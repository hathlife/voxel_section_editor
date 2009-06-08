unit ThreeDMap;

// This is a 3D grid that is independent of voxels, with interesting operations
// for normalizing and rendering.

// 06/06/2009: Version 1.0 by Banshee

interface

uses BasicDataTypes, Class3DPointList, Normals, BasicConstants, Voxel_Engine,
   Math;

type
   T3DMap = class
      private
         // Variables
         FMap : T3DIntGrid;
         FBaseMap : T3DIntGrid;
         // Constructors and Destructors
         procedure Clear;
         procedure FillMap(_Mode : integer = C_MODE_NONE; _Value : integer = C_INSIDE_VOLUME);
         procedure Initialize(_Mode : integer = C_MODE_NONE; _Value : integer = C_INSIDE_VOLUME);
         // Gets
         function GetMap(_x,_y,_z: integer): integer;
         function GetMapSafe(_x,_y,_z: integer): integer;
         function GetBaseMap(_x,_y,_z: integer): integer;
         function GetBaseMapSafe(_x,_y,_z: integer): integer;
         // Sets
         procedure SetMap(_x,_y,_z: integer; _value: integer);
         procedure SetMapSafe(_x,_y,_z: integer; _value: integer);
         // Paints
         function GetEdgeDirection(_V1, _V2: TVector3i): TVector3i;
         function GetStepCounter(var _Direction: TVector3i): TVector3i;
         procedure IncreaseVector(var _Vector, _IncCounter: TVector3i; const _StepCounter,_Direction: TVector3i);
         function IsEdgePaintable(_V1, _V2, _Direction, _StepCounter: TVector3i; _Value: integer): boolean;
         procedure PaintEdge(_V1, _V2, _Direction, _StepCounter: TVector3i; _Value: integer); overload;
         // Misc
         procedure SetMapSize;
      public
         // Constructors and Destructors
         constructor Create(_x, _y, _z: integer); overload;
         constructor Create(const _BaseMap : T3DIntGrid; _Mode: integer; _Value : integer); overload;
         constructor Create(const _Map : T3DMap); overload;
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
         procedure GenerateSelfSurfaceMap;
         procedure GenerateInfluenceMapOnly;
         procedure GenerateFullMap;
         // Copies
         procedure Assign(const _Map : T3DMap);
         function CopyMap(const _Map: T3DSingleGrid): T3DSingleGrid;
         // Paints
         function TryPaintingEdge(_V1, _V2: TVector3i; _Value: integer): boolean;
         procedure PaintEdge(_V1, _V2: TVector3i; _Value: integer); overload;
         procedure PaintFace(_V1, _V2, _V3: TVector3i; _Value: integer);
         function IsFaceValid(_V1, _V2, _V3: TVector3i; _Value: integer): boolean;
         // Misc
         procedure FloodFill(const _Point : TVector3i; _value : integer);
         procedure MergeMapData(const _Source : T3DMap; _Data : integer);
         procedure MapInfluences;
         procedure MapSurfaces(_Value: integer);
         procedure MapSurfacesOnly(_Value: integer);
         procedure ConvertValues(_Values : array of integer);
         function IsFaceNormalsCorrect(const _V1, _V2, _V3: TVector3i; const _Normal: TVector3f): boolean;
         // Properties
         property Map[_x,_y,_z: integer] : integer read GetMap write SetMap; default;
         property MapSafe[_x,_y,_z: integer] : integer read GetMapSafe write SetMapSafe;
         function GenerateFilledDataParam(_Filled, _Unfilled: integer): integer;
         function IsPointOK (const x,y,z: integer) : boolean;
         function IsBaseMapPointOK (const x,y,z: integer) : boolean;
   end;
   P3DMap = ^T3DMap;

implementation

// Constructors and Destructors
constructor T3DMap.Create(_x, _y, _z: Integer);
var
   x,y,z: integer;
begin
   SetLength(FBaseMap,_x,_y,_z);
   for x := Low(FBaseMap) to High(FBaseMap) do
      for y := Low(FBaseMap[x]) to High(FBaseMap[x]) do
         for z := Low(FBaseMap[x,y]) to High(FBaseMap[x,y]) do
            FBaseMap[x,y,z] := 0;
   Initialize(C_MODE_NONE);
end;

constructor T3DMap.Create(const _BaseMap : T3DIntGrid; _Mode: integer; _Value: integer);
begin
   FBaseMap := _BaseMap;
   Initialize(_Mode,_Value);
end;

constructor T3DMap.Create(const _Map : T3DMap);
begin
   Assign(_Map);
end;

destructor T3DMap.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure T3DMap.Clear;
begin
   SetLength(FMap,0,0,0);
end;

procedure T3DMap.FillMap(_Mode : integer = C_MODE_NONE; _Value: integer = C_INSIDE_VOLUME);
var
   x,y,z : integer;
   Filled : integer;
   Unfilled : integer;
begin
   if _Mode = C_MODE_USED then
   begin
      Unfilled := _Value and $FF;
      Filled := _Value shr 8;
      for x := Low(FMap) to High(FMap) do
         for y := Low(FMap[0]) to High(FMap[0]) do
            for z := Low(FMap[0,0]) to High(FMap[0,0]) do
            begin
               if GetBaseMap(x,y,z) > 0 then
               begin
                  FMap[x,y,z] := Filled;
               end
               else
               begin
                  FMap[x,y,z] := Unfilled;
               end
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

procedure T3DMap.Initialize(_Mode : integer = C_MODE_NONE; _Value : integer = C_INSIDE_VOLUME);
begin
   SetMapSize;
   FillMap(_Mode,_Value);
end;

procedure T3DMap.Reset;
begin
   Clear;
   Initialize(C_MODE_NONE,0);
end;

// Gets
// Note: I want something quicker than checking if every damn point is ok.
function T3DMap.GetMap(_x: Integer; _y: Integer; _z: Integer): integer;
begin
   try
      Result := FMap[_x,_y,_z];
   except
      Result := -1;
   end;
end;

function T3DMap.GetMapSafe(_x: Integer; _y: Integer; _z: Integer): integer;
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

function T3DMap.GetBaseMap(_x: Integer; _y: Integer; _z: Integer): integer;
begin
   try
      Result := FBaseMap[_x,_y,_z];
   except
      Result := -1;
   end;
end;

function T3DMap.GetBaseMapSafe(_x: Integer; _y: Integer; _z: Integer): integer;
begin
   if IsBaseMapPointOK(_x,_y,_z) then
   begin
      Result := FBaseMap[_x,_y,_z];
   end
   else
   begin
      Result := -1;
   end;
end;


function T3DMap.GetMaxX: integer;
begin
   Result := High(FMap);
end;

function T3DMap.GetMaxY: integer;
begin
   Result := High(FMap[0]);
end;

function T3DMap.GetMaxZ: integer;
begin
   Result := High(FMap[0,0]);
end;


// Sets
// Note: I want something quicker than checking if every damn point is ok.
procedure T3DMap.SetMap(_x: Integer; _y: Integer; _z: Integer; _value: integer);
begin
   try
      FMap[_x,_y,_z] := _value;
   except
      exit;
   end;
end;

procedure T3DMap.SetMapSafe(_x: Integer; _y: Integer; _z: Integer; _value: integer);
begin
   if IsPointOK(_x,_y,_z) then
   begin
      FMap[_x,_y,_z] := _value;
   end;
end;

// Generates

// This procedure generates a map that specifies the voxels that are inside and
// outside the volume as 0 and 1.
procedure T3DMap.GenerateVolumeMap;
var
   FilledMap : T3DMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(C_INSIDE_VOLUME,C_OUTSIDE_VOLUME));
   FilledMap := T3DMap.Create(FBaseMap,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,C_INSIDE_VOLUME));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,C_INSIDE_VOLUME);
   FilledMap.Free;
end;

procedure T3DMap.GenerateInfluenceMap;
var
   FilledMap : T3DMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(1,C_OUTSIDE_VOLUME));
   FilledMap := T3DMap.Create(FBaseMap,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapInfluences;
end;

procedure T3DMap.GenerateSelfSurfaceMap;
var
   FilledMap : T3DMap;
begin
   FilledMap := T3DMap.Create(FMap,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapSurfaces(1);
end;


procedure T3DMap.GenerateSurfaceMap;
var
   FilledMap : T3DMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(1,C_OUTSIDE_VOLUME));
   FilledMap := T3DMap.Create(FBaseMap,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapSurfaces(1);
end;

procedure T3DMap.GenerateInfluenceMapOnly;
begin
   FillMap(C_MODE_All,0);
   MapInfluences;
end;


procedure T3DMap.GenerateFullMap;
var
   FilledMap : T3DMap;
begin
   FillMap(C_MODE_USED,GenerateFilledDataParam(1,C_OUTSIDE_VOLUME));
   FilledMap := T3DMap.Create(FBaseMap,C_MODE_USED,GenerateFilledDataParam(C_OUTSIDE_VOLUME,1));
   FilledMap.FloodFill(SetVectorI(0,0,0),0);
   MergeMapData(FilledMap,1);
   FilledMap.Free;
   MapInfluences;
   MapSurfaces(C_SURFACE);
end;


// Copies
procedure T3DMap.Assign(const _Map : T3DMap);
var
   x, y, z: integer;
begin
   SetMapSize;
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[0]) to High(FMap[0]) do
         for z := Low(FMap[0,0]) to High(FMap[0,0]) do
         begin
            FMap[x,y,z] := _Map.FMap[x,y,z];
         end;
end;

function T3DMap.CopyMap(const _Map: T3DSingleGrid): T3DSingleGrid;
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

// Paints
function T3DMap.TryPaintingEdge(_V1, _V2: TVector3i; _Value: integer): boolean;
var
   Direction,StepCounter: TVector3i;
begin
   Direction := GetEdgeDirection(_V1,_V2);
   StepCounter := GetStepCounter(Direction);
   Result := IsEdgePaintable(_V1,_V2,Direction,StepCounter,_Value);
   if Result then
      PaintEdge(_V1,_V2,Direction,StepCounter,_Value);
end;

procedure T3DMap.PaintEdge(_V1, _V2: TVector3i; _Value: integer);
var
   Direction,StepCounter: TVector3i;
begin
   Direction := GetEdgeDirection(_V1,_V2);
   StepCounter := GetStepCounter(Direction);
   PaintEdge(_V1,_V2,Direction,StepCounter,_Value);
end;

procedure T3DMap.PaintEdge(_V1, _V2, _Direction, _StepCounter: TVector3i; _Value: integer);
var
   IncCounter: TVector3i;
   CurrentVertex: TVector3i;
begin
   IncCounter := SetVectori(0,0,0);
   CurrentVertex := SetVectori(_V1.X,_V1.Y,_V1.Z);
   IncreaseVector(CurrentVertex,IncCounter,_StepCounter,_Direction);
   while (CurrentVertex.X <> _V2.X) or (CurrentVertex.Y <> _V2.Y) or (CurrentVertex.Z <> _V2.Z) do
   begin
      FMap[CurrentVertex.X,CurrentVertex.Y,CurrentVertex.Z] := _Value;
      IncreaseVector(CurrentVertex,IncCounter,_StepCounter,_Direction);
   end;
end;

procedure T3DMap.PaintFace(_V1, _V2, _V3: TVector3i; _Value: integer);
var
   Direction,StepCounter: TVector3i;
   DirectionE1,StepCounterE1, IncCounterE1, CurrentV1: TVector3i;
   DirectionE2,StepCounterE2, IncCounterE2, CurrentV2: TVector3i;
begin
   Direction := GetEdgeDirection(_V2,_V3);
   StepCounter := GetStepCounter(Direction);
   DirectionE1 := GetEdgeDirection(_V1,_V2);
   StepCounterE1 := GetStepCounter(DirectionE1);
   DirectionE2 := GetEdgeDirection(_V1,_V3);
   StepCounterE2 := GetStepCounter(DirectionE2);
   IncCounterE1 := SetVectori(0,0,0);
   IncCounterE2 := SetVectori(0,0,0);
   FMap[_V1.X,_V1.Y,_V1.Z] := _Value;
   FMap[_V2.X,_V2.Y,_V2.Z] := _Value;
   FMap[_V3.X,_V3.Y,_V3.Z] := _Value;
   IncreaseVector(CurrentV1,IncCounterE1,StepCounterE1,DirectionE1);
   IncreaseVector(CurrentV2,IncCounterE2,StepCounterE2,DirectionE2);
   while (CurrentV1.X <> _V2.X) or (CurrentV1.Y <> _V2.Y) or (CurrentV1.Z <> _V2.Z) do
   begin
      FMap[CurrentV1.X,CurrentV1.Y,CurrentV1.Z] := _Value;
      FMap[CurrentV2.X,CurrentV2.Y,CurrentV2.Z] := _Value;
      PaintEdge(CurrentV1,CurrentV2,Direction,StepCounter,_Value);
      IncreaseVector(CurrentV1,IncCounterE1,StepCounterE1,DirectionE1);
      IncreaseVector(CurrentV2,IncCounterE2,StepCounterE2,DirectionE2);
   end;
end;


function T3DMap.IsEdgePaintable(_V1, _V2, _Direction, _StepCounter: TVector3i; _Value: integer): boolean;
var
   IncCounter: TVector3i;
   CurrentVertex: TVector3i;
begin
   Result := true;
   IncCounter := SetVectori(0,0,0);
   CurrentVertex := SetVectori(_V1.X,_V1.Y,_V1.Z);
   IncreaseVector(CurrentVertex,IncCounter,_StepCounter,_Direction);
   while (CurrentVertex.X <> _V2.X) or (CurrentVertex.Y <> _V2.Y) or (CurrentVertex.Z <> _V2.Z) do
   begin
      if FMap[CurrentVertex.X,CurrentVertex.Y,CurrentVertex.Z] = _Value then
      begin
         Result := false;
         exit;
      end;
      IncreaseVector(CurrentVertex,IncCounter,_StepCounter,_Direction);
   end;
end;

function T3DMap.IsFaceValid(_V1, _V2, _V3: TVector3i; _Value: integer): boolean;
var
   Direction,StepCounter: TVector3i;
   DirectionE1,StepCounterE1, IncCounterE1, CurrentV1: TVector3i;
   DirectionE2,StepCounterE2, IncCounterE2, CurrentV2: TVector3i;
begin
   Result := true;
   Direction := GetEdgeDirection(_V2,_V3);
   StepCounter := GetStepCounter(Direction);
   DirectionE1 := GetEdgeDirection(_V1,_V2);
   StepCounterE1 := GetStepCounter(DirectionE1);
   DirectionE2 := GetEdgeDirection(_V1,_V3);
   StepCounterE2 := GetStepCounter(DirectionE2);
   IncCounterE1 := SetVectori(0,0,0);
   IncCounterE2 := SetVectori(0,0,0);
   if (FMap[_V1.X,_V1.Y,_V1.Z] = _Value) or (FMap[_V2.X,_V2.Y,_V2.Z] = _Value) or (FMap[_V3.X,_V3.Y,_V3.Z] = _Value) then
   begin
      Result := false;
      exit;
   end;
   IncreaseVector(CurrentV1,IncCounterE1,StepCounterE1,DirectionE1);
   IncreaseVector(CurrentV2,IncCounterE2,StepCounterE2,DirectionE2);
   while (CurrentV1.X <> _V2.X) or (CurrentV1.Y <> _V2.Y) or (CurrentV1.Z <> _V2.Z) do
   begin
      if (FMap[CurrentV1.X,CurrentV1.Y,CurrentV1.Z] = _Value) or (FMap[CurrentV2.X,CurrentV2.Y,CurrentV2.Z] = _Value) or IsEdgePaintable(CurrentV1,CurrentV2,Direction,StepCounter,_Value) then
      begin
         Result := false;
         exit;
      end;
      IncreaseVector(CurrentV1,IncCounterE1,StepCounterE1,DirectionE1);
      IncreaseVector(CurrentV2,IncCounterE2,StepCounterE2,DirectionE2);
   end;
end;

function T3DMap.IsFaceNormalsCorrect(const _V1, _V2, _V3: TVector3i; const _Normal: TVector3f): boolean;
var
   CentralPoint, TestPoint: TVector3i;
   Direction: TVector3f;
   MaxNormalValue: single;
begin
   CentralPoint.X := (((_V1.X + _V2.X) div 2) + _V3.X) div 2;
   CentralPoint.Y := (((_V1.Y + _V2.Y) div 2) + _V3.Y) div 2;
   CentralPoint.Z := (((_V1.Z + _V2.Z) div 2) + _V3.Z) div 2;
   // Now that we have the central point, we need to have a point that will ensure
   // that it will move us to another voxel. So one of the axis must be 1 or -1.
   MaxNormalValue := Max(Max(abs(_Normal.X),abs(_Normal.Y)),abs(_Normal.Z));
   Direction.X := _Normal.X / MaxNormalValue;
   Direction.Y := _Normal.Y / MaxNormalValue;
   Direction.Z := _Normal.Z / MaxNormalValue;
   // Now, let's walk from the central point in the direction of the normals.
   TestPoint.X := Round(CentralPoint.X + Direction.X);
   TestPoint.Y := Round(CentralPoint.Y + Direction.Y);
   TestPoint.Z := Round(CentralPoint.Z + Direction.Z);
   if GetMapSafe(TestPoint.X,TestPoint.Y,TestPoint.Z) <= C_OUTSIDE_VOLUME then
   begin
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function T3DMap.GetEdgeDirection(_V1, _V2: TVector3i): TVector3i;
var
   BaseValue: integer;
begin
   // Get direction
   Result.X := _V2.X - _V1.X;
   Result.Y := _V2.Y - _V1.Y;
   Result.Z := _V2.Z - _V1.Z;
   // Ensure that we'll get a step 1 direction.
   BaseValue := Min(abs(Result.X),abs(Result.Y));
   if BaseValue = 0 then
      BaseValue := Max(abs(Result.X),abs(Result.Y));
   if Min(abs(Result.Z),BaseValue) <> 0 then
      BaseValue := Min(abs(Result.Z),BaseValue);
   Result.X := Result.X div BaseValue;
   Result.Y := Result.Y div BaseValue;
   Result.Z := Result.Z div BaseValue;
end;

function T3DMap.GetStepCounter(var _Direction: TVector3i): TVector3i;
var
   MaxStep: integer;
begin
   Result.X := abs(_Direction.X);
   Result.Y := abs(_Direction.Y);
   Result.Z := abs(_Direction.Z);
   MaxStep := Max(Result.X,Result.Y);
   MaxStep := Max(MaxStep,Result.Z);
   if Result.X <> 0 then
   begin
      _Direction.X := _Direction.X div Result.X;
      Result.X := MaxStep div Result.X;
   end;
   if Result.Y <> 0 then
   begin
      _Direction.Y := _Direction.Y div Result.Y;
      Result.Y := MaxStep div Result.Y;
   end;
   if Result.Z <> 0 then
   begin
      _Direction.Z := _Direction.Z div Result.Z;
      Result.Z := MaxStep div Result.Z;
   end;
end;

procedure T3DMap.IncreaseVector(var _Vector, _IncCounter: TVector3i; const _StepCounter,_Direction: TVector3i);
begin
   inc(_IncCounter.X);
   if _IncCounter.X >= _StepCounter.X then
   begin
      _Vector.X := _Vector.X + _Direction.X;
      _IncCounter.X := 0;
   end;
   inc(_IncCounter.Y);
   if _IncCounter.Y >= _StepCounter.Y then
   begin
      _Vector.Y := _Vector.Y + _Direction.Y;
      _IncCounter.Y := 0;
   end;
   inc(_IncCounter.Z);
   if _IncCounter.Z >= _StepCounter.Z then
   begin
      _Vector.Z := _Vector.Z + _Direction.Z;
      _IncCounter.Z := 0;
   end;
end;


// Misc
procedure T3DMap.SetMapSize;
begin
   if High(FBaseMap) < 0 then
      SetLength(FMap, 0, 0, 0)
   else if High(FBaseMap[0]) < 0 then
      SetLength(FMap, 0, 0, 0)
   else
      SetLength(FMap, High(FBaseMap)+1, High(FBaseMap[0])+1, High(FBaseMap[0,0]));
end;

procedure T3DMap.FloodFill(const _Point : TVector3i; _value : integer);
var
   List : C3DPointList; // Check Class3DPointList.pas;
   x,y,z : integer;
begin
   List := C3DPointList.Create;
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
      List.GoToNextElement;
   end;
   List.Free;
end;

procedure T3DMap.MergeMapData(const _Source : T3DMap; _Data : integer);
var
   x,y,z : integer;
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

procedure T3DMap.MapInfluences;
var
   x,y,z : integer;
   InitialPosition,FinalPosition : integer;
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
            if GetBaseMap(x,y,z) > 0 then
            begin
               InitialPosition := z;
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
               if GetBaseMap(x,y,z) > 0 then
               begin
                  FinalPosition := z;
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
            if GetBaseMap(x,y,z) > 0 then
            begin
               InitialPosition := x;
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
               if GetBaseMap(x,y,z) > 0 then
               begin
                  FinalPosition := x;
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
            if GetBaseMap(x,y,z) > 0 then
            begin
               InitialPosition := y;
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
               if GetBaseMap(x,y,z) > 0 then
               begin
                  FinalPosition := y;
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

procedure T3DMap.MapSurfaces(_Value: integer);
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

procedure T3DMap.MapSurfacesOnly(_Value: integer);
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

procedure T3DMap.ConvertValues(_Values : array of integer);
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
function T3DMap.IsPointOK (const x,y,z: integer) : boolean;
begin
   result := false;
   if (x < 0) or (x >= High(FMap)) then exit;
   if (y < 0) or (y >= High(FMap[0])) then exit;
   if (z < 0) or (z >= High(FMap[0,0])) then exit;
   result := true;
end;

function T3DMap.IsBaseMapPointOK (const x,y,z: integer) : boolean;
begin
   result := false;
   if (x < 0) or (x >= High(FBaseMap)) then exit;
   if (y < 0) or (y >= High(FBaseMap[0])) then exit;
   if (z < 0) or (z >= High(FBaseMap[0,0])) then exit;
   result := true;
end;

function T3DMap.GenerateFilledDataParam(_Filled: Integer; _Unfilled: Integer): integer;
begin
   Result := (_Filled shl 8) + _Unfilled;
end;


end.
