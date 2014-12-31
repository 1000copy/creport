unit ReportRunTime;

interface
uses ReportControl,  Windows, Messages, SysUtils,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice,margin,cc;
Procedure Register;


type
   TSummer = class
     SumPage, SumAll: Array[0..40] Of real;
   public
     procedure Acc(j:integer;value:real);
     procedure ResetSumPage;
     procedure ResetAll;
     function GetSumAll(i:integer):Real;
     function GetSumPage(i:integer):Real;
   end;
type
  TDataList = class(TList)
  public
   procedure FreeItems;
  end;
  RenderException =class(Exception)
  public
    constructor Create;
  end;
  TReportRunTime = Class(TReportControl)
  private
    FSummer:TSummer;
    function GetHeaderHeight: Integer;
    procedure CloneLine(ThisLine, Line: TReportLine);

    function PageMinHeight: Integer;
    //function HeaderHeight: integer;
    function FooterHeight():integer;
    function SumHeight():integer;
    function ExpandLine(HasDataNo:integer):TReportLine;
    function RenderCellText(NewCell,ThisCell:TReportCell):String;
    function IsDataField(s: String): Boolean;
    function GetValue(ThisCell: TReportCell): String;
    function ExpandDataHeight(HasDataNo:integer): integer;
    function DetailCellIndex(NO:integer) :Integer;
    function Dataset(): TDataset;
  public
    FFileName: Tfilename;
    FAddSpace: boolean;
    FSetData: TstringList;
    FVarList: TVarList;
    FPrintLineList: TList;
    FDRMap: TDRMappings;
    FNamedDatasets: TDataList;
    FHeaderHeight: Integer;
    Fallprint: Boolean;
    FPageCount: Integer;
    FDataLineHeight: Integer;
    Procedure UpdateLines;
    Procedure UpdatePrintLines;
    Procedure PrintOnePage;
    Procedure LoadReport;
    Function GetDatasetName(strCellText: String): String;
    Function GetDataset(strCellText: String): TDataset;
    Function DatasetByName(strDatasetName: String): TDataset;
    Function GetVarValue(strVarName: String): String;
    Function GetFieldName(strCellText: String): String;
    Procedure SetRptFileName(Const Value: TFilename);
    Procedure SaveTempFile(FileName:string;PageNumber, Fpageall: Integer);overload;
    Procedure SaveTempFile(PageNumber, Fpageall: Integer);overload;
    Function setSumAllYg(fm, ss: String): String;
    Function setSumpageYg(fm, ss: String): String;
    Procedure LoadTempFile(strFileName: String);
    Procedure DeleteAllTempFiles;
    Procedure SetNewCell(spyn: boolean; NewCell, ThisCell: TReportCell);
    Procedure SetAddSpace(Const Value: boolean);
    procedure SetEmptyCell(NewCell, ThisCell: TReportCell);
    function HasEmptyRoomLastPage: Boolean;
    function IsLastPageFull: Boolean;
    function isPageFull: boolean;
    function CloneEmptyLine(thisLine: TReportLine): TReportLine;
    function FillHeadList(): TList;
    function DetailLineIndex:Integer;
    function GetHasDataPosition(var HasDataNo,
      cellIndex: integer): Boolean;
    function AppendList(l1, l2: TList): Boolean;
    function FillFootList(): TList;
    function FillSumList(): TLineList;
    procedure JoinAllList(FPrintLineList, HandLineList, dataLineList,
      SumAllList, HootLineList: TList;IsLastPage:Boolean);
    procedure PaddingEmptyLine(hasdatano: integer; var dataLineList: TLineList);overload;
    procedure SumCell(ThisCell: TReportCell; j: Integer);
    procedure SumLine(HasDataNo: integer);
    function DoPageCount(): integer;
    function GetDataSetFromCell(HasDataNo,CellIndex:Integer):TDataset;
    function GetPrintRange(var A, Z: Integer): boolean;
    procedure LoadPage(I: integer);
    procedure PrintRange(Title: String; FromPage, ToPage: Integer);
    function ReadyFileName(PageNumber, Fpageall: Integer): String;
  Protected
    function RenderText(ThisCell: TReportCell;PageNumber, Fpageall: Integer): String;override;
  Public
    procedure ClearDataset;
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetDataset(strDatasetName: String; pDataSet: TDataSet);
    Procedure SetVarValue(strVarName, strVarValue: String);
    Property allprint: boolean Read Fallprint Write Fallprint Default true;
    Procedure PrintPreview(bPreviewMode: Boolean);
    function  EditReport :TReportControl;overload;
    function  EditReport (FileName:String):TReportControl;overload;
    Function shpreview: boolean;
    Function PrintSET(prfile: String): boolean; 
    Procedure updatepage;           
    procedure PreparePrintk(FpageAll: integer);
    Procedure loadfile(value: tfilename);
    Procedure Print(IsDirectPrint: Boolean);
    Procedure Resetself;
    Function Cancelprint: boolean;
    function GetHeadHeight: integer;
  Published
    Property ReportFile: TFilename Read FFileName Write SetRptFileName;
    Property AddSpace: boolean Read FAddSpace Write SetAddSpace;

  End;
implementation

Uses
  Preview, REPmess, Creport;
  
Procedure TReportRunTime.LoadPage(I:integer);
Var
  FileName: String;
Begin
   If FileExists(FileName) Then
        LoadTempFile(FileName);
End;

Procedure TReportRunTime.DeleteAllTempFiles;
Var
  tempDir: String;
Begin                             
  Try
    tempDir := Format('%s\temp\',[AppDir]);
    If Not DirectoryExists(tempDir) Then
      Exit;
    os.DeleteFiles(tempDir, '*.tmp');
    RmDir(tempDir);
  Except
  End;
End;
function TReportRunTime.ReadyFileName(PageNumber, Fpageall: Integer):String;
  Var
    strFileDir: String;
    FileName: String;
  procedure EnsureTempDirExist;
  Var
    tempDir: String;
  begin
    tempDir := Format('%s\temp',[AppDir]);
      If Not DirectoryExists(tempDir) Then
        MkDir(tempDir);
  end;
begin
  REPmessform.Label1.Caption := inttostr(PageNumber);
  EnsureTempDirExist;
  FileName := osservice.PageFileName(PageNumber);
  If FileExists(FileName) Then
    DeleteFile(FileName);
  result := FileName;
end;
// call this function OnSave
// todo: Sum Lines 's @t1.lb why not render ?
function TReportRunTime.RenderText(ThisCell:TReportCell;PageNumber, Fpageall: Integer):String;
var
  R : String;

begin
  If  ThisCell.IsPageNumFormula Then
    R :=Format(cc.PageFormat1,[PageNumber])
  Else If ThisCell.IsPageNumFormula1  Then
    R :=Format(cc.PageFormat,[PageNumber,FPageAll])
  Else If ThisCell.IsPageNumFormula2 Then 
    R :=Format(cc.PageFormat2,[PageNumber,FPageAll])
  Else If ThisCell.IsSumPageFormula Then
    R := setSumpageYg(thiscell.FCellDispformat,ThisCell.FCellText)
  Else If ThisCell.IsSumAllFormula  Then
    R := setSumAllYg(thiscell.FCellDispformat,ThisCell.FCellText)
  else If ThisCell.IsHeadField or thiscell.isDetailField  Then
    R := GetValue(ThisCell)
  else
    R := ThisCell.FCellText;
  Result := R;
end;

Procedure TReportRunTime.SaveTempFile(PageNumber, Fpageall: Integer);
var f :string;
begin
   f:= ReadyFileName(PageNumber, Fpageall);
   SaveTempFile(f,PageNumber, Fpageall);
end;
Procedure TReportRunTime.SaveTempFile(FileName: String;PageNumber, Fpageall: Integer);
begin
  SaveToFile(FPrintLineList,FileName,PageNumber,Fpageall);
end;

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
  try
    InternalLoadFromFile(strFileName,FPrintLineList);
    PrintPaper.Batch(FprPageNo,FprPageXy,fpaperLength,fpaperWidth);
    UpdatePrintLines;
  except
    on E:Exception do ShowMessage(e.message);
  end;

End;

Constructor TReportRunTime.Create(AOwner: TComponent);
Begin
  Inherited create(AOwner);
  FSummer:=TSummer.Create;
  FAddspace := false;
  FReportScale := 100;
  Width := 0;
  Height := 0;             
  fallprint := true;                   
  FSetData := Tstringlist.Create;
  FNamedDatasets := TDataList.Create;
  FVarList := TVarList.Create;
  FPrintLineList := TList.Create;
  FDRMap := TDRMappings.Create;              
  repmessForm := TrepmessForm.Create(Self);
  FHeaderHeight := 0;            
  If FFileName <> '' Then
    LoadReport;
End;

Destructor TReportRunTime.Destroy;
Var
  I: Integer;
Begin

  FNamedDatasets.FreeItems;
  FNamedDatasets.clear;
  FVarList.FreeItems;
  FVarList.Free;


  For I := FPrintLineList.Count - 1 Downto 0 Do
    TReportLine(FPrintLineList[I]).Free;
  FPrintLineList.Free;

  FDRMap.Free;
  FSummer.Free;
  Inherited Destroy;
End;

Function TReportRunTime.DatasetByName(strDatasetName: String): TDataset;
Var
  I: Integer;
Begin
  Result := Nil;

  For I := 0 To FNamedDatasets.Count - 1 Do
  Begin
    If TDatasetItem(FNamedDatasets[I]).strName = strDatasetName Then
    Begin
      Result := TDatasetItem(FNamedDatasets[I]).pDataset;
    End;
  End;
End;

Function TReportRunTime.GetDataset(strCellText: String): TDataset;
Begin
  Result := DatasetByName(GetDatasetName(strCellText));
End;
function TReportRunTime.IsDataField(s:String):Boolean;
begin
  result :=  (Length(s) < 2) or
   ((s[1] <> '@') And (s[1] <> '#'));
   result := not result ;
end;

//testcase  t1.lb ->  t1
Function TReportRunTime.GetDatasetName(strCellText: String): String;
Var
  I: Integer;
  s:StrSlice;
Begin
  If isDataField(strCellText) Then begin
    s:=StrSlice.Create(strCellText);
    Result := UpperCase(s.Slice(2,s.GoUntil('.')-1));
    s.Free ;
  end else
    Result := '';
End;

Function TReportRunTime.GetFieldName(strCellText: String): String;
Var
  I: Integer;
  bFlag: Boolean;
  s:StrSlice;
Begin
  If isDataField(strCellText) Then
    Result := StrSlice.DoSlice(StrCellText,'.')
  else
    Result := '';
End;

Procedure TReportRunTime.LoadReport;
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
  try
    InternalLoadFromFile(FFileName,FLineList);
    PrintPaper.Batch(FprPageNo,FprPageXy,fpaperLength,fpaperWidth);
    UpdateLines;
    FHeaderHeight := GetHeaderHeight;
  except
    on E:Exception do ShowMessage(e.message);
    end;
End;


Procedure TReportRunTime.SetEmptyCell(NewCell, ThisCell:TReportCell);
Begin
  setNewCell(true,NewCell,ThisCell);
End;

//  增加 ,完全重写的 PreparePrint,并增加了用空行补满一页 统计等功能
//返回数用于在预览中确定代＃字头数据库是在模板的第几行
function TReportRunTime.IsLastPageFull:Boolean ;
begin
  result := (FtopMargin + getHeadHeight + FDataLineHeight + SumHeight +
          FBottomMargin) > height;
end;
function TReportRunTime.isPageFull:boolean;
begin
  result := (FtopMargin + getHeadHeight + FDataLineHeight + FooterHeight + FBottomMargin >height);
end;
function TReportRunTime.PageMinHeight:Integer;
begin
  result := FtopMargin + getHeadHeight + FooterHeight + FBottomMargin ;
end;
function TReportRunTime.HasEmptyRoomLastPage:Boolean;
begin
  result := FtopMargin + getHeadHeight +
      FDataLineHeight +
      SumHeight + FBottomMargin < height;
end;

function TReportRunTime.AppendList( l1, l2:TList):Boolean;var n :integer; begin
    For n := 0 To l2.Count - 1 Do
      l1.Add(l2[n]);
    result := true;
end;


function TReportRunTime.GetDataSetFromCell(HasDataNo,CellIndex:Integer):TDataset;
begin
  result := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
end;

function TReportRunTime.GetPrintRange(var A,Z:Integer):boolean;
var
  PrintDlg: TPrintDialog; I: Integer;
begin
  PrintDlg := TPrintDialog.Create(Self);
  PrintDlg.MinPage := 1;
  PrintDlg.MaxPage := FPageCount;
  PrintDlg.FromPage := 1;
  PrintDlg.ToPage := FPageCount;
  PrintDlg.Options := [poPageNums];
  If Not PrintDlg.Execute Then
    Begin
      result := false;
    End
  else begin
    a := printdlg.frompage;
    z := printdlg.topage;       
    result := true;
  end;
  PrintDlg.Free;
end;
Procedure TReportRunTime.ClearDataset();
Var
  I: Integer;
begin
   For I := FNamedDatasets.Count - 1 Downto 0 Do
    TDataSetItem(FNamedDatasets[I]).Free;
   FNamedDatasets.clear;
end;
procedure TReportRunTime.PrintRange(Title:String;FromPage,ToPage:Integer);
Var
  I: Integer;
begin
			Printer.Title := Title;
			Printer.BeginDoc;
			For I := FromPage To ToPage Do
			Begin
			  LoadPage(I);
			  PrintOnePage;
			  If I < ToPage Then
				Printer.NewPage;
			End;
			Printer.EndDoc;

end;
//IsDirectPrint  ：true , 代表是否直接打印 ,false 表示从预览UI中调用打印
Procedure TReportRunTime.Print(IsDirectPrint: Boolean);
Var
  I: Integer;
  strFileDir: TFileName;
  frompage, topage: integer;
Begin
	try
		Try
			CheckError(printer.Printers.Count = 0 ,cc.ErrorPrinterSetupRequired);
			// 爱上会展：金丝楠梳，宁德老寿眉，六安瓜片，太平猴魁，汝瓷 2014-11-7 茶博会
			If IsDirectPrint Then
			Begin
			  REPmessform.show;
			  i := DoPageCount;
			  PreparePrintk( i);
        REPmessform.Hide;
			End;
			FromPage := 1;
			ToPage  := FPageCount;
			if not GetPrintRange(frompage,topage) then exit;
      PrintRange('C_Report',Frompage,ToPage);
		Except
		on E:Exception do
		  MessageDlg(e.Message,mtInformation, [mbOk], 0);
		End;
	finally          
     If IsDirectPrint  Then
				DeleteAllTempFiles;
	end;
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

  For I := FDRMap.Count - 1 Downto 0 Do
    TDRMapping(FDRMap[I]).Free;

  FDRMap.Clear;
End;
 //LCJ: 可直接或在预览中调用设置打印参数
Function TReportRunTime.PrintSET(prfile: String): boolean;
Begin
  Application.CreateForm(TMarginForm, MarginForm);
  MarginForm.filename.Caption := prfile;
  Try
    MarginForm.ShowModal;
    result :=  MarginForm.okset ;
  Finally
    MarginForm.free;
  End;
End;

Procedure TReportRunTime.PrintPreview(bPreviewMode: Boolean);
Var
  i: integer;
Begin
  try
    Try
      If printer.Printers.Count <= 0 Then
        Application.Messagebox(cc.ErrorPrinterSetupRequired, '', MB_OK + MB_iconwarning)
      Else
      Begin
        i := DoPageCount;
        REPmessform.show;
        PreparePrintk( i);
        TPreviewForm.Action(ReportFile,FPageCount,bPreviewMode);
      End;
    Except
      MessageDlg(cc.ErrorRendering, mtInformation, [mbOk], 0);
    End;
  finally
    FNamedDatasets.FreeItems;
    FNamedDatasets.clear;
    DeleteAllTempFiles;
    REPmessform.Hide;
  end;
End;

Function TReportRunTime.shpreview: boolean;
Var
  i: integer;
Begin
  If PrintSET(reportfile)  Then
  Begin
    ReportFile := reportfile; 
    i := DoPageCount;
    REPmessform.show;                     
    PreparePrintk( i);
    REPmessform.Hide;
    PreviewForm.PageCount := FPageCount;
    PreviewForm.SetPage;
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
  FNamedDatasets.Add(TempItem);
End;

Procedure TReportRunTime.SetRptFileName(Const Value: TFilename);
Begin
  FFileName := Value;
  If Value <> '' Then
    LoadReport;
End;


Procedure TReportRunTime.UpdateLines;
Begin
  EachCell(EachCell_CalcHeight);
  EachLine(EachLine_CalcLineHeight);
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
  // 首先计算合并后的单元格
  For I := 0 To FPrintLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);

    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If ThisCell.FSlaveCells.Count > 0 Then
        ThisCell.CalcHeight;
    End;
  End;

  // 计算每行的高度
  For I := 0 To FPrintLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FPrintLineList[I]);
    ThisLine.UpdateLineHeight;
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
  FNamedDatasets.clear;
  fvarlist.clear;
  flinelist.clear;
  fprintlinelist.clear;
  FDRMap.clear;
End;

Function TReportRunTime.GetVarValue(strVarName: String): String;
begin
  Result := FVarList.GetVarValue(StrVarName);
end;


Procedure TReportRunTime.SetVarValue(strVarName, strVarValue: String);
Var
  ThisItem: TVarTableItem;
Begin
  If Length(strVarName) <= 0 Then
    Exit;
  ThisItem := FVarList.FindKeyOrNew(strVarName);
  ThisItem.strVarValue := strVarValue;
End;


Procedure TReportRunTime.loadfile(value: tfilename);
Begin
  FFileName := Value;
  If Value <> '' Then
    LoadReport;
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



Function TReportRunTime.SetSumAllYg(fm, ss: String): String; //add  
var
  Value,iCode :Integer;
  slice :StrSlice;
  s : string;
Begin
  slice := StrSlice.Create(ss);
  s := slice.Slice(slice.GoUntil('(')+1,slice.GoUntil(')')-1);
  val(s, Value, iCode);
  if iCode = 0 then begin
   Value := strtoint(s) ;
    Result := FormatFloat(fm,FSummer.GetSumAll(Value));
  end else
   Result := 'N/A';
 end;

Function TReportRunTime.setSumpageYg(fm, ss: String): String;
var
  Value ,iCode:Integer;
  slice :StrSlice;
  s : string;
Begin
  slice := StrSlice.Create(ss);
  s := slice.Slice(slice.GoUntil('(')+1,slice.GoUntil(')')-1);
  val(s, Value, iCode);
  if iCode = 0 then begin
   Value := strtoint(s) ;
   Result := FormatFloat(fm,FSummer.GetSumPage(Value));
  end else
   Result := 'N/A';
 end;


Procedure TReportRunTime.SetAddSpace(Const Value: boolean);
Begin
  FAddSpace := Value;
End;

function TReportRunTime.EditReport:TReportControl;
begin
  result := TCreportform.EditReport(ReportFile);
end;
function TReportRunTime.EditReport(FileName:String):TReportControl;
begin
  result := TCreportform.EditReport(FileName);
end;
Procedure TReportRunTime.updatepage;
Var
  i: integer;
Begin
  ReportFile := reportfile;
  i := DoPageCount;
  REPmessform.show;
  PreparePrintk(i);
  REPmessform.Hide;
  PreviewForm.PageCount := FPageCount;
  PreviewForm.SetPage;
End;
Procedure Register;
Begin
  RegisterComponents('CReport', [TReportRunTime]);
End;

constructor RenderException.Create;
begin
  self.message := cc.RenderException;
end;

procedure TSummer.Acc(j: integer; value: real);
begin
   SumPage[j] := SumPage[j] + value;
   SumAll[j]  := SumAll[j] + value;
end;

function TSummer.GetSumAll(i: integer): Real;
begin
   result := SumALL[i];
end;

function TSummer.GetSumPage(i: integer): Real;
begin
  If i < 0 Then
   raise Exception.Create(cc.SumPageFormat);
  result := SumPage[i];
end;

procedure TSummer.ResetAll;
var n :integer;
begin
  For n := 0 To 40 Do 
  Begin
    SumPage[n] := 0;
    SumAll[n] := 0;
  End;
end;

procedure TSummer.ResetSumPage;
var n :integer;
begin
  For n := 0 To 40 Do
    SumPage[n] := 0;
end;


{ TDataList }

procedure TDataList.FreeItems;
var I :integer;
begin
    For I := Count - 1 Downto 0 Do
      TDataSetItem(Items[I]).Free;
end;

// TODO :以下代码都得好好改下。
function TReportRunTime.GetValue(ThisCell:TReportCell):String;
var
   cellText :string;
   cf: CellField ;
begin
  CellText := ThisCell.FCellText;
  cf:= CellField.Create(ThisCell.CellText,GetDataset(thisCell.CellText)) ;
  try
    If ThisCell.IsHeadField and (not cf.IsNullField) Then
    Begin
      CellText := cf.GetField().displaytext ;
      If cf.isNumberField  Then
      Begin
        If ThisCell.CellDispformat <> '' Then
            cellText := ThisCell.FormatValue(cf.DataValue());
      End
    End
    Else If ThisCell.IsFormula Then
        CellText := GetVarValue(thiscell.FCellText) ;
    result := CellText;
  finally
    cf.Free;
  end;
end;
function TReportRunTime.RenderCellText(NewCell,ThisCell:TReportCell):String;
var
   cellText :string;
   cf: CellField ;
begin
  CellText := ThisCell.FCellText;
  cf:= CellField.Create(ThisCell.CellText,GetDataset(thisCell.CellText)) ;
  try
    If ThisCell.IsHeadField and (not cf.IsNullField) Then
    Begin
      CellText := cf.GetField().displaytext ;
      If cf.isNumberField  Then
      Begin
        If ThisCell.CellDispformat <> '' Then
            cellText := ThisCell.FormatValue(cf.DataValue());
      End
      Else If cf.IsBlobField then begin
         NewCell.LoadCF(cf);
         CellText := '';
      end;
    End
    Else If  thisCell.IsDetailField Then
    Begin
      If cf.IsNumberField Then
      Begin
        CellText := cf.GetField.displaytext;
        If thiscell.CellDispformat <> '' Then
        Begin
          If Not cf.IsNullField  Then
            cellText := Thiscell.FormatValue(cf.DataValue);
        End
      End
      Else If cf.IsBlobField then begin
         NewCell.LoadCF(cf);
         CellText := '';
      end
      Else
        CellText := cf.GetField.displaytext;
    End
    Else If ThisCell.IsFormula Then
        CellText := GetVarValue(thiscell.FCellText) ;
    result := CellText;
  finally
    cf.Free;
  end;
end;

Procedure TReportRunTime.SetNewCell(spyn: boolean; NewCell, ThisCell:
  TReportCell);

Begin
  NewCell.CloneFrom(ThisCell);
  If Not spyn Then
    NewCell.CellText:= RenderCellText(newCell,ThisCell)
  Else
    NewCell.CellText := ''; 
  NewCell.FLogFont := ThisCell.FLogFont;
  FDRMap.RuntimeMapping(NewCell, ThisCell);
  NewCell.CalcHeight;
End;
function TReportRunTime.GetHeaderHeight:Integer;
var I,J,FHeaderHeight :Integer; ThisLine:TReportLine;bHasDataSet:boolean;  ThisCell :TReportCell;
begin
    FHeaderHeight := 0;

  For I := 0 To FLineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FLineList[I]);
    bHasDataSet := False;
    For J := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TReportCell(ThisLine.FCells[J]);

      If Length(ThisCell.FCellText) > 0 Then  //如果当前CELL有字符，判断是否有数据集
      Begin
        If ThisCell.FCellText[1] = '#' Then
          bHasDataSet := True;
      End;
    End;
    If Not bHasDataSet Then
      FHeaderHeight := FHeaderHeight + ThisLine.LineHeight;
  End;
  result := FHeaderHeight;
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
    NewCell := TReportCell.Create(Self);
    TempLine.FCells.Add(NewCell);
    NewCell.FOwnerLine := TempLine;
    SetEmptyCell(newcell, thiscell);
  End;
  result := templine;
end;
// clone from ThisLine to Line
procedure TReportRunTime.CloneLine(ThisLine,Line:TReportLine);
var
  LineList:TLineList;
  i,j:integer;
  ThisCell, NewCell: TReportCell;
begin
  Line.FMinHeight := ThisLine.FMinHeight;
  Line.FDragHeight := ThisLine.FDragHeight;
  For j := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    ThisCell := TreportCell(ThisLine.FCells[j]);
    NewCell := TReportCell.Create(Self);
    Line.FCells.Add(NewCell);
    NewCell.FOwnerLine := Line;
    SetNewCell(false, newcell, thiscell);
  End;
  Line.UpdateLineHeight;  
end;
function TReportRunTime.FillHeadList():TList;
var
  LineList:TLineList;
  ThisLine, Line: TReportLine;
  i:Integer;
begin
   LineList := TLineList.Create(self);
   try
     For i := 0 To FLineList.Count - 1 Do
     Begin
      ThisLine := FlineList[i];
      if Not ThisLine.IsDetailLine then
      begin
        Line := TReportLine.Create;
        LineList.Add(Line);
        CloneLine(ThisLine,Line);
      end else
        break;
     End;
   finally
     result :=   LineList ;
   end;
end;

function TReportRunTime.GetHeadHeight:integer;
var
   i:integer;
begin
   result := 0 ;
   i := 0;
   while (not FlineList[i].IsDetailLine) and (i < FLineList.Count) do
   begin
     inc(result,FlineList[i].LineHeight);
     inc(i);
   end;
end;



function TReportRunTime.GetHasDataPosition(var HasDataNo,cellIndex:integer):Boolean;
Var
  I, J, n:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  HasDataNo := -1 ;
  For i := 0 To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#') Then
        Begin
          HasDataNo := i;
          cellIndex := j ;
          exit;
        End;
    End;                             
  End;
end;
function TReportRunTime.DetailLineIndex:Integer;
Var
  I, J:Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
begin
  Result := -1 ;
  For i := 0 To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#') Then
        Begin
          Result := i;
          exit;
        End;
    End;                             
  End;
end;
function TReportRunTime.DetailCellIndex(No:integer):Integer;
Var
  I, J, n:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  Result := -1;
  For i := No To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
        ThisCell := TreportCell(ThisLine.FCells[j]);
        If (Length(ThisCell.CellText) > 0) And (ThisCell.FCellText[1] = '#') Then
        Begin
          Result := j ;
          exit;
        End;
    End;                             
  End;
end;
function TReportRunTime.FillFootList( ):TList;
  Var
  I, J, n:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  HootLineList := TList.Create;
  For i := DetailLineIndex + 1 To FlineList.Count - 1 Do
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
      NewCell := TReportCell.Create(Self);
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      setnewcell(false, newcell, thiscell);
    End;
    If (UpperCase(copy(ThisCell.FCellText, 1, 7)) <> '`SUMALL') Then
      TempLine.UpdateLineHeight;
  End;
  result := HootLineList;
end;
function TReportRunTime.FooterHeight():integer;
var
   i:integer;
begin
   result := 0 ;
   i := DetailLineIndex + 1;
   while  (i < FLineList.Count) and  (not FlineList[i].IsSumAllLine) do
   begin
     inc(result,FlineList[i].LineHeight);
     inc(i);
   end;
end;

//将有合计的行(`SumAll)存入一个列表中
function TReportRunTime.FillSumList():TLineList;
Var
  I, J, n,  TempDataSetCount:Integer;
  sumAllList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  sumAllList := TLineList.Create(self);
  For i := DetailLineIndex + 1 To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    TempLine := TReportLine.Create;
    TempLine.FMinHeight := ThisLine.FMinHeight;
    TempLine.FDragHeight := ThisLine.FDragHeight;
    sumAllList.Add(TempLine);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      NewCell := TReportCell.Create(Self);
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      setnewcell(false, newcell, thiscell);
    End;                              //for j
    TempLine.UpdateLineHeight;
  End;
  result :=  sumAllList;
end ;
function TReportRunTime.SumHeight():integer;
var
   i:integer;
begin
   result := 0 ;
   i := DetailLineIndex + 1;
   while  (i < FLineList.Count) do
   begin
     inc(result,FlineList[i].LineHeight);
     inc(i);
   end;
end;

procedure TReportRunTime.PaddingEmptyLine(hasdatano:integer; var dataLineList:TLineList);
var
  thisline,templine : Treportline ;
begin
  thisline := FLineList[hasdatano];
  templine := CloneEmptyLine(thisLine);
  While true Do
  Begin
    dataLineList.Add(templine);
    TempLine.UpdateLineHeight;
    inc(FDataLineHeight ,templine.GetLineHeight);
    If IsLastPageFull Then
    Begin
      dataLineList.Delete(dataLineList.Count - 1);
      break;
    End;
  End;
end;
procedure TReportRunTime.SumCell(ThisCell:TReportCell;j:Integer);
  function IsFieldNumric(FieldName:String):Boolean;
  begin
    result :=
      (Not Dataset.fieldbyname(FieldName).IsNull)
       and (Dataset.fieldbyname(FieldName) Is TNumericField) ;
  end;
Var
  FieldName : string;
  value : real;
begin
  Try
    FieldName := GetFieldName(ThisCell.CellText) ;
    if ThisCell.IsDetailField and IsFieldNumric(FieldName) then
    Begin
      value := Dataset.fieldbyname(FieldName).Value ;
      FSummer.Acc(j,Value);
    End;
  Except
    raise Exception.create('统计时发生错误，请检查模板设置是否正确');
  End;
end;
function TReportRunTime.ExpandLine(HasDataNo:integer):TReportLine;
var
  thisLine ,TempLine: TReportLine;
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;

begin
  ThisLine := TReportLine(FlineList[HasDataNo]);
  TempLine := TReportLine.Create;
  TempLine.FMinHeight := ThisLine.FMinHeight;
  TempLine.FDragHeight := ThisLine.FDragHeight;
  For j := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    ThisCell := TreportCell(ThisLine.FCells[j]);
    NewCell := TReportCell.Create(Self);
    TempLine.FCells.Add(NewCell);
    NewCell.FOwnerLine := TempLine;
    setnewcell(false, newcell, thiscell);
  End; //for j
  TempLine.UpdateLineHeight;
  result := TempLine;
end;
function TReportRunTime.ExpandDataHeight(HasDataNo:integer):integer;
var
  thisLine ,TempLine: TReportLine;
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;
begin
  ThisLine := TReportLine(FlineList[HasDataNo]);
  // 痛苦的副作用：下面的11行代码对Result无影响，但是不能删除，否则飞线。
  TempLine := TReportLine.Create;
  TempLine.FMinHeight := ThisLine.FMinHeight;
  TempLine.FDragHeight := ThisLine.FDragHeight;
  For j := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    ThisCell := TreportCell(ThisLine.FCells[j]);
    NewCell := TReportCell.Create(Self);
    TempLine.FCells.Add(NewCell);
    NewCell.FOwnerLine := TempLine;
    SetNewCell(false, newcell, thiscell);
  End;
  Result := ThisLine.GetLineHeight;
end;
procedure TReportRunTime.SumLine(HasDataNo:integer);
var j:integer;var thisLine ,TempLine: TReportLine;
Var
  I,  n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;
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
function TReportRunTime.DataSet ():TDataset;
var
   t : string;
begin
   t :=  Cells[ DetailLineIndex,DetailCellIndex(DetailLineIndex)].FCellText;
   result := GetDataSet(t);
end;

Type
  RenderParts = class
  private
    FRC:TReportRuntime;
    FLineList:TLineList;
    FDataLineList :TLineList ;
    procedure ResetData;
    procedure SavePage(fpagecount, FpageAll:Integer);
    procedure JoinList(FPrintLineList: TList; IsLastPage: Boolean);
    function AppendList(l1, l2: TList): Boolean;
    procedure SaveHeadPage;
  private
     FHead,FFoot,FData,FSumAll:TLineList;
  public
     constructor Create(RC:TReportRuntime);
     function FillPage(FromIndex: Integer):Integer;
     procedure FillHead;
     procedure FillFoot;
     procedure FillSumAll;
     property Head:TLineList read FHead;
     property Foot:TLineList read FFoot;
  end;

// todo:NextStep --> Iam tired ,have a rest
procedure TReportRunTime.PreparePrintk(FpageAll: integer);
Var
  rp : RenderParts ;
  procedure FreeList;
  Var
    n :Integer;
  begin
    FPrintLineList.Clear;
    FDRMap.FreeItems;
    FDRMap.Clear;
  end;


  procedure DataPage(Dataset:TDataset);
  Var
    ThisLine, TempLine: TReportLine;
    ThisCell, NewCell: TReportCell;
    I, J,N:Integer;
  Begin
    Dataset.First;
    rp.FillHead();
    rp.FillFoot ;
    rp.FillSumAll ;
    FDataLineHeight := 0;
    // dataLineList era
    i := 0;
    While (i < Dataset.RecordCount) Do
    Begin
      i := rp.FillPage (i);
      If isPageFull Then
      Begin
        CheckError(rp.FData.Count = 0,cc.RenderException);
        rp.SavePage(fpagecount, FpageAll);
        begin
          FSummer.ResetSumPage;
          FPrintLineList.Clear;
          rp.ResetData;
        end;
        FDataLineHeight := 0;
        inc(Fpagecount);
      End;
      application.ProcessMessages;
    End;
    // dataLineList END
    // 都是  i =  TempDataSetCount，也看从那个分支出来的。
    if not IsPageFull then
    begin
      If (Faddspace) And (HasEmptyRoomLastPage) Then begin
        PaddingEmptyLine(DetailLineIndex,rp.FData );
      end;
      JoinAllList(FPrintLineList, rp.Head,rp.FData,rp.FSumAll,rp.Foot,True);
      UpdatePrintLines;
      SaveTempFile(ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
    end; 
  End ;

Var
  CellIndex:Integer;

Begin
  rp := RenderParts.Create(Self);
  try
    try
      FSummer.ResetAll;
      FpageCount := 1;

      If DetailLineIndex = -1 Then
      begin
        rp.FillHead();
        rp.SaveHeadPage()
      end
      else
      begin
       DataPage(Dataset);
      end;
      FreeList;
    except
      on E:Exception do
           MessageDlg(e.Message,mtInformation,[mbOk], 0);
    end;
  finally
    rp.Free ;
  end;
End;
Function TReportRunTime.DoPageCount:integer;
Var
  CellIndex,I :Integer;
Begin
  try
    FpageCount := 1;
    If DetailLineIndex <> -1 Then
    Begin
      Dataset.First;
      FDataLineHeight := 0;
      i := 0;
      While (i < Dataset.RecordCount)  Do
      Begin
        inc(FDataLineHeight ,ExpandDataHeight(DetailLineIndex)) ;
        If isPageFull  Then
        Begin
          inc(FPagecount);
          FDataLineHeight := 0;
        End else begin
          Dataset.Next;
          i := i + 1;
        end;
      End;
    End ;
    result := FPagecount;
  except
    on E:Exception do MessageDlg(e.Message,mtInformation,[mbOk], 0);
  end;
End;       

{ RenderParts }

constructor RenderParts.Create(RC:TReportRuntime);
begin
  Self.FLineList := RC.LineList ;
  Self.FRC :=RC ;
end;

procedure RenderParts.FillHead;
var
  LineList:TLineList;
  ThisLine, Line: TReportLine;
  i:Integer;
begin
   LineList := TLineList.Create(FRC);
   try
     For i := 0 To FLineList.Count - 1 Do
     Begin
      ThisLine := FlineList[i];
      if Not ThisLine.IsDetailLine then
      begin
        Line := TReportLine.Create;
        LineList.Add(Line);
        FRC.CloneLine(ThisLine,Line);
      end else
        break;
     End;
   finally
     FHead :=   LineList ;
   end;
end;
procedure RenderParts.FillFoot;
  Var
  I, J, n:Integer;
  HootLineList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  HootLineList := TLineList.Create(FRC);
  For i := FRc.DetailLineIndex + 1 To FlineList.Count - 1 Do
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
      NewCell := TReportCell.Create(self.FRC);
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      FRC.setnewcell(false, newcell, thiscell);
    End;
    If (UpperCase(copy(ThisCell.FCellText, 1, 7)) <> '`SUMALL') Then
      TempLine.UpdateLineHeight;
  End;
  FFoot := HootLineList;
end;
procedure RenderParts.FillSumAll();
Var
  I, J, n,  TempDataSetCount:Integer;
  sumAllList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  sumAllList := TLineList.Create(FRC);
  For i := FRC.DetailLineIndex + 1 To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    TempLine := TReportLine.Create;
    TempLine.FMinHeight := ThisLine.FMinHeight;
    TempLine.FDragHeight := ThisLine.FDragHeight;
    sumAllList.Add(TempLine);
    For j := 0 To ThisLine.FCells.Count - 1 Do
    Begin
      ThisCell := TreportCell(ThisLine.FCells[j]);
      NewCell := TReportCell.Create(FRC);
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      FRC.setnewcell(false, newcell, thiscell);
    End;                              //for j
    TempLine.UpdateLineHeight;
  End;
  FSumAll :=  sumAllList;
end ;
procedure RenderParts.ResetData;
begin
  // memory leak if items not clear !
  FData.Free;
end;
function RenderParts.FillPage(FromIndex:Integer):Integer;
var i :integer;tempLine:TReportLine;
begin
  i := FromIndex;
  FData := TLineList.Create(FRC);
  while (i < FRC.Dataset.RecordCount) do
  begin
    TempLine := FRC.ExpandLine(FRC.DetailLineIndex);
    inc(FRC.FDataLineHeight,FRC.ExpandDataHeight(FRC.DetailLineIndex));
    if not FRC.isPageFull then begin
      FData.add(tempLine);
      FRC.SumLine(FRC.DetailLineIndex);
      FRC.Dataset.Next;
      i := i + 1;
    end else
      break;
  end;
  Result := i;
end;
procedure RenderParts.SavePage(fpagecount, FpageAll:Integer);
begin
   JoinList(FRC.FPrintLineList,false);
   FRC.UpdatePrintLines;
   FRC.SaveTempFile(fpagecount, FpageAll);
end;
procedure RenderParts.SaveHeadPage();
begin
    FRC.AppendList(FRC.FPrintLineList, FHead);
    FRC.UpdatePrintLines;
    FRC.SaveTempFile(1,1);
end;

procedure  RenderParts.JoinList(FPrintLineList:TList;IsLastPage:Boolean);
begin
    AppendList(  FPrintLineList, FHead);
    AppendList(  FPrintLineList, FData);
    If (IsLastPage) Then
      AppendList(  FPrintLineList, FSumAll)
    Else
      AppendList(  FPrintLineList, FFoot);
end;


function RenderParts.AppendList( l1, l2:TList):Boolean;var n :integer;
begin
    For n := 0 To l2.Count - 1 Do
      l1.Add(l2[n]);
    result := true;
end;

end.




