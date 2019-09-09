unit ujson2rita;

interface

uses
  // user
  ureport,ureportcontrol,
 ujson,TestFramework,sysutils,classes,forms;

type
  TCell = class
  public
    cellLeft : Integer;
    cellIndex :Integer;
  end;
  TLine = class
  public
    cells : array of TCell;
    lineTop : Integer;
    lineIndex :Integer;
  end;
  TReport = class
  public
    lines : array of TLine;
    PageWidth : Integer;
    PageHeight : Integer;
    Scale : Integer;
  end;

  TJsonToRita = class(TTestCase)
  private

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReverseObject;
    procedure TestJsonFile;
    procedure TestJsonFile2Report;

end;

implementation

{ TRitaRestartTest }

procedure TJsonToRita.SetUp;
begin
  inherited;

end;

procedure TJsonToRita.TearDown;
begin
  inherited;

end;

procedure TJsonToRita.TestJsonFile2Report;
  var a:string;
    sl : TStringList;
    report : TReportControl;
begin
    report := TReportControl.create(Application.MainForm);
    report.Visible := false;
    report.loadFromJson('remember.me.txt');
    check(report.ReportScale = 100,inttostr(report.ReportScale));
    check(report.LineList.Count = 2);
    check(report.Lines[0].CellCount = 2);
    check(report.Lines[1].CellCount = 2);
end;


procedure TJsonToRita.TestJsonFile;
  var a:string;

//    arr : TJsonArray;
    op : Json;
    sl : TStringList;
begin
    sl := TStringList.create;
    sl.LoadFromFile('remember.me.txt');
    a := sl.Text;
    op := Json.create(a);
    op.parse;
    check(op._int('ReportScale') = 100);
    sl.free;
end;


procedure TJsonToRita.TestReverseObject;
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
end;


initialization
  RegisterTests('Json2Rita',[
      TJsonToRita.Suite
  ]);
end.
