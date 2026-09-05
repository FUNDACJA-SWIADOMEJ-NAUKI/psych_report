#include <stdio.h>
#include <stdlib.h>
#include "psych_report_core.h"

int main(int argc, char **argv) {
  const char *input_file = argv[1];
  ProcessingResult result = {};
  ProcessingConfig config = {
    .speech_to_text_model_path = "/home/mateusz/Projects/psych_report/models/ggml-large-v3-turbo-q5_0.bin",
    .llm_model_path = "/home/mateusz/Projects/psych_report/models/minitron-Bielik-7B-v3.0-Instruct-GGUF.Q6_K.gguf",
    .prompt = "Wciel się w rolę psychiatry i napisz dokładny raport ze spotkania z pacjentem. Nie pisz co robisz, napisz sam raport. Oto zapis rozmowy:"
  };
  process_recording(input_file, config, &result);

  printf("%s\n", result.transcript);
  printf("\n%s\n", result.report);

  free(result.report);
  free(result.transcript);
  return 0;
}

