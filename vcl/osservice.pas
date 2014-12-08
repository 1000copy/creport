unit osservice;

interface

uses
   windows ,classes,SysUtils,Math;

type
  EachCellProc =  procedure (ThisCell:TReportCell) of object;
  EachLineProc =  procedure (ThisLine:TReportLine)of object;
  EachLineIndexProc = procedure (ThisLine:TReportLine;Index:Integer)of object;
  TBlueException = class(Exception);
  WindowsOS = class
  private
    nPixelsPerInch:integer;
    hDesktopDC :THandle;
  public
    function UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function Contains(Bigger, smaller: TRect):boolean;
    procedure SetRectEmpty(var r :TRect);
    function MM2Dot(a:integer):integer;
    function MapDots(FromHandle, ToHandle: THandle;FromLen: Integer): Integer;
    constructor Create;
    destructor Destroy;
  end;
  procedure CheckError(condition:Boolean ;msg :string);
implementation

{ WindowsOS }

function WindowsOS.UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
var
   r: TRect;
begin
  if not windows.UnionRect(Result,lprcSrc1,lprcSrc2)  then
    SetRectEmpty(result);

end;

function WindowsOS.IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
var
   r: TRect;
begin
  if not windows.IntersectRect(Result,lprcSrc1,lprcSrc2)  then
    SetRectEmpty(result);

end;

function WindowsOS.Contains(Bigger, smaller: TRect): boolean;
var
  r :trect ;
begin
  r := self.IntersectRect(Bigger,smaller);
  Result := windows.EqualRect(r,smaller) ;
end;
procedure CheckError(condition:Boolean ;msg :string);
begin
  if not condition then
    raise TBlueException.Create(msg);
end;

procedure WindowsOS.SetRectEmpty(var r: TRect);
begin
  windows.SetRectEmpty(r);
end;

function WindowsOS.MM2Dot(a: integer): integer;
begin
  Result := Trunc(nPixelsPerInch * a/ 25 + 0.5);   // LCJ: or 25 -> 25.4?
end;

constructor WindowsOS.Create;

begin
  hDesktopDC := GetDC(0);
  nPixelsPerInch := GetDeviceCaps(hDesktopDC, LOGPIXELSX);
end;

destructor WindowsOS.Destroy;
begin
    ReleaseDC(0, hDesktopDC);
end;
function WindowsOS.MapDots(FromHandle:THandle;ToHandle:THandle;FromLen:Integer):Integer;
begin
  result := trunc(FromLen / GetDeviceCaps(FromHandle,LOGPIXELSX)
      * GetDeviceCaps(ToHandle, LOGPIXELSX) + 0.5);
end;
end.
