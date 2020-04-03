{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
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

unit CnSM2;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�SM2 ��Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��Ҫʵ�ֻ��� SM2 �����ݼӽ��ܡ�ǩ����ǩ����Կ����
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.04.02 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnECC, CnBigNumber, CnSM3, CnKDF;

type
  TCnSM2 = class(TCnEcc)
  public
    constructor Create; override;
  end;

function CnSM2EncryptData(PlainData: Pointer; DataLen: Integer; OutStream:
  TStream; PublicKey: TCnEccPublicKey; Sm2: TCnSm2 = nil): Boolean;
{* �ù�Կ�����ݿ���м��ܣ��ο� GM/T0003.4-2012��SM2��Բ���߹�Կ�����㷨
   ��4����:��Կ�����㷨���е�������򣬲�ͬ����ͨ ECC �� RSA �Ķ������}

function CnSM2DecryptData(EnData: Pointer; DataLen: Integer; OutStream: TStream;
  PrivateKey: TCnEccPrivateKey; Sm2: TCnSm2 = nil): Boolean;
{* �ù�Կ�����ݿ���н��ܣ��ο� GM/T0003.4-2012��SM2��Բ���߹�Կ�����㷨
   ��4����:��Կ�����㷨���е�������򣬲�ͬ����ͨ ECC �� RSA �Ķ������}

function CnSM2SignData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  OutSignature: TCnEccPoint; PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey;
  Sm2: TCnSM2 = nil): Boolean;
{* ˽Կ�����ݿ�ǩ������ GM/T0003.2-2012��SM2��Բ���߹�Կ�����㷨
   ��2����:����ǩ���㷨���е��������Ҫ����ǩ������������Ϣ�Լ���Կ������ժҪ}

implementation

{ TCnSM2 }

constructor TCnSM2.Create;
begin
  inherited;
  Load(ctSM2);
end;

{
  �������� M���� MLen �ֽڣ�������� k������

  Cl = k * G => (xl, yl)         // ��ѹ���洢������Ϊ��������λ���� 1

  k * PublicKey => (x2, y2)
  t <= KDF(x2��y2, Mlen)
  C2 <= M xor t                  // ���� MLen

  C3 <= SM3(x2��M��y2)           // ���� 32 �ֽ�

  ����Ϊ��C1��C3��C2
}
function CnSM2EncryptData(PlainData: Pointer; DataLen: Integer; OutStream:
  TStream; PublicKey: TCnEccPublicKey; Sm2: TCnSm2 = nil): Boolean;
var
  Py, P1, P2: TCnEccPoint;
  K: TCnBigNumber;
  B: Byte;
  M: PAnsiChar;
  I: Integer;
  Buf: array of Byte;
  KDFStr, T, C3H: AnsiString;
  Sm3Dig: TSM3Digest;
  Sm2IsNil: Boolean;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (OutStream = nil) or (PublicKey = nil) then
    Exit;

  Py := nil;
  P1 := nil;
  P2 := nil;
  K := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    K := TCnBigNumber.Create;

    // ȷ����Կ X Y ������
    if PublicKey.Y.IsZero then
    begin
      Py := TCnEccPoint.Create;
      if not Sm2.PlainToPoint(PublicKey.X, Py) then
        Exit;
      BigNumberCopy(PublicKey.Y, Py.Y);
    end;

    // ����һ����� K
    if not BigNumberRandRange(K, Sm2.Order) then
      Exit;
    // K.SetHex('384F30353073AEECE7A1654330A96204D37982A3E15B2CB5');

    P1 := TCnEccPoint.Create;
    P1.Assign(Sm2.Generator);
    Sm2.MultiplePoint(K, P1);  // ����� K * G �õ� X1 Y1

    B := 4;
    OutStream.Position := 0;

    OutStream.Write(B, 1);
    SetLength(Buf, P1.X.GetBytesCount);
    P1.X.ToBinary(@Buf[0]);
    OutStream.Write(Buf[0], P1.X.GetBytesCount);
    SetLength(Buf, P1.Y.GetBytesCount);
    P1.Y.ToBinary(@Buf[0]);
    OutStream.Write(Buf[0], P1.Y.GetBytesCount); // ƴ�� C1

    P2 := TCnEccPoint.Create;
    P2.Assign(PublicKey);
    Sm2.MultiplePoint(K, P2); // ����� K * PublicKey �õ� X2 Y2

    SetLength(KDFStr, P2.X.GetBytesCount + P2.Y.GetBytesCount);
    P2.X.ToBinary(@KDFStr[1]);
    P2.Y.ToBinary(@KDFStr[P2.X.GetBytesCount + 1]);
    T := CnSM2KDF(KDFStr, DataLen);

    M := PAnsiChar(PlainData);
    for I := 1 to DataLen do
      T[I] := AnsiChar(Byte(T[I]) xor Byte(M[I - 1])); // T ���� C2�����Ȳ���д

    SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + DataLen);
    P2.X.ToBinary(@C3H[1]);
    Move(M[0], C3H[P2.X.GetBytesCount + 1], DataLen);
    P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + DataLen + 1]); // ƴ���� C3 ��
    Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

    OutStream.Write(Sm3Dig[0], SizeOf(TSM3Digest));        // д�� C3
    OutStream.Write(T[1], DataLen);                        // д�� C2
    Result := True;
  finally
    P2.Free;
    P1.Free;
    Py.Free;
    K.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

{
  MLen <= DataLen - SM3DigLength - 2 * Sm2 Byte Length - 1�������õ� C1 C2 C3

  PrivateKey * C1 => (x2, y2)

  t <= KDF(x2��y2, Mlen)

  M' <= C2 xor t

  ���ɶԱ� SM3(x2��M��y2) Hash �Ƿ��� C3 ���
}
function CnSM2DecryptData(EnData: Pointer; DataLen: Integer; OutStream: TStream;
  PrivateKey: TCnEccPrivateKey; Sm2: TCnSM2): Boolean;
var
  MLen: Integer;
  M: PAnsiChar;
  MP: AnsiString;
  KDFStr, T, C3H: AnsiString;
  Sm2IsNil: Boolean;
  P2: TCnEccPoint;
  I: Integer;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (EnData = nil) or (DataLen <= 0) or (OutStream = nil) or (PrivateKey = nil) then
    Exit;

  P2 := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    MLen := DataLen - SizeOf(TSM3Digest) - (Sm2.BitsCount div 4) - 1;
    if MLen <= 0 then
      Exit;

    P2 := TCnEccPoint.Create;
    M := PAnsiChar(EnData);
    Inc(M);
    P2.X.SetBinary(M, Sm2.BitsCount div 8);
    Inc(M, Sm2.BitsCount div 8);
    P2.Y.SetBinary(M, Sm2.BitsCount div 8);
    Sm2.MultiplePoint(PrivateKey, P2);

    SetLength(KDFStr, P2.X.GetBytesCount + P2.Y.GetBytesCount);
    P2.X.ToBinary(@KDFStr[1]);
    P2.Y.ToBinary(@KDFStr[P2.X.GetBytesCount + 1]);
    T := CnSM2KDF(KDFStr, MLen);

    SetLength(MP, MLen);
    M := PAnsiChar(EnData);
    Inc(M, SizeOf(TSM3Digest) + (Sm2.BitsCount div 4) + 1);
    for I := 1 to MLen do
      MP[I] := AnsiChar(Byte(M[I - 1]) xor Byte(T[I])); // MP �õ�����

    SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + MLen);
    P2.X.ToBinary(@C3H[1]);
    Move(MP[1], C3H[P2.X.GetBytesCount + 1], MLen);
    P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + MLen + 1]);    // ƴ���� C3 ��
    Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

    M := PAnsiChar(EnData);
    Inc(M, (Sm2.BitsCount div 4) + 1);
    if CompareMem(@Sm3Dig[0], M, SizeOf(TSM3Digest)) then  // �ȶ� Hash �Ƿ����
    begin
      OutStream.Write(MP[1], Length(MP));
      Result := True;
    end;
  finally
    P2.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

{
  ZA = Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
  e = Hash(ZA��M)

  k * G => (x1, y1)

  r <= (e + x1) mod n

  s <= ((1 + PrivateKey)^-1 * (k - r * PrivateKey)) mod n
}
function CnSM2SignData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  OutSignature: TCnEccPoint; PrivateKey: TCnEccPrivateKey; PublicKey: TCnEccPublicKey;
  Sm2: TCnSM2): Boolean;
var
  Stream: TMemoryStream;
  Len: Integer;
  K, R, E: TCnBigNumber;
  P: TCnEccPoint;
  ULen: Word;
  Sm2IsNil: Boolean;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (OutSignature = nil) or (PrivateKey = nil) then
    Exit;

  K := nil;
  P := nil;
  E := nil;
  R := nil;
  Stream := nil;
  Sm2IsNil := Sm2 = nil;

  try
    if Sm2IsNil then
      Sm2 := TCnSM2.Create;

    Len := Length(UserID) * 8;
    ULen := ((Len and $FF) shl 8) or ((Len and $FF00) shr 8);

    Stream := TMemoryStream.Create;
    Stream.Write(ULen, SizeOf(ULen));
    if ULen > 0 then
      Stream.Write(UserID[1], Length(UserID));

    BigNumberWriteBinaryToStream(Sm2.CoefficientA, Stream);
    BigNumberWriteBinaryToStream(Sm2.CoefficientB, Stream);
    BigNumberWriteBinaryToStream(Sm2.Generator.X, Stream);
    BigNumberWriteBinaryToStream(Sm2.Generator.Y, Stream);
    BigNumberWriteBinaryToStream(PublicKey.X, Stream);
    BigNumberWriteBinaryToStream(PublicKey.Y, Stream);

    Sm3Dig := SM3(PAnsiChar(Stream.Memory), Stream.Size);  // ��� ZA
    Stream.Clear;
    Stream.Write(Sm3Dig[0], SizeOf(TSM3Digest));
    Stream.Write(PlainData^, DataLen);

    Sm3Dig := SM3(PAnsiChar(Stream.Memory), Stream.Size);  // �ٴ�����Ӵ�ֵ e

    P := TCnEccPoint.Create;
    E := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    K := TCnBigNumber.Create;

    while True do
    begin
      // ����һ����� K
      if not BigNumberRandRange(K, Sm2.Order) then
        Exit;
      // K.SetHex('6CB28D99385C175C94F94E934817663FC176D925DD72B727260DBAAE1FB2F96F');

      P.Assign(Sm2.Generator);
      Sm2.MultiplePoint(K, P);

      // ���� R = (e + x) mod N
      E.SetBinary(@Sm3Dig[0], SizeOf(TSM3Digest));
      if not BigNumberAdd(E, E, P.X) then
        Exit;
      if not BigNumberMod(R, E, Sm2.Order) then // ��� R �� E ������
        Exit;

      if R.IsZero then  // R ����Ϊ 0
        Continue;

      if not BigNumberAdd(E, R, K) then
        Exit;
      if BigNumberCompare(E, Sm2.Order) = 0 then // R + K = N Ҳ����
        Continue;

      BigNumberCopy(OutSignature.X, R);  // �õ�һ��ǩ��ֵ R

      BigNumberCopy(E, PrivateKey);
      BigNumberAddWord(E, 1);
      BigNumberModularInverse(R, E, Sm2.Order);      // ����Ԫ�õ� (1 + PrivateKey)^-1������ R ��

      // �� K - R * PrivateKey�������� E ��
      if not BigNumberMul(E, OutSignature.X, PrivateKey) then
        Exit;
      if not BigNumberSub(E, K, E) then
        Exit;

      if not BigNumberMul(R, E, R) then // (1 + PrivateKey)^-1 * (K - R * PrivateKey) ���� R ��
        Exit;

      if not BigNumberNonNegativeMod(OutSignature.Y, R, Sm2.Order) then // ע����������Ϊ��
        Exit;

      Result := True;
      Break;
    end;
  finally
    Stream.Free;
    K.Free;
    P.Free;
    R.Free;
    E.Free;
    if Sm2IsNil then
      Sm2.Free;
  end;
end;

end.

