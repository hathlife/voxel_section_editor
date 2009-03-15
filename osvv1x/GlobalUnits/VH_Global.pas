unit VH_Global;

interface

Uses Windows,Graphics,Palette,OpenGL15,VH_Types,Math3d,Voxel,TimerUnit,HVA;//,OpenGLWrapper;

Const
ENGINE_TITLE = 'Voxel HVA Engine';
ENGINE_VER = '1.3';
ENGINE_BY = 'Stucuk and Banshee';

var
h_DC   : HDC;
h_rc   : HGLRC;
h_Wnd  : HWND;

gTimer : TTimerSystem;

VoxelFile,VoxelTurret,VoxelBarrel : TVoxel;
CurrentVoxel,CurrentSectionVoxel : PVoxel;

VXLPalette: TPalette;
DefaultPalette,VHLocation,VXLFilename : String;
VoxelBoxes,VoxelBoxesT,VoxelBoxesB : TVoxelBoxs;

VoxelBox_No,VoxelBox_NoT,VoxelBox_NoB,
base, VoxelsUsed,CurrentVoxelSection,CurrentSection,
Xcoord,Xcoord2,Ycoord,Ycoord2,Zcoord,MouseButton,
SCREEN_WIDTH,SCREEN_HEIGHT,GroundTex_No,
Default_View,Axis : Integer;

BGColor,FontColor,RemapColour,UnitShift : TVector3f;

VoxelOpen,VoxelOpenT,VoxelOpenB,
HVAOpen,HVAOpenT,HVAOpenB,
ColoursOnly,TileGround,Ground_Tex_Draw,
XRotB,YRotB,oglloaded,DebugMode,
ShowVoxelCount,VVSLoading,DrawSky,
DrawCenter,VXLChanged : Boolean;

DrawVHWorld : Boolean = True;
Highlight : Boolean = True;
DrawAllOfVoxel : Boolean = True;
DrawTurret : Boolean = True;
DrawBarrel : Boolean = True;
CullFace : Boolean = True;

GroundTex : TGTI;
GroundTex_Textures : array of TGT;

SkyTexList : array of TSKYTex;
SkyTexList_No : integer;
SkyList,SkyTex : integer;
SkyPos,SkySize : TVector3f;

CamMov : Single = 0.33333333333;

SpectrumMode : ESpectrumMode;

xRot,yRot,xRot2,yRot2,Depth,FOV,DEPTH_OF_VIEW,
Size,DefaultDepth,UnitRot,LowestZ,GroundHeightOffset,
TexShiftX,TexShiftY,GSize : Single;

HVAFile,HVABarrel,HVATurret : THVA;
HVAFrame : integer = 0;
HVAFrameB : integer = 0;
HVAFrameT : integer = 0;
HVACurrentFrame : integer = 0;
HVAScale : single = 1/12;
CurrentHVA : PHVA;

VXLTurretRotation : TVector3f;

ScreenShot : TScreenShot;
VHControlType : TControlType;

LightAmb,LightDif : TVector4f;
LightGround : Boolean = False;

RebuildLists : Boolean = False;
UnitCount : Single = 1;
UnitSpace : Single = 15;

FTexture : Cardinal = 0;
FUpdateWorld : Boolean = False;

Const
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
  R : 200;
  G : 200;
  B : 200;
  ),
  ( //Orange
  R : 146;
  G : 92;
  B : 3;
  ),
  ( //Purple
  R : 137;
  G : 12;
  B : 134;
  ),
  ( //Magenta
  R : 104;
  G : 43;
  B : 73;
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

// View list is made from the list below. Easyer to make sure all views are the same in each app.
VH_Default_View = 10; // Game TS/RA2
VH_Views_No = 11;
VH_Views : array [0..VH_Views_No-1] of TVH_Views =
  (
  (
  Name       : 'Front';
  XRot       : -90;
  YRot       : -90;
  Section    : 0;
  ),
  (
  Name       : 'Back';
  XRot       : -90;
  YRot       : 90;
  Section    : 0;
  ),
  (
  Name       : 'Left';
  XRot       : -90;
  YRot       : -180;
  Section    : 1;
  ),
  (
  Name       : 'Right';
  XRot       : -90;
  YRot       : 0;
  Section    : 1;
  ),
  (
  Name       : 'Bottom';
  XRot       : 180;
  YRot       : 180;
  Section    : 2;
  ),
  (
  Name       : 'Top';
  XRot       : 0;
  YRot       : 180;
  Section    : 2;
  ),
  (
  Name       : 'Cameo1';
  XRot       : 287;
  YRot       : 225;
  Section    : 3;
  ),
  (
  Name       : 'Cameo2';
  XRot       : 287;
  YRot       : 315;
  Section    : 3;
  ),
  (
  Name       : 'Cameo3';
  XRot       : 287;
  YRot       : 255;
  Section    : 3;
  ),
  (
  Name       : 'Cameo4';
  XRot       : 287;
  YRot       : 285;
  Section    : 3;
  ),
  (
  Name       : 'Game TS/RA2';
  XRot       : 305;
  YRot       : 46;
  Depth      : -121.333297729492;
  Section    : 4;
  NotUnitRot : True;
  )
  );

light0_position:TGLArrayf4=( 5.0, 0.0, 10.0, 0.0);
ambient:  TGLArrayf4=( 0.5, 0.5, 0.5, 1);
Light0_Light:  TGLArrayf4=( 1, 1, 1, 1);
Light0_Spec:  TGLArrayf4=( 1, 0.5, 0, 0);

//var
//OGLW : TOpenGLWrapper;

Function TColorToTVector3f(Color : TColor) : TVector3f;
Function TVector3fToTColor(Vector3f : TVector3f) : TColor;
Function TColorToTVector4f(Color : TColor) : TVector4f;
Function TVector4fToTColor(Vector : TVector4f) : TColor;
Function TVector3bToTVector3f(Vector3b : TVector3b) : TVector3f;
function CleanAngle(Angle : single) : single;

implementation

Function TColorToTVector3f(Color : TColor) : TVector3f;
begin
   Result.X := GetRValue(Color) / 255;
   Result.Y := GetGValue(Color) / 255;
   Result.Z := GetBValue(Color) / 255;
end;

Function TVector3fToTColor(Vector3f : TVector3f) : TColor;
begin
   Result := RGB(trunc(Vector3f.X*255),trunc(Vector3f.Y*255),trunc(Vector3f.Z*255));
end;

Function TColorToTVector4f(Color : TColor) : TVector4f;
begin
   Result.X := GetRValue(Color) / 255;
   Result.Y := GetGValue(Color) / 255;
   Result.Z := GetBValue(Color) / 255;
   Result.W := 1;
end;

Function TVector4fToTColor(Vector : TVector4f) : TColor;
begin
   Result := RGB(trunc(Vector.X*255),trunc(Vector.Y*255),trunc(Vector.Z*255));
end;

Function TVector3bToTVector3f(Vector3b : TVector3b) : TVector3f;
begin
   Result.X := Vector3b.R/255;
   Result.Y := Vector3b.G/255;
   Result.Z := Vector3b.B/255;
end;

function CleanAngle(Angle : single) : single;
begin
   Result := Angle;

   If result < 0 then
      Result := 360 + Result;

   If result > 360 then
      Result := Result - 360;
end;

begin
   BGColor := TColorToTVector3f(RGB(40,111,162));
   FontColor := TColorToTVector3f(RGB(255,255,255));
   RemapColour := TVector3bToTVector3f(RemapColourMap[0]);

   xRot :=-90;
   yRot :=-90;
   Depth :=-60;

   FOV := 45;
   DEPTH_OF_VIEW := 4000;
   Size := 0.1;

   SpectrumMode := ModeColours;

   Default_View := VH_Default_View;

   ScreenShot._Type := 0;
   ScreenShot.CompressionRate := 1;
   ScreenShot.Width := -1;
   ScreenShot.Height := -1;
   ScreenShot.Frames := 90;
   ScreenShot.FrameAdder := 4;

   VHControlType := CTview;

   LightAmb := SetVector4f(134/255, 134/255, 134/255, 1.0);
   LightDif := SetVector4f(172/255, 172/255, 172/255, 1.0);
end.
