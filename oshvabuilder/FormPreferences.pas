unit FormPreferences;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ImgList, StdCtrls, ComCtrls, ExtCtrls, Registry;

type
   TFrmPreferences = class(TForm)
      GbOptionsBox: TGroupBox;
      Pref_List: TTreeView;
      pcOptions: TPageControl;
      FileAssociationTab: TTabSheet;
      cbAssociate: TCheckBox;
      gbAssociationIcon: TGroupBox;
      IconPrev: TImage;
      IconID: TTrackBar;
      btnApply: TButton;
      Palette_tab: TTabSheet;
      cbUseNameSpecificPalettes: TCheckBox;
      lblTiberianSunPalette: TLabel;
      lblRedAlert2Palette: TLabel;
      cbRedAlert2Palette: TComboBoxEx;
      cbTiberianSunPalette: TComboBoxEx;
      Bevel2: TBevel;
      pnlTop: TPanel;
      ImgPreferences: TImage;
      lblPreferencesDescription: TLabel;
      lblPreferences: TLabel;
      Bevel3: TBevel;
      pnlBottom: TPanel;
      btnOK: TButton;
      btnCancel: TButton;
      Rendering_tab: TTabSheet;
      cbFPSCap: TCheckBox;
    Measures_tab: TTabSheet;
    lblLeptonSize: TLabel;
    EdLeptonSize: TEdit;
    rbCustomLeptonSize: TRadioButton;
    rbMiggyLeptonSize: TRadioButton;
    rbStuLeptonSize: TRadioButton;
    lblBulletSize: TLabel;
    EdBulletSize: TEdit;
    procedure EdLeptonSizeChange(Sender: TObject);
    procedure rbMiggyLeptonSizeClick(Sender: TObject);
    procedure rbStuLeptonSizeClick(Sender: TObject);
      procedure btnCancelClick(Sender: TObject);
      procedure btnApplyClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure IconIDChange(Sender: TObject);
      procedure Pref_ListClick(Sender: TObject);
      procedure Pref_ListKeyPress(Sender: TObject; var Key: Char);
      procedure Pref_ListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure cbUseNameSpecificPalettesClick(Sender: TObject);
      procedure btnOKClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      IconPath: String;
      procedure ExtractIcon;
      procedure GetSettings;
      procedure DefaultSettings;
      function IsFileInUse(const _FileName: string): Boolean;
      procedure SetPalette(const _PaletteName: string; var _PaletteCheckBox: TComboBoxEx);
   end;

var
   FrmPreferences: TFrmPreferences;

implementation

uses FormMain, VH_Global;

{$R *.dfm}

procedure TFrmPreferences.EdLeptonSizeChange(Sender: TObject);
var
   Value: single;
begin
   Value := StrToFloatDef(EdLeptonSize.Text, C_ONE_LEPTON);
   if Value = C_ONE_LEPTON then
   begin
      rbMiggyLeptonSize.Checked := true;
   end
   else if Value = C_ONE_LEPTON_GE then
   begin
      rbStuLeptonSize.Checked := true;
   end
   else
   begin
      rbCustomLeptonSize.Checked := true;
   end;
end;

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

{
   Res := TResourceStream.Create(hInstance,'Icon_'+IntToStr(IconID.Position+1),RT_RCDATA);
   Res.SaveToFile(IconPath);
   Res.Free;
}
end;

function TFrmPreferences.IsFileInUse(const _FileName: string): Boolean;
var
   HFileRes: HFILE;
begin
   Result := False;
   if not FileExists(_FileName) then Exit;
   HFileRes := CreateFile(PChar(_FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
   Result := (HFileRes = INVALID_HANDLE_VALUE);
   if not Result then
      CloseHandle(HFileRes);
end;

procedure TFrmPreferences.GetSettings;
var
   Reg: TRegistry;
   F: TSearchRec;
   dir, path, Name: string;
begin
   // Let's build the list of items on Tiberian Sun Palette combo box first.
   dir := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)) + '\Palettes\TS');
   if DirectoryExists(dir) then
   begin
      // prepare
      path := Concat(dir, '*.pal');
      // find files
      if FindFirst(path, faAnyFile, f) = 0 then
         repeat
            Name := IncludeTrailingPathDelimiter(Dir) + f.Name;
            if FileExists(Name) and (not IsFileInUse(Name)) then
            begin
               cbTiberianSunPalette.ItemsEx.AddItem(f.Name, 0, 0, 0, 0, 0);
            end;
         until FindNext(f) <> 0;
      FindClose(f);
   end;

   // Let's build the list of items on Red Alert 2 Palette combo box now.
   dir := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)) + '\Palettes\RA2');
   if DirectoryExists(dir) then
   begin
      // prepare
      path := Concat(dir, '*.pal');
      // find files
      if FindFirst(path, faAnyFile, f) = 0 then
         repeat
            Name := IncludeTrailingPathDelimiter(Dir) + f.Name;
            if FileExists(Name) and (not IsFileInUse(Name)) then
            begin
               cbRedAlert2Palette.ItemsEx.AddItem(f.Name, 0, 0, 0, 0, 0);
            end;
         until FindNext(f) <> 0;
      FindClose(f);
   end;


   Reg :=TRegistry.Create;
   // File Association
   Reg.RootKey := HKEY_CLASSES_ROOT;
   cbAssociate.Checked := Reg.KeyExists('\HVABuilder\shell\');
   Reg.CloseKey;
   // Other settings
   Reg.RootKey := HKEY_CURRENT_USER;
   if Reg.KeyExists('\SOFTWARE\CnC Tools\OS HVA Builder\') then
   begin
      if Reg.OpenKey('\SOFTWARE\CnC Tools\OS HVA Builder\', true) then
      begin
         // Palette Settings
         SetPalette(Reg.ReadString('TiberianSunPalette'), cbTiberianSunPalette);
         SetPalette(Reg.ReadString('RedAlert2Palette'), cbRedAlert2Palette);
         cbUseNameSpecificPalettes.Checked := Reg.ReadBool('UseNameSpecificPalette');
         // Rendering Options
         cbFPSCap.Checked := Reg.ReadBool('FPSCap');
         try
            // Bullet Size
            EdBulletSize.Text := FloatToStr(Reg.ReadFloat('BulletSize'));
            // Lepton Size
            EdLeptonSize.Text := FloatToStr(Reg.ReadFloat('LeptonSize'));
            if Reg.ReadFloat('LeptonSize') = C_ONE_LEPTON then
            begin
               rbMiggyLeptonSize.Checked := true;
            end
            else if Reg.ReadFloat('LeptonSize') = C_ONE_LEPTON_GE then
            begin
               rbStuLeptonSize.Checked := true;
            end
            else
            begin
               rbCustomLeptonSize.Checked := true;
            end;
            // And it is over.
         except
            // Bullet Size
            EdBulletSize.Text := FloatToStr(BulletSize);
            // Lepton Size
            EdLeptonSize.Text := FloatToStr(LeptonSize);
            if LeptonSize = C_ONE_LEPTON then
            begin
               rbMiggyLeptonSize.Checked := true;
            end
            else if LeptonSize = C_ONE_LEPTON_GE then
            begin
               rbStuLeptonSize.Checked := true;
            end
            else
            begin
               rbCustomLeptonSize.Checked := true;
            end;
         end;
         Reg.CloseKey;
      end
      else
      begin
         DefaultSettings;
      end;
   end
   else
   begin
      DefaultSettings;
   end;
   Reg.Free;
   IconIDChange(Self);
end;

procedure TFrmPreferences.SetPalette(const _PaletteName: string; var _PaletteCheckBox: TComboBoxEx);
var
   i: integer;
   isEnabled: boolean;
begin
   isEnabled := _PaletteCheckBox.Enabled;
   i := 0;
   _PaletteCheckBox.ItemIndex := 0;
   while i < _PaletteCheckBox.ItemsEx.Count do
   begin
      if _PaletteCheckBox.ItemsEx.Items[i].Caption = _PaletteName then
      begin
         _PaletteCheckBox.ItemIndex := i;
      end;
      inc(i);
   end;
   _PaletteCheckBox.Enabled := isEnabled;
end;

procedure TFrmPreferences.DefaultSettings;
var
   i: integer;
begin
   cbUseNameSpecificPalettes.Checked := false;
   // Get TS palette.
   SetPalette('unittem.pal', cbTiberianSunPalette);
   cbTiberianSunPalette.Enabled := false;
   // Get RA2 palette.
   SetPalette('unittem.pal', cbRedAlert2Palette);
   cbRedAlert2Palette.Enabled := false;
   // Get FPS cap.
   cbFPSCap.Checked := true;
   // Get Bullet Size
   EdBulletSize.Text := FloatToStr(C_DEFAULT_BULLET_SIZE);
   // Get Lepton Size
   rbMiggyLeptonSize.Checked := true;
   rbCustomLeptonSize.Checked := false;
   rbStuLeptonSize.Checked := false;
   EdLeptonSize.Text := FloatToStr(C_ONE_LEPTON);
end;

procedure TFrmPreferences.btnApplyClick(Sender: TObject);
var
   Reg: TRegistry;
begin
//  Config.Icon:=IconID.Position;
   ExtractIcon;
   Reg := TRegistry.Create;
   Reg.RootKey := HKEY_CLASSES_ROOT;
   if Reg.OpenKey('\HVABuilder\DefaultIcon\',true) then
   begin
      Reg.WriteString('',IconPath);
      Reg.CloseKey;
   end;

   if cbAssociate.Checked = true then
   begin
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
   end;

   // Save the other settings.
   Reg.RootKey := HKEY_CURRENT_USER;
   if Reg.OpenKey('\SOFTWARE\CnC Tools\OS HVA Builder\', true) then
   begin
      // Palette Settings
      Reg.WriteString('TiberianSunPalette', cbTiberianSunPalette.ItemsEx.Items[cbTiberianSunPalette.ItemIndex].Caption);
      Reg.WriteString('RedAlert2Palette', cbRedAlert2Palette.ItemsEx.Items[cbRedAlert2Palette.ItemIndex].Caption);
      Reg.WriteBool('UseNameSpecificPalette', cbUseNameSpecificPalettes.Checked);
      if cbUseNameSpecificPalettes.Checked then
      begin
         FrmMain.Palette[C_GAME_TS] := 'Palettes\TS\' + cbTiberianSunPalette.ItemsEx.Items[cbTiberianSunPalette.ItemIndex].Caption;
         FrmMain.Palette[C_GAME_RA2] := 'Palettes\RA2\' + cbRedAlert2Palette.ItemsEx.Items[cbRedAlert2Palette.ItemIndex].Caption;
      end
      else
      begin
         FrmMain.Palette[C_GAME_TS] := 'Palettes\TS\unittem.pal';
         FrmMain.Palette[C_GAME_RA2] := 'Palettes\RA2\unittem.pal';
      end;
      FrmMain.RefreshGame;
      // Rendering Options
      Reg.WriteBool('FPSCap', cbFPSCap.Checked);
      FrmMain.SetFPSCap(cbFPSCap.Checked);
      // Bullet Size
      BulletSize := StrToFloatDef(EdBulletSize.Text, C_DEFAULT_BULLET_SIZE);
      Reg.WriteFloat('BulletSize', BulletSize);
      // Lepton Size
      LeptonSize := StrToFloatDef(EdLeptonSize.Text, C_ONE_LEPTON);
      Reg.WriteFloat('LeptonSize', LeptonSize);
      // And it is over.
      Reg.CloseKey;
   end;
   Reg.Free;
   Close;
end;


procedure TFrmPreferences.FormShow(Sender: TObject);
begin
   GetSettings;
   pcOptions.ActivePageIndex := 0;
   gbOptionsBox.Caption := 'File Associations';
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

procedure TFrmPreferences.Pref_ListClick(Sender: TObject);
begin
   if pref_list.SelectionCount > 0 then
   begin
      if pref_list.Selected.Text = 'File Associations' then
         pcOptions.ActivePageIndex := 0
      else if pref_list.Selected.Text = 'Palette Options' then
         pcOptions.ActivePageIndex := 1
      else if pref_list.Selected.Text = 'Rendering Options' then
         pcOptions.ActivePageIndex := 2
      else if pref_list.Selected.Text = 'Measures' then
         pcOptions.ActivePageIndex := 3;

      GbOptionsBox.Caption := pref_list.Selected.Text;
   end;
end;

procedure TFrmPreferences.Pref_ListKeyPress(Sender: TObject; var Key: Char);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.Pref_ListKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Pref_ListClick(sender);
end;

procedure TFrmPreferences.rbMiggyLeptonSizeClick(Sender: TObject);
begin
   EdLeptonSize.Text := FloatToStr(C_ONE_LEPTON);
end;

procedure TFrmPreferences.rbStuLeptonSizeClick(Sender: TObject);
begin
   EdLeptonSize.Text := FloatToStr(C_ONE_LEPTON_GE);
end;

procedure TFrmPreferences.cbUseNameSpecificPalettesClick(Sender: TObject);
begin
   lblTiberianSunPalette.Enabled := cbUseNameSpecificPalettes.Checked;
   lblRedAlert2Palette.Enabled := cbUseNameSpecificPalettes.Checked;
   cbTiberianSunPalette.Enabled := cbUseNameSpecificPalettes.Checked;
   cbRedAlert2Palette.Enabled := cbUseNameSpecificPalettes.Checked;
end;

procedure TFrmPreferences.btnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmPreferences.btnOKClick(Sender: TObject);
begin
   btnApplyClick(Sender);
   Close;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
begin
   pnlTop.DoubleBuffered := true;
end;

end.
