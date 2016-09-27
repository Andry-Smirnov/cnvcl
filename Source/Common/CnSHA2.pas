{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2016 CnPack ������                       }
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

unit CnSHA2;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�SHA2(SHA256)�㷨��Ԫ
* ��Ԫ���ߣ���Х��Liu Xiao��
* ��    ע��
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnSHA2.pas 426 2016-09-27 07:01:49Z liuxiao $
* �޸ļ�¼��2016.09.27 V1.0
*               ������Ԫ������������ C ������ Pascal ��������ֲ����
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

uses
  SysUtils, Windows, Classes;

type
  TSHA256Digest = array[0..31] of Byte;

  TSHA256Context = record
    DataLen: DWORD;
    Data: array[0..63] of Byte;
    BitLen: Int64;
    State: array[0..7] of DWORD;
    Ipad: array[0..63] of Byte;      {!< HMAC: inner padding        }
    Opad: array[0..63] of Byte;      {!< HMAC: outer padding        }
  end;

  TSHA256CalcProgressFunc = procedure(ATotal, AProgress: Int64; var Cancel:
    Boolean) of object;
  {* ���Ȼص��¼���������}

function SHA256Buffer(const Buffer; Count: LongWord): TSHA256Digest;
{* �����ݿ����SHA256ת��
 |<PRE>
   const Buffer     - Ҫ��������ݿ�
   Count: LongWord  - ���ݿ鳤��
 |</PRE>}

function SHA256String(const Str: string): TSHA256Digest;
{* ��String�������ݽ���SHA256ת����ע��D2009�����ϰ汾��stringΪUnicodeString��
   ��˶�ͬһ���ַ����ļ���������D2007�����°汾�Ļ᲻ͬ��ʹ��ʱ��ע��
 |<PRE>
   Str: string       - Ҫ������ַ���
 |</PRE>}

function SHA256StringA(const Str: AnsiString): TSHA256Digest;
{* ��AnsiString�������ݽ���SHA256ת��
 |<PRE>
   Str: AnsiString       - Ҫ������ַ���
 |</PRE>}

function SHA256StringW(const Str: WideString): TSHA256Digest;
{* �� WideString�������ݽ���SHA256ת��
 |<PRE>
   Str: WideString       - Ҫ������ַ���
 |</PRE>}

function SHA256File(const FileName: string; CallBack: TSHA256CalcProgressFunc =
  nil): TSHA256Digest;
{* ��ָ���ļ����ݽ���SHA256ת��
 |<PRE>
   FileName: string  - Ҫ������ļ���
   CallBack: TSHA256CalcProgressFunc - ���Ȼص�������Ĭ��Ϊ��
 |</PRE>}

function SHA256Stream(Stream: TStream; CallBack: TSHA256CalcProgressFunc = nil):
  TSHA256Digest;
{* ��ָ�������ݽ���SHA256ת��
 |<PRE>
   Stream: TStream  - Ҫ�����������
   CallBack: TSHA256CalcProgressFunc - ���Ȼص�������Ĭ��Ϊ��
 |</PRE>}

procedure SHA256Init(var Context: TSHA256Context);

procedure SHA256Update(var Context: TSHA256Context; Buffer: PAnsiChar; Len: Cardinal);

procedure SHA256Final(var Context: TSHA256Context; var Digest: TSHA256Digest);

function SHA256Print(const Digest: TSHA256Digest): string;
{* ��ʮ�����Ƹ�ʽ���SHA256����ֵ
 |<PRE>
   Digest: TSHA256Digest  - ָ����SHA256����ֵ
 |</PRE>}

function SHA256Match(const D1, D2: TSHA256Digest): Boolean;
{* �Ƚ�����SHA256����ֵ�Ƿ����
 |<PRE>
   D1: TSHA256Digest   - ��Ҫ�Ƚϵ�SHA256����ֵ
   D2: TSHA256Digest   - ��Ҫ�Ƚϵ�SHA256����ֵ
 |</PRE>}

function SHA256DigestToStr(aDig: TSHA256Digest): string;
{* SHA256����ֵת string
 |<PRE>
   aDig: TSHA256Digest   - ��Ҫת����SHA256����ֵ
 |</PRE>}

procedure SHA256HmacInit(var Context: TSHA256Context; Key: PAnsiChar; KeyLength: Integer);

procedure SHA256HmacUpdate(var Context: TSHA256Context; Input: PAnsiChar; Length:
  LongWord);

procedure SHA256HmacFinal(var Context: TSHA256Context; var Output: TSHA256Digest);

procedure SHA256Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA256Digest);
{* Hash-based Message Authentication Code (based on SHA256) }

implementation

const
  MAX_FILE_SIZE = 512 * 1024 * 1024;
  // If file size <= this size (bytes), using Mapping, else stream

  KEYS: array[0..63] of DWORD = ($428A2F98, $71374491, $B5C0FBCF, $E9B5DBA5,
    $3956C25B, $59F111F1, $923F82A4, $AB1C5ED5, $D807AA98, $12835B01, $243185BE,
    $550C7DC3, $72BE5D74, $80DEB1FE, $9BDC06A7, $C19BF174, $E49B69C1, $EFBE4786,
    $0FC19DC6, $240CA1CC, $2DE92C6F, $4A7484AA, $5CB0A9DC, $76F988DA, $983E5152,
    $A831C66D, $B00327C8, $BF597FC7, $C6E00BF3, $D5A79147, $06CA6351, $14292967,
    $27B70A85, $2E1B2138, $4D2C6DFC, $53380D13, $650A7354, $766A0ABB, $81C2C92E,
    $92722C85, $A2BFE8A1, $A81A664B, $C24B8B70, $C76C51A3, $D192E819, $D6990624,
    $F40E3585, $106AA070, $19A4C116, $1E376C08, $2748774C, $34B0BCB5, $391C0CB3,
    $4ED8AA4A, $5B9CCA4F, $682E6FF3, $748F82EE, $78A5636F, $84C87814, $8CC70208,
    $90BEFFFA, $A4506CEB, $BEF9A3F7, $C67178F2);
{$R-}

function ROTLeft256(A, B: DWORD): DWORD;
begin
  Result := (A shl B) or (A shr (32 - B));
end;

function ROTRight256(A, B: DWORD): DWORD;
begin
  Result := (A shr B) or (A shl (32 - B));
end;

function CH256(X, Y, Z: DWORD): DWORD;
begin
  Result := (X and Y) xor ((not X) and Z);
end;

function MAJ256(X, Y, Z: DWORD): DWORD;
begin
  Result := (X and Y) xor (X and Z) xor (Y and Z);
end;

function EP0256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 2) xor ROTRight256(X, 13) xor ROTRight256(X, 22);
end;

function EP1256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 6) xor ROTRight256(X, 11) xor ROTRight256(X, 25);
end;

function SIG0256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 7) xor ROTRight256(X, 18) xor (X shr 3);
end;

function SIG1256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 17) xor ROTRight256(X, 19) xor (X shr 10);
end;

procedure SHA256Transform(var Context: TSHA256Context; Data: PAnsiChar);
var
  A, B, C, D, E, F, G, H, T1, T2: DWORD;
  M: array[0..63] of DWORD;
  I, J: Integer;
begin
  I := 0;
  J := 0;
  while I < 16 do
  begin
    M[I] := (DWORD(Data[J]) shl 24) or (DWORD(Data[J + 1]) shl 16) or (DWORD(Data
      [J + 2]) shl 8) or DWORD(Data[J + 3]);
    Inc(I);
    Inc(J, 4);
  end;

  while I < 64 do
  begin
    M[I] := SIG1256(M[I - 2]) + M[I - 7] + SIG0256(M[I - 15]) + M[I - 16];
    Inc(I);
  end;

  A := Context.State[0];
  B := Context.State[1];
  C := Context.State[2];
  D := Context.State[3];
  E := Context.State[4];
  F := Context.State[5];
  G := Context.State[6];
  H := Context.State[7];

  I := 0;
  while I < 64 do
  begin
    T1 := H + EP1256(E) + CH256(E, F, G) + KEYS[I] + M[I];
    T2 := EP0256(A) + MAJ256(A, B, C);
    H := G;
    G := F;
    F := E;
    E := D + T1;
    D := C;
    C := B;
    B := A;
    A := T1 + T2;
    Inc(I);
  end;

  Context.State[0] := Context.State[0] + A;
  Context.State[1] := Context.State[1] + B;
  Context.State[2] := Context.State[2] + C;
  Context.State[3] := Context.State[3] + D;
  Context.State[4] := Context.State[4] + E;
  Context.State[5] := Context.State[5] + F;
  Context.State[6] := Context.State[6] + G;
  Context.State[7] := Context.State[7] + H;
end;

procedure SHA256Init(var Context: TSHA256Context);
begin
  Context.DataLen := 0;
  Context.BitLen := 0;
  Context.State[0] := $6A09E667;
  Context.State[1] := $BB67AE85;
  Context.State[2] := $3C6EF372;
  Context.State[3] := $A54FF53A;
  Context.State[4] := $510E527F;
  Context.State[5] := $9B05688C;
  Context.State[6] := $1F83D9AB;
  Context.State[7] := $5BE0CD19;
  FillChar(Context.Data, SizeOf(Context.Data), 0);
end;

procedure SHA256Update(var Context: TSHA256Context; Buffer: PAnsiChar; Len: Cardinal);
var
  I: Integer;
begin
  for I := 0 to Len - 1 do
  begin
    Context.Data[Context.DataLen] := Byte(Buffer[I]);
    Inc(Context.DataLen);
    if Context.DataLen = 64 then
    begin
      SHA256Transform(Context, @Context.Data[0]);
      Context.BitLen := Context.BitLen + 512;
      Context.DataLen := 0;
    end;
  end;
end;

procedure SHA256UpdateW(var Context: TSHA256Context; Buffer: PWideChar; Len: LongWord);
var
  Content: PAnsiChar;
  iLen: Cardinal;
begin
  GetMem(Content, Len * SizeOf(WideChar));
  try
    iLen := WideCharToMultiByte(0, 0, Buffer, Len, // ����ҳĬ���� 0
      PAnsiChar(Content), Len * SizeOf(WideChar), nil, nil);
    SHA256Update(Context, Content, iLen);
  finally
    FreeMem(Content);
  end;
end;

procedure SHA256Final(var Context: TSHA256Context; var Digest: TSHA256Digest);
var
  I: Integer;
begin
  I := Context.DataLen;
  if Context.Datalen < 56 then
  begin
    Context.Data[I] := $80;
    Inc(I);
    while I < 56 do
    begin
      Context.Data[I] := 0;
      Inc(I);
    end;
  end
  else
  begin
    Context.Data[I] := $80;
    Inc(I);
    while I < 64 do
    begin
      Context.Data[I] := 0;
      Inc(I);
    end;

    SHA256Transform(Context, @(Context.Data[0]));
    FillChar(Context.Data, 56, 0);
  end;

  Context.BitLen := Context.BitLen + Context.DataLen * 8;
  Context.Data[63] := Context.Bitlen;
  Context.Data[62] := Context.Bitlen shr 8;
  Context.Data[61] := Context.Bitlen shr 16;
  Context.Data[60] := Context.Bitlen shr 24;
  Context.Data[59] := Context.Bitlen shr 32;
  Context.Data[58] := Context.Bitlen shr 40;
  Context.Data[57] := Context.Bitlen shr 48;
  Context.Data[56] := Context.Bitlen shr 56;
  SHA256Transform(Context, @(Context.Data[0]));

  for I := 0 to 3 do
  begin
    Digest[I] := (Context.State[0] shr (24 - I * 8)) and $000000FF;
    Digest[I + 4] := (Context.State[1] shr (24 - I * 8)) and $000000FF;
    Digest[I + 8] := (Context.State[2] shr (24 - I * 8)) and $000000FF;
    Digest[I + 12] := (Context.State[3] shr (24 - I * 8)) and $000000FF;
    Digest[I + 16] := (Context.State[4] shr (24 - I * 8)) and $000000FF;
    Digest[I + 20] := (Context.State[5] shr (24 - I * 8)) and $000000FF;
    Digest[I + 24] := (Context.State[6] shr (24 - I * 8)) and $000000FF;
    Digest[I + 28] := (Context.State[7] shr (24 - I * 8)) and $000000FF;
  end;
end;

// �����ݿ����SHA256ת��
function SHA256Buffer(const Buffer; Count: Longword): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PAnsiChar(Buffer), Count);
  SHA256Final(Context, Result);
end;

// ��String�������ݽ���SHA256ת��
function SHA256String(const Str: string): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA256Final(Context, Result);
end;

// ��AnsiString�������ݽ���SHA256ת��
function SHA256StringA(const Str: AnsiString): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PAnsiChar(Str), Length(Str));
  SHA256Final(Context, Result);
end;

// ��WideString�������ݽ���SHA256ת��
function SHA256StringW(const Str: WideString): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256UpdateW(Context, PWideChar(Str), Length(Str));
  SHA256Final(Context, Result);
end;

function InternalSHA256Stream(Stream: TStream; const BufSize: Cardinal; var D:
  TSHA256Digest; CallBack: TSHA256CalcProgressFunc = nil): Boolean;
var
  Context: TSHA256Context;
  Buf: PAnsiChar;
  BufLen: Cardinal;
  Size: Int64;
  ReadBytes: Cardinal;
  TotalBytes: Int64;
  SavePos: Int64;
  CancelCalc: Boolean;
begin
  Result := False;
  Size := Stream.Size;
  SavePos := Stream.Position;
  TotalBytes := 0;
  if Size = 0 then
    Exit;
  if Size < BufSize then
    BufLen := Size
  else
    BufLen := BufSize;

  CancelCalc := False;
  SHA256Init(Context);
  GetMem(Buf, BufLen);
  try
    Stream.Seek(0, soFromBeginning);
    repeat
      ReadBytes := Stream.Read(Buf^, BufLen);
      if ReadBytes <> 0 then
      begin
        Inc(TotalBytes, ReadBytes);
        SHA256Update(Context, Buf, ReadBytes);
        if Assigned(CallBack) then
        begin
          CallBack(Size, TotalBytes, CancelCalc);
          if CancelCalc then
            Exit;
        end;
      end;
    until (ReadBytes = 0) or (TotalBytes = Size);
    SHA256Final(Context, D);
    Result := True;
  finally
    FreeMem(Buf, BufLen);
    Stream.Position := SavePos;
  end;
end;

// ��ָ��������SHA256����
function SHA256Stream(Stream: TStream; CallBack: TSHA256CalcProgressFunc = nil):
  TSHA256Digest;
begin
  InternalSHA256Stream(Stream, 4096 * 1024, Result, CallBack);
end;

// ��ָ���ļ����ݽ���SHA256ת��
function SHA256File(const FileName: string; CallBack: TSHA256CalcProgressFunc):
  TSHA256Digest;
var
  FileHandle: THandle;
  MapHandle: THandle;
  ViewPointer: Pointer;
  Context: TSHA256Context;
  Stream: TStream;
  FileIsZeroSize: Boolean;

  function FileSizeIsLargeThanMax(const AFileName: string; out IsEmpty: Boolean): Boolean;
  var
    H: THandle;
    Info: BY_HANDLE_FILE_INFORMATION;
    Rec: Int64Rec;
  begin
    Result := False;
    IsEmpty := False;
    H := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
      OPEN_EXISTING, 0, 0);
    if H = INVALID_HANDLE_VALUE then
      Exit;
    try
      if not GetFileInformationByHandle(H, Info) then
        Exit;
    finally
      CloseHandle(H);
    end;
    Rec.Lo := Info.nFileSizeLow;
    Rec.Hi := Info.nFileSizeHigh;
    Result := (Rec.Hi > 0) or (Rec.Lo > MAX_FILE_SIZE);
    IsEmpty := (Rec.Hi = 0) and (Rec.Lo = 0);
  end;

begin
  FileIsZeroSize := False;
  if FileSizeIsLargeThanMax(FileName, FileIsZeroSize) then
  begin
    // ���� 2G ���ļ����� Map ʧ�ܣ���������ʽѭ������
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      InternalSHA256Stream(Stream, 4096 * 1024, Result, CallBack);
    finally
      Stream.Free;
    end;
  end
  else
  begin
    SHA256Init(Context);
    FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ or
      FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or
      FILE_FLAG_SEQUENTIAL_SCAN, 0);
    if FileHandle <> INVALID_HANDLE_VALUE then
    begin
      try
        MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, 0, nil);
        if MapHandle <> 0 then
        begin
          try
            ViewPointer := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, 0, 0);
            if ViewPointer <> nil then
            begin
              try
                SHA256Update(Context, ViewPointer, GetFileSize(FileHandle, nil));
              finally
                UnmapViewOfFile(ViewPointer);
              end;
            end
            else
            begin
              raise Exception.Create('MapViewOfFile Failed. ' + IntToStr(GetLastError));
            end;
          finally
            CloseHandle(MapHandle);
          end;
        end
        else
        begin
          if not FileIsZeroSize then
            raise Exception.Create('CreateFileMapping Failed. ' + IntToStr(GetLastError));
        end;
      finally
        CloseHandle(FileHandle);
      end;
    end;
    SHA256Final(Context, Result);
  end;
end;

// ��ʮ�����Ƹ�ʽ���SHA256����ֵ
function SHA256Print(const Digest: TSHA256Digest): string;
var
  I: Byte;
const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := '';
  for I := 0 to 31 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// �Ƚ�����SHA256����ֵ�Ƿ����
function SHA256Match(const D1, D2: TSHA256Digest): Boolean;
var
  I: Byte;
begin
  I := 0;
  Result := TRUE;
  while Result and (I < 20) do
  begin
    Result := D1[I] = D2[I];
    Inc(I);
  end;
end;

// SHA256����ֵת string
function SHA256DigestToStr(aDig: TSHA256Digest): string;
var
  I: Integer;
begin
  SetLength(Result, 20);
  for I := 1 to 20 do
    Result[I] := Chr(aDig[I - 1]);
end;

procedure SHA256HmacInit(var Context: TSHA256Context; Key: PAnsiChar; KeyLength: Integer);
var
  I: Integer;
  Sum: TSHA256Digest;
begin
  if KeyLength > 64 then
  begin
    Sum := SHA256Buffer(Key, KeyLength);
    KeyLength := 32;
    Key := @(Sum[0]);
  end;

  FillChar(Context.Ipad, $36, 64);
  FillChar(Context.Opad, $5C, 64);

  for I := 0 to KeyLength - 1 do
  begin
    Context.Ipad[I] := Byte(Context.Ipad[I] xor Byte(Key[I]));
    Context.Opad[I] := Byte(Context.Opad[I] xor Byte(Key[I]));
  end;

  SHA256Init(Context);
  SHA256Update(Context, @(Context.Ipad[0]), 64);
end;

procedure SHA256HmacUpdate(var Context: TSHA256Context; Input: PAnsiChar; Length:
  LongWord);
begin
  SHA256Update(Context, Input, Length);
end;

procedure SHA256HmacFinal(var Context: TSHA256Context; var Output: TSHA256Digest);
var
  Len: Integer;
  TmpBuf: TSHA256Digest;
begin
  Len := 32;
  SHA256Final(Context, TmpBuf);
  SHA256Init(Context);
  SHA256Update(Context, @(Context.Opad[0]), 64);
  SHA256Update(Context, @(TmpBuf[0]), Len);
  SHA256Final(Context, Output);
end;

procedure SHA256Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA256Digest);
var
  Context: TSHA256Context;
begin
  SHA256HmacInit(Context, Key, KeyLength);
  SHA256HmacUpdate(Context, Input, Length);
  SHA256HmacFinal(Context, Output);
end;

end.

