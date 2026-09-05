#ifndef PSYCH_REPORT_CORE
#define PSYCH_REPORT_CORE

typedef struct {
  char* transcript;
  char* report;
} ProcessingResult;

typedef struct {
    const char* speech_to_text_model_path;
    const char* llm_model_path;
    const char* prompt;
} ProcessingConfig;

int process_recording(const char *input_file_path, ProcessingConfig config, ProcessingResult *result);

#endif
