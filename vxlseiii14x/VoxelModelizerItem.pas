unit VoxelModelizerItem;

interface

uses BasicFunctions, BasicDataTypes, VoxelMap, Normals;

const
   // Vertices
   C_VERT_TOP_LEFT_BACK = 0;
   C_VERT_TOP_RIGHT_BACK = 1;
   C_VERT_TOP_LEFT_FRONT = 2;
   C_VERT_TOP_RIGHT_FRONT = 3;
   C_VERT_BOTTOM_LEFT_BACK = 4;
   C_VERT_BOTTOM_RIGHT_BACK = 5;
   C_VERT_BOTTOM_LEFT_FRONT = 6;
   C_VERT_BOTTOM_RIGHT_FRONT = 7;
   // Edges
   C_EDGE_TOP_LEFT = 0;
   C_EDGE_TOP_RIGHT = 1;
   C_EDGE_TOP_BACK = 2;
   C_EDGE_TOP_FRONT = 3;
   C_EDGE_BOTTOM_LEFT = 4;
   C_EDGE_BOTTOM_RIGHT = 5;
   C_EDGE_BOTTOM_BACK = 6;
   C_EDGE_BOTTOM_FRONT = 7;
   C_EDGE_FRONT_LEFT = 8;
   C_EDGE_FRONT_RIGHT = 9;
   C_EDGE_BACK_LEFT = 10;
   C_EDGE_BACK_RIGHT = 11;
   // Faces
   C_FACE_LEFT = 0;
   C_FACE_RIGHT = 1;
   C_FACE_BACK = 2;
   C_FACE_FRONT = 3;
   C_FACE_BOTTOM = 4;
   C_FACE_TOP = 5;

   // Face Settings
   C_FACE_SET_VERT = 0;
   C_FACE_SET_EDGE = 1;
   C_FACE_SET_FACE = 2;

   // Vertex Positions
   C_VP_HIGH = 8;
   C_VP_MID = C_VP_HIGH div 2;

   VertexRequirements: array[0..7] of integer = (C_SF_TOP_BACK_LEFT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT);

   VertexCheck: array[0..55] of byte = (0, 1, 4, 8, 9, 10, 11, 17, 18, 21, 25, 9, 10,
   11, 0, 1, 3, 6, 13, 12, 11, 17, 18, 20, 23, 13, 12, 11, 0, 2, 4, 7, 9, 16, 15,
   17, 19, 21, 24, 9, 16, 15, 0, 2, 3, 5, 13, 14, 15, 17, 19, 20, 22, 13, 14, 15);

   SSVertexesCheck: array[0..55] of byte = (C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_LEFT_POINT,
   C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
   C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
   C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
   C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_TOP_BACK_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_TOP_BACK_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT);

   EdgeRequirements: array[0..11] of integer = (C_SF_TOP_LEFT_LINE, C_SF_TOP_RIGHT_LINE,
   C_SF_TOP_BACK_LINE, C_SF_TOP_FRONT_LINE, C_SF_BOTTOM_LEFT_LINE, C_SF_BOTTOM_RIGHT_LINE,
   C_SF_BOTTOM_BACK_LINE, C_SF_BOTTOM_FRONT_LINE, C_SF_LEFT_FRONT_LINE, C_SF_RIGHT_FRONT_LINE,
   C_SF_LEFT_BACK_LINE, C_SF_RIGHT_FRONT_LINE);

   EdgeCheck: array[0..35] of byte = (0, 1, 11, 17, 18, 11, 9, 10, 11, 13, 12, 11,
   0, 2, 15, 17, 19, 15, 9, 16, 15, 13, 14, 15, 0, 3, 13, 17, 20, 13, 0, 4, 9, 17,
   21, 9);

   SSEdgesCheck: array[0..35] of integer = (C_SF_TOP_RIGHT_LINE, C_SF_BOTTOM_RIGHT_LINE,
   C_SF_BOTTOM_LEFT_LINE, C_SF_TOP_LEFT_LINE, C_SF_BOTTOM_LEFT_LINE,
   C_SF_BOTTOM_RIGHT_LINE, C_SF_TOP_FRONT_LINE, C_SF_BOTTOM_FRONT_LINE,
   C_SF_BOTTOM_BACK_LINE, C_SF_TOP_BACK_LINE, C_SF_BOTTOM_BACK_LINE,
   C_SF_BOTTOM_FRONT_LINE, C_SF_BOTTOM_RIGHT_LINE, C_SF_TOP_RIGHT_LINE,
   C_SF_BOTTOM_LEFT_LINE, C_SF_BOTTOM_LEFT_LINE, C_SF_TOP_LEFT_LINE,
   C_SF_BOTTOM_RIGHT_LINE, C_SF_BOTTOM_FRONT_LINE, C_SF_TOP_FRONT_LINE,
   C_SF_TOP_BACK_LINE, C_SF_BOTTOM_BACK_LINE, C_SF_TOP_BACK_LINE,
   C_SF_TOP_FRONT_LINE, C_SF_RIGHT_FRONT_LINE, C_SF_RIGHT_BACK_LINE,
   C_SF_LEFT_BACK_LINE, C_SF_LEFT_FRONT_LINE, C_SF_LEFT_BACK_LINE,
   C_SF_RIGHT_BACK_LINE, C_SF_RIGHT_BACK_LINE, C_SF_RIGHT_FRONT_LINE,
   C_SF_LEFT_FRONT_LINE, C_SF_LEFT_BACK_LINE, C_SF_LEFT_FRONT_LINE,
   C_SF_RIGHT_FRONT_LINE);

   FaceCheck: array[0..5] of byte = (0, 17, 9, 13, 15, 11);

   FaceVerts: array [0..23] of byte = (2,6,4,0,1,5,7,3,0,4,5,1,3,7,6,2,7,5,4,6,1,3,2,0);
   FaceEdges: array[0..23] of byte = (8,4,10,0,11,5,9,1,10,6,11,2,9,7,8,3,5,6,4,7,1,3,0,2);

   VertexPoints: array[0..5,0..3,0..1,0..2] of byte = ((((0,C_VP_HIGH,C_VP_HIGH),
   (0,C_VP_HIGH,C_VP_MID)),	((0,C_VP_HIGH,0), (0,C_VP_MID,0)),((0,0,0),
   (0,0,C_VP_MID)),((0,0,C_VP_HIGH), (0,C_VP_MID,C_VP_HIGH))),(((C_VP_HIGH,0,C_VP_HIGH),
   (C_VP_HIGH,0,C_VP_MID)), ((C_VP_HIGH,0,0), (C_VP_HIGH,C_VP_MID,0)),
   ((C_VP_HIGH,C_VP_HIGH,0), (C_VP_HIGH,C_VP_HIGH,C_VP_MID)),
   ((C_VP_HIGH,C_VP_HIGH,C_VP_HIGH), (C_VP_HIGH,C_VP_MID,C_VP_HIGH))),(((0,0,C_VP_HIGH),
   (0,0,C_VP_MID)), ((0,0,0), (C_VP_MID,0,0)),((C_VP_HIGH,0,0), (C_VP_HIGH,0,C_VP_MID)),
   ((C_VP_HIGH,0,C_VP_HIGH), (C_VP_MID,0,C_VP_HIGH))),(((C_VP_HIGH,C_VP_HIGH,C_VP_HIGH),
   (C_VP_HIGH,C_VP_HIGH,C_VP_MID)),	((C_VP_HIGH,C_VP_HIGH,0), (C_VP_MID,C_VP_HIGH,0)),
   ((0,C_VP_HIGH,0), (0,C_VP_HIGH,C_VP_MID)),((0,C_VP_HIGH,C_VP_HIGH),
   (C_VP_MID,C_VP_HIGH,C_VP_HIGH))),(((C_VP_HIGH,C_VP_HIGH,0), (C_VP_HIGH,C_VP_MID,0)),
	((C_VP_HIGH,0,0), (C_VP_MID,0,0)),((0,0,0), (0,C_VP_MID,0)),((0,C_VP_HIGH,0),
   (C_VP_MID,C_VP_HIGH,0))),(((C_VP_HIGH,0,C_VP_HIGH), (C_VP_HIGH,C_VP_MID,C_VP_HIGH)),
	((C_VP_HIGH,C_VP_HIGH,C_VP_HIGH), (C_VP_MID,C_VP_HIGH,C_VP_HIGH)),
   ((0,C_VP_HIGH,C_VP_HIGH), (0,C_VP_MID,C_VP_HIGH)),((0,0,C_VP_HIGH), (C_VP_MID,0,C_VP_HIGH))));

   EdgeCentralPoints: array[0..11,0..2] of byte = 	((0,C_VP_MID,C_VP_HIGH),
   (C_VP_HIGH,C_VP_MID,C_VP_HIGH), (C_VP_MID,0,C_VP_HIGH), (C_VP_MID,C_VP_HIGH,C_VP_HIGH),
   (0,C_VP_MID,0), (C_VP_HIGH,C_VP_MID,0), (C_VP_MID,0,0), (C_VP_MID,C_VP_HIGH,0),
   (0,C_VP_HIGH,C_VP_MID), (C_VP_HIGH,C_VP_HIGH,C_VP_MID), (0,0,C_VP_MID), (C_VP_HIGH,0,C_VP_MID));

   EdgeNeighboorList: array[0..47] of byte = (C_EDGE_TOP_FRONT, C_EDGE_FRONT_LEFT, C_EDGE_BACK_LEFT,
   C_EDGE_TOP_BACK, C_EDGE_TOP_BACK, C_EDGE_BACK_RIGHT, C_EDGE_FRONT_RIGHT, C_EDGE_TOP_FRONT,
   C_EDGE_TOP_LEFT, C_EDGE_BACK_LEFT, C_EDGE_BACK_RIGHT, C_EDGE_TOP_RIGHT, C_EDGE_TOP_RIGHT,
   C_EDGE_FRONT_RIGHT, C_EDGE_FRONT_LEFT, C_EDGE_TOP_LEFT, C_EDGE_BOTTOM_FRONT, C_EDGE_FRONT_LEFT,
   C_EDGE_BACK_LEFT, C_EDGE_BOTTOM_BACK, C_EDGE_BOTTOM_BACK, C_EDGE_BACK_RIGHT, C_EDGE_FRONT_RIGHT,
   C_EDGE_BOTTOM_FRONT, C_EDGE_BOTTOM_LEFT, C_EDGE_BACK_LEFT, C_EDGE_BACK_RIGHT, C_EDGE_BOTTOM_RIGHT,
   C_EDGE_BOTTOM_RIGHT, C_EDGE_FRONT_RIGHT, C_EDGE_FRONT_LEFT, C_EDGE_BOTTOM_BACK, C_EDGE_TOP_FRONT,
   C_EDGE_BOTTOM_FRONT, C_EDGE_BOTTOM_LEFT, C_EDGE_TOP_LEFT, C_EDGE_TOP_RIGHT, C_EDGE_BOTTOM_RIGHT,
   C_EDGE_BOTTOM_FRONT, C_EDGE_TOP_FRONT, C_EDGE_TOP_LEFT, C_EDGE_BOTTOM_LEFT, C_EDGE_BOTTOM_BACK,
   C_EDGE_TOP_LEFT, C_EDGE_TOP_BACK, C_EDGE_BOTTOM_BACK, C_EDGE_BOTTOM_RIGHT, C_EDGE_TOP_RIGHT);


type
   TVoxelModelizerItem = class
      private
         procedure BuildFilledVerts(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; _MyClassification: single; _MySurface: integer);
         procedure BuildFilledEdges(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; _MyClassification: single; _MySurface: integer);
         procedure BuildFilledFaces(const _VoxelMap: TVoxelMap; const Cube : TNormals; _MyClassification: single);
      public
         // Position
         x, y, z: integer;
         // Region as a cube
         FilledVerts: array[0..7] of boolean;
         FilledEdges: array[0..11] of boolean;
         FilledFaces: array[0..5] of boolean;
         // Situation per face and its edges.
         FaceSettings: array[0..5] of byte;
         EdgeSettings: array[0..5,0..3] of byte;
         EdgeVertices: array[0..5,0..3,0..1] of integer;
         // Faces
         NumFaces: integer;
         Faces: array of integer;
         VertexGeneratedList : array of integer;
         EdgeGeneratedList : array of integer;
         FaceGeneratedList : array of integer;

         VertexGeneratedPositions : array of TVector3i;
         EdgeGeneratedPositions : array of TVector3i;
         FaceGeneratedPositions : array of TVector3i;

         // Constructors and Destructors
         constructor Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; _x, _y, _z : integer; var _TotalNumVertices: integer);
         // Adds
         function AddVertex( var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer): integer;
   end;

implementation

constructor TVoxelModelizerItem.Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; _x, _y, _z : integer; var _TotalNumVertices: integer);
var
   v1,v2,e1,e2,p,i,imax,value : integer;
   Cube : TNormals;
   MyClassification: single;
   MySurface: integer;
   v0x,v0y,v0z: integer;
   FaceHasVertices,FaceHasEdges : boolean;
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
   for i := 0 to 11 do
   begin
      VisitedEdgesVertex[i] := false;
      VisitedEdges[i] := false;
      InternalFaceEdges[i] := false;
      ExternalFaceEdges[i] := false;
   end;
   for i := 0 to 5 do // for each face
   begin
      // check if this face will constructed based on vertexes (traditional marching cubes)
      v1 := i * 4;
      v2 := v1 + 3;
      FaceHasVertices := false;
      while v1 < v2 do
      begin
         FaceHasVertices := FaceHasVertices or FilledVerts[FaceVerts[v1]];
         inc(v1);
      end;
      // We'll generate new vertexes based on edges where only one of its vertexes is in the volume.
      if FaceHasVertices then
      begin
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
                  VertexGeneratedList[High(VertexGeneratedList)] := AddVertex(_VertexMap,v0x + VertexPoints[i,p,1,0], v0y + VertexPoints[i,p,1,1], v0z + VertexPoints[i,p,1,2],_TotalNumVertices);
               end;
            end;
         end;
      end
      else
      begin
         // check if this face will constructed based on edges
         e1 := i * 4;
         e2 := e1 + 3;
         FaceHasEdges := false;
         while e1 < e2 do
         begin
            FaceHasEdges := FaceHasEdges or FilledEdges[FaceEdges[e1]];
            inc(e1);
         end;
         // We'll generate new vertexes based on filled edges
         if FaceHasEdges then
         begin
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
                        EdgeGeneratedList[High(EdgeGeneratedList)- (e2 - e1)] := AddVertex(_VertexMap,v0x + ((EdgeCentralPoints[EdgeNeighboorList[e1],0] + EdgeCentralPoints[FaceEdges[v1],0]) div 2), v0y + ((EdgeCentralPoints[EdgeNeighboorList[e1],1] + EdgeCentralPoints[FaceEdges[v1],1]) div 2), v0z + ((EdgeCentralPoints[EdgeNeighboorList[e1],2] + EdgeCentralPoints[FaceEdges[v1],2]) div 2),_TotalNumVertices);
                     end
                     else
                     begin
                        // Add a vertex in the middle of the edge.
                        EdgeGeneratedList[High(EdgeGeneratedList)- (e2 - e1)] := AddVertex(_VertexMap,v0x + EdgeCentralPoints[EdgeNeighboorList[e1],0], v0y + EdgeCentralPoints[EdgeNeighboorList[e1],1], v0z + EdgeCentralPoints[EdgeNeighboorList[e1],2],_TotalNumVertices);
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
                  FaceGeneratedList[High(FaceGeneratedList) - (4 - p)] := AddVertex(_VertexMap,v0x + VertexPoints[i,p,0,0], v0y + VertexPoints[i,p,0,1], v0z + VertexPoints[i,p,0,2],_TotalNumVertices);
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
                  FaceGeneratedList[High(FaceGeneratedList)] := AddVertex(_VertexMap,v0x + EdgeCentralPoints[EdgeNeighboorList[e1],0], v0y + EdgeCentralPoints[EdgeNeighboorList[e1],1], v0z + EdgeCentralPoints[EdgeNeighboorList[e1],2],_TotalNumVertices);
               end;
               inc(e1);
            end;
         end;
      end;
   end;



   Cube.Free;
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
         CheckPoint := Cube[f];
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

function TVoxelModelizerItem.AddVertex(var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer): integer;
begin
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

end.
