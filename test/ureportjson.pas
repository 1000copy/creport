unit ureportjson;

interface

uses
  ureport,ureportcontrol,
  ReportRunTime,
  // sys
  forms,
  messages,
  Classes,    ujson,
   Math,DBClient,  db,  DBTables,  Graphics, dialogs,   Windows,  SysUtils,  TestFramework,Printers;

type

  TReportJsonTest = class(TTestCase)
  private


  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestJson;
    procedure TestCell;
    procedure Test;
    procedure TestLine;
    procedure Viewfile;
  end;

implementation

procedure TReportJsonTest.SetUp;
begin
  inherited;

end;

procedure TReportJsonTest.TearDown;
begin
  inherited;

end;
const reportjson = '"ReportScale":100,"PageWidth":1123,"PageHeight":794,"LeftMargin":77,"TopMargin":77,"RightMargin":38,"BottomMargin":58,"NewTable":1,"DataLine":2000,"TablePerPage":1';
const cell0json =  '{"CellIndex":0,"CellLeft":77'+
',"CellWidth":504,"LeftMargin":5,"LeftLine":1,"LeftLineWidth":1,"TopLine":1,"TopLineWidth":1,'+
'"RightLine":1,"RightLineWidth":1,"BottomLine":1,"BottomLineWidth":1,"Diagonal":0,"TextColor" :0,'+
'"BackGroundColor" :16777215,"HorzAlign":0,"VertAlign":1,"CellText":"","Bmpyn":0}';

const cell1json =  '{"CellIndex":1,"CellLeft":77'+
',"CellWidth":504,"LeftMargin":5,"LeftLine":1,"LeftLineWidth":1,"TopLine":1,"TopLineWidth":1,'+
'"RightLine":1,"RightLineWidth":1,"BottomLine":1,"BottomLineWidth":1,"Diagonal":0,"TextColor" :0,'+
'"BackGroundColor" :16777215,"HorzAlign":0,"VertAlign":1,"CellText":"","Bmpyn":0}';

procedure TReportJsonTest.Test;
var r : TReportControl;a:string;
    j : json;
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
    j := Json.create(r.toJson());
    try
    j.parse;
    check(100=j._int('ReportScale',100));
    j.locateArray('Lines');
    check(2=j.getCurrentArrayLength );
    j.locateObject(1); // second line
    j.locateArray('Cells');
    check(2=j.getCurrentArrayLength );
    j.locateObject(0); // first cell
    check(77=j._int('CellLeft',77) );
    check(''=j._string('CellText') );
    finally
    j.free;
    end;
end;
procedure TReportJsonTest.Viewfile;
var r : TReportControl;a:string;
    j : json;sl:TStringList;
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
    j := Json.create(r.toJson());
      sl := TStringList.create;
          try

      sl.Text := r.toJson();
      sl.SaveToFile('remember.me.txt');
    finally
    sl.free;
    end;
end;
procedure TReportJsonTest.TestLine;
var r : TReportControl;
const s = '{"CellLeft":0}';
var j : json;
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
        j := Json.create(r.LineList.Items[0].toJson());
    try
    j.parse;
    j.locateArray('Cells');
    check(2=j.getCurrentArrayLength );
    j.locateObject(0); // first cell
    check(77=j._int('CellLeft',77) );
    check(''=j._string('CellText') );
    finally
    j.free;
    end;

end;
procedure TReportJsonTest.TestCell;
var r : TReportControl;var j:string;
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
    j := TReportCell(r.LineList.Items[0].FCells[0]).toJson();
    check(cell0json = j,j);
end;
procedure TReportJsonTest.TestJson;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  var a:string;
  op : Json;
begin
    a := '{"PageWidth":1,"lines":[{"lineTop":10,"lineIndex":5,"cells":[{"CellIndex":1}]}]}';
    c := 0 ;
    op := Json.create(a);
    op.parse;
    check(op._int('PageWidth',1) = 1);
    op.locateArray('lines');
    // line
    op.locateObject(0);
    check( op._int('lineTop',10) = 10) ;
    check(op._int('lineIndex',5) = 5) ;
    // cell
    op.locateArray('cells');
    op.locateObject(0);
    check(1 = op._int('CellIndex',1));
    op.free;
end;

initialization
  RegisterTests('RitaRestart',[
      TReportJsonTest.Suite
  ]);
end.
