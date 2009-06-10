unit VoxelModelizerItem;

interface

uses BasicFunctions, BasicDataTypes, VoxelMap, Normals, Class2DPointQueue,
   BasicConstants, ThreeDMap, Voxel_Engine, Palette, Dialogs, SysUtils,
   ClassFaceQueue, ClassVertexQueue;

type
   TFilledVerts = array[0..7] of boolean;
   TFilledEdges = array[0..11] of boolean;
   TFilledFaces = array[0..5] of boolean;
   TFaceSettings = array [0..5] of integer;

   TVoxelModelizerItem = class
      private
         // Colouring procedure
         procedure SetColour(const _VoxelMap, _ColourMap: TVoxelMap; const _Palette: TPalette; _MyClassification: single; _x,_y,_z: integer);
         // Classification procedures
         procedure BuildFilledVerts(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; var _FilledVerts: TFilledVerts; _MyClassification: single; _x,_y,_z,_MySurface: integer);
         procedure BuildFilledEdges(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; var _FilledEdges: TFilledEdges; _MyClassification: single; _x,_y,_z,_MySurface: integer);
         procedure BuildFilledFaces(const _VoxelMap: TVoxelMap; const Cube : TNormals; var _FilledFaces: TFilledFaces; _MyClassification: single; _x,_y,_z: integer);
         // Vertex construction procedures
         function FaceHasVertexes(const _FilledVerts: TFilledVerts; _face: integer): boolean;
         function FaceHasEdges(const _FilledEdges: TFilledEdges; _face: integer): boolean;
         // Face construction procedures
         procedure MakeFacesFromVertexes(const _VertexList: CVertexQueue; var _EdgeMap: T3DMap);
         procedure MakeFacesFromEdges(const _VertexList: CVertexQueue; var _EdgeMap: T3DMap);
         procedure MakeACube(const _MyPosition: TVector3i; var _VertexMap : T3DIntGrid; var _NumVertices: integer);
         // Adds
         procedure AddVertex( var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer; var _VertexList: CVertexQueue);
      public
         // Colour
         Colour: TVector4f;
         // Faces
         Faces: CFaceQueue;

         // Constructors and Destructors
         constructor Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; var _EdgeMap: T3DMap; _x, _y, _z : integer; var _TotalNumVertexes: integer; const _Palette: TPalette; const _ColourMap: TVoxelMap);
         destructor Destroy; override;
   end;
   PVoxelModelizerItem = ^TVoxelModelizerItem;

implementation

constructor TVoxelModelizerItem.Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; var _EdgeMap: T3DMap; _x, _y, _z : integer; var _TotalNumVertexes: integer; const _Palette: TPalette; const _ColourMap: TVoxelMap);
var
   v1,v2,e1,e2,p,i : integer;
   Cube : TNormals;
   v0x,v0y,v0z: integer;
   // Vertex generation caching.
   VisitedEdgesVertex: array[0..11] of boolean;
   // Edge generation caching
   VisitedEdges: array[0..11] of boolean;
   // Face generation caching
   ExternalFaceEdges: array[0..11] of boolean;
   MarkedFaceVertexes: array[0..7] of boolean;
   InternalFaceEdges: array[0..11] of boolean;
   // Situation
   MyClassification: single;
   MySurface: integer;
   // Region as a cube
   FilledVerts: TFilledVerts;
   FilledEdges: TFilledEdges;
   FilledFaces: TFilledFaces;
   // Situation per face.
   FaceSettings: TFaceSettings;
   // Vertex positions and lists.
   VertexGeneratedList : CVertexQueue;
   EdgeGeneratedList : CVertexQueue;
   FaceGeneratedList : CVertexQueue;
begin
   // Reset basic variables.
   Cube := TNormals.Create(6);
   Faces := CFaceQueue.Create;
   VertexGeneratedList := CVertexQueue.Create;
   EdgeGeneratedList := CVertexQueue.Create;
   FaceGeneratedList := CVertexQueue.Create;
   // Semi surface or surface?
   MyClassification := _VoxelMap.MapSafe[_x,_y,_z];
   // Which kind of semi-surface?
   MySurface := _SurfaceMap[_x,_y,_z];
   // initial position in the vertex map;
   v0x := _x * C_VP_HIGH;
   v0y := _y * C_VP_HIGH;
   v0z := _z * C_VP_HIGH;
   // Set the Colour from all faces that we'll generate here
   SetColour(_VoxelMap,_ColourMap,_Palette,MyClassification,_x,_y,_z);

   // Check which vertices, edges and faces are in and out of the surface.
   BuildFilledVerts(_VoxelMap,_SurfaceMap,Cube,FilledVerts,MyClassification,_x,_y,_z,MySurface);
   BuildFilledEdges(_VoxelMap,_SurfaceMap,Cube,FilledEdges,MyClassification,_x,_y,_z,MySurface);
   BuildFilledFaces(_VoxelMap,Cube,FilledFaces,MyClassification,_x,_y,_z);

   // Let's analyse the situation for each edge and add the vertices.
   // First, split the cube into 6 faces. Each face has 4 edges.
   // FaceVerts has (topright, bottomright, bottomleft, topleft) for each face
   // FaceEdges has (right, bottom, left, top) for each face.

   // Prepare our variables for the construction of vertexes.
   for i := 0 to 7 do
      MarkedFaceVertexes[i] := false;
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
      if FaceHasVertexes(FilledVerts,i) then
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
                  AddVertex(_VertexMap,v0x + VertexPoints[i,p,1,0], v0y + VertexPoints[i,p,1,1], v0z + VertexPoints[i,p,1,2],_TotalNumVertexes,VertexGeneratedList);
               end;
            end;
         end;
      end
      else
      begin
         // check if this face will constructed based on edges
         if FaceHasEdges(FilledEdges,i) then
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
                  while e1 < e2 do
                  begin
                     // Check if the neighboor edge is filled.
                     if FilledEdges[EdgeNeighboorList[e1]] then
                     begin
                        // calculate the vertex between FaceEdges[v1] and FilledEdges[EdgeNeighboorList[e1]]
                        // to prevent shapes from getting mixed up.
                        AddVertex(_VertexMap,v0x + ((EdgeCentralPoints[EdgeNeighboorList[e1],0] + EdgeCentralPoints[FaceEdges[v1],0]) div 2), v0y + ((EdgeCentralPoints[EdgeNeighboorList[e1],1] + EdgeCentralPoints[FaceEdges[v1],1]) div 2), v0z + ((EdgeCentralPoints[EdgeNeighboorList[e1],2] + EdgeCentralPoints[FaceEdges[v1],2]) div 2),_TotalNumVertexes,EdgeGeneratedList);
                     end
                     else
                     begin
                        // Add a vertex in the middle of the edge.
                        AddVertex(_VertexMap,v0x + EdgeCentralPoints[EdgeNeighboorList[e1],0], v0y + EdgeCentralPoints[EdgeNeighboorList[e1],1], v0z + EdgeCentralPoints[EdgeNeighboorList[e1],2],_TotalNumVertexes,EdgeGeneratedList);
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
               for p := 0 to 3 do // for each edge from the face i
               begin
                  e1 := p  + (i * 4); // edge index on FaceEdge
                  // fill the beggining of each edge with a vertex
                  if not ExternalFaceEdges[FaceEdges[e1]] then
                  begin
                     if not MarkedFaceVertexes[FaceVerts[e1]] then
                     begin
                        AddVertex(_VertexMap,v0x + VertexPoints[i,p,0,0], v0y + VertexPoints[i,p,0,1], v0z + VertexPoints[i,p,0,2],_TotalNumVertexes,FaceGeneratedList);
                        ExternalFaceEdges[FaceEdges[e1]] := true;
                        MarkedFaceVertexes[FaceVerts[e1]] := true;
                     end;
                  end;
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
                  AddVertex(_VertexMap,v0x + EdgeCentralPoints[EdgeNeighboorList[e1],0], v0y + EdgeCentralPoints[EdgeNeighboorList[e1],1], v0z + EdgeCentralPoints[EdgeNeighboorList[e1],2],_TotalNumVertexes,FaceGeneratedList);
               end;
               inc(e1);
            end;
         end;
      end;
   end;
   // Here we start all procedures to build the faces.
   // First we build the faces generated from vertexes.
   if VertexGeneratedList.GetNumItems > 0 then
      MakeFacesFromVertexes(VertexGeneratedList,_EdgeMap);

   // Then we build the faces generated from edges.
   if EdgeGeneratedList.GetNumItems > 0 then
      MakeFacesFromEdges(EdgeGeneratedList,_EdgeMap);

   // Finally we build the faces generated from faces.
   if FaceGeneratedList.GetNumItems > 0 then
      MakeFacesFromVertexes(FaceGeneratedList,_EdgeMap);

   // If vertexes, edges and faces = 0. Do the lonely cube.
   if Faces.IsEmpty then
      MakeACube(SetVectori(v0x,v0y,v0z),_VertexMap,_TotalNumVertexes);

   VertexGeneratedList.Free;
   EdgeGeneratedList.Free;
   FaceGeneratedList.Free;
   Cube.Free;
end;

destructor TVoxelModelizerItem.Destroy;
begin
   Faces.Free;
   inherited Destroy;
end;

// Check which vertexes are inside or outside the surface.
procedure TVoxelModelizerItem.BuildFilledVerts(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; var _FilledVerts: TFilledVerts; _MyClassification: single; _x,_y,_z,_MySurface: integer);
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
      i := v * 7;
      // check if the vertex is in a location where the surface can pass.
      if (_MyClassification = C_SURFACE) or ((_MySurface and VertexRequirements[v]) <> 0) then
      begin
         _FilledVerts[v] := true;
         imax := i + 7;
      end
      else
      begin
         _FilledVerts[v] := false;
         imax := i - 1;
      end;
      // check if this same vertex exists at every one of the 7 neightboors.
      while i < imax do
      begin
         CheckPoint := Cube[VertexCheck[i]];
         Point.X := _x + Round(CheckPoint.X);
         Point.Y := _y + Round(CheckPoint.Y);
         Point.Z := _z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         _FilledVerts[v] := _FilledVerts[v] and (VoxelClassification >= C_SURFACE);
         // if the neighboor is not a surface, check for semi-surface.
         if not _FilledVerts[v] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSVertexesCheck[i] <> 0  then
               begin // if the semi-surface exists, then it is still in.
                  _FilledVerts[v] := true;
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
procedure TVoxelModelizerItem.BuildFilledEdges(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; var _FilledEdges: TFilledEdges; _MyClassification: single; _x,_y,_z,_MySurface: integer);
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
      if (_MyClassification = C_SURFACE) or ((_MySurface and EdgeRequirements[e]) <> 0) then
      begin
         _FilledEdges[e] := true;
         imax := i + 3;
      end
      else
      begin
         _FilledEdges[e] := false;
         imax := i - 1;
      end;
      // check if this same edge exists at every one of the 3 neightboors.
      while i < imax do
      begin
         CheckPoint := Cube[EdgeCheck[i]];
         Point.X := _x + Round(CheckPoint.X);
         Point.Y := _y + Round(CheckPoint.Y);
         Point.Z := _z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         _FilledEdges[e] := _FilledEdges[e] and (VoxelClassification >= C_SURFACE);
         // if the neighboor is not a surface, check for semi-surface.
         if not _FilledEdges[e] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSEdgesCheck[i] <> 0  then
               begin
                  _FilledEdges[e] := true;
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
procedure TVoxelModelizerItem.BuildFilledFaces(const _VoxelMap: TVoxelMap; const Cube : TNormals; var _FilledFaces: TFilledFaces; _MyClassification: single; _x,_y,_z: integer);
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
         Point.X := _x + Round(CheckPoint.X);
         Point.Y := _y + Round(CheckPoint.Y);
         Point.Z := _z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         _FilledFaces[f] := VoxelClassification >= C_SURFACE;
      end;
   end
   else
   begin
      // all six faces are outside.
      for f := 0 to 5 do
         _FilledFaces[f] := false;
   end;
end;

function TVoxelModelizerItem.FaceHasVertexes(const _FilledVerts: TFilledVerts; _face: integer): boolean;
var
   v,vmax : integer;
begin
   // check if this face will constructed based on vertexes (traditional marching cubes)
   v := _face * 4;
   vmax := v + 4;
   Result := false;
   while v < vmax do
   begin
      Result := Result or _FilledVerts[FaceVerts[v]];
      inc(v);
   end;
end;

function TVoxelModelizerItem.FaceHasEdges(const _FilledEdges: TFilledEdges; _face: integer): boolean;
var
   e,emax: integer;
begin
   // check if this face will constructed based on edges
   e := _face * 4;
   emax := e + 4;
   Result := false;
   while e < emax do
   begin
      Result := Result or _FilledEdges[FaceEdges[e]];
      inc(e);
   end;
end;

procedure TVoxelModelizerItem.AddVertex(var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer; var _VertexList: CVertexQueue);
begin
   if _VertexMap[_x,_y,_z] = -1 then
   begin
      _VertexMap[_x,_y,_z] := _NumVertices;
      _VertexList.Add(_x,_y,_z,_NumVertices);
      inc(_NumVertices);
   end
   else
   begin
      _VertexList.Add(_x,_y,_z,_VertexMap[_x,_y,_z]);
   end;
end;

// - 1) Build a distance table between the vertexes (not using square root).
// - 2) Order edges by distances (32, 64, 96 and 128)
// - 3) Draw each edge in the edge in the hashing and check for interceptions.
// - 4) Combine linked vertexes from the surviving edges to build the faces.
procedure TVoxelModelizerItem.MakeFacesFromVertexes(const _VertexList: CVertexQueue; var _EdgeMap: T3DMap);
const
   MAX_DIST = 7;
var
   NumVerts: integer;
   DistanceMatrix: array of array of integer;
   QueueDist: array[0..MAX_DIST] of C2DPointQueue;
   i, j, k : integer;
   VertexList: array of PVertexData;
   MyVertex: PVertexData;
begin
   // Prepare variables
   for i := 0 to MAX_DIST do
   begin
      QueueDist[i] := C2DPointQueue.Create;
   end;

   // get number of vertexes that we'll work with.
   NumVerts := _VertexList.GetNumItems;
   SetLength(VertexList,NumVerts);
   MyVertex := _VertexList.GetFirstElement;
   for i := Low(VertexList) to High(VertexList) do
   begin
      VertexList[i] := MyVertex;
      MyVertex := MyVertex^.Next;
   end;
   // Check if we have a single face
   if numVerts = 3 then
   begin
      // if we have a single face, the situation is ridiculous.
      Faces.Add(VertexList[0]^.Position,VertexList[1]^.Position,VertexList[2]^.Position);
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
            DistanceMatrix[i,j] := ((VertexList[i]^.X - VertexList[j]^.X) * (VertexList[i]^.X - VertexList[j]^.X)) + ((VertexList[i]^.Y - VertexList[j]^.Y) * (VertexList[i]^.Y - VertexList[j]^.Y)) + ((VertexList[i]^.Z - VertexList[j]^.Z) * (VertexList[i]^.Z - VertexList[j]^.Z));
            // Add the edge to the list related to its distance.
            case (DistanceMatrix[i,j]) of
               C_VP_DIST0: QueueDist[0].Add(i,j);
               C_VP_DIST1: QueueDist[1].Add(i,j);
               C_VP_DIST2: QueueDist[2].Add(i,j);
               C_VP_DIST3: QueueDist[3].Add(i,j);
               C_VP_DIST4: QueueDist[4].Add(i,j);
               C_VP_DIST5: QueueDist[5].Add(i,j);
               C_VP_DIST6: QueueDist[6].Add(i,j);
               C_VP_DIST7: QueueDist[7].Add(i,j);
               0: DistanceMatrix[i,j] := 0;
               else
               begin
                  ShowMessage(IntToStr(DistanceMatrix[i,j]));
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
      for i := 0 to MAX_DIST do
      begin
         if not QueueDist[i].IsEmpty then
         begin
            QueueDist[i].GoToFirstElement;
            while QueueDist[i].GetPosition(j,k) do
            begin
               if not _EdgeMap.TryPaintingEdge(_VertexList.GetVector3i(VertexList[j]),_VertexList.GetVector3i(VertexList[k]),1) then
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
                  if (DistanceMatrix[k,i] <> 0) and (DistanceMatrix[j,k] <> 0) then
                  begin
                     // Add i, j, k to faces.
                     Faces.Add(VertexList[i]^.Position,VertexList[j]^.Position,VertexList[k]^.Position);
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
   for i := 0 to MAX_DIST do
   begin
      QueueDist[i].Free;
   end;
   i := High(DistanceMatrix);
   while i >= 0 do
   begin
      SetLength(DistanceMatrix[0],0);
      dec(i);
   end;
   SetLength(DistanceMatrix,0);
   SetLength(VertexList,0);
end;

// Build a set of faces using the given order.
procedure TVoxelModelizerItem.MakeFacesFromEdges(const _VertexList: CVertexQueue; var _EdgeMap: T3DMap);
var
   Maxj: integer;
   j: integer;
   VertexList: array of PVertexData;
   MyVertex: PVertexData;
begin
   SetLength(VertexList,_VertexList.GetNumItems);
   MyVertex := _VertexList.GetFirstElement;
   for j := Low(VertexList) to High(VertexList) do
   begin
      VertexList[j] := MyVertex;
      MyVertex := MyVertex^.Next;
   end;
   j := 0;
   Maxj := _VertexList.GetNumItems-3;
   while j < Maxj do
   begin
      // Face 1: V1, V3, V2
      Faces.Add(VertexList[j]^.Position,VertexList[j+2]^.Position,VertexList[j+1]^.Position);
      // Face 2: V1, V4, V3
      Faces.Add(VertexList[j]^.Position,VertexList[j+3]^.Position,VertexList[j+2]^.Position);

      // Draw them in the edge map.
      _EdgeMap.PaintEdge(_VertexList.GetVector3i(VertexList[j]),_VertexList.GetVector3i(VertexList[j+1]),1);
      _EdgeMap.PaintEdge(_VertexList.GetVector3i(VertexList[j+1]),_VertexList.GetVector3i(VertexList[j+2]),1);
      _EdgeMap.PaintEdge(_VertexList.GetVector3i(VertexList[j+2]),_VertexList.GetVector3i(VertexList[j+3]),1);
      _EdgeMap.PaintEdge(_VertexList.GetVector3i(VertexList[j+3]),_VertexList.GetVector3i(VertexList[j]),1);
      _EdgeMap.PaintEdge(_VertexList.GetVector3i(VertexList[j]),_VertexList.GetVector3i(VertexList[j+2]),1);

      // Go to next two faces.
      inc(j,4);
   end;
end;

// The lonely cube solution.
procedure TVoxelModelizerItem.MakeACube(const _MyPosition: TVector3i; var _VertexMap : T3DIntGrid; var _NumVertices: integer);
var
   Vertexes: array[0..7] of integer;
   VertexPositions: CVertexQueue;
   i : integer;
   MyVertex: PVertexData;
begin
   // Add all vertexes.
   VertexPositions := CVertexQueue.Create;
   AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y + C_VP_HIGH,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y,_MyPosition.Z,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X,_MyPosition.Y,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y,_MyPosition.Z + C_VP_HIGH,_NumVertices,VertexPositions);
   AddVertex(_VertexMap,_MyPosition.X + C_VP_HIGH,_MyPosition.Y,_MyPosition.Z,_NumVertices,VertexPositions);
   MyVertex := VertexPositions.GetFirstElement;
   for i := 0 to 7 do
   begin
      Vertexes[i] := MyVertex^.Position;
      MyVertex := MyVertex^.Next;
   end;

   // Add All Faces

   // Front triangles
   // Face 1: top right, bottom left, bottom right.
   Faces.Add(Vertexes[0],Vertexes[2],Vertexes[1]);
   // Face 2: top right, top left, bottom left.
   Faces.Add(Vertexes[0],Vertexes[3],Vertexes[2]);
   // Left triangles
   // Face 1: top right, bottom left, bottom right.
   Faces.Add(Vertexes[3],Vertexes[4],Vertexes[2]);
   // Face 2: top right, top left, bottom left.
   Faces.Add(Vertexes[3],Vertexes[5],Vertexes[4]);
   // Back triangles
   // Face 1: top right, bottom left, bottom right.
   Faces.Add(Vertexes[5],Vertexes[7],Vertexes[4]);
   // Face 2: top right, top left, bottom left.
   Faces.Add(Vertexes[5],Vertexes[6],Vertexes[7]);
   // Right triangles
   // Face 1: top right, bottom left, bottom right.
   Faces.Add(Vertexes[6],Vertexes[1],Vertexes[7]);
   // Face 2: top right, top left, bottom left.
   Faces.Add(Vertexes[6],Vertexes[0],Vertexes[1]);
   // Top triangles
   // Face 1: top right, bottom left, bottom right.
   Faces.Add(Vertexes[7],Vertexes[3],Vertexes[6]);
   // Face 2: top right, top left, bottom left.
   Faces.Add(Vertexes[7],Vertexes[3],Vertexes[5]);
   // Bottom triangles
   // Face 1: top right, bottom left, bottom right.
   Faces.Add(Vertexes[1],Vertexes[4],Vertexes[7]);
   // Face 2: top right, top left, bottom left.
   Faces.Add(Vertexes[1],Vertexes[2],Vertexes[4]);
   // Free memory
   VertexPositions.Free;
end;

procedure TVoxelModelizerItem.SetColour(const _VoxelMap, _ColourMap: TVoxelMap; const _Palette: TPalette; _MyClassification: single; _x,_y,_z: integer);
var
   c : integer;
begin
   if _MyClassification = C_SURFACE then
   begin
      Colour := _Palette.ColourGL4[Round(_ColourMap[_x,_y,_z])];
   end
   else
   begin
      c := 0;
      Colour.X := 0;
      Colour.Y := 0;
      Colour.Z := 0;
      Colour.W := 0;
      if _VoxelMap.MapSafe[_x+1,_y,_z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[_x+1,_y,_z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[_x+1,_y,_z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[_x+1,_y,_z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[_x+1,_y,_z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[_x-1,_y,_z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[_x-1,_y,_z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[_x-1,_y,_z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[_x-1,_y,_z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[_x-1,_y,_z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[_x,_y+1,_z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y+1,_z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y+1,_z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y+1,_z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y+1,_z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[_x,_y-1,_z] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y-1,_z])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y-1,_z])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y-1,_z])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y-1,_z])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[_x,_y,_z+1] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z+1])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z+1])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z+1])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z+1])].W;
         inc(c);
      end;
      if _VoxelMap.MapSafe[_x,_y,_z-1] = C_SURFACE then
      begin
         Colour.X := Colour.X + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z-1])].X;
         Colour.Y := Colour.Y + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z-1])].Y;
         Colour.Z := Colour.Z + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z-1])].Z;
         Colour.W := Colour.W + _Palette.ColourGL4[Round(_ColourMap.Map[_x,_y,_z-1])].W;
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
