{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2021 CnPack ������                       }
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

unit CnTextControl;
{* |<PRE>
================================================================================
* ������ƣ�����ؼ���
* ��Ԫ���ƣ��ı���ʾ��༭�ؼ�ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�Ԫ��ǰ��Ϊ�ڲ��ο�������
* ���˵����ScreenLineNumber���� ScreenRow��: �ؼ�����ʾ�õ������кţ��������� 1
*           LineNumber: ������������кţ�1 ��ʼ���� ScreenLineNumber ��� FVertOffset
*           PaintLineNumber: ���к����ϻ��Ƶ��кţ�û���۵�������µ��� LineNumber
*           ScreenColNumber���� ScreenCol�����ؼ�����ʾ�õ������кţ�������� 1
*           ColNumber��������������кţ�1 ��ʼ���� ScreenColNumber ��� FHoriOffset
*           CaretRow����ǰ������ڵ������кţ�1 ��ʼ������ ScreenLineNumber
*           CaretCol����ǰ������ڵ������кţ���ߵ� 1 ���ַ�������ǵ� 1 �����λ��
*           ������Ϊ���϶��������������������ͷ��������ʱ��������λ�þ���Ӧ�仯
*                     ���������ҳ��ʱ��������λ�÷����仯�������ݹ������ɼ�
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ�PWinXP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.04.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Controls, Graphics, Messages, Windows;

type
  TCnVirtualTextControl = class(TCustomControl)
  {* �ܹ���ʾ��ͬ��������ֲ������Ļ��࣬�;����ַ��������޹�}
  private
    FFontIsFixedWidth: Boolean;   // �����Ƿ�ȿ�
    FCharFrameSize: TPoint;       // �����ַ������ߴ磬��������
    FCharFrameWidthHalf: Integer; // �����ַ������ߴ��һ�룬���жϵ��ʱ������ַ�ǰ��ʹ��
    FCharWidth: Integer;          // ������ַ�ƽ����ȣ���������������
    FLineHeight: Integer;         // �иߣ�������������
    FShowLineNumber: Boolean;     // �Ƿ���ʾ�к���
    FLineNumCount: Integer;       // ����кŵ�λ��
    FLineNumPattern: string;      // ��������к�����Ӧ���ַ����������� 0000
    FLineNumWidth: Integer;       // ��������к�����Ӧ���ַ������
    FMaxLineCount: Integer;       // ��������кţ���������ã������� 1 �� FMaxLineCount
    FWheelLinesCount: Integer;    // ����������������������
    FLineNumColor: TColor;        // �к��ֵ���ɫ
    FLineNumFocusBkColor: TColor;     // �н���ʱ�к����ı���ɫ
    FLineNumNoFocusBkColor: TColor;   // �޽���ʱ�к����ı���ɫ
    FGutterRect: TRect;               // �����
    FTextRect: TRect;                 // ���ֻ�����
    FUseCaret: Boolean;               // �Ƿ�ʹ�ù��
    FCaretVisible: Boolean;           // ����Ƿ�ɼ�
    FCharFrameRow: Integer;           // ��ǰ�ַ���������кţ�1 ��ʼ
    FCharFrameCol: Integer;           // ��ǰ�ַ���������кţ�1 ��ʼ
    FCharFrameIsLeft: Boolean;        // �Ƿ��ڵ�ǰ�ַ��������
    FScreenCaretRow: Integer;         // ������ڵ������кţ�1 ��ʼ���� ScreenLineNumber
    FScreenCaretCol: Integer;         // ������ڵ������кţ�1 ��ʼ���� 1 ���ַ�������ǵ� 1 �����λ��
    FCaretRow: Integer;               // ������ڵ������кţ�1 ��ʼ���� LineNumber
    FCaretCol: Integer;               // ������ڵ������кţ�1 ��ʼ
    FCaretAfterLineEnd: Boolean;      // �Ƿ�������Խ����β
    FSelectStartRow: Integer;         // ѡ������ʼ�кţ����ڻ���ڽ����к�
    FSelectEndRow: Integer;           // ѡ���������к�
    FSelectStartCol: Integer;         // ѡ������ʼ�к�
    FSelectEndCol: Integer;           // ѡ���������к�
    FLeftMouseDown: Boolean;          // ��¼�������������
    FLeftMouseMoveAfterDown: Boolean; // ��¼���������º��Ƿ��϶���
    FIsWheeling: Boolean;             // ��ǰ����ʱ�Ƿ������������¼�����
    FOnCaretChange: TNotifyEvent;
    FOnScroll: TNotifyEvent;
    FUseSelection: Boolean;
    FOnSelectChange: TNotifyEvent;
    procedure UpdateScrollBars;       // ������Ļ״��ȷ����������λ�óߴ��
    procedure UpdateRects;
    {* �����ı������к����ȵĳߴ磬ע���� Paint ��û��ʹ��}
    procedure CalcMetrics;
    {* ����ı�ʱ���ã�ȫ������}
    function GetVisibleLineCount: Integer;
    function GetScreenBottomLine: Integer;
    procedure SetMaxLineCount(const Value: Integer);
    procedure SetShowLineNumber(const Value: Boolean);
    procedure SetLineNumColor(const Value: TColor);
    procedure SetLineNumFocusBkColor(const Value: TColor);
    procedure SetLineNumNoFocusBkColor(const Value: TColor);
    procedure SetUseCaret(const Value: Boolean);

    procedure DisplayCaret(CaretVisible: Boolean);
    {* ���ƹ����ʾ���}
    function GetTextRectLeft: Integer;
    {* ��̬�����ı���ʾ���������꣬�����к���ʾ��������}
    function GetTextRect: TRect;
    {* ������������ı�����ʾ������ȥ���ϡ����±߽�}
    function ScreenLineNumberToLineNumber(ScreenLineNumber: Integer): Integer;
    {* ����Ļ�ϵ������кţ�1 ��ʼ�ģ�ת���ɹ�����������кţ�1 ��ʼ�ģ�}
    function ScreenColNumberToColNumber(ScreenColNumber: Integer): Integer;
    {* ����Ļ�ϵ������кţ�1 ��ʼ�ģ�ת���ɹ�����������кţ�1 ��ʼ�ģ�}
    function LineNumberToScreenLineNumber(LineNumber: Integer): Integer;
    {* ����Ļ�ϵ������кţ�1 ��ʼ�ģ�ת������Ļ�ϵ������кţ�1 ��ʼ�ģ�}
    function ColNumberToScreenColNumber(ColNumber: Integer): Integer;
    {* ����Ļ�ϵ������кţ�1 ��ʼ�ģ�ת������Ļ�ϵ������кţ�1 ��ʼ�ģ�}
    function CalcRowCol(Pt: TPoint; out ACharFrameRow, ACharFrameCol,
      AScreenCaretRow, AScreenCaretCol, ACaretRow, ACaretCol: Integer;
      out ACharFrameIsLeft: Boolean): Boolean;
    {* ���ݿؼ�����������ַ�λ�ã����ؼ����Ƿ�ɹ�}
    procedure UpdateCursorFrameCaret;
    {* ���ݵ�ǰ���λ�ö�λ�ַ���λ��}
    procedure LimitRowColumnInLine(var LineNumber, Column: Integer);
    {* ���ݵ�ǰ���λ���Լ���������Լ��Ƿ������곬��β�������������������λ��}
    procedure SyncSelectionStartEnd(Force: Boolean = False);
    {* ����ѡ��״̬ʱ����ǿ�ƣ��������λ��ͬ������ѡ����ʼ����λ�ã�Ҳ��ζ��ȡ��ѡ��}
    procedure CalcSelectEnd(Pt: TPoint);
    {* ���ݿؼ���������㲢����ѡ����ĩβ��������ڹ����ƶ���Χ��}

    procedure SetCaretCol(const Value: Integer);
    procedure SetCaretRow(const Value: Integer);
    procedure SetCaretRowCol(Row, Col: Integer);
    procedure SetCaretAfterLineEnd(const Value: Boolean);
    procedure SetSelectEndCol(const Value: Integer);    // ������ѡ����β��
    procedure SetSelectEndRow(const Value: Integer);    // ������ѡ����β��
    procedure SetSelectStartCol(const Value: Integer);
    procedure SetSelectStartRow(const Value: Integer);
    function GetTopLine: Integer;
    function GetBottomLine: Integer;
    function GetLeftColumn: Integer;
    function GetRightColumn: Integer;
    procedure SetUseSelection(const Value: Boolean);
    procedure SetOnSelectChange(const Value: TNotifyEvent);
  protected
    FVertExp: Integer;            // ���������ָ�������ڿ���������̫��ʱ�������������̫ϸ
    FVertOffset: Integer;         // �������ƫ��������������Ϊ��λ��0 ��ʼ���� 1 ���� TopLine
    FHoriOffset: Integer;         // �������ƫ���������ַ���Ϊ��λ��0 ��ʼ

    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSetFont(var message: TMessage); message WM_SETFONT;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;

    procedure WMVScroll(var message: TWMScroll); message WM_VSCROLL;
    {* ���������Ϣ���������������������ʼ�У���������λ��}
    procedure WMHScroll(var message: TWMScroll); message WM_HSCROLL;
    {* ���������Ϣ�������º������������ʼ�У���������λ��}

    procedure WMSetFocus(var message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var message: TWMSetFocus); message WM_KILLFOCUS;
    procedure WMSize(var message: TWMSize); message WM_SIZE;
    procedure WMMouseWheel(var message: TWMMouseWheel); message WM_MOUSEWHEEL;
    {* �����ֹ������ö�����Ӱ������Ĺ��λ�ã�ֻ������������������λ�ÿ����Ƴ���Ļ��}

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure KeyDown(var Key: WORD; Shift: TShiftState); override;
    procedure DoScroll; virtual;
    procedure DoCaretChange; virtual;
    {* ���λ�÷����ı�ʱ����}
    procedure DoSelectChange; virtual;
    {* ѡ���������ı�ʱ����}

    procedure NavigationKey(Key: WORD; Shift: TShiftState); virtual;
    {* �յ��������·�����Լ� PageUp/PageDown Home/End ���Ĵ�������ֻ��������
      ���໹�������д�Դ������ƶ�}
    procedure MoveCaretToVisible;
    {* ����λ������Ļ��ʱ����ǰ���λ���ƶ�����Ļ��}
    procedure ScrollToVislbleCaret;
    {* ����λ������Ļ��ʱ������Ļ�Խ����¶���������겻�䣬��������ܷ����仯}

    procedure ScrollUpLine;      // �Ϲ�һ��
    procedure ScrollDownLine;    // �¹�һ��
    procedure ScrollLeftCol;     // ���һ��
    procedure ScrollRightCol;    // �ҹ�һ��
    procedure ScrollUpPage;      // �Ϲ�һ��
    procedure ScrollDownPage;    // �¹�һ��
    procedure ScrollLeftPage;    // ���һ��
    procedure ScrollRightPage;   // �ҹ�һ��

    procedure GetScreenCharPosRect(ScreenRow, ScreenCol: Integer; var Rect: TRect);
    {* ������������������ؼ��ڵ� Rect}
    procedure Paint; override;
    {* ���Ʒ���}
    procedure DoPaintLineNum(ScreenLineNumber, LineNumber: Integer; LineNumRect: TRect); virtual;
    {* Ĭ�ϵĻ����кŵķ��������� ScreenLineNumber Ϊ 1 ��ʼ�������кţ�
      LineNumber Ϊ������������кţ�LineNumRect Ϊ�кŴ����Ƶķ���}

    procedure DoPaintLine(ScreenLineNumber, LineNumber, HoriCharOffset: Integer;
      LineRect: TRect); virtual; abstract;
    {* �������ʵ�ֵĻ��������ݵķ��������� ScreenLineNumber Ϊ 1 ��ʼ�������кţ�
      LineNumber Ϊ������������кţ�LineNumRect Ϊ�����ݴ����Ƶĳ�������}

    function GetPaintLineNumber(LineNumber: Integer): Integer; virtual;
    {* �ӹ�����������кŷ������к����ϻ��Ƶ��кţ�Ĭ�����ֱ�ӷ���ԭʼֵ����
      ���෵�ز�ֵͬ�Դ����۵������ע�ⷵ��ֵ��Ҫ��������к�ֵ}

    function ClientPosToCharPos(Pt: TPoint; out ScreenRow, ScreenCol: Integer;
      out LeftHalf: Boolean; ExtendOut: Boolean = True): Boolean; virtual;
    {* ���ؼ��ڵ���������ת��Ϊ�������꣬Ҳ������������ڼ��У����ڵڼ����ַ������ڣ�
      �Լ����ַ����������ڿ���뻹�ǿ��Ұ룬����ȷ���������λ�á������Ƿ�ɹ�
      Row��Col ���� 1 ��ʼ��ExtendOut Ϊ True ʱ��ʾ�������������Ҳ���￿�����ȥ
      ע��������������һ���Ҳ�ܼ���ɹ����� True}

    function GetColumnFromLine(ScreenLineNumber, LineNumber, X: Integer;
      out ScreenCol: Integer; out LeftHalf: Boolean): Boolean; virtual;
    {* ���������к����ĺ����������ڵ��ַ��������ţ�1 ��ʼ���ڲ�ʵ���ǣ�
      �ȿ�����ʱ��ֱ�Ӹ����ַ��ߴ� FCharFrameSize ���㣬�ǵȿ�������� GetColumnFromLineVar
      �����Ƿ�ɹ�}

    function GetColumnFromLineVar(ScreenLineNumber, LineNumber, X: Integer;
      out ScreenCol: Integer; out LeftHalf: Boolean): Boolean; virtual;
    {* �ǵȿ���������£����������к����ĺ����������ڵ��ַ��������ţ�1 ��ʼ��
      ��Ҫ��������ʵ�֣���Ϊ���಻�����ַ�������}

    function GetLastColumnFromLine(LineNumber: Integer): Integer; virtual; abstract;
    {* ���������кŻ�ø�����β��������ֵ���������ʵ��}
  public
    constructor Create(AOwner: TComponent); override;
    {* ���캯��}
    destructor Destroy; override;
    {* ��������}

    function HasSelection: Boolean;
    {* �Ƿ���ѡ�������ڣ�Ҳ�����ж���ʼ�ͽ���λ���Ƿ���ͬ}

    property LineHeight: Integer read FLineHeight;
    {* �иߣ��������ָ߶ȡ����� ExternalLeading �Լ��м仭������Ԥ���Ŀ�϶}
    property TopLine: Integer read GetTopLine;
    {* �ؼ���ʾ�������һ�е������кţ����� FVertOffset + 1}
    property BottomLine: Integer read GetBottomLine;
    {* �ؼ���ʾ����������һ�е������кţ������� FMaxLineCount
      ���� FVertOffset + 1 + (TextRect.Bottom - TextRect.Top) div FLineHeight}
    property LeftColumn: Integer read GetLeftColumn;
    {* �ؼ���ʾ���������һ�е������кţ����� FHoriOffset + 1}
    property RightColumn: Integer read GetRightColumn;
    {* �ؼ���ʾ�������ұ�һ�е������кţ��;������޹أ�
      ���� FHoriOffset + 1 + (TextRect.Right - TextRect.Left) div FCharFrameSize.x}

    property ScreenBottomLine: Integer read GetScreenBottomLine;
    {* ������һ�е������кţ���������һ�е������к��� 1��}
    property VisibleLineCount: Integer read GetVisibleLineCount;
    {* ���ӻ���������������ʾ����߶��������и�}
    property MaxLineCount: Integer read FMaxLineCount write SetMaxLineCount;
    {* �������Ƶ������������}

    property WheelLinesCount: Integer read FWheelLinesCount write FWheelLinesCount;
    {* ������һ�ι���������}
    property ShowLineNumber: Boolean read FShowLineNumber write SetShowLineNumber;
    {* �Ƿ���ʾ�к���}
    property LineNumFocusBkColor: TColor read FLineNumFocusBkColor write SetLineNumFocusBkColor;
    {* �н���ʱ�к����ı�����ɫ}
    property LineNumNoFocusBkColor: TColor read FLineNumNoFocusBkColor write SetLineNumNoFocusBkColor;
    {* �޽���ʱ�к����ı�����ɫ}
    property LineNumColor: TColor read FLineNumColor write SetLineNumColor;
    {* �к�����������ɫ}
    property UseCaret: Boolean read FUseCaret write SetUseCaret;
    {* �Ƿ���ʾ������}
    property CaretAfterLineEnd: Boolean read FCaretAfterLineEnd write SetCaretAfterLineEnd;
    {* �Ƿ�������Խ����β}
    property CharFrameRow: Integer read FCharFrameRow write FCharFrameRow;
    {* ��ǰ�ַ���������кţ�1 ��ʼ}
    property CharFrameCol: Integer read FCharFrameCol write FCharFrameCol;
    {* ��ǰ�ַ���������кţ�1 ��ʼ}
    property ScreenCaretRow: Integer read FScreenCaretRow;
    {* ��ǰ���λ�����ڵ������кţ�1 ��ʼ��Ӧ�������ݹ������仯������Ĳ��䣩��
      ֵ��С�� 0����ʾ��ǰ����ڿؼ�������}
    property ScreenCaretCol: Integer read FScreenCaretCol;
    {* ��ǰ���λ�����ڵ������кţ�1 ��ʼ��Ӧ�������ݹ������仯������Ĳ��䣩��
      ֵ��С�� 0����ʾ��ǰ����ڿؼ�������}
    property CaretRow: Integer read FCaretRow write SetCaretRow;
    {* ��ǰ���λ�����ڵĹ�����������кţ�1 ��ʼ������ʱ���䣬�����������
      �� ScreenCaretRow ��һ�� FVertOffset}
    property CaretCol: Integer read FCaretCol write SetCaretCol;
    {* ��ǰ���λ�����ڵĹ�����������кţ�1 ��ʼ������ʱ���䣬�����������
      �� ScreenCaretCol ��һ�� FHoriOffset}

    property UseSelection: Boolean read FUseSelection write SetUseSelection;
    {* �Ƿ�����ѡ��������}

    property SelectStartRow: Integer read FSelectStartRow write SetSelectStartRow;
    {* ѡ������ʼ�У�1 ��ʼ�������к�}
    property SelectStartCol: Integer read FSelectStartCol write SetSelectStartCol;
    {* ѡ������ʼ�У�1 ��ʼ�������к�}
    property SelectEndRow: Integer read FSelectEndRow write SetSelectEndRow;
    {* ѡ���������У�1 ��ʼ�������к�}
    property SelectEndCol: Integer read FSelectEndCol write SetSelectEndCol;
    {* ѡ���������У�1 ��ʼ�������к�}

    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    {* �����¼�}
    property OnCaretChange: TNotifyEvent read FOnCaretChange write FOnCaretChange;
    {* ����ƶ��¼�}
    property OnSelectChange: TNotifyEvent read FOnSelectChange write SetOnSelectChange;
    {* ѡ���������ı�ʱ������ע���ʱ��겻һ��̧����}
  published
    property Align;
    property Ctl3D;
    property Color;
    property Font;
  end;

implementation

const
  MAX_NO_EXP_LINES = 32768;
  LEFT_MARGIN = 3;             // �к�������������ߵĿ�϶
  COMMON_MARGIN = 3;              // �����������Ŀ�϶
  SEP_WIDTH = 3;               // �к������������ָ��ߵĿ��
  LINE_GAP = 2;                // ������֮��Ŀ�϶���û��»��߲�������

function GetNumWidth(Int: Integer): Integer;
begin
  Result := Length(IntToStr(Int));
end;

function EnumFontsProc(var ELF: TEnumLogFont;
                       var TM: TNewTextMetric;
                       FontType: Integer;
                       Data: LPARAM): Integer; stdcall;
begin;
  Result := Integer(FIXED_PITCH = (ELF.elfLogFont.lfPitchAndFamily and FIXED_PITCH));
end;

{ TCnTextControl }

procedure TCnVirtualTextControl.CalcMetrics;
const
  csAlphaText = 'abcdefghijklmnopqrstuvwxyz';
  csHeightText = 'Wj_';
  csWidthText = 'W';
var
  LogFont: TLogFont;
  DC: HDC;
  SaveFont: HFONT;
  AHandle: THandle;
  TM: TEXTMETRIC;
  ASize: TSize;
begin
  FLineHeight := 0;

  if GetObject(Font.Handle, SizeOf(LogFont), @LogFont) <> 0 then
  begin
    DC := CreateCompatibleDC(0);
    SaveFont := 0;
    try
      AHandle := CreateFontIndirect(LogFont);
      AHandle := SelectObject(DC, AHandle);
      if SaveFont = 0 then
        SaveFont := AHandle
      else if AHandle <> 0 then
        DeleteObject(AHandle);

      GetTextMetrics(DC, TM);
      FCharWidth := TM.tmAveCharWidth; // �õ��ַ�ƽ�����

      GetTextExtentPoint(DC, csAlphaText, Length(csAlphaText), ASize);

      // ȡ�ı��߶��������и�
      if TM.tmHeight + TM.tmExternalLeading > FLineHeight then
        FLineHeight := TM.tmHeight + TM.tmExternalLeading;

      if ASize.cy > FLineHeight then
        FLineHeight := ASize.cy;

      // FLineHeight Ҫ�������¿�϶�Լ��»��ߵĿռ�����
      Inc(FLineHeight, LINE_GAP);

      // ����
      if ASize.cx div Length(csAlphaText) > FCharWidth then
        FCharWidth := ASize.cx div Length(csAlphaText);

      // ͨ����һ�ַ�ʽ����ַ���Ĵ�С
      GetTextExtentPoint32(DC, csWidthText, Length(csWidthText), ASize);
      FCharFrameSize.x := ASize.cx;
      FCharFrameWidthHalf := FCharFrameSize.x shr 1;

      GetTextExtentPoint32(DC, csHeightText, Length(csHeightText), ASize);
      FCharFrameSize.y := ASize.cy;

      // �����кſ��
      GetTextExtentPoint32(DC, PChar(FLineNumPattern), Length(FLineNumPattern), ASize);
      FLineNumWidth := ASize.cx;

      // �ж��Ƿ�ȿ�
      FFontIsFixedWidth := EnumFontFamiliesEx(DC, LogFont, @EnumFontsProc, 0, 0);
    finally
      SaveFont := SelectObject(DC, SaveFont);
      if SaveFont <> 0 then
        DeleteObject(SaveFont);
      DeleteDC(DC);
    end;
  end;
end;

function TCnVirtualTextControl.ClientPosToCharPos(Pt: TPoint; out ScreenRow,
  ScreenCol: Integer; out LeftHalf: Boolean; ExtendOut: Boolean): Boolean;
var
  TR: TRect;
begin
  Result := False;
  TR := GetTextRect;

  if ExtendOut then
  begin
    // �����ڷ�����ʱ���жϷ���������
    if Pt.x < TR.Left then
      Pt.x := TR.Left + 1;
    if Pt.x > TR.Right then
      Pt.x := TR.Right - 1;
    if Pt.y < TR.Top then
      Pt.y := TR.Top + 1;
    if Pt.y > TR.Bottom then
      Pt.y := TR.Bottom - 1;
  end;

  if PtInRect(TR, Pt) then
  begin
    ScreenRow := ((Pt.y - TR.Top) div FLineHeight) + 1;
    Result := GetColumnFromLine(ScreenRow, ScreenLineNumberToLineNumber(ScreenRow),
      Pt.x, ScreenCol, LeftHalf);
  end;
end;

constructor TCnVirtualTextControl.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csCaptureMouse, csOpaque, csClickEvents, csDoubleClicks];
  SetBounds(Left, Top, 300, 200);
  ParentFont := True;
  ParentColor := False;
  TabStop := True;

  FLineNumCount := 1;
  FLineNumPattern := '0';
  FLineHeight := 12;
  FWheelLinesCount := 3;

  FLineNumColor := clNavy;
  FLineNumFocusBkColor := clSilver;
  FLineNumNoFocusBkColor := clGray;

  FCaretRow := 1;
  FCaretCol := 1;
  FScreenCaretRow := 1;
  FScreenCaretCol := 1;
  FCaretAfterLineEnd := True;

  CalcMetrics;
end;

procedure TCnVirtualTextControl.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    Style := Style or WS_VSCROLL or WS_HSCROLL or WS_TABSTOP;
    if NewStyleControls and Ctl3D then
      ExStyle := ExStyle or WS_EX_CLIENTEDGE
    else
      Style := Style or WS_BORDER;
  end;
end;

destructor TCnVirtualTextControl.Destroy;
begin

  inherited;
end;


procedure TCnVirtualTextControl.DoPaintLineNum(ScreenLineNumber,
  LineNumber: Integer; LineNumRect: TRect);
begin
  Canvas.TextOut(LineNumRect.Left, LineNumRect.Top, IntToStr(LineNumber));
end;

procedure TCnVirtualTextControl.DoScroll;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

procedure TCnVirtualTextControl.GetScreenCharPosRect(ScreenRow,
  ScreenCol: Integer; var Rect: TRect);
begin
  Rect := GetTextRect;
  Inc(Rect.Top, (ScreenRow - 1) * FLineHeight);
  Inc(Rect.Left, (ScreenCol - 1) * FCharFrameSize.x);

  Rect.Bottom := Rect.Top + FLineHeight;
  Rect.Right := Rect.Left + FCharFrameSize.x;
end;

function TCnVirtualTextControl.GetColumnFromLine(ScreenLineNumber, LineNumber,
  X: Integer; out ScreenCol: Integer; out LeftHalf: Boolean): Boolean;
var
  T: Integer;
begin
  if FFontIsFixedWidth then
  begin
    Dec(X, GetTextRectLeft);                     // �ȿ�������������ûɶ����
    ScreenCol := (X div FCharFrameSize.x) + 1;
    T := X - (ScreenCol - 1) * FCharFrameSize.x;
    LeftHalf := T <= FCharFrameWidthHalf;
    Result := True;
  end
  else
    Result := GetColumnFromLineVar(ScreenLineNumber, LineNumber, X, ScreenCol, LeftHalf);
end;

function TCnVirtualTextControl.GetColumnFromLineVar(ScreenLineNumber, LineNumber, X: Integer;
  out ScreenCol: Integer; out LeftHalf: Boolean): Boolean;
var
  T: Integer;
begin
  Dec(X, GetTextRectLeft);                     // �ǵȿ������ڻ�����Ҳ����������
  ScreenCol := (X div FCharFrameSize.x) + 1;
  T := X - (ScreenCol - 1) * FCharFrameSize.x;
  LeftHalf := T < FCharFrameWidthHalf;
  Result := True;
end;

function TCnVirtualTextControl.GetPaintLineNumber(LineNumber: Integer): Integer;
begin
  Result := LineNumber;
end;

function TCnVirtualTextControl.GetTextRect: TRect;
begin
  Result.Top := COMMON_MARGIN;
  Result.Left := GetTextRectLeft;
  Result.Bottom := Result.Top + FLineHeight * VisibleLineCount;
  Result.Right := ClientWidth;
end;

function TCnVirtualTextControl.GetTextRectLeft: Integer;
begin
  Result := LEFT_MARGIN;
  if FShowLineNumber then
    Inc(Result, LEFT_MARGIN + FLineNumWidth + COMMON_MARGIN + SEP_WIDTH);
    // �ı�����߾������ƶ����Ƶľ���Ϊ�к�����ȼ��ϻ��߿��
end;

function TCnVirtualTextControl.GetTopLine: Integer;
begin
  Result := FVertOffset + 1;
end;

function TCnVirtualTextControl.GetBottomLine: Integer;
begin
  Result := FVertOffset + GetVisibleLineCount;
  if Result > FMaxLineCount then
    Result := FMaxLineCount;
end;

function TCnVirtualTextControl.GetVisibleLineCount: Integer;
begin
  if HandleAllocated then
    Result := (ClientHeight - COMMON_MARGIN * 2) div FLineHeight
  else
    Result := -1;
end;

procedure TCnVirtualTextControl.NavigationKey(Key: WORD; Shift: TShiftState);
var
  Msg: TWMScroll;
begin
  if FUseCaret then
  begin
    // �����й��ʱ�ķ����
    if not (ssShift in Shift) then
    begin
      // û�� Shift������ѡ��ģʽ�����ƶ����
      case Key of
        VK_LEFT:
          begin
            // ���������Ʋ����ֿɼ�
            CaretCol := CaretCol - 1;
            ScrollToVislbleCaret;
          end;
        VK_RIGHT:
          begin
            // ���������Ʋ����ֿɼ�
            CaretCol := CaretCol + 1;
            ScrollToVislbleCaret;
          end;
        VK_UP:
          begin
            // ���������Ʋ����ֿɼ�
            CaretRow := CaretRow - 1;
            ScrollToVislbleCaret;
          end;
        VK_DOWN:
          begin
            // ���������Ʋ����ֿɼ�
            CaretRow := CaretRow + 1;
            ScrollToVislbleCaret;
          end;
        VK_PRIOR:
          begin
            CaretRow := CaretRow - GetVisibleLineCount;
            ScrollToVislbleCaret;
          end;
        VK_NEXT:
          begin
            CaretRow := CaretRow + GetVisibleLineCount;
            ScrollToVislbleCaret;
          end;
        VK_HOME:
          begin
            if ssCtrl in Shift then // Ctrl ����ʱ�ص���������
              CaretRow := 1;

            CaretCol := 1; // �ص�����
            ScrollToVislbleCaret;
          end;
        VK_END:
          begin
            if ssCtrl in Shift then // Ctrl ����ʱ�ص�β��β��
              CaretRow := FMaxLineCount;

            CaretCol := GetLastColumnFromLine(FMaxLineCount); // �ص�β��
            ScrollToVislbleCaret;
          end;
      end;
    end
    else
    begin
      // TODO: ���� Shift�����ѡ�����յ�λ��
      if not FUseSelection then
        Exit;

      case Key of
        VK_LEFT:
          begin
            // ѡ�����յ������Ʋ����ֿɼ�
            SelectEndCol := SelectEndCol - 1;
            ScrollToVislbleCaret;
          end;
        VK_RIGHT:
          begin
            // ѡ�����յ������Ʋ����ֿɼ�
            SelectEndCol := SelectEndCol + 1;
            ScrollToVislbleCaret;
          end;
        VK_UP:
          begin
            // ѡ�����յ������Ʋ����ֿɼ�
            SelectEndRow := SelectEndRow - 1;
            ScrollToVislbleCaret;
          end;
        VK_DOWN:
          begin
            // ѡ�����յ������Ʋ����ֿɼ�
            SelectEndRow := SelectEndRow + 1;
            ScrollToVislbleCaret;
          end;
        VK_PRIOR:
          begin
            SelectEndRow := SelectEndRow - GetVisibleLineCount;
            ScrollToVislbleCaret;
          end;
        VK_NEXT:
          begin
            SelectEndRow := SelectEndRow + GetVisibleLineCount;
            ScrollToVislbleCaret;
          end;
        VK_HOME:
          begin
            if ssCtrl in Shift then // Ctrl ����ʱѡ����������
              SelectEndRow := 1;

            SelectEndCol := 1; // ѡ������
            ScrollToVislbleCaret;
          end;
        VK_END:
          begin
            if ssCtrl in Shift then // Ctrl ����ʱѡ��β��β��
              SelectEndRow := FMaxLineCount;

            SelectEndCol := GetLastColumnFromLine(FMaxLineCount); // ѡ��β��
            ScrollToVislbleCaret;
          end;
      end;
    end;
  end
  else // û�й�꣬�����ƶ��������򣬲����� Ctrl ���ļ�ͷβ�����
  begin
    case Key of
      VK_LEFT: ScrollLeftCol;
      VK_RIGHT: ScrollRightCol;
      VK_UP: ScrollUpLine;
      VK_DOWN: ScrollDownLine;
      VK_PRIOR: ScrollUpPage;
      VK_NEXT: ScrollDownPage;
      VK_HOME:
        begin
          Msg.ScrollCode := SB_THUMBTRACK;
          Msg.Pos := 0;
          WMHScroll(Msg);
        end;
      VK_END:
        begin
          Msg.ScrollCode := SB_THUMBTRACK;
          Msg.Pos := FMaxLineCount;
          WMHScroll(Msg);
        end;
    end;
  end;
end;

procedure TCnVirtualTextControl.KeyDown(var Key: WORD; Shift: TShiftState);
begin
  inherited;
  if Assigned(OnKeyDown) then
    OnKeyDown(Self, Key, Shift);

  case Key of
    VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END, VK_LEFT, VK_RIGHT:
      NavigationKey(Key, Shift);
  end;
end;

procedure TCnVirtualTextControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  inherited;
  if not Focused then
    Windows.SetFocus(Handle);

  UpdateCursorFrameCaret;

  if Button = mbLeft then
  begin
    FLeftMouseDown := True;
    FLeftMouseMoveAfterDown := False;
  end;
end;

procedure TCnVirtualTextControl.Paint;
var
  TR, LR: TRect;
  LC: TColor;
  I, V: Integer;
begin
  // �Ȼ��к���
  TR := ClientRect;
  LR := ClientRect;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(TR);

  TR.Left := GetTextRectLeft;
  TR.Top := COMMON_MARGIN;
  V := VisibleLineCount;

  if FShowLineNumber then // �����к����ĵ�ɫ������Ĭ�ϵ��кŻ���
  begin
    if Focused then
      LC := FLineNumFocusBkColor
    else
      LC := FLineNumNoFocusBkColor;

    // �к������Ϊ Margin + LineNumWidth + Margin
    // ������������ Left Ϊ Margin��Width Ϊ LineNumWidth + Margin

    LR.Right := LEFT_MARGIN + FLineNumWidth + LEFT_MARGIN + SEP_WIDTH;  // SEP_WIDTH �ǻ��߿��

    Canvas.Brush.Color := LC;
    Canvas.FillRect(LR);

    Inc(LR.Left, LEFT_MARGIN);
    Inc(LR.Top, COMMON_MARGIN);

    Canvas.Pen.Color := clGray;
    Dec(LR.Right);
    Canvas.MoveTo(LR.Right, 0);
    Canvas.LineTo(LR.Right, ClientHeight);
    Canvas.Pen.Color := clWhite;
    Dec(LR.Right);
    Canvas.MoveTo(LR.Right, 0);
    Canvas.LineTo(LR.Right, ClientHeight);
    Canvas.Pen.Color := clSilver;
    Dec(LR.Right);
    Canvas.MoveTo(LR.Right, 0);
    Canvas.LineTo(LR.Right, ClientHeight);

    LR.Bottom := COMMON_MARGIN + FLineHeight;

    Canvas.Font.Color := FLineNumColor;
    Canvas.Brush.Style := bsClear;

    for I := 1 to V do
    begin
      if I + FVertOffset <= FMaxLineCount then
        DoPaintLineNum(I, GetPaintLineNumber(I + FVertOffset), LR);

      Inc(LR.Top, FLineHeight);
      Inc(LR.Bottom, FLineHeight);
    end;
  end;

  TR.Bottom := TR.Top + FLineHeight;
  Canvas.Pen.Color := Canvas.Font.Color;
  Canvas.Brush.Style := bsClear;

  for I := 1 to V do
  begin
    DoPaintLine(I, I + FVertOffset, FHoriOffset, TR);
    Inc(TR.Top, FLineHeight);
    Inc(TR.Bottom, FLineHeight);
  end;
end;

function TCnVirtualTextControl.ScreenLineNumberToLineNumber(
  ScreenLineNumber: Integer): Integer;
begin
  Result := ScreenLineNumber + FVertOffset;
end;

procedure TCnVirtualTextControl.SetLineNumColor(const Value: TColor);
begin
  if FLineNumColor <> Value then
  begin
    FLineNumColor := Value;
    Invalidate;
  end;
end;

procedure TCnVirtualTextControl.SetLineNumFocusBkColor(const Value: TColor);
begin
  if FLineNumFocusBkColor <> Value then
  begin
    FLineNumFocusBkColor := Value;
    Invalidate;
  end;
end;

procedure TCnVirtualTextControl.SetLineNumNoFocusBkColor(const Value: TColor);
begin
  if FLineNumNoFocusBkColor <> Value then
  begin
    FLineNumNoFocusBkColor := Value;
    Invalidate;
  end;
end;

procedure TCnVirtualTextControl.SetMaxLineCount(const Value: Integer);
var
  Old: Integer;
begin
  if FMaxLineCount <> Value then
  begin
    FMaxLineCount := Value;

    Old := FLineNumCount;
    FLineNumCount := GetNumWidth(Value);
    FLineNumPattern := StringOfChar('0', FLineNumCount);

    if FLineNumCount <> Old then // λ�������仯�����¼��� FLineNumWidth
    begin
      CalcMetrics;
      UpdateRects;
    end;
    Invalidate;
  end;
end;

procedure TCnVirtualTextControl.SetShowLineNumber(const Value: Boolean);
begin
  if FShowLineNumber <> Value then
  begin
    FShowLineNumber := Value;
    UpdateRects;
    Invalidate;
  end;
end;

procedure TCnVirtualTextControl.UpdateScrollBars;
var
  SI: TScrollInfo;
begin
  if not HandleAllocated then
    Exit;

  SI.cbSize := SizeOf(TScrollInfo);
  SI.fMask := SIF_RANGE or SIF_POS or SIF_PAGE;
  SI.nMin := 0;

  // ���������
  FVertExp := 0;
  SI.nMax := FMaxLineCount - 1;       // nMax ���������
  while SI.nMax > MAX_NO_EXP_LINES do // �к�̫��ʱ��ָ����ʽ����������̫ϸ
  begin
    SI.nMax := SI.nMax div 2;
    Inc(FVertExp);
  end;

  SI.nPage := VisibleLineCount shr FVertExp; // nPage ��һ�����ݶ�Ӧ�ĸ߶�
  SI.nPos := FVertOffset shr FVertExp;
  SetScrollInfo(Handle, SB_VERT, SI, True);

  // ���������
  SI.nMax := 255;                            // ��֪�����д�� 256 ��
  SI.nPage := ClientWidth div FCharWidth;    // nPage ��һ�����ݶ�Ӧ���ַ����
  SI.nPos := FHoriOffset;
  SetScrollInfo(Handle, SB_HORZ, SI, True);
end;

procedure TCnVirtualTextControl.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS;
end;

procedure TCnVirtualTextControl.WMHScroll(var message: TWMScroll);
var
  SI: TScrollInfo;
  Old: Integer;
begin
  SI.cbSize := SizeOf(TScrollInfo);
  SI.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  GetScrollInfo(Handle, SB_HORZ, SI);

  Old := FHoriOffset;
  case message.ScrollCode of
    SB_PAGEUP: Dec(FHoriOffset, (FTextRect.Right - FTextRect.Left) div FCharWidth);  // ����һ���Ŀ��
    SB_PAGEDOWN: Inc(FHoriOffset, (FTextRect.Right - FTextRect.Left) div FCharWidth);
    SB_LINEUP: Dec(FHoriOffset);
    SB_LINEDOWN: Inc(FHoriOffset);
    SB_THUMBTRACK: FHoriOffset := message.Pos;
  end;

  if FHoriOffset > SI.nMax - (FTextRect.Right - FTextRect.Left) div FCharWidth then
    FHoriOffset := SI.nMax - (FTextRect.Right - FTextRect.Left) div FCharWidth;

  if FHoriOffset < 0 then
    FHoriOffset := 0;

  if FHoriOffset = Old then
    Exit;

  SI.nPos := FHoriOffset;
  SetScrollInfo(Handle, SB_HORZ, SI, True);
  Refresh;

  DoScroll;
end;

procedure TCnVirtualTextControl.WMKillFocus(var message: TWMSetFocus);
begin
  inherited;
  DestroyCaret;
  FCaretVisible := False;

  Invalidate;
end;

procedure TCnVirtualTextControl.WMMouseWheel(var message: TWMMouseWheel);
var
  I: Integer;
  R: TRect;
begin
  // ע�����ʱ FCaretRow �� FCaretCol ���䣬���ҿ����ܵ� TextRect ��ͷȥ
  if GetKeyState(VK_CONTROL) < 0 then
  begin
    FIsWheeling := True;
    try
      if message.WheelDelta > 0 then
        ScrollUpPage
      else
        ScrollDownPage;
    finally
      FIsWheeling := False;
    end;
  end
  else
  begin
    FIsWheeling := True;
    try
      if message.WheelDelta > 0 then
      begin
        for I := 0 to FWheelLinesCount - 1 do
          ScrollUpLine;
      end
      else
      begin
        for I := 0 to FWheelLinesCount - 1 do
          ScrollDownLine;
      end;
    finally
      FIsWheeling := False;
    end;
  end;

  // ����ʱ������һ�㲻��������������ᶯ
  FScreenCaretRow := LineNumberToScreenLineNumber(FCaretRow);
  FScreenCaretCol := ColNumberToScreenColNumber(FCaretCol);
  GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
  SetCaretPos(R.Left, R.Top);

  SyncSelectionStartEnd;
end;

procedure TCnVirtualTextControl.WMSetFocus(var message: TWMSetFocus);
begin
  inherited;

  if FCharFrameSize.y <= 0 then
    CalcMetrics;

  if FUseCaret then
  begin
    CreateCaret(Handle, HBITMAP(0), 2, FCharFrameSize.y);
    SetCaretBlinkTime(GetCaretBlinkTime);

    DisplayCaret(True);
  end;

  Invalidate;
end;

procedure TCnVirtualTextControl.WMSetFont(var message: TMessage);
begin
  inherited;
  Canvas.Font := Font;

  CalcMetrics;
  UpdateRects;
  UpdateScrollbars;
end;

procedure TCnVirtualTextControl.WMSize(var message: TWMSize);
begin
  inherited;
  UpdateRects;
  UpdateScrollBars;
end;

procedure TCnVirtualTextControl.WMVScroll(var message: TWMScroll);
var
  SI: TScrollInfo;
  Old, VL: Integer;
begin
  VL := VisibleLineCount;
  SI.cbSize := SizeOf(TScrollInfo);
  SI.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  GetScrollInfo(Handle, SB_VERT, SI);

  Old := FVertOffset;
  case message.ScrollCode of
    SB_PAGEUP: Dec(FVertOffset, VL);
    SB_PAGEDOWN: Inc(FVertOffset, VL);
    SB_LINEUP: Dec(FVertOffset);
    SB_LINEDOWN: Inc(FVertOffset);
    SB_THUMBTRACK: FVertOffset := message.Pos shl FVertExp;
  end;

  if FVertOffset > FMaxLineCount - VL then
    FVertOffset := FMaxLineCount - VL;
  if FVertOffset < 0 then
    FVertOffset := 0;

  if FVertOffset = Old then
    Exit;

  SI.nPos := FVertOffset shr FVertExp;
  SetScrollInfo(Handle, SB_VERT, SI, True);

  Refresh;
  DoScroll;
end;

procedure TCnVirtualTextControl.SetUseCaret(const Value: Boolean);
begin
  if FUseCaret <> Value then
  begin
    FUseCaret := Value;
    if FUseCaret then   // ֻ����
    begin
      if HandleAllocated then
      begin
        CreateCaret(Handle, HBITMAP(0), 2, FCharFrameSize.y - 2);
        SetCaretBlinkTime(GetCaretBlinkTime);

        DisplayCaret(Focused);
      end;
    end
    else
    begin
      DisplayCaret(False);
      DestroyCaret;
    end;
  end;
end;

procedure TCnVirtualTextControl.DisplayCaret(CaretVisible: Boolean);
var
  R: TRect;
begin
  if CaretVisible and Focused then
  begin
    if HandleAllocated then
    begin
      ShowCaret(Handle);
      FCaretVisible := True;

      GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
      SetCaretPos(R.Left, R.Top);
    end;
  end
  else if not CaretVisible then
  begin
    HideCaret(Handle);
    FCaretVisible := False;
  end;
end;

procedure TCnVirtualTextControl.UpdateCursorFrameCaret;
var
  P: TPoint;
  R: TRect;
begin
  P := ScreenToClient(Mouse.CursorPos);
  if CalcRowCol(P, FCharFrameRow, FCharFrameCol, FScreenCaretRow, FScreenCaretCol,
    FCaretRow, FCaretCol, FCharFrameIsLeft) then
  begin
    // ���ù��λ��
    GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
    SetCaretPos(R.Left, R.Top);
    SyncSelectionStartEnd;
    DoCaretChange;
  end;
end;

function TCnVirtualTextControl.ScreenColNumberToColNumber(
  ScreenColNumber: Integer): Integer;
begin
  Result := ScreenColNumber + FHoriOffset;
end;

procedure TCnVirtualTextControl.SetCaretCol(const Value: Integer);
var
  R: TRect;
begin
  FCaretCol := Value;

  // ���� FCaretRow �ж� FCaretCol �Ƿ񳬳���β
  // ������������������� FCaretCol
  LimitRowColumnInLine(FCaretRow, FCaretCol);

  // ͬ������ ScreenCaretCol �� ScreenCaretRow
  FScreenCaretCol := ColNumberToScreenColNumber(FCaretCol);
  FScreenCaretRow := LineNumberToScreenLineNumber(FCaretRow);

  if FUseCaret then
  begin
    GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
    SetCaretPos(R.Left, R.Top);
    SyncSelectionStartEnd;
    DoCaretChange;
  end;
end;

procedure TCnVirtualTextControl.SetCaretRow(const Value: Integer);
var
  R: TRect;
begin
  FCaretRow := Value;

  // ���� FCaretRow �ж� FCaretRow �Ƿ���� FMaxLineCount ���� FCaretCol �Ƿ񳬳���β
  // ������������������� FCaretCol
  LimitRowColumnInLine(FCaretRow, FCaretCol);

  FScreenCaretCol := ColNumberToScreenColNumber(FCaretCol);
  FScreenCaretRow := LineNumberToScreenLineNumber(FCaretRow);

  // ͬ������ ScreenCaretCol �� ScreenCaretRow
  if FUseCaret then
  begin
    GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
    SetCaretPos(R.Left, R.Top);
    SyncSelectionStartEnd;
    DoCaretChange;
  end;
end;

procedure TCnVirtualTextControl.UpdateRects;
begin
  if not HandleAllocated then
    Exit;

  FTextRect.Left := GetTextRectLeft;
  FTextRect.Top := COMMON_MARGIN;
  FTextRect.Bottom := ClientRect.Bottom - COMMON_MARGIN;
  FTextRect.Right := ClientRect.Right - COMMON_MARGIN;

  FGutterRect.Top := COMMON_MARGIN;
  FGutterRect.Bottom := COMMON_MARGIN;
  if ShowLineNumber then
  begin
    FGutterRect.Left := LEFT_MARGIN;
    FGutterRect.Right := LEFT_MARGIN + FLineNumWidth + COMMON_MARGIN;
  end
  else
  begin
    FGutterRect.Left := 0;
    FGutterRect.Right := 0;
  end;
end;

function TCnVirtualTextControl.GetScreenBottomLine: Integer;
begin
  Result := GetBottomLine - GetTopLine + 1;
end;

function TCnVirtualTextControl.ColNumberToScreenColNumber(
  ColNumber: Integer): Integer;
begin
  Result := ColNumber - FHoriOffset;
end;

function TCnVirtualTextControl.LineNumberToScreenLineNumber(
  LineNumber: Integer): Integer;
begin
  Result := LineNumber - FVertOffset;
end;

procedure TCnVirtualTextControl.DoCaretChange;
begin
  if Assigned(FOnCaretChange) then
    FOnCaretChange(Self);
end;

procedure TCnVirtualTextControl.SetCaretAfterLineEnd(const Value: Boolean);
var
  R: TRect;
begin
  if FCaretAfterLineEnd <> Value then
  begin
    FCaretAfterLineEnd := Value;

    LimitRowColumnInLine(FCaretRow, FCaretCol);

    // ��ͬ��ת�� ScreenCaretRow/Col
    FScreenCaretRow := LineNumberToScreenLineNumber(FCaretRow);
    FScreenCaretCol := ColNumberToScreenColNumber(FCaretCol);

    // ���ù��λ��
    if FUseCaret then
    begin
      GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
      SetCaretPos(R.Left, R.Top);
      SyncSelectionStartEnd;
      DoCaretChange;
    end;
    Invalidate;
  end;
end;

procedure TCnVirtualTextControl.LimitRowColumnInLine(var LineNumber, Column: Integer);
var
  C: Integer;
begin
  if LineNumber <= 0 then
    LineNumber := 1;

  if LineNumber > FMaxLineCount then
    LineNumber := FMaxLineCount;

  if Column <= 0 then
    Column := 1;

  if not CaretAfterLineEnd then
  begin
    C := GetLastColumnFromLine(LineNumber);
    if C < Column then
      Column := C;
  end;
end;

procedure TCnVirtualTextControl.SetSelectEndCol(const Value: Integer);
begin
  if FSelectEndCol <> Value then
  begin
    FSelectEndCol := Value;
    LimitRowColumnInLine(FSelectEndRow, FSelectEndCol);
    SetCaretRowCol(FSelectEndRow, FSelectEndCol);
    Invalidate;
    DoSelectChange;
  end;
end;

procedure TCnVirtualTextControl.SetSelectEndRow(const Value: Integer);
begin
  if FSelectEndRow <> Value then
  begin
    FSelectEndRow := Value;
    LimitRowColumnInLine(FSelectEndRow, FSelectEndCol);
    SetCaretRowCol(FSelectEndRow, FSelectEndCol);
    Invalidate;
    DoSelectChange;
  end;
end;

procedure TCnVirtualTextControl.SetSelectStartCol(const Value: Integer);
begin
  if FSelectStartCol <> Value then
  begin
    FSelectStartCol := Value;
    LimitRowColumnInLine(FSelectStartRow, FSelectStartCol);
    Invalidate;
    DoSelectChange;
  end;
end;

procedure TCnVirtualTextControl.SetSelectStartRow(const Value: Integer);
begin
  if FSelectStartRow <> Value then
  begin
    FSelectStartRow := Value;
    LimitRowColumnInLine(FSelectStartRow, FSelectStartCol);
    Invalidate;
    DoSelectChange;
  end;
end;

procedure TCnVirtualTextControl.MouseMove(Shift: TShiftState; X,
  Y: Integer);
var
  P: TPoint;
  TR: TRect;
begin
  inherited;

  if FLeftMouseDown then
  begin
    if FUseSelection then     // ����϶�ʱ���֧��ѡ�����������ѡ����β
    begin
      if not FLeftMouseMoveAfterDown then // �����϶��� MouseDown ����״� Move
      begin
        // TODO: �ж��Ƿ���ѡ�������ٴ��϶��������������ק�����ڼ򵥵�ȡ��ѡ��׼���ٴ�ѡ��
        SyncSelectionStartEnd(True);
      end;

      FLeftMouseMoveAfterDown := True;
      P.x := X;
      P.y := Y;

      // �϶����˱�Ե���ȹ���һ���������� SetCapture
      TR := GetTextRect;
      if P.x < TR.Left then
        ScrollLeftCol
      else if P.x > TR.Right then
        ScrollRightCol;

      if P.y < TR.Top then
        ScrollUpLine
      else if P.y > TR.Bottom then
        ScrollDownLine;

      CalcSelectEnd(P); // Ȼ��������������ε�ѡ����
      SetCaretRowCol(FSelectEndRow, FSelectEndCol); // ͬʱҲ�ƶ����
    end
    else
      UpdateCursorFrameCaret; // ����϶�ʱ�����֧��ѡ��������Ҳ�ƶ����
  end;
end;

procedure TCnVirtualTextControl.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if Button = mbLeft then
  begin
    FLeftMouseDown := False;
    if FUseSelection then  // ������̧��ʱ��Ҫͨ��ʲô����ȡ����ǰѡ����������δ�϶�
    begin
      if not FLeftMouseMoveAfterDown then // �϶�����ɶ��������δ�϶�����ȡ��ѡ��
      begin
        SyncSelectionStartEnd(True);
        DoSelectChange;
      end;
    end;
  end;
end;

procedure TCnVirtualTextControl.MoveCaretToVisible;
var
  M: Boolean;
  R, C: Integer;
begin
  M := False;
  R := FCaretRow;
  C := FCaretCol;

  if FCaretRow < GetTopLine then
  begin
    M := True;
    R := GetTopLine;
  end
  else if FCaretRow > GetBottomLine then
  begin
    M := True;
    R := GetBottomLine;
  end
  else if FCaretCol < GetLeftColumn then
  begin
    M := True;
    C := GetLeftColumn;
  end
  else if FCaretCol > GetRightColumn then
  begin
    M := True;
    C := GetRightColumn;
  end;

  if M then
  begin
    SetCaretRowCol(R, C);
    Invalidate;
  end;
end;

function TCnVirtualTextControl.GetLeftColumn: Integer;
begin
  Result := FHoriOffset + 1;
end;

function TCnVirtualTextControl.GetRightColumn: Integer;
begin
  Result := ((FTextRect.Right - FTextRect.Left) div FCharFrameSize.x)
    + FHoriOffset + 1;
end;

procedure TCnVirtualTextControl.SetCaretRowCol(Row, Col: Integer);
var
  R: TRect;
begin
  FCaretRow := Row;
  FCaretCol := Col;

  // ���� FCaretRow �ж� FCaretCol �Ƿ񳬳���β
  // ������������������� FCaretCol
  LimitRowColumnInLine(FCaretRow, FCaretCol);

  // ͬ������ ScreenCaretCol �� ScreenCaretRow
  FScreenCaretCol := ColNumberToScreenColNumber(FCaretCol);
  FScreenCaretRow := LineNumberToScreenLineNumber(FCaretRow);

  if FUseCaret then
  begin
    GetScreenCharPosRect(FScreenCaretRow, FScreenCaretCol, R);
    SetCaretPos(R.Left, R.Top);
    SyncSelectionStartEnd;
    DoCaretChange;
  end;
end;

procedure TCnVirtualTextControl.ScrollToVislbleCaret;
var
  M: Boolean;
begin
  M := False;
  if FCaretRow < GetTopLine then
  begin
    Dec(FVertOffset, GetTopLine - FCaretRow);
    CaretRow := GetTopLine;
    M := True;
  end
  else if FCaretRow > GetBottomLine then
  begin
    Inc(FVertOffset, FCaretRow - GetBottomLine);
    CaretRow := GetBottomLine;
    M := True;
  end
  else if FCaretCol < GetLeftColumn then
  begin
    Dec(FHoriOffset, GetLeftColumn - FCaretCol);
    CaretCol := GetLeftColumn;
    M := True;
  end
  else if FCaretCol > GetRightColumn then
  begin
    Inc(FHoriOffset, FCaretCol - GetRightColumn);
    CaretCol := GetRightColumn;
    M := True;
  end;

  if M then
  begin
    Invalidate;
    UpdateScrollBars;
    DoScroll;
  end;
end;

procedure TCnVirtualTextControl.SetUseSelection(const Value: Boolean);
begin
  FUseSelection := Value;
end;

function TCnVirtualTextControl.HasSelection: Boolean;
begin
  Result := (FSelectStartRow <> FSelectEndRow) or (FSelectStartCol <> FSelectEndCol);
end;

procedure TCnVirtualTextControl.SyncSelectionStartEnd(Force: Boolean);
begin
  if FUseSelection and (Force or not HasSelection) then
  begin
    FSelectStartRow := FCaretRow;
    FSelectEndRow := FCaretRow;
    FSelectStartCol := FCaretCol;
    FSelectEndCol := FCaretCol;
  end;
end;

function TCnVirtualTextControl.CalcRowCol(Pt: TPoint; out ACharFrameRow,
  ACharFrameCol, AScreenCaretRow, AScreenCaretCol, ACaretRow, ACaretCol: Integer;
  out ACharFrameIsLeft: Boolean): Boolean;
begin
  Result := ClientPosToCharPos(Pt, ACharFrameRow, ACharFrameCol, ACharFrameIsLeft);
  if Result then
  begin
    AScreenCaretRow := ACharFrameRow;
    if ACharFrameIsLeft then
      AScreenCaretCol := ACharFrameCol
    else
      AScreenCaretCol := ACharFrameCol + 1;

    // ת�������� CaretRow/Col
    ACaretRow := ScreenLineNumberToLineNumber(AScreenCaretRow);
    ACaretCol := ScreenColNumberToColNumber(AScreenCaretCol);

    // ͨ������ Row/Col �ж�����
    LimitRowColumnInLine(ACaretRow, ACaretCol);

    // ��ͬ��ת�� ScreenCaretRow/Col
    AScreenCaretRow := LineNumberToScreenLineNumber(ACaretRow);
    AScreenCaretCol := ColNumberToScreenColNumber(ACaretCol);
  end;
end;

procedure TCnVirtualTextControl.DoSelectChange;
begin
  if Assigned(FOnSelectChange) then
    FOnSelectChange(Self);
end;

procedure TCnVirtualTextControl.CalcSelectEnd(Pt: TPoint);
var
  ACharFrameRow, ACharFrameCol: Integer;
  AScreenCaretRow, AScreenCaretCol: Integer;
  ACaretRow, ACaretCol: Integer;
  OldSelEndRow, OldSelEndCol: Integer;
  ACharFrameIsLeft: Boolean;
begin
  // �����϶�ѡ��ע�� Down ʱ�Ѿ�ȷ������ѡ����ʼ��
  OldSelEndRow := FSelectEndRow;
  OldSelEndCol := FSelectEndCol;

  if CalcRowCol(Pt, ACharFrameRow, ACharFrameCol, AScreenCaretRow,
    AScreenCaretCol, ACaretRow, ACaretCol, ACharFrameIsLeft) then
  begin
    // ������������ڻ��������������к���
    FSelectEndRow := ACaretRow;
    FSelectEndCol := ACaretCol;

    LimitRowColumnInLine(FSelectEndRow, FSelectEndCol); // ���Ʊ����ϳ���Χ

    if (FSelectEndRow <> OldSelEndRow) or (FSelectEndCol <> OldSelEndCol) then
    begin
      Invalidate;
      DoSelectChange;
    end;
  end;
end;

procedure TCnVirtualTextControl.SetOnSelectChange(
  const Value: TNotifyEvent);
begin
  FOnSelectChange := Value;
end;

procedure TCnVirtualTextControl.ScrollDownLine;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_LINEDOWN;
  WMVScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollDownPage;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_PAGEDOWN;
  WMVScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollLeftCol;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_LINELEFT;
  WMHScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollLeftPage;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_PAGELEFT;
  WMHScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollRightCol;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_LINERIGHT;
  WMHScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollRightPage;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_PAGERIGHT;
  WMHScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollUpLine;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_LINEUP;
  WMVScroll(Msg);
end;

procedure TCnVirtualTextControl.ScrollUpPage;
var
  Msg: TWMScroll;
begin
  Msg.ScrollCode := SB_PAGEUP;
  WMVScroll(Msg);
end;

end.
