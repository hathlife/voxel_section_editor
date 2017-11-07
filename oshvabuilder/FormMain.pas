unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, Buttons, StdCtrls, ComCtrls, ImgList, Spin,FTGifAnimate,
  ToolWin, VH_Voxel, Registry, FormPreferences;

Const
APPLICATION_TITLE = 'Open Source HVA Builder';
APPLICATION_VER = '2.13';
APPLICATION_BY = 'Stucuk and Banshee';

type
  TFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    MainView: TPanel;
    OpenVXLDialog: TOpenDialog;
    Load1: TMenuItem;
    Panel4: TPanel;
    lblHVAFrame: TLabel;
    PlayAnimation: TSpeedButton;
    PauseAnimation: TSpeedButton;
    StopAnimation: TSpeedButton;
    AnimationBar: TTrackBar;
    Label2: TLabel;
    RemapImageList: TImageList;
    Label1: TLabel;
    Panel5: TPanel;
    RemapColourBox: TComboBoxEx;
    AnimationTimer: TTimer;
    StatusBar1: TStatusBar;
    RemapTimer: TTimer;
    ColorDialog: TColorDialog;
    Help1: TMenuItem;
    About1: TMenuItem;
    Panel3: TPanel;
    SpeedButton2: TSpeedButton;
    btn3DRotateX: TSpeedButton;
    btn3DRotateX2: TSpeedButton;
    btn3DRotateY2: TSpeedButton;
    btn3DRotateY: TSpeedButton;
    spin3Djmp: TSpinEdit;
    Label3: TLabel;
    Panel6: TPanel;
    SectionBox: TComboBoxEx;
    lblSection: TLabel;
    Label4: TLabel;
    Options1: TMenuItem;
    Disable3DView1: TMenuItem;
    View1: TMenuItem;
    ools1: TMenuItem;
    Spectrum1: TMenuItem;
    Views1: TMenuItem;
    N1: TMenuItem;
    CameraManager1: TMenuItem;
    ColoursNormals1: TMenuItem;
    N2: TMenuItem;
    Colours1: TMenuItem;
    Normals1: TMenuItem;
    Help2: TMenuItem;
    N3: TMenuItem;
    ScreenShot1: TMenuItem;
    N5: TMenuItem;
    BackgroundColour1: TMenuItem;
    extColour1: TMenuItem;
    CaptureAnimation1: TMenuItem;
    N6: TMenuItem;
    OpenVVSDialog: TOpenDialog;
    Make360DegreeAnimation1: TMenuItem;
    ToolBar1: TToolBar;
    BarOpen: TToolButton;
    BarSaveAs: TToolButton;
    BarReopen: TToolButton;
    ToolButton4: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    ToolButton13: TToolButton;
    ToolButton12: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ImageList: TImageList;
    IconList: TImageList;
    UpDown1: TUpDown;
    Panel7: TPanel;
    HighlightCheckBox: TCheckBox;
    DrawCenterCheckBox: TCheckBox;
    CheckBox1: TCheckBox;
    ShowDebugCheckBox: TCheckBox;
    VoxelCountCheckBox: TCheckBox;
    TopBarImageHolder: TImage;
    Panel8: TPanel;
    ControlY: TSpeedButton;
    ControlZ: TSpeedButton;
    ControlX: TSpeedButton;
    ControlType: TComboBoxEx;
    Label5: TLabel;
    SaveVoxel1: TMenuItem;
    ReOpen1: TMenuItem;
    N4: TMenuItem;
    SaveAs1: TMenuItem;
    SaveVXLDialog: TSaveDialog;
    ScreenShots1: TMenuItem;
    ViewTransform1: TMenuItem;
    N7: TMenuItem;
    Managers1: TMenuItem;
    VoxelBounds1: TMenuItem;
    RotateTo1: TMenuItem;
    RotateBy1: TMenuItem;
    HVAPosition1: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    N8: TMenuItem;
    Preferences1: TMenuItem;
    procedure MainViewResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DrawFrames;
    procedure Idle(Sender: TObject; var Done: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure OpenVoxel(var Filename: string);
    procedure Load1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MainViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MainViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MainViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure AnimationTimerTimer(Sender: TObject);
    procedure PlayAnimationClick(Sender: TObject);
    procedure PauseAnimationClick(Sender: TObject);
    procedure StopAnimationClick(Sender: TObject);
    procedure AnimationBarChange(Sender: TObject);
    Procedure SetIsHVA;
    Procedure SetIsEditable;
    Procedure SetCaption(Filename : String);
    procedure RemapColourBoxChange(Sender: TObject);
    procedure RemapTimerTimer(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btn3DRotateXClick(Sender: TObject);
    Procedure SetRotationAdders;
    procedure btn3DRotateX2Click(Sender: TObject);
    procedure btn3DRotateY2Click(Sender: TObject);
    procedure btn3DRotateYClick(Sender: TObject);
    procedure spin3DjmpChange(Sender: TObject);
    Procedure SetupSections;
    procedure SectionBoxChange(Sender: TObject);
    procedure ShowDebugCheckBoxClick(Sender: TObject);
    procedure VoxelCountCheckBoxClick(Sender: TObject);
    procedure Disable3DView1Click(Sender: TObject);
    procedure ColoursNormals1Click(Sender: TObject);
    procedure Colours1Click(Sender: TObject);
    procedure Normals1Click(Sender: TObject);
    procedure CameraManager1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    Procedure ChangeView(Sender : TObject);
    procedure ScreenShot1Click(Sender: TObject);
    procedure BackgroundColour1Click(Sender: TObject);
    procedure extColour1Click(Sender: TObject);
    procedure CaptureAnimation1Click(Sender: TObject);
    Procedure ClearRotationAdders;
    procedure Make360DegreeAnimation1Click(Sender: TObject);
    procedure UpDown1ChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Smallint; Direction: TUpDownDirection);
    procedure DrawCenterCheckBoxClick(Sender: TObject);
    procedure HighlightCheckBoxClick(Sender: TObject);
    procedure ControlYClick(Sender: TObject);
    procedure ControlZClick(Sender: TObject);
    procedure ControlXClick(Sender: TObject);
    procedure ControlTypeChange(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    Procedure CheckHVAFrames;
    Procedure CheckHVAFrames2;
    procedure SaveVoxel1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure ViewTransform1Click(Sender: TObject);
    procedure VoxelBounds1Click(Sender: TObject);
    procedure RotateBy1Click(Sender: TObject);
    procedure HVAPosition1Click(Sender: TObject);
    Procedure SetUndoRedo;
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure Preferences1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    VXLFilename2 : String;
    LoadedProg : Boolean;
  end;

var
  FrmMain: TFrmMain;

implementation

Uses VH_Engine,VH_Global,VH_GL,HVA,FormAboutNew,
     FormCameraManagerNew, ShellAPI,FormScreenShotManagerNew,
     FormAnimationManagerNew,VH_Types,FormTransformManagerNew,
     FormBoundsManagerNew,Math3d,FormRotationManagerNew,
     FormHVAPositionManagerNew;

{$R *.dfm}

procedure RunAProgram (const theProgram, itsParameters, defaultDirectory : string);
var
   rslt     : integer;
   msg      : string;
begin
   rslt := ShellExecute (0, 'open',
                        pChar (theProgram),
                        pChar (itsParameters),
                        pChar (defaultDirectory),
                        sw_ShowNormal);
   if rslt <= 32 then
   begin
      case rslt of
          0,
          se_err_OOM :             msg := 'Out of memory/resources';
          error_File_Not_Found :   msg := 'File "' + theProgram + '" not found';
          error_Path_Not_Found :   msg := 'Path not found';
          error_Bad_Format :       msg := 'Damaged or invalid exe';
          se_err_AccessDenied :    msg := 'Access denied';
          se_err_NoAssoc,
          se_err_AssocIncomplete : msg := 'Filename association invalid';
          se_err_DDEBusy,
          se_err_DDEFail,
          se_err_DDETimeOut :      msg := 'DDE error';
         se_err_Share :        msg := 'Sharing violation';
          else                    msg := 'no text';
          end; // of case
      raise Exception.Create ('ShellExecute error #' + IntToStr (rslt) + ': ' + msg);
      end;
end;

procedure TFrmMain.MainViewResize(Sender: TObject);
begin
   If oglloaded then
      glResizeWnd(MainView.Width,MainView.Height);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
   LoadedProg := false;
   RemapColourBox.ItemIndex := 1;
   SetIsEditable;
   SetCaption('');
   DrawAllOfVoxel := True;
   UnitRot := 180;
   DrawCenter := True;

   If not InitalizeVHE(ExtractFileDir(ParamStr(0)),'Palettes\ts\unittem.pal',MainView.Width,MainView.Height,MainView.Handle,-67) then
   begin
      Messagebox(0,pchar('Error Initalizing Engine'#13#13'Closing'),'VH Engine',0);
      Application.Terminate;
   end;

   VH_BuildViewMenu(Views1,ChangeView);
   VH_ChangeView(Default_View);

   ControlType.ItemIndex := 0;
   //PageControl1.ActivePage := TabSheet1;

   Application.OnIdle := Idle;
   LoadedProg := true;
end;

procedure TFrmMain.Idle(Sender: TObject; var Done: Boolean);
var
   BMP : TBitmap;
begin
   if not DrawVHWorld then exit;

   if (ScreenShot.Take) or (ScreenShot.TakeAnimation) or (ScreenShot.Take360DAnimation) then
      FUpdateWorld := True;
   DrawFrames;

   if ScreenShot.Take then
   begin
      if ScreenShot._Type = 0 then
         VH_ScreenShot(VXLFilename)
      else
         VH_ScreenShotJPG(VXLFilename,ScreenShot.CompressionRate);
      MainView.Align := alclient;
      ScreenShot.Take := false;
   end;

   if ScreenShot.TakeAnimation then
   begin
      BMP := VH_ScreenShot_BitmapResult;
      GifAnimateAddImage(BMP,false,100);
      BMP.Free;
      ScreenShot.TakeAnimation := false;
   end;

   if ScreenShot.Take360DAnimation then
   begin
      inc(ScreenShot.FrameCount);
      BMP := VH_ScreenShot_BitmapResult;
      GifAnimateAddImage(BMP,false,(100*90) div ScreenShot.Frames);
      BMP.Free;
      YRot := YRot + ScreenShot.FrameAdder;

      if ScreenShot.FrameCount >= ScreenShot.Frames then
      begin
         VH_ScreenShotGIF(GifAnimateEndGif,VXLFilename);

         YRot := ScreenShot.OldYRot;
         ScreenShot.Take360DAnimation := false;
         MainView.Align := alClient;
         AnimationTimer.Enabled := False;
         AnimationBar.Position := 0;
         AnimationBarChange(Sender);
      end;
   end;
   Done := false;
end;

procedure TFrmMain.DrawFrames;
begin
  if not oglloaded then exit;

  VH_Draw();                         // Draw the scene
end;

procedure TFrmMain.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmMain.OpenVoxel(var Filename: string);
begin
   if CompareStr(LowerCase(ExtractFileExt(Filename)),'.hva') = 0 then
   begin
      Filename[Length(Filename)-2] := 'v';
      Filename[Length(Filename)-1] := 'x';
      Filename[Length(Filename)] := 'l';
   end;
   VH_LoadVoxel(FileName);
   VXLFilename2 := FileName;

   //If HVAOpen then
   SetCaption(FileName);

   SetupSections;
   SectionBox.ItemIndex := 0;
   SectionBoxChange(nil);

   SetIsEditable;

   If HVAOpen then
      AnimationBar.Max := HVAFile.Header.N_Frames-1
   else
      AnimationBar.Max := 0;

   lblHVAFrame.Caption := 'Frame ' + inttostr(GetCurrentFrame+1) + '/' + inttostr(GetCurrentHVA^.Header.N_Frames);
end;

procedure TFrmMain.Load1Click(Sender: TObject);
var
   Filename : string;
begin
   if OpenVXLDialog.Execute then
   begin
      Filename := OpenVXLDialog.FileName;
      OpenVoxel(FileName);
   end;
end;

Function GetParamStr : String;
var
   x : integer;
begin
   Result := '';

   for x := 1 to ParamCount do
      if Result <> '' then
         Result := Result + ' ' +ParamStr(x)
      else
         Result := ParamStr(x);
end;

procedure TFrmMain.FormShow(Sender: TObject);
var
   Reg : TRegistry;
   LatestVersion,ParamFile: string;
begin
   glResizeWnd(MainView.Width,MainView.Height);

   // 2.1:For future compatibility with other OS tools, we are
   // using the registry keys to confirm its existance.
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   if Reg.OpenKey('Software\CnC Tools\OS HVA Builder\',true) then
   begin
      LatestVersion := Reg.ReadString('Version');
      if APPLICATION_VER > LatestVersion then
      begin
         Reg.WriteString('Path',ParamStr(0));
         Reg.WriteString('Ver',APPLICATION_VER);
         Reg.WriteString('Version',APPLICATION_VER);
      end;
   end;
   Reg.CloseKey;
   Reg.Free;

   if ParamCount > 0 then
   begin
      ParamFile := GetParamStr();
      OpenVoxel(ParamFile);
   end;
end;

procedure TFrmMain.MainViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (not VoxelOpen) or (not DrawVHWorld) then
      exit;

   If VHControlType = CTOffset then
      VH_AddVOXELToUndo(CurrentVoxel,GetCurrentFrame,CurrentVoxelSection);

   If (VHControlType = CThvaposition) or (VHControlType = CThvarotation) then
      VH_AddHVAToUndo(CurrentHVA,GetCurrentFrame,CurrentVoxelSection);

   if (VHControlType <> CTView) and (VH_ISRedo) then
      VH_ResetRedo;

   SetUndoRedo;
   VH_MouseDown(Button,X, Y);
end;

procedure TFrmMain.MainViewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   VH_MouseUp;
   MainView.Cursor := crCross;
end;

procedure TFrmMain.MainViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   VH_MouseMove(X,Y);
end;

procedure TFrmMain.AnimationTimerTimer(Sender: TObject);
Var
   N_Frames : Integer;
begin
   N_Frames := GetCurrentHVA^.Header.N_Frames;

   if (N_Frames < 2) then
   begin
      AnimationTimer.Enabled := false;
      HVAFrame := 0;
      HVAFrameT := 0;
      HVAFrameB := 0;
      AnimationBar.Position := 0;
      exit;
   end;

   if (AnimationBar.Position = N_Frames-1) and ScreenShot.CaptureAnimation then
   begin
      ScreenShot.CaptureAnimation := False;
      VH_ScreenShotGIF(GifAnimateEndGif,VXLFilename);
      AnimationTimer.Enabled := false;
      HVAFrame := 0;
      HVAFrameT := 0;
      HVAFrameB := 0;
      AnimationBar.Position := 0;
      MainView.Align := alClient;
   end;

   if ScreenShot.CaptureAnimation then
      ScreenShot.TakeAnimation := true;

   if AnimationBar.Position = N_Frames-1 then
      AnimationBar.Position := 0
   else
      AnimationBar.Position := AnimationBar.Position +1;

end;

procedure TFrmMain.PlayAnimationClick(Sender: TObject);
begin
   AnimationTimer.Enabled := true;
end;

procedure TFrmMain.PauseAnimationClick(Sender: TObject);
begin
   AnimationTimer.Enabled := not AnimationTimer.Enabled;
end;

procedure TFrmMain.StopAnimationClick(Sender: TObject);
begin
   AnimationTimer.Enabled := False;
   AnimationBar.Position := 0;
end;

procedure TFrmMain.AnimationBarChange(Sender: TObject);
begin
   SetCurrentFrame(AnimationBar.Position);
   lblHVAFrame.Caption := 'Frame ' + inttostr(GetCurrentFrame+1) + '/' + inttostr(GetCurrentHVA^.Header.N_Frames);
end;

Procedure TFrmMain.SetIsHVA;
var
   V : Boolean;
begin
   If Assigned(CurrentHVA) then
      if CurrentHVA^.Header.N_Frames > 1 then
         V := True
      else
         V := False
   else
      V := False;

   AnimationBar.Enabled   := V;
   PlayAnimation.Enabled  := V;
   PauseAnimation.Enabled := V;
   StopAnimation.Enabled  := V;
   lblHVAFrame.Enabled    := V;
   ToolButton8.Enabled    := V;
   SetUndoRedo;
end;

Procedure TFrmMain.SetIsEditable;
begin
   RemapColourBox.Enabled := VoxelOpen;
   SpeedButton2.Enabled := VoxelOpen;
   btn3DRotateX.Enabled := VoxelOpen;
   btn3DRotateX2.Enabled := VoxelOpen;
   btn3DRotateY.Enabled := VoxelOpen;
   btn3DRotateY2.Enabled := VoxelOpen;
   spin3Djmp.Enabled := VoxelOpen;
   SectionBox.Enabled := VoxelOpen;
   ControlType.Enabled := VoxelOpen;
   ToolButton1.Enabled := VoxelOpen;
   ToolButton2.Enabled := VoxelOpen;
   ToolButton3.Enabled := VoxelOpen;
   ToolButton5.Enabled := VoxelOpen;
   BarSaveAs.Enabled := VoxelOpen;
   ToolButton6.Enabled := VoxelOpen;
   ToolButton12.Enabled := VoxelOpen;
   HighlightCheckBox.Enabled := VoxelOpen;
   DrawCenterCheckBox.Enabled := VoxelOpen;
   ShowDebugCheckBox.Enabled := VoxelOpen;
   VoxelCountCheckBox.Enabled := VoxelOpen;
   CheckBox1.Enabled := VoxelOpen;
   SaveVoxel1.Enabled := VoxelOpen;
   SaveAs1.Enabled := VoxelOpen;
   Options1.Visible := VoxelOpen;
   View1.Visible := VoxelOpen;
   ools1.Visible := VoxelOpen;
   Edit1.Visible := VoxelOpen;
   SetIsHVA;
end;

Procedure TFrmMain.SetCaption(Filename : String);
begin
   If Filename <> '' then
      Caption := ' ' + APPLICATION_TITLE + ' v'+APPLICATION_VER + ' [' +Extractfilename(Filename) + ']'
   else
      Caption := ' ' + APPLICATION_TITLE + ' v'+APPLICATION_VER;
end;

procedure TFrmMain.RemapColourBoxChange(Sender: TObject);
begin
   if RemapColourBox.ItemIndex > 0 then
   begin
      RemapColour := TVector3bToTVector3f(RemapColourMap[RemapColourBox.ItemIndex-1]);
      ChangeRemappable(VXLPalette,RemapColour);
      RebuildLists := true;
   end
   else If LoadedProg then
      RemapTimer.Enabled := true;
end;

procedure TFrmMain.RemapTimerTimer(Sender: TObject);
begin
   RemapTimer.Enabled := False;
   ColorDialog.Color := TVector3ftoTColor(RemapColour);
   if ColorDialog.Execute then
   begin
      RemapColour := TColorToTVector3f(ColorDialog.Color);
      ChangeRemappable(VXLPalette,RemapColour);
      RebuildLists := true;
   end;
end;

procedure TFrmMain.About1Click(Sender: TObject);
var
  frm: TFrmAbout_New;
begin
  frm:=TFrmAbout_New.Create(Self);
  frm.Visible:=False;
  Frm.Image1.Picture := TopBarImageHolder.Picture;
 { if TB_ENABLED then
  frm.Label2.Caption := APPLICATION_TITLE + ' v' + APPLICATION_VER + ' TB ' + TB_VER
  else    }
  frm.Label2.Caption := APPLICATION_TITLE + ' v' + APPLICATION_VER;
  frm.Label1.Caption := frm.Label1.Caption + APPLICATION_BY;
  frm.Label6.Caption := ENGINE_TITLE + ' v' + ENGINE_VER;
  frm.Label9.Caption := 'By: ' + ENGINE_BY;
  frm.ShowModal;
  frm.Close;
  frm.Free;
end;

procedure TFrmMain.SpeedButton2Click(Sender: TObject);
begin
   Depth := DefaultDepth;
end;

Procedure TFrmMain.SetRotationAdders;
var
   V : single;
begin
   try
      V := spin3Djmp.Value / 10;
   except
      exit; // Not a value
   end;

   if btn3DRotateX2.Down then
      XRot2 := V
   else if btn3DRotateX.Down then
      XRot2 := -V;

   if btn3DRotateY2.Down then
      YRot2 := -V
   else if btn3DRotateY.Down then
      YRot2 := V;

end;

procedure TFrmMain.btn3DRotateXClick(Sender: TObject);
begin
   if btn3DRotateX.Down then
   begin
      SetRotationAdders;
      XRotB := True;
   end
   else
      XRotB := false;
end;

procedure TFrmMain.btn3DRotateX2Click(Sender: TObject);
begin
   if btn3DRotateX2.Down then
   begin
      SetRotationAdders;
      XRotB := True;
   end
   else
      XRotB := false;
end;

procedure TFrmMain.btn3DRotateY2Click(Sender: TObject);
begin
   if btn3DRotateY2.Down then
   begin
      SetRotationAdders;
      YRotB := True;
   end
   else
      YRotB := false;
end;

procedure TFrmMain.btn3DRotateYClick(Sender: TObject);
begin
   if btn3DRotateY.Down then
   begin
      SetRotationAdders;
      YRotB := True;
   end
   else
      YRotB := false;
end;

procedure TFrmMain.spin3DjmpChange(Sender: TObject);
begin
   SetRotationAdders;
end;

Procedure TFrmMain.SetupSections;
var
   i : integer;
begin
   SectionBox.Clear;
   for i := 0 to (VoxelFile.Header.NumSections - 1) do
   begin
      SectionBox.Items.Add(VoxelFile.Section[i].Name);
      SectionBox.ItemsEx.ComboItems[SectionBox.ItemsEx.Count-1].ImageIndex := 4;
   end;

   if VoxelOpenT then
      for i := 0 to (VoxelTurret.Header.NumSections - 1) do
      begin
         SectionBox.Items.Add(VoxelTurret.Section[i].Name);
         SectionBox.ItemsEx.ComboItems[SectionBox.ItemsEx.Count-1].ImageIndex := 5;
      end;

   if VoxelOpenB then
      for i := 0 to (VoxelBarrel.Header.NumSections - 1) do
      begin
         SectionBox.Items.Add(VoxelBarrel.Section[i].Name);
         SectionBox.ItemsEx.ComboItems[SectionBox.ItemsEx.Count-1].ImageIndex := 6;
      end;
   SectionBox.ItemIndex := CurrentSection+1;
end;

procedure TFrmMain.SectionBoxChange(Sender: TObject);
begin
   if (not VoxelOpen) then exit;

   if SectionBox.ItemIndex < 0  then
      exit;

   VH_ResetUndoRedo;
   SetUndoRedo;

   if SectionBox.ItemsEx.ComboItems[SectionBox.ItemIndex].ImageIndex = 4 then
   begin
      CurrentVoxel := @VoxelFile;
      if CurrentHVA <> @HVAFile then
      begin
         CurrentHVA := @HVAFile;
         HVACurrentFrame := 0;
         CheckHVAFrames2;
      end;
      CurrentVoxelSection := SectionBox.ItemIndex;
   end;

   if SectionBox.ItemsEx.ComboItems[SectionBox.ItemIndex].ImageIndex = 5 then
   begin
      CurrentVoxel := @VoxelTurret;

      if CurrentHVA <> @HVATurret then
      begin
         CurrentHVA := @HVATurret;
         HVACurrentFrame := 1;
         CheckHVAFrames2;
      end;

      CurrentVoxelSection := SectionBox.ItemIndex - VoxelFile.Header.NumSections;
   end;

   if SectionBox.ItemsEx.ComboItems[SectionBox.ItemIndex].ImageIndex = 6 then
   begin
      CurrentVoxel := @VoxelBarrel;

      if CurrentHVA <> @HVABarrel then
      begin
         CurrentHVA := @HVABarrel;
         HVACurrentFrame := 2;
         CheckHVAFrames2;
      end;

      CurrentVoxelSection := SectionBox.ItemIndex - VoxelFile.Header.NumSections;

      if VoxelOpenT then
         CurrentVoxelSection := CurrentVoxelSection - VoxelTurret.Header.NumSections;
   end;
   if HighlightCheckBox.Checked then
      RebuildLists := true;
end;

procedure TFrmMain.ShowDebugCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then
      exit;

   DebugMode := not DebugMode;
   ShowDebugCheckBox.Checked := DebugMode;
end;

procedure TFrmMain.VoxelCountCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then
      exit;

   ShowVoxelCount := not ShowVoxelCount;
   VoxelCountCheckBox.Checked := ShowVoxelCount;
end;

procedure TFrmMain.Disable3DView1Click(Sender: TObject);
begin
   If VVSLoading then
      exit;

   VVSLoading := True; //Fake a VVS Load

   DrawVHWorld := not DrawVHWorld;
   Disable3DView1.Checked := not DrawVHWorld;
   CheckBox1.Checked := not DrawVHWorld;

   If not DrawVHWorld then
      MainView.Repaint;

   VVSLoading := False;
end;

procedure TFrmMain.ColoursNormals1Click(Sender: TObject);
begin
   VH_SetSpectrum(True);
   ColoursNormals1.Checked := true;
   Normals1.Checked := false;
   Colours1.Checked := false;
   ColoursOnly := false;
end;

procedure TFrmMain.Colours1Click(Sender: TObject);
begin
   VH_SetSpectrum(True);
   ColoursNormals1.Checked := false;
   Normals1.Checked := false;
   Colours1.Checked := true;
   ColoursOnly := True;
end;

procedure TFrmMain.Normals1Click(Sender: TObject);
begin
   VH_SetSpectrum(False);
   ColoursNormals1.Checked := false;
   Normals1.Checked := true;
   Colours1.Checked := false;
   ColoursOnly := false;
end;

procedure TFrmMain.CameraManager1Click(Sender: TObject);
var
   frm: TFrmCameraManager_New;
begin
   frm:=TFrmCameraManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;
   frm.XRot.Text := FloatToStr(XRot);
   frm.YRot.Text := FloatToStr(YRot);
   frm.Depth.Text := FloatToStr(Depth);
   frm.ShowModal;
   frm.Close;

   if Frm.O then
   begin
      XRot := StrToFloat(frm.XRot.Text);
      YRot := StrToFloat(frm.YRot.Text);
      Depth := StrToFloat(frm.Depth.Text);
   end;

   frm.Free;
end;

procedure TFrmMain.Help2Click(Sender: TObject);
begin
   if not fileexists(extractfiledir(paramstr(0))+'/help.chm') then
   begin
      messagebox(0,'Help' + #13#13 + 'help.chm not found','Help',0);
      exit;
   end;
   RunAProgram('help.chm','',extractfiledir(paramstr(0)));
end;

Procedure TFrmMain.ChangeView(Sender : TObject);
begin
   VH_ChangeView(TMenuItem(Sender).Tag);
end;

procedure TFrmMain.ScreenShot1Click(Sender: TObject);
var
   frm: TFrmScreenShotManager_New;
begin
   frm:=TFrmScreenShotManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;
//  Frm.Image1.Refresh;
   If ScreenShot._Type = 0 then
      frm.RadioButton1.Checked := True
   else
      frm.RadioButton2.Checked := True;

   frm.RadioButton1Click(Sender);
   Frm.Compression.Position := ScreenShot.CompressionRate;

   if ScreenShot.Width = -1 then
      ScreenShot.Width := MainView.Width;

   if ScreenShot.Height = -1 then
      ScreenShot.Height := MainView.Height;

   Frm.MainViewWidth.Value := ScreenShot.Width;
   Frm.MainViewWidth.MaxValue := MainView.Width;
   Frm.MainViewHeight.Value := ScreenShot.Height;
   Frm.MainViewHeight.MaxValue := MainView.Height;
   frm.ShowModal;
   frm.Close;

   if frm.O then
   begin
      MainView.Align := alNone;
      ScreenShot.Width := Frm.MainViewWidth.Value;
      ScreenShot.Height := Frm.MainViewHeight.Value;
      MainView.Width := Frm.MainViewWidth.Value;
      MainView.Height := Frm.MainViewHeight.Value;

      If frm.RadioButton1.Checked then
         ScreenShot._Type := 0
      else
         ScreenShot._Type := 1;

      ScreenShot.CompressionRate := Frm.Compression.Position;
      ScreenShot.Take := true;
   end;

   frm.Free;
end;

procedure TFrmMain.BackgroundColour1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector3fToTColor(BGColor);
   if ColorDialog.Execute then
      VH_SetBGColour(TColorToTVector3f(ColorDialog.Color));
end;

procedure TFrmMain.extColour1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector3fToTColor(FontColor);
   if ColorDialog.Execute then
      FontColor := TColorToTVector3f(ColorDialog.Color);
end;

procedure TFrmMain.CaptureAnimation1Click(Sender: TObject);
var
   frm: TFrmAnimationManager_New;
begin
   frm:=TFrmAnimationManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   if ScreenShot.Width = -1 then
      ScreenShot.Width := MainView.Width;

   if ScreenShot.Height = -1 then
      ScreenShot.Height := MainView.Height;

   Frm.MainViewWidth.Value := ScreenShot.Width;
   Frm.MainViewWidth.MaxValue := MainView.Width;
   Frm.MainViewHeight.Value := ScreenShot.Height;
   Frm.MainViewHeight.MaxValue := MainView.Height;

   Frm.Frames.Enabled := false;
   Frm.Label7.Enabled := false;
   Frm.Label8.Enabled := false;
   Frm.Label9.Enabled := false;
   Frm.AnimateCheckBox.Enabled := false;
   Frm.AnimateCheckBox.Checked := true;

   frm.ShowModal;
   frm.Close;

   if frm.O then
   begin
      AnimationTimer.Enabled := false;
      MainView.Align := alNone;
      ScreenShot.Width := Frm.MainViewWidth.Value;
      ScreenShot.Height := Frm.MainViewHeight.Value;
      MainView.Width := Frm.MainViewWidth.Value;
      MainView.Height := Frm.MainViewHeight.Value;
      ScreenShot.CaptureAnimation := true;
      ScreenShot.TakeAnimation := true;
      AnimationBar.Position := 0;
      AnimationBarChange(Sender);
      SetCurrentFrame(0);
      AnimationTimer.Enabled := true;

      ClearRotationAdders;
      GifAnimateBegin;
   end;
   frm.free;
end;

Procedure TFrmMain.ClearRotationAdders;
var
   V : single;
begin
   btn3DRotateX2.Down := false;
   btn3DRotateX.Down := false;
   XRot2 := 0;
   XRotB := false;

   btn3DRotateY2.Down := false;
   btn3DRotateY.Down := false;
   YRot2 := 0;
   YRotB := false;
end;

procedure TFrmMain.Make360DegreeAnimation1Click(Sender: TObject);
var
   frm: TFrmAnimationManager_New;
begin
   frm:=TFrmAnimationManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   if ScreenShot.Width = -1 then
      ScreenShot.Width := MainView.Width;

   if ScreenShot.Height = -1 then
      ScreenShot.Height := MainView.Height;

   Frm.MainViewWidth.Value := ScreenShot.Width;
   Frm.MainViewWidth.MaxValue := MainView.Width;
   Frm.MainViewHeight.Value := ScreenShot.Height;
   Frm.MainViewHeight.MaxValue := MainView.Height;

   Frm.Frames.Value := ScreenShot.Frames;

{
   Frm.Frames.Enabled := false;
   Frm.Label2.Enabled := false;
   Frm.Label4.Enabled := false;
   Frm.Label7.Enabled := false;
}

   if not HVAOpen then
      Frm.AnimateCheckBox.Enabled := false;

   frm.ShowModal;
   frm.Close;

   if frm.O then
   begin
      MainView.Align := alNone;
      ScreenShot.Width := Frm.MainViewWidth.Value;
      ScreenShot.Height := Frm.MainViewHeight.Value;
      MainView.Width := Frm.MainViewWidth.Value;
      MainView.Height := Frm.MainViewHeight.Value;
      ScreenShot.Frames := Frm.Frames.Value;
      ScreenShot.FrameAdder := 360/ScreenShot.Frames;
      ScreenShot.FrameCount := 0;
      ScreenShot.OldYRot := YRot;
      YRot := 0;
      ScreenShot.Take360DAnimation := true;
      if Frm.AnimateCheckBox.Checked then
      begin
         AnimationBar.Position := 0;
         AnimationBarChange(Sender);
         SetCurrentFrame(0);
         AnimationTimer.Enabled := True;
      end
      else
         AnimationTimer.Enabled := false;

      ClearRotationAdders;
      GifAnimateBegin;
   end;
   frm.free;
end;

procedure TFrmMain.UpDown1ChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
begin
   if Direction = updUp then
      AnimationBar.Position := AnimationBar.Position + 1;

   if Direction = updDown then
      AnimationBar.Position := AnimationBar.Position - 1;
end;

procedure TFrmMain.DrawCenterCheckBoxClick(Sender: TObject);
begin
   DrawCenter := Not DrawCenter;
   DrawCenterCheckBox.Checked := DrawCenter;
end;

procedure TFrmMain.HighlightCheckBoxClick(Sender: TObject);
begin
   Highlight := Not Highlight;
   HighlightCheckBox.Checked := Highlight;
   RebuildLists := true;
end;

procedure TFrmMain.ControlYClick(Sender: TObject);
begin
   Axis := 0;
end;

procedure TFrmMain.ControlZClick(Sender: TObject);
begin
   Axis := 1;
end;

procedure TFrmMain.ControlXClick(Sender: TObject);
begin
   Axis := 2;
end;

procedure TFrmMain.ControlTypeChange(Sender: TObject);
begin
   if ControlType.ItemIndex = 0 then
      VHControlType := CTview
   else if ControlType.ItemIndex = 1 then
      VHControlType := CToffset
   else if ControlType.ItemIndex = 2 then
      VHControlType := CThvaposition
   else if ControlType.ItemIndex = 3 then
      VHControlType := CThvarotation;
end;

procedure TFrmMain.ToolButton1Click(Sender: TObject);
begin
   ControlType.ItemIndex := 0;
   ControlTypeChange(Sender);
end;

procedure TFrmMain.ToolButton2Click(Sender: TObject);
begin
   ControlType.ItemIndex := 1;
   ControlTypeChange(Sender);
end;

procedure TFrmMain.ToolButton3Click(Sender: TObject);
begin
   ControlType.ItemIndex := 2;
   ControlTypeChange(Sender);
end;

procedure TFrmMain.ToolButton5Click(Sender: TObject);
begin
   ControlType.ItemIndex := 3;
   ControlTypeChange(Sender);
end;

procedure TFrmMain.ToolButton6Click(Sender: TObject);
begin
   InsertHVAFrame(CurrentHVA^);

   CheckHVAFrames;
end;

procedure TFrmMain.ToolButton8Click(Sender: TObject);
begin
   DeleteHVAFrame(CurrentHVA^);

   CheckHVAFrames;
end;

procedure TFrmMain.ToolButton12Click(Sender: TObject);
begin
   CopyHVAFrame(CurrentHVA^);

   CheckHVAFrames;
end;

Procedure TFrmMain.CheckHVAFrames;
Var
   Sender : TObject;
begin
   if CurrentHVA^.Header.N_Frames > 1 then
      AnimationBar.Max := CurrentHVA^.Header.N_Frames-1;

   AnimationBarChange(Sender);
   SetIsHVA;
end;

Procedure TFrmMain.CheckHVAFrames2;
Var
   Sender : TObject;
begin
   if CurrentHVA^.Header.N_Frames > 1 then
      AnimationBar.Max := CurrentHVA^.Header.N_Frames-1;

   AnimationBar.Position := 0;
   AnimationBarChange(Sender);

   SetIsHVA;
end;

procedure TFrmMain.SaveVoxel1Click(Sender: TObject);
begin
   VXLChanged := false;

   if VXLFilename = '' then
      SaveAs1.Click
   else
   begin
      VH_SaveVoxel(VXLFilename2);
      VH_SaveHVA(VXLFilename2);
      SetCaption(VXLFilename2 + '.vxl');
   end;
end;

procedure TFrmMain.SaveAs1Click(Sender: TObject);
begin
   VXLChanged := false;

   if SaveVXLDialog.Execute then
   begin
      VXLFilename := extractfilename(SaveVXLDialog.Filename);
      VXLFilename := copy(VXLFilename,0,length(VXLFilename)-length(extractfileext(VXLFilename)));
      VXLFilename2 := SaveVXLDialog.Filename;
      VH_SaveVoxel(SaveVXLDialog.Filename);
      VH_SaveHVA(SaveVXLDialog.Filename);
      SetCaption(SaveVXLDialog.Filename);

      //Config.AddFileToHistory(VXLFilename);
      //UpdateHistoryMenu;
   end;
end;

procedure TFrmMain.ViewTransform1Click(Sender: TObject);
var
   frm: TFrmTransformManager_New;
   HTM,j,k : Integer;
begin
   frm:=TFrmTransformManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   HTM := GetCurrentFrame*CurrentHVA^.Header.N_Sections+CurrentVoxelSection;

   for j:=1 to 3 do
   begin
      for k:=1 to 4 do
      begin
         frm.grdTrans.Cells[k-1,j-1]:=FloatToStr(CurrentHVA^.TransformMatrixs[HTM][k][j]);
      end;
   end;

   frm.ShowModal;

   if Frm.O then
   begin
      VH_AddHVAToUndo(CurrentHVA,GetCurrentFrame,CurrentVoxelSection);   VH_ResetRedo;
      SetUndoRedo;

      for j:=1 to 4 do
      begin
         for k:=1 to 3 do
         begin
            CurrentHVA^.TransformMatrixs[HTM][j][k] := strtofloat(frm.grdTrans.Cells[k-1,j-1]);
         end;
      end;
   end;

   frm.Free;
end;

procedure TFrmMain.VoxelBounds1Click(Sender: TObject);
var
   frm: TFrmBoundsManager_New;
   CD,NB,NB2,Size : TVector3f;
   w,h,d : single;
begin
   frm:=TFrmBoundsManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   Size.x := CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[1]-CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[1];
   Size.y := CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[2]-CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[2];
   Size.z := CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[3]-CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[3];

   CD.x := CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[1] + (-(CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[1]-CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[1])/2);
   CD.y := CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[2] + (-(CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[2]-CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[2])/2);
   CD.z := CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[3] + (-(CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[3]-CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[3])/2);

   frm.XOffset.Text := floattostr(CD.x);
   frm.YOffset.Text := floattostr(CD.y);
   frm.ZOffset.Text := floattostr(CD.z);

   frm.SizeX.Text  := floattostr(Size.x);
   frm.SizeY.Text  := floattostr(Size.y);
   frm.SizeZ.Text  := floattostr(Size.z);

   frm.ShowModal;

   if Frm.O then
   begin
      VH_AddVOXELToUndo(CurrentVoxel,GetCurrentFrame,CurrentVoxelSection);
      VH_ResetRedo;
      SetUndoRedo;

      w := strtofloat(frm.SizeX.Text);
      h := strtofloat(frm.SizeY.Text);
      d := strtofloat(frm.SizeZ.Text);

      NB.x := 0-(w/2);
      NB.y := 0-(h/2);
      NB.z := 0-(d/2);

      NB2.x := (w/2);
      NB2.y := (h/2);
      NB2.z := (d/2);

      NB.X := NB.X + StrToFloat(frm.XOffset.Text);
      NB.Y := NB.Y + StrToFloat(frm.YOffset.Text);
      NB.Z := NB.Z + StrToFloat(frm.ZOffset.Text);

      NB2.X := NB2.X + StrToFloat(frm.XOffset.Text);
      NB2.Y := NB2.Y + StrToFloat(frm.YOffset.Text);
      NB2.Z := NB2.Z + StrToFloat(frm.ZOffset.Text);

      CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[1] := NB.X;
      CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[2] := NB.Y;
      CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MinBounds[3] := NB.Z;

      CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[1] := NB2.X;
      CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[2] := NB2.Y;
      CurrentVoxel^.Section[CurrentVoxelSection].Tailer.MaxBounds[3] := NB2.Z;
   end;

   frm.Free;
end;

procedure TFrmMain.RotateBy1Click(Sender: TObject);
var
   frm: TFrmRotationManager_New;
   Angle : TVector3f;
begin
   frm:=TFrmRotationManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   frm.RotationX.Text := '0';
   frm.RotationY.Text := '0';
   frm.RotationZ.Text := '0';

   frm.ShowModal;

   if Frm.O then
   begin
      VH_AddHVAToUndo(CurrentHVA,GetCurrentFrame,CurrentVoxelSection);
      VH_ResetRedo;
      SetUndoRedo;

      SETHVAAngle(CurrentHVA^,CurrentVoxelSection,GetCurrentFrame,strtofloat(frm.RotationX.Text),strtofloat(frm.RotationY.Text),strtofloat(frm.RotationZ.Text));
   end;

   frm.Free;
end;

procedure TFrmMain.HVAPosition1Click(Sender: TObject);
var
   frm: TFrmHVAPositionManager_New;
   Pos : TVector3f;
begin
   frm:=TFrmHVAPositionManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   Pos := GetHVAPos(CurrentHVA^,CurrentVoxel^,CurrentVoxelSection);

   frm.PositionX.Text := floattostr(Pos.X);
   frm.PositionY.Text := floattostr(Pos.Y);
   frm.PositionZ.Text := floattostr(Pos.Z);

   frm.ShowModal;

   if Frm.O then
   begin
      VH_AddHVAToUndo(CurrentHVA,GetCurrentFrame,CurrentVoxelSection);
      VH_ResetRedo;
      SetUndoRedo;

      SetHVAPos2(CurrentHVA^,CurrentVoxel^,CurrentVoxelSection,SetVector(strtofloat(frm.PositionX.Text),strtofloat(frm.PositionY.Text),strtofloat(frm.PositionZ.Text)));
   end;

   frm.Free;
end;

Procedure TFrmMain.SetUndoRedo;
begin
   ToolButton10.Enabled := VH_ISUndo;
   Undo1.Enabled := ToolButton10.Enabled;
   ToolButton11.Enabled := VH_ISRedo;
   Redo1.Enabled := ToolButton11.Enabled;
end;

procedure TFrmMain.Undo1Click(Sender: TObject);
begin
   VH_DoUndo;
   SetUndoRedo;
end;

procedure TFrmMain.Redo1Click(Sender: TObject);
begin
   VH_DoRedo;
   SetUndoRedo;
end;

procedure TFrmMain.Preferences1Click(Sender: TObject);
var
   Frm : TFrmPreferences;
begin
   // Here we call the Form Preferences.
   Frm := TFrmPreferences.Create(self);
   Frm.ShowModal();
   Frm.Release;
end;

end.
