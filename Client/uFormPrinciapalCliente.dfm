object FormPrincipalCliente: TFormPrincipalCliente
  Left = 0
  Top = 0
  Caption = 'Expert Access Client'
  ClientHeight = 230
  ClientWidth = 615
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object mmo1: TMemo
    Left = 0
    Top = 0
    Width = 409
    Height = 230
    Align = alClient
    Lines.Strings = (
      'mmo1')
    TabOrder = 0
  end
  object pnl1: TPanel
    Left = 409
    Top = 0
    Width = 206
    Height = 230
    Align = alRight
    TabOrder = 1
    object btnConectar: TButton
      Left = 15
      Top = 54
      Width = 75
      Height = 25
      Caption = 'Conectar'
      TabOrder = 0
      OnClick = btnConectarClick
    end
    object edtIP: TEdit
      Left = 6
      Top = 16
      Width = 105
      Height = 21
      Alignment = taCenter
      NumbersOnly = True
      TabOrder = 1
      Text = '192.168.25.3'
      TextHint = 'Informe I.P.'
    end
    object edtPorta: TEdit
      Left = 117
      Top = 16
      Width = 68
      Height = 21
      Alignment = taCenter
      NumbersOnly = True
      TabOrder = 2
      Text = '3200'
      TextHint = 'Porta'
    end
    object btnInicial: TBitBtn
      Left = 112
      Top = 54
      Width = 75
      Height = 25
      Caption = 'Iniciar'
      TabOrder = 3
      OnClick = btnInicialClick
    end
  end
  object idtcpclntDesktop: TIdTCPClient
    OnDisconnected = idtcpclntDesktopDisconnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 552
    Top = 120
  end
  object idtcpclntTeclado: TIdTCPClient
    OnDisconnected = idtcpclntTecladoDisconnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 552
    Top = 168
  end
  object idtcpclntMouse: TIdTCPClient
    OnDisconnected = idtcpclntMouseDisconnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 464
    Top = 161
  end
end
