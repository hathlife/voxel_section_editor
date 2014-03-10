unit MeshSmoothGaussian;

// This is a Taubin like mesh smooth that uses gaussian functions. It works with
// manifold meshes that are regular (or as regular as possible) and all its edges
// should be in the same size. In short, it is a terrible way to smooth meshes
// and it is here just for comparison purposes. However, it is very quick and
// using a good filter with an almost regular mesh may make the results look
// good with a single interaction.

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothGaussian = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
   end;

implementation

uses Math, GlConstants, MeshPluginBase, NeighborhoodDataPlugin;

procedure TMeshSmoothGaussian.DoMeshProcessing(var _Mesh: TMesh);
var
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
begin
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      NumVertices := High(_Mesh.Vertices)+1;
      VertexEquivalences := nil;
   end;
   MeshSmoothOperation(_Mesh.Vertices,NumVertices,NeighborDetector,VertexEquivalences);
   _Mesh.ForceRefresh;
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
end;

procedure TMeshSmoothGaussian.MeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
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

end.
