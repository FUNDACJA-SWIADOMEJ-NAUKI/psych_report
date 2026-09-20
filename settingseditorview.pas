unit SettingsEditorView;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LCLType, SettingsEditorPresenter, AppInterfaces;

type

  TSettingsForm = class(TForm, ISettingsEditorView)
    Button1: TButton;
    Button2: TButton;
    SaveButton: TButton;
    LlmModelPathInput: TEdit;
    Prompt: TMemo;
    SpeechToTextModelInputLabel: TLabel;
    SpeechToTextModelPathInput: TEdit;
    procedure FormShow(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    FPresenter: TSettingsEditorPresenter;
  public
    destructor Destroy; override;
    procedure DisplaySettings(const AppSettings: TSettingsDTO);
    function GetSettings: TSettingsDTO;
    procedure SetPresenter(Presenter: TSettingsEditorPresenter);
  end;

implementation

{$R *.lfm}

{ TSettingsForm }

procedure TSettingsForm.SaveButtonClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnSaveButtonClicked;
  ModalResult := mrOk;
end;

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnFormShown;
end;

destructor TSettingsForm.Destroy;
begin
  if Assigned(FPresenter) then FPresenter.Free;
  inherited Destroy;
end;

procedure TSettingsForm.DisplaySettings(const AppSettings: TSettingsDTO);
begin
  SpeechToTextModelPathInput.Text := AppSettings.SpeechToTextModelPath;
  LlmModelPathInput.Text := AppSettings.LlmModelPath;
  Prompt.Text := AppSettings.Prompt;
end;

function TSettingsForm.GetSettings: TSettingsDTO;
begin
  Result.SpeechToTextModelPath := SpeechToTextModelPathInput.Text;
  Result.LlmModelPath := LlmModelPathInput.Text;
  Result.Prompt := Prompt.Text;
end;

procedure TSettingsForm.SetPresenter(Presenter: TSettingsEditorPresenter);
begin
  FPresenter := Presenter;
end;

end.
