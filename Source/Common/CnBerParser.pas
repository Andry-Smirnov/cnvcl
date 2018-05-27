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

unit CnBerParser;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����� ASN.1 �� BER ���뵥Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2018.05.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, TypInfo, CnTree {$IFDEF DEBUG}, ComCtrls {$ENDIF};

const
  CN_BER_TAG_TYPE_MASK                      = $C0;
  CN_BER_TAG_STRUCT_MASK                    = $20;
  CN_BER_TAG_VALUE_MASK                     = $1F;
  CN_BER_LENLEN_MASK                        = $80;
  CN_BER_LENGTH_MASK                        = $7F;

  CN_BER_TAG_RESERVED                       = $00;
  CN_BER_TAG_BOOLEAN                        = $01;
  CN_BER_TAG_INTEGER                        = $02;
  CN_BER_TAG_BIT_STRING                     = $03;
  CN_BER_TAG_OCTET_STRING                   = $04;
  CN_BER_TAG_NULL                           = $05;
  CN_BER_TAG_OBJECT_IDENTIFIER              = $06;
  CN_BER_TAG_OBJECT_DESCRIPION              = $07;
  CN_BER_TAG_EXTERNAL                       = $08;
  CN_BER_TAG_REAL                           = $09;
  CN_BER_TAG_ENUMERATED                     = $0A;
  CN_BER_TAG_EMBEDDED_PDV                   = $0B;
  CN_BER_TAG_UFT8STRING                     = $0C;
  CN_BER_TAG_RELATIVE_OID                   = $0D;

  CN_BER_TAG_SEQUENCE                       = $10;
  CN_BER_TAG_SET                            = $11;
  CN_BER_TAG_NUMERICSTRING                  = $12;
  CN_BER_TAG_PRINTABLESTRING                = $13;
  CN_BER_TAG_TELETEXSTRING                  = $14;
  CN_BER_TAG_VIDEOTEXSTRING                 = $15;
  CN_BER_TAG_IA5STRING                      = $16;
  CN_BER_TAG_UTCTIME                        = $17;
  CN_BER_TAG_GENERALIZEDTIME                = $18;
  CN_BER_TAG_GRAPHICSTRING                  = $19;
  CN_BER_TAG_VISIBLESTRING                  = $1A;
  CN_BER_TAG_GENERALSTRING                  = $1B;
  CN_BER_TAG_UNIVERSALSTRING                = $1C;
  CN_BER_TAG_CHARACTER_STRING               = $1D;
  CN_BER_TAG_BMPSTRING                      = $1E;

type
  TCnBerTag = (cbtReserved_0, cbtBoolean, cbtInteger, cbtBit_String,
    cbtOctet_String, cbtNull, cbtObject_Identifier, cbtObject_Descripion,
    cbtExternal, cbtReal, cbtEnumerated, cbtEmbedded_Pdv, cbtUft8String,
    cbtRelative_Oid, cbtReserved_0E, cbtReserved_0F, cbtSequence, cbtSet,
    cbtNumericString, cbtPrintableString, cbtTeletexString, cbtVideotexString,
    cbtIa5String, cbtUtcTime, cbtGeneralizedTime, cbtGraphicString,
    cbtVisibleString, cbtGeneralString, cbtUniversalString, cbtCharacter_String,
    cbtBmpstring);

  TCnBerTags = set of TCnBerTag;

  TCnBerNode = class(TCnLeaf)
  {* ����һ���������� ASN.1 �ڵ�}
  private
    FOriginData: PByte;
    FBerLength: Integer;
    FBerOffset: Integer;
    FBerTag: Integer;
    FBerDataLength: Integer;
    FBerDataOffset: Integer;
    function GetItems(Index: Integer): TCnBerNode;
    procedure SetItems(Index: Integer; const Value: TCnBerNode);

    function InternalAsInt(ByteSize: Integer): Integer;
  public
    procedure CopyDataTo(DestBuf: Pointer);
    {* �����ݸ��������������������ߴ�������Ҫ BerDataLength ��}

    function AsShortInt: ShortInt;
    function AsByte: Byte;
    function AsSmallInt: SmallInt;
    function AsWord: Word;
    function AsInteger: Integer;
    function AsCardinal: Cardinal;
    function AsInt64: Int64;

    property Items[Index: Integer]: TCnBerNode read GetItems write SetItems;

    property BerOffset: Integer read FBerOffset write FBerOffset;
    {* �ýڵ��Ӧ�� ASN.1 ���ݱ����������е�ƫ��}
    property BerLength: Integer read FBerLength write FBerLength;
    {* �����ڵ�����ݳ���}

    property BerTag: Integer read FBerTag write FBerTag;
    {* �ڵ����ͣ�Ҳ���� Tag}
    property BerDataLength: Integer read FBerDataLength write FBerDataLength;
    {* �ڵ����ݳ���}
    property BerDataOffset: Integer read FBerDataOffset write FBerDataOffset;
    {* �ýڵ��Ӧ�����������������е�ƫ��}
  end;

  TCnBerParser = class
  private
    FBerTree: TCnTree;
    FData: PByte;
    FDataLen: Cardinal;
    FParseInnerString: Boolean;
{$IFDEF DEBUG}
    function GetOnSaveNode: TCnTreeNodeEvent;
    procedure SetOnSaveNode(const Value: TCnTreeNodeEvent);
{$ENDIF}
    function GetTotalCount: Integer;
    function GetItems(Index: Integer): TCnBerNode;
    procedure ParseArea(Parent: TCnLeaf; AData: PByteArray;
      ADataLen: Cardinal; AStartOffset: Cardinal);
    {* ����һ�����ݣ�������������� ASN.1 �ڵ����ι��� Parent �ڵ���}
  protected
    procedure ParseToTree;
  public
    constructor Create(Data: PByte; DataLen: Cardinal; AParseInnerString: Boolean = False);
    destructor Destroy; override;
{$IFDEF DEBUG}
    procedure DumpToTreeView(ATreeView: TTreeView);
    property OnSaveNode: TCnTreeNodeEvent read GetOnSaveNode write SetOnSaveNode;
{$ENDIF}
    property ParseInnerString: Boolean read FParseInnerString;
    {* �Ƿ� BitString/OctetString ����Ҳ��������������������PKCS#8 �� Pem �ļ��г���}
    property TotalCount: Integer read GetTotalCount;
    {* ���������� ASN.1 �ڵ�����}
    property Items[Index: Integer]: TCnBerNode read GetItems;
    {* ˳��������н��������� ASN.1 �ڵ㣬�±�� 0 ��ʼ�������� Tree ����� Root}
  end;

implementation

function GetTagName(Tag: Integer): string;
begin
  Result := 'Invalid';
  if Tag in [Ord(Low(TCnBerTag))..Ord(High(TCnBerTag))] then
  begin
    Result := GetEnumName(TypeInfo(TCnBerTag), Tag);
    if (Length(Result) > 3) and (Copy(Result, 1, 3) = 'cbt') then
      Delete(Result, 1, 3);
  end;
end;

function SwapLongWord(Value: LongWord): LongWord;
begin
  Result := ((Value and $000000FF) shl 24) or ((Value and $0000FF00) shl 8)
    or ((Value and $00FF0000) shr 8) or ((Value and $FF000000) shr 24);
end;

function SwapInt64(Value: Int64): Int64;
var
  Lo, Hi: LongWord;
  Rec: Int64Rec;
begin
  Lo := Int64Rec(Value).Lo;
  Hi := Int64Rec(Value).Hi;
  Lo := SwapLongWord(Lo);
  Hi := SwapLongWord(Hi);
  Rec.Lo := Hi;
  Rec.Hi := Lo;
  Result := Int64(Rec);
end;

{ TCnBerParser }

constructor TCnBerParser.Create(Data: PByte; DataLen: Cardinal;
  AParseInnerString: Boolean);
begin
  FData := Data;
  FDataLen := DataLen;
  FParseInnerString := AParseInnerString;
  FBerTree := TCnTree.Create(TCnBerNode);

  ParseToTree;
end;

destructor TCnBerParser.Destroy;
begin
  inherited;

end;

{$IFDEF DEBUG}

procedure TCnBerParser.DumpToTreeView;
begin
  FBerTree.SaveToTreeView(ATreeView);
end;

function TCnBerParser.GetOnSaveNode: TCnTreeNodeEvent;
begin
  Result := FBerTree.OnSaveANode;
end;

procedure TCnBerParser.SetOnSaveNode(const Value: TCnTreeNodeEvent);
begin
  FBerTree.OnSaveANode := Value;
end;

{$ENDIF}

function TCnBerParser.GetItems(Index: Integer): TCnBerNode;
begin
  Result := TCnBerNode(FBerTree.Items[Index + 1]);
end;

function TCnBerParser.GetTotalCount: Integer;
begin
  Result := FBerTree.Root.AllCount;
end;

procedure TCnBerParser.ParseArea(Parent: TCnLeaf; AData: PByteArray;
  ADataLen: Cardinal; AStartOffset: Cardinal);
var
  Run, Start: Cardinal;
  Tag, DataLen, DataOffset, LenLen, Delta: Integer;
  B: Byte;
  IsStruct: Boolean;
  ALeaf: TCnBerNode;
begin
  Run := 0;  // Run �ǻ��� AData ��ʼ����ƫ����

  while Run < ADataLen do
  begin
    B := AData[Run];

    if B = $FF then
      Exit;

    Start := Run;

    // ���� Tag ����
    IsStruct := (B and CN_BER_TAG_STRUCT_MASK) <> 0;
    Tag := B and CN_BER_TAG_VALUE_MASK;

    Inc(Run);
    if Run >= ADataLen then
      raise Exception.Create('Data Corruption when Processing Tag.');

    // Run ָ�򳤶ȣ�������
    Delta := 1;  // 1 ��ʾ Tag ��ռ�ֽ�
    B := AData[Run];
    if (B and CN_BER_LENLEN_MASK) = 0 then
    begin
      // ���ֽھ��ǳ���
      DataLen := B;
      DataOffset := AStartOffset + Run + 1;
      Inc(Delta); // ���ϳ��ȵ���һ�ֽ�
      Inc(Run);   // Run ָ������
    end
    else
    begin
      // ���ֽڸ�λΪ 1����ʾ���ȵĳ���
      LenLen := B and CN_BER_LENGTH_MASK;
      Inc(Delta); // ���ϳ��ȵĳ�����һ�ֽ�
      Inc(Run);   // Run ָ�򳤶�

      // AData[Run] �� AData[Run + LenLen - 1] �ǳ���
      if Run + Cardinal(LenLen) - 1 >= ADataLen then
        raise Exception.Create('Data Corruption when Processing Tag.');

      if LenLen = SizeOf(Byte) then
        DataLen := AData[Run]
      else if LenLen = SizeOf(Word) then
        DataLen := (Cardinal(AData[Run]) shl 8) or Cardinal(AData[Run + 1])
      else // if LenLen > SizeOf(Word) then
        raise Exception.Create('Length Too Long: ' + IntToStr(LenLen));

      DataOffset := AStartOffset + Run + Cardinal(LenLen);
      Inc(Delta, LenLen);
      Inc(Run, LenLen);   // Run ָ������
    end;

    // Tag, Len, DataOffset ����ȫ�ˣ�Delta ��������ʼ���뵱ǰ�ڵ���ʼ����ƫ��
    if Parent = nil then
      Parent := FBerTree.Root;

    ALeaf := FBerTree.AddChild(Parent) as TCnBerNode;
    ALeaf.FOriginData := FData;

    ALeaf.BerOffset := AStartOffset + Start;
    ALeaf.BerLength := DataLen + Delta;
    ALeaf.BerTag := Tag;
    ALeaf.BerDataLength := DataLen;
    ALeaf.BerDataOffset := DataOffset;

{$IFDEF DEBUG}
    ALeaf.Text := Format('Offset %d. Len %d. Tag %d (%s). DataLen %d', [ALeaf.BerOffset,
      ALeaf.BerLength, ALeaf.BerTag, GetTagName(ALeaf.BerTag), ALeaf.BerDataLength]);
{$ENDIF}

    if IsStruct or (FParseInnerString and (ALeaf.BerTag in [CN_BER_TAG_BIT_STRING,
      CN_BER_TAG_OCTET_STRING])) then
    begin
      // ˵�� BerDataOffset �� BerDataLength �����ӽڵ�

      if (ALeaf.BerTag = CN_BER_TAG_BIT_STRING) and (AData[Run] = 0) then
      begin
        // BIT_STRING �����������и�ǰ�� 00
        ParseArea(ALeaf, PByteArray(Cardinal(AData) + Run + 1),
          ALeaf.BerDataLength - 1, ALeaf.BerDataOffset + 1);
      end
      else
        ParseArea(ALeaf, PByteArray(Cardinal(AData) + Run),
          ALeaf.BerDataLength, ALeaf.BerDataOffset);
    end;

    Inc(Run, DataLen);
  end;
end;

procedure TCnBerParser.ParseToTree;
begin
  ParseArea(FBerTree.Root, PByteArray(FData), FDataLen, 0);
end;

{ TCnBerNode }

function TCnBerNode.InternalAsInt(ByteSize: Integer): Integer;
var
  IntValue: Integer;
begin
  if FBerTag <> CN_BER_TAG_INTEGER then
    raise Exception.Create('Ber Tag Type Mismatch for ByteSize: ' + IntToStr(ByteSize));

  if not (ByteSize in [SizeOf(Byte)..SizeOf(Integer)]) then
    raise Exception.Create('Invalid ByteSize: ' + IntToStr(ByteSize));

  if FBerDataLength > ByteSize then
    raise Exception.CreateFmt('Data Length %d Overflow for Required %d.',
      [FBerDataLength, ByteSize]);

  IntValue := 0;
  CopyDataTo(@IntValue);
  IntValue := SwapLongWord(IntValue);
  Result := IntValue;
end;

function TCnBerNode.AsInt64: Int64;
begin
  if FBerTag <> CN_BER_TAG_INTEGER then
    raise Exception.Create('Ber Tag Type Mismatch for Int64: ' + IntToStr(FBerTag));

  if FBerDataLength > SizeOf(Int64) then
    raise Exception.CreateFmt('Data Length %d Overflow for Required %d.',
      [FBerDataLength, SizeOf(Int64)]);

  Result := 0;
  CopyDataTo(@Result);
  Result := SwapInt64(Result);
end;

function TCnBerNode.AsByte: Byte;
begin
  Result := Byte(InternalAsInt(SizeOf(Byte)));
end;

function TCnBerNode.AsCardinal: Cardinal;
begin
  Result := Cardinal(InternalAsInt(SizeOf(Cardinal)));
end;

function TCnBerNode.AsInteger: Integer;
begin
  Result := Integer(InternalAsInt(SizeOf(Integer)));
end;

function TCnBerNode.AsShortInt: ShortInt;
begin
  Result := ShortInt(InternalAsInt(SizeOf(ShortInt)));
end;

function TCnBerNode.AsSmallInt: SmallInt;
begin
  Result := SmallInt(InternalAsInt(SizeOf(SmallInt)));
end;

function TCnBerNode.AsWord: Word;
begin
  Result := Word(InternalAsInt(SizeOf(Word)));
end;

procedure TCnBerNode.CopyDataTo(DestBuf: Pointer);
begin
  if (FOriginData <> nil) and (FBerDataLength > 0) then
    CopyMemory(DestBuf, Pointer(Integer(FOriginData) + FBerDataOffset), FBerDataLength);
end;

function TCnBerNode.GetItems(Index: Integer): TCnBerNode;
begin
  Result := inherited GetItems(Index) as TCnBerNode;
end;

procedure TCnBerNode.SetItems(Index: Integer; const Value: TCnBerNode);
begin
  inherited SetItems(Index, Value);
end;

end.
