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
  forms,
  messages,
  Classes,    ujson,
   Math,DBClient,  db,  DBTables,  Graphics, dialogs,   Windows,  SysUtils,  TestFramework,Printers;

type

  TRitaRestartTest = class(TTestCase)
  private

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRuntime;
    procedure TestSimpleJson;
    procedure TestArray;
    procedure TestDeepLevel;
    procedure TestJson;
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
procedure TRitaRestartTest.TestSimpleJson;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
begin
    c := 0 ;
    Source := TStringList.Create;
    Source.Add('{"PageWidth":"100","PageHeight":"300"}');
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, Source.Text);
    Source.Free;
    for J := 0 to Length(JsonParser.Output.Errors) - 1 do
      WriteLn(JsonParser.Output.Errors[J]);
    Lines := TStringList.Create;
    PrintJsonParserOutput(JsonParser.Output, Lines);
    pairs := JsonParser.Output.Objects[0] ;
    for I := 0 to length(pairs) -1 do
    begin
        key := pairs[i].key ;
        value := pairs[i].value ;
        if (value.Kind = JVKString)then
          c := c + strtoint(JsonParser.Output.strings[value.index])
    end;
    Lines.Free;
    check(c = 400,'not equals 400' + inttostr(c));
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
        SaveToFile(strFileDir+'\'+'1.ept');
        ResetContent;
        cf.Free;
      end;
      R.ReportFile:=strFileDir+'\'+'1.ept';
      R.SaveToJson(strFileDir+'\'+'1.json');
      R.PrintPreview(true);
    finally
      T1.free;
      T2.Free;
    end;
end;


procedure TRitaRestartTest.TestArray;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
begin
    c := 0 ;
    Source := TStringList.Create;
    Source.Add('[{"PageWidth":"100"},{"PageWidth":"101"}]');
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, Source.Text);
    Source.Free;
    for J := 0 to Length(JsonParser.Output.Errors) - 1 do
      WriteLn(JsonParser.Output.Errors[J]);
    Lines := TStringList.Create;
    for i := 0 to length(JsonParser.Output.Objects)-1 do begin
        pairs := JsonParser.Output.Objects[i] ;
        key := pairs[0].key;
        value := pairs[0].value ;
        if (value.Kind = JVKString)then
          c := c + strtoint(JsonParser.Output.strings[value.index])
    end;
    Lines.Free;
    check(c = 201,'not equals 201' + inttostr(c));
end;
procedure TRitaRestartTest.TestDeepLevel;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  function ParseCell(arr : TJsonObject): Integer;
  var
    I, J: Integer;
    pairs : TJsonObject;
  begin
     result := 0;
      for i := 0 to length(arr)-1 do begin
        pairs := arr ;
        key := pairs[i].key;
        value := pairs[i].value ;
        if (value.Kind = JVKString)then
          result := result + strtoint(JsonParser.Output.strings[value.index]);
    end;
  end;
  function ParseCells(arr : TJsonArray): Integer;
  var
    I, J: Integer;
  begin
      result := 0;
      for i := 0 to length(arr)-1 do begin
        value := arr[0];
        if (value.Kind = JVKObject)then
          result := result + parseCell(JsonParser.Output.Objects[value.index]);
    end;
  end;
  function ParseLine(arr :TJsonObject): Integer;
  var
    I, J: Integer;
    pairs : TJsonObject;
  begin
     result := 0;
     for i := 0 to length(arr)-1 do begin
        key := arr[i].key ;
        value := arr[i].Value ;
        if (value.Kind = JVKstring)then
          result := result + strtoint(JsonParser.Output.strings[value.index]);
        if (key = 'Cells') then
          result := result + parseCells(JsonParser.Output.Arrays[value.index])
    end;
  end;
  function ParseLines(arr :TJsonArray): Integer;
  var
    I, J: Integer;
    pairs : TJsonValue;
  begin
     result := 0;
      for i := 0 to length(arr)-1 do begin
        value := arr[i] ;
        if (value.Kind = JVKObject)then
          result := result + ParseLine(JsonParser.Output.Objects[value.index]);
    end;
  end;
 var report :  TJsonObject;
begin
    c := 0 ;
    Source := TStringList.Create;
    Source.Add('{"PageWidth":"100","Lines":[{"Index":"0","LineTop":"10","LineHeight":"20","Cells":[{"CellIndex":"0","CellLeft":"210"}]}]}');
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, Source.Text);
    Source.Free;
    for J := 0 to Length(JsonParser.Output.Errors) - 1 do
      WriteLn(JsonParser.Output.Errors[J]);
    Lines := TStringList.Create;
    report := JsonParser.Output.Objects[0];
    for i := 0 to length(report)-1 do begin
        //pairs :=  report[i];
        key := report[i].key;
        value := report[i].value ;
        if (value.Kind = JVKString)then
          c := c + strtoint(JsonParser.Output.strings[value.index]);
        if ((key = 'Lines') and (value.Kind = JVKArray)) then
          c := c + ParseLines(JsonParser.Output.Arrays[value.Index])
    end;
    Lines.Free;
    check(c = 340,'not equals 201' + inttostr(c));
end;

procedure TRitaRestartTest.TestJson;
var
  Source, Lines: TStringList;
  JsonParser: TJsonParser;
  I, J: Integer;
  pairs : TJsonObject;
  key:string;
  value : TJsonValue;
  c : Integer;
  var a:string;

begin
    a := '{"lineIndex":0,"cells":[{"cellLeft":10,"cellIndex":5},{"cellLeft":10,"cellIndex":5}]}';
    c := 0 ;
    ClearJsonParser(JsonParser);
    ParseJson(JsonParser, a);
    for J := 0 to Length(JsonParser.Output.Errors) - 1 do
      WriteLn(JsonParser.Output.Errors[J]);
    Lines := TStringList.Create;
    PrintJsonParserOutput(JsonParser.Output, Lines);
    check(a = a,Lines.text);
end;

initialization
  RegisterTests('RitaRestart',[
      TRitaRestartTest.Suite
  ]);
end.
