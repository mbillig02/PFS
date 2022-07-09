object AddUserDlg: TAddUserDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Add User'
  ClientHeight = 149
  ClientWidth = 384
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  DesignSize = (
    384
    149)
  PixelsPerInch = 96
  TextHeight = 13
  object OKBtn: TButton
    Left = 300
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 300
    Top = 42
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object UserNameLabeledEdit: TLabeledEdit
    Left = 16
    Top = 24
    Width = 121
    Height = 21
    EditLabel.Width = 49
    EditLabel.Height = 13
    EditLabel.Caption = 'UserName'
    TabOrder = 0
  end
  object HomePathEdit: TLabeledEdit
    Left = 16
    Top = 110
    Width = 360
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    EditLabel.Width = 49
    EditLabel.Height = 13
    EditLabel.Caption = 'HomePath'
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnChange = HomePathEditChange
  end
  object SelectHomePathBtn: TButton
    Left = 271
    Top = 79
    Width = 105
    Height = 25
    Caption = 'Select HomePath'
    TabOrder = 3
    OnClick = SelectHomePathBtnClick
  end
  object PasswordEdit: TLabeledEdit
    Left = 16
    Top = 67
    Width = 121
    Height = 21
    EditLabel.Width = 46
    EditLabel.Height = 13
    EditLabel.Caption = 'Password'
    TabOrder = 1
  end
  object ListBox: TListBox
    Left = 225
    Top = 81
    Width = 40
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    Visible = False
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 160
    Top = 48
  end
  object JvSelectDirectory: TJvSelectDirectory
    Left = 240
  end
  object ScFileStorage: TScFileStorage
    Left = 160
  end
end
