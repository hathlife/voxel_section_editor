object FrmAniamtionManager_New: TFrmAniamtionManager_New
  Left = 388
  Top = 131
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
    Top = 257
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Label4: TLabel
    Left = 24
    Top = 80
    Width = 25
    Height = 13
    Caption = 'Size'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 32
    Top = 168
    Width = 41
    Height = 22
    AutoSize = False
    Caption = 'Frames'
    Layout = tlCenter
  end
  object Label8: TLabel
    Left = 24
    Top = 152
    Width = 27
    Height = 13
    Caption = 'Misc'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 184
    Top = 168
    Width = 41
    Height = 22
    AutoSize = False
    Caption = '/ 360'
    Layout = tlCenter
  end
  object SpeedButton1: TSpeedButton
    Left = 152
    Top = 96
    Width = 41
    Height = 22
    Caption = 'Reset'
    OnClick = SpeedButton1Click
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
      Width = 207
      Height = 13
      Caption = 'Please define the animation you want below'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 109
      Height = 13
      Caption = 'Animation Manager'
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
    Top = 265
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button4: TButton
      Left = 327
      Top = 11
      Width = 75
      Height = 23
      Caption = 'Ok'
      TabOrder = 0
      OnClick = Button4Click
    end
    object Button2: TButton
      Left = 408
      Top = 11
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object MainViewWidth: TSpinEdit
    Left = 40
    Top = 96
    Width = 105
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object Frames: TSpinEdit
    Left = 72
    Top = 168
    Width = 105
    Height = 22
    MaxValue = 360
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object AnimateCheckBox: TCheckBox
    Left = 30
    Top = 192
    Width = 55
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Animate'
    TabOrder = 4
  end
end
