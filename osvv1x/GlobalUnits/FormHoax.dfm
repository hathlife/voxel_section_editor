object FrmHoax: TFrmHoax
  Left = 192
  Top = 106
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = ' '
  ClientHeight = 319
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 58
    Width = 490
    Height = 7
    Align = alTop
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 0
    Top = 265
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 490
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 490
      Height = 58
      Align = alClient
    end
    object Label1: TLabel
      Left = 24
      Top = 24
      Width = 122
      Height = 13
      Caption = 'Trial Version 15 Days Left'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 93
      Height = 13
      Caption = 'Application Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 273
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object ProgressBar1: TProgressBar
      Left = 16
      Top = 15
      Width = 377
      Height = 16
      Min = 0
      Max = 100
      TabOrder = 0
    end
    object Button2: TButton
      Left = 408
      Top = 11
      Width = 75
      Height = 23
      Caption = 'Ok'
      TabOrder = 1
      Visible = False
      OnClick = Button2Click
    end
  end
  object RichEdit1: TRichEdit
    Left = 24
    Top = 80
    Width = 449
    Height = 169
    BorderStyle = bsNone
    Color = clBtnFace
    Enabled = False
    Lines.Strings = (
      'Welcome to the PPM Voxel Viewer 1.3c 15 Trial.'
      ''
      
        'If you decide to purchase this product goto http://software.ppms' +
        'ite.com/ for more '
      'information.')
    PlainText = True
    ReadOnly = True
    TabOrder = 2
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 120
    Top = 128
  end
end
