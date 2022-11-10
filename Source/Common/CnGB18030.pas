{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnGB18030;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�֧�� GB18030 ���ַ����� Unicode �Ĺ��ߵ�Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��GB18030 ���ַ�����Ϊ����� GBK/GB2312���ʴ˱������Ƿǵȿ��ַ�����
*           �ַ������� ASCII ��һ�ֽڡ���ͨ���ֵĶ��ֽڡ���Ƨ���ֵ����ֽ�����
*           �Ҿ��ǰ��Ķ�ϰ�߽������У������� AnsiString
*           �� Delphi �� WideString �� UnicodeString �� UTF16-LE��˫�ֽڱ����еߵ�
*           ���硰�Է��������֣�
*           AnsiString �ڴ����� B3D4B7B9��GB18030����Ҳ�� B3D4 �� B7B9 �����Ķ�˳��
*           UnicodeString �ڴ����� 03546D99���� Unicode ����ȴ�� 5403 �� 996D���з���
*
*           GB18030 �У��ַ��ı���ֵ����ʵ�ʱ�������
*           UTF16 �У�����ƽ���ڵı���ֵ���������ֽڣ�����ʵ�����ֽڱ��뷽ʽ��ͬ
*
*           ϵͳ�� UtfEncode �����ܹ���ȷ�������ֽ� UTF16-LE��ע�� UTF8 ת������
*           ���ֽ� UTF16 �ַ��ı���ֵ������ת�����ֽڱ������ UTF8-MB4 �㹻����
*
* ����ƽ̨��PWin98SE + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.11.11
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

// {$DEFINE UTF16_BE}

// Delphi Ĭ�� UTF16-LE�����Ҫ���� UTF16-BE �ַ�������Ҫ���� UTF16_BE

uses
  SysUtils, Classes, CnNative;

type
{$IFDEF SUPPORT_ANSISTRING_CODEPAGE}
  TCnGB18130String = RawByteString;
{$ELSE}
  TCnGB18130String = AnsiString;
{$ENDIF}
  {* GB18130 ������ַ������ڲ��� RawByteString Ҳ���� AnsiString($FFFF) ��ʾ}

  PCnGB18130String = ^TCnGB18130String;

  PCnGB18130StringPtr = PAnsiChar;
  {* GB18130 ������ַ�ָ�룬�ڲ��� PAnsiChar ��ʾ}

  TCnCodePoint = type Cardinal;

  TCn2CharRec = packed record
    P1: AnsiChar;
    P2: AnsiChar;
  end;
  PCn2CharRec = ^TCn2CharRec;

  TCn4CharRec = packed record
    P1: AnsiChar;
    P2: AnsiChar;
    P3: AnsiChar;
    P4: AnsiChar;
  end;
  PCn4CharRec = ^TCn4CharRec;

function GetCharLengthFromUtf8(Utf8Str: PAnsiChar): Integer;
{* ����һ UTF8�������� UTF8MB4���ַ������ַ���}

function GetCharLengthFromUtf16(Utf16Str: PWideChar): Integer;
{* ����һ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ������ַ���}

function GetCharLengthFromGB18130(GB18130Str: PCnGB18130StringPtr): Integer;
{* ����һ GB18130 �ַ������ַ���}

function GetByteWidthFromUtf8(Utf8Str: PAnsiChar): Integer;
{* ����һ UTF8�������� UTF8MB4���ַ����ĵ�ǰ�ַ�ռ�����ֽ�}

function GetByteWidthFromUtf16(Utf16Str: PWideChar): Integer;
{* ����һ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ����ĵ�ǰ�ַ�ռ�����ֽ�}

function GetByteWidthFromGB18130(GB18130Str: PCnGB18130StringPtr): Integer;
{* ����һ GB18130 �ַ����ĵ�ǰ�ַ�ռ�����ֽ�}

function UnicodeToGB18130(Utf16Str: PWideChar; GB18130Str: PCnGB18130StringPtr): Integer;
{* ��һ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ���ת��Ϊ GB18130 �ַ���
  GB18130Str ��ָ������������ת���Ľ�����紫 nil���򲻽���ת��
  ����ֵ���� GB18130Str ����ı��س��Ȼ�ת����ı��س��ȣ�������ĩβ�� #0}

function GB18130ToUtf16(GB18130Str: PCnGB18130StringPtr; Utf16Str: PWideChar): Integer;
{* ��һ GB18130 �ַ���ת��Ϊ UTF16�����ܻ�� Unicode ��չƽ��������ֽ��ַ����ַ���
  UniStr ��ָ������������ת���Ľ�����紫 nil���򲻽���ת��
  ����ֵ���� UniStr �����˫�ֽ��ַ����Ȼ�ת�����˫�ֽ��ַ����ȣ�������ĩβ�Ŀ��ַ� #0}

function GetGB18130FromUtf16(Utf16Str: PWideChar): TCnGB18130String;
{* ����һ Unicode �ַ�����Ӧ�� GB18130 �ַ���}

{$IFDEF UNICODE}

function GetUtf16FromGB18130(GB18130Str: TCnGB18130String): string;
{* ����һ GB18130 �ַ�����Ӧ�� Utf16 �ַ���}

{$ELSE}

function GetUtf16FromGB18130(GB18130Str: TCnGB18130String): WideString;
{* ����һ GB18130 �ַ�����Ӧ�� Utf16 �ַ���}

{$ENDIF}

function GetCodePointFromUtf16Char(Utf16Str: PWideChar): TCnCodePoint;
{* ����һ�� Utf16 �ַ��ı���ֵ��Ҳ�д���λ�ã���ע�� Utf16Str ����ָ��һ��˫�ֽ��ַ���Ҳ����ָ��һ�����ֽ��ַ�}

function GetCodePointFromUtf164Char(PtrTo4Char: Pointer): TCnCodePoint;
{* ����һ�����ֽ� Utf16 �ַ��ı���ֵ��Ҳ�д���λ�ã�}

function GetUtf16CharFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
{* ����һ�� Unicode ����ֵ�Ķ��ֽڻ����ֽڱ�ʾ��������� PtrTo4Char ��ָ�Ķ��ֽڻ����ֽ�����
  �������� CP ���� $FFFF ʱ�뱣֤ PtrToChars ��ָ�������������ֽڣ���֮���ֽڼ���
  ���� 1 �� 2���ֱ��ʾ������Ƕ��ֽڻ����ֽ�}

function GetUtf16HighByte(Rec: PCn2CharRec): Byte; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* �õ�һ�� UTF 16 ˫�ֽ��ַ��ĸ�λ�ֽ�ֵ}

function GetUtf16LowByte(Rec: PCn2CharRec): Byte; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* �õ�һ�� UTF 16 ˫�ֽ��ַ��ĵ�λ�ֽ�ֵ}

procedure SetUtf16HighByte(B: Byte; Rec: PCn2CharRec); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* ����һ�� UTF 16 ˫�ֽ��ַ��ĸ�λ�ֽ�ֵ}

procedure SetUtf16LowByte(B: Byte; Rec: PCn2CharRec); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
{* ����һ�� UTF 16 ˫�ֽ��ַ��ĵ�λ�ֽ�ֵ}

implementation

const
  CN_UTF16_4CHAR_PREFIX1_LOW  = $D8;
  CN_UTF16_4CHAR_PREFIX1_HIGH = $DC;
  CN_UTF16_4CHAR_PREFIX2_LOW  = $DC;
  CN_UTF16_4CHAR_PREFIX2_HIGH = $E0;

  CN_UTF16_4CHAR_HIGH_MASK    = $3;
  CN_UTF16_4CHAR_SPLIT_MASK   = $3FF;

  CN_UTF16_EXT_BASE           = $10000;

  CN_GB18030_BOM: array[0..3] of Byte = ($84, $31, $95, $33);

function GetUtf16HighByte(Rec: PCn2CharRec): Byte;
begin
{$IFDEF UTF16_BE}
  Result := Byte(Rec^.P1);
{$ELSE}
  Result := Byte(Rec^.P2); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

function GetUtf16LowByte(Rec: PCn2CharRec): Byte;
begin
{$IFDEF UTF16_BE}
  Result := Byte(Rec^.P2);
{$ELSE}
  Result := Byte(Rec^.P1); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

procedure SetUtf16HighByte(B: Byte; Rec: PCn2CharRec);
begin
{$IFDEF UTF16_BE}
  Rec^.P1 := AnsiChar(B);
{$ELSE}
  Rec^.P2 := AnsiChar(B); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

procedure SetUtf16LowByte(B: Byte; Rec: PCn2CharRec);
begin
{$IFDEF UTF16_BE}
  Rec^.P2 := AnsiChar(B);
{$ELSE}
  Rec^.P1 := AnsiChar(B); // UTF16-LE �ĸߵ�λ���û�
{$ENDIF}
end;

function GetCharLengthFromUtf8(Utf8Str: PAnsiChar): Integer;
var
  L: Integer;
begin
  Result := 0;
  while Utf8Str^ <> #0 do
  begin
    L := GetByteWidthFromUtf8(Utf8Str);
    Inc(Utf8Str, L);
    Inc(Result);
  end;
end;

function GetCharLengthFromUtf16(Utf16Str: PWideChar): Integer;
var
  L: Integer;
begin
  Result := 0;
  while Utf16Str^ <> #0 do
  begin
    L := GetByteWidthFromUtf16(Utf16Str);
    Utf16Str := PWideChar(TCnNativeInt(Utf16Str) + L);
    Inc(Result);
  end;
end;

function GetCharLengthFromGB18130(GB18130Str: PCnGB18130StringPtr): Integer;
var
  L: Integer;
begin
  Result := 0;
  while GB18130Str^ <> #0 do
  begin
    L := GetByteWidthFromGB18130(GB18130Str);
    Inc(GB18130Str, L);
    Inc(Result);
  end;
end;

function GetByteWidthFromUtf8(Utf8Str: PAnsiChar): Integer;
var
  B: Byte;
begin
  B := Byte(Utf8Str^);
  if B >= $FC then        // 6 �� 1��1 �� 0���Ȳ������߻�� 1 �����
    Result := 6
  else if B >= $F8 then   // 5 �� 1��1 �� 0
    Result := 5
  else if B >= $F0 then   // 4 �� 1��1 �� 0
    Result := 4
  else if B >= $E0 then   // 3 �� 1��1 �� 0
    Result := 3
  else if B >= $B0 then   // 2 �� 1��1 �� 0
    Result := 2
  else                    // ����
    Result := 1;
end;

function GetByteWidthFromUtf16(Utf16Str: PWideChar): Integer;
var
  P: PCn2CharRec;
  B1, B2: Byte;
begin
  Result := 2;

  P := PCn2CharRec(Utf16Str);
  B1 := GetUtf16HighByte(P);

  if (B1 >= CN_UTF16_4CHAR_PREFIX1_LOW) and (B1 < CN_UTF16_4CHAR_PREFIX1_HIGH) then
  begin
    // ����������ֽ��ַ�����ֵ�ֱ��� $D800 �� $DBFF ֮��
    Inc(P);
    B2 := GetUtf16HighByte(P);

    // ��ô�����ں�����������ֽ��ַ�Ӧ���� $DC00 �� $DFFF ֮�䣬
    if (B2 >= CN_UTF16_4CHAR_PREFIX2_LOW) and (B2 < CN_UTF16_4CHAR_PREFIX2_HIGH) then
      Result := 4;

    // ���ĸ��ֽ����һ�����ֽ� Unicode �ַ��������Ǹ�ֵ�ı���ֵ
  end;
end;

function GetByteWidthFromGB18130(GB18130Str: PCnGB18130StringPtr): Integer;
var
  B1, B2, B3, B4: Byte;
begin
  Result := 1;
  B1 := Byte(GB18130Str^);
  if B1 <= $7F then
    Exit;

  Inc(GB18130Str);
  B2 := Byte(GB18130Str^);

  if (B1 >= $81) and (B1 <= $FE) then
  begin
    if ((B2 >= $40) and (B2 <= $7E)) or
      ((B2 >= $80) and (B2 <= $FE)) then
      Result := 2
    else if (B2 >= $30) and (B2 <= $39) then
    begin
      Inc(GB18130Str);
      B3 := Byte(GB18130Str^);
      Inc(GB18130Str);
      B4 := Byte(GB18130Str^);

      if ((B3 >= $81) and (B3 <= $FE)) or
      ((B4 >= $30) and (B4 <= $39)) then
        Result := 4;
    end;
  end;
end;

function UnicodeToGB18130(Utf16Str: PWideChar; GB18130Str: PCnGB18130StringPtr): Integer;
begin

end;

function GB18130ToUtf16(GB18130Str: PCnGB18130StringPtr; Utf16Str: PWideChar): Integer;
begin

end;

function GetGB18130FromUtf16(Utf16Str: PWideChar): TCnGB18130String;
var
  L: Integer;
begin
  L := UnicodeToGB18130(Utf16Str, nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    UnicodeToGB18130(Utf16Str, @Result[1]);
  end;
end;

{$IFDEF UNICODE}

function GetUtf16FromGB18130(GB18130Str: TCnGB18130String): string;
var
  L: Integer;
begin
  L := GB18130ToUtf16(PCnGB18130StringPtr(GB18130Str), nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    GB18130ToUtf16(PCnGB18130StringPtr(GB18130Str), @Result[1]);
  end;
end;

{$ELSE}

function GetUtf16FromGB18130(GB18130Str: TCnGB18130String): WideString;
var
  L: Integer;
begin
  L := GB18130ToUtf16(PCnGB18130StringPtr(GB18130Str), nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    GB18130ToUtf16(PCnGB18130StringPtr(GB18130Str), @Result[1]);
  end;
end;

{$ENDIF}

function GetCodePointFromUtf16Char(Utf16Str: PWideChar): TCnCodePoint;
var
  R: Word;
  C2: PCn2CharRec;
begin
  if GetByteWidthFromUtf16(Utf16Str) = 4 then // ���ֽ��ַ�
    Result := GetCodePointFromUtf164Char(PAnsiChar(Utf16Str))
  else  // ��ͨ˫�ֽ��ַ�
  begin
    C2 := PCn2CharRec(Utf16Str);
    R := Byte(C2^.P1) shl 8 + Byte(C2^.P2);       // ˫�ֽ��ַ���ֵ������Ǳ���ֵ

{$IFDEF UTF16_BE}
    Result := TCnCodePoint(R);
{$ELSE}
    Result := TCnCodePoint(Int16ToBigEndian(R));  // UTF16-LE Ҫ����ֵ
{$ENDIF}
  end;
end;

function GetCodePointFromUtf164Char(PtrTo4Char: Pointer): TCnCodePoint;
var
  TH, TL: Word;
  C2: PCn2CharRec;
begin
  C2 := PCn2CharRec(PtrTo4Char);

  // ��һ���ֽڣ�ȥ����λ�� 110110���ڶ����ֽ����ţ��� 2 + 8 = 10 λ
  TH := (GetUtf16HighByte(C2) and CN_UTF16_4CHAR_HIGH_MASK) shl 8 + GetUtf16LowByte(C2);
  Inc(C2);

  // �������ֽڣ�ȥ����λ�� 110111�����ĸ��ֽ����ţ��� 2 + 8 = 10 λ
  TL := (GetUtf16HighByte(C2) and CN_UTF16_4CHAR_HIGH_MASK) shl 8 + GetUtf16LowByte(C2);

  // �� 10 λƴ�� 10 λ
  Result := TH shl 10 + TL + CN_UTF16_EXT_BASE;
  // ����ȥ $10000 ���ֵ��ǰ 10 λӳ�䵽 $D800 �� $DBFF ֮�䣬�� 10 λӳ�䵽 $DC00 �� $DFFF ֮��
end;

function GetUtf16CharFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
var
  C2: PCn2CharRec;
  L, H: Byte;
  LW, HW: Word;
begin
  if CP >= CN_UTF16_EXT_BASE then
  begin
    CP := CP - CN_UTF16_EXT_BASE;
    // ����� 10 λ��ǰ���ֽڣ������ 10 λ�ź����ֽ�

    LW := CP and CN_UTF16_4CHAR_SPLIT_MASK;          // �� 10 λ�����������ֽ�
    HW := (CP shr 10) and CN_UTF16_4CHAR_SPLIT_MASK; // �� 10 λ����һ�����ֽ�

    L := HW and $FF;
    H := (HW shr 8) and CN_UTF16_4CHAR_HIGH_MASK;
    H := H or CN_UTF16_4CHAR_PREFIX1_LOW;              // 1101 1000
    C2 := PCn2CharRec(PtrToChars);

    SetUtf16LowByte(L, C2);
    SetUtf16HighByte(H, C2);

    L := LW and $FF;
    H := (LW shr 8) and CN_UTF16_4CHAR_HIGH_MASK;
    H := H or CN_UTF16_4CHAR_PREFIX1_HIGH;              // 1101 1100
    Inc(C2);

    SetUtf16LowByte(L, C2);
    SetUtf16HighByte(H, C2);
    Result := 2;
  end
  else
  begin
    C2 := PCn2CharRec(PtrToChars);
    SetUtf16LowByte(Byte(CP and $00FF), C2);
    SetUtf16HighByte(Byte(CP shr 8), C2);
    Result := 1;
  end;
end;

end.

