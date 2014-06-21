object FrmVoxelTexture: TFrmVoxelTexture
  Left = 301
  Top = 196
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Voxel Texture'
  ClientHeight = 398
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image2: TImage
    Left = 280
    Top = 232
    Width = 65
    Height = 65
    Visible = False
  end
  object Bevel2: TBevel
    Left = 0
    Top = 58
    Width = 490
    Height = 7
    Align = alTop
    Shape = bsTopLine
  end
  object Bevel3: TBevel
    Left = 0
    Top = 344
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Panel1: TPanel
    Left = 112
    Top = 72
    Width = 153
    Height = 265
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 151
      Height = 263
      Align = alClient
      Stretch = True
    end
  end
  object BtGetVoxelTexture: TButton
    Left = 272
    Top = 72
    Width = 105
    Height = 25
    Caption = 'Get Voxel Texture'
    TabOrder = 1
    Visible = False
    OnClick = BtGetVoxelTextureClick
  end
  object BtApplyTexture: TButton
    Left = 272
    Top = 96
    Width = 105
    Height = 25
    Caption = 'Apply Texture'
    TabOrder = 2
    Visible = False
    OnClick = BtApplyTextureClick
  end
  object BtLoadTexture: TButton
    Left = 272
    Top = 120
    Width = 105
    Height = 25
    Caption = 'Import Texture'
    TabOrder = 3
    OnClick = BtLoadTextureClick
  end
  object BtSaveTexture: TButton
    Left = 272
    Top = 144
    Width = 105
    Height = 25
    Caption = 'Export Texture'
    TabOrder = 4
    OnClick = BtSaveTextureClick
  end
  object BtSavePalette: TButton
    Left = 272
    Top = 176
    Width = 105
    Height = 25
    Caption = 'Save Palette'
    TabOrder = 5
    OnClick = BtSavePaletteClick
  end
  object CbPaintRemaining: TCheckBox
    Left = 272
    Top = 208
    Width = 218
    Height = 17
    Caption = 'Paint Remaining with Top/Bottom Colors'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 490
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 7
    object Image3: TImage
      Left = 0
      Top = 0
      Width = 490
      Height = 58
      Align = alClient
    end
    object Label2: TLabel
      Left = 24
      Top = 24
      Width = 206
      Height = 13
      Caption = 'Here you can apply a texture over the voxel'
      Transparent = True
    end
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 79
      Height = 13
      Caption = 'Voxel Texture'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 352
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 8
    object LbCurrentOperation: TLabel
      Left = 32
      Top = 4
      Width = 265
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Done'
      Visible = False
    end
    object BtOK: TButton
      Left = 327
      Top = 11
      Width = 75
      Height = 23
      Caption = 'Ok'
      TabOrder = 0
      OnClick = BtOKClick
    end
    object BtCancel: TButton
      Left = 408
      Top = 11
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = BtCancelClick
    end
    object ProgressBar: TProgressBar
      Left = 32
      Top = 17
      Width = 265
      Height = 16
      TabOrder = 2
      Visible = False
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    DefaultExt = 'bmp'
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 392
    Top = 160
  end
  object SavePictureDialog1: TSavePictureDialog
    DefaultExt = 'bmp'
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Left = 424
    Top = 160
  end
end
