object CReportDemoForm: TCReportDemoForm
  Left = 315
  Top = 238
  Width = 667
  Height = 437
  Caption = 'creport demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 16
    Top = 48
    Width = 489
    Height = 209
    Color = clWhite
    DataSource = Dataform.DataSource1
    ImeName = #20116#31508#30011
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'No'
        Title.Caption = #24207#21495
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Cassname'
        Title.Caption = #21697#21517
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Lb'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Bz'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Hh'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Sx'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Bm'
        Title.Caption = #22270#29255
        Visible = True
      end>
  end
  object ReportRunTime1: TReportRunTime
    Left = 423
    Top = 16
    Width = 20
    Height = 33
    Visible = False
    AddSpace = True
  end
  object dbimg1: TDBImage
    Left = 16
    Top = 264
    Width = 489
    Height = 105
    DataField = 'bm'
    DataSource = Dataform.DataSource1
    TabOrder = 2
  end
  object ReportControl1: TReportControl
    Left = 448
    Top = 16
    Width = 25
    Height = 33
    Visible = False
  end
  object Button4: TButton
    Left = 546
    Top = 160
    Width = 83
    Height = 34
    Caption = #20851#38381
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #26999#20307'_GB2312'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button1: TButton
    Left = 546
    Top = 117
    Width = 83
    Height = 32
    Hint = 
      'E:\lzl_delphi\vcl\CReport\CReport_D5_D7\demo_d6_7\CReport_demo.e' +
      'pt'
    Caption = #32534#36753
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #26999#20307'_GB2312'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 546
    Top = 69
    Width = 83
    Height = 32
    Hint = 
      'E:\lzl_delphi\vcl\CReport\CReport_D5_D7\demo_d6_7\CReport_demo.e' +
      'pt'
    Caption = #25171#21360
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #26999#20307'_GB2312'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 547
    Top = 27
    Width = 82
    Height = 32
    Hint = 
      'E:\lzl_delphi\vcl\CReport\CReport_D5_D7\demo_d6_7\CReport_demo.e' +
      'pt'
    Caption = #39044#35272
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #26999#20307'_GB2312'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = Button5Click
  end
  object CheckBox1: TCheckBox
    Left = 20
    Top = 14
    Width = 138
    Height = 17
    Caption = #26410#28385#39029#31354#34920#26684#40784
    Checked = True
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlue
    Font.Height = -14
    Font.Name = #26999#20307'_GB2312'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 8
    OnClick = CheckBox1Click
  end
  object btnCSV: TButton
    Left = 546
    Top = 208
    Width = 83
    Height = 34
    Caption = 'CSV'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #26999#20307'_GB2312'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
    OnClick = btnCSVClick
  end
  object opbm1: TOpenPictureDialog
    Filter = 
      'All (*.jpg;*.jpeg;*.bmp;*.ico)|*.jpg;*.jpeg;*.bmp;*.ico|JPEG Ima' +
      'ge File (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg|Bitmaps (*' +
      '.bmp)|*.bmp|Icons (*.ico)|*.ico'
    Left = 248
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'XLS'
    Filter = 'Excl'#25991#20214'|*.XLS'
    Left = 208
    Top = 16
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 280
    Top = 16
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 176
    Top = 16
  end
end
