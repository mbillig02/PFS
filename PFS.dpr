program PFS;

uses
  Forms,
  MFUnit in 'MFUnit.pas' {MainForm},
  IPHelper in 'IPHelper.pas',
  IPUnit in 'IPUnit.pas',
  About in 'About.pas' {AboutBox},
  UEUnit in 'UEUnit.pas' {UserEditorDlg},
  AUUnit in 'AUUnit.pas' {AddUserDlg},
  Vcl.Themes,
  Vcl.Styles,
  SetUnit in 'SetUnit.pas' {SettingsForm},
  ScrPosF in 'ScrPosF.pas' {ScrPosFrame: TFrame},
  UtlUnit in 'UtlUnit.pas',
  FTPUnit in 'FTPUnit.pas' {FTPForm},
  SFTPUnit in 'SFTPUnit.pas' {SFTPForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TUserEditorDlg, UserEditorDlg);
  Application.CreateForm(TAddUserDlg, AddUserDlg);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TFTPForm, FTPForm);
  Application.CreateForm(TSFTPForm, SFTPForm);
  Application.Run;
end.
