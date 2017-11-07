object FrmTransformManager_New: TFrmTransformManager_New
  Left = 196
  Top = 171
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
  object Label13: TLabel
    Left = 24
    Top = 80
    Width = 122
    Height = 13
    Caption = 'Transformation matrix'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
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
      Width = 305
      Height = 13
      Caption = 'Below you can manualy set the hva of the current sections frame'
      Transparent = True
    end
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 110
      Height = 13
      Caption = 'Transform Manager'
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
  object grdTrans: TStringGrid
    Left = 32
    Top = 95
    Width = 284
    Height = 63
    BorderStyle = bsNone
    ColCount = 4
    DefaultColWidth = 70
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 3
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
    ScrollBars = ssHorizontal
    TabOrder = 2
  end
end
