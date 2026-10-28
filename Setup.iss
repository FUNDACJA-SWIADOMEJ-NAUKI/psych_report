[Setup]
AppName=psych_report
AppVersion=0.1
AppPublisher=Fundacja Świadomej Nauki
AppPublisherURL=https://swiadoma-nauka.pl/
WizardStyle=modern dynamic
DefaultDirName={autopf}\psych_report
DefaultGroupName=psych_report
UninstallDisplayIcon={app}\psych_report.exe
Compression=lzma2
SolidCompression=yes
SetupArchitecture=x64
OutputDir=setup
OutputBaseFilename=PsychReportSetup
AllowNoIcons=yes

[Dirs]
Name: "{app}\models"

[Files]
Source: "release\*.exe"; DestDir: "{app}"
Source: "release\*.dll"; DestDir: "{app}"
//Source: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin"; DestDir: "{app}\models"; DestName: "ggml-large-v3-turbo-q5_0.bin"; ExternalSize: 574_041_195; Flags: external download ignoreversion; Hash: "394221709cd5ad1f40c46e6031ca61bce88931e6e088c188294c6d5a55ffa7e2"; Components: models
//Source: "https://huggingface.co/speakleash/Bielik-Minitron-7B-v3.0-Instruct-GGUF/resolve/main/minitron-Bielik-7B-v3.0-Instruct-GGUF.Q6_K.gguf"; DestDir: "{app}\models"; DestName: "minitron-Bielik-7B-v3.0-Instruct-GGUF.Q6_K.gguf"; ExternalSize: 6_140_000_000; Flags: external download ignoreversion; Hash: "1abaa53ac3a89a8b5e9e00eb0c46409de3925b601cf4ea4c5392ab067778550b"; Components: models


[Icons]
Name: "{group}\psych_report"; Filename: "{app}\psych_report.exe"
