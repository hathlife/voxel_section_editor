object FrmOptimizeMesh: TFrmOptimizeMesh
  Left = 0
  Top = 0
  Caption = 'Optimize Mesh'
  ClientHeight = 164
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    345
    164)
  PixelsPerInch = 96
  TextHeight = 13
  object LbThreshold: TLabel
    Left = 16
    Top = 16
    Width = 95
    Height = 13
    Caption = 'Normals Max Angle:'
  end
  object BvlBottomLine: TBevel
    Left = 0
    Top = 110
    Width = 345
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 48
    ExplicitWidth = 361
  end
  object Label1: TLabel
    Left = 21
    Top = 73
    Width = 316
    Height = 39
    Anchors = [akLeft, akRight, akBottom]
    Caption = 
      'Optimize Mesh reduces the amount of vertexes and faces in a 3D g' +
      'eometry. The angle determines the maximum angle where a face can' +
      ' be merged. Use angles between  0 and 180.'
    WordWrap = True
  end
  object BtOK: TButton
    Left = 262
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 181
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object cbIgnoreColours: TCheckBox
    Left = 16
    Top = 41
    Width = 289
    Height = 17
    Caption = 'Ignore Material Colours (Use it on textured models)'
    TabOrder = 2
  end
  object EdThreshold: TEdit
    Left = 128
    Top = 14
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '0'
  end
end
