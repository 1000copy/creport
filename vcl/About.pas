unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tfrm_About = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Image6: TImage;
    Label5: TLabel;
    Image7: TImage;
    Label6: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_About: Tfrm_About;

implementation

{$R *.DFM}

procedure Tfrm_About.Button1Click(Sender: TObject);
begin
   Close;
end;

end.
