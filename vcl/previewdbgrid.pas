// create 李泽伦

unit PreviewDbGrid;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ReportControl,db,grids, DBGrids, Buttons, ExtCtrls,
  Spin;

type
  Tpreviewdbgridform = class(TForm)
    GroupBox1: TGroupBox;
    ReportControl2: TReportControl;
    ReportControl1: TReportControl;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    FN1: TSpeedButton;
    FontDialog1: TFontDialog;
    bt: TEdit;
    GroupBox2: TGroupBox;
    SpeedButton4: TSpeedButton;
    SpeedButton1: TSpeedButton;
    edit1: TLabel;
    edit2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    PrinterSetupDialog1: TPrinterSetupDialog;
    H1: TSpinEdit;
    Label1: TLabel;
    H2: TSpinEdit;
    SpeedButton2: TSpeedButton;
    edit3: TLabel;
    Label2: TLabel;
    procedure CheckBox1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FN1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
  private
    btFont: TLogFont; //标题字体 及字号
    CellFont: TLogFont; //
    zz:boolean;
    Cellcolor:integer;
    procedure pryn(yn:boolean);
    { Private declarations }
  public
    Pdbgrid:TdbGrid;
    FEptNAme:string;
    { Public declarations }
  end;

var
  previewdbgridform: Tpreviewdbgridform;

implementation
uses margink;
{$R *.dfm}

procedure Tpreviewdbgridform.CheckBox1Click(Sender: TObject);
begin
if CheckBox1.Checked then
  TReportRunTime(owner).AddSpace:=true
else
  TReportRunTime(owner).AddSpace:=false;

end;

procedure Tpreviewdbgridform.FormPaint(Sender: TObject);
begin
CheckBox1.Checked:= TReportRunTime(owner).AddSpace;

end;

procedure Tpreviewdbgridform.FormActivate(Sender: TObject);
var    strFileDir:string;
begin
 strFileDir := ExtractFileDir(Application.ExeName);
 if FileExists(strFileDir+'\'+FeptName) then
 begin
    CheckBox2.Enabled:=true;
    GroupBox1.Enabled:=false;
    GroupBox2.Enabled:=false;
 end
 else
    CheckBox2.visible:=false;
end;

procedure Tpreviewdbgridform.FN1Click(Sender: TObject);
begin

    FontDialog1.Font.Name := edit1.Font.Name;
    FontDialog1.Font.Size := edit1.Font.Size;
    FontDialog1.Font.Color:= edit1.Font.Color;
    FontDialog1.Font.Style := edit1.Font.Style;
    if FontDialog1.Execute then
    begin
      Windows.GetObject(FontDialog1.Font.Handle, SizeOf(btFont), @btFont);
      edit1.Font.Name:= FontDialog1.Font.Name;
      edit1.Font.size:= FontDialog1.Font.Size;
      edit1.Font.Color:=FontDialog1.Font.Color;
      edit1.Font.style:=FontDialog1.Font.style;
      //bt.Font.color:= FontDialog1.Font.color;
      //btcolor:=FontDialog1.Font.color;
    end;
end;

procedure Tpreviewdbgridform.SpeedButton4Click(Sender: TObject);
begin
    FontDialog1.Font.Name := edit3.Font.Name;
    FontDialog1.Font.Size := edit3.Font.Size;
    FontDialog1.Font.Color:= edit3.Font.Color;
    FontDialog1.Font.style:= edit3.Font.style;
    if FontDialog1.Execute then
    begin
      Windows.GetObject(FontDialog1.Font.Handle, SizeOf(CellFont), @CellFont);
      edit3.Font.Name:= FontDialog1.Font.Name;
      edit3.Font.size:= FontDialog1.Font.Size;
      edit3.Font.color:= FontDialog1.Font.color;
      edit3.Font.style:=FontDialog1.Font.style;
    end;
end;
procedure Tpreviewdbgridform.pryn(yn: boolean);
var j,k:integer;
   strFileDir:string;
begin
{
   if uppercase(pdbgrid.ClassName)='TDBGRIDEH' then
      k:=tdbgrideh(pdbgrid).Columns.Count
   else
      k:=pdbgrid.Columns.Count;

 strFileDir := ExtractFileDir(Application.ExeName);
 if (not FileExists(strFileDir+'\'+FeptName)) or (not CheckBox2.Checked) then
 begin
  if not zz then
  begin
   ReportControl1.Height:=1090;
   ReportControl1.Width:=748;
   cp_pgw:=0;
   ReportControl1.CalcWndSize;
  end;
   ReportControl1.NewTable(k , 4);// 

    ReportControl1.SetCellSFocus(0,0,0,k-1);//选取0行

   ReportControl1.CombineCell;   //合并0行单元格
   ReportControl1.setLineHegit(0,40); //设定0行的高度
   ReportControl1.SetCellLines(false,false,false,false,1,1,1,1); //去掉表格线
   ReportControl1.SetCallText(0,0,bt.Text);  //填0行的内容
   ReportControl1.SetCellAlign(1, 1);//将选中行的文字居中

    FontDialog1.Font.Name := edit1.Font.Name;
    FontDialog1.Font.Size := edit1.Font.Size;
    Windows.GetObject(FontDialog1.Font.Handle, SizeOf(btFont), @btFont);

   ReportControl1.SetCellFont(btFont); //设定字体
   ReportControl1.SetCellColor(edit1.Font.Color, clwhite);  //白底红字

   for j:=0 to k -1 do
   begin
   if uppercase(pdbgrid.ClassName)='TDBGRIDEH' then
   begin
     ReportControl1.SetCallText(1,j,tdbgrideh(pdbgrid).Columns[j].Title.Caption);
     ReportControl1.SetCallText(2,j,'#T1.'+tdbgrideh(pdbgrid).Columns[j].FieldName);
   end
   else
   begin
     ReportControl1.SetCallText(1,j,pdbgrid.Columns[j].Title.Caption);
     ReportControl1.SetCallText(2,j,'#T1.'+pdbgrid.Columns[j].FieldName);
   end;

     ReportControl1.RemoveAllSelectedCell;
     ReportControl1.SetCellFocus(2,j);//
   if uppercase(pdbgrid.ClassName)='TDBGRIDEH' then
   begin
     if tdbgrideh(pdbgrid).DataSource.DataSet.FieldByName(tdbgrideh(pdbgrid).Columns[j].FieldName) is tnumericField then
       ReportControl1.SetCellAlign(2, 1)
     else
       ReportControl1.SetCellAlign(1, 1);
   end
   else
   begin
     if pdbgrid.DataSource.DataSet.FieldByName(pdbgrid.Columns[j].FieldName) is tnumericField then
       ReportControl1.SetCellAlign(2, 1)
     else
       ReportControl1.SetCellAlign(1, 1);
    end;
    FontDialog1.Font.Name := edit2.Font.Name;
    FontDialog1.Font.Size := edit2.Font.Size;
    Windows.GetObject(FontDialog1.Font.Handle, SizeOf(cellFont), @cellFont);

     ReportControl1.SetCellFont(CellFont); //设定字体
     ReportControl1.SetCellColor(edit2.Font.Color, clwhite);  //

   end;
   ReportControl1.RemoveAllSelectedCell;
   ReportControl1.SetCellSFocus(1,0,1,k-1);//选取0行
   ReportControl1.SetCellAlign(1, 1);//将选中行的文字居中
   ReportControl1.SetCellFont(CellFont); //设定字体
   ReportControl1.SetCellColor(edit2.Font.Color, clwhite);  //

   ReportControl1.RemoveAllSelectedCell;
   ReportControl1.SetCellSFocus(3,0,3,k-1); //选择最后一行
   ReportControl1.SetCellLines(false,false,false,false,1,1,1,1); //去掉表格线
   ReportControl1.CombineCell;                                   //合并单元格
   ReportControl1.SetCallText(3,0,'`PageNum/');                  //本行内容为"第?/?页"样式的页码
   ReportControl1.SetCellAlign(1, 1);                            //居中
    FontDialog1.Font.Name := edit2.Font.Name;
    FontDialog1.Font.Size := edit2.Font.Size;
    Windows.GetObject(FontDialog1.Font.Handle, SizeOf(cellFont), @cellFont);

     ReportControl1.SetCellFont(CellFont); //设定字体
     ReportControl1.SetCellColor(edit2.Font.Color, clwhite);  //

   ReportControl1.SaveToFile(strFileDir+'\'+FeptName);
   ReportControl1.ResetContent;
 end;


 TReportRunTime(owner).ReportFile:=strFileDir+'\'+FeptName;

   if uppercase(pdbgrid.ClassName)='TDBGRIDEH' then
 TReportRunTime(owner).SetDataSet('T1',tdbgrideh(pdbgrid).DataSource.DataSet)
else
 TReportRunTime(owner).SetDataSet('T1',pdbgrid.DataSource.DataSet);
 if not yn then

   TReportRunTime(owner).PrintPreview(true)
 else
   TReportRunTime(owner).print(false);
}

 k:=pdbgrid.Columns.Count;

 strFileDir := ExtractFileDir(Application.ExeName);
 if (not FileExists(strFileDir+'\'+FeptName)) or (not CheckBox2.Checked) then
 begin
  if not zz then
  begin
  //SetWndSize(748,1090);// 设置纸张大小
   cp_pgw:=0;
   ReportControl1.CalcWndSize;//  选择默认的纸来确定报表窗口的大小并对该窗口进行设置。
  end;
    ReportControl1.NewTable(k , 4);// 创建一个两行两列的表

    ReportControl1.SetCellSFocus(0,0,0,k-1);//选取0行

   ReportControl1.CombineCell;   //合并0行单元格
   ReportControl1.setLineHegit(0,40); //设定0行的高度
   ReportControl1.SetCellLines(false,false,false,false,1,1,1,1); //去掉表格线
   ReportControl1.SetCallText(0,0,bt.Text);  //填0行的内容
   ReportControl1.SetCellAlign(1, 1);//将选中行的文字居中

    FontDialog1.Font.Name := edit1.Font.Name;
    FontDialog1.Font.Size := edit1.Font.Size;
    FontDialog1.Font.style := edit1.Font.style;
    Windows.GetObject(FontDialog1.Font.Handle, SizeOf(btFont), @btFont);

   ReportControl1.SetCellFont(btFont); //设定字体
   ReportControl1.SetCellColor(edit1.Font.Color, clwhite);  //白底红字

   for j:=0 to k -1 do
   begin
     ReportControl1.SetCallText(1,j,pdbgrid.Columns[j].Title.Caption);
     ReportControl1.SetCallText(2,j,'#T1.'+pdbgrid.Columns[j].FieldName);
     ReportControl1.RemoveAllSelectedCell;
     ReportControl1.SetCellFocus(2,j);//
     if pdbgrid.DataSource.DataSet.FieldByName(pdbgrid.Columns[j].FieldName) is tnumericField then
       ReportControl1.SetCellAlign(2, 1)
     else
    ReportControl1.SetCellAlign(1, 1);
   end;
   ReportControl1.RemoveAllSelectedCell;
   ReportControl1.SetCellSFocus(1,0,1,k-1);//选取1行
   ReportControl1.SetCellAlign(1, 1);//将选中行的文字居中
   FontDialog1.Font.Name := edit2.Font.Name;
   FontDialog1.Font.Size := edit2.Font.Size;
    FontDialog1.Font.style := edit2.Font.style;
   Windows.GetObject(FontDialog1.Font.Handle, SizeOf(cellFont), @cellFont);
   ReportControl1.SetCellFont(CellFont); //设定字体
   ReportControl1.SetCellColor(edit2.Font.Color, clwhite);  //

   ReportControl1.RemoveAllSelectedCell;
   ReportControl1.SetCellsFocus(3,0,3,k-1); //选择最后一行
   ReportControl1.SetCellLines(false,false,false,false,1,1,1,1); //去掉表格线
   ReportControl1.CombineCell;                                   //合并单元格
   ReportControl1.SetCallText(3,0,'`PageNum/');                  //本行内容为"第?/?页"样式的页码
   ReportControl1.SetCellAlign(1, 1); //居中
   ReportControl1.SetCellSFocus(2,0,2,k-1); //选择行

    FontDialog1.Font.Name := edit3.Font.Name;
    FontDialog1.Font.Size := edit3.Font.Size;
    FontDialog1.Font.style := edit3.Font.style;
    Windows.GetObject(FontDialog1.Font.Handle, SizeOf(cellFont), @cellFont);
    ReportControl1.SetCellFont(CellFont); //设定字体
    ReportControl1.SetCellColor(edit3.Font.Color, clwhite);  //

   ReportControl1.setLineHegit(0,h1.Value); //设定0行的高度
   ReportControl1.setLineHegit(1,h2.Value); //设定1行的高度

   ReportControl1.SaveToFile(strFileDir+'\'+FeptName);
   ReportControl1.ResetContent;
 end;


 TReportRunTime(owner).ReportFile:=strFileDir+'\'+FeptName;

 TReportRunTime(owner).SetDataSet('T1',pdbgrid.DataSource.DataSet);
 if not yn then

   TReportRunTime(owner).PrintPreview(true)
 else
   TReportRunTime(owner).print(false);

end;



procedure Tpreviewdbgridform.BitBtn2Click(Sender: TObject);
begin
pryn(true);

end;

procedure Tpreviewdbgridform.BitBtn3Click(Sender: TObject);
begin
close;

end;

procedure Tpreviewdbgridform.BitBtn1Click(Sender: TObject);
begin
pryn(false);

end;

procedure Tpreviewdbgridform.SpeedButton1Click(Sender: TObject);
var
  MarginRect: TRect;
begin
  MarginkForm := TMarginkForm.Create(Self);
  with MarginkForm do
  begin
    MarginRect := ReportControl1.GetMargin;
    LeftMargin.Value := MarginRect.Left;
    TopMargin.Value := MarginRect.Top;
    RightMargin.Value := MarginRect.Right;
    BottomMargin.Value := MarginRect.Bottom;
  end;

  if MarginkForm.ShowModal = mrOK then
  begin
    with MarginkForm do
    begin
      ReportControl1.SetMargin(LeftMargin.Value,
        TopMargin.Value,
        RightMargin.Value,
        BottomMargin.Value);
    end;
   cp_pgw:=0;
   ReportControl1.CalcWndSize;

    zz:=true;
  end;
  MarginkForm.Free;
end;

procedure Tpreviewdbgridform.FormCreate(Sender: TObject);
begin
zz:=false;
end;

procedure Tpreviewdbgridform.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
zz:=false;
end;

procedure Tpreviewdbgridform.SpeedButton2Click(Sender: TObject);
begin

    FontDialog1.Font.Name := edit2.Font.Name;
    FontDialog1.Font.Size := edit2.Font.Size;
    FontDialog1.Font.Color:= edit2.Font.Color;
    FontDialog1.Font.Style := edit2.Font.Style;
    if FontDialog1.Execute then
    begin
      Windows.GetObject(FontDialog1.Font.Handle, SizeOf(btFont), @btFont);
      edit2.Font.Name:= FontDialog1.Font.Name;
      edit2.Font.size:= FontDialog1.Font.Size;
      edit2.Font.Color:=FontDialog1.Font.Color;
      edit2.Font.style:=FontDialog1.Font.style;
      //bt.Font.color:= FontDialog1.Font.color;
      //btcolor:=FontDialog1.Font.color;
    end;

end;

procedure Tpreviewdbgridform.CheckBox2Click(Sender: TObject);
begin
if CheckBox2.Checked then
begin
    GroupBox1.Enabled:=false;
    GroupBox2.Enabled:=false;
end
else
begin
    GroupBox1.Enabled:=true;
    GroupBox2.Enabled:=true;
    bt.SetFocus;
end

end;

end.
