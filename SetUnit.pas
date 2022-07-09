unit SetUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvExControls, JvPageList, Vcl.ComCtrls,
  JvExComCtrls, JvPageListTreeView, Vcl.StdCtrls, ScrPosF, JvComponentBase,
  JvBalloonHint, Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TSettingsForm = class(TForm)
    JvSettingsTreeView: TJvSettingsTreeView;
    JvPageList: TJvPageList;
    JvStandardPageForm: TJvStandardPage;
    SetDefaultScrrenBtn: TButton;
    SetAlomstFullScreenBtn: TButton;
    SavFrmSizChkBox: TCheckBox;
    SavFrmPosChkBox: TCheckBox;
    TScrPosFrame: TScrPosFrame;
    JvStandardPageAutoStart: TJvStandardPage;
    AutoStartFtpChkBox: TCheckBox;
    AutoStartSftpChkBox: TCheckBox;
    JvStandardPageDirectories: TJvStandardPage;
    DtaDirGrpBox: TGroupBox;
    DtaDirLbl: TLabel;
    DtaDirCopyToClpBrdBtn: TButton;
    DtaDirOpenInExplorerBtn: TButton;
    DtaDirJvBalloonHint: TJvBalloonHint;
    TmpDirGrpBox: TGroupBox;
    TmpDirLbl: TLabel;
    TmpDirCopyToClpBrdBtn: TButton;
    TmpDirOpenInExplorerBtn: TButton;
    TmpDirJvBalloonHint: TJvBalloonHint;
    JvStandardPageKeys: TJvStandardPage;
    KeysMemo: TMemo;
    ExportDsaPublicKeyBtn: TButton;
    ExportEcPublicKeyBtn: TButton;
    ExportRsaPublicKeyBtn: TButton;
    KeysPanel: TPanel;
    JvStandardPageTestItems: TJvStandardPage;
    CreateTestItemsBtn: TButton;
    CreateTestItemsINIBtn: TButton;
    AutoCreateTestItemsChkBox: TCheckBox;
    JvStandardPageStyles: TJvStandardPage;
    StylesListBox: TListBox;
    JvStandardPageMiscellaneous: TJvStandardPage;
    IPInfoMemo: TMemo;
    IPAddressInfoGrpBox: TGroupBox;
    LogDirGrpBox: TGroupBox;
    LogDirLbl: TLabel;
    LogDirCopyToClpBrdBtn: TButton;
    LogDirOpenInExplorerBtn: TButton;
    LogDirJvBalloonHint: TJvBalloonHint;
    JvStandardPageRootAccess: TJvStandardPage;
    RootAccessListBox: TListBox;
    RootAccessStatusLbl: TLabel;
    UsersRefreshBtn: TButton;
    JvStandardPageSFTPOptions: TJvStandardPage;
    GatherFilePermissionsChkBox: TCheckBox;
    LogFileReadChkBox: TCheckBox;
    LogReadDirFileInfoChkBox: TCheckBox;
    HidePhysicalPathChkBox: TCheckBox;
    DisplayFileOpenModeChkBox: TCheckBox;
    DisplayDebugInfoChkBox: TCheckBox;
    DisplayDesiredAccessChkBox: TCheckBox;
    AutoStartNoParmsGroupBox: TGroupBox;
    AutoStartWithParmsGroupBox: TGroupBox;
    AutoStartFtpParmsChkBox: TCheckBox;
    AutoStartSftpParmsChkBox: TCheckBox;
    DebugGroupBox: TGroupBox;
    DebugScreenCheckBox: TCheckBox;
    DebugFileCheckBox: TCheckBox;
    InfoGroupBox: TGroupBox;
    InfoScreenCheckBox: TCheckBox;
    InfoFileCheckBox: TCheckBox;
    ErrorGroupBox: TGroupBox;
    ErrorScreenCheckBox: TCheckBox;
    ErrorFileCheckBox: TCheckBox;
    WarningGroupBox: TGroupBox;
    WarningScreenCheckBox: TCheckBox;
    WarningFileCheckBox: TCheckBox;
    MainFormSettingsListBox: TListBox;
    MainFormSettingsToListBoxBtn: TButton;
    MainFormSettingsToFormBtn: TButton;
    DeleteListBoxItemBtn: TButton;
    EnableRealtimeStatusChkBox: TCheckBox;
    UpdateIntervalSpinEdit: TSpinEdit;
    procedure SetDefaultScrrenBtnClick(Sender: TObject);
    procedure SetAlomstFullScreenBtnClick(Sender: TObject);
    procedure SavFrmSizChkBoxClick(Sender: TObject);
    procedure SavFrmPosChkBoxClick(Sender: TObject);
    procedure TScrPosFrameSpinEditTopChange(Sender: TObject);
    procedure TScrPosFrameSpinEditLeftChange(Sender: TObject);
    procedure TScrPosFrameSpinEditHeightChange(Sender: TObject);
    procedure TScrPosFrameSpinEditWidthChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DtaDirCopyToClpBrdBtnClick(Sender: TObject);
    procedure DtaDirOpenInExplorerBtnClick(Sender: TObject);
    procedure TmpDirCopyToClpBrdBtnClick(Sender: TObject);
    procedure TmpDirOpenInExplorerBtnClick(Sender: TObject);
    procedure ExportDsaPublicKeyBtnClick(Sender: TObject);
    procedure ExportEcPublicKeyBtnClick(Sender: TObject);
    procedure ExportRsaPublicKeyBtnClick(Sender: TObject);
    procedure CreateTestItemsBtnClick(Sender: TObject);
    procedure CreateTestItemsINIBtnClick(Sender: TObject);
    procedure StylesListBoxClick(Sender: TObject);
    procedure LogDirCopyToClpBrdBtnClick(Sender: TObject);
    procedure LogDirOpenInExplorerBtnClick(Sender: TObject);
    procedure RootAccessListBoxClick(Sender: TObject);
    procedure UsersRefreshBtnClick(Sender: TObject);
    procedure GatherFilePermissionsChkBoxClick(Sender: TObject);
    procedure LogFileReadChkBoxClick(Sender: TObject);
    procedure LogReadDirFileInfoChkBoxClick(Sender: TObject);
    procedure MainFormSettingsToListBoxBtnClick(Sender: TObject);
    procedure MainFormSettingsToFormBtnClick(Sender: TObject);
    procedure DeleteListBoxItemBtnClick(Sender: TObject);
    procedure UpdateIntervalSpinEditChange(Sender: TObject);
  private
    procedure OpenDirectory(DirectoryName: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.dfm}

uses MFUnit, ClipBrd, ShellApi, Themes, PerlRegex, SFTPUnit;

procedure TSettingsForm.SetDefaultScrrenBtnClick(Sender: TObject);
begin
  MainForm.Top := MainFormDefaultRect.Top;
  MainForm.Left := MainFormDefaultRect.Left;
  MainForm.Height := MainFormDefaultRect.Height;
  MainForm.Width := MainFormDefaultRect.Width;
  MainForm.InfoMemo.Height := 122;
  MainForm.UpdateScrPosEdits;
end;

procedure TSettingsForm.StylesListBoxClick(Sender: TObject);
var
  StyleStr: String;
begin
  StyleStr := StylesListBox.Items[StylesListBox.ItemIndex];
  TStyleManager.TrySetStyle(StyleStr);
end;

procedure TSettingsForm.SetAlomstFullScreenBtnClick(Sender: TObject);
begin
  MainForm.Top := 30;
  MainForm.Left := 30;
  MainForm.Height := Screen.WorkAreaHeight - 60;
  MainForm.Width := Screen.WorkAreaWidth - 60;
  MainForm.UpdateScrPosEdits;
end;

procedure TSettingsForm.TmpDirCopyToClpBrdBtnClick(Sender: TObject);
begin
  TmpDirCopyToClpBrdBtn.Hint := '';
  Clipboard.AsText := MainForm.GetTmpDir;
  TmpDirJvBalloonHint.ActivateHint(TmpDirCopyToClpBrdBtn, '(Copied to clipboard)', MainForm.GetTmpDir, 4000);
end;

procedure TSettingsForm.ExportDsaPublicKeyBtnClick(Sender: TObject);
begin
  MainForm.ExportDsaPublicKey;
end;

procedure TSettingsForm.UpdateIntervalSpinEditChange(Sender: TObject);
begin
  MainForm.UpdateTimer.Interval := UpdateIntervalSpinEdit.Value;
end;

procedure TSettingsForm.UsersRefreshBtnClick(Sender: TObject);
begin
  SFTPForm.ScFileStorage.Users.Refresh;
end;

procedure TSettingsForm.MainFormSettingsToListBoxBtnClick(Sender: TObject);
var
  TmpStr: String;
begin
//  MainFormSettingsListBox.Items.Add('T:1234 | L:1234 | H:1234 | W:1234');
  TmpStr := 'T:' + IntToStr(TScrPosFrame.SpinEditTop.Value) + ' | ' +
            'L:' + IntToStr(TScrPosFrame.SpinEditLeft.Value) + ' | ' +
            'H:' + IntToStr(TScrPosFrame.SpinEditHeight.Value) + ' | ' +
            'W:' + IntToStr(TScrPosFrame.SpinEditWidth.Value);
  if MainFormSettingsListBox.Items.IndexOf(TmpStr) = -1 then
    MainFormSettingsListBox.Items.Add(TmpStr);
end;

procedure TSettingsForm.MainFormSettingsToFormBtnClick(Sender: TObject);
var
	Regex: TPerlRegEx;
begin
  if MainFormSettingsListBox.ItemIndex <> -1 then
  begin
    Regex := TPerlRegEx.Create;
    try
      Regex.RegEx := 'T:(?<Top>[0-9]+) \| L:(?<Left>[0-9]+) \| H:(?<Height>[0-9]+) \| W:(?<Width>[0-9]+)';
      Regex.Options := [];
      Regex.State := [];
      Regex.Subject := AnsiToUTF8(MainFormSettingsListBox.Items[MainFormSettingsListBox.ItemIndex]);
      if Regex.Match then
      begin
        TScrPosFrame.SpinEditTop.Value := StrToInt(Utf8ToAnsi(Regex.Groups[1]));
        TScrPosFrame.SpinEditLeft.Value := StrToInt(Utf8ToAnsi(Regex.Groups[2]));
        TScrPosFrame.SpinEditHeight.Value := StrToInt(Utf8ToAnsi(Regex.Groups[3]));
        TScrPosFrame.SpinEditWidth.Value := StrToInt(Utf8ToAnsi(Regex.Groups[4]));
      end;
    finally
      Regex.Free;
    end;
  end;
end;

procedure TSettingsForm.DeleteListBoxItemBtnClick(Sender: TObject);
begin
  if MainFormSettingsListBox.ItemIndex <> -1 then MainFormSettingsListBox.DeleteSelected;
end;

procedure TSettingsForm.CreateTestItemsBtnClick(Sender: TObject);
begin
  MainForm.CreateTestItems;
  MainForm.InfoMemo.Lines.Append('');
end;

procedure TSettingsForm.LogFileReadChkBoxClick(Sender: TObject);
begin
  LogFileRead := not LogFileRead;
end;

procedure TSettingsForm.LogReadDirFileInfoChkBoxClick(Sender: TObject);
begin
  LogReadDirFileInfo := not LogReadDirFileInfo;
end;

procedure TSettingsForm.LogDirCopyToClpBrdBtnClick(Sender: TObject);
begin
  LogDirCopyToClpBrdBtn.Hint := '';
  Clipboard.AsText := MainForm.GetLogDir;
  LogDirJvBalloonHint.ActivateHint(LogDirCopyToClpBrdBtn, '(Copied to clipboard)', MainForm.GetLogDir, 4000);
end;

procedure TSettingsForm.DtaDirOpenInExplorerBtnClick(Sender: TObject);
begin
  OpenDirectory(MainForm.GetDtaDir);
end;

procedure TSettingsForm.TmpDirOpenInExplorerBtnClick(Sender: TObject);
begin
  OpenDirectory(MainForm.GetTmpDir);
end;

procedure TSettingsForm.LogDirOpenInExplorerBtnClick(Sender: TObject);
begin
  OpenDirectory(MainForm.GetLogDir);
end;

procedure TSettingsForm.CreateTestItemsINIBtnClick(Sender: TObject);
begin
  MainForm.CreateTestItemsINI('MultiPath', 'none', '{TmpDir}TestRoot\', '/,R-----L----|/Incoming,RWAND-LCMVI|/Outgoing,R---D-L----|/1,RW-ND-LCMVI|/2,R-----L---I');
  MainForm.CreateTestItemsINI('n1', 'n1', 'c:\TEMP\~~~~1\', '/,RWAND-LCMVI');
end;

procedure TSettingsForm.ExportRsaPublicKeyBtnClick(Sender: TObject);
begin
  MainForm.ExportRsaPublicKey;
end;

procedure TSettingsForm.ExportEcPublicKeyBtnClick(Sender: TObject);
begin
  MainForm.ExportEcPublicKey;
end;

procedure TSettingsForm.DtaDirCopyToClpBrdBtnClick(Sender: TObject);
begin
  DtaDirCopyToClpBrdBtn.Hint := '';
  Clipboard.AsText := MainForm.GetDtaDir;
  DtaDirJvBalloonHint.ActivateHint(DtaDirCopyToClpBrdBtn, '(Copied to clipboard)', MainForm.GetDtaDir, 4000);
end;

procedure TSettingsForm.FormActivate(Sender: TObject);
begin
  TScrPosFrame.SpinEditTop.Value := MainForm.Top;
  TScrPosFrame.SpinEditLeft.Value := MainForm.Left;
  TScrPosFrame.SpinEditHeight.Value := MainForm.Height;
  TScrPosFrame.SpinEditWidth.Value := MainForm.Width;
end;

procedure TSettingsForm.GatherFilePermissionsChkBoxClick(Sender: TObject);
begin
  if GatherFilePermissionsChkBox.Checked then
  begin
    SFTPForm.ScSFTPServer.OnRequestFileSecurityAttributes := nil;
  end
  else
  begin
    SFTPForm.ScSFTPServer.OnRequestFileSecurityAttributes := SFTPForm.ScSFTPServerRequestFileSecurityAttributes;
  end;
end;

procedure TSettingsForm.OpenDirectory(DirectoryName: String);
begin
  ShellExecute(Application.Handle,
    nil,
    'explorer.exe',
    PChar(DirectoryName), //wherever you want the window to open to
    nil,
    SW_NORMAL     //see other possibilities by ctrl+clicking on SW_NORMAL
    );
end;

procedure TSettingsForm.RootAccessListBoxClick(Sender: TObject);
var
  UserName: String;
begin
  UserName := RootAccessListBox.Items[RootAccessListBox.ItemIndex];
  MainForm.AddRootUser(UserName);
  RootAccessStatusLbl.Caption := 'User ' + UserName + ' created';
end;

procedure TSettingsForm.SavFrmPosChkBoxClick(Sender: TObject);
begin
  SaveFormPosition := SavFrmPosChkBox.Checked;
end;

procedure TSettingsForm.SavFrmSizChkBoxClick(Sender: TObject);
begin
  SaveFormSize := SavFrmSizChkBox.Checked;
end;

procedure TSettingsForm.TScrPosFrameSpinEditHeightChange(Sender: TObject);
begin
  MainForm.Height := TScrPosFrame.SpinEditHeight.Value;
end;

procedure TSettingsForm.TScrPosFrameSpinEditLeftChange(Sender: TObject);
begin
  MainForm.Left := TScrPosFrame.SpinEditLeft.Value;
end;

procedure TSettingsForm.TScrPosFrameSpinEditTopChange(Sender: TObject);
begin
  MainForm.Top := TScrPosFrame.SpinEditTop.Value;
end;

procedure TSettingsForm.TScrPosFrameSpinEditWidthChange(Sender: TObject);
begin
  MainForm.Width := TScrPosFrame.SpinEditWidth.Value;
end;

end.
