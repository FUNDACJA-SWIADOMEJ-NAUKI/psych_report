unit RecordingSelectionPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, AppInterfaces;

type
  TRecordingSelectionPresenter = class(TObject)
  private
    FView: IRecordingSelectionView;
    FDelegate: ICoordinatorDelegate;
  public
    constructor Create(View: IRecordingSelectionView);
    procedure SetDelegate(Delegate: ICoordinatorDelegate);
    procedure OnSelectRecordingButtonClicked(Sender: TObject);
    procedure OnRecordingFileSelected;
    procedure OnRunButtonClicked(Sender: TObject);
  end;

implementation

constructor TRecordingSelectionPresenter.Create(View: IRecordingSelectionView);
begin
  FView := View;
end;

procedure TRecordingSelectionPresenter.SetDelegate(Delegate: ICoordinatorDelegate);
begin
  FDelegate := Delegate;
end;

procedure TRecordingSelectionPresenter.OnSelectRecordingButtonClicked(Sender: TObject);
begin
  FView.OpenDialog;
end;

procedure TRecordingSelectionPresenter.OnRecordingFileSelected;
begin
  FView.SetFileNameLabel(FView.GetFilePath);
  FView.MakeFileNameLabelVisible;
end;

procedure TRecordingSelectionPresenter.OnRunButtonClicked(Sender: TObject);
begin
  if Assigned(FDelegate) then
    FDelegate.OnRun(FView.GetFilePath);
end;



end.
