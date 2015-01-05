unit CC;

interface
uses windows;
const
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
function Grey :COLORREF;
function White :COLORREF;
function Black :COLORREF;
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
end.
