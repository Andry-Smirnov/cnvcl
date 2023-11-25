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

unit CnOTS;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�һ�����Ӵ�ǩ���㷨ʵ�ֵ�Ԫ��Ŀǰʵ���˻��� SM3 �� SHA256 �ļ�ʵ��
* ��Ԫ���ߣ���Х
* ��    ע��Hash Based One Time Signature���������ȵ��Ӵ��㷨��δʵ��
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2023.11.25 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnNative, CnBits, CnRandom, CnSM3, CnSHA2;

type
  TCnOTSSM3PrivateKey = array[0..(SizeOf(TCnSM3Digest) * 8 * 2) - 1] of TCnSM3Digest;
  {* ���� SM3 �Ӵ��㷨��һ�����Ӵ�ǩ��˽Կ��Ϊ 256 * 2 �����ֵ��Ϊһ�����������ȡ SM3 �Ľ������}

  TCnOTSSM3PublicKey = array[0..(SizeOf(TCnSM3Digest) * 8 * 2) - 1] of TCnSM3Digest;
  {* ���� SM3 �Ӵ��㷨��һ�����Ӵ�ǩ����Կ��Ϊ 256 * 2 �����ֵ�� SM3 �Ӵ�ֵ}

  TCnOTSSM3Signature = array[0..(SizeOf(TCnSM3Digest) * 8) - 1] of TCnSM3Digest;
  {* ���� SM3 �Ӵ��㷨��һ�����Ӵ�ǩ��ֵ��ʵ������ 256 �� SM3 �Ӵ�ֵ}

  TCnOTSSM3VerificationKey = array[0..(SizeOf(TCnSM3Digest) * 8) - 1] of TCnSM3Digest;
  {* ���� SM3 �Ӵ��㷨��һ�����Ӵ�ǩ����֤��Կ��ʵ�����Ǵ�˽Կ�г�ȡ�� 256 �����ֵ}

  TCnOTSSHA256PrivateKey = array[0..(SizeOf(TCnSHA256Digest) * 8 * 2) - 1] of TCnSHA256Digest;
  {* ���� SHA256 �Ӵ��㷨��һ�����Ӵ�ǩ��˽Կ��Ϊ 256 * 2 �����ֵ��Ϊһ�����������ȡ SHA256 �Ľ������}

  TCnOTSSHA256PublicKey = array[0..(SizeOf(TCnSHA256Digest) * 8 * 2) - 1] of TCnSHA256Digest;
  {* ���� SHA256 �Ӵ��㷨��һ�����Ӵ�ǩ����Կ��Ϊ 256 * 2 �����ֵ�� SHA256 �Ӵ�ֵ}

  TCnOTSSHA256Signature = array[0..(SizeOf(TCnSHA256Digest) * 8) - 1] of TCnSHA256Digest;
  {* ���� SHA256 �Ӵ��㷨��һ�����Ӵ�ǩ��ֵ��ʵ������ 256 �� SHA256 �Ӵ�ֵ}

  TCnOTSSHA256VerificationKey = array[0..(SizeOf(TCnSHA256Digest) * 8) - 1] of TCnSHA256Digest;
  {* ���� SHA256 �Ӵ��㷨��һ�����Ӵ�ǩ����֤��Կ��ʵ�����Ǵ�˽Կ�г�ȡ�� 256 �����ֵ}

function CnOTSSM3GenerateKeys(var PrivateKey: TCnOTSSM3PrivateKey;
  var PublicKey: TCnOTSSM3PublicKey): Boolean;
{* ����һ�Ի��� SM3 �Ӵ��㷨��һ�����Ӵ�ǩ����˽Կ�����������Ƿ�ɹ�}

procedure CnOTSSM3SignData(Data: Pointer; DataByteLen: Integer;
  PrivateKey: TCnOTSSM3PrivateKey; PublicKey: TCnOTSSM3PublicKey;
  var OutSignature: TCnOTSSM3Signature; var OutVerifyKey: TCnOTSSM3VerificationKey);
{* ���ݹ�˽Կ����ָ���ڴ�����ݵ�һ�����Ӵ�ǩ������֤���ǩ������Կ��
  ƽʱ�������ġ�ǩ��ֵ�빫Կ������֤����ʱ������֤��������֤��Կ��
  ��֤��Կʵ������˽Կ��һ���֣������֤��Կ�������ͬ��ֻ����֤��һ�Σ�
  ������������˽Կ�������Ϣǩ���ˣ�������һ����ǩ���ĺ���}

function CnOTSSM3VerifyData(Data: Pointer; DataByteLen: Integer;
  Signature: TCnOTSSM3Signature; PublicKey: TCnOTSSM3PublicKey;
  VerifyKey: TCnOTSSM3VerificationKey): Boolean;
{* �������ġ���������֤��Կ�빫Կ��ָ֤���ڴ�����ݵ�ǩ���Ƿ���ȷ��������֤�Ƿ�ɹ�}

procedure CnOTSSM3SignBytes(Data: TBytes; PrivateKey: TCnOTSSM3PrivateKey;
  PublicKey: TCnOTSSM3PublicKey; var OutSignature: TCnOTSSM3Signature;
  var OutVerifyKey: TCnOTSSM3VerificationKey);
{* ���ݹ�˽Կ�����ֽ������һ�����Ӵ�ǩ������֤���ǩ������Կ��
  ƽʱ�������ġ�ǩ��ֵ�빫Կ������֤����ʱ������֤��������֤��Կ��
  ��֤��Կʵ������˽Կ��һ���֣������֤��Կ�������ͬ��ֻ����֤��һ�Σ�
  ������������˽Կ�������Ϣǩ���ˣ�������һ����ǩ���ĺ���}

function CnOTSSM3VerifyBytes(Data: TBytes; Signature: TCnOTSSM3Signature;
  PublicKey: TCnOTSSM3PublicKey; VerifyKey: TCnOTSSM3VerificationKey): Boolean;
{* �������ġ���������֤��Կ�빫Կ��֤�ֽ������ǩ���Ƿ���ȷ��������֤�Ƿ�ɹ�}

function CnOTSSHA256GenerateKeys(var PrivateKey: TCnOTSSHA256PrivateKey;
  var PublicKey: TCnOTSSHA256PublicKey): Boolean;
{* ����һ�Ի��� SHA256 �Ӵ��㷨��һ�����Ӵ�ǩ����˽Կ�����������Ƿ�ɹ�}

procedure CnOTSSHA256SignData(Data: Pointer; DataByteLen: Integer;
  PrivateKey: TCnOTSSHA256PrivateKey; PublicKey: TCnOTSSHA256PublicKey;
  var OutSignature: TCnOTSSHA256Signature; var OutVerifyKey: TCnOTSSHA256VerificationKey);
{* ���ݹ�˽Կ����ָ���ڴ�����ݵ�һ�����Ӵ�ǩ������֤���ǩ������Կ��
  ƽʱ�������ġ�ǩ��ֵ�빫Կ������֤����ʱ������֤��������֤��Կ��
  ��֤��Կʵ������˽Կ��һ���֣������֤��Կ�������ͬ��ֻ����֤��һ�Σ�
  ������������˽Կ�������Ϣǩ���ˣ�������һ����ǩ���ĺ���}

function CnOTSSHA256VerifyData(Data: Pointer; DataByteLen: Integer;
  Signature: TCnOTSSHA256Signature; PublicKey: TCnOTSSHA256PublicKey;
  VerifyKey: TCnOTSSHA256VerificationKey): Boolean;
{* �������ġ���������֤��Կ�빫Կ��ָ֤���ڴ�����ݵ�ǩ���Ƿ���ȷ��������֤�Ƿ�ɹ�}

procedure CnOTSSHA256SignBytes(Data: TBytes; PrivateKey: TCnOTSSHA256PrivateKey;
  PublicKey: TCnOTSSHA256PublicKey; var OutSignature: TCnOTSSHA256Signature;
  var OutVerifyKey: TCnOTSSHA256VerificationKey);
{* ���ݹ�˽Կ�����ֽ������һ�����Ӵ�ǩ������֤���ǩ������Կ��
  ƽʱ�������ġ�ǩ��ֵ�빫Կ������֤����ʱ������֤��������֤��Կ��
  ��֤��Կʵ������˽Կ��һ���֣������֤��Կ�������ͬ��ֻ����֤��һ�Σ�
  ������������˽Կ�������Ϣǩ���ˣ�������һ����ǩ���ĺ���}

function CnOTSSHA256VerifyBytes(Data: TBytes; Signature: TCnOTSSHA256Signature;
  PublicKey: TCnOTSSHA256PublicKey; VerifyKey: TCnOTSSHA256VerificationKey): Boolean;
{* �������ġ���������֤��Կ�빫Կ��֤�ֽ������ǩ���Ƿ���ȷ��������֤�Ƿ�ɹ�}

implementation

function CnOTSSM3GenerateKeys(var PrivateKey: TCnOTSSM3PrivateKey;
  var PublicKey: TCnOTSSM3PublicKey): Boolean;
var
  I: Integer;
begin
  Result := CnRandomFillBytes(@PrivateKey[0], SizeOf(TCnOTSSM3PrivateKey));
  if Result then
    for I := Low(TCnOTSSM3PublicKey) to High(TCnOTSSM3PublicKey) do
      PublicKey[I] := SM3(@PrivateKey[I], SizeOf(TCnSM3Digest));
end;

procedure CnOTSSM3SignData(Data: Pointer; DataByteLen: Integer;
  PrivateKey: TCnOTSSM3PrivateKey; PublicKey: TCnOTSSM3PublicKey;
  var OutSignature: TCnOTSSM3Signature; var OutVerifyKey: TCnOTSSM3VerificationKey);
var
  I: Integer;
  Bits: TCnBitBuilder;
  Dig: TCnSM3Digest;
begin
  Dig := SM3(PAnsiChar(Data), DataByteLen);
  Bits := TCnBitBuilder.Create;
  try
    Bits.AppendData(@Dig[0], SizeOf(TCnSM3Digest));

    for I := 0 to Bits.BitLength - 1 do
    begin
      if Bits.Bit[I] then // �� 1
      begin
        OutSignature[I] := PublicKey[I * 2 + 1];
        OutVerifyKey[I] := PrivateKey[I * 2 + 1];
      end
      else
      begin
        OutSignature[I] := PublicKey[I * 2];
        OutVerifyKey[I] := PrivateKey[I * 2];
      end;
    end;
  finally
    Bits.Free;
  end;
end;

function CnOTSSM3VerifyData(Data: Pointer; DataByteLen: Integer;
  Signature: TCnOTSSM3Signature; PublicKey: TCnOTSSM3PublicKey;
  VerifyKey: TCnOTSSM3VerificationKey): Boolean;
var
  I: Integer;
  Bits: TCnBitBuilder;
  Dig, Cmp: TCnSM3Digest;
begin
  Result := False;
  Dig := SM3(PAnsiChar(Data), DataByteLen);
  Bits := TCnBitBuilder.Create;
  try
    Bits.AppendData(@Dig[0], SizeOf(TCnSM3Digest));

    for I := 0 to Bits.BitLength - 1 do
    begin
      Cmp := SM3(@VerifyKey[I], SizeOf(TCnSM3Digest)); // ����˽Կ���Ӵ�ֵ
      if Bits.Bit[I] then 
        Result := SM3Match(Cmp, PublicKey[I * 2 + 1])  // ��λ�� 1���Ƚ� 1 ��Ӧ�Ĺ�Կ
      else
        Result := SM3Match(Cmp, PublicKey[I * 2]);     // ��λ�� 0���Ƚ� 0 ��Ӧ�Ĺ�Կ

      if not Result then
        Exit;
    end;
  finally
    Bits.Free;
  end;
end;

procedure CnOTSSM3SignBytes(Data: TBytes; PrivateKey: TCnOTSSM3PrivateKey;
  PublicKey: TCnOTSSM3PublicKey; var OutSignature: TCnOTSSM3Signature;
  var OutVerifyKey: TCnOTSSM3VerificationKey);
begin
  if Length(Data) = 0 then
    CnOTSSM3SignData(nil, 0, PrivateKey, PublicKey, OutSignature, OutVerifyKey)
  else
    CnOTSSM3SignData(@Data[0], Length(Data), PrivateKey, PublicKey, OutSignature, OutVerifyKey);
end;

function CnOTSSM3VerifyBytes(Data: TBytes; Signature: TCnOTSSM3Signature;
  PublicKey: TCnOTSSM3PublicKey; VerifyKey: TCnOTSSM3VerificationKey): Boolean;
begin
  if Length(Data) = 0 then
    Result := CnOTSSM3VerifyData(nil, 0, Signature, PublicKey, VerifyKey)
  else
    Result := CnOTSSM3VerifyData(@Data[0], Length(Data), Signature, PublicKey, VerifyKey);
end;

function CnOTSSHA256GenerateKeys(var PrivateKey: TCnOTSSHA256PrivateKey;
  var PublicKey: TCnOTSSHA256PublicKey): Boolean;
var
  I: Integer;
  P: Pointer;
begin
  Result := CnRandomFillBytes(@PrivateKey[0], SizeOf(TCnOTSSHA256PrivateKey));
  if Result then
  begin
    for I := Low(TCnOTSSHA256PublicKey) to High(TCnOTSSHA256PublicKey) do
    begin
      P := @PrivateKey[I];
      PublicKey[I] := SHA256Buffer(P, SizeOf(TCnSHA256Digest));
    end;
  end;
end;

procedure CnOTSSHA256SignData(Data: Pointer; DataByteLen: Integer;
  PrivateKey: TCnOTSSHA256PrivateKey; PublicKey: TCnOTSSHA256PublicKey;
  var OutSignature: TCnOTSSHA256Signature; var OutVerifyKey: TCnOTSSHA256VerificationKey);
var
  I: Integer;
  Bits: TCnBitBuilder;
  Dig: TCnSHA256Digest;
begin
  Dig := SHA256Buffer(PAnsiChar(Data), DataByteLen);
  Bits := TCnBitBuilder.Create;
  try
    Bits.AppendData(@Dig[0], SizeOf(TCnSHA256Digest));

    for I := 0 to Bits.BitLength - 1 do
    begin
      if Bits.Bit[I] then // �� 1
      begin
        OutSignature[I] := PublicKey[I * 2 + 1];
        OutVerifyKey[I] := PrivateKey[I * 2 + 1];
      end
      else
      begin
        OutSignature[I] := PublicKey[I * 2];
        OutVerifyKey[I] := PrivateKey[I * 2];
      end;
    end;
  finally
    Bits.Free;
  end;
end;

function CnOTSSHA256VerifyData(Data: Pointer; DataByteLen: Integer;
  Signature: TCnOTSSHA256Signature; PublicKey: TCnOTSSHA256PublicKey;
  VerifyKey: TCnOTSSHA256VerificationKey): Boolean;
var
  I: Integer;
  Bits: TCnBitBuilder;
  Dig, Cmp: TCnSHA256Digest;
  P: Pointer;
begin
  Result := False;
  Dig := SHA256Buffer(PAnsiChar(Data), DataByteLen);
  Bits := TCnBitBuilder.Create;
  try
    Bits.AppendData(@Dig[0], SizeOf(TCnSHA256Digest));

    for I := 0 to Bits.BitLength - 1 do
    begin
      P := @VerifyKey[I];
      Cmp := SHA256Buffer(P, SizeOf(TCnSHA256Digest));    // ����˽Կ���Ӵ�ֵ
      if Bits.Bit[I] then 
        Result := SHA256Match(Cmp, PublicKey[I * 2 + 1])  // ��λ�� 1���Ƚ� 1 ��Ӧ�Ĺ�Կ
      else
        Result := SHA256Match(Cmp, PublicKey[I * 2]);     // ��λ�� 0���Ƚ� 0 ��Ӧ�Ĺ�Կ

      if not Result then
        Exit;
    end;
  finally
    Bits.Free;
  end;
end;

procedure CnOTSSHA256SignBytes(Data: TBytes; PrivateKey: TCnOTSSHA256PrivateKey;
  PublicKey: TCnOTSSHA256PublicKey; var OutSignature: TCnOTSSHA256Signature;
  var OutVerifyKey: TCnOTSSHA256VerificationKey);
begin
  if Length(Data) = 0 then
    CnOTSSHA256SignData(nil, 0, PrivateKey, PublicKey, OutSignature, OutVerifyKey)
  else
    CnOTSSHA256SignData(@Data[0], Length(Data), PrivateKey, PublicKey, OutSignature, OutVerifyKey);
end;

function CnOTSSHA256VerifyBytes(Data: TBytes; Signature: TCnOTSSHA256Signature;
  PublicKey: TCnOTSSHA256PublicKey; VerifyKey: TCnOTSSHA256VerificationKey): Boolean;
begin
  if Length(Data) = 0 then
    Result := CnOTSSHA256VerifyData(nil, 0, Signature, PublicKey, VerifyKey)
  else
    Result := CnOTSSHA256VerifyData(@Data[0], Length(Data), Signature, PublicKey, VerifyKey);
end;

end.
