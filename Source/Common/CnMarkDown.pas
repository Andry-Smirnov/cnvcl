{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
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
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnMarkDown;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�MarkDown ��ʽ������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���﷨֧�ֲ�������Ʃ��û�б�񣬲�֧��Ƕ���б��
*           Parser �ܹ�ʵ�� MarkDown �Ĵʷ�������CnParseMarkDownString ���ܽ�
*           MarkDown �ı������� DOM ����������������ṹ����һ���Ƕ��䡢�ڶ��������֡�
*           ���� DOM ��δ����������� HTML �� RTF��
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.03.06 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Contnrs, TypInfo, CnStrings;

type
  TCnMarkDownTokenType = (cmtUnknown,
  {* MarkDown �ļ��﷨����֧�ֱ��}
    cmtHeading1,       // ����#�ո�
    cmtHeading2,       // ����##�ո�
    cmtHeading3,       // ����###�ո�
    cmtHeading4,       // ����####�ո�
    cmtHeading5,       // ����#####�ո�
    cmtHeading6,       // ����######�ո�
    cmtHeading7,       // ����#######�ո�
    cmtUnOrderedList,  // ����*+-֮һ�ӿո�
    cmtOrderedList,    // ��������.�ӿո�
    cmtIndent,         // �����ĸ��ո��һ��Tab
    cmtLine,           // ����***��---��___��β
    cmtQuota,          // ����>�ո�
    cmtFenceCodeBlock, // ����```
    cmtHardBreak,      // ���ո���β�س�
    cmtCodeBlock,      // `
    cmtBold,           // ** �� __
    cmtItalic,         // * �� _
    cmtBoldItalic,     // *** �� ___
    cmtStroke,         // ~~
    cmtLinkDisplay,    // [
    cmtLink,           // (
    cmtDirectLink,     // <
    cmtImageSign,      // !
    cmtContent,        // ����
    cmtSpace,          // �ո�
    cmtLineBreak,      // �س�����
    cmtTerminate       // ������
  );
  TCnMarkDownTokenTypes = set of TCnMarkDownTokenType;

  TCnMarkDownBookmark = packed record
  {* �������е���ǩ����Ϊ������}
    Run: Integer;
    TokenPos: Integer;
    IsLineStart: Boolean;
    TokenID: TCnMarkDownTokenType;
  end;

  TCnMarkDownParser = class
  {* String ��ʽ�� MarkDown �ַ����﷨������}
  private
    FRun: Integer;
    FTokenPos: Integer;
    FOrigin: PChar;
    FIsLineStart: Boolean;
    FTokenID: TCnMarkDownTokenType;

    procedure SharpHeaderProc;     // #     ���ױ���
    procedure NumberHeaderProc;    // ����  ���������б�
    procedure GreaterHeaderProc;   // >     ��������
    procedure PlusHeaderProc;      // +     ������պ���
    procedure MinusHeaderProc;     // -     ������պ���
    procedure TabHeaderProc;       // Tab   ��������
    procedure UnderLineProc;       // _     ������պ��ߣ����б��
    procedure SpaceProc;           // �ո�  �ĸ����������ӻس�
    procedure SquareProc;          // [��]֮����������ʾ
    procedure LessProc;            // <��>֮����ֱ������
    procedure BraceProc;           // (��)֮����������ת����
    procedure ExclamationProc;     // !��[��ͼ��
    procedure StarProc;            // * ��պ��߻��б��
    procedure WaveProc;            // ~ ��ɾ����
    procedure QuotaProc;           // `
    procedure LineBreakProc;       // ��ͨ�Ļس�����
    procedure TerminateProc; // #0

    function GetToken: string;
    procedure SetOrigin(const Value: PChar);
    function GetTokenLength: Integer;
  protected
    procedure StepRun; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  public
    constructor Create; virtual;
    {* ���캯��}
    destructor Destroy; override;
    {* ��������}

    procedure Next;
    {* ������һ�� Token ��ȷ�� TokenID}

    procedure SaveToBookmark(var Bookmark: TCnMarkDownBookmark);
    procedure LoadFromBookmark(var Bookmark: TCnMarkDownBookmark);

    property Origin: PAnsiChar read FOrigin write SetOrigin;
    {* �������� string ��ʽ�� MarkDown �ַ�������}
    property RunPos: Integer read FRun;
    {* ��ǰ����λ������� FOrigin ������ƫ��������λΪ�ֽ�����0 ��ʼ}
    property TokenID: TCnMarkDownTokenType read FTokenID;
    {* ��ǰ Token ����}
    property Token: string read GetToken;
    {* ��ǰ Token ��ԭʼ�ַ������ݲ�����ת������}
    property TokenLength: Integer read GetTokenLength;
    {* ��ǰ Token ���ֽڳ���}
  end;

  TCnMarkDownParagraphType = (cmpUnknown, cmpHeading1, cmpHeading2, cmpHeading3,
    cmpHeading4, cmpHeading5, cmpHeading6, cmpHeading7, cmpCommon, cmpPre, cmpLine,
    cmpFenceCodeBlock, cmpOrderedList, cmpUnorderedList, cmpQuota, cmpEmpty);
  {* ��������}

  TCnMarkDownTextFragmentType = (cmfUnknown, cmfCommon, cmfBold, cmfItalic,
    cmfBoldItalic, cmfStroke, cmfCodeBlock, cmfLink, cmfLinkDisplay, cmfImage, cmfDirectLink);
  {* �ı�����}
  TCnMarkDownTextFragmentTypes = set of TCnMarkDownTextFragmentType;

  TCnMarkDownTextBraceType = (cmtbNone, cmtbBold, cmtbItalic, cmtbBoldItalic, cmtbStroke,
    cmtbCodeBlock);
  {* �ı�����Ҫ��Ե�����}

  TCnMarkDownBase = class
  {* �ķ����ڵ�Ļ���}
  private
    FItems: TObjectList;
    FParent: TCnMarkDownBase;
    function GetItem(Index: Integer): TCnMarkDownBase;
    procedure SetItem(Index: Integer; const Value: TCnMarkDownBase);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Add(AMarkDown: TCnMarkDownBase): TCnmarkDownBase;
    procedure Delete(Index: Integer);

    property Parent: TCnMarkDownBase read FParent write FParent;
    property Items[Index: Integer]: TCnMarkDownBase read GetItem write SetItem; default;
    property Count: Integer read GetCount;
  end;

  TCnMarkDownParagraph = class(TCnMarkDownBase)
  {* �������}
  private
    FParagraphType: TCnMarkDownParagraphType;
    FCloseType: TCnMarkDownTextBraceType;
    FOpenType: TCnMarkDownTextBraceType;
  public
    property OpenType: TCnMarkDownTextBraceType read FOpenType write FOpenType;
    property CloseType: TCnMarkDownTextBraceType read FCloseType write FCloseType;

    property ParagraphType: TCnMarkDownParagraphType read FParagraphType write FParagraphType;
  end;

  TCnMarkDownTextFragment = class(TCnMarkDownBase)
  {* ����������ֿ�}
  private
    FContent: string;
    FFragmentType: TCnMarkDownTextFragmentType;
    FCloseType: TCnMarkDownTextBraceType;
    FOpenType: TCnMarkDownTextBraceType;
    function GetContent: string;
  public
    procedure AddContent(const Cont: string);

    property OpenType: TCnMarkDownTextBraceType read FOpenType write FOpenType;
    property CloseType: TCnMarkDownTextBraceType read FCloseType write FCloseType;

    property FragmentType: TCnMarkDownTextFragmentType read FFragmentType write FFragmentType;
    property Content: string read GetContent;
  end;

  TCnMarkDownConverter = class
  {* ת�����������}
  protected
    function ConvertParagraphStart(Paragraph: TCnMarkDownParagraph): string; virtual; abstract;
    function ConvertParagraphEnd(Paragraph: TCnMarkDownParagraph): string; virtual; abstract;
    function ConvertFragment(Fragment: TCnMarkDownTextFragment): string; virtual; abstract;
    function EscapeContent(const Text: string): string; virtual; abstract;
  public
    function Convert(Root: TCnMarkDownBase): string; virtual; abstract;
  end;

  TCnRTFConverter = class(TCnMarkDownConverter)
  {* RTF ת����ʵ����}
  private
    FRtf: TCnStringBuilder;
    FCurrentFontSize: Integer;
    FListCounters: array[1..9] of Integer; // ֧����� 9 ���б�
    function GetListLevel(Paragraph: TCnMarkDownParagraph): Integer;
    function GetQuotaLevel(Paragraph: TCnMarkDownParagraph): Integer;
    {* ��ð������ڵ����ڵ����и��ڵ����е�����Ƕ������0 ��ʼ}
  protected
    function ConvertParagraphStart(Paragraph: TCnMarkDownParagraph): string; override;
    function ConvertParagraphEnd(Paragraph: TCnMarkDownParagraph): string; override;
    function ConvertFragment(Fragment: TCnMarkDownTextFragment): string; override;
    function EscapeContent(const Text: string): string; override;
    procedure ProcessNode(Node: TCnMarkDownBase);
  public
    constructor Create;
    destructor Destroy; override;
    function Convert(Root: TCnMarkDownBase): string; override;
  end;

function CnParseMarkDownString(const MarkDown: string): TCnMarkDownBase;
{* �� MarkDown �ַ�������Ϊ��״���󣬷��ض��������ⲿ����ʱ�ͷ�}

procedure CnMarkDownDebugOutput(MarkDown: TCnMarkDownBase; List: TStrings);
{* �� MarkDown ��������ӡ���ַ����б���}

function CnMarkDownConvertToRTF(Root: TCnMarkDownBase): string;
{* �� MarkDown �� DOM ������� RTF �ַ���}

//  RTF �����ʽ��{\pard [���Ʋ���] [�ı�����] \par}

implementation

const
  // ��Щ�������Ҫ��Ե�
  CN_MARKDOWN_FRAGMENTTYPE_NEED_MATCH: TCnMarkDownTextFragmentTypes =
    [cmfBold, cmfItalic, cmfBoldItalic, cmfStroke, cmfCodeBlock];

  // ������Щ��ǣ���ʹǰ��û�����������س����У�ҲҪ����һ��
  CN_MARKDOWN_TOKENTYPE_PARAHEAD: TCnMarkDownTokenTypes =
    [cmtHeading1,      // ����#�ո�
    cmtHeading2,       // ����##�ո�
    cmtHeading3,       // ����###�ո�
    cmtHeading4,       // ����####�ո�
    cmtHeading5,       // ����#####�ո�
    cmtHeading6,       // ����######�ո�
    cmtHeading7,       // ����#######�ո�
    cmtUnOrderedList,  // ����*+-֮һ�ӿո�
    cmtOrderedList,    // ��������.�ӿո�
    cmtIndent,         // �����ĸ��ո��һ��Tab
    cmtLine,           // ����***��---��___��β
    cmtQuota,          // ����>�ո�
    cmtFenceCodeBlock  // ����```
  ];

  CN_RTF_HEADER =
    '{\rtf1\ansi\ansicpg936\deff0' +            // �ĵ�ͷ+�������Ĵ���ҳ
    '{\fonttbl' +                               // �����ʼ
    '{\f0\fnil\fcharset134 SimSun;}' +          // �����壺���壨GB2312�ַ�����
    '{\f1\fnil\fcharset134 Microsoft YaHei;}' + // ��������1��΢���ź�
    '{\f2\fnil\fcharset134 KaiTi;}' +           // ��������2������
    '{\f3\fnil\fcharset134 Courier New;}' +     // �ȿ�����
    '}' +                                       // ��������
    '{\colortbl;' +
    '\red0\green0\blue0;' +
    '\red255\green0\blue0;' +
    '\red216\green216\blue216;}' +              // ��ɫ���ڡ��졢�ң�
    '\viewkind4\uc1' +                          // ��ͼģʽ+Unicode����
    '\pard' +
    '\lang2052\langfe2052\f0\fs24\qj';          // �����Ű�����+Ĭ������

  CN_RTF_FOOTER = '}';

  CN_QUOTA_INDENT = 720;    // ���õ�����
  CN_LIST_UNINDENT = -360;  // �б�ĵ����ŵķ�����
  CN_LIST_INDENT = 720;     // �б����ֵ�����

function IsBlank(const Str: string): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  I: Integer;
begin
  for I := 1 to Length(Str) do
  begin
    if Str[I] <> ' ' then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function IsCRLF(C: Char): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  Result := (C = #13) or (C = #10);
end;

function IsSpaceOrTab(C: Char): Boolean; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  Result := (C = ' ') or (C = #9);
end;

{ TCnMarkDownParser }

procedure TCnMarkDownParser.BraceProc;
begin
  StepRun;
  FTokenID := cmtLink;

  while not (FOrigin[FRun] in [')', #0]) do
    StepRun;

  if FOrigin[FRun] = ')' then
    StepRun;
end;

constructor TCnMarkDownParser.Create;
begin
  inherited;
end;

destructor TCnMarkDownParser.Destroy;
begin

  inherited;
end;

procedure TCnMarkDownParser.ExclamationProc;
begin
  StepRun;
  if FOrigin[FRun] = '[' then
    FTokenID := cmtImageSign
  else
    FTokenID := cmtContent;
end;

function TCnMarkDownParser.GetToken: string;
var
  Len: Cardinal;
  OutStr: string;
begin
  Len := FRun - FTokenPos;                         // ����ƫ����֮���λΪ�ַ���
  SetString(OutStr, (FOrigin + FTokenPos), Len);   // ��ָ���ڴ��ַ���ַ����ȹ����ַ���
  Result := OutStr;
end;

function TCnMarkDownParser.GetTokenLength: Integer;
begin
  Result := FRun - FTokenPos;
end;

procedure TCnMarkDownParser.GreaterHeaderProc;
begin
  StepRun;
  FTokenID := cmtContent;

  if IsSpaceOrTab(FOrigin[FRun]) then
  begin
    FTokenID := cmtQuota;
    StepRun;
    FIsLineStart := True; // ע�⣡���÷��ź����赱�����׽����������ݣ�����ֹ�����
  end;
end;

procedure TCnMarkDownParser.LessProc;
begin
  StepRun;
  FTokenID := cmtDirectLink;

  while not (FOrigin[FRun] in ['>', #0]) do
    StepRun;

  if FOrigin[FRun] = '>' then
    StepRun;
end;

procedure TCnMarkDownParser.LineBreakProc;
begin
  FTokenID := cmtContent;
  while FOrigin[FRun] = #13 do
    StepRun;

  if FOrigin[FRun] = #10 then
  begin
    FTokenID := cmtLineBreak;
    StepRun;
  end;
end;

procedure TCnMarkDownParser.LoadFromBookmark(var Bookmark: TCnMarkDownBookmark);
begin
  FRun := Bookmark.Run;
  FTokenPos := Bookmark.TokenPos;
  FIsLineStart := Bookmark.IsLineStart;
  FTokenID := Bookmark.TokenID;
end;

procedure TCnMarkDownParser.MinusHeaderProc;
begin
  StepRun;
  FTokenID := cmtContent;

  if FOrigin[FRun] = '-' then             // ����������һ���ָ���
  begin
    StepRun;
    if FOrigin[FRun] = '-' then
    begin
      StepRun;
      if IsCRLF(FOrigin[FRun]) then
      begin
        FTokenID := cmtLine;
        StepRun;
      end;
    end;
  end
  else if IsSpaceOrTab(FOrigin[FRun]) then // ���׵����������б�
  begin
    FTokenID := cmtUnOrderedList;
    StepRun;
  end;
end;

procedure TCnMarkDownParser.Next;

  // �ӵ�ǰ�ַ������ܵ������ַ�Ϊֹ��ע������ Ansi ���� Utf8 ���� Utf16 ��Ӧ��Ч
  procedure StepTo;
  begin
    repeat
      StepRun;

      if FIsLineStart then
      begin
        // ���׵Ļ�����Щ�ַ�Ҫ����
        if FOrigin[FRun] in ['#', '<', '>', '0'..'9', '+', '-', '(', '!',
          '_', '*', '`', '[', ' ', #9, #13, #10] then
          Exit;
      end
      else
      begin
        // �����׵Ļ�����Щ�ַ�Ҫ�����������ո�ҲҪ�ģ���Ϊ��Ч�ʣ���������
        if FOrigin[FRun] in ['<', '(', '*', '`', '~', '_', '!', '[', #13, #10] then
          Exit
        else if (FOrigin[FRun] = ' ') and (FOrigin[FRun + 1] = ' ') then
          Exit;
      end;
    until FOrigin[FRun] = #0;
  end;

begin
  FTokenPos := FRun;

  if FIsLineStart then
  begin
    // �����ж�������Ч
    case FOrigin[FRun] of
      '#':
        SharpHeaderProc;
      '>':
        GreaterHeaderProc;
      '0'..'9':
        NumberHeaderProc;
      '+':
        PlusHeaderProc;
      '-':
        MinusHeaderProc;
      '_':
        UnderLineProc;
      '*':
        StarProc;
      '`':
        QuotaProc;
      ' ':
        SpaceProc;
      #9:
        TabHeaderProc;
      #13, #10:
        LineBreakProc;
      #0:
        TerminateProc;
    else
      FTokenID := cmtContent;
      StepTo;
    end;
  end
  else // ���·�����Ҳ��Ч���ڲ�Ҫ�������׽����ж�
  begin
    case FOrigin[FRun] of
      '*':
        StarProc;
      '`':
        QuotaProc;
      '~':
        WaveProc;
      '[':
        SquareProc;
      '<':
        LessProc;
      '(':
        BraceProc;
      '!':
        ExclamationProc;
      '_':
        UnderLineProc;
      ' ':
        SpaceProc;
      #13, #10:
        LineBreakProc;
      #0:
        TerminateProc;
    else
      FTokenID := cmtContent;
      StepTo;
    end;
  end;
end;

procedure TCnMarkDownParser.NumberHeaderProc;
begin
  StepRun;
  FTokenID := cmtContent;

  if FOrigin[FRun] = '.' then
  begin
    StepRun;
    if IsSpaceOrTab(FOrigin[FRun]) then
    begin
      FTokenID := cmtOrderedList;
      StepRun;
    end;
  end
  else if FOrigin[FRun] in ['0'..'9'] then
  begin
    StepRun;
    if FOrigin[FRun] = '.' then
    begin
      StepRun;
      if IsSpaceOrTab(FOrigin[FRun]) then
      begin
        FTokenID := cmtOrderedList;
        StepRun;
      end;
    end;
  end;
end;

procedure TCnMarkDownParser.PlusHeaderProc;
begin
  StepRun;
  FTokenID := cmtContent;

  if FOrigin[FRun] = '+' then
  begin
    StepRun;
    if FOrigin[FRun] = '+' then
    begin
      StepRun;
      if IsCRLF(FOrigin[FRun]) then
      begin
        FTokenID := cmtLine;
        StepRun;
      end;
    end;
  end;
end;

procedure TCnMarkDownParser.QuotaProc;
var
  IsLS: Boolean;
begin
  IsLS := FIsLineStart;
  StepRun;

  if IsLS then
  begin
    FTokenID := cmtContent;

    if FOrigin[FRun] = '`' then
    begin
      StepRun;
      if FOrigin[FRun] = '`' then
      begin
        FTokenID := cmtQuota;
        StepRun;
      end;
    end;
  end
  else
  begin
    FTokenID := cmtCodeBlock;
  end;
end;

procedure TCnMarkDownParser.SaveToBookmark(var Bookmark: TCnMarkDownBookmark);
begin
  Bookmark.Run := FRun;
  Bookmark.TokenPos := FTokenPos;
  Bookmark.IsLineStart := FIsLineStart;
  Bookmark.TokenID := FTokenID;
end;

procedure TCnMarkDownParser.SetOrigin(const Value: PChar);
begin
  FOrigin := Value;
  FRun := 0;
  FIsLineStart := True;
  Next;
end;

procedure TCnMarkDownParser.SharpHeaderProc;
begin
  StepRun;
  FTokenID := cmtContent;

  if IsSpaceOrTab(FOrigin[FRun]) then
  begin
    FTokenID := cmtHeading1;
    StepRun;
  end
  else if FOrigin[FRun] = '#' then
  begin
    StepRun;
    if IsSpaceOrTab(FOrigin[FRun]) then
    begin
      FTokenID := cmtHeading2;
      StepRun;
    end
    else if FOrigin[FRun] = '#' then
    begin
      StepRun;
      if IsSpaceOrTab(FOrigin[FRun]) then
      begin
        FTokenID := cmtHeading3;
        StepRun;
      end
      else if FOrigin[FRun] = '#' then
      begin
        StepRun;
        if IsSpaceOrTab(FOrigin[FRun]) then
        begin
          FTokenID := cmtHeading4;
          StepRun;
        end
        else if FOrigin[FRun] = '#' then
        begin
          StepRun;
          if IsSpaceOrTab(FOrigin[FRun]) then
          begin
            FTokenID := cmtHeading5;
            StepRun;
          end
          else if FOrigin[FRun] = '#' then
          begin
            StepRun;
            if IsSpaceOrTab(FOrigin[FRun]) then
            begin
              FTokenID := cmtHeading6;
              StepRun;
            end
            else if FOrigin[FRun] = '#' then
            begin
              FTokenID := cmtHeading7;
              StepRun;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCnMarkDownParser.SpaceProc;
var
  IsLS: Boolean;
begin
  IsLS := FIsLineStart;
  StepRun;
  FTokenID := cmtSpace;

  if IsLS then                // �����ĸ��ո�������
  begin
    if FOrigin[FRun] = ' ' then
    begin
      StepRun;
      if FOrigin[FRun] = ' ' then
      begin
        StepRun;
        if FOrigin[FRun] = ' ' then
        begin
          FTokenID := cmtIndent;
          StepRun;
        end;
      end;
    end;
  end
  else // ƽʱ���ո�ӣ��س�������
  begin
    if FOrigin[FRun] = ' ' then
    begin
      StepRun;
      if FOrigin[FRun] = #10 then
      begin
        FTokenID := cmtHardBreak;
        StepRun;
      end
      else if (FOrigin[FRun] = #13) and (FOrigin[FRun + 1] = #10) then
      begin
        FTokenID := cmtHardBreak;
        StepRun;
        StepRun;
      end;
    end;
  end;

  if IsLS and (FTokenID = cmtSpace) then // ���׵Ŀո�Խ������Ȼ�����׼���
    FIsLineStart := True;
end;

procedure TCnMarkDownParser.SquareProc;
begin
  StepRun;
  FTokenID := cmtLinkDisplay;

  while not (FOrigin[FRun] in [']', #0]) do
    StepRun;

  if FOrigin[FRun] = ']' then
    StepRun;
end;

procedure TCnMarkDownParser.StarProc;
var
  IsLS: Boolean;
begin
  IsLS := FIsLineStart;
  StepRun;
  FTokenID := cmtContent;

  if IsLS then
  begin
    if IsSpaceOrTab(FOrigin[FRun]) then // ���׵�*�ո���������б�
    begin
      FTokenID := cmtUnOrderedList;
      StepRun;
    end
    else if FOrigin[FRun] = '*' then
    begin
      StepRun;
      if FOrigin[FRun] = '*' then
      begin
        StepRun;
        if IsCRLF(FOrigin[FRun]) then
        begin
          FTokenID := cmtLine;  // ���������ǺŻ�������
          StepRun;
        end
        else
        begin
          // ���������Ǻź�����б�壬�����Ѿ�Խ����
          FTokenID := cmtBoldItalic;
        end;
      end
      else
      begin
        // �����Ǻţ������Ѿ�Խ����
        FTokenID := cmtBold;
      end;
    end
    else
    begin
      // ���׵ĵ����ǺŴ���б�壬��ͷ�Ѿ�Խ����
      FTokenID := cmtItalic;
    end;
  end
  else
  begin
    if FOrigin[FRun] = '*' then
    begin
      StepRun;
      if FOrigin[FRun] = '*' then
      begin
        // �����ǺŴ����б��
        FTokenID := cmtBoldItalic;
        StepRun;
      end
      else
      begin
        // �����Ǻţ������Ѿ�Խ����
        FTokenID := cmtBold;
      end;
    end
    else
    begin
      // �����Ǻţ���ͷ�Ѿ�Խ����
      FTokenID := cmtItalic;
    end;
  end;
end;

procedure TCnMarkDownParser.StepRun;
var
  IsLF: Boolean;
begin
  IsLF := FOrigin[FRun] = #10;
  Inc(FRun);
  FIsLineStart := IsLF and (FOrigin[FRun] <> #13) and (FOrigin[FRun] <> #10);
end;

procedure TCnMarkDownParser.TabHeaderProc;
begin
  StepRun;
  FTokenID := cmtIndent;
end;

procedure TCnMarkDownParser.TerminateProc;
begin
  FTokenID := cmtTerminate;
end;

procedure TCnMarkDownParser.UnderLineProc;
var
  IsLS: Boolean;
begin
  IsLS := FIsLineStart;
  StepRun;
  FTokenID := cmtContent;

  if IsLS then
  begin
    if FOrigin[FRun] = '_' then
    begin
      StepRun;
      if FOrigin[FRun] = '_' then
      begin
        StepRun;
        if IsCRLF(FOrigin[FRun]) then
        begin
          FTokenID := cmtLine;  // ���������»��߻�������
          StepRun;
        end
        else
        begin
          // ���������»������б�壬�����Ѿ�Խ����
          FTokenID := cmtBoldItalic;
        end;
      end
      else
      begin
        // ���������»�������壬�����Ѿ�Խ����
        FTokenID := cmtBold;
      end;
    end
    else
    begin
      // ���׵����»�����б�壬��ͷ�Ѿ�Խ����
      FTokenID := cmtItalic;
    end;
  end
  else
  begin
    if FOrigin[FRun] = '_' then
    begin
      StepRun;
      if FOrigin[FRun] = '_' then
      begin
        // �����»������б��
        FTokenID := cmtBoldItalic;
        StepRun;
      end
      else
      begin
        // �����»�������壬����Խ����
        FTokenID := cmtBold;
      end;
    end
    else
    begin
      // �����»�����б�壬��ͷ�Ѿ�Խ����
      FTokenID := cmtItalic;
    end;
  end;
end;

procedure TCnMarkDownParser.WaveProc;
begin
  StepRun;
  if FOrigin[FRun] = '~' then  // ���������� ~ ��ɾ����
  begin
    FTokenID := cmtStroke;
    StepRun;
  end
  else
    FTokenID := cmtContent;
end;

{ TCnMarkDownBase }

function TCnMarkDownBase.Add(AMarkDown: TCnMarkDownBase): TCnmarkDownBase;
begin
  FItems.Add(AMarkDown);
  AMarkDown.Parent := Self;
  Result := AMarkDown;
end;

constructor TCnMarkDownBase.Create;
begin
  inherited;
  FItems := TObjectList.Create(True);
end;

procedure TCnMarkDownBase.Delete(Index: Integer);
begin
  FItems.Delete(Index);
end;

destructor TCnMarkDownBase.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCnMarkDownBase.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCnMarkDownBase.GetItem(Index: Integer): TCnMarkDownBase;
begin
  Result := TCnMarkDownBase(FItems.Items[Index]);
end;

procedure TCnMarkDownBase.SetItem(Index: Integer;
  const Value: TCnMarkDownBase);
begin
  FItems.Items[Index] := Value;
end;

procedure CnMarkDownDebugOutputLevel(MarkDown: TCnMarkDownBase; List: TStrings; Level: Integer = 0);
var
  I: Integer;
  IndentStr: string;
  Para: TCnMarkDownParagraph;
  Fragment: TCnMarkDownTextFragment;
  TypeName: string;
begin
  if (MarkDown = nil) or (List = nil) then
    Exit;

  // ���������ַ�����ÿ������ 4 ���ո�
  IndentStr := StringOfChar(' ', Level * 4);

  // ���ݽڵ����������Ϣ
  if MarkDown is TCnMarkDownParagraph then
  begin
    Para := TCnMarkDownParagraph(MarkDown);
    // ��ȡ��������ö������
    TypeName := GetEnumName(TypeInfo(TCnMarkDownParagraphType), Ord(Para.ParagraphType));
    List.Add(IndentStr + '[Paragraph] ' + TypeName);
  end
  else if MarkDown is TCnMarkDownTextFragment then
  begin
    Fragment := TCnMarkDownTextFragment(MarkDown);
    // ��ȡƬ������ö������
    TypeName := GetEnumName(TypeInfo(TCnMarkDownTextFragmentType), Ord(Fragment.FragmentType));
    List.Add(IndentStr + '[Fragment] ' + TypeName + ' Length: ' + IntToStr(Length(Fragment.Content))
      + ' - ' + Fragment.Content);
  end
  else
  begin
    // δ֪�ڵ�����
    List.Add(IndentStr + '[Node] ' + MarkDown.ClassName);
  end;

  // �ݹ鴦���ӽڵ�
  for I := 0 to MarkDown.Count - 1 do
    CnMarkDownDebugOutputLevel(MarkDown.Items[I], List, Level + 1);
end;

procedure CnMarkDownDebugOutput(MarkDown: TCnMarkDownBase; List: TStrings);
begin
  CnMarkDownDebugOutputLevel(MarkDown, List, 0);
end;

function TokenTypeToParaType(TokenType: TCnMarkDownTokenType): TCnMarkDownParagraphType;
begin
  case TokenType of
    cmtHeading1: Result := cmpHeading1;
    cmtHeading2: Result := cmpHeading2;
    cmtHeading3: Result := cmpHeading3;
    cmtHeading4: Result := cmpHeading4;
    cmtHeading5: Result := cmpHeading5;
    cmtHeading6: Result := cmpHeading6;
    cmtHeading7: Result := cmpHeading7;

    cmtLine: Result := cmpLine;
    cmtIndent: Result := cmpPre;
    cmtQuota: Result := cmpQuota;

    cmtUnOrderedList: Result := cmpUnorderedList;
    cmtOrderedList: Result := cmpOrderedList;
    cmtLineBreak: Result := cmpEmpty; // δ������Ķ�������

    cmtContent,
    cmtCodeBlock,      // `
    cmtBold,           // ** �� __
    cmtItalic,         // * �� _
    cmtBoldItalic,     // *** �� ___
    cmtStroke,         // ~~
    cmtLinkDisplay,    // [
    cmtLink,           // (
    cmtDirectLink,     // <...> �е�����
    cmtImageSign:      // ! ���������� [
      Result := cmpCommon; // ���ڸ�ʽ����ͨ���ݣ�������ͨ����

    // TODO: ����
  else
    Result := cmpUnknown;
  end;
end;

procedure ParseMarkDownToLineEnd(P: TCnMarkDownParser; Parent: TCnMarkDownParagraph);
var
  Frag: TCnMarkDownTextFragment;
  PT: TCnMarkDownParagraphType;
  Bookmark: TCnMarkDownBookmark;

  function MapTokenToBrace(ATokenType: TCnMarkDownTokenType): TCnMarkDownTextBraceType;
  begin
    case ATokenType of
      cmtBold:       Result := cmtbBold;
      cmtItalic:     Result := cmtbItalic;
      cmtBoldItalic: Result := cmtbBoldItalic;
      cmtStroke:     Result := cmtbStroke;
      cmtCodeBlock:  Result := cmtbCodeBlock;
    else
      Result := cmtbNone;
    end;
  end;

  // ע��ú������� True ʱ��ParentLastOpenFrag �뷵�ض�Ӧ Open �� Fragment
  function ParentFragmentHasLastOpenToken(AnOpen: TCnMarkDownTokenType): Boolean;
  var
    I: Integer;
    F: TCnMarkDownTextFragment;
    B: TCnMarkDownTextBraceType;
  begin
    // �Ӻ���ǰ�� Parent �� Fragment ���Ƿ��п��ŵ�
    // cmtBold, cmtItalic, cmtBoldItalic, cmtStroke, cmtCodeBlock ��
    // �Ծ��������������ǿ����Ǳգ�ע�⴦���˽���
    B := MapTokenToBrace(AnOpen);
    for I := Parent.Count - 1 downto 0 do
    begin
      F := TCnMarkDownTextFragment(Parent.Items[I]);
      if (F.FragmentType in CN_MARKDOWN_FRAGMENTTYPE_NEED_MATCH) and (F.OpenType = B) and (F.CloseType <> B) then
      begin
        Result := True;
        Exit;
      end;
    end;
    Result := False;
  end;

  // �����һ��Ӧ�رն�δ�رյ� Fragment
  // ע������ ParentFragmentHasLastOpenToken �жϵ����ݱ�����ͬ
  function ParentLastOpenFrag: TCnMarkDownTextFragment;
  var
    F: TCnMarkDownTextFragment;
  begin
    Result := nil;
    if Parent.Count > 0 then
    begin
      F := TCnMarkDownTextFragment(Parent.Items[Parent.Count - 1]);
      if (F.FragmentType in CN_MARKDOWN_FRAGMENTTYPE_NEED_MATCH)          // Ӧ�رն�δ�رյ�
        and (F.CloseType = cmtbNone) then
      begin
        Result := F;
        Exit;
      end;

      if F.FragmentType in [cmfDirectLink, cmfLink, cmfLinkDisplay] then // ֱ�����ȼ����ǵ��飬�����ټӶ���
        Result := nil;
    end;
  end;

  // ���һ���ɼӶ����ģ������Ǳպϵ���Կ飬�����ǵ���
  function ParentLastCommonFrag: TCnMarkDownTextFragment;
  var
    F: TCnMarkDownTextFragment;
  begin
    Result := nil;
    if Parent.Count > 0 then
    begin
      F := TCnMarkDownTextFragment(Parent.Items[Parent.Count - 1]);
      if F.FragmentType in [cmfDirectLink, cmfLink, cmfLinkDisplay] then // �����ǵ���
        Exit;

      if (F.FragmentType in CN_MARKDOWN_FRAGMENTTYPE_NEED_MATCH) // �����Ǳպϵ���Կ�
        and (F.CloseType <> cmtbNone) then
        Exit;
    end;
  end;

  procedure AddCommonContent(const Str: string);
  var
    L: TCnMarkDownTextFragment;
  begin
    L := ParentLastOpenFrag;
    if L = nil then // ��һ���������걸
    begin
      L := ParentLastCommonFrag;
      if L = nil then // ����û����һ�����ͼӸ��µ�
      begin
        Frag := TCnMarkDownTextFragment.Create;
        Frag.FragmentType := cmfCommon;

        Parent.Add(Frag);
        Frag.AddContent(Str);
        Exit;
      end;
    end;
    L.AddContent(Str);
  end;

begin
  // ����ֱ����β������Ȼ����ӵ� Parent �£���Խ����β�Ļ���ָ����һ������������ Next
  // ����ʱ��P ��ǰһ�� Token�����ﰴ�� Next
  // ���������������
  // һ����ͨ���л�Ӳ���к�ǿ�н��������� Parent �� Heading����������һ����ɶ
  // ������ͨ���к��Լ��Լ���һ����ɶ�����Ƿ�����������Լ�����ͨ���䣬��ͨ�����򲻽��������������У���Ӳ���н�����

  PT := TCnMarkDownParagraph(Parent).ParagraphType;
  if PT in [cmpPre, cmpFenceCodeBlock] then
  begin
    // Pre �ʹ���鶼ԭ�ⲻ�������У�����������ѭ������
    Frag := TCnMarkDownTextFragment.Create;
    Frag.FragmentType := cmfCommon;
    Parent.Add(Frag);

    repeat
      P.Next;
      Frag.AddContent(P.Token);
    until (P.TokenID in [cmtTerminate, cmtLineBreak, cmtHardBreak]); // ��ͨ�س���Ӳ�س�����
  end
  else
  begin
    if PT in [cmpHeading1..cmpHeading7, cmpOrderedList, cmpUnOrderedList, cmpLine] then // �⼸�������п�ʼ��ǣ�����
      P.Next;

    // ѭ������������
    while not (P.TokenID in [cmtTerminate, cmtHardBreak]) do
    begin
      case P.TokenID of
        cmtLineBreak:
          begin
            // Ҫȷ���˳�ѭ��ʱ P.TokenID ָ����
            if PT in [cmpHeading1..cmpHeading7, cmpOrderedList, cmpUnOrderedList] then // ��Щ�������˳�
              Break;

            P.SaveToBookmark(Bookmark);
            P.Next;

            // ��������Ҳ�˳���һЩ���Ͷ��俪ͷҲ�˳���Ҫ���˵����У�������ͨ���ݼ���
            if P.TokenID = cmtLineBreak then
              Break
            else if P.TokenID in CN_MARKDOWN_TOKENTYPE_PARAHEAD then
            begin
              // ���˵���һ Token
              P.LoadFromBookmark(Bookmark);
              Break;
            end
            else if P.TokenID = cmtContent then
              AddCommonContent(P.Token);
          end;
        cmtBold:
          begin
            if ParentFragmentHasLastOpenToken(cmtBold) then
              ParentLastOpenFrag.CloseType := cmtbBold
            else
            begin
              Frag := TCnMarkDownTextFragment.Create;
              Frag.FragmentType := cmfBold;
              Frag.OpenType := cmtbBold;

              Parent.Add(Frag);
            end;
          end;
        cmtItalic:
          begin
            if ParentFragmentHasLastOpenToken(cmtItalic) then
              ParentLastOpenFrag.CloseType := cmtbItalic
            else
            begin
              Frag := TCnMarkDownTextFragment.Create;
              Frag.FragmentType := cmfItalic;
              Frag.OpenType := cmtbItalic;

              Parent.Add(Frag);
            end;
          end;
        cmtBoldItalic:
          begin
            if ParentFragmentHasLastOpenToken(cmtBoldItalic) then
              ParentLastOpenFrag.CloseType := cmtbBoldItalic
            else
            begin
              Frag := TCnMarkDownTextFragment.Create;
              Frag.FragmentType := cmfBoldItalic;
              Frag.OpenType := cmtbBoldItalic;

              Parent.Add(Frag);
            end;
          end;
        cmtStroke:
          begin
            if ParentFragmentHasLastOpenToken(cmtStroke) then
              ParentLastOpenFrag.CloseType := cmtbStroke
            else
            begin
              Frag := TCnMarkDownTextFragment.Create;
              Frag.FragmentType := cmfStroke;
              Frag.OpenType := cmtbStroke;

              Parent.Add(Frag);
            end;
          end;
        cmtCodeBlock:
          begin
            if ParentFragmentHasLastOpenToken(cmtCodeBlock) then
              ParentLastOpenFrag.CloseType := cmtbCodeBlock
            else
            begin
              Frag := TCnMarkDownTextFragment.Create;
              Frag.FragmentType := cmfCodeBlock;
              Frag.OpenType := cmtbCodeBlock;

              Parent.Add(Frag);
            end;
          end;
        cmtLinkDisplay:
          begin
            Frag := TCnMarkDownTextFragment.Create;
            Frag.FragmentType := cmfLinkDisplay;
            Frag.AddContent(P.Token);
            Parent.Add(Frag);
          end;
        cmtLink:
          begin
            Frag := TCnMarkDownTextFragment.Create;
            Frag.FragmentType := cmfLink;
            Frag.AddContent(P.Token);
            Parent.Add(Frag);
          end;
        cmtDirectLink:
          begin
            Frag := TCnMarkDownTextFragment.Create;
            Frag.FragmentType := cmfDirectLink;
            Frag.AddContent(P.Token);
            Parent.Add(Frag);
          end;
        cmtImageSign:
          begin
            Frag := TCnMarkDownTextFragment.Create;
            Frag.FragmentType := cmfImage;
            Frag.AddContent(P.Token);
            Parent.Add(Frag);
          end;
      else
        AddCommonContent(P.Token);
      end;
      P.Next;
    end;
  end;
end;

function CnParseMarkDownString(const MarkDown: string): TCnMarkDownBase;
var
  I: Integer;
  P: TCnMarkDownParser;
  Root: TCnMarkDownBase;
  CurPara: TCnMarkDownParagraph;
  ParaStack: TStack;

  procedure NewParagraph;
  var
    Para: TCnMarkDownParagraph;
  begin
    Para := TCnMarkDownParagraph.Create;
    Para.ParagraphType := TokenTypeToParaType(P.TokenID);
    if CurPara = nil then
    begin
      Root.Add(Para);
      ParaStack.Push(Root);
    end
    else
    begin
      CurPara.Add(Para);
      ParaStack.Push(CurPara);
    end;

    CurPara := Para;
  end;

  procedure EndParagraph;
  begin
    // ��ͨ������������õı��Ҫȫ��������������������ֻҪ����
    while ParaStack.Count > 0 do
    begin
      CurPara := TCnMarkDownParagraph(ParaStack.Pop);
      if CurPara.ParagraphType <> cmpQuota then
        Break;
    end;
  end;

begin
  Root := TCnMarkDownBase.Create; // ��Ϊ Root

  P := nil;
  ParaStack := nil;

  try
    P := TCnMarkDownParser.Create;
    try
      P.SetOrigin(PChar(MarkDown));
      ParaStack := TStack.Create;
      CurPara := nil;

      while P.TokenID <> cmtTerminate do
      begin
        // ����Ҫȷ��ÿ�� case ���Ƕ��俪ʼ
        case P.TokenID of
          cmtHeading1..cmtHeading7:
            begin
              // �����¶��䲢���ñ��⼶��
              NewParagraph;
              ParseMarkDownToLineEnd(P, CurPara);
              EndParagraph;
            end;
          cmtLine:
            begin
              // �߶�
              NewParagraph;
              P.Next; // ֱ��Խ���߶Σ���ѭ��Խ������Ļ���
              EndParagraph;
            end;
          cmtUnOrderedList:
            begin
              // �����б��ÿһ��
              NewParagraph;
              ParseMarkDownToLineEnd(P, CurPara);
              EndParagraph;
            end;
          cmtOrderedList:
            begin
              // �����б��ÿһ��
              NewParagraph;
              ParseMarkDownToLineEnd(P, CurPara);
              EndParagraph;
            end;
          cmtFenceCodeBlock:
            begin
              // ��������һ��
              NewParagraph;
              repeat
                ParseMarkDownToLineEnd(P, CurPara);
              until P.TokenID in [cmtFenceCodeBlock, cmtTerminate];
              EndParagraph;
            end;
          cmtIndent:
            begin
              // ����ԭʼ��ʽ��
              NewParagraph;
              ParseMarkDownToLineEnd(P, CurPara);
              EndParagraph;
            end;
          cmtQuota:
            begin
              // ���ÿ飬������µ�һ��
              NewParagraph;
            end;
        else //cmtContent, cmtLinkDisplay, cmtDirectLink, cmtImageSign:
          // ������ͨ���ݣ�������ʼ�Ŀո񣬽�������
          if not IsBlank(P.Token) then
          begin
            NewParagraph;
            ParseMarkDownToLineEnd(P, CurPara);
            EndParagraph;
          end;
        end;

        P.Next;
      end;
    finally
      ParaStack.Free;
      P.Free;
    end;
  except
    Root.Free; // ����;�������쳣���ͷ� Root
    Root := nil;
    raise;
  end;

  // ����������õĿն�
  if Root <> nil then
  begin
    for I := Root.Count - 1 downto 0 do
    begin
      if Root[I] is TCnMarkDownParagraph then
      begin
        if (TCnMarkDownParagraph(Root[I]).Count = 0) and
          (TCnMarkDownParagraph(Root[I]).ParagraphType = cmpEmpty) then
          Root.Delete(I);
      end;
    end;
  end;
  Result := Root;
end;

{ TCnMarkDownTextFragment }

procedure TCnMarkDownTextFragment.AddContent(const Cont: string);
begin
  FContent := FContent + Cont;
end;

function TCnMarkDownTextFragment.GetContent: string;
begin
  Result := FContent;
end;

{ TCnRTFConverter }

function TCnRTFConverter.Convert(Root: TCnMarkDownBase): string;
var
  I: Integer;
begin
  FRtf.Clear;
  FRtf.Append(CN_RTF_HEADER);

  for I := 0 to Root.Count - 1 do
    ProcessNode(Root.Items[I]);

  FRtf.Append(CN_RTF_FOOTER);
  Result := FRtf.ToString;
end;

function TCnRTFConverter.ConvertFragment(Fragment: TCnMarkDownTextFragment): string;
begin
  case Fragment.FragmentType of
    cmfCodeBlock:   Result := '\f3\highlight3\b ' + EscapeContent(Fragment.Content) + '\b0\highlight0\f0 ';
    cmfBold:        Result := '\b ' + EscapeContent(Fragment.Content) + '\b0 ';
    cmfItalic:      Result := '\i ' + EscapeContent(Fragment.Content) + '\i0 ';
    cmfBoldItalic:  Result := '\b\i ' + EscapeContent(Fragment.Content) + '\i0\b0 ';
    cmfStroke:      Result := '\strike ' + EscapeContent(Fragment.Content) + '\strike0 ';
    cmfLink:        Result := '\cf2 ' + EscapeContent(Fragment.Content) + '\cf0 ';
  else
    Result := EscapeContent(Fragment.Content);
  end;
end;

function TCnRTFConverter.ConvertParagraphEnd(Paragraph: TCnMarkDownParagraph): string;
begin
  if Paragraph.ParagraphType = cmpLine then
    Result := #13#10 // �ָ������貹��β������
  else if Paragraph.ParagraphType <> cmpQuota then // Quota Ҳ���Ǿ�����䣬��д
    Result :='\par}'#13#10;
end;

function TCnRTFConverter.ConvertParagraphStart(Paragraph: TCnMarkDownParagraph): string;
var
  Level, Q: Integer;
begin
  Q := GetQuotaLevel(Paragraph);
  case Paragraph.ParagraphType of
    cmpHeading1..cmpHeading7:
      begin
        FCurrentFontSize := 36 - (Ord(Paragraph.ParagraphType) - Ord(cmpHeading1)) * 4;
        Result := Format('{\pard\fs%d\b ', [FCurrentFontSize]);
      end;
    cmpUnorderedList:
      begin
        Result := Format('{\pard{\pntext\f2\''B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\''B7}}\fi%d\li%d\sa200\sl276\slmult1 ',
          [CN_LIST_UNINDENT, CN_LIST_INDENT + Q * CN_QUOTA_INDENT]);
      end;
    cmpOrderedList:
      begin
        Level := GetListLevel(Paragraph);  // �б������㼶
        Q := GetQuotaLevel(Paragraph);     // ���������㼶
        Inc(FListCounters[Level]);         // �б����

        Result := Format('{\pard{\pntext\f0 %d.\tab}\fi%d\li%d\sa200\sl276\slmult1\lang2052\f0\fs22 ',
          [FListCounters[Level], CN_LIST_UNINDENT, CN_LIST_INDENT + Q * CN_QUOTA_INDENT])
      end;
    cmpLine:
      Result := '{\pard\sa200\brdrb\brdrs\brdrw15\par}';
    cmpQuota:
      begin
        // Quota �����Ǿ�����䣬��д
      end;
    cmpFenceCodeBlock:
      Result := '{\lang2052\f1\fs20\cbpat1 ';
  else
    if (Paragraph.Parent <> nil) and (Paragraph.Parent is TCnMarkDownParagraph) then
    begin
      Result := Format('{\pard\li%d ', [Q * CN_QUOTA_INDENT])   // ��ͨ�ڲ�������������ò㼶����
    end
    else
      Result := '{\pard\plain\li0\fi0 '; // ����������Ĭ������ 0 �ĸ�ʽ
  end;
end;

constructor TCnRTFConverter.Create;
begin
  inherited;
  FRtf := TCnStringBuilder.Create;
  FCurrentFontSize := 24;
end;

destructor TCnRTFConverter.Destroy;
begin
  FRtf.Free;
  inherited;
end;

function TCnRTFConverter.EscapeContent(const Text: string): string;
begin
  Result := StringReplace(Text, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '{', '\{', [rfReplaceAll]);
  Result := StringReplace(Result, '}', '\}', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\line ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\line ', [rfReplaceAll]);
end;

function TCnRTFConverter.GetListLevel(Paragraph: TCnMarkDownParagraph): Integer;
var
  Node: TCnMarkDownBase;
begin
  Result := 1;
  Node := Paragraph.Parent;
  while (Node <> nil) and (Node is TCnMarkDownParagraph) do
  begin
    if TCnMarkDownParagraph(Node).ParagraphType in [cmpOrderedList, cmpUnorderedList] then
      Inc(Result);
    Node := Node.Parent;
  end;
end;

function TCnRTFConverter.GetQuotaLevel(Paragraph: TCnMarkDownParagraph): Integer;
var
  Node: TCnMarkDownBase;
begin
  Result := 0;
  if Paragraph.ParagraphType = cmpQuota then
    Inc(Result);

  Node := Paragraph.Parent;
  while (Node <> nil) and (Node is TCnMarkDownParagraph) do
  begin
    if TCnMarkDownParagraph(Node).ParagraphType in [cmpQuota] then
      Inc(Result);
    Node := Node.Parent;
  end;
end;

procedure TCnRTFConverter.ProcessNode(Node: TCnMarkDownBase);
var
  I: Integer;
begin
  if Node is TCnMarkDownParagraph then
    FRtf.Append(ConvertParagraphStart(TCnMarkDownParagraph(Node)));

  for I := 0 to Node.Count - 1 do
    ProcessNode(Node.Items[I]);

  if Node is TCnMarkDownParagraph then
    FRtf.Append(ConvertParagraphEnd(TCnMarkDownParagraph(Node)))
  else if Node is TCnMarkDownTextFragment then
    FRtf.Append(ConvertFragment(TCnMarkDownTextFragment(Node)));
end;

function CnMarkDownConvertToRTF(Root: TCnMarkDownBase): string;
begin
  with TCnRTFConverter.Create do
  try
    Result := Convert(Root);
  finally
    Free;
  end;
end;

end.

