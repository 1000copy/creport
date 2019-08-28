unit uprintpaper;

interface

uses
  // user
  cc,
  uHornCartesian,
  osservice,
  ureport,
  ReportRunTime,creport,forms,
  // sys
  messages,
  Classes,
   Math,DBClient,  db,  DBTables,  Graphics,  Windows,  SysUtils,  TestFramework,Printers;

type

  TReportPaperTest = class(TTestCase)
  private
    R:TReportRunTime;
    t1 ,t2: TClientDataset;
    strFileDir:string;
    procedure makereport;


  protected
    procedure SetUp; override;
    procedure TearDown; override;
    {$WARNINGS OFF}
  published
  {$WARNINGS ON}
    procedure var1;
    procedure paper;
  end;


implementation


procedure TReportPaperTest.paper;
var FPageSize,FPageOrientation,fpaperLength,fpaperWidth:Integer;
begin
      R.Visible := false;
      with  R do
      begin
        // 设置是无效的
        R.PrintPaper.SetPaper(osservice.A3,osservice.PORTRAIT,0,0);
        R.PrintPaper.GetPaper(FPageSize,FPageOrientation,fpaperLength,fpaperWidth);
        check(osservice.A4 = FpageSize);
        check(osservice.LANDSCAPE = FPageOrientation);
      end;
end;

procedure TReportPaperTest.SetUp;
var i:integer;

begin
    inherited;
    t1 := TClientDataset.Create(nil);
    t1.FieldDefs.Add('f1',ftString,20,true);
    t1.FieldDefs.Add('f2',ftFloat);
    t2 := TClientDataset.Create(nil);
    t2.FieldDefs.Add('f1',ftString,20,true);
    t1.CreateDataSet;
    t2.CreateDataSet;
    R:=TReportRunTime.Create(Application.MainForm);
    R.SetData(t1,t2);
      t1.Open;
      t2.Open;
      for I:= 0 to 50 do
        t1.AppendRecord([I,(cos(I)*1000)]);
      t2.AppendRecord([2]);
    strFileDir := ExtractFileDir(Application.ExeName);
end;
procedure TReportPaperTest.makereport;
var j:integer;
    strFileDir:string;
begin
      R.Visible := false;
      with  R do
      begin
        CalcWndSize;
        NewTable(2 ,4);
        Lines[0].Select;
        CombineCell;
        Cells[0,0].CellText := 'bill';
        for j:=0 to t1.FieldDefs.Count -1  do
        begin
           Cells[1,j].CellText := t1.FieldDefs[j].Name;
           Cells[2,j].CellText := '#T1.'+t1.FieldDefs[j].Name;
        end;
        Cells[3,1].CellText := '`SUMALL(1)';
        SaveToJson(strFileDir+'\'+'2.json');
        ResetContent;
      end;
      R.ReportFile:=strFileDir+'\'+'2.json';
end;

procedure TReportPaperTest.var1;
var i:integer;
begin
      makereport();
      with  R do
      begin
//        visible := true;
        Cells[0,0].CellText := '`DATETIME';
        Cells[1,0].CellText := '`DATE';
        Cells[1,1].CellText := '`TIME';
      end;
      t1.EmptyDataSet;
      for I:= 0 to 1 do
        t1.AppendRecord([I,(cos(I)*1000)]);
      r.PrintPreview;
end;
procedure TReportPaperTest.TearDown;
begin
  inherited;
    T1.free;
    T2.Free;
end;

initialization
  RegisterTests('paper',[
      TReportPaperTest.Suite
  ]);
end.
