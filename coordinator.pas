unit Coordinator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, SysUtils, AppInterfaces, PsychReportCore, SettingsEditorView;

type
  TCoordinator = class(TInterfacedObject, ICoordinatorDelegate)
  private
    FMainView: IMainView;
    FCurrentFrame: TFrame;
    FProcessingConfig: TProcessingConfig;
    FSettings: ISettings;
    procedure SwitchFrame(NewFrame: TFrame);
  public
    constructor Create(View: IMainView);
    destructor Destroy; override;
    procedure Start;
    procedure OnSettingsMenuItemClicked;
    procedure OnRun(const RecordingPath: string);

  end;

implementation

{ TCoordinator }

uses Settings, RecordingSelectionPresenter, RecordingSelectionFrame,
  SettingsEditorPresenter;

procedure TCoordinator.SwitchFrame(NewFrame: TFrame);
begin
  if Assigned(FCurrentFrame) then FCurrentFrame.Free;
  FCurrentFrame := NewFrame;
  FMainView.ShowFrame(FCurrentFrame);
end;

constructor TCoordinator.Create(View: IMainView);
begin
  FMainView := View;
  FMainView.SetDelegate(Self);
  FSettings := TSettings.Create;
end;

destructor TCoordinator.Destroy;
begin
  if Assigned(FCurrentFrame) then FCurrentFrame.Free;
  inherited Destroy;
end;

procedure TCoordinator.Start;
var
  View: TRecordingSelectionFrame;
  Presenter: TRecordingSelectionPresenter;
begin
  View := TRecordingSelectionFrame.Create(nil);
  Presenter := TRecordingSelectionPresenter.Create(View);
  Presenter.SetDelegate(Self);
  View.SetPresenter(Presenter);
  SwitchFrame(View);
end;

procedure TCoordinator.OnSettingsMenuItemClicked;
var
  View: TSettingsForm;
  Presenter: TSettingsEditorPresenter;
begin
  View := TSettingsForm.Create(nil);
  Presenter := TSettingsEditorPresenter.Create(View, FSettings);
  View.SetPresenter(Presenter);
  View.ShowModal;
  View.Free;
end;

procedure TCoordinator.OnRun(const RecordingPath: string);
var
  Result: TProcessingResult;
begin
  with FSettings.GetSettings do
  begin
    FProcessingConfig.speech_to_text_model_path :=
      PChar(SpeechToTextModelPath);
    FProcessingConfig.llm_model_path := PChar(LlmModelPath);
    FProcessingConfig.prompt := PChar(Prompt);
    ProcessRecording(PChar(RecordingPath), FProcessingConfig, Result);
    FMainView.ShowMessageModal(Result.transcript);
    FMainView.ShowMessageModal(Result.report);
  end;

end;

end.
