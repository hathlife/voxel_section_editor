unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, Buttons, StdCtrls, ComCtrls, ImgList, Spin,FTGifAnimate,
  Voxel, FormSurface, math3d, VH_SurfaceGen, normals, Registry;

   // Note: BZK is an engine that I (Banshee) am working with
   // some friends from my university (UFF). The BZK_BUILD
   // can export .GEO (geometry) files that another program
   // uses to create maps from it. This feature is already
   // useless, since VXLSE was also modified and it exports
   // the .BZK2 (maps) files straight from it.

   // So, this must be commented out on the C&C version.
//{$define BZK_BUILD}

Const
APPLICATION_TITLE = 'Open Source Voxel Viewer';
APPLICATION_VER = '1.83' {$ifdef BZK_BUILD} + ' BZK Edition'{$endif};
APPLICATION_VER_ID = '1.83';
APPLICATION_BY = 'Stucuk && Banshee';

type
  TVVFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    MainView: TPanel;
    OpenVXLDialog: TOpenDialog;
    Load1: TMenuItem;
    TopBarImageHolder: TImage;
    Panel4: TPanel;
    lblHVAFrame: TLabel;
    PlayAnimation: TSpeedButton;
    PauseAnimation: TSpeedButton;
    StopAnimation: TSpeedButton;
    AnimationBar: TTrackBar;
    AnimFrom: TComboBoxEx;
    Label2: TLabel;
    RemapImageList: TImageList;
    ImageList: TImageList;
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
    UnitRotPopupMenu: TPopupMenu;
    N01: TMenuItem;
    N451: TMenuItem;
    N901: TMenuItem;
    N1351: TMenuItem;
    N1801: TMenuItem;
    N2251: TMenuItem;
    N2701: TMenuItem;
    N3151: TMenuItem;
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
    N4: TMenuItem;
    ScreenShot1: TMenuItem;
    N5: TMenuItem;
    BackgroundColour1: TMenuItem;
    extColour1: TMenuItem;
    CaptureAnimation1: TMenuItem;
    N6: TMenuItem;
    LoadScene1: TMenuItem;
    OpenVVSDialog: TOpenDialog;
    SaveVVSDialog: TSaveDialog;
    SaveScene1: TMenuItem;
    Make360DegreeAnimation1: TMenuItem;
    DebugVoxelBounds1: TMenuItem;
    MakeBZKUnit1: TMenuItem;
    GenerateSurface1: TMenuItem;
    MakeGeoUnitwithPrecompiledLighting1: TMenuItem;
    Panel7: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel8: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    GroundCheckBox: TCheckBox;
    TileGroundCheckBox: TCheckBox;
    XTexShift: TSpinEdit;
    YTexShift: TSpinEdit;
    GroundSize: TSpinEdit;
    GroundHeightOffsetSpinEdit: TSpinEdit;
    GroundTexBox: TComboBoxEx;
    TabSheet4: TTabSheet;
    Label20: TLabel;
    Label21: TLabel;
    UnitRotPopupBut: TSpeedButton;
    Label18: TLabel;
    Label29: TLabel;
    UnitShiftXSpinEdit: TSpinEdit;
    UnitShiftYSpinEdit: TSpinEdit;
    RotationEdit: TEdit;
    TurretRotationBar: TTrackBar;
    TabSheet5: TTabSheet;
    Label19: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    AmbientRed: TSpinEdit;
    AmbientGreen: TSpinEdit;
    AmbientBlue: TSpinEdit;
    DiffuseRed: TSpinEdit;
    DiffuseGreen: TSpinEdit;
    DiffuseBlue: TSpinEdit;
    LightGroundCheckBox: TCheckBox;
    TabSheet2: TTabSheet;
    Label17: TLabel;
    Label16: TLabel;
    Label15: TLabel;
    CamMovEdit: TEdit;
    VisibleDistEdit: TSpinEdit;
    FOVEdit: TSpinEdit;
    CullFaceCheckBox: TCheckBox;
    VoxelCountCheckBox: TCheckBox;
    ShowDebugCheckBox: TCheckBox;
    DrawBarrelCheckBox: TCheckBox;
    DrawTurretCheckBox: TCheckBox;
    Timer1: TTimer;
    Label30: TLabel;
    UnitCountCombo: TComboBox;
    Label31: TLabel;
    UnitSpaceEdit: TSpinEdit;
    Label14: TLabel;
    SkyLengthSpinEdit: TSpinEdit;
    SkyHeightSpinEdit: TSpinEdit;
    Label13: TLabel;
    Label12: TLabel;
    SkyWidthSpinEdit: TSpinEdit;
    SkyXPosSpinEdit: TSpinEdit;
    SkyZPosSpinEdit: TSpinEdit;
    SkyYPosSpinEdit: TSpinEdit;
    Label11: TLabel;
    Label10: TLabel;
    Label5: TLabel;
    DrawSkyCheckBox: TCheckBox;
    SkyTextureComboBox: TComboBox;
    Bevel1: TBevel;
    Label32: TLabel;
    Label33: TLabel;
    AutoSizeCheck: TCheckBox;
    Label4: TLabel;
    OGLSize: TSpinEdit;
    Bevel2: TBevel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label38: TLabel;
    Label37: TLabel;
    EdOffsetX: TEdit;
    EdOffsetY: TEdit;
    Label39: TLabel;
    EdOffsetZ: TEdit;
    Label40: TLabel;
    UnitShiftZSpinEdit: TSpinEdit;
    Label41: TLabel;
    procedure UnitShiftZSpinEditChange(Sender: TObject);
    procedure EdOffsetZChange(Sender: TObject);
    procedure EdOffsetYChange(Sender: TObject);
    procedure EdOffsetXChange(Sender: TObject);
    procedure MainViewResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DrawFrames;
    procedure Idle(Sender: TObject; var Done: Boolean);
    procedure Exit1Click(Sender: TObject);
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
    Procedure SetAnimFrom;
    Procedure SetIsHVA;
    Procedure SetIsEditable;
    Procedure SetCaption(Filename : String);
    procedure RemapColourBoxChange(Sender: TObject);
    procedure RemapTimerTimer(Sender: TObject);
    procedure AnimFromChange(Sender: TObject);
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
    procedure FOVEditChange(Sender: TObject);
    procedure VisibleDistEditChange(Sender: TObject);
    procedure UnitRotPopupButClick(Sender: TObject);
    procedure N01Click(Sender: TObject);
    procedure RotationEditChange(Sender: TObject);
    procedure UnitShiftXSpinEditChange(Sender: TObject);
    procedure UnitShiftYSpinEditChange(Sender: TObject);
    procedure XTexShiftChange(Sender: TObject);
    procedure YTexShiftChange(Sender: TObject);
    procedure GroundHeightOffsetSpinEditChange(Sender: TObject);
    procedure TileGroundCheckBoxClick(Sender: TObject);
    procedure GroundCheckBoxClick(Sender: TObject);
    procedure DrawTurretCheckBoxClick(Sender: TObject);
    procedure DrawBarrelCheckBoxClick(Sender: TObject);
    procedure ShowDebugCheckBoxClick(Sender: TObject);
    procedure VoxelCountCheckBoxClick(Sender: TObject);
    procedure CullFaceCheckBoxClick(Sender: TObject);
    procedure CamMovEditChange(Sender: TObject);
    procedure GroundSizeChange(Sender: TObject);
    Procedure BuildTexList;
    procedure GroundTexBoxChange(Sender: TObject);
    Procedure BuildSkyTextureComboBox;
    procedure SkyTextureComboBoxChange(Sender: TObject);
    procedure SkyWidthSpinEditChange(Sender: TObject);
    procedure SkyHeightSpinEditChange(Sender: TObject);
    procedure SkyLengthSpinEditChange(Sender: TObject);
    procedure SkyZPosSpinEditChange(Sender: TObject);
    procedure SkyYPosSpinEditChange(Sender: TObject);
    procedure SkyXPosSpinEditChange(Sender: TObject);
    procedure DrawSkyCheckBoxClick(Sender: TObject);
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
    procedure LoadScene1Click(Sender: TObject);
    procedure SaveScene1Click(Sender: TObject);
    procedure Make360DegreeAnimation1Click(Sender: TObject);
    procedure AmbientRedChange(Sender: TObject);
    procedure AmbientGreenChange(Sender: TObject);
    procedure AmbientBlueChange(Sender: TObject);
    procedure DiffuseRedChange(Sender: TObject);
    procedure DiffuseGreenChange(Sender: TObject);
    procedure DiffuseBlueChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure LightGroundCheckBoxClick(Sender: TObject);
    procedure TurretRotationBarChange(Sender: TObject);
    procedure CopyData(var Msg: TMessage); message WM_COPYDATA;
    procedure OpenVoxel(FileName : string);
    procedure DebugVoxelBounds1Click(Sender: TObject);
    procedure MakeBZKUnit1Click(Sender: TObject);
    procedure GenerateSurface1Click(Sender: TObject);
    procedure MakeGeoUnitwithPrecompiledLighting1Click(Sender: TObject);
    procedure OGLSizeChange(Sender: TObject);
    procedure AutoSizeCheckClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure UnitCountComboChange(Sender: TObject);
    procedure UnitSpaceEditChange(Sender: TObject);
    procedure DeactivateView(Sender: TObject);
    procedure ActivateView(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LoadedProg : Boolean;
  end;

var
  VVFrmMain: TVVFrmMain;

implementation

Uses VH_Engine,VH_Global,VH_GL,VH_Voxel{,Voxel},HVA,FormAboutNew,
     FormCameraManagerNew, ShellAPI,FormProgress,FormScreenShotManagerNew,
     FormAnimationManagerNew, VH_Types, Math;

{$R *.dfm}

procedure RunAProgram (const theProgram, itsParameters, defaultDirectory : string);
var rslt     : integer;
    msg      : string;
begin
rslt := ShellExecute (0, 'open',
                        pChar (theProgram),
                        pChar (itsParameters),
                        pChar (defaultDirectory),
                        sw_ShowNormal);
if rslt <= 32
then begin
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

procedure TVVFrmMain.MainViewResize(Sender: TObject);
begin
   If oglloaded then
      glResizeWnd(MainView.Width,MainView.Height);
end;

procedure TVVFrmMain.FormCreate(Sender: TObject);
var
   frm : TFrmProgress;
begin
   LoadedProg := False;

   RemapColourBox.ItemIndex := 1;
   RemapColourBoxChange(Sender);
   SetIsEditable;
   SetCaption('');
   Highlight := False; // No Highlighting in VXL View
   DrawAllOfVoxel := False;
   UnitRot := 180;
   Ground_Tex_Draw := True;
   DrawSky := True;

   If not InitalizeVHE(ExtractFileDir(ParamStr(0)),'Palettes\ts\unittem.pal',MainView.Width,MainView.Height,MainView.Handle,-90) then
   begin
      Messagebox(0,pchar('Error Initalizing Engine'#13#13'Closing'),'VH Engine',0);
      Application.Terminate;
   end;

   frm:=TFrmProgress.Create(Application);
   frm.Visible:=False;
   frm.UpdateAction('');
   frm.Show;
   frm.Refresh;

   VH_LoadGroundTextures(frm);
   if (GroundTex_No = 0) then
   begin
      Messagebox(0,'Error: Couldn''t load Ground Textures','Textures Missing',0);
      Application.Terminate;
   end;

   VH_LoadSkyTextures(frm);
   if (SkyTexList_No = 0) then
   begin
      Messagebox(0,'Error: Couldn''t load Sky Textures','Textures Missing',0);
      Application.Terminate;
   end;

   frm.Close;
   frm.Free;

   BuildTexList;
   BuildSkyTextureComboBox;
   VH_BuildViewMenu(Views1,ChangeView);
   VH_ChangeView(Default_View);

   RotationEdit.Text := floattostr(UnitRot);
   FOVEdit.Value := Trunc(FOV);
   VisibleDistEdit.Value := Trunc(DEPTH_OF_VIEW);
   PageControl1.ActivePage := TabSheet1;

   SkyWidthSpinEdit.Value  := Trunc(DEPTH_OF_VIEW/2);
   SkyHeightSpinEdit.Value := SkyWidthSpinEdit.Value;
   SkyLengthSpinEdit.Value := SkyWidthSpinEdit.Value;
   GroundSize.Value        := Trunc(DEPTH_OF_VIEW);

   Application.OnIdle := Idle;

   AmbientRed.Value   := Trunc(LightAmb.X*255);
   AmbientGreen.Value := Trunc(LightAmb.Y*255);
   AmbientBlue.Value  := Trunc(LightAmb.Z*255);

   DiffuseRed.Value   := Trunc(LightDif.X*255);
   DiffuseGreen.Value := Trunc(LightDif.Y*255);
   DiffuseBlue.Value  := Trunc(LightDif.Z*255);

   Application.OnDeactivate := DeactivateView;
   Application.OnActivate := ActivateView;
   Application.OnMinimize := DeactivateView;
   Application.OnRestore := ActivateView;

   LoadedProg := True;
end;

procedure TVVFrmMain.ActivateView(Sender : TObject);
begin
   Application.OnIdle := Idle;
end;

procedure TVVFrmMain.DeactivateView(Sender : TObject);
begin
   Application.OnIdle := nil;
end;

procedure TVVFrmMain.Idle(Sender: TObject; var Done: Boolean);
var
   BMP : TBitmap;
begin
   Done := False;
   if not DrawVHWorld then exit;

   if (ScreenShot.Take) or (ScreenShot.TakeAnimation) or (ScreenShot.Take360DAnimation) then
      FUpdateWorld := True;

   DrawFrames;

   if ScreenShot.Take then
   begin
      if ScreenShot._Type = 0 then
         VH_ScreenShot(VXLFilename)
      else if ScreenShot._Type = 1 then
         VH_ScreenShotJPG(VXLFilename,ScreenShot.CompressionRate)
      else if ScreenShot._Type = 2 then
         VH_ScreenShotToSHPBuilder;
      if AutoSizeCheck.Checked then
         MainView.Align := alClient
      else
      begin
         MainView.Align  := alNone;
         MainView.Width  := OGLSize.Value;
         MainView.Height := OGLSize.Value;
      end;
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
         if AutoSizeCheck.Checked then
            MainView.Align := alClient
         else
         begin
            MainView.Align  := alNone;
            MainView.Width  := OGLSize.Value;
            MainView.Height := OGLSize.Value;
         end;
         AnimationTimer.Enabled := False;
         AnimationBar.Position := 0;
         AnimationBarChange(Sender);
      end;
   end;

 //  Sleep(1);
end;

procedure TVVFrmMain.DrawFrames;
begin
  if not oglloaded then exit;

  VH_Draw();                         // Draw the scene
end;

procedure TVVFrmMain.EdOffsetXChange(Sender: TObject);
begin
   TurretOffset.X := StrToFloatDef(EdOffsetX.Text,0);
end;

procedure TVVFrmMain.EdOffsetYChange(Sender: TObject);
begin
   TurretOffset.Y := StrToFloatDef(EdOffsetY.Text,0);
end;

procedure TVVFrmMain.EdOffsetZChange(Sender: TObject);
begin
   TurretOffset.Z := StrToFloatDef(EdOffsetZ.Text,0);
end;

procedure TVVFrmMain.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TVVFrmMain.Load1Click(Sender: TObject);
begin
   if OpenVXLDialog.Execute then
   begin
      OpenVoxel(OpenVXLDialog.FileName);
      DrawFrames;
      FUpdateWorld := True;
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

procedure TVVFrmMain.OpenVoxel(FileName : string);
begin
   If FileExists(FileName) then
   Begin
      LoadVoxel(FileName);

      //If HVAOpen then
      SetCaption(FileName);

      SetupSections;
      SectionBox.ItemIndex := 0;
      SectionBoxChange(nil);
      RemapColourBoxChange(nil);

      SetAnimFrom;
      AnimFrom.ItemIndex := 0;
      AnimFromChange(nil);

      SetIsEditable;

      If HVAOpen then
         AnimationBar.Max := HVAFile.Header.N_Frames-1
      else
         AnimationBar.Max := 0;

      lblHVAFrame.Caption := 'Frame ' + inttostr(GetCurrentFrame+1) + '/' + inttostr(GetCurrentHVA^.Header.N_Frames);
      FUpdateWorld := True;
   End;
end;

procedure TVVFrmMain.FormShow(Sender: TObject);
var
   Reg : TRegistry;
   LatestVersion: string;
begin
   glResizeWnd(MainView.Width,MainView.Height);

   // 1.7:For future compatibility with other OS tools, we are
   // using the registry keys to confirm its existance.
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   if Reg.OpenKey('Software\CnC Tools\VoxelViewer\',true) then
   begin
      LatestVersion := Reg.ReadString('Version');
      if APPLICATION_VER_ID > LatestVersion then
      begin
         Reg.WriteString('Path',ParamStr(0));
         Reg.WriteString('Version',APPLICATION_VER);
      end;
   end;
   Reg.CloseKey;
   Reg.Free;

   if ParamCount > 0 then
      OpenVoxel(GetParamStr());
end;

procedure TVVFrmMain.MainViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   VH_MouseDown(Button,X, Y);
end;

procedure TVVFrmMain.MainViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   VH_MouseUp;
   MainView.Cursor := crCross;
end;

procedure TVVFrmMain.MainViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   VH_MouseMove(X,Y);
end;

procedure TVVFrmMain.AnimationTimerTimer(Sender: TObject);
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
      if AutoSizeCheck.Checked then
      MainView.Align := alClient
      else
      begin
       MainView.Align  := alNone;
       MainView.Width  := OGLSize.Value;
       MainView.Height := OGLSize.Value;
      end;

      exit;
   end;

   if ScreenShot.CaptureAnimation then
      ScreenShot.TakeAnimation := true;

   if AnimationBar.Position = N_Frames-1 then
      AnimationBar.Position := 0
   else
      AnimationBar.Position := AnimationBar.Position +1;

   FUpdateWorld := True;
end;

procedure TVVFrmMain.PlayAnimationClick(Sender: TObject);
begin
   AnimationTimer.Enabled := true;
end;

procedure TVVFrmMain.PauseAnimationClick(Sender: TObject);
begin
   AnimationTimer.Enabled := not AnimationTimer.Enabled;
end;

procedure TVVFrmMain.StopAnimationClick(Sender: TObject);
begin
   AnimationTimer.Enabled := False;
   AnimationBar.Position := 0;
end;

procedure TVVFrmMain.AnimationBarChange(Sender: TObject);
begin
   SetCurrentFrame(AnimationBar.Position);
   lblHVAFrame.Caption := 'Frame ' + inttostr(GetCurrentFrame+1) + '/' + inttostr(GetCurrentHVA^.Header.N_Frames);
end;

Procedure TVVFrmMain.SetAnimFrom;
begin
   AnimFrom.Clear;

   if VoxelOpen then
   begin
      AnimFrom.Items.Add('Body');
      AnimFrom.ItemsEx.Items[AnimFrom.Items.Count-1].ImageIndex := 4;
   end;

   if VoxelOpenT then
   begin
      AnimFrom.Items.Add('Turret');
      AnimFrom.ItemsEx.Items[AnimFrom.Items.Count-1].ImageIndex := 5;
   end;

   if VoxelOpenB then
   begin
      AnimFrom.Items.Add('Barrel');
      AnimFrom.ItemsEx.Items[AnimFrom.Items.Count-1].ImageIndex := 6;
   end;
end;

Procedure TVVFrmMain.SetIsHVA;
begin
   AnimFrom.Enabled := HVAOpen;
   AnimationBar.Enabled := HVAOpen;
   PlayAnimation.Enabled := HVAOpen;
   PauseAnimation.Enabled := HVAOpen;
   StopAnimation.Enabled := HVAOpen;
   lblHVAFrame.Enabled := HVAOpen;
end;

Procedure TVVFrmMain.SetIsEditable;
begin
   RemapColourBox.Enabled := VoxelOpen;
   SpeedButton2.Enabled := VoxelOpen;
   btn3DRotateX.Enabled := VoxelOpen;
   btn3DRotateX2.Enabled := VoxelOpen;
   btn3DRotateY.Enabled := VoxelOpen;
   btn3DRotateY2.Enabled := VoxelOpen;
   spin3Djmp.Enabled := VoxelOpen;
   SectionBox.Enabled := VoxelOpen;
   PageControl1.Enabled := VoxelOpen;
   GroundTexBox.Enabled := VoxelOpen;
   GroundCheckBox.Enabled := VoxelOpen;
   TileGroundCheckBox.Enabled := VoxelOpen;
   XTexShift.Enabled := VoxelOpen;
   YTexShift.Enabled := VoxelOpen;
   GroundSize.Enabled := VoxelOpen;
   GroundHeightOffsetSpinEdit.Enabled := VoxelOpen;
   Label8.Enabled := VoxelOpen;
   Label7.Enabled := VoxelOpen;
   Label6.Enabled := VoxelOpen;
   Label9.Enabled := VoxelOpen;

   GroundTexBox.Enabled := VoxelOpen;
   SkyTextureComboBox.Enabled := VoxelOpen;
   Label5.Enabled := VoxelOpen;
   Label10.Enabled := VoxelOpen;
   Label11.Enabled := VoxelOpen;
   Label12.Enabled := VoxelOpen;
   Label13.Enabled := VoxelOpen;
   Label14.Enabled := VoxelOpen;
   Label32.Enabled := VoxelOpen;
   Label33.Enabled := VoxelOpen;
   DrawSkyCheckBox.Enabled := VoxelOpen;
   SkyXPosSpinEdit.Enabled := VoxelOpen;
   SkyYPosSpinEdit.Enabled := VoxelOpen;
   SkyZPosSpinEdit.Enabled := VoxelOpen;
   SkyWidthSpinEdit.Enabled := VoxelOpen;
   SkyHeightSpinEdit.Enabled := VoxelOpen;
   SkyLengthSpinEdit.Enabled := VoxelOpen;

   Options1.Visible := VoxelOpen;
   View1.Visible := VoxelOpen;
   ools1.Visible := VoxelOpen;

   Label29.Enabled := VoxelOpenT;
   TurretRotationBar.Enabled := VoxelOpenT;

   // Options menu.
   {$ifdef DEBUG_BUILD}
   DebugVoxelBounds1.Visible := VoxelOpen;
   {$endif}
   {$ifdef BZK_BUILD}
   MakeBZKUnit1.Visible := VoxelOpen;
   MakeGeoUnitwithPrecompiledLighting1.Visible := VoxelOpen;
//   GenerateSurface1.Visible := VoxelOpen;
   {$endif}

   SetIsHVA;
end;

Procedure TVVFrmMain.SetCaption(Filename : String);
begin
   If Filename <> '' then
      Caption := ' ' + APPLICATION_TITLE + ' v'+APPLICATION_VER + ' [' +Extractfilename(Filename) + ']'
   else
      Caption := ' ' + APPLICATION_TITLE + ' v'+APPLICATION_VER;
end;

procedure TVVFrmMain.RemapColourBoxChange(Sender: TObject);
begin
   If (RemapColourBox.ItemIndex > 0) then
   begin
      RemapColour := TVector3bToTVector3f(RemapColourMap[RemapColourBox.ItemIndex-1]);
      ChangeRemappable(VXLPalette,RemapColour);
      RebuildLists := True;
   end
   else If LoadedProg then
      RemapTimer.Enabled := true;
end;

procedure TVVFrmMain.RemapTimerTimer(Sender: TObject);
begin
   RemapTimer.Enabled := False;
   ColorDialog.Color := TVector3ftoTColor(RemapColour);
   if ColorDialog.Execute then
   begin
      RemapColour := TColorToTVector3f(ColorDialog.Color);
      ChangeRemappable(VXLPalette,RemapColour);
      RebuildLists := True;
   end;
end;

procedure TVVFrmMain.AnimFromChange(Sender: TObject);
begin
   if AnimFrom.Items.Count < 1 then exit;

   if AnimFrom.ItemsEx.Items[AnimFrom.ItemIndex].ImageIndex = 5 then
      HVACurrentFrame := 1
   else if AnimFrom.ItemsEx.Items[AnimFrom.ItemIndex].ImageIndex = 6 then
      HVACurrentFrame := 2
   else
      HVACurrentFrame := 0;
end;

procedure TVVFrmMain.About1Click(Sender: TObject);
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

procedure TVVFrmMain.SpeedButton2Click(Sender: TObject);
begin
   Depth := DefaultDepth;
end;

Procedure TVVFrmMain.SetRotationAdders;
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

procedure TVVFrmMain.btn3DRotateXClick(Sender: TObject);
begin
   if btn3DRotateX.Down then
   begin
      SetRotationAdders;
      XRotB := True;
   end
   else
      XRotB := false;

   if XRotB or YRotB then
   Timer1.Interval := 50
   else
   Timer1.Interval := 100;
end;

procedure TVVFrmMain.btn3DRotateX2Click(Sender: TObject);
begin
   if btn3DRotateX2.Down then
   begin
      SetRotationAdders;
      XRotB := True;
   end
   else
      XRotB := false;

   if XRotB or YRotB then
   Timer1.Interval := 50
   else
   Timer1.Interval := 100;
end;

procedure TVVFrmMain.btn3DRotateY2Click(Sender: TObject);
begin
   if btn3DRotateY2.Down then
   begin
      SetRotationAdders;
      YRotB := True;
   end
   else
      YRotB := false;

   if XRotB or YRotB then
   Timer1.Interval := 50
   else
   Timer1.Interval := 100;
end;

procedure TVVFrmMain.btn3DRotateYClick(Sender: TObject);
begin
   if btn3DRotateY.Down then
   begin
      SetRotationAdders;
      YRotB := True;
   end
   else
      YRotB := false;

   if XRotB or YRotB then
   Timer1.Interval := 50
   else
   Timer1.Interval := 100;
end;

procedure TVVFrmMain.spin3DjmpChange(Sender: TObject);
begin
   SetRotationAdders;
end;

Procedure TVVFrmMain.SetupSections;
var
   i : integer;
begin
   SectionBox.Clear;

   SectionBox.Items.Add('View All');
   for i := 0 to (VoxelFile.Header.NumSections - 1) do
   begin
      SectionBox.Items.Add(VoxelFile.Section[i].Name);
      SectionBox.ItemsEx.Items[SectionBox.Items.Count-1].ImageIndex := 4;
   end;

   if VoxelOpenT then
      for i := 0 to (VoxelTurret.Header.NumSections - 1) do
      begin
         SectionBox.Items.Add(VoxelTurret.Section[i].Name);
         SectionBox.ItemsEx.Items[SectionBox.Items.Count-1].ImageIndex := 5;
      end;

   if VoxelOpenB then
      for i := 0 to (VoxelBarrel.Header.NumSections - 1) do
      begin
         SectionBox.Items.Add(VoxelBarrel.Section[i].Name);
         SectionBox.ItemsEx.Items[SectionBox.Items.Count-1].ImageIndex := 6;
      end;

   //SectionBox.ItemIndex := CurrentSection+1;
end;

procedure TVVFrmMain.SectionBoxChange(Sender: TObject);
begin
   if not VoxelOpen then exit;
   if SectionBox.Items.Count < 1 then exit; // Stops access violations when sectionbox is cleared.

   RebuildLists := True;

   if SectionBox.ItemIndex = 0 then
   begin
      CurrentSection := -1;
      CurrentSectionVoxel := @VoxelFile;
   end
   else
   begin
      if SectionBox.ItemIndex > VoxelFile.Header.NumSections then
         if VoxelOpenT then
         begin

            if SectionBox.ItemIndex <= VoxelFile.Header.NumSections+VoxelTurret.Header.NumSections then
            begin
               CurrentSection := SectionBox.ItemIndex-VoxelFile.Header.NumSections-1;
               CurrentSectionVoxel := @VoxelTurret;
            end
            else
               if VoxelOpenB then
                  if SectionBox.ItemIndex <= VoxelFile.Header.NumSections+VoxelTurret.Header.NumSections+VoxelBarrel.Header.NumSections then
                  begin
                     CurrentSection := SectionBox.ItemIndex-VoxelFile.Header.NumSections-VoxelTurret.Header.NumSections-1;
                     CurrentSectionVoxel := @VoxelBarrel;
                  end;
         end
         else
            if VoxelOpenB then
               if SectionBox.ItemIndex <= VoxelFile.Header.NumSections+VoxelBarrel.Header.NumSections then
               begin
                  CurrentSection := SectionBox.ItemIndex-VoxelFile.Header.NumSections-1;
                  CurrentSectionVoxel := @VoxelBarrel;
               end;

         if SectionBox.ItemIndex <= VoxelFile.Header.NumSections then
         begin
            CurrentSection := SectionBox.ItemIndex-1;
            CurrentSectionVoxel := @VoxelFile;
         end;
   end;
end;

procedure TVVFrmMain.FOVEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (FOVEdit.Text <> '') and (FOVEdit.Text <> ' ') then
      try
         FOV := FOVEdit.Value;
         glResizeWnd(MainView.Width,MainView.Height);
      except
      end;
end;

procedure TVVFrmMain.VisibleDistEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (VisibleDistEdit.Text <> '') and (VisibleDistEdit.Text <> ' ') then
      try
         DEPTH_OF_VIEW := VisibleDistEdit.Value;
         glResizeWnd(MainView.Width,MainView.Height);
      except
      end;
end;

procedure TVVFrmMain.UnitRotPopupButClick(Sender: TObject);
begin
   UnitRotPopupMenu.Popup(Left+TabSheet2.Left+PageControl1.Left+Panel7.Left+UnitRotPopupBut.Left+3,Top+Height-ClientHeight+Panel7.Top+TabSheet2.Top+PageControl1.Top+UnitRotPopupBut.Top+UnitRotPopupBut.Height-4);
   FUpdateWorld := True;
end;

procedure TVVFrmMain.N01Click(Sender: TObject);
begin
   RotationEdit.Text := inttostr(TMenuItem(Sender).Tag);
end;

procedure TVVFrmMain.RotationEditChange(Sender: TObject);
begin
   try
//RotationEdit.Text := floattostr(strtofloat(RotationEdit.Text));
      UnitRot := CleanAngle(strtofloatdef(RotationEdit.Text,0));
//UnitRotUpDown.Position := trunc(UnitRot);
   except
   end;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.UnitShiftXSpinEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (UnitShiftXSpinEdit.Text <> '') and (UnitShiftXSpinEdit.Text <> ' ') then
      try
         UnitShift.X := UnitShiftXSpinEdit.Value;
      except
      end;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.UnitShiftYSpinEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (UnitShiftYSpinEdit.Text <> '') and (UnitShiftYSpinEdit.Text <> ' ') then
      try
         UnitShift.Y := UnitShiftYSpinEdit.Value;
      except
      end;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.UnitShiftZSpinEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (UnitShiftZSpinEdit.Text <> '') and (UnitShiftZSpinEdit.Text <> ' ') then
      try
         UnitShift.Z := UnitShiftZSpinEdit.Value;
      except
      end;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.XTexShiftChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (XTexShift.Text <> '') and (XTexShift.Text <> ' ') then
      try
         TexShiftX := XTexShift.Value;
      except
      end;
FUpdateWorld := True;
end;

procedure TVVFrmMain.YTexShiftChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (YTexShift.Text <> '') and (YTexShift.Text <> ' ') then
      try
         TexShiftY := YTexShift.Value;
      except
      end;
FUpdateWorld := True;
end;

procedure TVVFrmMain.GroundHeightOffsetSpinEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (GroundHeightOffsetSpinEdit.Text <> '') and (GroundHeightOffsetSpinEdit.Text <> ' ') then
      try
         GroundHeightOffset := GroundHeightOffsetSpinEdit.Value;
      except
      end;

  FUpdateWorld := True;
end;

procedure TVVFrmMain.TileGroundCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   TileGround := not TileGround;
   TileGroundCheckBox.Checked := TileGround;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.GroundCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   Ground_Tex_Draw := not Ground_Tex_Draw;
   GroundCheckBox.Checked := Ground_Tex_Draw;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.DrawTurretCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   DrawTurret := not DrawTurret;
   DrawTurretCheckBox.Checked := DrawTurret;
   
   FUpdateWorld := True;
end;

procedure TVVFrmMain.DrawBarrelCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   DrawBarrel := not DrawBarrel;
   DrawBarrelCheckBox.Checked := DrawBarrel;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.ShowDebugCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   DebugMode := not DebugMode;
   ShowDebugCheckBox.Checked := DebugMode;
end;

procedure TVVFrmMain.VoxelCountCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   ShowVoxelCount := not ShowVoxelCount;
   VoxelCountCheckBox.Checked := ShowVoxelCount;
end;

procedure TVVFrmMain.CullFaceCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   CullFace := not CullFace;
   CullFaceCheckBox.Checked := CullFace;
end;

procedure TVVFrmMain.CamMovEditChange(Sender: TObject);
begin
   if (CamMovEdit.Text <> '') and (CamMovEdit.Text <> ' ') then
      try
         CamMov := strtofloat(CamMovEdit.text);
      except
      end;
end;

procedure TVVFrmMain.GroundSizeChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (GroundSize.Text <> '') and (GroundSize.Text <> ' ') then
      try
         if GroundSize.Value < 1 then exit;

         GSize := GroundSize.Value;
      except
      end;

FUpdateWorld := True;
end;

Procedure TVVFrmMain.BuildTexList;
var
   X,IID : integer;
   S : string;
begin
   GroundTexBox.Items.Clear;

   for x := 0 to GroundTex_No-1 do
   begin
      GroundTexBox.Items.Add(GroundTex_Textures[x].Name);
      s := ansiuppercase(copy(GroundTex_Textures[x].Name,1,length('RA2_')));

      IID := 0;

      if copy(s,1,length('TS_')) = 'TS_' then
         IID := 1
      else if s = 'RA2_' then
         IID := 2
      else if copy(s,1,length('YR_')) = 'YR_' then
         IID := 3;

      GroundTexBox.ItemsEx.Items[GroundTexBox.Items.Count-1].ImageIndex := IID;
   end;
   GroundTexBox.ItemIndex := 0;//GroundTex1.Id;

   GroundTexBoxChange(nil);
   //TexListBuilt := true;
end;

procedure TVVFrmMain.GroundTexBoxChange(Sender: TObject);
begin
   If VVSLoading then exit;

   GroundTex.Id := GroundTexBox.ItemIndex;
   GroundTex.Tex := GroundTex_Textures[GroundTex.Id].Tex;

   XTexShift.Value := 0;
   YTexShift.Value := 0;

   VVSLoading := true; //Fake a VVS loading

   TileGround := GroundTex_Textures[GroundTex.Id].Tile;
   TileGroundCheckBox.Checked := GroundTex_Textures[GroundTex.Id].Tile;

   VVSLoading := false;
   FUpdateWorld := True;
end;

Procedure TVVFrmMain.BuildSkyTextureComboBox;
var
   x : integer;
begin
   SkyTextureComboBox.Clear;

   for x := 0 to SkyTexList_no-1 do
      SkyTextureComboBox.Items.Add(SkyTexList[x].Texture_Name);

   SkyTextureComboBox.ItemIndex := 0;
end;

procedure TVVFrmMain.SkyTextureComboBoxChange(Sender: TObject);
begin
   if VVSLoading then exit;

   SkyTex := SkyTextureComboBox.ItemIndex;
   VH_BuildSkyBox;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.SkyWidthSpinEditChange(Sender: TObject);
begin
   if VVSLoading then exit;

   if (SkyWidthSpinEdit.Text <> '') and (SkyWidthSpinEdit.Text <> ' ') then
   try
      SkySize.X := SkyWidthSpinEdit.Value;
      VH_BuildSkyBox;
      FUpdateWorld := True;
   except
   end;
end;

procedure TVVFrmMain.SkyHeightSpinEditChange(Sender: TObject);
begin
   if VVSLoading then exit;

   if (SkyHeightSpinEdit.Text <> '') and (SkyHeightSpinEdit.Text <> ' ') then
   try
      SkySize.Y := SkyHeightSpinEdit.Value;
      VH_BuildSkyBox;
      FUpdateWorld := True;
   except
   end;
end;

procedure TVVFrmMain.SkyLengthSpinEditChange(Sender: TObject);
begin
   if VVSLoading then exit;

   if (SkyLengthSpinEdit.Text <> '') and (SkyLengthSpinEdit.Text <> ' ') then
   try
      SkySize.Z := SkyLengthSpinEdit.Value;
      VH_BuildSkyBox;
      FUpdateWorld := True;
   except
   end;
end;

procedure TVVFrmMain.SkyZPosSpinEditChange(Sender: TObject);
begin
   if VVSLoading then exit;

   if (SkyZPosSpinEdit.Text <> '') and (SkyZPosSpinEdit.Text <> ' ') then
   try
      SkyPos.Z := SkyZPosSpinEdit.Value;
      FUpdateWorld := True;
   except
   end;
end;

procedure TVVFrmMain.SkyYPosSpinEditChange(Sender: TObject);
begin
   if VVSLoading then exit;

   if (SkyYPosSpinEdit.Text <> '') and (SkyYPosSpinEdit.Text <> ' ') then
   try
      SkyPos.Y := SkyYPosSpinEdit.Value;
      FUpdateWorld := True;
   except
   end;
end;

procedure TVVFrmMain.SkyXPosSpinEditChange(Sender: TObject);
begin
   if VVSLoading then exit;

   if (SkyXPosSpinEdit.Text <> '') and (SkyXPosSpinEdit.Text <> ' ') then
   try
      SkyPos.X := SkyXPosSpinEdit.Value;
      FUpdateWorld := True;
   except
   end;
end;

procedure TVVFrmMain.DrawSkyCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   DrawSky := not DrawSky;
   DrawSkyCheckBox.Checked := DrawSky;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.Disable3DView1Click(Sender: TObject);
begin
   DrawVHWorld := not DrawVHWorld;
   Disable3DView1.Checked := not DrawVHWorld;

   If not DrawVHWorld then
      MainView.Repaint;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.ColoursNormals1Click(Sender: TObject);
begin
   SetSpectrum(True);
   ColoursNormals1.Checked := true;
   Normals1.Checked := false;
   Colours1.Checked := false;
   ColoursOnly := false;
   RebuildLists := True;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.Colours1Click(Sender: TObject);
begin
   SetSpectrum(True);
   ColoursNormals1.Checked := false;
   Normals1.Checked := false;
   Colours1.Checked := true;
   ColoursOnly := True;
   RebuildLists := True;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.Normals1Click(Sender: TObject);
begin
   SetSpectrum(False);
   ColoursNormals1.Checked := false;
   Normals1.Checked := true;
   Colours1.Checked := false;
   ColoursOnly := false;
   RebuildLists := True;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.CameraManager1Click(Sender: TObject);
var
   frm: TFrmCameraManager_New;
begin
   frm:=TFrmCameraManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;
   frm.XRot.Text := FloatToStr(XRot);
   frm.YRot.Text := FloatToStr(YRot);
   frm.Depth.Text := FloatToStr(Depth);
   frm.TargetX.Text := FloatToStr(CameraCenter.X);
   frm.TargetY.Text := FloatToStr(CameraCenter.Y);
   frm.ShowModal;
   frm.Close;

   if Frm.O then
   begin
      XRot := StrToFloatDef(frm.XRot.Text,XRot);
      YRot := StrToFloatDef(frm.YRot.Text,YRot);
      Depth := StrToFloatDef(frm.Depth.Text,Depth);
      CameraCenter.X := StrToFloatDef(frm.TargetX.Text,CameraCenter.X);
      CameraCenter.Y := StrToFloatDef(frm.TargetY.Text,CameraCenter.Y);
   end;

   frm.Free;
end;

procedure TVVFrmMain.Help2Click(Sender: TObject);
begin
   if not fileexists(extractfiledir(paramstr(0))+'/osvv_help.chm') then
   begin
      messagebox(0,'Help' + #13#13 + 'osvv_help.chm not found','Help',0);
      exit;
   end;
   RunAProgram('osvv_help.chm','',extractfiledir(paramstr(0)));
end;

Procedure TVVFrmMain.ChangeView(Sender : TObject);
begin
   VH_ChangeView(TMenuItem(Sender).Tag);
end;

procedure TVVFrmMain.ScreenShot1Click(Sender: TObject);
var
   frm: TFrmScreenShotManager_New;
begin
   frm:=TFrmScreenShotManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;
//  Frm.Image1.Refresh;
   If ScreenShot._Type = 0 then
      frm.RadioButton1.Checked := True
   else If ScreenShot._Type = 1 then
      frm.RadioButton2.Checked := True
   else
      frm.RadioButton3.Checked := True;

   frm.RadioButton1Click(Sender);
   Frm.Compression.Position := ScreenShot.CompressionRate;

   if ScreenShot.Width = -1 then
      ScreenShot.Width := MainView.Width;

   if ScreenShot.Height = -1 then
      ScreenShot.Height := MainView.Height;

   Frm.MainViewWidth.Value := Min(ScreenShot.Width,MainView.Width);
   Frm.MainViewWidth.MaxValue := MainView.Width;
   Frm.MainViewHeight.Value := Min(ScreenShot.Height,MainView.Height);
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
      else If frm.RadioButton2.Checked then
         ScreenShot._Type := 1
      else
         ScreenShot._Type := 2;

      ScreenShot.CompressionRate := Frm.Compression.Position;
      ScreenShot.Take := true;
   end;

   frm.Free;
end;

procedure TVVFrmMain.BackgroundColour1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector3fToTColor(BGColor);
   if ColorDialog.Execute then
      VH_SetBGColour(TColorToTVector3f(ColorDialog.Color));
   FUpdateWorld := True;
end;

procedure TVVFrmMain.extColour1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector3fToTColor(FontColor);
   if ColorDialog.Execute then
      FontColor := TColorToTVector3f(ColorDialog.Color);
   FUpdateWorld := True;
end;

procedure TVVFrmMain.CaptureAnimation1Click(Sender: TObject);
var
   frm: TFrmAniamtionManager_New;
begin
   frm:=TFrmAniamtionManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   if ScreenShot.Width = -1 then
      ScreenShot.Width := MainView.Width;

   if ScreenShot.Height = -1 then
      ScreenShot.Height := MainView.Height;

   Frm.MainViewWidth.Value := ScreenShot.Width;
   Frm.MainViewWidth.MaxValue := MainView.Width;

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
      ScreenShot.Height := Frm.MainViewWidth.Value;
      MainView.Width := Frm.MainViewWidth.Value;
      MainView.Height := Frm.MainViewWidth.Value;
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

Procedure TVVFrmMain.ClearRotationAdders;
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

procedure TVVFrmMain.LoadScene1Click(Sender: TObject);
begin
   if OpenVVSDialog.Execute then
   begin
      AnimationTimer.Enabled := false;
      AnimationBar.Position := 0;
      //AnimationBarChange(Sender);
      HVAFrame := 0;
      HVAFrameT := 0;
      HVAFrameB := 0;

      ClearRotationAdders;

      VH_LoadVVS(OpenVVSDialog.FileName);

      //Update Components on MainForm
      VVSLoading := true;

      GroundCheckBox.Checked := Ground_Tex_Draw;
      TileGroundCheckBox.Checked := TileGround;
      DrawTurretCheckBox.Checked := DrawTurret;
      DrawBarrelCheckBox.Checked := DrawBarrel;
      ShowDebugCheckBox.Checked := DebugMode;
      VoxelCountCheckBox.Checked := ShowVoxelCount;

      XTexShift.Value := trunc(TexShiftX);
      YTexShift.Value := trunc(TexShiftY);
      GroundSize.Value := trunc(GSize);
      GroundHeightOffsetSpinEdit.Value := trunc(GroundHeightOffset);

      //if VoxelFile.Section[0].Tailer.Unknown = 2 then
      GroundTexBox.ItemIndex := GroundTex.ID;
      {else
         GroundTexBox.ItemIndex := GroundTex.ID;  }

      SkyTextureComboBox.ItemIndex := SkyTex;

      SkyXPosSpinEdit.Value := trunc(SkyPos.X);
      SkyYPosSpinEdit.Value := trunc(SkyPos.Y);
      SkyZPosSpinEdit.Value := trunc(SkyPos.Z);

      SkyWidthSpinEdit.Value := trunc(SkySize.X);
      SkyHeightSpinEdit.Value := trunc(SkySize.Y);
      SkyLengthSpinEdit.Value := trunc(SkySize.Z);

      DrawSkyCheckBox.Checked := DrawSky;
      CullFaceCheckBox.Checked := CullFace;

      FOVEdit.Value := trunc(FOV);
      VisibleDistEdit.Value := trunc(DEPTH_OF_VIEW);
      RotationEdit.Text := floattostr(UnitRot);

      AmbientRed.Value   := Trunc(LightAmb.X*255);
      AmbientGreen.Value := Trunc(LightAmb.Y*255);
      AmbientBlue.Value  := Trunc(LightAmb.Z*255);

      DiffuseRed.Value   := Trunc(LightDif.X*255);
      DiffuseGreen.Value := Trunc(LightDif.Y*255);
      DiffuseBlue.Value  := Trunc(LightDif.Z*255);

      LightGroundCheckBox.Checked := LightGround;
      TurretRotationBar.Position := trunc(VXLTurretRotation.X);

      VH_SetBGColour(BGColor);

      Case Trunc(UnitCount) of
       1 : UnitCountCombo.ItemIndex := 0;
       4 : UnitCountCombo.ItemIndex := 1;
       8 : UnitCountCombo.ItemIndex := 2;
      end;

      UnitSpaceEdit.Value := Trunc(UnitSpace);

      VVSLoading := False;
   end;
end;

procedure TVVFrmMain.SaveScene1Click(Sender: TObject);
begin
   if SaveVVSDialog.Execute then
      VH_SaveVVS(SaveVVSDialog.FileName);
end;

procedure TVVFrmMain.Make360DegreeAnimation1Click(Sender: TObject);
var
   frm: TFrmAniamtionManager_New;
begin
   frm:=TFrmAniamtionManager_New.Create(Self);
   frm.Visible:=False;
   Frm.Image1.Picture := TopBarImageHolder.Picture;

   if ScreenShot.Width = -1 then
      ScreenShot.Width := Min(MainView.Width,300);

   if ScreenShot.Height = -1 then
      ScreenShot.Height := Min(MainView.Width,300);

   Frm.MainViewWidth.Value := Min(ScreenShot.Width,MainView.Width);
   Frm.MainViewWidth.MaxValue := MainView.Width;

   Frm.Frames.Value := ScreenShot.Frames;

{  Frm.Frames.Enabled := false;
  Frm.Label2.Enabled := false;
  Frm.Label4.Enabled := false;
  Frm.Label7.Enabled := false;  }

   if not HVAOpen then
      Frm.AnimateCheckBox.Enabled := false;

   frm.ShowModal;
   frm.Close;

   if frm.O then
   begin
      MainView.Align := alNone;
      ScreenShot.Width := Frm.MainViewWidth.Value;
      ScreenShot.Height := Frm.MainViewWidth.Value;
      MainView.Width := Frm.MainViewWidth.Value;
      MainView.Height := Frm.MainViewWidth.Value;
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

procedure TVVFrmMain.AmbientRedChange(Sender: TObject);
begin
   if (AmbientRed.Text <> '') and (AmbientRed.Text <> ' ') then
      try
         LightAmb.X := AmbientRed.Value/255;
      except
      end;
   if LightGround then
   FUpdateWorld := True;
end;

procedure TVVFrmMain.AmbientGreenChange(Sender: TObject);
begin
   if (AmbientGreen.Text <> '') and (AmbientGreen.Text <> ' ') then
      try
         LightAmb.Y := AmbientGreen.Value/255;
      except
      end;
   if LightGround then
   FUpdateWorld := True;
end;

procedure TVVFrmMain.AmbientBlueChange(Sender: TObject);
begin
   if (AmbientBlue.Text <> '') and (AmbientBlue.Text <> ' ') then
      try
         LightAmb.Z := AmbientBlue.Value/255;
      except
      end;
   if LightGround then
   FUpdateWorld := True;
end;

procedure TVVFrmMain.DiffuseRedChange(Sender: TObject);
begin
   if (DiffuseRed.Text <> '') and (DiffuseRed.Text <> ' ') then
      try
         LightDif.X := DiffuseRed.Value/255;
      except
      end;
   if LightGround then
   FUpdateWorld := True;
end;

procedure TVVFrmMain.DiffuseGreenChange(Sender: TObject);
begin
   if (DiffuseGreen.Text <> '') and (DiffuseGreen.Text <> ' ') then
      try
         LightDif.Y := DiffuseGreen.Value/255;
      except
      end;
   if LightGround then
   FUpdateWorld := True;
end;

procedure TVVFrmMain.DiffuseBlueChange(Sender: TObject);
begin
   if (DiffuseBlue.Text <> '') and (DiffuseBlue.Text <> ' ') then
      try
         LightDif.Z := DiffuseBlue.Value/255;
      except
      end;
   if LightGround then
   FUpdateWorld := True;
end;

procedure TVVFrmMain.SpeedButton1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector4fToTColor(LightAmb);
   if ColorDialog.Execute then
      LightAmb := TColorToTVector4f(ColorDialog.Color);

   AmbientRed.Value   := Trunc(LightAmb.X*255);
   AmbientGreen.Value := Trunc(LightAmb.Y*255);
   AmbientBlue.Value  := Trunc(LightAmb.Z*255);
end;

procedure TVVFrmMain.SpeedButton3Click(Sender: TObject);
begin
   ColorDialog.Color := TVector4fToTColor(LightDif);
   if ColorDialog.Execute then
      LightDif := TColorToTVector4f(ColorDialog.Color);

   DiffuseRed.Value   := Trunc(LightDif.X*255);
   DiffuseGreen.Value := Trunc(LightDif.Y*255);
   DiffuseBlue.Value  := Trunc(LightDif.Z*255);
end;

procedure TVVFrmMain.LightGroundCheckBoxClick(Sender: TObject);
begin
   If VVSLoading then exit;

   LightGround := Not LightGround;
   LightGroundCheckBox.Checked := LightGround;
   FUpdateWorld := True;
end;

procedure TVVFrmMain.TurretRotationBarChange(Sender: TObject);
begin
   VXLTurretRotation.X := TurretRotationBar.Position;
   FUpdateWorld := True;
end;

// Interpretates comunications from other programs
// Check SHP Builder project source (PostMessage commands)

procedure TVVFrmMain.CopyData(var Msg: TMessage);
var
  cd: ^TCOPYDATASTRUCT;
  p: pchar;
begin
   cd:=Pointer(msg.lParam);
   msg.result:=0;
   if cd^.dwData=(12345234) then
   begin
      try
     // showmessage('hi');
         p:=cd^.lpData;
     // showmessage(p);
         p := pchar(copy(p,2,length(p)));
         if Fileexists(p) then
         begin
            OpenVXLDialog.FileName := P;

            LoadVoxel(OpenVXLDialog.FileName);

            //If HVAOpen then
            SetCaption(OpenVXLDialog.FileName);

            SetupSections;
            SectionBox.ItemIndex := 0;
            SectionBoxChange(nil);

            SetAnimFrom;
            AnimFrom.ItemIndex := 0;
            AnimFromChange(nil);

            SetIsEditable;

            If HVAOpen then
               AnimationBar.Max := HVAFile.Header.N_Frames-1
            else
               AnimationBar.Max := 0;

            lblHVAFrame.Caption := 'Frame ' + inttostr(GetCurrentFrame+1) + '/' + inttostr(GetCurrentHVA^.Header.N_Frames);
         end;
        { process data }
        msg.result:=-1;
      except
      end;
   end;
end;

procedure TVVFrmMain.DebugVoxelBounds1Click(Sender: TObject);
var
   SectionNum : integer;
   Filename : string;
   F : system.Text;
   x,y,z,w : Double;
begin
   if VoxelOpen then
   begin
      Filename := copy(VoxelFile.Filename,1,length(VoxelFile.Filename)-length('.vxl'));
      if MessageBox(Application.Handle,PChar('Building ' + Filename + '_debug_bounds.txt. Go ahead?'),'Debug Voxel Bounds',MB_YESNO) = ID_YES then
      begin
         DecimalSeparator := '.';
         AssignFile(F,Filename + '_debug_bounds.txt');
         Rewrite(F);
         writeln(F,VoxelFile.Filename + ' Report Starting...');
         writeln(F);
         writeln(F, 'Type: ' + VoxelFile.Header.FileType);
         writeln(F, 'Unknown: ' + IntToStr(VoxelFile.Header.Unknown));
         writeln(F, 'Num Sections: ' + IntToStr(VoxelFile.Header.NumSections));
         writeln(F, 'Num Sections 2: ' + IntToStr(VoxelFile.Header.NumSections2));
         writeln(F);
         writeln(F);
         // Print info from main body voxel and its sections.
         for SectionNum := Low(VoxelFile.Section) to High(VoxelFile.Section) do
         begin
            writeln(F,'Starting section ' + IntToStr(SectionNum) + ':');
            writeln(F);
            writeln(F, 'Name: ' + VoxelFile.Section[SectionNum].Header.Name);
            writeln(F, 'MinBounds: (' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.MinBounds[1]) + '; ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.MinBounds[2]) + '; ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.MinBounds[3]) + ')');
            writeln(F, 'MaxBounds: (' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.MaxBounds[1]) + '; ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.MaxBounds[2]) + '; ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.MaxBounds[3]) + ')');
            writeln(F, 'Unknown 1: ' + IntToStr(VoxelFile.Section[SectionNum].Header.Unknown1));
            writeln(F, 'Unknown 2: ' + IntToStr(VoxelFile.Section[SectionNum].Header.Unknown2));
            writeln(F, 'Number: ' + IntToStr(VoxelFile.Section[SectionNum].Header.Number));
            writeln(F, 'Size X : ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.XSize));
            writeln(F, 'Size Y : ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.YSize));
            writeln(F, 'Size Z : ' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.ZSize));
            writeln(F, 'Det: (' + FloatToStr(VoxelFile.Section[SectionNum].Tailer.Det) + ')');
            writeln(F);
            writeln(F);
            writeln(F,'Transformation Matrix: ');
            writeln(F);
            writeln(F, FloatToStrF(GetTMValue2(HVAFile,1,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,1,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,1,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,1,4,SectionNum,1),ffFixed,15,17));
            writeln(F, FloatToStrF(GetTMValue2(HVAFile,2,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,2,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,2,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,2,4,SectionNum,1),ffFixed,15,17));
            writeln(F, FloatToStrF(GetTMValue2(HVAFile,3,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,3,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,3,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,3,4,SectionNum,1),ffFixed,15,17));
            writeln(F, FloatToStrF(GetTMValue2(HVAFile,4,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,4,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,4,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVAFile,4,4,SectionNum,1),ffFixed,15,17));
            writeln(F);
            writeln(F);
            writeln(F);
            writeln(F,'Transformation Calculations:');
            writeln(F);
            x := (VoxelFile.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVAFile,1,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVAFile,1,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVAFile,1,3,SectionNum,1)) + GetTMValue2(HVAFile,1,4,SectionNum,1);
            y := (VoxelFile.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVAFile,2,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVAFile,2,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVAFile,2,3,SectionNum,1)) + GetTMValue2(HVAFile,2,4,SectionNum,1);
            z := (VoxelFile.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVAFile,3,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVAFile,3,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVAFile,3,3,SectionNum,1)) + GetTMValue2(HVAFile,3,4,SectionNum,1);
            w := (VoxelFile.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVAFile,4,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVAFile,4,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVAFile,4,3,SectionNum,1)) + GetTMValue2(HVAFile,4,4,SectionNum,1);
            writeln(F, 'MinBounds: (' + FloatToStr(x) + ', ' + FloatToStr(y) + ', ' + FloatToStr(z) + ', ' + FloatToStr(w) + ')');
            if (w <> 0) then
               writeln(F, 'MinBounds Normalized: (' + FloatToStr(x/w) + ', ' + FloatToStr(y/w) + ', ' + FloatToStr(z/w) + ', ' + FloatToStr(w/w) + ')');
            x := (VoxelFile.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVAFile,1,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVAFile,1,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVAFile,1,3,SectionNum,1)) + GetTMValue2(HVAFile,1,4,SectionNum,1);
            y := (VoxelFile.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVAFile,2,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVAFile,2,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVAFile,2,3,SectionNum,1)) + GetTMValue2(HVAFile,2,4,SectionNum,1);
            z := (VoxelFile.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVAFile,3,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVAFile,3,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVAFile,3,3,SectionNum,1)) + GetTMValue2(HVAFile,3,4,SectionNum,1);
            w := (VoxelFile.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVAFile,4,1,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVAFile,4,2,SectionNum,1)) + (VoxelFile.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVAFile,4,3,SectionNum,1)) + GetTMValue2(HVAFile,4,4,SectionNum,1);
            writeln(F, 'MaxBounds: (' + FloatToStr(x) + ', ' + FloatToStr(y) + ', ' + FloatToStr(z) + ', ' + FloatToStr(w) + ')');
            if (w <> 0) then
               writeln(F, 'MaxBounds Normalized: (' + FloatToStr(x/w) + ', ' + FloatToStr(y/w) + ', ' + FloatToStr(z/w) + ', ' + FloatToStr(w/w) + ')');
            writeln(F);
            writeln(F);
         end;
         writeln(F);
         // Check for turret.
         if VoxelOpenT then
         begin
            writeln(F,VoxelTurret.Filename + ' Report Starting...');
            writeln(F);
            writeln(F, 'Type: ' + VoxelTurret.Header.FileType);
            writeln(F, 'Unknown: ' + IntToStr(VoxelTurret.Header.Unknown));
            writeln(F, 'Num Sections: ' + IntToStr(VoxelTurret.Header.NumSections));
            writeln(F, 'Num Sections 2: ' + IntToStr(VoxelTurret.Header.NumSections2));
            writeln(F);
            writeln(F);
            for SectionNum := Low(VoxelTurret.Section) to High(VoxelTurret.Section) do
            begin
               writeln(F,'Starting section ' + IntToStr(SectionNum) + ':');
               writeln(F);
               writeln(F, 'Name: ' + VoxelTurret.Section[SectionNum].Header.Name);
               writeln(F, 'MinBounds: (' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.MinBounds[1]) + ',' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.MinBounds[2]) + ',' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.MinBounds[3]) + ')');
               writeln(F, 'MaxBounds: (' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.MaxBounds[1]) + ',' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.MaxBounds[2]) + ',' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.MaxBounds[3]) + ')');
               writeln(F, 'Unknown 1: ' + IntToStr(VoxelTurret.Section[SectionNum].Header.Unknown1));
               writeln(F, 'Unknown 2: ' + IntToStr(VoxelTurret.Section[SectionNum].Header.Unknown2));
               writeln(F, 'Number: ' + IntToStr(VoxelTurret.Section[SectionNum].Header.Number));
               writeln(F, 'Size X : ' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.XSize));
               writeln(F, 'Size Y : ' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.YSize));
               writeln(F, 'Size Z : ' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.ZSize));
               writeln(F, 'Det: (' + FloatToStr(VoxelTurret.Section[SectionNum].Tailer.Det) + ')');
               writeln(F);
               writeln(F);
               writeln(F,'Transformation Matrix: ');
               writeln(F);
               writeln(F, FloatToStrF(GetTMValue2(HVATurret,1,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,1,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,1,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,1,4,SectionNum,1),ffFixed,15,17));
               writeln(F, FloatToStrF(GetTMValue2(HVATurret,2,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,2,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,2,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,2,4,SectionNum,1),ffFixed,15,17));
               writeln(F, FloatToStrF(GetTMValue2(HVATurret,3,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,3,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,3,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,3,4,SectionNum,1),ffFixed,15,17));
               writeln(F, FloatToStrF(GetTMValue2(HVATurret,4,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,4,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,4,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVATurret,4,4,SectionNum,1),ffFixed,15,17));
               writeln(F);
               writeln(F);
               writeln(F);
               writeln(F,'Transformation Calculations:');
               writeln(F);
               x := (VoxelTurret.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVATurret,1,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVATurret,1,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVATurret,1,3,SectionNum,1)) + GetTMValue2(HVATurret,1,4,SectionNum,1);
               y := (VoxelTurret.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVATurret,2,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVATurret,2,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVATurret,2,3,SectionNum,1)) + GetTMValue2(HVATurret,2,4,SectionNum,1);
               z := (VoxelTurret.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVATurret,3,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVATurret,3,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVATurret,3,3,SectionNum,1)) + GetTMValue2(HVATurret,3,4,SectionNum,1);
               w := (VoxelTurret.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVATurret,4,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVATurret,4,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVATurret,4,3,SectionNum,1)) + GetTMValue2(HVATurret,4,4,SectionNum,1);
               writeln(F, 'MinBounds: (' + FloatToStr(x) + ', ' + FloatToStr(y) + ', ' + FloatToStr(z) + ', ' + FloatToStr(w) + ')');
               if (w <> 0) then
                  writeln(F, 'MinBounds Normalized: (' + FloatToStr(x/w) + ', ' + FloatToStr(y/w) + ', ' + FloatToStr(z/w) + ', ' + FloatToStr(w/w) + ')');
               x := (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVATurret,1,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVATurret,1,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVATurret,1,3,SectionNum,1)) + GetTMValue2(HVATurret,1,4,SectionNum,1);
               y := (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVATurret,2,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVATurret,2,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVATurret,2,3,SectionNum,1)) + GetTMValue2(HVATurret,2,4,SectionNum,1);
               z := (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVATurret,3,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVATurret,3,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVATurret,3,3,SectionNum,1)) + GetTMValue2(HVATurret,3,4,SectionNum,1);
               w := (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVATurret,4,1,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVATurret,4,2,SectionNum,1)) + (VoxelTurret.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVATurret,4,3,SectionNum,1)) + GetTMValue2(HVATurret,4,4,SectionNum,1);
               writeln(F, 'MaxBounds: (' + FloatToStr(x) + ', ' + FloatToStr(y) + ', ' + FloatToStr(z) + ', ' + FloatToStr(w) + ')');
               if (w <> 0) then
                  writeln(F, 'MaxBounds Normalized: (' + FloatToStr(x/w) + ', ' + FloatToStr(y/w) + ', ' + FloatToStr(z/w) + ', ' + FloatToStr(w/w) + ')');
               writeln(F);
               writeln(F);
            end;
            writeln(F);
         end;
         // Check for barrel.
         if VoxelOpenB then
         begin
            writeln(F,VoxelBarrel.Filename + ' Report Starting...');
            writeln(F);
            writeln(F, 'Type: ' + VoxelBarrel.Header.FileType);
            writeln(F, 'Unknown: ' + IntToStr(VoxelBarrel.Header.Unknown));
            writeln(F, 'Num Sections: ' + IntToStr(VoxelBarrel.Header.NumSections));
            writeln(F, 'Num Sections 2: ' + IntToStr(VoxelBarrel.Header.NumSections2));
            writeln(F);
            writeln(F);
            for SectionNum := Low(VoxelBarrel.Section) to High(VoxelBarrel.Section) do
            begin
               writeln(F,'Starting section ' + IntToStr(SectionNum) + ':');
               writeln(F);
               writeln(F, 'Name: ' + VoxelBarrel.Section[SectionNum].Header.Name);
               writeln(F, 'MinBounds: (' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.MinBounds[1]) + ',' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.MinBounds[2]) + ',' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.MinBounds[3]) + ')');
               writeln(F, 'MaxBounds: (' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[1]) + ',' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[2]) + ',' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[3]) + ')');
               writeln(F, 'Unknown 1: ' + IntToStr(VoxelBarrel.Section[SectionNum].Header.Unknown1));
               writeln(F, 'Unknown 2: ' + IntToStr(VoxelBarrel.Section[SectionNum].Header.Unknown2));
               writeln(F, 'Number: ' + IntToStr(VoxelBarrel.Section[SectionNum].Header.Number));
               writeln(F, 'Size X : ' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.XSize));
               writeln(F, 'Size Y : ' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.YSize));
               writeln(F, 'Size Z : ' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.ZSize));
               writeln(F, 'Det: (' + FloatToStr(VoxelBarrel.Section[SectionNum].Tailer.Det) + ')');
               writeln(F);
               writeln(F);
               writeln(F,'Transformation Matrix: ');
               writeln(F);
               writeln(F, FloatToStrF(GetTMValue2(HVABarrel,1,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,1,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,1,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,1,4,SectionNum,1),ffFixed,15,17));
               writeln(F, FloatToStrF(GetTMValue2(HVABarrel,2,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,2,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,2,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,2,4,SectionNum,1),ffFixed,15,17));
               writeln(F, FloatToStrF(GetTMValue2(HVABarrel,3,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,3,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,3,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,3,4,SectionNum,1),ffFixed,15,17));
               writeln(F, FloatToStrF(GetTMValue2(HVABarrel,4,1,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,4,2,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,4,3,SectionNum,1),ffFixed,15,17) + ' :: ' + FloatToStrF(GetTMValue2(HVABarrel,4,4,SectionNum,1),ffFixed,15,17));
               writeln(F);
               writeln(F);
               writeln(F);
               writeln(F,'Transformation Calculations:');
               writeln(F);
               x := (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVABarrel,1,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVABarrel,1,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVABarrel,1,3,SectionNum,1)) + GetTMValue2(HVABarrel,1,4,SectionNum,1);
               y := (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVABarrel,2,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVABarrel,2,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVABarrel,2,3,SectionNum,1)) + GetTMValue2(HVABarrel,2,4,SectionNum,1);
               z := (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVABarrel,3,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVABarrel,3,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVABarrel,3,3,SectionNum,1)) + GetTMValue2(HVABarrel,3,4,SectionNum,1);
               w := (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[1] * GetTMValue2(HVABarrel,4,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[2] * GetTMValue2(HVABarrel,4,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MinBounds[3] * GetTMValue2(HVABarrel,4,3,SectionNum,1)) + GetTMValue2(HVABarrel,4,4,SectionNum,1);
               writeln(F, 'MinBounds: (' + FloatToStr(x) + ', ' + FloatToStr(y) + ', ' + FloatToStr(z) + ', ' + FloatToStr(w) + ')');
               if (w <> 0) then
                  writeln(F, 'MinBounds Normalized: (' + FloatToStr(x/w) + ', ' + FloatToStr(y/w) + ', ' + FloatToStr(z/w) + ', ' + FloatToStr(w/w) + ')');
               x := (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVABarrel,1,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVABarrel,1,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVABarrel,1,3,SectionNum,1)) + GetTMValue2(HVABarrel,1,4,SectionNum,1);
               y := (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVABarrel,2,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVABarrel,2,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVABarrel,2,3,SectionNum,1)) + GetTMValue2(HVABarrel,2,4,SectionNum,1);
               z := (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVABarrel,3,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVABarrel,3,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVABarrel,3,3,SectionNum,1)) + GetTMValue2(HVABarrel,3,4,SectionNum,1);
               w := (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[1] * GetTMValue2(HVABarrel,4,1,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[2] * GetTMValue2(HVABarrel,4,2,SectionNum,1)) + (VoxelBarrel.Section[SectionNum].Tailer.MaxBounds[3] * GetTMValue2(HVABarrel,4,3,SectionNum,1)) + GetTMValue2(HVABarrel,4,4,SectionNum,1);
               writeln(F, 'MaxBounds: (' + FloatToStr(x) + ', ' + FloatToStr(y) + ', ' + FloatToStr(z) + ', ' + FloatToStr(w) + ')');
               if (w <> 0) then
                  writeln(F, 'MaxBounds Normalized: (' + FloatToStr(x/w) + ', ' + FloatToStr(y/w) + ', ' + FloatToStr(z/w) + ', ' + FloatToStr(w/w) + ')');
               writeln(F);
               writeln(F);
            end;
            writeln(F);
         end;
         CloseFile(F);
      end;
   end;
end;

procedure TVVFrmMain.MakeBZKUnit1Click(Sender: TObject);
   procedure UnpackVoxel(PackedVoxel: TVoxelPacked; var dest: TVoxelUnpacked);
   begin
      dest.Normal := (PackedVoxel and $000000FF);
      dest.Colour := (PackedVoxel and $0000FF00) shr 8;
      dest.Used :=   (PackedVoxel and $00010000) > 0;
      dest.Flags :=  (PackedVoxel and $FF000000) shr 24;
   end;
// Make BZK Unit Starts here.
var
   Filename : string;
   F : system.Text;
   x,y,z,i : Integer;
   data : smallint;
   Voxel : TVoxelUnpacked;
begin
   if VoxelOpen then
   begin
      Filename := copy(VoxelFile.Filename,1,length(VoxelFile.Filename)-length('.vxl'));
      if MessageBox(Application.Handle,PChar('Building ' + Filename + '.geo. Go ahead?'),'Debug Voxel Bounds',MB_YESNO) = ID_YES then
      begin
         AssignFile(F,Filename + '.geo');
         Rewrite(F);
         // Write number of colours
         writeln(F, IntToStr(High(VXLPalette) + 1) );
         // Write palette colours
         for i := 0 to High(VXLPalette) do
         begin
            writeln(F, IntToStr(GetRValue(VXLPalette[i])));
            writeln(F, IntToStr(GetGValue(VXLPalette[i])));
            writeln(F, IntToStr(GetBValue(VXLPalette[i])));
            writeln(F, '255'); // alpha
         end;
         // Write sector header.
         // section size.
         writeln(F, IntToStr(VoxelFile.Section[0].Tailer.XSize));
         writeln(F, IntToStr(VoxelFile.Section[0].Tailer.YSize));
         writeln(F, IntToStr(VoxelFile.Section[0].Tailer.ZSize));
         // section scales.
         writeln(F, IntToStr(Round((VoxelFile.Section[0].Tailer.MaxBounds[1]-VoxelFile.Section[0].Tailer.MinBounds[1])/VoxelFile.Section[0].Tailer.xSize)));
         writeln(F, IntToStr(Round((VoxelFile.Section[0].Tailer.MaxBounds[2]-VoxelFile.Section[0].Tailer.MinBounds[2])/VoxelFile.Section[0].Tailer.ySize)));
         writeln(F, IntToStr(Round((VoxelFile.Section[0].Tailer.MaxBounds[3]-VoxelFile.Section[0].Tailer.MinBounds[3])/VoxelFile.Section[0].Tailer.zSize)));
         // Print each matrix.
         for z := 0 to VoxelFile.Section[0].Tailer.ZSize-1 do
         begin
            writeln(F,IntToStr(z));
            for y := 0 to VoxelFile.Section[0].Tailer.YSize-1 do
            begin
               // Write the first byte
               UnpackVoxel(VoxelFile.Section[0].Data[0,y,z],Voxel);
               if Voxel.Used then
                  data := Voxel.Colour
               else
                  data := -1;
               Write(F,IntToStr(data));
               if VoxelFile.Section[0].Tailer.XSize > 1 then
               begin
                  Write(F,' ');
                  // Write middle stuff
                  for x := 1 to VoxelFile.Section[0].Tailer.XSize-2 do
                  begin
                     UnpackVoxel(VoxelFile.Section[0].Data[x,y,z],Voxel);
                     if Voxel.Used then
                        data := Voxel.Colour
                     else
                        data := -1;
                     Write(F,IntToStr(data) + ' ');
                  end;
                  // Write the last element.
                  UnpackVoxel(VoxelFile.Section[0].Data[VoxelFile.Section[0].Tailer.XSize-1,y,z],Voxel);
                  if Voxel.Used then
                     data := Voxel.Colour
                  else
                     data := -1;
                  Writeln(F,IntToStr(data));
               end;
            end;
         end;
         CloseFile(F);
      end;
   end;
   ShowMessage('Geo Unit Saved Successfully at ' + Filename + '.geo');
end;

procedure TVVFrmMain.GenerateSurface1Click(Sender: TObject);
var
   Frm: TFrmSurfaces;
   P1,P2,P3,P4 : TVector3i;
   T1,T2,T3,T4 : TVector3f;
begin
   // Here comes the code for the top secret surface generator.
   Frm := TFrmSurfaces.Create(Self);
   Frm.ShowModal;

   if Frm.Changed then
   begin
      // Get points, starting with P1
      P1.X := StrToIntDef(Frm.SpP1x.Text,0);
      P1.Y := StrToIntDef(Frm.SpP1y.Text,0);
      P1.Z := StrToIntDef(Frm.SpP1z.Text,0);
      // P2
      P2.X := StrToIntDef(Frm.SpP2x.Text,0);
      P2.Y := StrToIntDef(Frm.SpP2y.Text,0);
      P2.Z := StrToIntDef(Frm.SpP2z.Text,0);
      // P3
      P3.X := StrToIntDef(Frm.SpP3x.Text,0);
      P3.Y := StrToIntDef(Frm.SpP3y.Text,0);
      P3.Z := StrToIntDef(Frm.SpP3z.Text,0);
      // P4
      P4.X := StrToIntDef(Frm.SpP4x.Text,0);
      P4.Y := StrToIntDef(Frm.SpP4y.Text,0);
      P4.Z := StrToIntDef(Frm.SpP4z.Text,0);

      // Get tangents, starting with T1
      T1.X := StrToFloatDef(Frm.SpT1x.Text,0);
      T1.Y := StrToFloatDef(Frm.SpT1y.Text,0);
      T1.Z := StrToFloatDef(Frm.SpT1z.Text,0);
      // T2
      T2.X := StrToFloatDef(Frm.SpT2x.Text,0);
      T2.Y := StrToFloatDef(Frm.SpT2y.Text,0);
      T2.Z := StrToFloatDef(Frm.SpT2z.Text,0);
      // T3
      T3.X := StrToFloatDef(Frm.SpT3x.Text,0);
      T3.Y := StrToFloatDef(Frm.SpT3y.Text,0);
      T3.Z := StrToFloatDef(Frm.SpT3z.Text,0);
      // T4
      T4.X := StrToFloatDef(Frm.SpT4x.Text,0);
      T4.Y := StrToFloatDef(Frm.SpT4y.Text,0);
      T4.Z := StrToFloatDef(Frm.SpT4z.Text,0);

      Surface(P1,P2,P3,T1,T2,T3,T4);
   end;

   Frm.Release;
end;

procedure TVVFrmMain.MakeGeoUnitwithPrecompiledLighting1Click(
  Sender: TObject);
type
   TGeoMap = array of array of array of Integer;
   TCustomPalette = array of TColor;

   procedure UnpackVoxel(PackedVoxel: TVoxelPacked; var dest: TVoxelUnpacked);
   begin
      dest.Normal := (PackedVoxel and $000000FF);
      dest.Colour := (PackedVoxel and $0000FF00) shr 8;
      dest.Used :=   (PackedVoxel and $00010000) > 0;
      dest.Flags :=  (PackedVoxel and $FF000000) shr 24;
   end;

   function AddColourToPalette(Colour : TColor; var Palette : TCustomPalette): Integer;
   var
      i : integer;
      found : boolean;
   begin
      found := false; // colour wasn't checked yet.
      Result := -1;
      // Check if it has elements
      if High(Palette) > -1 then
      begin
         i := Low(Palette);
         while (i <= High(Palette)) and (not found) do
         begin
            if Palette[i] = Colour then
            begin
               found := true;
               Result := i;
            end;
            inc(i);
         end;
      end;
      // If the colour isn't in the palette, add it.
      if not found then
      begin
         SetLength(Palette,High(Palette)+2);
         Palette[High(Palette)] := Colour;
         Result := High(Palette);
      end;
   end;

// Make BZK Unit Starts here.
var
   Filename : string;
   F : system.Text;
   x,y,z,i : Integer;
   data : smallint;
   Voxel : TVoxelUnpacked;
   Palette : TCustomPalette;
   GeoMap : TGeoMap;
   AvarageNormal : Real;
begin
   if VoxelOpen then
   begin
      Filename := copy(VoxelFile.Filename,1,length(VoxelFile.Filename)-length('.vxl'));
      if MessageBox(Application.Handle,PChar('Building ' + Filename + '.geo. Go ahead?'),'Debug Voxel Bounds',MB_YESNO) = ID_YES then
      begin
         AssignFile(F,Filename + '.geo');
         Rewrite(F);
         // Generate GeoMap.
         SetLength(GeoMap,VoxelFile.Section[0].Tailer.XSize,VoxelFile.Section[0].Tailer.YSize,VoxelFile.Section[0].Tailer.ZSize);
         for x := 0 to VoxelFile.Section[0].Tailer.XSize-1 do
            for y := 0 to VoxelFile.Section[0].Tailer.YSize-1 do
               for z := 0 to VoxelFile.Section[0].Tailer.ZSize-1 do
               begin
                  UnpackVoxel(VoxelFile.Section[0].Data[x,y,z],Voxel);
                  if Voxel.Used then
                  begin
                     if VoxelFile.Section[0].Tailer.Unknown = 4 then
                     begin
                        AvarageNormal := sqrt(((RA2Normals[Voxel.Normal].X * RA2Normals[Voxel.Normal].X) + (RA2Normals[Voxel.Normal].Y * RA2Normals[Voxel.Normal].Y) + (RA2Normals[Voxel.Normal].Z * RA2Normals[Voxel.Normal].Z)) / 3);
                     end
                     else
                     begin
                        AvarageNormal := sqrt(((TSNormals[Voxel.Normal].X * TSNormals[Voxel.Normal].X) + (TSNormals[Voxel.Normal].Y * TSNormals[Voxel.Normal].Y) + (TSNormals[Voxel.Normal].Z * TSNormals[Voxel.Normal].Z)) / 3);
                     end;
                     GeoMap[x,y,z] := AddColourToPalette(RGB(Round(GetRValue(VXLPalette[Voxel.Colour]) * AvarageNormal),Round(GetGValue(VXLPalette[Voxel.Colour]) * AvarageNormal),Round(GetBValue(VXLPalette[Voxel.Colour]) * AvarageNormal)),Palette);
                  end
                  else
                     GeoMap[x,y,z] := -1;
               end;
         // Write number of colours
         writeln(F, IntToStr(High(Palette) + 1) );
         // Write palette colours
         for i := 0 to High(Palette) do
         begin
            writeln(F, IntToStr(GetRValue(Palette[i])));
            writeln(F, IntToStr(GetGValue(Palette[i])));
            writeln(F, IntToStr(GetBValue(Palette[i])));
            writeln(F, '255'); // alpha
         end;
         // Write sector header.
         // section size.
         writeln(F, IntToStr(VoxelFile.Section[0].Tailer.XSize));
         writeln(F, IntToStr(VoxelFile.Section[0].Tailer.YSize));
         writeln(F, IntToStr(VoxelFile.Section[0].Tailer.ZSize));
         // section scales.
         writeln(F, IntToStr(Round((VoxelFile.Section[0].Tailer.MaxBounds[1]-VoxelFile.Section[0].Tailer.MinBounds[1])/VoxelFile.Section[0].Tailer.xSize)));
         writeln(F, IntToStr(Round((VoxelFile.Section[0].Tailer.MaxBounds[2]-VoxelFile.Section[0].Tailer.MinBounds[2])/VoxelFile.Section[0].Tailer.ySize)));
         writeln(F, IntToStr(Round((VoxelFile.Section[0].Tailer.MaxBounds[3]-VoxelFile.Section[0].Tailer.MinBounds[3])/VoxelFile.Section[0].Tailer.zSize)));
         // Print each matrix.
         for z := 0 to VoxelFile.Section[0].Tailer.ZSize-1 do
         begin
            writeln(F,IntToStr(z));
            for y := 0 to VoxelFile.Section[0].Tailer.YSize-1 do
            begin
               // Write the first byte
               Write(F,IntToStr(GeoMap[0,y,z]));
               if VoxelFile.Section[0].Tailer.XSize > 1 then
               begin
                  Write(F,' ');
                  // Write middle stuff
                  for x := 1 to VoxelFile.Section[0].Tailer.XSize-2 do
                  begin
                     Write(F,IntToStr(GeoMap[x,y,z]) + ' ');
                  end;
                  // Write the last element.
                  Writeln(F,IntToStr(GeoMap[VoxelFile.Section[0].Tailer.XSize-1,y,z]));
               end;
            end;
         end;
         CloseFile(F);
         ShowMessage('Geo Unit Saved Successfully at ' + Filename + '.geo');
      end;
   end;
end;

procedure TVVFrmMain.OGLSizeChange(Sender: TObject);
begin
 if AutoSizeCheck.Checked then exit;

 MainView.Width  := OGLSize.Value;
 MainView.Height := OGLSize.Value;
end;

procedure TVVFrmMain.AutoSizeCheckClick(Sender: TObject);
begin
 if AutoSizeCheck.Checked then
 MainView.Align := alClient
 else
 begin
  MainView.Align  := alNone;
  MainView.Width  := OGLSize.Value;
  MainView.Height := OGLSize.Value;
 end;

 FUpdateWorld := True;
end;

procedure TVVFrmMain.Timer1Timer(Sender: TObject);
begin
   FUpdateWorld := True;
end;

procedure TVVFrmMain.UnitCountComboChange(Sender: TObject);
begin
 Case UnitCountCombo.ItemIndex of
  0 : UnitCount := 1;
  1 : UnitCount := 4;
  2 : UnitCount := 8;
 end;
end;

procedure TVVFrmMain.UnitSpaceEditChange(Sender: TObject);
begin
   If VVSLoading then exit;

   if (UnitSpaceEdit.Text <> '') then
      try
         UnitSpace := UnitSpaceEdit.Value;
      except
      end;
   FUpdateWorld := True;
end;

end.
