object FrmAbout_New: TFrmAbout_New
  Left = 125
  Top = 62
  BorderStyle = bsDialog
  Caption = ' '
  ClientHeight = 311
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 0
    Top = 257
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Bevel1: TBevel
    Left = 0
    Top = 58
    Width = 490
    Height = 7
    Align = alTop
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 24
    Top = 144
    Width = 44
    Height = 13
    Caption = 'Websites'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 28
    Top = 176
    Width = 135
    Height = 15
    Cursor = crHandPoint
    Caption = 'https://www.ppmsite.com/'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ShowAccelChar = False
    OnClick = Label8Click
  end
  object Label8: TLabel
    Left = 28
    Top = 160
    Width = 147
    Height = 15
    Cursor = crHandPoint
    Caption = 'http://www.cnc-source.com/'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ShowAccelChar = False
    OnClick = Label8Click
  end
  object Label5: TLabel
    Left = 24
    Top = 80
    Width = 33
    Height = 13
    Caption = 'Engine'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 28
    Top = 96
    Width = 33
    Height = 15
    Caption = 'TITLE'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ShowAccelChar = False
  end
  object Label9: TLabel
    Left = 28
    Top = 112
    Width = 14
    Height = 15
    Caption = 'BY'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Comic Sans MS'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ShowAccelChar = False
  end
  object Panel2: TPanel
    Left = 0
    Top = 265
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button2: TButton
      Left = 408
      Top = 11
      Width = 75
      Height = 23
      Caption = 'Ok'
      TabOrder = 0
      OnClick = Button2Click
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 490
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 1
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
      Width = 84
      Height = 13
      Caption = 'Main program by: '
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
end
