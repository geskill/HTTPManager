object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    635
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Left = 24
    Top = 64
    Width = 466
    Height = 217
    Anchors = [akLeft, akTop, akRight, akBottom]
    IncrementalDisplay = True
    Proportional = True
  end
  object bClose: TButton
    Left = 552
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 0
    OnClick = bCloseClick
  end
  object eGETRequest: TEdit
    Left = 24
    Top = 24
    Width = 385
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'http://images.delphipraxis.net/header_back_winter2012.jpg'
  end
  object bDownload: TButton
    Left = 415
    Top = 22
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Download'
    TabOrder = 2
    OnClick = bDownloadClick
  end
end
