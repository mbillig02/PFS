unit MFUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScBridge, ScSFTPServer, ScSSHServer, StdCtrls, ScUtils, WinSock,
  JvComponentBase, JvBalloonHint, Buttons, SyncObjs, Grids, ScSSHSocket, ScSSHUtils,
  ExtCtrls, JvBaseDlg, JvSelectDirectory, ScSFTPUtils, OverbyteIcsWndControl,
  OverbyteIcsWSocket, Menus, OverbyteIcsFtpSrv, ScSFTPConsts;

type
  TTopLeftHeightWidth = record
    Top: Integer;
    Left: Integer;
    Height: Integer;
    Width: Integer;
  end;
  TStringGrid = class(Grids.TStringGrid)
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
  end;
  TMainForm = class(TForm)
    InfoMemo: TMemo;
    JvSelectDirectory: TJvSelectDirectory;
    LogMemo: TMemo;
    MainMenu: TMainMenu;
    mmiftp: TMenuItem;
    mmiSettings: TMenuItem;
    mmisftp: TMenuItem;
    mmiStyles: TMenuItem;
    mmiUserEditor: TMenuItem;
    mmiVersionAbout: TMenuItem;
    PathEdit: TEdit;
    SaveDialog: TSaveDialog;
    Splitter1: TSplitter;
    StringGrid: TStringGrid;
    UpdateTimer: TTimer;
    function CheckUserPathPermissions(const DirPermStr, SpecificPermission, Path: String): Boolean;
    function ConvertBytes(Bytes: Int64): String;
    function GetDtaDir: String;
    function GetLogDir: String;
    function GetTmpDir: String;
    function OkayToUpdate(Source: String): Boolean;
    procedure AddRootUser(UserName: String);
    procedure AddUser(Source, Username, Directory, Transfer, Bytes, Update: String);
    procedure ClearFile(Source: String);
    procedure CreateTestItems;
    procedure CreateTestItemsINI(UserName, Password, HomeDir, DirPerm: String);
    procedure DelUser(Source: String);
    procedure DelUserIni(Username: String);
    procedure DisplayDesiredAccess(DesiredAccess: TScSFTPDesiredAccess);
    procedure DisplayFileOpenMode(FileOpenMode: TScSFTPFileOpenMode);
    procedure ExportDsaPublicKey;
    procedure ExportEcPublicKey;
    procedure ExportRsaPublicKey;
    procedure FlagUpdated(Source: String);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MainMenuChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    procedure mmiftpClick(Sender: TObject);
    procedure mmiSettingsClick(Sender: TObject);
    procedure mmisftpClick(Sender: TObject);
    procedure mmiUserEditorClick(Sender: TObject);
    procedure mmiVersionAboutClick(Sender: TObject);
    procedure PathEditChange(Sender: TObject);
    procedure PathEditDblClick(Sender: TObject);
    procedure UpdateBytes(Source, Bytes: String);
    procedure UpdateDirectory(Source, Directory: String);
    procedure UpdateScrPosEdits;
    procedure UpdateTimerTimer(Sender: TObject);
    procedure UpdateTransfer(Source, Transfer: String);
    procedure UpdateUserIni(UserName, Password, HomeDir, DirPerm: String);
    procedure WriteLog(const Event: String; Obj: TObject; LogType: Char);
  private
    FLockEvent: TCriticalSection;
    function GetDefaultIPAddr: String;
    procedure AddStylesToListBox;
    procedure AutoSizeColumns;
    procedure Display(Msg: String);
//    procedure DisplayFileOpenFlags(FileOpenFlags: TScSFTPFileOpenFlags);
    procedure ExportPublicKey;
    procedure LoadAutoStartSettings;
    procedure LoadSettingsFromFormActivate;
    procedure LoadSettingsFromFormCreate;
    procedure OnMoving(var Msg: TWMMoving); message WM_MOVING;
    procedure RightMenu;
    procedure SaveSettings;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  MainFormDefaultRect: TTopLeftHeightWidth;
  SaveFormSize, SaveFormPosition, LogReadDirFileInfo, LogFileRead: Boolean;

implementation

uses
  JclSysInfo, ClipBrd, ShellAPI, UtlUnit, ScVioTcp, IPHelper, IPUnit, About,
  IniFiles, UEUnit, PerlRegEx, Themes, SetUnit, Math, System.UITypes, FTPUnit,
  SFTPUnit;

const
  ServerKeyNameRSA = 'SBSSHServer_RSA';
  ServerKeyNameDSA = 'SBSSHServer_DSA';
  ServerKeyNameEC = 'SBSSHServer_EC';

var
  FInitialized, DebugToFile, ErrorToFile, InfoToFile, WarningToFile, LogFileOpen: Boolean;
  ExeDir, DtaDir, TmpDir, PgmUpdDir, LogDir, StyleStr: String;
  LogFile: TStreamWriter;
  FS: TFileStream;

{$R *.dfm}
{$I SecureBridgeVer.inc}

function FindMenuItemByHint(AMainMenu: TMainMenu; const Hint: String): TMenuItem;

  function FindItemInner(Item: TMenuItem; const Hint: String): TMenuItem;
  var
    i: Integer;
  begin
    Result := Nil;
    if Item.Hint = Hint then
    begin
      Result := Item;
      exit;
    end
    else
    begin
      for i := 0 to Item.Count - 1 do
      begin
        Result := FindItemInner(Item.Items[i], Hint);
        if Result <> Nil then Break;
      end;
    end;
  end;

begin
  Result := FindItemInner(AMainMenu.Items, Hint);
end;

function GetDriveList(const DriveTypeStr: String): String;
var
  DriveNum: Integer;
  DriveBits: set of 0..25;
  DriveChar: Char;
  TmpStr: String;
  OkToAdd: Boolean;
  EMode: Cardinal;
begin
  Result := '';
  Integer(DriveBits) := GetLogicalDrives;
  for DriveNum := 0 to 25 do
  begin
    if (DriveNum in DriveBits) then
    begin
      DriveChar := Char(DriveNum + Ord('A'));

      EMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        GetDir(DriveNum + 1, TmpStr);
      finally
        SetErrorMode(EMode);
      end;

      OkToAdd := False;
      case TDriveType(GetDriveType(PChar(DriveChar + ':\'))) of
        dtFloppy: if Pos('R', DriveTypeStr) > 0 then OkToAdd := True;
        dtFixed: if Pos('F', DriveTypeStr) > 0 then OkToAdd := True;
        dtNetwork: if Pos('N', DriveTypeStr) > 0 then OkToAdd := True;
        dtCDROM: if Pos('C', DriveTypeStr) > 0 then OkToAdd := True;
      end;

      if OkToAdd then
      begin
        if Copy(TmpStr, 1, 1) = DriveChar then
          Result := Result + '+' + DriveChar
        else
          Result := Result + '-' + DriveChar;
      end;
    end;
  end;
end;

// https://stackoverflow.com/questions/4618743/how-to-make-messagedlg-centered-on-owner-form
function MessageDlgCenter(const Msg: String; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
var
  R: TRect;
begin
  if not Assigned(Screen.ActiveForm) then
  begin
    Result := MessageDlg(Msg, DlgType, Buttons, 0);
  end
  else
  begin
    with CreateMessageDialog(Msg, DlgType, Buttons) do
    try
      GetWindowRect(Screen.ActiveForm.Handle, R);
      Left := R.Left + ((R.Right - R.Left) div 2) - (Width div 2);
      Top := R.Top + ((R.Bottom - R.Top) div 2) - (Height div 2);
      if mbCancel in Buttons then ActiveControl := TWinControl(FindComponent('Cancel'));
      if mbNo in Buttons then ActiveControl := TWinControl(FindComponent('No'));
      Result := ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure AutoSizeColumn(StrGrd: TStringGrid; ColNum: Integer);
var
  i, TempWidth, LargestWidth: Integer;
begin
  LargestWidth := 0;
  for i := 0 to StrGrd.RowCount - 1 do
  begin
    TempWidth := StrGrd.Canvas.TextWidth(StrGrd.Cells[ColNum, i]);
    if TempWidth > LargestWidth then LargestWidth := TempWidth;
  end;
  StrGrd.ColWidths[ColNum] := LargestWidth + 10;
end;

procedure TStringGrid.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  TmpStr: String;
  LDelta: Integer;
begin
  TmpStr := Cells[ACol, ARow];
  LDelta := (ColWidths[ACol] div 2) - (Canvas.TextWidth(TmpStr) div 2);
  Canvas.TextRect(ARect, ARect.Left + LDelta, ARect.Top + 2, TmpStr);
end;

function TMainForm.ConvertBytes(Bytes: Int64): String;
const
  Description: Array [0 .. 8] of String = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
var
  i: Integer;
begin
  i := 0;
  while Bytes > Power(1024, i + 1) do Inc(i);
  Result := FormatFloat('###0.##', Bytes / IntPower(1024, i)) + ' ' + Description[i];
end;

function TMainForm.GetDtaDir: String;
begin
  Result := DtaDir;
end;

function TMainForm.GetLogDir: String;
begin
  Result := LogDir;
end;

function TMainForm.GetTmpDir: String;
begin
  Result := TmpDir;
end;

procedure TMainForm.UpdateUserIni(UserName, Password, HomeDir, DirPerm: String);
var
  RegIniFile: TIniFile;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'FtpAccounts.INI');
  try
    RegIniFile.WriteString(UserName, 'Password', Password);
    RegIniFile.WriteString(UserName, 'HomeDir', HomeDir);
    RegIniFile.WriteString(UserName, 'DirPerm', DirPerm);
  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.DelUserIni(Username: String);
var
  RegIniFile: TIniFile;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'FtpAccounts.INI');
  try
    RegIniFile.EraseSection(Username);
  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.CreateTestItemsINI(UserName, Password, HomeDir, DirPerm: String);
var
  RegIniFile: TIniFile;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'TestItems.INI');
  try
    RegIniFile.WriteString(UserName, 'Password', Password);
    RegIniFile.WriteString(UserName, 'HomeDir', HomeDir);
    RegIniFile.WriteString(UserName, 'DirPerm', DirPerm);
  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.mmiftpClick(Sender: TObject);
begin
  if mmiftp.Checked then
  begin
    FTPForm.StartFtpServer;
  end
  else
  begin
    FTPForm.StopFtpServer;
  end;
end;

procedure TMainForm.mmiSettingsClick(Sender: TObject);
begin
  SettingsForm.SavFrmSizChkBox.Checked := SaveFormSize;
  SettingsForm.SavFrmPosChkBox.Checked := SaveFormPosition;
  if MainForm.Left + MainForm.Width + SettingsForm.Width < Screen.WorkAreaWidth then
  begin
    SettingsForm.Position := poDesigned;
    SettingsForm.Top := MainForm.Top;
    SettingsForm.Left := MainForm.Left + MainForm.Width;
  end
  else
  begin
    if MainForm.Top + MainForm.Height + SettingsForm.Height < Screen.WorkAreaHeight then
    begin
      SettingsForm.Position := poDesigned;
      SettingsForm.Top := MainForm.Top + MainForm.Height;
      SettingsForm.Left := MainForm.Left;
    end
    else
    begin
      SettingsForm.Position := poMainFormCenter;
    end;
  end;
  SettingsForm.Show;
end;

procedure TMainForm.mmisftpClick(Sender: TObject);
begin
  if mmisftp.Checked then
  begin
    SFTPForm.StartSftpServer;
  end
  else
  begin
    SFTPForm.StopSftpServer;
  end;
end;

procedure TMainForm.mmiUserEditorClick(Sender: TObject);
begin
  UserEditorDlg.ScFileStorage.Path := DtaDir;
  UserEditorDlg.ScFileStorage.Users.Refresh;
  if MainForm.Left + MainForm.Width + UserEditorDlg.Width < Screen.WorkAreaWidth then
  begin
    UserEditorDlg.Position := poDesigned;
    UserEditorDlg.Top := MainForm.Top;
    UserEditorDlg.Left := MainForm.Left + MainForm.Width;
  end
  else
  begin
    if MainForm.Top + MainForm.Height + UserEditorDlg.Height < Screen.WorkAreaHeight then
    begin
      UserEditorDlg.Position := poDesigned;
      UserEditorDlg.Top := MainForm.Top + MainForm.Height;
      UserEditorDlg.Left := MainForm.Left;
    end
    else
    begin
      UserEditorDlg.Position := poMainFormCenter;
    end;
  end;
  UserEditorDlg.Show;
  SFTPForm.ScFileStorage.Users.Refresh;
end;

procedure TMainForm.mmiVersionAboutClick(Sender: TObject);
begin
  TAboutBox.Execute;
end;

procedure TMainForm.PathEditChange(Sender: TObject);
const
  clGoodPath = 11534255;
  clBadPath = 11513855;
var
  RegEx: TPerlRegEx;
  PathFmtMatch: Boolean;
begin
  PathFmtMatch := False;
  Regex := TPerlRegEx.Create;
	Regex.Options := [preCaseless, preExtended];
  Regex.Subject := AnsiToUTF8((Sender as TEdit).Text);

  Regex.RegEx := '(?>\b[a-z]:|\\\\[a-z0-9 %._~-]{1,63}\\[a-z0-9 $%._~-]{1,80})\\(?>[^\\/:*?"<>|\x00-\x1F]{0,254}[^.\\/:*?"<>|\x00-\x1F]\\)*';
  if Regex.Match and (Regex.MatchedLength = Length(Regex.Subject)) then PathFmtMatch := True;

  if PathFmtMatch then
  begin
    if DirectoryExists((Sender as TEdit).Text) then
    begin
      (Sender as TEdit).Color := clGoodPath;
      SFTPForm.ScSFTPServer.DefaultRootPath := PathEdit.Text;
    end
    else
    begin
      (Sender as TEdit).Color := clBadPath;
    end;
  end
  else
  begin
    (Sender as TEdit).Color := clBadPath;
  end;
  RegEx.Free;
end;

procedure TMainForm.PathEditDblClick(Sender: TObject);
begin
// https://stackoverflow.com/questions/7422689/selecting-a-directory-with-topendialog
  if Win32MajorVersion >= 6 then
  begin
    with TFileOpenDialog.Create(nil) do
      try
        Title := 'Select Directory';
        Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
        OkButtonLabel := 'Select';
        DefaultFolder := PathEdit.Text;
        FileName := PathEdit.Text;
        if Execute then PathEdit.Text := IncludeTrailingPathDelimiter(FileName);
      finally
        Free;
      end
  end
  else
  begin
    JvSelectDirectory.InitialDir := PathEdit.Text;
    if JvSelectDirectory.Execute then
    begin
      PathEdit.Text := IncludeTrailingPathDelimiter(JvSelectDirectory.Directory);
    end;
  end;
end;

procedure TMainForm.ExportPublicKey;
var
  Key: TScKey;
  KeyFormat: TScKeyFormat;
begin
  Key := SFTPForm.ScFileStorage.Keys.KeyByName(ServerKeyNameRSA);
  Key.Ready := True;
  KeyFormat := kfDefault;
  Key.ExportTo(DtaDir + GetHostName + '_PFS_RSA.pub', True, '', saTripleDES_cbc, KeyFormat);
end;

// https://stackoverflow.com/questions/11594084/shift-in-the-right-of-last-item-of-the-menu
Procedure TMainForm.RightMenu; // Shift in the right of last item of the menu
var
  mii: TMenuItemInfo;
  MainMenu: hMenu;
  Buffer: array[0..79] of Char;
begin
  MainMenu := Self.Menu.Handle;
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_TYPE;
  mii.dwTypeData := Buffer;
  mii.cch := SizeOf(Buffer);
  GetMenuItemInfo(MainMenu, mmiVersionAbout.Command, False, mii);
  mii.fType := mii.fType or MFT_RIGHTJUSTIFY;
  if SetMenuItemInfo(MainMenu, mmiVersionAbout.Command, False, mii) then DrawMenuBar(Self.Menu.WindowHandle);
end;

procedure TMainForm.AddStylesToListBox;
var
  StyleStr: String;
begin
  // Add Styles menu items to the ListBox
  SettingsForm.StylesListBox.Clear;
  for StyleStr in TStyleManager.StyleNames do SettingsForm.StylesListBox.Items.Append(StyleStr);
  SettingsForm.StylesListBox.Sorted := True;
end;

procedure TMainForm.AddRootUser(UserName: String);
var
  UserList: TStringList;
  User: TScUser;
  DriveChar: Char;
begin
  UserList := TStringList.Create;
  SFTPForm.ScFileStorage.Users.GetUserNames(UserList);
  if UserList.IndexOf(UserName) = -1 then
  begin
    User := TScUser.Create(SFTPForm.ScFileStorage.Users);
  end
  else
  begin
    User := SFTPForm.ScFileStorage.Users.UserByName(UserName);
  end;
  User.UserName := UserName;
  User.Authentications := [uaPassword];
  DriveChar := UserName[1];
  User.Password := DriveChar + '$PW';
  User.HomePath := DriveChar + ':\';
  User.ExtData := '/,R-----L---I';
  UpdateUserIni(User.UserName, User.Password, User.HomePath, 'R-----L---I');
  UserList.Free;
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
  User: TScUser;
  UserList: TStringList;
  DriveNum: Integer;
  DriveChar: Char;
  VerStr, DriveListStr, UserName: String;
begin
  if not FInitialized then
  begin
    FInitialized := True;
    LoadSettingsFromFormActivate;

    AddStylesToListBox;
    if TStyleManager.ActiveStyle.Name <> StyleStr then TStyleManager.TrySetStyle(StyleStr);
    SettingsForm.StylesListBox.ItemIndex := SettingsForm.StylesListBox.Items.IndexOf(StyleStr);

    VerStr := 'PFS-v' + GetVersionInfoStr(ParamStr(0));
    MainMenu.Items.Find('About').Caption := VerStr;
    RightMenu;
    SFTPForm.ScSSHServer.Options.ServerVersion := SFTPForm.ScSSHServer.Options.ServerVersion + ' ' + VerStr;

    ExeDir := ExtractFilePath(Application.ExeName);
    TmpDir := GetTempDir + 'PFS\TMP\'; ForceDirectories(TmpDir);
    SettingsForm.DtaDirLbl.Caption := DtaDir;
    SettingsForm.LogDirLbl.Caption := LogDir;
    SettingsForm.TmpDirLbl.Caption := TmpDir;

    LclExeDir := ExeDir;
    LclTmpDir := TmpDir;
    LclVerStr := VerStr;
    LclDtaDir := DtaDir;
    PgmUpdDir := TmpDir + 'PgmUpdates\'; ForceDirectories(PgmUpdDir);
    LclPgmUpdDir := PgmUpdDir;

    MainForm.Caption := 'Portable FTP Server - ' + GetDefaultIPAddr;

    StringGrid.ColCount := 6;
    StringGrid.ColWidths[0] := 89;
    StringGrid.ColWidths[1] := 104;
    StringGrid.ColWidths[2] := 100;
    StringGrid.ColWidths[3] := 72;
    StringGrid.ColWidths[4] := 100;
    StringGrid.ColWidths[5] := 5;
    StringGrid.Cells[0,0] := 'Source';
    StringGrid.Cells[1,0] := 'Username';
    StringGrid.Cells[2,0] := 'Directory';
    StringGrid.Cells[3,0] := 'File';
    StringGrid.Cells[4,0] := 'Bytes';
    StringGrid.Cells[5,0] := '.';

    FLockEvent := TCriticalSection.Create;
    SFTPForm.ScFileStorage.Path := DtaDir;
    SFTPForm.ScSSHServer.KeyNameRSA := ServerKeyNameRSA;
    SFTPForm.ScSSHServer.KeyNameDSA := ServerKeyNameDSA;
    SFTPForm.ScSSHServer.KeyNameEC := ServerKeyNameEC;
    SFTPForm.InitKeys;
    SFTPForm.ScSSHServer.HostKeyAlgorithms := [aaRSA, aaDSA, aaEC];
    ExportPublicKey;
    SFTPForm.ShowKeyFingerprints;
    UserList := TStringList.Create;
    SFTPForm.ScFileStorage.Users.GetUserNames(UserList);
    if UserList.IndexOf('DefaultUser') = -1 then
    begin
      User := TScUser.Create(SFTPForm.ScFileStorage.Users);
    end
    else
    begin
      User := SFTPForm.ScFileStorage.Users.UserByName('DefaultUser');
    end;
    User.UserName := 'DefaultUser';
    User.Authentications := [uaPassword];
    User.Password := 'P@ssw0rd';
    User.HomePath := '';
    User.ExtData := '/,RWAND-LCMVI';
    UpdateUserIni('DefaultUser', 'P@ssw0rd', '', 'RW-ND-LCMVI');

    SettingsForm.IPInfoMemo.Lines.AddStrings(LocalIPList);

    LoadAutoStartSettings;
    if SettingsForm.AutoCreateTestItemsChkBox.Checked then CreateTestItems;

    // Remove old RootAccess users
    DriveListStr := GetDriveList('RFNC');
    for DriveNum := 0 to 25 do
    begin
      DriveChar := Char(DriveNum + Ord('A'));
      // Delete User
      UserName := DriveChar + '$USER';
      if UserList.IndexOf(UserName) <> -1 then
      begin
        User := SFTPForm.ScFileStorage.Users.UserByName(UserName);
        try
          SFTPForm.ScFileStorage.Users.Remove(User);
        finally
          User.Free;
          DelUserIni(Username);
        end;
      end;
    end;
    UserList.Free;

    // Create RootAccess listbox items
    SettingsForm.RootAccessListBox.Clear;
    DriveListStr := GetDriveList('RFNC');
    for DriveNum := 0 to 25 do
    begin
      DriveChar := Char(DriveNum + Ord('A'));
      if Pos('+' + DriveChar, DriveListStr) > 0 then
      begin
        SettingsForm.RootAccessListBox.Items.Append(DriveChar + '$USER');
      end;
    end;

    PathEditChange(PathEdit);
    WriteLog('Starting ' + VerStr, PathEdit, 'I');

    if ParamCount > 0 then
    begin
      PathEdit.Text := IncludeTrailingPathDelimiter(ParamStr(1));
      if SettingsForm.AutoStartFtpParmsChkBox.Checked then FTPForm.StartFtpServer;
      if SettingsForm.AutoStartSftpParmsChkBox.Checked then SFTPForm.StartSftpServer;
      if SettingsForm.AutoStartFtpParmsChkBox.Checked or SettingsForm.AutoStartSftpParmsChkBox.Checked then InfoMemo.Lines.Append('');
    end
    else
    begin
      PathEdit.Text := 'C:\Temp\';
      if SettingsForm.AutoStartFtpChkBox.Checked then FTPForm.StartFtpServer;
      if SettingsForm.AutoStartSftpChkBox.Checked then SFTPForm.StartSftpServer;
      if SettingsForm.AutoStartFtpChkBox.Checked or SettingsForm.AutoStartSftpChkBox.Checked then InfoMemo.Lines.Append('');
    end;
    SFTPForm.ScSFTPServer.DefaultRootPath := PathEdit.Text;

  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FtpForm.FtpServer.Active then WriteLog('Stopping Ftp Server', PathEdit, 'I');
  FtpForm.FtpServer.Active := False;
  if SFTPForm.ScSSHServer.Active then WriteLog('Stopping sFtp Server', PathEdit, 'I');
  SFTPForm.ScSSHServer.Active := False;
  WriteLog('Exiting PFS', PathEdit, 'I');
  MainForm.OnResize := nil;
  FreeAndNil(FLockEvent);
  SaveSettings;
  LogFile.Free();
  FS.Free;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  MsgTxt: String;
begin
  if Changes then
  begin
    MsgTxt := 'You have not saved.' + #13 + #10 + 'Save or Cancel edits!';
    MessageDlgCenter(MsgTxt, mtWarning, [mbOk]);
    CanClose := False;
  end;
end;

function FindMenuItemByCaption(AMainMenu: TMainMenu; const Caption: String): TMenuItem;

  function FindItemInner(Item: TMenuItem; const Caption: String): TMenuItem;
  var
    i: Integer;
  begin
    Result := Nil;
    if Item.Caption = Caption then
    begin
      Result := Item;
      exit;
    end
    else
    begin
      for i := 0 to Item.Count - 1 do
      begin
        Result := FindItemInner(Item.Items[i], Caption);
        if Result <> Nil then
          Break;
      end;
    end;
  end;

begin
  Result := FindItemInner(AMainMenu.Items, Caption);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  LogFileName: String;
begin
//  ReportMemoryLeaksOnShutdown := (DebugHook <> 0);
//  ReportMemoryLeaksOnShutdown := True;
  DtaDir := GetCommonDocumentsFolder + '\MWB\PFS\'; ForceDirectories(DtaDir); //DeployMaster - %COMMONDOCUMENTS%
  LoadSettingsFromFormCreate;
  LogFileOpen := False;
  if DebugToFile or ErrorToFile or InfoToFile or WarningToFile then
  begin
    LogFileName := LogDir + FormatDateTime('yyyy-mm-dd', Date) + '.log';
    if FileExists(LogFileName) then
    begin
      FS := TFileStream.Create(LogFileName, fmOpenWrite or fmShareDenyWrite);
      FS.Seek(FS.Size, soFromBeginning);
    end
    else
    begin
      FS := TFileStream.Create(LogFileName, fmCreate or fmShareDenyWrite);
    end;
    LogFile := TStreamWriter.Create(FS, TEncoding.UTF8);
    LogFileOpen := True;
  end;
end;

function PathToPerm(PathToFind: String; ListToSearch: TStringList): String;
var
  i: Integer;
  Words: TStringList;
begin
  Result := '';
  Words := TStringList.Create;
  for i := 0 to ListToSearch.Count - 1 do
  begin
    Parse(ListToSearch[i], ',', Words);
    if PathToFind = Words[0] then
    begin
      Result := Words[1];
      Break;
    end;
  end;
  Words.Free;
end;

function TMainForm.CheckUserPathPermissions(const DirPermStr, SpecificPermission, Path: String): Boolean;
var
  DirPermList, Words: TStringList;
  PathToCheck, PermStr: String;
begin
  WriteLog(Path, PathEdit, 'D');
  WriteLog(DirPermStr, PathEdit, 'D');
  Result := False;
  DirPermList := TStringList.Create;
  Parse(DirPermStr, '|', DirPermList);
  Words := TStringList.Create;
  Parse(DirPermList[0], ',', Words);
  if Pos('I', Words[1]) > 0 then
  begin
    if Pos(SpecificPermission, Words[1]) > 0 then
      Result := True;
  end
  else
  begin
    PathToCheck := Path;
    repeat
      PermStr := PathToPerm(PathToCheck, DirPermList);
      if Length(PermStr) > 0 then
      begin
        if Pos(SpecificPermission, PermStr) > 0 then Result := True;
        Break;
      end;
      // delete rightmost directory
      SetLength(PathToCheck,LastDelimiter('/', PathToCheck)-1);
    until PathToCheck = '/';
  end;
  Words.Free;
  DirPermList.Free;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  InfoMemo.Height := (InfoMemo.Height + StringGrid.Height) div 2;
  SettingsForm.TScrPosFrame.SpinEditHeight.Value := MainForm.Height;
  SettingsForm.TScrPosFrame.SpinEditWidth.Value := MainForm.Width;
end;

procedure TMainForm.ClearFile(Source: String);
var
  i: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then
      begin
        StringGrid.Cells[3, i] := '';
        StringGrid.Cells[4, i] := '';
      end;
  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.DisplayDesiredAccess(DesiredAccess: TScSFTPDesiredAccess);
begin
  if amReadData in DesiredAccess then InfoMemo.Lines.Append('amReadData');
  if amListDirectory in DesiredAccess then InfoMemo.Lines.Append('amListDirectory');
  if amWriteData in DesiredAccess then InfoMemo.Lines.Append('amWriteData');
  if amAddFile in DesiredAccess then InfoMemo.Lines.Append('amAddFile');
  if amAppendData in DesiredAccess then InfoMemo.Lines.Append('amAppendData');
  if amAddSubdirectory in DesiredAccess then InfoMemo.Lines.Append('amAddSubdirectory');
  if amReadNamedAttrs in DesiredAccess then InfoMemo.Lines.Append('amReadNamedAttrs');
  if amWriteNamedAttrs in DesiredAccess then InfoMemo.Lines.Append('amWriteNamedAttrs');
  if amExecute in DesiredAccess then InfoMemo.Lines.Append('amExecute');
  if amDeleteChild in DesiredAccess then InfoMemo.Lines.Append('amDeleteChild');
  if amReadAttributes in DesiredAccess then InfoMemo.Lines.Append('amReadAttributes');
  if amWriteAttributes in DesiredAccess then InfoMemo.Lines.Append('amWriteAttributes');
  if amDelete in DesiredAccess then InfoMemo.Lines.Append('amDelete');
  if amReadAcl in DesiredAccess then InfoMemo.Lines.Append('amReadAcl');
  if amWriteAcl in DesiredAccess then InfoMemo.Lines.Append('amWriteAcl');
  if amWriteOwner in DesiredAccess then InfoMemo.Lines.Append('amWriteOwner');
  if amSynchronize in DesiredAccess then InfoMemo.Lines.Append('amSynchronize');
end;

procedure TMainForm.DisplayFileOpenMode(FileOpenMode: TScSFTPFileOpenMode);
begin
  if fmCreateNew in [FileOpenMode] then InfoMemo.Lines.Append('fmCreateNew');
  if fmCreateOrTruncate in [FileOpenMode] then InfoMemo.Lines.Append('fmCreateOrTruncate');
  if fmOpenExisting in [FileOpenMode] then InfoMemo.Lines.Append('fmOpenExisting');
  if fmOpenOrCreate in [FileOpenMode] then InfoMemo.Lines.Append('fmOpenOrCreate');
  if fmTruncateExisting in [FileOpenMode] then InfoMemo.Lines.Append('fmTruncateExisting');
end;

{
procedure TMainForm.DisplayFileOpenFlags(FileOpenFlags: TScSFTPFileOpenFlags);
begin
  if ofAppendData in FileOpenFlags then InfoMemo.Lines.Append('ofAppendData');
  if ofAppendDataAtomic in FileOpenFlags then InfoMemo.Lines.Append('ofAppendDataAtomic');
  if ofTextMode in FileOpenFlags then InfoMemo.Lines.Append('ofTextMode');
  if ofNoFollow in FileOpenFlags then InfoMemo.Lines.Append('ofNoFollow');
  if ofDeleteOnClose in FileOpenFlags then InfoMemo.Lines.Append('ofDeleteOnClose');
  if ofAccessAudit in FileOpenFlags then InfoMemo.Lines.Append('ofAccessAudit');
  if ofAccessBackup in FileOpenFlags then InfoMemo.Lines.Append('ofAccessBackup');
  if ofBackupStream in FileOpenFlags then InfoMemo.Lines.Append('ofBackupStream');
  if ofOverrideOwner in FileOpenFlags then InfoMemo.Lines.Append('ofOverrideOwner');
end;
}

function TMainForm.OkayToUpdate(Source: String): Boolean;
var
  i, SourceFound: Integer;
begin
  Result := False;
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    if StringGrid.Cells[5, SourceFound] = '' then Result := True;
  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.AutoSizeColumns;
var
  i: Integer;
begin
  for i := 0 to StringGrid.ColCount - 1 do
  begin
    if i <> 4 then AutoSizeColumn(StringGrid, i);
  end;
end;

procedure TMainForm.FlagUpdated(Source: String);
var
  i, SourceFound: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    StringGrid.Cells[5, SourceFound] := '.';
    AutoSizeColumns;
  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.Display(Msg: String);
begin
  if InfoMemo.Lines.Count > 200 then InfoMemo.Lines.Delete(0);
  if Length(Trim(InfoMemo.Lines.Strings[0])) = 0 then InfoMemo.Lines.Delete(0);
  InfoMemo.Lines.Append(Msg);
end;

function TMainForm.GetDefaultIPAddr: String;
var
  IPFwrdTbl, Words: TStringList;
  i, Remote: Integer;
  IPAddrSubNetStrC, IPAddressStrC, SubNetMaskStrC, SubNetBitsStrC: String;
  IPAddrSubNetStrP, IPAddressStrP, SubNetMaskStrP, SubNetBitsStrP: String;
begin
  IPFwrdTbl := TStringList.Create;
  Get_IPForwardTable(IPFwrdTbl);
  Remote := 0;
  for i := 0 to IPFwrdTbl.Count - 1 do if Pos('remote', IPFwrdTbl[i]) > 0 then Remote := i;
  Words := TStringList.Create;
  Parse(IPFwrdTbl[Remote], '|', Words);
  IPAddrSubNetStrC := Trim(Words[2]) + ' 255.255.255.255';
  SplitIpAddressSubnet(IPAddrSubNetStrC, IPAddressStrC, SubNetMaskStrC);
  SubNetBitsStrC := IntToStr(MaskToBits(SubNetMaskStrC));
  for i := 0 to IPFwrdTbl.Count - 1 do
  begin
    if i <> Remote then
    begin
      Parse(IPFwrdTbl[i], '|', Words);
      IPAddrSubNetStrP := Trim(Words[0]) + ' ' + Trim(Words[1]);
      SplitIpAddressSubnet(IPAddrSubNetStrP, IPAddressStrP, SubNetMaskStrP);
      SubNetBitsStrP := IntToStr(MaskToBits(SubNetMaskStrP));
      if IsParentIP(IPAddressStrC + '/' + SubNetBitsStrC, IPAddressStrP + '/' + SubNetBitsStrP) then Break;
    end;
  end;
  IPFwrdTbl.Free;
  Result := Trim(Words[2]);
  Words.Free;
end;

procedure TMainForm.WriteLog(const Event: String; Obj: TObject; LogType: Char);
var
  UserName, DestHost, DestPort, TmpStr, Category: String;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    if Obj is TEdit then
    begin
      TmpStr := Event;
    end
    else
    if Obj is TFtpCtrlSocket then
    begin
      TmpStr := TFtpCtrlSocket(Obj).GetPeerAddr + ':' + TFtpCtrlSocket(Obj).GetPeerPort + ',' + TFtpCtrlSocket(Obj).UserName + ',' + Event;
    end
    else
    if Obj is TScSSHClientInfo then
    begin
      UserName := TScSSHClientInfo(Obj).User;
      DestHost := '';
      DestPort := '';
      TmpStr := SFTPForm.TCPConnectionToStr(TScSSHClientInfo(Obj).TCPConnection) + ',' + UserName + ',' + Event;
    end
    else
    if Obj is TScSSHChannelInfo then
    begin
      UserName := TScSSHChannelInfo(Obj).Client.User;
      DestHost := TScSSHChannelInfo(Obj).DestHost;
      DestPort := IntToStr(TScSSHChannelInfo(Obj).DestPort);
      TmpStr := SFTPForm.TCPConnectionToStr(TScSSHChannelInfo(Obj).Client.TCPConnection) + ',' + UserName + ',' + Event;
    end
    else
    begin
      Assert(False);
    end;
    case LogType of
      'D': Category := ' [DEBUG   ] ';
      'E': Category := ' [ERROR   ] ';
      'I': Category := ' [INFO    ] ';
      'W': Category := ' [WARNING ] ';
    else
      Category := ' [        ] ';
    end;

    if ((LogType = 'D') and (SettingsForm.DebugScreenCheckBox.Checked)) or
       ((LogType = 'E') and (SettingsForm.ErrorScreenCheckBox.Checked)) or
       ((LogType = 'I') and (SettingsForm.InfoScreenCheckBox.Checked)) or
       ((LogType = 'W') and (SettingsForm.WarningScreenCheckBox.Checked)) then
         Display(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + Category + TmpStr);

    if ((LogType = 'D') and (SettingsForm.DebugFileCheckBox.Checked)) or
       ((LogType = 'E') and (SettingsForm.ErrorFileCheckBox.Checked)) or
       ((LogType = 'I') and (SettingsForm.InfoFileCheckBox.Checked)) or
       ((LogType = 'W') and (SettingsForm.WarningFileCheckBox.Checked)) then
       if LogFileOpen then
         LogFile.WriteLine(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + Category + TmpStr);

  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.AddUser(Source, Username, Directory, Transfer, Bytes, Update: String);
var
  i, SourceFound: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    if SourceFound = -1 then
    begin
      for i := 0 to StringGrid.RowCount - 1 do
        if Length(Trim(StringGrid.Cells[0, i])) = 0 then SourceFound := i;
      if SourceFound = -1 then
      begin
        SourceFound := StringGrid.RowCount;
        StringGrid.RowCount := StringGrid.RowCount + 1;
      end;
    end;
    StringGrid.Cells[0, SourceFound] := Source;
    StringGrid.Cells[1, SourceFound] := Username;
    StringGrid.Cells[2, SourceFound] := Directory;
    StringGrid.Cells[3, SourceFound] := Transfer;
    StringGrid.Cells[4, SourceFound] := Bytes;
    StringGrid.Cells[5, SourceFound] := Update;
    if StringGrid.Cells[0, SourceFound] = '' then StringGrid.Cells[0, SourceFound] := '--- No Source ---';
    if StringGrid.Cells[1, SourceFound] = '' then StringGrid.Cells[1, SourceFound] := '--- No Username ---';
    if StringGrid.Cells[2, SourceFound] = '' then StringGrid.Cells[2, SourceFound] := '--- No Directory ---';
    if StringGrid.Cells[3, SourceFound] = '' then StringGrid.Cells[3, SourceFound] := '--- No File ---';
    if StringGrid.Cells[4, SourceFound] = '' then StringGrid.Cells[4, SourceFound] := '--- No Bytes ---';
    if StringGrid.Cells[5, SourceFound] = '' then StringGrid.Cells[5, SourceFound] := '--- No Update ---';
    AutoSizeColumns;
  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.DelUser(Source: String);
var
  i, j, SourceFound: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    if SourceFound <> -1 then
    begin
      for i := 0 to StringGrid.ColCount - 1 do StringGrid.Cells[i, SourceFound] := '';
    end;
    // Delete top rows that are blank
    i := StringGrid.RowCount - 1;
    while StringGrid.Cells[0, i] = '' do
    begin
      StringGrid.RowCount := StringGrid.RowCount - 1;
      i := StringGrid.RowCount - 1;
    end;
    // Move higher entries in to blank rows
    for i := 0 to StringGrid.RowCount - 1 do
    begin
      if (StringGrid.Cells[0, i] = '') and (i < (StringGrid.RowCount - 1)) then
      begin
        for j := 0 to StringGrid.ColCount - 1 do
        begin
          StringGrid.Cells[j, i] := StringGrid.Cells[0, j + 1];
          StringGrid.Cells[0, j + 1] := '';
        end;
      end;
    end;
    // Delete top rows that are blank
    i := StringGrid.RowCount - 1;
    while StringGrid.Cells[0, i] = '' do
    begin
      StringGrid.RowCount := StringGrid.RowCount - 1;
      i := StringGrid.RowCount - 1;
    end;

  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.UpdateScrPosEdits;
begin
  SettingsForm.TScrPosFrame.SpinEditTop.Value := MainForm.Top;
  SettingsForm.TScrPosFrame.SpinEditLeft.Value := MainForm.Left;
end;

procedure TMainForm.OnMoving(var Msg: TWMMoving);
begin
  inherited;
  UpdateScrPosEdits;
end;

procedure TMainForm.LoadSettingsFromFormActivate;
var
  RegIniFile: TIniFile;
  i, ItemCount: Integer;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'PFS.INI');
  try
    if SaveFormSize then
    begin
//      MainForm.Height := MainFormDefaultRect.Height;
//      MainForm.Width := MainFormDefaultRect.Width;
      MainForm.Height := RegIniFile.ReadInteger('Section-Window', 'KeyHeight', MainFormDefaultRect.Height);
      MainForm.Width := RegIniFile.ReadInteger('Section-Window', 'KeyWidth', MainFormDefaultRect.Width);
    end;
    if SaveFormPosition then
    begin
//      MainForm.Top := MainFormDefaultRect.Top;
//      MainForm.Left := MainFormDefaultRect.Left;
      MainForm.Top := RegIniFile.ReadInteger('Section-Window', 'KeyTop', MainFormDefaultRect.Top);
      MainForm.Left := RegIniFile.ReadInteger('Section-Window', 'KeyLeft', MainFormDefaultRect.Left);
    end;

    SettingsForm.EnableRealtimeStatusChkBox.Checked := RegIniFile.ReadBool('Section-Options', 'EnableRealtimeStatus', False);
    SettingsForm.UpdateIntervalSpinEdit.Value := RegIniFile.ReadInteger('Section-Options', 'UpdateInterval', 1000);
    UpdateTimer.Interval := SettingsForm.UpdateIntervalSpinEdit.Value;

    RegIniFile.ReadSection('MainFormSettingsListBox', SettingsForm.MainFormSettingsListBox.Items);
    ItemCount := SettingsForm.MainFormSettingsListBox.Items.Count;
    SettingsForm.MainFormSettingsListBox.Clear;
    for i := 0 to ItemCount - 1 do
      SettingsForm.MainFormSettingsListBox.Items.Append(RegIniFile.ReadString('MainFormSettingsListBox', IntToStr(i), ''));

    StyleStr := RegIniFile.ReadString('Section-Options', 'Style', 'Windows');
    SettingsForm.GatherFilePermissionsChkBox.Checked := RegIniFile.ReadBool('Section-Options', 'GatherFilePermissions', True);

    SettingsForm.DebugScreenCheckBox.Checked := RegIniFile.ReadBool('Section-Log', 'DebugToScreen', False);
    SettingsForm.DebugFileCheckBox.Checked := DebugToFile;
    SettingsForm.ErrorScreenCheckBox.Checked := RegIniFile.ReadBool('Section-Log', 'ErrorToScreen', True);
    SettingsForm.ErrorFileCheckBox.Checked := ErrorToFile;
    SettingsForm.InfoScreenCheckBox.Checked := RegIniFile.ReadBool('Section-Log', 'InfoToScreen', True);
    SettingsForm.InfoFileCheckBox.Checked := InfoToFile;
    SettingsForm.WarningScreenCheckBox.Checked := RegIniFile.ReadBool('Section-Log', 'WarningToScreen', True);
    SettingsForm.WarningFileCheckBox.Checked := WarningToFile;

  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.CreateTestItems;
var
  User: TScUser;
  UserList, SrcUserList, DirPermList, Words: TStringList;
  RegIniFile: TIniFile;
  UserName, Password, HomeDir, TestRoot, DirPermStr, TmpStr: String;
  i, j: Integer;
begin
  if FileExists(DtaDir + 'TestItems.INI') then
  begin
    SrcUserList := TStringList.Create;
    UserList := TStringList.Create;
    DirPermList := TStringList.Create;
    RegIniFile := TIniFile.Create(DtaDir + 'TestItems.INI');
    try
      RegIniFile.ReadSections(SrcUserList);
      for i := 0 to SrcUserList.Count-1 do
      begin
        UserName := SrcUserList[i];
        Password := RegIniFile.ReadString(UserName, 'Password', '');
        HomeDir := RegIniFile.ReadString(UserName, 'HomeDir', '');
        DirPermStr := RegIniFile.ReadString(UserName, 'DirPerm', '');

        // Create test user
        SFTPForm.ScFileStorage.Users.Refresh;
        SFTPForm.ScFileStorage.Users.GetUserNames(UserList);
        if UserList.IndexOf(UserName) = -1 then
        begin
          User := TScUser.Create(SFTPForm.ScFileStorage.Users);
        end
        else
        begin
          User := SFTPForm.ScFileStorage.Users.UserByName(UserName);
        end;
        WriteLog('---------- Create User ----------', PathEdit, 'D');
        WriteLog('UserName: ' + UserName, PathEdit, 'D');
        WriteLog('Home Directory: ' + HomeDir, PathEdit, 'D');
        WriteLog('Directory Permissions: ' + DirPermStr, PathEdit, 'D');
        User.UserName := UserName;
        User.Authentications := [uaPassword];
        User.Password := Password;
        TestRoot := StringReplace(HomeDir, '{TmpDir}', TmpDir, [rfIgnoreCase]);
        User.HomePath := TestRoot;
        User.ExtData := DirPermStr;

        ForceDirectories(TestRoot);
        WriteLog('Create Directory: ' + TestRoot, PathEdit, 'D');
        Parse(DirPermStr, '|', DirPermList);
        for j := 0 to DirPermList.Count - 1 do
        begin
          Words := TStringList.Create;
          Parse(DirPermList[j], ',', Words);
          TmpStr := Words[0];
          if TmpStr <> '/' then
          begin
            TmpStr := StringReplace(TmpStr, '/', '\', [rfReplaceAll]);
            ForceDirectories(StringReplace(TestRoot + TmpStr, '\\', '\', [rfReplaceAll]));
            WriteLog('Create Directory: ' + StringReplace(TestRoot + TmpStr, '\\', '\', [rfReplaceAll]), PathEdit, 'D');
          end;
          Words.Free;
        end;

      end;
    finally
      RegIniFile.Free;
    end;
    DirPermList.Free;
    UserList.Free;
    SrcUserList.Free;
  end;
end;

procedure TMainForm.LoadSettingsFromFormCreate;
var
  RegIniFile: TIniFile;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'PFS.INI');
  try
    SaveFormSize := RegIniFile.ReadBool('Section-Window', 'SaveFormSize', False);
    SaveFormPosition := RegIniFile.ReadBool('Section-Window', 'SaveFormPosition', False);

    MainFormDefaultRect.Top := RegIniFile.ReadInteger('Section-MainForm', 'DefaultTop', 75);
    MainFormDefaultRect.Left := RegIniFile.ReadInteger('Section-MainForm', 'DefaultLeft', 75);
    MainFormDefaultRect.Height := RegIniFile.ReadInteger('Section-MainForm', 'DefaultHeight', 348);
    MainFormDefaultRect.Width := RegIniFile.ReadInteger('Section-MainForm', 'DefaultWidth', 570);

    LogDir := RegIniFile.ReadString('Section-Log', 'LogDir', DtaDir + 'Logs\');
    ForceDirectories(LogDir);
    DebugToFile := RegIniFile.ReadBool('Section-Log', 'DebugToFile', False);
    ErrorToFile := RegIniFile.ReadBool('Section-Log', 'ErrorToFile', True);
    InfoToFile := RegIniFile.ReadBool('Section-Log', 'InfoToFile', True);
    WarningToFile := RegIniFile.ReadBool('Section-Log', 'WarningToFile', True);
  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.LoadAutoStartSettings;
var
  RegIniFile: TIniFile;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'PFS.INI');
  try
    SettingsForm.AutoStartFtpChkBox.Checked := RegIniFile.ReadBool('Section-AutoStart', 'AutoStartFTP', False);
    SettingsForm.AutoStartSftpChkBox.Checked := RegIniFile.ReadBool('Section-AutoStart', 'AutoStartSFTP', False);

    SettingsForm.AutoStartFtpParmsChkBox.Checked := RegIniFile.ReadBool('Section-AutoStart', 'AutoStartFTPParms', False);
    SettingsForm.AutoStartSftpParmsChkBox.Checked := RegIniFile.ReadBool('Section-AutoStart', 'AutoStartSFTPParms', True);

    SettingsForm.AutoCreateTestItemsChkBox.Checked := RegIniFile.ReadBool('Section-Autostart', 'AutoCreateTestItems', False);

    SettingsForm.DisplayFileOpenModeChkBox.Checked := RegIniFile.ReadBool('Section-DebugDisplay', 'DisplayFileOpenMode', False);
    SettingsForm.DisplayDebugInfoChkBox.Checked := RegIniFile.ReadBool('Section-DebugDisplay', 'DisplayDebugInfo', False);
    SettingsForm.DisplayDesiredAccessChkBox.Checked := RegIniFile.ReadBool('Section-DebugDisplay', 'DisplayDesiredAccess', False);
  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.ExportDsaPublicKey;
var
  Key: TScKey;
begin
  Key := SFTPForm.ScFileStorage.Keys.KeyByName(ServerKeyNameDSA);
  Key.ExportTo(TmpDir + Key.KeyName + '.pub', True, '');
end;

procedure TMainForm.ExportEcPublicKey;
var
  Key: TScKey;
begin
  Key := SFTPForm.ScFileStorage.Keys.KeyByName(ServerKeyNameEC);
  Key.ExportTo(TmpDir + Key.KeyName + '.pub', True, '');
end;

procedure TMainForm.ExportRsaPublicKey;
var
  Key: TScKey;
begin
  Key := SFTPForm.ScFileStorage.Keys.KeyByName(ServerKeyNameRSA);
  Key.ExportTo(TmpDir + Key.KeyName + '.pub', True, '');
end;

procedure TMainForm.MainMenuChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
begin
  RightMenu;
end;

procedure TMainForm.SaveSettings;
var
  RegIniFile: TIniFile;
  i: Integer;
begin
  RegIniFile := TIniFile.Create(DtaDir + 'PFS.INI');
  try

    if not (Self.WindowState = wsMaximized) then
    begin
      RegIniFile.WriteInteger('Section-Window', 'KeyTop', MainForm.Top);
      RegIniFile.WriteInteger('Section-Window', 'KeyLeft', MainForm.Left);
      RegIniFile.WriteInteger('Section-Window', 'KeyHeight', MainForm.Height);
      RegIniFile.WriteInteger('Section-Window', 'KeyWidth', MainForm.Width);
    end;

    RegIniFile.WriteBool('Section-Window', 'SaveFormSize', SaveFormSize);
    RegIniFile.WriteBool('Section-Window', 'SaveFormPosition', SaveFormPosition);

    RegIniFile.WriteInteger('Section-MainForm', 'DefaultTop', MainFormDefaultRect.Top);
    RegIniFile.WriteInteger('Section-MainForm', 'DefaultLeft', MainFormDefaultRect.Left);
    RegIniFile.WriteInteger('Section-MainForm', 'DefaultHeight', MainFormDefaultRect.Height);
    RegIniFile.WriteInteger('Section-MainForm', 'DefaultWidth', MainFormDefaultRect.Width);

    RegIniFile.WriteBool('Section-Options', 'EnableRealtimeStatus', SettingsForm.EnableRealtimeStatusChkBox.Checked);
    RegIniFile.WriteInteger('Section-Options', 'UpdateInterval', SettingsForm.UpdateIntervalSpinEdit.Value);

    RegIniFile.EraseSection('MainFormSettingsListBox');
    for i := 0 to SettingsForm.MainFormSettingsListBox.Items.Count - 1 do
      RegIniFile.WriteString('MainFormSettingsListBox', IntToStr(i), SettingsForm.MainFormSettingsListBox.Items[i]);

    RegIniFile.WriteBool('Section-AutoStart', 'AutoCreateTestItems', SettingsForm.AutoCreateTestItemsChkBox.Checked);
    RegIniFile.WriteBool('Section-AutoStart', 'AutoStartFTP', SettingsForm.AutoStartFtpChkBox.Checked);
    RegIniFile.WriteBool('Section-AutoStart', 'AutoStartSFTP', SettingsForm.AutoStartSftpChkBox.Checked);

    RegIniFile.WriteBool('Section-AutoStart', 'AutoStartFTPParms', SettingsForm.AutoStartFtpParmsChkBox.Checked);
    RegIniFile.WriteBool('Section-AutoStart', 'AutoStartSFTPParms', SettingsForm.AutoStartSftpParmsChkBox.Checked);

    RegIniFile.WriteBool('Section-DebugDisplay', 'DisplayFileOpenMode', SettingsForm.DisplayFileOpenModeChkBox.Checked);
    RegIniFile.WriteBool('Section-DebugDisplay', 'DisplayDesiredAccess', SettingsForm.DisplayDesiredAccessChkBox.Checked);
    RegIniFile.WriteBool('Section-DebugDisplay', 'DisplayDebugInfo', SettingsForm.DisplayDebugInfoChkBox.Checked);

    RegIniFile.WriteBool('Section-Options', 'GatherFilePermissions', SettingsForm.GatherFilePermissionsChkBox.Checked);

    RegIniFile.WriteString('Section-Options', 'Style', SettingsForm.StylesListBox.Items[SettingsForm.StylesListBox.ItemIndex]);

    RegIniFile.WriteString('Section-Log', 'LogDir', LogDir);
    RegIniFile.WriteBool('Section-Log', 'DebugToScreen', SettingsForm.DebugScreenCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'DebugToFile', SettingsForm.DebugFileCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'ErrorToScreen', SettingsForm.ErrorScreenCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'ErrorToFile', SettingsForm.ErrorFileCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'InfoToScreen', SettingsForm.InfoScreenCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'InfoToFile', SettingsForm.InfoFileCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'WarningToScreen', SettingsForm.WarningScreenCheckBox.Checked);
    RegIniFile.WriteBool('Section-Log', 'WarningToFile', SettingsForm.WarningFileCheckBox.Checked);
  finally
    RegIniFile.Free;
  end;
end;

procedure TMainForm.UpdateDirectory(Source, Directory: String);
var
  i, SourceFound: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    StringGrid.Cells[2, SourceFound] := Directory;
    AutoSizeColumns;
  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.UpdateTimerTimer(Sender: TObject);
var
  i: Integer;
begin
  for i := 1 to StringGrid.RowCount - 1 do StringGrid.Cells[5, i] := '';
end;

procedure TMainForm.UpdateTransfer(Source, Transfer: String);
var
  i, SourceFound: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    StringGrid.Cells[3, SourceFound] := Transfer;
    AutoSizeColumns;
  finally
    FLockEvent.Release;
  end;
end;

procedure TMainForm.UpdateBytes(Source, Bytes: String);
var
  i, SourceFound: Integer;
begin
  if FLockEvent = nil then Exit;
  FLockEvent.Acquire;
  try
    SourceFound := -1;
    for i := 0 to StringGrid.RowCount - 1 do
      if StringGrid.Cells[0, i] = Source then SourceFound := i;
    StringGrid.Cells[4, SourceFound] := Bytes;
    StringGrid.ColWidths[4] := 100;
    AutoSizeColumns;
  finally
    FLockEvent.Release;
  end;
end;

end.
