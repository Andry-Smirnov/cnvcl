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
  GHASH_BLOCK = 16;

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

procedure GMulBlock128(var X, Y: TGHash128Buffer; var R: TGHash128Buffer);
{* ʵ�� GHash �е�٤�޻��� (2^128) �ϵĿ�˷���������������ͨ����Ҳ���Ͻ�����
  ע�� 2 ����������˷���ļӷ���ģ 2 ��Ҳ�������Ҳ��ͬ��ģ 2 ����
  ͬʱ��Ҫģһ��ģ����ʽ GHASH_POLY�����еĵ��μ�ͬ��Ҳ�����}

function GHash128(var HashKey: TGHash128Key; Data: Pointer; DataByteLength: Integer;
  AAD: Pointer; AADByteLength: Integer): TGHash128Tag;
{* ��ָ�� HashKey �븽������ AAD����һ�����ݽ��� GHash ����õ� Tag ժҪ��
  ��Ӧ�ĵ��е� GHash(H, A C)}

function GHash128Bytes(var HashKey: TGHash128Key; Data, AAD: TBytes): TGHash128Tag;
{* �ֽ����鷽ʽ���� GHash ���㣬�ڲ����� GHash128}

// �����������������ⲿ���������ݽ�����ɢ�� GHash128 ���㣬GHash128Update �ɶ�α�����
// ע�� GHash128Update �� Data ��Ҫ���������飬�粻���飬ĩβ�Ჹ 0 ���㣬
// �����������������Ӵպ������������ŵ���һ�ִ��������

procedure GHash128Start(var Ctx: TGHash128Context; var HashKey: TGHash128Key;
  AAD: Pointer; AADByteLength: Integer);

procedure GHash128Update(var Ctx: TGHash128Context; Data: Pointer; DataByteLength: Integer);

procedure GHash128Finish(var Ctx: TGHash128Context; var Output: TGHash128Tag);

implementation

const
  GHASH_POLY: TGHash128Buffer = ($E1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

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

function GHash128(var HashKey: TGHash128Key; Data: Pointer; DataByteLength: Integer;
  AAD: Pointer; AADByteLength: Integer): TGHash128Tag;
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

  // �������һ�ֳ��ȣ�A �� C �����ֽ�ƴ����
  FillChar(Y[0], SizeOf(TGHash128Buffer), 0);
  AL64 := Int64ToBigEndian(AADByteLength * 8);
  DL64 := Int64ToBigEndian(DataByteLength * 8);

  Move(AL64, Y[0], SizeOf(Int64));
  Move(DL64, Y[SizeOf(Int64)], SizeOf(Int64));

  MemoryXor(@Y[0], @X[0], SizeOf(TGHash128Buffer), @Y[0]);
  GMulBlock128(Y, H, X); // �ٳ�һ��

  Move(X[0], Result[0], SizeOf(TGHash128Tag));
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

  Result := GHash128(HashKey, C, Length(Data), A, Length(AAD));
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

end.
