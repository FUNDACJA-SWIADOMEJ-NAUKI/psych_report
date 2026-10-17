unit LoadingPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, AppInterfaces, PsychReportCore, ProcessRecordingThread;

type
  TLoadingPresenter = class(TObject)
  private
    FView: ILoadingView;
    FDelegate: ICoordinatorDelegate;
    FRecordingPath: string;
    FWorkerThread: TProcessRecordingThread;
    FSettings: ISettings;
    procedure OnResult(Result: TProcessingResult);
  public
    constructor Create(View: ILoadingView; Delegate: ICoordinatorDelegate; Settings: ISettings; const RecordingPath: string);
    destructor Destroy; override;
    procedure StartWork;
  end;

implementation

constructor TLoadingPresenter.Create(View: ILoadingView; Delegate: ICoordinatorDelegate; Settings: ISettings; const RecordingPath: string);
begin
  FView := View;
  FDelegate := Delegate;
  FSettings := Settings;
  FRecordingPath := RecordingPath;
end;

destructor TLoadingPresenter.Destroy;
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;
    FWorkerThread.WaitFor;
    FWorkerThread.Free;
  end;
  inherited Destroy;
end;

procedure TLoadingPresenter.StartWork;
var
  ProcessingConfig: TProcessingConfig;
begin
  with FSettings.GetSettings do
  begin
    ProcessingConfig.speech_to_text_model_path := PChar(SpeechToTextModelPath);
    ProcessingConfig.llm_model_path := PChar(LlmModelPath);
    ProcessingConfig.prompt := PChar(Prompt);
    FWorkerThread := TProcessRecordingThread.Create(ProcessingConfig, FRecordingPath);
    FWorkerThread.OnProcessingCompleted := @OnResult;
    FWorkerThread.Start;
  end;
end;

procedure TLoadingPresenter.OnResult(Result: TProcessingResult);
begin
  FDelegate.OnRecordingProcessed(Result.report, Result.transcript);
end;

end.
