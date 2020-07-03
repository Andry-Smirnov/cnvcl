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

unit CnBigDecimal;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ��󸡵����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע���� CnBigNumber ��ʾ��Ч���֣��� Integer ��ʾ����ָ��
*           ���ֲο� Rudy Velthuis �� BigDecimal �Լ� Java �� BigDecimal
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.06.25 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, SysConst, Math,
  CnNativeDecl, CnFloatConvert, CnBigNumber;

const
  CN_BIG_DECIMAL_DEFAULT_PRECISION = 12;                       // �˳�����С������Ĭ�Ͼ���

type
  ECnBigDecimalException = class(Exception);

  TCnBigDecimalRoundMode = (
  {* ȡ����ģʽ���������֣�����������������ɵ�����������
    ע�⣺�����������ֻ����������ֵ��������û������������������Ϊ�ᶯ����Ȼ��������ֵС����ȡ}
    drAwayFromZero,            // ������ֵ�����ȡ
    drTowardsZero,             // ������ֵС����ȡ������ֻ���������ֵ� Trunc
    drCeilingToInfinite,       // ���������ȡ
    drFloorToNegInfinite,      // ���������ȡ
    dr45Round,                 // �������롢��������ֵ�����
    dr465RoundEven             // �����������˫����������ֵ�����
  );

  TCnBigDecimal = class
  {* �󸡵���ʵ���࣬�� CnBigNumber ������Ч���֣��� Integer ����ָ��Ҳ����С����λ��
    FScale ����С��������Ч�������ұߵ�λ�ã�����Ϊ��������Ϊ����
    ��ʱ�����֮����С������� FScale λ����ʱ�����֮��Ҫ�� -FScale �� 0}
  private
    FValue: TCnBigNumber;
    FScale: Integer;                 // ��ȷֵΪ FValue / (10^FScale)
    function GetDecString: string;
    function GetDebugDump: string;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetZero;
    {* ���ó� 0}
    procedure SetOne;
    {* ���ó� 1}
    procedure SetNegative(Neg: Boolean);
    {* �����Ƿ���}
    procedure Negate;
    {* �������÷�}

    function SetWord(W: LongWord): Boolean;
    {* ����Ϊһ�� UInt32}
    function SetInt64(W: Int64): Boolean;
    {* ����Ϊһ�� Int64}
    function SetDec(const Buf: string): Boolean;
    {* �����ַ���ֵ}
    procedure SetSingle(Value: Single);
    {* �����ȸ���ֵ}
    procedure SetDouble(Value: Double);
    {* ˫���ȸ���ֵ}
    procedure SetExtended(Value: Extended);
    {* ��չ���ȸ���ֵ}

    procedure AddWord(W: LongWord);
    {* ����һ�� UInt32}
    procedure SubWord(W: LongWord);
    {* ��ȥһ�� UInt32}
    procedure MulWord(W: LongWord);
    {* ����һ�� UInt32}
    procedure DivWord(W: LongWord);
    {* ����һ�� UInt32}

    function IsNegative: Boolean;
    {* �Ƿ���}
    function IsZero: Boolean;
    {* �Ƿ��� 0}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ת���ַ���}

//    class function GetMulDivPrecision: Integer;
//    class function SetMulDivPrecision(Value: Integer);

    property DecString: string read GetDecString;
    property DebugDump: string read GetDebugDump;
  end;

  TCnBigDecimalPool = class(TObjectList)
  {* �󸡵�����ʵ���࣬����ʹ�õ��󸡵����ĵط����д����󸡵�����}
  private
  public
    constructor Create;
    destructor Destroy; override;

    function Obtain: TCnBigDecimal;
    procedure Recycle(Num: TCnBigDecimal);
  end;

procedure BigDecimalClear(const Num: TCnBigDecimal);
{* ���һ���󸡵�����ʵ������ Value �� Scale ���� 0}

function BigDecimalSetDec(const Buf: string; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵������������ַ���ֵ}

function BigDecimalSetWord(W: LongWord; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵���������������ֵ}

function BigDecimalSetInt64(W: Int64; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵����������� Int64 ����ֵ}

function BigDecimalSetSingle(const Value: Single; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵����������õ����ȸ���ֵ}

function BigDecimalSetDouble(const Value: Double; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵�����������˫���ȸ���ֵ}

function BigDecimalSetExtended(const Value: Extended; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵�������������չ���ȸ���ֵ}

function BigDecimalToString(const Num: TCnBigDecimal): string;
{* �󸡵�������ת��Ϊ�ַ���}

function BigDecimalCompare(const Num1, Num2: TCnBigDecimal): Integer; overload;
{* �Ƚ������󸡵�������}

function BigDecimalCompare(const Num1: TCnBigDecimal; Num2: Int64): Integer; overload;
{* �Ƚϴ󸡵�������������}

procedure BigDecimalCopy(const Dest, Source: TCnBigDecimal);
{* �󸡵�����ֵ}

function BigDecimalGetPrecision(const Num: TCnBigDecimal): Integer;
{* ����󸡵�����ʮ����λ����Ҳ����Ч���ֳ���}

function BigDecimalGetIntDecimalCount(const Num: TCnBigDecimal;
  out IntCount: Integer; out DecimalCount: Integer): Boolean;
{* ����󸡵������������ֳ�����С�����ֳ���}

function BigDecimalGetHighScale(const Num: TCnBigDecimal): Integer;
{* ����󸡵����������Ч����λ��С�����ڼ�λ���������С�� 0�����󸺺��ʾ��С����ǰ�ڼ�λ}

function BigDecimalAdd(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
{* �󸡵����ӣ�Res ������ Num1 �� Num2��Num1 ������ Num2}

function BigDecimalSub(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
{* �󸡵�������Res ������ Num1 �� Num2��Num1 ������ Num2}

function BigDecimalMul(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal; MulPrecision: Integer = 0): Boolean;
{* �󸡵����ˣ�Res ������ Num1 �� Num2��Num1 ������ Num2��
  MulPrecision ��ʾ�˷���ౣ��С�����λ��0 ��ʾȫ����}

function BigDecimalDiv(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal; DivPrecision: Integer = 0): Boolean;
{* �󸡵�������Res ������ Num1 �� Num2��Num1 ������ Num2��
  DivPrecision ��ʾ����������ౣ��С�����λ��0 ��ʾ��Ĭ��������}

function BigDecimalChangeToScale(const Res: TCnBigDecimal; const Num: TCnBigDecimal;
  Scale: Integer; RoundMode: TCnBigDecimalRoundMode = drTowardsZero): Boolean;
{* ���󸡵�����ָ��ģʽ���뵽ָ�� Scale��Ҳ����С����� Scale λ����� Scale ������С�����󷽣�Ҳ�������뵽�� 10 �η�}

function BigDecimalRoundToDigits(const Res: TCnBigDecimal; const Num: TCnBigDecimal;
  Digits: Integer; RoundMode: TCnBigDecimalRoundMode = drTowardsZero): Boolean;
{* ���󸡵�����ָ��ģʽ���뵽ָ��С����� Digits λ����������Ȳ��� Digits λ�򲻱�}

function BigDecimalTrunc(const Res: TCnBigDecimal; const Num: TCnBigDecimal): Boolean;
{* ���󸡵��� Trunc ��ֻʣ����}

function BigDecimalDebugDump(const Num: TCnBigDecimal): string;
{* ��ӡ�󸡵����ڲ���Ϣ}

var
  CnBigDecimalOne: TCnBigDecimal = nil;     // ��ʾ 1 �ĳ���
  CnBigDecimalZero: TCnBigDecimal = nil;    // ��ʾ 0 �ĳ���

implementation

resourcestring
  SCnNotImplemented = 'NOT Implemented.';
  SCnScaleOutOfRange = 'Scale Out of Range.';

const
  SCN_FIVE_POWER_UINT32 = 13;
  SCN_POWER_FIVES32: array[0..13] of LongWord = (
    1,                               // 5 ^ 0
    5,                               // 5 ^ 1
    25,                              // 5 ^ 2
    125,                             // 5 ^ 3
    625,                             // 5 ^ 4
    3125,                            // 5 ^ 5
    15625,                           // 5 ^ 6
    78125,                           // 5 ^ 7
    390625,                          // 5 ^ 8
    1953125,                         // 5 ^ 9
    9765625,                         // 5 ^ 10
    48828125,                        // 5 ^ 11
    244140625,                       // 5 ^ 12
    1220703125                       // 5 ^ 13
  );

  SCN_TEN_POWER_UINT32 = 9;
  SCN_POWER_TENS32: array[0..9] of LongWord = (
    1,                               // 10 ^ 0
    10,                              // 10 ^ 1
    100,                             // 10 ^ 2
    1000,                            // 10 ^ 3
    10000,                           // 10 ^ 4
    100000,                          // 10 ^ 5
    1000000,                         // 10 ^ 6
    10000000,                        // 10 ^ 7
    100000000,                       // 10 ^ 8
    1000000000                       // 10 ^ 9
  );

//const
//  SCN_POWER_TENS64: array[0..19] of TUInt64 = (
//    1,                               // 10 ^ 0
//    10,                              // 10 ^ 1
//    100,                             // 10 ^ 2
//    1000,                            // 10 ^ 3
//    10000,                           // 10 ^ 4
//    100000,                          // 10 ^ 5
//    1000000,                         // 10 ^ 6
//    10000000,                        // 10 ^ 7
//    100000000,                       // 10 ^ 8
//    1000000000,                      // 10 ^ 9
//    10000000000,                     // 10 ^ 10
//    100000000000,                    // 10 ^ 11
//    1000000000000,                   // 10 ^ 12
//    10000000000000,                  // 10 ^ 13
//    100000000000000,                 // 10 ^ 14
//    1000000000000000,                // 10 ^ 15
//    10000000000000000,               // 10 ^ 16
//    100000000000000000,              // 10 ^ 17
//    1000000000000000000,             // 10 ^ 18
//    $8AC7230489E80000                // 10 ^ 19
//
//    // 10 ^ 19 10000000000000000000 �Ѿ����� Int64 9223372036854775807
//    // ���Ե��� 16 ����д��û�� UInt64 18446744073709551615��10 ^ 20 �ų�
//  );

var
  FLocalBigDecimalPool: TCnBigDecimalPool = nil;
  FLocalBigNumberPool: TCnBigNumberPool = nil;
  FDefaultPrecisionDigits: Integer = CN_BIG_DECIMAL_DEFAULT_PRECISION;

function CheckScaleAddRange(Scale1, Scale2: Integer): Integer;
begin
  if IsInt32AddOverflow(Scale1, Scale2) then
    raise ECnBigDecimalException.Create(SCnScaleOutOfRange);
  Result := Scale1 + Scale2;
end;

procedure RoundByMode(Quotient, Divisor, Remainder: TCnBigNumber; QWillBeNeg: Boolean;
  Mode: TCnBigDecimalRoundMode);
var
  R2: TCnBigNumber;
  R2CD: Integer;
begin
  if Remainder.IsZero then
    Exit;

  case Mode of
    drAwayFromZero:            // ������ֵ�����ȡ
      begin
        BigNumberAddWord(Quotient, 1);
      end;
    drTowardsZero:             // ������ֵС����ȡ������ֻ���������ֵ� Trunc
      begin
        // ɶ��������
      end;
    drCeilingToInfinite:       // ���������ȡ
      begin
        if not QWillBeNeg then
          BigNumberAddWord(Quotient, 1);
      end;
    drFloorToNegInfinite:      // ���������ȡ
      begin
        if QWillBeNeg then
          BigNumberAddWord(Quotient, 1);
      end;
  else
    R2 := FLocalBigNumberPool.Obtain;
    try
      BigNumberCopy(R2, Remainder);
      BigNumberShiftLeftOne(R2, R2);
      R2CD := BigNumberCompare(R2, Divisor);

      // ��������ģʽ�£�R2CD ������ڵ��� 0��˵���������ڵ��� 5��Ҫ��
      // ��������ģʽ�£�������� 1��Ҫ�ж��̵�ĩλ�Ƿ�ż��ż���룬�����������
      // ȷ�������������ٸ������������ᶼ�ǳ�����ֵС�ķ������Ǿ���ֵ��ķ���
      case Mode of
        dr45Round:         // �������롢��������ֵ�����
          begin
            if R2CD >= 0 then
              BigNumberAddWord(Quotient, 1);
          end;
        dr465RoundEven:     // �����������˫����������ֵ�����
          begin
            if (R2CD > 0) or ((R2CD = 0) and not Quotient.IsOdd) then
              BigNumberAddWord(Quotient, 1);
          end;
      end;
    finally
      FLocalBigNumberPool.Recycle(R2);
    end;
  end;
end;

// �������� 10 �� Power5 �η�
procedure BigNumberMulPower5(Num: TCnBigNumber; Power5: Integer);
var
  I, L, D, R: Integer;
begin
  if Power5 < 0 then
    raise ECnBigDecimalException.Create(SCnNotImplemented);

  L := High(SCN_POWER_FIVES32);       // һ������ 13 ��
  D := Power5 div L;
  R := Power5 mod L;

  for I := 1 to D do                  // һ���� 13 ����
    Num.MulWord(SCN_POWER_FIVES32[L]);
  Num.MulWord(SCN_POWER_FIVES32[R]);  // ���ϳ�ʣ�µ�
end;

// �������� 10 �� Power10 �η�
procedure BigNumberMulPower10(Num: TCnBigNumber; Power10: Integer);
var
  I, L, D, R: Integer;
begin
  if Power10 < 0 then
    raise ECnBigDecimalException.Create(SCnNotImplemented);

  L := High(SCN_POWER_TENS32);       // һ������ 9 ��
  D := Power10 div L;
  R := Power10 mod L;

  for I := 1 to D do                 // һ���� 9 ����
    Num.MulWord(SCN_POWER_TENS32[L]);
  Num.MulWord(SCN_POWER_TENS32[R]);  // ���ϳ�ʣ�µ�
end;

procedure BigDecimalClear(const Num: TCnBigDecimal);
begin
  if Num <> nil then
  begin
    Num.FScale := 0;
    Num.FValue.SetZero;
  end;
end;

function BigDecimalSetDec(const Buf: string; const Res: TCnBigDecimal): Boolean;
var
  Neg, ENeg: Boolean;
  E, DC: Integer;
  P, DotPos: PChar;
  S, V: string;
  C: Char;
begin
  Result := False;

  V := '';
  S := Trim(Buf);
  P := PChar(S);
  if P^ = #0 then
    Exit;

  Neg := False;
  ENeg := False;
  DotPos := nil;

  if (P^ = '+') or (P^ = '-') then
  begin
    Neg := (P^ = '-');
    Inc(P);
  end;

  if P^ = #0 then
    Exit;

  Res.FValue.SetZero;
  DC := 0;

  // ����ֵ��ֱ����β�����Ͽ�ѧ�������� E
  C := P^;
  while (C <> #0) and (C <> 'e') and (C <> 'E') do
  begin
    case C of
      '0'..'9':
        V := V + C;
      ',':
        ; // �ֽںź���
      '.':
        if Assigned(DotPos) then
          // С����ֻ����һ��
          Exit
        else
          DotPos := P;
    else
      Exit;
    end;
    Inc(P);
    C := P^;
  end;

  // V �ǲ�����С�����ʮ�����ַ���

  // ���������ԭ����С���㣬��� DC ��ֵ
  if Assigned(DotPos) then
    DC := P - DotPos - 1;

  E := 0;
  if (C = 'e') or (C = 'E') then
  begin
    // ��ѧ�������� E �����ָ��
    Inc(P);
    if (P^ = '+') or (P^ = '-') then
    begin
      ENeg := (P^ = '-');
      Inc(P);
    end;
    while P^ <> #0 do
    begin
      case P^ of
        '0'..'9':
          E := E * 10 + Ord(P^) - Ord('0');
      else
        Exit;
      end;
      Inc(P);
    end;
  end;

  if ENeg then
    E := -E;
  DC := DC - E; // ���ָ��һ�����С�����ֳ��ȸ� DC

  Res.FScale := DC;
  Res.FValue.SetDec(V);

  if (not Res.FValue.IsNegative) and Neg then
    Res.FValue.SetNegative(True);

  Result := True;
end;

function BigDecimalSetWord(W: LongWord; const Res: TCnBigDecimal): Boolean;
begin
  Res.FValue.SetWord(W);
  Res.FScale := 0;
  Result := True;
end;

function BigDecimalSetInt64(W: Int64; const Res: TCnBigDecimal): Boolean;
begin
  Res.FValue.SetInt64(W);
  Res.FScale := 0;
  Result := True;
end;

function InternalBigDecimalSetFloat(Neg: Boolean; IntExponent: Integer; IntMantissa: TUInt64;
  const Res: TCnBigDecimal): Boolean;
var
  C: Integer;
begin
  C := GetUInt64LowBits(IntMantissa);
  if C > 0 then
  begin
    IntMantissa := IntMantissa shr C;
    Inc(IntExponent, C);
  end;

  // ֵ�� IntMantissa * 2^IntExponent
  BigNumberSetUInt64UsingInt64(Res.FValue, IntMantissa);
  if IntExponent > 0 then
  begin
    Res.FValue.ShiftLeft(IntExponent);   // ֱ����������������ָ����� 0
    Res.FScale := 0;
  end
  else // ָ���Ǹ���˵����С�����֣���ôÿ������ 2 ��Ҫ��ɳ��� 10��IntMantissa �͵����ÿ��ָ������ 5
  begin
    IntExponent := -IntExponent;
    Res.FScale := IntExponent;
    BigNumberMulPower5(Res.FValue, IntExponent);
  end;

  Res.FValue.SetNegative(Neg);
  Result := True;
end;

function BigDecimalSetSingle(const Value: Single; const Res: TCnBigDecimal): Boolean;
var
  N: Boolean;
  E: Integer;
  S: LongWord;
begin
  if SingleIsInfinite(Value) or SingleIsNan(Value) then
    raise ECnBigDecimalException.Create(SInvalidOp);

  if Value = 0.0 then
  begin
    Res.FValue.SetZero;
    Res.FScale := 0;
    Result := True;
    Exit;
  end;

  ExtractFloatSingle(Value, N, E, S);
  // �� 1. ��ͷ����Ч���ֵ���������E ��Ҫ�� 23
  Result := InternalBigDecimalSetFloat(N, E - 23, TUInt64(S), Res);
end;

function BigDecimalSetDouble(const Value: Double; const Res: TCnBigDecimal): Boolean;
var
  N: Boolean;
  E: Integer;
  S: TUInt64;
begin
  if DoubleIsInfinite(Value) or DoubleIsNan(Value) then
    raise ECnBigDecimalException.Create(SInvalidOp);

  if Value = 0.0 then
  begin
    Res.FValue.SetZero;
    Res.FScale := 0;
    Result := True;
    Exit;
  end;

  ExtractFloatDouble(Value, N, E, S);
  // �� 1. ��ͷ����Ч���ֵ���������E ��Ҫ�� 52
  Result := InternalBigDecimalSetFloat(N, E - 52, S, Res);
end;

function BigDecimalSetExtended(const Value: Extended; const Res: TCnBigDecimal): Boolean;
var
  N: Boolean;
  E: Integer;
  S: TUInt64;
begin
  if ExtendedIsInfinite(Value) or ExtendedIsNan(Value) then
    raise ECnBigDecimalException.Create(SInvalidOp);

  if Value = 0.0 then
  begin
    Res.FValue.SetZero;
    Res.FScale := 0;
    Result := True;
    Exit;
  end;

  ExtractFloatExtended(Value, N, E, S);
  // �� 1. ��ͷ����Ч���ֵ���������E ��Ҫ�� 63
  Result := InternalBigDecimalSetFloat(N, E - 63, S, Res);
end;

function BigDecimalToString(const Num: TCnBigDecimal): string;
var
  C: Char;
  S: string;
  L: Integer;
begin
  S := Num.FValue.ToDec;
  L := Length(S);

  if L = 0 then
  begin
    Result := '';
    Exit;
  end;

  // ������������
  C := #0;
  if (S[1] = '-') or (S[1] = '+') then
  begin
    C := S[1];
    Delete(S, 1, 1);
    Dec(L);
  end;

  // ȷ��С����λ��
  if Num.FScale < 0 then
    Result := S + StringOfChar('0', -Num.FScale)
  else if Num.FScale = 0 then
    Result := S
  else if Num.FScale >= L then
    Result := '0.' + StringOfChar('0', Num.FScale - L) + S
  else
    Result := Copy(S, 1, L - Num.FScale) + '.' + Copy(S, L - Num.FScale + 1, MaxInt);

  // �ٰ������żӻ���
  if C <> #0 then
    Result := C + Result;
end;

function BigDecimalCompare(const Num1, Num2: TCnBigDecimal): Integer;
var
  T: TCnBigNumber;
  L: Integer;
begin
  if Num1.FValue.IsZero then
  begin
    if Num2.FValue.IsZero then
      Result := 0   // ���� 0�����
    else if Num2.FValue.IsNegative then
      Result := 1   // 0 ���ڸ�
    else
      Result := -1; // 0 С����
  end
  else if Num2.FValue.IsZero then
  begin
    if not Num1.FValue.IsNegative then
      Result := 1     // ������ 0
    else
      Result := -1;   // ��С�� 0
  end
  else if Num1.FValue.IsNegative and not Num2.FValue.IsNegative then // ����Ϊ 0����С����
    Result := -1
  else if not Num1.FValue.IsNegative and Num2.FValue.IsNegative then // ����Ϊ 0�������ڸ�
    Result := 1
  else if Num1.FScale = Num2.FScale then // ������ͬ���ȿ�ָ���Ƿ���ͬ
    Result := BigNumberCompare(Num1.FValue, Num2.FValue)
  else // ������ͬ��ָ����ͬ
  begin
    // Ҫ�� Scale ���Ҳ����С���㿿�����������Խ�С�� Value��
    // ���� 10 ��ָ��������Զ���С���㣬�ٺ���һ���Ƚϣ����豣��ֵ���䣬���ԺͼӼ�������
    T := FLocalBigNumberPool.Obtain;
    L := CheckScaleAddRange(Num1.FScale, -Num2.FScale);

    try
      if L > 0 then
      begin
        BigNumberCopy(T, Num2.FValue);
        BigNumberMulPower10(T, L);
        Result := BigNumberCompare(Num1.FValue, T);
      end
      else
      begin
        BigNumberCopy(T, Num1.FValue);
        L := -L;
        BigNumberMulPower10(T, L);
        Result := BigNumberCompare(T, Num2.FValue);
      end;
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
  end;
end;

function BigDecimalCompare(const Num1: TCnBigDecimal; Num2: Int64): Integer; overload;
var
  T: TCnBigDecimal;
begin
  if not Num1.IsNegative and (Num2 < 0) then
    Result := 1
  else if Num1.IsNegative and (Num2 > 0) then
    Result := -1
  else if Num1.IsZero and (Num2 = 0) then
    Result := 0
  else
  begin
    T := FLocalBigDecimalPool.Obtain;
    try
      T.FScale := 0;
      T.FValue.SetInt64(Num2);
      Result := BigDecimalCompare(Num1, T);
    finally
      FLocalBigDecimalPool.Recycle(T);
    end;
  end;
end;

procedure BigDecimalCopy(const Dest, Source: TCnBigDecimal);
begin
  if (Source <> nil) and (Dest <> nil) and (Source <> Dest) then
  begin
    BigNumberCopy(Dest.FValue, Source.FValue);
    Dest.FScale := Source.FScale;
  end;
end;

function BigDecimalGetPrecision(const Num: TCnBigDecimal): Integer;
begin
  Result := 0;
  if Num <> nil then
    Result := BigNumberGetTenPrecision(Num.FValue); // �õ�ʮ��������λ��
end;

function BigDecimalGetIntDecimalCount(const Num: TCnBigDecimal;
  out IntCount: Integer; out DecimalCount: Integer): Boolean;
var
  P: Integer;
begin
  Result := False;
  if Num <> nil then
  begin
    P := BigNumberGetTenPrecision(Num.FValue);
    if Num.FScale > 0 then  // ��С������
    begin
      DecimalCount := Num.FScale;
      IntCount := P - DecimalCount;
      if IntCount < 0 then
        IntCount := 0;
    end
    else
    begin
      // û��С������
      DecimalCount := 0;
      IntCount := P + Num.FScale;
    end;
    Result := True;
  end;
end;

function BigDecimalGetHighScale(const Num: TCnBigDecimal): Integer;
begin
  Result := 0;
  if Num <> nil then
  begin
    Result := BigNumberGetTenPrecision(Num.FValue);
    // С������� FScale λ����ȥ��Ч����
    Result := Num.FScale - Result + 1;
    if Result <= 0 then // С����ǰ�ڼ�λ�Ǵ� 1 ��ʼ��
      Dec(Result)
  end;
end;

function BigDecimalAdd(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
var
  T: TCnBigNumber;
  L: Integer;
begin
  if Num1.FValue.IsZero then
  begin
    BigDecimalCopy(Res, Num2);
    Result := True;
    Exit;
  end
  else if Num2.FValue.IsZero then
  begin
    BigDecimalCopy(Res, Num1);
    Result := True;
    Exit;
  end
  else if Num1.FScale = Num2.FScale then
  begin
    // ָ����ֱͬ�Ӽ�
    Res.FScale := Num1.FScale;
    Result := BigNumberAdd(Res.FValue, Num1.FValue, Num2.FValue);
    Exit;
  end
  else
  begin
    // Ҫ�� Scale С��Ҳ����С���㿿�����������Խϴ�� Value��
    // ���� 10 ��ָ������ݲ���С��ͬ�ȵ� Scale �Զ���С���㲢������ֵ���䣬
    // �ٺ���һ����ӣ������ Scale ȡС��
    T := FLocalBigNumberPool.Obtain;
    L := CheckScaleAddRange(Num1.FScale, -Num2.FScale);

    try
      if L > 0 then
      begin
        BigNumberCopy(T, Num2.FValue);
        BigNumberMulPower10(T, L);
        Res.FScale := Num1.FScale;
        Result := BigNumberAdd(Res.FValue, Num1.FValue, T);
      end
      else
      begin
        BigNumberCopy(T, Num1.FValue);
        L := -L;
        BigNumberMulPower10(T, L);
        Res.FScale := Num2.FScale;
        Result := BigNumberAdd(Res.FValue, T, Num2.FValue);
      end;
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
  end;
end;

function BigDecimalSub(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
var
  T: TCnBigNumber;
  L: Integer;
begin
  if Num1.FValue.IsZero then
  begin
    BigNumberCopy(Num2.FValue, Res.FValue);
    Res.FValue.Negate;
    Result := True;
    Exit;
  end
  else if Num2.FValue.IsZero then
  begin
    BigNumberCopy(Num1.FValue, Res.FValue);
    Result := True;
    Exit;
  end
  else if Num1.FScale = Num2.FScale then
  begin
    // ָ����ֱͬ�Ӽ�
    Res.FScale := Num1.FScale;
    Result := BigNumberSub(Res.FValue, Num1.FValue, Num2.FValue);
    Exit;
  end
  else
  begin
    // Ҫ�� Scale С��Ҳ����С���㿿�����������Խϴ�� Value��
    // ���� 10 ��ָ������ݲ���С��ͬ�ȵ� Scale �Զ���С���㲢������ֵ���䣬
    // �ٺ���һ������������ Scale ȡС��
    T := FLocalBigNumberPool.Obtain;
    L := CheckScaleAddRange(Num1.FScale, -Num2.FScale);

    try
      if L > 0 then
      begin
        BigNumberCopy(T, Num2.FValue);
        BigNumberMulPower10(T, L);
        Res.FScale := Num1.FScale;
        Result := BigNumberSub(Res.FValue, Num1.FValue, T);
      end
      else
      begin
        BigNumberCopy(T, Num1.FValue);
        L := -L;
        BigNumberMulPower10(T, L);
        Res.FScale := Num2.FScale;
        Result := BigNumberSub(Res.FValue, T, Num2.FValue);
      end;
    finally
      FLocalBigNumberPool.Recycle(T);
    end;
  end;
end;

function BigDecimalMul(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal; MulPrecision: Integer): Boolean;
begin
  if Num1.FValue.IsZero or Num2.FValue.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end
  else
  begin
    Res.FScale := CheckScaleAddRange(Num1.FScale, Num2.FScale);
    Result := BigNumberMul(Res.FValue, Num1.FValue, Num2.FValue);
    if Result and (MulPrecision > 0) then
      Result := BigDecimalRoundToDigits(Res, Res, MulPrecision, drTowardsZero);
  end;
end;

function BigDecimalDiv(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal; DivPrecision: Integer): Boolean;
var
  S: Boolean;
  M, TS: Integer;
  T, R: TCnBigNumber;
begin
  if Num2.FValue.IsZero then
    raise EDivByZero.Create(SDivByZero);

  if Num1.FValue.IsZero then
  begin
    Res.SetZero;
    Result := True;
    Exit;
  end;

  // ������
  S := Num1.FValue.isNegative <> Num2.FValue.IsNegative; // ���Ų��Ƚ���Ÿ�
  TS := Num1.FScale - Num2.FScale;

  if DivPrecision <= 0 then
    DivPrecision := FDefaultPrecisionDigits;
  if DivPrecision < 0 then
    DivPrecision := CN_BIG_DECIMAL_DEFAULT_PRECISION;

  // ���ݾ���Ҫ����㽫�������ͳ���ͬʱ����ı�����ע����ڳ��� 9 ʱ�Ϳ��������������Ȳ���
  M := CheckScaleAddRange(DivPrecision, (Num2.FValue.Top - Num2.FValue.Top + 1) * 9 + 3);
  TS := CheckScaleAddRange(TS, M);

  T := nil;
  R := nil;
  try
    T := FLocalBigNumberPool.Obtain;
    BigNumberCopy(T, Num1.FValue);
    BigNumberMulPower10(T, M);

    R := FLocalBigNumberPool.Obtain;
    BigNumberDiv(Res.FValue, R, T, Num2.FValue);  // Num1.FValue * 10 ^ M div Num2.FValue �õ��̺�����

    RoundByMode(Res.FValue, Num2.FValue, R, Res.FValue.IsNegative, drTowardsZero);
    Res.FScale := TS;
    // TODO: ʮ����Լ��

    BigDecimalRoundToDigits(Res, Res, DivPrecision, drTowardsZero);
    Res.FValue.SetNegative(S);
    Result := True;
  finally
    FLocalBigNumberPool.Recycle(T);
    FLocalBigNumberPool.Recycle(R);
  end;
end;

function BigDecimalChangeToScale(const Res: TCnBigDecimal; const Num: TCnBigDecimal;
  Scale: Integer; RoundMode: TCnBigDecimalRoundMode): Boolean;
var
  DS: Integer;
  D, Q, R: TCnBigNumber;
  Neg: Boolean;
begin
  DS := CheckScaleAddRange(Num.FScale, -Scale);
  if DS > 0 then // �µ�С������λ����ԭ���٣�Ҫ��֮������
  begin
    D := FLocalBigNumberPool.Obtain;
    Q := FLocalBigNumberPool.Obtain;
    R := FLocalBigNumberPool.Obtain;
    try
      D.SetOne;
      BigNumberMulPower10(D, DS);  // ����� 10 �� DS �η���������

      Neg := Num.FValue.IsNegative;
      Num.FValue.SetNegative(False);

      // �����̺�������
      BigNumberDiv(Q, R, Num.FValue, D);

      // �����̺������Լ������������
      RoundByMode(Q, D, R, Neg, RoundMode);

      BigNumberCopy(Res.FValue, Q);
      Res.FScale := Scale;
      Res.FValue.SetNegative(Neg);

      if Res <> Num then           // ��� Num �Ƕ����ģ�����Ҫ��ԭ�� Neg
        Num.FValue.SetNegative(Neg);
      Result := True;
    finally
      FLocalBigNumberPool.Recycle(D);
      FLocalBigNumberPool.Recycle(Q);
      FLocalBigNumberPool.Recycle(R);
    end;
  end
  else // �µ�С����λ����ԭ�����࣬�򵥱任һ�¾���
  begin
    BigNumberCopy(Res.FValue, Num.FValue);
    if DS < 0 then
      BigNumberMulPower10(Res.FValue, -DS);
    Res.FScale := Scale;
    Result := True;
  end;
end;

function BigDecimalRoundToDigits(const Res: TCnBigDecimal; const Num: TCnBigDecimal;
  Digits: Integer; RoundMode: TCnBigDecimalRoundMode = drTowardsZero): Boolean;
var
  DS: Integer;
  D, Q, R: TCnBigNumber;
  Neg: Boolean;
begin
  Result := False;
  DS := CheckScaleAddRange(Num.FScale, -Digits);

  if DS > 0 then // �µ�С������λ���ñ�ԭ���٣����ܳ�֮������
  begin
    D := FLocalBigNumberPool.Obtain;
    Q := FLocalBigNumberPool.Obtain;
    R := FLocalBigNumberPool.Obtain;
    try
      D.SetOne;
      BigNumberMulPower10(D, DS);  // ����� 10 �� DS �η���������

      Neg := Num.FValue.IsNegative;
      Num.FValue.SetNegative(False);

      // �����̺�������
      BigNumberDiv(Q, R, Num.FValue, D);

      // �����̺������Լ������������
      RoundByMode(Q, D, R, Neg, RoundMode);

      BigNumberCopy(Res.FValue, Q);
      Res.FScale := Digits;
      Res.FValue.SetNegative(Neg);

      if Res <> Num then           // ��� Num �Ƕ����ģ�����Ҫ��ԭ�� Neg
        Num.FValue.SetNegative(Neg);
      Result := True;
    finally
      FLocalBigNumberPool.Recycle(D);
      FLocalBigNumberPool.Recycle(Q);
      FLocalBigNumberPool.Recycle(R);
    end;
  end;
end;

function BigDecimalTrunc(const Res: TCnBigDecimal; const Num: TCnBigDecimal): Boolean;
begin
  if Num.FScale <= 0 then // ��С������
  begin
    BigDecimalCopy(Res, Num);
    Result := True;
    Exit;
  end
  else // ��С������ FScale λ���ɵ�
  begin
    Result := BigDecimalChangeToScale(Res, Num, 0, drTowardsZero);
  end;
end;

function BigDecimalDebugDump(const Num: TCnBigDecimal): string;
begin
  Result := 'Scale: ' + IntToStr(Num.FScale) + '. ' + BigNumberDebugDump(Num.FValue);
end;

{ TCnBigDecimal }

procedure TCnBigDecimal.AddWord(W: LongWord);
var
  T: TCnBigDecimal;
begin
  T := FLocalBigDecimalPool.Obtain;
  try
    T.SetWord(W);
    BigDecimalAdd(Self, Self, T);
  finally
    FLocalBigDecimalPool.Recycle(T);
  end;
end;

constructor TCnBigDecimal.Create;
begin
  inherited;
  FValue := TCnBigNumber.Create;
end;

destructor TCnBigDecimal.Destroy;
begin
  FValue.Free;
  inherited;
end;

procedure TCnBigDecimal.DivWord(W: LongWord);
var
  T: TCnBigDecimal;
begin
  T := FLocalBigDecimalPool.Obtain;
  try
    T.SetWord(W);
    BigDecimalDiv(Self, Self, T);
  finally
    FLocalBigDecimalPool.Recycle(T);
  end;
end;

function TCnBigDecimal.GetDebugDump: string;
begin
  Result := BigDecimalDebugDump(Self);
end;

function TCnBigDecimal.GetDecString: string;
begin
  Result := BigDecimalToString(Self);
end;

function TCnBigDecimal.IsNegative: Boolean;
begin
  Result := FValue.IsNegative;
end;

function TCnBigDecimal.IsZero: Boolean;
begin
  Result := FValue.IsZero;
end;

procedure TCnBigDecimal.MulWord(W: LongWord);
begin
  FValue.MulWord(W);
end;

procedure TCnBigDecimal.Negate;
begin
  FValue.Negate;
end;

function TCnBigDecimal.SetDec(const Buf: string): Boolean;
begin
  Result := BigDecimalSetDec(Buf, Self);
end;

procedure TCnBigDecimal.SetDouble(Value: Double);
begin
  BigDecimalSetDouble(Value, Self);
end;

procedure TCnBigDecimal.SetExtended(Value: Extended);
begin
  BigDecimalSetExtended(Value, Self);
end;

function TCnBigDecimal.SetInt64(W: Int64): Boolean;
begin
  Result := BigDecimalSetInt64(W, Self);
end;

procedure TCnBigDecimal.SetNegative(Neg: Boolean);
begin
  FValue.SetNegative(Neg);
end;

procedure TCnBigDecimal.SetOne;
begin
  FValue.SetOne;
  FScale := 0;
end;

procedure TCnBigDecimal.SetSingle(Value: Single);
begin
  BigDecimalSetSingle(Value, Self);
end;

function TCnBigDecimal.SetWord(W: LongWord): Boolean;
begin
  Result := BigDecimalSetWord(W, Self);
end;

procedure TCnBigDecimal.SetZero;
begin
  FValue.SetZero;
  FScale := 0;
end;

procedure TCnBigDecimal.SubWord(W: LongWord);
var
  T: TCnBigDecimal;
begin
  T := FLocalBigDecimalPool.Obtain;
  try
    T.SetWord(W);
    BigDecimalSub(Self, Self, T);
  finally
    FLocalBigDecimalPool.Recycle(T);
  end;
end;

function TCnBigDecimal.ToString: string;
begin
  Result := BigDecimalToString(Self);
end;

{ TCnBigDecimalPool }

constructor TCnBigDecimalPool.Create;
begin
  inherited Create(False);
end;

destructor TCnBigDecimalPool.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TObject(Items[I]).Free;
  inherited;
end;

function TCnBigDecimalPool.Obtain: TCnBigDecimal;
begin
  if Count = 0 then
  begin
    Result := TCnBigDecimal.Create
  end
  else
  begin
    Result := TCnBigDecimal(Items[Count - 1]);
    Delete(Count - 1);
    Result.SetZero;
  end;
end;

procedure TCnBigDecimalPool.Recycle(Num: TCnBigDecimal);
begin
  if Num <> nil then
    Add(Num);
end;

initialization
  FLocalBigDecimalPool := TCnBigDecimalPool.Create;
  FLocalBigNumberPool := TCnBigNumberPool.Create;

  CnBigDecimalOne := TCnBigDecimal.Create;
  CnBigDecimalOne.SetOne;
  CnBigDecimalZero := TCnBigDecimal.Create;
  CnBigDecimalZero.SetZero;

finalization
  CnBigDecimalZero.DecString; // �ֹ������������ֹ������������
  CnBigDecimalZero.DebugDump;

  CnBigDecimalZero.Free;
  CnBigDecimalOne.Free;

  FLocalBigNumberPool.Free;
  FLocalBigDecimalPool.Free;

end.
