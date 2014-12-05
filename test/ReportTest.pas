
unit ReportTest;

interface

uses
  // user
  osservice,
  ReportControl,
  ReportRunTime,creport,
  // sys
   Math,DBClient,  db,  DBTables,  Graphics,  forms,  Windows,  SysUtils,  TestFramework,Printers;

type
  TCDSTest =  class(TTestCase)
    procedure ReproducedEAccessViolation;
  published
    procedure SolutedMissingDataProvider1;
    procedure ReproducedMissingDataProvider;
  end;
  TReportTest = class(TTestCase)
  private
    R: TReportRunTime;
    Filename : string;
    fTestCount: integer;

    procedure DoChanged (Sender:TObject;str:String) ;

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CombineVertical;
    procedure CombineHorz;
    procedure Owner;
    procedure Rect;
    procedure dynamicReport;
    procedure PrinterPagerWidth;
    procedure PrinterCaps;
    procedure OwnerCellRequiredHeight;
    procedure OwnerCellRequiredHeightIncrement;
    procedure GetTextHeight;
    procedure TextHeightCRCompensate;
    procedure CalcTextHeight;
    procedure LogFont;
    procedure TFont1;
    procedure Inc_vs_Add;
    procedure CalcText_Cell_Rect;
    procedure Trunc_vs_ceil;
    procedure TextLine_vs_RequiredHeight;
    procedure DirectLoad;
    procedure TopAlign;
    procedure LoadSave_now_it_is_shift_to_you ;
  end;

  TReportUITest = class(TTestCase)
  private
    fTestCount: integer;
    procedure TestCheck;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCombineVertical;
  end;

implementation
// why TClientDataset.Fields.add can't work?
// and how to pupolate TClientDataset
// http://www.informit.com/articles/article.aspx?p=24094&seqNum=5
procedure TCDSTest.ReproducedEAccessViolation;
var
    t1 ,t2: TClientDataset;
    F : TStringField;
begin
    t1 := TClientDataset.Create(nil);
    F := TStringField.Create(t1);
    F.FieldName := 'zname';
    t1.Fields.Add(F);
    t1.CreateDataSet;
    t1.open;
    t1.Append;
    StartExpectingException(EAccessViolation);
    // here EAccessViolation happened!
    t1.FieldByName('zname').AsString := '1';
    StopExpectingException();
    t1.Post;
    t1.free;
end;

procedure TReportTest.dynamicReport;
var j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
    R:TReportRunTime;
    t1 ,t2: TClientDataset;
    F : TStringField;
begin
  try
      R:=TReportRunTime.Create(Application.MainForm);
      R.Visible := False;
      R.ClearDataSet;
      t1 := TClientDataset.Create(nil);
      t1.FieldDefs.Add('f1',ftString,20,true);
      t1.FieldDefs.Add('f2',ftString,20,true);
      t2 := TClientDataset.Create(nil);
      t2.FieldDefs.Add('f1',ftString,20,true);

      t1.CreateDataSet;
      t2.CreateDataSet;
      R.SetDataSet('t1',t1);
      R.SetDataSet('t2',t2);
      t1.Open;
      t2.Open;
      t1.AppendRecord([1,2]);
      t1.AppendRecord([1,2]);
      t1.AppendRecord([1,2]);
      t1.AppendRecord([1,2]);
      t1.AppendRecord([1,2]);
      t1.AppendRecord([1,2]);
      t2.Append;
      t2.FieldByName('f1').asstring:= '2' ;
      t2.Post;
      strFileDir := ExtractFileDir(Application.ExeName);
      with  R do
      begin
        SetWndSize(1058,748); 
        NewTable(6 ,3);
        Lines[0].Select;
        CombineCell;
        Lines[0].LineHeight := 80;
        SetCellLines(false,false,false,false,1,1,1,1);
        Cells[0,0].CellText := 'bill';
        SetCellAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_VCENTER);

        cf := Tfont.Create;
        cf.Name := '楷体_GB2312';
        cf.Size := 22;
        cf.style :=cf.style+ [fsBold];
        SetSelectedCellFont(cf);
        for j:=0 to t1.FieldDefs.Count -1  do
        begin
           Cells[1,j].CellText := t1.FieldDefs[j].Name;
           Cells[2,j].CellText := '#T1.'+t1.FieldDefs[j].Name;
        end;
        SaveToFile(strFileDir+'\'+'xxx.ept');
        ResetContent;
        cf.Free;
      end;
      R.ReportFile:=strFileDir+'\'+'xxx.ept';
      R.PrintPreview(true);
    finally
      T1.free;
      T2.Free;
    end;
end;
procedure TReportTest.Rect;
var
   w : WindowsOS;
   r1,r2,r3 :TRect;
begin
    w := WindowsOS.Create ;
    r1.Left := 0 ;
    r1.Right := 1;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    r3 := w.UnionRect(r1,r2);

    r1.Left := 0 ;
    r1.Right := 4;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    r3 := w.IntersectRect(r1,r2);

    r1.Left := 0 ;
    r1.Right := 1;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    r3 := w.IntersectRect(r1,r2);
    r1.Left := 0 ;
    r1.Right := 1;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    w.contains(r1,r2);

    r1.Left := 0 ;
    r1.Right := 4;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;
    w.contains(r1,r2);
end;




procedure TReportTest.CombineHorz;
var Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(2 ,2);
    // 水平合并后，Cell确实减少
    r.ClearSelect ;
    r.Cells[0,0].Select;
    r.Cells[0,1].Select;
    r.CombineCell;
    assert(R.Lines[0].FCells.count = 1);
    r.SaveToFile(Filename);
    r.ResetContent;
    R.EditReport(FileName);
end;
procedure TReportTest.CombineVertical;
var Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,2);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.CombineCell ;
      Check(R.Lines[0].FCells.count = 2);
      Check(R.Lines[1].FCells.count = 2);
      Check(R.Cells[0,0].OwnerCell = nil);
      Check(R.Cells[1,0].OwnerCell = R.Cells[0,0]);
      Check(R.Cells[0,0].FSlaveCells.Count = 1);
      Check(R.Cells[0,0].FSlaveCells[0]  = R.Cells[1,0]);   
    finally
      R.Free;
    end;
end;
{ TReportUITest }

procedure TReportUITest.SetUp;
begin
  inherited;

end;

procedure TReportUITest.TearDown;
begin
  inherited;

end;

procedure TReportUITest.TestCheck;
begin

end;

procedure TReportUITest.TestCombineVertical;
var Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,2);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.CombineCell ;
      Check(R.Lines[0].FCells.count = 2);
      Check(R.Lines[1].FCells.count = 2);
      Check(R.Cells[0,0].OwnerCell = nil);
      Check(R.Cells[1,0].OwnerCell = R.Cells[0,0]);
      Check(R.Cells[0,0].FSlaveCells.Count = 1);
      Check(R.Cells[0,0].FSlaveCells[0]  = R.Cells[1,0]);
      r.SaveToFile(Filename);
      r.ResetContent;
      R.EditReport(FileName);
    finally
      R.Free;
    end;
end;

procedure TReportTest.Owner;
// TReportCell.Own Testcase .细微之处，必须这样测试：
var Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible :=False;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(2 ,3);
    r.ClearSelect ;
    r.Cells[1,0].Select;
    r.Cells[2,0].Select;
    r.CombineCell;
    assert(R.Lines[0].FCells.count = 2);
    assert(R.Lines[1].FCells.count = 2);
    assert(R.Lines[2].FCells.count = 2);
    Assert(r.Cells[1,0] = r.Cells[2,0].OwnerCell);
    Assert(r.Cells[1,0].FSlaveCells.count = 1);
    Assert(r.Cells[1,0].FSlaveCells[0] = r.Cells[2,0]);
    r.Cells[0,0].Select;
    r.Cells[1,0].Select;
    // 这样，Cells[1,0] 就有CellList，同时需要被Cells[0,0] 捕获(Owned)
    r.CombineCell;
    Assert(r.Cells[0,0] = r.Cells[1,0].OwnerCell);
    Assert(r.Cells[0,0] = r.Cells[2,0].OwnerCell);
    Assert(r.Cells[0,0].FSlaveCells.count = 2);
    Assert(r.Cells[0,0].FSlaveCells[0] = r.Cells[1,0]);
    Assert(r.Cells[0,0].FSlaveCells[1] = r.Cells[2,0]);
    r.SaveToFile(Filename);
    r.ResetContent;
    r.EditReport(FileName);     
end;
procedure TCDSTest.SolutedMissingDataProvider1;
var j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
    R:TReportRunTime;
    t1 ,t2: TClientDataset;
    F : TStringField;
begin
    t1 := TClientDataset.Create(nil);
    t1.FieldDefs.Add('ID', ftInteger, 0, True);
    t1.CreateDataSet;// key clause
    t1.open;
    t1.Append;
    t1.FieldByName('id').AsString := '1';
    t1.Post;
    t1.free;
end;
procedure TCDSTest.ReproducedMissingDataProvider;
var t1 ,t2: TClientDataset;
begin
    // CreateDataset required ,else MissingDataProvider happened;
    t1 := TClientDataset.Create(nil);
    t1.FieldDefs.Add('ID', ftInteger, 0, True);
    try
      t1.open;
    Except on E: EDatabaseError do
      Check(True,e.Message);
    end;
end;
procedure TReportTest.PrinterPagerWidth;
var
  p : TPrinterPaper;
 FprPageNo, FprPageXy, fpaperLength,
      fpaperWidth: Integer ;
begin
  p := TPrinterPaper.Create;
  p.prDeviceMode;
  p.SetPaper(DMPAPER_A4,DMORIENT_PORTRAIT,2970,2100);
  p.GetPaper(FprPageNo, FprPageXy, fpaperLength,
      fpaperWidth);
  check(FprPageNo =DMPAPER_A4);
  check(FprPageXy =DMORIENT_PORTRAIT);
  CheckEquals(fpaperLength,2970);
  CheckEquals(fpaperWidth,2100); 
end;

procedure TReportTest.PrinterCaps;
  function GetDPI(D:HDC): Integer;
  begin
    Result := GetDeviceCaps(d, LOGPIXELSX)
  end;
  function GetPixelsPerInchX: Integer;
  begin
    Result := GetDeviceCaps(Printer.Handle, LOGPIXELSX)
  end;

  function GetPixelsPerInchY: Integer;
  begin
    Result := GetDeviceCaps(Printer.Handle, LOGPIXELSY)
  end;
  function GetHorzX: Integer;
  begin
    Result := GetDeviceCaps(Printer.Handle, HORZSIZE)
  end;
  function GetHORZRES: Integer;
  begin
    Result := GetDeviceCaps(Printer.Handle, HORZRES)
  end;
  function mm2dot(mm:integer;dpi:integer):integer;
  begin
      result := Ceil(mm/25.4 *dpi);
  end;

var dc:HDC;   dots:Integer;
begin
  // printer
  //DPI
  CheckEquals(600,GetPixelsPerInchX);// dpi
  // Horz Resolution
  CheckEquals(210,GetHorzX);// unit by mm
  // and convet inch to cm
  CheckEquals(4961,GetHORZRES);// unit by dot
  // 验算 : 公式的由来！
  CheckEquals(Ceil(GetHorzX/2.54/10 *GetPixelsPerInchX),GetHORZRES);
  // Display，在屏幕上绘制20cm的线，应该转换成多少个Dot?

  dc := GetDC(0);
//  dots := mm2dot(100,GetDPI(dc))
//  ;
//
//  MoveToEx(dc,0,100,nil);
//  LineTo(dc,dots,100);

  // 量了下，确实比实际上的长。说明DPI是不准确的。
  // 那么问题来了。 I want to draw a line with a length of 1 cm, independent of the video
  {
      The trick is to know the size and resolution of the users screen.
      There is a property (I think of the canvas) called "PixelsPerInch", but it is
      unreliable.  For example, if the user is using a 10 foot projection monitor, the
      value for "Pixels per inch" might be 96, wich is definitely not true, as 96
      pixels might be more like a foot!
      Therefore, you need to measure and compute the users pixels per inch.  To do
      this, ask the user to use a ruler to measure a line on the screen, and enter in
      the results.
      Then, you have a scale to draw your line at.
      This is the only accurate way that I know of to do what you want.
  }
  SetMapMode(dc, MM_LOMETRIC );
  MoveToEx(dc, 0, -100 ,nil);
  LineTo(dc, 1000,-100); // 0.1mm ,so 1000 = 10cm
  ReleaseDC(0,dc);
  {
    Which mapping mode do you use?
    You can use the MM_LOMETRIC mapping mode for this purpose. With MM_LOMETRIC, 
    each logical unit is 0,1 mm. But take into account that you must use 
    negative values on the y-axis! To Draw a vertical line with a length of 1 cm 
    in the top left corner, use: 
    SetMapMode( Canvas.Handle, MM_LOMETRIC ); 
    Canvas.MoveTo( 0, 0 );
    Canvas.LineTo( 0, -100 );
    //
    Q:
    I write

    SetMapMOde(canvas.Handle,MM_LOMETRIC);
    Canvas.Rectange(0,0,100,100);

    and it's do not work.
    It draws nothing !!!
    A:
    1. Positive x is to the right; positive y is up
    and 
    2. Each logical unit is mapped to 0.1 millimeter
  }
end;

procedure TReportTest.OwnerCellRequiredHeight;
var Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      Check(R.Lines[0].FCells.count = 2);
      Check(R.Lines[1].FCells.count = 2);
      Check(R.Lines[2].FCells.count = 2);
      Check(R.Cells[0,0].OwnerCell = nil);
      Check(R.Cells[1,0].OwnerCell = R.Cells[0,0]);
      Check(R.Cells[2,0].OwnerCell = R.Cells[0,0]);
      Check(R.Cells[0,0].FSlaveCells.Count = 2);
      Check(R.Cells[0,0].FSlaveCells[0]  = R.Cells[1,0]);
      Check(R.Cells[0,0].FSlaveCells[1]  = R.Cells[2,0]);
      CheckEquals(20,R.Cells[0,0].Calc_RequiredCellHeight );
      CheckEquals(20,R.Cells[1,0].Calc_RequiredCellHeight );
      CheckEquals(20,R.Cells[2,0].Calc_RequiredCellHeight );
    finally
      R.Free;
    end;
end;
function TextDouble(s : string):string;
begin
  result := s + s;
end;
procedure TReportTest.OwnerCellRequiredHeightIncrement;
var Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      Check(R.Lines[0].FCells.count = 2);
      Check(R.Lines[1].FCells.count = 2);
      Check(R.Lines[2].FCells.count = 2);
      Check(R.Cells[0,0].OwnerCell = nil);
      Check(R.Cells[1,0].OwnerCell = R.Cells[0,0]);
      Check(R.Cells[2,0].OwnerCell = R.Cells[0,0]);
      Check(R.Cells[0,0].FSlaveCells.Count = 2);
      Check(R.Cells[0,0].FSlaveCells[0]  = R.Cells[1,0]);
      Check(R.Cells[0,0].FSlaveCells[1]  = R.Cells[2,0]);
      R.Cells[0,0].CellText := TextDouble(TextDouble(
        'long text so FRequiredCellHeight is incremented absolutly ' ));
      CheckEquals(68,R.Cells[0,0].Calc_RequiredCellHeight );
      CheckEquals(20,R.Cells[1,0].Calc_RequiredCellHeight );
      CheckEquals(20,R.Cells[2,0].Calc_RequiredCellHeight );
      CheckEquals(R.Cells[0,0].DefaultHeight,R.Cells[0,0].FMinCellHeight );
      CheckEquals(R.Cells[1,0].DefaultHeight,R.Cells[1,0].FMinCellHeight );
      CheckEquals(28,R.Cells[2,0].FMinCellHeight );    
    finally
      R.Free;
    end;
end;

procedure TReportTest.GetTextHeight;
var Filename ,s: string;
    ThisCell:TReportCell;
    R: TReportRunTime;
    rect : TRect;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      s := 'long text so FRequiredCellHeight is incremented absolutly ' ;
      s := TextDouble(TextDouble(s));  
      rect := R.Cells[0,0].GetTextRectInternal(s);
      CheckEquals(64,rect.bottom - rect.top); 
    finally
      R.Free;
    end;
end;
 // 补偿文字最后的回车带来的误差
procedure TReportTest.TextHeightCRCompensate;
var Filename ,s: string;
    ThisCell:TReportCell;
    R: TReportRunTime;
    rect : TRect;
begin

    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      s := 'long text so FRequiredCellHeight is incremented absolutly ' ;
      s := TextDouble(TextDouble(s))+chr(13)+chr(10);
      rect := R.Cells[0,0].GetTextRectInternal(s);
      CheckEquals(96,rect.bottom - rect.top);
//      CheckEquals(96, r.Cells[0,0].CellWidth);
    finally
      R.Free;
    end;
    //  DT_LEFT; DT_CENTER ;DT_RIGHT
//    CalcBottom( TempString,TempRect, HAlign2DT(FHorzAlign))
end;

procedure TReportTest.CalcTextHeight;
var Filename ,s: string;
    ThisCell:TReportCell;
    R: TReportRunTime;
    rect : TRect;
    FLogFont: TLogFont ;
    Var
  hTempDC: HDC;
  pt, ptOrg: TPoint;
begin
      FLogFont.lfHeight := 120;
      FLogFont.lfWidth := 0;
      FLogFont.lfEscapement := 0;
      FLogFont.lfOrientation := 0;
      FLogFont.lfWeight := 0;
      FLogFont.lfItalic := 0;
      FLogFont.lfUnderline := 0;
      FLogFont.lfStrikeOut := 0;
      FLogFont.lfCharSet := DEFAULT_CHARSET;
      FLogFont.lfOutPrecision := 0;
      FLogFont.lfClipPrecision := 0;
      FLogFont.lfQuality := 0;
      FLogFont.lfPitchAndFamily := 0;
      FLogFont.lfFaceName := '宋体';
      // Hey, I pass a invalid window's handle to you, what you return to me ?
      // Haha, is a device context of the DESKTOP WINDOW !
      hTempDC := GetDC(0);

      pt.y := GetDeviceCaps(hTempDC, LOGPIXELSY) * FLogFont.lfHeight;
      pt.y := trunc(pt.y / 720 + 0.5);      // 72 points/inch, 10 decipoints/point
      DPtoLP(hTempDC, pt, 1);
      ptOrg.x := 0;
      ptOrg.y := 0;
      DPtoLP(hTempDC, ptOrg, 1);
      FLogFont.lfHeight := -abs(pt.y - ptOrg.y);
      ReleaseDC(0, hTempDC);

      s := 'long text so FRequiredCellHeight is incremented absolutly ' ;
      s := TextDouble(TextDouble(s))+chr(13)+chr(10);
      rect.Top := 0 ;
      rect.Right := 462 ; // CellWidth(472) - 2*FLeftMargin
      rect.Left := 0 ;
      rect.bottom  := CalcBottom( s,rect,DT_LEFT,FLogFont);
      CheckEquals(96,rect.bottom - rect.top);
    //  DT_LEFT; DT_CENTER ;DT_RIGHT
//
end;
function ConverToLogFontHeight(PointSize :Integer):Integer;
var h : HDC;
begin
  h := GetDC(0);
  try
    result :=  -MulDiv(PointSize, GetDeviceCaps(h, LOGPIXELSY), 72);
  finally
    ReleaseDC(0, h);
  end;
end;
function ConverToLogFontHeight1(PointSize :Integer):Integer;
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
procedure TReportTest.LogFont;
begin
    CheckEquals(-16,ConverToLogFontHeight(12));
    CheckEquals(-16,ConverToLogFontHeight1(12));
end;
// GOOGLE : TFont,TLogFont使用
procedure TReportTest.TFont1;
var
  FLogFont: TLogFont;
  Font: TFont;
begin
    Font := TFont.Create;
//    Font.Name := 'Arial';//或者 宋体 .都一样。
    Font.Size := 12;
    try
      GetObject(Font.Handle, sizeof(FLogFont), @FLogFont) ;
      CheckEquals(-16,FLogFont.lfheight);
      CheckEquals(FLogFont.lfWidth , 0);
      CheckEquals(FLogFont.lfEscapement , 0);
      CheckEquals(FLogFont.lfOrientation , 0);
      //The weight of the font in the range 0 through 1000.
      //For example, 400 is normal and 700 is bold.
      //If this value is zero, a default weight is used.
      CheckEquals(FLogFont.lfWeight , 400); 
      CheckEquals(FLogFont.lfItalic , 0);
      CheckEquals(FLogFont.lfUnderline , 0);
      CheckEquals(FLogFont.lfStrikeOut , 0);
      CheckEquals(FLogFont.lfCharSet , DEFAULT_CHARSET);
      CheckEquals(FLogFont.lfOutPrecision , 0);
      CheckEquals(FLogFont.lfClipPrecision , 0);
      CheckEquals(FLogFont.lfQuality , 0);
      CheckEquals(FLogFont.lfPitchAndFamily , 0);          
    finally
      Font.Free;
    end;

end;
procedure TReportTest.Inc_vs_Add;
var
   r: TRect ;
begin
    SetRectEmpty(r);
    r.Bottom :=  10 ;
    r.Bottom := R.Bottom +2;
    CheckEquals(12,r.Bottom);
    Inc(r.Bottom,2);
    CheckEquals(14,r.bottom);

end;

procedure TReportTest.CalcText_Cell_Rect;
var Filename ,s: string;
    c0:TReportCell;
    R: TReportRunTime;
    rect : TRect;
    w1,w2 :integer;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      CheckEquals(20,r.Cells[0,0].CellRect.Bottom -r.Cells[0,0].CellRect.Top);
      c0 :=   r.Cells[0,0] ;
      CheckEquals(
            c0.CellRect.Top+c0.FTopLineWidth +1,
            c0.TextRect.Top
      );
      CheckEquals(
            c0.CellRect.Bottom,
            c0.TextRect.Bottom+c0.FBottomLineWidth +1
      );
      CheckEquals(
            c0.CellRect.Right,
            c0.TextRect.Right+c0.FRightLineWidth + c0.FLeftMargin
      );
      CheckEquals(
            c0.CellRect.Left+c0.FLeftLineWidth + c0.FLeftMargin,
            c0.TextRect.Left
      );
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      CheckEquals(60,r.Cells[0,0].FCellRect.Bottom -r.Cells[0,0].FCellRect.Top);

    finally
      R.Free;
    end;
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      w1 := r.Cells[0,0].FCellRect.Right -r.Cells[0,0].FCellRect.Left;
      r.Cells[0,0].Select;
      r.Cells[0,1].Select;
      r.CombineCell ;
      w2 := r.Cells[0,0].FCellRect.Right -r.Cells[0,0].FCellRect.Left;
      CheckEquals(w1*2,w2);
    finally
      R.Free;
    end;
end;
// should we  
// alter : R.Top := R.Top + trunc((FCellRect.Bottom - FCellRect.Top - FRequiredCellHeight) / 2 + 0.5);
// to :  Inc(R.Top,Ceil(FCellRect.Bottom - FCellRect.Top - FRequiredCellHeight) / 2)
procedure TReportTest.Trunc_vs_ceil;
var r,i,base :integer;
    a :array[0..3] of Integer;
begin
  base := 2;
  for i := 0 to Trunc (Power(10,6)) do begin
      r := i ;
      CheckEquals(
        trunc(r / base + 0.5),
        Ceil(r/base)
      );
  end;
end;
procedure TReportTest.TextLine_vs_RequiredHeight;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportRunTime;
begin
    R := TReportRunTime.Create(Application.MainForm);
    R.Visible := false;
    try
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      s := 'long text so is incremented absolutly ';
      r.Cells[0,0].CellText := s ;
      CheckEquals(0,R.Cells[0,0].FRequiredCellHeight );
      b := s + chr(13)+chr(10) + S ;
      r.Cells[0,0].CellText := b ;
      CheckEquals(0,R.Cells[0,0].FRequiredCellHeight );
      b := s + chr(13)+chr(10) + S + chr(13)+chr(10) + S;
      r.Cells[0,0].CellText := b ;
      CheckEquals(0,R.Cells[0,0].FRequiredCellHeight );
      r.SaveToFile(Filename);
      r.ResetContent;
      R.EditReport(FileName);
    finally
      R.Free;
    end;
end;


procedure TReportTest.SetUp;
begin
  inherited;

end;

procedure TReportTest.TearDown;
begin
  inherited;
end;

procedure TReportTest.DoChanged(Sender: TObject; str: String);
begin
//   Application.MainForm.Caption :=
//    Application.MainForm.Caption + Inttostr(R.Cells[0,0].FRequiredCellHeight)+',' ;
end;

procedure TReportTest.DirectLoad;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.ReportControl1;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      s := 'long text so is incremented absolutly ';
      r.Cells[0,0].CellText := s ;
      form.ShowModal;      
    finally
      TCreportForm.UninitReport();
    end;
end;

procedure TReportTest.TopAlign;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.ReportControl1;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      r.Cells[0,0].VertAlign := TEXT_ALIGN_TOP ;
      r.Cells[0,0].CalcMinCellHeight;
      s := 'long text so is incremented absolutly ';
      r.Cells[0,0].CellText := s ;
      form.ShowModal;      
    finally
      TCreportForm.UninitReport();
    end;
end;
procedure TReportTest.LoadSave_now_it_is_shift_to_you;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.ReportControl1;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      r.Cells[0,0].VertAlign := TEXT_ALIGN_TOP ;
      r.Cells[0,0].CalcMinCellHeight;
      s := 'long text so is incremented absolutly ';
      r.Cells[0,0].CellText := s ;
      FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
      R.SaveToFile(FileName);
      R.LoadFromFile(FileName);
      CheckEquals(3,R.LineList.count);
      // TODO : 继续ut，以便重构代码 Load / Save 部分。分化之。
    finally
      TCreportForm.UninitReport();
    end;
end;

initialization
  RegisterTests('Framework Suites',[TReportTest.Suite,TReportUITest.Suite,TCDSTest.Suite]);
end.
