unit CC;

interface
uses windows;
const
  RenderException = '���δ����ȫ����,�������Ԫ���Ȼ�ҳ�߾������' ;
  SumPageFormat = 'ģ���ļ���Sumpage()�����ڲ�����ӦΪ��';
  PageFormat = '��%d/%dҳ';
  PageFormat1 = '��%dҳ' ;
  PageFormat2 = '��%d-%dҳ' ;
  FormulaPrefix = '`' ;
  ErrorRendering = '�γɱ���ʱ��������������������ģ�����õ��Ƿ���ȷ';
  ErrorPrinterSetupRequired = 'δ��װ��ӡ��';
  TwoCellSelectedAtLeast = '������ѡ��������Ԫ��' ;
  IsRegularForCombine  = 'ѡ����β�������������ѡ' ;
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
