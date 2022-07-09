unit SFTPUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ScBridge, ScSFTPServer, ScSSHServer, ScUtils, ScSSHSocket,
  ScSSHUtils, ScSFTPUtils, ScSFTPConsts;

type
  TSFTPForm = class(TForm)
    ScSSHServer: TScSSHServer;
    ScSFTPServer: TScSFTPServer;
    ScFileStorage: TScFileStorage;
    function TCPConnectionToStr(Connection: TScTCPConnection): String;
    procedure InitKeys;
    procedure ScSFTPServerCloseFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; var Error: TScSFTPError);
    procedure ScSFTPServerMakeDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const Path: String; var Error: TScSFTPError);
    procedure ScSFTPServerOpen(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo);
    procedure ScSFTPServerOpenDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const Path: String; out Data: TObject; var Error: TScSFTPError);
    procedure ScSFTPServerOpenFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const FileName: String; const OpenAttributes: TScSFTPFileOpenAttributes; out Data: TObject; var Error: TScSFTPError);
    procedure ScSFTPServerReadDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; FileInfo: TScSFTPFileInfo; var Error: TScSFTPError);
    procedure ScSFTPServerReadFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; Offset: Int64; Count: Cardinal; var Buffer: TArray<System.Byte>; var Read: Cardinal; var Error: TScSFTPError);
    procedure ScSFTPServerRemoveDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const Path: String; var Error: TScSFTPError);
    procedure ScSFTPServerRemoveFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const FileName: String; var Error: TScSFTPError);
    procedure ScSFTPServerRenameFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const OldName, NewName: String; const Flags: TScSFTPRenameFlags; var Error: TScSFTPError);
    procedure ScSFTPServerRequestFileSecurityAttributes(Sender: TObject; Attributes: TScSFTPFileAttributes; const Path: String; SecurityDescriptor: Pointer);
    procedure ScSFTPServerWriteFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; Offset: Int64; const Buffer: TArray<System.Byte>; Count: Integer; var Error: TScSFTPError);
    procedure ScSSHServerAfterChannelDisconnect(Sender: TObject; ChannelInfo: TScSSHChannelInfo);
    procedure ScSSHServerAfterClientConnect(Sender: TObject; ClientInfo: TScSSHClientInfo);
    procedure ScSSHServerAfterClientDisconnect(Sender: TObject; ClientInfo: TScSSHClientInfo);
    procedure ScSSHServerBeforeChannelConnect(Sender: TObject; ChannelInfo: TScSSHChannelInfo; var Direct: Boolean);
    procedure ScSSHServerClientError(Sender: TObject; ClientInfo: TScSSHClientInfo; E: Exception);
    procedure ShowKeyFingerprints;
    procedure StartSftpServer;
    procedure StopSftpServer;
  private
    { Private declarations }
    procedure GenerateKey(Key: TScKey; const Algorithm: TScAsymmetricAlgorithm);
  public
    { Public declarations }
  end;

var
  SFTPForm: TSFTPForm;

implementation

uses MFUnit, SetUnit;

const
  ServerKeyNameRSA = 'SBSSHServer_RSA';
  ServerKeyNameDSA = 'SBSSHServer_DSA';
  ServerKeyNameEC = 'SBSSHServer_EC';

{$R *.dfm}

function TSFTPForm.TCPConnectionToStr(Connection: TScTCPConnection): String;
begin
  Result := Connection.GetRemoteIP + ':' + IntToStr(Connection.GetRemotePort);
end;

procedure TSFTPForm.GenerateKey(Key: TScKey; const Algorithm: TScAsymmetricAlgorithm);
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    if Algorithm = aaEC then
      Key.GenerateEC(secp256r1)
    else
      Key.Generate(Algorithm, 2048);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TSFTPForm.InitKeys;

  procedure CheckKey(const KeyName: String; const Algorithm: TScAsymmetricAlgorithm);
  var
    Key: TScKey;
  begin
    Key := ScFileStorage.Keys.FindKey(KeyName);

    if Key = nil then begin
      Key := TScKey.Create(nil);
      try
        GenerateKey(Key, Algorithm);
        Key.KeyName := KeyName;
        ScFileStorage.Keys.Add(Key);
      except
        Key.Free;
        raise;
      end;
    end;
  end;

begin
  ScFileStorage.Keys.Refresh;
  CheckKey(ServerKeyNameRSA, aaRSA);
  CheckKey(ServerKeyNameDSA, aaDSA);
  CheckKey(ServerKeyNameEC, aaEC);
end;

procedure TSFTPForm.ScSFTPServerCloseFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; var Error: TScSFTPError);
begin
  // SSH_FXP_CLOSE = 4;
  MainForm.WriteLog('SSH_FXP_CLOSE', SFTPSessionInfo.Client, 'D');
  ScSFTPServer.DefaultCloseFile(SFTPSessionInfo, Data, Error);
  MainForm.ClearFile(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection));
  if Data is TScSearchRec then MainForm.WriteLog('Directory listing complete', SFTPSessionInfo.Client, 'I');
  if Data is TScHandle then MainForm.WriteLog('Transfer complete: ' + (Data as TScHandle).FullFileName, SFTPSessionInfo.Client, 'I');
end;

procedure TSFTPForm.ScSFTPServerMakeDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const Path: String; var Error: TScSFTPError);
var
  ProcessAllowed: Boolean;
begin
// SSH_FXP_MKDIR = 14;
  ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'C', Path);
  if ProcessAllowed then
  begin
    MainForm.WriteLog('SSH_FXP_MKDIR -> ' + Path,SFTPSessionInfo.Client, 'D');
    MainForm.WriteLog('Create directory: ' + Path,SFTPSessionInfo.Client, 'I');
    ScSFTPServer.DefaultMakeDirectory(SFTPSessionInfo, Path, Error);
  end
  else
  begin
    InitError(Error, erPermissionDenied, '550 Cannot create directory. Permission denied!');
    MainForm.WriteLog('SSH_FXP_MKDIR -> ' + Path + ' [550 Cannot create directory. Permission denied!]', SFTPSessionInfo.Client, 'W');
  end;
end;

procedure TSFTPForm.ScSFTPServerOpen(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo);
begin
  MainForm.WriteLog('SFTP Protocol Version: ' + IntToStr(SFTPSessionInfo.Version), SFTPSessionInfo.Client, 'I');
end;

procedure TSFTPForm.ScSFTPServerOpenDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const Path: String; out Data: TObject; var Error: TScSFTPError);
var
  TmpStr, Directory: String;
  ProcessAllowed: Boolean;
begin
  ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'L', Path);
  if not ProcessAllowed then
    MainForm.WriteLog('Permission Denied!', MainForm.PathEdit, 'W');
  if ProcessAllowed then
  begin
  // SSH_FXP_OPENDIR = 11;
    TmpStr := 'SSH_FXP_OPENDIR -> ' + IncludeTrailingPathDelimiter(ScSFTPServer.GetFullPath(SFTPSessionInfo, Path));
    MainForm.WriteLog(TmpStr, SFTPSessionInfo.Client, 'D');
    TmpStr := 'Listing directory: ' + IncludeTrailingPathDelimiter(ScSFTPServer.GetFullPath(SFTPSessionInfo, Path));
    MainForm.WriteLog(TmpStr, SFTPSessionInfo.Client, 'I');
    Directory := IncludeTrailingPathDelimiter(ScSFTPServer.GetFullPath(SFTPSessionInfo, Path));
    MainForm.UpdateDirectory(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection), Directory);
    ScSFTPServer.DefaultOpenDirectory(SFTPSessionInfo, Path, Data, Error);
  end
  else
  begin
    Error.ErrorCode := erPermissionDenied;
    Error.ErrorMessage := 'Permission Denied';
    TmpStr := 'SSH_FXP_OPENDIR -> ' + IncludeTrailingPathDelimiter(ScSFTPServer.GetFullPath(SFTPSessionInfo, Path)) + ' [Permission Denied]';
    MainForm.WriteLog(TmpStr, SFTPSessionInfo.Client, 'W');
  end;
end;

procedure TSFTPForm.ScSFTPServerOpenFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const FileName: String; const OpenAttributes: TScSFTPFileOpenAttributes; out Data: TObject; var Error: TScSFTPError);
var
  ProcessAllowed: Boolean;
  TmpFileName, UorDStr: String;
begin
  ProcessAllowed := False; UorDStr := '';
//  DisplayFileOpenFlags(OpenAttributes.Flags); // Did not show anything on upload
  if SettingsForm.DisplayFileOpenModeChkBox.Checked then MainForm.DisplayFileOpenMode(OpenAttributes.Mode);
  if SettingsForm.DisplayDesiredAccessChkBox.Checked then MainForm.DisplayDesiredAccess(OpenAttributes.DesiredAccess);
//  if SettingsForm.DisplayDebugInfoChkBox.Checked then InfoMemo.Lines.Append('FileName: ' + FileName);
  MainForm.WriteLog('FileName: ' + FileName, SFTPSessionInfo.Client, 'D');
  TmpFileName := FileName;
  // delete filename
  SetLength(TmpFileName, LastDelimiter('/', TmpFileName) - 1);
  if Length(TmpFileName) = 0 then TmpFileName := '/';
//  if SettingsForm.DisplayDebugInfoChkBox.Checked then InfoMemo.Lines.Append('TmpFileName: ' + TmpFileName);
  MainForm.WriteLog('TmpFileName: ' + TmpFileName, SFTPSessionInfo.Client, 'D');
  if amReadData in OpenAttributes.DesiredAccess then
  begin
    ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'R', TmpFileName);
    if not ProcessAllowed then
      MainForm.WriteLog('SSH_FXP_OPEN -> ' + ScSFTPServer.GetFullPath(SFTPSessionInfo, FileName) + ' [Download not allowed]', SFTPSessionInfo.Client, 'W');
    UorDStr := 'D ';
  end;
  if amWriteData in OpenAttributes.DesiredAccess then
  begin
    ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'W', TmpFileName);
    if not ProcessAllowed then
      MainForm.WriteLog('SSH_FXP_OPEN -> ' + ScSFTPServer.GetFullPath(SFTPSessionInfo, FileName) + ' [Upload not allowed]', SFTPSessionInfo.Client, 'W');
    UorDStr := 'U ';
  end;
  if ((fmOpenExisting in [OpenAttributes.Mode]) and (not (amReadData in OpenAttributes.DesiredAccess))) then
  begin
    ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'A', TmpFileName);
    if not ProcessAllowed then
      MainForm.WriteLog('SSH_FXP_OPEN -> ' + ScSFTPServer.GetFullPath(SFTPSessionInfo, FileName) + ' [Append not allowed]', SFTPSessionInfo.Client, 'W');
    UorDStr := 'R ';
  end;
  if ProcessAllowed then
  begin
  // SSH_FXP_OPEN = 3;
    if Length(UorDStr) > 0 then
    begin
      if UorDStr = 'U ' then MainForm.WriteLog('SSH_FXP_OPEN -> ' + FileName + ' [Upload started]', SFTPSessionInfo.Client, 'D');
      if UorDStr = 'U ' then MainForm.WriteLog('Upload started: ' + FileName, SFTPSessionInfo.Client, 'I');
      if UorDStr = 'R ' then MainForm.WriteLog('SSH_FXP_OPEN -> ' + FileName + ' [Resuming upload]', SFTPSessionInfo.Client, 'D');
      if UorDStr = 'R ' then MainForm.WriteLog('Resuming upload: ' + FileName, SFTPSessionInfo.Client, 'I');
      if UorDStr = 'D ' then MainForm.WriteLog('SSH_FXP_OPEN -> ' + FileName + ' [Download started]', SFTPSessionInfo.Client, 'D');
      if UorDStr = 'D ' then MainForm.WriteLog('Download started: ' + FileName, SFTPSessionInfo.Client, 'I');
    end
    else
    begin
      MainForm.WriteLog('SSH_FXP_OPEN -> ' + FileName, SFTPSessionInfo.Client, 'D');
    end;
    MainForm.UpdateTransfer(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection), UorDStr +
      ExtractFilename(ScSFTPServer.GetFullPath(SFTPSessionInfo, FileName)));
    ScSFTPServer.DefaultOpenFile(SFTPSessionInfo, FileName, OpenAttributes, Data, Error);
  end
  else
  begin
    InitError(Error, erPermissionDenied, '550. Permission denied!');
  end;
end;

procedure TSFTPForm.ScSFTPServerReadDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; FileInfo: TScSFTPFileInfo; var Error: TScSFTPError);
var
  TmpStr: String;
begin
  if LogReadDirFileInfo then
  begin
  // SSH_FXP_READDIR = 12;
    TmpStr := 'SSH_FXP_READDIR -> ' + FileInfo.Filename;
    MainForm.WriteLog(TmpStr, SFTPSessionInfo.Client, 'I');
  end;
  ScSFTPServer.DefaultReadDirectory(SFTPSessionInfo, Data, FileInfo, Error);
end;

procedure TSFTPForm.ScSFTPServerReadFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; Offset: Int64; Count: Cardinal; var Buffer: TArray<System.Byte>; var Read: Cardinal; var Error: TScSFTPError);
begin
  // SSH_FXP_READ = 5;
  if LogFileRead then MainForm.WriteLog('SSH_FXP_READ -> '+IntToStr(Offset), SFTPSessionInfo.Client, 'I');
  if MainForm.OkayToUpdate(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection)) then
  begin
    MainForm.UpdateBytes(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection), MainForm.ConvertBytes(Offset));
    MainForm.FlagUpdated(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection));
  end;
  ScSFTPServer.DefaultReadFile(SFTPSessionInfo, Data, Offset, Count, Buffer, Read, Error);
end;

procedure TSFTPForm.ScSFTPServerRemoveDirectory(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const Path: String; var Error: TScSFTPError);
var
  ProcessAllowed: Boolean;
begin
  ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'V', Path);
  if not ProcessAllowed then
    MainForm.WriteLog('Cannot remove directory (' + Path + '). Permission denied!', SFTPSessionInfo.Client, 'W');
  if ProcessAllowed then
  begin
    // SSH_FXP_RMDIR = 15;
    MainForm.WriteLog('SSH_FXP_RMDIR -> ' + Path, SFTPSessionInfo.Client, 'D');
    MainForm.WriteLog('Remove directory: ' + Path, SFTPSessionInfo.Client, 'I');
    ScSFTPServer.DefaultRemoveDirectory(SFTPSessionInfo, Path, Error);
  end
  else
  begin
    InitError(Error, erPermissionDenied, '550 Cannot remove directory. Permission denied!');
  end;
end;

procedure TSFTPForm.ScSFTPServerRemoveFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const FileName: String; var Error: TScSFTPError);
var
  ProcessAllowed: Boolean;
  TmpFileName: String;
begin
  TmpFileName := FileName;
  // delete filename
  SetLength(TmpFileName, LastDelimiter('/', TmpFileName) - 1);
  if Length(TmpFileName) = 0 then TmpFileName := '/';
  MainForm.WriteLog('TmpFileName: ' + TmpFileName, SFTPSessionInfo.Client, 'D');
  ProcessAllowed := MainForm.CheckUserPathPermissions(SFTPSessionInfo.Client.UserExtData, 'D', TmpFileName);
  if not ProcessAllowed then
    MainForm.WriteLog('Cannot remove file (' + FileName + '). Permission denied!', SFTPSessionInfo.Client, 'W');
  if ProcessAllowed then
  begin
    // SSH_FXP_REMOVE = 13;
    MainForm.WriteLog('SSH_FXP_REMOVE -> ' + FileName, SFTPSessionInfo.Client, 'D');
    MainForm.WriteLog('File deleted: ' + FileName, SFTPSessionInfo.Client, 'I');
    ScSFTPServer.DefaultRemoveFile(SFTPSessionInfo, FileName, Error);
  end
  else
  begin
    InitError(Error, erPermissionDenied, '550 Cannot remove file. Permission denied!');
  end;
end;

procedure TSFTPForm.ScSFTPServerRenameFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; const OldName, NewName: String; const Flags: TScSFTPRenameFlags; var Error: TScSFTPError);
var
  ProcessAllowed: Boolean;
begin
  ProcessAllowed := False;
  if FileExists(SFTPForm.ScSFTPServer.GetFullPath(SFTPSessionInfo, OldName)) then
    ProcessAllowed := (Pos('N', SFTPSessionInfo.Client.UserExtData) > 0); // File
  if DirectoryExists(SFTPForm.ScSFTPServer.GetFullPath(SFTPSessionInfo, OldName)) then
    ProcessAllowed := (Pos('M', SFTPSessionInfo.Client.UserExtData) > 0); // Directory
  if ProcessAllowed then
  begin
  // SSH_FXP_RENAME = 18;
    MainForm.WriteLog('SSH_FXP_RENAME -> ' + OldNAme + ' to ' + NewName,SFTPSessionInfo.Client, 'D');
    MainForm.WriteLog('Rename file: ' + OldNAme + ' to ' + NewName,SFTPSessionInfo.Client, 'I');
    ScSFTPServer.DefaultRenameFile(SFTPSessionInfo, OldName, NewName, Flags, Error);
  end
  else
  begin
    InitError(Error, erPermissionDenied, '550 Cannot rename file. Permission denied!');
  end;
end;

procedure TSFTPForm.ScSFTPServerRequestFileSecurityAttributes(Sender: TObject; Attributes: TScSFTPFileAttributes; const Path: String; SecurityDescriptor: Pointer);
begin
  // This is empty to speed up the reading of directories
  {
    This overhead is associated with the installation of security attributes in the information
    for each file in the directory. Therefore, to increase performance, you should use the
    TScSFTPServer.RequestFileSecurityAttributes event handler. Maximum performance will be
    achieved if you do not perform any actions in this event handler. Only in this case, no
    security attributes will be set to the information about the files.
    https://devart.com/sbridge/docs/tscsftpserver_onrequestfilesecurityattributes.htm
  }
end;

procedure TSFTPForm.ScSFTPServerWriteFile(Sender: TObject; SFTPSessionInfo: TScSFTPSessionInfo; Data: TObject; Offset: Int64; const Buffer: TArray<System.Byte>; Count: Integer; var Error: TScSFTPError);
begin
  if SettingsForm.EnableRealtimeStatusChkBox.Checked then
  begin
    if MainForm.OkayToUpdate(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection)) then
    begin
      MainForm.UpdateBytes(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection), MainForm.ConvertBytes(Offset));
      MainForm.FlagUpdated(TCPConnectionToStr(SFTPSessionInfo.Client.TCPConnection));
    end;
  end;
  ScSFTPServer.DefaultWriteFile(SFTPSessionInfo, Data, Offset, Buffer, Count, Error);
end;

procedure TSFTPForm.ScSSHServerAfterChannelDisconnect(Sender: TObject; ChannelInfo: TScSSHChannelInfo);
begin
  MainForm.WriteLog('Channel Disconnect', ChannelInfo, 'I');
end;

procedure TSFTPForm.ScSSHServerAfterClientConnect(Sender: TObject; ClientInfo: TScSSHClientInfo);
begin
  MainForm.WriteLog('Client Connect: ' + ClientInfo.Version, ClientInfo, 'I');
  MainForm.AddUser(TCPConnectionToStr(ClientInfo.TCPConnection), ClientInfo.User, '', '', '', '');
end;

procedure TSFTPForm.ScSSHServerAfterClientDisconnect(Sender: TObject; ClientInfo: TScSSHClientInfo);
begin
  MainForm.WriteLog('Client Disconnect', ClientInfo, 'I');
  MainForm.DelUser(TCPConnectionToStr(ClientInfo.TCPConnection));
end;

procedure TSFTPForm.ScSSHServerBeforeChannelConnect(Sender: TObject; ChannelInfo: TScSSHChannelInfo; var Direct: Boolean);
begin
  MainForm.WriteLog('Channel Connect', ChannelInfo, 'I');
end;

procedure TSFTPForm.ScSSHServerClientError(Sender: TObject; ClientInfo: TScSSHClientInfo; E: Exception);
begin
//  MainForm.WriteLog('Error -> ' + E.Message,ClientInfo);
end;

procedure TSFTPForm.ShowKeyFingerprints;
var
  FingerPrint: String;
begin
  SettingsForm.KeysMemo.Clear;
  SettingsForm.KeysMemo.Lines.Append('RSA Key Fingerprints:');
  ScFileStorage.Keys.KeyByName(ServerKeyNameRSA).GetFingerprint(haMD5, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('MD5: ' + FingerPrint);
  ScFileStorage.Keys.KeyByName(ServerKeyNameRSA).GetFingerprint(haSHA1, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('SHA1: ' + FingerPrint);
  ScFileStorage.Keys.KeyByName(ServerKeyNameRSA).GetFingerprint(haSHA2_256, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('SHA256: ' + FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('');
  SettingsForm.KeysMemo.Lines.Append('EC Key Fingerprints:');
  ScFileStorage.Keys.KeyByName(ServerKeyNameEC).GetFingerprint(haMD5, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('MD5: ' + FingerPrint);
  ScFileStorage.Keys.KeyByName(ServerKeyNameEC).GetFingerprint(haSHA1, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('SHA1: ' + FingerPrint);
  ScFileStorage.Keys.KeyByName(ServerKeyNameEC).GetFingerprint(haSHA2_256, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('SHA256: ' + FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('');
  SettingsForm.KeysMemo.Lines.Append('DSA Key Fingerprints:');
  ScFileStorage.Keys.KeyByName(ServerKeyNameDSA).GetFingerprint(haMD5, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('MD5: ' + FingerPrint);
  ScFileStorage.Keys.KeyByName(ServerKeyNameDSA).GetFingerprint(haSHA1, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('SHA1: ' + FingerPrint);
  ScFileStorage.Keys.KeyByName(ServerKeyNameDSA).GetFingerprint(haSHA2_256, FingerPrint);
  SettingsForm.KeysMemo.Lines.Append('SHA256: ' + FingerPrint);
end;

procedure TSFTPForm.StartSftpServer;
begin
  ScSSHServer.Active := True;
  if ScSSHServer.Active then
  begin
    MainForm.mmisftp.Checked := True;
    MainForm.mmisftp.Caption := 'sftp (running)';
    MainForm.WriteLog('Starting Devart sFtp Server V' + SecureBridgeVersion, MainForm.PathEdit, 'I');
  end;
end;

procedure TSFTPForm.StopSftpServer;
begin
  ScSSHServer.Active := False;
  if not ScSSHServer.Active then
  begin
    MainForm.mmisftp.Checked := False;
    MainForm.mmisftp.Caption := 'sftp (stopped)';
    MainForm.WriteLog('sFtp Server Stopped', MainForm.PathEdit, 'I');
  end;
end;

end.
