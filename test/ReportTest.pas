
unit ReportTest;

interface

uses
  // user
  cc,
  uHornCartesian,
  osservice,
  ReportControl,
  ReportRunTime,creport,
  // sys
  messages,
  Classes,
   Math,DBClient,  db,  DBTables,  Graphics,  forms,  Windows,  SysUtils,  TestFramework,Printers;

type
  TCDSTest =  class(TTestCase)
    procedure ReproducedEAccessViolation;
  published
    procedure SolutedMissingDataProvider1;
    procedure ReproducedMissingDataProvider;
  end;
  TReportRunTimeTest = class(TTestCase)
  private
  published
    procedure HeadHeightMustEqualsFillHeadListsHeight ;
    procedure NonRegularDetailLine;
    procedure VarList;
    procedure HeightHowtoConsumed;
    procedure Rita;
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
    procedure Rita;
    procedure ScaleRect;
    procedure FormCartesian;
    procedure SetCellAlign;
    procedure RectInflate;
    procedure TFont2;
    procedure VSplitCell_UpdateLines_Associcated;
    procedure AddCell;
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
    procedure ReadTYpe ;
    procedure MeasureConvert;
    procedure SlaveHeight;
    procedure CopyLine_bInsert;
    procedure ProcedureAnonymos;
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
        'long text so RequiredCellHeight is incremented absolutly ' ));
      CheckEquals(68,R.Cells[0,0].Calc_RequiredCellHeight );
      CheckEquals(20,R.Cells[1,0].Calc_RequiredCellHeight );
      CheckEquals(20,R.Cells[2,0].Calc_RequiredCellHeight );
      CheckEquals(R.Cells[0,0].DefaultHeight,R.Cells[0,0].FCellHeight );
      CheckEquals(R.Cells[1,0].DefaultHeight,R.Cells[1,0].FCellHeight );
      CheckEquals(28,R.Cells[2,0].FCellHeight );    
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
      s := 'long text so RequiredCellHeight is incremented absolutly ' ;
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
      s := 'long text so RequiredCellHeight is incremented absolutly ' ;
      s := TextDouble(TextDouble(s))+chr(13)+chr(10);
      rect := R.Cells[0,0].GetTextRectInternal(s);
      CheckEquals(80,rect.bottom - rect.top);
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

      s := '1' ;
      s := s +chr(13)+chr(10);
      s := s +chr(13)+chr(10);
      rect.Top := 0 ;
      rect.Right := 462 ; // CellWidth(472) - 2*FLeftMargin
      rect.Left := 0 ;
      rect.bottom  := CalcBottom( s,rect,DT_LEFT,FLogFont);
      // three lines 
      CheckEquals(48,rect.bottom - rect.top);
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

procedure TReportTest.LogFont;
var os : WindowsOs;
begin
    os :=WindowsOs.Create;
    CheckEquals(-16,os.Height2LogFontHeight(12));
    CheckEquals(-16,os.Height2LogFontHeight(12));
    os.free;
end;
// GOOGLE : TFont,TLogFont使用
procedure TReportTest.TFont2;
var
  FLogFont: TLogFont;
  os : WindowsOS;
begin
    os := WindowsOS.Create;
    try
      FLogFont := os.MakeLogFont('Arial',12);
      CheckEquals(-16,FLogFont.lfheight);
      CheckEquals(FLogFont.lfWidth , 0);
      CheckEquals(FLogFont.lfEscapement , 0);
      CheckEquals(FLogFont.lfOrientation , 0);
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
      os.Free;
    end;

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
      CheckEquals(0,R.Cells[0,0].Calc_RequiredCellHeight );
      b := s + chr(13)+chr(10) + S ;
      r.Cells[0,0].CellText := b ;
      CheckEquals(0,R.Cells[0,0].Calc_RequiredCellHeight );
      b := s + chr(13)+chr(10) + S + chr(13)+chr(10) + S;
      r.Cells[0,0].CellText := b ;
      CheckEquals(0,R.Cells[0,0].Calc_RequiredCellHeight );
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
      R := form.RC;
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
      R := form.RC;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      r.Cells[0,0].VertAlign := TEXT_ALIGN_TOP ;
      r.Cells[0,0].CalcHeight;
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
Var
  TargetFile: TSimpleFileStream;
  FileFlag: WORD;
  Count1, Count2, Count3: Integer;
  ThisLine: TReportLine;
  I, J, K: Integer;
  TempPChar: Array[0..3000] Of Char;
  bHasDataSet: Boolean;
begin
  form := TCreportForm.InitReport ;   
  R := form.RC;
  r.SetWndSize(1058,748);
  r.NewTable(2 ,3);
  r.Cells[0,0].Select;
  r.Cells[1,0].Select;
  r.Cells[2,0].Select;
  r.CombineCell ;
  r.Cells[0,0].VertAlign := TEXT_ALIGN_TOP ;
  r.Cells[0,0].CalcHeight;
  s := 'long text 111so is incremented absolutly ';
  r.Cells[0,0].CellText := s ;
  FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
  R.SaveToFile(FileName);
  TargetFile := TSimpleFileStream.Create(FileName, fmOpenRead);
  Try
    With TargetFile Do
    Begin
      ReadWord(FileFlag);CheckEquals($AA57,FileFlag);
    end;
  finally
    targetFile.Free;
    TCreportForm.UninitReport();
  end;
end;



procedure TReportTest.ReadTYpe;
var
   a:word ;
   b:integer ;
   c:uint ;
   d:char;
   f:real ;
   g:byte ;
   h :TRect ;
   i : cardinal;
begin
  checkEquals(sizeof(a),sizeof(word));
  checkEquals(sizeof(b),sizeof(integer));
  checkEquals(sizeof(c),sizeof(uint));
  checkEquals(sizeof(d),sizeof(char));
  checkEquals(sizeof(f),sizeof(real));
  checkEquals(sizeof(g),sizeof(byte));
  checkEquals(sizeof(h),sizeof(TREct));
  checkEquals(sizeof(i),sizeof(cardinal));
end;

procedure TReportTest.MeasureConvert;
var f,e,c,d,a,b, nPixelsPerInch:integer;hDesktopDC :THandle;
  os : WindowsOS ;
begin
  hDesktopDC := GetDC(0);
  nPixelsPerInch := GetDeviceCaps(hDesktopDC, LOGPIXELSX);
  // 以毫米为单位
  a := 20;
  b := 10;
  f := 15;

  c:= trunc(nPixelsPerInch * a/ 25 + 0.5);
  d:= trunc(nPixelsPerInch * b/ 25 + 0.5);
  e:= trunc(nPixelsPerInch * f/ 25 + 0.5);
  ReleaseDC(0, hDesktopDC);
  CheckEquals(77,c);
  CheckEquals(38,d);
  CheckEquals(58,e);
  os := WIndowsOS.Create;
  CheckEquals(77,os.MM2Dot(a));
  CheckEquals(38,os.MM2Dot(b));
  CheckEquals(58,os.MM2Dot(f));
  os.Free;
end;

procedure TReportTest.SlaveHeight;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.RC;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      // 垂直合并后，Cell并不减少
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      checkequals(20,r.Cells[0,0].FCellHeight);
      checkequals(20,r.Cells[1,0].FCellHeight);
      checkequals(20,r.Cells[2,0].FCellHeight);
    finally
      TCreportForm.UninitReport();
    end;
end;
//cover test bInsert
//  Procedure TReportCell.CopyCell(Cell: TReportCell; bInsert: Boolean);
procedure TReportTest.CopyLine_bInsert;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.RC;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,3);
      r.Cells[0,0].Select;
      r.Cells[1,0].Select;
      r.Cells[2,0].Select;
      r.CombineCell ;
      r.ClearSelect;
      r.Cells[1,1].Select;
      CheckEquals(1,r.SelectedCells[0].OwnerLine.Index );
      r.InsertLine; // will copyLine(bInsert = true)
      CheckEquals(2,r.SelectedCells[0].OwnerLine.Index );
      CheckEquals(4,r.LineList.Count );
      r.AddLine;  //// will copyLine(bInsert = false)
      CheckEquals(2,r.SelectedCells[0].OwnerLine.Index );
      CheckEquals(5,r.LineList.Count );
      form.ShowModal;
    finally
      TCreportForm.UninitReport();
    end;
end;
procedure TReportTest.AddCell;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.RC;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,2);
      r.Cells[0,1].Select;
      r.Cells[0,1].CellWidth := 10;
      r.AddCell;
      CheckEquals(3,r.Lines[0].FCells.count);
      CheckEquals(10,r.Cells[0,2].Cellwidth );
      //form.ShowModal;
    finally
      TCreportForm.UninitReport();
    end;
end;
procedure TReportTest.VSplitCell_UpdateLines_Associcated;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.RC;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,2);
      // 验证：UpdateLine做的事情，是否都那么必要？
      // CalcLineHeight 内做的事情有点杂，需要分离职责。
      r.DOvsplit(R.Cells[0,0],3);
      CheckEquals(4,r.Lines[0].FCells.count);
      CheckEquals(0,r.Cells[0,0].CellIndex);
      CheckEquals(1,r.Cells[0,1].CellIndex);
      CheckEquals(2,r.Cells[0,2].CellIndex);
      CheckEquals(3,r.Cells[0,3].CellIndex);
      CheckNotEquals(0,r.Cells[0,1].CellTop);
      CheckNotEquals(0,r.Cells[0,1].CellHeight);
      form.ShowModal;
    finally
      TCreportForm.UninitReport();
    end;
end;
procedure TReportTest.ProcedureAnonymos;
begin
  // Anonymous Method 是有的，不过在Delphi 2009 之后 ：）——
end;
procedure TReportTest.RectInflate;
var R,R2:TRect;os:WindowsOS;
begin
    os := Windowsos.Create ;
    Os.SetRectEmpty(R);
    R.Left := R.left - 1;
    R.Top := R.top - 1;
    R.Right := R.Right + 1;
    R.Bottom := R.Bottom + 1;
    Os.SetRectEmpty(R2);
    os.InflateRect(r2,1,1);
    checkTrue(os.RectEquals(r,r2));
end;

procedure TReportTest.SetCellAlign;
var s,b,Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
    form : TCreportForm;
begin
    form := TCreportForm.InitReport ;
    try
      R := form.RC;
      r.SetWndSize(1058,748);
      r.NewTable(2 ,2);
      // 验证：UpdateLine做的事情，是否都那么必要？
      // CalcLineHeight 内做的事情有点杂，需要分离职责。
      r.Cells[0,0].CellText := 'text sth';
      r.Cells[0,0].Select;
      r.SetCellAlignHorzAlign(1);
//      CheckEquals(4,2);
      form.ShowModal;
    finally
      TCreportForm.UninitReport();
    end;
end;
type
  CForm = class (TForm)
  private
    hPaintDC: HDC;
    ps: TPaintStruct;
  public
    Procedure WMPaint(Var Message: TMessage); Message WM_PAINT;
    procedure DoPaint;
    procedure DoPaint1;
    procedure DoPaint2;
    procedure DoPaint3;

  end;
procedure TReportTest.FormCartesian ;
var
  form : TForm;
begin
    form := CForm.CreateNew (nil);
    //GOOGLe:not able to create a dynamic form in delphi7
    //form := CForm.Create (nil);
    form.Height := 500;
    form.Width := 1000;
    try
      form.ShowModal;
    finally
      form.Free;
    end;
end;

{ CForm }

procedure CForm.DoPaint;
begin
  {
    The viewport sets the origin and extent of the client area in pixels (or based on the size in pixels) and the window is the origin and extent of the client area in logical units (which can be a user defined scale). The window co-ordinates will then be converted to viewport co-ordinates for display.

    The default mapping mode treats window units as viewport units with the origin at the top left, so all painting to the client area is based on the pixels where the painting is to be done.
    An example -

    Code:
    SetMapMode(hdc,MM_ANISOTROPIC);
    SetWindowOrgEx(hdc,0,0,0);
    SetWindowExtEx(hdc,2000,2000,0);
    SetViewportOrgEx(hdc,0,0,0);
    SetViewportExtEx(hdc,100,100,0);
    TextOut(hdc,2000,2000,"Hello, World!",13);

    First of all I'm setting the logical units to be used to draw to the window to 2000 by 2000, and then making these units relate to 100 by 100 pixels. So my text will be outputted at 100 pixels across and 100 pixels down in my client area. If I changed the TextOut call to paint at 1000,1000 then the text will be drawn at 50,50 and changing it to 4000,4000 will draw at 200,200.

    If I do something like -

    SetMapMode(hdc,MM_ANISOTROPIC);
    SetWindowOrgEx(hdc,-1000,-1000,0);
    SetWindowExtEx(hdc,2000,2000,0);
    SetViewportOrgEx(hdc,0,0,0);
    SetViewportExtEx(hdc,100,100,0);
    TextOut(hdc,0,0,"Hello, World!",13);
    The the origin of the window now starts at -1000,-1000, so now when I paint the text at 0,0 this translates to 50 pixels across and 50 pixels down (as 0,0 is 1000 logical units from the left and 1000 logical units from the top).

    Alternatively I can adjust where the text is painted by altering the viewport origin -

    Code:

    SetMapMode(hdc,MM_ANISOTROPIC);
    SetWindowOrgEx(hdc,0,0,0);
    SetWindowExtEx(hdc,2000,2000,0);
    SetViewportOrgEx(hdc,50,50,0);
    SetViewportExtEx(hdc,100,100,0);
    TextOut(hdc,0,0,"Hello, World!",13);
    The origin 0,0 has been transformed 50 pixels across the top and 50 pixels down.

    There's probably not much point altering the window orgin and the viewport orgin, you'd alter one and stick with it. However you may want to alter the extent of both so that differing amount of pixels represent a differerent amount of logical units. 

    If you're not sure take the code and stick it in a WM_PAINT message and have a play around with it.
    }
  SetMapMode(hPaintDC,MM_ANISOTROPIC);
  SetWindowOrgEx(hPaintDC,0,0,0);
  SetWindowExtEx(hPaintDC,1000,1000,0);
  SetViewportOrgEx(hPaintDC,0,0,0);
  SetViewportExtEx(hPaintDC,100,100,0);
  TextOut(hPaintDC,2000,1000,'Hello, World!',13);
  //
  SetMapMode(hPaintDC,MM_ANISOTROPIC);
  SetWindowOrgEx(hPaintDC,-1000,-1000,0);
  SetWindowExtEx(hPaintDC,2000,2000,0);
  SetViewportOrgEx(hPaintDC,0,0,0);
  SetViewportExtEx(hPaintDC,100,100,0);
  TextOut(hPaintDC,0,0,'Hello, World!',13);
  //
  SetMapMode(hPaintDC,MM_ANISOTROPIC);
  SetWindowOrgEx(hPaintDC,0,0,0);
  SetWindowExtEx(hPaintDC,2000,2000,0);
  SetViewportOrgEx(hPaintDC,50,50,0);
  SetViewportExtEx(hPaintDC,100,100,0);
  TextOut(hPaintDC,0,0,'Hello, World!',13);
  //
  SetMapMode(hPaintDC,MM_ANISOTROPIC);
  SetWindowExtEx(hPaintDC,1000,-1000,0);
  SetViewportExtEx(hPaintDC,ClientWidth,ClientHeight,0);
  SetViewportOrgEx(hPaintDC, 0,ClientHeight ,0);
  Ellipse(hPaintDC,0,0,1000,1000);
end;
procedure CForm.DoPaint2;
VAR
  saved,HornLength ,HornX,HornY :integer;
procedure DrawHorn ;
  begin
   HornLength := 50 ;
      MoveToEx(hPaintDC, 0, 0, Nil);
    LineTo(hPaintDC, 0, HornLength);
    MoveToEx(hPaintDC, 0, 0, Nil);
    LineTo(hPaintDC, HornLength, 0);
  end;


begin
  // 这样绘制的4个飞燕（鹿角），确实比起一个个的原点不动，绝对坐标调整的方式来的更好。
  // GOOGLE:GDI Coordinate Systems - FunctionX
  HornX := 100;
  HornY := 100;

  saved := saveDC(hPaintDC);

  SetMapMode(hPaintDC,MM_ISOTROPIC);
  // Left Top
  SetViewportOrgEx(hPaintDC,HornX,HornY,0);
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,-1,-1,0);
  DrawHorn ;
  // Right Top
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,1,-1,0);
  SetViewportOrgEx(hPaintDC,ClientWidth - HornX,HornY,0);
  DrawHorn ;
  // Left bottom
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,-1,1,0);
  SetViewportOrgEx(hPaintDC,HornX,ClientHeight - HornY,0);
  DrawHorn ;
  // right bottom
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,1,1,0);
  SetViewportOrgEx(hPaintDC,ClientWidth - HornX,ClientHeight - HornY,0);
  DrawHorn ;

  restoreDC(hPaintDC,saved);
  DrawHorn ;

end;

procedure CForm.DoPaint1;
VAR
  saved,HornLength ,HornX,HornY :integer;
var c : Cartesian;   p:TPoint ;
  function MakePoint(x,y:Integer):TPoint;begin
   result.x := x;
   result.y := y;
  end;
begin
   HornX := 100;
   HornY := 100;
   c := HornCartesian.Create(hPaintDc);
   try
     c.Save;
     c.Origin := MakePoint(HornX,HornY);
     c.Oriention := orLeftTop;
     c.Ratio := 200;
     c.Go;
     //
     c.Origin := MakePoint(ClientWidth - HornX,HornY);
     c.Oriention := orRightTop;
     c.Ratio := 100;
     c.Go;
     //
     c.Origin := MakePoint(ClientWidth - HornX,ClientHeight - HornY);
     c.Oriention := orRightBottom;
     c.Ratio := 50;
     c.Go;
     //
     c.Origin := MakePoint(HornX,ClientHeight - HornY);
     c.Oriention := orLeftBottom;
     c.Go;
   finally
     c.Restore;
     c.free;
   end;
end;
procedure CForm.DoPaint3;
VAR
  saved,HornLength ,HornX,HornY :integer;
procedure DrawHorn ;
  begin
   HornLength := 50 ;
      MoveToEx(hPaintDC, 0, 0, Nil);
    LineTo(hPaintDC, 0, HornLength);
    MoveToEx(hPaintDC, 0, 0, Nil);
    LineTo(hPaintDC, HornLength, 0);
  end;


begin
  // 这样绘制的4个飞燕（鹿角），确实比起一个个的原点不动，绝对坐标调整的方式来的更好。
  // GOOGLE:GDI Coordinate Systems - FunctionX
  HornX := 100;
  HornY := 100;

  saved := saveDC(hPaintDC);

  SetMapMode(hPaintDC,MM_ISOTROPIC);
  // Left Top

  SetViewportOrgEx(hPaintDC,HornX,HornY,0);
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,-1,-1,0);
  DrawHorn ;
  // Right Top
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,1,-1,0);
  SetViewportOrgEx(hPaintDC,ClientWidth - HornX,HornY,0);
  DrawHorn ;
  // Left bottom
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,-1,1,0);
  SetViewportOrgEx(hPaintDC,HornX,ClientHeight - HornY,0);
  DrawHorn ;
  // right bottom
  SetViewportExtEx(hPaintDC,1,1,0);
  SetWindowExtEx(hPaintDC,1,1,0);
  SetViewportOrgEx(hPaintDC,ClientWidth - HornX,ClientHeight - HornY,0);
  DrawHorn ;

  restoreDC(hPaintDC,saved);
  DrawHorn ;

end;
procedure CForm.WMPaint(var Message: TMessage);

Begin
  // 全部鼠标消息的代码的都舒服了，归一了。现在开始WMPaint.... 
  hPaintDC := BeginPaint(Handle, ps);
  DoPaint1 ;
  EndPaint(Handle, ps);
End;


procedure TReportTest.ScaleRect;
var r ,rectPaint: trect;os :WIndowsOs; FReportScale:Integer;
begin
  os := windowsos.Create;
  r.left :=100;
  os.InverseScaleRect(r,50);
  CheckEquals(200,r.Left);
  rectPaint.left :=100;
  FReportScale := 50 ;
  If FReportScale <> 100 Then
  Begin
    rectPaint.Left := trunc(rectPaint.Left * 100 / FReportScale + 0.5);
    rectPaint.Top := trunc(rectPaint.Top * 100 / FReportScale + 0.5);
    rectPaint.Right := trunc(rectPaint.Right * 100 / FReportScale + 0.5);
    rectPaint.Bottom := trunc(rectPaint.Bottom * 100 / FReportScale + 0.5);
  End;
  CheckEquals(200,rectPaint.Left);
end;

procedure TReportTest.Rita;
begin

end;

{ TReportRunTimeTest }
const
  PAGEHEIGHT = 748 ;
  PAGEWIDTH =  1058 ;
  HEADERHEIGHT= 80 ;
  LINEHEIGHT =20;
procedure TReportRunTimeTest.Rita;
var i,j:integer;
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
      for I:= 0 to 100 do
        t1.AppendRecord([I,(cos(I)*1000)]);
      t2.AppendRecord([2]);
      strFileDir := ExtractFileDir(Application.ExeName);
      with  R do
      begin
        SetWndSize(PAGEWIDTH,PAGEHEIGHT);
        NewTable(6 ,3);
        Lines[0].Select;  
        CombineCell;
        Lines[0].LineHeight := HEADERHEIGHT;
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
      R.PrintPreview(true);    // Ready for  Test Page_count 
    finally
      T1.free;
      T2.Free;
    end;
end;
procedure TReportRunTimeTest.HeightHowtoConsumed;
var i,j,height:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
    R:TReportRunTime;
    t1 : TClientDataset;
    F : TStringField;
    list:TList;
begin
  try
      R:=TReportRunTime.Create(Application.MainForm);
      R.Visible := False;
      R.ClearDataSet;
      t1 := TClientDataset.Create(nil);
      t1.FieldDefs.Add('f1',ftString,20,true);
      t1.FieldDefs.Add('f2',ftString,20,true);
      t1.CreateDataSet;
      R.SetDataSet('t1',t1);
      t1.Open;
      for I:= 0 to 100 do
        t1.AppendRecord([I,(cos(I)*1000)]);
      strFileDir := ExtractFileDir(Application.ExeName);
      with  R do
      begin
        SetWndSize(PAGEWIDTH,PAGEHEIGHT);
        NewTable(2 ,4);
        Lines[0].Select;  
        CombineCell;
        Lines[0].LineHeight := HEADERHEIGHT;
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
        Cells[3,0].CellText := 'Footer..';
        SaveToFile(strFileDir+'\'+'xxx.ept');
        ResetContent;
        cf.Free;
      end;
      R.ReportFile:=strFileDir+'\'+'xxx.ept';
      R.PrintPreview(true);    
      //r.EditReport(R.ReportFile);
      //CheckEquals(0 ,
      //  PAGEHEIGHT- (HEADERHEIGHT+r.TopMargin + 24* LINEHEIGHT + LINEHEIGHT  +r.BottomMargin));
      R.SetDataSet('t1',t1);
      CheckEquals(5,R.DoPageCount);
      height := 0;
      list := r.FillHeadList(height);
      CheckEquals(HEADERHEIGHT+LINEHEIGHT*1,height);
      CheckEquals(2,list.count);
      CheckEquals(HEADERHEIGHT,TReportLine(list[0]).Lineheight);
      CheckEquals(LineHEIGHT,TReportLine(list[1]).Lineheight);
    finally
      T1.free;
    end;
end;

procedure TReportRunTimeTest.VarList;
var
    Key,Value,FileName:string;
    R:TReportRunTime;
begin
  Key := 'HEAD';
  Value := '1-value';
  try
    R:=TReportRunTime.Create(Application.MainForm);
    R.Visible := False;
    R.ClearDataSet;
    FileName :=osservice.AppDir+'xxx.ept';
    with  R do
    begin
      SetWndSize(PAGEWIDTH,PAGEHEIGHT);
      NewTable(2 ,4);
      Cells[0,0].CellText := cc.FormulaPrefix+Key;
      SetVarValue(Key,Value);
      SaveToFile(FileName);
      ResetContent;
    end;
    R.ReportFile:=FileName;
    R.PrintPreview(true);
    CheckEquals(1,R.DoPageCount);
    CheckEquals(Value,R.Cells[0,0].CellText);
  finally
     R.Free;
  end;
end;

procedure TReportRunTimeTest.NonRegularDetailLine;
begin
  // 如果一个detailLine 跨越了两行，会怎样？
end;

procedure TReportRunTimeTest.HeadHeightMustEqualsFillHeadListsHeight;
begin
  // 再写一个单纯的GetheadHeight，替代FillHeadList ,但是不管何时，必须保证两者获得的Height相等。
end;

initialization
  RegisterTests('Report',[
      TReportRuntimeTest.Suite,
      TReportTest.Suite,
      TReportUITest.Suite,
      TCDSTest.Suite
  ]);
end.
