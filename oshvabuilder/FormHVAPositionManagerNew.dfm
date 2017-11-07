object FrmHVAPositionManager_New: TFrmHVAPositionManager_New
  Left = 237
  Top = 239
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
    Width = 46
    Height = 13
    Caption = 'Position'
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
  object Label4: TLabel
    Left = 32
    Top = 144
    Width = 17
    Height = 22
    AutoSize = False
    Caption = 'Z'
    Layout = tlCenter
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
      Width = 242
      Height = 13
      Caption = 'Please enter the HVA position you would like below'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 128
      Height = 13
      Caption = 'HVA Position Manager'
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
  object PositionX: TEdit
    Left = 56
    Top = 144
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object PositionY: TEdit
    Left = 56
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object PositionZ: TEdit
    Left = 56
    Top = 120
    Width = 121
    Height = 21
    TabOrder = 4
  end
end
