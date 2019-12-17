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

unit CnMandelbrotImage;
{* |<PRE>
================================================================================
* ������ƣ�����ؼ���
* ��Ԫ���ƣ����²��޼�ͼʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2019.12.17 V1.0
*               LiuXiao ��ֲ��Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Graphics, Controls, ExtCtrls;

const
  CN_MANDELBROT_MAX_COUNT = 100;

type
  TMandelbrotColorEvent = function (Sender: TObject; X, Y: Extended;
    XZ, YZ: Extended; Count: Integer): TColor of object;
  {* �������ȡɫ�ʺ�����ע�� C ������� C > CN_MANDELBROT_MAX_COUNT ��ʾ������Ӧ�÷��������������ɫ}

  TCnMandelbrotImage = class(TGraphicControl)
  {* ���²��޼�ͼʵ�ֿؼ�}
  private
    FMaps: array of array of TColor;
    FXValues: array of Extended;
    FYValues: array of Extended;
    FMaxY: Extended;
    FMinX: Extended;
    FMinY: Extended;
    FMaxX: Extended;
    FOnColor: TMandelbrotColorEvent;
    FShowAxis: Boolean;
    procedure SetMaxX(const Value: Extended);
    procedure SetMaxY(const Value: Extended);
    procedure SetMinX(const Value: Extended);
    procedure SetMinY(const Value: Extended);

    procedure UpdatePointsValues(AWidth, AHeight: Integer);
    procedure UpdateMatrixes(AWidth, AHeight: Integer);
    procedure SetShowAxis(const Value: Boolean);
  protected
    function CalcColor(X, Y: Extended): TColor;
    procedure ReCalcColors;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Loaded; override;
    
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure GetComplexValues(X, Y: Integer; out R, I: Extended);
  published
    property MinX: Extended read FMinX write SetMinX;
    {* X �����ֵ}
    property MinY: Extended read FMinY write SetMinY;
    {* Y ����Եֵ}
    property MaxX: Extended read FMaxX write SetMaxX;
    {* X �����ֵ}
    property MaxY: Extended read FMaxY write SetMaxY;
    {* Y ����Եֵ}

    property OnColor: TMandelbrotColorEvent read FOnColor write FOnColor;
    {* �Զ������²��޼����ص����ɫ�£����ޣ����ڲ�ʹ�úڰ�ɫ}
    property ShowAxis: Boolean read FShowAxis write SetShowAxis;
    {* �Ƿ����������}
    property OnClick;
    {* ����¼����}
  end;

implementation

{ TCnMandelbrotImage }

procedure CalcMandelbortSetPoint(X, Y: Extended; out XZ, YZ: Extended; out Count: Integer);
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

function TCnMandelbrotImage.CalcColor(X, Y: Extended): TColor;
var
  XZ, YZ: Extended;
  C: Integer;
begin
  XZ := 0.0;
  YZ := 0.0;
  C := 0;

  CalcMandelbortSetPoint(X, Y, XZ, YZ, C);

  if C > CN_MANDELBROT_MAX_COUNT then
  begin
    if Assigned(FOnColor) then
      Result := FOnColor(Self, X, Y, XZ, YZ, C)
    else
      Result := clNavy;
  end
  else
  begin
    if Assigned(FOnColor) then
      Result := FOnColor(Self, X, Y, XZ, YZ, C)
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
end;

destructor TCnMandelbrotImage.Destroy;
begin
  SetLength(FMaps, 0);
  SetLength(FXValues, 0);
  SetLength(FYValues, 0);
  inherited;
end;

procedure TCnMandelbrotImage.GetComplexValues(X, Y: Integer; out R,
  I: Extended);
begin
  if (X >= 0) and (X < Width) and (Y >= 0) and (Y < Height) then
  begin
    R := FXValues[X];
    I := FYValues[Y];
  end
  else
    raise Exception.Create('X Y Index Out of Bounds.');
end;

procedure TCnMandelbrotImage.Loaded;
begin
  inherited;
  UpdateMatrixes(Width, Height);
  ReCalcColors;
  ReCalcColors;
end;

procedure TCnMandelbrotImage.Paint;
var
  X, Y: Integer;
begin
  for X := 0 to Width - 1 do
    for Y := 0 to Height - 1 do
      Canvas.Pixels[X, Y] := FMaps[X, Y];

  if ShowAxis then
  begin
    // ��� X Y ���λ�ã�����
    X := Trunc(Width * (-FMinX) / (FMaxX - FMinX));
    Y := Trunc(Height * (FMaxY) / (FMaxY - FMinY));
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Style := psSolid;
    Canvas.MoveTo(X, 0);
    Canvas.LineTo(X, Height);
    Canvas.MoveTo(0, Y);
    Canvas.LineTo(Width, Y);
  end;
end;

procedure TCnMandelbrotImage.ReCalcColors;
var
  X, Y: Integer;
begin
  for X := 0 to Width - 1 do
    for Y := 0 to Height - 1 do
      FMaps[X, Y] := CalcColor(FXValues[X], FYValues[Y]);
  Invalidate;
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
      ReCalcColors;
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
      ReCalcColors;
    end;
  end;
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
begin
  SetLength(FXValues, AWidth);
  SetLength(FYValues, AHeight);
  SetLength(FMaps, AWidth, AHeight);

  UpdatePointsValues(AWidth, AHeight);
end;

procedure TCnMandelbrotImage.UpdatePointsValues(AWidth, AHeight: Integer);
var
  X, Y, W, H: Integer;
  WX, HY: Extended;
begin
  W := Width - 1;
  H := Height - 1;
  WX := (FMaxX - FMinX) / W;
  HY := (FMaxY - FMinY) / H;

  for X := 0 to W do
    FXValues[X] := FMinX + X * WX;

  for Y := 0 to H do
    FYValues[Y] := FMinY + (H - Y) * HY;

  for X := 0 to W do
    for Y := 0 to H do
      FMaps[X, Y] := clWhite;
end;

end.
