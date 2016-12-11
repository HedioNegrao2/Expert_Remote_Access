object FormMainServer: TFormMainServer
  Left = 0
  Top = 0
  Caption = 'Servidor de Controle remoto de PC'
  ClientHeight = 408
  ClientWidth = 797
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 260
    Width = 797
    Height = 148
    Align = alBottom
    TabOrder = 0
    object mmoLog: TMemo
      Left = 1
      Top = 1
      Width = 656
      Height = 127
      Align = alClient
      Lines.Strings = (
        '')
      TabOrder = 0
    end
    object pnl3: TPanel
      Left = 657
      Top = 1
      Width = 139
      Height = 127
      Align = alRight
      Alignment = taLeftJustify
      TabOrder = 1
      object edtIP: TEdit
        Left = 6
        Top = 24
        Width = 121
        Height = 21
        Alignment = taCenter
        NumbersOnly = True
        TabOrder = 0
        Text = '192.168.25.3'
        TextHint = 'Informe I.P.'
      end
      object edtPorta: TEdit
        Left = 6
        Top = 60
        Width = 121
        Height = 21
        Alignment = taCenter
        NumbersOnly = True
        TabOrder = 1
        Text = '3200'
        TextHint = 'Porta'
      end
      object btnAtivar: TBitBtn
        Left = 14
        Top = 96
        Width = 113
        Height = 25
        Caption = 'Ativar'
        TabOrder = 2
        OnClick = btnAtivarClick
      end
    end
    object stat: TStatusBar
      Left = 1
      Top = 128
      Width = 795
      Height = 19
      Panels = <
        item
          Width = 300
        end
        item
          Width = 600
        end>
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 0
    Width = 797
    Height = 260
    Align = alClient
    TabOrder = 1
    object lvClientes: TListView
      Left = 1
      Top = 1
      Width = 795
      Height = 258
      Align = alClient
      Columns = <
        item
          Caption = 'Id'
        end
        item
          Caption = 'Nome'
          Width = 200
        end
        item
          Caption = 'Hora'
          Width = 80
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = lvClientesClick
    end
  end
  object idTCPServidor: TIdTCPServer
    OnStatus = idTCPServidorStatus
    Bindings = <>
    DefaultPort = 0
    OnConnect = idTCPServidorConnect
    OnDisconnect = idTCPServidorDisconnect
    OnExecute = idTCPServidorExecute
    Left = 240
    Top = 48
  end
end
