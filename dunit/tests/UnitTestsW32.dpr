program UnitTestsW32;

uses
  SysUtils,
  Forms,
  UnitTestFramework in 'UnitTestFramework.pas',
  TestFramework in '..\src\TestFramework.pas',
  TestExtensions in '..\src\TestExtensions.pas',
  GUITestRunner in '..\src\GUITestRunner.pas',
  TextTestRunner in '..\src\TextTestRunner.pas',
  GUITesting in '..\src\GUITesting.pas';

{$R *.res}


begin
  if FindCmdLineSwitch('text-mode', ['-','/'], true) then
    TextTestRunner.RunRegisteredTests(rxbHaltOnFailures)
  else
  begin
    Application.Initialize;
    Application.Title := 'DUnit Tests';
    TGUITestRunner.RunRegisteredTests;
  end;
end.

