object FormMarkDown: TFormMarkDown
  Left = 192
  Top = 107
  Width = 1106
  Height = 636
  Caption = 'Test MarkDown'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object mmoMarkDown: TMemo
    Left = 16
    Top = 48
    Width = 577
    Height = 281
    Lines.Strings = (
      '# Hea*er1*'
      '## Header2'
      '* �϶���'
      '* ��˵����ʽ'
      '### Header3'
      '��`��`���¥*�˹�*��**����**  '
      '---'
      '��~~�ǰ�~~�����ӣ�[CnPack](https://www.cnpack.org)  '
      'Internal Help ![test]()'
      '1. �Է�'
      '2. ��ˮ'
      '>  * ��ˮ'
      '>  * �Է�'
      '> > ������**����**������'
      ''
      
        '    FragmentType ��ˮ F**ragmentType FragmentType FragmentTypeFr' +
        'agmentType�Է�TypeFragmentType '
      'FragmentType Fragm**entType  '
      'FragmentT<https://cnpack.org>ypeFragmentType')
    TabOrder = 0
  end
  object redtMarkDown: TRichEdit
    Left = 632
    Top = 48
    Width = 433
    Height = 545
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      '')
    ParentFont = False
    TabOrder = 1
  end
  object btnTest: TButton
    Left = 416
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 2
    OnClick = btnTestClick
  end
  object mmoParse: TMemo
    Left = 16
    Top = 344
    Width = 577
    Height = 249
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnDump: TButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Tokens Dump'
    TabOrder = 4
    OnClick = btnDumpClick
  end
  object btnParseTree: TButton
    Left = 104
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Parse Tree'
    TabOrder = 5
    OnClick = btnParseTreeClick
  end
end
