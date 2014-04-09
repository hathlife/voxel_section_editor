unit NeighborDetector;

interface

uses BasicMathsTypes, BasicDataTypes, BasicRenderingTypes, SysUtils, Windows, MeshGeometryList;

const
   C_NEIGHBTYPE_VERTEX_VERTEX = 0;     // vertex neighbors of vertexes.
   C_NEIGHBTYPE_VERTEX_FACE = 1;       // face neighbors of vertexes.
   C_NEIGHBTYPE_FACE_VERTEX = 2;       // vertex neighbors of faces.
   C_NEIGHBTYPE_FACE_FACE_FROM_EDGE = 3;         // face neighbors of faces, with common edges.
   C_NEIGHBTYPE_FACE_FACE_FROM_VERTEX = 4;         // face neighbors of faces, with common vertexes.
   C_NEIGHBTYPE_MAX = C_NEIGHBTYPE_FACE_FACE_FROM_VERTEX;

type
   PNeighborDetector = ^TNeighborDetector;
   TNeighborDetector = class
      private
         FNeighbors: array of PIntegerItem;
         FRequest : integer;
         FNeighborID: integer;
         FCurrentID: integer;
         FNeighborhoodData: array of integer;
         FDescriptorData: TADescriptor;
         // Constructors and Destructors
         procedure Initialize;
         procedure InitializeNeighbors(_NumElements: integer);
         procedure ClearFNeighbors;
         // Executes
         procedure OrganizeVertexVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer); overload;
         procedure OrganizeVertexVertex(const _Geometry: CMeshGeometryList; _NumVertexes: integer); overload;
         procedure OrganizeVertexFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure OrganizeFaceVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure OrganizeFaceFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure OrganizeFaceFaceFromVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure DefragmentData;
         // ReOrder
         procedure ReOrderVertexVertex(const _Vertexes,_VertexNormals: TAVector3f);
         procedure ReOrderVertexFace(const _Vertexes,_VertexNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
         procedure ReOrderFaceVertex(const _Vertexes,_FaceNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
         procedure ReOrderFaceFace(const _Vertexes,_FaceNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
         procedure QuickSortAngles(_min, _max : integer; var _Order: auint32; const _Angles : afloat);
         function GetTheVertexAfterMe(_VertexID,_VertexesPerFace: integer; const _Faces: auint32): integer;
         function GetFaceCenterPosition(_Face: integer; const _Faces:auint32; const _Vertexes: TAVector3f; _VertexesPerFace: integer): TVector3f;
         // Adds
         procedure AddElementAtTarget(_Value: integer; _Target: integer);
         procedure AddElementAtTargetWithoutRepetition(_Value: integer; _Target: integer);
      public
         VertexVertexNeighbors: TNeighborDetector;
         VertexFaceNeighbors: TNeighborDetector;
         NeighborType : byte;
         IsValid: boolean;
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(_Type : byte); overload;
         constructor Create(const _Source: TNeighborDetector); overload;
         destructor Destroy; override;
         procedure Clear;
         // I/O
         procedure LoadState(_State: TNeighborDetectorSaveData);
         function SaveState:TNeighborDetectorSaveData;
         // Sets
         procedure SetType(_Type: byte);
         // Executes
         procedure BuildUpData(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer); overload;
         procedure BuildUpData(var _Geometry: CMeshGeometryList; _NumVertexes: integer); overload;
         // ReOrder
         procedure GetStarOrder(const _Vertexes,_FaceNormals,_VertexNormals: TAVector3f;  const _Faces: auint32; _VertexesPerFace: integer);
         // Requests
         function GetNeighborFromID(_ID: integer): integer;
         function GetNextNeighbor: integer;
         // Copy
         procedure Assign(const _Source: TNeighborDetector);
   end;

implementation

uses MeshBRepGeometry, VertexTransformationUtils, math3d;

// Constructors and Destructors
constructor TNeighborDetector.Create;
begin
   NeighborType := C_NEIGHBTYPE_VERTEX_VERTEX;
   Initialize;
end;

constructor TNeighborDetector.Create(_Type : byte);
begin
   NeighborType := _Type;
   Initialize;
end;

constructor TNeighborDetector.Create(const _Source: TNeighborDetector);
begin
   Assign(_Source);
end;

destructor TNeighborDetector.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TNeighborDetector.Initialize;
begin
   FRequest := -1;
   VertexVertexNeighbors := nil;
   VertexFaceNeighbors := nil;
   IsValid := false;
   SetLength(FNeighbors,0);
   SetLength(FNeighborhoodData,0);
   SetLength(FDescriptorData,0);
end;

procedure TNeighborDetector.ClearFNeighbors;
var
   i : integer;
   Element, DisposedElement: PIntegerItem;
begin
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      // clear each element.
      Element := FNeighbors[i];
      while Element <> nil do
      begin
         DisposedElement := Element;
         Element := Element^.Next;
         Dispose(DisposedElement);
      end;
      FNeighbors[i] := nil;
   end;
   SetLength(FNeighbors,0);
end;

procedure TNeighborDetector.Clear;
begin
   ClearFNeighbors;
   Initialize;
end;

procedure TNeighborDetector.InitializeNeighbors(_NumElements: integer);
var
   i : integer;
begin
   SetLength(FNeighbors,_NumElements);
   SetLength(FDescriptorData,_NumElements);
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      FNeighbors[i] := nil;
   end;
end;

// I/O
procedure TNeighborDetector.LoadState(_State: TNeighborDetectorSaveData);
begin
   FCurrentID := _State.cID;
   FNeighborID := _State.nID;
   FRequest := FNeighborhoodData[FDescriptorData[FCurrentID].Start + FNeighborID];
end;

function TNeighborDetector.SaveState:TNeighborDetectorSaveData;
begin
   Result.nID := FNeighborID;
   Result.cID := FCurrentID;
end;

// Sets
procedure TNeighborDetector.SetType(_Type: byte);
begin
   if (not IsValid) and (_type <= C_NEIGHBTYPE_MAX) then
   begin
      NeighborType := _Type;
   end;
end;


// Executes
procedure TNeighborDetector.BuildUpData(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
begin
   Case(NeighborType) of
      C_NEIGHBTYPE_VERTEX_VERTEX:     // vertex neighbors of vertexes.
      begin
         OrganizeVertexVertex(_Faces,_VertexesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_VERTEX_FACE:       // face neighbors of vertexes.
      begin
         OrganizeVertexFace(_Faces,_VertexesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_FACE_VERTEX:       // vertex neighbors of faces.
      begin
         OrganizeFaceVertex(_Faces,_VertexesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_FACE_FACE_FROM_EDGE:         // face neighbors of faces with common edges.
      begin
         OrganizeFaceFace(_Faces,_VertexesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_FACE_FACE_FROM_VERTEX:         // face neighbors of faces with common vertexes.
      begin
         OrganizeFaceFaceFromVertex(_Faces,_VertexesPerFace,_NumVertexes);
      end;
   end;
   DefragmentData;
   IsValid := true;
end;

procedure TNeighborDetector.BuildUpData(var _Geometry: CMeshGeometryList; _NumVertexes: integer);
begin
   Case(NeighborType) of
      C_NEIGHBTYPE_VERTEX_VERTEX:     // vertex neighbors of vertexes.
      begin
         OrganizeVertexVertex(_Geometry,_NumVertexes);
      end;
      C_NEIGHBTYPE_VERTEX_FACE:       // face neighbors of vertexes.
      begin
         OrganizeVertexFace((_Geometry.Current^ as TMeshBRepGeometry).Faces,(_Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_FACE_VERTEX:       // vertex neighbors of faces.
      begin
         OrganizeFaceVertex((_Geometry.Current^ as TMeshBRepGeometry).Faces,(_Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_FACE_FACE_FROM_EDGE:         // face neighbors of faces with common edges.
      begin
         OrganizeFaceFace((_Geometry.Current^ as TMeshBRepGeometry).Faces,(_Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_NumVertexes);
      end;
      C_NEIGHBTYPE_FACE_FACE_FROM_VERTEX:         // face neighbors of faces with common vertexes.
      begin
         OrganizeFaceFaceFromVertex((_Geometry.Current^ as TMeshBRepGeometry).Faces,(_Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_NumVertexes);
      end;
   end;
   DefragmentData;
   IsValid := true;
end;

procedure TNeighborDetector.OrganizeVertexVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, v, i : integer;
   SearchArray : array of array of integer;
begin
   // Setup Neighbors.
   InitializeNeighbors(_NumVertexes);
   SetLength(SearchArray,((_VertexesPerFace-1)*_VertexesPerFace) shr 1,2);
   f := 0;
   for v := 0 to _VertexesPerFace - 2 do
      for i := v+1 to _VertexesPerFace -1 do
      begin
         SearchArray[f,0] := v;
         SearchArray[f,1] := i;
         inc(f);
      end;

   // Main loop goes here.
   f := 0;
   while f < High(_Faces) do
   begin
      // check all neighbors of each vertex of the face.
      for i := Low(SearchArray) to High(SearchArray) do
      begin
         AddElementAtTarget(_Faces[f+SearchArray[i,0]],_Faces[f+SearchArray[i,1]]);
         AddElementAtTarget(_Faces[f+SearchArray[i,1]],_Faces[f+SearchArray[i,0]]);
      end;
      inc(f,_VertexesPerFace);
   end;

   for i := Low(SearchArray) to High(SearchArray) do
   begin
      SetLength(SearchArray,i,0);
   end;
   SetLength(SearchArray,0);
end;

procedure TNeighborDetector.OrganizeVertexVertex(const _Geometry: CMeshGeometryList; _NumVertexes: integer);
var
   f, v, i : integer;
   SearchArray : array of array of integer;
   VertexesPerFace: integer;
begin
   // Setup Neighbors.
   InitializeNeighbors(_NumVertexes);
   _Geometry.GoToFirstElement;
   while _Geometry.Current <> nil do
   begin
      VertexesPerFace := (_Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
      SetLength(SearchArray,((VertexesPerFace-1)*VertexesPerFace) shr 1,2);
      f := 0;
      for v := 0 to VertexesPerFace - 2 do
         for i := v+1 to VertexesPerFace -1 do
         begin
            SearchArray[f,0] := v;
            SearchArray[f,1] := i;
            inc(f);
         end;

      // Main loop goes here.
      f := 0;
      while f < High((_Geometry.Current^ as TMeshBRepGeometry).Faces) do
      begin
         // check all neighbors of each vertex of the face.
         for i := Low(SearchArray) to High(SearchArray) do
         begin
            AddElementAtTarget((_Geometry.Current^ as TMeshBRepGeometry).Faces[f+SearchArray[i,0]],(_Geometry.Current^ as TMeshBRepGeometry).Faces[f+SearchArray[i,1]]);
            AddElementAtTarget((_Geometry.Current^ as TMeshBRepGeometry).Faces[f+SearchArray[i,1]],(_Geometry.Current^ as TMeshBRepGeometry).Faces[f+SearchArray[i,0]]);
         end;
         inc(f,VertexesPerFace);
      end;

      for i := Low(SearchArray) to High(SearchArray) do
      begin
         SetLength(SearchArray,i,0);
      end;
      SetLength(SearchArray,0);
      _Geometry.GoToNextElement;
   end;
end;

procedure TNeighborDetector.OrganizeVertexFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f,face, v : integer;
begin
   // Setup Neighbors.
   InitializeNeighbors(_NumVertexes);

   // Main loop goes here.
   f := 0;
   face := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 1 do
      begin
         // Here we add the element to FNeighbors[f+v]
         AddElementAtTargetWithoutRepetition(face,_Faces[f+v]);
      end;
      inc(f,_VertexesPerFace);
      inc(face);
   end;
end;

procedure TNeighborDetector.OrganizeFaceVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, face, v, NumFaces, Value : integer;
   TempDetector : TNeighborDetector;
begin
   // Setup Neighbors.
   NumFaces := (High(_Faces)+1) div _VertexesPerFace;
   InitializeNeighbors(NumFaces);
   // Get Vertex neighbors from vertexes.
   if VertexVertexNeighbors = nil then
   begin
      TempDetector := TNeighborDetector.Create;
      TempDetector.BuildUpData(_Faces,_VertexesPerFace,_NumVertexes);
   end
   else
   begin
      TempDetector := VertexVertexNeighbors;
   end;

   // Main loop goes here.
   f := 0;
   face := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 1 do
      begin
         Value := TempDetector.GetNeighborFromID(_Faces[f+v]);
         while Value <> -1 do
         begin
            // Here we add the element to the face
            AddElementAtTarget(Value,face);
            Value := TempDetector.GetNextNeighbor;
         end;
      end;
      inc(f,_VertexesPerFace);
      inc(face);
   end;

   // Clean up memory
   if VertexVertexNeighbors = nil then
      TempDetector.Free;
end;

procedure TNeighborDetector.OrganizeFaceFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, face, v, vi, vn, fn, NumFaces, Value : integer;
   TempDetector : TNeighborDetector;
label
   FinishedVertex;
begin
   // Setup Neighbors.
   NumFaces := (High(_Faces)+1) div _VertexesPerFace;
   InitializeNeighbors(NumFaces);
   // Get face neighbors from vertexes.
   if VertexFaceNeighbors = nil then
   begin
      TempDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      TempDetector.BuildUpData(_Faces,_VertexesPerFace,_NumVertexes);
   end
   else
   begin
      TempDetector := VertexFaceNeighbors;
   end;

   // Main loop goes here.
   f := 0;
   face := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 2 do
      begin
         Value := TempDetector.GetNeighborFromID(_Faces[f+v]);
         while Value <> -1 do
         begin
            // Here we check if an edge belongs to both faces.
            fn := Value * _VertexesPerFace;
            if (f <> fn) then
            begin
               for vi := (v + 1) to (_VertexesPerFace - 1) do
               begin
                  for vn := 0 to _VertexesPerFace - 1 do
                  begin
                     if _Faces[f+vi] = _Faces[fn+vn] then
                     begin
                        // Here we add the element to the face
                        AddElementAtTarget(Value,face);
                        goto FinishedVertex;
                     end;
                  end;
               end;
            end;
            FinishedVertex:
            Value := TempDetector.GetNextNeighbor;
         end;
      end;
      inc(f,_VertexesPerFace);
      inc(face);
   end;

   // Clean up memory
   if VertexFaceNeighbors = nil then
      TempDetector.Free;
end;

// Another approach for Face neighbors of Faces, where each neighbor needs to have at least one common vertex instead of edge.
procedure TNeighborDetector.OrganizeFaceFaceFromVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, face, v, NumFaces, Value : integer;
   TempDetector : TNeighborDetector;
begin
   // Setup Neighbors.
   NumFaces := (High(_Faces)+1) div _VertexesPerFace;
   InitializeNeighbors(NumFaces);
   // Get face neighbors from vertexes.
   if VertexFaceNeighbors = nil then
   begin
      TempDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      TempDetector.BuildUpData(_Faces,_VertexesPerFace,_NumVertexes);
   end
   else
   begin
      TempDetector := VertexFaceNeighbors;
   end;

   // Main loop goes here.
   f := 0;
   face := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 2 do
      begin
         Value := TempDetector.GetNeighborFromID(_Faces[f+v]);
         while Value <> -1 do
         begin
            // Here we check if an edge belongs to both faces.
            if (face <> Value) then
            begin
               // Here we add the element to the face
               AddElementAtTarget(Value,face);
            end;
            Value := TempDetector.GetNextNeighbor;
         end;
      end;
      inc(f,_VertexesPerFace);
      inc(face);
   end;

   // Clean up memory
   if VertexFaceNeighbors = nil then
      TempDetector.Free;
end;

// Transform the data at the fragmented FNeighbors into a single array.
procedure TNeighborDetector.DefragmentData;
var
   e, i, Size: integer;
   Element: PIntegerItem;
begin
   Size := 0;
   // Let's fill the descriptors first.
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      Element := FNeighbors[i];
      FDescriptorData[i].Start := Size;
      while Element <> nil do
      begin
         Element := Element^.Next;
         inc(Size);
      end;
      FDescriptorData[i].Size := Size - FDescriptorData[i].Start;
   end;
   SetLength(FNeighborhoodData,Size);
   // Now, we fill the data.
   e := 0;
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      Element := FNeighbors[i];
      while Element <> nil do
      begin
         FNeighborhoodData[e] := Element^.Value;
         Element := Element^.Next;
         inc(e);
      end;
   end;
   // So... now that we've passed all the data from FNeighbors to an array, we
   // need to get rid of FNeighbors.
   ClearFNeighbors;
end;


// Adds
procedure TNeighborDetector.AddElementAtTarget(_Value: integer; _Target: integer);
var
   Element,Previous: PIntegerItem;
begin
   if FNeighbors[_Target] <> nil then
   begin
      Previous := FNeighbors[_Target];
      if _Value <> Previous^.Value then
      begin
         while Previous^.Next <> nil do
         begin
            Previous := Previous^.Next;
            if _Value = Previous^.Value then
               exit;
         end;
         new(Element);
         Element^.Value := _Value;
         Element^.Next := nil;
         Previous^.Next := Element;
      end;
   end
   else
   begin
      new(Element);
      Element^.Value := _Value;
      Element^.Next := nil;
      FNeighbors[_Target] := Element;
   end;
end;

procedure TNeighborDetector.AddElementAtTargetWithoutRepetition(_Value: integer; _Target: integer);
var
   Element,Previous: PIntegerItem;
begin
   new(Element);
   Element^.Value := _Value;
   Element^.Next := nil;
   if FNeighbors[_Target] <> nil then
   begin
      Previous := FNeighbors[_Target];
      while Previous^.Next <> nil do
      begin
         Previous := Previous^.Next;
      end;
      Previous^.Next := Element;
   end
   else
   begin
      FNeighbors[_Target] := Element;
   end;
end;

// ReOrder
procedure TNeighborDetector.GetStarOrder(const _Vertexes,_FaceNormals,_VertexNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
begin
   Case(NeighborType) of
      C_NEIGHBTYPE_VERTEX_VERTEX:     // vertex neighbors of vertexes.
      begin
         ReOrderVertexVertex(_Vertexes,_VertexNormals);
      end;
      C_NEIGHBTYPE_VERTEX_FACE:       // face neighbors of vertexes.
      begin
         if VertexVertexNeighbors <> nil then
         begin
            VertexVertexNeighbors.GetStarOrder(_Vertexes,_FaceNormals,_VertexNormals,_Faces,_VertexesPerFace);
         end;
         ReOrderVertexFace(_Vertexes,_VertexNormals,_Faces,_VertexesPerFace);
      end;
      C_NEIGHBTYPE_FACE_VERTEX:       // vertex neighbors of faces.
      begin
         if VertexVertexNeighbors <> nil then
         begin
            VertexVertexNeighbors.GetStarOrder(_Vertexes,_FaceNormals,_VertexNormals,_Faces,_VertexesPerFace);
         end;
         ReOrderFaceVertex(_Vertexes,_FaceNormals,_Faces,_VertexesPerFace);
      end;
      else //C_NEIGHBTYPE_FACE_FACE_FROM_EDGE or C_NEIGHBTYPE_FACE_FACE_FROM_VERTEX
      begin
         if VertexFaceNeighbors <> nil then
         begin
            VertexFaceNeighbors.GetStarOrder(_Vertexes,_FaceNormals,_VertexNormals,_Faces,_VertexesPerFace);
         end;
         ReOrderFaceFace(_Vertexes,_FaceNormals,_Faces,_VertexesPerFace);
      end;
   end;

end;

procedure TNeighborDetector.ReOrderVertexVertex(const _Vertexes,_VertexNormals: TAVector3f);
var
   v,i : integer;
   Order: auint32;
   Angles: afloat;
   Util: TVertexTransformationUtils;
   Direction,AxisX,AxisY: TVector3f;
begin
   // Let's reorder every vertex.
   Util := TVertexTransformationUtils.Create;
   for v := 0 to High(FDescriptorData) do
   begin
      if FDescriptorData[v].Size > 0 then
      begin
         // Setup and Backup Order
         SetLength(Order,FDescriptorData[v].Size);
         for i := Low(Order) to High(Order) do
         begin
            Order[i] := FNeighborhoodData[FDescriptorData[v].Start + i];
         end;
         // Setup Angles
         SetLength(Angles,FDescriptorData[v].Size);
         // Obtain tangent plane.
         i := Order[0];
         Direction := SetVector(_Vertexes[i].X - _Vertexes[v].X,_Vertexes[i].Y - _Vertexes[v].Y,_Vertexes[i].Z - _Vertexes[v].Z);
         Util.GetTangentPlaneFromNormalAndDirection(AxisX,AxisY,_VertexNormals[v],Direction);
         // Now we obtain the angle from each neighbour
         for i := Low(Order) to High(Order) do
         begin
            // Direction starts as the direction of the vertex composed of v
            // and the neighbour
            Direction := SetVector(_Vertexes[Order[i]].X - _Vertexes[v].X,_Vertexes[Order[i]].Y - _Vertexes[v].Y,_Vertexes[Order[i]].Z - _Vertexes[v].Z);
            Direction := Util.ProjectVectorOnTangentPlane(_VertexNormals[v],Direction);
            Normalize(Direction);
            // Direction ends up as the projection of that in the tangent plane.
            // What a mess! Sorry. But I'm lazy to create temp variables.

            // Finally, we obtain the angle from Direction and the Tangent Plane
            // (AxisX,AxisY).
            Angles[i] := Util.CleanAngleRadians(Util.GetArcCosineFromTangentPlane(Direction,AxisX,AxisY));
         end;
         // ReOrder the angles.
         QuickSortAngles(0,High(Angles),Order,Angles);
         // Replace the values.
         for i := Low(Order) to High(Order) do
         begin
            FNeighborhoodData[FDescriptorData[v].Start + i] := Order[i];
         end;
      end;
   end;
   SetLength(Order, 0);
   SetLength(Angles, 0);
   Util.Free;
end;

procedure TNeighborDetector.ReOrderVertexFace(const _Vertexes,_VertexNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
var
   v,i,c : integer;
   Order: auint32;
   Angles: afloat;
   Util: TVertexTransformationUtils;
   Direction,AxisX,AxisY: TVector3f;
begin
   // Let's reorder every vertex.
   Util := TVertexTransformationUtils.Create;
   for v := 0 to High(FDescriptorData) do
   begin
      if FDescriptorData[v].Size > 0 then
      begin
         // Setup and Backup Order
         SetLength(Order,FDescriptorData[v].Size);
         for i := Low(Order) to High(Order) do
         begin
            Order[i] := FNeighborhoodData[FDescriptorData[v].Start + i];
         end;
         // Setup Angles
         SetLength(Angles,FDescriptorData[v].Size);
         // Obtain tangent plane.
         i := GetTheVertexAfterMe(v,_VertexesPerFace,_Faces);
         Direction := SetVector(_Vertexes[i].X - _Vertexes[v].X,_Vertexes[i].Y - _Vertexes[v].Y,_Vertexes[i].Z - _Vertexes[v].Z);
         Util.GetTangentPlaneFromNormalAndDirection(AxisX,AxisY,_VertexNormals[v],Direction);
         // Now we obtain the angle from each neighbour
         for i := Low(Order) to High(Order) do
         begin
            // Direction starts as the direction of the vertex composed of v
            // and the neighbour
            Direction := GetFaceCenterPosition(Order[i],_Faces,_Vertexes,_VertexesPerFace);
            Direction := SetVector(Direction.X - _Vertexes[v].X,Direction.Y - _Vertexes[v].Y,Direction.Z - _Vertexes[v].Z);
            Direction := Util.ProjectVectorOnTangentPlane(_VertexNormals[v],Direction);
            Normalize(Direction);
            // Direction ends up as the projection of that in the tangent plane.
            // What a mess! Sorry. But I'm lazy to create temp variables.

            // Finally, we obtain the angle from Direction and the Tangent Plane
            // (AxisX,AxisY).
            Angles[i] := Util.CleanAngleRadians(Util.GetArcCosineFromTangentPlane(Direction,AxisX,AxisY));
         end;
         // ReOrder the angles.
         QuickSortAngles(0,High(Angles),Order,Angles);
         // Replace the values.
         for i := Low(Order) to High(Order) do
         begin
            FNeighborhoodData[FDescriptorData[v].Start + i] := Order[i];
         end;
      end;
   end;
   SetLength(Order, 0);
   SetLength(Angles, 0);
   Util.Free;
end;

procedure TNeighborDetector.ReOrderFaceVertex(const _Vertexes,_FaceNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
var
   v,i : integer;
   Order: auint32;
   Angles: afloat;
   Util: TVertexTransformationUtils;
   Center,Direction,AxisX,AxisY: TVector3f;
begin
   // Let's reorder every vertex.
   Util := TVertexTransformationUtils.Create;
   for v := 0 to High(FDescriptorData) do
   begin
      if FDescriptorData[v].Size > 0 then
      begin
         // Setup and Backup Order
         SetLength(Order,FDescriptorData[v].Size);
         for i := Low(Order) to High(Order) do
         begin
            Order[i] := FNeighborhoodData[FDescriptorData[v].Start + i];
         end;
         // Setup Angles
         SetLength(Angles,FDescriptorData[v].Size);
         // Obtain tangent plane.
         Center := GetFaceCenterPosition(v,_Faces,_Vertexes,_VertexesPerFace);
         i := Order[0];
         Direction := SubtractVector(_Vertexes[i],Center);
         Util.GetTangentPlaneFromNormalAndDirection(AxisX,AxisY,_FaceNormals[v],Direction);
         // Now we obtain the angle from each neighbour
         for i := Low(Order) to High(Order) do
         begin
            // Direction starts as the direction of the vertex composed of v
            // and the neighbour
            Direction := SetVector(_Vertexes[Order[i]].X - Center.X,_Vertexes[Order[i]].Y - Center.Y,_Vertexes[Order[i]].Z - Center.Z);
            Direction := Util.ProjectVectorOnTangentPlane(_FaceNormals[v],Direction);
            Normalize(Direction);
            // Direction ends up as the projection of that in the tangent plane.
            // What a mess! Sorry. But I'm lazy to create temp variables.

            // Finally, we obtain the angle from Direction and the Tangent Plane
            // (AxisX,AxisY).
            Angles[i] := Util.CleanAngleRadians(Util.GetArcCosineFromTangentPlane(Direction,AxisX,AxisY));
         end;
         // ReOrder the angles.
         QuickSortAngles(0,High(Angles),Order,Angles);
         // Replace the values.
         for i := Low(Order) to High(Order) do
         begin
            FNeighborhoodData[FDescriptorData[v].Start + i] := Order[i];
         end;
      end;
   end;
   SetLength(Order, 0);
   SetLength(Angles, 0);
   Util.Free;
end;

procedure TNeighborDetector.ReOrderFaceFace(const _Vertexes,_FaceNormals: TAVector3f; const _Faces: auint32; _VertexesPerFace: integer);
var
   v,i : integer;
   Order: auint32;
   Angles: afloat;
   Util: TVertexTransformationUtils;
   Center,Direction,AxisX,AxisY: TVector3f;
begin
   // Let's reorder every vertex.
   Util := TVertexTransformationUtils.Create;
   for v := 0 to High(FDescriptorData) do
   begin
      if FDescriptorData[v].Size > 0 then
      begin
         // Setup and Backup Order
         SetLength(Order,FDescriptorData[v].Size);
         for i := Low(Order) to High(Order) do
         begin
            Order[i] := FNeighborhoodData[FDescriptorData[v].Start + i];
         end;
         // Setup Angles
         SetLength(Angles,FDescriptorData[v].Size);
         // Obtain tangent plane.
         Center := GetFaceCenterPosition(v,_Faces,_Vertexes,_VertexesPerFace);
         i := Order[0];
         Direction := SubtractVector(GetFaceCenterPosition(i,_Faces,_Vertexes,_VertexesPerFace),Center);
         Util.GetTangentPlaneFromNormalAndDirection(AxisX,AxisY,_FaceNormals[v],Direction);
         // Now we obtain the angle from each neighbour
         for i := Low(Order) to High(Order) do
         begin
            // Direction starts as the direction of the vertex composed of v
            // and the neighbour
            Direction := SubtractVector(GetFaceCenterPosition(Order[i],_Faces,_Vertexes,_VertexesPerFace),Center);
            Direction := Util.ProjectVectorOnTangentPlane(_FaceNormals[v],Direction);
            Normalize(Direction);
            // Direction ends up as the projection of that in the tangent plane.
            // What a mess! Sorry. But I'm lazy to create temp variables.

            // Finally, we obtain the angle from Direction and the Tangent Plane
            // (AxisX,AxisY).
            Angles[i] := Util.CleanAngleRadians(Util.GetArcCosineFromTangentPlane(Direction,AxisX,AxisY));
         end;
         // ReOrder the angles.
         QuickSortAngles(0,High(Angles),Order,Angles);
         // Replace the values.
         for i := Low(Order) to High(Order) do
         begin
            FNeighborhoodData[FDescriptorData[v].Start + i] := Order[i];
         end;
      end;
   end;
   SetLength(Order, 0);
   SetLength(Angles, 0);
   Util.Free;
end;

// Ascending Quick Sort (To make it descending, change the > and < in both whiles)
procedure TNeighborDetector.QuickSortAngles(_min, _max : integer; var _Order: auint32; const _Angles : afloat);
var
   Lo, Hi, Mid, T: Integer;
   A : real;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while (_Angles[_Order[Lo]] - _Angles[_Order[Mid]]) < 0 do Inc(Lo);
      while (_Angles[_Order[Hi]] - _Angles[_Order[Mid]]) > 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         T := _Order[Lo];
         _Order[Lo] := _Order[Hi];
         _Order[Hi] := T;
         A := _Angles[Lo];
         _Angles[Lo] := _Angles[Hi];
         _Angles[Hi] := A;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortAngles(_min, Hi, _Order, _Angles);
   if Lo < _max then
      QuickSortAngles(Lo, _max, _Order, _Angles);
end;

function TNeighborDetector.GetTheVertexAfterMe(_VertexID,_VertexesPerFace: integer; const _Faces: auint32): integer;
var
   i,c : integer;
begin
   i := _VertexID * _VertexesPerFace;
   c := 0;
   while _Faces[i] <> _VertexID do
   begin
      inc(i);
      inc(c);
   end;
   if c = _VertexesPerFace then
   begin
      Result := _Faces[_VertexID * _VertexesPerFace];
   end
   else
   begin
      Result := _Faces[i+1];
   end;
end;

function TNeighborDetector.GetFaceCenterPosition(_Face: integer; const _Faces:auint32; const _Vertexes: TAVector3f; _VertexesPerFace: integer): TVector3f;
var
   i : integer;
begin
   Result := SetVector(0,0,0);
   for i := 0 to _VertexesPerFace do
   begin
      Result.X := Result.X + _Vertexes[_Faces[(_Face*_VertexesPerFace)+i]].X;
      Result.Y := Result.Y + _Vertexes[_Faces[(_Face*_VertexesPerFace)+i]].Y;
      Result.Z := Result.Z + _Vertexes[_Faces[(_Face*_VertexesPerFace)+i]].Z;
   end;
   Result.X := Result.X / _VertexesPerFace;
   Result.Y := Result.Y / _VertexesPerFace;
   Result.Z := Result.Z / _VertexesPerFace;
end;

// Requests
function TNeighborDetector.GetNeighborFromID(_ID: integer): integer;
begin
   if (_ID >= 0) and (_ID <= High(FDescriptorData)) then
   begin
      FCurrentID := _ID;
      FRequest := FNeighborhoodData[FDescriptorData[_ID].Start];
      FNeighborID := 0;
   end
   else
   begin
      FRequest := -1;
   end;
   Result := FRequest;
end;

function TNeighborDetector.GetNextNeighbor: integer;
begin
   if FRequest <> -1 then
   begin
      inc(FNeighborID);
      if FNeighborID < FDescriptorData[FCurrentID].Size then
      begin
         FRequest := FNeighborhoodData[FDescriptorData[FCurrentID].Start + FNeighborID];
      end
      else
      begin
         FRequest := -1;
      end;
      Result := FRequest;
   end
   else
      Result := -1;
end;

// Copy
procedure TNeighborDetector.Assign(const _Source: TNeighborDetector);
var
   i: integer;
   Element, NewElement, PreviousElement: PIntegerItem;
begin
   SetLength(FNeighbors, High(_Source.FNeighbors) + 1);
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      if _Source.FNeighbors[i] = nil then
      begin
         FNeighbors[i] := nil;
      end
      else
      begin
         Element := _Source.FNeighbors[i];
         PreviousElement := nil;
         while Element <> nil do
         begin
            new(NewElement);
            NewElement^.Value := Element^.Value;
            if PreviousElement <> nil then
            begin
               PreviousElement^.Next := NewElement;
            end
            else
            begin
               FNeighbors[i] := NewElement;
            end;
            NewElement^.Next := nil;
            PreviousElement := NewElement;
            Element := Element^.Next;
         end;
      end;
   end;
   FRequest := _Source.FRequest;
   FNeighborID := _Source.FNeighborID;
   FCurrentID := _Source.FCurrentID;
   SetLength(FNeighborhoodData, High(_Source.FNeighborhoodData) + 1);
   for i := Low(FNeighborhoodData) to High(FNeighborhoodData) do
   begin
      FNeighborhoodData[i] := _Source.FNeighborhoodData[i];
   end;
   SetLength(FDescriptorData, High(_Source.FDescriptorData) + 1);
   for i := Low(FDescriptorData) to High(FDescriptorData) do
   begin
      FDescriptorData[i].Start := _Source.FDescriptorData[i].Start;
      FDescriptorData[i].Size := _Source.FDescriptorData[i].Size;
   end;
   NeighborType := _Source.NeighborType;
   IsValid := _Source.IsValid;

   // It's highly recommended to change these ones later.
   VertexVertexNeighbors := _Source.VertexVertexNeighbors;
   VertexFaceNeighbors := _Source.VertexFaceNeighbors;
end;

end.
