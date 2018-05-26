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
* �޸ļ�¼��2018.05.26 V1.3
*               �ܹ��� Openssl ���ɵĹ�˽Կ PEM ��ʽ�ļ��ж��빫˽Կ����
*               openssl genrsa -out private.pem 2048
*               openssl rsa -in private.pem -outform PEM -pubout -out public.pem
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
  SysUtils, Classes, Windows, CnPrimeNumber, CnBigNumber, CnBase64, CnBerParser;

type
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
    {* ������ 1}
    property PrimeKey2: TCnBigNumber read FPrimeKey2 write FPrimeKey2;
    {* ������ 2}
    property PrivKeyProduct: TCnBigNumber read FPrivKeyProduct write FPrivKeyProduct;
    {* �������˻���Ҳ�� Modulus}
    property PrivKeyExponent: TCnBigNumber read FPrivKeyExponent write FPrivKeyProduct;
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
    {* �������˻���Ҳ�� Modulus}
    property PubKeyExponent: TCnBigNumber read FPubKeyExponent write FPubKeyExponent;
  end;

// Int64 ��Χ�ڵ� RSA �ӽ���ʵ��

// function Int64ExtendedEuclideanGcd(A, B: Int64; out X: Int64; out Y: Int64): Int64;
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

procedure CnRSASaveKeysToPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey);
{* ����˽Կд�� PEM ��ʽ�ļ���}

function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
{* �� PEM ��ʽ�ļ��м��ع�Կ���ݣ������Ƿ�ɹ�}

procedure CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey);
{* ����Կд�� PEM ��ʽ�ļ���}

function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean;
{* �����������ɵ�˽Կ�����ݽ��м��ܣ����ؼ����Ƿ�ɹ�}

function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean;
{* �����������ɵĹ�Կ�����ݽ��н��ܣ����ؽ����Ƿ�ɹ�}

implementation

const
  PEM_PRIVATE_HEAD = '-----BEGIN RSA PRIVATE KEY-----';
  PEM_PRIVATE_TAIL = '-----END RSA PRIVATE KEY-----';
  PEM_PUBLIC_HEAD = '-----BEGIN PUBLIC KEY-----';
  PEM_PUBLIC_TAIL = '-----END PUBLIC KEY-----';

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
  P, Y, R, S1, S2, One: TCnBigNumber;
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

  if not BigNumberMul(PrivateKey.PrivKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
    Exit;

  if not BigNumberMul(PublicKey.PubKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
    Exit;

  PublicKey.PubKeyExponent.SetDec('65537');

  R := nil;
  Y := nil;
  P := nil;
  S1 := nil;
  S2 := nil;
  One := nil;

  try
    R := TCnBigNumber.Create;
    Y := TCnBigNumber.Create;
    P := TCnBigNumber.Create;
    S1 := TCnBigNumber.Create;
    S2 := TCnBigNumber.Create;
    One := TCnBigNumber.Create;

    BigNumberSetOne(One);
    BigNumberSub(S1, PrivateKey.PrimeKey1, One);
    BigNumberSub(S2, PrivateKey.PrimeKey2, One);
    BigNumberMul(P, S1, S2);

    BigNumberExtendedEuclideanGcd(PublicKey.PubKeyExponent, P, PrivateKey.PrivKeyExponent, Y, R);

    // ���������� d С�� 0���򲻷�����������Ҫ�� d ���� p
    if BigNumberIsNegative(PrivateKey.PrivKeyExponent) then
       BigNumberAdd(PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyExponent, P);
  finally
    One.Free;
    S2.Free;
    S1.Free;
    P.Free;
    Y.Free;
    R.Free;
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
  end
  else
  begin
    MemoryStream.LoadFromFile(FileName);
    Result := True;
  end;
end;

// �� PEM ��ʽ�ļ��м��ع�˽Կ����
(*
  RSAPrivateKey ::= SEQUENCE {                        0
    version Version,                                  1
    modulus INTEGER, �C n                             2 ��˽Կ
    publicExponent INTEGER, �C e                      3 ��Կ
    privateExponent INTEGER, �C d                     4 ˽Կ
    prime1 INTEGER, �C p                              5 ˽Կ
    prime2 INTEGER, �C q                              6 ˽Կ
    exponent1 INTEGER, �C d mod (p-1)                 7
    exponent2 INTEGER, �C d mod (q-1)                 8
    coefficient INTEGER, �C (inverse of q) mod p      9
    otherPrimeInfos OtherPrimeInfos OPTIONAL          10
  }
*)
function CnRSALoadKeysFromPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
var
  MemStream: TMemoryStream;
  Ber: TCnBerParser;
  Node: TCnBerNode;
  Buf: Pointer;

  procedure PutIndexedBigIntegerToBigInt(Idx: Integer; BigNumber: TCnBigNumber);
  begin
    Node := Ber.Items[Idx];
    ReallocMem(Buf, Node.BerDataLength);
    Node.CopyDataTo(Buf);
    BigNumber.SetBinary(Buf, Node.BerDataLength);
  end;

begin
  Result := False;
  MemStream := nil;
  Ber := nil;

  try
    MemStream := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_PRIVATE_HEAD, PEM_PRIVATE_TAIL, MemStream) then
    begin
      Ber := TCnBerParser.Create(PByte(MemStream.Memory), MemStream.Size);
      if Ber.TotalCount >= 8 then
      begin
        Node := Ber.Items[1]; // 0 ������ Sequence��1 �� Version
        if Node.AsByte = 0 then // ֻ֧�ְ汾 0
        begin
          Buf := nil;
          // 2 �� 3 ���ɹ�Կ
          if PublicKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(2, PublicKey.PubKeyProduct);
            PutIndexedBigIntegerToBigInt(3, PublicKey.PubKeyExponent);
          end;

          // 2 4 5 6 ����˽Կ
          if PrivateKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(2, PrivateKey.PrivKeyProduct);
            PutIndexedBigIntegerToBigInt(4, PrivateKey.PrivKeyExponent);
            PutIndexedBigIntegerToBigInt(5, PrivateKey.PrimeKey1);
            PutIndexedBigIntegerToBigInt(6, PrivateKey.PrimeKey2);
          end;

          ReallocMem(Buf, 0);
          Result := True;
        end;
      end;
    end;
  finally
    MemStream.Free;
    Ber.Free;
  end;
end;

// ����˽Կд�� PEM ��ʽ�ļ���
procedure CnRSASaveKeysToPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey);
begin

end;

// �� PEM ��ʽ�ļ��м��ع�Կ����
// ע�� PublicKey �� PEM �ڱ�׼ ASN.1 ������һ���װ��
// �� Modulus �� Exponent ������ BitString �У���Ҫ��������
(*

*)
function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
var
  Mem: TMemoryStream;
  Ber: TCnBerParser;
  Node: TCnBerNode;
  Buf: Pointer;
  
  procedure PutIndexedBigIntegerToBigInt(Idx: Integer; BigNumber: TCnBigNumber);
  begin
    Node := Ber.Items[Idx];
    ReallocMem(Buf, Node.BerDataLength);
    Node.CopyDataTo(Buf);
    BigNumber.SetBinary(Buf, Node.BerDataLength);
  end;

begin
  Result := False;
  Mem := nil;
  Ber := nil;

  try
    Mem := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_PUBLIC_HEAD, PEM_PUBLIC_TAIL, Mem) then
    begin
      Ber := TCnBerParser.Create(PByte(Mem.Memory), Mem.Size, True);
      if Ber.TotalCount >= 7 then
      begin
        Buf := nil;
        // 2 �� 3 ���ɹ�Կ
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigInt(6, PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigInt(7, PublicKey.PubKeyExponent);
        end;

        ReallocMem(Buf, 0);
        Result := True;
      end;
    end;
  finally
    Mem.Free;
    Ber.Free;
  end;
end;

// ����Կд�� PEM ��ʽ�ļ���
procedure CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey);
begin

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
