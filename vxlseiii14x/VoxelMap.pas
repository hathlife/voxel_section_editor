unit VoxelMap;

// This is a 3D grid that supports some interesting voxel treatment
// operations for normalizing and rendering.

// 28/01/2009: Version 1.0 by Banshee

interface

uses BasicDataTypes, Class3DPointList, Voxel, Normals, BasicConstants,
   BasicFunctions, VolumeGreyData, Dialogs, SysUtils;

{$INCLUDE Global_Conditionals.inc}

type
   TVoxelMap = class
      private
         // Variables
         //FMap : T3DSingleGrid;
         FMap: T3DVolumeGreyData;
         FBias : integer;
         FSection : TVoxelSection;
         // Constructors and Destructors
         procedure Clear;
         procedure FillMap(_Mode : integer = C_MODE_NONE; _Value : integer = C_INSIDE_VOLUME);
         procedure Initialize(_Mode : integer = C_MODE_NONE; _Value : integer = C_INSIDE_VOLUME);
         // Gets
         function GetMap(_x,_y,_z: integer): single;
         function GetMapSafe(_x,_y,_z: integer): single;
         function GetBias : integer;
         // Sets
         procedure SetMap(_x,_y,_z: integer; _value: single);
         procedure SetMapSafe(_x,_y,_z: integer; _value: single);
         procedure SetBias(_value: integer);
         // Misc
         procedure SetMapSize;
      public
         // Constructors and Destructors
         constructor Create(const _Voxel: TVoxelSection; _Bias: integer); overload;
         constructor Create(const _Voxel: TVoxelSection; _Bias: integer; _Mode: integer; _Value : integer); overload;
         constructor Create(const _Map : TVoxelMap); overload;
         procedure Reset;
         destructor Destroy; override;
         // Gets
         function GetMaxX: integer;
         function GetMaxY: integer;
         function GetMaxZ: integer;
         // Generates
         procedure GenerateVolumeMap;
         procedure GenerateInfluenceMap;
         procedure GenerateSurfaceMap;
         procedure GenerateExternalSurfaceMap;
         procedure GenerateInfluenceMapOnly;
         procedure GenerateFullMap;
         procedure GenerateSurfaceAndRefinementMap;
         // Copies
         procedure Assign(const _Map : TVoxelMap);
         function CopyMap(const _Map: T3DVolumeGreyData): T3DVolumeGreyData;
         // Misc
         procedure FloodFill(const _Point : TVector3i; _value : single);
         procedure MergeMapData(const _Source : TVoxelMap; _Data : single);
         procedure MapInfluences;
         procedure MapSurfaces(_Value: single); overload;
         procedure MapSurfaces(_Candidate,_InsideVolume,_Surface: single); overload;
         procedure MapSurfacesOnly(_Value: single);
         procedure MapExternalSurfaces(_Value: single);
         procedure MapSemiSurfaces(var _SemiSurfaces: T3DIntGrid);
         procedure MapTopologicalProblems(_Surface: single);
         procedure MapRefinementZones(_Surface: single);
         function SynchronizeWithSection(_Mode: integer; _Threshold : single): integer; overload;
         function SynchronizeWithSection(_Threshold : single): integer; overload;
         procedure ConvertValues(_Values : array of single);
         // Properties
         property Map[_x,_y,_z: integer] : single read GetMap write SetMap; default;
         property MapSafe[_x,_y,_z: integer] : single read GetMapSafe write SetMapSafe;
         property Bias: integer read GetBias write SetBias;
         function GenerateFilledDataParam(_Filled, _Unfilled: integer): integer;
         function IsPointOK (const x,y,z: integer) : boolean;
   end;
   PVoxelMap = ^TVoxelMap;

implementation

uses GlobalVars;

// Constructors and Destructors
constructor TVoxelMap.Create(const _Voxel: TVoxelSection; _Bias: Integer);
var
   Bias: longword;
begin
   FBias := _Bias;
   FSection := _Voxel;
   Bias := 2 * _Bias;
   FMap := T3DVolumeGreyData.Create(FSection.Tailer.XSize + Bias, FSection.Tailer.YSize + Bias,FSection.Tailer.ZSize + Bias);
   FillMap(C_MODE_NONE,C_INSIDE_VOLUME);
end;

constructor TVoxelMap.Create(const _Voxel: TVoxelSection; _Bias: Integer; _Mode: integer; _Value: integer);
var
   Bias: longword;
begin
   FBias := _Bias;
   FSection := _Voxel;
   Bias := 2 * _Bias;
   FMap := T3DVolumeGreyData.Create(FSection.Tailer.XSize + Bias, FSection.Tailer.YSize + Bias,FSection.Tailer.ZSize + Bias);
   FillMap(_Mode,_Value);
end;

constructor TVoxelMap.Create(const _Map : TVoxelMap);
begin
   Assign(_Map);
end;


destructor TVoxelMap.Destroy;
begin
   Clear;
   FSection := nil;
   inherited Destroy;
end;

procedure TVoxelMap.Clear;
var
   x,y : integer;
begin
   FMap.Clear;
end;

procedure TVoxelMap.FillMap(_Mode : integer = C_MODE_NONE; _Value: integer = C_INSIDE_VOLUME);
var
   x,y,z : integer;
   Filled : integer;
   Unfilled : integer;
   V : TVoxelUnpacked;
begin
   if _Mode = C_MODE_USED then
   begin
      Unfilled := _Value and $FF;
      Filled := _Value shr 8;
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  // Check if it's used.
                  if v.Used then
                  begin
                     FMap.DataUnsafe[x,y,z] := Filled;
                  end
                  else
                  begin
                     FMap.DataUnsafe[x,y,z] := Unfilled;
                  end
               end
               else
               begin
                  FMap.DataUnsafe[x,y,z] := Unfilled;
               end;
            end;
   end
   else if _Mode = C_MODE_COLOUR then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  FMap.DataUnsafe[x,y,z] := v.Colour;
               end
               else
               begin
                  FMap.DataUnsafe[x,y,z] := 0;
               end;
            end;
   end
   else if _Mode = C_MODE_NORMAL then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  FMap.DataUnsafe[x,y,z] := v.Normal;
               end
               else
               begin
                  FMap.DataUnsafe[x,y,z] := 0;
               end;
            end;
   end
   else if (_Mode <> C_MODE_NONE) then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
               FMap.DataUnsafe[x,y,z] := _Value;
   end;
end;

procedure TVoxelMap.Initialize(_Mode : integer = C_MODE_NONE; _Value : integer = C_INSIDE_VOLUME);
begin
   SetMapSize;
   FillMap(_Mode,_Value);
end;

procedure TVoxelMap.Reset;
begin
   Clear;
   Initialize(C_MODE_NONE,0);
end;

// Gets
// Note: I want something quicker than checking if every damn point is ok.
function TVoxelMap.GetMap(_x: Integer; _y: Integer; _z: Integer): single;
begin
   try
      Result := FMap.DataUnsafe[_x,_y,_z];
   except
      Result := -1;
   end;
end;

function TVoxelMap.GetMapSafe(_x: Integer; _y: Integer; _z: Integer): single;
begin
   Result := FMap[_x,_y,_z];
end;


function TVoxelMap.GetBias: integer;
begin
   Result := FBias;
end;

function TVoxelMap.GetMaxX: integer;
begin
   Result := FMap.MaxX;
end;

function TVoxelMap.GetMaxY: integer;
begin
   Result := FMap.MaxY;
end;

function TVoxelMap.GetMaxZ: integer;
begin
   Result := FMap.MaxZ;
end;


// Sets
// Note: I want something quicker than checking if every damn point is ok.
procedure TVoxelMap.SetMap(_x: Integer; _y: Integer; _z: Integer; _value: single);
begin
   try
      FMap.DataUnsafe[_x,_y,_z] := _value;
   except
      exit;
   end;
end;

procedure TVoxelMap.SetMapSafe(_x: Integer; _y: Integer; _z: Integer; _value: single);
begin
   FMap[_x,_y,_z] := _value;
end;

procedure TVoxelMap.SetBias(_value: Integer);
var
   OldMapBias, Offset: integer;
   Map : T3DVolumeGreyData;
   x, y, z: Integer;
begin
   if FBias = _Value then exit;

   OldMapBias := FBias;
   Map := CopyMap(FMap);
   FBias := _Value;
   SetMapSize;
   Offset := abs(OldMapBias - FBias);
   if OldMapBias > FBias then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               FMap.DataUnsafe[x,y,z] := Map.DataUnsafe[Offset+x,Offset+y,Offset+z];
            end;
   end
   else
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               FMap.DataUnsafe[x,y,z] := 0;
            end;
      for x := 0 to Map.MaxX do
         for y := 0 to Map.MaxY do
            for z := 0 to Map.MaxZ do
            begin
               FMap.DataUnsafe[x+Offset,y+Offset,z+Offset] := Map.DataUnsafe[x,y,z];
            end;
   end;
   // Free memory
   Map.Free;
end;

// Generates

// This procedure generates a map that specifies the voxels that are inside and
// outside the volume as 0 and 1.
procedure TVoxelMap.GenerateVolumeMap;
var
   FilledMap : TVoxelMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(C_INSIDE_VOLUME,C_OUTSIDE_VOLUME));
   FilledMap := TVoxelMap.Create(FSection,FBias,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,C_INSIDE_VOLUME));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,C_INSIDE_VOLUME);
   FilledMap.Free;
end;

procedure TVoxelMap.GenerateInfluenceMap;
var
   FilledMap : TVoxelMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(1,C_OUTSIDE_VOLUME));
   FilledMap := TVoxelMap.Create(FSection,FBias,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapInfluences;
end;

procedure TVoxelMap.GenerateSurfaceMap;
var
   FilledMap : TVoxelMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(1,C_OUTSIDE_VOLUME));
   FilledMap := TVoxelMap.Create(FSection,FBias,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapSurfaces(1);
end;

procedure TVoxelMap.GenerateExternalSurfaceMap;
var
   FilledMap : TVoxelMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(C_INSIDE_VOLUME,C_OUTSIDE_VOLUME));
   FilledMap := TVoxelMap.Create(FSection,FBias,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,C_INSIDE_VOLUME));
   FilledMap.FloodFill(SetVectorI(0,0,0),C_OUTSIDE_VOLUME);
   MergeMapData(FilledMap,C_INSIDE_VOLUME);
   FilledMap.Free;
   MapExternalSurfaces(C_OUTSIDE_VOLUME);
end;

procedure TVoxelMap.GenerateInfluenceMapOnly;
begin
   FillMap(C_MODE_All,0);
   MapInfluences;
end;


procedure TVoxelMap.GenerateFullMap;
var
   FilledMap : TVoxelMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(1,C_OUTSIDE_VOLUME));
   FilledMap := TVoxelMap.Create(FSection,FBias,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapInfluences;
   MapSurfaces(C_SURFACE);
end;

procedure TVoxelMap.GenerateSurfaceAndRefinementMap;
var
   FilledMap : TVoxelMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(511,C_OUTSIDE_VOLUME));
   FilledMap := TVoxelMap.Create(FSection,FBias,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,511));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,511);
   FilledMap.Free;
   MapSurfaces(511,1023,511);
   MapRefinementZones(511);
   //MapTopologicalProblems(511);
end;

// Copies
procedure TVoxelMap.Assign(const _Map : TVoxelMap);
var
   x, y, z: integer;
begin
   FBias := _Map.FBias;
   FSection := _Map.FSection;
   FMap := T3DVolumeGreyData.Create(_Map.FMap);
end;

function TVoxelMap.CopyMap(const _Map: T3DVolumeGreyData): T3DVolumeGreyData;
var
   x, y, z: integer;
begin
   Result := T3DVolumeGreyData.Create(_Map);
end;



// Misc
procedure TVoxelMap.SetMapSize;
var
   Bias : integer;
begin
   Bias := 2 * FBias;
   FMap.Resize(FSection.Tailer.XSize + Bias, FSection.Tailer.YSize + Bias,FSection.Tailer.ZSize + Bias);
end;

procedure TVoxelMap.FloodFill(const _Point : TVector3i; _value : single);
var
   List : C3DPointList; // Check Class3DPointList.pas;
   x,y,z : integer;
begin
   List := C3DPointList.Create;
   List.UseSmartMemoryManagement(true);
   List.Add(_Point.X,_Point.Y,_Point.Z);
   FMap[_Point.X,_Point.Y,_Point.Z] := _value;
   // It will fill the map while there are elements in the list.
   while List.GetPosition(x,y,z) do
   begin
      // Check and add the neighbours (6 faces)
      if IsPointOK(x-1,y,z) then
         if FMap.DataUnsafe[x-1,y,z] <> _value then
         begin
            FMap.DataUnsafe[x-1,y,z] := _value;
            List.Add(x-1,y,z);
         end;
      if IsPointOK(x+1,y,z) then
         if FMap.DataUnsafe[x+1,y,z] <> _value then
         begin
            FMap.DataUnsafe[x+1,y,z] := _value;
            List.Add(x+1,y,z);
         end;
      if IsPointOK(x,y-1,z) then
         if FMap.DataUnsafe[x,y-1,z] <> _value then
         begin
            FMap.DataUnsafe[x,y-1,z] := _value;
            List.Add(x,y-1,z);
         end;
      if IsPointOK(x,y+1,z) then
         if FMap.DataUnsafe[x,y+1,z] <> _value then
         begin
            FMap.DataUnsafe[x,y+1,z] := _value;
            List.Add(x,y+1,z);
         end;
      if IsPointOK(x,y,z-1) then
         if FMap.DataUnsafe[x,y,z-1] <> _value then
         begin
            FMap.DataUnsafe[x,y,z-1] := _value;
            List.Add(x,y,z-1);
         end;
      if IsPointOK(x,y,z+1) then
         if FMap.DataUnsafe[x,y,z+1] <> _value then
         begin
            FMap.DataUnsafe[x,y,z+1] := _value;
            List.Add(x,y,z+1);
         end;
   end;
   List.Free;
end;

procedure TVoxelMap.MergeMapData(const _Source : TVoxelMap; _Data : single);
var
   x,y,z : integer;
begin
   if _Source.FSection = FSection then
   begin
      // Copies every data from the source to the map.
      for x := 0 to _Source.FMap.MaxX do
         for y := 0 to _Source.FMap.MaxY do
            for z := 0 to _Source.FMap.MaxZ do
            begin
               if _Source.FMap.DataUnsafe[x,y,z] = _Data then
                  FMap.DataUnsafe[x,y,z] := _Data;
            end;
   end;
end;

procedure TVoxelMap.MapInfluences;
var
   x,y,z : integer;
   InitialPosition,FinalPosition : integer;
   V : TVoxelUnpacked;
begin
   // Scan the volume on the direction z
   for x := 0 to FMap.MaxX do
      for y := 0 to FMap.MaxY do
      begin
         // Get the initial position.
         z := 0;
         InitialPosition := -1;
         while (z <= FMap.MaxZ) and (InitialPosition = -1) do
         begin
            if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
            begin
               if v.Used then
               begin
                  InitialPosition := z;
               end;
            end;
            inc(z);
         end;
         // Get the final position, if there is a used pizel in the axis.
         if InitialPosition <> -1 then
         begin
            z := FMap.MaxZ;
            FinalPosition := -1;
            while (z >= 0) and (FinalPosition = -1) do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  if v.Used then
                  begin
                     FinalPosition := z;
                  end;
               end;
               dec(z);
            end;
            // Now we fill everything between the initial and final positions.
            z := InitialPosition;
            while z <= FinalPosition do
            begin
               FMap.DataUnsafe[x,y,z] := FMap.DataUnsafe[x,y,z] + 1;
               inc(z);
            end;
         end;
      end;

   // Scan the volume on the direction x
   for y := 0 to FMap.MaxY do
      for z := 0 to FMap.MaxZ do
      begin
         // Get the initial position.
         x := 0;
         InitialPosition := -1;
         while (x <= FMap.MaxX) and (InitialPosition = -1) do
         begin
            if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
            begin
               if v.Used then
               begin
                  InitialPosition := x;
               end;
            end;
            inc(x);
         end;
         // Get the final position, if there is a used pizel in the axis.
         if InitialPosition <> -1 then
         begin
            x := FMap.MaxX;
            FinalPosition := -1;
            while (x >= 0) and (FinalPosition = -1) do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  if v.Used then
                  begin
                     FinalPosition := x;
                  end;
               end;
               dec(x);
            end;
            // Now we fill everything between the initial and final positions.
            x := InitialPosition;
            while x <= FinalPosition do
            begin
               FMap.DataUnsafe[x,y,z] := FMap.DataUnsafe[x,y,z] + 1;
               inc(x);
            end;
         end;
      end;

   // Scan the volume on the direction y
   for x := 0 to FMap.MaxX do
      for z := 0 to FMap.MaxZ do
      begin
         // Get the initial position.
         y := 0;
         InitialPosition := -1;
         while (y <= FMap.MaxY) and (InitialPosition = -1) do
         begin
            if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
            begin
               if v.Used then
               begin
                  InitialPosition := y;
               end;
            end;
            inc(y);
         end;
         // Get the final position, if there is a used pizel in the axis.
         if InitialPosition <> -1 then
         begin
            y := FMap.MaxY;
            FinalPosition := -1;
            while (y >= 0) and (FinalPosition = -1) do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  if v.Used then
                  begin
                     FinalPosition := y;
                  end;
               end;
               dec(y);
            end;
            // Now we fill everything between the initial and final positions.
            y := InitialPosition;
            while y <= FinalPosition do
            begin
               FMap.DataUnsafe[x,y,z] := FMap.DataUnsafe[x,y,z] + 1;
               inc(y);
            end;
         end;
      end;
end;

procedure TVoxelMap.MapSurfaces(_Value: single);
var
   Cube : TNormals;
   CurrentNormal : TVector3f;
   x, y, z, i, maxi : integer;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FMap.DataUnsafe[x,y,z] = _Value then
               begin
                  i := 0;
                  while i <= maxi do
                  begin
                     CurrentNormal := Cube[i];
                     if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) >= _Value) then
                     begin
                        inc(i);
                     end
                     else
                     begin
                        // surface
                        i := maxi * 2;
                     end;
                  end;
                  if i <> (maxi * 2) then
                  begin
                     // inside the voxel
                     FMap.DataUnsafe[x,y,z] := C_INSIDE_VOLUME;
                  end
                  else // surface
                  begin
                     FMap.DataUnsafe[x,y,z] := C_SURFACE;
                  end;
               end;
            end;
   end;
   Cube.Free;
end;

procedure TVoxelMap.MapSurfaces(_Candidate,_InsideVolume,_Surface: single);
var
   Cube : TNormals;
   CurrentNormal : TVector3f;
   x, y, z, i, maxi : integer;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FMap.DataUnsafe[x,y,z] = _Candidate then
               begin
                  i := 0;
                  while i <= maxi do
                  begin
                     CurrentNormal := Cube[i];
                     if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) >= _Candidate) then
                     begin
                        inc(i);
                     end
                     else
                     begin
                        // surface
                        i := maxi * 2;
                     end;
                  end;
                  if i <> (maxi * 2) then
                  begin
                     // inside the voxel
                     FMap.DataUnsafe[x,y,z] := _InsideVolume;
                  end
                  else // surface
                  begin
                     FMap.DataUnsafe[x,y,z] := _Surface;
                  end;
               end;
            end;
   end;
   Cube.Free;
end;

procedure TVoxelMap.MapSurfacesOnly(_Value: single);
var
   Cube : TNormals;
   CurrentNormal : TVector3f;
   x, y, z, i, maxi : integer;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FMap.DataUnsafe[x,y,z] = _Value then
               begin
                  i := 0;
                  while i <= maxi do
                  begin
                     CurrentNormal := Cube[i];
                     if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) <= _Value) then
                     begin
                        inc(i);
                     end
                     else
                     begin
                        // surface
                        i := maxi * 2;
                     end;
                  end;
                  if i = (maxi * 2) then
                  begin
                     FMap.DataUnsafe[x,y,z] := C_SURFACE;
                  end;
               end;
            end;
   end;
   Cube.Free;
end;

procedure TVoxelMap.MapExternalSurfaces(_Value: single);
var
   Cube : TNormals;
   CurrentNormal : TVector3f;
   x, y, z, i, maxi : integer;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if FMap.DataUnsafe[x,y,z] = _Value then
               begin
                  i := 0;
                  while i <= maxi do
                  begin
                     CurrentNormal := Cube[i];
                     if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) <= _Value) then
                     begin
                        inc(i);
                     end
                     else
                     begin
                        // surface
                        i := maxi * 2;
                     end;
                  end;
                  if i = (maxi * 2) then
                  begin
                     FMap.DataUnsafe[x,y,z] := C_SURFACE;
                  end;
               end;
            end;
   end;
   Cube.Free;
end;

procedure TVoxelMap.MapSemiSurfaces(var _SemiSurfaces: T3DIntGrid);
const
   SSRequirements: array [0..19] of integer = (33, 17, 9, 5, 25, 41, 21, 37,
   36, 40, 24, 20, 34, 18, 10, 6, 26, 42, 22, 38);
   SSMapPointerList: array [0..19] of integer = (0, 2, 4, 6, 8, 14, 20, 26, 32,
      34, 36, 38, 40, 42, 44, 46, 48, 54, 60, 66);
   SSMapQuantList: array [0..19] of integer = (2, 2, 2, 2, 6, 6, 6, 6, 2, 2, 2,
      2, 2, 2, 2, 2, 6, 6, 6, 6);
   SSMapVertsList: array [0..71] of integer = (0, 11, 0, 15, 0, 13, 0, 9, 0,
      2, 13, 14, 3, 15, 1, 0, 12, 13, 3, 11, 4, 9, 16, 0, 2, 15, 4, 10, 9, 1, 0,
      11, 11, 9, 11, 13, 15, 13, 15, 9, 11, 17, 15, 17, 17, 13, 17, 9, 17, 19,
      13, 14, 20, 15, 18, 17, 12, 13, 20, 11, 21, 9, 16, 17, 19 , 15, 21, 10, 9,
      18, 17 , 11);
   SSMapResultsList: array [0..71] of integer = (C_SF_TOP_RIGHT_LINE,
      C_SF_BOTTOM_LEFT_LINE, C_SF_BOTTOM_RIGHT_LINE, C_SF_TOP_LEFT_LINE,
      C_SF_RIGHT_FRONT_LINE, C_SF_LEFT_BACK_LINE, C_SF_RIGHT_BACK_LINE,
      C_SF_LEFT_FRONT_LINE, C_SF_BOTTOM_FRONT_RIGHT_POINT,
      C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
      C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
      C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT,
      C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
      C_SF_TOP_BACK_LEFT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
      C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
      C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
      C_SF_TOP_BACK_RIGHT_POINT,  C_SF_TOP_BACK_LEFT_POINT,
      C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
      C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
      C_SF_TOP_BACK_RIGHT_POINT,  C_SF_BOTTOM_BACK_LEFT_POINT,
      C_SF_BOTTOM_BACK_LINE, C_SF_TOP_FRONT_LINE, C_SF_BOTTOM_FRONT_LINE,
      C_SF_TOP_BACK_LINE, C_SF_TOP_FRONT_LINE, C_SF_BOTTOM_BACK_LINE,
      C_SF_TOP_BACK_LINE, C_SF_BOTTOM_FRONT_LINE, C_SF_BOTTOM_RIGHT_LINE,
      C_SF_TOP_LEFT_LINE, C_SF_TOP_RIGHT_LINE, C_SF_BOTTOM_LEFT_LINE,
      C_SF_LEFT_FRONT_LINE, C_SF_RIGHT_BACK_LINE, C_SF_LEFT_BACK_LINE,
      C_SF_RIGHT_FRONT_LINE, C_SF_BOTTOM_FRONT_LEFT_POINT,
      C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
      C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
      C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
      C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
      C_SF_TOP_BACK_RIGHT_POINT, C_SF_TOP_BACK_LEFT_POINT,
      C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
      C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
      C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
      C_SF_TOP_BACK_RIGHT_POINT, C_SF_TOP_FRONT_LEFT_POINT,
      C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
      C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
      C_SF_BOTTOM_BACK_RIGHT_POINT);

var
   x, y, z : integer;
   CubeNeighboors : TNormals;
   FaceNeighboors : TNormals;
   CurrentNormal : TVector3f;
   CubeNormal : TVector3f;
   VertsAndEdgesNeighboors: TNormals;
   i, c, maxC, MaxFace, MaxEdge,MissingFaces: integer;
begin
   CubeNeighboors := TNormals.Create(6);
   FaceNeighboors := TNormals.Create(7);
   VertsAndEdgesNeighboors := TNormals.Create(8);
   MaxFace := FaceNeighboors.GetLastID;
   MaxEdge := VertsAndEdgesNeighboors.GetLastID;
   SetLength(_SemiSurfaces,FMap.XSize,FMap.YSize,FMap.ZSize);
   for x := 0 to FMap.MaxX do
      for y := 0 to FMap.MaxY do
         for z := 0 to FMap.MaxZ do
            _SemiSurfaces[x,y,z] := 0;
   for x := 0 to FMap.MaxX do
      for y := 0 to FMap.MaxY do
         for z := 0 to FMap.MaxZ do
         begin
            // Let's check if the surface has face neighbors
            if FMap[x,y,z] = C_SURFACE then
            begin
               MissingFaces := 0;
               i := 0;
               while (i <= MaxFace) do
               begin
                  CurrentNormal := FaceNeighboors[i];
                  if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) < C_SURFACE) then
                  begin
                     MissingFaces := MissingFaces or ($1 shl i);
                  end;
                  inc(i);
               end;
               i := 0;
               // check all non-face neighboors (8 vertices and 12 edges)
               while (i <= MaxEdge) do
               begin
                  if (MissingFaces and SSRequirements[i]) >= SSRequirements[i] then
                  begin
                     CurrentNormal := VertsAndEdgesNeighboors[i];
                     // if neighboor has content, we'll estabilish a connection in the _SemiSurfaces.
                     if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) >= C_SURFACE) then
                     begin
                        c := SSMapPointerList[i];
                        maxC := c + SSMapQuantList[i];
                        while c < maxC do
                        begin
                           CubeNormal := CubeNeighboors[SSMapVertsList[c]];
                           if FMap[x + Round(CubeNormal.X),y + Round(CubeNormal.Y),z + Round(CubeNormal.Z)] < C_SURFACE then
                           begin
                              _SemiSurfaces[x + Round(CubeNormal.X),y + Round(CubeNormal.Y),z + Round(CubeNormal.Z)] := _SemiSurfaces[x + Round(CubeNormal.X),y + Round(CubeNormal.Y),z + Round(CubeNormal.Z)] or SSMapResultsList[c];
                              FMap[x + Round(CubeNormal.X),y + Round(CubeNormal.Y),z + Round(CubeNormal.Z)] := C_SEMI_SURFACE;
                           end;
                           inc(c);
                        end;
                     end;
                  end;
                  inc(i);
               end;
            end;
         end;
   CubeNeighboors.Free;
   FaceNeighboors.Free;
   VertsAndEdgesNeighboors.Free;
end;

procedure TVoxelMap.MapTopologicalProblems(_Surface: single);
const
   CubeVertexBit: array [0..25] of byte = (15,10,5,12,3,4,8,1,2,51,34,170,136,204,68,85,17,240,160,80,192,48,64,128,16,32);
   EdgeDetectionBit: array[0..11] of longword = (513,8193,131584,139264,32769,2049,163840,133120,33280,2560,40960,10240);
   EdgeForbiddenBit: array[0..11] of longword = (16,8,2097152,1048576,4,2,524288,262144,65536,1024,16384,4096);
   EdgeVertexBit: array[0..11] of byte = (3,12,48,192,5,10,80,160,17,34,68,136);
   VertexDetectionBit: array[0..7,0..2] of longword = ((65537,516,32784),(1025,514,2064),(16385,8196,32776),(4097,2056,8194),(524800,2129920,196608),(262656,2099200,132096),(532480,1081344,147456),(1050624,270336,135168));
   VertexForbiddenBit: array[0..7,0..2] of longword = ((33428,98449,66181),(2834,3345,1795),(41004,49193,24613),(10314,12355,6217),(19103744,17498624,19431936),(35785728,33949184,35916288),(5423104,4874240,5808128),(8794112,9574400,9709568));
var
   Cube : TNormals;
   CurrentNormal : TVector3f;
   x, y, z, i, j, maxi,VertexConfig,BitValue,BitCount : integer;
   RegionBitConfig: longword;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      // Check all voxels.
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               // refinement zones are points out of the model that are close to
               // surfaces
               if FMap.DataUnsafe[x,y,z] < _Surface then
               begin
                  // Generate our bit config that we'll need to use later to find
                  // if there is any topological problem in our region.
                  i := 0;
                  RegionBitConfig := 0;
                  while i <= maxi do
                  begin
                     CurrentNormal := Cube[i];
                     // So, if the neighbour is surface, then..
                     if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) >= _Surface) then
                     begin
                        // increments the config with the neighbour config
                        RegionBitConfig := RegionBitConfig or (1 shl i);
                     end;
                     inc(i);
                  end;

                  // Verify the presence of problematic edges and fill the
                  // vertexes that belong to it.
                  i := 0;
                  VertexConfig := 0;
                  while i < 12 do
                  begin
                     if ((RegionBitConfig and EdgeDetectionBit[i]) = EdgeDetectionBit[i]) and ((RegionBitConfig and EdgeForbiddenBit[i]) = 0) then
                     begin
                        VertexConfig := VertexConfig or EdgeVertexBit[i];
                     end;
                     inc(i);
                  end;

                  // Verify the presence of problematic vertexes on the ones
                  // that are not part of the problematic edges.
                  i := 0;
                  while i < 8 do
                  begin
                     // if vertex not in VertexConfig, verify it.
                     if ((1 shl i) and VertexConfig) = 0 then
                     begin
                        // verify the 3 possible situations of vertex topological
                        // problems for each vertex:
                        j := 0;
                        while j < 3 do
                        begin
                           if ((RegionBitConfig and VertexDetectionBit[i,j]) = VertexDetectionBit[i,j]) and ((RegionBitConfig and VertexForbiddenBit[i,j]) = 0) then
                           begin
                              VertexConfig := VertexConfig or (1 shl i);
                              j := 3;
                           end;
                           inc(j);
                        end;
                     end;
                     inc(i);
                  end;

                  // The vertexes in VertexConfig are part of the final
                  // mesh, but we'll add inside vertexes that are neighbour to
                  // them.
                  BitValue := VertexConfig;
                  i := 0;
                  while i < 26 do
                  begin
                     // if region i is in the surface, then
                     if ((1 shl i) and RegionBitConfig) > 0 then
                     begin
                        // if it has one of the problematic vertexes, then
                        if CubeVertexBit[i] and VertexConfig > 0 then
                        begin
                           // increment our config with its vertexes.
                           BitValue := BitValue or CubeVertexBit[i];
                        end;
                     end;
                     inc(i);
                  end;

                  // check if it has 5 or more vertexes.
                  BitCount := 0;
                  if BitValue and 1 > 0 then
                     inc(BitCount);
                  if BitValue and 2 > 0 then
                     inc(BitCount);
                  if BitValue and 4 > 0 then
                     inc(BitCount);
                  if BitValue and 8 > 0 then
                     inc(BitCount);
                  if BitValue and 16 > 0 then
                     inc(BitCount);
                  if BitValue and 32 > 0 then
                     inc(BitCount);
                  if BitValue and 64 > 0 then
                     inc(BitCount);
                  if BitValue and 128 > 0 then
                     inc(BitCount);
                  if BitCount >= 5 then
                  begin
                     // Finally, we write the value of the refinement zone here.
                     {$ifdef MESH_TEST}
                     GlobalVars.MeshFile.Add('Interpolation Zone Location: (' + IntToStr(x-1) + ',' + IntToStr(y-1) + ',' + IntToStr(z-1) + '), config is ' + IntToStr(BitValue) + ' and in binary it is (' + IntToStr((BitValue and 128) shr 7) + ',' + IntToStr((BitValue and 64) shr 6) + ',' + IntToStr((BitValue and 32) shr 5) + ',' + IntToStr((BitValue and 16) shr 4) + ',' + IntToStr((BitValue and 8) shr 3) + ',' + IntToStr((BitValue and 4) shr 2) + ',' + IntToStr((BitValue and 2) shr 1) + ',' + IntToStr(BitValue and 1) + ').');
                     {$endif}
                     FMap.DataUnsafe[x,y,z] := BitValue;
                  end;
               end;
            end;
   end;
   Cube.Free;
end;

// Refinement zones are regions that are neighbour to two surface voxels that
// are 'linked by edge or vertex'. These zones, while considered to be out of
// the volume, they'll have part of the volume of the model, in order to avoid
// regions where the internal volume does not exist, therefore not being
// manifolds. We'll do a sort of marching cubes on these regions.
procedure TVoxelMap.MapRefinementZones(_Surface: single);
const
   CubeVertexBit: array [0..25] of byte = (15,10,5,12,3,4,8,1,2,51,34,170,136,204,68,85,17,240,160,80,192,48,64,128,16,32);
   CubeFaceBit: array[0..25] of byte = (47,45,46,39,43,38,37,42,41,59,57,61,53,55,54,62,58,31,29,30,23,27,22,21,26,25);
var
   Cube : TNormals;
   CurrentNormal : TVector3f;
   x, y, z, i, maxi,FaceConfig,bitValue,bitCount : integer;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      // Check all voxels.
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               // refinement zones are points out of the model that are close to
               // surfaces
               if FMap.DataUnsafe[x,y,z] < _Surface then
               begin
                  // verify if we have any face neighbour (which is one of the
                  // requirements of refinement zone.
                  FaceConfig := 0;
                  if (GetMapSafe(x-1,y,z) >= _Surface) then
                  begin
                     FaceConfig := FaceConfig or 32;
                  end;
                  if (GetMapSafe(x+1,y,z) >= _Surface) then
                  begin
                     FaceConfig := FaceConfig or 16;
                  end;
                  if (GetMapSafe(x,y-1,z) >= _Surface) then
                  begin
                     FaceConfig := FaceConfig or 8;
                  end;
                  if (GetMapSafe(x,y+1,z) >= _Surface) then
                  begin
                     FaceConfig := FaceConfig or 4;
                  end;
                  if (GetMapSafe(x,y,z-1) >= _Surface) then
                  begin
                     FaceConfig := FaceConfig or 2;
                  end;
                  if (GetMapSafe(x,y,z+1) >= _Surface) then
                  begin
                     FaceConfig := FaceConfig or 1;
                  end;


                  // Now we check if we have a face neighbour and if 5 vertexes
                  // are checked.
                  if FaceConfig > 0 then
                  begin
                     // Now, we really calculate the configuration of this
                     // region.

                     // Visit all neighbours and calculate a preliminary config.
                     i := 0;
                     BitValue := 0;
                     while i <= maxi do
                     begin
                        // If this neighbour is neighbour to any face that
                        // incides in this refinement zone...
                        if CubeFaceBit[i] and FaceConfig <> 0 then
                        begin
                           CurrentNormal := Cube[i];
                           // So, if the neighbour is surface, then..
                           if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) >= _Surface) then
                           begin
                              // increments the config with the neighbour config
                              BitValue := BitValue or CubeVertexBit[i];
                           end;
                        end;
                        inc(i);
                     end;
                     // check if it has 5 or more vertexes.
                     BitCount := 0;
                     if BitValue and 1 > 0 then
                        inc(BitCount);
                     if BitValue and 2 > 0 then
                        inc(BitCount);
                     if BitValue and 4 > 0 then
                        inc(BitCount);
                     if BitValue and 8 > 0 then
                        inc(BitCount);
                     if BitValue and 16 > 0 then
                        inc(BitCount);
                     if BitValue and 32 > 0 then
                        inc(BitCount);
                     if BitValue and 64 > 0 then
                        inc(BitCount);
                     if BitValue and 128 > 0 then
                        inc(BitCount);
                     if BitCount >= 5 then
                     begin
                        // Finally, we write the value of the refinement zone here.
                        {$ifdef MESH_TEST}
                        GlobalVars.MeshFile.Add('Interpolation Zone Location: (' + IntToStr(x-1) + ',' + IntToStr(y-1) + ',' + IntToStr(z-1) + '), config is ' + IntToStr(BitValue) + ' and in binary it is (' + IntToStr((BitValue and 128) shr 7) + ',' + IntToStr((BitValue and 64) shr 6) + ',' + IntToStr((BitValue and 32) shr 5) + ',' + IntToStr((BitValue and 16) shr 4) + ',' + IntToStr((BitValue and 8) shr 3) + ',' + IntToStr((BitValue and 4) shr 2) + ',' + IntToStr((BitValue and 2) shr 1) + ',' + IntToStr(BitValue and 1) + ').');
                       {$endif}
                        FMap.DataUnsafe[x,y,z] := BitValue;
                     end;
                  end;

               end;
            end;
   end;
   Cube.Free;
end;

function TVoxelMap.SynchronizeWithSection(_Mode : integer; _Threshold : single): integer;
var
   x, y, z : integer;
   V : TVoxelUnpacked;
begin
   Result := 0;
   if _MODE = C_MODE_USED then
   begin
      for x := Low(FSection.Data) to High(FSection.Data) do
         for y := Low(FSection.Data[0]) to High(FSection.Data[0]) do
            for z := Low(FSection.Data[0,0]) to High(FSection.Data[0,0]) do
            begin
               FSection.GetVoxel(x,y,z,v);
               if v.Used then
               begin
                  v.Used := (FMap.DataUnsafe[x + FBias, y + FBias, z + FBias] >= _Threshold);
                  if not v.Used then
                     inc(Result);
                  FSection.SetVoxel(x,y,z,v);
               end;
            end;
   end
   else if _MODE = C_MODE_COLOUR then
   begin
      for x := Low(FSection.Data) to High(FSection.Data) do
         for y := Low(FSection.Data[0]) to High(FSection.Data[0]) do
            for z := Low(FSection.Data[0,0]) to High(FSection.Data[0,0]) do
            begin
               FSection.GetVoxel(x,y,z,v);
               v.Colour := Round(FMap.DataUnsafe[x + FBias,y + FBias, z + FBias]);
               FSection.SetVoxel(x,y,z,v);
            end;
   end
   else if _MODE = C_MODE_NORMAL then
   begin
      for x := Low(FSection.Data) to High(FSection.Data) do
         for y := Low(FSection.Data[0]) to High(FSection.Data[0]) do
            for z := Low(FSection.Data[0,0]) to High(FSection.Data[0,0]) do
            begin
               FSection.GetVoxel(x,y,z,v);
               v.Normal := Round(FMap.DataUnsafe[x + FBias,y + FBias, z + FBias]);
               FSection.SetVoxel(x,y,z,v);
            end;
   end;
end;

function TVoxelMap.SynchronizeWithSection(_Threshold : single): integer;
begin
   Result := SynchronizeWithSection(C_MODE_USED,_Threshold);
end;

procedure TVoxelMap.ConvertValues(_Values : array of single);
var
   x, y, z : integer;
begin
   if High(_Values) >= 0 then
   begin
      for x := 0 to FMap.MaxX do
         for y := 0 to FMap.MaxY do
            for z := 0 to FMap.MaxZ do
            begin
               if (FMap.DataUnsafe[x,y,z] > 0) and (FMap.DataUnsafe[x,y,z] <= High(_Values)) then
               begin
                  FMap.DataUnsafe[x,y,z] := _Values[Round(FMap.DataUnsafe[x,y,z])];
               end;
            end;
   end;
end;


// Check if the point is valid.
function TVoxelMap.IsPointOK (const x,y,z: integer) : boolean;
begin
   result := false;
   if (x < 0) or (x > FMap.MaxX) then exit;
   if (y < 0) or (y > FMap.MaxY) then exit;
   if (z < 0) or (z > FMap.MaxZ) then exit;
   result := true;
end;

function TVoxelMap.GenerateFilledDataParam(_Filled: Integer; _Unfilled: Integer): integer;
begin
   Result := (_Filled shl 8) + _Unfilled;
end;


end.
