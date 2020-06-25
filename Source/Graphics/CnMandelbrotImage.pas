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

unit CnMandelbrotImage;
{* |<PRE>
================================================================================
* ������ƣ�����ؼ���
* ��Ԫ���ƣ����²��޼�ͼʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע�������� Double ����Ӱ�첻�������ƷŴ�
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2019.12.21 V1.1
*               �ø߾�������������ʵ�����޷Ŵ󣬵������ٶȽ���
*           2019.12.18 V1.0
*               ������Ԫ��ʵ�ֹ��ܣ��� ScanLine ���ٻ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, Graphics, Controls, ExtCtrls, Contnrs, CnBigRational,
  CnBigDecimal;

const
  CN_MANDELBROT_MAX_COUNT = 100;

type
  TCnMandelbrotMode = (mmFloat, mmBigRational, mmBigDecimal);
  // ���������㡢�����������㡢�󸡵�������

  TCnMandelbrotFloatColorEvent = function (Sender: TObject; X, Y: Extended;
    XZ, YZ: Extended; Count: Integer): TColor of object;
  {* �������ȡɫ�ʺ�����ע�� C ������� C > CN_MANDELBROT_MAX_COUNT ��ʾ������Ӧ�÷��������������ɫ}

  TCnMandelbrotRationalColorEvent = function (Sender: TObject; X, Y: TCnBigRational;
    XZ, YZ: TCnBigRational; Count: Integer): TColor of object;

  TCnMandelbrotDecimalColorEvent = function (Sender: TObject; X, Y: TCnBigDecimal;
    XZ, YZ: TCnBigDecimal; Count: Integer): TColor of object;

  TCnMandelbrotImage = class(TGraphicControl)
  {* ���²��޼�ͼʵ�ֿؼ�}
  private
    // FMaps: array of array of TColor;
    FBitmap: TBitmap;
    FXValues: array of Extended;
    FYValues: array of Extended;
    FXRationals: TObjectList;
    FYRationals: TObjectList;
    FXDecimals: TObjectList;
    FYDecimals: TObjectList;
    FMaxY: Extended;
    FMinX: Extended;
    FMinY: Extended;
    FMaxX: Extended;
    FMaxRX: TCnBigRational;
    FMinRX: TCnBigRational;
    FMaxRY: TCnBigRational;
    FMinRY: TCnBigRational;
    FMaxDX: TCnBigDecimal;
    FMinDX: TCnBigDecimal;
    FMaxDY: TCnBigDecimal;
    FMinDY: TCnBigDecimal;
    FOnColor: TCnMandelbrotFloatColorEvent;
    FOnInfiniteColor: TCnMandelbrotRationalColorEvent;
    FShowAxis: Boolean;
    FAxisColor: TColor;
    FMode: TCnMandelbrotMode;
    FInSetCount: Integer;
    FOutSetCount: Integer;
    procedure SetMaxX(const Value: Extended);
    procedure SetMaxY(const Value: Extended);
    procedure SetMinX(const Value: Extended);
    procedure SetMinY(const Value: Extended);

    procedure UpdatePointsValues(AWidth, AHeight: Integer);
    procedure UpdateMatrixes(AWidth, AHeight: Integer);
    procedure SetShowAxis(const Value: Boolean);
    procedure SetAxisColor(const Value: TColor);
    procedure SetOnColor(const Value: TCnMandelbrotFloatColorEvent);
    procedure SetMode(const Value: TCnMandelbrotMode);
    procedure SetOnInfiniteColor(
      const Value: TCnMandelbrotRationalColorEvent);
  protected
    function CalcFloatColor(X, Y: Extended; out InSet: Boolean): TColor;
    function CalcInfiniteColor(X, Y: TCnBigRational; XZ, YZ: TCnBigRational): TColor;
    procedure ReCalcColors;
    procedure ReCalcFloatColors;
    procedure ReCalcBigRationalColors;
    procedure ReCalcBigDecimalColors;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Loaded; override;
    
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetRect(AMinX, AMaxX, AMinY, AMaxY: Extended); overload;
    procedure SetRect(AMinX, AMaxX, AMinY, AMaxY: TCnBigRational); overload;
    procedure GetComplexValues(X, Y: Integer; out R, I: Extended);
    procedure GetComplexRational(X, Y: Integer; R, I: TCnBigRational);
  published
    property Mode: TCnMandelbrotMode read FMode write SetMode;
    {* ����ģʽ����ʹ�þ������޵���չ���ȸ��㣬���Ǵ������������Ǵ󸡵���}

    property MinX: Extended read FMinX write SetMinX;
    {* X �����ֵ}
    property MinY: Extended read FMinY write SetMinY;
    {* Y ����Եֵ}
    property MaxX: Extended read FMaxX write SetMaxX;
    {* X �����ֵ}
    property MaxY: Extended read FMaxY write SetMaxY;
    {* Y ����Եֵ}

    property InSetCount: Integer read FInSetCount;
    {* һ�����������У������ڼ����ڵĵ�����}
    property OutSetCount: Integer read FOutSetCount;
    {* һ�����������У������ڼ�����ĵ�����}

    property OnColor: TCnMandelbrotFloatColorEvent read FOnColor write SetOnColor;
    {* �Զ������²��޼����ص����ɫ�£����ޣ����ڲ�ʹ�úڰ�ɫ}
    property OnInfiniteColor: TCnMandelbrotRationalColorEvent read FOnInfiniteColor
      write SetOnInfiniteColor;
    property ShowAxis: Boolean read FShowAxis write SetShowAxis;
    {* �Ƿ����������}
    property AxisColor: TColor read FAxisColor write SetAxisColor;
    {* ��������ɫ}
    property OnClick;
    {* ����¼����}
  end;

implementation

resourcestring
  SCnMandelbrotOutOfBounds = 'Invalid Mode or X Y Out of Bounds.';

type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array [Byte] of TRGBTriple;

var
  TmpXZ, TmpYZ: TCnBigRational;

procedure CalcMandelbortSetInfinitePoint(X, Y: TCnBigRational; XZ, YZ: TCnBigRational;
  out Count: Integer);

  function R2SqrSumGT4(A, B: TCnBigRational): Boolean;
  begin
    Result := False;
    TmpXZ.Assign(A);
    TmpYZ.Assign(B);
    TmpXZ.Mul(TmpXZ);
    TmpYZ.Mul(TmpYZ);
    TmpXZ.Add(TmpYZ);
    if CnBigRationalNumberCompare(TmpXZ, 4) > 0 then
      Result := True;
  end;

begin
  // ���������ķ�ʽ��������
  if TmpXZ = nil then
    TmpXZ := TCnBigRational.Create;
  if TmpYZ = nil then
    TmpYZ := TCnBigRational.Create;

  Count := 0;
  if R2SqrSumGT4(X, Y) then
    Exit;

  repeat
    TmpXZ.Assign(XZ);
    TmpYZ.Assign(YZ);
    TmpXZ.Mul(XZ);
    TmpYZ.Mul(YZ);

    YZ.Mul(XZ);
    YZ.Mul(2);
    YZ.Add(Y);

    XZ.Assign(TmpXZ);
    XZ.Sub(TmpYZ);
    XZ.Add(X);

    Inc(Count);
  until R2SqrSumGT4(XZ, YZ) or (Count > CN_MANDELBROT_MAX_COUNT);
end;

procedure CalcMandelbortSetFloatPoint(X, Y: Extended; out XZ, YZ: Extended; out Count: Integer);
var
  XZ2, YZ2: Extended;
begin
  XZ := 0.0;
  YZ := 0.0;
  Count := 0;

  if X * X + Y * Y > 4.0 then
    Exit;

  repeat
    // XZ + YZi := (XZ + YZi)^2 + (X + Yi);
    XZ2 := XZ * XZ;
    YZ2 := YZ * YZ;

    // ���ε�����������Ҫ���� XZ^2 �� YZ^2 ��ֵ��������;�����ı�
    YZ := 2.0 * XZ * YZ + Y;
    XZ := XZ2 - YZ2 + X;
    Inc(Count);
  until (XZ * XZ + YZ * YZ > 4.0) or (Count > CN_MANDELBROT_MAX_COUNT);
end;

{ TCnMandelbrotImage }

function TCnMandelbrotImage.CalcFloatColor(X, Y: Extended; out InSet: Boolean): TColor;
var
  XZ, YZ: Extended;
  C: Integer;
begin
  XZ := 0.0;
  YZ := 0.0;
  C := 0;

  CalcMandelbortSetFloatPoint(X, Y, XZ, YZ, C);

  if C > CN_MANDELBROT_MAX_COUNT then
  begin
    InSet := True;
    if Assigned(FOnColor) then
      Result := FOnColor(Self, X, Y, XZ, YZ, C)
    else
      Result := clNavy;
  end
  else
  begin
    InSet := False;
    if Assigned(FOnColor) then
      Result := FOnColor(Self, X, Y, XZ, YZ, C)
    else
      Result := clWhite;
  end;
end;

function TCnMandelbrotImage.CalcInfiniteColor(X,
  Y: TCnBigRational; XZ, YZ: TCnBigRational): TColor;
var
  C: Integer;
begin
  XZ.SetZero;
  YZ.SetZero;
  C := 0;

  CalcMandelbortSetInfinitePoint(X, Y, XZ, YZ, C);

  if C > CN_MANDELBROT_MAX_COUNT then
  begin
    if Assigned(FOnInfiniteColor) then
      Result := FOnInfiniteColor(Self, X, Y, XZ, YZ, C)
    else
      Result := clNavy;
  end
  else
  begin
    if Assigned(FOnInfiniteColor) then
      Result := FOnInfiniteColor(Self, X, Y, XZ, YZ, C)
    else
      Result := clWhite;
  end;
end;

constructor TCnMandelbrotImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinX := -2.0;
  FMaxX := 1.0;
  FMinY := -1.5;
  FMaxY := 1.5;

  FAxisColor := clTeal;
  FXRationals := TObjectList.Create(True);
  FYRationals := TObjectList.Create(True);
  FMaxRX := TCnBigRational.Create;
  FMinRX := TCnBigRational.Create;
  FMaxRY := TCnBigRational.Create;
  FMinRY := TCnBigRational.Create;
end;

destructor TCnMandelbrotImage.Destroy;
begin
  FMinRY.Free;
  FMaxRY.Free;
  FMinRX.Free;
  FMaxRX.Free;
  FYRationals.Free;
  FXRationals.Free;

  FBitmap.Free;
  SetLength(FXValues, 0);
  SetLength(FYValues, 0);
  inherited;
end;

procedure TCnMandelbrotImage.GetComplexRational(X, Y: Integer; R,
  I: TCnBigRational);
begin
  if (FMode = mmBigRational) and (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) then
  begin
    R.Assign(TCnBigRational(FXRationals[X]));
    I.Assign(TCnBigRational(FYRationals[Y]));
  end
  else
    raise Exception.Create(SCnMandelbrotOutOfBounds);
end;

procedure TCnMandelbrotImage.GetComplexValues(X, Y: Integer; out R,
  I: Extended);
begin
  if (FMode = mmFloat) and (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) then
  begin
    R := FXValues[X];
    I := FYValues[Y];
  end
  else
    raise Exception.Create(SCnMandelbrotOutOfBounds);
end;

procedure TCnMandelbrotImage.Loaded;
begin
  inherited;
  UpdateMatrixes(Width, Height);
  ReCalcFloatColors;
end;

procedure TCnMandelbrotImage.Paint;
var
  X, Y: Integer;
begin
  Canvas.Draw(0, 0, FBitmap);

  if ShowAxis then
  begin
    // ��� X Y ���λ�ã�����
    X := Trunc(Width * (-FMinX) / (FMaxX - FMinX));
    Y := Trunc(Height * (FMaxY) / (FMaxY - FMinY));

    Canvas.Pen.Color := FAxisColor;
    Canvas.Pen.Style := psSolid;
    Canvas.MoveTo(X, 0);
    Canvas.LineTo(X, Height);
    Canvas.MoveTo(0, Y);
    Canvas.LineTo(Width, Y);
  end;
end;

procedure TCnMandelbrotImage.ReCalcFloatColors;
var
  X, Y, C: Integer;
  AColor: TColor;
  R, G, B: Byte;
  Arr: PRGBTripleArray;
  InSet: Boolean;
begin
  FInSetCount := 0;
  FOutSetCount := 0;

  for Y := 0 to Height - 1 do
  begin
    Arr := PRGBTripleArray(FBitmap.ScanLine[Y]);
    for X := 0 to Width - 1 do
    begin
      AColor := CalcFloatColor(FXValues[X], FYValues[Y], InSet);
      if InSet then
        Inc(FInSetCount)
      else
        Inc(FOutSetCount);

      C := ColorToRGB(AColor);
      B := C and $FF0000 shr 16;
      G := C and $00FF00 shr 8;
      R := C and $0000FF;

      Arr^[X].rgbtRed := R;
      Arr^[X].rgbtGreen := G;
      Arr^[X].rgbtBlue := B;
    end;
  end;
  Invalidate;
end;

procedure TCnMandelbrotImage.ReCalcBigRationalColors;
var
  X, Y, C: Integer;
  AColor: TColor;
  R, G, B: Byte;
  Arr: PRGBTripleArray;
  XZ, YZ: TCnBigRational;
begin
  XZ := nil;
  YZ := nil;
  try
    XZ := TCnBigRational.Create;
    YZ := TCnBigRational.Create;

    for Y := 0 to Height - 1 do
    begin
      Arr := PRGBTripleArray(FBitmap.ScanLine[Y]);
      for X := 0 to Width - 1 do
      begin
        AColor := CalcInfiniteColor(TCnBigRational(FXRationals[X]),
          TCnBigRational(FYRationals[Y]), XZ, YZ);
        C := ColorToRGB(AColor);
        B := C and $FF0000 shr 16;
        G := C and $00FF00 shr 8;
        R := C and $0000FF;

        Arr^[X].rgbtRed := R;
        Arr^[X].rgbtGreen := G;
        Arr^[X].rgbtBlue := B;
      end;
    end;
  finally
    XZ.Free;
    YZ.Free;
  end;
  Invalidate;
end;

procedure TCnMandelbrotImage.SetAxisColor(const Value: TColor);
begin
  if Value <> FAxisColor then
  begin
    FAxisColor := Value;
    Invalidate;
  end;
end;

procedure TCnMandelbrotImage.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;
  if not (csLoading in ComponentState) then
  begin
    UpdateMatrixes(AWidth, AHeight);
    ReCalcColors;
  end;
end;

procedure TCnMandelbrotImage.SetMode(const Value: TCnMandelbrotMode);
begin
  if Value <> FMode then
  begin
    FMode := Value;
    FMinRX.SetFloat(FMinX);
    FMinRY.SetFloat(FMinY);
    FMaxRX.SetFloat(FMaxX);
    FMaxRY.SetFloat(FMaxY);

    UpdateMatrixes(Width, Height);
    UpdatePointsValues(Width, Height);

    ReCalcColors;
  end;
end;

procedure TCnMandelbrotImage.SetMaxX(const Value: Extended);
begin
  if Value <> FMaxX then
  begin
    FMaxX := Value;
    if not (csLoading in ComponentState) then
    begin
      UpdatePointsValues(Width, Height);
      ReCalcColors;
    end;
  end;
end;

procedure TCnMandelbrotImage.SetMaxY(const Value: Extended);
begin
  if Value <> FMaxY then
  begin
    FMaxY := Value;
    if not (csLoading in ComponentState) then
    begin
      UpdatePointsValues(Width, Height);
      ReCalcColors;;
    end;
  end;
end;

procedure TCnMandelbrotImage.SetMinX(const Value: Extended);
begin
  if Value <> FMinX then
  begin
    FMinX := Value;
    if not (csLoading in ComponentState) then
    begin
      UpdatePointsValues(Width, Height);
      ReCalcColors;
    end;
  end;
end;

procedure TCnMandelbrotImage.SetMinY(const Value: Extended);
begin
  if Value <> FMinY then
  begin
    FMinY := Value;
    if not (csLoading in ComponentState) then
    begin
      UpdatePointsValues(Width, Height);
      ReCalcFloatColors;
    end;
  end;
end;

procedure TCnMandelbrotImage.SetOnColor(const Value: TCnMandelbrotFloatColorEvent);
begin
  FOnColor := Value;
  Invalidate;
end;

procedure TCnMandelbrotImage.SetOnInfiniteColor(
  const Value: TCnMandelbrotRationalColorEvent);
begin
  FOnInfiniteColor := Value;
  Invalidate;
end;

procedure TCnMandelbrotImage.SetRect(AMinX, AMaxX, AMinY, AMaxY: Extended);
begin
  FMinX := AMinX;
  FMinY := AMinY;
  FMaxX := AMaxX;
  FMaxY := AMaxY;

  UpdatePointsValues(Width, Height);
  ReCalcFloatColors;
end;

procedure TCnMandelbrotImage.SetRect(AMinX, AMaxX, AMinY,
  AMaxY: TCnBigRational);
begin
  FMinRX.Assign(AMinX);
  FMinRY.Assign(AMinY);
  FMaxRX.Assign(AMaxX);
  FMaxRY.Assign(AMaxY);

  UpdatePointsValues(Width, Height);
  ReCalcBigRationalColors;
end;

procedure TCnMandelbrotImage.SetShowAxis(const Value: Boolean);
begin
  if Value <> FShowAxis then
  begin
    FShowAxis := Value;
    Invalidate;
  end;
end;

procedure TCnMandelbrotImage.UpdateMatrixes(AWidth, AHeight: Integer);
var
  I: Integer;
begin
  if FMode = mmFloat then
  begin
    SetLength(FXValues, AWidth);
    SetLength(FYValues, AHeight);
  end
  else if FMode = mmBigRational then
  begin
    // ��ʼ�� X��Y ���������б�
    FXRationals.Clear;
    for I := 1 to AWidth do
      FXRationals.Add(TCnBigRational.Create);
    FYRationals.Clear;
    for I := 1 to AHeight do
      FYRationals.Add(TCnBigRational.Create);
  end
  else
  begin
    // ��ʼ�� X��Y �Ĵ󸡵����б�
    FXDecimals.Clear;
    for I := 1 to AWidth do
      FXDecimals.Add(TCnBigDecimal.Create);
    FYRationals.Clear;
    for I := 1 to AHeight do
      FYDecimals.Add(TCnBigDecimal.Create);
  end;

  FreeAndNil(FBitmap);
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pf24bit;
  FBitmap.Width := AWidth;
  FBitmap.Height := AHeight;

  UpdatePointsValues(AWidth, AHeight);
end;

procedure TCnMandelbrotImage.UpdatePointsValues(AWidth, AHeight: Integer);
var
  X, Y, W, H: Integer;
  WX, HY: Extended;
  WRX, HRY: TCnBigRational;
  WDX, HDY: TCnBigDecimal;
begin
  W := Width - 1;
  H := Height - 1;
  if FMode = mmFloat then
  begin
    WX := (FMaxX - FMinX) / W;
    HY := (FMaxY - FMinY) / H;

    for X := 0 to W do
      FXValues[X] := FMinX + X * WX;

    for Y := 0 to H do
      FYValues[Y] := FMinY + (H - Y) * HY;
  end
  else if FMode = mmBigRational then
  begin
    // ��ʼ�� X��Y ����������ֵ
    WRX := TCnBigRational.Create;
    HRY := TCnBigRational.Create;

    CnBigRationalNumberSub(FMaxRX, FMinRX, WRX);
    WRX.Divide(W);
    CnBigRationalNumberSub(FMaxRY, FMinRY, HRY);
    HRY.Divide(H);

    for X := 0 to W do
    begin
      TCnBigRational(FXRationals[X]).Assign(WRX);
      TCnBigRational(FXRationals[X]).Mul(X);
      CnBigRationalNumberAdd(TCnBigRational(FXRationals[X]), FMinRX, TCnBigRational(FXRationals[X]));
    end;

    for Y := 0 to H do
    begin
      TCnBigRational(FYRationals[Y]).Assign(HRY);
      TCnBigRational(FYRationals[Y]).Mul(Y);
      CnBigRationalNumberAdd(TCnBigRational(FYRationals[Y]), FMinRY, TCnBigRational(FYRationals[Y]));
    end;
  end
  else
  begin
    // ��ʼ�� X��Y �Ĵ󸡵�����ֵ
//    WDX := TCnBigDecimal.Create;
//    HDY := TCnBigDecimal.Create;
//
//    BigDecimalSub(FMaxDX, FMinDX, WDX);
//    WDX.Divide(W);
//    BigDecimalSub(FMaxDY, FMinDY, HDY);
//    HDY.Divide(H);
//
//    for X := 0 to W do
//    begin
//      BigDecimalCopy(WDX, TCnBigDecimal(FXDecimals[X]));
//      TCnBigDecimal(FXDecimals[X]).Mul(X);
//      CnBigRationalNumberAdd(TCnBigDecimal(FXDecimals[X]), FMinRX, TCnBigDecimal(FXDecimals[X]));
//    end;
//
//    for Y := 0 to H do
//    begin
//      TCnBigDecimal(FYDecimals[Y]).Assign(HDY);
//      TCnBigDecimal(FYDecimals[Y]).Mul(Y);
//      CnBigRationalNumberAdd(TCnBigDecimal(FYDecimals[Y]), FMinRY, TCnBigDecimal(FYDecimals[Y]));
//    end;
  end;

  FBitmap.Canvas.Brush.Color := clWhite;
  FBitmap.Canvas.Brush.Style := bsSolid;
  FBitmap.Canvas.FillRect(Rect(0, 0, AHeight, AWidth));
end;

procedure TCnMandelbrotImage.ReCalcColors;
begin
  if FMode = mmFloat then
    ReCalcFloatColors
  else if FMode = mmBigRational then
    ReCalcBigRationalColors
  else if FMode = mmBigDecimal then
    RecalcBigDecimalColors;
end;

procedure TCnMandelbrotImage.ReCalcBigDecimalColors;
begin

end;

initialization

finalization
  TmpXZ.Free;
  TmpYZ.Free;

end.
