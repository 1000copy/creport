unit Preview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, ExtCtrls, Buttons, StdCtrls, Spin, ComCtrls,uReportRunTime;

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
    { Private declarations }
  public
    { Public declarations }
    PageCount: Integer;
    CurrentPage: Integer;
    DataNameFilst:Tlist;
    procedure updatepage;
    procedure PrintFile(strFileName: string);
    procedure SetPreviewMode(bPreview: Boolean);
  end;

var
  PreviewForm: TPreviewForm;

implementation

uses margin, REPmess
     , Creport,About,Border,vsplit,Color,diagonal,NewDialog; // add 李泽伦

{$R *.DFM}

procedure TPreviewForm.ScrollBox1Resize(Sender: TObject);
begin

///////////////////////////// add 李泽伦
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
var
  nPrevScale: Integer;
  strFileDir: TFileName;
begin
  nPrevScale := ReportControl1.ReportScale;

  if CurrentPage >= PageCount then
    Exit;

  CurrentPage := CurrentPage + 1;

  if CurrentPage >= PageCount then
  begin
    NextPageBtn.Enabled := False;
    but2.enabled := false;
  end;

  PrevPageBtn.Enabled := True;
  but1.enabled := true;
  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  LockWindowUpdate(Handle);

  strFileDir := ExtractFileDir(Application.ExeName); // + '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp');

  ReportControl1.ReportScale := nPrevScale;
;
  LockWindowUpdate(0);
end;

procedure TPreviewForm.PrevPageBtnClick(Sender: TObject);
var
  nPrevScale: Integer;
  strFileDir: TFileName;
begin
  nPrevScale := ReportControl1.ReportScale;

  if CurrentPage <= 1 then
    Exit;

  CurrentPage := CurrentPage - 1;

  if CurrentPage <= 1 then
  begin
    PrevPageBtn.Enabled := False;
    but1.enabled := false;
  end;

  NextPageBtn.Enabled := True;
  but2.Enabled := true;

  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  LockWindowUpdate(Handle);

  strFileDir := ExtractFileDir(Application.ExeName); // + '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp');

  ReportControl1.ReportScale := nPrevScale;

  LockWindowUpdate(0);
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
var
  nPrevScale: Integer;
  strFileDir: TFileName;
begin

  nPrevScale := ReportControl1.ReportScale;
  CurrentPage := 1;

  PrevPageBtn.Enabled := False;
  but1.Enabled := False;

  NextPageBtn.Enabled := True;
  but2.Enabled := true;
  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  LockWindowUpdate(Handle);

  strFileDir := ExtractFileDir(Application.ExeName); // + '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp');

  ReportControl1.ReportScale := nPrevScale;
  LockWindowUpdate(0);
end;
// next page
procedure TPreviewForm.But2Click(Sender: TObject);
var
  nPrevScale: Integer;
  strFileDir: TFileName;
begin
  nPrevScale := ReportControl1.ReportScale;

  CurrentPage := PageCount;

  NextPageBtn.Enabled := False;
  but2.Enabled := false;
  PrevPageBtn.Enabled := True;
  but1.Enabled := True;
  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  LockWindowUpdate(Handle);

  strFileDir := ExtractFileDir(Application.ExeName); // + '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp');

  ReportControl1.ReportScale := nPrevScale;
  LockWindowUpdate(0);
end;

procedure TPreviewForm.SpeedButton2Click(Sender: TObject);
begin
   SpeedButton2.Enabled:=Not TReportRunTime(Owner).CancelPrint;
end;

procedure TPreviewForm.SpeedButton5Click(Sender: TObject);
begin
  //add 李泽伦
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
  strFileDir := ExtractFileDir(Application.ExeName); //+ '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\1.tmp') then //临时打印文件
    ReportControl1.LoadFromFile(strFileDir + 'Temp\1.tmp');

  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  SpeedButton3.OnClick(sender);

end;

procedure TPreviewForm.SpeedButton4Click(Sender: TObject);
begin
  //add 李泽伦
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
     But1.OnClick(Sender); //预览第一页
  DoFit();
end;


procedure TPreviewForm.ReportControl1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  zoomxxx:=100;
end;


procedure TPreviewForm.updatepage;
var
  nPrevScale: Integer;
  strFileDir: TFileName;
begin
  tReportRunTime(owner).updatepage;

  nPrevScale := ReportControl1.ReportScale;
  if PageCount>= CurrentPage then
     CurrentPage := CurrentPage
  else
     CurrentPage :=1;

  if CurrentPage = 1 then
  begin
     PrevPageBtn.Enabled := False;
     NextPageBtn.Enabled := True;
     but1.Enabled := false;
     but2.Enabled := true;
  end
  else
  begin
     PrevPageBtn.Enabled := true;
     NextPageBtn.Enabled := false;
     but1.Enabled := true;
     but2.Enabled := false;
  end;
  StatusBar1.Panels[0].Text :='第'+IntToStr(CurrentPage)+'／' +IntToStr(PageCount) +  '页';

  LockWindowUpdate(Handle);

  strFileDir := ExtractFileDir(Application.ExeName); // + '\';
  if copy(strfiledir, length(strfiledir), 1) <> '\' then strFileDir := strFileDir + '\';

  if FileExists(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp') then
    ReportControl1.LoadFromFile(strFileDir + 'Temp\' + IntToStr(CurrentPage) + '.tmp');

  ReportControl1.ReportScale := nPrevScale;
  LockWindowUpdate(0);
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
procedure TPreviewForm.EditEptkClick(Sender: TObject);   
begin
  Application.CreateForm(TCreportform,Creportform);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(TBorderform,Borderform );
  Application.CreateForm(TColorform,Colorform );
  Application.CreateForm(Tdiagonalform,diagonalform);
  Application.CreateForm(TfrmNewTable,frmNewTable);
  Application.CreateForm(Tvsplitform,vsplitform);

  Creportform.ReportControl1.LoadFromFile(filename.Caption);
  Creportform.Caption:=filename.Caption;

  Creportform.Thefile :=Filename.Caption;
  Creportform.savefilename := Filename.Caption;

  //editept:=true;
  Creportform.showmodal;
  //editept:=false;
  tReportRunTime(owner).updatepage;
  But1.OnClick(Sender); //预览第一页
  Creportform.Free;
  frm_About.Free;
  Borderform.Free;
  Colorform.Free;
  diagonalform.Free;
  frmNewTable.Free;
  vsplitform.Free;    
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

end.


