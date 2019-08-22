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
    Rc : TReportControl;
    t1 ,t2: TClientDataset;
    strFileDir:string;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure preview;
    procedure pageCount;
    procedure drawtext;
    procedure dyndrawtext;
    procedure drawtext1;
    procedure print;
    procedure sum;

  end;


implementation

procedure TReportRunTimeTest.pageCount;
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
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
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
    R:TReportControl;
begin
    R:=TReportControl.Create(Application.MainForm);
//    r.Visible := false;
//    r.CalcWndSize;
    R.loadfromjson('1.tmp.json');
    r.free;
//    ShowWindow(R.Handle, SW_SHOW);
end;
procedure TReportRunTimeTest.drawtext1;
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
    R:TReportControl;
begin
    R:=TReportControl.Create(Application.MainForm);
//    r.Visible := false;
//    r.CalcWndSize;
    R.loadfromjson('temp\1.tmp.json');
    r.free;
//    ShowWindow(R.Handle, SW_SHOW);
end;
procedure TReportRunTimeTest.dyndrawtext;
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
    R:TReportControl;
    line:TReportLine;
    cell :TReportCell;
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
procedure TReportRunTimeTest.preview;
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
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
    R.PrintPreview();
    r.free;
end;
procedure TReportRunTimeTest.SetUp;
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
begin
    inherited;
    t1 := TClientDataset.Create(nil);
    t1.FieldDefs.Add('f1',ftString,20,true);
    t1.FieldDefs.Add('f2',ftString,20,true);
    t2 := TClientDataset.Create(nil);
    t2.FieldDefs.Add('f1',ftString,20,true);
    t1.CreateDataSet;
    t2.CreateDataSet;
    strFileDir := ExtractFileDir(Application.ExeName);
end;

procedure TReportRunTimeTest.sum;
var i,j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
    R:TReportRunTime;
    t1 ,t2: TClientDataset;
    F : TStringField;
begin
  R:=TReportRunTime.Create(Application.MainForm);
  try
      R.Visible := true;
      t1 := TClientDataset.Create(nil);
      t1.FieldDefs.Add('f1',ftString,20,true);
      t1.FieldDefs.Add('f2',ftString,20,true);
      t2 := TClientDataset.Create(nil);
      t2.FieldDefs.Add('f1',ftString,20,true);
      t1.CreateDataSet;
      t2.CreateDataSet;
      R.SetData(t1,t2);
      t1.Open;
      t2.Open;
      for I:= 0 to 100 do
        t1.AppendRecord([I,(cos(I)*1000)]);
      t2.AppendRecord([2]);
      strFileDir := ExtractFileDir(Application.ExeName);
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
        Cells[3,1].CellText := 'SumAll(#T1.'+t1.FieldDefs[1].Name+')';
        SaveToJson(strFileDir+'\'+'2.json');
        ResetContent;
        r.UpdateLines;
        r.Invalidate;
      end;
      R.ReportFile:=strFileDir+'\'+'2.json';
      R.PrintPreview();    
    finally
      T1.free;
      T2.Free;
    end;
end;

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
