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
         // Constructors and Destructors
         constructor Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; _x, _y, _z : integer);
   end;

implementation

constructor TVoxelModelizerItem.Create(const _VoxelMap: TVoxelMap; const _SurfaceMap: T3DIntGrid; _x, _y, _z : integer);
const
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

   PointsPerVerts = 7;
var
   v1,v2,p,i,imax : integer;
   Cube : TNormals;
   CheckPoint : TVector3f;
   Point : TVector3i;
   VoxelClassification: single;
begin
   x := _x;
   y := _y;
   z := _z;

   Cube := TNormals.Create(6);
   // Check which vertices are in.
   i := 0;
   for p := 0 to 7 do
   begin
      FilledVerts[p] := true;
      imax := i + 7;
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
      FilledEdges[p] := true;
      imax := i + 3;
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
   i := 0;
   for p := 0 to 5 do
   begin
      CheckPoint := Cube[EdgeCheck[p]];
      Point.X := x + Round(CheckPoint.X);
      Point.Y := y + Round(CheckPoint.Y);
      Point.Z := z + Round(CheckPoint.Z);
      VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
      FilledEdges[p] := VoxelClassification >= C_SURFACE;
   end;

   // Let's analyse the situation for each edge.
   // First, split the cube into 6 faces. Each face has 4 edges.
   // FaceVerts has (topright, bottomright, bottomleft, topleft) for each face
   // FaceEdges has (right, bottomt, left, top) for each face.
   for i := 0 to 5 do // for each face
   begin
      for p := 0 to 3 do // for each edge from the face i
      begin
         v1 := p * i; // vertice 1 and edge index
         v2 := ((p + 1) mod 4) * i; // vertice 2 index
         // We have the following cases:
         // Edge | V1 | V2 | Outcome:
         //   0  | 0  | 0  | No vertice in the surface. (outside the object)
         //   0  | 0  | 1  | One vertice out of the edge.
         //   0  | 1  | 0  | One vertice out of the edge.
         //   0  | 1  | 1  | No vertice in the surface. <---???
         //   1  | 0  | 0  | Two vertices in the edge.
         //   1  | 0  | 1  | One vertice in the edge.
         //   1  | 1  | 0  | One vertice in the edge.
         //   1  | 1  | 1  | No vertice in the surface. <---??? (inside the object)


      end;
   end;


   Cube.Free;
end;

end.
