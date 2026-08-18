#ifndef PSYCH_REPORT_CORE
#define PSYCH_REPORT_CORE

typedef struct {
  char* transcript;
  char* report;
} ProcessingResult;

int process_recording(const char *input_file_path, ProcessingResult *result);

#endif
