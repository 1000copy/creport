program ReportTests;

uses
  SysUtils,
  Forms,
  TestFramework in '..\dunit\src\TestFramework.pas',
  TestExtensions in '..\dunit\src\TestExtensions.pas',
  GUITestRunner in '..\dunit\src\GUITestRunner.pas',
  TextTestRunner in '..\dunit\src\TextTestRunner.pas',
  GUITesting in '..\dunit\src\GUITesting.pas',
  ReportTest in 'ReportTest.pas',
  ReportControl in '..\vcl\ReportControl.pas',
  ReportRunTime in '..\vcl\ReportRunTime.pas',
  osservice in '..\vcl\osservice.pas',
  uHornCartesian in '..\vcl\uHornCartesian.pas',
  RitaRestart in 'RitaRestart.pas',
  ritaToJson in 'ritaToJson.pas',
  FastMMMemLeakMonitor in '..\dunit\src\FastMMMemLeakMonitor.pas',
  CC in '..\vcl\CC.pas',
  UnitTestFramework in 'UnitTestFramework.pas',
  ujson in '..\vcl\ujson.pas',
  ureportjson in 'ureportjson.pas';

{$R *.res}


begin
  if FindCmdLineSwitch('text-mode', ['-','/'], true) then
//  if true then
    TextTestRunner.RunRegisteredTests(rxbHaltOnFailures)
  else
  begin
    Application.Initialize;
    Application.Title := 'Report Tests';
    TGUITestRunner.RunRegisteredTests;
  end;
end.

