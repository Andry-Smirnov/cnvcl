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
* �޸ļ�¼��2018.09.13 V1.2
*               ����ʵ�ִ�����Բ���ߵļӽ��ܹ��ܣ�֧�� SM2 �Լ� Secp256k1 ����
*           2018.09.10 V1.1
*               �ܹ�����ϵ����С����Բ���߲���
*           2018.09.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, CnNativeDecl, CnPrimeNumber, CnBigNumber;

type
  ECnEccException = class(Exception);

  TCnInt64EccPoint = packed record
  {* Int64 ��Χ�ڵ���Բ�����ϵĵ������ṹ}
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

  TCnEccPoint = class(TPersistent)
  {* ��Բ�����ϵĵ�������}
  private
    FY: TCnBigNumber;
    FX: TCnBigNumber;
    procedure SetX(const Value: TCnBigNumber);
    procedure SetY(const Value: TCnBigNumber);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function IsZero: Boolean;
    procedure SetZero;

    property X: TCnBigNumber read FX write SetX;
    property Y: TCnBigNumber read FY write SetY;
  end;

  TCnEccPublicKey = TCnEccPoint;
  {* ��Բ���ߵĹ�Կ��G ����� k �κ�ĵ�����}

  TCnEccPrivateKey = TCnBigNumber;
  {* ��Բ���ߵ�˽Կ��������� k ��}

  TCnEccPredefinedCurveType = (ctCustomized, ctSM2, ctSecp256k1);
  {* ֧�ֵ���Բ��������}

  TCnEcc = class
  {* ����һ������ p Ҳ���� 0 �� p - 1 �ϵ���Բ���� y^2 = x^3 + Ax + B mod p}
  private
    FCoefficientB: TCnBigNumber;
    FCoefficientA: TCnBigNumber;
    FOrder: TCnBigNumber;
    FFiniteFieldSize: TCnBigNumber;
    FGenerator: TCnEccPoint;
    FBigNumberPool: TObjectList;
    function ObtainBigNumberFromPool: TCnBigNumber;
    procedure RecycleBigNumberToPool(Num: TCnBigNumber);
    function GetBitsCount: Integer;
  public
    constructor Create; overload;
    constructor Create(Predefined: TCnEccPredefinedCurveType); overload;
    constructor Create(const A, B, FieldPrime, GX, GY, Order: AnsiString); overload;
    {* ���캯�������뷽�̵� A, B �������������Ͻ� p��G �����ꡢG ��Ľ�������Ҫʮ�������ַ���}
    destructor Destroy; override;
    {* ��������}

    procedure Load(Predefined: TCnEccPredefinedCurveType); overload;
    procedure Load(const A, B, FieldPrime, GX, GY, Order: AnsiString); overload;
    {* �������߲���}

    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure PointAddPoint(P, Q, Sum: TCnEccPoint);
    {* ���� P + Q��ֵ���� Sum �У�Sum ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointSubPoint(P, Q, Diff: TCnEccPoint);
    {* ���� P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure PointInverse(P: TCnEccPoint);
    {* ���� P �����Ԫ -P��ֵ���·��� P}
    function IsPointOnCurve(P: TCnEccPoint): Boolean;
    {* �ж� P ���Ƿ��ڱ�������}

    function PlainToPoint(Plain: TCnBigNumber; OutPoint: TCnEccPoint): Boolean;
    {* ��Ҫ���ܵ�������ֵ��װ��һ�������ܵĵ㣬���������Ƽ�}
    function PointToPlain(Point: TCnEccPoint; OutPlain: TCnBigNumber): Boolean;
    {* �����ܳ������ĵ�⿪��һ��������ֵ}

    procedure GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey);
    {* ����һ�Ը���Բ���ߵĹ�˽Կ��˽Կ��������� k����Կ�ǻ��� G ���� k �γ˷���õ��ĵ����� K}
    procedure Encrypt(PlainPoint: TCnEccPoint; PublicKey: TCnEccPublicKey;
      OutDataPoint1, OutDataPoint2: TCnEccPoint);
    {* ��Կ�������ĵ� M���õ��������������ģ��ڲ����������ֵ r��Ҳ���� C1 = M + rK; C2 = r * G}
    procedure Decrypt(DataPoint1, DataPoint2: TCnEccPoint;
      PrivateKey: TCnEccPrivateKey; OutPlainPoint: TCnEccPoint);
    {* ˽Կ�������ĵ㣬Ҳ���Ǽ��� C1 - k * C2 �͵õ���ԭ�ĵ� M}

    property Generator: TCnEccPoint read FGenerator;
    {* �������� G}
    property CoefficientA: TCnBigNumber read FCoefficientA;
    {* ����ϵ�� A}
    property CoefficientB: TCnBigNumber read FCoefficientB;
    {* ����ϵ�� B}
    property FiniteFieldSize: TCnBigNumber read FFiniteFieldSize;
    {* ��������Ͻ磬���� p}
    property Order: TCnBigNumber read FOrder;
    {* ����Ľ���}
    property BitsCount: Integer read GetBitsCount;
    {* ����Բ���ߵ�������λ��}
  end;

function CnInt64EccPointToString(var P: TCnInt64EccPoint): string;
{* ��һ�� TCnInt64EccPoint ������ת��Ϊ�ַ���}

function CnEccPointToString(const P: TCnEccPoint): string;
{* ��һ�� TCnEccPoint ������ת��Ϊ�ַ���}

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

function CnEccPointsEqual(P1, P2: TCnEccPoint): Boolean;
{* �ж��������Ƿ����}

function CnEccDiffieHellmanGenerateOutKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey): Boolean;
{* ��������ѡ�������� PrivateKey ���� ECDH ��ԿЭ�̵������Կ��
   ���� PublicKey = SelfPrivateKey * G}

function CnEccDiffieHellmanCalucateKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  OtherPublicKey: TCnEccPublicKey; SecretKey: TCnEccPublicKey): Boolean;
{* ���ݶԷ����͵� ECDH ��ԿЭ�̵������Կ�������ɹ��ϵ���Կ��
   ���� SecretKey = SelfPrivateKey * OtherPublicKey}

implementation

const
  CN_ECC_PLAIN_DATA_BITS_GAP = 16;

type
  TCnEccPredefinedHexParams = packed record
    P: AnsiString;
    A: AnsiString;
    B: AnsiString;
    GX: AnsiString;
    GY: AnsiString;
    N: AnsiString;
    H: AnsiString;
  end;

const
  ECC_PRE_DEFINED_PARAMS: array[TCnEccPredefinedCurveType] of TCnEccPredefinedHexParams = (
    (P: ''; A: ''; B: ''; GX: ''; GY: ''; N: ''; H: ''),
    ( // SM2
      P: 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFF';
      A: 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC';
      B: '28E9FA9E9D9F5E344D5A9E4BCF6509A7F39789F515AB8F92DDBCBD414D940E93';
      GX: '32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7';
      GY: 'BC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0';
      N: 'FFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFF7203DF6B21C6052B53BBF40939D54123';
      H: '01'
    ),
    ( // secp256k1
      P: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F';
      A: '00';
      B: '07';
      GX: '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798';
      GY: '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8';
      N: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141';
      H: '01'
    )
  );

// ��һ�� TCnInt64EccPoint ������ת��Ϊ�ַ���
function CnInt64EccPointToString(var P: TCnInt64EccPoint): string;
begin
  Result := Format('%d,%d', [P.X, P.Y]);
end;

// ��һ�� TCnEccPoint ������ת��Ϊ�ַ���
function CnEccPointToString(const P: TCnEccPoint): string;
begin
  Result := Format('%s,%s', [P.X.ToDec, P.Y.ToDec]);
end;

// �ж��������Ƿ����
function CnEccPointsEqual(P1, P2: TCnEccPoint): Boolean;
begin
  if P1 = P2 then
  begin
    Result := True;
    Exit;
  end;
  Result := (BigNumberCompare(P1.X, P2.X) = 0) and (BigNumberCompare(P1.Y, P2.Y) = 0);
end;

// �������õ·��� ( A / P) ��ֵ
function CalcInt64Legendre(A, P: Int64): Integer;
begin
  // ���������P ������ A ʱ���� 0����������ʱ����� A ����ȫƽ�����ͷ��� 1�����򷵻� -1
  if A mod P = 0 then
    Result := 0
  else if MontgomeryPowerMod(A, (P - 1) shr 1, P) = 1 then // ŷ���б�
    Result := 1
  else
    Result := -1;
end;

// ������Բ���� y^2 = x^3 + Ax + B mod p �ĸ�������������ʵ��
function CnInt64EccGenerateParams(var FiniteFieldSize, CoefficientA, CoefficientB,
  GX, GY, Order: Int64): Boolean;
var
  I: Integer;
  N: Int64;
  P: TCnInt64EccPoint;
  Ecc64: TCnInt64Ecc;
begin
  // ���裺���ѡ���������� p��������� a��b���� SEA �㷨��������ߵĽ� N
  // �ж� N �Ǵ���������һ�������֮һ�Ǵ�������Ȼ�������������Ϊѭ����Ⱥ�Ľ� n
  // �ٸ��� n Ѱ�һ��� G �����ꡣ��� n �͵��� N ������������� G ���ѡ���С�

  repeat
    // FiniteFieldSize := CnGenerateUInt32Prime; // ����С�������������Ҳ����̫С
    Randomize;
    I := Trunc(Random * (High(CN_PRIME_NUMBERS_SQRT_UINT32) - 100)) + 100;
    FiniteFieldSize := CN_PRIME_NUMBERS_SQRT_UINT32[I];
    CoefficientA := Trunc(Random * 16);
    CoefficientB := Trunc(Random * 256);
    N := 1; // 0,0 ��Ȼ����

    // A��B ���Ƚ�С�����ﲻ�õ������
    if (4 * CoefficientA * CoefficientA * CoefficientA - 27 * CoefficientB * CoefficientB)
      mod FiniteFieldSize = 0 then
      Continue;

    GX := 0;
    GY := 0;

    // ���������Բ���ߵĽף����� SEA��ԭ��ֻ������������ٷ�����������õ¹�ʽ
    // N := 1 + P + ���е����õ�((x^3+ax+b)/p)֮�ͣ����� X �� 0 �� P - 1
    Inc(N, FiniteFieldSize);
    for I := 0 to FiniteFieldSize - 1 do
    begin
      // ������� Int64 ��ת��һ�£����� I �����η����� Integer �����
      N := N + CalcInt64Legendre(Int64(I) * Int64(I) * Int64(I) + CoefficientA * I + CoefficientB, FiniteFieldSize);
    end;

    // Ȼ�������һ�� X �� Y
    Ecc64 := TCnInt64Ecc.Create(CoefficientA, CoefficientB, FiniteFieldSize, 0, 0, FiniteFieldSize);
    repeat
      P.X := Trunc(Random * (FiniteFieldSize - 1)) + 1;
      for I := 0 to FiniteFieldSize - 1 do
      begin
        P.Y := I;
        if Ecc64.IsPointOnCurve(P) then
        begin
          GX := P.X;
          GY := P.Y;
          Break;
        end;
      end;
    until (GX > 0) and (GY > 0);
    Ecc64.Free;

//    ���´�������ٷ�����֤ N �Ƿ���ȷ��ĿǰС��Χ������������û��
//    N := 1;
//    Ecc64 := TCnInt64Ecc.Create(CoefficientA, CoefficientB, FiniteFieldSize, 0, 0, FiniteFieldSize);
//    for I := 0 to FiniteFieldSize - 1 do
//    begin
//      for J := 0 to FiniteFieldSize - 1 do
//      begin
//        P.X := I;
//        P.Y := J;
//        if Ecc64.IsPointOnCurve(P) then
//        begin
//          Inc(N);
//          if (GX = 0) or (GY = 0) then // ��һ������ľ͵�������
//          begin
//            GX := P.X;
//            GY := P.Y;
//          end;
//
//          if P.Y > 0 then
//          begin
//            P.Y := FiniteFieldSize - P.Y;
//            if Ecc64.IsPointOnCurve(P) then
//              Inc(N);
//          end;
//
//          // ��� X �Ѿ������ˣ�ÿ�� X �����ж������� Y��
//          Break;
//        end;
//      end;
//      // Break ���ˣ�������һ�� X ��ѭ��
//    end;

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
    Result := -Result;

  if Result < 0 then
    Result := Result + Modulus;
end;

function CalcBigNumberLegendre(A, P: TCnBigNumber): Integer;
var
  R, Res: TCnBigNumber;
begin
  R := TCnBigNumber.Create;
  Res := TCnBigNumber.Create;
  try
    // ���������P ������ A ʱ���� 0����������ʱ����� A ����ȫƽ�����ͷ��� 1�����򷵻� -1
    BigNumberMod(R, A, P);
    if R.IsZero then
      Result := 0
    else
    begin
      BigNumberCopy(R, P);
      BigNumberSubWord(R, 1);
      BigNumberMontgomeryPowerMod(Res, A, R, P);

      if Res.IsOne then // ŷ���б�
        Result := 1
      else
        Result := -1;
    end;
  finally
    R.Free;
    Res.Free;
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
  AX := Int64MultipleMod(FCoefficientA, P.X, FFiniteFieldSize);
  B := FCoefficientB mod FFiniteFieldSize;

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
  AX := Int64MultipleMod(FCoefficientA, Plain, FFiniteFieldSize);
  B := FCoefficientB mod FFiniteFieldSize;

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
    X := 3 * P.X * P.X + FCoefficientA;
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
  if X < 0 then
  begin
    X := -X;
    Sum.X := X mod FFiniteFieldSize;
    Sum.X := FFiniteFieldSize - Sum.X;
  end
  else
    Sum.X := X mod FFiniteFieldSize;

  // Ysum = (K * (X1 - Xsum) - Y1) mod p  ע��Ҫȡ��
  //   Ҳ = (K * (X2 - Xsum) - Y2) mod p  ע��Ҫȡ��
  X := PX - Sum.X;
  Y := K * X - P.Y;
  if Y < 0 then
  begin
    Y := -Y;
    Sum.Y := Y mod FFiniteFieldSize;
    Sum.Y := FFiniteFieldSize - Sum.Y;
  end
  else
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

{ TCnEccPoint }

procedure TCnEccPoint.Assign(Source: TPersistent);
begin
  if Source is TCnEccPoint then
  begin
    BigNumberCopy(FX, (Source as TCnEccPoint).X);
    BigNumberCopy(FY, (Source as TCnEccPoint).Y);
  end
  else
    inherited;
end;

constructor TCnEccPoint.Create;
begin
  inherited;
  FX := TCnBigNumber.Create;
  FY := TCnBigNumber.Create;
  FX.SetZero;
  FY.SetZero;
end;

destructor TCnEccPoint.Destroy;
begin
  FY.Free;
  FX.Free;
  inherited;
end;

function TCnEccPoint.IsZero: Boolean;
begin
  Result := FX.IsZero and FY.IsZero;
end;

procedure TCnEccPoint.SetX(const Value: TCnBigNumber);
begin
  BigNumberCopy(FX, Value);
end;

procedure TCnEccPoint.SetY(const Value: TCnBigNumber);
begin
  BigNumberCopy(FY, Value);
end;

procedure TCnEccPoint.SetZero;
begin
  FX.SetZero;
  FY.SetZero;
end;

{ TCnEcc }

constructor TCnEcc.Create(const A, B, FieldPrime, GX, GY, Order: AnsiString);
begin
  Create;
  Load(A, B, FIeldPrime, GX, GY, Order);
end;

constructor TCnEcc.Create;
begin
  inherited;
  FGenerator := TCnEccPoint.Create;
  FCoefficientB := TCnBigNumber.Create;
  FCoefficientA := TCnBigNumber.Create;
  FOrder := TCnBigNumber.Create;
  FFiniteFieldSize := TCnBigNumber.Create;
end;

constructor TCnEcc.Create(Predefined: TCnEccPredefinedCurveType);
begin
  Create;
  Load(Predefined);
end;

procedure TCnEcc.Decrypt(DataPoint1, DataPoint2: TCnEccPoint;
  PrivateKey: TCnEccPrivateKey; OutPlainPoint: TCnEccPoint);
var
  P: TCnEccPoint;
begin
  if (BigNumberCompare(PrivateKey, CnBigNumberZero) <= 0) or
    not IsPointOnCurve(DataPoint1) or not IsPointOnCurve(DataPoint2) then
    raise ECnEccException.Create('Invalid Private Key or Data.');

  P := TCnEccPoint.Create;
  try
    P.Assign(DataPoint2);
    MultiplePoint(PrivateKey, P);
    PointSubPoint(DataPoint1, P, OutPlainPoint);
  finally
    P.Free;
  end;
end;

destructor TCnEcc.Destroy;
var
  I: Integer;
begin
  if FBigNumberPool <> nil then
  begin
    for I := 0 to FBigNumberPool.Count - 1 do
      FBigNumberPool[I].Free;
    FBigNumberPool.Free;
  end;

  FGenerator.Free;
  FCoefficientB.Free;
  FCoefficientA.Free;
  FOrder.Free;
  FFiniteFieldSize.Free;
  inherited;
end;

procedure TCnEcc.Encrypt(PlainPoint: TCnEccPoint;
  PublicKey: TCnEccPublicKey; OutDataPoint1, OutDataPoint2: TCnEccPoint);
var
  RandomKey: TCnBigNumber;
begin
  if not IsPointOnCurve(PublicKey) or not IsPointOnCurve(PlainPoint) then
    raise ECnEccException.Create('Invalid Public Key or Data.');

  RandomKey := ObtainBigNumberFromPool;
  try
    BigNumberRandRange(RandomKey, FOrder);    // �� 0 �󵫱Ȼ����С�������
    if BigNumberIsZero(RandomKey) then
      BigNumberSetOne(RandomKey);

    // M + rK;
    OutDataPoint1.Assign(PublicKey);
    MultiplePoint(RandomKey, OutDataPoint1);
    PointAddPoint(PlainPoint, OutDataPoint1, OutDataPoint1);

    // r * G
    OutDataPoint2.Assign(FGenerator);
    MultiplePoint(RandomKey, OutDataPoint2);
  finally
    RecycleBigNumberToPool(RandomKey);
  end;
end;

procedure TCnEcc.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey);
begin
  BigNumberRandRange(PrivateKey, FOrder);           // �� 0 �󵫱Ȼ����С�������
  if PrivateKey.IsZero then                         // ��һ���õ� 0���ͼ� 1
    PrivateKey.SetOne;

  PublicKey.Assign(FGenerator);
  MultiplePoint(PrivateKey, PublicKey);             // ����� PrivateKey ��
end;

function TCnEcc.GetBitsCount: Integer;
begin
  Result := FFiniteFieldSize.GetBitsCount;
end;

function TCnEcc.IsPointOnCurve(P: TCnEccPoint): Boolean;
var
  X, X2, Y, A: TCnBigNumber;
begin
  X := ObtainBigNumberFromPool;
  X2 := ObtainBigNumberFromPool;
  Y := ObtainBigNumberFromPool;
  A := ObtainBigNumberFromPool;

  try
    BigNumberCopy(X, P.X);
    BigNumberCopy(X2, P.X);
    BigNumberCopy(Y, P.Y);

    BigNumberMul(Y, Y, Y);                // Y: Y^2
    BigNumberMod(Y, Y, FFiniteFieldSize); // Y^2 mod P

    BigNumberMul(A, X, FCoefficientA);     // A: A*X

    BigNumberMul(X, X, X);
    BigNumberMul(X, X, X2);               // X: X^3

    BigNumberAdd(X, X, A);                // X: X^3 + A*X
    BigNumberAdd(X, X, FCoefficientB);     // X: X^3 + A*X + B

    BigNumberMod(X, X, FFiniteFieldSize); // X: (X^3 + A*X + B) mod P
    Result := BigNumberCompare(X, Y) = 0;
  finally
    RecycleBigNumberToPool(X);
    RecycleBigNumberToPool(X2);
    RecycleBigNumberToPool(Y);
    RecycleBigNumberToPool(A);
  end;
end;

procedure TCnEcc.Load(Predefined: TCnEccPredefinedCurveType);
begin
  Load(ECC_PRE_DEFINED_PARAMS[Predefined].A, ECC_PRE_DEFINED_PARAMS[Predefined].B,
    ECC_PRE_DEFINED_PARAMS[Predefined].P, ECC_PRE_DEFINED_PARAMS[Predefined].GX,
    ECC_PRE_DEFINED_PARAMS[Predefined].GY, ECC_PRE_DEFINED_PARAMS[Predefined].N);
end;

procedure TCnEcc.Load(const A, B, FieldPrime, GX, GY, Order: AnsiString);
begin
  FGenerator.X.SetHex(GX);
  FGenerator.Y.SetHex(GY);
  FCoefficientA.SetHex(A);
  FCoefficientB.SetHex(B);
  FFiniteFieldSize.SetHex(FieldPrime);
  FOrder.SetHex(Order);
end;

procedure TCnEcc.MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
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
    Point.X.SetZero;
    Point.Y.SetZero;
    Exit;
  end;

  R := nil;
  E := nil;

  try
    R := TCnEccPoint.Create;
    E := TCnEccPoint.Create;
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
    R.Free;
    E.Free;
  end;
end;

function TCnEcc.ObtainBigNumberFromPool: TCnBigNumber;
begin
  if FBigNumberPool = nil then
    Result := TCnBigNumber.Create
  else if FBigNumberPool.Count = 0 then
    Result := TCnBigNumber.Create
  else
  begin
    Result := TCnBigNumber(FBigNumberPool.Last);
    Result.Clear;
    FBigNumberPool.Delete(FBigNumberPool.Count - 1);
  end;
end;

function TCnEcc.PlainToPoint(Plain: TCnBigNumber;
  OutPoint: TCnEccPoint): Boolean;
var
  P, Q: TCnBigNumber;
  Pt: TCnEccPoint;
begin
  Result := False;

  // �� Plain ���� 16 λ�ڳ� 2^16 ���ռ����������޽�
  if Plain.GetBitsCount - CN_ECC_PLAIN_DATA_BITS_GAP - 1 > FFiniteFieldSize.GetBitsCount then
    raise ECnEccException.Create('Data Too Large.');

  P := nil;
  Q := nil;
  Pt := nil;

  try
    Pt := TCnEccPoint.Create;
    P := ObtainBigNumberFromPool;
    Q := ObtainBigNumberFromPool;

    BigNumberCopy(Pt.X, Plain);
    BigNumbercopy(Q, Plain);
    BigNumberAddWord(Q, 1);

    BigNumberShiftLeft(Pt.X, Pt.X, CN_ECC_PLAIN_DATA_BITS_GAP);
    BigNumberShiftLeft(Q, Q, CN_ECC_PLAIN_DATA_BITS_GAP);

    repeat
      // ���� Pt.X ������Χ�ڵ�ÿһ�� X��Pt.Y ���� 0 �� FFiniteFieldSize - 1 �������������ߵ�

      // ͨ�����õ·����ж� X �Ƿ��н⣬�в��ڸ� X ����Ѱ
      if CalcBigNumberLegendre(Pt.X, FFiniteFieldSize) = 1 then
      begin
        Pt.Y.SetZero;
        repeat
          if IsPointOnCurve(Pt) then
          begin
            OutPoint.Assign(Pt);
            Result := True;
            Exit;
          end;
          BigNumberAddWord(Pt.Y, 1);
        until BigNumberCompare(Pt.Y, FFiniteFieldSize) >= 0;
      end;

      BigNumberAddWord(Pt.X, 1);
    until BigNumberCompare(Pt.X, Q) >= 0;
  finally
    Pt.Free;
    RecycleBigNumberToPool(P);
    RecycleBigNumberToPool(Q);
  end;
end;

procedure TCnEcc.PointAddPoint(P, Q, Sum: TCnEccPoint);
var
  K, X, Y, A, SX, SY: TCnBigNumber;
begin
  K := nil;
  X := nil;
  Y := nil;
  A := nil;
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
    end
    else if (BigNumberCompare(P.X, Q.X) = 0) and (BigNumberCompare(P.Y, Q.Y) = 0) then
    begin
      // ��������ͬһ���㣬����б��Ϊ�����󵼣�3 * X^2 + A / (2 * Y) ���� Y = 0 ��ֱ��������Զ 0��
      if P.Y.IsZero then
      begin
        Sum.SetZero;
        Exit;
      end;

      X := ObtainBigNumberFromPool;
      Y := ObtainBigNumberFromPool;
      K := ObtainBigNumberFromPool;

      // X := 3 * P.X * P.X + CoefficientA;
      BigNumberMul(X, P.X, P.X);             // X: P.X^2
      BigNumberMulWord(X, 3);                // X: 3 * P.X^2
      BigNumberAdd(X, X, FCoefficientA);     // X: 3 * P.X^2 + A

      // Y := 2 * P.Y;
      BigNumberCopy(Y, P.Y);
      BigNumberMulWord(Y, 2);                // Y: 2 * P.Y

      A := ObtainBigNumberFromPool;
      BigNumberCopy(A, Y);
      BigNumberModularInverse(Y, A, FFiniteFieldSize);

      // K := X * Y mod FFiniteFieldSize;
      BigNumberMulMod(K, X, Y, FFiniteFieldSize);      // �õ�б��
    end
    else // �ǲ�ͬ��
    begin
      if BigNumberCompare(P.X, Q.X) = 0 then // ��� X ��ȣ�Ҫ�ж� Y �ǲ��ǻ����������Ϊ 0�����������
      begin
        A := ObtainBigNumberFromPool;
        BigNumberAdd(A, P.Y, Q.Y);
        if BigNumberCompare(A, FFiniteFieldSize) = 0 then  // ��������Ϊ 0
          Sum.SetZero
        else                                               // ������������
          raise ECnEccException.CreateFmt('Can NOT Calucate %s,%s + %s,%s', [P.X.ToDec, P.Y.ToDec, Q.X.ToDec, Q.Y.ToDec]);

        Exit;
      end;

      // �����X ȷ����ͬ��б�� K := ((Q.Y - P.Y) / (Q.X - P.X)) mod p
      X := ObtainBigNumberFromPool;
      Y := ObtainBigNumberFromPool;
      K := ObtainBigNumberFromPool;

      // Y := Q.Y - P.Y;
      // X := Q.X - P.X;
      BigNumberSub(Y, Q.Y, P.Y);
      BigNumberSub(X, Q.X, P.X);

      A := ObtainBigNumberFromPool;
      BigNumberCopy(A, X);
      BigNumberModularInverse(X, A, FFiniteFieldSize);
      BigNumberMulMod(K, Y, X, FFiniteFieldSize);      // �õ�б��
    end;

    BigNumberCopy(X, K);
    BigNumberMul(X, X, K);
    BigNumberSub(X, X, P.X);
    BigNumberSub(X, X, Q.X);    //  X := K * K - P.X - Q.X;

    SX := ObtainBigNumberFromPool;
    if BigNumberIsNegative(X) then // ��ֵ��ģ������ֵ��ģ��ģ����
    begin
      BigNumberSetNegative(X, False);
      BigNumberMod(SX, X, FFiniteFieldSize);
      BigNumberSub(SX, FFiniteFieldSize, SX);
    end
    else
      BigNumberMod(SX, X, FFiniteFieldSize);

    // Ysum = (K * (X1 - Xsum) - Y1) mod p  ע��Ҫȡ��
    //   Ҳ = (K * (X2 - Xsum) - Y2) mod p  ע��Ҫȡ��
    BigNumberSub(X, P.X, SX);
    BigNumberMul(Y, K, X);
    BigNumberSub(Y, Y, P.Y);

    SY := ObtainBigNumberFromPool;
    if BigNumberIsNegative(Y) then
    begin
      BigNumberSetNegative(Y, False);
      BigNumberMod(SY, Y, FFiniteFieldSize);
      BigNumberSub(SY, FFiniteFieldSize, SY);
    end
    else
      BigNumberMod(SY, Y, FFiniteFieldSize);

    BigNumberCopy(Sum.X, SX);
    BigNumberCopy(Sum.Y, SY);
  finally
    RecycleBigNumberToPool(K);
    RecycleBigNumberToPool(X);
    RecycleBigNumberToPool(Y);
    RecycleBigNumberToPool(A);
    RecycleBigNumberToPool(SX);
    RecycleBigNumberToPool(SY);
  end;
end;

procedure TCnEcc.PointInverse(P: TCnEccPoint);
begin
  if BigNumberIsNegative(P.Y) or (BigNumberCompare(P.Y, FFiniteFieldSize) >= 0) then
    raise ECnEccException.Create('Inverse Error.');

  BigNumberSub(P.Y, FFiniteFieldSize, P.Y);
end;

procedure TCnEcc.PointSubPoint(P, Q, Diff: TCnEccPoint);
var
  Inv: TCnEccPoint;
begin
  Inv := TCnEccPoint.Create;
  Inv.X := Q.X;
  Inv.Y := Q.Y;
  PointInverse(Inv);
  PointAddPoint(P, Inv, Diff);
  Inv.Free;
end;

function TCnEcc.PointToPlain(Point: TCnEccPoint;
  OutPlain: TCnBigNumber): Boolean;
begin
  Result := False;
  if (Point <> nil) and (OutPlain <> nil) then
  begin
    BigNumberCopy(OutPlain, Point.X);
    BigNumberShiftRight(OutPlain, OutPlain, CN_ECC_PLAIN_DATA_BITS_GAP);
    Result := True;
  end;
end;

procedure TCnEcc.RecycleBigNumberToPool(Num: TCnBigNumber);
begin
  if Num = nil then
    Exit;

  if FBigNumberPool = nil then
    FBigNumberPool := TObjectList.Create(False);
  FBigNumberPool.Add(Num);
end;

function CnEccDiffieHellmanGenerateOutKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey): Boolean;
begin
  // PublicKey = SelfPrivateKey * G
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey <> nil) and not BigNumberIsNegative(SelfPrivateKey) then
  begin
    PublicKey.Assign(Ecc.Generator);
    Ecc.MultiplePoint(SelfPrivateKey, PublicKey);
    Result := True;
  end;
end;

function CnEccDiffieHellmanCalucateKey(Ecc: TCnEcc; SelfPrivateKey: TCnEccPrivateKey;
  OtherPublicKey: TCnEccPublicKey; SecretKey: TCnEccPublicKey): Boolean;
begin
  // SecretKey = SelfPrivateKey * OtherPublicKey
  Result := False;
  if (Ecc <> nil) and (SelfPrivateKey <> nil) and not BigNumberIsNegative(SelfPrivateKey) then
  begin
    SecretKey.Assign(OtherPublicKey);
    Ecc.MultiplePoint(SelfPrivateKey, SecretKey);
    Result := True;
  end;
end;

end.
