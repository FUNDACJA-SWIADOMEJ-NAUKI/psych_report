unit SettingsEditor;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType;

type

  TSettingsForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    SaveButton: TButton;
    LlmModelPathInput: TEdit;
    Prompt: TMemo;
    SpeechToTextModelInputLabel: TLabel;
    SpeechToTextModelPathInput: TEdit;
    procedure FormShow(Sender: TObject);
    procedure PromptChange(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private

  public

  end;

var
  SettingsForm: TSettingsForm;

implementation

uses Settings;

  {$R *.lfm}

  { TSettingsForm }

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  SpeechToTextModelPathInput.Text := AppSettings.SpeechToTextModelPath;
  LlmModelPathInput.Text := AppSettings.LlmModelPath;
  Prompt.Text := AppSettings.Prompt;
end;

procedure TSettingsForm.PromptChange(Sender: TObject);
begin

end;

procedure TSettingsForm.SaveButtonClick(Sender: TObject);
begin
  AppSettings.SpeechToTextModelPath := SpeechToTextModelPathInput.Text;
  AppSettings.LlmModelPath := LlmModelPathInput.Text;
  AppSettings.Prompt := Prompt.Text;

  AppSettings.SaveSettings;
  ModalResult := mrOK;
end;

end.
