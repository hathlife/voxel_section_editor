unit Mesh;

interface

uses math3d, voxel_engine, dglOpenGL, GLConstants, Graphics, Voxel, Normals,
      BasicDataTypes, Palette, VoxelMap;

type
   TRenderProc = procedure of object;
   TMesh = class
      private
         NormalsType : byte;
         ColoursType : byte;
         // I/O
         procedure LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         // Sets
         procedure SetRenderingProcedure;
      public
         // These are the formal atributes
         Name : string;
         ID : longword;
         Parent : integer;
         // Graphical atributes goes here
         FaceType : GLINT; // GL_QUADS for volumes, and GL_TRIANGLES for geometry
         VerticesPerFace : byte; // for optimization purposes only.
         Vertices : array of TVector3f;
         Normals : array of TVector3f;
         Colours : array of TVector3f;
         Faces : array of longword;
         TextCoords : array of TVector2f;
         FaceNormals : array of TVector3f;
         // Graphical and colision
         BoundingBox : TRectangle3f;
         Scale : TVector3f;
         IsColisionEnabled : boolean;
         IsVisible : boolean;
         Texture: integer;
         // Rendering optimization
         RenderingProcedure : TRenderProc;
         List : Integer;

         // Constructors And Destructors
         constructor Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte);
         constructor CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _HighQuality: boolean = false);
         destructor Destroy; override;
         procedure Clear;

         // Sets
         procedure SetColoursType(_ColoursType: integer);
         procedure SetNormalsType(_NormalsType: integer);
         procedure SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);

         // Rendering methods
         procedure Render(var _Polycount: longword);
         procedure RenderWithoutNormalsAndColours;
         procedure RenderWithVertexNormalsAndNoColours;
         procedure RenderWithFaceNormalsAndNoColours;
         procedure RenderWithoutNormalsAndWithColoursPerVertex;
         procedure RenderWithVertexNormalsAndColours;
         procedure RenderWithFaceNormalsAndVertexColours;
         procedure RenderWithoutNormalsAndWithFaceColours;
         procedure RenderWithVertexNormalsAndFaceColours;
         procedure RenderWithFaceNormalsAndColours;
         procedure ForceRebuildMesh;
   end;


implementation

constructor TMesh.Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte);
begin
   // Set basic variables:
   ID := _ID;
   VerticesPerFace := _VerticesPerFace;
   SetColoursAndNormalsType(_ColoursType,_NormalsType);
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
      SetLength(FaceNormals,_NumFaces)
   else
      SetLength(FaceNormals,0);
   if (ColoursType = C_COLOURS_PER_VERTEX) then
      SetLength(Colours,_NumVertices)
   else if (ColoursType = C_COLOURS_PER_FACE) then
      SetLength(Colours,_NumFaces)
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
end;

constructor TMesh.CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _HighQuality: boolean = false);
begin
   ID := _ID;
   if _HighQuality then
   begin
      ModelizeFromVoxel(_Voxel,_Palette);
   end
   else
   begin
      LoadFromVoxel(_Voxel,_Palette);
   end;
end;

destructor TMesh.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TMesh.Clear;
begin
   ForceRebuildMesh;
   SetLength(Vertices,0);
   SetLength(Faces,0);
   SetLength(Colours,0);
   SetLength(Normals,0);
   SetLength(FaceNormals,0);
   SetLength(TextCoords,0);
end;


// I/O;
procedure TMesh.LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   NumVertices, NumFaces : longword;
   VertexMap : array of array of array of integer;
   FaceMap : array of array of array of array of integer;
   x, y, z : longword;
   V : TVoxelUnpacked;
   v1, v2 : boolean;
begin
   VerticesPerFace := 4;
   FaceType := GL_QUADS;
   SetColoursAndNormalsType(C_COLOURS_PER_FACE,C_NORMALS_PER_FACE);
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
   for x := Low(_Voxel.Data) to High(_Voxel.Data) do
      for y := Low(_Voxel.Data[x]) to High(_Voxel.Data[x]) do
         for z := Low(_Voxel.Data[x,y]) to High(_Voxel.Data[x,y]) do
         begin
            _Voxel.GetVoxel(x,y,z,v);
            if v.Used then
            begin
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
   for x := Low(FaceMap) to High(FaceMap) do
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            // Checking for the side face.
            // 1. Do the vertices exists?
            if (y < High(VertexMap[0])) and (z < High(VertexMap[0,0]))  then
               if (VertexMap[x,y,z] <> -1) and (VertexMap[x,y+1,z] <> -1) and (VertexMap[x,y,z+1] <> -1) and (VertexMap[x,y+1,z+1] <> -1) then
               begin
                  // 2. Is there any chance of the user look at this face?
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
               end;

            // Checking for the depth face.
            // 1. Do the vertices exists?
            if (x < High(VertexMap)) and (z < High(VertexMap[0,0]))  then
               if (VertexMap[x,y,z] <> -1) and (VertexMap[x+1,y,z] <> -1) and (VertexMap[x,y,z+1] <> -1) and (VertexMap[x+1,y,z+1] <> -1) then
               begin
                  // 2. Is there any chance of the user look at this face?
                  // To know it, we need to check if the pixels (x and x-1) that
                  // this face splits are actually used.
                  v1 := false;
                  if _Voxel.GetVoxelSafe(x,y,z,v) then
                     v1 := v.Used;
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

            // Checking for the height face.
            // 1. Do the vertices exists?
            if (x < High(VertexMap)) and (y < High(VertexMap[0]))  then
               if (VertexMap[x,y,z] <> -1) and (VertexMap[x+1,y,z] <> -1) and (VertexMap[x,y+1,z] <> -1) and (VertexMap[x+1,y+1,z] <> -1) then
               begin
                  // 2. Is there any chance of the user look at this face?
                  // To know it, we need to check if the pixels (x and x-1) that
                  // this face splits are actually used.
                  v1 := false;
                  if _Voxel.GetVoxelSafe(x,y,z,v) then
                     v1 := v.Used;
                  v2 := false;
                  if _Voxel.GetVoxelSafe(x,y,z-1,v) then
                     v2 := v.Used;
                  // We'll only make a face if exactly one of them is used.
                  if (v1 xor v2) then
                  begin
                     // Then, we add the Face
                     FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] := NumFaces;
                     inc(NumFaces);
                  end;
               end;

         end;
   // face map is done.
   // let's fill the faces array, normals, colours, etc.
   SetLength(Faces,NumFaces * VerticesPerFace);
   SetLength(Normals,0);
   SetLength(FaceNormals,NumFaces);
   SetLength(TextCoords,0);
   SetLength(Colours,NumFaces);
   for x := Low(FaceMap) to High(FaceMap) do
      for y := Low(FaceMap[x]) to High(FaceMap[x]) do
         for z := Low(FaceMap[x,y]) to High(FaceMap[x,y]) do
         begin
            if FaceMap[x,y,z,C_VOXEL_FACE_SIDE] <> -1 then
            begin
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace)] := VertexMap[x,y+1,z+1];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 1] := VertexMap[x,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 2] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_SIDE] * VerticesPerFace) + 3] := VertexMap[x,y,z+1];
               // Now that we have the vertices, we can grab voxel data (v).
               if _Voxel.GetVoxelSafe(x,y,z,v) then
               begin
                  if not v.Used then
                  begin
                     _Voxel.GetVoxel(x-1,y,z,v);
                  end;
               end
               else
                  _Voxel.GetVoxel(x-1,y,z,v);
               // Normals
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].X := _Voxel.Normals[v.Normal].X;
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Y := _Voxel.Normals[v.Normal].Y;
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]].Z := _Voxel.Normals[v.Normal].Z;
               // Colour
               Colours[FaceMap[x,y,z,C_VOXEL_FACE_SIDE]] := _Palette.ColourGL[v.Colour];
            end;
            if FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] <> -1 then
            begin
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace)] := VertexMap[x+1,y,z+1];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 1] := VertexMap[x+1,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 2] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_DEPTH] * VerticesPerFace) + 3] := VertexMap[x,y,z+1];
               // Now that we have the vertices, we can grab voxel data (v).
               if _Voxel.GetVoxelSafe(x,y,z,v) then
               begin
                  if not v.Used then
                  begin
                     _Voxel.GetVoxel(x,y-1,z,v);
                  end;
               end
               else
                  _Voxel.GetVoxel(x,y-1,z,v);
               // Normals
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].X := _Voxel.Normals[v.Normal].X;
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Y := _Voxel.Normals[v.Normal].Y;
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]].Z := _Voxel.Normals[v.Normal].Z;
               // Colour
               Colours[FaceMap[x,y,z,C_VOXEL_FACE_DEPTH]] := _Palette.ColourGL[v.Colour];
            end;
            if FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] <> -1 then
            begin
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace)] := VertexMap[x+1,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 1] := VertexMap[x,y+1,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 2] := VertexMap[x,y,z];
               Faces[(FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT] * VerticesPerFace) + 3] := VertexMap[x+1,y,z];
               // Now that we have the vertices, we can grab voxel data (v).
               if _Voxel.GetVoxelSafe(x,y,z,v) then
               begin
                  if not v.Used then
                  begin
                     _Voxel.GetVoxel(x,y,z-1,v);
                  end;
               end
               else
                  _Voxel.GetVoxel(x,y,z-1,v);
               // Normals
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].X := _Voxel.Normals[v.Normal].X;
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Y := _Voxel.Normals[v.Normal].Y;
               FaceNormals[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]].Z := _Voxel.Normals[v.Normal].Z;
               // Colour
               Colours[FaceMap[x,y,z,C_VOXEL_FACE_HEIGHT]] := _Palette.ColourGL[v.Colour];
            end;
         end;
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
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
end;


procedure TMesh.ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   NumVertices, NumFaces : longword;
   VoxelMap : TVoxelMap;
   VertexMap : array of array of array of integer;
   FaceMap : array of array of array of array of integer;
   x, y, z : longword;
   V : TVoxelUnpacked;
   v1, v2 : boolean;
begin
   VerticesPerFace := 3;
   FaceType := GL_TRIANGLES;
   ColoursType := C_COLOURS_PER_FACE;
   NormalsType := C_NORMALS_PER_FACE;
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;
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
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
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
   ForceRebuildMesh;
end;

procedure TMesh.SetColoursType(_ColoursType: integer);
begin
   ColoursType := _ColoursType and 3;
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

// Rendering methods.
procedure TMesh.Render(var _PolyCount: longword);
begin
   if IsVisible then
   begin
      inc(_PolyCount,High(Faces)+1);
      if List = C_LIST_NONE then
      begin
         List := glGenLists(1);
         glNewList(List, GL_COMPILE);
         glPushMatrix;
            glLoadIdentity;
            RenderingProcedure();
         glPopMatrix;
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
   glColor3f(0.5,0.5,0.5);
   glNormal3f(0,0,0);
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithVertexNormalsAndNoColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor3f(0.5,0.5,0.5);
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithFaceNormalsAndNoColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor3f(0.5,0.5,0.5);
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithoutNormalsAndWithColoursPerVertex;
var
   i,f,v : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glColor3f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithVertexNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glColor3f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z);
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithFaceNormalsAndVertexColours;
var
   i,f,v : longword;
begin
   f := 0;
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glColor3f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithoutNormalsAndWithFaceColours;
var
   i,f,v : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         glColor3f(Colours[i].X,Colours[i].Y,Colours[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithVertexNormalsAndFaceColours;
var
   i,f,v : longword;
begin
   f := 0;
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         glColor3f(Colours[i].X,Colours[i].Y,Colours[i].Z);
         while (v < VerticesPerFace) do
         begin
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.RenderWithFaceNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   for i := Low(Faces) to High(Faces) do
   begin
      glBegin(FaceType);
         v := 0;
         glColor3f(Colours[i].X,Colours[i].Y,Colours[i].Z);
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
      glEnd();
   end;
end;

procedure TMesh.ForceRebuildMesh;
begin
   if List > C_LIST_NONE then
   begin
      glDeleteLists(List,1);
   end;
   List := C_LIST_NONE;
end;


end.
