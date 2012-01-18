unit ClassInterpolationTrianglesSupporter;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, ClassVertexList, ClassTriangleList, ClassQuadList,
   Normals, Windows, ClassMeshNormalsTool;

type
   CInterpolationTrianglesSupporter = class
      public
         // Initialize
         procedure InitializeNeighbourVertexIDsSize3(var _NeighbourVertexIDs: T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer);
         procedure InitializeNeighbourVertexIDsSize4(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer);

         // Add side faces.
         procedure AddLeftFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddRightFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddBackFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddFrontFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddBottomFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
         procedure AddTopFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);

         // Misc
         procedure AddInterpolationFaces(_LeftBottomFront,_LeftBottomBack,_LeftTopFront,_LeftTopBack,_RightBottomFront,_RightBottomBack,_RightTopFront,_RightTopBack,_FaceFilledConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; _Color: cardinal);
         function GetColour(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
         procedure AddInterpolationFacesFor4x4Regions(const _Voxel : TVoxelSection; const _Palette: TPalette; const _NeighbourVertexIDs: T3DIntGrid; _x,_y,_z: integer; const _FaceConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList);
         procedure AddVertexToTarget (var _Target: integer; var _VertexList: CVertexList; var _PotentialID : longword; _x,_y,_z: single);
   end;

implementation

procedure CInterpolationTrianglesSupporter.InitializeNeighbourVertexIDsSize3(var _NeighbourVertexIDs: T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer);
begin
   _NeighbourVertexIDs[0,0,0] := _VertexMap.Data[_x,_y,_z];
   _NeighbourVertexIDs[0,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,0,2] := _VertexMap.Data[_x,_y,_z+1];
   _NeighbourVertexIDs[0,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,0] := _VertexMap.Data[_x,_y+1,_z];
   _NeighbourVertexIDs[0,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,2] := _VertexMap.Data[_x,_y+1,_z+1];
   _NeighbourVertexIDs[1,0,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[1,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,0] := _VertexMap.Data[_x+1,_y,_z];
   _NeighbourVertexIDs[2,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,0,2] := _VertexMap.Data[_x+1,_y,_z+1];
   _NeighbourVertexIDs[2,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,0] := _VertexMap.Data[_x+1,_y+1,_z];
   _NeighbourVertexIDs[2,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[2,2,2] := _VertexMap.Data[_x+1,_y+1,_z+1];
end;

procedure CInterpolationTrianglesSupporter.InitializeNeighbourVertexIDsSize4(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer);
begin
   _NeighbourVertexIDs[0,0,0] := _VertexMap.Data[_x,_y,_z];
   _NeighbourVertexIDs[0,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,0,3] := _VertexMap.Data[_x,_y,_z+1];
   _NeighbourVertexIDs[0,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,1,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,2,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,3,0] := _VertexMap.Data[_x,_y+1,_z];
   _NeighbourVertexIDs[0,3,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,3,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[0,3,3] := _VertexMap.Data[_x,_y+1,_z+1];
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
   _NeighbourVertexIDs[3,0,0] := _VertexMap.Data[_x+1,_y,_z];
   _NeighbourVertexIDs[3,0,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,0,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,0,3] := _VertexMap.Data[_x+1,_y,_z+1];
   _NeighbourVertexIDs[3,1,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,1,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,1,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,1,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,0] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,2,3] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,3,0] := _VertexMap.Data[_x+1,_y+1,_z];
   _NeighbourVertexIDs[3,3,1] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,3,2] := C_VMG_NO_VERTEX;
   _NeighbourVertexIDs[3,3,3] := _VertexMap.Data[_x+1,_y+1,_z+1];
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

procedure CInterpolationTrianglesSupporter.AddInterpolationFaces(_LeftBottomFront,_LeftBottomBack,_LeftTopFront,_LeftTopBack,_RightBottomFront,_RightBottomBack,_RightTopFront,_RightTopBack,_FaceFilledConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; _Color: cardinal);
const
   QuadSet: array[1..36,0..3] of byte = ((0,1,5,4),(0,1,5,6),(0,1,7,4),(0,1,7,6),(0,2,3,1),(0,2,7,5),(0,3,5,4),(0,3,7,4),(0,3,7,5),(0,4,6,2),(0,4,6,3),(0,4,7,2),(0,4,7,3),(0,5,6,2),(0,5,7,2),(0,5,7,3),(0,6,7,1),(0,6,7,3),(1,2,6,5),(1,2,6,7),(1,2,7,5),(1,3,6,4),(1,3,6,5),(1,3,7,5),(1,4,2,3),(1,4,6,2),(1,4,6,3),(1,5,4,2),(1,5,6,2),(1,6,4,7),(2,4,3,7),(2,4,5,3),(2,4,7,3),(2,6,5,3),(2,6,7,3),(4,5,7,6));
   QuadFaces: array[1..36] of shortint = (2,-1,-1,-1,0,-1,-1,-1,-1,4,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,5,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,3,1);
   QuadConfigStart: array[0..255] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,9,9,9,9,9,9,10,10,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,16,16,16,16,17,17,17,17,20,20,20,20,23,23,26,26,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,34,34,34,34,34,34,34,34,34,34,34,34,35,35,35,36,39,39,39,39,40,40,40,40,43,43,43,44,47,47,47,50,54,54,54,54,54,54,54,54,54,54,54,54,54,54,55,56,59,59,59,59,59,59,60,60,63,63,63,63,63,64,67,70,74,74,74,74,74,74,74,74,74,74,74,75,78,78,81,84,88,88,89,90,93,94,97,100,104,105,108,111,115,118,122,126);
   QuadConfigData: array[0..125] of byte = (36,36,35,35,32,36,35,36,24,24,27,36,24,20,36,28,35,29,35,24,35,25,30,24,31,28,24,36,35,26,36,11,36,16,10,10,10,36,6,5,35,14,9,10,35,10,8,34,10,7,10,36,35,7,1,1,36,1,17,24,2,24,18,1,1,24,13,11,23,1,24,1,36,18,10,34,10,7,12,1,21,10,1,19,10,1,36,20,5,5,35,5,4,5,24,5,15,34,5,2,35,24,5,2,5,33,5,3,10,5,22,35,5,10,3,1,5,32,10,5,1,34,1,5,24,35);
   TriangleSet: array[1..68,0..2] of byte = ((0,1,4),(0,1,5),(0,1,6),(0,2,1),(0,2,3),(0,2,5),(0,2,7),(0,3,1),(0,3,2),(0,3,4),(0,4,2),(0,4,3),(0,4,6),(0,4,7),(0,5,2),(0,5,4),(0,5,7),(0,6,1),(0,6,2),(0,6,7),(0,7,1),(0,7,2),(0,7,3),(0,7,5),(1,2,3),(1,2,6),(1,3,2),(1,3,4),(1,3,5),(1,3,6),(1,3,7),(1,4,3),(1,4,5),(1,4,6),(1,5,4),(1,5,6),(1,5,7),(1,6,2),(1,6,3),(1,6,4),(1,6,5),(1,6,7),(1,7,5),(1,7,6),(2,3,4),(2,3,5),(2,4,3),(2,4,6),(2,5,3),(2,5,4),(2,5,7),(2,6,3),(2,6,5),(2,6,7),(2,7,3),(3,4,5),(3,4,6),(3,4,7),(3,5,4),(3,6,4),(3,6,7),(3,7,5),(3,7,6),(4,5,6),(4,5,7),(4,7,5),(4,7,6),(5,7,6));
   TriConfigStart: array[0..255] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,8,8,8,8,8,8,8,8,12,12,12,12,16,16,16,16,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,22,22,22,22,22,22,22,22,26,26,26,26,26,26,30,30,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,34,34,34,34,38,38,38,38,40,40,40,40,42,42,44,44,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,52,52,52,52,52,52,52,52,52,52,52,52,56,56,56,60,62,62,62,62,66,66,66,66,68,68,68,72,74,74,74,76,78,78,78,78,78,78,78,78,78,78,78,78,78,78,82,86,88,88,88,88,88,88,92,92,94,94,94,94,94,98,100,102,104,104,104,104,104,104,104,104,104,104,104,108,110,110,112,114,116,116,120,124,126,130,132,134,136,140,142,144,146,148,150,152);
   TriConfigData: array[0..151] of byte = (57,62,61,59,51,48,54,49,46,68,62,53,58,48,67,45,48,62,42,35,34,43,36,63,39,68,58,35,65,32,61,35,48,37,44,25,31,38,68,25,48,31,67,27,33,25,20,24,16,13,16,61,7,14,67,54,6,16,64,53,54,16,19,18,30,52,68,5,52,9,10,60,67,8,64,4,62,5,43,66,14,21,13,18,41,64,13,43,8,2,17,23,68,8,8,29,56,12,65,8,64,8,8,13,4,1,40,26,64,5,4,65,64,4,43,4,31,21,22,55,39,3,19,52,19,31,29,2,15,49,55,2,19,29,68,19,11,1,28,47,11,31,52,1,67,31,11,29,64,29,65,11);
var
   Vertexes: array [0..7] of integer;
   AllowedFaces: array[0..5] of boolean;
   i,Config,Mult2: byte;
begin
   // Fill vertexes.
   Vertexes[0] := _LeftBottomFront;
   Vertexes[1] := _LeftBottomBack;
   Vertexes[2] := _LeftTopFront;
   Vertexes[3] := _LeftTopBack;
   Vertexes[4] := _RightBottomFront;
   Vertexes[5] := _RightBottomBack;
   Vertexes[6] := _RightTopFront;
   Vertexes[7] := _RightTopBack;
   // Fill faces.
   AllowedFaces[0] := (_FaceFilledConfig and 32) = 0; // left (x-1)
   AllowedFaces[1] := (_FaceFilledConfig and 16) = 0; // right (x+1)
   AllowedFaces[2] := (_FaceFilledConfig and 8) = 0;  // bottom (y-1)
   AllowedFaces[3] := (_FaceFilledConfig and 4) = 0;  // top (y+1)
   AllowedFaces[4] := (_FaceFilledConfig and 2) = 0;  // front (z-1)
   AllowedFaces[5] := (_FaceFilledConfig and 1) = 0;  // back (z+1)
   // Find out vertex configuration
   Config := 0;
   Mult2 := 1;
   for i := 0 to 7 do
   begin
      if Vertexes[i] <> C_VMG_NO_VERTEX then
      begin
         Config := Config or Mult2;
      end;
      Mult2 := Mult2 * 2;
   end;
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
   while i < TriConfigStart[config+1] do // config will always be below 255
   begin
      // Add face.
      _TriangleList.Add(Vertexes[TriangleSet[TriConfigData[i],0]],Vertexes[TriangleSet[TriConfigData[i],1]],Vertexes[TriangleSet[TriConfigData[i],2]],_Color);
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

end.
