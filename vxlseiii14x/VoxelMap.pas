unit VoxelMap;

// This is a 3D grid that supports some interesting voxel treatment
// operations for normalizing and rendering.

// 28/01/2009: Version 1.0 by Banshee

interface

uses BasicDataTypes, Class3DPointList, Voxel, Voxel_Engine, Normals, BasicConstants;

type
   TVoxelMap = class
      private
         // Variables
         FMap : T3DSingleGrid;
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
         procedure GenerateInfluenceMapOnly;
         procedure GenerateFullMap;
         // Copies
         procedure Assign(const _Map : TVoxelMap);
         function CopyMap(const _Map: T3DSingleGrid): T3DSingleGrid;
         // Misc
         procedure FloodFill(const _Point : TVector3i; _value : single);
         procedure MergeMapData(const _Source : TVoxelMap; _Data : single);
         procedure MapInfluences;
         procedure MapSurfaces(_Value: single);
         procedure MapSurfacesOnly(_Value: single);
         procedure MapSemiSurfaces(var _SemiSurfaces: T3DIntGrid);
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

// Constructors and Destructors
constructor TVoxelMap.Create(const _Voxel: TVoxelSection; _Bias: Integer);
begin
   FBias := _Bias;
   FSection := _Voxel;
   Initialize(C_MODE_NONE);
end;

constructor TVoxelMap.Create(const _Voxel: TVoxelSection; _Bias: Integer; _Mode: integer; _Value: integer);
begin
   FBias := _Bias;
   FSection := _Voxel;
   Initialize(_Mode,_Value);
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
   for x := High(FMap) downto Low(FMap) do
   begin
      for y := High(FMap[x]) downto Low(FMap[x]) do
      begin
         SetLength(FMap[x,y],0);
      end;
      SetLength(FMap[x],0);
   end;
   SetLength(FMap,0,0,0);
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
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  // Check if it's used.
                  if v.Used then
                  begin
                     FMap[x,y,z] := Filled;
                  end
                  else
                  begin
                     FMap[x,y,z] := Unfilled;
                  end
               end
               else
               begin
                  FMap[x,y,z] := Unfilled;
               end;
            end;
   end
   else if _Mode = C_MODE_COLOUR then
   begin
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  FMap[x,y,z] := v.Colour;
               end
               else
               begin
                  FMap[x,y,z] := 0;
               end;
            end;
   end
   else if _Mode = C_MODE_NORMAL then
   begin
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if FSection.GetVoxelSafe(x-FBias,y-FBias,z-FBias,v) then
               begin
                  FMap[x,y,z] := v.Normal;
               end
               else
               begin
                  FMap[x,y,z] := 0;
               end;
            end;
   end
   else if (_Mode <> C_MODE_NONE) then
   begin
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
               FMap[x,y,z] := _Value;
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
   Initialize(C_MODE_ALL,0);
end;

// Gets
// Note: I want something quicker than checking if every damn point is ok.
function TVoxelMap.GetMap(_x: Integer; _y: Integer; _z: Integer): single;
begin
   try
      Result := FMap[_x,_y,_z];
   except
      Result := -1;
   end;
end;

function TVoxelMap.GetMapSafe(_x: Integer; _y: Integer; _z: Integer): single;
begin
   if IsPointOK(_x,_y,_z) then
   begin
      Result := FMap[_x,_y,_z];
   end
   else
   begin
      Result := -1;
   end;
end;


function TVoxelMap.GetBias: integer;
begin
   Result := FBias;
end;

function TVoxelMap.GetMaxX: integer;
begin
   Result := High(FMap);
end;

function TVoxelMap.GetMaxY: integer;
begin
   Result := High(FMap[0]);
end;

function TVoxelMap.GetMaxZ: integer;
begin
   Result := High(FMap[0,0]);
end;


// Sets
// Note: I want something quicker than checking if every damn point is ok.
procedure TVoxelMap.SetMap(_x: Integer; _y: Integer; _z: Integer; _value: single);
begin
   try
      FMap[_x,_y,_z] := _value;
   except
      exit;
   end;
end;

procedure TVoxelMap.SetMapSafe(_x: Integer; _y: Integer; _z: Integer; _value: single);
begin
   if IsPointOK(_x,_y,_z) then
   begin
      FMap[_x,_y,_z] := _value;
   end;
end;

procedure TVoxelMap.SetBias(_value: Integer);
var
   OldMapBias, Offset: integer;
   Map : T3DSingleGrid;
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
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[x]) to High(FMap[x]) do
            for z := Low(FMap[x,y]) to High(FMap[x,y]) do
            begin
               FMap[x,y,z] := Map[Offset+x,Offset+y,Offset+z];
            end;
   end
   else
   begin
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[x]) to High(FMap[x]) do
            for z := Low(FMap[x,y]) to High(FMap[x,y]) do
            begin
               FMap[x,y,z] := 0;
            end;
      for x := Low(Map) to High(Map) do
         for y := Low(Map[x]) to High(Map[x]) do
            for z := Low(Map[x,y]) to High(Map[x,y]) do
            begin
               FMap[x+Offset,y+Offset,z+Offset] := Map[x,y,z];
            end;
   end;
   // Free memory
   for x := High(Map) downto Low(Map) do
   begin
      for y := High(Map[x]) downto Low(Map[x]) do
      begin
         SetLength(Map[x,y],0);
      end;
      SetLength(Map[x],0);
   end;
   SetLength(Map,0);
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


// Copies
procedure TVoxelMap.Assign(const _Map : TVoxelMap);
var
   x, y, z: integer;
begin
   FBias := _Map.FBias;
   FSection := _Map.FSection;
   SetMapSize;
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[0]) to High(FMap[0]) do
         for z := Low(FMap[0,0]) to High(FMap[0,0]) do
         begin
            FMap[x,y,z] := _Map.FMap[x,y,z];
         end;
end;

function TVoxelMap.CopyMap(const _Map: T3DSingleGrid): T3DSingleGrid;
var
   x, y, z: integer;
begin
   SetLength(Result,High(_Map)+1,High(_Map[0])+1,High(_Map[0,0])+1);
   for x := Low(_Map) to High(_Map) do
      for y := Low(_Map[0]) to High(_Map[0]) do
         for z := Low(_Map[0,0]) to High(_Map[0,0]) do
         begin
            Result[x,y,z] := _Map[x,y,z];
         end;
end;



// Misc
procedure TVoxelMap.SetMapSize;
var
   Bias : integer;
begin
   Bias := 2 * FBias;
   SetLength(FMap, FSection.Tailer.XSize + Bias, FSection.Tailer.YSize + Bias, FSection.Tailer.ZSize + Bias);
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
         if FMap[x-1,y,z] <> _value then
         begin
            FMap[x-1,y,z] := _value;
            List.Add(x-1,y,z);
         end;
      if IsPointOK(x+1,y,z) then
         if FMap[x+1,y,z] <> _value then
         begin
            FMap[x+1,y,z] := _value;
            List.Add(x+1,y,z);
         end;
      if IsPointOK(x,y-1,z) then
         if FMap[x,y-1,z] <> _value then
         begin
            FMap[x,y-1,z] := _value;
            List.Add(x,y-1,z);
         end;
      if IsPointOK(x,y+1,z) then
         if FMap[x,y+1,z] <> _value then
         begin
            FMap[x,y+1,z] := _value;
            List.Add(x,y+1,z);
         end;
      if IsPointOK(x,y,z-1) then
         if FMap[x,y,z-1] <> _value then
         begin
            FMap[x,y,z-1] := _value;
            List.Add(x,y,z-1);
         end;
      if IsPointOK(x,y,z+1) then
         if FMap[x,y,z+1] <> _value then
         begin
            FMap[x,y,z+1] := _value;
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
      for x := 0 to High(_Source.FMap) do
         for y := 0 to High(_Source.FMap[x]) do
            for z := 0 to High(_Source.FMap[x,y]) do
            begin
               if _Source[x,y,z] = _Data then
                  FMap[x,y,z] := _Data;
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
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap) to High(FMap[x]) do
      begin
         // Get the initial position.
         z := Low(FMap[x,y]);
         InitialPosition := -1;
         while (z <= High(FMap[x,y])) and (InitialPosition = -1) do
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
            z := High(FMap[x,y]);
            FinalPosition := -1;
            while (z >= Low(FMap[x,y])) and (FinalPosition = -1) do
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
               FMap[x,y,z] := FMap[x,y,z] + 1;
               inc(z);
            end;
         end;
      end;

   // Scan the volume on the direction x
   for y := Low(FMap[0]) to High(FMap[0]) do
      for z := Low(FMap[0,y]) to High(FMap[0,y]) do
      begin
         // Get the initial position.
         x := Low(FMap);
         InitialPosition := -1;
         while (x <= High(FMap)) and (InitialPosition = -1) do
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
            x := High(FMap);
            FinalPosition := -1;
            while (x >= Low(FMap)) and (FinalPosition = -1) do
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
               FMap[x,y,z] := FMap[x,y,z] + 1;
               inc(x);
            end;
         end;
      end;

   // Scan the volume on the direction y
   for x := Low(FMap) to High(FMap) do
      for z := Low(FMap[x,0]) to High(FMap[x,0]) do
      begin
         // Get the initial position.
         y := Low(FMap[x]);
         InitialPosition := -1;
         while (y <= High(FMap[x])) and (InitialPosition = -1) do
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
            y := High(FMap[x]);
            FinalPosition := -1;
            while (y >= Low(FMap[x])) and (FinalPosition = -1) do
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
               FMap[x,y,z] := FMap[x,y,z] + 1;
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
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if FMap[x,y,z] = _Value then
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
                     FMap[x,y,z] := C_INSIDE_VOLUME;
                  end
                  else // surface
                  begin
                     FMap[x,y,z] := C_SURFACE;
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
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if FMap[x,y,z] = _Value then
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
                  if i = (maxi * 2) then
                  begin
                     FMap[x,y,z] := C_SURFACE;
                  end;
               end;
            end;
   end;
   Cube.Free;
end;

procedure TVoxelMap.MapSemiSurfaces(var _SemiSurfaces: T3DIntGrid);
const
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
      C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
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
   i, c, maxC, MaxFace, MaxEdge: integer;
   found : boolean;
begin
   CubeNeighboors := TNormals.Create(6);
   FaceNeighboors := TNormals.Create(7);
   VertsAndEdgesNeighboors := TNormals.Create(8);
   MaxFace := FaceNeighboors.GetLastID;
   MaxEdge := VertsAndEdgesNeighboors.GetLastID;
   SetLength(_SemiSurfaces,High(FMap)+1,High(FMap[0])+1,High(FMap[0,0])+1);
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[0]) to High(FMap[0]) do
         for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            _SemiSurfaces[x,y,z] := 0;
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[0]) to High(FMap[0]) do
         for z := Low(FMap[0,0]) to High(FMap[0,0]) do
         begin
            // Let's check if the surface has face neighbors
            if FMap[x,y,z] = C_SURFACE then
            begin
               found := false;
               i := 0;
               while (i <= MaxFace) do
               begin
                  CurrentNormal := FaceNeighboors[i];
                  if (GetMapSafe(x + Round(CurrentNormal.X),y + Round(CurrentNormal.Y),z + Round(CurrentNormal.Z)) >= C_SURFACE) then
                  begin
                     found := true;
                     i := MaxFace;
                  end;
                  inc(i);
               end;
               // if not found, it will generate semi-surfaces around it.
               if not found then
               begin
                  i := 0;
                  // check all non-face neighboors (8 vertices and 12 edges)
                  while (i <= MaxEdge) do
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
                     inc(i);
                  end;
               end;
            end;
         end;
   CubeNeighboors.Free;
   FaceNeighboors.Free;
   VertsAndEdgesNeighboors.Free;
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
                  v.Used := (FMap[x + FBias, y + FBias, z + FBias] >= _Threshold);
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
               v.Colour := Round(FMap[x + FBias,y + FBias, z + FBias]);
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
               v.Normal := Round(FMap[x + FBias,y + FBias, z + FBias]);
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
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if (Map[x,y,z] > 0) and (Map[x,y,z] <= High(_Values)) then
               begin
                  Map[x,y,z] := _Values[Round(Map[x,y,z])];
               end;
            end;
   end;
end;


// Check if the point is valid.
function TVoxelMap.IsPointOK (const x,y,z: integer) : boolean;
begin
   result := false;
   if (x < 0) or (x > High(FMap)) then exit;
   if (y < 0) or (y > High(FMap[0])) then exit;
   if (z < 0) or (z > High(FMap[0,0])) then exit;
   result := true;
end;

function TVoxelMap.GenerateFilledDataParam(_Filled: Integer; _Unfilled: Integer): integer;
begin
   Result := (_Filled shl 8) + _Unfilled;
end;


end.
