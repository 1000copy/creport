
unit ReportTest;

interface

uses
  // user
  osservice,
  ReportControl,
  ReportRunTime,
  // sys
   Math,DBClient,  db,  DBTables,  Graphics,  forms,  Windows,  SysUtils,  TestFramework,Printers;

type
  TCDSTest =  class(TTestCase)
  published
    procedure ReproducedEAccessViolation;
    procedure SolutedMissingDataProvider1;
    procedure ReproducedMissingDataProvider;
  end;
  TReportTest = class(TTestCase)
  private
    fTestCount: integer;
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
procedure TReportTest.SetUp;
begin
  inherited;

end;

procedure TReportTest.TearDown;
begin
  inherited;

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

initialization
  RegisterTests('Framework Suites',[TReportTest.Suite,TReportUITest.Suite,TCDSTest.Suite]);
end.
