unit Actor;

interface

uses Voxel_engine, BasicDataTypes, math3d, math, dglOpenGL, Model, Voxel, HVA,
   Palette;

type
   PActor = ^TActor;
   TActor = class
   private
      procedure QuickSwitchModels(_m1, _m2: integer);
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
   end;

implementation

uses GlobalVars;

constructor TActor.Create;
begin
   Next := nil;
   IsSelected := false;
   SetLength(Models,0);
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
end;

procedure TActor.Reset;
begin
   Rotation.X := -90;
   Rotation.Y := 0;
   Rotation.Z := -85;
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
   ProcessNextFrame;
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
end;

// Adds
procedure TActor.Add(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_filename);
end;

procedure TActor.Add(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_Model);
end;

procedure TActor.Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_Voxel,_HVA,_Palette,_HighQuality);
end;

procedure TActor.Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.Add(_VoxelSection,_Palette,_HighQuality);
end;

procedure TActor.AddReadOnly(const _filename: string);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_filename);
end;

procedure TActor.AddReadOnly(const _Model: PModel);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_Model);
end;

procedure TActor.AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_Voxel,_HVA,_Palette,_HighQuality);
end;

procedure TActor.AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: Boolean);
begin
   SetLength(Models,High(Models)+2);
   Models[High(Models)] := ModelBank.AddReadOnly(_VoxelSection,_Palette,_HighQuality);
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



end.
