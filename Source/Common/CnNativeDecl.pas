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
  Classes, Windows, SysUtils;

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

function UInt64ToStr(N: TUInt64): string;
begin
  Result := Format('%u', [N]);
end;

function StrToUInt64(const S: string): TUInt64;
begin
  // Not Implemented
end;

end.
