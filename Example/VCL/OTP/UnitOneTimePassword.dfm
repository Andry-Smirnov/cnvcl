object FormOneTimePassword: TFormOneTimePassword
  Left = 192
  Top = 108
  Width = 979
  Height = 563
  Caption = 'One-Time-Password Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnGenerate: TButton
    Left = 24
    Top = 24
    Width = 225
    Height = 25
    Caption = 'Generate GB/T 38556-2020'
    TabOrder = 0
    OnClick = btnGenerateClick
  end
  object btnGen2: TButton
    Left = 24
    Top = 72
    Width = 225
    Height = 25
    Caption = 'Generate HOTP rfc4226'
    TabOrder = 1
    OnClick = btnGen2Click
  end
  object btnGen3: TButton
    Left = 24
    Top = 120
    Width = 225
    Height = 25
    Caption = 'Generate TOTP rfc6238'
    TabOrder = 2
    OnClick = btnGen3Click
  end
  object grpTOTP: TGroupBox
    Left = 24
    Top = 176
    Width = 289
    Height = 321
    Caption = 'TOTP Authenticator(SHA1)'
    TabOrder = 3
    object lblTOTP: TLabel
      Left = 32
      Top = 32
      Width = 108
      Height = 13
      Caption = 'TOTP Secret(Base32):'
    end
    object edtTOTPSecret: TEdit
      Left = 32
      Top = 64
      Width = 169
      Height = 21
      TabOrder = 0
    end
    object btnTOTPGen: TButton
      Left = 30
      Top = 104
      Width = 75
      Height = 25
      Caption = 'Generate'
      TabOrder = 1
      OnClick = btnTOTPGenClick
    end
    object pnlTOTP: TPanel
      Left = 32
      Top = 152
      Width = 209
      Height = 81
      BevelOuter = bvNone
      Caption = '000000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
end
