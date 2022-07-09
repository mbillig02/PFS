object SettingsForm: TSettingsForm
  Left = 0
  Top = 0
  Caption = 'Settings'
  ClientHeight = 311
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object JvSettingsTreeView: TJvSettingsTreeView
    Left = 0
    Top = 0
    Width = 97
    Height = 311
    PageDefault = 0
    PageList = JvPageList
    Align = alLeft
    Indent = 19
    TabOrder = 0
    Items.NodeData = {
      030900000032000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000020000
      0000000000010A4100750074006F0020005300740061007200740034000000FF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000300000000000000010B440069
      0072006500630074006F00720069006500730026000000FFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFF000000000100000000000000010446006F0072006D00260000
      00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000040000000000000001044B
      0065007900730038000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000006
      00000000000000010D4D0069007300630065006C006C0061006E0065006F0075
      00730034000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000700000000
      000000010B52006F006F007400200041006300630065007300730036000000FF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000800000000000000010C530046
      005400500020004F007000740069006F006E0073002A000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF00000000000000000000000001065300740079006C0065
      00730030000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000500000000
      000000010954006500730074004900740065006D007300}
    Items.Links = {
      0900000002000000030000000100000004000000060000000700000008000000
      0000000005000000}
  end
  object JvPageList: TJvPageList
    Left = 97
    Top = 0
    Width = 337
    Height = 311
    ActivePage = JvStandardPageMiscellaneous
    PropagateEnable = False
    Align = alClient
    object JvStandardPageStyles: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageStyles'
      object StylesListBox: TListBox
        Left = 24
        Top = 24
        Width = 121
        Height = 193
        ItemHeight = 13
        TabOrder = 0
        OnClick = StylesListBoxClick
      end
    end
    object JvStandardPageForm: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPage (Form)'
      object SetDefaultScrrenBtn: TButton
        Left = 17
        Top = 24
        Width = 121
        Height = 25
        Caption = 'Set Default Scrren'
        TabOrder = 0
        OnClick = SetDefaultScrrenBtnClick
      end
      object SetAlomstFullScreenBtn: TButton
        Left = 17
        Top = 64
        Width = 121
        Height = 25
        Caption = 'Set Alomst Full Screen'
        TabOrder = 1
        OnClick = SetAlomstFullScreenBtnClick
      end
      object SavFrmSizChkBox: TCheckBox
        Left = 17
        Top = 112
        Width = 97
        Height = 17
        Caption = 'Save form size'
        TabOrder = 2
        OnClick = SavFrmSizChkBoxClick
      end
      object SavFrmPosChkBox: TCheckBox
        Left = 17
        Top = 152
        Width = 113
        Height = 17
        Caption = 'Save form position'
        TabOrder = 3
        OnClick = SavFrmPosChkBoxClick
      end
      inline TScrPosFrame: TScrPosFrame
        Left = 9
        Top = 183
        Width = 185
        Height = 65
        TabOrder = 4
        ExplicitLeft = 9
        ExplicitTop = 183
        inherited SpinEditLeft: TSpinEdit
          OnChange = TScrPosFrameSpinEditLeftChange
        end
        inherited SpinEditTop: TSpinEdit
          OnChange = TScrPosFrameSpinEditTopChange
        end
        inherited SpinEditHeight: TSpinEdit
          OnChange = TScrPosFrameSpinEditHeightChange
        end
        inherited SpinEditWidth: TSpinEdit
          OnChange = TScrPosFrameSpinEditWidthChange
        end
      end
      object MainFormSettingsListBox: TListBox
        Left = 147
        Top = 24
        Width = 178
        Height = 153
        ItemHeight = 13
        TabOrder = 5
      end
      object MainFormSettingsToListBoxBtn: TButton
        Left = 229
        Top = 191
        Width = 96
        Height = 25
        Caption = 'Get (To ListBox)'
        TabOrder = 6
        OnClick = MainFormSettingsToListBoxBtnClick
      end
      object MainFormSettingsToFormBtn: TButton
        Left = 229
        Top = 222
        Width = 96
        Height = 25
        Caption = 'Set (To Form)'
        TabOrder = 7
        OnClick = MainFormSettingsToFormBtnClick
      end
      object DeleteListBoxItemBtn: TButton
        Left = 229
        Top = 253
        Width = 96
        Height = 25
        Caption = 'Delete'
        TabOrder = 8
        OnClick = DeleteListBoxItemBtnClick
      end
    end
    object JvStandardPageAutoStart: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageAutoStart'
      object AutoStartNoParmsGroupBox: TGroupBox
        Left = 6
        Top = 3
        Width = 155
        Height = 87
        Caption = 'AutoStart No Parms'
        TabOrder = 0
        object AutoStartFtpChkBox: TCheckBox
          Left = 32
          Top = 24
          Width = 97
          Height = 17
          Caption = 'AutoStart ftp'
          TabOrder = 0
        end
        object AutoStartSftpChkBox: TCheckBox
          Left = 32
          Top = 56
          Width = 97
          Height = 17
          Caption = 'AutoStart sftp'
          TabOrder = 1
        end
      end
      object AutoStartWithParmsGroupBox: TGroupBox
        Left = 6
        Top = 96
        Width = 155
        Height = 87
        Caption = 'AutoStart With Parms'
        TabOrder = 1
        object AutoStartFtpParmsChkBox: TCheckBox
          Left = 32
          Top = 24
          Width = 97
          Height = 17
          Caption = 'AutoStart ftp'
          TabOrder = 0
        end
        object AutoStartSftpParmsChkBox: TCheckBox
          Left = 32
          Top = 56
          Width = 97
          Height = 17
          Caption = 'AutoStart sftp'
          TabOrder = 1
        end
      end
    end
    object JvStandardPageDirectories: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageDirectories'
      object DtaDirGrpBox: TGroupBox
        Left = 0
        Top = 0
        Width = 337
        Height = 102
        Align = alTop
        Caption = 'DtaDir'
        TabOrder = 0
        object DtaDirLbl: TLabel
          Left = 8
          Top = 16
          Width = 43
          Height = 13
          Caption = 'DtaDirLbl'
        end
        object DtaDirCopyToClpBrdBtn: TButton
          Left = 7
          Top = 34
          Width = 104
          Height = 25
          Caption = 'Copy to Clipboard'
          TabOrder = 0
          OnClick = DtaDirCopyToClpBrdBtnClick
        end
        object DtaDirOpenInExplorerBtn: TButton
          Left = 7
          Top = 65
          Width = 104
          Height = 25
          Caption = 'Open in Explorer'
          TabOrder = 1
          OnClick = DtaDirOpenInExplorerBtnClick
        end
      end
      object TmpDirGrpBox: TGroupBox
        Left = 0
        Top = 204
        Width = 337
        Height = 102
        Align = alTop
        Caption = 'TmpDir'
        TabOrder = 1
        object TmpDirLbl: TLabel
          Left = 8
          Top = 16
          Width = 46
          Height = 13
          Caption = 'TmpDirLbl'
        end
        object TmpDirCopyToClpBrdBtn: TButton
          Left = 7
          Top = 34
          Width = 104
          Height = 25
          Caption = 'Copy to Clipboard'
          TabOrder = 0
          OnClick = TmpDirCopyToClpBrdBtnClick
        end
        object TmpDirOpenInExplorerBtn: TButton
          Left = 7
          Top = 65
          Width = 104
          Height = 25
          Caption = 'Open in Explorer'
          TabOrder = 1
          OnClick = TmpDirOpenInExplorerBtnClick
        end
      end
      object LogDirGrpBox: TGroupBox
        Left = 0
        Top = 102
        Width = 337
        Height = 102
        Align = alTop
        Caption = 'LogDir'
        TabOrder = 2
        object LogDirLbl: TLabel
          Left = 8
          Top = 16
          Width = 43
          Height = 13
          Caption = 'LogDirLbl'
        end
        object LogDirCopyToClpBrdBtn: TButton
          Left = 7
          Top = 34
          Width = 104
          Height = 25
          Caption = 'Copy to Clipboard'
          TabOrder = 0
          OnClick = LogDirCopyToClpBrdBtnClick
        end
        object LogDirOpenInExplorerBtn: TButton
          Left = 7
          Top = 65
          Width = 104
          Height = 25
          Caption = 'Open in Explorer'
          TabOrder = 1
          OnClick = LogDirOpenInExplorerBtnClick
        end
        object DebugGroupBox: TGroupBox
          Left = 120
          Top = 29
          Width = 100
          Height = 34
          Caption = 'Debug'
          TabOrder = 2
          object DebugScreenCheckBox: TCheckBox
            Left = 6
            Top = 13
            Width = 52
            Height = 17
            Caption = 'Screen'
            TabOrder = 0
          end
          object DebugFileCheckBox: TCheckBox
            Left = 64
            Top = 13
            Width = 34
            Height = 17
            Caption = 'File'
            TabOrder = 1
          end
        end
        object InfoGroupBox: TGroupBox
          Left = 226
          Top = 29
          Width = 100
          Height = 34
          Caption = 'Info'
          TabOrder = 3
          object InfoScreenCheckBox: TCheckBox
            Left = 6
            Top = 13
            Width = 52
            Height = 17
            Caption = 'Screen'
            TabOrder = 0
          end
          object InfoFileCheckBox: TCheckBox
            Left = 64
            Top = 13
            Width = 34
            Height = 17
            Caption = 'File'
            TabOrder = 1
          end
        end
        object ErrorGroupBox: TGroupBox
          Left = 120
          Top = 62
          Width = 100
          Height = 34
          Caption = 'Error'
          TabOrder = 4
          object ErrorScreenCheckBox: TCheckBox
            Left = 6
            Top = 13
            Width = 52
            Height = 17
            Caption = 'Screen'
            TabOrder = 0
          end
          object ErrorFileCheckBox: TCheckBox
            Left = 64
            Top = 13
            Width = 34
            Height = 17
            Caption = 'File'
            TabOrder = 1
          end
        end
        object WarningGroupBox: TGroupBox
          Left = 226
          Top = 62
          Width = 100
          Height = 34
          Caption = 'Warning'
          TabOrder = 5
          object WarningScreenCheckBox: TCheckBox
            Left = 6
            Top = 13
            Width = 52
            Height = 17
            Caption = 'Screen'
            TabOrder = 0
          end
          object WarningFileCheckBox: TCheckBox
            Left = 64
            Top = 13
            Width = 34
            Height = 17
            Caption = 'File'
            TabOrder = 1
          end
        end
      end
    end
    object JvStandardPageKeys: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageKeys'
      object KeysMemo: TMemo
        Left = 0
        Top = 103
        Width = 337
        Height = 208
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object KeysPanel: TPanel
        Left = 0
        Top = 0
        Width = 337
        Height = 103
        Align = alTop
        TabOrder = 1
        object ExportDsaPublicKeyBtn: TButton
          Left = 6
          Top = 8
          Width = 137
          Height = 25
          Hint = 'Export DSA Public Key to TmpDir'
          Caption = 'Export DSA Public Key'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = ExportDsaPublicKeyBtnClick
        end
        object ExportEcPublicKeyBtn: TButton
          Left = 6
          Top = 39
          Width = 137
          Height = 25
          Hint = 'Export EC Public Key to TmpDir'
          Caption = 'Export EC Public Key'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = ExportEcPublicKeyBtnClick
        end
        object ExportRsaPublicKeyBtn: TButton
          Left = 6
          Top = 70
          Width = 137
          Height = 25
          Hint = 'Export RSA Public Key to TmpDir'
          Caption = 'Export RSA Public Key'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = ExportRsaPublicKeyBtnClick
        end
      end
    end
    object JvStandardPageTestItems: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageTestItems'
      object CreateTestItemsBtn: TButton
        Left = 24
        Top = 24
        Width = 129
        Height = 25
        Caption = 'Create Test Items'
        TabOrder = 0
        OnClick = CreateTestItemsBtnClick
      end
      object CreateTestItemsINIBtn: TButton
        Left = 24
        Top = 55
        Width = 129
        Height = 25
        Caption = 'Create TestItems.INI'
        TabOrder = 1
        OnClick = CreateTestItemsINIBtnClick
      end
      object AutoCreateTestItemsChkBox: TCheckBox
        Left = 24
        Top = 96
        Width = 145
        Height = 17
        Caption = 'Auto Create Test Items'
        TabOrder = 2
      end
    end
    object JvStandardPageMiscellaneous: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageMiscellaneous'
      object IPAddressInfoGrpBox: TGroupBox
        Left = 0
        Top = 0
        Width = 185
        Height = 105
        Caption = 'IP Address Info'
        TabOrder = 0
        object IPInfoMemo: TMemo
          Left = 2
          Top = 15
          Width = 181
          Height = 88
          Align = alClient
          TabOrder = 0
        end
      end
      object UsersRefreshBtn: TButton
        Left = 16
        Top = 120
        Width = 89
        Height = 25
        Caption = 'Users Refresh'
        TabOrder = 1
        OnClick = UsersRefreshBtnClick
      end
      object EnableRealtimeStatusChkBox: TCheckBox
        Left = 32
        Top = 264
        Width = 140
        Height = 17
        Caption = 'Enable Realtime Status'
        TabOrder = 2
      end
      object UpdateIntervalSpinEdit: TSpinEdit
        Left = 200
        Top = 262
        Width = 121
        Height = 22
        Increment = 100
        MaxValue = 5000
        MinValue = 100
        TabOrder = 3
        Value = 100
        OnChange = UpdateIntervalSpinEditChange
      end
    end
    object JvStandardPageRootAccess: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageRootAccess'
      object RootAccessStatusLbl: TLabel
        Left = 192
        Top = 32
        Width = 31
        Height = 13
        Caption = 'Status'
      end
      object RootAccessListBox: TListBox
        Left = 24
        Top = 24
        Width = 121
        Height = 97
        ItemHeight = 13
        TabOrder = 0
        OnClick = RootAccessListBoxClick
      end
    end
    object JvStandardPageSFTPOptions: TJvStandardPage
      Left = 0
      Top = 0
      Width = 337
      Height = 311
      Caption = 'JvStandardPageSFTPOptions'
      object GatherFilePermissionsChkBox: TCheckBox
        Left = 32
        Top = 24
        Width = 145
        Height = 17
        Caption = 'Gather File Permissions'
        TabOrder = 0
        OnClick = GatherFilePermissionsChkBoxClick
      end
      object LogFileReadChkBox: TCheckBox
        Left = 32
        Top = 47
        Width = 97
        Height = 17
        Caption = 'Log File Read'
        TabOrder = 1
        OnClick = LogFileReadChkBoxClick
      end
      object LogReadDirFileInfoChkBox: TCheckBox
        Left = 32
        Top = 70
        Width = 130
        Height = 17
        Caption = 'Log Read Dir File Info'
        TabOrder = 2
        OnClick = LogReadDirFileInfoChkBoxClick
      end
      object HidePhysicalPathChkBox: TCheckBox
        Left = 32
        Top = 93
        Width = 113
        Height = 17
        Caption = 'Hide Physical Path'
        TabOrder = 3
      end
      object DisplayFileOpenModeChkBox: TCheckBox
        Left = 32
        Top = 176
        Width = 129
        Height = 17
        Caption = 'Display File Open Mode'
        TabOrder = 4
      end
      object DisplayDebugInfoChkBox: TCheckBox
        Left = 32
        Top = 199
        Width = 113
        Height = 17
        Caption = 'Display Debug Info'
        TabOrder = 5
      end
      object DisplayDesiredAccessChkBox: TCheckBox
        Left = 32
        Top = 222
        Width = 150
        Height = 17
        Caption = 'Display Desired Access'
        TabOrder = 6
      end
    end
  end
  object DtaDirJvBalloonHint: TJvBalloonHint
    Left = 256
    Top = 40
  end
  object TmpDirJvBalloonHint: TJvBalloonHint
    Left = 256
    Top = 240
  end
  object LogDirJvBalloonHint: TJvBalloonHint
    Left = 256
    Top = 136
  end
end
