program creport_demo;

uses
  Forms,
  REportDemo in 'REportDemo.pas' {CReportDemoForm},
  Data in 'Data.pas' {Dataform: TDataModule},
  uReportRunTime in '..\vcl\uReportRunTime.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDataform, Dataform);
  Application.CreateForm(TCReportDemoForm, CReportDemoForm);
  Application.Run;
end.
