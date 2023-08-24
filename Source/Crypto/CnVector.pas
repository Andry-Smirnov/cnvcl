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

unit CnVector;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ��������㵥Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��Լ���±� 0 ���������б��ʽ����߻��б��ʽ�������ά�ȵ�����
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.08.22 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative, CnContainers, CnBigNumber;

type
  ECnVectorException = class(Exception);
  {* ������ص��쳣}

  TCnInt64Vector = class(TCnInt64List)
  {* Int64 �����������±�ֵ��Ϊ��Ӧά��ֵ}
  private
    function GetDimension: Integer;
    procedure SetDimension(const Value: Integer);

  public
    constructor Create(ADimension: Integer = 1); virtual;
    {* ���캯��������������ά��}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* �� Int64 ����ת���ַ���}

    property Dimension: Integer read GetDimension write SetDimension;
    {* ����ά��}
  end;

  TCnBigNumberVector = class(TCnBigNumberList)
  {* �������������±�ֵ��Ϊ��Ӧά��ֵ}
  private
    function GetDimension: Integer;
    procedure SetDimension(const Value: Integer);

  public
    constructor Create(ADimension: Integer = 1); virtual;
    {* ���캯��������������ά��}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������������ת���ַ���}

    property Dimension: Integer read GetDimension write SetDimension;
    {* ����ά�ȣ����ú����Զ�������������}
  end;

  TCnBigNumberVectorPool = class(TCnMathObjectPool)
  {* ������������ʵ���࣬����ʹ�õ������������ĵط����д���������������}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnBigNumberVector; reintroduce;
    procedure Recycle(Num: TCnBigNumberVector); reintroduce;
  end;

// ======================== Int64 �����������㺯�� =============================

function Int64VectorToString(const V: TCnInt64Vector): string;
{* �� Int64 ����ת��Ϊ�ַ�����ʽ�����}

function Int64VectorModule(const V: TCnInt64Vector): Extended;
{* ���� Int64 �������ȣ�ģ������Ҳ������ƽ���͵�ƽ����}

function Int64VectorModuleSquare(const V: TCnInt64Vector): Int64;
{* ���� Int64 �������ȣ�ģ������ƽ����Ҳ������ƽ���ĺ�}

procedure Int64VectorCopy(const Dst: TCnInt64Vector; const Src: TCnInt64Vector);
{* ���� Int64 ����������}

procedure Int64VectorSwap(const A: TCnInt64Vector; const B: TCnInt64Vector);
{* ������ Int64 ���������ݣ�Ҫ����������ͬά}

function Int64VectorEqual(const A: TCnInt64Vector; const B: TCnInt64Vector): Boolean;
{* �ж��� Int64 �����Ƿ����}

procedure Int64VectorNegate(const Res: TCnInt64Vector; const A: TCnInt64Vector);
{* �� Int64 �����ķ�������Res �� A ������ͬһ������}

procedure Int64VectorAdd(const Res: TCnInt64Vector; const A: TCnInt64Vector;
  const B: TCnInt64Vector);
{* �� Int64 �����ļӷ������������ظ�ά�ȶ�Ӧ�͡�Res �� A B ������ͬһ������}

procedure Int64VectorSub(const Res: TCnInt64Vector; const A: TCnInt64Vector;
  const B: TCnInt64Vector);
{* �� Int64 �����ļ��������������ظ�ά�ȶ�Ӧ�Res �� A B ������ͬһ������}

procedure Int64VectorMul(const Res: TCnInt64Vector; const A: TCnInt64Vector; N: Int64);
{* Int64 ���������ı����˷���Res �� A ������ͬһ������}

function Int64VectorDotProduct(const A: TCnInt64Vector; const B: TCnInt64Vector): Int64;
{* �� Int64 �����ı����˷�Ҳ���ǵ�ˣ����ظ�ά�ȶ�Ӧ�˻�֮�͡�A �� B ������ͬһ������}

function Int64GaussianLatticeReduction(const V1, V2: TCnInt64Vector; const X, Y: TCnInt64Vector): Boolean;
{* ��������ά Int64 �������������ϵĽ��Ƹ�˹���Լ��������ά SVP ���⣬�����Ƿ�ɹ�}

// ========================= �������������㺯�� ================================

procedure BigNumberVectorModule(const Res: TCnBigNumber; const V: TCnBigNumberVector);
{* ���ش������������ȣ�ģ������Ҳ������ƽ���͵�ƽ����������ȡ��}

procedure BigNumberVectorModuleSquare(const Res: TCnBigNumber; const V: TCnBigNumberVector);
{* ���ش������������ȣ�ģ������ƽ����Ҳ������ƽ���ĺ�}

procedure BigNumberVectorCopy(const Dst: TCnBigNumberVector; const Src: TCnBigNumberVector);
{* ���ƴ���������������}

procedure BigNumberVectorSwap(const A: TCnBigNumberVector; const B: TCnBigNumberVector);
{* ����������������������}

function BigNumberVectorEqual(const A: TCnBigNumberVector; const B: TCnBigNumberVector): Boolean;
{* �ж��������������Ƿ����}

procedure BigNumberVectorNegate(const Res: TCnBigNumberVector; const A: TCnBigNumberVector);
{* ������������ķ�������Res �� A ������ͬһ������}

procedure BigNumberVectorAdd(const Res: TCnBigNumberVector; const A: TCnBigNumberVector;
  const B: TCnBigNumberVector);
{* �������������ļӷ������������ظ�ά�ȶ�Ӧ�͡�Res �� A B ������ͬһ������}

procedure BigNumberVectorSub(const Res: TCnBigNumberVector; const A: TCnBigNumberVector;
  const B: TCnBigNumberVector);
{* �������������ļ��������������ظ�ά�ȶ�Ӧ�Res �� A B ������ͬһ������}

procedure BigNumberVectorMul(const Res: TCnBigNumberVector; const A: TCnBigNumberVector;
  const N: TCnBigNumber);
{* ���������������ı����˷���Res �� A ������ͬһ������}

procedure BigNumberVectorDotProduct(const Res: TCnBigNumber; A: TCnBigNumberVector;
  const B: TCnBigNumberVector);
{* �������������ı����˷�Ҳ���ǵ�ˣ����ظ�ά�ȶ�Ӧ�˻�֮�͡�A �� B ������ͬһ������}

function BigNumberGaussianLatticeReduction(const V1, V2: TCnBigNumberVector; const X, Y: TCnBigNumberVector): Boolean;
{* ��������ά�������������������ϵĽ��Ƹ�˹���Լ��������ά SVP ���⣬�����Ƿ�ɹ�}

implementation

resourcestring
  SCnErrorVectorDimensionInvalid = 'Invalid Dimension!';
  SCnErrorVectorDimensionNotEqual = 'Error Dimension NOT Equal!';

var
  FBigNumberPool: TCnBigNumberPool = nil;
  FBigNumberVectorPool: TCnBigNumberVectorPool = nil;

procedure CheckInt64VectorDimensionEqual(const A, B: TCnInt64Vector);
begin
  if A.Dimension <> B.Dimension then
    raise ECnVectorException.Create(SCnErrorVectorDimensionNotEqual);
end;

function Int64VectorToString(const V: TCnInt64Vector): string;
var
  I: Integer;
begin
  Result := '(';
  for I := 0 to V.Dimension - 1 do
  begin
    if I = 0 then
      Result := Result + IntToStr(V[I])
    else
      Result := Result + ', ' + IntToStr(V[I]);
  end;
  Result := Result + ')';
end;

function Int64VectorModule(const V: TCnInt64Vector): Extended;
var
  T: Extended;
begin
  T := Int64VectorModuleSquare(V);
  Result := Sqrt(T);
end;

function Int64VectorModuleSquare(const V: TCnInt64Vector): Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to V.Dimension - 1 do
    Result := Result + V[I] * V[I];
end;

procedure Int64VectorCopy(const Dst: TCnInt64Vector; const Src: TCnInt64Vector);
var
  I: Integer;
begin
  if Src <> Dst then
  begin
    Dst.Dimension := Src.Dimension;
    for I := 0 to Src.Dimension - 1 do
      Dst[I] := Src[I];
  end;
end;

procedure Int64VectorSwap(const A: TCnInt64Vector; const B: TCnInt64Vector);
var
  I: Integer;
  T: Int64;
begin
  if A <> B then
  begin
    CheckInt64VectorDimensionEqual(A, B);

    for I := 0 to A.Dimension - 1 do
    begin
      T := A[I];
      A[I] := B[I];
      B[I] := T;
    end;
  end;
end;

function Int64VectorEqual(const A: TCnInt64Vector; const B: TCnInt64Vector): Boolean;
var
  I: Integer;
begin
  Result := A.Dimension = B.Dimension;
  if Result then
  begin
    for I := 0 to A.Dimension - 1 do
    begin
      if A[I] <> B[I] then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure Int64VectorNegate(const Res: TCnInt64Vector; const A: TCnInt64Vector);
var
  I: Integer;
begin
  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    Res[I] := -A[I];
end;

procedure Int64VectorAdd(const Res: TCnInt64Vector; const A: TCnInt64Vector;
  const B: TCnInt64Vector);
var
  I: Integer;
begin
  CheckInt64VectorDimensionEqual(A, B);

  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    Res[I] := A[I] + B[I];
end;

procedure Int64VectorSub(const Res: TCnInt64Vector; const A: TCnInt64Vector;
  const B: TCnInt64Vector);
var
  I: Integer;
begin
  CheckInt64VectorDimensionEqual(A, B);

  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    Res[I] := A[I] - B[I];
end;

procedure Int64VectorMul(const Res: TCnInt64Vector; const A: TCnInt64Vector; N: Int64);
var
  I: Integer;
begin
  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    Res[I] := A[I] * N;
end;

function Int64VectorDotProduct(const A: TCnInt64Vector; const B: TCnInt64Vector): Int64;
var
  I: Integer;
begin
  CheckInt64VectorDimensionEqual(A, B);

  Result := 0;
  for I := 0 to A.Dimension - 1 do
    Result := Result + A[I] * B[I];
end;

function Int64GaussianLatticeReduction(const V1, V2: TCnInt64Vector; const X, Y: TCnInt64Vector): Boolean;
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

{ TCnInt64Vector }

constructor TCnInt64Vector.Create(ADimension: Integer);
begin
  inherited Create;
  SetDimension(ADimension);
end;

function TCnInt64Vector.GetDimension: Integer;
begin
  Result := Count;
end;

procedure TCnInt64Vector.SetDimension(const Value: Integer);
begin
  if Value <= 0 then
    raise ECnVectorException.Create(SCnErrorVectorDimensionInvalid);

  SetCount(Value);
end;

function TCnInt64Vector.ToString: string;
begin
  Result := Int64VectorToString(Self);
end;

{ TCnBigNumberVector }

constructor TCnBigNumberVector.Create(ADimension: Integer);
begin
  inherited Create;
  SetDimension(ADimension);
end;

function TCnBigNumberVector.GetDimension: Integer;
begin
  Result := Count;
end;

procedure TCnBigNumberVector.SetDimension(const Value: Integer);
var
  I, OC: Integer;
begin
  if Value <= 0 then
    raise ECnVectorException.Create(SCnErrorVectorDimensionInvalid);

  OC := Count;
  Count := Value; // ֱ������ Count�����С�����Զ��ͷŶ���Ķ���

  if Count > OC then  // ���ӵĲ��ִ����¶���
  begin
    for I := OC to Count - 1 do
      Items[I] := TCnBigNumber.Create;
  end;
end;

procedure CheckBigNumberVectorDimensionEqual(const A, B: TCnBigNumberVector);
begin
  if A.Dimension <> B.Dimension then
    raise ECnVectorException.Create(SCnErrorVectorDimensionNotEqual);
end;

function BigNumberVectorToString(const V: TCnBigNumberVector): string;
var
  I: Integer;
begin
  Result := '(';
  for I := 0 to V.Dimension - 1 do
  begin
    if I = 0 then
      Result := Result + V[I].ToString
    else
      Result := Result + ', ' + V[I].ToString;
  end;
  Result := Result + ')';
end;

procedure BigNumberVectorModule(const Res: TCnBigNumber; const V: TCnBigNumberVector);
begin
  BigNumberVectorModuleSquare(Res, V);
  BigNumberSqrt(Res, Res);
end;

procedure BigNumberVectorModuleSquare(const Res: TCnBigNumber; const V: TCnBigNumberVector);
var
  I: Integer;
  T: TCnBigNumber;
begin
  Res.SetZero;
  T := FBigNumberPool.Obtain;
  try
    for I := 0 to V.Dimension - 1 do
    begin
      BigNumberMul(T, V[I], V[I]);
      BigNumberAdd(Res, Res, T);
    end;
  finally
    FBigNumberPool.Recycle(T);
  end;
end;

procedure BigNumberVectorCopy(const Dst: TCnBigNumberVector; const Src: TCnBigNumberVector);
var
  I: Integer;
begin
  if Src <> Dst then
  begin
    Dst.Dimension := Src.Dimension;
    for I := 0 to Src.Dimension - 1 do
      BigNumberCopy(Dst[I], Src[I]);
  end;
end;

procedure BigNumberVectorSwap(const A: TCnBigNumberVector; const B: TCnBigNumberVector);
var
  I: Integer;
begin
  if A <> B then
  begin
    CheckBigNumberVectorDimensionEqual(A, B);

    for I := 0 to A.Dimension - 1 do
      BigNumberSwap(A[I], B[I]);
  end;
end;

function BigNumberVectorEqual(const A: TCnBigNumberVector; const B: TCnBigNumberVector): Boolean;
var
  I: Integer;
begin
  Result := A.Dimension = B.Dimension;
  if Result then
  begin
    for I := 0 to A.Dimension - 1 do
    begin
      if not BigNumberEqual(A[I], B[I]) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure BigNumberVectorNegate(const Res: TCnBigNumberVector; const A: TCnBigNumberVector);
var
  I: Integer;
begin
  BigNumberVectorCopy(Res, A);
  for I := 0 to A.Dimension - 1 do
    Res[I].Negate;
end;

procedure BigNumberVectorAdd(const Res: TCnBigNumberVector; const A: TCnBigNumberVector;
  const B: TCnBigNumberVector);
var
  I: Integer;
begin
  CheckBigNumberVectorDimensionEqual(A, B);

  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    BigNumberAdd(Res[I], A[I], B[I]);
end;

procedure BigNumberVectorSub(const Res: TCnBigNumberVector; const A: TCnBigNumberVector;
  const B: TCnBigNumberVector);
var
  I: Integer;
begin
  CheckBigNumberVectorDimensionEqual(A, B);

  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    BigNumberSub(Res[I], A[I], B[I]);
end;

procedure BigNumberVectorMul(const Res: TCnBigNumberVector; const A: TCnBigNumberVector;
  const N: TCnBigNumber);
var
  I: Integer;
begin
  Res.Dimension := A.Dimension;
  for I := 0 to A.Dimension - 1 do
    BigNumberMul(Res[I], A[I], N);
end;

procedure BigNumberVectorDotProduct(const Res: TCnBigNumber; A: TCnBigNumberVector;
  const B: TCnBigNumberVector);
var
  I: Integer;
  T: TCnBigNumber;
begin
  CheckBigNumberVectorDimensionEqual(A, B);

  Res.SetZero;
  T := FBigNumberPool.Obtain;
  try
    for I := 0 to A.Dimension - 1 do
    begin
      BigNumberMul(T, A[I], B[I]);
      BigNumberAdd(Res, Res, T);
    end;
  finally
    FBigNumberPool.Recycle(T);
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

function TCnBigNumberVector.ToString: string;
begin
  Result := BigNumberVectorToString(Self);
end;

{ TCnBigNumberVectorPool }

function TCnBigNumberVectorPool.CreateObject: TObject;
begin
  Result := TCnBigNumberVector.Create(1);
end;

function TCnBigNumberVectorPool.Obtain: TCnBigNumberVector;
begin
  Result := TCnBigNumberVector(inherited Obtain);
  Result.SetDimension(1);
end;

procedure TCnBigNumberVectorPool.Recycle(Num: TCnBigNumberVector);
begin
  inherited Recycle(Num);
end;

initialization
  FBigNumberPool := TCnBigNumberPool.Create;
  FBigNumberVectorPool := TCnBigNumberVectorPool.Create;

finalization
  FBigNumberVectorPool.Free;
  FBigNumberPool.Free;

end.
