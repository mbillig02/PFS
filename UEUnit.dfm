object UserEditorDlg: TUserEditorDlg
  Left = 227
  Top = 108
  Caption = 'User Editor'
  ClientHeight = 445
  ClientWidth = 374
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object PermissionPanel: TPanel
    Left = 0
    Top = 260
    Width = 374
    Height = 185
    Align = alBottom
    TabOrder = 2
    object PermissionsLbl: TLabel
      Left = 121
      Top = 152
      Width = 140
      Height = 18
      Caption = 'PermissionsLbl'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
    object Directory: TGroupBox
      Left = 180
      Top = 35
      Width = 93
      Height = 93
      Caption = 'Directory'
      TabOrder = 2
      object ListChkBox: TCheckBox
        Left = 16
        Top = 17
        Width = 65
        Height = 17
        Caption = '(L)ist'
        Enabled = False
        TabOrder = 0
        OnClick = ChkBoxClick
      end
      object CreateChkBox: TCheckBox
        Left = 16
        Top = 34
        Width = 65
        Height = 17
        Caption = '(C)reate'
        Enabled = False
        TabOrder = 1
        OnClick = ChkBoxClick
      end
      object RenameDirChkBox: TCheckBox
        Left = 16
        Top = 51
        Width = 65
        Height = 17
        Caption = 'Rena(m)e'
        Enabled = False
        TabOrder = 2
        OnClick = ChkBoxClick
      end
      object RemoveChkBox: TCheckBox
        Left = 16
        Top = 68
        Width = 65
        Height = 17
        Caption = 'Remo(v)e'
        Enabled = False
        TabOrder = 3
        OnClick = ChkBoxClick
      end
    end
    object SubdirectoryGrpBox: TGroupBox
      Left = 8
      Top = 137
      Width = 97
      Height = 40
      Caption = 'Subdirectory'
      TabOrder = 3
      object InheritChkBox: TCheckBox
        Left = 16
        Top = 17
        Width = 65
        Height = 17
        Caption = '(I)nherit'
        Enabled = False
        TabOrder = 0
        OnClick = ChkBoxClick
      end
    end
    object FileGrpBox: TGroupBox
      Left = 8
      Top = 35
      Width = 169
      Height = 93
      Caption = 'File'
      TabOrder = 1
      object ReadChkBox: TCheckBox
        Left = 16
        Top = 17
        Width = 65
        Height = 17
        Caption = '(R)ead'
        Enabled = False
        TabOrder = 0
        OnClick = ChkBoxClick
      end
      object WriteChkBox: TCheckBox
        Left = 16
        Top = 34
        Width = 65
        Height = 17
        Caption = '(W)rite'
        Enabled = False
        TabOrder = 1
        OnClick = ChkBoxClick
      end
      object AppendChkBox: TCheckBox
        Left = 16
        Top = 51
        Width = 65
        Height = 17
        Caption = '(A)ppend'
        Enabled = False
        TabOrder = 2
        OnClick = ChkBoxClick
      end
      object RenameChkBox: TCheckBox
        Left = 16
        Top = 68
        Width = 65
        Height = 17
        Caption = 'Re(n)ame'
        Enabled = False
        TabOrder = 3
        OnClick = ChkBoxClick
      end
      object DeleteChkBox: TCheckBox
        Left = 91
        Top = 17
        Width = 65
        Height = 17
        Caption = '(D)elete'
        Enabled = False
        TabOrder = 4
        OnClick = ChkBoxClick
      end
      object ExecuteChkBox: TCheckBox
        Left = 91
        Top = 34
        Width = 65
        Height = 17
        Caption = '(E)xecute'
        Enabled = False
        TabOrder = 5
        OnClick = ChkBoxClick
      end
    end
    object ReadOnlyBtn: TButton
      Left = 288
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Read Only'
      Enabled = False
      TabOrder = 5
      OnClick = ReadOnlyBtnClick
    end
    object PathEdit: TEdit
      Left = 8
      Top = 8
      Width = 355
      Height = 21
      Enabled = False
      TabOrder = 0
      Text = '/'
    end
    object FullAccessBtn: TButton
      Left = 288
      Top = 41
      Width = 75
      Height = 25
      Caption = 'Full Access'
      Enabled = False
      TabOrder = 4
      OnClick = FullAccessBtnClick
    end
    object DeleteFromListBtn: TButton
      Left = 280
      Top = 152
      Width = 83
      Height = 25
      Caption = 'Delete from List'
      Enabled = False
      TabOrder = 7
      OnClick = DeleteFromListBtnClick
    end
    object AddToListBtn: TButton
      Left = 279
      Top = 121
      Width = 84
      Height = 25
      Caption = 'Add to List'
      Enabled = False
      TabOrder = 6
      OnClick = AddToListBtnClick
    end
  end
  object VSTUE: TVirtualStringTree
    Left = 0
    Top = 185
    Width = 374
    Height = 75
    Align = alClient
    Colors.BorderColor = 15987699
    Colors.DisabledColor = clGray
    Colors.DropMarkColor = 15385233
    Colors.DropTargetColor = 15385233
    Colors.DropTargetBorderColor = 15385233
    Colors.FocusedSelectionColor = clSkyBlue
    Colors.FocusedSelectionBorderColor = 15385233
    Colors.GridLineColor = 15987699
    Colors.HeaderHotColor = clBlack
    Colors.HotColor = clBlack
    Colors.SelectionRectangleBlendColor = 15385233
    Colors.SelectionRectangleBorderColor = 15385233
    Colors.SelectionTextColor = clBlack
    Colors.TreeLineColor = 9471874
    Colors.UnfocusedColor = clGray
    Colors.UnfocusedSelectionColor = 13421772
    Colors.UnfocusedSelectionBorderColor = 13421772
    Enabled = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    Header.AutoSizeIndex = 0
    Header.Options = [hoColumnResize, hoDrag, hoOwnerDraw, hoShowSortGlyphs, hoVisible]
    ParentFont = False
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect]
    OnAdvancedHeaderDraw = VSTUEAdvancedHeaderDraw
    OnBeforeCellPaint = VSTUEBeforeCellPaint
    OnGetText = VSTUEGetText
    OnHeaderDrawQueryElements = VSTUEHeaderDrawQueryElements
    OnNodeClick = VSTUENodeClick
    Columns = <
      item
        Alignment = taCenter
        Position = 0
        Text = 'Path'
        Width = 270
      end
      item
        Alignment = taCenter
        Position = 1
        Text = 'Permissions'
        Width = 100
      end>
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 374
    Height = 185
    Align = alTop
    TabOrder = 0
    DesignSize = (
      374
      185)
    object SpeedButton1: TSpeedButton
      Left = 207
      Top = 106
      Width = 40
      Height = 16
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Show'
      Flat = True
      OnClick = SpeedButton1Click
    end
    object DelUserBtn: TButton
      Left = 288
      Top = 39
      Width = 75
      Height = 25
      Caption = 'Delete User'
      TabOrder = 5
      OnClick = DelUserBtnClick
    end
    object SelectHomePathBtn: TButton
      Left = 258
      Top = 121
      Width = 105
      Height = 25
      Caption = 'Select HomePath'
      Enabled = False
      TabOrder = 3
      OnClick = SelectHomePathBtnClick
    end
    object HomePathEdit: TLabeledEdit
      Left = 8
      Top = 150
      Width = 351
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Ctl3D = True
      EditLabel.Width = 49
      EditLabel.Height = 13
      EditLabel.Caption = 'HomePath'
      Enabled = False
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnChange = HomePathEditChange
    end
    object ListBox: TListBox
      Left = 0
      Top = 0
      Width = 120
      Height = 129
      ItemHeight = 13
      TabOrder = 8
      OnClick = ListBoxClick
    end
    object UserNameEdit: TLabeledEdit
      Left = 159
      Top = 10
      Width = 123
      Height = 21
      EditLabel.Width = 27
      EditLabel.Height = 26
      EditLabel.Caption = 'User'#13#10'Name'
      Enabled = False
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 9
    end
    object PasswordEdit: TLabeledEdit
      Left = 126
      Top = 123
      Width = 121
      Height = 21
      EditLabel.Width = 46
      EditLabel.Height = 13
      EditLabel.Caption = 'Password'
      Enabled = False
      PasswordChar = '*'
      TabOrder = 1
    end
    object EditUserBtn: TButton
      Left = 126
      Top = 69
      Width = 75
      Height = 25
      Caption = 'Edit User'
      TabOrder = 0
      OnClick = EditUserBtnClick
    end
    object SaveUserBtn: TButton
      Left = 207
      Top = 69
      Width = 75
      Height = 25
      Caption = 'Save User'
      Enabled = False
      TabOrder = 7
      OnClick = SaveUserBtnClick
    end
    object CancelEditBtn: TButton
      Left = 288
      Top = 69
      Width = 75
      Height = 25
      Caption = 'Cancel Edit'
      Enabled = False
      TabOrder = 6
      OnClick = CancelEditBtnClick
    end
    object AddUserBtn: TButton
      Left = 288
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Add User'
      TabOrder = 4
      OnClick = AddUserBtnClick
    end
    object AddTestItemBtn: TButton
      Left = 126
      Top = 39
      Width = 75
      Height = 25
      Hint = 'Add entry to TestItems.ini'
      Caption = 'Add TestItem'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      OnClick = AddTestItemBtnClick
    end
  end
  object ScFileStorage: TScFileStorage
    Left = 40
    Top = 210
  end
  object JvSelectDirectory: TJvSelectDirectory
    Left = 128
    Top = 210
  end
end
