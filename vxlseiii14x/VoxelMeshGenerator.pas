unit VoxelMeshGenerator;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, ClassVertexList, ClassTriangleList, ClassQuadList,
   Normals, Windows, ClassMeshNormalsTool, DifferentMeshFaceTypePlugin,
   MeshGeometryBase, MeshBRepGeometry, ClassMeshGeometryList,
   ClassRefinementTrianglesSupporter, Dialogs, SysUtils, ClassVolumeFaceVerifier;

{$INCLUDE Global_Conditionals.inc}

type
   TVoxelMeshGenerator = class
      private
         procedure BuildTriangleModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword);
         procedure BuildModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxelMapWithRefinementZones(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);

         procedure SetupVertexMap(var _VertexMap: T3DVolumeGreyIntData; _XSize,_YSize,_ZSize: integer);
         procedure BuildVertexMap(var _VertexMap: T3DVolumeGreyIntData; const _Voxel : TVoxelSection; var _NumVertices, _NumVoxels: longword);
         procedure FillVerticesArray(var _Vertices: TAVector3f; const _VertexMap: T3DVolumeGreyIntData; const _NumVertices: longword);
         procedure SetupFaceMap(var _FaceMap: T4DIntGrid; const _XSize, _YSize, _ZSize: integer);
         procedure BuildFaceMap(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure BuildFaceMap(var _FaceMap: T4DIntGrid; const _Voxel : TVoxelSection; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure BuildFaceMapI(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces: longword; const _VerticesPerFace: integer); overload;
         procedure FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumFaces: longword; const _VerticesPerFace: integer); overload;
         procedure FillTriangleFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces,_NumVertices: longword; const _VerticesPerFace: integer); overload;
         procedure BuildRefinementTriangles(const _Voxel : TVoxelSection; const _Palette: TPalette; var _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap;  var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _NumVertices: longword; var _VertexTransformation: aint32);
         procedure EliminateUselessVertices(var _VertexTransformation: aint32; var _Vertices: TAVector3f; var _Faces: auint32; var _NumVertices: longword);
      public
         VUnit: integer; // amount of times the cube is divided for each dimension
         constructor Create; overload;
         constructor Create(_VUnit: integer); overload;
         procedure LoadFromVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
         procedure LoadTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
         procedure LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: CMeshGeometryList; var _TexCoords: TAVector2f; var _NumVoxels: longword);
    end;

implementation

uses GlobalVars;

constructor TVoxelMeshGenerator.Create;
begin
   VUnit := 1;
end;

constructor TVoxelMeshGenerator.Create(_VUnit: integer);
begin
   VUnit := _VUnit;
end;

procedure TVoxelMeshGenerator.SetupVertexMap(var _VertexMap: T3DVolumeGreyIntData; _XSize,_YSize,_ZSize: integer);
begin
   // Let's map the vertices.
   _VertexMap := T3DVolumeGreyIntData.Create(VUnit * _XSize,VUnit * _YSize,VUnit * _ZSize);
   // clear map
   _VertexMap.Fill(C_VMG_NO_VERTEX);
end;

procedure TVoxelMeshGenerator.BuildVertexMap(var _VertexMap: T3DVolumeGreyIntData; const _Voxel : TVoxelSection; var _NumVertices, _NumVoxels: longword);
var
   x,y,z,xVert,yVert,zVert: integer;
   maxx, maxy, maxz: integer;
   V : TVoxelUnpacked;
begin
   _NumVertices := 0;
   _NumVoxels := 0;
   maxx := High(_Voxel.Data);
   maxy := High(_Voxel.Data[0]);
   maxz := High(_Voxel.Data[0,0]);
   x := Low(_Voxel.Data);
   xVert := x;
   while x <= maxx do
   begin
      y := Low(_Voxel.Data[x]);
      yVert := y;
      while y <= maxy do
      begin
         z := Low(_Voxel.Data[x,y]);
         zVert := z;
         while z <= maxz do
         begin
            _Voxel.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               inc(_NumVoxels);
               if _VertexMap.DataUnsafe[xVert,yVert,zVert] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert,yVert,zVert] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert+VUnit,yVert,zVert] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert+VUnit,yVert,zVert] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert,yVert+VUnit,zVert] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert,yVert+VUnit,zVert] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert+VUnit,yVert+VUnit,zVert] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert+VUnit,yVert+VUnit,zVert] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert,yVert,zVert+VUnit] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert,yVert,zVert+VUnit] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert+VUnit,yVert,zVert+VUnit] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert+VUnit,yVert,zVert+VUnit] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert,yVert+VUnit,zVert+VUnit] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert,yVert+VUnit,zVert+VUnit] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[xVert+VUnit,yVert+VUnit,zVert+VUnit] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[xVert+VUnit,yVert+VUnit,zVert+VUnit] := _NumVertices;
                  inc(_NumVertices);
               end;
            end;
            inc(z);
            inc(zVert,VUnit);
         end;
         inc(y);
         inc(yVert,VUnit);
      end;
      inc(x);
      inc(xVert,VUnit);
   end;

end;

procedure TVoxelMeshGenerator.FillVerticesArray(var _Vertices: TAVector3f; const _VertexMap: T3DVolumeGreyIntData; const _NumVertices: longword);
var
   x,y,z: integer;
begin
   SetLength(_Vertices,_NumVertices);
   for x := 0 to _VertexMap.MaxX do
      for y := 0 to _VertexMap.MaxY do
         for z := 0 to _VertexMap.MaxZ do
         begin
            if _VertexMap.DataUnsafe[x,y,z] <> C_VMG_NO_VERTEX then
            begin
               _Vertices[_VertexMap.DataUnsafe[x,y,z]].X := x div VUnit;
               _Vertices[_VertexMap.DataUnsafe[x,y,z]].Y := y div VUnit;
               _Vertices[_VertexMap.DataUnsafe[x,y,z]].Z := z div VUnit;
            end;
         end;
end;

procedure TVoxelMeshGenerator.SetupFaceMap(var _FaceMap: T4DIntGrid; const _XSize, _YSize, _ZSize: integer);
var
   x,y,z: integer;
begin
   SetLength(_FaceMap,_XSize,_YSize,_ZSize,3);
   // clear map
   for x := Low(_FaceMap) to High(_FaceMap) do
      for y := Low(_FaceMap[x]) to High(_FaceMap[x]) do
         for z := Low(_FaceMap[x,y]) to High(_FaceMap[x,y]) do
         begin
            _FaceMap[x,y,z,0] := C_VMG_NO_VERTEX;
            _FaceMap[x,y,z,1] := C_VMG_NO_VERTEX;
            _FaceMap[x,y,z,2] := C_VMG_NO_VERTEX;
         end;
end;

procedure TVoxelMeshGenerator.BuildFaceMap(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword);
var
   x,y,z,i: integer;
   v1, v2 : boolean;
begin
      // Now we give the faces an ID and count them.
   _NumFaces := 0;
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);

      // Checking for the side face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (x and x-1) that
      // this face splits are actually used.
      v1 := false;
      if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         v1 := true;
      v2 := false;
      if _VoxelMap.MapSafe[x,y+1,z+1] > C_OUTSIDE_VOLUME then
         v2 := true;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] := _NumFaces;
         inc(_NumFaces);
      end;

      // Checking for the height face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (y and y-1) that
      // this face splits are actually used.
      v2 := false;
      if _VoxelMap.MapSafe[x+1,y,z+1] > C_OUTSIDE_VOLUME then
         v2 := true;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] := _NumFaces;
         inc(_NumFaces);
      end;

      // Checking for the depth face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (z and z-1) that
      // this face splits are actually used.
      v2 := false;
      if _VoxelMap.MapSafe[x+1,y+1,z] > C_OUTSIDE_VOLUME then
         v2 := true;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] := _NumFaces;
         inc(_NumFaces);
      end;
   end;
end;

procedure TVoxelMeshGenerator.BuildFaceMap(var _FaceMap: T4DIntGrid; const _Voxel : TVoxelSection; const _Vertices: TAVector3f; var _NumFaces: longword);
var
   x,y,z,i: integer;
   v1, v2 : boolean;
   V : TVoxelUnpacked;
begin
   _NumFaces := 0;
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);

      // Checking for the side face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (x and x-1) that
      // this face splits are actually used.
      v1 := false;
      if _Voxel.GetVoxelSafe(x,y,z,v) then
         v1 := v.Used;
      v2 := false;
      if _Voxel.GetVoxelSafe(x-1,y,z,v) then
         v2 := v.Used;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] := _NumFaces;
         inc(_NumFaces);
      end;

      // Checking for the height face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (y and y-1) that
      // this face splits are actually used.
      v2 := false;
      if _Voxel.GetVoxelSafe(x,y-1,z,v) then
         v2 := v.Used;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] := _NumFaces;
         inc(_NumFaces);
      end;

      // Checking for the depth face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (z and z-1) that
      // this face splits are actually used.
      v2 := false;
      if _Voxel.GetVoxelSafe(x,y,z-1,v) then
         v2 := v.Used;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] := _NumFaces;
         inc(_NumFaces);
      end;
   end;
end;

procedure TVoxelMeshGenerator.BuildFaceMapI(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword);
var
   x,y,z,i: integer;
   value : single;
   v1, v2, interpolation : boolean;
begin
      // Now we give the faces an ID and count them.
   _NumFaces := 0;
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);

      // Checking for the side face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (x and x-1) that
      // this face splits are actually used.
      v1 := false;
      interpolation := false;
      value := _VoxelMap.MapSafe[x+1,y+1,z+1];
      if value >= 510 then
      begin
         v1 := true;
      end
      else if value = C_OUTSIDE_VOLUME then
      begin
         v1 := false;
      end
      else
      begin
         interpolation := true;
      end;

      if not interpolation then
      begin
         v2 := false;
         value := _VoxelMap.MapSafe[x,y+1,z+1];
         if value >= 510 then
         begin
            v2 := true;
         end
         else if value = C_OUTSIDE_VOLUME then
         begin
            v2 := false;
         end
         else
         begin
            interpolation := true;
         end;
         // We'll only make a face if exactly one of them is used.
         if (not interpolation) and (v1 xor v2) then
         begin
            // Then, we add the Face
            _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] := _NumFaces;
            inc(_NumFaces);
         end;

         // Checking for the height face.
         // Is there any chance of the user look at this face?
         // To know it, we need to check if the pixels (y and y-1) that
         // this face splits are actually used.
         v2 := false;
         interpolation := false;
         value := _VoxelMap.MapSafe[x+1,y,z+1];
         if value >= 510 then
         begin
            v2 := true;
         end
         else if value = C_OUTSIDE_VOLUME then
         begin
            v2 := false;
         end
         else
         begin
            interpolation := true;
         end;
         // We'll only make a face if exactly one of them is used.
         if (not interpolation) and (v1 xor v2) then
         begin
            // Then, we add the Face
            _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] := _NumFaces;
            inc(_NumFaces);
         end;

         // Checking for the depth face.
         // Is there any chance of the user look at this face?
         // To know it, we need to check if the pixels (z and z-1) that
         // this face splits are actually used.
         v2 := false;
         interpolation := false;
         value := _VoxelMap.MapSafe[x+1,y+1,z];
         if value >= 510 then
         begin
            v2 := true;
         end
         else if value = C_OUTSIDE_VOLUME then
         begin
            v2 := false;
         end
         else
         begin
            interpolation := true;
         end;
         // We'll only make a face if exactly one of them is used.
         if (not interpolation) and (v1 xor v2) then
         begin
            // Then, we add the Face
            _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] := _NumFaces;
            inc(_NumFaces);
         end;
      end;
   end;
end;


procedure TVoxelMeshGenerator.FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumFaces: longword; const _VerticesPerFace: integer);
var
   x,y,z,xU,yU,zU,i,f: integer;
   V : TVoxelUnpacked;
begin
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);
      xU := x * VUnit;
      yU := y * VUnit;
      zU := z * VUnit;
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x-1,y,z,v);
               _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
               _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
               _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
               _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            end
            else
            begin
               _Faces[f] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
               _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
               _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
               _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL4[v.Colour];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x,y-1,z,v);
               _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
               _Faces[f+1] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
               _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
               _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            end
            else
            begin
               _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
               _Faces[f+2] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
               _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
               _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL4[v.Colour];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x,y,z-1,v);
               _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
               _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
               _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
               _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            end
            else
            begin
               _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
               _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
               _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
               _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]] := _Palette.ColourGL4[v.Colour];
      end;
   end;
end;

procedure TVoxelMeshGenerator.FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces: longword; const _VerticesPerFace: integer);
var
   x,y,z,xU,yU,zU,i,f: integer;
   V : TVoxelUnpacked;
begin
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      _VertexTransformation[i] := C_VMG_NO_VERTEX;
   end;

   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);
      xU := x * VUnit;
      yU := y * VUnit;
      zU := z * VUnit;
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit]] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU+VUnit,zU]] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU]] := _VertexMap.DataUnsafe[xU,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU+VUnit]] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit]] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU,zU]] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU]] := _VertexMap.DataUnsafe[xU,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU+VUnit]] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+2] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU]] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU+VUnit,zU]] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU]] := _VertexMap.DataUnsafe[xU,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU,zU]] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
      end;
   end;
end;

procedure TVoxelMeshGenerator.FillTriangleFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces,_NumVertices: longword; const _VerticesPerFace: integer);
var
   x,y,z,xU,yU,zU,i,f,fl,cv: integer;
   V : TVoxelUnpacked;
   maxVertex : integer;
begin
   for i := Low(_VertexTransformation) to _NumVertices - 1 do
   begin
      _VertexTransformation[i] := C_VMG_NO_VERTEX;
   end;
   for i := _NumVertices to High(_VertexTransformation) do
   begin
      _VertexTransformation[i] := i;
   end;

   maxVertex := _NumVertices-1;
   for i := Low(_Vertices) to maxVertex do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);
      xU := x * VUnit;
      yU := y * VUnit;
      zU := z * VUnit;
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> C_VMG_NO_VERTEX then
      begin
         // add the central vertex.
         _Vertices[_NumVertices].X := x;
         _Vertices[_NumVertices].Y := y + 0.5;
         _Vertices[_NumVertices].Z := z + 0.5;
         cv := _NumVertices;
         inc(_NumVertices);
         // Now that we have the vertices, we can grab voxel data (v).
         fl := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * 4;
         f := fl * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+4] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+7] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+10] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+4] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+7] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
            _Faces[f+10] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+11] := cv;
         end;
         // Normals
         _FaceNormals[fl].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+1].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+1].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+1].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+2].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+2].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+2].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+3].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+3].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+3].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[fl] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+1] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+2] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+3] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit]] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU+VUnit];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU+VUnit,zU]] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU]] := _VertexMap.DataUnsafe[xU,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU+VUnit]] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> C_VMG_NO_VERTEX then
      begin
         // add the central vertex.
         _Vertices[_NumVertices].X := x + 0.5;
         _Vertices[_NumVertices].Y := y;
         _Vertices[_NumVertices].Z := z + 0.5;
         cv := _NumVertices;
         inc(_NumVertices);
         // Now that we have the vertices, we can grab voxel data (v).
         fl := _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * 4;
         f := fl * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+4] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+7] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+10] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+4] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+7] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
            _Faces[f+10] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
            _Faces[f+11] := cv;
         end;
         // Normals
         _FaceNormals[fl].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+1].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+1].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+1].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+2].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+2].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+2].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+3].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+3].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+3].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[fl] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+1] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+2] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+3] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit]] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU+VUnit];
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU,zU]] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU]] := _VertexMap.DataUnsafe[xU,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU+VUnit]] := _VertexMap.DataUnsafe[xU,yU,zU+VUnit];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> C_VMG_NO_VERTEX then
      begin
         // add the central vertex.
         _Vertices[_NumVertices].X := x + 0.5;
         _Vertices[_NumVertices].Y := y + 0.5;
         _Vertices[_NumVertices].Z := z;
         cv := _NumVertices;
         inc(_NumVertices);
         // Now that we have the vertices, we can grab voxel data (v).
         fl := _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * 4;
         f :=  fl * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+4] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+7] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+10] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+1] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
            _Faces[f+4] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[xU,yU,zU];
            _Faces[f+7] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
            _Faces[f+10] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
            _Faces[f+11] := cv;
         end;
         // Normals
         _FaceNormals[fl].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+1].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+1].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+1].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+2].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+2].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+2].Z := _Voxel.Normals[v.Normal].Z;
         _FaceNormals[fl+3].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[fl+3].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[fl+3].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[fl] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+1] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+2] := _Palette.ColourGL4[v.Colour];
         _Colours[fl+3] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU]] := _VertexMap.DataUnsafe[xU+VUnit,yU+VUnit,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU+VUnit,zU]] := _VertexMap.DataUnsafe[xU,yU+VUnit,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU,yU,zU]] := _VertexMap.DataUnsafe[xU,yU,zU];
         _VertexTransformation[_VertexMap.DataUnsafe[xU+VUnit,yU,zU]] := _VertexMap.DataUnsafe[xU+VUnit,yU,zU];
      end;
   end;
end;

// Refinement zones are regions that are neighbour to two surface voxels that
// are 'linked by edge or vertex'. These zones, while considered to be out of
// the volume, they'll have part of the volume of the model, in order to avoid
// regions where the internal volume does not exist, therefore not being
// manifolds. We'll do a sort of marching cubes on these regions.

// Here we build triangles or quads at refinement zones.
procedure TVoxelMeshGenerator.BuildRefinementTriangles(const _Voxel : TVoxelSection; const _Palette: TPalette; var _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap;  var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _NumVertices: longword; var _VertexTransformation: aint32);
var
   x,y,z,id,OldNumVertices,VUnitPlus1: integer;
   V : TVoxelUnpacked;
   c: single;
   FaceConfig : integer;
   NeighbourVertexIDs: T3DIntGrid;
   TriangleList: CTriangleList;
   QuadList: CQuadList;
   FaceVerifier: CVolumeFaceVerifier;
   Tool: CRefinementTrianglesSupporter;
begin
   VUnitPlus1 := VUnit + 1;
   Tool := CRefinementTrianglesSupporter.Create;
   TriangleList := CTriangleList.Create;
   QuadList := CQuadList.Create;
   OldNumVertices := _NumVertices;
   SetLength(NeighbourVertexIDs,VUnitPlus1,VUnitPlus1,VUnitPlus1);
   FaceVerifier := CVolumeFaceVerifier.Create(_VertexMap.XSize,_VertexMap.YSize,_VertexMap.ZSize);
   // visit every region.
   for x := 0 to _VoxelMap.GetMaxX do
      for y := 0 to _VoxelMap.GetMaxY do
         for z := 0 to _VoxelMap.GetMaxZ do
         begin
            // if the region is an refinement zone, then...
            if (_VoxelMap.Map[x,y,z] > 0.9) and (_VoxelMap.Map[x,y,z] < 256) then
            begin
               // Subdivision starts here...

               // Detect face configuration
               FaceConfig := 255;//0;
               // Axis X
{
               if _VoxelMap.MapSafe[x-1,y,z] < 256 then
                  FaceConfig := FaceConfig or 32;
               if _VoxelMap.MapSafe[x+1,y,z] < 256 then
                  FaceConfig := FaceConfig or 16;
               // Axis Y
               if _VoxelMap.MapSafe[x,y-1,z] < 256 then
                  FaceConfig := FaceConfig or 8;
               if _VoxelMap.MapSafe[x,y+1,z] < 256 then
                  FaceConfig := FaceConfig or 4;
               // Axis Z
               if _VoxelMap.MapSafe[x,y,z-1] < 256 then
                  FaceConfig := FaceConfig or 2;
               if _VoxelMap.MapSafe[x,y,z+1] < 256 then
                  FaceConfig := FaceConfig or 1;
}
               // Let's check its neighbour faces, edges and vertexes. We'll
               // fill the potential vertexes that this region may receive
               // according to the following criteria. If a face neighbour
               // exists, we'll fill every vertex in its face. A similar
               // approach applies to neighbour edges and vertexes.

               {$ifdef MESH_TEST}
               GlobalVars.MeshFile.Add('...');
               GlobalVars.MeshFile.Add('Next region is: (' + IntToStr(x-1) + ',' + IntToStr(y-1) + ',' + IntToStr(z-1) + ') and it will be subdivided!');
               {$endif}
               Tool.InitializeNeighbourVertexIDsSize(NeighbourVertexIDs,_VertexMap,_VoxelMap,x-1,y-1,z-1,VUnit,_VertexTransformation,_NumVertices);
               Tool.DetectPotentialVertexes(_VoxelMap,_VertexMap,NeighbourVertexIDs,x,y,z,VUnit,_NumVertices);
               Tool.AddRefinementFacesFromRegions(_Voxel,_Palette,NeighbourVertexIDs,TriangleList,QuadList,FaceVerifier,x-1,y-1,z-1,FaceConfig,VUnit);
            end;
         end;
   QuadList.CleanUpBadQuads;
   TriangleList.CleanUpBadTriangles;
   if ((TriangleList.Count + QuadList.Count) > 0) then
   begin
      // Build new vertexes.
      if _NumVertices > OldNumVertices then
      begin
         SetLength(_Vertices,_NumVertices);
         {$ifdef MESH_TEST}
         GlobalVars.MeshFile.Add('...');
         GlobalVars.MeshFile.Add('We have ' + IntToStr(_NumVertices) + ' distributed in the following way:');
         {$endif}
         x := 0;
         while x <= _VertexMap.MaxX do
         begin
            y := 0;
            while y <= _VertexMap.MaxY do
            begin
               z := 0;
               while z <= _VertexMap.MaxZ do
               begin
                  id := _VertexMap.DataUnsafe[x,y,z];
                  if id <> C_VMG_NO_VERTEX then
                  begin
                     _Vertices[id].X := x / VUnit;
                     _Vertices[id].Y := y / VUnit;
                     _Vertices[id].Z := z / VUnit;
                    {$ifdef MESH_TEST}
                    GlobalVars.MeshFile.Add('Vertex ' + IntToStr(id) + ' Location: (' + FloatToStr(_Vertices[id].X) + ';' + FloatToStr(_Vertices[id].Y) + ';' + FloatToStr(_Vertices[id].Z) + ').');
                    {$endif}
                  end;
                  inc(z,1);
               end;
               inc(y,1);
            end;
            inc(x,1);
         end;
         SetLength(_VertexTransformation,_NumVertices);
         for x := OldNumVertices to High(_Vertices) do
         begin
            _VertexTransformation[x] := C_VMG_NO_VERTEX;
         end;
      end;

      // Add all new faces
      _Geometry.AddQuadsFromList(QuadList,_Vertices);
      _Geometry.ConvertQuadsToTris();
      _Geometry.AddTrianglesFromList(TriangleList,_Vertices);

      // Ensure that these new vertexes will be used.
      QuadList.GoToFirstElement;
      x := 0;
      while x < QuadList.Count do
      begin
         _VertexTransformation[QuadList.V1] := QuadList.V1;
         _VertexTransformation[QuadList.V2] := QuadList.V2;
         _VertexTransformation[QuadList.V3] := QuadList.V3;
         _VertexTransformation[QuadList.V4] := QuadList.V4;
         QuadList.GoToNextElement;
         inc(x);
      end;
      TriangleList.GoToFirstElement;
      x := 0;
      while x < TriangleList.Count do
      begin
         _VertexTransformation[TriangleList.V1] := TriangleList.V1;
         _VertexTransformation[TriangleList.V2] := TriangleList.V2;
         _VertexTransformation[TriangleList.V3] := TriangleList.V3;
         TriangleList.GoToNextElement;
         inc(x);
      end;
   end;
   // Free memory.
   TriangleList.Free;
   QuadList.Free;
   FaceVerifier.Free;
   Tool.Free;
   for x := 0 to 2 do
   begin
      for y := 0 to 2 do
      begin
         SetLength(NeighbourVertexIDs[x,y],0);
      end;
      SetLength(NeighbourVertexIDs[x],0);
   end;
   SetLength(NeighbourVertexIDs,0);
end;


procedure TVoxelMeshGenerator.EliminateUselessVertices(var _VertexTransformation: aint32; var _Vertices: TAVector3f; var _Faces: auint32; var _NumVertices: longword);
var
   HitCounter, i: integer;
begin
   HitCounter := 0;
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      if _VertexTransformation[i] = i then
      begin
         _VertexTransformation[i] := HitCounter;
         inc(HitCounter);
      end;
   end;
   // Update faces according to the new indexes.
   for i := Low(_Faces) to High(_Faces) do
   begin
      _Faces[i] := _VertexTransformation[_Faces[i]];
   end;
   // Update Vertice list.
   _NumVertices := HitCounter;
   for i := Low(_VertexTransformation) to High(_VertexTransformation) do
   begin
      if _VertexTransformation[i] <> C_VMG_NO_VERTEX then
      begin
         _Vertices[_VertexTransformation[i]].X := _Vertices[i].X;
         _Vertices[_VertexTransformation[i]].Y := _Vertices[i].Y;
         _Vertices[_VertexTransformation[i]].Z := _Vertices[i].Z;
      end;
   end;
   SetLength(_Vertices,_NumVertices);
end;

procedure TVoxelMeshGenerator.BuildModelFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword);
var
   NumVertices,NumFaces : longword;
   VertexMap : T3DVolumeGreyIntData;
   FaceMap : T4DIntGrid;
   x, y, z : longword;
begin
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.

   // Let's map the vertices.
   SetupVertexMap(VertexMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the vertices an ID and count them.
   BuildVertexMap(VertexMap,_Voxel,NumVertices,_NumVoxels);
   // vertex map is done. If there is no vertex, quit.
   if NumVertices = 0 then
   begin
      _Geometry.NumFaces := 0;
      SetLength(_TexCoords,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMap(FaceMap,_Voxel,_Vertices,NumFaces);
   // face map is done.
   _Geometry.NumFaces := NumFaces;
   SetLength(_TexCoords,0);
   // let's fill the faces array, normals, colours, etc.
   FillQuadFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Geometry.Faces,_Geometry.Colours,_Geometry.Normals,_TexCoords,_NumVoxels,_Geometry.VerticesPerFace);
   // Free memory
   VertexMap.Free;
   for x := Low(FaceMap) to High(FaceMap) do
   begin
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
      begin
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            SetLength(FaceMap[x,y,z],0);
         end;
         SetLength(FaceMap[x,y],0);
      end;
      SetLength(FaceMap[x],0);
   end;
   SetLength(FaceMap,0);
end;

procedure TVoxelMeshGenerator.BuildModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
var
   NumVertices,NumFaces : longword;
   VertexMap : T3DVolumeGreyIntData;
   FaceMap : T4DIntGrid;
   VertexTransformation: aint32;
   x, y, z : longword;
begin
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.

   // Let's map the vertices.
   SetupVertexMap(VertexMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the vertices an ID and count them.
   BuildVertexMap(VertexMap,_Voxel,NumVertices,_NumVoxels);
   // vertex map is done. If there is no vertex, quit.
   if NumVertices = 0 then
   begin
      _Geometry.NumFaces := 0;
      SetLength(_TexCoords,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMap(FaceMap,_VoxelMap,_Vertices,NumFaces);
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   _Geometry.NumFaces := NumFaces;
   SetLength(_TexCoords,0);
   SetLength(VertexTransformation,High(_Vertices)+1);
   FillQuadFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Geometry.Faces,_Geometry.Colours,_Geometry.Normals,_TexCoords,_VoxelMap,VertexTransformation,_NumVoxels,_Geometry.VerticesPerFace);

   // Get the positions of the vertexes in the new vertex list, so we can eliminate
   // the unused ones.
   EliminateUselessVertices(VertexTransformation,_Vertices,_Geometry.Faces,NumVertices);
   // Free memory
   SetLength(VertexTransformation,0);
   VertexMap.Free;
   for x := Low(FaceMap) to High(FaceMap) do
   begin
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
      begin
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            SetLength(FaceMap[x,y,z],0);
         end;
         SetLength(FaceMap[x,y],0);
      end;
      SetLength(FaceMap[x],0);
   end;
   SetLength(FaceMap,0);
end;

procedure TVoxelMeshGenerator.BuildModelFromVoxelMapWithRefinementZones(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
var
   NumVertices,NumFaces : longword;
   VertexMap : T3DVolumeGreyIntData;
   FaceMap : T4DIntGrid;
   VertexTransformation: aint32;
   x, y, z : longword;
begin
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.

   // Let's map the vertices.
   SetupVertexMap(VertexMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the vertices an ID and count them.
   BuildVertexMap(VertexMap,_Voxel,NumVertices,_NumVoxels);
   // vertex map is done. If there is no vertex, quit.
   if NumVertices = 0 then
   begin
      _Geometry.NumFaces := 0;
      SetLength(_TexCoords,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMapI(FaceMap,_VoxelMap,_Vertices,NumFaces);
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   _Geometry.NumFaces := NumFaces;
   SetLength(_TexCoords,0);
   SetLength(VertexTransformation,High(_Vertices)+1);
   FillQuadFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Geometry.Faces,_Geometry.Colours,_Geometry.Normals,_TexCoords,_VoxelMap,VertexTransformation,_NumVoxels,_Geometry.VerticesPerFace);
   // Here we build the triangles from the refinement zones.
   BuildRefinementTriangles(_Voxel,_Palette,VertexMap,_VoxelMap,_Vertices,_Geometry,NumVertices,VertexTransformation);
   // Get the positions of the vertexes in the new vertex list, so we can eliminate
   // the unused ones.
   EliminateUselessVertices(VertexTransformation,_Vertices,_Geometry.Faces,NumVertices);
   // Free memory
   SetLength(VertexTransformation,0);
   VertexMap.Free;
   for x := Low(FaceMap) to High(FaceMap) do
   begin
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
      begin
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            SetLength(FaceMap[x,y,z],0);
         end;
         SetLength(FaceMap[x,y],0);
      end;
      SetLength(FaceMap[x],0);
   end;
   SetLength(FaceMap,0);
end;

procedure TVoxelMeshGenerator.BuildTriangleModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
var
   NumVertices,NumFaces : longword;
   VertexMap : T3DVolumeGreyIntData;
   FaceMap : T4DIntGrid;
   VertexTransformation: aint32;
   x, y, z : longword;
begin
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.

   // Let's map the vertices.
   SetupVertexMap(VertexMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the vertices an ID and count them.
   BuildVertexMap(VertexMap,_Voxel,NumVertices,_NumVoxels);
   // vertex map is done. If there is no vertex, quit.
   if NumVertices = 0 then
   begin
      _Geometry.NumFaces := 0;
      SetLength(_TexCoords,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMap(FaceMap,_VoxelMap,_Vertices,NumFaces);
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   SetLength(_Vertices,High(_Vertices)+NumFaces+1);
   _Geometry.NumFaces := NumFaces * 4;
   SetLength(_TexCoords,0);
   SetLength(VertexTransformation,High(_Vertices)+1);
   FillTriangleFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Geometry.Faces,_Geometry.Colours,_Geometry.Normals,_TexCoords,_VoxelMap,VertexTransformation,_NumVoxels,NumVertices,_Geometry.VerticesPerFace);

   // Get the positions of the vertexes in the new vertex list, so we can eliminate
   // the unused ones.
   EliminateUselessVertices(VertexTransformation,_Vertices,_Geometry.Faces,NumVertices);
   // Free memory
   SetLength(VertexTransformation,0);
   VertexMap.Free;
   for x := Low(FaceMap) to High(FaceMap) do
   begin
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
      begin
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            SetLength(FaceMap[x,y,z],0);
         end;
         SetLength(FaceMap[x,y],0);
      end;
      SetLength(FaceMap[x],0);
   end;
   SetLength(FaceMap,0);
end;


procedure TVoxelMeshGenerator.LoadFromVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
var
   Geometry: PMeshBRepGeometry;
begin
   _Geometry.GoToFirstElement;
   Geometry := PMeshBRepGeometry(_Geometry.Current);
   BuildModelFromVoxel(_Voxel,_Palette,_Vertices,Geometry^,_TexCoords,_NumVoxels);
end;

procedure TVoxelMeshGenerator.LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
var
   VoxelMap: TVoxelMap;
   Geometry: PMeshBRepGeometry;
begin
   _Geometry.GoToFirstElement;
   Geometry := PMeshBRepGeometry(_Geometry.Current);
   // Let's map our voxels.
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;

   BuildModelFromVoxelMap(_Voxel,_Palette,_Vertices,Geometry^,_TexCoords,_NumVoxels,VoxelMap);

   VoxelMap.Free;
end;

procedure TVoxelMeshGenerator.LoadTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
var
   VoxelMap: TVoxelMap;
   Geometry: PMeshBRepGeometry;
begin
   _Geometry.GoToFirstElement;
   Geometry := PMeshBRepGeometry(_Geometry.Current);
   // Let's map our voxels.
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;

   BuildTriangleModelFromVoxelMap(_Voxel,_Palette,_Vertices,Geometry^,_TexCoords,_NumVoxels,VoxelMap);

   VoxelMap.Free;
end;

procedure TVoxelMeshGenerator.LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: CMeshGeometryList; var _TexCoords: TAVector2f; var _NumVoxels: longword);
var
   VoxelMap: TVoxelMap;
   Geometry: PMeshBRepGeometry;
begin
   _Geometry.GoToFirstElement;
   Geometry := PMeshBRepGeometry(_Geometry.Current);
   // Let's map our voxels.
   {$ifdef MESH_TEST}
   GlobalVars.MeshFile.Add('Initializing Mesh Extraction');
   GlobalVars.MeshFile.Add('...');
   GlobalVars.MeshFile.Add('Surface Detection Starts now...');
  {$endif}
   VUnit := 2;
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceAndRefinementMap;

   {$ifdef MESH_TEST}
   GlobalVars.MeshFile.Add('Model Generation Starts now...');
  {$endif}
   BuildModelFromVoxelMapWithRefinementZones(_Voxel,_Palette,_Vertices,Geometry^,_TexCoords,_NumVoxels,VoxelMap);
   {$ifdef MESH_TEST}
   GlobalVars.MeshFile.Add('Mesh Extraction has been terminated...');
  {$endif}

   VoxelMap.Free;
end;

end.
