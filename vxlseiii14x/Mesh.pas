unit Mesh;

interface

uses math3d, voxel_engine, dglOpenGL, GLConstants, Graphics, Voxel, Normals,
      BasicDataTypes, BasicFunctions, Palette, VoxelMap, Dialogs, SysUtils,
      VoxelModelizer, BasicConstants, Math;

type
   TMeshMaterial = record
      TextureID: GLINT;
      TextureBehavior: integer;
      Ambient: TVector4f;
      Diffuse: TVector4f;
      Specular: TVector4f;
      Shininess: TVector4f;
      Emission: TVector4f;
   end;

   TRenderProc = procedure of object;
   TMesh = class
      private
         NormalsType : byte;
         ColoursType : byte;
         ColourGenStructure : byte;
         TransparencyLevel : single;
         Opened : boolean;
         // I/O
         procedure LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
         // Sets
         procedure SetRenderingProcedure;
         // Normals
         procedure ReNormalizeQuads;
         procedure ReNormalizeTriangles;
         procedure ReNormalizePerVertex;
         procedure TransformFaceToVertexNormals;
         // Misc
         procedure OverrideTransparency;
         function FindMeshCenter: TVector3f;
      public
         // These are the formal atributes
         Name : string;
         ID : longword;
         Next : integer;
         Son : integer; // not implemented yet.
         // Graphical atributes goes here
         FaceType : GLINT; // GL_QUADS for volumes, and GL_TRIANGLES for geometry
         VerticesPerFace : byte; // for optimization purposes only.
         NumFaces : longword;
         NumVoxels : longword; // for statistic purposes.
         Vertices : TAVector3f;
         Normals : TAVector3f;
         Colours : TAVector4f;
         Faces : auint32;
         TextCoords : TAVector2f;
         FaceNormals : TAVector3f;
         // Graphical and colision
         BoundingBox : TRectangle3f;
         Scale : TVector3f;
         IsColisionEnabled : boolean;
         IsVisible : boolean;
         // Rendering optimization
         RenderingProcedure : TRenderProc;
         List : Integer;
         // GUI
         IsSelected : boolean;
         // Constructors And Destructors
         constructor Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte); overload;
         constructor Create(const _Mesh : TMesh); overload;
         constructor CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
         destructor Destroy; override;
         procedure Clear;
         // I/O
         procedure RebuildVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
         // Sets
         procedure SetColoursType(_ColoursType: integer);
         procedure SetNormalsType(_NormalsType: integer);
         procedure SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
         procedure ForceColoursRendering;
         // Gets
         function IsOpened: boolean;

         // Mesh Effects
         procedure MeshSmooth;
         procedure MeshCubicSmooth;
         procedure MeshLanczosSmooth;
         procedure MeshUnsharpMasking;
         procedure MeshInflate;
         procedure MeshDeflate;

         // Colour Effects
         procedure ColourSmooth;
         procedure ColourCubicSmooth;
         procedure ColourUnsharpMasking;

         // Normals related
         procedure ReNormalizeMesh;
         function GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
         procedure ConvertFaceToVertexNormals;

         // Rendering methods
         procedure Render(var _Polycount, _VoxelCount: longword);
         procedure RenderWithoutNormalsAndColours;
         procedure RenderWithVertexNormalsAndNoColours;
         procedure RenderWithFaceNormalsAndNoColours;
         procedure RenderWithoutNormalsAndWithColoursPerVertex;
         procedure RenderWithVertexNormalsAndColours;
         procedure RenderWithFaceNormalsAndVertexColours;
         procedure RenderWithoutNormalsAndWithFaceColours;
         procedure RenderWithVertexNormalsAndFaceColours;
         procedure RenderWithFaceNormalsAndColours;
         procedure ForceRefresh;

         // Copies
         procedure Assign(const _Mesh : TMesh);

         // Texture related
         function CollectColours(var _ColourMap: auint32): TAVector4f;

         // Model optimization
         procedure RemoveInvisibleFaces;
         procedure ConvertQuadsToTris;

         // Miscelaneous
         procedure ForceTransparencyLevel(_TransparencyLevel : single);
   end;
   PMesh = ^TMesh;

implementation

constructor TMesh.Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte);
begin
   // Set basic variables:
   List := C_LIST_NONE;
   ID := _ID;
   VerticesPerFace := _VerticesPerFace;
   NumFaces := _NumFaces;
   NumVoxels := 0;
   SetColoursAndNormalsType(_ColoursType,_NormalsType);
   ColourGenStructure := _ColoursType;
   // Let's set the face type:
   if VerticesPerFace = 4 then
      FaceType := GL_QUADS
   else
      FaceType := GL_TRIANGLES;
   // Let's set the array sizes.
   SetLength(Vertices,_NumVertices);
   SetLength(Faces,_NumFaces);
   SetLength(TextCoords,_NumVertices);
   if (NormalsType and C_NORMALS_PER_VERTEX) <> 0 then
      SetLength(Normals,_NumVertices)
   else
      SetLength(Normals,0);
   if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      SetLength(FaceNormals,NumFaces)
   else
      SetLength(FaceNormals,0);
   if (ColoursType = C_COLOURS_PER_VERTEX) then
      SetLength(Colours,_NumVertices)
   else if (ColoursType = C_COLOURS_PER_FACE) then
      SetLength(Colours,NumFaces)
   else
      SetLength(Colours,0);
   // The rest
   BoundingBox.Min.X := _BoundingBox.Min.X;
   BoundingBox.Min.Y := _BoundingBox.Min.Y;
   BoundingBox.Min.Z := _BoundingBox.Min.Z;
   BoundingBox.Max.X := _BoundingBox.Max.X;
   BoundingBox.Max.Y := _BoundingBox.Max.Y;
   BoundingBox.Max.Z := _BoundingBox.Max.Z;
   Scale := SetVector(1,1,1);
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
   TransparencyLevel := 0;
   Opened := false;
   IsSelected := false;
   Next := -1;
   Son := -1;
end;

constructor TMesh.Create(const _Mesh : TMesh);
begin
   List := C_LIST_NONE;
   Assign(_Mesh);
end;

constructor TMesh.CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
var
   c : integer;
begin
   List := C_LIST_NONE;
   Clear;
   ColoursType := C_COLOURS_PER_FACE;
   ColourGenStructure := C_COLOURS_PER_FACE;
   ID := _ID;
   TransparencyLevel := 0;
   NumVoxels := 0;
   c := 1;
   while (c <= 16) and (_Voxel.Header.Name[c] <> #0) do
   begin
      Name := Name + _Voxel.Header.Name[c];
      inc(c);
   end;
   case _Quality of
      C_QUALITY_CUBED:
      begin
         LoadFromVoxel(_Voxel,_Palette);
      end;
      C_QUALITY_LANCZOS_QUADS:
      begin
         LoadFromVoxel(_Voxel,_Palette);
         MeshLanczosSmooth;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         LoadFromVoxel(_Voxel,_Palette);
         ConvertQuadsToTris;
         MeshLanczosSmooth;
         ColourSmooth;
         ConvertFaceToVertexNormals;
      end;
      C_QUALITY_HIGH:
      begin
         ModelizeFromVoxel(_Voxel,_Palette);
      end;
   end;
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
   IsSelected := false;
   Next := -1;
   Son := -1;
end;

destructor TMesh.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TMesh.Clear;
begin
   Opened := false;
   ForceRefresh;
   SetLength(Vertices,0);
   SetLength(Faces,0);
   SetLength(Colours,0);
   SetLength(Normals,0);
   SetLength(FaceNormals,0);
   SetLength(TextCoords,0);
end;


// I/O;
procedure TMesh.RebuildVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
begin
   Clear;
   case _Quality of
      C_QUALITY_CUBED:
      begin
         LoadFromVoxel(_Voxel,_Palette);
      end;
      C_QUALITY_LANCZOS_QUADS:
      begin
         LoadFromVoxel(_Voxel,_Palette);
         MeshLanczosSmooth;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         LoadFromVoxel(_Voxel,_Palette);
         ConvertQuadsToTris;
         MeshLanczosSmooth;
         ColourSmooth;
         ConvertFaceToVertexNormals;
      end;
      C_QUALITY_HIGH:
      begin
         ModelizeFromVoxel(_Voxel,_Palette);
      end;
   end;
   OverrideTransparency;
end;


procedure TMesh.LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   NumVertices : longword;
   VertexMap : array of array of array of integer;
   FaceMap : array of array of array of array of integer;
   x, y, z, i : longword;
   V : TVoxelUnpacked;
   v1, v2 : boolean;
begin
   VerticesPerFace := 4;
   FaceType := GL_QUADS;
   SetNormalsType(C_NORMALS_PER_FACE);
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.

   // Let's map the vertices.
   SetLength(VertexMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   // clear map
   for x := Low(VertexMap) to High(VertexMap) do
      for y := Low(VertexMap[x]) to High(VertexMap[x]) do
         for z := Low(VertexMap[x,y]) to High(VertexMap[x,y]) do
            VertexMap[x,y,z] := -1;
   // Now we give the vertices an ID and count them.
   NumVertices := 0;
   NumVoxels := 0;
   for x := Low(_Voxel.Data) to High(_Voxel.Data) do
      for y := Low(_Voxel.Data[x]) to High(_Voxel.Data[x]) do
         for z := Low(_Voxel.Data[x,y]) to High(_Voxel.Data[x,y]) do
         begin
            _Voxel.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               inc(NumVoxels);
               if VertexMap[x,y,z] = -1 then
               begin
                  VertexMap[x,y,z] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y,z] = -1 then
               begin
                  VertexMap[x+1,y,z] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x,y+1,z] = -1 then
               begin
                  VertexMap[x,y+1,z] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y+1,z] = -1 then
               begin
                  VertexMap[x+1,y+1,z] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x,y,z+1] = -1 then
               begin
                  VertexMap[x,y,z+1] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y,z+1] = -1 then
               begin
                  VertexMap[x+1,y,z+1] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x,y+1,z+1] = -1 then
               begin
                  VertexMap[x,y+1,z+1] := NumVertices;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y+1,z+1] = -1 then
               begin
                  VertexMap[x+1,y+1,z+1] := NumVertices;
                  inc(NumVertices);
               end;
            end;
         end;
   // vertex map is done.
   // let's fill the vertices array
   SetLength(Vertices,NumVertices);
   if NumVertices = 0 then
   begin
      NumFaces := 0;
      SetLength(Faces,0);
      SetLength(Normals,0);
      SetLength(FaceNormals,0);
      SetLength(TextCoords,0);
      SetLength(Colours,0);
      CommonVoxelLoadingActions(_Voxel);
      exit;
   end;
   for x := Low(VertexMap) to High(VertexMap) do
      for y := Low(VertexMap[x]) to High(VertexMap[x]) do
         for z := Low(VertexMap[x,y]) to High(VertexMap[x,y]) do
         begin
            if VertexMap[x,y,z] <> -1 then
            begin
               Vertices[VertexMap[x,y,z]].X := x;
               Vertices[VertexMap[x,y,z]].Y := y;
               Vertices[VertexMap[x,y,z]].Z := z;
            end;
         end;
   // Now, we'll look for the faces.
   SetLength(FaceMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1,3);
   // clear map
   for x := Low(FaceMap) to High(FaceMap) do
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            FaceMap[x,y,z,0] := -1;
            FaceMap[x,y,z,1] := -1;
            FaceMap[x,y,z,2] := -1;
         end;
   // Now we give the faces an ID and count them.
   NumFaces := 0;
   for i := Low(Vertices) to High(Vertices) do
   begin
      x := Round(Vertices[i].X);
      y := Round(Vertices[i].Y);
      z := Round(Vertices[i].Z);

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
         FaceMap[x,y,z,C_VOXEL_FACE_SIDE] := NumFaces;
         inc(NumFaces);
      end;

      // Checking for the height face.
      // Is there any chance of the user look at this face?
      // To know it, we need to check if the pixels (x and x-1) that
      // this face splits are actually used.
      v2 := false;
      if _Voxel.GetVoxelSafe(x,y,z-1,v) then
         v2 := v.Used;
      // We'll only make a face if exactly one of them is used.
      if (v1 xor v2) then
      begin
         // Then, we add the Face
         FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] := NumFaces;
         inc(NumFaces);
      end;

      // Checking for the depth face.
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
         FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] := NumFaces;
         inc(NumFaces);
      end;
   end;
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   SetLength(Faces,NumFaces * VerticesPerFace);
   SetLength(Normals,0);
   SetLength(FaceNormals,NumFaces);
   SetLength(TextCoords,0);
   SetLength(Colours,NumFaces);
   for i := Low(Vertices) to High(Vertices) do
   begin
      x := Round(Vertices[i].X);
      y := Round(Vertices[i].Y);
      z := Round(Vertices[i].Z);
      if FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x-1,y,z,v);
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace)] := VertexMap[x,y+1,z+1];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 1] := VertexMap[x,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 2] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 3] := VertexMap[x,y,z+1];
            end
            else
            begin
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 3] := VertexMap[x,y+1,z+1];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 2] := VertexMap[x,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 1] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace)] := VertexMap[x,y,z+1];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x-1,y,z,v);
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace)] := VertexMap[x,y+1,z+1];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 1] := VertexMap[x,y+1,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 2] := VertexMap[x,y,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 3] := VertexMap[x,y,z+1];
         end;
         // Normals
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         Colours[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL4[v.Colour];
      end;
      if FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x,y-1,z,v);
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 3] := VertexMap[x+1,y,z+1];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 2] := VertexMap[x+1,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 1] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace)] := VertexMap[x,y,z+1];
            end
            else
            begin
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace)] := VertexMap[x+1,y,z+1];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 1] := VertexMap[x+1,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 2] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 3] := VertexMap[x,y,z+1];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y-1,z,v);
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 3] := VertexMap[x+1,y,z+1];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 2] := VertexMap[x+1,y,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 1] := VertexMap[x,y,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace)] := VertexMap[x,y,z+1];
         end;
         // Normals
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].X := _Voxel.Normals[v.Normal].X;
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Y := _Voxel.Normals[v.Normal].Y;
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         Colours[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]] := _Palette.ColourGL4[v.Colour];
      end;
      if FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> -1 then
      begin
         // Now that we have the vertices, we can grab voxel data (v).
         if _Voxel.GetVoxelSafe(x,y,z,v) then
         begin
            if not v.Used then
            begin
               _Voxel.GetVoxelSafe(x,y,z-1,v);
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 3] := VertexMap[x+1,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 2] := VertexMap[x,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 1] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace)] := VertexMap[x+1,y,z];
            end
            else
            begin
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace)] := VertexMap[x+1,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 1] := VertexMap[x,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 2] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 3] := VertexMap[x+1,y,z];
            end;
         end
         else
         begin
            _Voxel.GetVoxelSafe(x,y,z-1,v);
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 3] := VertexMap[x+1,y+1,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 2] := VertexMap[x,y+1,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 1] := VertexMap[x,y,z];
            Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace)] := VertexMap[x+1,y,z];
         end;
         // Normals
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
         FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
         // Colour
         Colours[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL4[v.Colour];
      end;
   end;
   CommonVoxelLoadingActions(_Voxel);
end;


procedure TMesh.ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   VoxelMap,ColourMap : TVoxelMap;
   SemiSurfacesMap : T3DIntGrid;
   VoxelModelizer : TVoxelModelizer;
   x, y : integer;
begin
   VerticesPerFace := 3;
   FaceType := GL_TRIANGLES;
   ColoursType := C_COLOURS_PER_FACE;
   NormalsType := C_NORMALS_PER_FACE;
   SetLength(TextCoords,0);
   SetLength(Normals,0);
   // Voxel classification stage
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;
   VoxelMap.MapSemiSurfaces(SemiSurfacesMap);
   // Colour mapping stage
   ColourMap := TVoxelMap.Create(_Voxel,1,C_MODE_COLOUR,C_OUTSIDE_VOLUME);
   // Mesh generation process
   VoxelModelizer := TVoxelModelizer.Create(VoxelMap,SemiSurfacesMap,Vertices,Faces,FaceNormals,Colours,_Palette,ColourMap);
   NumFaces := (High(Faces)+1) div VerticesPerFace;
   // Do the rest.
   CommonVoxelLoadingActions(_Voxel);
   // Clear memory
   VoxelModelizer.Free;
   VoxelMap.Free;
   ColourMap.Free;
   for x := High(SemiSurfacesMap) downto Low(SemiSurfacesMap) do
   begin
      for y := High(SemiSurfacesMap[x]) downto Low(SemiSurfacesMap[x]) do
      begin
         SetLength(SemiSurfacesMap[x,y],0);
      end;
      SetLength(SemiSurfacesMap[x],0);
   end;
   SetLength(SemiSurfacesMap,0);
end;

procedure TMesh.CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
begin
   // The rest
   BoundingBox.Min.X := _Voxel.Tailer.MinBounds[1];
   BoundingBox.Min.Y := _Voxel.Tailer.MinBounds[2];
   BoundingBox.Min.Z := _Voxel.Tailer.MinBounds[3];
   BoundingBox.Max.X := _Voxel.Tailer.MaxBounds[1];
   BoundingBox.Max.Y := _Voxel.Tailer.MaxBounds[2];
   BoundingBox.Max.Z := _Voxel.Tailer.MaxBounds[3];
   Scale.X := (BoundingBox.Max.X - BoundingBox.Min.X) / _Voxel.Tailer.XSize;
   Scale.Y := (BoundingBox.Max.Y - BoundingBox.Min.Y) / _Voxel.Tailer.YSize;
   Scale.Z := (BoundingBox.Max.Z - BoundingBox.Min.Z) / _Voxel.Tailer.ZSize;
   Opened := true;
end;

// Mesh Effects.
procedure TMesh.MeshSmooth;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   SetLength(VertsHit,High(Vertices)+1,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      OriginalVertexes[i].X := Vertices[i].X;
      OriginalVertexes[i].Y := Vertices[i].Y;
      OriginalVertexes[i].Z := Vertices[i].Z;
      Vertices[i].X := 0;
      Vertices[i].Y := 0;
      Vertices[i].Z := 0;
      for j := Low(HitCounter) to High(HitCounter) do
      begin
         VertsHit[i,j] := false;
      end;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         i := (v + VerticesPerFace - 1) mod VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[Faces[v1],Faces[v2]] then
            begin
               Vertices[Faces[v1]].X := Vertices[Faces[v1]].X + OriginalVertexes[Faces[v2]].X;
               Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y + OriginalVertexes[Faces[v2]].Y;
               Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z + OriginalVertexes[Faces[v2]].Z;
               inc(HitCounter[Faces[v1]]);
               VertsHit[Faces[v1],Faces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod VerticesPerFace;
            inc(j);
         end;
      end;
   end;
   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HitCounter[v] > 0 then
      begin
         Vertices[v].X := Vertices[v].X / HitCounter[v];
         Vertices[v].Y := Vertices[v].Y / HitCounter[v];
         Vertices[v].Z := Vertices[v].Z / HitCounter[v];
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   for i := Low(Vertices) to High(Vertices) do
   begin
      SetLength(VertsHit[i],0);
   end;
   SetLength(VertsHit,0);
   ForceRefresh;
end;

procedure TMesh.MeshCubicSmooth;
const
   ONE_THIRD = 1/3;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   SetLength(VertsHit,High(Vertices)+1,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      OriginalVertexes[i].X := Vertices[i].X;
      OriginalVertexes[i].Y := Vertices[i].Y;
      OriginalVertexes[i].Z := Vertices[i].Z;
      Vertices[i].X := 0;
      Vertices[i].Y := 0;
      Vertices[i].Z := 0;
      for j := Low(HitCounter) to High(HitCounter) do
      begin
         VertsHit[i,j] := false;
      end;
      VertsHit[i,i] := true;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         i := (v + VerticesPerFace - 1) mod VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[Faces[v1],Faces[v2]] then
            begin
               Vertices[Faces[v1]].X := Vertices[Faces[v1]].X + Power((OriginalVertexes[Faces[v2]].X - OriginalVertexes[Faces[v1]].X),3);
               Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y + Power((OriginalVertexes[Faces[v2]].Y - OriginalVertexes[Faces[v1]].Y),3);
               Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z + Power((OriginalVertexes[Faces[v2]].Z - OriginalVertexes[Faces[v1]].Z),3);
               inc(HitCounter[Faces[v1]]);
               VertsHit[Faces[v1],Faces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod VerticesPerFace;
            inc(j);
         end;
      end;
   end;
   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HItCounter[v] > 0 then
      begin
         Vertices[v].X := OriginalVertexes[v].X + (Vertices[v].X / HitCounter[v]);
         Vertices[v].Y := OriginalVertexes[v].Y + (Vertices[v].Y / HitCounter[v]);
         Vertices[v].Z := OriginalVertexes[v].Z + (Vertices[v].Z / HitCounter[v]);
      end
      else
      begin
         Vertices[v].X := OriginalVertexes[v].X;
         Vertices[v].Y := OriginalVertexes[v].Y;
         Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   for i := Low(Vertices) to High(Vertices) do
   begin
      SetLength(VertsHit[i],0);
   end;
   SetLength(VertsHit,0);
   ForceRefresh;
end;

procedure TMesh.MeshLanczosSmooth;
const
   PI2 = Pi * Pi;
   PIDIV3 = Pi / 3;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
   Distance: single;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   SetLength(VertsHit,High(Vertices)+1,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      OriginalVertexes[i].X := Vertices[i].X;
      OriginalVertexes[i].Y := Vertices[i].Y;
      OriginalVertexes[i].Z := Vertices[i].Z;
      Vertices[i].X := 0;
      Vertices[i].Y := 0;
      Vertices[i].Z := 0;
      for j := Low(HitCounter) to High(HitCounter) do
      begin
         VertsHit[i,j] := false;
      end;
      VertsHit[i,i] := true;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         i := (v + VerticesPerFace - 1) mod VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[Faces[v1],Faces[v2]] then
            begin
               Distance := OriginalVertexes[Faces[v2]].X - OriginalVertexes[Faces[v1]].X;
               if Distance > 0 then
                  Vertices[Faces[v1]].X := Vertices[Faces[v1]].X + 1 - (3 * sin(Pi * Distance) * sin(PIDIV3 * Distance) / Power((PI * Distance),2))
               else if Distance < 0 then
                  Vertices[Faces[v1]].X := Vertices[Faces[v1]].X - 1 - (3 * sin(Pi * Distance) * sin(PIDIV3 * Distance) / Power((PI * Distance),2));
               Distance := OriginalVertexes[Faces[v2]].Y - OriginalVertexes[Faces[v1]].Y;
               if Distance > 0 then
                  Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y + 1 - (3 * sin(Pi * Distance) * sin(PIDIV3 * Distance) / Power((PI * Distance),2))
               else if Distance < 0 then
                  Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y - 1 - (3 * sin(Pi * Distance) * sin(PIDIV3 * Distance) / Power((PI * Distance),2));
               Distance := OriginalVertexes[Faces[v2]].Z - OriginalVertexes[Faces[v1]].Z;
               if Distance > 0 then
                  Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z + 1 - (3 * sin(Pi * Distance) * sin(PIDIV3 * Distance) / Power((PI * Distance),2))
               else if Distance < 0 then
                  Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z - 1 - (3 * sin(Pi * Distance) * sin(PIDIV3 * Distance) / Power((PI * Distance),2));
               inc(HitCounter[Faces[v1]]);
               VertsHit[Faces[v1],Faces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod VerticesPerFace;
            inc(j);
         end;
      end;
   end;
   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HItCounter[v] > 0 then
      begin
         Vertices[v].X := OriginalVertexes[v].X + (Vertices[v].X / HitCounter[v]);
         Vertices[v].Y := OriginalVertexes[v].Y + (Vertices[v].Y / HitCounter[v]);
         Vertices[v].Z := OriginalVertexes[v].Z + (Vertices[v].Z / HitCounter[v]);
      end
      else
      begin
         Vertices[v].X := OriginalVertexes[v].X;
         Vertices[v].Y := OriginalVertexes[v].Y;
         Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   for i := Low(Vertices) to High(Vertices) do
   begin
      SetLength(VertsHit[i],0);
   end;
   SetLength(VertsHit,0);
   ForceRefresh;
end;

procedure TMesh.MeshUnsharpMasking;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   SetLength(VertsHit,High(Vertices)+1,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      OriginalVertexes[i].X := Vertices[i].X;
      OriginalVertexes[i].Y := Vertices[i].Y;
      OriginalVertexes[i].Z := Vertices[i].Z;
      Vertices[i].X := 0;
      Vertices[i].Y := 0;
      Vertices[i].Z := 0;
      for j := Low(HitCounter) to High(HitCounter) do
      begin
         VertsHit[i,j] := false;
      end;
      VertsHit[i,i] := true;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         i := (v + VerticesPerFace - 1) mod VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[Faces[v1],Faces[v2]] then
            begin
               Vertices[Faces[v1]].X := Vertices[Faces[v1]].X + OriginalVertexes[Faces[v2]].X;
               Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y + OriginalVertexes[Faces[v2]].Y;
               Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z + OriginalVertexes[Faces[v2]].Z;
               inc(HitCounter[Faces[v1]]);
               VertsHit[Faces[v1],Faces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod VerticesPerFace;
            inc(j);
         end;
      end;
   end;
   // Finally, we do the unsharp masking effect here.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HItCounter[v] > 0 then
      begin
         Vertices[v].X := (2 * OriginalVertexes[v].X) - (Vertices[v].X / HitCounter[v]);
         Vertices[v].Y := (2 * OriginalVertexes[v].Y) - (Vertices[v].Y / HitCounter[v]);
         Vertices[v].Z := (2 * OriginalVertexes[v].Z) - (Vertices[v].Z / HitCounter[v]);
      end
      else
      begin
         Vertices[v].X := OriginalVertexes[v].X;
         Vertices[v].Y := OriginalVertexes[v].Y;
         Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   for i := Low(Vertices) to High(Vertices) do
   begin
      SetLength(VertsHit[i],0);
   end;
   SetLength(VertsHit,0);
   ForceRefresh;
end;

procedure TMesh.MeshDeflate;
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter;

    // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      Temp := (CenterPoint.X - Vertices[v].X) * 0.1;
      if Temp > 0 then
         Vertices[v].X := Vertices[v].X  + Power(Temp,2)
      else
         Vertices[v].X := Vertices[v].X - Power(Temp,2);
      Temp := (CenterPoint.Y - Vertices[v].Y) * 0.1;
      if Temp > 0 then
         Vertices[v].Y := Vertices[v].Y + Power(Temp,2)
      else
         Vertices[v].Y := Vertices[v].Y - Power(Temp,2);
      Temp := (CenterPoint.Z - Vertices[v].Z) * 0.1;
      if Temp > 0 then
         Vertices[v].Z := Vertices[v].Z + Power(Temp,2)
      else
         Vertices[v].Z := Vertices[v].Z - Power(Temp,2);
   end;
   ForceRefresh;
end;

procedure TMesh.MeshInflate;
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter;

    // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      Temp := (CenterPoint.X - Vertices[v].X) * 0.1;
      if Temp > 0 then
         Vertices[v].X := Vertices[v].X - Power(Temp,2)
      else
         Vertices[v].X := Vertices[v].X + Power(Temp,2);
      Temp := (CenterPoint.Y - Vertices[v].Y) * 0.1;
      if Temp > 0 then
         Vertices[v].Y := Vertices[v].Y - Power(Temp,2)
      else
         Vertices[v].Y := Vertices[v].Y + Power(Temp,2);
      Temp := (CenterPoint.Z - Vertices[v].Z) * 0.1;
      if Temp > 0 then
         Vertices[v].Z := Vertices[v].Z - Power(Temp,2)
      else
         Vertices[v].Z := Vertices[v].Z + Power(Temp,2);
   end;
   ForceRefresh;
end;

// Colour Effects.
procedure TMesh.ColourSmooth;
var
   HitCounter: array of integer;
   OriginalColours,VertColours : array of TVector4f;
   i,f,v,v1 : integer;
   MaxVerticePerFace: integer;
   MidPoint : TVector3f;
   Distance: single;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalColours,High(Colours)+1);
   SetLength(VertColours,High(Vertices)+1);
   // Reset values.
   for i := Low(Colours) to High(Colours) do
   begin
      OriginalColours[i].X := Colours[i].X;
      OriginalColours[i].Y := Colours[i].Y;
      OriginalColours[i].Z := Colours[i].Z;
      OriginalColours[i].W := Colours[i].W;
      Colours[i].X := 0;
      Colours[i].Y := 0;
      Colours[i].Z := 0;
      Colours[i].W := 0;
   end;
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      VertColours[i].X := 0;
      VertColours[i].Y := 0;
      VertColours[i].Z := 0;
      VertColours[i].W := 0;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // find central position of the face.
      MidPoint.X := 0;
      MidPoint.Y := 0;
      MidPoint.Z := 0;
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         MidPoint.X := MidPoint.X + Vertices[Faces[v1]].X;
         MidPoint.Y := MidPoint.Y + Vertices[Faces[v1]].Y;
         MidPoint.Z := MidPoint.Z + Vertices[Faces[v1]].Z;
      end;

      // check all colours from all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         Distance := sqrt(Power(MidPoint.X - Vertices[Faces[v1]].X,2) + Power(MidPoint.Y - Vertices[Faces[v1]].Y,2) + Power(MidPoint.Z - Vertices[Faces[v1]].Z,2));
         VertColours[Faces[v1]].X := VertColours[Faces[v1]].X + OriginalColours[f].X + (1 / Distance);
         VertColours[Faces[v1]].Y := VertColours[Faces[v1]].Y + OriginalColours[f].Y + (1 / Distance);
         VertColours[Faces[v1]].Z := VertColours[Faces[v1]].Z + OriginalColours[f].Z + (1 / Distance);
         VertColours[Faces[v1]].W := VertColours[Faces[v1]].W + OriginalColours[f].W + (1 / Distance);
         inc(HitCounter[Faces[v1]]);
      end;
   end;
   // Then, we do an average for each vertice.
   for v := Low(VertColours) to High(VertColours) do
   begin
      if HitCounter[v] > 0 then
      begin
         VertColours[v].X := VertColours[v].X / HitCounter[v];
         VertColours[v].Y := VertColours[v].Y / HitCounter[v];
         VertColours[v].Z := VertColours[v].Z / HitCounter[v];
         VertColours[v].W := VertColours[v].W / HitCounter[v];
      end;
   end;
   // Finally, define face colours.
   for f := 0 to NumFaces-1 do
   begin
      // average all colours from all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         Colours[f].X := Colours[f].X + VertColours[Faces[v1]].X;
         Colours[f].Y := Colours[f].Y + VertColours[Faces[v1]].Y;
         Colours[f].Z := Colours[f].Z + VertColours[Faces[v1]].Z;
         Colours[f].W := Colours[f].W + VertColours[Faces[v1]].W;
      end;
      // Get result
      Colours[f].X := (Colours[f].X / VerticesPerFace);
      Colours[f].Y := (Colours[f].Y / VerticesPerFace);
      Colours[f].Z := (Colours[f].Z / VerticesPerFace);
      Colours[f].W := (Colours[f].W / VerticesPerFace);
      // Avoid problematic colours:
      if Colours[f].X < 0 then
         Colours[f].X := 0
      else if Colours[f].X > 1 then
         Colours[f].X := 1;
      if Colours[f].Y < 0 then
         Colours[f].Y := 0
      else if Colours[f].Y > 1 then
         Colours[f].Y := 1;
      if Colours[f].Z < 0 then
         Colours[f].Z := 0
      else if Colours[f].Z > 1 then
         Colours[f].Z := 1;
      if Colours[f].W < 0 then
         Colours[f].W := 0
      else if Colours[f].W > 1 then
         Colours[f].W := 1;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalColours,0);
   SetLength(VertColours,0);
   ForceRefresh;
end;

procedure TMesh.ColourCubicSmooth;
var
   HitCounter: array of integer;
   OriginalColours,VertColours : array of TVector4f;
   i,f,v,v1 : integer;
   MaxVerticePerFace: integer;
   MidPoint : TVector3f;
   Distance: single;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalColours,High(Colours)+1);
   SetLength(VertColours,High(Vertices)+1);
   // Reset values.
   for i := Low(Colours) to High(Colours) do
   begin
      OriginalColours[i].X := Colours[i].X;
      OriginalColours[i].Y := Colours[i].Y;
      OriginalColours[i].Z := Colours[i].Z;
      OriginalColours[i].W := Colours[i].W;
      Colours[i].X := 0;
      Colours[i].Y := 0;
      Colours[i].Z := 0;
      Colours[i].W := 0;
   end;
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      VertColours[i].X := 0;
      VertColours[i].Y := 0;
      VertColours[i].Z := 0;
      VertColours[i].W := 0;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // find central position of the face.
      MidPoint.X := 0;
      MidPoint.Y := 0;
      MidPoint.Z := 0;
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         MidPoint.X := MidPoint.X + Vertices[Faces[v1]].X;
         MidPoint.Y := MidPoint.Y + Vertices[Faces[v1]].Y;
         MidPoint.Z := MidPoint.Z + Vertices[Faces[v1]].Z;
      end;

      // check all colours from all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         Distance := Power(sqrt(Power(MidPoint.X - Vertices[Faces[v1]].X,2) + Power(MidPoint.Y - Vertices[Faces[v1]].Y,2) + Power(MidPoint.Z - Vertices[Faces[v1]].Z,2)),3);
         VertColours[Faces[v1]].X := VertColours[Faces[v1]].X + OriginalColours[f].X + (1 / Distance);
         VertColours[Faces[v1]].Y := VertColours[Faces[v1]].Y + OriginalColours[f].Y + (1 / Distance);
         VertColours[Faces[v1]].Z := VertColours[Faces[v1]].Z + OriginalColours[f].Z + (1 / Distance);
         VertColours[Faces[v1]].W := VertColours[Faces[v1]].W + OriginalColours[f].W + (1 / Distance);
         inc(HitCounter[Faces[v1]]);
      end;
   end;
   // Then, we do an average for each vertice.
   for v := Low(VertColours) to High(VertColours) do
   begin
      if HitCounter[v] > 0 then
      begin
         VertColours[v].X := VertColours[v].X / HitCounter[v];
         VertColours[v].Y := VertColours[v].Y / HitCounter[v];
         VertColours[v].Z := VertColours[v].Z / HitCounter[v];
         VertColours[v].W := VertColours[v].W / HitCounter[v];
      end;
   end;
   // Finally, define face colours.
   for f := 0 to NumFaces-1 do
   begin
      // average all colours from all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         Colours[f].X := Colours[f].X + VertColours[Faces[v1]].X;
         Colours[f].Y := Colours[f].Y + VertColours[Faces[v1]].Y;
         Colours[f].Z := Colours[f].Z + VertColours[Faces[v1]].Z;
         Colours[f].W := Colours[f].W + VertColours[Faces[v1]].W;
      end;
      // Get result
      Colours[f].X := (Colours[f].X / VerticesPerFace);
      Colours[f].Y := (Colours[f].Y / VerticesPerFace);
      Colours[f].Z := (Colours[f].Z / VerticesPerFace);
      Colours[f].W := (Colours[f].W / VerticesPerFace);
      // Avoid problematic colours:
      if Colours[f].X < 0 then
         Colours[f].X := 0
      else if Colours[f].X > 1 then
         Colours[f].X := 1;
      if Colours[f].Y < 0 then
         Colours[f].Y := 0
      else if Colours[f].Y > 1 then
         Colours[f].Y := 1;
      if Colours[f].Z < 0 then
         Colours[f].Z := 0
      else if Colours[f].Z > 1 then
         Colours[f].Z := 1;
      if Colours[f].W < 0 then
         Colours[f].W := 0
      else if Colours[f].W > 1 then
         Colours[f].W := 1;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalColours,0);
   SetLength(VertColours,0);
   ForceRefresh;
end;

procedure TMesh.ColourUnsharpMasking;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   SetLength(VertsHit,High(Vertices)+1,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      OriginalVertexes[i].X := Vertices[i].X;
      OriginalVertexes[i].Y := Vertices[i].Y;
      OriginalVertexes[i].Z := Vertices[i].Z;
      Vertices[i].X := 0;
      Vertices[i].Y := 0;
      Vertices[i].Z := 0;
      for j := Low(HitCounter) to High(HitCounter) do
      begin
         VertsHit[i,j] := false;
      end;
      VertsHit[i,i] := true;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         i := (v + VerticesPerFace - 1) mod VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[Faces[v1],Faces[v2]] then
            begin
               Vertices[Faces[v1]].X := Vertices[Faces[v1]].X + OriginalVertexes[Faces[v2]].X;
               Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y + OriginalVertexes[Faces[v2]].Y;
               Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z + OriginalVertexes[Faces[v2]].Z;
               inc(HitCounter[Faces[v1]]);
               VertsHit[Faces[v1],Faces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod VerticesPerFace;
            inc(j);
         end;
      end;
   end;
   // Finally, we do the unsharp masking effect here.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HItCounter[v] > 0 then
      begin
         Vertices[v].X := (2 * OriginalVertexes[v].X) - (Vertices[v].X / HitCounter[v]);
         Vertices[v].Y := (2 * OriginalVertexes[v].Y) - (Vertices[v].Y / HitCounter[v]);
         Vertices[v].Z := (2 * OriginalVertexes[v].Z) - (Vertices[v].Z / HitCounter[v]);
      end
      else
      begin
         Vertices[v].X := OriginalVertexes[v].X;
         Vertices[v].Y := OriginalVertexes[v].Y;
         Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   for i := Low(Vertices) to High(Vertices) do
   begin
      SetLength(VertsHit[i],0);
   end;
   SetLength(VertsHit,0);
   ForceRefresh;
end;


// Sets
procedure TMesh.SetRenderingProcedure;
begin
   case (NormalsType) of
      C_NORMALS_DISABLED:
      begin
         case (ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := RenderWithoutNormalsAndColours;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := RenderWithoutNormalsAndWithColoursPerVertex;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := RenderWithoutNormalsAndWithFaceColours;
            end;
         end;
      end;
      C_NORMALS_PER_VERTEX:
      begin
         case (ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndNoColours;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndColours;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndFaceColours;
            end;
         end;
      end;
      C_NORMALS_PER_FACE:
      begin
         case (ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndNoColours;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndVertexColours;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndColours;
            end;
         end;
      end;
   end;
   ForceRefresh;
end;

procedure TMesh.SetColoursType(_ColoursType: integer);
begin
   ColoursType := _ColoursType and 3;
   SetRenderingProcedure;
end;

procedure TMesh.ForceColoursRendering;
begin
   ColoursType := ColourGenStructure;
   SetRenderingProcedure;
end;

procedure TMesh.SetNormalsType(_NormalsType: integer);
begin
   NormalsType := _NormalsType and 3;
   SetRenderingProcedure;
end;

procedure TMesh.SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
begin
   ColoursType := _ColoursType and 3;
   NormalsType := _NormalsType and 3;
   SetRenderingProcedure;
end;

// Gets
function TMesh.IsOpened: boolean;
begin
   Result := Opened;
end;


// Rendering methods.
procedure TMesh.Render(var _PolyCount,_VoxelCount: longword);
begin
   if IsVisible and Opened then
   begin
      inc(_PolyCount,NumFaces);
      inc(_VoxelCount,NumVoxels);
      if List = C_LIST_NONE then
      begin
         List := glGenLists(1);
         glNewList(List, GL_COMPILE);
         if TransparencyLevel <> 0 then
         begin
            glEnable(GL_BLEND);
            glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
            RenderingProcedure();
            glDisable(GL_BLEND);
         end
         else
         begin
            RenderingProcedure();
         end;
         glEndList;
      end;
      // Move accordingly to the bounding box position.
      glTranslatef(BoundingBox.Min.X, BoundingBox.Min.Y, BoundingBox.Min.Z);
      glCallList(List);
   end;
end;

procedure TMesh.RenderWithoutNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor4f(0.5,0.5,0.5,0);
   glNormal3f(0,0,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithVertexNormalsAndNoColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor4f(0.5,0.5,0.5,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithFaceNormalsAndNoColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor4f(0.5,0.5,0.5,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithoutNormalsAndWithColoursPerVertex;
var
   i,f,v : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glColor4f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z,Colours[Faces[f]].W);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithVertexNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glColor4f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z,Colours[Faces[f]].W);
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithFaceNormalsAndVertexColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glColor4f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z,Colours[Faces[f]].W);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithoutNormalsAndWithFaceColours;
var
   i,f,v : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glColor4f(Colours[i].X,Colours[i].Y,Colours[i].Z,Colours[i].W);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithVertexNormalsAndFaceColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glColor4f(Colours[i].X,Colours[i].Y,Colours[i].Z,Colours[i].W);
         while (v < VerticesPerFace) do
         begin
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithFaceNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glColor4f(Colours[i].X,Colours[i].Y,Colours[i].Z,Colours[i].W);
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

// Basically clears the OpenGL List, so the RenderingProcedure may run next time it renders the mesh.
procedure TMesh.ForceRefresh;
begin
   if List > C_LIST_NONE then
   begin
      glDeleteLists(List,1);
   end;
   List := C_LIST_NONE;
end;

// Copies
procedure TMesh.Assign(const _Mesh : TMesh);
var
   i : integer;
begin
   NormalsType := _Mesh.NormalsType;
   ColoursType := _Mesh.ColoursType;
   TransparencyLevel := _Mesh.TransparencyLevel;
   Opened := _Mesh.Opened;
   Name := CopyString(_Mesh.Name);
   ID := _Mesh.ID;
   Son := _Mesh.Son;
   FaceType := _Mesh.FaceType;
   VerticesPerFace := _Mesh.VerticesPerFace;
   Scale.X := _Mesh.Scale.X;
   Scale.Y := _Mesh.Scale.Y;
   Scale.Z := _Mesh.Scale.Z;
   IsColisionEnabled := _Mesh.IsColisionEnabled;
   IsVisible := _Mesh.IsVisible;
   IsSelected := _Mesh.IsSelected;
   BoundingBox.Min.X := _Mesh.BoundingBox.Min.X;
   BoundingBox.Min.Y := _Mesh.BoundingBox.Min.Y;
   BoundingBox.Min.Z := _Mesh.BoundingBox.Min.Z;
   BoundingBox.Max.X := _Mesh.BoundingBox.Max.X;
   BoundingBox.Max.Y := _Mesh.BoundingBox.Max.Y;
   BoundingBox.Max.Z := _Mesh.BoundingBox.Max.Z;
   SetLength(Vertices,High(_Mesh.Vertices) + 1);
   for i := Low(Vertices) to High(Vertices) do
   begin
      Vertices[i].X := _Mesh.Vertices[i].X;
      Vertices[i].Y := _Mesh.Vertices[i].Y;
      Vertices[i].Z := _Mesh.Vertices[i].Z;
   end;
   SetLength(Faces,High(_Mesh.Faces)+1);
   for i := Low(Faces) to High(Faces) do
   begin
      Faces[i] := _Mesh.Faces[i];
   end;
   SetLength(Normals,High(_Mesh.Normals)+1);
   for i := Low(Normals) to High(Normals) do
   begin
      Normals[i].X := _Mesh.Normals[i].X;
      Normals[i].Y := _Mesh.Normals[i].Y;
      Normals[i].Z := _Mesh.Normals[i].Z;
   end;
   SetLength(FaceNormals,High(_Mesh.FaceNormals)+1);
   for i := Low(FaceNormals) to High(FaceNormals) do
   begin
      FaceNormals[i].X := _Mesh.FaceNormals[i].X;
      FaceNormals[i].Y := _Mesh.FaceNormals[i].Y;
      FaceNormals[i].Z := _Mesh.FaceNormals[i].Z;
   end;
   SetLength(Colours,High(_Mesh.Colours)+1);
   for i := Low(Colours) to High(Colours) do
   begin
      Colours[i].X := _Mesh.Colours[i].X;
      Colours[i].Y := _Mesh.Colours[i].Y;
      Colours[i].Z := _Mesh.Colours[i].Z;
      Colours[i].W := _Mesh.Colours[i].W;
   end;
   SetLength(TextCoords,High(_Mesh.TextCoords)+1);
   for i := Low(TextCoords) to High(TextCoords) do
   begin
      TextCoords[i].U := _Mesh.TextCoords[i].U;
      TextCoords[i].V := _Mesh.TextCoords[i].V;
   end;
   Next := _Mesh.Next;
end;

// Texture related
function TMesh.CollectColours(var _ColourMap: auint32): TAVector4f;
var
   i,f: integer;
   found : boolean;
begin
   SetLength(Result,0);
   SetLength(_ColourMap,High(Colours)+1);
   for f := Low(Colours) to High(Colours) do
   begin
      i := Low(Result);
      found := false;
      while (i < High(Result)) and (not found) do
      begin
         if (Colours[f].X = Result[i].X) and (Colours[f].Y = Result[i].Y) and (Colours[f].Z = Result[i].Z) and (Colours[f].W = Result[i].W) then
         begin
            found := true;
            _ColourMap[f] := i;
         end
         else
            inc(i);
      end;
      if not found then
      begin
         SetLength(Result,High(Result)+2);
         Result[High(Result)].X := Colours[f].X;
         Result[High(Result)].Y := Colours[f].Y;
         Result[High(Result)].Z := Colours[f].Z;
         Result[High(Result)].W := Colours[f].W;
         _ColourMap[f] := High(Result);
      end;
   end;
end;


// Miscelaneous
procedure TMesh.OverrideTransparency;
var
   c : integer;
begin
   for c := Low(Colours) to High(Colours) do
   begin
      Colours[c].W := TransparencyLevel;
   end;
end;

procedure TMesh.ForceTransparencyLevel(_TransparencyLevel : single);
begin
   TransparencyLevel := _TransparencyLevel;
   OverrideTransparency;
   ForceRefresh;
end;

function TMesh.FindMeshCenter: TVector3f;
var
   v : integer;
   MaxPoint,MinPoint: TVector3f;
begin
   if High(Vertices) >= 0 then
   begin
      MinPoint.X := Vertices[0].X;
      MinPoint.Y := Vertices[0].Y;
      MinPoint.Z := Vertices[0].Z;
      MaxPoint.X := Vertices[0].X;
      MaxPoint.Y := Vertices[0].Y;
      MaxPoint.Z := Vertices[0].Z;
      // Find mesh scope.
      for v := Low(Vertices) to High(Vertices) do
      begin
         if (Vertices[v].X < MinPoint.X) and (Vertices[v].X <> -NAN) then
         begin
            MinPoint.X := Vertices[v].X;
         end;
         if Vertices[v].X > MaxPoint.X then
         begin
            MaxPoint.X := Vertices[v].X;
         end;
         if (Vertices[v].Y < MinPoint.Y) and (Vertices[v].Y <> -NAN) then
         begin
            MinPoint.Y := Vertices[v].Y;
         end;
         if Vertices[v].Y > MaxPoint.Y then
         begin
            MaxPoint.Y := Vertices[v].Y;
         end;
         if (Vertices[v].Z < MinPoint.Z) and (Vertices[v].Z <> -NAN) then
         begin
            MinPoint.Z := Vertices[v].Z;
         end;
         if Vertices[v].Z > MaxPoint.Z then
         begin
            MaxPoint.Z := Vertices[v].Z;
         end;
      end;
      Result.X := (MinPoint.X + MaxPoint.X) / 2;
      Result.Y := (MinPoint.Y + MaxPoint.Y) / 2;
      Result.Z := (MinPoint.Z + MaxPoint.Z) / 2;
   end
   else
   begin
      Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
   end;
end;

procedure TMesh.ReNormalizeMesh;
begin
   if FaceType = GL_QUADS then
      ReNormalizeQuads
   else
      ReNormalizeTriangles;
end;

procedure TMesh.ReNormalizeQuads;
var
   f : integer;
   temp : TVector3f;
begin
   if High(FaceNormals) >= 0 then
   begin
      for f := Low(FaceNormals) to High(faceNormals) do
      begin
         FaceNormals[f] := GetNormalsValue(Vertices[Faces[f*4]],Vertices[Faces[(f*4)+1]],Vertices[Faces[(f*4)+2]]);
         Temp := GetNormalsValue(Vertices[Faces[(f*4)+2]],Vertices[Faces[(f*4)+3]],Vertices[Faces[f*4]]);
         FaceNormals[f].X := (FaceNormals[f].X + Temp.X) / -2;
         FaceNormals[f].Y := (FaceNormals[f].Y + Temp.Y) / -2;
         FaceNormals[f].Z := (FaceNormals[f].Z + Temp.Z) / -2;
      end;
   end
   else if High(Normals) >= 0 then
   begin
      ReNormalizePerVertex;
   end;
   ForceRefresh;
end;

procedure TMesh.ReNormalizeTriangles;
var
   f : integer;
begin
   if High(FaceNormals) >= 0 then
   begin
      for f := Low(FaceNormals) to High(FaceNormals) do
      begin
         FaceNormals[f] := GetNormalsValue(Vertices[Faces[f*3]],Vertices[Faces[(f*3)+1]],Vertices[Faces[(f*3)+2]]);
         FaceNormals[f].X := -FaceNormals[f].X;
         FaceNormals[f].Y := -FaceNormals[f].Y;
         FaceNormals[f].Z := -FaceNormals[f].Z;
      end;
   end
   else if High(Normals) >= 0 then
   begin
      ReNormalizePerVertex;
   end;
   ForceRefresh;
end;

procedure TMesh.ReNormalizePerVertex;
var
   HitCounter: array of integer;
   i,f,v,v1 : integer;
   MaxVerticePerFace: integer;
   Normals1,Normals2 : TVector3f;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(Normals,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      Normals[i].X := 0;
      Normals[i].Y := 0;
      Normals[i].Z := 0;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   if MaxVerticePerFace = 2 then
   begin
      for f := 0 to NumFaces-1 do
      begin
         v1 := (f * VerticesPerFace);
         Normals1 := GetNormalsValue(Vertices[Faces[v1]],Vertices[Faces[v1+1]],Vertices[Faces[v1+2]]);

         // check all vertexes from the face.
         for v := 0 to MaxVerticePerFace do
         begin
            Normals[Faces[v1+v]].X := Normals[Faces[v1+v]].X - Normals1.X;
            Normals[Faces[v1+v]].Y := Normals[Faces[v1+v]].Y - Normals1.Y;
            Normals[Faces[v1+v]].Z := Normals[Faces[v1+v]].Z - Normals1.Z;
            inc(HitCounter[Faces[v1+v]]);
         end;
      end;
   end
   else
   begin
      for f := 0 to NumFaces-1 do
      begin
         v1 := (f * VerticesPerFace);
         Normals1 := GetNormalsValue(Vertices[Faces[v1]],Vertices[Faces[v1+1]],Vertices[Faces[v1+2]]);
         Normals2 := GetNormalsValue(Vertices[Faces[v1+2]],Vertices[Faces[v1+3]],Vertices[Faces[v1]]);

         // check all vertexes from the face.
         for v := 0 to MaxVerticePerFace do
         begin
            Normals[Faces[v1+v]].X := Normals[Faces[v1+v]].X - ((Normals1.X + Normals2.X) / 2);
            Normals[Faces[v1+v]].Y := Normals[Faces[v1+v]].Y - ((Normals1.Y + Normals2.Y) / 2);
            Normals[Faces[v1+v]].Z := Normals[Faces[v1+v]].Z - ((Normals1.Z + Normals2.Z) / 2);
            inc(HitCounter[Faces[v1+v]]);
         end;
      end;
   end;
   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HitCounter[v] > 0 then
      begin
         Normals[v].X := Normals[v].X / HitCounter[v];
         Normals[v].Y := Normals[v].Y / HitCounter[v];
         Normals[v].Z := Normals[v].Z / HitCounter[v];
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
end;

procedure TMesh.TransformFaceToVertexNormals;
var
   HitCounter: array of integer;
   i,f,v,v1 : integer;
   MaxVerticePerFace: integer;
begin
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(Normals,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      Normals[i].X := 0;
      Normals[i].Y := 0;
      Normals[i].Z := 0;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   if MaxVerticePerFace = 2 then
   begin
      for f := 0 to NumFaces-1 do
      begin
         v1 := (f * VerticesPerFace);

         // check all vertexes from the face.
         for v := 0 to MaxVerticePerFace do
         begin
            Normals[Faces[v1+v]].X := Normals[Faces[v1+v]].X + FaceNormals[f].X;
            Normals[Faces[v1+v]].Y := Normals[Faces[v1+v]].Y + FaceNormals[f].Y;
            Normals[Faces[v1+v]].Z := Normals[Faces[v1+v]].Z + FaceNormals[f].Z;
            inc(HitCounter[Faces[v1+v]]);
         end;
      end;
   end;
   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HitCounter[v] > 0 then
      begin
         Normals[v].X := Normals[v].X / HitCounter[v];
         Normals[v].Y := Normals[v].Y / HitCounter[v];
         Normals[v].Z := Normals[v].Z / HitCounter[v];
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
end;


procedure TMesh.ConvertFaceToVertexNormals;
begin
   if (NormalsType and C_NORMALS_PER_VERTEX) = 0 then
   begin
      NormalsType := C_NORMALS_PER_VERTEX;
      if High(FaceNormals) >= 0 then
      begin
         TransformFaceToVertexNormals;
         SetLength(FaceNormals,0);
      end
      else
      begin
         ReNormalizePerVertex;
      end;
      SetRenderingProcedure;
   end;
end;

function TMesh.GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
begin
   Result.X := (((_V3.Y - _V2.Y) * (_V1.Z - _V2.Z)) - ((_V1.Y - _V2.Y) * (_V3.Z - _V2.Z)));
   Result.Y := (((_V3.Z - _V2.Z) * (_V1.X - _V2.X)) - ((_V1.Z - _V2.Z) * (_V3.X - _V2.X)));
   Result.Z := (((_V3.X - _V2.X) * (_V1.Y - _V2.Y)) - ((_V1.X - _V2.X) * (_V3.Y - _V2.Y)));
   Normalize(Result);
end;

procedure TMesh.RemoveInvisibleFaces;
var
   iRead,iWrite,v: integer;
   MarkForRemoval: boolean;
   Normal : TVector3f;
begin
   iRead := 0;
   iWrite := 0;
   while iRead <= High(Faces) do
   begin
      MarkForRemoval := false;
      // check if vertexes are NaN.
      v := 0;
      while v < VerticesPerFace do
      begin
         if IsNaN(Vertices[Faces[iRead+v]].X) or IsNaN(Vertices[Faces[iRead+v]].Y) or IsNaN(Vertices[Faces[iRead+v]].Z) or IsInfinite(Vertices[Faces[iRead+v]].X) or IsInfinite(Vertices[Faces[iRead+v]].Y) or IsInfinite(Vertices[Faces[iRead+v]].Z) then
         begin
            MarkForRemoval := true;
         end;
         inc(v);
      end;
      if not MarkForRemoval then
      begin
         // check if normal is 0,0,0.
         Normal := GetNormalsValue(Vertices[Faces[iRead]],Vertices[Faces[iRead+1]],Vertices[Faces[iRead+2]]);
         if (Normal.X = 0) and (Normal.Y = 0) and (Normal.Z = 0) then
            MarkForRemoval := true;
         if VerticesPerFace = 4 then
         begin
            Normal := GetNormalsValue(Vertices[Faces[iRead+2]],Vertices[Faces[iRead+3]],Vertices[Faces[iRead]]);
            if (Normal.X = 0) and (Normal.Y = 0) and (Normal.Z = 0) then
               MarkForRemoval := true;
          end;
      end;

      // Finally, we remove it.
      if not MarkForRemoval then
      begin
         v := 0;
         while v < VerticesPerFace do
         begin
            Faces[iWrite+v] := Faces[iRead+v];
            inc(v);
         end;
         if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
         begin
            FaceNormals[iWrite div VerticesPerFace].X := FaceNormals[iRead div VerticesPerFace].X;
            FaceNormals[iWrite div VerticesPerFace].Y := FaceNormals[iRead div VerticesPerFace].Y;
            FaceNormals[iWrite div VerticesPerFace].Z := FaceNormals[iRead div VerticesPerFace].Z;
         end;
         if (ColoursType = C_COLOURS_PER_FACE) then
         begin
            Colours[iWrite div VerticesPerFace].X := Colours[iRead div VerticesPerFace].X;
            Colours[iWrite div VerticesPerFace].Y := Colours[iRead div VerticesPerFace].Y;
            Colours[iWrite div VerticesPerFace].Z := Colours[iRead div VerticesPerFace].Z;
            Colours[iWrite div VerticesPerFace].W := Colours[iRead div VerticesPerFace].W;
         end;
         iWrite := iWrite + VerticesPerFace;
      end;
      iRead := iRead + VerticesPerFace;
   end;
   NumFaces := iWrite div VerticesPerFace;
   SetLength(Faces,iWrite);
   if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
   begin
      SetLength(FaceNormals,NumFaces);
   end;
   if (ColoursType = C_COLOURS_PER_FACE) then
   begin
      SetLength(Colours,NumFaces);
   end;
   ForceRefresh;
end;

procedure TMesh.ConvertQuadsToTris;
var
   OldFaces: auint32;
   OldFaceNormals: TAVector3f;
   OldColours: TAVector4f;
   OldNumFaces : integer;
   i : integer;
begin
   if VerticesPerFace <> 3 then
   begin
      // Start with face conversion.
      VerticesPerFace := 3;
      FaceType := GL_TRIANGLES;
      OldNumFaces := NumFaces;
      NumFaces := NumFaces * 2;
      // Make a backup of the faces first.
      SetLength(OldFaces,High(Faces)+1);
      for i := Low(Faces) to High(Faces) do
         OldFaces[i] := Faces[i];
      // Now we transform each quad in two tris.
      SetLength(Faces,Round((High(Faces)+1)*1.5));
      for i := 0 to OldNumFaces - 1 do
      begin
         Faces[i*6] := OldFaces[i*4];
         Faces[(i*6)+1] := OldFaces[(i*4)+1];
         Faces[(i*6)+2] := OldFaces[(i*4)+2];
         Faces[(i*6)+3] := OldFaces[(i*4)+2];
         Faces[(i*6)+4] := OldFaces[(i*4)+3];
         Faces[(i*6)+5] := OldFaces[(i*4)];
      end;
      SetLength(OldFaces,0);
      // Go with Colour conversion.
      if (ColoursType = C_COLOURS_PER_FACE) then
      begin
         // Make a backup of the colours first.
         SetLength(OldColours,High(Colours)+1);
         for i := Low(Colours) to High(Colours) do
         begin
            OldColours[i].X := Colours[i].X;
            OldColours[i].Y := Colours[i].Y;
            OldColours[i].Z := Colours[i].Z;
            OldColours[i].W := Colours[i].W;
         end;
         // Duplicate the colours.
         SetLength(Colours,NumFaces);
         for i := 0 to OldNumFaces - 1 do
         begin
            Colours[i*2].X := OldColours[i].X;
            Colours[i*2].Y := OldColours[i].Y;
            Colours[i*2].Z := OldColours[i].Z;
            Colours[i*2].W := OldColours[i].W;
            Colours[(i*2)+1].X := OldColours[i].X;
            Colours[(i*2)+1].Y := OldColours[i].Y;
            Colours[(i*2)+1].Z := OldColours[i].Z;
            Colours[(i*2)+1].W := OldColours[i].W;
         end;
         SetLength(OldColours,0);
      end;
      // Go with Normals conversion.
      if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      begin
         // Make a backup of the normals first.
         SetLength(OldFaceNormals,High(FaceNormals)+1);
         for i := Low(FaceNormals) to High(FaceNormals) do
         begin
            OldFaceNormals[i].X := FaceNormals[i].X;
            OldFaceNormals[i].Y := FaceNormals[i].Y;
            OldFaceNormals[i].Z := FaceNormals[i].Z;
         end;
         // Duplicate the face normals.
         SetLength(FaceNormals,NumFaces);
         for i := 0 to OldNumFaces - 1 do
         begin
            FaceNormals[i*2].X := OldFaceNormals[i].X;
            FaceNormals[i*2].Y := OldFaceNormals[i].Y;
            FaceNormals[i*2].Z := OldFaceNormals[i].Z;
            FaceNormals[(i*2)+1].X := OldFaceNormals[i].X;
            FaceNormals[(i*2)+1].Y := OldFaceNormals[i].Y;
            FaceNormals[(i*2)+1].Z := OldFaceNormals[i].Z;
         end;
         SetLength(OldFaceNormals,0);
      end;
      ForceRefresh;
   end;
end;


end.
