unit ViewInterfaces;

{$mode ObjFPC}{$H+}

interface

uses Classes, Forms;

type
  IMainView = interface
    ['{D573B28C-C792-43E9-8DD0-4B3CD81A90B2}']
    procedure ShowFrame(Frame: TFrame);
  end;

  IRecordingSelectionView = interface
    ['{AE0B0821-BB49-420F-917D-B38B7BA05923}']
    function GetFilePath: string;
    procedure SetStatusLabel(const AText: string);
    procedure SetRunButtonClickHandler(Event: TNotifyEvent);
  end;

implementation

end.
