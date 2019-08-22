// holiday of Spring Day is coming . workmate is playing ,so noise . so now it is time to go home
unit ReportRunTime;

interface
uses ureport,  Windows, Messages, SysUtils,
  {$WARNINGS OFF}FileCtrl,{$WARNINGS ON}
   Classes, Graphics, Controls,
  Forms, Dialogs, Printers, Menus, Db,
  DesignEditors, ExtCtrls,osservice,cc;
Procedure Register;


type
  RenderParts =class ;
   TSummer = class
     SumPage, SumAll: Array[0..40] Of real;
   public
     procedure Acc(j:integer;value:real);
     procedure ResetSumPage;
     procedure ResetAll;
     function GetSumAll(i:integer):Real;
     function GetSumPage(i:integer):Real;
   end;
  TDataList = class(TList)
  private
    procedure ClearDataset;
    procedure SetDataset(strDatasetName: String; pDataSet: TDataSet);
    procedure SetData(M, D: TDataSet);
    function DatasetByName(strDatasetName: String): TDataset;
  public
   procedure FreeItems;
  end;
  RenderException =class(Exception)
  public
    constructor Create;
  end;
  //bridge for LineList -> PrintLineList
  TReportRunTime = Class(TReportControl)
  private
    FRender:RenderParts ;
    FSummer:TSummer;
    FFileName: Tfilename;
    FAddSpace: boolean;
    FVarList: TVarList;
    FPrintLineList: TLineList;
    FDRMap: TDRMappings;
    FPageIndex: Integer;
    FpageAll: integer ;
    FDataLineHeight: Integer;
    //dataset concerns
    FNamedDatasets: TDataList;
    function GetDetailDataset(): TDataset;
    Function GetDataset(strCellText: String): TDataset;
  private
    // height calc..er
    function FooterHeight():integer;
    function SumHeight():integer;
    function HeadHeight: integer;
    function IsLastPageFull: Boolean;
    function isPageFull(DataLineHeight:Integer): boolean;
    function HasEmptyRoomLastPage: Boolean;
  private
    // Line copy
    procedure CloneLine(ThisLine, Line: TReportLine);
    function ExpandLine(HasDataNo:integer):TReportLine;
    function CloneEmptyLine(thisLine: TReportLine): TReportLine;
    function CloneNewLine(ThisLine: TReportLine): TReportLine;
  private
    // var
    function GetValue(ThisCell: TReportCell): String;
    Function GetVarValue(strVarName: String): String;
  private
    // file
    Procedure SetReportFileName(Const Value: TFilename);
    Procedure SaveTempFile(FileName:string);overload;
    Procedure SaveCurrentPage();overload;
    Procedure LoadReport;
    Procedure LoadTempFile(strFileName: String);
    function ReadyFileName(PageNumber: Integer): String;
    Procedure DeleteAllTempFiles;
//    procedure LoadPage(I: integer);
  private
    // sum
    Function setSumAllYg(fm, ss: String): String;
    Function setSumpageYg(fm, ss: String): String;
    procedure SumCell(ThisCell: TReportCell; j: Integer);
    procedure SumLine(HasDataNo: integer);
  private
    // list
    function AppendList(l1, l2: TList): Boolean;
    function FillFootList(): TList;
    function FillSumList(): TLineList;
    procedure JoinAllList(FPrintLineList, HandLineList, dataLineList,
    SumAllList, HootLineList: TList;IsLastPage:Boolean);
  private
    // todo
    function IsDataField(s: String): Boolean;
    function getDataLineHeight(): integer;
    function DetailCellIndex(NO:integer) :Integer;
    procedure DataPage();
    procedure FreeList;
    Procedure UpdateLines;
    Procedure UpdatePrintLines;
    Procedure PrintOnePage;
    Function GetFieldName(strCellText: String): String;

    Procedure CloneCell(NewCell, ThisCell: TReportCell);
    procedure CloneEmptyCell(NewCell, ThisCell: TReportCell);
    function DetailLineIndex:Integer;
    procedure PaddingEmptyLine(hasdatano: integer; var dataLineList: TLineList);overload;
    function GetPrintRange(var A, Z: Integer): boolean;
    procedure PrintRange(Title: String; FromPage, ToPage: Integer);
  // render : what 's diference on RenderText vs . RenderTextOnly vs. RenderCell ?
  Protected
    function RenderText(ThisCell: TReportCell): String;override;
  private
    procedure RenderCell(NewCell,ThisCell:TReportCell);
    procedure RenderBlobOnly(NewCell, ThisCell: TReportCell);
    procedure RenderTextOnly(NewCell, ThisCell: TReportCell);
    procedure pp(preview: boolean);
    procedure eachcell_paint(ThisCell: TReportCell);

  Public
    function calcPageCount(): integer;
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetVarValue(strVarName, strVarValue: String);
    Procedure PrintPreview();
    function  EditReport :TReportControl;overload;
    function  EditReport (FileName:String):TReportControl;overload;
    Function shpreview: boolean;
    Function PrintSET(prfile: String): boolean;
    Procedure updatepage;
    procedure PreparePrintFiles();
    Procedure Print();
    Procedure Resetself;
    Function Cancelprint: boolean;
    Property ReportFile: TFilename Read FFileName Write SetReportFileName;

    Published
    Property AddSpace: boolean Read FAddSpace Write FAddSpace;
    // TEST section
    Published
    function FillHeadList: TList;
    procedure SetData(M,D:TDataSet);
    End;
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
    procedure SaveLastPage(fpagecount, FpageAll: Integer);
    procedure FillFixParts;
    procedure Reset;
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
     procedure SimplePage;
  end;

implementation

Uses
  Preview, REPmess, Creport,margin;


Procedure TReportRunTime.DeleteAllTempFiles;
Var
  tempDir: String;
Begin                             
  Try
    tempDir := Format('%s\temp\',[AppDir]);
    If Not DirectoryExists(tempDir) Then
      Exit;
//    os.DeleteFiles(tempDir, '*.tmp.json');
//    RmDir(tempDir);
  Except
  End;
End;
function TReportRunTime.ReadyFileName(PageNumber: Integer):String;
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
function TReportRunTime.RenderText(ThisCell:TReportCell):String;
var
  R : String;
  PageNumber: Integer ;
begin
  PageNumber := FPageIndex;
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

Procedure TReportRunTime.SaveCurrentPage();
begin
   SaveTempFile(ReadyFileName(FPageIndex+1));
end;
Procedure TReportRunTime.SaveTempFile(FileName: String);
begin
  SaveToJson1(FileName+'.json',FPrintLineList);
end;

Procedure TReportRunTime.LoadTempFile(strFileName: String);
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
  FRender := RenderParts.Create(Self);
  FSummer:=TSummer.Create;
  FAddspace := false;
  FReportScale := 100;
  Width := 0;
  Height := 0;
  FNamedDatasets := TDataList.Create;
  FVarList := TVarList.Create;
  FPrintLineList := TLineList.Create(self);
  FDRMap := TDRMappings.Create;
  repmessForm := TrepmessForm.Create(Self);
  //FHeaderHeight := 0;
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
  if FPrintLineList <> FlineList then
    FPrintLineList.Free;
  FDRMap.Free;
  FSummer.Free;
  FRender.Free ;
  Inherited Destroy;
End;


Function TReportRunTime.GetDataset(strCellText: String): TDataset;
  Function GetDatasetName(strCellText: String): String;
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
Begin
  Result := FNamedDatasets.DatasetByName(GetDatasetName(strCellText));
End;
function TReportRunTime.IsDataField(s:String):Boolean;
begin
  result :=  (Length(s) < 2) or
   ((s[1] <> '@') And (s[1] <> '#'));
   result := not result ;
end;

//testcase  t1.lb ->  t1

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

Begin
  try
    if endsWith(FFileName,'.json') then
      loadFromJson(FFileName)
    else
      InternalLoadFromFile(FFileName,FLineList);
    PrintPaper.Batch(FprPageNo,FprPageXy,fpaperLength,fpaperWidth);
    UpdateLines;
  except
    on E:Exception do ShowMessage(e.message);
    end;
End;


Procedure TReportRunTime.CloneEmptyCell(NewCell, ThisCell:TReportCell);
Begin
  NewCell.CloneFrom(ThisCell);
  NewCell.CellText := '';
  NewCell.FLogFont := ThisCell.FLogFont;
  FDRMap.RuntimeMapping(NewCell, ThisCell);
  NewCell.CalcHeight;
End;

//  ���� ,��ȫ��д�� PreparePrint,���������ÿ��в���һҳ ͳ�Ƶȹ���
//������������Ԥ����ȷ��������ͷ���ݿ�����ģ��ĵڼ���
function TReportRunTime.IsLastPageFull:Boolean ;
begin
  result := (FtopMargin + HeadHeight + FDataLineHeight + SumHeight +
          FBottomMargin) > height;
end;
function TReportRunTime.isPageFull(DataLineHeight:Integer):boolean;
begin
  result := (FtopMargin + HeadHeight + DataLineHeight + FooterHeight + FBottomMargin >height);
end;
function TReportRunTime.HasEmptyRoomLastPage:Boolean;
begin
  result := FtopMargin + HeadHeight +
      FDataLineHeight +
      SumHeight + FBottomMargin < height;
end;

function TReportRunTime.AppendList( l1, l2:TList):Boolean;var n :integer; begin
    For n := 0 To l2.Count - 1 Do
      l1.Add(l2[n]);
    result := true;
end;



function TReportRunTime.GetPrintRange(var A,Z:Integer):boolean;
var
  PrintDlg: TPrintDialog; I: Integer;
begin
  PrintDlg := TPrintDialog.Create(Self);
  PrintDlg.MinPage := 1;
  PrintDlg.MaxPage := FPageAll;
  PrintDlg.FromPage := 1;
  PrintDlg.ToPage := FPageAll;
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
Procedure TDataList.ClearDataset();
Var
  I: Integer;
begin
   For I := Count - 1 Downto 0 Do
    TDataSetItem(Self[I]).Free;
   Self.clear;
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
Procedure TReportRunTime.PrintPreview();
Begin
  pp(true)
End;
Procedure TReportRunTime.Print();
Begin
  pp(false)
End;
Procedure TReportRunTime.pp(preview:boolean);
Var
  I: Integer;
  strFileDir: TFileName;
  frompage: integer;
Begin
  If printer.Printers.Count <= 0 Then begin
    Application.Messagebox(cc.ErrorPrinterSetupRequired, '', MB_OK + MB_iconwarning);
    exit;
  end;
  Try
        REPmessform.show;
        FpageAll := calcPageCount;
        PreparePrintFiles( );
        REPmessform.Hide;
        FromPage := 1;
        if not preview then begin
          if GetPrintRange(frompage,FPageAll) then 
            PrintRange('CReport',Frompage,FPageAll);
        end
        else
            TPreviewForm.Action(ReportFile,FPageAll);
        DeleteAllTempFiles;
    Except
      on E:Exception do MessageDlg(e.Message,mtInformation, [mbOk], 0);
    End;
End;
//Procedure TReportRunTime.eachCell(proc:eachCellProc);
//Var
//  ThisLine: TReportLine;
//  ThisCell: TReportCell;I, J: Integer;
//Begin
//  FPrintLineList := FLineList;
//  If FPrintLineList.Count <= 0 Then
//    Exit;
//  For I := 0 To FPrintLineList.Count - 1 Do
//  Begin
//    ThisLine := TReportLine(FPrintLineList[I]);
//    For J := 0 To ThisLine.FCells.Count - 1 Do
//    Begin
//      ThisCell := TReportCell(ThisLine.FCells[J]);
//      proc(thiscell);
//    End;
//  End;
//End;
procedure TReportRunTime.eachcell_paint(ThisCell:TReportCell);
Var
  hPrinterDC: HDC;
  I, J: Integer;
  ThisLine: TReportLine;
  PageSize: TSize;
  Ltemprect: tRect;
  FPrintLineList : TLineList;
begin
hPrinterDC := Printer.Handle;
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

end;
Procedure TReportRunTime.PrintOnePage;
Var
  hPrinterDC: HDC;
  I, J: Integer;
  ThisLine: TReportLine;
  ThisCell: TReportCell;
  PageSize: TSize;
  Ltemprect: tRect;
  FPrintLineList : TLineList;

Begin
  If FLineList.Count <= 0 Then
    Exit;
  MapDevice(Printer,Width, Height);
  eachcell(eachcell_paint);
  FDRMap.empty;
End;
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



Function TReportRunTime.shpreview: boolean;
Var
  i: integer;
Begin
  If PrintSET(reportfile)  Then
  Begin
    ReportFile := reportfile; 
    FpageAll := calcPageCount;
    REPmessform.show;
    PreparePrintFiles( );
    REPmessform.Hide;
    PreviewForm.PageCount := FPageAll;
    PreviewForm.updateStatus;
    result := true;
  End
  Else
    result := false;
End;

Procedure TDataList.SetDataset(strDatasetName: String; pDataSet: TDataSet);
Var
  TempItem: TDatasetItem;
  dk, i: integer;
Begin
  TempItem := TDatasetItem.Create;
  TempItem.pDataset := pDataSet;
  TempItem.strName := UpperCase(strDataSetName);
  Self.Add(TempItem);
End;

Procedure TReportRunTime.SetReportFileName(Const Value: TFilename);
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
  FpageAll := calcPageCount;
  REPmessform.show;
  PreparePrintFiles();
  REPmessform.Hide;
  PreviewForm.PageCount := FPageAll;
  PreviewForm.updateStatus;
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

// TODO :���´��붼�úúø��¡�
function TReportRunTime.GetValue(ThisCell:TReportCell):String;
var
    cellText ,FieldName:string;
    cf: DataField ;
    Dataset:TDataset;
    function IsDataField(s:String):Boolean;
    begin
      result :=  (Length(s) < 2) or
       ((s[1] <> '@') And (s[1] <> '#'));
       result := not result ;
    end;

begin
  CellText := ThisCell.FCellText;
  FieldName := GetFieldName(CellText);
  Dataset := GetDataset(thisCell.CellText);
  cf:= DataField.Create(Dataset,FieldName) ;
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

  procedure TReportRunTime.RenderCell(NewCell,ThisCell:TReportCell);
begin
  RenderTextOnly(NewCell,ThisCell);
  RenderBlobOnly(NewCell,ThisCell);
end;
procedure TReportRunTime.RenderTextOnly(NewCell,ThisCell:TReportCell);
var
    Result,Value,cellText ,FieldName:string;
    cf: DataField ;
    Dataset:TDataset;
   function IsFormatable:Boolean;
   begin
     Result := cf.IsAvailableNumberField and (ThisCell.CellDispformat <> '' )  
   end;
begin
  try
    CellText := ThisCell.FCellText ;
    if (Thiscell.IsSimpleField ) then
    begin
      Result := CellText;
      exit;
    end;
    If ThisCell.IsFormula Then
    begin
      Result := GetVarValue(CellText) ;
      Exit;
    end;
    if GetDataset(CellText) = nil then
    begin
      Result := CellText;
      exit;
    end;
    FieldName := GetFieldName(CellText);
    Dataset := GetDataset(thisCell.CellText);
    cf:= DataField.Create(Dataset,FieldName) ;
    If  cf.IsBlobField  and (not cf.IsNullField) then
    begin
       Result := '';
       exit;
    end;
    try
      Value :=cf.GetField.AsString ;
      If IsFormatable Then
        Value :=  ThisCell.FormatValue(cf.DataValue()) ;
      result := Value;
      if '(Graphic)' =  CellText then
        raise Exception.create('');
    finally
      cf.Free;      
    end;
  finally
   NewCell.CellText:= Result ;
  end;
end;

procedure TReportRunTime.RenderBlobOnly(NewCell,ThisCell:TReportCell);
var
    Value,cellText ,FieldName:string;
    cf: DataField ;
    Dataset:TDataset;
begin
  CellText := ThisCell.FCellText;
  FieldName := GetFieldName(CellText);
  Dataset := GetDataset(thisCell.CellText);
  cf:= DataField.Create(Dataset,FieldName) ;
  try
    If ThisCell.IsHeadField Then
    Begin
      If cf.IsBlobField then
      begin
         NewCell.LoadCF(cf);
      end;
    End
    Else If  thisCell.IsDetailField Then
    Begin
      If cf.IsBlobField then
      begin
         NewCell.LoadCF(cf);
      end
    End
  finally
    cf.Free;
  end;
end;

Procedure TReportRunTime.CloneCell(NewCell, ThisCell:
  TReportCell);
Begin
  NewCell.CloneFrom(ThisCell);
  RenderCell(newCell,ThisCell);
  NewCell.FLogFont := ThisCell.FLogFont;
  FDRMap.RuntimeMapping(NewCell, ThisCell);
  NewCell.CalcHeight;
End;

function TReportRunTime.CloneEmptyLine(thisLine:TReportLine):TReportLine;
var j:integer; templine:treportline;
Var
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
    CloneEmptyCell(newcell, thiscell);
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
    CloneCell(newcell, thiscell);
  End;
  Line.UpdateLineHeight;  
end;
function TReportRunTime.CloneNewLine(ThisLine:TReportLine):TReportLine;
var
  LineList:TLineList;
  i,j:integer;
  ThisCell, NewCell: TReportCell;
  Line : TReportLine ;
begin
  Line := TReportLine.Create;
  Line.FMinHeight := ThisLine.FMinHeight;
  Line.FDragHeight := ThisLine.FDragHeight;
  For j := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    ThisCell := TreportCell(ThisLine.FCells[j]);
    NewCell := TReportCell.Create(Self);
    Line.FCells.Add(NewCell);
    NewCell.FOwnerLine := Line;
    CloneCell( newcell, thiscell);
  End;
  Line.UpdateLineHeight;
  result := Line;
end;


function TReportRunTime.HeadHeight:integer;
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
      CloneCell( newcell, thiscell);
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

//���кϼƵ���(`SumAll)����һ���б���
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
      CloneCell( newcell, thiscell);
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
      (Not GetDetailDataset().fieldbyname(FieldName).IsNull)
       and (GetDetailDataset().fieldbyname(FieldName) Is TNumericField) ;
  end;
Var
  FieldName : string;
  value : real;
begin
  Try
    FieldName := GetFieldName(ThisCell.CellText) ;
    if ThisCell.IsDetailField and IsFieldNumric(FieldName) then
    Begin
      value := GetDetailDataset().fieldbyname(FieldName).Value ;
      FSummer.Acc(j,Value);
    End;
  Except
    raise Exception.create('ͳ��ʱ������������ģ�������Ƿ���ȷ');
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
    CloneCell(newcell, thiscell);
  End; 
  TempLine.UpdateLineHeight;
  result := TempLine;
end;




function TReportRunTime.getDataLineHeight():integer;
var
  thisLine ,TempLine: TReportLine;
  I, J, n,  TempDataSetCount:Integer;
  ThisCell, NewCell: TReportCell;
begin
  // google:$Optimization on off insite: delphibasics.co.uk
  {$Optimization on}
  ThisLine := FlineList[DetailLineIndex];
  // painful side effects as follow 11 statements
  {*
  TempLine := TReportLine.Create;
  TempLine.FMinHeight := ThisLine.FMinHeight;
  TempLine.FDragHeight := ThisLine.FDragHeight;
  For j := 0 To ThisLine.FCells.Count - 1 Do
  Begin
    ThisCell := TreportCell(ThisLine.FCells[j]);
    NewCell := TReportCell.Create(Self);
    TempLine.FCells.Add(NewCell);
    NewCell.FOwnerLine := TempLine;
    NewCell.CloneFrom(ThisCell);
    FDRMap.RuntimeMapping(NewCell, ThisCell);
  End;
  *}
  Result := ThisLine.GetLineHeight;
  {$Optimization off}
end;


procedure TReportRunTime.SumLine(HasDataNo:integer);
var j:integer;var thisLine ,TempLine: TReportLine;
Var
  I,  n,  TempDataSetCount:Integer;
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
function TReportRunTime.GetDetailDataset() :TDataset;
var
   t : string;
begin
   t :=  Cells[ DetailLineIndex,DetailCellIndex(DetailLineIndex)].FCellText;
   result := GetDataSet(t);
end;

procedure TReportRunTime.DataPage();
Var
  I:Integer;
  Dataset:TDataset;
Begin
  dataset := GetDetailDataset();
  FRender.FillFixParts;
  FDataLineHeight := 0;
  i := 0;
  Dataset.First;
  While (i < Dataset.RecordCount) Do
  Begin
    i := FRender.FillPage (i);
    If isPageFull(FDataLineHeight) Then
    Begin
      CheckError(FRender.FData.Count = 0,cc.RenderException);
      FRender.SavePage(FPageIndex, FpageAll);
      FRender.Reset;
      inc(FPageIndex);
    End;
    application.ProcessMessages;
  End;
  if not IsPageFull(FDataLineHeight) then
  begin
    If (Faddspace) And (HasEmptyRoomLastPage) Then begin
      PaddingEmptyLine(DetailLineIndex,FRender.FData );
    end;
    FRender.SaveLastPage(FPageIndex, FpageAll);
  end; 
End ;
procedure TReportRunTime.FreeList;
Var
  n :Integer;
begin
  FPrintLineList.Clear;
  FDRMap.empty;
end;
procedure TReportRunTime.PreparePrintFiles();
Begin
    FSummer.ResetAll;
    If DetailLineIndex = -1 Then
       FRender.SimplePage
    else
     DataPage;
    FreeList;
End;
Function TReportRunTime.calcPageCount:integer;
Var
  I :Integer;
  DataLineHeight: Integer;
Begin
    Result := 1;
    If DetailLineIndex =  -1 Then
        exit ;
    GetDetailDataset().First;
    DataLineHeight := 0;
    i := 0;
    While (i < GetDetailDataset().RecordCount)  Do
    Begin
        inc(DataLineHeight ,getDataLineHeight()) ;
        If isPageFull (DataLineHeight) Then
        Begin
            inc(Result);
            DataLineHeight := 0;
        End else begin
            GetDetailDataset().Next;
            inc(I);
        end;
    End;
End;  

{ RenderParts }

constructor RenderParts.Create(RC:TReportRuntime);
begin
  Self.FLineList := RC.LineList ;
  Self.FRC :=RC ;
end;

procedure RenderParts.FillHead;
var
  R:TLineList;
  ThisLine, Line: TReportLine;
  i:Integer;
begin
   R := TLineList.Create(FRC);
   try
     For i := 0 To FLineList.Count - 1 Do
     Begin
      ThisLine := FlineList[i];
      if Not ThisLine.IsDetailLine then
      begin
        Line := FRC.CloneNewLine(ThisLine);
        R.Add(Line);
      end else
        break;
     End;
   finally
     FHead :=  R ;
   end;
end;
function TReportRunTime.FillHeadList():TList;
begin
  FRender.FillHead;
  result :=   FRender.FLineList;
end;

procedure RenderParts.FillFoot;
  Var
  I :Integer;
  R: TLineList;
  ThisLine, Line: TReportLine;
begin
  R := TLineList.Create(FRC);
  For i := FRc.DetailLineIndex + 1 To FlineList.Count - 1 Do
  Begin
    ThisLine := TReportLine(FlineList[i]);
    if not ThisLine.IsSumAllLine then begin
      Line := FRC.CloneNewLine(ThisLine);
      R.Add(Line);
      Line.UpdateLineHeight;
    end;
  End;
  FFoot := R;
end;
procedure RenderParts.FillFixParts();
begin
    FillHead();
    FillFoot ;
    FillSumAll ;
end;
procedure RenderParts.FillSumAll();
Var
  I :Integer;
  Line: TReportLine;
begin
  FSumAll := TLineList.Create(FRC);
  For i := FRC.DetailLineIndex + 1 To FlineList.Count - 1 Do
  Begin
    Line := FRC.CloneNewLine(FlineList[i]);
    Line.UpdateLineHeight;
    FSumAll.Add(Line);
  End;
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
  while (i < FRC.GetDetailDataset().RecordCount) do
  begin
    TempLine := FRC.ExpandLine(FRC.DetailLineIndex);
    inc(FRC.FDataLineHeight,FRC.getDataLineHeight());
    if not FRC.isPageFull(FRC.FDataLineHeight) then begin
      FData.add(tempLine);
      FRC.SumLine(FRC.DetailLineIndex);
      FRC.GetDetailDataset().Next;
      i := i + 1;
    end else
      break;
  end;
  Result := i;
end;
procedure RenderParts.SaveLastPage(fpagecount, FpageAll:Integer);
begin
   JoinList(FRC.FPrintLineList,True);
   FRC.UpdatePrintLines;
   FRC.SaveCurrentPage();
end;

procedure RenderParts.SavePage(fpagecount, FpageAll:Integer);
begin
   JoinList(FRC.FPrintLineList,false);
   FRC.UpdatePrintLines;
   FRC.SaveCurrentPage();
end;
procedure RenderParts.SimplePage;
begin
       FillHead();
       SaveHeadPage()
end;

procedure RenderParts.SaveHeadPage();
begin
    FRC.AppendList(FRC.FPrintLineList, FHead);
    FRC.UpdatePrintLines;
    FRC.SaveCurrentPage();
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

procedure  RenderParts.Reset;
begin
  FRC.FSummer.ResetSumPage;
  FRC.FPrintLineList.Clear;
  ResetData;
  FRC.FDataLineHeight := 0;
end;

procedure TReportRunTime.SetData(M, D: TDataSet);
begin
  FNamedDatasets.SEtData(M,D);
end;
procedure TDataList.SetData(M, D: TDataSet);
begin
  ClearDataset ;
  SetDataSet('t1',M);
  SetDataSet('t2',D);
end;
Function TDataList.DatasetByName(strDatasetName: String): TDataset;
Var
  I: Integer;
Begin
  Result := Nil;

  For I := 0 To Count - 1 Do
  Begin
    If TDatasetItem(Self[I]).strName = strDatasetName Then
    Begin
      Result := TDatasetItem(Self[I]).pDataset;
    End;
  End;
End;


end.




