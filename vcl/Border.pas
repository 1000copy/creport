
unit Border;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Spin;

type
  TBorderForm = class(TForm)
    GroupBox1: TGroupBox;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    BottomLine: TCheckBox;
    RightLine: TCheckBox;
    TopLine: TCheckBox;
    LeftLine: TCheckBox;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BorderForm: TBorderForm;

implementation

{$R *.DFM}

procedure TBorderForm.SpeedButton1Click(Sender: TObject);
begin
   LeftLine.Checked:=True;
   TopLine.Checked:=True;
   RightLine.Checked:=True;
   BottomLine.Checked:=True;
end;

procedure TBorderForm.SpeedButton2Click(Sender: TObject);
begin
   LeftLine.Checked:=False;
   TopLine.Checked:=False;
   RightLine.Checked:=False;
   BottomLine.Checked:=False;
end;

end.
