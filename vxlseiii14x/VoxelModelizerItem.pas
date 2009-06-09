unit VoxelModelizerItem;

interface

uses BasicFunctions, BasicDataTypes, VoxelMap, Normals, Class2DPointQueue,
   BasicConstants, ThreeDMap, Voxel_Engine, Palette, Dialogs, SysUtils;

type
   TVoxelModelizerItem = class
      private
         // Colouring procedure
         procedure SetColour(const _VoxelMap, _ColourMap: TVoxelMap; const _Palette: TPalette; _MyClassification: single);
         // Classification procedures
         procedure BuildFilledVerts(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; _MyClassification: single; _MySurface: integer);
         procedure BuildFilledEdges(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; _MyClassification: single; _MySurface: integer);
         procedure BuildFilledFaces(const _VoxelMap: TVoxelMap; const Cube : TNormals; _MyClassification: single);
         // Vertex construction procedures
         function FaceHasVertexes(_face: integer): boolean;
         function FaceHasEdges(_face: integer): boolean;
         // Face construction procedures
         procedure MakeFacesFromVertexes(const _VertexPositions: TAVector3i; const _VertexList: AInt32; var _EdgeMap: T3DMap);
         procedure MakeFacesFromEdges(const _VertexPositions: TAVector3i; const _VertexList: AInt32; var _EdgeMap: T3DMap);
         procedure MakeACube(const _MyPosition: TVector3i; var _VertexMap : T3DIntGrid; var _NumVertices: integer);
      public
         // Position
         x, y, z: integer;
         MyClassification: single;
         MySurface: integer;
         // Colour
         Colour: TVector4f;
         // Region as a cube
         FilledVerts: array[0..7] of boolean;
         FilledEdges: array[0..11] of boolean;
         FilledFaces: array[0..5] of boolean;
         // Situation per face.
         FaceSettings: array[0..5] of byte;
         // Vertex positions and lists.
         VertexGeneratedList : AInt32;
         EdgeGeneratedList : AInt32;
         FaceGeneratedList : Aint32;

         VertexGeneratedPositions : TAVector3i;
         EdgeGeneratedPositions : TAVector3i;
         FaceGeneratedPositions : TAVector3i;
         // Faces
         Faces: AInt32;
         FaceLocation: AInt32;

         // Constructors and Destructors
         constructor Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; var _EdgeMap: T3DMap; _x, _y, _z : integer; var _TotalNumVertexes: integer; const _Palette: TPalette; const _ColourMap: TVoxelMap);
         destructor Destroy; override;
         // Adds
         function AddVertex( var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer; var _VertexList: TAVector3i): integer;
   end;

implementation

constructor TVoxelModelizerItem.Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; var _EdgeMap: T3DMap; _x, _y, _z : integer; var _TotalNumVertexes: integer; const _Palette: TPalette; const _ColourMap: TVoxelMap);
var
   v1,v2,e1,e2,p,i : integer;
   Cube : TNormals;
   v0x,v0y,v0z: integer;
   VisitedEdgesVertex: array[0..11] of boolean;
   VisitedEdges: array[0..11] of boolean;
   ExternalFaceEdges: array[0..11] of boolean;
   InternalFaceEdges: array[0..11] of boolean;
begin
   // Reset basic variables.
   x := _x;
   y := _y;
   z := _z;
   Cube := TNormals.Create(6);
   // Semi surface or surface?
   MyClassification := _VoxelMap.MapSafe[x,y,z];
   // Which kind of semi-surface?
   MySurface := _SurfaceMap[x,y,z];
   // initial position in the vertex map;
   v0x := x * C_VP_HIGH;
   v0y := y * C_VP_HIGH;
   v0z := z * C_VP_HIGH;
   // Set the Colour from all faces that we'll generate here
   SetColour(_VoxelMap,_ColourMap,_Palette,MyClassification);

   // Check which vertices, edges and faces are in and out of the surface.
   BuildFilledVerts(_VoxelMap,_SurfaceMap,Cube,MyClassification,MySurface);
   BuildFilledEdges(_VoxelMap,_SurfaceMap,Cube,MyClassification,MySurface);
   BuildFilledFaces(_VoxelMap,Cube,MyClassification);

   // Let's analyse the situation for each edge and add the vertices.
   // First, split the cube into 6 faces. Each face has 4 edges.
   // FaceVerts has (topright, bottomright, bottomleft, topleft) for each face
   // FaceEdges has (right, bottom, left, top) for each face.

   // Prepare our variables for the construction of vertexes.
   SetLength(VertexGeneratedList,0);
   SetLength(EdgeGeneratedList,0);
   SetLength(FaceGeneratedList,0);
   SetLength(VertexGeneratedPositions,0);
   SetLength(EdgeGeneratedPositions,0);
   SetLength(FaceGeneratedPositions,0);
   for i := 0 to 11 do
   begin
      VisitedEdgesVertex[i] := false;
      VisitedEdges[i] := false;
      InternalFaceEdges[i] := false;
      ExternalFaceEdges[i] := false;
   end;
   for i := 0 to 5 do // for each face
   begin
      // check if this face will constructed based on vertexes ('traditional' marching cubes)
      if FaceHasVertexes(i) then
      begin
         // We'll generate new vertexes based on edges where only one of its vertexes is in the volume.
         FaceSettings[i] := C_FACE_SET_VERT;
         for p := 0 to 3 do // for each edge from the face i
         begin
            v1 := p + (i * 4); // vertice 1 index
            if not VisitedEdgesVertex[FaceEdges[v1]] then
            begin
               VisitedEdgesVertex[FaceEdges[v1]] := true; // avoid multiples vertexes at the same place
               v2 := ((p + 1) mod 4) + (i * 4); // vertice 2 index
               if FilledVerts[FaceVerts[v1]] xor FilledVerts[FaceVerts[v2]] then
               begin
                  // Add a vertex in the middle of the edge.
                  SetLength(VertexGeneratedList,High(VertexGeneratedList)+2);
                  VertexGeneratedList[High(VertexGeneratedList)] := AddVertex(_VertexMap,v0x + VertexPoints[i,p,1,0], v0y + VertexPoints[i,p,1,1], v0z + VertexPoints[i,p,1,2],_TotalNumVertexes,VertexGeneratedPositions);
               end;
            end;
         end;
      end
      else
      begin
         // check if this face will constructed based on edges
         if FaceHasEdges(i) then
         begin
            // We'll generate new vertexes based on filled edges
            FaceSettings[i] := C_FACE_SET_EDGE;
            for p := 0 to 3 do // for each edge from the face i
            begin
               v1 := p + (i * 4); // edge index on FaceEdge
               if (FilledEdges[FaceEdges[v1]] and (not VisitedEdges[FaceEdges[v1]])) then
               begin
                  VisitedEdges[FaceEdges[v1]] := true;
                  // Create vertexes in the middle of the 4 neighboor edges.
                  e1 := FaceEdges[v1] * 4;
                  e2 := e1 + 4;
                  SetLength(EdgeGeneratedList,High(EdgeGeneratedList)+5);
                  while e1 < e2 do
                  begin
                     // Check if the neighboor edge is filled.
                     if FilledEdges[EdgeNeighboorList[e1]] then
                     begin
                        // calculate the vertex between FaceEdges[v1] and FilledEdges[EdgeNeighboorList[e1]]
                        // to prevent shapes from getting mixed up.
                        EdgeGeneratedList[High(EdgeGeneratedList)- (e2 - e1 - 1)] := AddVertex(_VertexMap,v0x + ((EdgeCentralPoints[EdgeNeighboorList[e1],0] + EdgeCentralPoints[FaceEdges[v1],0]) div 2), v0y + ((EdgeCentralPoints[EdgeNeighboorList[e1],1] + EdgeCentralPoints[FaceEdges[v1],1]) div 2), v0z + ((EdgeCentralPoints[EdgeNeighboorList[e1],2] + EdgeCentralPoints[FaceEdges[v1],2]) div 2),_TotalNumVertexes,EdgeGeneratedPositions);
                     end
                     else
                     begin
                        // Add a vertex in the middle of the edge.
                        EdgeGeneratedList[High(EdgeGeneratedList)- (e2 - e1 - 1)] := AddVertex(_VertexMap,v0x + EdgeCentralPoints[EdgeNeighboorList[e1],0], v0y + EdgeCentralPoints[EdgeNeighboorList[e1],1], v0z + EdgeCentralPoints[EdgeNeighboorList[e1],2],_TotalNumVertexes,EdgeGeneratedPositions);
                     end;
                     inc(e1);
                  end;
               end;
            end;
         end
         else
         begin
            // We'll generate new vertexes based on filled faces
            FaceSettings[i] := C_FACE_SET_FACE;
            if FilledFaces[i] then
            begin
               SetLength(FaceGeneratedList,High(FaceGeneratedList)+5);
               for p := 0 to 3 do // for each edge from the face i
               begin
                  e1 := p  + (i * 4); // edge index on FaceEdge
                  // fill the beggining of each edge with a vertex
                  FaceGeneratedList[High(FaceGeneratedList) - (3 - p)] := AddVertex(_VertexMap,v0x + VertexPoints[i,p,0,0], v0y + VertexPoints[i,p,0,1], v0z + VertexPoints[i,p,0,2],_TotalNumVertexes,FaceGeneratedPositions);
                  ExternalFaceEdges[FaceEdges[e1]] := true;
               end;
            end;
         end;
      end;
   end;
   // Let's build the face vertex ones.
   for i := 0 to 5 do
   begin
      // check the ones that have faces.
      if FilledFaces[i] and (FaceSettings[i] = C_FACE_SET_FACE) then
      begin
         for p := 0 to 3 do // for each edge from the face i
         begin
            v1 := p  + (i * 4); // edge index on FaceEdge
            e1 := FaceEdges[v1] * 4;
            e2 := e1 + 4;
            while e1 < e2 do
            begin
               if (not ExternalFaceEdges[EdgeNeighboorList[e1]]) and (not InternalFaceEdges[EdgeNeighboorList[e1]]) then
               begin
                  InternalFaceEdges[EdgeNeighboorList[e1]] := true;
                  SetLength(FaceGeneratedList,High(FaceGeneratedList)+2);
                  FaceGeneratedList[High(FaceGeneratedList)] := AddVertex(_VertexMap,v0x + EdgeCentralPoints[EdgeNeighboorList[e1],0], v0y + EdgeCentralPoints[EdgeNeighboorList[e1],1], v0z + EdgeCentralPoints[EdgeNeighboorList[e1],2],_TotalNumVertexes,FaceGeneratedPositions);
               end;
               inc(e1);
            end;
         end;
      end;
   end;
   // Here we start all procedures to build the faces.
   // First we build the faces generated from vertexes.
   if High(VertexGeneratedPositions) > -1 then
      MakeFacesFromVertexes(VertexGeneratedPositions,VertexGeneratedList,_EdgeMap);

   // Then we build the faces generated from edges.
   if High(EdgeGeneratedPositions) > -1 then
      MakeFacesFromEdges(EdgeGeneratedPositions,EdgeGeneratedList,_EdgeMap);

   // Finally we build the faces generated from faces.
   if High(FaceGeneratedPositions) > -1 then
      MakeFacesFromVertexes(FaceGeneratedPositions,FaceGeneratedList,_EdgeMap);

   // If vertexes, edges and faces = 0. Do the lonely cube.
   if High(Faces) < 0 then
      MakeACube(SetVectori(v0x,v0y,v0z),_VertexMap,_TotalNumVertexes);

   for i:= Low(FaceLocation) to High(FaceLocation) do
      FaceLocation[i] := -1;
   Cube.Free;
end;

destructor TVoxelModelizerItem.Destroy;
begin
   SetLength(Faces,0);
   SetLength(FaceLocation,0);
   SetLength(VertexGeneratedList,0);
   SetLength(EdgeGeneratedList,0);
   SetLength(FaceGeneratedList,0);
   SetLength(VertexGeneratedPositions,0);
   SetLength(EdgeGeneratedPositions,0);
   SetLength(FaceGeneratedPositions,0);
   inherited Destroy;
end;

// Check which vertexes are inside or outside the surface.
procedure TVoxelModelizerItem.BuildFilledVerts(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; _MyClassification: single; _MySurface: integer);
var
   i,imax,v : integer;
   CheckPoint : TVector3f;
   Point : TVector3i;
   VoxelClassification: single;
begin
   // check all 8 vertexes.
   for v := 0 to 7 do
   begin
      // i points to the first of the 7 neighboors that must be checked, to detect
      // if the vertex is inside or outside the surface.
      i := v * 8;
      // check if the vertex is in a location where the surface can pass.
      if (_MyClassification = C_SURFACE) or ((_MySurface and VertexRequirements[v]) <> 0) then
      begin
         FilledVerts[v] := true;
         imax := i + 7;
      end
      else
      begin
         FilledVerts[v] := false;
         imax := i - 1;
      end;
      // check if this same vertex exists at every one of the 7 neightboors.
      while i < imax do
      begin
         CheckPoint := Cube[VertexCheck[i]];
         Point.X := x + Round(CheckPoint.X);
         Point.Y := y + Round(CheckPoint.Y);
         Point.Z := z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         FilledVerts[v] := FilledVerts[v] and (VoxelClassification >= C_SURFACE);
         // if the neighboor is not a surface, check for semi-surface.
         if not FilledVerts[v] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSVertexesCheck[i] <> 0  then
               begin // if the semi-surface exists, then it is still in.
                  FilledVerts[v] := true;
                  inc(i);
               end
               else // if not, leaves the loop
                  i := imax;
            end
            else  // if not, leaves the loop
               i := imax;
         end
         else // check next element.
            inc(i);
      end;
   end;
end;

// Check which edges are inside or outside the surface.
procedure TVoxelModelizerItem.BuildFilledEdges(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; _MyClassification: single; _MySurface: integer);
var
   i,imax,e : integer;
   CheckPoint : TVector3f;
   Point : TVector3i;
   VoxelClassification: single;
begin
   for e := 0 to 11 do
   begin
      // i points to the first of the 3 neighboors that must be checked, to detect
      // if the edge is inside or outside the surface.
      i := e * 3;
      // check if the edge is in a location where the surface can pass.
      if (_MyClassification = C_SURFACE) or ((_MySurface and VertexRequirements[e]) <> 0) then
      begin
         FilledEdges[e] := true;
         imax := i + 3;
      end
      else
      begin
         FilledEdges[e] := false;
         imax := i - 1;
      end;
      // check if this same edge exists at every one of the 3 neightboors.
      while i < imax do
      begin
         CheckPoint := Cube[EdgeCheck[i]];
         Point.X := x + Round(CheckPoint.X);
         Point.Y := y + Round(CheckPoint.Y);
         Point.Z := z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         FilledEdges[e] := FilledEdges[e] and (VoxelClassification >= C_SURFACE);
         // if the neighboor is not a surface, check for semi-surface.
         if not FilledEdges[e] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSEdgesCheck[i] <> 0  then
               begin
                  FilledEdges[e] := true;
                  inc(i);
               end
               else
                  i := imax;
            end
            else
               i := imax;
         end
         else
            inc(i);
      end;
   end;
end;

// Check which faces are inside or outside the surface.
procedure TVoxelModelizerItem.BuildFilledFaces(const _VoxelMap: TVoxelMap; const Cube : TNormals; _MyClassification: single);
var
   f : integer;
   CheckPoint : TVector3f;
   Point : TVector3i;
   VoxelClassification: single;
begin
   // This is restricted for surfaces.
   if (_MyClassification = C_SURFACE) then
   begin
      // check all 6 faces.
      for f := 0 to 5 do
      begin
         CheckPoint := Cube[FaceCheck[f]];
         Point.X := x + Round(CheckPoint.X);
         Point.Y := y + Round(CheckPoint.Y);
         Point.Z := z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         FilledFaces[f] := VoxelClassification >= C_SURFACE;
      end;
   end
   else
   begin
      // all six faces are outside.
      for f := 0 to 5 do
         FilledFaces[f] := false;
   end;
end;

function TVoxelModelizerItem.FaceHasVertexes(_face: integer): boolean;
var
   v,vmax : integer;
begin
   // check if this face will constructed based on vertexes (traditional marching cubes)
   v := _face * 4;
   vmax := v + 4;
   Result := false;
   while v < vmax do
   begin
      Result := Result or FilledVerts[FaceVerts[v]];
      inc(v);
   end;
end;

function TVoxelModelizerItem.FaceHasEdges(_face: integer): boolean;
var
   e,emax: integer;
begin
   // check if this face will constructed based on edges
   e := _face * 4;
   emax := e + 4;
   Result := false;
   while e < emax do
   begin
      Result := Result or FilledEdges[FaceEdges[e]];
      inc(e);
   end;
end;

function TVoxelModelizerItem.AddVertex(var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer; var _VertexList: TAVector3i): integer;
begin
   SetLength(_VertexList,High(_VertexList)+2);
   _VertexList[High(_VertexList)].X := _x;
   _VertexList[High(_VertexList)].Y := _y;
   _VertexList[High(_VertexList)].Z := _z;
   if _VertexMap[_x,_y,_z] = -1 then
   begin
      _VertexMap[_x,_y,_z] := _NumVertices;
      Result := _NumVertices;
      inc(_NumVertices);
   end
   else
   begin
      Result := _VertexMap[_x,_y,_z];
   end;
end;

// - 1) Build a distance table between the vertexes (not using square root).
// - 2) Order edges by distances (32, 64, 96 and 128)
// - 3) Draw each edge in the edge in the hashing and check for interceptions.
// - 4) Combine linked vertexes from the surviving edges to build the faces.
procedure TVoxelModelizerItem.MakeFacesFromVertexes(const _VertexPositions: TAVector3i; const _VertexList: AInt32; var _EdgeMap: T3DMap);
var
   NumVerts: integer;
   DistanceMatrix: array of array of integer;
   QueueDist: array[0..3] of C2DPointQueue;
   i, j, k : integer;
begin
   // Prepare variables
   QueueDist[0] := C2DPointQueue.Create;
   QueueDist[1] := C2DPointQueue.Create;
   QueueDist[2] := C2DPointQueue.Create;
   QueueDist[3] := C2DPointQueue.Create;

   // get number of vertexes that we'll work with.
   NumVerts := High(_VertexList)+1;
   // Check if we have a single face
   if numVerts = 3 then
   begin
      // if we have a single face, the situation is ridiculous.
      SetLength(Faces,High(Faces)+4);
      SetLength(FaceLocation,High(FaceLocation)+2);
      Faces[High(Faces)-2] := _VertexList[0];
      Faces[High(Faces)-1] := _VertexList[1];
      Faces[High(Faces)] := _VertexList[2];
   end
   else
   begin
      // We have more than 3 vertexes, so, we'll have to figure this face out with
      // a complex operation.

      // Prepare distance list.
      SetLength(DistanceMatrix,NumVerts,NumVerts);
      // Build the distance matrix.
      i := 0;
      while i < NumVerts do
      begin
         DistanceMatrix[i,i] := 0;
         j := i+1;
         while j < NumVerts do
         begin
            // get a fake distance, since it doesn't have the square root, which is unnecessary in this case.
            DistanceMatrix[i,j] := ((_VertexPositions[i].X - _VertexPositions[j].X) * (_VertexPositions[i].X - _VertexPositions[j].X)) + ((_VertexPositions[i].Y - _VertexPositions[j].Y) * (_VertexPositions[i].Y - _VertexPositions[j].Y)) + ((_VertexPositions[i].Z - _VertexPositions[j].Z) * (_VertexPositions[i].Z - _VertexPositions[j].Z));
            // Add the edge to the list related to its distance.
            case (DistanceMatrix[i,j]) of
               C_VP_DIST1: QueueDist[0].Add(i,j);
               C_VP_DIST2: QueueDist[1].Add(i,j);
               C_VP_DIST3: QueueDist[2].Add(i,j);
               C_VP_DIST4: QueueDist[3].Add(i,j);
               else
               begin
                  DistanceMatrix[i,j] := 0;
               end;
            end;
            DistanceMatrix[j,i] := DistanceMatrix[i,j];
            inc(j);
         end;
         inc(i);
      end;
      // So, there we go, with all distances and ordered edges in 4 lists.
      // Let's check the edges that intercept other edges and cut them.
      for i := 0 to 3 do
      begin
         if not QueueDist[i].IsEmpty then
         begin
            QueueDist[i].GoToFirstElement;
            while QueueDist[i].GetPosition(j,k) do
            begin
               if not _EdgeMap.TryPaintingEdge(_VertexPositions[j],_VertexPositions[k],1) then
               begin
                  DistanceMatrix[j,k] := 0;
                  DistanceMatrix[k,j] := 0;
               end;
               QueueDist[i].GoToNextElement;
            end;
         end;
      end;
      // So, we have all edges. Let's build faces out of it and write them.
      for i := Low(DistanceMatrix) to High(DistanceMatrix) do
      begin
         for j := Low(DistanceMatrix) to High(DistanceMatrix) do
         begin
            if DistanceMatrix[i,j] <> 0 then
            begin
               k := 0;
               while k < NumVerts do
               begin
                  if (DistanceMatrix[i,k] <> 0) and (DistanceMatrix[j,k] <> 0) then
                  begin
                     // Add i, j, k to faces.
                     SetLength(Faces,High(Faces)+4);
                     SetLength(FaceLocation,High(FaceLocation)+2);
                     Faces[High(Faces)] := k;
                     Faces[High(Faces)-1] := j;
                     Faces[High(Faces)-2] := i;
                     // Ensure that they will not be detected anymore.
                     DistanceMatrix[i,j] := 0;
                     DistanceMatrix[j,k] := 0;
                     DistanceMatrix[k,i] := 0;
                     k := NumVerts;
                  end
                  else
                     inc(k);
               end;
            end;
         end;
      end;
   end;
   // Free memory
   QueueDist[0].Free;
   QueueDist[1].Free;
   QueueDist[2].Free;
   QueueDist[3].Free;
   i := High(DistanceMatrix);
   while i >= 0 do
   begin
      SetLength(DistanceMatrix[0],0);
      dec(i);
   end;
   SetLength(DistanceMatrix,0);
end;

// Build a set of faces using the given order.
procedure TVoxelModelizerItem.MakeFacesFromEdges(const _VertexPositions: TAVector3i; const _VertexList: AInt32; var _EdgeMap: T3DMap);
var
   NumFaces,Maxj: integer;
   i,j: integer;
begin
   NumFaces := (High(_VertexList)+1) div 2;
   i := High(Faces)+1;
   j := 0;
   SetLength(Faces,(High(Faces)+1) + (NumFaces*3));
   SetLength(FaceLocation,(High(FaceLocation)+1) + NumFaces);
   Maxj := High(_VertexPositions)-2;
   while j < Maxj do
   begin
      // Face 1: V1, V3, V2
      Faces[i] := _VertexList[j];
      Faces[i+1] := _VertexList[j+2];
      Faces[i+2] := _VertexList[j+1];

      // Face 2: V1, V4, V3
      Faces[i+3] := _VertexList[j];
      Faces[i+4] := _VertexList[j+3];
      Faces[i+5] := _VertexList[j+2];

      // Draw them in the edge map.
      _EdgeMap.PaintEdge(_VertexPositions[j],_VertexPositions[j+1],1);
      _EdgeMap.PaintEdge(_VertexPositions[j+1],_VertexPositions[j+2],1);
      _EdgeMap.PaintEdge(_VertexPositions[j+2],_VertexPositions[j+3],1);
      _EdgeMap.PaintEdge(_VertexPositions[j+3],_VertexPositions[j],1);
      _EdgeMap.PaintEdge(_VertexPositions[j],_VertexPositions[j+2],1);

      // Go to next two faces.
      inc(j,4);
      inc(i,6);
   end;
end;

// The lonely cube solution.
procedure TVoxelModelizerItem.MakeACube(const _MyPosition: TVector3i; var _VertexMap : T3DIntGrid; var _NumVertices: integer);
var
   Vertexes: array[0..7] of integer;
   VertexPositions: TAVector3i;
begin
   // Add all vertexes.
   Vertexes[0] := AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   Vertexes[1] := AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z,_NumVertices,VertexPositions);
   Vertexes[2] := AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z,_NumVertices,VertexPositions);
   Vertexes[3] := AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   Vertexes[4] := AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y,_MyPosition.Z,_NumVertices,VertexPositions);
   Vertexes[5] := AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   Vertexes[6] := AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   Vertexes[7] := AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y,_MyPosition.Z,_NumVertices,VertexPositions);
   // Add All Faces
   SetLength(Faces,36);
   SetLength(FaceLocation,12);
   // Front triangles
   // Face 1: top right, bottom left, bottom right.
   Faces[0] := Vertexes[0];
   Faces[1] := Vertexes[2];
   Faces[2] := Vertexes[1];
   // Face 2: top right, top left, bottom left.
   Faces[3] := Vertexes[0];
   Faces[4] := Vertexes[3];
   Faces[5] := Vertexes[2];
   // Left triangles
   // Face 1: top right, bottom left, bottom right.
   Faces[6] := Vertexes[3];
   Faces[7] := Vertexes[4];
   Faces[8] := Vertexes[2];
   // Face 2: top right, top left, bottom left.
   Faces[9] := Vertexes[3];
   Faces[10] := Vertexes[5];
   Faces[11] := Vertexes[4];
   // Back triangles
   // Face 1: top right, bottom left, bottom right.
   Faces[12] := Vertexes[5];
   Faces[13] := Vertexes[7];
   Faces[14] := Vertexes[4];
   // Face 2: top right, top left, bottom left.
   Faces[15] := Vertexes[5];
   Faces[16] := Vertexes[6];
   Faces[17] := Vertexes[7];
   // Right triangles
   // Face 1: top right, bottom left, bottom right.
   Faces[18] := Vertexes[6];
   Faces[19] := Vertexes[1];
   Faces[20] := Vertexes[7];
   // Face 2: top right, top left, bottom left.
   Faces[21] := Vertexes[6];
   Faces[22] := Vertexes[0];
   Faces[23] := Vertexes[1];
   // Top triangles
   // Face 1: top right, bottom left, bottom right.
   Faces[24] := Vertexes[7];
   Faces[25] := Vertexes[3];
   Faces[26] := Vertexes[6];
   // Face 2: top right, top left, bottom left.
   Faces[27] := Vertexes[7];
   Faces[28] := Vertexes[3];
   Faces[29] := Vertexes[5];
   // Bottom triangles
   // Face 1: top right, bottom left, bottom right.
   Faces[30] := Vertexes[1];
   Faces[31] := Vertexes[4];
   Faces[32] := Vertexes[7];
   // Face 2: top right, top left, bottom left.
   Faces[33] := Vertexes[1];
   Faces[34] := Vertexes[2];
   Faces[35] := Vertexes[4];
   // Free memory
   SetLength(VertexPositions,0);
end;

procedure TVoxelModelizerItem.SetColour(const _VoxelMap, _ColourMap: TVoxelMap; const _Palette: TPalette; _MyClassification: single);
var
   c : integer;
begin
   if _MyClassification = C_SURFACE then
   begin
      Colour := _Palette.ColourGL4[Round(_ColourMap[x,y,z])];
   end
   else
   begin
      c := 0;
      Colour.X := 0;
      Colour.Y := 0;
      Colour.Z := 0;
      Colour.W := 0;
      if _VoxelMap.MapSafe[x+1,y,z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[x+1,y,z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[x+1,y,z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[x+1,y,z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[x+1,y,z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[x-1,y,z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[x-1,y,z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[x-1,y,z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[x-1,y,z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[x-1,y,z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[x,y+1,z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[x,y+1,z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[x,y+1,z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[x,y+1,z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[x,y+1,z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[x,y-1,z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[x,y-1,z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[x,y-1,z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[x,y-1,z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[x,y-1,z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[x,y,z+1] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z+1])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z+1])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z+1])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z+1])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[x,y,z-1] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z-1])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z-1])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z-1])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[x,y,z-1])].W;
         inc(c);
      end;
      if c > 0 then
      begin
         Colour.X := Colour.X / c;
         Colour.Y := Colour.Y / c;
         Colour.Z := Colour.Z / c;
         Colour.W := Colour.W / c;
      end;
   end;
end;

end.
