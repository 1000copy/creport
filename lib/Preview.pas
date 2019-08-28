unit Preview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ureport, ExtCtrls, Buttons, StdCtrls, Spin, ComCtrls,ReportRunTime,osservice,cc;

type
  TPreviewForm = class(TForm)
    StatusBar1: TStatusBar;
    ScrollBox1: TScrollBox;
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
    procedure RCMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
     // LCJ : ×î¼ÑËõ·Å±ÈÀý
    procedure DoFit;
    procedure GoLastPage;
    procedure NextPage;
    procedure PrevPage;
    procedure GoPage(CurrentPage: Integer);
    procedure SetPreviewMode();
  public
    RC: TReportRuntime;
    PageCount: Integer;
    CurrentPage: Integer;
    DataNameFilst:Tlist;

    procedure GoFirstPage;
//    procedure PrintFile(strFileName: string);
    function RR:TReportRuntime;
    procedure updateStatus;
    class procedure Action(ReportFile:string;FPageCount:Integer);
  end;

var
  PreviewForm: TPreviewForm;

implementation

//uses margin; // add

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

//procedure TPreviewForm.PrintFile(strFileName: string);
//begin
//  RC.LoadFromFile(strFileName);
//  RC.PrintIt;
//end;

procedure TPreviewForm.SetPreviewMode();
begin
  RC.IsPreview := true;
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
  RC:= TReportRuntime.create(SELF);
  // disable template
  Self.PrintBtn.Visible := False;
  height:=550;
  width:= 715;
  PageCount := 1;
  CurrentPage := 1;
  self.SetPreviewMode();
end;

procedure TPreviewForm.FormShow(Sender: TObject);
begin
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
  procedure RuleApply;
  begin
      NextPageBtn.Enabled := CurrentPage < PageCount;
      btnLast.enabled := CurrentPage < PageCount;
      btnFirst.Enabled := CurrentPage > 1;
      PrevPageBtn.Enabled := CurrentPage > 1;
  end;
begin
  updateStatus;
  RC.LoadPage(CurrentPage);
  rc.CalcWndSize;
  RC.Invalidate;
  RuleApply ;
end;



procedure TPreviewForm.updateStatus;
begin
  StatusBar1.Panels[0].Text :=Format(cc.PageFormat,[CurrentPage,PageCount]);
end;

class procedure TPreviewForm.Action(ReportFile:string;FPageCount:Integer);
begin
  PreviewForm := TPreviewForm.Create(nil);
  

  PreviewForm.PageCount := FPageCount;
  PreviewForm.updateStatus();
  PreviewForm.filename.Caption := ReportFile;
  PreviewForm.ShowModal;
  PreviewForm.Free;
end;

end.



