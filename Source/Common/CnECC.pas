{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2018 CnPack ������                       }
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

unit CnECC;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ���Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��Ŀǰֻʵ�� Int64 ��Χ������ y^2 = x^3 + Ax + B mod p ������Բ���ߵļ��㡣
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2018.09.08 V1.1
*               �ܹ�����ϵ����С����Բ���߲���
*           2018.09.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNativeDecl, CnPrimeNumber;

type
  ECnEccException = class(Exception);

  TCnInt64EccPoint = packed record
  {* Int64 ��Χ�ڵ���Բ���ߵĻ��������ṹ}
    X: Int64;
    Y: Int64;
  end;

  TCnInt64PublicKey = TCnInt64EccPoint;
  {* Int64 ��Χ�ڵ���Բ���ߵĹ�Կ��G ����� k �κ�ĵ�����}

  TCnInt64PrivateKey = Int64;
  {* Int64 ��Χ�ڵ���Բ���ߵ�˽Կ��������� k ��}

  TCnInt64Ecc = class
  {* ����һ������ p Ҳ���� 0 �� p - 1 �ϵ���Բ���� y^2 = x^3 + Ax + B mod p���������� Int64 ��Χ��}
  private
    FGenerator: TCnInt64EccPoint;
    FCoefficientA: Int64;
    FCoefficientB: Int64;
    FFiniteFieldSize: Int64;
    FOrder: Int64;
  protected

  public
    constructor Create(A, B, FieldPrime, GX, GY, Order: Int64);
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p��G �����ꡢG ��Ľ���}
    destructor Destroy; override;
    {* ��������}

    procedure MultiplePoint(K: Int64; var Point: TCnInt64EccPoint);
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure PointAddPoint(var P, Q, Sum: TCnInt64EccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointSubPoint(var P, Q, Diff: TCnInt64EccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(var P: TCnInt64EccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P}
    function IsPointOnCurve(var P: TCnInt64EccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function PlainToPoint(Plain: Int64; var OutPoint: TCnInt64EccPoint): Boolean;
    {* ��Ҫ���ܵ�������ֵ��װ��һ�������ܵĵ�}

    procedure GenerateKeys(out PrivateKey: TCnInt64PrivateKey; out PublicKey: TCnInt64PublicKey);
    {* ����һ�Ը���Բ���ߵĹ�˽Կ��˽Կ��������� k����Կ�ǻ��� G ���� k �γ˷���õ��ĵ����� K}
    procedure Encrypt(var PlainPoint: TCnInt64EccPoint; PublicKey: TCnInt64PublicKey;
      var OutDataPoint1, OutDataPoint2: TCnInt64EccPoint; RandomKey: Int64 = 0);
    {* ��Կ�������ĵ� M���õ��������������ģ��ڲ����������ֵ r��Ҳ���� C1 = M + rK; C2 = r * G
      �������� RandomKey �� 0�����ڲ��������}
    procedure Decrypt(var DataPoint1, DataPoint2: TCnInt64EccPoint;
      PrivateKey: TCnInt64PrivateKey; var OutPlainPoint: TCnInt64EccPoint);
    {* ˽Կ�������ĵ㣬Ҳ���Ǽ��� C1 - k * C2 �͵õ���ԭ�ĵ� M}

    property Generator: TCnInt64EccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: Int64 read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: Int64 read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: Int64 read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: Int64 read FOrder;
    {* ����Ľ���}
  end;

function CnInt64EccPointToString(var P: TCnInt64EccPoint): string;
{* ��һ�� TCnInt64EccPoint ������ת��Ϊ�ַ���}

function CnInt64EccGenerateParams(var FiniteFieldSize, CoefficientA, CoefficientB,
  GX, GY, Order: Int64): Boolean;
{* ������Բ���� y^2 = x^3 + Ax + B mod p �ĸ�����������������ʵ�֣�ֻ��������ϵ����С��}

function CnInt64EccDiffieHellmanGenerateOutKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  out PublicKey: TCnInt64PublicKey): Boolean;
{* ��������ѡ�������� PrivateKey ���� ECDH ��ԿЭ�̵������Կ��
   ���� OutPublicKey = SelfPrivateKey * G}

function CnInt64EccDiffieHellmanCalucateKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  var OtherPublicKey: TCnInt64PublicKey; var SecretKey: TCnInt64PublicKey): Boolean;
{* ���ݶԷ����͵� ECDH ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ��
   ���� SecretKey = SelfPrivateKey * OtherPublicKey}

implementation

// ��һ�� TCnInt64EccPoint ������ת��Ϊ�ַ���
function CnInt64EccPointToString(var P: TCnInt64EccPoint): string;
begin
  Result := Format('%d,%d', [P.X, P.Y]);
end;

// ������Բ���� y^2 = x^3 + Ax + B mod p �ĸ�������������ʵ��
function CnInt64EccGenerateParams(var FiniteFieldSize, CoefficientA, CoefficientB,
  GX, GY, Order: Int64): Boolean;
var
  I, J: Integer;
  N: Int64;
  P: TCnInt64EccPoint;
  Ecc64: TCnInt64Ecc;
begin
  // ���裺���ѡ���������� p��������� a��b���� SEA �㷨��������ߵĽ� N
  // �ж� N �Ǵ���������һ�������֮һ�Ǵ�������Ȼ�������������Ϊѭ����Ⱥ�Ľ� n
  // �ٸ��� n Ѱ�һ��� G �����ꡣ��� n �͵��� N ������������� G ���ѡ���С�
  // raise ECnEccException.Create('NOT Implemented.');

  repeat
    // FiniteFieldSize := CnGenerateUInt32Prime;
    Randomize;
    I := Trunc(Random * ((High(CN_PRIME_NUMBERS_SQRT_UINT32) div 32) - 100)) + 100;
    FiniteFieldSize := CN_PRIME_NUMBERS_SQRT_UINT32[I];
    CoefficientA := Trunc(Random * 16);
    CoefficientB := Trunc(Random * 256);
    N := 1; // 0,0 ��Ȼ����

    if (4 * CoefficientA * CoefficientA * CoefficientA - 27 * CoefficientB * CoefficientB)
      mod FiniteFieldSize = 0 then
      Continue;

    GX := 0;
    GY := 0;

    // ���������Բ���ߵĽף����� SEA��ֻ������������ٷ�
    Ecc64 := TCnInt64Ecc.Create(CoefficientA, CoefficientB, FiniteFieldSize, 0, 0, FiniteFieldSize);
    for I := 0 to FiniteFieldSize - 1 do
    begin
      for J := 0 to FiniteFieldSize - 1 do
      begin
        P.X := I;
        P.Y := J;
        if Ecc64.IsPointOnCurve(P) then
        begin
          Inc(N);
          if (GX = 0) or (GY = 0) then // ��һ������ľ͵�������
          begin
            GX := P.X;
            GY := P.Y;
          end;
        end;
      end;
    end;

    // N Ϊ������Բ���ߵĽ�
  until CnInt64IsPrime(N);

  Order := N;
  Result := True;
end;

// ��λȷ�������ټ���������ƽ�������������֣�����Ǹ�������ȡ��
function FastSqrt64(N: Int64): Int64;
var
  T, B: Int64;
  Sft: Int64;
begin
  Result := 0;
  if N < 0 then N := -N;

  B := $80000000;
  Sft := 31;
  repeat
    T := ((Result shl 1)+ B) shl Sft;
    Dec(Sft);
    if N >= T then
    begin
      Result := Result + B;
      N := N - T;
    end;
    B := B shr 1;
  until B = 0;
end;

// ֧�� A��B Ϊ�����ĳ˻�ȡģ���� C ��Ҫ������������������
function Int64MultipleMod(A, B, C: Int64): Int64;
begin
  if (A > 0) and (B > 0) then
    Result := MultipleMod(A, B, C)
  else if (A < 0) and (B < 0) then
    Result := MultipleMod(-A, -B, C)
  else if (A > 0) and (B < 0) then
    Result := C - MultipleMod(A, -B, C)
  else if (A < 0) and (B > 0) then
    Result := C - MultipleMod(-A, B, C)
  else
    Result := 0;
end;

// �� X ��� M ��ģ��Ԫ��Ҳ����ģ��Ԫ Y������ (X * Y) mod M = 1����ΧΪ Int64��Ҳ����˵֧�� X Ϊ��ֵ
function Int64ModularInverse(X: Int64; Modulus: Int64): Int64;
var
  Neg: Boolean;
begin
  Neg := False;
  if X < 0 then
  begin
    X := -X;
    Neg := True;
  end;

  // ������ģ��Ԫ������������ģ��Ԫ�ĸ�ֵ����ֵ�������ټ� Modulus
  Result := CnInt64ModularInverse(X, Modulus);
  if Neg and (Result > 0) then
  begin
    Result := -Result;
    if Result < 0 then
      Result := Result + Modulus;
  end;
end;

{ TCnInt64Ecc }

constructor TCnInt64Ecc.Create(A, B, FieldPrime, GX, GY, Order: Int64);
begin
  inherited Create;
  if not CnInt64IsPrime(FieldPrime) or not CnInt64IsPrime(Order) then
    raise ECnEccException.Create('Infinite Field and Order must be a Prime Number.');

  if not (GX >= 0) and (GX < FieldPrime) or
    not (GY >= 0) and (GY < FieldPrime) then
    raise ECnEccException.Create('Generator Point must be in Infinite Field.');

  FCoefficientA := A;
  FCoefficientB := B;
  FFiniteFieldSize := FieldPrime;
  FGenerator.X := GX;
  FGenerator.Y := GY;
  FOrder := Order;
end;

procedure TCnInt64Ecc.Decrypt(var DataPoint1, DataPoint2: TCnInt64EccPoint;
  PrivateKey: TCnInt64PrivateKey; var OutPlainPoint: TCnInt64EccPoint);
var
  P: TCnInt64EccPoint;
begin
  P := DataPoint2;
  MultiplePoint(PrivateKey, P);
  PointSubPoint(DataPoint1, P, OutPlainPoint);
end;

destructor TCnInt64Ecc.Destroy;
begin

  inherited;
end;

procedure TCnInt64Ecc.Encrypt(var PlainPoint: TCnInt64EccPoint;
  PublicKey: TCnInt64PublicKey; var OutDataPoint1,
  OutDataPoint2: TCnInt64EccPoint; RandomKey: Int64);
begin
  if RandomKey = 0 then
  begin
    Randomize;
    RandomKey := Trunc(Random * (FOrder - 1)) + 1; // �� 0 �󵫱Ȼ����С�������
  end;

  if RandomKey mod FOrder = 0 then
    raise ECnEccException.CreateFmt('Error RandomKey %d for Order.', [RandomKey]);

  // M + rK;
  OutDataPoint1 := PublicKey;
  MultiplePoint(RandomKey, OutDataPoint1);
  PointAddPoint(PlainPoint, OutDataPoint1, OutDataPoint1);

  // r * G
  OutDataPoint2 := FGenerator;
  MultiplePoint(RandomKey, OutDataPoint2);
end;

procedure TCnInt64Ecc.GenerateKeys(out PrivateKey: TCnInt64PrivateKey;
  out PublicKey: TCnInt64PublicKey);
begin
  Randomize;
  PrivateKey := Trunc(Random * (FOrder - 1)) + 1; // �� 0 �󵫱Ȼ����С�������
  PublicKey := FGenerator;
  MultiplePoint(PrivateKey, PublicKey);           // ����� PrivateKey ��
end;

function TCnInt64Ecc.IsPointOnCurve(var P: TCnInt64EccPoint): Boolean;
var
  Y2, X3, AX, B: Int64;
begin
  // ���� (Y^2 - X^3 - A*X - B) mod p �Ƿ���� 0��Ӧ�÷�����
  // Ҳ���Ǽ���(Y^2 mod p - X^3 mod p - A*X mod p - B mod p) mod p
  Y2 := MontgomeryPowerMod(P.Y, 2, FFiniteFieldSize);
  X3 := MontgomeryPowerMod(P.X, 3, FFiniteFieldSize);
  AX := Int64MultipleMod(CoefficientA, P.X, FFiniteFieldSize);
  B := CoefficientB mod FFiniteFieldSize;

  Result := ((Y2 - X3 - AX - B) mod FFiniteFieldSize) = 0;
end;

procedure TCnInt64Ecc.MultiplePoint(K: Int64; var Point: TCnInt64EccPoint);
var
  E, R: TCnInt64EccPoint;
begin
  if K < 0 then
  begin
    K := -K;
    PointInverse(Point);
  end;

  if K = 0 then
  begin
    Point.X := 0;
    Point.Y := 0;
    Exit;
  end;

  R.X := 0;
  R.Y := 0;
  E := Point;

  while K <> 0 do
  begin
    if (K and 1) <> 0 then
      PointAddPoint(R, E, R);

    PointAddPoint(E, E, E);
    K := K shr 1;
  end;

  Point := R;
end;

function TCnInt64Ecc.PlainToPoint(Plain: Int64;
  var OutPoint: TCnInt64EccPoint): Boolean;
var
  Y2, X3, AX, B, Y: Int64;
begin
  // �ⷽ���� Y�� (y^2 - (Plain^3 + A * Plain + B)) mod p = 0
  // ע�� Plain ���̫�󣬼�������л���������ô���ֻ���÷����ɡ�
  // (Y^2 mod p - Plain ^ 3 mod p - A * Plain mod p - B mod p) mod p = 0;
  X3 := MontgomeryPowerMod(Plain, 3, FFiniteFieldSize);
  AX := Int64MultipleMod(CoefficientA, Plain, FFiniteFieldSize);
  B := CoefficientB mod FFiniteFieldSize;

  B := X3 + Ax + B; // ���������Ļ�

  // ��Ϊ Y^2 = N * p + B Ҫ���ҳ� N ���ұ�Ϊ��ȫƽ���������� Y ����ֵ
  // ֻ�� N �� 0 ��ʼ�� 1 ���������������Ƿ���ȫƽ����

  Y2 := B;
  while True do
  begin
    if Y2 > 0 then
    begin
      Y := FastSqrt64(Y2);
      if Y * Y = Y2 then
      begin
        // Y2 ����ȫƽ����
        OutPoint.X := Plain;
        OutPoint.Y := Y;
        Result := True;
        Exit;
      end;
    end;
    Inc(Y2, FFiniteFieldSize);
  end;
  Result := False;
end;

procedure TCnInt64Ecc.PointAddPoint(var P, Q, Sum: TCnInt64EccPoint);
var
  K, X, Y, PX: Int64;
begin
  K := 0;
  if (P.X = 0) and (P.Y = 0) then
  begin
    Sum := Q;
    Exit;
  end
  else if (Q.X = 0) and (Q.Y = 0) then
  begin
    Sum := P;
    Exit;
  end
  else if (P.X = Q.X) and (P.Y = Q.Y) then
  begin
    // ��������ͬһ���㣬����б��Ϊ�����󵼣�3 * X^2 + A / (2 * Y) ���� Y = 0 ��ֱ��������Զ 0��
    X := 3 * P.X * P.X + CoefficientA;
    Y := 2 * P.Y;

    if Y = 0 then
    begin
      Sum.X := 0;
      Sum.Y := 0;
    end;

    Y := Int64ModularInverse(Y, FFiniteFieldSize);
    K := Int64MultipleMod(X, Y, FFiniteFieldSize); // �õ�б��
  end
  else if (P.X = Q.X) and ((P.Y = -Q.Y) or (P.Y + Q.Y = FFiniteFieldSize)) then        // P = -Q
  begin
    Sum.X := 0;
    Sum.Y := 0;
    Exit;
  end
  else if P.X <> Q.X then
  begin
    // б�� K := ((Q.Y - P.Y) / (Q.X - P.X)) mod p
    Y := Q.Y - P.Y;
    X := Q.X - P.X;

    // Y/X = Y*X^-1 = Y * (X ��� p ����Ԫ)
    X := Int64ModularInverse(X, FFiniteFieldSize);
    K := Int64MultipleMod(Y, X, FFiniteFieldSize); // �õ�б��
  end
  else if P.Y <> Q.Y then
  begin
    // P��Q ���� X ��ͬ��Y ��ͬ���ֲ�����Ԫ���������ӣ������ϲ������
    raise ECnEccException.CreateFmt('Can NOT Calucate %d,%d + %d,%d', [P.X, P.Y, Q.X, Q.Y]);
  end;

  // Xsum = (K^2 - X1 - X2) mod p
  X := K * K - P.X - Q.X;
  while X < 0 do
    X := X + FFiniteFieldSize;
  PX := P.X; // ��� Sum �� P ��ͬһ����Ҫ���� P.X �������������ȴ��� P.X
  Sum.X := X mod FFiniteFieldSize;

  // Ysum = (K * (X1 - Xsum) - Y1) mod p  ע��Ҫȡ��
  //   Ҳ = (K * (X2 - Xsum) - Y2) mod p  ע��Ҫȡ��
  X := PX - Sum.X;
  Y := K * X - P.Y;
  while Y < 0 do
    Y := Y + FFiniteFieldSize;
  Sum.Y := Y mod FFiniteFieldSize;
end;

procedure TCnInt64Ecc.PointInverse(var P: TCnInt64EccPoint);
begin
  // P.Y := -P.Y mod p ע������ĸ�ֵȡģ������ Delphi ��ȡ����ȡģ�ٱ为
  P.Y := FFiniteFieldSize - (P.Y mod FFiniteFieldSize);
end;

procedure TCnInt64Ecc.PointSubPoint(var P, Q, Diff: TCnInt64EccPoint);
var
  Inv: TCnInt64EccPoint;
begin
  Inv.X := Q.X;
  Inv.Y := Q.Y;
  PointInverse(Inv);
  PointAddPoint(P, Inv, Diff);
end;

// ��������ѡ�������� PrivateKey ���� ECDH ��ԿЭ�̵������Կ��
function CnInt64EccDiffieHellmanGenerateOutKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  out PublicKey: TCnInt64PublicKey): Boolean;
begin
  // OutPublicKey = SelfPrivateKey * G
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey > 0) then
  begin
    PublicKey := Ecc.Generator;
    Ecc.MultiplePoint(SelfPrivateKey, PublicKey);
    Result := True;
  end;
end;

// ���ݶԷ����͵� ECDH ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ��
function CnInt64EccDiffieHellmanCalucateKey(Ecc: TCnInt64Ecc; SelfPrivateKey: TCnInt64PrivateKey;
  var OtherPublicKey: TCnInt64PublicKey; var SecretKey: TCnInt64PublicKey): Boolean;
begin
  // SecretKey = SelfPrivateKey * OtherPublicKey
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey > 0) then
  begin
    SecretKey := OtherPublicKey;
    Ecc.MultiplePoint(SelfPrivateKey, SecretKey);
    Result := True;
  end;
end;

end.
