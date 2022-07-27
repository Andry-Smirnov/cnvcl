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

unit CnAEAD;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����� AEAD ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��Liu Xiao��
* ��    ע��AEAD �ǹ���������֤���ܵļ�ơ����������롢�����������ʼ�������ȶ�
*           ���ݽ��м�����������֤���ݣ�����ʱ�����֤����ͨ������ʧ�ܡ�
*           ע���ֽڴ�ת��Ϊ������ʱ�൱�ڴ�˱�﷨���Ҵ��±�ָ���λ��ַ
*           Ŀǰʵ���� GHash128���ƺ�Ҳ�� GMAC���Լ� AES128/192/256/SM4 �� GCM
*           GCM �ο��ĵ���The Galois/Counter Mode of Operation (GCM)���Լ�
*           ��NIST Special Publication 800-38D���Լ� RFC 8998 ����������
*           CMAC �ο��ĵ���NIST Special Publication 800-38B��
*           Recommendation for Block Cipher Modes of Operation:
*           The CMAC Mode for Authentication�� �Լ� RFC 4993 ����������(AES-128)
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.07.27 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative;

const
  AEAD_BLOCK  = 16;       // GHASH/GCM/CMAC �Լ� AES/SM4 �ȵķ��鶼�� 16 �ֽ�

  GCM_NONCE_LENGTH = 12;  // 12 �ֽڵ� Nonce �������ƴ������ Iv

type
  T128BitsBuffer = array[0..AEAD_BLOCK - 1] of Byte;
  {* AEAD ������ 128 λ����ķֿ�}

  TGHash128Key = array[0..AEAD_BLOCK - 1] of Byte;
  {* GHash128 ����Կ}

  TGHash128Tag    = array[0..AEAD_BLOCK - 1] of Byte;
  {* GHash128 �ļ�����}

  TGHash128Context = packed record
  {* ���ڶ�ηֿ����� GHash128 �����Ľṹ}
    HashKey:     T128BitsBuffer;
    State:       T128BitsBuffer;
    AADByteLen:  Integer;
    DataByteLen: Integer;
  end;

  TGCM128Key = array[0..AEAD_BLOCK - 1] of Byte;
  {* GCM ģʽ����Կ���ڲ������� AES ���� SM4 ��Ϊ 16 �ֽ�}

  TGCM128Tag    = array[0..AEAD_BLOCK - 1] of Byte;
  {* GCM �ļ�����}

  TCMAC128Key = array[0..AEAD_BLOCK - 1] of Byte;
  {* CMAC ģʽ����Կ���ڲ������� AES ���� SM4 ��Ϊ 16 �ֽ�}

  TCMAC128Tag    = array[0..AEAD_BLOCK - 1] of Byte;
  {* CMAC �ļ�����}

procedure GMulBlock128(var X, Y: T128BitsBuffer; var R: T128BitsBuffer);
{* ʵ�� GHash �е�٤�޻��� (2^128) �ϵĿ�˷���������������ͨ����Ҳ���Ͻ�����
  ע�� 2 ����������˷���ļӷ���ģ 2 ��Ҳ�������Ҳ��ͬ��ģ 2 ����
  ͬʱ��Ҫģһ��ģ����ʽ GHASH_POLY�����еĵ��μ�ͬ��Ҳ�����}

procedure GHash128(var HashKey: TGHash128Key; Data: Pointer; DataByteLength: Integer;
  AAD: Pointer; AADByteLength: Integer; var OutTag: TGHash128Tag);
{* ��ָ�� HashKey �븽������ AAD����һ�����ݽ��� GHash ����õ� Tag ժҪ��
  ��Ӧ�ĵ��е� GHash(H, A C)}

function GHash128Bytes(var HashKey: TGHash128Key; Data, AAD: TBytes): TGHash128Tag;
{* �ֽ����鷽ʽ���� GHash ���㣬�ڲ����� GHash128}

// �����������������ⲿ���������ݽ�����ɢ�� GHash128 ���㣬GHash128Update �ɶ�α�����
// ע�� GHash128Update �� Data ��Ҫ���������飬�粻���飬ĩβ�Ჹ 0 ���㣬
// �����������������Ӵպ������������ŵ���һ�ִ��������

procedure GHash128Start(var Ctx: TGHash128Context; var HashKey: TGHash128Key;
  AAD: Pointer; AADByteLength: Integer);
{* ��ʼ GHash128 �ĵ�һ������ʼ����ȫ������� AAD ����}

procedure GHash128Update(var Ctx: TGHash128Context; Data: Pointer; DataByteLength: Integer);
{* ��һ�����ݽ��� GHash128���������㳤�Ⱦ���¼�� Ctx �У����Զ�ε���}

procedure GHash128Finish(var Ctx: TGHash128Context; var Output: TGHash128Tag);
{* GHash128 ���������㳤�ȣ������ؽ��}

// ======================= AES/SM4-GCM �ֽ�������ܺ��� ========================

function AES128GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-128-GCM ���ܣ���������
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬���� OutTag �з�����֤���ݹ�������֤}

function AES192GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-192-GCM ���ܣ���������
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬���� OutTag �з�����֤���ݹ�������֤}

function AES256GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-256-GCM ���ܣ���������
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬���� OutTag �з�����֤���ݹ�������֤}

function SM4GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� SM4-GCM ���ܣ���������
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬���� OutTag �з�����֤���ݹ�������֤}

// ======================== AES/SM4-GCM ���ݿ���ܺ��� =========================

procedure AES128GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-128-GCM ���ܣ����������� OutEnData ��ָ��������
  OutEnData ��ָ�����򳤶�������Ϊ PlainByteLength�������������Խ������غ��
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������ OutTag �з�����֤���ݹ�������֤}

procedure AES192GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-192-GCM ���ܣ����������� OutEnData ��ָ��������
  OutEnData ��ָ�����򳤶�������Ϊ PlainByteLength�������������Խ������غ��
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������ OutTag �з�����֤���ݹ�������֤}

procedure AES256GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-256-GCM ���ܣ����������� OutEnData ��ָ��������
  OutEnData ��ָ�����򳤶�������Ϊ PlainByteLength�������������Խ������غ��
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������ OutTag �з�����֤���ݹ�������֤}

procedure SM4GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� SM4-GCM ���ܣ����������� OutEnData ��ָ��������
  OutEnData ��ָ�����򳤶�������Ϊ PlainByteLength�������������Խ������غ��
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������ OutTag �з�����֤���ݹ�������֤}

// ======================= AES/SM4-GCM �ֽ�������ܺ��� ========================

function AES128GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-128-GCM ���ܲ���֤���ɹ��򷵻�����
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬����֤ InTag �Ƿ�Ϸ������Ϸ����� nil}

function AES192GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-192-GCM ���ܲ���֤���ɹ��򷵻�����
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬����֤ InTag �Ƿ�Ϸ������Ϸ����� nil}

function AES256GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-256-GCM ���ܲ���֤���ɹ��򷵻�����
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬����֤ InTag �Ƿ�Ϸ������Ϸ����� nil}

function SM4GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� SM4-GCM ���ܲ���֤���ɹ��򷵻�����
  ���ϲ����뷵��ֵ��Ϊ�ֽ����飬����֤ InTag �Ƿ�Ϸ������Ϸ����� nil}

// ======================== AES/SM4-GCM ���ݿ���ܺ��� =========================

function AES128GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-128-GCM ���ܲ���֤��
  �ɹ��򷵻� True �������ķ����� OutPlainData ��ָ�������У�
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������֤ InTag �Ƿ�Ϸ������Ϸ����� False}

function AES192GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-192-GCM ���ܲ���֤��
  �ɹ��򷵻� True �������ķ����� OutPlainData ��ָ�������У�
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������֤ InTag �Ƿ�Ϸ������Ϸ����� False}

function AES256GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� AES-256-GCM ���ܲ���֤��
  �ɹ��򷵻� True �������ķ����� OutPlainData ��ָ�������У�
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������֤ InTag �Ƿ�Ϸ������Ϸ����� False}

function SM4GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
{* ʹ�����롢��ʼ���������������ݶ����Ľ��� SM4-GCM ���ܲ���֤��
  �ɹ��򷵻� True �������ķ����� OutPlainData ��ָ�������У�
  ���ϲ�����Ϊ�ڴ�鲢ָ���ֽڳ��ȵ���ʽ������֤ InTag �Ƿ�Ϸ������Ϸ����� False}

// ======================= AES/SM4-CMAC �ֽ������Ӵպ��� =======================

function AES128CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� AES-128-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

function AES192CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� AES-192-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

function AES256CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� AES-256-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

function SM4CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� SM4-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

// ======================== AES/SM4-CMAC ���ݿ��Ӵպ��� ========================

function AES128CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� AES-128-CMAC ���㣬���ؼ������ Tag��������Ϊ�ڴ��}

function AES192CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� AES-192-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

function AES256CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� AES-256-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

function SM4CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
{* ��ָ���� Key �����ݽ��� SM4-CMAC ���㣬���ؼ������ Tag��������Ϊ�ֽ�����}

implementation

uses
  CnSM4, CnAES;

const
  GHASH_POLY: T128BitsBuffer = ($E1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  CMAC_POLY: T128BitsBuffer =  (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $87);

type
  TAEADEncryptType = (aetAES128, aetAES192, aetAES256, aetSM4);
  {* ֧�ֵ����ֶԳƼ�������}

  TAEADContext = packed record
  case TAEADEncryptType of
    aetAES128: (ExpandedKey128: TAESExpandedKey128);
    aetAES192: (ExpandedKey192: TAESExpandedKey192);
    aetAES256: (ExpandedKey256: TAESExpandedKey256);
    aetSM4:    (SM4Context: TSM4Context);
  end;

// ע��˴��ж��ֽ��� Bit ��˳��Ҳ���ֽ��ڵĸ�λ�� 0
function AeadIsBitSet(AMem: Pointer; N: Integer): Boolean;
var
  P: PCnByte;
  A1, B1: Integer;
  V: Byte;
begin
  A1 := N div 8;
  B1 := 7 - (N mod 8);
  P := PCnByte(TCnNativeInt(AMem) + A1);

  V := Byte(1 shl B1);
  Result := (P^ and V) <> 0;
end;

procedure MoveMost128(const Source; var Dest; ByteLen: Integer);
begin
  if ByteLen > AEAD_BLOCK then
    ByteLen := AEAD_BLOCK
  else if ByteLen < AEAD_BLOCK then
    FillChar(Dest, AEAD_BLOCK, 0);

  Move(Source, Dest, ByteLen);
end;

{
  GCM ʹ�õ� Galois(2^128) ���ڵĳ˷�

  һ����˵�����ֽڴ������� $FEDC���� BIT ˳���Ӧ���� FEDC��Ҳ���� 1111111011011100��
  GCM �У�����Ӧ������Ҳ��ͬ���⴮�����Ƶĳ����
  Ȼ�� LSB ָ�ұߵĵ�λ�ģ�MSB ָ��߸�λ�ģ�������λ���ϳ���ϰ�ߡ�
  �����������������⣺�±� 0 ��ָ���������ң�
  GCM �õ�ģ����ʽ�� 128,7,2,1,0�����㷨�еı���� E1000000000������˵���±����ұ߸�λ
  ��ˣ�127 �±���������λ���������������ĸ�λ�����ơ�
  ͬʱ��127 Ҳ��Ӧ�ŵ�ַ��λ��0 �ǵ�ַ��λ��������������ַ��λ������
}
procedure GMulBlock128(var X, Y: T128BitsBuffer; var R: T128BitsBuffer);
var
  I: Integer;
  Z, V: T128BitsBuffer;
  B: Boolean;
begin
  FillChar(Z[0], SizeOf(T128BitsBuffer), 0);
  Move(X[0], V[0], SizeOf(T128BitsBuffer));

  for I := 0 to 127 do
  begin
    if AeadIsBitSet(@Y[0], I) then
      MemoryXor(@Z[0], @V[0], SizeOf(T128BitsBuffer), @Z[0]);

    B := AeadIsBitSet(@V[0], 127); // �жϴ������ĸ�λ�Ƿ��� 1
    MemoryShiftRight(@V[0], nil, SizeOf(T128BitsBuffer), 1);
    if B then
      MemoryXor(@V[0], @GHASH_POLY[0], SizeOf(T128BitsBuffer), @V[0]);
  end;
  Move(Z[0], R[0], SizeOf(T128BitsBuffer));
end;

procedure GHash128(var HashKey: TGHash128Key; Data: Pointer; DataByteLength: Integer;
  AAD: Pointer; AADByteLength: Integer; var OutTag: TGHash128Tag);
var
  AL, DL: Integer;
  AL64, DL64: Int64;
  X, Y, H: T128BitsBuffer;
begin
  // �Ա� GHash(H, A, C)��Data �� C��AAD �� A��Key �� H
  // �� 16 �ֽڷ֣�C �� m �飬A �� n �飨ĩ�鶼���ܲ�������
  // ���� m + n ��������ݵ� GaloisMulBlock���ټ�һ��λ����

  FillChar(X[0], SizeOf(T128BitsBuffer), 0);  // ��ʼȫ 0
  Move(HashKey[0], H[0], SizeOf(T128BitsBuffer));

  AL := AADByteLength;
  DL := DataByteLength;
  if Data = nil then
    DL := 0;
  if AAD = nil then
    AL := 0;

  // ������ A
  while AL >= AEAD_BLOCK do
  begin
    Move(AAD^, Y[0], AEAD_BLOCK);

    MemoryXor(@Y[0], @X[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, H, X);  // һ�ּ������ٴη��� X

    AAD := Pointer(TCnNativeInt(AAD) + AEAD_BLOCK);
    Dec(AL, AEAD_BLOCK);
  end;

  // ����� A������еĻ�
  if AL > 0 then
  begin
    FillChar(Y[0], SizeOf(T128BitsBuffer), 0);
    Move(AAD^, Y[0], AL);

    MemoryXor(@Y[0], @X[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, H, X);
  end;

  // ������ C
  while DL >= AEAD_BLOCK do
  begin
    Move(Data^, Y[0], AEAD_BLOCK);

    MemoryXor(@Y[0], @X[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, H, X);  // һ�ּ������ٴη��� X

    Data := Pointer(TCnNativeInt(Data) + AEAD_BLOCK);
    Dec(DL, AEAD_BLOCK);
  end;

  // ����� C������еĻ�
  if DL > 0 then
  begin
    FillChar(Y[0], SizeOf(T128BitsBuffer), 0);
    Move(Data^, Y[0], DL);

    MemoryXor(@Y[0], @X[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, H, X);
  end;

  // �������һ�ֳ��ȣ�A �� C �����ֽ�ƴ������ƴ��Ҫ����������׼���Ķ�ϰ��Ҳ���� BigEndian
  FillChar(Y[0], SizeOf(T128BitsBuffer), 0);
  AL64 := Int64ToBigEndian(AADByteLength * 8);
  DL64 := Int64ToBigEndian(DataByteLength * 8);

  Move(AL64, Y[0], SizeOf(Int64));
  Move(DL64, Y[SizeOf(Int64)], SizeOf(Int64));

  MemoryXor(@Y[0], @X[0], SizeOf(T128BitsBuffer), @Y[0]);
  GMulBlock128(Y, H, X); // �ٳ�һ��

  Move(X[0], OutTag[0], SizeOf(TGHash128Tag));
end;

function GHash128Bytes(var HashKey: TGHash128Key; Data, AAD: TBytes): TGHash128Tag;
var
  C, A: Pointer;
begin
  if Data = nil then
    C := nil
  else
    C := @Data[0];

  if AAD = nil then
    A := nil
  else
    A := @AAD[0];

  GHash128(HashKey, C, Length(Data), A, Length(AAD), Result);
end;

procedure GHash128Start(var Ctx: TGHash128Context; var HashKey: TGHash128Key;
  AAD: Pointer; AADByteLength: Integer);
var
  Y: T128BitsBuffer;
begin
  FillChar(Ctx.State[0], SizeOf(T128BitsBuffer), 0);  // ��ʼȫ 0
  Move(HashKey[0], Ctx.HashKey[0], SizeOf(T128BitsBuffer));

  Ctx.DataByteLen := 0;
  Ctx.AADByteLen := AADByteLength;
  if AAD = nil then
    Ctx.AADByteLen := 0;

  // ������ A
  while AADByteLength >= AEAD_BLOCK do
  begin
    Move(AAD^, Y[0], AEAD_BLOCK);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);  // һ�ּ������ٴη��� Ctx.State

    AAD := Pointer(TCnNativeInt(AAD) + AEAD_BLOCK);
    Dec(AADByteLength, AEAD_BLOCK);
  end;

  // ����� A������еĻ�
  if AADByteLength > 0 then
  begin
    FillChar(Y[0], SizeOf(T128BitsBuffer), 0);
    Move(AAD^, Y[0], AADByteLength);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);
  end;
end;

procedure GHash128Update(var Ctx: TGHash128Context; Data: Pointer; DataByteLength: Integer);
var
  Y: T128BitsBuffer;
begin
  if (Data = nil) or (DataByteLength <= 0) then
    Exit;

  Ctx.DataByteLen := Ctx.DataByteLen + DataByteLength;

  // ������ C
  while DataByteLength >= AEAD_BLOCK do
  begin
    Move(Data^, Y[0], AEAD_BLOCK);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);  // һ�ּ������ٴη��� Ctx.State

    Data := Pointer(TCnNativeInt(Data) + AEAD_BLOCK);
    Dec(DataByteLength, AEAD_BLOCK);
  end;

  // ����� C������еĻ�
  if DataByteLength > 0 then
  begin
    FillChar(Y[0], SizeOf(T128BitsBuffer), 0);
    Move(Data^, Y[0], DataByteLength);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(T128BitsBuffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);
  end;
end;

procedure GHash128Finish(var Ctx: TGHash128Context; var Output: TGHash128Tag);
var
  Y: T128BitsBuffer;
  AL64, DL64: Int64;
begin
  // �������һ�ֳ��ȣ�A �� C �����ֽ�ƴ����
  FillChar(Y[0], SizeOf(T128BitsBuffer), 0);
  AL64 := Int64ToBigEndian(Ctx.AADByteLen * 8);
  DL64 := Int64ToBigEndian(Ctx.DataByteLen * 8);

  Move(AL64, Y[0], SizeOf(Int64));
  Move(DL64, Y[SizeOf(Int64)], SizeOf(Int64));

  MemoryXor(@Y[0], @Ctx.State[0], SizeOf(T128BitsBuffer), @Y[0]);
  GMulBlock128(Y, Ctx.HashKey, Ctx.State); // �ٳ�һ�֣�

  Move(Ctx.State[0], Output[0], SizeOf(TGHash128Tag)); // ����� Output
end;

// ���ݶԳƼ����㷨���ͳ�ʼ��������Կ�ṹ��ע�ⲻ��Ҫ������Կ�ṹ
procedure AEADEncryptInit(var Context: TAEADContext; Key: Pointer;
  KeyByteLength: Integer; EncryptType: TAEADEncryptType);
var
  Key128: TAESKey128;
  Key192: TAESKey192;
  Key256: TAESKey256;
  SM4Key: TSM4Key;
begin
  FillChar(Context, SizeOf(TAEADContext), 0);

  case EncryptType of
    aetAES128:
      begin
        MoveMost128(Key^, Key128[0], KeyByteLength);
        ExpandAESKeyForEncryption(Key128, Context.ExpandedKey128);
      end;
    aetAES192:
      begin
        MoveMost128(Key^, Key192[0], KeyByteLength);
        ExpandAESKeyForEncryption(Key192, Context.ExpandedKey192);
      end;
    aetAES256:
      begin
        MoveMost128(Key^, Key256[0], KeyByteLength);
        ExpandAESKeyForEncryption(Key256, Context.ExpandedKey256);
      end;
    aetSM4:
      begin
        MoveMost128(Key^, SM4Key[0], KeyByteLength);
        SM4SetKeyEnc(Context.SM4Context, @SM4Key[0]);
      end;
  end;
end;

// ���ݶԳƼ����㷨���ͼ���һ���飬���鴮�������Ǽ��ܽ����ע�ⲻ��Ҫ�����
procedure AEADEncryptBlock(var Context: TAEADContext; var InData, OutData: T128BitsBuffer;
  EncryptType: TAEADEncryptType);
begin
  case EncryptType of
    aetAES128: EncryptAES(TAESBuffer(InData), Context.ExpandedKey128, TAESBuffer(OutData));
    aetAES192: EncryptAES(TAESBuffer(InData), Context.ExpandedKey192, TAESBuffer(OutData));
    aetAES256: EncryptAES(TAESBuffer(InData), Context.ExpandedKey256, TAESBuffer(OutData));
    aetSM4:    SM4OneRound(@(Context.SM4Context.Sk[0]), @InData[0], @OutData[0]);
  end;
end;

// ���� Key��Iv�����ĺͶ������ݣ����� GCM ������������֤���
procedure GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer;
  AuthDataByteLength: Integer; EnData: Pointer; var OutTag: TGCM128Tag;
  EncryptType: TAEADEncryptType);
var
  H: TGHash128Key;
  Y, Y0: T128BitsBuffer;// Y ƴ���˼�����������
  Cnt, M: Cardinal;      // ������
  C: T128BitsBuffer;      // �����м����ݴ洢��
  AeadCtx: TAEADContext;
  GHashCtx: TGHash128Context;
begin
  if Key = nil then
    KeyByteLength := 0;
  if Iv = nil then
    IvByteLength := 0;
  if AuthData = nil then
    AuthDataByteLength := 0;

  AEADEncryptInit(AeadCtx, Key, KeyByteLength, EncryptType);

  // ���� Enc(Key, 128 �� 0)���õ� H
  FillChar(H[0], SizeOf(H), 0);
  AEADEncryptBlock(AeadCtx, T128BitsBuffer(H), T128BitsBuffer(H), EncryptType);

  // ��ʼ�����������Ժ� Cnt ���������� Y �ĺ� 32 λ��
  if IvByteLength = GCM_NONCE_LENGTH then
  begin
    Move(Iv^, Y[0], GCM_NONCE_LENGTH);
    Cnt := 1;
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));
  end
  else
  begin
    GHash128(H, Iv, IvByteLength, nil, 0, TGHash128Tag(Y));
    Move(Y[GCM_NONCE_LENGTH], Cnt, SizeOf(Cardinal));
    ReverseMemory(@Cnt, SizeOf(Cardinal));
  end;

  // �Ȱ��ʼ�� Y ֵ�ļ��ܽ���������
  AEADEncryptBlock(AeadCtx, T128BitsBuffer(Y), T128BitsBuffer(Y0), EncryptType);

  // ��ʼ�� GHash
  GHash128Start(GHashCtx, H, AuthData, AuthDataByteLength);

  // ��ʼѭ����������
  while PlainByteLength >= AEAD_BLOCK do
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    AEADEncryptBlock(AeadCtx, T128BitsBuffer(Y), C, EncryptType);

    // ���������C �õ�����Ľ����������
    MemoryXor(PlainData, @C[0], SizeOf(T128BitsBuffer), @C[0]);

    // ��������
    Move(C[0], EnData^, SizeOf(T128BitsBuffer));

    // C ���� GHash
    GHash128Update(GHashCtx, @C[0], SizeOf(T128BitsBuffer));

    // ׼����һ��
    PlainData := Pointer(TCnNativeInt(PlainData) + AEAD_BLOCK);
    EnData := Pointer(TCnNativeInt(EnData) + AEAD_BLOCK);
    Dec(PlainByteLength, AEAD_BLOCK);
  end;

  if PlainByteLength > 0 then
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    AEADEncryptBlock(AeadCtx, T128BitsBuffer(Y), C, EncryptType);

    // ���������C �õ�����Ľ����������ֻ�� PlainByteLength
    MemoryXor(PlainData, @C[0], PlainByteLength, @C[0]);

    // �������ģ����
    Move(C[0], EnData^, PlainByteLength);

    // C ���� GHash
    GHash128Update(GHashCtx, @C[0], PlainByteLength);
  end;

  // ������� GHash �� Tag
  GHash128Finish(GHashCtx, TGHash128Tag(OutTag));

  // �ٺͿ�ʼ���������õ����� Tag
  MemoryXor(@OutTag[0], @Y0[0], SizeOf(TGHash128Tag), @OutTag[0]);
end;

// ���� Key��Iv�����ĺͶ������ݣ����� GCM ������������֤���
function GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer;
  AuthDataByteLength: Integer; PlainData: Pointer; var InTag: TGCM128Tag;
  EncryptType: TAEADEncryptType): Boolean;
var
  H: TGHash128Key;
  Y, Y0: T128BitsBuffer;// Y ƴ���˼�����������
  Cnt, M: Cardinal;      // ������
  C: T128BitsBuffer;      // �����м����ݴ洢��
  AeadCtx: TAEADContext;
  GHashCtx: TGHash128Context;
  Tag: TGCM128Tag;
begin
  if Key = nil then
    KeyByteLength := 0;
  if Iv = nil then
    IvByteLength := 0;
  if AuthData = nil then
    AuthDataByteLength := 0;

  AEADEncryptInit(AeadCtx, Key, KeyByteLength, EncryptType);

  // ���� Enc(Key, 128 �� 0)���õ� H
  FillChar(H[0], SizeOf(H), 0);
  AEADEncryptBlock(AeadCtx, T128BitsBuffer(H), T128BitsBuffer(H), EncryptType);

  // ��ʼ�����������Ժ� Cnt ���������� Y �ĺ� 32 λ��
  if IvByteLength = GCM_NONCE_LENGTH then
  begin
    Move(Iv^, Y[0], GCM_NONCE_LENGTH);
    Cnt := 1;
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));
  end
  else
  begin
    GHash128(H, Iv, IvByteLength, nil, 0, TGHash128Tag(Y));
    Move(Y[GCM_NONCE_LENGTH], Cnt, SizeOf(Cardinal));
    ReverseMemory(@Cnt, SizeOf(Cardinal));
  end;

  // �Ȱ��ʼ�� Y ֵ�ļ��ܽ���������
  AEADEncryptBlock(AeadCtx, T128BitsBuffer(Y), T128BitsBuffer(Y0), EncryptType);

  // ��ʼ�� GHash
  GHash128Start(GHashCtx, H, AuthData, AuthDataByteLength);

  // ��ʼѭ����������
  while EnByteLength >= AEAD_BLOCK do
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �����Ƚ��� GHash
    GHash128Update(GHashCtx, EnData, SizeOf(T128BitsBuffer));

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    AEADEncryptBlock(AeadCtx, T128BitsBuffer(Y), C, EncryptType);

    // ���������C �õ�����Ľ����������
    MemoryXor(EnData, @C[0], SizeOf(T128BitsBuffer), @C[0]);

    // ��������
    Move(C[0], PlainData^, SizeOf(T128BitsBuffer));

    // ׼����һ��
    EnData := Pointer(TCnNativeInt(EnData) + AEAD_BLOCK);
    PlainData := Pointer(TCnNativeInt(PlainData) + AEAD_BLOCK);
    Dec(EnByteLength, AEAD_BLOCK);
  end;

  if EnByteLength > 0 then
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �����Ƚ��� GHash
    GHash128Update(GHashCtx, EnData, EnByteLength);

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    AEADEncryptBlock(AeadCtx, T128BitsBuffer(Y), C, EncryptType);

    // ���������C �õ�����Ľ����������ֻ�� EnByteLength
    MemoryXor(EnData, @C[0], EnByteLength, @C[0]);

    // �������ģ����
    Move(C[0], PlainData^, EnByteLength);
  end;

  // ������� GHash �� Tag
  GHash128Finish(GHashCtx, TGHash128Tag(Tag));

  // �ٺͿ�ʼ���������õ����� Tag
  MemoryXor(@Tag[0], @Y0[0], SizeOf(TGHash128Tag), @Tag[0]);

  Result := CompareMem(@Tag[0], @InTag[0], SizeOf(TGHash128Tag));
end;

function GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag;
  EncryptType: TAEADEncryptType): TBytes;
var
  K, I, P, A: Pointer;
begin
  if Key = nil then
    K := nil
  else
    K := @Key[0];

  if Iv = nil then
    I := nil
  else
    I := @Iv[0];

  if PlainData = nil then
    P := nil
  else
    P := @PlainData[0];

  if AuthData = nil then
    A := nil
  else
    A := @AuthData[0];

  if Length(PlainData) > 0 then
  begin
    SetLength(Result, Length(PlainData));
    GCMEncrypt(K, Length(Key), I, Length(Iv), P, Length(PlainData), A,
      Length(AuthData), @Result[0], OutTag, EncryptType);
  end
  else
  begin
    GCMEncrypt(K, Length(Key), I, Length(Iv), P, Length(PlainData), A,
      Length(AuthData), nil, OutTag, EncryptType);
  end;
end;

function GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag;
  EncryptType: TAEADEncryptType): TBytes;
var
  K, I, P, A: Pointer;
begin
  if Key = nil then
    K := nil
  else
    K := @Key[0];

  if Iv = nil then
    I := nil
  else
    I := @Iv[0];

  if EnData = nil then
    P := nil
  else
    P := @EnData[0];

  if AuthData = nil then
    A := nil
  else
    A := @AuthData[0];

  if Length(EnData) > 0 then
  begin
    SetLength(Result, Length(EnData));
    if not GCMDecrypt(K, Length(Key), I, Length(Iv), P, Length(EnData), A,
      Length(AuthData), @Result[0], InTag, EncryptType) then // Tag �ȶ�ʧ���򷵻�
      SetLength(Result, 0);
  end
  else
  begin
    GCMDecrypt(K, Length(Key), I, Length(Iv), P, Length(EnData), A,
      Length(AuthData), nil, InTag, EncryptType); // û���ģ���ʵ Tag �ȶԳɹ����û��
  end;
end;

function AES128GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, aetAES128);
end;

function AES192GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, aetAES192);
end;

function AES256GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, aetAES256);
end;

function SM4GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, aetSM4);
end;

procedure AES128GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
begin
  GCMEncrypt(Key, KeyByteLength, Iv, IvByteLength, PlainData, PlainByteLength,
    AuthData, AuthDataByteLength, OutEnData, OutTag, aetAES128);
end;

procedure AES192GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
begin
  GCMEncrypt(Key, KeyByteLength, Iv, IvByteLength, PlainData, PlainByteLength,
    AuthData, AuthDataByteLength, OutEnData, OutTag, aetAES192);
end;

procedure AES256GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
begin
  GCMEncrypt(Key, KeyByteLength, Iv, IvByteLength, PlainData, PlainByteLength,
    AuthData, AuthDataByteLength, OutEnData, OutTag, aetAES256);
end;

procedure SM4GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutEnData: Pointer; var OutTag: TGCM128Tag);
begin
  GCMEncrypt(Key, KeyByteLength, Iv, IvByteLength, PlainData, PlainByteLength,
    AuthData, AuthDataByteLength, OutEnData, OutTag, aetSM4);
end;

function AES128GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, aetAES128);
end;

function AES192GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, aetAES192);
end;

function AES256GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, aetAES256);
end;

function SM4GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, aetSM4);
end;

function AES128GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
begin
  Result := GCMDecrypt(Key, KeyByteLength, Iv, IvByteLength, EnData, EnByteLength,
    AuthData, AuthDataByteLength, OutPlainData, InTag, aetAES128);
end;

function AES192GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
begin
  Result := GCMDecrypt(Key, KeyByteLength, Iv, IvByteLength, EnData, EnByteLength,
    AuthData, AuthDataByteLength, OutPlainData, InTag, aetAES192);
end;

function AES256GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
begin
  Result := GCMDecrypt(Key, KeyByteLength, Iv, IvByteLength, EnData, EnByteLength,
    AuthData, AuthDataByteLength, OutPlainData, InTag, aetAES256);
end;

function SM4GCMDecrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  EnData: Pointer; EnByteLength: Integer; AuthData: Pointer; AuthDataByteLength: Integer;
  OutPlainData: Pointer; var InTag: TGCM128Tag): Boolean;
begin
  Result := GCMDecrypt(Key, KeyByteLength, Iv, IvByteLength, EnData, EnByteLength,
    AuthData, AuthDataByteLength, OutPlainData, InTag, aetSM4);
end;

procedure CMAC128(var Key: TCMAC128Key; Data: Pointer; DataByteLength: Integer;
  EncryptType: TAEADEncryptType; var OutTag: TCMAC128Tag);
var
  K1, K2: TCMAC128Key;
  L, X, Y: T128BitsBuffer;
  AeadCtx: TAEADContext;
  LastFull: Boolean;
begin
  AEADEncryptInit(AeadCtx, @Key[0], Length(Key), EncryptType);

  // ���� Enc(Key, 128 �� 0)���õ� L
  FillChar(L[0], SizeOf(L), 0);
  AEADEncryptBlock(AeadCtx, L, L, EncryptType);

  // ���� L ����������Կ
  MemoryShiftLeft(@L[0], @K1[0], SizeOf(TCMAC128Key), 1);
  if AeadIsBitSet(@L[0], 0) then
    MemoryXor(@K1[0], @CMAC_POLY[0], SizeOf(TCMAC128Key), @K1[0]);

  MemoryShiftLeft(@K1[0], @K2[0], SizeOf(TCMAC128Key), 1);
  if AeadIsBitSet(@K1[0], 0) then
    MemoryXor(@K2[0], @CMAC_POLY[0], SizeOf(TCMAC128Key), @K2[0]);

  // ��ʼ�ֿ���㣬ĩ��Ҫ���⴦��
  LastFull := (DataByteLength mod AEAD_BLOCK) = 0;

  // ������ A
  FillChar(X[0], SizeOf(T128BitsBuffer), 0);
  while DataByteLength >= AEAD_BLOCK do
  begin
    Move(Data^, L[0], AEAD_BLOCK); // ���� L ��Ϊÿ��ԭʼ����
    if LastFull and (DataByteLength = AEAD_BLOCK) then // ���һ������
    begin
      MemoryXor(@K1[0], @L[0], AEAD_BLOCK, @L[0]);
      MemoryXor(@X[0], @L[0], AEAD_BLOCK, @Y[0]);
      AEADEncryptBlock(AeadCtx, Y, T128BitsBuffer(OutTag), EncryptType); // ������� Tag
      Exit;
    end;

    MemoryXor(@L[0], @X[0], SizeOf(T128BitsBuffer), @Y[0]);
    AEADEncryptBlock(AeadCtx, Y, X, EncryptType); // һ�ּ������ٴη��� X

    Data := Pointer(TCnNativeInt(Data) + AEAD_BLOCK);
    Dec(DataByteLength, AEAD_BLOCK);
  end;

  FillChar(L[0], SizeOf(T128BitsBuffer), 0);
  if DataByteLength > 0 then
  Move(Data^, L[0], DataByteLength);
  L[DataByteLength] := $80;         // ���һ������飬���� Padding

  MemoryXor(@K2[0], @L[0], AEAD_BLOCK, @L[0]);
  MemoryXor(@X[0], @L[0], AEAD_BLOCK, @Y[0]);
  AEADEncryptBlock(AeadCtx, Y, T128BitsBuffer(OutTag), EncryptType); // ������� Tag
end;

function CMAC128Bytes(Key, Data: TBytes; EncryptType: TAEADEncryptType): TCMAC128Tag;
var
  D: Pointer;
  Key128: TCMAC128Key;
begin
  if Data = nil then
    D := nil
  else
    D := @Data[0];

  MoveMost128(Key[0], Key128[0], Length(Key));
  CMAC128(Key128, D, Length(Data), EncryptType, Result);
end;

function AES128CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
begin
  Result := CMAC128Bytes(Key, Data, aetAES128);
end;

function AES192CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
begin
  Result := CMAC128Bytes(Key, Data, aetAES192);
end;

function AES256CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
begin
  Result := CMAC128Bytes(Key, Data, aetAES256);
end;

function SM4CMAC128Bytes(Key, Data: TBytes): TCMAC128Tag;
begin
  Result := CMAC128Bytes(Key, Data, aetSM4);
end;

function AES128CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
var
  Key128: TCMAC128Key;
begin
  MoveMost128(Key^, Key128[0], KeyByteLength);
  CMAC128(Key128, Data, DataByteLength, aetAES128, Result);
end;

function AES192CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
var
  Key128: TCMAC128Key;
begin
  MoveMost128(Key^, Key128[0], KeyByteLength);
  CMAC128(Key128, Data, DataByteLength, aetAES192, Result);
end;

function AES256CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
var
  Key128: TCMAC128Key;
begin
  MoveMost128(Key^, Key128[0], KeyByteLength);
  CMAC128(Key128, Data, DataByteLength, aetAES256, Result);
end;

function SM4CMAC128(Key: Pointer; KeyByteLength: Integer; Data: Pointer;
  DataByteLength: Integer): TCMAC128Tag;
var
  Key128: TCMAC128Key;
begin
  MoveMost128(Key^, Key128[0], KeyByteLength);
  CMAC128(Key128, Data, DataByteLength, aetSM4, Result);
end;

end.
