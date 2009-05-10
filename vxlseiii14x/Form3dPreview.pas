// Originaly Made by Jan Horn (Quake 3 Model Viewer)
// Modifyed By Stuart Carey (To a VXL Previewer)
// And modified by Carlos "Banshee" Muniz for VXLSE III.
// And modified again by Banshee to support the OS 3D Engine from VXLSE III 2.0 and OSGIC
unit Form3dPreview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, {model,} dglOpenGL, {Textures,} Menus, voxel, Spin,
  Buttons, FTGifAnimate, GIFImage,Palette,BasicDataTypes, Voxel_Engine, Normals,
  Ogl3dview_engine,HVA,JPEG,PNGImage, math3d, RenderEnvironment, Render, Actor,
  Camera;

type
  PFrm3DPReview = ^TFrm3DPReview;
  TFrm3DPReview = class(TForm)
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
    procedure ClearRemapClicks;
  public
    { Public declarations }
    AnimationState : boolean;
    IsReady : boolean;
    EnvP : PRenderEnvironment;
    Env : TRenderEnvironment;
    Actor : TActor;
    Camera : TCamera;
    Procedure SetRotationAdders;
    procedure SetActorModelTransparency;
    Procedure Reset3DView;
  end;

type TVector3b = record
  R,G,B : Byte;
end;

const

  RemapColourMap : array [0..8] of TVector3b =
  (
  ( //DarkRed
  R : 146;
  G : 3;
  B : 3;
  ),
  ( //DarkBlue
  R : 9;
  G : 32;
  B : 140;
  ),
  ( //DarkGreen
  R : 13;
  G : 136;
  B : 16;
  ),
  ( //White
  R : 160;
  G : 160;
  B : 160;
  ),
  ( //Orange
  R : 146;
  G : 92;
  B : 3;
  ),
  ( //Magenta
  R : 104;
  G : 43;
  B : 73;
  ),
  ( //Purple
  R : 137;
  G : 12;
  B : 134;
  ),
  ( //Gold
  R : 149;
  G : 119;
  B : 0;
  ),
  ( //DarkSky
  R : 13;
  G : 102;
  B : 136;
  )
  );

implementation

uses FormMain, GlobalVars;

{$R *.DFM}

{
      if ScreenieType <> stNone then
      begin
         case (ScreenieType) of
            stBmp:
            begin
               ScreenShotBMP(VXLFilename);
               height := oldh;
               width := oldw;
               ScreenieType := stNone;
            end;
            stTga:
            begin
               ScreenShot(VXLFilename);
               height := oldh;
               width := oldw;
               ScreenieType := stNone;
            end;
            stJpg:
            begin
               ScreenshotJPG(VXLFilename,1);
               height := oldh;
               width := oldw;
               ScreenieType := stNone;
            end;
            stPng:
            begin
               ScreenshotPNG(VXLFilename);
               height := oldh;
               width := oldw;
               ScreenieType := stNone;
            end;
            stGif:
            begin
               GifAnimateAddImage(ScreenShot_BitmapResult, False, 10);
               if (YRot = 360) then
               begin
                  ScreenieType := stNone;
                  FrmMain.btn3DRotateY.Down := False;
                  ScreenShotGIF(GifAnimateEndGif, VXLFilename);

                  btn3DRotateY.Enabled  := True;
                  btn3DRotateY2.Enabled := True;
                  btn3DRotateX.Enabled  := True;
                  btn3DRotateX2.Enabled := True;
                  spin3Djmp.Enabled     := True;
                  SpeedButton1.Enabled  := True;
                  SpeedButton2.Enabled  := True;

                  YRot := 225;
                  XRotB := False;
                  YRotB := False;

                  height := oldh;
                  width := oldw;
               end;
            end;
         end;
      end;


{------------------------------------------------------------------}
procedure TFrm3DPReview.FormCreate(Sender: TObject);
var
   pfd : TPIXELFORMATDESCRIPTOR;
   pf  : Integer;
begin
   IsReady := false;
   // OpenGL initialization
   EnvP := GlobalVars.Render.AddEnvironment(Panel2.Handle,Panel2.Width,Panel2.Height);
   Env := EnvP^;
   Env.BackgroundColour := SetVector(140/255,170/255,235/255);
   Env.FontColour := SetVector(1,1,1);
   Env.Size := 0.1;
   Camera := Env.CurrentCamera^;

   RemapColour.X := RemapColourMap[0].R /255;
   RemapColour.Y := RemapColourMap[0].G /255;
   RemapColour.Z := RemapColourMap[0].B /255;

   SpFrame.Value := 1;
   SpFrame.MaxValue := FrmMain.Document.ActiveHVA^.Header.N_Frames;
   FrmMain.Document.ActiveHVA^.Frame := 0;

   Actor := (Env.AddActor)^;
   Actor.Add(FrmMain.Document.ActiveVoxel,FrmMain.Document.ActiveHVA,FrmMain.Document.Palette,false);
   SetActorModelTransparency;

   IsReady := true;
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}

{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DPReview.FormResize(Sender: TObject);
begin
   if width < 330 then
      Width := 330;
   Env.Resize(Panel2.Width,Panel2.Height);
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DPReview.FormDestroy(Sender: TObject);
begin
   GlobalVars.Render.RemoveEnvironment(EnvP);
   FrmMain.p_Frm3DPreview := nil;
end;


{------------------------------------------------------------------}
{------------------------------------------------------------------}
procedure TFrm3DPReview.Panel2MouseMove(Sender: TObject; Shift: TShiftState; X,
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
procedure TFrm3DPReview.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TFrm3DPReview.Panel2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   MouseButton :=0;
end;

procedure TFrm3DPReview.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TFrm3DPReview.BackgroundColour1Click(Sender: TObject);
begin
   ColorDialog1.Color := TVector3fToTColor(BGColor);
   if ColorDialog1.Execute then
      BGColor := TColorToTVector3f(ColorDialog1.Color);
end;

Procedure TFrm3DPReview.SetRotationAdders;
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
      Camera.SetRotationSpeed(V,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);

   if btn3DRotateY2.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,-V)
   else if btn3DRotateY.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,V);
end;

procedure TFrm3DPReview.btn3DRotateX2Click(Sender: TObject);
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

procedure TFrm3DPReview.btn3DRotateXClick(Sender: TObject);
begin
   if btn3DRotateX.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);
end;

procedure TFrm3DPReview.btn3DRotateY2Click(Sender: TObject);
begin
   if btn3DRotateY2.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,0);
end;

procedure TFrm3DPReview.btn3DRotateYClick(Sender: TObject);
begin
   if btn3DRotateY.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,Camera.RotationSpeed.Y,0);
end;

procedure TFrm3DPReview.spin3DjmpChange(Sender: TObject);
begin
   SetRotationAdders;
end;

procedure TFrm3DPReview.SpPlayClick(Sender: TObject);
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

procedure TFrm3DPReview.SpStopClick(Sender: TObject);
begin
   AnimationTimer.Enabled := false;
   FrmMain.Document.ActiveHVA^.Frame := 0;
   SpFrame.Value := 1;
   SpPlay.Glyph.LoadFromFile(ExtractFileDir(ParamStr(0)) + '/images/play.bmp');
end;

procedure TFrm3DPReview.AnimationTimerTimer(Sender: TObject);
begin
   if FrmMain.Document.ActiveHVA^.Header.N_Frames = 1 then
   begin
      SpStopClick(Sender);
   end;
   FrmMain.Document.ActiveHVA^.Frame := (FrmMain.Document.ActiveHVA^.Frame + 1) mod SpFrame.MaxValue;
   SpFrame.Value := FrmMain.Document.ActiveHVA^.Frame + 1;
end;

procedure TFrm3DPReview.SpFrameChange(Sender: TObject);
begin
   if StrToIntDef(SpFrame.Text,-1) <> -1 then
   begin
      if SpFrame.Value > SpFrame.MaxValue then
         SpFrame.Value := 1
      else if SpFrame.Value < 1 then
         SpFrame.Value := SpFrame.MaxValue;
      FrmMain.Document.ActiveHVA^.Frame := SpFrame.Value-1;
   end;
end;

procedure TFrm3DPReview.FontColor1Click(Sender: TObject);
begin
   ColorDialog1.Color := TVector3fToTColor(FontColor);
   if ColorDialog1.Execute then
      FontColor := TColorToTVector3f(ColorDialog1.Color);
end;

procedure TFrm3DPReview.Front1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,-90);
end;

procedure TFrm3DPReview.Back1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,90);
end;

procedure TFrm3DPReview.LEft1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,0);
end;

procedure TFrm3DPReview.Right1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,0,-180);
end;

procedure TFrm3DPReview.Bottom1Click(Sender: TObject);
begin
   Camera.SetRotation(180,0,180);
end;

procedure TFrm3DPReview.op1Click(Sender: TObject);
begin
   Camera.SetRotation(0,0,180);
end;

procedure TFrm3DPReview.Cameo1Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,225);
end;

procedure TFrm3DPReview.SpeedButton1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Popup3d.Popup(Left+SpeedButton1.Left+5,Top+ 60+ SpeedButton1.Top);
end;

procedure TFrm3DPReview.Cameo21Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,315);
end;

procedure TFrm3DPReview.Cameo31Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,255);
end;

procedure TFrm3DPReview.Cameo41Click(Sender: TObject);
begin
   Camera.SetRotation(287,0,285);
end;

procedure TFrm3DPReview.ake360DegScreenshots1Click(Sender: TObject);
begin
   Env.Take360Animation(VXLFilename,90,10,stGif);

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
end;

procedure TFrm3DPReview.akeScreenshot1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stTGA);
end;

procedure TFrm3DPReview.akeScreenshotBMP1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stBMP);
end;

procedure TFrm3DPReview.akeScreenshotJPG1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stJPG);
end;

procedure TFrm3DPReview.akeScreenshotPNG1Click(Sender: TObject);
begin
   Env.TakeScreenshot(VXLFilename,stPNG);
end;

procedure TFrm3DPReview.ClearRemapClicks;
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

procedure TFrm3DPReview.Red1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Red1.Checked := true;
   RemapColour.X := RemapColourMap[0].R /255;
   RemapColour.Y := RemapColourMap[0].G /255;
   RemapColour.Z := RemapColourMap[0].B /255;
   Actor.ChangeRemappable(RemapColourMap[0].R,RemapColourMap[0].G,RemapColourMap[0].B);
end;

procedure TFrm3DPReview.Blue1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Blue1.Checked := true;
   RemapColour.X := RemapColourMap[1].R /255;
   RemapColour.Y := RemapColourMap[1].G /255;
   RemapColour.Z := RemapColourMap[1].B /255;
   Actor.ChangeRemappable(RemapColourMap[1].R,RemapColourMap[1].G,RemapColourMap[1].B);
end;

procedure TFrm3DPReview.Green1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Green1.Checked := true;
   RemapColour.X := RemapColourMap[2].R /255;
   RemapColour.Y := RemapColourMap[2].G /255;
   RemapColour.Z := RemapColourMap[2].B /255;
   Actor.ChangeRemappable(RemapColourMap[2].R,RemapColourMap[2].G,RemapColourMap[2].B);
end;

procedure TFrm3DPReview.White1Click(Sender: TObject);
begin
   ClearRemapClicks;
   White1.Checked := true;
   RemapColour.X := RemapColourMap[3].R /255;
   RemapColour.Y := RemapColourMap[3].G /255;
   RemapColour.Z := RemapColourMap[3].B /255;
   Actor.ChangeRemappable(RemapColourMap[3].R,RemapColourMap[3].G,RemapColourMap[3].B);
end;

procedure TFrm3DPReview.Orange1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Orange1.Checked := true;
   RemapColour.X := RemapColourMap[4].R /255;
   RemapColour.Y := RemapColourMap[4].G /255;
   RemapColour.Z := RemapColourMap[4].B /255;
   Actor.ChangeRemappable(RemapColourMap[4].R,RemapColourMap[4].G,RemapColourMap[4].B);
end;

procedure TFrm3DPReview.Magenta1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Magenta1.Checked := true;
   RemapColour.X := RemapColourMap[5].R /255;
   RemapColour.Y := RemapColourMap[5].G /255;
   RemapColour.Z := RemapColourMap[5].B /255;
   Actor.ChangeRemappable(RemapColourMap[5].R,RemapColourMap[5].G,RemapColourMap[5].B);
end;

procedure TFrm3DPReview.Purple1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Purple1.Checked := true;
   RemapColour.X := RemapColourMap[6].R /255;
   RemapColour.Y := RemapColourMap[6].G /255;
   RemapColour.Z := RemapColourMap[6].B /255;
   Actor.ChangeRemappable(RemapColourMap[6].R,RemapColourMap[6].G,RemapColourMap[6].B);
end;

procedure TFrm3DPReview.Gold1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Gold1.Checked := true;
   RemapColour.X := RemapColourMap[7].R /255;
   RemapColour.Y := RemapColourMap[7].G /255;
   RemapColour.Z := RemapColourMap[7].B /255;
   Actor.ChangeRemappable(RemapColourMap[7].R,RemapColourMap[7].G,RemapColourMap[7].B);
end;

procedure TFrm3DPReview.DarkSky1Click(Sender: TObject);
begin
   ClearRemapClicks;
   DarkSky1.Checked := true;
   RemapColour.X := RemapColourMap[8].R /255;
   RemapColour.Y := RemapColourMap[8].G /255;
   RemapColour.Z := RemapColourMap[8].B /255;
   Actor.ChangeRemappable(RemapColourMap[8].R,RemapColourMap[8].G,RemapColourMap[8].B);
end;

procedure TFrm3DPReview.SpeedButton2Click(Sender: TObject);
begin
   Camera.SetPosition(Camera.Position.X,Camera.Position.Y,-30);
end;

Procedure TFrm3DPReview.Reset3DView;
begin
   SpeedButton2Click(nil); // Reset Depth
   Cameo1Click(nil); // Set To Cameo1
   Camera.SetRotationSpeed(0,0,0);

   btn3DRotateY.Down := false;
   btn3DRotateY2.Down := false;
   btn3DRotateX.Down := false;
   btn3DRotateX2.Down := false;
end;

procedure TFrm3DPReview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FrmMain.p_Frm3DPreview := nil;
   if FrmMain.Display3dView1.Checked then
      Application.OnIdle := nil;
   Free;
end;

procedure TFrm3DPReview.CurrentSectionOnly1Click(Sender: TObject);
begin
   CurrentSectionOnly1.Checked := not CurrentSectionOnly1.Checked;
   WholeVoxel1.Checked := not CurrentSectionOnly1.Checked;
   SetActorModelTransparency;
end;

procedure TFrm3DPReview.SetActorModelTransparency;
begin
   if WholeVoxel1.Checked then
   begin
      Actor.ForceTransparency(0);
   end
   else
   begin
      Actor.ForceTransparencyExceptOnAMesh(80,0,FrmMain.Document.ActiveSection^.Header.Number);
   end;
end;

procedure TFrm3DPReview.FormActivate(Sender: TObject);
begin
   FrmMain.OnActivate(sender);
end;

procedure TFrm3DPReview.FormDeactivate(Sender: TObject);
begin
   FrmMain.OnDeactivate(sender);
   AnimationState := AnimationTimer.Enabled;
   AnimationTimer.Enabled := false;
end;

end.
