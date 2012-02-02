unit ClassInterpolationTrianglesSupporter;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, ClassVertexList, ClassTriangleList, ClassQuadList,
   Normals, Windows, ClassMeshNormalsTool, Dialogs, SysUtils;

type
   CInterpolationTrianglesSupporter = class
      public
         // Initialize
         procedure InitializeNeighbourVertexIDsSize3(var _NeighbourVertexIDs: T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);
         procedure InitializeNeighbourVertexIDsSize4(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);
         procedure InitializeNeighbourVertexIDsSize(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);

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
         procedure DetectPotentialVertexes(const _Neighbours: T3DBooleanMap; const _VoxelMap: TVoxelMap; _x, _y, _z: integer);
         procedure AddInterpolationFacesFromRegions(const _Voxel : TVoxelSection; const _Palette: TPalette; const _Neighbours: T3DBooleanMap; var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList;  var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _NumVertices : longword; _x, _y, _z, _AllowedFaces: integer);
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

procedure CInterpolationTrianglesSupporter.InitializeNeighbourVertexIDsSize(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer; const _VertexTransformation: aint32);
var
   x,y,z: integer;
begin
   for x := 0 to 4 do
      for y := 0 to 4 do
         for z := 0 to 4 do
         begin
            _NeighbourVertexIDs[x,y,z] := C_VMG_NO_VERTEX;
         end;
   _NeighbourVertexIDs[0,0,0] := GetVertex(_VertexMap,_x,_y,_z,_VertexTransformation);
   _NeighbourVertexIDs[0,0,4] := GetVertex(_VertexMap,_x,_y,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[0,4,0] := GetVertex(_VertexMap,_x,_y+1,_z,_VertexTransformation);
   _NeighbourVertexIDs[0,4,4] := GetVertex(_VertexMap,_x,_y+1,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[4,0,0] := GetVertex(_VertexMap,_x+1,_y,_z,_VertexTransformation);
   _NeighbourVertexIDs[4,0,4] := GetVertex(_VertexMap,_x+1,_y,_z+1,_VertexTransformation);
   _NeighbourVertexIDs[4,4,0] := GetVertex(_VertexMap,_x+1,_y+1,_z,_VertexTransformation);
   _NeighbourVertexIDs[4,4,4] := GetVertex(_VertexMap,_x+1,_y+1,_z+1,_VertexTransformation);
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
   QuadSet: array[1..24,0..3] of byte = ((0,1,5,4),(0,2,3,1),(0,4,6,2),(1,3,7,5),(2,6,7,3),(4,5,7,6),(4,6,7,5),(2,3,7,6),(2,3,5,4),(1,5,7,3),(1,4,6,3),(1,5,6,2),(0,2,4,6),(0,2,7,5),(0,3,7,4),(0,4,5,1),(0,6,7,1),(0,4,7,3),(1,2,6,5),(0,1,3,2),(0,1,7,6),(0,5,7,2),(1,3,6,4),(2,4,5,3));
   QuadFaces: array[1..24] of shortint = (2,0,4,5,3,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
   QuadConfigStart: array[0..255] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,11,11,12,12,12,12,12,12,13,13,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,17,17,17,17,18,18,19,19,22,22,22,22,23,23,24,24,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,30,31,31,31,32,35,35,35,35,36,36,36,36,37,37,37,38,41,41,41,42,45,45,45,45,45,45,45,45,45,45,45,45,45,46,47,48,51,51,51,51,51,51,52,52,53,53,53,53,53,54,57,58,61,61,61,61,61,61,61,61,61,61,61,62,63,64,65,68,71,72,73,74,77,78,81,82,85,86,87,90,93,96,99,102);
   QuadConfigData: array[0..101] of byte = (7,6,6,8,5,5,5,6,9,6,10,4,4,4,6,11,6,5,4,4,5,12,5,4,4,5,6,6,6,13,3,3,3,6,14,5,5,3,3,5,15,3,3,5,6,16,1,1,1,6,17,4,4,1,1,4,18,1,1,4,6,3,3,1,1,1,3,19,1,3,6,20,2,2,2,5,21,2,2,4,22,2,2,4,5,2,2,2,3,23,2,3,5,1,2,24,1,2,4,1,2,3);

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
   if Config = 255 then   // this "if" is for debugging only.
      ShowMessage('Configuration is 255: Vertexes are: (' + IntToStr(Vertexes[0]) + ',' + IntToStr(Vertexes[1]) + ',' + IntToStr(Vertexes[2]) + ',' + IntToStr(Vertexes[3]) + ',' + IntToStr(Vertexes[4]) + ',' + IntToStr(Vertexes[5]) + ',' + IntToStr(Vertexes[6]) + ',' + IntToStr(Vertexes[7]) + ').');
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

{
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
}

   // Here we get an average of the colours of the neighbours of the region.
function CInterpolationTrianglesSupporter.GetColour(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
const
   CubeConfigStart: array[0..33] of byte = (0,1,4,7,10,13,20,27,34,41,42,45,46,49,50,53,54,57,58,61,64,67,70,77,84,91,98,115,132,149,166,183,200,226);
   CubeConfigData: array[0..225] of byte =  (0,0,1,11,0,2,15,0,3,13,0,4,9,0,2,4,5,9,14,15,0,1,3,6,11,12,13,0,2,4,7,9,15,16,0,1,4,8,9,10,11,9,9,10,11,11,11,12,13,13,13,14,15,15,9,15,16,17,11,17,18,15,17,19,13,17,20,9,17,21,10,13,15,17,19,20,22,11,12,13,17,18,20,23,9,15,16,17,19,21,24,9,10,11,17,18,21,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,4,7,8,9,10,11,15,16,17,18,19,21,24,25,0,1,2,3,5,6,11,12,13,14,15,17,18,19,20,22,23,0,2,3,4,5,7,9,13,14,15,16,17,19,20,21,22,24,0,1,3,4,6,8,9,10,11,12,13,17,18,20,21,23,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25);
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
      i := CubeConfigStart[_config];
      while i < CubeConfigStart[_config+1] do
      begin
         // add this colour.
         CurrentNormal := Cube[CubeConfigData[i]];
         _Voxel.GetVoxelSafe(Round(_x + CurrentNormal.X),Round(_y + CurrentNormal.Y),Round(_z + CurrentNormal.Z),v);
         if v.Used then
         begin
            r := r + GetRValue(_Palette[v.Colour]);
            g := g + GetGValue(_Palette[v.Colour]);
            b := b + GetBValue(_Palette[v.Colour]);
            inc(numColours);
         end;
         inc(i);
      end;
      if numColours > 0 then
      begin
         r := r / numColours;
         g := g / numColours;
         b := b / numColours;
      end;
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

procedure CInterpolationTrianglesSupporter.DetectPotentialVertexes(const _Neighbours: T3DBooleanMap; const _VoxelMap: TVoxelMap; _x, _y, _z: integer);
const
   VertexSet: array[1..98,0..2] of byte = ((0,0,0),(0,0,1),(0,0,2),(0,0,3),(0,0,4),(0,1,0),(0,1,1),(0,1,2),(0,1,3),(0,1,4),(0,2,0),(0,2,1),(0,2,2),(0,2,3),(0,2,4),(0,3,0),(0,3,1),(0,3,2),(0,3,3),(0,3,4),(0,4,0),(0,4,1),(0,4,2),(0,4,3),(0,4,4),(1,0,0),(1,0,1),(1,0,2),(1,0,3),(1,0,4),(2,0,0),(2,0,1),(2,0,2),(2,0,3),(2,0,4),(3,0,0),(3,0,1),(3,0,2),(3,0,3),(3,0,4),(4,0,0),(4,0,1),(4,0,2),(4,0,3),(4,0,4),(1,1,4),(2,1,4),(3,1,4),(4,1,4),(1,2,4),(2,2,4),(3,2,4),(4,2,4),(1,3,4),(2,3,4),(3,3,4),(4,3,4),(1,4,4),(2,4,4),(3,4,4),(4,4,4),(1,4,0),(1,4,1),(1,4,2),(1,4,3),(2,4,0),(2,4,1),(2,4,2),(2,4,3),(3,4,0),(3,4,1),(3,4,2),(3,4,3),(4,4,0),(4,4,1),(4,4,2),(4,4,3),(1,1,0),(2,1,0),(3,1,0),(4,1,0),(1,2,0),(2,2,0),(3,2,0),(4,2,0),(1,3,0),(2,3,0),(3,3,0),(4,3,0),(4,1,1),(4,1,2),(4,1,3),(4,2,1),(4,2,2),(4,2,3),(4,3,1),(4,3,2),(4,3,3));
   VertexConfigStart: array[0..26] of byte = (0,25,30,35,40,45,46,47,48,49,74,79,104,109,134,139,164,169,194,199,204,209,214,215,216,217,218);
   VertexConfigData: array[0..217] of byte = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,5,10,15,20,25,1,6,11,16,21,21,22,23,24,25,1,2,3,4,5,21,25,1,5,1,2,3,4,5,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,5,30,35,40,45,5,30,35,40,45,10,46,47,48,49,15,50,51,52,53,20,54,55,56,57,25,58,59,60,61,25,58,59,60,61,21,22,23,24,25,62,63,64,65,58,66,67,68,69,59,70,71,72,73,60,74,75,76,77,61,21,62,66,70,74,1,26,31,36,41,6,78,79,80,81,11,82,83,84,85,16,86,87,88,89,21,62,66,70,74,1,26,31,36,41,41,42,43,44,45,81,90,91,92,49,85,93,94,95,53,89,96,97,98,57,74,75,76,77,61,45,49,53,57,61,41,81,85,89,74,74,75,76,77,61,41,42,43,44,45,74,61,41,45);
var
   Cube : TNormals;
   i,j,k,maxi: integer;
   CurrentNormal : TVector3f;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      // Fill _Neighbours with false.
      for i := 0 to 4 do
         for j := 0 to 4 do
            for k := 0 to 4 do
            begin
               _Neighbours[i,j,k] := false;
            end;

      // Now we fill the other potential vertexes with the value they deserve.
      i := 0;
      while i <= maxi do
      begin
         CurrentNormal := Cube[i];
         if _VoxelMap.MapSafe[_x + Round(CurrentNormal.X),_y + Round(CurrentNormal.Y),_z + Round(CurrentNormal.Z)] > 256 then
         begin
            j := VertexConfigStart[i];
            while j < VertexConfigStart[i+1] do
            begin
               _Neighbours[VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2]] := true;
               inc(j);
            end;
         end;
         inc(i);
      end;
   end;
   Cube.Free;
end;

procedure CInterpolationTrianglesSupporter.AddInterpolationFacesFromRegions(const _Voxel : TVoxelSection; const _Palette: TPalette; const _Neighbours: T3DBooleanMap; var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList;  var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _NumVertices : longword; _x, _y, _z, _AllowedFaces: integer);
const
   VertexSet: array[1..125,0..2] of byte = ((0,0,0),(0,0,4),(0,4,0),(0,4,4),(2,0,0),(2,0,4),(2,4,0),(2,4,4),(4,0,0),(4,0,4),(4,4,0),(4,4,4),(0,2,0),(0,2,4),(4,2,0),(4,2,4),(0,0,2),(0,4,2),(4,0,2),(4,4,2),(0,0,1),(0,1,0),(0,1,1),(1,0,0),(1,0,1),(1,1,0),(1,1,1),(0,2,1),(1,2,0),(1,2,1),(0,3,0),(0,3,1),(1,3,0),(1,3,1),(0,4,1),
      (1,4,0),(1,4,1),(0,1,2),(1,0,2),(1,1,2),(0,2,2),(1,2,2),(0,3,2),(1,3,2),(1,4,2),(0,0,3),(0,1,3),(1,0,3),(1,1,3),(0,2,3),(1,2,3),(0,3,3),(1,3,3),(0,4,3),(1,4,3),(0,1,4),(1,0,4),(1,1,4),(1,2,4),(0,3,4),(1,3,4),(1,4,4),(2,0,1),(2,1,0),(2,1,1),(2,2,0),(2,2,1),(2,3,0),(2,3,1),(2,4,1),(2,0,2),(2,1,2),(2,2,2),(2,3,2),(2,4,2),(2,0,3),(2,1,3),(2,2,3),(2,3,3),(2,4,3),(2,1,4),(2,2,4),(2,3,4),(3,0,0),(3,0,1),(3,1,0),(3,1,1),(3,2,0),(3,2,1),(3,3,0),(3,3,1),(3,4,0),(3,4,1),(3,0,2),(3,1,2),(3,2,2),(3,3,2),(3,4,2),(3,0,3),(3,1,3),(3,2,3),(3,3,3),(3,4,3),(3,0,4),(3,1,4),(3,2,4),(3,3,4),(3,4,4),(4,0,1),(4,1,0),(4,1,1),(4,2,1),(4,3,0),(4,3,1),(4,4,1),(4,1,2),(4,2,2),(4,3,2),(4,0,3),(4,1,3),(4,2,3),(4,3,3),(4,4,3),(4,1,4),(4,3,4));
   VertexConfigStart: array[0..70] of integer = (0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168,176,184,192,200,208,216,224,232,240,248,256,264,272,280,288,296,304,312,320,328,336,344,352,360,368,376,384,392,400,408,416,424,432,440,448,456,464,472,480,488,496,504,512,520,528,536,544,552,560);
   VertexConfigData: array[0..559] of byte = (1,2,3,4,5,6,7,8,5,6,7,8,9,10,11,12,1,2,13,14,9,10,15,16,13,14,3,4,15,16,11,12,1,17,3,18,9,19,11,20,17,2,18,4,19,10,20,12,1,21,22,23,24,25,26,27,22,23,13,28,26,27,29,30,13,28,31,32,29,30,33,34,31,32,3,35,33,34,36,37,21,17,23,38,25,39,27,40,23,38,28,41,27,40,30,42,28,41,32,43,30,42,34,44,32,43,35,18,34,44,37,45,17,46,38,47,39,48,40,49,38,47,41,50,40,49,42,51,41,50,43,52,42,51,44,53,43,52,18,54,44,53,45,55,46,2,47,56,48,57,49,58,47,56,50,14,49,58,51,59,50,14,52,60,51,59,53,61,52,60,54,4,53,61,55,62,24,25,26,27,5,63,64,65,26,27,29,30,64,65,66,67,29,30,33,34,66,67,68,69,33,34,36,37,68,69,7,70,25,39,27,40,63,71,65,72,27,40,30,42,65,72,67,73,30,42,34,44,67,73,69,74,34,44,37,45,69,
      74,70,75,39,48,40,49,71,76,72,77,40,49,42,51,72,77,73,78,42,51,44,53,73,78,74,79,44,53,45,55,74,79,75,80,48,57,49,58,76,6,77,81,49,58,51,59,77,81,78,82,51,59,53,61,78,82,79,83,53,61,55,62,79,83,80,8,5,63,64,65,84,85,86,87,64,65,66,67,86,87,88,89,66,67,68,69,88,89,90,91,68,69,7,70,90,91,92,93,63,71,65,72,85,94,87,95,65,72,67,73,87,95,89,96,67,73,69,74,89,96,91,97,69,74,70,75,91,97,93,98,71,76,72,77,94,99,95,100,72,77,73,78,95,100,96,101,73,78,74,79,96,101,97,102,74,79,75,80,97,102,98,103,76,6,77,81,99,104,100,105,77,81,78,82,100,105,101,106,78,82,79,83,101,106,102,107,79,83,80,8,102,107,103,108,84,85,86,87,9,109,110,111,86,87,88,89,110,111,15,112,88,89,90,91,15,112,113,114,90,91,92,93,113,114,11,115,85,94,87,95,109,
      19,111,116,87,95,89,96,111,116,112,117,89,96,91,97,112,117,114,118,91,97,93,98,114,118,115,20,94,99,95,100,19,119,116,120,95,100,96,101,116,120,117,121,96,101,97,102,117,121,118,122,97,102,98,103,118,122,20,123,99,104,100,105,119,10,120,124,100,105,101,106,120,124,121,16,101,106,102,107,121,16,122,125,102,107,103,108,122,125,123,12);
   FaceConfigLimits: array[0..69] of integer = (47,31,59,55,62,61,42,34,34,38,40,32,32,36,40,32,32,36,41,33,33,37,10,2,2,6,8,0,0,4,8,0,0,4,9,1,1,5,10,2,2,6,8,0,0,4,8,0,0,4,9,1,1,5,26,18,18,22,24,16,16,20,24,16,16,20,25,17,17,21);
   FaceColorConfig: array[0..69]of byte = (26,27,28,29,30,31,7,2,2,5,4,0,0,3,4,0,0,3,8,1,1,6,16,15,15,14,9,32,32,13,9,32,32,13,10,11,11,12,16,15,15,14,9,32,32,13,9,32,32,13,10,11,11,12,14,19,19,22,21,17,17,20,21,17,17,20,25,18,18,23);
   SubdivisionStart: array[0..4] of byte = (0,2,4,6,70);
var
   i,j, subdivisionMode: integer;
   Subdivide,ConfigIs255: boolean;
begin
   // First of all, we figure out how the region will be subdivided. There are 4
   // possible ways and we must ensure that every sub-region will not have a 255
   // config.
   Subdivide := false;
   subdivisionMode := 0;
   while (not subdivide) and (subdivisionMode < 3) do
   begin
      i := SubdivisionStart[subdivisionMode];
      while i < SubdivisionStart[subdivisionMode+1] do
      begin
         // Here we check each region.

         // if all vertexes exist, then we skip to the next subdivision mode.
         ConfigIs255 := true; // assume true just to make things easier.
         j := VertexConfigStart[i];
         while j < VertexConfigStart[i+1] do
         begin
            ConfigIs255 := ConfigIs255 and _Neighbours[VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2]];
            inc(j);
         end;
         if ConfigIs255 then
         begin
            i := SubdivisionStart[subdivisionMode+1];
         end
         else
            inc(i);
      end;
      if ConfigIs255 then
         inc(subdivisionMode)
      else
         subdivide := true;
   end;

   // Now we have to create the new vertexes.
   i := SubdivisionStart[subdivisionMode];
   while i < SubdivisionStart[subdivisionMode+1] do
   begin
      j := VertexConfigStart[i];
      while j < VertexConfigStart[i+1] do
      begin
         if _Neighbours[VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2]] then
         begin
            AddVertexToTarget(_NeighbourVertexIDs[VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2]],_VertexList,_NumVertices,_x+(0.25*VertexSet[VertexConfigData[j],0]),_y+(0.25*VertexSet[VertexConfigData[j],1]),_z+(0.25*VertexSet[VertexConfigData[j],2]));
         end;
         inc(j);
      end;
      inc(i);
   end;

   // Then we finally add the interpolation zones.
   i := SubdivisionStart[subdivisionMode];
   while i < SubdivisionStart[subdivisionMode+1] do
   begin
      j := VertexConfigStart[i];
      AddInterpolationFaces(_NeighbourVertexIDs[VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2]],_NeighbourVertexIDs[VertexSet[VertexConfigData[j+1],0],VertexSet[VertexConfigData[j+1],1],VertexSet[VertexConfigData[j+1],2]],_NeighbourVertexIDs[VertexSet[VertexConfigData[j+2],0],VertexSet[VertexConfigData[j+2],1],VertexSet[VertexConfigData[j+2],2]],_NeighbourVertexIDs[VertexSet[VertexConfigData[j+3],0],VertexSet[VertexConfigData[j+3],1],VertexSet[VertexConfigData[j+3],2]],_NeighbourVertexIDs[VertexSet[VertexConfigData[j+4],0],VertexSet[VertexConfigData[j+4],1],VertexSet[VertexConfigData[j+4],2]],_NeighbourVertexIDs[VertexSet[VertexConfigData[j+5],0],VertexSet[VertexConfigData[j+5],1],VertexSet[VertexConfigData[j+5],2]],_NeighbourVertexIDs[VertexSet[VertexConfigData[j+6],0],VertexSet[VertexConfigData[j+6],1],VertexSet[VertexConfigData[j+6],2]],
         _NeighbourVertexIDs[VertexSet[VertexConfigData[j+7],0],VertexSet[VertexConfigData[j+7],1],VertexSet[VertexConfigData[j+7],2]],_AllowedFaces and FaceConfigLimits[i],_TriangleList,_QuadList,GetColour(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[i]));
      inc(i);
   end;
end;

end.
