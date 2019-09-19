unit osservice;

interface

uses
   Graphics,windows ,classes,SysUtils,Math,Forms,cc,messages,printers;
  function inflate(Rect:TRect;i:integer):TRect;
  procedure mapDevice(Width, Height:Integer);
function SysPrinter:TPrinter;
  procedure msgok(a,b:PChar);
const A4 = Windows.DMPAPER_A4;
const A3 = Windows.DMPAPER_A3;
const A5 = Windows.DMPAPER_A5;
const PORTRAIT =  Windows.DMORIENT_PORTRAIT; // 纵向
const LANDSCAPE =  Windows.DMORIENT_LANDSCAPE;       // 横向
function  PageFileName(CurrentPage:Integer):string;
function AppDir:String;
type
  TPrinterPaper = class
  private
    // google : msdn DEVMODE structure
    //DevMode: PdeviceMode;
    //LCJ: 打印文件的纸张编号：比如 A4，A3，自定义纸张等。
    FPageSize: integer; //osservice.A4 A5 A3 etc.
    // 纸张纵横方向
    FPageOrientation: integer;
    // 纸张长度（高度）
    fpaperLength: integer;
    fpaperWidth: integer;
  private
    //取得当前打印机的DeviceMode的结构成员
  public
    procedure SetPaperWithCurrent;
    procedure Batch;overload;
    procedure SetPaper(PageSize, PageOrientation, PaperLength,
      PaperWidth: Integer);
    procedure GetPaper(var FPageSize, FPageOrientation, fpaperLength,
      fpaperWidth: Integer);
  end;
  StrSlice=class
    FStr :string;
  public
    constructor Create(str:String);
    function GoUntil(c:char):integer;
    function Slice(b,e:integer):string;overload;
    function Slice(b:integer):string;overload;
    class function DoSlice(str: String; FromChar:char): string;
  end;

  Canvas = class
    handle:HWND;
    dc : HDC ;
    hPrevPen, hTempPen: HPEN;
    PrevDrawMode: Integer;
  private
  public
    constructor Create(dc : HDC);
    procedure Rectangle(x1, y1, x2, y2: integer);
    procedure SetViewportExtent(x, y: integer);
    procedure SetWindowExtent(x, y: integer);
    procedure LineTo(x, y: Integer);
    procedure MoveTo(x, y: Integer);
    procedure ReleaseDC;
    procedure KillDrawMode;
    procedure ReadyDrawModeInvert;
    procedure ReadyDefaultPen;
    procedure KillPen();
    procedure DrawLine(p1, p2: TPoint);
    procedure ReadySolidPen(Width: Integer; Color: ColorREF);
    procedure ReadyDotPen(Width: Integer; Color: ColorREF);
    constructor CreateWnd(handle: HWND);
    procedure SetMapMode();

  end;
  Rect = class
    FRect:TRect;
  public
    function BottomMid: TPoint;
    function LeftBottom: TPoint;
    function LeftMid: TPoint;
    function RightTop: TPoint;
    function TopLeft:TPoint;
    function BottomRight:TPoint;
    function RightMid: TPoint;
    constructor Create(R:TRect);
  end;
type
  TBlueException = class(Exception);
  WindowsOS = class
  private
    nPixelsPerInch:integer;
    hDesktopDC :THandle;
    function geta4: Integer;
  public
    FEditBrush: HBRUSH;

    function CreateEdit(Handle:HWND;Rect:TRect; FEditFont: HFONT;Text:String;FHorzAlign:Integer):HWND;
    //CreateEdit(ThisCell.TextRect,FEditFont,ThisCell.CellText);
    procedure SetCursorSizeBEAM;
    procedure SetCursorSizeNS;
    procedure  SetCursorSizeWE;
    procedure  SetCursorArrow;
    procedure ScaleRect(var rectPaint: TRect; FReportScale: Integer);
    procedure InverseScaleRect(var rectPaint: TRect;
      FReportScale: Integer);
    function HAlign2DT(FHorzAlign: UINT): UINT;
    function IsRectEmpty(r: TRect): boolean;
    function MakeRect(FMousePoint, TempPoint: TPoint): TRect;
    function DeleteFiles(FilePath, FileMask: String): Boolean;
    function InvalidateRect1(hWnd: HWND; lpRect: TRect; bErase: BOOL): BOOL;
    function RectEquals(r1, r2: TRect): Boolean;
    procedure InflateRect(var r: TRect; dx, dy: integer);
    function Inflate(r: TRect; dx, dy: integer):TRect;
    function UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
    class function IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
    function IsIntersect(r1, r2: TRect): boolean;
    class function Contains(Bigger, smaller: TRect):boolean;
    procedure SetRectEmpty(var r :TRect);
    function MM2Dot(a:integer):integer;
    function MapDots(FromHandle, ToHandle: THandle;FromLen: Integer): Integer;
    function Height2LogFontHeight(PointSize :Integer):Integer;
    function Height2LogFontHeight1(PointSize :Integer):Integer;
    function MakeLogFont(Name:String;size:integer):TLogFont;
    procedure SetViewportExtent(hPaintDC:HDC;x,y:integer);
    procedure SetWindowExtent(hPaintDC:HDC;x,y:integer);
    constructor Create;
    destructor Destroy;override;
    property DMPAPER_A4 :Integer read geta4;
  end;
    Edit = class
    os : WindowsOS;
    FEditWnd: HWND;
    FEditBrush: HBRUSH;
    FEditFont: HFONT;
  private
  public
    function CreateEdit(Handle: HWND; Rect: TRect;LogFont: TLOGFONT;
      Text: String; FHorzAlign: Integer): HWND;
    function GetText: String;
    procedure MoveRect(TextRect: TRect);
    procedure DestroyIfVisible;
    function IsWindowVisible: Boolean;
    procedure DestroyWindow;
    function CreateBrush(color: Cardinal): HBRUSH;
    constructor Create();
    destructor destroy;override;
  end;
  procedure CheckError(condition:Boolean ;msg :string);
implementation

{ WindowsOS }

function WindowsOS.UnionRect(lprcSrc1, lprcSrc2: TRect): TRect;
begin
  if not windows.UnionRect(Result,lprcSrc1,lprcSrc2)  then
    SetRectEmpty(result);

end;

class function WindowsOS.IntersectRect(lprcSrc1, lprcSrc2: TRect): TRect;
begin
  if not windows.IntersectRect(Result,lprcSrc1,lprcSrc2)  then
    windows.SetRectEmpty(result);

end;

class function WindowsOS.Contains(Bigger, smaller: TRect): boolean;
var
  r :trect ;
begin
  r := IntersectRect(Bigger,smaller);
  Result := windows.EqualRect(r,smaller) ;
end;
procedure CheckError(condition:Boolean ;msg :string);
begin
  if condition then
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
    inherited ;
end;
function WindowsOS.geta4: Integer;
begin
  result := windows.DMPAPER_A4;
end;

function WindowsOS.MapDots(FromHandle:THandle;ToHandle:THandle;FromLen:Integer):Integer;
begin
  result := trunc(FromLen / GetDeviceCaps(FromHandle,LOGPIXELSX)
      * GetDeviceCaps(ToHandle, LOGPIXELSX) + 0.5);
end;
function WindowsOS.Height2LogFontHeight(PointSize: Integer): Integer;
var h : HDC;
    Var
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
function WindowsOS.Inflate(r: TRect; dx, dy: integer):TRect;
begin
  windows.inflateRect(r,dx,dy);
  result := r;
end;

function WindowsOS.InvalidateRect1(hWnd: HWND; lpRect: TRect;
  bErase: BOOL): BOOL;
begin
  result := Windows.InvalidateRect(hwnd,@lprect,berase);
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
function WindowsOS.MakeRect(FMousePoint,TempPoint:TPoint):TRect;
Var
  RectSelection: TRect;
begin
    If FMousePoint.x > TempPoint.x Then
    Begin
      RectSelection.Left := TempPoint.x;
      RectSelection.Right := FMousePoint.x;
    End
    Else
    Begin
      RectSelection.Left := FMousePoint.x;
      RectSelection.Right := TempPoint.x;
    End;

    If FMousePoint.y > TempPoint.y Then
    Begin
      RectSelection.Top := TempPoint.y;
      RectSelection.Bottom := FMousePoint.y;
    End
    Else
    Begin
      RectSelection.Top := FMousePoint.y;
      RectSelection.Bottom := TempPoint.y;
    End;

    If RectSelection.Right = RectSelection.Left Then
      RectSelection.Right := RectSelection.Right + 1;

    If RectSelection.Bottom = RectSelection.Top Then
      RectSelection.Bottom := RectSelection.Bottom + 1;
    Result := RectSelection;
end;
function WindowsOS.IsIntersect(r1, r2: TRect): boolean;
begin
  result := not IsRectEmpty(IntersectRect(r1,r2));  
end;

function WindowsOS.IsRectEmpty(r: TRect): boolean;
begin
  {The IsRectEmpty function determines whether the specified rectangle is empty.
   An empty rectangle is one that has no area; that is, the coordinate of the \
   right side is less than or equal to the coordinate of the left side,
    or the coordinate of the bottom side is less than or equal to the coordinate
     of the top side.
    }
  result := windows.IsRectEmpty(r);
end;

function WindowsOS.HAlign2DT(FHorzAlign:UINT):UINT;
var dt : Integer ;
begin
  Case FHorzAlign Of
    0:dt := DT_LEFT;
    1:dt := DT_CENTER;
    2:dt := DT_RIGHT;
    Else dt := DT_LEFT;
  End;
  Result := dt;
end;

procedure WindowsOS.SetViewportExtent(hPaintDC: HDC; x, y: integer);
begin
  {$Warn ZERO_NIL_COMPAT OFF}
  SetViewportExtEx(hPaintDC,x,y,0);

end;

procedure WindowsOS.SetWindowExtent(hPaintDC: HDC; x, y: integer);
begin
  {$Warn ZERO_NIL_COMPAT OFF}
  SetWindowExtEx(hPaintDC,x ,y,0);

end;
procedure WindowsOS.ScaleRect(var rectPaint :TRect ; FReportScale:Integer);
begin
  If FReportScale <> 100 Then
  Begin
    rectPaint.Left := trunc(rectPaint.Left * FReportScale /100  + 0.5);
    rectPaint.Top := trunc(rectPaint.Top * FReportScale /100 + 0.5);
    rectPaint.Right := trunc(rectPaint.Right * FReportScale /100 + 0.5);
    rectPaint.Bottom := trunc(rectPaint.Bottom * FReportScale /100 + 0.5);
  End;
end;
procedure WindowsOS.InverseScaleRect(var rectPaint :TRect ; FReportScale:Integer);
begin
  If FReportScale <> 100 Then
  Begin
    rectPaint.Left := trunc(rectPaint.Left * 100 / FReportScale + 0.5);
    rectPaint.Top := trunc(rectPaint.Top * 100 / FReportScale + 0.5);
    rectPaint.Right := trunc(rectPaint.Right * 100 / FReportScale + 0.5);
    rectPaint.Bottom := trunc(rectPaint.Bottom * 100 / FReportScale + 0.5);
  End;
end;

function  PageFileName(CurrentPage:Integer):string;
begin
 Result := Format('%s\Temp\%d.tmp',[ AppDir,CurrentPage]) ;
end;
function AppDir:String;
begin
   result := ExtractFileDir(Application.ExeName)+'\' ;
end;
procedure WindowsOS.SetCursorSizeNS;
begin
  SetCursor(LoadCursor(0, IDC_SIZENS));
end;

procedure WindowsOS.SetCursorArrow;
begin
  SetCursor(LoadCursor(0, IDC_ARROW));
end;

procedure WindowsOS.SetCursorSizeBEAM;
begin
  SetCursor(LoadCursor(0, IDC_IBEAM));
end;

procedure WindowsOS.SetCursorSizeWE;
begin
  SetCursor(LoadCursor(0, IDC_SIZEWE))
end;




function WindowsOS.CreateEdit(Handle:HWND;Rect: TRect; FEditFont: HFONT;
  Text: String;FHorzAlign:Integer): HWND;
var
  dwStyle: DWORD;
  FEditWnd: HWND;
begin
  dwStyle :=
      WS_VISIBLE Or
      WS_CHILD Or
      ES_MULTILINE or
      ES_AUTOVSCROLL or
      HAlign2DT(FHorzAlign);
  FEditWnd := CreateWindow('EDIT', '', dwStyle, 0, 0, 0, 0, Handle, 1,
    hInstance, Nil);  
  SendMessage(FEditWnd, WM_SETFONT, FEditFont, 1); // 1 means TRUE here.
  SendMessage(FEditWnd, EM_LIMITTEXT, 3000, 0);
  MoveWindow(FEditWnd, Rect.left, Rect.Top,
    Rect.Right - Rect.Left,
    Rect.Bottom - Rect.Top, True);
  SetWindowText(FEditWnd, PChar(Text));
  ShowWindow(FEditWnd, SW_SHOWNORMAL);
  Windows.SetFocus(FEditWnd);
  result := FEditWnd ;
end;

{ Rect }


function Rect.BottomRight: TPoint;
begin
  result.X := FRect.Right;
  result.y := FRect.Bottom ;

end;

constructor Rect.Create(R: TRect);
begin
  self.FRect := r;
end;



function Rect.TopLeft: TPoint;
begin
  result.X := FRect.Left;
  result.y := FRect.Top ;

end;
function Rect.RightMid: TPoint;
begin
  result.X := FRect.Right;
  result.y := trunc((FRect.bottom + FRect.top) / 2 + 0.5) ;
end;

function Rect.BottomMid: TPoint;
begin
  result.X := trunc((FRect.right + FRect.left) / 2 + 0.5);
  result.y := FRect.Bottom;
end;

function Rect.LeftMid: TPoint;
begin
  result.X := FRect.Left;
  result.y := trunc((FRect.bottom + FRect.top) / 2 + 0.5)
end;
function Rect.RightTop: TPoint;
begin
  result.X := FRect.Right;
  result.y := FRect.Top;
end;

function Rect.LeftBottom: TPoint;
begin
  result.X := FRect.Left;
  result.y := FRect.Bottom;
end;
{ Canvas }

constructor Canvas.Create(dc: HDC);
begin
  self.dc := dc;
end;
constructor Canvas.CreateWnd(Handle: HWND);
begin
  self.Handle := Handle;
  self.dc := GetDC(Handle);
end;
procedure Canvas.ReleaseDC;
begin
  windows.ReleaseDC(Handle, dc);
end;
procedure Canvas.MoveTo(x,y:Integer);
begin
  MoveToEx(dc, x,y, Nil);
end;
procedure Canvas.LineTo(x,y:Integer);
begin
  Windows.LineTo(dc, x,y);
end;



procedure Canvas.KillPen;
begin
  SelectObject(dc, hPrevPen);
  DeleteObject(hTempPen);
end;

procedure Canvas.KillDrawMode;
begin
    SetROP2(dc, PrevDrawMode);
end;
procedure Canvas.ReadySolidPen(Width:Integer;Color:ColorREF);
begin
  hTempPen := CreatePen(PS_SOLID, width, Color);
  hPrevPen := SelectObject(dc, hTempPen);
end;
procedure Canvas.ReadyDefaultPen();
begin
  ReadySolidPen (1, cc.Black);
end;

procedure Canvas.DrawLine(p1,p2:TPoint);
begin
  MoveToEx(dc,p1.x, p1.y, Nil);
  Windows.LineTo(dc, p2.x, p2.y);
end;


procedure Canvas.ReadyDotPen(Width: Integer; Color: ColorREF);
begin
  hTempPen := CreatePen(PS_DOT, 1, cc.Black);
  hPrevPen := SelectObject(dc, hTempPen);

end;
procedure Canvas.ReadyDrawModeInvert();
begin
  PrevDrawMode := SetROP2(dc, R2_NOTXORPEN);
end;

procedure Canvas.SetMapMode;
begin
  windows.SetMapMode(dc, MM_ISOTROPIC);
end;

procedure Canvas.SetViewportExtent(x, y: integer);
begin
  windows.SetViewportExtEx(dc,x,y,0);
end;

procedure Canvas.SetWindowExtent( x, y: integer);
begin
  Windows.SetWindowExtEx(dc,x ,y,0);

end;
procedure Canvas.Rectangle(x1,y1,x2,y2:integer);
begin
  windows.Rectangle(dc,x1,y1,x2,y2);
end;
procedure mapDevice(Width, Height:Integer);
  var PageSize: TSize;
begin
  SetMapMode(SysPrinter.Handle, MM_ISOTROPIC);
  PageSize.cx := SysPrinter.PageWidth;
  PageSize.cy := SysPrinter.PageHeight;
  SetWindowExtEx(SysPrinter.Handle, Width, Height, @PageSize);
  SetViewPortExtEx(SysPrinter.Handle, SysPrinter.PageWidth, SysPrinter.PageHeight,
    @PageSize);
end;
  function inflate(Rect:TRect;i:integer):TRect;
  begin
        result.Left := Rect.Left + i;
        result.Top := Rect.Top + i;
        result.Right := Rect.Right - i;
        result.Bottom := Rect.Bottom - i;
  end;
procedure msgok(a,b:PChar);begin
  Application.Messagebox(a,b, MB_OK + MB_iconwarning);
end;
function SysPrinter:TPrinter;begin
  result := Printers.Printer;
end;
{ Edit }

constructor Edit.Create();
begin
  os := WindowsOS.Create;
  FEditWnd := INVALID_HANDLE_VALUE;
  FEditBrush := INVALID_HANDLE_VALUE;
  FEditFont := INVALID_HANDLE_VALUE;
end;
function Edit.CreateEdit(Handle:HWND;Rect: TRect; LogFont: TLOGFONT;Text: String;FHorzAlign:Integer): HWND;
var
  dwStyle: DWORD;
begin
  If FEditFont <> INVALID_HANDLE_VALUE Then
    DeleteObject(FEditFont);
  FEditFont := CreateFontIndirect(LogFont);
  dwStyle :=
      WS_VISIBLE Or
      WS_CHILD Or
      ES_MULTILINE or
      ES_AUTOVSCROLL or
      os.HAlign2DT(FHorzAlign);
  FEditWnd := CreateWindow('EDIT', '', dwStyle, 0, 0, 0, 0, Handle, 1,
    hInstance, Nil);
  SendMessage(FEditWnd, WM_SETFONT, FEditFont, 1); // 1 means TRUE here.
  SendMessage(FEditWnd, EM_LIMITTEXT, 3000, 0);
  MoveWindow(FEditWnd, Rect.left, Rect.Top,
    Rect.Right - Rect.Left,
    Rect.Bottom - Rect.Top, True);
  SetWindowText(FEditWnd, PChar(Text));
  ShowWindow(FEditWnd, SW_SHOWNORMAL);
  Windows.SetFocus(FEditWnd);
  result := FEditWnd ;
end;
destructor Edit.destroy;
begin
  os.free;
  inherited;
end;

function Edit.GetText(): String;
var
  TempChar: Array[0..3000] Of Char;
begin
  GetWindowText(FEditWnd, TempChar, 3000);
  Result := TempChar;
end;

procedure Edit.MoveRect(TextRect:TRect);
begin
  MoveWindow(FEditWnd, TextRect.left, TextRect.Top,
    TextRect.Right - TextRect.Left,
    TextRect.Bottom - TextRect.Top, True);
end;
procedure Edit.DestroyIfVisible();
begin
  If IsWindowVisible() Then
    DestroyWindow();
end;

function Edit.IsWindowVisible():Boolean;
begin
  result := windows.IsWindowVisible(FEditWnd) ;
end;
procedure Edit.DestroyWindow();
begin
  windows.DestroyWindow(FEditWnd);
end;
function Edit.CreateBrush(Color:Cardinal):HBRUSH;
var
  TempLogBrush: TLOGBRUSH;
begin
    If FEditBrush <> INVALID_HANDLE_VALUE Then
      DeleteObject(FEditBrush);
    TempLogBrush.lbStyle := PS_SOLID;
    TempLogBrush.lbColor := Color;
    FEditBrush := CreateBrushIndirect(TempLogBrush);
    Result := FEditBrush;
end;
constructor StrSlice.Create(str: String);
begin
  FStr := str;
end;
function StrSlice.GoUntil(c: char): integer;
var i : integer;
begin
  i := 2;
  while  (i < Length(FStr)) and  ( FStr[I] <> c ) do
    inc(i);
  result := i ;
end;

function StrSlice.Slice(b, e: integer): string;
var i : integer;
begin
   result := '';
   i := b ;
   while i <=e do begin
    result := result + FStr[i];
    inc(i);
   end;
end;

function StrSlice.Slice(b: integer): string;
begin
  result := Slice(b,Length(FStr));
end;

class function StrSlice.DoSlice(str: String; FromChar:char): string;
var   s:StrSlice;
begin
    s:=StrSlice.Create(str);
    Result := s.Slice(s.GoUntil(FromChar)+1);
    s.Free ;
end;

procedure TPrinterPaper.SetPaperWithCurrent;
begin
  // LCJ : 我说好好的A4，干嘛总是进入信纸状态呢:)
  if  FPageSize = 0 then begin
    exit;
  end;
  SetPaper(FPageSize,FPageOrientation,fpaperLength,fpaperWidth);
end;
//http://delphi-kb.blogspot.com/2009/04/how-to-set-printer-paper-size.html
procedure TPrinterPaper.SetPaper(PageSize,PageOrientation,PaperLength,PaperWidth:Integer);
var
  Device, Driver, Port: array[0..80] of Char;
  DevMode: THandle;
  pDevmode: PDeviceMode;
begin
  SysPrinter.GetPrinter(Device, Driver, Port, DevMode);
  {force reload of DEVMODE}
  SysPrinter.SetPrinter(Device, Driver, Port, 0);
  SysPrinter.GetPrinter(Device, Driver, Port, DevMode);
  if Devmode <> 0 then
  begin
    {lock it to get pointer to DEVMODE record}
    pDevMode := GlobalLock(Devmode);
    if pDevmode <> nil then
    try
      with pDevmode^ do
      begin
        {tell printer driver that dmPapersize field contains data it needs to inspect}
        dmFields := dmFields or DM_PAPERSIZE;
            dmFields:=dmFields or DM_ORIENTATION;
        {modify paper size}
        dmPapersize := PageSize;
        //dmPapersize := DMPAPER_B5;
        dmOrientation:=PageOrientation;
        dmPaperLength:=PaperLength;
        dmPaperWidth:=PaperWidth;
      end;
    finally
      GlobalUnlock(Devmode);
    end;
  end;
end;
procedure TPrinterPaper.GetPaper(var FPageSize,FPageOrientation,fpaperLength,fpaperWidth:Integer);
var
  Device, Driver, Port: array[0..80] of Char;
  DevMode: THandle;
  pDevmode: PDeviceMode;
begin
  SysPrinter.GetPrinter(Device, Driver, Port, DevMode);
  SysPrinter.SetPrinter(Device, Driver, Port, 0);
  SysPrinter.GetPrinter(Device, Driver, Port, DevMode);
  if Devmode =  0 then exit;
  try
  pDevMode := GlobalLock(Devmode);
  With pDevmode^ Do
  Begin
    dmFields := dmFields Or DM_PAPERSIZE;
    FPageSize := dmPapersize;
    dmFields := dmFields Or DM_ORIENTATION;
    FPageOrientation := dmOrientation;
    fPaperLength := dmPaperLength;
    fPaperWidth := dmPaperWidth;
  End;
  finally
      GlobalUnlock(Devmode);
  end;
end;
procedure TPrinterPaper.Batch;
begin
    SetPaperWithCurrent;
end;


end.
