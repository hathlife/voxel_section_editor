unit FormHeaderUnit;

interface

uses
  Windows, Forms, StdCtrls, Controls, Classes, ExtCtrls, Voxel, Sysutils,
  Buttons, Dialogs, Grids, Graphics,math, ComCtrls, Spin, Voxel_Engine,
  BasicDataTypes, HVA;

{$INCLUDE Global_Conditionals.inc}

type
  TFrmHeader = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label8: TLabel;
    cmbSection: TComboBox;
    Label9: TLabel;
    txtName: TEdit;
    txtNumber: TEdit;
    txtUnknown1: TEdit;
    txtUnknown2: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label15: TLabel;
    grdTrans: TStringGrid;
    Label13: TLabel;
    Image1: TImage;
    Label14: TLabel;
    Bevel1: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label16: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label1: TLabel;
    txtNormalMode: TComboBox;
    TabSheet3: TTabSheet;
    Label5: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    scaleXmin: TEdit;
    scaleYmin: TEdit;
    scaleZmin: TEdit;
    Label12: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    scaleXmax: TEdit;
    scaleYmax: TEdit;
    scaleZmax: TEdit;
    scale: TEdit;
    Label23: TLabel;
    SpCalculate: TSpeedButton;
    Label17: TLabel;
    BtnApply: TButton;
    Label24: TLabel;
    Bevel2: TBevel;
    Panel1: TPanel;
    Image2: TImage;
    Label25: TLabel;
    Label26: TLabel;
    Bevel3: TBevel;
    Panel2: TPanel;
    BtClose: TButton;
    GrpVoxelType: TGroupBox;
    rbLand: TRadioButton;
    rbAir: TRadioButton;
    SpFrame: TSpinEdit;
    procedure SpFrameChange(Sender: TObject);
    procedure cmbSectionChange(Sender: TObject);
    procedure butCloseClick(Sender: TObject);
    procedure txtChange(Sender: TObject);
    procedure grdTransSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure SpCalculateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
  private
    { Private declarations }
    p: PVoxel;
    HVA : PHVA;
  public
    { Public declarations }
    procedure SetValues(Vox: PVoxel; _HVA: PHVA);
  end;

var
  FrmHeader: TFrmHeader;

implementation

uses FormMain;

{$R *.DFM}

procedure TFrmHeader.SetValues(Vox: PVoxel; _HVA: PHVA);
var
   i: Integer;
begin
   p:=Vox;
   HVA := _HVA;
   label2.caption:='File Type: '+p^.Header.FileType;
   label3.caption:='Unknown: '+IntToStr(p^.Header.Unknown);
   label4.caption:='Num Sections: '+IntToStr(p^.Header.NumSections) + ' - ' +IntToStr(p^.Header.NumSections2);
   label6.caption:='Start: '+IntToStr(p^.Header.StartPaletteRemap);
   label7.caption:='End: '+IntToStr(p^.Header.EndPaletteRemap);
   label14.caption:= extractfilename(VXLFilename);
   if p^.Section[0].Tailer.Unknown = 2 then
      Label17.caption := 'Game: Tiberian Sun'
   else if p^.Section[0].Tailer.Unknown = 4 then
      Label17.caption := 'Game: Red Alert 2'
   else
      Label17.caption := 'Game: Unknown';
   cmbSection.Style:=csDropDownList;
   cmbSection.Items.Clear;
   for i:=0 to p^.Header.NumSections - 1 do
   begin
      cmbSection.Items.Add(p^.Section[i].Name);
   end;
   SpFrame.MinValue := 1;
   SpFrame.MaxValue := HVA^.Header.N_Frames;
   SpFrame.Value := 1;
   cmbSection.ItemIndex:=0;
   cmbSectionChange(Self);
end;

procedure TFrmHeader.cmbSectionChange(Sender: TObject);
var
   i: Integer;
begin
   //now populate those other list boxes...
   i:=cmbSection.ItemIndex;

   //Stucuk: Start and end colour values have no effect on Voxels in game, even tho they are saved into the voxel.
//  StartColour.OnChange:=nil;
//  StartColour.value := p^.Header.StartPaletteRemap;
//  StartColour.OnChange:=StartColourChange;
//  EndColour.OnChange:=nil;
//  EndColour.value := p^.Header.EndPaletteRemap;
//  EndColour.OnChange:=StartColourChange;

   txtName.OnChange:=nil;
   txtName.Text:=p^.Section[i].Name;
//  txtName.OnChange:=txtChange;
   txtNumber.OnChange:=nil;
   txtNumber.Text:=IntToStr(p^.Section[i].Header.Number);
//  txtNumber.OnChange:=txtChange;
   txtUnknown1.OnChange:=nil;
   txtUnknown1.Text:=IntToStr(p^.Section[i].Header.Unknown1);
//  txtUnknown1.OnChange:=txtChange;
   txtUnknown2.OnChange:=nil;
   txtUnknown2.Text:=IntToStr(p^.Section[i].Header.Unknown2);
//  txtUnknown2.OnChange:=txtChange;
   txtNormalMode.OnChange:=nil;
   txtNormalMode.ItemIndex := p^.Section[i].Tailer.Unknown-1;
   txtNormalMode.Text:=IntToStr(p^.Section[i].Tailer.Unknown);
//  txtNormalMode.OnChange:=txtChange;
//  txtTrailer.Lines.Clear;

   scaleXmin.OnChange:=nil;
   scaleXmin.Text := floattostr(p^.Section[i].Tailer.MinBounds[1]);
//  scaleXmin.OnChange:=txtChange;

   scaleYmin.OnChange:=nil;
   scaleYmin.Text := floattostr(p^.Section[i].Tailer.MinBounds[2]);
//  scaleYmin.OnChange:=txtChange;

   scaleZmin.OnChange:=nil;
   scaleZmin.Text := floattostr(p^.Section[i].Tailer.MinBounds[3]);
//  scaleZmin.OnChange:=txtChange;

   scaleXmax.OnChange:=nil;
   scaleXmax.Text := floattostr(p^.Section[i].Tailer.MaxBounds[1]);
//  scaleXmax.OnChange:=txtChange;

   scaleYmax.OnChange:=nil;
   scaleYmax.Text := floattostr(p^.Section[i].Tailer.MaxBounds[2]);
//  scaleYmax.OnChange:=txtChange;

   scaleZmax.OnChange:=nil;
   scaleZmax.Text := floattostr(p^.Section[i].Tailer.MaxBounds[3]);
//  scaleZmax.OnChange:=txtChange;

   scale.OnChange:=nil;
   scale.Text := floattostr(p^.Section[i].Tailer.det);
//  scale.OnChange:=txtChange;

   With p^.Section[i].Tailer do
   begin
      label1.Caption:='Dimensions: '+Format('%dx%dx%d', [XSize,YSize,ZSize]);
   end;
   SpFrameChange(Sender);
end;

procedure TFrmHeader.butCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmHeader.txtChange(Sender: TObject);
var
   i: Integer;
begin
//  ShowMessage(Sender.ClassName);
//FrmMain.Clicked := true; // Made changes to voxel... alert system
   i:=cmbSection.ItemIndex;
   if i>=0 then
   begin
      try
         if txtName.Text <> '' then
         begin
            p^.Section[i].SetHeaderName(txtName.Text);
            FrmMain.SectionCombo.Items.Strings[i] := txtName.Text;
            cmbSection.Items[i] := p^.Section[i].Name;
            cmbSection.ItemIndex := i;
         end;
         FrmMain.SectionCombo.ItemIndex:= FrmMain.Document.ActiveSection^.Header.Number;
         p^.Section[i].Header.Number:=StrToIntDef(txtNumber.Text,0);
         p^.Section[i].Header.Unknown1:=StrToIntDef(txtUnknown1.Text,1);
         p^.Section[i].Header.Unknown2:=StrToIntDef(txtUnknown2.Text,0);

         if p^.Section[i].Tailer.Unknown <> txtNormalMode.itemindex+1 then
         begin
            SetNormals(txtNormalMode.itemindex+1);
            //  p^.Section[i].Tailer.Unknown:=txtNormalMode.itemindex+1;
            if FrmMain.Document.ActiveSection^.Tailer.Unknown = 2 then
               FrmMain.StatusBar1.Panels[0].Text := 'Type: Tiberian Sun'
            else if FrmMain.Document.ActiveSection^.Tailer.Unknown = 4 then
               FrmMain.StatusBar1.Panels[0].Text := 'Type: RedAlert 2'
            else
               FrmMain.StatusBar1.Panels[0].Text := 'Type: Unknown ' + inttostr(FrmMain.Document.ActiveSection^.Tailer.Unknown);
            SetNormalsCount;
            FrmMain.cnvPalette.Refresh;
            RepaintViews;
         end;
         p^.Section[i].Tailer.MinBounds[1] := StrToFloat(scaleXmin.Text);
         p^.Section[i].Tailer.MinBounds[2] := StrToFloat(scaleYmin.Text);
         p^.Section[i].Tailer.MinBounds[3] := StrToFloat(scaleZmin.Text);
         p^.Section[i].Tailer.MaxBounds[1] := StrToFloat(scaleXmax.Text);
         p^.Section[i].Tailer.MaxBounds[2] := StrToFloat(scaleYmax.Text);
         p^.Section[i].Tailer.MaxBounds[3] := StrToFloat(scaleZmax.Text);
         p^.Section[i].Tailer.Det := StrToFloat(scale.Text);
         FrmMain.RefreshAll;
      except
         on EConvertError do
         begin
            i:=0;
         end;
      end;
   end;
end;

procedure TFrmHeader.grdTransSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
   i,j,k,Frame: Integer;
   M : TTransformMatrix;
begin
   i:=cmbSection.ItemIndex;
   Frame := StrToIntDef(SpFrame.Text,0);
   if (i>=0) and (Frame > 0) then
   begin
      try
         for j:=1 to 3 do
         begin
            for k:=1 to 4 do
            begin
               M[j,k]:=StrToFloat(grdTrans.Cells[k-1,j-1]);
            end;
         end;
         HVA^.SetMatrix(M,Frame-1,i);
      except
         on EConvertError do
         begin
            i:=0;
         end;
      end;
   end;
end;

procedure TFrmHeader.SpCalculateClick(Sender: TObject);
begin
   with p^.Section[cmbSection.ItemIndex] do
   begin
      scaleXmax.text := floattostr((Tailer.XSize /2));
      scaleZmax.text := floattostr((Tailer.ZSize /2));
      scaleXmin.text := floattostr(0 - (Tailer.XSize /2));
      scaleZmin.text := floattostr(0 - (Tailer.ZSize /2));
      if rbAir.Checked then
      begin
         scaleYmax.text := floattostr((Tailer.YSize /2));
         scaleYmin.text := floattostr(0 - (Tailer.YSize /2));
      end
      else
      begin
         scaleYmax.text := floattostr(Tailer.YSize);
         scaleYmin.text := floattostr(0);
      end;
   end;
end;

procedure TFrmHeader.SpFrameChange(Sender: TObject);
var
   MyValue,i,j: integer;
begin
   MyValue := StrToIntDef(SpFrame.Text,0);
   if (MyValue >= SpFrame.MinValue) and (MyValue <= SpFrame.MaxValue) then
   begin
      for i:=1 to 3 do
      begin
         for j:=1 to 4 do
         begin
            grdTrans.Cells[j-1,i-1]:=FloatToStr(HVA^.GetTMValue(i,j,cmbSection.ItemIndex,MyValue-1));
         end;
      end;
   end
   else
   begin
      SpFrame.Value := SpFrame.MinValue;
      SpFrameChange(Sender);
   end;
end;

procedure TFrmHeader.FormCreate(Sender: TObject);
begin
   if FrmMain.Document.ActiveSection^.Tailer.Unknown = 4 then
      FrmMain.IconList.GetIcon(2,Image1.Picture.Icon)
   else
      FrmMain.IconList.GetIcon(0,Image1.Picture.Icon);

   Panel2.DoubleBuffered := true;

   //1.3: Voxel Type Support.
   if VoxelType = vtLand then
      rbLand.Checked := true
   else
      rbAir.Checked := true;
end;

procedure TFrmHeader.BtCloseClick(Sender: TObject);
begin
   Close;
end;

end.
