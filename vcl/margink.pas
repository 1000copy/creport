// create ¿Ó‘Û¬◊
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
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
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

procedure TMarginkForm.FormCreate(Sender: TObject);
begin

 // NewTableBox.Checked := True;
 // LineCountEdit.Value := 32767;
end;

procedure TMarginkForm.SpeedButton2Click(Sender: TObject);
begin
  //If PrinterSetupDialog1.Execute Then
  //begin
   // cp_pgw:=0;
   // Creportform.ReportControl1.CalcWndSize;
  //end;
  PrinterSetupDialog1.Execute;
end;

procedure TMarginkForm.FormActivate(Sender: TObject);
begin
      prDeviceMode;
      with Devmode^ do //…Ë÷√¥Ú”°÷Ω  ¿Ó‘Û¬◊
      begin
        dmFields:=dmFields or DM_PAPERSIZE;
        dmPapersize:=FprPageNo;
        dmFields:=dmFields or DM_ORIENTATION;
        dmOrientation:=FprPageXy;

        dmPaperLength:=fpaperLength;
        dmPaperWidth:=fpaperWidth;
      end;

end;

end.
