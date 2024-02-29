{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
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

unit CnPDFCrypt;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�PDF ���׽������ɵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��PDF �ӽ��ܻ��Ƶ�ʵ�ֵ�Ԫ���� CnPDF.pas �ж�����������֧�� Revision 2 3 4
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2024.02.29 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  SysUtils, Classes, CnNative;

type
  ECnPDFCryptException = class(Exception);

function CnPDFCalcEncryptKey(const UserPass: AnsiString; Revision: Integer; OwnerCipher: TBytes;
  Permission: Cardinal; ID: TBytes; KeyBitLength: Integer): TBytes;
{* �����û������� O ֵ�ȼ������ Key�����ӽ����ַ�����������}

function CnPDFCalcUserCipher(const UserPass: AnsiString; Revision: Integer;
  OwnerCipher: TBytes; Permission: Cardinal; ID: TBytes; KeyBitLength: Integer): TBytes;
{* �����û���������ݼ��� U ֵ���ڲ������������ Key}

function CnPDFCalcOwnerCipher(const OwnerPass, UserPass: AnsiString;
  Revision, KeyBitLength: Integer): TBytes;
{* ����Ȩ���������û�������� O ֵ}

implementation

uses
  CnRandom, CnMD5, CnRC4;

const
  CN_PDF_ENCRYPT_SIZE = 32;       // 32 �ֽڶ���� PDF ����ģʽ

type
  TCnPDFPaddingKey = array[0..CN_PDF_ENCRYPT_SIZE - 1] of Byte;

const
  CN_PDF_ENCRYPT_PADDING: TCnPDFPaddingKey = (
    $28, $BF, $4E, $5E, $4E, $75, $8A, $41, $64, $00, $4E, $56, $FF, $FA, $01, $08,
    $2E, $2E, $00, $B6, $D0, $68, $3E, $80, $2F, $0C, $A9, $FE, $64, $53, $69, $7A
  );

resourcestring
  SCnErrorPDFKeyLength = 'Invalid Key Length';

function PaddingKey(const Password: AnsiString): TCnPDFPaddingKey;
var
  L: Integer;
begin
  L := Length(Password);
  if L > 0 then
  begin
    L := MoveMost(Password[1], Result[0], L, SizeOf(TCnPDFPaddingKey));
    if L < SizeOf(TCnPDFPaddingKey) then
      Move(CN_PDF_ENCRYPT_PADDING[0], Result[L], SizeOf(TCnPDFPaddingKey) - L);
  end
  else
    Move(CN_PDF_ENCRYPT_PADDING[0], Result[0], SizeOf(TCnPDFPaddingKey));
end;

function CnPDFCalcEncryptKey(const UserPass: AnsiString;
  Revision: Integer; OwnerCipher: TBytes; Permission: Cardinal; ID: TBytes;
  KeyBitLength: Integer): TBytes;
var
  I, KL: Integer;
  PK: TCnPDFPaddingKey;
  Ctx: TCnMD5Context;
  Dig: TCnMD5Digest;
  P: Cardinal;
begin
  KL := KeyBitLength div 8;
  if (KL <= 0) or (KL > 16) then // ��� 16 �ֽ�
    raise ECnPDFCryptException.Create(SCnErrorPDFKeyLength);

  PK := PaddingKey(UserPass);

  MD5Init(Ctx);
  MD5Update(Ctx, @PK[0], SizeOf(TCnPDFPaddingKey));
  MD5Update(Ctx, @OwnerCipher[0], Length(OwnerCipher));

  P := UInt32ToLittleEndian(Permission); // ǿ��С��
  MD5Update(Ctx, @P, SizeOf(P));

  MD5Update(Ctx, @ID[0], Length(ID));

  if Revision >= 4 then // ֻ���� Metadata �����ܵ����
  begin
    P := $FFFFFFFF;
    MD5Update(Ctx, @P, SizeOf(P));
  end;

  MD5Final(Ctx, Dig);

  if Revision >= 3 then  // ����ʮ�� MD5
  begin
    for I := 1 to 50 do
      Dig := MD5(@Dig[0], KL);

    SetLength(Result, 16);
  end
  else
    SetLength(Result, 5);

  Move(Dig[0], Result[0], Length(Result));
end;

function CnPDFCalcOwnerCipher(const OwnerPass, UserPass: AnsiString;
  Revision, KeyBitLength: Integer): TBytes;
var
  I, J, KL: Integer;
  OPK, UPK, XK: TCnPDFPaddingKey;
  Dig: TCnMD5Digest;
  RK: TBytes;
begin
  if OwnerPass <> '' then
    OPK := PaddingKey(OwnerPass)
  else
    OPK := PaddingKey(UserPass);

  // �ض������� 32 �ֽڲ���һ�� MD5
  Dig := MD5(@OPK[0], SizeOf(TCnPDFPaddingKey));

  // �� MD5 ������� 50 �� MD5
  for I := 1 to 50 do
    Dig := MD5(@Dig[0], SizeOf(TCnMD5Digest));

  if Revision <= 2 then
    KL := 5
  else
    KL := KeyBitLength div 8;

  if (KL <= 0) or (KL > 16) then // ��� 16 �ֽ�
    raise ECnPDFCryptException.Create(SCnErrorPDFKeyLength);

  SetLength(RK, KL);
  MoveMost(Dig[0], RK[0], KL, SizeOf(TCnMD5Digest));
  // RK �ǴӶ�� MD5 �����ȡ����ָ��������� 16 ���ֽ���Ϊ RC4 ��Կ

  // �û���������ض� 32 �ֽڵ� UPK ��
  UPK := PaddingKey(UserPass);

  // RC4 ����� 16 �ֽڵ� RK ���� 32 �ֽڵ� UPK������� UPK ��
  RC4Encrypt(@RK[0], KL, @UPK[0], @UPK[0], SizeOf(TCnPDFPaddingKey));

  if Revision >= 3 then
  begin
    for I := 1 to 19 do
    begin
      for J := 0 to KL - 1 do
        XK[J] := RK[J] xor I;

      RC4Encrypt(@XK[0], KL, @UPK[0], @UPK[0], SizeOf(TCnPDFPaddingKey));
    end;
  end;

  SetLength(Result, SizeOf(TCnPDFPaddingKey));
  Move(UPK[0], Result[0], SizeOf(TCnPDFPaddingKey))
end;

function CnPDFCalcUserCipher(const UserPass: AnsiString; Revision: Integer;
  OwnerCipher: TBytes; Permission: Cardinal; ID: TBytes; KeyBitLength: Integer): TBytes;
var
  I, J, KL: Integer;
  Key: TBytes;
  Ctx: TCnMD5Context;
  Dig: TCnMD5Digest;
  XK: TCnPDFPaddingKey;
begin
  Key := CnPDFCalcEncryptKey(UserPass, Revision, OwnerCipher, Permission, ID, KeyBitLength);

  if Revision = 2 then
  begin
    SetLength(Result, SizeOf(TCnPDFPaddingKey));
    RC4Encrypt(@Key[0], Length(Key), @CN_PDF_ENCRYPT_PADDING[0], @Result[0], SizeOf(TCnPDFPaddingKey));
  end
  else if Revision in [3, 4] then
  begin
    MD5Init(Ctx);
    MD5Update(Ctx, @CN_PDF_ENCRYPT_PADDING[0], SizeOf(TCnPDFPaddingKey));
    MD5Update(Ctx, @ID[0], Length(ID));
    MD5Final(Ctx, Dig);

    RC4Encrypt(@Key[0], Length(Key), @Dig[0], @Dig[0], SizeOf(TCnMD5Digest));

    KL := KeyBitLength div 8;
    if (KL <= 0) or (KL > 16) then // ��� 16 �ֽ�
      raise ECnPDFCryptException.Create(SCnErrorPDFKeyLength);

    for I := 1 to 19 do
    begin
      for J := 0 to KL - 1 do
        XK[J] := Key[J] xor I;

      RC4Encrypt(@XK[0], KL, @Dig[0], @Dig[0], SizeOf(TCnPDFPaddingKey));
    end;

    SetLength(Result, SizeOf(TCnPDFPaddingKey));
    Move(Dig[0], Result[0], SizeOf(TCnMD5Digest));

    // �����ǰ 16 �ֽں󣬺� 16 �ֽ�����������
    CnRandomFillBytes(@Result[SizeOf(TCnMD5Digest)], SizeOf(TCnMD5Digest));
  end;
end;

end.
