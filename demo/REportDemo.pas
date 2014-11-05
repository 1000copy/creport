//??ӭʹ?ã??ɶ?????????
unit REportDemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, StdCtrls, Db, DBTables, Grids, DBGrids,printers, Buttons,
  ExtCtrls, ExtDlgs;

type
  TCReportDemoForm = class(TForm)
    DBGrid1: TDBGrid;
    ReportRunTime1: TReportRunTime;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    opbm1: TOpenPictureDialog;
    SpeedButton1: TSpeedButton;
    CheckBox1: TCheckBox;
    ReportControl1: TReportControl;
    SaveDialog1: TSaveDialog;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure Button4Click(Sender: TObject);
    //procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
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
  ReportRunTime1.SetDataSet('t1',dataform.table1);
  ReportRunTime1.SetDataSet('t2',dataform.table2);
  dataform.Table1.DisableControls;
  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+'creport_demo.ept';//??̬??дģ??????ѡcreport_demo1.ept
  ReportRunTime1.Setvarvalue('jgtw','???λ:Ԫ');
  ReportRunTime1.Setvarvalue('head','********************ͳ?Ʊ?');
  ReportRunTime1.Setvarvalue('name','??λ??*********');
  ReportRunTime1.PrintPreview(true); //true??????ʾԤ??????ʾ?Ǵ?ӡ??????
  dataform.Table1.EnableControls;
end;

procedure TCReportDemoForm.Button3Click(Sender: TObject);
begin

  dataform.Table1.DisableControls;
  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+'creport_demo.ept';//??̬??дģ??????ѡcreport_demo1.ept
  ReportRunTime1.Setvarvalue('jgtw','???λ:Ԫ');
  ReportRunTime1.Setvarvalue('head','********************ͳ?Ʊ?');
  ReportRunTime1.Setvarvalue('name','??λ??*********');
  ReportRunTime1.Print(false); //false ????ѡ????ӡҳ,true??ֱ?Ӵ?ӡ
  dataform.Table1.EnableControls;
end;

procedure TCReportDemoForm.FormCreate(Sender: TObject);
begin
dataform.table1.open;
dataform.table2.open;
  ReportRunTime1.SetDataSet('t1',dataform.table1);
  ReportRunTime1.SetDataSet('t2',dataform.table2);

end;





procedure TCReportDemoForm.SpeedButton2Click(Sender: TObject);
begin
  ReportRunTime1.prdbgrid:=dbgrid1;  //ֻ֧?ִ?TDbGrid?????? dbgrid
  ReportRunTime1.previewDbGrid(self.Name);

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

procedure TCReportDemoForm.SpeedButton3Click(Sender: TObject);
var j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
begin
    ReportRunTime1.SetDataSet('t1',dataform.table1);
    ReportRunTime1.SetDataSet('t2',dataform.table2);
 		strFileDir := ExtractFileDir(Application.ExeName);
		with  ReportControl1 do
		begin
			SetWndSize(1058,748); 
			NewTable(dbgrid1.Columns.Count ,6);

			SetCellSFocus(0,0,0,dbgrid1.Columns.Count-1);
			CombineCell;
			setLineHegit(0,80);
			SetCellLines(false,false,false,false,1,1,1,1);
			SetCallText(0,0,'֧Ʊ');
			SetCellAlign(1, 1);

			cf := Tfont.Create;
			cf.Name := '����_GB2312';
			cf.Size := 22;
			cf.style :=cf.style+ [fsBold];

			GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
			SetCellFont(CellFont);

			for j:=0 to dbgrid1.Columns.Count -1 do
			begin
			 SetCallText(1,j,dbgrid1.Columns[j].FieldName);
			 SetCallText(2,j,'#T1.'+dbgrid1.Columns[j].FieldName);

			 RemoveAllSelectedCell;
			 SetCellFocus(2,j);//

			 if dbgrid1.DataSource.DataSet.FieldByName(dbgrid1.Columns[j].FieldName) is tnumericField then
			 begin
			   SetCellAlign(2, 1);
			   SetCellDispFormt('0,.00');
			 end
			 else
			   SetCellAlign(3, 1);
			end;
			setLineHegit(1,40);  

			RemoveAllSelectedCell;
			SetCellSFocus(1,0,1,dbgrid1.Columns.Count-1);
			SetCellAlign(1, 1);

			cf.Name := '����_GB2312';
			cf.Size := 16;
			cf.Style:=[];
			GetObject(cf.Handle, SizeOf(CellFont), @CellFont);

			SetCellFont(CellFont);
			SetCellColor(clRed, clWhite);

			SetCallText(3,0,'֧Ʊ');
			SetCallText(3,3,'`SumAll(4)');

			RemoveAllSelectedCell;
			SetCellFocus(3,3);
			SetCellAlign(2, 1);
			SetCellDispFormt('0,.00');


			RemoveAllSelectedCell;
			SetCellSFocus(4,0,4,dbgrid1.Columns.Count-1);
			SetCellLines(false,false,false,false,1,1,1,1);
			CombineCell;
			SetCallText(4,0,'`PageNum/');
			SetCellAlign(1, 1);

			RemoveAllSelectedCell;
			SetCellSFocus(1,0,3,dbgrid1.Columns.Count-1);
			SetCellFocus(4,0);
			cf.Name := 'MS Serif';
			cf.Size :=10;
			cf.Style:=[];
			GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
			SetCellFont(CellFont);

			RemoveAllSelectedCell;
			SetCellSFocus(5,0,5,dbgrid1.Columns.Count-1);
			SetCellLines(false,false,false,false,1,1,1,1);
			CombineCell;
			SetCallText(5,0,'@T2.Loel');
			setLineHegit(5,250);

			SaveToFile(strFileDir+'\'+'xxx.ept');
			ResetContent;
			cf.Free;
		end;

		dataform.Table1.DisableControls;
		ReportRunTime1.ReportFile:=strFileDir+'\'+'xxx.ept';
		ReportRunTime1.PrintPreview(true); 
		dataform.Table1.EnableControls;
end;
end.
