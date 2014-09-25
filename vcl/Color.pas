unit Color;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TColorForm = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    ColorDialog1: TColorDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ColorForm: TColorForm;

implementation

{$R *.DFM}

procedure TColorForm.SpeedButton1Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
    Panel1.Font.Color := ColorDialog1.Color;

end;

procedure TColorForm.SpeedButton2Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
    Panel1.Color := ColorDialog1.Color;

end;

end.
