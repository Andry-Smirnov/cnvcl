{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
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

unit CnRandom;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ��������䵥Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ�Win32/Win64/MacOS/Linux + Unicode/NonUnicode
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.01.15 V1.3
*               �� Windows ��ȫ���� urandom ��֧�� Linux
*           2023.01.08 V1.2
*               ���� Win64 �� API �����������������
*           2022.08.22 V1.1
*               ����ʹ�ò���ϵͳ�ṩ�������������
*           2020.03.27 V1.0
*               ������Ԫ���� CnPrimeNumber �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils {$IFDEF MSWINDOWS}, Windows {$ENDIF}, Classes, CnNative;

type
  ECnRandomAPIError = class(Exception);

function RandomUInt64: TUInt64;
{* ���� UInt64 ��Χ�ڵ���������ڲ�֧�� UInt64 ��ƽ̨���� Int64 ����}

function RandomUInt64LessThan(HighValue: TUInt64): TUInt64;
{* ���ش��ڵ��� 0 ��С��ָ�� UInt64 ֵ�������}

function RandomInt64: Int64;
{* ���ش��ڵ��� 0 ��С�� Int64 ���޵������}

function RandomInt64LessThan(HighValue: Int64): Int64;
{* ���ش��ڵ��� 0 ��С��ָ�� Int64 ֵ�������}

function CnRandomFillBytes(Buf: PAnsiChar; Len: Integer): Boolean;
{* ʹ�� Windows API �� /dev/random �豸ʵ�����������䣬�ڲ����γ�ʼ����������沢�ͷ�}

function CnRandomFillBytes2(Buf: PAnsiChar; Len: Integer): Boolean;
{* ʹ�� Windows API �� /dev/urandom �豸ʵ�����������䣬
  Windows ��ʹ����Ԥ�ȳ�ʼ���õ�����������}

implementation

{$IFDEF MSWINDOWS}

const
  ADVAPI32 = 'advapi32.dll';

  CRYPT_VERIFYCONTEXT = $F0000000;
  CRYPT_NEWKEYSET = $8;
  CRYPT_DELETEKEYSET = $10;

  PROV_RSA_FULL = 1;
  NTE_BAD_KEYSET = $80090016;

function CryptAcquireContext(phProv: PHandle; pszContainer: PAnsiChar;
  pszProvider: PAnsiChar; dwProvType: LongWord; dwFlags: LongWord): BOOL;
  stdcall; external ADVAPI32 name 'CryptAcquireContextA';

function CryptReleaseContext(hProv: THandle; dwFlags: LongWord): BOOL;
  stdcall; external ADVAPI32 name 'CryptReleaseContext';

function CryptGenRandom(hProv: THandle; dwLen: LongWord; pbBuffer: PAnsiChar): BOOL;
  stdcall; external ADVAPI32 name 'CryptGenRandom';

var
  FHProv: THandle = 0;

{$ELSE}

const
  DEV_FILE = '/dev/urandom';

{$ENDIF}

function CnRandomFillBytes(Buf: PAnsiChar; Len: Integer): Boolean;
var
{$IFDEF MSWINDOWS}
  HProv: THandle;
  Res: DWORD;
{$ELSE}
  F: TFileStream;
{$ENDIF}
begin
  Result := False;
{$IFDEF MSWINDOWS}
  // ʹ�� Windows API ʵ������������
  HProv := 0;
  if not CryptAcquireContext(@HProv, nil, nil, PROV_RSA_FULL, 0) then
  begin
    Res := GetLastError;
    if Res = NTE_BAD_KEYSET then // KeyContainer �����ڣ����½��ķ�ʽ
    begin
      if not CryptAcquireContext(@HProv, nil, nil, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext NewKeySet $%8.8x', [GetLastError]);
    end
    else
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext $%8.8x', [Res]);
  end;

  if HProv <> 0 then
  begin
    try
      Result := CryptGenRandom(HProv, Len, Buf);
      if not Result then
        raise ECnRandomAPIError.CreateFmt('Error CryptGenRandom $%8.8x', [GetLastError]);
    finally
      CryptReleaseContext(HProv, 0);
    end;
  end;
{$ELSE}
  // MacOS/Linux �µ�������ʵ�֣����ö�ȡ /dev/urandom ���ݵķ�ʽ��������
  F := nil;
  try
    F := TFileStream.Create(DEV_FILE, fmOpenRead);
    Result := F.Read(Buf^, Len) = Len;
  finally
    F.Free;
  end;
{$ENDIF}
end;

function CnRandomFillBytes2(Buf: PAnsiChar; Len: Integer): Boolean;
{$IFNDEF MSWINDOWS}
var
  F: TFileStream;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := CryptGenRandom(FHProv, Len, Buf);
{$ELSE}
  // MacOS/Linux �µ�������ʵ�֣����ö�ȡ /dev/urandom ���ݵķ�ʽ��������
  F := nil;
  try
    F := TFileStream.Create(DEV_FILE, fmOpenRead);
    Result := F.Read(Buf^, Len) = Len;
  finally
    F.Free;
  end;
{$ENDIF}
end;

function RandomUInt64: TUInt64;
var
  HL: array[0..1] of Cardinal;
begin
  // ������ϵͳ�������������
  if not CnRandomFillBytes2(@HL[0], SizeOf(TUInt64)) then
  begin
    // ֱ�� Random * High(TUInt64) ���ܻᾫ�Ȳ������� Lo ȫ FF����˷ֿ�����
    Randomize;
    HL[0] := Trunc(Random * High(Cardinal) - 1) + 1;
    HL[1] := Trunc(Random * High(Cardinal) - 1) + 1;
  end;

  Result := (TUInt64(HL[0]) shl 32) + HL[1];
end;

function RandomUInt64LessThan(HighValue: TUInt64): TUInt64;
begin
  Result := UInt64Mod(RandomUInt64, HighValue);
end;

function RandomInt64LessThan(HighValue: Int64): Int64;
var
  HL: array[0..1] of Cardinal;
begin
  // ������ϵͳ�������������
  if not CnRandomFillBytes2(@HL[0], SizeOf(Int64)) then
  begin
    // ֱ�� Random * High(Int64) ���ܻᾫ�Ȳ������� Lo ȫ FF����˷ֿ�����
    Randomize;
    HL[0] := Trunc(Random * High(Integer) - 1) + 1;   // Int64 ���λ������ 1�����⸺��
    HL[1] := Trunc(Random * High(Cardinal) - 1) + 1;
  end
  else
    HL[0] := HL[0] mod (Cardinal(High(Integer)) + 1);    // Int64 ���λ������ 1�����⸺��

  Result := (Int64(HL[0]) shl 32) + HL[1];
  Result := Result mod HighValue;
end;

function RandomInt64: Int64;
begin
  Result := RandomInt64LessThan(High(Int64));
end;

{$IFDEF MSWINDOWS}

procedure StartRandom;
var
  Res: DWORD;
begin
  FHProv := 0;
  if not CryptAcquireContext(@FHProv, nil, nil, PROV_RSA_FULL, 0) then
  begin
    Res := GetLastError;
    if Res = NTE_BAD_KEYSET then // KeyContainer �����ڣ����½��ķ�ʽ
    begin
      if not CryptAcquireContext(@FHProv, nil, nil, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext NewKeySet $%8.8x', [GetLastError]);
    end
    else
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext $%8.8x', [Res]);
  end;
end;

procedure StopRandom;
begin
  if FHProv <> 0 then
  begin
    CryptReleaseContext(FHProv, 0);
    FHProv := 0;
  end;
end;

initialization
  StartRandom;

finalization
  StopRandom;

{$ENDIF}

end.
