unit MeshUnsharpMasking;

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshUnsharpMasking = class (TMeshProcessingBase)
      protected
         procedure MeshUnsharpMaskingOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
   end;

implementation

uses MeshPluginBase, GlConstants, NeighborhoodDataPlugin;

procedure TMeshUnsharpMasking.DoMeshProcessing(var _Mesh: TMesh);
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
   MeshUnsharpMaskingOperation(_Mesh.Vertices,NumVertices,NeighborDetector,VertexEquivalences);
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   _Mesh.ForceRefresh;
end;

procedure TMeshUnsharpMasking.MeshUnsharpMaskingOperation(var _Vertices: TAVector3f; _NumVertices: integer; const _NeighborDetector : TNeighborDetector; const _VertexEquivalences: auint32);
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

end.
