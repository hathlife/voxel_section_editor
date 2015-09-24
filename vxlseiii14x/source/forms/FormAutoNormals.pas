unit FormAutoNormals;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Voxel_Engine, Voxel_Tools, Voxel, VoxelUndoEngine, Voxel_AutoNormals;

const
   // I've found these magic numbers in the sphere area:
   // sqrt(NumNormals / (4 * pi) = MagicNumber

   // NumNormals is 244 for RA2 and 36 for TS.
   // It technically finds the ray of the sphere.
   TS_MAGIC_NUMBER = 1.6925687506432688608442383546829;
   RA2_MAGIC_NUMBER = 3.5449077018110320545963349666812;
   RANGE_DEFAULT = 1;
   RANGE_CUSTOM = 2;

   AUTONORMALS_TANGENT = '8.4';
   AUTONORMALS_INFLUENCE = '7.1';
   AUTONORMALS_CUBED = '5.6';
   AUTONORMALS_6FACED = '1.1';

type
   TFrmAutoNormals = class(TForm)
      GbNormalizationMethod: TGroupBox;
      RbInfluence: TRadioButton;
      RbCubed: TRadioButton;
      Rb6Faced: TRadioButton;
      GbInfluenceOptions: TGroupBox;
      LbRange: TListBox;
      Label1: TLabel;
      Label2: TLabel;
      EdRange: TEdit;
      Label3: TLabel;
      CbSmoothMe: TCheckBox;
      BtOK: TButton;
      BtCancel: TButton;
      Label4: TLabel;
      Label5: TLabel;
      Label6: TLabel;
      CbInfluenceMap: TCheckBox;
      BtTips: TButton;
      CbNewPixelsOnly: TCheckBox;
      CbIncreaseContrast: TCheckBox;
      Label7: TLabel;
      EdContrast: TEdit;
      EdSmooth: TEdit;
      Label8: TLabel;
      RbTangent: TRadioButton;
      RbHBD: TRadioButton;
      procedure RbHBDClick(Sender: TObject);
      procedure RbTangentClick(Sender: TObject);
      procedure BtTipsClick(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
      procedure Rb6FacedClick(Sender: TObject);
      procedure RbCubedClick(Sender: TObject);
      procedure RbInfluenceClick(Sender: TObject);
      procedure EdRangeChange(Sender: TObject);
      procedure LbRangeClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure BtCancelClick(Sender: TObject);
   private
      { Private declarations }
      procedure ShowInfluenceOptions(value : boolean);
   public
      { Public declarations }
      MyVoxel : TVoxelSection;
   end;

implementation

{$R *.dfm}

uses FormMain;

procedure TFrmAutoNormals.ShowInfluenceOptions(value : boolean);
begin
   GbInfluenceOptions.Enabled := value;
   LbRange.Enabled := value;
   EdRange.Enabled := value and (LbRange.ItemIndex = RANGE_CUSTOM);
   CbSmoothMe.Enabled := value and (not RbTangent.Checked) and (not RbHBD.Checked);
   CbInfluenceMap.Enabled := value and RbCubed.Checked;
   CbIncreaseContrast.Enabled := value and RbInfluence.Checked;
   EdContrast.Enabled := value and (not RbTangent.Checked) and (not RbHBD.Checked);
   EdSmooth.Enabled := value and (not RbTangent.Checked);
   CbNewPixelsOnly.Enabled := value and (not RbTangent.Checked) and (not RbHBD.Checked);
   if RbInfluence.Checked then
   begin
      CbIncreaseContrast.Caption := 'Stretch Influence Map';
      CbIncreaseContrast.Enabled := true;
   end
   else if RbTangent.Checked then
   begin
      CbIncreaseContrast.Caption := 'Treat Descontinuities';
      CbIncreaseContrast.Enabled := true;
   end
   else
   begin
      CbIncreaseContrast.Caption := 'Stretch Influence Map';
      CbIncreaseContrast.Enabled := false;
   end;
end;

procedure TFrmAutoNormals.FormShow(Sender: TObject);
begin
   case Configuration.ANType of
      0:
      begin
         RbTangent.Checked := true;
         RbTangentClick(Sender);
      end;
      1:
      begin
         RbInfluence.Checked := true;
         RbInfluenceClick(Sender);
      end;
      2:
      begin
         RbCubed.Checked := true;
         RbCubedClick(Sender);
      end;
      3:
      begin
         Rb6Faced.Checked := true;
         Rb6FacedClick(Sender);
      end;
      4:
      begin
         RbHBD.Checked := true;
         RbHBDClick(Sender);
      end;
   end;
   EdRange.Text := FloatToStr(Configuration.ANNormalizationRange);
   if Configuration.ANNormalizationRange = TS_MAGIC_NUMBER then
   begin
      LbRange.ItemIndex := 0;
   end
   else if Configuration.ANNormalizationRange = RA2_MAGIC_NUMBER then
   begin
      LbRange.ItemIndex := 1;
   end
   else
   begin
      LbRange.ItemIndex := RANGE_CUSTOM;
   end;
   CbSmoothMe.Checked := Configuration.ANSmoothMyNormals;
   CbInfluenceMap.Checked := Configuration.ANInfluenceMap;
   CbNewPixelsOnly.Checked := Configuration.ANNewPixels;
   CbIncreaseContrast.Checked := Configuration.ANStretch;
   EdSmooth.Text := FloatToStr(Configuration.ANSmoothLevel);
   EdContrast.Text := FloatToStr(Configuration.ANContrastLevel);
   //RbTangent.Checked := true;
   //ShowInfluenceOptions(true);
   //LbRange.ItemIndex := RANGE_DEFAULT;
   //LbRangeClick(Sender);
   Caption := 'AutoNormals ' + AUTONORMALS_TANGENT;
   RbTangent.Caption := 'Tangent Plane Auto Normals (v' + AUTONORMALS_TANGENT + ', recommended)';
   RbInfluence.Caption := 'Influence Auto Normals (v' + AUTONORMALS_INFLUENCE + ')';
   RbCubed.Caption := 'Cubed Auto Normals (v' + AUTONORMALS_CUBED + ')';
   Rb6Faced.Caption := '6-Faced Auto Normals (v' + AUTONORMALS_6FACED + ')';
   RbHBD.Caption := 'HBD AutoNormals (Quick`n`Good.)';
   //GbInfluenceOptions.Caption := 'Tangent Plane Normalizer Options..';
end;

procedure TFrmAutoNormals.LbRangeClick(Sender: TObject);
begin
   if LbRange.ItemIndex = -1 then
      LbRange.ItemIndex := RANGE_DEFAULT;
   case (LbRange.ItemIndex) of
      0: EdRange.Text := FloatToStr(TS_MAGIC_NUMBER);
      1: EdRange.Text := FloatToStr(RA2_MAGIC_NUMBER);
   end;
   EdRange.Enabled := (LbRange.ItemIndex = RANGE_CUSTOM);
end;

procedure TFrmAutoNormals.EdRangeChange(Sender: TObject);
var
   Range : single;
   Contrast : integer;
   Smooth : single;
begin
   BtOK.Enabled := true;
   Range := StrToFloatDef(EdRange.Text,0);
   Contrast := StrToIntDef(EdContrast.Text,1);
   Smooth := StrToFloatDef(EdSmooth.Text,1);
   if (Range < 1) or (Contrast < 1) or (Smooth < 1) then
      BtOK.Enabled := false;
end;

procedure TFrmAutoNormals.RbTangentClick(Sender: TObject);
begin
   ShowInfluenceOptions(RbTangent.Checked);
   Configuration.ANType := 0;
   GbInfluenceOptions.Caption := 'Tangent Plane Normalizer Options..';
end;

procedure TFrmAutoNormals.RbInfluenceClick(Sender: TObject);
begin
   ShowInfluenceOptions(RbInfluence.Checked);
   Configuration.ANType := 1;
   GbInfluenceOptions.Caption := 'Influence Normalizer Options..';
end;

procedure TFrmAutoNormals.RbCubedClick(Sender: TObject);
begin
   ShowInfluenceOptions(RbCubed.Checked);
   Configuration.ANType := 2;
   GbInfluenceOptions.Caption := 'Smooth Cubed Normalizer Options..';
end;

procedure TFrmAutoNormals.Rb6FacedClick(Sender: TObject);
begin
   ShowInfluenceOptions(not Rb6Faced.Checked);
   Configuration.ANType := 3;
   GbInfluenceOptions.Caption := '6-Faced Normalizer Options..';
end;

procedure TFrmAutoNormals.RbHBDClick(Sender: TObject);
begin
   ShowInfluenceOptions(RbHBD.Checked);
   Configuration.ANType := 4;
   GbInfluenceOptions.Caption := 'HBD Normalizer Options..';
end;

procedure TFrmAutoNormals.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmAutoNormals.BtOKClick(Sender: TObject);
var
   Res : TApplyNormalsResult;
   Range,Smooth : single;
   Contrast : integer;
   AutoNormalsApplied: boolean;
begin
   AutoNormalsApplied := false;
   BtOK.Enabled := false;
   If RbTangent.Checked then
   begin
      Range := StrToFloatDef(EdRange.Text,0);
      if Range < 1 then
      begin
         MessageBox(0,pchar('Range Value Is Invalid. It Must Be Positive and Higher Than 1. Using 3.54 (Default).'),'Auto Normals Warning',0);
         Range := RA2_MAGIC_NUMBER;
      end;
      AutoNormalsApplied := true;
      CreateVXLRestorePoint(FrmMain.Document.ActiveSection^,Undo);
      FrmMain.UpdateUndo_RedoState;
      Res := AcharNormais(MyVoxel,Range,CbIncreaseContrast.Checked);
      MessageBox(0,pchar('AutoNormals v' + AUTONORMALS_TANGENT + #13#13 + 'Total: ' + inttostr(Res.applied) + ' voxels modified.'),'Tangent Plane Auto Normal Results',0);
   end
   else If RbInfluence.Checked then
   begin
      Range := StrToFloatDef(EdRange.Text,0);
      Contrast := StrToIntDef(EdContrast.Text,1);
      if CbSmoothMe.Checked and CbSmoothMe.Enabled then
      begin
         Smooth := StrToFloatDef(EdSmooth.Text,1);
         if (Smooth < 1) and CbSmoothMe.Checked and CbSmoothMe.Enabled then
         begin
            MessageBox(0,pchar('Smooth Value Is Invalid. It Must Be Positive, Integer and Higher Or Equal Than 1. Using 1 (Default).'),'Auto Normals Warning',0);
            Smooth := 1;
         end;
      end
      else
         Smooth := Range;
      if Range < 1 then
      begin
         MessageBox(0,pchar('Range Value Is Invalid. It Must Be Positive and Higher Than 1. Using 3.54 (Default).'),'Auto Normals Warning',0);
         Range := RA2_MAGIC_NUMBER;
      end;
      if Contrast < 1 then
      begin
         MessageBox(0,pchar('Contrast Value Is Invalid. It Must Be Positive, Integer and Higher Or Equal Than 1. Using 1 (Default).'),'Auto Normals Warning',0);
         Contrast := 1;
      end;
      AutoNormalsApplied := true;
      CreateVXLRestorePoint(FrmMain.Document.ActiveSection^,Undo);
      FrmMain.UpdateUndo_RedoState;
      Res := ApplyInfluenceNormals(MyVoxel,Range,Smooth,Contrast,CbSmoothMe.Checked,CbNewPixelsOnly.checked,CbIncreaseContrast.checked);
      MessageBox(0,pchar('AutoNormals v' + AUTONORMALS_INFLUENCE + #13#13 + 'Total: ' + inttostr(Res.applied) + ' voxels modified.'),'Influence Auto Normal Results',0);
   end
   else if RbCubed.Checked then
   begin
      Range := StrToFloatDef(EdRange.Text,0);
      Contrast := StrToIntDef(EdContrast.Text,1);
      if CbSmoothMe.Checked and CbSmoothMe.Enabled then
      begin
         Smooth := StrToFloatDef(EdSmooth.Text,1);
         if (Smooth < 1) and CbSmoothMe.Checked and CbSmoothMe.Enabled then
         begin
            MessageBox(0,pchar('Smooth Value Is Invalid. It Must Be Positive, Integer and Higher Or Equal Than 1. Using 1 (Default).'),'Auto Normals Warning',0);
            Smooth := 1;
         end;
      end
      else
         Smooth := Range;
      if Range < 1 then
      begin
         MessageBox(0,pchar('Range Value Is Invalid. It Must Be Positive and Higher Than 1. Using 3.54 (Default).'),'Auto Normals Warning',0);
         Range := RA2_MAGIC_NUMBER;
      end;
      if Contrast < 1 then
      begin
         MessageBox(0,pchar('Contrast Value Is Invalid. It Must Be Positive, Integer and Higher Or Equal Than 1. Using 1 (Default).'),'Auto Normals Warning',0);
         Contrast := 1;
      end;
      AutoNormalsApplied := true;
      CreateVXLRestorePoint(FrmMain.Document.ActiveSection^,Undo);
      FrmMain.UpdateUndo_RedoState;
      Res := ApplyCubedNormals(MyVoxel,Range,Smooth,Contrast,CbSmoothMe.Checked,CbInfluenceMap.Checked,CbNewPixelsOnly.checked);
      MessageBox(0,pchar('AutoNormals v' + AUTONORMALS_CUBED + #13#13 + 'Total: ' + inttostr(Res.applied) + ' voxels modified.'),'Cubed Auto Normal Results',0);
   end
   else if RbHBD.Checked then
   begin
      Range := StrToFloatDef(EdRange.Text,0);
      if Range < 1 then
      begin
         MessageBox(0,pchar('Range Value Is Invalid. It Must Be Positive and Higher Than 1. Using 3.54 (Default).'),'Auto Normals Warning',0);
         Range := RA2_MAGIC_NUMBER;
      end;
      Smooth := StrToFloatDef(EdSmooth.Text,1);
      if (Smooth < 1) then
      begin
         MessageBox(0,pchar('Smooth Value Is Invalid. It Must Be Positive, Integer and Higher Or Equal Than 1. Using 1 (Default).'),'Auto Normals Warning',0);
         Smooth := 1;
      end
      else
         Smooth := Range;
      AutoNormalsApplied := true;
      CreateVXLRestorePoint(FrmMain.Document.ActiveSection^,Undo);
      FrmMain.UpdateUndo_RedoState;
      velAutoNormals2(MyVoxel, Range, Smooth);
      ShowMessage('AutoNormals HBD' + #13#13 + 'Operation Completed!');
   end
   else
   begin
      AutoNormalsApplied := true;
      CreateVXLRestorePoint(FrmMain.Document.ActiveSection^,Undo);
      FrmMain.UpdateUndo_RedoState;
      Res := ApplyNormals(MyVoxel);
      if Res.confused > 0 then
      begin
         MessageBox(0,pchar('AutoNormals v' + AUTONORMALS_6FACED + #13#13 + 'Total: ' + inttostr(Res.applied + Res.confused) + #13 +'Applied: ' + inttostr(Res.applied) + #13 + 'Confused: ' +inttostr(Res.confused) + #13 + #13 + 'Some were Confused, This may mean there are redundant voxels.'),'6-Faced Auto Normal Results',0);
         if FrmMain.p_Frm3DPreview <> nil then
         begin
            FrmMain.p_Frm3DPreview^.Visible := false;
         end;
         FrmMain.RemoveRedundantVoxels1Click(Sender);
         if FrmMain.p_Frm3DPreview <> nil then
         begin
            FrmMain.p_Frm3DPreview^.Visible := true;
         end;
      end
      else
      begin
         MessageBox(0,pchar('AutoNormals v' + AUTONORMALS_6FACED + #13#13 + 'Total: ' + inttostr(Res.applied + Res.confused) + #13 +'Applied: ' + inttostr(Res.applied) + #13 + 'Confused: ' +inttostr(Res.confused)),'6-Faced Auto Normal Results',0);
      end;
   end;

   // Update configurations.
   if AutoNormalsApplied = true then
   begin
      Configuration.ANSmoothMyNormals := CbSmoothMe.Checked;
      Configuration.ANInfluenceMap := CbInfluenceMap.Checked;
      Configuration.ANNewPixels := CbNewPixelsOnly.Checked;
      Configuration.ANStretch := CbIncreaseContrast.Checked;
      Configuration.ANNormalizationRange := StrToFloatDef(EdRange.Text, 0);
      Configuration.ANSmoothLevel := StrToFloatDef(EdSmooth.Text, 1);
      Configuration.ANContrastLevel := StrToFloatDef(EdContrast.Text, 1);

      FrmMain.SetVoxelChanged(true);
      FrmMain.Refreshall;
      Close;
   end
   else
   begin
      BtOK.Enabled := true;
   end;
end;

procedure TFrmAutoNormals.BtTipsClick(Sender: TObject);
begin
   FrmMain.OpenHyperLink('http://www.ppmsite.com/index.php?go=normalstips');
end;

end.
