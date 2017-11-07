object FrmBoundsManager_New: TFrmBoundsManager_New
  Left = 189
  Top = 106
  BorderStyle = bsDialog
  Caption = ' '
  ClientHeight = 340
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
    Top = 286
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Label3: TLabel
    Left = 24
    Top = 80
    Width = 35
    Height = 13
    Caption = 'Offset'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 32
    Top = 96
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'X'
    Layout = tlCenter
  end
  object Label6: TLabel
    Left = 32
    Top = 120
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'Y'
    Layout = tlCenter
  end
  object Label7: TLabel
    Left = 32
    Top = 144
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'Z'
    Layout = tlCenter
  end
  object Label8: TLabel
    Left = 24
    Top = 176
    Width = 76
    Height = 13
    Caption = 'Size In Game'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label9: TLabel
    Left = 32
    Top = 192
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'X'
    Layout = tlCenter
  end
  object Label10: TLabel
    Left = 32
    Top = 216
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'Y'
    Layout = tlCenter
  end
  object Label11: TLabel
    Left = 32
    Top = 240
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'Z'
    Layout = tlCenter
  end
  object SpeedButton1: TSpeedButton
    Left = 184
    Top = 240
    Width = 41
    Height = 22
    Caption = 'Reset'
  end
  object SpeedButton2: TSpeedButton
    Left = 184
    Top = 192
    Width = 41
    Height = 22
    Caption = 'Reset'
  end
  object SpeedButton3: TSpeedButton
    Left = 184
    Top = 216
    Width = 41
    Height = 22
    Caption = 'Reset'
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
      Width = 215
      Height = 13
      Caption = 'Please enter the offset and size of the section'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 96
      Height = 13
      Caption = 'Bounds Manager'
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
    Top = 294
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
  object XOffset: TEdit
    Left = 56
    Top = 144
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object YOffset: TEdit
    Left = 56
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object ZOffset: TEdit
    Left = 56
    Top = 120
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object SizeX: TEdit
    Left = 56
    Top = 240
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object SizeY: TEdit
    Left = 56
    Top = 192
    Width = 121
    Height = 21
    TabOrder = 6
  end
  object SizeZ: TEdit
    Left = 56
    Top = 216
    Width = 121
    Height = 21
    TabOrder = 7
  end
end
