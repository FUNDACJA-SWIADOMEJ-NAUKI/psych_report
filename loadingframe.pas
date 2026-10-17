unit LoadingFrame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, AppInterfaces, LoadingPresenter;

type
  TLoadingFrame = class(TFrame, ILoadingView)
    ProgressBar: TProgressBar;
  private
    FPresenter: TLoadingPresenter;
  public
    destructor Destroy; override;
    procedure SetPresenter(Presenter: TLoadingPresenter);
  end;

implementation

{$R *.lfm}

{ TLoadingFrame }

destructor TLoadingFrame.Destroy;
begin
  if Assigned(FPresenter) then FPresenter.Free;
  inherited Destroy;
end;

procedure TLoadingFrame.SetPresenter(Presenter: TLoadingPresenter);
begin
  FPresenter := Presenter;
end;

end.

