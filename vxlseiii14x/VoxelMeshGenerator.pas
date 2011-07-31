unit VoxelMeshGenerator;

interface

uses BasicDataTypes, BasicConstants, GLConstants, VoxelMap, Voxel, Palette;

type
   TVoxelMeshGenerator = class
      private
         procedure BuildTriangleModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxelMapWithExternalData(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer; var _VoxelMap: TVoxelMap);
         procedure BuildModelFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);

         procedure SetupVertexMap(var _VertexMap: T3DIntGrid; _XSize,_YSize,_ZSize: integer);
         procedure BuildVertexMap(var _VertexMap: T3DIntGrid; const _Voxel : TVoxelSection; var _NumVertices, _NumVoxels: longword);
         procedure FillVerticesArray(var _Vertices: TAVector3f; const _VertexMap: T3DIntGrid; const _NumVertices: longword);
         procedure SetupFaceMap(var _FaceMap: T4DIntGrid; const _XSize, _YSize, _ZSize: integer);
         procedure BuildFaceMap(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure BuildFaceMap(var _FaceMap: T4DIntGrid; const _Voxel : TVoxelSection; const _Vertices: TAVector3f; var _NumFaces: longword); overload;
         procedure BuildFaceMapExternal(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword);
         procedure FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DIntGrid; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces: longword; const _VerticesPerFace: integer); overload;
         procedure FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DIntGrid; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumFaces: longword; const _VerticesPerFace: integer); overload;
         procedure FillTriangleFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DIntGrid; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces,_NumVertices: longword; const _VerticesPerFace: integer); overload;
         procedure EliminateUselessVertices(var _VertexTransformation: aint32; var _Vertices: TAVector3f; var _Faces: auint32; var _NumVertices: longword);

         function IsPointValid(_x,_y,_z,_maxx,_maxy,_maxz: integer): boolean;
      public
         procedure LoadFromVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
         procedure LoadFromExternalVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
         procedure LoadTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
    end;

implementation

procedure TVoxelMeshGenerator.SetupVertexMap(var _VertexMap: T3DIntGrid; _XSize,_YSize,_ZSize: integer);
var
   x,y,z: integer;
begin
   // Let's map the vertices.
   SetLength(_VertexMap,_XSize,_YSize,_ZSize);
   // clear map
   for x := Low(_VertexMap) to High(_VertexMap) do
      for y := Low(_VertexMap[x]) to High(_VertexMap[x]) do
         for z := Low(_VertexMap[x,y]) to High(_VertexMap[x,y]) do
            _VertexMap[x,y,z] := -1;
end;

procedure TVoxelMeshGenerator.BuildVertexMap(var _VertexMap: T3DIntGrid; const _Voxel : TVoxelSection; var _NumVertices, _NumVoxels: longword);
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
               if _VertexMap[x,y,z] = -1 then
               begin
                  _VertexMap[x,y,z] := _NumVertices;
                  inc(_NumVertices);
               end;
               if IsPointValid(x+1,y,z,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x+1,y,z] = -1 then
                  begin
                     _VertexMap[x+1,y,z] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
               if IsPointValid(x,y+1,z,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x,y+1,z] = -1 then
                  begin
                     _VertexMap[x,y+1,z] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
               if IsPointValid(x+1,y+1,z,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x+1,y+1,z] = -1 then
                  begin
                     _VertexMap[x+1,y+1,z] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
               if IsPointValid(x,y,z+1,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x,y,z+1] = -1 then
                  begin
                     _VertexMap[x,y,z+1] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
               if IsPointValid(x+1,y,z+1,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x+1,y,z+1] = -1 then
                  begin
                     _VertexMap[x+1,y,z+1] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
               if IsPointValid(x,y+1,z+1,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x,y+1,z+1] = -1 then
                  begin
                     _VertexMap[x,y+1,z+1] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
               if IsPointValid(x+1,y+1,z+1,High(_VertexMap),High(_VertexMap[x]),High(_VertexMap[x,y])) then
               begin
                  if _VertexMap[x+1,y+1,z+1] = -1 then
                  begin
                     _VertexMap[x+1,y+1,z+1] := _NumVertices;
                     inc(_NumVertices);
                  end;
               end;
            end;
         end;

end;

procedure TVoxelMeshGenerator.FillVerticesArray(var _Vertices: TAVector3f; const _VertexMap: T3DIntGrid; const _NumVertices: longword);
var
   x,y,z: integer;
begin
   SetLength(_Vertices,_NumVertices);
   for x := Low(_VertexMap) to High(_VertexMap) do
      for y := Low(_VertexMap[x]) to High(_VertexMap[x]) do
         for z := Low(_VertexMap[x,y]) to High(_VertexMap[x,y]) do
         begin
            if _VertexMap[x,y,z] <> -1 then
            begin
               _Vertices[_VertexMap[x,y,z]].X := x;
               _Vertices[_VertexMap[x,y,z]].Y := y;
               _Vertices[_VertexMap[x,y,z]].Z := z;
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
            _FaceMap[x,y,z,0] := -1;
            _FaceMap[x,y,z,1] := -1;
            _FaceMap[x,y,z,2] := -1;
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

procedure TVoxelMeshGenerator.BuildFaceMapExternal(var _FaceMap: T4DIntGrid; const _VoxelMap: TVoxelMap; const _Vertices: TAVector3f; var _NumFaces: longword);
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
      if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_SURFACE then
         v1 := true;
      v2 := false;
      if _VoxelMap.MapSafe[x,y+1,z+1] > C_SURFACE then
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
      if _VoxelMap.MapSafe[x+1,y,z+1] > C_SURFACE then
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
      if _VoxelMap.MapSafe[x+1,y+1,z] > C_SURFACE then
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

procedure TVoxelMeshGenerator.FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DIntGrid; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumFaces: longword; const _VerticesPerFace: integer);
var
   x,y,z,i,f: integer;
   V : TVoxelUnpacked;
begin
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      x := Round(_Vertices[i].X);
      y := Round(_Vertices[i].Y);
      z := Round(_Vertices[i].Z);
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x-1,y,z,v);
               _Faces[f+3] := _VertexMap[x,y+1,z+1];
               _Faces[f+2] := _VertexMap[x,y+1,z];
               _Faces[f+1] := _VertexMap[x,y,z];
               _Faces[f] := _VertexMap[x,y,z+1];
            end
            else
            begin
               _Faces[f] := _VertexMap[x,y+1,z+1];
               _Faces[f+1] := _VertexMap[x,y+1,z];
               _Faces[f+2] := _VertexMap[x,y,z];
               _Faces[f+3] := _VertexMap[x,y,z+1];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f+3] := _VertexMap[x,y+1,z+1];
            _Faces[f+2] := _VertexMap[x,y+1,z];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f] := _VertexMap[x,y,z+1];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL4[v.Colour];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x,y-1,z,v);
               _Faces[f] := _VertexMap[x+1,y,z+1];
               _Faces[f+1] := _VertexMap[x+1,y,z];
               _Faces[f+2] := _VertexMap[x,y,z];
               _Faces[f+3] := _VertexMap[x,y,z+1];
            end
            else
            begin
               _Faces[f+3] := _VertexMap[x+1,y,z+1];
               _Faces[f+2] := _VertexMap[x+1,y,z];
               _Faces[f+1] := _VertexMap[x,y,z];
               _Faces[f] := _VertexMap[x,y,z+1];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap[x+1,y,z+1];
            _Faces[f+1] := _VertexMap[x+1,y,z];
            _Faces[f+2] := _VertexMap[x,y,z];
            _Faces[f+3] := _VertexMap[x,y,z+1];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL4[v.Colour];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * _VerticesPerFace;
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x,y,z-1,v);
               _Faces[f] := _VertexMap[x+1,y+1,z];
               _Faces[f+1] := _VertexMap[x,y+1,z];
               _Faces[f+2] := _VertexMap[x,y,z];
               _Faces[f+3] := _VertexMap[x+1,y,z];
            end
            else
            begin
               _Faces[f+3] := _VertexMap[x+1,y+1,z];
               _Faces[f+2] := _VertexMap[x,y+1,z];
               _Faces[f+1] := _VertexMap[x,y,z];
               _Faces[f] := _VertexMap[x+1,y,z];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap[x+1,y+1,z];
            _Faces[f+1] := _VertexMap[x,y+1,z];
            _Faces[f+2] := _VertexMap[x,y,z];
            _Faces[f+3] := _VertexMap[x+1,y,z];
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

procedure TVoxelMeshGenerator.FillQuadFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DIntGrid; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces: longword; const _VerticesPerFace: integer);
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
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap[x,y+1,z+1];
            _Faces[f+1] := _VertexMap[x,y+1,z];
            _Faces[f+2] := _VertexMap[x,y,z];
            _Faces[f+3] := _VertexMap[x,y,z+1];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f+3] := _VertexMap[x,y+1,z+1];
            _Faces[f+2] := _VertexMap[x,y+1,z];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f] := _VertexMap[x,y,z+1];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap[x,y+1,z+1]] := _VertexMap[x,y+1,z+1];
         _VertexTransformation[_VertexMap[x,y+1,z]] := _VertexMap[x,y+1,z];
         _VertexTransformation[_VertexMap[x,y,z]] := _VertexMap[x,y,z];
         _VertexTransformation[_VertexMap[x,y,z+1]] := _VertexMap[x,y,z+1];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f+3] := _VertexMap[x+1,y,z+1];
            _Faces[f+2] := _VertexMap[x+1,y,z];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f] := _VertexMap[x,y,z+1];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap[x+1,y,z+1];
            _Faces[f+1] := _VertexMap[x+1,y,z];
            _Faces[f+2] := _VertexMap[x,y,z];
            _Faces[f+3] := _VertexMap[x,y,z+1];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap[x+1,y,z+1]] := _VertexMap[x+1,y,z+1];
         _VertexTransformation[_VertexMap[x+1,y,z]] := _VertexMap[x+1,y,z];
         _VertexTransformation[_VertexMap[x,y,z]] := _VertexMap[x,y,z];
         _VertexTransformation[_VertexMap[x,y,z+1]] := _VertexMap[x,y,z+1];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         f := _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * _VerticesPerFace;
         if _VoxelMap.MapSafe[x+1,y+1,z+1] > C_OUTSIDE_VOLUME then
         begin
            _Voxel.GetVoxelSafe(x,y,z,v);
            if not v.Used then
               _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f+3] := _VertexMap[x+1,y+1,z];
            _Faces[f+2] := _VertexMap[x,y+1,z];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f] := _VertexMap[x+1,y,z];
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap[x+1,y+1,z];
            _Faces[f+1] := _VertexMap[x,y+1,z];
            _Faces[f+2] := _VertexMap[x,y,z];
            _Faces[f+3] := _VertexMap[x+1,y,z];
         end;
         // Normals
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].X := _Voxel.Normals[v.Normal].X;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Y := _Voxel.Normals[v.Normal].Y;
         _FaceNormals[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         _Colours[_FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]] := _Palette.ColourGL4[v.Colour];
         // Ensure that these vertexes are used in the model.
         _VertexTransformation[_VertexMap[x+1,y+1,z]] := _VertexMap[x+1,y+1,z];
         _VertexTransformation[_VertexMap[x,y+1,z]] := _VertexMap[x,y+1,z];
         _VertexTransformation[_VertexMap[x,y,z]] := _VertexMap[x,y,z];
         _VertexTransformation[_VertexMap[x+1,y,z]] := _VertexMap[x+1,y,z];
      end;
   end;
end;

procedure TVoxelMeshGenerator.FillTriangleFaces(const _Voxel : TVoxelSection; const _Palette : TPalette; var _VertexMap : T3DIntGrid; var _FaceMap: T4DIntGrid; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _VoxelMap: TVoxelMap; var _VertexTransformation: aint32; var _NumFaces,_NumVertices: longword; const _VerticesPerFace: integer);
var
   x,y,z,i,f,fl,cv: integer;
   V : TVoxelUnpacked;
   maxVertex : integer;
begin
   for i := Low(_VertexTransformation) to _NumVertices - 1 do
   begin
      _VertexTransformation[i] := -1;
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
      if _FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> -1 then
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
            _Faces[f] := _VertexMap[x,y+1,z+1];
            _Faces[f+1] := _VertexMap[x,y+1,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap[x,y+1,z];
            _Faces[f+4] := _VertexMap[x,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap[x,y,z];
            _Faces[f+7] := _VertexMap[x,y,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap[x,y,z+1];
            _Faces[f+10] := _VertexMap[x,y+1,z+1];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            _Faces[f] := _VertexMap[x,y,z+1];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap[x,y,z];
            _Faces[f+4] := _VertexMap[x,y+1,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap[x,y+1,z];
            _Faces[f+7] := _VertexMap[x,y+1,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap[x,y+1,z+1];
            _Faces[f+10] := _VertexMap[x,y,z+1];
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
         _VertexTransformation[_VertexMap[x,y+1,z+1]] := _VertexMap[x,y+1,z+1];
         _VertexTransformation[_VertexMap[x,y+1,z]] := _VertexMap[x,y+1,z];
         _VertexTransformation[_VertexMap[x,y,z]] := _VertexMap[x,y,z];
         _VertexTransformation[_VertexMap[x,y,z+1]] := _VertexMap[x,y,z+1];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> -1 then
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
            _Faces[f] := _VertexMap[x,y,z+1];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap[x,y,z];
            _Faces[f+4] := _VertexMap[x+1,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap[x+1,y,z];
            _Faces[f+7] := _VertexMap[x+1,y,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap[x+1,y,z+1];
            _Faces[f+10] := _VertexMap[x,y,z+1];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            _Faces[f] := _VertexMap[x+1,y,z+1];
            _Faces[f+1] := _VertexMap[x+1,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap[x+1,y,z];
            _Faces[f+4] := _VertexMap[x,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap[x,y,z];
            _Faces[f+7] := _VertexMap[x,y,z+1];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap[x,y,z+1];
            _Faces[f+10] := _VertexMap[x+1,y,z+1];
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
         _VertexTransformation[_VertexMap[x+1,y,z+1]] := _VertexMap[x+1,y,z+1];
         _VertexTransformation[_VertexMap[x+1,y,z]] := _VertexMap[x+1,y,z];
         _VertexTransformation[_VertexMap[x,y,z]] := _VertexMap[x,y,z];
         _VertexTransformation[_VertexMap[x,y,z+1]] := _VertexMap[x,y,z+1];
      end;
      if _FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> -1 then
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
            _Faces[f] := _VertexMap[x+1,y,z];
            _Faces[f+1] := _VertexMap[x,y,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap[x,y,z];
            _Faces[f+4] := _VertexMap[x,y+1,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap[x,y+1,z];
            _Faces[f+7] := _VertexMap[x+1,y+1,z];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap[x+1,y+1,z];
            _Faces[f+10] := _VertexMap[x+1,y,z];
            _Faces[f+11] := cv;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            _Faces[f] := _VertexMap[x+1,y+1,z];
            _Faces[f+1] := _VertexMap[x,y+1,z];
            _Faces[f+2] := cv;
            _Faces[f+3] := _VertexMap[x,y+1,z];
            _Faces[f+4] := _VertexMap[x,y,z];
            _Faces[f+5] := cv;
            _Faces[f+6] := _VertexMap[x,y,z];
            _Faces[f+7] := _VertexMap[x+1,y,z];
            _Faces[f+8] := cv;
            _Faces[f+9] := _VertexMap[x+1,y,z];
            _Faces[f+10] := _VertexMap[x+1,y+1,z];
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
         _VertexTransformation[_VertexMap[x+1,y+1,z]] := _VertexMap[x+1,y+1,z];
         _VertexTransformation[_VertexMap[x,y+1,z]] := _VertexMap[x,y+1,z];
         _VertexTransformation[_VertexMap[x,y,z]] := _VertexMap[x,y,z];
         _VertexTransformation[_VertexMap[x+1,y,z]] := _VertexMap[x+1,y,z];
      end;
   end;
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
      if _VertexTransformation[i] <> -1 then
      begin
         _Vertices[_VertexTransformation[i]].X := _Vertices[i].X;
         _Vertices[_VertexTransformation[i]].Y := _Vertices[i].Y;
         _Vertices[_VertexTransformation[i]].Z := _Vertices[i].Z;
      end;
   end;
   SetLength(_Vertices,_NumVertices);
end;

procedure TVoxelMeshGenerator.BuildModelFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
var
   NumVertices : longword;
   VertexMap : T3DIntGrid;
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
      _NumFaces := 0;
      SetLength(_Faces,0);
      SetLength(_Normals,0);
      SetLength(_FaceNormals,0);
      SetLength(_TexCoords,0);
      SetLength(_Colours,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMap(FaceMap,_Voxel,_Vertices,_NumFaces);
   // face map is done.
   SetLength(_Faces,_NumFaces * _VerticesPerFace);
   SetLength(_Normals,0);
   SetLength(_FaceNormals,_NumFaces);
   SetLength(_TexCoords,0);
   SetLength(_Colours,_NumFaces);
   // let's fill the faces array, normals, colours, etc.
   FillQuadFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_NumVoxels,_VerticesPerFace);
   // Free memory
   for x := Low(VertexMap) to High(VertexMap) do
   begin
      for y := Low(VertexMap[x]) to High(VertexMap[x]) do
      begin
         SetLength(VertexMap[x,y],0);
      end;
      SetLength(VertexMap[x],0);
   end;
   SetLength(VertexMap,0);
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

procedure TVoxelMeshGenerator.BuildModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer; var _VoxelMap: TVoxelMap);
var
   NumVertices : longword;
   VertexMap : T3DIntGrid;
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
      _NumFaces := 0;
      SetLength(_Faces,0);
      SetLength(_Normals,0);
      SetLength(_FaceNormals,0);
      SetLength(_TexCoords,0);
      SetLength(_Colours,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMap(FaceMap,_VoxelMap,_Vertices,_NumFaces);
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   SetLength(_Faces,_NumFaces * _VerticesPerFace);
   SetLength(_Normals,0);
   SetLength(_FaceNormals,_NumFaces);
   SetLength(_TexCoords,0);
   SetLength(_Colours,_NumFaces);
   SetLength(VertexTransformation,High(_Vertices)+1);
   FillQuadFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_VoxelMap,VertexTransformation,_NumVoxels,_VerticesPerFace);

   // Get the positions of the vertexes in the new vertex list, so we can eliminate
   // the unused ones.
   EliminateUselessVertices(VertexTransformation,_Vertices,_Faces,NumVertices);
   // Free memory
   SetLength(VertexTransformation,0);
   for x := Low(VertexMap) to High(VertexMap) do
   begin
      for y := Low(VertexMap[x]) to High(VertexMap[x]) do
      begin
         SetLength(VertexMap[x,y],0);
      end;
      SetLength(VertexMap[x],0);
   end;
   SetLength(VertexMap,0);
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

procedure TVoxelMeshGenerator.BuildModelFromVoxelMapWithExternalData(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer; var _VoxelMap: TVoxelMap);
var
   NumVertices : longword;
   VertexMap : T3DIntGrid;
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
      _NumFaces := 0;
      SetLength(_Faces,0);
      SetLength(_Normals,0);
      SetLength(_FaceNormals,0);
      SetLength(_TexCoords,0);
      SetLength(_Colours,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMapExternal(FaceMap,_VoxelMap,_Vertices,_NumFaces);
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   SetLength(_Faces,_NumFaces * _VerticesPerFace);
   SetLength(_Normals,0);
   SetLength(_FaceNormals,_NumFaces);
   SetLength(_TexCoords,0);
   SetLength(_Colours,_NumFaces);
   SetLength(VertexTransformation,High(_Vertices)+1);
   FillQuadFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_VoxelMap,VertexTransformation,_NumVoxels,_VerticesPerFace);

   // Get the positions of the vertexes in the new vertex list, so we can eliminate
   // the unused ones.
   EliminateUselessVertices(VertexTransformation,_Vertices,_Faces,NumVertices);
   // Free memory
   SetLength(VertexTransformation,0);
   for x := Low(VertexMap) to High(VertexMap) do
   begin
      for y := Low(VertexMap[x]) to High(VertexMap[x]) do
      begin
         SetLength(VertexMap[x,y],0);
      end;
      SetLength(VertexMap[x],0);
   end;
   SetLength(VertexMap,0);
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

procedure TVoxelMeshGenerator.BuildTriangleModelFromVoxelMap(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer; var _VoxelMap: TVoxelMap);
var
   NumVertices : longword;
   VertexMap : T3DIntGrid;
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
      _NumFaces := 0;
      SetLength(_Faces,0);
      SetLength(_Normals,0);
      SetLength(_FaceNormals,0);
      SetLength(_TexCoords,0);
      SetLength(_Colours,0);
      exit;
   end;
   // let's fill the vertices array
   FillVerticesArray(_Vertices,VertexMap,NumVertices);
   // Now, we'll look for the faces.
   SetupFaceMap(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // Now we give the faces an ID and count them.
   BuildFaceMap(FaceMap,_VoxelMap,_Vertices,_NumFaces);
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   SetLength(_Vertices,High(_Vertices)+_NumFaces+1);
   _NumFaces := _NumFaces * 4;
   SetLength(_Faces,_NumFaces * _VerticesPerFace);
   SetLength(_Normals,0);
   SetLength(_FaceNormals,_NumFaces);
   SetLength(_TexCoords,0);
   SetLength(_Colours,_NumFaces);
   SetLength(VertexTransformation,High(_Vertices)+1);
   FillTriangleFaces(_Voxel,_Palette,VertexMap,FaceMap,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_VoxelMap,VertexTransformation,_NumVoxels,NumVertices,_VerticesPerFace);

   // Get the positions of the vertexes in the new vertex list, so we can eliminate
   // the unused ones.
   EliminateUselessVertices(VertexTransformation,_Vertices,_Faces,NumVertices);
   // Free memory
   SetLength(VertexTransformation,0);
   for x := Low(VertexMap) to High(VertexMap) do
   begin
      for y := Low(VertexMap[x]) to High(VertexMap[x]) do
      begin
         SetLength(VertexMap[x,y],0);
      end;
      SetLength(VertexMap[x],0);
   end;
   SetLength(VertexMap,0);
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


procedure TVoxelMeshGenerator.LoadFromVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
begin
   BuildModelFromVoxel(_Voxel,_Palette,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_NumVoxels,_NumFaces,_VerticesPerFace);
end;

procedure TVoxelMeshGenerator.LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
var
   VoxelMap: TVoxelMap;
begin
   // Let's map our voxels.
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;

   BuildModelFromVoxelMap(_Voxel,_Palette,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_NumVoxels,_NumFaces,_VerticesPerFace,VoxelMap);

   VoxelMap.Free;
end;

procedure TVoxelMeshGenerator.LoadFromExternalVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
var
   VoxelMap: TVoxelMap;
begin
   // Let's map our voxels.
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateExternalSurfaceMap;

   BuildModelFromVoxelMapWithExternalData(_Voxel,_Palette,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_NumVoxels,_NumFaces,_VerticesPerFace,VoxelMap);

   VoxelMap.Free;
end;

procedure TVoxelMeshGenerator.LoadTrianglesFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette; var _Vertices: TAVector3f; var _Faces: auint32; var _Colours: TAVector4f; var _Normals,_FaceNormals: TAVector3f; var _TexCoords: TAVector2f; var _NumVoxels,_NumFaces: longword; const _VerticesPerFace: integer);
var
   VoxelMap: TVoxelMap;
begin
   // Let's map our voxels.
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;

   BuildTriangleModelFromVoxelMap(_Voxel,_Palette,_Vertices,_Faces,_Colours,_Normals,_FaceNormals,_TexCoords,_NumVoxels,_NumFaces,_VerticesPerFace,VoxelMap);

   VoxelMap.Free;
end;

function TVoxelMeshGenerator.IsPointValid(_x,_y,_z,_maxx,_maxy,_maxz: integer): boolean;
begin
   Result := (_x >= 0) and (_x <= _maxx) and (_y >= 0) and (_y <= _maxy) and (_z >= 0) and (_z <= _maxz);
end;

end.
