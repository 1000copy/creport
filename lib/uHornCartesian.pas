unit uHornCartesian;

interface
uses
  // user
  osservice,
  // sys
  messages,
  Classes,
   Math,DBClient,  db,  DBTables,  Graphics,  forms,  Windows,  SysUtils,  Printers;

type
   Oriention = (orLeftTop=1,orRightTop,orLeftBottom,orRightBottom);
   Cartesian = class
   private
    os : WindowsOS ;
    saved,HornX,HornY :integer;
    hPaintDC: HDC;
    FOrigin: TPoint;
    FOriention: Oriention;
    FRatio: integer;
    procedure SetOrigin(const Value: TPoint);
    procedure SetOriention(const Value: Oriention);
    procedure SetRatio(const Value: integer);
   protected
     procedure OnDraw;virtual;abstract;
   public
    constructor Create(hPaintDC: HDC);
    destructor Destroy ;override;
    property Origin :TPoint  read FOrigin write SetOrigin;
    // 100 = 1倍放大。 200 为2倍放大。
    property Ratio :integer  read FRatio write SetRatio;
    property Oriention : Oriention  read FOriention write SetOriention;
    procedure Save ;
    procedure Go ;
    procedure Restore ;
   end;
   HornCartesian = class (Cartesian)
   public
     procedure OnDraw;override;
   end;
implementation
{ Cartesian }

procedure Cartesian.Restore;
begin
  restoreDC(hPaintDC,saved);
end;

constructor Cartesian.Create(hPaintDC: HDC);
begin
  self.hPaintDc := hPaintDc ;
  self.FRatio := 100;
  os := WindowsOS.Create ;
end;

procedure Cartesian.Go;
var signx,signy : integer;
VAR
  saved,HornLength ,HornX,HornY ,BigFace,BigBase:integer;
begin
  SetMapMode(hPaintDC,MM_ISOTROPIC);
  SetViewportOrgEx(hPaintDC,Origin.X,Origin.Y,0);
  // 大小不重要，关键是ViewPointExtent和WindowsExtent的比例 ！
  case Oriention of
  orLeftTop : // Left Top
    begin signx := -1;signy:=-1;  end;
  orRightTop : // Right Top
    begin signx :=  1;signy:=-1;  end;
  orLeftBottom :  // Left bottom
    begin signx := -1;signy:=1;  end;
  orRightBottom : // right bottom
    begin signx := 1;signy:= 1;  end;
  end;
  BigFace:=1000 ;
  // 这辈子，也用上了一回 MulDiv 这么高大上的函数。
  BigBase :=MulDiv(BigFace,FRatio,100);
  //SetViewportExtEx(hPaintDC,trunc(BigFace*F),trunc(BigFace*F),0);
//  SetViewportExtEx(hPaintDC,BigBase,BigBase,0);
  os.SetViewportExtent(hPaintDC,BigBase,BigBase);
//  SetWindowExtEx(hPaintDC,BigFace*signx ,BigFace*signy,0);
  os.SetWindowExtent(hPaintDC,BigFace*signx,BigFace*signy);
  OnDraw;
end;

procedure Cartesian.Save;
begin
    saved := saveDC(hPaintDC);
end;

procedure Cartesian.SetOrigin(const Value: TPoint);
begin
  FOrigin := Value;
end;

procedure Cartesian.SetOriention(const Value: Oriention);
begin
  FOriention := Value;
end;

{ HornCaresian }

procedure HornCartesian.OnDraw;
VAR
  saved,HornLength ,HornX,HornY :integer;
begin
  HornLength := 50 ;
  MoveToEx(hPaintDC, 0, 0, Nil);
  LineTo(hPaintDC, 0, HornLength);
  MoveToEx(hPaintDC, 0, 0, Nil);
  LineTo(hPaintDC, HornLength, 0);
end;

procedure Cartesian.SetRatio(const Value: integer);
begin
  FRatio := Value;
end;

destructor Cartesian.Destroy;
begin
  os.free;
  inherited;
end;

end.
