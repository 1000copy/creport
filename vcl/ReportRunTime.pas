unit ReportRunTime;

interface
uses ReportControl,  Windows, Messages, SysUtils,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice,margin;
Procedure Register;

type
  RenderException =class(Exception)
  public
    constructor Create;
  end;
  TReportRunTime = Class(TReportControl)
  private
    function GetHeaderHeight: Integer;
    procedure CloneLine(ThisLine, Line: TReportLine);

    function PageMinHeight: Integer;
    function HeaderHeight: integer;
    function FooterHeight: integer;
    function SumHeight:integer;
    function ExpandLine(var HasDataNo, ndataHeight: integer): TReportLine;
    function PreparePrintk1(FpageAll: integer): integer;

  public
    //С�ƺͺϼ���,���40�е�Ԫ��,����ͳ�ƻ���ʱҪ����.
    SumPage, SumAll: Array[0..40] Of real;
    FFileName: Tfilename;
    FAddSpace: boolean;
    FSetData: TstringList;
    // ������������ֺ�ֵ�Ķ��ձ�
    FVarList: TList;
    //����Ҫ��ӡ��ĳһҳ������Ϣ
    FPrintLineList: TList;
    // ����ÿһҳ�кϲ���Ԫ��ǰ���ָ��
    FOwnerCellList: TList;
    FNamedDatasets: TList;
    FHeaderHeight: Integer;
    //�Ƿ��ӡȫ����¼��Ĭ��Ϊȫ��
    Fallprint: Boolean;
    // ��ҳ��
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

    Function LFindComponent(Owner: TComponent; Name: String): TComponent;

    Procedure SaveTempFile(FileName:string;PageNumber, Fpageall: Integer);

    Function setSumAllYg(fm, ss: String): String; //add lzl
    Function setSumpageYg(fm, ss: String): String; //add lzl

    Procedure LoadTempFile(strFileName: String);
    Procedure DeleteAllTempFiles;
    Procedure SetNewCell(spyn: boolean; NewCell, ThisCell: TReportCell);
    Procedure SetAddSpace(Const Value: boolean);
    procedure SetEmptyCell(NewCell, ThisCell: TReportCell);
    function HasEmptyRoomLastPage: Boolean;
    function IsLastPageFull: Boolean;
    function isPageFull: boolean;
    function CloneEmptyLine(thisLine: TReportLine): TReportLine;
    function FillHeadList(var H: integer): TList;
    function GetHasDataPosition(var HasDataNo,
      cellIndex: integer): Boolean;
    function AppendList(l1, l2: TList): Boolean;
    function FillFootList(var nHootHeight: integer): TList;
    function FillSumList(var nSumAllHeight: integer): TList;
    procedure JoinAllList(FPrintLineList, HandLineList, dataLineList,
      SumAllList, HootLineList: TList;IsLastPage:Boolean);
    procedure PaddingEmptyLine(hasdatano: integer; var dataLineList: TList;
      var ndataHeight: integer; var khbz: boolean);overload;
    procedure PaddingEmptyLine(hasdatano: integer;
      var ndataHeight: integer; var khbz: boolean);overload;
    function SumCell(ThisCell: TReportCell; j: Integer): Boolean;
    procedure SumLine(var HasDataNo: integer);
    function DoPageCount(): integer;
    function RenderLineHeight(HasDataNo:integer):Integer;
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
    Procedure ResetContent;
    Procedure PrintPreview(bPreviewMode: Boolean);
    function  EditReport (FileName:String):TReportControl;
    Function shpreview: boolean;        //��������Ԥ���й��ļ�
    Function PrintSET(prfile: String): boolean; //ֽ�ż��߾����ã�lzl
    Procedure updatepage;               //
    Function PreparePrintk(FpageAll: integer): integer;
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
  strFileDir: String;
Begin
     strFileDir := ExtractFileDir(Application.ExeName); //+ '\';
     If copy(strfiledir, length(strfiledir), 1) <> '\' Then
          strFileDir := strFileDir + '\';
     If FileExists(strFileDir + 'Temp\' + IntToStr(I) + '.tmp') Then
          LoadTempFile(strFileDir + 'Temp\' + IntToStr(I) + '.tmp');
End;

Procedure TReportRunTime.DeleteAllTempFiles;
Var
  strFileDir: String;
Begin
  strFileDir := ExtractFileDir(Application.ExeName);
  If copy(strfiledir, length(strfiledir), 1) <> '\' Then
    strFileDir := strFileDir + '\';

  If Not DirectoryExists(strFileDir + 'Temp') Then
    Exit;
  os.DeleteFiles(strFileDir + 'Temp', '*.tmp');
  Try
    RmDir(strFileDir + 'Temp');
  Except
  End;
End;
function TReportRunTime.ReadyFileName(PageNumber, Fpageall: Integer):String;
Var
  strFileDir: String;
  FileName: String;

begin
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
  result := FileName;
end;
function TReportRunTime.RenderText(ThisCell:TReportCell;PageNumber, Fpageall: Integer):String;
var
  celltext : String;
begin
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
      celltext := trim(setSumpageYg(thiscell.FCellDispformat,
        ThisCell.FCellText));
    End
    Else If copy(UpperCase(ThisCell.FCellText), 1, 8) = '`SUMALL(' Then  //lzl ��
    Begin
        celltext := setSumAllYg(thiscell.FCellDispformat,
          ThisCell.FCellText);
    End Else
        celltext := ThisCell.FCellText;
    Result := celltext;
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
  FAddspace := false;
  FReportScale := 100;
  Width := 0;
  Height := 0;             
  fallprint := true;                    //Ĭ��Ϊȫ����ӡ
  FSetData := Tstringlist.Create;
  FNamedDatasets := TList.Create;
  FVarList := TList.Create;
  FPrintLineList := TList.Create;
  FOwnerCellList := TList.Create;

  repmessForm := TrepmessForm.Create(Self); //  lzl 

  FHeaderHeight := 0;

  If FFileName <> '' Then
    LoadReport;
End;

{�������}

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

  FOwnerCellList.Free;

  Inherited Destroy;
End;

{���ݼ���ֵ}

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

      If Length(ThisCell.FCellText) > 0 Then  //�����ǰCELL���ַ����ж��Ƿ������ݼ�
      Begin
        If ThisCell.FCellText[1] = '#' Then
          bHasDataSet := True;
      End;
    End;
    If Not bHasDataSet Then
      //���û�����ݼ������ͷ�߶ȵ��ڱ�ͷ�߶ȼӵ�ǰ�и߶�
      FHeaderHeight := FHeaderHeight + ThisLine.LineHeight;
  End;
  result := FHeaderHeight;
end;
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
//    FDragCellHeight := ThisCell.FDragCellHeight;
//    FDragCellHeight := 0;
    FCellHeight := ThisCell.FCellHeight;
//    FCellHeight := 0;
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
        If Dataset.fieldbyname(GetFieldName(ThisCell.CellText)) Is
          tnumericField Then
        Begin
          If thiscell.CellDispformat <> '' Then
          Begin
            If Not
              Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).isnull
                Then
              cellText := formatfloat(thiscell.FCellDispformat,
                Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).value);
          End
          Else
            CellText :=
              Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).displaytext;
        End
        Else If Dataset.fieldbyname(GetFieldName(ThisCell.CellText)) Is
          Tblobfield Then
        Begin
          If Not Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).isnull
            Then
          Begin
            //if fbmp = nil then
            fbmp := TBitmap.create;
            FBmp.Assign(Dataset.fieldbyname(GetFieldName(ThisCell.CellText)));
            FbmpYn := true;
          End
          Else
            CellText := '';
        End
        Else

          CellText :=
            Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).displaytext

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
        TempOwnerCell.Own(NewCell);
    End;

    If ThisCell.FSlaveCells.Count > 0 Then
    Begin
      // ���Լ����뵽���ձ���ȥ
      TempCellTable := TCellTable.Create;
      TempCellTable.PrevCell := ThisCell;
      TempCellTable.ThisCell := NewCell;
      FOwnerCellList.Add(TempCellTable);
    End;

    CalcHeight;
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
    SetNewCell(false, newcell, thiscell);
  End;
  Line.UpdateLineHeight;  
end;
function TReportRunTime.FillHeadList(var H:integer):TList;
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
  khbz: boolean;
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
        NewCell := TReportCell.Create(Self);
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
        setnewcell(false, newcell, thiscell);
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
  khbz: boolean;
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

  //���кϼƵ���(`SumAll)����һ���б���
  function TReportRunTime.FillSumList(var nSumAllHeight:integer ):TList;
  Var
  I, J, n,  TempDataSetCount:Integer;
  HandLineList, datalinelist, HootLineList, sumAllList: TList;
  ThisLine, TempLine: TReportLine;
  ThisCell, NewCell: TReportCell;
  Dataset: TDataset;
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
        NewCell := TReportCell.Create(Self);
        TempLine.FCells.Add(NewCell);
        NewCell.FOwnerLine := TempLine;
        setnewcell(false, newcell, thiscell);
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
  khbz: boolean;
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
  procedure TReportRunTime.PaddingEmptyLine(hasdatano:integer; var dataLineList:TList;var ndataHeight:integer;var khbz :boolean);
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
          TempLine.UpdateLineHeight;
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
            If Dataset.fieldbyname(GetFieldName(ThisCell.CellText)) Is
              tnumericField Then
              If Not
                (Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).IsNull)
                  Then
              Begin
                SumPage[j] := SumPage[j] +
                  Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).Value;
                SumAll[j] := SumAll[j] +
                  Dataset.fieldbyname(GetFieldName(ThisCell.CellText)).Value;
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
var
  thisLine ,TempLine: TReportLine;
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
    NewCell := TReportCell.Create(Self);
    TempLine.FCells.Add(NewCell);
    NewCell.FOwnerLine := TempLine;
    setnewcell(false, newcell, thiscell);
    //SumCell(ThisCell,j) ;
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
  khbz: boolean;
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
// todo:NextStep --> Iam tired ,have a rest 
Function TReportRunTime.PreparePrintk(FpageAll: integer):
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
  Dataset := Nil;
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
    SaveTempFile( ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
  End else
  Begin
    Dataset := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
    TempDataSetCount := Dataset.RecordCount;
    Dataset.First;
    HootLineList := FillFootList(nHootHeight);
//    GetNhasSumALl();//
    sumAllList := FillSumList(nSumAllHeight);
    //dataLineList := FillDataList(ndataHeight,khbz);

    ndataHeight := 0;
    dataLineList := TList.Create;
    i := 0;


//        While (i <= TempDataSetCount) Or (Not Dataset.eof) Do
//        =====
//        While (i <= TempDataSetCount) Do
//        so "(Not Dataset.eof)" is nonsense
    //While (i <= TempDataSetCount) Or (Not Dataset.eof) Do
//  �Ƿ���Թʼ����ݣ�
//     i <= TempDataSetCount ������飬һ�� i < TempDataSetCount ,һ�� i = TempDataSetCount
    While (i < TempDataSetCount) Do
    Begin
      TempLine := ExpandLine(HasDataNo,ndataHeight);
      If isPageFull Then
      Begin
        If dataLineList.Count = 0 Then
          raise Exception.create('���δ����ȫ����,�������Ԫ���Ȼ�ҳ�߾������');
        FhootNo := HandLineList.Count+dataLineList.Count ;
        JoinAllList(FPrintLineList, HandLineList,dataLineList,SumAllList,HootLineList,i = TempDataSetCount);
        UpdatePrintLines;
          SaveTempFile(ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
          application.ProcessMessages;
        For n := 0 To 40 Do
          SumPage[n] := 0;
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
    While (i = TempDataSetCount) Do
    Begin
      If (Faddspace) And (HasEmptyRoomLastPage) Then begin
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
          SaveTempFile(ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
          application.ProcessMessages;
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
        Dataset.Next;
        i := i + 1;
      end;         
    End;  
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
    result := HasDataNo
  except
    on E:Exception do
         MessageDlg(e.Message,mtInformation,[mbOk], 0);
  end;
End;
Function TReportRunTime.PreparePrintk1(FpageAll: integer):
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
  Dataset := Nil;
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
    SaveTempFile( ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
  End else
  Begin
    Dataset := GetDataSet(TReportCell(TReportLine(FlineList[HasDataNo]).FCells[CellIndex]).FCellText);
    TempDataSetCount := Dataset.RecordCount;
    Dataset.First;
    HootLineList := FillFootList(nHootHeight);
//    GetNhasSumALl();//
    sumAllList := FillSumList(nSumAllHeight);
    //dataLineList := FillDataList(ndataHeight,khbz);

    ndataHeight := 0;
    dataLineList := TList.Create;
    i := 0;


//        While (i <= TempDataSetCount) Or (Not Dataset.eof) Do
//        =====
//        While (i <= TempDataSetCount) Do
//        so "(Not Dataset.eof)" is nonsense
    //While (i <= TempDataSetCount) Or (Not Dataset.eof) Do
//  �Ƿ���Թʼ����ݣ�
//     i <= TempDataSetCount ������飬һ�� i < TempDataSetCount ,һ�� i = TempDataSetCount
    While (i <= TempDataSetCount) Do
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
          SaveTempFile(ReadyFileName(fpagecount, Fpageall),fpagecount, FpageAll);
          application.ProcessMessages;
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
        Dataset.Next;
        i := i + 1;
      end;         
    End;  
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
    result := HasDataNo
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
//IsDirectPrint  ��true , �����Ƿ�ֱ�Ӵ�ӡ ,false ��ʾ��Ԥ��UI�е��ô�ӡ
Procedure TReportRunTime.Print(IsDirectPrint: Boolean);
Var
  I: Integer;
  strFileDir: TFileName;
  frompage, topage: integer;
Begin
	try
		Try
			CheckError(printer.Printers.Count = 0 ,'δ��װ��ӡ��');
			// ���ϻ�չ����˿��ᣬ��������ü��������Ƭ��̫ƽ�������� 2014-11-7 �販��
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
 //LCJ: ��ֱ�ӻ���Ԥ���е������ô�ӡ����
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
      Application.Messagebox('δ��װ��ӡ��', '����', MB_OK + MB_iconwarning);
      For I := FNamedDatasets.Count - 1 Downto 0 Do // add lzl
        TDataSetItem(FNamedDatasets[I]).Free;
      FNamedDatasets.clear;
      Exit;
    End
    Else
    Begin
      i := DoPageCount;
      REPmessform.show;
      HasDataNo := PreparePrintk( i);
      REPmessform.Close;
      PreviewForm := TPreviewForm.Create(Self);
      PreviewForm.SetPreviewMode(bPreviewMode);
      PreviewForm.PageCount := FPageCount;

      PreviewForm.StatusBar1.Panels[0].Text := '��' +
        IntToStr(PreviewForm.CurrentPage) + '��' +
          IntToStr(PreviewForm.PageCount)
        + 'ҳ';

      PreviewForm.filename.Caption := ReportFile;
      PreviewForm.tag := HasDataNo;
      PreviewForm.ShowModal;
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
    For I := FNamedDatasets.Count - 1 Downto 0 Do  //ɾ�����ݿ������ģ��CELL�Ķ����б�,����ÿ�ε��ö�Ҫ�����б���
      TDataSetItem(FNamedDatasets[I]).Free;
    FNamedDatasets.clear;
    exit;
  End;
  For I := FNamedDatasets.Count - 1 Downto 0 Do  //ɾ�����ݿ������ģ��CELL�Ķ����б�,����ÿ�ε��ö�Ҫ�����б���
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
  FNamedDatasets.Add(TempItem);
  //ע:���TReportRunTime���𣬶��ֲ��ϵ���SetDataset
  //�б����ظ�����,���,���󽫻����..Ŀǰ����Ԥ���ʹ�ӡ�����ա�������
  //���޸��ð취?������. lzl .
  // LCJ:����ǰ��������Ϳ����ˡ�ɵ�ơ�
  // ����˼���Ĵ��룬10�ɵ�Ҫɾ��9.9�ɡ����²����������
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
  // ���ȼ���ϲ���ĵ�Ԫ��
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

  // ����ÿ�еĸ߶�
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
  //   add by wang han song 1999.03.05
  FNamedDatasets.clear;
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
  ReportFile := reportfile;             //����װ���޸ĺ��ģ���ļ�
  i := DoPageCount;
  REPmessform.show;                     //lzla2001.4.27
  PreparePrintk( i);
  REPmessform.Close;
  PreviewForm.PageCount := FPageCount;
  PreviewForm.StatusBar1.Panels[0].Text := '��' +
    IntToStr(PreviewForm.CurrentPage) + '��' + IntToStr(PreviewForm.PageCount) +
    'ҳ';

End;
Procedure Register;
Begin

  RegisterComponents('CReport', [TReportRunTime]);

End;
{ RenderException }

constructor RenderException.Create;
begin
  self.message := '���δ����ȫ����,�������Ԫ���Ȼ�ҳ�߾������';
end;

end.
