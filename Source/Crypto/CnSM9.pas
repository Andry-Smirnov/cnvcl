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

unit CnSM9;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�SM9 ������Բ����˫����ӳ��������֤�㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע���ο��� GmSSL/PBC/Federico2014 Դ�롣
*           ���Ρ��ĴΡ�ʮ��������ֱ��� U V W �˷�����
*           ��������ϵ�����Ԫ��Ҳ�мӡ��ˡ��󷴡�Frobenius �Ȳ�����
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.04.04 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Consts, SysConst,
  CnContainers, CnBigNumber, CnECC, CnNativeDecl;

type
  TCnFP2 = class
  {* �����������ϵ��Ԫ��ʵ����}
  private
    F0: TCnBigNumber;
    F1: TCnBigNumber;
    function GetItems(Index: Integer): TCnBigNumber;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    function IsZero: Boolean;
    function IsOne: Boolean;
    function SetZero: Boolean;
    function SetOne: Boolean;
    function SetU: Boolean;
    function SetBigNumber(const Num: TCnBigNumber): Boolean;
    function SetHex(const S0, S1: string): Boolean;
    function SetWord(Value: Cardinal): Boolean;
    function SetWords(Value0, Value1: Cardinal): Boolean;

    property Items[Index: Integer]: TCnBigNumber read GetItems; default;
  end;

  TCnFP2Pool = class(TCnMathObjectPool)
  {* �����������ϵ��Ԫ�س�ʵ���࣬����ʹ�õ������������ϵ��Ԫ�صĵط����д�����}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP2; reintroduce;
    procedure Recycle(Num: TCnFP2); reintroduce;
  end;

  TCnFP4 = class
  {* �Ĵ��������ϵ��Ԫ��ʵ����}
  private
    F0: TCnFP2;
    F1: TCnFP2;
    function GetItems(Index: Integer): TCnFP2;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    function IsZero: Boolean;
    function IsOne: Boolean;
    function SetZero: Boolean;
    function SetOne: Boolean;
    function SetU: Boolean;
    function SetV: Boolean;
    function SetBigNumber(const Num: TCnBigNumber): Boolean;
    function SetBigNumbers(const Num0, Num1: TCnBigNumber): Boolean;
    function SetHex(const S0, S1, S2, S3: string): Boolean;
    function SetWord(Value: Cardinal): Boolean;
    function SetWords(Value0, Value1, Value2, Value3: Cardinal): Boolean;

    property Items[Index: Integer]: TCnFP2 read GetItems; default;
  end;

  TCnFP4Pool = class(TCnMathObjectPool)
  {* �Ĵ��������ϵ��Ԫ�س�ʵ���࣬����ʹ�õ��Ĵ��������ϵ��Ԫ�صĵط����д�����}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP4; reintroduce;
    procedure Recycle(Num: TCnFP4); reintroduce;
  end;

  TCnFP12 = class
  {* ʮ�����������ϵ��Ԫ��ʵ����}
  private
    F0: TCnFP4;
    F1: TCnFP4;
    F2: TCnFP4;
    function GetItems(Index: Integer): TCnFP4;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    function IsZero: Boolean;
    function IsOne: Boolean;
    function SetZero: Boolean;
    function SetOne: Boolean;
    function SetU: Boolean;
    function SetV: Boolean;
    function SetW: Boolean;
    function SetWSqr: Boolean;
    function SetBigNumber(const Num: TCnBigNumber): Boolean;
    function SetBigNumbers(const Num0, Num1, Num2: TCnBigNumber): Boolean;
    function SetHex(const S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11: string): Boolean;
      
    function SetWord(Value: Cardinal): Boolean;
    function SetWords(Value0, Value1, Value2, Value3, Value4, Value5, Value6,
      Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;

    property Items[Index: Integer]: TCnFP4 read GetItems; default;
  end;

  TCnFP12Pool = class(TCnMathObjectPool)
  {* ʮ�����������ϵ��Ԫ�س�ʵ���࣬����ʹ�õ��Ĵ��������ϵ��Ԫ�صĵط����д�����}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnFP12; reintroduce;
    procedure Recycle(Num: TCnFP12); reintroduce;
  end;

  TCnAffinePoint = class
  {* ��������ϵ���ƽ��㣬�������������}
  private
    FY: TCnFP2;
    FX: TCnFP2;
    FZ: TCnFP2;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ת��Ϊ�ַ���}
    procedure SetZero;
    {* ����Ϊȫ 0���ƺ�ûɶ��}
    function IsAtInfinity: Boolean;
    {* �Ƿ�λ������Զ��}
    function SetToInfinity: Boolean;
    {* ������Ϊ����Զ}
    function GetCoordinatesFP2(const FP2X, FP2Y: TCnFP2): Boolean;
    {* ��ȡ XY ����ֵ���ڲ����ø���}
    function SetCoordinatesFP2(const FP2X, FP2Y: TCnFP2): Boolean;
    {* ���� XY ����ֵ���ڲ����ø���}
    function SetCoordinatesHex(const SX0, SX1, SY0, SY1: string): Boolean;
    {* ���� XY ����ֵ��ʹ��ʮ�������ַ���}
    function SetCoordinatesBigNumbers(const X0, X1, Y0, Y1: TCnBigNumber): Boolean;
    {* ���� XY ����ֵ��ʹ�ô��������ڲ����ø���}
    function GetExtCoordinatesFP12(const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
    {* ��ȡ��չ XY ����ֵ���ڲ����ø���}
    function SetExtCoordinatesFP12(const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
    {* ������չ XY ����ֵ���ڲ����ø���}
    function IsOnCurve(Prime: TCnBigNumber): Boolean;
    {* �ж��Ƿ�����Բ���� y^2 = x^3 + 5 ��}

    property X: TCnFP2 read FX;
    property Y: TCnFP2 read FY;
    property Z: TCnFP2 read FZ;
  end;

  TCnAffinePointPool = class(TCnMathObjectPool)
  {* ��������ϵ���ƽ����ʵ���࣬����ʹ�õ���������ϵ���ƽ���ĵط����д�����}
  protected
    function CreateObject: TObject; override;
  public
    function Obtain: TCnAffinePoint; reintroduce;
    procedure Recycle(Num: TCnAffinePoint); reintroduce;
  end;

  TCnSM9 = class
  private
    FEcc: TCnEcc;
    FP1: TCnEccPoint;
    FP2: TCnEccPoint;
    FT: TCnBigNumber;
  protected
    procedure Init;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

// ====================== �����������ϵ��Ԫ�����㺯�� =========================

function FP2New: TCnFP2;
{* ����һ�����������ϵ��Ԫ�ض��󣬵�ͬ�� TCnFP2.Create}

procedure FP2Free(FP2: TCnFP2);
{* �ͷ�һ�����������ϵ��Ԫ�ض��󣬵�ͬ�� TCnFP2.Free}

function FP2IsZero(FP2: TCnFP2): Boolean;
{* �ж�һ�����������ϵ��Ԫ�ض����Ƿ�Ϊ 0}

function FP2IsOne(FP2: TCnFP2): Boolean;
{* �ж�һ�����������ϵ��Ԫ�ض����Ƿ�Ϊ 1}

function FP2SetZero(FP2: TCnFP2): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊ 0}

function FP2SetOne(FP2: TCnFP2): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊ 1��Ҳ���� [0] Ϊ 1��[1] Ϊ 0}

function FP2SetU(FP2: TCnFP2): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�����Ϊ U��Ҳ���� [0] Ϊ 0��[1] Ϊ 1}

function FP2SetBigNumber(const FP2: TCnFP2; const Num: TCnBigNumber): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊĳһ������}

function FP2SetBigNumbers(const FP2: TCnFP2; const Num0, Num1: TCnBigNumber): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊ��������ֵ}

function FP2SetHex(const FP2: TCnFP2; const S0, S1: string): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊ����ʮ�������ַ���}

function FP2ToString(const FP2: TCnFP2): string;
{* ��һ�����������ϵ��Ԫ�ض���ת��Ϊ�ַ���}

function FP2SetWord(const FP2: TCnFP2; Value: Cardinal): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊһ�� Cardinal}

function FP2SetWords(const FP2: TCnFP2; Value0, Value1: Cardinal): Boolean;
{* ��һ�����������ϵ��Ԫ�ض�������Ϊ���� Cardinal}

function FP2Equal(const F1, F2: TCnFP2): Boolean;
{* �ж����������������ϵ��Ԫ�ض���ֵ�Ƿ����}

function FP2Copy(const Dst, Src: TCnFP2): TCnFP2;
{* ��һ�����������ϵ��Ԫ�ض���ֵ���Ƶ���һ�������������ϵ��Ԫ�ض�����}

function FP2Negate(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
{* ��һ�����������ϵ��Ԫ�ض���ֵ����������}

function FP2Add(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* �������ж����������ϵ��Ԫ�ؼӷ���Prime Ϊ��������Res ������ F1��F2��F1 ������ F2}

function FP2Sub(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* �������ж����������ϵ��Ԫ�ؼ�����Prime Ϊ��������Res ������ F1��F2��F1 ������ F2}

function FP2Mul(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean; overload;
{* �������ж����������ϵ��Ԫ�س˷���Prime Ϊ��������Res �������� F1 �� F2��F1 ������ F2}

function FP2Mul3(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
{* �������ж����������ϵ��Ԫ�ض������ 3��Prime Ϊ��������Res ������ F}

function FP2MulU(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* �������ж����������ϵ��Ԫ�� U �˷���Prime Ϊ��������Res �������� F1 �� F2��F1 ������ F2}

function FP2Mul(const Res: TCnFP2; const F: TCnFP2; Num: TCnBigNumber; Prime: TCnBigNumber): Boolean; overload;
{* �������ж����������ϵ��Ԫ��������ĳ˷���Prime Ϊ��������Res ������ F���� Num ������ Res �� F �е�����}

function FP2Inverse(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
{* �������ж����������ϵ��Ԫ����ģ����Prime Ϊ��������Res ������ F}

function FP2Div(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
{* �������ж����������ϵ��Ԫ�س�����Prime Ϊ��������Res ������ F1��F2��F1 ������ F2���ڲ���ģ���˷�ʵ��}

// ====================== �Ĵ��������ϵ��Ԫ�����㺯�� =========================

function FP4New: TCnFP4;
{* ����һ�Ĵ��������ϵ��Ԫ�ض��󣬵�ͬ�� TCnFP4.Create}

procedure FP4Free(FP4: TCnFP4);
{* �ͷ�һ�Ĵ��������ϵ��Ԫ�ض��󣬵�ͬ�� TCnFP4.Free}

function FP4IsZero(FP4: TCnFP4): Boolean;
{* �ж�һ�Ĵ��������ϵ��Ԫ�ض����Ƿ�Ϊ 0}

function FP4IsOne(FP4: TCnFP4): Boolean;
{* �ж�һ�Ĵ��������ϵ��Ԫ�ض����Ƿ�Ϊ 1}

function FP4SetZero(FP4: TCnFP4): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊ 0}

function FP4SetOne(FP4: TCnFP4): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊ 1��Ҳ���� [0] Ϊ 1��[1] Ϊ 0}

function FP4SetU(FP4: TCnFP4): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�����Ϊ U��Ҳ���� [0] Ϊ U��[1] Ϊ 0}

function FP4SetV(FP4: TCnFP4): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�����Ϊ V��Ҳ���� [0] Ϊ 0��[1] Ϊ 1}

function FP4SetBigNumber(const FP4: TCnFP4; const Num: TCnBigNumber): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊĳһ������}

function FP4SetBigNumbers(const FP4: TCnFP4; const Num0, Num1: TCnBigNumber): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊ��������ֵ}

function FP4SetFP2(const FP4: TCnFP4; const FP2: TCnFP2): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊһ�������������ϵ��Ԫ��}

function FP4Set2FP2S(const FP4: TCnFP4; const FP20, FP21: TCnFP2): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊ���������������ϵ��Ԫ��}

function FP4SetHex(const FP4: TCnFP4; const S0, S1, S2, S3: string): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊ�ĸ�ʮ�������ַ���}

function FP4ToString(const FP4: TCnFP4): string;
{* ��һ�Ĵ��������ϵ��Ԫ�ض���ת��Ϊ�ַ���}

function FP4SetWord(const FP4: TCnFP4; Value: Cardinal): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊһ�� Cardinal}

function FP4SetWords(const FP4: TCnFP4; Value0, Value1, Value2, Value3: Cardinal): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض�������Ϊ�ĸ� Cardinal}

function FP4Equal(const F1, F2: TCnFP4): Boolean;
{* �ж������Ĵ��������ϵ��Ԫ�ض���ֵ�Ƿ����}

function FP4Copy(const Dst, Src: TCnFP4): TCnFP4;
{* ��һ�Ĵ��������ϵ��Ԫ�ض���ֵ���Ƶ���һ���Ĵ��������ϵ��Ԫ�ض�����}

function FP4Negate(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ��һ�Ĵ��������ϵ��Ԫ�ض���ֵ����������}

function FP4Add(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ�ؼӷ���Prime Ϊ��������Res ������ F1��F2��F1 ������ F2}

function FP4Sub(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ�ؼ�����Prime Ϊ��������Res ������ F1��F2��F1 ������ F2}

function FP4Mul(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ�س˷���Prime Ϊ��������Res �������� F1 �� F2��F1 ������ F2}

function FP4Mul3(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ�ض������ 3��Prime Ϊ��������Res ������ F}

function FP4MulV(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ�� V �˷���Prime Ϊ��������Res �������� F1 �� F2��F1 ������ F2}

function FP4Inverse(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ����ģ����Prime Ϊ��������Res ������ F}

function FP4Div(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
{* ���������Ĵ��������ϵ��Ԫ�س�����Prime Ϊ��������Res ������ F1��F2��F1 ������ F2���ڲ���ģ���˷�ʵ��}

// ===================== ʮ�����������ϵ��Ԫ�����㺯�� ========================

function FP12New: TCnFP12;
{* ����һʮ�����������ϵ��Ԫ�ض��󣬵�ͬ�� TCnFP12.Create}

procedure FP12Free(FP12: TCnFP12);
{* �ͷ�һʮ�����������ϵ��Ԫ�ض��󣬵�ͬ�� TCnFP12.Free}

function FP12IsZero(FP12: TCnFP12): Boolean;
{* �ж�һʮ�����������ϵ��Ԫ�ض����Ƿ�Ϊ 0}

function FP12IsOne(FP12: TCnFP12): Boolean;
{* �ж�һʮ�����������ϵ��Ԫ�ض����Ƿ�Ϊ 1}

function FP12SetZero(FP12: TCnFP12): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊ 0}

function FP12SetOne(FP12: TCnFP12): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊ 1}

function FP12SetU(FP12: TCnFP12): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�����Ϊ U��Ҳ������ FP4 �ֱ� U��0��0}

function FP12SetV(FP12: TCnFP12): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�����Ϊ V��Ҳ������ FP4 �ֱ� V��0��0}

function FP12SetW(FP12: TCnFP12): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�����Ϊ W��Ҳ������ FP4 �ֱ� 0��1��0}

function FP12SetWSqr(FP12: TCnFP12): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�����Ϊ W^2��Ҳ������ FP4 �ֱ� 0��0��1}

function FP12SetBigNumber(const FP12: TCnFP12; const Num: TCnBigNumber): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊĳһ������}

function FP12SetBigNumbers(const FP12: TCnFP12; const Num0, Num1, Num2: TCnBigNumber): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊ��������ֵ}

function FP12SetFP4(const FP12: TCnFP12; const FP4: TCnFP4): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊһ���Ĵ��������ϵ��Ԫ��}

function FP12Set3FP4S(const FP12: TCnFP12; const FP40, FP41, FP42: TCnFP4): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊ�����Ĵ��������ϵ��Ԫ��}

function FP12SetFP2(const FP12: TCnFP12; const FP2: TCnFP2): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊһ�������������ϵ��Ԫ��}

function FP12SetHex(const FP12: TCnFP12; const S0, S1, S2, S3, S4, S5, S6, S7, S8,
  S9, S10, S11: string): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊʮ����ʮ�������ַ���}

function FP12ToString(const FP12: TCnFP12): string;
{* ��һʮ�����������ϵ��Ԫ�ض���ת��Ϊ�ַ���}

function FP12SetWord(const FP12: TCnFP12; Value: Cardinal): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊһ�� Cardinal}

function FP12SetWords(const FP12: TCnFP12; Value0, Value1, Value2, Value3, Value4,
  Value5, Value6, Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض�������Ϊʮ���� Cardinal}

function FP12Equal(const F1, F2: TCnFP12): Boolean;
{* �ж�����ʮ�����������ϵ��Ԫ�ض���ֵ�Ƿ����}

function FP12Copy(const Dst, Src: TCnFP12): TCnFP12;
{* ��һʮ�����������ϵ��Ԫ�ض���ֵ���Ƶ���һ��ʮ�����������ϵ��Ԫ�ض�����}

function FP12Negate(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��һʮ�����������ϵ��Ԫ�ض���ֵ����������}

function FP12Add(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ�ؼӷ���Prime Ϊ��������Res ������ F1��F2��F1 ������ F2}

function FP12Sub(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ�ؼ�����Prime Ϊ��������Res ������ F1��F2��F1 ������ F2}

function FP12Mul(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ�س˷���Prime Ϊ��������Res �������� F1 �� F2��F1 ������ F2}

function FP12Mul3(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ�ض������ 3��Prime Ϊ��������Res ������ F}

function FP12Inverse(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ����ģ����Prime Ϊ��������Res ������ F}

function FP12Div(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ�س�����Prime Ϊ��������Res ������ F1��F2��F1 ������ F2���ڲ���ģ���˷�ʵ��}

function FP12Power(const Res: TCnFP12; const F: TCnFP12; Exponent: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* ��������ʮ�����������ϵ��Ԫ�س˷���Prime Ϊ��������Res ������ F����δ����}

// ===================== ��������ϵ�����Ԫ������㺯�� ========================

function AffinePointNew: TCnAffinePoint;
{* ����һ��������ϵ�����Ԫ����󣬵�ͬ�� TCnAffinePoint.Create}

procedure AffinePointFree(P: TCnAffinePoint);
{* �ͷ�һ��������ϵ�����Ԫ����󣬵�ͬ�� TCnAffinePoint.Free}

procedure AffinePointSetZero(P: TCnAffinePoint);
{* ��һ����������ϵ�����Ԫ����������Ϊȫ 0}

function AffinePointToString(const P: TCnAffinePoint): string;
{* ��һ��������ϵ�����Ԫ�����ת��Ϊ�ַ���}

function AffinePointEqual(const P1, P2: TCnAffinePoint): Boolean;
{* �ж�������������ϵ�����Ԫ�����ֵ�Ƿ����}

function AffinePointCopy(const Dst, Src: TCnAffinePoint): TCnAffinePoint;
{* ��һ��������ϵ�����Ԫ�����ֵ���Ƶ���һ����������ϵ�����Ԫ�������}

function AffinePointIsAtInfinity(const P: TCnAffinePoint): Boolean;
{* �ж�һ��������ϵ�����Ԫ������Ƿ�λ������Զ��}

function AffinePointSetToInfinity(const P: TCnAffinePoint): Boolean;
{* ��һ��������ϵ�����Ԫ�����������Ϊ����Զ}

function AffinePointGetCoordinatesFP2(const P: TCnAffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
{* ��ȡһ��������ϵ�����Ԫ������ XY ����ֵ���ڲ����ø���}

function AffinePointSetCoordinatesFP2(const P: TCnAffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
{* ����һ��������ϵ�����Ԫ������ XY ����ֵ���ڲ����ø���}

function AffinePointSetCoordinatesHex(const P: TCnAffinePoint;
  const SX0, SX1, SY0, SY1: string): Boolean;
{* ����һ��������ϵ�����Ԫ������ XY ����ֵ��ʹ��ʮ�������ַ���}

function AffinePointSetCoordinatesBigNumbers(const P: TCnAffinePoint;
  const X0, X1, Y0, Y1: TCnBigNumber): Boolean;
{* ����һ��������ϵ�����Ԫ������ XY ����ֵ��ʹ�ô��������ڲ����ø���}

function AffinePointGetExtCoordinatesFP12(const P: TCnAffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ��ȡһ��������ϵ�����Ԫ��������չ XY ����ֵ���ڲ����ø���}

function AffinePointSetExtCoordinatesFP12(const P: TCnAffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
{* ����һ��������ϵ�����Ԫ��������չ XY ����ֵ���ڲ����ø���}

function AffinePointIsOnCurve(const P: TCnAffinePoint; Prime: TCnBigNumber): Boolean;
{* �ж�һ��������ϵ�����Ԫ������Ƿ�����Բ���� y^2 = x^3 + 5 ��}

function AffinePointNegate(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
{* һ����������ϵ�����Ԫ��������Բ�����󷴣�Res ������ P}

function AffinePointDouble(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
{* һ����������ϵ�����Ԫ��������Բ���߱��㷨��Res ������ P}

function AffinePointAdd(const Res: TCnAffinePoint; const P, Q: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
{* ������������ϵ�����Ԫ��������Բ���߼ӷ���Res ������ P �� Q��P ������ Q}

function AffinePointSub(const Res: TCnAffinePoint; const P, Q: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
{* ������������ϵ�����Ԫ��������Բ���߼�����Res ������ P �� Q��P ������ Q}

function AffinePointMul(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Num: TCnBigNumber; Prime: TCnBigNumber): Boolean;
{* һ����������ϵ�����Ԫ��������Բ���� N ���㷨��Res ������ P}

function AffinePointFrobenius(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
{* ����һ����������ϵ�����Ԫ�����ĸ��ޱ�����˹��ֵ̬ͬ��Res ������ P
  ��ʵ���� P �� Prime �η��Ľ�� mod Prime}

implementation

const
  CRLF = #13#10;

var
  FLocalBigNumberPool: TCnBigNumberPool = nil;
  FLocalFP2Pool: TCnFP2Pool = nil;
  FLocalFP4Pool: TCnFP4Pool = nil;
  FLocalFP12Pool: TCnFP12Pool = nil;
  FLocalAffinePointPool: TCnAffinePointPool = nil;

{ TCnSM9 }

constructor TCnSM9.Create;
begin
  inherited;
  FEcc := TCnEcc.Create;
  FP1 := TCnEccPoint.Create;
  FP2 := TCnEccPoint.Create;
  FT := TCnBigNumber.Create;

  Init;
end;

destructor TCnSM9.Destroy;
begin
  FT.Free;
  FP2.Free;
  FP1.Free;
  FEcc.Free;
  inherited;
end;

procedure TCnSM9.Init;
begin
  FEcc.Load('00', '05', 'B640000002A3A6F1D603AB4FF58EC74521F2934B1A7AEEDBE56F9B27E351457D',
    '', '', 'B640000002A3A6F1D603AB4FF58EC74449F2934B18EA8BEEE56EE19CD69ECF25', 1);

  FT.SetHex('600000000058F98A');

  FP1.X.SetHex('93DE051D 62BF718F F5ED0704 487D01D6 E1E40869 09DC3280 E8C4E481 7C66DDDD');
  FP1.Y.SetHex('21FE8DDA 4F21E607 63106512 5C395BBC 1C1C00CB FA602435 0C464CD7 0A3EA616');
  FP2.X.SetHex('');
  FP2.Y.SetHex('');
end;

// ====================== �����������ϵ��Ԫ�����㺯�� =========================

function FP2New: TCnFP2;
begin
  Result := TCnFP2.Create;
end;

procedure FP2Free(FP2: TCnFP2);
begin
  FP2.Free;
end;

function FP2IsZero(FP2: TCnFP2): Boolean;
begin
  Result := FP2[0].IsZero and FP2[1].IsZero;
end;

function FP2IsOne(FP2: TCnFP2): Boolean;
begin
  Result := FP2[0].IsOne and FP2[1].IsZero;
end;

function FP2SetZero(FP2: TCnFP2): Boolean;
begin
  FP2[0].SetZero;
  FP2[1].SetZero;
  Result := True;
end;

function FP2SetOne(FP2: TCnFP2): Boolean;
begin
  FP2[0].SetOne;
  FP2[1].SetZero;
  Result := True;
end;

function FP2SetU(FP2: TCnFP2): Boolean;
begin
  FP2[0].SetZero;
  FP2[1].SetOne;
  Result := True;
end;

function FP2SetBigNumber(const FP2: TCnFP2; const Num: TCnBigNumber): Boolean;
begin
  BigNumberCopy(FP2[0], Num);
  FP2[1].SetZero;
  Result := True;
end;

function FP2SetBigNumbers(const FP2: TCnFP2; const Num0, Num1: TCnBigNumber): Boolean;
begin
  BigNumberCopy(FP2[0], Num0);
  BigNumberCopy(FP2[1], Num1);
  Result := True;
end;

function FP2SetHex(const FP2: TCnFP2; const S0, S1: string): Boolean;
begin
  FP2[0].SetHex(S0);
  FP2[1].SetHex(S1);
  Result := True;
end;

function FP2ToString(const FP2: TCnFP2): string;
begin
  Result := FP2[0].ToHex + ',' + FP2[1].ToHex;
end;

function FP2SetWord(const FP2: TCnFP2; Value: Cardinal): Boolean;
begin
  FP2[0].SetWord(Value);
  FP2[1].SetZero;
  Result := True;
end;

function FP2SetWords(const FP2: TCnFP2; Value0, Value1: Cardinal): Boolean;
begin
  FP2[0].SetWord(Value0);
  FP2[1].SetWord(Value1);
  Result := True;
end;

function FP2Equal(const F1, F2: TCnFP2): Boolean;
begin
  Result := BigNumberEqual(F1[0], F2[0]) and BigNumberEqual(F1[1], F2[1]);
end;

function FP2Copy(const Dst, Src: TCnFP2): TCnFP2;
begin
  BigNumberCopy(Dst[0], Src[0]);
  BigNumberCopy(Dst[1], Src[1]);
  Result := Dst;
end;

function FP2Negate(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
begin
  BigNumberSub(Res[0], Prime, F[0]);
  BigNumberSub(Res[1], Prime, F[1]);
  BigNumberNonNegativeMod(Res[0], Res[0], Prime);
  BigNumberNonNegativeMod(Res[1], Res[1], Prime);
  Result := True;
end;

function FP2Add(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
begin
  BigNumberAdd(Res[0], F1[0], F2[0]);
  BigNumberAdd(Res[1], F1[1], F2[1]);
  BigNumberNonNegativeMod(Res[0], Res[0], Prime);
  BigNumberNonNegativeMod(Res[1], Res[1], Prime);
  Result := True;
end;

function FP2Sub(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
begin
  BigNumberSub(Res[0], F1[0], F2[0]);
  BigNumberSub(Res[1], F1[1], F2[1]);
  BigNumberNonNegativeMod(Res[0], Res[0], Prime);
  BigNumberNonNegativeMod(Res[1], Res[1], Prime);
  Result := True;
end;

function FP2Mul(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  T0, T1, R0: TCnBigNumber;
begin
  // r0 = a0 * b0 - 2 * a1 * b1
  // r1 = a0 * b1 + a1 * b0
  T0 := nil;
  T1 := nil;
  R0 := nil;

  try
    T0 := FLocalBigNumberPool.Obtain;
    T1 := FLocalBigNumberPool.Obtain;
    R0 := FLocalBigNumberPool.Obtain;

    BigNumberMul(T0, F1[0], F2[0]);
    BigNumberMul(T1, F1[1], F2[1]);
    BigNumberAdd(T1, T1, T1);
    BigNumberSub(T0, T0, T1);
    BigNumberNonNegativeMod(R0, T0, Prime); // ����ֱ�Ӹ� Res[0] ��ֵ����һ F1 �� Res ��ͬ�����ǰӰ�� F0

    BigNumberMul(T0, F1[0], F2[1]);
    BigNumberMul(T1, F1[1], F2[0]);
    BigNumberAdd(T1, T0, T1);
    BigNumberNonNegativeMod(Res[1], T1, Prime);

    BigNumberCopy(Res[0], R0);
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(R0);
    FLocalBigNumberPool.Recycle(T1);
    FLocalBigNumberPool.Recycle(T0);
  end;
end;

function FP2Mul3(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  T: TCnFP2;
begin
  T := FLocalFP2Pool.Obtain;
  try
    FP2Add(T, F, F, Prime);
    FP2Add(Res, T, F, Prime);
    Result := True;
  finally
    FLocalFP2Pool.Recycle(T);
  end;
end;

function FP2MulU(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  T0, T1: TCnBigNumber;
begin
  // r0 = -2 * (a0 * b1 + a1 * b0)
  // r1 = a0 * b0 - 2 * a1 * b1
  T0 := nil;
  T1 := nil;
  try
    T0 := FLocalBigNumberPool.Obtain;
    T1 := FLocalBigNumberPool.Obtain;

    BigNumberMul(T0, F1[0], F2[1]);
    BigNumberMul(T1, F1[1], F2[0]);
    BigNumberAdd(T0, T0, T1);
    T0.MulWord(2);
    T0.Negate;
    BigNumberNonNegativeMod(Res[0], T0, Prime);

    BigNumberMul(T0, F1[0], F2[0]);
    BigNumberMul(T1, F1[1], F2[1]);
    T1.MulWord(2);
    BigNumberSub(T1, T0, T1);
    BigNumberNonNegativeMod(Res[1], T1, Prime);
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(T1);
    FLocalBigNumberPool.Recycle(T0);
  end;
end;

function FP2Mul(const Res: TCnFP2; const F: TCnFP2; Num: TCnBigNumber; Prime: TCnBigNumber): Boolean;
begin
  BigNumberMul(Res[0], F[0], Num);
  BigNumberMul(Res[1], F[1], Num);
  BigNumberNonNegativeMod(Res[0], Res[0], Prime);
  BigNumberNonNegativeMod(Res[1], Res[1], Prime);
  Result := True;
end;

function FP2Inverse(const Res: TCnFP2; const F: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  K, T: TCnBigNumber;
begin
  if F[0].IsZero then
  begin
    Res[0].SetZero;
    // r1 = -((2 * a1)^-1) */
    BigNumberAdd(Res[1], F[1], F[1]);
    BigNumberModularInverse(Res[1], Res[1], Prime);
    BigNumberNonNegativeMod(Res[1], Res[1], Prime);
    BigNumberSub(Res[1], Prime, Res[1]);
    Result := True;
  end
  else if F[1].IsZero then
  begin
    Res[1].SetZero;
    // r0 = a0^-1
    BigNumberModularInverse(Res[0], F[0], Prime);
    Result := True;
  end
  else
  begin
    // k = (a[0]^2 + 2 * a[1]^2)^-1
    // r[0] = a[0] * k
    // r[1] = -a[1] * k
    K := nil;
    T := nil;
    try
      K := FLocalBigNumberPool.Obtain;
      T := FLocalBigNumberPool.Obtain;

      BigNumberMul(T, F[1], F[1]);
      T.MulWord(2);
      BigNumberMul(K, F[0], F[0]);
      BigNumberAdd(K, T, K);
      BigNumberModularInverse(K, K, Prime);

      BigNumberMul(Res[0], F[0], K);
      BigNumberNonNegativeMod(Res[0], Res[0], Prime);

      BigNumberMul(Res[1], F[1], K);
      BigNumberNonNegativeMod(Res[1], Res[1], Prime);
      BigNumberSub(Res[1], Prime, Res[1]);
      Result := True;
    finally
      FLocalBigNumberPool.Recycle(T);
      FLocalBigNumberPool.Recycle(K);
    end;
  end;
end;

function FP2Div(const Res: TCnFP2; const F1, F2: TCnFP2; Prime: TCnBigNumber): Boolean;
var
  Inv: TCnFP2;
begin
  if F2.IsZero then
    raise EZeroDivide.Create(SDivByZero);

  if F1 = F2 then
  begin
    Res.SetOne;
    Result := True;
  end
  else
  begin
    Inv := FLocalFP2Pool.Obtain;
    try
      Result := FP2Inverse(Inv, F2, Prime);
      if Result then
        Result := FP2Mul(Res, F1, Inv, Prime);
    finally
      FLocalFP2Pool.Recycle(Inv);
    end;
  end;
end;

// ====================== �Ĵ��������ϵ��Ԫ�����㺯�� =========================

function FP4New: TCnFP4;
begin
  Result := TCnFP4.Create;
end;

procedure FP4Free(FP4: TCnFP4);
begin
  FP4.Free;
end;

function FP4IsZero(FP4: TCnFP4): Boolean;
begin
  Result := FP4[0].IsZero and FP4[1].IsZero;
end;

function FP4IsOne(FP4: TCnFP4): Boolean;
begin
  Result := FP4[0].IsOne and FP4[1].IsZero;
end;

function FP4SetZero(FP4: TCnFP4): Boolean;
begin
  FP4[0].SetZero;
  FP4[1].SetZero;
  Result := True;
end;

function FP4SetOne(FP4: TCnFP4): Boolean;
begin
  FP4[1].SetZero;
  FP4[0].SetOne;
  Result := True;
end;

function FP4SetU(FP4: TCnFP4): Boolean;
begin
  FP4[1].SetZero;
  FP4[0].SetU;
  Result := True;
end;

function FP4SetV(FP4: TCnFP4): Boolean;
begin
  FP4[0].SetZero;
  FP4[1].SetOne;
  Result := True;
end;

function FP4SetBigNumber(const FP4: TCnFP4; const Num: TCnBigNumber): Boolean;
begin
  FP4[1].SetZero;
  FP4[0].SetBigNumber(Num);
  Result := True;
end;

function FP4SetBigNumbers(const FP4: TCnFP4; const Num0, Num1: TCnBigNumber): Boolean;
begin
  FP4[0].SetBigNumber(Num0);
  FP4[1].SetBigNumber(Num1);
  Result := True;
end;

function FP4SetFP2(const FP4: TCnFP4; const FP2: TCnFP2): Boolean;
begin
  FP4[1].SetZero;
  FP2Copy(FP4[0], FP2);
  Result := True;
end;

function FP4Set2FP2S(const FP4: TCnFP4; const FP20, FP21: TCnFP2): Boolean;
begin
  FP2Copy(FP4[0], FP20);
  FP2Copy(FP4[1], FP21);
  Result := True;
end;

function FP4SetHex(const FP4: TCnFP4; const S0, S1, S2, S3: string): Boolean;
begin
  FP4[1].SetHex(S2, S3);
  FP4[0].SetHex(S0, S1);
  Result := True;
end;

function FP4ToString(const FP4: TCnFP4): string;
begin
  Result := FP4[0].ToString + CRLF + FP4[1].ToString;
end;

function FP4SetWord(const FP4: TCnFP4; Value: Cardinal): Boolean;
begin
  FP4[1].SetZero;
  FP4[0].SetWord(Value);
  Result := True;
end;

function FP4SetWords(const FP4: TCnFP4; Value0, Value1, Value2, Value3: Cardinal): Boolean;
begin
  FP4[0].SetWords(Value0, Value1);
  FP4[1].SetWords(Value2, Value3);
  Result := True;
end;

function FP4Equal(const F1, F2: TCnFP4): Boolean;
begin
  Result := FP2Equal(F1[0], F2[0]) and FP2Equal(F1[1], F2[1]);
end;

function FP4Copy(const Dst, Src: TCnFP4): TCnFP4;
begin
  FP2Copy(Dst[0], Src[0]);
  FP2Copy(Dst[1], Src[1]);
  Result := Dst;
end;

function FP4Negate(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
begin
  Result := FP2Negate(Res[0], F[0], Prime) and FP2Negate(Res[1], F[1], Prime);
end;

function FP4Add(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
begin
  Result := FP2Add(Res[0], F1[0], F2[0], Prime) and FP2Add(Res[1], F1[1], F2[1], Prime);
end;

function FP4Sub(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
begin
  Result := FP2Sub(Res[0], F1[0], F2[0], Prime) and FP2Sub(Res[1], F1[1], F2[1], Prime);
end;

function FP4Mul(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  T, R0, R1: TCnFP2;
begin
  // r0 = a0 * b0 + a1 * b1 * u
  // r1 = a0 * b1 + a1 * b0
  T := nil;
  R0 := nil;
  R1 := nil;

  try
    T := FLocalFP2Pool.Obtain;
    R0 := FLocalFP2Pool.Obtain;
    R1 := FLocalFP2Pool.Obtain;

    FP2Mul(R0, F1[0], F2[0], Prime);
    FP2MulU(T, F1[1], F2[1], Prime);
    FP2Add(R0, R0, T, Prime);

    FP2Mul(R1, F1[0], F2[1], Prime);
    FP2Mul(T, F1[1], F2[0], Prime);
    FP2Add(Res[1], R1, T, Prime);

    FP2Copy(Res[0], R0);
    Result := True;
  finally
    FLocalFP2Pool.Recycle(R1);
    FLocalFP2Pool.Recycle(R0);
    FLocalFP2Pool.Recycle(T);
  end;
end;

function FP4Mul3(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  T: TCnFP4;
begin
  T := FLocalFP4Pool.Obtain;
  try
    FP4Add(T, F, F, Prime);
    FP4Add(Res, T, F, Prime);
    Result := True;
  finally
    FLocalFP4Pool.Recycle(T);
  end;
end;

function FP4MulV(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  T, R0, R1: TCnFP2;
begin
  // r0 = a0 * b1 * u + a1 * b0 * u
  // r1 = a0 * b0 + a1 * b1 * u
  T := nil;
  R0 := nil;
  R1 := nil;

  try
    T := FLocalFP2Pool.Obtain;
    R0 := FLocalFP2Pool.Obtain;
    R1 := FLocalFP2Pool.Obtain;

    FP2MulU(R0, F1[0], F2[1], Prime);
    FP2MulU(T, F1[1], F2[0], Prime);
    FP2Add(R0, R0, T, Prime);

    FP2Mul(R1, F1[0], F2[0], Prime);
    FP2MulU(T, F1[1], F2[1], Prime);
    FP2Add(Res[1], R1, T, Prime);

    FP2Copy(Res[0], R0);
    Result := True;
  finally
    FLocalFP2Pool.Recycle(R1);
    FLocalFP2Pool.Recycle(R0);
    FLocalFP2Pool.Recycle(T);
  end;
end;

function FP4Inverse(const Res: TCnFP4; const F: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  R0, R1, K: TCnFP2;
begin
  // k = (f1^2 * u - f0^2)^-1
  // r0 = -(f0 * k)
  // r1 = f1 * k
  K := nil;
  R0 := nil;
  R1 := nil;

  try
    K := FLocalFP2Pool.Obtain;
    R0 := FLocalFP2Pool.Obtain;
    R1 := FLocalFP2Pool.Obtain;

    FP2MulU(K, F[1], F[1], Prime);
    FP2Mul(R0, F[0], F[0], Prime);
    FP2Sub(K, K, R0, Prime);
    FP2Inverse(K, K, Prime);

    FP2Mul(R0, F[0], K, Prime);
    FP2Negate(R0, R0, Prime);

    FP2Mul(R1, F[1], K, Prime);

    FP2Copy(Res[0], R0);
    FP2Copy(Res[1], R1);
    Result := True;
  finally
    FLocalFP2Pool.Recycle(R1);
    FLocalFP2Pool.Recycle(R0);
    FLocalFP2Pool.Recycle(K);
  end;
end;

function FP4Div(const Res: TCnFP4; const F1, F2: TCnFP4; Prime: TCnBigNumber): Boolean;
var
  Inv: TCnFP4;
begin
  if F2.IsZero then
    raise EZeroDivide.Create(SDivByZero);

  if F1 = F2 then
  begin
    Res.SetOne;
    Result := True;
  end
  else
  begin
    Inv := FLocalFP4Pool.Obtain;
    try
      Result := FP4Inverse(Inv, F2, Prime);
      if Result then
        Result := FP4Mul(Res, F1, Inv, Prime);
    finally
      FLocalFP4Pool.Recycle(Inv);
    end;
  end;
end;

function FP12New: TCnFP12;
begin
  Result := TCnFP12.Create;
end;

procedure FP12Free(FP12: TCnFP12);
begin
  FP12.Free;
end;

function FP12IsZero(FP12: TCnFP12): Boolean;
begin
  Result := FP12[0].IsZero and FP12[1].IsZero and FP12[2].IsZero;
end;

function FP12IsOne(FP12: TCnFP12): Boolean;
begin
  Result := FP12[0].IsOne and FP12[1].IsZero and FP12[2].IsZero;
end;

function FP12SetZero(FP12: TCnFP12): Boolean;
begin
  FP12[0].SetZero;
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetOne(FP12: TCnFP12): Boolean;
begin
  FP12[0].SetOne;
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetU(FP12: TCnFP12): Boolean;
begin
  FP12[0].SetU;
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetV(FP12: TCnFP12): Boolean;
begin
  FP12[0].SetV;
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetW(FP12: TCnFP12): Boolean;
begin
  FP12[0].SetZero;
  FP12[1].SetOne;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetWSqr(FP12: TCnFP12): Boolean;
begin
  FP12[0].SetZero;
  FP12[1].SetZero;
  FP12[2].SetOne;
  Result := True;
end;

function FP12SetBigNumber(const FP12: TCnFP12; const Num: TCnBigNumber): Boolean;
begin
  FP12[0].SetBigNumber(Num);
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetBigNumbers(const FP12: TCnFP12; const Num0, Num1, Num2: TCnBigNumber): Boolean;
begin
  FP12[0].SetBigNumber(Num0);
  FP12[1].SetBigNumber(Num1);
  FP12[2].SetBigNumber(Num2);
  Result := True;
end;

function FP12SetFP4(const FP12: TCnFP12; const FP4: TCnFP4): Boolean;
begin
  FP4Copy(FP12[0], FP4);
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12Set3FP4S(const FP12: TCnFP12; const FP40, FP41, FP42: TCnFP4): Boolean;
begin
  FP4Copy(FP12[0], FP40);
  FP4Copy(FP12[1], FP41);
  FP4Copy(FP12[2], FP42);
  Result := True;
end;

function FP12SetFP2(const FP12: TCnFP12; const FP2: TCnFP2): Boolean;
begin
  FP4SetFP2(FP12[0], FP2);
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetHex(const FP12: TCnFP12; const S0, S1, S2, S3, S4, S5, S6, S7, S8,
  S9, S10, S11: string): Boolean;
begin
  FP12[0].SetHex(S0, S1, S2, S3);
  FP12[1].SetHex(S4, S5, S6, S7);
  FP12[2].SetHex(S8, S9, S10, S11);
  Result := True;
end;

function FP12ToString(const FP12: TCnFP12): string;
begin
  Result := FP12[0].ToString + CRLF + FP12[1].ToString + CRLF + FP12[2].ToString;
end;

function FP12SetWord(const FP12: TCnFP12; Value: Cardinal): Boolean;
begin
  FP4SetWord(FP12[0], Value);
  FP12[1].SetZero;
  FP12[2].SetZero;
  Result := True;
end;

function FP12SetWords(const FP12: TCnFP12; Value0, Value1, Value2, Value3, Value4,
  Value5, Value6, Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;
begin
  FP12[0].SetWords(Value0, Value1, Value2, Value3);
  FP12[1].SetWords(Value4, Value5, Value6, Value7);
  FP12[2].SetWords(Value8, Value9, Value10, Value11);
  Result := True;
end;

function FP12Equal(const F1, F2: TCnFP12): Boolean;
begin
  Result := FP4Equal(F1[0], F2[0]) and FP4Equal(F1[1], F2[1]) and FP4Equal(F1[2], F2[2]);
end;

function FP12Copy(const Dst, Src: TCnFP12): TCnFP12;
begin
  FP4Copy(Dst[0], Src[0]);
  FP4Copy(Dst[1], Src[1]);
  FP4Copy(Dst[2], Src[2]);
  Result := Dst;
end;

function FP12Negate(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  FP4Negate(Res[0], F[0], Prime);
  FP4Negate(Res[1], F[1], Prime);
  FP4Negate(Res[2], F[2], Prime);
  Result := True;
end;

function FP12Add(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  FP4Add(Res[0], F1[0], F2[0], Prime);
  FP4Add(Res[1], F1[1], F2[1], Prime);
  FP4Add(Res[2], F1[2], F2[2], Prime);
  Result := True;
end;

function FP12Sub(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
begin
  FP4Sub(Res[0], F1[0], F2[0], Prime);
  FP4Sub(Res[1], F1[1], F2[1], Prime);
  FP4Sub(Res[2], F1[2], F2[2], Prime);
  Result := True;
end;

function FP12Mul(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  T, R0, R1, R2: TCnFP4;
begin
  // r0 = a0 * b0 + a1 * b2 * v + a2 * b1 * v
  // r1 = a0 * b1 + a1 * b0 + a2 * b2 *v
  // r2 = a0 * b2 + a1 * b1 + a2 * b0
  T := nil;
  R0 := nil;
  R1 := nil;
  R2 := nil;

  try
    T := FLocalFP4Pool.Obtain;
    R0 := FLocalFP4Pool.Obtain;
    R1 := FLocalFP4Pool.Obtain;
    R2 := FLocalFP4Pool.Obtain;

    FP4Mul(R0, F1[0], F2[0], Prime);
    FP4MulV(T, F1[1], F2[2], Prime);
    FP4Add(R0, R0, T, Prime);
    FP4MulV(T, F1[2], F2[1], Prime);
    FP4Add(R0, R0, T, Prime);

    FP4Mul(R1, F1[0], F2[1], Prime);
    FP4Mul(T, F1[1], F2[0], Prime);
    FP4Add(R1, R1, T, Prime);
    FP4MulV(T, F1[2], F2[2], Prime);
    FP4Add(R1, R1, T, Prime);

    FP4Mul(R2, F1[0], F2[2], Prime);
    FP4Mul(T, F1[1], F2[1], Prime);
    FP4Add(R2, R2, T, Prime);
    FP4Mul(T, F1[2], F2[0], Prime);
    FP4Add(R2, R2, T, Prime);

    FP4Copy(Res[0], R0);
    FP4Copy(Res[1], R1);
    FP4Copy(Res[2], R2);

    Result := True;
  finally
    FLocalFP4Pool.Recycle(R2);
    FLocalFP4Pool.Recycle(R1);
    FLocalFP4Pool.Recycle(R0);
    FLocalFP4Pool.Recycle(T);
  end;
end;

function FP12Mul3(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  T: TCnFP12;
begin
  T := FLocalFP12Pool.Obtain;
  try
    FP12Add(T, F, F, Prime);
    FP12Add(Res, T, F, Prime);
    Result := True;
  finally
    FLocalFP12Pool.Recycle(T);
  end;
end;

function FP12Inverse(const Res: TCnFP12; const F: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  K, T, T0, T1, T2, T3: TCnFP4;
begin
  if FP4IsZero(F[2]) then // �ֿ�����
  begin
    // k = (f0^3 + f1^3 * v)^-1
    // r2 = f1^2 * k
    // r1 = -(f0 * f1 * k)
    // r0 = f0^2 * k
    K := nil;
    T := nil;

    try
      K := FLocalFP4Pool.Obtain;
      T := FLocalFP4Pool.Obtain;

      FP4Mul(K, F[0], F[0], Prime);
      FP4Mul(K, K, F[0], Prime);
      FP4MulV(T, F[1], F[1], Prime);
      FP4Mul(T, T, F[1], Prime);
      FP4Add(K, K, T, Prime);
      FP4Inverse(K, K, Prime);

      FP4Mul(T, F[1], F[1], Prime);
      FP4Mul(Res[2], T, K, Prime);

      FP4Mul(T, F[0], F[1], Prime);
      FP4Mul(T, T, K, Prime);
      FP4Negate(Res[1], T, Prime);

      FP4Mul(T, F[0], F[0], Prime);
      FP4Mul(Res[0], T, K, Prime);

      Result := True;
    finally
      FLocalFP4Pool.Recycle(T);
      FLocalFP4Pool.Recycle(K);
    end;
  end
  else
  begin
    T := nil;
    T0 := nil;
    T1 := nil;
    T2 := nil;
    T3 := nil;

    try
      T := FLocalFP4Pool.Obtain;
      T0 := FLocalFP4Pool.Obtain;
      T1 := FLocalFP4Pool.Obtain;
      T2 := FLocalFP4Pool.Obtain;
      T3 := FLocalFP4Pool.Obtain;

      // t0 = f1^2 - f0 * f2
      // t1 = f0 * f1 - f2^2 * v
      // t2 = f0^2 - f1 * f2 * v
      // t3 = f2 * (t1^2 - t0 * t2)^-1
      FP4Mul(T0, F[1], F[1], Prime);
      FP4Mul(T1, F[0], F[2], Prime);
      FP4Sub(T0, T0, T1, Prime);

      FP4Mul(T1, F[0], F[1], Prime);
      FP4MulV(T2, F[2], F[2], Prime);
      FP4Sub(T1, T1, T2, Prime);

      FP4Mul(T2, F[0], F[0], Prime);
      FP4MulV(T3, F[1], F[2], Prime);
      FP4Sub(T2, T2, T3, Prime);

      FP4Mul(T3, T1, T1, Prime);
      FP4Mul(T, T0, T2, Prime);
      FP4Sub(T3, T3, T, Prime);
      FP4Inverse(T3, T3, Prime);
      FP4Mul(T3, F[2], T3, Prime);

      // r0 = t2 * t3
      // r1 = -(t1 * t3)
      // r2 = t0 * t3
      FP4Mul(Res[0], T2, T3, Prime);

      FP4Mul(Res[1], T1, T3, Prime);
      FP4Negate(Res[1], Res[1], Prime);

      FP4Mul(Res[2], T0, T3, Prime);

      Result := True;
    finally
      FLocalFP4Pool.Recycle(T3);
      FLocalFP4Pool.Recycle(T2);
      FLocalFP4Pool.Recycle(T1);
      FLocalFP4Pool.Recycle(T0);
      FLocalFP4Pool.Recycle(T);
    end;
  end;
end;

function FP12Div(const Res: TCnFP12; const F1, F2: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  Inv: TCnFP12;
begin
  if F2.IsZero then
    raise EZeroDivide.Create(SDivByZero);

  if F1 = F2 then
  begin
    Res.SetOne;
    Result := True;
  end
  else
  begin
    Inv := FLocalFP12Pool.Obtain;
    try
      Result := FP12Inverse(Inv, F2, Prime);
      if Result then
        Result := FP12Mul(Res, F1, Inv, Prime);
    finally
      FLocalFP12Pool.Recycle(Inv);
    end;
  end;
end;

function FP12Power(const Res: TCnFP12; const F: TCnFP12; Exponent: TCnBigNumber;
  Prime: TCnBigNumber): Boolean;
var
  I, N: Integer;
  T: TCnFP12;
begin
  if Exponent.IsZero then
  begin
    Res.SetOne;
    Result := True;
    Exit;
  end
  else if Exponent.IsOne then
  begin
    FP12Copy(Res, F);
    Result := True;
    Exit;
  end;

  N := Exponent.GetBitsCount;
  if Res = F then
    T := FLocalFP12Pool.Obtain
  else
    T := Res;

  FP12Copy(T, F);

  try
    for I := N - 2 downto 0 do  // ָ�������� 6 �� 13 ��֤���ƺ��ǶԵ�
    begin
      FP12Mul(T, T, T, Prime);
      if Exponent.IsBitSet(I) then
        FP12Mul(T, T, F, Prime);
    end;

    if Res = F then
      FP12Copy(Res, T);
    Result := True;
  finally
    if Res = F then
      FLocalFP12Pool.Recycle(T);
  end;
end;

function AffinePointNew: TCnAffinePoint;
begin
  Result := TCnAffinePoint.Create;
end;

procedure AffinePointFree(P: TCnAffinePoint);
begin
  P.Free;
end;

procedure AffinePointSetZero(P: TCnAffinePoint);
begin
  P.X.SetZero;
  P.Y.SetZero;
  P.Z.SetZero;
end;

function AffinePointToString(const P: TCnAffinePoint): string;
begin
  Result := 'X: ' + P.X.ToString + CRLF + 'Y: ' + P.Y.ToString + CRLF + 'Z: ' + P.Z.ToString;
end;

function AffinePointEqual(const P1, P2: TCnAffinePoint): Boolean;
begin
  Result := FP2Equal(P1.X, P2.X) and FP2Equal(P1.Y, P2.Y) and FP2Equal(P1.Z, P2.Z);
end;

function AffinePointCopy(const Dst, Src: TCnAffinePoint): TCnAffinePoint;
begin
  FP2Copy(Dst.X, Src.X);
  FP2Copy(Dst.Y, Src.Y);
  FP2Copy(Dst.Z, Src.Z);
  Result := Dst;
end;

function AffinePointIsAtInfinity(const P: TCnAffinePoint): Boolean;
begin
  Result := FP2IsZero(P.X) and FP2IsOne(P.Y) and FP2IsZero(P.Z);
end;

function AffinePointSetToInfinity(const P: TCnAffinePoint): Boolean;
begin
  P.X.SetZero;
  P.Y.SetOne;
  P.Z.SetZero;
  Result := True;
end;

function AffinePointGetCoordinatesFP2(const P: TCnAffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
begin
  Result := False;
  if P.Z.IsOne then
  begin
    FP2Copy(FP2X, P.X);
    FP2Copy(FP2Y, P.Y);
    Result := True;
  end;
end;

function AffinePointSetCoordinatesFP2(const P: TCnAffinePoint; const FP2X, FP2Y: TCnFP2): Boolean;
begin
  FP2Copy(P.X, FP2X);
  FP2Copy(P.Y, FP2Y);
  FP2SetOne(P.Z);
  Result := True;
end;

function AffinePointSetCoordinatesHex(const P: TCnAffinePoint;
  const SX0, SX1, SY0, SY1: string): Boolean;
begin
  FP2SetHex(P.X, SX0, SX1);
  FP2SetHex(P.Y, SY0, SY1);
  FP2SetOne(P.Z);
  Result := True;
end;

function AffinePointSetCoordinatesBigNumbers(const P: TCnAffinePoint;
  const X0, X1, Y0, Y1: TCnBigNumber): Boolean;
begin
  FP2SetBigNumbers(P.X, X0, X1);
  FP2SetBigNumbers(P.Y, X1, Y1);
  FP2SetOne(P.Z);
  Result := True;
end;

function AffinePointGetExtCoordinatesFP12(const P: TCnAffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  X, Y: TCnFP2;
  W: TCnFP12;
begin
  X := nil;
  Y := nil;
  W := nil;

  try
    X := FLocalFP2Pool.Obtain;
    Y := FLocalFP2Pool.Obtain;
    W := FLocalFP12Pool.Obtain;

    AffinePointGetCoordinatesFP2(P, X, Y);
    FP12SetFP2(FP12X, X);
    FP12SetFP2(FP12Y, Y);

    // x = x * w^-2
    FP12SetWSqr(W);
    FP12Inverse(W, W, Prime);
    FP12Mul(FP12X, FP12X, W, Prime);

    // y = y * w^-3
    FP12SetV(W);
    FP12Inverse(W, W, Prime);
    FP12Mul(FP12Y, FP12Y, W, Prime);

    Result := True;
  finally
    FLocalFP2Pool.Recycle(Y);
    FLocalFP2Pool.Recycle(X);
    FLocalFP12Pool.Recycle(W);
  end;
end;

function AffinePointSetExtCoordinatesFP12(const P: TCnAffinePoint;
  const FP12X, FP12Y: TCnFP12; Prime: TCnBigNumber): Boolean;
var
  TX, TY: TCnFP12;
begin
  TX := nil;
  TY := nil;

  try
    TX := FLocalFP12Pool.Obtain;
    TY := FLocalFP12Pool.Obtain;

    FP12SetWSqr(TX);
    FP12SetV(TY);
    FP12Mul(TX, FP12X, TX, Prime);
    FP12Mul(TY, FP12Y, TY, Prime);

    AffinePointSetCoordinatesFP2(P, TX[0][0], TY[0][0]);
    Result := True;
  finally
    FLocalFP12Pool.Recycle(TY);
    FLocalFP12Pool.Recycle(TX);
  end;
end;

function AffinePointIsOnCurve(const P: TCnAffinePoint; Prime: TCnBigNumber): Boolean;
var
  X, Y, B, T: TCnFP2;
begin
  X := nil;
  Y := nil;
  B := nil;
  T := nil;

  try
    X := FLocalFP2Pool.Obtain;
    Y := FLocalFP2Pool.Obtain;
    B := FLocalFP2Pool.Obtain;
    T := FLocalFP2Pool.Obtain;

    B[0].SetZero;
    B[1].SetWord(5);   // B �� 5

    AffinePointGetCoordinatesFP2(P, X, Y);

    // X^3 + 5 u
    FP2Mul(T, X, X, Prime);
    FP2Mul(X, X, T, Prime);
    FP2Add(X, X, B, Prime);

    // Y^2
    FP2Mul(Y, Y, Y, Prime);

    Result := FP2Equal(X, Y);
  finally
    FLocalFP2Pool.Recycle(T);
    FLocalFP2Pool.Recycle(B);
    FLocalFP2Pool.Recycle(Y);
    FLocalFP2Pool.Recycle(X);
  end;
end;

function AffinePointNegate(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
begin
  FP2Copy(Res.X, P.X);
  FP2Negate(Res.Y, P.Y, Prime);
  FP2Copy(Res.Z, P.Z);
  Result := True; 
end;

function AffinePointDouble(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  L, T, X1, Y1, X2, Y2: TCnFP2;
begin
  if P.IsAtInfinity then
  begin
    Result := Res.SetToInfinity;
    Exit;
  end;

  L := nil;
  T := nil;
  X1 := nil;
  Y1 := nil;
  X2 := nil;
  Y2 := nil;

  try
    L := FLocalFP2Pool.Obtain;
    T := FLocalFP2Pool.Obtain;
    X1 := FLocalFP2Pool.Obtain;
    Y1 := FLocalFP2Pool.Obtain;
    X2 := FLocalFP2Pool.Obtain;
    Y2 := FLocalFP2Pool.Obtain;

    AffinePointGetCoordinatesFP2(P, X1, Y1);

    // L := 3 * x1^2 / (2 * y1)
    FP2Mul(L, X1, X1, Prime);
    FP2Mul3(L, L, Prime);
    FP2Add(T, Y1, Y1, Prime);
    FP2Inverse(T, T, Prime);
    FP2Mul(L, L, T, Prime);

    // X2 = L^2 - 2 * X1
    FP2Mul(X2, L, L, Prime);
    FP2Add(T, X1, X1, Prime);
    FP2Sub(X2, X2, T, Prime);

    // Y2 = L * (X1 - X2) - Y1
    FP2Sub(Y2, X1, X2, Prime);
    FP2Mul(Y2, L, Y2, Prime);
    FP2Sub(Y2, Y2, Y1, Prime);

    Result := AffinePointSetCoordinatesFP2(Res, X2, Y2);
  finally
    FLocalFP2Pool.Recycle(Y2);
    FLocalFP2Pool.Recycle(X2);
    FLocalFP2Pool.Recycle(Y1);
    FLocalFP2Pool.Recycle(X1);
    FLocalFP2Pool.Recycle(T);
    FLocalFP2Pool.Recycle(L);
  end;
end;

function AffinePointAdd(const Res: TCnAffinePoint; const P, Q: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  X1, Y1, X2, Y2, X3, Y3, L, T: TCnFP2;
begin
  if AffinePointIsAtInfinity(P) then
    Result := AffinePointCopy(Res, Q) <> nil
  else if AffinePointIsAtInfinity(Q) then
    Result := AffinePointCopy(Res, P) <> nil
  else if AffinePointEqual(P, Q) then
    Result := AffinePointDouble(P, Q, Prime)
  else
  begin
    T := nil;
    L := nil;
    X1 := nil;
    Y1 := nil;
    X2 := nil;
    Y2 := nil;
    X3 := nil;
    Y3 := nil;

    try
      T := FLocalFP2Pool.Obtain;
      L := FLocalFP2Pool.Obtain;
      X1 := FLocalFP2Pool.Obtain;
      Y1 := FLocalFP2Pool.Obtain;
      X2 := FLocalFP2Pool.Obtain;
      Y2 := FLocalFP2Pool.Obtain;
      X3 := FLocalFP2Pool.Obtain;
      Y3 := FLocalFP2Pool.Obtain;

      AffinePointGetCoordinatesFP2(P, X1, Y1);
      AffinePointGetCoordinatesFP2(Q, X2, Y2);
      FP2Add(T, Y1, Y2, Prime);

      if T.IsZero and FP2Equal(X1, X2) then // ������
      begin
        Result := Res.SetToInfinity; // ��Ϊ 0
        Exit;
      end;

      // L = (Y2 - Y1)/(X2 - X1)
      FP2Sub(L, Y2, Y1, Prime);
      FP2Sub(T, X2, X1, Prime);
      FP2Inverse(T, T, Prime);
      FP2Mul(L, L, T, Prime);

      // X3 = L^2 - X1 - X2
      FP2Mul(X3, L, L, Prime);
      FP2Sub(X3, X3, X1, Prime);
      FP2Sub(X3, X3, X2, Prime);

      // Y3 = L * (X1 - X3) - Y1
      FP2Sub(Y3, X1, X3, Prime);
      FP2Mul(Y3, L, Y3, Prime);
      FP2Sub(Y3, Y3, Y1, Prime);

      Result := AffinePointSetCoordinatesFP2(Res, X3, Y3);
    finally
      FLocalFP2Pool.Recycle(Y3);
      FLocalFP2Pool.Recycle(X3);
      FLocalFP2Pool.Recycle(Y2);
      FLocalFP2Pool.Recycle(X2);
      FLocalFP2Pool.Recycle(Y1);
      FLocalFP2Pool.Recycle(X1);
      FLocalFP2Pool.Recycle(L);
      FLocalFP2Pool.Recycle(T);
    end;
  end;
end;

function AffinePointSub(const Res: TCnAffinePoint; const P, Q: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  T: TCnAffinePoint;
begin
  T := FLocalAffinePointPool.Obtain;
  try
    AffinePointNegate(T, Q, Prime);
    Result := AffinePointAdd(Res, P, T, Prime);
  finally
    FLocalAffinePointPool.Recycle(T);
  end;
end;

function AffinePointMul(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Num: TCnBigNumber; Prime: TCnBigNumber): Boolean;
var
  I, N: Integer;
  T: TCnAffinePoint;
begin
  if Num.IsZero then
    Result := AffinePointSetToInfinity(Res)
  else if Num.IsOne then
    Result := AffinePointCopy(Res, P) <> nil
  else  // �˶��ڼӣ���ͬ���ݶ��ڳˣ����Ժ� Power �㷨����
  begin
    N := Num.GetBitsCount;
    if Res = P then
      T := FLocalAffinePointPool.Obtain
    else
      T := Res;
        
    try
      AffinePointCopy(T, P);
      for I := N - 2 downto 0 do
      begin
        AffinePointDouble(T, T, Prime);
        if Num.IsBitSet(I) then
          AffinePointAdd(T, T, P, Prime);
      end;

      if Res = P then
        AffinePointCopy(Res, T);
      Result := True;
    finally
      if Res = P then
        FLocalAffinePointPool.Recycle(T);
    end;
  end;
end;

function AffinePointFrobenius(const Res: TCnAffinePoint; const P: TCnAffinePoint;
  Prime: TCnBigNumber): Boolean;
var
  X, Y: TCnFP12;
begin
  X := nil;
  Y := nil;

  try
    X := FLocalFP12Pool.Obtain;
    Y := FLocalFP12Pool.Obtain;

    AffinePointGetExtCoordinatesFP12(P, X, Y, Prime);
    FP12Power(X, X, Prime, Prime);
    FP12Power(Y, Y, Prime, Prime);
    AffinePointSetExtCoordinatesFP12(Res, X, Y, Prime);
    Result := True;
  finally
    FLocalFP12Pool.Recycle(Y);
    FLocalFP12Pool.Recycle(X);
  end;
end;

{ TCnFP2 }

constructor TCnFP2.Create;
begin
  inherited;
  F0 := TCnBigNumber.Create;
  F1 := TCnBigNumber.Create;
end;

destructor TCnFP2.Destroy;
begin
  F1.Free;
  F0.Free;
  inherited;
end;

function TCnFP2.GetItems(Index: Integer): TCnBigNumber;
begin
  if Index = 0 then
    Result := F0
  else if Index = 1 then
    Result := F1
  else
    raise Exception.CreateFmt(SListIndexError, [Index]);
end;

function TCnFP2.IsOne: Boolean;
begin
  Result := FP2IsOne(Self);
end;

function TCnFP2.IsZero: Boolean;
begin
  Result := FP2IsZero(Self);
end;

function TCnFP2.SetBigNumber(const Num: TCnBigNumber): Boolean;
begin
  Result := FP2SetBigNumber(Self, Num);
end;

function TCnFP2.SetHex(const S0, S1: string): Boolean;
begin
  Result := FP2SetHex(Self, S0, S1);
end;

function TCnFP2.SetOne: Boolean;
begin
  Result := FP2SetOne(Self);
end;

function TCnFP2.SetU: Boolean;
begin
  Result := FP2SetU(Self);
end;

function TCnFP2.SetWord(Value: Cardinal): Boolean;
begin
  Result := FP2SetWord(Self, Value);
end;

function TCnFP2.SetWords(Value0, Value1: Cardinal): Boolean;
begin
  Result := FP2SetWords(Self, Value0, Value1);
end;

function TCnFP2.SetZero: Boolean;
begin
  Result := FP2SetZero(Self);
end;

function TCnFP2.ToString: string;
begin
  Result := FP2ToString(Self);
end;

{ TCnFP4 }

constructor TCnFP4.Create;
begin
  inherited;
  F0 := TCnFP2.Create;
  F1 := TCnFP2.Create;
end;

destructor TCnFP4.Destroy;
begin
  F1.Free;
  F0.Free;
  inherited;
end;

function TCnFP4.GetItems(Index: Integer): TCnFP2;
begin
  if Index = 0 then
    Result := F0
  else if Index = 1 then
    Result := F1
  else
    raise Exception.CreateFmt(SListIndexError, [Index]);
end;

function TCnFP4.IsOne: Boolean;
begin
  Result := FP4IsOne(Self);
end;

function TCnFP4.IsZero: Boolean;
begin
  Result := FP4IsZero(Self);
end;

function TCnFP4.SetBigNumber(const Num: TCnBigNumber): Boolean;
begin
  Result := FP4SetBigNumber(Self, Num);
end;

function TCnFP4.SetBigNumbers(const Num0, Num1: TCnBigNumber): Boolean;
begin
  Result := FP4SetBigNumbers(Self, Num0, Num1);
end;

function TCnFP4.SetHex(const S0, S1, S2, S3: string): Boolean;
begin
  Result := FP4SetHex(Self, S0, S1, S2, S3);
end;

function TCnFP4.SetOne: Boolean;
begin
  Result := FP4SetOne(Self);
end;

function TCnFP4.SetU: Boolean;
begin
  Result := FP4SetU(Self);
end;

function TCnFP4.SetV: Boolean;
begin
  Result := FP4SetV(Self);
end;

function TCnFP4.SetWord(Value: Cardinal): Boolean;
begin
  Result := FP4SetWord(Self, Value);
end;

function TCnFP4.SetWords(Value0, Value1, Value2,
  Value3: Cardinal): Boolean;
begin
  Result := FP4SetWords(Self, Value0, Value1, Value2, Value3);
end;

function TCnFP4.SetZero: Boolean;
begin
  Result := FP4SetZero(Self);
end;

function TCnFP4.ToString: string;
begin
  Result := FP4ToString(Self);
end;

{ TCnFP12 }

constructor TCnFP12.Create;
begin
  inherited;
  F0 := TCnFP4.Create;
  F1 := TCnFP4.Create;
  F2 := TCnFP4.Create;
end;

destructor TCnFP12.Destroy;
begin
  F2.Free;
  F1.Free;
  F0.Free;
  inherited;
end;

function TCnFP12.GetItems(Index: Integer): TCnFP4;
begin
  if Index = 0 then
    Result := F0
  else if Index = 1 then
    Result := F1
  else if Index = 2 then
    Result := F2
  else
    raise Exception.CreateFmt(SListIndexError, [Index]);
end;

function TCnFP12.IsOne: Boolean;
begin
  Result := FP12IsOne(Self);
end;

function TCnFP12.IsZero: Boolean;
begin
  Result := FP12IsZero(Self);
end;

function TCnFP12.SetBigNumber(const Num: TCnBigNumber): Boolean;
begin
  Result := FP12SetBigNumber(Self, Num);
end;

function TCnFP12.SetBigNumbers(const Num0, Num1, Num2: TCnBigNumber): Boolean;
begin
  Result := FP12SetBigNumbers(Self, Num0, Num1, Num2);
end;

function TCnFP12.SetHex(const S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10,
  S11: string): Boolean;
begin
  Result := FP12SetHex(Self, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11);
end;

function TCnFP12.SetOne: Boolean;
begin
  Result := FP12SetOne(Self);
end;

function TCnFP12.SetU: Boolean;
begin
  Result := FP12SetU(Self);
end;

function TCnFP12.SetV: Boolean;
begin
  Result := FP12SetV(Self);
end;

function TCnFP12.SetW: Boolean;
begin
  Result := FP12SetW(Self);
end;

function TCnFP12.SetWord(Value: Cardinal): Boolean;
begin
  Result := FP12SetWord(Self, Value);
end;

function TCnFP12.SetWords(Value0, Value1, Value2, Value3, Value4, Value5,
  Value6, Value7, Value8, Value9, Value10, Value11: Cardinal): Boolean;
begin
  Result := FP12SetWords(Self, Value0, Value1, Value2, Value3, Value4, Value5,
    Value6, Value7, Value8, Value9, Value10, Value11);
end;

function TCnFP12.SetWSqr: Boolean;
begin
  Result := FP12SetWSqr(Self);
end;

function TCnFP12.SetZero: Boolean;
begin
  Result := FP12SetZero(Self);
end;

function TCnFP12.ToString: string;
begin
  Result := FP12ToString(Self);
end;

{ TCnFP2Pool }

function TCnFP2Pool.CreateObject: TObject;
begin
  Result := TCnFP2.Create;
end;

function TCnFP2Pool.Obtain: TCnFP2;
begin
  Result := TCnFP2(inherited Obtain);
  Result.SetZero;
end;

procedure TCnFP2Pool.Recycle(Num: TCnFP2);
begin
  inherited Recycle(Num);
end;

{ TCnFP4Pool }

function TCnFP4Pool.CreateObject: TObject;
begin
  Result := TCnFP4.Create;
end;

function TCnFP4Pool.Obtain: TCnFP4;
begin
  Result := TCnFP4(inherited Obtain);
  Result.SetZero;
end;

procedure TCnFP4Pool.Recycle(Num: TCnFP4);
begin
  inherited Recycle(Num);
end;

{ TCnFP12Pool }

function TCnFP12Pool.CreateObject: TObject;
begin
  Result := TCnFP12.Create;
end;

function TCnFP12Pool.Obtain: TCnFP12;
begin
  Result := TCnFP12(inherited Obtain);
  Result.SetZero;
end;

procedure TCnFP12Pool.Recycle(Num: TCnFP12);
begin
  inherited Recycle(Num);
end;

{ TCnAffinePoint }

constructor TCnAffinePoint.Create;
begin
  inherited;
  FX := TCnFP2.Create;
  FY := TCnFP2.Create;
  FZ := TCnFP2.Create;
end;

destructor TCnAffinePoint.Destroy;
begin
  FZ.Free;
  FY.Free;
  FX.Free;
  inherited;
end;

function TCnAffinePoint.GetCoordinatesFP2(const FP2X,
  FP2Y: TCnFP2): Boolean;
begin
  Result := AffinePointGetCoordinatesFP2(Self, FP2X, FP2Y);
end;

function TCnAffinePoint.GetExtCoordinatesFP12(const FP12X, FP12Y: TCnFP12;
  Prime: TCnBigNumber): Boolean;
begin
  Result := AffinePointGetExtCoordinatesFP12(Self, FP12X, FP12Y, Prime);
end;

function TCnAffinePoint.IsAtInfinity: Boolean;
begin
  Result := AffinePointIsAtInfinity(Self);
end;

function TCnAffinePoint.IsOnCurve(Prime: TCnBigNumber): Boolean;
begin
  Result := AffinePointIsOnCurve(Self, Prime);
end;

function TCnAffinePoint.SetCoordinatesBigNumbers(const X0, X1, Y0,
  Y1: TCnBigNumber): Boolean;
begin
  Result := AffinePointSetCoordinatesBigNumbers(Self, X0, X1, Y0, Y1);
end;

function TCnAffinePoint.SetCoordinatesFP2(const FP2X,
  FP2Y: TCnFP2): Boolean;
begin
  Result := AffinePointSetCoordinatesFP2(Self, FP2X, FP2Y);
end;

function TCnAffinePoint.SetCoordinatesHex(const SX0, SX1, SY0,
  SY1: string): Boolean;
begin
  Result := AffinePointSetCoordinatesHex(Self, SX0, SX1, SY0, SY1);
end;

function TCnAffinePoint.SetExtCoordinatesFP12(const FP12X, FP12Y: TCnFP12;
  Prime: TCnBigNumber): Boolean;
begin
  Result := AffinePointSetExtCoordinatesFP12(Self, FP12X, FP12Y, Prime);
end;

function TCnAffinePoint.SetToInfinity: Boolean;
begin
  Result := AffinePointSetToInfinity(Self);
end;

procedure TCnAffinePoint.SetZero;
begin
  AffinePointSetZero(Self);
end;

function TCnAffinePoint.ToString: string;
begin
  Result := AffinePointToString(Self);
end;

{ TCnAffinePointPool }

function TCnAffinePointPool.CreateObject: TObject;
begin
  Result := TCnAffinePoint.Create;
end;

function TCnAffinePointPool.Obtain: TCnAffinePoint;
begin
  Result := TCnAffinePoint(inherited Obtain);
//  Result.SetZero;
end;

procedure TCnAffinePointPool.Recycle(Num: TCnAffinePoint);
begin
  inherited Recycle(Num);
end;

initialization
  FLocalBigNumberPool := TCnBigNumberPool.Create;
  FLocalFP2Pool := TCnFP2Pool.Create;
  FLocalFP4Pool := TCnFP4Pool.Create;
  FLocalFP12Pool := TCnFP12Pool.Create;
  FLocalAffinePointPool := TCnAffinePointPool.Create;

finalization
  FLocalAffinePointPool.Free;
  FLocalFP12Pool.Free;
  FLocalFP4Pool.Free;
  FLocalFP2Pool.Free;
  FLocalBigNumberPool.Free;

end.
