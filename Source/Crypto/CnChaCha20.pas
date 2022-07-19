{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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

unit CnChaCha20;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�ChaCha20 �������㷨ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org)
* ��    ע������ RFC 7539 ʵ�֣����� nonce �����ڳ�ʼ������
*           �����㣻���� 32 �ֽ� Key��12 �ֽ� nonce��4 �ֽ� Counter����� 64 �ֽ�����
*           �����㣺���� 32 �ֽ� Key��12 �ֽ� nonce��4 �ֽ� Counter�����ⳤ����/����
*                   �����ͬ������/����
* ����ƽ̨��Windows 7 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.07.19 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNativeDecl;

const
  CHACHA_STATE_SIZE   = 16;
  {* ChaCha20 �㷨��״̬������64 �ֽ�}

  CHACHA_KEY_SIZE     = 32;
  {* ChaCha20 �㷨�� Key �ֽڳ���}

  CHACHA_NONCE_SIZE   = 12;
  {* ChaCha20 �㷨�� Nonce �ֽڳ���}

  CHACHA_COUNT_SIZE   = 4;
  {* ChaCha20 �㷨�ļ������ֽڳ��ȣ�ʵ������ʱʹ�� TCnLongWord32 ����}

type
  TChaChaKey = array[0..CHACHA_KEY_SIZE - 1] of Byte;
  {* ChaCha20 �㷨�� Key}

  TChaChaNonce = array[0..CHACHA_NONCE_SIZE - 1] of Byte;
  {* ChaCha20 �㷨�� Nonce}

  TChaChaCounter = TCnLongWord32;
  {* ChaCha20 �㷨�ļ�����}

  TChaChaState = array[0..CHACHA_STATE_SIZE - 1] of TCnLongWord32;
  {* ChaCha20 �㷨��״̬��}

procedure ChaCha20Block(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Counter: TChaChaCounter; var OutState: TChaChaState);
{* ����һ�ο����㣬���� 20 �ֵ�������}

function ChaCha20EncryptBytes(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Data: TBytes): TBytes;
{* ���ֽ�������� ChaCha20 ����}

function ChaCha20DecryptBytes(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  EnData: TBytes): TBytes;
{* ���ֽ�������� ChaCha20 ����}

function ChaCha20EncryptData(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Data: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
{* �� Data ��ָ�� DataByteLength ���ȵ����ݿ���� ChaCha20 ���ܣ�
  ���ķ� Output ��ָ���ڴ棬Ҫ�󳤶����������� DataByteLength}

function ChaCha20DecryptData(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  EnData: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
{* �� Data ��ָ�� DataByteLength ���ȵ��������ݿ���� ChaCha20 ���ܣ�
  ���ķ� Output ��ָ���ڴ棬Ҫ�󳤶����������� DataByteLength}

implementation

const
  CHACHA20_CONST0 = $61707865;
  CHACHA20_CONST1 = $3320646E;
  CHACHA20_CONST2 = $79622D32;
  CHACHA20_CONST3 = $6B206574;

procedure ROT(var X: TCnLongWord32; N: BYTE);
begin
  X := (X shl N) or (X shr (32 - N));
end;

procedure QuarterRound(var A, B, C, D: TCnLongWord32);
begin
  A := A + B;
  D := D xor A;
  ROT(D, 16);

  C := C + D;
  B := B xor C;
  ROT(B, 12);

  A := A + B;
  D := D xor A;
  ROT(D, 8);

  C := C + D;
  B := B xor C;
  ROT(B, 7);
end;

procedure QuarterRoundState(var State: TChaChaState; A, B, C, D: Integer);
begin
  QuarterRound(State[A], State[B], State[C], State[D]);
end;

procedure BuildState(var State: TChaChaState; var Key: TChaChaKey;
  var Nonce: TChaChaNonce; Counter: TChaChaCounter);
begin
  State[0] := CHACHA20_CONST0;
  State[1] := CHACHA20_CONST1;
  State[2] := CHACHA20_CONST2;
  State[3] := CHACHA20_CONST3;

  State[4] := PCnLongWord32(@Key[0])^;
  State[5] := PCnLongWord32(@Key[4])^;
  State[6] := PCnLongWord32(@Key[8])^;
  State[7] := PCnLongWord32(@Key[12])^;
  State[8] := PCnLongWord32(@Key[16])^;
  State[9] := PCnLongWord32(@Key[20])^;
  State[10] := PCnLongWord32(@Key[24])^;
  State[11] := PCnLongWord32(@Key[28])^;

  State[12] := Counter;

  State[13] := PCnLongWord32(@Nonce[0])^;
  State[14] := PCnLongWord32(@Nonce[4])^;
  State[15] := PCnLongWord32(@Nonce[8])^;
end;

procedure ChaCha20InnerBlock(var State: TChaChaState);
begin
  QuarterRoundState(State, 0, 4, 8, 12);
  QuarterRoundState(State, 1, 5, 9, 13);
  QuarterRoundState(State, 2, 6, 10, 14);
  QuarterRoundState(State, 3, 7, 11, 15);

  QuarterRoundState(State, 0, 5, 10, 15);
  QuarterRoundState(State, 1, 6, 11, 12);
  QuarterRoundState(State, 2, 7, 8, 13);
  QuarterRoundState(State, 3, 4, 9, 14);
end;

procedure ChaCha20Block(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Counter: TChaChaCounter; var OutState: TChaChaState);
var
  I: Integer;
  State: TChaChaState;
begin
  BuildState(State, Key, Nonce, Counter);
  Move(State[0], OutState[0], SizeOf(TChaChaState));

  for I := 1 to 10 do
    ChaCha20InnerBlock(OutState);

  for I := Low(TChaChaState) to High(TChaChaState) do
    OutState[I] := OutState[I] + State[I];
end;

function ChaCha20Data(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Data: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
var
  I, J, L, B: Integer;
  Cnt: TChaChaCounter;
  Stream: TChaChaState;
  P, Q, M: PByteArray;
begin
  Result := False;
  if (Data = nil) or (DataByteLength <= 0) or (Output = nil) then
    Exit;

  Cnt := 1;
  B := DataByteLength div (SizeOf(TCnLongWord32) * CHACHA_STATE_SIZE); // �� B ��������
  P := PByteArray(Data);
  Q := PByteArray(Output);
  M := PByteArray(@Stream[0]);

  if B > 0 then
  begin
    for I := 1 to B do
    begin
      ChaCha20Block(Key, Nonce, Cnt, Stream);

      // P��Q �Ѹ�ָ��Ҫ�����ԭʼ�������Ŀ�
      for J := 0 to SizeOf(TCnLongWord32) * CHACHA_STATE_SIZE - 1 do
        Q^[J] := P^[J] xor M[J];

      // ָ����һ��
      P := PByteArray(TCnNativeInt(P) + SizeOf(TCnLongWord32) * CHACHA_STATE_SIZE);
      Q := PByteArray(TCnNativeInt(Q) + SizeOf(TCnLongWord32) * CHACHA_STATE_SIZE);

      Inc(Cnt);
    end;
  end;

  L := DataByteLength mod (SizeOf(TCnLongWord32) * CHACHA_STATE_SIZE);
  if L > 0 then // ����ʣ��飬����Ϊ L
  begin
    ChaCha20Block(Key, Nonce, Cnt, Stream);

    // P��Q �Ѹ�ָ��Ҫ�����ԭʼ�������Ŀ�
    for J := 0 to L - 1 do
      Q^[J] := P^[J] xor M[J];
  end;
end;

function ChaCha20EncryptBytes(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Data: TBytes): TBytes;
var
  L: Integer;
begin
  Result := nil;
  if Data = nil then
    Exit;

  L := Length(Data);
  if L > 0 then
  begin
    SetLength(Result, L);
    if not ChaCha20Data(Key, Nonce, @Data[0], L, @Result[0]) then
      SetLength(Result, 0);
  end;
end;

function ChaCha20DecryptBytes(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  EnData: TBytes): TBytes;
var
  L: Integer;
begin
  Result := nil;
  if EnData = nil then
    Exit;

  L := Length(EnData);
  if L > 0 then
  begin
    SetLength(Result, L);
    if not ChaCha20Data(Key, Nonce, @EnData[0], L, @Result[0]) then
      SetLength(Result, 0);
  end;
end;

function ChaCha20EncryptData(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  Data: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
begin
  Result := ChaCha20Data(Key, Nonce, Data, DataByteLength, Output);
end;

function ChaCha20DecryptData(var Key: TChaChaKey; var Nonce: TChaChaNonce;
  EnData: Pointer; DataByteLength: Integer; Output: Pointer): Boolean;
begin
  Result := ChaCha20Data(Key, Nonce, EnData, DataByteLength, Output);
end;

end.
