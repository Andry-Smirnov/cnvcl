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
*           Ŀǰʵ���� GHash128���ƺ�Ҳ�� GMAC��
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.07.27 V1.0
*               ������Ԫ��
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative;

const
  GHASH_BLOCK = 16;       // GHASH �ķ��� 16 �ֽ�

  GCM_BLOCK   = 16;       // GCM �ķ��� 16 �ֽ�

  GCM_NONCE_LENGTH = 12;  // 12 �ֽڵ� Nonce �������ƴ������ Iv

type
  TGHash128Buffer = array[0..GHASH_BLOCK - 1] of Byte;
  {* GHash128 �ķֿ�}

  TGHash128Key = array[0..GHASH_BLOCK - 1] of Byte;
  {* GHash128 ����Կ}

  TGHash128Tag    = array[0..GHASH_BLOCK - 1] of Byte;
  {* GHash128 �ļ�����}

  TGHash128Context = packed record
  {* ���ڶ�ηֿ����� GHash128 �����Ľṹ}
    HashKey:  TGHash128Buffer;
    State:    TGHash128Buffer;
    AADByteLen: Integer;
    DataByteLen: Integer;
  end;

  TGCM128Buffer = array[0..GCM_BLOCK - 1] of Byte;
  {* GCM ģʽ�ķֿ飬�ڲ������� AES ���� SM4 ��Ϊ 16 �ֽ�}

  TGCM128Key = array[0..GCM_BLOCK - 1] of Byte;
  {* GCM ģʽ����Կ���ڲ������� AES ���� SM4 ��Ϊ 16 �ֽ�}

  TGCM128Tag    = array[0..GCM_BLOCK - 1] of Byte;
  {* GCM �ļ�����}

procedure GMulBlock128(var X, Y: TGHash128Buffer; var R: TGHash128Buffer);
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

// ========================== AES/SM4 - GCM �ӽ��ܺ��� =========================

function AES128GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
function AES192GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
function AES256GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
function SM4GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;

function AES128GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
function AES192GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
function AES256GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
function SM4GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;

implementation

uses
  CnSM4, CnAES;

const
  GHASH_POLY: TGHash128Buffer = ($E1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

type
  TGCMEncryptType = (getAES128, getAES192, getAES256, getSM4);
  {* ֧�ֵ����� GCM ����}

  TGCMContext = packed record
  case TGCMEncryptType of
    getAES128: (ExpandedKey128: TAESExpandedKey128);
    getAES192: (ExpandedKey192: TAESExpandedKey192);
    getAES256: (ExpandedKey256: TAESExpandedKey256);
    getSM4:    (SM4Context: TSM4Context);
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
procedure GMulBlock128(var X, Y: TGHash128Buffer; var R: TGHash128Buffer);
var
  I: Integer;
  Z, V: TGHash128Buffer;
  B: Boolean;

  // ע��˴��ж��ֽ��� Bit ��˳��Ҳ���ֽ��ڵĸ�λ�� 0��
  function GHashIsBitSet(AMem: Pointer; N: Integer): Boolean;
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

begin
  FillChar(Z[0], SizeOf(TGHash128Buffer), 0);
  Move(X[0], V[0], SizeOf(TGHash128Buffer));

  for I := 0 to 127 do
  begin
    if GHashIsBitSet(@Y[0], I) then
      MemoryXor(@Z[0], @V[0], SizeOf(TGHash128Buffer), @Z[0]);

    B := GHashIsBitSet(@V[0], 127); // �жϴ������ĸ�λ�Ƿ��� 1
    MemoryShiftRight(@V[0], nil, SizeOf(TGHash128Buffer), 1);
    if B then
      MemoryXor(@V[0], @GHASH_POLY[0], SizeOf(TGHash128Buffer), @V[0]);
  end;
  Move(Z[0], R[0], SizeOf(TGHash128Buffer));
end;

procedure GHash128(var HashKey: TGHash128Key; Data: Pointer; DataByteLength: Integer;
  AAD: Pointer; AADByteLength: Integer; var OutTag: TGHash128Tag);
var
  AL, DL: Integer;
  AL64, DL64: Int64;
  X, Y, H: TGHash128Buffer;
begin
  // �Ա� GHash(H, A, C)��Data �� C��AAD �� A��Key �� H
  // �� 16 �ֽڷ֣�C �� m �飬A �� n �飨ĩ�鶼���ܲ�������
  // ���� m + n ��������ݵ� GaloisMulBlock���ټ�һ��λ����

  FillChar(X[0], SizeOf(TGHash128Buffer), 0);  // ��ʼȫ 0
  Move(HashKey[0], H[0], SizeOf(TGHash128Buffer));

  AL := AADByteLength;
  DL := DataByteLength;
  if Data = nil then
    DL := 0;
  if AAD = nil then
    AL := 0;

  // ������ A
  while AL >= GHASH_BLOCK do
  begin
    Move(AAD^, Y[0], GHASH_BLOCK);

    MemoryXor(@Y[0], @X[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, H, X);  // һ�ּ������ٴη��� X

    AAD := Pointer(TCnNativeInt(AAD) + GHASH_BLOCK);
    Dec(AL, GHASH_BLOCK);
  end;

  // ����� A������еĻ�
  if AL > 0 then
  begin
    FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
    Move(AAD^, Y[0], AL);

    MemoryXor(@Y[0], @X[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, H, X);
  end;

  // ������ C
  while DL >= GHASH_BLOCK do
  begin
    Move(Data^, Y[0], GHASH_BLOCK);

    MemoryXor(@Y[0], @X[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, H, X);  // һ�ּ������ٴη��� X

    Data := Pointer(TCnNativeInt(Data) + GHASH_BLOCK);
    Dec(DL, GHASH_BLOCK);
  end;

  // ����� C������еĻ�
  if DL > 0 then
  begin
    FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
    Move(Data^, Y[0], DL);

    MemoryXor(@Y[0], @X[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, H, X);
  end;

  // �������һ�ֳ��ȣ�A �� C �����ֽ�ƴ������ƴ��Ҫ����������׼���Ķ�ϰ��Ҳ���� BigEndian
  FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
  AL64 := Int64ToBigEndian(AADByteLength * 8);
  DL64 := Int64ToBigEndian(DataByteLength * 8);

  Move(AL64, Y[0], SizeOf(Int64));
  Move(DL64, Y[SizeOf(Int64)], SizeOf(Int64));

  MemoryXor(@Y[0], @X[0], SizeOf(TGHash128Buffer), @Y[0]);
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
  Y: TGHash128Buffer;
begin
  FillChar(Ctx.State[0], SizeOf(TGHash128Buffer), 0);  // ��ʼȫ 0
  Move(HashKey[0], Ctx.HashKey[0], SizeOf(TGHash128Buffer));

  Ctx.DataByteLen := 0;
  Ctx.AADByteLen := AADByteLength;
  if AAD = nil then
    Ctx.AADByteLen := 0;

  // ������ A
  while AADByteLength >= GHASH_BLOCK do
  begin
    Move(AAD^, Y[0], GHASH_BLOCK);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);  // һ�ּ������ٴη��� Ctx.State

    AAD := Pointer(TCnNativeInt(AAD) + GHASH_BLOCK);
    Dec(AADByteLength, GHASH_BLOCK);
  end;

  // ����� A������еĻ�
  if AADByteLength > 0 then
  begin
    FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
    Move(AAD^, Y[0], AADByteLength);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);
  end;
end;

procedure GHash128Update(var Ctx: TGHash128Context; Data: Pointer; DataByteLength: Integer);
var
  Y: TGHash128Buffer;
begin
  if (Data = nil) or (DataByteLength <= 0) then
    Exit;

  Ctx.DataByteLen := Ctx.DataByteLen + DataByteLength;

  // ������ C
  while DataByteLength >= GHASH_BLOCK do
  begin
    Move(Data^, Y[0], GHASH_BLOCK);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);  // һ�ּ������ٴη��� Ctx.State

    Data := Pointer(TCnNativeInt(Data) + GHASH_BLOCK);
    Dec(DataByteLength, GHASH_BLOCK);
  end;

  // ����� C������еĻ�
  if DataByteLength > 0 then
  begin
    FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
    Move(Data^, Y[0], DataByteLength);

    MemoryXor(@Y[0], @Ctx.State[0], SizeOf(TGHash128Buffer), @Y[0]);
    GMulBlock128(Y, Ctx.HashKey, Ctx.State);
  end;
end;

procedure GHash128Finish(var Ctx: TGHash128Context; var Output: TGHash128Tag);
var
  Y: TGHash128Buffer;
  AL64, DL64: Int64;
begin
  // �������һ�ֳ��ȣ�A �� C �����ֽ�ƴ����
  FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
  AL64 := Int64ToBigEndian(Ctx.AADByteLen * 8);
  DL64 := Int64ToBigEndian(Ctx.DataByteLen * 8);

  Move(AL64, Y[0], SizeOf(Int64));
  Move(DL64, Y[SizeOf(Int64)], SizeOf(Int64));

  MemoryXor(@Y[0], @Ctx.State[0], SizeOf(TGHash128Buffer), @Y[0]);
  GMulBlock128(Y, Ctx.HashKey, Ctx.State); // �ٳ�һ�֣�

  Move(Ctx.State[0], Output[0], SizeOf(TGHash128Tag)); // ����� Output
end;

// ���ݶԳƼ����㷨���ͳ�ʼ��������Կ�ṹ��ע�ⲻ��Ҫ������Կ�ṹ
procedure GCMEncryptInit(var Context: TGCMContext; Key: Pointer;
  KeyByteLength: Integer; EncryptType: TGCMEncryptType);
var
  Key128: TAESKey128;
  Key192: TAESKey192;
  Key256: TAESKey256;
  SM4Key: TSM4Key;
  L: Integer;
begin
  FillChar(Context, SizeOf(TGCMContext), 0);
  L := KeyByteLength;

  case EncryptType of
    getAES128:
      begin
        if L > SizeOf(TAESKey128) then
          L := SizeOf(TAESKey128);
        FillChar(Key128[0], SizeOf(TAESKey128), 0);
        Move(Key^, Key128[0], L);
        ExpandAESKeyForEncryption(Key128, Context.ExpandedKey128);
      end;
    getAES192:
      begin
        if L > SizeOf(TAESKey192) then
          L := SizeOf(TAESKey192);
        FillChar(Key192[0], SizeOf(TAESKey192), 0);
        Move(Key^, Key192[0], L);
        ExpandAESKeyForEncryption(Key192, Context.ExpandedKey192);
      end;
    getAES256:
      begin
        if L > SizeOf(TAESKey256) then
          L := SizeOf(TAESKey256);
        FillChar(Key256[0], SizeOf(TAESKey256), 0);
        Move(Key^, Key256[0], L);
        ExpandAESKeyForEncryption(Key256, Context.ExpandedKey256);
      end;
    getSM4:
      begin
        if L > SizeOf(TSM4Key) then
          L := SizeOf(TSM4Key);
        FillChar(SM4Key[0], SizeOf(SM4Key), 0);
        Move(Key^, SM4Key[0], L);
        SM4SetKeyEnc(Context.SM4Context, @SM4Key[0]);
      end;
  end;
end;

// ���ݶԳƼ����㷨���ͼ���һ���飬���鴮�������Ǽ��ܽ����ע�ⲻ��Ҫ�����
procedure GCMEncryptBlock(var Context: TGCMContext; var InData, OutData: TGCM128Buffer;
  EncryptType: TGCMEncryptType);
begin
  case EncryptType of
    getAES128: EncryptAES(TAESBuffer(InData), Context.ExpandedKey128, TAESBuffer(OutData));
    getAES192: EncryptAES(TAESBuffer(InData), Context.ExpandedKey192, TAESBuffer(OutData));
    getAES256: EncryptAES(TAESBuffer(InData), Context.ExpandedKey256, TAESBuffer(OutData));
    getSM4:    SM4OneRound(@(Context.SM4Context.Sk[0]), @InData[0], @OutData[0]);
  end;
end;

// ���� Key��Iv�����ĺͶ������ݣ����� GCM ������������֤���
procedure GCMEncrypt(Key: Pointer; KeyByteLength: Integer; Iv: Pointer; IvByteLength: Integer;
  PlainData: Pointer; PlainByteLength: Integer; AuthData: Pointer;
  AuthDataByteLength: Integer; EnData: Pointer; var OutTag: TGCM128Tag;
  EncryptType: TGCMEncryptType);
var
  H: TGHash128Key;
  Y, Y0: TGHash128Buffer;// Y ƴ���˼�����������
  Cnt, M: Cardinal;      // ������
  C: TGCM128Buffer;      // �����м����ݴ洢��
  GcmCtx: TGCMContext;
  GHashCtx: TGHash128Context;
begin
  if Key = nil then
    KeyByteLength := 0;
  if Iv = nil then
    IvByteLength := 0;
  if AuthData = nil then
    AuthDataByteLength := 0;

  GCMEncryptInit(GcmCtx, Key, KeyByteLength, EncryptType);

  // ���� Enc(Key, 128 �� 0)���õ� H
  FillChar(H[0], SizeOf(H), 0);
  GCMEncryptBlock(GcmCtx, TGCM128Buffer(H), TGCM128Buffer(H), EncryptType);

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
  GCMEncryptBlock(GcmCtx, TGCM128Buffer(Y), TGCM128Buffer(Y0), EncryptType);

  // ��ʼ�� GHash
  GHash128Start(GHashCtx, H, AuthData, AuthDataByteLength);

  // ��ʼѭ����������
  while PlainByteLength >= GCM_BLOCK do
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    GCMEncryptBlock(GcmCtx, TGCM128Buffer(Y), C, EncryptType);

    // ���������C �õ�����Ľ����������
    MemoryXor(PlainData, @C[0], SizeOf(TGCM128Buffer), @C[0]);

    // ��������
    Move(C[0], EnData^, SizeOf(TGCM128Buffer));

    // C ���� GHash
    GHash128Update(GHashCtx, @C[0], SizeOf(TGCM128Buffer));

    // ׼����һ��
    PlainData := Pointer(TCnNativeInt(PlainData) + GCM_BLOCK);
    EnData := Pointer(TCnNativeInt(EnData) + GCM_BLOCK);
    Dec(PlainByteLength, GCM_BLOCK);
  end;

  if PlainByteLength > 0 then
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    GCMEncryptBlock(GcmCtx, TGCM128Buffer(Y), C, EncryptType);

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
  EncryptType: TGCMEncryptType): Boolean;
var
  H: TGHash128Key;
  Y, Y0: TGHash128Buffer;// Y ƴ���˼�����������
  Cnt, M: Cardinal;      // ������
  C: TGCM128Buffer;      // �����м����ݴ洢��
  GcmCtx: TGCMContext;
  GHashCtx: TGHash128Context;
  Tag: TGCM128Tag;
begin
  if Key = nil then
    KeyByteLength := 0;
  if Iv = nil then
    IvByteLength := 0;
  if AuthData = nil then
    AuthDataByteLength := 0;

  GCMEncryptInit(GcmCtx, Key, KeyByteLength, EncryptType);

  // ���� Enc(Key, 128 �� 0)���õ� H
  FillChar(H[0], SizeOf(H), 0);
  GCMEncryptBlock(GcmCtx, TGCM128Buffer(H), TGCM128Buffer(H), EncryptType);

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
  GCMEncryptBlock(GcmCtx, TGCM128Buffer(Y), TGCM128Buffer(Y0), EncryptType);

  // ��ʼ�� GHash
  GHash128Start(GHashCtx, H, AuthData, AuthDataByteLength);

  // ��ʼѭ����������
  while EnByteLength >= GCM_BLOCK do
  begin
    // ���������������� Y
    Inc(Cnt);
    M := Int32ToBigEndian(Cnt);
    Move(M, Y[GCM_NONCE_LENGTH], SizeOf(M));

    // �����Ƚ��� GHash
    GHash128Update(GHashCtx, EnData, SizeOf(TGCM128Buffer));

    // �� Y ���� C ��ʱ�õ�����ļ��ܽ��
    GCMEncryptBlock(GcmCtx, TGCM128Buffer(Y), C, EncryptType);

    // ���������C �õ�����Ľ����������
    MemoryXor(EnData, @C[0], SizeOf(TGCM128Buffer), @C[0]);

    // ��������
    Move(C[0], PlainData^, SizeOf(TGCM128Buffer));

    // ׼����һ��
    EnData := Pointer(TCnNativeInt(EnData) + GCM_BLOCK);
    PlainData := Pointer(TCnNativeInt(PlainData) + GCM_BLOCK);
    Dec(EnByteLength, GCM_BLOCK);
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
    GCMEncryptBlock(GcmCtx, TGCM128Buffer(Y), C, EncryptType);

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
  EncryptType: TGCMEncryptType): TBytes;
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
  EncryptType: TGCMEncryptType): TBytes;
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
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, getAES128);
end;

function AES192GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, getAES192);
end;

function AES256GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, getAES256);
end;

function SM4GCMEncryptBytes(Key, Iv, PlainData, AuthData: TBytes; var OutTag: TGCM128Tag): TBytes;
begin
  Result := GCMEncryptBytes(Key, Iv, PlainData, AuthData, OutTag, getSM4);
end;

function AES128GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, getAES128);
end;

function AES192GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, getAES192);
end;

function AES256GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, getAES256);
end;

function SM4GCMDecryptBytes(Key, Iv, EnData, AuthData: TBytes; var InTag: TGCM128Tag): TBytes;
begin
  Result := GCMDecryptBytes(Key, Iv, EnData, AuthData, InTag, getSM4);
end;

end.
