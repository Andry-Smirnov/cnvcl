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

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative;

type
  ECnPDFCryptException = class(Exception);
  {* PDF �ӽ��ܵ��쳣}

function CnPDFCalcUserCipher(const UserPass: AnsiString; Revision: Integer;
  OwnerCipher: TBytes; Permission: Cardinal; ID: TBytes; KeyBitLength: Integer): TBytes;
{* �����û���������ݼ��� U ֵ���ڲ������������ Key���ɹ����ĵ��е� U ֵ�Ա���ȷ���Ƿ�����ȷ���û�����

  UserPass: AnsiString              �û�����
  Revision: Integer                 ���ܰ汾�ţ�ֻ֧�� 2  3  4
  OwnerCipher: TBytes               PDF �ļ��� Encrypt �ڵ�� O �ֶ�ֵ��һ�� 32 �ֽ�
  Permission: Cardinal              PDF �ļ��� Encrypt �ڵ�� P �ֶ�ֵ�����Ǹ�ֵҪǿ��ת�����޷��� 32 λ
  ID: TBytes                        PDF �ļ��� Trailer ���ֵ� ID ����ĵ�һ���ַ���ֵ
  KeyBitLength: Integer             PDF �ļ��� Encrypt �ڵ�� Length �ֶ�ֵ��һ���� 128��ʵ�ʳ��� 8 �õ��ֽ���

  ����ֵ TBytes Ϊ�ɷ����� PDF �ļ��� Encrypt �ڵ�� U �ֶ�ֵ������ԭʼ U ֵ�Ƚ���ȷ���û������Ƿ���ȷ
}

function CnPDFCalcOwnerCipher(const OwnerPass, UserPass: AnsiString;
  Revision, KeyBitLength: Integer): TBytes;
{* ����Ȩ���������û�������� O ֵ

  OwnerPass: AnsiString             Ȩ������
  Revision: Integer                 ���ܰ汾�ţ�ֻ֧�� 2  3  4
  KeyBitLength: Integer             PDF �ļ��� Encrypt �ڵ�� Length �ֶ�ֵ��һ���� 128��ʵ�ʳ��� 8 �õ��ֽ���

  ����ֵ TBytes Ϊ�ɷ����� PDF �ļ��� Encrypt �ڵ�� O �ֶ�ֵ
}

function CnPDFCheckUserPassword(const UserPass: AnsiString; Revision: Integer;
  OwnerCipher, UserCipher: TBytes; Permission: Cardinal; ID: TBytes;
  KeyBitLength: Integer): TBytes;
{* ����û������ UserPass �Ƿ��ǺϷ����û����룬���ͨ�����ؼ�����Կ�����򷵻� nil

  UserPass: AnsiString              �û�����
  Revision: Integer                 ���ܰ汾�ţ�ֻ֧�� 2  3  4
  OwnerCipher: TBytes               PDF �ļ��� Encrypt �ڵ�� O �ֶ�ֵ��һ�� 32 �ֽ�
  UserCipher: TBytes                PDF �ļ��� Encrypt �ڵ�� U �ֶ�ֵ��һ�� 32 �ֽ�
  Permission: Cardinal              PDF �ļ��� Encrypt �ڵ�� P �ֶ�ֵ�����Ǹ�ֵҪǿ��ת�����޷��� 32 λ
  ID: TBytes                        PDF �ļ��� Trailer ���ֵ� ID ����ĵ�һ���ַ���ֵ
  KeyBitLength: Integer             PDF �ļ��� Encrypt �ڵ�� Length �ֶ�ֵ��һ���� 128��ʵ�ʳ��� 8 �õ��ֽ���

  ����ֵ TBytes Ϊ�ӽ��ܵ���Կ�ֽ�����
}

function CnPDFCheckOwnerPassword(const OwnerPass: AnsiString; Revision: Integer;
  OwnerCipher, UserCipher: TBytes; Permission: Cardinal; ID: TBytes;
  KeyBitLength: Integer): TBytes;
{* ����û������ OwnerPass �Ƿ��ǺϷ���Ȩ�����룬���ͨ�����ؼ�����Կ�����򷵻� nil

  UserPass: AnsiString              �û�����
  Revision: Integer                 ���ܰ汾�ţ�ֻ֧�� 2  3  4
  OwnerCipher: TBytes               PDF �ļ��� Encrypt �ڵ�� O �ֶ�ֵ��һ�� 32 �ֽ�
  UserCipher: TBytes                PDF �ļ��� Encrypt �ڵ�� U �ֶ�ֵ��һ�� 32 �ֽ�
  Permission: Cardinal              PDF �ļ��� Encrypt �ڵ�� P �ֶ�ֵ�����Ǹ�ֵҪǿ��ת�����޷��� 32 λ
  ID: TBytes                        PDF �ļ��� Trailer ���ֵ� ID ����ĵ�һ���ַ���ֵ
  KeyBitLength: Integer             PDF �ļ��� Encrypt �ڵ�� Length �ֶ�ֵ��һ���� 128��ʵ�ʳ��� 8 �õ��ֽ���

  ����ֵ TBytes Ϊ�ӽ��ܵ���Կ�ֽ�����
}

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
  SCnErrorPDFEncryptParams = 'Invalid Encrypt Params';

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

function UnPaddingKey(var PaddingKey: TCnPDFPaddingKey): AnsiString;
var
  I, Idx: Integer;
  S, Pat: AnsiString;
begin
  SetLength(S, SizeOf(TCnPDFPaddingKey));
  Move(PaddingKey[0], S[1], SizeOf(TCnPDFPaddingKey)); // �����ҵ���������

  for I := 1 to SizeOf(TCnPDFPaddingKey) do
  begin
    SetLength(Pat, I);
    Move(CN_PDF_ENCRYPT_PADDING[0], Pat[1], Length(Pat));

    Idx := AnsiPos(Pat, S);
    if Idx = SizeOf(TCnPDFPaddingKey) - I then
    begin
      Result := Copy(S, 1, Idx - 1);
      Exit;
    end;
  end;
  Result := S;
end;

{* �����û������� O ֵ�ȼ������ Key�����ӽ����ַ�����������

  UserPass: AnsiString              �û�����
  Revision: Integer                 ���ܰ汾�ţ�ֻ֧�� 2  3  4
  OwnerCipher: TBytes               PDF �ļ��� Encrypt �ڵ�� O �ֶ�ֵ��һ�� 32 �ֽ�
  Permission: Cardinal              PDF �ļ��� Encrypt �ڵ�� P �ֶ�ֵ�����Ǹ�ֵҪǿ��ת�����޷��� 32 λ
  ID: TBytes                        PDF �ļ��� Trailer ���ֵ� ID ����ĵ�һ���ַ���ֵ
  KeyBitLength: Integer             PDF �ļ��� Encrypt �ڵ�� Length �ֶ�ֵ��һ���� 128��ʵ�ʳ��� 8 �õ��ֽ���

  ����ֵ TBytes Ϊ�ӽ��ܵ���Կ�ֽ�����
}
function CalcEncryptKey(const UserPass: AnsiString;
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

function CalcOwnerKey(const OwnerPass: AnsiString; Revision, KeyBitLength: Integer): TBytes;
var
  I, KL: Integer;
  Dig: TCnMD5Digest;
  OPK: TCnPDFPaddingKey;
begin
  OPK := PaddingKey(OwnerPass);

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

  SetLength(Result, KL);
  MoveMost(Dig[0], Result[0], KL, SizeOf(TCnMD5Digest));
  // Result �ǴӶ�� MD5 �����ȡ����ָ��������� 16 ���ֽ���Ϊ RC4 ��Կ
end;

function CnPDFCalcOwnerCipher(const OwnerPass, UserPass: AnsiString;
  Revision, KeyBitLength: Integer): TBytes;
var
  I, J: Integer;
  UPK, XK: TCnPDFPaddingKey;
  RK: TBytes;
begin
  RK := CalcOwnerKey(OwnerPass, Revision, KeyBitLength);

  // �û���������ض� 32 �ֽڵ� UPK ��
  UPK := PaddingKey(UserPass);

  // RC4 ����� 16 �ֽڵ� RK ���� 32 �ֽڵ� UPK������� UPK ��
  RC4Encrypt(@RK[0], Length(RK), @UPK[0], @UPK[0], SizeOf(TCnPDFPaddingKey));

  if Revision >= 3 then
  begin
    for I := 1 to 19 do
    begin
      for J := 0 to Length(RK) - 1 do
        XK[J] := RK[J] xor I;

      RC4Encrypt(@XK[0], Length(RK), @UPK[0], @UPK[0], SizeOf(TCnPDFPaddingKey));
    end;
  end;

  SetLength(Result, SizeOf(TCnPDFPaddingKey));
  Move(UPK[0], Result[0], SizeOf(TCnPDFPaddingKey));
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
  Key := CalcEncryptKey(UserPass, Revision, OwnerCipher, Permission, ID, KeyBitLength);

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

function CnPDFCheckUserPassword(const UserPass: AnsiString; Revision: Integer;
  OwnerCipher, UserCipher: TBytes; Permission: Cardinal; ID: TBytes;
  KeyBitLength: Integer): TBytes;
var
  N: TBytes;
begin
  if (Length(OwnerCipher) = 0) or (Length(UserCipher) = 0) or (Length(ID) = 0) then
    raise ECnPDFCryptException.Create(SCnErrorPDFEncryptParams);

  N := CnPDFCalcUserCipher(UserPass, Revision, OwnerCipher, Permission, ID, KeyBitLength);
  if CompareBytes(N, UserCipher, 16) then
    Result := CalcEncryptKey(UserPass, Revision, OwnerCipher, Permission, ID, KeyBitLength)
  else
    Result := nil;
end;

function CnPDFCheckOwnerPassword(const OwnerPass: AnsiString; Revision: Integer;
  OwnerCipher, UserCipher: TBytes; Permission: Cardinal; ID: TBytes;
  KeyBitLength: Integer): TBytes;
var
  I, J: Integer;
  RK, OC, XK: TBytes;
  OCP: TCnPDFPaddingKey;
  UP: AnsiString;
begin
  if (Length(OwnerCipher) = 0) or (Length(UserCipher) = 0) or (Length(ID) = 0) then
    raise ECnPDFCryptException.Create(SCnErrorPDFEncryptParams);

  RK := CalcOwnerKey(OwnerPass, Revision, KeyBitLength);

  if Revision = 2 then
  begin
    SetLength(OC, Length(OwnerCipher));
    RC4Decrypt(@RK[0], Length(RK), @OwnerCipher[0], @OC[0], Length(OwnerCipher));
  end
  else if Revision >= 3 then
  begin
    SetLength(OC, Length(OwnerCipher));
    Move(OwnerCipher[0], OC[0], Length(OwnerCipher));

    SetLength(XK, Length(RK));
    for I := 19 downto 0 do
    begin
      for J := Length(RK) - 1 downto 0 do
        XK[J] := RK[J] xor I;

      RC4Decrypt(@XK[0], Length(XK), @OC[0], @OC[0], Length(OC));
    end;
  end;

  // OC �ǽ��ܳ����Ķ���� Password����ȥ��֤
  MoveMost(OC[0], OCP[0], Length(OC), SizeOf(TCnPDFPaddingKey));
  UP := UnPaddingKey(OCP);

  // ��֤ͨ���򷵻���Կ����ͨ���򷵻� nil
  Result := CnPDFCheckUserPassword(UP, Revision, OwnerCipher, UserCipher,
    Permission, ID, KeyBitLength);;
end;

end.
