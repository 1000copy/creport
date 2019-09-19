unit uslimjson;


interface
uses TestFramework,ureport,forms,ureportcontrol,ujson,sysutils,windows,graphics,classes;
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
    procedure dojsonloaded;
    procedure TestSlaveCells;
    procedure TestSlaveCells2Str;
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
 color : COLORREF;
begin
  color := clwhite;
  check(color = 16777215,inttostr(color));
  color := $ffffff;
  check(color = 16777215,inttostr(color));
  check($ffffff=16777215)
end;
procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   ListOfStrings.DelimitedText   := Str;
end;

procedure TJsonSlim.dojsonloaded;var row,col:integer;sl:TstringList;
const a = '1,2;3,4';
begin
  sl:=TstringList.create;
  try
     Split(',', a, sl) ;
     row := strtoint(sl.Strings[0]);
     col := strtoint(sl.Strings[1]);
   finally
     sl.Free;
   end;
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
procedure TJsonSlim.TestSlaveCells;
var rp : TReportPage;
begin
  rp := TReportPage.Create(nil);
  rp.loadFromJson('slaves.json');
  check(rp.Cells[0,0].SlaveCellsStr = '1,0;2,0',rp.Cells[0,0].CellText);
  check(rp.Cells[0,0].IsMaster = true,'false');
  check(rp.Cells[0,0].SlaveCells.count = 2,inttostr(rp.Cells[0,0].SlaveCells.count));
  rp.free;
end;
procedure TJsonSlim.TestSlaveCells2Str;
var rp : TReportPage;
begin
  rp := TReportPage.Create(nil);
  rp.loadFromJson('slaves.json');
  check(rp.Cells[0,0].CalcSlaveCellStr = '1,0;2,0',rp.Cells[0,0].CalcSlaveCellStr);
  rp.free;
end;
initialization
  RegisterTests('json.slim',[
    TJsonSlim.Suite
  ]);
end.
