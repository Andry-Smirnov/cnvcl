{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2015 CnPack ������                       }
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

unit CnEventHook;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ������¼��ҽӵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�Ԫ�����ҽӶ�����¼�
* ����ƽ̨��PWin7 + Delphi 7
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.07.10
*               ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, SysUtils, Classes, Controls, TypInfo;

type
  TCnEventHook = class
  {* �ҽӶ����¼������ʵ����}
  private
    FObject: TObject;
    FEventName: string;
    FOldData: Pointer;
    FOldCode: Pointer;
    FNewData: Pointer;
    FNewCode: Pointer;
    FHooked: Boolean;
    FTrampolineData: TObject;
    FTrampoline: Pointer;
  public
    constructor Create(AObject: TObject; const AEventName: string;
      NewData: Pointer; NewCode: Pointer);
    {* ���캯����������ҽӵĶ��󣬴��ҽӵ��¼��������¼��������ĺ�����ַ��
      ���¼��������Ķ��󡣹�����Զ��ҽ�}
    destructor Destroy; override;
    {* �����������Զ�ȡ���ҽ�}

    procedure HookEvent;
    {* �ҽ��¼��������}
    procedure UnhookEvent;
    {* ȡ���ҽ��¼��������}

    property Hooked: Boolean read FHooked;
    {* ��ǰ�Ƿ��ѹҽ�}
    property EventName: string read FEventName;
    {* ���ҽӵ��¼���}

    property TrampolineData: TObject read FTrampolineData;
    {* �����¼��������Ķ���}
    property Trampoline: Pointer read FTrampoline;
    {* �����¼�����������ڵ�ַ}
  end;

implementation

{ TCnEventHook }

constructor TCnEventHook.Create(AObject: TObject;
  const AEventName: string; NewData, NewCode: Pointer);
begin
  FObject := AObject;
  FEventName := AEventName;
  FNewData := NewData;
  FNewCode := NewCode;

  HookEvent;
end;

destructor TCnEventHook.Destroy;
begin
  UnhookEvent;
  inherited;
end;

procedure TCnEventHook.HookEvent;
var
  Method: TMethod;
begin
  if Hooked then
    Exit;

  try
    Method := GetMethodProp(FObject, FEventName);
  except
    Exit;  // No EventName
  end;

  FOldCode := Method.Code;
  FOldData := Method.Data;

  FTrampolineData := TObject(FOldData);
  FTrampoline := FOldCode;

  Method.Code := FNewCode;
  Method.Data := FNewData;
  SetMethodProp(FObject, FEventName, Method);

  FHooked := True;
end;

procedure TCnEventHook.UnhookEvent;
var
  Method: TMethod;
begin
  if not Hooked then
    Exit;

  Method.Code := FOldCode;
  Method.Data := FOldData;

  SetMethodProp(FObject, FEventName, Method);
  FHooked := False;
end;

end.
 
