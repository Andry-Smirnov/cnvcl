unit Unit18030;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnWideStrings;

type
  TFormGB18030 = class(TForm)
    btnCodePointFromUtf161: TButton;
    btnCodePointFromUtf162: TButton;
    btnUtf16CharLength: TButton;
    btnUtf8CharLength: TButton;
    btnUtf8Encode: TButton;
    btnCodePointUtf16: TButton;
    btnCodePointUtf162: TButton;
    btnUtf8Decode: TButton;
    btnGenUtf16: TButton;
    dlgSave1: TSaveDialog;
    btnCodePointUtf163: TButton;
    procedure btnCodePointFromUtf161Click(Sender: TObject);
    procedure btnCodePointFromUtf162Click(Sender: TObject);
    procedure btnUtf16CharLengthClick(Sender: TObject);
    procedure btnUtf8CharLengthClick(Sender: TObject);
    procedure btnUtf8EncodeClick(Sender: TObject);
    procedure btnCodePointUtf16Click(Sender: TObject);
    procedure btnCodePointUtf162Click(Sender: TObject);
    procedure btnUtf8DecodeClick(Sender: TObject);
    procedure btnGenUtf16Click(Sender: TObject);
    procedure btnCodePointUtf163Click(Sender: TObject);
  private
    procedure GenUtf16Page(Page: Byte; Content: TCnWideStringList);
  public

  end;

var
  FormGB18030: TFormGB18030;

implementation

uses
  CnGB18030, CnNative;

{$R *.DFM}

const
  FACE: array[0..3] of Byte = ($3D, $D8, $02, $DE);      // Ц���˵ı������ UTF16-LE ��ʾ
  FACE_UTF8: array[0..3] of Byte = ($F0, $9F, $98, $82); // Ц���˵ı������ UTF8-MB4 ��ʾ

procedure TFormGB18030.btnCodePointFromUtf161Click(Sender: TObject);
var
  A: AnsiString;
  S: WideString;
  C: Cardinal;
begin
  A := '�Է�'; // �ڴ����� B3D4B7B9��GB18030����Ҳ�� B3D4 �� B7B9�����Ķ�˳��
  S := '�Է�'; // �ڴ����� 03546D99���� Unicode ����ȴ�� 5403 �� 996D���з���
  C := GetCodePointFromUtf16Char(PWideChar(S));
  ShowMessage(IntToHex(C, 2));
end;

procedure TFormGB18030.btnCodePointFromUtf162Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  SetLength(S, 2);
  Move(FACE[0], S[1], 4);

  C := GetCodePointFromUtf16Char(PWideChar(S));
  ShowMessage(IntToHex(C, 2)); // Ӧ�õ� $1F602
end;

procedure TFormGB18030.btnUtf16CharLengthClick(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  SetLength(S, 2);
  Move(FACE[0], S[1], 4);

  C := GetCharLengthFromUtf16(PWideChar(S));
  ShowMessage(IntToStr(C)); // Ӧ�õ� 1
end;

procedure TFormGB18030.btnUtf8CharLengthClick(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  SetLength(S, 4);
  Move(FACE_UTF8[0], S[1], 4);

  C := GetCharLengthFromUtf8(PAnsiChar(S));
  ShowMessage(IntToStr(C)); // Ӧ�õ� 1
end;

procedure TFormGB18030.btnUtf8EncodeClick(Sender: TObject);
var
  S: WideString;
  R: AnsiString;
begin
  SetLength(S, 2);
  Move(FACE[0], S[1], 4);

  R := CnUtf8EncodeWideString(S);
  if R <> '' then
    ShowMessage(DataToHex(@R[1], Length(R)))  // F09F9882
  else
    ShowMessage('Error');
end;

procedure TFormGB18030.btnCodePointUtf16Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  C := $5403;  // �Ե� Unicode ���
  SetLength(S, 1);
  GetUtf16CharFromCodePoint(C, @S[1]);
  ShowMessage(S);
end;

procedure TFormGB18030.btnCodePointUtf162Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  C := $1F602;  // Ц���˵ı������ Unicode ���
  SetLength(S, 2);
  GetUtf16CharFromCodePoint(C, @S[1]);
  ShowMessage(DataToHex(@S[1], Length(S) * SizeOf(WideChar))); // $3DD802DE
end;

procedure TFormGB18030.btnUtf8DecodeClick(Sender: TObject);
var
  S: AnsiString;
  R: WideString;
begin
  SetLength(S, 4);
  Move(FACE_UTF8[0], S[1], 4);

  R := CnUtf8DecodeToWideString(S);
  if R <> '' then
    ShowMessage(DataToHex(@R[1], Length(R) * SizeOf(WideChar)))  // 3DD802DE
  else
    ShowMessage('Error');
end;

procedure TFormGB18030.btnGenUtf16Click(Sender: TObject);
var
  I: Integer;
  WS: TCnWideStringList;
begin
  // 0000 ~ FFFF��һ�� 0~F��һҳ 0~F���� 255 ҳ
  WS := TCnWideStringList.Create;
  Screen.Cursor := crHourGlass;

  try
    for I := 0 to 255 do
    begin
      WS.Add('');
      GenUtf16Page(I, WS);
    end;

    if dlgSave1.Execute then
      WS.SaveToFile(dlgSave1.FileName);
  finally
    Screen.Cursor := crDefault;
    WS.Free;
  end;
end;

procedure TFormGB18030.GenUtf16Page(Page: Byte; Content: TCnWideStringList);
var
  R, C: Byte;
  S, T: WideString;
begin
  S := '    ';
  for C := 0 to $F do
    S := S + ' ' + IntToHex(C, 2);
  Content.Add(S);

  SetLength(T, 1);
  for R := 0 to $F do
  begin
    S := IntToHex(Page, 2) + IntToHex(16 * R, 2);
    for C := 0 to $F do
    begin
      GetUtf16CharFromCodePoint(Page * 256 + R * 16 + C, @T[1]);
      S := S + ' ' + T;
    end;
    Content.Add(S);
  end;
end;

procedure TFormGB18030.btnCodePointUtf163Click(Sender: TObject);
var
  S: WideString;
  C: Cardinal;
begin
  C := $20BB7;  // �����¿� �� Unicode ���
  SetLength(S, 2);
  GetUtf16CharFromCodePoint(C, @S[1]);
  ShowMessage(DataToHex(@S[1], Length(S) * SizeOf(WideChar))); // $42D8B7DF
end;

end.
