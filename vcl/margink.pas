
unit margink;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin, ReportControl,ExtCtrls;

type
  TMarginkForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LeftMargin: TSpinEdit;
    TopMargin: TSpinEdit;
    RightMargin: TSpinEdit;
    BottomMargin: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label5: TLabel;
    PrinterSetupDialog1: TPrinterSetupDialog;
    Label6: TLabel;
    SpeedButton2: TSpeedButton;
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MarginkForm: TMarginkForm;

implementation

uses creport;

{$R *.DFM}

procedure TMarginkForm.SpeedButton2Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

end.
