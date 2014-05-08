unit MeshSmoothSBGAMESDraft;

// This is the first type of mesh smooth made for this program. It works with
// manifold meshes that are regular (or as regular as possible) and all its edges
// should be in the same size. In short, it is a terrible way to smooth meshes
// and it is here just for comparison purposes. It works similarly as Taubin's
// Smooth. However, it is very quick and using a good filter with an almost
// regular mesh may make the results look good with a single interaction.

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector, LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothSBGAMES2010Draft = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
      public
         DistanceFunction: TDistanceFunc;

         constructor Create(var _LOD: TLOD); override;
   end;

implementation

uses MeshPluginBase, NeighborhoodDataPlugin, GLConstants, Math, DistanceFormulas;

constructor TMeshSmoothSBGAMES2010Draft.Create(var _LOD: TLOD);
begin
   inherited Create(_LOD);
   DistanceFunction := GetLinearDistance;
end;

procedure TMeshSmoothSBGAMES2010Draft.DoMeshProcessing(var _Mesh: TMesh);
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
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   _Mesh.ForceRefresh;
end;

procedure TMeshSmoothSBGAMES2010Draft.MeshSmoothOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
var
   HitCounter: single;
   OriginalVertexes: TAVector3f;
   v,v1 : integer;
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
         _Vertices[v].X := OriginalVertexes[v].X + DistanceFunction((_Vertices[v].X) / HitCounter);
         _Vertices[v].Y := OriginalVertexes[v].Y + DistanceFunction((_Vertices[v].Y) / HitCounter);
         _Vertices[v].Z := OriginalVertexes[v].Z + DistanceFunction((_Vertices[v].Z) / HitCounter);
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

end.
