object FrmBumpMapping: TFrmBumpMapping
  Left = 0
  Top = 0
  Caption = 'Generate Bump Mapping'
  ClientHeight = 135
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    353
    135)
  PixelsPerInch = 96
  TextHeight = 13
  object LbThreshold: TLabel
    Left = 16
    Top = 16
    Width = 101
    Height = 13
    Caption = 'Bump Mapping Scale:'
  end
  object BvlBottomLine: TBevel
    Left = 0
    Top = 79
    Width = 344
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 48
    ExplicitWidth = 361
  end
  object Label1: TLabel
    Left = 21
    Top = 41
    Width = 315
    Height = 39
    Anchors = [akLeft, akRight, akBottom]
    Caption = 
      'Bump mapping textures distorts the normals in the texture of the' +
      ' model making it look bumpy. The scale determines the bumpiness ' +
      'of the surface. Use positive values.'
    WordWrap = True
  end
  object BtOK: TButton
    Left = 261
    Top = 101
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 180
    Top = 101
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object EdBump: TEdit
    Left = 128
    Top = 14
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '3'
  end
end
