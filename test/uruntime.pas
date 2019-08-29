unit uruntime;



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

  TReportRunTimeTest = class(TTestCase)
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
    procedure preview;
    procedure pageCount;
    procedure drawtext;
    procedure dyndrawtext;
    procedure drawtext1;
    procedure print;
    procedure sum1;
    procedure tablehead;
    procedure var1;
    procedure averror;
    procedure pagenum;
    procedure pagenumIfWithSumline;
    procedure pagenumIfWithSumline1;
    procedure printit;

  end;


implementation

procedure TReportRunTimeTest.pageCount;
var i:integer;
begin
    R:=TReportRunTime.Create(Application.MainForm);
    r.Visible := false;
    r.CalcWndSize;
    R.SetData(t1,t2);
    t1.Open;
    t2.Open;
    for I:= 0 to 100 do begin
        t1.AppendRecord([I,(cos(I)*1000)]);
        t2.AppendRecord([2]);
    end;
    R.ReportFile:=strFileDir+'\'+'1.json';
    check(4=R.calcPageCount,inttostr(R.calcPageCount));
    r.free;
end;
procedure TReportRunTimeTest.drawtext;
var R:TReportControl;
begin
    R:=TReportControl.Create(Application.MainForm);
    R.loadfromjson('1.tmp.json');
    r.free;
end;
procedure TReportRunTimeTest.drawtext1;
var
    R:TReportControl;
begin
    R:=TReportControl.Create(Application.MainForm);
    R.loadfromjson('temp\1.tmp.json');
    r.free;
end;
procedure TReportRunTimeTest.dyndrawtext;
var R:TReportControl;
begin
    R:=TReportControl.Create(Application.MainForm);
    r.CalcWndSize;
    R.NewTable(2,2);
    TReportCell(R.Lines[0].FCells[0]).celltext:='bill';
    ShowWindow(R.Handle, SW_SHOW);
    r.free;
end;
procedure TReportRunTimeTest.print;
var i:integer;
   form : TForm ;
begin
    form := TForm.create(nil);
    R:=TReportRunTime.Create(form);
    r.Visible := false;
    r.CalcWndSize;
    R.SetData(t1,t2);
    t1.Open;
    t2.Open;
    for I:= 0 to 100 do begin
        t1.AppendRecord([I,(cos(I)*1000)]);
        t2.AppendRecord([2]);
    end;
    R.ReportFile:=strFileDir+'\'+'1.json';
    R.Print();
    form.free;
end;
procedure TReportRunTimeTest.printit;
var i:integer;
   form : TForm ;
begin
    r.Visible := false;
    r.CalcWndSize;
    R.NewTable(2,2);
    R.savetoJson(strFileDir+'\'+'1.json');
    R.ReportFile:=strFileDir+'\'+'1.json';
    R.PrintIt();
end;
procedure TReportRunTimeTest.preview;
var i:integer;
begin
    makereport;
    R.PrintPreview();
    r.free;
end;
procedure TReportRunTimeTest.SetUp;
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
procedure TReportRunTimeTest.makereport;
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
procedure TReportRunTimeTest.sum1;
var i:integer;
begin
      makereport();
      t1.EmptyDataSet;
      for I:= 0 to 1 do
        t1.AppendRecord([I,(cos(I)*1000)]);
      R.PrintPreview();
      check(format('%2n',[r.Summer.GetSumAll(1)]) ='1,540.30', format('%2n',[r.Summer.GetSumAll(1)]));
end;

procedure TReportRunTimeTest.var1;
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
procedure TReportRunTimeTest.averror;
begin
      makereport();
      with  R do
      begin
//        visible := true;
        Cells[0,0].CellText := '`DATETIME';
      end;
      t1.EmptyDataSet;
      r.PrintPreview;
end;
procedure TReportRunTimeTest.tablehead;
begin
      makereport();
      with  R do
      begin
        r.ResetContent;
        NewTable(2,2);
        visible := true;
        Cells[0,0].CellText := '@t2.f1';
      end;
      t1.EmptyDataSet;
      r.PrintPreview;
end;
procedure TReportRunTimeTest.pagenum;
begin
      makereport();
      with  R do
      begin
        //Cells[0,0].CellText := '@t2.f1';
        visible := true ;
        Cells[3,0].Select;
        r.VSplitCell(2);
        Cells[3,0].CellText := '`PAGENUM';
        Cells[3,1].CellText := '`PAGENUM/';
        Cells[3,2].CellText := '`PAGENUM-';
      end;
      r.PrintPreview;
end;

procedure TReportRunTimeTest.pagenumIfWithSumline;
begin
      makereport();
      with  R do
      begin
        //Cells[0,0].CellText := '@t2.f1';
        visible := true ;
        Cells[3,0].CellText := '`SUMALL(1)';
        Cells[3,1].CellText := '';
        AddLine;
        Cells[4,0].CellText := '`PAGENUM';
        Cells[4,1].CellText := '`PAGENUM/';
      end;
      r.PrintPreview;
end;
procedure TReportRunTimeTest.pagenumIfWithSumline1;
begin
      makereport();
      with  R do
      begin
        //Cells[0,0].CellText := '@t2.f1';
        visible := true ;
        Cells[3,0].Select;
        r.VSplitCell(2);
        Cells[3,0].CellText := '`PAGENUM';
        Cells[3,1].CellText := '`PAGENUM/';
        Cells[3,2].CellText := '`SUMALL(1)';
      end;
      r.PrintPreview;
end;
//ISVar GetVar  `DATE `TIME
procedure TReportRunTimeTest.TearDown;
begin
  inherited;
    T1.free;
    T2.Free;    
end;

initialization
  RegisterTests('runtime',[
      TReportRuntimeTest.Suite
  ]);
end.
