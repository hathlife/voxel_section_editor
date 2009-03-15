object FrmCameraManager_New: TFrmCameraManager_New
  Left = 195
  Top = 272
  BorderStyle = bsDialog
  Caption = ' '
  ClientHeight = 311
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
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
  object Label7: TLabel
    Left = 24
    Top = 104
    Width = 28
    Height = 22
    AutoSize = False
    Caption = 'XRot'
    Layout = tlCenter
  end
  object Label8: TLabel
    Left = 24
    Top = 128
    Width = 31
    Height = 22
    AutoSize = False
    Caption = 'YRot'
    Layout = tlCenter
  end
  object Label9: TLabel
    Left = 24
    Top = 152
    Width = 31
    Height = 22
    AutoSize = False
    Caption = 'Depth'
    Layout = tlCenter
  end
  object Panel2: TPanel
    Left = 0
    Top = 265
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
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
      Width = 158
      Height = 14
      Caption = 'Select the position of the camera'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 96
      Height = 13
      Caption = 'Camera Manager'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object XRot: TEdit
    Left = 64
    Top = 104
    Width = 105
    Height = 22
    TabOrder = 2
  end
  object YRot: TEdit
    Left = 64
    Top = 128
    Width = 105
    Height = 22
    TabOrder = 3
  end
  object Depth: TEdit
    Left = 64
    Top = 152
    Width = 105
    Height = 22
    TabOrder = 4
  end
end
