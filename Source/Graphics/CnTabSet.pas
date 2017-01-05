{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2017 CnPack ������                       }
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

unit CnTabSet;
{* |<PRE>
================================================================================
* ������ƣ�����ؼ���
* ��Ԫ���ƣ�������˫���¼���TabSetʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP SP2 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.05.23
*             ���� Tab ���ɼ�ʱ��������һ��ķ���
*           2007.03.06
*             ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Tabs;

type
  TCnTabSetCloseEvent = procedure(Sender: TObject; Index: Integer;
    var CanClose: Boolean) of object;

  TCnTabSet = class(TTabSet)
  private
    FDblClickClose: Boolean;
    FOnCloseTab: TCnTabSetCloseEvent;
    function CalcVisibleTabs(Start, Stop: Integer; Canvas: TCanvas;
      First: Integer): Integer;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
  protected
    procedure DoCloseTab(Index: Integer; var CanClose: Boolean); virtual;
  public
    procedure MakeTabVisible;
    {* ��ǰ�� Tab ��ʾʱ��������һ�� Tab ��}
  published
    property DblClickClose: Boolean read FDblClickClose write FDblClickClose;
    {* �Ƿ�˫��ʱ�Զ��رյ�ǰҳ��}
    property OnCloseTab: TCnTabSetCloseEvent read FOnCloseTab write FOnCloseTab;
    {* ˫��ʱ�Զ��ر�ҳ��ǰ�������¼�}
    property OnDblClick;
    {* ˫��ʱ�����¼�}
  end;

implementation

const
  EdgeWidth = 9;

{ TCnTabSet }

function TCnTabSet.CalcVisibleTabs(Start, Stop: Integer; Canvas: TCanvas;
  First: Integer): Integer;
var
  Index, ASize: Integer;
  W: Integer;
begin
  Index := First;
  while (Start < Stop) and (Index < Tabs.Count) do
    with Canvas do
    begin
      W := TextWidth(Tabs[Index]);

      if (Style = tsOwnerDraw) then MeasureTab(Index, W);

      ASize := W;
      Inc(Start, ASize + EdgeWidth);    { next usable position }

      if Start <= Stop then
      begin
        Inc(Index);
      end;
    end;
  Result := Index - First;
end;

procedure TCnTabSet.DoCloseTab(Index: Integer; var CanClose: Boolean);
begin
  if Assigned(FOnCloseTab) then
    FOnCloseTab(Self, Index, CanClose);
end;

procedure TCnTabSet.MakeTabVisible;
var
  VTC: Integer;
begin
  // �����ǰ�޿ɼ� Tab����������ʼ
  VTC := CalcVisibleTabs(StartMargin + EdgeWidth, Width - EndMargin,
    Canvas, FirstIndex);
  if VTC = 0 then
    FirstIndex := 0;
end;

procedure TCnTabSet.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  P: TPoint;
  Index: Integer;
  CanClose: Boolean;
begin
  inherited;
  DblClick;

  if not FDblClickClose then
    Exit;

  P := ScreenToClient(Mouse.CursorPos);
  Index := ItemAtPos(P);

  if Index >= 0 then
  begin
    CanClose := True;
    DoCloseTab(Index, CanClose);
    
    if CanClose then
      Tabs.Delete(Index);
  end;
end;

end.
