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
   // Vertex Outcome
   C_VERT_OUT_OUT = 0;
   C_VERT_OUT_IN = 1;
   C_VERT_OUT_ONE_Q2 = 2;
   C_VERT_OUT_ONE_Q7 = 3;
   C_VERT_OUT_TWO_Q13 = 4;
   C_VERT_OUT_TWO_Q04 = 5;
   C_VERT_OUT_TWO_Q68 = 6;
   C_VERT_OUT_TWO_Q59 = 7;


type
   TVoxelModelizerItem = class
      private
      public
         // Position
         x, y, z: integer;
         // Region as a cube
         FilledVerts: array[0..7] of boolean;
         FilledEdges: array[0..11] of boolean;
         FilledFaces: array[0..5] of boolean;
         // Situation per face and its edges.
         EdgeSettings: array[0..5,0..3] of byte;
         EdgeVertices: array[0..5,0..3,0..1] of integer;
         // Faces
         NumFaces: integer;
         Faces: array of integer;
         // Constructors and Destructors
         constructor Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; _x, _y, _z : integer; var _TotalNumVertices: integer);
         // Adds
         function AddVertex( var _VertexMap : T3DIntGrid; _x,_y,_z: integer; var _NumVertices: integer): integer;
   end;

implementation

constructor TVoxelModelizerItem.Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; var _VertexMap : T3DIntGrid; _x, _y, _z : integer; var _TotalNumVertices: integer);
const
   VerticeRequirements: array[0..7] of integer = (C_SF_TOP_BACK_LEFT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT);

   VerticeCheck: array[0..55] of byte = (0, 1, 4, 8, 9, 10, 11, 17, 18, 21, 25, 9, 10,
   11, 0, 1, 3, 6, 13, 12, 11, 17, 18, 20, 23, 13, 12, 11, 0, 2, 4, 7, 9, 16, 15,
   17, 19, 21, 24, 9, 16, 15, 0, 2, 3, 5, 13, 14, 15, 17, 19, 20, 22, 13, 14, 15);

   SSVerticesCheck: array[0..55] of byte = (C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
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

   VertexOutcome: array[0..15] of byte = (C_VERT_OUT_OUT, C_VERT_OUT_ONE_Q7,
   C_VERT_OUT_ONE_Q7, C_VERT_OUT_TWO_Q59, C_VERT_OUT_TWO_Q13, C_VERT_OUT_ONE_Q2,
   C_VERT_OUT_ONE_Q2, C_VERT_OUT_TWO_Q04, C_VERT_OUT_TWO_Q68, C_VERT_OUT_ONE_Q7,
   C_VERT_OUT_ONE_Q7, C_VERT_OUT_TWO_Q59, C_VERT_OUT_TWO_Q13, C_VERT_OUT_ONE_Q2,
   C_VERT_OUT_ONE_Q2, C_VERT_OUT_IN);

   VertexQuarterPoints: array[0..5,0..3,0..9,0..2] of byte = ((((0,4,4), (0,4,3), (0,4,2), (0,4,1),
   (0,4,0), (0,3,4), (0,3,3), (0,3,2), (0,3,1), (0,3,0)), ((0,4,0), (0,3,0), (0,2,0), (0,1,0), (0,0,0),
   (0,4,1), (0,3,1), (0,2,1), (0,1,1), (0,0,1)), ((0,0,0), (0,0,1), (0,0,2), (0,0,3), (0,0,4), (0,1,0),
   (0,1,1), (0,1,2), (0,1,3), (0,1,4)), ((0,0,4), (0,1,4), (0,2,4), (0,3,4), (0,4,4), (0,0,3), (0,1,3),
   (0,2,3), (0,3,3), (0,4,3))),(((4,0,4), (4,0,3), (4,0,2), (4,0,1), (4,0,0), (4,1,4), (4,1,3), (4,1,2),
   (4,1,1), (4,1,0)),((4,0,0), (4,1,0), (4,2,0), (4,3,0), (4,4,0), (4,0,1), (4,1,1), (4,2,1), (4,3,1),
   (4,4,1)),((4,4,0), (4,4,1), (4,4,2), (4,4,3), (4,4,4), (4,3,0), (4,3,1), (4,3,2), (4,3,3), (4,3,4)),
	((4,4,4), (4,3,4), (4,2,4), (4,1,4), (4,0,4), (4,4,4), (4,3,4), (4,2,4), (4,1,4), (4,0,4))),
   (((0,0,4), (0,0,3), (0,0,2), (0,0,1), (0,0,0), (1,0,4), (1,0,3), (1,0,2), (1,0,1), (1,0,0)), ((0,0,0),
   (1,0,0), (2,0,0), (3,0,0), (4,0,0), (0,0,1), (1,0,1), (2,0,1), (3,0,1), (4,0,1)), ((4,0,0), (4,0,1),
   (4,0,2), (4,0,3), (4,0,4), (3,0,0), (3,0,1), (3,0,2), (3,0,3), (3,0,4)),((4,0,4), (3,0,4), (2,0,4),
   (1,0,4), (0,0,4), (4,0,3), (3,0,3), (2,0,3), (1,0,3), (0,0,3))),(((4,4,4), (4,4,3), (4,4,2), (4,4,1),
   (4,4,0), (3,4,4), (3,4,3), (3,4,2), (3,4,1), (3,4,0)),((4,4,0), (3,4,0), (2,4,0), (1,4,0), (0,4,0),
   (4,4,1), (3,4,1), (2,4,1), (1,4,1), (0,4,1)),((0,4,0), (0,4,1), (0,4,2), (0,4,3), (0,4,4), (1,4,0),
   (1,4,1), (1,4,2), (1,4,3), (1,4,4)),((0,4,4), (1,4,4), (2,4,4), (3,4,4), (4,4,4), (0,4,3), (1,4,3),
   (2,4,3), (3,4,3), (4,4,3))),(((4,4,0), (4,3,0), (4,2,0), (4,1,0), (4,0,0), (3,4,0), (3,3,0), (3,2,0),
   (3,1,0), (3,0,0)),((4,0,0), (3,0,0), (2,0,0), (1,0,0), (0,0,0), (4,1,0), (3,1,0), (2,1,0), (1,1,0),
   (0,1,0)),((0,0,0), (0,1,0), (0,2,0), (0,3,0), (0,4,0), (1,0,0), (1,1,0), (1,2,0), (1,3,0), (1,4,0)),
	((0,4,0), (1,4,0), (2,4,0), (3,4,0), (4,4,0), (0,4,1), (1,4,1), (2,4,1), (3,4,1), (4,4,1))),(((4,0,4),
   (4,1,4), (4,2,4), (4,3,4), (4,4,4), (3,0,4), (3,1,4), (3,2,4), (3,3,4), (3,4,4)), ((4,4,4), (3,4,4),
   (2,4,4), (1,4,4), (0,4,4), (4,3,4), (3,3,4), (2,3,4), (1,3,4), (0,3,4)),((0,4,4), (0,3,4), (0,2,4),
   (0,1,4), (0,0,4), (1,4,4), (1,3,4), (1,2,4), (1,1,4), (1,0,4)),((0,0,4), (1,0,4), (2,0,4), (3,0,4),
   (4,0,4), (0,1,4), (1,1,4), (2,1,4), (3,1,4), (4,1,4))));

   QuarterPerOutcomeIndexList: array[0..7,0..1] of integer = ((-1, -1),(-1, -1), (2, -1), (7, -1), (1, 3),
   (0, 4), (6,8), (5,9));

   PointsPerVerts = 7;
var
   v1,v2,p,i,imax,value : integer;
   Cube : TNormals;
   CheckPoint : TVector3f;
   Point : TVector3i;
   VoxelClassification,MyClassification: single;
   MySurface: integer;
   v0x,v0y,v0z: integer;
   FaceHasVertices,RegionHasVertices : boolean;
begin
   x := _x;
   y := _y;
   z := _z;
   // initial position in the vertex map;
   v0x := x * 4;
   v0y := y * 4;
   v0z := z * 4;

   Cube := TNormals.Create(6);
   // Check which vertices are in.
   i := 0;
   MyClassification := _VoxelMap.MapSafe[x,y,z];
   MySurface := _SurfaceMap[x,y,z];
   for p := 0 to 7 do
   begin
      if (MyClassification = C_SURFACE) or ((MySurface and VerticeRequirements[p]) <> 0) then
      begin
         FilledVerts[p] := true;
         imax := i + 7;
      end
      else
      begin
         FilledVerts[p] := false;
         imax := i - 1;
      end;
      while i < imax do
      begin
         CheckPoint := Cube[VerticeCheck[i]];
         Point.X := x + Round(CheckPoint.X);
         Point.Y := y + Round(CheckPoint.Y);
         Point.Z := z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         FilledVerts[p] := FilledVerts[p] and (VoxelClassification >= C_SURFACE);
         if not FilledVerts[p] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSVerticesCheck[i] <> 0  then
               begin
                  FilledVerts[p] := true;
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
   // Check which edges are in.
   i := 0;
   for p := 0 to 11 do
   begin
      if (MyClassification = C_SURFACE) or ((MySurface and VerticeRequirements[p]) <> 0) then
      begin
         FilledEdges[p] := true;
         imax := i + 3;
      end
      else
      begin
         FilledEdges[p] := false;
         imax := i - 1;
      end;
      while i < imax do
      begin
         CheckPoint := Cube[EdgeCheck[i]];
         Point.X := x + Round(CheckPoint.X);
         Point.Y := y + Round(CheckPoint.Y);
         Point.Z := z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         FilledEdges[p] := FilledEdges[p] and (VoxelClassification >= C_SURFACE);
         if not FilledEdges[p] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSEdgesCheck[i] <> 0  then
               begin
                  FilledEdges[p] := true;
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
   // Check which faces are in.
   for p := 0 to 5 do
   begin
      CheckPoint := Cube[p];
      Point.X := x + Round(CheckPoint.X);
      Point.Y := y + Round(CheckPoint.Y);
      Point.Z := z + Round(CheckPoint.Z);
      VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
      FilledFaces[p] := VoxelClassification >= C_SURFACE;
   end;

   // Let's analyse the situation for each edge and add the vertices.
   // First, split the cube into 6 faces. Each face has 4 edges.
   // FaceVerts has (topright, bottomright, bottomleft, topleft) for each face
   // FaceEdges has (right, bottom, left, top) for each face.
   RegionHasVertices := false;
   for i := 0 to 5 do // for each face
   begin
      FaceHasVertices := false;
      for p := 0 to 3 do // for each edge from the face i
      begin
         v1 := p * i; // vertice 1 and edge index
         v2 := ((p + 1) mod 4) * i; // vertice 2 index
         // We have the following cases:
         // Face | Edge | V1 | V2 | Outcome:
         //   0  | 0    | 0  | 0  | No vertice in the surface. (outside the object) :: Outcome 0
         //   0  | 0    | 0  | 1  | One vertice off the edge (Q7). :: Outcome 3
         //   0  | 0    | 1  | 0  | One vertice off the edge (Q7). :: Outcome 3
         //   0  | 0    | 1  | 1  | Two vertices off the edge (Q5 and Q9 independent). :: Outcome 7
         //   0  | 1    | 0  | 0  | Two vertices in the edge (Q1 and Q3 dependent).  :: Outcome 4
         //   0  | 1    | 0  | 1  | One vertice in the edge (Q2). :: Outcome 2
         //   0  | 1    | 1  | 0  | One vertice in the edge (Q2). :: Outcome 2
         //   0  | 1    | 1  | 1  | Two vertices in the edge (Q0 and Q4 independent). :: Outcome 5
         //   1  | 0    | 0  | 0  | Two vertices out of the edge (Q6 and Q8 independent). :: Outcome 6
         //   1  | 0    | 0  | 1  | One vertice out of the edge (Q7). :: Outcome 3
         //   1  | 0    | 1  | 0  | One vertice out of the edge (Q7). :: Outcome 3
         //   1  | 0    | 1  | 1  | Two vertices out of the edge (Q5 and Q9 independent). :: Outcome 7
         //   1  | 1    | 0  | 0  | Two vertices in the edge (Q1 and Q3 dependent). :: Outcome 4
         //   1  | 1    | 0  | 1  | One vertice in the edge (Q2). :: Outcome 2
         //   1  | 1    | 1  | 0  | One vertice in the edge (Q2). :: Outcome 2
         //   1  | 1    | 1  | 1  | No vertice in the surface. (inside the object) :: Outcome 1

         // Note QX = Quarter X. 0 (0%)..4 (100%) in the edge. 5..9 is 0..4 outside the edge.
         Value := 0;
         if FilledFaces[i] then
            inc(Value,8);
         if FilledEdges[FaceEdges[v1]] then
            inc(Value,4);
         if FilledVerts[FaceVerts[v1]] then
            inc(Value,2);
         if FilledVerts[FaceVerts[v2]] then
            inc(Value,1);
         EdgeSettings[i,p] := VertexOutcome[value];
         // Now let's add the vertices according to the outcome.
         if QuarterPerOutcomeIndexList[VertexOutcome[value],0] <> -1 then
         begin
            FaceHasVertices := true;
            // Add the first vertex.
            EdgeVertices[i,p,0] := AddVertex(_VertexMap,v0x + VertexQuarterPoints[i,p,QuarterPerOutcomeIndexList[VertexOutcome[value],0],0], v0y + VertexQuarterPoints[i,p,QuarterPerOutcomeIndexList[VertexOutcome[value],0],1], v0z + VertexQuarterPoints[i,p,QuarterPerOutcomeIndexList[VertexOutcome[value],0],2],_TotalNumVertices);
            if QuarterPerOutcomeIndexList[VertexOutcome[value],1] <> -1 then
            begin
               // Add the second vertex.
               EdgeVertices[i,p,1] := AddVertex(_VertexMap,v0x + VertexQuarterPoints[i,p,QuarterPerOutcomeIndexList[VertexOutcome[value],1],0], v0y + VertexQuarterPoints[i,p,QuarterPerOutcomeIndexList[VertexOutcome[value],1],1], v0z + VertexQuarterPoints[i,p,QuarterPerOutcomeIndexList[VertexOutcome[value],1],2],_TotalNumVertices);
            end;
         end;
      end;
      RegionHasVertices := RegionHasVertices or FaceHasVertices;
   end;


   Cube.Free;
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
