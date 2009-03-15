object FrmScreenShotManager_New: TFrmScreenShotManager_New
  Left = 497
  Top = 275
  BorderStyle = bsDialog
  ClientHeight = 328
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
    Top = 274
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Label5: TLabel
    Left = 32
    Top = 96
    Width = 28
    Height = 22
    AutoSize = False
    Caption = 'Width'
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 32
    Top = 120
    Width = 31
    Height = 22
    AutoSize = False
    Caption = 'Height'
    Layout = tlCenter
  end
  object lblC100: TLabel
    Left = 156
    Top = 258
    Width = 18
    Height = 13
    Caption = '100'
    Enabled = False
  end
  object lblC1: TLabel
    Left = 28
    Top = 258
    Width = 6
    Height = 13
    AutoSize = False
    Caption = '1'
    Enabled = False
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
    Left = 24
    Top = 152
    Width = 39
    Height = 13
    Caption = 'Format'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 24
    Top = 224
    Width = 72
    Height = 13
    Caption = 'Compression'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 184
    Top = 96
    Width = 41
    Height = 22
    Caption = 'Reset'
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 184
    Top = 120
    Width = 41
    Height = 22
    Caption = 'Reset'
    OnClick = SpeedButton2Click
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
      Width = 230
      Height = 13
      Caption = 'Please define how you would like the screenshot'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 118
      Height = 13
      Caption = 'Screenshot Manager'
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
    Top = 282
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
    Left = 72
    Top = 96
    Width = 105
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object MainViewHeight: TSpinEdit
    Left = 72
    Top = 120
    Width = 105
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object RadioButton1: TRadioButton
    Left = 32
    Top = 168
    Width = 113
    Height = 17
    Caption = 'Bitmap'
    Checked = True
    TabOrder = 4
    TabStop = True
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 32
    Top = 184
    Width = 113
    Height = 17
    Caption = 'Jpg'
    TabOrder = 5
    OnClick = RadioButton1Click
  end
  object Compression: TTrackBar
    Left = 24
    Top = 240
    Width = 150
    Height = 17
    Enabled = False
    Max = 100
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 6
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsManual
  end
  object RadioButton3: TRadioButton
    Left = 32
    Top = 200
    Width = 137
    Height = 17
    Caption = 'Send to SHP Builder'
    TabOrder = 7
    OnClick = RadioButton1Click
  end
end
