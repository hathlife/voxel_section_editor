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

Uses BasicDataTypes,Voxel,normals,Voxel_Engine,math,math3d,Dialogs,Sysutils,
   VoxelMap, BasicFunctions;

type
   TApplyNormalsResult = record
      applied,
      confused: Integer;
   end;

   TVoxelSmoothData = record
     Pos : TVector3i;
     V : TVoxelUnpacked;
   end;

   TDistanceUnit = record
      x,
      y,
      z,
      Distance : single;
   end;


const
   // 1.2 Cubed Normals Constants:
   DIST2 = 0.707106781186547524400844362104849; // sqrt(2)/2
   DIST3 = 0.577350269189625764509148780501957; // sqrt(3)/3
   LIMZERO = 0.0000000000001;
   TIP = 1;

type
   TBinaryMap = array of array of array of single; //byte;
   TBooleanMap = array of array of array of boolean;
   TVector3fMap = array of array of array of TVector3f;
   TDistanceArray = array of array of array of TDistanceUnit; //single;


//applies normals
function ApplyNormals(Voxel : TVoxelSection) : TApplyNormalsResult;
function ApplyCubedNormals(Voxel : TVoxelSection; Range,SmoothLevel : single; ContrastLevel : integer; SmoothMe,InfluenceMe,AffectOnlyNonNormalized : Boolean) : TApplyNormalsResult;
function ApplyInfluenceNormals(Voxel : TVoxelSection; Range,SmoothLevel : single; ContrastLevel : integer; SmoothMe,AffectOnlyNonNormalized,ImproveContrast : boolean) : TApplyNormalsResult;
function RemoveRedundantVoxels(Voxel : TVoxelSection) : integer;
function SmoothNormals(var Vxl : TVoxelSection) : TApplyNormalsResult;
function GetSmoothNormal(var Vxl : TVoxelSection; X,Y,Z,Normal : integer) : integer;

// Random functions
procedure GetPreliminaryNormals(const Map: TVoxelMap; var FloatMap : TVector3fMap; const Dist: TDistanceArray; var V : TVoxelUnpacked; MidPoint,Range,_x,_y,_z : integer);
function GetNonZeroSign(const value : single) : shortint;
function GetTrueSign(var value,signal : single; minVar, maxVar : integer) : shortint;

implementation

{uses SysUtils;}

procedure VecToAngles(const _In: TVector3f ; var angles: TVector3f);
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

  angles.x := -pitch;
  angles.y := yaw;
  angles.z := 0;
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
procedure GetPreliminaryNormals(const Map: TVoxelMap; var FloatMap : TVector3fMap; const Dist: TDistanceArray; var V : TVoxelUnpacked; MidPoint,Range,_x,_y,_z : integer);
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
   if not V.Used then exit;

   x := MidPoint + _x;
   y := MidPoint + _y;
   z := MidPoint + _z;

   MinPoint.X := x - Range;
   MaxPoint.X := x + Range;
   MinPoint.Y := y - Range;
   MaxPoint.Y := y + Range;
   MinPoint.Z := z - Range;
   MaxPoint.Z := z + Range;

   Res.X := 0;
   Res.Y := 0;
   Res.Z := 0;
   Sum.X := 0;
   Sum.Y := 0;
   Sum.Z := 0;

   // This is the centralizer factor, so it will make MyPoint points to
   // the position of the filter based on its center.
   MidPointMinusRange := MidPoint - Range;

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
            Res.X := Res.X + (Map[xx,yy,zz] * Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].X);
            Res.Y := Res.Y + (Map[xx,yy,zz] * Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Y);
            Res.Z := Res.Z + (Map[xx,yy,zz] * Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Z);
            Sum.X := Sum.X + abs(Map[xx,yy,zz] * Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].X);
            Sum.Y := Sum.Y + abs(Map[xx,yy,zz] * Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Y);
            Sum.Z := Sum.Z + abs(Map[xx,yy,zz] * Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Z);
         end;

   if Sum.X <> 0 then
      FloatMap[x,y,z].X := Res.X / Sum.X
   else
      FloatMap[x,y,z].X := 0;
   if Sum.Y <> 0 then
      FloatMap[x,y,z].Y := Res.Y / Sum.Y
   else
      FloatMap[x,y,z].Y := 0;
   if Sum.Z <> 0 then
      FloatMap[x,y,z].Z := Res.Z / Sum.Z
   else
      FloatMap[x,y,z].Z := 0;
end;

function GetNonZeroSign(const value : single) : shortint;
begin
   Result := sign(value);
   if Result = 0 then
      Result := 1;
 end;

function GetTrueSign(var value,signal : single; minVar, maxVar: integer) : shortint;
begin
   Result := sign(value);
   if Result = 0 then
   begin
      Result := sign(signal);
      if Result = 0 then
      begin
         // we need to do some magic here.
         if minVar <= (maxVar div 2) then
            Result := 1
         else
            Result := -1;
      end;
   end;
end;

procedure GetNewNormals(var Voxel : TVoxelSection; const BM: TVector3fMap; const Dist : TDistanceArray; var V : TVoxelUnpacked; MidPoint,Range,_x,_y,_z : integer; var applied : integer);
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
   if not V.Used then exit;

   x := MidPoint + _x;
   y := MidPoint + _y;
   z := MidPoint + _z;

   MinPoint.X := x - Range;
   MaxPoint.X := x + Range;
   MinPoint.Y := y - Range;
   MaxPoint.Y := y + Range;
   MinPoint.Z := z - Range;
   MaxPoint.Z := z + Range;

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
   MidPointMinusRange := MidPoint - Range;

   // Let's grab the new res
   for xx := MinPoint.X to MaxPoint.X do
      for yy := MinPoint.Y to MaxPoint.Y do
         for zz := MinPoint.Z to MaxPoint.Z do
         begin
            // Set MyPoint
            MyPoint.X := xx - MinPoint.X + MidPointMinusRange;
            MyPoint.Y := yy - MinPoint.Y + MidPointMinusRange;
            MyPoint.Z := zz - MinPoint.Z + MidPointMinusRange;
            if Voxel.GetVoxelSafe(xx - MidPoint,yy - MidPoint,zz - MidPoint,CurrentVoxel) then
               if CurrentVoxel.Used then
               begin
                  newvalue := Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance * BM[xx,yy,zz].X;
                  res.X := res.X + abs(NewValue);// * GetNonZeroSign(BM[xx,yy,zz].X));
                  signal.X := signal.X + NewValue;
                  xcounter := xcounter + Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance;
                  NewValue := Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance * BM[xx,yy,zz].Y;
                  res.Y := res.Y + abs(NewValue); // * GetNonZeroSign(BM[xx,yy,zz].Y));
                  signal.X := signal.X + NewValue;
                  ycounter := ycounter + Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance;
                  NewValue := Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance * BM[xx,yy,zz].Z;
                  res.Z := res.Z + abs(NewValue); // * GetNonZeroSign(BM[xx,yy,zz].Z));
                  signal.Z := signal.Z + NewValue;
                  zcounter := zcounter + Dist[MyPoint.X,MyPoint.Y,MyPoint.Z].Distance;
               end;
         end;
   if xcounter > 0 then
      res.X := (res.X / xcounter) * GetTrueSign(BM[x,y,z].X,signal.X,_x,Voxel.Tailer.XSize);
   if ycounter > 0 then
      res.Y := (res.Y / ycounter) * GetTrueSign(BM[x,y,z].Y,signal.Y,_y,Voxel.Tailer.YSize);
   if zcounter > 0 then
      res.Z := (res.Z / zcounter) * GetTrueSign(BM[x,y,z].Z,signal.Z,_z,Voxel.Tailer.ZSize);

   // Normalization process.
   Normalize(res);
   v.Normal := Voxel.Normals.GetIDFromNormal(res);

   // Apply
   Voxel.SetVoxel(_x,_y,_z,V);
   inc(applied);
end;

procedure GetNewNormalsWithNoSmooth(var Voxel: TVoxelSection; const BM: TVector3fMap; var V : TVoxelUnpacked; Range,_x,_y,_z : integer; var applied : integer);
var
   x,y,z : integer;
begin
   // Security checkup.
   if not V.Used then exit;

   x := _x + Range;
   y := _y + Range;
   z := _z + Range;

   // Normalization process.
   Normalize(BM[x,y,z]);
   V.Normal := Voxel.Normals.GetIDFromNormal(BM[x,y,z]);

   // Apply
   Voxel.SetVoxel(_x,_y,_z,V);
   inc(applied);
end;

procedure ResetBinaryMap(const Voxel: TVoxelSection; var Map : TBinaryMap; Range: integer);
var
   DoubleRange : integer;
   x,y,z : integer;
begin
   DoubleRange := 2 * Range;
   // Set memory for binary map. Extra memory avoids bound checking
   SetLength(Map,Voxel.Tailer.XSize+DoubleRange,Voxel.Tailer.YSize+DoubleRange,Voxel.Tailer.ZSize+DoubleRange);

   // Clear map
   for x := Low(Map) to High(Map) do
      for y := Low(Map) to High(Map[x]) do
         for z := Low(Map) to High(Map[x,y]) do
             Map[x,y,z] := 0;
end;


procedure SetupDistanceArray(var Dist : TDistanceArray; Range,SmoothLevel : single; ContrastLevel : integer);
var
   x,y,z : integer;
   Size,MidPoint : integer;
   Distance: single;//,Distance2D : single;
begin
   // 1.36 Setup distance array
   MidPoint := Max(Trunc(SmoothLevel),Trunc(Range));
   Size := (2*MidPoint)+1;
   SetLength(Dist,Size,Size,Size);
   Dist[MidPoint,MidPoint,MidPoint].Distance := 1;
   Dist[MidPoint,MidPoint,MidPoint].X := 0;
   Dist[MidPoint,MidPoint,MidPoint].Y := 0;
   Dist[MidPoint,MidPoint,MidPoint].Z := 0;
   for x := Low(Dist) to High(Dist) do
   begin
      for y := Low(Dist[x]) to High(Dist[x]) do
      begin
         for z := Low(Dist[x,y]) to High(Dist[x,y]) do
         begin
            Distance := sqrt(((x - MidPoint) * (x - MidPoint)) + ((y - MidPoint) * (y - MidPoint)) + ((z - MidPoint) * (z - MidPoint)));
            if Distance > 0 then
            begin
               if Distance <= SmoothLevel then
               begin
                  Dist[x,y,z].Distance := 1 / Power(Distance,ContrastLevel);
               end
               else
               begin
                  Dist[x,y,z].Distance := 0;
               end;
               if (Distance <= Range) then
               begin
                  if MidPoint <> x then
                     Dist[x,y,z].X :=  (3 * (MidPoint - x)) / Power(Distance,3)
                  else
                     Dist[x,y,z].X := 0;

                  if MidPoint <> y then
                     Dist[x,y,z].Y :=  (3 * (MidPoint - y)) / Power(Distance,3)
                  else
                     Dist[x,y,z].Y := 0;

                  if MidPoint <> z then
                     Dist[x,y,z].Z :=  (3 * (MidPoint - z)) / Power(Distance,3)
                  else
                     Dist[x,y,z].Z := 0;
               end
               else
               begin
                  Dist[x,y,z].X := 0;
                  Dist[x,y,z].Y := 0;
                  Dist[x,y,z].Z := 0;
               end;
            end
            else
            begin
               Dist[x,y,z].Distance := 0;
               Dist[x,y,z].X := 0;
               Dist[x,y,z].Y := 0;
               Dist[x,y,z].Z := 0;
            end;
         end;
      end;
   end;
end;

procedure NormalizeModel(var Voxel : TVoxelSection; const Map : TVoxelMap; var FloatMap: TVector3fMap; const Dist : TDistanceArray; MidPoint,Range : integer);
var
   x,y,z : integer;
   V : TVoxelUnpacked;
begin
   // Now, let's normalize every voxel.
   for x := 0 to Voxel.Tailer.XSize-1 do
      for y := 0 to Voxel.Tailer.YSize-1 do
         for z := 0 to Voxel.Tailer.ZSize-1 do
         begin
            // Get voxel data and calculate it (added +1 to
            // each, since binary map has propositally a
            // border to avoid bound checking).
            Voxel.GetVoxel(x,y,z,v);
            GetPreliminaryNormals(Map,FloatMap,Dist,V,MidPoint,Range,x,y,z);
         end;
end;

procedure PolishModel(var Voxel : TVoxelSection; var FloatMap: TVector3fMap; const Dist : TDistanceArray; MidPoint,Range : integer; SmoothMe: boolean; var Applied : integer; AffectOnlyNonNormalized : Boolean);
var
   x,y,z : integer;
   V : TVoxelUnpacked;
begin
   if SmoothMe then
   begin
      for x := 0 to Voxel.Tailer.XSize-1 do
         for y := 0 to Voxel.Tailer.YSize-1 do
            for z := 0 to Voxel.Tailer.ZSize-1 do
            begin
               Voxel.GetVoxel(x,y,z,v);
               if (not AffectOnlyNonNormalized) or (v.Normal = 0) then
                  GetNewNormals(Voxel,FloatMap,Dist,V,MidPoint,Range,x,y,z,Applied);
            end;
   end
   else
   begin
      for x := 0 to Voxel.Tailer.XSize-1 do
         for y := 0 to Voxel.Tailer.YSize-1 do
            for z := 0 to Voxel.Tailer.ZSize-1 do
            begin
               Voxel.GetVoxel(x,y,z,v);
               if (not AffectOnlyNonNormalized) or (v.Normal = 0) then
                  GetNewNormalsWithNoSmooth(Voxel,FloatMap,V,Range,x,y,z,Applied);
            end;
   end;
end;

// 1.2 Adition: Cubed Normalizer
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
// Cubed Normals 2x Main Funcion Starts Here
//*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
function ApplyCubedNormals(Voxel : TVoxelSection; Range,SmoothLevel : single; ContrastLevel : integer; SmoothMe,InfluenceMe,AffectOnlyNonNormalized : Boolean) : TApplyNormalsResult;
var
   Map : TVoxelMap;
   FloatMap : TVector3fMap;
   x,y,z : integer;
   Dist : TDistanceArray;
   IntRange,IntSmooth,FullRange : integer;
   Values : array of single;
begin
   // 1.36 Setup distance array
   IntRange := Trunc(Range);
   IntSmooth := Trunc(SmoothLevel);
   FullRange := Max(IntSmooth,IntRange);
   SetupDistanceArray(Dist,Range,SmoothLevel,ContrastLevel);
   SetLength(FloatMap,Voxel.Tailer.XSize+(2*FullRange),Voxel.Tailer.YSize+(2*FullRange),Voxel.Tailer.ZSize+(2*FullRange));
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
   Map := TVoxelMap.Create(Voxel,FullRange);
   Map.GenerateVolumeMap;
   // 1.32: Solves limit (x,y,z) -> (0,0,0) on cubed normalizer.
   if InfluenceMe then
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
   NormalizeModel(Voxel,Map,FloatMap,Dist,FullRange,IntRange);
   PolishModel(Voxel,FloatMap,Dist,FullRange,IntSmooth,SmoothMe,Result.Applied,AffectOnlyNonNormalized);
   // Now, let's free some memory.
   Finalize(Dist);
   Map.Free;
   Finalize(FloatMap);
end;


// 1.3 Adition: Influence Normalizer
function ApplyInfluenceNormals(Voxel : TVoxelSection; Range,SmoothLevel : single; ContrastLevel : integer; SmoothMe,AffectOnlyNonNormalized,ImproveContrast : boolean) : TApplyNormalsResult;
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
   SetupDistanceArray(Dist,Range,SmoothLevel,ContrastLevel);
   // Normalizing algorithm starts here.
   Result.applied := 0;
   // Prepare and Clear FloatMap
   IntRange := Trunc(Range);
   IntSmooth := Trunc(SmoothLevel);
   FullRange := Max(IntSmooth,IntRange);
   SetLength(FloatMap,Voxel.Tailer.XSize+(2*FullRange),Voxel.Tailer.YSize+(2*FullRange),Voxel.Tailer.ZSize+(2*FullRange));
   for x := Low(FloatMap) to High(FloatMap) do
      for y := Low(FloatMap) to High(FloatMap[x]) do
         for z := Low(FloatMap) to High(FloatMap[x,y]) do
         begin
            FloatMap[x,y,z].X := 0;
            FloatMap[x,y,z].Y := 0;
            FloatMap[x,y,z].Z := 0;
         end;
   // 1.34: Create Influence map.
   Map := TVoxelMap.Create(Voxel,FullRange);
   if ImproveContrast then
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
   NormalizeModel(Voxel,Map,FloatMap,Dist,FullRange,IntRange);
   PolishModel(Voxel,FloatMap,Dist,FullRange,IntSmooth,SmoothMe,Result.Applied,AffectOnlyNonNormalized);

   // Now, let's free some memory.
   Finalize(Dist);
   Map.Free;
   Finalize(FloatMap);
end;

function ApplyNormals(Voxel : TVoxelSection) : TApplyNormalsResult;
var maxx, maxy, maxz,
    x, y, z: integer;
   function Empty(x,y,z: integer): boolean;
   var
      v: TVoxelUnpacked;
   begin
      // check bounds
      Result := True; // outside the voxel is all empty
      if (x < 0) or (x > maxx) then Exit;
      if (y < 0) or (y > maxy) then Exit;
      if (z < 0) or (z > maxz) then Exit;
      // ok, do the real check
      voxel.GetVoxel(x,y,z,v);
      if v.Used then
         Result := False
      else
         Result := true;//BitSet(v.Flags,isOutside);
   end;

   function CheckTopBottom(var b1,b2 : boolean) : boolean;
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
               voxel.GetVoxel(x,y,ZZ,v);
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
               voxel.GetVoxel(x,y,ZZ,v);
               if v.Used then
                  Second := false;
            end;
      end
      else if z = 0 then
         Second := true;

      If (First) and (not Second) then
      begin
         B2 := true;
         B1 := false;
         Result := true;
      end
      else If (not First) and (Second) then
      begin
         B2 := false;
         B1 := true;
         Result := true;
      end
      else
         Result := false;
   end;

   function CheckRightLeft(var b1,b2 : boolean) : boolean;
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
               voxel.GetVoxel(x,yy,z,v);
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
               voxel.GetVoxel(x,yy,z,v);
               if v.Used then
                  Second := false;
            end;
      end
      else if y = 0 then
         Second := true;

      If (First) and (not Second) then
      begin
         B2 := true;
         B1 := false;
         Result := true;
      end
      else If (not First) and (Second) then
      begin
         B2 := false;
         B1 := true;
         Result := true;
      end
      else
         Result := false;
   end;

   function CheckFrontBack(var b1,b2 : boolean) : boolean;
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
               voxel.GetVoxel(xx,y,z,v);
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
               voxel.GetVoxel(xx,y,z,v);
               if v.Used then
                  Second := false;
            end;
      end
      else if x = 0 then
         Second := true;

      If (First) and (not Second) then
      begin
         B2 := false;
         B1 := true;
         Result := true;
      end
      else If (not First) and (Second) then
      begin
         B2 := true;
         B1 := false;
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
      voxel.GetVoxel(x,y,z,v);
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
      if B[0] and B[1] then if not CheckFrontBack(B[0],B[1]) then if x > trunc(maxx/2) then B[1] := false else B[0] := false;  //Dec(Flags,ChooseFrontOrBack(x,y,z));
      if B[2] and B[3] then if not CheckRightLeft(B[2],B[3]) then if y < trunc(maxy/2) then B[3] := false else B[2] := false;
      if B[4] and B[5] then if not CheckTopBottom(B[4],B[5]) then if z < trunc(maxz/2) then B[5] := false else B[4] := false;

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
         v.Normal := Voxel.Normals.GetIDFromNormal(Pos.X,Pos.Y,Pos.Z);

         inc(Result.applied);

         voxel.SetVoxel(x,y,z,v);
      end;
   end;
begin
   maxx := voxel.Tailer.XSize - 1;
   maxy := voxel.Tailer.YSize - 1;
   maxz := voxel.Tailer.ZSize - 1;

   Result.applied := 0;
   Result.confused := 0;
   //Result.redundant := 0; // Not used!

   // examine each used voxel, pass one for outside voxels
   for x := 0 to maxx do
      for y := 0 to maxy do
         for z := 0 to maxz do
            CalcFacing;
end;

Function GetNormal3f(Vxl : TVoxelSection; N : integer) : TVector3f;
begin
   Result := Vxl.Normals[n];
end;

function SmoothNormals(var Vxl : TVoxelSection) : TApplyNormalsResult;
var
   x,y,z,maxx,maxy,maxz,t : integer;
   v : TVoxelUnPacked;
   VoxelSmoothData : array of TVoxelSmoothData;
   Data_no : integer;
   function GetVoxel(x,y,z: integer; var v : TVoxelUnpacked): boolean;
   begin
      // check bounds
      Result := false; // outside the voxel is all empty
      if (x < 0) or (x > maxx) then Exit;
      if (y < 0) or (y > maxy) then Exit;
      if (z < 0) or (z > maxz) then Exit;
      // ok, do the real check
      vxl.GetVoxel(x,y,z,v);
      Result := v.Used;
   end;
   Function GetAverage: integer;
   var
      i : integer;
      Normals : TVector3f;
      Count : integer;
      v : TVoxelUnPacked;
   begin
      GetVoxel(x,y,z,v);
      Count := 0;//1;

      For i := 0 to 25 do
         if GetVoxel(x+trunc(CubeNormals[i].x),y+trunc(CubeNormals[i].y),z+trunc(CubeNormals[i].z),v) then
         begin
            Normals.X := Normals.X + GetNormal3f(Vxl,v.Normal).x;
            Normals.Y := Normals.Y + GetNormal3f(Vxl,v.Normal).y;
            Normals.Z := Normals.Z + GetNormal3f(Vxl,v.Normal).z;
            inc(count);
         end;

      if count > 0 then
      begin
         Normalize(Normals);

         GetVoxel(x,y,z,v);
         Normals.X := Normals.X + GetNormal3f(Vxl,v.Normal).x;
         Normals.Y := Normals.Y + GetNormal3f(Vxl,v.Normal).y;
         Normals.Z := Normals.Z + GetNormal3f(Vxl,v.Normal).z;

         Normalize(Normals);
         Result := Vxl.Normals.GetIDFromNormal(Normals);
      end
      else
      begin
         GetVoxel(x,y,z,v);
         Result := v.Normal;
      end;
   end;
begin
   maxx := vxl.Tailer.XSize - 1;
   maxy := vxl.Tailer.YSize - 1;
   maxz := vxl.Tailer.ZSize - 1;

   Result.applied := 0;
   Result.confused := 0;

   Data_no := 0;
   SetLength(VoxelSmoothData,Data_no);

   for x := 0 to maxx do
      for y := 0 to maxy do
         for z := 0 to maxz do
         begin
            vxl.GetVoxel(x,y,z,v);
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
               vxl.SetVoxel(x,y,z,v);
            end;
         end;

   SetLength(VoxelSmoothData,0);
end;

function RemoveRedundantVoxels(voxel: TVoxelSection): integer;
var
   Map : TVoxelMap;
   Values : array of single;
begin
   Map := TVoxelMap.Create(Voxel,1);
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
end;


function GetSmoothNormal(var Vxl : TVoxelSection; X,Y,Z,Normal : integer) : integer;
var
   t,maxx,maxy,maxz : integer;
   v : TVoxelUnPacked;

   // Get voxel data
   function GetVoxel(x,y,z: integer; var v : TVoxelUnpacked): boolean;
   begin
      // check bounds
      Result := false; // outside the voxel is all empty
      if (x < 0) or (x > maxx) then Exit;
      if (y < 0) or (y > maxy) then Exit;
      if (z < 0) or (z > maxz) then Exit;
      // ok, do the real check
      vxl.GetVoxel(x,y,z,v);
      Result := v.Used;
   end;

   Function GetAverage: integer;
   var
      i : integer;
      Normals : TVector3f;
      Count : integer;
      v : TVoxelUnPacked;
   begin
      GetVoxel(x,y,z,v);
//      Result := V.Normal;
      Count := 0;
      For i := 0 to 25 do
         if GetVoxel(x+trunc(CubeNormals[i].x),y+trunc(CubeNormals[i].y),z+trunc(CubeNormals[i].z),v) then
         begin
            Normals.X := Normals.X + GetNormal3f(Vxl,v.Normal).x;
            Normals.Y := Normals.Y + GetNormal3f(Vxl,v.Normal).y;
            Normals.Z := Normals.Z + GetNormal3f(Vxl,v.Normal).z;
            inc(count);
         end;

      if count > 0 then
      begin
         Normalize(Normals);
         GetVoxel(x,y,z,v);
         Normals.X := Normals.X + GetNormal3f(Vxl,v.Normal).x;
         Normals.Y := Normals.Y + GetNormal3f(Vxl,v.Normal).y;
         Normals.Z := Normals.Z + GetNormal3f(Vxl,v.Normal).z;
         Normalize(Normals);
         Result := Vxl.Normals.GetIDFromNormal(Normals);
      end
      else
      begin
         GetVoxel(x,y,z,v);
         Result := v.Normal;
      end;
   end;
//
// Main Smmothing Function Starts HERE
//
begin
   maxx := vxl.Tailer.XSize - 1;
   maxy := vxl.Tailer.YSize - 1;
   maxz := vxl.Tailer.ZSize - 1;

   vxl.GetVoxel(x,y,z,v);
   if V.Used then
   begin
      T := GetAverage;
      Result := T;
   end
   else
      Result := Normal;
end;

end.

