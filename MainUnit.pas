unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, PsychReportCore, AppInterfaces;

type

  { TMainForm }

  TMainForm = class(TForm, IMainView)
    MainMenu: TMainMenu;
    FramePanel: TPanel;
    SettingsMenuItem: TMenuItem;
    procedure SettingsMenuItemClick(Sender: TObject);
  private
    FDelegate: ICoordinatorDelegate;
  public
    procedure SetDelegate(Delegate: ICoordinatorDelegate);
    procedure ShowFrame(Frame: TObject);
    procedure ShowMessageModal(const Message: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.SettingsMenuItemClick(Sender: TObject);
begin
  if Assigned(FDelegate) then FDelegate.OnSettingsMenuItemClicked;
end;

procedure TMainForm.SetDelegate(Delegate: ICoordinatorDelegate);
begin
  FDelegate := Delegate;
end;

procedure TMainForm.ShowFrame(Frame: TObject);
var
  TargetFrame: TFrame;
begin
  if Frame is TFrame then
  begin
    TargetFrame := TFrame(Frame);
    TargetFrame.Visible := False;
    TargetFrame.Parent := FramePanel;
    TargetFrame.Align := alClient;
    TargetFrame.BringToFront;
    TargetFrame.Visible := True;
  end;
end;

procedure TMainForm.ShowMessageModal(const Message: string);
begin
  ShowMessage(Message);
end;

end.
