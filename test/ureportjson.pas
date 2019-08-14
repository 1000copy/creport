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
        procedure Test;
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
var r : TReportControl;
const s = '{"PageWidth":100,"PageHeight":1123,"LeftMargin":794,"TopMargin":77,"RightMargin":77,"BottomMargin":38,"NewTable":58,"DataLine:1,"FTablePerPage":2000}';
begin
    r := TReportControl.Create(Application.mainform);
    r.Visible := false;
    r.CalcWndSize;
    r.NewTable(2,2);
//    check(s = r.toJson(),r.toJson())
    check('{"ReportScale":100,"Lines":[]}' = r.toJson(),r.toJson())


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
