unit About;

interface

{
Fade In / Out an About Box or any Modal Delphi Form
http://delphi.about.com/od/formsdialogs/a/fadeinmodalform.htm
~Zarko Gajic
}

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, pngimage, OverbyteIcsWndControl, OverbyteIcsFtpCli,
  JvExStdCtrls, JvButton, JvCtrls, ImgList, JvComponentBase, JvBalloonHint,
  System.ImageList;

type
  TFadeType = (ftIn, ftOut);
  TAboutBox = class(TForm)
    Panel: TPanel;
    ProgramIcon: TImage;
    Version: TLabel;
    fadeTimer: TTimer;
    ProgramLabel: TLabel;
    VersionLbl: TLabel;
    ProgrammerLbl: TLabel;
    EmailLbl: TLabel;
    CompilerLbl: TLabel;
    PgmUpdBtn: TButton;
    OKBtn: TButton;
    FtpClient: TFtpClient;
    PgmUpdDirJvImgBtn: TJvImgBtn;
    ImageList: TImageList;
    JvBalloonHint: TJvBalloonHint;
    TestSetVersionToZeroBtn: TButton;
    procedure fadeTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PgmUpdBtnClick(Sender: TObject);
    procedure PgmUpdDirJvImgBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure JvBalloonHintClose(Sender: TObject);
    procedure TestSetVersionToZeroBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

    fFadeType: TFadeType;
    function CheckForPgmUpdate(HostDirName, HostName, UserName, PassWord,
      PgmVersionStr, RegexStr: String): String;
    procedure DownloadPgmUpdate;
    procedure PgmUpdBtnClick2(Sender: TObject);
    procedure OpenDirectory(DirectoryName: String);
    procedure WriteIniFile(IniFileName: String);
    procedure LoadSectionUpdate;
    property FadeType: TFadeType read fFadeType write fFadeType;
  public
    class function Execute(): TModalResult;
  end;

var
  AboutBox: TAboutBox;
  LclInstalled: Boolean;
  LclPgmUpdDir, LclTmpDir, LclVerStr, LclExeDir, LclDtaDir: String;
  CFPUHostName, CFPUUserName, CFPUPassWord, CFPUAppName: String;
{   *** Add in main form
    LclExeDir := ExeDir;
    LclTmpDir := TmpDir;
    LclDtaDir := DtaDir;
    LclVerStr := VersionLbl.Caption;
    LclPgmUpdDir := PgmUpdDir;
}

implementation

uses UtlUnit, PerlRegEx, ShellApi, ClipBrd, IniFiles, MFUnit, Dialogs, System.UITypes;

var
  UpdaterProgramFileName, UpdateStr: String;

{$R *.dfm}
{========================================================================}
function FileNameToVersionStr(FileNameStr: String): String;
var
  Regex: TPerlRegEx;
  Words: TStringList;
begin
  Regex := TPerlRegEx.Create;
  Regex.RegEx := '([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2})';
  Regex.Options := [];
  Regex.Subject := AnsiToUTF8(FileNameStr);
  if Regex.Match then
  begin
    Words := TStringList.Create;
    Parse(Utf8ToAnsi(Regex.MatchedText), '.', Words);
    Result := LPad(Words[0], 3, '0') + LPad(Words[1], 3, '0') + LPad(Words[2], 3, '0') + LPad(Words[3], 3, '0');
    Words.Free;
  end;
  Regex.Free;
end;
{========================================================================}
class function TAboutBox.Execute: TModalResult;
begin
  with TAboutBox.Create(nil) do
  begin
    try
//      PgmUpdBtn.Enabled := lclInstalled;
      Result := ShowModal;
    finally
      Release;
    end;
  end;
end;
{========================================================================}
procedure TAboutBox.fadeTimerTimer(Sender: TObject);
const
  FADE_IN_SPEED = 5;
  FADE_OUT_SPEED = 20;
var
  newBlendValue: Integer;
begin
  case FadeType of
    ftIn:
      begin
        if AlphaBlendValue < 255 then
          AlphaBlendValue := FADE_IN_SPEED + AlphaBlendValue
        else
          fadeTimer.Enabled := False;
      end;
    ftOut:
      begin
        if AlphaBlendValue > 0 then
        begin
          newBlendValue := -1 * FADE_OUT_SPEED + AlphaBlendValue;
          if newBlendValue >  0 then
            AlphaBlendValue := newBlendValue
          else
            AlphaBlendValue := 0;
        end
        else
        begin
          fadeTimer.Enabled := False;
          Close;
        end;
      end;
  end;
end;
{========================================================================}
procedure TAboutBox.LoadSectionUpdate;
var
  RegIniFile: TIniFile;
{
[Section-Update]
FtpHostName=ftp.domain.com
FtpUserName=DelphiTools
FtpPassWord=TDT
AppName=PFS
}
begin
  if FileExists(LclDtaDir + 'Section-Update.INI') then
  begin
    RegIniFile := TIniFile.Create(LclDtaDir + 'Section-Update.INI');
    try
      CFPUHostName := RegIniFile.ReadString('Section-Update', 'FtpHostName', '');
      CFPUUserName := RegIniFile.ReadString('Section-Update', 'FtpUserName', '');
      CFPUPassWord := RegIniFile.ReadString('Section-Update', 'FtpPassWord', '');
      CFPUAppName := RegIniFile.ReadString('Section-Update', 'AppName', '');
    finally
      RegIniFile.Free;
    end;
    PgmUpdBtn.Enabled := True;
  end
  else
  begin
    PgmUpdBtn.Enabled := False;
  end;
end;
{========================================================================}
procedure TAboutBox.FormCreate(Sender: TObject);
begin
  AlphaBlend := True;
  AlphaBlendValue := 0;
  fFadeType := ftIn;
  fadeTimer.Enabled := True;
  VersionLbl.Caption := GetVersionInfoStr(ParamStr(0));
  CompilerLbl.Caption := 'Application compiled with: ' + GetCompilerName(CompilerVersion);
  UpdaterProgramFileName := LclExeDir + 'PgmUpdater.exe';
  LoadSectionUpdate;
end;
{========================================================================}
procedure TAboutBox.JvBalloonHintClose(Sender: TObject);
begin
  PgmUpdDirJvImgBtn.Hint := 'Program update directory, LC-Open, RC-Copy to clipboard';
end;
{========================================================================}
procedure TAboutBox.PgmUpdBtnClick2(Sender: TObject);
begin
  DownloadPgmUpdate;
end;
{========================================================================}
procedure TAboutBox.OpenDirectory(DirectoryName: String);
begin
  ShellExecute(Application.Handle,
    nil,
    'explorer.exe',
    PChar(DirectoryName), //wherever you want the window to open to
    nil,
    SW_NORMAL     //see other possibilities by ctrl+clicking on SW_NORMAL
    );
end;
{========================================================================}
procedure TAboutBox.PgmUpdDirJvImgBtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssShift in Shift then
  begin
    case Button of
      mbRight:
      begin
        // Shift-Right-Click
      end;
    end;
  end
  else
  begin
    case Button of
      mbLeft:
      begin
        // Left-Click
        OpenDirectory(LclPgmUpdDir);
      end;
      mbRight:
      begin
        // Right-Click
        PgmUpdDirJvImgBtn.Hint := '';
        Clipboard.AsText := LclPgmUpdDir;
        JvBalloonHint.ActivateHint(PgmUpdDirJvImgBtn, '(Copied to clipboard)', LclPgmUpdDir, 4000);
      end;
    end;
  end;
end;
{========================================================================}
procedure TAboutBox.PgmUpdBtnClick(Sender: TObject);
var
  HostDirName, PgmVersionStr, RegexStr: String;
begin
  PgmUpdBtn.Enabled := False;
  OKBtn.Enabled := False;
  PgmUpdDirJvImgBtn.Enabled := False;
  PgmUpdBtn.Caption := 'Checking...';
  PgmVersionStr := FileNameToVersionStr(LclVerStr);
  HostDirName := 'APPS/' + CFPUAppName;
  RegexStr := 'Setup-' + CFPUAppName + '-v([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}).exe\b';
  UpdateStr := CheckForPgmUpdate(HostDirName, CFPUHostName, CFPUUserName, CFPUPassWord, PgmVersionStr, RegexStr);
  if Length(UpdateStr) > 0 then
  begin
    PgmUpdBtn.Caption := 'Install';
    PgmUpdBtn.OnClick := PgmUpdBtnClick2;
    PgmUpdBtn.Hint := 'Install updated version: ' + UpdateStr;
    WriteIniFile(LclPgmUpdDir + 'PgmUpdater.ini');
  end
  else
  begin
    PgmUpdBtn.Caption := 'No update!';
  end;
  PgmUpdBtn.Enabled := True;
  OKBtn.Enabled := True;
  PgmUpdDirJvImgBtn.Enabled := True;
end;
{========================================================================}
procedure TAboutBox.FormActivate(Sender: TObject);
var
  B1L, B1W, B2L, B2W, B3L, B3W, B4L, {B4W,} S1, S2, S3, ST: Integer;
begin
  // Equally space buttons
  B1L := TestSetVersionToZeroBtn.Left;
  B1W := TestSetVersionToZeroBtn.Width;
  B2L := PgmUpdDirJvImgBtn.Left;
  B2W := PgmUpdDirJvImgBtn.Width;
  B3L := PgmUpdBtn.Left;
  B3W := PgmUpdBtn.Width;
  B4L := OKBtn.Left;
//  B4W := OKBtn.Width; // Not useed
  S1 := B2L - (B1L + B1W);
  S2 := B3L - (B2L + B2W);
  S3 := B4L - (B3L + B3W);
  ST := S1 + S2 + S3;
  B2L := B1L + B1W + (ST div 3);
  B3L := B2L + B2W + (ST div 3);
  PgmUpdDirJvImgBtn.Left := B2L;
  PgmUpdBtn.Left := B3L;
end;
{========================================================================}
procedure TAboutBox.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //cancel hint before closing form
  JvBalloonHint.CancelHint;
  //no close before we fade away
  if FadeType = ftIn then
  begin
    fFadeType := ftOut;
    AlphaBlendValue := 255;
    fadeTimer.Enabled := True;
    CanClose := False;
  end
  else
  begin
    CanClose := True;
  end;
end;
{========================================================================}
procedure TAboutBox.TestSetVersionToZeroBtnClick(Sender: TObject);
begin
  LclVerStr := CFPUAppName+'-v0.0.0.0';
  VersionLbl.Caption := '0.0.0.0';
end;
{========================================================================}
function TAboutBox.CheckForPgmUpdate(HostDirName, HostName, UserName, PassWord, PgmVersionStr, RegexStr: String): String;
var
  UpdateVersionStr: String;
  FileList: TStringList;
  i: Integer;
  Regex: TPerlRegEx;
  FtpVersionStr: String;
begin
  Result := '';
  Regex := TPerlRegEx.Create;
  UpdateVersionStr := '';
  FTPClient.HostName := HostName;
  FTPClient.UserName := UserName;
  FTPClient.PassWord := PassWord;
  FtpClient.HostDirName := HostDirName;
  FtpClient.HostFileName := '';
  FtpClient.LocalFileName := LclTmpDir + 'FTPFileList.TXT';
  if FtpClient.Directory then // Connect, Cwd, Download a directory listing to a file & Quit
  begin
    FileList := TStringList.Create;
    FileList.LoadFromFile(LclTmpDir + 'FTPFileList.TXT');
    for i := 0 to FileList.Count - 1 do
    begin
      Regex.RegEx := AnsiToUTF8(RegexStr);
      Regex.Options := [];
      Regex.Subject := AnsiToUTF8(FileList[i]);
      if Regex.Match then
      begin
        FtpVersionStr := FileNameToVersionStr(Utf8ToAnsi(Regex.MatchedText));
        if FtpVersionStr > PgmVersionStr then
        begin
          if FtpVersionStr > UpdateVersionStr then
          begin
            UpdateVersionStr := FtpVersionStr;
            Result := Utf8ToAnsi(Regex.MatchedText);
          end;
        end;
      end;
    end;
    FileList.Free;
  end;
  Regex.Free;
end;
{========================================================================}
procedure TAboutBox.WriteIniFile(IniFileName: String);
var
  RegIniFile: TIniFile;
begin
  RegIniFile := TIniFile.Create(IniFileName);
  try
    RegIniFile.WriteString('SectionFormClose', 'AboutCap', Caption);
    RegIniFile.WriteString('SectionFormClose', 'MainCap', MainForm.Caption);
    RegIniFile.WriteString('SectionPgmUpdater', 'PgmUpdDir', lclPgmUpdDir);
    RegIniFile.WriteString('SectionPgmUpdater', 'Installer', UpdateStr);
  finally
    RegIniFile.Free;
  end;
end;
{========================================================================}
procedure TAboutBox.DownloadPgmUpdate;
var
  HostDirName: String;
begin
  PgmUpdBtn.Caption := 'Working...';
  HostDirName := 'APPS/' + CFPUAppName;
  FTPClient.HostName := CFPUHostName;
  FTPClient.UserName := CFPUUserName;
  FTPClient.PassWord := CFPUPassWord;
  FTPClient.HostDirName := HostDirName;
  FTPClient.LocalFileName := LclPgmUpdDir + UpdateStr;
  FTPClient.HostFileName := UpdateStr;
  if FTPClient.Receive then
  // Connect, Cwd, Download a file & Quit
  begin
//    if SysUtils.FileExists(LclPgmUpdDir + UpdaterProgramFileName) then
    if SysUtils.FileExists(UpdaterProgramFileName) then
    begin
      Sleep(1000);
      ShellExecute(Application.Handle, nil, PWideChar(UpdaterProgramFileName), PWideChar(LclPgmUpdDir + 'PgmUpdater.ini'), nil, SW_MINIMIZE);
      //SW_NORMAL  //see other possibilities by ctrl+clicking on SW_NORMAL
    end
    else
    begin
      PgmUpdBtn.Caption := 'Error!';
      MessageDlg('PgmUpdater.exe not found!', mtError, [mbOk], 0);
    end;
  end
  else
  begin
    PgmUpdBtn.Caption := 'Error!';
  end;
end;
{========================================================================}
end.

