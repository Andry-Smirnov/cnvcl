{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
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

unit CnKeyDerivation;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����������㷨��KDF����Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.03.30 V1.0
*               ������Ԫ���� CnPemUtils �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnMD5, CnSHA2;

type
  TCnKeyDeriveHash = (ckdMd5, ckdSha256);

  ECnKeyDerivation = class(Exception);

function CnGetDeriveKey(const Password, Salt: AnsiString; OutKey: PAnsiChar; KeyLength: Cardinal;
  KeyHash: TCnKeyDeriveHash = ckdMd5): Boolean;
{* ������ Openssl �е� BytesToKey�������������ָ���� Hash �㷨���ɼ��� Key��
  KeyLength ���֧������ Hash��Ҳ���� MD5 32 �ֽڣ�SHA256 64 �ֽ�}

function CnPBKDF1(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer): AnsiString;

function CnPBKDF2(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer): AnsiString;

implementation

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function CnGetDeriveKey(const Password, Salt: AnsiString; OutKey: PAnsiChar; KeyLength: Cardinal;
  KeyHash: TCnKeyDeriveHash): Boolean;
var
  Md5Dig, Md5Dig2: TMD5Digest;
  Sha256Dig, Sha256Dig2: TSHA256Digest;
  SaltBuf, PS, PSMD5, PSSHA256: AnsiString;
begin
  Result := False;

  if (Password = '') or (OutKey = nil) or (KeyLength < 8) then
    Exit;

  SetLength(SaltBuf, 8);
  FillChar(SaltBuf[1], Length(SaltBuf), 0);
  if Salt <> '' then
  Move(Salt[1], SaltBuf[1], Min(Length(Salt), 8));

  PS := AnsiString(Password) + SaltBuf; // �涨ǰ 8 ���ֽ���Ϊ Salt
  if KeyHash = ckdMd5 then
  begin
    SetLength(PSMD5, SizeOf(TMD5Digest) + Length(PS));
    Move(PS[1], PSMD5[SizeOf(TMD5Digest) + 1], Length(PS));
    Md5Dig := MD5StringA(PS);
    // ������ Salt ƴ������ MD5 �����16 Byte����Ϊ��һ����

    Move(Md5Dig[0], OutKey^, Min(KeyLength, SizeOf(TMD5Digest)));
    if KeyLength <= SizeOf(TMD5Digest) then
    begin
      Result := True;
      Exit;
    end;

    KeyLength := KeyLength - SizeOf(TMD5Digest);
    OutKey := PAnsiChar(Integer(OutKey) + SizeOf(TMD5Digest));

    Move(Md5Dig[0], PSMD5[1], SizeOf(TMD5Digest));
    Md5Dig2 := MD5StringA(PSMD5);
    Move(Md5Dig2[0], OutKey^, Min(KeyLength, SizeOf(TMD5Digest)));
    if KeyLength <= SizeOf(TMD5Digest) then
      Result := True;

    // ���� KeyLength ̫�����㲻��
  end
  else if KeyHash = ckdSha256 then
  begin
    SetLength(PSSHA256, SizeOf(TSHA256Digest) + Length(PS));
    Move(PS[1], PSSHA256[SizeOf(TSHA256Digest) + 1], Length(PS));
    Sha256Dig := SHA256StringA(PS);
    // ������ Salt ƴ������ SHA256 �����32 Byte����Ϊ��һ����

    Move(Sha256Dig[0], PSSHA256[1], SizeOf(TSHA256Digest));
    Sha256Dig2 := SHA256StringA(PSSHA256);

    Move(Sha256Dig[0], OutKey^, Min(KeyLength, SizeOf(TSHA256Digest)));
    if KeyLength <= SizeOf(TSHA256Digest) then
    begin
      Result := True;
      Exit;
    end;

    KeyLength := KeyLength - SizeOf(TSHA256Digest);
    OutKey := PAnsiChar(Integer(OutKey) + SizeOf(TSHA256Digest));

    Move(Sha256Dig[0], PSMD5[1], SizeOf(TSHA256Digest));
    Md5Dig2 := MD5StringA(PSMD5);
    Move(Md5Dig2[0], OutKey^, Min(KeyLength, SizeOf(TSHA256Digest)));
    if KeyLength <= SizeOf(TSHA256Digest) then
      Result := True;

    // ���� KeyLength ̫�����㲻��
  end;
end;

function CnPBKDF1(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer): AnsiString;
begin

end;

function CnPBKDF2(const Password, Salt: AnsiString; Count, DerivedKeyLength: Integer): AnsiString;
begin

end;

end.
