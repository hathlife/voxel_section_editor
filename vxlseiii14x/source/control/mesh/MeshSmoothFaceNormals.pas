unit MeshSmoothFaceNormals;

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector, LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothFaceNormals = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothFaceNormalsOperation(var _FaceNormals: TAVector3f; const _Vertices: TAVector3f; const _Neighbors : TNeighborDetector);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
      public
         DistanceFunction: TDistanceFunc;

         constructor Create(var _LOD: TLOD);
   end;

implementation

uses MeshPluginBase, GLConstants, NeighborhoodDataPlugin, MeshBRepGeometry,
   Math3d, Math, DistanceFormulas;

constructor TMeshSmoothFaceNormals.Create(var _LOD:TLOD);
begin
   inherited Create(_LOD);
   DistanceFunction := GetLinearDistance;
end;


procedure TMeshSmoothFaceNormals.DoMeshProcessing(var _Mesh: TMesh);
var
   Neighbors : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices : integer;
   VertexEquivalences: auint32;
begin
   // Setup Neighbors.
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   _Mesh.Geometry.GoToFirstElement;
   if (High((_Mesh.Geometry.Current^ as TMeshBRepGeometry).Normals) > 0) then
   begin
      if NeighborhoodPlugin <> nil then
      begin
         Neighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
      end
      else
      begin
         Neighbors := TNeighborDetector.Create;
         Neighbors.NeighborType := C_NEIGHBTYPE_FACE_FACE_FROM_EDGE;
         Neighbors.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      end;
      MeshSmoothFaceNormalsOperation((_Mesh.Geometry.Current^ as TMeshBRepGeometry).Normals,_Mesh.Vertices,Neighbors);
   end;

   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      Neighbors.Free;
   end;
   _Mesh.ForceRefresh;
end;

procedure TMeshSmoothFaceNormals.MeshSmoothFaceNormalsOperation(var _FaceNormals: TAVector3f; const _Vertices: TAVector3f; const _Neighbors : TNeighborDetector);
var
   i,Value : integer;
   NormalsHandicap : TAVector3f;
   Counter : single;
   Distance: single;
begin
   // Setup Normals Handicap.
   SetLength(NormalsHandicap,High(_FaceNormals)+1);
   for i := Low(NormalsHandicap) to High(NormalsHandicap) do
   begin
      NormalsHandicap[i].X := 0;
      NormalsHandicap[i].Y := 0;
      NormalsHandicap[i].Z := 0;
   end;
   // Main loop goes here.
   for i := Low(NormalsHandicap) to High(NormalsHandicap) do
   begin
      Counter := 0;
      Value := _Neighbors.GetNeighborFromID(i); // Get face neighbor from face (common edge)
      while Value <> -1 do
      begin
         Distance := _Vertices[Value].X - _Vertices[i].X;
         if Distance <> 0 then
            NormalsHandicap[i].X := NormalsHandicap[i].X + (_FaceNormals[Value].X * DistanceFunction(Distance));
         Distance := _Vertices[Value].Y - _Vertices[i].Y;
         if Distance <> 0 then
            NormalsHandicap[i].Y := NormalsHandicap[i].Y + (_FaceNormals[Value].Y * DistanceFunction(Distance));
         Distance := _Vertices[Value].Z - _Vertices[i].Z;
         if Distance <> 0 then
            NormalsHandicap[i].Z := NormalsHandicap[i].Z + (_FaceNormals[Value].Z * DistanceFunction(Distance));
         Distance := sqrt(Power(_Vertices[Value].X - _Vertices[i].X,2) + Power(_Vertices[Value].Y - _Vertices[i].Y,2) + Power(_Vertices[Value].Z - _Vertices[i].Z,2));
         Counter := Counter + Distance;
         Value := _Neighbors.GetNextNeighbor;
      end;
      if Counter > 0 then
      begin
         _FaceNormals[i].X := _FaceNormals[i].X + (NormalsHandicap[i].X / Counter);
         _FaceNormals[i].Y := _FaceNormals[i].Y + (NormalsHandicap[i].Y / Counter);
         _FaceNormals[i].Z := _FaceNormals[i].Z + (NormalsHandicap[i].Z / Counter);
         Normalize(_FaceNormals[i]);
      end;
   end;

   // Free memory
   SetLength(NormalsHandicap,0);
end;


end.
