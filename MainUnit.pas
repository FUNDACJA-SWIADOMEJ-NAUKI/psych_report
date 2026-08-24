unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, Forms, Controls, Graphics, Dialogs, StdCtrls, PsychReportCore;

type

  { TMainForm }

  TMainForm = class(TForm)
    Label1: TLabel;
    SelectRecordingButton: TButton;
    RunButton: TButton;
    OpenRecordingDialog: TOpenDialog;
    procedure SelectRecordingButtonClick(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
  private
    FProcessingConfig: TProcessingConfig;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.SelectRecordingButtonClick(Sender: TObject);
begin
  if not(OpenRecordingDialog.Execute) then Exit;
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  Result: TProcessingResult;
begin
  FProcessingConfig.speech_to_text_model_path := '/home/mateusz/Projects/psych_report/models/ggml-large-v3-turbo-q5_0.bin';
  FProcessingConfig.llm_model_path := '/home/mateusz/Projects/psych_report/models/Bielik-1.5B-v3.0-Instruct.Q8_0.gguf';
  ProcessRecording('/home/mateusz/Projects/test.mp4', FProcessingConfig, Result);
  ShowMessage(Result.transcript);
  ShowMessage(Result.report);
end;

end.

