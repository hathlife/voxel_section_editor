unit Actor;

interface

uses Voxel_engine, BasicDataTypes, math3d, math, dglOpenGL, Model, Voxel, HVA,
   Palette, Graphics, Windows, GLConstants;

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
      // Constructors
      constructor Create;
      destructor Destroy; override;
      procedure Clear;
      procedure Reset;
       // Execution
      procedure Render(var _PolyCount: longword);
      procedure RotateActor;
      procedure MoveActor;
      procedure ProcessNextFrame;
      procedure RebuildActor;
      procedure RebuildCurrentMeshes;
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
       // Adds
      procedure Add(const _filename: string); overload;
      procedure Add(const _Model: PModel); overload;
      procedure Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: boolean = false); overload;
      procedure Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: boolean = false); overload;
      procedure AddReadOnly(const _filename: string); overload;
      procedure AddReadOnly(const _Model: PModel); overload;
      procedure AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: boolean = false); overload;
      procedure AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: boolean = false); overload;
      // Removes
      procedure Remove(var _Model : PModel);
      // switches
      procedure SwitchModels(_m1, _m2: integer);
      // remappable
      procedure ChangeRemappable (_Colour : TColor); overload;
      procedure ChangeRemappable (_r,_g,_b : byte); overload;
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _ModelID,_MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _ModelID,_MeshID: integer);
   end;

implementation

uses GlobalVars;

constructor TActor.Create;
begin
   Next := nil;
   IsSelected := false;
   SetLength(Models,0);
   RequestUpdateWorld := false;
   ColoursType := 1;
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
   Rotation.X := 0;
   Rotation.Y := 0;
   Rotation.Z := 0;
   Position.X := 0;
   Position.Y := 0;
   Position.Z := -30;
   PositionSpeed := SetVector(0,0,0);
   RotationSpeed := SetVector(0,0,0);
   PositionAcceleration := SetVector(0,0,0);
   RotationAcceleration := SetVector(0,0,0);
end;

procedure TActor.Render(var _PolyCount: longword);
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
            Models[i]^.Render(_PolyCount);
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
   if (PositionSpeed.X <> 0) or (PositionSpeed.Y <> 0) or (PositionSpeed.Z <> 0)  then
      RequestUpdateWorld := true;
   if (RotationSpeed.X <> 0) or (RotationSpeed.Y <> 0) or (RotationSpeed.Z <> 0)  then
      RequestUpdateWorld := true;

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


// Adds
procedure TActor.Add(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_filename);
   CommonAddActions;
end;

procedure TActor.Add(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_Model);
   CommonAddActions;
end;

procedure TActor.Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_Voxel,_HVA,_Palette,_HighQuality);
   CommonAddActions;
end;

procedure TActor.Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_VoxelSection,_Palette,_HighQuality);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_filename);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_Model);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_Voxel,_HVA,_Palette,_HighQuality);
   CommonAddActions;
end;

procedure TActor.AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_VoxelSection,_Palette,_HighQuality);
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

// Remappable
procedure TActor.ChangeRemappable(_Colour: TColor);
var
   i : integer;
begin
   for i := Low(Models) to High(Models) do
   begin
      if Models[i] <> nil then
      begin
         Models[i].ChangeRemappable(_Colour);
      end;
   end;
   RequestUpdateWorld := true;
end;

procedure TActor.ChangeRemappable (_r,_g,_b : byte);
begin
   ChangeRemappable(RGB(_r,_g,_b));
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
end;

procedure TActor.ForceTransparencyOnMesh(_Level: single; _ModelID,_MeshID: integer);
begin
   if Models[_ModelID] <> nil then
   begin
      Models[_ModelID]^.ForceTransparencyOnMesh(_Level,_MeshID);
   end;
end;

procedure TActor.ForceTransparencyExceptOnAMesh(_Level: single; _ModelID,_MeshID: integer);
begin
   if Models[_ModelID] <> nil then
   begin
      Models[_ModelID]^.ForceTransparencyExceptOnAMesh(_Level,_MeshID);
   end;
end;

end.
