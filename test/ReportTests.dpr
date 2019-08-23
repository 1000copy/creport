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
  osservice in '..\lib\osservice.pas',
  uHornCartesian in '..\lib\uHornCartesian.pas',
  RitaRestart in 'RitaRestart.pas',
  ritaToJson in 'ritaToJson.pas',
  FastMMMemLeakMonitor in '..\dunit\src\FastMMMemLeakMonitor.pas',
  CC in '..\lib\CC.pas',
  UnitTestFramework in 'UnitTestFramework.pas',
  ujson in '..\lib\ujson.pas',
  ureportjson in 'ureportjson.pas',
  ujson2rita in 'ujson2rita.pas',
  ustringtest in 'ustringtest.pas',
  uruntime in 'uruntime.pas';

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

