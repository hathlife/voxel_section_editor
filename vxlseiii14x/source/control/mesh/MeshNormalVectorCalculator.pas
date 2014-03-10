unit MeshNormalVectorCalculator;

interface

uses Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector;

type
   TMeshNormalVectorCalculator = class
      private
         function GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
      public
         function GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
         function GetQuadNormalValue(const _V1,_V2,_V3,_V4: TVector3f): TVector3f;
         procedure FindMeshVertexNormals(var _Mesh: TMesh);
         procedure FindMeshFaceNormals(var _Mesh: TMesh);
         procedure GetVertexNormalsFromFaces(var _VertexNormals: TAVector3f; const _FaceNormals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; _NeighborDetector : TNeighborDetector;  const _VertexEquivalences: auint32);
         procedure GetFaceNormals(var _FaceNormals: TAVector3f; _VerticesPerFace : integer; const _Vertices: TAVector3f; const _Faces: auint32);
   end;

implementation

uses MeshPluginBase, NeighborhoodDataPlugin, GLConstants, MeshBRepGeometry,
   MeshGeometryBase, Vector3fSet, Math3D;

procedure TMeshNormalVectorCalculator.FindMeshVertexNormals(var _Mesh: TMesh);
var
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin: PMeshPluginBase;
   VertexEquivalences: auint32;
   MyNormals: TAVector3f;
   NumVertices: integer;
begin
   if High(_Mesh.Normals) <= 0 then
   begin
      SetLength(_Mesh.Normals,High(_Mesh.Vertices)+1);
   end;
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   _Mesh.Geometry.GoToFirstElement;
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
         MyNormals := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNormals;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
         MyNormals := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Normals;
      end;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      MyNormals := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Normals;
      VertexEquivalences := nil;
      NumVertices := High(_Mesh.Vertices)+1;
   end;
   GetVertexNormalsFromFaces(_Mesh.Normals,MyNormals,_Mesh.Vertices,NumVertices,NeighborDetector,VertexEquivalences);
//   _Mesh.SetVertexNormals;
end;

procedure TMeshNormalVectorCalculator.FindMeshFaceNormals(var _Mesh: TMesh);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   // Recalculate Face Normals
   _Mesh.Geometry.GoToFirstElement;
   CurrentGeometry := _Mesh.Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      if High((CurrentGeometry^ as TMeshBRepGeometry).Normals) > 0 then
      begin
         GetFaceNormals((_Mesh.Geometry.Current^ as TMeshBRepGeometry).Normals,(_Mesh.Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_Mesh.Vertices,(_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces);
      end;
      _Mesh.Geometry.GoToNextElement;
      CurrentGeometry := _Mesh.Geometry.Current;
   end;
end;

procedure TMeshNormalVectorCalculator.GetVertexNormalsFromFaces(var _VertexNormals: TAVector3f; const _FaceNormals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; _NeighborDetector : TNeighborDetector;  const _VertexEquivalences: auint32);
var
   DifferentNormalsList: CVector3fSet;
   v,Value : integer;
   Normal : PVector3f;
begin
   DifferentNormalsList := CVector3fSet.Create;
   // Now, let's check each vertex.
   for v := Low(_Vertices) to (_NumVertices - 1) do
   begin
      DifferentNormalsList.Reset;
      _VertexNormals[v].X := 0;
      _VertexNormals[v].Y := 0;
      _VertexNormals[v].Z := 0;
      Value := _NeighborDetector.GetNeighborFromID(v); // face neighbors from vertex
      while Value <> -1 do
      begin
         Normal := new(PVector3f);
         Normal^.X := _FaceNormals[Value].X;
         Normal^.Y := _FaceNormals[Value].Y;
         Normal^.Z := _FaceNormals[Value].Z;
         if DifferentNormalsList.Add(Normal) then
         begin
            _VertexNormals[v].X := _VertexNormals[v].X + Normal^.X;
            _VertexNormals[v].Y := _VertexNormals[v].Y + Normal^.Y;
            _VertexNormals[v].Z := _VertexNormals[v].Z + Normal^.Z;
         end;
         Value := _NeighborDetector.GetNextNeighbor;
      end;
      if not DifferentNormalsList.isEmpty then
      begin
         Normalize(_VertexNormals[v]);
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      Value := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _VertexNormals[v].X := _VertexNormals[Value].X;
      _VertexNormals[v].Y := _VertexNormals[Value].Y;
      _VertexNormals[v].Z := _VertexNormals[Value].Z;
      inc(v);
   end;

   // Free memory
   DifferentNormalsList.Free;
end;

procedure TMeshNormalVectorCalculator.GetFaceNormals(var _FaceNormals: TAVector3f; _VerticesPerFace : integer; const _Vertices: TAVector3f; const _Faces: auint32);
var
   f,face : integer;
   temp : TVector3f;
begin
   if High(_FaceNormals) >= 0 then
   begin
      if _VerticesPerFace = 3 then
      begin
         face := 0;
         for f := Low(_FaceNormals) to High(_FaceNormals) do
         begin
            _FaceNormals[f] := GetNormalsValue(_Vertices[_Faces[face]],_Vertices[_Faces[face+1]],_Vertices[_Faces[face+2]]);
            inc(face,3);
         end;
      end
      else if _VerticesPerFace = 4 then
      begin
         face := 0;
         for f := Low(_FaceNormals) to High(_FaceNormals) do
         begin
            _FaceNormals[f] := GetQuadNormalValue(_Vertices[_Faces[face]],_Vertices[_Faces[face+1]],_Vertices[_Faces[face+2]],_Vertices[_Faces[face+3]]);
            inc(face,4);
         end;
      end;
   end;
end;

function TMeshNormalVectorCalculator.GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
begin
   Result := _VertexID;
   while Result > _MaxVertexID do
   begin
      Result := _VertexEquivalences[Result];
   end;
end;

function TMeshNormalVectorCalculator.GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
begin
   Result.X := (((_V3.Y - _V2.Y) * (_V1.Z - _V2.Z)) - ((_V1.Y - _V2.Y) * (_V3.Z - _V2.Z)));
   Result.Y := (((_V3.Z - _V2.Z) * (_V1.X - _V2.X)) - ((_V1.Z - _V2.Z) * (_V3.X - _V2.X)));
   Result.Z := (((_V3.X - _V2.X) * (_V1.Y - _V2.Y)) - ((_V1.X - _V2.X) * (_V3.Y - _V2.Y)));
   Normalize(Result);
end;

function TMeshNormalVectorCalculator.GetQuadNormalValue(const _V1,_V2,_V3,_V4: TVector3f): TVector3f;
var
   Temp : TVector3f;
begin
   Result := GetNormalsValue(_V1,_V2,_V3);
   Temp := GetNormalsValue(_V3,_V4,_V1);
   Result.X := Result.X + Temp.X;
   Result.Y := Result.Y + Temp.Y;
   Result.Z := Result.Z + Temp.Z;
   Normalize(Result);
end;

end.
