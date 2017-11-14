{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2017 CnPack ������                       }
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

unit CnSHA3;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�SHA3(SHA3-224/256/384/512)�㷨��Ԫ
* ��Ԫ���ߣ���Х��Liu Xiao��
* ��    ע��D567�¿������з��� Int64 �����޷��� UInt64 ������ SHA512/384��ԭ����
*           ���ڲ���������޷������ļӼ���λ�Լ�������������Ƶȶ���ͬ��Ψһ��
*           ͬ���ǱȽϣ�������Ԫ��û�����ƵıȽϡ�
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnSHA2.pas 426 2016-09-27 07:01:49Z liuxiao $
* �޸ļ�¼��2017.11.10 V1.0
*               ������Ԫ������������ Keccak C ������ Pascal ��������ֲ����
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Windows, Classes;

type
  TSHA3GeneralDigest = array[0..63] of Byte;

  TSHA3_224Digest = array[0..27] of Byte;

  TSHA3_256Digest = array[0..31] of Byte;

  TSHA3_384Digest = array[0..47] of Byte;

  TSHA3_512Digest = array[0..63] of Byte;

  TSHA3Context = packed record
    State: array[0..24] of Int64;
    Index: DWORD;
    DigestLen: DWORD;
    Round: DWORD;
    BlockLen: DWORD;
    Block: array[0..255] of Byte;
    Ipad: array[0..63] of Byte;      {!< HMAC: inner padding        }
    Opad: array[0..63] of Byte;      {!< HMAC: outer padding        }
  end;

function SHA3_224Buffer(const Buffer; Count: LongWord): TSHA3_224Digest;
{* �����ݿ����SHA3_224ת��
 |<PRE>
   const Buffer     - Ҫ��������ݿ�
   Count: LongWord  - ���ݿ鳤��
 |</PRE>}

function SHA3_256Buffer(const Buffer; Count: LongWord): TSHA3_256Digest;
{* �����ݿ����SHA3_256ת��
 |<PRE>
   const Buffer     - Ҫ��������ݿ�
   Count: LongWord  - ���ݿ鳤��
 |</PRE>}

function SHA3_384Buffer(const Buffer; Count: LongWord): TSHA3_384Digest;
{* �����ݿ����SHA3_384ת��
 |<PRE>
   const Buffer     - Ҫ��������ݿ�
   Count: LongWord  - ���ݿ鳤��
 |</PRE>}

function SHA3_512Buffer(const Buffer; Count: LongWord): TSHA3_512Digest;
{* �����ݿ����SHA3_512ת��
 |<PRE>
  const Buffer     - Ҫ��������ݿ�
  Count: LongWord  - ���ݿ鳤��
 |</PRE>}

function SHA3_224String(const Str: string): TSHA3_224Digest;
{* ��String�������ݽ���SHA3_224ת����ע��D2009�����ϰ汾��stringΪUnicodeString��
   ��˶�ͬһ���ַ����ļ���������D2007�����°汾�Ļ᲻ͬ��ʹ��ʱ��ע��
 |<PRE>
   Str: string       - Ҫ������ַ���
 |</PRE>}

function SHA3_256String(const Str: string): TSHA3_256Digest;
{* ��String�������ݽ���SHA3_256ת����ע��D2009�����ϰ汾��stringΪUnicodeString��
   ��˶�ͬһ���ַ����ļ���������D2007�����°汾�Ļ᲻ͬ��ʹ��ʱ��ע��
 |<PRE>
   Str: string       - Ҫ������ַ���
 |</PRE>}

function SHA3_384String(const Str: string): TSHA3_384Digest;
{* ��String�������ݽ���SHA3_384ת����ע��D2009�����ϰ汾��stringΪUnicodeString��
   ��˶�ͬһ���ַ����ļ���������D2007�����°汾�Ļ᲻ͬ��ʹ��ʱ��ע��
 |<PRE>
   Str: string       - Ҫ������ַ���
 |</PRE>}

function SHA3_512String(const Str: string): TSHA3_512Digest;
{* ��String�������ݽ���SHA3_512ת����ע��D2009�����ϰ汾��stringΪUnicodeString��
   ��˶�ͬһ���ַ����ļ���������D2007�����°汾�Ļ᲻ͬ��ʹ��ʱ��ע��
 |<PRE>
   Str: string       - Ҫ������ַ���
 |</PRE>}

function SHA3_224StringA(const Str: AnsiString): TSHA3_224Digest;
{* ��AnsiString�������ݽ���SHA3_224ת��
 |<PRE>
   Str: AnsiString       - Ҫ������ַ���
 |</PRE>}

function SHA3_224StringW(const Str: WideString): TSHA3_224Digest;
{* �� WideString�������ݽ���SHA3_224ת��
 |<PRE>
   Str: WideString       - Ҫ������ַ���
 |</PRE>}

function SHA3_256StringA(const Str: AnsiString): TSHA3_256Digest;
{* ��AnsiString�������ݽ���SHA3_256ת��
 |<PRE>
   Str: AnsiString       - Ҫ������ַ���
 |</PRE>}

function SHA3_256StringW(const Str: WideString): TSHA3_256Digest;
{* �� WideString�������ݽ���SHA3_256ת��
 |<PRE>
   Str: WideString       - Ҫ������ַ���
 |</PRE>}

function SHA3_384StringA(const Str: AnsiString): TSHA3_384Digest;
{* ��AnsiString�������ݽ���SHA3_384ת��
 |<PRE>
   Str: AnsiString       - Ҫ������ַ���
 |</PRE>}

function SHA3_384StringW(const Str: WideString): TSHA3_384Digest;
{* �� WideString�������ݽ���SHA3_384ת��
 |<PRE>
   Str: WideString       - Ҫ������ַ���
 |</PRE>}

function SHA3_512StringA(const Str: AnsiString): TSHA3_512Digest;
{* ��AnsiString�������ݽ���SHA3_512ת��
|<PRE>
 Str: AnsiString       - Ҫ������ַ���
|</PRE>}

function SHA3_512StringW(const Str: WideString): TSHA3_512Digest;
{* �� WideString�������ݽ���SHA512ת��
|<PRE>
 Str: WideString       - Ҫ������ַ���
|</PRE>}




function SHA3_224Print(const Digest: TSHA3_224Digest): string;
{* ��ʮ�����Ƹ�ʽ���SHA3_224����ֵ
 |<PRE>
   Digest: TSHA3_224Digest  - ָ����SHA3_224����ֵ
 |</PRE>}

function SHA3_256Print(const Digest: TSHA3_256Digest): string;
{* ��ʮ�����Ƹ�ʽ���SHA3_256����ֵ
 |<PRE>
   Digest: TSHA3_256Digest  - ָ����SHA3_256����ֵ
 |</PRE>}

function SHA3_384Print(const Digest: TSHA3_384Digest): string;
{* ��ʮ�����Ƹ�ʽ���SHA3_384����ֵ
 |<PRE>
   Digest: TSHA3_384Digest  - ָ����SHA3_384����ֵ
 |</PRE>}

function SHA3_512Print(const Digest: TSHA3_512Digest): string;
{* ��ʮ�����Ƹ�ʽ���SHA3_512����ֵ
 |<PRE>
   Digest: TSHA3_512Digest  - ָ����SHA3_512����ֵ
 |</PRE>}

//procedure SHA3Init(var Context: TSHA3Context; SHA3Type: TSHA3Type);
//procedure SHA3Update(var Context: TSHA3Context; Buffer: PAnsiChar; Len: Cardinal);
//procedure SHA3Final(var Context: TSHA3Context; var Digest: TSHA3GeneralDigest);

implementation

type
  TSHA3Type = (stSHA3_224, stSHA3_256, stSHA3_384, stSHA3_512);

{$IFDEF SUPPORT_UINT64}
  TUInt64 = UInt64;
{$ELSE}
  // D 5,6,7 ���������з��ŵ� Int64 �������޷��ŵ� Int64
  TUInt64 = Int64;
{$ENDIF}

const
  SHA3_ROUNDS = 24;
  SHA3_STATE_LEN = 25;

  SHA3_224_OUTPUT_LENGTH_BYTE = 28;
  SHA3_256_OUTPUT_LENGTH_BYTE = 32;
  SHA3_384_OUTPUT_LENGTH_BYTE = 48;
  SHA3_512_OUTPUT_LENGTH_BYTE = 64;

  SHA3_224_BLOCK_SIZE_BYTE = 144;
  SHA3_256_BLOCK_SIZE_BYTE = 136;
  SHA3_384_BLOCK_SIZE_BYTE = 104;
  SHA3_512_BLOCK_SIZE_BYTE = 72;

  HMAC_SHA3_224_256_BLOCK_SIZE_BYTE = 64;
  HMAC_SHA3_384_512_BLOCK_SIZE_BYTE = 128;

  HMAC_SHA3_224_OUTPUT_LENGTH_BYTE = SHA3_224_OUTPUT_LENGTH_BYTE;
  HMAC_SHA3_256_OUTPUT_LENGTH_BYTE = SHA3_256_OUTPUT_LENGTH_BYTE;
  HMAC_SHA3_384_OUTPUT_LENGTH_BYTE = SHA3_384_OUTPUT_LENGTH_BYTE;
  HMAC_SHA3_512_OUTPUT_LENGTH_BYTE = SHA3_512_OUTPUT_LENGTH_BYTE;

  KECCAKF_ROUND_CONSTS: array[0..23] of TUInt64 = (
    $0000000000000001, $0000000000008082, $800000000000808A,
    $8000000080008000, $000000000000808B, $0000000080000001,
    $8000000080008081, $8000000000008009, $000000000000008A,
    $0000000000000088, $0000000080008009, $000000008000000A,
    $000000008000808B, $800000000000008B, $8000000000008089,
    $8000000000008003, $8000000000008002, $8000000000000080,
    $000000000000800A, $800000008000000A, $8000000080008081,
    $8000000000008080, $0000000080000001, $8000000080008008
  );

  KECCAKF_ROT_CONSTS: array[0..23] of Integer = (
    1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
    27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44
  );

  KECCAKF_PILN: array[0..23] of Integer = (
    10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4,
    15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
  );

function ROTL64(Q: TUInt64; N: Integer): TUInt64;
begin
  Result := (Q shl N) xor (Q shr (64 - N));
end;

procedure SHA3_Transform(var Context: TSHA3Context);
type
  PUInt64Array = ^TUInt64Array;
  TUInt64Array = array[0..4095] of TUInt64;
var
  I, J, R, L: Integer;
  P: PUInt64Array;
  T: TUInt64;
  BC: array[0..4] of TUInt64;
begin
  P := PUInt64Array(@(Context.Block[0]));
  I := 0;
  L := Integer(Context.BlockLen div 8);
  while I < L do
  begin
    Context.State[I] := Context.State[I] xor P^[I];
    Inc(I);
  end;

  for R := 0 to Context.Round - 1 do
  begin
    // Theta
    for I := 0 to 4 do
    begin
      BC[I] := Context.State[I] xor Context.State[I + 5] xor Context.State[I + 10]
        xor Context.State[I + 15] xor Context.State[I + 20];
    end;
    for I := 0 to 4 do
    begin
      T := BC[(I + 4) mod 5] xor ROTL64(BC[(I + 1) mod 5], 1);
      for J := 0 to 4 do
        Context.State[5 * J + I] := Context.State[5 * J + I] xor T;
    end;

    // Rho Pi
    T := Context.State[1];
    for I := 0 to 23 do
    begin
      J := KECCAKF_PILN[I];
      BC[0] := Context.State[J];
      Context.State[J] := ROTL64(T, KECCAKF_ROT_CONSTS[I]);
      T := BC[0];
    end;

    // Chi
    for J := 0 to 4 do
    begin
      for I := 0 to 4 do
        BC[I] := Context.State[5 * J + I];

      for I := 0 to 4 do
        Context.State[5 * J + I] := Context.State[5 * J + I] xor
          ((not BC[(I + 1) mod 5]) and BC[(I + 2) mod 5]);
    end;

    // Iota
    Context.State[0] := Context.State[0] xor KECCAKF_ROUND_CONSTS[R];
  end;
end;

procedure SHA3Init(var Context: TSHA3Context; SHA3Type: TSHA3Type);
begin
  FillChar(Context, SizeOf(TSHA3Context), 0);
  Context.Round := SHA3_ROUNDS;
  case SHA3Type of
  stSHA3_224:
    begin
      Context.BlockLen := SHA3_224_BLOCK_SIZE_BYTE;
      Context.DigestLen := SHA3_224_OUTPUT_LENGTH_BYTE;
    end;
  stSHA3_256:
    begin
      Context.BlockLen := SHA3_256_BLOCK_SIZE_BYTE;
      Context.DigestLen := SHA3_256_OUTPUT_LENGTH_BYTE;
    end;
  stSHA3_384:
    begin
      Context.BlockLen := SHA3_384_BLOCK_SIZE_BYTE;
      Context.DigestLen := SHA3_384_OUTPUT_LENGTH_BYTE;
    end;
  stSHA3_512:
    begin
      Context.BlockLen := SHA3_512_BLOCK_SIZE_BYTE;
      Context.DigestLen := SHA3_512_OUTPUT_LENGTH_BYTE;
    end;
  end;
end;

procedure SHA3Update(var Context: TSHA3Context; Buffer: PAnsiChar; Len: Cardinal);
var
  R, Idx: Cardinal;
begin
  Idx := Context.Index;
  repeat
    if Len < Context.BlockLen - Idx then
      R := Len
    else
      R := Context.BlockLen - Idx;

    CopyMemory(@(Context.Block[Idx]), Buffer, R);
    if (Idx + R) < Context.BlockLen then
    begin
      Idx := Idx + R;
      Break;
    end;

    SHA3_Transform(Context);
    Dec(Len, R);
    Idx := 0;
    Inc(Buffer, R);
  until False;
  Context.Index := Idx;
end;

procedure SHA3UpdateW(var Context: TSHA3Context; Buffer: PWideChar; Len: LongWord);
var
  Content: PAnsiChar;
  iLen: Cardinal;
begin
  GetMem(Content, Len * SizeOf(WideChar));
  try
    iLen := WideCharToMultiByte(0, 0, Buffer, Len, // ����ҳĬ���� 0
      PAnsiChar(Content), Len * SizeOf(WideChar), nil, nil);
    SHA3Update(Context, Content, iLen);
  finally
    FreeMem(Content);
  end;
end;

procedure SHA3Final(var Context: TSHA3Context; var Digest: TSHA3GeneralDigest);
begin
  Context.Block[Context.Index] := 6;
  Context.Block[Context.BlockLen - 1] := Context.Block[Context.BlockLen - 1] or $80;
  SHA3_Transform(Context);
  CopyMemory(@Digest[0], @(Context.State[0]), Context.DigestLen);
end;

// �����ݿ����SHA3_224ת��
function SHA3_224Buffer(const Buffer; Count: LongWord): TSHA3_224Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_224);
  SHA3Update(Context, PAnsiChar(Buffer), Count);
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_224_OUTPUT_LENGTH_BYTE);
end;

// �����ݿ����SHA3_256ת��
function SHA3_256Buffer(const Buffer; Count: LongWord): TSHA3_256Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_256);
  SHA3Update(Context, PAnsiChar(Buffer), Count);
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_256_OUTPUT_LENGTH_BYTE);
end;

// �����ݿ����SHA3_384ת��
function SHA3_384Buffer(const Buffer; Count: LongWord): TSHA3_384Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_384);
  SHA3Update(Context, PAnsiChar(Buffer), Count);
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_384_OUTPUT_LENGTH_BYTE);
end;

// �����ݿ����SHA3_512ת��
function SHA3_512Buffer(const Buffer; Count: LongWord): TSHA3_512Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_512);
  SHA3Update(Context, PAnsiChar(Buffer), Count);
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_512_OUTPUT_LENGTH_BYTE);
end;

// ��String�������ݽ���SHA3_224ת��
function SHA3_224String(const Str: string): TSHA3_224Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_224);
  SHA3Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_224_OUTPUT_LENGTH_BYTE);
end;

// ��String�������ݽ���SHA3_256ת��
function SHA3_256String(const Str: string): TSHA3_256Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_256);
  SHA3Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_256_OUTPUT_LENGTH_BYTE);
end;

// ��String�������ݽ���SHA3_384ת��
function SHA3_384String(const Str: string): TSHA3_384Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_384);
  SHA3Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_384_OUTPUT_LENGTH_BYTE);
end;

// ��String�������ݽ���SHA3_512ת��
function SHA3_512String(const Str: string): TSHA3_512Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_512);
  SHA3Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_512_OUTPUT_LENGTH_BYTE);
end;

// ��AnsiString�������ݽ���SHA224ת��
function SHA3_224StringA(const Str: AnsiString): TSHA3_224Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_224);
  SHA3Update(Context, PAnsiChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_224_OUTPUT_LENGTH_BYTE);
end;

// ��WideString�������ݽ���SHA3_224ת��
function SHA3_224StringW(const Str: WideString): TSHA3_224Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_224);
  SHA3UpdateW(Context, PWideChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_224_OUTPUT_LENGTH_BYTE);
end;

// ��AnsiString�������ݽ���SHA3_256ת��
function SHA3_256StringA(const Str: AnsiString): TSHA3_256Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_256);
  SHA3Update(Context, PAnsiChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_256_OUTPUT_LENGTH_BYTE);
end;

// ��WideString�������ݽ���SHA3_256ת��
function SHA3_256StringW(const Str: WideString): TSHA3_256Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_256);
  SHA3UpdateW(Context, PWideChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_256_OUTPUT_LENGTH_BYTE);
end;

// ��AnsiString�������ݽ���SHA3_384ת��
function SHA3_384StringA(const Str: AnsiString): TSHA3_384Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_384);
  SHA3Update(Context, PAnsiChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_384_OUTPUT_LENGTH_BYTE);
end;

// ��WideString�������ݽ���SHA3_384ת��
function SHA3_384StringW(const Str: WideString): TSHA3_384Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_384);
  SHA3UpdateW(Context, PWideChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_384_OUTPUT_LENGTH_BYTE);
end;

// ��AnsiString�������ݽ���SHA3_512ת��
function SHA3_512StringA(const Str: AnsiString): TSHA3_512Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_512);
  SHA3Update(Context, PAnsiChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_512_OUTPUT_LENGTH_BYTE);
end;

// ��WideString�������ݽ���SHA3_512ת��
function SHA3_512StringW(const Str: WideString): TSHA3_512Digest;
var
  Context: TSHA3Context;
  Res: TSHA3GeneralDigest;
begin
  SHA3Init(Context, stSHA3_512);
  SHA3UpdateW(Context, PWideChar(Str), Length(Str));
  SHA3Final(Context, Res);
  CopyMemory(@Result[0], @Res[0], SHA3_512_OUTPUT_LENGTH_BYTE);
end;

const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

// ��ʮ�����Ƹ�ʽ���SHA3_224����ֵ
function SHA3_224Print(const Digest: TSHA3_224Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to SHA3_224_OUTPUT_LENGTH_BYTE - 1 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// ��ʮ�����Ƹ�ʽ���SHA3_256����ֵ
function SHA3_256Print(const Digest: TSHA3_256Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to SHA3_256_OUTPUT_LENGTH_BYTE - 1 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// ��ʮ�����Ƹ�ʽ���SHA3_384����ֵ
function SHA3_384Print(const Digest: TSHA3_384Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to SHA3_384_OUTPUT_LENGTH_BYTE - 1 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// ��ʮ�����Ƹ�ʽ���SHA3_512����ֵ
function SHA3_512Print(const Digest: TSHA3_512Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to SHA3_512_OUTPUT_LENGTH_BYTE - 1 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

end.
