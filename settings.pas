unit Settings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, AppInterfaces;

type
  TSettings = class(TInterfacedObject, ISettings)
  private
    FSpeechToTextModelPath: string;
    FLlmModelPath: string;
    FPrompt: string;
    procedure ReadSettings;
  public
    function GetSettings: TSettingsDTO;
    procedure UpdateSettings(const NewSettings: TSettingsDTO);
    constructor Create;
    procedure SaveSettings;
  end;

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

function TSettings.GetSettings: TSettingsDTO;
var
  Settings: TSettingsDTO;
begin
  with Settings do
  begin
    SpeechToTextModelPath := FSpeechToTextModelPath;
    LlmModelPath := FLlmModelPath;
    Prompt := FPrompt;
  end;
  Result := Settings;
end;

procedure TSettings.UpdateSettings(const NewSettings: TSettingsDTO);
begin
  with NewSettings do
  begin
    FSpeechToTextModelPath := SpeechToTextModelPath;
    FLlmModelPath := LlmModelPath;
    FPrompt := Prompt;
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
end;

constructor TSettings.Create;
begin
  ReadSettings;
end;

end.
