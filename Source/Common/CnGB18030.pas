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
* ��Ԫ���ƣ�֧�� GB18030 ���ַ��� 2022 �� Unicode �Ĺ��ߵ�Ԫ
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
*           GB18030 �ı���ȡֵ��Χ��ʮ�����ƣ�
*           ע�⣺˫�ֽڵ� AABB~CCDD �ķ�Χ����ͨ�������ϵ����� FF �ٽ�λ��
*             ���Ǵ���ǰһ���ֽ� AA �� CC���Һ�һ���ֽ� CC �� DD���������� AAFF ���֡�
*           �����ֽ�ȴ�ֲ�ͬ�������ֽ����� 30~39��û�� 40�������� 40 ʱ������ֽڽ�λ��
*             �����ֽ�˳�����ӣ������� 81~FE��û�� FF������ FF ʱ��ڶ��ֽڽ�λ��
*             �ڶ��ֽ�Ҳ˳�����ӣ������� 30~39��û�� 40�������� 40 ʱ���һ�ֽڽ�λ��
*             ��һ�ֽ�Ҳ˳�����ӣ������� 81~FE��û�� FF������ FF ʱ��׼�����硣
*
*           ���ֽڣ�00~7F
*           ˫�ֽڣ������������й��޹ص����������ַ���
*                   A1A9~A1FE                     1 ��
*                   A840~A97E, A880~A9A0          5 ��
*                   B0A1~F7FE                     2 ������
*                   8140~A07E, 8180~A0FE          3 ������
*                   AA40~FE7E, AA80~FEA0          4 ������
*                   AAA1~AFFE                     �û� 1 ��
*                   F8A1~FEFE                     �û� 2 ��
*                   A140~A77E, A180~A7A0          �û� 3 ��
*           ���ֽڣ������������й��޹ص����������ַ���������������Ǳ���λ����������������Ч�ַ�����
*                            81308130~81318131            �ָ���һ
*                   81318132~81319934             ά����������ˡ��¶�������                     243    42
*                            81319935~8132E833            �ָ�����
*                   8132E834~8132FD31             ����                                           208    193
*                            8132FD32~81339D35            �ָ�����
*                   81339D36~8133B635             ��������ĸ                                     250    69
*                            8133B636~8134D237            �ָ�����
*                   8134D238~8134E337             �ɹ��ģ��������ġ���߯�ġ������ĺͰ�������֣� 170    149
*                            8134E337~8134F433            �ָ�����
*                   8134F434~8134F830             �º����                                       37     35
*                            8134F831~8134F931            �ָ�����                               8+2
*                   8134F932~81358437             ��˫�����´���                                 96     83
*                            81358438~81358B31            �ָ�����
*                   81358B32~81359935             ��˫�����ϴ���                                 144    127
*                            81359936~81398B31            �ָ�����
*                   81398B32~8139A035             �������ף��淶���󽫽�βд�� 8139A135��        224    214
*                            8139A036~8139A932            �ָ�����
*                   8139A933~8139B734             �����ļ�����ĸ                                 142    51
*                            8139B735~8139EE38            �ָ���ʮ
*                   8139EE39~82358738             CJK ͳһ�������� A                             6530   6530
*                            82358739~82358F32            �ָ���ʮһ
*                   82358F33~82359636             CJK ͳһ����                                   74     66
*                            82359637~82359832            �ָ���ʮ��
*                   82359833~82369435             ����                                           1223   1215
*                            82369436~82369534            �ָ���ʮ��
*                   82369535~82369A32             ������                                         48     48
*                            82369A33~8237CF34            �ָ���ʮ��
*                   8237CF35~8336BE36             ����������                                     11172  3431
*                            8336BE37~8430BA31            �ָ���ʮ��
*                   8430BA32~8430FE35             ά����������ˡ��¶�������                     684    59
*                            8430FE36~84318639            �ָ���ʮ��
*                   84318730~84319530             ά����������ˡ��¶�������                     141    84
*                            84319531~8431A439            �ָ���ʮ����������������ֹ�� FFFF
*                                                 ���¿�����淶����������������ʵ��Ӧ����ֻ��ʡ���ˣ�
*                   9034C538~9034C730             �ɹ��� BIRGA                                   13     13
*                            9034C731~9034C739            �ָ���ʮ�߿�ͷһ�飬ʵ���ϵ� 9232C635
*                   9232C636~9232D635             �ᶫ������                                     160    133
*                            9232D636~9232D639            �ָ���ʮ�˿�ͷһ�飬ʵ���ϵ� 95328235
*                   95328236~9835F336             CJK ͳһ�������� B                             42711  42711
*                            9835F337~9835F737            �ָ���ʮ��
*                   9835F738~98399E36             CJK ͳһ�������� C                             4149   4149
*                            98399E37~98399F37            �ָ�����ʮ
*                   98399F38~9839B539             CJK ͳһ�������� D                             222    222
*                            9839B630~9839B631            �ָ�����ʮһ                           2
*                   9839B632~9933FE33             CJK ͳһ�������� E                             5762   5762
*                            9933FE34~99348137            �ָ�����ʮ��
*                   99348138~9939F730             CJK ͳһ�������� F                             7473   7473
*                            9939F731~9A348431            �ָ�����ʮ����������������ֹ�� 2FFFF
*
*                   FD308130~FE39FE39             �û��Զ�������Ŀǰ�� Unicode ӳ��
*
*           ע�⣺ÿ�����ֽ����������������ڻ���������ڹ涨����Ч�ַ�����
*              ��ʣ�����Ч�ַ�����Ч�ַ�һ����ͬ���� Unicode �ַ�ֵӳ�䡣
*              ����������֮��ķָ���������ͬ���� Unicode �ַ�ֵӳ�䣬ֻ��û����Ч�ַ���
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

const
  CN_INVALID_CODEPOINT = $FFFFFFFF;

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

function Utf16ToGB18130(Utf16Str: PWideChar; GB18130Str: PCnGB18130StringPtr): Integer;
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
{* ����һ�� Unicode ����ֵ�Ķ��ֽڻ����ֽڱ�ʾ����� PtrToChars ָ���λ�ò�Ϊ�գ�
  �򽫽������ PtrToChars ��ָ�Ķ��ֽڻ����ֽ�����
  �������� CP ���� $FFFF ʱ�뱣֤ PtrToChars ��ָ�������������ֽڣ���֮���ֽڼ���
  ���� 1 �� 2���ֱ��ʾ������Ƕ��ֽڻ����ֽ�}

function GetCodePointFromGB18030Char(PtrToGB18030Chars: PCnGB18130StringPtr): TCnCodePoint;
{* ����һ�� GB18030 �ַ��ı���ֵ��Ҳ�д���λ�ã���ע�� PtrToGB18030Chars ����ָ��һ������˫�����ֽ��ַ�}

function GetGB18030CharsFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
{* ����һ�� GB18030 ����ֵ��һ�ֽڻ���ֽڻ����ֽڱ�ʾ����� PtrToChars ָ���λ�ò�Ϊ����ת��������ݷ���ͷ
   ����ֵ��ת�����ֽ�����1 �� 2 �� 4}

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

function Utf16ToGB18130(Utf16Str: PWideChar; GB18130Str: PCnGB18130StringPtr): Integer;
begin

end;

function GB18130ToUtf16(GB18130Str: PCnGB18130StringPtr; Utf16Str: PWideChar): Integer;
begin

end;

function GetGB18130FromUtf16(Utf16Str: PWideChar): TCnGB18130String;
var
  L: Integer;
begin
  L := Utf16ToGB18130(Utf16Str, nil);
  if L > 0 then
  begin
    SetLength(Result, L);
    Utf16ToGB18130(Utf16Str, @Result[1]);
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
    Result := TCnCodePoint(UInt16ToBigEndian(R)); // UTF16-LE Ҫ����ֵ
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
    if PtrToChars <> nil then
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
    end;
    Result := 2;
  end
  else
  begin
    if PtrToChars <> nil then
    begin
      C2 := PCn2CharRec(PtrToChars);
      SetUtf16LowByte(Byte(CP and $00FF), C2);
      SetUtf16HighByte(Byte(CP shr 8), C2);
    end;
    Result := 1;
  end;
end;

function GetCodePointFromGB18030Char(PtrToGB18030Chars: PCnGB18130StringPtr): TCnCodePoint;
var
  C1, C2, C3, C4: Byte;
begin
  Result := 0;
  C1 := Byte(PtrToGB18030Chars^);
  if C1 < $80 then
    Result := C1                                // ���ֽ�
  else if (C1 >= $81) and (C1 <= $FE) then
  begin
    Inc(PtrToGB18030Chars);
    C2 := Byte(PtrToGB18030Chars^);
    if ((C2 >= $40) and (C2 <= $7E)) or ((C2 >= $90) and (C2 <= $FE)) then 
      Result := C1 shl 8 + C2                   // ˫�ֽ�
    else if (C2 >= $30) and (C2 <= $39) then    // ���ֽ�
    begin
      Inc(PtrToGB18030Chars);
      C3 := Byte(PtrToGB18030Chars^);
      Inc(PtrToGB18030Chars);                   // ���ж����ֽڵ� 81 �� F3 �Լ����ֽڵ� 30 �� 39 ��
      C4 := Byte(PtrToGB18030Chars^);

      Result := C1 shl 24 + C2 shl 16 + C3 shl 8 + C4;
    end;
  end;
end;

function GetGB18030CharsFromCodePoint(CP: TCnCodePoint; PtrToChars: Pointer): Integer;
var
  P: PByte;
  C1, C2, C3, C4: Byte;
begin
  Result := 0;
  P := PByte(PtrToChars);
  if CP < $80 then
  begin
    if P <> nil then
      P^ := Byte(CP);
    Result := 1;
  end
  else
  begin
    C1 := CP and $FF000000 shr 24;
    C2 := CP and $00FF0000 shr 16;
    C3 := CP and $0000FF00 shr 8;
    C4 := CP and $000000FF;

    if (C1 = 0) and (C2 = 0) and ((C3 >= $81) and (C3 <= $FE)) and
      (((C4 >= $40) and (C4 <= $7E)) or ((C4 >= $80) and (C4 <= $FE))) then
    begin
      // �����ֽ��ַ�
      if P <> nil then
      begin
        P^ := C3;
        Inc(P);
        P^ := C4;
      end;
      Result := 2;
    end
    else if ((C1 >= $81) and (C1 <= $FE)) and ((C2 >= $30) and (C2 <= $39)) then
    begin
      // �����ֽ��ַ����ݲ��ж� C3 �� C4
      if P <> nil then
      begin
        P^ := C1;
        Inc(P);
        P^ := C2;
        Inc(P);
        P^ := C3;
        Inc(P);
        P^ := C4;
      end;
      Result := 4;
    end;
  end;
end;

end.

