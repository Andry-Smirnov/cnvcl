unit Unit18030;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnStrings, CnWideStrings, CnGB18030;

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
    btnGB18030ToUtf16: TButton;
    btn18030CodePoint1: TButton;
    btn18030CodePoint2: TButton;
    btn18030CodePoint3: TButton;
    btnCodePoint180301: TButton;
    btnCodePoint180302: TButton;
    btnCodePoint180303: TButton;
    btnMultiUtf16ToGB18130: TButton;
    btnMultiGB18131ToUtf16: TButton;
    btnGenGB18030Page: TButton;
    btnGenUtf16Page: TButton;
    chkIncludeCharValue: TCheckBox;
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
    procedure btnGB18030ToUtf16Click(Sender: TObject);
    procedure btn18030CodePoint1Click(Sender: TObject);
    procedure btn18030CodePoint2Click(Sender: TObject);
    procedure btn18030CodePoint3Click(Sender: TObject);
    procedure btnCodePoint180301Click(Sender: TObject);
    procedure btnCodePoint180302Click(Sender: TObject);
    procedure btnCodePoint180303Click(Sender: TObject);
    procedure btnMultiUtf16ToGB18130Click(Sender: TObject);
    procedure btnMultiGB18131ToUtf16Click(Sender: TObject);
    procedure btnGenGB18030PageClick(Sender: TObject);
    procedure btnGenUtf16PageClick(Sender: TObject);
  private
    procedure GenUtf16Page(Page: Byte; Content: TCnWideStringList);
    function CodePointUtf16ToGB18130(UCP: TCnCodePoint): TCnCodePoint;
    function CodePointGB18130ToUtf16(GBCP: TCnCodePoint): TCnCodePoint;
    function Gen2GB18030ToUtf16Page(FromH, ToH, FromL, ToL: Byte; Content: TCnWideStringList): Integer;
    procedure Gen2Utf16ToGB18030Page(FromH, FromL, ToH, ToL: Byte; Content: TCnAnsiStringList; H2: Word = 0);

    function Gen4GB18030ToUtf16Page(From4, To4: TCnCodePoint; Content: TCnWideStringList): Integer;
  public

  end;

var
  FormGB18030: TFormGB18030;

implementation

uses
  CnNative;

{$R *.DFM}

const
  FACE: array[0..3] of Byte = ($3D, $D8, $02, $DE);      // Ц���˵ı������ UTF16-LE ��ʾ
  FACE_UTF8: array[0..3] of Byte = ($F0, $9F, $98, $82); // Ц���˵ı������ UTF8-MB4 ��ʾ

  CP_GB18030 = 54936;

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

    dlgSave1.FileName := 'UTF16.txt';
    if dlgSave1.Execute then
    begin
      WS.SaveToFile(dlgSave1.FileName);
      ShowMessage('Save to ' + dlgSave1.FileName);
    end;
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

procedure TFormGB18030.btnGB18030ToUtf16Click(Sender: TObject);
var
  S: AnsiString;
  W: WideString;
  C: Integer;
begin
  S := '�Է�';

  C := MultiByteToWideChar(CP_GB18030, 0, @S[1], Length(S), nil, 0);
  if C > 0 then
  begin
    SetLength(W, C);
    C := MultiByteToWideChar(CP_GB18030, 0, @S[1], Length(S), @W[1], Length(W));

    if C > 0 then
    begin
      ShowMessage(W);

      C := WideCharToMultiByte(CP_GB18030, 0, @W[1], Length(W), nil, 0, nil, nil);
      if C > 0 then
      begin
        SetLength(S, C);

        C := WideCharToMultiByte(CP_GB18030, 0, @W[1], Length(W), @S[1], Length(S), nil, nil);
        if C > 0 then
          ShowMessage(S);
      end;
    end;
  end;
end;

procedure TFormGB18030.btn18030CodePoint1Click(Sender: TObject);
var
  S: AnsiString;
  C: TCnCodePoint;
begin
  S := 'A';
  C := GetCodePointFromGB18030Char(@S[1]);
  ShowMessage(IntToHex(C, 2));              // 41
end;

procedure TFormGB18030.btn18030CodePoint2Click(Sender: TObject);
var
  S: AnsiString;
  C: TCnCodePoint;
begin
  S := '��';
  C := GetCodePointFromGB18030Char(@S[1]);
  ShowMessage(IntToHex(C, 2));              // B3D4
end;

procedure TFormGB18030.btn18030CodePoint3Click(Sender: TObject);
var
  S: AnsiString;
  C: TCnCodePoint;
begin
  SetLength(S, 4);
  S[1] := #$82;   // ��Ů�Ұ�
  S[2] := #$30;
  S[3] := #$C2;
  S[4] := #$30;

  C := GetCodePointFromGB18030Char(@S[1]);
  ShowMessage(IntToHex(C, 2));              // 8230C230
end;

procedure TFormGB18030.btnCodePoint180301Click(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  C := $42;  // B �� GB18030 ���
  SetLength(S, 1);
  GetGB18030CharsFromCodePoint(C, @S[1]);
  ShowMessage(S);
end;

procedure TFormGB18030.btnCodePoint180302Click(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  C := $B3D4;  // �Ե� GB18030 ���
  SetLength(S, 2);
  GetGB18030CharsFromCodePoint(C, @S[1]);
  ShowMessage(S);
end;

procedure TFormGB18030.btnCodePoint180303Click(Sender: TObject);
var
  S: AnsiString;
  C: Cardinal;
begin
  C := $8139EF34;  // һ����� GB18030 ���
  SetLength(S, 4);
  GetGB18030CharsFromCodePoint(C, @S[1]);   // �ڴ��еõ� 8139EF34
  ShowMessage(S);
end;

function TFormGB18030.CodePointGB18130ToUtf16(GBCP: TCnCodePoint): TCnCodePoint;
var
  S: AnsiString;
  W: WideString;
  C, T: Integer;
begin
  Result := CN_INVALID_CODEPOINT;

  SetLength(S, 4); // ��� 4
  C := GetGB18030CharsFromCodePoint(GBCP, @S[1]);  // S �Ǹ� GB18030 �ַ���C �����ֽڳ���

  T := MultiByteToWideChar(CP_GB18030, 0, @S[1], C, nil, 0);
  if T > 0 then
  begin
    SetLength(W, T);
    T := MultiByteToWideChar(CP_GB18030, 0, @S[1], C, @W[1], Length(W));
    if T > 0 then
      Result := GetCodePointFromUtf16Char(@W[1]);
  end;
end;

function TFormGB18030.CodePointUtf16ToGB18130(UCP: TCnCodePoint): TCnCodePoint;
var
  S: AnsiString;
  W: WideString;
  C, T: Integer;
begin
  Result := CN_INVALID_CODEPOINT;

  SetLength(W, 2); // ��� 2 �����ַ�Ҳ�������ֽ�
  C := GetUtf16CharFromCodePoint(UCP, @W[1]);  // W �Ǹ� Utf16 �ַ���C ������ַ�����

  T := WideCharToMultiByte(CP_GB18030, 0, @W[1], C, nil, 0, nil, nil);
  if T > 0 then
  begin
    SetLength(S, T);

    T := WideCharToMultiByte(CP_GB18030, 0, @W[1], C, @S[1], Length(S), nil, nil);
    if T > 0 then
      Result := GetCodePointFromGB18030Char(@S[1]);
  end;
end;

procedure TFormGB18030.btnMultiUtf16ToGB18130Click(Sender: TObject);
var
  S: WideString;
  A, T: AnsiString;
  I: Integer;
  C: TCnCodePoint;
begin
  S := '�Է�һ���٣�˯�����ܶ�';
  A := '';
  for I := 1 to Length(S) do
  begin
    C := GetCodePointFromUtf16Char(@S[I]);   // Utf16 ֵ
    if C = CN_INVALID_CODEPOINT then
      Exit;

    C := CodePointUtf16ToGB18130(C);         // ת�� GB18030
    if C = CN_INVALID_CODEPOINT then
      Exit;

    SetLength(T, 4);
    C := GetGB18030CharsFromCodePoint(C, @T[1]);
    if C > 0 then
      SetLength(T, C);

    A := A + T;
  end;
  ShowMessage(A);
end;

procedure TFormGB18030.btnMultiGB18131ToUtf16Click(Sender: TObject);
var
  S, T: WideString;
  A: AnsiString;
  I: Integer;
  C: TCnCodePoint;
begin
  A := '�Է�һ���٣�˯�����ܶ�';
  S := '';
  I := 1;

  while I <= Length(A) do
  begin
    C := GetCodePointFromGB18030Char(@A[I]);   // GB18030 ֵ
    Inc(I, 2);

    if C = CN_INVALID_CODEPOINT then
      Exit;

    C := CodePointGB18130ToUtf16(C);           // ת�� Utf16
    if C = CN_INVALID_CODEPOINT then
      Exit;

    SetLength(T, 1);
    GetUtf16CharFromCodePoint(C, @T[1]);

    S := S + T;
  end;
  ShowMessage(S);
end;

function TFormGB18030.Gen2GB18030ToUtf16Page(FromH, ToH, FromL, ToL: Byte;
  Content: TCnWideStringList): Integer;
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: WideString;
begin
  Result := 0;
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      GBCP := (H shl 8) or L;
      UCP := CodePointGB18130ToUtf16(GBCP);
      T := GetUtf16CharFromCodePoint(UCP, nil);
      SetLength(C, T);
      GetUtf16CharFromCodePoint(UCP, @C[1]);

      if chkIncludeCharValue.Checked then
        S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2) + '  ' + C
      else
        S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2);

      Content.Add(S);
      Inc(Result);
    end;
  end;
end;

procedure TFormGB18030.btnGenGB18030PageClick(Sender: TObject);
var
  R: Integer;
  WS: TCnWideStringList;
begin
  WS := TCnWideStringList.Create;
// ˫�ֽڣ�A1A9~A1FE                     1 ��
//         A840~A97E, A880~A9A0          5 ��
//         B0A1~F7FE                     2 ������
//         8140~A07E, 8180~A0FE          3 ������
//         AA40~FE7E, AA80~FEA0          4 ������
//         AAA1~AFFE                     �û� 1 ��
//         F8A1~FEFE                     �û� 2 ��
//         A140~A77E, A180~A7A0          �û� 3 ��

  R := 0;
  WS.Add('����˫�ֽ�һ; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($A1, $A9, $A1, $FE, WS);
  WS.Add('����˫�ֽ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($A8, $A9, $40, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($A8, $A9, $80, $A0, WS);
  WS.Add('����˫�ֽں��ֶ�; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($B0, $F7, $A1, $FE, WS);
  WS.Add('����˫�ֽں�����; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($81, $A0, $40, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($81, $A0, $80, $FE, WS);
  WS.Add('����˫�ֽں�����; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($AA, $FE, $40, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($AA, $FE, $80, $A0, WS);

  WS.Add('����˫�ֽ��û�һ; ��һ���ַ�����' + IntToStr(R)); // ����˫�ֽ��û���
  R := Gen2GB18030ToUtf16Page($AA, $AF, $A1, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($F8, $FE, $A1, $FE, WS);
  WS.Add('����˫�ֽ��û���; ��һ���ַ�����' + IntToStr(R));
  R := Gen2GB18030ToUtf16Page($A1, $A7, $40, $7E, WS);
  R := R + Gen2GB18030ToUtf16Page($A1, $A7, $80, $A0, WS);

  // ���ֽ�
  WS.Add('�������ֽ�ά����������ˡ��¶�������һ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81318132, $81319934, WS);
  WS.Add('�������ֽڲ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8132E834, $8132FD31, WS);
  WS.Add('�������ֽڳ�������ĸ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81339D36, $8133B635, WS);
  WS.Add('�������ֽ��ɹ��ģ��������ġ���߯�ġ������ĺͰ�������֣�; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134D238, $8134E337, WS);
  WS.Add('�������ֽڵº����; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134F434, $8134F830, WS);
  WS.Add('�������ֽ���˫�����´���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8134F932, $81358437, WS);
  WS.Add('�������ֽ���˫�����ϴ���; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81358B32, $81359935, WS);
  WS.Add('�������ֽڿ�������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($81398B32, $8139A135, WS);
  WS.Add('�������ֽڳ����ļ�����ĸ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8139A933, $8139B734, WS);
  WS.Add('�������ֽ� CJK ͳһ�������� A; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8139EE39, $82358738, WS);
  WS.Add('�������ֽ� CJK ͳһ����; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82358F33, $82359636, WS);
  WS.Add('�������ֽ�����; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82359833, $82369435, WS);
  WS.Add('�������ֽ�������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($82369535, $82369A32, WS);
  WS.Add('�������ֽڳ���������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8237CF35, $8336BE36, WS);
  WS.Add('�������ֽ�ά����������ˡ��¶������Ķ�; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($8430BA32, $8430FE35, WS);
  WS.Add('�������ֽ�ά����������ˡ��¶���������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($84318730, $84319530, WS);
  WS.Add('�������ֽ��ɹ��� BIRGA; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9034C538, $9034C730, WS);
  WS.Add('�������ֽڵᶫ������; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9232C636, $9232D635, WS);
  WS.Add('�������ֽ� CJK ͳһ�������� B; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($95328236, $9835F336, WS);
  WS.Add('�������ֽ� CJK ͳһ�������� C; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9835F738, $98399E36, WS);
  WS.Add('�������ֽ� CJK ͳһ�������� D; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($98399F38, $9839B539, WS);
  WS.Add('�������ֽ� CJK ͳһ�������� E; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($9839B632, $9933FE33, WS);
  WS.Add('�������ֽ� CJK ͳһ�������� F; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($99348138, $9939F730, WS);
  WS.Add('�������ֽ��û���չ; ��һ���ַ�����' + IntToStr(R));
  R := Gen4GB18030ToUtf16Page($FD308130, $FE39FE39, WS);
  WS.Add('��β; ��һ���ַ�����' + IntToStr(R));

  dlgSave1.FileName := 'GB18030_UTF16.txt';
  if dlgSave1.Execute then
  begin
    WS.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  WS.Free;
end;

procedure TFormGB18030.btnGenUtf16PageClick(Sender: TObject);
var
  SL: TCnAnsiStringList;
begin
  SL := TCnAnsiStringList.Create;

  Gen2Utf16ToGB18030Page(0, 0, $FF, $FF, SL);
  // Gen2Utf16ToGB18030Page($54, $03, $54, $03, SL);
  dlgSave1.FileName := 'UTF16_GB18030.txt';
  if dlgSave1.Execute then
  begin
    SL.SaveToFile(dlgSave1.FileName);
    ShowMessage('Save to ' + dlgSave1.FileName);
  end;
  SL.Free;
end;

procedure TFormGB18030.Gen2Utf16ToGB18030Page(FromH, FromL, ToH, ToL: Byte;
  Content: TCnAnsiStringList; H2: Word);
var
  H, L, T: Integer;
  GBCP, UCP: TCnCodePoint;
  S, C: AnsiString;
begin
  for H := FromH to ToH do
  begin
    for L := FromL to ToL do
    begin
      UCP := ((H shl 8) or L) + (H2 shl 16);
      GBCP := CodePointUtf16ToGB18130(UCP);
      if GBCP <> CN_INVALID_CODEPOINT then
      begin
        T := GetGB18030CharsFromCodePoint(GBCP, nil);
        SetLength(C, T);
        GetGB18030CharsFromCodePoint(GBCP, @C[1]);

        S := IntToHex(UCP, 2) + ' = ' + IntToHex(GBCP, 2) + '  ' + C;
      end
      else
        S := IntToHex(UCP, 2) + ' = ';

      Content.Add(S);
    end;
  end;
end;

function TFormGB18030.Gen4GB18030ToUtf16Page(From4, To4: TCnCodePoint;
  Content: TCnWideStringList): Integer;
var
  GBCP, UCP: TCnCodePoint;
  T: Integer;
  S, C: WideString;

  procedure Step4GB18030CodePoint(var CP: TCnCodePoint);
  var
    B2, B3, B4: Byte;
  begin
    repeat
      Inc(CP);
      B4 := Byte(CP);
      B3 := Byte(CP shr 8);
      B2 := Byte(CP shr 16);
    until (B4 in [$30..$39]) and (B3 in [$81..$FE]) and (B2 in [$30..$39]);
  end;

begin
  Result := 0;
  GBCP := From4;
  while GBCP <= To4 do
  begin
    UCP := CodePointGB18130ToUtf16(GBCP);
    T := GetUtf16CharFromCodePoint(UCP, nil);
    SetLength(C, T);
    GetUtf16CharFromCodePoint(UCP, @C[1]);

    if chkIncludeCharValue.Checked then
      S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2) + '  ' + C
    else
      S := IntToHex(GBCP, 2) + ' = ' + IntToHex(UCP, 2);

    Content.Add(S);
    Inc(Result);

    Step4GB18030CodePoint(GBCP);
  end;
end;

end.
