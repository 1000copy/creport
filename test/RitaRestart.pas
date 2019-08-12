unit RitaRestart;

interface

uses
  // user
  cc,
  uHornCartesian,
  osservice,
  ReportControl,
  ReportRunTime,creport,
  // sys
  messages,
  Classes,
   Math,DBClient,  db,  DBTables,  Graphics,  forms,  Windows,  SysUtils,  TestFramework,Printers;

type

  TRitaRestartTest = class(TTestCase)
  private
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRuntime;

  end;

implementation

procedure TRitaRestartTest.SetUp;
begin
  inherited;

end;

procedure TRitaRestartTest.TearDown;
begin
  inherited;

end;

procedure TRitaRestartTest.TestRuntime;
var j:integer;
    strFileDir:string;
    CellFont: TLogFont;
    cf: TFont;
    R:TReportRunTime;
    t1 ,t2: TClientDataset;
    F : TStringField;
    i : integer ;
begin
  try
      R:=TReportRunTime.Create(Application.MainForm);
      R.Visible := False;
      t1 := TClientDataset.Create(nil);
      t1.FieldDefs.Add('f1',ftString,20,true);
      t1.FieldDefs.Add('f2',ftString,20,true);
      t2 := TClientDataset.Create(nil);
      t2.FieldDefs.Add('f1',ftString,20,true);

      t1.CreateDataSet;
      t2.CreateDataSet;
      R.SetData(t1,t2);
      t1.Open;
      t2.Open;
      for i := 0 to 100 do begin
        t1.AppendRecord([i,2]);
      end;
      t2.Append;
      t2.FieldByName('f1').asstring:= '2' ;
      t2.Post;
      strFileDir := ExtractFileDir(Application.ExeName);
      with  R do
      begin
        CalcWndSize; 
        NewTable(2 ,3);
        Lines[0].Select;
        CombineCell;
        Lines[0].LineHeight := 80;
        SetCellLines(false,false,false,false,1,1,1,1);
        Cells[0,0].CellText := 'bill';
        SetCellAlign(TEXT_ALIGN_CENTER, TEXT_ALIGN_VCENTER);

        cf := Tfont.Create;
        cf.Name := '¿¬Ìå_GB2312';
        cf.Size := 22;
        cf.style :=cf.style+ [fsBold];
        SetSelectedCellFont(cf);
        for j:=0 to t1.FieldDefs.Count -1  do
        begin
           Cells[1,j].CellText := t1.FieldDefs[j].Name;
           Cells[2,j].CellText := '#T1.'+t1.FieldDefs[j].Name;
        end;
        SaveToFile(strFileDir+'\'+'xxx.ept');
        ResetContent;
        cf.Free;
      end;
      R.ReportFile:=strFileDir+'\'+'xxx.ept';
      R.PrintPreview(true);
    finally
      T1.free;
      T2.Free;
    end;
end;


initialization
  RegisterTests('RitaRestart',[
      TRitaRestartTest.Suite
  ]);
end.
