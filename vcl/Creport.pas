unit creport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ureport, StdCtrls, Buttons, Menus, IniFiles,ExtCtrls, ToolWin,
  ComCtrls, Spin,  printers , ExtDlgs,cc,db;

type
  TCreportForm = class(TForm)
    MainMenu1: TMainMenu;
    T1: TMenuItem;
    FileOpen: TMenuItem;
    FileExit: TMenuItem;
    N1: TMenuItem;
    T2: TMenuItem;
    NewTable: TMenuItem;
    InsertLine: TMenuItem;
    AddLine: TMenuItem;
    DeleteLine: TMenuItem;
    N4: TMenuItem;
    CombineCells: TMenuItem;
    SplitCell: TMenuItem;
    N7: TMenuItem;
    FileSave: TMenuItem;
    OpenDialog1: TOpenDialog;
    N2: TMenuItem;
    AddCell: TMenuItem;
    InsertCell: TMenuItem;
    DeleteCell: TMenuItem;
    CellBorderLine: TMenuItem;
    CellFont: TMenuItem;
    CellDiagonalLine: TMenuItem;
    CellColor: TMenuItem;
    FontDialog1: TFontDialog;
    SaveDialog1: TSaveDialog;
    PrintIt: TMenuItem;
    VSplitCell: TMenuItem;
    MarginSetting: TMenuItem;
    N6: TMenuItem;
    PrintPreivew: TMenuItem;
    PopupMenu1: TPopupMenu;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    file1: TMenuItem;
    FileClose: TMenuItem;
    N3: TMenuItem;
    N29: TMenuItem;
    N32: TMenuItem;
    N30: TMenuItem;
    N33: TMenuItem;
    ScrollBox1: TScrollBox;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton23: TSpeedButton;
    SpeedButton24: TSpeedButton;
    SpeedButton25: TSpeedButton;
    SpeedButton26: TSpeedButton;
    SpeedButton28: TSpeedButton;
    SpeedButton29: TSpeedButton;
    SpeedButton30: TSpeedButton;
    SpeedButton31: TSpeedButton;
    SpeedButton32: TSpeedButton;
    SpeedButton33: TSpeedButton;
    Panel1: TPanel;
    Panel2: TPanel;
    SpeedButton11: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    Bevel1: TBevel;
    Panel4: TPanel;
    Bevel2: TBevel;
    fontbox: TComboBox;
    fontsize: TComboBox;
    bold: TSpeedButton;
    italic: TSpeedButton;
    underline: TSpeedButton;
    left1: TSpeedButton;
    center1: TSpeedButton;
    right1: TSpeedButton;
    top1: TSpeedButton;
    medium1: TSpeedButton;
    bottom1: TSpeedButton;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Label1: TLabel;
    CellDispFormt: TComboBox;
    Lsum: TComboBox;
    SpeedButton8: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton15: TSpeedButton;
    Bevel6: TBevel;
    Label2: TLabel;
    Bevel7: TBevel;
    SpeedButton7: TSpeedButton;
    Bevel8: TBevel;
    SpeedButton9: TSpeedButton;
    Bevel9: TBevel;
    SpeedButton10: TSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    SpeedButton16: TSpeedButton;
    SpeedButton17: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure FileOpen1(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileExitClick(Sender: TObject);
    procedure FileOpenClick(Sender: TObject);
    procedure NewTableClick(Sender: TObject);
    procedure InsertLineClick(Sender: TObject);
    procedure AddLineClick(Sender: TObject);
    procedure CombineCellsClick(Sender: TObject);
    procedure SplitCellClick(Sender: TObject);
    procedure DeleteLineClick(Sender: TObject);
    procedure AddCellClick(Sender: TObject);
    procedure InsertCellClick(Sender: TObject);
    procedure DeleteCellClick(Sender: TObject);
    procedure CellBorderLineClick(Sender: TObject);
    procedure CellDiagonalLineClick(Sender: TObject);
    procedure CellFontClick(Sender: TObject);
    procedure CellColorClick(Sender: TObject);
    procedure FileSaveClick(Sender: TObject);
    procedure PrintItClick(Sender: TObject);
    procedure VSplitCellClick(Sender: TObject);
    procedure MarginSettingClick(Sender: TObject);
    procedure UpdateOldies(thefile: string; sender: tobject);
    procedure RecentFile1(sender: tobject);
    procedure RecentFile2(sender: tobject);
    procedure RecentFile3(sender: tobject);
    procedure RecentFile4(sender: tobject);
    procedure RecentFile5(sender: tobject);
    procedure RecentFile6(sender: tobject);
    procedure RecentFile7(sender: tobject);
    procedure RecentFile8(sender: tobject);
    procedure RecentFile9(sender: tobject);
    procedure T1Click(Sender: TObject);
    procedure FileCloseClick(Sender: TObject);
    procedure N29Click(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure N33Click(Sender: TObject);
    procedure loadini;
    procedure saveini;
    procedure left1Click(Sender: TObject);
    procedure fontboxChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure fontsizeChange(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton15Click(Sender: TObject);
    procedure RCMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton7Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CellDispFormtChange(Sender: TObject);
    procedure LsumChange(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton16Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private

    dbarleft:integer;
    dbartop:integer;
    //δ���̱�־
    isSave:boolean;
    procedure ListBoxDragOver(Sender, Source: TObject; X,Y: Integer; State: TDragState; var Accept: Boolean);

//    function  LFindComponent(Owner: TComponent; Name: String): TComponent;
//    procedure LEnumComponents(F:TComponent);

    { Private declarations }
  public
    RC: TReportControl;
    thefile, saveFileName: string;
    zoomxxx:INTEGER;
    property ReportControl: TReportControl read RC;
    procedure DoCenter ;
    class function  EditReport(FileName: String):TReportControl;
    class function InitReport: TCreportForm;
    class function UninitReport(): TReportControl;
  end;

const
  DefIni = 'EReport.ini';
  ver = 'eReport 5.0'
  copyright = ver ;
  prname='������������';
  updates = '�޸�����:2019.9 MTK"

var
  CreportForm: TCreportForm;
  //cp_fieldName:string;
  //cp_buttion:boolean;

implementation

uses NewDialog, Border, diagonal, Color, vsplit,about,margin;

{$R *.DFM}

procedure TCreportForm.saveini;
var
  IniFile: TIniFile;
  toolbar, fonts, statusbar, autosave: integer;
begin
  IniFile := TIniFile.create(defini);
//  IniFile := TIniFile.create(ExtractFilePath(ParamStr(0)) + defini);
  inifile.writeinteger('����', 'toolbar', toolbar);
  inifile.writeinteger('����', 'statusbar', statusbar);
  inifile.writeinteger('����', 'autosave', autosave);
  //inifile.writeinteger('����', 'savetime', timer1.Interval);
  inifile.writeinteger('����', 'fonts', fonts);
end;

procedure TCreportForm.loadini;
var
  IniFile: TIniFile;
  savetime, fonts, toolbar, statusbar, autosave: integer;
begin
  IniFile := TIniFile.create(defini);
//  IniFile := TIniFile.create(ExtractFilePath(ParamStr(0)) + defini);
  toolbar := inifile.readinteger('����', 'toolbar', 1);
  statusbar := inifile.readinteger('����', 'statusbar', 1);
  autosave := inifile.readinteger('����', 'autosave', 1);
  savetime := inifile.readinteger('����', 'savetime', 120000);
  fonts := inifile.readinteger('����', 'fonts', 1);
 // timer1.Interval := savetime;
end;

procedure TCreportForm.FormCreate(Sender: TObject);
var i,j:integer;
begin
  RC:= TReportControl.Create(self.ScrollBox1);
  rc.CalcWndSize;
  isSave:=true;

  dbarleft:=0;
  dbartop:=0;
  caption := '[���ļ���] ' ;
  loadini;
  saveini;
  fontbox.Items := screen.fonts;
  fontbox.ItemIndex := 1;
  fontsize.ItemIndex := 1;

  for i := 0 to fontbox.items.Count do
  begin
    if fontbox.Items[i] = '����' then
    begin
      fontbox.ItemIndex := i;
      break;
    end;
  end;
  zoomxxx:=100;
  If ParamCount>=1 Then
  Begin
    RC.LoadFromFile(ParamStr(1));
    caption:=ParamStr(1);
    Thefile :=ParamStr(1);
    saveFileName := Thefile;
  End;
  RC.CalcWndSize;

// combobox1.Clear;
// for i:=0 to Screen.FormCount-1 do
//   for j:=0 to Screen.Forms[i].ComponentCount-1 do
//     if Screen.Forms[i].Components[j] is TDataSet then
//     begin
//       with TDataSet(Screen.Forms[i].Components[j]) do
//            combobox1.Items.Add(Screen.Forms[i].Name+'.'+TDataSet(Screen.Forms[i].Components[j]).Name);
//     end;

 //if Screen.DataModuleCount>0 then
// for i:=0 to Screen.DataModuleCount-1 do
//   for j:=0 to Screen.DataModules[i].ComponentCount-1 do
//     if Screen.DataModules[i].Components[j] is TDataSet then
//     begin
//       with TDataSet(Screen.DataModules[i].Components[j]) do
//            combobox1.Items.Add(Screen.DataModules[i].Name+'.'+TDataSet(Screen.DataModules[i].Components[j]).Name);
//     end;
//
//    for i := 0 to Screen.CustomFormCount - 1 do
//      if (Screen.CustomForms[i].ClassName = 'TDataModuleForm')  then
//        for j := 0 to Screen.CustomForms[i].ComponentCount - 1 do
//        begin
//          if (Screen.CustomForms[i].Components[j] is TDataModule) then
//            LEnumComponents(Screen.CustomForms[i].Components[j]);
//        end;
end;

procedure TCreportForm.FileExitClick(Sender: TObject);
begin
  close;
end;


procedure TCreportForm.FileOpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    thefile := OpenDialog1.Filename;
    if endsWith(thefile,'.json') or endsWith(thefile,'.txt') then begin
      rc.LoadFromJson(thefile);
    end
    else
      RC.LoadFromFile(theFile);
    Creportform.caption := thefile ;
    saveFileName := thefile;
    updateOldies(thefile, sender);
    thefile := '';
    zoomxxx:=100;
    ShowWindow(RC.Handle, SW_HIDE);
    RC.ReportScale := zoomxxx;
    ScrollBox1Resize(Self);
    ShowWindow(RC.Handle, SW_SHOW);
  end;
end;

procedure TCreportForm.FileOpen1(Sender: TObject);
begin
  RC.LoadFromFile(theFile);
  Creportform.caption := thefile ;
  saveFileName := thefile;
  updateOldies(thefile, sender);
  thefile := '';
end;

procedure TCreportForm.NewTableClick(Sender: TObject);
var
  t: boolean;
begin
  if frmNewTable.ShowModal = IDOK then
    RC.NewTable(StrToInt(frmNewTable.Edit2.Text), StrToInt(frmNewTable.Edit1.Text));
end;

procedure TCreportForm.InsertLineClick(Sender: TObject);
begin
  RC.InsertLine;
      isSave:=false;

end;

procedure TCreportForm.AddLineClick(Sender: TObject);
begin
if self.RC.SelectedCells.Count > 0  then
begin
      RC.AddLine;
      isSave:=false;
end;
end;

procedure TCreportForm.CombineCellsClick(Sender: TObject);
begin
  RC.CombineCell;
      isSave:=false;

end;

procedure TCreportForm.SplitCellClick(Sender: TObject);
begin
  RC.SplitCell;
  fontboxChange(Sender);
    isSave:=false;

end;

{procedure TCreportForm.CellPropClick(Sender: TObject);
begin
end;
 }
procedure TCreportForm.DeleteLineClick(Sender: TObject);
begin
  RC.DeleteLine;
      isSave:=false;

end;

procedure TCreportForm.AddCellClick(Sender: TObject);
begin
  RC.AddCell;
      isSave:=false;

end;

procedure TCreportForm.InsertCellClick(Sender: TObject);
begin
  RC.InsertCell;
  isSave:=false;
end;

procedure TCreportForm.DeleteCellClick(Sender: TObject);
begin
  RC.DeleteCell;
  isSave:=false;
end;

procedure TCreportForm.CellBorderLineClick(Sender: TObject);
var
  cell : TReportCell;
begin
  if RC.SelectedCells.Count >0  then
  begin
    cell := RC.SelectedCells[0];
    borderform.LeftLine.Checked:=cell.LeftLine;
    borderform.TopLine.Checked:=cell.TopLine;
    borderform.RightLine.Checked:=cell.RightLine;
    borderform.BottomLine.Checked:=cell.BottomLine;

    borderform.SpinEdit1.Value:=cell.LeftLineWidth;
    borderform.SpinEdit2.Value:=cell.TopLineWidth;
    borderform.SpinEdit3.Value:=cell.RightLineWidth;
    borderform.SpinEdit4.Value:=cell.BottomLineWidth;

    if BorderForm.ShowModal = mrOK then
      with BorderForm do
      RC.SetCellLines(LeftLine.Checked,
        TopLine.Checked,
        RightLine.Checked,
        BottomLine.Checked,
        SpinEdit1.Value, SpinEdit2.Value, SpinEdit3.Value, SpinEdit4.Value);
    isSave:=false;

  end
  else Application.Messagebox('��ѡ��Ԫ��!!!', '����', MB_OK + MB_iconwarning);
end;

procedure TCreportForm.CellDiagonalLineClick(Sender: TObject);
var
  nDiagonal: UINT;
begin
  if RC.SelectedCells.Count = 0  then
    exit;
  if DiagonalForm.ShowModal = mrOK then
  begin
    with DiagonalForm do
    begin
      nDiagonal := 0;
      if LeftDiagonal1.Checked then
        nDiagonal := nDiagonal or LINE_LEFT1;

      if LeftDiagonal2.Checked then
        nDiagonal := nDiagonal or LINE_LEFT2;

      if LeftDiagonal3.Checked then
        nDiagonal := nDiagonal or LINE_LEFT3;

      if RightDiagonal1.Checked then
        nDiagonal := nDiagonal or LINE_RIGHT1;

      if RightDiagonal2.Checked then
        nDiagonal := nDiagonal or LINE_RIGHT2;

      if RightDiagonal3.Checked then
        nDiagonal := nDiagonal or LINE_RIGHT3;
      RC.SetCellDiagonal(nDiagonal);
    isSave:=false;
    end;
  end;
end;

procedure TCreportForm.CellFontClick(Sender: TObject);
var
  CellFont: TLogFont;
  hTempDC: HDC;
  pt, ptOrg: TPoint;
begin
  if RC.SelectedCells.Count >0  then
  begin
    hTempDC := GetDC(0);
    pt.y := abs(TReportCell(RC.SelectedCells[0]).LogFont.lfheight) * 720 div GetDeviceCaps(hTempDC, LOGPIXELSY);
    DPtoLP(hTempDC, pt, 1);
    ptOrg.x := 0;
    ptOrg.y := 0;
    DPtoLP(hTempDC, ptOrg, 1);

    FontDialog1.Font.Name := TReportCell(RC.SelectedCells[0]).LogFont.lfFaceName;
    FontDialog1.Font.Size := ((pt.y - ptOrg.y) div 10);

    if FontDialog1.Execute then
    begin
      Windows.GetObject(FontDialog1.Font.Handle, SizeOf(CellFont), @CellFont);
      RC.SetCellFont(CellFont);
      RC.SetCellColor(FontDialog1.Font.color, ColorForm.Panel1.Color);
      isSave:=false;
    end;
  end
  else Application.Messagebox('��ѡ��Ԫ��!!!', '����', MB_OK + MB_iconwarning);
end;

procedure TCreportForm.CellColorClick(Sender: TObject);
begin
  if RC.SelectedCells.Count >0  then
  begin
    if ColorForm.ShowModal = mrOK then
    begin
      RC.SetCellColor(ColorForm.Panel1.Font.Color, ColorForm.Panel1.Color);
    isSave:=false;
    end;
  end
  else Application.Messagebox('��ѡ��Ԫ��!!!', '����', MB_OK + MB_iconwarning);
end;

procedure TCreportForm.FileSaveClick(Sender: TObject);
begin
  savedialog1.filename := saveFileName;
  if SaveDialog1.Execute then
  begin
    RC.SaveToFile(SaveDialog1.FileName);
    thefile := SaveDialog1.Filename;
    saveFileName := thefile;
    Creportform.caption := thefile ;
    updateOldies(thefile, sender);
    thefile := '';
  end;
end;

procedure TCreportForm.PrintItClick(Sender: TObject);  // update  
begin
  if printer.Printers.Count > 0 then RC.PrintIt
  else Application.Messagebox('δ��װ��ӡ��', '����', MB_OK + MB_iconwarning);
end;

procedure TCreportForm.VSplitCellClick(Sender: TObject);
begin
if RC.SelectedCells.Count >0  then
  if VSplitForm.ShowModal = mrOK then
  begin
    RC.VSplitCell(VSplitForm.VSplitCount.Value);
        isSave:=false;
end;
end;

procedure TCreportForm.MarginSettingClick(Sender: TObject);   
var
  MarginRect: TRect;
begin
 
  MarginRect := RC.GetMargin;
  if MarginForm = nil then
    MarginForm := TMarginForm.Create(Application);
  MarginForm.LeftMargin.Value := MarginRect.Left;
  MarginForm.TopMargin.Value := MarginRect.Top;
  MarginForm.RightMargin.Value := MarginRect.Right;
  MarginForm.BottomMargin.Value := MarginRect.Bottom;
  RC.PrintPaper.Batch;
  if MarginForm.ShowModal = mrOK then
  begin
      RC.SetMargin(MarginForm.LeftMargin.Value,
        MarginForm.TopMargin.Value,
        MarginForm.RightMargin.Value,
        MarginForm.BottomMargin.Value);
      isSave:=false;
      RC.CalcWndSize;
  end;
end;

procedure TCreportForm.FileCloseClick(Sender: TObject); // update  
begin
  if Application.Messagebox('ȷʵҪ�ر��ļ���', '����', MB_OKCANCEL) = MrOK then
  begin
    RC.FreeEdit;
    RC.ResetContent;
    RC.FLastPrintPageWidth := 0;
    RC.CalcWndSize;
    Creportform.caption := '[���ļ���] ' ;
    thefile := '';
    saveFileName := '';
  end;
end;


procedure TCreportForm.updateoldies(thefile: string; sender: tobject);
var
  A, B, holder: string;
  n: integer;
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
//  IniFile := TIniFile.create(ExtractFilePath(ParamStr(0)) + defini);
  A := uppercase(thefile);
  holder := A;
  for n := 1 to 10 do
  begin
    B := inifile.readstring('Oldies', inttostr(n), '');
    if b = holder then
    begin
      inifile.writestring('Oldies', inttostr(n), 'filepath');
      B := inifile.readstring('Oldies', inttostr(n), '');
    end;
    inifile.writestring('Oldies', inttostr(n), A);
    A := B;
  end;
  zoomxxx:=100;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

end;

procedure TCreportForm.RecentFile1(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '1', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile2(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '2', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile3(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '3', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile4(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '4', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile5(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '5', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile6(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '6', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile7(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '7', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile8(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '8', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.RecentFile9(sender: tobject);
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.create(defini);
  thefile := inifile.readstring('Oldies', '9', '');
  if thefile <> '' then FileOpen1(sender);
end;

procedure TCreportForm.T1Click(Sender: TObject);
var
  NewItem: TMenuItem;
  count, A, B, wipe: string;
  n, m: integer;
  IniFile: TIniFile;
label
  redo;
begin
  IniFile := TIniFile.create(defini);
  while file1.count > 0 do
    file1.Delete(0);
  for n := 1 to 9 do
  begin
    count := inttostr(n);
    redo: //ѭ����ʼ
    A := inifile.readstring('Oldies', count, '');
    if A = '' then exit;
    if not fileexists(A) then
    begin
      for m := strtoint(count) to 10 do
      begin
        B := inifile.readstring('Oldies', inttostr(m + 1), '');
        inifile.writestring('Oldies', inttostr(m), B);
        wipe := inttostr(m + 1);
      end;
      inifile.writestring('Oldies', wipe, '');
      goto redo; //ѭ������
    end;
    NewItem := TMenuItem.Create(Self);
    NewItem.Caption := '&' + count + ' ' + A;
    case n of
      1: newitem.onclick := RecentFile1;
      2: newitem.onclick := RecentFile2;
      3: newitem.onclick := RecentFile3;
      4: newitem.onclick := RecentFile4;
      5: newitem.onclick := RecentFile5;
      6: newitem.onclick := RecentFile6;
      7: newitem.onclick := RecentFile7;
      8: newitem.onclick := RecentFile8;
      9: newitem.onclick := RecentFile9;
    end;
//    File1.Insert(n-1, NewItem);
    File1.Add(NewItem);
  end;

end;

procedure TCreportForm.N29Click(Sender: TObject);
var
  t: string;
begin
  if saveFileName = '' then
  begin
    if SaveDialog1.Execute then
    begin
      RC.SaveToFile(SaveDialog1.FileName);
      thefile := SaveDialog1.Filename;
      updateOldies(thefile, sender);
      Creportform.caption := thefile ;
      saveFileName := thefile;
      thefile := '';
      isSave:=true;
    end;
  end
  else
  begin
    if endsWith(saveFileName,'.json') or endsWith(saveFileName,'.txt')then
       RC.savetoJson(saveFileName)
    else
      RC.SaveToFile(saveFileName);
    thefile := saveFileName;
    updateOldies(thefile, sender);
    thefile := '';
    isSave:=true;

  end;
end;

procedure TCreportForm.ScrollBox1Resize(Sender: TObject);
begin
  if ClientRect.Right > RC.Width + 20 then
    RC.Left := (ClientRect.Right - RC.Width-20) div 2
  else
    RC.Left := 30;

   if ((height-150-RC.Height) div 2)+10 >10 then
      RC.top:= ((height-150-RC.Height) div 2)+5
   else
     RC.top:=5;
end;

procedure TCreportForm.N33Click(Sender: TObject);
begin
  frm_About.ShowModal;
end;

procedure TCreportForm.left1Click(Sender: TObject);
var
  h, v: byte;
begin
  h := 3;
  v := 3;
  if left1.Down then h := 0;
  if center1.down then h := 1;
  if right1.down then h := 2;
  if top1.Down then v := 0;
  if medium1.Down then v := 1;
  if bottom1.down then v := 2;
  RC.SetCellAlign(H, v);
  isSave:=false;

end;

procedure TCreportForm.fontboxChange(Sender: TObject);
var
  CellFont: TLogFont;
  cf: TFont;
  i, code: integer;
begin
  if RC.SelectedCells.Count >0  then
  begin
    cf := Tfont.Create;
    cf.Name := fontbox.items[fontbox.itemindex];
    val(fontsize.text, i, code);
    if i < 1 then i := 9;
    cf.Size := i;
    if bold.Down then cf.Style := cf.style + [fsBold];
    if italic.Down then cf.Style := cf.style + [fsItalic];
    if underline.Down then cf.Style := cf.style + [fsunderline];

    Windows.GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
    cf.Free;
    RC.SetCellFont(CellFont);
    isSave:=false;
  end;
end;

procedure TCreportForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  key: integer;
begin
if not isSave then
begin
  canclose:=false;
  if (saveFileName <> '') then
  begin
    key := Application.Messagebox('�����ļ������ǡ����������ļ������񡱣�ȡ�����β�������ȡ����', 'ע��', MB_YESNOCANCEL + MB_ICONEXCLAMATION); //+MB_ICONQUESTION);
    if key = Mryes then n29click(sender);
    if key <> MrCancel then canclose:=true;
  end
  else canclose:=true;
end;
end;

procedure TCreportForm.fontsizeChange(Sender: TObject);
var
  CellFont: TLogFont;
  cf: TFont;
  i, code: integer;
begin
  if RC.SelectedCells.Count >0  then
  begin

    cf := Tfont.Create;
    cf.Name := fontbox.items[fontbox.itemindex];
    val(fontsize.text, i, code);
    if i < 1 then i := 9;
    cf.Size := i;
    if bold.Down then cf.Style := cf.style + [fsBold];
    if italic.Down then cf.Style := cf.style + [fsItalic];
    if underline.Down then cf.Style := cf.style + [fsunderline];
    Windows.GetObject(cf.Handle, SizeOf(CellFont), @CellFont);
    cf.Free;
    RC.SetCellFont(CellFont);
        isSave:=false;

  end;
end;
// LCJ : ������ű���
procedure TCreportForm.SpeedButton8Click(Sender: TObject); // add  
begin
  //zoomxxx:=RC.ZoomRate (Height,Self.Width,cc.VertMargin_ZoomFit_For_Design,cc.HorzMargin_ZoomFit);
  zoomxxx:=RC.ZoomRate (Self.ScrollBox1.Height,Self.ScrollBox1.Width);
  RC.FreeEdit;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);
end;

procedure TCreportForm.SpeedButton12Click(Sender: TObject);
begin
  zoomxxx:=zoomxxx+10;
  RC.FreeEdit;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

end;

procedure TCreportForm.SpeedButton15Click(Sender: TObject);
begin
  zoomxxx:=zoomxxx-10;
  RC.FreeEdit;
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);

end;

procedure TCreportForm.RCMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);// update  
var
  hTempDC: HDC;
  pt, ptOrg: TPoint;
  i: integer;
  celldisp : TReportCell;
begin
if ssright in shift then
begin
   pt:=(Sender as TWinControl).ClienttoScreen(point(x,y));
   PopupMenu1.Popup(pt.X,pt.Y);
end;

if ssleft in shift then
try
 Panel3.Enabled:=false;
 Panel4.Enabled:=false;
 if RC.SelectedCells.count > 0 then
  begin
    celldisp := RC.SelectedCells[0];
    if celldisp.HorzAlign = 0 then left1.Down := true;
    if celldisp.HorzAlign = 1 then center1.Down := true;
    if celldisp.HorzAlign = 2 then right1.Down := true;
    if celldisp.vertAlign = 0 then top1.Down := true;
    if celldisp.vertAlign = 1 then medium1.Down := true;
    if celldisp.vertAlign = 2 then bottom1.Down := true;
    if celldisp.LogFont.lfItalic = 1 then italic.Down := true else italic.Down := false;
    if celldisp.LogFont.lfUnderline = 1 then underline.Down := true else underline.Down := false;
    if celldisp.LogFont.lfWeight = 700 then bold.Down := true else bold.Down := false;
    for i := 0 to fontbox.items.Count do
    begin
      if celldisp.LogFont.lfFaceName = fontbox.Items[i] then
      begin
        fontbox.ItemIndex := i;
        break;
      end;
    end;
    hTempDC := GetDC(0);
    pt.y := abs(celldisp.LogFont.lfheight) * 720 div GetDeviceCaps(hTempDC, LOGPIXELSY);
    DPtoLP(hTempDC, pt, 1);
    ptOrg.x := 0;
    ptOrg.y := 0;
    DPtoLP(hTempDC, ptOrg, 1);
    fontsize.Text := inttostr((pt.y - ptOrg.y) div 10);

    CellDispFormt.Text:= celldisp.CellDispformat;
  end;
  except
  end;

  Panel3.Enabled:=true;
  Panel4.Enabled:=true;

   
end;

procedure TCreportForm.SpeedButton7Click(Sender: TObject);
begin
close;
end;
// 160,171

procedure TCreportForm.FormResize(Sender: TObject); 
begin               
  //zoomxxx:= RC.ZoomRate(Height,Width, cc.VertMargin_ZoomFit_For_Design,cc.HorzMargin_ZoomFit);
  zoomxxx:= RC.ZoomRate(self.ScrollBox1.Height,self.ScrollBox1.Width);
  ShowWindow(RC.Handle, SW_HIDE);
  RC.ReportScale := zoomxxx;
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);
end;

procedure TCreportForm.ListBoxDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   Accept:=true;
end;

procedure TCreportForm.CellDispFormtChange(Sender: TObject);  
begin
if RC.SelectedCells.Count >0  then
begin
   RC.SetCellDispFormt(CellDispFormt.items[CellDispFormt.itemindex]);
    isSave:=false;
end;   
end;

procedure TCreportForm.LsumChange(Sender: TObject);
var celldisp : TReportCell;
begin
if RC.SelectedCells.Count >0  then
begin
   celldisp := RC.SelectedCells[0];
   celldisp.CellText:=Lsum.Items[Lsum.ItemIndex];
   RC.SetCellSumText('`'+Lsum.items[Lsum.itemindex]);
   fontboxChange(Sender);
       isSave:=false;

end;
end;



procedure TCreportForm.SpeedButton10Click(Sender: TObject);
var celldisp : TReportCell;
begin
if RC.SelectedCells.Count >0  then
begin
   celldisp := RC.SelectedCells[0];
try
  if OpenPictureDialog1.Execute then
  begin
    RC.DoLoadBmp(celldisp,OpenPictureDialog1.FileName);
        isSave:=false;
  end;
except
   //
end;
end
else
  MessageDlg('����ѡ��Ԫ��', mtInformation,[mbOk], 0);

end;
procedure TCreportForm.SpeedButton16Click(Sender: TObject);//  
var Acanvas:Tcanvas;
    LTempRect:Trect;
var celldisp : TReportCell;
begin
if RC.SelectedCells.Count >0  then
begin
   celldisp := RC.SelectedCells[0];
   RC.FreeBmp(celldisp);
    isSave:=false;

  ShowWindow(RC.Handle, SW_HIDE);
  ScrollBox1Resize(Self);
  ShowWindow(RC.Handle, SW_SHOW);
end
else
  MessageDlg('����ѡ��Ԫ��', mtInformation,[mbOk], 0);
end;
procedure TCreportForm.ComboBox1Change(Sender: TObject); // add
//var ss:string;
//    Dbar:TToolWindow97;
//    Dlist:tlistbox;
begin
//   if ComboBox1.Items[ComboBox1.ItemIndex] = '' then
//      exit;
//   Dbar:= TToolWindow97.Create(self);
//   Dlist:=tlistbox.Create(self);
//   Dbar.Parent:=Creportform;
//   Dbar.Height:=140;
//   Dbar.Width:=120;
//   Dlist.Parent:=DBar;
//   Dlist.Align:=alClient;
//   Dlist.DragMode:= dmAutomatic;
//   Dlist.OnDragOver:=ListBoxDragOver;
//   Dbar.Left:=dbarleft*120+2;
//   dbar.top:= dbartop*140+2;
//   if dbar.left>780 then
//   begin
//      dbartop:=dbartop+1;
//      dbarleft:=0;
//   end
//   else
//    dbarleft:=dbarleft+1;
//   ss:=ComboBox1.Items[ComboBox1.itemindex];
//   Dbar.Caption:='����:'+ss;
//    savebz:=false;
//   try
//     TDataSet(LFindComponent(Owner, ss)).GetFieldNames(dlist.Items);
//   except
//     MessageDlg('�˱�򲻿����������ò���ȷ', mtInformation,[mbOk], 0);
//   end;
end;


procedure TCreportForm.DoCenter;
begin
    zoomxxx:=100;
    ShowWindow(RC.Handle, SW_HIDE);
    RC.ReportScale := zoomxxx;
    ScrollBox1Resize(Self);
    ShowWindow(RC.Handle, SW_SHOW);
end;

class function  TCreportForm.EditReport(FileName: String):TReportControl;
begin
  Application.CreateForm(TCreportform,Creportform);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(TBorderform,Borderform );
  Application.CreateForm(TColorform,Colorform );
  Application.CreateForm(Tdiagonalform,diagonalform);
  Application.CreateForm(Tmarginform,marginform );
  Application.CreateForm(TfrmNewTable,frmNewTable);
  Application.CreateForm(Tvsplitform,vsplitform);

  Creportform.RC.LoadFromFile(filename);
  Result := Creportform.RC;
  Creportform.Caption:= filename;

  Creportform.Thefile :=filename;
  Creportform.saveFileName := filename;
  creportform.DoCenter;
  Creportform.showmodal;
  Creportform.Free;
  frm_About.Free;
  Borderform.Free;
  Colorform.Free;
  diagonalform.Free;
  marginform.Free;
  frmNewTable.Free;
  vsplitform.Free;
end;
class function  TCreportForm.InitReport():TCreportForm;
begin
  Application.CreateForm(TCreportform,Creportform);
  Application.CreateForm(Tfrm_About, frm_About);
  Application.CreateForm(TBorderform,Borderform );
  Application.CreateForm(TColorform,Colorform );
  Application.CreateForm(Tdiagonalform,diagonalform);
  Application.CreateForm(Tmarginform,marginform );
  Application.CreateForm(TfrmNewTable,frmNewTable);
  Application.CreateForm(Tvsplitform,vsplitform);
  Result := Creportform ;
end;
class function  TCreportForm.UninitReport():TReportControl;
begin
  Creportform.Free;
  frm_About.Free;
  Borderform.Free;
  Colorform.Free;
  diagonalform.Free;
  marginform.Free;
  frmNewTable.Free;
  vsplitform.Free;
end;

end.


