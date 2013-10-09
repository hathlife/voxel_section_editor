unit FormHVA;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, HVA, ogl3dview_engine, ExtCtrls, GlobalVars;

type
  TFrmTestHVA = class(TForm)
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    RichEdit1: TRichEdit;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmTestHVA: TFrmTestHVA;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmTestHVA.FormShow(Sender: TObject);
begin
  FrmMain.Document.ActiveHVA^.Frame := 0;
  FrmMain.Document.ActiveHVA^.Section := FrmMain.SectionCombo.ItemIndex;
  Label1.Caption := 'Section: ' + FrmMain.SectionCombo.Items.Strings[FrmMain.Document.ActiveHVA^.Section];
  SpinEdit1.Value := FrmMain.Document.ActiveHVA^.Frame;
//  HVATEST := true;
//  PopulateMatrix;
end;

procedure TFrmTestHVA.SpinEdit1Change(Sender: TObject);
begin
   try
      if SpinEdit1.Value > FrmMain.Document.ActiveHVA^.Header.N_Frames-1 then
         SpinEdit1.Value := 0;
      if SpinEdit1.Value < 0 then
         SpinEdit1.Value := FrmMain.Document.ActiveHVA^.Header.N_Frames-1;
   except
      exit;
   end;
   FrmMain.Document.ActiveHVA^.Frame := SpinEdit1.Value;
end;

procedure TFrmTestHVA.Button1Click(Sender: TObject);
begin
   Timer1.Enabled := not Timer1.Enabled;
end;

procedure TFrmTestHVA.Timer1Timer(Sender: TObject);
begin
   if FrmMain.Document.ActiveHVA^.Section <> FrmMain.SectionCombo.ItemIndex then
   begin
      FrmMain.Document.ActiveHVA^.Section := FrmMain.SectionCombo.ItemIndex;
      Label1.Caption := 'Section: ' + FrmMain.SectionCombo.Items.Strings[FrmMain.Document.ActiveHVA^.Section];
   end;
   SpinEdit1.Value := SpinEdit1.Value +1;
   SpinEdit1Change(Sender);
end;

end.
