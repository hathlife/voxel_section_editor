unit ClassMeshProcessingTool;

interface

uses BasicDataTypes, ClassNeighborDetector, SysUtils, Math, GlConstants;

{$INCLUDE Global_Conditionals.inc}

type
   TMeshProcessingTool = class
      private
         function GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
      public
         procedure MeshSmooth(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure MeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
         procedure LimitedMeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
         procedure MeshGaussianSmooth(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure MeshUnsharpMasking(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure MeshDeflate(var _Vertices: TAVector3f);
         procedure MeshInflate(var _Vertices: TAVector3f);

         function FindMeshCenter(var _Vertices: TAVector3f): TVector3f;
         procedure BackupVector3f(const _Source: TAVector3f; var _Destination: TAVector3f);
   end;

implementation

uses GlobalVars;

function TMeshProcessingTool.GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
begin
   Result := _VertexID;
   while Result > _MaxVertexID do
   begin
      Result := _VertexEquivalences[Result];
   end;
end;

procedure TMeshProcessingTool.MeshSmooth(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
var
   OriginalVertexes : TAVector3f;
   v,v1,HitCounter : integer;
begin
   SetLength(OriginalVertexes,High(_Vertices)+1);
   BackupVector3f(_Vertices,OriginalVertexes);
   // Now, let's check each vertex.
   for v := Low(_Vertices) to (_NumVertices-1) do
   begin
      _Vertices[v].X := 0;
      _Vertices[v].Y := 0;
      _Vertices[v].Z := 0;
      HitCounter := 0;
      v1 := _NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         // add it to the sum.
         _Vertices[v].X := _Vertices[v].X + OriginalVertexes[v1].X;
         _Vertices[v].Y := _Vertices[v].Y + OriginalVertexes[v1].Y;
         _Vertices[v].Z := _Vertices[v].Z + OriginalVertexes[v1].Z;
         inc(HitCounter);

         v1 := _NeighborDetector.GetNextNeighbor;
      end;
      // Finally, we do an average for all vertices.
      if HitCounter > 0 then
      begin
         _Vertices[v].X := _Vertices[v].X / HitCounter;
         _Vertices[v].Y := _Vertices[v].Y / HitCounter;
         _Vertices[v].Z := _Vertices[v].Z / HitCounter;
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _Vertices[v].X := _Vertices[v1].X;
      _Vertices[v].Y := _Vertices[v1].Y;
      _Vertices[v].Z := _Vertices[v1].Z;
      inc(v);
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
end;

procedure TMeshProcessingTool.MeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
var
   HitCounter: single;
   OriginalVertexes: TAVector3f;
   v,v1 : integer;
   Distance: single;
begin
   SetLength(OriginalVertexes,High(_Vertices)+1);
   BackupVector3f(_Vertices,OriginalVertexes);
   // Sum up vertices with its neighbours, using the desired distance formula.
   for v := Low(_Vertices) to (_NumVertices-1) do
   begin
      _Vertices[v].X := 0;
      _Vertices[v].Y := 0;
      _Vertices[v].Z := 0;
      HitCounter := 0;
      v1 := _NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         _Vertices[v].X := _Vertices[v].X + (OriginalVertexes[v1].X - OriginalVertexes[v].X);
         _Vertices[v].Y := _Vertices[v].Y + (OriginalVertexes[v1].Y - OriginalVertexes[v].Y);
         _Vertices[v].Z := _Vertices[v].Z + (OriginalVertexes[v1].Z - OriginalVertexes[v].Z);
         HitCounter := HitCounter + 1;

         v1 := _NeighborDetector.GetNextNeighbor;
      end;
      // Finally, we do an average for all vertices.
      {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Mesh Value (' + FloatToStr(_Vertices[v].X) + ', ' + FloatToStr(_Vertices[v].Y) + ', ' +FloatToStr(_Vertices[v].Z) + ') with ' + FloatToStr(HitCounter) + ' neighbours. Expected frequencies: (' + FloatToStr(_Vertices[v].X / HitCounter) + ', ' + FloatToStr(_Vertices[v].Y / HitCounter) + ', ' + FloatToStr(_Vertices[v].Z / HitCounter) + ')');
      {$endif}
      if HitCounter > 0 then
      begin
         _Vertices[v].X := OriginalVertexes[v].X + _DistanceFunction((_Vertices[v].X) / HitCounter);
         _Vertices[v].Y := OriginalVertexes[v].Y + _DistanceFunction((_Vertices[v].Y) / HitCounter);
         _Vertices[v].Z := OriginalVertexes[v].Z + _DistanceFunction((_Vertices[v].Z) / HitCounter);
      end
      else
      begin
         _Vertices[v].X := OriginalVertexes[v].X;
         _Vertices[v].Y := OriginalVertexes[v].Y;
         _Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _Vertices[v].X := _Vertices[v1].X;
      _Vertices[v].Y := _Vertices[v1].Y;
      _Vertices[v].Z := _Vertices[v1].Z;
      inc(v);
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
end;

procedure TMeshProcessingTool.LimitedMeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
var
   HitCounter: single;
   OriginalVertexes : TAVector3f;
   v,v1 : integer;
   x,y,z : single;
   Distance: single;
begin
   SetLength(OriginalVertexes,High(_Vertices)+1);
   BackupVector3f(_Vertices,OriginalVertexes);
   // Sum up vertices with its neighbours, using the desired distance formula.
   for v := Low(_Vertices) to (_NumVertices-1) do
   begin
      _Vertices[v].X := 0;
      _Vertices[v].Y := 0;
      _Vertices[v].Z := 0;
      HitCounter := 0;
      v1 := _NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         x := (OriginalVertexes[v1].X - OriginalVertexes[v].X);
         y := (OriginalVertexes[v1].Y - OriginalVertexes[v].Y);
         z := (OriginalVertexes[v1].Z - OriginalVertexes[v].Z);
         Distance := Sqrt((x * x) + (y * y) + (z * z));
         if Distance > 0 then
         begin
            _Vertices[v].X := _Vertices[v].X + (x/distance);
            _Vertices[v].Y := _Vertices[v].Y + (y/distance);
            _Vertices[v].Z := _Vertices[v].Z + (z/distance);

            HitCounter := HitCounter + 1;
         end;
         v1 := _NeighborDetector.GetNextNeighbor;
      end;
      // Finally, we do an average for all vertices.
      {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Mesh Value (' + FloatToStr(_Vertices[v].X) + ', ' + FloatToStr(_Vertices[v].Y) + ', ' +FloatToStr(_Vertices[v].Z) + ') with ' + FloatToStr(HitCounter) + ' neighbours. Expected frequencies: (' + FloatToStr(_Vertices[v].X / HitCounter) + ', ' + FloatToStr(_Vertices[v].Y / HitCounter) + ', ' + FloatToStr(_Vertices[v].Z / HitCounter) + ')');
      {$endif}
      if HitCounter > 0 then
      begin
         _Vertices[v].X := OriginalVertexes[v].X + _DistanceFunction((_Vertices[v].X / HitCounter));
         _Vertices[v].Y := OriginalVertexes[v].Y + _DistanceFunction((_Vertices[v].Y / HitCounter));
         _Vertices[v].Z := OriginalVertexes[v].Z + _DistanceFunction((_Vertices[v].Z / HitCounter));
      end
      else
      begin
         _Vertices[v].X := OriginalVertexes[v].X;
         _Vertices[v].Y := OriginalVertexes[v].Y;
         _Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _Vertices[v].X := _Vertices[v1].X;
      _Vertices[v].Y := _Vertices[v1].Y;
      _Vertices[v].Z := _Vertices[v1].Z;
      inc(v);
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
end;

procedure TMeshProcessingTool.MeshGaussianSmooth(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
const
   C_2PI = 2 * Pi;
   C_E = 2.718281828;
var
   HitCounter: single;
   OriginalVertexes : TAVector3f;
   VertexWeight : TVector3f;
   v,v1 : integer;
   Distance: single;
   Deviation: single;
begin
   SetLength(OriginalVertexes,High(_Vertices)+1);
   BackupVector3f(_Vertices,OriginalVertexes);
   // Sum up vertices with its neighbours, using the desired distance formula.
   // Do an average for all vertices.
   for v := Low(_Vertices) to (_NumVertices-1) do
   begin
      // get the standard deviation.
      Deviation := 0;
      v1 := _NeighborDetector.GetNeighborFromID(v); // get vertex neighbor from vertex
      HitCounter := 0;
      VertexWeight.X := 0;
      VertexWeight.Y := 0;
      VertexWeight.Z := 0;
      while v1 <> -1 do
      begin
         Deviation := Deviation + Power(OriginalVertexes[v1].X - OriginalVertexes[v].X,2) + Power(OriginalVertexes[v1].Y - OriginalVertexes[v].Y,2) + Power(OriginalVertexes[v1].Z - OriginalVertexes[v].Z,2);
         HitCounter := HitCounter + 1;

         VertexWeight.X := VertexWeight.X + (OriginalVertexes[v1].X - OriginalVertexes[v].X);
         VertexWeight.Y := VertexWeight.Y + (OriginalVertexes[v1].Y - OriginalVertexes[v].Y);
         VertexWeight.Z := VertexWeight.Z + (OriginalVertexes[v1].Z - OriginalVertexes[v].Z);

         v1 := _NeighborDetector.GetNextNeighbor;
      end;
      if HitCounter > 0 then
         Deviation := Sqrt(Deviation / HitCounter);
      // calculate the vertex position.
      if (HitCounter > 0) and (Deviation <> 0) then
      begin
         Distance := ((C_FREQ_NORMALIZER * VertexWeight.X) / HitCounter);
         if Distance > 0 then
            _Vertices[v].X := OriginalVertexes[v].X + (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation))
         else if Distance < 0 then
            _Vertices[v].X := OriginalVertexes[v].X - (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation));
         Distance := ((C_FREQ_NORMALIZER * VertexWeight.Y) / HitCounter);
         if Distance > 0 then
            _Vertices[v].Y := OriginalVertexes[v].Y + (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation))
         else if Distance < 0 then
            _Vertices[v].Y := OriginalVertexes[v].Y - (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation));
         Distance := ((C_FREQ_NORMALIZER * VertexWeight.Z) / HitCounter);
         if Distance > 0 then
            _Vertices[v].Z := OriginalVertexes[v].Z + (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation))
         else if Distance < 0 then
            _Vertices[v].Z := OriginalVertexes[v].Z - (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation));
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _Vertices[v].X := _Vertices[v1].X;
      _Vertices[v].Y := _Vertices[v1].Y;
      _Vertices[v].Z := _Vertices[v1].Z;
      inc(v);
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
end;

procedure TMeshProcessingTool.MeshUnsharpMasking(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
var
   OriginalVertexes : TAVector3f;
   v,v1,HitCounter : integer;
begin
   SetLength(OriginalVertexes,High(_Vertices)+1);
   BackupVector3f(_Vertices,OriginalVertexes);
   // sum all values from neighbors
   for v := Low(_Vertices) to (_NumVertices-1) do
   begin
      _Vertices[v].X := 0;
      _Vertices[v].Y := 0;
      _Vertices[v].Z := 0;
      HitCounter := 0;
      v1 := _NeighborDetector.GetNeighborFromID(v); // vertex neighbor from vertex
      while v1 <> -1 do
      begin
         _Vertices[v].X := _Vertices[v].X + OriginalVertexes[v1].X;
         _Vertices[v].Y := _Vertices[v].Y + OriginalVertexes[v1].Y;
         _Vertices[v].Z := _Vertices[v].Z + OriginalVertexes[v1].Z;
         inc(HitCounter);
         v1 := _NeighborDetector.GetNextNeighbor;
      end;
      // Finally, we do the unsharp masking effect here.
      if HitCounter > 0 then
      begin
         _Vertices[v].X := ((HitCounter + 1) * OriginalVertexes[v].X) - _Vertices[v].X;
         _Vertices[v].Y := ((HitCounter + 1) * OriginalVertexes[v].Y) - _Vertices[v].Y;
         _Vertices[v].Z := ((HitCounter + 1) * OriginalVertexes[v].Z) - _Vertices[v].Z;
      end
      else
      begin
         _Vertices[v].X := OriginalVertexes[v].X;
         _Vertices[v].Y := OriginalVertexes[v].Y;
         _Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _Vertices[v].X := _Vertices[v1].X;
      _Vertices[v].Y := _Vertices[v1].Y;
      _Vertices[v].Z := _Vertices[v1].Z;
      inc(v);
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
end;

procedure TMeshProcessingTool.MeshDeflate(var _Vertices: TAVector3f);
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter(_Vertices);

    // Finally, we do an average for all vertices.
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      Temp := (CenterPoint.X - _Vertices[v].X) * 0.1;
      if Temp > 0 then
         _Vertices[v].X := _Vertices[v].X  + Power(Temp,2)
      else
         _Vertices[v].X := _Vertices[v].X - Power(Temp,2);
      Temp := (CenterPoint.Y - _Vertices[v].Y) * 0.1;
      if Temp > 0 then
         _Vertices[v].Y := _Vertices[v].Y + Power(Temp,2)
      else
         _Vertices[v].Y := _Vertices[v].Y - Power(Temp,2);
      Temp := (CenterPoint.Z - _Vertices[v].Z) * 0.1;
      if Temp > 0 then
         _Vertices[v].Z := _Vertices[v].Z + Power(Temp,2)
      else
         _Vertices[v].Z := _Vertices[v].Z - Power(Temp,2);
   end;
end;

procedure TMeshProcessingTool.MeshInflate(var _Vertices: TAVector3f);
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter(_Vertices);

    // Finally, we do an average for all vertices.
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      Temp := (CenterPoint.X - _Vertices[v].X) * 0.1;
      if Temp > 0 then
         _Vertices[v].X := _Vertices[v].X - Power(Temp,2)
      else
         _Vertices[v].X := _Vertices[v].X + Power(Temp,2);
      Temp := (CenterPoint.Y - _Vertices[v].Y) * 0.1;
      if Temp > 0 then
         _Vertices[v].Y := _Vertices[v].Y - Power(Temp,2)
      else
         _Vertices[v].Y := _Vertices[v].Y + Power(Temp,2);
      Temp := (CenterPoint.Z - _Vertices[v].Z) * 0.1;
      if Temp > 0 then
         _Vertices[v].Z := _Vertices[v].Z - Power(Temp,2)
      else
         _Vertices[v].Z := _Vertices[v].Z + Power(Temp,2);
   end;
end;

function TMeshProcessingTool.FindMeshCenter(var _Vertices: TAVector3f): TVector3f;
var
   v : integer;
   MaxPoint,MinPoint: TVector3f;
begin
   if High(_Vertices) >= 0 then
   begin
      MinPoint.X := _Vertices[0].X;
      MinPoint.Y := _Vertices[0].Y;
      MinPoint.Z := _Vertices[0].Z;
      MaxPoint.X := _Vertices[0].X;
      MaxPoint.Y := _Vertices[0].Y;
      MaxPoint.Z := _Vertices[0].Z;
      // Find mesh scope.
      for v := 1 to High(_Vertices) do
      begin
         if (_Vertices[v].X < MinPoint.X) and (_Vertices[v].X <> -NAN) then
         begin
            MinPoint.X := _Vertices[v].X;
         end;
         if _Vertices[v].X > MaxPoint.X then
         begin
            MaxPoint.X := _Vertices[v].X;
         end;
         if (_Vertices[v].Y < MinPoint.Y) and (_Vertices[v].Y <> -NAN) then
         begin
            MinPoint.Y := _Vertices[v].Y;
         end;
         if _Vertices[v].Y > MaxPoint.Y then
         begin
            MaxPoint.Y := _Vertices[v].Y;
         end;
         if (_Vertices[v].Z < MinPoint.Z) and (_Vertices[v].Z <> -NAN) then
         begin
            MinPoint.Z := _Vertices[v].Z;
         end;
         if _Vertices[v].Z > MaxPoint.Z then
         begin
            MaxPoint.Z := _Vertices[v].Z;
         end;
      end;
      Result.X := (MinPoint.X + MaxPoint.X) / 2;
      Result.Y := (MinPoint.Y + MaxPoint.Y) / 2;
      Result.Z := (MinPoint.Z + MaxPoint.Z) / 2;
   end
   else
   begin
      Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
   end;
end;


procedure TMeshProcessingTool.BackupVector3f(const _Source: TAVector3f; var _Destination: TAVector3f);
var
   i : integer;
begin
   for i := Low(_Source) to High(_Source) do
   begin
      _Destination[i].X := _Source[i].X;
      _Destination[i].Y := _Source[i].Y;
      _Destination[i].Z := _Source[i].Z;
   end;
end;

end.
