object FTPForm: TFTPForm
  Left = 0
  Top = 0
  Caption = 'FTPForm'
  ClientHeight = 261
  ClientWidth = 563
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object FtpServer: TFtpServer
    Addr = '0.0.0.0'
    SocketFamily = sfIPv4
    Port = 'ftp'
    ListenBackLog = 5
    MultiListenSockets = <>
    Banner = '220 ICS FTP Server ready.'
    UserData = 0
    MaxClients = 0
    PasvPortRangeStart = 0
    PasvPortRangeSize = 0
    Options = [ftpsCwdCheck, ftpsCdupHome, ftpsSiteXmlsd]
    MD5UseThreadFileSize = 0
    TimeoutSecsLogin = 60
    TimeoutSecsIdle = 300
    TimeoutSecsXfer = 60
    ZlibMinLevel = 1
    ZlibMaxLevel = 9
    ZlibNoCompExt = '.zip;.rar;.7z;.cab;.lzh;.gz;.avi;.wmv;.mpg;.mp3;.jpg;.png;'
    AlloExtraSpace = 1000000
    ZlibMinSpace = 50000000
    ZlibMaxSize = 500000000
    CodePage = 0
    Language = 'EN*'
    MaxAttempts = 12
    BandwidthLimit = 0
    BandwidthSampling = 1000
    OnAuthenticate = FtpServerAuthenticate
    OnClientDisconnect = FtpServerClientDisconnect
    OnClientConnect = FtpServerClientConnect
    OnClientCommand = FtpServerClientCommand
    OnChangeDirectory = FtpServerChangeDirectory
    OnMakeDirectory = FtpServerMakeDirectory
    OnAlterDirectory = FtpServerAlterDirectory
    OnStorSessionConnected = FtpServerStorSessionConnected
    OnRetrSessionConnected = FtpServerRetrSessionConnected
    OnStorSessionClosed = FtpServerStorSessionClosed
    OnRetrSessionClosed = FtpServerRetrSessionClosed
    OnValidatePut = FtpServerValidatePut
    OnValidateDele = FtpServerValidateDele
    OnValidateRmd = FtpServerValidateRmd
    OnValidateRnFr = FtpServerValidateRnFr
    OnValidateGet = FtpServerValidateGet
    OnClntStr = FtpServerClntStr
    SocketErrs = wsErrTech
    ExclusiveAddr = True
    Left = 16
    Top = 16
  end
  object WSocket: TWSocket
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    ListenBacklog = 15
    SocketErrs = wsErrTech
    Left = 80
    Top = 16
  end
end