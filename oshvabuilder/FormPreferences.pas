unit FormPreferences;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ComCtrls, ExtCtrls, Registry;

type
  TFrmPreferences = class(TForm)
    GroupBox1: TGroupBox;
    Pref_List: TTreeView;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    AssociateCheck: TCheckBox;
    GroupBox3: TGroupBox;
    IconPrev: TImage;
    IconID: TTrackBar;
    BtnApply: TButton;
    TabSheet2: TTabSheet;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox2: TComboBoxEx;
    ComboBox1: TComboBoxEx;
    Bevel2: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label9: TLabel;
    Label10: TLabel;
    Bevel3: TBevel;
    Panel2: TPanel;
    Button4: TButton;
    Button1: TButton;
    procedure BtnApplyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IconIDChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Pref_ListClick(Sender: TObject);
    procedure Pref_ListKeyPress(Sender: TObject; var Key: Char);
    procedure Pref_ListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IconPath: String;
    procedure ExtractIcon;
    procedure GetSettings;
  end;

var
  FrmPreferences: TFrmPreferences;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmPreferences.ExtractIcon;
var
  sWinDir: String;
  iLength: Integer;
  {Res: TResourceStream; }
  MIcon: TIcon;
begin

  // Initialize Variable
  iLength := 255;
  setLength(sWinDir, iLength);
  iLength := GetWindowsDirectory(PChar(sWinDir), iLength);
  setLength(sWinDir, iLength);
  IconPath := sWinDir + '\hvabuilder'+inttostr(IconID.Position)+'.ico';

  MIcon := TIcon.Create;
  FrmMain.IconList.GetIcon(IconID.Position,MIcon);
  MIcon.SaveToFile(IconPath);
  MIcon.Free;

  {Res := TResourceStream.Create(hInstance,'Icon_'+IntToStr(IconID.Position+1),RT_RCDATA);
  Res.SaveToFile(IconPath);
  Res.Free;}
end;

procedure TFrmPreferences.GetSettings;
var
  Reg: TRegistry;
begin
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_CLASSES_ROOT;
   AssociateCheck.Checked := Reg.KeyExists('\HVABuilder\shell\');
   Reg.CloseKey;
   Reg.Free;
   IconIDChange(Self);
end;

procedure TFrmPreferences.BtnApplyClick(Sender: TObject);
var
  Reg: TRegistry;
begin
//  Config.Icon:=IconID.Position;
   ExtractIcon;
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_CLASSES_ROOT;
   if Reg.OpenKey('\HVABuilder\DefaultIcon\',true) then
   begin
      Reg.WriteString('',IconPath);
      Reg.CloseKey;
   end;
   Reg.Free;

   if AssociateCheck.Checked = true then
   begin
      Reg :=TRegistry.Create;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.OpenKey('\.hva\',true) then
      begin
         Reg.WriteString('','HVABuilder');
         Reg.CloseKey;
      end;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      if Reg.OpenKey('\HVABuilder\shell\',true) then
      begin
         Reg.WriteString('','Open');
         if Reg.OpenKey('\HVABuilder\shell\open\command\',true) then
         begin
            Reg.WriteString('',ParamStr(0)+' %1');
            Reg.CloseKey;
         end;
      end;
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.hva\',true) then
      begin
         Reg.WriteString('Application',ParamStr(0)+' "%1"');
         Reg.CloseKey;
      end;
      Reg.Free;
      Close;
   end
   else
   begin
      //  Config.Assoc:=False;
      Reg :=TRegistry.Create;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      Reg.DeleteKey('.hva');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CLASSES_ROOT;
      Reg.DeleteKey('\HVABuilder\');
      Reg.CloseKey;
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.hva\');
      Reg.CloseKey;
      Reg.Free;
      Close;
   end;
end;


procedure TFrmPreferences.FormShow(Sender: TObject);
begin
   GetSettings;
   PageControl1.ActivePageIndex := 0;
   GroupBox1.Caption := 'File Associations';
end;

procedure TFrmPreferences.IconIDChange(Sender: TObject);
var
   MIcon: TIcon;//Icon: TResourceStream;
begin
   // Icon := TResourceStream.Create(hInstance,'Icon_'+IntToStr(IconID.Position+1),RT_RCDATA);
   MIcon := TIcon.Create;
   FrmMain.IconList.GetIcon(IconID.Position,MIcon);
   IconPrev.Picture.Icon := MIcon;
   // Icon.Free;
   MIcon.Free;
end;

procedure TFrmPreferences.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmPreferences.Pref_ListClick(Sender: TObject);
begin
   if pref_list.SelectionCount > 0 then
   begin
      if pref_list.Selected.Text = 'File Associations' then
         PageControl1.ActivePageIndex := 0;

      GroupBox1.Caption := pref_list.Selected.Text;
   end;
end;

procedure TFrmPreferences.Pref_ListKeyPress(Sender: TObject;
  var Key: Char);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.Pref_ListKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
Pref_ListClick(sender);
end;

procedure TFrmPreferences.CheckBox1Click(Sender: TObject);
begin
   Label1.Enabled := CheckBox1.Checked;
   Label2.Enabled := CheckBox1.Checked;
   ComboBox1.Enabled := CheckBox1.Checked;
   ComboBox2.Enabled := CheckBox1.Checked;
end;

procedure TFrmPreferences.Button4Click(Sender: TObject);
begin
   BtnApplyClick(Sender);
   Close;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
begin
   Panel1.DoubleBuffered := true;
end;

end.
