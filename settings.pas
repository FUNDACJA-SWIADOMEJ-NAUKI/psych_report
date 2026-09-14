unit Settings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;

type
  TSettings = class(TObject)
  private
    FSpeechToTextModelPath: string;
    FLlmModelPath: string;
    FPrompt: string;
    FOnChanged: TNotifyEvent;
    procedure ReadSettings;
  public
    property SpeechToTextModelPath: string
      read FSpeechToTextModelPath write FSpeechToTextModelPath;
    property LlmModelPath: string read FLlmModelPath write FLlmModelPath;
    property Prompt: string read FPrompt write FPrompt;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    constructor Create;
    procedure SaveSettings;
  end;

var
  AppSettings: TSettings;

implementation

const
  DefaultSpeechToModelPath = 'models/ggml-large-v3-turbo-q5_0.bin';
  DefaultLlmModelPath = 'models/minitron-Bielik-7B-v3.0-Instruct-GGUF.Q6_K.gguf';
  DefaultPrompt =
    'Wciel się w rolę psychiatry i napisz dokładny raport ze spotkania z pacjentem. Nie pisz co robisz, napisz sam raport. Oto zapis rozmowy:';


{ TSettings }
procedure TSettings.ReadSettings;
var
  SettingsIni: TIniFile;
begin
  SettingsIni := TIniFile.Create('settings.ini');
  try
    FSpeechToTextModelPath :=
      SettingsIni.ReadString('Main', 'SpeechToTextModelPath', DefaultSpeechToModelPath);
    FLlmModelPath := SettingsIni.ReadString('Main', 'LlmModelPath', DefaultLlmModelPath);
    FPrompt := SettingsIni.ReadString('Main', 'Prompt', DefaultPrompt);
  finally
    SettingsIni.Free;
  end;
end;

procedure TSettings.SaveSettings;
var
  SettingsIni: TIniFile;
begin
  SettingsIni := TIniFile.Create('settings.ini');
  try
    SettingsIni.WriteString('Main', 'SpeechToTextModelPath', FSpeechToTextModelPath);
    SettingsIni.WriteString('Main', 'LlmModelPath', FLlmModelPath);
    SettingsIni.WriteString('Main', 'Prompt', FPrompt);
  finally
    SettingsIni.Free;
  end;

  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor TSettings.Create;
begin
  inherited Create;
  ReadSettings;
end;

initialization
  AppSettings := TSettings.Create;

finalization
  AppSettings.Free;

end.
