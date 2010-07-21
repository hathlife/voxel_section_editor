object FrmGenerateDiffuseTexture: TFrmGenerateDiffuseTexture
  Left = 0
  Top = 0
  Caption = 'Diffuse Texture Generation Settings'
  ClientHeight = 190
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
    190)
  PixelsPerInch = 96
  TextHeight = 13
  object LbThreshold: TLabel
    Left = 16
    Top = 16
    Width = 80
    Height = 13
    Caption = 'Face Max Angle:'
  end
  object BvlBottomLine: TBevel
    Left = 0
    Top = 136
    Width = 345
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 48
    ExplicitWidth = 361
  end
  object Label1: TLabel
    Left = 8
    Top = 50
    Width = 313
    Height = 88
    Anchors = [akLeft, akRight, akBottom]
    Caption = 
      'Diffuse Texture Generation tool build the texture atlas by takin' +
      'g '#39'pictures'#39' from the angle of randomly selected faces.  Use ang' +
      'les between  0 and 89 to set the maximum angle that these pictur' +
      'es can cover. If the angle is 90'#39' or higher, then there is a gre' +
      'at chance of several faces take the same sector of the picture, ' +
      'blurring the final result.'
    WordWrap = True
    ExplicitTop = 60
  end
  object BtOK: TButton
    Left = 262
    Top = 158
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtOKClick
    ExplicitTop = 132
  end
  object BtCancel: TButton
    Left = 181
    Top = 158
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = BtCancelClick
    ExplicitTop = 132
  end
  object EdThreshold: TEdit
    Left = 128
    Top = 14
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '45'
  end
end
