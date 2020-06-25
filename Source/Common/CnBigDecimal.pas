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
  CN_BIG_DECIMAL_MAX_SCALE = MaxInt div SizeOf(Integer);     // ���ָ��

  CN_BIG_DECIMAL_MIN_SCALE = -CN_BIG_DECIMAL_MAX_SCALE - 1;  // ��Сָ��

  // ��ֱ���� Integer �������Сֵ����ΪҪ��ֹ������Ŀհ���

  CN_BIG_DECIMAL_DEFAULT_PRECISION = 12;                     // ������Ĭ�Ͼ���

type
  ECnBigDecimalException = class(Exception);

  TCnBigDecimal = class
  {* �󸡵���ʵ���࣬�� CnBigNumber ������Ч���֣��� Integer ����ָ��Ҳ����С����λ��
    FScale ����С��������Ч�������ұߵ�λ�ã�����Ϊ��������Ϊ��}
  private
    FValue: TCnBigNumber;
    FScale: Integer;   // ��ȷֵΪ FValue / (10^FScale)
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    function SetDec(const Buf: string): Boolean;
    {* �����ַ���ֵ}
    procedure SetSingle(Value: Single);
    {* �����ȸ���ֵ}
    procedure SetDouble(Value: Double);
    {* ˫���ȸ���ֵ}
    procedure SetExtended(Value: Extended);
    {* ��չ���ȸ���ֵ}

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
    {* ������ת���ַ���}
  end;

procedure BigDecimalClear(const Num: TCnBigDecimal);
{* ���һ���󸡵�����ʵ������ Value �� Scale ���� 0}

function BigDecimalSetDec(const Buf: string; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵������������ַ���ֵ}

function BigDecimalSetSingle(const Value: Single; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵����������õ����ȸ���ֵ}

function BigDecimalSetDouble(const Value: Double; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵�����������˫���ȸ���ֵ}

function BigDecimalSetExtended(const Value: Extended; const Res: TCnBigDecimal): Boolean;
{* Ϊ�󸡵�������������չ���ȸ���ֵ}

function BigDecimalToString(const Num: TCnBigDecimal): string;
{* �󸡵�������ת��Ϊ�ַ���}

function BigDecimalCompare(const Num1, Num2: TCnBigDecimal): Integer;
{* �Ƚ������󸡵�������}

procedure BigDecimalCopy(const Source, Dest: TCnBigDecimal);
{* �󸡵�����ֵ}

function BigDecimalGetPrecision(const Num: TCnBigDecimal): Integer;
{* ����󸡵�����ʮ����λ��}

function BigDecimalAdd(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
{* �󸡵����ӣ�Res ������ Num1 �� Num2��Num1 ������ Num2}

function BigDecimalSub(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
{* �󸡵�������Res ������ Num1 �� Num2��Num1 ������ Num2}

function BigDecimalMul(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
{* �󸡵����ˣ�Res ������ Num1 �� Num2��Num1 ������ Num2}

function BigDecimalDiv(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal; DivPrecision: Integer = CN_BIG_DECIMAL_DEFAULT_PRECISION): Boolean;
{* �󸡵�����}

function BigDecimalDebugDump(const Num: TCnBigDecimal): string;
{* ��ӡ�󸡵����ڲ���Ϣ}

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
  FLocalBigDecimalPool: TObjectList = nil;

function CheckScaleRange(AScale: Integer): Integer;
begin
  if (AScale < CN_BIG_DECIMAL_MIN_SCALE) or (AScale > CN_BIG_DECIMAL_MAX_SCALE) then
    raise ECnBigDecimalException.Create(SCnScaleOutOfRange);
  Result := AScale;
end;

procedure BigNumberMulPower5(Num: TCnBigNumber; Power5: Integer);
var
  I, L, D, R: Integer;
begin
  if Power5 < 0 then
    raise ECnBigDecimalException.Create(SCnNotImplemented);

  L := High(SCN_POWER_FIVES32);       // һ������ 13 ��
  D := Power5 div L;
  R := Power5 mod L;

  for I := 1 to D do                 // һ���� 13 ����
    Num.MulWord(SCN_POWER_FIVES32[L]);
  Num.MulWord(SCN_POWER_FIVES32[R]);  // ���ϳ�ʣ�µ�
end;

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
    T := TCnBigNumber.Create;
    L := Num1.FScale - Num2.FScale;
    CheckScaleRange(L);

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
      T.Free;
    end;
  end;
end;

procedure BigDecimalCopy(const Source, Dest: TCnBigDecimal);
begin
  if (Source <> nil) and (Dest <> nil) then
  begin
    BigNumberCopy(Dest.FValue, Source.FValue);
    Dest.FScale := Source.FScale;
  end;
end;

function BigDecimalGetPrecision(const Num: TCnBigDecimal): Integer;
begin
  Result := 0;
  if Num <> nil then
  begin
    Result := BigNumberGetTenPrecision(Num.FValue); // �õ�����λ
    // TODO: ��θ���ָ���ټ��㾫�ȣ�
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
    BigNumberCopy(Num2.FValue, Res.FValue);
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
    Result := BigNumberAdd(Res.FValue, Num1.FValue, Num2.FValue);
    Exit;
  end
  else
  begin
    // Ҫ�� Scale С��Ҳ����С���㿿�����������Խϴ�� Value��
    // ���� 10 ��ָ������ݲ���С��ͬ�ȵ� Scale �Զ���С���㲢������ֵ���䣬
    // �ٺ���һ����ӣ������ Scale ȡС��
    T := TCnBigNumber.Create;
    L := Num1.FScale - Num2.FScale;
    CheckScaleRange(L);

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
      T.Free;
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
    T := TCnBigNumber.Create;
    L := Num1.FScale - Num2.FScale;
    CheckScaleRange(L);

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
      T.Free;
    end;
  end;
end;

function BigDecimalMul(const Res: TCnBigDecimal; const Num1: TCnBigDecimal;
  const Num2: TCnBigDecimal): Boolean;
begin
  if Num1.FValue.IsZero or Num2.FValue.IsZero then
  begin
    Res.Clear;
    Result := True;
    Exit;
  end
  else
  begin
    Res.FScale := CheckScaleRange(Num1.FScale + Num2.FScale);
    Result := BigNumberMul(Res.FValue, Num1.FValue, Num2.FValue);
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
    Res.Clear;
    Result := True;
    Exit;
  end;

  // ������
  S := Num1.FValue.isNegative <> Num2.FValue.IsNegative; // ���Ų��Ƚ���Ÿ�
  TS := Num1.FScale - Num2.FScale;
  if DivPrecision < 0 then
    DivPrecision := 0;

  // ���ݾ���Ҫ����㽫�������ͳ���ͬʱ����ı���
  M := CheckScaleRange(DivPrecision + (Num2.FValue.Top - Num2.FValue.Top + 1) * 9 + 3);
  TS := CheckScaleRange(TS + M);

  T := nil;
  R := nil;
  try
    T := TCnBigNumber.Create;
    BigNumberCopy(T, Num1.FValue);
    BigNumberMulPower10(T, M);

    R := TCnBigNumber.Create;
    BigNumberDiv(Res.FValue, R, T, Num2.FValue);  // Num1.FValue * 10 ^ M div Num2.FValue �õ��̺�����

    Res.FScale := TS;

    // TODO: Լ��
    Res.FValue.SetNegative(S);
    Result := True;
  finally
    T.Free;
    R.Free;
  end;
end;

function BigDecimalDebugDump(const Num: TCnBigDecimal): string;
begin
  Result := 'Scale: ' + IntToStr(Num.FScale) + ' ' + BigNumberDebugDump(Num.FValue);
end;

{* �󸡵����ز���������ʼ}

function ObtainBigDecimalFromPool: TCnBigDecimal;
begin
  if FLocalBigDecimalPool.Count = 0 then
  begin
    Result := TCnBigDecimal.Create
  end
  else
  begin
    Result := TCnBigDecimal(FLocalBigDecimalPool.Items[FLocalBigDecimalPool.Count - 1]);
    FLocalBigDecimalPool.Delete(FLocalBigDecimalPool.Count - 1);
    Result.Clear;
  end;
end;

procedure RecycleBigDecimalToPool(Num: TCnBigDecimal);
begin
  if Num <> nil then
    FLocalBigDecimalPool.Add(Num);
end;

procedure FreeBigNumberPool;
var
  I: Integer;
begin
  for I := 0 to FLocalBigDecimalPool.Count - 1 do
    TObject(FLocalBigDecimalPool[I]).Free;

  FreeAndNil(FLocalBigDecimalPool);
end;

{ TCnBigDecimal }

procedure TCnBigDecimal.Clear;
begin
  BigDecimalClear(Self);
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

procedure TCnBigDecimal.SetSingle(Value: Single);
begin
  BigDecimalSetSingle(Value, Self);
end;

function TCnBigDecimal.ToString: string;
begin
  Result := BigDecimalToString(Self);
end;

initialization
  FLocalBigDecimalPool := TObjectList.Create(False);

finalization
  FreeBigNumberPool;

end.
