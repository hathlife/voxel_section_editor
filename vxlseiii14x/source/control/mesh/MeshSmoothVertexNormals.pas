unit MeshSmoothVertexNormals;

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector, LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothVertexNormals = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothVertexNormalsOperation(var _Normals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; const _Neighbors : TNeighborDetector; const _VertexEquivalences: auint32);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
      public
         DistanceFunction: TDistanceFunc;

         constructor Create(var _LOD: TLOD); override;
   end;

implementation

uses MeshPluginBase, GLConstants, NeighborhoodDataPlugin, MeshBRepGeometry,
   Math3d, DistanceFormulas;

constructor TMeshSmoothVertexNormals.Create(var _LOD: TLOD);
begin
   inherited Create(_LOD);
   DistanceFunction := GetLinearDistance;
end;

procedure TMeshSmoothVertexNormals.DoMeshProcessing(var _Mesh: TMesh);
var
   Neighbors : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices : integer;
   VertexEquivalences: auint32;
begin
   // Setup Neighbors.
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   _Mesh.Geometry.GoToFirstElement;
   if (High(_Mesh.Normals) > 0) then
   begin
      if NeighborhoodPlugin <> nil then
      begin
         Neighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
         NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
         if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseEquivalenceFaces then
         begin
            VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
         end
         else
         begin
            VertexEquivalences := nil;
         end;
      end
      else
      begin
         Neighbors := TNeighborDetector.Create;
         Neighbors.BuildUpData((_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces,(_Mesh.Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,High(_Mesh.Vertices)+1);
         _Mesh.Geometry.GoToFirstElement;
         NumVertices := High(_Mesh.Vertices)+1;
         VertexEquivalences := nil;
      end;
      MeshSmoothVertexNormalsOperation(_Mesh.Normals,_Mesh.Vertices,NumVertices,Neighbors,VertexEquivalences);
      // Free memory
      if NeighborhoodPlugin = nil then
      begin
         Neighbors.Free;
      end;
      _Mesh.ForceRefresh;
   end;
end;

procedure TMeshSmoothVertexNormals.MeshSmoothVertexNormalsOperation(var _Normals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; const _Neighbors : TNeighborDetector; const _VertexEquivalences: auint32);
var
   i,Value : integer;
   NormalsHandicap : TAVector3f;
   Counter : integer;
   Distance: single;
begin
   // Setup Normals Handicap.
   SetLength(NormalsHandicap,High(_Normals)+1);
   for i := Low(NormalsHandicap) to High(NormalsHandicap) do
   begin
      NormalsHandicap[i].X := 0;
      NormalsHandicap[i].Y := 0;
      NormalsHandicap[i].Z := 0;
   end;
   // Main loop goes here.
   for i := Low(_Vertices) to (_NumVertices - 1) do
   begin
      Counter := 0;
      Value := _Neighbors.GetNeighborFromID(i); // Get vertex neighbor from vertex
      while Value <> -1 do
      begin
         Distance := _Vertices[Value].X - _Vertices[i].X;
         if Distance <> 0 then
            NormalsHandicap[i].X := NormalsHandicap[i].X + (_Normals[Value].X * DistanceFunction(Distance));
         Distance := _Vertices[Value].Y - _Vertices[i].Y;
         if Distance <> 0 then
            NormalsHandicap[i].Y := NormalsHandicap[i].Y + (_Normals[Value].Y * DistanceFunction(Distance));
         Distance := _Vertices[Value].Z - _Vertices[i].Z;
         if Distance <> 0 then
            NormalsHandicap[i].Z := NormalsHandicap[i].Z + (_Normals[Value].Z * DistanceFunction(Distance));
         inc(Counter);
         Value := _Neighbors.GetNextNeighbor;
      end;
      if Counter > 0 then
      begin
         _Normals[i].X := _Normals[i].X + (NormalsHandicap[i].X / Counter);
         _Normals[i].Y := _Normals[i].Y + (NormalsHandicap[i].Y / Counter);
         _Normals[i].Z := _Normals[i].Z + (NormalsHandicap[i].Z / Counter);
         Normalize(_Normals[i]);
      end;
   end;
   i := _NumVertices;
   while i <= High(_Vertices) do
   begin
      Value := GetEquivalentVertex(i,_NumVertices,_VertexEquivalences);
      _Normals[i].X := _Normals[Value].X;
      _Normals[i].Y := _Normals[Value].Y;
      _Normals[i].Z := _Normals[Value].Z;
      inc(i);
   end;
   // Free memory
   SetLength(NormalsHandicap,0);
end;


end.
