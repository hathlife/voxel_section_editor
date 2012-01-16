unit VoxelMeshGenerator;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette,
   VolumeGreyIntData, ClassVertexList, ClassTriangleList, ClassQuadList,
   Normals, Windows, ClassMeshNormalsTool, DifferentMeshFaceTypePlugin,
   MeshGeometryBase, MeshBRepGeometry, ClassMeshGeometryList;

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
{
procedure TVoxelMeshGenerator.BuildInterpolationTriangles(const _Voxel : TVoxelSection; const _Palette: TPalette; const _VertexMap : T3DVolumeGreyIntData; const _VoxelMap: TVoxelMap;  var _Vertices: TAVector3f; var _Faces: auint32; var _FaceNormals: TAVector3f; var _Colours: TAVector4f; var _TriangleMesh: TDifferentMeshFaceTypePlugin; var _NumFaces,_NumVertices: longword);
   procedure InitializeNeighbourVertexIDsSize3(var _NeighbourVertexIDs: T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer);
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

   procedure InitializeNeighbourVertexIDsSize4(var _NeighbourVertexIDs:T3DIntGrid; const _VertexMap : T3DVolumeGreyIntData; _x, _y, _z: integer);
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

   procedure AddLeftFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
   begin
      if _NeighbourVertexIDs[0,1,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,1,0] := _VertexList.Add(_NumVertices,_x,_y+0.33,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,2,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,2,0] := _VertexList.Add(_NumVertices,_x,_y+0.66,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,0,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,0,1] := _VertexList.Add(_NumVertices,_x,_y,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,1,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,1,1] := _VertexList.Add(_NumVertices,_x,_y+0.33,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,2,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,2,1] := _VertexList.Add(_NumVertices,_x,_y+0.66,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,3,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,3,1] := _VertexList.Add(_NumVertices,_x,_y+1,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,0,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,0,2] := _VertexList.Add(_NumVertices,_x,_y,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,1,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,1,2] := _VertexList.Add(_NumVertices,_x,_y+0.33,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,2,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,2,2] := _VertexList.Add(_NumVertices,_x,_y+0.66,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,3,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,3,2] := _VertexList.Add(_NumVertices,_x,_y+1,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,1,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,1,3] := _VertexList.Add(_NumVertices,_x,_y+0.33,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,2,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,2,3] := _VertexList.Add(_NumVertices,_x,_y+0.66,_z+1);
         inc(_NumVertices);
      end;
   end;

   procedure AddRightFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
   begin
      if _NeighbourVertexIDs[3,1,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,1,0] := _VertexList.Add(_NumVertices,_x+1,_y+0.33,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,2,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,2,0] := _VertexList.Add(_NumVertices,_x+1,_y+0.66,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,0,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,0,1] := _VertexList.Add(_NumVertices,_x+1,_y,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,1,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,1,1] := _VertexList.Add(_NumVertices,_x+1,_y+0.33,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,2,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,2,1] := _VertexList.Add(_NumVertices,_x+1,_y+0.66,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,3,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,3,1] := _VertexList.Add(_NumVertices,_x+1,_y+1,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,0,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,0,2] := _VertexList.Add(_NumVertices,_x+1,_y,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,1,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,1,2] := _VertexList.Add(_NumVertices,_x+1,_y+0.33,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,2,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,2,2] := _VertexList.Add(_NumVertices,_x+1,_y+0.66,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,3,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,3,2] := _VertexList.Add(_NumVertices,_x+1,_y+1,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,1,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,1,3] := _VertexList.Add(_NumVertices,_x+1,_y+0.33,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,2,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,2,3] := _VertexList.Add(_NumVertices,_x+1,_y+0.66,_z+1);
         inc(_NumVertices);
      end;
   end;

   procedure AddBackFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
   begin
      if _NeighbourVertexIDs[0,1,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,1,0] := _VertexList.Add(_NumVertices,_x,_y+0.33,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,2,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,2,0] := _VertexList.Add(_NumVertices,_x,_y+0.66,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,0,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,0,0] := _VertexList.Add(_NumVertices,_x+0.33,_y,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,1,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,1,0] := _VertexList.Add(_NumVertices,_x+0.33,_y+0.33,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,2,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,2,0] := _VertexList.Add(_NumVertices,_x+0.33,_y+0.66,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,3,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,3,0] := _VertexList.Add(_NumVertices,_x+0.33,_y+1,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,0,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,0,0] := _VertexList.Add(_NumVertices,_x+0.66,_y,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,1,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,1,0] := _VertexList.Add(_NumVertices,_x+0.66,_y+0.33,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,2,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,2,0] := _VertexList.Add(_NumVertices,_x+0.66,_y+0.66,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,3,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,3,0] := _VertexList.Add(_NumVertices,_x+0.66,_y+1,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,1,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,1,0] := _VertexList.Add(_NumVertices,_x+1,_y+0.33,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,2,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,2,0] := _VertexList.Add(_NumVertices,_x+1,_y+0.66,_z);
         inc(_NumVertices);
      end;
   end;

   procedure AddFrontFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
   begin
      if _NeighbourVertexIDs[0,1,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,1,3] := _VertexList.Add(_NumVertices,_x,_y+0.33,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,2,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,2,3] := _VertexList.Add(_NumVertices,_x,_y+0.66,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,0,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,0,3] := _VertexList.Add(_NumVertices,_x+0.33,_y,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,1,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,1,3] := _VertexList.Add(_NumVertices,_x+0.33,_y+0.33,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,2,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,2,3] := _VertexList.Add(_NumVertices,_x+0.33,_y+0.66,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,3,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,3,3] := _VertexList.Add(_NumVertices,_x+0.33,_y+1,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,0,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,0,3] := _VertexList.Add(_NumVertices,_x+0.66,_y,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,1,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,1,3] := _VertexList.Add(_NumVertices,_x+0.66,_y+0.33,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,2,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,2,3] := _VertexList.Add(_NumVertices,_x+0.66,_y+0.66,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,3,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,3,3] := _VertexList.Add(_NumVertices,_x+0.66,_y+1,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,1,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,1,3] := _VertexList.Add(_NumVertices,_x+1,_y+0.33,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,2,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,2,3] := _VertexList.Add(_NumVertices,_x+1,_y+0.66,_z+1);
         inc(_NumVertices);
      end;
   end;

   procedure AddBottomFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
   begin
      if _NeighbourVertexIDs[1,0,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,0,0] := _VertexList.Add(_NumVertices,_x+0.33,_y,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,0,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,0,0] := _VertexList.Add(_NumVertices,_x+0.66,_y,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,0,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,0,1] := _VertexList.Add(_NumVertices,_x,_y,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,0,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,0,1] := _VertexList.Add(_NumVertices,_x+0.33,_y,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,0,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,0,1] := _VertexList.Add(_NumVertices,_x+0.66,_y,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,0,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,0,1] := _VertexList.Add(_NumVertices,_x+1,_y,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,0,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,0,2] := _VertexList.Add(_NumVertices,_x,_y,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,0,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,0,2] := _VertexList.Add(_NumVertices,_x+0.33,_y,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,0,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,0,2] := _VertexList.Add(_NumVertices,_x+0.66,_y,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,0,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,0,2] := _VertexList.Add(_NumVertices,_x+1,_y,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,0,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,0,3] := _VertexList.Add(_NumVertices,_x+0.33,_y,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,0,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,0,3] := _VertexList.Add(_NumVertices,_x+0.66,_y,_z+1);
         inc(_NumVertices);
      end;
   end;

   procedure AddTopFace(var _NeighbourVertexIDs: T3DIntGrid; var _VertexList: CVertexList; _x, _y, _z: integer; var _NumVertices: longword);
   begin
      if _NeighbourVertexIDs[1,3,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,3,0] := _VertexList.Add(_NumVertices,_x+0.33,_y+1,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,3,0] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,3,0] := _VertexList.Add(_NumVertices,_x+0.66,_y+1,_z);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,3,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,3,1] := _VertexList.Add(_NumVertices,_x,_y+1,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,3,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,3,1] := _VertexList.Add(_NumVertices,_x+0.33,_y+1,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,3,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,3,1] := _VertexList.Add(_NumVertices,_x+0.66,_y+1,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,3,1] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,3,1] := _VertexList.Add(_NumVertices,_x+1,_y+1,_z+0.33);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[0,3,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[0,3,2] := _VertexList.Add(_NumVertices,_x,_y+1,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,3,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,3,2] := _VertexList.Add(_NumVertices,_x+0.33,_y+1,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,3,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,3,2] := _VertexList.Add(_NumVertices,_x+0.66,_y+1,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[3,3,2] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[3,3,2] := _VertexList.Add(_NumVertices,_x+1,_y+1,_z+0.66);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[1,3,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[1,3,3] := _VertexList.Add(_NumVertices,_x+0.33,_y+1,_z+1);
         inc(_NumVertices);
      end;
      if _NeighbourVertexIDs[2,3,3] = C_VMG_NO_VERTEX then
      begin
         _NeighbourVertexIDs[2,3,3] := _VertexList.Add(_NumVertices,_x+0.66,_y+1,_z+1);
         inc(_NumVertices);
      end;
   end;

   procedure AddInterpolationFaces(_LeftBottomFront,_LeftBottomBack,_LeftTopFront,_LeftTopBack,_RightBottomFront,_RightBottomBack,_RightTopFront,_RightTopBack,_FaceFilledConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList; _Color: cardinal);
   const
      QuadSet: array[1..36,0..3] of shortint = ((0,1,5,4),(0,1,5,6),(0,1,7,4),(0,1,7,6),(0,2,3,1),(0,2,7,5),(0,3,5,4),(0,3,7,4),(0,3,7,5),(0,4,6,2),(0,4,6,3),(0,4,7,2),(0,4,7,3),(0,5,6,2),(0,5,7,2),(0,5,7,3),(0,6,7,1),(0,6,7,3),(1,2,6,5),(1,2,6,7),(1,2,7,5),(1,3,6,4),(1,3,6,5),(1,3,7,5),(1,4,2,3),(1,4,6,2),(1,4,6,3),(1,5,4,2),(1,5,6,2),(1,6,4,7),(2,4,3,7),(2,4,5,3),(2,4,7,3),(2,6,5,3),(2,6,7,3),(4,5,7,6));
      QuadFaces: array[1..36] of shortint = (2,-1,-1,-1,0,-1,-1,-1,-1,4,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,5,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,3,1);
      QuadConfigStart: array[0..255] of shortint = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,9,9,9,9,9,9,10,10,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,16,16,16,16,17,17,17,17,20,20,20,20,23,23,26,26,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,34,34,34,34,34,34,34,34,34,34,34,34,35,35,35,36,39,39,39,39,40,40,40,40,43,43,43,44,47,47,47,50,54,54,54,54,54,54,54,54,54,54,54,54,54,54,55,56,59,59,59,59,59,59,60,60,63,63,63,63,63,64,67,70,74,74,74,74,74,74,74,74,74,74,74,75,78,78,81,84,88,88,89,90,93,94,97,100,104,105,108,111,115,118,122,126);
      QuadConfigData: array[0..125] of shortint = (36,36,35,35,32,36,35,36,24,24,27,36,24,20,36,28,35,29,35,24,35,25,30,24,31,28,24,36,35,26,36,11,36,16,10,10,10,36,6,5,35,14,9,10,35,10,8,34,10,7,10,36,35,7,1,1,36,1,17,24,2,24,18,1,1,24,13,11,23,1,24,1,36,18,10,34,10,7,12,1,21,10,1,19,10,1,36,20,5,5,35,5,4,5,24,5,15,34,5,2,35,24,5,2,5,33,5,3,10,5,22,35,5,10,3,1,5,32,10,5,1,34,1,5,24,35);
      TriangleSet: array[1..68,0..2] of shortint = ((0,1,4),(0,1,5),(0,1,6),(0,2,1),(0,2,3),(0,2,5),(0,2,7),(0,3,1),(0,3,2),(0,3,4),(0,4,2),(0,4,3),(0,4,6),(0,4,7),(0,5,2),(0,5,4),(0,5,7),(0,6,1),(0,6,2),(0,6,7),(0,7,1),(0,7,2),(0,7,3),(0,7,5),(1,2,3),(1,2,6),(1,3,2),(1,3,4),(1,3,5),(1,3,6),(1,3,7),(1,4,3),(1,4,5),(1,4,6),(1,5,4),(1,5,6),(1,5,7),(1,6,2),(1,6,3),(1,6,4),(1,6,5),(1,6,7),(1,7,5),(1,7,6),(2,3,4),(2,3,5),(2,4,3),(2,4,6),(2,5,3),(2,5,4),(2,5,7),(2,6,3),(2,6,5),(2,6,7),(2,7,3),(3,4,5),(3,4,6),(3,4,7),(3,5,4),(3,6,4),(3,6,7),(3,7,5),(3,7,6),(4,5,6),(4,5,7),(4,7,5),(4,7,6),(5,7,6));
      TriConfigStart: array[0..255] of shortint = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,8,8,8,8,8,8,8,8,12,12,12,12,16,16,16,16,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,22,22,22,22,22,22,22,22,26,26,26,26,26,26,30,30,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,34,34,34,34,38,38,38,38,40,40,40,40,42,42,44,44,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,46,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,52,52,52,52,52,52,52,52,52,52,52,52,56,56,56,60,62,62,62,62,66,66,66,66,68,68,68,72,74,74,74,76,78,78,78,78,78,78,78,78,78,78,78,78,78,78,82,86,88,88,88,88,88,88,92,92,94,94,94,94,94,98,100,102,104,104,104,104,104,104,104,104,104,104,104,108,110,110,112,114,116,116,120,124,126,130,132,134,136,140,142,144,146,148,150,152);
      TriConfigData: array[0..151] of shortint = (57,62,61,59,51,48,54,49,46,68,62,53,58,48,67,45,48,62,42,35,34,43,36,63,39,68,58,35,65,32,61,35,48,37,44,25,31,38,68,25,48,31,67,27,33,25,20,24,16,13,16,61,7,14,67,54,6,16,64,53,54,16,19,18,30,52,68,5,52,9,10,60,67,8,64,4,62,5,43,66,14,21,13,18,41,64,13,43,8,2,17,23,68,8,8,29,56,12,65,8,64,8,8,13,4,1,40,26,64,5,4,65,64,4,43,4,31,21,22,55,39,3,19,52,19,31,29,2,15,49,55,2,19,29,68,19,11,1,28,47,11,31,52,1,67,31,11,29,64,29,65,11);
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
   function GetColour(const _Voxel : TVoxelSection; const _Palette: TPalette; _x,_y,_z,_config: integer): Cardinal;
   var
      Cube : TNormals;
      i,maxi : integer;
      CubeVertexBit: array [0..25] of byte = (15,10,5,12,3,4,8,1,2,51,34,170,136,204,68,85,17,240,160,80,192,48,64,128,16,32);
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

   procedure AddInterpolationFacesFor4x4Regions(const _Voxel : TVoxelSection; const _Palette: TPalette; const _NeighbourVertexIDs: T3DIntGrid; _x,_y,_z: integer; const _FaceConfig: integer; var _TriangleList: CTriangleList; var _QuadList: CQuadList);
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


var
   x,y,z,OldNumVertices,maxx: integer;
   V : TVoxelUnpacked;
   SubdivisionSituation,FaceConfig : integer;
   NeighbourVertexIDs: T3DIntGrid;
   VertexList: CVertexList;
   TriangleList: CTriangleList;
   QuadList: CQuadList;
   NormalsTool: TMeshNormalsTool;
begin
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
                        InitializeNeighbourVertexIDsSize3(NeighbourVertexIDs,_VertexMap,x,y,z);
                        if NeighbourVertexIDs[0,0,1] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[0,0,1] := VertexList.Add(_NumVertices,x,y,z+0.5);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[0,2,1] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[0,2,1] := VertexList.Add(_NumVertices,x,y+1,z+0.5);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[2,0,1] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[2,0,1] := VertexList.Add(_NumVertices,x+1,y,z+0.5);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[2,2,1] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[2,2,1] := VertexList.Add(_NumVertices,x+1,y+1,z+0.5);
                           inc(_NumVertices);
                        end;
                        AddInterpolationFaces(NeighbourVertexIDs[0,0,0],NeighbourVertexIDs[0,0,1],NeighbourVertexIDs[0,2,0],NeighbourVertexIDs[0,2,1],NeighbourVertexIDs[2,0,0],NeighbourVertexIDs[2,0,1],NeighbourVertexIDs[2,2,0],NeighbourVertexIDs[2,2,1],FaceConfig and 61,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,51));
                        AddInterpolationFaces(NeighbourVertexIDs[0,0,1],NeighbourVertexIDs[0,0,2],NeighbourVertexIDs[0,2,1],NeighbourVertexIDs[0,2,2],NeighbourVertexIDs[2,0,1],NeighbourVertexIDs[2,0,2],NeighbourVertexIDs[2,2,1],NeighbourVertexIDs[2,2,2],FaceConfig and 62,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,204));
                     end;
                     2: // subdivides y only
                     begin
                        InitializeNeighbourVertexIDsSize3(NeighbourVertexIDs,_VertexMap,x,y,z);
                        if NeighbourVertexIDs[0,1,0] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[0,1,0] := VertexList.Add(_NumVertices,x,y+0.5,z);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[0,1,2] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[0,1,2] := VertexList.Add(_NumVertices,x,y+0.5,z+1);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[2,1,0] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[2,1,0] := VertexList.Add(_NumVertices,x+1,y+0.5,z);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[2,1,2] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[2,1,2] := VertexList.Add(_NumVertices,x+1,y+0.5,z+1);
                           inc(_NumVertices);
                        end;
                        AddInterpolationFaces(NeighbourVertexIDs[0,0,0],NeighbourVertexIDs[0,0,2],NeighbourVertexIDs[0,1,0],NeighbourVertexIDs[0,1,2],NeighbourVertexIDs[2,0,0],NeighbourVertexIDs[2,0,2],NeighbourVertexIDs[2,1,0],NeighbourVertexIDs[2,1,2],FaceConfig and 55,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,85));
                        AddInterpolationFaces(NeighbourVertexIDs[0,1,0],NeighbourVertexIDs[0,1,2],NeighbourVertexIDs[0,2,0],NeighbourVertexIDs[0,2,2],NeighbourVertexIDs[2,1,0],NeighbourVertexIDs[2,1,2],NeighbourVertexIDs[2,2,0],NeighbourVertexIDs[2,2,2],FaceConfig and 59,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,170));
                     end;
                     3: // subdivides y and z
                     begin
                        InitializeNeighbourVertexIDsSize4(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add neighbour faces
                        AddBottomFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddTopFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddBackFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddFrontFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        // Add the new faces
                        AddInterpolationFacesFor4x4Regions(_Voxel,_Palette,NeighbourVertexIDs,x,y,z,FaceConfig,TriangleList,QuadList);
                     end;
                     4: // subdivides x only
                     begin
                        InitializeNeighbourVertexIDsSize3(NeighbourVertexIDs,_VertexMap,x,y,z);
                        if NeighbourVertexIDs[1,0,0] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[1,0,0] := VertexList.Add(_NumVertices,x+0.5,y,z);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[1,0,2] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[1,0,2] := VertexList.Add(_NumVertices,x+0.5,y,z+1);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[1,2,0] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[1,2,0] := VertexList.Add(_NumVertices,x+0.5,y+1,z);
                           inc(_NumVertices);
                        end;
                        if NeighbourVertexIDs[1,2,2] = C_VMG_NO_VERTEX then
                        begin
                           NeighbourVertexIDs[1,2,2] := VertexList.Add(_NumVertices,x+0.5,y+1,z+1);
                           inc(_NumVertices);
                        end;
                        AddInterpolationFaces(NeighbourVertexIDs[0,0,0],NeighbourVertexIDs[0,0,2],NeighbourVertexIDs[0,2,0],NeighbourVertexIDs[0,2,2],NeighbourVertexIDs[1,0,0],NeighbourVertexIDs[1,0,2],NeighbourVertexIDs[1,2,0],NeighbourVertexIDs[1,2,2],FaceConfig and 31,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,15));
                        AddInterpolationFaces(NeighbourVertexIDs[1,0,0],NeighbourVertexIDs[1,0,2],NeighbourVertexIDs[1,2,0],NeighbourVertexIDs[1,2,2],NeighbourVertexIDs[2,0,0],NeighbourVertexIDs[2,0,2],NeighbourVertexIDs[2,2,0],NeighbourVertexIDs[2,2,2],FaceConfig and 47,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,240));
                     end;
                     5: // subdivides x and z
                     begin
                        InitializeNeighbourVertexIDsSize4(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add neighbour faces
                        AddLeftFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddRightFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddBackFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddFrontFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        // Add the new faces
                        AddInterpolationFacesFor4x4Regions(_Voxel,_Palette,NeighbourVertexIDs,x,y,z,FaceConfig,TriangleList,QuadList);
                     end;
                     6: // subdivides x and y
                     begin
                        InitializeNeighbourVertexIDsSize4(NeighbourVertexIDs,_VertexMap,x,y,z);
                        // Add neighbour faces
                        AddLeftFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddRightFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddBottomFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        AddTopFace(NeighbourVertexIDs,VertexList,x,y,z,_NumVertices);
                        // Add the new faces
                        AddInterpolationFacesFor4x4Regions(_Voxel,_Palette,NeighbourVertexIDs,x,y,z,FaceConfig,TriangleList,QuadList);                        
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
                  AddInterpolationFaces(_VertexMap.Data[x,y,z],_VertexMap.Data[x,y,z+1],_VertexMap.Data[x,y+1,z],_VertexMap.Data[x,y+1,z+1],_VertexMap.Data[x+1,y,z],_VertexMap.Data[x+1,y,z+1],_VertexMap.Data[x+1,y+1,z],_VertexMap.Data[x+1,y+1,z+1],FaceConfig,TriangleList,QuadList,GetColour(_Voxel,_Palette,x,y,z,255));
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

      NormalsTool := TMeshNormalsTool.Create;
      // Build new quads (faces, normals, colours).
      if QuadList.Count > 0 then
      begin
         maxx := _NumFaces+QuadList.Count;
         SetLength(_Faces,maxx*4);
         SetLength(_Colours,maxx);
         SetLength(_FaceNormals,maxx);
         QuadList.GoToFirstElement;
         x := _NumFaces * 4;
         y := _NumFaces;
         while x < High(_Faces) do
         begin
            _Faces[x] := QuadList.V1;
            _Faces[x+1] := QuadList.V2;
            _Faces[x+2] := QuadList.V3;
            _Faces[x+3] := QuadList.V4;
            _Colours[y].X := GetRValue(QuadList.Colour) / 255;
            _Colours[y].Y := GetGValue(QuadList.Colour) / 255;
            _Colours[y].Z := GetBValue(QuadList.Colour) / 255;
            _Colours[y].W := 0;
            _FaceNormals[y] := NormalsTool.GetQuadNormalValue(_Vertices[QuadList.V1],_Vertices[QuadList.V2],_Vertices[QuadList.V3],_Vertices[QuadList.V4]);
            QuadList.GoToNextElement;
            inc(y);
            inc(x,4);
         end;
         _NumFaces := maxx;
      end;

      // Build new triangles (faces, normals, colours).
      if TriangleList.Count > 0 then
      begin
         _TriangleMesh := TDifferentMeshFaceTypePlugin.Create;
         maxx := TriangleList.Count;
         SetLength(_Faces,maxx*4);
         SetLength(_Colours,maxx);
         SetLength(_FaceNormals,maxx);
         QuadList.GoToFirstElement;
         x := _NumFaces * 4;
         y := _NumFaces;
         while x < High(_Faces) do
         begin
            _Faces[x] := QuadList.V1;
            _Faces[x+1] := QuadList.V2;
            _Faces[x+2] := QuadList.V3;
            _Faces[x+3] := QuadList.V4;
            _Colours[y].X := GetRValue(QuadList.Colour) / 255;
            _Colours[y].Y := GetGValue(QuadList.Colour) / 255;
            _Colours[y].Z := GetBValue(QuadList.Colour) / 255;
            _Colours[y].W := 0;
            _FaceNormals[y] := NormalsTool.GetQuadNormalValue(_Vertices[QuadList.V1],_Vertices[QuadList.V2],_Vertices[QuadList.V3],_Vertices[QuadList.V4]);
            QuadList.GoToNextElement;
            inc(y);
            inc(x,4);
         end;
         _NumFaces := maxx;
      end;
      NormalsTool.Free;

   end;
   // Free memory.
   VertexList.Free;
   TriangleList.Free;
   QuadList.Free;
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
}

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
