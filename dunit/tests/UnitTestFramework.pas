
unit UnitTestFramework;

interface

uses
  Windows,
  SysUtils,
  TestFramework;

type

  TTestTest = class(TTestCase)
  private
    fTestCount: integer;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCheck;
  end;


implementation

procedure TTestTest.SetUp;
begin
  inherited;

end;

procedure TTestTest.TearDown;
begin
  inherited;

end;

procedure TTestTest.TestCheck;
var
  s1, s2, s3 :WideString;
begin
  Check(true, 'Check');
  CheckEquals(1, 1,                   'CheckEquals    Integer');
  CheckNotEquals(1, 2,                'CheckNotEquals Integer');
  CheckEquals(1.0, 1.1, 0.15,         'CheckEquals    Double');
  CheckNotEquals(1.0, 1.16, 0.15,     'CheckNotEquals Double');
  CheckEqualsString('abc', 'abc',     'CheckEquals    String');
  CheckNotEqualsString('abc', 'abcd', 'CheckNotEquals String');
  CheckEquals(true, true,             'CheckEquals    Boolean');
  CheckNotEquals(true, false,         'CheckNotEquals Boolean');

  CheckEqualsBin(1, 1,                'CheckEqualsBin  Longword');
  CheckNotEqualsBin(1, 2,             'CheckNotEqualsBin  Longword');
  CheckEqualsHex(1, 1,                'CheckEqualsHex  Longword');
  CheckNotEqualsHex(1, 2,             'CheckNotEqualsHex  Longword');

  CheckNull(TObject(nil),        'CheckNull');
  CheckNotNull(TObject(self),    'CheckNotNull object');
  CheckSame(TObject(self), self, 'CheckSame    object');
end;

initialization
  RegisterTests('Framework Suites',[TTestTest.Suite]);
end.
