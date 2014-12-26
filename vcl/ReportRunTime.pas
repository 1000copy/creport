unit ReportRunTime;

interface
uses ReportControl,  Windows, Messages, SysUtils,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice,margin;
Procedure Register;
type
   TSummer = class
     //最多40列单元格,否则统计汇总时要出错. 拟换为动态的
     SumPage, SumAll: Array[0..40] Of real;
   public
     procedure Acc(j:integer;value:real);
     procedure ResetSumPage;
     procedure ResetAll;
     function GetSumAll(i:integer):Real;
     function GetSumPage(i:integer):Real;
   end;
type
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
    function HeaderHeight: integer;
    function FooterHeight: integer;
    function SumHeight:integer;
    function ExpandLine(var HasDataNo, ndataHeight: integer): TReportLine;
    function RenderCellText(NewCell,ThisCell:TReportCell):String;
    function IsDataField(s: String): Boolean;

  public
    //小计和合计用,最多40列单元格,否则统计汇总时要出错.

    FFileName: Tfilename;
    FAddSpace: boolean;
    FSetData: TstringList;
    // 保存变量的名字和值的对照表
    FVarList: TList;
    //保存要打印的某一页的行信息
    FPrintLineList: TList;
    // 保存每一页中合并后单元格前后的指针
    FDRMap: TDRMappings;
    FNamedDatasets: TList;
    FHeaderHeight: Integer;
    //是否打印全部记录，默认为全部
    Fallprint: Boolean;
    // 总页数
    FPageCount: Integer;
    nDataHeight, nHandHeight, nHootHeight, nSumAllHeight: Integer;
    Dataset: TDataset;
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


    Procedure SaveTempFile(FileName:string;PageNumber, Fpageall: Integer);

    Function setSumAllYg(fm, ss: String): String;
    Function setSumpageYg(fm, ss: String): String;

    Procedure LoadTempFile(strFileName: String);
    Procedure DeleteAllTempFiles;
    Procedure SetNewCell(NewCell, ThisCell: TReportCell);
    Procedure SetAddSpace(Const Value: boolean);
    procedure SetEmptyCell(NewCell, ThisCell: TReportCell);
    function HasEmptyRoomLastPage: Boolean;
    function IsLastPageFull: Boolean;
    function isPageFull: boolean;
    function CloneEmptyLine(thisLine: TReportLine): TReportLine;
    function FillHeadList(var H: integer): TLineList;
    function GetHasDataPosition(var HasDataNo,
      cellIndex: integer): Boolean;
    function AppendList(l1, l2: TList): Boolean;
    function FillFootList(var nHootHeight: integer): TLineList;
    function FillSumList(var nSumAllHeight: integer): TLineList;
    procedure JoinAllList(FPrintLineList, HandLineList, dataLineList,
      SumAllList, HootLineList: TList;IsLastPage:Boolean);
    procedure PaddingEmptyLine(hasdatano: integer; var dataLineList: TLineList;
      var ndataHeight: integer);overload;
    procedure SumCell(ThisCell: TReportCell; j: Integer);
    procedure SumLine(var HasDataNo: integer);
    function DoPageCount(): integer;
    function RenderLineHeight(HasDataNo:integer):Integer;
    function GetDataSetFromCell(HasDataNo,CellIndex:Integer):TDataset;
    function GetPrintRange(var A, Z: Integer): boolean;
    procedure LoadPage(I: integer);
    procedure PrintRange(Title: String; FromPage, ToPage: Integer);
    function ReadyFileName(PageNumber, Fpageall: Integer): String;
  Protected
    //function RenderText(ThisCell: TReportCell;PageNumber, Fpageall: Integer): String;override;
  Public
    procedure ClearDataset;
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetDataset(strDatasetName: String; pDataSet: TDataSet);
    Procedure SetVarValue(strVarName, strVarValue: String);
    Property allprint: boolean Read Fallprint Write Fallprint Default true;
    Procedure ResetContent;
    Procedure PrintPreview(bPreviewMode: Boolean);
    function  EditReport (FileName:String):TReportControl;
    Function shpreview: boolean;        //重新生成预览有关文件
    Function PrintSET(prfile: String): boolean; //纸张及边距设置，lzl
    Procedure updatepage;               //
    procedure PreparePrintk(FpageAll: integer);
    Procedure loadfile(value: tfilename);
    Procedure Print(IsDirectPrint: Boolean);
    Procedure Resetself;
    Function Cancelprint: boolean;                               
  Published
    Property ReportFile: TFilename Read FFileName Write SetRptFileName;
    Property AddSpace: boolean Read FAddSpace Write SetAddSpace;

  End;
implementation
{ TReportRunTime }
Uses Preview, REPmess, Creport;
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
    tempDir := Format('%s\temp\',[os.ExeDir]);
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
Var
  tempDir: String;
begin
  REPmessform.Label1.Caption := inttostr(PageNumber);
  tempDir := Format('%s\temp',[os.ExeDir]);
  If Not DirectoryExists(tempDir) Then
    MkDir(tempDir);
  FileName := Format('%s\%d.tmp',[tempDir ,PageNumber]);
  If FileExists(FileName) Then
    DeleteFile(FileName);
  result := FileName;
end;
//function TReportRunTime.RenderText(ThisCell:TReportCell;PageNumber, Fpageall: Integer):String;
//var
//  celltext : String;
//
//begin
//  result := inherited(ThisCell,PageNumber, Fpageall);
//  exit;
//    If  ThisCell.IsPageNumFormula Then
//      celltext :=Format('第%d页',[PageNumber])
//    Else If ThisCell.IsPageNumFormula1  Then
//      celltext :=Format('第%d/%d页',[PageNumber,FPageAll])
//    Else If ThisCell.IsPageNumFormula2 Then 
//      celltext :=Format('第%d-%d页',[PageNumber,FPageAll])
//    Else If ThisCell.IsSumPageFormula Then
//    Begin
//      celltext := trim(setSumpageYg(thiscell.FCellDispformat,ThisCell.FCellText));
//    End
//    Else If ThisCell.IsSumAllFormula  Then  //  增
//    Begin
//        celltext := setSumAllYg(thiscell.FCellDispformat,ThisCell.FCellText);
//    End Else
//        celltext := ThisCell.FCellText;
//    Result := celltext;
//end;

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
  FNamedDatasets := TList.Create;
  FVarList := TList.Create;
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
  For I := FNamedDatasets.Count - 1 Downto 0 Do
    TDataSetItem(FNamedDatasets[I]).Free;
  FNamedDatasets.clear;

  For I := FVarList.Count - 1 Downto 0 Do
    TVarTableItem(FVarList[I]).Free;
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
type
  StrSlice=class
    FStr :string;
  public
    constructor Create(str:String);
    function GoUntil(c:char):integer;
    function Slice(b,e:integer):string;overload;
    function Slice(b:integer):string;overload;
    class function DoSlice(str: String; FromChar:char): string;
  end;
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
Procedure TReportRunTime.SetEmptyCell(NewCell, ThisCell:TReportCell);
Begin
  setNewCell(NewCell,ThisCell);
End;
// Mappings From CellText to Data end :TDataset ,TField,Value 
type
   CellField = class
     FCellText : string;
     Fds:TDataset;
  private
    function GetFieldName: String;
    function IsDataField(s: String): Boolean;
   public
    constructor Create(CellText:String;ds:TDataset);
    function DataValue(): Extended;
    function ds: TDataset;
    function GetField(): TField;
    function IsNullField(): Boolean;
    function IsNumberField(): Boolean;
    function IsBlobField:Boolean;

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
      Else If cf.IsBlobField Then
      Begin
        NewCell.fbmp := TBitmap.create;
        NewCell.FBmp.Assign(cf.GetField);
        NewCell.FbmpYn := true;
      End
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
      Else If cf.IsBlobField then
      Begin
        CellText := '';
        If Not cf.IsNullField Then
        Begin
          NewCell.fbmp := TBitmap.create;
          NewCell.FBmp.Assign(cf.GetField);
          NewCell.FbmpYn := true;
        End
      End
      Else
        CellText := cf.GetField.displaytext;
    End
    Else If ThisCell.IsFormula Then
<<<<<<< HEAD
      CellText := GetVarValue(thiscell.FCellText)
    Else If ThisCell.IsSumAllFormula Then
      CellText := self.setSumAllYg('',ThisCell.CellText)
    Else If ThisCell.IsSumPageFormula Then
      CellText := self.setSumpageYg('',ThisCell.CellText);
=======
        CellText := GetVarValue(thiscell.FCellText) ;
>>>>>>> parent of e1dec3e... todo : 闇�瑕佷竴涓ソ鐨別xpress parser锛屼互渚挎妸鍏抽棴鐨勫姛鑳藉姞涓婂幓
    result := CellText;
  finally
    cf.Free;
  end;
end;
Procedure TReportRunTime.SetNewCell(NewCell, ThisCell:
  TReportCell);
Var
  TempCellTable: TDRMapping;
  L: integer;
  TempOwnerCell: TReportCell;

Begin 
  With NewCell Do
  Begin
    NewCell.CloneFrom(ThisCell);
    If ThisCell.IsSimpleText Then
      CellText := ThisCell.FCellText
    Else
      CellText:= RenderCellText(newCell,ThisCell);
    flogfont := thiscell.FLogFont;
    // TODO:LCJ :看了一遍， 没有看懂。
    // DONE : 基本懂了。
    // 运行逻辑：如果设计态是Slave，在runtime时也得是奴隶，通过这个FOwnerCellList找到自己的新主人
    If ThisCell.OwnerCell <> Nil Then
    Begin
      // 若隶属的CELL不为空则判断是否在同一页，若不在同一页则将自己加入到CELL对照表中去
      TempOwnerCell := Nil;
      // 若找到隶属的CELL则将自己加入到该CELL中去
      For L := 0 To FDRMap.Count - 1 Do
      Begin
        If ThisCell.OwnerCell = TDRMapping(FDRMap[L]).DesignMasterCell Then
          TempOwnerCell := TDRMapping(FDRMap[L]).RuntimeMasterCell;
      End;
      TempOwnerCell := FDRMap.FindRuntimeMasterCell(ThisCell);
      If TempOwnerCell = Nil Then
        FDRMap.NewMapping(ThisCell.OwnerCell,NewCell)
      Else
        TempOwnerCell.Own(NewCell);
    End;
    If ThisCell.FSlaveCells.Count > 0 Then
      FDRMap.NewMapping(ThisCell,NewCell);
    CalcHeight;
  End;
End;
//  增加 ,完全重写的 PreparePrint,并增加了用空行补满一页 统计等功能
//返回数用于在预览中确定代＃字头数据库是在模板的第几行
function TReportRunTime.IsLastPageFull:Boolean ;
begin
  result := (FtopMargin + nHandHeight + nDataHeight + nSumAllHeight +
          FBottomMargin) > height;
end;
function TReportRunTime.isPageFull:boolean;
begin
  result := (FtopMargin + nHandHeight + nDataHeight + nHootHeight + FBottomMargin >height);
end;
function TReportRunTime.PageMinHeight:Integer;
begin
  result := FtopMargin + nHandHeight + nHootHeight + FBottomMargin ;
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
        NewCell := TReportCell.Create(Self);
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
        //setnewcell(true, newcell, thiscell, Dataset);
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
    SetNewCell( newcell, thiscell);
  End;
  Line.UpdateLineHeight;  
end;
function TReportRunTime.FillHeadList(var H:integer):TLineList;
var
  LineList:TLineList;
  i,j:integer;
  ThisLine, Line: TReportLine;
  ThisCell, NewCell: TReportCell;
  function Fill:TLineList;
  var i,j:Integer;
  begin
     LineList := TLineList.Create(self);
     try
       For i := 0 To FlineList.Count - 1 Do
       Begin
        ThisLine := TReportLine(FlineList[i]);
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
begin
   LineList := Fill;
   H := H + LineList.TotalHeight;
   Result := LineList;
end;
function TReportRunTime.HeaderHeight:integer;
var
  LineList:TLineList;
  i,j:integer;
  ThisLine, Line: TReportLine;
  ThisCell, NewCell: TReportCell;
  function Fill:TLineList;
  var i,j:Integer;
  begin
     LineList := TLineList.Create(self);
     try
       For i := 0 To FlineList.Count - 1 Do
       Begin
        ThisLine := TReportLine(FlineList[i]);
        if Not ThisLine.IsDetailLine then
        begin
          Line := TReportLine.Create;
          LineList.Add(Line);
          CloneLine(ThisLine,Line);
        end;
       End;
     finally
       result :=   LineList ;
     end;
  end;
begin
   LineList := Fill;
   try
     Result := LineList.TotalHeight;
   finally
     LineList.Free;
   end;
end;

function TReportRunTime.GetHasDataPosition(var HasDataNo,cellIndex:integer):Boolean;
Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  Dataset: TDataset;
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
    End;                                //for j
  End;
end;
function TReportRunTime.FillFootList(var nHootHeight:integer ):TLineList;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
begin
  HootLineList := TLineList.Create(self);
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
      NewCell := TReportCell.Create(Self);
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      setnewcell( newcell, thiscell);
    End;
    If (UpperCase(copy(ThisCell.FCellText, 1, 7)) <> '`SUMALL') Then
    Begin
      TempLine.UpdateLineHeight;
      nHootHeight := nHootHeight + TempLine.GetLineHeight;
    End;
  End;
  result := HootLineList;
end;
function TReportRunTime.FooterHeight:integer;
Var
  I, J, n,  TempDataSetCount:Integer;
  HootLineList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  nHootHeight:integer;
begin
  nHootHeight := 0 ;
  HootLineList := TLineList.Create(Self);
  try
    For i := HasDataNo + 1 To FlineList.Count - 1 Do
    Begin
      ThisLine := TReportLine(FlineList[i]);
      if not ThisLine.IsSumAllLine then
      begin
        TempLine := TReportLine.Create;
        CloneLine(ThisLine,TempLine);
        HootLineList.Add(TempLine);
      end;
    End;
    result := HootLineList.TotalHeight;
  except
    HootLineList.Free;
  end;
end;

//将有合计的行(`SumAll)存入一个列表中
function TReportRunTime.FillSumList(var nSumAllHeight:integer ):TLineList;
Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  Dataset: TDataset;
begin
  nSumAllHeight := 0;
  sumAllList := TLineList.Create(Self);
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
      NewCell := TReportCell.Create(Self);
      TempLine.FCells.Add(NewCell);
      NewCell.FOwnerLine := TempLine;
      setnewcell( newcell, thiscell);
    End;                              //for j
    TempLine.UpdateLineHeight;
    nSumAllHeight := nSumAllHeight + TempLine.GetLineHeight;
  End;
  result :=  sumAllList;
end ;
function TReportRunTime.SumHeight:Integer;
Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  Dataset: TDataset;
  nSumAllHeight:integer;
begin
  nSumAllHeight := 0;
  sumAllList := TLineList.Create(Self);
  For i := HasDataNo + 1 To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    TempLine := TReportLine.Create;
    sumAllList.Add(TempLine);
    CloneLine(ThisLine,TempLine);
    TempLine.UpdateLineHeight;
  End;            
  result := sumAllList.TotalHeight;
  sumAllList.Free;
end ;
procedure TReportRunTime.PaddingEmptyLine(hasdatano:integer; var dataLineList:TLineList;var ndataHeight:integer);
var
  thisline,templine : Treportline ;
begin
      thisline := Treportline(FLineList[hasdatano]);
      templine := CloneEmptyLine(thisLine);
      While true Do
      Begin
        dataLineList.Add(templine);
        TempLine.UpdateLineHeight;
        ndataHeight := ndataHeight + templine.GetLineHeight;
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
 
function TReportRunTime.AppendList( l1, l2:TList):Boolean;var n :integer; begin
    For n := 0 To l2.Count - 1 Do
      l1.Add(l2[n]);
    result := true;
end;
function TReportRunTime.ExpandLine(var HasDataNo,ndataHeight:integer):TReportLine;
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
    setnewcell( newcell, thiscell);
  End; //for j
  TempLine.UpdateLineHeight;
  ndataHeight := ndataHeight + TempLine.GetLineHeight;
  result := TempLine;
end;
function TReportRunTime.RenderLineHeight(HasDataNo:integer):Integer;
var
  thisLine ,TempLine: TReportLine;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisCell, NewCell: TReportCell;
  ndataHeight:integer;
begin
  ThisLine := TReportLine(FlineList[HasDataNo]);
  TempLine := TReportLine.Create;
  CloneLine(ThisLine,TempLine);
  ndataHeight := 0;
  inc(ndataHeight ,TempLine.GetLineHeight);
  result := ndataHeight;
end;
procedure TReportRunTime.SumLine(var HasDataNo:integer);
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
// todo:NextStep --> Iam tired ,have a rest
procedure TReportRunTime.PreparePrintk(FpageAll: integer);
Var
  CellIndex,I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TLineList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  
  procedure NoDataPage;
  begin
    AppendList(  FPrintLineList, HandLineList);
    UpdatePrintLines;
    SaveTempFile( ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
  end;
  procedure DataPage;
  Var
    n :Integer;
  Begin
    Dataset := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
    TempDataSetCount := Dataset.RecordCount;
    Dataset.First;
    HootLineList := FillFootList(nHootHeight);
    sumAllList := FillSumList(nSumAllHeight);
    ndataHeight := 0;
    dataLineList := TLineList.Create(Self);
    i := 0;                                      
    While (i < TempDataSetCount) Do
    Begin
      TempLine := ExpandLine(HasDataNo,ndataHeight);
      If isPageFull Then
      Begin
        If dataLineList.Count = 0 Then
          raise Exception.create('表格未能完全处理,请调整单元格宽度或页边距等设置');
        FhootNo := HandLineList.Count+dataLineList.Count ;
        JoinAllList(FPrintLineList, HandLineList,dataLineList,SumAllList,HootLineList,false);
        UpdatePrintLines;
        SaveTempFile(ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
        application.ProcessMessages;
        FSummer.ResetSumPage;
        fpagecount := fpagecount + 1;
        FPrintLineList.Clear;
        datalinelist.clear;
        ndataHeight := 0;
      End else begin
        DataLineList.add(tempLine);
        SumLine(HasDataNo);
        Dataset.Next;
        i := i + 1;
      end;
    End;
    // 都是  i =  TempDataSetCount，也看从那个分支出来的。
    if not IsPageFull then
    begin
      If (Faddspace) And (HasEmptyRoomLastPage) Then begin
        PaddingEmptyLine(hasdatano,dataLineList,ndataHeight );
      end;
      JoinAllList(FPrintLineList, HandLineList,dataLineList,SumAllList,HootLineList,True);
      UpdatePrintLines;
      SaveTempFile(ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
    end;
  End ;
  procedure FreeList;
  Var
    n :Integer;
  begin
    HootLineList.Free;
    dataLineList.free;
    FPrintLineList.Clear;
    For N := FDRMap.Count - 1 Downto 0 Do
      TDRMapping(FDRMap[N]).Free;
    FDRMap.Clear;
    HandLineList.free;
  end;
Begin
  try
    FSummer.ResetAll;
    Dataset := Nil;
    FhootNo := 0;
    nHandHeight := 0;                     //该页数据库行之前每行累加高度
    FpageCount := 1;                      //正处理的页数
    HasDataNo := 0;
    nHootHeight := 0;
    TempDataSetCount := 0;

    //将每页的表头存入一个列表中
    HandLineList := FillHeadList(nHandHeight);
    GetHasDataPosition(HasDataNo,CellIndex) ;
    If HasDataNo = -1 Then
      noDataPage
     else
     DataPage;        
    FreeList;
  except
    on E:Exception do
         MessageDlg(e.Message,mtInformation,[mbOk], 0);
  end;
End;

function TReportRunTime.GetDataSetFromCell(HasDataNo,CellIndex:Integer):TDataset;
begin
  result := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
end;
Function TReportRunTime.DoPageCount:integer;
Var
  CellIndex,I , RowCount:Integer;
Begin   
  try
    nHandHeight := 0;
    nHootHeight := 0;
    FpageCount := 1;
    HasDataNo := 0;
    GetHasDataPosition(HasDataNo,CellIndex) ;
    If HasDataNo <> -1 Then
    Begin
      FillHeadList(nHandHeight);
      FillFootList(nHootHeight);
      FillSumList(nSumAllHeight);
      Dataset := GetDataSetFromCell(HasDataNo,CellIndex);
      RowCount := Dataset.RecordCount;
      Dataset.First;
      ndataHeight := 0;
      i := 0;
      While (i < RowCount)  Do
      Begin
        ExpandLine(HasDataNo,ndataHeight);
        If isPageFull  Then
        Begin
          inc(FPagecount);
          ndataHeight := 0;
        End else begin
          Dataset.Next;
          i := i + 1;
        end;
      End;
    End ;
    result := FPagecount;
  except
    on E:Exception do
         MessageDlg(e.Message,mtInformation,[mbOk], 0);
  end;
End;


function TReportRunTime.GetPrintRange(var A,Z:Integer):boolean;
  var PrintDlg: TPrintDialog; I: Integer;
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
        a := printdlg.frompage;    //99.3.9
        z := printdlg.topage;        //99.3.9
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
			CheckError(printer.Printers.Count = 0 ,'未安装打印机');
			// 爱上会展：金丝楠梳，宁德老寿眉，六安瓜片，太平猴魁，汝瓷 2014-11-7 茶博会
			If IsDirectPrint Then
			Begin
			  REPmessform.show;
			  i := DoPageCount;
			  PreparePrintk( i);
        REPmessform.Close;
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
  i, HasDataNo: integer;
Begin
  Try
    If printer.Printers.Count <= 0 Then
    Begin
      DeleteAllTempFiles;
      Application.Messagebox('未安装打印机', '警告', MB_OK + MB_iconwarning);
      For I := FNamedDatasets.Count - 1 Downto 0 Do // add  
        TDataSetItem(FNamedDatasets[I]).Free;
      FNamedDatasets.clear;
      Exit;
    End
    Else
    Begin
      i := DoPageCount;
      REPmessform.show;
      PreparePrintk( i);
      REPmessform.Close;
      PreviewForm := TPreviewForm.Create(Self);
      PreviewForm.SetPreviewMode(bPreviewMode);
      PreviewForm.PageCount := FPageCount;

      PreviewForm.StatusBar1.Panels[0].Text := '第' +
        IntToStr(PreviewForm.CurrentPage) + '／' +
          IntToStr(PreviewForm.PageCount)
        + '页';

      PreviewForm.filename.Caption := ReportFile;
      PreviewForm.tag := HasDataNo;
      PreviewForm.ShowModal;
      PreviewForm.Free;
      DeleteAllTempFiles;
    End;
    //  for i:=0 to setdata.Count -1 do  // add  
    //      setpar(fase,setdata[i]); //参数设置
      //finally
  Except
    MessageDlg('形成报表时发生错误，请检查各项参数与模板设置等是否正确',
      mtInformation, [mbOk], 0);
    REPmessform.Close;
    For I := FNamedDatasets.Count - 1 Downto 0 Do  //删除数据库表名与模板CELL的对照列表,否则每次调用都要增加列表项
      TDataSetItem(FNamedDatasets[I]).Free;
    FNamedDatasets.clear;
    exit;
  End;
  For I := FNamedDatasets.Count - 1 Downto 0 Do  //删除数据库表名与模板CELL的对照列表,否则每次调用都要增加列表项
    TDataSetItem(FNamedDatasets[I]).Free;
  FNamedDatasets.clear;
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
    REPmessform.Close;
    PreviewForm.PageCount := FPageCount;
    PreviewForm.StatusBar1.Panels[0].Text := '第' +
      IntToStr(PreviewForm.CurrentPage) + '／' + IntToStr(PreviewForm.PageCount)
        +
      '页';
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



  shortdateformat := 'yyy-mm-dd';
  shorttimeformat := 'HH:MM:SS';
  If UpperCase(strVarName) = '`DATE' Then //日期
    Result := datetostr(date);

  If UpperCase(strVarName) = '`TIME' Then //时间
    Result := timetostr(time);

  If UpperCase(strVarName) = '`DATETIME' Then //日期时间
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

//调所需打印的报表文件

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


<<<<<<< HEAD
// todo : 需要一个好的express parser，以便把关闭的功能加上去
Function TReportRunTime.SetSumAllYg(fm, ss: String): String; //add
var
  Value :Integer;
  slice :StrSlice;
  s : string;
=======

Function TReportRunTime.SetSumAllYg(fm, ss: String): String; //add  
>>>>>>> parent of e1dec3e... todo : 闇�瑕佷竴涓ソ鐨別xpress parser锛屼互渚挎妸鍏抽棴鐨勫姛鑳藉姞涓婂幓
Begin
  slice := StrSlice.Create(ss);
  s := slice.Slice(slice.GoUntil('(')+1,slice.GoUntil(')')-1);
  try
   Value := strtoint(s) ;
   Result := FormatFloat(fm,FSummer.GetSumAll(Value));
  except
     Result := 'N/A';
  end;
End;

Function TReportRunTime.setSumpageYg(fm, ss: String): String;
var
  Value :Integer;
  slice :StrSlice;
  s : string;
Begin
  slice := StrSlice.Create(ss);
  s := slice.Slice(slice.GoUntil('(')+1,slice.GoUntil(')')-1);
  try
     Value := strtoint(s) ;
   Result := FormatFloat(fm,FSummer.GetSumPage(Value));
  except
     Result := 'N/A';
  end;

End;
Procedure TReportRunTime.SetAddSpace(Const Value: boolean);
Begin
  FAddSpace := Value;
End;


function TReportRunTime.EditReport(FileName:String):TReportControl;
begin
  result := TCreportform.EditReport(FileName);
end;
Procedure TReportRunTime.updatepage;
Var
  i: integer;
Begin
  ReportFile := reportfile;             //从新装入修改后的模版文件
  i := DoPageCount;
  REPmessform.show;                     //lzla2001.4.27
  PreparePrintk( i);
  REPmessform.Close;
  PreviewForm.PageCount := FPageCount;
  PreviewForm.StatusBar1.Panels[0].Text := '第' +
    IntToStr(PreviewForm.CurrentPage) + '／' + IntToStr(PreviewForm.PageCount) +
    '页';

End;
Procedure Register;
Begin

  RegisterComponents('CReport', [TReportRunTime]);

End;
{ RenderException }

constructor RenderException.Create;
begin
  self.message := '表格未能完全处理,请调整单元格宽度或页边距等设置';
end;

{ TSummer }

procedure TSummer.Acc(j: integer; value: real);
begin
   SumPage[j] := SumPage[j] + value;
   SumAll[j] :=   SumAll[j] + value;
end;

function TSummer.GetSumAll(i: integer): Real;
begin
    result := SumALL[i];
end;

function TSummer.GetSumPage(i: integer): Real;
begin
  If i < 0 Then
   raise Exception.Create('模板文件中`Sumpage()括号内参数不应为零');
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

{ StrUtil }

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
function CellField.ds : TDataset ;
begin
 result := FDs;
end;
function CellField.GetField() : TField ;
begin
 result := ds.fieldbyname(GetFieldName())
end;
function CellField.IsDataField(s:String):Boolean;
begin
  result :=  (Length(s) < 2) or
   ((s[1] <> '@') And (s[1] <> '#'));
   result := not result ;
end;

Function CellField.GetFieldName(): String;
Var
  I: Integer;
  bFlag: Boolean;
  s:StrSlice;
Begin
  If isDataField(FCellText) Then
    Result := StrSlice.DoSlice(FCellText,'.')
  else
    Result := '';
End;

function CellField.IsNumberField():Boolean;
begin
  result := ds.fieldbyname(GetFieldName()) Is tnumericField
end;
function CellField.IsNullField( ):Boolean;
begin
  result := ds.fieldbyname(GetFieldName()).isnull;
end;
function CellField.DataValue():Extended;
begin
    result := ds.fieldbyname(GetFieldName()).value ;
end;
constructor CellField.Create(CellText:String;ds:TDataset);
begin
  FCellText:= CellText;
  FDs :=ds
end;

function CellField.IsBlobField: Boolean;
begin
   result := ds.fieldbyname(GetFieldName()) Is Tblobfield
end;
end.
