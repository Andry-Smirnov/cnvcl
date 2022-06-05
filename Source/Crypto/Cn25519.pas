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

unit Cn25519;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�25519 ϵ����Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��Ŀǰʵ���� Montgomery ��Բ���� y^2 = x^3 + A*X^2 + x
*           �Լ�Ť�� Edwards ��Բ���� au^2 + v^2 = 1 + d * u^2 * v^2 �ĵ�Ӽ���
*           ��δʵ�ֽ����� X �Լ��ɸ��������ݵĿ��ټ���
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2022.06.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNativeDecl, CnBigNumber, CnECC;

type
  TCnTwistedEdwardsCurve = class
  {* �������ϵ�Ť�����»����� au^2 + v^2 = 1 + du^2v^2 (���� u v ���ɸ��������ߵ� x y ��ӳ���ϵ)}
  private
    FCoefficientA: TCnBigNumber;
    FCoefficientD: TCnBigNumber;
    FOrder: TCnBigNumber;
    FFiniteFieldSize: TCnBigNumber;
    FGenerator: TCnEccPoint;
    FCoFactor: Integer;
  public
    constructor Create; overload; virtual;
    {* ��ͨ���캯����δ��ʼ������}
    constructor Create(const A, D, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); overload;
    {* ���캯�������뷽�̵� A, D �������������Ͻ� p��G �����ꡢG ��Ľ�������Ҫʮ�������ַ���}

    destructor Destroy; override;
    {* ��������}

    procedure Load(const A, D, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); virtual;
    {* �������߲�����ע���ַ���������ʮ�����Ƹ�ʽ}

    procedure MultiplePoint(K: Int64; Point: TCnEccPoint); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P���ڲ�ʵ�ֵ�ͬ�� CnECC ��ͬ������}

    function PointAddPoint(P, Q, Sum: TCnEccPoint): Boolean;
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ
      �˴��ļӷ��ļ��������൱�ڵ�λԲ�ϵ����� Y ��ļнǽǶ���ӷ���
      ���Ե�(0, 1)����ͬ�� Weierstrass �����е�����Զ��}
    function PointSubPoint(P, Q, Diff: TCnEccPoint): Boolean;
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P��Ҳ���� X ֵȡ��}
    function IsPointOnCurve(P: TCnEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function IsNeutualPoint(P: TCnEccPoint): Boolean;
    {* �жϵ��Ƿ������Ե㣬Ҳ�����ж� X = 0 �� Y = 1���� Weierstrass ������Զ��ȫ 0 ��ͬ}
    procedure SetNeutualPoint(P: TCnEccPoint);
    {* ������Ϊ���Ե㣬Ҳ���� X := 0 �� Y := 1}

    property Generator: TCnEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: TCnBigNumber read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientD: TCnBigNumber read FCoefficientD;
    {* ����ϵ�� B}
    property FiniteFieldSize: TCnBigNumber read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: TCnBigNumber read FOrder;
    {* ����Ľ��� N��ע����ֻ�� H Ϊ 1 ʱ�ŵ��ڱ����ߵ��ܵ���}
    property CoFactor: Integer read FCoFactor;
    {* �������� H��Ҳ�����ܵ��� = N * H������ Integer ��ʾ}
  end;

  TCnMontgomeryCurve = class
  {* �������ϵ��ɸ��������� By^2 = x^3 + Ax^2 + x������ B*(A^2 - 4) <> 0}
  private
    FCoefficientB: TCnBigNumber;
    FCoefficientA: TCnBigNumber;
    FOrder: TCnBigNumber;
    FFiniteFieldSize: TCnBigNumber;
    FGenerator: TCnEccPoint;
    FCoFactor: Integer;
  public
    constructor Create; overload; virtual;
    {* ��ͨ���캯����δ��ʼ������}
    constructor Create(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); overload;
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p��G �����ꡢG ��Ľ�������Ҫʮ�������ַ���}

    destructor Destroy; override;
    {* ��������}

    procedure Load(const A, B, FieldPrime, GX, GY, Order: AnsiString; H: Integer = 1); virtual;
    {* �������߲�����ע���ַ���������ʮ�����Ƹ�ʽ}

    procedure MultiplePoint(K: Int64; Point: TCnEccPoint); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P���ڲ�ʵ�ֵ�ͬ�� CnECC ��ͬ������}

    function PointAddPoint(P, Q, Sum: TCnEccPoint): Boolean;
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ
      �˴��ļӷ��ļ������������� Weierstrass ��Բ�����ϵ����߻����߽�����ȡ����ͬ����������Զ��(0, 0)}
    function PointSubPoint(P, Q, Diff: TCnEccPoint): Boolean;
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P��Ҳ���� Y ֵȡ��}
    function IsPointOnCurve(P: TCnEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    property Generator: TCnEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: TCnBigNumber read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: TCnBigNumber read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: TCnBigNumber read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: TCnBigNumber read FOrder;
    {* ����Ľ��� N��ע����ֻ�� H Ϊ 1 ʱ�ŵ��ڱ����ߵ��ܵ���}
    property CoFactor: Integer read FCoFactor;
    {* �������� H��Ҳ�����ܵ��� = N * H������ Integer ��ʾ}
  end;

// =============================================================================
//
//       Curve25519 �� x y �� Ed25519 �� u v ��˫��ӳ���ϵΪ��
//           (u, v) = ((1+y)/(1-y), sqrt(-486664)*u/x)
//           (x, y) = (sqrt(-486664)*u/v, (u-1)/(u+1))
//
// =============================================================================

  TCnCurve25519 = class(TCnMontgomeryCurve)
  {* rfc 7748/8032 �й涨�� Curve25519 ����}
  public
    constructor Create; override;
  end;

  TCnEd25519 = class(TCnTwistedEdwardsCurve)
  {* rfc 7748/8032 �й涨�� Ed25519 ����}
  public
    constructor Create; override;
  end;

implementation

const
  SCN_25519_PRIME = '7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED';
  // 2^255 - 19

  SCN_25519_COFACTOR = 8;
  // �����Ӿ�Ϊ 8��Ҳ������Բ�����ܵ����� G ������İ˱�

  SCN_25519_ORDER = '1000000000000000000000000000000014DEF9DEA2F79CD65812631A5CF5D3ED';
  // ���������Ϊ 2^252 + 27742317777372353535851937790883648493

  // 25519 Ť�����»����߲���
  SCN_25519_EDWARDS_A = '-01';
  // -1

  SCN_25519_EDWARDS_D = '52036CEE2B6FFE738CC740797779E89800700A4D4141D8AB75EB4DCA135978A3';
  // -121655/121656��Ҳ���� 121656 * D mod P = P - 121655 ��� D =
  // 37095705934669439343138083508754565189542113879843219016388785533085940283555

  SCN_25519_EDWARDS_GX = '216936D3CD6E53FEC0A4E231FDD6DC5C692CC7609525A7B2C9562D608F25D51A';
  // 15112221349535400772501151409588531511454012693041857206046113283949847762202

  SCN_25519_EDWARDS_GY = '6666666666666666666666666666666666666666666666666666666666666658';
  // 46316835694926478169428394003475163141307993866256225615783033603165251855960

  // 25519 �ɸ��������߲���
  SCN_25519_MONT_A = '076D06';
  // 486662

  SCN_25519_MONT_B = '01';
  // 1

  SCN_25519_MONT_GX = '09';
  // 9
  SCN_25519_MONT_GY = '20AE19A1B8A086B4E01EDD2C7748D14C923D4D7E6D7C61B229E9C5A27ECED3D9';
  // 4/5��Ҳ���� 5 * Y mod P = 4  y = 14781619447589544791020593568409986887264606134616475288964881837755586237401? �ƺ�����
  // ������ 46316835694926478169428394003475163141307993866256225615783033603165251855960 �Ŷԣ�

var
  F25519BigNumberPool: TCnBigNumberPool = nil;

{ TCnTwistedEdwardsCurve }

constructor TCnTwistedEdwardsCurve.Create(const A, D, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  Create;
  Load(A, D, FieldPrime, GX, GY, Order, H);
end;

constructor TCnTwistedEdwardsCurve.Create;
begin
  inherited;
  FCoefficientA := TCnBigNumber.Create;
  FCoefficientD := TCnBigNumber.Create;
  FOrder := TCnBigNumber.Create;
  FFiniteFieldSize := TCnBigNumber.Create;
  FGenerator := TCnEccPoint.Create;
  FCoFactor := 1;
end;

destructor TCnTwistedEdwardsCurve.Destroy;
begin
  FGenerator.Free;
  FFiniteFieldSize.Free;
  FOrder.Free;
  FCoefficientD.Free;
  FCoefficientA.Free;
  inherited;
end;

function TCnTwistedEdwardsCurve.IsNeutualPoint(P: TCnEccPoint): Boolean;
begin
  Result := P.X.IsZero and P.Y.IsOne;
end;

function TCnTwistedEdwardsCurve.IsPointOnCurve(P: TCnEccPoint): Boolean;
var
  X, Y, L, R: TCnBigNumber;
begin
  // �ж� au^2 + v^2 �Ƿ���� 1 + du^2v^2������ U �� X ���棬V �� Y ����
  Result := False;
  X := nil;
  Y := nil;
  L := nil;
  R := nil;

  try
    X := F25519BigNumberPool.Obtain;
    if BigNumberCopy(X, P.X) = nil then
      Exit;
    if not BigNumberDirectMulMod(X, X, X, FFiniteFieldSize) then
      Exit;

    Y := F25519BigNumberPool.Obtain;
    if BigNumberCopy(Y, P.Y) = nil then
      Exit;
    if not BigNumberDirectMulMod(Y, Y, Y, FFiniteFieldSize) then
      Exit;

    L := F25519BigNumberPool.Obtain;
    if not BigNumberDirectMulMod(L, FCoefficientA, X, FFiniteFieldSize) then
      Exit;
    if not BigNumberAddMod(L, L, Y, FFiniteFieldSize) then
      Exit; // ��ʱ L := A * X^2 + Y^2

    R := F25519BigNumberPool.Obtain;
    if not BigNumberDirectMulMod(R, X, Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(R, FCoefficientD, R, FFiniteFieldSize) then
      Exit;
    R.AddWord(1); // ��ʱ R := 1 + D * X^2 * Y^2

    Result := BigNumberEqual(L, R);
  finally
    F25519BigNumberPool.Recycle(R);
    F25519BigNumberPool.Recycle(L);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
  end;
end;

procedure TCnTwistedEdwardsCurve.Load(const A, D, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  FCoefficientA.SetHex(A);
  FCoefficientD.SetHex(D);
  FFiniteFieldSize.SetHex(FieldPrime);
  FGenerator.X.SetHex(GX);
  FGenerator.Y.SetHex(GY);
  FOrder.SetHex(Order);
  FCoFactor := H;
end;

procedure TCnTwistedEdwardsCurve.MultiplePoint(K: Int64;
  Point: TCnEccPoint);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    MultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnTwistedEdwardsCurve.MultiplePoint(K: TCnBigNumber;
  Point: TCnEccPoint);
var
  I: Integer;
  E, R: TCnEccPoint;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    PointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    SetNeutualPoint(Point);
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  R := nil;
  E := nil;

  try
    R := TCnEccPoint.Create;
    E := TCnEccPoint.Create;

    SetNeutualPoint(R); // R ������ʱĬ��Ϊ (0, 0)�����˴�����Ϊ���Ե� (0, 1)
    E.X := Point.X;
    E.Y := Point.Y;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        PointAddPoint(R, E, R);
      PointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
  finally
    E.Free;
    R.Free;
  end;
end;

function TCnTwistedEdwardsCurve.PointAddPoint(P, Q, Sum: TCnEccPoint): Boolean;
var
  X, Y, T, D1, D2, N1, N2: TCnBigNumber;
begin
//            x1 * y2 + x2 * y1                y1 * y2 - a * x1 * x2
//   x3 = --------------------------,   y3 = ---------------------------  �������迼�� P/Q �Ƿ�ͬһ��
//         1 + d * x1 * x2 * y1 * y2          1 - d * x1 * x2 * y1 * y2

  Result := False;

  X := nil;
  Y := nil;
  T := nil;
  D1 := nil;
  D2 := nil;
  N1 := nil;
  N2 := nil;

  try
    X := F25519BigNumberPool.Obtain;
    Y := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;
    D1 := F25519BigNumberPool.Obtain;
    D2 := F25519BigNumberPool.Obtain;
    N1 := F25519BigNumberPool.Obtain;
    N2 := F25519BigNumberPool.Obtain;

    if not BigNumberDirectMulMod(T, P.X, Q.Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(N1, Q.X, P.Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberAddMod(N1, N1, T, FFiniteFieldSize) then // N1 �õ� x1 * y2 + x2 * y1���ͷ� T
      Exit;

    if not BigNumberDirectMulMod(T, P.X, Q.X, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(T, T, FCoefficientA, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(N2, P.Y, Q.Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberSubMod(N2, N2, T, FFiniteFieldSize) then // N2 �õ� y1 * y2 - a * x1 * x2���ͷ� T
      Exit;

    if not BigNumberDirectMulMod(T, P.Y, Q.Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(T, T, Q.X, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(T, T, P.X, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(T, T, FCoefficientD, FFiniteFieldSize) then // T �õ� d * x1 * x2 * y1 * y2
      Exit;

    if not BigNumberAddMod(D1, T, CnBigNumberOne, FFiniteFieldSize) then // D1 �õ� 1 + d * x1 * x2 * y1 * y2
      Exit;
    if not BigNumberSubMod(D2, CnBigNumberOne, T, FFiniteFieldSize) then // D2 �õ� 1 - d * x1 * x2 * y1 * y2
      Exit;

    if not BigNumberModularInverse(T, D1, FFiniteFieldSize) then  // T �õ� D1 ��Ԫ
      Exit;
    if not BigNumberDirectMulMod(X, N1, T, FFiniteFieldSize) then // �õ� Sum.X
      Exit;

    if not BigNumberModularInverse(T, D2, FFiniteFieldSize) then  // T �õ� D2 ��Ԫ
      Exit;
    if not BigNumberDirectMulMod(Y, N2, T, FFiniteFieldSize) then // �õ� Sum.Y
      Exit;

    if BigNumberCopy(Sum.X, X) = nil then
      Exit;
    if BigNumberCopy(Sum.Y, Y) = nil then
      Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(N2);
    F25519BigNumberPool.Recycle(N1);
    F25519BigNumberPool.Recycle(D2);
    F25519BigNumberPool.Recycle(D1);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
  end;
end;

procedure TCnTwistedEdwardsCurve.PointInverse(P: TCnEccPoint);
begin
  if BigNumberIsNegative(P.X) or (BigNumberCompare(P.X, FFiniteFieldSize) >= 0) then
    raise ECnEccException.Create('Inverse Error.');

  BigNumberSub(P.X, FFiniteFieldSize, P.X);
end;

function TCnTwistedEdwardsCurve.PointSubPoint(P, Q, Diff: TCnEccPoint): Boolean;
var
  Inv: TCnEccPoint;
begin
  Inv := TCnEccPoint.Create;
  try
    Inv.Assign(Q);
    PointInverse(Inv);
    Result := PointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

procedure TCnTwistedEdwardsCurve.SetNeutualPoint(P: TCnEccPoint);
begin
  P.X.SetZero;
  P.Y.SetOne;
end;

{ TCnMontgomeryCurve }

constructor TCnMontgomeryCurve.Create(const A, B, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  Create;
  Load(A, B, FieldPrime, GX, GY, Order, H);
end;

constructor TCnMontgomeryCurve.Create;
begin
  inherited;
  FCoefficientA := TCnBigNumber.Create;
  FCoefficientB := TCnBigNumber.Create;
  FOrder := TCnBigNumber.Create;
  FFiniteFieldSize := TCnBigNumber.Create;
  FGenerator := TCnEccPoint.Create;
  FCoFactor := 1;
end;

destructor TCnMontgomeryCurve.Destroy;
begin
  FGenerator.Free;
  FFiniteFieldSize.Free;
  FOrder.Free;
  FCoefficientB.Free;
  FCoefficientA.Free;
  inherited;
end;

function TCnMontgomeryCurve.IsPointOnCurve(P: TCnEccPoint): Boolean;
var
  X, Y, T: TCnBigNumber;
begin
  // �ж� B*y^2 �Ƿ���� x^3 + A*x^2 + x mod P
  Result := False;
  X := nil;
  Y := nil;
  T := nil;

  try
    X := F25519BigNumberPool.Obtain;
    if BigNumberCopy(X, P.X) = nil then
      Exit;

    Y := F25519BigNumberPool.Obtain;
    if BigNumberCopy(Y, P.Y) = nil then
      Exit;

    if not BigNumberDirectMulMod(Y, Y, Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(Y, FCoefficientB, Y, FFiniteFieldSize) then  // Y := B * y^2 mod P
      Exit;

    T := F25519BigNumberPool.Obtain;
    if not BigNumberDirectMulMod(T, FCoefficientA, X, FFiniteFieldSize) then
      Exit;  // T := A*X

    T.AddWord(1); // T := A*X + 1
    if not BigNumberDirectMulMod(T, X, T, FFiniteFieldSize) then
      Exit;       // T := X * (A*X + 1) = AX^2 + X

    if not BigNumberPowerWordMod(X, X, 3, FFiniteFieldSize) then  // X^3
      Exit;

    if not BigNumberAddMod(X, X, T, FFiniteFieldSize) then // X := x^3 + Ax^2 + x mod P
      Exit;

    Result := BigNumberEqual(X, Y);
  finally
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
    F25519BigNumberPool.Recycle(T);
  end;
end;

procedure TCnMontgomeryCurve.Load(const A, B, FieldPrime, GX, GY,
  Order: AnsiString; H: Integer);
begin
  FCoefficientA.SetHex(A);
  FCoefficientB.SetHex(B);
  FFiniteFieldSize.SetHex(FieldPrime);
  FGenerator.X.SetHex(GX);
  FGenerator.Y.SetHex(GY);
  FOrder.SetHex(Order);
  FCoFactor := H;
end;

procedure TCnMontgomeryCurve.MultiplePoint(K: Int64; Point: TCnEccPoint);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    MultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnMontgomeryCurve.MultiplePoint(K: TCnBigNumber;
  Point: TCnEccPoint);
var
  I: Integer;
  E, R: TCnEccPoint;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    PointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    Point.SetZero;
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  R := nil;
  E := nil;

  try
    R := TCnEccPoint.Create;
    E := TCnEccPoint.Create;

    // R ������ʱĬ��Ϊ����Զ��
    E.X := Point.X;
    E.Y := Point.Y;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        PointAddPoint(R, E, R);
      PointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
  finally
    E.Free;
    R.Free;
  end;
end;

function TCnMontgomeryCurve.PointAddPoint(P, Q, Sum: TCnEccPoint): Boolean;
var
  K, X, Y, T, SX, SY: TCnBigNumber;
begin
  // �ȼ���б�ʣ������� X ���Ȼ����ʱ��б�ʷֱ�Ϊ
  //          (y2 - y1)^2          (3*x1^2 + 2*A*x1 + 1)^2
  // б�� K = ------------  �� =  -------------------------
  //          (x2 - x1)^2                (2*y1)^2
  //
  // x3 = K^2 - A - x1 - x2
  // y3 = -(y1 + K * (x3 - x1))
  Result := True;
  K := nil;
  X := nil;
  Y := nil;
  T := nil;
  SX := nil;
  SY := nil;

  try
    if P.IsZero then
    begin
      Sum.Assign(Q);
      Exit;
    end
    else if Q.IsZero then
    begin
      Sum.Assign(P);
      Exit;
    end;

    K := F25519BigNumberPool.Obtain;
    X := F25519BigNumberPool.Obtain;
    Y := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;
    SX := F25519BigNumberPool.Obtain;
    SY := F25519BigNumberPool.Obtain;

    if (BigNumberCompare(P.X, Q.X) = 0) and (BigNumberCompare(P.Y, Q.Y) = 0) then
    begin
      if P.Y.IsZero then
      begin
        Sum.SetZero;
        Exit;
      end;

      // ͬһ���㣬������б��
      if not BigNumberSubMod(Y, Q.Y, P.Y, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(Y, Y, Y, FFiniteFieldSize) then // �õ����� (y2 - y1)^2
        Exit;
      if not BigNumberSubMod(X, Q.X, P.X, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(X, X, X, FFiniteFieldSize) then // �õ���ĸ (x2 - x1)^2
        Exit;
      if not BigNumberModularInverse(T, X, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(K, Y, T, FFiniteFieldSize) then // K �õ�����б��
        Exit;
    end
    else
    begin
      if BigNumberCompare(P.X, Q.X) = 0 then // ��� X ��ȣ�Ҫ�ж� Y �ǲ��ǻ����������Ϊ 0�����������
      begin
        BigNumberAdd(T, P.Y, Q.Y);
        if BigNumberCompare(T, FFiniteFieldSize) = 0 then  // ��������Ϊ 0
          Sum.SetZero
        else                                               // ������������
          raise ECnEccException.CreateFmt('Can NOT Calucate %s,%s + %s,%s',
            [P.X.ToDec, P.Y.ToDec, Q.X.ToDec, Q.Y.ToDec]);

        Exit;
      end;

      // ��������б��
      // ������ (3*x1^2 + 2*A*x1 + 1)^2
      if not BigNumberDirectMulMod(Y, FCoefficientA, P.X, FFiniteFieldSize) then
        Exit;
      if not BigNumberAddMod(Y, Y, Y, FFiniteFieldSize) then
        Exit;
      Y.AddWord(1); // Y �õ� 2*A*x1 + 1

      if not BigNumberDirectMulMod(T, P.X, P.X, FFiniteFieldSize) then
        Exit;
      T.MulWord(3);
      if not BigNumberAddMod(Y, T, Y, FFiniteFieldSize) then // Y �õ� 3*x1^2 + 2*A*x1 + 1���ͷ� T
        Exit;

      if not BigNumberDirectMulMod(Y, Y, Y, FFiniteFieldSize) then // Y ��ƽ��
        Exit;

      if not BigNumberAddMod(X, P.Y, P.Y, FFiniteFieldSize) then  // 2Y
        Exit;
      if not BigNumberDirectMulMod(X, X, X, FFiniteFieldSize) then // 4Y^2
        Exit;
      if not BigNumberModularInverse(T, X, FFiniteFieldSize) then // �õ���ĸ (2*y1)^2
        Exit;

      if not BigNumberDirectMulMod(K, Y, T, FFiniteFieldSize) then // K �õ�����б��
        Exit;
    end;

    // x3 = K^2 - A - x1 - x2
    if not BigNumberDirectMulMod(SX, K, K, FFiniteFieldSize) then
      Exit;
    if not BigNumberSubMod(SX, SX, FCoefficientA, FFiniteFieldSize) then
      Exit;
    if not BigNumberSubMod(SX, SX, P.X, FFiniteFieldSize) then
      Exit;
    if not BigNumberSubMod(SX, SX, Q.X, FFiniteFieldSize) then
      Exit;

    // y3 = -(y1 + K * (x3 - x1))
    if not BigNumberSubMod(SY, SX, P.X, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(SY, SY, K, FFiniteFieldSize) then
      Exit;
    if not BigNumberAddMod(SY, SY, P.Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberSub(SY, FFiniteFieldSize, SY) then
      Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(SY);
    F25519BigNumberPool.Recycle(SX);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(X);
    F25519BigNumberPool.Recycle(K);
  end;
end;

procedure TCnMontgomeryCurve.PointInverse(P: TCnEccPoint);
begin
  if BigNumberIsNegative(P.Y) or (BigNumberCompare(P.Y, FFiniteFieldSize) >= 0) then
    raise ECnEccException.Create('Inverse Error.');

  BigNumberSub(P.Y, FFiniteFieldSize, P.Y);
end;

function TCnMontgomeryCurve.PointSubPoint(P, Q, Diff: TCnEccPoint): Boolean;
var
  Inv: TCnEccPoint;
begin
  Inv := TCnEccPoint.Create;
  try
    Inv.Assign(Q);
    PointInverse(Inv);
    Result := PointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

{ TCnCurve25519 }

constructor TCnCurve25519.Create;
begin
  inherited;
  Load(SCN_25519_MONT_A, SCN_25519_MONT_B, SCN_25519_PRIME, SCN_25519_MONT_GX,
    SCN_25519_MONT_GY, SCN_25519_ORDER, 8);
end;

{ TCnEd25519 }

constructor TCnEd25519.Create;
begin
  inherited;
  Load(SCN_25519_EDWARDS_A, SCN_25519_EDWARDS_D, SCN_25519_PRIME, SCN_25519_EDWARDS_GX,
    SCN_25519_EDWARDS_GY, SCN_25519_ORDER, 8);
end;

initialization
  F25519BigNumberPool := TCnBigNumberPool.Create;

finalization
  F25519BigNumberPool.Free;

end.
