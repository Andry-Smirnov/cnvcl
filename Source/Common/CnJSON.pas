{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2023 CnPack ������                       }
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

unit CnJSON;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�JSON ��������װ��Ԫ�������� DXE6 ������ JSON ������ĳ���
* ��Ԫ���ߣ�CnPack ������ Liu Xiao
* ��    ע���ʺ� UTF8 ��ע�͸�ʽ������ RFC 7159 ������
* ����ƽ̨��PWinXP + Delphi 7
* ���ݲ��ԣ�PWinXP/7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2023.09.15 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Contnrs, TypInfo, CnStrings;

type
  ECnJSONException = class(Exception);
  {* JSON ��������쳣}

  TCnJSONTokenType = (jttObjectBegin, jttObjectEnd, jttArrayBegin, jttArrayEnd,
    jttNameValueSep, jttElementSep, jttNumber, jttString, jttNull, jttTrue,
    jttFalse, jttBlank, jttTerminated, jttUnknown);
  {* JSON �еķ������ͣ���Ӧ������š��Ҵ����š��������š��������š��ֺš����š�
    ���֡�˫�����ַ�����null��true��false���ո�س���#0��}

  TCnJSONParser = class
  {* UTF8 ��ʽ����ע�͵� JSON �ַ���������}
  private
    FRun: Integer;
    FTokenPos: Integer;
    FOrigin: PAnsiChar;
    FStringLen: Integer; // ��ǰ�ַ������ַ�����
    FProcTable: array[#0..#255] of procedure of object;
    FTokenID: TCnJSONTokenType;

    procedure KeywordProc;               // null true false ���ʶ��
    procedure ObjectBeginProc;           // {
    procedure ObjectEndProc;             // }
    procedure ArrayBeginProc;            // []
    procedure ArrayEndProc;              // ]
    procedure NameValueSepProc;          // :
    procedure ArrayElementSepProc;       // ,
    procedure StringProc;                // ˫����
    procedure NumberProc;                // ����
    procedure BlankProc;                 // �ո� Tab �س���
    procedure TerminateProc;             // #0
    procedure UnknownProc;               // δ֪
    function GetToken: AnsiString;
    procedure SetOrigin(const Value: PAnsiChar);
    procedure SetRunPos(const Value: Integer);
    function GetTokenLength: Integer;
  protected
    function TokenEqualStr(Org: PAnsiChar; const Str: AnsiString): Boolean;
    procedure MakeMethodTable;
    procedure StepRun; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
    procedure StepBOM;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Next;
    {* ������һ�� Token ��ȷ�� TokenID}
    procedure NextNoJunk;
    {* ������һ���� Null �Լ��ǿո� Token ��ȷ�� TokenID}

    property Origin: PAnsiChar read FOrigin write SetOrigin;
    {* �������� UTF8 ��ʽ�� JSON �ַ�������}
    property RunPos: Integer read FRun write SetRunPos;
    {* ��ǰ����λ������� FOrigin ������ƫ��������λΪ�ֽ�����0 ��ʼ}
    property TokenID: TCnJSONTokenType read FTokenID;
    {* ��ǰ Token ����}
    property Token: AnsiString read GetToken;
    {* ��ǰ Token �� UTF8 �ַ������ݲ���������}
    property TokenLength: Integer read GetTokenLength;
    {* ��ǰ Token ���ֽڳ���}
  end;

  TCnJSONString = class;

  TCnJSONBase = class
  private
    FParent: TCnJSONBase;
  public
    function AddChild(AChild: TCnJSONBase): TCnJSONBase; virtual;
    function ToJSON(UseFormat: Boolean = True; Indent: Integer = 0): string; virtual; abstract;
    property Parent: TCnJSONBase read FParent write FParent;
  end;

  TCnJSONValue = class(TCnJSONBase)
  private
    FContent: AnsiString;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToJSON(UseFormat: Boolean = True; Indent: Integer = 0): string; override;

    function IsObject: Boolean; virtual;
    function IsArray: Boolean; virtual;
    function IsString: Boolean; virtual;
    function IsNumber: Boolean; virtual;
    function IsNull: Boolean; virtual;
    function IsTrue: Boolean; virtual;
    function IsFalse: Boolean; virtual;

    property Content: AnsiString read FContent write FContent;
  end;

{
  object = begin-object [ member *( value-separator member ) ]
           end-object

  member = string name-separator value
}
  TCnJSONObject = class(TCnJSONValue)
  private
    FPairs: TObjectList;
    function GetCount: Integer;
    function GetName(Index: Integer): TCnJSONString;
    function GetValue(Index: Integer): TCnJSONValue;
  public
    constructor Create; override;
    destructor Destroy; override;

    function AddChild(AChild: TCnJSONBase): TCnJSONBase; override; // ��� Pair
    function ToJSON(UseFormat: Boolean = True; Indent: Integer = 0): string; override;

    function IsObject: Boolean; override;

    property Count: Integer read GetCount;
    {* �ж��ٸ� Name Value ��}
    property Names[Index: Integer]: TCnJSONString read GetName;
    property Values[Index: Integer]: TCnJSONValue read GetValue;
  end;

{
  string = quotation-mark *char quotation-mark
}
  TCnJSONString = class(TCnJSONValue)
  private

  public
    function IsString: Boolean; override;
  end;

  TCnJSONNumber = class(TCnJSONValue)
  private

  public
    function IsNumber: Boolean; override;
  end;

  TCnJSONNull = class(TCnJSONValue)
  private

  public
    function IsNull: Boolean; override;
  end;

  TCnJSONTrue = class(TCnJSONValue)
  private

  public
    function IsTrue: Boolean; override;
  end;

  TCnJSONFalse = class(TCnJSONValue)
  private

  public
    function IsFalse: Boolean; override;
  end;

{
  array = begin-array [ value *( value-separator value ) ] end-array
}
  TCnJSONArray = class(TCnJSONValue)
  private
    FValues: TObjectList;
    function GetCount: Integer;
    function GetValues(Index: Integer): TCnJSONValue;
  public
    constructor Create; override;
    destructor Destroy; override;

    function AddChild(AChild: TCnJSONBase): TCnJSONBase; override;
    // ��� Value ��Ϊ����Ԫ��

    function ToJSON(UseFormat: Boolean = True; Indent: Integer = 0): string; override;

    property Count: Integer read GetCount;
    property Values[Index: Integer]: TCnJSONValue read GetValues;
  end;

  TCnJSONPair = class(TCnJSONBase)
  private
    FName: TCnJSONString;
    FValue: TCnJSONValue;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddChild(AChild: TCnJSONBase): TCnJSONBase; override;
    // ���� Value ��Ϊ Value

    function ToJSON(UseFormat: Boolean = True; Indent: Integer = 0): string; override;

    property Name: TCnJSONString read FName;
    {* ����������}
    property Value: TCnJSONValue read FValue;
    {* ֵ���ⲿ���������ã������ͷ�}
  end;

function CnJSONParse(const JsonStr: AnsiString): TCnJSONObject;
{* ���� UTF8 ��ʽ�� JSON �ַ���Ϊ JSON ����}

implementation

const
  CN_BLANK_CHARSET: set of AnsiChar = [#9, #10, #13, #32]; // RFC �淶��ֻ�����⼸����Ϊ�հ׷�
  CN_INDENT_DELTA = 4; // ���ʱ�������ո�
  CRLF = #13#10;

resourcestring
  SCnErrorJSONTokenFmt = 'JSON Token %s Expected at Offset %d';
  SCnErrorJSONValueFmt = 'JSON Value Error %s at Offset %d';
  SCnErrorJSONPair = 'JSON Pair Value Conflict';

// ע�⣬ÿ�� JSONParseXXXX ����ִ�����P �� TokenID ��ָ�����Ԫ�غ���ڵķǿ�Ԫ��

function JSONParseValue(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONValue; forward;

function JSONParseObject(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONObject; forward;

procedure JSONCheckToken(P: TCnJSONParser; ExpectedToken: TCnJSONTokenType);
begin
  if P.TokenID <> ExpectedToken then
    raise ECnJSONException.CreateFmt(SCnErrorJSONTokenFmt,
      [GetEnumName(TypeInfo(TCnJSONTokenType), Ord(ExpectedToken)), P.RunPos]);
end;

// �����������ַ���ʱ���ã�Current ���ⲿ�ĸ�����
function JSONParseString(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONString;
begin
  Result := TCnJSONString.Create;
  Result.Content := P.Token;
  Current.AddChild(Result);
  P.NextNoJunk;
end;

// ��������������ʱ���ã�Current ���ⲿ�ĸ�����
function JSONParseNumber(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONNumber;
begin
  Result := TCnJSONNumber.Create;
  Result.Content := P.Token;
  Current.AddChild(Result);
  P.NextNoJunk;
end;

// ���������� null ʱ���ã�Current ���ⲿ�ĸ�����
function JSONParseNull(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONNull;
begin
  Result := TCnJSONNull.Create;
  Result.Content := P.Token;
  Current.AddChild(Result);
  P.NextNoJunk;
end;

// ���������� true ʱ���ã�Current ���ⲿ�ĸ�����
function JSONParseTrue(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONTrue;
begin
  Result := TCnJSONTrue.Create;
  Result.Content := P.Token;
  Current.AddChild(Result);
  P.NextNoJunk;
end;

// ���������� false ʱ���ã�Current ���ⲿ�ĸ�����
function JSONParseFalse(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONFalse;
begin
  Result := TCnJSONFalse.Create;
  Result.Content := P.Token;
  Current.AddChild(Result);
  P.NextNoJunk;
end;

// �������������鿪ʼ���� [ ʱ���ã�Current ���ⲿ�ĸ�����
function JSONParseArray(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONArray;
begin
  Result := TCnJSONArray.Create;
  P.NextNoJunk;

  Current.AddChild(Result);
  while P.TokenID <> jttTerminated do
  begin
    JSONParseValue(P, Result);
    if P.TokenID = jttElementSep then
    begin
      P.NextNoJunk;
      Continue;
    end
    else
      Break;
  end;

  JSONCheckToken(P, jttArrayEnd);
  P.NextNoJunk;
end;

function JSONParseValue(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONValue;
begin
  case P.TokenID of
    jttObjectBegin:
      Result := JSONParseObject(P, Current);
    jttString:
      Result := JSONParseString(P, Current);
    jttNumber:
      Result := JSONParseNumber(P, Current);
    jttArrayBegin:
      Result := JSONParseArray(P, Current);
    jttNull:
      Result := JSONParseNull(P, Current);
    jttTrue:
      Result := JSONParseTrue(P, Current);
    jttFalse:
      Result := JSONParseFalse(P, Current);
  else
    raise ECnJSONException.CreateFmt(SCnErrorJSONValueFmt,
      [GetEnumName(TypeInfo(TCnJSONTokenType), Ord(P.TokenID)), P.RunPos]);
  end;
end;

// ���������� { ʱ���ã�Ҫ�� Current ���ⲿ������ JSONObject ����
function JSONParseObject(P: TCnJSONParser; Current: TCnJSONBase): TCnJSONObject;
var
  Pair: TCnJSONPair;
begin
  Result := TCnJSONObject.Create;
  P.NextNoJunk;
  if Current <> nil then
    Current.AddChild(Result);

  while P.TokenID <> jttTerminated do
  begin
    // ����һ�� String
    JSONCheckToken(P, jttString);

    Pair := TCnJSONPair.Create;
    Pair.Name.Content := P.Token;            // ���á�Pair ���е� Name ������
    Result.AddChild(Pair);

    // ����һ��ð��
    P.NextNoJunk;
    JSONCheckToken(P, jttNameValueSep);

    P.NextNoJunk;
    JSONParseValue(P, Pair);
    // ����һ�� Value

    if P.TokenID = jttElementSep then        // �ж��ŷָ���˵������һ�� Key Value ��
    begin
      P.NextNoJunk;
      Continue;
    end
    else
      Break;
  end;

  JSONCheckToken(P, jttObjectEnd);
  P.NextNoJunk;
end;

function CnJSONParse(const JsonStr: AnsiString): TCnJSONObject;
var
  P: TCnJSONParser;
begin
  Result := nil;
  P := TCnJSONParser.Create;
  try
    P.SetOrigin(PAnsiChar(JsonStr));

    while P.TokenID <> jttTerminated do
    begin
      if P.TokenID = jttObjectBegin then
      begin
        Result := JSONParseObject(P, nil);
        Exit;
      end;

      P.NextNoJunk;
    end;
  finally
    P.Free;
  end;
end;

{ TCnJSONParser }

procedure TCnJSONParser.ArrayBeginProc;
begin
  StepRun;
  FTokenID := jttArrayBegin;
end;

procedure TCnJSONParser.ArrayElementSepProc;
begin
  StepRun;
  FTokenID := jttElementSep;
end;

procedure TCnJSONParser.ArrayEndProc;
begin
  StepRun;
  FTokenID := jttArrayEnd;
end;

procedure TCnJSONParser.BlankProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in CN_BLANK_CHARSET);
  FTokenID := jttBlank;
end;

constructor TCnJSONParser.Create;
begin
  inherited Create;
  MakeMethodTable;
end;

destructor TCnJSONParser.Destroy;
begin

  inherited;
end;

function TCnJSONParser.GetToken: AnsiString;
var
  Len: Cardinal;
  OutStr: AnsiString;
begin
  Len := FRun - FTokenPos;                         // ����ƫ����֮���λΪ�ַ���
  SetString(OutStr, (FOrigin + FTokenPos), Len);   // ��ָ���ڴ��ַ�볤�ȹ����ַ���
  Result := OutStr;
end;

function TCnJSONParser.GetTokenLength: Integer;
begin
  Result := FRun - FTokenPos;
end;

procedure TCnJSONParser.KeywordProc;
begin
  FStringLen := 0;
  repeat
    StepRun;
    Inc(FStringLen);
  until not (FOrigin[FRun] in ['a'..'z']); // �ҵ�Сд��ĸ��ϵı�ʶ��β��

  FTokenID := jttUnknown; // ����ô��
  if (FStringLen = 5) and TokenEqualStr(FOrigin + FRun - FStringLen, 'false') then
    FTokenID := jttFalse
  else if FStringLen = 4 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'true') then
      FTokenID := jttTrue
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'null') then
      FTokenID := jttNull;
  end;
end;

procedure TCnJSONParser.MakeMethodTable;
var
  I: AnsiChar;
begin
  for I := #0 to #255 do
  begin
    case I of
      #0:
        FProcTable[I] := TerminateProc;
      #9, #10, #13, #32:
        FProcTable[I] := BlankProc;
      '"':
        FProcTable[I] := StringProc;
      '0'..'9', '+', '-':
        FProcTable[I] := NumberProc;
      '{':
        FProcTable[I] := ObjectBeginProc;
      '}':
        FProcTable[I] := ObjectEndProc;
      '[':
        FProcTable[I] := ArrayBeginProc;
      ']':
        FProcTable[I] := ArrayEndProc;
      ':':
        FProcTable[I] := NameValueSepProc;
      ',':
        FProcTable[I] := ArrayElementSepProc;
      'f', 'n', 't':
        FProcTable[I] := KeywordProc;
    else
      FProcTable[I] := UnknownProc;
    end;
  end;
end;

procedure TCnJSONParser.NameValueSepProc;
begin
  StepRun;
  FTokenID := jttNameValueSep;
end;

procedure TCnJSONParser.Next;
begin
  FTokenPos := FRun;
  FProcTable[FOrigin[FRun]];
end;

procedure TCnJSONParser.NextNoJunk;
begin
  repeat
    Next;
  until not (FTokenID in [jttBlank]);
end;

procedure TCnJSONParser.NumberProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in ['0'..'9', '.', 'e', 'E']); // ���Ų����ٳ����ˣ��ܳ��� e ���ֿ�ѧ������
  FTokenID := jttNumber;
end;

procedure TCnJSONParser.ObjectBeginProc;
begin
  StepRun;
  FTokenID := jttObjectBegin;
end;

procedure TCnJSONParser.ObjectEndProc;
begin
  StepRun;
  FTokenID := jttObjectEnd;
end;

procedure TCnJSONParser.SetOrigin(const Value: PAnsiChar);
begin
  FOrigin := Value;
  FRun := 0;
  StepBOM;
  Next;
end;

procedure TCnJSONParser.SetRunPos(const Value: Integer);
begin
  FRun := Value;
  Next;
end;

procedure TCnJSONParser.StepBOM;
begin
  if (FOrigin[FRun] <> #239) or (FOrigin[FRun + 1] = #0) then
    Exit;
  if (FOrigin[FRun + 1] <> #187) or (FOrigin[FRun + 2] = #0) then
    Exit;
  if FOrigin[FRun + 2] <> #191 then
    Exit;

  Inc(FRun, 3);
end;

procedure TCnJSONParser.StepRun;
begin
  Inc(FRun);
end;

procedure TCnJSONParser.StringProc;
begin
  StepRun;
  FTokenID := jttString;
  // Ҫ���� UTF8 �ַ�����ҲҪ����ת���ַ��� \ ��� " \ / b f n r t u ֱ�������� " Ϊֹ
  while FOrigin[FRun] <> '"' do
  begin
    StepRun;
    if FOrigin[FRun] = '\' then
    begin
      StepRun;
      if FOrigin[FRun] = '"' then   // \" ���⴦���Ա����жϽ������󣬵�Ҫע�� UTF8 �ĺ����ַ����ܳ�������
        StepRun;
    end;
  end;
  StepRun;
end;

procedure TCnJSONParser.TerminateProc;
begin
  FTokenID := jttTerminated;
end;

function TCnJSONParser.TokenEqualStr(Org: PAnsiChar; const Str: AnsiString): Boolean;
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

procedure TCnJSONParser.UnknownProc;
begin
  StepRun;
  FTokenID := jttUnknown;
end;

{ TCnJSONObject }

function TCnJSONObject.AddChild(AChild: TCnJSONBase): TCnJSONBase;
begin
  if AChild is TCnJSONPair then
  begin
    FPairs.Add(AChild);
    Result := AChild;
  end
  else
    Result := nil;
end;

constructor TCnJSONObject.Create;
begin
  inherited;
  FPairs := TObjectList.Create(True);
end;

destructor TCnJSONObject.Destroy;
begin
  FPairs.Free;
  inherited;
end;

function TCnJSONObject.GetCount: Integer;
begin
  Result := FPairs.Count;
end;

function TCnJSONObject.GetName(Index: Integer): TCnJSONString;
begin
  Result := (FPairs[Index] as TCnJSONPair).Name;
end;

function TCnJSONObject.GetValue(Index: Integer): TCnJSONValue;
begin
  Result := (FPairs[Index] as TCnJSONPair).Value;
end;

function TCnJSONObject.IsObject: Boolean;
begin
  Result := True;
end;

function TCnJSONObject.ToJSON(UseFormat: Boolean; Indent: Integer): string;
var
  I: Integer;
  Bld: TCnStringBuilder;
begin
  if Indent < 0 then
    Indent := 0;

  Bld := TCnStringBuilder.Create;
  try
    if UseFormat then
      Bld.Append('{' + CRLF)
    else
      Bld.AppendChar('{');

    for I := 0 to Count - 1 do
    begin
      if UseFormat then
        Bld.Append(StringOfChar(' ', Indent + CN_INDENT_DELTA));

      Bld.Append(Names[I].ToJSON(UseFormat, Indent + CN_INDENT_DELTA));
      Bld.AppendChar(':');
      if UseFormat then
        Bld.AppendChar(' ');
      Bld.Append(Values[I].ToJSON(UseFormat, Indent + CN_INDENT_DELTA));

      if I <> Count - 1 then
      begin
        Bld.AppendChar(',');
        if UseFormat then
          Bld.Append(CRLF);
      end;
    end;

    if UseFormat then
      Bld.Append(CRLF + StringOfChar(' ', Indent) + '}')
    else
      Bld.AppendChar('}');

    Result := Bld.ToString;
  finally
    Bld.Free;
  end;
end;

{ TCnJSONValue }

constructor TCnJSONValue.Create;
begin

end;

destructor TCnJSONValue.Destroy;
begin

  inherited;
end;

function TCnJSONValue.IsArray: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.IsFalse: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.IsNull: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.IsNumber: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.IsObject: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.IsString: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.IsTrue: Boolean;
begin
  Result := False;
end;

function TCnJSONValue.ToJSON(UseFormat: Boolean; Indent: Integer): string;
begin
  Result := FContent;
end;

{ TCnJSONArray }

function TCnJSONArray.AddChild(AChild: TCnJSONBase): TCnJSONBase;
begin
  if AChild is TCnJSONValue then
  begin
    FValues.Add(AChild);
    Result := AChild;
  end
  else
    Result := nil;
end;

constructor TCnJSONArray.Create;
begin
  inherited;
  FValues := TObjectList.Create(True);
end;

destructor TCnJSONArray.Destroy;
begin
  FValues.Free;
  inherited;
end;

function TCnJSONArray.GetCount: Integer;
begin
  Result := FValues.Count;
end;

function TCnJSONArray.GetValues(Index: Integer): TCnJSONValue;
begin
  Result := TCnJSONValue(FValues[Index]);
end;

function TCnJSONArray.ToJSON(UseFormat: Boolean; Indent: Integer): string;
var
  Bld: TCnStringBuilder;
  I: Integer;
begin
  Bld := TCnStringBuilder.Create;
  try
    Bld.AppendChar('[');
    if UseFormat then
      Bld.Append(CRLF + StringOfChar(' ', Indent + CN_INDENT_DELTA));

    for I := 0 to Count - 1 do
    begin
      Bld.Append(Values[I].ToJSON(UseFormat, Indent + CN_INDENT_DELTA));
      if I <> Count - 1 then
      begin
        Bld.AppendChar(',');
        if UseFormat then
          Bld.AppendChar(' ');
      end;
    end;

    if UseFormat then
    begin
      Bld.Append(CRLF);
      Bld.Append(StringOfChar(' ', Indent) + ']');
    end
    else
      Bld.AppendChar(']');
    Result := Bld.ToString;
  finally
    Bld.Free;
  end;
end;

{ TCnJSONPair }

function TCnJSONPair.AddChild(AChild: TCnJSONBase): TCnJSONBase;
begin
  if FValue <> nil then
    raise ECnJSONException.Create(SCnErrorJSONPair);

  if AChild is TCnJSONValue then
  begin
    FValue := AChild as TCnJSONValue;
    Result := AChild;
  end
  else
    Result := nil;
end;

constructor TCnJSONPair.Create;
begin
  inherited;
  FName := TCnJSONString.Create;
  // FValue ���Ͳ�һ�����ȴ���
end;

destructor TCnJSONPair.Destroy;
begin
  FValue.Free;
  FName.Free;
  inherited;
end;

function TCnJSONPair.ToJSON(UseFormat: Boolean; Indent: Integer): string;
begin
  // ��������Ӧ���õ����
end;

{ TCnJSONBase }

function TCnJSONBase.AddChild(AChild: TCnJSONBase): TCnJSONBase;
begin
  Result := AChild;
end;

{ TCnJSONString }

function TCnJSONString.IsString: Boolean;
begin
  Result := True;
end;

{ TCnJSONNumber }

function TCnJSONNumber.IsNumber: Boolean;
begin
  Result := True;
end;

{ TCnJSONNull }

function TCnJSONNull.IsNull: Boolean;
begin
  Result := True;
end;

{ TCnJSONTrue }

function TCnJSONTrue.IsTrue: Boolean;
begin
  Result := True;
end;

{ TCnJSONFalse }

function TCnJSONFalse.IsFalse: Boolean;
begin
  Result := True;
end;

end.
