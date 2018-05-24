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
  SysUtils, Classes, Windows, CnTree {$IFDEF DEBUG}, ComCtrls {$ENDIF};

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
  TCnBerNode = class(TCnLeaf)
  {* ����һ���������� ASN.1 �ڵ�}
  private
    FBerLength: Integer;
    FBerOffset: Integer;
    FBerTag: Integer;
    FBerDataLength: Integer;
    FBerDataOffset: Integer;
    function GetItems(Index: Integer): TCnBerNode;
    procedure SetItems(Index: Integer; const Value: TCnBerNode);
  public
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
    function GetTotalCount: Integer;
    function GetItems(Index: Integer): TCnBerNode;
    procedure ParseArea(Parent: TCnLeaf; AData: PByteArray;
      ADataLen: Cardinal; AStartOffset: Cardinal);
    {* ����һ�����ݣ�������������� ASN.1 �ڵ����ι��� Parent �ڵ���}
  protected
    procedure ParseToTree;
  public
    constructor Create(Data: PByte; DataLen: Cardinal);
    destructor Destroy; override;
{$IFDEF DEBUG}
    procedure DumpToTreeView(ATreeView: TTreeView);
{$ENDIF}
    property TotalCount: Integer read GetTotalCount;
    {* ���������� ASN.1 �ڵ�����}
    property Items[Index: Integer]: TCnBerNode read GetItems;
    {* ˳��������н��������� ASN.1 �ڵ㣬�±�� 0 ��ʼ}
  end;

implementation

{ TCnBerParser }

constructor TCnBerParser.Create(Data: PByte; DataLen: Cardinal);
begin
  FData := Data;
  FDataLen := DataLen;
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

    // Tag, Len, DataOffset ����ȫ�ˣ�Delta ��������ʼ���������ڵ���ʼ����ƫ��
    if Parent = nil then
      Parent := FBerTree.Root;

    ALeaf := FBerTree.AddChild(Parent) as TCnBerNode;
    ALeaf.BerOffset := AStartOffset + Start;
    ALeaf.BerLength := DataLen + Delta;
    ALeaf.BerTag := Tag;
    ALeaf.BerDataLength := DataLen;
    ALeaf.BerDataOffset := DataOffset;

{$IFDEF DEBUG}
    ALeaf.Text := Format('Offset %d. Length %d. Tag %d. DataLength %d', [ALeaf.BerOffset,
      ALeaf.BerLength, ALeaf.BerTag, ALeaf.BerDataLength]);
{$ENDIF}

    if IsStruct then
    begin
      // ˵�� BerDataOffset �� BerDataLength �����ӽڵ�
      ParseArea(ALeaf, PByteArray(Integer(AData) + Delta),
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

function TCnBerNode.GetItems(Index: Integer): TCnBerNode;
begin
  Result := inherited GetItems(Index) as TCnBerNode;
end;

procedure TCnBerNode.SetItems(Index: Integer; const Value: TCnBerNode);
begin
  inherited SetItems(Index, Value);
end;

end.
