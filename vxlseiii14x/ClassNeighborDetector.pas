unit ClassNeighborDetector;

interface

uses BasicDataTypes, SysUtils, PSAPI, Windows, ClassMeshGeometryList;

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
         // Requests
         function GetNeighborFromID(_ID: integer): integer;
         function GetNextNeighbor: integer;
   end;

implementation

uses MeshBRepGeometry;

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

// Requests
function TNeighborDetector.GetNeighborFromID(_ID: integer): integer;
begin
   if (_ID >= 0) and (_ID <= High(FDescriptorData)) then
   begin
      FCurrentID := _ID;
      FRequest := FNeighborhoodData[FDescriptorData[_ID].Start];
      FNeighborID := 0;
      Result := FRequest;
   end
   else
   begin
      FRequest := -1;
      Result := -1;
   end;
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

end.
