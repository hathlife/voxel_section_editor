unit Voxel_Tools;

{ REVISION HISTORY
  2009/01/17 Removed all normals related functions. Now normals.pas has something better.
  2005/11/23 Fixed ApplyCubedNormals, by adding the Binary3DFloodFill stuff.
  2005/11/10 Added ApplyCubedNormals.
  2004/06/14 Added GetSmoothNormal, used for smoothing single voxel points.
  2004/05/02 Normal Scheme's removed, Apply Normals remade. RemoveRedundantVoxels Remade.
  20020224 Fixed non-current folder bugs in loadnormalschemes,
           added flag NO_FORMS to switch back to ParamStr(0) instead
           of Application.ExeName (for console apps, the extra certainty isn't
           worth 300 KB :-) (since ParamStr(0) works fine on my/most PC's)
  20011218 removed all WriteLns
  20011213 using multi-pass flood filling instead of recursion
  20011213 fixed bug in Internal
}

interface

Uses BasicMathsTypes, BasicDataTypes, BasicVXLSETypes, Voxel, normals,
   Voxel_Engine, math, math3d, Dialogs, Sysutils, VoxelMap, BasicFunctions,
   BasicConstants;

type
   TApplyNormalsResult = record
      applied,
      confused: Integer;
   end;

   TVoxelSmoothData = record
     Pos : TVector3i;
     V : TVoxelUnpacked;
   end;

const
   // 1.2 Cubed Normals Constants:
   DIST2 = 0.707106781186547524400844362104849; // sqrt(2)/2
   DIST3 = 0.577350269189625764509148780501957; // sqrt(3)/3
   LIMZERO = 0.0000000000001;
   TIP = 1;

//applies normals
function ApplyNormals(var _Voxel : TVoxelSection) : TApplyNormalsResult;
function ApplyCubedNormals(var _Voxel : TVoxelSection; _Range,_SmoothLevel : single; _ContrastLevel : integer; _SmoothMe,_InfluenceMe,_AffectOnlyNonNormalized : Boolean) : TApplyNormalsResult;
function ApplyInfluenceNormals(var _Voxel : TVoxelSection; _Range,_SmoothLevel : single; _ContrastLevel : integer; _SmoothMe,_AffectOnlyNonNormalized,_ImproveContrast : boolean) : TApplyNormalsResult;
function RemoveRedundantVoxels(var _Voxel : TVoxelSection) : integer;
function SmoothNormals(var _Voxel : TVoxelSection) : TApplyNormalsResult;
function GetSmoothNormal(var _Voxel : TVoxelSection; _X,_Y,_Z,Normal : integer) : integer;

// HBD functions (based in a modified old voxel engine, so somethings might be replicated)
procedure velAutoNormals2(_Sect: TVoxelSection; _Range, _Smooth: Single);

// Maths
procedure VecToAngles(const _In: TVector3f ; var _angles: TVector3f);
function GetNonZeroSign(const _value : single) : shortint;
function GetTrueSign(var _value,_signal : single; _minVar, _maxVar : integer) : shortint;

// auxiliary functions
procedure GetNewNormals(var _Voxel : TVoxelSection; const _BM: TVector3fMap; const _Dist : TDistanceArray; var _V : TVoxelUnpacked; _MidPoint,_Range,_x,_y,_z : integer; var _applied : integer);
procedure GetNewNormalsWithNoSmooth(var _Voxel: TVoxelSection; const _BM: TVector3fMap; var _V : TVoxelUnpacked; Range,_x,_y,_z : integer; var _applied : integer);
procedure GetPreliminaryNormals(const _Map: TVoxelMap; var _FloatMap : TVector3fMap; const _Dist: TDistanceArray; var _V : TVoxelUnpacked; _MidPoint,_Range,_x,_y,_z : integer);
procedure ResetBinaryMap(const _Voxel: TVoxelSection; var _Map : TBinaryMap; _Range: integer);
procedure SetupDistanceArray(var _Dist : TDistanceArray; _Range,_SmoothLevel : single; _ContrastLevel : integer);
procedure NormalizeModel(var _Voxel : TVoxelSection; const _Map : TVoxelMap; var _FloatMap: TVector3fMap; const _Dist : TDistanceArray; _MidPoint,_Range : integer);
procedure PolishModel(var _Voxel : TVoxelSection; var _FloatMap: TVector3fMap; const _Dist : TDistanceArray; _MidPoint,_Range : integer; _SmoothMe: boolean; var _Applied : integer; _AffectOnlyNonNormalized : Boolean);


implementation

{uses SysUtils;}

procedure VecToAngles(const _In: TVector3f ; var _angles: TVector3f);
var
   forward_: Single;
   yaw, pitch: Single;
begin
   if (_In.z = 0) and (_In.x = 0) then
   begin
      yaw := 0;
      if (_In.z > 0) then
         pitch := 90
      else
         pitch := 270;
   end
   else
   begin
      if (_In.x <> 0) then
         yaw := Round(ArcTan2(_In.z, _In.x) * 180 / M_PI)
      else if (_In.z > 0) then
         yaw := 90
      else
         yaw := -90;
      if (yaw < 0) then
         yaw := yaw + 360;

      forward_ := sqrt(_In.x*_In.x + _In.z*_In.z);
      pitch := Round(ArcTan2(_In.y, forward_) * 180 / M_PI);
      if (pitch < 0) then
         pitch := pitch + 360;
   end;

   _angles.x := -pitch;
   _angles.y := yaw;
   _angles.z := 0;
end;
       {
Function VectorLength(N : TVector3f) : Single;
begin
Result := sqrt(N.X*N.X + N.Y*N.Y + N.Z*N.Z);
end;   }
            {
Function SubtractVector(V1,V2 : TVector3f) : single;
begin
Result := Max(V1.X,V2.X)-Min(V1.X,V2.X);
Result := Result + Max(V1.Y,V2.Y)-Min(V1.Y,V2.Y);
Result := Result + Max(V1.Z,V2.Z)-Min(V1.Z,V2.Z);
end;

Function SubtractVector3f(V1,V2 : TVector3f) : TVector3f;
begin
Result.X := V1.X-V2.X;
Result.Y := V1.Y-V2.Y;
Result.Z := V1.Z-V2.Z;
end;             }

//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
// Calculate new normals
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
procedure GetPreliminaryNormals(const _Map: TVoxelMap; var _FloatMap : TVector3fMap; const _Dist: TDistanceArray; var _V : TVoxelUnpacked; _MidPoint,_Range,_x,_y,_z : integer);
var
   Res : TVector3f;
   Sum : TVector3f;
   {Alpha,}x,y,z : integer;
   xx,yy,zz : integer;
   MyPoint : TVector3i;
   MinPoint,MaxPoint : TVector3i;
   MidPointMinusRange : integer;
begin
   // Security checkup.
   if not _V.Used then exit;

   x := _MidPoint + _x;
   y := _MidPoint + _y;
   z := _MidPoint + _z;

   MinPoint.X := x - _Range;
   MaxPoint.X := x + _Range;
   MinPoint.Y := y - _Range;
   MaxPoint.Y := y + _Range;
   MinPoint.Z := z - _Range;
   MaxPoint.Z := z + _Range;

   Res.X := 0;
   Res.Y := 0;
   Res.Z := 0;
   Sum.X := 0;
   Sum.Y := 0;
   Sum.Z := 0;

   // This is the centralizer factor, so it will make MyPoint points to
   // the position of the filter based on its center.
   MidPointMinusRange := _MidPoint - _Range;

   // Time to get a rx, ry and rz from the binary map
   for xx := MinPoint.X to MaxPoint.X do
      for yy := MinPoint.Y to MaxPoint.Y do
         for zz := MinPoint.Z to MaxPoint.Z do
         begin
            // Set MyPoint
            MyPoint.X := xx - MinPoint.X + MidPointMinusRange;
            MyPoint.Y := yy - MinPoint.Y + MidPointMinusRange;
            MyPoint.Z := zz - MinPoint.Z + MidPointMinusRange;
            //Alpha := abs(x - xx) + abs(y - yy) + abs(z - zz);
            Res.X := Res.X + (_Map[xx,yy,zz] * _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].X);
            Res.Y := Res.Y + (_Map[xx,yy,zz] * _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Y);
            Res.Z := Res.Z + (_Map[xx,yy,zz] * _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Z);
            Sum.X := Sum.X + abs(_Map[xx,yy,zz] * _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].X);
            Sum.Y := Sum.Y + abs(_Map[xx,yy,zz] * _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Y);
            Sum.Z := Sum.Z + abs(_Map[xx,yy,zz] * _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Z);
         end;

   if Sum.X <> 0 then
      _FloatMap[x,y,z].X := Res.X / Sum.X
   else
      _FloatMap[x,y,z].X := 0;
   if Sum.Y <> 0 then
      _FloatMap[x,y,z].Y := Res.Y / Sum.Y
   else
      _FloatMap[x,y,z].Y := 0;
   if Sum.Z <> 0 then
      _FloatMap[x,y,z].Z := Res.Z / Sum.Z
   else
      _FloatMap[x,y,z].Z := 0;
end;

function GetNonZeroSign(const _value : single) : shortint;
begin
   Result := sign(_value);
   if Result = 0 then
      Result := 1;
 end;

function GetTrueSign(var _value,_signal : single; _minVar, _maxVar: integer) : shortint;
begin
   Result := sign(_value);
   if Result = 0 then
   begin
      Result := sign(_signal);
      if Result = 0 then
      begin
         // we need to do some magic here.
         if _minVar <= (_maxVar div 2) then
            Result := 1
         else
            Result := -1;
      end;
   end;
end;

procedure GetNewNormals(var _Voxel : TVoxelSection; const _BM: TVector3fMap; const _Dist : TDistanceArray; var _V : TVoxelUnpacked; _MidPoint,_Range,_x,_y,_z : integer; var _applied : integer);
var
   res : TVector3f;
   signal : TVector3f;
   newvalue : single;
   x,y,z : integer;
   xx,yy,zz : integer;
   xcounter,ycounter,zcounter : single;
   MyPoint : TVector3i;
   CurrentVoxel : TVoxelUnpacked;
   MinPoint,MaxPoint : TVector3i;
   MidPointMinusRange : integer;
begin
   // Security checkup.
   if not _V.Used then exit;

   x := _MidPoint + _x;
   y := _MidPoint + _y;
   z := _MidPoint + _z;

   MinPoint.X := x - _Range;
   MaxPoint.X := x + _Range;
   MinPoint.Y := y - _Range;
   MaxPoint.Y := y + _Range;
   MinPoint.Z := z - _Range;
   MaxPoint.Z := z + _Range;

   res.X := 0;
   res.Y := 0;
   res.Z := 0;
   signal.X := 0;
   signal.Y := 0;
   signal.Z := 0;
   xcounter := 0;
   ycounter := 0;
   zcounter := 0;

   // This is the centralizer factor, so it will make MyPoint points to
   // the position of the filter based on its center.
   MidPointMinusRange := _MidPoint - _Range;

   // Let's grab the new res
   for xx := MinPoint.X to MaxPoint.X do
      for yy := MinPoint.Y to MaxPoint.Y do
         for zz := MinPoint.Z to MaxPoint.Z do
         begin
            // Set MyPoint
            MyPoint.X := xx - MinPoint.X + MidPointMinusRange;
            MyPoint.Y := yy - MinPoint.Y + MidPointMinusRange;
            MyPoint.Z := zz - MinPoint.Z + MidPointMinusRange;
            if _Voxel.GetVoxelSafe(xx - _MidPoint,yy - _MidPoint,zz - _MidPoint,CurrentVoxel) then
               if CurrentVoxel.Used then
               begin
                  newvalue := _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance * _BM[xx,yy,zz].X;
                  res.X := res.X + abs(NewValue);// * GetNonZeroSign(BM[xx,yy,zz].X));
                  signal.X := signal.X + NewValue;
                  xcounter := xcounter + _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance;
                  NewValue := _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance * _BM[xx,yy,zz].Y;
                  res.Y := res.Y + abs(NewValue); // * GetNonZeroSign(BM[xx,yy,zz].Y));
                  signal.X := signal.X + NewValue;
                  ycounter := ycounter + _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance;
                  NewValue := _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance * _BM[xx,yy,zz].Z;
                  res.Z := res.Z + abs(NewValue); // * GetNonZeroSign(BM[xx,yy,zz].Z));
                  signal.Z := signal.Z + NewValue;
                  zcounter := zcounter + _Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance;
               end;
         end;
   if xcounter > 0 then
      res.X := (res.X / xcounter) * GetTrueSign(_BM[x,y,z].X,signal.X,_x,_Voxel.Tailer.XSize);
   if ycounter > 0 then
      res.Y := (res.Y / ycounter) * GetTrueSign(_BM[x,y,z].Y,signal.Y,_y,_Voxel.Tailer.YSize);
   if zcounter > 0 then
      res.Z := (res.Z / zcounter) * GetTrueSign(_BM[x,y,z].Z,signal.Z,_z,_Voxel.Tailer.ZSize);

   // Normalization process.
   Normalize(res);
   _v.Normal := _Voxel.Normals.GetIDFromNormal(res);

   // Apply
   _Voxel.SetVoxel(_x,_y,_z,_V);
   inc(_applied);
end;

procedure GetNewNormalsWithNoSmooth(var _Voxel: TVoxelSection; const _BM: TVector3fMap; var _V : TVoxelUnpacked; Range,_x,_y,_z : integer; var _applied : integer);
var
   x,y,z : integer;
begin
   // Security checkup.
   if not _V.Used then exit;

   x := _x + Range;
   y := _y + Range;
   z := _z + Range;

   // Normalization process.
   Normalize(_BM[x,y,z]);
   _V.Normal := _Voxel.Normals.GetIDFromNormal(_BM[x,y,z]);

   // Apply
   _Voxel.SetVoxel(_x,_y,_z,_V);
   inc(_applied);
end;

procedure ResetBinaryMap(const _Voxel: TVoxelSection; var _Map : TBinaryMap; _Range: integer);
var
   DoubleRange : integer;
   x,y,z : integer;
begin
   DoubleRange := 2 * _Range;
   // Set memory for binary map. Extra memory avoids bound checking
   SetLength(_Map,_Voxel.Tailer.XSize+DoubleRange,_Voxel.Tailer.YSize+DoubleRange,_Voxel.Tailer.ZSize+DoubleRange);

   // Clear map
   for x := Low(_Map) to High(_Map) do
      for y := Low(_Map) to High(_Map[x]) do
         for z := Low(_Map) to High(_Map[x,y]) do
             _Map[x,y,z] := 0;
end;


procedure SetupDistanceArray(var _Dist : TDistanceArray; _Range,_SmoothLevel : single; _ContrastLevel : integer);
var
   x,y,z : integer;
   Size,MidPoint : integer;
   Distance: single;//,Distance2D : single;
begin
   // 1.36 Setup distance array
   MidPoint := Max(Trunc(_SmoothLevel),Trunc(_Range));
   Size := (2*MidPoint)+1;
   SetLength(_Dist,Size,Size,Size);
   _Dist[MidPoint,MidPoint,MidPoint].Distance := 1;
   _Dist[MidPoint,MidPoint,MidPoint].X := 0;
   _Dist[MidPoint,MidPoint,MidPoint].Y := 0;
   _Dist[MidPoint,MidPoint,MidPoint].Z := 0;
   for x := Low(_Dist) to High(_Dist) do
   begin
      for y := Low(_Dist[x]) to High(_Dist[x]) do
      begin
         for z := Low(_Dist[x,y]) to High(_Dist[x,y]) do
         begin
            Distance := sqrt(((x - MidPoint) * (x - MidPoint)) + ((y - MidPoint) * (y - MidPoint)) + ((z - MidPoint) * (z - MidPoint)));
            if Distance > 0 then
            begin
               if Distance <= _SmoothLevel then
               begin
                  _Dist[x,y,z].Distance := 1 / Power(Distance,_ContrastLevel);
               end
               else
               begin
                  _Dist[x,y,z].Distance := 0;
               end;
               if (Distance <= _Range) then
               begin
                  if MidPoint <> x then
                     _Dist[x,y,z].X :=  (3 * (MidPoint - x)) / Power(Distance,3)
                  else
                     _Dist[x,y,z].X := 0;

                  if MidPoint <> y then
                     _Dist[x,y,z].Y :=  (3 * (MidPoint - y)) / Power(Distance,3)
                  else
                     _Dist[x,y,z].Y := 0;

                  if MidPoint <> z then
                     _Dist[x,y,z].Z :=  (3 * (MidPoint - z)) / Power(Distance,3)
                  else
                     _Dist[x,y,z].Z := 0;
               end
               else
               begin
                  _Dist[x,y,z].X := 0;
                  _Dist[x,y,z].Y := 0;
                  _Dist[x,y,z].Z := 0;
               end;
            end
            else
            begin
               _Dist[x,y,z].Distance := 0;
               _Dist[x,y,z].X := 0;
               _Dist[x,y,z].Y := 0;
               _Dist[x,y,z].Z := 0;
            end;
         end;
      end;
   end;
end;

procedure NormalizeModel(var _Voxel : TVoxelSection; const _Map : TVoxelMap; var _FloatMap: TVector3fMap; const _Dist : TDistanceArray; _MidPoint,_Range : integer);
var
   x,y,z : integer;
   V : TVoxelUnpacked;
begin
   // Now, let's normalize every voxel.
   for x := 0 to _Voxel.Tailer.XSize-1 do
      for y := 0 to _Voxel.Tailer.YSize-1 do
         for z := 0 to _Voxel.Tailer.ZSize-1 do
         begin
            // Get voxel data and calculate it (added +1 to
            // each, since binary map has propositally a
            // border to avoid bound checking).
            _Voxel.GetVoxel(x,y,z,v);
            GetPreliminaryNormals(_Map,_FloatMap,_Dist,V,_MidPoint,_Range,x,y,z);
         end;
end;

procedure PolishModel(var _Voxel : TVoxelSection; var _FloatMap: TVector3fMap; const _Dist : TDistanceArray; _MidPoint,_Range : integer; _SmoothMe: boolean; var _Applied : integer; _AffectOnlyNonNormalized : Boolean);
var
   x,y,z : integer;
   V : TVoxelUnpacked;
   MinimumInvalidNormalValue: byte;
begin
   MinimumInvalidNormalValue := _Voxel.Normals.GetLastID + 1;
   if _SmoothMe then
   begin
      for x := 0 to _Voxel.Tailer.XSize-1 do
         for y := 0 to _Voxel.Tailer.YSize-1 do
            for z := 0 to _Voxel.Tailer.ZSize-1 do
            begin
               _Voxel.GetVoxel(x,y,z,v);
               if (not _AffectOnlyNonNormalized) or (v.Normal = 0) or (v.Normal >= MinimumInvalidNormalValue) then
                  GetNewNormals(_Voxel,_FloatMap,_Dist,V,_MidPoint,_Range,x,y,z,_Applied);
            end;
   end
   else
   begin
      for x := 0 to _Voxel.Tailer.XSize-1 do
         for y := 0 to _Voxel.Tailer.YSize-1 do
            for z := 0 to _Voxel.Tailer.ZSize-1 do
            begin
               _Voxel.GetVoxel(x,y,z,v);
               if (not _AffectOnlyNonNormalized) or (v.Normal = 0) or (v.Normal >= MinimumInvalidNormalValue) then
                  GetNewNormalsWithNoSmooth(_Voxel,_FloatMap,V,_Range,x,y,z,_Applied);
            end;
   end;
end;

// 1.2 Adition: Cubed Normalizer
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
// Cubed Normals 2x Main Funcion Starts Here
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
function ApplyCubedNormals(var _Voxel : TVoxelSection; _Range,_SmoothLevel : single; _ContrastLevel : integer; _SmoothMe,_InfluenceMe,_AffectOnlyNonNormalized : Boolean) : TApplyNormalsResult;
var
   Map : TVoxelMap;
   FloatMap : TVector3fMap;
   x,y,z : integer;
   Dist : TDistanceArray;
   IntRange,IntSmooth,FullRange : integer;
   Values : array of single;
begin
   // 1.36 Setup distance array
   IntRange := Trunc(_Range);
   IntSmooth := Trunc(_SmoothLevel);
   FullRange := Max(IntSmooth,IntRange);
   SetupDistanceArray(Dist,_Range,_SmoothLevel,_ContrastLevel);
   SetLength(FloatMap,_Voxel.Tailer.XSize+(2*FullRange),_Voxel.Tailer.YSize+(2*FullRange),_Voxel.Tailer.ZSize+(2*FullRange));
   for x := Low(FloatMap) to High(FloatMap) do
      for y := Low(FloatMap) to High(FloatMap[x]) do
         for z := Low(FloatMap) to High(FloatMap[x,y]) do
         begin
            FloatMap[x,y,z].X := 0;
            FloatMap[x,y,z].Y := 0;
            FloatMap[x,y,z].Z := 0;
         end;
   Result.applied := 0;
   // Create the binary map
   Map := TVoxelMap.CreateQuick(_Voxel,FullRange);
   Map.GenerateVolumeMap;
   // 1.32: Solves limit (x,y,z) -> (0,0,0) on cubed normalizer.
   if _InfluenceMe then
   begin
      Map.GenerateInfluenceMap;
      SetLength(Values,5);
      Values[0] := 0;
      Values[1] := LIMZERO;
      Values[2] := 0.0000001;
      Values[3] := 0.0001;
      Values[4] := 1;
      Map.ConvertValues(Values);
   end;
   // Now, let's normalize every voxel.
   NormalizeModel(_Voxel,Map,FloatMap,Dist,FullRange,IntRange);
   PolishModel(_Voxel,FloatMap,Dist,FullRange,IntSmooth,_SmoothMe,Result.Applied,_AffectOnlyNonNormalized);
   // Now, let's free some memory.
   for x := Low(Dist) to High(Dist) do
   begin
      for y := Low(Dist) to High(Dist[x]) do
      begin
         SetLength(Dist[x,y], 0);
      end;
      SetLength(Dist[x], 0);
   end;
   SetLength(Dist, 0);
   Map.Free;
   for x := Low(FloatMap) to High(FloatMap) do
   begin
      for y := Low(FloatMap) to High(FloatMap[x]) do
      begin
         SetLength(FloatMap[x,y], 0);
      end;
      SetLength(FloatMap[x], 0);
   end;
   SetLength(FloatMap, 0);
   SetLength(Values, 0);
end;


// 1.3 Adition: Influence Normalizer
function ApplyInfluenceNormals(var _Voxel : TVoxelSection; _Range,_SmoothLevel : single; _ContrastLevel : integer; _SmoothMe,_AffectOnlyNonNormalized,_ImproveContrast : boolean) : TApplyNormalsResult;
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
// Influence Normalizer Main Funcion Starts Here
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
var
   Map : TVoxelMap;
   FloatMap : TVector3fMap;
   x,y,z : integer;
   Dist : TDistanceArray;
   IntRange,IntSmooth,FullRange : integer;
   Values : array of single;
begin
   // 1.36 Setup distance array
   SetupDistanceArray(Dist,_Range,_SmoothLevel,_ContrastLevel);
   // Normalizing algorithm starts here.
   Result.applied := 0;
   // Prepare and Clear FloatMap
   IntRange := Trunc(_Range);
   IntSmooth := Trunc(_SmoothLevel);
   FullRange := Max(IntSmooth,IntRange);
   SetLength(FloatMap,_Voxel.Tailer.XSize+(2*FullRange),_Voxel.Tailer.YSize+(2*FullRange),_Voxel.Tailer.ZSize+(2*FullRange));
   for x := Low(FloatMap) to High(FloatMap) do
      for y := Low(FloatMap) to High(FloatMap[x]) do
         for z := Low(FloatMap) to High(FloatMap[x,y]) do
         begin
            FloatMap[x,y,z].X := 0;
            FloatMap[x,y,z].Y := 0;
            FloatMap[x,y,z].Z := 0;
         end;
   // 1.34: Create Influence map.
   Map := TVoxelMap.CreateQuick(_Voxel,FullRange);
   if _ImproveContrast then
   begin
      Map.GenerateInfluenceMap;
      Map.MapSurfaces(4);
      SetLength(Values,6);
      Values[0] := 0;
      Values[1] := LIMZERO;
      Values[2] := 0.0000001;
      Values[3] := 0.0001;
      Values[4] := 1;
      Values[5] := 1;
      Map.ConvertValues(Values);
   end
   else
      Map.GenerateInfluenceMapOnly;

   // Now, let's normalize every voxel.
   NormalizeModel(_Voxel,Map,FloatMap,Dist,FullRange,IntRange);
   PolishModel(_Voxel,FloatMap,Dist,FullRange,IntSmooth,_SmoothMe,Result.Applied,_AffectOnlyNonNormalized);

   // Now, let's free some memory.
   for x := Low(Dist) to High(Dist) do
   begin
      for y := Low(Dist) to High(Dist[x]) do
      begin
         SetLength(Dist[x,y], 0);
      end;
      SetLength(Dist[x], 0);
   end;
   SetLength(Dist, 0);
   Map.Free;
   for x := Low(FloatMap) to High(FloatMap) do
   begin
      for y := Low(FloatMap) to High(FloatMap[x]) do
      begin
         SetLength(FloatMap[x,y], 0);
      end;
      SetLength(FloatMap[x], 0);
   end;
   SetLength(FloatMap, 0);
   SetLength(Values, 0);
end;

function ApplyNormals(var _Voxel : TVoxelSection) : TApplyNormalsResult;
var
   maxx, maxy, maxz, x, y, z: integer;
   function Empty(_x,_y,_z: integer): boolean;
   var
      v: TVoxelUnpacked;
   begin
      // check bounds
      Result := True; // outside the voxel is all empty
      if (_x < 0) or (_x > maxx) then Exit;
      if (_y < 0) or (_y > maxy) then Exit;
      if (_z < 0) or (_z > maxz) then Exit;
      // ok, do the real check
      _Voxel.GetVoxel(_x,_y,_z,v);
      if v.Used then
         Result := False
      else
         Result := true;//BitSet(v.Flags,isOutside);
   end;

   function CheckTopBottom(var _B1,_B2 : boolean) : boolean;
   var
      ZZ : integer;
      First,Second : boolean;
      v : TVoxelunpacked;
   begin
      First := True;
      if z < maxz then
         for ZZ := z+1 to Maxz do
            if First then
            begin
               _Voxel.GetVoxel(x,y,ZZ,v);
               if v.Used then
                  First := false;
            end;

      if z = maxz then
         First := true;

      Second := True;

      if z > 0 then
      begin
         for ZZ := z-1 downto 0 do
            if Second then
            begin
               _Voxel.GetVoxel(x,y,ZZ,v);
               if v.Used then
                  Second := false;
            end;
      end
      else if z = 0 then
         Second := true;

      If (First) and (not Second) then
      begin
         _B2 := true;
         _B1 := false;
         Result := true;
      end
      else If (not First) and (Second) then
      begin
         _B2 := false;
         _B1 := true;
         Result := true;
      end
      else
         Result := false;
   end;

   function CheckRightLeft(var _B1,_B2 : boolean) : boolean;
   var
      YY : integer;
      First,Second : boolean;
      v : TVoxelunpacked;
   begin
      First := True;

      if y < maxy then
         for YY := y+1 to Maxy do
            if First then
            begin
               _Voxel.GetVoxel(x,yy,z,v);
               if v.Used then
                  First := false;
            end;

      if y = maxy then
         First := true;

      Second := True;

      if y > 0 then
      begin
         for YY := y-1 downto 0 do
            if Second then
            begin
               _Voxel.GetVoxel(x,yy,z,v);
               if v.Used then
                  Second := false;
            end;
      end
      else if y = 0 then
         Second := true;

      If (First) and (not Second) then
      begin
         _B2 := true;
         _B1 := false;
         Result := true;
      end
      else If (not First) and (Second) then
      begin
         _B2 := false;
         _B1 := true;
         Result := true;
      end
      else
         Result := false;
   end;

   function CheckFrontBack(var _B1,_B2 : boolean) : boolean;
   var
      XX : integer;
      First,Second : boolean;
      v : TVoxelunpacked;
   begin
      First := True;

      if x < maxx then
         for XX := x+1 to Maxx do
            if First then
            begin
               _Voxel.GetVoxel(xx,y,z,v);
               if v.Used then
                  First := false;
            end;

      if x = maxx then
         First := true;

      Second := True;

      if x > 0 then
      begin
         for xx := x-1 downto 0 do
            if Second then
            begin
               _Voxel.GetVoxel(xx,y,z,v);
               if v.Used then
                  Second := false;
            end;
      end
      else if x = 0 then
         Second := true;

      If (First) and (not Second) then
      begin
         _B2 := false;
         _B1 := true;
         Result := true;
      end
      else If (not First) and (Second) then
      begin
         _B2 := true;
         _B1 := false;
         Result := true;
      end
      else
         Result := false;
   end;

   Procedure CalcFacing;
   var
      v: TVoxelUnpacked;
      B : array [0..5] of boolean;
      I : integer;
      Pos : TVector3i;
   begin
      // get the voxel in question
      _Voxel.GetVoxel(x,y,z,v);
      // skip empty ones
      if not v.Used then Exit;

      for i := 0 to 5 do
         B[i] := false;

      if Empty(x+1,y,z) then B[0] := true;
      if Empty(x-1,y,z) then B[1] := true;
      if Empty(x,y-1,z) then B[2] := true;
      if Empty(x,y+1,z) then B[3] := true;
      if Empty(x,y,z-1) then B[4] := true;
      if Empty(x,y,z+1) then B[5] := true;

      // cancel out double-sided facings
      if B[0] and B[1] then if not CheckFrontBack(B[0],B[1]) then
      begin
         if x > trunc(maxx/2) then
            B[1] := false
         else
            B[0] := false;  //Dec(Flags,ChooseFrontOrBack(x,y,z));
      end;
      if B[2] and B[3] then
      begin
         if not CheckRightLeft(B[2],B[3]) then
         begin
            if y < trunc(maxy/2) then
               B[3] := false
            else
               B[2] := false;
         end;
      end;
      if B[4] and B[5] then
      begin
         if not CheckTopBottom(B[4],B[5]) then
         begin
            if z < trunc(maxz/2) then
               B[5] := false
            else
               B[4] := false;
         end;
      end;

      Pos := SetVectorI(0,0,0);
      if B[0] then
         Pos.X := Pos.X + 1;
      if B[1] then
         Pos.X := Pos.X - 1;
      if B[2] then
         Pos.Y := Pos.Y - 1;
      if B[3] then
         Pos.Y := Pos.Y + 1;
      if B[4] then
         Pos.Z := Pos.Z - 1;
      if B[5] then
         Pos.Z := Pos.Z + 1;

      if (Pos.x = 0) and (Pos.z = 0) and (Pos.y = 0) then
         inc(Result.confused)
      else
      begin
         v.Normal := _Voxel.Normals.GetIDFromNormal(Pos.X,Pos.Y,Pos.Z);

         inc(Result.applied);

         _Voxel.SetVoxel(x,y,z,v);
      end;
   end;
begin
   maxx := _Voxel.Tailer.XSize - 1;
   maxy := _Voxel.Tailer.YSize - 1;
   maxz := _Voxel.Tailer.ZSize - 1;

   Result.applied := 0;
   Result.confused := 0;
   //Result.redundant := 0; // Not used!

   // examine each used voxel, pass one for outside voxels
   for x := 0 to maxx do
      for y := 0 to maxy do
         for z := 0 to maxz do
            CalcFacing;
end;

Function GetNormal3f(const _Voxel : TVoxelSection; _N : integer) : TVector3f;
begin
   Result := _Voxel.Normals[_n];
end;

function SmoothNormals(var _Voxel : TVoxelSection) : TApplyNormalsResult;
var
   x,y,z,maxx,maxy,maxz,t : integer;
   v : TVoxelUnPacked;
   VoxelSmoothData : array of TVoxelSmoothData;
   Data_no : integer;
   Function GetAverage: integer;
   var
      i : integer;
      Normals : TVector3f;
      Count : integer;
      v : TVoxelUnPacked;
   begin
      _Voxel.GetVoxelSafe(x,y,z,v);
      Count := 0;//1;

      For i := 0 to 25 do
         if _Voxel.GetVoxelSafe(x+trunc(CubeNormals[i].x),y+trunc(CubeNormals[i].y),z+trunc(CubeNormals[i].z),v) then
         begin
            Normals.X := Normals.X + GetNormal3f(_Voxel,v.Normal).x;
            Normals.Y := Normals.Y + GetNormal3f(_Voxel,v.Normal).y;
            Normals.Z := Normals.Z + GetNormal3f(_Voxel,v.Normal).z;
            inc(count);
         end;

      if count > 0 then
      begin
         Normalize(Normals);

         _Voxel.GetVoxelSafe(x,y,z,v);
         Normals.X := Normals.X + GetNormal3f(_Voxel,v.Normal).x;
         Normals.Y := Normals.Y + GetNormal3f(_Voxel,v.Normal).y;
         Normals.Z := Normals.Z + GetNormal3f(_Voxel,v.Normal).z;

         Normalize(Normals);
         Result := _Voxel.Normals.GetIDFromNormal(Normals);
      end
      else
      begin
         _Voxel.GetVoxelSafe(x,y,z,v);
         Result := v.Normal;
      end;
   end;
begin
   maxx := _Voxel.Tailer.XSize - 1;
   maxy := _Voxel.Tailer.YSize - 1;
   maxz := _Voxel.Tailer.ZSize - 1;

   Result.applied := 0;
   Result.confused := 0;

   Data_no := 0;
   SetLength(VoxelSmoothData,Data_no);

   for x := 0 to maxx do
      for y := 0 to maxy do
         for z := 0 to maxz do
         begin
            _Voxel.GetVoxel(x,y,z,v);
            if V.Used then
            begin
               T := GetAverage;

               if T = V.Normal then
                  inc(Result.confused)
               else
                  inc(Result.applied);
               V.Normal := T;

               inc(Data_no);
               SetLength(VoxelSmoothData,Data_no);
               VoxelSmoothData[Data_no-1].Pos.X := x;
               VoxelSmoothData[Data_no-1].Pos.Y := y;
               VoxelSmoothData[Data_no-1].Pos.Z := z;
               VoxelSmoothData[Data_no-1].v.Colour := v.Colour;
               VoxelSmoothData[Data_no-1].v.Normal := v.Normal;
               VoxelSmoothData[Data_no-1].v.Flags := v.Flags;
               VoxelSmoothData[Data_no-1].v.Used := v.Used;
               _Voxel.SetVoxel(x,y,z,v);
            end;
         end;

   SetLength(VoxelSmoothData,0);
end;

function RemoveRedundantVoxels(var _Voxel: TVoxelSection): integer;
var
   Map : TVoxelMap;
   Values : array of single;
begin
   Map := TVoxelMap.CreateQuick(_Voxel,1);
   Map.GenerateSurfaceMap;
   SetLength(Values,6);
   Values[0] := 0;
   Values[1] := 0;
   Values[2] := 0;
   Values[3] := 0;
   Values[4] := 1;
   Values[5] := 0;
   Map.ConvertValues(Values);
   Result := Map.SynchronizeWithSection(1);
   Map.Free;
   SetLength(Values, 0);
end;


function GetSmoothNormal(var _Voxel : TVoxelSection; _X,_Y,_Z,Normal : integer) : integer;
var
   t,maxx,maxy,maxz : integer;
   v : TVoxelUnPacked;

   // Get voxel data
   Function GetAverage: integer;
   var
      i : integer;
      Normals : TVector3f;
      Count : integer;
      v : TVoxelUnPacked;
   begin
      _Voxel.GetVoxelSafe(_x,_y,_z,v);
//      Result := V.Normal;
      Count := 0;
      For i := 0 to 25 do
         if _Voxel.GetVoxelSafe(_x+trunc(CubeNormals[i].x),_y+trunc(CubeNormals[i].y),_z+trunc(CubeNormals[i].z),v) then
         begin
            Normals.X := Normals.X + GetNormal3f(_Voxel,v.Normal).x;
            Normals.Y := Normals.Y + GetNormal3f(_Voxel,v.Normal).y;
            Normals.Z := Normals.Z + GetNormal3f(_Voxel,v.Normal).z;
            inc(count);
         end;

      if count > 0 then
      begin
         Normalize(Normals);
         _Voxel.GetVoxelSafe(_x,_y,_z,v);
         Normals.X := Normals.X + GetNormal3f(_Voxel,v.Normal).x;
         Normals.Y := Normals.Y + GetNormal3f(_Voxel,v.Normal).y;
         Normals.Z := Normals.Z + GetNormal3f(_Voxel,v.Normal).z;
         Normalize(Normals);
         Result := _Voxel.Normals.GetIDFromNormal(Normals);
      end
      else
      begin
         _Voxel.GetVoxelSafe(_x,_y,_z,v);
         Result := v.Normal;
      end;
   end;
//
// Main Smmothing Function Starts HERE
//
begin
   maxx := _Voxel.Tailer.XSize - 1;
   maxy := _Voxel.Tailer.YSize - 1;
   maxz := _Voxel.Tailer.ZSize - 1;

   _Voxel.GetVoxel(_x,_y,_z,v);
   if V.Used then
   begin
      T := GetAverage;
      Result := T;
   end
   else
      Result := Normal;
end;

// Adapted code from HBD starts here
// ----------------------------------------------

// HBD's latest invention!
// 6-faced method extended.
procedure velAutoNormals2(_Sect: TVoxelSection; _Range, _Smooth: Single);
type
   TArray3i = array[0..2] of Integer;
   TOrient = record
      CM: array[0..2] of Integer;
      SignC, SignA: Integer;
   end;
   TFaceMap = array of array of array of array[0..2] of TArray3i;
var
   Map: TVoxelMap; //T3DIntGrid;
   FaceMap,FaceMap2: TFaceMap;
   S,D, temp: ^TFaceMap;
   PointList: array of TVector3b;
   N: TArray3i;
   Orient1,Orient2: TOrient;
   NPoint, i, j, x,y,z: Integer;

   // Find adjacent face
   procedure Succeed(var _P: TArray3i; var _O: TOrient);
   var
      temp: Integer;
   begin
      with _O do
      begin
         Inc(_P[CM[0]],SignA);
         Inc(_P[CM[2]],SignC);
         if Map[_P[0],_P[1],_P[2]] = C_SURFACE then
         begin
            temp := CM[0];
            CM[0] := CM[2];
            CM[2] := temp;
            temp := SignA;
            SignA := SignC;
            SignC := -temp;
         end
         else
         begin
            Dec(_P[CM[2]],SignC);
            if Map[_P[0],_P[1],_P[2]]<> C_SURFACE then
            begin
               Dec(_P[CM[0]],SignA);
               temp := CM[0];
               CM[0] := CM[2];
               CM[2] := temp;
               temp := SignA;
               SignA := -SignC;
               SignC := temp;
            end
         end
      end
   end;

   procedure DoBranch2(_IC,_IA,_IB,_SC,_SA: Integer);
   var
      P1,P2: TArray3i;
      i,j: Cardinal;
   begin
      P1[0] := x;
      P1[1] := y;
      P1[2] := z;
      with Orient1 do
      begin
         CM[0] := _IA;
         CM[1] := _IB;
         CM[2] := _IC;
         SignC := _SC;
         SignA := _SA;
      end;
      i := Trunc(_Range);
      while not (i=0) do
      begin
         Succeed(P1,Orient1);
         with Orient1 do
         begin
            Dec(P1[CM[2]],SignC shr 31);
            Inc(N[0],S^[P1[0],P1[1],P1[2],CM[2],0]*2);
            Inc(N[1],S^[P1[0],P1[1],P1[2],CM[2],1]*2);
            Inc(N[2],S^[P1[0],P1[1],P1[2],CM[2],2]*2);
            Inc(P1[CM[2]],SignC shr 31);
         end;
         //Inc(N[CM[2]],SignC+SignC);

         j := Trunc(_Range);
         P2 := P1;
         with Orient2 do
         begin
            CM[0] := _IB;
            CM[1] := _IA;
            CM[2] := _IC;
            SignC := _SC;
            SignA := -1;
         end;

         while not (j=0) do
         begin
            Succeed(P2,Orient2);
            with Orient2 do
            begin
               Dec(P2[CM[2]],SignC shr 31);
               Inc(N[0],S^[P2[0],P2[1],P2[2],CM[2],0]);
               Inc(N[1],S^[P2[0],P2[1],P2[2],CM[2],1]);
               Inc(N[2],S^[P2[0],P2[1],P2[2],CM[2],2]);
               Inc(P2[CM[2]],SignC shr 31);
            end;
            // Inc(N[CM[2]],SignC);
            Dec(j);
         end;

         j := Trunc(_Range);
         P2 := P1;
         with Orient2 do
         begin
            CM[0] := _IB;
            CM[1] := _IA;
            CM[2] := _IC;
            SignC := _SC;
            SignA := +1;
         end;

         while not (j=0) do
         begin
            Succeed(P2,Orient2);
            with Orient2 do
            begin
               Dec(P2[CM[2]],SignC shr 31);
               Inc(N[0],S^[P2[0],P2[1],P2[2],CM[2],0]);
               Inc(N[1],S^[P2[0],P2[1],P2[2],CM[2],1]);
               Inc(N[2],S^[P2[0],P2[1],P2[2],CM[2],2]);
               Inc(P2[CM[2]],SignC shr 31);
            end;
            Dec(j);
         end;

         Dec(i);
      end;
   end;

   procedure DoBranch1(_IC,_IA,_IB:Integer);
   var
      P: TArray3i; o: Integer;
   begin
      P[0] := x;
      P[1] := y;
      P[2] := z;
      o := P[_IC];

      P[_IC] := o-1;
      if Map[P[0],P[1],P[2]] = C_OUTSIDE_VOLUME then
      begin
         N[0] := 0;
         N[1] := 0;
         N[2] := 0;
         DoBranch2(_IC,_IA,_IB,-1,-1);
         DoBranch2(_IC,_IA,_IB,-1,+1);
         DoBranch2(_IC,_IB,_IA,-1,-1);
         DoBranch2(_IC,_IB,_IA,-1,+1);
         Inc(N[0],S^[P[0],P[1],P[2],_IC,0]*2);
         Inc(N[1],S^[P[0],P[1],P[2],_IC,1]*2);
         Inc(N[2],S^[P[0],P[1],P[2],_IC,2]*2);
         D^[P[0],P[1],P[2],_IC] := N;
      end;

      P[_IC] := o+1;
      if Map[P[0],P[1],P[2]] = C_OUTSIDE_VOLUME then
      begin
         N[0] := 0;
         N[1] := 0;
         N[2] := 0;
         DoBranch2(_IC,_IA,_IB,+1,-1);
         DoBranch2(_IC,_IA,_IB,+1,+1);
         DoBranch2(_IC,_IB,_IA,+1,-1);
         DoBranch2(_IC,_IB,_IA,+1,+1);
         P[_IC] := o;
         Inc(N[0],S^[P[0],P[1],P[2],_IC,0]*2);
         Inc(N[1],S^[P[0],P[1],P[2],_IC,1]*2);
         Inc(N[2],S^[P[0],P[1],P[2],_IC,2]*2);
         D^[P[0],P[1],P[2],_IC] := N;
      end;
   end;

   procedure MergeFaces(_X,_Y,_Z: Integer);
   var
      i: Cardinal;
      v : TVoxelUnPacked;
   begin
      for i := 0 to 2 do
      begin
         N[i] := D^[_X-1,_Y,_Z,0,i] + D^[_X,_Y,_Z,0,i] + D^[_X,_Y-1,_Z,1,i] + D^[_X,_Y,_Z,1,i] + D^[_X,_Y,_Z-1,2,i] + D^[_X,_Y,_Z,2,i];
      end;
      _Sect.GetVoxel(_X-1,_Y-1,_Z-1,v);
      v.Normal := _Sect.Normals.GetIDFromNormal(SetVector(N[0],N[1],N[2]));
      _Sect.SetVoxel(_X-1,_Y-1,_Z-1,v);
  end;

begin
   Map := TVoxelMap.CreateQuick(_Sect,1);
   Map.GenerateSurfaceMap;
   SetLength(FaceMap,_Sect.Tailer.XSize+1,_Sect.Tailer.YSize+1,_Sect.Tailer.ZSize+1);
   SetLength(FaceMap2,_Sect.Tailer.XSize+1,_Sect.Tailer.YSize+1,_Sect.Tailer.ZSize+1);
   SetLength(PointList,_Sect.Tailer.XSize*_Sect.Tailer.YSize*_Sect.Tailer.ZSize);
   NPoint := 0;
   for x:=1 to _Sect.Tailer.XSize do
   begin
      for y:=1 to _Sect.Tailer.YSize do
      begin
         for z:=1 to _Sect.Tailer.ZSize do
         begin
            if map[x,y,z] = C_SURFACE then
            begin
               PointList[NPoint].R := x;
               PointList[NPoint].G := y;
               PointList[NPoint].B := z;
               Inc(NPoint);
               if Map[x-1,y,z]=C_OUTSIDE_VOLUME then
                  FaceMap[x-1,y,z,0,0] := -1;
               if Map[x+1,y,z]=C_OUTSIDE_VOLUME then
                  FaceMap[x  ,y,z,0,0] := +1;
               if Map[x,y-1,z]=C_OUTSIDE_VOLUME then
                  FaceMap[x,y-1,z,1,1] := -1;
               if Map[x,y+1,z]=C_OUTSIDE_VOLUME then
                  FaceMap[x,y  ,z,1,1] := +1;
               if Map[x,y,z-1]=C_OUTSIDE_VOLUME then
                  FaceMap[x,y,z-1,2,2] := -1;
               if Map[x,y,z+1]=C_OUTSIDE_VOLUME then
                  FaceMap[x,y,z  ,2,2] := +1;
            end;
         end;
      end;
   end;
   S := @FaceMap2;
   D := @FaceMap;
   j := Trunc(_Smooth)+1;
   while not (j=0) do
   begin
      temp := S;
      S := D;
      D := temp;
      for i:=0 to NPoint-1 do
      begin
         x := PointList[i].R;
         y := PointList[i].G;
         z := PointList[i].B;
         DoBranch1(0,1,2);
         DoBranch1(1,2,0);
         DoBranch1(2,0,1);
      end;
      Dec(j)
   end;
   for i:=0 to NPoint-1 do
      with PointList[i] do
         MergeFaces(X,Y,Z);
   SetLength(PointList,0);
   for x := Low(FaceMap) to High(FaceMap) do
   begin
      for y := Low(FaceMap) to High(FaceMap[x]) do
      begin
         SetLength(FaceMap[x,y], 0);
      end;
      SetLength(FaceMap[x], 0);
   end;
   SetLength(FaceMap, 0);
   for x := Low(FaceMap2) to High(FaceMap2) do
   begin
      for y := Low(FaceMap2) to High(FaceMap2[x]) do
      begin
         SetLength(FaceMap2[x,y], 0);
      end;
      SetLength(FaceMap2[x], 0);
   end;
   SetLength(FaceMap2, 0);
   Map.Free;
end;

end.

