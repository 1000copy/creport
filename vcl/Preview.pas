unit Preview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, ExtCtrls, Buttons, StdCtrls, Spin, ComCtrls,ReportRunTime;

type
  TPreviewForm = class(TForm)
    StatusBar1: TStatusBar;
    ScrollBox1: TScrollBox;
    ReportControl1: TReportControl;
    filename: TLabel;
    Panel1: TPanel;
    PrevPageBtn: TSpeedButton;
    NextPageBtn: TSpeedButton;
    CloseBtn: TSpeedButton;
    But1: TSpeedButton;
    But2: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Bevel1: TBevel;
    Bevel3: TBevel;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    EditEptk: TSpeedButton;
    Panel2: TPanel;
    Panel3: TPanel;
    PrintBtn: TSpeedButton;
    procedure ScrollBox1Resize(Sender: TObject);
    procedure NextPageBtnClick(Sender: TObject);
    procedure PrevPageBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure But1Click(Sender: TObject);
    procedure But2Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  //  procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ReportControl1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure EditEptkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
  private
     zoomxxx:integer;
     // LCJ : 最佳缩放比例
    procedure DoFit;
    procedure CreateSlaves;
    procedure FreeSlaves;
    procedure GoLastPage;
    procedure NextPage;
    procedure PrevPage;
    procedure ReloadPageFile(CurrentPage: Integer);
    procedure GoPage(CurrentPage: Integer);
    { Private declarations }
  public
    { Public declarations }
    PageCount: Integer;
    CurrentPage: Integer;
    DataNameFilst:Tlist;

    procedure GoFirstPage;
    procedure PrintFile(strFileName: string);
    procedure SetPreviewMode(bPreview: Boolean);
    function RR:TReportRuntime;
  end;

var
  PreviewForm: TPreviewForm;

implementation

uses margin, REPmess
     , Creport,About,Border,vsplit,Color,diagonal,NewDialog; // add  

{$R *.DFM}

procedure TPreviewForm.ScrollBox1Resize(Sender: TObject);
begin

///////////////////////////// add  
  if ClientRect.Right > ReportControl1.Width + 20 then
    ReportControl1.Left := (ClientRect.Right - ReportControl1.Width-20) div 2
  else
    ReportControl1.Left := 23;

   if ((height-110-ReportControl1.Height) div 2)+10 >10 then
      ReportControl1.top:= ((height-110-ReportControl1.Height) div 2)+10
   else
     ReportControl1.top:=10;
//////////////////////////
end;

procedure TPreviewForm.NextPageBtnClick(Sender: TObject);
begin
  NextPage;
end;


procedure TPreviewForm.PrevPageBtnClick(Sender: TObject);
begin
  PrevPage;
end;


procedure TPreviewForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TPreviewForm.PrintFile(strFileName: string);
begin
  ReportControl1.LoadFromFile(strFileName);
  ReportControl1.PrintIt;
end;

procedure TPreviewForm.SetPreviewMode(bPreview: Boolean);
begin
  ReportControl1.IsPreview := bPreview;
  ReportControl1.Refresh;
end;

procedure TPreviewForm.But1Click(Sender: TObject);
begin
  GoFirstPage;
end;


procedure TPreviewForm.But2Click(Sender: TObject);
begin
  GoLastPage;
end;


procedure TPreviewForm.SpeedButton2Click(Sender: TObject);
begin
   SpeedButton2.Enabled:=Not TReportRunTime(Owner).CancelPrint;
end;

procedure TPreviewForm.SpeedButton5Click(Sender: TObject);
begin
  //add  
  ReportControl1.FreeEdit;
  zoomxxx:=zoomxxx-10;
  ShowWindow(ReportControl1.Handle, SW_HIDE);
  ReportControl1.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(ReportControl1.Handle, SW_SHOW);

end;

procedure TPreviewForm.FormCreate(Sender: TObject);
var
  strFileDir: TFileName;
begin
  height:=550;
  width:= 715;
  PageCount := 1;
  CurrentPage := 1;
  zoomxxx:=75;
  strFileDir := ExtractFileDir(Application.ExeName);
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\1.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\1.tmp');

  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  SpeedButton3.OnClick(sender);

end;

procedure TPreviewForm.SpeedButton4Click(Sender: TObject);
begin

  ReportControl1.FreeEdit;
  zoomxxx:=zoomxxx+10;
  ShowWindow(ReportControl1.Handle, SW_HIDE);
  ReportControl1.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(ReportControl1.Handle, SW_SHOW);

end;

procedure TPreviewForm.SpeedButton1Click(Sender: TObject);
begin
  if tReportRunTime(owner).shpreview  then
     GoFirstPage;
  DoFit();
end;


procedure TPreviewForm.ReportControl1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  zoomxxx:=100;
end;





procedure TPreviewForm.FormResize(Sender: TObject);
var z1,z2:integer;
begin

 
////////////////////////////////

  zoomxxx:=ReportControl1.ZoomRate(Height,Width,110,170);
 ///////////////////////////////////////////////////
  ShowWindow(ReportControl1.Handle, SW_HIDE);
  ReportControl1.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(ReportControl1.Handle, SW_SHOW);

end;

procedure TPreviewForm.SpeedButton3Click(Sender: TObject); 

begin
  DoFit();
end;


procedure TPreviewForm.DoFit();

begin
  ReportControl1.FreeEdit;  
  zoomxxx := ReportControl1.ZoomRate(Height,Width,110,170);
  ShowWindow(ReportControl1.Handle, SW_HIDE);
  ReportControl1.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(ReportControl1.Handle, SW_SHOW);

end;
procedure TPreviewForm.CreateSlaves;
begin
  Application.CreateForm(TCreportform,Creportform);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(TBorderform,Borderform );
  Application.CreateForm(TColorform,Colorform );
  Application.CreateForm(Tdiagonalform,diagonalform);
  Application.CreateForm(TfrmNewTable,frmNewTable);
  Application.CreateForm(Tvsplitform,vsplitform);
end;
procedure TPreviewForm.FreeSlaves;
begin
  Application.CreateForm(TCreportform,Creportform);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(TBorderform,Borderform );
  Application.CreateForm(TColorform,Colorform );
  Application.CreateForm(Tdiagonalform,diagonalform);
  Application.CreateForm(TfrmNewTable,frmNewTable);
  Application.CreateForm(Tvsplitform,vsplitform);
end;
procedure TPreviewForm.EditEptkClick(Sender: TObject);
begin
  CreateSlaves;

  Creportform.ReportControl1.LoadFromFile(filename.Caption);
  Creportform.Caption:=filename.Caption;

  Creportform.Thefile :=Filename.Caption;
  Creportform.savefilename := Filename.Caption;

  Creportform.showmodal;
  RR.updatepage;
  But1.OnClick(Sender); 
  FreeSlaves ;
end;

procedure TPreviewForm.FormActivate(Sender: TObject);
begin


  ReportControl1.AllowPreviewEdit:=EditEptk.Visible; //add lzl 如果充许编辑模板则可编辑单元格否则不行。

end;

procedure TPreviewForm.PrintBtnClick(Sender: TObject);
begin
  SpeedButton2.Enabled:=True;
  TReportRunTime(Owner).Print(false);
  SpeedButton2.Enabled:=false;

end;

function TPreviewForm.RR: TReportRuntime;
begin
  Result := TReportRunTime(owner)
end;
procedure TPreviewForm.GoFirstPage;
begin
  CurrentPage:= 1 ;
  GoPage(CurrentPage);
end;

procedure TPreviewForm.GoLastPage;
begin
  CurrentPage:= PageCount ;
  GoPage(PageCount);
end;
procedure TPreviewForm.PrevPage;
begin
  if CurrentPage <= 1 then
    Exit;
  CurrentPage := CurrentPage - 1;
  GoPage(CurrentPage);
end;

procedure TPreviewForm.NextPage;
begin
  if CurrentPage >= PageCount then
    Exit;
  CurrentPage := CurrentPage + 1;
  GoPage(currentPage);
end;
procedure TPreviewForm.GoPage(CurrentPage:Integer);
var
  nPrevScale: Integer;
  procedure RuleApply;
  begin
    if CurrentPage >= PageCount then
    begin
      NextPageBtn.Enabled := False;
      but2.enabled := false;
      PrevPageBtn.Enabled := True;
      but1.Enabled := True;
    end;
    if CurrentPage <= 1 then
    begin
      PrevPageBtn.Enabled := False;
      but1.enabled := false;
      NextPageBtn.Enabled := True;
      but2.Enabled := true;
    end;
  end;
begin
  RuleApply  ;
  nPrevScale := ReportControl1.ReportScale;

  StatusBar1.Panels[0].Text := format('第%d/%d页',[CurrentPage,PageCount]);

  LockWindowUpdate(Handle);

  ReloadPageFile(CurrentPage);

  ReportControl1.ReportScale := nPrevScale;
  LockWindowUpdate(0);
  RuleApply ;

end;
procedure TPreviewForm.ReloadPageFile(CurrentPage:Integer);
var
  strFileDir: TFileName;
begin
   strFileDir := ExtractFileDir(Application.ExeName); // + '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp');
end;

end.


