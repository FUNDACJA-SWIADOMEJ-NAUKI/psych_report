#include <stdio.h>
#include <string.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/channel_layout.h>
#include <libavutil/opt.h>
#include <libswresample/swresample.h>
#include "whisper.h"
#include "llama.h"

#include "psych_report_core.h"

#define NOB_IMPLEMENTATION
#include "nob.h"

#define PROJECT_NAME "psych_report_core"
#define RESPONSE_TOKENS_NUMBER 4000

int call_llm(const char* prompt, const char *llm_model_path, char** result) {
  llama_backend_init();
  struct llama_model_params model_params = llama_model_default_params();
  model_params.n_gpu_layers = 999;
  struct llama_model *model = llama_model_load_from_file(llm_model_path, model_params);

  if (!model) {
    fprintf(stderr, "Error: Unable to load model\n");
    return 1;
  }

  const struct llama_vocab *vocab = llama_model_get_vocab(model);

  // find the number of tokens in the prompt
  const int max_prompt_tokens = -llama_tokenize(vocab, prompt, strlen(prompt), NULL, 0, true, true);
  llama_token *prompt_tokens = malloc(max_prompt_tokens * sizeof(llama_token));
  int prompt_tokens_number = llama_tokenize(vocab, prompt, strlen(prompt), prompt_tokens, max_prompt_tokens, true, true);
  if (prompt_tokens_number < 0) {
    fprintf(stderr, "Error: Prompt tokenization failed\n");
    free(prompt_tokens);
    llama_model_free(model);
    llama_backend_free();
    return 1;
  }

  // Initialize context
  struct llama_context_params context_params = llama_context_default_params();
  context_params.n_ctx = prompt_tokens_number + RESPONSE_TOKENS_NUMBER;
  context_params.n_batch = prompt_tokens_number;
  struct llama_context *context = llama_init_from_model(model, context_params);

  // batches

  struct llama_batch batch = llama_batch_init(prompt_tokens_number, 0, 1);
  for (int i = 0; i < prompt_tokens_number; i++) {
    batch.token[i] = prompt_tokens[i];
    batch.pos[i] = i;
    batch.n_seq_id[i] = 1;
    batch.seq_id[i][0] = 0;
    batch.logits[i] = (i == prompt_tokens_number - 1);  // Only last token needs logits
  }
    batch.n_tokens = prompt_tokens_number;

  // Process prompt
  if (llama_decode(context, batch) != 0) {
      fprintf(stderr, "Error: Failed to decode prompt\n");
      llama_batch_free(batch);
      free(prompt_tokens);
      //return NULL;
      return 1;
  }
  free(prompt_tokens);

  struct llama_sampler *sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
  llama_sampler_chain_add(sampler, llama_sampler_init_greedy());

  uint32_t current_position = prompt_tokens_number;
  llama_token *tokens = malloc(RESPONSE_TOKENS_NUMBER * sizeof(llama_token));
  while (current_position < context_params.n_ctx) {
    llama_token new_token = llama_sampler_sample(sampler, context, batch.n_tokens  - 1);
    tokens[current_position - prompt_tokens_number] = new_token;

    if (llama_vocab_is_eog(vocab, new_token)) {
      break;
    }

    batch.token[0]    = new_token;
    batch.pos[0]      = current_position;
    batch.n_seq_id[0] = 1;
    batch.seq_id[0][0] = 0;
    batch.logits[0]   = true;
    batch.n_tokens    = 1;

    if (llama_decode(context, batch) != 0) {
      fprintf(stderr, "Error: Failed to decode prompt\n");
      llama_batch_free(batch);
      llama_sampler_free(sampler);
      free(tokens);
      //return NULL;
      return 1;
    }
    current_position++;
  }
  int n_generated_tokens = current_position - prompt_tokens_number;
  int response_length_estimate = n_generated_tokens * 4 + 1000;
  *result = malloc(response_length_estimate * sizeof(char));
  llama_detokenize(vocab, tokens, n_generated_tokens, *result, response_length_estimate, false, true);
  free(tokens);

  // Clean up
  llama_batch_free(batch);
  llama_sampler_free(sampler);
  llama_free(context);
  llama_model_free(model);
  llama_backend_free();

  return 0;
}

int extract_audio(const char *input_file_path, float **pcm_buffer) {
  AVFormatContext *input_format_context = NULL;
  if(avformat_open_input(&input_format_context, input_file_path, NULL, NULL) < 0) return -1;
  avformat_find_stream_info(input_format_context, NULL);
  int audio_stream_idx = av_find_best_stream(input_format_context, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
  AVStream *input_stream = input_format_context->streams[audio_stream_idx];

  const AVCodec *decoder = avcodec_find_decoder(input_stream->codecpar->codec_id);
  AVCodecContext *decoder_context = avcodec_alloc_context3(decoder);
  avcodec_parameters_to_context(decoder_context, input_stream->codecpar);
  if (avcodec_open2(decoder_context, decoder, NULL) < 0) return -1;

  // configure resampling
  AVChannelLayout out_channel_layout;
  av_channel_layout_default(&out_channel_layout, 1);
  SwrContext *swr = swr_alloc();
  av_opt_set_chlayout(swr, "out_chlayout", &out_channel_layout, 0);
  av_opt_set_sample_fmt(swr, "out_sample_fmt", AV_SAMPLE_FMT_FLT, 0);
  av_opt_set_int(swr, "out_sample_rate", 16000, 0);
  av_opt_set_chlayout(swr, "in_chlayout", &decoder_context->ch_layout, 0);
  av_opt_set_sample_fmt(swr, "in_sample_fmt", decoder_context->sample_fmt, 0);
  av_opt_set_int(swr, "in_sample_rate", decoder_context->sample_rate, 0);
  swr_init(swr);

  // Output
  *pcm_buffer = NULL;
  int total_samples = 0;
  int max_samples = 0;
  AVFrame *frame = av_frame_alloc();
  AVPacket *packet = av_packet_alloc();

  while (av_read_frame(input_format_context, packet) == 0) {
    if (packet->stream_index == audio_stream_idx) {
      avcodec_send_packet(decoder_context, packet);
      while (avcodec_receive_frame(decoder_context, frame) == 0) {
        int out_count = swr_get_out_samples(swr, frame->nb_samples);

        if (total_samples + out_count > max_samples) {
          max_samples = (total_samples + out_count) * 2 + 4096;
          *pcm_buffer = realloc(*pcm_buffer, max_samples * sizeof(float));
        }
        uint8_t *out_data[1] = { (uint8_t*)(*pcm_buffer + total_samples) };
        int converted_samples = swr_convert(swr, out_data, out_count, (const uint8_t **)frame->extended_data, frame->nb_samples);
        if (converted_samples > 0) {
          total_samples += converted_samples;
        }
      }
    }
    av_packet_unref(packet);
  }

  // Flush the resampler to get any remaining cached samples
  int out_count = swr_get_out_samples(swr, 0);
  if (out_count > 0) {
      if (total_samples + out_count > max_samples) {
          max_samples = total_samples + out_count;
          *pcm_buffer = realloc(*pcm_buffer, max_samples * sizeof(float));
      }
      uint8_t *out_data[1] = { (uint8_t*)(*pcm_buffer + total_samples) };
      int converted_samples = swr_convert(swr, out_data, out_count, NULL, 0);
      if (converted_samples > 0) {
          total_samples += converted_samples;
      }
  }

  // Clean up
  av_packet_free(&packet);
  av_frame_free(&frame);
  swr_free(&swr);
  avcodec_free_context(&decoder_context);
  avformat_close_input(&input_format_context);

  return total_samples;
}

int convert_speech_to_text(float *pcm_buffer, int total_samples, const char *whisper_model_path, char **output) {
  struct whisper_context_params context_params = whisper_context_default_params();
  context_params.use_gpu = true;
  struct whisper_context *context = whisper_init_from_file_with_params(whisper_model_path, context_params);

  struct whisper_full_params params = whisper_full_default_params(WHISPER_SAMPLING_BEAM_SEARCH);
  params.print_progress   = false;
  params.print_timestamps = false;
  params.no_timestamps    = true;
  params.language         = "pl";
  params.temperature     = 0.4f;
  params.temperature_inc = 1.0f;
  params.greedy.best_of  = 5;
  params.beam_search.beam_size = 5;

  if (whisper_full(context, params, pcm_buffer, total_samples) != 0) return 1;

  Nob_String_Builder sb = {0};
  const int n_segments = whisper_full_n_segments(context);
  for (int i = 0; i < n_segments; ++i) {
      const char *text = whisper_full_get_segment_text(context, i);
      nob_sb_append_cstr(&sb, text);
  }
  const char* result = nob_temp_sv_to_cstr(nob_sb_to_sv(sb));

  *output = malloc(strlen(result) + 1);
  strcpy(*output, result);

  // Clean up
  nob_sb_free(sb);
  whisper_free(context);

  return 0;
}


int process_recording(const char *input_file_path, ProcessingConfig config, ProcessingResult *result) {
  float *pcm_buffer = NULL;
  int total_samples = extract_audio(input_file_path, &pcm_buffer);

  printf("Successfully decoded %d samples into memory.\n", total_samples);

  char *whisper_result = NULL;
  convert_speech_to_text(pcm_buffer, total_samples, config.speech_to_text_model_path, &whisper_result);

  // Llama part
  // ========================

  const char *initial_prompt = "<|im_start|> user\nPolicz ile jest słów w zapisie nagrania. Oto zapis:\n";
  const char *prompt_ending = "<|im_end|> \n<|im_start|> assistant\n";
  char *prompt = malloc(strlen(initial_prompt) + strlen(whisper_result) + strlen(prompt_ending) + 1);
  strcpy(prompt, initial_prompt);
  strcat(prompt, whisper_result);
  strcat(prompt, prompt_ending);
  printf("%s\n", prompt);

  char *llm_result = NULL;
  call_llm(prompt, config.llm_model_path, &llm_result);

  result->transcript = whisper_result;
  result->report = llm_result;

  free(prompt);
  free(pcm_buffer);

  return 0;
}
