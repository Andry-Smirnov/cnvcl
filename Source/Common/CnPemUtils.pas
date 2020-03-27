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

unit CnPemUtils;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ����� PEM ��ʽ�����Լ��ӽ��ܵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2020.03.23 V1.1
*               ģ�� Openssl ʵ�� PEM �ļ��ܶ�ȡ��ֻ֧�ֲ��ּ����㷨�����
*               Ŀǰ��ȡ���� des aes128/192/256 PKCS7 ���룬���� Openssl 1.0.2g
*           2020.03.18 V1.0
*               ������Ԫ���� CnRSA �ж�������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, CnBase64, CnAES, CnDES, CnMD5, CnSHA2;

type
  TCnKeyHashMethod = (ckhMd5, ckhSha256);

  TCnKeyEncryptMethod = (ckeNone, ckeDES, cke3DES, ckeAES128, ckeAES192, ckeAES256);

function LoadPemFileToMemory(const FileName, ExpectHead, ExpectTail: string;
  MemoryStream: TMemoryStream; const Password: string = '';
  KeyHashMethod: TCnKeyHashMethod = ckhMd5): Boolean;
{* �� PEM ��ʽ������ļ�����ָ֤��ͷβ�����ʵ�����ݲ����ܽ��� Base64 ����}

function LoadPemStreamToMemory(Stream: TStream; const ExpectHead, ExpectTail: string;
  MemoryStream: TMemoryStream; const Password: string = '';
  KeyHashMethod: TCnKeyHashMethod = ckhMd5): Boolean;
{* �� PEM ��ʽ������ļ�����ָ֤��ͷβ�����ʵ�����ݲ����ܽ��� Base64 ����}

function SaveMemoryToPemFile(const FileName, Head, Tail: string;
  MemoryStream: TMemoryStream; KeyEncryptMethod: TCnKeyEncryptMethod = ckeNone;
  KeyHashMethod: TCnKeyHashMethod = ckhMd5; const Password: string = ''): Boolean;
{* �� Stream �����ݽ��� Base64 �������ܷ��в������ļ�ͷβ��д���ļ�}

implementation

const
  ENC_HEAD_PROCTYPE = 'Proc-Type:';
  ENC_HEAD_PROCTYPE_NUM = '4';
  ENC_HEAD_ENCRYPTED = 'ENCRYPTED';
  ENC_HEAD_DEK = 'DEK-Info:';

  ENC_TYPE_AES128 = 'AES-128';
  ENC_TYPE_AES192 = 'AES-192';
  ENC_TYPE_AES256 = 'AES-256';
  ENC_TYPE_DES    = 'DES';
  ENC_TYPE_3DES   = 'DES-EDE3';

  ENC_BLOCK_CBC   = 'CBC';

  ENC_TYPE_STRS: array[TCnKeyEncryptMethod] of string =
    ('', ENC_TYPE_DES, ENC_TYPE_3DES, ENC_TYPE_AES128, ENC_TYPE_AES192, ENC_TYPE_AES256);

  ENC_TYPE_BLOCK_SIZE: array[TCnKeyEncryptMethod] of Byte =
    (0, 8, 8, 16, 16, 16);

function Min(A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function StrToHex(Value: PAnsiChar; Len: Integer): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Len - 1 do
    Result := Result + IntToHex(Ord(Value[I]), 2);
end;

function HexToInt(Hex: AnsiString): Integer;
var
  I, Res: Integer;
  ch: AnsiChar;
begin
  Res := 0;
  for I := 0 to Length(Hex) - 1 do
  begin
    ch := Hex[I + 1];
    if (ch >= '0') and (ch <= '9') then
      Res := Res * 16 + Ord(ch) - Ord('0')
    else if (ch >= 'A') and (ch <= 'F') then
      Res := Res * 16 + Ord(ch) - Ord('A') + 10
    else if (ch >= 'a') and (ch <= 'f') then
      Res := Res * 16 + Ord(ch) - Ord('a') + 10
    else raise Exception.Create('Error: not a Hex String');
  end;
  Result := Res;
end;

function HexToStr(Value: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
  begin
    if ((I mod 2) = 1) then
      Result := Result + AnsiChar(HexToInt(Copy(Value, I, 2)));
  end;
end;

procedure AddPKCS7Padding(Stream: TMemoryStream; BlockSize: Byte);
var
  R: Byte;
  Buf: array[0..255] of Byte;
begin
  R := Stream.Size mod BlockSize;
  if R = 0 then
    R := R + BlockSize;

  FillChar(Buf[0], R, R);
  Stream.Position := Stream.Size;
  Stream.Write(Buf[0], R);
end;

// ȥ�� PKCS7 �涨��ĩβ��䡰�����������������
procedure RemovePKCS7Padding(Stream: TMemoryStream);
var
  L: Byte;
  Len: Cardinal;
  Mem: Pointer;
begin
  // ȥ�� Stream ĩβ�� 9 �� 9 ���� Padding
  if Stream.Size > 1 then
  begin
    Stream.Position := Stream.Size - 1;
    Stream.Read(L, 1);

    Len := Stream.Size - L;
    Mem := GetMemory(Len);
    if Mem <> nil then
    begin
      Move(Stream.Memory^, Mem^, Len);
      Stream.Clear;
      Stream.Write(Mem^, Len);
      FreeMemory(Mem);
    end;
  end;
end;

function EncryptPemStream(KeyHash: TCnKeyHashMethod; KeyEncrypt: TCnKeyEncryptMethod;
  Stream: TMemoryStream; const Password: string): Boolean;
begin
  // TODO: ������
end;

// �ü����㷨�������㡢��ʼ���������������⿪ Base64 ����� S����д�� Stream ��
function DecryptPemString(const S, M1, M2, HexIv, Password: string; Stream: TMemoryStream;
  KeyHashMethod: TCnKeyHashMethod): Boolean;
var
  DS: TMemoryStream;
  PS, PSMD5, PSSHA256: AnsiString;
  AESKey128: TAESKey128;
  AESKey192: TAESKey192;
  AESKey256: TAESKey256;
  IvStr: AnsiString;
  AesIv: TAESBuffer;
  DesKey: TDESKey;
  Des3Key: T3DESKey;
  DesIv: TDESIv;
  Md5Dig, Md5Dig2: TMD5Digest;
  Sha256Dig, Sha256Dig2: TSHA256Digest;
begin
  Result := False;
  DS := nil;

  if (M1 = '') or (M2 = '') or (HexIv = '') or (Password = '') then
    Exit;

  try
    DS := TMemoryStream.Create;
    if BASE64_OK <> Base64Decode(S, DS, False) then
      Exit;

    DS.Position := 0;
    IvStr := HexToStr(HexIv);
    PS := AnsiString(Password) + Copy(IvStr, 1, 8); // �涨 IvStr ǰ 8 λ��Ϊ Salt

    if KeyHashMethod = ckhMd5 then
    begin
      SetLength(PSMD5, 16 + Length(PS));
      Move(PS[1], PSMD5[17], Length(PS));
      Md5Dig := MD5StringA(PS);
      // ������ Salt��Iv ��ǰ���ֽڣ�ƴ������ MD5 �����16 Byte����Ϊ��һ����

      Move(Md5Dig[0], PSMD5[1], SizeOf(TMD5Digest));
      Md5Dig2 := MD5StringA(PSMD5);
      // ��һ���ּ������ Salt��Iv ��ǰ���ֽڣ�ƴ��������һ�� MD5 �� 16 �ֽ���Ϊ�ڶ�����

      // DS �������ģ�Ҫ�⵽ Stream ��
      if (M1 = ENC_TYPE_AES256) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ AES-256-CBC ���ܵ�����
        FillChar(AESKey256, SizeOf(AESKey256), 0);
        Move(Md5Dig, AESKey256, SizeOf(TMD5Digest));
        Move(Md5Dig2, AESKey256[16], SizeOf(TAESKey256) - SizeOf(TMD5Digest));

        Move(IvStr[1], AesIv, Min(SizeOf(TAESBuffer), Length(IvStr)));
        DecryptAESStreamCBC(DS, DS.Size, AESKey256, AesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_AES192) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ AES-192-CBC ���ܵ�����
        FillChar(AESKey192, SizeOf(AESKey192), 0);
        Move(Md5Dig, AESKey192, SizeOf(TMD5Digest));
        Move(Md5Dig2, AESKey192[16], SizeOf(TAESKey192) - SizeOf(TMD5Digest));

        Move(IvStr[1], AesIv, Min(SizeOf(TAESBuffer), Length(IvStr)));
        DecryptAESStreamCBC(DS, DS.Size, AESKey192, AesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_AES128) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ AES-128-CBC ���ܵ����ģ��� D5 ��ò�ƿ��������������� Bug ���³� AV��
        FillChar(AESKey128, SizeOf(AESKey128), 0);
        Move(Md5Dig, AESKey128, Min(SizeOf(AESKey128), SizeOf(TMD5Digest)));

        Move(IvStr[1], AesIv, Min(SizeOf(TAESBuffer), Length(IvStr)));
        DecryptAESStreamCBC(DS, DS.Size, AESKey128, AesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_DES) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ DES-CBC ���ܵ�����
        Move(Md5Dig, DesKey[0], SizeOf(TDESKey));
        Move(IvStr[1], DesIv[0], 8);

        DESDecryptStreamCBC(DS, DS.Size, DesKey, DesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_3DES) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ 3DES-CBC ���ܵ�����
        // ������ Salt��Iv ��ǰ���ֽڣ�ƴ������ MD5 �����16 Byte����Ϊ Key ��ǰ 16 �ֽ�
        // �ټӵڶ����ֵ�ǰ��λ��Ϊ���� Key��24 �ֽڣ�
        Move(Md5Dig, Des3Key[0], SizeOf(TMD5Digest));
        Move(Md5Dig2, Des3Key[16], SizeOf(T3DESKey) - SizeOf(TMD5Digest));
        Move(IvStr[1], DesIv[0], 8);

        TripleDESDecryptStreamCBC(DS, DS.Size, Des3Key, DesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end;
    end
    else if KeyHashMethod = ckhSha256 then // ��δ����
    begin
      SetLength(PSSHA256, 32 + Length(PS));
      Move(PS[1], PSSHA256[33], Length(PS));
      Sha256Dig := SHA256StringA(PS);
      // ������ Salt��Iv ��ǰ���ֽڣ�ƴ������ SHA256 �����32 Byte����Ϊ��һ����

      Move(Sha256Dig[0], PSSHA256[1], SizeOf(TSHA256Digest));
      Sha256Dig2 := SHA256StringA(PSSHA256);
      // ��һ���ּ������ Salt��Iv ��ǰ���ֽڣ�ƴ��������һ�� SHA256 �� 32 �ֽ���Ϊ�ڶ�����

      // DS �������ģ�Ҫ�⵽ Stream ��
      if (M1 = ENC_TYPE_AES256) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ AES-256-CBC ���ܵ�����
        FillChar(AESKey256, SizeOf(AESKey256), 0);
        Move(Sha256Dig, AESKey256, SizeOf(TAESKey256));

        Move(IvStr[1], AesIv, Min(SizeOf(TAESBuffer), Length(IvStr)));
        DecryptAESStreamCBC(DS, DS.Size, AESKey256, AesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_AES192) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ AES-192-CBC ���ܵ�����
        FillChar(AESKey192, SizeOf(AESKey192), 0);
        Move(Sha256Dig, AESKey192, SizeOf(TAESKey192));

        Move(IvStr[1], AesIv, Min(SizeOf(TAESBuffer), Length(IvStr)));
        DecryptAESStreamCBC(DS, DS.Size, AESKey192, AesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_AES128) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ AES-128-CBC ���ܵ�����
        FillChar(AESKey128, SizeOf(AESKey128), 0);
        Move(Sha256Dig, AESKey128, SizeOf(TAESKey128));

        Move(IvStr[1], AesIv, Min(SizeOf(TAESBuffer), Length(IvStr)));
        DecryptAESStreamCBC(DS, DS.Size, AESKey128, AesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_DES) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ DES-CBC ���ܵ�����
        Move(Sha256Dig, DesKey[0], SizeOf(TDESKey));
        Move(IvStr[1], DesIv[0], 8);

        DESDecryptStreamCBC(DS, DS.Size, DesKey, DesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end
      else if (M1 = ENC_TYPE_3DES) and (M2 = ENC_BLOCK_CBC) then
      begin
        // �⿪ 3DES-CBC ���ܵ�����
        Move(Sha256Dig, Des3Key[0], SizeOf(T3DESKey));
        Move(IvStr[1], DesIv[0], 8);

        TripleDESDecryptStreamCBC(DS, DS.Size, Des3Key, DesIv, Stream);
        RemovePKCS7Padding(Stream);
        Result := True;
      end;
    end;
  finally
    DS.Free;
  end;
end;

function LoadPemStreamToMemory(Stream: TStream; const ExpectHead, ExpectTail: string;
  MemoryStream: TMemoryStream; const Password: string; KeyHashMethod: TCnKeyHashMethod): Boolean;
var
  I, J: Integer;
  S, L1, L2, M1, M2, M3: string;
  Sl: TStringList;
begin
  Result := False;

  if (Stream <> nil) and (Stream.Size > 0) and (ExpectHead <> '') and (ExpectTail <> '') then
  begin
    Sl := TStringList.Create;
    try
      Sl.LoadFromStream(Stream);
      if Sl.Count > 2 then
      begin
        if Trim(Sl[0]) <> ExpectHead then
          Exit;

        if Trim(Sl[Sl.Count - 1]) = '' then // ȥ��ĩβ���ܵĿ���
          Sl.Delete(Sl.Count - 1);

        if Trim(Sl[Sl.Count - 1]) <> ExpectTail then
          Exit;

        // ͷβ��֤ͨ������ǰ�����ж��Ƿ����
        L1 := Sl[1];
        if Pos(ENC_HEAD_PROCTYPE, L1) = 1 then // �Ǽ��ܵ�
        begin
          Delete(L1, 1, Length(ENC_HEAD_PROCTYPE));
          I := Pos(',', L1);
          if I <= 1 then
            Exit;

          if Trim(Copy(L1, 1, I - 1)) <> ENC_HEAD_PROCTYPE_NUM then
            Exit;

          if Trim(Copy(L1, I + 1, MaxInt)) <> ENC_HEAD_ENCRYPTED then
            Exit;

          // ProcType: 4,ENCRYPTED �ж�ͨ��

          L2 := Sl[2];
          if Pos(ENC_HEAD_DEK, L2) <> 1 then
            Exit;

          Delete(L2, 1, Length(ENC_HEAD_DEK));
          I := Pos(',', L2);
          if I <= 1 then
            Exit;

          M1 := Trim(Copy(L2, 1, I - 1)); // �õ� AES256-CBC ����
          M3 := UpperCase(Trim(Copy(L2, I + 1, MaxInt)));  // �õ�����ʱʹ�õĳ�ʼ������
          I := Pos('-', M1);
          if I <= 1 then
            Exit;
          J := Pos('-', Copy(M1, I + 1, MaxInt));
          if J > 0 then
            I := I + J; // AES-256-CBC

          M2 := UpperCase(Trim(Copy(M1, I + 1, MaxInt)));  // �õ���ģʽ���� ECB �� CBC ��
          M1 := UpperCase(Trim(Copy(M1, 1, I - 1)));       // �õ������㷨���� DES �� AES ��

          // ͷβ��������ȫɾ��
          Sl.Delete(Sl.Count - 1);
          Sl.Delete(0);
          Sl.Delete(0);
          Sl.Delete(0);

          S := '';
          for I := 0 to Sl.Count - 1 do
            S := S + Sl[I];

          S := Trim(S);

          Result := DecryptPemString(S, M1, M2, M3, Password, MemoryStream, KeyHashMethod);
        end
        else // δ���ܵģ�ƴ�ճ� Base64 �����
        begin
          Sl.Delete(Sl.Count - 1);
          Sl.Delete(0);
          S := '';
          for I := 0 to Sl.Count - 1 do
            S := S + Sl[I];

          S := Trim(S);

          // To De Base64 S
          MemoryStream.Clear;
          Result := (BASE64_OK = Base64Decode(S, MemoryStream, False));
        end;
      end;
    finally
      Sl.Free;
    end;
  end;
end;

function LoadPemFileToMemory(const FileName, ExpectHead, ExpectTail: string;
  MemoryStream: TMemoryStream; const Password: string; KeyHashMethod: TCnKeyHashMethod): Boolean;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := LoadPemStreamToMemory(Stream, ExpectHead, ExpectTail, MemoryStream, Password, KeyHashMethod);
  finally
    Stream.Free;
  end;
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

function SaveMemoryToPemFile(const FileName, Head, Tail: string;
  MemoryStream: TMemoryStream; KeyEncryptMethod: TCnKeyEncryptMethod;
  KeyHashMethod: TCnKeyHashMethod; const Password: string): Boolean;
var
  S: string;
  List: TStringList;
begin
  Result := False;
  if (MemoryStream <> nil) and (MemoryStream.Size <> 0) then
  begin
    MemoryStream.Position := 0;

    if (KeyEncryptMethod <> ckeNone) and (Password <> '') then
    begin
      // �� MemoryStream ����
      AddPKCS7Padding(MemoryStream, ENC_TYPE_BLOCK_SIZE[KeyEncryptMethod]);

      // �ټ���
      if not EncryptPemStream(KeyHashMethod, KeyEncryptMethod, MemoryStream, Password) then
        Exit;
    end;

    if Base64_OK = Base64Encode(MemoryStream, S) then
    begin
      List := TStringList.Create;
      try
        SplitStringToList(S, List);

        List.Insert(0, Head);
        List.Add(Tail);

        List.SaveToFile(FileName);
        Result := True;
      finally
        List.Free;
      end;
    end;

  end;
end;

end.
