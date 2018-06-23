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

unit CnCertificateAuthority;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�CA ֤����֤��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע�����ɿͻ��� CSR �ļ���֤��ǩ������
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2018.06.15 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, CnRSA, CnBerUtils, CnMD5, CnSHA1, CnSHA2;

type
  TCnCASignType = (ctMd5RSA, ctSha1RSA, ctSha256RSA);
  {* ֤��ǩ��ʹ�õ�ɢ��ǩ���㷨��ctSha1RSA ��ʾ�� Sha1 �� RSA}

  TCnCertificateInfo = class(TPersistent)
  {* ����֤���а�������ͨ�ֶ���Ϣ��Ҳ�� DN}
  private
    FCountryName: string;
    FOrganizationName: string;
    FEmailAddress: string;
    FLocalityName: string;
    FCommonName: string;
    FOrganizationalUnitName: string;
    FStateOrProvinceName: string;
  public
    procedure Assign(Source: TPersistent); override;
    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}
  published
    property CountryName: string read FCountryName write FCountryName;
    {* ������}
    property StateOrProvinceName: string read FStateOrProvinceName write FStateOrProvinceName;
    {* ������ʡ��}
    property LocalityName: string read FLocalityName write FLocalityName;
    {* �������������}
    property OrganizationName: string read FOrganizationName write FOrganizationName;
    {* ��֯��}
    property OrganizationalUnitName: string read FOrganizationalUnitName write FOrganizationalUnitName;
    {* ��֯��λ��}
    property CommonName: string read FCommonName write FCommonName;
    {* ����}
    property EmailAddress: string read FEmailAddress write FEmailAddress;
    {* �����ʼ���ַ}
  end;

  TCnRSACertificateRequest = class(TObject)
  {* ����֤�������е���Ϣ��������ͨ�ֶΡ���Կ��ժҪ������ǩ����}
  private
    FCertificateInfo: TCnCertificateInfo;
    FPublicKey: TCnRSAPublicKey;
    FCASignType: TCnCASignType;
    FSignValue: Pointer;
    FSignLength: Integer;
    FDigestLength: Integer;
    FDigestValue: Pointer;
    FDigestType: TCnRSASignDigestType;
    procedure SetCertificateInfo(const Value: TCnCertificateInfo);
    procedure SetPublicKey(const Value: TCnRSAPublicKey); // ǩ�� Length Ϊ Key �� Bit ���� 2048 Bit��
  public
    constructor Create;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ENDIF}

    property CertificateInfo: TCnCertificateInfo read FCertificateInfo write SetCertificateInfo;
    {* ֤�� DN ��Ϣ}
    property PublicKey: TCnRSAPublicKey read FPublicKey write SetPublicKey;
    {* �ͻ��˹�Կ}
    property CASignType: TCnCASignType read FCASignType write FCASignType;
    {* �ͻ���ʹ�õ�ɢ����ǩ���㷨}
    property SignValue: Pointer read FSignValue write FSignValue;
    {* ɢ�к�ǩ���Ľ��}
    property SignLength: Integer read FSignLength write FSignLength;
    {* ɢ�к�ǩ���Ľ������}
    property DigestType: TCnRSASignDigestType read FDigestType write FDigestType;
    {* �ͻ���ɢ��ʹ�õ�ɢ���㷨��Ӧ�� CASignType �������}
    property DigestValue: Pointer read FDigestValue write FDigestValue;
    {* ɢ��ֵ}
    property DigestLength: Integer read FDigestLength write FDigestLength;
    {* ɢ��ֵ�ĳ���}
  end;

function CnCANewCertificateSignRequest(PrivateKey: TCnRSAPrivateKey; PublicKey:
  TCnRSAPublicKey; const OutCSRFile: string; const CountryName: string; const
  StateOrProvinceName: string; const LocalityName: string; const OrganizationName:
  string; const OrganizationalUnitName: string; const CommonName: string; const
  EmailAddress: string; CASignType: TCnCASignType = ctSha1RSA): Boolean;
{* ���ݹ�˽Կ��һЩ DN ��Ϣ�Լ�ָ��ɢ���㷨���� CSR ��ʽ��֤�������ļ�}

function CnCALoadCertificateSignRequestFromFile(const FileName: string;
  CertificateRequest: TCnRSACertificateRequest): Boolean;
{* ���� PEM ��ʽ�� CSR �ļ��������ݷ��� TCnRSACertificateRequest ������}

// ������������

function AddCASignTypeOIDNodeToWriter(AWriter: TCnBerWriter; CASignType: TCnCASignType;
  AParent: TCnBerWriteNode): TCnBerWriteNode;
{* ��һ��ɢ���㷨�� OID д��һ�� Ber �ڵ�}

function GetCASignNameFromSignType(Sign: TCnCASignType): string;
{* ��֤���ǩ��ɢ���㷨ö��ֵ��ȡ������}

implementation

const
  // PKCS#10
  PEM_CERTIFICATE_REQUEST_HEAD = '-----BEGIN CERTIFICATE REQUEST-----';
  PEM_CERTIFICATE_REQUEST_TAIL = '-----END CERTIFICATE REQUEST-----';

  OID_DN_COUNTRYNAME            : array[0..2] of Byte = ($55, $04, $06); // 2.5.4.6
  OID_DN_STATEORPROVINCENAME    : array[0..2] of Byte = ($55, $04, $08); // 2.5.4.8
  OID_DN_LOCALITYNAME           : array[0..2] of Byte = ($55, $04, $07); // 2.5.4.7
  OID_DN_ORGANIZATIONNAME       : array[0..2] of Byte = ($55, $04, $0A); // 2.5.4.10
  OID_DN_ORGANIZATIONALUNITNAME : array[0..2] of Byte = ($55, $04, $0B); // 2.5.4.11
  OID_DN_COMMONNAME             : array[0..2] of Byte = ($55, $04, $03); // 2.5.4.3
  OID_DN_EMAILADDRESS           : array[0..8] of Byte = (
    $2A, $86, $48, $86, $F7, $0D, $01, $09, $01
  ); // 1.2.840.113549.1.9.1

  OID_SHA1_RSAENCRYPTION        : array[0..8] of Byte = (
    $2A, $86, $48, $86, $F7, $0D, $01, $01, $05
  ); // 1.2.840.113549.1.1.5

  SCRLF = #13#10;

function PrintHex(const Buf: Pointer; Len: Integer): string;
var
  I: Integer;
  P: PByteArray;
const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
                                  '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := '';
  P := PByteArray(Buf);
  for I := 0 to Len - 1 do
  begin
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(P[I] shr 4) and $0F] +
              Digits[P[I] and $0F]);
  end;
end;

function AddCASignTypeOIDNodeToWriter(AWriter: TCnBerWriter; CASignType: TCnCASignType;
  AParent: TCnBerWriteNode): TCnBerWriteNode;
begin
  Result := nil;
  case CASignType of
    ctSha1RSA:
      Result := AWriter.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_SHA1_RSAENCRYPTION[0],
        SizeOf(OID_SHA1_RSAENCRYPTION), AParent);
    // TODO: �����㷨����֧��
  end;
end;

// ����ָ������ժҪ�㷨�������ݵĶ�����ɢ��ֵ��д�� Stream
function CalcDigestData(const Buffer; Count: Integer; CASignType: TCnCASignType;
  outStream: TStream): Boolean;
var
  Md5: TMD5Digest;
  Sha1: TSHA1Digest;
  Sha256: TSHA256Digest;
begin
  Result := False;
  case CASignType of
    ctMd5RSA:
      begin
        Md5 := MD5Buffer(Buffer, Count);
        outStream.Write(Md5, SizeOf(TMD5Digest));
        Result := True;
      end;
    ctSha1RSA:
      begin
        Sha1 := SHA1Buffer(Buffer, Count);
        outStream.Write(Sha1, SizeOf(TSHA1Digest));
        Result := True;
      end;
    ctSha256RSA:
      begin
        Sha256 := SHA256Buffer(Buffer, Count);
        outStream.Write(Sha256, SizeOf(TSHA256Digest));
        Result := True;
      end;
  end;
end;

function GetRSASignTypeFromCASignType(CASignType: TCnCASignType): TCnRSASignDigestType;
begin
  Result := sdtSHA1;
  case CASignType of
    ctMd5RSA:
      Result := sdtMD5;
    ctSha1RSA:
      Result := sdtSHA1;
    ctSha256RSA:
      Result := sdtSHA256;
  end;
end;

function CnCANewCertificateSignRequest(PrivateKey: TCnRSAPrivateKey; PublicKey:
  TCnRSAPublicKey; const OutCSRFile: string; const CountryName: string; const
  StateOrProvinceName: string; const LocalityName: string; const OrganizationName:
  string; const OrganizationalUnitName: string; const CommonName: string; const
  EmailAddress: string; CASignType: TCnCASignType): Boolean;
var
  B: Byte;
  OutLen: Integer;
  OutBuf: array of Byte;
  Writer, HashWriter: TCnBerWriter;
  Stream, DigestStream, ValueStream: TMemoryStream;
  Root, DNRoot, InfoRoot, PubNode, HashNode, Node, HashRoot: TCnBerWriteNode;

  procedure WriteDNNameToNode(AWriter: TCnBerWriter; DNOID: Pointer; DNOIDLen: Integer;
    const DN: string; SuperParent: TCnBerWriteNode; ATag: Integer = CN_BER_TAG_PRINTABLESTRING);
  var
    ANode: TCnBerWriteNode;
    AnsiDN: AnsiString;
  begin
    // Superparent �� DNRoot�������� Set���� Sequence��Sequence ��� OID �� PrintableString
    ANode := AWriter.AddContainerNode(CN_BER_TAG_SET, SuperParent);
    ANode := AWriter.AddContainerNode(CN_BER_TAG_SEQUENCE, ANode);
    AWriter.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, PByte(DNOID), DNOIDLen, ANode);
    AnsiDN := AnsiString(DN);
    AWriter.AddBasicNode(ATag, @AnsiDN[1], Length(AnsiDN), ANode);
  end;

begin
  Result := False;

  if (PrivateKey = nil) or (PublicKey = nil) or (OutCSRFile = '') then
    Exit;

  if (Length(CountryName) <> 2) or (StateOrProvinceName = '') or (LocalityName = '')
    or (OrganizationName = '') or (OrganizationalUnitName = '') or (CommonName = '')
    or (EmailAddress = '') then
    Exit;

  B := 0;
  Writer := nil;
  HashWriter := nil;
  Stream := nil;
  DigestStream := nil;
  ValueStream := nil;
  try
    Writer := TCnBerWriter.Create;
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    InfoRoot := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);

    // �� Info дһ��ֱ���ӽڵ�
    Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, InfoRoot);          // �汾
    DNRoot := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, InfoRoot);  // DN
    PubNode := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, InfoRoot); // ��Կ
    Writer.AddRawNode($A0, @B, 1, InfoRoot);                           // ������

    // д DN �ڵ������
    WriteDNNameToNode(Writer, @OID_DN_COUNTRYNAME[0], SizeOf(OID_DN_COUNTRYNAME), CountryName, DNRoot);
    WriteDNNameToNode(Writer, @OID_DN_STATEORPROVINCENAME[0], SizeOf(OID_DN_STATEORPROVINCENAME), StateOrProvinceName, DNRoot);
    WriteDNNameToNode(Writer, @OID_DN_LOCALITYNAME[0], SizeOf(OID_DN_LOCALITYNAME), LocalityName, DNRoot);
    WriteDNNameToNode(Writer, @OID_DN_ORGANIZATIONNAME[0], SizeOf(OID_DN_ORGANIZATIONNAME), OrganizationName, DNRoot);
    WriteDNNameToNode(Writer, @OID_DN_ORGANIZATIONALUNITNAME[0], SizeOf(OID_DN_ORGANIZATIONALUNITNAME), OrganizationalUnitName, DNRoot);
    WriteDNNameToNode(Writer, @OID_DN_COMMONNAME[0], SizeOf(OID_DN_COMMONNAME), CommonName, DNRoot);
    WriteDNNameToNode(Writer, @OID_DN_EMAILADDRESS[0], SizeOf(OID_DN_EMAILADDRESS), EmailAddress, DNRoot, CN_BER_TAG_IA5STRING);

    // д��Կ�ڵ������
    Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, PubNode);
    Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_RSAENCRYPTION_PKCS1[0],
      SizeOf(OID_RSAENCRYPTION_PKCS1), Node);
    Writer.AddNullNode(Node);
    Node := Writer.AddContainerNode(CN_BER_TAG_BIT_STRING, PubNode);
    Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Node);
    AddBigNumberToWriter(Writer, PublicKey.PubKeyProduct, Node);
    AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Node);

    // �ó� InfoRoot ������
    ValueStream := TMemoryStream.Create;
    InfoRoot.SaveValueToStream(ValueStream);

    // ������ Hash
    DigestStream := TMemoryStream.Create;
    CalcDigestData(ValueStream.Memory, ValueStream.Size, CASignType, DigestStream);

    // �� Hash ����ǩ���㷨ƴ�� BER ����
    HashWriter := TCnBerWriter.Create;
    HashRoot := HashWriter.AddContainerNode(CN_BER_TAG_SEQUENCE);
    Node := HashWriter.AddContainerNode(CN_BER_TAG_SEQUENCE, HashRoot);
    AddDigestTypeOIDNodeToWriter(HashWriter, GetRSASignTypeFromCASignType(CASignType), Node);
    HashWriter.AddNullNode(Node);
    HashWriter.AddBasicNode(CN_BER_TAG_OCTET_STRING, DigestStream, HashRoot);

    // ���ô� Stream���������ɵ� BER ��ʽ����
    DigestStream.Clear;
    HashWriter.SaveToStream(DigestStream);

    // RSA ˽Կ���ܴ� BER ��õ�ǩ��ֵ
    SetLength(OutBuf, PrivateKey.BitsCount div 8);
    if not CnRSAEncryptRawData(DigestStream.Memory, DigestStream.Size,
      @OutBuf[0], OutLen, PrivateKey) then
      Exit;

    // ���� Hash �㷨˵��
    HashNode := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);
    AddCASignTypeOIDNodeToWriter(Writer, CASignType, HashNode);
    Writer.AddNullNode(HashNode);

    // д������ǩ��ֵ
    Writer.AddBasicNode(CN_BER_TAG_BIT_STRING, @OutBuf[0], OutLen, Root);

    Stream := TMemoryStream.Create;
    Writer.SaveToStream(Stream);
    Result := SaveMemoryToPemFile(OutCSRFile, PEM_CERTIFICATE_REQUEST_HEAD,
      PEM_CERTIFICATE_REQUEST_TAIL, Stream);
  finally
    Writer.Free;
    HashWriter.Free;
    Stream.Free;
    ValueStream.Free;
    DigestStream.Free;
    SetLength(OutBuf, 0);
  end;
end;

{
  CSR �ļ��Ĵ����ʽ���£�

  SEQUENCE
    SEQUENCE
      INTEGER0
      SEQUENCE
        SET
          SEQUENCE
            OBJECT IDENTIFIER 2.5.4.6countryName(X.520 DN component)
            PrintableString  CN
        SET
          SEQUENCE
            OBJECT IDENTIFIER 2.5.4.8stateOrProvinceName(X.520 DN component)
            PrintableString  ShangHai
        SET
          SEQUENCE
            OBJECT IDENTIFIER 2.5.4.7localityName(X.520 DN component)
            PrintableString  ShangHai
        SET
          SEQUENCE
            OBJECT IDENTIFIER 2.5.4.10organizationName(X.520 DN component)
            PrintableString  CnPack
        SET
          SEQUENCE
            OBJECT IDENTIFIER 2.5.4.11organizationalUnitName(X.520 DN component)
            PrintableString  CnPack Team
        SET
          SEQUENCE
            OBJECT IDENTIFIER 2.5.4.3commonName(X.520 DN component)
            PrintableString  cnpack.org
        SET
          SEQUENCE
           OBJECT IDENTIFIER  1.2.840.113549.1.9.1 emailAddress
           IA5String  master@cnpack.org
      SEQUENCE
        SEQUENCE
          OBJECT IDENTIFIER1.2.840.113549.1.1.1rsaEncryption(PKCS #1)
          NULL
        BIT STRING
          SEQUENCE
            INTEGER
            INTEGER 65537
      [0]
    SEQUENCE
      OBJECT IDENTIFIER 1.2.840.113549.1.1.5sha1WithRSAEncryption(PKCS #1)
      NULL
    BIT STRING  Digest ֵ���� RSA ���ܺ�Ľ��
}
function CnCALoadCertificateSignRequestFromFile(const FileName: string;
  CertificateRequest: TCnRSACertificateRequest): Boolean;
var
  I: Integer;
  P: Pointer;
  IsRSA, HasPub: Boolean;
  Reader: TCnBerReader;
  MemStream: TMemoryStream;
  DNRoot, PubNode, HashNode, SignNode, Node, StrNode: TCnBerReadNode;
  OutBuf: array of Byte;
  OutLen: Integer;
begin
  Result := False;
  if FileExists(FileName) then
  begin
    Reader := nil;
    MemStream := nil;
    try
      MemStream := TMemoryStream.Create;
      if not LoadPemFileToMemory(FileName, PEM_CERTIFICATE_REQUEST_HEAD,
        PEM_CERTIFICATE_REQUEST_TAIL, MemStream) then
        Exit;

      Reader := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size, True);
      Reader.ParseToTree;
      if (Reader.TotalCount >= 42) and (Reader.Items[2].BerTag = CN_BER_TAG_INTEGER)
        and (Reader.Items[2].AsInteger = 0) then // ��������ô����汾�ű���Ϊ 0
      begin
        DNRoot := Reader.Items[3];
        PubNode := DNRoot.GetNextSibling;
        if PubNode = nil then
          Exit;

        HashNode := Reader.Items[1].GetNextSibling;
        if (HashNode = nil) or (HashNode.Count <> 2) then
          Exit;

        SignNode := HashNode.GetNextSibling;
        if (SignNode = nil) or (SignNode.BerTag <> CN_BER_TAG_BIT_STRING)
          or (SignNode.BerDataLength <= 2) then
          Exit;

        IsRSA := False;
        if (PubNode.Count = 2) and (PubNode.Items[0].Count = 2) then
          IsRSA := CompareObjectIdentifier(PubNode.Items[0].Items[0],
            @OID_RSAENCRYPTION_PKCS1[0], SizeOf(OID_RSAENCRYPTION_PKCS1));

        if not IsRSA then // �㷨���� RSA
          Exit;

        // ѭ������ DN ��
        for I := 0 to DNRoot.Count - 1 do
        begin
          Node := DNRoot.Items[I]; // Set
          if (Node.BerTag = CN_BER_TAG_SET) and (Node.Count = 1) then
          begin
            Node := Node.Items[0]; // Sequence
            if (Node.BerTag = CN_BER_TAG_SEQUENCE) and (Node.Count = 2) then
            begin
              StrNode := Node.Items[1];
              Node := Node.Items[0];
              if Node.BerTag = CN_BER_TAG_OBJECT_IDENTIFIER then
              begin
                if CompareObjectIdentifier(Node, @OID_DN_COUNTRYNAME[0], SizeOf(OID_DN_COUNTRYNAME)) then
                  CertificateRequest.CertificateInfo.CountryName := StrNode.AsPrintableString
                else if CompareObjectIdentifier(Node, @OID_DN_STATEORPROVINCENAME[0], SizeOf(OID_DN_STATEORPROVINCENAME)) then
                  CertificateRequest.CertificateInfo.StateOrProvinceName := StrNode.AsPrintableString
                else if CompareObjectIdentifier(Node, @OID_DN_LOCALITYNAME[0], SizeOf(OID_DN_LOCALITYNAME)) then
                  CertificateRequest.CertificateInfo.LocalityName := StrNode.AsPrintableString
                else if CompareObjectIdentifier(Node, @OID_DN_ORGANIZATIONNAME[0], SizeOf(OID_DN_ORGANIZATIONNAME)) then
                  CertificateRequest.CertificateInfo.OrganizationName := StrNode.AsPrintableString
                else if CompareObjectIdentifier(Node, @OID_DN_ORGANIZATIONALUNITNAME[0], SizeOf(OID_DN_ORGANIZATIONALUNITNAME)) then
                  CertificateRequest.CertificateInfo.OrganizationalUnitName := StrNode.AsPrintableString
                else if CompareObjectIdentifier(Node, @OID_DN_COMMONNAME[0], SizeOf(OID_DN_COMMONNAME)) then
                  CertificateRequest.CertificateInfo.CommonName := StrNode.AsPrintableString
                else if CompareObjectIdentifier(Node, @OID_DN_EMAILADDRESS[0], SizeOf(OID_DN_EMAILADDRESS)) then
                  CertificateRequest.CertificateInfo.EmailAddress := StrNode.AsPrintableString
              end;
            end;
          end;
        end;

        // �⿪��Կ
        HasPub := False;
        PubNode := PubNode.Items[1]; // BitString
        if (PubNode.Count = 1) and (PubNode.Items[0].Count = 2) then
        begin
          PubNode := PubNode.Items[0]; // Sequence
          CertificateRequest.PublicKey.PubKeyProduct.SetBinary(PAnsiChar(
            PubNode.Items[0].BerDataAddress), PubNode.Items[0].BerDataLength);
          CertificateRequest.PublicKey.PubKeyExponent.SetBinary(PAnsiChar(
            PubNode.Items[1].BerDataAddress), PubNode.Items[1].BerDataLength);
          HasPub := True;
        end;

        if not HasPub then
          Exit;

        // �ҵ�ǩ���㷨
        if HashNode.Count = 2 then
        begin
          if CompareObjectIdentifier(HashNode.Items[0], @OID_SHA1_RSAENCRYPTION[0],
            SizeOf(OID_SHA1_RSAENCRYPTION)) then
            CertificateRequest.CASignType := ctSha1RSA;
          // TODO: ֧�ָ����㷨
        end;

        // ����ǩ�����ݣ����� BIT String ��ǰ������ 0
        FreeMemory(CertificateRequest.SignValue);
        CertificateRequest.SignLength := SignNode.BerDataLength - 1;
        CertificateRequest.SignValue := GetMemory(CertificateRequest.SignLength);
        P := Pointer(Integer(SignNode.BerDataAddress) + 1);
        CopyMemory(CertificateRequest.SignValue, P, CertificateRequest.SignLength);

        // �⿪ RSA ǩ�������ݵõ� DER ����� Hash ֵ���㷨
        SetLength(OutBuf, CertificateRequest.PublicKey.BitsCount div 8);
        if CnRSADecryptRawData(CertificateRequest.SignValue, CertificateRequest.SignLength,
          @OutBuf[0], OutLen, CertificateRequest.PublicKey) then
        begin
          FreeAndNil(Reader);
          Reader := TCnBerReader.Create(@OutBuf[0], OutLen);
          Reader.ParseToTree;

          if Reader.TotalCount < 5 then
            Exit;
          
          Node := Reader.Items[2];
          CertificateRequest.DigestType := GetDigestSignTypeFromBerOID(Node.BerDataAddress,
            Node.BerDataLength);
          if CertificateRequest.DigestType = sdtNone then
            Exit;

          // ��ȡ Ber �����ɢ��ֵ
          Node := Reader.Items[4];
          FreeMemory(CertificateRequest.DigestValue);
          CertificateRequest.DigestLength := Node.BerDataLength;
          CertificateRequest.DigestValue := GetMemory(CertificateRequest.DigestLength);
          CopyMemory(CertificateRequest.DigestValue, Node.BerDataAddress,
            CertificateRequest.DigestLength);
        end;
        Result := True;
      end;
    finally
      Reader.Free;
      MemStream.Free;
      SetLength(OutBuf, 0);
    end;
  end;
end;

{ TCnCertificateInfo }

procedure TCnCertificateInfo.Assign(Source: TPersistent);
begin
  if Source is TCnCertificateInfo then
  begin
    FCountryName := (Source as TCnCertificateInfo).CountryName;
    FOrganizationName := (Source as TCnCertificateInfo).OrganizationName;
    FEmailAddress := (Source as TCnCertificateInfo).EmailAddress;
    FLocalityName := (Source as TCnCertificateInfo).LocalityName;
    FCommonName := (Source as TCnCertificateInfo).CommonName;
    FOrganizationalUnitName := (Source as TCnCertificateInfo).OrganizationalUnitName;
    FStateOrProvinceName := (Source as TCnCertificateInfo).StateOrProvinceName;
  end
  else
    inherited;
end;

function TCnCertificateInfo.ToString: string;
begin
  Result := 'CountryName: ' + FCountryName + SCRLF;
  Result := Result + 'StateOrProvinceName: ' + FStateOrProvinceName + SCRLF;
  Result := Result + 'LocalityName: ' + FLocalityName + SCRLF;
  Result := Result + 'OrganizationName: ' + FOrganizationName + SCRLF;
  Result := Result + 'OrganizationalUnitName: ' + FOrganizationalUnitName + SCRLF;
  Result := Result + 'CommonName: ' + FCommonName + SCRLF;
  Result := Result + 'EmailAddress: ' + FEmailAddress + SCRLF;
end;

{ TCnRSACertificateRequest }

constructor TCnRSACertificateRequest.Create;
begin
  inherited;
  FCertificateInfo := TCnCertificateInfo.Create;
  FPublicKey := TCnRSAPublicKey.Create;
end;

destructor TCnRSACertificateRequest.Destroy;
begin
  FCertificateInfo.Free;
  FPublicKey.Free;
  FreeMemory(FSignValue);
  FreeMemory(FDigestValue);
  inherited;
end;

procedure TCnRSACertificateRequest.SetCertificateInfo(
  const Value: TCnCertificateInfo);
begin
  FCertificateInfo.Assign(Value);
end;

procedure TCnRSACertificateRequest.SetPublicKey(
  const Value: TCnRSAPublicKey);
begin
  FPublicKey.Assign(Value);
end;

function TCnRSACertificateRequest.ToString: string;
begin
  Result := FCertificateInfo.ToString;
  Result := Result + SCRLF + 'Public Key Modulus: ' + FPublicKey.PubKeyProduct.ToDec;
  Result := Result + SCRLF + 'Public Key Exponent: ' + FPublicKey.PubKeyExponent.ToDec;
  Result := Result + SCRLF + 'CA Signature Type: ' + GetCASignNameFromSignType(FCASignType);
  Result := Result + SCRLF + 'Signature: ' + PrintHex(FSignValue, FSignLength);
  Result := Result + SCRLF + 'Signature Hash: ' + GetDigestNameFromSignDigestType(FDigestType);
  Result := Result + SCRLF + 'Digest: ' + PrintHex(FDigestValue, FDigestLength);
end;

function GetCASignNameFromSignType(Sign: TCnCASignType): string;
begin
  case Sign of
    ctMd5RSA: Result := 'MD5 RSA';
    ctSha1RSA: Result := 'SHA1 RSA';
    ctSha256RSA: Result := 'SHA256 RSA';
  else
    Result := '<Unknown>';
  end;
end;
end.
