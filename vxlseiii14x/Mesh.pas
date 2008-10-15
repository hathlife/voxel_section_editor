unit Mesh;

interface

uses math3d, voxel_engine, dglOpenGL, GLConstants, Graphics, Voxel;

type
   TMesh = class
      public
         // These are the formal atributes
         Name : string;
         ID : longword;
         Parent : integer;
         // Graphical atributes goes here
         FaceType : GLINT; // GL_QUADS for volumes, and GL_TRIANGLES for geometry
         NormalsType : byte;
         ColoursType : byte;
         VerticesPerFace : byte; // for optimization purposes only.
         Vertices : array of TVector3f;
         Normals : array of TVector3f;
         Colours : array of TColor;
         Faces : array of longword;
         TextCoords : array of TVector2f;
         FaceNormals : array of TVector3f;
         // Graphical and colision
         BoundingBox : TRectangle3f;
         IsColisionEnabled : boolean;
         IsVisible : boolean;

         // Constructors And Destructors
         constructor Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte);
         constructor CreateFromVoxel(_ID : longword; _Voxel : TVoxelSection);
   end;


implementation

constructor TMesh.Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte);
begin
   // Set basic variables:
   ID := _ID;
   VerticesPerFace := _VerticesPerFace;
   ColoursType := _ColoursType;
   NormalsType := _NormalsType;
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
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
end;

constructor TMesh.CreateFromVoxel(_ID : longword; _Voxel : TVoxelSection);
var
   NumVertices, NumFaces : longword;
   VertexMap : array of array of array of boolean;
   x, y, z : longword;
   V : TVoxelUnpacked;
begin
   ID := _ID;
   VerticesPerFace := 4;
   ColoursType := C_COLOURS_PER_FACE;
   NormalsType := C_NORMALS_PER_FACE;
   // Let's set the face type:
   if VerticesPerFace = 4 then
      FaceType := GL_QUADS
   else
      FaceType := GL_TRIANGLES;
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.

   // Let's map the vertices.
   SetLength(VertexMap,_Voxel.Tailer.XSize+1,_Voxel.Tailer.YSize+1,_Voxel.Tailer.ZSize+1);
   NumVertices := 0;
   for x := Low(_Voxel.Data) to High(_Voxel.Data) do
      for y := Low(_Voxel.Data[x]) to High(_Voxel.Data[x]) do
         for z := Low(_Voxel.Data[x,y]) to High(_Voxel.Data[x,y]) do
         begin
            _Voxel.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               if VertexMap[x,y,z] = false then
               begin
                  VertexMap[x,y,z] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y,z] = false then
               begin
                  VertexMap[x+1,y,z] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x,y+1,z] = false then
               begin
                  VertexMap[x,y+1,z] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y+1,z] = false then
               begin
                  VertexMap[x+1,y+1,z] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x,y,z+1] = false then
               begin
                  VertexMap[x,y,z+1] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y,z+1] = false then
               begin
                  VertexMap[x+1,y,z+1] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x,y+1,z+1] = false then
               begin
                  VertexMap[x,y+1,z+1] := true;
                  inc(NumVertices);
               end;
               if VertexMap[x+1,y+1,z+1] = false then
               begin
                  VertexMap[x+1,y+1,z+1] := true;
                  inc(NumVertices);
               end;
            end;
         end;



   // Let's set the array sizes.
   SetLength(Vertices,NumVertices);
   SetLength(Faces,NumFaces);
   SetLength(TextCoords,0);
   SetLength(Normals,0);
   SetLength(FaceNormals,NumFaces);
   SetLength(Colours,NumFaces);
   // The rest
   BoundingBox.Min.X := _Voxel.Tailer.MinBounds[1];
   BoundingBox.Min.Y := _Voxel.Tailer.MinBounds[2];
   BoundingBox.Min.Z := _Voxel.Tailer.MinBounds[3];
   BoundingBox.Max.X := _Voxel.Tailer.MaxBounds[1];
   BoundingBox.Max.Y := _Voxel.Tailer.MaxBounds[2];
   BoundingBox.Max.Z := _Voxel.Tailer.MaxBounds[3];
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
end;



end.
