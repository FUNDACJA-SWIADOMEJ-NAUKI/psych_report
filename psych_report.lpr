program psych_report;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  MainUnit,
  PsychReportCore,
  Settings,
  SettingsEditorView,
  AppInterfaces,
  RecordingSelectionPresenter,
  RecordingSelectionFrame,
  Coordinator, SettingsEditorPresenter;

  {$R *.res}

var
  AppCoordinator: TCoordinator;

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  {$PUSH}
  {$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  AppCoordinator := TCoordinator.Create(MainForm);
  AppCoordinator.Start;
  Application.Run;
end.
