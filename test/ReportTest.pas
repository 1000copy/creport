
unit ReportTest;

interface

uses
  // user
  osservice,
  ReportControl,
  uReportRunTime,
  // sys
  DBClient,
  db,
  DBTables,
  Graphics,
  forms,
  Windows,
  SysUtils,
  TestFramework;

type

  TReportTest = class(TTestCase)
  private
    fTestCount: integer;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCombineVertical;
    procedure TestCombineHorz;
    procedure TestOwner;
    procedure Rect;
    procedure dynamicReport;
    procedure CreateDatasetWayWayWay;
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
// why Fields.add can't work?
// and how to pupolate TClientDataset
// http://www.informit.com/articles/article.aspx?p=24094&seqNum=5
procedure TReportTest.CreateDatasetWayWayWay;
var j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
    R:TReportRunTime;
    t1 ,t2: TClientDataset;
    F : TStringField;
begin
    R:=TReportRunTime.Create(Application.MainForm);
    R.Visible := False;
    R.ClearDataSet;
    t1 := TClientDataset.Create(nil);
    //    F := TStringField.Create(t1);
    //    F.FieldName := 'zname';
    //    t1.Fields.Add(F);
    {
     FCDS.FieldDefs.Add('ID', ftInteger, 0, True);
     FCDS.FieldDefs.Add('Name', ftString, 20, True);
     FCDS.FieldDefs.Add('Birthday', ftDateTime, 0, True);
     FCDS.FieldDefs.Add('Salary', ftCurrency, 0, True);

    }
    // soluted : http://stackoverflow.com/questions/26564531/tclientdataset-missing-data-provider
    {
      FCDS.CreateDataSet;
    }
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
    R:=TReportRunTime.Create(Application.MainForm);
    R.Visible := False;
    R.ClearDataSet;
    t1 := TClientDataset.Create(nil);
    t1.FieldDefs.Add('zname',ftString,20,true);
    t2 := TClientDataset.Create(nil);
    t2.FieldDefs.Add('zname',ftString,20,true);

    t1.CreateDataSet;
    t2.CreateDataSet;
    R.SetDataSet('t1',t1);
    R.SetDataSet('t2',t2);
    t1.Open;
    t2.Open;
    t1.Append;
    t1.FieldByName('zname').asstring:= '2' ;
    t1.Post;
    t2.Append;
    t2.FieldByName('zname').asstring:= '2' ;
    t2.Post;
    strFileDir := ExtractFileDir(Application.ExeName);
		with  R do
		begin
			SetWndSize(1058,748); 
			NewTable(6 ,6);
      Lines[0].Select;
			CombineCell;
      Lines[0].LineHeight := 80;
			SetCellLines(false,false,false,false,1,1,1,1);
      Cells[0,0].CellText := '支票112';
			SetCellAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_VCENTER);

			cf := Tfont.Create;
			cf.Name := '楷体_GB2312';
			cf.Size := 22;
			cf.style :=cf.style+ [fsBold];
      SetSelectedCellFont(cf);
			for j:=0 to 0 do
			begin
//       Cells[1,j].CellText := dbgrid1.Columns[j].FieldName;
         Cells[2,j].CellText := '#T1.'+'Zname';
         ClearSelect;
         SetCellFocus(2,j);
         {
         if dbgrid1.DataSource.DataSet.FieldByName(dbgrid1.Columns[j].FieldName) is tnumericField then
         begin
           SetCellAlign(2, 1);
           SetCellDispFormt('0,.00');
         end
         else
           SetCellAlign(3, 1);
        end;
          }
        Lines[1].LineHeight := 40;
        ClearSelect;
        SelectLine(1);
        SetCellAlign(1, 1);

        cf.Name := '仿宋_GB2312';
        cf.Size := 16;
        cf.Style:=[];
        SetSelectedCellFont(cf);
        SetCellColor(clRed, clWhite);

        Cells[3,0].CellText := '支票' ;
        Cells[3,3].CellText := '`SumAll(4)' ;
        ClearSelect;
        SetCellFocus(3,3);
        SetCellAlign(2, 1);
        SetCellDispFormt('0,.00');


        ClearSelect;
        SelectLine(4);
        SetCellLines(false,false,false,false,1,1,1,1);
        CombineCell;
        Cells[4,0].CellText := '`PageNum/' ;
        SetCellAlign(1, 1);

        ClearSelect;
        SelectLines(1,3);
        SetCellFocus(4,0);
        cf.Name := 'MS Serif';
        cf.Size :=10;
        cf.Style:=[];
        GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
        SetCellFont(CellFont);

        ClearSelect;
        SelectLine(5);
        SetCellLines(false,false,false,false,1,1,1,1);
        CombineCell;
        Cells[5,0].CellText := '@T2.ZName' ;

        Lines[5].LineHeight := 250;
        SaveToFile(strFileDir+'\'+'xxx.ept');
        ResetContent;
        cf.Free;
		end;          

		R.ReportFile:=strFileDir+'\'+'xxx.ept';
		R.PrintPreview(true);
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



procedure TReportTest.TestCombineHorz;
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
procedure TReportTest.TestCombineVertical;
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

procedure TReportTest.TestOwner;
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
initialization
  RegisterTests('Framework Suites',[TReportTest.Suite,TReportUITest.Suite]);
end.
