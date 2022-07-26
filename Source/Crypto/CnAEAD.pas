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
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.07.23 V1.0
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

  TGHash128Key = array[0..GHASH_BLOCK - 1] of Byte;

  TGHash128Iv  = array[0..GHASH_BLOCK - 1] of Byte;

  TGHash128Tag    = array[0..GHASH_BLOCK - 1] of Byte;

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

end.
