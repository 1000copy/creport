
Unit ReportControl;

Interface

Uses
  Windows, Messages, SysUtils,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice;
type
  TPrinterPaper = class
  private
    // google : msdn DEVMODE structure
    DevMode: PdeviceMode;
    //LCJ: 打印文件的纸张编号：比如 A4，A3，自定义纸张等。
    FprPageNo: integer;
    // 纸张纵横方向  lzl
    FprPageXy: integer;
    // 纸张长度（高度）
    fpaperLength: integer;
    fpaperWidth: integer;
  private
    //取得当前打印机的DeviceMode的结构成员
    Procedure prDeviceMode;
    procedure SetPaper(FprPageNo, FprPageXy, fpaperLength,
      fpaperWidth: Integer);
    procedure GetPaper(var FprPageNo, FprPageXy, fpaperLength,
      fpaperWidth: Integer);
  public
    procedure SetPaperWithCurrent;
    procedure Batch;overload;
    procedure Batch(FprPageNo,FprPageXy,fpaperLength,fpaperWidth:Integer);overload;
  end;
  //dsgnintf d5
Const
  // Horz Align
  TEXT_ALIGN_LEFT = 0;
  TEXT_ALIGN_CENTER = 1;
  TEXT_ALIGN_RIGHT = 2;

  // Vert Align
  TEXT_ALIGN_TOP = 0;
  TEXT_ALIGN_VCENTER = 1;
  TEXT_ALIGN_BOTTOM = 2;

  // 斜线定义
  LINE_LEFT1 = 1;                       // left top to right bottom
  LINE_LEFT2 = 2;                       // left top to right
  LINE_LEFT3 = 4;                       // left top to bottom

  LINE_RIGHT1 = $100;                   // right top to left bottom
  LINE_RIGHT2 = $200;                   // right top to left
  LINE_RIGHT3 = $400;                   // right top to bottom

Type
  TReportCell = Class;
  TReportLine = Class;
  TReportControl = Class;

  TReportCell = Class(TObject)
  public
    { Private declarations }
    FLeftMargin: Integer;               // 左边的空格
    FOwnerLine: TReportLine;            // 隶属行
    FOwnerCell: TReportCell;            // 隶属的单元格
    FCellsList: TList;                  // 覆盖的Cell

    // Index
    FCellIndex: Integer;                // Cell在行中的索引

    // size & position
    FCellLeft: Integer;
    FCellWidth: Integer;

    FCellRect: TRect;                   // 计算得来
    FTextRect: TRect;

    FDragCellHeight: Integer;
    FMinCellHeight: Integer;
    FRequiredCellHeight: Integer;


    // border
    FLeftLine: Boolean;
    FLeftLineWidth: Integer;

    FTopLine: Boolean;
    FTopLineWidth: Integer;

    FRightLine: Boolean;
    FRightLineWidth: Integer;

    FBottomLine: Boolean;
    FBottomLineWidth: Integer;

    // 斜线
    FDiagonal: UINT;

    // color
    FTextColor: COLORREF;
    FBackGroundColor: COLORREF;

    // align
    FHorzAlign: Integer;
    FVertAlign: Integer;

    // string
    FCellText: String;
    FCellDispformat: String;

    FBmp: TBitmap;
    FbmpYn: boolean;
    // font
    FLogFont: TLOGFONT;
    // Cell的Top属性从隶属的行中取得
    // Cell的Height属性从隶属行和跨越行中取得
    Function GetCellHeight: Integer;
    Function GetCellTop: Integer;
    Function GetOwnerLineHeight: Integer;
    function DefaultHeight(cell: TReportCell): integer;
    function GetBottomest(FOwnerCell: TReportCell): TReportCell;
    procedure GetTextRect(var TempRect: TRect);
    function GetTotalHeight(FOwnerCell: TReportCell): Integer;
    function Payload: Integer;
  Protected
    { Protected declarations }
    Procedure SetLeftMargin(LeftMargin: Integer);
    Procedure SetOwnerLine(OwnerLine: TReportLine);

    Procedure SetOwnerCell(Cell: TReportCell);
    Function GetOwnedCellCount: Integer;

    Procedure SetCellLeft(CellLeft: Integer);
    Procedure SetCellWidth(CellWidth: Integer);

    Procedure SetLeftLine(LeftLine: Boolean);
    Procedure SetLeftLineWidth(LeftLineWidth: Integer);

    Procedure SetTopLine(TopLine: Boolean);
    Procedure SetTopLineWidth(TopLineWidth: Integer);

    Procedure SetRightLine(RightLine: Boolean);
    Procedure SetRightLineWidth(RightLineWidth: Integer);

    Procedure SetBottomLine(BottomLine: Boolean);
    Procedure SetBottomLineWidth(BottomLineWidth: Integer);

    Procedure SetCellText(CellText: String);
    Procedure SetCellDispformat(CellDispformat: String);
    Procedure SetLogFont(NewFont: TLOGFONT);

    Procedure SetBackGroundColor(BkColor: COLORREF);
    Procedure SetTextColor(TextColor: COLORREF);

  Public
    function IsLastCell():boolean;
    Procedure AddOwnedCell(Cell: TReportCell);
    Procedure RemoveAllOwnedCell;
    Procedure RemoveOwnedCell(Cell: TReportCell);
    Function IsCellOwned(Cell: TReportCell): Boolean;
    Procedure CalcCellTextRect;
    Procedure CalcEveryHeight;
    Procedure PaintCell(hPaintDC: HDC; bPrint: Boolean);
    Procedure CopyCell(Cell: TReportCell; bInsert: Boolean);

    Constructor Create;
    Destructor Destroy; Override;

    // Properties
    Property LeftMargin: Integer Read FLeftMargin Write SetLeftMargin;
    Property OwnerLine: TReportLine Read FOwnerLine Write SetOwnerLine;
    Property OwnerCell: TReportCell Read FOwnerCell Write SetOwnerCell;
    Property OwnedCellCount: Integer Read GetOwnedCellCount;

    Property CellIndex: Integer Read FCellIndex Write FCellIndex;

    // size & position
    Property CellLeft: Integer Read FCellLeft Write SetCellLeft;
    Property CellWidth: Integer Read FCellWidth Write SetCellWidth;
    Property CellTop: Integer Read GetCellTop;
    Property CellHeight: Integer Read GetCellHeight;

    Property CellRect: TRect Read FCellRect;
    Property TextRect: TRect Read FTextRect;

    Property DragCellHeight: Integer Read FDragCellHeight;
    // or protected property ?
    Property MinCellHeight: Integer Read FMinCellHeight Write FMinCellHeight;
    Property RequiredCellHeight: Integer Read FRequiredCellHeight;
    Property OwnerLineHeight: Integer Read GetOwnerLineHeight;

    // border
    Property LeftLine: Boolean Read FLeftLine Write SetLeftLine Default True;
    Property LeftLineWidth: Integer Read FLeftLineWidth Write SetLeftLineWidth
      Default 1;

    Property TopLine: Boolean Read FTopLine Write SetTopLine Default True;
    Property TopLineWidth: Integer Read FTopLineWidth Write SetTopLineWidth
      Default 1;

    Property RightLine: Boolean Read FRightLine Write SetRightLine Default True;
    Property RightLineWidth: Integer Read FRightLineWidth Write SetRightLineWidth
      Default 1;

    Property BottomLine: Boolean Read FBottomLine Write SetBottomLine Default
      True;
    Property BottomLineWidth: Integer Read FBottomLineWidth Write
      SetBottomLineWidth Default 1;

    // 斜线
    Property Diagonal: UINT Read FDiagonal Write FDiagonal;

    // color
    Property TextColor: COLORREF Read FTextColor Write SetTextColor Default
      clBlack;
    Property BkColor: COLORREF Read FBackGroundColor Write SetBackGroundColor
      Default clWhite;

    // align
    Property HorzAlign: Integer Read FHorzAlign Write FHorzAlign Default 1;
    Property VertAlign: Integer Read FVertAlign Write FVertAlign Default 1;

    // string
    Property CellText: String Read FCellText Write SetCellText;
    Property CellDispformat: String Read FCellDispformat Write
      SetCellDispformat;

    // font
    Property LogFont: TLOGFONT Read FLogFont Write SetLogFont;
  End;
  TReportLine = Class(TObject)
  public
    { Private declarations }
    FReportControl: TReportControl;     // Report Control的指针
    FCells: TList;                      // 保存所有在该行中的CELL
    FIndex: Integer;                    // 行的索引

    FMinHeight: Integer;
    FDragHeight: Integer;
    FLineTop: Integer;
    FLineRect: TRect;
    Function GetLineHeight: Integer;
    Function GetLineRect: TRect;
    Procedure SetDragHeight(Const Value: Integer);
    Procedure SetLineTop(Const Value: Integer);
  Protected
    { Protected declarations }
  Public
    { Public declarations }
    Property ReportControl: TReportControl Read FReportControl Write
      FReportControl;
    Property Index: Integer Read FIndex Write FIndex;
    Property LineHeight: Integer Read GetLineHeight Write SetDragHeight;
    Property LineTop: Integer Read FLineTop Write SetLineTop;
    Property LineRect: TRect Read GetLineRect;
    Property PrevLineRect: TRect Read FLineRect;
    Procedure CalcLineHeight;
    Procedure CreateLine(LineLeft, CellNumber, PageWidth: Integer);
    Procedure CopyLine(Line: TReportLine; bInsert: Boolean);
    procedure Select ;
    Constructor Create;
    Destructor Destroy; Override;

  End;
  TCellList = class(TList)
  private
    ReportControl:TReportControl;
  public
    constructor Create(ReportControl:TReportControl);
    function IsRegularForCombine():Boolean;
  end;

  TReportControl = Class(TWinControl)
  private
    procedure InternalSaveToFile(FLineList: TList; FileName: String;
      PageNumber, Fpageall: integer);
  protected
    FprPageNo,FprPageXy,fpaperLength,fpaperWidth: Integer;
    Cpreviewedit: boolean;
    FPreviewStatus: Boolean;

    FLineList: TList;
    FSelectCells: TCellList;
    FEditCell: TReportCell;

    FReportScale: Integer;
    FPageWidth: Integer;
    FPageHeight: Integer;

    FLeftMargin: Integer;
    FRightMargin: Integer;
    FTopMargin: Integer;
    FBottomMargin: Integer;

    FcellFont: TlogFont;

    FLeftMargin1: Integer;
    FRightMargin1: Integer;
    FTopMargin1: Integer;
    FBottomMargin1: Integer;
    //表尾的第一行在整个页的第几行
    FHootNo: integer;
    // 换页加表头（不加表头）
    FNewTable: Boolean;
    // 定义打印多少行后从新加表头
    FDataLine: Integer;
    FTablePerPage: Integer;
    // 鼠标操作支持
    FMousePoint: TPoint;
    // 编辑框、以及它的颜色和字体
    FEditWnd: HWND;
    FEditBrush: HBRUSH;
    FEditFont: HFONT;
    function GetNhassumall: Integer;
    Procedure SetCellSFocus(row1, col1, row2, col2: integer);
    function Get(Index: Integer): TReportLine;
    function GetCells(Row, Col: Integer): TReportCell;
    procedure InvertCell(Cell: TReportCell);
  Protected
    hasdatano: integer;
    function RenderText(ThisCell: TReportCell; PageNumber,Fpageall: Integer): String;virtual ;
    Procedure CreateWnd; Override;
    procedure InternalLoadFromFile(FileName:string;FLineList:TList);


  Public
    FLastPrintPageWidth, FLastPrintPageHeight: integer;
    PrintPaper:TPrinterPaper;
    procedure DoVertSplitCell(ThisCell : TReportCell;SplitCount: Integer);
    function ZoomRate(height,width,HConst, WConst: integer): Integer;
    property SelectedCells: TCellList read FSelectCells ;
    { Public declarations }
    Procedure SetSelectedCellFont(cf: TFont);
    procedure SelectLines(row1, row2: integer);
    Procedure SetCellFocus(row, col: integer);
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure SaveToFile(FileName: String);overload;
    Procedure SaveToFile(FLineList:TList;FileName: String;PageNumber, Fpageall:integer);overload;
    Procedure LoadFromFile(FileName: String);
    Procedure SaveBmp(thiscell: Treportcell; filename: String);
    Function LoadBmp(thiscell: Treportcell): TBitmap;  
    Procedure FreeBmp(thiscell: Treportcell);
    Procedure PrintIt;
    Procedure ResetContent;
    Procedure SetScale(Const Value: Integer);
    Property cellFont: TlogFont Read Fcellfont Write Fcellfont;
    // Message Handler
    Procedure WMLButtonDown(Var Message: TMessage); Message WM_LBUTTONDOWN;
    Procedure WMLButtonDBLClk(Var Message: TMessage); Message WM_LBUTTONDBLCLK;
    Procedure WMMouseMove(Var Message: TMessage); Message WM_MOUSEMOVE;
    Procedure WMContextMenu(Var Message: TMessage); Message WM_CONTEXTMENU;
    Procedure WMPaint(Var Message: TMessage); Message WM_PAINT;
    Procedure WMCOMMAND(Var Message: TMessage); Message WM_COMMAND;
    Procedure WMCtlColor(Var Message: TMessage); Message WM_CTLCOLOREDIT;
    // Window size
    Procedure CalcWndSize;
    //在定义动态报表时,设置纸的大小 不调用windows的打印设置对框时
    Procedure SetWndSize(w, h: integer);
    //动态报表设置纸张大小
    Procedure NewTable(ColNumber, RowNumber: Integer);
    Procedure InsertLine;
    Function CanInsert: Boolean;
    Procedure AddLine;
    Function CanAdd: Boolean;
    Procedure DeleteLine;
    Procedure InsertCell;
    Procedure DeleteCell;
    Procedure AddCell;
    Procedure CombineCell;
    Procedure SplitCell;
    Procedure VSplitCell(Number: Integer);
    Function CanSplit: Boolean;
    Function CountFcells(crow: integer): integer;
    Procedure SetCellLines(bLeftLine, bTopLine, bRightLine, bBottomLine:
      Boolean;
      nLeftLineWidth, nTopLineWidth, nRightLineWidth, nBottomLineWidth:
      Integer);
    Procedure SetCellDiagonal(NewDiagonal: UINT);
    Procedure SetCellColor(NewTextColor, NewBackColor: COLORREF);
    Procedure SetCellDispFormt(mek: String);
    Procedure SetCellSumText(mek: String);
    Procedure SetCellFont(CellFont: TLOGFONT);
    Procedure SetCellAlign(NewHorzAlign, NewVertAlign: Integer);
    Procedure SetCellTextColor(NewTextColor: COLORREF);
    Procedure SetCellAlignHorzAlign(NewHorzAlign: Integer);
    Procedure SetCellAlignNewVertAlign(NewVertAlign: Integer);
    Procedure SetCellBackColor(NewBackColor: COLORREF);
    Procedure SetMargin(nLeftMargin, nTopMargin, nRightMargin, nBottomMargin:
      Integer);
    Function GetMargin: TRect;
    Function getcellfont: tfont;
    Procedure UpdateLines;
    //取销编辑状态  lzl
    Procedure FreeEdit;
    Procedure StartMouseDrag(point: TPoint);
    Procedure StartMouseSelect(point: TPoint; bSelectFlag: Boolean; shift_down:
      byte);
    Procedure MouseMoveHandler(message: TMSG);
    procedure SelectLine(row: integer);
    // 选中区的操作
    Function AddSelectedCell(Cell: TReportCell): Boolean;
    Function RemoveSelectedCell(Cell: TReportCell): Boolean;
    Procedure ClearSelect;
    Function IsCellSelected(Cell: TReportCell): Boolean;
    Function CellFromPoint(point: TPoint): TReportCell;
    Property IsPreview: Boolean Read FPreviewStatus Write FPreviewStatus Default
      False;
    Property ReportScale: Integer Read FReportScale Write SetScale Default 100;
    Property IsNewTable: Boolean Read FNewTable Write FNewTable Default True;
    Property DataLine: Integer Read FDataLine Write FDataLine ;
    Property TablePerPage: Integer Read FTablePerPage Write FTablePerPage ;
    property Lines[Index: Integer]: TReportLine read Get  ;
    property Cells[Row: Integer;Col: Integer]: TReportCell read GetCells ;
    property  AllowPreviewEdit: boolean read CPreviewEdit write CPreviewEdit;
  Published
    { Published declarations }
    Property Left;
    Property Top;
    Property Cursor;
    Property Hint;
    Property Visible Default True;
    Property Enabled Default True;
    Property OnMouseMove;
    Property OnMouseDown;
    Property OnMouseUp;
    Property ShowHint;
    Property OnDragOver;
    Property OnDragDrop;
  End;
  TDatasetItem = Class(TObject)
    pDataset: TDataset;
    strName: String;
  End;
  TVarTableItem = Class(TObject)
    strVarName: String;
    strVarValue: String;
  End;
  TMyRect = Class(TObject)
  Public
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
  End;
  TCellTable = Class(TObject)
    PrevCell: TReportCell;
    ThisCell: TReportCell;
  End;

Function DeleteFiles(FilePath, FileMask: String): Boolean;

Procedure Register;
// 2014-11-13 这两天正在喝。平和，质朴，散发着有钱的感觉...
//            金丝带 Alectoria virens Tayl.，寄生地衣类植物。除风湿、健脾胃。
// 2014-11-13 encaplating...艰难而看不到未来。唯有埋头，忍耐，坚韧不拔。
// 2014-11-17 把Load/Save 5个拷贝后小改的代码合并。有一个趁手的对比工具很重要。
//            winmerge，thank you
// 2014-11-19 全部这里的全局变量，已经消失，转换，降低了可见级别！



  {
  解构主义
   ========================
  风雨声中，忽听得吴六奇放开喉咙唱起曲来：...

 曲声从江上远送出去，风雨之声虽响，却也压他不倒。

 马超兴在後梢喝采不迭，叫道：「好一个『声逐海天远』！」

 韦小宝但听他唱得慷慨激昂，也不知曲文是甚麽意思，
  心中骂道：「你有这副好嗓子，却不去戏台上做大花面？老叫化，放开了喉咙大叫：『老
  爷太太，施舍些残羹冷饭』，倒也饿不死你。」
}

Implementation

{$R ReportControl.dcr}
Uses Preview, REPmess, margin,Creport;


Procedure TPrinterPaper.prDeviceMode;
var
  Adevice, Adriver, Aport: Array[0..255] Of char;
  DeviceHandle: THandle;
Begin
  Printer.GetPrinter(Adevice, Adriver, Aport, DeviceHandle);
  If DeviceHandle = 0 Then
    Raise Exception.Create('Could Not Initialize TdeviceMode Structure')
  Else
    DevMode := GlobalLock(DeviceHandle);
End;
procedure TPrinterPaper.SetPaperWithCurrent;
begin
  with Devmode^ do //设置打印纸  李泽伦
  begin
    dmFields:=dmFields or DM_PAPERSIZE;
    dmPapersize:=FprPageNo;
    dmFields:=dmFields or DM_ORIENTATION;
    dmOrientation:=FprPageXy;

    dmPaperLength:=fpaperLength;
    dmPaperWidth:=fpaperWidth;
  end;
end;
procedure TPrinterPaper.SetPaper(FprPageNo,FprPageXy,fpaperLength,fpaperWidth:Integer);
begin
    Devmode^.dmFields := Devmode^.dmFields Or DM_PAPERSIZE;
    Devmode^.dmPapersize := FprPageNo;
    Devmode^.dmFields := Devmode^.dmFields Or DM_ORIENTATION;
    Devmode^.dmOrientation := FprPageXy;

    Devmode^.dmPaperLength := fpaperLength;
    Devmode^.dmPaperWidth := fpaperWidth;
end;

procedure TPrinterPaper.GetPaper(var FprPageNo,FprPageXy,fpaperLength,fpaperWidth:Integer);
begin
  With Devmode^ Do
  Begin
    dmFields := dmFields Or DM_PAPERSIZE;
    FprPageNo := dmPapersize;
    dmFields := dmFields Or DM_ORIENTATION;
    FprPageXy := dmOrientation;
    fPaperLength := dmPaperLength;
    fPaperWidth := dmPaperWidth;
  End;
end;

Function DeleteFiles(FilePath, FileMask: String): Boolean;
Var
  Attributes: integer;
  DeleteFilesSearchRec: TSearchRec;
Begin
  Result := true;
  Try
    FindFirst(FilePath + '\' + FileMask, faAnyFile, DeleteFilesSearchRec);

    If Not (DeleteFilesSearchRec.Name = '') Then
    Begin
      Result := True;
      {$WARNINGS OFF}
      Attributes := FileGetAttr(FilePath + '\' + DeleteFilesSearchRec.Name);
      //Attributes := Attributes And Not (faReadonly Or faHidden Or fasysfile);
      FileSetAttr(FilePath + '\' + DeleteFilesSearchRec.Name, Attributes);
      {$WARNINGS ON}
      DeleteFile(FilePath + '\' + DeleteFilesSearchRec.Name);

      While FindNext(DeleteFilesSearchRec) = 0 Do
      Begin
        {$WARNINGS OFF}
        Attributes := FileGetAttr(FilePath + '\' + DeleteFilesSearchRec.Name);
        //Attributes := Attributes And Not (faReadOnly Or faHidden Or fasysfile);
        FileSetAttr(FilePath + '\' + DeleteFilesSearchRec.Name, Attributes);
        {$WARNINGS ON}
        DeleteFile(FilePath + '\' + DeleteFilesSearchRec.Name);
      End;
    End;

    FindClose(DeleteFilesSearchRec);

  Except
    Result := false;
    Exit;
  End;
End;

Procedure Register;
Begin
  RegisterComponents('CReport', [TReportControl]);
End;

{TReportCell}   

Procedure TReportCell.SetLeftMargin(LeftMargin: Integer);
Begin
  // 修改左右预留的空白区域.呵呵，目前只能是5。
  If (LeftMargin = FLeftMargin) Or
    (LeftMargin < 5) Or (LeftMargin > 5) Then
    Exit;  
  FLeftMargin := LeftMargin;
  CalcEveryHeight;
End;

Procedure TReportCell.SetOwnerLine(OwnerLine: TReportLine);
Begin
  If OwnerLine <> Nil Then
    FOwnerLine := OwnerLine;

End;

Procedure TReportCell.SetOwnerCell(Cell: TReportCell);
Begin
  FOwnerCell := Cell;
End;

Function TReportCell.GetOwnedCellCount: Integer;
Begin
  Result := FCellsList.Count;
End;

Procedure TReportCell.AddOwnedCell(Cell: TReportCell);
Var
  I: Integer;
  TempCellList: TList;
Begin
  If (Cell = Nil) Or (FCellsList.IndexOf(Cell) >= 0) Then
    Exit;

  Cell.OwnerCell := Self;
  FCellText := FCellText + Cell.CellText;
  Cell.CellText := '';

  FCellsList.Add(Cell);

  TempCellList := TList.Create;
  For I := 0 To Cell.FCellsList.Count - 1 Do
    TempCellList.Add(Cell.FCellsList[I]);

  Cell.RemoveAllOwnedCell();

  For I := 0 To TempCellList.Count - 1 Do
  Begin
    FCellsList.Add(TempCellList[I]);
    TReportCell(TempCellList[I]).OwnerCell := Self;
  End;

//  TempCellList := Cell.FCellsList ;
//  For I := 0 To TempCellList.Count - 1 Do
//  Begin
//    FCellsList.Add(TempCellList[I]);
//    TReportCell(TempCellList[I]).OwnerCell := Self;
//  End;
//  Cell.RemoveAllOwnedCell();
End;

Procedure TReportCell.RemoveAllOwnedCell;
Var
  I: Integer;
  Cell: TReportCell;
Begin
  For I := 0 To FCellsList.Count - 1 Do
  Begin
    Cell := FCellsList[I];
    Cell.SetOwnerCell(Nil);
    Cell.CalcEveryHeight;

  End;

  FCellsList.Clear;
End;

Function TReportCell.IsCellOwned(Cell: TReportCell): Boolean;
Begin
  If FCellsList.IndexOf(Cell) >= 0 Then
    Result := True
  Else
    Result := False;
End;

Procedure TReportCell.SetCellLeft(CellLeft: Integer);
Begin
  If CellLeft = FCellLeft Then
    Exit;

  FCellLeft := CellLeft;
  CalcCellTextRect;
End;

Procedure TReportCell.SetCellWidth(CellWidth: Integer);
Begin
  If CellWidth = FCellWidth Then
    Exit;

  If CellWidth > 10 Then
  Begin
    FCellWidth := CellWidth;
    CalcEveryHeight;
    CalcCellTextRect;
  End
  Else
  Begin
    FCellWidth := 10;
    CalcEveryHeight;
    CalcCellTextRect;
  End;
End;

Function TReportCell.GetCellHeight: Integer;
Begin
  Assert(FOwnerLine <> Nil );
  If FDragCellHeight > FMinCellHeight Then
    Result := FDragCellHeight
  Else
    Result := FMinCellHeight;
End;

Function TReportCell.GetCellTop: Integer;
Begin
   Assert(FOwnerLine <> Nil );
   Result := FOwnerLine.LineTop;
End;

Procedure TReportCell.SetLeftLine(LeftLine: Boolean);
Begin
  If LeftLine = FLeftLine Then
    Exit;

  FLeftLine := LeftLine;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetLeftLineWidth(LeftLineWidth: Integer);
Begin
  If LeftLineWidth = FLeftLineWidth Then
    Exit;

  FLeftLineWidth := LeftLineWidth;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetTopLine(TopLine: Boolean);
Begin
  If TopLine = FTopLine Then
    Exit;

  FTopLine := TopLine;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetTopLineWidth(TopLineWidth: Integer);
Begin
  If TopLineWidth = FTopLineWidth Then
    Exit;

  FTopLineWidth := TopLineWidth;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetRightLine(RightLine: Boolean);
Begin
  If RightLine = FRightLine Then
    Exit;

  FRightLine := RightLine;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetRightLineWidth(RightLineWidth: Integer);
Begin
  If RightLineWidth = FRightLineWidth Then
    Exit;

  FRightLineWidth := RightLineWidth;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetBottomLine(BottomLine: Boolean);
Begin
  If BottomLine = FBottomLine Then
    Exit;

  FBottomLine := BottomLine;
  CalcEveryHeight;
  CalcCellTextRect;

End;

Procedure TReportCell.SetBottomLineWidth(BottomLineWidth: Integer);
Begin
  If BottomLineWidth = FBottomLineWidth Then
    Exit;

  FBottomLineWidth := BottomLineWidth;
  CalcEveryHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetCellText(CellText: String);
Begin
  If CellText = FCellText Then
    Exit;

  FCellText := CellText;
  CalcEveryHeight;

End;

Procedure TReportCell.SetLogFont(NewFont: TLOGFONT);
Begin
  FLogFont := NewFont;
  CalcEveryHeight;
End;

Procedure TReportCell.SetBackGroundColor(BkColor: COLORREF);
Begin
  If BkColor = FBackGroundColor Then
    Exit;

  FBackGroundColor := BkColor;
  // InvalidateRect
End;

Procedure TReportCell.SetTextColor(TextColor: COLORREF);
Begin
  If TextColor = FTextColor Then
    Exit;

  FTextColor := TextColor;
  // InvalidateRect
End;

 procedure TReportCell.GetTextRect(var TempRect:TRect);
  var   hTempFont, hPrevFont: HFONT;
  hTempDC: HDC;
  TempString: String;
  Var
  Format: UINT;
  I: Integer;
  BottomCell, ThisCell: TReportCell;
  TotalHeight,Top: Integer;
  TempSize: TSize;
  begin
    // LCJ : 最小高度需要能够放下文字，并且留下直线的宽度和2个点的空间出来。
    //       因此，需要实际绘制文字在DC 0 上，获得它的TempRect-文字所占的空间
    //       - FLeftMargin : Cell 内文字和边线之间留下的空的宽度
    hTempFont := CreateFontIndirect(FLogFont);
    If (Length(FCellText) <= 0) Then
    TempString := '汉'
    Else
    TempString := FCellText;

    hTempDC := GetDC(0);
    hPrevFont := SelectObject(hTempDC, hTempFont);

    SetRect(TempRect, 0, 0, 0, 0);

    TempRect.left := FCellLeft + FLeftMargin;
    TempRect.top := GetCellTop + 2;
    ;
    TempRect.right := FCellLeft + FCellWidth - FLeftMargin;
    TempRect.bottom := 65535;

    Format := DT_EDITCONTROL Or DT_WORDBREAK;
    Case FHorzAlign Of
    0:
      Format := Format Or DT_LEFT;
    1:
      Format := Format Or DT_CENTER;
    2:
      Format := Format Or DT_RIGHT;
    Else
    Format := Format Or DT_LEFT;
    End;

    Format := Format Or DT_CALCRECT;
    // lpRect [in, out] !  TempRect.Bottom ,TempRect.Right  会被修改 。但是手册上没有提到。
    DrawText(hTempDC, PChar(TempString), Length(TempString), TempRect, Format);
    //  DrawText(hTempDC, PChar(TempString), -1, TempRect, Format);

    // 补偿文字最后的回车带来的误差
    If Length(TempString) >= 2 Then
    Begin
    If (TempString[Length(TempString)] = Chr(10)) And
    (TempString[Length(TempString) - 1] = Chr(13)) Then
    Begin
      GetTextExtentPoint(hTempDC, 'A', 1, TempSize);
      TempRect.Bottom := TempRect.Bottom + TempSize.cy;
    End;
    End;

    SelectObject(hTempDc, hPrevFont);
    DeleteObject(hTempFont);
    ReleaseDC(0, hTempDC);
  end;
  function TReportCell.DefaultHeight(cell : TReportCell) : integer; begin
    result := 16 + 2 + cell.FTopLineWidth + cell.FBottomLineWidth ;
  end;
  // 取得最下的单元格
  function TReportCell.GetBottomest(FOwnerCell:TReportCell):TReportCell;
  var BottomCell,ThisCell:TReportCell;I,Top:Integer ;
  begin
    BottomCell := Nil;
    Top := 0;
    For I := 0 To FOwnerCell.FCellsList.Count - 1 Do
    Begin
      ThisCell := FOwnerCell.FCellsList[i];
      If ThisCell.CellTop > Top Then
      Begin
        BottomCell := ThisCell;
        Top := ThisCell.CellTop;
      End;
    End;
    result := BottomCell;
  end;
  function TReportCell.GetTotalHeight(FOwnerCell:TReportCell):Integer;
  var BottomCell,ThisCell:TReportCell;I,Top,Height:Integer ;
  begin
    Height := 0 ;
    For I := 0 To FOwnerCell.FCellsList.Count - 1 Do
    Begin
      ThisCell := FOwnerCell.FCellsList[i];
      ThisCell.FMinCellHeight := DefaultHeight(thiscell);
      ThisCell.OwnerLine.CalcLineHeight;
      Height := Height + ThisCell.OwnerLineHeight;
    End;
    result := Height + FOwnerCell.OwnerLineHeight;
  end;
// 开始噩梦，噩梦中我把屏幕上的象素点一个一个干掉
// LCJ: 在 Calc_MinCellHeight 内，期望仅仅计算 CalcEveryHeight ；实际上同时在计算
//  FMinCellHeight ，FRequiredCellHeight ，还调用了 OwnerLine.CalcLineHeight
//  不能不说，看的有点焦虑 。。。
//  2014-11-6. 某人又在招人了，说拉了点投资。做猎头得了。
//  要覆盖测试的话，只要combine一个贯穿三行的Cell，每个cell会各走一个分支。Yeah。
//  这个cover，脑袋里面演示下，还是没有问题的
//  2014-11-7 现在，你体会下，这就是职责分离的快感。
//   RequiredCellHeight 就是在跨行合并的Cell中表达 CellText需要的高度。区别于
//  而MinCellHeight,后者是最小Cell的高度，不管它有没有合并和拆分，
//  都固定表示一个cell的高度。普通cell用  MinCellHeight，合并的cell可能需要用RequiredCellHeight
//  概念辨析:)
  function TReportCell.Payload : Integer;
  begin
    result := 2  + FTopLineWidth + FBottomLineWidth ;
  end;

Procedure TReportCell.CalcEveryHeight;
Var
  I: Integer;
  BottomCell, ThisCell: TReportCell;
  TotalHeight,Top,RectHeight: Integer;
  TempSize: TSize;
  TempRect: TRect;
  function Calc_RequiredCellHeight( ): Integer;
  var Height : integer;  TempRect: TRect;
  begin
    GetTextRect(TempRect);
    Height := 16 ;
    If TempRect.Bottom - TempRect.Top > 0 Then
      Height := TempRect.Bottom - TempRect.Top;
    result := Height + Payload ;
  end;
Begin
  FMinCellHeight := DefaultHeight(self);
  // 要是Cell 太窄，窄到无法放入任何文字，就不要到后面去计算高度了。
  // 直接默认 字高 16 即可。
  // 没有 RightMargin ,原作者把RightMargin 和LeftMargin等同，所以又下面的 FLeftMargin * 2
  If FCellWidth <= FLeftMargin * 2 Then
    Exit ;
  if (FOwnerCell <> Nil) Then
  Begin
      BottomCell := GetBottomest(FOwnerCell);
      TotalHeight := GetTotalHeight(FOwnerCell) ;
      If (BottomCell = Self ) and (FOwnerCell.RequiredCellHeight > TotalHeight) Then
        FMinCellHeight := FOwnerCell.RequiredCellHeight - TotalHeight + OwnerLineHeight;
  End else begin
      GetTextRect(TempRect);
      RectHeight := TempRect.Bottom - TempRect.Top ;
      If (FCellsList.Count = 0) and ( RectHeight > 0) Then
          FMinCellHeight := RectHeight + Payload;
  end;
  // block resonsibility depart
  If (FOwnerCell = Nil) and (FCellsList.Count > 0) Then
  Begin
    FRequiredCellHeight := Calc_RequiredCellHeight();
    OwnerLine.CalcLineHeight;
    For I := 0 To FCellsList.Count - 1 Do
      TReportCell(FCellsList[I]).CalcEveryHeight;
  End
End;

// Calc CellRect & TextRect here
// 如果CELL的大小或者文本框的大小改变，自动的置窗口的失效区
Procedure TReportCell.CalcCellTextRect;
  procedure CalcCellRect;
  Var
    TotalHeight: Integer;
    I: Integer;
  begin
    FCellRect.left := FCellLeft;
    FCellRect.top := CellTop;
    FCellRect.right := FCellRect.left + FCellWidth;
     FCellRect.bottom := FCellRect.top + OwnerLineHeight;
    if FCellsList.Count >0 then
      For I := 0 To FCellsList.Count - 1 Do
        FCellRect.bottom := FCellRect.bottom + TReportCell(FCellsList[I]).OwnerLineHeight;
  end;
  procedure CalcTextRect;
  Var
  TempRect: TRect;
  TotalHeight: Integer;
  I: Integer;
  begin
    TempRect := FCellRect;
    TempRect.left := TempRect.Left + FLeftMargin + 1;
    TempRect.top := TempRect.top + FTopLineWidth + 1;
    TempRect.right := TempRect.right - FLeftMargin - 1;
   If FCellsList.Count <= 0 Then
  Begin
    TempRect.bottom := TempRect.top + FMinCellHeight - 2 - FTopLineWidth -
      FBottomLineWidth;
    Case FVertAlign Of
      TEXT_ALIGN_VCENTER:
      Begin
        TempRect.Top := TempRect.Top + trunc((OwnerLineHeight - FMinCellHeight)
        / 2 + 0.5);
        TempRect.Bottom := TempRect.Bottom + trunc((OwnerLineHeight -
        FMinCellHeight) / 2 + 0.5);
      End;
      TEXT_ALIGN_BOTTOM:
      Begin
        TempRect.Top := TempRect.Top + OwnerLineHeight - FMinCellHeight;
        TempRect.Bottom := TempRect.Bottom + OwnerLineHeight - FMinCellHeight;
      End;
    End;
   End Else
   Begin
      TempRect.bottom := TempRect.top + FRequiredCellHeight - 2 - FTopLineWidth -
        FBottomLineWidth;
      Case FVertAlign Of
      TEXT_ALIGN_VCENTER:
      Begin
        TempRect.Top := TempRect.Top + trunc((FCellRect.Bottom - FCellRect.Top
        - FRequiredCellHeight) / 2 + 0.5);
        TempRect.Bottom := TempRect.Bottom + trunc((FCellRect.Bottom -
        FCellRect.Top - FRequiredCellHeight) / 2 + 0.5);
      End;
      TEXT_ALIGN_BOTTOM:
      Begin
        TempRect.Top := TempRect.Top + FCellRect.Bottom - FCellRect.Top -
        FRequiredCellHeight;
        TempRect.Bottom := TempRect.Bottom + FCellRect.Bottom - FCellRect.Top
        - FRequiredCellHeight;
      End;
      End;
    End;
    FTextRect := TempRect;
  end;
Begin
  CalcCellRect;
  CalcTextRect;
End;

Procedure TReportCell.PaintCell(hPaintDC: HDC; bPrint: Boolean);
Var
  SaveDCIndex: Integer;
  hTempBrush: HBRUSH;
  TempLogBrush: TLOGBRUSH;
  hPrevPen, hTempPen: HPEN;
  bDelete: Boolean;
  Format: UINT;
  hTextFont, hPrevFont: HFONT;
  TempRect: TRect;
  color  : COLORREF ;
  procedure DrawLine(x1,y1,x2,y2:integer;color:COLORREF;PenWidth:Integer);
  begin
    hTempPen := CreatePen(BS_SOLID, PenWidth, color);
    hPrevPen := SelectObject(hPaintDc, hTempPen);
    MoveToEx(hPaintDc, x1, y1, Nil);
    LineTo(hPaintDC, x2, y2);
    SelectObject(hPaintDc, hPrevPen);
    DeleteObject(hTempPen);
  end;
  procedure DrawLeft(color:COLORREF);
  begin
    DrawLine(FCellRect.left, FCellRect.top,FCellRect.left, FCellRect.bottom,color,FLeftLineWidth);
  end;
  procedure DrawTop(color:COLORREF);
  begin
    DrawLine( FCellRect.left, FCellRect.top,FCellRect.right, FCellRect.top,color,FTopLineWidth);
  end;
  procedure DrawRight(color:COLORREF);
  begin
    DrawLine( FCellRect.right, FCellRect.top,FCellRect.right, FCellRect.bottom,color,FRightLineWidth);
  end;
  procedure DrawBottom(color:COLORREF);
  begin
    DrawLine( FCellRect.left, FCellRect.bottom,FCellRect.right, FCellRect.bottom,color,FBottomLineWidth);
  end;
  procedure DrawFrameLine();
  var cGrey,cBlack: COLORREF ;
  begin
    cGrey :=  RGB(192, 192, 192);cBlack := RGB(0, 0, 0);
    // 绘制边框
    If FLeftLine Then
      DrawLeft(cBlack)
    else if (not bPrint) and (CellIndex = 0) then
      DrawLeft(cGrey);

    If FTopLine Then
      DrawTop(cBlack)
    else if (not bPrint) and (OwnerLine.Index = 0) then
      DrawTop(cGrey);

    If FRightLine Then
      DrawRight(cBlack)
    else if (not bPrint)  then
      DrawRight(cGrey);

    If FBottomLine Then
      DrawBottom(cBlack)
    else if (not bPrint)  then
      DrawBottom(cGrey); 
  end;
  procedure FillBg(FCellRect:TRect;FBackGroundColor:COLORREF);
  var TempRect:TRect;
  begin
      TempRect := FCellRect;
      TempRect.Top := TempRect.Top + 1;
      TempRect.Right := TempRect.Right + 1;
      If FBackGroundColor <> RGB(255, 255, 255) Then
      Begin
      TempLogBrush.lbStyle := BS_SOLID;
      TempLogBrush.lbColor := FBackGroundColor;
      hTempBrush := CreateBrushIndirect(TempLogBrush);
      FillRect(hPaintDC, TempRect, hTempBrush);
      DeleteObject(hTempBrush);
      End;
    end;
  procedure DrawDragon;begin
    hTempPen := CreatePen(PS_SOLID, 1, RGB(0, 0, 0));
    hPrevPen := SelectObject(hPaintDc, hTempPen);

    // 绘制斜线
    If FDiagonal > 0 Then
    Begin
    If ((FDiagonal And LINE_LEFT1) > 0) Then
    Begin
      MoveToEx(hPaintDC, FCellRect.left + 1, FCellRect.top + 1, Nil);
      LineTo(hPaintDC, FCellRect.right - 1, FCellRect.bottom - 1);
    End;

    If ((FDiagonal And LINE_LEFT2) > 0) Then
    Begin
      MoveToEx(hPaintDC, FCellRect.left + 1, FCellRect.top + 1, Nil);
      LineTo(hPaintDC, FCellRect.right - 1, trunc((FCellRect.bottom +
      FCellRect.top) / 2 + 0.5));
    End;

    If ((FDiagonal And LINE_LEFT3) > 0) Then
    Begin
      MoveToEx(hPaintDC, FCellRect.left + 1, FCellRect.top + 1, Nil);
      LineTo(hPaintDC, trunc((FCellRect.right + FCellRect.left) / 2 + 0.5),
      FCellRect.bottom - 1);
    End;

    If ((FDiagonal And LINE_RIGHT1) > 0) Then
    Begin
      MoveToEx(hPaintDC, FCellRect.right - 1, FCellRect.top + 1, Nil);
      LineTo(hPaintDC, FCellRect.left + 1, FCellRect.bottom - 1);
    End;

    If ((FDiagonal And LINE_RIGHT2) > 0) Then
    Begin
      MoveToEx(hPaintDC, FCellRect.right - 1, FCellRect.top + 1, Nil);
      LineTo(hPaintDC, FCellRect.left + 1, trunc((FCellRect.bottom +
      FCellRect.top) / 2 + 0.5));
    End;

    If ((FDiagonal And LINE_RIGHT3) > 0) Then
    Begin
      MoveToEx(hPaintDC, FCellRect.right - 1, FCellRect.top + 1, Nil);
      LineTo(hPaintDC, trunc((FCellRect.right + FCellRect.left) / 2 + 0.5),
      FCellRect.bottom - 1);
    End;

    End;

    SelectObject(hPaintDC, hPrevPen);
    DeleteObject(hTempPen);
  end;
  procedure DrawContentText;
  begin
   If Length(FCellText) > 0 Then
   Begin
    Windows.SetTextColor(hPaintDC, FTextColor);
    Format := DT_EDITCONTROL Or DT_WORDBREAK;
    Case FHorzAlign Of
      TEXT_ALIGN_LEFT:
      Format := Format Or DT_LEFT;
      TEXT_ALIGN_CENTER:
      Format := Format Or DT_CENTER;
      TEXT_ALIGN_RIGHT:
      Format := Format Or DT_RIGHT;
    Else
      Format := Format Or DT_LEFT;
    End;
    hTextFont := CreateFontIndirect(FLogFont);
    hPrevFont := SelectObject(hPaintDC, hTextFont);
    TempRect := FTextRect;
    DrawText(hPaintDC, PChar(FCellText), Length(FCellText), TempRect, Format);
    SelectObject(hPaintDC, hPrevFont);
    DeleteObject(hTextFont);
   End;
  end;
Begin
  If FOwnerCell <> Nil Then
    Exit;                          
  SaveDCIndex := SaveDC(hPaintDC);
  try
    SetBkMode(hPaintDC, TRANSPARENT);
    FillBg ( FCellRect,FBackGroundColor);
    DrawFrameLine();
    DrawDragon;
    DrawContentText ;
  finally
    RestoreDC(hPaintDC, SaveDCIndex);
  end;
End;

Constructor TReportCell.Create;
Var
  hTempDC: HDC;
  pt, ptOrg: TPoint;
Begin
  FCellsList := TList.Create;
  Fbmp := TBitmap.Create;
  FLeftMargin := 5;
  FOwnerLine := Nil;
  FOwnerCell := Nil;

  FCellIndex := -1;

  FCellLeft := 0;
  FCellWidth := 0;

  FCellRect.Left := 0;
  FCellRect.Top := 0;
  FCellRect.Right := 0;
  FCellRect.Bottom := 0;

  FTextRect.Left := 0;
  FTextRect.Top := 0;
  FTextRect.Right := 0;
  FTextRect.Bottom := 0;

  FDragCellHeight := 0;
  FMinCellHeight := 0;
  FRequiredCellHeight := 0;

  // border
  FLeftLine := True;
  FLeftLineWidth := 1;

  FTopLine := True;
  FTopLineWidth := 1;

  FRightLine := True;
  FRightLineWidth := 1;

  FBottomLine := True;
  FBottomLineWidth := 1;

  // 斜线
  FDiagonal := 0;

  // color
  FTextColor := RGB(0, 0, 0);
  FBackGroundColor := RGB(255, 255, 255);

  // align
  FHorzAlign := TEXT_ALIGN_LEFT;
  FVertAlign := TEXT_ALIGN_CENTER;

  // string
  FCellText := '';

  // font
  FLogFont.lfHeight := 120;
  FLogFont.lfWidth := 0;
  FLogFont.lfEscapement := 0;
  FLogFont.lfOrientation := 0;
  FLogFont.lfWeight := 0;
  FLogFont.lfItalic := 0;
  FLogFont.lfUnderline := 0;
  FLogFont.lfStrikeOut := 0;
  FLogFont.lfCharSet := DEFAULT_CHARSET;
  FLogFont.lfOutPrecision := 0;
  FLogFont.lfClipPrecision := 0;
  FLogFont.lfQuality := 0;
  FLogFont.lfPitchAndFamily := 0;
  FLogFont.lfFaceName := '宋体';

  // Hey, I pass a invalid window's handle to you, what you return to me ?
  // Haha, is a device context of the DESKTOP WINDOW !
  hTempDC := GetDC(0);

  pt.y := GetDeviceCaps(hTempDC, LOGPIXELSY) * FLogFont.lfHeight;
  pt.y := trunc(pt.y / 720 + 0.5);      // 72 points/inch, 10 decipoints/point
  DPtoLP(hTempDC, pt, 1);
  ptOrg.x := 0;
  ptOrg.y := 0;
  DPtoLP(hTempDC, ptOrg, 1);
  FLogFont.lfHeight := -abs(pt.y - ptOrg.y);
  ReleaseDC(0, hTempDC);

End;

Destructor TReportCell.Destroy;
Begin
  FCellsList.Free;
  FCellsList := Nil;
  fbmp.Free;
  Inherited Destroy;
End;

Function TReportCell.GetOwnerLineHeight: Integer;
Begin
  // LCJ :assert 
  Assert(FOwnerLine <> Nil );
  Result := FOwnerLine.LineHeight;
End;

Procedure TReportCell.CopyCell(Cell: TReportCell; bInsert: Boolean);
Begin
  FLeftMargin := Cell.FLeftMargin;

  // Index
  FCellIndex := Cell.FCellIndex;

  // size & position
  FCellLeft := Cell.FCellLeft;
  FCellWidth := Cell.FCellWidth;

  FCellRect.Left := 0;
  FCellRect.Top := 0;
  FCellRect.Right := 0;
  FCellRect.Bottom := 0;

  FTextRect.Left := 0;
  FTextRect.Top := 0;
  FTextRect.Right := 0;
  FTextRect.Bottom := 0;

  FDragCellHeight := Cell.FDragCellHeight;
  FMinCellHeight := Cell.FMinCellHeight;

  // border
  FLeftLine := Cell.FLeftLine;
  FLeftLineWidth := Cell.FLeftLineWidth;

  FTopLine := Cell.FTopLine;
  FTopLineWidth := Cell.FTopLineWidth;

  FRightLine := Cell.FRightLine;
  FRightLineWidth := Cell.FRightLineWidth;

  FBottomLine := Cell.FBottomLine;
  FBottomLineWidth := Cell.FBottomLineWidth;

  // 斜线
  FDiagonal := Cell.FDiagonal;

  // color
  FTextColor := Cell.FTextColor;
  FBackGroundColor := Cell.FBackGroundColor;

  // align
  FHorzAlign := Cell.FHorzAlign;
  FVertAlign := Cell.FVertAlign;

  // string
//  FCellText := Cell.FCellText;

  // font
  FLogFont := Cell.FLogFont;

  If Cell.OwnerCell <> Nil Then
  Begin
    If bInsert Then
    Begin
      Cell.OwnerCell.FCellsList.Insert(
        Cell.OwnerCell.FCellsList.IndexOf(Cell),
        Self);
      FOwnerCell := Cell.OwnerCell;
    End
    Else
      Cell.OwnerCell.AddOwnedCell(Self);
  End;
End;
Procedure TReportCell.SetCellDispformat(CellDispformat: String);
Begin
  If CellDispformat = FCellDispformat Then
    Exit;

  FCellDispformat := CellDispformat;

End;


Procedure TReportCell.RemoveOwnedCell(Cell: TReportCell);
Begin
  FCellsList.Remove(Cell);
  Cell.OwnerCell := Nil;
End;
// 一觉醒来，又是一个阳光灿烂的日子

///////////////////////////////////////////////////////////////////////////
// CReportLine



function TReportCell.IsLastCell: boolean;
begin
  //result := OwnerLine.FCells.IndexOf(Self) = OwnerLine.FCells.Count - 1;
  result := CellIndex = OwnerLine.FCells.Count - 1;
end;

{ TReportLine }
Procedure TReportLine.CalcLineHeight;
Var
  I: Integer;
  ThisCell: TReportCell;
Begin
  FMinHeight := 0;

  For I := 0 To FCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(FCells[I]);
    If ThisCell.CellHeight > FMinHeight Then
      FMinHeight := ThisCell.CellHeight;
    ThisCell.CellIndex := I;

    If (I = 0) And (ReportControl <> Nil) Then
      ThisCell.CellLeft := ReportControl.FLeftMargin;

    If I > 0 Then
      ThisCell.CellLeft := TReportCell(FCells[I - 1]).CellLeft +
        TReportCell(FCells[I - 1]).CellWidth;
  End;
End;

Procedure TReportLine.CopyLine(Line: TReportLine; bInsert: Boolean);
Var
  I: Integer;
  NewCell: TReportCell;
Begin
  If Line = Nil Then
    Exit;

  FDragHeight := 0;
  FMinHeight := 20;
  FReportControl := Line.FReportControl;

  For I := 0 To Line.FCells.Count - 1 Do
  Begin
    NewCell := TReportCell.Create;
    FCells.Add(NewCell);
    NewCell.FOwnerLine := Self;
    NewCell.CopyCell(Line.FCells[I], bInsert);
  End;
End;

Constructor TReportLine.Create;
Begin
  FReportControl := Nil;
  FCells := TList.Create;
  FIndex := 0;

  FMinHeight := 0;
  FDragHeight := 0;
  FLineTop := 0;
  FLineRect.left := 0;
  FLineRect.top := 0;
  FLineRect.right := 0;
  FLineRect.bottom := 0;
End;

Destructor TReportLine.Destroy;
Var
  I: Integer;
  ThisCell: TReportCell;
Begin
  For I := FCells.Count - 1 Downto 0 Do
  Begin
    ThisCell := TReportCell(FCells[I]);
    ThisCell.Free;
  End;

  FCells.Free;
  FCells := Nil;

  Inherited Destroy;
End;

Procedure TReportLine.CreateLine(LineLeft, CellNumber, PageWidth: Integer);
Var
  I: Integer;
  NewCell: TReportCell;
  CellWidth: Integer;
Begin
  CellWidth := trunc(PageWidth / CellNumber + 0.5);
  For I := 0 To CellNumber - 1 Do
  Begin
    NewCell := TReportCell.Create;
    FCells.Add(NewCell);
    NewCell.OwnerLine := Self;
    NewCell.CellIndex := I;
    NewCell.CellLeft := I * CellWidth + LineLeft;
    NewCell.CellWidth := CellWidth;
  End;
End;

Function TReportLine.GetLineHeight: Integer;
Begin
  If FMinHeight > FDragHeight Then
    Result := FMinHeight
  Else
    Result := FDragHeight;
End;

Function TReportLine.GetLineRect: TRect;
Var
  I: Integer;
Begin
  // 重新由各个CELL计算出该行的矩形来
  For I := 0 To FCells.Count - 1 Do
  Begin
    TReportCell(FCells[I]).CellIndex := I;
    TReportCell(FCells[I]).CalcCellTextRect;
  End;

  If FCells.Count > 0 Then
    Result.Left := TReportCell(FCells.First).CellLeft;
  Result.Top := FLineTop;
  Result.Bottom := Result.Top + LineHeight;
  Result.Right := Result.Left;

  For I := 0 To FCells.Count - 1 Do
    Result.Right := Result.Right + TReportCell(FCells[I]).CellWidth;

  FLineRect := Result;
End;

Procedure TReportLine.SetDragHeight(Const Value: Integer);
Begin
  FDragHeight := Value;
End;

Procedure TReportLine.SetLineTop(Const Value: Integer);
Var
  I: Integer;
Begin
  If FLineTop = Value Then
    Exit;

  FLineTop := Value;

  For I := 0 To FCells.Count - 1 Do
  Begin
    TReportCell(FCells[I]).CalcCellTextRect;
  End;
End;

///////////////////////////////////////////////////////////////////////////
// TReportControl

procedure TReportLine.Select;
begin
  self.FReportControl.SetCellsFocus(FIndex,0,FIndex,FCells.count -1);  
end;



{TReportControl}

Procedure TReportControl.CreateWnd;
Begin
  Inherited;

  If Handle <> INVALID_HANDLE_VALUE Then
    SetClassLong(Handle, GCL_HCURSOR, 0);
End;

Constructor TReportControl.Create(AOwner: TComponent);
Var
  hDesktopDC: HDC;
  nPixelsPerInch: Integer;
Begin
  Inherited Create(AOwner);
  PrintPaper:= TPrinterPaper.Create;
  // 设定为无光标，防止光标闪烁。
  //  Cursor := crNone;
  Cpreviewedit := true;                 //预览时是否允许编辑单元格中的字符
  FPreviewStatus := False;

  Color := clWhite;
  FLineList := TList.Create;
  FSelectCells := TCellList.Create(Self);

  FEditCell := Nil;

  FNewTable := True;
  FDataLine := 2000;
  FTablePerPage := 1;                   

  FLastPrintPageWidth := 0;
  FLastPrintPageHeight := 0;

  FReportScale := 100;
  FPageWidth := 0;
  FPageHeight := 0;

  hDesktopDC := GetDC(0);
  nPixelsPerInch := GetDeviceCaps(hDesktopDC, LOGPIXELSX);

  FLeftMargin1 := 20;
  FRightMargin1 := 10;
  FTopMargin1 := 20;
  FBottomMargin1 := 15;

  FLeftMargin := trunc(nPixelsPerInch * FLeftMargin1 / 25 + 0.5);
  FRightMargin := trunc(nPixelsPerInch * FRightMargin1 / 25 + 0.5);
  FTopMargin := trunc(nPixelsPerInch * FTopMargin1 / 25 + 0.5);
  FBottomMargin := trunc(nPixelsPerInch * FBottomMargin1 / 25 + 0.5);

  ReleaseDC(0, hDesktopDC);

  // 鼠标操作支持
  FMousePoint.x := 0;
  FMousePoint.y := 0;

  // 编辑、颜色及字体
  FEditWnd := INVALID_HANDLE_VALUE;
  FEditBrush := INVALID_HANDLE_VALUE;
  FEditFont := INVALID_HANDLE_VALUE;
  CalcWndSize;
End;

Destructor TReportControl.Destroy;
Var
  I: Integer;
  ThisLine: TReportLine;
Begin
  FSelectCells.Free;
  FSelectCells := Nil;

  For I := FLineList.Count - 1 Downto 0 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    ThisLine.Free;
  End;

  FLineList.Free;
  FLineList := Nil;
  PrintPaper.Free;
  Inherited Destroy;
End;


Procedure TReportControl.CalcWndSize;
Var
  hClientDC: HDC;
  function MapDots(FromHandle:THandle;ToHandle:THandle;FromLen:Integer):Integer;
  begin
    result := trunc(FromLen / GetDeviceCaps(FromHandle,LOGPIXELSX)
        * GetDeviceCaps(ToHandle, LOGPIXELSX) + 0.5);
  end;
Begin
  If printer.Printers.Count <= 0 Then
  Begin
    If FLastPrintPageWidth <> 0 Then
    Begin
      FPageWidth := FLastPrintPageWidth;
      FPageHeight := FLastPrintPageHeight;
    End;
  End;

  // 根据用户选择的纸来确定报表窗口的大小并对该窗口进行设置。

  If FLastPrintPageWidth = 0 Then
  Begin
    If printer.Printers.Count <= 0 Then
    Begin
      FPageWidth := 768;
      FPageHeight := 1058;
    End
    Else
    Begin
      hClientDC := GetDC(0);
      try
        FPageWidth :=MapDots(Printer.Handle, hClientDC,Printer.PageWidth);
        FPageHeight :=MapDots(Printer.Handle, hClientDC,Printer.PageHeight);
      finally
        ReleaseDC(0, hClientDC);
      end;
    End;
  End;
  FLastPrintPageWidth := FPageWidth;
  FLastPrintPageHeight := FPageHeight;
  Width := trunc(FPageWidth * FReportScale / 100 + 0.5);   
  Height := trunc(FPageHeight * FReportScale / 100 + 0.5);
End;

Procedure TReportControl.WMPaint(Var Message: TMessage);
Var
  hPaintDC: HDC;
  ps: TPaintStruct;
  I, J: Integer;
  TempRect: TRect;
  hGrayPen, hPrevPen: HPEN;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  WndSize: TSize;
  rectPaint: TRect;

  Acanvas: Tcanvas;                     // add lzl
  //x,y:integer;
  LTempRect: Trect;

Begin

  hPaintDC := BeginPaint(Handle, ps);

  SetMapMode(hPaintDC, MM_ISOTROPIC);
  WndSize.cx := Width;
  WndSize.cy := Height;
  SetWindowExtEx(hPaintDC, FPageWidth, FPageHeight, @WndSize);
  SetViewPortExtEx(hPaintDC, Width, Height, @WndSize);

  rectPaint := ps.rcPaint;

  If FReportScale <> 100 Then
  Begin
    rectPaint.Left := trunc(rectPaint.Left * 100 / FReportScale + 0.5);
    rectPaint.Top := trunc(rectPaint.Top * 100 / FReportScale + 0.5);
    rectPaint.Right := trunc(rectPaint.Right * 100 / FReportScale + 0.5);
    rectPaint.Bottom := trunc(rectPaint.Bottom * 100 / FReportScale + 0.5);
  End;

  Rectangle(hPaintDC, 0, 0, FPageWidth, FPageHeight);

  hGrayPen := CreatePen(PS_SOLID, 1, RGB(128, 128, 128));
  hPrevPen := SelectObject(hPaintDC, hGrayPen);

  // 左上
  MoveToEx(hPaintDC, FLeftMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FLeftMargin, FTopMargin - 25);

  MoveToEx(hPaintDC, FLeftMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FLeftMargin - 25, FTopMargin);

  // 右上
  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin, FTopMargin - 25);

  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin + 25, FTopMargin);

  // 左下
  MoveToEx(hPaintDC, FLeftMargin, FPageHeight - FBottomMargin, Nil);
  LineTo(hPaintDC, FLeftMargin, FPageHeight - FBottomMargin + 25);

  MoveToEx(hPaintDC, FLeftMargin, FPageHeight - FBottomMargin, Nil);
  LineTo(hPaintDC, FLeftMargin - 25, FPageHeight - FBottomMargin);

  // 右下
  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FPageHeight - FBottomMargin,
    Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin, FPageHeight - FBottomMargin + 25);

  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FPageHeight - FBottomMargin,
    Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin + 25, FPageHeight - FBottomMargin);

  SelectObject(hPaintDC, hPrevPen);
  DeleteObject(hGrayPen);

  ///////////////////////////////////////////////////////////////////////////
    // 绘制所有与失效区相交的矩形
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    {
        if ThisLine.LineRect.Bottom < ps.rcPaint.top then
          Continue;

        if ThisLine.LineTop > ps.rcPaint.bottom then
          Break;
    }
    For J := 0 To TReportLine(FLineList[i]).FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If ThisCell.CellRect.Left > rectPaint.Right Then
        Break;

      If ThisCell.CellRect.Right < rectPaint.Left Then
        Continue;

      If ThisCell.CellRect.Top > rectPaint.Bottom Then
        Break;

      If ThisCell.CellRect.Bottom < rectPaint.Top Then
        Continue;

      Acanvas := Tcanvas.Create;
      Acanvas.Handle := getdc(Handle);
      //Acanvas.Draw(x,y,loadbmp(thiscell));
      LTempRect := ThisCell.FCellRect;
      LTempRect.Left := trunc((Thiscell.FCellRect.Left) * FReportScale / 100 +
        0.5) + 3;
      LTempRect.Top := trunc((Thiscell.FCellRect.Top) * FReportScale / 100 + 0.5)
        + 3;
      LTempRect.Right := trunc((Thiscell.FCellRect.Right) * FReportScale / 100 +
        0.5) - 3;
      LTempRect.Bottom := trunc((Thiscell.FCellRect.Bottom) * FReportScale / 100
        + 0.5) - 3;
      acanvas.StretchDraw(LTempRect, loadbmp(thiscell));
      ReleaseDC(Handle, ACanvas.Handle);
      ACanvas.Free;

      If ThisCell.OwnerCell = Nil Then
        ThisCell.PaintCell(hPaintDC, FPreviewStatus);
    End;
  End;

  If Not FPreviewStatus Then
  Begin
    For I := 0 To FSelectCells.Count - 1 Do
    Begin
      IntersectRect(TempRect, ps.rcPaint,
        TReportCell(FSelectCells[I]).CellRect);
      If (TempRect.right >= TempRect.Left) And (TempRect.bottom >= TempRect.top)
        Then
        InvertRect(hPaintDC, TempRect);
    End;
  End;

  // 划线的算法目前还没有想出来
  // 各个CELL之间表线重叠的部分如何处理，如何存储这些线的设置呢？显然，现在的方法太土了。

  // 改乐，如果右面的CELL或下面的CELL的左边线或上边线为0时，不画不就得乐。(1998.9.9)

  EndPaint(Handle, ps);

End;

Procedure TReportControl.WMLButtonDBLClk(Var Message: TMessage);
Var
  ThisCell: TReportCell;
  TempPoint: TPoint;
  dwStyle: DWORD;
Begin
  If Not Cpreviewedit Then              
  Begin
    Inherited;
    exit;
  End;
  ClearSelect;
  GetCursorPos(TempPoint);
  Windows.ScreenToClient(Handle, TempPoint);

  ThisCell := CellFromPoint(TempPoint);

  If (ThisCell <> Nil) And (ThisCell.CellWidth > 10) Then
  Begin
    FEditCell := ThisCell;

    If FEditFont <> INVALID_HANDLE_VALUE Then
      DeleteObject(FEditFont);

    FEditFont := CreateFontIndirect(ThisCell.LogFont);

    // 设置编辑窗的字体
    If IsWindow(FEditWnd) Then
    Begin
      DestroyWindow(FEditWnd);
    End;

    //// Edit Window's Position
    Case ThisCell.HorzAlign Of
      TEXT_ALIGN_LEFT:
        dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_LEFT Or
          ES_AUTOVSCROLL;
      TEXT_ALIGN_CENTER:
        dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_CENTER Or
          ES_AUTOVSCROLL;
      TEXT_ALIGN_RIGHT:
        dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_RIGHT Or
          ES_AUTOVSCROLL;
    Else
      dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_LEFT Or
        ES_AUTOVSCROLL;
    End;

    FEditWnd := CreateWindow('EDIT', '', dwStyle, 0, 0, 0, 0, Handle, 1,
      hInstance, Nil);

    SendMessage(FEditWnd, WM_SETFONT, FEditFont, 1); // 1 means TRUE here.
    SendMessage(FEditWnd, EM_LIMITTEXT, 3000, 0);

    MoveWindow(FEditWnd, ThisCell.TextRect.left, ThisCell.TextRect.Top,
      ThisCell.TextRect.Right - ThisCell.TextRect.Left,
      ThisCell.TextRect.Bottom - ThisCell.TextRect.Top, True);
    SetWindowText(FEditWnd, PChar(ThisCell.CellText));
    ShowWindow(FEditWnd, SW_SHOWNORMAL);
    Windows.SetFocus(FEditWnd);
  End;
  Inherited;
End;

Procedure TReportControl.WMLButtonDown(Var Message: TMessage);
Var
  ThisCell: TReportCell;
  MousePoint: TPoint;
  TempChar: Array[0..3000] Of Char;
  TempMsg: TMSG;
  TempRect: TRect;
  sh_down: byte;
Begin
  MousePoint.x := LOWORD(Message.lParam);
  MousePoint.y := HIWORD(Message.lParam);
  ThisCell := CellFromPoint(MousePoint);

  sh_down := message.wparam;            //当拖动时，按下SHIFT键时不取消已选单元格
  If freportscale <> 100 Then //按下Mouse键，并缩放率<>100时，恢复为正常
  Begin                                 //1999.1.23
    freportscale := 100;
    CalcWndSize;
    Update;
    exit;
  End;

  If IsWindowVisible(FEditWnd) Then
  Begin
    If FEditCell <> Nil Then
    Begin
      GetWindowText(FEditWnd, TempChar, 3000);
      FEditCell.CellText := TempChar;
    End;
    // 奇怪，ReportControl窗口一旦得到焦点就移动自己
    Windows.SetFocus(0);
    DestroyWindow(FEditWnd);
    FEditCell := Nil;
  End;

  // 清除消息队列中的WM_PAINT消息，防止画出飞线
  While PeekMessage(TempMsg, 0, WM_PAINT, WM_PAINT, PM_NOREMOVE) Do
  Begin
    If Not GetMessage(TempMsg, 0, WM_PAINT, WM_PAINT) Then
      Break;

    DispatchMessage(TempMsg);
  End;

  If ThisCell = Nil Then
    StartMouseSelect(MousePoint, True, sh_down)
  Else
  Begin
    TempRect := ThisCell.CellRect;

    If (abs(TempRect.Bottom - MousePoint.y) <= 3) Or
      (abs(TempRect.Right - MousePoint.x) <= 3) Then
      StartMouseDrag(MousePoint)
    Else
      StartMouseSelect(MousePoint, True, sh_down);
  End;
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); 

  Inherited;                            //将mouse的消息返回   1999.1.23

End;

Procedure TReportControl.WMMouseMove(Var Message: TMessage);
Var
  ThisCell: TReportCell;
  MousePoint: TPoint;
  RectCell: TRect;
Begin
  MousePoint.x := LOWORD(Message.lParam);
  MousePoint.y := HIWORD(Message.lParam);
  ThisCell := CellFromPoint(MousePoint);

  If ThisCell <> Nil Then
  Begin
    RectCell := ThisCell.CellRect;
    If (abs(RectCell.Right - MousePoint.x) <= 3) Then
      SetCursor(LoadCursor(0, IDC_SIZEWE))
    Else If (abs(RectCell.Bottom - MousePoint.y) <= 3) Then
      SetCursor(LoadCursor(0, IDC_SIZENS))
    Else
      SetCursor(LoadCursor(0, IDC_IBEAM));
  End
  Else
    SetCursor(LoadCursor(0, IDC_ARROW));

  Inherited;                            //将mouse的消息返回   1999.1.23
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
  TempCell, TempNextCell, ThisCell, NextCell: TReportCell;
  ThisCellsList: TList;
  TempRect, RectBorder, RectCell, RectClient: TRect;
  hClientDC: HDC;
  hInvertPen, hPrevPen: HPEN;
  PrevDrawMode, PrevCellWidth, Distance: Integer;
  I, J: Integer;
  bHorz, bSelectFlag: Boolean;
  ThisLine, TempLine: TReportLine;
  TempMsg: TMSG;
  BottomCell: TReportCell;
  Top: Integer;
  //  CellList : TList;
  DragBottom: Integer;
Begin
  ThisCell := CellFromPoint(point);
  RectCell := ThisCell.CellRect;
  FMousePoint := point;
  Windows.GetClientRect(Handle, RectClient);
  ThisCellsList := TList.Create;

  // 设置线形和绘制模式
  hClientDC := GetDC(Handle);
  hInvertPen := CreatePen(PS_DOT, 1, RGB(0, 0, 0));
  hPrevPen := SelectObject(hClientDC, hInvertPen);

  PrevDrawMode := SetROP2(hClientDC, R2_NOTXORPEN);

  // 置横向标志
  If abs(RectCell.Bottom - point.y) <= 3 Then
    bHorz := True
  Else
    bHorz := False;
  // 计算上下左右边界
  ThisLine := ThisCell.OwnerLine;
  RectBorder.Top := ThisLine.LineTop + 5;
  RectBorder.Bottom := Height - 10;
  RectBorder.Right := ClientRect.Right;

  NextCell := Nil;

  For I := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    TempCell := TReportCell(ThisLine.FCells[I]);

    If ThisCell = TempCell Then
    Begin
      RectBorder.Left := ThisCell.CellLeft + 10;

      If I < ThisLine.FCells.Count - 1 Then
      Begin
        NextCell := TReportCell(ThisLine.FCells[I + 1]);
        RectBorder.Right := NextCell.CellLeft + NextCell.CellWidth - 10;
      End
      Else
        RectBorder.Right := ClientRect.Right - 10;
    End;
  End;

  If Not bHorz Then
  Begin
    // 若无选中的CELL,或者要改变宽度的CELL和NEXTCELL不在选中区中
    bSelectFlag := False;

    If FSelectCells.Count <= 0 Then
      bSelectFlag := True;

    If NextCell = Nil Then
    Begin
      If (Not IsCellSelected(ThisCell)) And (Not IsCellSelected(NextCell)) Then
        bSelectFlag := True;
    End
    Else If (Not IsCellSelected(ThisCell)) And (Not IsCellSelected(NextCell))
      And
      (Not IsCellSelected(NextCell.OwnerCell)) Then
      bSelectFlag := True;

    If bSelectFlag Then
    Begin
      For I := 0 To FLineList.Count - 1 Do
      Begin
        TempLine := TReportLine(FLineList[I]);
        For J := 0 To TempLine.FCells.Count - 1 Do
        Begin
          TempCell := TReportCell(TempLine.FCells[J]);
          // 若该CELL的右边等于选中的CELL的右边，将该CELL和NEXTCELL加入到两个LIST中去
          If TempCell.CellRect.Right = ThisCell.CellRect.Right Then
          Begin
            ThisCellsList.Add(TempCell);

            If TempCell.CellLeft + 10 > RectBorder.Left Then
              RectBorder.Left := TempCell.CellLeft + 10;

            If J < TempLine.FCells.Count - 1 Then
            Begin
              TempNextCell := TReportCell(TempLine.FCells[J + 1]);
              If TempNextCell.CellRect.Right - 10 < RectBorder.Right Then
                RectBorder.Right := TempNextCell.CellRect.Right - 10;
            End;
          End;
        End;
      End;
    End
    Else
    Begin
      For I := 0 To FLineList.Count - 1 Do
      Begin
        TempLine := TReportLine(FLineList[I]);
        TempNextCell := Nil;
        For J := 0 To TempLine.FCells.Count - 1 Do
        Begin
          TempCell := TReportCell(TempLine.FCells[J]);
          // 若该CELL的右边等于选中的CELL的右边，将该CEL加入到LIST中去
          // 前提是CELL或NEXTCELL在选中区内
          If (TempCell.CellRect.Right = ThisCell.CellRect.Right) Then
          Begin
            If J < TempLine.FCells.Count - 1 Then
              TempNextCell := TReportCell(TempLine.FCells[J + 1]);

            If (Not IsCellSelected(TempNextCell)) And (Not
              IsCellSelected(TempCell)) Then
              Break;

            If TempNextCell <> Nil Then
            Begin
              If TempNextCell.CellRect.Right - 10 < RectBorder.Right Then
                RectBorder.Right := TempNextCell.CellRect.Right - 10;
            End;

            ThisCellsList.Add(TempCell);

            If TempCell.CellLeft + 10 > RectBorder.Left Then
              RectBorder.Left := TempCell.CellLeft + 10;

            Break;
          End;
        End;
      End;
    End;
  End;

  // 画第一条线
  If bHorz Then
  Begin
    FMousePoint.y := trunc(FMousePoint.y / 5 * 5 + 0.5);

    If FMousePoint.y < RectBorder.Top Then
      FMousePoint.y := RectBorder.Top;

    If FMousePoint.y > RectBorder.Bottom Then
      FMousePoint.y := RectBorder.Bottom;

    MoveToEx(hClientDC, 0, FMousePoint.y, Nil);
    LineTo(hClientDC, RectClient.Right, FMousePoint.y);
    SetCursor(LoadCursor(0, IDC_SIZENS));
  End
  Else
  Begin
    FMousePoint.x := trunc(FMousePoint.x / 5 * 5 + 0.5);

    If FMousePoint.x < RectBorder.Left Then
      FMousePoint.x := RectBorder.Left;

    If FMousePoint.x > RectBorder.Right Then
      FMousePoint.x := RectBorder.Right;

    MoveToEx(hClientDC, FMousePoint.x, 0, Nil);
    LineTo(hClientDC, FMousePoint.x, RectClient.Bottom);
    SetCursor(LoadCursor(0, IDC_SIZEWE));
  End;

  SetCapture(Handle);

  // 取得鼠标输入，进入第二个消息循环
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
        If bHorz Then
        Begin
          MoveToEx(hClientDC, 0, FMousePoint.y, Nil);
          LineTo(hClientDC, RectClient.Right, FMousePoint.y);
          FMousePoint := TempMsg.pt;
          Windows.ScreenToClient(Handle, FMousePoint);

          // 边界检查
          FMousePoint.y := trunc(FMousePoint.y / 5 * 5 + 0.5);

          If FMousePoint.y < RectBorder.Top Then
            FMousePoint.y := RectBorder.Top;

          If FMousePoint.y > RectBorder.Bottom Then
            FMousePoint.y := RectBorder.Bottom;

          MoveToEx(hClientDC, 0, FMousePoint.y, Nil);
          LineTo(hClientDC, RectClient.Right, FMousePoint.y);
        End
        Else
        Begin
          MoveToEx(hClientDC, FMousePoint.x, 0, Nil);
          LineTo(hClientDC, FMousePoint.x, RectClient.Bottom);
          FMousePoint := TempMsg.pt;
          Windows.ScreenToClient(Handle, FMousePoint);

          // 边界检查
          FMousePoint.x := trunc(FMousePoint.x / 5 * 5 + 0.5);

          If FMousePoint.x < RectBorder.Left Then
            FMousePoint.x := RectBorder.Left;
          If FMousePoint.x > RectBorder.Right Then
            FMousePoint.x := RectBorder.Right;

          MoveToEx(hClientDC, FMousePoint.x, 0, Nil);
          LineTo(hClientDC, FMousePoint.x, RectClient.Bottom);
        End;
      WM_SETCURSOR:
        ;
    Else
      DispatchMessage(TempMsg);
    End;
  End;

  If GetCapture = Handle Then
    ReleaseCapture;

  If bHorz Then
  Begin
    // 将反显的线去掉
    MoveToEx(hClientDC, 0, FMousePoint.y, Nil);
    LineTo(hClientDC, RectClient.Right, FMousePoint.y);

    // 改变行高
    // 改变行高
    If ThisCell.FCellsList.Count <= 0 Then
    Begin
      // 不跨越其他CELL时
      BottomCell := ThisCell;
    End
    Else
    Begin
      // 跨越其他CELL时，取得最下一行的CELL
      BottomCell := Nil;
      Top := 0;
      For I := 0 To ThisCell.FCellsList.Count - 1 Do
      Begin
        If TReportCell(ThisCell.FCellsList[I]).CellTop > Top Then
        Begin
          BottomCell := TReportCell(ThisCell.FCellsList[I]);
          Top := BottomCell.CellTop;
        End;
      End;
    End;

    BottomCell.CalcEveryHeight;
    BottomCell.OwnerLine.LineHeight := FMousePoint.Y -
      BottomCell.OwnerLine.LineTop;
    UpdateLines;
  End
  Else
  Begin
    // 将反显的线去掉
    MoveToEx(hClientDC, FMousePoint.x, 0, Nil);
    LineTo(hClientDc, FMousePoint.x, RectClient.Bottom);

    // 在此处判断对CELL宽度的设定是否有效
    DragBottom := ThisCellsList.Count;

    For I := 0 To DragBottom - 1 Do
    Begin
      For J := 0 To TReportCell(ThisCellsList[I]).FCellsList.Count - 1 Do
      Begin
        ThisCellsList.Add(TReportCell(ThisCellsList[I]).FCellsList[J]);
      End;
    End;

    // 取得NEXTCELL
    If ThisCellsList.Count > 0 Then
    Begin
      ThisCell := TReportCell(ThisCellsList[0]);
      If ThisCell.CellIndex < ThisCell.OwnerLine.FCells.Count - 1 Then
        NextCell := TReportCell(ThisCell.OwnerLine.FCells[ThisCell.CellIndex +
          1]);

      // 右边的CELL不为空且隶属与某一CELL
      If NextCell <> Nil Then
      Begin
        If NextCell.OwnerCell <> Nil Then
        Begin
          SelectObject(hClientDC, hPrevPen);
          DeleteObject(hInvertPen);
          SetROP2(hClientDc, PrevDrawMode);
          ReleaseDC(Handle, hClientDC);
          Exit;
        End;
      End;

      DragBottom := 0;
      For I := 0 To ThisCellsList.Count - 1 Do
      Begin
        If TReportCell(ThisCellsList[I]).CellRect.Bottom > DragBottom Then
          DragBottom := TReportCell(ThisCellsList[I]).CellRect.Bottom;
      End;

      For I := 0 To ThisCellsList.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisCellsList[I]);
        If ThisCell.CellIndex < ThisCell.OwnerLine.FCells.Count - 1 Then
          NextCell := TReportCell(ThisCell.OwnerLine.FCells[ThisCell.CellIndex +
            1]);

        If NextCell <> Nil Then
        Begin
          If NextCell.CellRect.Bottom > DragBottom Then
          Begin
            SelectObject(hClientDC, hPrevPen);
            DeleteObject(hInvertPen);
            SetROP2(hClientDc, PrevDrawMode);
            ReleaseDC(Handle, hClientDC);
            Exit;
          End;
        End;
      End;
    End;

    For I := 0 To ThisCellsList.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisCellsList[I]);
      NextCell := Nil;
      If ThisCell.CellIndex < ThisCell.OwnerLine.FCells.Count - 1 Then
        NextCell := TReportCell(ThisCell.OwnerLine.FCells[ThisCell.CellIndex +
          1]);

      TempRect := ThisCell.CellRect;
      TempRect.Right := TempRect.Right + 1;
      TempRect.Bottom := TempRect.Bottom + 1;

      Distance := FMousePoint.x - ThisCell.CellLeft - ThisCell.CellWidth;

      PrevCellWidth := ThisCell.CellWidth;
      ThisCell.CellWidth := FMousePoint.x - ThisCell.CellLeft;

      If PrevCellWidth <> ThisCell.CellWidth Then
      Begin
        //        InvalidateRect(Handle, @TempRect, True);
        InvalidateRect(Handle, @TempRect, False);
        TempRect := ThisCell.CellRect;
        TempRect.Right := TempRect.Right + 1;
        TempRect.Bottom := TempRect.Bottom + 1;
        //        InvalidateRect(Handle, @TempRect, True);
        InvalidateRect(Handle, @TempRect, False);
      End;

      If NextCell <> Nil Then
      Begin
        TempRect := NextCell.CellRect;
        TempRect.Right := TempRect.Right + 1;
        TempRect.Bottom := TempRect.Bottom + 1;

        PrevCellWidth := NextCell.CellWidth;
        NextCell.CellLeft := NextCell.CellLeft + Distance;
        NextCell.CellWidth := NextCell.CellWidth - Distance;

        If PrevCellWidth <> NextCell.CellWidth Then
        Begin
          //          InvalidateRect(Handle, @TempRect, True);
          InvalidateRect(Handle, @TempRect, False);
          TempRect := NextCell.CellRect;
          TempRect.Right := TempRect.Right + 1;
          TempRect.Bottom := TempRect.Bottom + 1;
          //          InvalidateRect(Handle, @TempRect, True);
          InvalidateRect(Handle, @TempRect, False);
        End;
      End;
    End;

    UpdateLines;
  End;

  SelectObject(hClientDC, hPrevPen);
  DeleteObject(hInvertPen);
  SetROP2(hClientDc, PrevDrawMode);
  ReleaseDC(Handle, hClientDC);
End;

Procedure TReportControl.StartMouseSelect(point: TPoint; bSelectFlag: Boolean;
  shift_down: byte);
Var
  ThisCell: TReportCell;
  bFlag: Boolean;
  TempMsg: TMSG;
  TempPoint: TPoint;
  dwStyle: DWORD;
Begin
  // 清除掉所有选中的CELL 。当拖动时，按下SHIFT键时不取消已选单元格
  If shift_down <> 5 Then
    ClearSelect;
  ThisCell := CellFromPoint(point);

  If bSelectFlag Then
    AddSelectedCell(ThisCell);

  SetCapture(Handle);

  // 是选中还是编辑?
  bFlag := bSelectFlag;
  FMousePoint := point;

  //  Windows.ScreenToClient(Handle, FMousePoint);

  While GetCapture = Handle Do
  Begin
    If Not GetMessage(TempMsg, Handle, 0, 0) Then
    Begin
      PostQuitMessage(0);
      Break;
    End;

    Case TempMsg.Message Of
      WM_LBUTTONUP:
        ReleaseCapture;
      WM_MOUSEMOVE:
        If Not bFlag Then
        Begin
          TempPoint := TempMsg.pt;
          Windows.ScreenToClient(Handle, TempPoint);
          If CellFromPoint(TempPoint) <> ThisCell Then
            bFlag := True;
        End
        Else
        Begin
          AddSelectedCell(ThisCell);
          MouseMoveHandler(TempMsg);
        End;
    Else
      DispatchMessage(TempMsg);
    End;
    //inherited;
  End;

  // 如果用户的鼠标没有移出最初按下的CELL
  If Not bFlag Then
  Begin
    If (ThisCell <> Nil) And (ThisCell.CellWidth > 10) Then
    Begin
      FEditCell := ThisCell;

      If FEditFont <> INVALID_HANDLE_VALUE Then
        DeleteObject(FEditFont);

      FEditFont := CreateFontIndirect(ThisCell.LogFont);

      // 设置编辑窗的字体
      If IsWindow(FEditWnd) Then
      Begin
        DestroyWindow(FEditWnd);
      End;
      //// Edit Window's Position
      Case ThisCell.HorzAlign Of
        TEXT_ALIGN_LEFT:
          dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_LEFT Or
            ES_AUTOVSCROLL;
        TEXT_ALIGN_CENTER:
          dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_CENTER Or
            ES_AUTOVSCROLL;
        TEXT_ALIGN_RIGHT:
          dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_RIGHT Or
            ES_AUTOVSCROLL;
      Else
        dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_LEFT Or
          ES_AUTOVSCROLL;
      End;

      FEditWnd := CreateWindow('EDIT', '', dwStyle, 0, 0, 0, 0, Handle, 1,
        hInstance, Nil);

      SendMessage(FEditWnd, WM_SETFONT, FEditFont, 1); // 1 means TRUE here.
      SendMessage(FEditWnd, EM_LIMITTEXT, 3000, 0);

      MoveWindow(FEditWnd, ThisCell.TextRect.left, ThisCell.TextRect.Top,
        ThisCell.TextRect.Right - ThisCell.TextRect.Left,
        ThisCell.TextRect.Bottom - ThisCell.TextRect.Top, True);
      SetWindowText(FEditWnd, PChar(ThisCell.CellText));
      ShowWindow(FEditWnd, SW_SHOWNORMAL);
      Windows.SetFocus(FEditWnd);

    End;
  End;

  If GetCapture = Handle Then
    ReleaseCapture;

  // inherited;

End;

Procedure TReportControl.MouseMoveHandler(message: TMsg);
Var
  TempPoint: TPoint;
  RectSelection, TempRect: TRect;
  ThisCell: TReportCell;
  I, J: Integer;
  ThisLine: TReportLine;
  sh_down: byte;
Begin
  TempPoint := message.pt;
  sh_down := message.wParam;
  Windows.ScreenToClient(Handle, TempPoint);

  If FMousePoint.x > TempPoint.x Then
  Begin
    RectSelection.Left := TempPoint.x;
    RectSelection.Right := FMousePoint.x;
  End
  Else
  Begin
    RectSelection.Left := FMousePoint.x;
    RectSelection.Right := TempPoint.x;
  End;

  If FMousePoint.y > TempPoint.y Then
  Begin
    RectSelection.Top := TempPoint.y;
    RectSelection.Bottom := FMousePoint.y;
  End
  Else
  Begin
    RectSelection.Top := FMousePoint.y;
    RectSelection.Bottom := TempPoint.y;
  End;

  If RectSelection.Right = RectSelection.Left Then
    RectSelection.Right := RectSelection.Right + 1;

  If RectSelection.Bottom = RectSelection.Top Then
    RectSelection.Bottom := RectSelection.Bottom + 1;

  // 清除掉不在选中矩形中的CELL
  For I := FSelectCells.Count - 1 Downto 0 Do
  Begin
    ThisCell := TReportCell(FSelectCells[I]);
    IntersectRect(TempRect, ThisCell.CellRect, RectSelection);

    If sh_down <> 5 Then                //当拖动时，按下SHIFT键时不取消已选单元格
    Begin
      If Not ((TempRect.right > TempRect.Left) And (TempRect.bottom >
        TempRect.top)) Then
        RemoveSelectedCell(ThisCell);
    End;
  End;

  // 查找选中的Cell
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    IntersectRect(TempRect, RectSelection, ThisLine.LineRect);
    If (TempRect.right > TempRect.Left) And (TempRect.bottom > TempRect.top)
      Then
    Begin
      For J := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisLine.FCells[J]);
        IntersectRect(TempRect, RectSelection, ThisCell.CellRect);
        If (TempRect.right > TempRect.Left) And (TempRect.bottom > TempRect.top)
          And
          Not IsCellSelected(ThisCell) Then
        Begin
          If ThisCell.OwnerCell = Nil Then
            AddSelectedCell(ThisCell)
          Else If Not IsCellSelected(ThisCell.OwnerCell) Then
            AddSelectedCell(ThisCell.OwnerCell);
        End;
      End;
    End;
  End;

End;

Procedure TReportControl.AddLine;
Var
  TempLine: TReportLine;
Begin

  If Not CanAdd Then
    Exit;
  TempLine := TReportLine.Create;
  TempLine.ReportControl := Self;
  TempLine.LineTop := TReportLine(FLineList.Last).LineTop +
    TReportLine(FLineList.Last).LineHeight;
  TempLine.CopyLine(TReportLine(FLineList.Last), False);
  FLineList.Add(TempLine);
  TempLine.Index := FLineList.Count - 1;

  UpdateLines;
End;

Function TReportControl.CanAdd: Boolean;
Begin
  If FSelectCells.Count < 2 Then
    Result := True
  Else
    Result := False;
End;

Function TReportControl.CanInsert: Boolean;
Begin
  If FSelectCells.Count > 0 Then
    Result := True
  Else
    Result := False;
End;

Function TReportControl.CanSplit: Boolean;
Begin
  If (FSelectCells.Count = 1) Then
  Begin
    If TReportCell(FSelectCells.First).FCellsList.Count > 0 Then
      Result := True
    Else
      Result := False;
  End
  Else
    Result := False;
End;

Procedure TReportControl.CombineCell;
Var
  I, J: Integer;
  OwnerCell: TReportCell;
  ThisCell, FirstCell: TReportCell;
  ThisLine: TReportLine;
  TempLeft, TempRight: Integer;
  TempRect: TMyRect;
  LineArray :TList;
  procedure freeLineArray;
  begin
    While LineArray.Count > 0 Do
    Begin
      TMyRect(LineArray[0]).Free;
      LineArray.Delete(0);
    End;
    LineArray.Free;  
  end;
  function OutlineSelection(FSelectCells:TList):TList;
  var LineArray:TList;
  Var
    I, J, Count: Integer;
  begin
      LineArray := TList.Create;
      For I := 0 To FLineList.Count - 1 Do
      Begin
        TempRect := TMyRect.Create;
        TempRect.Left := 65535;
        TempRect.Top := 0;
        TempRect.Right := 0;
        TempRect.Bottom := 0;
        LineArray.Add(TempRect);
      End;
      For I := 0 To FSelectCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(FSelectCells[I]);
        If ThisCell.CellLeft < TMyRect(LineArray[ThisCell.OwnerLine.Index]).Left
          Then
          TMyRect(LineArray[ThisCell.OwnerLine.Index]).Left := ThisCell.CellLeft;

        If ThisCell.CellRect.Right >
          TMyRect(LineArray[ThisCell.OwnerLine.Index]).Right Then
          TMyRect(LineArray[ThisCell.OwnerLine.Index]).Right :=
            ThisCell.CellRect.Right;
      End;
      result := LineArray;
  end;
   // 将同一行上的单元格合并
  procedure CombineSameLineCell;
  Var
    I, J, Count: Integer;
    CellsToDelete: TList;
  begin
    LineArray := OutlineSelection(FSelectCells);
    CellsToDelete := TList.Create;

    For I := 0 To LineArray.Count - 1 Do
    Begin
      If TMyRect(LineArray[I]).Left = 65535 Then
        Continue;

      CellsToDelete.Clear;

      FirstCell := Nil;
      ThisLine := TReportLine(FLineList[I]);
      For J := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisLine.FCells[J]);
        If IsCellSelected(ThisCell) Then
        Begin
          If FirstCell = Nil Then
          Begin
            FirstCell := ThisCell;
          End
          Else
          Begin
            FirstCell.CellWidth := FirstCell.CellWidth + ThisCell.CellWidth;
            CellsToDelete.Add(ThisCell);
          End;
        End;
      End;             
      For J := CellsToDelete.Count - 1 Downto 0 Do
      Begin
        ThisLine.FCells.Remove(CellsToDelete[J]);
        RemoveSelectedCell(CellsToDelete[J]);
        TReportCell(CellsToDelete[J]).Free;
      End;
    End;
    freeLineArray;
    CellsToDelete.Free;
  end;
  procedure CombineSameColumnCell;
  Var
    I, J, Count: Integer;
    CellsToCombine: TList;
  begin
    LineArray := OutlineSelection(FSelectCells);
    //GET CellsToCombine 
    CellsToCombine := TList.Create;
    For I := 0 To LineArray.Count - 1 Do
    Begin
      If TMyRect(LineArray[I]).Left = 65535 Then
        Continue;        
      FirstCell := Nil;
      ThisLine := TReportLine(FLineList[I]);
      For J := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisLine.FCells[J]);
        If IsCellSelected(ThisCell) Then
        Begin
          If FirstCell = Nil Then
          Begin
            FirstCell := ThisCell;
            CellsToCombine.Add(ThisCell);
          End
        End;
      End;
    End;
    OwnerCell := TReportCell(CellsToCombine[0]);
    // 合并同一列的单元格 -- 只要将下面行的Cell加入到第一行内cell的OwneredCell即可
    For I := 1 To CellsToCombine.Count - 1 Do
    Begin
        OwnerCell.AddOwnedCell(TReportCell(CellsToCombine[I]));
        InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
    End;
    FreeLineArray;
    CellsToCombine.Free;
    ClearSelect;
    AddSelectedCell(OwnerCell);
  end;

  // LCJ : 描绘被选中的单元格的轮廓
Begin
  checkError(FSelectCells.Count >= 2,'请至少选择两个单元格');
  checkError(FSelectCells.IsRegularForCombine  ,'选择矩形不够规整，请重选');
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(FSelectCells[I]);
    For J := 0 To ThisCell.FCellsList.Count - 1 Do
      FSelectCells.Add(ThisCell.FCellsList[J]);
  End;
  CombineSameLineCell;
  CombineSameColumnCell; 
  UpdateLines;
  Self.Invalidate;
End;

Procedure TReportControl.DeleteLine;
Var
  I, J: Integer;
  LineArray: TList;
  ThisLineRect,BigRect: TRect;
  ThisCell: TReportCell;
  thisLine : TReportLine ;
Begin
  If FSelectCells.Count < 1 Then
    Exit;

  LineArray := TList.Create;

  For I := 0 To FLineList.Count - 1 Do
  Begin
    LineArray.Add(Nil);
  End;

  For I := 0 To FSelectCells.Count - 1 Do
    LineArray[TReportCell(FSelectCells[I]).OwnerLine.Index] :=
      TReportCell(FSelectCells[I]).OwnerLine;

  ClearSelect;

  For I := FLineList.Count - 1 Downto 0 Do
  Begin
    If LineArray[I] <> Nil Then
    Begin
      thisLine := TReportLine(FLineList[I]);
      ThisLineRect := thisLine.LineRect;
      ThisLineRect.Right := ThisLineRect.Right + 1;
      ThisLineRect.Bottom := ThisLineRect.Bottom + 1;
      windows.UnionRect(BigRect,BigRect,ThisLineRect);
      For J := 0 To thisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisLine.FCells[J]);
        If ThisCell.OwnerCell <> Nil Then
          ThisCell.OwnerCell.RemoveOwnedCell(ThisCell);

        If ThisCell.OwnedCellCount > 0 Then
          ThisCell.RemoveAllOwnedCell;
      End;
      TReportLine(FLineList[I]).Free;
      FLineList.Delete(I);
      //InvalidateRect(Handle, @ThisLineRect, False);
    End;
  End;
  InvalidateRect(Handle, @BigRect, False);
  LineArray.Free;
  UpdateLines;
End;

Procedure TReportControl.InsertLine;
Var
  NewLine,ThisLine: TReportLine;
Begin
  If Not CanInsert Then
    Exit;
  NewLine := TReportLine.Create;
  NewLine.ReportControl := Self;
  ThisLine  := TReportCell(FSelectCells[0]).OwnerLine ;
  NewLine.LineTop := ThisLine.LineTop;
  NewLine.CopyLine(ThisLine, True);
  NewLine.Index := ThisLine.Index;
  FLineList.Insert(ThisLine.Index, NewLine);   
  UpdateLines;
End;

Procedure TReportControl.NewTable(ColNumber, RowNumber: Integer);
Var
  I: Integer;
  FirstLine: TReportLine;
  PaintRect: TRect;
Begin
  If FLineList.Count > 0 Then
  Begin
    Application.Messagebox('关闭正在编辑的文件后，才能建立新表格。', '警告',
      MB_OK + MB_iconwarning);
    Exit;
  End;                      
  FirstLine := TReportLine.Create;
  FirstLine.ReportControl := Self;
  FirstLine.LineTop := FTopMargin;
  FirstLine.CreateLine(FLeftMargin, ColNumber, Width - FLeftMargin -
    FRightMargin);
  FirstLine.Index := 0;
  FLineList.Add(FirstLine);
  For I := 1 To RowNumber - 1 Do
    AddLine;
End;

Procedure TReportControl.SplitCell;
Var
  TempCell: TReportCell;
  I: Integer;
Begin
  If CanSplit Then
  Begin
    TempCell := TReportCell(FSelectCells[0]);
    ClearSelect;              
    AddSelectedCell(TempCell);
    For I := 0 To TempCell.FCellsList.Count - 1 Do
      InvalidateRect(Handle, @TReportCell(TempCell.FCellsList[I]).CellRect,False);
    // LCJ : 实际操作就是这一行代码
    TempCell.RemoveAllOwnedCell;
    UpdateLines;
  End;
End;

Procedure TReportControl.SetCellAlignHorzAlign(NewHorzAlign: Integer);
Var
  I: Integer;
Begin    
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).HorzAlign := NewHorzAlign;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
End;

Procedure TReportControl.SetCellAlignNewVertAlign(NewVertAlign: Integer);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).VertAlign := NewVertAlign;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
End;

Procedure TReportControl.SetCellBackColor(NewBackColor: COLORREF);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).BkColor := NewBackColor;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
End;

Procedure TReportControl.SetCellTextColor(NewTextColor: COLORREF);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).TextColor := NewTextColor;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
End;

Procedure TReportControl.SetCellColor(NewTextColor, NewBackColor: COLORREF);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).TextColor := NewTextColor;
    TReportCell(FSelectCells[I]).BkColor := NewBackColor;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
End;

Procedure TReportControl.SetCellAlign(NewHorzAlign, NewVertAlign: Integer);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).HorzAlign := NewHorzAlign;
    TReportCell(FSelectCells[I]).VertAlign := NewVertAlign;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
  UpdateLines;
End;

Procedure TReportControl.SetCellDiagonal(NewDiagonal: UINT);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).Diagonal := NewDiagonal;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;
End;
Procedure TReportControl.SetSelectedCellFont(cf: TFont);
var CellFont: TLOGFONT;
begin
      {$WARN UNSAFE_CODE OFF}
      GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
      {$WARN UNSAFE_CODE  ON}
      SetCellFont(CellFont);
end;
Procedure TReportControl.SetCellFont(CellFont: TLOGFONT);
Var
  I: Integer;
  CellRect: TRect;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).LogFont := CellFont;
    CellRect := TReportCell(FSelectCells[I]).CellRect;
    CellRect.Left := CellRect.left - 1;
    CellRect.Top := CellRect.top - 1;
    CellRect.Right := CellRect.Right + 1;
    CellRect.Bottom := CellRect.Bottom + 1;
    InvalidateRect(Handle, @CellRect, false);
  End;
  UpdateLines;

End;

Procedure TReportControl.SetCellLines(bLeftLine, bTopLine, bRightLine,
  bBottomLine: Boolean; nLeftLineWidth, nTopLineWidth, nRightLineWidth,
  nBottomLineWidth: Integer);
Var
  I: Integer;
  CellRect: TRect;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).LeftLine := bLeftLine;
    TReportCell(FSelectCells[I]).LeftLineWidth := nLeftLineWidth;

    TReportCell(FSelectCells[I]).TopLine := bTopLine;
    TReportCell(FSelectCells[I]).TopLineWidth := nTopLineWidth;

    TReportCell(FSelectCells[I]).RightLine := bRightLine;
    TReportCell(FSelectCells[I]).RightLineWidth := nRightLineWidth;

    TReportCell(FSelectCells[I]).BottomLine := bBottomLine;
    TReportCell(FSelectCells[I]).BottomLineWidth := nBottomLineWidth;

    CellRect := TReportCell(FSelectCells[I]).CellRect;
    CellRect.Left := CellRect.left - 1;
    CellRect.Top := CellRect.top - 1;
    CellRect.Right := CellRect.Right + 1;
    CellRect.Bottom := CellRect.Bottom + 1;
    InvalidateRect(Handle, @CellRect, false);
  End;
  UpdateLines;
End;

Procedure TReportControl.UpdateLines;
Var
  PrevRect, TempRect: TRect;
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
Begin
  // 首先计算合并后的单元格
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);

    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If ThisCell.FCellsList.Count > 0 Then
        ThisCell.CalcEveryHeight;
    End;
  End;

  // 计算每行的高度
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    ThisLine.CalcLineHeight;
  End;

  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);

    ThisLine.Index := I;

    If I = 0 Then
      ThisLine.LineTop := FTopMargin;
    If I > 0 Then
      ThisLine.LineTop := TReportLine(FLineList[I - 1]).LineTop +
        TReportLine(FLineList[I - 1]).LineHeight;

    PrevRect := ThisLine.PrevLineRect;
    TempRect := ThisLine.LineRect;

    If (PrevRect.Left <> TempRect.Left) Or (PrevRect.Top <> TempRect.Top) Or
      (PrevRect.Right <> TempRect.Right) Or (PrevRect.Bottom <> TempRect.Bottom)
      And
      (TempRect.top <= ClientRect.bottom) Then
    Begin
      For J := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisLine.FCells[J]);
        If ThisCell.OwnerCell <> Nil Then
          InvalidateRect(Handle, @ThisCell.OwnerCell.CellRect, False);
      End;
      PrevRect.Right := PrevRect.Right + 1;
      PrevRect.Bottom := PrevRect.Bottom + 1;
      TempRect.Right := TempRect.Right + 1;
      TempRect.Bottom := TempRect.Bottom + 1;
      InvalidateRect(Handle, @PrevRect, False);
      InvalidateRect(Handle, @TempRect, False);
    End;
  End;       
End;

procedure TReportControl.InvertCell(Cell:TReportCell);
Var
  hClientDC: HDC;
begin
    hClientDC := GetDC(Handle);
    InvertRect(hClientDC, Cell.CellRect);
    ReleaseDC(Handle, hClientDC);
end;

Function TReportControl.AddSelectedCell(Cell: TReportCell): Boolean;
Begin
  If IsCellSelected(Cell) Or (Cell = Nil) Then
    Result := False
  Else Begin
    FSelectCells.Add(Cell);
    InvertCell(Cell);
    Result := True;
  End;
End;

Function TReportControl.CellFromPoint(point: TPoint): TReportCell;
Var
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
Begin
  Result := Nil;

  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);

    If (Point.y >= ThisLine.LineTop) And (Point.y <= Thisline.LineTop +
      ThisLine.LineHeight) Then
    Begin
      For J := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(ThisLine.FCells[J]);

        If PtInRect(ThisCell.CellRect, point) Then
        Begin
          If ThisCell.OwnerCell <> Nil Then
            Result := ThisCell.OwnerCell
          Else
            Result := ThisCell;

          Break;
        End;
      End;
    End;
  End;
End;

Function TReportControl.IsCellSelected(Cell: TReportCell): Boolean;
Begin

  If Cell = Nil Then
  Begin
    Result := False;
    Exit;
  End;

  If FSelectCells.IndexOf(Cell) >= 0 Then
  Begin
    Result := True;
  End
  Else
    Result := False;
End;

Procedure TReportControl.ClearSelect;
Var
  ThisCell: TReportCell;
  hClientDC: HDC;
Begin
  hClientDC := GetDC(Handle);

  While FSelectCells.Count > 0 Do
  Begin
    ThisCell := TReportCell(FSelectCells.First);
    InvertRect(hClientDC, ThisCell.CellRect);
    FSelectCells.Remove(ThisCell);
  End;

  ReleaseDC(Handle, hClientDC);
End;

Function TReportControl.RemoveSelectedCell(Cell: TReportCell): Boolean;
Var
  hClientDC: HDC;
Begin
  If Not IsCellSelected(Cell) Then
    Result := False
  Else
  Begin
    hClientDC := GetDC(Handle);
    InvertRect(hClientDC, Cell.CellRect);
    ReleaseDC(Handle, hClientDC);
    FSelectCells.Remove(Cell);

    Result := True;
  End;
End;

Procedure TReportControl.WMCOMMAND(Var Message: TMessage);
Var
  r: TRect;
  TempChar: Array[0..3000] Of Char;
Begin
  Case HIWORD(Message.wParam) Of
    EN_UPDATE:
      If FEditCell <> Nil Then
      Begin
        r := FEditCell.TextRect;
        GetWindowText(FEditWnd, TempChar, 3000);
        FEditCell.CellText := TempChar;

        UpdateLines;

        If (r.Left <> FEditCell.TextRect.Left) Or
          (r.Top <> FEditCell.TextRect.Top) Or
          (r.Right <> FEditCell.TextRect.Right) Or
          (r.Bottom <> FEditCell.TextRect.Bottom) Then
        Begin
          MoveWindow(FEditWnd, FEditCell.TextRect.left, FEditCell.TextRect.Top,
            FEditCell.TextRect.Right - FEditCell.TextRect.Left,
            FEditCell.TextRect.Bottom - FEditCell.TextRect.Top, True);  
        End;
      End;
  End;
End;

Procedure TReportControl.WMCtlColor(Var Message: TMessage);
Var
  hTempDC: HDC;
  TempLogBrush: TLOGBRUSH;
Begin
  If FEditCell <> Nil Then
  Begin
    hTempDC := HDC(Message.WParam);
    SetBkColor(hTempDC, FEditCell.BkColor);
    SetTextColor(hTempDC, FEditCell.TextColor);

    If FEditBrush <> INVALID_HANDLE_VALUE Then
      DeleteObject(FEditBrush);

    TempLogBrush.lbStyle := PS_SOLID;
    TempLogBrush.lbColor := FEditCell.BkColor;
    FEditBrush := CreateBrushIndirect(TempLogBrush);

    Message.Result := FEditBrush;
  End;
End;

Procedure TReportControl.AddCell;
Var
  ThisLine: TReportLine;
  ThisCell, NewCell: TReportCell;
Begin
  If FSelectCells.Count <> 1 Then
    Exit;
  ThisCell := TReportCell(FSelectCells[0]);
  ThisLine := ThisCell.OwnerLine;
  NewCell := TReportCell.Create;
  NewCell.OwnerLine := ThisLine;
  NewCell.CopyCell(TReportCell(ThisLine.FCells[ThisLine.FCells.Count - 1]),
    False);
  NewCell.CellLeft := TReportCell(ThisLine.FCells[ThisLine.FCells.Count -
    1]).CellRect.Right;
  ThisLine.FCells.Add(NewCell);
  UpdateLines;

  // FSelectCells.Clear;

End;



Function TReportControl.CountFcells(crow: integer): integer;
Begin
  Result := TReportLine(FLineList[crow]).FCells.Count;
End;

Procedure TReportControl.DeleteCell;
Var
  I, J: Integer;
  ThisCell, TempCell: TReportCell;
  ThisLine: TReportLine;
Begin
  If FSelectCells.Count <= 0 Then
    Exit;

  For I := FSelectCells.Count - 1 Downto 0 Do
  Begin
    ThisCell := TReportCell(FSelectCells[I]);

    For J := ThisCell.FCellsList.Count - 1 Downto 0 Do
    Begin
      TempCell := TReportCell(Thiscell.FCellsList[J]);
      TempCell.OwnerLine.FCells.Remove(TempCell);
      TempCell.Free;
    End;

    ThisCell.FCellsList.Clear;

    ThisCell.OwnerLine.FCells.Remove(ThisCell);
    RemoveSelectedCell(ThisCell);
    ThisCell.Free;
  End;

  FSelectCells.Clear;

  UpdateLines;

  For I := FLineList.Count - 1 Downto 0 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    If ThisLine.FCells.Count <= 0 Then
    Begin
      FLineList.Remove(ThisLine);
      ThisLine.Free;
    End;
  End;
End;

Procedure TReportControl.InsertCell;
Var
  ThisCell, NewCell: TReportCell;
  ThisLine: TReportLine;
Begin
  If FSelectCells.Count <> 1 Then
    Exit;

  ThisCell := TReportCell(FSelectCells[0]);
  ThisLine := ThisCell.OwnerLine;
  NewCell := TReportCell.Create;
  NewCell.CopyCell(ThisCell, False);
  NewCell.OwnerLine := ThisCell.OwnerLine;

  ThisLine.FCells.Insert(ThisLine.FCells.IndexOf(ThisCell), NewCell);
  UpdateLines;
End;
function TReportControl.RenderText(ThisCell:TReportCell;PageNumber, Fpageall: Integer):String;
begin
    Result := ThisCell.FCellText;
end;

Procedure TReportControl.InternalSaveToFile(FLineList:TList;FileName: String;PageNumber, Fpageall:integer);
Var

  TargetFile: TFileStream;
  FileFlag: WORD;
  Count: Integer;
  I, J, K: Integer;
  ThisLine: TReportLine;
  ThisCell, TempCell: TReportCell;
  TempInteger: Integer;
  TempPChar: Array[0..3000] Of char;    
  strFileDir: String;
  celltext: String;
Begin
  TargetFile := TFileStream.Create(FileName, fmOpenWrite Or fmCreate);
  Try
    With TargetFile Do
    Begin  
      FileFlag := $AA57;
      Write(FileFlag, SizeOf(FileFlag));  
      Write(FReportScale, SizeOf(FReportScale));
      Write(FPageWidth, SizeOf(FPageWidth));
      Write(FPageHeight, SizeOf(FPageHeight));

      Write(FLeftMargin, SizeOf(FLeftMargin));
      Write(FTopMargin, SizeOf(FTopMargin));
      Write(FRightMargin, SizeOf(FRightMargin));
      Write(FBottomMargin, SizeOf(FBottomMargin));

      Write(FLeftMargin1, SizeOf(FLeftMargin));
      Write(FTopMargin1, SizeOf(FTopMargin));
      Write(FRightMargin1, SizeOf(FRightMargin));
      Write(FBottomMargin1, SizeOf(FBottomMargin));

      Write(FNewTable, SizeOf(FNewTable));
      Write(FDataLine, SizeOf(FDataLine));
      Write(FTablePerPage, SizeOf(FTablePerPage));

      // 多少行
      Count := FLineList.Count;
      Write(Count, SizeOf(Count));

      // 每行有多少个CELL
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        Count := ThisLine.FCells.Count;
        Write(Count, SizeOf(Count));
      End;

      // 每行的属性
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);

        Write(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Write(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Write(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Write(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Write(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // 每个CELL的属性
        For J := 0 To ThisLine.FCells.Count - 1 Do
        Begin
          ThisCell := TReportCell(ThisLine.FCells[J]);
          // Write Cell's Property here;
          Write(ThisCell.FLeftMargin, SizeOf(ThisCell.FLeftMargin));
          Write(ThisCell.FCellIndex, SizeOf(ThisCell.FCellIndex));

          Write(ThisCell.FCellLeft, SizeOf(ThisCell.FCellLeft));
          Write(ThisCell.FCellWidth, SizeOf(ThisCell.FCellWidth));

          Write(ThisCell.FCellRect, SizeOf(ThisCell.FCellRect));
          Write(ThisCell.FTextrect, SizeOf(ThisCell.FTextRect));

          Write(ThisCell.FDragCellHeight, SizeOf(ThisCell.FDragCellHeight));
          Write(ThisCell.FMinCellHeight, SizeOf(ThisCell.FMinCellHeight));
          Write(ThisCell.FRequiredCellHeight,
            SizeOf(ThisCell.FRequiredCellHeight));

          Write(ThisCell.FLeftLine, SizeOf(ThisCell.FLeftLine));
          Write(ThisCell.FLeftLineWidth, SizeOf(ThisCell.FLeftLineWidth));

          Write(ThisCell.FTopLine, SizeOf(ThisCell.FTopLine));
          Write(ThisCell.FTopLineWidth, SizeOf(ThisCell.FTopLineWidth));

          Write(ThisCell.FRightLine, SizeOf(ThisCell.FRightLine));
          Write(ThisCell.FRightLineWidth, SizeOf(ThisCell.FRightLineWidth));

          Write(ThisCell.FBottomLine, SizeOf(ThisCell.FBottomLine));
          Write(ThisCell.FBottomLineWidth, SizeOf(ThisCell.FBottomLineWidth));

          Write(ThisCell.FDiagonal, SizeOf(ThisCell.FDiagonal));

          Write(ThisCell.FTextColor, SizeOf(ThisCell.FTextColor));
          Write(ThisCell.FBackGroundColor, SizeOf(ThisCell.FBackGroundColor));

          Write(ThisCell.FHorzAlign, SizeOf(ThisCell.FHorzAlign));
          Write(ThisCell.FVertAlign, SizeOf(ThisCell.FVertAlign));

          CellText := RenderText(ThisCell,PageNumber, Fpageall);
          Count := Length(celltext);
          Write(Count, SizeOf(Count));
          StrPCopy(TempPChar, celltext);
          For K := 0 To Count - 1 Do
            Write(TempPChar[K], 1);

          Count := Length(ThisCell.FCellDispformat);
          Write(Count, SizeOf(Count));
          StrPCopy(TempPChar, ThisCell.FCellDispformat);
          For K := 0 To Count - 1 Do
            Write(TempPChar[K], 1);

          Write(thiscell.Fbmpyn, SizeOf(thiscell.FbmpYn)); //add lzl

          If thiscell.FbmpYn Then
            ThisCell.FBmp.SaveToStream(TargetFile);

          Write(ThisCell.FLogFont, SizeOf(ThisCell.FLogFont));

          // 属主CELL的行，列索引
          If ThisCell.FOwnerCell <> Nil Then
          Begin
            Write(ThisCell.FOwnerCell.OwnerLine.FIndex,
              SizeOf(ThisCell.FOwnerCell.OwnerLine.FIndex));
            Write(ThisCell.FOwnerCell.FCellIndex,
              SizeOf(ThisCell.FOwnerCell.FCellIndex));
          End
          Else
          Begin
            TempInteger := -1;
            Write(TempInteger, SizeOf(TempInteger));
            Write(TempInteger, SizeOf(TempInteger));
          End;

          Count := ThisCell.FCellsList.Count;
          Write(Count, SizeOf(Count));

          For K := 0 To ThisCell.FCellsList.Count - 1 Do
          Begin
            TempCell := TReportCell(ThisCell.FCellsList[K]);
            Write(TempCell.OwnerLine.FIndex, SizeOf(TempCell.OwnerLine.FIndex));
            Write(TempCell.FCellIndex, SizeOf(TempCell.FCellIndex));
          End;
        End;
      End;

      Begin
        Write(FprPageNo, SizeOf(FprPageNo));
        Write(FprPageXy, SizeOf(FprPageXy));
        Write(fPaperLength, SizeOf(fPaperLength));
        Write(fPaperWidth, SizeOf(fPaperWidth));
      End;
      Write(FHootNo, SizeOf(FHootNo));
    End;
  Finally
    TargetFile.Free;
  End;
End;
Procedure TReportControl.SaveToFile(FLineList:TList;FileName: String;PageNumber, Fpageall:integer);
Begin
  PrintPaper.prDeviceMode;
  PrintPaper.GetPaper(FprPageNo,FprPageXy,fpaperLength,fpaperWidth);
  InternalSavetoFile(FLineList,FileName,PageNumber, Fpageall);
End;

Procedure TReportControl.LoadFromFile(FileName: String);
Var
  TargetFile: TFileStream;
  FileFlag: WORD;
  Count1, Count2, Count3: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  I, J, K: Integer;
  TempPChar: Array[0..3000] Of Char;
Begin
  InternalLoadFromFile(FileName,Self.FLineList);
  PrintPaper.prDeviceMode;
  PrintPaper.SetPaper(FprPageNo,FprPageXy,fpaperLength,fpaperWidth);
  If IsWindowVisible(FEditWnd) Then
    DestroyWindow(FEditWnd);
  FLastPrintPageWidth := FPageWidth;             //1999.1.23
  FLastPrintPageHeight := FPageHeight;
  UpdateLines;

End;
Procedure TReportControl.InternalLoadFromFile(FileName:string;FLineList:TList);
Var
  TargetFile: TFileStream;
  FileFlag: WORD;
  Count1, Count2, Count3: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  I, J, K: Integer;
  TempPChar: Array[0..3000] Of Char;
  bHasDataSet: Boolean;
Begin
  TargetFile := TFileStream.Create(FileName, fmOpenRead);
  Try
    With TargetFile Do
    Begin
      Read(FileFlag, SizeOf(FileFlag));
      If (FileFlag <> $AA55) And (FileFlag <> $AA56) And (FileFlag <> $AA57)
        Then
        raise Exception.create('打开文件错误');
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        ThisLine.Free;
      End;

      FLineList.Clear;

      

      Read(FReportScale, SizeOf(FReportScale));
      Read(FPageWidth, SizeOf(FPageWidth));
      Read(FPageHeight, SizeOf(FPageHeight));
      Width := FPageWidth;
      Height := FPageHeight;
      Read(FLeftMargin, SizeOf(FLeftMargin));
      Read(FTopMargin, SizeOf(FTopMargin));
      Read(FRightMargin, SizeOf(FRightMargin));
      Read(FBottomMargin, SizeOf(FBottomMargin));

      Read(FLeftMargin1, SizeOf(FLeftMargin));
      Read(FTopMargin1, SizeOf(FTopMargin));
      Read(FRightMargin1, SizeOf(FRightMargin));
      Read(FBottomMargin1, SizeOf(FBottomMargin));

      Read(FNewTable, SizeOf(FNewTable));
      Read(FDataLine, SizeOf(FDataLine));
      Read(FTablePerPage, SizeOf(FTablePerPage));

      // 多少行
      Read(Count1, SizeOf(Count1));
      For I := 0 To Count1 - 1 Do
      Begin
        ThisLine := TReportLine.Create;
		  if (self is TReportControl) then
        	ThisLine.FReportControl := Self;
        FLineList.Add(ThisLine);
        Read(Count2, SizeOf(Count2));
        ThisLine.CreateLine(0, Count2, FRightMargin - FLeftMargin);
      End;

      // 每行的属性
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);

        Read(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Read(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Read(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Read(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Read(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // 每个CELL的属性
        For J := 0 To ThisLine.FCells.Count - 1 Do
        Begin
          ThisCell := TReportCell(ThisLine.FCells[J]);
          // Write Cell's Property here;
          Read(ThisCell.FLeftMargin, SizeOf(ThisCell.FLeftMargin));
          Read(ThisCell.FCellIndex, SizeOf(ThisCell.FCellIndex));

          Read(ThisCell.FCellLeft, SizeOf(ThisCell.FCellLeft));
          Read(ThisCell.FCellWidth, SizeOf(ThisCell.FCellWidth));

          Read(ThisCell.FCellRect, SizeOf(ThisCell.FCellRect));
          Read(ThisCell.FTextrect, SizeOf(ThisCell.FTextRect));

          Read(ThisCell.FDragCellHeight, SizeOf(ThisCell.FDragCellHeight));
          Read(ThisCell.FMinCellHeight, SizeOf(ThisCell.FMinCellHeight));
          Read(ThisCell.FRequiredCellHeight,
            SizeOf(ThisCell.FRequiredCellHeight));

          Read(ThisCell.FLeftLine, SizeOf(ThisCell.FLeftLine));
          Read(ThisCell.FLeftLineWidth, SizeOf(ThisCell.FLeftLineWidth));

          Read(ThisCell.FTopLine, SizeOf(ThisCell.FTopLine));
          Read(ThisCell.FTopLineWidth, SizeOf(ThisCell.FTopLineWidth));

          Read(ThisCell.FRightLine, SizeOf(ThisCell.FRightLine));
          Read(ThisCell.FRightLineWidth, SizeOf(ThisCell.FRightLineWidth));

          Read(ThisCell.FBottomLine, SizeOf(ThisCell.FBottomLine));
          Read(ThisCell.FBottomLineWidth, SizeOf(ThisCell.FBottomLineWidth));

          Read(ThisCell.FDiagonal, SizeOf(ThisCell.FDiagonal));

          Read(ThisCell.FTextColor, SizeOf(ThisCell.FTextColor));
          Read(ThisCell.FBackGroundColor, SizeOf(ThisCell.FBackGroundColor));

          Read(ThisCell.FHorzAlign, SizeOf(ThisCell.FHorzAlign));
          Read(ThisCell.FVertAlign, SizeOf(ThisCell.FVertAlign));

          Read(Count1, SizeOf(Count1));

          tempPchar := #0;
          For K := 0 To Count1 - 1 Do
            Read(TempPChar[K], 1);

          TempPChar[Count1] := #0;
          ThisCell.FCellText := StrPas(TempPChar);

          If FileFlag <> $AA55 Then
          Begin
            Read(Count1, SizeOf(Count1));

            tempPchar := #0;
            For K := 0 To Count1 - 1 Do
              Read(TempPChar[K], 1);
            TempPChar[Count1] := #0;
            ThisCell.FCellDispformat := StrPas(TempPChar);
          End;

          If FileFlag = $AA57 Then
          Begin
            read(thiscell.Fbmpyn, SizeOf(thiscell.FbmpYn)); // add lzl

            If thiscell.FbmpYn Then
              thiscell.FBmp.LoadFromStream(TargetFile);

          End;

          Read(ThisCell.FLogFont, SizeOf(ThisCell.FLogFont));

          Read(Count1, SizeOf(Count1));
          Read(Count2, SizeOf(Count2));

          If (Count1 < 0) Or (Count2 < 0) Then
            ThisCell.FOwnerCell := Nil
          Else
            ThisCell.FOwnerCell :=
              TReportCell(TReportLine(FLineList[Count1]).FCells[Count2]);

          Read(Count3, SizeOf(Count3));

          For K := 0 To Count3 - 1 Do
          Begin
            Read(Count1, SizeOf(Count1));
            Read(Count2, SizeOf(Count2));
            ThisCell.FCellsList.Add(TReportCell(TReportLine(FLineList[Count1]).FCells[Count2]));
          End;
        End;
      End;               

      Read(FprPageNo, SizeOf(FprPageNo));
      Read(FprPageXy, SizeOf(FprPageXy));
      Read(fpaperLength, SizeOf(fpaperLength));
      Read(fpaperWidth, SizeOf(fpaperWidth));
      Read(FHootNo, SizeOf(FHootNo));
    End;
  Finally
    TargetFile.Free;
  End;
End;
// 垂直切分单元格。一个单元格拆分成多个横向单元格（和OwnerCell无关
Procedure TReportControl.VSplitCell(Number: Integer);
Var
  ThisCell, TempCell, Cell2,ChildCell: TReportCell;
  xx, I, J, CellWidth, MaxCellCount: Integer;
Begin
  If FSelectCells.Count <> 1 Then
    Exit;

  ThisCell := TReportCell(FSelectCells[0]);
  InvalidateRect(Handle, @ThisCell.CellRect, False);

  MaxCellCount := trunc((ThisCell.CellRect.Right - ThisCell.CellRect.Left) / 12
    + 0.5);

  If MaxCellCount > Number Then
    MaxCellCount := Number;
  DoVertSplitCell(ThisCell,MaxCellCount);
  UpdateLines;
End;
Procedure TReportControl.DoVertSplitCell(ThisCell : TReportCell;SplitCount: Integer);
Var
  CurrentCell, Cell,ChildCell: TReportCell;
  xx, I, J, CellWidth: Integer;
Begin
  //平分后多余的宽度 , 修正折分后不能对齐的问题
  xx := (ThisCell.CellRect.Right - ThisCell.CellRect.Left) Mod SplitCount;
  // 每个Cell的Width
  CellWidth := trunc((ThisCell.CellRect.Right - ThisCell.CellRect.Left) /
    SplitCount);

  ThisCell.CellWidth := CellWidth;
  For J := 0 To ThisCell.FCellsList.Count - 1 Do
      TReportCell(ThisCell.FCellsList[J]).CellWidth := CellWidth;
  For I := 1 To SplitCount - 1 Do
  Begin
    CurrentCell := TReportCell.Create;
    CurrentCell.CopyCell(ThisCell, False);
    CurrentCell.OwnerLine := ThisCell.OwnerLine;
    If i = SplitCount - 1 Then
      CurrentCell.CellWidth := CellWidth + xx;
    if ThisCell.IsLastCell() then
      CurrentCell.OwnerLine.FCells.Add(CurrentCell)
    Else
      CurrentCell.OwnerLine.FCells.Insert(ThisCell.CellIndex  + 1, CurrentCell);

    For J := 0 To ThisCell.FCellsList.Count - 1 Do
    Begin
      Cell := TReportCell.Create;
      Cell.CopyCell(CurrentCell, False);
      CurrentCell.AddOwnedCell(Cell);
      ChildCell :=  TReportCell(ThisCell.FCellsList[J]);
      Cell.OwnerLine := ChildCell.OwnerLine;
      If ThisCell.IsLastCell  Then
        ChildCell.OwnerLine.FCells.Add(Cell)
      Else
        ChildCell.OwnerLine.FCells.Insert(ChildCell.CellIndex + 1,Cell);
    End;
  End;
End;
// 打印模板。就是不填入数据的情况下，把设计态表格打印出来 。
// 肯定只有一页，因此不需要考虑分页问题
Procedure TReportControl.PrintIt;
Var
  hPrinterDC: HDC;
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  PageSize: TSize;
  Ltemprect: Trect;
Begin
  Printer.Title := 'C_Report';
  Printer.BeginDoc;
  hPrinterDC := Printer.Handle;
  SetMapMode(hPrinterDC, MM_ISOTROPIC);
  PageSize.cx := Printer.PageWidth;
  PageSize.cy := Printer.PageHeight;
  SetWindowExtEx(hPrinterDC, Width, Height, @PageSize);
  SetViewPortExtEx(hPrinterDC, Printer.PageWidth, Printer.PageHeight,@PageSize);
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);         
    For J := 0 To TReportLine(FLineList[i]).FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]); 
      If ThisCell.OwnerCell = Nil Then
      Begin
        LTempRect := ThisCell.FCellRect;
        LTempRect.Left := ThisCell.FCellRect.Left + 3;
        LTempRect.Top := ThisCell.FCellRect.Top + 3;
        LTempRect.Right := ThisCell.FCellRect.Right - 3;
        LTempRect.Bottom := ThisCell.FCellRect.Bottom - 3;
        printer.Canvas.stretchdraw(LTempRect, ThisCell.fbmp);
        ThisCell.PaintCell(hPrinterDC, True);                
      End;   
    End;
  End;        
  Printer.EndDoc;
End;

// add by wang han song

Function TreportControl.GetCellFont: Tfont;
Var
  i: integer;
  AFont: TFont;
Begin
  Try
    afont := tfont.create;
    i := 0;
    If Fselectcells.count > 0 Then
    Begin
      afont.handle := createfontindirect(Treportcell(fselectcells[i]).logfont);
      result := afont;
    End
    Else
      result := Nil;
  Finally
    // afont.free;
  End;
End;

Function TReportControl.GetMargin: TRect;
Begin
  Result.Left := FLeftMargin1;
  Result.Top := FTopMargin1;
  Result.Right := FRightMargin1;
  Result.Bottom := FBottomMargin1;
End;

Procedure TReportControl.SetMargin(nLeftMargin, nTopMargin, nRightMargin,
  nBottomMargin: Integer);
Var
  RectClient: TRect;
  nPixelsPerInch: Integer;
  hTempDC: HDC;
Begin
  // 将毫米数转化为象素点
  If (FLeftMargin1 <> nLeftMargin) Or
    (FTopMargin1 <> nTopMargin) Or
    (FRightMargin1 <> nRightMargin) Or
    (FBottomMargin1 <> nBottomMargin) Then
  Begin
    hTempDC := GetDC(Handle);
    nPixelsPerInch := GetDeviceCaps(hTempDC, LOGPIXELSX);
    ReleaseDC(Handle, hTempDC);

    FLeftMargin1 := nLeftMargin;
    FTopMargin1 := nTopMargin;
    FRightMargin1 := nRightMargin;
    FBottomMargin1 := nBottomMargin;

    FLeftMargin := trunc(nLeftMargin * nPixelsPerInch / 25 + 0.5);
    FTopMargin := trunc(nTopMargin * nPixelsPerInch / 25 + 0.5);
    FRightMargin := trunc(nRightMargin * nPixelsPerInch / 25 + 0.5);
    FBottomMargin := trunc(nBottomMargin * nPixelsPerInch / 25 + 0.5);

    UpdateLines;
    RectClient := ClientRect;
    InvalidateRect(Handle, @RectClient, False);
  End;
End;

Procedure TReportControl.SetScale(Const Value: Integer);
Begin
  FReportScale := Value;
  CalcWndSize;
  Refresh;
End;

Procedure TReportControl.ResetContent;
Var
  I: Integer;
  ThisLine: TReportLine;
Begin
  FSelectCells.Clear;
  For I := FLineList.Count - 1 Downto 0 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    ThisLine.Free;
  End;
  FLineList.Clear;
  Refresh;
End;

  function TReportControl.GetNhassumall():Integer;
  var r : integer;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  TempDataSet: TDataset;
  khbz: boolean;
  begin
    r := 0 ;
    For i := HasDataNo + 1 To FlineList.Count - 1 Do
    Begin
      ThisLine := TReportLine(FlineList[i]);
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        If (Length(ThisCell.CellText) > 0) And
          (UpperCase(copy(ThisCell.FCellText, 1, 7)) = '`SUMALL') Then
        Begin
          If r = 0 Then
            r := i;
          result :=r ;
          break;
        End;
      End;                              //for j
    End;
    result  :=  0 ;
  end;
// 2014-11-17 张英华 酸菜 3根。好。
// SetFileCellWidth 根据用户拖动表格线修改模板文件中单元格的宽度
// 将变化后的单元格宽度存入全局变量数组 lzl


Procedure TReportControl.FreeEdit;      //取销编辑状态  lzl 
Begin
  If IsWindowVisible(FEditWnd) Then
  Begin
    If FEditCell <> Nil Then            //<>nil　
    Begin
      Windows.SetFocus(0);
      DestroyWindow(FEditWnd);
      FEditCell := Nil;
    End;
  End;
End;

Procedure TReportControl.SetCellDispFormt(mek: String); // lzl add
Var
  i: integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
    TReportCell(FSelectCells[I]).CellDispformat := mek;
End;

Procedure TReportControl.SetCellSumText(mek: String); // lzl add
Var
  i: integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
    TReportCell(FSelectCells[I]).celltext := mek;
End;


Procedure TReportControl.SetCellFocus(row, col: integer); // add lzl
Var
  thiscell: TreportCell;
  ThisLine: Treportline;
Begin
  ThisLine := TReportLine(FlineList[row]);
  ThisCell := TreportCell(ThisLine.FCells[col]);
  AddSelectedCell(ThisCell);
End;
Procedure TReportControl.SelectLine(row : integer);  // add lzl
Begin
  SetCellsFocus(row,0,row,TReportLine(FlineList[row]).FCells.Count -1);
End;
Procedure TReportControl.SelectLines(row1,row2 : integer);  // add lzl
Begin
  SetCellsFocus(row1,0,row2,TReportLine(FlineList[row1]).FCells.Count -1);
End;
Procedure TReportControl.SetCellsFocus(row1, col1, row2, col2: integer);  // add lzl
Var
  thiscell: TreportCell;
  ThisLine: Treportline;
  i, j: integer;
Begin
  For i := row1 To row2 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    For j := col1 To col2 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      AddSelectedCell(ThisCell);
    End;
  End;

End;


Procedure TReportControl.SetWndSize(w, h: integer); //add lzl
Begin
  FPageWidth := w;
  FPageHeight := h;
  FLastPrintPageWidth := FPageWidth;
  FLastPrintPageHeight := FPageHeight;
  Width := trunc(FPageWidth * FReportScale / 100 + 0.5); //width,heght用于显示
  Height := trunc(FPageHeight * FReportScale / 100 + 0.5);
End;

function TReportControl.Get(Index: Integer): TReportLine;
begin
  result := TReportLine(FLineList[Index ]);
end;


function TReportControl.GetCells(Row, Col: Integer): TReportCell;
begin
  result := TReportCell(TReportLine(FLineList[Row ]).FCells[Col]);
end;

Procedure TReportControl.savebmp(thiscell: Treportcell; filename: String);  // add lzl
Var
  Fpicture: Tpicture;
Begin

  Fpicture := Tpicture.Create;

  Fpicture.LoadFromFile(filename);

  thiscell.fbmp := TBitmap.Create;

  If Not (Fpicture.Graphic Is Ticon) Then
    thiscell.fbmp.Assign(Fpicture.Graphic)
  Else
  Begin
    thiscell.fbmp.Width := Fpicture.Icon.Width;
    thiscell.fbmp.Height := Fpicture.Icon.Height;
    thiscell.fbmp.Canvas.Draw(0, 0, Fpicture.Icon);
  End;

  thiscell.FbmpYn := true;
  ShowWindow(Handle, SW_HIDE);
  ShowWindow(Handle, SW_SHOW);
  Fpicture := Nil;
  Fpicture.Free;
End;

Function TReportControl.LoadBmp(thiscell: Treportcell): TBitmap; // add lzl
Begin
  result := thiscell.FBmp;
End;

Procedure TReportControl.FreeBmp(thiscell: Treportcell);
Begin
  thiscell.FBmp := Nil;
  thiscell.FBmp.Free;

  thiscell.FbmpYn := false;
End;


procedure TReportControl.SaveToFile(FileName: String);
begin
  SaveToFile(FLineList,FileName,0,0);
end;

procedure TPrinterPaper.Batch;
begin
    prDeviceMode;
    SetPaperWithCurrent;
end;

procedure TPrinterPaper.Batch(FprPageNo,FprPageXy,fpaperLength,fpaperWidth:Integer);
begin
    prDeviceMode;
    SetPaper(FprPageNo,FprPageXy,fpaperLength,fpaperWidth);
end;

function TReportControl.ZoomRate(height,width,HConst,WConst:integer):Integer;
var z1,z2:integer;
begin
  if (height-HConst) < FLastPrintPageHeight then
    z1:=trunc(((height-HConst) / FLastPrintPageHeight)*100)
  else
    z1:=100;
  if (width-WConst) < FLastPrintPageWidth then
    z2:=trunc(((width-WConst) / FLastPrintPageWidth)*100)
  else
    z2:=100;
  if z1 <= z2 then
    result :=z1
  else
    result :=z2;
end;

{ TSelectedCells }

constructor TCellList.Create(ReportControl:TReportControl);
begin
  self.ReportControl := ReportControl;
end;

function TCellList.IsRegularForCombine(): Boolean;
var i,j:integer;
  bigrect : TRect;
  os : WindowsOS ;
  l : TReportLine;
  c : TReportCell;
begin
  result := true;
  os.SetRectEmpty (bigrect);
  try
    os := WindowsOS.Create;
    for i := 0 to Count -1 do
      bigrect := os.UnionRect(bigrect,TReportCell(Items[i]).CellRect);
    for i := 0 to ReportControl.FLineList.count -1 do  begin
      l := ReportControl.Lines[i];
      for j := 0 to l.FCells.Count -1 do begin
        c := l.FCells[j] ;
        if
        os.Contains(bigrect,c.CellRect) and
        (c.OwnerCell = nil) and
        (not ReportControl.IsCellSelected(c)) then
        begin
          result := false;
          break;
        end;
      end;
    end;

  finally
    os.free;
  end;
end;

End.





