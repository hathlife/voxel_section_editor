unit RefinementTrianglesSupporter;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, VertexList, TriangleList, QuadList, Normals, Windows,
   MeshNormalsTool, Dialogs, SysUtils, VolumeFaceVerifier;

{$INCLUDE source/Global_Conditionals.inc}

type
   CRefinementTrianglesSupporter = class
      public
         // Initialize
         procedure InitializeNeighbourVertexIDsSize(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap; _x, _y, _z,_VUnit: integer; const _VertexTransformation: aint32; var _NumVertices: longword);

         // Misc
         procedure AddRefinementFaces(_LeftBottomBack,_LeftBottomFront,_LeftTopBack,_LeftTopFront,_RightBottomBack,_RightBottomFront,_RightTopBack,_RightTopFront,_FaceFilledConfig,_x,_y,_z: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _FaceVerifier: CVolumeFaceVerifier; _Color: cardinal);
         function GetColourRefinement(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
         function GetColourSurface(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
         function GetVertex(const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z,_reference,_VUnit: integer; var _NumVertices: longword; const _VoxelMap: TVoxelMap; const _VertexTransformation: aint32): integer;
         procedure DetectPotentialRefinementVertexes(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
         procedure DetectPotentialSurfaceVertexes(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
         procedure DetectPotentialRefinementVertexesOld(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
         procedure DetectPotentialSurfaceVertexesOld(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
         procedure AddRefinementFacesFromRegions(const _Voxel : TVoxelSection; const _Palette: TPalette; var _NeighbourVertexIDs: T3DIntGrid;  var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _FaceVerifier: CVolumeFaceVerifier; _x, _y, _z, _AllowedFaces, _VUnit: integer);
         procedure AddSurfaceFacesFromRegions(const _Voxel : TVoxelSection; const _Palette: TPalette; var _NeighbourVertexIDs: T3DIntGrid; var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _FaceVerifier: CVolumeFaceVerifier; _x, _y, _z, _AllowedFaces, _VUnit: integer);
         function HasMidFaceVertex(_vNE, _vNW, _vSW, _vSE, _vN, _vW, _vS, _vE, _vSelf: integer): boolean;
         function HasMidFaceVertexOnSurface(_vNE, _vNW, _vSW, _vSE, _vN, _vW, _vS, _vE, _vSelf: integer): boolean;
         procedure AddVertex(var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x,_y,_z,_xN,_yN,_zN: integer; var _NumVertices: longword);
   end;

implementation

uses GlobalVars;

procedure CRefinementTrianglesSupporter.InitializeNeighbourVertexIDsSize(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap; _x, _y, _z, _VUnit: integer; const _VertexTransformation: aint32; var _NumVertices: longword);
var
   x,y,z: integer;
begin
   for x := 0 to 2 do
      for y := 0 to 2 do
         for z := 0 to 2 do
         begin
            _NeighbourVertexIDs[x,y,z] := C_VMG_NO_VERTEX;
         end;
end;

procedure CRefinementTrianglesSupporter.AddRefinementFaces(_LeftBottomBack,_LeftBottomFront,_LeftTopBack,_LeftTopFront,_RightBottomBack,_RightBottomFront,_RightTopBack,_RightTopFront,_FaceFilledConfig,_x,_y,_z: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _FaceVerifier: CVolumeFaceVerifier; _Color: cardinal);
const
   QuadSet: array[1..18,0..3] of byte = ((0,4,5,1),(0,1,3,2),(0,2,6,4),(1,5,7,3),(2,3,7,6),(4,6,7,5),(2,3,5,4),(1,4,6,3),(1,5,6,2),(0,2,7,5),(0,3,7,4),(0,6,7,1),(0,4,7,3),(1,2,6,5),(0,1,7,6),(0,5,7,2),(1,3,6,4),(2,4,5,3));
   QuadFaces: array[1..18] of shortint = (2,0,4,5,3,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
   QuadConfigStart: array[0..256] of byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,9,9,9,9,9,9,10,10,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,15,15,16,16,19,19,19,19,20,20,21,21,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,26,26,27,27,27,28,31,31,31,31,32,32,32,32,33,33,33,34,37,37,37,38,41,41,41,41,41,41,41,41,41,41,41,41,41,41,42,43,46,46,46,46,46,46,47,47,48,48,48,48,48,49,52,53,56,56,56,56,56,56,56,56,56,56,56,57,58,59,60,63,66,66,67,68,71,72,75,76,79,80,81,84,87,90,93,96,102);
   QuadConfigData: array[0..101] of byte = (2,2,1,1,1,2,7,2,3,3,2,3,8,2,1,3,1,3,9,1,3,1,2,3,2,2,4,4,2,4,10,1,1,4,1,4,11,4,1,2,4,5,5,2,5,12,3,3,5,3,5,13,5,2,3,5,4,4,5,5,4,5,14,2,4,5,6,6,1,6,15,6,3,6,16,6,1,3,6,6,6,4,6,17,1,4,6,5,6,18,3,5,6,4,5,6,2,1,3,4,5,6);

   TriangleSet: array[1..92,0..2] of byte = ((0,1,2),(0,2,4),(0,4,1),(1,4,2),(1,4,3),(2,3,4),(0,1,3),(1,3,5),(0,3,5),(0,5,1),(0,2,5),(1,5,3),(2,3,5),(1,5,2),(2,5,4),(0,3,4),(3,5,4),(0,3,2),(0,2,6),(2,3,6),(0,6,3),(0,6,1),(1,6,3),(1,6,2),(1,4,6),(0,4,3),(3,4,6),(0,5,3),(0,6,5),(3,5,6),(0,3,6),(0,4,5),(0,6,4),(4,6,5),(0,5,6),(0,1,6),(1,5,6),(0,5,2),(2,5,6),(1,3,2),(1,7,3),(2,3,7),(1,2,7),(0,7,1),(0,2,7),(1,4,7),(2,7,4),(1,7,2),(1,2,4),(0,7,5),(0,3,7),(1,2,5),(2,7,5),(1,5,7),(4,7,5),(1,4,5),(1,7,4),(0,7,4),(0,1,7),(1,3,4),(1,5,4),(3,7,4),(1,2,3),(4,5,7),(0,7,3),(0,6,7),(1,2,6),(1,6,7),(2,7,6),(4,6,7),(2,6,4),(2,4,7),(0,7,2),(0,4,7),(2,4,3),(3,4,7),(3,5,7),(5,6,7),(3,7,6),(3,6,5),(1,6,5),(1,3,6),(2,5,3),(2,6,5),(0,7,6),(0,5,7),(1,6,4),(1,7,6),(2,4,5),(2,5,7),(3,4,5),(3,6,4));
   TriConfigStart: array[0..256] of word = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,8,8,8,8,8,8,8,8,8,8,8,8,12,12,12,12,16,16,16,16,16,16,16,16,20,20,20,20,24,24,24,24,26,26,26,26,26,26,26,26,26,26,26,26,26,26,30,30,34,34,34,34,34,34,34,34,38,38,38,38,38,38,42,42,44,44,44,44,44,44,44,44,44,44,48,48,48,48,48,48,54,54,58,58,62,62,66,66,68,68,68,68,74,74,80,80,84,84,84,84,84,84,84,84,84,84,84,84,84,84,84,88,92,92,92,92,92,92,92,96,96,96,96,96,96,96,96,96,102,102,102,102,102,102,102,102,102,102,102,102,106,106,106,110,112,112,112,116,120,120,120,120,126,126,126,130,132,132,132,138,142,142,142,142,142,142,142,142,142,142,142,142,142,142,146,150,152,152,152,152,152,156,160,160,166,166,166,166,166,170,172,178,182,182,182,182,182,182,182,182,182,186,186,190,196,200,206,208,212,212,216,220,222,226,228,234,238,242,248,250,254,256,260,264,264);
   TriConfigData: array[0..263] of byte = (1,2,3,4,3,2,5,6,7,8,9,10,10,11,12,13,1,2,14,15,7,16,12,17,2,12,18,19,20,21,22,19,23,20,3,1,24,25,18,26,20,27,3,20,28,29,30,31,10,29,19,12,20,30,32,33,34,35,33,36,37,34,38,32,39,34,1,34,7,33,31,12,30,34,18,28,32,20,30,34,12,20,30,34,40,41,42,43,44,45,41,42,46,47,48,49,3,2,41,46,47,42,10,7,50,51,40,52,53,42,10,42,54,55,56,57,58,59,54,55,1,2,54,47,48,55,60,61,62,55,7,55,63,49,56,47,42,64,2,47,42,55,18,65,19,66,40,67,41,68,19,41,69,70,71,72,73,74,69,70,3,1,46,69,48,70,75,71,76,70,18,70,40,41,49,46,71,70,3,41,46,70,77,78,79,80,81,82,79,78,10,7,29,31,79,78,83,84,77,78,18,28,29,19,77,78,40,78,10,29,19,78,33,32,85,86,87,56,88,54,33,54,89,71,69,90,32,69,48,49,56,54,71,69,1,48,54,69,91,92,79,77,28,33,32,31,79,77,56,79,7,33,31,79,71,77,18,28,32,77,40,49,56,71);
   TriangleFaces: array[1..92] of shortint = (0,4,2,-1,-1,-1,0,5,-1,2,-1,5,-1,-1,-1,-1,-1,0,4,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,2,4,1,-1,-1,-1,-1,-1,0,5,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,5,1,2,-1,-1,-1,-1,2,-1,0,1,-1,-1,-1,-1,3,1,4,-1,-1,-1,-1,-1,5,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
var
   Vertexes: array [0..7] of integer;
   AllowedFaces: array[0..5] of boolean;
   Config,Mult2: byte;
   i: integer;
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
   AllowedFaces[0] := (_FaceFilledConfig and 32) <> 0; // left (x-1)
   AllowedFaces[1] := (_FaceFilledConfig and 16) <> 0; // right (x+1)
   AllowedFaces[2] := (_FaceFilledConfig and 8) <> 0;  // bottom (y-1)
   AllowedFaces[3] := (_FaceFilledConfig and 4) <> 0;  // top (y+1)
   AllowedFaces[4] := (_FaceFilledConfig and 2) <> 0;  // back (z-1)
   AllowedFaces[5] := (_FaceFilledConfig and 1) <> 0;  // front (z+1)
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
   {$ifdef MESH_TEST}
      if QuadConfigStart[config] = QuadConfigStart[config+1] then
    	   GlobalVars.MeshFile.Add('Configuration detected and not calculated: ' + IntToStr(Config) + '. The vertexes are respectively: (' + IntToStr(Vertexes[0]) + ',' + IntToStr(Vertexes[1]) + ',' + IntToStr(Vertexes[2]) + ',' + IntToStr(Vertexes[3]) + ',' + IntToStr(Vertexes[4]) + ',' + IntToStr(Vertexes[5]) + ',' + IntToStr(Vertexes[6]) + ',' + IntToStr(Vertexes[7]) + ').');
   {$endif}
   // Add the new quads.
   i := QuadConfigStart[config];
   while i < QuadConfigStart[config+1] do // config will always be below 255
   begin
      if (QuadFaces[QuadConfigData[i]] = -1) then
      begin
         {$ifdef MESH_TEST}
 	         if (Vertexes[QuadSet[QuadConfigData[i],0]] < 0) or (Vertexes[QuadSet[QuadConfigData[i],1]] < 0) or (Vertexes[QuadSet[QuadConfigData[i],2]] < 0) or (Vertexes[QuadSet[QuadConfigData[i],3]] < 0) then
 	         begin
 	            GlobalVars.MeshFile.Add('Invalid face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],0]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],1]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],2]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],3]]) + ').');
 	         end;
 	         GlobalVars.MeshFile.Add('Face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],0]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],1]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],2]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],3]]) + ') of the type (' + IntToStr(QuadSet[QuadConfigData[i],0]) + ',' + IntToStr(QuadSet[QuadConfigData[i],1]) + ',' + IntToStr(QuadSet[QuadConfigData[i],2]) + ',' + IntToStr(QuadSet[QuadConfigData[i],3]) + ') has been constructed.');
         {$endif}
         // Add face.
         _QuadList.Add(Vertexes[QuadSet[QuadConfigData[i],0]],Vertexes[QuadSet[QuadConfigData[i],1]],Vertexes[QuadSet[QuadConfigData[i],2]],Vertexes[QuadSet[QuadConfigData[i],3]],_Color);
      end
      else if AllowedFaces[QuadFaces[QuadConfigData[i]]] then
      begin
         // This condition was splitted to avoid access violations.
         {$ifdef MESH_TEST}
 	         if (Vertexes[QuadSet[QuadConfigData[i],0]] < 0) or (Vertexes[QuadSet[QuadConfigData[i],1]] < 0) or (Vertexes[QuadSet[QuadConfigData[i],2]] < 0) or (Vertexes[QuadSet[QuadConfigData[i],3]] < 0) then
 	         begin
 	            GlobalVars.MeshFile.Add('Invalid face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],0]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],1]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],2]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],3]]) + ').');
 	         end;
 	         GlobalVars.MeshFile.Add('Face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],0]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],1]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],2]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],3]]) + ') of the type (' + IntToStr(QuadSet[QuadConfigData[i],0]) + ',' + IntToStr(QuadSet[QuadConfigData[i],1]) + ',' + IntToStr(QuadSet[QuadConfigData[i],2]) + ',' + IntToStr(QuadSet[QuadConfigData[i],3]) + ') from the side ' + IntToStr(QuadFaces[QuadConfigData[i]]) +  ' has been constructed.');
 	         {$endif}
         // Add face.
         _QuadList.Add(Vertexes[QuadSet[QuadConfigData[i],0]],Vertexes[QuadSet[QuadConfigData[i],1]],Vertexes[QuadSet[QuadConfigData[i],2]],Vertexes[QuadSet[QuadConfigData[i],3]],_Color);
         _QuadList.GoToLastElement;
         _FaceVerifier.AddQuadUnsafe(_QuadList.SaveState(),_x,_y,_z,QuadFaces[QuadConfigData[i]]);
      end
      else
      begin
         {$ifdef MESH_TEST}
            GlobalVars.MeshFile.Add('Face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],0]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],1]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],2]]) + ',' + IntToStr(Vertexes[QuadSet[QuadConfigData[i],3]]) + ') of the type (' + IntToStr(QuadSet[QuadConfigData[i],0]) + ',' + IntToStr(QuadSet[QuadConfigData[i],1]) + ',' + IntToStr(QuadSet[QuadConfigData[i],2]) + ',' + IntToStr(QuadSet[QuadConfigData[i],3]) + ') from the side ' + IntToStr(QuadFaces[QuadConfigData[i]]) +  ' has been rejected.');
 	     {$endif}
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
         {$ifdef MESH_TEST}
 	         GlobalVars.MeshFile.Add('Face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],0]]) + ',' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],1]]) + ',' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],2]]) + ') of the type (' + IntToStr(TriangleSet[TriConfigData[i],0]) + ',' + IntToStr(TriangleSet[TriConfigData[i],1]) + ',' + IntToStr(TriangleSet[TriConfigData[i],2]) + ') has been constructed.');
         {$endif}
         _TriangleList.Add(Vertexes[TriangleSet[TriConfigData[i],0]],Vertexes[TriangleSet[TriConfigData[i],1]],Vertexes[TriangleSet[TriConfigData[i],2]],_Color);
      end
      else if AllowedFaces[TriangleFaces[TriConfigData[i]]] then
      begin
         {$ifdef MESH_TEST}
 	         GlobalVars.MeshFile.Add('Face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],0]]) + ',' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],1]]) + ',' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],2]]) + ') of the type (' + IntToStr(TriangleSet[TriConfigData[i],0]) + ',' + IntToStr(TriangleSet[TriConfigData[i],1]) + ',' + IntToStr(TriangleSet[TriConfigData[i],2]) + ') from the side ' + IntToStr(TriangleFaces[TriConfigData[i]]) +  ' has been constructed.');
         {$endif}
         // Add face.
         _TriangleList.Add(Vertexes[TriangleSet[TriConfigData[i],0]],Vertexes[TriangleSet[TriConfigData[i],1]],Vertexes[TriangleSet[TriConfigData[i],2]],_Color);
         _TriangleList.GoToLastElement;
         _FaceVerifier.AddTriangleUnsafe(_TriangleList.SaveState(),_x,_y,_z,TriangleFaces[TriConfigData[i]]);
     end
     else
     begin
 	     {$ifdef MESH_TEST}
 	         GlobalVars.MeshFile.Add('Face ' + IntToStr(i) + ' from config ' + IntToStr(Config) + ' formed by (' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],0]]) + ',' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],1]]) + ',' + IntToStr(Vertexes[TriangleSet[TriConfigData[i],2]]) + ') of the type (' + IntToStr(TriangleSet[TriConfigData[i],0]) + ',' + IntToStr(TriangleSet[TriConfigData[i],1]) + ',' + IntToStr(TriangleSet[TriConfigData[i],2]) + ') from the side ' + IntToStr(TriangleFaces[TriConfigData[i]]) +  ' has been rejected.');
        {$endif}
      end;
      inc(i);
   end;
end;

   // Here we get an average of the colours of the neighbours of the region.
function CRefinementTrianglesSupporter.GetColourRefinement(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
const
   CubeConfigStart: array[0..33] of byte = (0,1,4,7,10,13,20,27,34,41,42,45,46,49,50,53,54,57,58,61,64,67,70,77,84,91,98,115,132,149,166,183,200,226);
   CubeConfigData: array[0..225] of byte = (0,0,1,11,0,2,15,0,3,13,0,4,9,0,2,3,5,13,14,15,0,1,3,6,11,12,13,0,2,4,7,9,15,16,0,1,4,8,9,10,11,9,9,10,11,11,11,12,13,13,13,14,15,15,9,15,16,17,11,17,18,15,17,19,13,17,20,9,17,21,13,14,15,17,19,20,22,11,12,13,17,18,20,23,9,15,16,17,19,21,24,9,10,11,17,18,21,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,4,7,8,9,10,11,15,16,17,18,19,21,24,25,0,1,2,3,5,6,11,12,13,14,15,17,18,19,20,22,23,0,2,3,4,5,7,9,13,14,15,16,17,19,20,21,22,24,0,1,3,4,6,8,9,10,11,12,13,17,18,20,21,23,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25);
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
         if _Voxel.GetVoxelSafe(Round(_x + CurrentNormal.X),Round(_y + CurrentNormal.Y),Round(_z + CurrentNormal.Z),v) then
         begin
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
      if numColours > 0 then
      begin
         r := r / numColours;
         g := g / numColours;
         b := b / numColours;
      end
      else // if there is no colour, we'll try an average of all neighbours here.
      begin
         i := 0;
         while i < 26 do
         begin
            CurrentNormal := Cube[i];
            if _Voxel.GetVoxelSafe(Round(_x + CurrentNormal.X),Round(_y + CurrentNormal.Y),Round(_z + CurrentNormal.Z),v) then
            begin
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
         if numColours > 0 then
         begin
            r := r / numColours;
            g := g / numColours;
            b := b / numColours;
         end;
      end;
   end;
   Result := RGB(Round(r),Round(g),Round(b));
   Cube.Free;
end;

function CRefinementTrianglesSupporter.GetColourSurface(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
const
   CubeConfigStart: array[0..33] of byte = (0,1,4,7,10,13,20,27,34,41,42,45,46,49,50,53,54,57,58,61,64,67,70,77,84,91,98,115,132,149,166,183,200,226);
   CubeConfigData: array[0..225] of byte = (0,0,1,11,0,2,15,0,3,13,0,4,9,0,2,3,5,13,14,15,0,1,3,6,11,12,13,0,2,4,7,9,15,16,0,1,4,8,9,10,11,9,9,10,11,11,11,12,13,13,13,14,15,15,9,15,16,17,11,17,18,15,17,19,13,17,20,9,17,21,13,14,15,17,19,20,22,11,12,13,17,18,20,23,9,15,16,17,19,21,24,9,10,11,17,18,21,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,4,7,8,9,10,11,15,16,17,18,19,21,24,25,0,1,2,3,5,6,11,12,13,14,15,17,18,19,20,22,23,0,2,3,4,5,7,9,13,14,15,16,17,19,20,21,22,24,0,1,3,4,6,8,9,10,11,12,13,17,18,20,21,23,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25);
   NeighbourWeight: array[0..25] of byte = (4,2,2,2,2,1,1,1,1,4,2,4,2,4,2,4,2,4,2,2,2,2,1,1,1,1);
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
   _Voxel.GetVoxel(_x,_y,_z,v);
   r := 7 * GetRValue(_Palette[v.Colour]);
   g := 7 * GetGValue(_Palette[v.Colour]);
   b := 7 * GetBValue(_Palette[v.Colour]);
   numColours := 7;
   if maxi > 0 then
   begin
      // visit all cubed neighbours
      i := CubeConfigStart[_config];
      while i < CubeConfigStart[_config+1] do
      begin
         // add this colour.
         CurrentNormal := Cube[CubeConfigData[i]];
         if _Voxel.GetVoxelSafe(Round(_x + CurrentNormal.X),Round(_y + CurrentNormal.Y),Round(_z + CurrentNormal.Z),v) then
         begin
            if v.Used then
            begin
               r := r + (NeighbourWeight[i] * GetRValue(_Palette[v.Colour]));
               g := g + (NeighbourWeight[i] * GetGValue(_Palette[v.Colour]));
               b := b + (NeighbourWeight[i] * GetBValue(_Palette[v.Colour]));
               inc(numColours,NeighbourWeight[i]);
            end;
         end;
         inc(i);
      end;
   end;
   r := r / numColours;
   g := g / numColours;
   b := b / numColours;
   Result := RGB(Round(r),Round(g),Round(b));
   Cube.Free;
end;

function CRefinementTrianglesSupporter.GetVertex(const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z,_reference,_VUnit: integer; var _NumVertices: longword; const _VoxelMap: TVoxelMap; const _VertexTransformation: aint32): integer;
const
   RegionSet: array[0..7,0..2] of short = ((-1,-1,-1),(-1,-1,0),(-1,0,-1),(-1,0,0),(0,-1,-1),(0,-1,0),(0,0,-1),(0,0,0));
   VertexBit: array[0..7] of byte = (1,2,4,8,16,32,64,128);
begin
   if _VertexMap.isPixelValid(_x*_VUnit,_y*_VUnit,_z*_Vunit) then
   begin
      Result := _VertexMap.DataUnsafe[_x*_VUnit,_y*_VUnit,_z*_VUnit];
      if Result <> C_VMG_NO_VERTEX then
      begin
         if (Round(_VoxelMap.MapSafe[_x - RegionSet[_reference,0],_y - RegionSet[_reference,1],_z - RegionSet[_reference,2]]) and VertexBit[_reference]) = 0 then
         begin
            Result := C_VMG_NO_VERTEX;
         end;
      end;
   end
   else
   begin
      Result := C_VMG_NO_VERTEX;
   end;
end;

function CRefinementTrianglesSupporter.HasMidFaceVertex(_vNE, _vNW, _vSW, _vSE, _vN, _vW, _vS, _vE, _vSelf: integer): boolean;
const
   ValidConfigs: array[0..3] of byte = (12,9,3,6);
var
   CountCorner,CountCenter,CenterConfig,i: byte;
   Found : boolean;
begin
   Result := false;
   if _vSelf = C_VMG_NO_VERTEX then
   begin
      CountCorner := 0;
      if _vNE <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if _vNW <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if _vSE <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if _vSW <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if CountCorner = 3 then
      begin
         CountCenter := 0;
         CenterConfig := 0;
         if (_vS <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            CenterConfig := CenterConfig or 8;
         end;
         if (_vW <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            CenterConfig := CenterConfig or 4;
         end;
         if (_vN <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            CenterConfig := CenterConfig or 2;
         end;
         if (_vE <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            inc(CenterConfig);
         end;
         if CountCenter = 2 then
         begin
            Found := false;
            i := 0;
            while i < 4 do
            begin
               if CenterConfig = ValidConfigs[i] then
               begin
                  Found := true;
                  i := 4;
               end
               else
               begin
                  inc(i);
               end;
            end;
            if Found then
            begin
               Result := true;
            end;
         end
         else if CountCenter > 2 then
         begin
            Result := true;
         end;
      end
      else if CountCorner = 4 then
      begin
         CountCenter := 0;
         if (_vS <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
         end;
         if (_vW <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
         end;
         if (_vN <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
         end;
         if (_vE <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
         end;
         if CountCenter = 3 then
         begin
            Result := true;
         end;
      end;
   end;
end;

function CRefinementTrianglesSupporter.HasMidFaceVertexOnSurface(_vNE, _vNW, _vSW, _vSE, _vN, _vW, _vS, _vE, _vSelf: integer): boolean;
const
   ValidConfigs: array[0..3] of byte = (12,9,3,6);
var
   CountCorner,CountCenter,CenterConfig,i: byte;
   Found : boolean;
begin
   Result := false;
   if _vSelf = C_VMG_NO_VERTEX then
   begin
      CountCorner := 0;
      if _vNE <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if _vNW <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if _vSE <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if _vSW <> C_VMG_NO_VERTEX then
      begin
         inc(CountCorner);
      end;
      if CountCorner = 3 then
      begin
         CountCenter := 0;
         CenterConfig := 0;
         if (_vS <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            CenterConfig := CenterConfig or 8;
         end;
         if (_vW <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            CenterConfig := CenterConfig or 4;
         end;
         if (_vN <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            CenterConfig := CenterConfig or 2;
         end;
         if (_vE <> C_VMG_NO_VERTEX) then
         begin
            inc(CountCenter);
            inc(CenterConfig);
         end;
         if CountCenter = 2 then
         begin
            Found := false;
            i := 0;
            while i < 4 do
            begin
               if CenterConfig = ValidConfigs[i] then
               begin
                  Found := true;
                  i := 4;
               end
               else
               begin
                  inc(i);
               end;
            end;
            if Found then
            begin
               Result := true;
            end;
         end
         else if CountCenter > 2 then
         begin
            Result := true;
         end;
      end
      else if CountCorner = 4 then
      begin
         Result := true;
      end;
   end;
end;

procedure CRefinementTrianglesSupporter.AddVertex(var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x,_y,_z,_xN,_yN,_zN: integer; var _NumVertices: longword);
begin
   if _VertexMap[_x,_y,_z] = C_VMG_NO_VERTEX then
   begin
      _VertexMap[_x,_y,_z] := _NumVertices;
      _NeighbourVertexIDs[_xN,_yN,_zN] := _NumVertices;
      inc(_NumVertices);
   end
   else
   begin
      _NeighbourVertexIDs[_xN,_yN,_zN] := _VertexMap[_x,_y,_z];
   end;
end;

procedure CRefinementTrianglesSupporter.DetectPotentialRefinementVertexes(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
const
   ConnectivityVertexConfigStart: array[0..26] of byte = (0,0,1,2,3,4,7,10,13,16,16,17,17,18,18,19,19,20,20,21,22,23,24,27,30,33,36);
   ConnectivityVertexConfigData: array[0..35] of longword = (2049,32769,8193,513,32776,8196,16385,2056,8194,4097,32784,516,65537,2064,514,1025,2560,10240,40960,33280,133120,163840,139264,131584,1081344,532480,147456,1050624,270336,135168,2129920,524800,196608,2099200,262656,132096);
   RegionBitNeighbours: array[0..25] of longword = (1,2049,32769,8193,513,57357,14347,98949,3603,512,2560,2048,10240,8192,40960,32768,33280,131072,133120,163840,139264,131584,1761280,1456128,2851328,2493952);
   ConnectivityBitNeighbours: array[0..25] of longword = (30,2369,32929,8289,897,16396,4106,65556,1042,2163728,33557248,267266,8398912,1069064,4235296,606212,16810624,3932160,42076160,21135360,12722176,50463232,1589248,1314816,2686976,2360320);
var
   Cube : TNormals;
   i,j,maxi: integer;
   xBase,yBase,zBase : integer;
   CurrentNormal : TVector3f;
   RegionBitConfig,ConnectivityConfig,current: longword;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      xBase := (_x-1) * _VUnit;
      yBase := (_y-1) * _VUnit;
      zBase := (_z-1) * _VUnit;
      // 1) We will fill the region config first.
      i := 0;
      RegionBitConfig := 0;
      current := 1;
      while i <= maxi do
      begin
         CurrentNormal := Cube[i];
         if _VoxelMap.MapSafe[_x + Round(CurrentNormal.X),_y + Round(CurrentNormal.Y),_z + Round(CurrentNormal.Z)] > 256 then
         begin
            RegionBitConfig := RegionBitConfig or current;
         end;
         inc(i);
         current := current shl 1;
      end;
      // 2) Find the connectivity graph.
      i := 0;
      current := 1;
      ConnectivityConfig := 0;
      while i <= maxi do
      begin
         j := ConnectivityVertexConfigStart[i];
         // if one of the next configurations match, the vertex i is in the config
         while j < ConnectivityVertexConfigStart[i+1] do
         begin
            if (RegionBitConfig and ConnectivityVertexConfigData[j]) = ConnectivityVertexConfigData[j] then
            begin
               ConnectivityConfig := ConnectivityConfig or current;
               j := ConnectivityVertexConfigStart[i+1]; // go to next i
            end
            else
            begin
               inc(j);
            end;
         end;
         inc(i);
         current := current shl 1;
      end;

      // 3) Find the final vertexes.
      i := 0;
      current := 1;
      while i <= maxi do
      begin
         // If the vertex is in the connectivity graph, then we add it (even if
         // it gets eliminated in the end of the technique.
         if (ConnectivityConfig and current) = current then
         begin
            // Add vertex
            CurrentNormal := Cube[i];
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + Round(CurrentNormal.X) + 1,yBase + Round(CurrentNormal.Y) + 1,zBase + Round(CurrentNormal.Z) + 1,Round(CurrentNormal.X) + 1,Round(CurrentNormal.Y) + 1,Round(CurrentNormal.Z) + 1,_NumVertices);
         end
         else // It's not in the connectivity graph.
         begin
            // If current is in the RegionBitConfig and one of the neighbours
            // from the RegionBitNeighbours[i] is in RegionBitConfig then...
            if ((RegionBitConfig and current) = current) and ((RegionBitConfig and RegionBitNeighbours[i]) <> 0) then
            begin
               // Add Vertex
               CurrentNormal := Cube[i];
               AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + Round(CurrentNormal.X) + 1,yBase + Round(CurrentNormal.Y) + 1,zBase + Round(CurrentNormal.Z) + 1,Round(CurrentNormal.X) + 1,Round(CurrentNormal.Y) + 1,Round(CurrentNormal.Z) + 1,_NumVertices);
            end
            else // It's not in the connectivity graph from neighbour voxels.
            begin
               // Check if one of the neighbours of i in the ConnectivityConfig
               // exists that it also adds a vertex
               if (ConnectivityConfig and ConnectivityBitNeighbours[i]) <> 0 then
               begin
                  // Add Vertex
                  CurrentNormal := Cube[i];
                  AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + Round(CurrentNormal.X) + 1,yBase + Round(CurrentNormal.Y) + 1,zBase + Round(CurrentNormal.Z) + 1,Round(CurrentNormal.X) + 1,Round(CurrentNormal.Y) + 1,Round(CurrentNormal.Z) + 1,_NumVertices);
               end;
            end;
         end;
         inc(i);
         current := current shl 1;
      end;
   end;
   Cube.Free;
end;

procedure CRefinementTrianglesSupporter.DetectPotentialRefinementVertexesOld(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
const
   VertexSet: array[1..26,0..2] of byte = ((0,0,0),(0,0,1),(0,0,2),(0,1,0),(0,1,1),(0,1,2),(0,2,0),(0,2,1),(0,2,2),(1,0,0),(1,0,1),(1,0,2),(2,0,0),(2,0,1),(2,0,2),(1,1,2),(2,1,2),(1,2,2),(2,2,2),(1,2,0),(1,2,1),(2,2,0),(2,2,1),(1,1,0),(2,1,0),(2,1,1));
   VertexConfigStart: array[0..26] of byte = (0,9,12,15,18,21,22,23,24,25,34,37,46,49,58,61,70,73,82,85,88,91,94,95,96,97,98);
   VertexConfigData: array[0..97] of byte = (1,2,3,4,5,6,7,8,9,3,6,9,1,4,7,7,8,9,1,2,3,7,9,1,3,1,2,3,10,11,12,13,14,15,3,12,15,3,12,15,6,16,17,9,18,19,9,18,19,7,8,9,20,21,18,22,23,19,7,20,22,1,10,13,4,24,25,7,20,22,1,10,13,13,14,15,25,26,17,22,23,19,15,17,19,13,25,22,22,23,19,13,14,15,22,19,13,15);

   MidVerts: array[0..71,0..2] of byte = ((1,2,0),(1,2,2),(1,0,2),(1,0,0),(1,2,1),(1,1,2),(1,0,1),(1,1,0),(0,1,0),(0,1,2),(2,1,2),(2,1,0),(0,1,1),(1,1,2),(2,1,1),(1,1,0),(2,2,1),(0,2,1),(0,0,1),(2,0,1),(1,2,1),(0,1,1),(1,0,1),(2,1,1),(2,2,2),(0,2,0),(0,0,0),(2,0,2),(1,2,1),(0,1,0),(1,0,1),(2,1,2),(2,2,0),(0,2,2),(0,0,2),(2,0,0),(1,2,1),(0,1,2),(1,0,1),(2,1,0),(2,2,0),(0,0,0),(0,0,2),(2,2,2),(1,1,0),(0,0,1),(1,1,2),(2,2,1),(2,0,0),(0,2,0),(0,2,2),(2,0,2),(1,1,0),(0,2,1),(1,1,2),(2,0,1),(2,2,0),(0,2,0),(0,0,2),(2,0,2),(1,2,0),(0,1,1),(1,0,2),(2,1,1),(2,0,0),(0,0,0),(0,2,2),(2,2,2),(1,0,0),(0,1,1),(1,2,2),(2,1,1));
var
   Cube : TNormals;
   i,j,k,maxi: integer;
   xBase,yBase,zBase : integer;
   CurrentNormal : TVector3f;
   VertexConfig: longword;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      // We will fill the potential vertexes with the value they deserve.
      i := 0;
      VertexConfig := 0;
      xBase := (_x-1) * _VUnit;
      yBase := (_y-1) * _VUnit;
      zBase := (_z-1) * _VUnit;
      while i <= maxi do
      begin
         CurrentNormal := Cube[i];
         if _VoxelMap.MapSafe[_x + Round(CurrentNormal.X),_y + Round(CurrentNormal.Y),_z + Round(CurrentNormal.Z)] > 256 then
         begin
            j := VertexConfigStart[i];
            while j < VertexConfigStart[i+1] do
            begin
               AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + VertexSet[VertexConfigData[j],0],yBase + VertexSet[VertexConfigData[j],1],zBase + VertexSet[VertexConfigData[j],2],VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2],_NumVertices);
               VertexConfig := VertexConfig + (1 shl VertexConfigData[j]);
               inc(j);
            end;
         end;
         inc(i);
      end;
      // update faces checking if the center vertex is used or not.
      // Order: NE, NW, SW, SE, N, W, S, E, Self -> pointing to the center of
      // the 3x3x3 region

      // Left
      if HasMidFaceVertex(_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,1,1]) then
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase,yBase + 1,zBase + 1,0,1,1,_NumVertices);
      end;
      // Right
      if HasMidFaceVertex(_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1]) then
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase + 1,zBase + 1,2,1,1,_NumVertices);
      end;
      // Bottom
      if HasMidFaceVertex(_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[1,0,1]) then
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase,zBase + 1,1,0,1,_NumVertices);
      end;
      // Top
      if HasMidFaceVertex(_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[1,2,1]) then
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 2,zBase + 1,1,2,1,_NumVertices);
      end;
      // Back
      if HasMidFaceVertex(_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[1,1,0]) then
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase,1,1,0,_NumVertices);
      end;
      // Front
      if HasMidFaceVertex(_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[1,1,2]) then
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 2,1,1,2,_NumVertices);
      end;
      // update the center region check if it is used or not.
//      AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 1,1,1,1,_NumVertices);
      if _VoxelMap.MapSafe[_x,_y,_z] > 254 then
      begin
         i := 0;
         j := 0;
         while i < High(MidVerts) do
         begin
            if HasMidFaceVertex(_NeighbourVertexIDs[MidVerts[i,0],MidVerts[i,1],MidVerts[i,2]],_NeighbourVertexIDs[MidVerts[i+1,0],MidVerts[i+1,1],MidVerts[i+1,2]],_NeighbourVertexIDs[MidVerts[i+2,0],MidVerts[i+2,1],MidVerts[i+2,2]],_NeighbourVertexIDs[MidVerts[i+3,0],MidVerts[i+3,1],MidVerts[i+3,2]],_NeighbourVertexIDs[MidVerts[i+4,0],MidVerts[i+4,1],MidVerts[i+4,2]],_NeighbourVertexIDs[MidVerts[i+5,0],MidVerts[i+5,1],MidVerts[i+5,2]],_NeighbourVertexIDs[MidVerts[i+6,0],MidVerts[i+6,1],MidVerts[i+6,2]],_NeighbourVertexIDs[MidVerts[i+7,0],MidVerts[i+7,1],MidVerts[i+7,2]],_NeighbourVertexIDs[1,1,1]) then
            begin
               AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 1,1,1,1,_NumVertices);
               i := High(MidVerts);
            end;
            inc(i,8);
         end;
      end
      else
      begin
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 1,1,1,1,_NumVertices);
      end;
   end;
   Cube.Free;
end;

procedure CRefinementTrianglesSupporter.DetectPotentialSurfaceVertexes(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
const
   ConnectivityVertexConfigStart: array[0..26] of byte = (0,0,1,2,3,4,7,10,13,16,16,17,17,18,18,19,19,20,20,21,22,23,24,27,30,33,36);
   ConnectivityVertexConfigData: array[0..35] of longword = (2049,32769,8193,513,32776,8196,16385,2056,8194,4097,32784,516,65537,2064,514,1025,2560,10240,40960,33280,133120,163840,139264,131584,1081344,532480,147456,1050624,270336,135168,2129920,524800,196608,2099200,262656,132096);
   RegionBitNeighbours: array[0..25] of longword = (1,2049,32769,8193,513,57357,14347,98949,3603,512,2560,2048,10240,8192,40960,32768,33280,131072,133120,163840,139264,131584,1761280,1456128,2851328,2493952);
   ConnectivityBitNeighbours: array[0..25] of longword = (30,2369,32929,8289,897,16396,4106,65556,1042,2163728,33557248,267266,8398912,1069064,4235296,606212,16810624,3932160,42076160,21135360,12722176,50463232,1589248,1314816,2686976,2360320);
var
   Cube : TNormals;
   i,j,maxi: integer;
   xBase,yBase,zBase : integer;
   CurrentNormal : TVector3f;
   RegionBitConfig,ConnectivityConfig,current: longword;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      xBase := (_x-1) * _VUnit;
      yBase := (_y-1) * _VUnit;
      zBase := (_z-1) * _VUnit;
      // 1) We will fill the region config first.
      i := 0;
      current := 1;
      RegionBitConfig := 0;
      while i <= maxi do
      begin
         CurrentNormal := Cube[i];
         if _VoxelMap.MapSafe[_x + Round(CurrentNormal.X),_y + Round(CurrentNormal.Y),_z + Round(CurrentNormal.Z)] > 256 then
         begin
            RegionBitConfig := RegionBitConfig or current;
         end;
         inc(i);
         current := current shl 1;
      end;
      // 2) Find the connectivity graph.
      i := 0;
      ConnectivityConfig := 0;
      current := 1;
      while i <= maxi do
      begin
         if (RegionBitConfig and current) = 0 then
         begin
            // if one of the next configurations match, the vertex i is in the config
            j := ConnectivityVertexConfigStart[i];
            while j < ConnectivityVertexConfigStart[i+1] do
            begin
               if (RegionBitConfig and ConnectivityVertexConfigData[j]) = ConnectivityVertexConfigData[j] then
               begin
                  ConnectivityConfig := ConnectivityConfig or current;
                  j := ConnectivityVertexConfigStart[i+1]; // go to next i
               end
               else
               begin
                  inc(j);
               end;
            end;
         end
         else
         begin
            ConnectivityConfig := ConnectivityConfig or current;
         end;
         inc(i);
         current := current shl 1;
      end;

      // 3) Find the final vertexes.
      i := 0;
      current := 1;
      while i <= maxi do
      begin
         // If the vertex is in the connectivity graph, then we add it (even if
         // it gets eliminated in the end of the technique.
         if (ConnectivityConfig and current) = current then
         begin
            // Add vertex
            CurrentNormal := Cube[i];
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + Round(CurrentNormal.X) + 1,yBase + Round(CurrentNormal.Y) + 1,zBase + Round(CurrentNormal.Z) + 1,Round(CurrentNormal.X) + 1,Round(CurrentNormal.Y) + 1,Round(CurrentNormal.Z) + 1,_NumVertices);
         end
         else // It's not in the connectivity graph.
         begin
            // If current is in the RegionBitConfig and one of the neighbours
            // from the RegionBitNeighbours[i] is in RegionBitConfig then...
            if ((RegionBitConfig and current) = current) and ((RegionBitConfig and RegionBitNeighbours[i]) <> 0) then
            begin
               // Add Vertex
               CurrentNormal := Cube[i];
               AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + Round(CurrentNormal.X) + 1,yBase + Round(CurrentNormal.Y) + 1,zBase + Round(CurrentNormal.Z) + 1,Round(CurrentNormal.X) + 1,Round(CurrentNormal.Y) + 1,Round(CurrentNormal.Z) + 1,_NumVertices);
            end
            else // It's not in the connectivity graph from neighbour voxels.
            begin
               // Check if one of the neighbours of i in the ConnectivityConfig
               // exists that it also adds a vertex
               if (ConnectivityConfig and ConnectivityBitNeighbours[i]) <> 0 then
               begin
                  // Add Vertex
                  CurrentNormal := Cube[i];
                  AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + Round(CurrentNormal.X) + 1,yBase + Round(CurrentNormal.Y) + 1,zBase + Round(CurrentNormal.Z) + 1,Round(CurrentNormal.X) + 1,Round(CurrentNormal.Y) + 1,Round(CurrentNormal.Z) + 1,_NumVertices);
               end;
            end;
         end;
         inc(i);
         current := current shl 1;
      end;
   end;
   Cube.Free;
   // Add the fixed vertexes
   // center
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 1,1,1,1,_NumVertices);
   // Mid-edges
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 0,yBase + 1,zBase + 1,0,1,1,_NumVertices);
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase + 1,zBase + 1,2,1,1,_NumVertices);
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 0,zBase + 1,1,0,1,_NumVertices);
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 2,zBase + 1,1,2,1,_NumVertices);
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 0,1,1,0,_NumVertices);
   AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 2,1,1,2,_NumVertices);
end;

procedure CRefinementTrianglesSupporter.DetectPotentialSurfaceVertexesOld(const _VoxelMap: TVoxelMap; var _VertexMap : T3DVolumeGreyIntData; var _NeighbourVertexIDs:T3DIntGrid; _x, _y, _z, _VUnit: integer; var _NumVertices: longword);
const
   VertexSet: array[1..26,0..2] of byte = ((0,0,0),(0,0,1),(0,0,2),(0,1,0),(0,1,1),(0,1,2),(0,2,0),(0,2,1),(0,2,2),(1,0,0),(1,0,1),(1,0,2),(2,0,0),(2,0,1),(2,0,2),(1,1,2),(2,1,2),(1,2,2),(2,2,2),(1,2,0),(1,2,1),(2,2,0),(2,2,1),(1,1,0),(2,1,0),(2,1,1));
   VertexConfigStart: array[0..26] of byte = (0,9,12,15,18,21,22,23,24,25,34,37,46,49,58,61,70,73,82,85,88,91,94,95,96,97,98);
   VertexConfigData: array[0..97] of byte = (1,2,3,4,5,6,7,8,9,3,6,9,1,4,7,7,8,9,1,2,3,7,9,1,3,1,2,3,10,11,12,13,14,15,3,12,15,3,12,15,6,16,17,9,18,19,9,18,19,7,8,9,20,21,18,22,23,19,7,20,22,1,10,13,4,24,25,7,20,22,1,10,13,13,14,15,25,26,17,22,23,19,15,17,19,13,25,22,22,23,19,13,14,15,22,19,13,15);

   MidVerts: array[0..71,0..2] of byte = ((1,2,0),(1,2,2),(1,0,2),(1,0,0),(1,2,1),(1,1,2),(1,0,1),(1,1,0),(0,1,0),(0,1,2),(2,1,2),(2,1,0),(0,1,1),(1,1,2),(2,1,1),(1,1,0),(2,2,1),(0,2,1),(0,0,1),(2,0,1),(1,2,1),(0,1,1),(1,0,1),(2,1,1),(2,2,2),(0,2,0),(0,0,0),(2,0,2),(1,2,1),(0,1,0),(1,0,1),(2,1,2),(2,2,0),(0,2,2),(0,0,2),(2,0,0),(1,2,1),(0,1,2),(1,0,1),(2,1,0),(2,2,0),(0,0,0),(0,0,2),(2,2,2),(1,1,0),(0,0,1),(1,1,2),(2,2,1),(2,0,0),(0,2,0),(0,2,2),(2,0,2),(1,1,0),(0,2,1),(1,1,2),(2,0,1),(2,2,0),(0,2,0),(0,0,2),(2,0,2),(1,2,0),(0,1,1),(1,0,2),(2,1,1),(2,0,0),(0,0,0),(0,2,2),(2,2,2),(1,0,0),(0,1,1),(1,2,2),(2,1,1));
var
   Cube : TNormals;
   i,j,k,maxi,counter: integer;
   xBase,yBase,zBase : integer;
   CurrentNormal : TVector3f;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      // We will fill the potential vertexes with the value they deserve.
      i := 0;
      counter := 0;
      xBase := (_x-1) * _VUnit;
      yBase := (_y-1) * _VUnit;
      zBase := (_z-1) * _VUnit;
      while i <= maxi do
      begin
         CurrentNormal := Cube[i];
         if _VoxelMap.MapSafe[_x + Round(CurrentNormal.X),_y + Round(CurrentNormal.Y),_z + Round(CurrentNormal.Z)] > 0 then
         begin
            j := VertexConfigStart[i];
            while j < VertexConfigStart[i+1] do
            begin
               AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + VertexSet[VertexConfigData[j],0],yBase + VertexSet[VertexConfigData[j],1],zBase + VertexSet[VertexConfigData[j],2],VertexSet[VertexConfigData[j],0],VertexSet[VertexConfigData[j],1],VertexSet[VertexConfigData[j],2],_NumVertices);
               inc(j);
            end;
            inc(counter);
         end;
         inc(i);
      end;
      if counter <> 0 then
      begin
         // Update 12 border edges.
         if (_NeighbourVertexIDs[0,0,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[0,0,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase,yBase,zBase + 1,0,0,1,_NumVertices);
         end;
         if (_NeighbourVertexIDs[2,0,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,0,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase,zBase + 1,2,0,1,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,0,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[0,2,0] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase,yBase + 1,zBase,0,1,0,_NumVertices);
         end;
         if (_NeighbourVertexIDs[2,0,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,2,0] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase + 1,zBase,2,1,0,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,0,2] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[0,2,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase,yBase + 1,zBase + 2,0,1,2,_NumVertices);
         end;
         if (_NeighbourVertexIDs[2,0,2] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,2,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase + 1,zBase + 2,2,1,2,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,2,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[0,2,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase,yBase + 2,zBase + 1,0,2,1,_NumVertices);
         end;
         if (_NeighbourVertexIDs[2,2,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,2,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase + 2,zBase + 1,2,2,1,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,0,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,0,0] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase,zBase,1,0,0,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,0,2] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,0,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase,zBase + 2,1,0,2,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,2,0] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,2,0] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 2,zBase,1,2,0,_NumVertices);
         end;
         if (_NeighbourVertexIDs[0,2,2] <> C_VMG_NO_VERTEX) and (_NeighbourVertexIDs[2,2,2] <> C_VMG_NO_VERTEX) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 2,zBase + 2,1,2,2,_NumVertices);
         end;


         // update faces checking if the center vertex is used or not.
         // Order: NE, NW, SW, SE, N, W, S, E, Self -> pointing to the center of
         // the 3x3x3 region

         // Left
         if HasMidFaceVertexOnSurface(_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,1,1]) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase,yBase + 1,zBase + 1,0,1,1,_NumVertices);
         end;
         // Right
         if HasMidFaceVertexOnSurface(_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1]) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 2,yBase + 1,zBase + 1,2,1,1,_NumVertices);
         end;
         // Bottom
         if HasMidFaceVertexOnSurface(_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[1,0,1]) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase,zBase + 1,1,0,1,_NumVertices);
         end;
         // Top
         if HasMidFaceVertexOnSurface(_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[2,2,1],_NeighbourVertexIDs[1,2,1]) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 2,zBase + 1,1,2,1,_NumVertices);
         end;
         // Back
         if HasMidFaceVertexOnSurface(_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[2,2,0],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[1,1,0]) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase,1,1,0,_NumVertices);
         end;
         // Front
         if HasMidFaceVertexOnSurface(_NeighbourVertexIDs[2,2,2],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[1,1,2]) then
         begin
            AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 2,1,1,2,_NumVertices);
         end;
         // update the center region check if it is used or not.
         AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + 1,yBase + 1,zBase + 1,1,1,1,_NumVertices);
      end
      else // Lone voxel situation. Fill every Vertex.
      begin
         for i := 0 to 2 do
            for j := 0 to 2 do
               for k := 0 to 2 do
               begin
                  AddVertex(_VertexMap,_NeighbourVertexIDs,xBase + i,yBase + j,zBase + k,i,j,k,_NumVertices);
               end;
      end;
   end;
   Cube.Free;
end;

procedure CRefinementTrianglesSupporter.AddRefinementFacesFromRegions(const _Voxel : TVoxelSection; const _Palette: TPalette; var _NeighbourVertexIDs: T3DIntGrid; var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _FaceVerifier: CVolumeFaceVerifier; _x, _y, _z, _AllowedFaces, _VUnit: integer);
const
   FaceColorConfig: array[0..7] of byte = (7,8,5,6,24,25,22,23);
var
   xVM,yVM,zVM: integer;
begin
   xVM := _x * _VUnit;
   yVM := _y * _VUnit;
   zVM := _z * _VUnit;

   // We'll now add the refinement zones, subdividing the original region in
   // 8, like an octree.

   // (0,0,0) -> (1,1,1), left bottom back side
  {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left bottom back, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,1,0], _NeighbourVertexIDs[1,1,1],_AllowedFaces,xVM,yVM,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[0]));
   // (0,0,1) -> (1,1,2), left bottom front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left bottom front, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,1,1], _NeighbourVertexIDs[1,1,2],_AllowedFaces,xVM,yVM,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[1]));
   // (0,1,0) -> (1,2,1), left top back side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left top back, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,2,0], _NeighbourVertexIDs[1,2,1],_AllowedFaces,xVM,yVM+1,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[2]));
   // (0,1,1) -> (1,2,2), left top front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left top front, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,2,1], _NeighbourVertexIDs[1,2,2],_AllowedFaces,xVM,yVM+1,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[3]));
   // (1,0,0) -> (2,1,1), right bottom back side
   {$ifdef MESH_TEST}
 	      GlobalVars.MeshFile.Add('Region: Right bottom back, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,1,0], _NeighbourVertexIDs[2,1,1],_AllowedFaces,xVM+1,yVM,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[4]));
   // (1,0,1) -> (2,1,2), right bottom front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right bottom front, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,1,1], _NeighbourVertexIDs[2,1,2],_AllowedFaces,xVM+1,yVM,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[5]));
   // (1,1,0) -> (2,2,1), right top back side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right top back, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,2,0], _NeighbourVertexIDs[2,2,1],_AllowedFaces,xVM+1,yVM+1,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[6]));
   // (1,1,1) -> (2,2,2), right top front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right top front, Allowed Faces: ' + IntToStr(_AllowedFaces) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,2,1], _NeighbourVertexIDs[2,2,2],_AllowedFaces,xVM+1,yVM+1,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourRefinement(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[7]));
end;

procedure CRefinementTrianglesSupporter.AddSurfaceFacesFromRegions(const _Voxel : TVoxelSection; const _Palette: TPalette; var _NeighbourVertexIDs: T3DIntGrid; var _TriangleList: CTriangleList; var _QuadList: CQuadList; var _FaceVerifier: CVolumeFaceVerifier; _x, _y, _z, _AllowedFaces, _VUnit: integer);
const
   FaceConfigLimits: array[0..7] of integer = (21,22,25,26,37,38,41,42);
   FaceColorConfig: array[0..7] of byte = (7,8,5,6,24,25,22,23);
var
   xVM,yVM,zVM: integer;
   V : TVoxelUnpacked;
begin
   xVM := _x * _VUnit;
   yVM := _y * _VUnit;
   zVM := _z * _VUnit;
   _Voxel.GetVoxel(_x,_y,_z,v);
   // We'll now add the refinement zones, subdividing the original region in
   // 8, like an octree.

   // (0,0,0) -> (1,1,1), left bottom back side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left bottom back, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[0]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,0,0],_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,1,0], _NeighbourVertexIDs[1,1,1],_AllowedFaces or FaceConfigLimits[0],xVM,yVM,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[0]));
   // (0,0,1) -> (1,1,2), left bottom front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left bottom front, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[1]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,0,1],_NeighbourVertexIDs[0,0,2],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,1,1], _NeighbourVertexIDs[1,1,2],_AllowedFaces or FaceConfigLimits[1],xVM,yVM,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[1]));
   // (0,1,0) -> (1,2,1), left top back side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left top back, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[2]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,1,0],_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,2,0],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,2,0], _NeighbourVertexIDs[1,2,1],_AllowedFaces or FaceConfigLimits[2],xVM,yVM+1,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[2]));
   // (0,1,1) -> (1,2,2), left top front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Left top front, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[3]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[0,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[0,2,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[0,1,1],_NeighbourVertexIDs[0,1,2],_NeighbourVertexIDs[0,2,1],_NeighbourVertexIDs[0,2,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,2,1], _NeighbourVertexIDs[1,2,2],_AllowedFaces or FaceConfigLimits[3],xVM,yVM+1,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[3]));
   // (1,0,0) -> (2,1,1), right bottom back side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right bottom back, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[4]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,0,0],_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[2,0,0],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,1,0], _NeighbourVertexIDs[2,1,1],_AllowedFaces or FaceConfigLimits[4],xVM+1,yVM,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[4]));
   // (1,0,1) -> (2,1,2), right bottom front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right bottom front, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[5]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,0,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,0,1],_NeighbourVertexIDs[1,0,2],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[2,0,1],_NeighbourVertexIDs[2,0,2],_NeighbourVertexIDs[2,1,1], _NeighbourVertexIDs[2,1,2],_AllowedFaces or FaceConfigLimits[5],xVM+1,yVM,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[5]));
   // (1,1,0) -> (2,2,1), right top back side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right top back, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[6]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,0]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,1]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,1,0],_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,2,0],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[2,1,0],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,2,0], _NeighbourVertexIDs[2,2,1],_AllowedFaces or FaceConfigLimits[6],xVM+1,yVM+1,zVM,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[6]));
   // (1,1,1) -> (2,2,2), right top front side
   {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Region: Right top front, Allowed Faces: ' + IntToStr(_AllowedFaces) + '//' + IntToStr(_AllowedFaces or FaceConfigLimits[7]) + ' and the vertexes are: (' + IntToStr(_NeighbourVertexIDs[1,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[1,2,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,1,2]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,1]) + ',' + IntToStr(_NeighbourVertexIDs[2,2,2]) + ')');
   {$endif}
   AddRefinementFaces(_NeighbourVertexIDs[1,1,1],_NeighbourVertexIDs[1,1,2],_NeighbourVertexIDs[1,2,1],_NeighbourVertexIDs[1,2,2],_NeighbourVertexIDs[2,1,1],_NeighbourVertexIDs[2,1,2],_NeighbourVertexIDs[2,2,1], _NeighbourVertexIDs[2,2,2],_AllowedFaces or FaceConfigLimits[7],xVM+1,yVM+1,zVM+1,_TriangleList,_QuadList,_FaceVerifier,GetColourSurface(_Voxel,_Palette,_x,_y,_z,FaceColorConfig[7]));
end;

end.
