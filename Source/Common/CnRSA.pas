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

unit CnRSA;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�RSA �㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע������ Int64 ��Χ�ڵ� RSA �㷨�Լ������㷨����Կ Exponent �̶�ʹ�� 65537��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2018.05.27 V1.3
*               �ܹ��� Openssl 1.0.2 ���ɵ�δ���ܵĹ�˽Կ PEM ��ʽ�ļ��ж��빫˽Կ����
*               openssl genrsa -out private_pkcs1.pem 2048
*                  // PKCS#1 ��ʽ�Ĺ�˽Կ
*               openssl pkcs8 -topk8 -inform PEM -in private_pkcs1.pem -outform PEM -nocrypt -out private_pkcs8.pem
*                  // PKCS#8 ��ʽ�Ĺ�˽Կ
*               openssl rsa -in private_pkcs1.pem -outform PEM -RSAPublicKey_out -out public_pkcs1.pem
*                  // PKCS#1 ��ʽ�Ĺ�Կ
*               openssl rsa -in private_pkcs1.pem -outform PEM -pubout -out public_pkcs8.pem
*                  // PKCS#8 ��ʽ�Ĺ�Կ
*           2018.05.22 V1.2
*               ����˽Կ��ϳɶ����Է���ʹ��
*           2017.04.05 V1.1
*               ʵ�ִ����� RSA ��Կ������ӽ���
*           2017.04.03 V1.0
*               ������Ԫ��Int64 ��Χ�ڵ� RSA �� CnPrimeNumber �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, CnPrimeNumber, CnBigNumber, CnBase64, CnBerUtils;

type
  TCnRSAKeyType = (cktPKCS1, cktPKCS8);

  TCnRSAPrivateKey = class
  private
    FPrimeKey1: TCnBigNumber;
    FPrimeKey2: TCnBigNumber;
    FPrivKeyProduct: TCnBigNumber;
    FPrivKeyExponent: TCnBigNumber;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property PrimeKey1: TCnBigNumber read FPrimeKey1 write FPrimeKey1;
    {* ������ 1��p}
    property PrimeKey2: TCnBigNumber read FPrimeKey2 write FPrimeKey2;
    {* ������ 2��q}
    property PrivKeyProduct: TCnBigNumber read FPrivKeyProduct write FPrivKeyProduct;
    {* �������˻� n��Ҳ�� Modulus}
    property PrivKeyExponent: TCnBigNumber read FPrivKeyExponent write FPrivKeyProduct;
    {* ˽Կָ�� d}
  end;

  TCnRSAPublicKey = class
  private
    FPubKeyProduct: TCnBigNumber;
    FPubKeyExponent: TCnBigNumber;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property PubKeyProduct: TCnBigNumber read FPubKeyProduct write FPubKeyProduct;
    {* �������˻� n��Ҳ�� Modulus}
    property PubKeyExponent: TCnBigNumber read FPubKeyExponent write FPubKeyExponent;
    {* ��Կָ�� e��65537}
  end;

// Int64 ��Χ�ڵ� RSA �ӽ���ʵ��

function Int64ExtendedEuclideanGcd(A, B: Int64; out X: Int64; out Y: Int64): Int64;
{* ��չŷ�����շת��������Ԫһ�β������� A * X + B * Y = 1 ��������}

function CnInt64RSAGenerateKeys(out PrimeKey1: Integer; out PrimeKey2: Integer;
  out PrivKeyProduct: Int64; out PrivKeyExponent: Int64;
  out PubKeyProduct: Int64; out PubKeyExponent: Int64): Boolean;
{* ���� RSA �㷨����Ĺ�˽Կ�������������� Integer��Keys �������� Int64}

function CnInt64RSAEncrypt(Data: Int64; PrivKeyProduct: Int64;
  PrivKeyExponent: Int64; out Res: Int64): Boolean;
{* �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�}

function CnInt64RSADecrypt(Res: Int64; PubKeyProduct: Int64;
  PubKeyExponent: Int64; out Data: Int64): Boolean;
{* �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�}

// ������Χ�ڵ� RSA �ӽ���ʵ��

function CnRSAGenerateKeys(Bits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey): Boolean;
{* ���� RSA �㷨����Ĺ�˽Կ��Bits ��������Χ�����������Ϊ����}

function CnRSALoadKeysFromPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
{* �� PEM ��ʽ�ļ��м��ع�˽Կ���ݣ���ĳԿ����Ϊ��������}

function CnRSASaveKeysToPem(const PemFileName: string; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType = cktPKCS1): Boolean;
{* ����˽Կд�� PEM ��ʽ�ļ��У������Ƿ�ɹ�}

function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
{* �� PEM ��ʽ�ļ��м��ع�Կ���ݣ������Ƿ�ɹ�}

function CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType = cktPKCS8): BOolean;
{* ����Կд�� PEM ��ʽ�ļ��У������Ƿ�ɹ�}

function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean;
{* �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�}

function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean;
{* �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�}

implementation

const
  // PKCS#1
  PEM_RSA_PRIVATE_HEAD = '-----BEGIN RSA PRIVATE KEY-----';  // �ѽ���
  PEM_RSA_PRIVATE_TAIL = '-----END RSA PRIVATE KEY-----';

  PEM_RSA_PUBLIC_HEAD = '-----BEGIN RSA PUBLIC KEY-----';    // �ѽ���
  PEM_RSA_PUBLIC_TAIL = '-----END RSA PUBLIC KEY-----';

  // PKCS#8
  PEM_PRIVATE_HEAD = '-----BEGIN PRIVATE KEY-----';          // �ѽ���
  PEM_PRIVATE_TAIL = '-----END PRIVATE KEY-----';

  PEM_PUBLIC_HEAD = '-----BEGIN PUBLIC KEY-----';            // �ѽ���
  PEM_PUBLIC_TAIL = '-----END PUBLIC KEY-----';

  // OID Ԥ��д��������̬���������
  OID_RSAENCRYPTION_PKCS1: array[0..8] of Byte = ( // 1.2.840.113549.1.1.1
    $2A, $86, $48, $86, $F7, $0D, $01, $01, $01
  );  // $2A = 40 * 1 + 2


// ���ù�˽Կ�����ݽ��мӽ��ܣ�ע��ӽ���ʹ�õ���ͬһ�׻��ƣ���������
function Int64RSACrypt(Data: Int64; Product: Int64; Exponent: Int64;
  out Res: Int64): Boolean;
begin
  Res := MontgomeryPowerMod(Data, Exponent, Product);
  Result := True;
end;

// ��չŷ�����շת��������Ԫһ�β������� A * X + B * Y = 1 ��������
function Int64ExtendedEuclideanGcd(A, B: Int64; out X: Int64; out Y: Int64): Int64;
var
  R, T: Int64;
begin
  if B = 0 then
  begin
    X := 1;
    Y := 0;
    Result := A;
  end
  else
  begin
    R := Int64ExtendedEuclideanGcd(B, A mod B, X, Y);
    T := X;
    X := Y;
    Y := T - (A div B) * Y;
    Result := R;
  end;
end;

// ���� RSA �㷨����Ĺ�˽Կ�������������� Integer��Keys �������� Int64
function CnInt64RSAGenerateKeys(out PrimeKey1: Integer; out PrimeKey2: Integer;
  out PrivKeyProduct: Int64; out PrivKeyExponent: Int64;
  out PubKeyProduct: Int64; out PubKeyExponent: Int64): Boolean;
var
  N: Integer;
  Product, Y: Int64;
begin
  PrimeKey1 := CnGenerateInt32Prime;

  N := Trunc(Random * 1000);
  Sleep(N);

  PrimeKey2 := CnGenerateInt32Prime;
  if PrimeKey2 > PrimeKey1 then  // һ��ʹ p > q
  begin
    N := PrimeKey1;
    PrimeKey1 := PrimeKey2;
    PrimeKey2 := N;
  end;

  PrivKeyProduct := Int64(PrimeKey1) * Int64(PrimeKey2);
  PubKeyProduct := Int64(PrimeKey2) * Int64(PrimeKey1);   // ���ڹ�˽Կ������ͬ��
  PubKeyExponent := 65537;                                // �̶�

  Product := Int64(PrimeKey1 - 1) * Int64(PrimeKey2 - 1);

  //                      e                d                p
  // ��շת������� PubKeyExponent * PrivKeyExponent mod Product = 1 �е� PrivKeyExponent
  // Ҳ���ǽⷽ�� e * d + p * y = 1������ e��p ��֪���� d �� y��
  Int64ExtendedEuclideanGcd(PubKeyExponent, Product, PrivKeyExponent, Y);
  while PrivKeyExponent < 0 do
  begin
     // ���������� d С�� 0���򲻷�����������Ҫ�� d ���� p���ӵ�������Ϊֹ
     PrivKeyExponent := PrivKeyExponent + Product;
  end;
  Result := True;
end;

// �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�
function CnInt64RSAEncrypt(Data: Int64; PrivKeyProduct: Int64;
  PrivKeyExponent: Int64; out Res: Int64): Boolean;
begin
  Result := Int64RSACrypt(Data, PrivKeyProduct, PrivKeyExponent, Res);
end;

// �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�
function CnInt64RSADecrypt(Res: Int64; PubKeyProduct: Int64;
  PubKeyExponent: Int64; out Data: Int64): Boolean;
begin
  Result := Int64RSACrypt(Res, PubKeyProduct, PubKeyExponent, Data);
end;

function CnRSAGenerateKeys(Bits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey): Boolean;
var
  N: Integer;
  R, Y, Rem, S1, S2, One: TCnBigNumber;
begin
  Result := False;
  if Bits <= 16 then
    Exit;

  PrivateKey.Clear;
  PublicKey.Clear;

  if not BigNumberGeneratePrime(PrivateKey.PrimeKey1, Bits div 8) then
    Exit;

  N := Trunc(Random * 1000);
  Sleep(N);

  if not BigNumberGeneratePrime(PrivateKey.PrimeKey2, Bits div 8) then
    Exit;

  // һ��Ҫ�� Prime1 > Prime2 �Ա���� CRT �Ȳ���
  if BigNumberCompare(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) < 0 then
    BigNumberSwap(PrivateKey.PrimeKey1, PrivateKey.PrimeKey2);

  if not BigNumberMul(PrivateKey.PrivKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
    Exit;

  if not BigNumberMul(PublicKey.PubKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
    Exit;

  PublicKey.PubKeyExponent.SetDec('65537');

  Rem := nil;
  Y := nil;
  R := nil;
  S1 := nil;
  S2 := nil;
  One := nil;

  try
    Rem := TCnBigNumber.Create;
    Y := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    S1 := TCnBigNumber.Create;
    S2 := TCnBigNumber.Create;
    One := TCnBigNumber.Create;

    BigNumberSetOne(One);
    BigNumberSub(S1, PrivateKey.PrimeKey1, One);
    BigNumberSub(S2, PrivateKey.PrimeKey2, One);
    BigNumberMul(R, S1, S2);     // ���������R = (p - 1) * (q - 1)

    // �� e Ҳ���� PubKeyExponent��65537����Ի��� R ��ģ��Ԫ�� d Ҳ���� PrivKeyExponent
    BigNumberExtendedEuclideanGcd(PublicKey.PubKeyExponent, R, PrivateKey.PrivKeyExponent, Y, Rem);

    // ���������� d С�� 0���򲻷�����������Ҫ�� d ���ϻ��� R
    if BigNumberIsNegative(PrivateKey.PrivKeyExponent) then
       BigNumberAdd(PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyExponent, R);
  finally
    One.Free;
    S2.Free;
    S1.Free;
    R.Free;
    Y.Free;
    Rem.Free;
  end;

  Result := True;
end;

function LoadPemFileToMemory(const FileName, ExpectHead, ExpectTail: string;
  MemoryStream: TMemoryStream): Boolean;
var
  I: Integer;
  S: string;
  Sl: TStringList;
begin
  Result := False;

  if (ExpectHead <> '') and (ExpectTail <> '') then
  begin
    Sl := TStringList.Create;
    try
      Sl.LoadFromFile(FileName);
      if Sl.Count > 2 then
      begin
        if Trim(Sl[0]) <> ExpectHead then
          Exit;

        if Trim(Sl[Sl.Count - 1]) = '' then
          Sl.Delete(Sl.Count - 1);

        if Trim(Sl[Sl.Count - 1]) <> ExpectTail then
          Exit;

        Sl.Delete(Sl.Count - 1);
        Sl.Delete(0);
        S := '';
        for I := 0 to Sl.Count - 1 do
          S := S + Sl[I];

        // To De Base64 S
        MemoryStream.Clear;
        Result := (BASE64_OK = Base64Decode(S, MemoryStream));
      end;
    finally
      Sl.Free;
    end;
  end;
end;

procedure PutIndexedBigIntegerToBigInt(Node: TCnBerReadNode; BigNumber: TCnBigNumber);
var
  P: Pointer;
begin
  if (Node = nil) or (Node.BerDataLength <= 0) then
    Exit;

  P := GetMemory(Node.BerDataLength);
  Node.CopyDataTo(P);
  BigNumber.SetBinary(P, Node.BerDataLength);
  FreeMemory(P);
end;

// �� PEM ��ʽ�ļ��м��ع�˽Կ����
(*
PKCS#1:
  RSAPrivateKey ::= SEQUENCE {                        0
    version Version,                                  1 0
    modulus INTEGER, �C n                             2 ��˽Կ
    publicExponent INTEGER, �C e                      3 ��Կ
    privateExponent INTEGER, �C d                     4 ˽Կ
    prime1 INTEGER, �C p                              5 ˽Կ
    prime2 INTEGER, �C q                              6 ˽Կ
    exponent1 INTEGER, �C d mod (p-1)                 7 CRT ϵ�� 1
    exponent2 INTEGER, �C d mod (q-1)                 8 CRT ϵ�� 2
    coefficient INTEGER, �C (inverse of q) mod p      9 CRT ϵ�� 3��q ��� n ��ģ��ϵ�� mod p
    otherPrimeInfos OtherPrimeInfos OPTIONAL          10

    q ��� n ��ģ��ϵ�� x����ָ���� (q * x) mod n = 1 ����ֵ x��
    ��������չŷ�����շת�����ֱ����⣬CRT ϵ�� 3 �� x mod p ��ֵ
  }

PKCS#8:
  PrivateKeyInfo ::= SEQUENCE {
    version         Version,
    algorithm       AlgorithmIdentifier,
    PrivateKey      OCTET STRING
  }

  AlgorithmIdentifier ::= SEQUENCE {
    algorithm       OBJECT IDENTIFIER,
    parameters      ANY DEFINED BY algorithm OPTIONAL
  }
  PrivateKey ������ PKCS#1 �� RSAPrivateKey �ṹ
  Ҳ����
  SEQUENCE (3 elem)
    INTEGER 0
    SEQUENCE (2 elem)
      OBJECT IDENTIFIER 1.2.840.113549.1.1.1 rsaEncryption(PKCS #1)
      NULL
    OCTET STRING (1 elem)
      SEQUENCE (9 elem)
        INTEGER 0
        INTEGER                                       8 ��˽Կ Modulus
        INTEGER                                       9 ��Կ   e
        INTEGER                                       10 ˽Կ  d
        INTEGER                                       11 ˽Կ  p
        INTEGER                                       12 ˽Կ  q
        INTEGER
        INTEGER
        INTEGER
*)
function CnRSALoadKeysFromPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
var
  MemStream: TMemoryStream;
  Ber: TCnBerReader;
  Node: TCnBerReadNode;
begin
  Result := False;
  MemStream := nil;
  Ber := nil;

  try
    MemStream := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_RSA_PRIVATE_HEAD, PEM_RSA_PRIVATE_TAIL, MemStream) then
    begin
      // �� PKCS#1 �� PEM ��˽Կ��ʽ
      Ber := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size);
      if Ber.TotalCount >= 8 then
      begin
        Node := Ber.Items[1]; // 0 ������ Sequence��1 �� Version
        if Node.AsByte = 0 then // ֻ֧�ְ汾 0
        begin
          // 2 �� 3 ���ɹ�Կ
          if PublicKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(Ber.Items[2], PublicKey.PubKeyProduct);
            PutIndexedBigIntegerToBigInt(Ber.Items[3], PublicKey.PubKeyExponent);
          end;

          // 2 4 5 6 ����˽Կ
          if PrivateKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(Ber.Items[2], PrivateKey.PrivKeyProduct);
            PutIndexedBigIntegerToBigInt(Ber.Items[4], PrivateKey.PrivKeyExponent);
            PutIndexedBigIntegerToBigInt(Ber.Items[5], PrivateKey.PrimeKey1);
            PutIndexedBigIntegerToBigInt(Ber.Items[6], PrivateKey.PrimeKey2);
          end;

          Result := True;
        end;
      end;
    end
    else if LoadPemFileToMemory(PemFileName, PEM_PRIVATE_HEAD, PEM_PRIVATE_TAIL, MemStream) then
    begin
      // �� PKCS#8 �� PEM ��˽Կ��ʽ
      Ber := TCnBerReader.Create(PByte(MemStream.Memory), MemStream.Size, True);
      if Ber.TotalCount >= 12 then
      begin
        Node := Ber.Items[1]; // 0 ������ Sequence��1 �� Version
        if Node.AsByte = 0 then // ֻ֧�ְ汾 0
        begin
          // 8 �� 9 ���ɹ�Կ
          if PublicKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(Ber.Items[8], PublicKey.PubKeyProduct);
            PutIndexedBigIntegerToBigInt(Ber.Items[9], PublicKey.PubKeyExponent);
          end;
      
          // 8 10 11 12 ����˽Կ
          if PrivateKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(Ber.Items[8], PrivateKey.PrivKeyProduct);
            PutIndexedBigIntegerToBigInt(Ber.Items[10], PrivateKey.PrivKeyExponent);
            PutIndexedBigIntegerToBigInt(Ber.Items[11], PrivateKey.PrimeKey1);
            PutIndexedBigIntegerToBigInt(Ber.Items[12], PrivateKey.PrimeKey2);
          end;
      
          Result := True;
        end;
      end;
    end;
  finally
    MemStream.Free;
    Ber.Free;
  end;
end;

// �� PEM ��ʽ�ļ��м��ع�Կ����
// ע�� PKCS#8 �� PublicKey �� PEM �ڱ�׼ ASN.1 ������һ���װ��
// �� Modulus �� Exponent ������ BitString �У���Ҫ Paser ��������
(*
PKCS#1:
  RSAPublicKey ::= SEQUENCE {
      modulus           INTEGER,  -- n
      publicExponent    INTEGER   -- e
  }

PKCS#8:
  PublicKeyInfo ::= SEQUENCE {
    algorithm       AlgorithmIdentifier,
    PublicKey       BIT STRING
  }

  AlgorithmIdentifier ::= SEQUENCE {
    algorithm       OBJECT IDENTIFIER,
    parameters      ANY DEFINED BY algorithm OPTIONAL
  }
  Ҳ����
  SEQUENCE (2 elem)
    SEQUENCE (2 elem)
      OBJECT IDENTIFIER 1.2.840.113549.1.1.1 rsaEncryption(PKCS #1)
      NULL
    BIT STRING (1 elem)
      SEQUENCE (2 elem)
        INTEGER     - Modulus
        INTEGER     - Exponent
*)
function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
var
  Mem: TMemoryStream;
  Ber: TCnBerReader;
begin
  Result := False;
  Mem := nil;
  Ber := nil;

  try
    Mem := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_PUBLIC_HEAD, PEM_PUBLIC_TAIL, Mem) then
    begin
      // �� PKCS#8 ��ʽ�Ĺ�Կ
      Ber := TCnBerReader.Create(PByte(Mem.Memory), Mem.Size, True);
      if Ber.TotalCount >= 7 then
      begin
        // 6 �� 7 ���ɹ�Կ
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigInt(Ber.Items[6], PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigInt(Ber.Items[7], PublicKey.PubKeyExponent);
        end;

        Result := True;
      end;
    end
    else if LoadPemFileToMemory(PemFileName, PEM_RSA_PUBLIC_HEAD, PEM_RSA_PUBLIC_TAIL, Mem) then
    begin
      // �� PKCS#1 ��ʽ�Ĺ�Կ
      Ber := TCnBerReader.Create(PByte(Mem.Memory), Mem.Size);
      if Ber.TotalCount >= 3 then
      begin
        // 1 �� 2 ���ɹ�Կ
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigInt(Ber.Items[1], PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigInt(Ber.Items[2], PublicKey.PubKeyExponent);
        end;
      
        Result := True;
      end;
    end;
  finally
    Mem.Free;
    Ber.Free;
  end;
end;

// ����������λ�� 1������Ҫǰ�油 0 �����븺���ı�������
function CalcIntegerTLV(BigNumber: TCnBigNumber): Cardinal;
begin
  Result := BigNumber.GetBytesCount;
  if BigNumber.IsBitSet((Result * 8) - 1) then
    Inc(Result);
end;

procedure SplitStringToList(const S: string; List: TStrings);
const
  LINE_WIDTH = 64;
var
  C, R: string;
begin
  if List = nil then
    Exit;

  List.Clear;
  if S <> '' then
  begin
    R := S;
    while R <> '' do
    begin
      C := Copy(R, 1, LINE_WIDTH);
      Delete(R, 1, LINE_WIDTH);
      List.Add(C);
    end;
  end;
end;

function AddBigNumberToWriter(Writer: TCnBerWriter; Num: TCnBigNumber;
  Parent: TCnBerWriteNode): TCnBerWriteNode;
var
  P: Pointer;
  C, D: Integer;
begin
  Result := nil;
  if (Writer = nil) or (Num = nil) then
    Exit;

  // Integer ������Ҫ�������λ
  C := CalcIntegerTLV(Num);
  if C <= 0 then
    Exit;

  P := GetMemory(C);
  D := C - Num.GetBytesCount;
  ZeroMemory(P, D);
  Num.ToBinary(PAnsiChar(Integer(P) + D));

  Result := Writer.AddBasicNode(CN_BER_TAG_INTEGER, P, C, Parent);
  FreeMemory(P);
end;

// ����˽Կд�� PEM ��ʽ�ļ���
function CnRSASaveKeysToPem(const PemFileName: string; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType): Boolean;
var
  Root, Node: TCnBerWriteNode;
  Writer: TCnBerWriter;
  Mem: TMemoryStream;
  List: TStrings;
  N1, N2, T, R1, R2, Co, X, Y, Rem : TCnBigNumber;
  S: string;
  B: Byte;
begin
  Result := False;
  if (PublicKey = nil) or (PublicKey.PubKeyProduct.GetBytesCount <= 0) or
    (PublicKey.PubKeyExponent.GetBytesCount <= 0) then
    Exit;

  if (PrivateKey = nil) or (PrivateKey.PrivKeyProduct.GetBytesCount <= 0) or
    (PrivateKey.PrivKeyExponent.GetBytesCount <= 0) then
    Exit;

  Mem := nil;
  List := nil;
  Writer := nil;
  T := nil;
  R1 := nil;
  R2 := nil;
  N1 := nil;
  N2 := nil;
  X := nil;
  Y := nil;
  Rem := nil;
  Co := nil;

  try
    T := BigNumberNew;
    R1 := BigNumberNew;
    R2 := BigNumberNew;
    N1 := BigNumberNew;
    N2 := BigNumberNew;
    X := BigNumberNew;
    Y := BigNumberNew;
    Rem := BigNumberNew;
    Co := BigNumberNew;
    if not T.SetOne then
      Exit;

    BigNumberSub(N1, PrivateKey.PrimeKey1, T);
    BigNumberMod(R1, PrivateKey.PrivKeyExponent, N1); // R1 = d mod (p - 1)

    BigNumberSub(N2, PrivateKey.PrimeKey2, T);
    BigNumberMod(R2, PrivateKey.PrivKeyExponent, N2); // R2 = d mod (q - 1)

    // Co = (q ��� n ��ģ��Ԫ��) mod p
    BigNumberExtendedEuclideanGcd(PrivateKey.PrimeKey2, PrivateKey.PrimeKey1,
      X, Y, Rem);
    if BigNumberIsNegative(X) then
      BigNumberAdd(X, X, PrivateKey.PrivKeyExponent); // ���ģ��Ԫ�� X��FIXME: �� X ������

    BigNumberMod(Co, X, PrivateKey.PrimeKey1);        // ��� CRT ϵ��3

    Writer := TCnBerWriter.Create;
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    B := 0;
    if KeyType = cktPKCS1 then
    begin
      // ƴ PKCS1 ��ʽ������
      Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyProduct, Root);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyExponent, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey1, Root);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey2, Root);
      AddBigNumberToWriter(Writer, R1, Root);
      AddBigNumberToWriter(Writer, R2, Root);
      AddBigNumberToWriter(Writer, Co, Root);
    end
    else if KeyType = cktPKCS8 then
    begin
      // ƴ PKCS8 ��ʽ������
      Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Root);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);

      // �� Node1 �� ObjectIdentifier �� Null
      Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_RSAENCRYPTION_PKCS1[0],
        SizeOf(OID_RSAENCRYPTION_PKCS1), Node);
      Writer.AddNullNode(Node);

      Node := Writer.AddContainerNode(CN_BER_TAG_OCTET_STRING, Root);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Node);

      Writer.AddBasicNode(CN_BER_TAG_INTEGER, @B, 1, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyProduct, Node);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrivKeyExponent, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey1, Node);
      AddBigNumberToWriter(Writer, PrivateKey.PrimeKey2, Node);
      AddBigNumberToWriter(Writer, R1, Node);
      AddBigNumberToWriter(Writer, R2, Node);
      AddBigNumberToWriter(Writer, Co, Node);
    end;

    // ������ˣ������ Base64 �ٷֶ���ƴͷβ���д�ļ�
    Mem := TMemoryStream.Create;
    Writer.SaveToStream(Mem);
    Mem.Position := 0;

    if Base64_OK = Base64Encode(Mem, S) then
    begin
      List := TStringList.Create;
      SplitStringToList(S, List);
      if KeyType = cktPKCS1 then
      begin
        List.Insert(0, PEM_RSA_PRIVATE_HEAD);
        List.Add(PEM_RSA_PRIVATE_TAIL);
      end
      else if KeyType = cktPKCS8 then
      begin
        List.Insert(0, PEM_PRIVATE_HEAD);
        List.Add(PEM_PRIVATE_TAIL);
      end;
      List.SaveToFile(PemFileName);
      Result := True;
    end;
  finally
    BigNumberFree(T);
    BigNumberFree(R1);
    BigNumberFree(R2);
    BigNumberFree(N1);
    BigNumberFree(N2);
    BigNumberFree(X);
    BigNumberFree(Y);
    BigNumberFree(Rem);
    BigNumberFree(Co);

    Mem.Free;
    List.Free;
    Writer.Free;
  end;
end;

// ����Կд�� PEM ��ʽ�ļ���
function CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey; KeyType: TCnRSAKeyType): Boolean;
var
  Root, Node: TCnBerWriteNode;
  Writer: TCnBerWriter;
  Mem: TMemoryStream;
  List: TStrings;
  S: string;
begin
  Result := False;
  if (PublicKey = nil) or (PublicKey.PubKeyProduct.GetBytesCount <= 0) or
    (PublicKey.PubKeyExponent.GetBytesCount <= 0) then
    Exit;

  Mem := nil;
  List := nil;
  Writer := nil;
  try
    Writer := TCnBerWriter.Create;
    Root := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE);
    if KeyType = cktPKCS1 then
    begin
      // ƴ PKCS1 ��ʽ�����ݣ��Ƚϼ�
      AddBigNumberToWriter(Writer, PublicKey.PubKeyProduct, Root);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Root);
    end
    else if KeyType = cktPKCS8 then
    begin
      // ƴ PKCS8 ��ʽ������
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Root);

      // �� Node �� ObjectIdentifier �� Null
      Writer.AddBasicNode(CN_BER_TAG_OBJECT_IDENTIFIER, @OID_RSAENCRYPTION_PKCS1[0],
        SizeOf(OID_RSAENCRYPTION_PKCS1), Node);
      Writer.AddNullNode(Node);

      Node := Writer.AddContainerNode(CN_BER_TAG_BIT_STRING, Root);
      Node := Writer.AddContainerNode(CN_BER_TAG_SEQUENCE, Node);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyProduct, Node);
      AddBigNumberToWriter(Writer, PublicKey.PubKeyExponent, Node);
    end;

    // ������ˣ������ Base64 �ٷֶ���ƴͷβ���д�ļ�
    Mem := TMemoryStream.Create;
    Writer.SaveToStream(Mem);
    Mem.Position := 0;

    if Base64_OK = Base64Encode(Mem, S) then
    begin
      List := TStringList.Create;
      SplitStringToList(S, List);
      if KeyType = cktPKCS1 then
      begin
        List.Insert(0, PEM_RSA_PUBLIC_HEAD);
        List.Add(PEM_RSA_PUBLIC_TAIL);
      end
      else if KeyType = cktPKCS8 then
      begin
        List.Insert(0, PEM_PUBLIC_HEAD);
        List.Add(PEM_PUBLIC_TAIL);
      end;
      List.SaveToFile(PemFileName);
      Result := True;
    end;
  finally
    Mem.Free;
    List.Free;
    Writer.Free;
  end;
end;

// ���ù�˽Կ�����ݽ��мӽ��ܣ�ע��ӽ���ʹ�õ���ͬһ�׻��ƣ���������
function RSACrypt(Data: TCnBigNumber; Product: TCnBigNumber; Exponent: TCnBigNumber;
  out Res: TCnBigNumber): Boolean;
begin
  Result := BigNumberMontgomeryPowerMod(Res, Data, Exponent, Product);
end;

// �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�
function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean;
begin
  Result := RSACrypt(Data, PrivateKey.PrivKeyProduct, PrivateKey.PrivKeyExponent, Res);
end;

// �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�
function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean;
begin
  Result := RSACrypt(Res, PublicKey.PubKeyProduct, PublicKey.PubKeyExponent, Data);
end;

{ TCnRSAPrivateKey }

procedure TCnRSAPrivateKey.Clear;
begin
  FPrimeKey1.Clear;
  FPrimeKey2.Clear;
  FPrivKeyProduct.Clear;
  FPrivKeyExponent.Clear;
end;

constructor TCnRSAPrivateKey.Create;
begin
  FPrimeKey1 := TCnBigNumber.Create;
  FPrimeKey2 := TCnBigNumber.Create;
  FPrivKeyProduct := TCnBigNumber.Create;
  FPrivKeyExponent := TCnBigNumber.Create;
end;

destructor TCnRSAPrivateKey.Destroy;
begin
  FPrimeKey1.Free;
  FPrimeKey2.Free;
  FPrivKeyProduct.Free;
  FPrivKeyExponent.Free;
  inherited;
end;

{ TCnRSAPublicKey }

procedure TCnRSAPublicKey.Clear;
begin
  FPubKeyProduct.Clear;
  FPubKeyExponent.Clear;
end;

constructor TCnRSAPublicKey.Create;
begin
  FPubKeyProduct := TCnBigNumber.Create;
  FPubKeyExponent := TCnBigNumber.Create;
end;

destructor TCnRSAPublicKey.Destroy;
begin
  FPubKeyExponent.Free;
  FPubKeyProduct.Free;
  inherited;
end;

end.
