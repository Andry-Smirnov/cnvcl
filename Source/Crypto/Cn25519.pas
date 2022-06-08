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
*           ǩ������ rfc 8032 ��˵��
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2022.06.08 V1.1
*               ʵ�� Ed25519 ǩ������֤
*           2022.06.07 V1.1
*               ʵ�� Ed25519 ��չ��Ԫ����Ŀ��ٵ���������ʵ�֣��ٶȿ�ʮ������
*           2022.06.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNativeDecl, CnBigNumber, CnECC, CnSHA2;

const
  CN_25519_BLOCK_BYTESIZE = 32;

type
  TCnEcc4Point = class(TCnEcc3Point)
  {* ��չ����Ӱ/����/�ſɱ�����㣬������ T ���ڼ�¼�м���}
  private
    FT: TCnBigNumber;
    procedure SetT(const Value: TCnBigNumber);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function ToString: string; override; // ������ ToString

    property T: TCnBigNumber read FT write SetT;
  end;

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
    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); overload; virtual;
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

    procedure GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey); virtual;
    {* ����һ�Ը���Բ���ߵĹ�˽Կ��˽Կ��������� k����Կ�ǻ��� G ���� k �γ˷���õ��ĵ����� K}

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

  TCnCurve25519 = class(TCnMontgomeryCurve)
  {* rfc 7748/8032 �й涨�� Curve25519 ����}
  public
    constructor Create; override;

    procedure GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey); override;
    {* ����һ�� Curve25519 ��Բ���ߵĹ�˽Կ������˽Կ�ĸߵ�λ�����⴦��}
  end;

  TCnEd25519Data = array[0..CN_25519_BLOCK_BYTESIZE - 1] of Byte;

  TCnEd25519SignatureData = array[0..2 * CN_25519_BLOCK_BYTESIZE - 1] of Byte;

  TCnEd25519 = class(TCnTwistedEdwardsCurve)
  {* rfc 7748/8032 �й涨�� Ed25519 ����}
  public
    constructor Create; override;

    function GenerateKeys(PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey): Boolean;
    {* ����һ�� Ed25519 ��Բ���ߵĹ�˽Կ�����й�Կ�Ļ���������� SHA512 �������}

    function PlainToPoint(Plain: TCnEd25519Data; OutPoint: TCnEccPoint): Boolean;
    {* �� 32 �ֽ�ֵת��Ϊ����㣬�漰�����}
    function PointToPlain(Point: TCnEccPoint; var OutPlain: TCnEd25519Data): Boolean;
    {* ��������ת���� 32 �ֽ�ֵ��ƴ Y ���� X ����һλ}

    procedure MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint); override;
    {* ���ظ������ͨ��ˣ��ڲ�������չ��Ԫ���ٳ�}

    function IsNeutualExtendedPoint(P: TCnEcc4Point): Boolean;
    {* �жϵ��Ƿ������Ե㣬Ҳ�����ж� X = 0 �� Y = 1���� Weierstrass ������Զ��ȫ 0 ��ͬ}
    procedure SetNeutualExtendedPoint(P: TCnEcc4Point);
    {* ������Ϊ���Ե㣬Ҳ���� X := 0 �� Y := 1}

    function ExtendedPointAddPoint(P, Q, Sum: TCnEcc4Point): Boolean;
    {* ʹ����չŤ�����»����꣨��Ԫ���Ŀ��ٵ�ӷ����� P + Q��ֵ���� Sum �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    function ExtendedPointSubPoint(P, Q, Diff: TCnEcc4Point): Boolean;
    {* ʹ����չŤ�����»����꣨��Ԫ������ P - Q��ֵ���� Diff �У�Diff ������ P��Q ֮һ��P��Q ������ͬ}
    procedure ExtendedPointInverse(P: TCnEcc4Point);
    {* ʹ����չŤ�����»����꣨��Ԫ������ P �����Ԫ -P��ֵ���·��� P��Ҳ���� Y ֵȡ��}
    function IsExtendedPointOnCurve(P: TCnEcc4Point): Boolean;
    {* �ж���չŤ�����»����꣨��Ԫ�� P ���Ƿ��ڱ�������}

    procedure ExtendedMultiplePoint(K: Int64; Point: TCnEcc4Point); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P}
    procedure ExtendedMultiplePoint(K: TCnBigNumber; Point: TCnEcc4Point); overload;
    {* ����ĳ�� P �� k * P ֵ��ֵ���·��� P���ٶȱ���ͨ�����˿�ʮ������}
  end;

  TCnEd25519Signature = class(TPersistent)
  {* Ed25519 ��ǩ������һ������һ���������� TCnEccSignature ��ͬ}
  private
    FR: TCnEccPoint;
    FS: TCnBigNumber;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure SaveToData(var Sig: TCnEd25519SignatureData);
    {* ����ת���� 64 �ֽ�ǩ�����鹩�洢�봫��}

    procedure LoadFromData(Sig: TCnEd25519SignatureData);
    {* ��64 �ֽ�ǩ�������м���ǩ��}

    property R: TCnEccPoint read FR;
    {* ǩ���� R}
    property S: TCnBigNumber read FS;
    {* ǩ���� S}
  end;

function CnEcc4PointToString(const P: TCnEcc4Point): string;
{* ��һ�� TCnEcc4Point ������ת��Ϊʮ�����ַ���}

function CnEcc4PointToHex(const P: TCnEcc4Point): string;
{* ��һ�� TCnEcc4Point ������ת��Ϊʮ�������ַ���}

function CnEcc4PointEqual(const P, Q: TCnEcc4Point; Prime: TCnBigNumber): Boolean;
{* �ж����� TCnEcc4Point �Ƿ�ͬһ����}

function CnEccPointToEcc4Point(P: TCnEccPoint; P4: TCnEcc4Point; Prime: TCnBigNumber): Boolean;
{* ������Χ�ڵ���ͨ���굽��չ��������ĵ�ת��}

function CnEcc4PointToEccPoint(P4: TCnEcc4Point; P: TCnEccPoint; Prime: TCnBigNumber): Boolean;
{* ������Χ�ڵ���չ�������굽��ͨ����ĵ�ת��}

function CnCurve25519PointToEd25519Point(DestPoint, SourcePoint: TCnEccPoint): Boolean;
{* �� Curve25519 �������ת��Ϊ Ed25519 �������}

function CnEd25519PointToCurve25519Point(DestPoint, SourcePoint: TCnEccPoint): Boolean;
{* �� Ed25519 �������ת��Ϊ Curve25519 �������}

function CnEd25519PointToData(P: TCnEccPoint; var Data: TCnEd25519Data): Boolean;
{* �� 25519 ��׼����Բ���ߵ�ת��Ϊѹ����ʽ�� 32 �ֽ����飬����ת���Ƿ�ɹ�}

function CnEd25519DataToPoint(Data: TCnEd25519Data; P: TCnEccPoint; out XOdd: Boolean): Boolean;
{* �� 25519 ��׼�� 32 �ֽ�����ת��Ϊ��Բ���ߵ�ѹ����ʽ������ת���Ƿ�ɹ���
  ����ɹ���P �з��ض�Ӧ Y ֵ���Լ� XOdd �з��ض�Ӧ�� X ֵ�Ƿ�����������Ҫ������н� X}

function CnEd25519BigNumberToData(N: TCnBigNumber; var Data: TCnEd25519Data): Boolean;
{* �� 25519 ��׼������ת��Ϊ 32 �ֽ����飬����ת���Ƿ�ɹ�}

function CnEd25519DataToBigNumber(Data: TCnEd25519Data; N: TCnBigNumber): Boolean;
{* �� 25519 ��׼�� 32 �ֽ�����ת��Ϊ����������ת���Ƿ�ɹ�}

// ===================== Ed25519 ��Բ��������ǩ����֤�㷨 ======================

function CnEd25519SignData(PlainData: Pointer; DataLen: Integer; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; OutSignature: TCnEd25519Signature; Ed25519: TCnEd25519 = nil): Boolean;
{* Ed25519 �ù�˽Կ�����ݿ����ǩ��������ǩ���Ƿ�ɹ�}

function CnEd25519VerifyData(PlainData: Pointer; DataLen: Integer; InSignature: TCnEd25519Signature;
  PublicKey: TCnEccPublicKey; Ed25519: TCnEd25519 = nil): Boolean;
{* Ed25519 �ù�Կ�����ݿ���ǩ��������֤��������֤�Ƿ�ɹ�}

// ================= Ed25519 ��Բ���� Diffie-Hellman ��Կ����  =================

function CnCurve25519KeyExchangeStep1(SelfPrivateKey: TCnEccPrivateKey;
  OutPointToAnother: TCnEccPoint; Curve25519: TCnCurve25519 = nil): Boolean;
{* ���� 25519 �� Diffie-Hellman ��Կ�����㷨��A �� B ���ȵ��ô˷�����
  ���ݸ���˽Կ���ɵ����꣬�õ������跢���Է������������Ƿ�ɹ�}

function CnCurve25519KeyExchangeStep2(SelfPrivateKey: TCnEccPrivateKey;
  InPointFromAnother: TCnEccPoint; OutKey: TCnEccPoint; Curve25519: TCnCurve25519 = nil): Boolean;
{* ���� 25519 �� Diffie-Hellman ��Կ�����㷨��A �� B �յ��Է��� Point ������ٵ��ô˷�����
  ���ݸ���˽Կ����һ��ͬ�ĵ����꣬�õ������Ϊ������Կ������ͨ��������һ�����ӻ���
  ���������Ƿ�ɹ�}

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
  // ���� RFC �е� y = 14781619447589544791020593568409986887264606134616475288964881837755586237401�����ƺ����� 4/5��Ҳ���� 5 * Y mod P = 4
  // ������ 5F51E65E475F794B1FE122D388B72EB36DC2B28192839E4DD6163A5D81312C14 �ŷ��� 4/5 ���Һ� Ed25519 �� GY ��Ӧ

  SCN_25519_SQRT_NEG_486664 = '0F26EDF460A006BBD27B08DC03FC4F7EC5A1D3D14B7D1A82CC6E04AAFF457E06';
  // ��ǰ��õ� sqrt(-486664)����������ת������

// =============================================================================
// �ɸ��������� By^2 = x^3 + Ax^2 + x ��Ť�����»����� au^2 + v^2 = 1 + du^2v^2
// �����еȼ۵�һһӳ���ϵ������ A = 2(a+d)/(a-d) ������֤�� �� B = 4 /(a-d)
// �� Curve25519 ������ Ed25519 �����־����˲���������B = 4 /(a-d) ������
// ͬ����(x, y) �� (u, v) �Ķ�Ӧ��ϵҲ��Ϊ A B a d ��ϵ�ĵ������������׼ӳ��
// =============================================================================


var
  F25519BigNumberPool: TCnBigNumberPool = nil;

function CalcBigNumberDigest(const Num: TCnBigNumber; FixedLen: Integer): TSHA512Digest;
var
  Stream: TStream;
begin
  Stream := TMemoryStream.Create;
  try
    FillChar(Result[0], SizeOf(TSHA512Digest), 0);
    if BigNumberWriteBinaryToStream(Num, Stream, FixedLen) <> FixedLen then
      Exit;

    Result := SHA512Stream(Stream);
  finally
    Stream.Free;
  end;
end;

// �������˽Կ�����ɹ�Կ�� Ed25519 ǩ��ʹ�õ� Hash ����
function CalcBigNumbersFromPrivateKey(const InPrivateKey: TCnBigNumber; FixedLen: Integer;
  OutMulFactor, OutHashPrefix: TCnBigNumber): Boolean;
var
  Dig: TSHA512Digest;
begin
  // �� PrivateKey �� Sha512���õ� 64 �ֽڽ�� Dig
  Dig := CalcBigNumberDigest(InPrivateKey, CN_25519_BLOCK_BYTESIZE);

  // ������ Sha512���õ� 64 �ֽڽ����ǰ 32 �ֽ�ȡ�����������ȵ��򣬵� 3 λ�����㣬
  // ���� CoFactor �� 2^3 = 8 ��Ӧ���������λ 2^255 ���� 0���θ�λ 2^254 ���� 1
  if OutMulFactor <> nil then
  begin
    ReverseMemory(@Dig[0], CN_25519_BLOCK_BYTESIZE);         // �õ�����
    OutMulFactor.SetBinary(@Dig[0], CN_25519_BLOCK_BYTESIZE);

    OutMulFactor.ClearBit(0);                                // ����λ�� 0
    OutMulFactor.ClearBit(1);
    OutMulFactor.ClearBit(2);
    OutMulFactor.ClearBit(CN_25519_BLOCK_BYTESIZE * 8 - 1);  // ���λ�� 0
    OutMulFactor.SetBit(CN_25519_BLOCK_BYTESIZE * 8 - 2);    // �θ�λ�� 1
  end;

  // �� 32 �ֽ���Ϊ Hash ����ڲ���
  if OutHashPrefix <> nil then
    OutHashPrefix.SetBinary(@Dig[CN_25519_BLOCK_BYTESIZE], CN_25519_BLOCK_BYTESIZE);

  Result := True;
end;

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
//            x1 * y2 + x2 * y1                 y1 * y2 - a * x1 * x2
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

procedure TCnMontgomeryCurve.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey);
begin
  BigNumberRandRange(PrivateKey, FOrder);           // �� 0 �󵫱Ȼ����С�������
  if PrivateKey.IsZero then                         // ��һ���õ� 0���ͼ� 1
    PrivateKey.SetOne;

  PublicKey.Assign(FGenerator);
  MultiplePoint(PrivateKey, PublicKey);             // ����� PrivateKey ��
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
  //          (y2 - y1)           3*x1^2 + 2*A*x1 + 1
  // б�� K = ----------  �� =  ----------------------
  //          (x2 - x1)                2*y1
  //
  // x3 = B*K^2 - A - x1 - x2
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
      // ������ (3*x1^2 + 2*A*x1 + 1)
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

      if not BigNumberAddMod(X, P.Y, P.Y, FFiniteFieldSize) then  // 2Y
        Exit;

      if not BigNumberModularInverse(T, X, FFiniteFieldSize) then // �õ���ĸ 2*y1
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

      if not BigNumberSubMod(Y, Q.Y, P.Y, FFiniteFieldSize) then   // �õ����� (y2 - y1)
        Exit;

      if not BigNumberSubMod(X, Q.X, P.X, FFiniteFieldSize) then   // �õ���ĸ (x2 - x1)
        Exit;

      if not BigNumberModularInverse(T, X, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(K, Y, T, FFiniteFieldSize) then // K �õ�����б��
        Exit;
    end;

    // x3 = B * K^2 - A - x1 - x2
    if not BigNumberDirectMulMod(SX, K, K, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(SX, FCoefficientB, SX, FFiniteFieldSize) then
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

    if BigNumberCopy(Sum.X, SX) = nil then
      Exit;
    if BigNumberCopy(Sum.Y, SY) = nil then
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

procedure TCnCurve25519.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey);
begin
  BigNumberRandRange(PrivateKey, FOrder);           // �� 0 �󵫱Ȼ����С�������
  if PrivateKey.IsZero then                         // ��һ���õ� 0���ͼ� 1
    PrivateKey.SetOne;

  PrivateKey.ClearBit(0);                                // ����λ�� 0
  PrivateKey.ClearBit(1);
  PrivateKey.ClearBit(2);
  PrivateKey.ClearBit(CN_25519_BLOCK_BYTESIZE * 8 - 1);  // ���λ�� 0
  PrivateKey.SetBit(CN_25519_BLOCK_BYTESIZE * 8 - 2);    // �θ�λ�� 1

  PublicKey.Assign(FGenerator);
  MultiplePoint(PrivateKey, PublicKey);             // ����� PrivateKey ��
end;

{ TCnEd25519 }

constructor TCnEd25519.Create;
begin
  inherited;
  Load(SCN_25519_EDWARDS_A, SCN_25519_EDWARDS_D, SCN_25519_PRIME, SCN_25519_EDWARDS_GX,
    SCN_25519_EDWARDS_GY, SCN_25519_ORDER, 8);
end;

procedure TCnEd25519.ExtendedMultiplePoint(K: Int64; Point: TCnEcc4Point);
var
  BK: TCnBigNumber;
begin
  BK := F25519BigNumberPool.Obtain;
  try
    BK.SetInt64(K);
    ExtendedMultiplePoint(BK, Point);
  finally
    F25519BigNumberPool.Recycle(BK);
  end;
end;

procedure TCnEd25519.ExtendedMultiplePoint(K: TCnBigNumber;
  Point: TCnEcc4Point);
var
  I: Integer;
  E, R: TCnEcc4Point;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    ExtendedPointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    SetNeutualExtendedPoint(Point);
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  R := nil;
  E := nil;

  try
    R := TCnEcc4Point.Create;
    E := TCnEcc4Point.Create;

    // R Ҫ�����Ե�
    SetNeutualExtendedPoint(R);

    E.X := Point.X;
    E.Y := Point.Y;
    E.Z := Point.Z;
    E.T := Point.T;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        ExtendedPointAddPoint(R, E, R);
      ExtendedPointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
    Point.Z := R.Z;
  finally
    R.Free;
    E.Free;
  end;
end;

function TCnEd25519.ExtendedPointAddPoint(P, Q, Sum: TCnEcc4Point): Boolean;
var
  A, B, C, D, E, F, G, H: TCnBigNumber;
begin
  Result := False;
  A := nil;
  B := nil;
  C := nil;
  D := nil;
  E := nil;
  F := nil;
  G := nil;
  H := nil;

  try
    A := F25519BigNumberPool.Obtain;
    B := F25519BigNumberPool.Obtain;
    C := F25519BigNumberPool.Obtain;
    D := F25519BigNumberPool.Obtain;
    E := F25519BigNumberPool.Obtain;
    F := F25519BigNumberPool.Obtain;
    G := F25519BigNumberPool.Obtain;
    H := F25519BigNumberPool.Obtain;

    if CnEcc4PointEqual(P, Q, FFiniteFieldSize) then
    begin
      // ��ͬһ����
      if not BigNumberDirectMulMod(A, P.X, P.X, FFiniteFieldSize) then // A = X1^2
        Exit;

      if not BigNumberDirectMulMod(B, P.Y, P.Y, FFiniteFieldSize) then // B = Y1^2
        Exit;

      if not BigNumberDirectMulMod(C, P.Z, P.Z, FFiniteFieldSize) then 
        Exit;
      if not BigNumberAddMod(C, C, C, FFiniteFieldSize) then     // C = 2*Z1^2
        Exit;

      if not BigNumberAddMod(H, A, B, FFiniteFieldSize) then     // H = A+B
        Exit;

      if not BigNumberAddMod(E, P.X, P.Y, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(E, E, E, FFiniteFieldSize) then
        Exit;
      if not BigNumberSubMod(E, H, E, FFiniteFieldSize) then     // E = H-(X1+Y1)^2
        Exit;

      if not BigNumberSubMod(G, A, B, FFiniteFieldSize) then     // G = A-B
        Exit;

      if not BigNumberAddMod(F, C, G, FFiniteFieldSize) then     // F = C+G
        Exit;

      if not BigNumberDirectMulMod(Sum.X, E, F, FFiniteFieldSize) then // X3 = E*F
        Exit;

      if not BigNumberDirectMulMod(Sum.Y, G, H, FFiniteFieldSize) then // Y3 = G*H
        Exit;

      if not BigNumberDirectMulMod(Sum.T, E, H, FFiniteFieldSize) then // T3 = E*H
        Exit;

      if not BigNumberDirectMulMod(Sum.Z, F, G, FFiniteFieldSize) then // Z3 = F*G
        Exit;

      Result := True;
    end
    else
    begin
      // ����ͬһ���㡣���� G H ����ʱ����
      if not BigNumberSubMod(G, P.Y, P.X, FFiniteFieldSize) then
        Exit;
      if not BigNumberSubMod(H, Q.Y, Q.X, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(A, G, H, FFiniteFieldSize) then // A = (Y1-X1)*(Y2-X2)
        Exit;

      if not BigNumberAddMod(G, P.Y, P.X, FFiniteFieldSize) then
        Exit;
      if not BigNumberAddMod(H, Q.Y, Q.X, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(B, G, H, FFiniteFieldSize) then  // B = (Y1+X1)*(Y2+X2)
        Exit;

      if not BigNumberAdd(C, FCoefficientD, FCoefficientD) then
        Exit;
      if not BigNumberDirectMulMod(C, P.T, C, FFiniteFieldSize) then
        Exit;
      if not BigNumberDirectMulMod(C, Q.T, C, FFiniteFieldSize) then  // C = T1*2*d*T2
        Exit;

      if not BigNumberAdd(D, P.Z, P.Z) then
        Exit;
      if not BigNumberDirectMulMod(D, Q.Z, D, FFiniteFieldSize) then  // D = Z1*2*Z2
        Exit;

      if not BigNumberSubMod(E, B, A, FFiniteFieldSize) then  // E = B-A
        Exit;

      if not BigNumberSubMod(F, D, C, FFiniteFieldSize) then  // F = D-C
        Exit;

      if not BigNumberAddMod(G, D, C, FFiniteFieldSize) then  // G = D+C
        Exit;
      if not BigNumberAddMod(H, B, A, FFiniteFieldSize) then  // H = B+A
        Exit;

      if not BigNumberDirectMulMod(Sum.X, E, F, FFiniteFieldSize) then  // X3 = E*F
        Exit;

      if not BigNumberDirectMulMod(Sum.Y, G, H, FFiniteFieldSize) then  // Y3 = G*H
        Exit;

      if not BigNumberDirectMulMod(Sum.T, E, H, FFiniteFieldSize) then  // T3 = E*H
        Exit;

      if not BigNumberDirectMulMod(Sum.Z, F, G, FFiniteFieldSize) then  // Z3 = F*G
        Exit;

      Result := True;
    end;
  finally
    F25519BigNumberPool.Recycle(H);
    F25519BigNumberPool.Recycle(G);
    F25519BigNumberPool.Recycle(F);
    F25519BigNumberPool.Recycle(E);
    F25519BigNumberPool.Recycle(D);
    F25519BigNumberPool.Recycle(C);
    F25519BigNumberPool.Recycle(B);
    F25519BigNumberPool.Recycle(A);
  end;
end;

procedure TCnEd25519.ExtendedPointInverse(P: TCnEcc4Point);
var
  T: TCnBigNumber;
begin
  T := F25519BigNumberPool.Obtain;
  try
    BigNumberDirectMulMod(T, P.Z, FFiniteFieldSize, FFiniteFieldSize);
    BigNumberSubMod(P.X, T, P.X, FFiniteFieldSize);

    // T := X * Y / Z^3
    BigNumberPowerWordMod(T, P.Z, 3, FFiniteFieldSize);
    BigNumberModularInverse(T, T, FFiniteFieldSize); // T �� Z^3 ����Ԫ
    BigNumberDirectMulMod(P.T, P.X, P.Y, FFiniteFieldSize);
    BigNumberDirectMulMod(P.T, P.T, T, FFiniteFieldSize);
  finally
    F25519BigNumberPool.Recycle(T);
  end;
end;

function TCnEd25519.ExtendedPointSubPoint(P, Q,
  Diff: TCnEcc4Point): Boolean;
var
  Inv: TCnEcc4Point;
begin
  Inv := TCnEcc4Point.Create;
  try
    Inv.Assign(Q);
    ExtendedPointInverse(Inv);
    Result := ExtendedPointAddPoint(P, Inv, Diff);
  finally
    Inv.Free;
  end;
end;

function TCnEd25519.GenerateKeys(PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey): Boolean;
var
  K: TCnBigNumber;
begin
  Result := False;

  // ��� 32 �ֽ��� PrivateKey
  if not BigNumberRandBytes(PrivateKey, CN_25519_BLOCK_BYTESIZE) then
    Exit;

  K := F25519BigNumberPool.Obtain;
  try

    if not CalcBigNumbersFromPrivateKey(PrivateKey, CN_25519_BLOCK_BYTESIZE,
      K, nil) then
      Exit;

    // �ó��� K ���� G ��õ���Կ
    PublicKey.Assign(FGenerator);
    MultiplePoint(K, PublicKey);                         // ����� K ��

    Result := True;
  finally
    F25519BigNumberPool.Recycle(K);
  end;
end;

function CnEcc4PointToString(const P: TCnEcc4Point): string;
begin
  Result := Format('%s,%s,%s,%s', [P.X.ToDec, P.Y.ToDec, P.Z.ToDec, P.T.ToDec]);
end;

function CnEcc4PointToHex(const P: TCnEcc4Point): string;
begin
  Result := Format('%s,%s,%s,%s', [P.X.ToHex, P.Y.ToHex, P.Z.ToHex, P.T.ToHex]);
end;

function CnEcc4PointEqual(const P, Q: TCnEcc4Point; Prime: TCnBigNumber): Boolean;
var
  T1, T2: TCnBigNumber;
begin
  // X1Z2 = X2Z1 �� Y1Z2 = Y2Z1
  Result := False;
  if P = Q then
  begin
    Result := True;
    Exit;
  end;

  T1 := nil;
  T2 := nil;

  try
    T1 := F25519BigNumberPool.Obtain;
    T2 := F25519BigNumberPool.Obtain;

    BigNumberDirectMulMod(T1, P.X, Q.Z, Prime);
    BigNumberDirectMulMod(T2, Q.X, P.Z, Prime);

    if not BigNumberEqual(T1, T2) then
      Exit;

    BigNumberDirectMulMod(T1, P.Y, Q.Z, Prime);
    BigNumberDirectMulMod(T2, Q.Y, P.Z, Prime);

    if not BigNumberEqual(T1, T2) then
      Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(T2);
    F25519BigNumberPool.Recycle(T1);
  end;
end;

function CnEccPointToEcc4Point(P: TCnEccPoint; P4: TCnEcc4Point; Prime: TCnBigNumber): Boolean;
begin
  Result := False;
  if not CnEccPointToEcc3Point(P, P4) then
    Exit;
  Result := BigNumberDirectMulMod(P4.T, P.X, P.Y, Prime);
end;

function CnEcc4PointToEccPoint(P4: TCnEcc4Point; P: TCnEccPoint; Prime: TCnBigNumber): Boolean;
begin
  Result := CnAffinePointToEccPoint(P4, P, Prime);
end;

// =============================================================================
//
//          Curve25519 �� u v �� Ed25519 �� x y ��˫��ӳ���ϵΪ��
//
//              (u, v) = ((1+y)/(1-y), sqrt(-486664)*u/x)
//              (x, y) = (sqrt(-486664)*u/v, (u-1)/(u+1))
//
// =============================================================================

function CnCurve25519PointToEd25519Point(DestPoint, SourcePoint: TCnEccPoint): Boolean;
var
  S, T, Inv, Prime: TCnBigNumber;
begin
  // x = sqrt(-486664)*u/v
  // y = (u-1)/(u+1)
  Result := False;

  S := nil;
  T := nil;
  Prime := nil;
  Inv := nil;

  try
    S := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;

    S.SetHex(SCN_25519_SQRT_NEG_486664);
    Prime := F25519BigNumberPool.Obtain;
    Prime.SetHex(SCN_25519_PRIME);

    if not BigNumberDirectMulMod(T, S, SourcePoint.X, Prime) then // sqrt * u
      Exit;

    Inv := F25519BigNumberPool.Obtain;
    if not BigNumberModularInverse(Inv, SourcePoint.Y, Prime) then // v^-1
      Exit;

    if not BigNumberDirectMulMod(DestPoint.X, T, Inv, Prime) then // �㵽 X
      Exit;

    if BigNumberCopy(T, SourcePoint.X) = nil then
      Exit;
    if BigNumberCopy(S, SourcePoint.X) = nil then
      Exit;

    T.SubWord(1);  // u - 1
    S.AddWord(1);  // u + 1

    if not BigNumberModularInverse(Inv, S, Prime) then // (u + 1)^1
      Exit;
    if not BigNumberDirectMulMod(DestPoint.Y, T, Inv, Prime) then
      Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(Inv);
    F25519BigNumberPool.Recycle(Prime);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(S);
  end;
end;

function CnEd25519PointToCurve25519Point(DestPoint, SourcePoint: TCnEccPoint): Boolean;
var
  S, T, Inv, Prime: TCnBigNumber;
begin
  // u = (1+y)/(1-y)
  // v = sqrt(-486664)*u/x
  Result := False;

  S := nil;
  T := nil;
  Prime := nil;
  Inv := nil;

  try
    S := F25519BigNumberPool.Obtain;
    T := F25519BigNumberPool.Obtain;

    if BigNumberCopy(T, SourcePoint.Y) = nil then
      Exit;
    if BigNumberCopy(S, SourcePoint.Y) = nil then
      Exit;
    T.AddWord(1);  // T �Ƿ��� 1+y

    Prime := F25519BigNumberPool.Obtain;
    Prime.SetHex(SCN_25519_PRIME);

    if not BigNumberSubMod(S, CnBigNumberOne, SourcePoint.Y, Prime) then
      Exit;        // S �Ƿ�ĸ 1-y

    Inv := F25519BigNumberPool.Obtain;
    if not BigNumberModularInverse(Inv, S, Prime) then // Inv �Ƿ�ĸ����������
      Exit;

    if not BigNumberDirectMulMod(DestPoint.X, T, Inv, Prime) then // �õ� U
      Exit;

    S.SetHex(SCN_25519_SQRT_NEG_486664);
    if not BigNumberDirectMulMod(T, S, DestPoint.X, Prime) then
      Exit;

    if not BigNumberModularInverse(Inv, SourcePoint.X, Prime) then
      Exit;

    if not BigNumberDirectMulMod(DestPoint.Y, T, Inv, Prime) then
      Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(Inv);
    F25519BigNumberPool.Recycle(Prime);
    F25519BigNumberPool.Recycle(T);
    F25519BigNumberPool.Recycle(S);
  end;
end;

function CnEd25519PointToData(P: TCnEccPoint; var Data: TCnEd25519Data): Boolean;
begin
  Result := False;
  if P = nil then
    Exit;

  FillChar(Data[0], SizeOf(TCnEd25519Data), 0);
  P.Y.ToBinary(@Data[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@Data[0], SizeOf(TCnEd25519Data)); // С������Ҫ��һ��

  if P.X.IsOdd then // X �����������λ�� 1
    Data[CN_25519_BLOCK_BYTESIZE - 1] := Data[CN_25519_BLOCK_BYTESIZE - 1] or $80  // ��λ�� 1
  else
    Data[CN_25519_BLOCK_BYTESIZE - 1] := Data[CN_25519_BLOCK_BYTESIZE - 1] and $7F; // ��λ�� 0

  Result := True;
end;

function CnEd25519DataToPoint(Data: TCnEd25519Data; P: TCnEccPoint;
  out XOdd: Boolean): Boolean;
var
  D: TCnEd25519Data;
begin
  Result := False;
  if P = nil then
    Exit;

  Move(Data[0], D[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@D[0], SizeOf(TCnEd25519Data));
  P.Y.SetBinary(@D[0], SizeOf(TCnEd25519Data));

  // ���λ�Ƿ��� 0 ��ʾ�� X ����ż
  XOdd := P.Y.IsBitSet(8 * CN_25519_BLOCK_BYTESIZE - 1);

  // ���λ������
  P.Y.ClearBit(8 * CN_25519_BLOCK_BYTESIZE - 1);
  Result := True;
end;

function CnEd25519BigNumberToData(N: TCnBigNumber; var Data: TCnEd25519Data): Boolean;
begin
  Result := False;
  if (N = nil) or (N.GetBytesCount > SizeOf(TCnEd25519Data)) then
    Exit;

  FillChar(Data[0], SizeOf(TCnEd25519Data), 0);
  N.ToBinary(@Data[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@Data[0], SizeOf(TCnEd25519Data));
  Result := True;
end;

function CnEd25519DataToBigNumber(Data: TCnEd25519Data; N: TCnBigNumber): Boolean;
var
  D: TCnEd25519Data;
begin
  Result := False;
  if N = nil then
    Exit;

  Move(Data[0], D[0], SizeOf(TCnEd25519Data));
  ReverseMemory(@D[0], SizeOf(TCnEd25519Data));
  N.SetBinary(@D[0], SizeOf(TCnEd25519Data));
  Result := True;
end;

function CnEd25519SignData(PlainData: Pointer; DataLen: Integer; PrivateKey: TCnEccPrivateKey;
  PublicKey: TCnEccPublicKey; OutSignature: TCnEd25519Signature; Ed25519: TCnEd25519): Boolean;
var
  Is25519Nil: Boolean;
  Stream: TMemoryStream;
  R, S, K, HP: TCnBigNumber;
  Dig: TSHA512Digest;
  Data: TCnEd25519Data;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (PrivateKey = nil) or (PublicKey = nil)
    or (OutSignature = nil) then
    Exit;

  R := nil;
  S := nil;
  K := nil;
  HP := nil;
  Stream := nil;
  Is25519Nil := Ed25519 = nil;

  try
    if Is25519Nil then
      Ed25519 := TCnEd25519.Create;

    R := F25519BigNumberPool.Obtain;
    S := F25519BigNumberPool.Obtain;
    K := F25519BigNumberPool.Obtain;
    HP := F25519BigNumberPool.Obtain;

    // ����˽Կ�õ�˽Կ���� s ���Ӵ�ǰ׺
    if not CalcBigNumbersFromPrivateKey(PrivateKey, CN_25519_BLOCK_BYTESIZE, S, HP) then
      Exit;

    // �Ӵ�ǰ׺ƴ��ԭʼ����
    Stream := TMemoryStream.Create;
    BigNumberWriteBinaryToStream(HP, Stream, CN_25519_BLOCK_BYTESIZE);
    Stream.Write(PlainData^, DataLen);

    // ����� SHA512 ֵ��Ϊ r ������׼�����Ի�����Ϊ R ��
    Dig := SHA512Buffer(Stream.Memory, Stream.Size);

    ReverseMemory(@Dig[0], SizeOf(TSHA512Digest)); // ��Ҫ��תһ��
    R.SetBinary(@Dig[0], SizeOf(TSHA512Digest));
    if not BigNumberNonNegativeMod(R, R, Ed25519.Order) then // r ����̫���� mod һ�½�
      Exit;

    OutSignature.R.Assign(Ed25519.Generator);
    Ed25519.MultiplePoint(R, OutSignature.R);      // ����õ�ǩ��ֵ R����ֵ��һ��������

    // �� Hash ���� S���ȵ� R ת��Ϊ�ֽ�����
    if not Ed25519.PointToPlain(OutSignature.R, Data) then
      Exit;

    // ƴ����
    Stream.Clear;
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));

    // ��Կ��Ҳת��Ϊ�ֽ�����
    if not Ed25519.PointToPlain(PublicKey, Data) then
      Exit;
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));

    // д���ģ�ƴ�����
    Stream.Write(PlainData^, DataLen);

    // �ٴ��Ӵ� R||PublicKey||����
    Dig := SHA512Buffer(Stream.Memory, Stream.Size);

    ReverseMemory(@Dig[0], SizeOf(TSHA512Digest)); // ����Ҫ��תһ��
    K.SetBinary(@Dig[0], SizeOf(TSHA512Digest));
    if not BigNumberNonNegativeMod(K, K, Ed25519.Order) then // ����̫������ mod һ�½�
      Exit;

    // ������� R + K * S mod Order
    if not BigNumberDirectMulMod(OutSignature.S, K, S, Ed25519.Order) then
      Exit;
    if not BigNumberAddMod(OutSignature.S, R, OutSignature.S, Ed25519.Order) then
      Exit;

    Result := True;
  finally
    Stream.Free;
    F25519BigNumberPool.Recycle(HP);
    F25519BigNumberPool.Recycle(K);
    F25519BigNumberPool.Recycle(S);
    F25519BigNumberPool.Recycle(R);
    if Is25519Nil then
      Ed25519.Free;
  end;
end;

function CnEd25519VerifyData(PlainData: Pointer; DataLen: Integer; InSignature: TCnEd25519Signature;
  PublicKey: TCnEccPublicKey; Ed25519: TCnEd25519): Boolean;
var
  Is25519Nil: Boolean;
  L, R, M: TCnEccPoint;
  T: TCnBigNumber;
  Stream: TMemoryStream;
  Data: TCnEd25519Data;
  Dig: TSHA512Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (PublicKey = nil) or (InSignature = nil) then
    Exit;

  L := nil;
  R := nil;
  Stream := nil;
  T := nil;
  M := nil;
  Is25519Nil := Ed25519 = nil;

  try
    if Is25519Nil then
      Ed25519 := TCnEd25519.Create;

    // ��֤ 8*S*���� �Ƿ� = 8*R�� + 8*Hash(R32λ||��Կ��32λ||����) * ��Կ��
    L := TCnEccPoint.Create;
    R := TCnEccPoint.Create;

    L.Assign(Ed25519.Generator);
    Ed25519.MultiplePoint(InSignature.S, L);
    Ed25519.MultiplePoint(8, L);  // �㵽��ߵ�

    R.Assign(InSignature.R);
    Ed25519.MultiplePoint(8, R);  // �㵽 8*R�����

    Stream := TMemoryStream.Create;
    if not CnEd25519PointToData(InSignature.R, Data) then
      Exit;
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));        // ƴ R ��
    if not CnEd25519PointToData(PublicKey, Data) then
      Exit;
    Stream.Write(Data[0], SizeOf(TCnEd25519Data));        // ƴ��Կ��
    Stream.Write(PlainData^, DataLen);                    // ƴ����

    Dig := SHA512Buffer(Stream.Memory, Stream.Size);      // ���� Hash ��Ϊֵ
    ReverseMemory(@Dig[0], SizeOf(TSHA512Digest));        // ��Ҫ��תһ��

    T := F25519BigNumberPool.Obtain;
    T.SetBinary(@Dig[0], SizeOf(TSHA512Digest));
    T.MulWord(8);
    if not BigNumberNonNegativeMod(T, T, Ed25519.Order) then // T ����̫���� mod һ�½�
      Exit;

    M := TCnEccPoint.Create;
    M.Assign(PublicKey);
    Ed25519.MultiplePoint(T, M);      // T �˹�Կ��
    Ed25519.PointAddPoint(R, M, R);   // ���

    Result := CnEccPointsEqual(L, R);
  finally
    M.Free;
    F25519BigNumberPool.Recycle(T);
    Stream.Free;
    R.Free;
    L.Free;
    if Is25519Nil then
      Ed25519.Free;
  end;
end;

function CnCurve25519KeyExchangeStep1(SelfPrivateKey: TCnEccPrivateKey;
  OutPointToAnother: TCnEccPoint; Curve25519: TCnCurve25519): Boolean;
var
  Is25519Nil: Boolean;
begin
  Result := False;
  if (SelfPrivateKey = nil) or (OutPointToAnother = nil) then
    Exit;

  Is25519Nil := Curve25519 = nil;

  try
    if Is25519Nil then
      Curve25519 := TCnCurve25519.Create;

    OutPointToAnother.Assign(Curve25519.Generator);
    Curve25519.MultiplePoint(SelfPrivateKey, OutPointToAnother);

    Result := True;
  finally
    if Is25519Nil then
      Curve25519.Free;
  end;
end;

function CnCurve25519KeyExchangeStep2(SelfPrivateKey: TCnEccPrivateKey;
  InPointFromAnother: TCnEccPoint; OutKey: TCnEccPoint; Curve25519: TCnCurve25519): Boolean;
var
  Is25519Nil: Boolean;
begin
  Result := False;
  if (SelfPrivateKey = nil) or (InPointFromAnother = nil) or (OutKey = nil) then
    Exit;

  Is25519Nil := Curve25519 = nil;

  try
    if Is25519Nil then
      Curve25519 := TCnCurve25519.Create;

    OutKey.Assign(InPointFromAnother);
    Curve25519.MultiplePoint(SelfPrivateKey, OutKey);

    Result := True;
  finally
    if Is25519Nil then
      Curve25519.Free;
  end;
end;

function TCnEd25519.IsExtendedPointOnCurve(P: TCnEcc4Point): Boolean;
var
  Q: TCnEccPoint;
begin
  Q := TCnEccPoint.Create;
  try
    CnEcc4PointToEccPoint(P, Q, FFiniteFieldSize);
    Result := IsPointOnCurve(Q);
  finally
    Q.Free;
  end;
end;

function TCnEd25519.IsNeutualExtendedPoint(P: TCnEcc4Point): Boolean;
begin
  Result := P.X.IsZero and P.T.IsZero and not P.Y.IsZero and not P.Z.IsZero
    and BigNumberEqual(P.Y, P.Z);
end;

procedure TCnEd25519.MultiplePoint(K: TCnBigNumber; Point: TCnEccPoint);
var
  P4: TCnEcc4Point;
begin
  P4 := TCnEcc4Point.Create;
  try
    CnEccPointToEcc4Point(Point, P4, FFiniteFieldSize);
    ExtendedMultiplePoint(K, P4);
    CnEcc4PointToEccPoint(P4, Point, FFiniteFieldSize);
  finally
    P4.Free;
  end;
end;

function TCnEd25519.PlainToPoint(Plain: TCnEd25519Data;
  OutPoint: TCnEccPoint): Boolean;
var
  XOdd: Boolean;
  T, Y, Inv: TCnBigNumber;
begin
  Result := False;
  if OutPoint = nil then
    Exit;

  // �ȴ� Plain �л�ԭ Y �����Լ� X �����ż��
  if not CnEd25519DataToPoint(Plain, OutPoint, XOdd) then
    Exit;

  // �õ� Y ����� x �ķ��� x^2 = (Y^2 - 1) / (D*Y^2 + 1) mod P
  // ע������ 25519 �� 8u5 ����ʽ

  T := nil;
  Y := nil;
  Inv := nil;

  try
    T := F25519BigNumberPool.Obtain;
    Y := F25519BigNumberPool.Obtain;

    if not BigNumberDirectMulMod(Y, OutPoint.Y, OutPoint.Y, FFiniteFieldSize) then
      Exit;
    Y.SubWord(1); // Y := Y^2 - 1

    if not BigNumberDirectMulMod(T, OutPoint.Y, OutPoint.Y, FFiniteFieldSize) then
      Exit;
    if not BigNumberDirectMulMod(T, T, FCoefficientD, FFiniteFieldSize) then
      Exit;
    T.AddWord(1); // T := D*Y^2 + 1

    Inv := F25519BigNumberPool.Obtain;
    if not BigNumberModularInverse(Inv, T, FFiniteFieldSize) then
      Exit;

    if not BigNumberDirectMulMod(Y, Y, Inv, FFiniteFieldSize) then // Y �õ������ұߵ�ֵ
      Exit;

    if not BigNumberSquareRootModPrime(OutPoint.X, Y, FFiniteFieldSize) then
      Exit;

    // ��� X ��
    if OutPoint.X.IsBitSet(0) <> XOdd then
      if BigNumberSub(OutPoint.X, FFiniteFieldSize, OutPoint.X) then
        Exit;

    Result := True;
  finally
    F25519BigNumberPool.Recycle(Inv);
    F25519BigNumberPool.Recycle(Y);
    F25519BigNumberPool.Recycle(T);
  end;
end;

function TCnEd25519.PointToPlain(Point: TCnEccPoint;
  var OutPlain: TCnEd25519Data): Boolean;
begin
  Result := False;
  if (Point = nil) or (BigNumberCompare(Point.Y, FFiniteFieldSize) >= 0) then
    Exit;

  Result := CnEd25519PointToData(Point, OutPlain);
end;

procedure TCnEd25519.SetNeutualExtendedPoint(P: TCnEcc4Point);
begin
  P.X.SetZero;
  P.Y.SetOne;
  P.Z.SetOne;
  P.T.SetZero;
end;

{ TCnEd25519Sigature }

procedure TCnEd25519Signature.Assign(Source: TPersistent);
begin
  if Source is TCnEd25519Signature then
  begin
    FR.Assign((Source as TCnEd25519Signature).R);
    BigNumberCopy(FS, (Source as TCnEd25519Signature).S);
  end
  else
    inherited;
end;

constructor TCnEd25519Signature.Create;
begin
  inherited;
  FR := TCnEccPoint.Create;
  FS := TCnBigNumber.Create;
end;

destructor TCnEd25519Signature.Destroy;
begin
  FS.Free;
  FR.Free;
  inherited;
end;

{ TCnEcc4Point }

procedure TCnEcc4Point.Assign(Source: TPersistent);
begin
  if Source is TCnEcc4Point then
    BigNumberCopy(FT, (Source as TCnEcc4Point).T);
  inherited;
end;

constructor TCnEcc4Point.Create;
begin
  inherited;
  FT := TCnBigNumber.Create;
end;

destructor TCnEcc4Point.Destroy;
begin
  FT.Free;
  inherited;
end;

procedure TCnEcc4Point.SetT(const Value: TCnBigNumber);
begin
  BigNumberCopy(FT, Value);
end;

function TCnEcc4Point.ToString: string;
begin
  Result := CnEcc4PointToHex(Self);
end;

procedure TCnEd25519Signature.LoadFromData(Sig: TCnEd25519SignatureData);
var
  Data: TCnEd25519Data;
  Ed25519: TCnEd25519;
begin
  Move(Sig[0], Data[0], SizeOf(TCnEd25519Data));

  // �� Data �м��� R ��
  Ed25519 := TCnEd25519.Create;
  try
    Ed25519.PlainToPoint(Data, FR);
  finally
    Ed25519.Free;
  end;

  Move(Sig[SizeOf(TCnEd25519Data)], Data[0], SizeOf(TCnEd25519Data));
  // �� Data �м��� S ��
  CnEd25519DataToBigNumber(Data, FS);
end;

procedure TCnEd25519Signature.SaveToData(var Sig: TCnEd25519SignatureData);
var
  Data: TCnEd25519Data;
begin
  FillChar(Sig[0], SizeOf(TCnEd25519SignatureData), 0);

  // �� R ��д�� Data
  CnEd25519PointToData(FR, Data);
  Move(Data[0], Sig[0], SizeOf(TCnEd25519Data));

  // �� S ��д�� Data
  CnEd25519BigNumberToData(FS, Data);
  Move(Data[0], Sig[SizeOf(TCnEd25519Data)], SizeOf(TCnEd25519Data));
end;

initialization
  F25519BigNumberPool := TCnBigNumberPool.Create;

finalization
  F25519BigNumberPool.Free;

end.
