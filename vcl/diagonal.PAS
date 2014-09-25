unit diagonal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TDiagonalForm = class(TForm)
    GroupBox2: TGroupBox;
    LeftDiagonal1: TCheckBox;
    LeftDiagonal2: TCheckBox;
    LeftDiagonal3: TCheckBox;
    RightDiagonal3: TCheckBox;
    RightDiagonal2: TCheckBox;
    RightDiagonal1: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DiagonalForm: TDiagonalForm;

implementation

{$R *.DFM}

end.
