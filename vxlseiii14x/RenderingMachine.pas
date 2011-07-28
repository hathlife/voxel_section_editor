unit RenderingMachine;

interface

uses BasicDataTypes, BasicConstants, BasicFunctions, DglOpenGL, GlConstants, Material;

type
   TRenderingMachine = class
      public
         List : integer;
         IsGeneratingList: boolean;
         // constructors and destructors.
         constructor Create;
         destructor Destroy; override;
         // Render basics
         procedure StartRender();
         procedure FinishRender(const _TranslatePosition: TVector3f);
         procedure ForceRefresh;
         // Rendering modes
         procedure RenderWithoutNormalsAndColours(const _Vertices: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithVertexNormalsAndNoColours(const _Vertices, _Normals: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithFaceNormalsAndNoColours(const _Vertices, _Normals: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithoutNormalsAndWithColoursPerVertex(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithVertexNormalsAndColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithFaceNormalsAndVertexColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithoutNormalsAndWithTexture(const _Vertices: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
         procedure RenderWithVertexNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
         procedure RenderWithFaceNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
         procedure RenderWithoutNormalsAndWithFaceColours(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithVertexNormalsAndFaceColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithFaceNormalsAndColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
   end;

implementation

// constructors and destructors.
constructor TRenderingMachine.Create;
begin
   List := C_LIST_NONE;
end;

destructor TRenderingMachine.Destroy;
begin
   ForceRefresh;
   inherited Destroy;
end;

// Render basics
procedure TRenderingMachine.StartRender();
begin
   if List = C_LIST_NONE then
   begin
      List := glGenLists(1);
      glNewList(List, GL_COMPILE);
      isGeneratingList := true;
   end;
end;

procedure TRenderingMachine.FinishRender(const _TranslatePosition: TVector3f);
begin
   if IsGeneratingList then
   begin
      glEndList;
   end;
   // Move accordingly to the bounding box position.
   glTranslatef(_TranslatePosition.X, _TranslatePosition.Y, _TranslatePosition.Z);
   glCallList(List);
   isGeneratingList := false;
end;

procedure TRenderingMachine.RenderWithoutNormalsAndColours(const _Vertices: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      glColor4f(0.5,0.5,0.5,C_TRP_OPAQUE);
      glNormal3f(0,0,0);
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            while (v < _VerticesPerFace) do
            begin
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithVertexNormalsAndNoColours(const _Vertices, _Normals: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      glColor4f(0.5,0.5,0.5,C_TRP_OPAQUE);
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            while (v < _VerticesPerFace) do
            begin
               glNormal3f(_Normals[_Faces[f]].X,_Normals[_Faces[f]].Y,_Normals[_Faces[f]].Z);
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithFaceNormalsAndNoColours(const _Vertices, _Normals: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      glColor4f(0.5,0.5,0.5,C_TRP_OPAQUE);
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            glNormal3f(_Normals[i].X,_Normals[i].Y,_Normals[i].Z);
            while (v < _VerticesPerFace) do
            begin
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithoutNormalsAndWithColoursPerVertex(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      glNormal3f(0,0,0);
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            while (v < _VerticesPerFace) do
            begin
               glColor4f(_Colours[_Faces[f]].X,_Colours[_Faces[f]].Y,_Colours[_Faces[f]].Z,_Colours[_Faces[f]].W);
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithVertexNormalsAndColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            while (v < _VerticesPerFace) do
            begin
               glColor4f(_Colours[_Faces[f]].X,_Colours[_Faces[f]].Y,_Colours[_Faces[f]].Z,_Colours[_Faces[f]].W);
               glNormal3f(_Normals[_Faces[f]].X,_Normals[_Faces[f]].Y,_Normals[_Faces[f]].Z);
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithFaceNormalsAndVertexColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            glNormal3f(_Normals[i].X,_Normals[i].Y,_Normals[i].Z);
            while (v < _VerticesPerFace) do
            begin
               glColor4f(_Colours[_Faces[f]].X,_Colours[_Faces[f]].Y,_Colours[_Faces[f]].Z,_Colours[_Faces[f]].W);
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithoutNormalsAndWithTexture(const _Vertices: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
var
   i,f,v,tex : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      glNormal3f(0,0,0);
      glColor4f(1,1,1,1);
      i := 0;
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glEnable(GL_TEXTURE_2D);
         end;
      end;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            while (v < _VerticesPerFace) do
            begin
               for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
               begin
                  glMultiTexCoord2f(GL_TEXTURE0 + tex,_TexCoords[_Faces[f]].U,_TexCoords[_Faces[f]].V);
               end;
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glDisable(GL_TEXTURE_2D);
         end;
      end;
   end;
end;

procedure TRenderingMachine.RenderWithVertexNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
var
   i,f,v,tex : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glColor4f(1,1,1,1);
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glEnable(GL_TEXTURE_2D);
         end;
      end;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            while (v < _VerticesPerFace) do
            begin
               for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
               begin
                  glMultiTexCoord2f(GL_TEXTURE0 + tex,_TexCoords[_Faces[f]].U,_TexCoords[_Faces[f]].V);
               end;
               glNormal3f(_Normals[_Faces[f]].X,_Normals[_Faces[f]].Y,_Normals[_Faces[f]].Z);
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glDisable(GL_TEXTURE_2D);
         end;
      end;
   end;
end;

procedure TRenderingMachine.RenderWithFaceNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
var
   i,f,v,tex : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glColor4f(1,1,1,1);
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glEnable(GL_TEXTURE_2D);
         end;
      end;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            glNormal3f(_Normals[i].X,_Normals[i].Y,_Normals[i].Z);
            while (v < _VerticesPerFace) do
            begin
               for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
               begin
                  glMultiTexCoord2f(GL_TEXTURE0 + tex,_TexCoords[_Faces[f]].U,_TexCoords[_Faces[f]].V);
               end;
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glDisable(GL_TEXTURE_2D);
         end;
      end;
   end;
end;

procedure TRenderingMachine.RenderWithoutNormalsAndWithFaceColours(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      glNormal3f(0,0,0);
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            glColor4f(_Colours[i].X,_Colours[i].Y,_Colours[i].Z,_Colours[i].W);
            while (v < _VerticesPerFace) do
            begin
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithVertexNormalsAndFaceColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            glColor4f(_Colours[i].X,_Colours[i].Y,_Colours[i].Z,_Colours[i].W);
            while (v < _VerticesPerFace) do
            begin
               glNormal3f(_Normals[_Faces[f]].X,_Normals[_Faces[f]].Y,_Normals[_Faces[f]].Z);
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.RenderWithFaceNormalsAndColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glBegin(_FaceType);
         while i < _NumFaces do
         begin
            v := 0;
            glColor4f(_Colours[i].X,_Colours[i].Y,_Colours[i].Z,_Colours[i].W);
            glNormal3f(_Normals[i].X,_Normals[i].Y,_Normals[i].Z);
            while (v < _VerticesPerFace) do
            begin
               glVertex3f(_Vertices[_Faces[f]].X,_Vertices[_Faces[f]].Y,_Vertices[_Faces[f]].Z);
               inc(v);
               inc(f);
            end;
            inc(i);
         end;
      glEnd();
   end;
end;

procedure TRenderingMachine.ForceRefresh;
begin
   if List > C_LIST_NONE then
   begin
      glDeleteLists(List,1);
   end;
   List := C_LIST_NONE;
end;


end.
