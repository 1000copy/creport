unit ureportjson;

interface

uses
  ReportControl,
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
procedure TReportJsonTest.Test;
var r : TReportControl;a:string;
const s = '"ReportScale":100,"PageWidth":1123,"PageHeight":794,"LeftMargin":77,"TopMargin":77,"RightMargin":38,"BottomMargin":58,"NewTable":1,"DataLine":2000,"TablePerPage":1';
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
    a := format('{%s,"Lines":[{"Index":0,"Cells":[{"CellIndex":0},{"CellIndex":1}]},{"Index":1,"Cells":[{"CellIndex":0},{"CellIndex":1}]}]}',[s]);
    check(a = r.toJson(),r.toJson());
end;
procedure TReportJsonTest.TestLine;
var r : TReportControl;
const s = '{"CellLeft":0}';var j:string;
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
    j := r.LineList.Items[0].toJson();
    check('{"Index":0,"Cells":[{"CellIndex":0},{"CellIndex":1}]}' = j,j);
end;
procedure TReportJsonTest.TestCell;
var r : TReportControl;
const s = '{"CellLeft":0}';var j:string;
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
    j := TReportCell(r.LineList.Items[0].FCells[0]).toJson();
    check('{"CellIndex":0}' = j,j);
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
    check(op._int('PageWidth') = 1);
    op.locateArray('lines');
    // line
    op.locateObject(0);
    check( op._int('lineTop') = 10) ;
    check(op._int('lineIndex') = 5) ;
    // cell
    op.locateArray('cells');
    op.locateObject(0);
    check(1 = op._int('CellIndex'));
    op.free;
end;

initialization
  RegisterTests('RitaRestart',[
      TReportJsonTest.Suite
  ]);
end.
