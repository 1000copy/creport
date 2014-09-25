unit NewDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TfrmNewTable = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNewTable: TfrmNewTable;

implementation

{$R *.DFM}

procedure TfrmNewTable.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
   if not (key in ['0'..'9',#8,#13]) then key:=#0 
end;

end.
