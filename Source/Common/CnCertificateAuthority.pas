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
* ��    ע��
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
  SysUtils, Classes, Windows, CnRSA, CnBerUtils;

type
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
    FSignDigestType: TCnRSASignDigestType;
    FSignValue: Pointer;
    FSignLength: Integer;
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
    property SignDigestType: TCnRSASignDigestType read FSignDigestType write FSignDigestType;
    {* �ͻ���ǩ����ɢ���㷨}
    property SignValue: Pointer read FSignValue write FSignValue;
    {* ɢ�к�ǩ���Ľ��}
    property SignLength: Integer read FSignLength write FSignLength;
    {* ɢ�к�ǩ���Ľ������}
  end;

function CnCANewCertificateSignRequest(PrivateKey: TCnRSAPrivateKey; PublicKey:
  TCnRSAPublicKey; const OutCSRFile: string; const CountryName: string; const
  StateOrProvinceName: string; const LocalityName: string; const OrganizationName:
  string; const OrganizationalUnitName: string; const CommonName: string; const
  EmailAddress: string; SignType: TCnRSASignDigestType = sdtSHA1): Boolean;

function CnCALoadCertificateSignRequestFromFile(const FileName: string;
  CertificateRequest: TCnRSACertificateRequest): Boolean;
{* ���� PEM ��ʽ�� CSR �ļ��������ݷ��� TCnRSACertificateRequest ������}

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

function CnCANewCertificateSignRequest(PrivateKey: TCnRSAPrivateKey; PublicKey:
  TCnRSAPublicKey; const OutCSRFile: string; const CountryName: string; const
  StateOrProvinceName: string; const LocalityName: string; const OrganizationName:
  string; const OrganizationalUnitName: string; const CommonName: string; const
  EmailAddress: string; SignType: TCnRSASignDigestType): Boolean;
begin
  Result := False;
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
    BIT STRING  Digestֵ
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
            CertificateRequest.SignDigestType := sdtSHA1;
          // TODO: ֧�ָ����㷨
        end;

        // ����ǩ�����ݣ����� BIT String ��ǰ������ 0
        FreeMemory(CertificateRequest.SignValue);
        CertificateRequest.SignLength := SignNode.BerDataLength - 1;
        CertificateRequest.SignValue := GetMemory(CertificateRequest.SignLength);
        P := Pointer(Integer(SignNode.BerDataAddress) + 1);
        CopyMemory(CertificateRequest.SignValue, P, CertificateRequest.SignLength);

        Result := True;
      end;
    finally
      Reader.Free;
      MemStream.Free;
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
  Result := Result + SCRLF + 'Signature: ' + PrintHex(FSignValue, FSignLength);
end;

end.
