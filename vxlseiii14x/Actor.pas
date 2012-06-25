unit Actor;

interface

uses Voxel_engine, BasicDataTypes, math3d, math, dglOpenGL, Model, Voxel, HVA,
   Palette, Graphics, Windows, GLConstants, ShaderBank,Histogram;

type
   PActor = ^TActor;
   TActor = class
   private
      // For the renderer
      RequestUpdateWorld: boolean;
      procedure QuickSwitchModels(_m1, _m2: integer);
      procedure CommonAddActions;
   public
      // List
      Next : PActor;
      // Atributes
      Models : array of PModel;
      // Animation
      Frame: integer;
      // physics cinematics.
      PositionAcceleration : TVector3f;
      RotationAcceleration : TVector3f;
      PositionSpeed : TVector3f;   // Move for the next frame.
      RotationSpeed : TVector3f;
      Position : TVector3f;
      Rotation : TVector3f;
      // User interface
      IsSelected : boolean;
      ColoursType : byte;
      FactionColour: TColor;
      // Others
      ShaderBank : PShaderBank;
      // Constructors
      constructor Create(_ShaderBank : PShaderBank);
      destructor Destroy; override;
      procedure Clear;
      procedure Reset;
      // I/O
      procedure SaveToFile(const _Filename,_TexExt: string; _ModelID: integer);
       // Execution
      procedure Render(var _PolyCount,_VoxelCount: longword);
      procedure RenderVectorial();
      procedure RotateActor;
      procedure MoveActor;
      procedure ProcessNextFrame;
      procedure RebuildActor;
      procedure RebuildCurrentMeshes;
      procedure Refresh;
      // Gets
      function GetRequestUpdateWorld: boolean;
      // Sets
      procedure SetPosition(_x, _y, _z: single); overload;
      procedure SetPosition(_Vector: TVector3f); overload;
      procedure SetRotation(_x, _y, _z: single); overload;
      procedure SetRotation(_Vector: TVector3f); overload;
      procedure SetPositionSpeed(_x, _y, _z: single); overload;
      procedure SetPositionSpeed(_Vector: TVector3f); overload;
      procedure SetRotationSpeed(_x, _y, _z: single); overload;
      procedure SetRotationSpeed(_Vector: TVector3f); overload;
      procedure SetPositionAcceleration(_x, _y, _z: single); overload;
      procedure SetPositionAcceleration(_Vector: TVector3f); overload;
      procedure SetRotationAcceleration(_x, _y, _z: single); overload;
      procedure SetRotationAcceleration(_Vector: TVector3f); overload;
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      procedure SetQuality(_value: integer);
       // Adds
      procedure Add(const _filename: string); overload;
      procedure Add(const _Model: PModel); overload;
      procedure Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _Quality: integer = C_QUALITY_CUBED); overload;
      procedure Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _Quality: integer = C_QUALITY_CUBED); overload;
      procedure AddReadOnly(const _filename: string); overload;
      procedure AddReadOnly(const _Model: PModel); overload;
      procedure AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _Quality: integer = C_QUALITY_CUBED); overload;
      procedure AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _Quality: integer = C_QUALITY_CUBED); overload;
      procedure Clone(const _filename: string); overload;
      procedure Clone(const _Model: PModel); overload;
      procedure Clone(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _Quality: integer = C_QUALITY_CUBED); overload;
      procedure Clone(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _Quality: integer = C_QUALITY_CUBED); overload;
      // Removes
      procedure Remove(var _Model : PModel);
      // switches
      procedure SwitchModels(_m1, _m2: integer);
      // Palette related
      procedure ChangeRemappable (_Colour : TColor); overload;
      procedure ChangeRemappable (_r,_g,_b : byte); overload;
      procedure ChangePalette (const _Filename: string);
      // Actor Effects
      procedure SmoothModel;
      procedure QuadricSmoothModel;
      procedure CubicSmoothModel;
      procedure LanczosSmoothModel;
      procedure SincSmoothModel;
      procedure EulerSmoothModel;
      procedure EulerSquaredSmoothModel;
      procedure SincInfiniteSmoothModel;
      procedure SmoothModel2;
      procedure QuadricSmoothModel2;
      procedure CubicSmoothModel2;
      procedure LanczosSmoothModel2;
      procedure SincSmoothModel2;
      procedure EulerSmoothModel2;
      procedure EulerSquaredSmoothModel2;
      procedure SincInfiniteSmoothModel2;
      procedure GaussianSmoothModel;
      procedure UnsharpModel;
      procedure InflateModel;
      procedure DeflateModel;
      // Colour Effects
      procedure ColourSmoothModel;
      procedure ColourCubicSmoothModel;
      procedure ColourLanczosSmoothModel;
      procedure ConvertVertexToFaceColours;
      procedure ConvertFaceToVertexColours;
      procedure ConvertFaceToVertexColoursLinear;
      procedure ConvertFaceToVertexColoursCubic;
      procedure ConvertFaceToVertexColoursLanczos;
      // Normals
      procedure ReNormalizeModel;
      procedure ConvertFaceToVertexNormals;
      procedure NormalSmoothModel;
      procedure NormalLinearSmoothModel;
      procedure NormalCubicSmoothModel;
      procedure NormalLanczosSmoothModel;
      // Textures
      procedure GenerateDiffuseTexture; overload;
      procedure GenerateDiffuseTexture(_Angle: single; _Size: integer); overload;
      procedure ExportTextures(const _BaseDir, _Ext: string; _previewTextures: boolean);
      procedure ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
      procedure GenerateNormalMapTexture;
      procedure GenerateBumpMapTexture; overload;
      procedure GenerateBumpMapTexture(_Scale: single); overload;
      procedure SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _ModelID,_MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _ModelID,_MeshID: integer);
      // Mesh Operations
      procedure RemoveInvisibleFaces;
      procedure OptimizeMeshMaxQuality;
      procedure OptimizeMeshMaxQualityIgnoreColours;
      procedure OptimizeMesh(_QualityLoss: single; _IgnoreColours: boolean);
      procedure ConvertQuadsToTris;
      procedure ConvertQuadsTo48Tris;
      // Quality Assurance
      function GetAspectRatioHistogram(): THistogram;
      function GetSkewnessHistogram(): THistogram;
      function GetSmoothnessHistogram(): THistogram;
      // Mesh Plugins
      procedure AddNormalsPlugin;
      procedure RemoveNormalsPlugin;
   end;

implementation

uses GlobalVars;

constructor TActor.Create(_ShaderBank : PShaderBank);
begin
   Next := nil;
   ShaderBank := _ShaderBank;
   IsSelected := false;
   SetLength(Models,0);
   RequestUpdateWorld := false;
   ColoursType := 1;
   FactionColour := $000000FF;
   Reset;
end;

destructor TActor.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TActor.Clear;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         ModelBank.Delete(Models[i]);
      end;
   end;
   SetLength(Models,0);
   RequestUpdateWorld := true;
end;

procedure TActor.Reset;
begin
   Frame := 0;
   Rotation.X := 0;
   Rotation.Y := 0;
   Rotation.Z := 0;
   Position.X := 0;
   Position.Y := 0;
   Position.Z := 0;
   PositionSpeed := SetVector(0,0,0);
   RotationSpeed := SetVector(0,0,0);
   PositionAcceleration := SetVector(0,0,0);
   RotationAcceleration := SetVector(0,0,0);
end;

// I/O
procedure TActor.SaveToFile(const _Filename,_TexExt: string; _ModelID: integer);
begin
   ModelBank.Save(Models[_ModelID],_Filename, _TexExt);
end;

procedure TActor.Render(var _PolyCount,_VoxelCount: longword);
var
   i : integer;
begin
   glPushMatrix;
      MoveActor;
      RotateActor;
      for i := Low(Models) to High(Models) do
      begin
         if Models[i] <> nil then
         begin
            Models[i]^.Render(_PolyCount,_VoxelCount,Frame);
         end;
      end;
   glPopMatrix;
end;

procedure TActor.RenderVectorial();
var
   i : integer;
begin
   glPushMatrix;
      MoveActor;
      RotateActor;
      for i := Low(Models) to High(Models) do
      begin
         if Models[i] <> nil then
         begin
            Models[i]^.RenderVectorial(Frame);
         end;
      end;
   glPopMatrix;
end;

procedure TActor.RotateActor;
begin
   glRotatef(Rotation.X, 1, 0, 0);
   glRotatef(Rotation.Y, 0, 1, 0);
   glRotatef(Rotation.Z, 0, 0, 1);
end;

procedure TActor.MoveActor;
begin
   glTranslatef(Position.X, Position.Y, Position.Z);
end;

procedure TActor.ProcessNextFrame;
var
   Signal : integer;
begin
   // Process acceleration.
   Signal := Sign(PositionSpeed.X);
   PositionSpeed.X := PositionSpeed.X + PositionAcceleration.X;
   if Signal <> Sign(PositionSpeed.X) then
      PositionSpeed.X := 0;
   Signal := Sign(PositionSpeed.Y);
   PositionSpeed.Y := PositionSpeed.Y + PositionAcceleration.Y;
   if Signal <> Sign(PositionSpeed.Y) then
      PositionSpeed.Y := 0;
   Signal := Sign(PositionSpeed.Z);
   PositionSpeed.Z := PositionSpeed.Z + PositionAcceleration.Z;
   if Signal <> Sign(PositionSpeed.Z) then
      PositionSpeed.Z := 0;
   Signal := Sign(RotationSpeed.X);
   RotationSpeed.X := RotationSpeed.X + RotationAcceleration.X;
   if Signal <> Sign(RotationSpeed.X) then
      RotationSpeed.X := 0;
   Signal := Sign(RotationSpeed.Y);
   RotationSpeed.Y := RotationSpeed.Y + RotationAcceleration.Y;
   if Signal <> Sign(RotationSpeed.Y) then
      RotationSpeed.Y := 0;
   Signal := Sign(RotationSpeed.Z);
   RotationSpeed.Z := RotationSpeed.Z + RotationAcceleration.Z;
   if Signal <> Sign(RotationSpeed.Z) then
      RotationSpeed.Z := 0;

   // Process position and angle
   Position.X := Position.X + PositionSpeed.X;
   Position.Y := Position.Y + PositionSpeed.Y;
   Position.Z := Position.Z + PositionSpeed.Z;
   Rotation.X := CleanAngle(Rotation.X + RotationSpeed.X);
   Rotation.Y := CleanAngle(Rotation.Y + RotationSpeed.Y);
   Rotation.Z := CleanAngle(Rotation.Z + RotationSpeed.Z);

   // update request world update.
   RequestUpdateWorld := RequestUpdateWorld or (PositionSpeed.X <> 0) or (PositionSpeed.Y <> 0) or (PositionSpeed.Z <> 0) or (RotationSpeed.X <> 0) or (RotationSpeed.Y <> 0) or (RotationSpeed.Z <> 0);
end;

procedure TActor.RebuildActor;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.RebuildModel;
         Models[i]^.ChangeRemappable(FactionColour);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.RebuildCurrentMeshes;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.RebuildCurrentLOD;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.Refresh;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.RefreshModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

// Gets
function TActor.GetRequestUpdateWorld: boolean;
begin
   Result := RequestUpdateWorld;
   RequestUpdateWorld := false;
end;

// Sets
procedure TActor.SetPosition(_x, _y, _z: single);
begin
   Position.X := _x;
   Position.Y := _y;
   Position.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetPosition(_Vector: TVector3f);
begin
   Position.X := _Vector.X;
   Position.Y := _Vector.Y;
   Position.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetRotation(_x, _y, _z: single);
begin
   Rotation.X := _x;
   Rotation.Y := _y;
   Rotation.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetRotation(_Vector: TVector3f);
begin
   Rotation.X := _Vector.X;
   Rotation.Y := _Vector.Y;
   Rotation.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetPositionSpeed(_x, _y, _z: single);
begin
   PositionSpeed.X := _x;
   PositionSpeed.Y := _y;
   PositionSpeed.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetPositionSpeed(_Vector: TVector3f);
begin
   PositionSpeed.X := _Vector.X;
   PositionSpeed.Y := _Vector.Y;
   PositionSpeed.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetRotationSpeed(_x, _y, _z: single);
begin
   RotationSpeed.X := _x;
   RotationSpeed.Y := _y;
   RotationSpeed.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetRotationSpeed(_Vector: TVector3f);
begin
   RotationSpeed.X := _Vector.X;
   RotationSpeed.Y := _Vector.Y;
   RotationSpeed.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetPositionAcceleration(_x, _y, _z: single);
begin
   PositionAcceleration.X := _x;
   PositionAcceleration.Y := _y;
   PositionAcceleration.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetPositionAcceleration(_Vector: TVector3f);
begin
   PositionAcceleration.X := _Vector.X;
   PositionAcceleration.Y := _Vector.Y;
   PositionAcceleration.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetRotationAcceleration(_x, _y, _z: single);
begin
   RotationAcceleration.X := _x;
   RotationAcceleration.Y := _y;
   RotationAcceleration.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetRotationAcceleration(_Vector: TVector3f);
begin
   RotationAcceleration.X := _Vector.X;
   RotationAcceleration.Y := _Vector.Y;
   RotationAcceleration.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TActor.SetNormalsModeRendering;
var
   i : integer;
begin
   ColoursType := C_COLOURS_DISABLED;
   if High(Models) >= 0 then
   begin
      for i := Low(Models) to High(Models) do
      begin
         if Models[i] <> nil then
         begin
            Models[i]^.SetNormalsModeRendering;
         end;
      end;
      RequestUpdateWorld := true;
   end;
end;

procedure TActor.SetColourModeRendering;
var
   i : integer;
begin
   ColoursType := 1;
   if High(Models) >= 0 then
   begin
      for i := Low(Models) to High(Models) do
      begin
         if Models[i] <> nil then
         begin
            Models[i]^.SetColourModeRendering;
         end;
      end;
      RequestUpdateWorld := true;
   end;
end;

procedure TActor.SetQuality(_value: integer);
var
   i : integer;
begin
   if High(Models) >= 0 then
   begin
      for i := Low(Models) to High(Models) do
      begin
         if Models[i] <> nil then
         begin
            Models[i]^.SetQuality(_value);
         end;
      end;
      RequestUpdateWorld := true;
   end;
end;


// Adds
procedure TActor.Add(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_filename,ShaderBank);
   CommonAddActions;
end;

procedure TActor.Add(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_Model);
   CommonAddActions;
end;

procedure TActor.Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _Quality: integer);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_Voxel,_HVA,_Palette,ShaderBank,_Quality);
   CommonAddActions;
end;

procedure TActor.Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _Quality: integer);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_VoxelSection,_Palette,ShaderBank,_Quality);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_filename,ShaderBank);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_Model);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _Quality: integer);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_Voxel,_HVA,_Palette,ShaderBank,_Quality);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _Quality: integer);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_VoxelSection,_Palette,ShaderBank,_Quality);
   CommonAddActions;
end;

procedure TActor.Clone(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Clone(_filename,ShaderBank);
   CommonAddActions;
end;

procedure TActor.Clone(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Clone(_Model);
   CommonAddActions;
end;

procedure TActor.Clone(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _Quality: integer);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Clone(_Voxel,_HVA,_Palette,ShaderBank,_Quality);
   CommonAddActions;
end;

procedure TActor.Clone(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _Quality: integer);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_VoxelSection,_Palette,ShaderBank,_Quality);
   CommonAddActions;
end;

procedure TActor.CommonAddActions;
begin
   if ColoursType =  C_COLOURS_DISABLED then
   begin
      SetNormalsModeRendering;
   end
   else
   begin
      SetColourModeRendering;
   end;
   RequestUpdateWorld := true;
end;

// Removes
procedure TActor.Remove(var _Model : PModel);
var
   i : integer;
begin
   i := Low(Models);
   while i <= High(Models) do
   begin
      if Models[i] = _Model then
      begin
         ModelBank.Delete(_Model);
         while i < High(Models) do
         begin
            QuickSwitchModels(i,i+1);
            inc(i);
         end;
         SetLength(Models,High(Models));
         RequestUpdateWorld := true;
         exit;
      end;
      inc(i);
   end;
end;


// Switches
procedure TActor.SwitchModels(_m1, _m2: integer);
begin
   if (_m1 <= High(Models)) and (_m1 > Low(Models)) then
      if (_m2 <= High(Models)) and (_m2 > Low(Models)) then
         QuickSwitchModels(_m1, _m2);
end;

procedure TActor.QuickSwitchModels(_m1, _m2: integer);
var
   temp : PModel;
begin
   Temp := Models[_m1];
   Models[_m1] := Models[_m2];
   Models[_m2] := temp;
end;

// Palette Related
procedure TActor.ChangeRemappable(_Colour: TColor);
var
   i : integer;
begin
   FactionColour := _Colour;
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i].ChangeRemappable(FactionColour);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ChangeRemappable (_r,_g,_b : byte);
begin
   ChangeRemappable(RGB(_r,_g,_b));
end;

procedure TActor.ChangePalette (const _Filename: string);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ChangePalette(_Filename);
         Models[i]^.ChangeRemappable(FactionColour);
      end;
   end;
   RequestUpdateWorld := true;
end;

// Actor Effects
procedure TActor.SmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.QuadricSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.QuadricSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.CubicSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.CubicSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.LanczosSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.LanczosSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.SincSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SincSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.EulerSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.EulerSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.EulerSquaredSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.EulerSquaredSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.SincInfiniteSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SincInfiniteSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.SmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.QuadricSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.QuadricSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.CubicSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.CubicSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.LanczosSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.LanczosSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.SincSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SincSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.EulerSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.EulerSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.EulerSquaredSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.EulerSquaredSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.SincInfiniteSmoothModel2;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SincInfiniteSmoothModel2;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.GaussianSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.GaussianSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.UnsharpModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.UnsharpModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.InflateModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.InflateModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.DeflateModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.DeflateModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

// Colour Effects
procedure TActor.ColourSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ColourSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ColourCubicSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ColourCubicSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ColourLanczosSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ColourLanczosSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertVertexToFaceColours;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertVertexToFaceColours;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertFaceToVertexColours;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertFaceToVertexColours;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertFaceToVertexColoursLinear;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertFaceToVertexColoursLinear;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertFaceToVertexColoursCubic;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertFaceToVertexColoursCubic;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertFaceToVertexColoursLanczos;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertFaceToVertexColoursLanczos;
      end;
   end;
   RequestUpdateWorld := true;
end;


// Normals
procedure TActor.ReNormalizeModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ReNormalizeModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertFaceToVertexNormals;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertFaceToVertexNormals;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.NormalSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.NormalSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.NormalLinearSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.NormalLinearSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.NormalCubicSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.NormalCubicSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.NormalLanczosSmoothModel;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.NormalLanczosSmoothModel;
      end;
   end;
   RequestUpdateWorld := true;
end;

// Textures
procedure TActor.GenerateDiffuseTexture;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ExtractTextureAtlas;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.GenerateNormalMapTexture;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.GenerateNormalMapTexture;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.GenerateBumpMapTexture;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.GenerateBumpMapTexture;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.GenerateBumpMapTexture(_Scale: single);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.GenerateBumpMapTexture(_Scale);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.SetTextureNumMipMaps(_NumMipMaps,_TextureType);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.GenerateDiffuseTexture(_Angle: single; _Size: integer);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ExtractTextureAtlas(_Angle, _Size);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ExportTextures(const _BaseDir, _Ext: string; _previewTextures: boolean);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ExportTextures(_BaseDir,_Ext,_previewTextures);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ExportHeightMap(const _BaseDir, _Ext: string; _previewTextures: boolean);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ExportHeightMap(_BaseDir,_Ext,_previewTextures);
      end;
   end;
   RequestUpdateWorld := true;
end;

// Transparency methods
procedure TActor.ForceTransparency(_level: single);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ForceTransparency(_level);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ForceTransparencyOnMesh(_Level: single; _ModelID,_MeshID: integer);
begin
   if Models[_ModelID] <> nil then
   begin
      Models[_ModelID]^.ForceTransparencyOnMesh(_Level,_MeshID);
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ForceTransparencyExceptOnAMesh(_Level: single; _ModelID,_MeshID: integer);
begin
   if Models[_ModelID] <> nil then
   begin
      Models[_ModelID]^.ForceTransparencyExceptOnAMesh(_Level,_MeshID);
   end;
   RequestUpdateWorld := true;
end;

// Mesh Operations
procedure TActor.RemoveInvisibleFaces;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.RemoveInvisibleFaces;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.OptimizeMeshMaxQuality;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.OptimizeMeshMaxQuality;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.OptimizeMeshMaxQualityIgnoreColours;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.OptimizeMeshMaxQualityIgnoreColours;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.OptimizeMesh(_QualityLoss: single; _IgnoreColours: boolean);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.OptimizeMesh(_QualityLoss,_IgnoreColours);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertQuadsToTris;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertQuadsToTris;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ConvertQuadsTo48Tris;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.ConvertQuadsTo48Tris;
      end;
   end;
   RequestUpdateWorld := true;
end;

// Quality Assurance
function TActor.GetAspectRatioHistogram(): THistogram;
var
   i : integer;
begin
   Result := THistogram.Create;
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.FillAspectRatioHistogram(Result);
      end;
   end;
end;

function TActor.GetSkewnessHistogram(): THistogram;
var
   i : integer;
begin
   Result := THistogram.Create;
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.FillSkewnessHistogram(Result);
      end;
   end;
end;

function TActor.GetSmoothnessHistogram(): THistogram;
var
   i : integer;
begin
   Result := THistogram.Create;
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.FillSmoothnessHistogram(Result);
      end;
   end;
end;

// Mesh Plugins
procedure TActor.AddNormalsPlugin;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.AddNormalsPlugin;
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.RemoveNormalsPlugin;
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i]^.RemoveNormalsPlugin;
      end;
   end;
   RequestUpdateWorld := true;
end;


end.
