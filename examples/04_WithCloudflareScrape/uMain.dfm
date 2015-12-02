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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    635
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object cxPageControl: TcxPageControl
    Left = 8
    Top = 8
    Width = 619
    Height = 253
    Anchors = [akLeft, akTop, akRight, akBottom]
    Focusable = False
    TabOrder = 0
    Properties.ActivePage = cxTSGetRequest
    Properties.CustomButtons.Buttons = <>
    ClientRectBottom = 249
    ClientRectLeft = 4
    ClientRectRight = 615
    ClientRectTop = 24
    object cxTSGetRequest: TcxTabSheet
      Caption = 'GET-Request'
      ImageIndex = 0
      DesignSize = (
        611
        225)
      object cxTEGETURL: TcxTextEdit
        Left = 16
        Top = 16
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'http://iphostinfo.com/cloudflare/'
        Width = 498
      end
      object bGET: TButton
        Left = 520
        Top = 14
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'GET'
        TabOrder = 1
        OnClick = bGETClick
      end
      object mGETResult: TMemo
        Left = 16
        Top = 56
        Width = 579
        Height = 153
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssBoth
        TabOrder = 2
      end
    end
    object cxTSPostRequest: TcxTabSheet
      Caption = 'POST-Request'
      ImageIndex = 1
      DesignSize = (
        611
        225)
      object lPOSTParams: TLabel
        Left = 16
        Top = 43
        Width = 39
        Height = 13
        Caption = 'Params:'
      end
      object cxTEPOSTURL: TcxTextEdit
        Left = 16
        Top = 16
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'http://www.delphipraxis.net/dp_search.php?do=process'
        Width = 498
      end
      object bPOST: TButton
        Left = 520
        Top = 14
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'POST'
        TabOrder = 1
        OnClick = bPOSTClick
      end
      object mPOSTParams: TMemo
        Left = 16
        Top = 59
        Width = 579
        Height = 54
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'query=http indy')
        TabOrder = 2
      end
      object mPOSTResult: TMemo
        Left = 16
        Top = 119
        Width = 579
        Height = 90
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 3
      end
    end
  end
  object bClose: TButton
    Left = 552
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 1
    OnClick = bCloseClick
  end
  object bHTTPLogger: TButton
    Left = 8
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'HTTP-Logger'
    TabOrder = 2
    OnClick = bHTTPLoggerClick
  end
end
