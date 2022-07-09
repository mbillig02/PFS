object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Portable FTP Server'
  ClientHeight = 289
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 143
    Width = 554
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 161
    ExplicitWidth = 47
  end
  object LogMemo: TMemo
    Left = 24
    Top = 176
    Width = 185
    Height = 89
    Lines.Strings = (
      'LogMemo')
    TabOrder = 3
  end
  object InfoMemo: TMemo
    Left = 0
    Top = 21
    Width = 554
    Height = 122
    Align = alTop
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitTop = 18
  end
  object StringGrid: TStringGrid
    Left = 0
    Top = 146
    Width = 554
    Height = 143
    Align = alClient
    ColCount = 4
    DefaultRowHeight = 15
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 1
  end
  object PathEdit: TEdit
    Left = 0
    Top = 0
    Width = 554
    Height = 21
    TabStop = False
    Align = alTop
    TabOrder = 2
    Text = 'C:\TEMP\'
    OnChange = PathEditChange
    OnDblClick = PathEditDblClick
  end
  object SaveDialog: TSaveDialog
    Left = 208
    Top = 40
  end
  object JvSelectDirectory: TJvSelectDirectory
    Left = 296
    Top = 40
  end
  object MainMenu: TMainMenu
    OnChange = MainMenuChange
    Left = 24
    Top = 40
    object mmisftp: TMenuItem
      AutoCheck = True
      Caption = 'sftp (stopped)'
      OnClick = mmisftpClick
    end
    object mmiftp: TMenuItem
      AutoCheck = True
      Caption = 'ftp (stopped)'
      OnClick = mmiftpClick
    end
    object mmiUserEditor: TMenuItem
      Caption = 'User Editor'
      OnClick = mmiUserEditorClick
    end
    object mmiStyles: TMenuItem
      Caption = 'Styles'
      Visible = False
    end
    object mmiSettings: TMenuItem
      Caption = 'Settings'
      OnClick = mmiSettingsClick
    end
    object mmiVersionAbout: TMenuItem
      Caption = 'About'
      OnClick = mmiVersionAboutClick
    end
  end
  object UpdateTimer: TTimer
    OnTimer = UpdateTimerTimer
    Left = 120
    Top = 40
  end
end
