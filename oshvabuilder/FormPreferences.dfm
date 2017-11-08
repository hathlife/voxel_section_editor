object FrmPreferences: TFrmPreferences
  Left = 192
  Top = 107
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = ' '
  ClientHeight = 431
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
    Top = 377
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object GbOptionsBox: TGroupBox
    Left = 176
    Top = 88
    Width = 297
    Height = 265
    Caption = 'File Association'
    TabOrder = 0
    object pcOptions: TPageControl
      Left = 8
      Top = 16
      Width = 273
      Height = 241
      ActivePage = FileAssociationTab
      Style = tsFlatButtons
      TabOrder = 0
      object FileAssociationTab: TTabSheet
        Caption = 'File_association_tab'
        TabVisible = False
        object cbAssociate: TCheckBox
          Left = 0
          Top = 8
          Width = 209
          Height = 17
          Caption = 'Associate *.hva files with HVA Builder'
          TabOrder = 0
        end
        object gbAssociationIcon: TGroupBox
          Left = 0
          Top = 32
          Width = 113
          Height = 89
          Caption = 'Icon'
          TabOrder = 1
          object IconPrev: TImage
            Left = 40
            Top = 16
            Width = 57
            Height = 57
            Center = True
          end
          object IconID: TTrackBar
            Left = 8
            Top = 16
            Width = 25
            Height = 65
            Max = 3
            Orientation = trVertical
            PageSize = 1
            TabOrder = 0
            OnChange = IconIDChange
          end
        end
        object btnApply: TButton
          Left = 184
          Top = 208
          Width = 81
          Height = 22
          Caption = '&Apply'
          TabOrder = 2
          Visible = False
          OnClick = btnApplyClick
        end
      end
      object Palette_tab: TTabSheet
        Caption = 'Palette_tab'
        ImageIndex = 1
        TabVisible = False
        object lblTiberianSunPalette: TLabel
          Left = 24
          Top = 24
          Width = 184
          Height = 13
          Caption = 'Select a palette to use for Tiberian Sun'
          Enabled = False
        end
        object lblRedAlert2Palette: TLabel
          Left = 24
          Top = 72
          Width = 177
          Height = 13
          Caption = 'Select a palette to use for Red Alert 2'
          Enabled = False
        end
        object cbUseNameSpecificPalettes: TCheckBox
          Left = 0
          Top = 0
          Width = 177
          Height = 17
          Caption = 'Use game specific palettes'
          TabOrder = 0
          OnClick = cbUseNameSpecificPalettesClick
        end
        object cbRedAlert2Palette: TComboBoxEx
          Left = 32
          Top = 88
          Width = 177
          Height = 22
          ItemsEx = <>
          Enabled = False
          ItemHeight = 16
          TabOrder = 1
        end
        object cbTiberianSunPalette: TComboBoxEx
          Left = 32
          Top = 40
          Width = 177
          Height = 22
          ItemsEx = <>
          Enabled = False
          ItemHeight = 16
          TabOrder = 2
        end
      end
      object Rendering_tab: TTabSheet
        Caption = 'Rendering_tab'
        ImageIndex = 2
        TabVisible = False
        object cbFPSCap: TCheckBox
          Left = 16
          Top = 16
          Width = 246
          Height = 17
          Caption = 'Cap rendering speed to 60 frames per second.'
          TabOrder = 0
        end
      end
    end
  end
  object Pref_List: TTreeView
    Left = 16
    Top = 80
    Width = 145
    Height = 281
    Indent = 19
    TabOrder = 1
    OnClick = Pref_ListClick
    OnKeyDown = Pref_ListKeyUp
    OnKeyPress = Pref_ListKeyPress
    OnKeyUp = Pref_ListKeyUp
    Items.NodeData = {
      01030000003B0000000000000001000000FFFFFFFFFFFFFFFF00000000000000
      0011460069006C00650020004100730073006F00630069006100740069006F00
      6E007300370000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      0F500061006C00650074007400650020004F007000740069006F006E0073003B
      0000000000000000000000FFFFFFFFFFFFFFFF00000000000000001152006500
      6E0064006500720069006E00670020004F007000740069006F006E007300}
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 490
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 2
    object ImgPreferences: TImage
      Left = 0
      Top = 0
      Width = 490
      Height = 58
      Align = alClient
    end
    object lblPreferencesDescription: TLabel
      Left = 24
      Top = 24
      Width = 209
      Height = 13
      Caption = 'Here you can set the settings of the program'
      Transparent = True
    end
    object lblPreferences: TLabel
      Left = 8
      Top = 8
      Width = 69
      Height = 13
      Caption = 'Preferences'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 385
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnOK: TButton
      Left = 327
      Top = 11
      Width = 75
      Height = 23
      Caption = 'Ok'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 408
      Top = 11
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
