object FrmHeightMap: TFrmHeightMap
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Import Image and Height Map as a New Section'
  ClientHeight = 210
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 323
    Height = 33
    AutoSize = False
    Caption = 
      'Select an image and its respective height map to import them as ' +
      'a new section.'
    WordWrap = True
  end
  object Bevel3: TBevel
    Left = 0
    Top = 156
    Width = 350
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
    ExplicitLeft = -142
    ExplicitTop = 178
    ExplicitWidth = 490
  end
  object Label2: TLabel
    Left = 17
    Top = 61
    Width = 53
    Height = 13
    Caption = 'Image File:'
  end
  object Label3: TLabel
    Left = 17
    Top = 108
    Width = 58
    Height = 13
    Caption = 'Height Map:'
  end
  object EdImage: TEdit
    Left = 17
    Top = 80
    Width = 233
    Height = 21
    ReadOnly = True
    TabOrder = 0
  end
  object BtBrowseImage: TButton
    Left = 265
    Top = 78
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = BtBrowseImageClick
  end
  object BtBrowseHeightmap: TButton
    Left = 265
    Top = 125
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 2
    OnClick = BtBrowseHeightmapClick
  end
  object EdHeightmap: TEdit
    Left = 16
    Top = 127
    Width = 233
    Height = 21
    ReadOnly = True
    TabOrder = 3
  end
  object Panel2: TPanel
    Left = 0
    Top = 164
    Width = 350
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 4
    object BtCancel: TButton
      Left = 183
      Top = 11
      Width = 75
      Height = 23
      Cancel = True
      Caption = '&Cancel'
      TabOrder = 0
      OnClick = BtCancelClick
    end
    object BtOK: TButton
      Left = 264
      Top = 11
      Width = 81
      Height = 23
      Caption = '&OK'
      Enabled = False
      TabOrder = 1
      OnClick = BtOKClick
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 
      'Image files supported by VXLSE (*.bmp,*.gif,*.jpg,*.jpeg,*.pcx,*' +
      '.png,*.tga)|*.bmp;*.gif;*.jpg;*.jpeg;*.pcx;*.png;*.tga|Bitmap (*' +
      '.bmp)|*.bmp|GIF (*.gif)|*.gif|J-PEG (*.jpg, *.jpeg)|*.jpg;*.jpeg' +
      '|PCX (*.pcx)|*.pcx|PNG (*.png)|*.png|Targa (*.tga)|*.TGA'
    Left = 280
    Top = 40
  end
end
