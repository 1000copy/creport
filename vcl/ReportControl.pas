
Unit ReportControl;

Interface

Uses
  Windows, Messages, SysUtils,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Math, Printers, Menus, dbgrids, Db, jpeg, dbtables,
  DesignEditors, DesignIntf, ShellAPI, ExtCtrls;

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

  TReportCell = Class(TObject)
  Private
    { Private declarations }
    FLeftMargin: Integer;               // ��ߵĿո�
    FOwnerLine: TReportLine;            // ������
    FOwnerCell: TReportCell;            // �����ĵ�Ԫ��
    FCellsList: TList;                  // ���ǵ�Cell

    // Index
    FCellIndex: Integer;                // Cell�����е�����

    // size & position
    FCellLeft: Integer;
    FCellWidth: Integer;

    FCellRect: TRect;                   // �������
    FTextRect: TRect;

    FDragCellHeight: Integer;
    FMinCellHeight: Integer;
    FRequiredCellHeight: Integer;

    // Cell��Top���Դ�����������ȡ��
    // int GetCellTop();
    // Cell��Height���Դ������кͿ�Խ����ȡ��
    // int GetCellHeight();

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
    Function GetCellHeight: Integer;
    Function GetCellTop: Integer;
    Function GetOwnerLineHeight: Integer;
    function DefaultHeight(cell: TReportCell): integer;
    function GetBottomest(FOwnerCell: TReportCell): TReportCell;
    procedure GetTextRect(var TempRect: TRect);
    function GetTotalHeight(FOwnerCell: TReportCell): Integer;
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
    { Public declarations }
    Procedure AddOwnedCell(Cell: TReportCell);
    Procedure RemoveAllOwnedCell;
    Procedure RemoveOwnedCell(Cell: TReportCell);
    Function IsCellOwned(Cell: TReportCell): Boolean;
    Procedure CalcCellTextRect;
    Procedure CalcMinCellHeight;
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

    // б��
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
  Private
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

  TReportControl = Class(TWinControl)
  Private
    FCreportEdit: boolean;
    { Private declarations }
    FPreviewStatus: Boolean;

    FLineList: TList;
    FSelectCells: TList;
    FEditCell: TReportCell;

    FReportScale: Integer;
    FPageWidth: Integer;
    FPageHeight: Integer;

    FLeftMargin: Integer;               // 1
    FRightMargin: Integer;
    FTopMargin: Integer;
    FBottomMargin: Integer;

    FcellFont: TlogFont;
    FcellFont_d: TlogFont;

    FLeftMargin1: Integer;
    FRightMargin1: Integer;
    FTopMargin1: Integer;
    FBottomMargin1: Integer;

    FHootNo: integer;                   //��β�ĵ�һ��������ҳ�ĵڼ��� lzl 

    // ��ҳ�ӱ�ͷ�����ӱ�ͷ��
    FNewTable: Boolean;

    // �����ӡ�����к���¼ӱ�ͷ
    FDataLine: Integer;

    FTablePerPage: Integer;

    // ������֧��
    FMousePoint: TPoint;

    // �༭����ɫ������
    FEditWnd: HWND;
    FEditBrush: HBRUSH;
    FEditFont: HFONT;
    //procedure SetScale(const Value: Integer);

    //FReportMenu : TPopupMenu;

    Procedure setCreportEdit(Const value: boolean);
    Procedure SetCellSFocus(row1, col1, row2, col2: integer);
    function Get(Index: Integer): TReportLine;
    function GetCells(Row, Col: Integer): TReportCell;

  Protected
    { Protected declarations }
    Procedure CreateWnd; Override;
  Public
    { Public declarations }
    Procedure SetSelectedCellFont(cf: TFont);
    procedure SelectLines(row1, row2: integer);  //add lzl ѡ��Ԫ��
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    //procedure setSaveToFile(callRow,lenk:integer;RcallText:array of string);
    Procedure SaveToFile(FileName: String);
    Procedure LoadFromFile(FileName: String);

    Procedure SetCellFocus(row, col: integer); //add lzl ѡ��Ԫ��


    Procedure SaveBmp(thiscell: Treportcell; filename: String); //lzl add
    Function LoadBmp(thiscell: Treportcell): TBitmap; //lzl add
    Procedure FreeBmp(thiscell: Treportcell); //lzl add
    Procedure SetLineHegit(row, h: integer); // lzl add

    Procedure PrintIt;
    Procedure ResetContent;
    Procedure SetScale(Const Value: Integer);

    Property cellFont: TlogFont Read Fcellfont Write Fcellfont; //default true;
    Property cellFont_d: TlogFont Read Fcellfont_d Write Fcellfont_d;  //default true;

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
    Procedure SetWndSize(w, h: integer);  //�ڶ��嶯̬����ʱ,����ֽ�Ĵ�С ������windows�Ĵ�ӡ���öԿ�ʱ
    Procedure SetPageSize(w, h: integer); //add lzl ��̬��������ֽ�Ŵ�С

    Procedure NewTable(ColNumber, RowNumber: Integer);

    Procedure InsertLine;
    Function CanInsert: Boolean;
    Procedure AddLine;
    Function CanAdd: Boolean;
    Procedure DeleteLine;

    Procedure InsertCell;
    Procedure DeleteCell;
    Procedure AddCell;

    Procedure GetCellsWadth(HasDataNo: integer); //lzl
    Procedure SetFileCellWidth(filename: String; HasDataNo: integer); //lzl 

    Procedure CombineCell;

    Procedure SplitCell;
    Procedure VSplitCell(Number: Integer);
    Function CanSplit: Boolean;

    Function CountFcells(crow: integer): integer; //lzl 

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

    Function getcellfont: tfont;        // add wang hang song

    Procedure UpdateLines;

    Procedure FreeEdit;                 //ȡ���༭״̬  lzl 

    Procedure StartMouseDrag(point: TPoint);
    Procedure StartMouseSelect(point: TPoint; bSelectFlag: Boolean; shift_down:
      byte);
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
    Property DataLine: Integer Read FDataLine Write FDataLine Default
      2147483647;
    Property TablePerPage: Integer Read FTablePerPage Write FTablePerPage Default
      2147483647;
    property Lines[Index: Integer]: TReportLine read Get  ;
    property Cells[Row: Integer;Col: Integer]: TReportCell read GetCells ;
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
    Property CreportEdit: boolean Read FCreportEdit Write setCreportEdit;  //�����Ƿ���ģ��༭���������
  End;

  //  TDragOverEvent = procedure(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean) of object;

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


 type
  EachCellProc =  procedure (ThisCell:TReportCell) of object;
  EachLineProc =  procedure (ThisLine:TReportLine)of object;
  EachLineIndexProc = procedure (ThisLine:TReportLine;Index:Integer)of object;
  TReportRunTime = Class(TComponent)
  Private

    SumPage, SumAll: Array[0..40] Of real;  //С�ƺͺϼ���,���40�е�Ԫ��,����ͳ�ƻ���ʱҪ����.

    FFileName: Tfilename;
    FAddSpace: boolean;
    FdbGrid: Tdbgrid;                   //add lzl
    FSetData: TstringList;              //add lzl

    FEnableEdit: Boolean;

    FVarList: TList;                    // ������������ֺ�ֵ�Ķ��ձ�
    FLineList: TList;                   // ���汨��������Ϣ�����ļ��ж��룩
    FPrintLineList: TList;              //����Ҫ��ӡ��ĳһҳ������Ϣ
    FOwnerCellList: TList;              // ����ÿһҳ�кϲ���Ԫ��ǰ���ָ��

    Cp_DFdList: TList;                  // �������ݼ���ָ������ƵĶ���

    Width: Integer;
    Height: Integer;

    // ���廻ҳ�ӱ�ͷ
    FNewTable: Boolean;

    // �����ӡ�����к���¼ӱ�ͷ
    FDataLine: Integer;
    FTablePerPage: Integer;

    FReportScale: Integer;
    FPageWidth: Integer;
    FPageHeight: Integer;

    FHeaderHeight: Integer;

    Fallprint: Boolean;                 //�Ƿ��ӡȫ����¼��Ĭ��Ϊȫ��

    FLeftMargin: Integer;               //2
    FRightMargin: Integer;
    FTopMargin: Integer;
    FBottomMargin: Integer;

    FLeftMargin1: Integer;
    FRightMargin1: Integer;
    FTopMargin1: Integer;
    FBottomMargin1: Integer;

    FPageCount: Integer;                // page count in print preview //��ҳ��

    FHootNo: integer;
    FEditEpt: boolean;                  //��β�ĵ�һ��������ҳ�ĵڼ��� lzl 
    nDataHeight, nHandHeight, nHootHeight, nSumAllHeight: Integer;
    TempDataSet: TDataset;
    hasdatano: integer;
    Procedure UpdateLines;
    Procedure UpdatePrintLines;
    Procedure PrintOnePage;
    Procedure LoadRptFile;
    Function GetDatasetName(strCellText: String): String;
    Function GetDataset(strCellText: String): TDataset;
    Function DatasetByName(strDatasetName: String): TDataset;
    Function GetVarValue(strVarName: String): String;
    Function GetFieldName(strCellText: String): String;
    Procedure SetRptFileName(Const Value: TFilename);

    Procedure Setdbgrid(Const Value: Tdbgrid);

    //   procedure LFOnSetEpt(const value:Tnotifyevent);

    //Procedure LSetData(Const value: TstringList);

    //Procedure Setpar(FIDE, Tableopen: boolean; name: String);
    Function LFindComponent(Owner: TComponent; Name: String): TComponent;

    Procedure SaveTempFile(PageNumber, Fpageall: Integer);

    Function setSumAllYg(fm, ss: String): String; //add lzl
    Function setSumpageYg(fm, ss: String): String; //add lzl

    Procedure LoadTempFile(strFileName: String);
    Procedure DeleteAllTempFiles;
    Procedure SetEnableEdit(Value: Boolean);
    Procedure SetEditept(Value: Boolean); //add lzl
    Procedure SetNewCell(spyn: boolean; NewCell, ThisCell: TReportCell);
    Procedure SetAddSpace(Const Value: boolean);
    procedure SetEmptyCell(NewCell, ThisCell: TReportCell);
    function HasEmptyRoomLastPage: Boolean;
    function IsLastPageFull: Boolean;
    function isPageFull: boolean;
    function CloneEmptyLine(thisLine: TReportLine): TReportLine;
    function FillHeadList(var nHandHeight: integer): TList;
    function GetHasDataPosition(var HasDataNo,
      cellIndex: integer): Boolean;
    function AppendList(l1, l2: TList): Boolean;
    function ExpandLine(var HasDataNo, ndataHeight: integer): TReportLine;
    function FillFootList(var nHootHeight: integer): TList;
    function FillSumList(var nSumAllHeight: integer): TList;
    function GetNhassumall(): Integer;
    procedure JoinAllList(FPrintLineList, HandLineList, dataLineList,
      SumAllList, HootLineList: TList;IsLastPage:Boolean);
    procedure PaddingEmptyLine(hasdatano: integer; var dataLineList: TList;
      var ndataHeight: integer; var khbz: boolean);overload;
    procedure PaddingEmptyLine(hasdatano: integer;
      var ndataHeight: integer; var khbz: boolean);overload;
    function SumCell(ThisCell: TReportCell; j: Integer): Boolean;
    procedure SumLine(var HasDataNo: integer);
    function PreparePrintk_PageCount(): integer;
    function ExpandLine_Height(var HasDataNo,
      ndataHeight: integer): TReportLine;
    function GetDataSetFromCell(HasDataNo,CellIndex:Integer):TDataset;
    procedure EachCell(EachProc: EachCellProc);
    procedure EachLine(EachProc: EachLineProc);
    procedure EachCell_CalcMinCellHeight(ThisCell: TReportCell);
    procedure EachProc_CalcLineHeight(thisLine: TReportLine);
    procedure EachLineIndex(EachProc: EachLineIndexProc);
    procedure EachLineIndexProc_UpdateIndex(thisLine: TReportLine;
      Index: integer);
    procedure EachProc_UpdateIndex(thisLine: TReportLine; I: integer);
    procedure EachProc_UpdateLineRect(thisLine: TReportLine;
      Index: integer);
    procedure EachProc_UpdateLineTop(thisLine: TReportLine;
      I: integer);

  Protected

  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetDataset(strDatasetName: String; pDataSet: TDataSet);
    Procedure SetVarValue(strVarName, strVarValue: String);
    Property allprint: boolean Read Fallprint Write Fallprint Default true;
    Procedure ResetContent;
    Procedure PrintPreview(bPreviewMode: Boolean);
    Function shpreview: boolean;        //��������Ԥ���й��ļ�
    Function PrintSET(prfile: String): boolean; //ֽ�ż��߾����ã�lzl 
    Procedure updatepage;               //
    Function PreparePrintk(SaveYn: boolean; FpageAll: integer): integer;  //lzl ����


//    Procedure PreparePrint;
    Procedure loadfile(value: tfilename);
    Procedure Print(pYn: boolean);
    Procedure Resetself;
    Function Cancelprint: boolean;


  Published
    Property ReportFile: TFilename Read FFileName Write SetRptFileName;

    Property PrDbGrid: Tdbgrid Read Fdbgrid Write Setdbgrid; //add lzl

    Property EnableEdit: boolean Read FEnableEdit Write setEnableEdit; //add lzl

    Property EditEpt: boolean Read FEditEpt Write setEditEpt;

    Property AddSpace: boolean Read FAddSpace Write SetAddSpace; //

  End;


  TCellTable = Class(TObject)
    PrevCell: TReportCell;
    ThisCell: TReportCell;
  End;

Procedure prDeviceMode;                 //ȡ�õ�ǰ��ӡ����DeviceMode�Ľṹ��Ա
Function DeleteFiles(FilePath, FileMask: String): Boolean;
Procedure Register;

Var
  CXlsBof: Array[0..5] Of Word = ($809, 8, 0, $10, 0, 0);
  CXlsEof: Array[0..1] Of Word = ($0A, 00);
  CXlsLabel: Array[0..5] Of Word = ($204, 0, 0, 0, 0, 0);
  CXlsNumber: Array[0..4] Of Word = ($203, 14, 0, 0, 0);
  CXlsRk: Array[0..4] Of Word = ($27E, 10, 0, 0, 0);
  CXlsBlank: Array[0..4] Of Word = ($201, 6, 0, 0, $17);

  Adevice, Adriver, Aport: Array[0..255] Of char; //prdevixemode���� lzl 2002.3
  DeviceHandle: THandle;
  DevMode: PdeviceMode; //��ǰ��ӡ���ṹ��Ա������prdevixemode��ʼ�� lzl 

  FprPageNo: integer;                   //��ӡ�ļ���ֽ�����  lzl 
  FprPageXy: integer;                   //��ӡ�ļ���ֽ���ݺ᷽��  lzl 
  fpaperLength: integer;
  fpaperWidth: integer;

  cp_pgw, cp_pgh, scale: integer;

  Cpreviewedit: boolean;

  CellsWidth: Array Of Array Of integer;  //lzl  ���û���Ԥ��ʱ�϶������µĵ�Ԫ����,
  NhasSumALl: integer;                  //�кϼƵ�����ģ�����ǵڼ���.

  cp_prewYn: Boolean;                   //�����Ƿ���Ԥ��״̬, lzl ��2001.4.27
  //EditEpt:boolean; //�Ƿ�����û���Ԥ��ʱ���ñ༭�����޸�ģ��

  CreportIde: boolean;
  cellline_d: TReportCell;              //���ڱ���ѡ�е�Ԫ������� 1999.1.25
  isprint: byte;                        //�����Ƿ��Ѱ�װ��ӡ��
  celldisp: TReportCell;                //������ʾMouseλ�õĵ�Ԫ������

Implementation

{$R ReportControl.dcr}
Uses Preview, REPmess, margin,
  Creport, About, Border, vsplit, Color, diagonal, margink, NewDialog; //add lzl

Procedure prDeviceMode; //ȡ�õ�ǰ��ӡ����DeviceMode�Ľṹ��Ա   lzl 
Begin
  Printer.GetPrinter(Adevice, Adriver, Aport, DeviceHandle);
  If DeviceHandle = 0 Then
  Begin
    printer.PrinterIndex := printer.PrinterIndex;
    Printer.GetPrinter(Adevice, Adriver, Aport, DeviceHandle);
  End;
  If DeviceHandle = 0 Then
    Raise Exception.Create('Could Not Initialize TdeviceMode Structure')
  Else
    DevMode := GlobalLock(DeviceHandle);
  {!!!}
  If Not DeviceHandle = 0 Then
    GlobalLock(DeviceHandle);
End;

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
  RegisterComponents('CReport', [TReportRunTime]);

End;

///////////////////////////////////////////////////////////////////////////
// TReportCell

{TReportCell}




Procedure TReportCell.SetLeftMargin(LeftMargin: Integer);
Begin
  // �޸�����Ԥ���Ŀհ�����
  // �Ǻǣ�Ŀǰֻ����5��
  If (LeftMargin = FLeftMargin) Or
    (LeftMargin < 5) Or (LeftMargin > 5) Then
    Exit;

  FLeftMargin := LeftMargin;
  CalcMinCellHeight;
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
    Cell.CalcMinCellHeight;

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
    CalcMinCellHeight;
    CalcCellTextRect;
  End
  Else
  Begin
    FCellWidth := 10;
    CalcMinCellHeight;
    CalcCellTextRect;
  End;
End;

Function TReportCell.GetCellHeight: Integer;
Begin
  If FOwnerLine = Nil Then
    Result := 0
  Else
  Begin
    If FDragCellHeight > FMinCellHeight Then
      Result := FDragCellHeight
    Else
      Result := FMinCellHeight;
  End;
End;

Function TReportCell.GetCellTop: Integer;
Begin
  If FOwnerLine = Nil Then
    Result := 0
  Else
    Result := FOwnerLine.LineTop;
End;

Procedure TReportCell.SetLeftLine(LeftLine: Boolean);
Begin
  If LeftLine = FLeftLine Then
    Exit;

  FLeftLine := LeftLine;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetLeftLineWidth(LeftLineWidth: Integer);
Begin
  If LeftLineWidth = FLeftLineWidth Then
    Exit;

  FLeftLineWidth := LeftLineWidth;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetTopLine(TopLine: Boolean);
Begin
  If TopLine = FTopLine Then
    Exit;

  FTopLine := TopLine;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetTopLineWidth(TopLineWidth: Integer);
Begin
  If TopLineWidth = FTopLineWidth Then
    Exit;

  FTopLineWidth := TopLineWidth;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetRightLine(RightLine: Boolean);
Begin
  If RightLine = FRightLine Then
    Exit;

  FRightLine := RightLine;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetRightLineWidth(RightLineWidth: Integer);
Begin
  If RightLineWidth = FRightLineWidth Then
    Exit;

  FRightLineWidth := RightLineWidth;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetBottomLine(BottomLine: Boolean);
Begin
  If BottomLine = FBottomLine Then
    Exit;

  FBottomLine := BottomLine;
  CalcMinCellHeight;
  CalcCellTextRect;

End;

Procedure TReportCell.SetBottomLineWidth(BottomLineWidth: Integer);
Begin
  If BottomLineWidth = FBottomLineWidth Then
    Exit;

  FBottomLineWidth := BottomLineWidth;
  CalcMinCellHeight;
  CalcCellTextRect;
End;

Procedure TReportCell.SetCellText(CellText: String);
Begin
  If CellText = FCellText Then
    Exit;

  FCellText := CellText;
  CalcMinCellHeight;

End;

Procedure TReportCell.SetLogFont(NewFont: TLOGFONT);
Begin
  FLogFont := NewFont;
  CalcMinCellHeight;
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
		// LCJ : ��С�߶���Ҫ�ܹ��������֣���������ֱ�ߵĿ�Ⱥ�2����Ŀռ������
	  //       ��ˣ���Ҫʵ�ʻ���������DC 0 �ϣ��������TempRect-������ռ�Ŀռ�
	  //       - FLeftMargin : Cell �����ֺͱ���֮�����µĿյĿ��
	  hTempFont := CreateFontIndirect(FLogFont);
	  If (Length(FCellText) <= 0) Then
		TempString := '��'
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
	  // lpRect [in, out] !  TempRect.Bottom ,TempRect.Right  �ᱻ�޸� �������ֲ���û���ᵽ��
	  DrawText(hTempDC, PChar(TempString), Length(TempString), TempRect, Format);
	  //  DrawText(hTempDC, PChar(TempString), -1, TempRect, Format);

		// �����������Ļس����������
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
  // ȡ�����µĵ�Ԫ��
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
// ��ʼج�Σ�ج�����Ұ���Ļ�ϵ����ص�һ��һ���ɵ�
// LCJ: �� Calc_MinCellHeight �ڣ������������� CalcMinCellHeight ��ʵ����ͬʱ�ڼ���
//  FMinCellHeight ��FRequiredCellHeight ���������� OwnerLine.CalcLineHeight
//  ���ܲ�˵�������е㽹�� ������
//  2014-11-6. ĳ�����������ˣ�˵���˵�Ͷ�ʡ�����ͷ���ˡ�
Procedure TReportCell.CalcMinCellHeight;
Var

  I: Integer;
  BottomCell, ThisCell: TReportCell;
  TotalHeight,Top: Integer;
  TempSize: TSize;
  TempRect: TRect;
Begin
  // Ҫ��Cell ̫խ��խ���޷������κ����֣��Ͳ�Ҫ������ȥ����߶��ˡ�
  // ֱ��Ĭ�� �ָ� 16 ���ɡ�
  // û�� RightMargin ,ԭ���߰�RightMargin ��LeftMargin��ͬ������������� FLeftMargin * 2
  If FCellWidth <= FLeftMargin * 2 Then
  Begin
    FMinCellHeight := DefaultHeight(self);
    Exit;
  End;
  // ������ĳCELLʱ
  If FOwnerCell <> Nil Then
  Begin
    BottomCell := GetBottomest(FOwnerCell);
    TotalHeight := GetTotalHeight(FOwnerCell) ;
    If (BottomCell = Self ) and (FOwnerCell.RequiredCellHeight > TotalHeight) Then
      FMinCellHeight := FOwnerCell.RequiredCellHeight - TotalHeight + OwnerLineHeight
    else
      FMinCellHeight := DefaultHeight(self) ;
    exit;
  End;
  GetTextRect(TempRect);

  If (FCellsList.Count > 0) Then
  Begin
    If TempRect.Bottom - TempRect.Top <= 0 Then
      FRequiredCellHeight := 16
    Else
      FRequiredCellHeight := TempRect.Bottom - TempRect.Top;

    FRequiredCellHeight := FRequiredCellHeight + 2  + FTopLineWidth +
      FBottomLineWidth;

    FMinCellHeight := DefaultHeight(self);
    OwnerLine.CalcLineHeight;
    For I := 0 To FCellsList.Count - 1 Do
      TReportCell(FCellsList[I]).CalcMinCellHeight;
  End
  Else
  Begin
    If TempRect.Bottom - TempRect.Top <= 0 Then
      FMinCellHeight := 16
    Else
      FMinCellHeight := TempRect.Bottom - TempRect.Top;
    FMinCellHeight := FMinCellHeight + 2 + FTopLineWidth + FBottomLineWidth;
  End;
End;

// Calc CellRect & TextRect here
// ���CELL�Ĵ�С�����ı���Ĵ�С�ı䣬�Զ����ô��ڵ�ʧЧ��
Procedure TReportCell.CalcCellTextRect;
  procedure CalcCellRect;
  Var
  TempRect: TRect;
  TotalHeight: Integer;
  I: Integer;
  begin
  	If FCellsList.Count <= 0 Then
	  Begin
		// ����CELL�ľ���   
		FCellRect.left := FCellLeft;
		FCellRect.top := CellTop;
		FCellRect.right := FCellRect.left + FCellWidth;
		FCellRect.bottom := FCellRect.top + OwnerLineHeight;
	  End
	  Else
	  Begin
		TotalHeight := OwnerLineHeight;

		For I := 0 To FCellsList.Count - 1 Do
		  TotalHeight := TotalHeight + TReportCell(FCellsList[I]).OwnerLineHeight;

		FCellRect.left := FCellLeft;
		FCellRect.top := CellTop;
		FCellRect.right := FCellRect.left + FCellWidth;
		FCellRect.bottom := FCellRect.top + TotalHeight;
	  End;
  end;
  procedure CalcTextRect;
  Var
  TempRect: TRect;
  TotalHeight: Integer;
  I: Integer;
  begin
  	If FCellsList.Count <= 0 Then
	  Begin
			// �����ı���ľ���
		TempRect := FCellRect;
		TempRect.left := TempRect.Left + FLeftMargin + 1;
		TempRect.top := TempRect.top + FTopLineWidth + 1;
		TempRect.right := TempRect.right - FLeftMargin - 1;
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
		FTextRect := TempRect;
	  End
	  Else
	  Begin
		// �����ı���ľ���
		TempRect := FCellRect;
		TempRect.left := TempRect.Left + FLeftMargin + 1;
		TempRect.top := TempRect.top + FTopLineWidth + 1;
		TempRect.right := TempRect.right - FLeftMargin;
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
		FTextRect := TempRect;
	  End;
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

  // б��
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
  FLogFont.lfFaceName := '����';

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
  If FOwnerLine = Nil Then
    Result := 0
  Else
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

  // б��
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
// һ������������һ��������õ�����

///////////////////////////////////////////////////////////////////////////
// CReportLine



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
  //CellWidth:=33; //��
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

  // �趨Ϊ�޹�꣬��ֹ�����˸��
  //  Cursor := crNone;
  Cpreviewedit := true;                 //Ԥ��ʱ�Ƿ�����༭��Ԫ���е��ַ�
  FPreviewStatus := False;

  Color := clWhite;
  FLineList := TList.Create;
  FSelectCells := TList.Create;

  Celldisp := Nil;
  cellline_d := Nil;
  FEditCell := Nil;

  FNewTable := True;
  //  FDataLine := 2147483647;
  //  FTablePerPage := 2147483647;
  FDataLine := 2000;                    //�β�־ 1999.1.16
  FTablePerPage := 1;                   //

  cp_pgw := 0;
  cp_pgh := 0;

  FReportScale := 100;
  scale := FReportScale;
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
  Inherited Destroy;
End;

Procedure TReportControl.SetPageSize(w, h: integer);  //add lzl ��̬��������ֽ�Ŵ�С
Var
  hClientDC: HDC;
Begin

End;

Procedure TReportControl.CalcWndSize;
Var
  hClientDC: HDC;
Begin
  isprint := 0;
  If printer.Printers.Count <= 0 Then
  Begin
    isprint := 1;                       //δ��װ��ӡ��
    If cp_pgw <> 0 Then
    Begin
      FPageWidth := cp_pgw;
      FPageHeight := cp_pgh;
    End;
  End;

  // �����û�ѡ���ֽ��ȷ�������ڵĴ�С���Ըô��ڽ������á�
  hClientDC := GetDC(0);
  If cp_pgw = 0 Then
  Begin
    If isprint = 1 Then
    Begin
      FPageWidth := 768;                //δ��װ��ӡ��ʱ������Ĭ��ֽ��
      FPageHeight := 1058;              //δ��װ��ӡ��ʱ������Ĭ��ֽ��
    End
    Else
    Begin
      FPageWidth := trunc(Printer.PageWidth / GetDeviceCaps(Printer.Handle,
        LOGPIXELSX)
        * GetDeviceCaps(hClientDC, LOGPIXELSX) + 0.5);
      FPageHeight := trunc(Printer.PageHeight / GetDeviceCaps(Printer.Handle,
        LOGPIXELSY)
        * GetDeviceCaps(hClientDC, LOGPIXELSY) + 0.5);
    End;
  End;
  cp_pgw := FPageWidth;                 //cp_pgw,cp_pgh���ڴ�ӡ
  cp_pgh := FPageHeight;
  Width := trunc(FPageWidth * FReportScale / 100 + 0.5); //width,heght������ʾ
  Height := trunc(FPageHeight * FReportScale / 100 + 0.5);
  ReleaseDC(0, hClientDC);

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

      // add lzl ��ͼ
      //  y:=ThisCell.CellTop+ ((ThisCell.OwnerLineHeight-thiscell.FBmp.Height) div 2);
      //  x:=ThisCell.CellLeft+((ThisCell.CellWidth- thiscell.FBmp.Width) div 2);
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
  If Not Cpreviewedit Then              //add lzl
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

  sh_down := message.wparam;            //���϶�ʱ������SHIFT��ʱ��ȡ����ѡ��Ԫ��
  If freportscale <> 100 Then //����Mouse������������<>100ʱ���ָ�Ϊ����
  Begin                                 //1999.1.23
    freportscale := 100;
    CalcWndSize;
    Update;
    exit;
  End;

  //  FcellFont_d:=thiscell.flogfont;

  If IsWindowVisible(FEditWnd) Then
  Begin
    If FEditCell <> Nil Then
    Begin
      GetWindowText(FEditWnd, TempChar, 3000);
      FEditCell.CellText := TempChar;
    End;
    // ��֣�ReportControl����һ���õ�������ƶ��Լ�
    Windows.SetFocus(0);
    DestroyWindow(FEditWnd);
    FEditCell := Nil;
  End;

  // �����Ϣ�����е�WM_PAINT��Ϣ����ֹ��������
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

  //���û��޷ѹ��ĸ�ʽ����Ԥ�� lzl 
  If (CellsWidth <> Nil) And (Not FCreportEdit) And (Not creportide) Then
    If cellswidth[0, 0] <> 0 Then
    Begin
      cellswidth[0, 0] := 0;
      PreviewForm.updatepage;
    End;
  //mouse_event( MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0 );
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); //add lzl 

  Inherited;                            //��mouse����Ϣ����   1999.1.23

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

  Inherited;                            //��mouse����Ϣ����   1999.1.23
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
    If ThisCell.FCellsList.Count <= 0 Then
    Begin
      // ����Խ����CELLʱ
      BottomCell := ThisCell;
    End
    Else
    Begin
      // ��Խ����CELLʱ��ȡ������һ�е�CELL
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

    BottomCell.CalcMinCellHeight;
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
      For J := 0 To TReportCell(ThisCellsList[I]).FCellsList.Count - 1 Do
      Begin
        ThisCellsList.Add(TReportCell(ThisCellsList[I]).FCellsList[J]);
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

  //lzl  ���� ���������û��϶���Ԫ���Ŀ���޸�ģ��
  If (cp_prewYn) And (PreviewForm.tag <> 0) And (Not FCreportedit) And (Not
    CreportIde) Then                    //��Ԥ���������ݼ�ʱ��ִ�д˹���
  Begin                                 //��Ԥ���е��ñ༭����,ide�е���Ҳ����
    GetCellsWadth(PreviewForm.tag);
    setfileCellWidth(PreviewForm.filename.Caption, PreviewForm.tag);
  End;
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
  // ���������ѡ�е�CELL
  If shift_down <> 5 Then
    ClearSelect;              //���϶�ʱ������SHIFT��ʱ��ȡ����ѡ��Ԫ��
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

  // ����û������û���Ƴ�������µ�CELL
  If Not bFlag Then
  Begin
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
  I, J, Count: Integer;
  OwnerCell: TReportCell;
  LineArray: TList;
  ThisCell, FirstCell: TReportCell;
  ThisLine: TReportLine;
  TempLeft, TempRight: Integer;
  CellsToDelete: TList;
  CellsToCombine: TList;
  TempRect: TMyRect;
Begin
  // �ж��Ƿ���Ժϲ������ѡ�е�CELL����С��2
  If FSelectCells.Count < 2 Then
    Exit;
  Count := FSelectCells.Count - 1;
  For I := 0 To Count Do
  Begin
    ThisCell := TReportCell(FSelectCells[I]);

    For J := 0 To ThisCell.FCellsList.Count - 1 Do
      FSelectCells.Add(ThisCell.FCellsList[J]);
  End;

  // LCJ : ��汻ѡ�еĵ�Ԫ�������
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
  // LCJ: ����еģ������ߣ��ұ߲����룬���޷��ϲ���
  TempLeft := 0;
  TempRight := 0;
  For I := 0 To LineArray.Count - 1 Do
  Begin
    If TMyRect(LineArray[I]).Left = 65535 Then
      Continue;

    If (TempLeft = 0) And (TempRight = 0) Then
    Begin
      TempLeft := TMyRect(LineArray[I]).Left;
      TempRight := TMyRect(LineArray[I]).Right;
    End
    Else
    Begin
      If (TempLeft <> TMyRect(LineArray[I]).Left) or (TempRight <> TMyRect(LineArray[I]).Right) Then
        Exit;
    End;
  End;

  // ��ͬһ���ϵĵ�Ԫ��ϲ�
  CellsToDelete := TList.Create;
  CellsToCombine := TList.Create;

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
          CellsToCombine.Add(ThisCell);
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

  CellsToDelete.Free;

  // �ϲ�ͬһ�еĵ�Ԫ�� -- ֻҪ�������е�Cell���뵽��һ����cell��OwneredCell����
  For I := 0 To CellsToCombine.Count - 1 Do
  Begin
    If I > 0 Then
    Begin
      TReportCell(CellsToCombine[0]).AddOwnedCell(TReportCell(CellsToCombine[I]));
    End;
    InvalidateRect(Handle, @TReportCell(FSelectCells[I]).CellRect, False);
  End;

  While LineArray.Count > 0 Do
  Begin
    TMyRect(LineArray[0]).Free;
    LineArray.Delete(0);
  End;

  LineArray.Free;

  OwnerCell := TReportCell(CellsToCombine[0]);
  ClearSelect;
  AddSelectedCell(OwnerCell);
  UpdateLines;
End;

Procedure TReportControl.DeleteLine;
Var
  I, J: Integer;
  LineArray: TList;
  ThisLineRect: TRect;
  ThisCell: TReportCell;
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
      ThisLineRect := TReportLine(FLineList[I]).LineRect;
      ThisLineRect.Right := ThisLineRect.Right + 1;
      ThisLineRect.Bottom := ThisLineRect.Bottom + 1;
      //      InvalidateRect(Handle, @ThisLineRect, True);
      InvalidateRect(Handle, @ThisLineRect, False);
      For J := 0 To TReportLine(FLineList[I]).FCells.Count - 1 Do
      Begin
        ThisCell := TReportCell(TReportLine(FLineList[I]).FCells[J]);
        If ThisCell.OwnerCell <> Nil Then
          ThisCell.OwnerCell.RemoveOwnedCell(ThisCell);

        If ThisCell.OwnedCellCount > 0 Then
          ThisCell.RemoveAllOwnedCell;
      End;
      TReportLine(FLineList[I]).Free;
      FLineList.Delete(I);
    End;
  End;

  LineArray.Free;

  UpdateLines;
End;

Procedure TReportControl.InsertLine;
Var
  TempLine: TReportLine;
Begin
  If Not CanInsert Then
    Exit;

  TempLine := TReportLine.Create;
  TempLine.ReportControl := Self;
  TempLine.LineTop := TReportCell(FSelectCells[0]).OwnerLine.LineTop;
  TempLine.CopyLine(TReportCell(FSelectCells[0]).OwnerLine, True);
  TempLine.Index := TReportCell(FSelectCells[0]).OwnerLine.Index;
  FLineList.Insert(TReportCell(FSelectCells[0]).OwnerLine.Index, TempLine);

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

  PaintRect := FirstLine.LineRect;
  PaintRect.Right := PaintRect.Right + 1;
  PaintRect.Bottom := PaintRect.Bottom + 1;
  //  InvalidateRect(Handle, @PaintRect, TRUE);
  InvalidateRect(Handle, @PaintRect, False);

  TReportLine(FLineList.First).Index := 0;

  For I := 1 To RowNumber - 1 Do
    //  for I := 1 to 30 do
  Begin
    AddLine;
    PaintRect := TReportLine(FLineList[I]).LineRect;
    PaintRect.Right := PaintRect.Right + 1;
    PaintRect.Bottom := PaintRect.Bottom + 1;
    //InvalidateRect(Handle, @PaintRect, TRUE);
    InvalidateRect(Handle, @PaintRect, False);
  End;

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
      //    InvalidateRect(Handle, @TReportCell(TempCell.FCellsList[I]).CellRect, True);
      InvalidateRect(Handle, @TReportCell(TempCell.FCellsList[I]).CellRect,
        False);

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
  // ���ȼ���ϲ���ĵ�Ԫ��
  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);

    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If ThisCell.FCellsList.Count > 0 Then
        ThisCell.CalcMinCellHeight;
    End;
  End;

  // ����ÿ�еĸ߶�
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
          //          InvalidateRect(Handle, @ThisCell.OwnerCell.CellRect, True);
          InvalidateRect(Handle, @ThisCell.OwnerCell.CellRect, False);
      End;
      PrevRect.Right := PrevRect.Right + 1;
      PrevRect.Bottom := PrevRect.Bottom + 1;
      TempRect.Right := TempRect.Right + 1;
      TempRect.Bottom := TempRect.Bottom + 1;
      //      InvalidateRect(Handle, @PrevRect, True);
      //      InvalidateRect(Handle, @TempRect, True);
      InvalidateRect(Handle, @PrevRect, False);
      InvalidateRect(Handle, @TempRect, False);
    End;
  End;

End;

Function TReportControl.AddSelectedCell(Cell: TReportCell): Boolean;
Var
  hClientDC: HDC;
Begin
  If IsCellSelected(Cell) Or (Cell = Nil) Then
    Result := False
  Else
  Begin

    FSelectCells.Add(Cell);
    celldisp := cell;
    FcellFont_d := cell.flogfont;       //ȡѡ�е�Ԫ����������� 1999.1.23
    cellline_d := cell;                 //���ڱ���ѡ�е�Ԫ������� 1999.1.25
    hClientDC := GetDC(Handle);
    InvertRect(hClientDC, Cell.CellRect);
    ReleaseDC(Handle, hClientDC);
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
  PrevCellRect: TRect;
  TempChar: Array[0..3000] Of Char;
Begin
  Case HIWORD(Message.wParam) Of
    EN_UPDATE:
      If FEditCell <> Nil Then
      Begin
        PrevCellRect := FEditCell.TextRect;
        GetWindowText(FEditWnd, TempChar, 3000);
        FEditCell.CellText := TempChar;

        UpdateLines;

        If (PrevCellRect.Left <> FEditCell.TextRect.Left) Or
          (PrevCellRect.Top <> FEditCell.TextRect.Top) Or
          (PrevCellRect.Right <> FEditCell.TextRect.Right) Or
          (PrevCellRect.Bottom <> FEditCell.TextRect.Bottom) Then
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
  // xx:=TReportCell(TReportLine(FLineList[1]).FCells[1]);
  // FSelectCells.Add(xx);

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
//lzla,�����޸�ģ���ļ�cell����


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

Procedure TReportControl.SaveToFile(FileName: String);
Var
  TargetFile: TFileStream;
  FileFlag: WORD;
  Count: Integer;
  I, J, K: Integer;
  ThisLine: TReportLine;
  ThisCell, TempCell: TReportCell;
  TempInteger: Integer;
  TempPChar: Array[0..3000] Of char;
Begin
  TargetFile := TFileStream.Create(FileName, fmOpenWrite Or fmCreate);
  Try
    // ���ڴ�С
    With TargetFile Do
    Begin

      FileFlag := $AA57;
      Write(FileFlag, SizeOf(FileFlag));

      FReportScale := 100;
      scale := FReportScale;            //1999.1.23

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

      // ������
      Count := FLineList.Count;
      Write(Count, SizeOf(Count));

      // ÿ���ж��ٸ�CELL
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        Count := ThisLine.FCells.Count;
        Write(Count, SizeOf(Count));
      End;

      // ÿ�е�����
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);

        Write(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Write(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Write(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Write(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Write(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // ÿ��CELL������
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

          Count := Length(ThisCell.FCellText);
          Write(Count, SizeOf(Count));
          StrPCopy(TempPChar, ThisCell.FCellText);
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

          // ����CELL���У�������
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
      prDeviceMode;                     //lzl 
      With Devmode^ Do
      Begin
        dmFields := dmFields Or DM_PAPERSIZE;
        FprPageNo := dmPapersize;

        dmFields := dmFields Or DM_ORIENTATION;
        FprPageXy := dmOrientation;

        Write(FprPageNo, SizeOf(FprPageNo));
        Write(FprPageXy, SizeOf(FprPageXy));

        fPaperLength := dmPaperLength;
        fPaperWidth := dmPaperWidth;

        Write(fPaperLength, SizeOf(fPaperLength));
        Write(fPaperWidth, SizeOf(fPaperWidth));
      End;
      Write(FHootNo, SizeOf(FHootNo));
    End;
  Finally
    TargetFile.Free;
  End;
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
  TargetFile := TFileStream.Create(FileName, fmOpenRead);
  Try
    With TargetFile Do
    Begin

      Read(FileFlag, SizeOf(FileFlag));
      If (FileFlag <> $AA55) And (FileFlag <> $AA56) And ((FileFlag <> $AA57))
        Then
      Begin
        ShowMessage('���ļ�����');
        Exit;
      End;

      ClearSelect;

      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        ThisLine.Free;
      End;

      FLineList.Clear;

      If IsWindowVisible(FEditWnd) Then
        DestroyWindow(FEditWnd);

      Read(FReportScale, SizeOf(FReportScale));
      FReportScale := 100;
      scale := 100;
      Read(FPageWidth, SizeOf(FPageWidth));
      Read(FPageHeight, SizeOf(FPageHeight));
      cp_pgw := FPageWidth;             //1999.1.23
      cp_pgh := FPageHeight;            //1999.1.23
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

      // ������
      Read(Count1, SizeOf(Count1));
      For I := 0 To Count1 - 1 Do
      Begin
        ThisLine := TReportLine.Create;
        ThisLine.FReportControl := Self;
        FLineList.Add(ThisLine);
        Read(Count2, SizeOf(Count2));
        ThisLine.CreateLine(0, Count2, FRightMargin - FLeftMargin);
      End;

      // ÿ�е�����
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);

        Read(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Read(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Read(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Read(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Read(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // ÿ��CELL������
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
          For K := 0 To Count1 - 1 Do
            Read(TempPChar[K], 1);

          TempPChar[Count1] := #0;
          ThisCell.FCellText := StrPas(TempPChar);

          If FileFlag <> $AA55 Then
          Begin
            Read(Count1, SizeOf(Count1));
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

      Read(FprPageNo, SizeOf(FprPageNo)); //ȡ��ֽ�����  lzl 2002��3
      Read(FprPageXy, SizeOf(FprPageXy)); //ȡ���ݺ᷽��  lzl 
      Read(fpaperLength, SizeOf(fpaperLength)); //ȡ������  lzl 
      Read(fpaperWidth, SizeOf(fpaperWidth)); //ȡ�����   lzl 
      prDeviceMode;
      With Devmode^ Do                  //���ô�ӡֽ  lzl 
      Begin
        dmFields := dmFields Or DM_PAPERSIZE;
        dmPapersize := FprPageNo;
        dmFields := dmFields Or DM_ORIENTATION;
        dmOrientation := FprPageXy;

        dmPaperLength := fpaperLength;
        dmPaperWidth := fpaperWidth;
      End;
      Read(FHootNo, SizeOf(FHootNo));
    End;
  Finally
    TargetFile.Free;
  End;
  UpdateLines;

  //  CalcWndSize;
  //  Invalidate;
End;

Procedure TReportControl.VSplitCell(Number: Integer);
Var
  ThisCell, TempCell, TempCell2: TReportCell;
  xx, I, J, CellWidth, MaxCellCount: Integer;
Begin
  If FSelectCells.Count <> 1 Then
    Exit;

  ThisCell := TReportCell(FSelectCells[0]);
  //  InvalidateRect(Handle, @ThisCell.CellRect, True);
  InvalidateRect(Handle, @ThisCell.CellRect, False);

  MaxCellCount := trunc((ThisCell.CellRect.Right - ThisCell.CellRect.Left) / 12
    + 0.5);

  If MaxCellCount > Number Then
    MaxCellCount := Number;

  xx := (ThisCell.CellRect.Right - ThisCell.CellRect.Left) Mod MaxCellCount;  //add lzl  ƽ�ֺ����Ŀ��

  CellWidth := trunc((ThisCell.CellRect.Right - ThisCell.CellRect.Left) /
    MaxCellCount);

  ThisCell.CellWidth := CellWidth;

  For I := 0 To MaxCellCount - 1 Do
  Begin

    If I = 0 Then
    Begin
      ThisCell.CellWidth := CellWidth;
      For J := 0 To ThisCell.FCellsList.Count - 1 Do
        TReportCell(ThisCell.FCellsList[J]).CellWidth := CellWidth;

      continue;
    End;

    TempCell := TReportCell.Create;
    TempCell.CopyCell(ThisCell, False);
    TempCell.OwnerLine := ThisCell.OwnerLine;

    If i = MaxCellCount - 1 Then        //add lzl  �����۷ֺ��ܶ��������
      TempCell.CellWidth := CellWidth + xx;

    If ThisCell.OwnerLine.FCells.IndexOf(ThisCell) =
      ThisCell.OwnerLine.FCells.Count - 1 Then
      TempCell.OwnerLine.FCells.Add(TempCell)
    Else
      TempCell.OwnerLine.FCells.Insert(ThisCell.OwnerLine.FCells.IndexOf(ThisCell) + 1, TempCell);

    For J := 0 To ThisCell.FCellsList.Count - 1 Do
    Begin
      TempCell2 := TReportCell.Create;
      TempCell2.CopyCell(TempCell, False);
      TempCell.AddOwnedCell(TempCell2);
      TempCell2.OwnerLine := TReportCell(ThisCell.FCellsList[J]).OwnerLine;

      If ThisCell.OwnerLine.FCells.IndexOf(ThisCell) =
        ThisCell.OwnerLine.FCells.Count - 1 Then
        TReportCell(ThisCell.FCellsList[J]).OwnerLine.FCells.Add(TempCell2)
      Else
        TReportCell(ThisCell.FCellsList[J]).OwnerLine.FCells.Insert(
          TReportCell(ThisCell.FCellsList[J]).OwnerLine.FCells.IndexOf(
          TReportCell(ThisCell.FCellsList[J])) + 1, TempCell2);
    End;

  End;

  UpdateLines;
End;

Procedure TReportControl.PrintIt;
Var
  hPrinterDC: HDC;
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  PageSize: TSize;
  Ltemprect: Trect;
Begin
  //  if Printer.Handle = INVALID_HANDLE_VALUE then
  //  begin
  //    Application.Messagebox('δ��װ��ӡ��', '����', MB_OK + MB_iconwarning);
  //    Exit;
  //  end;

  Printer.Title := 'C_Report';
  Printer.BeginDoc;

  hPrinterDC := Printer.Handle;

  SetMapMode(hPrinterDC, MM_ISOTROPIC);
  PageSize.cx := Printer.PageWidth;
  PageSize.cy := Printer.PageHeight;
  SetWindowExtEx(hPrinterDC, Width, Height, @PageSize);
  SetViewPortExtEx(hPrinterDC, Printer.PageWidth, Printer.PageHeight,
    @PageSize);

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
        //y:=CellTop+ ((OwnerLineHeight-fbmp.Height) div 2);
        //x:=CellLeft+((CellWidth- fbmp.Width) div 2);
        //printer.Canvas.Draw(x,y,fbmp);
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
  scale := value;
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

///////////////////////////////////////////////////////////////////////////
// SetFileCellWidth �����û��϶�������޸�ģ���ļ��е�Ԫ��Ŀ�� lzla

Procedure TReportControl.SetFileCellWidth(filename: String; HasDataNo: integer);  //lzl add
Var
  thisline: Treportline;
  thiscell: treportcell;
  i, j, k: integer;
Begin
  LoadFromFile(filename);
  If cellswidth[39, 0] = flinelist.Count - 1 Then
    k := flinelist.Count - 1
  Else
    k := NhasSumALl - 1;
  For i := 0 To k Do
  Begin
    thisline := treportline(flinelist[i]);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      ThisCell.CellWidth := cellswidth[i, j];
    End;
  End;
  savetoFile(filename);
  // ResetContent;
End;

// GetCellsWadth ���仯��ĵ�Ԫ���ȴ���ȫ�ֱ������� lzl 

Procedure TReportControl.GetCellsWadth(HasDataNo: integer);
Var
  thisline: Treportline;
  thiscell: treportcell;
  i, j, k: integer;
Begin
  SetLength(CellsWidth, 40, 40);        // row max 40
  For i := 0 To hasdatano Do
  Begin
    thisline := treportline(flinelist[i]);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      cellswidth[i, j] := ThisCell.CellWidth;
    End;                                //for j
  End;                                  //for i

  k := hasdatano + 1;

  For i := Fhootno To FLinelist.Count - 1 Do
  Begin
    thisline := treportline(flinelist[i]);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      cellswidth[k, j] := ThisCell.CellWidth;
    End;                                //for j
    k := k + 1;
  End;                                  //for i
  cellswidth[39, 0] := k - 1;

End;

Procedure TReportRunTime.updatepage;
Var
  i: integer;
Begin
  ReportFile := reportfile;             //����װ���޸ĺ��ģ���ļ�
  //i := PreparePrintk(FALSE, 0);
  i := PreparePrintk_PageCount;
  REPmessform.show;                     //lzla2001.4.27
  PreparePrintk(TRUE, i);
  REPmessform.Close;
  PreviewForm.PageCount := FPageCount;
  PreviewForm.StatusBar1.Panels[0].Text := '��' +
    IntToStr(PreviewForm.CurrentPage) + '��' + IntToStr(PreviewForm.PageCount) +
    'ҳ';

End;

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

Procedure TReportControl.setCreportEdit(Const value: boolean); // lzl add
Begin
  If value <> fcreportedit Then
    fcreportedit := value;
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

Procedure TReportControl.SetLineHegit(row, h: integer); // add lzl
Var
  ThisLine: Treportline;
Begin
  ThisLine := TReportLine(FlineList[row]);
  ThisLine.SetDragHeight(h);
End;

Procedure TReportControl.SetWndSize(w, h: integer); //add lzl
Begin
  FPageWidth := w;
  FPageHeight := h;
  cp_pgw := FPageWidth;                 //cp_pgw,cp_pgh���ڴ�ӡ
  cp_pgh := FPageHeight;
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

{ TReportRunTime }

Procedure TReportRunTime.DeleteAllTempFiles;
Var
  strFileDir: String;
Begin
  strFileDir := ExtractFileDir(Application.ExeName);
  If copy(strfiledir, length(strfiledir), 1) <> '\' Then
    strFileDir := strFileDir + '\';

  If Not DirectoryExists(strFileDir + 'Temp') Then
    Exit;
  DeleteFiles(strFileDir + 'Temp', '*.tmp');
  Try
    RmDir(strFileDir + 'Temp');
  Except
  End;
End;

Procedure TReportRunTime.SaveTempFile(PageNumber, Fpageall: Integer);
Var
  TargetFile: TFileStream;
  FileFlag: WORD;
  Count: Integer;
  I, J, K: Integer;
  ThisLine: TReportLine;
  ThisCell, TempCell: TReportCell;
  TempInteger: Integer;
  TempPChar: Array[0..3000] Of char;
  FileName: String;
  strFileDir: String;
  celltext: String;

Begin

  REPmessform.Label1.Caption := inttostr(PageNumber); //lzl  2001.4.27

  strFileDir := ExtractFileDir(Application.ExeName); // + '\';

  If copy(strfiledir, length(strfiledir), 1) <> '\' Then
    strFileDir := strFileDir + '\';

  If Not DirectoryExists(strFileDir + 'Temp') Then
    //MkDir('Temp');
    MkDir(strFileDir + 'Temp');         //re lzl

  FileName := strFileDir + 'Temp\' + IntToStr(PageNumber) + '.Tmp';

  If FileExists(FileName) Then
    DeleteFile(FileName);

  TargetFile := TFileStream.Create(FileName, fmOpenWrite Or fmCreate);
  application.ProcessMessages;


  Try
    // ���ڴ�С
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

      // ������
      Count := FPrintLineList.Count;
      Write(Count, SizeOf(Count));

      // ÿ���ж��ٸ�CELL
      For I := 0 To FPrintLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FPrintLineList[I]);
        Count := ThisLine.FCells.Count;
        Write(Count, SizeOf(Count));
      End;

      // ÿ�е�����
      For I := 0 To FPrintLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FPrintLineList[I]);

        Write(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Write(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Write(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Write(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Write(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // ÿ��CELL������
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

          If (UpperCase(ThisCell.FCellText) = '`PAGENUM') Then //lzl ��
            celltext := '�� ' + inttostr(PageNumber) + ' ҳ'
          Else If (UpperCase(ThisCell.FCellText) = '`PAGENUM/') Then //lzl ��
            celltext := '�� ' + inttostr(PageNumber) + '/' + inttostr(FPageAll) +
              ' ҳ'
          Else If (UpperCase(ThisCell.FCellText) = '`PAGENUM-') Then //lzl ��
            celltext := '�� ' + inttostr(Fpageall) + '-' + inttostr(PageNumber) +
              ' ҳ'
          Else If copy(UpperCase(ThisCell.FCellText), 1, 9) = '`SUMPAGE(' Then  //lzl ��
          Begin
            //celltext:=FormatFloat(thiscell.FCellDispformat,setSumpageYg(ThisCell.FCellText));
            celltext := trim(setSumpageYg(thiscell.FCellDispformat,
              ThisCell.FCellText));
          End
          Else
            If copy(UpperCase(ThisCell.FCellText), 1, 8) = '`SUMALL(' Then  //lzl ��
            Begin
              //celltext:=FormatFloat(thiscell.FCellDispformat,setSumAllYg(ThisCell.FCellText));
              celltext := setSumAllYg(thiscell.FCellDispformat,
                ThisCell.FCellText);
            End
            Else
              celltext := ThisCell.FCellText;

          //        Count := Length(ThisCell.FCellText);
          Count := Length(celltext);
          Write(Count, SizeOf(Count));
          //StrPCopy(TempPChar, ThisCell.FCellText);
          StrPCopy(TempPChar, celltext);

          For K := 0 To Count - 1 Do
            Write(TempPChar[K], 1);

          Count := Length('');
          Write(Count, SizeOf(Count));
          StrPCopy(TempPChar, '');

          For K := 0 To Count - 1 Do
            Write(TempPChar[K], 1);

          Write(thiscell.Fbmpyn, SizeOf(thiscell.FbmpYn)); //add lzl

          If thiscell.FbmpYn Then
            ThisCell.FBmp.SaveToStream(TargetFile);

          Write(ThisCell.FLogFont, SizeOf(ThisCell.FLogFont));

          // ����CELL���У�������
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
      prDeviceMode;                     //lzl 
      With Devmode^ Do                  //lzl 
      Begin
        dmFields := dmFields Or DM_PAPERSIZE;
        FprPageNo := dmPapersize;

        dmFields := dmFields Or DM_ORIENTATION;
        FprPageXy := dmOrientation;

        Write(FprPageNo, SizeOf(FprPageNo));
        Write(FprPageXy, SizeOf(FprPageXy));

        fPaperLength := dmPaperLength;
        fPaperWidth := dmPaperWidth;

        Write(fPaperLength, SizeOf(fPaperLength));
        Write(fPaperWidth, SizeOf(fPaperWidth));
      End;
      Write(FHootNo, SizeOf(FHootNo));

    End;
  Finally
    TargetFile.Free;
  End;
End;

Procedure TReportRunTime.LoadTempFile(strFileName: String);
Var
  TargetFile: TFileStream;
  FileFlag: WORD;
  Count1, Count2, Count3: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  I, J, K: Integer;
  TempPChar: Array[0..3000] Of Char;
Begin
  TargetFile := TFileStream.Create(strFileName, fmOpenRead);
  Try
    With TargetFile Do
    Begin
      Read(FileFlag, SizeOf(FileFlag));
      If (FileFlag <> $AA55) And (FileFlag <> $AA56) And (FileFlag <> $AA57)
        Then
      Begin
        ShowMessage('�ļ���ʽ����...');
        Exit;
      End;

      For I := 0 To FPrintLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FPrintLineList[I]);
        ThisLine.Free;
      End;

      FPrintLineList.Clear;

      Read(FReportScale, SizeOf(FReportScale));
      Read(FPageWidth, SizeOf(FPageWidth));
      Read(FPageHeight, SizeOf(FPageHeight));

      { �β�־�� 1999.1.17
            if FPageWidth > 768 then
              FPageWidth := 768;

            if FPageHeight > 1056 then
              FPageHeight := 1056;
      }

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

      // ������
      Read(Count1, SizeOf(Count1));
      For I := 0 To Count1 - 1 Do
      Begin
        ThisLine := TReportLine.Create;
        ThisLine.FReportControl := Nil;
        FPrintLineList.Add(ThisLine);
        Read(Count2, SizeOf(Count2));
        ThisLine.CreateLine(0, Count2, FRightMargin - FLeftMargin);
      End;

      // ÿ�е�����
      For I := 0 To FPrintLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FPrintLineList[I]);

        Read(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Read(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Read(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Read(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Read(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // ÿ��CELL������
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

          For K := 0 To Count1 - 1 Do
            Read(TempPChar[K], 1);

          TempPChar[Count1] := #0;
          ThisCell.FCellText := StrPas(TempPChar);

          If FileFlag <> $AA55 Then
          Begin
            Read(Count1, SizeOf(Count1));
            For K := 0 To Count1 - 1 Do
              Read(TempPChar[K], 1);
            TempPChar[Count1] := #0;
            //ThisCell.FCellDispformat := StrPas(TempPChar);
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

      Read(FprPageNo, SizeOf(FprPageNo)); //ȡ��ֽ�����  lzl 2002��3
      Read(FprPageXy, SizeOf(FprPageXy)); //ȡ���ݺ᷽��  lzl 
      Read(fpaperLength, SizeOf(fpaperLength)); //ȡ������  lzl 
      Read(fpaperWidth, SizeOf(fpaperWidth)); //ȡ�����   lzl 
      prDeviceMode;
      With Devmode^ Do                  //���ô�ӡֽ
      Begin
        dmFields := dmFields Or DM_PAPERSIZE;
        dmPapersize := FprPageNo;
        dmFields := dmFields Or DM_ORIENTATION;
        dmOrientation := FprPageXy;

        dmPaperLength := fpaperLength;
        dmPaperWidth := fpaperWidth;

      End;
      read(FHootNo, SizeOf(FHootNo));   //lzl 

    End;
  Finally
    TargetFile.Free;
  End;

  UpdatePrintLines;
End;

Constructor TReportRunTime.Create(AOwner: TComponent);
Begin
  Inherited create(AOwner);

  CreportIde := false;
  cp_prewYn := false; //Ĭ��Ϊ����Ԥ��״̬,����print��ʱʹ��  lzl 
  editept := false;
  enableedit := false;
  FAddspace := false;
  //cellswidth[0,0]:=0;
  FReportScale := 100;
  scale := 100;
  Width := 0;
  Height := 0;

  fallprint := true;                    //Ĭ��Ϊȫ����ӡ
  FSetData := Tstringlist.Create;
  Cp_DFdList := TList.Create;
  FVarList := TList.Create;
  FLineList := TList.Create;
  FPrintLineList := TList.Create;
  FOwnerCellList := TList.Create;

  repmessForm := TrepmessForm.Create(Self); //  lzl 

  FHeaderHeight := 0;

  If FFileName <> '' Then
    LoadRptFile;
End;

{�������}

Destructor TReportRunTime.Destroy;
Var
  I: Integer;
Begin
  For I := Cp_DFdList.Count - 1 Downto 0 Do
    TDataSetItem(Cp_DFdList[I]).Free;
  Cp_DFdList.clear;

  For I := FVarList.Count - 1 Downto 0 Do
    TVarTableItem(FVarList[I]).Free;
  FVarList.Free;

  For I := FLineList.Count - 1 Downto 0 Do
    TReportLine(FLineList[I]).Free;
  FLineList.Free;

  For I := FPrintLineList.Count - 1 Downto 0 Do
    TReportLine(FPrintLineList[I]).Free;
  FPrintLineList.Free;

  FOwnerCellList.Free;

  Inherited Destroy;
End;

{���ݼ���ֵ}

Function TReportRunTime.DatasetByName(strDatasetName: String): TDataset;
Var
  I: Integer;
Begin
  Result := Nil;

  For I := 0 To Cp_DFdList.Count - 1 Do
  Begin
    If TDatasetItem(Cp_DFdList[I]).strName = strDatasetName Then
    Begin
      Result := TDatasetItem(Cp_DFdList[I]).pDataset;
    End;
  End;
End;

Function TReportRunTime.GetDataset(strCellText: String): TDataset;
Begin
  Result := DatasetByName(GetDatasetName(strCellText));
End;

Function TReportRunTime.GetDatasetName(strCellText: String): String;
Var
  I: Integer;
Begin
  If Length(strCellText) <= 0 Then
  Begin
    Result := '';
    Exit;
  End;

  If (strCellText[1] <> '@') And (strCellText[1] <> '#') Then
  Begin
    Result := '';
    Exit;
  End;

  For I := 2 To Length(strCellText) Do
  Begin
    If (strCellText[I] = ' ') Or (strCellText[I] = #09) Then
      Continue;

    If strCellText[I] = '.' Then
      Break;

    Result := Result + strCellText[I];
  End;

  Result := UpperCase(Result);
End;

Function TReportRunTime.GetFieldName(strCellText: String): String;
Var
  I: Integer;
  bFlag: Boolean;
Begin
  Result := '';

  If Length(strCellText) <= 0 Then
    Exit;

  If (strCellText[1] <> '@') And (strCellText[1] <> '#') Then
    Exit;

  bFlag := False;
  For I := 2 To Length(strCellText) Do
  Begin
    If (strCellText[I] = ' ') Or (strCellText[I] = #09) Then
      Continue;

    If strCellText[I] = '.' Then
    Begin
      bFlag := True;
      Continue;
    End;

    If bFlag Then
      Result := Result + strCellText[I];
  End;
End;

Procedure TReportRunTime.LoadRptFile;
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
  //TargetFile := TFileStream.Create(FFileName, fmOpenRead);
  Try
    TargetFile := TFileStream.Create(FFileName, fmOpenRead);
    With TargetFile Do
    Begin
      Read(FileFlag, SizeOf(FileFlag));
      If (FileFlag <> $AA55) And (FileFlag <> $AA56) And (FileFlag <> $AA57)
        Then
      Begin
        ShowMessage('���ļ�����');
        Exit;
      End;

      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);
        ThisLine.Free;
      End;

      FLineList.Clear;

      // Read(FHootNo, SizeOf(FHootNo));

      Read(FReportScale, SizeOf(FReportScale));
      Read(FPageWidth, SizeOf(FPageWidth));
      Read(FPageHeight, SizeOf(FPageHeight));
      {
       �β�־ ��  1999.1.17
            if FPageWidth > 768 then
              FPageWidth := 768;

            if FPageHeight > 1056 then
              FPageHeight := 1056;
      }
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

      Read(FNewTable, SizeOf(FNewTable)); //��ҳ�󲻼ӱ�ͷ
      Read(FDataLine, SizeOf(FDataLine)); //ÿ�������������
      Read(FTablePerPage, SizeOf(FTablePerPage)); //ÿҳ��ӡ���ٸ���

      // ������
      Read(Count1, SizeOf(Count1));
      For I := 0 To Count1 - 1 Do
      Begin
        ThisLine := TReportLine.Create;
        ThisLine.FReportControl := Nil;
        FLineList.Add(ThisLine);
        Read(Count2, SizeOf(Count2));
        ThisLine.CreateLine(0, Count2, FRightMargin - FLeftMargin);
      End;

      // ÿ�е�����
      For I := 0 To FLineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FLineList[I]);

        Read(ThisLine.FIndex, SizeOf(ThisLine.FIndex));
        Read(ThisLine.FMinHeight, SizeOf(ThisLine.FMinHeight));
        Read(ThisLine.FDragHeight, SizeOf(ThisLine.FDragHeight));
        Read(ThisLine.FLineTop, SizeOf(ThisLine.FLineTop));
        Read(ThisLine.FLineRect, SizeOf(ThisLine.FLineRect));

        // ÿ��CELL������
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

          If (Count1 > 0) And (Count1 <= 3000) Then
            TempPChar[Count1] := #0;
          ThisCell.FCellText := StrPas(TempPChar);

          If FileFlag <> $AA55 Then
          Begin
            Read(Count1, SizeOf(Count1));

            tempPchar := #0;
            For K := 0 To Count1 - 1 Do
              Read(TempPChar[K], 1);

            If (Count1 > 0) And (Count1 <= 3000) Then
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

      Read(FprPageNo, SizeOf(FprPageNo)); //ȡ��ֽ�����  lzl 2002��3
      Read(FprPageXy, SizeOf(FprPageXy)); //ȡ���ݺ᷽��
      Read(fpaperLength, SizeOf(fpaperLength)); //ȡ���ݺ᷽��
      Read(fpaperWidth, SizeOf(fpaperWidth)); //ȡ���ݺ᷽��
      prDeviceMode;

      With Devmode^ Do                  //���ô�ӡֽ
      Begin
        dmFields := dmFields Or DM_PAPERSIZE;
        dmPapersize := FprPageNo;
        dmFields := dmFields Or DM_ORIENTATION;
        dmOrientation := FprPageXy;

        dmPaperLength := fpaperLength;
        dmPaperWidth := fpaperWidth;

      End;
      read(FHootNo, SizeOf(FHootNo));   //lzl 

    End;
  Finally
    TargetFile.Free;
  End;

  UpdateLines;

  FHeaderHeight := 0;

  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    bHasDataSet := False;
    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If Length(ThisCell.FCellText) > 0 Then  //�����ǰCELL���ַ����ж��Ƿ������ݼ�
      Begin
        If ThisCell.FCellText[1] = '#' Then
          bHasDataSet := True;
      End;
    End;
    If Not bHasDataSet Then
      FHeaderHeight := FHeaderHeight + ThisLine.LineHeight;  //���û�����ݼ������ͷ�߶ȵ��ڱ�ͷ�߶ȼӵ�ǰ�и߶�
  End;

End;
Procedure TReportRunTime.SetEmptyCell(NewCell, ThisCell:TReportCell);
Begin
  setNewCell(true,NewCell,ThisCell);
End;
Procedure TReportRunTime.SetNewCell(spyn: boolean; NewCell, ThisCell:
  TReportCell);
Var
  TempCellTable: TCellTable;
  L: integer;
  TempOwnerCell: TReportCell;
Begin

  With NewCell Do
  Begin
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
    FDragCellHeight := ThisCell.FDragCellHeight;
    FDragCellHeight := 0;
    FMinCellHeight := ThisCell.FMinCellHeight;
    FMinCellHeight := 0;
    // border
    FLeftLine := ThisCell.FLeftLine;
    FLeftLineWidth := ThisCell.FLeftLineWidth;
    FTopLine := ThisCell.FTopLine;
    FTopLineWidth := ThisCell.FTopLineWidth;
    FRightLine := ThisCell.FRightLine;
    FRightLineWidth := ThisCell.FRightLineWidth;
    FBottomLine := ThisCell.FBottomLine;
    FBottomLineWidth := ThisCell.FBottomLineWidth;
    // б��
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

    If Not spyn Then                    //spyn���������ݿ��ֶεĴ���
    Begin
      If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '@') Then
      Begin
        If
          GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)) Is tnumericField Then
        Begin
          If thiscell.CellDispformat <> '' Then
          Begin
            If Not
              GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)).isnull Then
              cellText := formatfloat(thiscell.FCellDispformat,
                GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)).value);
          End
          Else
            CellText :=
              GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)).displaytext;
        End
        Else
          If
          GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)) Is Tblobfield Then
          Begin
            If Not
              GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)).isnull Then
            Begin
              //if fbmp = nil then
              fbmp := TBitmap.create;
              FBmp.Assign(GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)));
              FbmpYn := true;
            End
            Else
              CellText := '';
          End
          Else

            CellText :=
              GetDataSet(ThisCell.CellText).fieldbyname(GetFieldName(ThisCell.CellText)).displaytext
      End
      Else If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#')
        Then
      Begin
        If TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)) Is
          tnumericField Then
        Begin
          If thiscell.CellDispformat <> '' Then
          Begin
            If Not
              TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).isnull
                Then
              cellText := formatfloat(thiscell.FCellDispformat,
                TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).value);
          End
          Else
            CellText :=
              TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).displaytext;
        End
        Else If TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)) Is
          Tblobfield Then
        Begin
          If Not TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).isnull
            Then
          Begin
            //if fbmp = nil then
            fbmp := TBitmap.create;
            FBmp.Assign(TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)));
            FbmpYn := true;
          End
          Else
            CellText := '';
        End
        Else

          CellText :=
            TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).displaytext

      End
      Else If (Length(ThisCell.CellText) > 0) Then
        If (UpperCase(copy(ThisCell.FCellText, 1, 8)) <> '`PAGENUM') And
          (UpperCase(copy(ThisCell.FCellText, 1, 4)) <> '`SUM') And
          (ThisCell.FCellText[1] = '`') Then
          CellText := GetVarValue(thiscell.FCellText)
        Else
          CellText := ThisCell.FCellText;
    End
    Else
      CellText := '';

    flogfont := thiscell.FLogFont;

    If ThisCell.OwnerCell <> Nil Then
    Begin
      // ��������CELL��Ϊ�����ж��Ƿ���ͬһҳ��������ͬһҳ���Լ����뵽CELL���ձ���ȥ
      TempOwnerCell := Nil;

      // ���ҵ�������CELL���Լ����뵽��CELL��ȥ
      For L := 0 To FOwnerCellList.Count - 1 Do
      Begin
        If ThisCell.OwnerCell = TCellTable(FOwnerCellList[L]).PrevCell Then
          TempOwnerCell := TReportCell(TCellTable(FOwnerCellList[L]).ThisCell);
      End;

      If TempOwnerCell = Nil Then
      Begin
        TempCellTable := TCellTable.Create;
        TempCellTable.PrevCell := ThisCell.OwnerCell;
        TempCellTable.ThisCell := NewCell;
        FOwnerCellList.Add(TempCellTable);
      End
      Else
        TempOwnerCell.AddOwnedCell(NewCell);
    End;

    If ThisCell.FCellsList.Count > 0 Then
    Begin
      // ���Լ����뵽���ձ���ȥ
      TempCellTable := TCellTable.Create;
      TempCellTable.PrevCell := ThisCell;
      TempCellTable.ThisCell := NewCell;
      FOwnerCellList.Add(TempCellTable);
    End;

    CalcMinCellHeight;
  End;
End;
//lzl ���� ,��ȫ��д�� PreparePrint,���������ÿ��в���һҳ ͳ�Ƶȹ���
//������������Ԥ����ȷ��������ͷ���ݿ�����ģ��ĵڼ���
  function TReportRunTime.IsLastPageFull:Boolean ;
  begin
    result := (FtopMargin + nHandHeight + nDataHeight + nSumAllHeight +
            FBottomMargin) > height;
  end;
  function TReportRunTime.isPageFull:boolean;
  begin
    result := (FtopMargin + nHandHeight + nDataHeight + nHootHeight + FBottomMargin >height);
  end;
  function TReportRunTime.HasEmptyRoomLastPage:Boolean;
  begin
    result := FtopMargin + nHandHeight +
        nDataHeight +
        nSumAllHeight + FBottomMargin < height;
  end;
  function TReportRunTime.CloneEmptyLine(thisLine:TReportLine):TReportLine;
  var j:integer; templine:treportline;
  Var
    HandLineList, datalinelist, HootLineList, sumAllList: TList;
    ThisCell, NewCell: TReportCell;
  begin
        templine := Treportline.Create;
        TempLine.FMinHeight := ThisLine.FMinHeight;
        TempLine.FDragHeight := ThisLine.FDragHeight;
        For j := 0 To ThisLine.FCells.Count - 1 Do
        Begin
          ThisCell := TreportCell(ThisLine.FCells[j]);
          NewCell := TReportCell.Create;
          TempLine.FCells.Add(NewCell);
          NewCell.FOwnerLine := TempLine;
          //setnewcell(true, newcell, thiscell, TempDataSet);
          SetEmptyCell(newcell, thiscell);
        End;

    result := templine;
  end;
function TReportRunTime.FillHeadList(var nHandHeight:integer):TList;
    var HandLineList:TList;        i,j:integer;
    Var
    ThisLine, TempLine: TReportLine;
    ThisCell, NewCell: TReportCell;
  begin
   HandLineList := TList.Create;
   For i := 0 To FlineList.Count - 1 Do
   Begin
    ThisLine := TReportLine(FlineList[i]);
    TempLine := TReportLine.Create;
    TempLine.FMinHeight := ThisLine.FMinHeight;
    TempLine.FDragHeight := ThisLine.FDragHeight;
    HandLineList.Add(TempLine);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      NewCell := TReportCell.Create;
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      //�ܵõ�FDragHeight(�����߶��϶��ĸ߶�)��ֵ Fminheight�����ָ�,����ȡ�����Ϊ�и�
      With NewCell Do
      Begin
        If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#')
          Then
        Begin
          HandLineList.Delete(HandLineList.count - 1);
          result :=   HandLineList;
          exit ;
        End;
        setnewcell(false, newcell, thiscell);
      End;                              //with  NewCell do
    End;                                //for j
    TempLine.CalcLineHeight;
    nHandHeight := nHandHeight + TempLine.GetLineHeight;
   End;
   result :=   HandLineList ;
  end;
function TReportRunTime.GetHasDataPosition(var HasDataNo,cellIndex:integer):Boolean;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  TempDataSet: TDataset;
  khbz: boolean;
   begin
      For i := 0 To FlineList.Count - 1 Do
      Begin
        ThisLine := TReportLine(FlineList[i]);
        For j := 0 To ThisLine.FCells.Count - 1 Do
        Begin
            ThisCell := TreportCell(ThisLine.FCells[j]);
            If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#') Then
            Begin
              //HasTable := true;
              HasDataNo := i;
              cellIndex := j ;
              exit;
            End;
        End;                                //for j
      End;
  end;
function TReportRunTime.FillFootList(var nHootHeight:integer ):TList;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  khbz: boolean;
  begin
    HootLineList := TList.Create;
    For i := HasDataNo + 1 To FlineList.Count - 1 Do
    Begin
      ThisLine := TReportLine(FlineList[i]);
      TempLine := TReportLine.Create;
      TempLine.FMinHeight := ThisLine.FMinHeight;
      TempLine.FDragHeight := ThisLine.FDragHeight;
      HootLineList.Add(TempLine);
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        If (Length(ThisCell.CellText) > 0) And
          (UpperCase(copy(ThisCell.FCellText, 1, 7)) = '`SUMALL') Then
        Begin
          HootLineList.Delete(HootLineList.count - 1);
          break;
        End;
        NewCell := TReportCell.Create;
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
        setnewcell(false, newcell, thiscell);
      End;
      If (UpperCase(copy(ThisCell.FCellText, 1, 7)) <> '`SUMALL') Then
      Begin
        TempLine.CalcLineHeight;
        nHootHeight := nHootHeight + TempLine.GetLineHeight;
      End;
    End;
    result := HootLineList;
  end;
  function TReportRunTime.GetNhassumall():Integer;
  var NhasSumALl : integer;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  TempDataSet: TDataset;
  khbz: boolean;
  begin
  //   Nsumall
    For i := HasDataNo + 1 To FlineList.Count - 1 Do
    Begin
      ThisLine := TReportLine(FlineList[i]);
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        If (Length(ThisCell.CellText) > 0) And
          (UpperCase(copy(ThisCell.FCellText, 1, 7)) = '`SUMALL') Then
        Begin
          If NhasSumALl = 0 Then
            NhasSumALl := i;
            result :=NhasSumALl;
          break;
        End;
      End;                              //for j
    End;
    result  :=  0 ;
  end;
  //���кϼƵ���(`SumAll)����һ���б���
  function TReportRunTime.FillSumList(var nSumAllHeight:integer ):TList;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  TempDataSet: TDataset;
  khbz: boolean;
  begin
    nSumAllHeight := 0;
    sumAllList := TList.Create;
    For i := HasDataNo + 1 To FlineList.Count - 1 Do
    Begin
      ThisLine := TReportLine(FlineList[i]);
      TempLine := TReportLine.Create;
      TempLine.FMinHeight := ThisLine.FMinHeight;
      TempLine.FDragHeight := ThisLine.FDragHeight;
      sumAllList.Add(TempLine);
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        NewCell := TReportCell.Create;
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
        setnewcell(false, newcell, thiscell);
      End;                              //for j
      TempLine.CalcLineHeight;
      nSumAllHeight := nSumAllHeight + TempLine.GetLineHeight;
    End;
    result :=  sumAllList;
  end ;
  procedure TReportRunTime.PaddingEmptyLine(hasdatano:integer; var dataLineList:TList;var ndataHeight:integer;var khbz :boolean);
  var
    thisline,templine : Treportline ;
  begin
        thisline := Treportline(FLineList[hasdatano]);
        templine := CloneEmptyLine(thisLine);
        While true Do
        Begin
          dataLineList.Add(templine);
          TempLine.CalcLineHeight;
          ndataHeight := ndataHeight + templine.GetLineHeight;
          If IsLastPageFull Then
          Begin
            dataLineList.Delete(dataLineList.Count - 1);
            khbz := true;
            break;
          End;
        End;
  end;
    procedure TReportRunTime.PaddingEmptyLine(hasdatano:integer; var ndataHeight:integer;var khbz :boolean);
  var
    thisline,templine : Treportline ;nPrevdataHeight :integer;
  begin
        thisline := Treportline(FLineList[hasdatano]);
        templine := CloneEmptyLine(thisLine);
        While true Do
        Begin
          TempLine.CalcLineHeight;
          nPrevdataHeight := ndataHeight ;
          ndataHeight := ndataHeight + templine.GetLineHeight;
          If IsLastPageFull Then
          Begin
            ndataHeight := nPrevdataHeight ;
            khbz := true;
            break;
          End;
        End;
  end;
  function TReportRunTime.SumCell(ThisCell:TReportCell;j:Integer):Boolean;
  Var
  I,  n, hasdatano, TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  NewCell: TReportCell;
  
  khbz: boolean;
  begin
        result := true ;
        Try
          If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#')
            Then
          Begin
            If TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)) Is
              tnumericField Then
              If Not
                (TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).IsNull)
                  Then
              Begin
                SumPage[j] := SumPage[j] +
                  TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).Value;
                SumAll[j] := SumAll[j] +
                  TempDataSet.fieldbyname(GetFieldName(ThisCell.CellText)).Value;
              End;
          End;
        Except
          raise Exception.create('ͳ��ʱ������������ģ�������Ƿ���ȷ');
          result := false ;
        End;
  end;
 
    function TReportRunTime.AppendList( l1, l2:TList):Boolean;var n :integer; begin
        For n := 0 To l2.Count - 1 Do
          l1.Add(l2[n]);
        result := true;
    end;
function TReportRunTime.ExpandLine(var HasDataNo,ndataHeight:integer):TReportLine;
var thisLine ,TempLine: TReportLine;
    Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;

  khbz: boolean;
    begin
      ThisLine := TReportLine(FlineList[HasDataNo]);
      TempLine := TReportLine.Create;
      TempLine.FMinHeight := ThisLine.FMinHeight;
      TempLine.FDragHeight := ThisLine.FDragHeight;
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        NewCell := TReportCell.Create;
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
        setnewcell(false, newcell, thiscell);
        //SumCell(ThisCell,j) ;
      End; //for j
      TempLine.CalcLineHeight;
      ndataHeight := ndataHeight + TempLine.GetLineHeight;
      result := TempLine;
    end;
function TReportRunTime.ExpandLine_Height(var HasDataNo,ndataHeight:integer):TReportLine;
var thisLine ,TempLine: TReportLine;
    Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;

  khbz: boolean;
    begin
      ThisLine := TReportLine(FlineList[HasDataNo]);
      TempLine := TReportLine.Create;
      TempLine.FMinHeight := ThisLine.FMinHeight;
      TempLine.FDragHeight := ThisLine.FDragHeight;
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        NewCell := TReportCell.Create;
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
      End; //for j
      TempLine.CalcLineHeight;
      ndataHeight := ndataHeight + TempLine.GetLineHeight;
      result := TempLine;
    end;
    procedure TReportRunTime.SumLine(var HasDataNo:integer);
    var j:integer;var thisLine ,TempLine: TReportLine;
    Var
  I,  n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;
  khbz: boolean;
    begin
      ThisLine := TReportLine(FlineList[HasDataNo]);
      For j := 0 To ThisLine.FCells.Count - 1 Do
      Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        SumCell(ThisCell,j) ;
      End; //for j
    end;
    procedure    TReportRunTime.JoinAllList(FPrintLineList, HandLineList,dataLineList,SumAllList,HootLineList:TList;IsLastPage:Boolean);

    begin
        AppendList(  FPrintLineList, HandLineList);
        AppendList(  FPrintLineList, dataLineList);
        If (IsLastPage) Then
          AppendList(  FPrintLineList, SumAllList)
        Else
          AppendList(  FPrintLineList, HootLineList);
    end;

Function TReportRunTime.PreparePrintk(SaveYn: boolean; FpageAll: integer):
  integer;
Var
  CellIndex,I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  
  khbz: boolean;
  //khbz - ���б�־ - �Ƿ�����������в�����Ϊҳ���������ɾ���С���������ţ��³���������˼ ����
  // ��Ϊһ����Ϣ������ѹ�����ӿ��б�ǵ�khbz���ף����������ѡ����ðٶ�ƴ������5ҳҲ�������ף����ˣ��ͻ������ţ�
Begin
  try
  For n := 0 To 40 Do //���40�е�Ԫ��,����ͳ�ƻ���ʱҪ����. �⻻Ϊ��̬��
  Begin
    SumPage[n] := 0;
    SumAll[n] := 0;
  End;
  NhasSumALl := 0;
  TempDataSet := Nil;
  FhootNo := 0;
  nHandHeight := 0;                     //��ҳ���ݿ���֮ǰÿ���ۼӸ߶�
  FpageCount := 1;                      //�������ҳ��
  HasDataNo := 0;
  nHootHeight := 0;
  TempDataSetCount := 0;
  khbz := false;

  //��ÿҳ�ı�ͷ����һ���б���
  HandLineList := FillHeadList(nHandHeight);
  GetHasDataPosition(HasDataNo,CellIndex) ;
  If HasDataNo = -1 Then
  Begin
    AppendList(  FPrintLineList, HandLineList);
    UpdatePrintLines;
    If saveyn Then
      SaveTempFile(fpagecount, FpageAll);       
  End else
  Begin
    TempDataSet := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
    TempDataSetCount := TempDataSet.RecordCount;
    TempDataSet.First;
    HootLineList := FillFootList(nHootHeight);
    NhasSumALl := GetNhasSumALl();//
    sumAllList := FillSumList(nSumAllHeight);
    //dataLineList := FillDataList(ndataHeight,khbz);

    ndataHeight := 0;
    dataLineList := TList.Create;
    i := 0;

    While (i <= TempDataSetCount) Or (Not tempdataset.eof) Do
    Begin
      If (Faddspace) And ((i = TempDataSetCount) And (HasEmptyRoomLastPage)) Then begin
        PaddingEmptyLine(hasdatano,dataLineList,ndataHeight,khbz );
      end;
      TempLine := ExpandLine(HasDataNo,ndataHeight);
      If isPageFull or (i = TempDataSetCount) Then
      Begin
        If dataLineList.Count = 0 Then
          raise Exception.create('���δ����ȫ����,�������Ԫ���Ȼ�ҳ�߾������');
        FhootNo := HandLineList.Count+dataLineList.Count ;
        JoinAllList(FPrintLineList, HandLineList,dataLineList,SumAllList,HootLineList,i = TempDataSetCount);
        UpdatePrintLines;
        If saveyn Then                  //
          SaveTempFile(fpagecount, FpageAll);
        For n := 0 To 40 Do
          SumPage[n] := 0;
        fpagecount := fpagecount + 1;
        FPrintLineList.Clear;
        datalinelist.clear;
        ndataHeight := 0;
        if (i = TempDataSetCount) then break;
      End else begin
        DataLineList.add(tempLine);
        SumLine(HasDataNo);
        TempDataSet.Next;
        i := i + 1;
      end;         
    End; // end while
    fpagecount := fpagecount - 1;       //��ҳ��
    HootLineList.Free;
    dataLineList.free;
  End ;


  //for N := FPrintLineList.Count - 1 downto 0 do
  //    TReportLine(FPrintLineList[N]).Free;
  FPrintLineList.Clear;

  For N := FOwnerCellList.Count - 1 Downto 0 Do
    TCellTable(FOwnerCellList[N]).Free;
  FOwnerCellList.Clear;

  HandLineList.free;
  If saveyn Then
    result := HasDataNo
  Else
    result := fpagecount;
  except
    on E:Exception do
         MessageDlg(e.Message,mtInformation,[mbOk], 0);
  end;
End;
function TReportRunTime.GetDataSetFromCell(HasDataNo,CellIndex:Integer):TDataset;
begin
  result := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
end;
Function TReportRunTime.PreparePrintk_PageCount():integer;
Var
  CellIndex,I, J, n,  TempDataSetCount:Integer;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  SaveYn: boolean;
  khbz: boolean;
Begin

  try
  TempDataSet := Nil;
  FhootNo := 0;
  nHandHeight := 0;                     //��ҳ���ݿ���֮ǰÿ���ۼӸ߶�
  FpageCount := 1;                      //�������ҳ��
  HasDataNo := 0;
  nHootHeight := 0;
  TempDataSetCount := 0;
  khbz := false;

  FillHeadList(nHandHeight);
  GetHasDataPosition(HasDataNo,CellIndex) ;
  If HasDataNo <> -1 Then
  Begin
    TempDataSet := GetDataSetFromCell(HasDataNo,CellIndex);
    TempDataSetCount := TempDataSet.RecordCount;
    TempDataSet.First;
    FillFootList(nHootHeight);
    FillSumList(nSumAllHeight);

    ndataHeight := 0;
    i := 0;
    While (i <= TempDataSetCount)  Do
    Begin
      If (Faddspace) And ((i = TempDataSetCount) And (HasEmptyRoomLastPage)) Then begin
        PaddingEmptyLine(hasdatano,ndataHeight,khbz );
      end;
      TempLine := ExpandLine_Height(HasDataNo,ndataHeight);
      If isPageFull or (i = TempDataSetCount) Then
      Begin
        If ndataHeight  = 0 Then
          raise Exception.create('���δ����ȫ����,�������Ԫ���Ȼ�ҳ�߾������');
        fpagecount := fpagecount + 1;

        ndataHeight := 0;
        if (i = TempDataSetCount) then break;
      End else begin
        TempDataSet.Next;
        i := i + 1;
      end;
    End; 
    fpagecount := fpagecount - 1;       //��ҳ��
  End ;
  result := fpagecount;
  except
    on E:Exception do
         MessageDlg(e.Message,mtInformation,[mbOk], 0);
  end;
End;



Procedure TReportRunTime.Print(pYn: boolean);
Var
  PrintDlg: TPrintDialog;
  I: Integer;
  strFileDir: TFileName;
  frompage, topage: integer;
Begin
  Try

    If printer.Printers.Count <= 0 Then
    Begin
      isprint := 1;                     //δ��װ��ӡ��
      Application.Messagebox('δ��װ��ӡ��', '����', MB_OK + MB_iconwarning);
      If cp_prewYn <> true Then
      Begin
        For I := Cp_DFdList.Count - 1 Downto 0 Do
          TDataSetItem(Cp_DFdList[I]).Free;
        Cp_DFdList.clear;
      End;
      Exit;
    End;

    strFileDir := ExtractFileDir(Application.ExeName); //+ '\';
    If copy(strfiledir, length(strfiledir), 1) <> '\' Then
      strFileDir := strFileDir + '\';

    If cp_prewYn <> true Then
    Begin
      REPmessform.show;                 //lzla2001.4.27
      //i := PreparePrintk(FALSE, 0);
      i := PreparePrintk_PageCount;
      PreparePrintk(TRUE, i);
    End;
    REPmessform.Close;
    Begin
      PrintDlg := TPrintDialog.Create(Self);
      PrintDlg.MinPage := 1;
      PrintDlg.MaxPage := FPageCount;
      PrintDlg.FromPage := 1;
      PrintDlg.ToPage := FPageCount;
      PrintDlg.Options := [poPageNums];

      If pyn <> true Then
        If Not PrintDlg.Execute Then
        Begin
          PrintDlg.Free;
          If cp_prewYn <> true Then //������Ԥ��״̬�Ĵ�ӡ������ɾ�������ɵĴ�ӡҳ�ļ� lzl 
          Begin
            DeleteAllTempFiles;         //99.3.9
            For I := Cp_DFdList.Count - 1 Downto 0 Do
              TDataSetItem(Cp_DFdList[I]).Free;
            Cp_DFdList.clear;
          End;
          Exit;
        End;
      frompage := printdlg.frompage;    //99.3.9
      topage := printdlg.topage;        //99.3.9

      Printer.Title := 'C_Report';
      Printer.BeginDoc;

      For I := FromPage To ToPage Do
      Begin
        If FileExists(strFileDir + 'Temp\' + IntToStr(I) + '.tmp') Then
          LoadTempFile(strFileDir + 'Temp\' + IntToStr(I) + '.tmp');
        PrintOnePage;

        If I < ToPage Then
          Printer.NewPage;
      End;
      Printer.EndDoc;
      PrintDlg.Free;
    End;
    If cp_prewYn <> true Then // ���Ǵ���Ԥ��״̬�Ĵ�ӡ������ɾ�������ɵĴ�ӡҳ lzl 
    Begin
      DeleteAllTempFiles;               //  99.3.9
      For I := Cp_DFdList.Count - 1 Downto 0 Do  //ɾ�����ݿ������ģ��CELL�Ķ����б�,����ÿ�ε��ö�Ҫ�����б���
        TDataSetItem(Cp_DFdList[I]).Free;
      Cp_DFdList.clear;
    End;
  Except
    MessageDlg('�γɱ���ʱ��������������������ģ�����õ��Ƿ���ȷ',
      mtInformation, [mbOk], 0);
    REPmessform.Close;
    For I := Cp_DFdList.Count - 1 Downto 0 Do
      TDataSetItem(Cp_DFdList[I]).Free;
    Cp_DFdList.clear;
    exit;
  End;

End;

Procedure TReportRunTime.PrintOnePage;
Var
  hPrinterDC: HDC;
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  PageSize: TSize;
  Ltemprect: tRect;
Begin
  If FPrintLineList.Count <= 0 Then
    Exit;

  hPrinterDC := Printer.Handle;
  SetMapMode(Printer.Handle, MM_ISOTROPIC);
  PageSize.cx := Printer.PageWidth;
  PageSize.cy := Printer.PageHeight;
  SetWindowExtEx(Printer.Handle, Width, Height, @PageSize);
  SetViewPortExtEx(Printer.Handle, Printer.PageWidth, Printer.PageHeight,
    @PageSize);

  For I := 0 To FPrintLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);

    For J := 0 To ThisLine.FCells.Count - 1 Do
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
        //y:=CellTop+ ((OwnerLineHeight-fbmp.Height) div 2);
        //x:=CellLeft+((CellWidth- fbmp.Width) div 2);
        //printer.Canvas.Draw(x,y,fbmp);

        ThisCell.PaintCell(hPrinterDC, True);
      End;
    End;
  End;
  // clear the temp data here
  For I := FPrintLineList.Count - 1 Downto 0 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);
    ThisLine.Free;
  End;

  FPrintLineList.Clear;

  For I := FOwnerCellList.Count - 1 Downto 0 Do
    TCellTable(FOwnerCellList[I]).Free;

  FOwnerCellList.Clear;
End;

Function TReportRunTime.PrintSET(prfile: String): boolean;  //lzl ���� ��ֱ�ӻ���Ԥ���е������ô�ӡ����
Begin
  Application.CreateForm(TMarginForm, MarginForm);
  MarginForm.filename.Caption := prfile;

  Try
    MarginForm.ShowModal;
    If MarginForm.okset = true Then
    Begin
      result := true;
    End
    Else
      result := false;
  Finally
    MarginForm.free;
  End;
End;

Procedure TReportRunTime.PrintPreview(bPreviewMode: Boolean);
Var
  i, HasDataNo: integer;
Begin

  Try


    If printer.Printers.Count <= 0 Then
    Begin
      isprint := 1;                     //δ��װ��ӡ��
      DeleteAllTempFiles;
      Application.Messagebox('δ��װ��ӡ��', '����', MB_OK + MB_iconwarning);
      For I := Cp_DFdList.Count - 1 Downto 0 Do // add lzl
        TDataSetItem(Cp_DFdList[I]).Free;
      Cp_DFdList.clear;
      Exit;
    End
    Else
    Begin
      //i := PreparePrintk(FALSE, 0);
      i := PreparePrintk_PageCount;
      REPmessform.show;
      HasDataNo := PreparePrintk(TRUE, i);
      REPmessform.Close;
      PreviewForm := TPreviewForm.Create(Self);
      // add wang han song
      PreviewForm.reportcontrol1.enabled := Fenableedit;
      preview.EnableBz := fenableedit;
      preview.EditeptBz := feditept;

      // add end
      PreviewForm.SetPreviewMode(bPreviewMode);
      PreviewForm.PageCount := FPageCount;

      cp_prewYn := true;                //������Ԥ��״̬,���ô�ӡʱ�Ա�����
      PreviewForm.StatusBar1.Panels[0].Text := '��' +
        IntToStr(PreviewForm.CurrentPage) + '��' +
          IntToStr(PreviewForm.PageCount)
        + 'ҳ';

      PreviewForm.filename.Caption := ReportFile;
      PreviewForm.tag := HasDataNo;
      PreviewForm.ShowModal;
      cp_prewYn := false;
      PreviewForm.Free;
      DeleteAllTempFiles;
    End;
    //  for i:=0 to setdata.Count -1 do  // add lzl
    //      setpar(fase,setdata[i]); //��������
      //finally
  Except
    MessageDlg('�γɱ���ʱ��������������������ģ�����õ��Ƿ���ȷ',
      mtInformation, [mbOk], 0);
    REPmessform.Close;
    For I := Cp_DFdList.Count - 1 Downto 0 Do  //ɾ�����ݿ������ģ��CELL�Ķ����б�,����ÿ�ε��ö�Ҫ�����б���
      TDataSetItem(Cp_DFdList[I]).Free;
    Cp_DFdList.clear;
    exit;
  End;
  For I := Cp_DFdList.Count - 1 Downto 0 Do  //ɾ�����ݿ������ģ��CELL�Ķ����б�,����ÿ�ε��ö�Ҫ�����б���
    TDataSetItem(Cp_DFdList[I]).Free;
  Cp_DFdList.clear;
End;

Function TReportRunTime.shpreview: boolean; //��Ԥ��������ֽ�ż��߾࣬lzl ����
Var
  i: integer;
Begin
  If PrintSET(reportfile) = true Then   //ֽ���߾�����
  Begin
    ReportFile := reportfile; //����װ���޸ĺ��ģ���ļ�,����Ҫ���Ա����PreparePrintk
    i := PreparePrintk(FALSE, 0);
    i := PreparePrintk_PageCount;
    REPmessform.show;                   //lzla2001.4.27
    PreparePrintk(TRUE, i);
    REPmessform.Close;
    PreviewForm.PageCount := FPageCount;
    PreviewForm.StatusBar1.Panels[0].Text := '��' +
      IntToStr(PreviewForm.CurrentPage) + '��' + IntToStr(PreviewForm.PageCount)
        +
      'ҳ';
    result := true;
  End
  Else
    result := false;
End;

Procedure TReportRunTime.SetDataset(strDatasetName: String; pDataSet: TDataSet);
Var
  TempItem: TDatasetItem;
  dk, i: integer;
Begin
  TempItem := TDatasetItem.Create;
  TempItem.pDataset := pDataSet;
  TempItem.strName := UpperCase(strDataSetName);
  Cp_DFdList.Add(TempItem); //ע:���TReportRunTime���𣬶��ֲ��ϵ���SetDataset
  //�б����ظ�����,���,���󽫻����..Ŀǰ����Ԥ���ʹ�ӡ�����ա�������
End;                                    //���޸��ð취?������. lzl .

Procedure TReportRunTime.SetRptFileName(Const Value: TFilename);
Begin
  FFileName := Value;
  If Value <> '' Then
    LoadRptFile;
End;

 procedure TReportRunTime.EachCell(EachProc:EachCellProc);
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
  procedure TReportRunTime.EachLine(EachProc:EachLineProc);
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
  procedure TReportRunTime.EachLineIndex(EachProc:EachLineIndexProc);
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
  procedure TReportRunTime.EachCell_CalcMinCellHeight(ThisCell:TReportCell);
  begin
    If ThisCell.FCellsList.Count > 0 Then
      thisCell.CalcMinCellHeight ;
  end;
  procedure TReportRunTime.EachProc_CalcLineHeight(thisLine:TReportLine);
  begin
      thisLine.CalcLineHeight ;
  end;
  procedure TReportRunTime.EachLineIndexProc_UpdateIndex(thisLine:TReportLine;Index:integer);
  begin
      thisLine.CalcLineHeight ;
  end;

  //
  procedure TReportRunTime.EachProc_UpdateIndex(thisLine:TReportLine;I:integer);
  begin
      ThisLine.Index := I;
  end;
  procedure TReportRunTime.EachProc_UpdateLineTop(thisLine:TReportLine;I:integer);
  begin
     If I = 0 Then
      ThisLine.LineTop := FTopMargin
     else
      ThisLine.LineTop := TReportLine(FLineList[I - 1]).LineTop +
                                TReportLine(FLineList[I - 1]).LineHeight;
  end;
  procedure TReportRunTime.EachProc_UpdateLineRect(thisLine:TReportLine;Index:integer);
  begin
       ThisLine.LineRect;
  end;
Procedure TReportRunTime.UpdateLines;
Begin
  EachCell(EachCell_CalcMinCellHeight);
  EachLine(EachProc_CalcLineHeight);
  EachLineIndex(EachProc_UpdateIndex);
  EachLineIndex(EachProc_UpdateLineTop);
  EachLineIndex(EachProc_UpdateLineRect);
End;

Procedure TReportRunTime.UpdatePrintLines;
Var
  PrevRect, TempRect: TRect;
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
Begin
  // ���ȼ���ϲ���ĵ�Ԫ��
  For I := 0 To FPrintLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);

    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If ThisCell.FCellsList.Count > 0 Then
        ThisCell.CalcMinCellHeight;
    End;
  End;

  // ����ÿ�еĸ߶�
  For I := 0 To FPrintLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);
    ThisLine.CalcLineHeight;
  End;

  For I := 0 To FPrintLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);

    ThisLine.Index := I;

    If I = 0 Then
      ThisLine.LineTop := FTopMargin;
    If I > 0 Then
      ThisLine.LineTop := TReportLine(FPrintLineList[I - 1]).LineTop +
        TReportLine(FPrintLineList[I - 1]).LineHeight;

    PrevRect := ThisLine.PrevLineRect;
    TempRect := ThisLine.LineRect;
  End;
End;


Procedure treportruntime.resetself;
Begin
  //   add by wang han song 1999.03.05
  Cp_DFdList.clear;
  fvarlist.clear;
  flinelist.clear;
  fprintlinelist.clear;
  fownercelllist.clear;
End;

Function TReportRunTime.GetVarValue(strVarName: String): String;
Var
  I: Integer;
  ThisItem: TVarTableItem;
  TempString: String;
Begin
  Result := '';

  If Length(strVarName) <= 0 Then
    Exit;

  If strVarName[1] <> '`' Then
    Exit;

  //  if strVarName = '`PAGENUM' then
// If UpperCase(strVarName) = '`PAGENUM' Then
//    Result := '��' + IntToStr(FPageCount) + 'ҳ';

  shortdateformat := 'yyy-mm-dd';
  shorttimeformat := 'HH:MM:SS';
  If UpperCase(strVarName) = '`DATE' Then //����
    Result := datetostr(date);

  If UpperCase(strVarName) = '`TIME' Then //ʱ��
    Result := timetostr(time);

  If UpperCase(strVarName) = '`DATETIME' Then //����ʱ��
    Result := datetimetostr(now);

  For I := 2 To Length(strVarName) Do
  Begin
    If (strVarName[I] <= 'z') Or (strVarName[I] >= 'A') Then
      TempString := TempString + strVarName[I];
  End;

  TempString := UpperCase(TempString);

  For I := 0 To FVarList.Count - 1 Do
  Begin
    ThisItem := TVarTableItem(FVarList[I]);
    If ThisItem.strVarName = TempString Then
    Begin
      Result := ThisItem.strVarValue;
      Exit;
    End;
  End;
End;

Procedure TReportRunTime.SetVarValue(strVarName, strVarValue: String);
Var
  I: Integer;
  TempString: String;
  bFind: Boolean;
  TempItem, ThisItem: TVarTableItem;
Begin
  If Length(strVarName) <= 0 Then
    Exit;
  //TempString:='';
  For I := 1 To Length(strVarName) Do
  Begin
    If (strVarName[I] <= 'z') Or (strVarName[I] >= 'A') Then
      TempString := TempString + strVarName[I];
  End;

  TempString := UpperCase(TempString);
  bFind := False;

  For I := 0 To FVarList.Count - 1 Do
  Begin
    ThisItem := TVarTableItem(FVarList[I]);
    If ThisItem.strVarName = TempString Then
    Begin
      bFind := True;
      ThisItem.strVarValue := strVarValue;
    End;
  End;

  If Not bFind Then
  Begin
    TempItem := TVarTableItem.Create;
    TempItem.strVarName := TempString;
    TempItem.strVarValue := strVarValue;
    FVarList.Add(TempItem);
  End;
End;

Procedure TReportRunTime.ResetContent;
Begin
  //
End;

//�������ӡ�ı����ļ�

Procedure TReportRunTime.loadfile(value: tfilename);
Begin
  FFileName := Value;
  If Value <> '' Then
    LoadRptFile;
End;

Function treportruntime.cancelprint: boolean;
Begin
  Try
    If printer.printing Then
      printer.abort;
    result := true;
  Except
    result := false;
  End;
End;

Procedure TReportRuntime.SetEnableEdit(value: boolean);
Begin
  If value <> FEnableEdit Then
    FEnableEdit := value;
End;


Function TReportRunTime.SetSumAllYg(fm, ss: String): String; //add lzl
Var
  i, j, k, L: integer;
  ss1, ss2, ss3, gjfh: String;
  yg: real;
Begin
  Try
    i := pos(')', ss);
    If i = 0 Then
    Begin
      MessageDlg('ͳ��ʱ������������`SumAll()�����Ƿ���ȷ', mtInformation,
        [mbOk], 0);
      Result := '';
      exit;
    End;
    ss1 := copy(ss, 9, i - 9);
    j := length(ss1);
    ss2 := '';
    ss3 := '';
    yg := 0;
    For k := 1 To j Do
    Begin
      ss2 := copy(ss1, k, 1);
      If (ss2 <> '-') And (ss2 <> '+') Then
        ss3 := ss3 + ss2
      Else If (ss2 = '-') Or (ss2 = '+') Then
      Begin
        L := k;
        break;
      End;
    End;
    gjfh := ss2;
    If strtoint(ss3) = 0 Then
      MessageDlg('ģ���ļ���`SumAll()�����ڲ�����ӦΪ��', mtInformation, [mbOk],
        0);

    yg := SumALL[strtoint(ss3) - 1];
    If k > j Then
    Begin
      If yg <> 0 Then
        Result := FormatFloat(fm, yg)
      Else
        Result := '';
      exit;
    End;

    ss3 := '';
    ss1 := copy(ss1, L + 1, j - L);
    j := length(ss1);

    For k := 1 To j Do
    Begin
      ss2 := copy(ss1, k, 1);
      If (ss2 <> '-') And (ss2 <> '+') Then
        ss3 := ss3 + ss2
      Else
      Begin
        If (ss2 = '-') Or (ss2 = '+') Then
        Begin
          If strtoint(ss3) = 0 Then
            MessageDlg('ģ���ļ���`SumAll()�����ڲ�����ӦΪ��', mtInformation,
              [mbOk], 0);
          If gjfh = '-' Then
            yg := yg - SumALL[strtoint(ss3) - 1];
          If gjfh = '+' Then
            yg := yg + SumALL[strtoint(ss3) - 1];
          gjfh := ss2;
          ss3 := '';
        End;
      End;
    End;                                // for k:=1 to j do
    If strtoint(ss3) = 0 Then
      MessageDlg('ģ���ļ���`SumAll()�����ڲ�����ӦΪ��', mtInformation, [mbOk],
        0);
    If gjfh = '-' Then
      yg := yg - SumALL[strtoint(ss3) - 1];
    If gjfh = '+' Then
      yg := yg + SumALL[strtoint(ss3) - 1];

  Except
    MessageDlg('ͳ��ʱ������������`SumAll()�����Ƿ���ȷ', mtInformation,
      [mbOk], 0);
    yg := 0;
  End;
  If yg <> 0 Then
    Result := FormatFloat(fm, yg)
  Else
    Result := '';

End;




Function TReportRunTime.LFindComponent(Owner: TComponent; Name: String):
  TComponent;                           // add lzl
Var
  n: Integer;
  s1, s2: String;
Begin
  Result := Nil;
  n := Pos('.', Name);
  Try
    If n = 0 Then
      Result := Owner.FindComponent(Name)
    Else
    Begin
      s1 := Copy(Name, 1, n - 1);       // module name
      s2 := Copy(Name, n + 1, 255);     // component name
      Owner := FindGlobalComponent(s1);
      If Owner <> Nil Then
        Result := Owner.FindComponent(s2);
    End;
  Except
  End;
End;

Procedure TReportRunTime.SetEditept(Value: Boolean); // add lzl
Begin
  If value <> FEditEpt Then
    FEditEpt := value;
End;

Function TReportRunTime.setSumpageYg(fm, ss: String): String; // add lzl
Var
  i, j, k, L: integer;
  ss1, ss2, ss3, gjfh: String;
  yg: real;
Begin
  Try
    i := pos(')', ss);
    If i = 0 Then
    Begin
      MessageDlg('ͳ��ʱ������������`Sumpage()�����Ƿ���ȷ', mtInformation,
        [mbOk], 0);
      Result := '';
      exit;
    End;
    ss1 := copy(ss, 10, i - 10);
    j := length(ss1);
    ss2 := '';
    ss3 := '';
    yg := 0;
    For k := 1 To j Do
    Begin
      ss2 := copy(ss1, k, 1);
      If (ss2 <> '-') And (ss2 <> '+') Then
        ss3 := ss3 + ss2
      Else If (ss2 = '-') Or (ss2 = '+') Then
      Begin
        L := k;
        break;
      End;
    End;
    gjfh := ss2;
    If strtoint(ss3) = 0 Then
      MessageDlg('ģ���ļ���`Sumpage()�����ڲ�����ӦΪ��', mtInformation,
        [mbOk], 0);

    yg := Sumpage[strtoint(ss3) - 1];
    If k > j Then
    Begin
      If yg <> 0 Then
        Result := FormatFloat(fm, yg)
      Else
        Result := '';
      exit;
    End;

    ss3 := '';
    ss1 := copy(ss1, L + 1, j - L);
    j := length(ss1);

    For k := 1 To j Do
    Begin
      ss2 := copy(ss1, k, 1);
      If (ss2 <> '-') And (ss2 <> '+') Then
        ss3 := ss3 + ss2
      Else
      Begin
        If (ss2 = '-') Or (ss2 = '+') Then
        Begin
          If strtoint(ss3) = 0 Then
            MessageDlg('ģ���ļ���`Sumpage()�����ڲ�����ӦΪ��', mtInformation,
              [mbOk], 0);
          If gjfh = '-' Then
            yg := yg - Sumpage[strtoint(ss3) - 1];
          If gjfh = '+' Then
            yg := yg + Sumpage[strtoint(ss3) - 1];
          gjfh := ss2;
          ss3 := '';
        End;
      End;
    End;                                // for k:=1 to j do
    If strtoint(ss3) = 0 Then
      MessageDlg('ģ���ļ���`Sumpage()�����ڲ�����ӦΪ��', mtInformation,
        [mbOk], 0);
    If gjfh = '-' Then
      yg := yg - Sumpage[strtoint(ss3) - 1];
    If gjfh = '+' Then
      yg := yg + Sumpage[strtoint(ss3) - 1];

  Except
    MessageDlg('ͳ��ʱ������������`Sumpage()�����Ƿ���ȷ', mtInformation,
      [mbOk], 0);
    yg := 0;
  End;
  If yg <> 0 Then
    Result := FormatFloat(fm, yg)
  Else
    Result := '';
End;

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


Procedure TReportRunTime.SetAddSpace(Const Value: boolean);
Begin
  FAddSpace := Value;
End;

Procedure TReportRunTime.Setdbgrid(Const Value: Tdbgrid);
Begin
  fdbgrid := Value;
End;

End.

