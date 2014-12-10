unit osservice;

interface

uses
   Graphics,windows ,classes,SysUtils,Math;

type
  TBlueException = class(Exception);
  WindowsOS = class
  private
    nPixelsPerInch:integer;
    hDesktopDC :THandle;
  public
    function DeleteFiles(FilePath, FileMask: String): Boolean;
    function InvalidateRect(hWnd: HWND; lpRect: PRect; bErase: BOOL): BOOL; 
    function RectEquals(r1, r2: TRect): Boolean;
    procedure InflateRect(var r: TRect; dx, dy: integer);
    function UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function Contains(Bigger, smaller: TRect):boolean;
    procedure SetRectEmpty(var r :TRect);
    function MM2Dot(a:integer):integer;
    function MapDots(FromHandle, ToHandle: THandle;FromLen: Integer): Integer;
    function Height2LogFontHeight(PointSize :Integer):Integer;
    function Height2LogFontHeight1(PointSize :Integer):Integer;
    function MakeLogFont(Name:String;size:integer):TLogFont;

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
function WindowsOS.Height2LogFontHeight(PointSize: Integer): Integer;
var h : HDC;
    Var
  hTempDC: HDC;
  pt, ptOrg: TPoint;
begin
    h := GetDC(0);
    try
      pt.y := GetDeviceCaps(h, LOGPIXELSY) * PointSize;
      pt.y := trunc(pt.y / 72 + 0.5);      // 72 points/inch, 10 decipoints/point
      DPtoLP(h, pt, 1);
      ptOrg.x := 0;
      ptOrg.y := 0;
      DPtoLP(h, ptOrg, 1);
      result := -abs(pt.y - ptOrg.y);
    finally
      ReleaseDC(0, h);
    end;
end;
function WindowsOS.Height2LogFontHeight1(PointSize: Integer): Integer;
//begin end;
var
  FLogFont: TLogFont;
  Font: TFont;
begin
    Font := TFont.Create;
    //    Font.Name := 'Arial';//或者 宋体 .都一样。
    Font.Size := 12;
    try
      GetObject(Font.Handle, sizeof(FLogFont), @FLogFont) ;
      result := FLogFont.lfHeight;
    finally
      Font.Free;
    end;
end;

function WindowsOS.MakeLogFont(Name: String; size: integer): TLogFont;
var
  FLogFont: TLogFont;
  Font: TFont;
begin
    Font := TFont.Create;
    Font.Name :=Name;//或者 宋体 .都一样。
    Font.Size := Size;
    try
      GetObject(Font.Handle, sizeof(FLogFont), @FLogFont) ;
      result := FLogFont;
    finally
      Font.Free;
    end;
    //The weight of the font in the range 0 through 1000.
    //For example, 400 is normal and 700 is bold.
    //If this value is zero, a default weight is used.
end;
function WindowsOS.RectEquals (r1,r2:TRect):Boolean;
begin
  result :=
      (r1.left = r2.left) and
      (r1.Right = r2.Right) and
      (r1.Top = r2.Top )and
      (r1.Bottom = r2.Bottom)
             ;
end;

procedure WindowsOS.InflateRect(var r: TRect; dx, dy: integer);
begin
  windows.inflateRect(r,dx,dy);
end;

function WindowsOS.InvalidateRect(hWnd: HWND; lpRect: PRect;
  bErase: BOOL): BOOL;
begin
  result := Windows.InvalidateRect(hwnd,lprect,berase);
end;
Function WindowsOS.DeleteFiles(FilePath, FileMask: String): Boolean;
Var
  Attributes: integer;
  DeleteFilesSearchRec: TSearchRec;
Begin
  Result := true;
  Try
    FindFirst(FilePath + '\' + FileMask, faAnyFile, DeleteFilesSearchRec);

    If Not (DeleteFilesSearchRec.Name = '') Then
    Begin
      Result := True;
      {$WARNINGS OFF}
      Attributes := FileGetAttr(FilePath + '\' + DeleteFilesSearchRec.Name);
      FileSetAttr(FilePath + '\' + DeleteFilesSearchRec.Name, Attributes);
      {$WARNINGS ON}
      DeleteFile(FilePath + '\' + DeleteFilesSearchRec.Name);

      While FindNext(DeleteFilesSearchRec) = 0 Do
      Begin
        {$WARNINGS OFF}
        Attributes := FileGetAttr(FilePath + '\' + DeleteFilesSearchRec.Name);
        FileSetAttr(FilePath + '\' + DeleteFilesSearchRec.Name, Attributes);
        {$WARNINGS ON}
        DeleteFile(FilePath + '\' + DeleteFilesSearchRec.Name);
      End;
    End;                              
    FindClose(DeleteFilesSearchRec);
  Except
    Result := false;
    Exit;
  End;
End;
end.
