unit ClassMeshColoursTool;

interface

uses BasicDataTypes, ClassNeighborDetector, Math, ClassMeshGeometryList;

type
   TMeshColoursTool = class
      private
         function GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
      public
         procedure ApplyFaceColourSmooth(var _Colours: TAVector4f; const _FaceColours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
         procedure ApplyVertexColourSmooth(var _Colours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _NumFaces,_VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
         procedure FilterAndFixColours(var _Colours: TAVector4f);
         procedure TransformFaceToVertexColours(var _VertColours: TAVector4f; const _FaceColours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc); overload;
         procedure TransformFaceToVertexColours(var _VertColours: TAVector4f; const _Geometry: CMeshGeometryList; const _Vertices: TAVector3f; _NumVertices: integer; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc); overload;
         procedure TransformVertexToFaceColours(const _VertColours: TAVector4f; var _FaceColours: TAVector4f; const _Faces: auint32; _VerticesPerFace: integer);
         procedure BackupColourVector(const _Source: TAVector4f; var _Destination: TAVector4f);
   end;

implementation

uses MeshGeometryBase, MeshBRepGeometry;

function TMeshColoursTool.GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
begin
   Result := _VertexID;
   while Result > _MaxVertexID do
   begin
      Result := _VertexEquivalences[Result];
   end;
end;

procedure TMeshColoursTool.ApplyFaceColourSmooth(var _Colours: TAVector4f; const _FaceColours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
var
   OriginalColours,VertColours : TAVector4f;
begin
   SetLength(OriginalColours,High(_Colours)+1);
   SetLength(VertColours,High(_Vertices)+1);
   BackupColourVector(_Colours,OriginalColours);
   TransformFaceToVertexColours(VertColours,OriginalColours,_Vertices,_NumVertices,_Faces,_VerticesPerFace,_NeighborDetector,_VertexEquivalences,_DistanceFunction);
   TransformVertexToFaceColours(VertColours,_Colours,_Faces,_VerticesPerFace);
   FilterAndFixColours(_Colours);
   // Free memory
   SetLength(VertColours,0);
   SetLength(OriginalColours,0);
end;

procedure TMeshColoursTool.ApplyVertexColourSmooth(var _Colours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _NumFaces,_VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
var
   OriginalColours,FaceColours : TAVector4f;
begin
   SetLength(OriginalColours,High(_Colours)+1);
   SetLength(FaceColours,_NumFaces);
  // Reset values.
   BackupColourVector(_Colours,OriginalColours);
   TransformVertexToFaceColours(OriginalColours,FaceColours,_Faces,_VerticesPerFace);
   TransformFaceToVertexColours(_Colours,FaceColours,_Vertices,_NumVertices,_Faces,_VerticesPerFace,_NeighborDetector,_VertexEquivalences,_DistanceFunction);
   FilterAndFixColours(_Colours);
   // Free memory
   SetLength(FaceColours,0);
   SetLength(OriginalColours,0);
end;

procedure TMeshColoursTool.TransformFaceToVertexColours(var _VertColours: TAVector4f; const _FaceColours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
var
   HitCounter: single;
   i,f,v,v1 : integer;
   MaxVerticePerFace: integer;
   MidPoint : TAVector3f;
   Distance: single;
begin
   MaxVerticePerFace := _VerticesPerFace - 1;
   // Let's check the mid point of every face.
   SetLength(MidPoint,(High(_Faces)+1) div _VerticesPerFace);
   f := 0;
   i := 0;
   while (f < High(_Faces)) do
   begin
      // find central position of the face.
      MidPoint[i].X := 0;
      MidPoint[i].Y := 0;
      MidPoint[i].Z := 0;
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := f + v;
         MidPoint[i].X := MidPoint[i].X + _Vertices[_Faces[v1]].X;
         MidPoint[i].Y := MidPoint[i].Y + _Vertices[_Faces[v1]].Y;
         MidPoint[i].Z := MidPoint[i].Z + _Vertices[_Faces[v1]].Z;
      end;
      MidPoint[i].X := MidPoint[i].X / _VerticesPerFace;
      MidPoint[i].Y := MidPoint[i].Y / _VerticesPerFace;
      MidPoint[i].Z := MidPoint[i].Z / _VerticesPerFace;
      inc(i);
      inc(f,_VerticesPerFace);
   end;
   // Now, let's check each vertex and find its colour.
   for v := Low(_VertColours) to (_NumVertices - 1) do
   begin
      HitCounter := 0;
      _VertColours[v].X := 0;
      _VertColours[v].Y := 0;
      _VertColours[v].Z := 0;
      _VertColours[v].W := 0;

      f := _NeighborDetector.GetNeighborFromID(v); // get face neighbor from vertex.
      while f <> -1 do
      begin
         Distance := sqrt(Power(MidPoint[f].X - _Vertices[v].X,2) + Power(MidPoint[f].Y - _Vertices[v].Y,2) + Power(MidPoint[f].Z - _Vertices[v].Z,2));
         Distance := _DistanceFunction(Distance);
         _VertColours[v].X := _VertColours[v].X + (_FaceColours[f].X * Distance);
         _VertColours[v].Y := _VertColours[v].Y + (_FaceColours[f].Y * Distance);
         _VertColours[v].Z := _VertColours[v].Z + (_FaceColours[f].Z * Distance);
         _VertColours[v].W := _VertColours[v].W + (_FaceColours[f].W * Distance);
         HitCounter := HitCounter + Distance;

         f := _NeighborDetector.GetNextNeighbor;
      end;
      if HitCounter > 0 then
      begin
         _VertColours[v].X := (_VertColours[v].X / HitCounter);
         _VertColours[v].Y := (_VertColours[v].Y / HitCounter);
         _VertColours[v].Z := (_VertColours[v].Z / HitCounter);
         _VertColours[v].W := (_VertColours[v].W / HitCounter);
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _VertColours[v].X := _VertColours[v1].X;
      _VertColours[v].Y := _VertColours[v1].Y;
      _VertColours[v].Z := _VertColours[v1].Z;
      _VertColours[v].W := _VertColours[v1].W;
   end;
   SetLength(MidPoint,0);
end;

procedure TMeshColoursTool.TransformFaceToVertexColours(var _VertColours: TAVector4f; const _Geometry: CMeshGeometryList; const _Vertices: TAVector3f; _NumVertices: integer; const _VertexEquivalences: auint32; _DistanceFunction : TDistanceFunc);
var
   CurrentGeometry: PMeshGeometryBase;
   HitCounter: array of single;
   i,f,v,v1 : integer;
   MaxVerticePerFace,VerticesPerFace: integer;
   MidPoint : TAVector3f;
   Distance: single;
begin
   // Initialize _VertsColours and HitCounter
   SetLength(HitCounter,_NumVertices);
   for v := Low(_VertColours) to (_NumVertices - 1) do
   begin
      HitCounter[v] := 0;
      _VertColours[v].X := 0;
      _VertColours[v].Y := 0;
      _VertColours[v].Z := 0;
      _VertColours[v].W := 0;
   end;
   // Check each geometry support.
   _Geometry.GoToFirstElement;
   CurrentGeometry := _Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      VerticesPerFace := (CurrentGeometry^ as TMeshBRepGeometry).VerticesPerFace;
      MaxVerticePerFace := VerticesPerFace - 1;
      SetLength(MidPoint,(High((CurrentGeometry^ as TMeshBRepGeometry).Faces)+1) div VerticesPerFace);
      // Let's check the mid point of every face.
      f := 0;
      i := 0;
      while (f < (CurrentGeometry^ as TMeshBRepGeometry).NumFaces) do
      begin
         // find central position of the face.
         MidPoint[i].X := 0;
         MidPoint[i].Y := 0;
         MidPoint[i].Z := 0;
         for v := 0 to MaxVerticePerFace do
         begin
            v1 := (CurrentGeometry^ as TMeshBRepGeometry).Faces[f + v];
            MidPoint[i].X := MidPoint[i].X + _Vertices[v1].X;
            MidPoint[i].Y := MidPoint[i].Y + _Vertices[v1].Y;
            MidPoint[i].Z := MidPoint[i].Z + _Vertices[v1].Z;
         end;
         MidPoint[i].X := MidPoint[i].X / VerticesPerFace;
         MidPoint[i].Y := MidPoint[i].Y / VerticesPerFace;
         MidPoint[i].Z := MidPoint[i].Z / VerticesPerFace;
         inc(i);
         inc(f,VerticesPerFace);
      end;
      // Let's add the face colours into the vertexes.
      f := 0;
      i := 0;
      while (i < (CurrentGeometry^ as TMeshBRepGeometry).NumFaces) do
      begin
         for v := 0 to MaxVerticePerFace do
         begin
            v1 := (CurrentGeometry^ as TMeshBRepGeometry).Faces[f + v];
            Distance := sqrt(Power(MidPoint[i].X - _Vertices[v1].X,2) + Power(MidPoint[i].Y - _Vertices[v1].Y,2) + Power(MidPoint[i].Z - _Vertices[v1].Z,2));
            Distance := _DistanceFunction(Distance);
            _VertColours[v1].X := _VertColours[v1].X + ((CurrentGeometry^ as TMeshBRepGeometry).Colours[i].X * Distance);
            _VertColours[v1].Y := _VertColours[v1].Y + ((CurrentGeometry^ as TMeshBRepGeometry).Colours[i].Y * Distance);
            _VertColours[v1].Z := _VertColours[v1].Z + ((CurrentGeometry^ as TMeshBRepGeometry).Colours[i].Z * Distance);
            _VertColours[v1].W := _VertColours[v1].W + ((CurrentGeometry^ as TMeshBRepGeometry).Colours[i].W * Distance);
            HitCounter[v1] := HitCounter[v1] + Distance;
         end;
         inc(i);
         inc(f,VerticesPerFace);
      end;

      // Move to next geometry
      _Geometry.GoToNextElement;
      CurrentGeometry := _Geometry.Current;
   end;

   // Now, let's find the final colour of each vertex.
   for v := Low(_VertColours) to (_NumVertices - 1) do
   begin
      if HitCounter[v] > 0 then
      begin
         _VertColours[v].X := (_VertColours[v].X / HitCounter[v]);
         _VertColours[v].Y := (_VertColours[v].Y / HitCounter[v]);
         _VertColours[v].Z := (_VertColours[v].Z / HitCounter[v]);
         _VertColours[v].W := (_VertColours[v].W / HitCounter[v]);
      end;
   end;
   // Ensure the correct colour value for _VertexEquivalences.
   if (_VertexEquivalences <> nil) then
   begin
      v := _NumVertices;
      while v <= High(_Vertices) do
      begin
         v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
         _VertColours[v].X := _VertColours[v1].X;
         _VertColours[v].Y := _VertColours[v1].Y;
         _VertColours[v].Z := _VertColours[v1].Z;
         _VertColours[v].W := _VertColours[v1].W;
      end;
   end;
   // Free memory.
   SetLength(MidPoint,0);
   SetLength(HitCounter,0);
end;

procedure TMeshColoursTool.TransformVertexToFaceColours(const _VertColours: TAVector4f; var _FaceColours: TAVector4f; const _Faces: auint32; _VerticesPerFace: integer);
var
   f,v,fpos,MaxVerticePerFace : integer;
begin
   // Define face colours.
   MaxVerticePerFace := _VerticesPerFace - 1;
   f := 0;
   fpos := 0;
   while fpos < High(_Faces) do
   begin
      // average all colours from all vertexes from the face.
      _FaceColours[f].X := 0;
      _FaceColours[f].Y := 0;
      _FaceColours[f].Z := 0;
      _FaceColours[f].W := 0;
      for v := 0 to MaxVerticePerFace do
      begin
         _FaceColours[f].X := _FaceColours[f].X + _VertColours[_Faces[fpos]].X;
         _FaceColours[f].Y := _FaceColours[f].Y + _VertColours[_Faces[fpos]].Y;
         _FaceColours[f].Z := _FaceColours[f].Z + _VertColours[_Faces[fpos]].Z;
         _FaceColours[f].W := _FaceColours[f].W + _VertColours[_Faces[fpos]].W;
         inc(fpos);
      end;
      // Get result
      _FaceColours[f].X := (_FaceColours[f].X / _VerticesPerFace);
      _FaceColours[f].Y := (_FaceColours[f].Y / _VerticesPerFace);
      _FaceColours[f].Z := (_FaceColours[f].Z / _VerticesPerFace);
      _FaceColours[f].W := (_FaceColours[f].W / _VerticesPerFace);
      inc(f);
   end;
end;


procedure TMeshColoursTool.FilterAndFixColours(var _Colours: TAVector4f);
var
   i : integer;
begin
   for i := Low(_Colours) to High(_Colours) do
   begin
      // Avoid problematic colours:
      if _Colours[i].X < 0 then
         _Colours[i].X := 0
      else if _Colours[i].X > 1 then
         _Colours[i].X := 1;
      if _Colours[i].Y < 0 then
         _Colours[i].Y := 0
      else if _Colours[i].Y > 1 then
         _Colours[i].Y := 1;
      if _Colours[i].Z < 0 then
         _Colours[i].Z := 0
      else if _Colours[i].Z > 1 then
         _Colours[i].Z := 1;
      if _Colours[i].W < 0 then
         _Colours[i].W := 0
      else if _Colours[i].W > 1 then
         _Colours[i].W := 1;
   end;
end;

procedure TMeshColoursTool.BackupColourVector(const _Source: TAVector4f; var _Destination: TAVector4f);
var
   i : integer;
begin
   for i := Low(_Source) to High(_Source) do
   begin
      _Destination[i].X := _Source[i].X;
      _Destination[i].Y := _Source[i].Y;
      _Destination[i].Z := _Source[i].Z;
      _Destination[i].W := _Source[i].W;
   end;
end;


end.
