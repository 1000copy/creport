
unit margin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin, uReport,printers;

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
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarginForm: TMarginForm;
implementation

{$R *.DFM}
 

// Margin ,Confirm Button,or Save Button
procedure TMarginForm.SpeedButton2Click(Sender: TObject);
begin
  If PrinterSetupDialog1.Execute Then begin
//     okset:=true;
  end
  else
//    okset:=false;

end;

end.

