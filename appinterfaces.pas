unit AppInterfaces;

{$mode ObjFPC}{$H+}

interface

type

  ICoordinatorDelegate = interface
    ['{AA6E51B9-5C9A-44C4-8EA0-BDA92FC8F995}']
    procedure OnRun(const RecordingPath: string);
    procedure OnSettingsMenuItemClicked;
  end;

  IMainView = interface
    ['{D573B28C-C792-43E9-8DD0-4B3CD81A90B2}']
    procedure ShowFrame(Frame: TObject);
    procedure ShowMessageModal(const Message: string);
    procedure SetDelegate(Delegate: ICoordinatorDelegate);
  end;

  IRecordingSelectionView = interface
    ['{AE0B0821-BB49-420F-917D-B38B7BA05923}']
    procedure OpenDialog;
    function GetFilePath: string;
    procedure SetFileNameLabel(const FilePath: string);
    procedure MakeFileNameLabelVisible;
  end;

  TSettingsDTO = record
    SpeechToTextModelPath: string;
    LlmModelPath: string;
    Prompt: string;
  end;

  ISettings = interface
    ['{50663EC8-CE56-4D06-AAAC-19F82A5A205A}']
    function GetSettings: TSettingsDTO;
    procedure UpdateSettings(const NewSettings: TSettingsDTO);
    procedure SaveSettings;
  end;

  ISettingsEditorView = interface
    ['{DAADF55D-F552-4F41-B6C2-2F4558398CB3}']
    procedure DisplaySettings(const AppSettings: TSettingsDTO);
    function GetSettings: TSettingsDTO;
  end;

implementation

end.
