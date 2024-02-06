{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
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

unit CnPDF;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�PDF ���׽������ɵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע���򵥵� PDF ��ʽ����Ԫ
*           �����������Խ��дʷ��������ٽ�������������ٽ������������
*           ���ɣ��ȹ���̶��Ķ��������������ݺ�д����
*
*           �ļ�β�� Trailer �� Root ָ�� Catalog ���󣬴�������ṹ���£�
*
*           Catalog -> Pages -> Page1 -> Resource
*                   |        |      | -> Content
*                   |        |      | -> Thunbnail Image
*                   |        |      | -> Annoation
*                   |        -> Page2 ...
*                   |
*                   -> Outline Hierarchy -> Outline Entry
*                   |                  | -> Outline Entry
*                   |
*                   -> Artical Threads -> Thread
*                   |                | -> Thread
*                   -> Named Destination
*                   -> Interactive Form
*
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2024.02.06 V1.0
*               ������ɴʷ�����������֯�﷨��
*           2024.01.28 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, jpeg, CnNative, CnStrings;

type
  ECnPDFException = class(Exception);
  {* PDF �쳣}

  ECnPDFEofException = class(Exception);
  {* ���� PDF ʱ��������β}

//==============================================================================
// ������ PDF �ļ��и��ֶ�������������̳й�ϵ
//
//  TCnPDFObject ������
//    �򵥣�TCnPDFNumberObject��TCnPDFNameObject��TCnPDFBooleanObject��
//          TCnPDFNullObject��TCnPDFStringObject��TCnPDFReferenceObject
//    ���ϣ�TCnPDFArrayObject�����԰������ TCnPDFObject
//          TCnPDFDictionaryObject��������� TCnPDFNameObject �� TCnPDFObject ��
//          TCnPDFStreamObject������һ�� TCnPDFDictionaryObject ��һƬ����������
//
//==============================================================================

  TCnPDFXRefType = (xrtNormal, xrtDeleted, xrtFree);
  {* ����Ľ����������ͣ����������á��������á���ɾ��}

  TCnPDFObject = class
  {* PDF �ļ��еĶ������}
  private
    FID: Cardinal;
    FGeneration: Cardinal;
    FXRefType: TCnPDFXRefType;
  protected
    function CheckWriteObjectStart(Stream: TStream): Cardinal;
    function CheckWriteObjectEnd(Stream: TStream): Cardinal;
  public
    function WriteToStream(Stream: TStream): Cardinal; virtual; abstract;

    property ID: Cardinal read FID write FID;
    {* ���� ID����Ϊ 0��д��ʱ��дǰ��׺}
    property Generation: Cardinal read FGeneration write FGeneration;
    {* ����Ĵ�����һ��Ϊ 0}
    property XRefType: TCnPDFXRefType read FXRefType write FXRefType;
    {* ���󽻲��������ͣ�һ��Ϊ normal}
  end;

  TCnPDFSimpleObject = class(TCnPDFObject)
  {* �򵥵� PDF �ļ�������࣬��һ�μ����ݣ��ɰ���ʽ���}
  private

  protected
    FContent: TBytes;
  public
    constructor Create(const AContent: AnsiString); overload;
    {* ��һ�����ݴ�������}
    constructor Create(const Data: TBytes); overload;
    {* ��һ�����ݴ�������}

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* �򵥶���Ĭ����ԭ�����}

    property Content: TBytes read FContent write FContent;
    {* ��������װ��ʽǰ��׺�ľ�������}
  end;

  TCnPDFNumberObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е����ֶ�����}
  public
    constructor Create(Num: Integer); reintroduce;overload;
    constructor Create(Num: Int64); reintroduce; overload;
    constructor Create(Num: Extended); reintroduce; overload;
  end;

  TCnPDFNameObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е����ֶ�����}
  public
    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���б�ܼ�����}
  end;

  TCnPDFBooleanObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��еĲ���������}
  public
    constructor Create(IsTrue: Boolean); reintroduce;
  end;

  TCnPDFNullObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��еĿն�����}
  public
    constructor Create; reintroduce;
  end;

  TCnPDFStringObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е��ַ���������}
  public
    constructor Create(const AnsiStr: AnsiString); overload;
{$IFDEF COMPILER5}
    constructor CreateW(const WideStr: WideString); // D5 ���� overload
{$ELSE}
    constructor Create(const WideStr: WideString); overload;
{$ENDIF}
{$IFDEF UNICODE}
    constructor Create(const UnicodeStr: string); overload;
{$ENDIF}

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���һ��С���ż������ڵ��ַ���}
  end;

  TCnPDFReferenceObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е����ö�����}
  private
    FRef: TCnPDFObject;
  public
    constructor Create(Obj: TCnPDFObject); reintroduce; virtual;
    destructor Destroy; override;

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ������� ���� R}
  end;

  TCnPDFDictPair = class
  {* PDF �ļ��е��ֵ�������е����ֶ���ԣ�����������ֵ��������}
  private
    FName: TCnPDFNameObject;
    FValue: TCnPDFObject;
  public
    constructor Create(const Name: string); virtual;
    destructor Destroy; override;

    procedure ChangeToArray;
    {* �� Value �Ǽ򵥶���� nil ʱ��ת�� Value ��������󣬲����� Value ��Ϊ���һ��Ԫ��}

    function WriteToStream(Stream: TStream): Cardinal;
    {* ������� ֵ}

    property Name: TCnPDFNameObject read FName;
    {* ���ֶ���}
    property Value: TCnPDFObject read FValue write FValue;
    {* ֵ���󣬿���������ã������ͷ�}
  end;


  TCnPDFArrayObject = class(TCnPDFObject)
  {* PDF �ļ��е���������࣬���������ڵ�Ԫ�ض���}
  private
    FElements: TObjectList;
    function GetItem(Index: Integer): TCnPDFObject;
    procedure SetItem(Index: Integer; const Value: TCnPDFObject);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���[��ÿ������]}

    procedure AddObject(Obj: TCnPDFObject);
    {* ���һ�������ⲿ�����ͷŴ˶���}
    procedure AddNumber(Value: Integer); overload;
    procedure AddNumber(Value: Int64); overload;
    procedure AddNumber(Value: Extended); overload;
    procedure AddNul;
    procedure AddTrue;
    procedure AddFalse;
    procedure AddObjectRef(Obj: TCnPDFObject);
    procedure AddAnsiString(const Value: AnsiString);
    procedure AddWideString(const Value: WideString);
{$IFDEF UNICODE}
    procedure AddUnicodeString(const Value: string);
{$ENDIF}

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCnPDFObject read GetItem write SetItem;
    {* ���������Ԫ��}
  end;

  TCnPDFDictionaryObject = class(TCnPDFObject)
  {* PDF �ļ��е��ֵ�����࣬�����ڲ� Pair}
  private
    FPairs: TObjectList;
    function GetValue(const Name: string): TCnPDFObject;
    procedure SetValue(const Name: string; const Value: TCnPDFObject);
    function GetCount: Integer;
  protected
    function IndexOfName(const Name: string): Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;
    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���<<��ÿ��Pair��>>}

    function AddName(const Name: string): TCnPDFDictPair; overload;
    {* ���һ�����ƣ�ֵ����縳ֵ����ֵ���ⲿ�����ͷŴ˶���}
    function AddName(const Name1, Name2: string): TCnPDFDictPair; overload;
    {* ����������Ʒֱ���Ϊ������ֵ}

    function AddArray(const Name: string): TCnPDFArrayObject;
    {* ���һ�������Ŀ����飬ע�ⷵ�ص������������}
    function AddDictionary(const Name: string): TCnPDFDictionaryObject;
    {* ���һ�������Ŀ��ֵ䣬ע�ⷵ�ص����ֵ������}

    function AddNumber(const Name: string; Value: Integer): TCnPDFDictPair; overload;
    function AddNumber(const Name: string; Value: Int64): TCnPDFDictPair; overload;
    function AddNumber(const Name: string; Value: Extended): TCnPDFDictPair; overload;
    function AddNull(const Name: string): TCnPDFDictPair;
    function AddTrue(const Name: string): TCnPDFDictPair;
    function AddFalse(const Name: string): TCnPDFDictPair;
    function AddObjectRef(const Name: string; Obj: TCnPDFObject): TCnPDFDictPair;
    function AddString(const Name: string; const Value: string): TCnPDFDictPair;
    function AddAnsiString(const Name: string; const Value: AnsiString): TCnPDFDictPair;
    function AddWideString(const Name: string; const Value: WideString): TCnPDFDictPair;
{$IFDEF UNICODE}
    function AddUnicodeString(const Name: string; const Value: string): TCnPDFDictPair;
{$ENDIF}

    property Count: Integer read GetCount;
    {* �ֵ��ڵ�Ԫ������}
    property Values[const Name: string]: TCnPDFObject read GetValue write SetValue; default;
    {* �����������ö���}
  end;

  TCnPDFStreamObject = class(TCnPDFObject)
  {* PDF �ļ��е��������࣬��˵����һ�ֵ�һ��}
  private
    FStream: TBytes;
    FDictionary: TCnPDFDictionaryObject;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetJpegImage(const JpegFileName: string);
    {* ��һ JPEG ��ʽ���ļ����뱾����} 

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ��� stream ������ endstream}

    property Dictionary: TCnPDFDictionaryObject read FDictionary;
    {* �ֵ�}
    property Stream: TBytes read FStream;
    {* ������ԭʼ������}
  end;

  TCnPDFObjectManager = class(TObjectList)
  {* PDFDocument ���ڲ�ʹ�õĹ���ÿ���������������}
  private
    FCurrentID: Integer;
    function GetItem(Index: Integer): TCnPDFObject;
    procedure SetItem(Index: Integer; const Value: TCnPDFObject);
  public
    constructor Create;

    function Add(AObject: TCnPDFObject): Integer; reintroduce;
    property Items[Index: Integer]: TCnPDFObject read GetItem write SetItem; default;
    property CurrentID: Integer read FCurrentID;
  end;

  TCnPDFHeader = class
  {* PDF �ļ�ͷ�Ľ���������}
  private
    FVersion: string;
    FComment: string;
  public
    constructor Create; virtual;
    {* ���캯��}
    destructor Destroy; override;
    {* ��������}

    function WriteToStream(Stream: TStream): Cardinal;
    {* �������������}

    property Version: string read FVersion write FVersion;
    {* �ַ�����ʽ�İ汾�ţ��� 1.7 ��}
    property Comment: string read FComment write FComment;
    {* һ�ε���ע�ͣ���һЩ�����ַ�}
  end;

  TCnPDFXRefItem = class(TCollectionItem)
  {* PDF �ļ���Ľ������ñ����Ŀ�������Ŀ����һ����}
  private
    FObjectGeneration: Cardinal;
    FObjectXRefType: TCnPDFXRefType;
    FObjectOffset: Cardinal;
  public
    property ObjectGeneration: Cardinal read FObjectGeneration write FObjectGeneration;
    {* �������}
    property ObjectXRefType: TCnPDFXRefType read FObjectXRefType write FObjectXRefType;
    {* ������������}
    property ObjectOffset: Cardinal read FObjectOffset write FObjectOffset;
    {* �������ļ��е�ƫ����}
  end;

  TCnPDFXRefCollection = class(TCollection)
  {* PDF �ļ���Ľ������ñ��е�һ���εĽ��������ɣ����������Ŀ}
  private
    FObjectIndex: Cardinal;
    function GetItem(Index: Integer): TCnPDFXRefItem;
    procedure SetItem(Index: Integer; const Value: TCnPDFXRefItem);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function WriteToStream(Stream: TStream): Cardinal;
    {* �������������}

    function Add: TCnPDFXRefItem;
    {* ���һ���ս���������Ŀ}

    property ObjectIndex: Cardinal read FObjectIndex write FObjectIndex;
    {* �����ڵĶ�����ʼ���}
    property Items[Index: Integer]: TCnPDFXRefItem read GetItem write SetItem;
    {* ���ε�����������}
  end;

  TCnPDFXRefTable = class
  {* PDF �ļ��еĽ������ñ�Ľ��������ɣ�����һ��������}
  private
    FSegments: TObjectList;
    function GetSegmenet(Index: Integer): TCnPDFXRefCollection;
    function GetSegmentCount: Integer;
    procedure SetSegment(Index: Integer;
      const Value: TCnPDFXRefCollection);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;

    function WriteToStream(Stream: TStream): Cardinal;
    {* �������������}

    function AddSegment: TCnPDFXRefCollection;
    {* ����һ���ն�}

    property SegmentCount: Integer read GetSegmentCount;
    {* �������ñ��еĶ���}
    property Segments[Index: Integer]: TCnPDFXRefCollection read GetSegmenet write SetSegment;
    {* �������ñ��е�ÿһ��}
  end;

  TCnPDFTrailer = class
  {* PDF �ļ�β�Ľ���������}
  private
    FDictionary: TCnPDFDictionaryObject;
    FXRefStart: Cardinal;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function WriteToStream(Stream: TStream): Cardinal;
    {* �������������}

    property Dictionary: TCnPDFDictionaryObject read FDictionary;
    {* �ļ�β���ֵ䣬���� Size��Root��Info �ȹؼ���Ϣ}

    property XRefStart: Cardinal read FXRefStart write FXRefStart;
    {* �������ñ����ʼ�ֽ�ƫ����������ָ�� xref ԭʼ��Ҳ������һ�� ������ XRef �� Object����ͷ����ʽ����}
  end;

  TCnPDFBody = class
  {* PDF ������֯��}
  private
    FObjects: TCnPDFObjectManager;     // ���ж����������Ͻ�����඼������
    FPageList: TObjectList;            // ҳ������б�
    FResourceList: TObjectList;        // ҳ��������Դ�б��ȶ���һ�飬һ���� Dictionary
    FContentList: TObjectList;         // ҳ�����������б��ȶ���һ�飬һ���� Stream
    FPages: TCnPDFDictionaryObject;    // ҳ��������
    FCatalog: TCnPDFDictionaryObject;  // ��Ŀ¼���󣬹� Trailer ������
    FInfo: TCnPDFDictionaryObject;     // ��Ϣ���󣬹� Trailer ������
    FXRefTable: TCnPDFXRefTable;       // �������ñ������
    function GetPage(Index: Integer): TCnPDFDictionaryObject;
    function GetPageCount: Integer;
  protected
    procedure ArrangeIDs;
    {* �����ж���� ID ˳��ֵ}
    procedure SyncPages;
    {* ��ҳ���������ø�ֵ�� Pages �� Kids}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SortObjects;
    {* �����������������}

    function WriteToStream(Stream: TStream): Cardinal;
    {* �������������}

    procedure AddObject(Obj: TCnPDFObject);
    {* �������Ӵ����õĶ��󲢽�����������ڲ�����ö���������Ч ID}
    property Objects: TCnPDFObjectManager read FObjects;
    {* ���ж��󹩷���}

    property XRefTable: TCnPDFXRefTable read FXRefTable write FXRefTable;
    {* �������ñ�����ã���д����������ƫ�Ƶ�}

    // ���´�ű���
    property Info: TCnPDFDictionaryObject read FInfo;
    {* ��Ϣ��������Ϊ�ֵ�}

    property Catalog: TCnPDFDictionaryObject read FCatalog;
    {* ����������Ϊ�ֵ䣬�� /Pages ָ�� Pages ����}

    property Pages: TCnPDFDictionaryObject read FPages;
    {* ҳ���б�����Ϊ�ֵ䣬�� /Kids ָ�����ҳ��}
    property PageCount: Integer read GetPageCount;
    {* ҳ���������}
    property Page[Index: Integer]: TCnPDFDictionaryObject read GetPage;
    {* ���ҳ���������Ϊ�ֵ䣬�� MediaBox������ֽ�Ŵ�С����Resources��������Դ�ȣ���
      Parent��ָ��ҳ���б��ڵ㣩��Contents��ҳ�����ݲ�������}
    function AddPage: TCnPDFDictionaryObject;
    {* ����һҳ��}

    function AddResource(Page: TCnPDFDictionaryObject): TCnPDFDictionaryObject;
    {* ��ĳҳ����һ�� Resource��Page �� /Resources ָ�������˶���}
    function AddContent(Page: TCnPDFDictionaryObject): TCnPDFStreamObject;
    {* ��ĳҳ����һ�� Content��Page �� /Contents ָ�������˶���}
  end;

//==============================================================================
//
// ������ PDF �ļ��Ľṹ�������ĸ���
//
//==============================================================================

  TCnPDFDocument = class
  private
    FHeader: TCnPDFHeader;
    FBody: TCnPDFBody;
    FXRefTable: TCnPDFXRefTable;
    FTrailer: TCnPDFTrailer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    property Header: TCnPDFHeader read FHeader;
    property Body: TCnPDFBody read FBody;
    property XRefTable: TCnPDFXRefTable read FXRefTable;
    property Trailer: TCnPDFTrailer read FTrailer;
  end;

//==============================================================================
//
// ������ PDF �ļ��Ĵʷ����﷨��������δʵ��
//
//==============================================================================

  TCnPDFTokenType = (pttUnknown, pttComment, pttBlank, pttLineBreak, pttNumber,
    pttNull, pttTrue, pttFalse, pttObj, pttEndObj, pttStream, pttEnd, pttR,
    pttN, pttD, pttF, pttXref, pttStartxref, pttTrailer,
    pttName, pttStringBegin, pttString, pttStringEnd,
    pttHexStringBegin, pttHexString, pttHexStringEnd, pttArrayBegin, pttArrayEnd,
    pttDictionaryBegin, pttDictionaryEnd, pttStreamData, pttEndStream);
  {* PDF �ļ������еķ������ͣ���Ӧ%���ո񡢻س����С����֡�
    null��true��false��obj��stream��end��R��xref��startxref��trailer
    /��(��)��<��>��[��]��<<��>>��������}

  TCnPDFParser = class
  {* PDF ���ݽ�����}
  private
    FRun: Integer;
    FTokenPos: Integer;
    FOrigin: PAnsiChar;
    FByteLength: Cardinal;
    FStringLen: Integer; // ��ǰ�ַ������ַ�����
    FProcTable: array[#0..#255] of procedure of object;
    FTokenID: TCnPDFTokenType;
    FPrevNonBlankID: TCnPDFTokenType;

    procedure KeywordProc;               // obj stream end null true false �ȹ̶���ʶ��
    procedure NameBeginProc;             // /
    procedure StringBeginProc;           // (
    procedure StringEndProc;             // )
    procedure ArrayBeginProc;            // [
    procedure ArrayEndProc;              // ]
    procedure LessThanProc;       // <<
    procedure GreaterThanProc;         // >>
    procedure CommentProc;               // %
    procedure NumberProc;                // ����+-
    procedure BlankProc;                 // �ո� Tab ��
    procedure CRLFProc;                  // �س����л�س�����
    procedure UnknownProc;               // δ֪

    procedure StringProc;                // �ֹ����õ��ַ�������
    procedure HexStringProc;             // �ֹ����õ�ʮ�������ַ�������
    procedure StreamDataProc;            // �ֹ����õ������ݴ���

    function GetToken: AnsiString;
    procedure SetRunPos(const Value: Integer);
    function GetTokenLength: Integer;
  protected
    procedure Error(const Msg: string);
    function TokenEqualStr(Org: PAnsiChar; const Str: AnsiString): Boolean;
    procedure MakeMethodTable;
    procedure StepRun; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  public
    constructor Create; virtual;
    {* ���캯��}
    destructor Destroy; override;
    {* ��������}

    procedure SetOrigin(const PDFBuf: PAnsiChar; PDFByteSize: Cardinal);

    procedure Next;
    {* ������һ�� Token ��ȷ�� TokenID}
    procedure NextNoJunk;
    {* ������һ���� Null �Լ��ǿո� Token ��ȷ�� TokenID}

    property Origin: PAnsiChar read FOrigin;
    {* �������� PDF ����}
    property RunPos: Integer read FRun write SetRunPos;
    {* ��ǰ����λ������� FOrigin ������ƫ��������λΪ�ֽ�����0 ��ʼ}
    property TokenID: TCnPDFTokenType read FTokenID;
    {* ��ǰ Token ����}
    property Token: AnsiString read GetToken;
    {* ��ǰ Token ���ַ������ݣ��ݲ�����}
    property TokenLength: Integer read GetTokenLength;
    {* ��ǰ Token ���ֽڳ���}
  end;

implementation

const
  SPACE: AnsiChar = ' ';
  CRLF: array[0..1] of AnsiChar = (#13, #10);

  CRLFS: set of AnsiChar = [#13, #10];
  // PDF �淶�еĿհ��ַ��еĻس�����
  WHITESPACES: set of AnsiChar = [#0, #9, #12, #32];
  // PDF �淶�г��˻س�����֮��Ŀհ��ַ�
  DELIMETERS: set of AnsiChar = ['(', ')', '<', '>', '[', ']', '{', '}', '%'];
  // PDF �淶�еķָ��ַ�

  OBJFMT: AnsiString = '%d %d obj';
  ENDOBJ: AnsiString = 'endobj';
  XREF: AnsiString = 'xref';
  BEGINSTREAM: AnsiString = 'stream';
  ENDSTREAM: AnsiString = 'endstream';

  TRAILER: AnsiString = 'trailer';
  STARTXREF: AnsiString = 'startxref';
  EOF: AnsiString = '%%EOF';

function WriteSpace(Stream: TStream): Cardinal;
begin
  Result := Stream.Write(SPACE, SizeOf(SPACE));
end;

function WriteCRLF(Stream: TStream): Cardinal;
begin
  Result := Stream.Write(CRLF[0], SizeOf(CRLF));
end;

function WriteLine(Stream: TStream; const Str: AnsiString): Cardinal;
begin
  if Length(Str) > 0 then
    Result := Stream.Write(Str[1], Length(Str))
  else
    Result := 0;
  Inc(Result, WriteCRLF(Stream));
end;

function WriteString(Stream: TStream; const Str: AnsiString): Cardinal;
begin
  if Length(Str) > 0 then
    Result := Stream.Write(Str[1], Length(Str))
  else
    Result := 0;
end;

function WriteBytes(Stream: TStream; const Data: TBytes): Cardinal;
begin
  if Length(Data) > 0 then
    Result := Stream.Write(Data[0], Length(Data))
  else
    Result := 0;
end;

function XRefTypeToString(XRefType: TCnPDFXRefType): AnsiString;
begin
  case XRefType of
    xrtFree: Result := 'f';
    xrtNormal: Result := 'n';
    xrtDeleted: Result := 'd';
  else
    Result := 'n';
  end;
end;

{ TCnPDFTrailer }

constructor TCnPDFTrailer.Create;
begin
  inherited;
  FDictionary := TCnPDFDictionaryObject.Create;
end;

destructor TCnPDFTrailer.Destroy;
begin
  FDictionary.Free;
  inherited;
end;

function TCnPDFTrailer.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  Inc(Result, WriteLine(Stream, TRAILER));
  Inc(Result, FDictionary.WriteToStream(Stream));
  Inc(Result, WriteLine(Stream, STARTXREF));
  Inc(Result, WriteLine(Stream, IntToStr(FXRefStart)));
  Inc(Result, WriteLine(Stream, EOF));
end;

{ TCnPDFXRefCollection }

function TCnPDFXRefCollection.Add: TCnPDFXRefItem;
begin
  Result := TCnPDFXRefItem(inherited Add);
end;

constructor TCnPDFXRefCollection.Create;
begin
  inherited Create(TCnPDFXRefItem);
end;

destructor TCnPDFXRefCollection.Destroy;
begin

  inherited;
end;

function TCnPDFXRefCollection.GetItem(Index: Integer): TCnPDFXRefItem;
begin
  Result := TCnPDFXRefItem(inherited GetItem(Index));
end;

procedure TCnPDFXRefCollection.SetItem(Index: Integer;
  const Value: TCnPDFXRefItem);
begin
  inherited SetItem(Index, Value);
end;

function TCnPDFXRefCollection.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := WriteLine(Stream, Format('%d %d', [FObjectIndex, Count]));
  for I := 0 to Count - 1 do
    Inc(Result, WriteLine(Stream, Format('%10.10d %5.5d %s', [Items[I].ObjectOffset,
      Items[I].ObjectGeneration, XRefTypeToString(Items[I].ObjectXRefType)])));
end;

{ TCnPDFXRefTable }

function TCnPDFXRefTable.AddSegment: TCnPDFXRefCollection;
begin
  Result := TCnPDFXRefCollection.Create;
  FSegments.Add(Result);
end;

procedure TCnPDFXRefTable.Clear;
begin
  FSegments.Clear;
end;

constructor TCnPDFXRefTable.Create;
begin
  inherited;
  FSegments := TObjectList.Create(True);
end;

destructor TCnPDFXRefTable.Destroy;
begin
  FSegments.Free;
  inherited;
end;

function TCnPDFXRefTable.GetSegmenet(Index: Integer): TCnPDFXRefCollection;
begin
  Result := TCnPDFXRefCollection(FSegments[Index]);
end;

function TCnPDFXRefTable.GetSegmentCount: Integer;
begin
  Result := FSegments.Count;
end;

procedure TCnPDFXRefTable.SetSegment(Index: Integer;
  const Value: TCnPDFXRefCollection);
begin
  FSegments[Index] := Value;
end;

function TCnPDFXRefTable.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := WriteLine(Stream, XREF);
  for I := 0 to SegmentCount - 1 do
    Inc(Result, Segments[I].WriteToStream(Stream));
end;

{ TCnPDFParser }

procedure TCnPDFParser.ArrayBeginProc;
begin
  StepRun;
  FTokenID := pttArrayBegin;
end;

procedure TCnPDFParser.ArrayEndProc;
begin
  StepRun;
  FTokenID := pttArrayEnd;
end;

procedure TCnPDFParser.BlankProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in WHITESPACES);
  FTokenID := pttBlank;
end;

procedure TCnPDFParser.CommentProc;
begin
  repeat
    StepRun;
  until (FOrigin[FRun] in [#13, #10]);
  FTokenID := pttComment;
end;

constructor TCnPDFParser.Create;
begin
  inherited;
  MakeMethodTable;
end;

procedure TCnPDFParser.CRLFProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in [#13, #10]);
  FTokenID := pttLineBreak;
end;

destructor TCnPDFParser.Destroy;
begin

  inherited;
end;

procedure TCnPDFParser.LessThanProc;
begin
  StepRun;
  if FOrigin[FRun] = '<' then
  begin
    StepRun;
    FTokenID := pttDictionaryBegin;
  end
  else
    FTokenID := pttHexStringBegin;
  // Error('Dictionary Begin Corrupt');
end;

procedure TCnPDFParser.GreaterThanProc;
begin
  StepRun;
  if FOrigin[FRun] = '>' then
  begin
    StepRun;
    FTokenID := pttDictionaryEnd;
  end
  else
    FTokenID := pttHexStringEnd;
  // Error('Dictionary End Corrupt');
end;

procedure TCnPDFParser.Error(const Msg: string);
begin
  raise ECnPDFException.CreateFmt('PDF Parse Error at %d: %s', [FRun, Msg]);
end;

function TCnPDFParser.GetToken: AnsiString;
var
  Len: Cardinal;
  OutStr: AnsiString;
begin
  Len := FRun - FTokenPos;                         // ����ƫ����֮���λΪ�ַ���
  SetString(OutStr, (FOrigin + FTokenPos), Len);   // ��ָ���ڴ��ַ�볤�ȹ����ַ���
  Result := OutStr;
end;

function TCnPDFParser.GetTokenLength: Integer;
begin
  Result := FRun - FTokenPos;
end;

procedure TCnPDFParser.KeywordProc;
begin
  FStringLen := 0;
  repeat
    StepRun;
    Inc(FStringLen);
  until not (FOrigin[FRun] in ['a'..'z', 'A'..'Z']); // �ҵ�Сд��ĸ��ϵı�ʶ��β��

  FTokenID := pttUnknown; // ����ô��
  // �Ƚ� endstream endobj stream false null true obj end

  if FStringLen = 9 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'endstream') then
      FTokenID := pttEndStream
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'startxref') then
      FTokenID := pttStartxref
  end
  else if FStringLen = 7 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'trailer') then
      FTokenID := pttTrailer
  end
  else if FStringLen = 6 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'stream') then
      FTokenID := pttStream
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'endobj') then
      FTokenID := pttEndObj
  end
  else if FStringLen = 5 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'false') then
      FTokenID := pttFalse
  end
  else if FStringLen = 4 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'true') then
      FTokenID := pttTrue
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'null') then
      FTokenID := pttNull
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'xref') then
      FTokenID := pttXref;
  end
  else if FStringLen = 3 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'obj') then
      FTokenID := pttObj
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'end') then
      FTokenID := pttEnd;
  end
  else if FStringLen = 1 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'R') then
      FTokenID := pttR
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'n') then
      FTokenID := pttN
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'd') then
      FTokenID := pttD
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'f') then
      FTokenID := pttF
  end;
end;

procedure TCnPDFParser.MakeMethodTable;
var
  I: AnsiChar;
begin
  for I := #0 to #255 do
  begin
    case I of
      '%':
        FProcTable[I] := CommentProc;
      #9, #32:
        FProcTable[I] := BlankProc;
      #10, #13:
        FProcTable[I] := CRLFProc;
      '(':
        FProcTable[I] := StringBeginProc;
      ')':
        FProcTable[I] := StringEndProc;
      '0'..'9', '+', '-':
        FProcTable[I] := NumberProc;
      '[':
        FProcTable[I] := ArrayBeginProc;
      ']':
        FProcTable[I] := ArrayEndProc;
      '<':
        FProcTable[I] := LessThanProc;
      '>':
        FProcTable[I] := GreaterThanProc;
      '/':
        FProcTable[I] := NameBeginProc;
      'f', 'n', 't', 'o', 's', 'e', 'x', 'R':
        FProcTable[I] := KeywordProc;
    else
      FProcTable[I] := UnknownProc;
    end;
  end;
end;

procedure TCnPDFParser.NameBeginProc;
begin
  repeat
    StepRun;
  until FOrigin[FRun] in CRLFS + WHITESPACES + DELIMETERS;
  FTokenID := pttName;
end;

procedure TCnPDFParser.Next;
var
  OldId: TCnPDFTokenType;
begin
  FTokenPos := FRun;
  OldId := FTokenID;

  if (FTokenID = pttStringBegin) and (FOrigin[FRun] <> ')') then
    StringProc
  else if (FTokenID = pttHexStringBegin) and (FOrigin[FRun] <> '>') then
    HexStringProc
  else if (FTokenID = pttLineBreak) and (FPrevNonBlankID = pttStream) then
    StreamDataProc
  else
    FProcTable[FOrigin[FRun]];

  if not (FTokenID in [pttBlank, pttComment]) then // ����һ���ǿջ���
    FPrevNonBlankID := OldId;
end;

procedure TCnPDFParser.NextNoJunk;
begin
  repeat
    Next;
  until not (FTokenID in [pttBlank]);
end;

procedure TCnPDFParser.NumberProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in ['0'..'9', '.']); // ���Ų����ٳ����ˣ�Ҳ���ܳ��� e ���ֿ�ѧ������
  FTokenID := pttNumber;
end;

procedure TCnPDFParser.SetOrigin(const PDFBuf: PAnsiChar; PDFByteSize: Cardinal);
begin
  FOrigin := PDFBuf;
  FRun := 0;
  FByteLength := PDFByteSize;
  Next;
end;

procedure TCnPDFParser.SetRunPos(const Value: Integer);
begin
  FRun := Value;
  Next;
end;

procedure TCnPDFParser.StepRun;
begin
  Inc(FRun);
  if FRun >= FByteLength then
    raise ECnPDFEofException.Create('PDF EOF');
end;

procedure TCnPDFParser.StreamDataProc;
var
  I, OldRun: Integer;
  Es: AnsiString;
begin
  // ��ʼ�����ݣ����س����к��жϺ��Ƿ� endstream
  SetLength(Es, 9);
  repeat
    StepRun;

    if FOrigin[FRun] in [#13, #10] then
    begin
      repeat
        StepRun;
      until not (FOrigin[FRun] in [#13, #10]);

      // ��ǰ���˸����ж��Ƿ� endstream �ؼ��֣������Ƿ�ɹ���������
      OldRun := FRun; // ��¼ԭʼλ��
      for I := 1 to 9 do
      begin
        Es[I] := FOrigin[FRun];
        StepRun;
      end;
      FRun := OldRun; // ����

      if Es = 'endstream' then // ֻ������ endstream ������
        Break;
    end;
  until False;

  FTokenID := pttStreamData;
end;

procedure TCnPDFParser.StringBeginProc;
begin
  StepRun;
  FTokenID := pttStringBegin;
end;

procedure TCnPDFParser.StringEndProc;
begin
  StepRun;
  FTokenID := pttStringEnd;
end;

procedure TCnPDFParser.StringProc;
var
  C: Integer;
begin
  // TODO: �ж�ͷ���ֽ��Ƿ��� UTF16���������ֽ����ֽڶ�ֱ���������� ) ���򵥸���ֱ������ )
  C := 0;
  repeat
    StepRun;
    if FOrigin[FRun - 1] = '\' then
      StepRun
    else if FOrigin[FRun - 1] = '(' then
      Inc(C)
    else if FOrigin[FRun - 1] = ')' then
      Dec(C);
  until (FOrigin[FRun] = ')') and (C = 0);
  FTokenID := pttString;
end;

function TCnPDFParser.TokenEqualStr(Org: PAnsiChar; const Str: AnsiString): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Length(Str) - 1 do
  begin
    if Org[I] <> Str[I + 1] then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure TCnPDFParser.UnknownProc;
begin
  StepRun;
  FTokenID := pttUnknown;
end;

procedure TCnPDFParser.HexStringProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in ['0'..'9', 'a'..'f', 'A'..'F'] + CRLFS + WHITESPACES);
end;

{ TCnPDFHeader }

constructor TCnPDFHeader.Create;
begin
  inherited;
  FVersion := '1.7';
  FComment := '�й�CnPack������';
end;

destructor TCnPDFHeader.Destroy;
begin

  inherited;
end;

function TCnPDFHeader.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteLine(Stream, '%PDF-' + FVersion);
  Inc(Result, WriteLine(Stream, '%' + FComment));
end;

{ TCnPDFObject }

function TCnPDFObject.CheckWriteObjectEnd(Stream: TStream): Cardinal;
begin
  if ID > 0 then
    Result := WriteLine(Stream, ENDOBJ)
  else
    Result := 0;
end;

function TCnPDFObject.CheckWriteObjectStart(Stream: TStream): Cardinal;
begin
  if ID > 0 then
    Result := WriteLine(Stream, Format(OBJFMT, [ID, Generation]))
  else
    Result := 0;
end;

{ TCnPDFDocument }

constructor TCnPDFDocument.Create;
begin
  inherited;
  FHeader := TCnPDFHeader.Create;
  FBody := TCnPDFBody.Create;
  FXRefTable := TCnPDFXRefTable.Create;
  FTrailer := TCnPDFTrailer.Create;

  FBody.XRefTable := FXRefTable;
  FTrailer.Dictionary.AddObjectRef('Root', FBody.Catalog);
  FTrailer.Dictionary.AddObjectRef('Info', FBody.Info);
end;

destructor TCnPDFDocument.Destroy;
begin
  FTrailer.Free;
  FXRefTable.Free;
  FBody.Free;
  FHeader.Free;
  inherited;
end;

procedure TCnPDFDocument.LoadFromFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TCnPDFDocument.LoadFromStream(Stream: TStream);
begin

end;

procedure TCnPDFDocument.SaveToFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TCnPDFDocument.SaveToStream(Stream: TStream);
begin
  FHeader.WriteToStream(Stream);

  FBody.SyncPages;
  FBody.WriteToStream(Stream);

  FTrailer.XRefStart := Stream.Position;
  FXRefTable.WriteToStream(Stream);

  FTrailer.Dictionary.Values['Size'] := TCnPDFNumberObject.Create(FBody.Objects.CurrentID + 1);
  FTrailer.WriteToStream(Stream);
end;

{ TCnPDFDictPair }

procedure TCnPDFDictPair.ChangeToArray;
var
  Arr: TCnPDFArrayObject;
begin
  if not (FValue is TCnPDFArrayObject) then
  begin
    Arr := TCnPDFArrayObject.Create;
    if FValue <> nil then
      Arr.AddObject(FValue);
    FValue := Arr;
  end;
end;

constructor TCnPDFDictPair.Create(const Name: string);
begin
  inherited Create;
  FName := TCnPDFNameObject.Create(Name);
end;

destructor TCnPDFDictPair.Destroy;
begin
  FName.Free;
  FValue.Free; // ������û���ã���Ϊ nil����Ӱ��
  inherited;
end;

function TCnPDFDictPair.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteString(Stream, CRLF);
  Inc(Result, FName.WriteToStream(Stream));
  Inc(Result, WriteSpace(Stream));
  if FValue <> nil then
    Inc(Result, FValue.WriteToStream(Stream));
end;

{ TCnPDFNameObject }

function TCnPDFNameObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteString(Stream, '/' + BytesToAnsi(Content));
end;

{ TCnPDFDictionaryObject }

function TCnPDFDictionaryObject.AddAnsiString(const Name: string;
  const Value: AnsiString): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFStringObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddArray(const Name: string): TCnPDFArrayObject;
var
  Pair: TCnPDFDictPair;
begin
  Pair := AddName(Name);
  Result := TCnPDFArrayObject.Create;
  Pair.Value := Result;
end;

function TCnPDFDictionaryObject.AddDictionary(const Name: string): TCnPDFDictionaryObject;
var
  Pair: TCnPDFDictPair;
begin
  Pair := AddName(Name);
  Result := TCnPDFDictionaryObject.Create;
  Pair.Value := Result;
end;

function TCnPDFDictionaryObject.AddFalse(const Name: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFBooleanObject.Create(False);
end;

function TCnPDFDictionaryObject.AddName(const Name: string): TCnPDFDictPair;
begin
  Result := TCnPDFDictPair.Create(Name);
  FPairs.Add(Result);
end;

function TCnPDFDictionaryObject.AddName(const Name1,
  Name2: string): TCnPDFDictPair;
begin
  Result := TCnPDFDictPair.Create(Name1);
  Result.Value := TCnPDFNameObject.Create(Name2);
  FPairs.Add(Result);
end;

function TCnPDFDictionaryObject.AddNull(const Name: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNullObject.Create;
end;

function TCnPDFDictionaryObject.AddNumber(const Name: string;
  Value: Int64): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNumberObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddNumber(const Name: string;
  Value: Integer): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNumberObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddNumber(const Name: string;
  Value: Extended): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNumberObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddObjectRef(const Name: string;
  Obj: TCnPDFObject): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFReferenceObject.Create(Obj);
end;

function TCnPDFDictionaryObject.AddString(const Name,
  Value: string): TCnPDFDictPair;
begin
{$IFDEF UNICODE}
  Result := AddUnicodeString(Name, Value);
{$ELSE}
  Result := AddAnsiString(Name, Value);
{$ENDIF}
end;

function TCnPDFDictionaryObject.AddTrue(const Name: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFBooleanObject.Create(True);
end;

{$IFDEF UNICODE}

function TCnPDFDictionaryObject.AddUnicodeString(const Name,
  Value: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFStringObject.Create(Value);
end;

{$ENDIF}

function TCnPDFDictionaryObject.AddWideString(const Name: string;
  const Value: WideString): TCnPDFDictPair;
begin
  Result := AddName(Name);
{$IFDEF COMPILER5}
  Result.Value := TCnPDFStringObject.CreateW(Value);
{$ELSE}
  Result.Value := TCnPDFStringObject.Create(Value);
{$ENDIF}
end;

procedure TCnPDFDictionaryObject.Clear;
begin
  FPairs.Clear;
end;

constructor TCnPDFDictionaryObject.Create;
begin
  inherited;
  FPairs := TObjectList.Create(True);
end;

destructor TCnPDFDictionaryObject.Destroy;
begin
  FPairs.Free;
  inherited;
end;

function TCnPDFDictionaryObject.GetCount: Integer;
begin
  Result := FPairs.Count;
end;

function TCnPDFDictionaryObject.GetValue(const Name: string): TCnPDFObject;
var
  Idx: Integer;
begin
  Idx := IndexOfName(Name);
  if Idx >= 0 then
    Result := TCnPDFDictPair(FPairs[Idx]).Value
  else
    Result := nil;
end;

function TCnPDFDictionaryObject.IndexOfName(const Name: string): Integer;
var
  I: Integer;
  Pair: TCnPDFDictPair;
  S: string;
begin
  for I := 0 to FPairs.Count - 1 do
  begin
    Pair := TCnPDFDictPair(FPairs[I]);
    S := string(BytesToAnsi(Pair.Name.Content));

    if S = Name then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPDFDictionaryObject.SetValue(const Name: string;
  const Value: TCnPDFObject);
var
  Idx: Integer;
  Pair: TCnPDFDictPair;
begin
  Idx := IndexOfName(Name);
  if Idx >= 0 then
  begin
    if TCnPDFDictPair(FPairs[Idx]).Value <> nil then
      TCnPDFDictPair(FPairs[Idx]).Value.Free;
    TCnPDFDictPair(FPairs[Idx]).Value := Value;
  end
  else
  begin
    Pair := AddName(Name);
    Pair.Value := Value;
  end;
end;

function TCnPDFDictionaryObject.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  Inc(Result, CheckWriteObjectStart(Stream));
  if FPairs.Count <= 0 then
  begin
    Inc(Result, WriteString(Stream, '<<>>'));
    Exit;
  end;

  Inc(Result, WriteString(Stream, '<<'));
  for I := 0 to FPairs.Count - 1 do
  begin
    Inc(Result, (FPairs[I] as TCnPDFDictPair).WriteToStream(Stream));
    // Inc(Result, WriteCRLF(Stream));
  end;
  Inc(Result, WriteCRLF(Stream));
  Inc(Result, WriteLine(Stream, '>>'));
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

{ TCnPDFArrayObject }

procedure TCnPDFArrayObject.AddAnsiString(const Value: AnsiString);
begin
  AddObject(TCnPDFStringObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddFalse;
begin
  AddObject(TCnPDFBooleanObject.Create(False));
end;

procedure TCnPDFArrayObject.AddNul;
begin
  AddObject(TCnPDFNullObject.Create);
end;

procedure TCnPDFArrayObject.AddNumber(Value: Extended);
begin
  AddObject(TCnPDFNumberObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddNumber(Value: Integer);
begin
  AddObject(TCnPDFNumberObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddNumber(Value: Int64);
begin
  AddObject(TCnPDFNumberObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddObject(Obj: TCnPDFObject);
begin
  FElements.Add(Obj);
end;

procedure TCnPDFArrayObject.AddObjectRef(Obj: TCnPDFObject);
begin
  AddObject(TCnPDFReferenceObject.Create(Obj));
end;

procedure TCnPDFArrayObject.AddTrue;
begin
  AddObject(TCnPDFBooleanObject.Create(True));
end;

{$IFDEF UNICODE}

procedure TCnPDFArrayObject.AddUnicodeString(const Value: string);
begin
  AddObject(TCnPDFStringObject.Create(Value));
end;

{$ENDIF}

procedure TCnPDFArrayObject.AddWideString(const Value: WideString);
begin
  AddObject(TCnPDFStringObject.Create(Value));
end;

procedure TCnPDFArrayObject.Clear;
begin
  FElements.Clear;
end;

constructor TCnPDFArrayObject.Create;
begin
  inherited;
  FElements := TObjectList.Create(True);
end;

destructor TCnPDFArrayObject.Destroy;
begin
  FElements.Free;
  inherited;
end;

function TCnPDFArrayObject.GetCount: Integer;
begin
  Result := FElements.Count;
end;

function TCnPDFArrayObject.GetItem(Index: Integer): TCnPDFObject;
begin
  Result := TCnPDFObject(FElements[Index]);
end;

procedure TCnPDFArrayObject.SetItem(Index: Integer;
  const Value: TCnPDFObject);
begin
  FElements[Index] := Value;
end;

function TCnPDFArrayObject.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  Inc(Result, CheckWriteObjectStart(Stream));
  Inc(Result, WriteString(Stream, '['));
  for I := 0 to FElements.Count - 1 do
  begin
    Inc(Result, (FElements[I] as TCnPDFObject).WriteToStream(Stream));
    if I < FElements.Count - 1 then
      Inc(Result, WriteSpace(Stream));
  end;
  Inc(Result, WriteString(Stream, ']'));
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

{ TCnPDFSimpleObject }

constructor TCnPDFSimpleObject.Create(const AContent: AnsiString);
begin
  inherited Create;
  FContent := AnsiToBytes(AContent);
end;

constructor TCnPDFSimpleObject.Create(const Data: TBytes);
begin
  inherited Create;
  if Length(Data) > 0 then
    FContent := NewBytesFromMemory(@Data[0], Length(Data));
end;

function TCnPDFSimpleObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  Inc(Result, CheckWriteObjectStart(Stream));
  Inc(Result, WriteBytes(Stream, Content));
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

{ TCnPDFReferenceObject }

constructor TCnPDFReferenceObject.Create(Obj: TCnPDFObject);
begin
  inherited Create('');
  FRef := Obj;
end;

destructor TCnPDFReferenceObject.Destroy;
begin

  inherited;
end;

function TCnPDFReferenceObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  if FRef <> nil then
  begin
    Inc(Result, WriteString(Stream, IntToStr(FRef.ID)));
    Inc(Result, WriteSpace(Stream));
    Inc(Result, WriteString(Stream, IntToStr(FRef.Generation)));
    Inc(Result, WriteSpace(Stream));
    Inc(Result, WriteString(Stream, 'R'));
  end;
end;

{ TCnPDFBooleanObject }

constructor TCnPDFBooleanObject.Create(IsTrue: Boolean);
begin
  if IsTrue then
    inherited Create('true')
  else
    inherited Create('false');
end;

{ TCnPDFNullObject }

constructor TCnPDFNullObject.Create;
begin
  inherited Create('null');
end;

{ TCnPDFStringObject }

constructor TCnPDFStringObject.Create(const AnsiStr: AnsiString);
begin
  inherited Create(AnsiStr);
end;

{$IFDEF COMPILER5}

constructor TCnPDFStringObject.CreateW(const WideStr: WideString);
begin
  if Length(WideStr) > 0 then
  begin
    SetLength(FContent, Length(WideStr) * SizeOf(WideChar) + 2);
    Move(SCN_BOM_UTF16_LE[0], FContent[0], SizeOf(SCN_BOM_UTF16_LE));
    Move(WideStr[1], FContent[2], Length(WideStr) * SizeOf(WideChar));
  end;
end;

{$ELSE}

constructor TCnPDFStringObject.Create(const WideStr: WideString);
begin
  if Length(WideStr) > 0 then
  begin
    SetLength(FContent, Length(WideStr) * SizeOf(WideChar) + 2);
    Move(SCN_BOM_UTF16_LE[0], FContent[0], SizeOf(SCN_BOM_UTF16_LE));
    Move(WideStr[1], FContent[2], Length(WideStr) * SizeOf(WideChar));
  end;
end;

{$ENDIF}

{$IFDEF UNICODE}

constructor TCnPDFStringObject.Create(const UnicodeStr: string);
begin
  if Length(UnicodeStr) > 0 then
  begin
    SetLength(FContent, Length(UnicodeStr) * SizeOf(WideChar) + 2);
    Move(SCN_BOM_UTF16_LE[0], FContent[0], SizeOf(SCN_BOM_UTF16_LE));
    Move(UnicodeStr[1], FContent[2], Length(UnicodeStr) * SizeOf(WideChar));
  end;
end;

{$ENDIF}

function TCnPDFStringObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  Inc(Result, WriteString(Stream, '('));
  Inc(Result, WriteBytes(Stream, Content));
  Inc(Result, WriteString(Stream, ')'));
end;

{ TCnPDFStreamObject }

constructor TCnPDFStreamObject.Create;
begin
  inherited;
  FDictionary := TCnPDFDictionaryObject.Create;
end;

destructor TCnPDFStreamObject.Destroy;
begin
  SetLength(FStream, 0);
  FDictionary.Free;
  inherited;
end;

procedure TCnPDFStreamObject.SetJpegImage(const JpegFileName: string);
var
  F: TFileStream;
  S: Int64;
  J: TJPEGImage;
begin
  if FileExists(JpegFileName) then
  begin
    FDictionary.Clear;

    FDictionary.AddName('Type', 'XObject');
    FDictionary.AddName('Subtype', 'Image');
    FDictionary.AddNumber('BitsPerComponent', 8);
    FDictionary.AddName('ColorSpace', 'DeviceRGB');
    FDictionary.AddName('Filter', 'DCTDecode');

    J := TJPEGImage.Create;
    try
      J.LoadFromFile(JpegFileName);
      FDictionary.AddNumber('Height', J.Height);
      FDictionary.AddNumber('Width', J.Width);
    finally
      J.Free;
    end;

    F := TFileStream.Create(JpegFileName, fmOpenRead or fmShareDenyWrite);
    try
      S := F.Size;
      FDictionary.AddNumber('Length', S);
      SetLength(FStream, S);

      F.Read(FStream[0], S);
    finally
      F.Free;
    end;
  end;
end;

function TCnPDFStreamObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  if FDictionary <> nil then
    Inc(Result, FDictionary.WriteToStream(Stream));

  Inc(Result, WriteLine(Stream, BEGINSTREAM));
  if Length(FStream) > 0 then
    Inc(Result, Stream.Write(FStream[0], Length(FStream)));

  Inc(Result, WriteCRLF(Stream));
  Inc(Result, WriteLine(Stream, ENDSTREAM));
end;

{ TCnPDFBody }

function TCnPDFBody.AddContent(Page: TCnPDFDictionaryObject): TCnPDFStreamObject;
begin
  Result := TCnPDFStreamObject.Create;
  FObjects.Add(Result);
  Page['/Contents'] := TCnPDFReferenceObject.Create(Result);
end;

procedure TCnPDFBody.AddObject(Obj: TCnPDFObject);
begin
  FObjects.Add(Obj);
end;

function TCnPDFBody.AddPage: TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject.Create;
  Result['Parent'] := TCnPDFReferenceObject.Create(FPages);
  Result['Resources'] := TCnPDFDictionaryObject.Create;

  FObjects.Add(Result);
  FPageList.Add(Result);
end;

function TCnPDFBody.AddResource(Page: TCnPDFDictionaryObject): TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject.Create;
  FObjects.Add(Result);
  Page['/Resources'] := TCnPDFReferenceObject.Create(Result);
end;

procedure TCnPDFBody.ArrangeIDs;
var
  I: Integer;
begin
  for I := 0 to FObjects.Count - 1 do
    TCnPDFObject(FObjects[I]).ID := I + 1;
end;

constructor TCnPDFBody.Create;
begin
  inherited;
  FObjects := TCnPDFObjectManager.Create;

  FInfo := TCnPDFDictionaryObject.Create;
  FObjects.Add(FInfo);
  FCatalog := TCnPDFDictionaryObject.Create;
  FCatalog.AddName('Type', 'Catalog');
  FObjects.Add(FCatalog);

  FPages := TCnPDFDictionaryObject.Create;
  FPages.AddName('Type', 'Pages');
  FObjects.Add(FPages);

  FPages.AddArray('Kids');
  FCatalog.AddObjectRef('Pages', FPages);

  FPageList := TObjectList.Create(False);
  FContentList := TObjectList.Create(False);
  FResourceList := TObjectList.Create(False);
end;

destructor TCnPDFBody.Destroy;
begin
  FResourceList.Free;
  FContentList.Free;
  FPageList.Free;

  FObjects.Free;
  inherited;
end;

function TCnPDFBody.GetPage(Index: Integer): TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject(FPageList[Index]);
end;

function TCnPDFBody.GetPageCount: Integer;
begin
  Result := FPageList.Count;
end;

function PDFObjectCompare(Item1, Item2: Pointer): Integer;
var
  P1, P2: TCnPDFObject;
begin
  P1 := TCnPDFObject(Item1);
  P2 := TCnPDFObject(Item2);
  Result := P1.ID - P2.ID;
end;

procedure TCnPDFBody.SortObjects;
begin
  FObjects.Sort(PDFObjectCompare);
end;

procedure TCnPDFBody.SyncPages;
var
  I: Integer;
  Arr: TCnPDFArrayObject;
begin
  FPages['Count'] := TCnPDFNumberObject.Create(FPageList.Count);
  Arr := FPages['Kids'] as TCnPDFArrayObject;

  for I := 0 to FPageList.Count - 1 do
    Arr.AddObjectRef(FPageList[I] as TCnPDFObject);
end;

function TCnPDFBody.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
  OldID: Int64;
  Obj: TCnPDFObject;
  Collection: TCnPDFXRefCollection;
  Item: TCnPDFXRefItem;
begin
  FXRefTable.Clear;
  SortObjects;

  Result := 0;
  OldID := -1;
  Collection := nil;

  for I := 0 to FObjects.Count - 1 do
  begin
    Obj := TCnPDFObject(FObjects[I]);
    if Obj.ID > OldID + 1 then
    begin
      // ���� Segment����� Index Ϊ�� Obj.ID
      Collection := FXRefTable.AddSegment;
      Collection.ObjectIndex := Obj.ID;
    end
    else if Obj.ID = OldID + 1 then
    begin
      // ���ڱ� Segment��
    end;

    // �þ� Collection ���� Collection �½� Item
    Item := Collection.Add;
    Item.ObjectGeneration := Obj.Generation;
    Item.ObjectXRefType := Obj.XRefType;
    Item.ObjectOffset := Stream.Position;

    // ���� ID
    OldID := Obj.ID;

    Inc(Result, Obj.WriteToStream(Stream));
  end;
end;

{ TCnPDFObjectManger }

function TCnPDFObjectManager.Add(AObject: TCnPDFObject): Integer;
begin
  Result := inherited Add(AObject);
  Inc(FCurrentID);
  AObject.ID := FCurrentID;
end;

constructor TCnPDFObjectManager.Create;
begin
  inherited Create(True);
end;

function TCnPDFObjectManager.GetItem(Index: Integer): TCnPDFObject;
begin
  Result := TCnPDFObject(inherited GetItem(Index));
end;

procedure TCnPDFObjectManager.SetItem(Index: Integer;
  const Value: TCnPDFObject);
begin
  inherited SetItem(Index, Value);
  Inc(FCurrentID);
  Value.ID := FCurrentID;
end;

{ TCnPDFNumberObject }

constructor TCnPDFNumberObject.Create(Num: Integer);
begin
  inherited Create(AnsiString(IntToStr(Num)));
end;

constructor TCnPDFNumberObject.Create(Num: Int64);
begin
  inherited Create(AnsiString(IntToStr(Num)));
end;

constructor TCnPDFNumberObject.Create(Num: Extended);
begin
  inherited Create(AnsiString(FloatToStr(Num)));
end;

end.
