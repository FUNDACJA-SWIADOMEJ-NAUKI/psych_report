unit ProcessingResultFrame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, ComCtrls, StdCtrls, Buttons,
  AppInterfaces, ProcessingResultPresenter;

type
  TProcessingResultFrame = class(TFrame, IProcessingResultView)
    ResetButton: TButton;
    CopyIconList: TImageList;
    ResultMemo: TMemo;
    ResultTabControl: TTabControl;
    CopyButton: TSpeedButton;
    procedure CopyButtonClick(Sender: TObject);
    procedure ResetButtonClick(Sender: TObject);
    procedure ResultTabControlChange(Sender: TObject);
  private
    FPresenter: TProcessingResultPresenter;
  public
    destructor Destroy; override;
    procedure SetPresenter(Presenter: TProcessingResultPresenter);
    function GetCurrentTab: string;
    procedure ShowText(ReportPart: string);

  end;

implementation

{$R *.lfm}

{ TProcessingResultFrame }

procedure TProcessingResultFrame.SetPresenter(Presenter: TProcessingResultPresenter);
begin
  FPresenter := Presenter;
end;

procedure TProcessingResultFrame.ResultTabControlChange(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnTabChanged;
end;

destructor TProcessingResultFrame.Destroy;
begin
  if Assigned(FPresenter) then FPresenter.Free;
  inherited Destroy;
end;

procedure TProcessingResultFrame.CopyButtonClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnCopyButtonClicked;
end;

procedure TProcessingResultFrame.ResetButtonClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnResetButtonClicked;
end;

function TProcessingResultFrame.GetCurrentTab: string;
begin
  Result := ResultTabControl.Tabs[ResultTabControl.TabIndex];
end;

procedure TProcessingResultFrame.ShowText(ReportPart: string);
begin
  ResultMemo.Lines.Text := ReportPart;
end;

end.
