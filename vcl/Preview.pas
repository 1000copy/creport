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
    btnFirst: TSpeedButton;
    btnLast: TSpeedButton;
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
    procedure btnFirstClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure RCMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure EditEptkClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
  private
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

procedure TPreviewForm.btnFirstClick(Sender: TObject);
begin
  GoFirstPage;
end;


procedure TPreviewForm.btnLastClick(Sender: TObject);
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
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := RC.ReportScale -10;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

end;

procedure TPreviewForm.FormCreate(Sender: TObject);
begin
  // disable template
  Self.PrintBtn.Visible := False;
  height:=550;
  width:= 715;
  PageCount := 1;
  CurrentPage := 1;
  GoPage(1);
end;

procedure TPreviewForm.SpeedButton4Click(Sender: TObject);
begin

  RC.FreeEdit;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := RC.ReportScale + 10;
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
  RC.ReportScale := 100;
end;

procedure TPreviewForm.SpeedButton3Click(Sender: TObject); 
begin
  DoFit();
end;


procedure TPreviewForm.DoFit();
begin
  RC.FreeEdit;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := RC.ZoomRate(Self.ScrollBox1.Height,self.ScrollBox1.Width);
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);
end;

procedure TPreviewForm.EditEptkClick(Sender: TObject);
begin
  TCreportForm.EditReport(filename.Caption);
  // why RR is nil ?
  RR.updatepage;
  GoFirstPage;
end;



procedure TPreviewForm.PrintBtnClick(Sender: TObject);
begin
//  SpeedButton2.Enabled:=True;
//  TReportRunTime(Owner).Print(false);
//  SpeedButton2.Enabled:=false;
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
  fn : string;
  nPrevScale: Integer;
  procedure RuleApply;
  begin
    if CurrentPage >= PageCount then
    begin
      NextPageBtn.Enabled := False;
      btnLast.enabled := false;
      btnFirst.Enabled := True;
      PrevPageBtn.Enabled := True;
    end;
    if CurrentPage <= 1 then
    begin
      PrevPageBtn.Enabled := False;
      NextPageBtn.Enabled := True;
      btnLast.enabled := True;
      btnFirst.Enabled := False;
    end;
  end;
begin
  RuleApply  ;
  nPrevScale := RC.ReportScale;
  SetPage;
  LockWindowUpdate(Handle);
  fn := osservice.PageFileName(CurrentPage) ;
  RC.LoadFromFile(fn);
  RC.ReportScale := nPrevScale;
  LockWindowUpdate(0);
  RuleApply ;
end;
procedure TPreviewForm.ReloadPageFile(CurrentPage:Integer);
begin
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


