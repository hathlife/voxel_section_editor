unit MeshNormalsTool;

interface

uses BasicMathsTypes, BasicDataTypes, Math3d, NeighborDetector, Math, Vector3fSet;

type
   TMeshNormalsTool = class
      private
         function GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
      public
         function GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
         function GetQuadNormalValue(const _V1,_V2,_V3,_V4: TVector3f): TVector3f;
         procedure GetVertexNormalsFromFaces(var _VertexNormals: TAVector3f; const _FaceNormals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; _NeighborDetector : TNeighborDetector;  const _VertexEquivalences: auint32);
         procedure GetFaceNormals(var _FaceNormals: TAVector3f; _VerticesPerFace : integer; const _Vertices: TAVector3f; const _Faces: auint32);

         // Deprecated.
         procedure SmoothVertexNormalsOperation(var _Normals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; const _Neighbors : TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction: TDistanceFunc);
         procedure SmoothFaceNormalsOperation(var _FaceNormals: TAVector3f; const _Vertices: TAVector3f; const _Neighbors : TNeighborDetector; _DistanceFunction: TDistanceFunc);
   end;

implementation

function TMeshNormalsTool.GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
begin
   Result := _VertexID;
   while Result > _MaxVertexID do
   begin
      Result := _VertexEquivalences[Result];
   end;
end;


function TMeshNormalsTool.GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
begin
   Result.X := (((_V3.Y - _V2.Y) * (_V1.Z - _V2.Z)) - ((_V1.Y - _V2.Y) * (_V3.Z - _V2.Z)));
   Result.Y := (((_V3.Z - _V2.Z) * (_V1.X - _V2.X)) - ((_V1.Z - _V2.Z) * (_V3.X - _V2.X)));
   Result.Z := (((_V3.X - _V2.X) * (_V1.Y - _V2.Y)) - ((_V1.X - _V2.X) * (_V3.Y - _V2.Y)));
   Normalize(Result);
end;

function TMeshNormalsTool.GetQuadNormalValue(const _V1,_V2,_V3,_V4: TVector3f): TVector3f;
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

procedure TMeshNormalsTool.SmoothVertexNormalsOperation(var _Normals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; const _Neighbors : TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction: TDistanceFunc);
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
            NormalsHandicap[i].X := NormalsHandicap[i].X + (_Normals[Value].X * _DistanceFunction(Distance));
         Distance := _Vertices[Value].Y - _Vertices[i].Y;
         if Distance <> 0 then
            NormalsHandicap[i].Y := NormalsHandicap[i].Y + (_Normals[Value].Y * _DistanceFunction(Distance));
         Distance := _Vertices[Value].Z - _Vertices[i].Z;
         if Distance <> 0 then
            NormalsHandicap[i].Z := NormalsHandicap[i].Z + (_Normals[Value].Z * _DistanceFunction(Distance));
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

procedure TMeshNormalsTool.SmoothFaceNormalsOperation(var _FaceNormals: TAVector3f; const _Vertices: TAVector3f; const _Neighbors : TNeighborDetector; _DistanceFunction: TDistanceFunc);
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
            NormalsHandicap[i].X := NormalsHandicap[i].X + (_FaceNormals[Value].X * _DistanceFunction(Distance));
         Distance := _Vertices[Value].Y - _Vertices[i].Y;
         if Distance <> 0 then
            NormalsHandicap[i].Y := NormalsHandicap[i].Y + (_FaceNormals[Value].Y * _DistanceFunction(Distance));
         Distance := _Vertices[Value].Z - _Vertices[i].Z;
         if Distance <> 0 then
            NormalsHandicap[i].Z := NormalsHandicap[i].Z + (_FaceNormals[Value].Z * _DistanceFunction(Distance));
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

procedure TMeshNormalsTool.GetVertexNormalsFromFaces(var _VertexNormals: TAVector3f; const _FaceNormals: TAVector3f; const _Vertices: TAVector3f; _NumVertices: integer; _NeighborDetector : TNeighborDetector;  const _VertexEquivalences: auint32);
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

procedure TMeshNormalsTool.GetFaceNormals(var _FaceNormals: TAVector3f; _VerticesPerFace : integer; const _Vertices: TAVector3f; const _Faces: auint32);
var
   f,face : integer;
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


end.
