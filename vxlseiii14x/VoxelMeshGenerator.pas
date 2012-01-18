unit VoxelMeshGenerator;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, ClassVertexList, ClassTriangleList, ClassQuadList,
   Normals, Windows, ClassMeshNormalsTool, DifferentMeshFaceTypePlugin,
   MeshGeometryBase, MeshBRepGeometry, ClassMeshGeometryList,
   ClassInterpolationTrianglesSupporter;

type
   TVoxelMeshGenerator = class
      private
         procedure BuildTriangleModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _TexCoords: TAVector2f; var _NumVoxels: longword);

         procedure SetupVertexMap(var _VertexMap: T3DVolumeGreyIntData; _XSize,_YSize,_ZSize: integer);
         procedure BuildVertexMap(var _VertexMap: T3DVolumeGreyIntData; const _Voxel : TVoxelSection; var _NumVertices, _NumVoxels: longword);
         procedure FillVerticesArray(var _Vertices: TAVector3f; const _VertexMap: T3DVolumeGreyIntData; const _NumVertices: longword);
         procedure SetupFaceMap(var _FaceMap: T4DIntGrid; const _XSize, _YSize, _ZSize: integer);
         procedure BuildFaceMap(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure BuildFaceMap(var _FaceMap: T4DIntGrid; const _Voxel : TVoxelSection; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces: longword; const _VerticesPerFace: integer); overload;
         procedure FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumFaces: longword; const _VerticesPerFace: integer); overload;
         procedure FillTriangleFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces,_NumVertices: longword; const _VerticesPerFace: integer); overload;
         procedure BuildInterpolationTriangles(const _Voxel : TVoxelSection; const _Palette: TPalette; const _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap;  var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _NumVertices: longword);
         procedure EliminateUselessVertices(var _VertexTransformation: aint32; var _Vertices: TAVector3f; var _Faces: auint32; var _NumVertices: longword);
      public
         procedure LoadFromVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
         procedure LoadTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _TexCoords: TAVector2f; var _Geometry: CMeshGeometryList; var _NumVoxels: longword);
         procedure LoadQuadsWithTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: CMeshGeometryList; var _TexCoords: TAVector2f; var _NumVoxels: longword);
    end;

implementation

procedure TVoxelMeshGenerator.SetupVertexMap(var _VertexMap: T3DVolumeGreyIntData; _XSize,_YSize,_ZSize: integer);
begin
   // Let's map the vertices.
   _VertexMap := T3DVolumeGreyIntData.Create(_XSize,_YSize,_ZSize);
   // clear map
   _VertexMap.Fill(C_VMG_NO_VERTEX);
end;

procedure TVoxelMeshGenerator.BuildVertexMap(var _VertexMap: T3DVolumeGreyIntData; const _Voxel : TVoxelSection; var _NumVertices, _NumVoxels: longword);
var
   x,y,z: integer;
   V : TVoxelUnpacked;
begin
   _NumVertices := 0;
   _NumVoxels := 0;
   for x := Low(_Voxel.Data) to High(_Voxel.Data) do
      for y := Low(_Voxel.Data[x]) to High(_Voxel.Data[x]) do
         for z := Low(_Voxel.Data[x,y]) to High(_Voxel.Data[x,y]) do
         begin
            _Voxel.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               inc(_NumVoxels);
               if _VertexMap.DataUnsafe[x,y,z] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x,y,z] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x+1,y,z] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x+1,y,z] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x,y+1,z] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x,y+1,z] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x+1,y+1,z] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x+1,y+1,z] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x,y,z+1] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x,y,z+1] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x+1,y,z+1] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x+1,y,z+1] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x,y+1,z+1] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x,y+1,z+1] := _NumVertices;
                  inc(_NumVertices);
               end;
               if _VertexMap.DataUnsafe[x+1,y+1,z+1] = C_VMG_NO_VERTEX then
               begin
                  _VertexMap.DataUnsafe[x+1,y+1,z+1] := _NumVertices;
                  inc(_NumVertices);
               end;
            end;
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
               _Vertices[_VertexMap.DataUnsafe[x,y,z]].X := x;
               _Vertices[_VertexMap.DataUnsafe[x,y,z]].Y := y;
               _Vertices[_VertexMap.DataUnsafe[x,y,z]].Z := z;
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

procedure TVoxelMeshGenerator.FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumFaces: longword; const _VerticesPerFace: integer);
var
   x,y,z,i,f: integer;
   V : TVoxelUnpacked;
begin
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x-1,y,z,v);
               _Faces[f+3] := _VertexMap.DataUnsafe[x,y+1,z+1];
               _Faces[f+2] := _VertexMap.DataUnsafe[x,y+1,z];
               _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
               _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
            end
            else
            begin
               _Faces[f] := _VertexMap.DataUnsafe[x,y+1,z+1];
               _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
               _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
               _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z+1];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
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
               _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z+1];
               _Faces[f+1] := _VertexMap.DataUnsafe[x+1,y,z];
               _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
               _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z+1];
            end
            else
            begin
               _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y,z+1];
               _Faces[f+2] := _VertexMap.DataUnsafe[x+1,y,z];
               _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
               _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z+1];
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
               _Faces[f] := _VertexMap.DataUnsafe[x+1,y+1,z];
               _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
               _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
               _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y,z];
            end
            else
            begin
               _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y+1,z];
               _Faces[f+2] := _VertexMap.DataUnsafe[x,y+1,z];
               _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
               _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y+1,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y,z];
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
   x,y,z,i,f: integer;
   V : TVoxelUnpacked;
begin
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      _VertexTransformation[i] := -1;
   end;

   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> C_VMG_NO_VERTEX then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z+1];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[x,y+1,z+1]] := _VertexMap.DataUnsafe[x,y+1,z+1];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y+1,z]] := _VertexMap.DataUnsafe[x,y+1,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z]] := _VertexMap.DataUnsafe[x,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z+1]] := _VertexMap.DataUnsafe[x,y,z+1];
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
            _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y,z+1];
            _Faces[f+2] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z+1];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y,z+1]] := _VertexMap.DataUnsafe[x+1,y,z+1];
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y,z]] := _VertexMap.DataUnsafe[x+1,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z]] := _VertexMap.DataUnsafe[x,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z+1]] := _VertexMap.DataUnsafe[x,y,z+1];
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
            _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y+1,z];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y+1,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+2] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y,z];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y+1,z]] := _VertexMap.DataUnsafe[x+1,y+1,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y+1,z]] := _VertexMap.DataUnsafe[x,y+1,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z]] := _VertexMap.DataUnsafe[x,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y,z]] := _VertexMap.DataUnsafe[x+1,y,z];
      end;
   end;
end;

procedure TVoxelMeshGenerator.FillTriangleFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DVolumeGreyIntData; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces,_NumVertices: longword; const _VerticesPerFace: integer);
var
   x,y,z,i,f,fl,cv: integer;
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
            _Faces[f] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+4] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+7] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+10] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+4] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+7] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[x,y+1,z+1];
            _Faces[f+10] := _VertexMap.DataUnsafe[x,y,z+1];
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
         _VertexTransformation[_VertexMap.DataUnsafe[x,y+1,z+1]] := _VertexMap.DataUnsafe[x,y+1,z+1];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y+1,z]] := _VertexMap.DataUnsafe[x,y+1,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z]] := _VertexMap.DataUnsafe[x,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z+1]] := _VertexMap.DataUnsafe[x,y,z+1];
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
            _Faces[f] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+4] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+7] := _VertexMap.DataUnsafe[x+1,y,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[x+1,y,z+1];
            _Faces[f+10] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z+1];
            _Faces[f+1] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+4] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+7] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[x,y,z+1];
            _Faces[f+10] := _VertexMap.DataUnsafe[x+1,y,z+1];
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
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y,z+1]] := _VertexMap.DataUnsafe[x+1,y,z+1];
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y,z]] := _VertexMap.DataUnsafe[x+1,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z]] := _VertexMap.DataUnsafe[x,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z+1]] := _VertexMap.DataUnsafe[x,y,z+1];
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
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+4] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+7] := _VertexMap.DataUnsafe[x+1,y+1,z];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[x+1,y+1,z];
            _Faces[f+10] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap.DataUnsafe[x+1,y+1,z];
            _Faces[f+1] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap.DataUnsafe[x,y+1,z];
            _Faces[f+4] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap.DataUnsafe[x,y,z];
            _Faces[f+7] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap.DataUnsafe[x+1,y,z];
            _Faces[f+10] := _VertexMap.DataUnsafe[x+1,y+1,z];
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
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y+1,z]] := _VertexMap.DataUnsafe[x+1,y+1,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y+1,z]] := _VertexMap.DataUnsafe[x,y+1,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x,y,z]] := _VertexMap.DataUnsafe[x,y,z];
         _VertexTransformation[_VertexMap.DataUnsafe[x+1,y,z]] := _VertexMap.DataUnsafe[x+1,y,z];
      end;
   end;
end;

// Interpolation zones are regions that are neighbour to two surface voxels that
// are 'linked by edge or vertex'. These zones, while considered to be out of
// the volume, they'll have part of the volume of the model, in order to avoid
// regions where the internal volume does not exist, therefore not being
// manifolds. We'll do a sort of marching cubes on these regions.

// Here we build triangles or quads at interpolation zones.
// Under Construction

procedure TVoxelMeshGenerator.BuildInterpolationTriangles(const _Voxel : TVoxelSection; const _Palette: TPalette; const _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap;  var _Vertices: TAVector3f; var _Geometry: TMeshBRepGeometry; var _NumVertices: longword);
var
   x,y,z,OldNumVertices: integer;
   V : TVoxelUnpacked;
   SubdivisionSituation,FaceConfig : integer;
   NeighbourVertexIDs: T3DIntGrid;
   VertexList: CVertexList;
   TriangleList: CTriangleList;
   QuadList: CQuadList;
   Tool: CInterpolationTrianglesSupporter;
begin
   Tool := CInterpolationTrianglesSupporter.Create;
   VertexList := CVertexList.Create;
   TriangleList := CTriangleList.Create;
   QuadList := CQuadList.Create;
   OldNumVertices := _NumVertices;
   SetLength(NeighbourVertexIDs,4,4,4);
   // visit every region.
   for x := 0 to _VoxelMap.GetMaxX do
      for y := 0 to _VoxelMap.GetMaxY do
         for z := 0 to _VoxelMap.GetMaxZ do
         begin
            // if the region is an interpolation zone, then...
            if (_VoxelMap.Map[x,y,z] > 0) and (_VoxelMap.Map[x,y,z] < 256) then
            begin
               // Should we subdivide it? If an interpolation zone has all 8
               // corners filled (=255), then the answer is yes. Otherwise, no.
               if (_VoxelMap.Map[x,y,z] = 255) then
               begin
                  // Subdivision starts here...

                  // Let's check its neighbour faces. If opposite faces are part
                  // of the surface, then we divide the region in its direction.

                  // Axis X
                  SubdivisionSituation := 0;
                  _Voxel.GetVoxelSafe(x-1,y,z,v);
                  if v.Used then
                  begin
                     FaceConfig := FaceConfig or 32;
                     _Voxel.GetVoxelSafe(x+1,y,z,v);
                     if v.Used then
                     begin
                        SubdivisionSituation := SubdivisionSituation or 4;
                        FaceConfig := FaceConfig or 16;
                     end;
                  end
                  else
                  begin
                     _Voxel.GetVoxelSafe(x+1,y,z,v);
                     if v.Used then
                     begin
                        FaceConfig := FaceConfig or 16;
                     end;
                  end;

                  // Axis Y
                  _Voxel.GetVoxelSafe(x,y-1,z,v);
                  if v.Used then
                  begin
                     FaceConfig := FaceConfig or 8;
                     _Voxel.GetVoxelSafe(x,y+1,z,v);
                     if v.Used then
                     begin
                        SubdivisionSituation := SubdivisionSituation or 2;
                        FaceConfig := FaceConfig or 4;
                     end;
                  end
                  else
                  begin
                     _Voxel.GetVoxelSafe(x,y+1,z,v);
                     if v.Used then
                     begin
                        FaceConfig := FaceConfig or 4;
                     end;
                  end;

                  // Axis Z
                  _Voxel.GetVoxelSafe(x,y,z-1,v);
                  if v.Used then
                  begin
                     FaceConfig := FaceConfig or 2;
                     _Voxel.GetVoxelSafe(x,y,z+1,v);
                     if v.Used then
                     begin
                        SubdivisionSituation := SubdivisionSituation or 1;
                        FaceConfig := FaceConfig or 1;
                     end;
                  end
                  else
                  begin
                     _Voxel.GetVoxelSafe(x,y,z+1,v);
                     if v.Used then
                     begin
                        FaceConfig := FaceConfig or 1;
                     end;
                  end;


                  // Now we operate each piece according to each situation
                  case (SubdivisionSituation) of
                     1: // subdivides z only
                     begin
                        Tool.InitializeNeighbourVertexIDsSize3(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add Vertexes
                        Tool.AddVertexToTarget(NeighbourVertexIDs[0,0,1],VertexList,_NumVertices,x,y,z+0.5);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[0,2,1],VertexList,_NumVertices,x,y+1,z+0.5);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[2,0,1],VertexList,_NumVertices,x+1,y,z+0.5);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[2,2,1],VertexList,_NumVertices,x+1,y+1,z+0.5);
                        // Add Faces
                        Tool.AddInterpolationFaces(NeighbourVertexIDs[0,0,0],NeighbourVertexIDs[0,0,1],NeighbourVertexIDs[0,2,0],NeighbourVertexIDs[0,2,1],NeighbourVertexIDs[2,0,0],NeighbourVertexIDs[2,0,1],NeighbourVertexIDs[2,2,0],NeighbourVertexIDs[2,2,1],FaceConfig and 61,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,51));
                        Tool.AddInterpolationFaces(NeighbourVertexIDs[0,0,1],NeighbourVertexIDs[0,0,2],NeighbourVertexIDs[0,2,1],NeighbourVertexIDs[0,2,2],NeighbourVertexIDs[2,0,1],NeighbourVertexIDs[2,0,2],NeighbourVertexIDs[2,2,1],NeighbourVertexIDs[2,2,2],FaceConfig and 62,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,204));
                     end;
                     2: // subdivides y only
                     begin
                        Tool.InitializeNeighbourVertexIDsSize3(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add Vertexes
                        Tool.AddVertexToTarget(NeighbourVertexIDs[0,1,0],VertexList,_NumVertices,x,y+0.5,z);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[0,1,2],VertexList,_NumVertices,x,y+0.5,z+1);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[2,1,0],VertexList,_NumVertices,x+1,y+0.5,z);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[2,1,2],VertexList,_NumVertices,x+1,y+0.5,z+1);
                        // Add Faces
                        Tool.AddInterpolationFaces(NeighbourVertexIDs[0,0,0],NeighbourVertexIDs[0,0,2],NeighbourVertexIDs[0,1,0],NeighbourVertexIDs[0,1,2],NeighbourVertexIDs[2,0,0],NeighbourVertexIDs[2,0,2],NeighbourVertexIDs[2,1,0],NeighbourVertexIDs[2,1,2],FaceConfig and 55,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,85));
                        Tool.AddInterpolationFaces(NeighbourVertexIDs[0,1,0],NeighbourVertexIDs[0,1,2],NeighbourVertexIDs[0,2,0],NeighbourVertexIDs[0,2,2],NeighbourVertexIDs[2,1,0],NeighbourVertexIDs[2,1,2],NeighbourVertexIDs[2,2,0],NeighbourVertexIDs[2,2,2],FaceConfig and 59,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,170));
                     end;
                     3: // subdivides y and z
                     begin
                        Tool.InitializeNeighbourVertexIDsSize4(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add neighbour faces
                        Tool.AddBottomFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddTopFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddBackFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddFrontFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        // Add the new faces
                        Tool.AddInterpolationFacesFor4x4Regions(_Voxel,_Palette,NeighbourVertexIDs,x,y,z,FaceConfig,TriangleList,QuadList);
                     end;
                     4: // subdivides x only
                     begin
                        Tool.InitializeNeighbourVertexIDsSize3(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add Vertexes
                        Tool.AddVertexToTarget(NeighbourVertexIDs[1,0,0],VertexList,_NumVertices,x+0.5,y,z);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[1,0,2],VertexList,_NumVertices,x+0.5,y,z+1);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[1,2,0],VertexList,_NumVertices,x+0.5,y+1,z);
                        Tool.AddVertexToTarget(NeighbourVertexIDs[1,2,2],VertexList,_NumVertices,x+0.5,y+1,z+1);
                        // Add Faces
                        Tool.AddInterpolationFaces(NeighbourVertexIDs[0,0,0],NeighbourVertexIDs[0,0,2],NeighbourVertexIDs[0,2,0],NeighbourVertexIDs[0,2,2],NeighbourVertexIDs[1,0,0],NeighbourVertexIDs[1,0,2],NeighbourVertexIDs[1,2,0],NeighbourVertexIDs[1,2,2],FaceConfig and 31,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,15));
                        Tool.AddInterpolationFaces(NeighbourVertexIDs[1,0,0],NeighbourVertexIDs[1,0,2],NeighbourVertexIDs[1,2,0],NeighbourVertexIDs[1,2,2],NeighbourVertexIDs[2,0,0],NeighbourVertexIDs[2,0,2],NeighbourVertexIDs[2,2,0],NeighbourVertexIDs[2,2,2],FaceConfig and 47,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,240));
                     end;
                     5: // subdivides x and z
                     begin
                        Tool.InitializeNeighbourVertexIDsSize4(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add neighbour faces
                        Tool.AddLeftFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddRightFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddBackFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddFrontFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        // Add the new faces
                        Tool.AddInterpolationFacesFor4x4Regions(_Voxel,_Palette,NeighbourVertexIDs,x,y,z,FaceConfig,TriangleList,QuadList);
                     end;
                     6: // subdivides x and y
                     begin
                        Tool.InitializeNeighbourVertexIDsSize4(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add neighbour faces
                        Tool.AddLeftFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddRightFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddBottomFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        Tool.AddTopFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        // Add the new faces
                        Tool.AddInterpolationFacesFor4x4Regions(_Voxel,_Palette,NeighbourVertexIDs,x,y,z,FaceConfig,TriangleList,QuadList);
                     end;
                  end;

               end
               else
               begin
                  // Does not subdivide it.

                  // Detect face configuration
                  // Axis X
                  _Voxel.GetVoxelSafe(x-1,y,z,v);
                  if v.Used then
                     FaceConfig := FaceConfig or 32;
                  _Voxel.GetVoxelSafe(x+1,y,z,v);
                  if v.Used then
                     FaceConfig := FaceConfig or 16;
                  // Axis Y
                  _Voxel.GetVoxelSafe(x,y-1,z,v);
                  if v.Used then
                     FaceConfig := FaceConfig or 8;
                  _Voxel.GetVoxelSafe(x,y+1,z,v);
                  if v.Used then
                     FaceConfig := FaceConfig or 4;
                  // Axis Z
                  _Voxel.GetVoxelSafe(x,y,z-1,v);
                  if v.Used then
                     FaceConfig := FaceConfig or 2;
                  _Voxel.GetVoxelSafe(x,y,z+1,v);
                  if v.Used then
                     FaceConfig := FaceConfig or 1;

                  // Find faces
                  Tool.AddInterpolationFaces(_VertexMap.Data[x,y,z],_VertexMap.Data[x,y,z+1],_VertexMap.Data[x,y+1,z],_VertexMap.Data[x,y+1,z+1],_VertexMap.Data[x+1,y,z],_VertexMap.Data[x+1,y,z+1],_VertexMap.Data[x+1,y+1,z],_VertexMap.Data[x+1,y+1,z+1],FaceConfig,TriangleList,QuadList,Tool.GetColour(_Voxel,_Palette,x,y,z,255));
               end;
            end;
         end;
   if (VertexList.Count > 0) and ((TriangleList.Count + QuadList.Count) > 0) then
   begin
      // Build new vertexes.
      VertexList.GoToFirstElement;
      SetLength(_Vertices,_NumVertices);
      for x := OldNumVertices to High(_Vertices) do
      begin
         _Vertices[x].X := VertexList.X;
         _Vertices[x].Y := VertexList.Y;
         _Vertices[x].Z := VertexList.Z;
         VertexList.GoToNextElement;
      end;

      // Add all new faces
      _Geometry.AddQuadsFromList(QuadList,_Vertices);
      _Geometry.ConvertQuadsToTris();
      _Geometry.AddTrianglesFromList(TriangleList,_Vertices);
   end;
   // Free memory.
   VertexList.Free;
   TriangleList.Free;
   QuadList.Free;
   Tool.Free;
   for x := 0 to 3 do
   begin
      for y := 0 to 3 do
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

procedure TVoxelMeshGenerator.LoadQuadsWithTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Geometry: CMeshGeometryList; var _TexCoords: TAVector2f; var _NumVoxels: longword);
var
   VoxelMap: TVoxelMap;
   Geometry: PMeshBRepGeometry;
begin
   _Geometry.GoToFirstElement;
   Geometry := PMeshBRepGeometry(_Geometry.Current);
   // Let's map our voxels.
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceAndInterpolationMap;

   BuildModelFromVoxelMap(_Voxel,_Palette,_Vertices,Geometry^,_TexCoords,_NumVoxels,VoxelMap);

   VoxelMap.Free;
end;

end.
