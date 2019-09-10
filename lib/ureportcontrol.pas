unit ureportcontrol;

interface
uses osservice, Types, Controls, CC, Classes, Messages, windows, ureport,
  Math,
  Forms, Dialogs, Menus, Db,
  ExtCtrls,Contnrs
;

type
  MouseSelector = class;
  MouseDragger = class;
  TReportControl = class (TReportPage)
  private
    FMousePoint: TPoint;
    FTextEdit:Edit;
    FEditCell: TReportCell;
    MouseSelect : MouseSelector;
    MouseDrag : MouseDragger;

    procedure StartMouseDrag_Horz(point: TPoint);
    procedure StartMouseDrag_Verz(point: TPoint);
    function IsEditing :Boolean;
    procedure CancelEditing;
    procedure RecreateEdit(ThisCell: TReportCell);
    procedure DoDoubleClick(p:TPoint);
    procedure MsgLoop(RectBorder:TRect);
    procedure ClearPaintMessage;
    
    procedure DrawIndicatorLine(var x: Integer; RectBorder: TRect);
    procedure OnMove(TempMsg: TMsg;RectBorder:TRect );
  public
    procedure DoMouseDown(P:TPoint;Shift:Boolean);
    Procedure StartMouseDrag(point: TPoint);
    Procedure StartMouseSelect(point: TPoint; Shift: Boolean );
    Procedure WMLButtonDown(Var m: TMessage); Message WM_LBUTTONDOWN;
    Procedure WMLButtonDBLClk(Var Message: TMessage); Message WM_LBUTTONDBLCLK;
    Procedure WMMouseMove(Var m: TMessage); Message WM_MOUSEMOVE;
    Procedure WMContextMenu(Var Message: TMessage); Message WM_CONTEXTMENU;      
    Procedure WMCOMMAND(Var Message: TMessage); Message WM_COMMAND;
    Procedure WMCtlColor(Var Message: TMessage); Message WM_CTLCOLOREDIT;
    constructor create(Owner:TComponent);override;
    destructor destroy;override;
    Procedure FreeEdit;
    procedure DoEdit(str:String);
  published
    Property OnMouseMove;
    Property OnMouseDown;
    Property OnMouseUp;
    Property OnDragOver;
    Property OnDragDrop;
  end;
  MouseBase = class
  protected
    FControl :TReportControl ;
    procedure DoMouseMove(Msg:TMsg);virtual;abstract;
    procedure MsgLoop;
  end;
  MouseSelector = class(MouseBase)
  private
  public
    constructor Create(RC:TReportControl);
    procedure DoMouseMove(Msg:TMsg); override;
    procedure StartMouseSelect(point: TPoint; Shift: Boolean);
  end;
  MouseDragger = class(MouseBase)
    c : Canvas ;
    RectBorder: TRect;
    ThisCell: TReportCell;
  private
    procedure XorHorz( );
    procedure RegularPointY(var P: TPoint);
    procedure Bound(var Value: Integer);
  public
    constructor Create(RC:TReportControl);
    procedure DoMouseMove(Msg: TMSG); override;
    procedure StartMouseDrag_Horz(point: TPoint);
  end;
implementation



Procedure TReportControl.WMLButtonDBLClk(Var Message: TMessage);
Var
  TempPoint: TPoint;
Begin
  ClearSelect;
  GetCursorPos(TempPoint);
  Windows.ScreenToClient(Handle, TempPoint);

  DoDoubleClick(TEmpPoint);
  Inherited;
End;

Procedure TReportControl.WMLButtonDown(Var m: TMessage);
Var
  p: TPoint;
  Shift: Boolean;
Begin
  If ReportScale <> 100 Then   //按下Mouse键，并缩放率<>100时，恢复为正常
  Begin                                     
    ReportScale :=100 ;
    exit;
  End;
  p := MousePoint(m);
  Shift := m.wparam = 5 ;
  if IsEditing then CancelEditing;
  ClearPaintMessage;
  DoMouseDown(p,Shift );
  // 这一行要是不写，点击退出的红叉叉就不好使。
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  Inherited;
End;

Procedure TReportControl.WMMouseMove(Var m: TMessage);
Var
  ThisCell: TReportCell;
  P: TPoint;
Begin
  p := MousePoint(m);
  ThisCell := CellFromPoint(p);
  If ThisCell <> Nil Then
  Begin
    If ThisCell.NearRight(p) Then
      os.SetCursorSizeWE
    Else If ThisCell.NearBottom(p) Then
      os.SetCursorSizeNS
    Else
      os.SetCursorSizeBeam;
  End
  Else
    os.setCursorArrow;
  Inherited;                           
End;

Procedure TReportControl.WMContextMenu(Var Message: TMessage);
Var
  ThisCell: TReportCell;
  TempPoint: TPoint;
Begin
  GetCursorPos(TempPoint);
  Windows.ScreenToClient(Handle, TempPoint);
  ThisCell := CellFromPoint(TempPoint);

  If Not IsCellSelected(ThisCell) Then
  Begin
    ClearSelect;
    If ThisCell <> Nil Then
    Begin
      AddSelectedCell(ThisCell);
    End;
  End;
End;

Procedure TReportControl.StartMouseDrag(point: TPoint);
Var
  ThisCell: TReportCell;
  RectCell: TRect;
Begin
  ThisCell := CellFromPoint(point);
  RectCell := ThisCell.CellRect;
  // 置横向标志
  If abs(RectCell.Bottom - point.y) <= 3 Then
    StartMouseDrag_Horz(Point)
  Else
    StartMouseDrag_Verz(Point) ;
End;

Procedure TReportControl.StartMouseDrag_Horz(Point: TPoint);
begin
   self.MouseDrag.StartMouseDrag_Horz(Point);
end;

procedure TReportControl.DrawIndicatorLine(var x:Integer;RectBorder:TRect );
var  RectClient:TRect;
Begin
  x:= RegularPoint(x);
  x  := Max (x , RectBorder.Left);
  x := Min (x , RectBorder.Right);
  MoveToEx(hClientDC,x, 0, Nil);
    Windows.GetClientRect(Handle, RectClient);
  LineTo(hClientDC, x, RectClient.Bottom);
End;

procedure TReportControl.OnMove(TempMsg: TMSG;RectBorder:TRect );
begin
  DrawIndicatorLine(FMousePoint.x,RectBorder);
  FMousePoint := TempMsg.pt;
  Windows.ScreenToClient(Handle, FMousePoint);
  DrawIndicatorLine(FMousePoint.x,RectBorder);
end;

procedure TReportControl.MsgLoop(RectBorder:TRect);
var TempMsg: TMSG;
begin
  While GetCapture = Handle Do
  Begin
    If Not GetMessage(TempMsg, Handle, 0, 0) Then
    Begin
      PostQuitMessage(TempMsg.wParam);
      Break;
    End;
    Case TempMsg.message Of
      WM_LBUTTONUP:
        ReleaseCapture;
      WM_MOUSEMOVE:
        Begin
          OnMove(TempMsg,RectBorder);
        End;
      WM_SETCURSOR:
        ;
    Else
      DispatchMessage(TempMsg);
    End;
  End; 
end;

Procedure TReportControl.StartMouseDrag_Verz(point: TPoint);

Var
  ThisCell: TReportCell;
  Nepotism: TCellList;
  I: Integer;
  RectBorder:TRect;
  c : Canvas;
Begin
  ThisCell := CellFromPoint(point);
  FMousePoint := point;
  hClientDC := GetDC(Handle);
  c := Canvas.Create(hClientDC);
  c.ReadyDotPen(1,cc.Black);
  c.ReadyDrawModeInvert;
  Nepotism := TCellList.Create(self);
  If not Interference (ThisCell) Then
    Nepotism.MakeFromSameRight(ThisCell)
  Else
    Nepotism.MakeFromSameRightAndInterference(ThisCell);

  RectBorder := RectBorder1(thisCell,Nepotism);
  DrawIndicatorLine(FMousePoint.x,RectBorder);
  SetCursor(LoadCursor(0, IDC_SIZEWE));
  SetCapture(Handle);

  MsgLoop (RectBorder);

  If GetCapture = Handle Then
    ReleaseCapture;

  try
    DrawIndicatorLine(FMousePoint.x,RectBorder);
    try
      Nepotism.CheckAllNextCellIsSlave;
      Nepotism.CheckAllNextCellIsBiggerBottom;
      For I := 0 To Nepotism.Count - 1 Do
        UpdateTwinCell (Nepotism[I],FMousePoint.x);
      UpdateLines;
    except
    end;
  finally
    c.KillDrawMode;
    c.KillPen;
    c.Free;
    ReleaseDC(Handle, hClientDC);
  end;
End;

Procedure TReportControl.StartMouseSelect(point: TPoint;Shift: Boolean );
begin
  MouseSelect.StartMouseSelect(point,shift);
end;

Procedure TReportControl.WMCOMMAND(Var Message: TMessage);
Var
  r: TRect;
Begin
  Case HIWORD(Message.wParam) Of
    EN_UPDATE:
      If FEditCell <> Nil Then
      Begin
        r := FEditCell.TextRect;
        DoEdit ( FTextEdit.GetText());

        if Assigned (FOnChanged) then
          FOnChanged(Self,FEditCell.CellText);
        UpdateLines ;
        if not os.RectEquals (r , FEditCell.TextRect) then
        Begin
          FTextEdit.MoveRect(FEditCell.TextRect);
        End;
      End;
  End;
End;

Procedure TReportControl.WMCtlColor(Var Message: TMessage);
Var
  hTempDC: HDC;
Begin
  If FEditCell <> Nil Then
  Begin
    hTempDC := HDC(Message.WParam);
    SetBkColor(hTempDC, FEditCell.BkColor);
    SetTextColor(hTempDC, FEditCell.TextColor);
    Message.Result := FTextEdit.CreateBrush(FEditCell.BkColor);
  End;
End;

Procedure TReportControl.FreeEdit;
Begin
  Windows.SetFocus(0);
  FTextEdit.DestroyIfVisible;
  If (FEditCell <> Nil)Then
    FEditCell := Nil;
End;

procedure TReportControl.DoEdit(str: string);
begin
  FEditCell.CellText := str;
end;

function TReportControl.IsEditing: boolean;
begin
  result := FTextEdit.IsWindowVisible() ;
end;

procedure TReportControl.CancelEditing;
var
  str: Array[0..3000] Of Char;
begin
    If FEditCell <> Nil Then
    Begin
      FEditCell.CellText := FTextEdit.GetText ;
    End;
    Windows.SetFocus(0);// 奇怪，ReportControl窗口一旦得到焦点就移动自己
    FTextEdit.DestroyWindow ;
    FEditCell := Nil;   
end;

procedure TReportControl.ClearPaintMessage;
var   TempMsg: TMSG;
begin
  // 清除消息队列中的WM_PAINT消息，防止画出飞线
  While PeekMessage(TempMsg, 0, WM_PAINT, WM_PAINT, PM_NOREMOVE) Do
  Begin
    If Not GetMessage(TempMsg, 0, WM_PAINT, WM_PAINT) Then
      Break;       
    DispatchMessage(TempMsg);
  End;

end;

constructor TReportControl.create(Owner: TComponent);
begin
  inherited;
  FEditCell := Nil;
  mouseSelect := MouseSelector.Create(Self);
  MouseDrag := MouseDragger.Create(Self);
  FTextEdit:=Edit.Create(self);
  // 鼠标操作支持
  FMousePoint.x := 0;
  FMousePoint.y := 0;
end;

destructor TReportControl.destroy;
begin
  FTextEdit.Free;
  mouseSelect.Free;
  MouseDrag.Free;
  inherited;
end;

procedure TReportControl.DoMouseDown(P: TPoint; Shift: Boolean);
var 
  Cell: TReportCell;
begin
  Cell := CellFromPoint(P);
  If  (Cell <> Nil) and Cell.NearRightBottom(P) Then
      StartMouseDrag(P)
  else
    StartMouseSelect(P, Shift) ;
end;

procedure TReportControl.RecreateEdit(ThisCell:TReportCell);
begin
  FTextEdit.DestroyIfVisible ;
  FTextEdit.CreateEdit(Handle,ThisCell.TextRect,ThisCell.LogFont,ThisCell.CellText,ThisCell.FHorzAlign);
end;

procedure TReportControl.DoDoubleClick(p: TPoint);
Var
  ThisCell: TReportCell;                             
begin
  ThisCell := CellFromPoint(p);
  If (ThisCell <> Nil) And (ThisCell.CellWidth > 10) Then
  Begin
    FEditCell := ThisCell;  
    RecreateEdit(ThisCell);
  End;
end;

constructor MouseSelector.Create(RC: TReportControl);
begin
  FControl := rc;
end;

Procedure MouseSelector.StartMouseSelect(point: TPoint;Shift: Boolean );
Var
  ThisCell: TReportCell;

Begin
  If not Shift Then
    FControl.ClearSelect;
  ThisCell := FControl.CellFromPoint(point);
  FControl.AddSelectedCell(ThisCell);
  SetCapture(FControl.Handle);
  FControl.FMousePoint := point;
  MsgLoop;
End;

Procedure MouseSelector.DoMouseMove(Msg:TMsg);
Var
  RectSelection: TRect;
  p: TPoint;Shift:Boolean ;
  Cells : TCellList;
Begin
  p := msg.pt ;
  Shift := msg.wParam =5 ;
  Windows.ScreenToClient(FControl.Handle, p);
  RectSelection := FControl.os.MakeRect(FControl.FMousePoint,p);
  If not Shift  Then
    FControl.FSelectCells.ClearBySelection(RectSelection);
  Cells := TCellList.Create(self.FControl);
  try
    Cells.MakeInteractWith(RectSelection);
    FControl.AddSelectedCells(Cells);
  finally
    Cells.Free;
  end;
End;
{ MouseDragger }

constructor MouseDragger.Create(RC: TReportControl);
begin
  FControl := RC;
end;
procedure MouseDragger.DoMouseMove(Msg: TMSG);
Begin
  XorHorz();
  FControl.FMousePoint := Msg.pt;
  Windows.ScreenToClient(FControl.Handle, FControl.FMousePoint);
  RegularPointY(FControl.FMousePoint);
  XorHorz();
End;

procedure MouseBase.MsgLoop;
var Msg: TMSG;
begin
    SetCapture(FControl.Handle);
    While GetCapture = FControl.Handle Do
    Begin
      If Not GetMessage(Msg, FControl.Handle, 0, 0) Then
      Begin
        PostQuitMessage(Msg.wParam);
        Break;
      End;
      Case Msg.message Of
        WM_LBUTTONUP:
          ReleaseCapture;
        WM_MOUSEMOVE:
          DoMouseMove (Msg);
        WM_SETCURSOR:
          ;
      Else
        DispatchMessage(Msg);
      End;
    End;               
    If GetCapture = FControl.Handle Then
      ReleaseCapture;
end;

procedure MouseDragger.StartMouseDrag_Horz(point: TPoint);

Begin
  c := Canvas.CreateWnd(FControl.Handle);
  c.ReadyDotPen(1, cc.Black);
  c.ReadyDrawModeInvert();
  try
    ThisCell := FControl.CellFromPoint(point);
    FControl.FMousePoint := point;
    RegularPointY(FControl.FMousePoint);
    XorHorz();
    FControl.Os.SetCursorSizeNS;
    MsgLoop;
    XorHorz();
    FControl.UpdateHeight(ThisCell,FControl.FMousePoint.Y);
  finally
    c.KillPen ;
    c.KillDrawMode ;
    c.ReleaseDC;
    c.Free;
  end;
End;
procedure MouseDragger.Bound(var Value:Integer);
var
  Rect:TRect ;
begin
  Rect :=FControl.QueryMaxDragExtent(ThisCell);
  Value := BoundValue(Value,Rect.Bottom,Rect.Top) ;
end;
procedure MouseDragger.XorHorz();
var y :integer;
begin
  y := FControl.FMousePoint.Y;
  Bound(y) ;
  c.MoveTo(0, Y);
  c.LineTo(FControl.ClientRect.Right, Y);
end;
procedure MouseDragger.RegularPointY(var P:TPoint);
begin
   p.y := RegularPoint(p.y);
end;    
end.
