
unit REportDemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, StdCtrls, Db, DBTables, Grids, DBGrids,printers, Buttons,
  ExtCtrls, ExtDlgs,uReportRunTime,osservice, DBClient;

type
  TCReportDemoForm = class(TForm)
    DBGrid1: TDBGrid;
    ReportRunTime1: TReportRunTime;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    opbm1: TOpenPictureDialog;
    CheckBox1: TCheckBox;
    ReportControl1: TReportControl;
    SaveDialog1: TSaveDialog;
    SpeedButton3: TSpeedButton;
    Button1: TButton;
    btnVertSplite: TSpeedButton;
    btnVertSplit2: TSpeedButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    ClientDataSet1: TClientDataSet;
    procedure Button4Click(Sender: TObject);
    //procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnVertSpliteClick(Sender: TObject);
    procedure btnVertSplit2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CReportDemoForm: TCReportDemoForm;


  implementation

uses Data;

{$R *.DFM}


procedure TCReportDemoForm.Button4Click(Sender: TObject);
begin
close;
end;


procedure TCReportDemoForm.Button5Click(Sender: TObject);
begin
  ReportRunTime1.ClearDataset ;
  ReportRunTime1.SetDataSet('t1',dataform.table1);
  ReportRunTime1.SetDataSet('t2',dataform.table2);
  dataform.Table1.DisableControls;
  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+'creport_demo.ept';//??̬??дģ??????ѡcreport_demo1.ept
  ReportRunTime1.Setvarvalue('jgtw','1');
  ReportRunTime1.Setvarvalue('head','2');
  ReportRunTime1.Setvarvalue('name','3');
  ReportRunTime1.PrintPreview(true);
  dataform.Table1.EnableControls;
end;

procedure TCReportDemoForm.Button3Click(Sender: TObject);
begin
  dataform.Table1.DisableControls;
  ReportRunTime1.ClearDataset ;
  ReportRunTime1.SetDataSet('t1',dataform.table1);
  ReportRunTime1.SetDataSet('t2',dataform.table2);

  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+'creport_demo.ept';
  ReportRunTime1.Setvarvalue('jgtw','1');
  ReportRunTime1.Setvarvalue('head','2');
  ReportRunTime1.Setvarvalue('name','3');
  ReportRunTime1.Print(true);
  dataform.Table1.EnableControls;
end;

procedure TCReportDemoForm.FormCreate(Sender: TObject);
begin
  dataform.table1.open;
  dataform.table2.open;
end;





procedure TCReportDemoForm.CheckBox1Click(Sender: TObject);
begin
if CheckBox1.Checked then
  ReportRunTime1.AddSpace:=true
else
  ReportRunTime1.AddSpace:=false;

end;

procedure TCReportDemoForm.FormPaint(Sender: TObject);
begin
  CheckBox1.Checked:= ReportRunTime1.AddSpace;   
end;

procedure TCReportDemoForm.Button1Click(Sender: TObject);
var strFileDir : string;
begin
  strFileDir := ExtractFileDir(Application.ExeName);
  self.ReportRunTime1.EditReport(strFileDir+'\'+'xxx.ept');

end;

procedure TCReportDemoForm.btnVertSpliteClick(Sender: TObject);
var j:integer;
    CellFont: TLogFont;
    cf: TFont;
    Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
begin
    R := ReportControl1;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(3 ,2);
    r.Lines[0].Select;
    r.CombineCell;
    ThisCell := ReportControl1.Cells[0,0] ;
    ReportControl1.DoVertSplitCell(ThisCell,4);
    r.UpdateLines;
    r.SaveToFile(Filename);
    r.ResetContent;
    ReportRunTime1.EditReport(FileName);
end;

procedure TCReportDemoForm.btnVertSplit2Click(Sender: TObject);
var Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
begin
    R := ReportControl1;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(3 ,2);
    r.AddSelectedCell(r.Cells[0,0]);
    r.AddSelectedCell(r.Cells[1,0]);
    r.CombineCell;
    ThisCell := ReportControl1.Cells[0,0] ;
    ReportControl1.DoVertSplitCell(ThisCell,4);
    r.UpdateLines;
    r.SaveToFile(Filename);
    r.ResetContent;
    ReportRunTime1.EditReport(FileName);
end;
end.
