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

unit CnInt128;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ�128 λ���޷�������������ʵ��
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��ȱ������ȡģ�ȣ����Ҵ���������
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 XE 2
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.06.11 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNativeDecl;

type
  TCnInt128 = packed record   // 128 λ�з��������ṹ
    Lo64, Hi64: Int64;        // ע�� Lo64 �ڲ�����Ϊ 64 λ�޷�����������
  end;
  PCnInt128 = ^TCnInt128;

  TCnUInt128 = packed record  // 128 λ�޷��������ṹ
    Lo64, Hi64: TUInt64;
  end;
  PCnUInt128 = ^TCnUInt128;

// ========================= Int128 ���㺯�� ===================================

procedure Int128Set(var R: TCnInt128; Lo, Hi: Int64); overload;
{* �ֱ����� 128 λ�з������ĸߵ� 64 λԭʼֵ�������⴦��������}

procedure Int128Set(var R: TCnInt128; Lo: Int64); overload;
{* ���� 128 λ�з������ĵ� 64 λֵ����λ�������������ȫ 0 ��ȫ F}

procedure Int128Copy(var D, S: TCnInt128);
{* ���� 128 λ�з�����}

procedure Int128SetZero(var N: TCnInt128);
{* ��һ 128 λ�з������� 0}

procedure Int128Add(var R, A, B: TCnInt128); overload;
{* 128 λ�з�������ӣ�����������������R��A��B ������ͬ��A B ʹ�ò�������ֿ���������ֵ}

procedure Int128Add(var R, A: TCnInt128; V: Int64); overload;
{* ��һ 128 λ�з���������һ�� 64 λ�з������������� B Ϊ��ֵ�����}

procedure Int128Sub(var R, A, B: TCnInt128); overload;
{* 128 λ�з��������������������������R��A��B ������ͬ}

procedure Int128Sub(var R, A: TCnInt128; V: Int64); overload;
{* ��һ 128 λ�з�������ȥһ�� 64 λ�з������������� B Ϊ��ֵ�����}

procedure Int128Mul(var R, A, B: TCnInt128; ResHi: PCnInt128 = nil);
{* 128 λ�з�������ˣ�����������쳣��ResHi �����ݲ������ã���R��A��B ������ͬ}

procedure Int128ShiftLeft(var N: TCnInt128; S: Integer);
{* 128 λ�з�������λ����}

procedure Int128ShiftRight(var N: TCnInt128; S: Integer);
{* 128 λ�з�������λ����}

procedure Int128And(var R, A, B: TCnInt128);
{* ���� 128 λ�з�������λ��}

procedure Int128Or(var R, A, B: TCnInt128);
{* ���� 128 λ�з�������λ��}

procedure Int128Xor(var R, A, B: TCnInt128);
{* ���� 128 λ�з�������λ���}

procedure Int128Negate(var N: TCnInt128);
{* ��һ 128 λ�з�������Ϊ���෴��}

procedure Int128Not(var N: TCnInt128);
{* ��һ 128 λ�з�������}

procedure Int128SetBit(var N: TCnInt128; Bit: Integer);
{* ��һ 128 λ�з�������ĳһλ�� 1��Bit �� 0 �� 127}

procedure Int128ClearBit(var N: TCnInt128; Bit: Integer);
{* ��һ 128 λ�з�������ĳһλ�� 0��Bit �� 0 �� 127}

function Int128IsBitSet(var N: TCnInt128; Bit: Integer): Boolean;
{* ����һ��128 λ�з�������ĳһλ�Ƿ��� 0��Bit �� 0 �� 127}

function Int128IsNegative(var N: TCnInt128): Boolean;
{* �ж�һ 128 λ�з������Ƿ��Ǹ���}

function Int128Equal(var A, B: TCnInt128): Boolean;
{* �ж����� 128 λ�з������Ƿ����}

function Int128Compare(var A, B: TCnInt128): Integer;
{* �Ƚ����� 128 λ�з����������ڵ���С�ڷֱ𷵻� 1��0��-1}

function Int128ToHex(var N: TCnInt128): string;
{* �� 128 λ�з�����ת��Ϊʮ�������ַ���}

// ======================== UInt128 ���㺯�� ===================================

procedure UInt128Set(var R: TCnUInt128; Lo, Hi: TUInt64); overload;
{* �ֱ����� 128 λ�޷������ĸߵ� 64 λֵ}

procedure UInt128Set(var R: TCnUInt128; Lo: TUInt64); overload;
{* ���� 128 λ�޷������ĵ� 64 λֵ����λ�� 0}

procedure UInt128Copy(var D, S: TCnUInt128);
{* ���� 128 λ�޷�����}

procedure UInt128SetZero(var N: TCnUInt128);
{* ��һ 128 λ�޷������� 0}

procedure UInt128Add(var R: TCnUInt128; V: TUInt64); overload;
{* ��һ 128 λ�޷���������һ�� 64 λ�޷�����}

procedure UInt128Add(var R, A, B: TCnUInt128); overload;
{* 128 λ�޷�������ӣ�����������������R��A��B������ͬ}

procedure UInt128Sub(var R, A, B: TCnUInt128);
{* 128 λ�޷��������������������������R��A��B������ͬ}

procedure UInt128Mul(var R, A, B: TCnUInt128; ResHi: PCnUInt128 = nil);
{* 128 λ�޷�������ˣ�������򳬹� 128 λ�ķ� ResHi ��
  �紫 nil ����������쳣��R��A��B������ͬ}

procedure UInt128ShiftLeft(var N: TCnUInt128; S: Integer);
{* 128 λ�޷�������λ����}

procedure UInt128ShiftRight(var N: TCnUInt128; S: Integer);
{* 128 λ�޷�������λ����}

procedure UInt128And(var R, A, B: TCnUInt128);
{* ���� 128 λ�޷�������λ��}

procedure UInt128Or(var R, A, B: TCnUInt128);
{* ���� 128 λ�޷�������λ��}

procedure UInt128Xor(var R, A, B: TCnUInt128);
{* ���� 128 λ�޷�������λ���}

procedure UInt128Not(var N: TCnUInt128);
{* 128 λ�޷�������}

procedure UInt128SetBit(var N: TCnUInt128; Bit: Integer);
{* ��һ 128 λ�޷�������ĳһλ�� 1��Bit �� 0 �� 127}

procedure UInt128ClearBit(var N: TCnUInt128; Bit: Integer);
{* ��һ 128 λ�޷�������ĳһλ�� 0��Bit �� 0 �� 127}

function UInt128IsBitSet(var N: TCnUInt128; Bit: Integer): Boolean;
{* ����һ��128 λ�޷�������ĳһλ�Ƿ��� 0��Bit �� 0 �� 127}

function UInt128Equal(var A, B: TCnUInt128): Boolean;
{* �ж����� 128 λ�޷������Ƿ����}

function UInt128Compare(var A, B: TCnUInt128): Integer;
{* �Ƚ����� 128 λ�޷����������ڵ���С�ڷֱ𷵻� 1��0��-1}

function IsUInt128AddOverflow(var A, B: TCnUInt128): Boolean;
{* �ж����� 64 λ�޷���������Ƿ���� 128 λ�޷�������}

function UInt128ToHex(var N: TCnUInt128): string;
{* �� 128 λ�޷�����ת��Ϊʮ�������ַ���}

implementation

var
  FInt128Zero: TCnInt128 = (Lo64: 0; Hi64: 0);
  FInt128One: TCnInt128 = (Lo64:1; Hi64: 0);

  FUInt128Zero: TCnUInt128 = (Lo64: 0; Hi64: 0);
  FUInt128One: TCnUInt128 = (Lo64:1; Hi64: 0);

procedure Int128Set(var R: TCnInt128; Lo, Hi: Int64);
begin
  R.Lo64 := Lo;
  R.Hi64 := Hi;
end;

procedure Int128Set(var R: TCnInt128; Lo: Int64);
begin
  R.Lo64 := Lo;
  if Lo >= 0 then
    R.Hi64 := 0
  else
    R.Hi64 := not 0;
end;

procedure Int128Copy(var D, S: TCnInt128);
begin
  D.Lo64 := S.Lo64;
  D.Hi64 := S.Hi64;
end;

procedure Int128SetZero(var N: TCnInt128);
begin
  N.Lo64 := 0;
  N.Hi64 := 0;
end;

procedure Int128Add(var R, A, B: TCnInt128);
var
  C: Integer;
begin
{$IFDEF SUPPORT_UINT64}
  UInt64Add(UInt64(R.Lo64), UInt64(A.Lo64), UInt64(B.Lo64), C);
{$ELSE}
  UInt64Add(R.Lo64, A.Lo64, B.Lo64, C);
{$ENDIF}
  R.Hi64 := A.Hi64 + B.Hi64 + C;
end;

procedure Int128Add(var R, A: TCnInt128; V: Int64); overload;
var
  C: Integer;
begin
  if V < 0 then
  begin
    V := (not V) + 1; // �󷴼�һ����ֵȻ���
{$IFDEF SUPPORT_UINT64}
    UInt64Sub(UInt64(R.Lo64), UInt64(A.Lo64), UInt64(V), C);
{$ELSE}
    UInt64Sub(R.Lo64, A.Lo64, V, C);
{$ENDIF}
  end
  else // V >= 0���� UInt64 ͬ������
  begin
{$IFDEF SUPPORT_UINT64}
    UInt64Add(UInt64(R.Lo64), UInt64(A.Lo64), UInt64(V), C);
{$ELSE}
    UInt64Add(R.Lo64, A.Lo64, V, C);
{$ENDIF}
  end;
  R.Hi64 := A.Hi64 + C;
end;

procedure Int128Sub(var R, A, B: TCnInt128);
var
  C: Integer;
begin
{$IFDEF SUPPORT_UINT64}
  UInt64Sub(UInt64(R.Lo64), UInt64(A.Lo64), UInt64(B.Lo64), C);
{$ELSE}
  UInt64Sub(R.Lo64, A.Lo64, B.Lo64, C);
{$ENDIF}
  R.Hi64 := A.Hi64 - B.Hi64 - C;
end;

procedure Int128Sub(var R, A: TCnInt128; V: Int64);
var
  C: Integer;
begin
  if V < 0 then
  begin
    V := (not V) + 1; // �󷴼�һ����ֵȻ���
{$IFDEF SUPPORT_UINT64}
    UInt64Add(UInt64(R.Lo64), UInt64(A.Lo64), UInt64(V), C);
{$ELSE}
    UInt64Add(R.Lo64, A.Lo64, V, C);
{$ENDIF}
  end
  else // V >= 0���� UInt64 ͬ������
  begin
{$IFDEF SUPPORT_UINT64}
    UInt64Sub(UInt64(R.Lo64), UInt64(A.Lo64), UInt64(V), C);
{$ELSE}
    UInt64Sub(R.Lo64, A.Lo64, V, C);
{$ENDIF}
  end;
  R.Hi64 := A.Hi64 - C;
end;

procedure Int128Mul(var R, A, B: TCnInt128; ResHi: PCnInt128);
var
  N1, N2: Boolean;
begin
  N1 := Int128IsNegative(A);
  N2 := Int128IsNegative(B);

  // ȫ����
  if N1 then
    Int128Negate(A);
  if N2 then
    Int128Negate(B);

  UInt128Mul(TCnUInt128(R), TCnUInt128(A), TCnUInt128(B));
  if Int128IsNegative(R) then // �˻��Ǹ�˵�������
    raise EIntOverflow.Create('Int128 Mul Overflow');

  if N1 <> N2 then // ֻҪ��һ�����
  begin
    Int128Negate(R);
    // TODO: ResHi ��α䣿�Ȳ���
  end;

  // ���ȥ
  if N1 then
    Int128Negate(A);
  if N2 then
    Int128Negate(B);
end;

procedure Int128ShiftLeft(var N: TCnInt128; S: Integer);
begin
  UInt128ShiftLeft(TCnUInt128(N), S);
end;

procedure Int128ShiftRight(var N: TCnInt128; S: Integer);
begin
  UInt128ShiftRight(TCnUInt128(N), S);
end;

procedure Int128And(var R, A, B: TCnInt128);
begin
  R.Lo64 := A.Lo64 and B.Lo64;
  R.Hi64 := A.Hi64 and B.Hi64;
end;

procedure Int128Or(var R, A, B: TCnInt128);
begin
  R.Lo64 := A.Lo64 or B.Lo64;
  R.Hi64 := A.Hi64 or B.Hi64;
end;

procedure Int128Xor(var R, A, B: TCnInt128);
begin
  R.Lo64 := A.Lo64 xor B.Lo64;
  R.Hi64 := A.Hi64 xor B.Hi64;
end;

procedure Int128Negate(var N: TCnInt128);
var
  C: Integer;
begin
  // ȫ����Ȼ�������һ
  N.Lo64 := not N.Lo64;
  N.Hi64 := not N.Hi64;

{$IFDEF SUPPORT_UINT64}
  UInt64Add(UInt64(N.Lo64), UInt64(N.Lo64), 1, C);
{$ELSE}
  UInt64Add(N.Lo64, N.Lo64, 1, C);
{$ENDIF}
  if C > 0 then
    N.Hi64 := N.Hi64 + C;
end;

procedure Int128Not(var N: TCnInt128);
begin
  N.Lo64 := not N.Lo64;
  N.Hi64 := not N.Hi64;
end;

procedure Int128SetBit(var N: TCnInt128; Bit: Integer);
begin
  if Bit > 63 then
    UInt64SetBit(N.Hi64, Bit - 64)
  else
    UInt64SetBit(N.Lo64, Bit);
end;

procedure Int128ClearBit(var N: TCnInt128; Bit: Integer);
begin
  if Bit > 63 then
    UInt64ClearBit(N.Hi64, Bit - 64)
  else
    UInt64ClearBit(N.Lo64, Bit);
end;

function Int128IsBitSet(var N: TCnInt128; Bit: Integer): Boolean;
begin
  if Bit > 63 then
    Result := GetUInt64BitSet(N.Hi64, Bit - 64)
  else
    Result := GetUInt64BitSet(N.Hi64, Bit);
end;

function Int128IsNegative(var N: TCnInt128): Boolean;
begin
  Result := N.Hi64 < 0;
end;

function Int128Equal(var A, B: TCnInt128): Boolean;
begin
  Result := (A.Lo64 = B.Lo64) and (A.Hi64 = B.Hi64);
end;

function Int128Compare(var A, B: TCnInt128): Integer;
var
  R: Integer;
begin
  if A.Hi64 > B.Hi64 then
    Result := 1
  else if A.Hi64 < B.Hi64 then
    Result := -1
  else
  begin
    R := UInt64Compare(A.Lo64, B.Lo64); // �� 64 λ����Ϊ�޷������Ƚ�
    if A.Hi64 < 0 then // ����Ǹ�ֵ������
      R := -R;

    if R > 0 then
      Result := 1
    else if R < 0 then
      Result := -1
    else
      Result := 0;
  end;
end;

function Int128ToHex(var N: TCnInt128): string;
var
  T: TCnInt128;
begin
  if N.Hi64 < 0 then
  begin
    Int128Copy(T, N);
    Int128Negate(T);
    Result := '-' + UInt64ToHex(T.Hi64) + UInt64ToHex(T.Lo64);
  end
  else
    Result := UInt64ToHex(N.Hi64) + UInt64ToHex(N.Lo64);
end;

// ======================== UInt128 ���㺯�� ===================================

procedure UInt128Set(var R: TCnUInt128; Lo, Hi: TUInt64);
begin
  R.Lo64 := Lo;
  R.Hi64 := Hi;
end;

procedure UInt128Set(var R: TCnUInt128; Lo: TUInt64);
begin
  R.Lo64 := Lo;
  R.Hi64 := 0;
end;

procedure UInt128Copy(var D, S: TCnUInt128);
begin
  D.Lo64 := S.Lo64;
  D.Hi64 := S.Hi64;
end;

procedure UInt128SetZero(var N: TCnUInt128);
begin
  N.Lo64 := 0;
  N.Hi64 := 0;
end;

procedure UInt128Add(var R, A, B: TCnUInt128);
var
  C: Integer;
begin
  UInt64Add(R.Lo64, A.Lo64, B.Lo64, C);
  R.Hi64 := A.Hi64 + B.Hi64 + C;
end;

procedure UInt128Add(var R: TCnUInt128; V: TUInt64);
var
  C: Integer;
begin
  UInt64Add(R.Lo64, R.Lo64, V, C);
  R.Hi64 := R.Hi64 + C;
end;

// ���� 128 λ�޷�������ӣ�A + B => R������������������� 1 ���λ������������
procedure UInt128AddC(var R: TCnUInt128; A, B: TCnUInt128; out Carry: Integer);
begin
  UInt128Add(R, A, B);
  if UInt128Compare(R, A) < 0 then // �޷�����ӣ����ֻҪС����һ������˵�������
    Carry := 1
  else
    Carry := 0;
end;

procedure UInt128Sub(var R, A, B: TCnUInt128);
var
  C: Integer;
begin
  UInt64Sub(R.Lo64, A.Lo64, B.Lo64, C);
  R.Hi64 := A.Hi64 - B.Hi64 - C;
end;

procedure UInt128Mul(var R, A, B: TCnUInt128; ResHi: PCnUInt128);
var
  R0, R1, R2, R3, Lo, T: TCnUInt128;
  C1, C2: Integer;
begin
  UInt64MulUInt64(A.Lo64, B.Lo64, R0.Lo64, R0.Hi64); //       0       0   | R0.Hi64 R0.Lo64
  UInt64MulUInt64(A.Hi64, B.Lo64, R1.Lo64, R1.Hi64); //       0   R1.Hi64 | R1.Lo64    0
  UInt64MulUInt64(A.Lo64, B.Hi64, R2.Lo64, R2.Hi64); //       0   R2.Hi64 | R2.Lo64    0
  UInt64MulUInt64(A.Hi64, B.Hi64, R3.Lo64, R3.Hi64); //   R3.Hi64 R3.Lo64 |    0       0

  T.Lo64 := 0;
  T.Hi64 := R1.Lo64;
  UInt128AddC(Lo, R0, T, C1);

  T.Hi64 := R2.Lo64;
  UInt128AddC(Lo, Lo, T, C2);

  UInt128Copy(R, Lo); // �� 128 λ����Ѿ��õ���

  if (C1 > 0) or (C2 > 0) or (R1.Hi64 > 0) or (R2.Hi64 > 0) or (R3.Lo64 > 0) or (R3.Hi64 > 0) then
  begin
    // ������������ֵҪ�� ResHi^ �У�������û�ṩ�������쳣
    if ResHi = nil then
      raise EIntOverflow.Create('UInt128 Mul Overflow');

    T.Hi64 := 0;
    T.Lo64 := R1.Hi64;
    UInt128Add(ResHi^, R3, T);

    T.Lo64 := R2.Hi64;
    UInt128Add(ResHi^, ResHi^, T);

    T.Lo64 := C1 + C2;
    UInt128Add(ResHi^, ResHi^, T); // �ӽ�λ�������ٳ��������
  end;
end;

procedure UInt128ShiftLeft(var N: TCnUInt128; S: Integer);
var
  T, M: TUInt64;
begin
  if S = 0 then
    Exit;

  if S < 0 then
    UInt128ShiftRight(N, -S);

  if S > 128 then // ȫ������
  begin
    N.Hi64 := 0;
    N.Lo64 := 0;
  end
  else if S > 64 then
  begin
    // Lo Ϊȫ 0
    N.Hi64 := N.Lo64 shl (S - 64);
    N.Lo64 := 0;
  end
  else
  begin
    // ȡ�� Lo �ĸ� S λ
    M := (not TUInt64(0)) shl (64 - S);
    T := N.Lo64 and M;
    T := T shr (64 - S);

    // Lo �� Hi ������ S
    N.Lo64 := N.Lo64 shl S;
    N.Hi64 := N.Hi64 shl S;

    // Lo ���Ƴ��ĸ߲��ַŵ� Hi �����ĵͲ���
    N.Hi64 := N.Hi64 or T;
  end;
end;

procedure UInt128ShiftRight(var N: TCnUInt128; S: Integer);
var
  T, M: TUInt64;
begin
  if S = 0 then
    Exit;

  if S < 0 then
    UInt128ShiftLeft(N, -S);

  if S > 128 then // ȫ������
  begin
    N.Hi64 := 0;
    N.Lo64 := 0;
  end
  else if S > 64 then
  begin
    // Lo Ϊȫ 0
    N.Lo64 := N.Hi64 shr (S - 64);
    N.Hi64 := 0;
  end
  else
  begin
    // ȡ�� Hi �ĵ� S λ
    M := (not TUInt64(0)) shr (64 - S);
    T := N.Hi64 and M;
    T := T shl (64 - S);

    // Lo �� Hi ������ S
    N.Lo64 := N.Lo64 shr S;
    N.Hi64 := N.Hi64 shr S;

    // Hi ���Ƴ��ĵͲ��ַŵ� Lo �����ĸ߲���
    N.Lo64 := N.Lo64 or T;
  end;
end;

procedure UInt128And(var R, A, B: TCnUInt128);
begin
  R.Lo64 := A.Lo64 and B.Lo64;
  R.Hi64 := A.Hi64 and B.Hi64;
end;

procedure UInt128Or(var R, A, B: TCnUInt128);
begin
  R.Lo64 := A.Lo64 or B.Lo64;
  R.Hi64 := A.Hi64 or B.Hi64;
end;

procedure UInt128Xor(var R, A, B: TCnUInt128);
begin
  R.Lo64 := A.Lo64 xor B.Lo64;
  R.Hi64 := A.Hi64 xor B.Hi64;
end;

procedure UInt128Not(var N: TCnUInt128);
begin
  N.Lo64 := not N.Lo64;
  N.Hi64 := not N.Hi64;
end;

procedure UInt128SetBit(var N: TCnUInt128; Bit: Integer);
begin
  if Bit > 63 then
    UInt64SetBit(N.Hi64, Bit - 64)
  else
    UInt64SetBit(N.Lo64, Bit);
end;

procedure UInt128ClearBit(var N: TCnUInt128; Bit: Integer);
begin
  if Bit > 63 then
    UInt64ClearBit(N.Hi64, Bit - 64)
  else
    UInt64ClearBit(N.Lo64, Bit);
end;

function UInt128IsBitSet(var N: TCnUInt128; Bit: Integer): Boolean;
begin
  if Bit > 63 then
    Result := GetUInt64BitSet(N.Hi64, Bit - 64)
  else
    Result := GetUInt64BitSet(N.Hi64, Bit);
end;

function UInt128Equal(var A, B: TCnUInt128): Boolean;
begin
  Result := (A.Lo64 = B.Lo64) and (A.Hi64 = B.Hi64);
end;

function UInt128Compare(var A, B: TCnUInt128): Integer;
begin
  if A.Hi64 > B.Hi64 then
    Result := 1
  else if A.Hi64 < B.Hi64 then
    Result := -1
  else
  begin
    if A.Lo64 > B.Lo64 then
      Result := 1
    else if A.Lo64 < B.Lo64 then
      Result := -1
    else
      Result := 0;
  end;
end;

function IsUInt128AddOverflow(var A, B: TCnUInt128): Boolean;
var
  R: TCnUInt128;
begin
  UInt128Add(R, A, B);
  Result := UInt128Compare(R, A) < 0;
end;

function UInt128ToHex(var N: TCnUInt128): string;
begin
  Result := UInt64ToHex(N.Hi64) + UInt64ToHex(N.Lo64);
end;

end.

