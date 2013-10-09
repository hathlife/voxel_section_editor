object FrmTopologyAnalysis: TFrmTopologyAnalysis
  Left = 0
  Top = 0
  Caption = 'Topology Analysis'
  ClientHeight = 510
  ClientWidth = 449
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    449
    510)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel4: TBevel
    Left = 16
    Top = 474
    Width = 425
    Height = 3
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 302
    ExplicitWidth = 402
  end
  object BtOK: TButton
    Left = 366
    Top = 483
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
    ExplicitLeft = 343
    ExplicitTop = 311
  end
  object GbCollectedData: TGroupBox
    Left = 8
    Top = 75
    Width = 433
    Height = 137
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Collected Data:'
    TabOrder = 1
    DesignSize = (
      433
      137)
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
      Width = 173
      Height = 13
      Caption = 'Manifold Voxels, 2 Possible Normals:'
    end
    object Label3: TLabel
      Left = 16
      Top = 54
      Width = 178
      Height = 13
      Caption = 'Manifold Voxels, Ambiguous Normals:'
    end
    object Label4: TLabel
      Left = 16
      Top = 73
      Width = 101
      Height = 13
      Caption = 'Non-Manifold Voxels:'
    end
    object Label5: TLabel
      Left = 16
      Top = 92
      Width = 61
      Height = 13
      Caption = 'Lone Voxels:'
    end
    object LbLoneVoxels: TLabel
      Left = 208
      Top = 92
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object Lb3Faces: TLabel
      Left = 208
      Top = 73
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object Lb2Faces: TLabel
      Left = 208
      Top = 54
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object Lb1Face: TLabel
      Left = 208
      Top = 35
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LbCorrectVoxels: TLabel
      Left = 208
      Top = 16
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object Label6: TLabel
      Left = 16
      Top = 120
      Width = 62
      Height = 13
      Caption = 'Total Voxels:'
    end
    object Bevel2: TBevel
      Left = 3
      Top = 111
      Width = 427
      Height = 3
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object LbTotalVoxels: TLabel
      Left = 208
      Top = 120
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
  end
  object GbAnalysis: TGroupBox
    Left = 8
    Top = 225
    Width = 433
    Height = 51
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Analysis:'
    TabOrder = 2
    DesignSize = (
      433
      51)
    object Label7: TLabel
      Left = 16
      Top = 16
      Width = 78
      Height = 13
      Caption = 'Topology Score:'
    end
    object LbTopologyScore: TLabel
      Left = 208
      Top = 16
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object LbClassification: TLabel
      Left = 208
      Top = 35
      Width = 208
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object Label8: TLabel
      Left = 16
      Top = 35
      Width = 66
      Height = 13
      Caption = 'Classification:'
    end
  end
  object GbExplanation: TGroupBox
    Left = 8
    Top = 293
    Width = 433
    Height = 172
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Explanation'
    TabOrder = 3
    ExplicitHeight = 138
    DesignSize = (
      433
      172)
    object Label9: TLabel
      Left = 16
      Top = 17
      Width = 400
      Height = 41
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'In a manifold voxel model, every voxel must have one single surf' +
        'ace normal direction. The topology analisys verifies every voxel' +
        ' in the surface follows this rule by checking their face neighbo' +
        'urs.'
      WordWrap = True
    end
    object Label10: TLabel
      Left = 16
      Top = 73
      Width = 400
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'The Topology Score is calculated in the following way:'
      WordWrap = True
    end
    object Label11: TLabel
      Left = 16
      Top = 96
      Width = 414
      Height = 26
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'TopologyScore =  ((Correct Voxels  - (Manifold Voxels w/ Ambiguo' +
        'us Normals + 2*Non-Manifold Voxels)) * 100) / Total Voxels'
      WordWrap = True
    end
    object Label12: TLabel
      Left = 16
      Top = 136
      Width = 400
      Height = 25
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'The Cubed Autonormals will work perfectly if the Topology Score ' +
        'is 100, while the 3D Modelizer will work perfectly if the model ' +
        'only has manifold voxels.'
      WordWrap = True
    end
  end
  object GroupBox1: TGroupBox
    Left = 9
    Top = 8
    Width = 432
    Height = 57
    Caption = 'Target:'
    TabOrder = 4
    object RbWholeModel: TRadioButton
      Left = 24
      Top = 16
      Width = 113
      Height = 17
      Caption = 'Whole Model'
      TabOrder = 0
      OnClick = RbWholeModelClick
    end
    object RbJustSection: TRadioButton
      Left = 24
      Top = 32
      Width = 113
      Height = 17
      Caption = 'Just the section:'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = RbJustSectionClick
    end
    object CbSections: TComboBox
      Left = 143
      Top = 30
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 0
      TabOrder = 2
      OnChange = CbSectionsChange
    end
  end
end
