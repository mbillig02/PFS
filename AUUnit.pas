unit AUUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs, JvBaseDlg, JvSelectDirectory, ScBridge;

type
  TAddUserDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    UserNameLabeledEdit: TLabeledEdit;
    HomePathEdit: TLabeledEdit;
    SelectHomePathBtn: TButton;
    FileOpenDialog: TFileOpenDialog;
    JvSelectDirectory: TJvSelectDirectory;
    PasswordEdit: TLabeledEdit;
    ListBox: TListBox;
    ScFileStorage: TScFileStorage;
    procedure SelectHomePathBtnClick(Sender: TObject);
    procedure HomePathEditChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddUserDlg: TAddUserDlg;

implementation

uses PerlRegEx, System.UITypes;

{$R *.dfm}

{========================================================================}
// https://stackoverflow.com/questions/4618743/how-to-make-messagedlg-centered-on-owner-form
function MessageDlgCenter(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons): Integer;
var R: TRect;
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
{========================================================================}
procedure TAddUserDlg.FormActivate(Sender: TObject);
begin
  UserNameLabeledEdit.SetFocus;
end;
{========================================================================}
procedure TAddUserDlg.HomePathEditChange(Sender: TObject);
const
  clGoodPath = 11534255;
  clBadPath = 11513855;
var
  RegEx: TPerlRegEx;
  PathFmtMatch, BlankPath: Boolean;
begin
  BlankPath := (Length((Sender as TLabeledEdit).Text) = 0);
  PathFmtMatch := False;
  Regex := TPerlRegEx.Create;
	Regex.Options := [preCaseless, preExtended];
  Regex.Subject := AnsiToUTF8((Sender as TLabeledEdit).Text);

  Regex.RegEx := '(?>\b[a-z]:|\\\\[a-z0-9 %._~-]{1,63}\\[a-z0-9 $%._~-]{1,80})\\(?>[^\\/:*?"<>|\x00-\x1F]{0,254}[^.\\/:*?"<>|\x00-\x1F]\\)*';
  if Regex.Match and (Regex.MatchedLength = Length(Regex.Subject)) then PathFmtMatch := True;

  if PathFmtMatch or BlankPath then
  begin
    if DirectoryExists((Sender as TLabeledEdit).Text) or BlankPath then
    begin
      (Sender as TLabeledEdit).Color := clGoodPath;
    end
    else
    begin
      (Sender as TLabeledEdit).Color := clBadPath;
    end;
  end
  else
  begin
    (Sender as TLabeledEdit).Color := clBadPath;
  end;
  RegEx.Free;
end;
{========================================================================}
procedure TAddUserDlg.OKBtnClick(Sender: TObject);
var
  User: TScUser;
begin
  if Length(Trim(UserNameLabeledEdit.Text)) = 0 then
  begin
    MessageDlgCenter('UserName cannot be empty!', mtError, [mbOk]);
    ModalResult := mrNone;
    UserNameLabeledEdit.SetFocus;
  end
  else
  begin
    ScFileStorage.Users.GetUserNames(ListBox.Items);
    if ListBox.Items.IndexOf(UserNameLabeledEdit.Text) = -1 then
    begin
      User := TScUser.Create(ScFileStorage.Users);
      User.UserName := UserNameLabeledEdit.Text;
    end
    else
    begin
      MessageDlgCenter('UserName already exists!'+#13+#10+'Please select another UserName.', mtError, [mbOk]);
      ModalResult := mrNone;
      Exit;
    end;
    User.Password := PasswordEdit.Text;
    User.HomePath := HomePathEdit.Text;
    User.ExtData := '/,RWAND-LCMVI';
    User.Authentications := User.Authentications + [uaPassword];
    ScFileStorage.Users.GetUserNames(ListBox.Items);
//    MainForm.UpdateUserIni(UserNameEdit.Text,PasswordEdit.Text,HomePathEdit.Text,VST3ToDirPermStr);
//    Close;
  end;
end;
{========================================================================}
procedure TAddUserDlg.SelectHomePathBtnClick(Sender: TObject);
begin
// https://stackoverflow.com/questions/7422689/selecting-a-directory-with-topendialog
  if Win32MajorVersion >= 6 then
  begin
    with TFileOpenDialog.Create(nil) do
      try
        Title := 'Select Directory';
        Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
        OkButtonLabel := 'Select';
        DefaultFolder := HomePathEdit.Text;
        FileName := HomePathEdit.Text;
        if Execute then HomePathEdit.Text := IncludeTrailingPathDelimiter(FileName);
      finally
        Free;
      end
  end
  else
  begin
    JvSelectDirectory.InitialDir := HomePathEdit.Text;
    if JvSelectDirectory.Execute then
    begin
      HomePathEdit.Text := IncludeTrailingPathDelimiter(JvSelectDirectory.Directory);
    end;
  end;
end;
{========================================================================}
end.
