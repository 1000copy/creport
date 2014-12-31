unit Preview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, ExtCtrls, Buttons, StdCtrls, Spin, ComCtrls,ReportRunTime,osservice,cc;

type
  TPreviewForm = class(TForm)
    StatusBar1: TStatusBar;
    ScrollBox1: TScrollBox;
    RC: TReportControl;
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
    procedure RCMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure EditEptkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
  private
     zoomxxx:integer;
     // LCJ : ×î¼ÑËõ·Å±ÈÀý
    procedure DoFit;
    procedure GoLastPage;
    procedure NextPage;
    procedure PrevPage;
    procedure ReloadPageFile(CurrentPage: Integer);
    procedure GoPage(CurrentPage: Integer);
  public
    PageCount: Integer;
    CurrentPage: Integer;
    DataNameFilst:Tlist;

    procedure GoFirstPage;
    procedure PrintFile(strFileName: string);
    procedure SetPreviewMode(bPreview: Boolean);
    function RR:TReportRuntime;
    procedure SetPage;
    class procedure Action(ReportFile:string;FPageCount:Integer;bPreviewMode:Boolean);
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
  if ClientRect.Right > RC.Width + 20 then
    RC.Left := (ClientRect.Right - RC.Width-20) div 2
  else
    RC.Left := 23;

   if ((height-110-RC.Height) div 2)+10 >10 then
      RC.top:= ((height-110-RC.Height) div 2)+10
   else
     RC.top:=10;
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
  RC.LoadFromFile(strFileName);
  RC.PrintIt;
end;

procedure TPreviewForm.SetPreviewMode(bPreview: Boolean);
begin
  RC.IsPreview := bPreview;
  RC.Refresh;
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
  RC.FreeEdit;
  zoomxxx:=zoomxxx-10;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

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

  if FileExists( osservice.PageFileName(1)) then
    RC.LoadFromFile(osservice.PageFileName(1));
  Setpage;                                     
  SpeedButton3.OnClick(sender);                
end;

procedure TPreviewForm.SpeedButton4Click(Sender: TObject);
begin

  RC.FreeEdit;
  zoomxxx:=zoomxxx+10;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

end;

procedure TPreviewForm.SpeedButton1Click(Sender: TObject);
begin
  if tReportRunTime(owner).shpreview  then
     GoFirstPage;
  DoFit();
end;


procedure TPreviewForm.RCMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  zoomxxx:=100;
end;





procedure TPreviewForm.FormResize(Sender: TObject);
var z1,z2:integer;
begin
  zoomxxx:=RC.ZoomRate(Height,Width,110,170);
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);
end;

procedure TPreviewForm.SpeedButton3Click(Sender: TObject); 
begin
  DoFit();
end;


procedure TPreviewForm.DoFit();

begin
  RC.FreeEdit;  
  zoomxxx := RC.ZoomRate(Height,Width,110,170);
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

end;

procedure TPreviewForm.EditEptkClick(Sender: TObject);
begin
  TCreportForm.EditReport(filename.Caption);
  RR.updatepage;
  GoFirstPage;
end;

procedure TPreviewForm.FormActivate(Sender: TObject);
begin
  RC.AllowPreviewEdit:=EditEptk.Visible; 
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
  nPrevScale := RC.ReportScale;

  SetPage;
  LockWindowUpdate(Handle);
  ReloadPageFile(CurrentPage);
  RC.ReportScale := nPrevScale;
  LockWindowUpdate(0);
  RuleApply ;

end;
procedure TPreviewForm.ReloadPageFile(CurrentPage:Integer);
begin
  RC.LoadFromFile(
    osservice.PageFileName(CurrentPage)

  );
end;



procedure TPreviewForm.SetPage;
begin
  StatusBar1.Panels[0].Text :=Format(cc.PageFormat,[CurrentPage,PageCount]);
end;

class procedure TPreviewForm.Action(ReportFile:string;FPageCount:Integer;bPreviewMode:Boolean);
begin
  PreviewForm := TPreviewForm.Create(nil);
  PreviewForm.SetPreviewMode(bPreviewMode);
  PreviewForm.PageCount := FPageCount;
  PreviewForm.SetPage();
  PreviewForm.filename.Caption := ReportFile;
  PreviewForm.ShowModal;
  PreviewForm.Free;
end;

end.


