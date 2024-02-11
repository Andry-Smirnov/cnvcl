unit UnitPdf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TypInfo;

type
  TFormPDF = class(TForm)
    btnGenSimple: TButton;
    dlgSave1: TSaveDialog;
    dlgOpen1: TOpenDialog;
    btnParsePDFToken: TButton;
    mmoPDF: TMemo;
    btnParsePDFStructure: TButton;
    procedure btnGenSimpleClick(Sender: TObject);
    procedure btnParsePDFTokenClick(Sender: TObject);
    procedure btnParsePDFStructureClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPDF: TFormPDF;

implementation

uses
  CnPDF;

{$R *.dfm}

procedure TFormPDF.btnGenSimpleClick(Sender: TObject);
var
  PDF: TCnPDFDocument;
  Page: TCnPDFDictionaryObject;
  Box: TCnPDFArrayObject;
  Stream: TCnPDFStreamObject;
  Resource: TCnPDFDictionaryObject;
  Arr: TCnPDFArrayObject;
  Dict: TCnPDFDictionaryObject;
  Content: TCnPDFStreamObject;
begin
  dlgOpen1.Title := 'Open a JPEG File';
  if not dlgOpen1.Execute then
    Exit;

  dlgSave1.Title := 'Save PDF File';
  if dlgSave1.Execute then
  begin
    PDF := TCnPDFDocument.Create;
    try
      PDF.Body.Info.AddAnsiString('Author', 'CnPack');
      PDF.Body.Info.AddAnsiString('Producer', 'CnPDF in CnVCL');
      PDF.Body.Info.AddAnsiString('Creator', 'CnPack PDF Demo');
      PDF.Body.Info.AddAnsiString('CreationDate', 'D:20240101000946+08''00''');

      PDF.Body.Info.AddWideString('Title', '���Ա���');
      PDF.Body.Info.AddWideString('Subject', '��������');  // ք
      PDF.Body.Info.AddWideString('Keywords', '�ؼ���1���ؼ���2');
      PDF.Body.Info.AddWideString('Company', 'CnPack������');
      PDF.Body.Info.AddWideString('Comments', '����ע��');

      Page := PDF.Body.AddPage;
      Box := Page.AddArray('MediaBox');
      Box.AddNumber(0);
      Box.AddNumber(0);
      Box.AddNumber(612);
      Box.AddNumber(792);

      // ���ͼ������
      Stream := TCnPDFStreamObject.Create;
      Stream.SetJpegImage(dlgOpen1.FileName);
      PDF.Body.AddObject(Stream);

      // ������ô�ͼ�����Դ
      Resource := PDF.Body.AddResource(Page);
      Arr := Resource.AddArray('ProcSet');
      Arr.AddAnsiString('PDF');
      Arr.AddAnsiString('ImageB');

      Dict := Resource.AddDictionary('XObject');
      //Dict.AddName('lm1', TCnPDFReferenceObject.Create(Stream));

      // ���ҳ�沼������
      Content := PDF.Body.AddContent(Page);

      PDF.SaveToFile(dlgSave1.FileName);
    finally
      PDF.Free;
    end;
  end;
end;

procedure TFormPDF.btnParsePDFTokenClick(Sender: TObject);
var
  I: Integer;
  P: TCnPDFParser;
  M: TMemoryStream;
  S, C: string;
begin
  dlgOpen1.Title := 'Open a PDF File';
  if dlgOpen1.Execute then
  begin
    P := TCnPDFParser.Create;
    M := TMemoryStream.Create;
    M.LoadFromFile(dlgOpen1.FileName);
    P.SetOrigin(M.Memory, M.Size);

    mmoPDF.Lines.Clear;
    mmoPDF.Lines.BeginUpdate;
    I := 0;
    try
      while True do
      begin
        // ��ӡ P �������� Token
        Inc(I);
        if P.TokenID in [pttStreamData] then
          C := '... Stream Data ...'
        else if P.TokenID in [pttLineBreak] then
          C := '<CRLF>'
        else if P.TokenLength > 128 then
          C := '... <Token Too Long> ...'
        else
          C := P.Token;

        S := Format('#%d Offset %d Length %d %-20.20s %s ', [I, P.RunPos - P.TokenLength, P.TokenLength,
          GetEnumName(TypeInfo(TCnPDFTokenType), Ord(P.TokenID)), C]);

        mmoPDF.Lines.Add(S);
        P.Next;
      end;
    finally
      mmoPDF.Lines.EndUpdate;
      M.Free;
      P.Free;
    end;
  end;
end;

procedure TFormPDF.btnParsePDFStructureClick(Sender: TObject);
var
  PDF: TCnPDFDocument;
begin
   dlgOpen1.Title := 'Open a PDF File';
  if dlgOpen1.Execute then
  begin
    PDF := CnLoadPDFFile(dlgOpen1.FileName);

    if PDF <> nil then
    begin
      mmoPDF.Lines.Clear;

      mmoPDF.Lines.BeginUpdate;
      PDF.Header.DumpToStrings(mmoPDF.Lines);
      PDF.Body.DumpToStrings(mmoPDF.Lines, True);
      PDF.XRefTable.DumpToStrings(mmoPDF.Lines);
      PDF.Trailer.DumpToStrings(mmoPDF.Lines);

      mmoPDF.Lines.Add('');

      // ��� Info��Catalog��Pages �ȶ��������
      mmoPDF.Lines.EndUpdate;

      if dlgSave1.Execute then
        PDF.SaveToFile(dlgSave1.FileName);
      PDF.Free;
    end;
  end;
end;

end.
