unit RecordingSelectionFrame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, AppInterfaces,
  RecordingSelectionPresenter;

type
  TRecordingSelectionFrame = class(TFrame, IRecordingSelectionView)
    RecordingFileNameLabel: TLabel;
    SelectRecordingButton: TButton;
    RunButton: TButton;
    OpenRecordingDialog: TOpenDialog;
    procedure RunButtonClick(Sender: TObject);
    procedure SelectRecordingButtonClick(Sender: TObject);
  private
    FPresenter: TRecordingSelectionPresenter;
  public
    destructor Destroy; override;
    procedure SetPresenter(Presenter: TRecordingSelectionPresenter);
    procedure OpenDialog;
    function GetFilePath: string;
    procedure SetFileNameLabel(const FilePath: string);
    procedure MakeFileNameLabelVisible;
  end;

implementation

{$R *.lfm}

{ TRecordingSelectionFrame }

procedure TRecordingSelectionFrame.SetPresenter(Presenter: TRecordingSelectionPresenter);
begin
  FPresenter := Presenter;
end;

procedure TRecordingSelectionFrame.OpenDialog;
begin
  if not (OpenRecordingDialog.Execute) then Exit;
  if Assigned(FPresenter) and (OpenRecordingDialog.FileName <> '') then
    FPresenter.OnRecordingFileSelected;
end;

procedure TRecordingSelectionFrame.RunButtonClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnRunButtonClicked(Sender);
end;

procedure TRecordingSelectionFrame.SelectRecordingButtonClick(Sender: TObject);
begin
  if Assigned(FPresenter) then FPresenter.OnSelectRecordingButtonClicked(Sender);
end;

destructor TRecordingSelectionFrame.Destroy;
begin
  if Assigned(FPresenter) then FPresenter.Free;
  inherited Destroy;
end;

function TRecordingSelectionFrame.GetFilePath: string;
begin
  Result := OpenRecordingDialog.FileName;
end;

procedure TRecordingSelectionFrame.SetFileNameLabel(const FilePath: string);
begin
  RecordingFileNameLabel.Caption := FilePath;
end;

procedure TRecordingSelectionFrame.MakeFileNameLabelVisible;
begin
  RecordingFileNameLabel.Visible := True;
end;

end.
