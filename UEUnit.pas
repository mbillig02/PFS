unit UEUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ScBridge, Dialogs, JvBaseDlg, JvSelectDirectory, ComCtrls,
  VirtualTrees;

type
  PTreeDataUE = ^TTreeDataUE;
  TTreeDataUE = record
    FPath: String[30];
    FPermissions: String[30];
  end;
  TUserEditorDlg = class(TForm)
    ScFileStorage: TScFileStorage;
    ListBox: TListBox;
    UserNameEdit: TLabeledEdit;
    PasswordEdit: TLabeledEdit;
    HomePathEdit: TLabeledEdit;
    DelUserBtn: TButton;
    JvSelectDirectory: TJvSelectDirectory;
    SelectHomePathBtn: TButton;
    PermissionsLbl: TLabel;
    PathEdit: TEdit;
    FileGrpBox: TGroupBox;
    ReadChkBox: TCheckBox;
    WriteChkBox: TCheckBox;
    AppendChkBox: TCheckBox;
    RenameChkBox: TCheckBox;
    DeleteChkBox: TCheckBox;
    ExecuteChkBox: TCheckBox;
    Directory: TGroupBox;
    ListChkBox: TCheckBox;
    CreateChkBox: TCheckBox;
    RenameDirChkBox: TCheckBox;
    RemoveChkBox: TCheckBox;
    SubdirectoryGrpBox: TGroupBox;
    InheritChkBox: TCheckBox;
    VSTUE: TVirtualStringTree;
    FullAccessBtn: TButton;
    ReadOnlyBtn: TButton;
    AddToListBtn: TButton;
    DeleteFromListBtn: TButton;
    PermissionPanel: TPanel;
    TopPanel: TPanel;
    EditUserBtn: TButton;
    SaveUserBtn: TButton;
    CancelEditBtn: TButton;
    AddUserBtn: TButton;
    AddTestItemBtn: TButton;
    SpeedButton1: TSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure DelUserBtnClick(Sender: TObject);
    procedure HomePathEditChange(Sender: TObject);
    procedure SelectHomePathBtnClick(Sender: TObject);
    procedure VSTUEGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VSTUENodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure ChkBoxClick(Sender: TObject);
    procedure FullAccessBtnClick(Sender: TObject);
    procedure ReadOnlyBtnClick(Sender: TObject);
    procedure AddToListBtnClick(Sender: TObject);
    procedure DeleteFromListBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VSTUEBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure VSTUEHeaderDrawQueryElements(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
    procedure VSTUEAdvancedHeaderDraw(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
    procedure EditUserBtnClick(Sender: TObject);
    procedure SaveUserBtnClick(Sender: TObject);
    procedure CancelEditBtnClick(Sender: TObject);
    procedure AddUserBtnClick(Sender: TObject);
    procedure AddTestItemBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure AddPath(Path, Permissions: String);
    function GetDataByColumnUE(Data: TTreeDataUE; Column: Integer): String;
    procedure LoadVSTUE(DirPermStr: String);
    function StringDataToTreeDataUE(Path, Permissions: String): TTreeDataUE;
    procedure SetCheckBoxesUE(DirPermStr: String);
    procedure UpdateGrid;
    function VSTUEToDirPermStr: String;
    procedure DelDirPerm(Path: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UserEditorDlg: TUserEditorDlg;
  Changes: Boolean;

implementation

uses MFUnit, PerlRegEx, UtlUnit, AUUnit, System.UITypes, SFTPUnit;

var
  FInitialized: Boolean;
  DirPermStr: String;

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
procedure TUserEditorDlg.AddToListBtnClick(Sender: TObject);
var
  Data: PTreeDataUE;
  Node: PVirtualNode;
  PathFound: Boolean;
begin
  PathFound := False;
  Node := VSTUE.GetFirst;
  while Assigned(Node) do
  begin
    Data := VSTUE.GetNodeData(Node);
    if PathEdit.Text = String(Data.FPath) then
    begin
      VSTUE.BeginUpdate;
      Data^ := StringDataToTreeDataUE(PathEdit.Text, PermissionsLbl.Caption);
      VSTUE.EndUpdate;
      PathFound := True;
    end;
    Node := VSTUE.GetNext(Node);
  end;
  if not PathFound then
  begin
    VSTUE.BeginUpdate;
    Node := VSTUE.AddChild(nil);
    Data := VSTUE.GetNodeData(Node);
    VSTUE.ValidateNode(Node, False);
    Data^ := StringDataToTreeDataUE(PathEdit.Text, PermissionsLbl.Caption);
    VSTUE.EndUpdate;
  end;
end;
{========================================================================}
procedure TUserEditorDlg.AddUserBtnClick(Sender: TObject);
begin
  AddUserDlg.ScFileStorage.Path := ScFileStorage.Path;
  AddUserDlg.ScFileStorage.Users.Refresh;
  AddUserDlg.UserNameLabeledEdit.Text := '';
  AddUserDlg.PasswordEdit.Text := '';
  AddUserDlg.HomePathEdit.Text := '';
  if AddUserDlg.ShowModal = mrOk then
  begin
    ScFileStorage.Users.Refresh;
    ScFileStorage.Users.GetUserNames(ListBox.Items);
    ListBox.ItemIndex := ListBox.Items.IndexOf(AddUserDlg.UserNameLabeledEdit.Text);
    ListBoxClick(nil);
    SFTPForm.ScFileStorage.Users.Refresh;
  end;
end;
{========================================================================}
procedure TUserEditorDlg.AddTestItemBtnClick(Sender: TObject);
begin
  MainForm.CreateTestItemsINI(UserNameEdit.Text, PasswordEdit.Text, HomePathEdit.Text, VSTUEToDirPermStr);
end;
{========================================================================}
procedure TUserEditorDlg.SelectHomePathBtnClick(Sender: TObject);
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
function TUserEditorDlg.GetDataByColumnUE(Data: TTreeDataUE; Column: Integer): String;
begin
  case Column of
    0: Result := String(Data.FPath);
    1: Result := String(Data.FPermissions);
  else
    Result := '';
  end;
end;
{========================================================================}
//https://stackoverflow.com/questions/32396875/how-to-set-the-color-of-virtualstringtree-header
procedure TUserEditorDlg.VSTUEAdvancedHeaderDraw(Sender: TVTHeader;
  var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
begin
  if hpeBackground in Elements then
  begin
    PaintInfo.TargetCanvas.Brush.Color := RGB(225,225,225); // <-- your color here
    if Assigned(PaintInfo.Column) then
      DrawFrameControl(PaintInfo.TargetCanvas.Handle, PaintInfo.PaintRectangle, DFC_BUTTON, DFCS_FLAT or DFCS_ADJUSTRECT); // <-- I think, that this keeps the style of the header background, but I'm not sure about that
    PaintInfo.TargetCanvas.FillRect(PaintInfo.PaintRectangle);
  end;
end;
{========================================================================}
// GreenBar
procedure TUserEditorDlg.VSTUEBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin
  if Node.Index mod 2 = 1 then
  begin
    TargetCanvas.Brush.Color := RGB(212,255,212);
    TargetCanvas.FillRect(CellRect);
  end;
end;
{========================================================================}
procedure TUserEditorDlg.VSTUEGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTreeDataUE;
begin
  Data := (Sender as TBaseVirtualTree).GetNodeData(Node);
  CellText := GetDataByColumnUE(Data^, Column);
end;
{========================================================================}
//https://stackoverflow.com/questions/32396875/how-to-set-the-color-of-virtualstringtree-header
procedure TUserEditorDlg.VSTUEHeaderDrawQueryElements(Sender: TVTHeader;
  var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
begin
  Elements := [hpeBackground];
end;
{========================================================================}
procedure TUserEditorDlg.UpdateGrid;
var
  Data: PTreeDataUE;
  Node: PVirtualNode;
begin
  Node := VSTUE.GetFirst;
  while Assigned(Node) do
  begin
    Data := VSTUE.GetNodeData(Node);
    if PathEdit.Text = String(Data.FPath) then
    begin
      VSTUE.BeginUpdate;
      Data^ := StringDataToTreeDataUE(PathEdit.Text, PermissionsLbl.Caption);
      VSTUE.EndUpdate;
    end;
    Node := VSTUE.GetNext(Node);
  end;
end;
{========================================================================}
procedure TUserEditorDlg.ChkBoxClick(Sender: TObject);
begin
  if ReadChkBox.Checked then PermissionsLbl.Caption := 'R' else PermissionsLbl.Caption := '-';
  if WriteChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'W' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if AppendChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'A' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if RenameChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'N' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if DeleteChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'D' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if ExecuteChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'E' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if ListChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'L' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if CreateChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'C' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if RenameDirChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'M' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if RemoveChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'V' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  if InheritChkBox.Checked then PermissionsLbl.Caption := PermissionsLbl.Caption+'I' else PermissionsLbl.Caption := PermissionsLbl.Caption+'-';
  UpdateGrid;
end;
{========================================================================}
procedure TUserEditorDlg.SetCheckBoxesUE(DirPermStr: String);
begin
  ReadChkBox.OnClick := nil;
  WriteChkBox.OnClick := nil;
  AppendChkBox.OnClick := nil;
  RenameChkBox.OnClick := nil;
  DeleteChkBox.OnClick := nil;
  ExecuteChkBox.OnClick := nil;
  ListChkBox.OnClick := nil;
  CreateChkBox.OnClick := nil;
  RenameDirChkBox.OnClick := nil;
  RemoveChkBox.OnClick := nil;
  InheritChkBox.OnClick := nil;

  ReadChkBox.Checked := (Pos('R',DirPermStr) > 0);
  WriteChkBox.Checked := (Pos('W',DirPermStr) > 0);
  AppendChkBox.Checked := (Pos('A',DirPermStr) > 0);
  RenameChkBox.Checked := (Pos('N',DirPermStr) > 0);
  DeleteChkBox.Checked := (Pos('D',DirPermStr) > 0);
  ExecuteChkBox.Checked := (Pos('E',DirPermStr) > 0);
  ListChkBox.Checked := (Pos('L',DirPermStr) > 0);
  CreateChkBox.Checked := (Pos('C',DirPermStr) > 0);
  RenameDirChkBox.Checked := (Pos('M',DirPermStr) > 0);
  RemoveChkBox.Checked := (Pos('V',DirPermStr) > 0);
  InheritChkBox.Checked := (Pos('I',DirPermStr) > 0);

  ReadChkBox.OnClick := ChkBoxClick;
  WriteChkBox.OnClick := ChkBoxClick;
  AppendChkBox.OnClick := ChkBoxClick;
  RenameChkBox.OnClick := ChkBoxClick;
  DeleteChkBox.OnClick := ChkBoxClick;
  ExecuteChkBox.OnClick := ChkBoxClick;
  ListChkBox.OnClick := ChkBoxClick;
  CreateChkBox.OnClick := ChkBoxClick;
  RenameDirChkBox.OnClick := ChkBoxClick;
  RemoveChkBox.OnClick := ChkBoxClick;
  InheritChkBox.OnClick := ChkBoxClick;
end;
{========================================================================}
procedure TUserEditorDlg.SpeedButton1Click(Sender: TObject);
begin
  if SpeedButton1.Down then
  begin
    PasswordEdit.PasswordChar := #0;
  end
  else
  begin
    PasswordEdit.PasswordChar := '*';
  end;
end;
{========================================================================}
procedure TUserEditorDlg.VSTUENodeClick(Sender: TBaseVirtualTree;
  const HitInfo: THitInfo);
var
  Data: PTreeDataUE;
begin
  Data := VSTUE.GetNodeData(HitInfo.HitNode);
  PermissionsLbl.Caption := String(Data^.FPermissions);
  SetCheckBoxesUE(String(Data^.FPermissions));
  PathEdit.Text := String(Data^.FPath);
end;
{========================================================================}
procedure TUserEditorDlg.DelUserBtnClick(Sender: TObject);
var
  User: TScUser;
  UserName: String;
begin
  UserName := ListBox.Items[ListBox.ItemIndex];
  if MessageDlgCenter('Do you want delete "' + UserName + '" user?', mtConfirmation, [mbYes, mbNo]) = mrNo then Exit;
  User := ScFileStorage.Users.UserByName(UserName);
  try
    ScFileStorage.Users.Remove(User);
  finally
    User.Free;
    ListBox.Items.Delete(ListBox.ItemIndex);
    MainForm.DelUserIni(Username);
    SFTPForm.ScFileStorage.Users.Refresh;
  end;
end;
{========================================================================}
procedure TUserEditorDlg.EditUserBtnClick(Sender: TObject);
begin
  EditUserBtn.Enabled := False;
  SaveUserBtn.Enabled := True;
  CancelEditBtn.Enabled := True;

  AddTestItemBtn.Enabled := True;

  ListBox.Enabled := False;
//  UserNameEdit.Enabled := False;
  PasswordEdit.Enabled := True;
  AddUserBtn.Enabled := False;
  DelUserBtn.Enabled := False;

  SelectHomePathBtn.Enabled := True;
  HomePathEdit.Enabled := True;
  VSTUE.Enabled := True;
  PathEdit.Enabled := True;
  FullAccessBtn.Enabled := True;
  ReadOnlyBtn.Enabled := True;
  AddToListBtn.Enabled := True;
  DeleteFromListBtn.Enabled := True;
  ReadChkBox.Enabled := True;
  WriteChkBox.Enabled := True;
  AppendChkBox.Enabled := True;
  RenameChkBox.Enabled := True;
  DeleteChkBox.Enabled := True;
  ListChkBox.Enabled := True;
  CreateChkBox.Enabled := True;
  RenameDirChkBox.Enabled := True;
  RemoveChkBox.Enabled := True;
  InheritChkBox.Enabled := True;
  VSTUE.SetFocus;

  Changes := True;

end;
{========================================================================}
procedure TUserEditorDlg.SaveUserBtnClick(Sender: TObject);
var
  User: TScUser;
begin
  EditUserBtn.Enabled := True;
  SaveUserBtn.Enabled := False;
  CancelEditBtn.Enabled := False;

  AddTestItemBtn.Enabled := False;

  ListBox.Enabled := True;
//  UserNameEdit.Enabled := True;
  PasswordEdit.Enabled := False;
  AddUserBtn.Enabled := True;
  DelUserBtn.Enabled := True;

  SelectHomePathBtn.Enabled := False;
  HomePathEdit.Enabled := False;
  VSTUE.Enabled := False;
  PathEdit.Enabled := False;
  FullAccessBtn.Enabled := False;
  ReadOnlyBtn.Enabled := False;
  AddToListBtn.Enabled := False;
  DeleteFromListBtn.Enabled := False;
  ReadChkBox.Enabled := False;
  WriteChkBox.Enabled := False;
  AppendChkBox.Enabled := False;
  RenameChkBox.Enabled := False;
  DeleteChkBox.Enabled := False;
  ListChkBox.Enabled := False;
  CreateChkBox.Enabled := False;
  RenameDirChkBox.Enabled := False;
  RemoveChkBox.Enabled := False;
  InheritChkBox.Enabled := False;

  User := ScFileStorage.Users.UserByName(UserNameEdit.Text);
  User.Password := PasswordEdit.Text;
  User.HomePath := HomePathEdit.Text;
  User.ExtData := VSTUEToDirPermStr;
  User.Authentications := User.Authentications + [uaPassword];
  ScFileStorage.Users.GetUserNames(ListBox.Items);
  MainForm.UpdateUserIni(UserNameEdit.Text,PasswordEdit.Text,HomePathEdit.Text,VSTUEToDirPermStr);
  SFTPForm.ScFileStorage.Users.Refresh;

  Changes := False;

end;
{========================================================================}
procedure TUserEditorDlg.CancelEditBtnClick(Sender: TObject);
begin
  EditUserBtn.Enabled := True;
  SaveUserBtn.Enabled := False;
  CancelEditBtn.Enabled := False;

  AddTestItemBtn.Enabled := False;

  ListBox.Enabled := True;
//  UserNameEdit.Enabled := True;
  PasswordEdit.Enabled := False;
  AddUserBtn.Enabled := True;
  DelUserBtn.Enabled := True;

  SelectHomePathBtn.Enabled := False;
  HomePathEdit.Enabled := False;
  VSTUE.Enabled := False;
  PathEdit.Enabled := False;
  FullAccessBtn.Enabled := False;
  ReadOnlyBtn.Enabled := False;
  AddToListBtn.Enabled := False;
  DeleteFromListBtn.Enabled := False;
  ReadChkBox.Enabled := False;
  WriteChkBox.Enabled := False;
  AppendChkBox.Enabled := False;
  RenameChkBox.Enabled := False;
  DeleteChkBox.Enabled := False;
  ListChkBox.Enabled := False;
  CreateChkBox.Enabled := False;
  RenameDirChkBox.Enabled := False;
  RemoveChkBox.Enabled := False;
  InheritChkBox.Enabled := False;

  ListBoxClick(nil);
  Changes := False;
end;
{========================================================================}
procedure TUserEditorDlg.FormActivate(Sender: TObject);
begin
  if not FInitialized then
  begin
    FInitialized := True;
    VSTUE.Header.SortColumn := NoColumn;
    VSTUE.NodeDataSize := SizeOf(TTreeDataUE);
    Changes := False;
  end;
  ScFileStorage.Users.GetUserNames(ListBox.Items);
  if ListBox.Count > 0 then
  begin
    ListBox.ItemIndex := 0;
    ListBoxClick(nil);
  end;
  HomePathEditChange(HomePathEdit);
end;
{========================================================================}
procedure TUserEditorDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  Changes := False;
end;
{========================================================================}
procedure TUserEditorDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  MsgTxt: String;
begin
  if Changes then
  begin
    MsgTxt := 'You have not saved.'+#13+#10+'Save or Cancel edits!';
    MessageDlgCenter(MsgTxt, mtWarning, [mbOk]);
    CanClose := False;
  end;
end;
{========================================================================}
procedure TUserEditorDlg.FullAccessBtnClick(Sender: TObject);
begin
  ReadChkBox.Checked := True;
  WriteChkBox.Checked := True;
  AppendChkBox.Checked := True;
  RenameChkBox.Checked := True;
  DeleteChkBox.Checked := True;
  ExecuteChkBox.Checked := False; // not supported
  ListChkBox.Checked := True;
  CreateChkBox.Checked := True;
  RenameDirChkBox.Checked := True;
  RemoveChkBox.Checked := True;
  InheritChkBox.Checked := True;
end;
{========================================================================}
procedure TUserEditorDlg.HomePathEditChange(Sender: TObject);
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
procedure TUserEditorDlg.ListBoxClick(Sender: TObject);
var
  User: TScUser;
  Data: PTreeDataUE;
  Node: PVirtualNode;
begin
  if ListBox.ItemIndex <> -1 then
  begin
    User := ScFileStorage.Users.UserByName(ListBox.Items[ListBox.ItemIndex]);
    UserNameEdit.Text := User.UserName;
    PasswordEdit.Text := User.Password;
    HomePathEdit.Text := User.HomePath;
    DirPermStr := User.ExtData;
    LoadVSTUE(DirPermStr);
    Node := VSTUE.GetFirst;
    if Assigned(Node) then
    begin
      VSTUE.Selected[Node] := True;
      Data := VSTUE.GetNodeData(Node);
      PermissionsLbl.Caption := String(Data^.FPermissions);
    end;
  end;
end;
{========================================================================}
function TUserEditorDlg.StringDataToTreeDataUE(Path, Permissions: String): TTreeDataUE;
begin
  Result.FPath := Path;
  Result.FPermissions := Permissions;
end;
{========================================================================}
procedure TUserEditorDlg.AddPath(Path, Permissions: String);
var
  Data: PTreeDataUE;
  Node: PVirtualNode;
  PathFound: Boolean;
begin
  PathFound := False;
  Node := VSTUE.GetFirst;
  while Assigned(Node) do
  begin
    Data := VSTUE.GetNodeData(Node);
    if Path = String(Data.FPath) then
      PathFound := True;
    Node := VSTUE.GetNext(Node);
  end;
  if not PathFound then
  begin
    VSTUE.BeginUpdate;
    Node := VSTUE.AddChild(nil);
    Data := VSTUE.GetNodeData(Node);
    VSTUE.ValidateNode(Node, False);
    Data^ := StringDataToTreeDataUE(Path, Permissions);
    VSTUE.EndUpdate;
  end;
end;
{========================================================================}
procedure TUserEditorDlg.LoadVSTUE(DirPermStr: String);
var
  DirPermList, Words: TStringList;
  i: Integer;
begin
  VSTUE.Clear;
  Words := TStringList.Create;
  if Pos('|',DirPermStr) = 0 then
  begin
    Parse(DirPermStr, ',', Words);
    AddPath(Words[0], Words[1]);
    PathEdit.Text := Words[0];
    SetCheckBoxesUE(Words[1]);
  end
  else
  begin
    DirPermList := TStringList.Create;
    Parse(DirPermStr, '|', DirPermList);
    for i := 0 to DirPermList.Count - 1 do
    begin
      Parse(DirPermList[i], ',', Words);
      AddPath(Words[0], Words[1]);
      if Words[0] = '/' then
      begin
        PathEdit.Text := Words[0];
        SetCheckBoxesUE(Words[1]);
      end;
    end;
    DirPermList.Free;
  end;
  Words.Free;
end;
{========================================================================}
procedure TUserEditorDlg.ReadOnlyBtnClick(Sender: TObject);
begin
  ReadChkBox.Checked := True;
  WriteChkBox.Checked := False;
  AppendChkBox.Checked := False;
  RenameChkBox.Checked := False;
  DeleteChkBox.Checked := False;
  ExecuteChkBox.Checked := False;
  ListChkBox.Checked := True;
  CreateChkBox.Checked := False;
  RenameDirChkBox.Checked := False;
  RemoveChkBox.Checked := False;
  InheritChkBox.Checked := True;
end;
{========================================================================}
function TUserEditorDlg.VSTUEToDirPermStr: String;
var
  Data: PTreeDataUE;
  Node: PVirtualNode;
begin
  Result := '';
  Node := VSTUE.GetFirst;
  while Assigned(Node) do
  begin
    Data := VSTUE.GetNodeData(Node);
    Result := Result + String(Data^.FPath) + ',' + String(Data^.FPermissions) + '|';
    Node := VSTUE.GetNext(Node);
  end;
  SetLength(Result,Length(Result)-1);
end;
{========================================================================}
procedure TUserEditorDlg.DeleteFromListBtnClick(Sender: TObject);
begin
  if MessageDlgCenter('Are you sure you want to delete ' + PathEdit.Text + '?', mtConfirmation, [mbYes, mbNo]) = mrYes then
  begin
    DelDirPerm(PathEdit.Text);
  end;
end;
{========================================================================}
procedure TUserEditorDlg.DelDirPerm(Path: String);
var
  Node: PVirtualNode;
  Data: PTreeDataUE;
begin
  if Path = '/' then
  begin
    MessageDlg('The root path (/) cannot be deleted!', mtError, [mbOk], 0);
  end
  else
  begin
    Node := VSTUE.GetFirst;
    while Assigned(Node) do
    begin
      Data := VSTUE.GetNodeData(Node);
      if Path = String(Data.FPath) then
        VSTUE.DeleteNode(Node);
      Node := VSTUE.GetNext(Node);
    end;
  end;
end;
{========================================================================}
end.
