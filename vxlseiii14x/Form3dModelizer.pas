unit Form3dModelizer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, {model,} dglOpenGL, {Textures,} Menus, voxel, Spin,
  Buttons, FTGifAnimate, GIFImage,Palette,BasicDataTypes, Voxel_Engine, Normals,
  HVA,JPEG,PNGImage, math3d, RenderEnvironment, Render, Actor, Camera, GlConstants,
  BasicFunctions, FormOptimizeMesh, FormGenerateDiffuseTexture, FormBumpMapping;

type
  PFrm3DModelizer = ^TFrm3DModelizer;
  TFrm3DModelizer = class(TForm)
    Panel2: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Options1: TMenuItem;
    BackgroundColour1: TMenuItem;
    ColorDialog1: TColorDialog;
    Panel1: TPanel;
    btn3DRotateX2: TSpeedButton;
    btn3DRotateY2: TSpeedButton;
    btn3DRotateY: TSpeedButton;
    spin3Djmp: TSpinEdit;
    Bevel1: TBevel;
    FontColor1: TMenuItem;
    Popup3d: TPopupMenu;
    Views1: TMenuItem;
    Front1: TMenuItem;
    Back1: TMenuItem;
    N1: TMenuItem;
    LEft1: TMenuItem;
    Right1: TMenuItem;
    N2: TMenuItem;
    Bottom1: TMenuItem;
    op1: TMenuItem;
    N3: TMenuItem;
    Cameo1: TMenuItem;
    SpeedButton1: TSpeedButton;
    Cameo21: TMenuItem;
    Cameo31: TMenuItem;
    Cameo41: TMenuItem;
    ools1: TMenuItem;
    akeScreenshot1: TMenuItem;
    ake360DegScreenshots1: TMenuItem;
    RemapColour1: TMenuItem;
    Red1: TMenuItem;
    Blue1: TMenuItem;
    Green1: TMenuItem;
    White1: TMenuItem;
    Orange1: TMenuItem;
    Magenta1: TMenuItem;
    Purple1: TMenuItem;
    Gold1: TMenuItem;
    DarkSky1: TMenuItem;
    SpeedButton2: TSpeedButton;
    btn3DRotateX: TSpeedButton;
    akeScreenshotJPG1: TMenuItem;
    akeScreenshotPNG1: TMenuItem;
    akeScreenshotBMP1: TMenuItem;
    Display1: TMenuItem;
    CurrentSectionOnly1: TMenuItem;
    WholeVoxel1: TMenuItem;
    SpPlay: TSpeedButton;
    SpStop: TSpeedButton;
    Label1: TLabel;
    SpFrame: TSpinEdit;
    AnimationTimer: TTimer;
    Anim360Timer: TTimer;
    RenderQuality1: TMenuItem;
    RenderCubes: TMenuItem;
    RenderModel: TMenuItem;
    ModelEffects1: TMenuItem;
    ModelFXSmooth: TMenuItem;
    ModelFXUnsharp: TMenuItem;
    ModelFXHeavySmooth: TMenuItem;
    ModelFXDeflate: TMenuItem;
    ModelFXInflate: TMenuItem;
    NormalFXNormalize: TMenuItem;
    ModelFXLanczos: TMenuItem;
    SaveModelAs: TMenuItem;
    N4: TMenuItem;
    SaveModelDialog: TSaveDialog;
    RenderQuads: TMenuItem;
    FaceFXCleanupInvisibleFaces: TMenuItem;
    FaceFXConvertQuadstoTriangles: TMenuItem;
    ColourEffects1: TMenuItem;
    ColourFXSmooth: TMenuItem;
    ColourFXHeavySmooth: TMenuItem;
    NormalEffects1: TMenuItem;
    NormalsFXConvertFaceToVertexNormals: TMenuItem;
    RenderTriangles: TMenuItem;
    LanczosDilatation1: TMenuItem;
    ColourFXConvertFaceToVertexS: TMenuItem;
    ColourFXConvertFaceToVertexHS: TMenuItem;
    ColourFXConvertFaceToVertexLS: TMenuItem;
    ColourFXConvertVertexToFace: TMenuItem;
    FaceSetup1: TMenuItem;
    ModelFXSincErosion: TMenuItem;
    ModelFXEulerErosion: TMenuItem;
    ModelFXHeavyEulerErosion: TMenuItem;
    ModelFXSincInfiniteErosion: TMenuItem;
    NormalsFXQuickSmoothNormals: TMenuItem;
    NormalsFXSmoothNormals: TMenuItem;
    NormalsFXCubicSmoothNormals: TMenuItem;
    NormalsFXLanczosSmoothNormals: TMenuItem;
    FaceFXOptimizeMesh: TMenuItem;
    FaceFXOptimizeMeshIgnoringColours: TMenuItem;
    ModelFXGaussianSmooth: TMenuItem;
    RenderVisibleCubes: TMenuItem;
    ColourFXConvertFacetoVertex: TMenuItem;
    FaceFXOptimizeMeshCustom: TMenuItem;
    ModelFXSquaredSmooth: TMenuItem;
    akeScreenshotDDS1: TMenuItem;
    TextureEffects1: TMenuItem;
    TextureFXDiffuse: TMenuItem;
    N5: TMenuItem;
    TextureFSExport: TMenuItem;
    N6: TMenuItem;
    extureFileType1: TMenuItem;
    TextureFSFTDDS: TMenuItem;
    TextureFSFTTGA: TMenuItem;
    TextureFSFTJPG: TMenuItem;
    TextureFSFTBMP: TMenuItem;
    TextureFXDiffuseCustom: TMenuItem;
    N7: TMenuItem;
    CameraRotationAngles1: TMenuItem;
    Render4Triangles: TMenuItem;
    EnableShaders1: TMenuItem;
    RenderVisibleTriangles: TMenuItem;
    FillMode1: TMenuItem;
    DisplayFMSolid: TMenuItem;
    DisplayFMWireframe: TMenuItem;
    DisplayFMPointCloud: TMenuItem;
    DisplayNormalVectors1: TMenuItem;
    EnableBackFaceCuling1: TMenuItem;
    TextureFXNormal: TMenuItem;
    TextureFXBump: TMenuItem;
    extureSize1: TMenuItem;
    TextureFXSize4096: TMenuItem;
    TextureFXSize2048: TMenuItem;
    TextureFXSize1024: TMenuItem;
    TextureFXSize512: TMenuItem;
    TextureFXSize256: TMenuItem;
    TextureFXSize128: TMenuItem;
    TextureFXSize64: TMenuItem;
    TextureFXSize32: TMenuItem;
    TextureFXNumMipMaps: TMenuItem;
    TextureFX10MipMaps: TMenuItem;
    TextureFX9MipMaps: TMenuItem;
    TextureFX8MipMaps: TMenuItem;
    TextureFX7MipMaps: TMenuItem;
    TextureFX6MipMaps: TMenuItem;
    TextureFX5MipMaps: TMenuItem;
    TextureFX4MipMaps: TMenuItem;
    TextureFX3MipMaps: TMenuItem;
    TextureFX2MipMaps: TMenuItem;
    TextureFX1MipMaps: TMenuItem;
    TextureFSExportHeightMap: TMenuItem;
    TextureFXBumpCustom: TMenuItem;
    RenderManifolds: TMenuItem;
    procedure RenderManifoldsClick(Sender: TObject);
    procedure TextureFXBumpCustomClick(Sender: TObject);
    procedure TextureFSExportHeightMapClick(Sender: TObject);
    procedure TextureFX1MipMapsClick(Sender: TObject);
    procedure TextureFX2MipMapsClick(Sender: TObject);
    procedure TextureFX3MipMapsClick(Sender: TObject);
    procedure TextureFX4MipMapsClick(Sender: TObject);
    procedure TextureFX5MipMapsClick(Sender: TObject);
    procedure TextureFX6MipMapsClick(Sender: TObject);
    procedure TextureFX7MipMapsClick(Sender: TObject);
    procedure TextureFX8MipMapsClick(Sender: TObject);
    procedure TextureFX9MipMapsClick(Sender: TObject);
    procedure TextureFX10MipMapsClick(Sender: TObject);
    procedure TextureFXSize32Click(Sender: TObject);
    procedure TextureFXSize64Click(Sender: TObject);
    procedure TextureFXSize128Click(Sender: TObject);
    procedure TextureFXSize256Click(Sender: TObject);
    procedure TextureFXSize512Click(Sender: TObject);
    procedure TextureFXSize1024Click(Sender: TObject);
    procedure TextureFXSize2048Click(Sender: TObject);
    procedure TextureFXSize4096Click(Sender: TObject);
    procedure TextureFXBumpClick(Sender: TObject);
    procedure TextureFXNormalClick(Sender: TObject);
    procedure EnableBackFaceCuling1Click(Sender: TObject);
    procedure DisplayNormalVectors1Click(Sender: TObject);
    procedure DisplayFMPointCloudClick(Sender: TObject);
    procedure DisplayFMWireframeClick(Sender: TObject);
    procedure DisplayFMSolidClick(Sender: TObject);
    procedure RenderVisibleTrianglesClick(Sender: TObject);
    procedure EnableShaders1Click(Sender: TObject);
    procedure CameraRotationAngles1Click(Sender: TObject);
    procedure TextureFXDiffuseCustomClick(Sender: TObject);
    procedure TextureFSFTBMPClick(Sender: TObject);
    procedure TextureFSFTJPGClick(Sender: TObject);
    procedure TextureFSFTTGAClick(Sender: TObject);
    procedure TextureFSFTDDSClick(Sender: TObject);
    procedure TextureFSExportClick(Sender: TObject);
    procedure TextureFXDiffuseClick(Sender: TObject);
    procedure akeScreenshotDDS1Click(Sender: TObject);
    procedure ModelFXSquaredSmoothClick(Sender: TObject);
    procedure FaceFXOptimizeMeshCustomClick(Sender: TObject);
    procedure ColourFXConvertFacetoVertexClick(Sender: TObject);
    procedure RenderVisibleCubesClick(Sender: TObject);
    procedure ModelFXGaussianSmoothClick(Sender: TObject);
    procedure FaceFXOptimizeMeshIgnoringColoursClick(Sender: TObject);
    procedure FaceFXOptimizeMeshClick(Sender: TObject);
    procedure NormalsFXLanczosSmoothNormalsClick(Sender: TObject);
    procedure NormalsFXCubicSmoothNormalsClick(Sender: TObject);
    procedure NormalsFXSmoothNormalsClick(Sender: TObject);
    procedure NormalsFXQuickSmoothNormalsClick(Sender: TObject);
    procedure ModelFXSincInfiniteErosionClick(Sender: TObject);
    procedure ModelFXHeavyEulerErosionClick(Sender: TObject);
    procedure ModelFXEulerErosionClick(Sender: TObject);
    procedure ModelFXSincErosionClick(Sender: TObject);
    procedure ColourFXConvertVertexToFaceClick(Sender: TObject);
    procedure ColourFXConvertFaceToVertexLSClick(Sender: TObject);
    procedure ColourFXConvertFaceToVertexHSClick(Sender: TObject);
    procedure ColourFXConvertFaceToVertexSClick(Sender: TObject);
    procedure LanczosDilatation1Click(Sender: TObject);
    procedure RenderTrianglesClick(Sender: TObject);
    procedure NormalsFXConvertFaceToVertexNormalsClick(Sender: TObject);
    procedure ColourFXHeavySmoothClick(Sender: TObject);
    procedure ColourFXSmoothClick(Sender: TObject);
    procedure FaceFXConvertQuadstoTrianglesClick(Sender: TObject);
    procedure FaceFXCleanupInvisibleFacesClick(Sender: TObject);
    procedure RenderQuadsClick(Sender: TObject);
    procedure SaveModelAsClick(Sender: TObject);
    procedure ModelFXLanczosClick(Sender: TObject);
    procedure NormalFXNormalizeClick(Sender: TObject);
    procedure ModelFXInflateClick(Sender: TObject);
    procedure ModelFXDeflateClick(Sender: TObject);
    procedure ModelFXHeavySmoothClick(Sender: TObject);
    procedure ModelFXUnsharpClick(Sender: TObject);
    procedure ModelFXSmoothClick(Sender: TObject);
    procedure RenderModelClick(Sender: TObject);
    procedure RenderCubesClick(Sender: TObject);
    procedure Anim360TimerTimer(Sender: TObject);
    procedure AnimationTimerTimer(Sender: TObject);
    procedure SpPlayClick(Sender: TObject);
    procedure SpStopClick(Sender: TObject);
    procedure SpFrameChange(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CurrentSectionOnly1Click(Sender: TObject);
    procedure akeScreenshotBMP1Click(Sender: TObject);
    procedure akeScreenshotPNG1Click(Sender: TObject);
    procedure akeScreenshotJPG1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Exit1Click(Sender: TObject);
    procedure BackgroundColour1Click(Sender: TObject);
    procedure btn3DRotateX2Click(Sender: TObject);
    procedure btn3DRotateXClick(Sender: TObject);
    procedure btn3DRotateY2Click(Sender: TObject);
    procedure btn3DRotateYClick(Sender: TObject);
    procedure spin3DjmpChange(Sender: TObject);
    procedure FontColor1Click(Sender: TObject);
    procedure Front1Click(Sender: TObject);
    procedure Back1Click(Sender: TObject);
    procedure LEft1Click(Sender: TObject);
    procedure Right1Click(Sender: TObject);
    procedure Bottom1Click(Sender: TObject);
    procedure op1Click(Sender: TObject);
    procedure Cameo1Click(Sender: TObject);
    procedure SpeedButton1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Cameo21Click(Sender: TObject);
    procedure Cameo31Click(Sender: TObject);
    procedure Cameo41Click(Sender: TObject);
    procedure ake360DegScreenshots1Click(Sender: TObject);
    procedure akeScreenshot1Click(Sender: TObject);
    procedure Red1Click(Sender: TObject);
    procedure Blue1Click(Sender: TObject);
    procedure Green1Click(Sender: TObject);
    procedure White1Click(Sender: TObject);
    procedure Orange1Click(Sender: TObject);
    procedure Magenta1Click(Sender: TObject);
    procedure Purple1Click(Sender: TObject);
    procedure Gold1Click(Sender: TObject);
    procedure DarkSky1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Render4TrianglesClick(Sender: TObject);
  private
    { Private declarations }
    RemapColour : TVector3f;
    Xcoord, Ycoord, Zcoord : Integer;
    MouseButton : Integer;
    // These are for Take 360 Animation
    btn3DRotateY_d, btn3DRotateY2_d, btn3DRotateX_d, btn3DRotateX2_d : boolean;
    procedure ClearRemapClicks;
    procedure UncheckModelQuality;
    procedure UncheckFillMode;
    procedure UncheckTextureSize;
    procedure UncheckNumMipMaps;
  public
    { Public declarations }
    AnimationState : boolean;
    EnvP : PRenderEnvironment;
    Env : TRenderEnvironment;
    Actor : TActor;
    Camera : TCamera;
    TextureFileExt: string;
    MeshMode,NormalsMode,ColoursMode: integer;
    TextureSize,NumMipMaps: integer;
    Procedure SetRotationAdders;
    procedure SetActorModelTransparency;
    Procedure Reset3DView;
    function GetQualityModel: integer;
    procedure UpdateQualityUI;
    procedure SetMeshMode(_MeshMode : integer);
    procedure SetNormalsMode(_NormalsMode : integer);
    procedure SetColoursMode(_ColoursMode : integer);
  end;

implementation

uses FormMain, GlobalVars;

{$R *.DFM}

{------------------------------------------------------------------}
procedure TFrm3DModelizer.FormCreate(Sender: TObject);
begin
   // OpenGL initialization
   EnvP := GlobalVars.Render.AddEnvironment(Panel2.Handle,Panel2.Width,Panel2.Height);
   Env := EnvP^;
   Env.BackgroundColour := SetVector(140/255,170/255,235/255);
   Env.FontColour := SetVector(1,1,1);
   Camera := Env.CurrentCamera^;
   EnableShaders1.Checked := Env.IsShaderEnabled;

   RemapColour.X := RemapColourMap[0].R /255;
   RemapColour.Y := RemapColourMap[0].G /255;
   RemapColour.Z := RemapColourMap[0].B /255;

   SpFrame.Value := 1;
   SpFrame.MaxValue := FrmMain.Document.ActiveHVA^.Header.N_Frames;
   AnimationTimer.Enabled := false;

   Actor := (Env.AddActor)^;
   Actor.Clone(FrmMain.Document.ActiveVoxel,FrmMain.Document.ActiveHVA,FrmMain.Document.Palette,GetQualityModel);
   Actor.Models[0].MakeVoxelHVAIndependent;
   SetActorModelTransparency;
   TextureFSFTDDSClick(sender);
   SetMeshMode(1);
   SetNormalsMode(1);
   SetColoursMode(1);
   TextureSize := 1024;
   NumMipMaps := 9;
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}

{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DModelizer.FormResize(Sender: TObject);
begin
   if width < 330 then
      Width := 330;
   Env.Resize(Panel2.Width,Panel2.Height);
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DModelizer.FormDestroy(Sender: TObject);
begin
   GlobalVars.Render.RemoveEnvironment(EnvP);
   FrmMain.p_Frm3DModelizer := nil;
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DModelizer.Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   if MouseButton = 1 then
   begin
      Camera.SetRotation(Camera.Rotation.X + (Y - Ycoord)/2,Camera.Rotation.Y + (X - Xcoord)/2,Camera.Rotation.Z);
      Xcoord := X;
      Ycoord := Y;
   end;
   if MouseButton = 2 then
   begin
      Camera.SetPosition(Camera.Position.X,Camera.Position.Y,Camera.Position.Z - (Y-ZCoord)/3);
      Zcoord := Y;
   end;
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DModelizer.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbLeft  then
   begin
      MouseButton :=1;
      Xcoord := X;
      Ycoord := Y;
   end;
   if Button = mbRight then
   begin
      MouseButton :=2;
      Zcoord := Y;
   end;
end;

procedure TFrm3DModelizer.Panel2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   MouseButton :=0;
end;

procedure TFrm3DModelizer.EnableBackFaceCuling1Click(Sender: TObject);
begin
   EnableBackFaceCuling1.Checked := not EnableBackFaceCuling1.Checked;
   Env.EnableBackFaceCulling(EnableBackFaceCuling1.Checked);
end;

procedure TFrm3DModelizer.EnableShaders1Click(Sender: TObject);
begin
   Env.EnableShaders(not EnableShaders1.Checked);
   EnableShaders1.Checked := Env.IsShaderEnabled;
end;

procedure TFrm3DModelizer.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TFrm3DModelizer.TextureFSExportHeightMapClick(Sender: TObject);
begin
   Actor.ExportHeightmap(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))),TextureFileExt,true);
end;

procedure TFrm3DModelizer.TextureFSExportClick(Sender: TObject);
begin
   // Export every single texture...
   Actor.ExportTextures(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))),TextureFileExt,true);
end;

procedure TFrm3DModelizer.TextureFSFTBMPClick(Sender: TObject);
begin
   TextureFSFTDDS.Checked := false;
   TextureFSFTTGA.Checked := false;
   TextureFSFTJPG.Checked := false;
   TextureFSFTBMP.Checked := true;
   TextureFileExt := 'bmp';
end;

procedure TFrm3DModelizer.TextureFSFTDDSClick(Sender: TObject);
begin
   TextureFSFTDDS.Checked := true;
   TextureFSFTTGA.Checked := false;
   TextureFSFTJPG.Checked := false;
   TextureFSFTBMP.Checked := false;
   TextureFileExt := 'dds';
end;

procedure TFrm3DModelizer.TextureFSFTJPGClick(Sender: TObject);
begin
   TextureFSFTDDS.Checked := false;
   TextureFSFTTGA.Checked := false;
   TextureFSFTJPG.Checked := true;
   TextureFSFTBMP.Checked := false;
   TextureFileExt := 'jpg';
end;

procedure TFrm3DModelizer.TextureFSFTTGAClick(Sender: TObject);
begin
   TextureFSFTDDS.Checked := false;
   TextureFSFTTGA.Checked := true;
   TextureFSFTJPG.Checked := false;
   TextureFSFTBMP.Checked := false;
   TextureFileExt := 'tga';
end;

procedure TFrm3DModelizer.BackgroundColour1Click(Sender: TObject);
begin
   ColorDialog1.Color := TVector3fToTColor(Env.BackgroundColour);
   if ColorDialog1.Execute then
      Env.SetBackgroundColour(TColorToTVector3f(ColorDialog1.Color));
end;

Procedure TFrm3DModelizer.SetRotationAdders;
var
   V : single;
begin
   try
      V := spin3Djmp.Value / 10;
   except
      exit; // Not a value
   end;

   if btn3DRotateX2.Down then
      Camera.SetRotationSpeed(-V,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z)
   else if btn3DRotateX.Down then
      Camera.SetRotationSpeed(V,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z)
   else
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);

   if btn3DRotateY2.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,V,Camera.RotationSpeed.Z)
   else if btn3DRotateY.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,-V,Camera.RotationSpeed.Z)
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,0,Camera.RotationSpeed.Z);
end;

procedure TFrm3DModelizer.btn3DRotateX2Click(Sender: TObject);
begin
   if btn3DRotateX2.Down then
   begin
      SetRotationAdders;
   end
   else
   begin
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);
   end;
end;

procedure TFrm3DModelizer.btn3DRotateXClick(Sender: TObject);
begin
   if btn3DRotateX.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);
end;

procedure TFrm3DModelizer.btn3DRotateY2Click(Sender: TObject);
begin
   if btn3DRotateY2.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,0,Camera.RotationSpeed.Z);
end;

procedure TFrm3DModelizer.btn3DRotateYClick(Sender: TObject);
begin
   if btn3DRotateY.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,0,Camera.RotationSpeed.Z);
end;

procedure TFrm3DModelizer.spin3DjmpChange(Sender: TObject);
begin
   SetRotationAdders;
end;

procedure TFrm3DModelizer.SpPlayClick(Sender: TObject);
begin
   // Enable timer here.
   if not AnimationTimer.Enabled then
   begin
      SpPlay.Glyph.LoadFromFile(ExtractFileDir(ParamStr(0)) + '/images/pause.bmp');
      AnimationTimer.Enabled := true;
   end
   else
   begin
      AnimationTimer.Enabled := false;
      SpPlay.Glyph.LoadFromFile(ExtractFileDir(ParamStr(0)) + '/images/play.bmp');
   end;
end;

procedure TFrm3DModelizer.SpStopClick(Sender: TObject);
begin
   AnimationTimer.Enabled := false;
   Actor.Frame := 0;
   Env.ForceRefresh;
   SpFrame.Value := 1;
   SpPlay.Glyph.LoadFromFile(ExtractFileDir(ParamStr(0)) + '/images/play.bmp');
end;

procedure TFrm3DModelizer.TextureFXDiffuseClick(Sender: TObject);
begin
   Actor.GenerateDiffuseTexture;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
   SetColoursMode(2);
end;

procedure TFrm3DModelizer.TextureFXDiffuseCustomClick(Sender: TObject);
var
   Frm : TFrmGenerateDiffuseTexture;
begin
   Frm := TFrmGenerateDiffuseTexture.Create(self);
   Frm.ShowModal;
   if Frm.Apply then
   begin
      Actor.GenerateDiffuseTexture(Frm.Threshold,TextureSize);
      Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
      SetColoursMode(2);
   end;
   Frm.Release;
end;

procedure TFrm3DModelizer.ModelFXSquaredSmoothClick(Sender: TObject);
begin
   Actor.QuadricSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXUnsharpClick(Sender: TObject);
begin
   Actor.UnsharpModel;
end;

procedure TFrm3DModelizer.AnimationTimerTimer(Sender: TObject);
begin
   if FrmMain.Document.ActiveHVA^.Header.N_Frames = 1 then
   begin
      SpStopClick(Sender);
   end
   else
   begin
      Actor.Frame := (Actor.Frame + 1) mod SpFrame.MaxValue;
      Env.ForceRefresh;
      SpFrame.Value := Actor.Frame + 1;
   end;
end;

procedure TFrm3DModelizer.SpFrameChange(Sender: TObject);
begin
   if StrToIntDef(SpFrame.Text,-1) <> -1 then
   begin
      if SpFrame.Value > SpFrame.MaxValue then
         SpFrame.Value := 1
      else if SpFrame.Value < 1 then
         SpFrame.Value := SpFrame.MaxValue;
      Actor.Frame := SpFrame.Value-1;
      Env.ForceRefresh;
   end;
end;

procedure TFrm3DModelizer.FontColor1Click(Sender: TObject);
begin
   ColorDialog1.Color := TVector3fToTColor(Env.FontColour);
   if ColorDialog1.Execute then
      Env.SetFontColour(TColorToTVector3f(ColorDialog1.Color));
end;

procedure TFrm3DModelizer.Front1Click(Sender: TObject);
begin
   Camera.SetRotation(0,0,0);
end;

procedure TFrm3DModelizer.Back1Click(Sender: TObject);
begin
   Camera.SetRotation(0,180,0);
end;

procedure TFrm3DModelizer.ModelFXLanczosClick(Sender: TObject);
begin
   Actor.LanczosSmoothModel;
end;

procedure TFrm3DModelizer.LanczosDilatation1Click(Sender: TObject);
begin
   Actor.ColourLanczosSmoothModel;
end;

procedure TFrm3DModelizer.LEft1Click(Sender: TObject);
begin
   Camera.SetRotation(0,-90,0);
end;

procedure TFrm3DModelizer.Right1Click(Sender: TObject);
begin
   Camera.SetRotation(0,90,0);
end;

procedure TFrm3DModelizer.Bottom1Click(Sender: TObject);
begin
   Camera.SetRotation(90,-90,180);
end;

procedure TFrm3DModelizer.op1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,90,180);
end;

procedure TFrm3DModelizer.Cameo1Click(Sender: TObject);
begin
   Camera.SetRotation(17,315,0);
end;

procedure TFrm3DModelizer.SpeedButton1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Popup3d.Popup(Left+SpeedButton1.Left+5,Top+ 60+ SpeedButton1.Top);
end;

procedure TFrm3DModelizer.Cameo21Click(Sender: TObject);
begin
   Camera.SetRotation(17,45,0);
end;

procedure TFrm3DModelizer.Cameo31Click(Sender: TObject);
begin
   Camera.SetRotation(17,345,0);
end;

procedure TFrm3DModelizer.Cameo41Click(Sender: TObject);
begin
   Camera.SetRotation(17,15,0);
end;

procedure TFrm3DModelizer.ake360DegScreenshots1Click(Sender: TObject);
begin
   Env.Take360Animation(VXLFilename,90,10,stGif);

   btn3DRotateY_d := btn3DRotateY.Down;
   btn3DRotateY2_d := btn3DRotateY2.Down;
   btn3DRotateX_d := btn3DRotateX.Down;
   btn3DRotateX2_d := btn3DRotateX2.Down;
   btn3DRotateY.Down := false;
   btn3DRotateY2.Down := false;
   btn3DRotateX.Down := false;
   btn3DRotateX2.Down := false;
   btn3DRotateY.Enabled := false;
   btn3DRotateY2.Enabled := false;
   btn3DRotateX.Enabled := false;
   btn3DRotateX2.Enabled := false;
   spin3Djmp.Enabled := false;
   SpeedButton1.Enabled := false;
   SpeedButton2.Enabled := false;
   Anim360Timer.Enabled := true;
end;

procedure TFrm3DModelizer.Anim360TimerTimer(Sender: TObject);
begin
   if not Env.IsScreenshoting then
   begin
      btn3DRotateY.Down := btn3DRotateY_d;
      btn3DRotateY2.Down := btn3DRotateY2_d;
      btn3DRotateX.Down := btn3DRotateX_d;
      btn3DRotateX2.Down := btn3DRotateX2_d;
      btn3DRotateY.Enabled := true;
      btn3DRotateY2.Enabled := true;
      btn3DRotateX.Enabled := true;
      btn3DRotateX2.Enabled := true;
      spin3Djmp.Enabled := true;
      SpeedButton1.Enabled := true;
      SpeedButton2.Enabled := true;
      Anim360Timer.Enabled := false;
   end;
end;


procedure TFrm3DModelizer.akeScreenshot1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stTGA);
end;

procedure TFrm3DModelizer.akeScreenshotBMP1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stBMP);
end;

procedure TFrm3DModelizer.akeScreenshotDDS1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stDDS);
end;

procedure TFrm3DModelizer.akeScreenshotJPG1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stJPG);
end;

procedure TFrm3DModelizer.akeScreenshotPNG1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stPNG);
end;

procedure TFrm3DModelizer.ClearRemapClicks;
begin
   Red1.Checked := false;
   Blue1.Checked := false;
   Green1.Checked := false;
   White1.Checked := false;
   Orange1.Checked := false;
   Magenta1.Checked := false;
   Purple1.Checked := false;
   Gold1.Checked := false;
   DarkSky1.Checked := false;
end;

procedure TFrm3DModelizer.ColourFXConvertFacetoVertexClick(
  Sender: TObject);
begin
   Actor.ConvertFaceToVertexColours;
   SetColoursMode(1);
end;

procedure TFrm3DModelizer.ColourFXConvertFaceToVertexHSClick(Sender: TObject);
begin
   Actor.ConvertFaceToVertexColoursCubic;
   SetColoursMode(1);
end;

procedure TFrm3DModelizer.ColourFXConvertFaceToVertexLSClick(Sender: TObject);
begin
   Actor.ConvertFaceToVertexColoursLanczos;
   SetColoursMode(1);
end;

procedure TFrm3DModelizer.ColourFXConvertFaceToVertexSClick(Sender: TObject);
begin
   Actor.ConvertFaceToVertexColoursLinear;
   SetColoursMode(1);
end;

procedure TFrm3DModelizer.ColourFXConvertVertexToFaceClick(Sender: TObject);
begin
   Actor.ConvertVertexToFaceColours;
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.ColourFXHeavySmoothClick(Sender: TObject);
begin
   Actor.ColourCubicSmoothModel
end;

procedure TFrm3DModelizer.ColourFXSmoothClick(Sender: TObject);
begin
   Actor.ColourSmoothModel;
end;

procedure TFrm3DModelizer.Red1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Red1.Checked := true;
   RemapColour.X := RemapColourMap[0].R /255;
   RemapColour.Y := RemapColourMap[0].G /255;
   RemapColour.Z := RemapColourMap[0].B /255;
   Actor.ChangeRemappable(RemapColourMap[0].R,RemapColourMap[0].G,RemapColourMap[0].B);
end;

procedure TFrm3DModelizer.Render4TrianglesClick(Sender: TObject);
begin
   UncheckModelQuality;
   Render4Triangles.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(1);
   SetNormalsMode(1);
   SetColoursMode(1);
end;

procedure TFrm3DModelizer.RenderCubesClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderCubes.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(0);
   SetNormalsMode(0);
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.RenderManifoldsClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderManifolds.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(1);
   SetNormalsMode(0);
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.RenderModelClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderModel.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(1);
   SetNormalsMode(0);
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.RenderQuadsClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderQuads.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(0);
   SetNormalsMode(0);
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.RenderTrianglesClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderTriangles.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(1);
   SetNormalsMode(1);
   SetColoursMode(1);
end;

procedure TFrm3DModelizer.RenderVisibleCubesClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderVisibleCubes.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(0);
   SetNormalsMode(0);
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.RenderVisibleTrianglesClick(Sender: TObject);
begin
   UncheckModelQuality;
   RenderVisibleTriangles.Checked := true;
   Actor.SetQuality(GetQualityModel);
   SetMeshMode(1);
   SetNormalsMode(0);
   SetColoursMode(0);
end;

procedure TFrm3DModelizer.Blue1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Blue1.Checked := true;
   RemapColour.X := RemapColourMap[1].R /255;
   RemapColour.Y := RemapColourMap[1].G /255;
   RemapColour.Z := RemapColourMap[1].B /255;
   Actor.ChangeRemappable(RemapColourMap[1].R,RemapColourMap[1].G,RemapColourMap[1].B);
end;

procedure TFrm3DModelizer.Green1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Green1.Checked := true;
   RemapColour.X := RemapColourMap[2].R /255;
   RemapColour.Y := RemapColourMap[2].G /255;
   RemapColour.Z := RemapColourMap[2].B /255;
   Actor.ChangeRemappable(RemapColourMap[2].R,RemapColourMap[2].G,RemapColourMap[2].B);
end;

procedure TFrm3DModelizer.White1Click(Sender: TObject);
begin
   ClearRemapClicks;
   White1.Checked := true;
   RemapColour.X := RemapColourMap[3].R /255;
   RemapColour.Y := RemapColourMap[3].G /255;
   RemapColour.Z := RemapColourMap[3].B /255;
   Actor.ChangeRemappable(RemapColourMap[3].R,RemapColourMap[3].G,RemapColourMap[3].B);
end;

procedure TFrm3DModelizer.FaceFXOptimizeMeshClick(Sender: TObject);
begin
   Actor.OptimizeMeshMaxQuality;
   SetMeshMode(2);
end;

procedure TFrm3DModelizer.FaceFXOptimizeMeshCustomClick(Sender: TObject);
var
   FrmOptimizeMesh: TFrmOptimizeMesh;
begin
   FrmOptimizeMesh := TFrmOptimizeMesh.Create(self);
   FrmOptimizeMesh.ShowModal;
   if FrmOptimizeMesh.Apply then
   begin
      Actor.OptimizeMesh(FrmOptimizeMesh.Threshold,FrmOptimizeMesh.cbIgnoreColours.Checked);
      SetMeshMode(2);
   end;
   FrmOptimizeMesh.Release;
end;

procedure TFrm3DModelizer.FaceFXOptimizeMeshIgnoringColoursClick(
  Sender: TObject);
begin
   Actor.OptimizeMeshMaxQualityIgnoreColours;
   SetMeshMode(2);
end;

procedure TFrm3DModelizer.Orange1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Orange1.Checked := true;
   RemapColour.X := RemapColourMap[4].R /255;
   RemapColour.Y := RemapColourMap[4].G /255;
   RemapColour.Z := RemapColourMap[4].B /255;
   Actor.ChangeRemappable(RemapColourMap[4].R,RemapColourMap[4].G,RemapColourMap[4].B);
end;

procedure TFrm3DModelizer.Magenta1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Magenta1.Checked := true;
   RemapColour.X := RemapColourMap[5].R /255;
   RemapColour.Y := RemapColourMap[5].G /255;
   RemapColour.Z := RemapColourMap[5].B /255;
   Actor.ChangeRemappable(RemapColourMap[5].R,RemapColourMap[5].G,RemapColourMap[5].B);
end;

procedure TFrm3DModelizer.ModelFXHeavyEulerErosionClick(Sender: TObject);
begin
   Actor.EulerSquaredSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXHeavySmoothClick(Sender: TObject);
begin
   Actor.CubicSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXInflateClick(Sender: TObject);
begin
   Actor.InflateModel;
end;

procedure TFrm3DModelizer.NormalFXNormalizeClick(Sender: TObject);
begin
   Actor.ReNormalizeModel;
end;

procedure TFrm3DModelizer.NormalsFXConvertFaceToVertexNormalsClick(
  Sender: TObject);
begin
   Actor.ConvertFaceToVertexNormals;
   SetNormalsMode(1);
end;

procedure TFrm3DModelizer.NormalsFXCubicSmoothNormalsClick(Sender: TObject);
begin
   Actor.NormalCubicSmoothModel;
end;

procedure TFrm3DModelizer.NormalsFXLanczosSmoothNormalsClick(Sender: TObject);
begin
   Actor.NormalLanczosSmoothModel;
end;

procedure TFrm3DModelizer.NormalsFXQuickSmoothNormalsClick(Sender: TObject);
begin
   Actor.NormalSmoothModel;
end;

procedure TFrm3DModelizer.NormalsFXSmoothNormalsClick(Sender: TObject);
begin
   Actor.NormalLinearSmoothModel;
end;

procedure TFrm3DModelizer.FaceFXCleanupInvisibleFacesClick(Sender: TObject);
begin
   Actor.RemoveInvisibleFaces;
end;

procedure TFrm3DModelizer.FaceFXConvertQuadstoTrianglesClick(Sender: TObject);
begin
   Actor.ConvertQuadsToTris;
   SetMeshMode(1);
end;

procedure TFrm3DModelizer.ModelFXDeflateClick(Sender: TObject);
begin
   Actor.DeflateModel;
end;

procedure TFrm3DModelizer.ModelFXEulerErosionClick(Sender: TObject);
begin
   Actor.EulerSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXGaussianSmoothClick(Sender: TObject);
begin
   Actor.GaussianSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXSincErosionClick(Sender: TObject);
begin
   Actor.SincSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXSincInfiniteErosionClick(Sender: TObject);
begin
   Actor.SincInfiniteSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXSmoothClick(Sender: TObject);
begin
   Actor.SmoothModel;
end;

procedure TFrm3DModelizer.Purple1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Purple1.Checked := true;
   RemapColour.X := RemapColourMap[6].R /255;
   RemapColour.Y := RemapColourMap[6].G /255;
   RemapColour.Z := RemapColourMap[6].B /255;
   Actor.ChangeRemappable(RemapColourMap[6].R,RemapColourMap[6].G,RemapColourMap[6].B);
end;

procedure TFrm3DModelizer.Gold1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Gold1.Checked := true;
   RemapColour.X := RemapColourMap[7].R /255;
   RemapColour.Y := RemapColourMap[7].G /255;
   RemapColour.Z := RemapColourMap[7].B /255;
   Actor.ChangeRemappable(RemapColourMap[7].R,RemapColourMap[7].G,RemapColourMap[7].B);
end;

procedure TFrm3DModelizer.DarkSky1Click(Sender: TObject);
begin
   ClearRemapClicks;
   DarkSky1.Checked := true;
   RemapColour.X := RemapColourMap[8].R /255;
   RemapColour.Y := RemapColourMap[8].G /255;
   RemapColour.Z := RemapColourMap[8].B /255;
   Actor.ChangeRemappable(RemapColourMap[8].R,RemapColourMap[8].G,RemapColourMap[8].B);
end;

procedure TFrm3DModelizer.DisplayFMPointCloudClick(Sender: TObject);
begin
   UncheckFillMode;
   DisplayFMPointCloud.Checked := true;
   Env.SetPolygonMode(GL_POINT);
end;

procedure TFrm3DModelizer.DisplayFMSolidClick(Sender: TObject);
begin
   UncheckFillMode;
   DisplayFMSolid.Checked := true;
   Env.SetPolygonMode(GL_FILL);
end;

procedure TFrm3DModelizer.DisplayFMWireframeClick(Sender: TObject);
begin
   UncheckFillMode;
   DisplayFMWireframe.Checked := true;
   Env.SetPolygonMode(GL_LINE);
end;

procedure TFrm3DModelizer.DisplayNormalVectors1Click(Sender: TObject);
begin
   DisplayNormalVectors1.Checked := not DisplayNormalVectors1.Checked;
   if DisplayNormalVectors1.Checked then
   begin
      Actor.AddNormalsPlugin;
   end
   else
   begin
      Actor.RemoveNormalsPlugin;
   end;
end;

procedure TFrm3DModelizer.CameraRotationAngles1Click(Sender: TObject);
begin
   CameraRotationAngles1.Checked := not CameraRotationAngles1.Checked;
   Env.ShowRotations := CameraRotationAngles1.Checked;
end;

procedure TFrm3DModelizer.SpeedButton2Click(Sender: TObject);
begin
   Camera.SetPosition(Camera.Position.X,Camera.Position.Y,-150);
end;

Procedure TFrm3DModelizer.Reset3DView;
begin
   SpeedButton2Click(nil); // Reset Depth
   Cameo1Click(nil); // Set To Cameo1
   Camera.SetRotationSpeed(0,0,0);

   btn3DRotateY.Down := false;
   btn3DRotateY2.Down := false;
   btn3DRotateX.Down := false;
   btn3DRotateX2.Down := false;
end;

procedure TFrm3DModelizer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FrmMain.p_Frm3DModelizer := nil;
   if FrmMain.Display3dView1.Checked then
      Application.OnIdle := nil;
   Free;
end;

procedure TFrm3DModelizer.CurrentSectionOnly1Click(Sender: TObject);
begin
   CurrentSectionOnly1.Checked := not CurrentSectionOnly1.Checked;
   WholeVoxel1.Checked := not CurrentSectionOnly1.Checked;
   SetActorModelTransparency;
end;

procedure TFrm3DModelizer.SaveModelAsClick(Sender: TObject);
begin
   // We write the save code here...
   SaveModelDialog.InitialDir := ExtractFileDir(ParamStr(0));
   if SaveModelDialog.Execute then
   begin
      Actor.SaveToFile(SaveModelDialog.FileName,TextureFileExt,0);
   end;
end;

procedure TFrm3DModelizer.SetActorModelTransparency;
begin
   if WholeVoxel1.Checked then
   begin
      Actor.ForceTransparency(C_TRP_OPAQUE);
   end
   else
   begin
      Actor.ForceTransparencyExceptOnAMesh(C_TRP_GHOST,0,FrmMain.Document.ActiveSection^.Header.Number);
   end;
end;

procedure TFrm3DModelizer.FormActivate(Sender: TObject);
begin
   FrmMain.OnActivate(sender);
end;

procedure TFrm3DModelizer.FormDeactivate(Sender: TObject);
begin
   FrmMain.OnDeactivate(sender);
   AnimationState := AnimationTimer.Enabled;
   AnimationTimer.Enabled := false;
end;

procedure TFrm3DModelizer.TextureFX10MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX10MipMaps.Checked := true;
   NumMipMaps := 10;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX1MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX1MipMaps.Checked := true;
   NumMipMaps := 1;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX2MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX2MipMaps.Checked := true;
   NumMipMaps := 2;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX3MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX3MipMaps.Checked := true;
   NumMipMaps := 3;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX4MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX4MipMaps.Checked := true;
   NumMipMaps := 4;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX5MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX5MipMaps.Checked := true;
   NumMipMaps := 5;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX6MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX6MipMaps.Checked := true;
   NumMipMaps := 6;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX7MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX7MipMaps.Checked := true;
   NumMipMaps := 7;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX8MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX8MipMaps.Checked := true;
   NumMipMaps := 8;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFX9MipMapsClick(Sender: TObject);
begin
   UncheckNumMipMaps;
   TextureFX9MipMaps.Checked := true;
   NumMipMaps := 9;
   Actor.SetTextureNumMipMaps(NumMipMaps,C_TTP_DIFFUSE);
end;

procedure TFrm3DModelizer.TextureFXBumpClick(Sender: TObject);
begin
   Actor.GenerateBumpMapTexture;
   SetNormalsMode(2);
end;

procedure TFrm3DModelizer.TextureFXBumpCustomClick(Sender: TObject);
var
   Form: TFrmBumpMapping;
begin
   Form := TFrmBumpMapping.Create(self);
   Form.ShowModal;
   if Form.Apply then
   begin
      Actor.GenerateBumpMapTexture(StrToFloatDef(Form.EdBump.Text,2.2));
      SetNormalsMode(2);
   end;
end;

procedure TFrm3DModelizer.TextureFXNormalClick(Sender: TObject);
begin
   Actor.GenerateNormalMapTexture;
   SetNormalsMode(2);
end;

procedure TFrm3DModelizer.UncheckTextureSize;
begin
   TextureFXSize4096.checked := false;
   TextureFXSize2048.checked := false;
   TextureFXSize1024.checked := false;
   TextureFXSize512.checked := false;
   TextureFXSize256.checked := false;
   TextureFXSize128.checked := false;
   TextureFXSize64.checked := false;
   TextureFXSize32.checked := false;
end;

procedure TFrm3DModelizer.TextureFXSize1024Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize1024.checked := true;
   TextureSize := 1024;
end;

procedure TFrm3DModelizer.TextureFXSize128Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize128.checked := true;
   TextureSize := 128;
end;

procedure TFrm3DModelizer.TextureFXSize2048Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize2048.checked := true;
   TextureSize := 2048;
end;

procedure TFrm3DModelizer.TextureFXSize256Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize256.checked := true;
   TextureSize := 256;
end;

procedure TFrm3DModelizer.TextureFXSize32Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize32.checked := true;
   TextureSize := 32;
end;

procedure TFrm3DModelizer.TextureFXSize4096Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize4096.checked := true;
   TextureSize := 4096;
end;

procedure TFrm3DModelizer.TextureFXSize512Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize512.checked := true;
   TextureSize := 512;
end;

procedure TFrm3DModelizer.TextureFXSize64Click(Sender: TObject);
begin
   UncheckTextureSize;
   TextureFXSize64.checked := true;
   TextureSize := 64;
end;

function TFrm3DModelizer.GetQualityModel: integer;
begin
   if RenderModel.checked then
   begin
      Result := C_QUALITY_HIGH;
   end
   else if RenderVisibleTriangles.Checked then
   begin
      Result := C_QUALITY_VISIBLE_TRIS;
   end
   else if RenderQuads.Checked then
   begin
      Result := C_QUALITY_LANCZOS_QUADS;
   end
   else if Render4Triangles.Checked then
   begin
      Result := C_QUALITY_2LANCZOS_4TRIS;
   end
   else if RenderTriangles.Checked then
   begin
      Result := C_QUALITY_LANCZOS_TRIS;
   end
   else if RenderVisibleCubes.Checked then
   begin
      Result := C_QUALITY_VISIBLE_CUBED;
   end
   else if RenderManifolds.Checked then
   begin
      Result := C_QUALITY_VISIBLE_MANIFOLD;
   end
   else
   begin
      Result := C_QUALITY_CUBED;
   end;
end;

procedure TFrm3DModelizer.UpdateQualityUI;
begin
   TextureFSExport.Enabled := false;
   if RenderModel.checked then
   begin
      RenderModelClick(nil);
   end
   else if RenderVisibleTriangles.Checked then
   begin
      RenderVisibleTrianglesClick(nil);
   end
   else if RenderQuads.Checked then
   begin
      RenderQuadsClick(nil);
   end
   else if Render4Triangles.Checked then
   begin
      Render4TrianglesClick(nil);
   end
   else if RenderTriangles.Checked then
   begin
      RenderTrianglesClick(nil);
   end
   else if RenderVisibleCubes.Checked then
   begin
      RenderVisibleCubesClick(nil);
   end
   else if RenderManifolds.Checked then
   begin
      RenderManifoldsClick(nil);
   end
   else
   begin
      RenderCubesClick(nil);
   end;
end;

procedure TFrm3DModelizer.UncheckModelQuality;
begin
   RenderCubes.Checked := false;
   RenderVisibleCubes.Checked := false;
   RenderVisibleTriangles.Checked := false;
   RenderQuads.Checked := false;
   RenderModel.Checked := false;
   Render4Triangles.Checked := false;
   RenderTriangles.Checked := false;
   RenderManifolds.Checked := false;
end;

procedure TFrm3DModelizer.UncheckFillMode;
begin
   DisplayFMSolid.Checked := false;
   DisplayFMWireframe.Checked := false;
   DisplayFMPointCloud.Checked := false;
end;

procedure TFrm3DModelizer.SetMeshMode(_MeshMode : integer);
begin
   MeshMode := _MeshMode;
   case MeshMode of
      0: // Quads.
      begin
         ModelFXSmooth.Enabled := true;
         ModelFXUnsharp.Enabled := true;
         ModelFXHeavySmooth.Enabled := true;
         ModelFXDeflate.Enabled := true;
         ModelFXInflate.Enabled := true;
         ModelFXLanczos.Enabled := true;
         ModelFXSincErosion.Enabled := true;
         ModelFXEulerErosion.Enabled := true;
         ModelFXHeavyEulerErosion.Enabled := true;
         ModelFXSincInfiniteErosion.Enabled := true;
         ModelFXGaussianSmooth.Enabled := true;
         ModelFXSquaredSmooth.Enabled := true;
         FaceFXCleanupInvisibleFaces.Enabled := true;
         FaceFXConvertQuadstoTriangles.Enabled := true;
         FaceFXOptimizeMesh.Enabled := false;
         FaceFXOptimizeMeshIgnoringColours.Enabled := false;
         FaceFXOptimizeMeshCustom.Enabled := false;
      end;
      1: // Triangles
      begin
         ModelFXSmooth.Enabled := true;
         ModelFXUnsharp.Enabled := true;
         ModelFXHeavySmooth.Enabled := true;
         ModelFXDeflate.Enabled := true;
         ModelFXInflate.Enabled := true;
         ModelFXLanczos.Enabled := true;
         ModelFXSincErosion.Enabled := true;
         ModelFXEulerErosion.Enabled := true;
         ModelFXHeavyEulerErosion.Enabled := true;
         ModelFXSincInfiniteErosion.Enabled := true;
         ModelFXGaussianSmooth.Enabled := true;
         ModelFXSquaredSmooth.Enabled := true;
         FaceFXCleanupInvisibleFaces.Enabled := true;
         FaceFXConvertQuadstoTriangles.Enabled := false;
         FaceFXOptimizeMesh.Enabled := true;
         FaceFXOptimizeMeshIgnoringColours.Enabled := true;
         FaceFXOptimizeMeshCustom.Enabled := true;
      end;
      2: // Optimized triangles.
      begin
         ModelFXSmooth.Enabled := false;
         ModelFXUnsharp.Enabled := false;
         ModelFXHeavySmooth.Enabled := false;
         ModelFXDeflate.Enabled := false;
         ModelFXInflate.Enabled := false;
         ModelFXLanczos.Enabled := false;
         ModelFXSincErosion.Enabled := false;
         ModelFXEulerErosion.Enabled := false;
         ModelFXHeavyEulerErosion.Enabled := false;
         ModelFXSincInfiniteErosion.Enabled := false;
         ModelFXGaussianSmooth.Enabled := false;
         ModelFXSquaredSmooth.Enabled := false;
         FaceFXCleanupInvisibleFaces.Enabled := false;
         FaceFXConvertQuadstoTriangles.Enabled := false;
         FaceFXOptimizeMesh.Enabled := true;
         FaceFXOptimizeMeshIgnoringColours.Enabled := true;
         FaceFXOptimizeMeshCustom.Enabled := true;
      end;
      else
      begin
         ModelFXSmooth.Enabled := true;
         ModelFXUnsharp.Enabled := true;
         ModelFXHeavySmooth.Enabled := true;
         ModelFXDeflate.Enabled := true;
         ModelFXInflate.Enabled := true;
         ModelFXLanczos.Enabled := true;
         ModelFXSincErosion.Enabled := true;
         ModelFXEulerErosion.Enabled := true;
         ModelFXHeavyEulerErosion.Enabled := true;
         ModelFXSincInfiniteErosion.Enabled := true;
         ModelFXGaussianSmooth.Enabled := true;
         ModelFXSquaredSmooth.Enabled := true;
         FaceFXCleanupInvisibleFaces.Enabled := true;
         FaceFXConvertQuadstoTriangles.Enabled := true;
         FaceFXOptimizeMesh.Enabled := true;
         FaceFXOptimizeMeshIgnoringColours.Enabled := true;
         FaceFXOptimizeMeshCustom.Enabled := true;
      end;
   end;
end;

procedure TFrm3DModelizer.SetNormalsMode(_NormalsMode : integer);
begin
   NormalsMode := _NormalsMode;
   case NormalsMode of
      0: // Normals per face
      begin
         NormalFXNormalize.Enabled := true;
         NormalsFXConvertFaceToVertexNormals.Enabled := true;
         NormalsFXQuickSmoothNormals.Enabled := true;
         NormalsFXSmoothNormals.Enabled := true;
         NormalsFXCubicSmoothNormals.Enabled := true;
         NormalsFXLanczosSmoothNormals.Enabled := true;
         TextureFXNormal.Enabled := false;
         TextureFXBump.Enabled := false;
         TextureFXBumpCustom.Enabled := false;
      end;
      1: // Normals per vertex
      begin
         NormalFXNormalize.Enabled := true;
         NormalsFXConvertFaceToVertexNormals.Enabled := false;
         NormalsFXQuickSmoothNormals.Enabled := true;
         NormalsFXSmoothNormals.Enabled := true;
         NormalsFXCubicSmoothNormals.Enabled := true;
         NormalsFXLanczosSmoothNormals.Enabled := true;
         TextureFXNormal.Enabled := (ColoursMode > 1);
         TextureFXBump.Enabled := (ColoursMode > 1);
         TextureFXBumpCustom.Enabled := (ColoursMode > 1);
      end;
      2: // Normals in a Normal Map or Bump Map
      begin
         NormalFXNormalize.Enabled := false;
         NormalsFXConvertFaceToVertexNormals.Enabled := false;
         NormalsFXQuickSmoothNormals.Enabled := false;
         NormalsFXSmoothNormals.Enabled := false;
         NormalsFXCubicSmoothNormals.Enabled := false;
         NormalsFXLanczosSmoothNormals.Enabled := false;
         TextureFXNormal.Enabled := false;
         TextureFXBump.Enabled := false;
         TextureFXBumpCustom.Enabled := false;
      end;
      else
      begin
         NormalFXNormalize.Enabled := true;
         NormalsFXConvertFaceToVertexNormals.Enabled := true;
         NormalsFXQuickSmoothNormals.Enabled := true;
         NormalsFXSmoothNormals.Enabled := true;
         NormalsFXCubicSmoothNormals.Enabled := true;
         NormalsFXLanczosSmoothNormals.Enabled := true;
         TextureFXNormal.Enabled := true;
         TextureFXBump.Enabled := true;
         TextureFXBumpCustom.Enabled := true;
      end;
   end;
end;

procedure TFrm3DModelizer.SetColoursMode(_ColoursMode : integer);
begin
   ColoursMode := _ColoursMode;
   case ColoursMode of
      0: // Colours per face
      begin
         ColourFXSmooth.Enabled := true;
         ColourFXHeavySmooth.Enabled := true;
         ColourFXConvertFaceToVertexS.Enabled := true;
         ColourFXConvertFaceToVertexHS.Enabled := true;
         ColourFXConvertFaceToVertexLS.Enabled := true;
         ColourFXConvertVertexToFace.Enabled := false;
         ColourFXConvertFacetoVertex.Enabled := true;
         TextureFXDiffuse.Enabled := false;
         TextureFXDiffuseCustom.Enabled := false;
         TextureFSExport.Enabled := false;
         TextureFSExportHeightMap.Enabled := false;
         TextureFXNormal.Enabled := false;
         TextureFXBump.Enabled := false;
         TextureFXBumpCustom.Enabled := false;
         TextureFXNumMipMaps.Enabled := false;
      end;
      1: // Colours per vertex
      begin
         ColourFXSmooth.Enabled := true;
         ColourFXHeavySmooth.Enabled := true;
         ColourFXConvertFaceToVertexS.Enabled := false;
         ColourFXConvertFaceToVertexHS.Enabled := false;
         ColourFXConvertFaceToVertexLS.Enabled := false;
         ColourFXConvertVertexToFace.Enabled := true;
         ColourFXConvertFacetoVertex.Enabled := false;
         TextureFXDiffuse.Enabled := true;
         TextureFXDiffuseCustom.Enabled := true;
         TextureFSExport.Enabled := false;
         TextureFSExportHeightMap.Enabled := false;
         TextureFXNormal.Enabled := false;
         TextureFXBump.Enabled := false;
         TextureFXBumpCustom.Enabled := false;
         TextureFXNumMipMaps.Enabled := false;
      end;
      2: // Colours in a diffuse texture
      begin
         ColourFXSmooth.Enabled := false;
         ColourFXHeavySmooth.Enabled := false;
         ColourFXConvertFaceToVertexS.Enabled := false;
         ColourFXConvertFaceToVertexHS.Enabled := false;
         ColourFXConvertFaceToVertexLS.Enabled := false;
         ColourFXConvertVertexToFace.Enabled := false;
         ColourFXConvertFacetoVertex.Enabled := false;
         TextureFXDiffuse.Enabled := false;
         TextureFXDiffuseCustom.Enabled := false;
         TextureFSExport.Enabled := true;
         TextureFSExportHeightMap.Enabled := true;
         TextureFXNormal.Enabled := (NormalsMode = 1);
         TextureFXBump.Enabled := (NormalsMode = 1);
         TextureFXBumpCustom.Enabled := (NormalsMode = 1);
         TextureFXNumMipMaps.Enabled := true;
      end;
      else
      begin
         ColourFXSmooth.Enabled := true;
         ColourFXHeavySmooth.Enabled := true;
         ColourFXConvertFaceToVertexS.Enabled := true;
         ColourFXConvertFaceToVertexHS.Enabled := true;
         ColourFXConvertFaceToVertexLS.Enabled := true;
         ColourFXConvertVertexToFace.Enabled := true;
         ColourFXConvertFacetoVertex.Enabled := true;
         TextureFXDiffuse.Enabled := true;
         TextureFXDiffuseCustom.Enabled := true;
         TextureFSExport.Enabled := true;
         TextureFSExportHeightMap.Enabled := true;
         TextureFXNormal.Enabled := true;
         TextureFXBump.Enabled := true;
         TextureFXBumpCustom.Enabled := true;
         TextureFXNumMipMaps.Enabled := true;
      end;
   end;
end;

procedure TFrm3DModelizer.UncheckNumMipMaps;
begin
   TextureFX1MipMaps.Checked := false;
   TextureFX2MipMaps.Checked := false;
   TextureFX3MipMaps.Checked := false;
   TextureFX4MipMaps.Checked := false;
   TextureFX5MipMaps.Checked := false;
   TextureFX6MipMaps.Checked := false;
   TextureFX7MipMaps.Checked := false;
   TextureFX8MipMaps.Checked := false;
   TextureFX9MipMaps.Checked := false;
   TextureFX10MipMaps.Checked := false;
end;


end.
