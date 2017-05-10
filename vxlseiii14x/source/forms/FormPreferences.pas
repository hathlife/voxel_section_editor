unit FormPreferences;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ComCtrls, ExtCtrls, Registry, Voxel_Engine, Spin;

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
    BtOK: TButton;
    BtCancel: TButton;
    ThreeDOptions_tab: TTabSheet;
    CbFPSCap: TCheckBox;
    SpFPSCap: TSpinEdit;
    Label3: TLabel;
    CbOpenCL: TCheckBox;
    TwoDOptions_tab: TTabSheet;
    pnl3DBackgroundColour: TPanel;
    Label4: TLabel;
    BtReset3DBackColor: TButton;
    ColorDialog1: TColorDialog;
    pnl2DBackgroundColour: TPanel;
    Label5: TLabel;
    BtReset2DBackColor: TButton;
    Normals_tab: TTabSheet;
    CbResetNormalValue: TCheckBox;
    procedure pnl2DBackgroundColourClick(Sender: TObject);
    procedure BtReset2DBackColorClick(Sender: TObject);
    procedure pnl3DBackgroundColourClick(Sender: TObject);
    procedure BtReset3DBackColorClick(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IconIDChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Pref_ListClick(Sender: TObject);
    procedure Pref_ListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Pref_ListKeyPress(Sender: TObject; var Key: Char);
    procedure Pref_ListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox1Click(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IconPath: String;
    procedure ExtractIcon;
    procedure GetSettings;
  end;


implementation

uses FormMain, GlobalVars;

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
   IconPath := sWinDir + '\vxlse'+inttostr(IconID.Position)+'.ico';

   MIcon := TIcon.Create;
   FrmMain.IconList.GetIcon(IconID.Position,MIcon);
   MIcon.SaveToFile(IconPath);
   MIcon.Free;
end;

procedure TFrmPreferences.GetSettings;
begin
   IconIDChange(Self);
end;

procedure TFrmPreferences.BtnApplyClick(Sender: TObject);
var
  Reg: TRegistry;
begin
   ExtractIcon;
   Reg :=TRegistry.Create;
   try
      Reg.RootKey := HKEY_CURRENT_USER;

      Configuration.Icon := IconID.Position;
      Configuration.Assoc := AssociateCheck.Checked;
      Configuration.Palette := CheckBox1.Checked;

      if ComboBox1.ItemIndex = 0 {< 1}then
         Configuration.TS := 'TS'
      else if ComboBox1.ItemIndex = 1 then
         Configuration.TS := 'RA2'
      else
      begin
         ShowMessage('I am going here with ' + IntToStr(ComboBox1.ItemIndex));
         Configuration.TS := ComboBox1.Items.Strings[ComboBox1.ItemIndex];
      end;

      if ComboBox2.ItemIndex = 0 then
         Configuration.RA2 := 'TS'
      else if (ComboBox2.ItemIndex = 1) then// or (frm.ComboBox2.ItemIndex = -1) then
         Configuration.RA2 := 'RA2'
      else
         Configuration.RA2 := ComboBox2.Items.Strings[ComboBox2.ItemIndex];

      if cbFPSCap.Checked then
         Configuration.FPSCap := StrToIntDef(SpFPSCap.Text,70)
      else
         Configuration.FPSCap := 0;
      GlobalVars.Render.SetFPS(Configuration.FPSCap);

      if cbOpenCL.Checked then
         Configuration.OpenCL := true
      else
         Configuration.OpenCL := false;
      GlobalVars.Render.EnableOpenCL := Configuration.OpenCL;

      Configuration.Canvas2DBackgroundColor := longword(pnl2DBackgroundColour.Color);

      Configuration.Canvas3DBackgroundColor := longword(pnl3DBackgroundColour.Color);
      FrmMain.Env.SetBackgroundColour(Configuration.Canvas3DBackgroundColor);

      if cbResetNormalValue.Checked then
         Configuration.ResetNormalValue := true
      else
         Configuration.ResetNormalValue := false;

      if Reg.OpenKey('\SOFTWARE\Classes\VXLSe\DefaultIcon\',true) then
      begin
         Reg.WriteString('',IconPath);
         Reg.CloseKey;
      end;

      if AssociateCheck.Checked = true then
      begin
         Reg.RootKey := HKEY_CURRENT_USER;
         if Reg.OpenKey('\SOFTWARE\Classes\.vxl\',true) then
         begin
            Reg.WriteString('','VXLSe');
            Reg.CloseKey;
            Reg.RootKey := HKEY_CURRENT_USER;
            if Reg.OpenKey('\SOFTWARE\Classes\VXLSe\shell\',true) then
            begin
               Reg.WriteString('','Open');
               if Reg.OpenKey('\VXLSe\shell\open\command\',true) then
               begin
                  Reg.WriteString('',ParamStr(0)+' %1');
               end;
               Reg.CloseKey;
               Reg.RootKey := HKEY_CURRENT_USER;
               if Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.vxl\',true) then
               begin
                  Reg.WriteString('Application',ParamStr(0)+' "%1"');
                  Reg.CloseKey;
               end
               else
               begin
                  ShowMessage('VXLSE III was not able to associate .vxl files because you are under a non-administrative account or does not have enough rights to do it. Contact the system administrator if you need any help');
               end;
            end
            else
            begin
               ShowMessage('VXLSE III was not able to associate .vxl files because you are under a non-administrative account or does not have enough rights to do it. Contact the system administrator if you need any help');
               close;
            end;
         end
         else
         begin
            ShowMessage('VXLSE III was not able to associate .vxl files because you are under a non-administrative account or does not have enough rights to do it. Contact the system administrator if you need any help');
            close;
         end;
      end
      else
      begin
         Reg.RootKey := HKEY_CURRENT_USER;
         Reg.DeleteKey('SOFTWARE\Classes\.vxl');
         Reg.CloseKey;
         Reg.RootKey := HKEY_CURRENT_USER;
         Reg.DeleteKey('SOFTWARE\Classes\VXLSe\');
         Reg.CloseKey;
         Reg.RootKey := HKEY_CURRENT_USER;
         Reg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.vxl\');
         Reg.CloseKey;
      end;
   finally
      Reg.Free;
   end;
end;

function GetComboBoxNo(filename:string; default : cardinal): cardinal;
var
   f_name : string;
begin
   f_name := ansilowercase(filename);
   result := default;

   if f_name = 'vxlseii_ts.vpal' then
      result := 0
   else if f_name = 'vxlseii_ra2.vpal' then
      result := 1
   else if f_name = 'vxlseii.vpal' then
      result := 2
end;

function GetFilenameFromNo(itemindex:cardinal): string;
begin
   if itemindex = 0 then
      result := 'vxlseii_ts.vpal'
   else if itemindex = 1 then
      result := 'vxlseii_ra2.vpal'
   else if itemindex = 2 then
      result := 'vxlseii.vpal';
end;


procedure TFrmPreferences.FormShow(Sender: TObject);
begin
   GetSettings;
   PageControl1.ActivePageIndex := 0;
   GroupBox1.Caption := 'File Associations';

   ComboBox1.ItemIndex := 0;
   ComboBox2.ItemIndex := 1;
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

procedure TFrmPreferences.pnl2DBackgroundColourClick(Sender: TObject);
begin
   if ColorDialog1.Execute then
   begin
      pnl2DBackgroundColour.Color := ColorDialog1.Color;
   end;
end;

procedure TFrmPreferences.pnl3DBackgroundColourClick(Sender: TObject);
begin
   if ColorDialog1.Execute then
   begin
      pnl3DBackgroundColour.Color := ColorDialog1.Color;
   end;
end;

procedure TFrmPreferences.BtReset2DBackColorClick(Sender: TObject);
begin
   pnl2DBackgroundColour.Color := RGB(140,170,235);
end;

procedure TFrmPreferences.BtReset3DBackColorClick(Sender: TObject);
begin
   pnl3DBackgroundColour.Color := RGB(140,170,235);
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
      if pref_list.Selected.Text = 'Palette' then
         PageControl1.ActivePageIndex := 1;
      if pref_list.Selected.Text = '3D Options' then
         PageControl1.ActivePageIndex := 2;
      if pref_list.Selected.Text = '2D Options' then
         PageControl1.ActivePageIndex := 3;
      if pref_list.Selected.Text = 'Normals' then
         PageControl1.ActivePageIndex := 4;
      GroupBox1.Caption := pref_list.Selected.Text;
   end;
end;

procedure TFrmPreferences.Pref_ListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.Pref_ListKeyPress(Sender: TObject;
  var Key: Char);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.Pref_ListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFrmPreferences.BtOKClick(Sender: TObject);
begin
   BtnApplyClick(Sender);
   BtOK.Enabled := false;
   BtnApply.Enabled := false;
   FrmMain.RefreshAll;
   Close;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
var
   x : integer;
begin
   Panel1.DoubleBuffered := true;
   Image1.Picture := FrmMain.TopBarImageHolder.Picture;

   IconID.Max := FrmMain.IconList.Count-1;
   IconID.Position := Configuration.Icon;
   AssociateCheck.Checked := Configuration.Assoc;

   CheckBox1.Checked := Configuration.Palette;

   ComboBox1.Clear;
   ComboBox1.Items.Add('unittem.pal');
   ComboBox1.ItemsEX.Items[ComboBox1.Items.Count-1].ImageIndex := 15;

   ComboBox1.Items.Add('unittem.pal');
   ComboBox1.ItemsEX.Items[ComboBox1.Items.Count-1].ImageIndex := 16;

   for x := Low(FrmMain.PaletteControl.PaletteSchemes) to High(FrmMain.PaletteControl.PaletteSchemes) do
   begin
      ComboBox1.Items.Add(ExtractFileName(FrmMain.PaletteControl.PaletteSchemes[x].Filename));
      ComboBox1.ItemsEX.Items[ComboBox1.Items.Count-1].ImageIndex := 24;
   end;

   ComboBox2.Clear;
   ComboBox2.Items.Add('unittem.pal');
   ComboBox2.ItemsEX.Items[ComboBox2.Items.Count-1].ImageIndex := 15;

   ComboBox2.Items.Add('unittem.pal');
   ComboBox2.ItemsEX.Items[ComboBox2.Items.Count-1].ImageIndex := 16;

   for x := Low(FrmMain.PaletteControl.PaletteSchemes) to High(FrmMain.PaletteControl.PaletteSchemes) do
   begin
      ComboBox2.Items.Add(ExtractFileName(FrmMain.PaletteControl.PaletteSchemes[x].Filename));
      ComboBox2.ItemsEX.Items[ComboBox2.Items.Count-1].ImageIndex := 24;
   end;

   // 3D Options
   CbFPSCap.Checked := Configuration.FPSCap <> 0;
   SpFPSCap.Value := Configuration.FPSCap;
   CbOpenCL.Enabled := GlobalVars.Render.IsOpenCLAllowed;
   CbOpenCL.Checked := Configuration.OpenCL and GlobalVars.Render.IsOpenCLAllowed;
   pnl2DBackgroundColour.Color := Configuration.Canvas2DBackgroundColor;
   pnl3DBackgroundColour.Color := Configuration.Canvas3DBackgroundColor;

   // Normals
   CbResetNormalValue.Checked := Configuration.ResetNormalValue;
end;

end.
