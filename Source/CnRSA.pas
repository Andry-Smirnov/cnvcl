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

unit CnRSA;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�RSA �㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע������ Int64 ��Χ�ڵ� RSA �㷨�Լ������㷨����δʵ�֣���
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2017.04.03 V1.0
*               ������Ԫ��Int64 ��Χ�ڵ� RSA �� CnPrimeNumber �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, CnPrimeNumber;

function CnInt64RSAGenerateKeys(out PrimeKey1: Integer; out PrimeKey2: Integer;
  out PrivKeyProduct: Int64; out PrivKeyExponent: Int64;
  out PubKeyProduct: Int64; out PubKeyExponent: Int64): Boolean;
{* ���� RSA �㷨����Ĺ�˽Կ�������������� Integer��Keys �������� Int64}

function CnInt64RSAEncrypt(Data: Int64; PrivKeyProduct: Int64;
  PrivKeyExponent: Int64; out Res: Int64): Boolean;
{* �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�}

function CnInt64RSADecrypt(Res: Int64; PubKeyProduct: Int64;
  PubKeyExponent: Int64; out Data: Int64): Boolean;
{* �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�}

implementation

// ���ù�˽Կ�����ݽ��мӽ��ܣ�ע��ӽ���ʹ�õ���ͬһ�׻��ƣ���������
function Int64RSACrypt(Data: Int64; Product: Int64; Exponent: Int64;
  out Res: Int64): Boolean;
begin
  Res := MontgomeryPowerMod(Data, Exponent, Product);
  Result := True;
end;

// ��չŷ�����շת��������Ԫһ�β������� A * X + B * Y = 1 ��������
function ExtendedEuclideanGcd(A, B: Int64; out X: Int64; out Y: Int64): Int64;
var
  R, T: Int64;
begin
  if B = 0 then
  begin
    X := 1;
    Y := 0;
    Result := A;
  end
  else
  begin
    R := ExtendedEuclideanGcd(B, A mod B, X, Y);
    T := X;
    X := Y;
    Y := T - (A div B) * Y;
    Result := R;
  end;
end;

// ���� RSA �㷨����Ĺ�˽Կ�������������� Integer��Keys �������� Int64
function CnInt64RSAGenerateKeys(out PrimeKey1: Integer; out PrimeKey2: Integer;
  out PrivKeyProduct: Int64; out PrivKeyExponent: Int64;
  out PubKeyProduct: Int64; out PubKeyExponent: Int64): Boolean;
var
  N: Integer;
  Product, Y: Int64;
begin
  PrimeKey1 := CnGenerateInt32Prime;

  N := Trunc(Random * 1000);
  Sleep(N);

  PrimeKey2 := CnGenerateInt32Prime;
  PrivKeyProduct := Int64(PrimeKey1) * Int64(PrimeKey2);
  PubKeyProduct := Int64(PrimeKey2) * Int64(PrimeKey1);   // ���ڹ�˽Կ������ͬ��
  PubKeyExponent := 65537;                                // �̶�

  Product := Int64(PrimeKey1 - 1) * Int64(PrimeKey2 - 1);

  //                      e                d                p
  // ��շת������� PubKeyExponent * PrivKeyExponent mod Product = 1 �е� PrivKeyExponent
  // Ҳ���ǽⷽ�� e * d + p * y = 1������ e��p ��֪���� d �� y��
  ExtendedEuclideanGcd(PubKeyExponent, Product, PrivKeyExponent, Y);
  while PrivKeyExponent < 0 do
  begin
     // ���������� d С�� 0���򲻷�����������Ҫ�� d ���� p���ӵ�������Ϊֹ
     PrivKeyExponent := PrivKeyExponent + Product;
  end;
  Result := True;
end;

// �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�
function CnInt64RSAEncrypt(Data: Int64; PrivKeyProduct: Int64;
  PrivKeyExponent: Int64; out Res: Int64): Boolean;
begin
  Result := Int64RSACrypt(Data, PrivKeyProduct, PrivKeyExponent, Res);
end;

// �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�
function CnInt64RSADecrypt(Res: Int64; PubKeyProduct: Int64;
  PubKeyExponent: Int64; out Data: Int64): Boolean;
begin
  Result := Int64RSACrypt(Res, PubKeyProduct, PubKeyExponent, Data);
end;

end.
