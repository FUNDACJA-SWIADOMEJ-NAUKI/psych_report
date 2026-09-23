program AssembleRelease;

{$mode ObjFPC}{$H+}

uses
  SysUtils,
  Process;

  function RunCommand(const Executable: string; const Args: array of string): boolean;
  var
    AProcess: TProcess;
    I: integer;
  begin
    AProcess := TProcess.Create(nil);
    try
      AProcess.Executable := Executable;
      for I := Low(Args) to High(Args) do
        AProcess.Parameters.Add(Args[I]);

      AProcess.Options := [poWaitOnExit, poUsePipes];
      WriteLn('Running: ', Executable, ' ...');
      AProcess.Execute;
      Result := (AProcess.ExitCode = 0);
    finally
      AProcess.Free;
    end;
  end;

begin
  WriteLn('=== Starting Release Assemble ===');

  if not DirectoryExists('release') then
  begin
    if not CreateDir('release') then Writeln('Failed to create directory !');
  end;

  if not RunCommand('cp', ['psych_report', 'release/psych_report']) then
  begin
    WriteLn('Error: Build failed!');
    Halt(1);
  end;

  if not RunCommand('cp', ['-a', 'psych_report_core/build/.', 'release/']) then
  begin
    WriteLn('Error: Build failed!');
    Halt(1);
  end;

  RunCommand('rm', ['-rf', 'release/main', 'release/obj']);

  WriteLn('=== Assemble Successful ===');
end.
