// create 李泽伦
unit margin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin, ReportControl,printers;

type
  TMarginForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    LeftMargin: TSpinEdit;
    TopMargin: TSpinEdit;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    PrinterSetupDialog1: TPrinterSetupDialog;
    ReportControl1: TReportControl;
    filename: TLabel;
    RightMargin: TSpinEdit;
    BottomMargin: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SpeedButton2: TSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
  okset:boolean;//是否确认了设置更改标志
    { Public declarations }
  end;

var
  MarginForm: TMarginForm;
implementation

{$R *.DFM}
//uses fr_prntr;
procedure TMarginForm.FormActivate(Sender: TObject);
var
  MarginRect: TRect;
  prPageXy:integer;
begin
  okset:=false;
  ReportControl1.LoadFromFile(filename.Caption); //装入模版以做修改页面或纸张
  MarginRect := ReportControl1.GetMargin;
  LeftMargin.Value := MarginRect.Left;
  TopMargin.Value := MarginRect.Top;
  RightMargin.Value := MarginRect.Right;
  BottomMargin.Value := MarginRect.Bottom;

      prDeviceMode;
      with Devmode^ do //设置打印纸  李泽伦
      begin
        dmFields:=dmFields or DM_PAPERSIZE;
        dmPapersize:=FprPageNo;
        dmFields:=dmFields or DM_ORIENTATION;
        dmOrientation:=FprPageXy; //1为纵向,2为横向

        dmPaperLength:=fpaperLength;
        dmPaperWidth:=fpaperWidth;
      end;


end;

procedure TMarginForm.BitBtn1Click(Sender: TObject);
var
  MarginRect: TRect;
begin
  cp_pgw:=0;
  ReportControl1.CalcWndSize;//

  ReportControl1.SetMargin(LeftMargin.Value,TopMargin.Value,RightMargin.Value,BottomMargin.Value);
  ReportControl1.SaveToFile(filename.Caption);

  ReportControl1.ResetContent;//清除内层中的表格数据
  okset:=true;
end;

procedure TMarginForm.SpeedButton2Click(Sender: TObject);
begin
  If PrinterSetupDialog1.Execute Then begin
{    cp_pgw:=0;
    ReportControl1.CalcWndSize;//  根据用户选择的纸来确定报表窗口的大小并对该窗口进行设置。
    ReportControl1.SaveToFile(filename.Caption);
 }   okset:=true;
  end
  else
    okset:=false;

end;

procedure TMarginForm.BitBtn2Click(Sender: TObject);
begin
okset:=false;
end;

end.

