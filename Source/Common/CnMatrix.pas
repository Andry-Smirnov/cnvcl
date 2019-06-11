{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2019 CnPack ������                       }
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

unit CnMatrix;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�������������ʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע���߽�����ʽ�Ĵ�������ʽ���㷽��������֤ͨ�����������������ܲ�������
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2019.06.5 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes;

type
  ECnMatrixException = class(Exception);

  TCnIntMatrix = class(TPersistent)
  {* Int64 ��Χ�ڵ����������ʵ����}
  private
    FMatrix: array of array of Int64;
    FColCount: Integer;
    FRowCount: Integer;
    procedure SetColCount(const Value: Integer);
    procedure SetRowCount(const Value: Integer);
    procedure CheckCount(Value: Int64);
    procedure SetValue(Row, Col: Integer; const Value: Int64);
    function GetValue(Row, Col: Integer): Int64;
  protected
    function OperationAdd(X, Y: Int64): Int64; virtual;
    function OperationMul(X, Y: Int64): Int64; virtual;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(ARowCount, AColCount: Integer); virtual;
    destructor Destroy; override;

    procedure Mul(Factor: Int64);
    {* �����Ԫ�س���һ������}
    procedure Divide(Factor: Int64);
    {* �����Ԫ�س���һ������}
    procedure Add(Factor: Int64);
    {* �����Ԫ�ؼ���һ������}
    procedure SetE(Size: Integer);
    {* ����Ϊ Size �׵�λ����}
    procedure SetZero;
    {* ����Ϊȫ 0 ����}

    function Determinant: Int64;
    {* ��������ʽֵ}
    function Trace: Int64;
    {* ����ļ���Ҳ���ǶԽ���Ԫ�صĺ�}
    function IsSquare: Boolean;
    {* �Ƿ���}
    function IsZero: Boolean;
    {* �Ƿ�ȫ 0 ����}
    function IsE: Boolean;
    {* �Ƿ�λ����}
    function IsSymmetrical: Boolean;
    {* �Ƿ�ԳƷ���}
    function IsSingular: Boolean;
    {* �Ƿ����췽��Ҳ��������ʽ�Ƿ���� 0}

    procedure DumpToStrings(List: TStrings; Sep: Char = ' ');
    {* ������ַ���}

    property Value[Row, Col: Integer]: Int64 read GetValue write SetValue;
    {* ���������±���ʾ���Ԫ�أ��±궼�� 0 ��ʼ}
  published
    property ColCount: Integer read FColCount write SetColCount;
    {* ��������}
    property RowCount: Integer read FRowCount write SetRowCount;
    {* ��������}
  end;

procedure CnMatrixMul(Matrix1, Matrix2: TCnIntMatrix; MulResult: TCnIntMatrix);
{* ����������ˣ������ MulResult �����У�Ҫ�� Matrix1 ������ Martrix2 ������ȡ�
  MulResult ������ Matrix1 �� Matrix2}

procedure CnMatrixPower(Matrix: TCnIntMatrix; K: Integer; PowerResult: TCnIntMatrix);
{* ���� K ���ݣ������ PowerResult �����У�PowerResult ������ Matrix}

procedure CnMatrixAdd(Matrix1, Matrix2: TCnIntMatrix; AddResult: TCnIntMatrix);
{* ����������ӣ������ AddResult �����У�Ҫ�� Matrix1 �ߴ��� Martrix2 ������ȡ�
  AddResult ������ Matrix1 �� Matrix2 ������}

procedure CnMatrixHadamardProduct(Matrix1, Matrix2: TCnIntMatrix; ProductResult: TCnIntMatrix);
{* ���������������ˣ������ ProductResult �����У�Ҫ�� Matrix1 �ߴ��� Martrix2 ������ȡ�
  ProductResult ������ Matrix1 �� Matrix2 ������}

procedure CnMatrixTranspose(Matrix1, Matrix2: TCnIntMatrix);
{* ת�þ��󣬽���һ������ת�����ڶ�����Matrix1��Matrix2 �������}

procedure CnMatrixMinor(Matrix: TCnIntMatrix; Row, Col: Integer; MinorResult: TCnIntMatrix);
{* ����������ʽ��Ҳ��ȥ��ָ�����к�ʣ�µľ���}

procedure CnMatrixAdjoint(Matrix1, Matrix2: TCnIntMatrix);
{* ����İ�����}

procedure CnMatrixInverse(Matrix1, Matrix2: TCnIntMatrix);
{* ���������󣬵����� TCnIntMatrix ������������ǰ������������ʽ�������һ���������������ܳ���}

implementation

// ���� -1 �� N �η��������������ʽ��
function NegativeOnePower(N: Integer): Integer; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
begin
  Result := (N and 1) * (-2) + 1;
end;

procedure CnMatrixMul(Matrix1, Matrix2: TCnIntMatrix; MulResult: TCnIntMatrix);
var
  I, J, K, T, Sum: Integer;
begin
  if (MulResult = Matrix1) or (MulResult = Matrix2) then
    raise ECnMatrixException.Create('Matrix Result can not Be Factors.');

  if Matrix1.ColCount <> Matrix2.RowCount then
    raise ECnMatrixException.Create('Matrix 1 Col Count must Equal to Matrix 2 Row Count.');

  MulResult.RowCount := Matrix1.RowCount;
  MulResult.ColCount := Matrix2.ColCount;

  // Value[I, J] := ���� 1 �� I ������� 2 �� J �ж�Ӧ�˲����
  for I := 0 to Matrix1.RowCount - 1 do
  begin
    for J := 0 to Matrix2.ColCount - 1 do
    begin
      Sum := 0;
      for K := 0 to Matrix1.ColCount - 1 do
      begin
        T := Matrix1.OperationMul(Matrix1.Value[I, K], Matrix2.Value[K, J]);
        Sum := Matrix1.OperationAdd(Sum, T);
      end;
      MulResult.Value[I, J] := Sum;
    end;
  end;
end;

procedure CnMatrixPower(Matrix: TCnIntMatrix; K: Integer; PowerResult: TCnIntMatrix);
var
  I: Integer;
  T: TCnIntMatrix;
begin
  if not Matrix.IsSquare then
    raise ECnMatrixException.Create('Matrix Power Must Be Square.');

  if K < 0 then
    raise ECnMatrixException.Create('Invalid Matrix Power.');

  if K = 0 then
  begin
    PowerResult.SetE(Matrix.RowCount);
    Exit;
  end
  else if K = 1 then
  begin
    PowerResult.Assign(Matrix);
    Exit;
  end;

  T := TCnIntMatrix.Create(Matrix.RowCount, Matrix.ColCount);
  try
    T.Assign(Matrix);
    for I := 0 to K - 2 do
    begin
      CnMatrixMul(Matrix, T, PowerResult);
      T.Assign(PowerResult);
    end;
  finally
    T.Free;
  end;
end;

procedure CnMatrixAdd(Matrix1, Matrix2: TCnIntMatrix; AddResult: TCnIntMatrix);
var
  I, J: Integer;
begin
  if (Matrix1.ColCount <> Matrix2.ColCount) or (Matrix1.RowCount <> Matrix2.RowCount) then
    raise ECnMatrixException.Create('Matrix 1/2 Row/Col Count must Equal.');

  AddResult.RowCount := Matrix1.RowCount;
  AddResult.ColCount := Matrix1.ColCount;
  for I := 0 to Matrix1.RowCount - 1 do
    for J := 0 to Matrix1.ColCount - 1 do
      AddResult.Value[I, J] := Matrix1.OperationAdd(Matrix1.Value[I, J], Matrix2.Value[I, J]);
end;

procedure CnMatrixHadamardProduct(Matrix1, Matrix2: TCnIntMatrix; ProductResult: TCnIntMatrix);
var
  I, J: Integer;
begin
  if (Matrix1.ColCount <> Matrix2.ColCount) or (Matrix1.RowCount <> Matrix2.RowCount) then
    raise ECnMatrixException.Create('Matrix 1/2 Row/Col Count must Equal.');

  ProductResult.RowCount := Matrix1.RowCount;
  ProductResult.ColCount := Matrix1.ColCount;
  for I := 0 to Matrix1.RowCount - 1 do
    for J := 0 to Matrix1.ColCount - 1 do
      ProductResult.Value[I, J] := Matrix1.OperationMul(Matrix1.Value[I, J], Matrix2.Value[I, J]);
end;

procedure CnMatrixTranspose(Matrix1, Matrix2: TCnIntMatrix);
var
  I, J: Integer;
  Tmp: TCnIntMatrix;
begin
  if Matrix1 = Matrix2 then
  begin
    Tmp := TCnIntMatrix.Create(1, 1);
    try
      Tmp.Assign(Matrix1);
      Matrix2.ColCount := Tmp.RowCount;
      Matrix2.RowCount := Tmp.ColCount;

      for I := 0 to Tmp.RowCount - 1 do
        for J := 0 to Tmp.ColCount - 1 do
          Matrix2.Value[J, I] := Tmp.Value[I, J];
    finally
      Tmp.Free;
    end;
  end
  else
  begin
    Matrix2.ColCount := Matrix1.RowCount;
    Matrix2.RowCount := Matrix1.ColCount;

    for I := 0 to Matrix1.RowCount - 1 do
      for J := 0 to Matrix1.ColCount - 1 do
        Matrix2.Value[J, I] := Matrix1.Value[I, J];
  end;
end;

procedure CnMatrixMinor(Matrix: TCnIntMatrix; Row, Col: Integer; MinorResult: TCnIntMatrix);
var
  SR, SC, DR, DC: Integer;
begin
  if ((Row < 0) or (Row >= Matrix.RowCount)) or
    ((Col < 0) or (Col >= Matrix.ColCount)) then
    raise ECnMatrixException.Create('Invalid Minor Row or Col.');

  MinorResult.ColCount := Matrix.ColCount - 1;
  MinorResult.RowCount := Matrix.RowCount - 1;

  SR := 0;
  DR := 0;

  while SR < Matrix.RowCount do
  begin
    if SR = Row then
    begin
      Inc(SR);
      if SR = Matrix.RowCount then
        Break;
    end;

    SC := 0;
    DC := 0;
    while SC < Matrix.ColCount do
    begin
      if SC = Col then
      begin
        Inc(SC);
        if SC = Matrix.ColCount then
          Break;
      end;

      MinorResult.Value[DR, DC] := Matrix.Value[SR, SC];
      Inc(SC);
      Inc(DC);
    end;

    Inc(SR);
    Inc(DR);
  end;
end;

procedure CnMatrixAdjoint(Matrix1, Matrix2: TCnIntMatrix);
var
  I, J: Integer;
  Minor: TCnIntMatrix;
begin
  if not Matrix1.IsSquare then
    raise ECnMatrixException.Create('Only Square can Adjoint.');

  Matrix2.RowCount := Matrix1.RowCount;
  Matrix2.ColCount := Matrix1.ColCount;

  Minor := TCnIntMatrix.Create(Matrix1.RowCount - 1, Matrix1.ColCount - 1);
  try
    for I := 0 to Matrix1.RowCount - 1 do
    begin
      for J := 0 to Matrix2.ColCount - 1 do
      begin
        CnMatrixMinor(Matrix1, I, J, Minor);
        Matrix2.Value[I, J] := NegativeOnePower(I + J) * Minor.Determinant;
      end;
    end;
    CnMatrixTranspose(Matrix2, Matrix2);
  finally
    Minor.Free;
  end;
end;

procedure CnMatrixInverse(Matrix1, Matrix2: TCnIntMatrix);
var
  D: Int64;
begin
  D := Matrix1.Determinant;
  if D = 0 then
    raise ECnMatrixException.Create('NO Inverse Matrix for Deteminant is 0');

  CnMatrixAdjoint(Matrix1, Matrix2);
  Matrix2.Divide(D); // ע�ⲻһ���������ˣ����Ƽ�ֱ���������
end;

{ TCnIntMatrix }

procedure TCnIntMatrix.Add(Factor: Int64);
var
  I, J: Integer;
begin
  for I := 0 to FRowCount - 1 do
    for J := 0 to FColCount - 1 do
      FMatrix[I, J] := OperationAdd(FMatrix[I, J], Factor);
end;

procedure TCnIntMatrix.AssignTo(Dest: TPersistent);
var
  I, J: Integer;
begin
  if Dest is TCnIntMatrix then
  begin
    TCnIntMatrix(Dest).RowCount := FRowCount;
    TCnIntMatrix(Dest).ColCount := FColCount;

    for I := 0 to FRowCount - 1 do
      for J := 0 to FColCount - 1 do
        TCnIntMatrix(Dest).Value[I, J] := FMatrix[I, J];
  end
  else
    inherited;
end;

procedure TCnIntMatrix.CheckCount(Value: Int64);
begin
  if Value <= 0 then
    raise ECnMatrixException.Create('Error Row or Col Count: ' + IntToStr(Value));
end;

constructor TCnIntMatrix.Create(ARowCount, AColCount: Integer);
begin
  inherited Create;
  CheckCount(ARowCount);
  CheckCount(AColCount);

  FRowCount := ARowCount;
  FColCount := AColCount;
  SetLength(FMatrix, FRowCount, FColCount);
end;

destructor TCnIntMatrix.Destroy;
begin
  SetLength(FMatrix, 0);
  inherited;
end;

function TCnIntMatrix.Determinant: Int64;
var
  I: Integer;
  Minor: TCnIntMatrix;
begin
  if not IsSquare then
    raise ECnMatrixException.Create('Only Square can Determinant.');

  if FRowCount = 1 then
    Result := FMatrix[0, 0]
  else if FRowCount = 2 then
    Result := FMatrix[0, 0] * FMatrix[1, 1] - FMatrix[0, 1] * FMatrix[1, 0]
  else if RowCount = 3 then
  begin
    Result := FMatrix[0, 0] * FMatrix[1, 1] * FMatrix[2, 2]
      + FMatrix[0, 1] * FMatrix[1, 2] * FMatrix[2, 0]
      + FMatrix[0, 2] * FMatrix[1, 0] * FMatrix[2, 1]
      - FMatrix[0, 0] * FMatrix[1, 2] * FMatrix[2, 1]
      - FMatrix[0, 1] * FMatrix[1, 0] * FMatrix[2, 2]
      - FMatrix[0, 2] * FMatrix[1, 1] * FMatrix[2, 0];
  end
  else
  begin
    // ���ô�������ʽ Minor/Cofactor ����߽�����ʽ
    Result := 0;
    Minor := TCnIntMatrix.Create(FRowCount - 1, FColCount - 1);
    try
      for I := 0 to FColCount - 1 do
      begin
        CnMatrixMinor(Self, 0, I, Minor);
        Result := Result + FMatrix[0, I] * NegativeOnePower(I) * Minor.Determinant;
      end;
    finally
      Minor.Free;
    end;
  end;
end;

procedure TCnIntMatrix.Divide(Factor: Int64);
var
  I, J: Integer;
begin
  for I := 0 to FRowCount - 1 do
    for J := 0 to FColCount - 1 do
      FMatrix[I, J] := FMatrix[I, J] div Factor;
end;

procedure TCnIntMatrix.DumpToStrings(List: TStrings; Sep: Char = ' ');
var
  I, J: Integer;
  S: string;
begin
  for I := 0 to FRowCount - 1 do
  begin
    S := '';
    for J := 0 to FColCount - 1 do
    begin
      if J = 0 then
        S := IntToStr(FMatrix[I, J])
      else
        S := S + Sep + IntToStr(FMatrix[I, J]);
    end;
    List.Add(S);
  end;
end;

function TCnIntMatrix.GetValue(Row, Col: Integer): Int64;
begin
  Result := FMatrix[Row, Col];
end;

function TCnIntMatrix.IsE: Boolean;
var
  I, J: Integer;
begin
  if not IsSquare then
  begin
    Result := False;
    Exit;
  end;

  for I := 0 to FRowCount - 1 do
  begin
    for J := 0 to FColCount - 1 do
    begin
      if (I = J) and (FMatrix[I, J] <> 1) then
      begin
        Result := False;
        Exit;
      end
      else if (I <> J) and (FMatrix[I, J] <> 0) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
  Result := True;
end;

function TCnIntMatrix.IsSingular: Boolean;
begin
  if not IsSquare then
    Result := False
  else
    Result := Determinant = 0;
end;

function TCnIntMatrix.IsSquare: Boolean;
begin
  Result := (FColCount = FRowCount);
end;

function TCnIntMatrix.IsSymmetrical: Boolean;
var
  I, J: Integer;
begin
  if not IsSquare then
  begin
    Result := False;
    Exit;
  end;

  for I := 0 to FRowCount - 1 do
    for J := 0 to I do
      if FMatrix[I, J] <> FMatrix[J, I] then
      begin
        Result := False;
        Exit;
      end;

  Result := True;
end;

function TCnIntMatrix.IsZero: Boolean;
var
  I, J: Integer;
begin
  if not IsSquare then
  begin
    Result := False;
    Exit;
  end;

  for I := 0 to FRowCount - 1 do
    for J := 0 to FColCount - 1 do
      if FMatrix[I, J] <> 0 then
      begin
        Result := False;
        Exit;
      end;

  Result := True;
end;

procedure TCnIntMatrix.Mul(Factor: Int64);
var
  I, J: Integer;
begin
  for I := 0 to FRowCount - 1 do
    for J := 0 to FColCount - 1 do
      FMatrix[I, J] := OperationMul(FMatrix[I, J], Factor);
end;

function TCnIntMatrix.OperationAdd(X, Y: Int64): Int64;
begin
  Result := X + Y;
end;

function TCnIntMatrix.OperationMul(X, Y: Int64): Int64;
begin
  Result := X * Y;
end;

procedure TCnIntMatrix.SetColCount(const Value: Integer);
begin
  if FColCount <> Value then
  begin
    CheckCount(Value);
    FColCount := Value;
    SetLength(FMatrix, FRowCount, FColCount);
  end;
end;

procedure TCnIntMatrix.SetE(Size: Integer);
var
  I, J: Integer;
begin
  CheckCount(Size);

  RowCount := Size;
  ColCount := Size;
  for I := 0 to Size - 1 do
    for J := 0 to Size - 1 do
      if I = J then
        FMatrix[I, J] := 1
      else
        FMatrix[I, J] := 0;
end;

procedure TCnIntMatrix.SetRowCount(const Value: Integer);
begin
  if FRowCount <> Value then
  begin
    CheckCount(Value);
    FRowCount := Value;
    SetLength(FMatrix, FRowCount, FColCount);
  end;
end;

procedure TCnIntMatrix.SetValue(Row, Col: Integer; const Value: Int64);
begin
  FMatrix[Row, Col] := Value;
end;

procedure TCnIntMatrix.SetZero;
var
  I, J: Integer;
begin
  for I := 0 to FRowCount - 1 do
    for J := 0 to FColCount - 1 do
      FMatrix[I, J] := 0;
end;

function TCnIntMatrix.Trace: Int64;
var
  I: Integer;
begin
  if not IsSquare then
    raise ECnMatrixException.Create('Only Square Matrix can Trace.');

  Result := 0;
  for I := 0 to FRowCount - 1 do
    Result := OperationAdd(Result, FMatrix[I, I]);
end;

end.

