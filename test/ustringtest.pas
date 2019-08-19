unit ustringtest;

interface
uses TestFramework,ureport,forms;
type
  TStrings = class(TTestCase)
  private

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
    procedure Format;
end;
implementation

function endsWith(s:string;ext:string):boolean;
begin
  result := copy(s,length(s) - length(ext)+1,length(ext)) = ext
end;

{ TStrings }

procedure TStrings.Format;var r : TReportControl;
begin
  r := TReportControl.create(application.mainform);
  r.Visible := false;
  r.loadfromjson('C:\dcu\remember.me.txt');
  r.savetojson('C:\dcu\remember.me.txt');
end;

procedure TStrings.SetUp;
begin
  inherited;

end;

procedure TStrings.TearDown;
begin
  inherited;

end;

procedure TStrings.Test;
begin
   check(endsWith('remb.json','json'));
   check(endsWith('remb.json','.json'))
end;
initialization
  RegisterTests('String',[
    TStrings.Suite
  ]);
end.
