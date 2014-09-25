// create ������
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
  okset:boolean;//�Ƿ�ȷ�������ø��ı�־
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
  ReportControl1.LoadFromFile(filename.Caption); //װ��ģ�������޸�ҳ���ֽ��
  MarginRect := ReportControl1.GetMargin;
  LeftMargin.Value := MarginRect.Left;
  TopMargin.Value := MarginRect.Top;
  RightMargin.Value := MarginRect.Right;
  BottomMargin.Value := MarginRect.Bottom;

      prDeviceMode;
      with Devmode^ do //���ô�ӡֽ  ������
      begin
        dmFields:=dmFields or DM_PAPERSIZE;
        dmPapersize:=FprPageNo;
        dmFields:=dmFields or DM_ORIENTATION;
        dmOrientation:=FprPageXy; //1Ϊ����,2Ϊ����

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

  ReportControl1.ResetContent;//����ڲ��еı������
  okset:=true;
end;

procedure TMarginForm.SpeedButton2Click(Sender: TObject);
begin
  If PrinterSetupDialog1.Execute Then begin
{    cp_pgw:=0;
    ReportControl1.CalcWndSize;//  �����û�ѡ���ֽ��ȷ�������ڵĴ�С���Ըô��ڽ������á�
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

