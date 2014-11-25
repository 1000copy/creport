
unit REportDemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, StdCtrls, Db, DBTables, Grids, DBGrids,printers, Buttons,
  ExtCtrls, ExtDlgs,uReportRunTime,osservice;

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
    SpeedButton1: TSpeedButton;
    CheckBox1: TCheckBox;
    ReportControl1: TReportControl;
    SaveDialog1: TSaveDialog;
    SpeedButton3: TSpeedButton;
    Button1: TButton;
    btnVertSplite: TSpeedButton;
    btnVertSplit2: TSpeedButton;
    btnCombine: TSpeedButton;
    btnRect: TSpeedButton;
    btnCombineVert: TSpeedButton;
    btnCombineHorz: TSpeedButton;
    procedure Button4Click(Sender: TObject);
    //procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnVertSpliteClick(Sender: TObject);
    procedure btnVertSplit2Click(Sender: TObject);
    procedure btnCombineClick(Sender: TObject);
    procedure btnRectClick(Sender: TObject);
    procedure btnCombineVertClick(Sender: TObject);
    procedure btnCombineHorzClick(Sender: TObject);
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
  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+'creport_demo.ept';//??态??写模??????选creport_demo1.ept
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

procedure TCReportDemoForm.SpeedButton3Click(Sender: TObject);
var j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
begin
    ReportRunTime1.ClearDataSet;
    ReportRunTime1.SetDataSet('t1',dataform.table1);
    ReportRunTime1.SetDataSet('t2',dataform.table2);
 		strFileDir := ExtractFileDir(Application.ExeName);
		with  ReportControl1 do
		begin
			SetWndSize(1058,748); 
			NewTable(dbgrid1.Columns.Count ,6);
      Lines[0].Select;
			CombineCell;
      Lines[0].LineHeight := 80;
			SetCellLines(false,false,false,false,1,1,1,1);
      Cells[0,0].CellText := '支票112';
			SetCellAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_VCENTER);

			cf := Tfont.Create;
			cf.Name := '楷体_GB2312';
			cf.Size := 22;
			cf.style :=cf.style+ [fsBold];
      SetSelectedCellFont(cf);
			for j:=0 to dbgrid1.Columns.Count -1 do
			begin
       Cells[1,j].CellText := dbgrid1.Columns[j].FieldName;
       Cells[2,j].CellText := '#T1.'+dbgrid1.Columns[j].FieldName;
			 ClearSelect;
			 SetCellFocus(2,j);

			 if dbgrid1.DataSource.DataSet.FieldByName(dbgrid1.Columns[j].FieldName) is tnumericField then
			 begin
			   SetCellAlign(2, 1);
			   SetCellDispFormt('0,.00');
			 end
			 else
			   SetCellAlign(3, 1);
			end;

      Lines[1].LineHeight := 40;
			ClearSelect;
			SelectLine(1);
			SetCellAlign(1, 1);

			cf.Name := '仿宋_GB2312';
			cf.Size := 16;
			cf.Style:=[];
			SetSelectedCellFont(cf);
			SetCellColor(clRed, clWhite);

      Cells[3,0].CellText := '支票' ;
      Cells[3,3].CellText := '`SumAll(4)' ;
			ClearSelect;
			SetCellFocus(3,3);
			SetCellAlign(2, 1);
			SetCellDispFormt('0,.00');


			ClearSelect;
			SelectLine(4);
			SetCellLines(false,false,false,false,1,1,1,1);
			CombineCell;
      Cells[4,0].CellText := '`PageNum/' ;
			SetCellAlign(1, 1);

			ClearSelect;
			SelectLines(1,3);
			SetCellFocus(4,0);
			cf.Name := 'MS Serif';
			cf.Size :=10;
			cf.Style:=[];
			GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
			SetCellFont(CellFont);

			ClearSelect;
			SelectLine(5);
			SetCellLines(false,false,false,false,1,1,1,1);
			CombineCell;
      Cells[5,0].CellText := '@T2.Loel' ;

      Lines[5].LineHeight := 250;
			SaveToFile(strFileDir+'\'+'xxx.ept');
			ResetContent;
			cf.Free;
		end;

		dataform.Table1.DisableControls;
		ReportRunTime1.ReportFile:=strFileDir+'\'+'xxx.ept';
		ReportRunTime1.PrintPreview(true); 
		dataform.Table1.EnableControls;
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
procedure TCReportDemoForm.btnCombineClick(Sender: TObject);
var Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
begin
    R := ReportControl1;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(2 ,2);
    r.AddSelectedCell(r.Cells[0,0]);
    r.AddSelectedCell(r.Cells[1,0]);
    r.CombineCell;
    r.SaveToFile(Filename);
    r.ResetContent;
    ReportRunTime1.EditReport(FileName);

end;

procedure TCReportDemoForm.btnRectClick(Sender: TObject);
var
   w : WindowsOS;
   r1,r2,r3 :TRect;
begin
    w := WindowsOS.Create ;
    r1.Left := 0 ;
    r1.Right := 1;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    r3 := w.UnionRect(r1,r2);

    r1.Left := 0 ;
    r1.Right := 4;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    r3 := w.IntersectRect(r1,r2);

    r1.Left := 0 ;
    r1.Right := 1;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    r3 := w.IntersectRect(r1,r2);
    r1.Left := 0 ;
    r1.Right := 1;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;

    w.contains(r1,r2);

    r1.Left := 0 ;
    r1.Right := 4;
    r1.top:= 0 ;
    r1.Bottom := 1;

    r2.Left := 3 ;
    r2.Right := 4;
    r2.top:= 0 ;
    r2.Bottom := 1;
    w.contains(r1,r2);

end;

procedure TCReportDemoForm.btnCombineVertClick(Sender: TObject);
var Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
begin
 R := ReportControl1;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(2 ,2);
    // 垂直合并后，Cell并不减少
    r.Cells[0,0].Select;
    r.Cells[1,0].Select;
    r.CombineCell ;
    assert(R.Lines[0].FCells.count = 2);
    assert(R.Lines[1].FCells.count = 2);
    assert(R.Cells[0,0].OwnerCell = nil);
    assert(R.Cells[1,0].OwnerCell = R.Cells[0,0]);
    assert(R.Cells[0,0].FCellsList.Count = 1);
    assert(R.Cells[0,0].FCellsList[0]  = R.Cells[1,0]);
    r.SaveToFile(Filename);
    r.ResetContent;
    ReportRunTime1.EditReport(FileName);
end;

procedure TCReportDemoForm.btnCombineHorzClick(Sender: TObject);
var Filename : string;
    ThisCell:TReportCell;
    R: TReportControl;
begin
 R := ReportControl1;
    FileName := ExtractFileDir(Application.ExeName) + '\btnVertSplite.ept';
    r.SetWndSize(1058,748);
    r.NewTable(2 ,2);
    // 水平合并后，Cell确实减少
    r.ClearSelect ;
    r.Cells[0,0].Select;
    r.Cells[0,1].Select;
    r.CombineCell;
    assert(R.Lines[0].FCells.count = 1);
    r.SaveToFile(Filename);
    r.ResetContent;
    ReportRunTime1.EditReport(FileName);
end;

end.
