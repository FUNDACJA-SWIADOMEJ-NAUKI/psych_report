program BuildCore;

{$mode ObjFPC}{$H+}
{$modeswitch arrayoperators}

uses
  SysUtils,
  Process;

var
  MakeArgs: array of string;
  Output: string;

begin
  WriteLn('=== Starting FPC ' + ParamStr(3) + ' Build ===');

  SetLength(MakeArgs, 1);
  if ParamStr(3) = 'Release' then MakeArgs := MakeArgs + ['config=release'];

  if not RunCommandIndir('./psych_report_core', 'premake5', ['gmake'], Output) then
  begin
    WriteLn('Error: Build failed!');
    Halt(1);
  end;

  if not RunCommandIndir('./psych_report_core', 'make', MakeArgs, Output) then
  begin
    WriteLn('Error: Build failed!');
    Halt(1);
  end;

  WriteLn('=== Build Successful ===');
end.
