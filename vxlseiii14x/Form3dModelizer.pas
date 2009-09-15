unit Form3dModelizer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, {model,} dglOpenGL, {Textures,} Menus, voxel, Spin,
  Buttons, FTGifAnimate, GIFImage,Palette,BasicDataTypes, Voxel_Engine, Normals,
  HVA,JPEG,PNGImage, math3d, RenderEnvironment, Render, Actor, Camera, GlConstants,
  BasicFunctions;

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
    ModelFXNormalize: TMenuItem;
    ModelFXLanczos: TMenuItem;
    SaveModelAs: TMenuItem;
    N4: TMenuItem;
    SaveModelDialog: TSaveDialog;
    RenderQuads: TMenuItem;
    ModelFXCleanupInvisibleFaces: TMenuItem;
    procedure ModelFXCleanupInvisibleFacesClick(Sender: TObject);
    procedure RenderQuadsClick(Sender: TObject);
    procedure SaveModelAsClick(Sender: TObject);
    procedure ModelFXLanczosClick(Sender: TObject);
    procedure ModelFXNormalizeClick(Sender: TObject);
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
  private
    { Private declarations }
    RemapColour : TVector3f;
    Xcoord, Ycoord, Zcoord : Integer;
    MouseButton : Integer;
    // These are for Take 360 Animation
    btn3DRotateY_d, btn3DRotateY2_d, btn3DRotateX_d, btn3DRotateX2_d : boolean;
    procedure ClearRemapClicks;
  public
    { Public declarations }
    AnimationState : boolean;
    EnvP : PRenderEnvironment;
    Env : TRenderEnvironment;
    Actor : TActor;
    Camera : TCamera;
    Procedure SetRotationAdders;
    procedure SetActorModelTransparency;
    Procedure Reset3DView;
    function GetQualityModel: integer;
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
      Camera.SetRotation(Camera.Rotation.X + (Y - Ycoord)/2,Camera.Rotation.Y,Camera.Rotation.Z + (X - Xcoord)/2);
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

procedure TFrm3DModelizer.Exit1Click(Sender: TObject);
begin
   Close;
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
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,-V)
   else if btn3DRotateY.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,V)
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,0);
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
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,0);
end;

procedure TFrm3DModelizer.btn3DRotateYClick(Sender: TObject);
begin
   if btn3DRotateY.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,0);
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
   Camera.SetRotation(-90,0,-90);
end;

procedure TFrm3DModelizer.Back1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,90);
end;

procedure TFrm3DModelizer.ModelFXLanczosClick(Sender: TObject);
begin
   Actor.LanczosSmoothModel;
end;

procedure TFrm3DModelizer.LEft1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,0);
end;

procedure TFrm3DModelizer.Right1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,-180);
end;

procedure TFrm3DModelizer.Bottom1Click(Sender: TObject);
begin
   Camera.SetRotation(180,0,180);
end;

procedure TFrm3DModelizer.op1Click(Sender: TObject);
begin
   Camera.SetRotation(0,0,180);
end;

procedure TFrm3DModelizer.Cameo1Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,225);
end;

procedure TFrm3DModelizer.SpeedButton1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Popup3d.Popup(Left+SpeedButton1.Left+5,Top+ 60+ SpeedButton1.Top);
end;

procedure TFrm3DModelizer.Cameo21Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,315);
end;

procedure TFrm3DModelizer.Cameo31Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,255);
end;

procedure TFrm3DModelizer.Cameo41Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,285);
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

procedure TFrm3DModelizer.Red1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Red1.Checked := true;
   RemapColour.X := RemapColourMap[0].R /255;
   RemapColour.Y := RemapColourMap[0].G /255;
   RemapColour.Z := RemapColourMap[0].B /255;
   Actor.ChangeRemappable(RemapColourMap[0].R,RemapColourMap[0].G,RemapColourMap[0].B);
end;

procedure TFrm3DModelizer.RenderCubesClick(Sender: TObject);
begin
   RenderCubes.Checked := true;
   RenderQuads.Checked := false;
   RenderModel.Checked := false;
   Actor.SetQuality(GetQualityModel);
end;

procedure TFrm3DModelizer.RenderModelClick(Sender: TObject);
begin
   RenderCubes.Checked := false;
   RenderQuads.Checked := false;
   RenderModel.Checked := true;
   Actor.SetQuality(GetQualityModel);
end;

procedure TFrm3DModelizer.RenderQuadsClick(Sender: TObject);
begin
   RenderCubes.Checked := false;
   RenderQuads.Checked := true;
   RenderModel.Checked := false;
   Actor.SetQuality(GetQualityModel);
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

procedure TFrm3DModelizer.ModelFXHeavySmoothClick(Sender: TObject);
begin
   Actor.CubicSmoothModel;
end;

procedure TFrm3DModelizer.ModelFXInflateClick(Sender: TObject);
begin
   Actor.InflateModel;
end;

procedure TFrm3DModelizer.ModelFXNormalizeClick(Sender: TObject);
begin
   Actor.ReNormalizeModel;
end;

procedure TFrm3DModelizer.ModelFXCleanupInvisibleFacesClick(Sender: TObject);
begin
   Actor.RemoveInvisibleFaces;
end;

procedure TFrm3DModelizer.ModelFXDeflateClick(Sender: TObject);
begin
   Actor.DeflateModel;
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
      Actor.SaveToFile(SaveModelDialog.FileName,0);
   end;
end;

procedure TFrm3DModelizer.SetActorModelTransparency;
begin
   if WholeVoxel1.Checked then
   begin
      Actor.ForceTransparency(0);
   end
   else
   begin
      Actor.ForceTransparencyExceptOnAMesh(0.95,0,FrmMain.Document.ActiveSection^.Header.Number);
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

function TFrm3DModelizer.GetQualityModel: integer;
begin
   if RenderModel.checked then
   begin
      Result := C_QUALITY_HIGH;
   end
   else if RenderQuads.Checked then
   begin
      Result := C_QUALITY_LANCZOS_QUADS;
   end
   else
   begin
      Result := C_QUALITY_CURVED;
   end;
end;

end.
