unit ClassNeighborDetector;

interface

uses BasicDataTypes;

const
   C_NEIGHBTYPE_VERTEX_VERTEX = 0;     // vertex neighbors of vertexes.
   C_NEIGHBTYPE_VERTEX_FACE = 1;       // face neighbors of vertexes.
   C_NEIGHBTYPE_FACE_VERTEX = 2;       // vertex neighbors of faces.
   C_NEIGHBTYPE_FACE_FACE = 3;         // face neighbors of faces.

type
   PIntegerItem = ^TIntegerItem;
   TIntegerItem = record
      Value : integer;
      Next : PIntegerItem;
   end;

   TNeighborDetector = class
      private
         FNeighbors: array of PIntegerItem;
         FRequest : PIntegerItem;
         // Constructors and Destructors
         procedure Initialize;
         procedure InitializeNeighbors(_NumElements: integer);
         // Executes
         procedure OrganizeVertexVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure OrganizeVertexFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure OrganizeFaceVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         procedure OrganizeFaceFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         // Adds
         procedure AddElementAtTarget(_Value: integer; _Target: integer);
         // Removes
         procedure ClearElement(_Element : PIntegerItem);
      public
         NeighborType : byte;
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(_Type : byte); overload;
         destructor Destroy; override;
         procedure Clear;
         // Executes
         procedure BuildUpData(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
         // Requests
         function GetNeighborFromID(_ID: integer): integer;
         function GetNextNeighbor: integer;
   end;

implementation

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
   FRequest := nil;
   SetLength(FNeighbors,0);
end;

procedure TNeighborDetector.Clear;
var
   i : integer;
begin
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      // clear each element.
      ClearElement(FNeighbors[i]);
      FNeighbors[i] := nil;
   end;
   Initialize;
end;

procedure TNeighborDetector.InitializeNeighbors(_NumElements: integer);
var
   i : integer;
begin
   SetLength(FNeighbors,_NumElements);
   for i := Low(FNeighbors) to High(FNeighbors) do
   begin
      FNeighbors[i] := nil;
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
      C_NEIGHBTYPE_FACE_FACE:         // face neighbors of faces.
      begin
         OrganizeFaceFace(_Faces,_VertexesPerFace,_NumVertexes);
      end;
   end;
end;


procedure TNeighborDetector.OrganizeVertexVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, v, i : integer;
   VertsHit : array of array of boolean;
begin
   // Setup VertsHit
   SetLength(VertsHit,_NumVertexes,_NumVertexes);
   for v := Low(VertsHit) to High(VertsHit) do
   begin
      for i := Low(VertsHit[v]) to High(VertsHit[v]) do
      begin
         VertsHit[v,i] := false;
      end;
      VertsHit[v,v] := true;
   end;
   // Setup Neighbors.
   InitializeNeighbors(_NumVertexes);

   // Main loop goes here.
   f := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 1 do
      begin
         // for each vertex, try to add all its neighbors.
         for i := 0 to _VertexesPerFace - 1 do
         begin
            if not VertsHit[_Faces[f+v],_Faces[f+i]] then
            begin
               // Here we add the element to FNeighbors[f+v]
               AddElementAtTarget(_Faces[f+i],_Faces[f+v]);
               VertsHit[_Faces[f+v],_Faces[f+i]] := true;
            end;
         end;
      end;
      inc(f,_VertexesPerFace);
   end;
   // Clean up memory
   for v := Low(VertsHit) to High(VertsHit) do
   begin
      SetLength(VertsHit[v],0);
   end;
   SetLength(VertsHit,0);
end;

procedure TNeighborDetector.OrganizeVertexFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, v : integer;
begin
   // Setup Neighbors.
   InitializeNeighbors(_NumVertexes);

   // Main loop goes here.
   f := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 1 do
      begin
         // Here we add the element to FNeighbors[f+v]
         AddElementAtTarget(f div _VertexesPerFace,_Faces[f+v]);
      end;
      inc(f,_VertexesPerFace);
   end;
end;

procedure TNeighborDetector.OrganizeFaceVertex(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, v, NumFaces, Value : integer;
   VertsHit : array of boolean;
   TempDetector : TNeighborDetector;
begin
   // Setup Neighbors.
   NumFaces := (High(_Faces)+1) div _VertexesPerFace;
   InitializeNeighbors(NumFaces);
   // Setup VertsHit
   SetLength(VertsHit,_NumVertexes);
   for v := Low(VertsHit) to High(VertsHit) do
   begin
      VertsHit[v] := false;
   end;
   // Get Vertex neighbors from vertexes.
   TempDetector := TNeighborDetector.Create;
   TempDetector.BuildUpData(_Faces,_VertexesPerFace,_NumVertexes);

   // Main loop goes here.
   f := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 1 do
      begin
         Value := TempDetector.GetNeighborFromID(_Faces[f+v]);
         while Value <> -1 do
         begin
            if not VertsHit[Value] then
            begin
               // Here we add the element to the face
               AddElementAtTarget(Value,f div _VertexesPerFace);
               VertsHit[Value] := true;
            end;
            Value := TempDetector.GetNextNeighbor;
         end;
      end;
      // Reset VertsHit
      for v := Low(VertsHit) to High(VertsHit) do
      begin
         VertsHit[v] := false;
      end;
      inc(f,_VertexesPerFace);
   end;

   // Clean up memory
   TempDetector.Free;
   SetLength(VertsHit,0);
end;

procedure TNeighborDetector.OrganizeFaceFace(const _Faces: auint32; _VertexesPerFace,_NumVertexes: integer);
var
   f, v, NumFaces, Value : integer;
   FacesHit : array of boolean;
   TempDetector : TNeighborDetector;
begin
   // Setup Neighbors.
   NumFaces := (High(_Faces)+1) div _VertexesPerFace;
   InitializeNeighbors(NumFaces);
   // Setup VertsHit
   SetLength(FacesHit,NumFaces);
   for v := Low(FacesHit) to High(FacesHit) do
   begin
      FacesHit[v] := false;
   end;
   // Get face neighbors from vertexes.
   TempDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
   TempDetector.BuildUpData(_Faces,_VertexesPerFace,_NumVertexes);

   // Main loop goes here.
   f := 0;
   while f < High(_Faces) do
   begin
      // check each vertex of the face.
      for v := 0 to _VertexesPerFace - 1 do
      begin
         FacesHit[f div _VertexesPerFace] := true;
         Value := TempDetector.GetNeighborFromID(_Faces[f+v]);
         while Value <> -1 do
         begin
            if not FacesHit[Value] then
            begin
               // Here we add the element to the face
               AddElementAtTarget(Value,f div _VertexesPerFace);
               FacesHit[Value] := true;
            end;
            Value := TempDetector.GetNextNeighbor;
         end;
      end;
      // Reset VertsHit
      for v := Low(FacesHit) to High(FacesHit) do
      begin
         FacesHit[v] := false;
      end;
      inc(f,_VertexesPerFace);
   end;

   // Clean up memory
   TempDetector.Free;
   SetLength(FacesHit,0);
end;

// Adds
procedure TNeighborDetector.AddElementAtTarget(_Value: integer; _Target: integer);
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


// Removes
procedure TNeighborDetector.ClearElement(_Element : PIntegerItem);
begin
   if _Element <> nil then
   begin
      ClearElement(_Element^.Next);
      Dispose(_Element);
   end;
end;

// Requests
function TNeighborDetector.GetNeighborFromID(_ID: integer): integer;
begin
   if (_ID >= 0) and (_ID <= High(FNeighbors)) then
   begin
      FRequest := FNeighbors[_ID];
      Result := GetNextNeighbor;
   end
   else
   begin
      Result := -1;
   end;
end;

function TNeighborDetector.GetNextNeighbor: integer;
begin
   if FRequest <> nil then
   begin
      Result := FRequest^.Value;
      FRequest := FRequest^.Next;
   end
   else
      Result := -1;
end;


end.
