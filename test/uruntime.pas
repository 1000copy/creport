unit uruntime;



interface

uses
  // user
  cc,
  uHornCartesian,
  osservice,
  ureport,
  ReportRunTime,creport,
  // sys
  messages,
  Classes,
   Math,DBClient,  db,  DBTables,  Graphics,  forms,  Windows,  SysUtils,  TestFramework,Printers;

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
    procedure Reco;
    procedure pageCount;

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
    check(4=R.doPageCount,inttostr(R.doPageCount))
end;
procedure TReportRunTimeTest.Reco;
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
    R.PrintPreview(true);
end;
procedure TReportRunTimeTest.SetUp;
var i,j:integer;
    CellFont: TLogFont;
    cf: TFont;
    F : TStringField;
begin
    inherited;
    Rc := TReportControl.Create(Application.MainForm);
    rc.Visible := false;
    t1 := TClientDataset.Create(nil);
    t1.FieldDefs.Add('f1',ftString,20,true);
    t1.FieldDefs.Add('f2',ftString,20,true);
    t2 := TClientDataset.Create(nil);
    t2.FieldDefs.Add('f1',ftString,20,true);
    t1.CreateDataSet;
    t2.CreateDataSet;

    RC.Visible := False;
    strFileDir := ExtractFileDir(Application.ExeName);
    with  RC do
    begin
        calcwndsize;
        NewTable(2 ,3);
        Lines[0].Select;
        CombineCell;
        Cells[0,0].CellText := 'bill';
        for j:=0 to t1.FieldDefs.Count -1  do
        begin
        Cells[1,j].CellText := t1.FieldDefs[j].Name;
        Cells[2,j].CellText := '#T1.'+t1.FieldDefs[j].Name;
        end;
        SaveToJson(strFileDir+'\'+'1.json');
        ResetContent;
    end;
end;

procedure TReportRunTimeTest.TearDown;
begin
  inherited;
    rc.free;
    T1.free;
    T2.Free;

end;

initialization
  RegisterTests('runtime',[
      TReportRuntimeTest.Suite
  ]);
end.
