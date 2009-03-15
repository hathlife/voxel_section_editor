object FrmProgress: TFrmProgress
  Left = 197
  Top = 114
  BorderStyle = bsNone
  Caption = ' '
  ClientHeight = 53
  ClientWidth = 322
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 322
    Height = 53
    Align = alClient
    TabOrder = 0
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 87
      Height = 13
      Caption = 'Loading Message!'
    end
    object Label1: TLabel
      Left = 1
      Top = 33
      Width = 320
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'PLEASE WAIT LOADING...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
end
