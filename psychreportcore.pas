unit PsychReportCore;

{$mode ObjFPC}{$H+}

{$link psych_report_core.o}
{$linklib stdc++}
{$linklib avcodec}
{$linklib avformat}
{$linklib avutil}
{$linklib swresample}
{$linklib ggml}
{$linklib ggml-base}
{$linklib ggml-cpu}
{$linklib whisper}
{$linklib llama}

interface

uses ctypes;

type
    {$IFDEF FPC}
            {$PACKRECORDS C}
    {$ENDIF}
    TProcessingResult = record
      transcript: PAnsiChar;     // consider using PWideChar; use wchar_t in C code
      report: PAnsiChar;
    end;
    TProcessingConfig = record
      speech_to_text_model_path: PAnsiChar;
      llm_model_path: PAnsiChar;
      prompt: PAnsiChar;
    end;

function ProcessRecording(InputFilePath: PAnsiChar; Config: TProcessingConfig; out Result: TProcessingResult):cint32; cdecl; external name 'process_recording';

implementation

end.

