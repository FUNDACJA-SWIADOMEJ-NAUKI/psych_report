unit PsychReportCore;

{$mode ObjFPC}{$H+}

{$link psych_report_core.o}
{$ifdef WINDOWS}
  {$linklib kernel32}
  {$linklib msvcrt}
  {$linklib mingwex}
  {$linklib avcodec.dll.a}
  {$linklib avformat.dll.a}
  {$linklib avutil.dll.a}
  {$linklib swresample.dll.a}
  {$linklib llama.dll.a}
  {$linklib libwhisper.dll.a}
{$else}
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
{$endif}




interface

uses ctypes;

type
  {$IFDEF FPC}
            {$PACKRECORDS C}
  {$ENDIF}
  TProcessingResult = record
    transcript: pansichar;     // consider using PWideChar; use wchar_t in C code
    report: pansichar;
  end;

  TProcessingConfig = record
    speech_to_text_model_path: pansichar;
    llm_model_path: pansichar;
    prompt: pansichar;
  end;

{$ifdef WINDOWS}
  function sys_vsnprintf(buffer: PAnsiChar; count: NativeUInt; format: PAnsiChar; argptr: Pointer): Integer; cdecl; external 'msvcrt.dll' name '_vsnprintf';
{$endif}

function ProcessRecording(InputFilePath: pansichar; Config: TProcessingConfig;
  out Result: TProcessingResult): cint32; cdecl; external 'psych_report_core.dll' name 'process_recording';

implementation

uses Math;

{$ifdef WINDOWS}
  function bridge_vsnprintf(buffer: PAnsiChar; count: NativeUInt; format: PAnsiChar; argptr: Pointer): Integer; cdecl; public name '_vsnprintf';
  begin
    Result := sys_vsnprintf(buffer, count, format, argptr);
  end;

  initialization
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
{$endif}

end.
