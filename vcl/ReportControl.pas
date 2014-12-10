
Unit ReportControl;

Interface

Uses
  Windows, Messages, SysUtils,Math,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice;
  function calcBottom(TempString:string ;TempRect:TRect;AlighFormat :UINT;FLogFont: TLOGFONT):Integer;
type
  TOnChanged = procedure(Sender:TObject;str:String) of object;
type
   TSimpleFileStream = class(TFileStream)
  private
   public
     procedure ReadWord(var a : Word);
     procedure ReadInteger(var a: Integer);
     procedure ReadBoolean(var a: Boolean);
     procedure ReadRect(var a:TRect);
     procedure ReadCardinal(var a:Cardinal);
     procedure ReadString(var a:String);
     procedure ReadTLOGFONT(var a:TLOGFONT);
     procedure WriteWord(a: Word);
     procedure WriteInteger(a: Integer);
     procedure WriteBoolean(a: Boolean);
     procedure WriteRect(a:TRect);
     procedure WriteCardinal(a:Cardinal);
     procedure WriteString(a:String);
     procedure WriteTLOGFONT(a:TLOGFONT);

   end;
type
  CellType = (ctOwnerCell,ctSlaveCell,ctNormalCell);
  TPrinterPaper = class
  private
    // google : msdn DEVMODE structure
    DevMode: PdeviceMode;
    //LCJ: ��ӡ�ļ���ֽ�ű�ţ����� A4��A3���Զ���ֽ�ŵȡ�
    FprPageNo: integer;
    // ֽ���ݺ᷽��  lzl
    FprPageXy: integer;
    // ֽ�ų��ȣ��߶ȣ�
    fpaperLength: integer;
    fpaperWidth: integer;
  private
    //ȡ�õ�ǰ��ӡ����DeviceMode�Ľṹ��Ա
  public
    procedure SetPaperWithCurrent;
    procedure Batch;overload;
    procedure Batch(FprPageNo,FprPageXy,fpaperLength,fpaperWidth:Integer);overload;
    Procedure prDeviceMode;
    procedure SetPaper(FprPageNo, FprPageXy, fpaperLength,
      fpaperWidth: Integer);
    procedure GetPaper(var FprPageNo, FprPageXy, fpaperLength,
      fpaperWidth: Integer);
  end;
Const
  // Horz Align
  TEXT_ALIGN_LEFT = 0;
  TEXT_ALIGN_CENTER = 1;
  TEXT_ALIGN_RIGHT = 2;

  // Vert Align
  TEXT_ALIGN_TOP = 0;
  TEXT_ALIGN_VCENTER = 1;
  TEXT_ALIGN_BOTTOM = 2;

  // б�߶���
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
  TLineList = class;
  TCellList = class(TList)
  private
    ReportControl:TReportControl;
    function Get(Index: Integer): TReportCell;
  public
    constructor Create(ReportControl:TReportControl);
    function IsRegularForCombine():Boolean;
    procedure MakeSelectedCellsFromLine(ThisLine:TReportLine);
    function TotalWidth:Integer;
    // How to implement indexed [] default property
    // http://stackoverflow.com/questions/10796417/how-to-implement-indexed-default-property
    property Items[Index: Integer]: TReportCell read Get ;default;
    procedure DeleteCells;
    procedure ColumnSelectedCells(FLineList:TLineList);
    procedure Fill(Cells :TCellList);
    function Last : TReportCell ;
    function CellRect:TRect;
  end;
  TLineList = class(TList)
  private                     
    R:TReportControl;
    function Get(Index: Integer): TReportLine;
  public
    constructor Create(R:TReportControl);
    procedure CombineHorz;
    property Items[Index: Integer]: TReportLine read Get ;default;
    procedure MakeSelectedLines(FLineList:TLineList);
    function CombineVert:TReportCell;
  end;
  TReportCell = Class(TObject)
  private
    NearResolution : integer;
    ReportControl:TReportControl;
    function GetOwnerCellHeight: Integer;
    function MaxSplitNum :integer;
    function GetBottomest(FOwnerCell: TReportCell): TReportCell;
    function GetTextHeight: Integer;
    procedure ExpandHeight(delta: integer);
  public
    function Calc_RequiredCellHeight: Integer;
    function GetReportControl: TReportControl;
    function GetSelected: Boolean;
    function GetTextRectInternal(Str: String): TRect;
    function NearBottom(P:TPoint):Boolean ;
    function NearRight(P:TPoint):Boolean ;
    function NearRightBottom(P:TPoint):Boolean ;

  public
    FLeftMargin: Integer;               // ��ߵĿո�
    FOwnerLine: TReportLine;            // ������
    FOwnerCell: TReportCell;            // Master Cell
    FSlaveCells: TCellList;             // Slave Cell
    // Index
    FCellIndex: Integer;                // Cell�����е�����
    // size & position
    FCellLeft: Integer;
    FCellWidth: Integer;
    FCellRect: TRect;                   // �������
    FTextRect: TRect;
    //   RequiredCellHeight �����ڿ��кϲ���Cell�б�� CellText��Ҫ�ĸ߶ȡ�������
    //  ��MinCellHeight,��������СCell�ĸ߶ȣ���������û�кϲ��Ͳ�֣�
    //  ���̶���ʾһ��cell�ĸ߶ȡ���ͨcell��  MinCellHeight���ϲ���cell������Ҫ��RequiredCellHeight
    //  �������:)
    FRequiredCellHeight: Integer;
    FCellHeight: Integer;
    // border
    FLeftLine: Boolean;
    FLeftLineWidth: Integer;
    FTopLine: Boolean;
    FTopLineWidth: Integer;
    FRightLine: Boolean;
    FRightLineWidth: Integer;
    FBottomLine: Boolean;
    FBottomLineWidth: Integer;   
    // б��
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
    // Cell��Height���Դ������кͿ�Խ����ȡ��
    Function GetCellHeight: Integer;
    // Cell��Top���Դ�����������ȡ��
    Function GetCellTop: Integer;
    Function GetOwnerLineHeight: Integer;
    function GetTextRect():TRect;
    function Payload: Integer;
    function IsNormalCell:Boolean;
  Protected
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
    procedure Load(stream:TSimpleFileStream;FileFlag:Word);
    procedure Save(s:TSimpleFileStream;PageNumber, Fpageall:integer);
    function GetCellType:CellType;
    function DefaultHeight(): integer;
    procedure Select;
    function IsLastCell():boolean;
    Procedure Own(Cell: TReportCell);overload;
    Procedure Own(Cell: TReportCell;bInsert:Boolean;InsertIndex:Integer);overload;
    Procedure LiberateSlaves;
    Procedure RemoveOwnedCell(Cell: TReportCell);
    Function IsCellOwned(Cell: TReportCell): Boolean;
    Procedure CalcCellTextRect;
    function IsOwnerCell :Boolean ;
    function IsBottomest():Boolean;
    Procedure CalcHeight;
    Procedure PaintCell(hPaintDC: HDC; bPrint: Boolean);
    // ��Cell�����ֵ� ��
    // ͬΪMasterCell�Ķ��ӡ����Ҳ��뵽 MasterCells�ڣ��Լ�λ��index֮ǰ
    procedure Sibling(Cell:TReportCell);
    Procedure CopyCell(Cell: TReportCell; bInsert: Boolean);overload;
    Procedure CopyCell(Cell: TReportCell; bInsert: Boolean;OwnerLine:TReportLine);overload;
    Constructor Create(R:TReportControl);
    Destructor Destroy; Override;
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
    Property OwnerLineHeight: Integer Read GetOwnerLineHeight;
    // border
    Property LeftLine: Boolean Read FLeftLine Write SetLeftLine Default True;
    Property LeftLineWidth: Integer Read FLeftLineWidth Write SetLeftLineWidth  Default 1;
    Property TopLine: Boolean Read FTopLine Write SetTopLine Default True;
    Property TopLineWidth: Integer Read FTopLineWidth Write SetTopLineWidth Default 1;
    Property RightLine: Boolean Read FRightLine Write SetRightLine Default True;
    Property RightLineWidth: Integer Read FRightLineWidth Write SetRightLineWidth Default 1;
    Property BottomLine: Boolean Read FBottomLine Write SetBottomLine Default True;
    Property BottomLineWidth: Integer Read FBottomLineWidth Write SetBottomLineWidth Default 1;
    // б��
    Property Diagonal: UINT Read FDiagonal Write FDiagonal;
    // color
    Property TextColor: COLORREF Read FTextColor Write SetTextColor Default                          clBlack;
    Property BkColor: COLORREF Read FBackGroundColor Write SetBackGroundColor Default clWhite;
    // align
    Property HorzAlign: Integer Read FHorzAlign Write FHorzAlign Default 1;
    Property VertAlign: Integer Read FVertAlign Write FVertAlign Default 1;
    // string
    Property CellText: String Read FCellText Write SetCellText;
    Property CellDispformat: String Read FCellDispformat Write SetCellDispformat;
    // font
    Property LogFont: TLOGFONT Read FLogFont Write SetLogFont;
    property R: TReportControl read GetReportControl;
    property IsSelected :Boolean read GetSelected;
  End;
  TReportLine = Class(TObject)
  private
    function GetSelected: Boolean;
    procedure DoInvalidate;
    procedure AddCell;
    procedure InsertCell(RefCell:TReportCell);
  public
    { Private declarations }
    FReportControl: TReportControl;     // Report Control��ָ��
    FCells: TList;                      // ���������ڸ����е�CELL
    FIndex: Integer;                    // �е�����

    FMinHeight: Integer;
    FDragHeight: Integer;
    FLineTop: Integer;
    FLineRect: TRect;
    Function GetLineHeight: Integer;
    Function GetLineRect: TRect;
    Procedure SetDragHeight(Const Value: Integer);
    Procedure SetLineTop(Const Value: Integer);
    procedure calcLineTop;

  Public
    procedure UpdateCellIndex;
    procedure UpdateCellLeft;
    procedure UpdateLineHeight;
    Property ReportControl: TReportControl Read FReportControl Write
      FReportControl;
    Property Index: Integer Read FIndex Write FIndex;
    Property LineHeight: Integer Read GetLineHeight Write SetDragHeight;
    Property LineTop: Integer Read FLineTop Write SetLineTop;
    Property LineRect: TRect Read GetLineRect;
    Property PrevLineRect: TRect Read FLineRect;
    property IsSelected : Boolean read GetSelected;
    Procedure CreateLine(LineLeft, CellNumber, PageWidth: Integer);
    Procedure CopyLine(Line: TReportLine; bInsert: Boolean);
    procedure Select ;
    Constructor Create;
    Destructor Destroy; Override;
    procedure DeleteCell(Cell:TReportCell);
    procedure CombineSelected;
    procedure CombineCells(Cells:TCellList);
    procedure Load (s:TSimpleFileStream);
    procedure Save(s:TSimpleFileStream);
  End;
  EachCellProc =  procedure (ThisCell:TReportCell) of object;
  EachLineProc =  procedure (ThisLine:TReportLine)of object;
  EachLineIndexProc = procedure (ThisLine:TReportLine;Index:Integer)of object;

  TReportControl = Class(TWinControl)
  private
    procedure InternalSaveToFile(
      FLineList: TList; FileName: String;PageNumber, Fpageall: integer);
    procedure DoInvalidateRect(Rect:TRect);
  protected
    FprPageNo,FprPageXy,fpaperLength,fpaperWidth: Integer;
    Cpreviewedit: boolean;
    FPreviewStatus: Boolean;

    FLineList: TLineList;
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
    //��β�ĵ�һ��������ҳ�ĵڼ���
    FHootNo: integer;
    // ��ҳ�ӱ�ͷ�����ӱ�ͷ��
    FNewTable: Boolean;
    // �����ӡ�����к���¼ӱ�ͷ
    FDataLine: Integer;
    FTablePerPage: Integer;
    // ������֧��
    FMousePoint: TPoint;
    // �༭���Լ�������ɫ������
    FEditWnd: HWND;
    FEditBrush: HBRUSH;
    FEditFont: HFONT;
    FOnChanged : TOnChanged;
    Os :WindowsOS ;
    Procedure SetCellSFocus(row1, col1, row2, col2: integer);
    function Get(Index: Integer): TReportLine;
    function GetCells(Row, Col: Integer): TReportCell;
    procedure InvertCell(Cell: TReportCell);
    procedure DoEdit(str:string);
    procedure DoMouseDown(P:TPoint;Shift:Boolean);
  Protected
    hasdatano: integer;
    function RenderText(ThisCell: TReportCell; PageNumber,Fpageall: Integer): String;virtual ;
    Procedure CreateWnd; Override;
    procedure InternalLoadFromFile(FileName:string;FLineList:TList);


  Public
    FLastPrintPageWidth, FLastPrintPageHeight: integer;
    PrintPaper:TPrinterPaper;
    function IsEditing :boolean;
    procedure CancelEditing;
    procedure EachCell(EachProc: EachCellProc);
    procedure EachLine(EachProc: EachLineProc);
    procedure EachCell_CalcHeight(ThisCell: TReportCell);
    procedure EachLineIndex(EachProc: EachLineIndexProc);
    procedure EachProc_UpdateIndex(thisLine: TReportLine; I: integer);
    procedure EachProc_UpdateLineRect(thisLine: TReportLine;
      Index: integer);
    procedure EachProc_UpdateLineTop(thisLine: TReportLine;
      I: integer);
    procedure EachCell_CalcMinCellHeight_If_Master(c: TReportCell);
    procedure EachLine_CalcLineHeight(c:TReportLine);

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
    property OnChanged : TOnChanged read FOnChanged write FOnChanged;
    procedure ClearPaintMessage;
    function MousePoint(Message: TMessage):TPoint;
    // Message Handler
    Procedure WMLButtonDown(Var m: TMessage); Message WM_LBUTTONDOWN;
    Procedure WMLButtonDBLClk(Var Message: TMessage); Message WM_LBUTTONDBLCLK;
    Procedure WMMouseMove(Var m: TMessage); Message WM_MOUSEMOVE;
    Procedure WMContextMenu(Var Message: TMessage); Message WM_CONTEXTMENU;
    Procedure WMPaint(Var Message: TMessage); Message WM_PAINT;
    Procedure WMCOMMAND(Var Message: TMessage); Message WM_COMMAND;
    Procedure WMCtlColor(Var Message: TMessage); Message WM_CTLCOLOREDIT;
    // Window size
    Procedure CalcWndSize;
    //�ڶ��嶯̬����ʱ,����ֽ�Ĵ�С ������windows�Ĵ�ӡ���öԿ�ʱ
    Procedure SetWndSize(w, h: integer);
    //��̬��������ֽ�Ŵ�С
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
    procedure DoVSplit(ThisCell:TReportCell;Number: Integer);
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
    //ȡ���༭״̬
    Procedure FreeEdit;
    Procedure StartMouseDrag(point: TPoint);
    Procedure StartMouseSelect(point: TPoint; bSelectFlag: Boolean; Shift: Boolean );
    Procedure MouseMoveHandler(message: TMSG);
    procedure SelectLine(row: integer);
    // ѡ�����Ĳ���
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
    property LineList : TLineList read FLineList;
    property Cells[Row: Integer;Col: Integer]: TReportCell read GetCells ;
    property  AllowPreviewEdit: boolean read CPreviewEdit write CPreviewEdit;
  Published
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


Procedure Register;
// 2014-11-13 ���������ںȡ�ƽ�ͣ����ӣ�ɢ������Ǯ�ĸо�...
//            ��˿�� Alectoria virens Tayl.������������ֲ�����ʪ����Ƣθ��
// 2014-11-13 encaplating...���Ѷ�������δ����Ψ����ͷ�����ͣ����Ͳ��Ρ�
// 2014-11-17 ��Load/Save 5��������С�ĵĴ���ϲ�����һ�����ֵĶԱȹ��ߺ���Ҫ��
//            winmerge��thank you
// 2014-11-19 ȫ�������ȫ�ֱ������Ѿ���ʧ��ת���������˿ɼ�����



  {
  �⹹����
   ========================
  �������У�������������ſ���������������...

 �����ӽ���Զ�ͳ�ȥ������֮�����죬ȴҲѹ��������

 ���������ҺȲɲ������е�������һ����������Զ������

 ΤС�����������ÿ���������Ҳ��֪������������˼��
  ����������������⸱��ɤ�ӣ�ȴ��ȥϷ̨�������棿�Ͻл����ſ��˺�����У�����
  ү̫̫��ʩ��Щ�и��䷹������Ҳ�������㡣��
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
  // LCJ : ��˵�úõ�A4���������ǽ�����ֽ״̬��:)
  if  FprPageNo = 0 then
    exit;
  with Devmode^ do  
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



Procedure Register;
Begin
  RegisterComponents('CReport', [TReportControl]);
End;

{TReportCell}   

Procedure TReportCell.SetLeftMargin(LeftMargin: Integer);
Begin
  // �޸�����Ԥ���Ŀհ�����.�Ǻǣ�Ŀǰֻ����5��
  If (LeftMargin = FLeftMargin) Or
    (LeftMargin < 5) Or (LeftMargin > 5) Then
    Exit;  
  FLeftMargin := LeftMargin;
  CalcHeight;
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
  Result := FSlaveCells.Count;
End;
procedure TReportCell.Own(Cell:TReportCell;bInsert:Boolean;InsertIndex:Integer);
Var
  I: Integer;
  List: TCellList;
Begin
  If (Cell = Nil) Or (FSlaveCells.IndexOf(Cell) >= 0) Then
    Exit;

  Cell.OwnerCell := Self;
  if bInsert then
      FSlaveCells.Insert(InsertIndex,Cell)
  else
    FSlaveCells.Add(Cell);
  FCellText := FCellText + Cell.CellText;
  Cell.CellText := ''; 
  
  // LCJ : �Ӹ�������˵��ֻ����SlaveCells������Щ�������Щ����
  if Cell.FSlaveCells.Count > 0 then
  begin
    // TODO :LCJ 
    {
     List.CopyFrom( Cell.FSlaveCells);
     Cell.LiberateSlaves();
     List.OwnerCell := Self;
     FSlaveCells.CopyFrom(List);
    }
    List := TCellList.Create(ReportControl);
    try
      For I := 0 To Cell.FSlaveCells.Count - 1 Do
        List.Add(Cell.FSlaveCells[I]);
      Cell.LiberateSlaves();
      For I := 0 To List.Count - 1 Do
      Begin
        FSlaveCells.Add(List[I]);
        List[I].OwnerCell := Self;
      End;
    finally
      List.Free ;
    end;
  end;
End;

Procedure TReportCell.Own(Cell: TReportCell);
Var
  I: Integer;
  TempCellList: TCellList;
Begin
  Own(Cell,false,0);
End;

Procedure TReportCell.LiberateSlaves;
Var
  I: Integer;
  Cell: TReportCell;
Begin
  For I := 0 To FSlaveCells.Count - 1 Do
  Begin
    Cell := FSlaveCells[I];
    Cell.SetOwnerCell(Nil);
    Cell.CalcHeight;
  End;                   
  FSlaveCells.Clear;
End;

Function TReportCell.IsCellOwned(Cell: TReportCell): Boolean;
Begin
  If FSlaveCells.IndexOf(Cell) >= 0 Then
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
var MinWidth : integer;
Begin
  MinWidth := 2*FLeftMargin;
  If CellWidth = FCellWidth Then
    Exit;

  If CellWidth > MinWidth Then
    FCellWidth := CellWidth
  Else
    FCellWidth := MinWidth;
  CalcHeight;
  CalcCellTextRect;
End;

Function TReportCell.GetCellHeight: Integer;
Begin
  Assert(FOwnerLine <> Nil );
  Result := FCellHeight;
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
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetLeftLineWidth(LeftLineWidth: Integer);
Begin
  If LeftLineWidth = FLeftLineWidth Then
    Exit;

  FLeftLineWidth := LeftLineWidth;
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetTopLine(TopLine: Boolean);
Begin
  If TopLine = FTopLine Then
    Exit;

  FTopLine := TopLine;
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetTopLineWidth(TopLineWidth: Integer);
Begin
  If TopLineWidth = FTopLineWidth Then
    Exit;

  FTopLineWidth := TopLineWidth;
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetRightLine(RightLine: Boolean);
Begin
  If RightLine = FRightLine Then
    Exit;

  FRightLine := RightLine;
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetRightLineWidth(RightLineWidth: Integer);
Begin
  If RightLineWidth = FRightLineWidth Then
    Exit;

  FRightLineWidth := RightLineWidth;
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetBottomLine(BottomLine: Boolean);
Begin
  If BottomLine = FBottomLine Then
    Exit;

  FBottomLine := BottomLine;
  CalcHeight;
  CalcCellTextRect;

End;

Procedure TReportCell.SetBottomLineWidth(BottomLineWidth: Integer);
Begin
  If BottomLineWidth = FBottomLineWidth Then
    Exit;

  FBottomLineWidth := BottomLineWidth;
  CalcHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetCellText(CellText: String);
Begin
  If CellText = FCellText Then
    Exit;

  FCellText := CellText;
  CalcHeight;

End;

Procedure TReportCell.SetLogFont(NewFont: TLOGFONT);
Begin
  FLogFont := NewFont;
  CalcHeight;
End;

Procedure TReportCell.SetBackGroundColor(BkColor: COLORREF);
Begin
  If BkColor = FBackGroundColor Then
    Exit;
  FBackGroundColor := BkColor;
End;

Procedure TReportCell.SetTextColor(TextColor: COLORREF);
Begin
  If TextColor = FTextColor Then
    Exit;
  FTextColor := TextColor;
End;
function TReportCell.GetTextHeight():Integer;
var r :TRect;
begin
  If FCellWidth <= FLeftMargin * 2 Then
    Result := 16 
  else begin
    r := GetTextRect();
    result := r.Bottom - r.Top ;
  end;
end;
function TReportCell.GetTextRect():TRect;
var s : string;
begin
  If (Length(FCellText) <= 0) Then
    s := '��'
  Else
    s := FCellText;
  result := GetTextRectInternal(s);
end;
function TReportCell.GetTextRectInternal(Str:String):TRect;
  function HAlign2DT(FHorzAlign:UINT):UINT;
  var dt : Integer ;
  begin
    Case FHorzAlign Of
      0:dt := DT_LEFT;
      1:dt := DT_CENTER;
      2:dt := DT_RIGHT;
      Else dt := DT_LEFT;
    End;
    Result := dt;
  end;        
var
  R:TRect;
begin
  ReportControl.Os.SetRectEmpty(R);   
  R.left := FCellLeft + FLeftMargin;
  R.top := GetCellTop + 2;
  R.right := FCellLeft + FCellWidth - FLeftMargin;
  R.bottom := CalcBottom( Str,R, HAlign2DT(FHorzAlign),FLogFont);
  result := R;
end;
function TReportCell.DefaultHeight() : integer; begin
  result := 16 + 2 + FTopLineWidth + FBottomLineWidth ;
end;

function TReportCell.Payload : Integer;
begin
  result := 2  + FTopLineWidth + FBottomLineWidth ;
end;
function TReportCell.GetOwnerCellHeight():Integer;
var
  BottomCell,ThisCell:TReportCell;
  I,Top,Height:Integer ;
begin
  Height := 0 ;
  For I := 0 To FSlaveCells.Count - 1 Do
  Begin
    ThisCell := FSlaveCells[i];
    ThisCell.OwnerLine.UpdateLineHeight ;
    Height := Height + ThisCell.OwnerLineHeight;
  End;
  result := Height + OwnerLineHeight;
end;
function TReportCell.Calc_RequiredCellHeight( ): Integer;
var Height : integer;  TempRect: TRect;
begin
  TempRect := GetTextRect();
  Height := 16 ;
  If TempRect.Bottom - TempRect.Top > 0 Then
    Height := TempRect.Bottom - TempRect.Top;
  result := Height  + Payload;
end;
// Ҫ��Cell ̫խ��խ���޷������κ����֣��Ͳ�Ҫ������ȥ����߶��ˡ�
// ֱ��Ĭ�� �ָ� 16 ���ɡ�
// û�� RightMargin ,ԭ���߰�RightMargin ��LeftMargin��ͬ������������� FLeftMargin * 2
Procedure TReportCell.CalcHeight;
Begin
//  if FCellHeight  = 0 then
//    FCellHeight := DefaultHeight;
  If FCellWidth <= FLeftMargin * 2 Then
    exit;
  if IsNormalCell  then
    FCellHeight := GetTextHeight + Payload ;
  if IsOwnerCell  then
    FSlaveCells.Last.ExpandHeight (Calc_RequiredCellHeight - GetOwnerCellHeight);
end;
procedure TReportCell.ExpandHeight(delta:integer);
begin
  if delta <= 0  Then
    Exit;
  inc (FCellHeight,delta);
end;

// Calc CellRect & TextRect here
// ���CELL�Ĵ�С�����ı���Ĵ�С�ı䣬�Զ����ô��ڵ�ʧЧ��
Procedure TReportCell.CalcCellTextRect;
  procedure CalcCellRect;
  Var
    I: Integer;
  begin
    FCellRect.left := FCellLeft;
    FCellRect.top := CellTop;
    FCellRect.right := FCellRect.left + FCellWidth;
    FCellRect.bottom := FCellRect.top + OwnerLineHeight;
    if IsOwnerCell then
      For I := 0 To FSlaveCells.Count - 1 Do
        Inc(FCellRect.Bottom,FSlaveCells[I].OwnerLineHeight);
  end;
  // TODO : �о���RequiredCellHeight ���ظ�������ͬһ���£��㷨��ͬ��
  procedure CalcTextRect;
  Var
    R: TRect;
    SpaceHeight,HalfSpaceHeight,TextHeight,RealHeight,delta: Integer;
    I: Integer;
  begin
    R := FCellRect;
    R.left := R.Left + FLeftMargin + 1;
    R.top := R.top + FTopLineWidth + 1;
    R.right := R.right - FLeftMargin - 1; 
    If IsOwnerCell Then begin
      TextHeight := Calc_RequiredCellHeight ;
      RealHeight := FCellRect.Bottom - FCellRect.Top ;
    end
    else begin
      TextHeight := FCellHeight ;
      RealHeight := OwnerLineHeight ;
    end;
    SpaceHeight := RealHeight - TextHeight ;
    HalfSpaceHeight := Ceil(SpaceHeight/ 2 );
    // R.bottom := R.top + TextHeight -( 2 + FTopLineWidth +FBottomLineWidth);
    // LCJ : ���Payload ��һ����ӣ�һ������ӵģ��������ء�
    R.bottom := R.top + TextHeight - Payload;
    Case FVertAlign Of
      TEXT_ALIGN_VCENTER:
      Begin
        delta :=  HalfSpaceHeight ;
        Inc(R.Top ,delta);
        Inc(R.Bottom , delta);
      End;
      TEXT_ALIGN_BOTTOM:
      Begin
        delta :=  SpaceHeight ;
        Inc(R.Top ,delta);
        Inc(R.Bottom , delta);
      End;
    End;         
    FTextRect := R;
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
    // ���Ʊ߿�
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

    // ����б��
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

Constructor TReportCell.Create(R:TReportControl);
Var
  hTempDC: HDC;
  pt, ptOrg: TPoint;
  procedure FillFont ;
  begin
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
    FLogFont.lfFaceName := '����';
    hTempDC := GetDC(0);          
    pt.y := GetDeviceCaps(hTempDC, LOGPIXELSY) * FLogFont.lfHeight;
    // 72 points/inch, 10 decipoints/point
    pt.y := trunc(pt.y / 720 + 0.5);
    DPtoLP(hTempDC, pt, 1);
    ptOrg.x := 0;
    ptOrg.y := 0;
    DPtoLP(hTempDC, ptOrg, 1);
    FLogFont.lfHeight := -abs(pt.y - ptOrg.y);
    ReleaseDC(0, hTempDC);
  end;
Begin
  self.ReportControl := R;
  NearResolution := 3;
  FSlaveCells := TCellList.Create(R);
  Fbmp := TBitmap.Create;
  FLeftMargin := 5;
  FOwnerLine := Nil;
  FOwnerCell := Nil;
  FCellHeight := 0;
  FRequiredCellHeight := 0;
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
  FLeftLine := True;
  FLeftLineWidth := 1;
  FTopLine := True;
  FTopLineWidth := 1;
  FRightLine := True;
  FRightLineWidth := 1; 
  FBottomLine := True;
  FBottomLineWidth := 1;
  FDiagonal := 0;
  FTextColor := RGB(0, 0, 0);
  FBackGroundColor := RGB(255, 255, 255);
  FHorzAlign := TEXT_ALIGN_LEFT;
  FVertAlign := TEXT_ALIGN_CENTER;
  FCellText := '';
  FillFont ;
End;

Destructor TReportCell.Destroy;
Begin
  FSlaveCells.Free;
  FSlaveCells := Nil;
  fbmp.Free;
  Inherited Destroy;
End;

Function TReportCell.GetOwnerLineHeight: Integer;
Begin
  Assert(FOwnerLine <> Nil );
  Result := FOwnerLine.LineHeight;
End;
Procedure TReportCell.CopyCell(Cell: TReportCell; bInsert: Boolean;OwnerLine:TReportLine);
begin
   CopyCell(cell,bInsert);
   self.OwnerLine := OwnerLine;
end;
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
  FCellHeight := Cell.FCellHeight;
  FLeftLine := Cell.FLeftLine;
  FLeftLineWidth := Cell.FLeftLineWidth;

  FTopLine := Cell.FTopLine;
  FTopLineWidth := Cell.FTopLineWidth;
  FRightLine := Cell.FRightLine;
  FRightLineWidth := Cell.FRightLineWidth;
  FBottomLine := Cell.FBottomLine;
  FBottomLineWidth := Cell.FBottomLineWidth;
  FDiagonal := Cell.FDiagonal;
  FTextColor := Cell.FTextColor;
  FBackGroundColor := Cell.FBackGroundColor;
  FHorzAlign := Cell.FHorzAlign;
  FVertAlign := Cell.FVertAlign;
  FLogFont := Cell.FLogFont;    
  If Cell.OwnerCell <> Nil Then
      Cell.Sibling(Self);
End;
Procedure TReportCell.SetCellDispformat(CellDispformat: String);
Begin
  If CellDispformat = FCellDispformat Then
    Exit;

  FCellDispformat := CellDispformat;

End;


Procedure TReportCell.RemoveOwnedCell(Cell: TReportCell);
Begin
  FSlaveCells.Remove(Cell);
  Cell.OwnerCell := Nil;
End;
function TReportCell.IsLastCell: boolean;
begin
  result := CellIndex = OwnerLine.FCells.Count - 1;
end;

procedure TReportCell.Select;
begin
  If not R.IsCellSelected(Self) Then
  Begin
    R.FSelectCells.Add(Self);
    R.InvertCell(Self);
  End;
end;

function TReportCell.GetReportControl: TReportControl;
begin
  Result := ReportControl ;
end;

function TReportCell.GetSelected: Boolean;
begin
  result := R.IsCellSelected(self);
end;



function TReportCell.GetBottomest(FOwnerCell:TReportCell):TReportCell;
var BottomCell,ThisCell:TReportCell;I,Top:Integer ;
begin
  BottomCell := Nil;
  Top := 0;
  For I := 0 To FOwnerCell.FSlaveCells.Count - 1 Do
  Begin
    ThisCell := FOwnerCell.FSlaveCells[i];
    If ThisCell.CellTop > Top Then
    Begin
      BottomCell := ThisCell;
      Top := ThisCell.CellTop;
    End;
  End;
  result := BottomCell;
end;
function TReportCell.IsBottomest: Boolean;   
begin
  result:= GetBottomest(OwnerCell) = Self ;
end;

function TReportCell.GetCellType: CellType;
begin
  if (FOwnerCell = nil) and (FSlaveCells.Count = 0) then begin
    result := ctNormalCell ;
    exit;
  end;
  if (FOwnerCell = nil) and (FSlaveCells.Count > 0) then begin
    result := ctOwnerCell ;
    exit;
  end;
  if FOwnerCell <> nil  then begin
    result := ctSlaveCell ;
    exit;
  end;                   
end;


function TReportCell.IsOwnerCell: Boolean;
begin
  Result := FSlaveCells.Count  >0 ;
end;

function TReportCell.IsNormalCell: Boolean;
begin
  result := ctNormalCell = GetCellType()
end;

procedure TReportCell.Load(stream: TSimpleFileStream;FileFlag:Word);
Var
  TargetFile: TSimpleFileStream;
  Count1, Count2, Count3: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  I, J, K: Integer;
  TempPChar: Array[0..3000] Of Char;
  bHasDataSet: Boolean;
begin
  with stream do
  begin
    ReadInteger(FLeftMargin);
    ReadInteger(FCellIndex);

    ReadInteger(FCellLeft);
    ReadInteger(FCellWidth);

    ReadRect(FCellRect);
    ReadRect(FTextRect);
    // LCJ :DELETE on the road
    ReadInteger(FCellHeight);
    ReadInteger(FCellHeight);
    ReadInteger(FRequiredCellHeight);

    ReadBoolean(FLeftLine);
    ReadInteger(FLeftLineWidth);

    ReadBoolean(FTopLine);
    ReadInteger(FTopLineWidth);

    ReadBoolean(FRightLine);
    ReadInteger(FRightLineWidth);

    ReadBoolean(FBottomLine);
    ReadInteger(FBottomLineWidth);

    ReadCardinal(FDiagonal);

    ReadCardinal(FTextColor);
    ReadCardinal(FBackGroundColor);

    ReadInteger(FHorzAlign);
    ReadInteger(FVertAlign);

    ReadString(FCellText);

    If FileFlag <> $AA55 Then
      ReadString(FCellDispformat);

    If FileFlag = $AA57 Then
    Begin
      read(Fbmpyn, SizeOf(FbmpYn));
      If FbmpYn Then
        FBmp.LoadFromStream(stream);
    End;

    ReadTLogFont(FLogFont);

    ReadInteger(Count1);
    ReadInteger(Count2);

    If (Count1 < 0) Or (Count2 < 0) Then
      FOwnerCell := Nil
    Else
      FOwnerCell :=
        TReportCell(TReportLine(Self.ReportControl. FLineList[Count1]).FCells[Count2]);

    ReadInteger(Count3);

    For K := 0 To Count3 - 1 Do
    Begin
      ReadInteger(Count1);
      ReadInteger(Count2);
      FSlaveCells.Add(TReportCell(TReportLine(Self.ReportControl.FLineList[Count1]).FCells[Count2]));
    End;
   end;
end;

procedure TReportCell.Save(s: TSimpleFileStream;PageNumber, Fpageall:integer);
var k :  integer;
begin
  with s do begin
    WriteInteger(FLeftMargin);
    WriteInteger(FCellIndex);

    WriteInteger(FCellLeft);
    WriteInteger(FCellWidth);

    WriteRect(FCellRect);
    WriteRect(FTextrect);
    // LCJ :DELETE on the road 
    WriteInteger(FCellHeight);
    WriteInteger(FCellHeight);
    WriteInteger(FRequiredCellHeight);

    WriteBoolean(FLeftLine);
    WriteInteger(FLeftLineWidth);

    WriteBoolean(FTopLine);
    WriteInteger(FTopLineWidth);

    WriteBoolean(FRightLine);
    WriteInteger(FRightLineWidth);

    WriteBoolean(FBottomLine);
    WriteInteger(FBottomLineWidth);

    WriteCardinal(FDiagonal);

    WriteCardinal(FTextColor );
    WriteCardinal(FBackGroundColor );

    WriteInteger(FHorzAlign);
    WriteInteger(FVertAlign);


    WriteString(Self.ReportControl.renderText(Self, PageNumber,  Fpageall));
    WriteString(FCellDispformat);

    WriteBoolean(Fbmpyn); 
    If FbmpYn Then
      FBmp.SaveToStream(s);
    WriteTLogFont(FLogFont);

    // ����CELL���У�������
    If FOwnerCell <> Nil Then
    Begin
      WriteInteger(FOwnerCell.OwnerLine.FIndex);
      WriteInteger(FOwnerCell.FCellIndex);
    End
    Else
    Begin
      WriteInteger(-1);
      WriteInteger(-1);
    End;                              
    WriteInteger(FSlaveCells.Count);
    For K := 0 To FSlaveCells.Count - 1 Do
    Begin
      WriteInteger(FSlaveCells[K].OwnerLine.FIndex);
      WriteInteger(FSlaveCells[K].FCellIndex);
    End;
  end;
end;

procedure TReportCell.Sibling(Cell: TReportCell);
begin
  OwnerCell.Own(Cell,true,OwnerCell.FSlaveCells.IndexOf(Self));
end;

function TReportCell.MaxSplitNum: integer;
var   MinCellWidth : Integer;
begin
  MinCellWidth :=12 ;
  result :=
    trunc((CellRect.Right - CellRect.Left) / MinCellWidth
    + 0.5);

end;

Procedure TReportLine.UpdateLineHeight;
Var
  I: Integer;
  ThisCell: TReportCell;
Begin
  For I := 0 To FCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(FCells[I]);
    If ThisCell.CellHeight > FMinHeight Then
      FMinHeight := ThisCell.CellHeight;
  End;
End;

Procedure TReportLine.UpdateCellIndex;
Var
  I: Integer;
  ThisCell: TReportCell;
Begin
  For I := 0 To FCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(FCells[I]);
    ThisCell.CellIndex := I;
  End;
End;
Procedure TReportLine.UpdateCellLeft;
Var
  I: Integer;
  ThisCell: TReportCell;
Begin
  For I := 0 To FCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(FCells[I]);
    If (I = 0) And (ReportControl <> Nil) Then
      ThisCell.CellLeft := ReportControl.FLeftMargin;
    // calc CellLeft
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
    NewCell := TReportCell.Create(self.ReportControl);
    FCells.Add(NewCell);
    NewCell.CopyCell(TReportCell( Line.FCells[I]), bInsert,Self);
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
    NewCell := TReportCell.Create(ReportControl);
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
  // �����ɸ���CELL��������еľ�����
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



function TReportLine.GetSelected: Boolean;
var j :Integer ;
begin
   result := false ;
   For J := 0 To Self.FCells.Count - 1 Do
   begin
    result := ReportControl.IsCellSelected(TReportCell(Self.FCells[J]));
    if Result  then
    begin
      result := true;
      break;
    end;
   end;             
end;

procedure TReportLine.DeleteCell(Cell: TReportCell);
begin
  FCells.Remove(Cell);
  Cell.Free;
end;

procedure TReportLine.CombineSelected;
Var
  I,J: Integer;
  Cells : TCellList;
begin
    If IsSelected Then
    Begin
      Cells := TCellList.Create(ReportControl);
      try
        Cells.MakeSelectedCellsFromLine(Self);
        CombineCells(Cells);
      finally
        Cells.Free;
      end;
    End;
end;

procedure TReportLine.CombineCells(Cells: TCellList);
Var
  I,J: Integer;
begin
  assert(cells <> nil);
  assert(cells.count > 0);
  Cells[0].CellWidth := Cells.TotalWidth;
  // ���˵�һ��Cell��ɾ��
  Cells.Delete(0);
  Cells.DeleteCells ;
end;

procedure TReportLine.Load(s: TSimpleFileStream);
begin
  s.ReadInteger(FIndex);
  s.ReadInteger(FMinHeight);
  s.ReadInteger(FDragHeight);
  s.ReadInteger(FLineTop);
  s.ReadRect(FLineRect);
end;

procedure TReportLine.Save(s: TSimpleFileStream);
begin
  with s do begin
    WriteInteger(FIndex);
    WriteInteger(FMinHeight);
    WriteInteger(FDragHeight);
    WriteInteger(FLineTop);
    WriteRect(FLineRect);
  end;
end;

procedure TReportLine.calcLineTop;
var
  PrevLine: TReportLine ;
begin
    If Index  = 0 Then
      LineTop := ReportControl.FTopMargin
    else begin
      PrevLine:=TReportLine(ReportControl.FLineList[Index - 1]);
      LineTop :=  PrevLine.LineTop + PrevLine.LineHeight;
    end;
end;

procedure TReportLine.InsertCell(RefCell:TReportCell);
var c:TReportCell;
begin
  c := TReportCell.Create(ReportControl);
  c.CopyCell(RefCell, False,Self);
  FCells.Insert(FCells.IndexOf(RefCell), c);
end;

function TReportCell.NearBottom(P: TPoint): Boolean;
begin
   result := abs(CellRect.Bottom - P.y) <= NearResolution ;
end;

function TReportCell.NearRight(P: TPoint): Boolean;
begin
   result := abs(CellRect.Right - P.x) <= NearResolution ;
end;

function TReportCell.NearRightBottom(P: TPoint): Boolean;
begin
  Result := NearBottom(P) Or NearRight(p)
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
  Os := WindowsOS.create;
  Parent := TWinControl(aOwner);
  PrintPaper:= TPrinterPaper.Create;
  // �趨Ϊ�޹�꣬��ֹ�����˸��
  //  Cursor := crNone;
  Cpreviewedit := true;                 //Ԥ��ʱ�Ƿ�����༭��Ԫ���е��ַ�
  FPreviewStatus := False;

  Color := clWhite;
  FLineList := TLineList.Create(self);
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

  // �Ժ���Ϊ��λ
  FLeftMargin1 := 20;
  FRightMargin1 := 10;
  FTopMargin1 := 20;
  FBottomMargin1 := 15;
  // ��DotΪ��λ
  //  hDesktopDC := GetDC(0);
  //  nPixelsPerInch := GetDeviceCaps(hDesktopDC, LOGPIXELSX);
  //  FLeftMargin := trunc(nPixelsPerInch * FLeftMargin1 / 25 + 0.5);
  //  FRightMargin := trunc(nPixelsPerInch * FRightMargin1 / 25 + 0.5);
  //  FTopMargin := trunc(nPixelsPerInch * FTopMargin1 / 25 + 0.5);
  //  FBottomMargin := trunc(nPixelsPerInch * FBottomMargin1 / 25 + 0.5);
  //  ReleaseDC(0, hDesktopDC);
  FLeftMargin := os.MM2Dot(FLeftMargin1);
  FRightMargin := os.MM2Dot(FRightMargin1);
  FTopMargin := os.MM2Dot(FTopMargin1);
  FBottomMargin := os.MM2Dot(FBottomMargin1);
  // ������֧��
  FMousePoint.x := 0;
  FMousePoint.y := 0;

  // �༭����ɫ������
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
  Os.Free;
  Inherited Destroy;
End;


Procedure TReportControl.CalcWndSize;
Var
  hClientDC: HDC;

Begin
  If printer.Printers.Count <= 0 Then
  Begin
    If FLastPrintPageWidth <> 0 Then
    Begin
      FPageWidth := FLastPrintPageWidth;
      FPageHeight := FLastPrintPageHeight;
    End;
  End;

  // �����û�ѡ���ֽ��ȷ�������ڵĴ�С���Ըô��ڽ������á�

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
        FPageWidth :=os.MapDots(Printer.Handle, hClientDC,Printer.PageWidth);
        FPageHeight :=os.MapDots(Printer.Handle, hClientDC,Printer.PageHeight);
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

  // ����
  MoveToEx(hPaintDC, FLeftMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FLeftMargin, FTopMargin - 25);

  MoveToEx(hPaintDC, FLeftMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FLeftMargin - 25, FTopMargin);

  // ����
  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin, FTopMargin - 25);

  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FTopMargin, Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin + 25, FTopMargin);

  // ����
  MoveToEx(hPaintDC, FLeftMargin, FPageHeight - FBottomMargin, Nil);
  LineTo(hPaintDC, FLeftMargin, FPageHeight - FBottomMargin + 25);

  MoveToEx(hPaintDC, FLeftMargin, FPageHeight - FBottomMargin, Nil);
  LineTo(hPaintDC, FLeftMargin - 25, FPageHeight - FBottomMargin);

  // ����
  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FPageHeight - FBottomMargin,
    Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin, FPageHeight - FBottomMargin + 25);

  MoveToEx(hPaintDC, FPageWidth - FRightMargin, FPageHeight - FBottomMargin,
    Nil);
  LineTo(hPaintDC, FPageWidth - FRightMargin + 25, FPageHeight - FBottomMargin);

  SelectObject(hPaintDC, hPrevPen);
  DeleteObject(hGrayPen);

  ///////////////////////////////////////////////////////////////////////////
    // ����������ʧЧ���ཻ�ľ���
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

  // ���ߵ��㷨Ŀǰ��û�������
  // ����CELL֮������ص��Ĳ�����δ�����δ洢��Щ�ߵ������أ���Ȼ�����ڵķ���̫���ˡ�

  // ���֣���������CELL�������CELL������߻��ϱ���Ϊ0ʱ���������͵��֡�(1998.9.9)

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

    // ���ñ༭��������
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

Procedure TReportControl.WMLButtonDown(Var m: TMessage);
Var
  p: TPoint;
  Shift: Boolean;
Begin
  If ReportScale <> 100 Then   //����Mouse������������<>100ʱ���ָ�Ϊ����
  Begin                                     
    ReportScale :=100 ;
    exit;
  End;
  p := MousePoint(m);
  Shift := m.wparam = 5 ;
  if IsEditing then CancelEditing;
  ClearPaintMessage;
  DoMouseDown(p,Shift );
  // ��һ��Ҫ�ǲ�д������˳��ĺ���Ͳ���ʹ��
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
      SetCursor(LoadCursor(0, IDC_SIZEWE))
    Else If ThisCell.NearBottom(p) Then
      SetCursor(LoadCursor(0, IDC_SIZENS))
    Else
      SetCursor(LoadCursor(0, IDC_IBEAM));
  End
  Else
    SetCursor(LoadCursor(0, IDC_ARROW));
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
  TempCell, TempNextCell, ThisCell, NextCell: TReportCell;
  ThisCellsList: TCellList;
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
  ThisCellsList := TCellList.Create(self);

  // �������κͻ���ģʽ
  hClientDC := GetDC(Handle);
  hInvertPen := CreatePen(PS_DOT, 1, RGB(0, 0, 0));
  hPrevPen := SelectObject(hClientDC, hInvertPen);

  PrevDrawMode := SetROP2(hClientDC, R2_NOTXORPEN);

  // �ú����־
  If abs(RectCell.Bottom - point.y) <= 3 Then
    bHorz := True
  Else
    bHorz := False;
  // �����������ұ߽�
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
    // ����ѡ�е�CELL,����Ҫ�ı��ȵ�CELL��NEXTCELL����ѡ������
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
          // ����CELL���ұߵ���ѡ�е�CELL���ұߣ�����CELL��NEXTCELL���뵽����LIST��ȥ
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
          // ����CELL���ұߵ���ѡ�е�CELL���ұߣ�����CEL���뵽LIST��ȥ
          // ǰ����CELL��NEXTCELL��ѡ������
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

  // ����һ����
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

  // ȡ��������룬����ڶ�����Ϣѭ��
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

          // �߽���
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

          // �߽���
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
    // �����Ե���ȥ��
    MoveToEx(hClientDC, 0, FMousePoint.y, Nil);
    LineTo(hClientDC, RectClient.Right, FMousePoint.y);

    // �ı��и�
    // �ı��и�
    If ThisCell.FSlaveCells.Count <= 0 Then
    Begin
      // ����Խ����CELLʱ
      BottomCell := ThisCell;
    End
    Else
    Begin
      // ��Խ����CELLʱ��ȡ������һ�е�CELL
      BottomCell := Nil;
      Top := 0;
      For I := 0 To ThisCell.FSlaveCells.Count - 1 Do
      Begin
        If ThisCell.FSlaveCells[I].CellTop > Top Then
        Begin
          BottomCell := ThisCell.FSlaveCells[I];
          Top := BottomCell.CellTop;
        End;
      End;
    End;

    BottomCell.CalcHeight;
    BottomCell.OwnerLine.LineHeight := FMousePoint.Y -
      BottomCell.OwnerLine.LineTop;
    UpdateLines;
  End
  Else
  Begin
    // �����Ե���ȥ��
    MoveToEx(hClientDC, FMousePoint.x, 0, Nil);
    LineTo(hClientDc, FMousePoint.x, RectClient.Bottom);

    // �ڴ˴��ж϶�CELL��ȵ��趨�Ƿ���Ч
    DragBottom := ThisCellsList.Count;

    For I := 0 To DragBottom - 1 Do
    Begin
      For J := 0 To TReportCell(ThisCellsList[I]).FSlaveCells.Count - 1 Do
      Begin
        ThisCellsList.Add(TReportCell(ThisCellsList[I]).FSlaveCells[J]);
      End;
    End;

    // ȡ��NEXTCELL
    If ThisCellsList.Count > 0 Then
    Begin
      ThisCell := TReportCell(ThisCellsList[0]);
      If ThisCell.CellIndex < ThisCell.OwnerLine.FCells.Count - 1 Then
        NextCell := TReportCell(ThisCell.OwnerLine.FCells[ThisCell.CellIndex +
          1]);

      // �ұߵ�CELL��Ϊ����������ĳһCELL
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
        InvalidateRect(Handle, @TempRect, False);
        TempRect := ThisCell.CellRect;
        TempRect.Right := TempRect.Right + 1;
        TempRect.Bottom := TempRect.Bottom + 1;
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
          InvalidateRect(Handle, @TempRect, False);
          TempRect := NextCell.CellRect;
          TempRect.Right := TempRect.Right + 1;
          TempRect.Bottom := TempRect.Bottom + 1;
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

Procedure TReportControl.StartMouseSelect(point: TPoint; bSelectFlag: Boolean;Shift: Boolean );
Var
  ThisCell: TReportCell;
  bFlag: Boolean;
  TempMsg: TMSG;
  TempPoint: TPoint;
  dwStyle: DWORD;
Begin
  If not Shift Then
    ClearSelect;
  ThisCell := CellFromPoint(point);
  If bSelectFlag Then
    AddSelectedCell(ThisCell);

  SetCapture(Handle);

  // ��ѡ�л��Ǳ༭?
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
// ����ִ�еĴ��� ��DELETED
  // ����û������û���Ƴ�������µ�CELL
//  If Not bFlag Then
//  Begin
//    If (ThisCell <> Nil) And (ThisCell.CellWidth > 10) Then
//    Begin
//      FEditCell := ThisCell;
//
//      If FEditFont <> INVALID_HANDLE_VALUE Then
//        DeleteObject(FEditFont);
//
//      FEditFont := CreateFontIndirect(ThisCell.LogFont);
//
//      // ���ñ༭��������
//      If IsWindow(FEditWnd) Then
//      Begin
//        DestroyWindow(FEditWnd);
//      End;
//      //// Edit Window's Position
//      Case ThisCell.HorzAlign Of
//        TEXT_ALIGN_LEFT:
//          dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_LEFT Or
//            ES_AUTOVSCROLL;
//        TEXT_ALIGN_CENTER:
//          dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_CENTER Or
//            ES_AUTOVSCROLL;
//        TEXT_ALIGN_RIGHT:
//          dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_RIGHT Or
//            ES_AUTOVSCROLL;
//      Else
//        dwStyle := WS_VISIBLE Or WS_CHILD Or ES_MULTILINE Or ES_LEFT Or
//          ES_AUTOVSCROLL;
//      End;
//
//      FEditWnd := CreateWindow('EDIT', '', dwStyle, 0, 0, 0, 0, Handle, 1,
//        hInstance, Nil);
//
//      SendMessage(FEditWnd, WM_SETFONT, FEditFont, 1); // 1 means TRUE here.
//      SendMessage(FEditWnd, EM_LIMITTEXT, 3000, 0);
//
//      MoveWindow(FEditWnd, ThisCell.TextRect.left, ThisCell.TextRect.Top,
//        ThisCell.TextRect.Right - ThisCell.TextRect.Left,
//        ThisCell.TextRect.Bottom - ThisCell.TextRect.Top, True);
//      SetWindowText(FEditWnd, PChar(ThisCell.CellText));
//      ShowWindow(FEditWnd, SW_SHOWNORMAL);
//      Windows.SetFocus(FEditWnd);
//
//    End;
//  End;

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

  // ���������ѡ�о����е�CELL
  For I := FSelectCells.Count - 1 Downto 0 Do
  Begin
    ThisCell := TReportCell(FSelectCells[I]);
    IntersectRect(TempRect, ThisCell.CellRect, RectSelection);

    If sh_down <> 5 Then                //���϶�ʱ������SHIFT��ʱ��ȡ����ѡ��Ԫ��
    Begin
      If Not ((TempRect.right > TempRect.Left) And (TempRect.bottom >
        TempRect.top)) Then
        RemoveSelectedCell(ThisCell);
    End;
  End;

  // ����ѡ�е�Cell
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
    If FSelectCells[0].FSlaveCells.Count > 0 Then
      Result := True
    Else
      Result := False;
  End
  Else
    Result := False;
End;

Procedure TReportControl.CombineCell;
// LCJ : ��汻ѡ�еĵ�Ԫ�������
// LCJ : ��comment �����italicȥ�������������л steve jobs .
// LCJ : ����æ�ĵ���˵{һ����������������Ӳ���4,5�أ��Ҷ�������:}�����죬��������+1��
// LCJ : �����˰칫���ڵĽ�������Ҳȥ��������AP��Ϊ�˰칫�����࣬�Ժ���AP�ˡ�

// LCJ :
// ���� {��������} ��
// LCJ : ������֢�˶��ԣ��ܹ����ű������ΰ��ġ���Ȼ�������׸����ҡ�
// LCJ : ��Ҳû�и�ʲô����Ϊʲô����? ��ʹ����ʲô��ÿ�������Ҳ�ȳ��˴�ö࣬�������ʵ
// LCJ : ������Թ��ʱ��ֻ̫̫Ҫ˵���꾰��˲��ã��㻹���Ŭ��������Ƿǳ��ܸɡ��ͺ���
// LCJ : ��ʹ���ϰ�͵������������֢������˵��Ҳ�Ǿ����ǳ������ѡ��������̣�͵�������޷�����
// LCJ : ���������������˽��Լ������Լ�������⣬�˾���Ȼ�ˡ�
// LCJ : ����������ĵ��������ˡ�
// LCJ : ״̬���µ�һ��.
// LCJ : Ȼ��һ��������������������ÿ���������а���
// LCJ : Ȼ����һ�������������������������������һ����˵�ģ�������˵����
// LCJ : Ȼ��˵���������ˡ����˲Ż����������Ĳ��������顣

var
    OwnerCell: TReportCell;
    I, J: Integer;
    ThisCell: TReportCell;
Begin
  checkError(FSelectCells.Count >= 2,'������ѡ��������Ԫ��');
  checkError(FSelectCells.IsRegularForCombine  ,'ѡ����β�������������ѡ');
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(FSelectCells[I]);
    For J := 0 To ThisCell.FSlaveCells.Count - 1 Do
      FSelectCells.Add(ThisCell.FSlaveCells[J]);
  End;
  FLineList.CombineHorz;
  OwnerCell := FLineList.CombineVert;

  UpdateLines;
  Self.Invalidate;
  ClearSelect;
  OwnerCell.Select;
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
          ThisCell.LiberateSlaves;
      End;
      TReportLine(FLineList[I]).Free;
      FLineList.Delete(I);
    End;
  End;
  self.DoInvalidateRect(bigrect);
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
    Application.Messagebox('�ر����ڱ༭���ļ��󣬲��ܽ����±��', '����',
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
  c: TReportCell;
  r : TRect;
  I: Integer;
Begin
  If CanSplit Then
  Begin
    c := TReportCell(FSelectCells[0]);
    ClearSelect;
    // LCJ : ʵ�ʲ���������һ�д���
    //so, Why not c.CellRect?
    DoInvalidateRect( c.FSlaveCells.CellRect);
    c.LiberateSlaves;
    UpdateLines;
    AddSelectedCell(c);
  End;
End;

Procedure TReportControl.SetCellAlignHorzAlign(NewHorzAlign: Integer);
Var
  I: Integer;
Begin    
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    FSelectCells[I].HorzAlign := NewHorzAlign;
    doInvalidateRect(FSelectCells[I].CellRect);
  End;
End;

Procedure TReportControl.SetCellAlignNewVertAlign(NewVertAlign: Integer);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).VertAlign := NewVertAlign;
    doInvalidateRect(FSelectCells[I].CellRect);
  End;
End;

Procedure TReportControl.SetCellBackColor(NewBackColor: COLORREF);
Var
  I: Integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
  Begin
    TReportCell(FSelectCells[I]).BkColor := NewBackColor;
    doInvalidateRect(FSelectCells[I].CellRect);
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
    FSelectCells[I].LeftLine := bLeftLine;
    FSelectCells[I].LeftLineWidth := nLeftLineWidth;

    FSelectCells[I].TopLine := bTopLine;
    FSelectCells[I].TopLineWidth := nTopLineWidth;

    FSelectCells[I].RightLine := bRightLine;
    FSelectCells[I].RightLineWidth := nRightLineWidth;

    FSelectCells[I].BottomLine := bBottomLine;
    FSelectCells[I].BottomLineWidth := nBottomLineWidth;

    CellRect := FSelectCells[I].CellRect;
//    CellRect.Left := CellRect.left - 1;
//    CellRect.Top := CellRect.top - 1;
//    CellRect.Right := CellRect.Right + 1;
//    CellRect.Bottom := CellRect.Bottom + 1;
    os.InflateRect(CellRect,1,1);
    InvalidateRect(Handle, @CellRect, false);
  End;
  UpdateLines;
End;

procedure TReportControl.EachCell_CalcMinCellHeight_If_Master(c:TReportCell);
begin
   If c.FSlaveCells.Count > 0 Then
      c.CalcHeight;
end;

procedure TReportLine.DoInvalidate;
var
  R :TRect;   
  PrevRect, TempRect: TRect;
  ThisCell : TReportCell;j:Integer;
begin
  Reportcontrol.os.SetRectEmpty(r);
  PrevRect := PrevLineRect;
  TempRect := LineRect;

  If not ReportControl.os.RectEquals(PrevRect,TempRect) And
    (TempRect.top <= Reportcontrol.ClientRect.bottom) Then
  Begin
    // ��֪���Ƿ�Ӧ��ɾ��
    For J := 0 To FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(FCells[J]);
      If ThisCell.OwnerCell <> Nil Then
        InvalidateRect(ReportControl.Handle, @ThisCell.OwnerCell.CellRect, False);
    End;
    // end comment
    PrevRect.Right := PrevRect.Right + 1;
    PrevRect.Bottom := PrevRect.Bottom + 1;
    TempRect.Right := TempRect.Right + 1;
    TempRect.Bottom := TempRect.Bottom + 1;
    R := Reportcontrol.os.UnionRect(r,prevRect);
    R := Reportcontrol.os.UnionRect(r,TempRect);
  End;
  InvalidateRect(Reportcontrol.Handle, @R, False);
end;
Procedure TReportControl.UpdateLines;
var
  I, J: Integer;
  c,ThisLine: TReportLine;
  ThisCell: TReportCell;
Begin
  EachCell(EachCell_CalcMinCellHeight_If_Master);
  EachLine(EachLine_CalcLineHeight);
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    ThisLine.Index := I;
    ThisLine.CalcLineTop ;
    ThisLine.DoInvalidate;                
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
        DoEdit ( TempChar);

        if Assigned (FOnChanged) then
          FOnChanged(Self,FEditCell.CellText);
        UpdateLines
        ;
        if not os.RectEquals (r , FEditCell.TextRect) then
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
  FSelectCells[0].OwnerLine.AddCell;
  UpdateLines;
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

    For J := ThisCell.FSlaveCells.Count - 1 Downto 0 Do
    Begin
      TempCell := Thiscell.FSlaveCells[J];
      TempCell.OwnerLine.FCells.Remove(TempCell);
      TempCell.Free;
    End;

    ThisCell.FSlaveCells.Clear;

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
  NewCell: TReportCell;
Begin
  If FSelectCells.Count <> 1 Then
    Exit;          
  FSelectCells[0].OwnerLine.InsertCell (FSelectCells[0]);
  UpdateLines;
End;
function TReportControl.RenderText(ThisCell:TReportCell;PageNumber, Fpageall: Integer):String;
begin
    Result := ThisCell.FCellText;
end;

Procedure TReportControl.InternalSaveToFile(FLineList:TList;FileName: String;PageNumber, Fpageall:integer);
Var
  TargetFile: TSimpleFileStream;
  I,j: Integer;
Begin
  TargetFile := TSimpleFileStream.Create(FileName, fmOpenWrite Or fmCreate);
  Try
    With TargetFile Do
    Begin  
      WriteWord($AA57);
      WriteInteger(FReportScale);
      WriteInteger(FPageWidth);
      WriteInteger(FPageHeight);
      WriteInteger(FLeftMargin);
      WriteInteger(FTopMargin);
      WriteInteger(FRightMargin);
      WriteInteger(FBottomMargin);
      WriteInteger(FLeftMargin1);
      WriteInteger(FTopMargin1);
      WriteInteger(FRightMargin1);
      WriteInteger(FBottomMargin1);
      WriteBoolean(FNewTable);
      WriteInteger(FDataLine);
      WriteInteger(FTablePerPage);  
      WriteInteger(FLineList.Count);
      For I := 0 To FLineList.Count - 1 Do
        WriteInteger(TReportLine(FLineList[I]).FCells.Count);
      For I := 0 To FLineList.Count - 1 Do
      Begin
        TReportLine(FLineList[I]).Save(TargetFile);
        For J := 0 To TReportLine(FLineList[I]).FCells.Count - 1 Do
          TReportCell(TReportLine(FLineList[I]).FCells[J]).Save(TargetFile,PageNumber, Fpageall);
          //Cells[I,J].Save(TargetFile,PageNumber, Fpageall);
      End;
      WriteInteger(FprPageNo);
      WriteInteger(FprPageXy);
      WriteInteger(fPaperLength);
      WriteInteger(fPaperWidth);
      WriteInteger(FHootNo);
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
  TargetFile: TSimpleFileStream;
  FileFlag: WORD;
  Count1, Count2, Count3: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  I, J, K: Integer;
  TempPChar: Array[0..3000] Of Char;
  bHasDataSet: Boolean;
  procedure Before ;
  var
    I : Integer;
  begin
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        ThisLine.Free;
      End;
      FLineList.Clear;
  end;
  procedure After;
  begin
      Width := FPageWidth;
      Height := FPageHeight;
  end;
Begin
  TargetFile := TSimpleFileStream.Create(FileName, fmOpenRead);
  Try
    With TargetFile Do
    Begin
      ReadWord(FileFlag);
      If (FileFlag <> $AA55) And (FileFlag <> $AA56) And (FileFlag <> $AA57) Then
        raise Exception.create('���ļ�����');

      Before ;      

      ReadInteger(FReportScale);
      ReadInteger(FPageWidth);
      ReadInteger(FPageHeight);

      ReadInteger(FLeftMargin);
      ReadInteger(FTopMargin);
      ReadInteger(FRightMargin);
      ReadInteger(FBottomMargin);

      ReadInteger(FLeftMargin1);
      ReadInteger(FTopMargin1);
      ReadInteger(FRightMargin1);
      ReadInteger(FBottomMargin1);

      ReadBoolean(FNewTable);
      ReadInteger(FDataLine);
      ReadInteger(FTablePerPage);
      // ������
      ReadInteger(Count1);
      For I := 0 To Count1 - 1 Do
      Begin
        ThisLine := TReportLine.Create;
  		  if (self is TReportControl) then
        	ThisLine.FReportControl := Self;
        FLineList.Add(ThisLine);
        ReadInteger(Count2);
        ThisLine.CreateLine(0, Count2, FRightMargin - FLeftMargin);
      End;      
      // ÿ�е�����
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        ThisLine.Load(TargetFile);
        // ÿ��CELL������
        For J := 0 To ThisLine.FCells.Count - 1 Do
        Begin
          ThisCell := TReportCell(ThisLine.FCells[J]);
          ThisCell.Load(TargetFile,FileFlag);
        End;
      End;
      ReadInteger(FprPageNo);
      ReadInteger(FprPageXy);
      ReadInteger(fpaperLength);
      ReadInteger(fpaperWidth);
      ReadInteger(FHootNo);
    End;
  Finally
    TargetFile.Free;
    After;
  End;
End;

// ��ֱ�зֵ�Ԫ��һ����Ԫ���ֳɶ������Ԫ�񣨺�OwnerCell�޹�
Procedure TReportControl.VSplitCell(Number: Integer);
Begin
  If FSelectCells.Count <> 1 Then
    Exit;

  DoVSplit(FSelectCells[0],Number);

End;
procedure TReportControl.DoVSplit(ThisCell:TReportCell;Number: Integer);
Var
  MaxCellCount,ActullyNum: Integer;
  rect : trect;
  ThisLine : TReportLine;
begin
  // LCJ : �����Paint��û���������ػ����ŵ�����β��Ҳ�����ػ���
  // ԭ������ֺ�CellRect�ͱ��ˣ�������һ��Ҳ������
  rect := ThisCell.CellRect;
  MaxCellCount := ThisCell.MaxSplitNum;
  If MaxCellCount > Number Then
    ActullyNum := Number
  else
    ActullyNum := MaxCellCount ;
  DoVertSplitCell(ThisCell,ActullyNum);
  //  UpdateLines;
  ThisCell.OwnerLine.UpdateCellIndex ;
  ThisCell.OwnerLine.UpdateCellLeft ;
  InvalidateRect(Handle, @rect, False);
end;

Procedure TReportControl.DoVertSplitCell(ThisCell : TReportCell;SplitCount: Integer);
Var
  CurrentCell, Cell,ChildCell: TReportCell;
  xx, I, J, CellWidth: Integer;
Begin
  //ƽ�ֺ����Ŀ�� , �����۷ֺ��ܶ��������
  xx := (ThisCell.CellRect.Right - ThisCell.CellRect.Left) Mod SplitCount;
  // ÿ��Cell��Width
  CellWidth := trunc((ThisCell.CellRect.Right - ThisCell.CellRect.Left) /
    SplitCount);

  ThisCell.CellWidth := CellWidth;
  For J := 0 To ThisCell.FSlaveCells.Count - 1 Do
      TReportCell(ThisCell.FSlaveCells[J]).CellWidth := CellWidth;
  For I := 1 To SplitCount - 1 Do
  Begin
    CurrentCell := TReportCell.Create(Self);
    // ��ʱ��CellIndex�Ǵ�ġ���ҪUpdateLines ,����CalcLineHeight ���㡣
    CurrentCell.CopyCell(ThisCell, False,ThisCell.OwnerLine);
    If i = SplitCount - 1 Then
      CurrentCell.CellWidth := CellWidth + xx;
    if ThisCell.IsLastCell() then
      CurrentCell.OwnerLine.FCells.Add(CurrentCell)
    Else
      CurrentCell.OwnerLine.FCells.Insert(ThisCell.CellIndex  + 1, CurrentCell);

    For J := 0 To ThisCell.FSlaveCells.Count - 1 Do
    Begin
      ChildCell :=  ThisCell.FSlaveCells[J];
      Cell := TReportCell.Create(Self);
      Cell.CopyCell(CurrentCell, False,ChildCell.OwnerLine);
      CurrentCell.Own(Cell);
      If ThisCell.IsLastCell  Then
        ChildCell.OwnerLine.FCells.Add(Cell)
      Else
        ChildCell.OwnerLine.FCells.Insert(ChildCell.CellIndex + 1,Cell);
    End;
  End;
End;
// ��ӡģ�塣���ǲ��������ݵ�����£������̬����ӡ���� ��
// �϶�ֻ��һҳ����˲���Ҫ���Ƿ�ҳ����
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
  // ��������ת��Ϊ���ص�
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

// 2014-11-17 ��Ӣ�� ��� 3�����á�
// SetFileCellWidth �����û��϶�������޸�ģ���ļ��е�Ԫ��Ŀ��
// ���仯��ĵ�Ԫ���ȴ���ȫ�ֱ������� 


Procedure TReportControl.FreeEdit;      //ȡ���༭״̬  lzl 
Begin
  If IsWindowVisible(FEditWnd) Then
  Begin
    If FEditCell <> Nil Then            //<>nil��
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
Procedure TReportControl.SetCellsFocus(row1, col1, row2, col2: integer);  
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


Procedure TReportControl.SetWndSize(w, h: integer);  
Begin
  FPageWidth := w;
  FPageHeight := h;
  FLastPrintPageWidth := FPageWidth;
  FLastPrintPageHeight := FPageHeight;
  Width := trunc(FPageWidth * FReportScale / 100 + 0.5); //width,heght������ʾ
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

procedure TReportLine.AddCell;
Var
  c: TReportCell;
begin
  c := TReportCell.Create(ReportControl);
  c.CopyCell(TReportCell(FCells.Last),False,Self);
  c.CellLeft := TReportCell(FCells.Last).CellRect.Right;
  FCells.Add(c);
end;

function TCellList.CellRect: TRect;
var i :integer;
begin
  ReportControl.os.SetRectEmpty(result);
  For I := 0 To Count - 1 Do
   result := ReportControl.os.UnionRect(result,Items[i].CellRect);
end;

procedure TCellList.ColumnSelectedCells(FLineList: TLineList);
  Var
    I, J, Count: Integer;
    CellsToCombine: TCellList;
    OwnerCell: TReportCell;
    ThisCell, FirstCell: TReportCell;
    ThisLine: TReportLine;
    SelectedLines : TLineList;
    SelectedCells :TCellList;
begin
    CellsToCombine := self;
    SelectedLines := TLineList.Create(Self.ReportControl);
    SelectedLines.makeSelectedLines(FLineList);
    For I := 0 To SelectedLines.Count - 1 Do
    Begin
      ThisLine := SelectedLines[I];
      SelectedCells :=TCellList.Create(ReportControl);
      try
        SelectedCells.MakeSelectedCellsFromLine(ThisLine);
        SelectedCells.Fill(CellsToCombine);
      finally
        SelectedCells.Free;
      end;
    End;
    SelectedLines.Free;
end;

constructor TCellList.Create(ReportControl:TReportControl);
begin
  self.ReportControl := ReportControl;
end;

procedure TCellList.DeleteCells;
var
  j :Integer ;
begin
  For J := Count - 1 Downto 0 Do
    Items[J].OwnerLine.DeleteCell(Items[J]);
end;

procedure TCellList.Fill(Cells: TCellList);
Var
    J: Integer;
begin
    For J := 0 To Count - 1 Do
      Cells.Add(TReportCell(Self[J]));
end;

function TCellList.Get(Index: Integer): TReportCell;
begin
  Result := TReportCell(inherited Get(Index));
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

function TCellList.Last: TReportCell;
begin
  Result := Items[count -1];
end;

procedure TCellList.MakeSelectedCellsFromLine(ThisLine: TReportLine);
var J :integer;ThisCell :TReportCell;
begin
  For J := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    ThisCell := TReportCell(ThisLine.FCells[J]);
    If ThisCell.IsSelected Then
        Add(ThisCell);
  End;
end;
function TCellList.TotalWidth: Integer;
var J :integer;
begin
  Result :=0 ;
  For J := 0 To Count - 1 Do
    Result := Result + TReportCell(Items[J]).CellWidth;
end;
procedure TReportControl.DoEdit(str: string);
begin
  FEditCell.CellText := str;
end;


procedure TReportControl.EachLine_CalcLineHeight(c: TReportLine);
begin
    c.UpdateLineHeight;
    c.UpdateCellIndex;
    c.UpdateCellLeft;
end;

procedure TReportControl.DoInvalidateRect(Rect: TRect);
begin
  os.InvalidateRect(Handle, @Rect, False);
end;

function TReportControl.IsEditing: boolean;
begin
  result := IsWindowVisible(FEditWnd) ;
end;

procedure TReportControl.CancelEditing;
var
  str: Array[0..3000] Of Char;
begin
    If FEditCell <> Nil Then
    Begin
      GetWindowText(FEditWnd, str, 3000);
      FEditCell.CellText := str;
    End;
    Windows.SetFocus(0);// ��֣�ReportControl����һ���õ�������ƶ��Լ�
    DestroyWindow(FEditWnd);
    FEditCell := Nil;   
end;

procedure TReportControl.ClearPaintMessage;
var   TempMsg: TMSG;
begin
  // �����Ϣ�����е�WM_PAINT��Ϣ����ֹ��������
  While PeekMessage(TempMsg, 0, WM_PAINT, WM_PAINT, PM_NOREMOVE) Do
  Begin
    If Not GetMessage(TempMsg, 0, WM_PAINT, WM_PAINT) Then
      Break;       
    DispatchMessage(TempMsg);
  End;

end;

procedure TReportControl.DoMouseDown(P: TPoint; Shift: Boolean);
var 
  Cell: TReportCell;
begin

  Cell := CellFromPoint(P);
  If  (Cell <> Nil) and Cell.NearRightBottom(P) Then
      StartMouseDrag(P)
  else
    StartMouseSelect(P, True, Shift) ;
end;

function TReportControl.MousePoint(Message: TMessage): TPoint;
begin
  Result.x := LOWORD(Message.lParam);
  Result.y := HIWORD(Message.lParam);
end;

{ TLineList }

procedure TLineList.CombineHorz;
Var
  I: Integer;
begin
   For I := 0 To Count - 1 Do
     Items[I].CombineSelected;
end;
function TLineList.CombineVert:TReportCell;
Var
  I: Integer;
  Cells: TCellList;
  OwnerCell: TReportCell;
begin
  Cells := TCellList.Create(Self.R);
  try
    Cells.ColumnSelectedCells(Self);
    OwnerCell := TReportCell(Cells[0]);
    // �ϲ�ͬһ�еĵ�Ԫ�� -- ֻҪ�������е�Cell���뵽��һ����cell��OwneredCell����
    For I := 1 To Cells.Count - 1 Do
        OwnerCell.Own(TReportCell(Cells[I]));
  finally
    Cells.Free;
  end;
  Result := OwnerCell ;

end;
constructor TLineList.Create(R:TReportControl);
begin
  self.R := R; 
end;

function TLineList.Get(Index: Integer): TReportLine;
begin
  Result := TReportLine(inherited Get(Index));
end;

procedure TLineList.MakeSelectedLines(FLineList:TLineList);
Var
    I: Integer;
begin
    For I := 0 To FLineList.Count - 1 Do
    Begin
      if FLineList[I].IsSelected then
        add(FLineList[I]);
    End;
end;
function IsCRTail(s : string):Boolean;
begin        
  Result := (Length(s) >= 2) and (s[Length(s)] = Chr(10)) And (s[Length(s) - 1] = Chr(13));
end;

function calcBottom(TempString:string ;TempRect:TRect;AlighFormat :UINT;FLogFont: TLOGFONT):Integer;
var
  hTempFont, hPrevFont: HFONT;
  hTempDC: HDC;
  Format: UINT;
  TempSize: TSize;
begin
  // LCJ : ��С�߶���Ҫ�ܹ��������֣���������ֱ�ߵĿ�Ⱥ�2����Ŀռ������ + 4
  //       ��ˣ���Ҫʵ�ʻ���������DC 0 �ϣ��������TempRect-������ռ�Ŀռ�
  //       - FLeftMargin : Cell �����ֺͱ���֮�����µĿյĿ��
  hTempFont := CreateFontIndirect(FLogFont);
  hTempDC := GetDC(0);
  hPrevFont := SelectObject(hTempDC, hTempFont);
  try
    Format := DT_EDITCONTROL Or DT_WORDBREAK;
    Format := Format Or AlighFormat ;
    Format := Format Or DT_CALCRECT;
    // lpRect [in, out] !  TempRect.Bottom ,TempRect.Right  �ᱻ�޸� �������ֲ���û���ᵽ��
    DrawText(hTempDC, PChar(TempString), Length(TempString), TempRect, Format);
    // �����������Ļس����������
    If  IsCRTail(TempString) Then
    Begin
        GetTextExtentPoint(hTempDC, 'A', 1, TempSize);
        TempRect.Bottom := TempRect.Bottom + TempSize.cy;
    End;
    result := TempRect.Bottom ;
  finally
    SelectObject(hTempDc, hPrevFont);
    DeleteObject(hTempFont);
    ReleaseDC(0, hTempDC);
  end;
end;
procedure TReportControl.EachCell(EachProc:EachCellProc);
var
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  i ,j :integer;
begin
   For I := 0 To FLineList.Count - 1 Do
    Begin
    ThisLine := TReportLine(FLineList[I]);
    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);
      EachProc(ThisCell);
    End;
   End;
end;
procedure TReportControl.EachLine(EachProc:EachLineProc);
var
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  i ,j :integer;
begin
   For I := 0 To FLineList.Count - 1 Do
    Begin
    ThisLine := TReportLine(FLineList[I]);
    EachProc(ThisLine);
   End;
end;
procedure TReportControl.EachLineIndex(EachProc:EachLineIndexProc);
var
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  i ,j :integer;
begin
   For I := 0 To FLineList.Count - 1 Do
    Begin
    ThisLine := TReportLine(FLineList[I]);
    EachProc(ThisLine,I);
   End;
end;
procedure TReportControl.EachCell_CalcHeight(ThisCell:TReportCell);
begin
  If ThisCell.FSlaveCells.Count > 0 Then
    thisCell.CalcHeight ;
end;

//
procedure TReportControl.EachProc_UpdateIndex(thisLine:TReportLine;I:integer);
begin
    ThisLine.Index := I;
end;
procedure TReportControl.EachProc_UpdateLineTop(thisLine:TReportLine;I:integer);
begin
   If I = 0 Then
    ThisLine.LineTop := FTopMargin
   else
    ThisLine.LineTop := TReportLine(FLineList[I - 1]).LineTop +
                              TReportLine(FLineList[I - 1]).LineHeight;
end;
procedure TReportControl.EachProc_UpdateLineRect(thisLine:TReportLine;Index:integer);
begin
     ThisLine.LineRect;
end;
procedure TSimpleFileStream.ReadWord(var a: Word);
begin
  Read(a,SizeOf(word))
end;
procedure TSimpleFileStream.WriteWord(a: Word);
begin
  Write(a,SizeOf(word))
end;
procedure TSimpleFileStream.WriteInteger(a: Integer);
begin
  Write(a,SizeOf(Integer))
end;

procedure TSimpleFileStream.WriteBoolean(a: Boolean);
begin
  Write(a,SizeOf(boolean));

end;

procedure TSimpleFileStream.WriteRect( a: TRect);
begin
  Write(a,SizeOf(TRect))
end;

procedure TSimpleFileStream.WriteCardinal(a: Cardinal);
begin
    Write(a,SizeOf(Cardinal))
end;

procedure TSimpleFileStream.WriteString(a: String);
var   TempPChar: Array[0..3000] Of char;count ,k:integer;
begin
    Count := Length(a);
    WriteInteger(Count);
    StrPCopy(TempPChar, a);
    For K := 0 To Count - 1 Do
      Write(TempPChar[K], 1);
end;

procedure TSimpleFileStream.WriteTLOGFONT(a: TLOGFONT);
begin
   Write(a,SizeOf(TLOGFONT))
end;

procedure TSimpleFileStream.ReadBoolean(var a: Boolean);
begin
  Read(a,SizeOf(Boolean))
end;

procedure TSimpleFileStream.ReadCardinal(var a: Cardinal);
begin
    Read(a,SizeOf(Cardinal))
end;

procedure TSimpleFileStream.ReadInteger(var a: Integer);
begin
    Read(a,SizeOf(Integer))
end;

procedure TSimpleFileStream.ReadRect(var a: TRect);
begin
      Read(a,SizeOf(TRect))
end;

procedure TSimpleFileStream.ReadString(var a: String);
var count1,k:integer;TempPChar: Array[0..3000] Of char;
begin
    ReadInteger(Count1);
    tempPchar := #0;
    For K := 0 To Count1 - 1 Do
      Read(TempPChar[K], 1);
    TempPChar[Count1] := #0;
    a := StrPas(TempPChar);
end;

procedure TSimpleFileStream.ReadTLOGFONT(var a: TLOGFONT);
begin
      Read(a,SizeOf(TLOGFONT))
end;

End.




//#
//#                       _oo0oo_
//#                      o8888888o
//#                      88" . "88
//#                      (| -_- |)
//#                      0\  =  /0
//#                    ___/`---'\___
//#                  .' \\|     |# '.
//#                 / \\|||  :  |||# \
//#                / _||||| -:- |||||- \
//#               |   | \\\  -  #/ |   |
//#               | \_|  ''\---/''  |_/ |
//#               \  .-\__  '-'  ___/-. /
//#             ___'. .'  /--.--\  `. .'___
//#          ."" '<  `.___\_<|>_/___.' >' "".
//#         | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//#         \  \ `_.   \_ __\ /__ _/   .-` /  /
//#     =====`-.____`.___ \_____/___.-`___.-'=====
//#                       `=---='
//#
//#
//#     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#
//#               ���汣��         ����BUG
//#               Siddh��ttha Gotama
//#
///*code is far away from bug with the animal protecting
//    *  ��������������
//    *�����ߩ��������ߩ�
//    *������������������ ��
//    *������������������
//    *�����ש������ס���
//    *������������������
//    *���������ߡ�������
//    *������������������
//    *������������������
//    *�����������������ޱ���
//    *��������������������BUG��
//    *����������������������
//    *���������������������ǩ�
//    *������������������������
//    *���������������ש�����
//    *���������ϩϡ����ϩ�
//    *���������ߩ������ߩ� 
//    *������
//    */

