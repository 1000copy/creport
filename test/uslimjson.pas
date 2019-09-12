unit uslimjson;


interface
uses TestFramework,ureport,forms,ureportcontrol,ujson,sysutils;
type
  TJsonSlim = class(TTestCase)
  private


  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestJson;
    procedure Test;
    procedure TestJson1;
    procedure TestReportLineIndex;
end;
implementation


procedure TJsonSlim.SetUp;
begin
  inherited;

end;

procedure TJsonSlim.TearDown;
begin
  inherited;

end;

procedure TJsonSlim.Test;
begin
  check(true)
end;
procedure TJsonSlim.TestJson1;
var
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  var a:string;
  op : Json;
begin

end;
procedure TJsonSlim.TestJson;
var
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  var a:string;
  op : Json;
begin
    a := '{"ReportScale":100}';
    c := 0 ;
    op := Json.create(a);
    op.parse;
    check(op._int('ReportScale',100) = 100);
    a := '{}';
    c := 0 ;
    op := Json.create(a);
    op.parse;
    check(op._int('ReportScale',100) = 100);
//    op.locateArray('lines');
//    // line
//    op.locateObject(0);
//    check( op._int('lineTop') = 10) ;
//    check(op._int('lineIndex') = 5) ;
//    // cell
//    op.locateArray('cells');
//    op.locateObject(0);
//    check(1 = op._int('CellIndex'));
//    op.free;
end;
procedure TJsonSlim.TestReportLineIndex;
var rp : TReportPage;
begin
  rp := TReportPage.Create(nil);
  rp.loadFromJson('slim.json');
  check(rp.Lines[0].Index = 0,inttostr(rp.Lines[0].Index));
  check(rp.Lines[1].Index = 1,inttostr(rp.Lines[1].Index));
  check(rp.Lines[2].Index = 2,inttostr(rp.Lines[2].Index));
  check(TReportcell(rp.Lines[0].CellList[0]).CellIndex = 0 );
  check(rp.Cells[0,0].CellIndex = 0 );
  check(rp.Cells[1,0].CellIndex = 0 );
  check(rp.Cells[1,1].CellIndex = 1 );
  rp.free;
end;
initialization
  RegisterTests('json.slim',[
    TJsonSlim.Suite
  ]);
end.
