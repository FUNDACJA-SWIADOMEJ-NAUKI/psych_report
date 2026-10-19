unit ProcessRecordingThread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, PsychReportCore;

type
  TProcessRecordingCompletedEvent = procedure(Result: TProcessingResult) of object;

  TProcessRecordingThread = class(TThread)
  private
    FProcessingConfig: TProcessingConfig;
    FFilePath: string;
    FOnCompleted: TProcessRecordingCompletedEvent;
    FResult: TProcessingResult;
    procedure SyncComplete;
  protected
    procedure Execute; override;
  public
    constructor Create(Config: TProcessingConfig; FilePath: string);
    property OnProcessingCompleted: TProcessRecordingCompletedEvent write FOnCompleted;
  end;

implementation

constructor TProcessRecordingThread.Create(Config: TProcessingConfig; FilePath: string);
begin
  inherited Create(True);
  FProcessingConfig := Config;
  FFilePath := FilePath;
  FreeOnTerminate := False;
end;

procedure TProcessRecordingThread.Execute;
begin
  ProcessRecording(PChar(FFilePath), FProcessingConfig, FResult);
  if not Terminated then Queue(@SyncComplete);
end;

procedure TProcessRecordingThread.SyncComplete;
begin
  if Assigned(FOnCompleted) and not Terminated then FOnCompleted(FResult);
end;

end.
