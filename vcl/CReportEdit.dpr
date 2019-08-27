program CReportEdit;

uses
  Forms,
  Border in 'Border.pas' {BorderForm},
  Color in 'Color.pas' {ColorForm},
  diagonal in 'diagonal.pas' {DiagonalForm},
  NewDialog in 'NewDialog.pas' {frmNewTable},
  vsplit in 'vsplit.pas' {VSplitForm},
  about in 'about.pas' {AboutBox},
  Creport in 'Creport.pas' {CreportForm},
  margin in 'margin.pas' {MarginForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCreportForm, CreportForm);
  Application.CreateForm(TBorderForm, BorderForm);
  Application.CreateForm(TColorForm, ColorForm);
  Application.CreateForm(TDiagonalForm, DiagonalForm);
  Application.CreateForm(TfrmNewTable, frmNewTable);
  Application.CreateForm(TVSplitForm, VSplitForm);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(TMarginForm, MarginForm);
  Application.Run;
end.

