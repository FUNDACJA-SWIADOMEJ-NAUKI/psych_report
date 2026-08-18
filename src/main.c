#include <stdio.h>
#include <stdlib.h>
#include "psych_report_core.h"

int main(int argc, char **argv) { 
  const char *input_file = argv[1];
  ProcessingResult result = {};
  process_recording(input_file, &result);

  printf("%s\n", result.transcript);
  printf("\n%s\n", result.report);
  
  free(result.report);
  free(result.transcript);
  return 0;
}

