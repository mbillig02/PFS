unit FTPUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OverbyteIcsWndControl, OverbyteIcsFtpSrv,
  OverbyteIcsWSocket;

type
  TFTPForm = class(TForm)
    FtpServer: TFtpServer;
    WSocket: TWSocket;
    procedure FtpServerAlterDirectory(Sender: TObject; Client: TFtpCtrlSocket; var Directory: TFtpString; Detailed: Boolean);
    procedure FtpServerAuthenticate(Sender: TObject; Client: TFtpCtrlSocket; UserName, Password: TFtpString; var Authenticated: Boolean);
    procedure FtpServerChangeDirectory(Sender: TObject; Client: TFtpCtrlSocket; Directory: TFtpString; var Allowed: Boolean);
    procedure FtpServerClientCommand(Sender: TObject; Client: TFtpCtrlSocket; var Keyword, Params, Answer: TFtpString);
    procedure FtpServerClientConnect(Sender: TObject; Client: TFtpCtrlSocket; AError: Word);
    procedure FtpServerClientDisconnect(Sender: TObject; Client: TFtpCtrlSocket; AError: Word);
    procedure FtpServerClntStr(Sender: TObject; Client: TFtpCtrlSocket; var Params, Answer: TFtpString);
    procedure FtpServerMakeDirectory(Sender: TObject; Client: TFtpCtrlSocket; Directory: TFtpString; var Allowed: Boolean);
    procedure FtpServerRetrSessionClosed(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
    procedure FtpServerRetrSessionConnected(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
    procedure FtpServerStorSessionClosed(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
    procedure FtpServerStorSessionConnected(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
    procedure FtpServerValidateDele(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
    procedure FtpServerValidateGet(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
    procedure FtpServerValidatePut(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
    procedure FtpServerValidateRmd(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
    procedure FtpServerValidateRnFr(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
    procedure StartFtpServer;
    procedure StopFtpServer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FTPForm: TFTPForm;

implementation

uses
  IniFiles, SetUnit, MFUnit;

{$R *.dfm}

procedure TFTPForm.FtpServerAlterDirectory(Sender: TObject; Client: TFtpCtrlSocket; var Directory: TFtpString; Detailed: Boolean);
var
  DirStr: String;
begin
  MainForm.WriteLog('Open directory: ' + Client.DirListPath, Client, 'I');
  DirStr := Copy(Client.DirListPath, 1, Length(Client. DirListPath) - 3);
//  WriteLog('CurCmdType: ' + IntToStr(Client.CurCmdType) + ' (MLSD): ' + Client.DirListPath, Client, 'D');
//  UpdateDirectory(Client.GetPeerAddr+':'+Client.GetPeerPort, DirStr);
end;

procedure TFTPForm.FtpServerAuthenticate(Sender: TObject; Client: TFtpCtrlSocket; UserName, Password: TFtpString; var Authenticated: Boolean);
var
  RegIniFile: TIniFile;
  HomeDir: String;
begin
  Authenticated := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if RegIniFile.ReadString(UserName, 'Password', 'DefaultPassword') = Password then
    begin
      Authenticated := True;
      HomeDir := RegIniFile.ReadString(UserName, 'HomeDir', '');
      if Length(Trim(HomeDir)) = 0 then HomeDir := MainForm.PathEdit.Text;
      Client.HomeDir := HomeDir;
      Client.Directory := Client.HomeDir;
      Client.SessIdInfo := Client.GetPeerAddr + '=' + UserName;
      if SettingsForm.HidePhysicalPathChkBox.Checked then Client.Options := Client.Options + [ftpHidePhysicalPath];
      MainForm.AddUser(Client.GetPeerAddr + ':' + Client.GetPeerPort, UserName, '', '', '', '');
    end;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.FtpServerChangeDirectory(Sender: TObject; Client: TFtpCtrlSocket; Directory: TFtpString; var Allowed: Boolean);
begin
  MainForm.UpdateDirectory(Client.GetPeerAddr + ':' + Client.GetPeerPort, Directory);
  // Client.DirListPath does not have the path in it yet
//  WriteLog('CurCmdType: ' + IntToStr(Client.CurCmdType) + ' (CWD): ' + Client.DirListPath, Client, 'I');
end;

procedure TFTPForm.FtpServerClientCommand(Sender: TObject; Client: TFtpCtrlSocket; var Keyword, Params, Answer: TFtpString);
begin
  MainForm.WriteLog(Keyword + ' ' + Params, Client, 'D');
end;

procedure TFTPForm.FtpServerClientConnect(Sender: TObject; Client: TFtpCtrlSocket; AError: Word);
begin
  MainForm.WriteLog('Ftp Session Connect', Client, 'I');
end;

procedure TFTPForm.FtpServerClientDisconnect(Sender: TObject; Client: TFtpCtrlSocket; AError: Word);
begin
  MainForm.DelUser(Client.GetPeerAddr+':'+Client.GetPeerPort);
  MainForm.WriteLog('Ftp Session Disconnect', Client, 'I');
end;

procedure TFTPForm.FtpServerClntStr(Sender: TObject; Client: TFtpCtrlSocket; var Params, Answer: TFtpString);
begin
  MainForm.WriteLog('Client Info: ' + Params, Client, 'I');
end;

procedure TFTPForm.FtpServerMakeDirectory(Sender: TObject; Client: TFtpCtrlSocket; Directory: TFtpString; var Allowed: Boolean);
var
  RegIniFile: TIniFile;
begin
  // Directory Create Permission
  Allowed := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if Pos('C', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then
    begin
      Allowed := True;
      MainForm.WriteLog('MKD -> ' + Directory, Client, 'D');
      MainForm.WriteLog('Make directory: ' + Directory, Client, 'I');
    end;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.FtpServerRetrSessionClosed(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
begin
  if Client.CurCmdType = ftpcRETR then
  begin
    MainForm.ClearFile(Client.GetPeerAddr + ':' + Client.GetPeerPort);
    MainForm.WriteLog('RetrSessionClosed -> ' + Client.FilePath, Client, 'D');
    MainForm.WriteLog('Download complete: ' + Client.FilePath, Client, 'I');
  end;
end;

procedure TFTPForm.FtpServerRetrSessionConnected(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
begin // Download
  if Client.CurCmdType = ftpcRETR then
  begin
    MainForm.UpdateTransfer(Client.GetPeerAddr + ':' + Client.GetPeerPort, 'D ' + Client.FileName);
    MainForm.WriteLog('RetrSessionConnected -> ' + Client.FilePath, Client, 'D');
    MainForm.WriteLog('Download started: ' + Client.FilePath, Client, 'I');
  end;
end;

procedure TFTPForm.FtpServerStorSessionClosed(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
begin
  if Client.CurCmdType = ftpcSTOR then
  begin
    MainForm.ClearFile(Client.GetPeerAddr + ':' + Client.GetPeerPort);
    MainForm.WriteLog('StorSessionClosed -> ' + Client.FilePath, Client, 'D');
    MainForm.WriteLog('Upload complete: ' + Client.FilePath, Client, 'I');
  end;
end;

procedure TFTPForm.FtpServerStorSessionConnected(Sender: TObject; Client: TFtpCtrlSocket; Data: TWSocket; AError: Word);
begin // Upload
  if Client.CurCmdType = ftpcSTOR then
  begin
    MainForm.UpdateTransfer(Client.GetPeerAddr + ':' + Client.GetPeerPort, 'U ' + Client.FileName);
    MainForm.WriteLog('StorSessionConnected -> ' + Client.FilePath, Client, 'D');
    MainForm.WriteLog('Upload started: ' + Client.FilePath, Client, 'I');
  end;
end;

procedure TFTPForm.FtpServerValidateDele(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
var
  RegIniFile: TIniFile;
begin
  // Delete File Permission
  Allowed := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if Pos('D', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then Allowed := True;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.FtpServerValidateGet(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
var
  RegIniFile: TIniFile;
begin
  // Download File Permission
  Allowed := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if Pos('R', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then Allowed := True;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.FtpServerValidatePut(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
var
  RegIniFile: TIniFile;
begin
  // Upload File Permission
  Allowed := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if Pos('W', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then Allowed := True;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.FtpServerValidateRmd(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
var
  RegIniFile: TIniFile;
begin
  // Directory Remove Permission
  Allowed := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if Pos('V', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then Allowed := True;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.FtpServerValidateRnFr(Sender: TObject; Client: TFtpCtrlSocket; var FilePath: TFtpString; var Allowed: Boolean);
var
  RegIniFile: TIniFile;
begin
  // Rename file and directory Permission
  Allowed := False;
  RegIniFile := TIniFile.Create(MainForm.GetDtaDir + 'FtpAccounts.INI');
  try
    if FileExists(FilePath) then
      if Pos('N', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then Allowed := True;
    if DirectoryExists(FilePath) then
      if Pos('M', RegIniFile.ReadString(Client.UserName, 'DirPerm', '---')) > 0 then Allowed := True;
  finally
    RegIniFile.Free;
  end;
end;

procedure TFTPForm.StartFtpServer;
begin
  FtpServer.Active := True;
  if FtpServer.Active then
  begin
    MainForm.mmiftp.Checked := True;
    MainForm.mmiftp.Caption := 'ftp (running)';
    MainForm.WriteLog('Starting' + OverbyteIcsFtpSrv.CopyRight, MainForm.PathEdit, 'I');
  end;
end;

procedure TFTPForm.StopFtpServer;
begin
  FtpServer.Active := False;
  if not FtpServer.Active then
  begin
    MainForm.mmiftp.Checked := False;
    MainForm.mmiftp.Caption := 'ftp (stopped)';
    MainForm.WriteLog('Ftp Server Stopped', MainForm.PathEdit, 'I');
  end;
end;

end.
