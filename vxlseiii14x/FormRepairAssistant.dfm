object FrmRepairAssistant: TFrmRepairAssistant
  Left = 0
  Top = 0
  Caption = 'VXLSE Filesystem Repair Assistant'
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
  DesignSize = (
    437
    213)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 105
    Height = 13
    AutoSize = False
    Caption = 'Current File:'
  end
  object LbFilename: TLabel
    Left = 136
    Top = 16
    Width = 293
    Height = 13
    AutoSize = False
  end
  object MmReport: TMemo
    Left = 8
    Top = 39
    Width = 421
    Height = 166
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    ExplicitTop = 64
  end
  object IdHTTP: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Top = 40
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 32
    Top = 40
  end
  object XMLDocument: TXMLDocument
    Left = 64
    Top = 40
    DOMVendorDesc = 'MSXML'
  end
end
