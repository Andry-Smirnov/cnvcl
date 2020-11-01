{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
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

unit CnPolynomial;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�����ʽ����ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע��֧����ͨ����ϵ������ʽ�������㣬����ֻ֧�ֳ�����ߴ���Ϊ 1 �����
*           ֧����������Χ�ڵĶ���ʽ�������㣬ϵ���� mod p ���ҽ���Ա�ԭ����ʽ����
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.10.20 V1.2
*               ʵ������������ Int64 ��Χ�ڵ������ʽ��������
*           2020.08.28 V1.1
*               ʵ������������ Int64 ��Χ�ڵĶ���ʽ�������㣬�����Ա�ԭ����ʽ�����ģ��Ԫ
*           2020.08.21 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, SysConst, Math, Contnrs, CnPrimeNumber, CnNativeDecl,
  CnMatrix, CnBigNumber;

type
  ECnPolynomialException = class(Exception);

// =============================================================================
//
//                         ��ϵ������ʽ�������ʽ
//
// =============================================================================

  TCnInt64Polynomial = class(TCnInt64List)
  {* ��ϵ������ʽ��ϵ����ΧΪ Int64}
  private
    function GetMaxDegree: Integer;
    procedure SetMaxDegree(const Value: Integer);
  public
    constructor Create(LowToHighCoefficients: array of const); overload;
    {* ���캯��������Ϊ�ӵ͵��ߵ�ϵ����ע��ϵ����ʼ��ʱ���� MaxInt32/MaxInt64 �Ļᱻ���� Integer/Int64 ���为}
    constructor Create; overload;
    destructor Destroy; override;

    procedure SetCoefficents(LowToHighCoefficients: array of const);
    {* һ���������ôӵ͵��ߵ�ϵ��}
    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    function IsOne: Boolean;
    {* �����Ƿ�Ϊ 1}
    procedure SetOne;
    {* ��Ϊ 1}
    function IsNegOne: Boolean;
    {* �����Ƿ�Ϊ -1}
    procedure Negate;
    {* ����ϵ����}
    property MaxDegree: Integer read GetMaxDegree write SetMaxDegree;
    {* ��ߴ�����0 ��ʼ������ Count ����ֻ���� Integer}
  end;

  TCnInt64RationalPolynomial = class(TPersistent)
  {* ��ϵ����ʽ����ĸ���ӷֱ�Ϊ��ϵ������ʽ}
  private
    FNominator: TCnInt64Polynomial;
    FDenominator: TCnInt64Polynomial;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsInt: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�������ʽ��Ҳ�����жϷ�ĸ�Ƿ������� 1}
    function IsZero: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 0}
    function IsOne: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 1}
    procedure Reciprocal;
    {* ��ɵ���}
    procedure Neg;
    {* ��ɸ���}
    procedure SetZero;
    {* ��Ϊ 0}
    procedure SetOne;
    {* ��Ϊ 1}
    procedure Reduce;
    {* Լ��}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ַ���}

    property Nominator: TCnInt64Polynomial read FNominator;
    {* ����ʽ}
    property Denominator: TCnInt64Polynomial read FDenominator;
    {* ��ĸʽ}
  end;

  TCnInt64PolynomialPool = class(TObjectList)
  {* ��ϵ������ʽ��ʵ���࣬����ʹ�õ������ĵط����д���������}
  private
{$IFDEF MULTI_THREAD}
  {$IFDEF MSWINDOWS}
    FCriticalSection: TRTLCriticalSection;
  {$ELSE}
    FCriticalSection: TCriticalSection;
  {$ENDIF}
{$ENDIF}
    procedure Enter; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    procedure Leave; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    function Obtain: TCnInt64Polynomial;
    procedure Recycle(Poly: TCnInt64Polynomial);
  end;

// =============================================================================
//
//                       ����ϵ������ʽ�������ʽ
//
// =============================================================================

  TCnBigNumberPolynomial = class(TCnBigNumberList)
  {* ����ϵ������ʽ}
  private
    function GetMaxDegree: Integer;
    procedure SetMaxDegree(const Value: Integer);
  public
    constructor Create(LowToHighCoefficients: array of const); overload;
    {* ���캯��������Ϊ�ӵ͵��ߵ�ϵ����ע��ϵ����ʼ��ʱ���� MaxInt32/MaxInt64 �Ļᱻ���� Integer/Int64 ���为}
    constructor Create; overload;
    destructor Destroy; override;

    procedure SetCoefficents(LowToHighCoefficients: array of const);
    {* һ���������ôӵ͵��ߵ�ϵ��}
    procedure CorrectTop;
    {* �޳��ߴε� 0 ϵ��}
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ʽת���ַ���}
    function IsZero: Boolean;
    {* �����Ƿ�Ϊ 0}
    procedure SetZero;
    {* ��Ϊ 0}
    function IsOne: Boolean;
    {* �����Ƿ�Ϊ 1}
    procedure SetOne;
    {* ��Ϊ 1}
    function IsNegOne: Boolean;
    {* �����Ƿ�Ϊ -1}
    procedure Negate;
    {* ����ϵ����}
    property MaxDegree: Integer read GetMaxDegree write SetMaxDegree;
    {* ��ߴ�����0 ��ʼ}
  end;

  TCnBigNumberRationalPolynomial = class(TPersistent)
  {* ����ϵ����ʽ����ĸ���ӷֱ�Ϊ����ϵ������ʽ}
  private
    FNominator: TCnBigNumberPolynomial;
    FDenominator: TCnBigNumberPolynomial;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsInt: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�������ʽ��Ҳ�����жϷ�ĸ�Ƿ������� 1}
    function IsZero: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 0}
    function IsOne: Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    {* �Ƿ�Ϊ 1}
    procedure Reciprocal;
    {* ��ɵ���}
    procedure Neg;
    {* ��ɸ���}
    procedure SetZero;
    {* ��Ϊ 0}
    procedure SetOne;
    {* ��Ϊ 1}
    procedure Reduce;
    {* Լ��}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ַ���}

    property Nominator: TCnBigNumberPolynomial read FNominator;
    {* ����ʽ}
    property Denominator: TCnBigNumberPolynomial read FDenominator;
    {* ��ĸʽ}
  end;

  TCnBigNumberPolynomialPool = class(TObjectList)
  {* ����ϵ������ʽ��ʵ���࣬����ʹ�õ�������ϵ������ʽ�ĵط����д���������}
  private
{$IFDEF MULTI_THREAD}
  {$IFDEF MSWINDOWS}
    FCriticalSection: TRTLCriticalSection;
  {$ELSE}
    FCriticalSection: TCriticalSection;
  {$ENDIF}
{$ENDIF}
    procedure Enter; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    procedure Leave; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    function Obtain: TCnBigNumberPolynomial;
    procedure Recycle(Poly: TCnBigNumberPolynomial);
  end;

// ======================== ��ϵ������ʽ�������� ===============================

function Int64PolynomialNew: TCnInt64Polynomial;
{* ����һ����̬�������ϵ������ʽ���󣬵�ͬ�� TCnInt64Polynomial.Create}

procedure Int64PolynomialFree(const P: TCnInt64Polynomial);
{* �ͷ�һ����ϵ������ʽ���󣬵�ͬ�� TCnInt64Polynomial.Free}

function Int64PolynomialDuplicate(const P: TCnInt64Polynomial): TCnInt64Polynomial;
{* ��һ����ϵ������ʽ�����¡һ���¶���}

function Int64PolynomialCopy(const Dst: TCnInt64Polynomial;
  const Src: TCnInt64Polynomial): TCnInt64Polynomial;
{* ����һ����ϵ������ʽ���󣬳ɹ����� Dst}

function Int64PolynomialToString(const P: TCnInt64Polynomial;
  const VarName: string = 'X'): string;
{* ��һ����ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X ��ʾ}

function Int64PolynomialIsZero(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ����ϵ������ʽ�����Ƿ�Ϊ 0}

procedure Int64PolynomialSetZero(const P: TCnInt64Polynomial);
{* ��һ����ϵ������ʽ������Ϊ 0}

function Int64PolynomialIsOne(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ����ϵ������ʽ�����Ƿ�Ϊ 1}

procedure Int64PolynomialSetOne(const P: TCnInt64Polynomial);
{* ��һ����ϵ������ʽ������Ϊ 1}

function Int64PolynomialIsNegOne(const P: TCnInt64Polynomial): Boolean;
{* �ж�һ����ϵ������ʽ�����Ƿ�Ϊ -1}

procedure Int64PolynomialNegate(const P: TCnInt64Polynomial);
{* ��һ����ϵ������ʽ��������ϵ����}

procedure Int64PolynomialShiftLeft(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N}

procedure Int64PolynomialShiftRight(const P: TCnInt64Polynomial; N: Integer);
{* ��һ����ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N��С�� 0 �ĺ�����}

function Int64PolynomialEqual(const A, B: TCnInt64Polynomial): Boolean;
{* �ж�����ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// =========================== ����ʽ��ͨ���� ==================================

procedure Int64PolynomialAddWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ����ϵ������ʽ����ĳ�ϵ������ N}

procedure Int64PolynomialSubWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ����ϵ������ʽ����ĳ�ϵ����ȥ N}

procedure Int64PolynomialMulWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ����ϵ������ʽ����ĸ���ϵ�������� N}

procedure Int64PolynomialDivWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ����ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure Int64PolynomialNonNegativeModWord(const P: TCnInt64Polynomial; N: Int64);
{* ��һ����ϵ������ʽ����ĸ���ϵ������ N �Ǹ�����}

function Int64PolynomialAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialDiv(const Res: TCnInt64Polynomial; const Remain: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; const Divisor: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ����������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64PolynomialMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial): Boolean;
{* ������ϵ������ʽ�������࣬�������� Res �У����������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ��
   Res ������ P �� Divisor��P ������ Divisor}

function Int64PolynomialPower(const Res: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; Exponent: Int64): Boolean;
{* ������ϵ������ʽ�� Exponent ���ݣ�������ϵ����������⣬
   ���ؼ����Ƿ�ɹ���Res ������ P}

function Int64PolynomialReduce(const P: TCnInt64Polynomial): Integer;
{* �������ʽϵ����Ҳ�����Ҷ���ʽϵ�������Լ��������ϵ�����������������Լ��}

function Int64PolynomialGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
{* ����������ϵ������ʽ�������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ������ʽΪ 1}

function Int64PolynomialLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
{* ����������ϵ������ʽ����С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ���С����ʽΪ������ˣ����н���}

function Int64PolynomialCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial): Boolean;
{* ��ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function Int64PolynomialGetValue(const F: TCnInt64Polynomial; X: Int64): Int64;
{* ��ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ�����}

procedure Int64PolynomialReduce2(P1, P2: TCnInt64Polynomial);
{* ���������ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ===================== ���������µ���ϵ������ʽģ���� ========================

function Int64PolynomialGaloisEqual(const A, B: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ������ϵ������ʽ��ģ Prime ���������Ƿ����}

procedure Int64PolynomialGaloisNegate(const P: TCnInt64Polynomial; Prime: Int64);
{* ��һ����ϵ������ʽ��������ϵ����ģ Prime ����������}

function Int64PolynomialGaloisAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function Int64PolynomialGaloisDiv(const Res: TCnInt64Polynomial;
  const Remain: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function Int64PolynomialGaloisMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* ������ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function Int64PolynomialGaloisPower(const Res, P: TCnInt64Polynomial;
  Exponent: Int64; Prime: Int64; Primitive: TCnInt64Polynomial = nil;
  ExponentHi: Int64 = 0): Boolean;
{* ������ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�Exponent ������ 128 λ��
   Exponent ������������Ǹ�ֵ���Զ�ת�� UInt64
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function Int64PolynomialGaloisAddWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ�ĳ�ϵ������ N �� mod Prime}

function Int64PolynomialGaloisSubWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ�ĳ�ϵ����ȥ N �� mod Prime}

function Int64PolynomialGaloisMulWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ������ N �� mod Prime}

function Int64PolynomialGaloisDivWord(const P: TCnInt64Polynomial; N: Int64; Prime: Int64): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

function Int64PolynomialGaloisMonic(const P: TCnInt64Polynomial; Prime: Int64): Integer;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ��ͬ������ʹ����Ϊһ�����س���ֵ}

function Int64PolynomialGaloisGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ����������ϵ������ʽ�� Prime �η����������ϵ������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

function Int64PolynomialGaloisLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
{* ����������ϵ������ʽ�� Prime �η����������ϵ���С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

procedure Int64PolynomialGaloisExtendedEuclideanGcd(A, B: TCnInt64Polynomial;
  X, Y: TCnInt64Polynomial; Prime: Int64);
{* ��չŷ�����շת������� Prime �η��������������Ԫһ�β�����ϵ������ʽ���� A * X + B * Y = 1 �Ľ�}

procedure Int64PolynomialGaloisModularInverse(const Res: TCnInt64Polynomial;
  X, Modulus: TCnInt64Polynomial; Prime: Int64; CheckGcd: Boolean = False);
{* ����ϵ������ʽ X �� Prime �η�������������� Modulus ��ģ������ʽ���ģ��Ԫ����ʽ Y��
   ���� (X * Y) mod M = 1���������뾡����֤ X��Modulus ���أ��� Res ����Ϊ X �� Modulus
   CheckGcd ����Ϊ True ʱ���ڲ����� X��Modulus �Ƿ���}

function Int64PolynomialGaloisCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* �� Prime �η����������Ͻ�����ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function Int64PolynomialGaloisGetValue(const F: TCnInt64Polynomial; X, Prime: Int64): Int64;
{* �� Prime �η����������Ͻ�����ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ�����}

function Int64PolynomialGaloisCalcDivisionPolynomial(A, B: Int64; Degree: Int64;
  outDivisionPolynomial: TCnInt64Polynomial; Prime: Int64): Boolean;
{* �ݹ����ָ����Բ������ Prime �η����������ϵ� N �׿ɳ�����ʽ�������Ƿ����ɹ�
   ע�� Degree ������ʱ���ɳ�����ʽ�Ǵ� x �Ķ���ʽ��ż��ʱ���ǣ�x �Ķ���ʽ��* y ����ʽ��
   �����ֻ���� x �Ķ���ʽ���֡�
   ����ο��� F. MORAIN �����²����ϳ��� 2 ���Ƶ�����
  ��COMPUTING THE CARDINALITY OF CM ELLIPTIC CURVES USING TORSION POINTS��}

procedure Int64PolynomialGaloisReduce2(P1, P2: TCnInt64Polynomial; Prime: Int64);
{* �� Prime �η��������������������ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ========================== �����ʽ�������� =================================

function Int64RationalPolynomialEqual(R1, R2: TCnInt64RationalPolynomial): Boolean;
{* �Ƚ����������ʽ�Ƿ����}

function Int64RationalPolynomialCopy(const Dst: TCnInt64RationalPolynomial;
  const Src: TCnInt64RationalPolynomial): TCnInt64RationalPolynomial;
{* �����ʽ����}

procedure Int64RationalPolynomialAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ��ͨ�ӷ��������������}

procedure Int64RationalPolynomialSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ��ͨ�����������������}

procedure Int64RationalPolynomialMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ��ͨ�˷��������������}

procedure Int64RationalPolynomialDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ��ͨ�����������������}

procedure Int64RationalPolynomialAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ�ӷ���RationalResult ������ R1}

procedure Int64RationalPolynomialSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

procedure Int64RationalPolynomialMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ�˷���RationalResult ������ R1}

procedure Int64RationalPolynomialDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

procedure Int64RationalPolynomialGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; outResult: TCnRationalNumber);
{* �����ʽ��ֵ��Ҳ���Ǽ��� F(x)����������� outResult ��}

// ====================== �����ʽ���������ϵ�ģ���� ===========================

function Int64RationalPolynomialGaloisEqual(R1, R2: TCnInt64RationalPolynomial;
  Prime: Int64; Primitive: TCnInt64Polynomial = nil): Boolean;
{* �Ƚ�����ģϵ�������ʽ�Ƿ����}

procedure Int64RationalPolynomialGaloisNegate(const P: TCnInt64RationalPolynomial;
  Prime: Int64);
{* ��һ�������ʽ������ӵ�����ϵ����ģ Prime ����������}

procedure Int64RationalPolynomialGaloisAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽģϵ���ӷ��������������}

procedure Int64RationalPolynomialGaloisSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽģϵ�������������������}

procedure Int64RationalPolynomialGaloisMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽģϵ���˷��������������}

procedure Int64RationalPolynomialGaloisDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽģϵ�������������������}

procedure Int64RationalPolynomialGaloisAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽ����ϵ������ʽ��ģϵ���ӷ���RationalResult ������ R1}

procedure Int64RationalPolynomialGaloisSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

procedure Int64RationalPolynomialGaloisMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽ����ϵ������ʽ��ģϵ���˷���RationalResult ������ R1}

procedure Int64RationalPolynomialGaloisDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
{* �����ʽ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

function Int64RationalPolynomialGaloisGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; Prime: Int64): Int64;
{* �����ʽģϵ����ֵ��Ҳ����ģ���� F(x)�������ó˷�ģ��Ԫ��ʾ}

// ======================= ����ϵ������ʽ�������� ==============================

function BigNumberPolynomialNew: TCnBigNumberPolynomial;
{* ����һ����̬����Ĵ���ϵ������ʽ���󣬵�ͬ�� TCnBigNumberPolynomial.Create}

procedure BigNumberPolynomialFree(const P: TCnBigNumberPolynomial);
{* �ͷ�һ������ϵ������ʽ���󣬵�ͬ�� TCnBigNumberPolynomial.Free}

function BigNumberPolynomialDuplicate(const P: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
{* ��һ������ϵ������ʽ�����¡һ���¶���}

function BigNumberPolynomialCopy(const Dst: TCnBigNumberPolynomial;
  const Src: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
{* ����һ������ϵ������ʽ���󣬳ɹ����� Dst}

function BigNumberPolynomialToString(const P: TCnBigNumberPolynomial;
  const VarName: string = 'X'): string;
{* ��һ������ϵ������ʽ����ת���ַ�����δ֪��Ĭ���� X ��ʾ}

function BigNumberPolynomialIsZero(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ������ϵ������ʽ�����Ƿ�Ϊ 0}

procedure BigNumberPolynomialSetZero(const P: TCnBigNumberPolynomial);
{* ��һ������ϵ������ʽ������Ϊ 0}

function BigNumberPolynomialIsOne(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ������ϵ������ʽ�����Ƿ�Ϊ 1}

procedure BigNumberPolynomialSetOne(const P: TCnBigNumberPolynomial);
{* ��һ������ϵ������ʽ������Ϊ 1}

function BigNumberPolynomialIsNegOne(const P: TCnBigNumberPolynomial): Boolean;
{* �ж�һ������ϵ������ʽ�����Ƿ�Ϊ -1}

procedure BigNumberPolynomialNegate(const P: TCnBigNumberPolynomial);
{* ��һ������ϵ������ʽ��������ϵ����}

procedure BigNumberPolynomialShiftLeft(const P: TCnBigNumberPolynomial; N: Integer);
{* ��һ������ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N}

procedure BigNumberPolynomialShiftRight(const P: TCnBigNumberPolynomial; N: Integer);
{* ��һ������ϵ������ʽ�������� N �Σ�Ҳ���Ǹ���ָ������ N��С�� 0 �ĺ�����}

function BigNumberPolynomialEqual(const A, B: TCnBigNumberPolynomial): Boolean;
{* �ж�����ϵ������ʽÿ��ϵ���Ƿ��Ӧ��ȣ����򷵻� True}

// ======================== ����ϵ������ʽ��ͨ���� =============================

procedure BigNumberPolynomialAddWord(const P: TCnBigNumberPolynomial; N: Int64);
{* ��һ������ϵ������ʽ����ĳ�ϵ������ N}

procedure BigNumberPolynomialSubWord(const P: TCnBigNumberPolynomial; N: Int64);
{* ��һ������ϵ������ʽ����ĳ�ϵ����ȥ N}

procedure BigNumberPolynomialMulWord(const P: TCnBigNumberPolynomial; N: Int64);
{* ��һ������ϵ������ʽ����ĸ���ϵ�������� N}

procedure BigNumberPolynomialDivWord(const P: TCnBigNumberPolynomial; N: Int64);
{* ��һ������ϵ������ʽ����ĸ���ϵ�������� N���粻��������ȡ��}

procedure BigNumberPolynomialNonNegativeModWord(const P: TCnBigNumberPolynomial; N: Int64);
{* ��һ������ϵ������ʽ����ĸ���ϵ������ N �Ǹ�����}

function BigNumberPolynomialAdd(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial): Boolean;
{* ��������ϵ������ʽ������ӣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialSub(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial): Boolean;
{* ��������ϵ������ʽ���������������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialMul(const Res: TCnBigNumberPolynomial; P1: TCnBigNumberPolynomial;
  P2: TCnBigNumberPolynomial): Boolean;
{* ��������ϵ������ʽ������ˣ�������� Res �У���������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialDiv(const Res: TCnBigNumberPolynomial; const Remain: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; const Divisor: TCnBigNumberPolynomial): Boolean;
{* ��������ϵ������ʽ����������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function BigNumberPolynomialMod(const Res: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial): Boolean;
{* ��������ϵ������ʽ�������࣬�������� Res �У����������Ƿ�ɹ���
   ע�⵱��ʽ����ʽ�����޷������ķ���ʱ�᷵�� False����ʾ�޷�֧�֣�����������жϷ���ֵ��
   Res ������ P �� Divisor��P ������ Divisor}

function BigNumberPolynomialPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: TUInt64): Boolean;
{* �������ϵ������ʽ�� Exponent ���ݣ����ؼ����Ƿ�ɹ���Res ������ P}

function BigNumberPolynomialReduce(const P: TCnBigNumberPolynomial): Integer;
{* �������ϵ������ʽϵ����Ҳ�����Ҷ���ʽϵ�������Լ��������ϵ�����������������Լ��}

function BigNumberPolynomialGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
{* ������������ϵ������ʽ�������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ������ʽΪ 1}

function BigNumberPolynomialLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
{* ������������ϵ������ʽ����С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2
   ע�������ܻ���Ϊϵ������������ʧ�ܣ���ʹ���������б�֤ P1 P2 ��Ϊ��һ����ʽҲ���ܱ�֤��
   �緵�� False�������߿ɸɴ���Ϊ���أ���С����ʽΪ������ˣ����н���}

function BigNumberPolynomialCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial): Boolean;
{* ����ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function BigNumberPolynomialGetValue(Res: TCnBigNumber; F: TCnBigNumberPolynomial;
  X: TCnBigNumber): Boolean;
{* ����ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ����Ƿ�ɹ�}

procedure BigNumberPolynomialReduce2(P1, P2: TCnBigNumberPolynomial);
{* �����������ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ===================== ���������µ���ϵ������ʽģ���� ========================

function BigNumberPolynomialGaloisEqual(const A, B: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
{* ��������ϵ������ʽ��ģ Prime ���������Ƿ����}

procedure BigNumberPolynomialGaloisNegate(const P: TCnBigNumberPolynomial; Prime: TCnBigNumber);
{* ��һ������ϵ������ʽ��������ϵ����ģ Prime ����������}

function BigNumberPolynomialGaloisAdd(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ��������ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialGaloisSub(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ��������ϵ������ʽ������ Prime �η�������������ӣ�������� Res �У�
   �����������б�֤ Prime �������� Res �������ڱ�ԭ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialGaloisMul(const Res: TCnBigNumberPolynomial; P1: TCnBigNumberPolynomial;
  P2: TCnBigNumberPolynomial; Prime: Int64; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ��������ϵ������ʽ������ Prime �η�������������ˣ�������� Res �У�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ��������Ƿ�ɹ���P1 ������ P2��Res ������ P1 �� P2}

function BigNumberPolynomialGaloisDiv(const Res: TCnBigNumberPolynomial;
  const Remain: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ��������ϵ������ʽ������ Prime �η�����������������̷��� Res �У��������� Remain �У���������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res �� Remail ������ nil����������Ӧ�����P ������ Divisor��Res ������ P �� Divisor}

function BigNumberPolynomialGaloisMod(const Res: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* ��������ϵ������ʽ������ Prime �η��������������࣬�������� Res �У����������Ƿ�ɹ���
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   Res ������ P �� Divisor��P ������ Divisor}

function BigNumberPolynomialGaloisPower(const Res, P: TCnBigNumberPolynomial;
  Exponent: TCnBigNumber; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* �������ϵ������ʽ�� Prime �η����������ϵ� Exponent ���ݣ�
   �����������б�֤ Prime �������ұ�ԭ����ʽ Primitive Ϊ����Լ����ʽ
   ���ؼ����Ƿ�ɹ���Res ������ P}

function BigNumberPolynomialGaloisAddWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵĴ���ϵ������ʽ�ĳ�ϵ������ N �� mod Prime}

function BigNumberPolynomialGaloisSubWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵĴ���ϵ������ʽ�ĳ�ϵ����ȥ N �� mod Prime}

function BigNumberPolynomialGaloisMulWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵĴ���ϵ������ʽ����ϵ������ N �� mod Prime}

function BigNumberPolynomialGaloisDivWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ������ N��Ҳ���ǳ��� N ����Ԫ�� mod Prime}

function BigNumberPolynomialGaloisMonic(const P: TCnBigNumberPolynomial; Prime: TCnBigNumber): Integer;
{* �� Prime �η����������ϵ���ϵ������ʽ����ϵ��ͬ������ʹ����Ϊһ�����س���ֵ}

function BigNumberPolynomialGaloisGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
{* ����������ϵ������ʽ�� Prime �η����������ϵ������ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

function BigNumberPolynomialGaloisLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
{* ����������ϵ������ʽ�� Prime �η����������ϵ���С����ʽ�����ؼ����Ƿ�ɹ���Res ������ P1 �� P2}

procedure BigNumberPolynomialGaloisExtendedEuclideanGcd(A, B: TCnBigNumberPolynomial;
  X, Y: TCnBigNumberPolynomial; Prime: TCnBigNumber);
{* ��չŷ�����շת������� Prime �η��������������Ԫһ�β�����ϵ������ʽ���� A * X + B * Y = 1 �Ľ�}

procedure BigNumberPolynomialGaloisModularInverse(const Res: TCnBigNumberPolynomial;
  X, Modulus: TCnBigNumberPolynomial; Prime: TCnBigNumber; CheckGcd: Boolean = False);
{* ����ϵ������ʽ X �� Prime �η�������������� Modulus ��ģ������ʽ���ģ��Ԫ����ʽ Y��
   ���� (X * Y) mod M = 1���������뾡����֤ X��Modulus ���أ��� Res ����Ϊ X �� Modulus
   CheckGcd ����Ϊ True ʱ���ڲ����� X��Modulus �Ƿ���}

function BigNumberPolynomialGaloisCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* �� Prime �η����������Ͻ�����ϵ������ʽ������Ҳ���Ǽ��� F(P(x))�������Ƿ����ɹ���Res ������ F �� P}

function BigNumberPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberPolynomial; X, Prime: TCnBigNumber): Boolean;
{* �� Prime �η����������Ͻ�����ϵ������ʽ��ֵ��Ҳ���Ǽ��� F(x)�����ؼ����Ƿ�ɹ�}

function BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B: TCnBigNumber; Degree: TCnBigNumber;
  outDivisionPolynomial: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
{* �ݹ����ָ����Բ������ Prime �η����������ϵ� N �׿ɳ�����ʽ�������Ƿ����ɹ�
   ע�� Degree ������ʱ���ɳ�����ʽ�Ǵ� x �Ķ���ʽ��ż��ʱ���ǣ�x �Ķ���ʽ��* y ����ʽ��
   �����ֻ���� x �Ķ���ʽ���֡�
   ����ο��� F. MORAIN �����²����ϳ��� 2 ���Ƶ�����
  ��COMPUTING THE CARDINALITY OF CM ELLIPTIC CURVES USING TORSION POINTS��}

procedure BigNumberPolynomialGaloisReduce2(P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber);
{* �� Prime �η��������������������ϵ������ʽ����Լ�֣�Ҳ�����������أ����������ʽԼ������}

// ======================= ����ϵ�������ʽ�������� ============================

function BigNumberRationalPolynomialEqual(R1, R2: TCnBigNumberRationalPolynomial): Boolean;
{* �Ƚ����������ʽ�Ƿ����}

function BigNumberRationalPolynomialCopy(const Dst: TCnBigNumberRationalPolynomial;
  const Src: TCnBigNumberRationalPolynomial): TCnBigNumberRationalPolynomial;
{* �����ʽ����}

procedure BigNumberRationalPolynomialAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ��ͨ�ӷ��������������}

procedure BigNumberRationalPolynomialSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ��ͨ�����������������}

procedure BigNumberRationalPolynomialMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ��ͨ�˷��������������}

procedure BigNumberRationalPolynomialDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ��ͨ�����������������}

procedure BigNumberRationalPolynomialAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ�ӷ���RationalResult ������ R1}

procedure BigNumberRationalPolynomialSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

procedure BigNumberRationalPolynomialMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ�˷���RationalResult ������ R1}

procedure BigNumberRationalPolynomialDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
{* �����ʽ����ϵ������ʽ����ͨ������RationalResult ������ R1}

procedure BigNumberRationalPolynomialGetValue(const F: TCnBigNumberRationalPolynomial;
  X: TCnBigNumber; outResult: TCnRationalNumber);
{* �����ʽ��ֵ��Ҳ���Ǽ��� F(x)����������� outResult ��}

// ==================== ����ϵ�������ʽ���������ϵ�ģ���� =====================

function BigNumberRationalPolynomialGaloisEqual(R1, R2: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
{* �Ƚ���������ϵ��ģϵ�������ʽ�Ƿ����}

procedure BigNumberRationalPolynomialGaloisNegate(const P: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber);
{* ��һ������ϵ�������ʽ������ӵ�����ϵ����ģ Prime ����������}

procedure BigNumberRationalPolynomialGaloisAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽģϵ���ӷ��������������}

procedure BigNumberRationalPolynomialGaloisSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽģϵ�������������������}

procedure BigNumberRationalPolynomialGaloisMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽģϵ���˷��������������}

procedure BigNumberRationalPolynomialGaloisDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽģϵ�������������������}

procedure BigNumberRationalPolynomialGaloisAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽ����ϵ������ʽ��ģϵ���ӷ���RationalResult ������ R1}

procedure BigNumberRationalPolynomialGaloisSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

procedure BigNumberRationalPolynomialGaloisMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽ����ϵ������ʽ��ģϵ���˷���RationalResult ������ R1}

procedure BigNumberRationalPolynomialGaloisDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
{* ����ϵ�������ʽ����ϵ������ʽ��ģϵ��������RationalResult ������ R1}

function BigNumberRationalPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberRationalPolynomial; X: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* ����ϵ�������ʽģϵ����ֵ��Ҳ����ģ���� F(x)�������ó˷�ģ��Ԫ��ʾ}

var
  CnInt64PolynomialOne: TCnInt64Polynomial = nil;     // ��ʾ 1 �ĳ���
  CnInt64PolynomialZero: TCnInt64Polynomial = nil;    // ��ʾ 0 �ĳ���

  CnBigNumberPolynomialOne: TCnBigNumberPolynomial = nil;     // ��ʾ 1 �ĳ���
  CnBigNumberPolynomialZero: TCnBigNumberPolynomial = nil;    // ��ʾ 0 �ĳ���

implementation

resourcestring
  SCnInvalidDegree = 'Invalid Degree %d';
  SCnErrorDivExactly = 'Can NOT Divide Exactly for Integer Polynomial.';
  SCnInvalidExponent = 'Invalid Exponent %d';
  SCnInvalidModulus = 'Can NOT Mod a Negative or Zero Value.';

var
  FLocalInt64PolynomialPool: TCnInt64PolynomialPool = nil;
  FLocalBigNumberPolynomialPool: TCnBigNumberPolynomialPool = nil;

{ TCnInt64Polynomial }

procedure TCnInt64Polynomial.CorrectTop;
begin
  while (MaxDegree > 0) and (Items[MaxDegree] = 0) do
    Delete(MaxDegree);
end;

constructor TCnInt64Polynomial.Create;
begin
  inherited;
  Add(0);   // ��ϵ����
end;

constructor TCnInt64Polynomial.Create(LowToHighCoefficients: array of const);
begin
  inherited Create;
  SetCoefficents(LowToHighCoefficients);
end;

destructor TCnInt64Polynomial.Destroy;
begin

  inherited;
end;

function TCnInt64Polynomial.GetMaxDegree: Integer;
begin
  if Count = 0 then
    Add(0);
  Result := Count - 1;
end;

function TCnInt64Polynomial.IsNegOne: Boolean;
begin
  Result := Int64PolynomialIsNegOne(Self);
end;

function TCnInt64Polynomial.IsOne: Boolean;
begin
  Result := Int64PolynomialIsOne(Self);
end;

function TCnInt64Polynomial.IsZero: Boolean;
begin
  Result := Int64PolynomialIsZero(Self);
end;

procedure TCnInt64Polynomial.Negate;
begin
  Int64PolynomialNegate(Self);
end;

procedure TCnInt64Polynomial.SetCoefficents(LowToHighCoefficients: array of const);
var
  I: Integer;
begin
  Clear;
  for I := Low(LowToHighCoefficients) to High(LowToHighCoefficients) do
  begin
    case LowToHighCoefficients[I].VType of
    vtInteger:
      begin
        Add(LowToHighCoefficients[I].VInteger);
      end;
    vtInt64:
      begin
        Add(LowToHighCoefficients[I].VInt64^);
      end;
    vtBoolean:
      begin
        if LowToHighCoefficients[I].VBoolean then
          Add(1)
        else
          Add(0);
      end;
    vtString:
      begin
        Add(StrToInt(LowToHighCoefficients[I].VString^));
      end;
    else
      raise ECnPolynomialException.CreateFmt(SInvalidInteger, ['Coefficients ' + IntToStr(I)]);
    end;
  end;

  if Count = 0 then
    Add(0)
  else
    CorrectTop;
end;

procedure TCnInt64Polynomial.SetMaxDegree(const Value: Integer);
begin
  if Value < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidDegree, [Value]);
  Count := Value + 1;
end;

procedure TCnInt64Polynomial.SetOne;
begin
  Int64PolynomialSetOne(Self);
end;

procedure TCnInt64Polynomial.SetZero;
begin
  Int64PolynomialSetZero(Self);
end;

function TCnInt64Polynomial.ToString: string;
begin
  Result := Int64PolynomialToString(Self);
end;

// ============================ ����ʽϵ�в������� =============================

function Int64PolynomialNew: TCnInt64Polynomial;
begin
  Result := TCnInt64Polynomial.Create;
end;

procedure Int64PolynomialFree(const P: TCnInt64Polynomial);
begin
  P.Free;
end;

function Int64PolynomialDuplicate(const P: TCnInt64Polynomial): TCnInt64Polynomial;
begin
  if P = nil then
  begin
    Result := nil;
    Exit;
  end;

  Result := Int64PolynomialNew;
  if Result <> nil then
    Int64PolynomialCopy(Result, P);
end;

function Int64PolynomialCopy(const Dst: TCnInt64Polynomial;
  const Src: TCnInt64Polynomial): TCnInt64Polynomial;
var
  I: Integer;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    Dst.Clear;
    for I := 0 to Src.Count - 1 do
      Dst.Add(Src[I]);
    Dst.CorrectTop;
  end;
end;

function Int64PolynomialToString(const P: TCnInt64Polynomial;
  const VarName: string = 'X'): string;
var
  I: Integer;
  C: Int64;

  function VarPower(E: Integer): string;
  begin
    if E = 0 then
      Result := ''
    else if E = 1 then
      Result := VarName
    else
      Result := VarName + '^' + IntToStr(E);
  end;

begin
  Result := '';
  if Int64PolynomialIsZero(P) then
  begin
    Result := '0';
    Exit;
  end;

  for I := P.MaxDegree downto 0 do
  begin
    C := P[I];
    if C = 0 then
    begin
      Continue;
    end
    else if C > 0 then
    begin
      if (C = 1) and (I > 0) then  // �ǳ������ 1 ϵ��������ʾ
      begin
        if Result = '' then  // ���������Ӻ�
          Result := VarPower(I)
        else
          Result := Result + '+' + VarPower(I);
      end
      else
      begin
        if Result = '' then  // ���������Ӻ�
          Result := IntToStr(C) + VarPower(I)
        else
          Result := Result + '+' + IntToStr(C) + VarPower(I);
      end;
    end
    else // С�� 0��Ҫ�ü���
    begin
      if (C = -1) and (I > 0) then // �ǳ������ -1 ������ʾ 1��ֻ�����
        Result := Result + '-' + VarPower(I)
      else
        Result := Result + IntToStr(C) + VarPower(I);
    end;
  end;
end;

function Int64PolynomialIsZero(const P: TCnInt64Polynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and (P[0] = 0);
end;

procedure Int64PolynomialSetZero(const P: TCnInt64Polynomial);
begin
  P.Clear;
  P.Add(0);
end;

function Int64PolynomialIsOne(const P: TCnInt64Polynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and (P[0] = 1);
end;

procedure Int64PolynomialSetOne(const P: TCnInt64Polynomial);
begin
  P.Clear;
  P.Add(1);
end;

function Int64PolynomialIsNegOne(const P: TCnInt64Polynomial): Boolean;
begin
  Result := (P.MaxDegree = 0) and (P[0] = -1);
end;

procedure Int64PolynomialNegate(const P: TCnInt64Polynomial);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
    P[I] := -P[I];
end;

procedure Int64PolynomialShiftLeft(const P: TCnInt64Polynomial; N: Integer);
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64PolynomialShiftRight(P, -N)
  else
    P.InsertBatch(0, N);
end;

procedure Int64PolynomialShiftRight(const P: TCnInt64Polynomial; N: Integer);
begin
  if N = 0 then
    Exit
  else if N < 0 then
    Int64PolynomialShiftLeft(P, -N)
  else
  begin
    P.DeleteLow(N);

    if P.Count = 0 then
      P.Add(0);
  end;
end;

function Int64PolynomialEqual(const A, B: TCnInt64Polynomial): Boolean;
var
  I: Integer;
begin
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  Result := A.MaxDegree = B.MaxDegree;
  if Result then
  begin
    for I := A.MaxDegree downto 0 do
    begin
      if A[I] <> B[I] then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure Int64PolynomialAddWord(const P: TCnInt64Polynomial; N: Int64);
begin
  P[0] := P[0] + N;
end;

procedure Int64PolynomialSubWord(const P: TCnInt64Polynomial; N: Int64);
begin
  P[0] := P[0] - N;
end;

procedure Int64PolynomialMulWord(const P: TCnInt64Polynomial; N: Int64);
var
  I: Integer;
begin
  if N = 0 then
  begin
    Int64PolynomialSetZero(P);
    Exit;
  end
  else
  begin
    for I := 0 to P.MaxDegree do
      P[I] := P[I] * N;
  end;
end;

procedure Int64PolynomialDivWord(const P: TCnInt64Polynomial; N: Int64);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide);

  for I := 0 to P.MaxDegree do
    P[I] := P[I] div N;
end;

procedure Int64PolynomialNonNegativeModWord(const P: TCnInt64Polynomial; N: Int64);
var
  I: Integer;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SZeroDivide);

  for I := 0 to P.MaxDegree do
    P[I] := Int64NonNegativeMod(P[I], N);
end;

function Int64PolynomialAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
var
  I, D1, D2: Integer;
  PBig: TCnInt64Polynomial;
begin
  D1 := Max(P1.MaxDegree, P2.MaxDegree);
  D2 := Min(P1.MaxDegree, P2.MaxDegree);

  if D1 > D2 then
  begin
    if P1.MaxDegree > P2.MaxDegree then
      PBig := P1
    else
      PBig := P2;

    Res.MaxDegree := D1; // ���ǵ� Res ������ P1 �� P2�����Ը� Res �� MaxDegree ��ֵ�÷�����ıȽ�֮��
    for I := D1 downto D2 + 1 do
      Res[I] := PBig[I];
  end
  else // D1 = D2 ˵������ʽͬ��
    Res.MaxDegree := D1;

  for I := D2 downto 0 do
    Res[I] := P1[I] + P2[I];
  Res.CorrectTop;
  Result := True;
end;

function Int64PolynomialSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial): Boolean;
var
  I, D1, D2: Integer;
begin
  D1 := Max(P1.MaxDegree, P2.MaxDegree);
  D2 := Min(P1.MaxDegree, P2.MaxDegree);

  Res.MaxDegree := D1;
  if D1 > D2 then
  begin
    if P1.MaxDegree > P2.MaxDegree then // ����ʽ��
    begin
      for I := D1 downto D2 + 1 do
        Res[I] := P1[I];
    end
    else  // ��ʽ��
    begin
      for I := D1 downto D2 + 1 do
        Res[I] := -P2[I];
    end;
  end;

  for I := D2 downto 0 do
    Res[I] := P1[I] - P2[I];
  Res.CorrectTop;
  Result := True;
end;

function Int64PolynomialMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial): Boolean;
var
  R: TCnInt64Polynomial;
  I, J: Integer;
begin
  if Int64PolynomialIsZero(P1) or Int64PolynomialIsZero(P2) then
  begin
    Int64PolynomialSetZero(Res);
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxDegree := P1.MaxDegree + P2.MaxDegree;

  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ���
    for J := 0 to P2.MaxDegree do
    begin
      R[I + J] := R[I + J] + P1[I] * P2[J];
    end;
  end;

  R.CorrectTop;
  if (Res = P1) or (Res = P2) then
  begin
    Int64PolynomialCopy(Res, R);
    FLocalInt64PolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64PolynomialDiv(const Res: TCnInt64Polynomial; const Remain: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; const Divisor: TCnInt64Polynomial): Boolean;
var
  SubRes: TCnInt64Polynomial; // ���ɵݼ���
  MulRes: TCnInt64Polynomial; // ���ɳ����˻�
  DivRes: TCnInt64Polynomial; // ������ʱ��
  I, D: Integer;
  T: Int64;
begin
  if Int64PolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  if Divisor.MaxDegree > P.MaxDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      Int64PolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      Int64PolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;

  try
    SubRes := FLocalInt64PolynomialPool.Obtain;
    Int64PolynomialCopy(SubRes, P);

    D := P.MaxDegree - Divisor.MaxDegree;
    DivRes := FLocalInt64PolynomialPool.Obtain;
    DivRes.MaxDegree := D;
    MulRes := FLocalInt64PolynomialPool.Obtain;

    for I := 0 to D do
    begin
      if P.MaxDegree - I > SubRes.MaxDegree then                 // �м���������λ
        Continue;

      // �ж� Divisor[Divisor.MaxDegree] �Ƿ������� SubRes[P.MaxDegree - I] ������˵�����������Ͷ���ʽ��Χ���޷�֧�֣�ֻ�ܳ���
      if (SubRes[P.MaxDegree - I] mod Divisor[Divisor.MaxDegree]) <> 0 then
      begin
        Result := False;
        Exit;
        // raise ECnPolynomialException.Create(SCnErrorDivExactly);
      end;

      Int64PolynomialCopy(MulRes, Divisor);
      Int64PolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�
      T := SubRes[P.MaxDegree - I] div MulRes[MulRes.MaxDegree];
      Int64PolynomialMulWord(MulRes, T); // ��ʽ�˵���ߴ�ϵ����ͬ
      DivRes[D - I] := T;                // �̷ŵ� DivRes λ��
      Int64PolynomialSub(SubRes, SubRes, MulRes);              // ���������·Ż� SubRes
    end;

    if Remain <> nil then
      Int64PolynomialCopy(Remain, SubRes);
    if Res <> nil then
      Int64PolynomialCopy(Res, DivRes);
  finally
    FLocalInt64PolynomialPool.Recycle(SubRes);
    FLocalInt64PolynomialPool.Recycle(MulRes);
    FLocalInt64PolynomialPool.Recycle(DivRes);
  end;
  Result := True;
end;

function Int64PolynomialMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialDiv(nil, Res, P, Divisor);
end;

function Int64PolynomialPower(const Res: TCnInt64Polynomial;
  const P: TCnInt64Polynomial; Exponent: Int64): Boolean;
var
  T: TCnInt64Polynomial;
begin
  if Exponent = 0 then
  begin
    Res.SetCoefficents([1]);
    Result := True;
    Exit;
  end
  else if Exponent = 1 then
  begin
    if Res <> P then
      Int64PolynomialCopy(Res, P);
    Result := True;
    Exit;
  end else if Exponent < 0 then
    raise ECnPolynomialException.CreateFmt(SCnInvalidExponent, [Exponent]);

  T := Int64PolynomialDuplicate(P);
  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetCoefficents([1]);
    while Exponent > 0 do
    begin
      if (Exponent and 1) <> 0 then
        Int64PolynomialMul(Res, Res, T);

      Exponent := Exponent shr 1;
      Int64PolynomialMul(T, T, T);
    end;
    Result := True;
  finally
    T.Free;
  end;
end;

function Int64PolynomialReduce(const P: TCnInt64Polynomial): Integer;
var
  I, D: Integer;

  function Gcd(A, B: Integer): Integer;
  var
    T: Integer;
  begin
    while B <> 0 do
    begin
      T := B;
      B := A mod B;
      A := T;
    end;
    Result := A;
  end;

begin
  if P.MaxDegree = 0 then
  begin
    Result := P[P.MaxDegree];
    if P[P.MaxDegree] <> 0 then
      P[P.MaxDegree] := 1;
  end
  else
  begin
    D := P[0];
    for I := 0 to P.MaxDegree - 1 do
    begin
      D := Gcd(D, P[I + 1]);
      if D = 1 then
        Break;
    end;

    Result := D;
    if Result > 1 then
      Int64PolynomialDivWord(P, Result);
  end;
end;

function Int64PolynomialGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
var
  A, B, C: TCnInt64Polynomial;
begin
  Result := False;
  A := nil;
  B := nil;
  C := nil;

  try
    A := FLocalInt64PolynomialPool.Obtain;
    B := FLocalInt64PolynomialPool.Obtain;

    if P1.MaxDegree >= P2.MaxDegree then
    begin
      Int64PolynomialCopy(A, P1);
      Int64PolynomialCopy(B, P2);
    end
    else
    begin
      Int64PolynomialCopy(A, P2);
      Int64PolynomialCopy(B, P1);
    end;

    C := FLocalInt64PolynomialPool.Obtain;
    while not B.IsZero do
    begin
      Int64PolynomialCopy(C, B);        // ���� B
      if not Int64PolynomialMod(B, A, B) then   // A mod B �� B
        Exit;

      // B Ҫϵ��Լ�ֻ���
      Int64PolynomialReduce(B);
      Int64PolynomialCopy(A, C);        // ԭʼ B �� A
    end;

    Int64PolynomialCopy(Res, A);
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(A);
    FLocalInt64PolynomialPool.Recycle(B);
    FLocalInt64PolynomialPool.Recycle(C);
  end;
end;

function Int64PolynomialLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial): Boolean;
var
  G, M, R: TCnInt64Polynomial;
begin
  Result := False;
  if Int64PolynomialEqual(P1, P2) then
  begin
    Int64PolynomialCopy(Res, P1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalInt64PolynomialPool.Obtain;
    M := FLocalInt64PolynomialPool.Obtain;
    R := FLocalInt64PolynomialPool.Obtain;

    if not Int64PolynomialMul(M, P1, P2) then
      Exit;

    if not Int64PolynomialGreatestCommonDivisor(G, P1, P2) then
      Exit;

    if not Int64PolynomialDiv(Res, R, M, G) then
      Exit;

    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(R);
    FLocalInt64PolynomialPool.Recycle(M);
    FLocalInt64PolynomialPool.Recycle(G);
  end;
end;

function Int64PolynomialCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64Polynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res[0] := F[0];
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64PolynomialPool.Obtain;
  T := FLocalInt64PolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      Int64PolynomialCopy(T, X);
      Int64PolynomialMulWord(T, F[I]);
      Int64PolynomialAdd(R, R, T);

      if I <> F.MaxDegree then
        Int64PolynomialMul(X, X, P);
    end;

    if (Res = F) or (Res = P) then
    begin
      Int64PolynomialCopy(Res, R);
      FLocalInt64PolynomialPool.Recycle(R);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(X);
    FLocalInt64PolynomialPool.Recycle(T);
  end;
  Result := True;
end;

function Int64PolynomialGetValue(const F: TCnInt64Polynomial; X: Int64): Int64;
var
  I: Integer;
  T: Int64;
begin
  Result := F[0];
  if (X = 0) or (F.MaxDegree = 0) then    // ֻ�г����������£��ó�����
    Exit;

  T := X;

  // �� F �е�ÿ��ϵ������ X �Ķ�Ӧ������ˣ�������
  for I := 1 to F.MaxDegree do
  begin
    Result := Result + F[I] * T;
    if I <> F.MaxDegree then
      T := T * X;
  end;
end;

procedure Int64PolynomialReduce2(P1, P2: TCnInt64Polynomial);
var
  D: TCnInt64Polynomial;
begin
  if P1 = P2 then
  begin
    P1.SetOne;
    Exit;
  end;

  D := FLocalInt64PolynomialPool.Obtain;
  try
    if not Int64PolynomialGreatestCommonDivisor(D, P1, P2) then
      Exit;

    if not D.IsOne then
    begin
      Int64PolynomialDiv(P1, nil, P1, D);
      Int64PolynomialDiv(P1, nil, P1, D);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(D);
  end;
end;

function Int64PolynomialGaloisEqual(const A, B: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  I: Integer;
begin
  if A = B then
  begin
    Result := True;
    Exit;
  end;

  Result := A.MaxDegree = B.MaxDegree;
  if Result then
  begin
    for I := A.MaxDegree downto 0 do
    begin
      if (A[I] <> B[I]) and (Int64NonNegativeMod(A[I], Prime) <> Int64NonNegativeMod(B[I], Prime)) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure Int64PolynomialGaloisNegate(const P: TCnInt64Polynomial; Prime: Int64);
var
  I: Integer;
begin
  for I := 0 to P.MaxDegree do
    P[I] := Int64NonNegativeMod(-P[I], Prime);
end;

function Int64PolynomialGaloisAdd(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialAdd(Res, P1, P2);
  if Result then
  begin
    Int64PolynomialNonNegativeModWord(Res, Prime);
    if Primitive <> nil then
      Int64PolynomialGaloisMod(Res, Res, Primitive, Prime);
  end;
end;

function Int64PolynomialGaloisSub(const Res: TCnInt64Polynomial; const P1: TCnInt64Polynomial;
  const P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialSub(Res, P1, P2);
  if Result then
  begin
    Int64PolynomialNonNegativeModWord(Res, Prime);
    if Primitive <> nil then
      Int64PolynomialGaloisMod(Res, Res, Primitive, Prime);
  end;
end;

function Int64PolynomialGaloisMul(const Res: TCnInt64Polynomial; P1: TCnInt64Polynomial;
  P2: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  R: TCnInt64Polynomial;
  I, J: Integer;
  T: Int64;
begin
  if Int64PolynomialIsZero(P1) or Int64PolynomialIsZero(P2) then
  begin
    Int64PolynomialSetZero(Res);
    Result := True;
    Exit;
  end;

  if (Res = P1) or (Res = P2) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  R.Clear;
  R.MaxDegree := P1.MaxDegree + P2.MaxDegree;
  for I := 0 to P1.MaxDegree do
  begin
    // �ѵ� I �η������ֳ��� P2 ��ÿһ�����֣��ӵ������ I ��ͷ�Ĳ��֣���ȡģ
    for J := 0 to P2.MaxDegree do
    begin
      // �������������ֱ�����
      T := Int64NonNegativeMulMod(P1[I], P2[J], Prime);
      R[I + J] := Int64NonNegativeMod(R[I + J] + Int64NonNegativeMod(T, Prime), Prime);
      // TODO: ��δ����ӷ���������
    end;
  end;

  R.CorrectTop;

  // �ٶԱ�ԭ����ʽȡģ��ע�����ﴫ��ı�ԭ����ʽ�� mod �����ĳ��������Ǳ�ԭ����ʽ����
  if Primitive <> nil then
    Int64PolynomialGaloisMod(R, R, Primitive, Prime);

  if (Res = P1) or (Res = P2) then
  begin
    Int64PolynomialCopy(Res, R);
    FLocalInt64PolynomialPool.Recycle(R);
  end;
  Result := True;
end;

function Int64PolynomialGaloisDiv(const Res: TCnInt64Polynomial;
  const Remain: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  SubRes: TCnInt64Polynomial; // ���ɵݼ���
  MulRes: TCnInt64Polynomial; // ���ɳ����˻�
  DivRes: TCnInt64Polynomial; // ������ʱ��
  I, D: Integer;
  K, T: Int64;
begin
  if Int64PolynomialIsZero(Divisor) then
    raise ECnPolynomialException.Create(SDivByZero);

  // ���赣�Ĳ������������⣬��Ϊ����Ԫ�� mod ����

  if Divisor.MaxDegree > P.MaxDegree then // ��ʽ�����߲�������ֱ�ӱ������
  begin
    if Res <> nil then
      Int64PolynomialSetZero(Res);
    if (Remain <> nil) and (P <> Remain) then
      Int64PolynomialCopy(Remain, P);
    Result := True;
    Exit;
  end;

  // ������ѭ��
  SubRes := nil;
  MulRes := nil;
  DivRes := nil;

  try
    SubRes := FLocalInt64PolynomialPool.Obtain;
    Int64PolynomialCopy(SubRes, P);

    D := P.MaxDegree - Divisor.MaxDegree;
    DivRes := FLocalInt64PolynomialPool.Obtain;
    DivRes.MaxDegree := D;
    MulRes := FLocalInt64PolynomialPool.Obtain;

    if Divisor[Divisor.MaxDegree] = 1 then
      K := 1
    else
      K := CnInt64ModularInverse2(Divisor[Divisor.MaxDegree], Prime); // K �ǳ�ʽ���λ����Ԫ

    for I := 0 to D do
    begin
      if P.MaxDegree - I > SubRes.MaxDegree then               // �м���������λ
        Continue;
      Int64PolynomialCopy(MulRes, Divisor);
      Int64PolynomialShiftLeft(MulRes, D - I);                 // ���뵽 SubRes ����ߴ�

      // ��ʽҪ��һ������������� SubRes ���λ���Գ�ʽ���λ�õ��Ľ����Ҳ�� SubRes ���λ���Գ�ʽ���λ����Ԫ�� mod Prime
      T := Int64NonNegativeMulMod(SubRes[P.MaxDegree - I], K, Prime);
      Int64PolynomialGaloisMulWord(MulRes, T, Prime);          // ��ʽ�˵���ߴ�ϵ����ͬ

      DivRes[D - I] := T;                                      // ��Ӧλ���̷ŵ� DivRes λ��
      Int64PolynomialGaloisSub(SubRes, SubRes, MulRes, Prime); // ����ģ�������·Ż� SubRes
    end;

    // ������ʽ����Ҫ��ģ��ԭ����ʽ
    if Primitive <> nil then
    begin
      Int64PolynomialGaloisMod(SubRes, SubRes, Primitive, Prime);
      Int64PolynomialGaloisMod(DivRes, DivRes, Primitive, Prime);
    end;

    if Remain <> nil then
      Int64PolynomialCopy(Remain, SubRes);
    if Res <> nil then
      Int64PolynomialCopy(Res, DivRes);
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(SubRes);
    FLocalInt64PolynomialPool.Recycle(MulRes);
    FLocalInt64PolynomialPool.Recycle(DivRes);
  end;
end;

function Int64PolynomialGaloisMod(const Res: TCnInt64Polynomial; const P: TCnInt64Polynomial;
  const Divisor: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
begin
  Result := Int64PolynomialGaloisDiv(nil, Res, P, Divisor, Prime, Primitive);
end;

function Int64PolynomialGaloisPower(const Res, P: TCnInt64Polynomial;
  Exponent: Int64; Prime: Int64; Primitive: TCnInt64Polynomial;
  ExponentHi: Int64): Boolean;
var
  T: TCnInt64Polynomial;

  function ExponentIsZero: Boolean;
  begin
    Result := (Exponent = 0) and (ExponentHi = 0);
  end;

  function ExponentIsOne: Boolean;
  begin
    Result := (Exponent = 1) and (ExponentHi = 0);
  end;

  procedure ExponentShiftRightOne;
  begin
    Exponent := Exponent shr 1;
    if (ExponentHi and 1) <> 0 then
      Exponent := Exponent or $F000000000000000;
    ExponentHi := ExponentHi shr 1;
  end;

begin
  if ExponentIsZero then
  begin
    Res.SetCoefficents([1]);
    Result := True;
    Exit;
  end
  else if ExponentIsOne then
  begin
    if Res <> P then
      Int64PolynomialCopy(Res, P);
    Result := True;
    Exit;
  end;

  T := Int64PolynomialDuplicate(P);
  try
    // ��������ʽ���ټ��� T �Ĵη���ֵ�� Res
    Res.SetCoefficents([1]);
    while not ExponentIsZero do
    begin
      if (Exponent and 1) <> 0 then
        Int64PolynomialGaloisMul(Res, Res, T, Prime, Primitive);

      ExponentShiftRightOne;
      Int64PolynomialGaloisMul(T, T, T, Prime, Primitive);
    end;
    Result := True;
  finally
    T.Free;
  end;
end;

function Int64PolynomialGaloisAddWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64): Boolean;
begin
  P[0] := Int64NonNegativeMod(P[0] + N, Prime);
  Result := True;
end;

function Int64PolynomialGaloisSubWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64): Boolean;
begin
  P[0] := Int64NonNegativeMod(P[0] - N, Prime);
  Result := True;
end;

function Int64PolynomialGaloisMulWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64): Boolean;
var
  I: Integer;
begin
  if N = 0 then
  begin
    Int64PolynomialSetZero(P);
  end
  else
  begin
    for I := 0 to P.MaxDegree do
      P[I] := Int64NonNegativeMulMod(P[I], N, Prime);
  end;
  Result := True;
end;

function Int64PolynomialGaloisDivWord(const P: TCnInt64Polynomial; N: Int64;
  Prime: Int64): Boolean;
var
  I: Integer;
  K: Int64;
  B: Boolean;
begin
  if N = 0 then
    raise ECnPolynomialException.Create(SDivByZero);

  B := N < 0;
  if B then
    N := -N;

  K := CnInt64ModularInverse2(N, Prime);
  for I := 0 to P.MaxDegree do
  begin
    P[I] := Int64NonNegativeMod(P[I] * K, Prime);
    if B then
      P[I] := Prime - LongWord(P[I]);
  end;
  Result := True;
end;

function Int64PolynomialGaloisMonic(const P: TCnInt64Polynomial; Prime: Int64): Integer;
begin
  Result := P[P.MaxDegree];
  if (Result <> 1) and (Result <> 0) then
    Int64PolynomialGaloisDivWord(P, Result, Prime);
end;

function Int64PolynomialGaloisGreatestCommonDivisor(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  A, B, C: TCnInt64Polynomial;
begin
  A := nil;
  B := nil;
  C := nil;
  try
    A := FLocalInt64PolynomialPool.Obtain;
    B := FLocalInt64PolynomialPool.Obtain;

    if P1.MaxDegree >= P2.MaxDegree then
    begin
      Int64PolynomialCopy(A, P1);
      Int64PolynomialCopy(B, P2);
    end
    else
    begin
      Int64PolynomialCopy(A, P2);
      Int64PolynomialCopy(B, P1);
    end;

    C := FLocalInt64PolynomialPool.Obtain;
    while not B.IsZero do
    begin
      Int64PolynomialCopy(C, B);          // ���� B
      Int64PolynomialGaloisMod(B, A, B, Prime);  // A mod B �� B
      Int64PolynomialCopy(A, C);          // ԭʼ B �� A
    end;

    Int64PolynomialCopy(Res, A);
    Int64PolynomialGaloisMonic(Res, Prime);      // ���Ϊһ
    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(A);
    FLocalInt64PolynomialPool.Recycle(B);
    FLocalInt64PolynomialPool.Recycle(C);
  end;
end;

function Int64PolynomialGaloisLeastCommonMultiple(const Res: TCnInt64Polynomial;
  const P1, P2: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  G, M, R: TCnInt64Polynomial;
begin
  Result := False;
  if Int64PolynomialEqual(P1, P2) then
  begin
    Int64PolynomialCopy(Res, P1);
    Result := True;
    Exit;
  end;

  G := nil;
  M := nil;
  R := nil;

  try
    G := FLocalInt64PolynomialPool.Obtain;
    M := FLocalInt64PolynomialPool.Obtain;
    R := FLocalInt64PolynomialPool.Obtain;

    if not Int64PolynomialGaloisMul(M, P1, P2, Prime) then
      Exit;

    if not Int64PolynomialGaloisGreatestCommonDivisor(G, P1, P2, Prime) then
      Exit;

    if not Int64PolynomialGaloisDiv(Res, R, M, G, Prime) then
      Exit;

    Result := True;
  finally
    FLocalInt64PolynomialPool.Recycle(R);
    FLocalInt64PolynomialPool.Recycle(M);
    FLocalInt64PolynomialPool.Recycle(G);
  end;
end;

procedure Int64PolynomialGaloisExtendedEuclideanGcd(A, B: TCnInt64Polynomial;
  X, Y: TCnInt64Polynomial; Prime: Int64);
var
  T, P, M: TCnInt64Polynomial;
begin
  if B.IsZero then
  begin
    X.SetZero;
    X[0] := CnInt64ModularInverse2(A[0], Prime);
    // X ���� A ���� P ��ģ��Ԫ��������������շת����������� 1
    // ��Ϊ A �����ǲ����� 1 ������
    Y.SetZero;
  end
  else
  begin
    T := nil;
    P := nil;
    M := nil;

    try
      T := FLocalInt64PolynomialPool.Obtain;
      P := FLocalInt64PolynomialPool.Obtain;
      M := FLocalInt64PolynomialPool.Obtain;

      Int64PolynomialGaloisMod(P, A, B, Prime);

      Int64PolynomialGaloisExtendedEuclideanGcd(B, P, Y, X, Prime);

      // Y := Y - (A div B) * X;
      Int64PolynomialGaloisDiv(P, M, A, B, Prime);
      Int64PolynomialGaloisMul(P, P, X, Prime);
      Int64PolynomialGaloisSub(Y, Y, P, Prime);
    finally
      FLocalInt64PolynomialPool.Recycle(M);
      FLocalInt64PolynomialPool.Recycle(P);
      FLocalInt64PolynomialPool.Recycle(T);
    end;
  end;
end;

procedure Int64PolynomialGaloisModularInverse(const Res: TCnInt64Polynomial;
  X, Modulus: TCnInt64Polynomial; Prime: Int64; CheckGcd: Boolean);
var
  X1, Y, G: TCnInt64Polynomial;
begin
  X1 := nil;
  Y := nil;
  G := nil;

  try
    if CheckGcd then
    begin
      G := FLocalInt64PolynomialPool.Obtain;
      Int64PolynomialGaloisGreatestCommonDivisor(G, X, Modulus, Prime);
      if not G.IsOne then
        raise ECnPolynomialException.Create('Modular Inverse Need GCD = 1');
    end;

    X1 := FLocalInt64PolynomialPool.Obtain;
    Y := FLocalInt64PolynomialPool.Obtain;

    Int64PolynomialCopy(X1, X);

    // ��չŷ�����շת��������Ԫһ�β�����ϵ������ʽ���� A * X - B * Y = 1 ��������
    Int64PolynomialGaloisExtendedEuclideanGcd(X1, Modulus, Res, Y, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(X1);
    FLocalInt64PolynomialPool.Recycle(Y);
    FLocalInt64PolynomialPool.Recycle(G);
  end;
end;

function Int64PolynomialGaloisCompose(const Res: TCnInt64Polynomial;
  const F, P: TCnInt64Polynomial; Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  I: Integer;
  R, X, T: TCnInt64Polynomial;
begin
  if P.IsZero or (F.MaxDegree = 0) then    // 0 ���룬��ֻ�г����������£��ó�����
  begin
    Res.SetOne;
    Res[0] := Int64NonNegativeMod(F[0], Prime);
    Result := True;
    Exit;
  end;

  if (Res = F) or (Res = P) then
    R := FLocalInt64PolynomialPool.Obtain
  else
    R := Res;

  X := FLocalInt64PolynomialPool.Obtain;
  T := FLocalInt64PolynomialPool.Obtain;

  try
    X.SetOne;
    R.SetZero;

    // �� F �е�ÿ��ϵ������ P �Ķ�Ӧ������ˣ�������
    for I := 0 to F.MaxDegree do
    begin
      Int64PolynomialCopy(T, X);
      Int64PolynomialGaloisMulWord(T, F[I], Prime);
      Int64PolynomialGaloisAdd(R, R, T, Prime);

      if I <> F.MaxDegree then
        Int64PolynomialGaloisMul(X, X, P, Prime);
    end;

    if Primitive <> nil then
      Int64PolynomialGaloisMod(R, R, Primitive, Prime);

    if (Res = F) or (Res = P) then
    begin
      Int64PolynomialCopy(Res, R);
      FLocalInt64PolynomialPool.Recycle(R);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(X);
    FLocalInt64PolynomialPool.Recycle(T);
  end;
  Result := True;
end;

function Int64PolynomialGaloisGetValue(const F: TCnInt64Polynomial; X, Prime: Int64): Int64;
var
  I: Integer;
  T: Int64;
begin
  Result := Int64NonNegativeMod(F[0], Prime);
  if (X = 0) or (F.MaxDegree = 0) then    // ֻ�г����������£��ó�����
    Exit;

  T := X;

  // �� F �е�ÿ��ϵ������ X �Ķ�Ӧ������ˣ�������
  for I := 1 to F.MaxDegree do
  begin
    Result := Int64NonNegativeMod(Result + Int64NonNegativeMod(F[I] * T, Prime), Prime);
    if I <> F.MaxDegree then
      T := Int64NonNegativeMod(T * X, Prime);
  end;
  Result := Int64NonNegativeMod(Result, Prime);
end;

{
  �ɳ�����ʽ�����֣�һ���Ǻ� x y �� F��һ����ֻ�� x �� f�����߶��� y ��������Ҫ����˸� y
  ���� Fn �� n Ϊż��ʱ��Ȼ���� y * ������Կ��Թ涨 Fn = fn * y ��n Ϊż����fn = Fn ��n Ϊ�棩

  F0 = 0
  F1 = 1
  F2 = 2y
  F3 = 3x^4 + 6Ax^2 + 12Bx - A^2
  F4 = 4y * (x^6 + 5Ax^4 + 20Bx^3 - 5A^2x^2 - 4ABx - 8B^2 - A^3)
  F5 = 5x^12 + 62Ax^10 + 380Bx^9 + 105A^2x^8 + 240BAx^7 + (-300A^3 - 240B^2)x^6
    - 696BA^2x^5 + (-125A^4 - 1920B^2A)x^4 + (-80BA^3 - 1600B^3)x^3 + (-50A^5 - 240B^2A^2)x^2
    + (100BA^4 - 640B^3A)x + (A^6 - 32B^2A^3 - 256B4)
  ......

  һ�㣺
    F2n+1 = Fn+2 * Fn^3 - Fn-1 * Fn+1^3
    F2n   = (Fn/2y) * (Fn+2 * Fn-1^2 - Fn-2 * Fn+1^2)       // �𿴳��� 2y��ʵ���ϱ�Ȼ�� * y ��

  ��Ӧ�ģ�

  f0 = 0
  f1 = 1
  f2 = 2
  f3 = 3x^4 + 6Ax^2 + 12Bx - A^2
  f4 = 4 * (x^6 + 5Ax^4 + 20Bx^3 - 5A^2x^2 - 4ABx - 8B^2 - A^3)
  f5 = 5x^12 + 62Ax^10 + 380Bx^9 + 105A^2x^8 + 240BAx^7 + (-300A^3 - 240B^2)x^6
    - 696BA^2x^5 + (-125A^4 - 1920B^2A)x^4 + (-80BA^3 - 1600B^3)x^3 + (-50A^5 - 240B^2A^2)x^2
    + (100BA^4 - 640B^3A)x + (A^6 - 32B^2A^3 - 256B4)
  ......

  һ�㣺
    f2n = fn * (fn+2 * fn-1 ^ 2 - fn-2 * fn+1 ^ 2) / 2
    f2n+1 = fn+2 * fn^3 - fn-1 * fn+1^3 * (x^3 + Ax + B)^2     //  nΪ��
          = (x^3 + Ax + B)^2 * fn+2 * fn^3 - fn-1 * fn+1^3     //  nΪż

}
function Int64PolynomialGaloisCalcDivisionPolynomial(A, B: Int64; Degree: Int64;
  outDivisionPolynomial: TCnInt64Polynomial; Prime: Int64): Boolean;
var
  N: Integer;
  MI, T1, T2: Int64;
  D1, D2, D3, Y4: TCnInt64Polynomial;
begin
  if Degree < 0 then
    raise ECnPolynomialException.Create('Galois Division Polynomial Invalid Degree')
  else if Degree = 0 then
  begin
    outDivisionPolynomial.SetCoefficents([0]);  // f0(X) = 0
    Result := True;
  end
  else if Degree = 1 then
  begin
    outDivisionPolynomial.SetCoefficents([1]);  // f1(X) = 1
    Result := True;
  end
  else if Degree = 2 then
  begin
    outDivisionPolynomial.SetCoefficents([2]);  // f2(X) = 2
    Result := True;
  end
  else if Degree = 3 then   // f3(X) = 3 X4 + 6 a X2 + 12 b X - a^2
  begin
    outDivisionPolynomial.MaxDegree := 4;
    outDivisionPolynomial[4] := 3;
    outDivisionPolynomial[3] := 0;
    outDivisionPolynomial[2] := Int64NonNegativeMulMod(6, A, Prime);
    outDivisionPolynomial[1] := Int64NonNegativeMulMod(12, B, Prime);
    outDivisionPolynomial[0] := Int64NonNegativeMulMod(-A, A, Prime);

    Result := True;
  end
  else if Degree = 4 then // f4(X) = 4 X6 + 20 a X4 + 80 b X3 - 20 a2X2 - 16 a b X - 4 a3 - 32 b^2
  begin
    outDivisionPolynomial.MaxDegree := 6;
    outDivisionPolynomial[6] := 4;
    outDivisionPolynomial[5] := 0;
    outDivisionPolynomial[4] := Int64NonNegativeMulMod(20, A, Prime);
    outDivisionPolynomial[3] := Int64NonNegativeMulMod(80, B, Prime);
    outDivisionPolynomial[2] := Int64NonNegativeMulMod(Int64NonNegativeMulMod(-20, A, Prime), A, Prime);
    outDivisionPolynomial[1] := Int64NonNegativeMulMod(Int64NonNegativeMulMod(-16, A, Prime), B, Prime);
    T1 := Int64NonNegativeMulMod(Int64NonNegativeMulMod(Int64NonNegativeMulMod(-4, A, Prime), A, Prime), A, Prime);
    T2 := Int64NonNegativeMulMod(Int64NonNegativeMulMod(-32, B, Prime), B, Prime);
    outDivisionPolynomial[0] := Int64NonNegativeMod(T1 + T2, Prime); // TODO: ��δ������������ȡģ

    Result := True;
  end
  else
  begin
    D1 := nil;
    D2 := nil;
    D3 := nil;
    Y4 := nil;

    try
      // ��ʼ�ݹ����
      N := Degree shr 1;
      if (Degree and 1) = 0 then // Degree ��ż�������� fn * (fn+2 * fn-1 ^ 2 - fn-2 * fn+1 ^ 2) / 2
      begin
        D1 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime);

        D2 := FLocalInt64PolynomialPool.Obtain;        // D1 �õ� fn+2
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
        Int64PolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� fn-1 ^2

        Int64PolynomialGaloisMul(D1, D1, D2, Prime);   // D1 �õ� fn+2 * fn-1 ^ 2

        D3 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 2, D3, Prime);  // D3 �õ� fn-2

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D2, Prime);
        Int64PolynomialGaloisMul(D2, D2, D2, Prime);   // D2 �õ� fn+1^2
        Int64PolynomialGaloisMul(D2, D2, D3, Prime);   // D2 �õ� fn-2 * fn+1^2

        Int64PolynomialGaloisSub(D1, D1, D2, Prime);   // D1 �õ� fn+2 * fn-1^2 - fn-2 * fn+1^2

        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);    // D2 �õ� fn
        Int64PolynomialGaloisMul(outDivisionPolynomial, D2, D1, Prime);     // ��˵õ� f2n
        MI := CnInt64ModularInverse(2, Prime);
        Int64PolynomialGaloisMulWord(outDivisionPolynomial, MI, Prime);     // �ٳ��� 2
      end
      else // Degree ������
      begin
        Y4 := FLocalInt64PolynomialPool.Obtain;
        Y4.SetCoefficents([B, A, 0, 1]);
        Int64PolynomialGaloisMul(Y4, Y4, Y4, Prime);

        D1 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 2, D1, Prime); // D1 �õ� fn+2

        D2 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N, D2, Prime);
        Int64PolynomialGaloisPower(D2, D2, 3, Prime);                        // D2 �õ� fn^3

        D3 := FLocalInt64PolynomialPool.Obtain;
        Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N + 1, D3, Prime);
        Int64PolynomialGaloisPower(D3, D3, 3, Prime);                        // D3 �õ� fn+1^3

        if (N and 1) <> 0 then // N ������������ f2n+1 = fn+2 * fn^3 - fn-1 * fn+1^3 * (x^3 + Ax + B)^2
        begin
          Int64PolynomialGaloisMul(D1, D1, D2, Prime);  // D1 �õ� fn+2 * fn^3

          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);
          Int64PolynomialGaloisMul(D2, D2, Y4, Prime);     // D2 �õ� fn-1 * Y^4

          Int64PolynomialGaloisMul(D2, D2, D3, Prime);     // D2 �õ� fn+1^3 * fn-1 * Y^4
          Int64PolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end
        else // N ��ż�������� (x^3 + Ax + B)^2 * fn+2 * fn^3 - fn-1 * fn+1^3
        begin
          Int64PolynomialGaloisMul(D1, D1, D2, Prime);
          Int64PolynomialGaloisMul(D1, D1, Y4, Prime);   // D1 �õ� Y^4 * fn+2 * fn^3

          Int64PolynomialGaloisCalcDivisionPolynomial(A, B, N - 1, D2, Prime);  // D2 �õ� fn-1

          Int64PolynomialGaloisMul(D2, D2, D3, Prime);  // D2 �õ� fn-1 * fn+1^3

          Int64PolynomialGaloisSub(outDivisionPolynomial, D1, D2, Prime);
        end;
      end;
    finally
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
      FLocalInt64PolynomialPool.Recycle(D3);
      FLocalInt64PolynomialPool.Recycle(Y4);
    end;
    Result := True;
  end;
end;

procedure Int64PolynomialGaloisReduce2(P1, P2: TCnInt64Polynomial; Prime: Int64);
var
  D: TCnInt64Polynomial;
begin
  if P1 = P2 then
  begin
    P1.SetOne;
    Exit;
  end;

  D := FLocalInt64PolynomialPool.Obtain;
  try
    if not Int64PolynomialGaloisGreatestCommonDivisor(D, P1, P2, Prime) then
      Exit;

    if not D.IsOne then
    begin
      Int64PolynomialGaloisDiv(P1, nil, P1, D, Prime);
      Int64PolynomialGaloisDiv(P1, nil, P1, D, Prime);
    end;
  finally
    FLocalInt64PolynomialPool.Recycle(D);
  end;
end;

{ TCnInt64PolynomialPool }

constructor TCnInt64PolynomialPool.Create;
begin
  inherited Create(False);
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  InitializeCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection := TCriticalSection.Create;
{$ENDIF}
{$ENDIF}
end;

destructor TCnInt64PolynomialPool.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TObject(Items[I]).Free;

{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  DeleteCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Free;
{$ENDIF}
{$ENDIF}
  inherited;
end;

procedure TCnInt64PolynomialPool.Enter;
begin
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  EnterCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Acquire;
{$ENDIF}
{$ENDIF}
end;

procedure TCnInt64PolynomialPool.Leave;
begin
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  LeaveCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Release;
{$ENDIF}
{$ENDIF}
end;

function TCnInt64PolynomialPool.Obtain: TCnInt64Polynomial;
begin
  Enter;
  if Count = 0 then
  begin
    Result := TCnInt64Polynomial.Create;
  end
  else
  begin
    Result := TCnInt64Polynomial(Items[Count - 1]);
    Delete(Count - 1);
  end;
  Leave;

  Result.SetZero;
end;

procedure TCnInt64PolynomialPool.Recycle(Poly: TCnInt64Polynomial);
begin
  if Poly <> nil then
  begin
    Enter;
    Add(Poly);
    Leave;
  end;
end;

{ TCnInt64RationalPolynomial }

procedure TCnInt64RationalPolynomial.AssignTo(Dest: TPersistent);
begin
  if Dest is TCnInt64RationalPolynomial then
  begin
    Int64PolynomialCopy(TCnInt64RationalPolynomial(Dest).Nominator, FNominator);
    Int64PolynomialCopy(TCnInt64RationalPolynomial(Dest).Denominator, FDenominator);
  end
  else
    inherited;
end;

constructor TCnInt64RationalPolynomial.Create;
begin
  inherited;
  FNominator := TCnInt64Polynomial.Create([0]);
  FDenominator := TCnInt64Polynomial.Create([1]);
end;

destructor TCnInt64RationalPolynomial.Destroy;
begin
  FDenominator.Free;
  FNominator.Free;
  inherited;
end;

function TCnInt64RationalPolynomial.IsInt: Boolean;
begin
  Result := FDenominator.IsOne or FDenominator.IsNegOne;
end;

function TCnInt64RationalPolynomial.IsOne: Boolean;
begin
  Result := not FNominator.IsZero and Int64PolynomialEqual(FNominator, FDenominator);
end;

function TCnInt64RationalPolynomial.IsZero: Boolean;
begin
  Result := not FDenominator.IsZero and FNominator.IsZero;
end;

procedure TCnInt64RationalPolynomial.Neg;
begin
  FNominator.Negate;
end;

procedure TCnInt64RationalPolynomial.Reciprocal;
var
  T: TCnInt64Polynomial;
begin
  if FNominator.IsZero then
    raise EDivByZero.Create(SDivByZero);

  T := FLocalInt64PolynomialPool.Obtain;
  try
    Int64PolynomialCopy(T, FDenominator);
    Int64PolynomialCopy(FDenominator, FNominator);
    Int64PolynomialCopy(FNominator, T);
  finally
    FLocalInt64PolynomialPool.Recycle(T);
  end;
end;

procedure TCnInt64RationalPolynomial.Reduce;
begin
  Int64PolynomialReduce2(FNominator, FDenominator);
end;

procedure TCnInt64RationalPolynomial.SetOne;
begin
  FDenominator.SetOne;
  FNominator.SetOne;
end;

procedure TCnInt64RationalPolynomial.SetZero;
begin
  FDenominator.SetOne;
  FNominator.SetZero;
end;

function TCnInt64RationalPolynomial.ToString: string;
begin
  if FDenominator.IsOne then
    Result := FNominator.ToString
  else
    Result := FNominator.ToString + ' / ' + FDenominator.ToString;
end;

// ============================= �����ʽ���� ==================================

function Int64RationalPolynomialEqual(R1, R2: TCnInt64RationalPolynomial): Boolean;
var
  T1, T2: TCnInt64Polynomial;
begin
  if R1 = R2 then
  begin
    Result := True;
    Exit;
  end;

  if R1.IsInt and R2.IsInt then
  begin
    Result := Int64PolynomialEqual(R1.Nominator, R2.Nominator);
    Exit;
  end;

  T1 := FLocalInt64PolynomialPool.Obtain;
  T2 := FLocalInt64PolynomialPool.Obtain;

  try
    // �жϷ��ӷ�ĸ����˵Ľ���Ƿ����
    Int64PolynomialMul(T1, R1.Nominator, R2.Denominator);
    Int64PolynomialMul(T2, R2.Nominator, R1.Denominator);
    Result := Int64PolynomialEqual(T1, T2);
  finally
    FLocalInt64PolynomialPool.Recycle(T2);
    FLocalInt64PolynomialPool.Recycle(T1);
  end;
end;

function Int64RationalPolynomialCopy(const Dst: TCnInt64RationalPolynomial;
  const Src: TCnInt64RationalPolynomial): TCnInt64RationalPolynomial;
begin
  Result := Dst;
  if Src <> Dst then
  begin
    Int64PolynomialCopy(Dst.Nominator, Src.Nominator);
    Int64PolynomialCopy(Dst.Denominator, Src.Denominator);
  end;
end;

procedure Int64RationalPolynomialAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
var
  M, R, F1, F2, D1, D2: TCnInt64Polynomial;
begin
  if R1.IsInt and R2.IsInt then
  begin
    Int64PolynomialAdd(RationalResult.Nominator, R1.Nominator, R2.Nominator);
    RationalResult.Denominator.SetOne;
    Exit;
  end
  else if R1.IsZero then
  begin
    if R2 <> RationalResult then
      RationalResult.Assign(R2);
  end
  else if R2.IsZero then
  begin
    if R1 <> RationalResult then
      RationalResult.Assign(R1);
  end
  else
  begin
    M := nil;
    R := nil;
    F1 := nil;
    F2 := nil;
    D1 := nil;
    D2 := nil;

    try
      // ���ĸ����С������
      M := FLocalInt64PolynomialPool.Obtain;
      R := FLocalInt64PolynomialPool.Obtain;
      F1 := FLocalInt64PolynomialPool.Obtain;
      F2 := FLocalInt64PolynomialPool.Obtain;
      D1 := FLocalInt64PolynomialPool.Obtain;
      D2 := FLocalInt64PolynomialPool.Obtain;

      Int64PolynomialCopy(D1, R1.Denominator);
      Int64PolynomialCopy(D2, R2.Denominator);

      if not Int64PolynomialLeastCommonMultiple(M, D1, D2) then
        Int64PolynomialMul(M, D1, D2);   // �޷�����С����ʽ��ʾϵ���޷�������ֱ�����

      Int64PolynomialDiv(F1, R, M, D1);
      Int64PolynomialDiv(F2, R, M, D2);

      Int64PolynomialCopy(RationalResult.Denominator, M);
      Int64PolynomialMul(R, R1.Nominator, F1);
      Int64PolynomialMul(M, R2.Nominator, F2);
      Int64PolynomialAdd(RationalResult.Nominator, R, M);
    finally
      FLocalInt64PolynomialPool.Recycle(M);
      FLocalInt64PolynomialPool.Recycle(R);
      FLocalInt64PolynomialPool.Recycle(F1);
      FLocalInt64PolynomialPool.Recycle(F2);
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
    end;
  end;
end;

procedure Int64RationalPolynomialSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
begin
  R2.Nominator.Negate;
  Int64RationalPolynomialAdd(R1, R2, RationalResult);
  if RationalResult <> R2 then
    R2.Nominator.Negate;
end;

procedure Int64RationalPolynomialMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
begin
  Int64PolynomialMul(RationalResult.Nominator, R1.Nominator, R2.Nominator);
  Int64PolynomialMul(RationalResult.Denominator, R1.Denominator, R2.Denominator);
end;

procedure Int64RationalPolynomialDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial);
var
  N: TCnInt64Polynomial;
begin
  if R2.IsZero then
    raise EDivByZero.Create('Divide by Zero.');

  N := FLocalInt64PolynomialPool.Obtain; // ������ˣ��������м��������ֹ RationalResult �� Number1 �� Number 2
  try
    Int64PolynomialMul(N, R1.Nominator, R2.Denominator);
    Int64PolynomialMul(RationalResult.Denominator, R1.Denominator, R2.Nominator);
    Int64PolynomialCopy(RationalResult.Nominator, N);
  finally
    FLocalInt64PolynomialPool.Recycle(N);
  end;
end;

procedure Int64RationalPolynomialAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
var
  T: TCnInt64RationalPolynomial;
begin
  if P1.IsZero then
  begin
    if R1 <> RationalResult then
    begin
      Int64RationalPolynomialCopy(RationalResult, R1);
      Exit;
    end;
  end;

  T := TCnInt64RationalPolynomial.Create;
  try
    T.Denominator.SetOne;
    Int64PolynomialCopy(T.Nominator, P1);
    Int64RationalPolynomialAdd(R1, T, RationalResult);
  finally
    T.Free;
  end;
end;

procedure Int64RationalPolynomialSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
begin
  P1.Negate;
  try
    Int64RationalPolynomialAdd(R1, P1, RationalResult);
  finally
    P1.Negate;
  end;
end;

procedure Int64RationalPolynomialMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
begin
  if P1.IsZero then
    RationalResult.SetZero
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialMul(RationalResult.Nominator, R1.Nominator, P1);
    Int64PolynomialCopy(RationalResult.Denominator, R1.Denominator);
  end;
end;

procedure Int64RationalPolynomialDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial); overload;
begin
  if P1.IsZero then
    raise EDivByZero.Create('Divide by Zero.')
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialMul(RationalResult.Denominator, R1.Denominator, P1);
    Int64PolynomialCopy(RationalResult.Nominator, R1.Nominator);
  end;
end;

procedure Int64RationalPolynomialGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; outResult: TCnRationalNumber);
begin
  outResult.Nominator := Int64PolynomialGetValue(F.Nominator, X);
  outResult.Denominator := Int64PolynomialGetValue(F.Denominator, X);
  outResult.Reduce;
end;

// ====================== �����ʽ���������ϵ�ģ���� ===========================

function Int64RationalPolynomialGaloisEqual(R1, R2: TCnInt64RationalPolynomial;
  Prime: Int64; Primitive: TCnInt64Polynomial): Boolean;
var
  T1, T2: TCnInt64Polynomial;
begin
  if R1 = R2 then
  begin
    Result := True;
    Exit;
  end;

  T1 := FLocalInt64PolynomialPool.Obtain;
  T2 := FLocalInt64PolynomialPool.Obtain;

  try
    // �жϷ��ӷ�ĸ����˵Ľ���Ƿ����
    Int64PolynomialGaloisMul(T1, R1.Nominator, R2.Denominator, Prime, Primitive);
    Int64PolynomialGaloisMul(T2, R2.Nominator, R1.Denominator, Prime, Primitive);
    Result := Int64PolynomialGaloisEqual(T1, T2, Prime);
  finally
    FLocalInt64PolynomialPool.Recycle(T2);
    FLocalInt64PolynomialPool.Recycle(T1);
  end;
end;

procedure Int64RationalPolynomialGaloisNegate(const P: TCnInt64RationalPolynomial;
  Prime: Int64);
begin
  Int64PolynomialGaloisNegate(P.Nominator, Prime);
end;

procedure Int64RationalPolynomialGaloisAdd(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
var
  M, R, F1, F2, D1, D2: TCnInt64Polynomial;
begin
  if R1.IsInt and R2.IsInt then
  begin
    Int64PolynomialGaloisAdd(RationalResult.Nominator, R1.Nominator,
      R2.Nominator, Prime);
    RationalResult.Denominator.SetOne;
    Exit;
  end
  else if R1.IsZero then
  begin
    if R2 <> RationalResult then
      RationalResult.Assign(R2);
  end
  else if R2.IsZero then
  begin
    if R1 <> RationalResult then
      RationalResult.Assign(R1);
  end
  else
  begin
    M := nil;
    R := nil;
    F1 := nil;
    F2 := nil;
    D1 := nil;
    D2 := nil;

    try
      // ���ĸ����С������
      M := FLocalInt64PolynomialPool.Obtain;
      R := FLocalInt64PolynomialPool.Obtain;
      F1 := FLocalInt64PolynomialPool.Obtain;
      F2 := FLocalInt64PolynomialPool.Obtain;
      D1 := FLocalInt64PolynomialPool.Obtain;
      D2 := FLocalInt64PolynomialPool.Obtain;

      Int64PolynomialCopy(D1, R1.Denominator);
      Int64PolynomialCopy(D2, R2.Denominator);

      if not Int64PolynomialGaloisLeastCommonMultiple(M, D1, D2, Prime) then
        Int64PolynomialGaloisMul(M, D1, D2, Prime);   // �޷�����С����ʽ��ʾϵ���޷�������ֱ�����

      Int64PolynomialGaloisDiv(F1, R, M, D1, Prime);  // ��С������ M div D1 ����� F1
      Int64PolynomialGaloisDiv(F2, R, M, D2, Prime);  // ��С������ M div D2 ����� F2

      Int64PolynomialCopy(RationalResult.Denominator, M);  // ����ķ�ĸ����С������
      Int64PolynomialGaloisMul(R, R1.Nominator, F1, Prime);
      Int64PolynomialGaloisMul(M, R2.Nominator, F2, Prime);
      Int64PolynomialGaloisAdd(RationalResult.Nominator, R, M, Prime);
    finally
      FLocalInt64PolynomialPool.Recycle(M);
      FLocalInt64PolynomialPool.Recycle(R);
      FLocalInt64PolynomialPool.Recycle(F1);
      FLocalInt64PolynomialPool.Recycle(F2);
      FLocalInt64PolynomialPool.Recycle(D1);
      FLocalInt64PolynomialPool.Recycle(D2);
    end;
  end;
end;

procedure Int64RationalPolynomialGaloisSub(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
begin
  R2.Nominator.Negate;
  Int64RationalPolynomialGaloisAdd(R1, R2, RationalResult, Prime);
  if RationalResult <> R2 then
    R2.Nominator.Negate;
end;

procedure Int64RationalPolynomialGaloisMul(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
begin
  Int64PolynomialGaloisMul(RationalResult.Nominator, R1.Nominator, R2.Nominator, Prime);
  Int64PolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, R2.Denominator, Prime);
end;

procedure Int64RationalPolynomialGaloisDiv(R1, R2: TCnInt64RationalPolynomial;
  RationalResult: TCnInt64RationalPolynomial; Prime: Int64);
var
  N: TCnInt64Polynomial;
begin
  if R2.IsZero then
    raise EDivByZero.Create('Divide by Zero.');

  N := FLocalInt64PolynomialPool.Obtain; // ������ˣ��������м��������ֹ RationalResult �� Number1 �� Number 2
  try
    Int64PolynomialGaloisMul(N, R1.Nominator, R2.Denominator, Prime);
    Int64PolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, R2.Nominator, Prime);
    Int64PolynomialCopy(RationalResult.Nominator, N);
  finally
    FLocalInt64PolynomialPool.Recycle(N);
  end;
end;

procedure Int64RationalPolynomialGaloisAdd(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
var
  T: TCnInt64RationalPolynomial;
begin
  if P1.IsZero then
  begin
    if R1 <> RationalResult then
    begin
      Int64RationalPolynomialCopy(RationalResult, R1);
      Exit;
    end;
  end;

  T := TCnInt64RationalPolynomial.Create;
  try
    T.Denominator.SetOne;
    Int64PolynomialCopy(T.Nominator, P1);
    Int64RationalPolynomialGaloisAdd(R1, T, RationalResult, Prime);
  finally
    T.Free;
  end;
end;

procedure Int64RationalPolynomialGaloisSub(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
begin
  P1.Negate;
  try
    Int64RationalPolynomialGaloisAdd(R1, P1, RationalResult, Prime);
  finally
    P1.Negate;
  end;
end;

procedure Int64RationalPolynomialGaloisMul(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
begin
  if P1.IsZero then
    RationalResult.SetZero
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialGaloisMul(RationalResult.Nominator, R1.Nominator, P1, Prime);
    Int64PolynomialCopy(RationalResult.Denominator, R1.Denominator);
  end;
end;

procedure Int64RationalPolynomialGaloisDiv(R1: TCnInt64RationalPolynomial;
  P1: TCnInt64Polynomial; RationalResult: TCnInt64RationalPolynomial; Prime: Int64); overload;
begin
  if P1.IsZero then
    raise EDivByZero.Create('Divide by Zero.')
  else if P1.IsOne then
    RationalResult.Assign(R1)
  else
  begin
    Int64PolynomialGaloisMul(RationalResult.Denominator, R1.Denominator, P1, Prime);
    Int64PolynomialCopy(RationalResult.Nominator, R1.Nominator);
  end;
end;

function Int64RationalPolynomialGaloisGetValue(const F: TCnInt64RationalPolynomial;
  X: Int64; Prime: Int64): Int64;
var
  N, D:Int64;
begin
  D := Int64PolynomialGaloisGetValue(F.Denominator, X, Prime);
  if D = 0 then
    raise EDivByZero.Create(SDivByZero);

  N := Int64PolynomialGaloisGetValue(F.Nominator, X, Prime);
  Result := Int64NonNegativeMod(N * CnInt64ModularInverse2(D, Prime), Prime);
end;

{ TCnBigNumberPolynomial }

procedure TCnBigNumberPolynomial.CorrectTop;
begin

end;

constructor TCnBigNumberPolynomial.Create;
begin

end;

constructor TCnBigNumberPolynomial.Create(
  LowToHighCoefficients: array of const);
begin

end;

destructor TCnBigNumberPolynomial.Destroy;
begin
  inherited;

end;

function TCnBigNumberPolynomial.GetMaxDegree: Integer;
begin

end;

function TCnBigNumberPolynomial.IsNegOne: Boolean;
begin

end;

function TCnBigNumberPolynomial.IsOne: Boolean;
begin

end;

function TCnBigNumberPolynomial.IsZero: Boolean;
begin

end;

procedure TCnBigNumberPolynomial.Negate;
begin

end;

procedure TCnBigNumberPolynomial.SetCoefficents(
  LowToHighCoefficients: array of const);
begin

end;

procedure TCnBigNumberPolynomial.SetMaxDegree(const Value: Integer);
begin

end;

procedure TCnBigNumberPolynomial.SetOne;
begin

end;

procedure TCnBigNumberPolynomial.SetZero;
begin

end;

function TCnBigNumberPolynomial.ToString: string;
begin

end;

{ TCnBigNumberRationalPolynomial }

procedure TCnBigNumberRationalPolynomial.AssignTo(Dest: TPersistent);
begin
  inherited;

end;

constructor TCnBigNumberRationalPolynomial.Create;
begin

end;

destructor TCnBigNumberRationalPolynomial.Destroy;
begin
  inherited;

end;

function TCnBigNumberRationalPolynomial.IsInt: Boolean;
begin

end;

function TCnBigNumberRationalPolynomial.IsOne: Boolean;
begin

end;

function TCnBigNumberRationalPolynomial.IsZero: Boolean;
begin

end;

procedure TCnBigNumberRationalPolynomial.Neg;
begin

end;

procedure TCnBigNumberRationalPolynomial.Reciprocal;
begin

end;

procedure TCnBigNumberRationalPolynomial.Reduce;
begin

end;

procedure TCnBigNumberRationalPolynomial.SetOne;
begin

end;

procedure TCnBigNumberRationalPolynomial.SetZero;
begin

end;

function TCnBigNumberRationalPolynomial.ToString: string;
begin

end;

{ TCnBigNumberPolynomialPool }

constructor TCnBigNumberPolynomialPool.Create;
begin
  inherited Create(False);
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  InitializeCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection := TCriticalSection.Create;
{$ENDIF}
{$ENDIF}
end;

destructor TCnBigNumberPolynomialPool.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TObject(Items[I]).Free;

{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  DeleteCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Free;
{$ENDIF}
{$ENDIF}

  inherited;
end;

procedure TCnBigNumberPolynomialPool.Enter;
begin
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  EnterCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Acquire;
{$ENDIF}
{$ENDIF}
end;

procedure TCnBigNumberPolynomialPool.Leave;
begin
{$IFDEF MULTI_THREAD}
{$IFDEF MSWINDOWS}
  LeaveCriticalSection(FCriticalSection);
{$ELSE}
  FCriticalSection.Release;
{$ENDIF}
{$ENDIF}
end;

function TCnBigNumberPolynomialPool.Obtain: TCnBigNumberPolynomial;
begin
  Enter;
  if Count = 0 then
  begin
    Result := TCnBigNumberPolynomial.Create;
  end
  else
  begin
    Result := TCnBigNumberPolynomial(Items[Count - 1]);
    Delete(Count - 1);
  end;
  Leave;

  Result.SetZero;
end;

procedure TCnBigNumberPolynomialPool.Recycle(Poly: TCnBigNumberPolynomial);
begin
  if Poly <> nil then
  begin
    Enter;
    Add(Poly);
    Leave;
  end;
end;

function BigNumberPolynomialNew: TCnBigNumberPolynomial;
begin

end;

procedure BigNumberPolynomialFree(const P: TCnBigNumberPolynomial);
begin

end;

function BigNumberPolynomialDuplicate(const P: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
begin

end;

function BigNumberPolynomialCopy(const Dst: TCnBigNumberPolynomial;
  const Src: TCnBigNumberPolynomial): TCnBigNumberPolynomial;
begin

end;

function BigNumberPolynomialToString(const P: TCnBigNumberPolynomial;
  const VarName: string = 'X'): string;
begin

end;

function BigNumberPolynomialIsZero(const P: TCnBigNumberPolynomial): Boolean;
begin

end;

procedure BigNumberPolynomialSetZero(const P: TCnBigNumberPolynomial);
begin

end;

function BigNumberPolynomialIsOne(const P: TCnBigNumberPolynomial): Boolean;
begin

end;

procedure BigNumberPolynomialSetOne(const P: TCnBigNumberPolynomial);
begin

end;

function BigNumberPolynomialIsNegOne(const P: TCnBigNumberPolynomial): Boolean;
begin

end;

procedure BigNumberPolynomialNegate(const P: TCnBigNumberPolynomial);
begin

end;

procedure BigNumberPolynomialShiftLeft(const P: TCnBigNumberPolynomial; N: Integer);
begin

end;

procedure BigNumberPolynomialShiftRight(const P: TCnBigNumberPolynomial; N: Integer);
begin

end;

function BigNumberPolynomialEqual(const A, B: TCnBigNumberPolynomial): Boolean;
begin

end;

// ======================== ����ϵ������ʽ��ͨ���� =============================

procedure BigNumberPolynomialAddWord(const P: TCnBigNumberPolynomial; N: Int64);
begin

end;

procedure BigNumberPolynomialSubWord(const P: TCnBigNumberPolynomial; N: Int64);
begin

end;

procedure BigNumberPolynomialMulWord(const P: TCnBigNumberPolynomial; N: Int64);
begin

end;

procedure BigNumberPolynomialDivWord(const P: TCnBigNumberPolynomial; N: Int64);
begin

end;

procedure BigNumberPolynomialNonNegativeModWord(const P: TCnBigNumberPolynomial; N: Int64);
begin

end;

function BigNumberPolynomialAdd(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialSub(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialMul(const Res: TCnBigNumberPolynomial; P1: TCnBigNumberPolynomial;
  P2: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialDiv(const Res: TCnBigNumberPolynomial; const Remain: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; const Divisor: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialMod(const Res: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialPower(const Res: TCnBigNumberPolynomial;
  const P: TCnBigNumberPolynomial; Exponent: TUInt64): Boolean;
begin

end;

function BigNumberPolynomialReduce(const P: TCnBigNumberPolynomial): Integer;
begin

end;

function BigNumberPolynomialGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial): Boolean;
begin

end;

function BigNumberPolynomialGetValue(Res: TCnBigNumber; F: TCnBigNumberPolynomial;
  X: TCnBigNumber): Boolean;
begin

end;

procedure BigNumberPolynomialReduce2(P1, P2: TCnBigNumberPolynomial);
begin

end;

// ===================== ���������µ���ϵ������ʽģ���� ========================

function BigNumberPolynomialGaloisEqual(const A, B: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
begin

end;

procedure BigNumberPolynomialGaloisNegate(const P: TCnBigNumberPolynomial; Prime: TCnBigNumber);
begin

end;

function BigNumberPolynomialGaloisAdd(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisSub(const Res: TCnBigNumberPolynomial; const P1: TCnBigNumberPolynomial;
  const P2: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisMul(const Res: TCnBigNumberPolynomial; P1: TCnBigNumberPolynomial;
  P2: TCnBigNumberPolynomial; Prime: Int64; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisDiv(const Res: TCnBigNumberPolynomial;
  const Remain: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisMod(const Res: TCnBigNumberPolynomial; const P: TCnBigNumberPolynomial;
  const Divisor: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisPower(const Res, P: TCnBigNumberPolynomial;
  Exponent: TCnBigNumber; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisAddWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin

end;

function BigNumberPolynomialGaloisSubWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin

end;

function BigNumberPolynomialGaloisMulWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin

end;

function BigNumberPolynomialGaloisDivWord(const P: TCnBigNumberPolynomial;
  N: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin

end;

function BigNumberPolynomialGaloisMonic(const P: TCnBigNumberPolynomial; Prime: TCnBigNumber): Integer;
begin

end;

function BigNumberPolynomialGaloisGreatestCommonDivisor(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
begin

end;

function BigNumberPolynomialGaloisLeastCommonMultiple(const Res: TCnBigNumberPolynomial;
  const P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
begin

end;

procedure BigNumberPolynomialGaloisExtendedEuclideanGcd(A, B: TCnBigNumberPolynomial;
  X, Y: TCnBigNumberPolynomial; Prime: TCnBigNumber);
begin

end;

procedure BigNumberPolynomialGaloisModularInverse(const Res: TCnBigNumberPolynomial;
  X, Modulus: TCnBigNumberPolynomial; Prime: TCnBigNumber; CheckGcd: Boolean = False);
begin

end;

function BigNumberPolynomialGaloisCompose(const Res: TCnBigNumberPolynomial;
  const F, P: TCnBigNumberPolynomial; Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

function BigNumberPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberPolynomial; X, Prime: TCnBigNumber): Boolean;
begin

end;

function BigNumberPolynomialGaloisCalcDivisionPolynomial(A, B: TCnBigNumber; Degree: TCnBigNumber;
  outDivisionPolynomial: TCnBigNumberPolynomial; Prime: TCnBigNumber): Boolean;
begin

end;

procedure BigNumberPolynomialGaloisReduce2(P1, P2: TCnBigNumberPolynomial; Prime: TCnBigNumber);
begin

end;

// ======================= ����ϵ�������ʽ�������� ============================

function BigNumberRationalPolynomialEqual(R1, R2: TCnBigNumberRationalPolynomial): Boolean;
begin

end;

function BigNumberRationalPolynomialCopy(const Dst: TCnBigNumberRationalPolynomial;
  const Src: TCnBigNumberRationalPolynomial): TCnBigNumberRationalPolynomial;
begin

end;

procedure BigNumberRationalPolynomialAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial); overload;
begin

end;

procedure BigNumberRationalPolynomialGetValue(const F: TCnBigNumberRationalPolynomial;
  X: TCnBigNumber; outResult: TCnRationalNumber);
begin

end;

// ==================== ����ϵ�������ʽ���������ϵ�ģ���� =====================

function BigNumberRationalPolynomialGaloisEqual(R1, R2: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber; Primitive: TCnBigNumberPolynomial = nil): Boolean;
begin

end;

procedure BigNumberRationalPolynomialGaloisNegate(const P: TCnBigNumberRationalPolynomial;
  Prime: TCnBigNumber);
begin

end;

procedure BigNumberRationalPolynomialGaloisAdd(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisSub(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisMul(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisDiv(R1, R2: TCnBigNumberRationalPolynomial;
  RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisAdd(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisSub(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisMul(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

procedure BigNumberRationalPolynomialGaloisDiv(R1: TCnBigNumberRationalPolynomial;
  P1: TCnBigNumberPolynomial; RationalResult: TCnBigNumberRationalPolynomial; Prime: TCnBigNumber); overload;
begin

end;

function BigNumberRationalPolynomialGaloisGetValue(Res: TCnBigNumber;
  const F: TCnBigNumberRationalPolynomial; X: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin

end;

initialization
  FLocalInt64PolynomialPool := TCnInt64PolynomialPool.Create;
  FLocalBigNumberPolynomialPool := TCnBigNumberPolynomialPool.Create;

  CnInt64PolynomialOne := TCnInt64Polynomial.Create([1]);
  CnInt64PolynomialZero := TCnInt64Polynomial.Create([0]);

  CnBigNumberPolynomialOne := TCnBigNumberPolynomial.Create([1]);
  CnBigNumberPolynomialZero := TCnBigNumberPolynomial.Create([0]);

finalization
  // CnInt64PolynomialOne.ToString; // �ֹ����÷�ֹ������������

  CnBigNumberPolynomialOne.Free;
  CnBigNumberPolynomialZero.Free;

  CnInt64PolynomialOne.Free;
  CnInt64PolynomialZero.Free;

  FLocalInt64PolynomialPool.Free;
  FLocalBigNumberPolynomialPool.Free;

end.
