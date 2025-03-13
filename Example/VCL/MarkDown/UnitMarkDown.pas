unit UnitMarkDown;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, TypInfo;

type
  TFormMarkDown = class(TForm)
    mmoMarkDown: TMemo;
    redtMarkDown: TRichEdit;
    btnTest: TButton;
    mmoParse: TMemo;
    btnDump: TButton;
    btnParseTree: TButton;
    btnConvRtf: TButton;
    procedure btnTestClick(Sender: TObject);
    procedure btnDumpClick(Sender: TObject);
    procedure btnParseTreeClick(Sender: TObject);
    procedure btnConvRtfClick(Sender: TObject);
  private
    procedure DumpMarkDownTokens(const MD: string);
  public
    { Public declarations }
  end;

var
  FormMarkDown: TFormMarkDown;

implementation

{$R *.DFM}

uses
  CnMarkDown;

procedure TFormMarkDown.btnTestClick(Sender: TObject);
//const
//  SampleMD =
//    '# ����'#13#10 +
//    '���ǵ�һ����ĵ�һ��  '#13#10 +  // �����ո�ǿ�ƻ���
//    '����ͬһ����ĵڶ���\'#13#10 +  // ��б�ܻ���
//    '������ͨ����'#13#10 +
//    ''#13#10 +  // ���зָ�����
//    '* �б���1'#13#10 +
//    '* �б���2'#13#10 +
//    ''#13#10 +
//    '> ��������'#13#10 +
//    ''#13#10 +
//    '```delphi'#13#10 +
//    'procedure Test;'#13#10 +
//    'begin'#13#10 +
//    '  ShowMessage(''Hello'');'#13#10 +
//    'end;'#13#10 +
//    '```'#13#10 +
//    ''#13#10 +
//    '����ʾ����[CnPack](https://www.cnpack.org) ͼƬʾ����![Logo](logo.png)';

const
  SampleMD =
    '# Header'#13#10  +
    '1st Para lst line  '#13#10 +  // �����ո�ǿ�ƻ���
    '1st para 2nd line\'#13#10 +  // ��б�ܻ���
    'com*mon* line'#13#10 +
    ''#13#10 +  // ���зָ�����
    '* Ulist1'#13#10 +
    '* ulist2'#13#10 +
    ''#13#10 +
    '> quota'#13#10 +
    ''#13#10 +
    '```delphi'#13#10 +
    'procedure Test;'#13#10 +
    'begin'#13#10 +
    '  ShowMessage(''Hello'');'#13#10 +
    'end;'#13#10 +
    '```'#13#10 +
    ''#13#10 +
    'Link��[CnPack](https://www.cnpack.org) Picture: ![Logo](logo.png)';
begin

end;

procedure TFormMarkDown.DumpMarkDownTokens(const MD: string);
var
  I: Integer;
  Parser: TCnMarkDownParser;
begin
  Parser := TCnMarkDownParser.Create;
  try
    Parser.Origin := PChar(MD);

    I := 1;
    while Parser.TokenID <> cmtTerminate do
    begin
      mmoParse.Lines.Add(Format('%3.3d. Length %3.3d, Pos %4.4d. %s, Token: %s',
        [I, Parser.TokenLength, Parser.RunPos, GetEnumName(TypeInfo(TCnMarkDownTokenType),
         Ord(Parser.TokenID)), Parser.Token]));
      Parser.Next;
      Inc(I);
    end;
  finally
    Parser.Free;
  end;
end;

procedure TFormMarkDown.btnDumpClick(Sender: TObject);
begin
  mmoParse.Lines.Clear;
  DumpMarkDownTokens(mmoMarkDown.Lines.Text);
end;

procedure TFormMarkDown.btnParseTreeClick(Sender: TObject);
var
  MD: TCnMarkDownBase;
begin
  mmoParse.Lines.Clear;
  MD := CnParseMarkDownString(mmoMarkDown.Lines.Text);
  CnMarkDownDebugOutput(MD, mmoParse.Lines);
  MD.Free;
end;

procedure TFormMarkDown.btnConvRtfClick(Sender: TObject);
var
  MD: TCnMarkDownBase;
begin
  mmoParse.Lines.Clear;
  MD := CnParseMarkDownString(mmoMarkDown.Lines.Text);
  mmoParse.Lines.Text := CnMarkDownConvertToRTF(MD);
  MD.Free;
end;

end.
