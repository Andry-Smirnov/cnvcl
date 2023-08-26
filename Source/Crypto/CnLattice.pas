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

unit CnLattice;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ���������㵥Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.08.25 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative, CnVector, CnBigNumber;

function Int64GaussianLatticeReduction(const V1, V2: TCnInt64Vector;
  const X, Y: TCnInt64Vector): Boolean;
{* ��������ά Int64 �������������ϵĽ��Ƹ�˹���Լ��������ά SVP ���⣬�����Ƿ�ɹ�}

function BigNumberGaussianLatticeReduction(const V1, V2: TCnBigNumberVector;
  const X, Y: TCnBigNumberVector): Boolean;
{* ��������ά�������������������ϵĽ��Ƹ�˹���Լ��������ά SVP ���⣬�����Ƿ�ɹ�
   �õ���Ȼ�Ǹ���ķ-ʩ���ص�������˼�룬�����������������}

implementation

var
  FBigNumberPool: TCnBigNumberPool = nil;
  FBigNumberVectorPool: TCnBigNumberVectorPool = nil;

function Int64GaussianLatticeReduction(const V1, V2: TCnInt64Vector;
  const X, Y: TCnInt64Vector): Boolean;
var
  U1, U2, T: TCnInt64Vector;
  M: Int64;
  K: Extended;
begin
  U1 := nil;
  U2 := nil;
  T := nil;

  try
    U1 := TCnInt64Vector.Create;
    U2 := TCnInt64Vector.Create;
    T := TCnInt64Vector.Create;

    Int64VectorCopy(U1, X);
    Int64VectorCopy(U2, Y);

    if Int64VectorModule(U1) > Int64VectorModule(U2) then
      Int64VectorSwap(U1, U2);

    while True do
    begin
      K := Int64VectorDotProduct(U2, U1) / Int64VectorDotProduct(U1, U1);
      M := Round(K);  // K ���ܱ�ȡ����� M ��

      Int64VectorMul(T, U1, M);
      Int64VectorSub(U2, U2, T);
//      if M > K then   // �����ø��ƺ����岻���Ҹ��汾��һ
//        Int64VectorNegate(U2, U2);

      if Int64VectorModule(U1) <= Int64VectorModule(U2) then
      begin
        Int64VectorCopy(V1, U1);
        Int64VectorCopy(V2, U2);
        Result := True;
        Exit;
      end
      else
        Int64VectorSwap(U1, U2);
    end;
  finally
    T.Free;
    U2.Free;
    U1.Free;
  end;
end;

function BigNumberGaussianLatticeReduction(const V1, V2: TCnBigNumberVector;
  const X, Y: TCnBigNumberVector): Boolean;
var
  U1, U2, T: TCnBigNumberVector;
  M, M1, M2: TCnBigNumber;
  Ru: Boolean;
begin
  U1 := nil;
  U2 := nil;
  T := nil;
  M := nil;
  M1 := nil;
  M2 := nil;

  try
    U1 := FBigNumberVectorPool.Obtain;
    U2 := FBigNumberVectorPool.Obtain;
    T := FBigNumberVectorPool.Obtain;
    M := FBigNumberPool.Obtain;
    M1 := FBigNumberPool.Obtain;
    M2 := FBigNumberPool.Obtain;

    // ȷ�� |X| <= |Y|
    BigNumberVectorCopy(U1, X);
    BigNumberVectorCopy(U2, Y);

    BigNumberVectorModuleSquare(M1, U1);
    BigNumberVectorModuleSquare(M2, U2);
    if BigNumberCompare(M1, M2) > 0 then
      BigNumberVectorSwap(U1, U2);

    // U1 := X;  U2 := Y;
    while True do
    begin
      BigNumberVectorDotProduct(M2, U2, U1);
      BigNumberVectorDotProduct(M1, U1, U1);
      BigNumberRoundDiv(M, M2, M1, Ru); // Ru ���Ϊ True ��ʾ���� M ����ʵ�����

      BigNumberVectorMul(T, U1, M);
      BigNumberVectorSub(U2, U2, T);
//      if Ru then   // �����ø��ƺ����岻���Ҹ��汾��һ
//        BigNumberVectorNegate(U2, U2);

      BigNumberVectorModuleSquare(M1, U1);
      BigNumberVectorModuleSquare(M2, U2);
      if BigNumberCompare(M1, M2) <= 0 then
      begin
        BigNumberVectorCopy(V1, U1);
        BigNumberVectorCopy(V2, U2);
        Result := True;
        Exit;
      end
      else
        BigNumberVectorSwap(U1, U2);
    end;
  finally
    FBigNumberPool.Recycle(M2);
    FBigNumberPool.Recycle(M1);
    FBigNumberPool.Recycle(M);
    FBigNumberVectorPool.Recycle(T);
    FBigNumberVectorPool.Recycle(U2);
    FBigNumberVectorPool.Recycle(U1);
  end;
end;

initialization
  FBigNumberPool := TCnBigNumberPool.Create;
  FBigNumberVectorPool := TCnBigNumberVectorPool.Create;

finalization
  FBigNumberVectorPool.Free;
  FBigNumberPool.Free;

end.
