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

unit CnNativeDecl;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ�32λ��64λ��һЩͳһ����
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��Delphi XE 2 ֧�� 32 �� 64 ���������ų��� NativeInt �� NativeUInt ��
*           ��ǰ�� 32 λ���� 64 ����̬�仯��Ӱ�쵽���� Pointer��Reference�ȶ�����
*           ���ǵ������ԣ��̶����ȵ� 32 λ Cardinal/Integer �Ⱥ� Pointer ��Щ��
*           ������ͨ���ˣ���ʹ 32 λ��Ҳ����������ֹ����˱���Ԫ�����˼������ͣ�
*           ��ͬʱ�ڵͰ汾�͸߰汾�� Delphi ��ʹ�á�
*           �������� UInt64 �İ�װ��ע�� D567 �²�ֱ��֧��UInt64 �����㣬��Ҫ��
*           ��������ʵ�֣�Ŀǰʵ���� div �� mod
* ����ƽ̨��PWin2000 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 XE 2
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnNativeDecl.pas 761 2011-02-07 14:08:58Z liuxiao@cnpack.org $
* �޸ļ�¼��2018.06.05 V1.2
*               ���� 64 λ���͵� div/mod ���㣬�ڲ�֧�� UInt64 ��ϵͳ���� Int64 ���� 
*           2016.09.27 V1.1
*               ���� 64 λ���͵�һЩ����
*           2011.07.06 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, Windows, SysUtils, SysConst;

const
  MAX_TUINT64                   = $FFFFFFFFFFFFFFFF;
  MAX_SIGNED_INT64_IN_TUINT64   = $7FFFFFFFFFFFFFFF;

type
{$IFDEF SUPPORT_32_AND_64}
  TCnNativeInt     = NativeInt;
  TCnNativeUInt    = NativeUInt;
  TCnNativePointer = NativeUInt;
{$ELSE}
  TCnNativeInt     = Integer;
  TCnNativeUInt    = Cardinal;
  TCnNativePointer = Cardinal;
{$ENDIF}

{$IFDEF WIN64}
  TCnUInt64        = NativeUInt;
  TCnInt64         = NativeInt;
{$ELSE}
  {$IFDEF SUPPORT_UINT64}
  TCnUInt64        = UInt64;
  {$ELSE}
  TCnUInt64 = packed record  // ֻ���������Ľṹ����
    case Boolean of
      True:  (Value: Int64);
      False: (Low32, Hi32: Cardinal);
  end;
  {$ENDIF}
  TCnInt64         = Int64;
{$ENDIF}

// TUInt64 ���� cnvcl ���в�֧�� UInt64 �������� div mod ��
{$IFDEF SUPPORT_UINT64}
  TUInt64          = UInt64;
{$ELSE}
  TUInt64          = Int64;
{$ENDIF}

{*
  ���� D567 �Ȳ�֧�� UInt64 �ı���������Ȼ������ Int64 ���� UInt64 ���мӼ����洢
  ���˳��������޷�ֱ����ɣ������װ���������� System ���е� _lludiv �� _llumod
  ������ʵ���� Int64 ��ʾ�� UInt64 ���ݵ� div �� mod ���ܡ�
}
function UInt64Mod(A, B: TUInt64): TUInt64;

function UInt64Div(A, B: TUInt64): TUInt64;

function UInt64ToStr(N: TUInt64): string;

function StrToUInt64(const S: string): TUInt64;

function UInt64Compare(A, B: TUInt64): Integer;

implementation

{
  UInt64 �� A mod B

  ���õ���ջ˳���� A �ĸ�λ��A �ĵ�λ��B �ĸ�λ��B �ĵ�λ������ push ��ϲ����뺯����
  ESP �Ƿ��ص�ַ��ESP+4 �� B �ĵ�λ��ESP + 8 �� B �ĸ�λ��ESP + C �� A �ĵ�λ��ESP + 10 �� A �ĸ�λ
  ����� push esp �� ESP ���� 4��Ȼ�� mov ebp esp��֮���� EBP ��Ѱַ��ȫҪ��� 4

  �� System.@_llumod Ҫ���ڸս���ʱ��EAX <- A �ĵ�λ��EDX <- A �ĸ�λ����System Դ��ע���� EAX/EDX д���ˣ�
  [ESP + 8]��Ҳ���� EBP + C��<- B �ĸ�λ��[ESP + 4] ��Ҳ���� EBP + 8��<- B �ĵ�λ

  ���� CALL ǰ�����ľ���ƴ���
}
function UInt64Mod(A, B: TUInt64): TUInt64;
asm
        // PUSH ESP �� ESP ���� 4��Ҫ����
        MOV     EAX, [EBP + $10]              // A Lo
        MOV     EDX, [EBP + $14]              // A Hi
        PUSH    DWORD PTR[EBP + $C]           // B Hi
        PUSH    DWORD PTR[EBP + $8]           // B Lo
        CALL    System.@_llumod;
end;

function UInt64Div(A, B: TUInt64): TUInt64;
asm
        // PUSH ESP �� ESP ���� 4��Ҫ����
        MOV     EAX, [EBP + $10]              // A Lo
        MOV     EDX, [EBP + $14]              // A Hi
        PUSH    DWORD PTR[EBP + $C]           // B Hi
        PUSH    DWORD PTR[EBP + $8]           // B Lo
        CALL    System.@_lludiv;
end;

function _ValUInt64(const S: string; var Code: Integer): TUInt64;
const
  FirstIndex = 1;
var
  I: Integer;
  Dig: Integer;
  Sign: Boolean;
  Empty: Boolean;
begin
  I := FirstIndex;
  Dig := 0;
  Result := 0;

  if S = '' then
  begin
    Code := 1;
    Exit;
  end;
  while S[I] = Char(' ') do
    Inc(I);
  Sign := False;
  if S[I] =  Char('-') then
  begin
    Sign := True;
    Inc(I);
  end
  else if S[I] =  Char('+') then
    Inc(I);
  Empty := True;

  if (S[I] =  Char('$')) or (UpCase(S[I]) =  Char('X'))
    or ((S[I] =  Char('0')) and (I < Length(S)) and (UpCase(S[I+1]) =  Char('X'))) then
  begin
    if S[I] =  Char('0') then
      Inc(I);
    Inc(I);
    while True do
    begin
      case   Char(S[I]) of
       Char('0').. Char('9'): Dig := Ord(S[I]) -  Ord('0');
       Char('A').. Char('F'): Dig := Ord(S[I]) - (Ord('A') - 10);
       Char('a').. Char('f'): Dig := Ord(S[I]) - (Ord('a') - 10);
      else
        Break;
      end;
      if Result > (MAX_TUINT64 shr 4) then
        Break;
      if Sign and (Dig <> 0) then
        Break;
      Result := Result shl 4 + Dig;
      Inc(I);
      Empty := False;
    end;
  end
  else
  begin
    while True do
    begin
      case Char(S[I]) of
        Char('0').. Char('9'): Dig := Ord(S[I]) - Ord('0');
      else
        Break;
      end;

      if Result > UInt64Div(MAX_TUINT64, 10) then
        Break;
      if Sign and (Dig <> 0) then
        Break;
      Result := Result * 10 + Dig;
      Inc(I);
      Empty := False;
    end;
  end;

  if (S[I] <> Char(#0)) or Empty then
    Code := I + 1 - FirstIndex
  else
    Code := 0;
end;

function UInt64ToStr(N: TUInt64): string;
begin
  Result := Format('%u', [N]);
end;

function StrToUInt64(const S: string): TUInt64;
{$IFNDEF SUPPORT_UINT64}
var
  E: Integer;
{$ENDIF}
begin
{$IFDEF SUPPORT_UINT64}
  Result := SysUtils.StrToUInt64(S);
{$ELSE}
  Result := _ValUInt64(S,  E);
  if E <> 0 then raise EConvertError.CreateResFmt(@SInvalidInteger, [S]);
{$ENDIF}
end;

function UInt64Compare(A, B: TUInt64): Integer;
{$IFNDEF SUPPORT_UINT64}
var
  HiA, HiB, LoA, LoB: DWORD;
{$ENDIF}
begin
{$IFDEF SUPPORT_UINT64}
  if A > B then
    Result := 1
  else if A < B then
    Result := -1
  else
    Result := 0;
{$ELSE}
  HiA := (A and $FFFFFFFF00000000) shr 32;
  HiB := (B and $FFFFFFFF00000000) shr 32;
  if HiA > HiB then
    Result := 1
  else if HiA < HiB then
    Result := -1
  else
  begin
    LoA := DWORD(A and $00000000FFFFFFFF);
    LoB := DWORD(B and $00000000FFFFFFFF);
    if LoA > LoB then
      Result := 1
    else if LoA < LoB then
      Result := -1
    else
      Result := 0;
  end;
{$ENDIF}
end;

end.
