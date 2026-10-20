unit Coordinator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, SysUtils, AppInterfaces, SettingsEditorView;

type
  TCoordinator = class(TInterfacedObject, ICoordinatorDelegate)
  private
    FMainView: IMainView;
    FCurrentFrame: TFrame;
    FSettings: ISettings;
    procedure SwitchFrame(NewFrame: TFrame);
  public
    constructor Create(View: IMainView);
    destructor Destroy; override;
    procedure Start;
    procedure OnSettingsMenuItemClicked;
    procedure OnStartProcessingRecording(const RecordingPath: string);
    procedure OnRecordingProcessed(const Report: string; const Transcript: string);
    procedure Reset;
  end;

implementation

{ TCoordinator }

uses Settings, RecordingSelectionPresenter, RecordingSelectionFrame,
  SettingsEditorPresenter, LoadingPresenter, LoadingFrame,
  ProcessingResultPresenter, ProcessingResultFrame;

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

procedure TCoordinator.OnStartProcessingRecording(const RecordingPath: string);
var
  View: TLoadingFrame;
  Presenter: TLoadingPresenter;
begin
  View := TLoadingFrame.Create(nil);
  Presenter := TLoadingPresenter.Create(View, Self, FSettings, RecordingPath);
  View.SetPresenter(Presenter);
  SwitchFrame(View);
  Presenter.StartWork;
end;

procedure TCoordinator.OnRecordingProcessed(const Report: string;
  const Transcript: string);
var
  View: TProcessingResultFrame;
  Presenter: TProcessingResultPresenter;
begin
  View := TProcessingResultFrame.Create(nil);
  Presenter := TProcessingResultPresenter.Create(View, Self, Report, Transcript);
  View.SetPresenter(Presenter);
  SwitchFrame(View);
end;

procedure TCoordinator.Reset;
begin
  Start;
end;

end.
