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

unit CnSM2;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�SM2 ��Բ�����㷨��Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��ʵ���� GM/T0003.x-2012��SM2��Բ���߹�Կ�����㷨��
*           �淶�еĻ��� SM2 �����ݼӽ��ܡ�ǩ����ǩ����Կ����
*           ע����ǩ���淶��ȫ��ͬ�� Openssl �е� Ecc ǩ���������Ӵպ���ֻ��ʹ�� SM3
*           ���⣬ע�� SM2 ��Բ����ǩ���޷���ǩ����ԭʼֵ�лָ���Կ
*           ��Ȼ�� PublicKey = (s + r)^-1 * (k*G - s*G)
*           �Ҿ��� k ����δ֪�� k*G ������ x1 �ǿ��� r ���Ƴ�������Ϊ r <= (e + x1) mod n
*           ���� x1 <= (r - e) mod n����� y1 Ҳ����������� e ʹ���˹�Կ���Ӵ�ֵ
*           ���³��������е��������м�������
* ����ƽ̨��Win7 + Delphi 5.0
* ���ݲ��ԣ�Win7 + XE
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2022.06.16 V1.5
*               ʹ��Ԥ���� 2 ���ݵ������� SM2 ��˼���
*           2022.06.01 V1.5
*               ���Ӽ��׵�Эͬ������ǩ����ʵ��
*           2022.05.27 V1.4
*               �����ļ��ӽ��ܵ�ʵ��
*           2022.05.26 V1.3
*               ���ӷǽ���ʽ Schnorr ��֪ʶ֤����֤���̵�ʵ��
*           2022.03.30 V1.2
*               ���ݼӽ��ܵ� C1C3C2 �� C1C2C3 ����ģʽ�Լ�ǰ���ֽ� 04
*           2021.11.25 V1.1
*               ���ӷ�װ�� SignFile �� VerifyFile ����
*           2020.04.04 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, CnECC, CnBigNumber, CnConsts, CnSM3;

const
  CN_SM2_FINITEFIELD_BYTESIZE = 32; // 256 Bits

  // ������
  ECN_SM2_OK                           = ECN_OK; // û��
  ECN_SM2_ERROR_BASE                   = ECN_CUSTOM_ERROR_BASE + $200; // SM2 �������׼

  ECN_SM2_INVALID_INPUT                = ECN_SM2_ERROR_BASE + 1; // ����Ϊ�ջ򳤶Ȳ���
  ECN_SM2_RANDOM_ERROR                 = ECN_SM2_ERROR_BASE + 2; // �������ش���
  ECN_SM2_BIGNUMBER_ERROR              = ECN_SM2_ERROR_BASE + 3; // �����������
  ECN_SM2_DECRYPT_INFINITE_ERROR       = ECN_SM2_ERROR_BASE + 4; // ����ʱ��������Զ��
  ECN_SM2_KEYEXCHANGE_INFINITE_ERROR   = ECN_SM2_ERROR_BASE + 5; // ��Կ������������Զ��

type
  TCnSM2PrivateKey = TCnEccPrivateKey;
  {* SM2 ��˽Կ������ͨ��Բ���ߵ�˽Կ}

  TCnSM2PublicKey = TCnEccPublicKey;
  {* SM2 �Ĺ�Կ������ͨ��Բ���ߵĹ�Կ}

  TCnSM2 = class(TCnEcc)
  {* SM2 ��Բ���������࣬����ʵ����ָ���������͵Ļ��� TCnEcc ��}
  public
    constructor Create; override;

    procedure AffineMultiplePoint(K: TCnBigNumber; Point: TCnEcc3Point); override;
    {* ʹ��Ԥ����ķ����������м���}
  end;

  TCnSM2Signature = class(TCnEccSignature);
  {* SM2 ��Բ����ǩ�������ݾ�����ͨ��Բ���ߵ�ǩ�������ݣ�ע���㷨���ļ���ʽ��ͬ��}

  TCnSM2CryptSequenceType = (cstC1C3C2, cstC1C2C3);
  {* SM2 ��������ʱ��ƴ�ӷ�ʽ���������� C1C3C2���������� C1C2C3 �İ汾���ʴ�������}

  TCnSM2CollaborativePrivateKey = TCnEccPrivateKey;
  {* SM2 Эͬ˽Կ������ͨ��Բ���ߵ�˽Կ��������������}

  TCnSM2CollaborativePublicKey = TCnEccPublicKey;
  {* SM2 Эͬ˽Կ������ͨ��Բ���ߵĹ�Կ��ͬ����һ��}

// ========================== SM2 ��Բ������Կ���� =============================

function CnSM2GenerateKeys(PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2 = nil): Boolean;
{* ����һ�� SM2 ��˽Կ}

// ========================= SM2 ��Բ���߼ӽ����㷨 ============================

function CnSM2EncryptData(PlainData: Pointer; DataLen: Integer; OutStream:
  TStream; PublicKey: TCnSM2PublicKey; SM2: TCnSM2 = nil;
  SequenceType: TCnSM2CryptSequenceType = cstC1C3C2;
  IncludePrefixByte: Boolean = True): Boolean;
{* �ù�Կ�����ݿ���м��ܣ��ο� GM/T0003.4-2012��SM2��Բ���߹�Կ�����㷨
   ��4����:��Կ�����㷨���е�������򣬲�ͬ����ͨ ECC �� RSA �Ķ������
   SequenceType ����ָ���ڲ�ƴ�Ӳ���Ĭ�Ϲ���� C1C3C2 �����뵱Ȼ�� C1C2C3
   IncludePrefixByte ���������Ƿ���� C1 ǰ���� $04 һ�ֽڣ�Ĭ�ϰ���}

function CnSM2DecryptData(EnData: Pointer; DataLen: Integer; OutStream: TStream;
  PrivateKey: TCnSM2PrivateKey; SM2: TCnSM2 = nil;
  SequenceType: TCnSM2CryptSequenceType = cstC1C3C2): Boolean;
{* ��˽Կ�����ݿ���н��ܣ��ο� GM/T0003.4-2012��SM2��Բ���߹�Կ�����㷨
   ��4����:��Կ�����㷨���е�������򣬲�ͬ����ͨ ECC �� RSA �Ķ������
   SequenceType ����ָ���ڲ�ƴ�Ӳ���Ĭ�Ϲ���� C1C3C2 �����뵱Ȼ�� C1C2C3
   ���� IncludePrefixByte �������ڲ��Զ�����}

function CnSM2EncryptFile(const InFile, OutFile: string; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2 = nil; SequenceType: TCnSM2CryptSequenceType = cstC1C3C2): Boolean;
{* �ù�Կ���� InFile �ļ����ݣ����ܽ���� OutFile ������Ƿ���ܳɹ�}

function CnSM2DecryptFile(const InFile, OutFile: string; PrivateKey: TCnSM2PrivateKey;
  SM2: TCnSM2 = nil; SequenceType: TCnSM2CryptSequenceType = cstC1C3C2): Boolean;
{* ��˽Կ���� InFile �ļ����ݣ����ܽ���� OutFile ������Ƿ���ܳɹ�}

// ====================== SM2 ��Բ��������ǩ����֤�㷨 =========================

function CnSM2SignData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  OutSignature: TCnSM2Signature; PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2 = nil): Boolean;
{* ˽Կ�����ݿ�ǩ������ GM/T0003.2-2012��SM2��Բ���߹�Կ�����㷨
   ��2����:����ǩ���㷨���е��������Ҫ����ǩ������������Ϣ�Լ���Կ������ժҪ}

function CnSM2VerifyData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  InSignature: TCnSM2Signature; PublicKey: TCnSM2PublicKey; SM2: TCnSM2 = nil): Boolean;
{* ��Կ��֤���ݿ��ǩ������ GM/T0003.2-2012��SM2��Բ���߹�Կ�����㷨
   ��2����:����ǩ���㷨���е����������}

function CnSM2SignFile(const UserID: AnsiString; const FileName: string;
  PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey; SM2: TCnSM2 = nil): string;
{* ��װ��˽Կ���ļ�ǩ������������ǩ��ֵ��ʮ�������ַ�����ע���ڲ������ǽ��ļ�ȫ���������ڴ�
  ��ǩ�������򷵻ؿ�ֵ}

function CnSM2VerifyFile(const UserID: AnsiString; const FileName: string;
  const InHexSignature: string; PublicKey: TCnSM2PublicKey; SM2: TCnSM2 = nil): Boolean;
{* ��װ�Ĺ�Կ��֤���ݿ��ǩ����������ǩ��ֵ��ʮ�������ַ�����ע���ڲ������ǽ��ļ�ȫ���������ڴ�
  ��֤ͨ������ True����ͨ��������� False}

// ======================== SM2 ��Բ������Կ�����㷨 ===========================

{
  SM2 ��Կ����ǰ�᣺A B ˫���������� ID �빫˽Կ������֪���Է��� ID ��Է��Ĺ�Կ
}
function CnSM2KeyExchangeAStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey;
  OutARand: TCnBigNumber; OutRA: TCnEccPoint; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬��һ�� A �û���������� RA�������� B
  ���룺A B ���û������������볤�ȡ��Լ���˽Կ��˫���Ĺ�Կ
  ��������ֵ OutARand�����ɵ������ RA������ B��}

function CnSM2KeyExchangeBStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey; InRA: TCnEccPoint;
  out OutKeyB: AnsiString; OutRB: TCnEccPoint; out OutOptionalSB: TSM3Digest;
  out OutOptionalS2: TSM3Digest; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬�ڶ��� B �û��յ� A �����ݣ����� Kb�����ѿ�ѡ����֤������� A
  ���룺A B ���û������������볤�ȡ��Լ���˽Կ��˫���Ĺ�Կ��A ������ RA
  ���������ɹ��Ĺ�����Կ Kb�����ɵ������ RB������ A������ѡ��У���Ӵ� SB������ A ��֤������ѡ��У���Ӵ� S2}

function CnSM2KeyExchangeAStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey; MyRA, InRB: TCnEccPoint;
  MyARand: TCnBigNumber; out OutKeyA: AnsiString; InOptionalSB: TSM3Digest;
  out OutOptionalSA: TSM3Digest; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬������ A �û��յ� B �����ݼ��� Ka�����ѿ�ѡ����֤������� B������Э�̺� Ka = Kb
  ���룺A B ���û������������볤�ȡ��Լ���˽Կ��˫���Ĺ�Կ��B ������ RB ���ѡ�� SB���Լ��ĵ� RA���Լ������ֵ MyARand
  ���������ɹ��Ĺ�����Կ Ka����ѡ��У���Ӵ� SA������ B ��֤��}

function CnSM2KeyExchangeBStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey;
  InOptionalSA: TSM3Digest; MyOptionalS2: TSM3Digest; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ����Կ����Э�飬���Ĳ� B �û��յ� A �����ݼ�����У�飬Э����ϣ��˲���ѡ
  ʵ����ֻ�Ա� B �ڶ������ɵ� S2 �� A ������������ SA�������������ʹ��}

// =============== ���� SM2/SM3 �ķǽ���ʽ Schnorr ��֪ʶ֤�� ==================

function CnSM2SchnorrProve(PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey;
  OutR: TCnEccPoint; OutZ: TCnBigNumber; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2/SM3 �ķǽ���ʽ Schnorr ��֪ʶ֤������һ����˽Կӵ���ߵ���
  ˽Կӵ�������� R �� Z�����������Ƿ�ɹ�
  �ú������� SM2 ˽Կӵ����֤���Լ�ӵ�ж�Ӧ��Կ��˽Կ�����蹫����˽Կ}

function CnSM2SchnorrCheck(PublicKey: TCnSM2PublicKey; InR: TCnEccPoint;
  InZ: TCnBigNumber; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2/SM3 �ķǽ���ʽ Schnorr ��֪ʶ֤������������õ���Կ����֤
  ��֤�Է������� R �� Z������ɹ���˵���Է�ӵ�иù�Կ��Ӧ��˽Կ
  �ú���������֤�Է��Ƿ�ӵ��ĳ SM2 ��Կ��Ӧ��˽Կ}

// ========== SM2 ��Բ����˫���������εļ���Эͬ�㷨֮Эͬ��Կ���� =============

{
  ��Эͬģʽ�£�A B ˫���������Σ�������ԶԷ�����֤�����������ŶԷ����������ݡ�
}
function CnSM2CollaborativeGenerateKeyAStep1(PrivateKeyA: TCnSM2CollaborativePrivateKey;
  PointToB: TCnEccPoint; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬ�㷨��A ��һ�������Լ���˽Կ PrivateKeyA���������м��� PointToB��
  �õ�ֵ��Ҫ������ B�������Ƿ����ɳɹ�}

function CnSM2CollaborativeGenerateKeyBStep1(PrivateKeyB: TCnSM2CollaborativePrivateKey;
  InPointFromA: TCnEccPoint; PublicKey: TCnSM2CollaborativePublicKey; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬ�㷨��B �ڶ��������Լ���˽Կ PrivateKeyB�������� A �������м��� InPointFromA��
  ���ɹ��õĹ�Կ PublicKey�������Ƿ����ɳɹ�
  ��Կ PublicKey ������Ҫ���� A ��������ȥ}

// =============== SM2 ��Բ����˫���������εļ���Эͬǩ���㷨 ==================

function CnSM2CollaborativeSignAStep1(const UserID: AnsiString; PlainData: Pointer;
  DataLen: Integer; OutHashEToB: TCnBigNumber; OutQToB: TCnEccPoint; OutRandK: TCnBigNumber;
  PrivateKeyA: TCnSM2CollaborativePrivateKey; PublicKey: TCnSM2PublicKey; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬǩ����A ��һ������ԭʼ����ǩ���м�ֵ E �� Q�����͸� B�����ظò�ǩ���Ƿ�ɹ�
  ע�� OutRandK ��Ҫ���� B��}

function CnSM2CollaborativeSignBStep1(InHashEFromA: TCnBigNumber; InQFromA: TCnEccPoint;
  OutRToB, OutS1ToB, OutS2ToB: TCnBigNumber; PrivateKeyB: TCnSM2CollaborativePrivateKey;
  SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬǩ����B �ڶ������� A ǩ�����м�ֵ E �� Q������ R S1 S2 ���ͻ� A�����ظò�ǩ���Ƿ�ɹ�}

function CnSM2CollaborativeSignAStep2(InRandK, InRFromB, InS1FromB, InS2FromB: TCnBigNumber;
  OutSignature: TCnSM2Signature; PrivateKeyA: TCnSM2CollaborativePrivateKey; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬǩ����A ���������� A ��һ���� OutRandK ���ֵ�� B ǩ�����м�ֵ R S1 S2����������ǩ�������ظò�ǩ���Ƿ�ɹ�}

// =============== SM2 ��Բ����˫���������εļ���Эͬ�����㷨 ==================

function CnSM2CollaborativeDecryptAStep1(EnData: Pointer; DataLen: Integer;
  OutTToB: TCnEccPoint; PrivateKeyA: TCnSM2CollaborativePrivateKey;
  SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬ���ܣ�A ��һ���������Ľ���м�ֵ T�����͸� B�����ظò������Ƿ�ɹ�}

function CnSM2CollaborativeDecryptBStep1(InTFromA: TCnEccPoint; OutTToA: TCnEccPoint;
  PrivateKeyB: TCnSM2CollaborativePrivateKey; SM2: TCnSM2 = nil): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬ���ܣ�B �ڶ������� A ������м�ֵ T��������һ���м�ֵ T ���ͻ� A��
  ���ظò������Ƿ�ɹ�}

function CnSM2CollaborativeDecryptAStep2(EnData: Pointer; DataLen: Integer;
  InTFromB: TCnEccPoint; OutStream: TStream; PrivateKeyA: TCnSM2CollaborativePrivateKey;
  SM2: TCnSM2 = nil; SequenceType: TCnSM2CryptSequenceType = cstC1C3C2): Boolean;
{* ���� SM2 ��Բ���ߵ�Эͬ���ܣ�A ���������� B ������м�ֵ T ������ս��ܽ��д�� Stream��
  ���ظò����ս����Ƿ�ɹ�
  ע�������� SequenceType �뱣�ֺ� AStep1 �е���ȫһ��}

implementation

uses
  CnKDF;

var
  FSM2AffineGPower2KList: TObjectList = nil; // SM2 �� G ���Ԥ�������꣬�� n ����ʾ 2^n �η�����

{* X <= 2^W + (x and (2^W - 1) ��ʾ�� x �ĵ� W λ�� 1���� W + 1 ������ȫ�� 0
   �����֮����ȡ X �ĵ� W λ����֤��һλ�ĵ� W λ�� 1��λ�� 0 ��ʼ��
  ���� W �� N �� BitsCount ��һ���ٵ�����ú���������Կ����
  ע�⣺���� CnECC �е�ͬ���������ܲ�ͬ}
procedure BuildShortXValue(X: TCnBigNumber; Order: TCnBigNumber);
var
  I, W: Integer;
begin
  W := (Order.GetBitsCount + 1) div 2 - 1;
  BigNumberSetBit(X, W);
  for I := W + 1 to X.GetBitsCount - 1 do
    BigNumberClearBit(X, I);
end;

{ TCnSM2 }

procedure TCnSM2.AffineMultiplePoint(K: TCnBigNumber; Point: TCnEcc3Point);
var
  I: Integer;
  E, R: TCnEcc3Point;
  IsG: Boolean;
begin
  if BigNumberIsNegative(K) then
  begin
    BigNumberSetNegative(K, False);
    AffinePointInverse(Point);
  end;

  if BigNumberIsZero(K) then
  begin
    Point.X.SetZero;
    Point.Y.SetZero;
    Point.Z.SetZero;
    Exit;
  end
  else if BigNumberIsOne(K) then // �� 1 ���趯
    Exit;

  IsG := Point.Z.IsOne and BigNumberEqual(Point.X, Generator.X) and BigNumberEqual(Point.Y, Generator.Y);

  R := nil;
  E := nil;

  try
    R := TCnEcc3Point.Create;
    E := TCnEcc3Point.Create;

    E.X := Point.X;
    E.Y := Point.Y;
    E.Z := Point.Z;

    for I := 0 to BigNumberGetBitsCount(K) - 1 do
    begin
      if BigNumberIsBitSet(K, I) then
        AffinePointAddPoint(R, E, R);

      // ��� P �� G �㣬�������ӣ�ֱ��ȡ��
      if IsG and (I < FSM2AffineGPower2KList.Count - 1) then
        E.Assign(TCnEcc3Point(FSM2AffineGPower2KList[I + 1]))
      else // ����˴�û��Ԥ�õ㣬�� E �Լ�
        AffinePointAddPoint(E, E, E);
    end;

    Point.X := R.X;
    Point.Y := R.Y;
    Point.Z := R.Z;
  finally
    R.Free;
    E.Free;
  end;
end;

constructor TCnSM2.Create;
begin
  inherited;
  Load(ctSM2);
end;

function CnSM2GenerateKeys(PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2): Boolean;
var
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKey = nil) or (PublicKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    SM2.GenerateKeys(PrivateKey, PublicKey);
    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

{
  �������� M���� MLen �ֽڣ�������� k������

  C1 = k * G => (x1, y1)         // ��ѹ���洢������Ϊ��������λ���� 1���� SM2 ��Ҳ���� 32 * 2 + 1 = 65 �ֽ�

  k * PublicKey => (x2, y2)
  t <= KDF(x2��y2, MLen)
  C2 <= M xor t                  // ���� MLen

  C3 <= SM3(x2��M��y2)           // ���� 32 �ֽ�

  ����Ϊ��C1��C3��C2             // �ܳ� MLen + 97 �ֽ�
}
function CnSM2EncryptData(PlainData: Pointer; DataLen: Integer; OutStream:
  TStream; PublicKey: TCnSM2PublicKey; SM2: TCnSM2;
  SequenceType: TCnSM2CryptSequenceType; IncludePrefixByte: Boolean): Boolean;
var
  Py, P1, P2: TCnEccPoint;
  K: TCnBigNumber;
  B: Byte;
  M: PAnsiChar;
  I: Integer;
  Buf: array of Byte;
  KDFStr, T, C3H: AnsiString;
  Sm3Dig: TSM3Digest;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (OutStream = nil) or (PublicKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  Py := nil;
  P1 := nil;
  P2 := nil;
  K := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    K := TCnBigNumber.Create;

    // ȷ����Կ X Y ������
    if PublicKey.Y.IsZero then
    begin
      Py := TCnEccPoint.Create;
      if not SM2.PlainToPoint(PublicKey.X, Py) then
        Exit;
      BigNumberCopy(PublicKey.Y, Py.Y);
    end;

    // ����һ����� K
    if not BigNumberRandRange(K, SM2.Order) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;

    P1 := TCnEccPoint.Create;
    P1.Assign(SM2.Generator);
    SM2.MultiplePoint(K, P1);  // ����� K * G �õ� X1 Y1

    OutStream.Position := 0;
    if IncludePrefixByte then
    begin
      B := 4;
      OutStream.Write(B, 1);
    end;

    SetLength(Buf, P1.X.GetBytesCount);
    P1.X.ToBinary(@Buf[0]);
    OutStream.Write(Buf[0], P1.X.GetBytesCount);
    SetLength(Buf, P1.Y.GetBytesCount);
    P1.Y.ToBinary(@Buf[0]);
    OutStream.Write(Buf[0], P1.Y.GetBytesCount); // ƴ�� C1

    P2 := TCnEccPoint.Create;
    P2.Assign(PublicKey);
    SM2.MultiplePoint(K, P2); // ����� K * PublicKey �õ� X2 Y2

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

    if SequenceType = cstC1C3C2 then
    begin
      OutStream.Write(Sm3Dig[0], SizeOf(TSM3Digest));        // д�� C3
      OutStream.Write(T[1], DataLen);                        // д�� C2
    end
    else
    begin
      OutStream.Write(T[1], DataLen);                        // д�� C2
      OutStream.Write(Sm3Dig[0], SizeOf(TSM3Digest));        // д�� C3
    end;

    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    P2.Free;
    P1.Free;
    Py.Free;
    K.Free;
    if SM2IsNil then
      SM2.Free;
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
  PrivateKey: TCnSM2PrivateKey; SM2: TCnSM2; SequenceType: TCnSM2CryptSequenceType): Boolean;
var
  MLen: Integer;
  M: PAnsiChar;
  MP: AnsiString;
  KDFStr, T, C3H: AnsiString;
  SM2IsNil: Boolean;
  P2: TCnEccPoint;
  I, PrefixLen: Integer;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (EnData = nil) or (DataLen <= 0) or (OutStream = nil) or (PrivateKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  P2 := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    MLen := DataLen - SizeOf(TSM3Digest) - (SM2.BitsCount div 4);
    if MLen <= 0 then
    begin
      _CnSetLastError(ECN_SM2_INVALID_INPUT);
      Exit;
    end;

    P2 := TCnEccPoint.Create;
    M := PAnsiChar(EnData);
    if M^ = #$04 then  // �������ܵ�ǰ���ֽ� $04
    begin
      Dec(MLen);
      if MLen <= 0 then
      begin
        _CnSetLastError(ECN_SM2_INVALID_INPUT);
        Exit;
      end;

      PrefixLen := 1;
      Inc(M);
    end
    else
      PrefixLen := 0;

    // ���� C1
    P2.X.SetBinary(M, SM2.BitsCount div 8);
    Inc(M, SM2.BitsCount div 8);
    P2.Y.SetBinary(M, SM2.BitsCount div 8);
    if P2.IsZero then
    begin
      _CnSetLastError(ECN_SM2_DECRYPT_INFINITE_ERROR);
      Exit;
    end;

    SM2.MultiplePoint(PrivateKey, P2);

    SetLength(KDFStr, P2.X.GetBytesCount + P2.Y.GetBytesCount);
    P2.X.ToBinary(@KDFStr[1]);
    P2.Y.ToBinary(@KDFStr[P2.X.GetBytesCount + 1]);
    T := CnSM2KDF(KDFStr, MLen);

    if SequenceType = cstC1C3C2 then
    begin
      SetLength(MP, MLen);
      M := PAnsiChar(EnData);
      Inc(M, SizeOf(TSM3Digest) + (SM2.BitsCount div 4) + PrefixLen); // ���� C3 ָ�� C2
      for I := 1 to MLen do
        MP[I] := AnsiChar(Byte(M[I - 1]) xor Byte(T[I])); // �� KDF ������� MP ��õ�����

      SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + MLen);
      P2.X.ToBinary(@C3H[1]);
      Move(MP[1], C3H[P2.X.GetBytesCount + 1], MLen);
      P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + MLen + 1]);    // ƴ���� C3 ��
      Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

      M := PAnsiChar(EnData);
      Inc(M, (SM2.BitsCount div 4) + PrefixLen);             // M ָ�� C3
      if CompareMem(@Sm3Dig[0], M, SizeOf(TSM3Digest)) then  // �ȶ� Hash �Ƿ����
      begin
        OutStream.Write(MP[1], Length(MP));

        Result := True;
        _CnSetLastError(ECN_SM2_OK);
      end;
    end
    else // C1C2C3 ������
    begin
      SetLength(MP, MLen);
      M := PAnsiChar(EnData);
      Inc(M, (SM2.BitsCount div 4) + PrefixLen);  // ָ�� C2

      for I := 1 to MLen do
        MP[I] := AnsiChar(Byte(M[I - 1]) xor Byte(T[I])); // �� KDF ������� MP ��õ�����

      SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + MLen);
      P2.X.ToBinary(@C3H[1]);
      Move(MP[1], C3H[P2.X.GetBytesCount + 1], MLen);
      P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + MLen + 1]);    // ƴ���� C3 ��
      Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

      M := PAnsiChar(EnData);
      Inc(M, (SM2.BitsCount div 4) + PrefixLen + MLen);      // ָ�� C3
      if CompareMem(@Sm3Dig[0], M, SizeOf(TSM3Digest)) then  // �ȶ� Hash �Ƿ����
      begin
        OutStream.Write(MP[1], Length(MP));

        Result := True;
        _CnSetLastError(ECN_SM2_OK);
      end;
    end;
  finally
    P2.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2EncryptFile(const InFile, OutFile: string; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2 = nil; SequenceType: TCnSM2CryptSequenceType = cstC1C3C2): Boolean;
var
  Stream: TMemoryStream;
  F: TFileStream;
begin
  Stream := nil;
  F := nil;

  try
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(InFile);

    F := TFileStream.Create(OutFile, fmCreate);
    Result := CnSM2EncryptData(Stream.Memory, Stream.Size, F, PublicKey, SM2, SequenceType);
  finally
    F.Free;
    Stream.Free;
  end;
end;

function CnSM2DecryptFile(const InFile, OutFile: string; PrivateKey: TCnSM2PrivateKey;
  SM2: TCnSM2 = nil; SequenceType: TCnSM2CryptSequenceType = cstC1C3C2): Boolean;
var
  Stream: TMemoryStream;
  F: TFileStream;
begin
  Stream := nil;
  F := nil;

  try
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(InFile);

    F := TFileStream.Create(OutFile, fmCreate);
    Result := CnSM2DecryptData(Stream.Memory, Stream.Size, F, PrivateKey, SM2, SequenceType);
  finally
    F.Free;
    Stream.Free;
  end;
end;

// ���� Za ֵҲ���� Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
function CalcSM2UserHash(const UserID: AnsiString; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2): TSM3Digest;
var
  Stream: TMemoryStream;
  Len: Integer;
  ULen: Word;
begin
  Stream := TMemoryStream.Create;
  try
    Len := Length(UserID) * 8;
    ULen := ((Len and $FF) shl 8) or ((Len and $FF00) shr 8);

    Stream.Write(ULen, SizeOf(ULen));
    if ULen > 0 then
      Stream.Write(UserID[1], Length(UserID));

    BigNumberWriteBinaryToStream(SM2.CoefficientA, Stream);
    BigNumberWriteBinaryToStream(SM2.CoefficientB, Stream);
    BigNumberWriteBinaryToStream(SM2.Generator.X, Stream);
    BigNumberWriteBinaryToStream(SM2.Generator.Y, Stream);
    BigNumberWriteBinaryToStream(PublicKey.X, Stream);
    BigNumberWriteBinaryToStream(PublicKey.Y, Stream);

    Result := SM3(PAnsiChar(Stream.Memory), Stream.Size);  // ��� ZA
  finally
    Stream.Free;
  end;
end;

// ���� Za �������ٴμ����Ӵ�ֵ e
function CalcSM2SignatureHash(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  PublicKey: TCnSM2PublicKey; SM2: TCnSM2): TSM3Digest;
var
  Stream: TMemoryStream;
  Sm3Dig: TSM3Digest;
begin
  Stream := TMemoryStream.Create;
  try
    Sm3Dig := CalcSM2UserHash(UserID, PublicKey, SM2);
    Stream.Write(Sm3Dig[0], SizeOf(TSM3Digest));
    Stream.Write(PlainData^, DataLen);

    Result := SM3(PAnsiChar(Stream.Memory), Stream.Size);  // �ٴ�����Ӵ�ֵ e
  finally
    Stream.Free;
  end;
end;

{
  ZA <= Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
  e <= Hash(ZA��M)

  k * G => (x1, y1)

  ���ǩ�� r <= (e + x1) mod n

  ���ǩ�� s <= ((1 + PrivateKey)^-1 * (k - r * PrivateKey)) mod n

}
function CnSM2SignData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  OutSignature: TCnSM2Signature; PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey;
  SM2: TCnSM2): Boolean;
var
  K, R, E: TCnBigNumber;
  P: TCnEccPoint;
  SM2IsNil: Boolean;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (OutSignature = nil) or
    (PrivateKey = nil) or (PublicKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  K := nil;
  P := nil;
  E := nil;
  R := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    Sm3Dig := CalcSM2SignatureHash(UserID, PlainData, DataLen, PublicKey, SM2); // �Ӵ�ֵ e

    P := TCnEccPoint.Create;
    E := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    K := TCnBigNumber.Create;

    while True do
    begin
      // ����һ����� K
      if not BigNumberRandRange(K, SM2.Order) then
      begin
        _CnSetLastError(ECN_SM2_RANDOM_ERROR);
        Exit;
      end;

      P.Assign(SM2.Generator);
      SM2.MultiplePoint(K, P);

      // ���� R = (e + x) mod N
      E.SetBinary(@Sm3Dig[0], SizeOf(TSM3Digest));
      if not BigNumberAdd(E, E, P.X) then
        Exit;
      if not BigNumberMod(R, E, SM2.Order) then // ��� R �� E ������
        Exit;

      if R.IsZero then  // R ����Ϊ 0
        Continue;

      if not BigNumberAdd(E, R, K) then
        Exit;
      if BigNumberCompare(E, SM2.Order) = 0 then // R + K = N Ҳ����
        Continue;

      BigNumberCopy(OutSignature.R, R);  // �õ�һ��ǩ��ֵ R

      BigNumberCopy(E, PrivateKey);
      BigNumberAddWord(E, 1);
      BigNumberModularInverse(R, E, SM2.Order);      // ����Ԫ�õ� (1 + PrivateKey)^-1������ R ��

      // �� K - R * PrivateKey�������� E ��
      if not BigNumberMul(E, OutSignature.R, PrivateKey) then
        Exit;
      if not BigNumberSub(E, K, E) then
        Exit;

      if not BigNumberMul(R, E, R) then // (1 + PrivateKey)^-1 * (K - R * PrivateKey) ���� R ��
        Exit;

      if not BigNumberNonNegativeMod(OutSignature.S, R, SM2.Order) then // ע����������Ϊ��
        Exit;

      Result := True;
      _CnSetLastError(ECN_SM2_OK);

      Break;
    end;
  finally
    K.Free;
    P.Free;
    R.Free;
    E.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

{
  s �� r ��ǩ��ֵ
  ZA = Hash(EntLen��UserID��a��b��xG��yG��xA��yA)
  e <= Hash(ZA��M)

  t <= (r + s) mod n
  P <= s * G + t * PublicKey
  r' <= (e + P.x) mod n
  �ȶ� r' �� r
}
function CnSM2VerifyData(const UserID: AnsiString; PlainData: Pointer; DataLen: Integer;
  InSignature: TCnSM2Signature; PublicKey: TCnSM2PublicKey; SM2: TCnSM2): Boolean;
var
  K, R, E: TCnBigNumber;
  P, Q: TCnEccPoint;
  SM2IsNil: Boolean;
  Sm3Dig: TSM3Digest;
begin
  Result := False;
  if (PlainData = nil) or (DataLen <= 0) or (InSignature = nil) or (PublicKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  K := nil;
  P := nil;
  Q := nil;
  E := nil;
  R := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    if BigNumberCompare(InSignature.R, SM2.Order) >= 0 then
      Exit;
    if BigNumberCompare(InSignature.S, SM2.Order) >= 0 then
      Exit;

    Sm3Dig := CalcSM2SignatureHash(UserID, PlainData, DataLen, PublicKey, SM2); // �Ӵ�ֵ e

    P := TCnEccPoint.Create;
    Q := TCnEccPoint.Create;
    E := TCnBigNumber.Create;
    R := TCnBigNumber.Create;
    K := TCnBigNumber.Create;

    if not BigNumberAdd(K, InSignature.R, InSignature.S) then
      Exit;
    if not BigNumberNonNegativeMod(R, K, SM2.Order) then
      Exit;
    if R.IsZero then  // (r + s) mod n = 0 ��ʧ�ܣ����� R �����е� T
      Exit;

    P.Assign(SM2.Generator);
    SM2.MultiplePoint(InSignature.S, P);
    Q.Assign(PublicKey);
    SM2.MultiplePoint(R, Q);
    SM2.PointAddPoint(P, Q, P);   // s * G + t * PublicKey => P

    E.SetBinary(@Sm3Dig[0], SizeOf(TSM3Digest));
    if not BigNumberAdd(E, E, P.X) then
      Exit;

    if not BigNumberNonNegativeMod(R, E, SM2.Order) then
      Exit;

    Result := BigNumberCompare(R, InSignature.R) = 0;
    _CnSetLastError(ECN_SM2_OK); // ��������У�飬��ʹУ�鲻ͨ��Ҳ��մ�����
  finally
    K.Free;
    P.Free;
    Q.Free;
    R.Free;
    E.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2SignFile(const UserID: AnsiString; const FileName: string;
  PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey; SM2: TCnSM2): string;
var
  OutSign: TCnSM2Signature;
  Stream: TMemoryStream;
begin
  Result := '';
  if not FileExists(FileName) then
  begin
    _CnSetLastError(ECN_FILE_NOT_FOUND);
    Exit;
  end;

  OutSign := nil;
  Stream := nil;

  try
    OutSign := TCnSM2Signature.Create;
    Stream := TMemoryStream.Create;

    Stream.LoadFromFile(FileName);
    if CnSM2SignData(UserID, Stream.Memory, Stream.Size, OutSign, PrivateKey, PublicKey, SM2) then
      Result := OutSign.ToHex(SM2.BytesCount);
  finally
    Stream.Free;
    OutSign.Free;
  end;
end;

function CnSM2VerifyFile(const UserID: AnsiString; const FileName: string;
  const InHexSignature: string; PublicKey: TCnSM2PublicKey; SM2: TCnSM2): Boolean;
var
  InSign: TCnSM2Signature;
  Stream: TMemoryStream;
begin
  Result := False;
  if not FileExists(FileName) then
  begin
    _CnSetLastError(ECN_FILE_NOT_FOUND);
    Exit;
  end;

  InSign := nil;
  Stream := nil;

  try
    InSign := TCnSM2Signature.Create;
    InSign.SetHex(InHexSignature);

    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(FileName);

    Result := CnSM2VerifyData(UserID, Stream.Memory, Stream.Size, InSign, PublicKey, SM2);
  finally
    Stream.Free;
    InSign.Free;
  end;
end;

{
  ���㽻��������Կ��KDF(Xuv��Yuv��Za��Zb, kLen)
}
function CalcSM2ExchangeKey(UV: TCnEccPoint; Za, Zb: TSM3Digest; KeyByteLength: Integer): AnsiString;
var
  Stream: TMemoryStream;
  S: AnsiString;
begin
  Stream := TMemoryStream.Create;
  try
    BigNumberWriteBinaryToStream(UV.X, Stream);
    BigNumberWriteBinaryToStream(UV.Y, Stream);
    Stream.Write(Za[0], SizeOf(TSM3Digest));
    Stream.Write(Zb[0], SizeOf(TSM3Digest));

    SetLength(S, Stream.Size);
    Stream.Position := 0;
    Stream.Read(S[1], Stream.Size);

    Result := CnSM2KDF(S, KeyByteLength);
  finally
    SetLength(S, 0);
    Stream.Free;
  end;
end;

{
  Hash(0x02��Yuv��Hash(Xuv��Za��Zb��X1��Y1��X2��Y2))
       0x03
}
function CalcSM2OptionalSig(UV, P1, P2: TCnEccPoint; Za, Zb: TSM3Digest; Step2or3: Boolean): TSM3Digest;
var
  Stream: TMemoryStream;
  Sm3Dig: TSM3Digest;
  B: Byte;
begin
  if Step2or3 then
    B := 2
  else
    B := 3;

  Stream := TMemoryStream.Create;
  try
    BigNumberWriteBinaryToStream(UV.X, Stream);
    Stream.Write(Za[0], SizeOf(TSM3Digest));
    Stream.Write(Zb[0], SizeOf(TSM3Digest));
    BigNumberWriteBinaryToStream(P1.X, Stream);
    BigNumberWriteBinaryToStream(P1.Y, Stream);
    BigNumberWriteBinaryToStream(P2.X, Stream);
    BigNumberWriteBinaryToStream(P2.Y, Stream);
    Sm3Dig := SM3(PAnsiChar(Stream.Memory), Stream.Size);

    Stream.Clear;
    Stream.Write(B, 1);
    BigNumberWriteBinaryToStream(UV.Y, Stream);
    Stream.Write(Sm3Dig[0], SizeOf(TSM3Digest));

    Result := SM3(PAnsiChar(Stream.Memory), Stream.Size);
  finally
    Stream.Free;
  end;
end;

{
  ���ֵ rA * G => RA ���� B
}
function CnSM2KeyExchangeAStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey;
  OutARand: TCnBigNumber; OutRA: TCnEccPoint; SM2: TCnSM2): Boolean;
var
  SM2IsNil: Boolean;
begin
  Result := False;
  if (KeyByteLength <= 0) or (APrivateKey = nil) or (APublicKey = nil) or (OutRA = nil)
    or (OutARand = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;
  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    if not BigNumberRandRange(OutARand, SM2.Order) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;

    OutRA.Assign(SM2.Generator);
    SM2.MultiplePoint(OutARand, OutRA);
    Result := True;
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

{
  ���ֵ * G => RB
  x2 <= RB.X
  X2 <= 2^W + (x2 and (2^W - 1) ��ʾ�� x2 �ĵ� W λ�� 1��W + 1 ����ȫ�� 0
  T <= (BPrivateKey + ���ֵ * X2) mod N

  x1 <= RA.X
  X1 <= 2^W + (x1 and (2^W - 1)
  KB <= (h * T) * (APublicKey + X1 * RA)

  ע�� BigNumber �� BitCount Ϊ 2 Ϊ�׵Ķ�������ȡ��
}
function CnSM2KeyExchangeBStep1(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey; InRA: TCnEccPoint;
  out OutKeyB: AnsiString; OutRB: TCnEccPoint; out OutOptionalSB: TSM3Digest;
  out OutOptionalS2: TSM3Digest; SM2: TCnSM2): Boolean;
var
  SM2IsNil: Boolean;
  R, X, T: TCnBigNumber;
  V: TCnEccPoint;
  Za, Zb: TSM3Digest;
begin
  Result := False;
  if (KeyByteLength <= 0) or (BPrivateKey = nil) or (APublicKey = nil) or
    (BPublicKey = nil) or (InRA = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;
  R := nil;
  X := nil;
  T := nil;
  V := nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    if not SM2.IsPointOnCurve(InRA) then // ��֤�������� RA �Ƿ����㷽��
      Exit;

    R := TCnBigNumber.Create;
    if not BigNumberRandRange(R, SM2.Order) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;

    OutRB.Assign(SM2.Generator);
    SM2.MultiplePoint(R, OutRB);

    X := TCnBigNumber.Create;
    BigNumberCopy(X, OutRB.X);

    // 2^W �η���ʾ�� W λ 1��λ�� 0 ��ʼ�㣩 ��2^W - 1 ���ʾ 0 λ�� W - 1 λȫ�� 1
    // X2 = 2^W + (x2 and (2^W - 1) ��ʾ�� x2 �ĵ� W λ�� 1��W + 1 ����ȫ�� 0��x2 �� RB.X
    BuildShortXValue(X, SM2.Order);

    if not BigNumberMul(X, R, X) then
      Exit;
    if not BigNumberAdd(X, X, BPrivateKey) then
      Exit;

    T := TCnBigNumber.Create;
    if not BigNumberNonNegativeMod(T, X, SM2.Order) then // T = (BPrivateKey + ���ֵ * X2) mod N
      Exit;

    BigNumberCopy(X, InRA.X);
    BuildShortXValue(X, SM2.Order);

    // ���� XV YV�� (h * t) * (APublicKey + X * RA)
    V := TCnEccPoint.Create;
    V.Assign(InRA);
    SM2.MultiplePoint(X, V);
    SM2.PointAddPoint(V, APublicKey, V);
    SM2.MultiplePoint(T, V);

    if V.X.IsZero or V.Y.IsZero then // ���������Զ����Э��ʧ��
    begin
      _CnSetLastError(ECN_SM2_KEYEXCHANGE_INFINITE_ERROR);
      Exit;
    end;

    // Э�̳����ɹ������� KB
    Za := CalcSM2UserHash(AUserID, APublicKey, SM2);
    Zb := CalcSM2UserHash(BUserID, BPublicKey, SM2);
    OutKeyB := CalcSM2ExchangeKey(V, Za, Zb, KeyByteLength); // ������ԿЭ�̳ɹ���

    // Ȼ����� SB �� A �˶�
    OutOptionalSB := CalcSM2OptionalSig(V, InRA, OutRB, Za, Zb, True);

    // ˳����� S2 �� A ���� SA ʱ�˶�
    OutOptionalS2 := CalcSM2OptionalSig(V, InRA, OutRB, Za, Zb, False);
    Result := True;
  finally
    V.Free;
    T.Free;
    X.Free;
    R.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2KeyExchangeAStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  APrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey; MyRA, InRB: TCnEccPoint;
  MyARand: TCnBigNumber; out OutKeyA: AnsiString; InOptionalSB: TSM3Digest;
  out OutOptionalSA: TSM3Digest; SM2: TCnSM2): Boolean;
var
  SM2IsNil: Boolean;
  X, T: TCnBigNumber;
  U: TCnEccPoint;
  Za, Zb: TSM3Digest;
begin
  Result := False;
  if (KeyByteLength <= 0) or (APrivateKey = nil) or (APublicKey = nil) or
    (BPublicKey = nil) or (MyRA = nil) or (InRB = nil) or (MyARand = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;
  X := nil;
  T := nil;
  U := nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    if not SM2.IsPointOnCurve(InRB) then // ��֤�������� RB �Ƿ����㷽��
      Exit;

    X := TCnBigNumber.Create;
    BigNumberCopy(X, MyRA.X);
    BuildShortXValue(X, SM2.Order);     // �� RA ������ X1

    if not BigNumberMul(X, MyARand, X) then
      Exit;
    if not BigNumberAdd(X, X, APrivateKey) then
      Exit;

    T := TCnBigNumber.Create;
    if not BigNumberNonNegativeMod(T, X, SM2.Order) then // T = (APrivateKey + ���ֵ * X1) mod N
      Exit;

    BigNumberCopy(X, InRB.X);
    BuildShortXValue(X, SM2.Order);

    // ���� XU YU�� (h * t) * (BPublicKey + X * RB)
    U := TCnEccPoint.Create;
    U.Assign(InRB);
    SM2.MultiplePoint(X, U);
    SM2.PointAddPoint(U, BPublicKey, U);
    SM2.MultiplePoint(T, U);

    if U.X.IsZero or U.Y.IsZero then // ���������Զ����Э��ʧ��
    begin
      _CnSetLastError(ECN_SM2_KEYEXCHANGE_INFINITE_ERROR);
      Exit;
    end;

    // Э�̳����ɹ������� KA
    Za := CalcSM2UserHash(AUserID, APublicKey, SM2);
    Zb := CalcSM2UserHash(BUserID, BPublicKey, SM2);
    OutKeyA := CalcSM2ExchangeKey(U, Za, Zb, KeyByteLength); // ������ԿЭ�̳ɹ���

    // Ȼ����� SB �˶�
    OutOptionalSA := CalcSM2OptionalSig(U, MyRA, InRB, Za, Zb, True);
    if not CompareMem(@OutOptionalSA[0], @InOptionalSB[0], SizeOf(TSM3Digest)) then
      Exit;

    // Ȼ����� SA �� B �˶�
    OutOptionalSA := CalcSM2OptionalSig(U, MyRA, InRB, Za, Zb, False);
    Result := True;
  finally
    U.Free;
    T.Free;
    X.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2KeyExchangeBStep2(const AUserID, BUserID: AnsiString; KeyByteLength: Integer;
  BPrivateKey: TCnSM2PrivateKey; APublicKey, BPublicKey: TCnSM2PublicKey;
  InOptionalSA: TSM3Digest; MyOptionalS2: TSM3Digest; SM2: TCnSM2): Boolean;
begin
  Result := CompareMem(@InOptionalSA[0], @MyOptionalS2[0], SizeOf(TSM3Digest));
end;

{
  ���ȡ r
  �� R <= r * G
  �� c <= Hash(PublicKey, R)
  �� z <= r + c * PrivateKey
}
function CnSM2SchnorrProve(PrivateKey: TCnSM2PrivateKey; PublicKey: TCnSM2PublicKey;
  OutR: TCnEccPoint; OutZ: TCnBigNumber; SM2: TCnSM2): Boolean;
var
  R: TCnBigNumber;
  Dig: TSM3Digest;
  SM2IsNil: Boolean;
  Stream: TMemoryStream;
begin
  Result := False;
  if (PrivateKey = nil) or (PublicKey = nil) or (OutR = nil) or (OutZ = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  R := nil;
  Stream := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    R := TCnBigNumber.Create;
    if not BigNumberRandBytes(R, CN_SM2_FINITEFIELD_BYTESIZE) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;

    OutR.Assign(SM2.Generator);
    SM2.MultiplePoint(R, OutR);

    Stream := TMemoryStream.Create;
    if CnEccPointToStream(PublicKey, Stream, CN_SM2_FINITEFIELD_BYTESIZE) <= 0 then
      Exit;

    if CnEccPointToStream(OutR, Stream, CN_SM2_FINITEFIELD_BYTESIZE) <= 0 then
      Exit;

    Dig := SM3(Stream.Memory, Stream.Size);

    OutZ.SetBinary(@Dig[0], SizeOf(TSM3Digest));

    // ע�⣬�˴�����Ҳ���� mod P��
    if not BigNumberMul(OutZ, OutZ, PrivateKey) then
      Exit;

    if not BigNumberAdd(OutZ, OutZ, R) then
      Exit;

    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    Stream.Free;
    R.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

{
  �� c <= Hash(PublicKey, R)
  �� z * G ?= R + c * PublicKey
}
function CnSM2SchnorrCheck(PublicKey: TCnSM2PublicKey; InR: TCnEccPoint;
  InZ: TCnBigNumber; SM2: TCnSM2): Boolean;
var
  C: TCnBigNumber;
  Dig: TSM3Digest;
  SM2IsNil: Boolean;
  Stream: TMemoryStream;
  P1, P2: TCnEccPoint;
begin
  Result := False;
  if (PublicKey = nil) or (InR = nil) or (InZ = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  Stream := nil;
  C := nil;
  P1 := nil;
  P2 := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    Stream := TMemoryStream.Create;
    if CnEccPointToStream(PublicKey, Stream, CN_SM2_FINITEFIELD_BYTESIZE) <= 0 then
      Exit;

    if CnEccPointToStream(InR, Stream, CN_SM2_FINITEFIELD_BYTESIZE) <= 0 then
      Exit;

    Dig := SM3(Stream.Memory, Stream.Size);

    C := TCnBigNumber.Create;
    C.SetBinary(@Dig[0], SizeOf(TSM3Digest));

    P1 := TCnEccPoint.Create;
    P1.Assign(SM2.Generator);
    SM2.MultiplePoint(InZ, P1);

    P2 := TCnEccPoint.Create;
    P2.Assign(PublicKey);
    SM2.MultiplePoint(C, P2);
    SM2.PointAddPoint(P2, InR, P2);

    Result := CnEccPointsEqual(P1, P2);
    _CnSetLastError(ECN_SM2_OK);
  finally
    P2.Free;
    P1.Free;
    C.Free;
    Stream.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

// ========== SM2 ��Բ����˫���������εļ���Эͬ�㷨֮Эͬ��Կ���� =============

function CnSM2CollaborativeGenerateKeyAStep1(PrivateKeyA: TCnSM2CollaborativePrivateKey;
  PointToB: TCnEccPoint; SM2: TCnSM2): Boolean;
var
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKeyA = nil) or (PointToB = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    if not BigNumberRandRange(PrivateKeyA, SM2.Order) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;
    if PrivateKeyA.IsZero then // ��һ���õ� 0���ͼ� 1
      PrivateKeyA.SetOne;

    PointToB.Assign(SM2.Generator);
    SM2.MultiplePoint(PrivateKeyA, PointToB); // ����� PrivateKeyA �θ� B

    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2CollaborativeGenerateKeyBStep1(PrivateKeyB: TCnSM2CollaborativePrivateKey;
  InPointFromA: TCnEccPoint; PublicKey: TCnSM2CollaborativePublicKey; SM2: TCnSM2): Boolean;
var
  P: TCnEccPoint;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKeyB = nil) or (InPointFromA = nil) or (PublicKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  P := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    if not BigNumberRandRange(PrivateKeyB, SM2.Order) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;
    if PrivateKeyB.IsZero then // ��һ���õ� 0���ͼ� 1
      PrivateKeyB.SetOne;

    PublicKey.Assign(InPointFromA);
    SM2.MultiplePoint(PrivateKeyB, PublicKey); // �õ��� PublicKey ��Ҫ�� G

    P := TCnEccPoint.Create;
    P.Assign(SM2.Generator);
    SM2.PointInverse(P);
    SM2.PointAddPoint(PublicKey, P, PublicKey);

    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    P.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

// =============== SM2 ��Բ����˫���������εļ���Эͬǩ���㷨 ==================

function CnSM2CollaborativeSignAStep1(const UserID: AnsiString; PlainData: Pointer;
  DataLen: Integer; OutHashEToB: TCnBigNumber; OutQToB: TCnEccPoint; OutRandK: TCnBigNumber;
  PrivateKeyA: TCnSM2CollaborativePrivateKey; PublicKey: TCnSM2PublicKey; SM2: TCnSM2): Boolean;
var
  Sm3Dig: TSM3Digest;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKeyA = nil) or (OutHashEToB = nil) or (OutQToB = nil) or
    (OutRandK = nil) or (PublicKey = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    Sm3Dig := CalcSM2SignatureHash(UserID, PlainData, DataLen, PublicKey, SM2); // �Ӵ�ֵ e Ҫ�� B
    OutHashEToB.SetBinary(@Sm3Dig[0], SizeOf(TSM3Digest));

    if not BigNumberRandRange(OutRandK, SM2.Order) then
    begin
      _CnSetLastError(ECN_SM2_RANDOM_ERROR);
      Exit;
    end;
    if OutRandK.IsZero then // ��һ���õ� 0���ͼ� 1
      OutRandK.SetOne;

    OutQToB.Assign(SM2.Generator);
    SM2.MultiplePoint(OutRandK, OutQToB); // K Ҫ���Ÿ� A ǩ������һ��

    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2CollaborativeSignBStep1(InHashEFromA: TCnBigNumber; InQFromA: TCnEccPoint;
  OutRToB, OutS1ToB, OutS2ToB: TCnBigNumber; PrivateKeyB: TCnSM2CollaborativePrivateKey;
  SM2: TCnSM2): Boolean;
var
  K1, K2, Inv: TCnBigNumber;
  P, Q: TCnEccPoint;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKeyB = nil) or (InHashEFromA = nil) or (InQFromA = nil)
    or (OutRToB = nil) or (OutS1ToB = nil) or (OutS2ToB = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  K1 := nil;
  K2 := nil;
  Q := nil;
  P := nil;
  Inv := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    K1 := TCnBigNumber.Create;
    K2 := TCnBigNumber.Create;
    Q := TCnEccPoint.Create;
    P := TCnEccPoint.Create;
    Inv := TCnBigNumber.Create;

    while True do
    begin
      if not BigNumberRandRange(K1, SM2.Order) then
      begin
        _CnSetLastError(ECN_SM2_RANDOM_ERROR);
        Exit;
      end;
      if K1.IsZero then // ��һ���õ� 0���ͼ� 1
        K1.SetOne;

      Q.Assign(SM2.Generator);
      SM2.MultiplePoint(K1, Q); // �ȼ����һ���Լ��� Q ��

      // ������һ����� K
      if not BigNumberRandRange(K2, SM2.Order) then
      begin
        _CnSetLastError(ECN_SM2_RANDOM_ERROR);
        Exit;
      end;
      if K2.IsZero then // ��һ���õ� 0���ͼ� 1
        K2.SetOne;

      P.Assign(InQFromA);
      SM2.MultiplePoint(K2, P);   // �Է��� Q ������Լ��� K
      SM2.PointAddPoint(P, Q, Q); // �ټ����Լ��� Q

      // r = (Q.x + e) mod N
      if not BigNumberAddMod(OutRToB, Q.X, InHashEFromA, SM2.Order) then
        Exit;

      if OutRToB.IsZero then
        Continue;

      if not BigNumberModularInverse(Inv, PrivateKeyB, SM2.Order) then
        Exit;

      if not BigNumberDirectMulMod(OutS1ToB, Inv, K2, SM2.Order) then // ��� s1 = k2 / PrivateKeyB
        Exit;

      if not BigNumberAddMod(K1, K1, OutRToB, SM2.Order) then // K1 + r
        Exit;

      if not BigNumberDirectMulMod(OutS2ToB, K1, Inv, SM2.Order) then // K1 + r / PrivateKeyB
        Exit;

      Result := True;
      _CnSetLastError(ECN_SM2_OK);

      Break;
    end;
  finally
    Inv.Free;
    P.Free;
    Q.Free;
    K2.Free;
    K1.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2CollaborativeSignAStep2(InRandK, InRFromB, InS1FromB, InS2FromB: TCnBigNumber;
  OutSignature: TCnSM2Signature; PrivateKeyA: TCnSM2CollaborativePrivateKey; SM2: TCnSM2): Boolean;
var
  Inv, T: TCnBigNumber;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKeyA = nil) or (OutSignature = nil) or
    (InRFromB = nil) or (InS1FromB = nil) or (InS2FromB = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  Inv := nil;
  T := nil;
  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    Inv := TCnBigNumber.Create;
    if not BigNumberModularInverse(Inv, PrivateKeyA, SM2.Order) then
      Exit;

    T := TCnBigNumber.Create;
    if not BigNumberDirectMulMod(T, Inv, InS2FromB, SM2.Order) then // T := S2 / PrivateKeyA
      Exit;

    if not BigNumberDirectMulMod(OutSignature.S, InRandK, Inv, SM2.Order) then // K / PrivateKeyA
      Exit;

    if not BigNumberDirectMulMod(OutSignature.S, OutSignature.S, InS1FromB, SM2.Order) then // K * S1 / PrivateKeyA
      Exit;

    if not BigNumberAddMod(OutSignature.S, OutSignature.S, T, SM2.Order) then
      Exit;

    if not BigNumberSubMod(OutSignature.S, OutSignature.S, InRFromB, SM2.Order) then
      Exit;

    if not OutSignature.S.IsZero then
    begin
      if not BigNumberAdd(T, OutSignature.S, InRFromB) then
        Exit;

      if not BigNumberEqual(T, SM2.Order) then
      begin
        if BigNumberCopy(OutSignature.R, InRFromB) = nil then
          Exit;
      end;

      Result := True;
      _CnSetLastError(ECN_SM2_OK);
    end;
  finally
    T.Free;
    Inv.Free;
    if SM2IsNil then
      SM2.Free;
  end;
end;

// =============== SM2 ��Բ����˫���������εļ���Эͬ�����㷨 ==================

function CnSM2CollaborativeDecryptAStep1(EnData: Pointer; DataLen: Integer;
  OutTToB: TCnEccPoint; PrivateKeyA: TCnSM2CollaborativePrivateKey;
  SM2: TCnSM2): Boolean;
var
  MLen: Integer;
  M: PAnsiChar;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (EnData = nil) or (DataLen <= 0) or (PrivateKeyA = nil)
    or (OutTToB = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    MLen := DataLen - SizeOf(TSM3Digest) - (SM2.BitsCount div 4);
    if MLen <= 0 then
    begin
      _CnSetLastError(ECN_SM2_INVALID_INPUT);
      Exit;
    end;

    M := PAnsiChar(EnData);
    if M^ = #$04 then  // �������ܵ�ǰ���ֽ� $04
    begin
      Dec(MLen);
      if MLen <= 0 then
      begin
        _CnSetLastError(ECN_SM2_INVALID_INPUT);
        Exit;
      end;

      Inc(M);
    end;

    // ���� C1
    OutTToB.X.SetBinary(M, SM2.BitsCount div 8);
    Inc(M, SM2.BitsCount div 8);
    OutTToB.Y.SetBinary(M, SM2.BitsCount div 8);
    if OutTToB.IsZero then
    begin
      _CnSetLastError(ECN_SM2_DECRYPT_INFINITE_ERROR);
      Exit;
    end;

    SM2.MultiplePoint(PrivateKeyA, OutTToB); // C1 ���˽Կ���� B

    Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2CollaborativeDecryptBStep1(InTFromA: TCnEccPoint; OutTToA: TCnEccPoint;
  PrivateKeyB: TCnSM2CollaborativePrivateKey; SM2: TCnSM2): Boolean;
var
  SM2IsNil: Boolean;
begin
  Result := False;
  if (PrivateKeyB = nil) or (InTFromA = nil) or (OutTToA = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    OutTToA.Assign(InTFromA);
    SM2.MultiplePoint(PrivateKeyB, OutTToA);

     Result := True;
    _CnSetLastError(ECN_SM2_OK);
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

function CnSM2CollaborativeDecryptAStep2(EnData: Pointer; DataLen: Integer;
  InTFromB: TCnEccPoint; OutStream: TStream; PrivateKeyA: TCnSM2CollaborativePrivateKey;
  SM2: TCnSM2; SequenceType: TCnSM2CryptSequenceType): Boolean;
var
  MLen: Integer;
  M: PAnsiChar;
  MP: AnsiString;
  KDFStr, T, C3H: AnsiString;
  P2: TCnEccPoint;
  I, PrefixLen: Integer;
  Sm3Dig: TSM3Digest;
  SM2IsNil: Boolean;
begin
  Result := False;
  if (EnData = nil) or (DataLen <= 0) or (PrivateKeyA = nil)
    or (InTFromB = nil) or (OutStream = nil) then
  begin
    _CnSetLastError(ECN_SM2_INVALID_INPUT);
    Exit;
  end;

  SM2IsNil := SM2 = nil;

  try
    if SM2IsNil then
      SM2 := TCnSM2.Create;

    MLen := DataLen - SizeOf(TSM3Digest) - (SM2.BitsCount div 4);
    if MLen <= 0 then
    begin
      _CnSetLastError(ECN_SM2_INVALID_INPUT);
      Exit;
    end;

    P2 := TCnEccPoint.Create;
    M := PAnsiChar(EnData);
    if M^ = #$04 then  // �������ܵ�ǰ���ֽ� $04
    begin
      Dec(MLen);
      if MLen <= 0 then
      begin
        _CnSetLastError(ECN_SM2_INVALID_INPUT);
        Exit;
      end;

      PrefixLen := 1;
      Inc(M);
    end
    else
      PrefixLen := 0;

    // ���� C1
    P2.X.SetBinary(M, SM2.BitsCount div 8);
    Inc(M, SM2.BitsCount div 8);
    P2.Y.SetBinary(M, SM2.BitsCount div 8);
    if P2.IsZero then
    begin
      _CnSetLastError(ECN_SM2_DECRYPT_INFINITE_ERROR);
      Exit;
    end;

    // P2 <= InTFromB - C1
    SM2.PointSubPoint(InTFromB, P2, P2);

    // ����ͬ�������

    SetLength(KDFStr, P2.X.GetBytesCount + P2.Y.GetBytesCount);
    P2.X.ToBinary(@KDFStr[1]);
    P2.Y.ToBinary(@KDFStr[P2.X.GetBytesCount + 1]);
    T := CnSM2KDF(KDFStr, MLen);

    if SequenceType = cstC1C3C2 then
    begin
      SetLength(MP, MLen);
      M := PAnsiChar(EnData);
      Inc(M, SizeOf(TSM3Digest) + (SM2.BitsCount div 4) + PrefixLen); // ���� C3 ָ�� C2
      for I := 1 to MLen do
        MP[I] := AnsiChar(Byte(M[I - 1]) xor Byte(T[I])); // �� KDF ������� MP ��õ�����

      SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + MLen);
      P2.X.ToBinary(@C3H[1]);
      Move(MP[1], C3H[P2.X.GetBytesCount + 1], MLen);
      P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + MLen + 1]);    // ƴ���� C3 ��
      Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

      M := PAnsiChar(EnData);
      Inc(M, (SM2.BitsCount div 4) + PrefixLen);             // M ָ�� C3
      if CompareMem(@Sm3Dig[0], M, SizeOf(TSM3Digest)) then  // �ȶ� Hash �Ƿ����
      begin
        OutStream.Write(MP[1], Length(MP));

        Result := True;
        _CnSetLastError(ECN_SM2_OK);
      end;
    end
    else // C1C2C3 ������
    begin
      SetLength(MP, MLen);
      M := PAnsiChar(EnData);
      Inc(M, (SM2.BitsCount div 4) + PrefixLen);  // ָ�� C2

      for I := 1 to MLen do
        MP[I] := AnsiChar(Byte(M[I - 1]) xor Byte(T[I])); // �� KDF ������� MP ��õ�����

      SetLength(C3H, P2.X.GetBytesCount + P2.Y.GetBytesCount + MLen);
      P2.X.ToBinary(@C3H[1]);
      Move(MP[1], C3H[P2.X.GetBytesCount + 1], MLen);
      P2.Y.ToBinary(@C3H[P2.X.GetBytesCount + MLen + 1]);    // ƴ���� C3 ��
      Sm3Dig := SM3(@C3H[1], Length(C3H));                   // ��� C3

      M := PAnsiChar(EnData);
      Inc(M, (SM2.BitsCount div 4) + PrefixLen + MLen);      // ָ�� C3
      if CompareMem(@Sm3Dig[0], M, SizeOf(TSM3Digest)) then  // �ȶ� Hash �Ƿ����
      begin
        OutStream.Write(MP[1], Length(MP));

        Result := True;
        _CnSetLastError(ECN_SM2_OK);
      end;
    end;
  finally
    if SM2IsNil then
      SM2.Free;
  end;
end;

procedure CheckPrePower2Points;
var
  SM2: TCnSM2;
  P, Q: TCnEcc3Point;
  I: Integer;
begin
  if FSM2AffineGPower2KList.Count > 0 then
    Exit;

  SM2 := TCnSM2.Create;
  try
    P := TCnEcc3Point.Create;
    CnEccPointToEcc3Point(SM2.Generator, P);

    FSM2AffineGPower2KList.Add(P);      // �� 0 ���� 2 �� 0 �η�Ҳ���� 1 ����������
    for I := 1 to 255 do
    begin
      Q := TCnEcc3Point.Create;
      SM2.AffinePointAddPoint(P, P, Q); // Q ��� 2P
      FSM2AffineGPower2KList.Add(Q);    // �����б�
      P.Assign(Q);                      // P ��� 2P ׼���´�ѭ��
    end;
  finally
    SM2.Free;
  end;
end;

procedure InitSM2;
begin
  FSM2AffineGPower2KList := TObjectList.Create(True);
  CheckPrePower2Points;
end;

procedure FintSM2;
begin
  FSM2AffineGPower2KList.Free;
end;

initialization
  InitSM2;

finalization
  FintSM2;

end.

