unit CC;

interface
uses windows,Math;
const
  DRAGMARGIN =10;
  RenderException = '表格未能完全处理,请调整单元格宽度或页边距等设置' ;
  SumPageFormat = '模板文件中Sumpage()括号内参数不应为零';
  PageFormat = '第%d/%d页';
  PageFormat1 = '第%d页' ;
  PageFormat2 = '第%d-%d页' ;
  FormulaPrefix = '`' ;
  ErrorRendering = '形成报表时发生错误，请检查各项参数与模板设置等是否正确';
  ErrorPrinterSetupRequired = '未安装打印机';
  TwoCellSelectedAtLeast = '请至少选择两个单元格' ;
  IsRegularForCombine  = '选择矩形不够规整，请重选' ;
  NewTableError = '关闭正在编辑的文件后，才能建立新表格。' ;
  HorzMargin_ZoomFit = 170 ;
  VertMargin_ZoomFit_ForPreview = 110 ;
  VertMargin_ZoomFit_For_Design = 160 ;
  
function Grey :COLORREF;
function White :COLORREF;
function Black :COLORREF;
function RegularPoint(V:Integer):Integer;
function calcBottom(TempString:string ;TempRect:TRect;AlighFormat :UINT;FLogFont: TLOGFONT):Integer;
function BoundValue(Value,Bigger,Smaller:Integer):Integer;
implementation
function Black :COLORREF;
begin
 result:= Windows.RGB(0,0,0);
end;
function Grey :COLORREF;
begin
 result:= Windows.RGB(192, 192, 192);
end;
function White :COLORREF;
begin
 result:= RGB(255, 255, 255)
end;
function RegularPoint(V:Integer):Integer;
begin
   result :=  trunc(V / 5 * 5 + 0.5);
end;
function BoundValue(Value,Bigger,Smaller:Integer):Integer;
begin
  Value := Max(Smaller,Value);
  Value := Min(Bigger,Value);
  Result := Value ;
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
  // LCJ : 最小高度需要能够放下文字，并且留下直线的宽度和2个点的空间出来。 + 4
  //       因此，需要实际绘制文字在DC 0 上，获得它的TempRect-文字所占的空间
  //       - FLeftMargin : Cell 内文字和边线之间留下的空的宽度
  hTempFont := CreateFontIndirect(FLogFont);
  hTempDC := GetDC(0);
  hPrevFont := SelectObject(hTempDC, hTempFont);
  try
    Format := DT_EDITCONTROL Or DT_WORDBREAK;
    Format := Format Or AlighFormat ;
    Format := Format Or DT_CALCRECT;
    // lpRect [in, out] !  TempRect.Bottom ,TempRect.Right  会被修改 。但是手册上没有提到。
    DrawText(hTempDC, PChar(TempString), Length(TempString), TempRect, Format);
    // 补偿文字最后的回车带来的误差
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

end.
