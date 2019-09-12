unit ritaToJson;

interface

uses
  // user
 ujson,TestFramework,sysutils,classes;

type
  TCell = class
  public
    cellLeft : Integer;
    cellIndex :Integer;
    function toJson:string;
  end;
  TLine = class
  public
    cells : array of TCell;
    lineTop : Integer;
    lineIndex :Integer;
    function toJson:string;
    function addCell(cell:TCell):Boolean;
  end;
  TReport = class
  public
    lines : array of TLine;
    PageWidth : Integer;
    PageHeight : Integer;
    Scale : Integer;
    function toJson:string;
  end;

  TRitaToJson = class(TTestCase)
  private

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test1;
    procedure TestLine;
    procedure TestReverse;
    procedure TestReverseObject;
end;

implementation

{ TRitaRestartTest }

procedure TRitaToJson.SetUp;
begin
  inherited;

end;

procedure TRitaToJson.TearDown;
begin
  inherited;

end;



function TReport.toJson: string;
begin

end;


{ TCell }

function TCell.toJson: string;
begin
  result := format('{"cellLeft":%d,"cellIndex":%d}',[cellLeft,cellIndex]) ;
end;

{ TLine }

function TLine.addCell(cell: TCell): Boolean;
begin
  setlength(self.cells,length(cells)+1);
  cells[length(cells)-1] := cell;
end;

function TLine.toJson: string;
var cellsjson : string;i:integer;
    arr : array of string;
begin
   cellsjson := '';
   setlength(arr,length(cells));
   for  i := 0 to length(cells)-1 do
     cellsjson := cellsjson + cells[i].tojson +',';
   if (cellsjson[length(cellsjson)] = ',') then
       delete(cellsjson,length(cellsjson),1);
   result := format('{"lineIndex":%d,"cells":[%s]}',[lineindex,cellsjson])
end;
procedure TRitaToJson.Test1;
var c : TCell;
begin
  c := TCell.create();
  c.cellLeft := 10 ;
  c.cellIndex := 5;
  check(c.tojson() = '{"cellLeft":10,"cellIndex":5}',c.toJson)
end;
procedure TRitaToJson.TestLine;
var c : TCell;line :TLine;
begin
  c := TCell.create();
  c.cellLeft := 10 ;
  c.cellIndex := 5;
  line := TLine.create;
  line.addCell(c);
  c := TCell.create();
  c.cellLeft := 10 ;
  c.cellIndex := 5;
  line.addCell(c);
  check(line.tojson() = '{"lineIndex":0,"cells":[{"cellLeft":10,"cellIndex":5},{"cellLeft":10,"cellIndex":5}]}',line.toJson)

end;
procedure TRitaToJson.TestReverse;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  var a:string;
var r : TReport ;cc : TLine;line :TLine;s:string;
function getIntProperty(p:string;obj:TJsonObject;output:TJsonParserOutput):Integer;
var i : integer;
begin
  result := 0 ;
  for i:= 0 to length(obj)-1 do begin
    if (obj[i].key = p) and (obj[i].Value.Kind = JVKNumber) then begin
      result :=  trunc( output.Numbers[obj[i].value.Index]);
      break;
    end;
  end;
end;
function getArrayLength(p:string;obj:TJsonObject;output:TJsonParserOutput):Integer;
var i : integer;
begin
  result := 0 ;
  for i:= 0 to length(obj)-1 do begin
    if (obj[i].key = p) and (obj[i].Value.Kind = JVKArray) then begin
      result :=  length( output.Arrays[obj[i].value.Index]);
      break;
    end;
  end;
end;
function getArrayPropery(p:string;index:integer;obj:TJsonObject;output:TJsonParserOutput):TJsonArray;
var i : integer;v : TJsonValue;
begin
  result := nil ;
  for i:= 0 to length(obj)-1 do begin
    if (obj[i].key = p) and (obj[i].Value.Kind = JVKArray) then begin
      result :=  (output.Arrays[obj[i].value.Index]);
      break;
    end;
  end;
end;
function getObjectFromArray(index:integer;obj:TJsonArray;output:TJsonParserOutput):TJsonObject;
var i : integer;v : TJsonValue;
begin
      result := nil ;
      v :=  obj[index];
      if v.kind = JVKObject then
        result := output.Objects[v.Index];
end;

var cellObject : TJsonObject;arr : TJsonArray;
begin
    a := '{"PageWidth":1,"lines":[{"lineTop":10,"lineIndex":5},{"lineTop":10,"lineIndex":5}]}';
    c := 0 ;
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, a);
    for J := 0 to Length(JsonParser.Output.Errors) - 1 do
      WriteLn(JsonParser.Output.Errors[J]);
    r := TReport.create;
    r.PageWidth := getIntProperty('PageWidth',JsonParser.output.Objects[0],JsonParser.output);
    setlength(r.lines,getArrayLength('lines',JsonParser.output.Objects[0],JsonParser.output));
    arr := getArrayPropery('lines',0,JsonParser.output.Objects[0],JsonParser.output);
    cellObject := getObjectFromArray(0,arr,JsonParser.output);
    check(length(r.lines)=2);
    cc := TLine.create();
    cc.lineTop :=  getIntProperty('lineTop',cellObject,JsonParser.output);;
    cc.lineIndex := getIntProperty('lineIndex',cellObject,JsonParser.output);;
    check(r.PageWidth = 1,inttostr(r.pagewidth));
    check(cc.linetop = 10,inttostr(r.pagewidth)) ;
    check(cc.lineindex = 5,inttostr(r.pagewidth)) ;
end;

procedure TRitaToJson.TestReverseObject;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  var a:string;
var s:string;

var lineObject : TJsonObject;
//    arr : TJsonArray;
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
end;


initialization
  RegisterTests('RitaRestart',[
      TRitaToJson.Suite
  ]);
end.
