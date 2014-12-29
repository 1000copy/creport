program creport_demo;

uses
  Forms,
  REportDemo in 'REportDemo.pas' {CReportDemoForm},
  Data in 'Data.pas' {Dataform: TDataModule},
  ReportRunTime in '..\vcl\ReportRunTime.pas',
  CC in '..\vcl\CC.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDataform, Dataform);
  Application.CreateForm(TCReportDemoForm, CReportDemoForm);
  Application.Run;
end.
