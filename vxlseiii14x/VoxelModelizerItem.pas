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
         CubeSettings: array[0..5,0..3] of byte;
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

   PointsPerVerts = 7;
var
   vert,i,imax : integer;
   Cube : TNormals;
   CheckPoint : TVector3f;
   Point : TVector3i;
   VoxelClassification: single;
begin
   x := _x;
   y := _y;
   z := _z;

   Cube := TNormals.Create(6);
   // Check if all vertices are in.
   i := 0;
   for vert := 0 to 7 do
   begin
      imax := i + 7;
      while i < imax do
      begin
         CheckPoint := Cube[VerticeCheck[i]];
         Point.X := x + Round(CheckPoint.X);
         Point.Y := y + Round(CheckPoint.Y);
         Point.Z := z + Round(CheckPoint.Z);
         VoxelClassification := _VoxelMap.MapSafe[Point.X,Point.Y,Point.Z];
         FilledVerts[vert] := VoxelClassification >= C_SURFACE;
         if not FilledVerts[vert] then
         begin
            if VoxelClassification = C_SEMI_SURFACE then
            begin
               if _SurfaceMap[Point.X,Point.Y,Point.Z] and SSVerticesCheck[i] <> 0  then
               begin
                  FilledVerts[vert] := true;
               end;
            end;
         end;
         inc(i);
      end;
   end;

   Cube.Free;
end;

end.
