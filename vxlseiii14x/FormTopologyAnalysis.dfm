object FrmTopologyAnalysis: TFrmTopologyAnalysis
  Left = 0
  Top = 0
  Caption = 'Topology Analysis'
  ClientHeight = 338
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 74
    Height = 13
    Caption = 'Correct Voxels:'
  end
  object Label2: TLabel
    Left = 16
    Top = 35
    Width = 141
    Height = 13
    Caption = 'Voxels w/ 2 Possible Normals:'
  end
  object Label3: TLabel
    Left = 16
    Top = 54
    Width = 173
    Height = 13
    Caption = 'Voxels w/ 3D Solid Possible Normals:'
  end
  object Label4: TLabel
    Left = 16
    Top = 73
    Width = 143
    Height = 13
    Caption = 'Voxels w/ Almost Any Normal:'
  end
  object Label5: TLabel
    Left = 16
    Top = 92
    Width = 61
    Height = 13
    Caption = 'Lone Voxels:'
  end
  object Bevel1: TBevel
    Left = 16
    Top = 108
    Width = 402
    Height = 3
    Shape = bsBottomLine
  end
  object Label6: TLabel
    Left = 16
    Top = 117
    Width = 62
    Height = 13
    Caption = 'Total Voxels:'
  end
  object Bevel2: TBevel
    Left = 16
    Top = 136
    Width = 402
    Height = 3
    Shape = bsBottomLine
  end
  object Label7: TLabel
    Left = 16
    Top = 145
    Width = 78
    Height = 13
    Caption = 'Topology Score:'
  end
  object Label8: TLabel
    Left = 16
    Top = 164
    Width = 66
    Height = 13
    Caption = 'Classification:'
  end
  object Bevel3: TBevel
    Left = 16
    Top = 183
    Width = 402
    Height = 3
    Shape = bsBottomLine
  end
  object Label9: TLabel
    Left = 16
    Top = 200
    Width = 402
    Height = 41
    AutoSize = False
    Caption = 
      'In a manifold volume, every voxel must have one single surface n' +
      'ormal direction. The topology analisys verifies every voxel in t' +
      'he surface follows this rule by checking if every axis has at le' +
      'ast one neighbour.'
    WordWrap = True
  end
  object Label10: TLabel
    Left = 16
    Top = 247
    Width = 402
    Height = 17
    AutoSize = False
    Caption = 'The Topology Score is calculated in the following way:'
    WordWrap = True
  end
  object Label11: TLabel
    Left = 16
    Top = 270
    Width = 402
    Height = 26
    AutoSize = False
    Caption = 
      'TopologyScore =  ((Correct Voxels  - (Voxels w/ 3D Solid Possibl' +
      'e Normals + 2*Voxels with Almost Any Normal)) * 100) / Total Vox' +
      'els'
    WordWrap = True
  end
  object Bevel4: TBevel
    Left = 16
    Top = 302
    Width = 402
    Height = 3
    Shape = bsBottomLine
  end
  object LbCorrectVoxels: TLabel
    Left = 240
    Top = 16
    Width = 145
    Height = 13
    AutoSize = False
  end
  object Lb1Face: TLabel
    Left = 240
    Top = 35
    Width = 145
    Height = 13
    AutoSize = False
  end
  object Lb2Faces: TLabel
    Left = 240
    Top = 54
    Width = 145
    Height = 13
    AutoSize = False
  end
  object Lb3Faces: TLabel
    Left = 240
    Top = 73
    Width = 145
    Height = 13
    AutoSize = False
  end
  object LbLoneVoxels: TLabel
    Left = 240
    Top = 92
    Width = 145
    Height = 13
    AutoSize = False
  end
  object LbTotalVoxels: TLabel
    Left = 240
    Top = 117
    Width = 145
    Height = 13
    AutoSize = False
  end
  object LbTopologyScore: TLabel
    Left = 240
    Top = 145
    Width = 145
    Height = 13
    AutoSize = False
  end
  object LbClassification: TLabel
    Left = 240
    Top = 164
    Width = 145
    Height = 13
    AutoSize = False
  end
  object BtOK: TButton
    Left = 343
    Top = 311
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
  end
end
