object FrmVisualizadorPC: TFrmVisualizadorPC
  Left = 0
  Top = 0
  Caption = 'FrmVisualizadorPC'
  ClientHeight = 450
  ClientWidth = 586
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lblTeste: TLabel
    Left = 56
    Top = 24
    Width = 37
    Height = 13
    Caption = 'lblTeste'
  end
  object scrlbx1: TScrollBox
    Left = 0
    Top = 0
    Width = 586
    Height = 450
    HorzScrollBar.Smooth = True
    VertScrollBar.Smooth = True
    Align = alClient
    TabOrder = 0
    object imgDesktop: TImage
      Left = 22
      Top = 3
      Width = 318
      Height = 409
      AutoSize = True
      OnClick = imgDesktopClick
      OnDblClick = imgDesktopDblClick
      OnMouseDown = imgDesktopMouseDown
      OnMouseMove = imgDesktopMouseMove
      OnMouseUp = imgDesktopMouseUp
    end
  end
  object tmrMonitoraTeclado: TTimer
    Enabled = False
    Interval = 75
    OnTimer = tmrMonitoraTecladoTimer
    Left = 136
    Top = 16
  end
end
