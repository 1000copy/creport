
unit REportDemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ReportControl, StdCtrls, Db, DBTables, Grids, DBGrids,printers, Buttons,
  ExtCtrls, ExtDlgs,ReportRunTime,osservice, DBClient, DBCtrls;

type
  TCReportDemoForm = class(TForm)
    DBGrid1: TDBGrid;
    ReportRunTime1: TReportRunTime;
    opbm1: TOpenPictureDialog;
    SaveDialog1: TSaveDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    ClientDataSet1: TClientDataSet;
    dbimg1: TDBImage;
    ReportControl1: TReportControl;
    Button4: TButton;
    Button1: TButton;
    Button3: TButton;
    Button5: TButton;
    CheckBox1: TCheckBox;
    btnCSV: TButton;
    procedure Button4Click(Sender: TObject);
    //procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnCSVClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CReportDemoForm: TCReportDemoForm;


  implementation

uses Data;

{$R *.DFM}


procedure TCReportDemoForm.Button4Click(Sender: TObject);
begin
close;
end;
const filename = 'creport_demo.ept' ; 
//const filename = 'ut_bmpfield_showtext_why.ept' ;

procedure TCReportDemoForm.Button5Click(Sender: TObject);
begin
  ReportRunTime1.ClearDataset ;
  ReportRunTime1.SetDataSet('t1',dataform.table1);
  ReportRunTime1.SetDataSet('t2',dataform.table2);
  dataform.Table1.DisableControls;
  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+ filename;
  ReportRunTime1.Setvarvalue('jgtw','1');
  ReportRunTime1.Setvarvalue('head','2');
  ReportRunTime1.Setvarvalue('name','3');
  dataform.table1.Last ;
  ReportRunTime1.PrintPreview(true);
  dataform.Table1.EnableControls;
end;

procedure TCReportDemoForm.Button3Click(Sender: TObject);
begin
  dataform.Table1.DisableControls;
  ReportRunTime1.ClearDataset ;
  ReportRunTime1.SetDataSet('t1',dataform.table1);
  ReportRunTime1.SetDataSet('t2',dataform.table2);

  ReportRunTime1.ReportFile:=ExtractFilepath(application.ExeName)+filename;
  ReportRunTime1.Setvarvalue('jgtw','1');
  ReportRunTime1.Setvarvalue('head','2');
  ReportRunTime1.Setvarvalue('name','3');
  ReportRunTime1.Print(true);
  dataform.Table1.EnableControls;
end;

procedure TCReportDemoForm.FormCreate(Sender: TObject);
begin
  dataform.table1.open;
  dataform.table2.open;
  dataform.table1.Last ;
end;              

procedure TCReportDemoForm.CheckBox1Click(Sender: TObject);
begin
if CheckBox1.Checked then
  ReportRunTime1.AddSpace:=true
else
  ReportRunTime1.AddSpace:=false;

end;

procedure TCReportDemoForm.FormPaint(Sender: TObject);
begin
  CheckBox1.Checked:= ReportRunTime1.AddSpace;
end;

procedure TCReportDemoForm.Button1Click(Sender: TObject);
var strFileDir : string;
begin
  strFileDir := ExtractFileDir(Application.ExeName);
  self.ReportRunTime1.EditReport(strFileDir+'\'+filename);

end;
type
  TGraphicHeader = record
    Count: Word;                { Fixed at 1 }
    HType: Word;                { Fixed at $0100 }
    Size: Longint;              { Size not including header }
  end;
procedure saveBlob (t:TTable;fname:string);
Var
  Blob: TBlobStream;
const
  HeaderSize = sizeof(TGraphicHeader);
Begin
  Blob:= TBLOBStream.Create(TBlobField(T.FieldByName(fname)),bmRead);
  Try
    Blob.Seek(0, soFromBeginning);
    With TFileStream.Create(fname +'.jpg', fmCreate) do
    Try
      Seek(+HeaderSize,soFromCurrent);
      CopyFrom(blob, blob.Size)
    finally
      free;
    end;
  finally
    Blob.Free;
  end;
End;
procedure TCReportDemoForm.btnCSVClick(Sender: TObject);
var
  Stream: TFileStream;
  i: Integer;
  OutLine: string;
  sTemp: string;
  table1 : TTable;
  fbmp : TBitmap ;
begin
  table1 := dataform.table1;
  Stream := TFileStream.Create('YourFile.csv', fmCreate);
  table1.first;
  try
    while not table1.Eof do
    begin
      // You'll need to add your special handling here where OutLine is built
      OutLine := '';
      for i := 0 to table1.FieldCount - 1 do
      begin
        if not table1.Fields[i].IsBlob then begin
          sTemp := table1.Fields[i].AsString;
          OutLine := OutLine + sTemp + ',';
        end else if not table1.Fields[0].isnull then
        begin
          fbmp := TBitmap.create;
          FBmp.Assign( table1.Fields[i]);
          if 0 <> fbmp.Height then
            fbMP.SaveToFile(table1.Fields[0].ASSTRING+'.BMP');
        end;
      end;
      // Remove final unnecessary ','
      SetLength(OutLine, Length(OutLine) - 1);
      // Write line to file
      Stream.Write(OutLine[1], Length(OutLine) * SizeOf(Char));
      // Write line ending
      Stream.Write(sLineBreak, Length(sLineBreak));
      table1.Next;
    end;
  finally
    Stream.Free;  // Saves the file
  end;
end;
end.
