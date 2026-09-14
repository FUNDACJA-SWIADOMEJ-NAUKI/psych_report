unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, PsychReportCore, SettingsEditor;

type

  { TMainForm }

  TMainForm = class(TForm)
    Bevel1: TBevel;
    MainMenu: TMainMenu;
    SettingsMenuItem: TMenuItem;
    RecordingFileNameLabel: TLabel;
    SelectRecordingButton: TButton;
    RunButton: TButton;
    OpenRecordingDialog: TOpenDialog;
    procedure SettingsMenuItemClick(Sender: TObject);
    procedure SelectRecordingButtonClick(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
  private
    FProcessingConfig: TProcessingConfig;
    FRecordingFileName: string;
  public

  end;

var
  MainForm: TMainForm;

implementation

uses Settings;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.SelectRecordingButtonClick(Sender: TObject);
begin
  if not(OpenRecordingDialog.Execute) then Exit;
  FRecordingFileName:= OpenRecordingDialog.FileName;
  RecordingFileNameLabel.Caption := FRecordingFileName;
  RecordingFileNameLabel.Visible := true;
end;

procedure TMainForm.SettingsMenuItemClick(Sender: TObject);
var
  SettingsForm: TSettingsForm;
begin
     SettingsForm := TSettingsForm.Create(Nil);
     SettingsForm.ShowModal;
     FreeAndNil(SettingsForm);
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  Result: TProcessingResult;
begin
  FProcessingConfig.speech_to_text_model_path := PChar(AppSettings.SpeechToTextModelPath);
  FProcessingConfig.llm_model_path := PChar(AppSettings.LlmModelPath);
  FProcessingConfig.prompt := PChar(AppSettings.Prompt);
  ProcessRecording(PChar(FRecordingFileName), FProcessingConfig, Result);
  ShowMessage(Result.transcript);
  ShowMessage(Result.report);
end;

end.

