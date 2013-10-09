object FrmSurfaces: TFrmSurfaces
  Left = 275
  Top = 197
  Caption = 'Superf'#237'cies'
  ClientHeight = 223
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 16
    Height = 13
    Caption = 'P1:'
  end
  object Label2: TLabel
    Left = 24
    Top = 48
    Width = 16
    Height = 13
    Caption = 'P2:'
  end
  object Label3: TLabel
    Left = 24
    Top = 72
    Width = 16
    Height = 13
    Caption = 'P3:'
  end
  object Label4: TLabel
    Left = 24
    Top = 96
    Width = 16
    Height = 13
    Caption = 'P4:'
  end
  object Label5: TLabel
    Left = 224
    Top = 24
    Width = 16
    Height = 13
    Caption = 'T1:'
  end
  object Label6: TLabel
    Left = 224
    Top = 48
    Width = 16
    Height = 13
    Caption = 'T2:'
  end
  object Label7: TLabel
    Left = 224
    Top = 72
    Width = 16
    Height = 13
    Caption = 'T3:'
  end
  object Label8: TLabel
    Left = 224
    Top = 96
    Width = 16
    Height = 13
    Caption = 'T4:'
  end
  object LbVoxelSize: TLabel
    Left = 72
    Top = 136
    Width = 305
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'Voxel Size is:'
  end
  object BtOK: TButton
    Left = 336
    Top = 192
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 248
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object SpP1x: TSpinEdit
    Left = 48
    Top = 24
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object SpP2x: TSpinEdit
    Left = 48
    Top = 48
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 3
    Value = 0
  end
  object SpP3x: TSpinEdit
    Left = 48
    Top = 72
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
  object SpP4x: TSpinEdit
    Left = 48
    Top = 96
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 5
    Value = 0
  end
  object SpP1y: TSpinEdit
    Left = 104
    Top = 24
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 6
    Value = 0
  end
  object SpP2y: TSpinEdit
    Left = 104
    Top = 48
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 7
    Value = 0
  end
  object SpP3y: TSpinEdit
    Left = 104
    Top = 72
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 8
    Value = 0
  end
  object SpP4y: TSpinEdit
    Left = 104
    Top = 96
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 9
    Value = 0
  end
  object SpP1z: TSpinEdit
    Left = 160
    Top = 24
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 10
    Value = 0
  end
  object SpP2z: TSpinEdit
    Left = 160
    Top = 48
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 11
    Value = 0
  end
  object SpP3z: TSpinEdit
    Left = 160
    Top = 72
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 12
    Value = 0
  end
  object SpP4z: TSpinEdit
    Left = 160
    Top = 96
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 13
    Value = 0
  end
  object SpT1x: TSpinEdit
    Left = 248
    Top = 24
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 14
    Value = 0
  end
  object SpT2x: TSpinEdit
    Left = 248
    Top = 48
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 15
    Value = 0
  end
  object SpT3x: TSpinEdit
    Left = 248
    Top = 72
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 16
    Value = 0
  end
  object SpT4x: TSpinEdit
    Left = 248
    Top = 96
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 17
    Value = 0
  end
  object SpT1y: TSpinEdit
    Left = 304
    Top = 24
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 18
    Value = 0
  end
  object SpT2y: TSpinEdit
    Left = 304
    Top = 48
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 19
    Value = 0
  end
  object SpT3y: TSpinEdit
    Left = 304
    Top = 72
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 20
    Value = 0
  end
  object SpT4y: TSpinEdit
    Left = 304
    Top = 96
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 21
    Value = 0
  end
  object SpT1z: TSpinEdit
    Left = 360
    Top = 24
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 22
    Value = 0
  end
  object SpT2z: TSpinEdit
    Left = 360
    Top = 48
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 23
    Value = 0
  end
  object SpT3z: TSpinEdit
    Left = 360
    Top = 72
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 24
    Value = 0
  end
  object SpT4z: TSpinEdit
    Left = 360
    Top = 96
    Width = 49
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 25
    Value = 0
  end
end
