unit SettingsEditorPresenter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, AppInterfaces;

type
  TSettingsEditorPresenter = class(TObject)
  private
    FView: ISettingsEditorView;
    FDelegate: ICoordinatorDelegate;
    FModel: ISettings;
  public
    constructor Create(View: ISettingsEditorView; Model: ISettings);
    procedure SetDelegate(Delegate: ICoordinatorDelegate);
    procedure OnFormShown;
    procedure OnSaveButtonClicked;
  end;

implementation

{ TSettingsEditorPresenter }

constructor TSettingsEditorPresenter.Create(View: ISettingsEditorView; Model: ISettings);
begin
  FView := View;
  FModel := Model;
end;

procedure TSettingsEditorPresenter.SetDelegate(Delegate: ICoordinatorDelegate);
begin
  FDelegate := Delegate;
end;

procedure TSettingsEditorPresenter.OnFormShown;
begin
  FView.DisplaySettings(FModel.GetSettings);
end;

procedure TSettingsEditorPresenter.OnSaveButtonClicked;
begin
  FModel.UpdateSettings(FView.GetSettings);
  FModel.SaveSettings;
end;

end.
