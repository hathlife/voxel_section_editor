object FrmRepairAssistant: TFrmRepairAssistant
  Left = 0
  Top = 0
  Caption = 'Voxel Section Editor III Online Installation Wizard'
  ClientHeight = 213
  ClientWidth = 437
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    437
    213)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 65
    Height = 13
    AutoSize = False
    Caption = 'Current File:'
  end
  object LbFilename: TLabel
    Left = 88
    Top = 16
    Width = 341
    Height = 13
    AutoSize = False
  end
  object MmReport: TMemo
    Left = 8
    Top = 39
    Width = 421
    Height = 166
    Anchors = [akLeft, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WantReturns = False
    OnChange = MmReportChange
  end
  object Timer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TimerTimer
    Left = 120
    Top = 8
  end
end
