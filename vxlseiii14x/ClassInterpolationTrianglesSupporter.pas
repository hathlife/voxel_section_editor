unit ClassInterpolationTrianglesSupporter;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, ClassVertexList, ClassTriangleList, ClassQuadList,
   Normals, Windows, ClassMeshNormalsTool;

type
   CInterpolationTrianglesSupporter = class
      public
         // Initialize
         procedure InitializeNeighbourVertexIDsSize3(var _NeighbourVertexIDs: T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);
         procedure InitializeNeighbourVertexIDsSize4(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);

         // Add side faces.
         procedure AddLeftFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddRightFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddBackFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddFrontFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddBottomFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddTopFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);

         // Misc
         procedure AddInterpolationFaces(_LeftBottomBack,_LeftBottomFront,_LeftTopBack,_LeftTopFront,_RightBottomBack,_RightBottomFront,_RightTopBack,_RightTopFront,_FaceFilledConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; _Color: cardinal);
         function GetColour(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
         procedure AddInterpolationFacesFor4x4Regions(const _Voxel : TVoxelSection; const _Palette: TPalette; const _NeighbourVertexIDs: T3DIntGrid; _x,_y,_z: integer; const _FaceConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList);
         procedure AddVertexToTarget (var _Target: integer; var _VertexList: CVertexList; var _PotentialID : longword; _x,_y,_z: single);
         function GetVertex(const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32): integer;
   end;

implementation

procedure CInterpolationTrianglesSupporter.InitializeNeighbourVertexIDsSize3(var _NeighbourVertexIDs: T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);
begin
   _NeighbourVertexIDs[0,0,0] := GetVertex(_VertexMap,_x,_y,_z,_VertexTransformation);
   _NeighbourVertexIDs[0,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,0,2] := GetVertex(_VertexMap,_x,_y,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[0,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,0] := GetVertex(_VertexMap,_x,_y+1,_z,_VertexTransformation);
   _NeighbourVertexIDs[0,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,2] := GetVertex(_VertexMap,_x,_y+1,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[1,0,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,0] := GetVertex(_VertexMap,_x+1,_y,_z,_VertexTransformation);
   _NeighbourVertexIDs[2,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,2] := GetVertex(_VertexMap,_x+1,_y,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[2,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,0] := GetVertex(_VertexMap,_x+1,_y+1,_z,_VertexTransformation);
   _NeighbourVertexIDs[2,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,2] := GetVertex(_VertexMap,_x+1,_y+1,_z+1,_VertexTransformation);
end;

procedure CInterpolationTrianglesSupporter.InitializeNeighbourVertexIDsSize4(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);
begin
   _NeighbourVertexIDs[0,0,0] := GetVertex(_VertexMap,_x,_y,_z,_VertexTransformation);
   _NeighbourVertexIDs[0,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,0,3] := GetVertex(_VertexMap,_x,_y,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[0,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,3,0] := GetVertex(_VertexMap,_x,_y+1,_z,_VertexTransformation);
   _NeighbourVertexIDs[0,3,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,3,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,3,3] := GetVertex(_VertexMap,_x,_y+1,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[1,0,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,3,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,3,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,3,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,3,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,3,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,3,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,3,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,3,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,0,0] := GetVertex(_VertexMap,_x+1,_y,_z,_VertexTransformation);
   _NeighbourVertexIDs[3,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,0,3] := GetVertex(_VertexMap,_x+1,_y,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[3,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,1,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,3,0] := GetVertex(_VertexMap,_x+1,_y+1,_z,_VertexTransformation);
   _NeighbourVertexIDs[3,3,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,3,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,3,3] := GetVertex(_VertexMap,_x+1,_y+1,_z+1,_VertexTransformation);
end;

procedure CInterpolationTrianglesSupporter.AddLeftFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
begin
   AddVertexToTarget(_NeighbourVertexIDs[0,1,0],_VertexList,_NumVertices,_x,_y+0.33,_z);
   AddVertexToTarget(_NeighbourVertexIDs[0,2,0],_VertexList,_NumVertices,_x,_y+0.66,_z);
   AddVertexToTarget(_NeighbourVertexIDs[0,0,1],_VertexList,_NumVertices,_x,_y,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[0,1,1],_VertexList,_NumVertices,_x,_y+0.33,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[0,2,1],_VertexList,_NumVertices,_x,_y+0.66,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[0,3,1],_VertexList,_NumVertices,_x,_y+1,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[0,0,2],_VertexList,_NumVertices,_x,_y,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[0,1,2],_VertexList,_NumVertices,_x,_y+0.33,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[0,2,2],_VertexList,_NumVertices,_x,_y+0.66,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[0,3,2],_VertexList,_NumVertices,_x,_y+1,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[0,1,3],_VertexList,_NumVertices,_x,_y+0.33,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[0,2,3],_VertexList,_NumVertices,_x,_y+0.66,_z+1);
end;

procedure CInterpolationTrianglesSupporter.AddRightFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
begin
   AddVertexToTarget(_NeighbourVertexIDs[3,1,0],_VertexList,_NumVertices,_x+1,_y+0.33,_z);
   AddVertexToTarget(_NeighbourVertexIDs[3,2,0],_VertexList,_NumVertices,_x+1,_y+0.66,_z);
   AddVertexToTarget(_NeighbourVertexIDs[3,0,1],_VertexList,_NumVertices,_x+1,_y,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[3,1,1],_VertexList,_NumVertices,_x+1,_y+0.33,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[3,2,1],_VertexList,_NumVertices,_x+1,_y+0.66,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[3,3,1],_VertexList,_NumVertices,_x+1,_y+1,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[3,0,2],_VertexList,_NumVertices,_x+1,_y,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[3,1,2],_VertexList,_NumVertices,_x+1,_y+0.33,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[3,2,2],_VertexList,_NumVertices,_x+1,_y+0.66,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[3,3,2],_VertexList,_NumVertices,_x+1,_y+1,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[3,1,3],_VertexList,_NumVertices,_x+1,_y+0.33,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[3,2,3],_VertexList,_NumVertices,_x+1,_y+0.66,_z+1);
end;

procedure CInterpolationTrianglesSupporter.AddBackFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
begin
   AddVertexToTarget(_NeighbourVertexIDs[0,1,0],_VertexList,_NumVertices,_x,_y+0.33,_z);
   AddVertexToTarget(_NeighbourVertexIDs[0,2,0],_VertexList,_NumVertices,_x,_y+0.66,_z);
   AddVertexToTarget(_NeighbourVertexIDs[1,0,0],_VertexList,_NumVertices,_x+0.33,_y,_z);
   AddVertexToTarget(_NeighbourVertexIDs[1,1,0],_VertexList,_NumVertices,_x+0.33,_y+0.33,_z);
   AddVertexToTarget(_NeighbourVertexIDs[1,2,0],_VertexList,_NumVertices,_x+0.33,_y+0.66,_z);
   AddVertexToTarget(_NeighbourVertexIDs[1,3,0],_VertexList,_NumVertices,_x+0.33,_y+1,_z);
   AddVertexToTarget(_NeighbourVertexIDs[2,0,0],_VertexList,_NumVertices,_x+0.66,_y,_z);
   AddVertexToTarget(_NeighbourVertexIDs[2,1,0],_VertexList,_NumVertices,_x+0.66,_y+0.33,_z);
   AddVertexToTarget(_NeighbourVertexIDs[2,2,0],_VertexList,_NumVertices,_x+0.66,_y+0.66,_z);
   AddVertexToTarget(_NeighbourVertexIDs[2,3,0],_VertexList,_NumVertices,_x+0.66,_y+1,_z);
   AddVertexToTarget(_NeighbourVertexIDs[3,1,0],_VertexList,_NumVertices,_x+1,_y+0.33,_z);
   AddVertexToTarget(_NeighbourVertexIDs[3,2,0],_VertexList,_NumVertices,_x+1,_y+0.66,_z);
end;

procedure CInterpolationTrianglesSupporter.AddFrontFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
begin
   AddVertexToTarget(_NeighbourVertexIDs[0,1,3],_VertexList,_NumVertices,_x,_y+0.33,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[0,2,3],_VertexList,_NumVertices,_x,_y+0.66,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[1,0,3],_VertexList,_NumVertices,_x+0.33,_y,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[1,1,3],_VertexList,_NumVertices,_x+0.33,_y+0.33,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[1,2,3],_VertexList,_NumVertices,_x+0.33,_y+0.66,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[1,3,3],_VertexList,_NumVertices,_x+0.33,_y+1,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[2,0,3],_VertexList,_NumVertices,_x+0.66,_y,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[2,1,3],_VertexList,_NumVertices,_x+0.66,_y+0.33,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[2,2,3],_VertexList,_NumVertices,_x+0.66,_y+0.66,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[2,3,3],_VertexList,_NumVertices,_x+0.66,_y+1,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[3,1,3],_VertexList,_NumVertices,_x+1,_y+0.33,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[3,2,3],_VertexList,_NumVertices,_x+1,_y+0.66,_z+1);
end;

procedure CInterpolationTrianglesSupporter.AddBottomFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
begin
   AddVertexToTarget(_NeighbourVertexIDs[1,0,0],_VertexList,_NumVertices,_x+0.33,_y,_z);
   AddVertexToTarget(_NeighbourVertexIDs[2,0,0],_VertexList,_NumVertices,_x+0.66,_y,_z);
   AddVertexToTarget(_NeighbourVertexIDs[0,0,1],_VertexList,_NumVertices,_x,_y,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[1,0,1],_VertexList,_NumVertices,_x+0.33,_y,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[2,0,1],_VertexList,_NumVertices,_x+0.66,_y,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[3,0,1],_VertexList,_NumVertices,_x+1,_y,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[0,0,2],_VertexList,_NumVertices,_x,_y,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[1,0,2],_VertexList,_NumVertices,_x+0.33,_y,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[2,0,2],_VertexList,_NumVertices,_x+0.66,_y,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[3,0,2],_VertexList,_NumVertices,_x+1,_y,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[1,0,3],_VertexList,_NumVertices,_x+0.33,_y,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[2,0,3],_VertexList,_NumVertices,_x+0.66,_y,_z+1);
end;

procedure CInterpolationTrianglesSupporter.AddTopFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
begin
   AddVertexToTarget(_NeighbourVertexIDs[1,3,0],_VertexList,_NumVertices,_x+0.33,_y+1,_z);
   AddVertexToTarget(_NeighbourVertexIDs[2,3,0],_VertexList,_NumVertices,_x+0.66,_y+1,_z);
   AddVertexToTarget(_NeighbourVertexIDs[0,3,1],_VertexList,_NumVertices,_x,_y+1,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[1,3,1],_VertexList,_NumVertices,_x+0.33,_y+1,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[2,3,1],_VertexList,_NumVertices,_x+0.66,_y+1,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[3,3,1],_VertexList,_NumVertices,_x+1,_y+1,_z+0.33);
   AddVertexToTarget(_NeighbourVertexIDs[0,3,2],_VertexList,_NumVertices,_x,_y+1,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[1,3,2],_VertexList,_NumVertices,_x+0.33,_y+1,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[2,3,2],_VertexList,_NumVertices,_x+0.66,_y+1,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[3,3,2],_VertexList,_NumVertices,_x+1,_y+1,_z+0.66);
   AddVertexToTarget(_NeighbourVertexIDs[1,3,3],_VertexList,_NumVertices,_x+0.33,_y+1,_z+1);
   AddVertexToTarget(_NeighbourVertexIDs[2,3,3],_VertexList,_NumVertices,_x+0.66,_y+1,_z+1);
end;

procedure CInterpolationTrianglesSupporter.AddInterpolationFaces(_LeftBottomBack,_LeftBottomFront,_LeftTopBack,_LeftTopFront,_RightBottomBack,_RightBottomFront,_RightTopBack,_RightTopFront,_FaceFilledConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; _Color: cardinal);
const
   QuadSet: array[1..18,0..3] of byte = ((0,1,5,4),(0,2,3,1),(0,4,6,2),(1,3,7,5),(2,6,7,3),(4,5,7,6),(2,3,5,4),(1,4,6,3),(1,5,6,2),(0,2,7,5),(0,3,7,4),(0,6,7,1),(0,4,7,3),(1,2,6,5),(0,1,7,6),(0,5,7,2),(1,3,6,4),(2,4,5,3));
   QuadFaces: array[1..18] of shortint = (2,0,4,5,3,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
   QuadConfigStart: array[0..255] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,9,9,9,9,9,9,10,10,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,15,15,16,16,19,19,19,19,20,20,21,21,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,28,31,31,31,31,32,32,32,32,33,33,33,34,37,37,37,38,41,41,41,41,41,41,41,41,41,41,41,41,41,41,42,43,46,46,46,46,46,46,47,47,48,48,48,48,48,49,52,53,56,56,56,56,56,56,56,56,56,56,56,57,58,59,60,63,66,66,67,68,71,72,75,76,79,80,81,84,87,90,93,96);
   QuadConfigData: array[0..95] of byte = (6,6,5,5,5,6,7,6,4,4,4,6,8,6,5,4,4,5,9,5,4,4,5,6,6,6,3,3,3,6,10,5,5,3,3,5,11,3,3,5,6,1,1,1,6,12,4,4,1,1,4,13,1,1,4,6,3,3,1,1,1,3,14,1,3,6,2,2,2,5,15,2,2,4,16,2,2,4,5,2,2,2,3,17,2,3,5,1,2,18,1,2,4,1,2,3);
   TriangleSet: array[1..79,0..2] of byte = ((3,6,4),(3,6,7),(3,7,5),(2,4,5),(2,4,6),(2,6,7),(2,7,5),(2,3,5),(2,5,6),(5,7,6),(2,3,4),(3,7,4),(4,7,6),(1,4,6),(1,5,4),(1,6,7),(1,7,5),(1,5,6),(1,6,3),(1,4,3),(1,4,5),(3,4,7),(4,5,7),(1,2,7),(1,4,2),(1,2,3),(1,2,6),(1,3,7),(1,7,6),(1,5,2),(2,5,7),(2,7,3),(1,7,4),(1,3,2),(2,4,7),(0,4,6),(0,5,4),(0,6,7),(0,7,5),(0,3,5),(0,6,3),(0,2,7),(0,7,4),(0,2,5),(2,6,5),(4,5,6),(0,2,3),(0,3,7),(0,6,2),(0,7,6),(0,5,6),(0,3,4),(2,6,3),(3,6,5),(0,4,7),(0,7,1),(0,6,1),(1,6,5),(0,1,5),(0,3,1),(0,5,7),(0,7,3),(0,4,3),(1,3,5),(3,4,5),(0,1,4),(0,2,1),(1,6,4),(2,7,1),(0,4,2),(1,2,5),(0,1,7),(0,7,2),(0,1,6),(1,3,6),(0,5,2),(2,5,3),(1,3,4),(2,4,3));
   TriangleFaces: array[1..79] of shortint = (-1,3,5,-1,4,3,-1,-1,-1,1,-1,-1,1,-1,2,-1,5,-1,-1,-1,2,-1,1,-1,-1,0,-1,5,-1,-1,-1,3,-1,0,-1,4,2,-1,-1,-1,-1,-1,-1,-1,-1,1,0,-1,4,-1,-1,-1,3,-1,-1,-1,-1,-1,2,0,-1,-1,-1,5,-1,2,0,-1,-1,4,-1,-1,-1,-1,-1,-1,-1,-1,-1);
   TriConfigStart: array[0..255] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,8,8,8,8,8,8,8,8,12,12,12,12,16,16,16,16,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,22,22,22,22,22,22,22,22,26,26,26,26,26,26,30,30,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,38,38,38,38,42,42,46,46,48,48,48,48,54,54,60,60,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,74,74,74,74,74,74,74,74,74,74,74,74,78,78,78,82,84,84,84,84,88,88,88,88,94,94,94,98,100,100,100,106,110,110,110,110,110,110,110,110,110,110,110,110,110,110,114,118,120,120,120,120,120,120,124,124,130,130,130,130,130,134,136,142,146,146,146,146,146,146,146,146,146,146,146,150,156,160,166,168,172,172,176,180,182,186,188,194,198,202,208,210,214,216,220,224);
   TriConfigData: array[0..223] of byte = (1,2,3,4,5,6,7,8,9,10,3,11,12,5,13,14,5,3,15,16,17,18,19,20,2,10,21,22,23,24,15,2,25,26,15,17,5,6,27,28,29,30,26,31,32,33,26,10,26,28,25,34,5,13,35,25,15,36,32,13,26,25,15,5,37,38,39,40,41,36,37,42,2,3,43,44,6,13,45,37,46,47,37,6,48,49,50,51,47,40,52,49,3,10,47,53,54,1,47,13,47,40,37,53,55,46,47,40,37,3,56,57,17,23,36,58,59,46,36,17,60,61,62,63,59,60,51,41,2,10,60,64,65,66,60,23,60,36,41,64,54,46,60,36,41,2,67,68,27,69,66,67,33,6,70,13,67,71,72,4,67,70,71,35,69,23,67,46,67,24,17,6,73,74,28,32,75,49,76,53,49,28,59,77,64,78,59,32,59,51,49,64,53,54,59,51,49,10,66,70,79,80,66,70,28,33,35,32,66,53,66,28,33,13,70,64,70,35,32,23,64,53,54,46);
var
   Vertexes: array [0..7] of integer;
   AllowedFaces: array[0..5] of boolean;
   i,Config,Mult2: byte;
begin
   // Fill vertexes.
   Vertexes[0] := _LeftBottomBack;
   Vertexes[1] := _LeftBottomFront;
   Vertexes[2] := _LeftTopBack;
   Vertexes[3] := _LeftTopFront;
   Vertexes[4] := _RightBottomBack;
   Vertexes[5] := _RightBottomFront;
   Vertexes[6] := _RightTopBack;
   Vertexes[7] := _RightTopFront;
   // Fill faces.
   AllowedFaces[0] := (_FaceFilledConfig and 32) = 0; // left (x-1)
   AllowedFaces[1] := (_FaceFilledConfig and 16) = 0; // right (x+1)
   AllowedFaces[2] := (_FaceFilledConfig and 8) = 0;  // bottom (y-1)
   AllowedFaces[3] := (_FaceFilledConfig and 4) = 0;  // top (y+1)
   AllowedFaces[4] := (_FaceFilledConfig and 2) = 0;  // back (z-1)
   AllowedFaces[5] := (_FaceFilledConfig and 1) = 0;  // front (z+1)
   // Find out vertex configuration
   Config := 0;
   Mult2 := 1;
   for i := 0 to 7 do
   begin
      if Vertexes[i] <> C_VMG_NO_VERTEX then
      begin
         Config := Config + Mult2;
      end;
      Mult2 := Mult2 * 2;
   end;
   if Config = 255 then
      Config := 254;
   // Add the new quads.
   i := QuadConfigStart[config];
   while i < QuadConfigStart[config+1] do // config will always be below 255
   begin
      if (QuadFaces[QuadConfigData[i]] = -1) then
      begin
         // Add face.
         _QuadList.Add(Vertexes[QuadSet[QuadConfigData[i],0]],Vertexes[QuadSet[QuadConfigData[i],1]],Vertexes[QuadSet[QuadConfigData[i],2]],Vertexes[QuadSet[QuadConfigData[i],3]],_Color);
      end
      else if AllowedFaces[QuadFaces[QuadConfigData[i]]] then
      begin
         // This condition was splitted to avoid access violations.
         // Add face.
         _QuadList.Add(Vertexes[QuadSet[QuadConfigData[i],0]],Vertexes[QuadSet[QuadConfigData[i],1]],Vertexes[QuadSet[QuadConfigData[i],2]],Vertexes[QuadSet[QuadConfigData[i],3]],_Color);
      end;
      // else does not add face.
      inc(i);
   end;
   // Add the new triangles.
   i := TriConfigStart[config];
   while i < TriConfigStart[config+1] do // config will always be below 255
   begin
      if (TriangleFaces[TriConfigData[i]] = -1) then
      begin
         // Add face.
         _TriangleList.Add(Vertexes[TriangleSet[TriConfigData[i],0]],Vertexes[TriangleSet[TriConfigData[i],1]],Vertexes[TriangleSet[TriConfigData[i],2]],_Color);
      end
      else if AllowedFaces[TriangleFaces[TriConfigData[i]]] then
      begin
         // Add face.
         _TriangleList.Add(Vertexes[TriangleSet[TriConfigData[i],0]],Vertexes[TriangleSet[TriConfigData[i],1]],Vertexes[TriangleSet[TriConfigData[i],2]],_Color);
      end;
      inc(i);
   end;
end;

   // Here we get an average of the colours of the neighbours that have at least
   // one vertex in the _config parameter.
function CInterpolationTrianglesSupporter.GetColour(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
const
   CubeVertexBit: array [0..25] of byte = (15,10,5,12,3,4,8,1,2,51,34,170,136,204,68,85,17,240,160,80,192,48,64,128,16,32);
var
   Cube : TNormals;
   i,maxi : integer;
   r,g,b: single;
   numColours: integer;
   CurrentNormal : TVector3f;
   V : TVoxelUnpacked;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   r := 0;
   g := 0;
   b := 0;
   numColours := 0;
   if maxi > 0 then
   begin
      // visit all cubed neighbours
      i := 0;
      while i <= maxi do
      begin
         if CubeVertexBit[i] and _config <> 0 then
         begin
            // add this colour.
            CurrentNormal := Cube[i];
            _Voxel.GetVoxelSafe(Round(_x + CurrentNormal.X),Round(_y + CurrentNormal.Y),Round(_z + CurrentNormal.Z),v);
            if v.Used then
            begin
               r := r + GetRValue(_Palette[v.Colour]);
               g := g + GetGValue(_Palette[v.Colour]);
               b := b + GetBValue(_Palette[v.Colour]);
               inc(numColours);
            end;
         end;
         inc(i);
      end;
   end;
   if numColours > 0 then
   begin
      r := r / numColours;
      g := g / numColours;
      b := b / numColours;
   end;
   Result := RGB(Round(r),Round(b),Round(g));
   Cube.Free;
end;

procedure CInterpolationTrianglesSupporter.AddInterpolationFacesFor4x4Regions(const _Voxel : TVoxelSection; const _Palette: TPalette; const _NeighbourVertexIDs: T3DIntGrid; _x,_y,_z: integer; const _FaceConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList);
begin
   AddInterpolationFaces(_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_FaceConfig and 42,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,1));
   AddInterpolationFaces(_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[1,2,1],_FaceConfig and 34,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,5));
   AddInterpolationFaces(_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,3,0],_NeighbourVertexIDs[0,3,1],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,3,0],_NeighbourVertexIDs[1,3,1],_FaceConfig and 38,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,4));
   AddInterpolationFaces(_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_FaceConfig and 40,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,3));
   AddInterpolationFaces(_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,2,2],_FaceConfig and 32,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,15));
   AddInterpolationFaces(_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,3,1],_NeighbourVertexIDs[0,3,2],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[1,3,1],_NeighbourVertexIDs[1,3,2],_FaceConfig and 36,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,12));
   AddInterpolationFaces(_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,0,3],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,1,3],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,0,3],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,1,3],_FaceConfig and 41,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,2));
   AddInterpolationFaces(_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,1,3],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,2,3],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,1,3],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[1,2,3],_FaceConfig and 33,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,10));
   AddInterpolationFaces(_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,2,3],_NeighbourVertexIDs[0,3,2],_NeighbourVertexIDs[0,3,3],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[1,2,3],_NeighbourVertexIDs[1,3,2],_NeighbourVertexIDs[1,3,3],_FaceConfig and 37,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,8));
   AddInterpolationFaces(_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1],_FaceConfig and 10,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,17));
   AddInterpolationFaces(_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,2,1],_FaceConfig and 2,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,85));
   AddInterpolationFaces(_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,3,0],_NeighbourVertexIDs[1,3,1],_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,3,0],_NeighbourVertexIDs[2,3,1],_FaceConfig and 6,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,68));
   AddInterpolationFaces(_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,1,2],_FaceConfig and 8,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,51));
   AddInterpolationFaces(_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,2,2],0,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,255));
   AddInterpolationFaces(_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[1,3,1],_NeighbourVertexIDs[1,3,2],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,3,1],_NeighbourVertexIDs[2,3,2],_FaceConfig and 4,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,204));
   AddInterpolationFaces(_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,0,3],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,1,3],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,0,3],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,1,3],_FaceConfig and 9,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,34));
   AddInterpolationFaces(_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,1,3],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[1,2,3],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,1,3],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,2,3],_FaceConfig and 1,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,170));
   AddInterpolationFaces(_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[1,2,3],_NeighbourVertexIDs[1,3,2],_NeighbourVertexIDs[1,3,3],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,2,3],_NeighbourVertexIDs[2,3,2],_NeighbourVertexIDs[2,3,3],_FaceConfig and 5,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,136));
   AddInterpolationFaces(_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[3,0,0],_NeighbourVertexIDs[3,0,1],_NeighbourVertexIDs[3,1,0],_NeighbourVertexIDs[3,1,1],_FaceConfig and 26,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,16));
   AddInterpolationFaces(_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[3,1,0],_NeighbourVertexIDs[3,1,1],_NeighbourVertexIDs[3,2,0],_NeighbourVertexIDs[3,2,1],_FaceConfig and 18,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,80));
   AddInterpolationFaces(_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,3,0],_NeighbourVertexIDs[2,3,1],_NeighbourVertexIDs[3,2,0],_NeighbourVertexIDs[3,2,1],_NeighbourVertexIDs[3,3,0],_NeighbourVertexIDs[3,3,1],_FaceConfig and 22,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,64));
   AddInterpolationFaces(_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[3,0,1],_NeighbourVertexIDs[3,0,2],_NeighbourVertexIDs[3,1,1],_NeighbourVertexIDs[3,1,2],_FaceConfig and 24,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,48));
   AddInterpolationFaces(_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[3,1,1],_NeighbourVertexIDs[3,1,2],_NeighbourVertexIDs[3,2,1],_NeighbourVertexIDs[3,2,2],_FaceConfig and 16,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,240));
   AddInterpolationFaces(_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,3,1],_NeighbourVertexIDs[2,3,2],_NeighbourVertexIDs[3,2,1],_NeighbourVertexIDs[3,2,2],_NeighbourVertexIDs[3,3,1],_NeighbourVertexIDs[3,3,2],_FaceConfig and 20,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,192));
   AddInterpolationFaces(_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,0,3],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,1,3],_NeighbourVertexIDs[3,0,2],_NeighbourVertexIDs[3,0,3],_NeighbourVertexIDs[3,1,2],_NeighbourVertexIDs[3,1,3],_FaceConfig and 25,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,32));
   AddInterpolationFaces(_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,1,3],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,2,3],_NeighbourVertexIDs[3,1,2],_NeighbourVertexIDs[3,1,3],_NeighbourVertexIDs[3,2,2],_NeighbourVertexIDs[3,2,3],_FaceConfig and 17,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,160));
   AddInterpolationFaces(_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,2,3],_NeighbourVertexIDs[2,3,2],_NeighbourVertexIDs[2,3,3],_NeighbourVertexIDs[3,2,2],_NeighbourVertexIDs[3,2,3],_NeighbourVertexIDs[3,3,2],_NeighbourVertexIDs[3,3,3],_FaceConfig and 21,_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,128));
end;

procedure CInterpolationTrianglesSupporter.AddVertexToTarget (var _Target: integer; var _VertexList: CVertexList; var _PotentialID : longword; _x,_y,_z: single);
begin
   if _Target = C_VMG_NO_VERTEX then
   begin
      _Target := _VertexList.Add(_PotentialID,_x,_y,_z);
      if (_PotentialID = _Target) then
      begin
         inc(_PotentialID);
      end;
   end;
end;

function CInterpolationTrianglesSupporter.GetVertex(const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32): integer;
begin
   Result := _VertexMap.Data[_x,_y,_z];
   if Result <> C_VMG_NO_VERTEX then
   begin
      if _VertexTransformation[Result] <> Result then
         Result := C_VMG_NO_VERTEX;
   end;
end;


end.
