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
    DBGrid2: TDBGrid;
    Button1: TButton;
    Button2: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    CheckBox1: TCheckBox;
    SpeedButton3: TSpeedButton;
    ReportControl1: TReportControl;
    SaveDialog1: TSaveDialog;
    procedure Button4Click(Sender: TObject);
    //procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
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

procedure TCReportDemoForm.Button1Click(Sender: TObject);
var Fpicture:Tpicture;
    FBmp:TBitmap;
begin
  if opbm1.Execute then
  begin
    Fpicture:=Tpicture.Create;
    Fpicture.LoadFromFile(opbm1.filename);
    fbmp:=TBitmap.Create;
    if not (Fpicture.Graphic is Ticon) then
      fbmp.Assign(Fpicture.Graphic)
    else
    begin
      fbmp.Width := Fpicture.Icon.Width;
      fbmp.Height := Fpicture.Icon.Height;
      fbmp.Canvas.Draw(0, 0, Fpicture.Icon );
    end;
    dataform.Table1.Edit;
    dataform.Table1.FieldByName('bm').Assign(fbmp);
    dataform.Table1.post;
    Fpicture.Free;
    fbmp.Free;
  end;
end;

procedure TCReportDemoForm.Button2Click(Sender: TObject);
var Fpicture:Tpicture;
    FBmp:TBitmap;
begin
  if opbm1.Execute then
  begin
    Fpicture:=Tpicture.Create;
    Fpicture.LoadFromFile(opbm1.filename);
    fbmp:=TBitmap.Create;
    if not (Fpicture.Graphic is Ticon) then
      fbmp.Assign(Fpicture.Graphic)
    else
    begin
      fbmp.Width := Fpicture.Icon.Width;
      fbmp.Height := Fpicture.Icon.Height;
      fbmp.Canvas.Draw(0, 0, Fpicture.Icon );
    end;
    dataform.Table2.Edit;
    dataform.Table2.FieldByName('loel').Assign(fbmp);
    dataform.Table2.post;
    Fpicture.Free;
    fbmp.Free;
  end;
end;

procedure TCReportDemoForm.SpeedButton1Click(Sender: TObject);
//var i:integer;
//    l1,l2:Tstringlist;
begin
{
l1:=Tstringlist.Create;
l2:=Tstringlist.Create;
for i:=0 to dbgrid1.Columns.Count -1 do
begin
  l1.Add(dbgrid1.Columns[i].Title.caption);
  l2.Add(dbgrid1.Columns[i].fieldname);
end;
}
  ReportRunTime1.prdbgrid:=dbgrid1;  //ֻ֧?ִ?TDbGrid?????? dbgrid
  ReportRunTime1.previewDbGrid(self.Name);
end;

procedure TCReportDemoForm.SpeedButton2Click(Sender: TObject);
begin
ReportRunTime1.prdbgrid:=dbgrid2;
ReportRunTime1.previewDbGrid(self.name);

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
   strFileDir := ExtractFileDir(Application.ExeName);
with  ReportControl1 do
begin
   SetWndSize(1058,748);// ????ֽ?Ŵ?С

   NewTable(dbgrid1.Columns.Count ,6);// ????????

   SetCellSFocus(0,0,0,dbgrid1.Columns.Count-1);//ѡȡ0??
   CombineCell;   //?ϲ?0?е?Ԫ??
   setLineHegit(0,80); //?趨0?еĸ߶?
   SetCellLines(false,false,false,false,1,1,1,1); //ȥ????????
   SetCallText(0,0,'??00??????????֧ͳ?Ʊ?');  //??0?е?????
   SetCellAlign(1, 1);//??ѡ???е????־???

   cf := Tfont.Create;
   cf.Name := '????_GB2312';
   cf.Size := 22;
   cf.style :=cf.style+ [fsBold];
   //cf.style:=cf.style+ [fsItalic];//б??
   //cf.style:=cf.style+ [fsunderline];//?»???
   GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
   SetCellFont(CellFont); //?趨????

   for j:=0 to dbgrid1.Columns.Count -1 do //???ֶ???????ϸ???ֶ?
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
   setLineHegit(1,40); //?趨??2?еĸ߶?

   RemoveAllSelectedCell;//ȡ??ѡ?е?Ԫ??
   SetCellSFocus(1,0,1,dbgrid1.Columns.Count-1);//ѡ????1?н??в???
   SetCellAlign(1, 1);//??ѡ???е????־???

   cf.Name := '????_GB2312';
   cf.Size := 16;
   cf.Style:=[];
   GetObject(cf.Handle, SizeOf(CellFont), @CellFont);

   SetCellFont(CellFont);
   SetCellColor(clRed, clWhite);  //?׵׺???

   SetCallText(3,0,'?ϼ?');
   SetCallText(3,3,'`SumAll(4)'); //ȷ??Ҫȡ?ϼ????ĵ?Ԫ??

   RemoveAllSelectedCell;
   SetCellFocus(3,3);//ѡ????1?н??в???
   SetCellAlign(2, 1);
   SetCellDispFormt('0,.00');


   RemoveAllSelectedCell;
   SetCellSFocus(4,0,4,dbgrid1.Columns.Count-1); //ѡ??????һ??
   SetCellLines(false,false,false,false,1,1,1,1); //ȥ????????
   CombineCell;                                   //?ϲ???Ԫ??
   SetCallText(4,0,'`PageNum/');                  //????????Ϊ"???/?ҳ"??ʽ??ҳ??
   SetCellAlign(1, 1);                            //????

   RemoveAllSelectedCell;//ȡ??ѡ?е?Ԫ??
   SetCellSFocus(1,0,3,dbgrid1.Columns.Count-1);//ѡ????1?н??в???
   SetCellFocus(4,0);//ѡ????1?н??в???
   cf.Name := 'MS Serif';
   cf.Size :=10;
   cf.Style:=[];
   GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
   SetCellFont(CellFont);

   RemoveAllSelectedCell;//ȡ??ѡ?е?Ԫ??
   SetCellSFocus(5,0,5,dbgrid1.Columns.Count-1);//ѡ????1?н??в???
   SetCellLines(false,false,false,false,1,1,1,1); //ȥ????????
   CombineCell;                                   //?ϲ???Ԫ??
   SetCallText(5,0,'@T2.Loel');                  //????????Ϊ"???/?ҳ"??ʽ??ҳ??
   setLineHegit(5,250); //?趨??5?еĸ߶?

   SaveToFile(strFileDir+'\'+'xxx.ept');
   ResetContent;
   cf.Free;
end;
   //Ԥ??
   dataform.Table1.DisableControls;
   ReportRunTime1.ReportFile:=strFileDir+'\'+'xxx.ept';
   ReportRunTime1.PrintPreview(true); //true??????ʾԤ??????ʾ?Ǵ?ӡ??????
   dataform.Table1.EnableControls;

end;
end.
