object FrmCustom360DegAnimation: TFrmCustom360DegAnimation
  Left = 0
  Top = 0
  Caption = 'Custom 360 Degree Animation'
  ClientHeight = 117
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    268
    117)
  PixelsPerInch = 96
  TextHeight = 13
  object LbNumFrames: TLabel
    Left = 16
    Top = 16
    Width = 92
    Height = 13
    Caption = 'Number of Frames:'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 73
    Width = 273
    Height = 5
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 55
  end
  object LbFrameDelay: TLabel
    Left = 16
    Top = 48
    Width = 99
    Height = 13
    Caption = 'Frame Delay (in ms):'
  end
  object EdNumFrames: TEdit
    Left = 128
    Top = 12
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '90'
  end
  object BtOK: TButton
    Left = 185
    Top = 84
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtOKClick
    ExplicitTop = 48
  end
  object BtCancel: TButton
    Left = 104
    Top = 84
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = BtCancelClick
    ExplicitTop = 48
  end
  object EdFrameDelay: TEdit
    Left = 128
    Top = 46
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '10'
  end
end
