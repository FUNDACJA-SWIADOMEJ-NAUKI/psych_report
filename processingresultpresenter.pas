unit ProcessingResultPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Clipbrd, AppInterfaces;

type
  TProcessingResultPresenter = class(TObject)
  private
    FView: IProcessingResultView;
    FDelegate: ICoordinatorDelegate;
    FReport: string;
    FTranscript: string;
    function GetResultPart(const PartName: string): string;
  public
    constructor Create(View: IProcessingResultView; Delegate: ICoordinatorDelegate;
      Report: string; Transcript: string);
    procedure OnTabChanged;
    procedure OnCopyButtonClicked;
    procedure OnResetButtonClicked;
  end;

implementation

{ TProcessingResultPresenter }

function TProcessingResultPresenter.GetResultPart(const PartName: string): string;
begin
  case LowerCase(PartName) of
    'report': Result := FReport;
    'transcript': Result := FTranscript;
    else
      raise Exception.CreateFmt('Unknown field: %s', [PartName]);
  end;
end;

constructor TProcessingResultPresenter.Create(View: IProcessingResultView;
  Delegate: ICoordinatorDelegate; Report: string; Transcript: string);
begin
  FView := View;
  FDelegate := Delegate;
  FReport := Report;
  FTranscript := Transcript;
  FView.ShowText(Report);
end;

procedure TProcessingResultPresenter.OnTabChanged;
var
  CurrentTab: string;
  ResultPart: string;
begin
  CurrentTab := FView.GetCurrentTab;
  ResultPart := GetResultPart(CurrentTab);
  FView.ShowText(ResultPart);
end;

procedure TProcessingResultPresenter.OnCopyButtonClicked;
var
  CurrentTab: string;
begin
  CurrentTab := FView.GetCurrentTab;
  Clipboard.AsText := GetResultPart(CurrentTab);
end;

procedure TProcessingResultPresenter.OnResetButtonClicked;
begin
  FDelegate.Reset;
end;

end.
