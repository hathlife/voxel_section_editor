unit VoxelModelizerItem;

interface

uses BasicFunctions, BasicDataTypes, VoxelMap, Normals, Class2DPointQueue,
   BasicConstants, ThreeDMap, Voxel_Engine, Palette, Dialogs, SysUtils,
   ClassFaceQueue, ClassVertexQueue, Class2DPointOrderList;

const
   C_NOTCHECKED = -2;
   C_FORBIDDEN = -1;

type
   TFilledVerts = array[0..7] of boolean;
   TFilledEdges = array[0..11] of boolean;
   TFilledFaces = array[0..5] of boolean;
   TFaceSettings = array [0..5] of integer;
   TVertexesArray = array[0..19] of integer;
   TEdgesMatrix = array[0..19,0..19] of integer;

   TVoxelModelizerItem = class
      private
         // Colouring procedure
         procedure SetColour(const _VoxelMap, _ColourMap: TVoxelMap; const _Palette: TPalette; _MyClassification: single; _x,_y,_z: integer);
         // Classification procedures
         procedure BuildFilledVerts(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; var _FilledVerts: TFilledVerts; _MyClassification: single; _x,_y,_z,_MySurface: integer);
         procedure BuildFilledEdges(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; const Cube : TNormals; var _FilledEdges: TFilledEdges; _MyClassification: single; _x,_y,_z,_MySurface: integer);
         procedure BuildFilledFaces(const _VoxelMap: TVoxelMap; const Cube : TNormals; var _FilledFaces: TFilledFaces; _MyClassification: single; _x,_y,_z: integer);
         // Face construction procedures
         procedure BuildFaces(var _DistanceMatrix: TEdgesMatrix;  var _FaceMap: T3DMap; const _VertexList: TVertexesArray);
         function IsEdgePaintable( _P1, _P2, _P3, _P4: integer):boolean;
         // Adds
         function AddVertex(var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer): integer;
      public
         // Colour
         Colour: TVector4f;
         // Faces
         Faces: CFaceQueue;

         // Constructors and Destructors
         constructor Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; _x, _y, _z : integer; var _TotalNumVertexes: integer; const _Palette: TPalette; const _ColourMap: TVoxelMap);
         destructor Destroy; override;
   end;
   PVoxelModelizerItem = ^TVoxelModelizerItem;

implementation

constructor TVoxelModelizerItem.Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; _x, _y, _z : integer; var _TotalNumVertexes: integer; const _Palette: TPalette; const _ColourMap: TVoxelMap);
var
   v1,v2,e1,e2,p,i : integer;
   Cube : TNormals;
   v0x,v0y,v0z: integer;
   // Vertexes
   VertexList: TVertexesArray;
   HasVertex: boolean;
   // Edges Distance
   EdgesDistanceMatrix : TEdgesMatrix;
   // FaceMap
   FaceMap: T3DMap;
   // Situation
   MyClassification: single;
   MySurface: integer;
   // Region as a cube
   FilledVerts: TFilledVerts;
   FilledEdges: TFilledEdges;
   FilledFaces: TFilledFaces;
begin
   // Reset basic variables.
   Cube := TNormals.Create(6);
   Faces := CFaceQueue.Create;
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
   for i := 0 to 19 do
   begin
      VertexList[i] := C_NOTCHECKED;
      for p := 0 to 19 do
      begin
         EdgesDistanceMatrix[i,p] := C_NOTCHECKED;
      end;
   end;
   HasVertex := false;
   // construct the vertexes from vertexes.
   for i := 0 to 7 do
   begin
      if FilledVerts[i] then
      begin
         HasVertex := true;
         VertexList[i] := C_FORBIDDEN;
         // set the neighbours as potential vertexes.
         v1 := i * 3;
         v2 := v1 + 3;
         while v1 < v2 do
         begin
            VertexList[VertexNeighbors[v1]] := 0;
            inc(v1);
         end;
      end;
   end;
   // construct the vertexes from edges.
   for i := 0 to 11 do
   begin
      if FilledEdges[i] then
      begin
         HasVertex := true;
         VertexList[i+8] := C_FORBIDDEN;
         // try to create vertexes in the neigbours if possible.
         v1 := i * 6;
         v2 := v1 + 6;
         while v1 < v2 do
         begin
            if VertexList[EdgeVertexesList[v1]] <> C_FORBIDDEN then
            begin
               VertexList[EdgeVertexesList[v1]] := 0;
            end;
            inc(v1);
         end;
         // Now we ensure that some of the edges will not be in the final result
         e1 := i * 4;//12;
         e2 := e1 + 4;//12;
         while e1 < e2 do
         begin
            EdgesDistanceMatrix[ForbiddenEdgesPerEdges[e1,0],ForbiddenEdgesPerEdges[e1,1]] := C_FORBIDDEN;
            EdgesDistanceMatrix[ForbiddenEdgesPerEdges[e1,1],ForbiddenEdgesPerEdges[e1,0]] := C_FORBIDDEN;
            inc(e1);
         end;
      end;
   end;

   // The lonely cube case... or those who only have faces and nothing else.
   if (not HasVertex) and (MyClassification = C_SURFACE) then
   begin
      // Force a cube.
      for i := 0 to 7 do
      begin
         VertexList[i] := 0;
      end;
   end;

   // Add all vertexes
   for i := 0 to 19 do
   begin
      if VertexList[i] >= 0 then
      begin
         VertexList[i] := AddVertex(_VertexMap,v0x + VertexPoints[i,0], v0y + VertexPoints[i,1], v0z + VertexPoints[i,2],_TotalNumVertexes);

         // There is no edge with only one vertex.
         EdgesDistanceMatrix[i,i] := C_FORBIDDEN;
      end
      else // if the vertex does not exist, there will be no edges for it.
      begin
         VertexList[i] := C_FORBIDDEN;
         for p := 0 to 19 do
         begin
            EdgesDistanceMatrix[i,p] := C_FORBIDDEN;
            EdgesDistanceMatrix[p,i] := C_FORBIDDEN;
         end;
      end;
   end;

   // Prepare FaceMap:
   FaceMap := T3DMap.Create(20,20,20);
   for i := 0 to 11 do
   begin
      FaceMap.Map[ForbiddenFaces[i,0],ForbiddenFaces[i,1],ForbiddenFaces[i,2]] := C_FORBIDDEN;
      FaceMap.Map[ForbiddenFaces[i,0],ForbiddenFaces[i,2],ForbiddenFaces[i,1]] := C_FORBIDDEN;
      FaceMap.Map[ForbiddenFaces[i,1],ForbiddenFaces[i,0],ForbiddenFaces[i,2]] := C_FORBIDDEN;
      FaceMap.Map[ForbiddenFaces[i,1],ForbiddenFaces[i,2],ForbiddenFaces[i,0]] := C_FORBIDDEN;
      FaceMap.Map[ForbiddenFaces[i,2],ForbiddenFaces[i,0],ForbiddenFaces[i,1]] := C_FORBIDDEN;
      FaceMap.Map[ForbiddenFaces[i,2],ForbiddenFaces[i,1],ForbiddenFaces[i,0]] := C_FORBIDDEN;
   end;

   // block faces according to the filled faces.
   for i := 0 to 5 do
   begin
      if FilledFaces[i] then
      begin
         // try to create vertexes in the neigbours if possible.
         v1 := i * 53;
         v2 := v1 + 53;
         while v1 < v2 do
         begin
            FaceMap.Map[ForbiddenFacesPerFaces[v1,0],ForbiddenFacesPerFaces[v1,1],ForbiddenFacesPerFaces[v1,2]] := C_FORBIDDEN;
            FaceMap.Map[ForbiddenFacesPerFaces[v1,0],ForbiddenFacesPerFaces[v1,2],ForbiddenFacesPerFaces[v1,1]] := C_FORBIDDEN;
            FaceMap.Map[ForbiddenFacesPerFaces[v1,1],ForbiddenFacesPerFaces[v1,0],ForbiddenFacesPerFaces[v1,2]] := C_FORBIDDEN;
            FaceMap.Map[ForbiddenFacesPerFaces[v1,1],ForbiddenFacesPerFaces[v1,2],ForbiddenFacesPerFaces[v1,0]] := C_FORBIDDEN;
            FaceMap.Map[ForbiddenFacesPerFaces[v1,2],ForbiddenFacesPerFaces[v1,0],ForbiddenFacesPerFaces[v1,1]] := C_FORBIDDEN;
            FaceMap.Map[ForbiddenFacesPerFaces[v1,2],ForbiddenFacesPerFaces[v1,1],ForbiddenFacesPerFaces[v1,0]] := C_FORBIDDEN;
            inc(v1);
         end;
      end;
   end;


   // Now we construct the faces.
   BuildFaces(EdgesDistanceMatrix,FaceMap,VertexList);

   FaceMap.Free;
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
               if (_SurfaceMap[Point.X,Point.Y,Point.Z] and SSVertexesCheck[i]) >= SSVertexesCheck[i]  then
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
      if (_MyClassification = C_SURFACE) or ((_MySurface and EdgeRequirements[e]) >= EdgeRequirements[e]) then
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
               if (_SurfaceMap[Point.X,Point.Y,Point.Z] and SSEdgesCheck[i]) >= SSEdgesCheck[i]  then
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

// - 1) Build a distance table between the vertexes (not using square root).
// - 2) Order edges by distances (32, 64, 96 and 128)
// - 3) Draw each edge in the edge in the hashing and check for interceptions.
// - 4) Combine linked vertexes from the surviving edges to build the faces.
procedure TVoxelModelizerItem.BuildFaces(var _DistanceMatrix: TEdgesMatrix; var _FaceMap: T3DMap; const _VertexList: TVertexesArray);
const
   RESOLUTION = 1;
var
   QueueDist: C2DPointOrderList;
   i, j, k, l : integer;
   Position: P2DPosition;
   List: P2DPointOrderItem;
begin
   // Prepare variables
   QueueDist := C2DPointOrderList.Create;

   // Prepare distance list.
   // Build the distance matrix.
   i := 0;
   while i < 20 do
   begin
      j := i+1;
      while j < 20 do
      begin
         // get a fake distance, since it doesn't have the square root, which is unnecessary in this case.
         if _DistanceMatrix[i,j] <> C_FORBIDDEN then
         begin
            _DistanceMatrix[i,j] := ((VertexPoints[i,0] - VertexPoints[j,0]) * (VertexPoints[i,0] - VertexPoints[j,0])) + ((VertexPoints[i,1] - VertexPoints[j,1]) * (VertexPoints[i,1] - VertexPoints[j,1])) + ((VertexPoints[i,2] - VertexPoints[j,2]) * (VertexPoints[i,2] - VertexPoints[j,2]));
            // Add the edge to the list related to its distance.
            if _DistanceMatrix[i,j] > 0 then
            begin
               QueueDist.Add(_DistanceMatrix[i,j],i,j);
            end;
            _DistanceMatrix[j,i] := _DistanceMatrix[i,j];
         end;
         inc(j);
      end;
      inc(i);
   end;
   // So, there we go, with all distances and ordered edges in 4 lists.
   // Let's check the edges that intercept other edges and cut them.
   if not QueueDist.IsEmpty then
   begin
      QueueDist.GoToFirstElement;
      QueueDist.GoToNextElement;
      while QueueDist.GetPosition(i,j) do
      begin
         QueueDist.GetFirstElement(List,Position);
         while (not QueueDist.IsActive(List,Position)) do
         begin
            k := Position^.x;
            l := Position^.y;
            if not IsEdgePaintable(i,j,k,l) then
            begin
               _DistanceMatrix[i,j] := C_FORBIDDEN;
               _DistanceMatrix[j,i] := C_FORBIDDEN;
               QueueDist.Delete;
               QueueDist.GetActive(List,Position); // Leave loop
            end
            else
               QueueDist.GetNextElement(List,Position);
         end;
         QueueDist.GoToNextElement;
      end;
   end;
   // So, we have all edges. Let's build faces out of it and write them.
   if not QueueDist.IsEmpty then
   begin
      QueueDist.GoToFirstElement;
      while QueueDist.GetPosition(i,j) do
      begin
         k := 0;
         while k < 20 do
         begin
            if (_DistanceMatrix[k,i] > 0) and (_DistanceMatrix[j,k] > 0) and (_FaceMap[i,j,k] <> C_FORBIDDEN) then
            begin
               // Add i, j, k to faces.
               Faces.Add(_VertexList[i],_VertexList[j],_VertexList[k]);
               // Ensure that the same face will not be detected anymore.
               _FaceMap.Map[i,j,k] := C_FORBIDDEN;
               _FaceMap.Map[i,k,j] := C_FORBIDDEN;
               _FaceMap.Map[j,i,k] := C_FORBIDDEN;
               _FaceMap.Map[j,k,i] := C_FORBIDDEN;
               _FaceMap.Map[k,i,j] := C_FORBIDDEN;
               _FaceMap.Map[k,j,i] := C_FORBIDDEN;
               k := 20;
             end
             else
                inc(k);
         end;
         QueueDist.GoToNextElement;
      end;
   end;
   // Free memory
   QueueDist.Free;
end;

function TVoxelModelizerItem.IsEdgePaintable( _P1, _P2, _P3, _P4: integer):boolean;
{
const
   EPS = 1;
var
   x21,x43,x13: integer;
   y21,y43,y13: integer;
   z21,z43,z13: integer;
   d1343,d4321,d1321,d4343,d2121: integer;
   denom,numer: integer;
   mua,mub : single;
begin
   x13 := VertexPoints[_P1,0] - VertexPoints[_P3,0];
   y13 := VertexPoints[_P1,1] - VertexPoints[_P3,1];
   z13 := VertexPoints[_P1,2] - VertexPoints[_P3,2];
   x43 := VertexPoints[_P4,0] - VertexPoints[_P3,0];
   y43 := VertexPoints[_P4,1] - VertexPoints[_P3,1];
   z43 := VertexPoints[_P4,2] - VertexPoints[_P3,2];
   if (abs(x43) < EPS) and (abs(y43) < EPS) and (abs(z43) < EPS) then
   begin
      Result := false;
      exit;
   end;
   x21 := VertexPoints[_P2,0] - VertexPoints[_P1,0];
   y21 := VertexPoints[_P2,1] - VertexPoints[_P1,1];
   z21 := VertexPoints[_P2,2] - VertexPoints[_P1,2];
   if (abs(x21) < EPS) and (abs(y21) < EPS) and (abs(z21) < EPS) then
   begin
      Result := false;
      exit;
   end;

   d1343 := (x13 * x43) + (y13 * y43) + (z13 * z43);
   d4321 := (x43 * x21) + (y43 * y21) + (z43 * z21);
   d1321 := (x13 * x21) + (y13 * y21) + (z13 * z21);
   d4343 := (x43 * x43) + (y43 * y43) + (z43 * z43);
   d2121 := (x21 * x21) + (y21 * y21) + (z21 * z21);

   denom := (d2121 * d4343) - (d4321 * d4321);
   if (abs(denom) < EPS) then
   begin
      Result := false;
      exit;
   end;
   numer := (d1343 * d4321) - (d1321 * d4343);

   mua := numer / denom;
   mub := (d1343 + (d4321 * mua)) / d4343;
//   if (abs(mub) < EPS) and (abs(mua) < EPS) and (mua <> 0) and (mub <> 0) then
//      Result := false
//   else
      Result := true;
end;
}

var
   PositionA,PositionB: single;
   x21,x43,x31,x41: integer;
   y21,y43,y31,y41: integer;
   z21,z43,z31,z41: integer;
   factorxy,factorxz,factoryz: integer;
   denom: integer;
   distance: array[0..3] of integer;
   points: array[0..3] of integer;
   maxdistance, i : integer;
   Det: integer;
   IsPointInsideEdge: boolean;
   procedure GetPositionA(_PositionB: single);
   begin
      if x21 <> 0 then
         PositionA := (x31 + (PositionB * x43)) / x21
      else if y21 <> 0 then
         PositionA := (y31 + (PositionB * y43)) / y21
      else
         PositionA := (z31 + (PositionB * z43)) / z21;
   end;
   function IsParalelOrCoincident: boolean;
   var
      Average: single;
   begin
      Average := 0;
      if x43 <> 0 then
      begin
         if x21 = 0 then
         begin
            Result := false;
            exit;
         end;
         Average := x21 / x43;
      end;
      if y43 <> 0 then
      begin
         if y21 = 0 then
         begin
            Result := false;
            exit;
         end;
         if Average <> 0 then
         begin
            if Average <> (y21 / y43) then
            begin
               Result := false;
               exit;
            end;
         end
         else
         begin
            Average := y21 / y43;
         end;
      end;
      if z43 <> 0 then
      begin
         if z21 = 0 then
         begin
            Result := false;
            exit;
         end;
         if Average <> 0 then
         begin
            if Average <> (z21 / z43) then
            begin
               Result := false;
               exit;
            end;
         end
         else
         begin
            Average := z21 / z43;
         end;
      end;
      Result := true;
   end;
begin
   Result := true;
   // Let's make sure P1 and P3's distance is the highest possible.
   maxdistance := 0;
   distance[0] := ((VertexPoints[_P1,0] - VertexPoints[_P3,0]) * (VertexPoints[_P1,0] - VertexPoints[_P3,0])) + ((VertexPoints[_P1,1] - VertexPoints[_P3,1]) * (VertexPoints[_P1,1] - VertexPoints[_P3,1])) + ((VertexPoints[_P1,2] - VertexPoints[_P3,2]) * (VertexPoints[_P1,2] - VertexPoints[_P3,2]));
   distance[1] := ((VertexPoints[_P2,0] - VertexPoints[_P3,0]) * (VertexPoints[_P2,0] - VertexPoints[_P3,0])) + ((VertexPoints[_P2,1] - VertexPoints[_P3,1]) * (VertexPoints[_P2,1] - VertexPoints[_P3,1])) + ((VertexPoints[_P2,2] - VertexPoints[_P3,2]) * (VertexPoints[_P2,2] - VertexPoints[_P3,2]));
   distance[2] := ((VertexPoints[_P1,0] - VertexPoints[_P4,0]) * (VertexPoints[_P1,0] - VertexPoints[_P4,0])) + ((VertexPoints[_P1,1] - VertexPoints[_P4,1]) * (VertexPoints[_P1,1] - VertexPoints[_P4,1])) + ((VertexPoints[_P1,2] - VertexPoints[_P4,2]) * (VertexPoints[_P1,2] - VertexPoints[_P4,2]));
   distance[3] := ((VertexPoints[_P2,0] - VertexPoints[_P4,0]) * (VertexPoints[_P2,0] - VertexPoints[_P4,0])) + ((VertexPoints[_P2,1] - VertexPoints[_P4,1]) * (VertexPoints[_P2,1] - VertexPoints[_P4,1])) + ((VertexPoints[_P2,2] - VertexPoints[_P4,2]) * (VertexPoints[_P2,2] - VertexPoints[_P4,2]));
   for i := 1 to 3 do
   begin
      if distance[i] > distance[maxdistance] then
      begin
         maxdistance := i;
      end;
   end;
   case maxdistance of
      0:
      begin
         Points[0] := _P1;
         Points[1] := _P2;
         Points[2] := _P3;
         Points[3] := _P4;
      end;
      1:
      begin
         Points[0] := _P2;
         Points[1] := _P1;
         Points[2] := _P3;
         Points[3] := _P4;
      end;
      2:
      begin
         Points[0] := _P1;
         Points[1] := _P2;
         Points[2] := _P4;
         Points[3] := _P3;
      end;
      3:
      begin
         Points[0] := _P2;
         Points[1] := _P1;
         Points[2] := _P4;
         Points[3] := _P3;
      end;
   end;
   // get edge points.
   x21 := VertexPoints[Points[1],0] - VertexPoints[Points[0],0];
   x43 := VertexPoints[Points[3],0] - VertexPoints[Points[2],0];
   x31 := VertexPoints[Points[2],0] - VertexPoints[Points[0],0];
   x41 := VertexPoints[Points[3],0] - VertexPoints[Points[0],0];
   y21 := VertexPoints[Points[1],1] - VertexPoints[Points[0],1];
   y43 := VertexPoints[Points[3],1] - VertexPoints[Points[2],1];
   y31 := VertexPoints[Points[2],1] - VertexPoints[Points[0],1];
   y41 := VertexPoints[Points[3],1] - VertexPoints[Points[0],1];
   z21 := VertexPoints[Points[1],2] - VertexPoints[Points[0],2];
   z43 := VertexPoints[Points[3],2] - VertexPoints[Points[2],2];
   z31 := VertexPoints[Points[2],2] - VertexPoints[Points[0],2];
   z41 := VertexPoints[Points[3],2] - VertexPoints[Points[0],2];
   // check if the edges are paralel or not.
   if IsParalelOrCoincident then
   begin
      // check if one of the points coincides in the othe edges.
      //x3 = x1 + t(x2 - x1) -> t = x31 / x21
      PositionA := 0;
      // check Point 3 on edge 2-1 in axis X
      if x21 <> 0 then
      begin
         PositionA := x31 / x21;
         IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
      end
      else
      begin
         IsPointInsideEdge := VertexPoints[Points[2],0] = VertexPoints[Points[0],0];
      end;
      // Axis Y
      if IsPointInsideEdge then
      begin
         if y21 <> 0 then
         begin
            if PositionA <> 0 then
            begin
               IsPointInsideEdge := PositionA = (y31 / y21);
            end
            else
            begin
               PositionA := y31 / y21;
               IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
            end;
         end
         else
         begin
            IsPointInsideEdge := VertexPoints[Points[2],1] = VertexPoints[Points[0],1];
         end;
         // Axis Z
         if IsPointInsideEdge then
         begin
            if z21 <> 0 then
            begin
               if PositionA <> 0 then
               begin
                  IsPointInsideEdge := PositionA = (z31 / z21);
               end
               else
               begin
                  PositionA := z31 / z21;
                  IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
               end;
            end
            else
            begin
               IsPointInsideEdge := VertexPoints[Points[2],2] = VertexPoints[Points[0],2];
            end;
            if IsPointInsideEdge then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
      //x4 = x1 + t(x2 - x1) -> t = x41 / x21
      PositionA := 0;
      // check Point 4 on edge 2-1 in axis X
      if x21 <> 0 then
      begin
         PositionA := x41 / x21;
         IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
      end
      else
      begin
         IsPointInsideEdge := VertexPoints[Points[3],0] = VertexPoints[Points[0],0];
      end;
      // Axis Y
      if IsPointInsideEdge then
      begin
         if y21 <> 0 then
         begin
            if PositionA <> 0 then
            begin
               IsPointInsideEdge := PositionA = (y41 / y21);
            end
            else
            begin
               PositionA := y41 / y21;
               IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
            end;
         end
         else
         begin
            IsPointInsideEdge := VertexPoints[Points[3],1] = VertexPoints[Points[0],1];
         end;
         // Axis Z
         if IsPointInsideEdge then
         begin
            if z21 <> 0 then
            begin
               if PositionA <> 0 then
               begin
                  IsPointInsideEdge := PositionA = (z41 / z21);
               end
               else
               begin
                  PositionA := z41 / z21;
                  IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
               end;
            end
            else
            begin
               IsPointInsideEdge := VertexPoints[Points[3],2] = VertexPoints[Points[0],2];
            end;
            if IsPointInsideEdge then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
      //x1 = x3 + t(x4 - x3) -> t = (-x31) / x43
      PositionA := 0;
      // check Point 1 on edge 4-3 in axis X
      if x43 <> 0 then
      begin
         PositionA := (-x31) / x43;
         IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
      end
      else
      begin
         IsPointInsideEdge := VertexPoints[Points[0],0] = VertexPoints[Points[2],0];
      end;
      // Axis Y
      if IsPointInsideEdge then
      begin
         if y43 <> 0 then
         begin
            if PositionA <> 0 then
            begin
               IsPointInsideEdge := PositionA = ((-y31) / y43);
            end
            else
            begin
               PositionA := (-y43) / y43;
               IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
            end;
         end
         else
         begin
            IsPointInsideEdge := VertexPoints[Points[0],1] = VertexPoints[Points[2],1];
         end;
         // Axis Z
         if IsPointInsideEdge then
         begin
            if z43 <> 0 then
            begin
               if PositionA <> 0 then
               begin
                  IsPointInsideEdge := PositionA = (-z31 / z43);
               end
               else
               begin
                  PositionA := (-z43) / z43;
                  IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
               end;
            end
            else
            begin
               IsPointInsideEdge := VertexPoints[Points[0],2] = VertexPoints[Points[2],2];
            end;
            if IsPointInsideEdge then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
      //x2 = x3 + t(x4 - x3) -> t = x23 / x43
      PositionA := 0;
      // check Point 1 on edge 4-3 in axis X
      if x43 <> 0 then
      begin
         PositionA := (VertexPoints[Points[1],0] - VertexPoints[Points[2],0]) / x43;
         IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
      end
      else
      begin
         IsPointInsideEdge := VertexPoints[Points[1],0] = VertexPoints[Points[2],0];
      end;
      // Axis Y
      if IsPointInsideEdge then
      begin
         if y43 <> 0 then
         begin
            if PositionA <> 0 then
            begin
               IsPointInsideEdge := PositionA = ((VertexPoints[Points[1],1] - VertexPoints[Points[2],1]) / y43);
            end
            else
            begin
               PositionA := (VertexPoints[Points[1],1] - VertexPoints[Points[2],1]) / y43;
               IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
            end;
         end
         else
         begin
            IsPointInsideEdge := VertexPoints[Points[1],1] = VertexPoints[Points[2],1];
         end;
         // Axis Z
         if IsPointInsideEdge then
         begin
            if z43 <> 0 then
            begin
               if PositionA <> 0 then
               begin
                  IsPointInsideEdge := PositionA = ((VertexPoints[Points[1],2] - VertexPoints[Points[2],2]) / z43);
               end
               else
               begin
                  PositionA := (VertexPoints[Points[1],2] - VertexPoints[Points[2],2]) / z43;
                  IsPointInsideEdge := (PositionA > 0) and (PositionA < 1);
               end;
            end
            else
            begin
               IsPointInsideEdge := VertexPoints[Points[1],2] = VertexPoints[Points[2],2];
            end;
            if IsPointInsideEdge then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
   end
   else
   begin
      // check if the edges are in the plane
      // Det = 0
      Det := (x21 * y43 * z31) + (y21 * z43 * x21) + (z21 * x43 * y31) - (x21 * z43 * y31) - (y21 * x43 * z31) - (z21 * y43 * x31);
      if Det <> 0 then
      begin
         exit;
      end;

      factorxz := (z21 * x43) - (z43 * x21);
      factorxy := (y21 * x43) - (y43 * x21);
      factoryz := (z21 * y43) - (z43 * y21);
      if (factorxy <> 0) then
      begin
         PositionB := ((x21 * y31) - (x31 * y21)) / factorxy;
         if (abs(PositionB) > 0) and (abs(PositionB) < 1) then
         begin
            GetPositionA(PositionB);
            if (abs(PositionA) > 0) and (abs(PositionA) < 1) then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
      if (factorxz <> 0) then
      begin
         PositionB := ((x21 * z31) - (x31 * z21)) / factorxz;
         if (abs(PositionB) > 0) and (abs(PositionB) < 1) then
         begin
            GetPositionA(PositionB);
            if (abs(PositionA) > 0) and (abs(PositionA) < 1) then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
      if (factoryz <> 0) then
      begin
         PositionB := ((y21 * z31) - (y31 * z21)) / factoryz;
         if (abs(PositionB) > 0) and (abs(PositionB) < 1) then
         begin
            GetPositionA(PositionB);
            if (abs(PositionA) > 0) and (abs(PositionA) < 1) then
            begin
               Result := false;
               exit;
            end;
         end;
      end;
      if (factorxy = 0) and (factorxz = 0) and (factoryz = 0) then
      begin


      end;
   end;
{
   denom := 2 * factorxz * factorxy;
   if denom <> 0 then
   begin
      PositionB := ((factorxy * ((x21 * z31) - (z21 * x31))) + (factorxz * ((x21 * y31) - (y21 * x31)))) / denom;
      if (PositionB > 0) and (PositionB < 1) then
      begin
         GetPositionA(PositionB);
         if (PositionA > 0) and (PositionA < 1) then
         begin
            Result := false;
            exit;
         end;
      end;
   end;
   denom := 2 * factoryz * factorxy;
   if denom <> 0 then
   begin
      PositionB := ((factorxy * ((z21 * y31) - (y21 * z31))) + (factoryz * ((x21 * y31) - (y21 * x31)))) / denom;
      if (PositionB > 0) and (PositionB < 1) then
      begin
         GetPositionA(PositionB);
         if (PositionA > 0) and (PositionA < 1) then
         begin
            Result := false;
            exit;
         end;
      end;
   end;
   denom := 2 * factorxz * factoryz;
   if denom <> 0 then
   begin
      PositionB := ((factoryz * ((x21 * z31) - (z21 * x31))) + (factorxz * ((z21 * y31) - (y21 * z31)))) / denom;
      if (PositionB > 0) and (PositionB < 1) then
      begin
         GetPositionA(PositionB);
         if (PositionA > 0) and (PositionA < 1) then
         begin
            Result := false;
            exit;
         end;
      end;
   end;
}
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
