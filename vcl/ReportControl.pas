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
//#               佛祖保佑         永无BUG
//#               Siddhāttha Gotama
//#


Unit ReportControl;

Interface

Uses
  Windows, Messages, SysUtils,Math,cc,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice;
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

type
  TReportControl = class ;
  TReportCell =class     ;
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
    StrSlice=class
    FStr :string;
  public
    constructor Create(str:String);
    function GoUntil(c:char):integer;
    function Slice(b,e:integer):string;overload;
    function Slice(b:integer):string;overload;
    class function DoSlice(str: String; FromChar:char): string;
  end;
  MouseDragger = class(MouseBase)
    //FControl :TReportControl ;
    //hClientDC: HDC;
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

// Mappings From CellText to Data end :TDataset ,TField,Value
   DataField = class
     FFieldName : String;
     Fds:TDataset;
  private
    function GetFieldName: String;
    function IsDataField(s: String): Boolean;
   public
    constructor Create(ds:TDataset;FFieldName : String);
    function DataValue(): Extended;
    function ds: TDataset;
    function GetField(): TField;
    function IsNullField(): Boolean;
    function IsNumberField(): Boolean;
    function IsBlobField:Boolean;
    function IsAvailableNumberField:Boolean;

   end;
  TOnChanged = procedure(Sender:TObject;str:String) of object;

  TSimpleFileStream = class(TFileStream)
  private
    procedure ReadIntegerSkip;
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
   TSimpleWriter = class
     FStream :TSimpleFileStream;
   public
     function Int(a:Integer):TSimpleWriter;
     function Word(a:Word):TSimpleWriter;
     function Bool(a:Boolean):TSimpleWriter;
     function Rect(a:TRect):TSimpleWriter;
     function Cardinal(a:Cardinal):TSimpleWriter;
     function Str(a:String):TSimpleWriter;
     function LOGFONT(a:TLOGFONT):TSimpleWriter;
     constructor Create(sfs :TSimpleFileStream);
   end;
   TSimpleReader = class
     FStream :TSimpleFileStream;
  private
    function IntSkip: TSimpleReader;
   public
     function Int(var a:Integer):TSimpleReader;
     function Word(var a:Word):TSimpleReader;
     function Bool(var a:Boolean):TSimpleReader;
     function Rect(var a:TRect):TSimpleReader;
     function Cardinal(var a:Cardinal):TSimpleReader;
     function Str(var a:String):TSimpleReader;
     function LOGFONT(var a:TLOGFONT):TSimpleReader;
     constructor Create(sfs :TSimpleFileStream);
   end;
  CellType = (ctOwnerCell,ctSlaveCell,ctNormalCell);
  TPrinterPaper = class
  private
    // google : msdn DEVMODE structure
    DevMode: PdeviceMode;
    //LCJ: 打印文件的纸张编号：比如 A4，A3，自定义纸张等。
    FprPageNo: integer;
    // 纸张纵横方向
    FprPageXy: integer;
    // 纸张长度（高度）
    fpaperLength: integer;
    fpaperWidth: integer;
  private
    //取得当前打印机的DeviceMode的结构成员
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

  TReportLine = Class;

  TLineList = class;
  TCellList = class(TList)
  private
    ReportControl:TReportControl;
    function Get(Index: Integer): TReportCell;
    procedure CheckAllNextCellIsBiggerBottom;
    procedure CheckAllNextCellIsSlave;
  public
    constructor Create(ReportControl:TReportControl);
    //清除掉不在选中矩形中的CELL  
    procedure ClearBySelection(R:TRect);
    function IsRegularForCombine():Boolean;
    procedure MakeInteractWith(R:TRect);
    procedure MakeSelectedCellsFromLine(ThisLine:TReportLine);
    procedure MakeFromSameRight(ThisCell:TReportCell);
    procedure MakeFromSameRightAndInterference(ThisCell:TReportCell);

    function TotalWidth:Integer;
    // How to implement indexed [] default property
    // http://stackoverflow.com/questions/10796417/how-to-implement-indexed-default-property
    property Items[Index: Integer]: TReportCell read Get ;default;
    procedure DeleteCells;
    procedure ColumnSelectedCells(FLineList:TLineList);
    procedure Fill(Cells :TCellList);
    function Last : TReportCell ;
    function CellRect:TRect;
    function MaxCellLeft:integer;
    function MinNextCellRight:integer;
    function MaxCellBottom:Integer;
    function ToString: String;
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
    function TotalHeight:Integer;
  published
    {
    G:How do I force the linker to include a function I need during debugging?
    You can make function published.
      TMyClass = class
        F : integer;
      published
        function AsString : string;
      end;
      And switch on in 'Watch Properties' 'Allow function calls'
    }
    function ToString:String ;
  end;
  TReportCell = Class(TObject)
  private

    NearResolution : integer;
    ReportControl:TReportControl;
    function GetOwnerCellHeight: Integer;
    function MaxSplitNum :integer;
    function GetBottomest(FOwnerCell: TReportCell): TReportCell;overload;
    function GetBottomest(): TReportCell;overload;
    function GetTextHeight: Integer;
    procedure ExpandHeight(delta: integer);
    function GetNextCell: TReportCell;
    // group by hPaintDC ,so simplize is possible
    procedure DrawDragon(hPaintDC:HDC);
    procedure DrawLine(hPaintDc:HDC;x1, y1, x2, y2: integer; color: COLORREF;
      PenWidth: Integer);
    procedure DrawBottom(hPaintDc: HDC; color: COLORREF);
    procedure DrawFrameLine(hPaintDc:HDC);
    procedure DrawLeft(hPaintDc: HDC; color: COLORREF);
    procedure DrawRight(hPaintDc: HDC; color: COLORREF);
    procedure DrawTop(hPaintDc: HDC; color: COLORREF);
    procedure DrawAuxiliaryLine(hPaintDc:HDC;bPrint:Boolean);
    procedure FillBg(hPaintDC: HDC; FCellRect: TRect;
      FBackGroundColor: COLORREF);
    procedure DrawContentText(hPaintDC: HDC);
    //procedure SaveInternal(s: TSimpleFileStream; PageNumber,Fpageall: integer);
    procedure SaveInternal(s: TSimpleFileStream);
  public
    procedure LoadBmp(FileName:String);
    procedure FreeBmp();
    function IsSimpleField: Boolean;
    procedure DrawImage;
    function IsSlave:Boolean;
    function Calc_RequiredCellHeight: Integer;
    function GetReportControl: TReportControl;
    function GetSelected: Boolean;
    function GetTextRectInternal(Str: String): TRect;
    function NearBottom(P:TPoint):Boolean ;
    function NearRight(P:TPoint):Boolean ;
    function NearRightBottom(P:TPoint):Boolean ;
    property NextCell:TReportCell read GetNextCell;
    function IsHeadField:Boolean;
    function IsDetailField:Boolean;
    function IsSumAllField:Boolean;
    function IsPageNumFormula:Boolean;
    function IsPageNumFormula1: Boolean;
    function IsPageNumFormula2: Boolean;
    function IsSumPageFormula:Boolean;
    function IsSumAllFormula: Boolean;
    function IsFormula:Boolean;
    procedure CloneFrom(ThisCell:TReportCell);
    function FormatValue(DataValue:Extended):string;
    procedure LoadCF(cf:DataField);
  public
    FLeftMargin: Integer;               // 左边的空格
    FOwnerLine: TReportLine;            // 隶属行
    FOwnerCell: TReportCell;            // Master Cell
    FSlaveCells: TCellList;             // Slave Cell
    // Index
    FCellIndex: Integer;                // Cell在行中的索引
    // size & position
    FCellLeft: Integer;
    FCellWidth: Integer;
    FCellRect: TRect;                   // 计算得来
    FTextRect: TRect;
    //   RequiredCellHeight 就是在跨行合并的Cell中表达 CellText需要的高度。区别于
    //  而MinCellHeight,后者是最小Cell的高度，不管它有没有合并和拆分，
    //  都固定表示一个cell的高度。普通cell用  MinCellHeight，合并的cell可能需要用RequiredCellHeight
    //  概念辨析:)
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
    // Cell的Height属性从隶属行和跨越行中取得
    Function GetCellHeight: Integer;
    // Cell的Top属性从隶属的行中取得
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
    procedure Save(s:TSimpleFileStream);
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
    function IsMaster :Boolean ;
    function IsBottomest():Boolean;
    Procedure CalcHeight;
    Procedure PaintCell(hPaintDC: HDC; bPrint: Boolean);
    // 把Cell认作兄弟 。
    // 同为MasterCell的儿子。并且插入到 MasterCells内，自己位置index之前
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
    // 斜线
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
    procedure calcLineTop;

  Public
    function IsDetailLine:Boolean;
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
    function IsSumAllLine:Boolean;
    function ToString:string;
  End;
  EachCellProc =  procedure (ThisCell:TReportCell) of object;
  EachLineProc =  procedure (ThisLine:TReportLine)of object;
  EachLineIndexProc = procedure (ThisLine:TReportLine;Index:Integer)of object;
  Edit = class
    FControl : TReportControl;
    FEditWnd: HWND;
    FEditBrush: HBRUSH;
    FEditFont: HFONT;
  private
    function CreateEdit(Handle: HWND; Rect: TRect;LogFont: TLOGFONT;
      Text: String; FHorzAlign: Integer): HWND;
    function GetText: String;
    procedure MoveRect(TextRect: TRect);
    procedure DestroyIfVisible;
    function IsWindowVisible: Boolean;
    procedure DestroyWindow;
    function CreateBrush(color: Cardinal): HBRUSH;
  public
    constructor Create(R:TReportControl);
  end;
  TReportControl = Class(TWinControl)
  private
    FTextEdit:Edit;
    MouseSelect : MouseSelector;
    MouseDrag : MouseDragger;
    hClientDC: HDC;
    procedure InternalSaveToFile(
      FLineList: TList; FileName: String;PageNumber, Fpageall: integer);
    procedure DoInvalidateRect(Rect:TRect);
    procedure RecreateEdit(ThisCell: TReportCell);
    procedure DoPaint(hPaintDC: HDC; Handle: HWND; ps: TPaintStruct);
    procedure DrawCornice(hPaintDC: HDC);
    procedure StartMouseDrag_Horz(point: TPoint);
    procedure StartMouseDrag_Verz(point: TPoint);
    procedure MaxDragExtent(ThisCell: TReportCell; var RectBorder: TRect);
    function QueryMaxDragExtent(ThisCell:TReportCell):TRect;
    procedure UpdateHeight(ThisCell: TReportCell; Y: Integer);
    procedure UpdateTwinCell(ThisCell: TReportCell; x: integer);
    function Interference(ThisCell: TReportCell): boolean;
    function RectBorder1(ThisCell: TReportCell;
      ThisCellsList: TCellList): TRect;
    procedure DrawIndicatorLine(var x: Integer; RectBorder: TRect);
    procedure MsgLoop(RectBorder:TRect);
    procedure OnMove(TempMsg: TMSG;RectBorder:TRect );
    function AddSelectedCells(Cells: TCellList): Boolean;
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
    // Margin : by pixel
    FLeftMargin: Integer;
    FRightMargin: Integer;
    FTopMargin: Integer;
    FBottomMargin: Integer;

    FcellFont: TlogFont;
    // Margin :by mm
    FLeftMargin1: Integer;
    FRightMargin1: Integer;
    FTopMargin1: Integer;
    FBottomMargin1: Integer;
    //表尾的第一行在整个页的第几行
    //FHootNo: integer;
    // 换页加表头（不加表头）
    FNewTable: Boolean;
    // 定义打印多少行后从新加表头
    FDataLine: Integer;
    FTablePerPage: Integer;
    // 鼠标操作支持
    FMousePoint: TPoint;
    // 编辑框、以及它的颜色和字体
    FOnChanged : TOnChanged;
    Os :WindowsOS ;
    Procedure SetCellSFocus(row1, col1, row2, col2: integer);
    function Get(Index: Integer): TReportLine;
    function GetCells(Row, Col: Integer): TReportCell;
    procedure InvertCell(Cell: TReportCell);
    procedure DoEdit(str:string);
    procedure DoMouseDown(P:TPoint;Shift:Boolean);
  Protected
    function RenderText(ThisCell: TReportCell): String;virtual ;
    Procedure CreateWnd; Override;
    procedure InternalLoadFromFile(FileName:string;FLineList:TList);


  Public
    FLastPrintPageWidth, FLastPrintPageHeight: integer;
    PrintPaper:TPrinterPaper;
        function ZoomRate(height, width: integer): Integer;

    property     LeftMargin: Integer read FLeftMargin ;
    property     RightMargin: Integer read FRightMargin ;
    property     TopMargin: Integer read FTopMargin ;
    property     BottomMargin: Integer read FBottomMargin ;

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
    Procedure DoLoadBmp(Cell: Treportcell; filename: String);
    Procedure FreeBmp(Cell: Treportcell);
    Procedure PrintIt;
    Procedure ResetContent;
    Procedure SetScale(Const Value: Integer);
    Property cellFont: TlogFont Read Fcellfont Write Fcellfont;
    property OnChanged : TOnChanged read FOnChanged write FOnChanged;
    procedure ClearPaintMessage;
    function MousePoint(Message: TMessage):TPoint;
    procedure DoDoubleClick(p:TPoint);
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
    //取销编辑状态
    Procedure FreeEdit;
    Procedure StartMouseDrag(point: TPoint);
//    Procedure StartMouseSelect(point: TPoint; Shift: Boolean );
//    Procedure DoMouseMove(p: TPoint;Shift:Boolean);
    Procedure StartMouseSelect(point: TPoint; Shift: Boolean );
//    Procedure DoMouseMove(p: TPoint;Shift:Boolean);
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
  TVarList = class(TList)
  private
    function KeepAlphaOnly(a: string): string;
    function FindKey(Key: String): TVarTableItem;
    function New(Key: String): TVarTableItem;
  public
    function FindKeyOrNew(Key: String): TVarTableItem;
    function GetVarValue(Key: String): String;
    procedure FreeItems;
  end;
  TMyRect = Class(TObject)
  Public
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
  End;
  // ThisCell 设计态的Master Cell
  // NewCell  运行态的Master Cell
  TDRMappings = class(TList)
  private
    procedure NewMapping (ThisCell,NewCell:TReportCell);
    function FindRuntimeMasterCell(ThisCell:TReportCell):TReportCell;
  public
    procedure FreeItems;
    procedure RuntimeMapping(NewCell, ThisCell: TReportCell);
  end;
  TDRMapping = Class(TObject)
    DesignMasterCell: TReportCell;
    RuntimeMasterCell: TReportCell;
  End;

type
  Combinator = class
    ReportControl:TReportControl ;
    CellList:TCellList;
    bigrect : TRect;
  private
    function IsPit(c : TReportCell): Boolean;
    procedure TakeupRect;
  public
    constructor Create(R:TReportControl;CellList:TCellList);
    function IsRegularForCombine(): Boolean;
  end;

Procedure Register;

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
  // LCJ : 我说好好的A4，干嘛总是进入信纸状态呢:)
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
  // 修改左右预留的空白区域.呵呵，目前只能是5。
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
  
  // LCJ : 加个条件，说明只有有SlaveCells才做这些，更清楚些：）
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
    s := '汉'
  Else
    s := FCellText;
  result := GetTextRectInternal(s);
end;

function TReportCell.GetTextRectInternal(Str:String):TRect;
var
  R:TRect;
begin
  ReportControl.Os.SetRectEmpty(R);   
  R.left := FCellLeft + FLeftMargin;
  R.top := GetCellTop + 2;
  R.right := FCellLeft + FCellWidth - FLeftMargin;
  R.bottom := CalcBottom( Str,R, ReportControl.os.HAlign2DT(FHorzAlign),FLogFont);
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
  ThisCell:TReportCell;
  I,Height:Integer ;
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
// 要是Cell 太窄，窄到无法放入任何文字，就不要到后面去计算高度了。
// 直接默认 字高 16 即可。
// 没有 RightMargin ,原作者把RightMargin 和LeftMargin等同，所以又下面的 FLeftMargin * 2
Procedure TReportCell.CalcHeight;
Begin
//  if FCellHeight  = 0 then
//    FCellHeight := DefaultHeight;
  If FCellWidth <= FLeftMargin * 2 Then
    exit;
  if IsNormalCell  then
    FCellHeight := GetTextHeight + Payload ;
  if IsMaster  then
    FSlaveCells.Last.ExpandHeight (Calc_RequiredCellHeight - GetOwnerCellHeight);
end;
procedure TReportCell.ExpandHeight(delta:integer);
begin
  if delta <= 0  Then
    Exit;
  inc (FCellHeight,delta);
end;

// Calc CellRect & TextRect here
// 如果CELL的大小或者文本框的大小改变，自动的置窗口的失效区
Procedure TReportCell.CalcCellTextRect;
  procedure CalcCellRect;
  Var
    I: Integer;
  begin
    FCellRect.left := FCellLeft;
    FCellRect.top := CellTop;
    FCellRect.right := FCellRect.left + FCellWidth;
    FCellRect.bottom := FCellRect.top + OwnerLineHeight;
    if IsMaster then
      For I := 0 To FSlaveCells.Count - 1 Do
        Inc(FCellRect.Bottom,FSlaveCells[I].OwnerLineHeight);
  end;
  // TODO : 感觉和RequiredCellHeight 有重复，并且同一件事，算法不同。
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
    If IsMaster Then begin
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
    // LCJ : 这个Payload ，一会儿加，一会儿不加的，不规律呢。
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
procedure TReportCell.DrawDragon(hPaintDc:HDC);
var p1,p2:TPoint ;R:TRect;
procedure DrawLine(hPaintDC:HDC;p1,p2:TPoint);
begin
      MoveToEx(hPaintDC,p1.x, p1.y, Nil);
      LineTo(hPaintDC, p2.x, p2.y);
end;

var R1:Rect;
  c : Canvas;
  function IsDragonLeft1:Boolean;
  begin
    result := (FDiagonal And LINE_LEFT1) > 0 ;
  end;
  function IsDragonLeft2:Boolean;
  begin
    result := (FDiagonal And LINE_LEFT2) > 0 ;
  end;
  function IsDragonLeft3:Boolean;
  begin
    result := (FDiagonal And LINE_LEFT3) > 0 ;
  end;
  function IsDragonRight1:Boolean;
  begin
    result := (FDiagonal And LINE_RIGHT1) > 0 ;
  end;
  function IsDragonRight2:Boolean;
  begin
    result := (FDiagonal And LINE_RIGHT2) > 0 ;
  end;
  function IsDragonRight3:Boolean;
  begin
    result := (FDiagonal And LINE_RIGHT3) > 0 ;
  end;
  function IsDragonSet:Boolean;
  begin
    result := FDiagonal > 0 ;
  end;
begin
  If not IsDragonSet Then exit;
  c := Canvas.Create(hPaintDC);
  c.ReadyDefaultPen;
  R1 := Rect.Create(self.ReportControl.os.Inflate(FCellRect,-1,-1));
  try
    If IsDragonLeft1 Then
    Begin
      p1 := R1.TopLeft ;
      p2 := R1.BottomRight;
      c.DrawLine(p1,p2);
    End;

    If IsDragonLeft2  Then
    Begin
      p1 := R1.TopLeft ;
      p2 := R1.RightMid;
      c.DrawLine(p1,p2);
    End;

    If IsDragonLeft3 Then
    Begin
      p1 := R1.TopLeft ;
      p2 := R1.BottomMid;
      c.DrawLine(p1,p2);
    End;

    If IsDragonRight1 Then
    Begin
      p1 := R1.RightTop;
      p2 := R1.LeftBottom;
      c.DrawLine(p1,p2);
    End;

    If IsDragonRight2 Then
    Begin
      p1 := R1.RightTop;
      p2 := R1.LeftMid;
      c.DrawLine(p1,p2);
    End;

    If IsDragonRight3 Then
    Begin
      p1 := R1.RightTop;
      p2 := R1.BottomMid;
      c.DrawLine(p1,p2);
    End;                
  finally
    c.KillPen;
    c.free;
    R1.Free;
  end;
end;
procedure TReportCell.DrawLine(hPaintDc:HDC;x1,y1,x2,y2:integer;color:COLORREF;PenWidth:Integer);
VAR     hPrevPen, hTempPen: HPEN;
begin
  hTempPen := CreatePen(BS_SOLID, PenWidth, color);
  hPrevPen := SelectObject(hPaintDc, hTempPen);
  MoveToEx(hPaintDc, x1, y1, Nil);
  LineTo(hPaintDC, x2, y2);
  SelectObject(hPaintDc, hPrevPen);
  DeleteObject(hTempPen);
end;
procedure TReportCell.DrawLeft(hPaintDc:HDC;color:COLORREF);
begin
  DrawLine(hPaintDc,FCellRect.left, FCellRect.top,FCellRect.left, FCellRect.bottom,color,FLeftLineWidth);
end;
procedure TReportCell.DrawTop(hPaintDc:HDC;color:COLORREF);
begin
  DrawLine( hPaintDc,FCellRect.left, FCellRect.top,FCellRect.right, FCellRect.top,color,FTopLineWidth);
end;
procedure TReportCell.DrawRight(hPaintDc:HDC;color:COLORREF);
begin
  DrawLine( hPaintDc,FCellRect.right, FCellRect.top,FCellRect.right, FCellRect.bottom,color,FRightLineWidth);
end;
procedure TReportCell.DrawBottom(hPaintDc:HDC;color:COLORREF);
begin
  DrawLine( hPaintDc,FCellRect.left, FCellRect.bottom,FCellRect.right, FCellRect.bottom,color,FBottomLineWidth);
end;
procedure TReportCell.DrawFrameLine(hPaintDc:HDC);
begin
  If FLeftLine Then
    DrawLeft(hPaintDc,cc.Black);
  If FTopLine Then
    DrawTop(hPaintDc,cc.Black);
  If FRightLine Then
    DrawRight(hPaintDc,cc.Black);
  If FBottomLine Then
    DrawBottom(hPaintDc,cc.Black);
end;
procedure  TReportCell.DrawAuxiliaryLine(hPaintDc:HDC;bPrint:Boolean) ;
begin
  if (not FLeftLine) and (not bPrint) and (CellIndex = 0) then
    DrawLeft(hPaintDc,cc.Grey);
  if (not FTopLine) and (not bPrint) and (OwnerLine.Index = 0) then
    DrawTop(hPaintDc,cc.Grey);
  if (not FRightLine) and (not bPrint)  then
    DrawRight(hPaintDc,cc.Grey);
  if (not FBottomLine )and (not bPrint)  then
    DrawBottom(hPaintDc,cc.Grey);
end;
procedure TReportCell.FillBg(hPaintDC: HDC;FCellRect:TRect;FBackGroundColor:COLORREF);
var
  TempRect:TRect;
  TempLogBrush: TLOGBRUSH;
  hTempBrush: HBRUSH;
begin
  TempRect := FCellRect;
  TempRect.Top := TempRect.Top + 1;
  TempRect.Right := TempRect.Right + 1;
  If FBackGroundColor <>cc.White Then
  Begin
    TempLogBrush.lbStyle := BS_SOLID;
    TempLogBrush.lbColor := FBackGroundColor;
    hTempBrush := CreateBrushIndirect(TempLogBrush);
    FillRect(hPaintDC, TempRect, hTempBrush);
    DeleteObject(hTempBrush);
  End;
end;
procedure TReportCell.DrawContentText(hPaintDC: HDC);
var   Format: UINT;  hTextFont, hPrevFont: HFONT; TempRect: TRect;
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
Procedure TReportCell.PaintCell(hPaintDC: HDC; bPrint: Boolean);
Var
  SaveDCIndex: Integer;
Begin
  If FOwnerCell <> Nil Then
    Exit;                          
  SaveDCIndex := SaveDC(hPaintDC);
  try
    SetBkMode(hPaintDC, TRANSPARENT);
    FillBg (hPaintDC, FCellRect,FBackGroundColor);
    DrawFrameLine(hPaintDc,);
    DrawAuxiliaryLine (hPaintDc,bPrint);
    DrawDragon(hPaintDC);
    DrawContentText(hPaintDC) ;
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
    FLogFont.lfFaceName := '宋体';
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
  FTextColor := cc.Black;
  FBackGroundColor := cc.White;
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
function TReportCell.GetBottomest():TReportCell;
var
  BottomCell,ThisCell:TReportCell;I,Top:Integer ;
  FOwnerCell:TReportCell;
begin
  FOwnerCell := Self;
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


function TReportCell.IsMaster: Boolean;
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
procedure TReportCell.Save(s: TSimpleFileStream);
begin
  //if not IsDesign then
  FCellText := Self.ReportControl.renderText(Self);
  Self.SaveInternal(s);
end;
procedure TReportCell.SaveInternal(s: TSimpleFileStream);
var k :  integer;
    w : TSimpleWriter;
begin
  w := TSimpleWriter.Create(s);
  w.Int(FLeftMargin)
   .Int(FCellIndex)
   .Int(FCellLeft)
   .Int(FCellWidth)
   .Rect(FCellRect)
   .Rect(FTextrect)
   .Int(FCellHeight)
   .Int(FCellHeight)
   .Int(FRequiredCellHeight)
   .Bool(FLeftLine)
   .Int(FLeftLineWidth)
   .Bool(FTopLine)
   .Int(FTopLineWidth)
   .Bool(FRightLine)
   .Int(FRightLineWidth)
   .Bool(FBottomLine)
   .Int(FBottomLineWidth)
   .Cardinal(FDiagonal)
   .Cardinal(FTextColor )
   .Cardinal(FBackGroundColor )
   .Int(FHorzAlign)
   .Int(FVertAlign)
   .Str(FCellText)
   .Str(FCellDispformat)
   .Bool(Fbmpyn) ;
    If FbmpYn Then
      FBmp.SaveToStream(s);
    w.LogFont(FLogFont);

    // 属主CELL的行，列索引
    If FOwnerCell <> Nil Then
    Begin
      w.Int(FOwnerCell.OwnerLine.FIndex)
      .Int(FOwnerCell.FCellIndex);
    End
    Else
    Begin
      w.Int(-1).Int(-1);
    End;
    w.Int(FSlaveCells.Count);
    For K := 0 To FSlaveCells.Count - 1 Do
    Begin
      w.Int(FSlaveCells[K].OwnerLine.FIndex);
      w.Int(FSlaveCells[K].FCellIndex);
    End;
  w.free;
end;
//procedure TReportCell.SaveInternal(s: TSimpleFileStream;PageNumber, Fpageall:integer);
//var k :  integer;
//    w : TSimpleWriter;
//begin
//  //if not IsDesign then
//    FCellText := Self.ReportControl.renderText(Self, PageNumber,  Fpageall);
//  w := TSimpleWriter.Create(s);
//  w.Int(FLeftMargin)
//   .Int(FCellIndex)
//   .Int(FCellLeft)
//   .Int(FCellWidth)
//   .Rect(FCellRect)
//   .Rect(FTextrect)
//   .Int(FCellHeight)
//   .Int(FCellHeight)
//   .Int(FRequiredCellHeight)
//   .Bool(FLeftLine)
//   .Int(FLeftLineWidth)
//   .Bool(FTopLine)
//   .Int(FTopLineWidth)
//   .Bool(FRightLine)
//   .Int(FRightLineWidth)
//   .Bool(FBottomLine)
//   .Int(FBottomLineWidth)
//   .Cardinal(FDiagonal)
//   .Cardinal(FTextColor )
//   .Cardinal(FBackGroundColor )
//   .Int(FHorzAlign)
//   .Int(FVertAlign)
//   .Str(FCellText)
//   .Str(FCellDispformat)
//   .Bool(Fbmpyn) ;
//    If FbmpYn Then
//      FBmp.SaveToStream(s);
//    w.LogFont(FLogFont);
//
//    // 属主CELL的行，列索引
//    If FOwnerCell <> Nil Then
//    Begin
//      w.Int(FOwnerCell.OwnerLine.FIndex)
//      .Int(FOwnerCell.FCellIndex);
//    End
//    Else
//    Begin
//      w.Int(-1).Int(-1);
//    End;
//    w.Int(FSlaveCells.Count);
//    For K := 0 To FSlaveCells.Count - 1 Do
//    Begin
//      w.Int(FSlaveCells[K].OwnerLine.FIndex);
//      w.Int(FSlaveCells[K].FCellIndex);
//    End;
//  w.free;
//end;

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
  // 除了第一个Cell都删掉
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

function TReportCell.IsSlave: Boolean;
begin
  result := OwnerCell <> nil;
end;
procedure TReportCell.DrawImage;
Var
  Acanvas: Tcanvas;
  R: Trect;
begin
    Acanvas := Tcanvas.Create;
    Acanvas.Handle := getdc(ReportControl.Handle);
    try
      R := FCellRect;
      R := FCellRect;
      ReportControl.Os.ScaleRect(R, ReportControl.FReportScale);
      ReportControl.Os.InflateRect(R,-3,-3);
      //acanvas.StretchDraw(R, ReportControl.loadbmp(self));
      acanvas.StretchDraw(R, self.FBmp);
      finally
      ReleaseDC(ReportControl.Handle, ACanvas.Handle);
      ACanvas.Free;
    end;
end;
function TReportCell.GetNextCell: TReportCell;
begin
  if CellIndex  < self.OwnerLine.FCells.Count -1 then
    Result := self.OwnerLine.FCells[CellIndex+1]
  else
    Result := nil;
end;

function TReportCell.IsDetailField: Boolean;
begin
  result := (Length(CellText) > 0) And (FCellText[1] = '#') 
end;
function TReportCell.IsSimpleField: Boolean;
begin
  result := (Length(CellText) =  0) or
      (
        (Length(CellText) > 0) And (FCellText[1] <> '#')
        And (FCellText[1] <> '`')
      )
end;

function TReportCell.IsSumAllField: Boolean;
begin
  result := (Length(CellText) > 0) And (UpperCase(copy(FCellText, 1, 7)) = '`SUMALL');
end;

function TReportCell.IsPageNumFormula: Boolean;
begin
  result := UpperCase(FCellText) = '`PAGENUM';
end;
function TReportCell.IsPageNumFormula1: Boolean;
begin
  result := UpperCase(FCellText) = '`PAGENUM/';
end;

function TReportCell.IsPageNumFormula2: Boolean;
begin
  result := UpperCase(FCellText) = '`PAGENUM-';
end;

function TReportCell.IsSumPageFormula: Boolean;
begin
  result := copy(UpperCase(FCellText), 1, 9) = '`SUMPAGE('
end;

function TReportCell.IsSumAllFormula: Boolean;
begin
  result := copy(UpperCase(FCellText), 1, 8) = '`SUMALL('
end;


procedure TReportCell.CloneFrom(ThisCell: TReportCell);
begin
    FLeftMargin := ThisCell.FLeftMargin;
    // Index
    FCellIndex := ThisCell.FCellIndex;
    // size & position
    FCellLeft := ThisCell.FCellLeft;
    FCellWidth := ThisCell.FCellWidth;
    FCellRect.Left := 0;
    FCellRect.Top := 0;
    FCellRect.Right := 0;
    FCellRect.Bottom := 0;
    FTextRect.Left := 0;
    FTextRect.Top := 0;
    FTextRect.Right := 0;
    FTextRect.Bottom := 0;
    FCellHeight := ThisCell.FCellHeight;
    // border
    FLeftLine := ThisCell.FLeftLine;
    FLeftLineWidth := ThisCell.FLeftLineWidth;
    FTopLine := ThisCell.FTopLine;
    FTopLineWidth := ThisCell.FTopLineWidth;
    FRightLine := ThisCell.FRightLine;
    FRightLineWidth := ThisCell.FRightLineWidth;
    FBottomLine := ThisCell.FBottomLine;
    FBottomLineWidth := ThisCell.FBottomLineWidth;
    // 斜线
    Diagonal := ThisCell.FDiagonal;
    // color

    FTextColor := ThisCell.FTextColor;
    FBackGroundColor := ThisCell.FBackGroundColor;
    // align
    FHorzAlign := ThisCell.FHorzAlign;
    FVertAlign := ThisCell.FVertAlign;
    Fcelldispformat := thiscell.fCellDispformat;

    Fbmp := Thiscell.FBmp;
    FbmpYn := Thiscell.FbmpYn;
end;

function TReportCell.IsHeadField: Boolean;
begin
  result := (Length(CellText) > 0) And (FCellText[1] = '@')
end;

function TReportCell.FormatValue(DataValue: Extended): string;
begin
  result := formatfloat(FCellDispformat, DataValue);
end;

function TReportCell.IsFormula: Boolean;
begin
  result := (Length(CellText) > 0) and
    (UpperCase(copy(FCellText, 1, 8)) <> '`PAGENUM') And
      (UpperCase(copy(FCellText, 1, 4)) <> '`SUM') and
      (FCellText[1] = '`') ;
end;

procedure TReportCell.LoadCF(cf: DataField);
begin
   If Not cf.IsNullField Then begin
    fbmp := TBitmap.create;
    FBmp.Assign(cf.GetField);
    FbmpYn := true;
    // 图片的话，默认的文字就不必显示了。(GRAPHIC)之类的
    CellText := '';
   end;
end;

procedure TReportCell.LoadBmp(FileName: String);
Var
  Fpicture: Tpicture;
Begin
  Fpicture := Tpicture.Create;
  try
    Fpicture.LoadFromFile(filename);
    fbmp := TBitmap.Create;
    If Not (Fpicture.Graphic Is Ticon) Then
      fbmp.Assign(Fpicture.Graphic)
    Else
    Begin
      fbmp.Width := Fpicture.Icon.Width;
      fbmp.Height := Fpicture.Icon.Height;
      fbmp.Canvas.Draw(0, 0, Fpicture.Icon);
    End;
    FbmpYn := true;
  finally
    FreeAndNil(FPicture);
    //http://stackoverflow.com/questions/3159376/which-is-preferable-free-or-freeandnil
  end;
end;

procedure TReportCell.FreeBmp;
begin              
  FreeAndNil(FBmp);
  FbmpYn := false;
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
  FTextEdit:=Edit.Create(self);
  mouseSelect := MouseSelector.Create(Self);
  MouseDrag := MouseDragger.Create(Self);
  Os := WindowsOS.create;
  Parent := TWinControl(aOwner);
  PrintPaper:= TPrinterPaper.Create;
  // 设定为无光标，防止光标闪烁。
  //  Cursor := crNone;
  Cpreviewedit := true;                 //预览时是否允许编辑单元格中的字符
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

  // 以毫米为单位
  FLeftMargin1 := 20;
  FRightMargin1 := 10;
  FTopMargin1 := 20;
  FBottomMargin1 := 15;
  // 以Dot为单位
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
  // 鼠标操作支持
  FMousePoint.x := 0;
  FMousePoint.y := 0;

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
  mouseSelect.Free;
  MouseDrag.Free;
  FTextEdit.Free;
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
//   cornice 飞檐     horn 犄角
procedure TReportControl.DrawCornice(hPaintDC:HDC);
Var
  I, J: Integer;
  TempRect: TRect;
  hGrayPen, hPrevPen: HPEN;
begin
  hGrayPen := CreatePen(PS_SOLID, 1, cc.Grey);
  try
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
  finally
    SelectObject(hPaintDC, hPrevPen);
    DeleteObject(hGrayPen);
  end;
end;
// FPageWidth  和 Width的关联，就是 FReportScale。所以，下面两行代码不行，因为没有考虑到缩放比例
//  os.SetWindowExtent(hPaintDc,1, 1);
//  os.SetViewportExtent(hPaintDC, 1, 1,);
// 可是，笛卡尔坐标是windows支持的。缩放也可以用这个东西来做！不需要自己去算。
// 而且，在编辑状态下，缩放它干啥？没有多大意思。
//  这函数名，读起来，像是卡带。你读下试试？
//  SetWindowExtEx(hPaintDC, FPageWidth, FPageHeight, @WndSize);
//  SetViewPortExtEx(hPaintDC, Width, Height, @WndSize);
procedure TReportControl.DoPaint(hPaintDC:HDC;Handle:HWND;ps:TPaintStruct);
Var
  I: Integer;
  Rect: TRect;

  rectPaint: TRect;
  Cells : TCellList;
  c : Canvas;
begin
  rectPaint := ps.rcPaint;
  //
  c := Canvas.Create(hPaintDC);
  c.SetMapMode();
  c.SetWindowExtent(FPageWidth, FPageHeight);
  c.SetViewportExtent(Width, Height);
  os.InverseScaleRect(rectPaint,FReportScale);
  c.Rectangle(0, 0, FPageWidth, FPageHeight);
  DrawCornice(hPaintDC);
  Cells := TCellList.Create(self);
  try
    Cells.MakeInteractWith(rectPaint);
    for i:= 0 to Cells.Count - 1 do
    begin
        Cells[i].DrawImage ;
        If not Cells[i].IsSlave Then
          Cells[i].PaintCell(hPaintDC, FPreviewStatus);
    end;
  finally
    Cells.Free;
    c.Free;
  end;
  if not FPreviewStatus then
    For I := 0 To FSelectCells.Count - 1 Do
    Begin
      Rect := os.IntersectRect( ps.rcPaint,FSelectCells[I].CellRect);
      if not os.IsRectEmpty(Rect) then
        InvertRect(hPaintDC, Rect);
    End;     
end;

Procedure TReportControl.WMPaint(Var Message: TMessage);
Var
  hPaintDC: HDC;
  ps: TPaintStruct;
Begin
  hPaintDC := BeginPaint(Handle, ps);
  DoPaint(hPaintDc,Handle,ps);
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

procedure TReportControl.UpdateHeight(ThisCell:TReportCell;Y:Integer);
var
    i :integer;
    BottomCell: TReportCell;
begin
  If ThisCell.FSlaveCells.Count <= 0 Then
    BottomCell := ThisCell
  Else
    BottomCell:= ThisCell.GetBottomest;
  BottomCell.CalcHeight;
  BottomCell.OwnerLine.LineHeight := Y -
    BottomCell.OwnerLine.LineTop;
  UpdateLines;
end;
Procedure TReportControl.StartMouseDrag_Horz(Point: TPoint);
begin
   self.MouseDrag.StartMouseDrag_Horz(Point);
end;

// 当前选中Cell和它的NextCell修改CellLeft，CellWidth，然后最两个Cell的前后矩形做刷新
procedure TReportControl.UpdateTwinCell(ThisCell:TReportCell;x:integer);
  Var
  TempCell, TempNextCell: TReportCell;
  ThisCellsList: TCellList;
  TempRect, RectBorder, RectCell, RectClient: TRect;
  hClientDC: HDC;
  hInvertPen, hPrevPen: HPEN;
  PrevDrawMode, PrevCellWidth, Distance: Integer;
  I, J: Integer;
  Top: Integer;
  var  NextCell: TReportCell;
  begin
    NextCell := ThisCell.NextCell;

    TempRect := ThisCell.CellRect;
    TempRect.Right := TempRect.Right + 1;
    TempRect.Bottom := TempRect.Bottom + 1;

    Distance := x - ThisCell.CellLeft - ThisCell.CellWidth;

    PrevCellWidth := ThisCell.CellWidth;
    ThisCell.CellWidth := x - ThisCell.CellLeft;

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
  end;

procedure TReportControl.MaxDragExtent(ThisCell:TReportCell;var RectBorder: TRect);
var
  NextCell: TReportCell;
  ThisLine, TempLine: TReportLine;
begin
  ThisLine := ThisCell.OwnerLine;
  RectBorder.Top := ThisLine.LineTop + (cc.DRAGMARGIN div 2);
  RectBorder.Bottom := Height - cc.DRAGMARGIN;
  NextCell := Nil;
  RectBorder.Left := ThisCell.CellLeft + cc.DRAGMARGIN;
  If ThisCell.CellIndex < ThisLine.FCells.Count - 1 Then
  Begin
    NextCell := ThisLine.FCells[ThisCell.CellIndex + 1];
    RectBorder.Right := NextCell.CellLeft + NextCell.CellWidth - cc.DRAGMARGIN;
  End
  Else
    RectBorder.Right := ClientRect.Right - cc.DRAGMARGIN;
end;

function TReportControl.QueryMaxDragExtent(ThisCell:TReportCell):TRect;
var
  NextCell: TReportCell;
  ThisLine, TempLine: TReportLine;
  RectBorder: TRect ;
begin
  ThisLine := ThisCell.OwnerLine;
  RectBorder.Top := ThisLine.LineTop + (DRAGMARGIN div 2);
  RectBorder.Bottom := Height - DRAGMARGIN;
  NextCell := Nil;
  RectBorder.Left := ThisCell.CellLeft + DRAGMARGIN;
  If ThisCell.CellIndex < ThisLine.FCells.Count - 1 Then
  Begin
    NextCell := ThisLine.FCells[ThisCell.CellIndex + 1];
    RectBorder.Right := NextCell.CellLeft + NextCell.CellWidth - DRAGMARGIN;
  End
  Else
    RectBorder.Right := ClientRect.Right - DRAGMARGIN;
  Result := RectBorder ;
end;
  // 选区和拖放区互相干涉否
  // 若无选中的CELL,或者要改变宽度的CELL和NEXTCELL不在选中区中
function TReportControl.Interference( ThisCell: TReportCell) :boolean;
var r:boolean ;
begin
  r := False;
  If FSelectCells.Count <= 0 Then
    r := True;
  If ThisCell.NextCell = Nil Then
  Begin
    If not IsCellSelected(ThisCell) Then
      r := True;
  End
  Else If (Not IsCellSelected(ThisCell)) And (Not IsCellSelected(ThisCell.NextCell))
    And
    (Not IsCellSelected(ThisCell.NextCell.OwnerCell)) Then
    r := True;
  result := not r;
end;
function TReportControl.RectBorder1(ThisCell: TReportCell;ThisCellsList: TCellList):TRect;
var R: TRect;
begin
  MaxDragExtent(ThisCell,R) ;
  R.Left := Max(ThisCellsList.MaxCellLeft + DRAGMARGIN,R.Left);
  R.Right := Min(ThisCellsList.MinNextCellRight - DRAGMARGIN,R.Right);
  result := R;
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
  Result := (FSelectCells.Count = 1) and (FSelectCells[0].FSlaveCells.Count > 0)
//  If (FSelectCells.Count = 1) Then
//  Begin
//    If FSelectCells[0].FSlaveCells.Count > 0 Then
//      Result := True
//    Else
//      Result := False;
//  End
//  Else
//    Result := False;
End;

// LCJ : 描绘被选中的单元格的轮廓
// LCJ : 把comment 字体的italic去掉。很舒服。感谢 steve jobs .
// LCJ : 来帮忙的弟妹说{一个月来有阳光的日子不过4,5回，我都数过了:}。今天，阳光明媚+1。
// LCJ : 丢掉了办公室内的交换机，也去掉了无线AP。为了办公室整洁，以后不用AP了。

// LCJ :
// 看了 {你活的累吗} ：
// LCJ : 对抑郁症人而言，能够活着本身就是伟大的。释然。比至亲更懂我。
// LCJ : 他也没有干什么啊，为什么会累? 即使不干什么，每天的消耗也比常人大得多，这就是现实
// LCJ : 当他抱怨的时候，太太只要说，年景如此不好，你还如此努力，真的是非常能干。就好了
// LCJ : 即使是上班偷个懒，对抑郁症的人来说，也是经过非常辛苦的选择，这个过程，偷来的懒无法补偿
// LCJ : 当发现有人真正了解自己，比自己还更理解，人就释然了。
// LCJ : 有如神助般的调整过来了。
// LCJ : 状态神勇的一天.
// LCJ : 然后，一个声音响起：你他妈试试每个函数五行啊。
// LCJ : 然后，另一个声音响起：你他妈听不清楚，是另外一个人说的，不是我说的吗？
// LCJ : 然后，说明，我累了。累了才会响起曾经的不愉快的事情。

Procedure TReportControl.CombineCell;
var
    OwnerCell: TReportCell;
    I, J: Integer;
    ThisCell: TReportCell;
Begin
  checkError(FSelectCells.Count < 2,cc.TwoCellSelectedAtLeast);
  checkError(not FSelectCells.IsRegularForCombine  ,cc.IsRegularForCombine);
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
    Application.Messagebox(cc.NewTableError, '警告',
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
    // LCJ : 实际操作就是这一行代码
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
    // 不知道是否应该删除
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

Function TReportControl.AddSelectedCells(Cells: TCellList): Boolean;
var i :integer;
Begin
  for i := 0 to Cells.Count -1 do
    AddSelectedCell(Cells[i]);
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
function TReportControl.RenderText(ThisCell:TReportCell):String;
begin
    Result := ThisCell.FCellText;
end;

Procedure TReportControl.InternalSaveToFile(FLineList:TList;FileName: String;PageNumber, Fpageall:integer);
Var
  TargetFile: TSimpleFileStream;
  I,j: Integer;
  ccc : TReportCell;
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
        begin
          ccc := TReportCell(TReportLine(FLineList[I]).FCells[J]);
          ccc.Save(TargetFile);
          // Cells[I,J].Save(TargetFile,IsDesign);
        end;                    
      End;
      WriteInteger(FprPageNo);
      WriteInteger(FprPageXy);
      WriteInteger(fPaperLength);
      WriteInteger(fPaperWidth);
      WriteInteger(0);//FHootNo
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
  FTextEdit.DestroyIfVisible;
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
        raise Exception.create('打开文件错误');

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
      // 多少行
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
      // 每行的属性
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        ThisLine.Load(TargetFile);
        // 每个CELL的属性
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
      ReadIntegerSkip();//FHootNo
    End;
  Finally
    TargetFile.Free;
    After;
  End;
End;

// 垂直切分单元格。一个单元格拆分成多个横向单元格（和OwnerCell无关
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
  // LCJ : 奇葩的Paint，没有他不会重画。放到函数尾部也不会重画。
  // 原来，拆分后CellRect就变了：）——一点也不奇葩
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
  //平分后多余的宽度 , 修正折分后不能对齐的问题
  xx := (ThisCell.CellRect.Right - ThisCell.CellRect.Left) Mod SplitCount;
  // 每个Cell的Width
  CellWidth := trunc((ThisCell.CellRect.Right - ThisCell.CellRect.Left) /
    SplitCount);

  ThisCell.CellWidth := CellWidth;
  For J := 0 To ThisCell.FSlaveCells.Count - 1 Do
      TReportCell(ThisCell.FSlaveCells[J]).CellWidth := CellWidth;
  For I := 1 To SplitCount - 1 Do
  Begin
    CurrentCell := TReportCell.Create(Self);
    // 此时，CellIndex是错的。需要UpdateLines ,或者CalcLineHeight 重算。
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
Begin
  // 将毫米数转化为象素点
  If (FLeftMargin1 <> nLeftMargin) Or
    (FTopMargin1 <> nTopMargin) Or
    (FRightMargin1 <> nRightMargin) Or
    (FBottomMargin1 <> nBottomMargin) Then
  Begin

    FLeftMargin1 := nLeftMargin;
    FTopMargin1 := nTopMargin;
    FRightMargin1 := nRightMargin;
    FBottomMargin1 := nBottomMargin;

    FLeftMargin := os.mm2dot(nLeftMargin );
    FTopMargin := os.mm2dot(nTopMargin);
    FRightMargin := os.mm2dot(nRightMargin);
    FBottomMargin := os.mm2dot(nBottomMargin);
    
    UpdateLines;
    RectClient := ClientRect;
    InvalidateRect(Handle, @RectClient, False);
  End;
End;

Procedure TReportControl.SetScale(Const Value: Integer);
Begin
  if FReportScale <>  Value then
  begin
    FReportScale := Value;
    CalcWndSize;
    Refresh;
  end;
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

// 2014-11-17 张英华 酸菜 3根。好。
// SetFileCellWidth 根据用户拖动表格线修改模板文件中单元格的宽度
// 将变化后的单元格宽度存入全局变量数组 


Procedure TReportControl.FreeEdit;
Begin
  Windows.SetFocus(0);
  FTextEdit.DestroyIfVisible;
  If (FEditCell <> Nil)Then
    FEditCell := Nil;
End;

Procedure TReportControl.SetCellDispFormt(mek: String);  
Var
  i: integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
    TReportCell(FSelectCells[I]).CellDispformat := mek;
End;

Procedure TReportControl.SetCellSumText(mek: String);
Var
  i: integer;
Begin
  For I := 0 To FSelectCells.Count - 1 Do
    TReportCell(FSelectCells[I]).celltext := mek;
End;


Procedure TReportControl.SetCellFocus(row, col: integer);
Var
  thiscell: TreportCell;
  ThisLine: Treportline;
Begin
  ThisLine := TReportLine(FlineList[row]);
  ThisCell := TreportCell(ThisLine.FCells[col]);
  AddSelectedCell(ThisCell);
End;
Procedure TReportControl.SelectLine(row : integer);
Begin
  SetCellsFocus(row,0,row,TReportLine(FlineList[row]).FCells.Count -1);
End;
Procedure TReportControl.SelectLines(row1,row2 : integer);
Begin
  SetCellsFocus(row1,0,row2,TReportLine(FlineList[row1]).FCells.Count -1);
End;
Procedure TReportControl.SetCellsFocus(row1, col1, row2, col2: integer);  
Var
  i, j: integer;
Begin
  For i := row1 To row2 Do
    For j := col1 To col2 Do
      AddSelectedCell(FlineList[i].FCells[j]);
End;


Procedure TReportControl.SetWndSize(w, h: integer);  
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

Procedure TReportControl.DoLoadBmp(Cell: Treportcell; filename: String);
begin
  Cell.LoadBmp(filename);
  InvalidateRect(Handle,@Cell.FCellRect,false);
End;


Procedure TReportControl.FreeBmp(Cell: Treportcell);
Begin
  Cell.FreeBmp;
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

function TReportControl.ZoomRate(height,width:integer):Integer;
  function PercentRate (a,b:Integer):integer;
  begin
    if  a  < b then
      result :=trunc((a / b)*100)
    else
      result :=100;
  end;
begin
  result := min(PercentRate(height ,FLastPrintPageHeight),PercentRate(width ,FLastPrintPageWidth));
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
constructor Combinator.Create(R: TReportControl;CellList:TCellList);
begin
  self.ReportControl := R ;
  Self.CellList := CellList;
end;

procedure Combinator.TakeupRect;
var
  os : WindowsOS ;
  i :integer;
begin
  os := WindowsOS.Create;
  os.SetRectEmpty (bigrect);
  try
    for i := 0 to CellList.Count -1 do
      bigrect := os.UnionRect(bigrect,TReportCell(CellList[i]).CellRect);
  finally
    os.free;
  end;
end;
// Is cell become a trap in the selection rect ?
function Combinator.IsPit(c : TReportCell):Boolean;
begin
  result :=
       WindowsOS.Contains(BigRect,c.CellRect) and
      (c.OwnerCell = nil) and
      (not ReportControl.IsCellSelected(c))
end;
function Combinator.IsRegularForCombine: Boolean;
var i,j:integer;
    l : TReportLine;
    c : TReportCell;
begin
  TakeupRect ;
  // A reduce calc ,but lamda is not inplace :)
  result := true;
  for i := 0 to ReportControl.FLineList.count -1 do  begin
    l := ReportControl.Lines[i];
    for j := 0 to l.FCells.Count -1 do begin
      c := l.FCells[j] ;
      if  IsPit(c) then
      begin
        result := false;
        break;
      end;
    end;
  end;
end;
function TCellList.IsRegularForCombine(): Boolean;
var c : Combinator ;
begin    
   c := Combinator.Create(Self.ReportControl,self) ;
   Result :=  c.IsRegularForCombine;
   c.Free;
end;


function TCellList.Last: TReportCell;
begin
  Result := Items[count -1];
end;

procedure TCellList.MakeFromSameRight(ThisCell: TReportCell);
var i ,J:integer;
Var
  TempCell: TReportCell;
  TempLine: TReportLine;
begin
  For I := 0 To Self.ReportControl.FLineList.Count - 1 Do
  Begin
    TempLine := TReportLine(Self.ReportControl.FLineList[I]);
    For J := 0 To TempLine.FCells.Count - 1 Do
    Begin
      TempCell := TempLine.FCells[J];
      If TempCell.CellRect.Right = ThisCell.CellRect.Right Then
        Add(TempCell);
    End;
  End;
end;

procedure TCellList.MakeFromSameRightAndInterference(ThisCell: TReportCell);
var i ,J:integer;
Var
  TempCell: TReportCell;
  TempLine: TReportLine;
begin
  For I := 0 To ReportControl.FLineList.Count - 1 Do
  Begin
    TempLine := TReportLine(ReportControl.FLineList[I]);
    For J := 0 To TempLine.FCells.Count - 1 Do
    Begin
      TempCell := TReportCell(TempLine.FCells[J]);
      If   (TempCell.CellRect.Right = ThisCell.CellRect.Right) then
        if  ((ReportControl.IsCellSelected( TempCell.NextCell)) or TempCell.IsSelected) Then
          Begin
            Add(TempCell);
            Break;
          End;
    End;
  End;     
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
function TCellList.MaxCellBottom: Integer;
var R ,I: Integer ;
begin
  R := 0;
  For I := 0 To Count - 1 Do
    R := Max (R,Items[I].CellRect.Bottom);
  Result := R;
end;

function TCellList.MaxCellLeft: integer;
var J ,R:integer;ThisCell :TReportCell;
begin
  R := 0 ;
  For J := 0 To Count - 1 Do
  Begin
    ThisCell := Items[J];
    If ThisCell.CellRect.Left > R Then
      R := ThisCell.CellRect.Left ;
  End;
  result := R;
end;

function TCellList.MinNextCellRight: integer;
var J ,R:integer;ThisCell :TReportCell;
begin
  R := 65535 ;
  For J := 0 To Count - 1 Do
  Begin
    ThisCell := Items[J].NextCell;
    If (ThisCell <> nil) and (ThisCell.CellRect.Right < R) Then
      R := ThisCell.CellRect.Right ;
  End;
  result := R;
end;

function TCellList.TotalWidth: Integer;
var J :integer;
begin
  Result :=0 ;
  For J := 0 To Count - 1 Do
    Result := Result + TReportCell(Items[J]).CellWidth;
end;
// 右边的CELL不为空且隶属于某一CELL，就别闹了，人家有女朋友了：）
procedure TCellList.CheckAllNextCellIsSlave;
var i,j:Integer; ThisCell :TReportCell;
begin
  For I := 0 To Count - 1 Do
    For J := 0 To Items[I].FSlaveCells.Count - 1 Do
      Add(Items[I].FSlaveCells[J]);
  If Count > 0 Then
  Begin
    ThisCell := Items[0];
    If (ThisCell.NextCell <> Nil) and (ThisCell.NextCell.OwnerCell <> Nil )Then
        raise TBlueException.Create('');
  End;
end;
// 右边的Cell的Bottom比选择的Cell的最大Bottom还大，也不玩了。人家后台硬：）
procedure TCellList.CheckAllNextCellIsBiggerBottom ;
var i,j,DragBottom:Integer; ThisCell :TReportCell;
begin
  For I := 0 To Count - 1 Do
    For J := 0 To Items[I].FSlaveCells.Count - 1 Do
      Add(Items[I].FSlaveCells[J]);
  If Count > 0 Then
  Begin
    ThisCell := Items[0];
    DragBottom := Max(0,MaxCellBottom);
    For I := 0 To Count - 1 Do
    Begin
      ThisCell := Items[I];
      If (ThisCell.NextCell <> Nil) and( ThisCell.NextCell.CellRect.Bottom > DragBottom) Then
          raise TBlueException.Create('');
    End;
  End;
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

function TReportControl.MousePoint(Message: TMessage): TPoint;
begin
  Result.x := LOWORD(Message.lParam);
  Result.y := HIWORD(Message.lParam);
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
    // 合并同一列的单元格 -- 只要将下面行的Cell加入到第一行内cell的OwneredCell即可
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
procedure TSimpleFileStream.ReadIntegerSkip;
var a: Integer;
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


function TLineList.TotalHeight: Integer;var i :Integer;
begin
  Result := 0;
  for i := 0 to Count -1 do
    Result := Result + Items[i].GetLineHeight;
end;

function TReportLine.IsDetailLine: Boolean;
var i : integer;
begin
  Result := False;
  for i:= 0 to FCells.Count -1 do
    If  TReportCell(FCells[i]).IsDetailField Then
    Begin
      Result := true;
      exit;
    End;
end;

function TReportLine.IsSumAllLine: Boolean;
var j :Integer;
begin
  result:= false;
  For j := 0 To FCells.Count - 1 Do
    if TReportCell(FCells[j]).IsSumAllField then
    begin
      result:= true;
      exit;
    end;
end;

{ TDRMappings }



function TDRMappings.FindRuntimeMasterCell(ThisCell: TReportCell): TReportCell;
var r : TReportCell;L:Integer;
begin
  R := Nil;
  // 若找到隶属的CELL则将自己加入到该CELL中去
  For L := 0 To Count - 1 Do
  Begin
    If ThisCell.OwnerCell = TDRMapping(Self[L]).DesignMasterCell Then
      R := TDRMapping(Self[L]).RuntimeMasterCell;
  End;
  result:= R;
end;

procedure TDRMappings.FreeItems;
var n :Integer;
begin
    For N := Count - 1 Downto 0 Do
      TDRMapping(Items[N]).Free;
end;

procedure TDRMappings.NewMapping(ThisCell, NewCell: TReportCell);
var
  m : TDRMapping ;
begin
  m := TDRMapping.Create;
  m.DesignMasterCell := ThisCell;
  m.RuntimeMasterCell := NewCell;
  Add(m);
end;

function TLineList.ToString: String;
var
  i : integer;
  line:TReportLine;r:string;
begin
  R := '';
  for i := 0 to Count -1 do
  begin
    line := Items[i];
    if '' <> line.ToString then
      R := R + line.ToString +#13#10;
  end;
  Result := R;
end;
function TCellList.ToString: String;
var
  i :Integer;
begin
   For i := 0 To Count - 1 Do
     Result := Result + Items[i].CellText;
end;

function TReportLine.ToString: String;
 var i :Integer;
begin
   For i := 0 To FCells.Count - 1 Do
     Result := Result + TReportCell(FCells[i]).CellText;
end;
function DataField.ds : TDataset ;
begin
 result := FDs;
end;
function DataField.GetField() : TField ;
begin
 result := ds.fieldbyname(GetFieldName())
end;
function DataField.IsDataField(s:String):Boolean;
begin
  result :=  (Length(s) < 2) or
   ((s[1] <> '@') And (s[1] <> '#'));
   result := not result ;
end;

Function DataField.GetFieldName(): String;
Begin
    Result := Self.FFieldName;
End;

function DataField.IsNumberField():Boolean;
begin
  result := ds.fieldbyname(GetFieldName()) Is tnumericField
end;
function DataField.IsNullField( ):Boolean;
begin
  result := FDs.fieldbyname(GetFieldName()).isnull;
end;
function DataField.DataValue():Extended;
begin
    result := ds.fieldbyname(GetFieldName()).value ;
end;
constructor DataField.Create(ds:TDataset;FFieldName : String);
begin
  Self.FFieldName := FFieldName ;
  FDs := ds ;
end;

function DataField.IsBlobField: Boolean;
begin
   result := False ;
   if ds = nil then exit;
   if nil = ds.fieldbyname(GetFieldName()) then  exit; 
   result := ds.fieldbyname(GetFieldName()) Is Tblobfield
end;

constructor StrSlice.Create(str: String);
begin
  FStr := str;
end;

function StrSlice.GoUntil(c: char): integer;
var i : integer;
begin
  i := 2;
  while  (i < Length(FStr)) and  ( FStr[I] <> c ) do
    inc(i);
  result := i ;
end;

function StrSlice.Slice(b, e: integer): string;
var i : integer;
begin
   result := '';
   i := b ;
   while i <=e do begin
    result := result + FStr[i];
    inc(i);
   end;
end;

function StrSlice.Slice(b: integer): string;
begin
  result := Slice(b,Length(FStr));
end;

class function StrSlice.DoSlice(str: String; FromChar:char): string;
var   s:StrSlice;
begin
    s:=StrSlice.Create(str);
    Result := s.Slice(s.GoUntil(FromChar)+1);
    s.Free ;
end;
{ TVarList }

function TVarList.KeepAlphaOnly(a:string):string;
Var
  I: Integer;
begin
  Result := '';
  For I := 1 To Length(a) Do
  Begin
    If (a[I] <= 'z') Or (a[I] >= 'A') Then
      Result := Result + a[I];
  End;
end;
function TVarList.GetVarValue(Key: String): String;
Var
  ThisItem: TVarTableItem;
Begin
  Result := '';
  If (Length(Key) <= 0) or (Key[1] <> '`' ) Then
    Exit;
  If UpperCase(Key) = '`DATE' Then
    Result := datetostr(date);
  If UpperCase(Key) = '`TIME' Then
    Result := timetostr(time);
  If UpperCase(Key) = '`DATETIME' Then 
    Result := datetimetostr(now);
  Key := Uppercase(KeepAlphaOnly(Key));
  ThisItem := FindKey(Key);
  if  nil <> ThisItem then
    Result := ThisItem.strVarValue;
End;
function TVarList.FindKey(Key: String): TVarTableItem;
var
  I :Integer;
  ThisItem : TVarTableItem ;
begin
  Key := Uppercase(KeepAlphaOnly(Key));
  Result := nil;
  For I := 0 To Count - 1 Do
  Begin
    ThisItem := TVarTableItem(Items[I]);
    If (cc.FormulaPrefix+ThisItem.strVarName = Key )Then
    Begin
      Result := ThisItem ;
      break;
    End;
  End;
end;
function TVarList.FindKeyOrNew(Key: String): TVarTableItem;
var
  ThisItem : TVarTableItem ;
begin
  Result := FindKey(Key);
  if Result = nil then
    Result :=  New (Key);
end;
function TVarList.New (Key: String): TVarTableItem;
var
  ThisItem : TVarTableItem ;
begin
  ThisItem := TVarTableItem.Create;
  ThisItem.strVarName := Key;
  Add(ThisItem);
  Result := ThisItem;
end;


procedure TVarList.FreeItems;
var i :Integer;
begin
  For I := Count - 1 Downto 0 Do
    TVarTableItem(Items[I]).Free;
end;
// 运行逻辑：如果设计态是Slave，在runtime时也得是奴隶，通过这个FOwnerCellList找到自己的新主人
// 若隶属的CELL不为空则判断是否在同一页，若不在同一页则将自己加入到CELL对照表中去
// 若找到隶属的CELL则将自己加入到该CELL中去
// 科幻小说程序员版本：
// 设计态和运行态，是一对平行宇宙，在这个宇宙，你有一个主人，当迁移到另外一个宇宙时，你也得找到你的主人，不能做流浪的Cell
procedure TDRMappings.RuntimeMapping(NewCell, ThisCell:TReportCell);
var
  TempOwnerCell: TReportCell;
begin
  If ThisCell.OwnerCell <> Nil Then
  Begin
    TempOwnerCell := FindRuntimeMasterCell(ThisCell);
    If TempOwnerCell = Nil Then
      NewMapping(ThisCell.OwnerCell,NewCell)
    Else
      TempOwnerCell.Own(NewCell);
  End;
  If ThisCell.FSlaveCells.Count > 0 Then
    NewMapping(ThisCell,NewCell);
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
procedure TCellList.ClearBySelection(R: TRect);
var
  i : integer;
  ThisCell:TReportCell;
begin
  For I := Count - 1 Downto 0 Do
  Begin
    ThisCell := TReportCell(ReportControl.FSelectCells[I]);
    if not ReportControl.os.IsIntersect(ThisCell.CellRect, R) then
        ReportControl.RemoveSelectedCell(ThisCell);
  End;
end;

procedure TCellList.MakeInteractWith(R: TRect);
var i,j :Integer;
Var
  ThisCell: TReportCell;
  ThisLine: TReportLine;
begin
  For I := 0 To self.ReportControl.FLineList.Count - 1 Do
  Begin
    ThisLine := ReportControl.FLineList[I];
    If ReportControl.os.IsIntersect(R, ThisLine.LineRect) Then
      For J := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := ThisLine.FCells[J];
        if ReportControl.os.IsIntersect(ThisCell.CellRect, R) Then
        Begin
          If ThisCell.IsSlave Then
            ThisCell :=  ThisCell.OwnerCell ;
          Add(ThisCell);
        End;
      End;
  End;
end;

{ Edit }

constructor Edit.Create(R: TReportControl);
begin
  FControl := R;
  FEditWnd := INVALID_HANDLE_VALUE;
  FEditBrush := INVALID_HANDLE_VALUE;
  FEditFont := INVALID_HANDLE_VALUE;
end;
function Edit.CreateEdit(Handle:HWND;Rect: TRect; LogFont: TLOGFONT;Text: String;FHorzAlign:Integer): HWND;
var
  dwStyle: DWORD;
begin
  If FEditFont <> INVALID_HANDLE_VALUE Then
    DeleteObject(FEditFont);
  FEditFont := CreateFontIndirect(LogFont);
  dwStyle :=
      WS_VISIBLE Or
      WS_CHILD Or
      ES_MULTILINE or
      ES_AUTOVSCROLL or
      FControl.os.HAlign2DT(FHorzAlign);
  FEditWnd := CreateWindow('EDIT', '', dwStyle, 0, 0, 0, 0, Handle, 1,
    hInstance, Nil);
  SendMessage(FEditWnd, WM_SETFONT, FEditFont, 1); // 1 means TRUE here.
  SendMessage(FEditWnd, EM_LIMITTEXT, 3000, 0);
  MoveWindow(FEditWnd, Rect.left, Rect.Top,
    Rect.Right - Rect.Left,
    Rect.Bottom - Rect.Top, True);
  SetWindowText(FEditWnd, PChar(Text));
  ShowWindow(FEditWnd, SW_SHOWNORMAL);
  Windows.SetFocus(FEditWnd);
  result := FEditWnd ;
end;
function Edit.GetText(): String;
var
  TempChar: Array[0..3000] Of Char;
begin
  GetWindowText(FEditWnd, TempChar, 3000);
  Result := TempChar;
end;

procedure Edit.MoveRect(TextRect:TRect);
begin
  MoveWindow(FEditWnd, TextRect.left, TextRect.Top,
    TextRect.Right - TextRect.Left,
    TextRect.Bottom - TextRect.Top, True);
end;
procedure Edit.DestroyIfVisible();
begin
  If IsWindowVisible() Then
    DestroyWindow();
end;

function Edit.IsWindowVisible():Boolean;
begin
  result := windows.IsWindowVisible(FEditWnd) ;
end;
procedure Edit.DestroyWindow();
begin
  windows.DestroyWindow(FEditWnd);
end;
function Edit.CreateBrush(Color:Cardinal):HBRUSH;
var
  TempLogBrush: TLOGBRUSH;
begin
    If FEditBrush <> INVALID_HANDLE_VALUE Then
      DeleteObject(FEditBrush);
    TempLogBrush.lbStyle := PS_SOLID;
    TempLogBrush.lbColor := Color;
    FEditBrush := CreateBrushIndirect(TempLogBrush);
    Result := FEditBrush;
end;

{ Combinator }


function DataField.IsAvailableNumberField: Boolean;
begin
  result := isNumberField  and (not IsNullField) 
end;

{ TSimpleReader }

function TSimpleReader.Bool(var a: Boolean): TSimpleReader;
begin
     FStream.ReadBoolean(a);
  result := Self;
end;

function TSimpleReader.Cardinal(var a: Cardinal): TSimpleReader;
begin
   FStream.ReadCardinal(a);
  result := Self;
end;

constructor TSimpleReader.Create(sfs: TSimpleFileStream);
begin
  FStream := sfs;
end;

function TSimpleReader.Int(var a: Integer): TSimpleReader;
begin
    FStream.ReadInteger(a);
  result := Self;
end;

function TSimpleReader.LOGFONT(var a: TLOGFONT): TSimpleReader;
begin
    FStream.ReadTLOGFONT(a);
  result := Self;
end;

function TSimpleReader.Rect(var a: TRect): TSimpleReader;
begin
    FStream.ReadRect(a);
  result := Self;
end;

function TSimpleReader.Str(var a: String): TSimpleReader;
begin
    FStream.ReadString(a);
  result := Self;
end;

function TSimpleReader.Word(var a: Word): TSimpleReader;
begin
    FStream.ReadWord(a);
  result := Self;
end;

{ TSimpleWriter }

function TSimpleWriter.Bool(a: Boolean): TSimpleWriter;
begin
    FStream.WriteBoolean(a);
  result := Self;
end;

function TSimpleWriter.Cardinal(a: Cardinal): TSimpleWriter;
begin
    FStream.WriteCardinal(a);
  result := Self;
end;

constructor TSimpleWriter.Create(sfs: TSimpleFileStream);
begin
  FStream := sfs;
end;

function TSimpleWriter.Int(a: Integer): TSimpleWriter;
begin
  FStream.WriteInteger(a);
  result := Self;
end;

function TSimpleReader.IntSkip:TSimpleReader;
begin
  FStream.ReadIntegerSkip;
  result := Self;
end;

function TSimpleWriter.LOGFONT(a: TLOGFONT): TSimpleWriter;
begin
  FStream.WriteTLOGFONT(a);
  result := Self;
end;

function TSimpleWriter.Rect(a: TRect): TSimpleWriter;
begin
  FStream.WriteRect(a);
  result := Self;
end;

function TSimpleWriter.Str(a: String): TSimpleWriter;
begin
  FStream.WriteString(a);
  result := Self;
end;

function TSimpleWriter.Word(a: Word): TSimpleWriter;
begin
   FStream.WriteWord(a);
  result := Self;
end;

end.

