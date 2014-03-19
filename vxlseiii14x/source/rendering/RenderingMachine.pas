unit RenderingMachine;

interface

uses BasicMathsTypes, BasicDataTypes, BasicConstants, BasicFunctions, DglOpenGL, GlConstants,
   Material, ShaderBank, ShaderBankItem, MeshPluginBase, BumpMapDataPlugin;

type
   TRenderingMachine = class
      public
         List : integer;
         IsGeneratingList: boolean;
         RenderingProcedure: integer;
         // SetShaderAttributes procedure for rendering bump maps
         SetShaderAttributes : TSetShaderAttributesFunc;
         SetShaderUniform : TSetShaderUniformFunc;
         // constructors and destructors.
         constructor Create; overload;
         constructor Create(const _Source: TRenderingMachine); overload;
         destructor Destroy; override;
         // Render basics
         procedure StartRender();
         procedure StartRenderVectorial();
         procedure DoRender(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _BumpPlugin: PMeshPluginBase; const _ShaderBank: PShaderBank; const _NumFaces,_CurrentPass: integer);
         procedure FinishRender(const _TranslatePosition: TVector3f); overload;
         procedure FinishRender(); overload;
         procedure FinishRenderVectorial();
         procedure CallList();
         procedure ForceRefresh;
         // Rendering modes
         procedure RenderWithoutNormalsAndColours(const _Vertices: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithVertexNormalsAndNoColours(const _Vertices, _Normals: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithFaceNormalsAndNoColours(const _Vertices, _Normals: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithoutNormalsAndWithColoursPerVertex(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithVertexNormalsAndColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithFaceNormalsAndVertexColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithoutNormalsAndWithTexture(const _Vertices: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
         procedure RenderWithVertexNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _BumpPlugin: PMeshPluginBase; const _ShaderBank: PShaderBank; const _NumFaces,_CurrentPass: integer);
         procedure RenderWithFaceNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces,_CurrentPass: integer);
         procedure RenderWithoutNormalsAndWithFaceColours(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithVertexNormalsAndFaceColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         procedure RenderWithFaceNormalsAndColours(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
         // Shaders
         procedure SetUniformShaderDoNothing(const _Materials: TAMeshMaterial; _MaterialID,_TextureID: integer);
         procedure SetUniformShaderBumpMapping(const _Materials: TAMeshMaterial; _MaterialID,_TextureID: integer);
         procedure SetAtributeShaderDoNothing(const _ShaderBank: PShaderBank; _VertexID: integer; const _PPlugin: PMeshPluginBase);
         procedure SetAtributeShaderBumpMapping(const _ShaderBank: PShaderBank; _VertexID: integer; const _PPlugin: PMeshPluginBase);
         // Sets
         procedure SetDiffuseMappingShader;
         procedure SetNormalMappingShader;
         procedure SetBumpMappingShader;
         // Miscellaneous
         procedure SetRenderingProcedure(_NormalsType, _ColoursType: integer);
         // Copy
         procedure Assign(const _Source: TRenderingMachine);
   end;

implementation

// constructors and destructors.
constructor TRenderingMachine.Create;
begin
   List := C_LIST_NONE;
   RenderingProcedure := -1;
   SetDiffuseMappingShader;
end;

constructor TRenderingMachine.Create(const _Source: TRenderingMachine);
begin
   Assign(_Source);
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

procedure TRenderingMachine.StartRenderVectorial();
begin
   isGeneratingList := true;
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

procedure TRenderingMachine.FinishRender;
begin
   if IsGeneratingList then
   begin
      glEndList;
   end;
   isGeneratingList := false;
end;

procedure TRenderingMachine.FinishRenderVectorial;
begin
   isGeneratingList := false;
end;

procedure TRenderingMachine.CallList;
begin
   glCallList(List);
end;

procedure TRenderingMachine.RenderWithoutNormalsAndColours(const _Vertices: TAVector3f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glColor4f(1,1,1,C_TRP_OPAQUE);
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
      glActiveTexture(GL_TEXTURE0);
   end;
end;

procedure TRenderingMachine.RenderWithVertexNormalsAndWithTexture(const _Vertices,_Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _BumpPlugin: PMeshPluginBase; const _ShaderBank: PShaderBank; const _NumFaces,_CurrentPass: integer);
var
   i,f,v,tex : longword;
begin
   if IsGeneratingList then
   begin
      f := 0;
      i := 0;
      glColor4f(1,1,1,C_TRP_OPAQUE);
      for tex := Low(_Materials[_CurrentPass].Texture) to High(_Materials[_CurrentPass].Texture) do
      begin
         if _Materials[_CurrentPass].Texture[tex] <> nil then
         begin
            glActiveTexture(GL_TEXTURE0 + tex);
            glBindTexture(GL_TEXTURE_2D,_Materials[_CurrentPass].Texture[tex]^.GetID);
            glEnable(GL_TEXTURE_2D);
            SetShaderUniform(_Materials,_CurrentPass,tex);
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
               SetShaderAttributes(_ShaderBank,_Faces[f],_BumpPlugin);
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
      glActiveTexture(GL_TEXTURE0);
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
      glColor4f(1,1,1,C_TRP_OPAQUE);
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
      glActiveTexture(GL_TEXTURE0);
   end;
end;

procedure TRenderingMachine.RenderWithoutNormalsAndWithFaceColours(const _Vertices: TAVector3f; const _Colours: TAVector4f; const _Faces: auint32; const _FaceType: GLInt; const _VerticesPerFace: byte; const _NumFaces: integer);
var
   i,f,v : longword;
begin
   if IsGeneratingList then
   begin
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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
      glActiveTexture(GL_TEXTURE0);
      glDisable(GL_TEXTURE_2D);
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

// Shader related.
procedure TRenderingMachine.SetUniformShaderDoNothing(const _Materials: TAMeshMaterial; _MaterialID,_TextureID: integer);
begin
   // do nothing, really... it does nothing!
end;

procedure TRenderingMachine.SetUniformShaderBumpMapping(const _Materials: TAMeshMaterial; _MaterialID,_TextureID: integer);
var
   Shader: PShaderBankItem;
begin
   // sends texture to shader.
   Shader := _Materials[_MaterialID].Shader;
   Shader^.glSendUniform1i(_TextureID,_TextureID);
end;

procedure TRenderingMachine.SetAtributeShaderDoNothing(const _ShaderBank: PShaderBank; _VertexID: integer; const _PPlugin: PMeshPluginBase);
begin
   // do nothing, really... it does nothing!
end;

procedure TRenderingMachine.SetAtributeShaderBumpMapping(const _ShaderBank: PShaderBank; _VertexID: integer; const _PPlugin: PMeshPluginBase);
var
   Shader: PShaderBankItem;
begin
   // sends tangent and bitangent attributes in this exact order.
   Shader := _ShaderBank^.Get(C_SHD_PHONG_DOT3TEX);
   Shader^.glSendAttribute3f(0,TBumpMapDataPlugin(_PPlugin^).Tangents[_VertexID]);
   Shader^.glSendAttribute3f(1,TBumpMapDataPlugin(_PPlugin^).BiTangents[_VertexID]);
end;

// Sets
procedure TRenderingMachine.SetDiffuseMappingShader;
begin
   SetShaderAttributes := SetAtributeShaderDoNothing;
   SetShaderUniform := SetUniformShaderDoNothing;
end;

procedure TRenderingMachine.SetNormalMappingShader;
begin
   SetShaderAttributes := SetAtributeShaderDoNothing;
   SetShaderUniform := SetUniformShaderBumpMapping;
end;

procedure TRenderingMachine.SetBumpMappingShader;
begin
   SetShaderAttributes := SetAtributeShaderBumpMapping;
   SetShaderUniform := SetUniformShaderBumpMapping;
end;

// Rendering procedure.
procedure TRenderingMachine.SetRenderingProcedure(_NormalsType, _ColoursType: integer);
begin
   case (_NormalsType) of
      C_NORMALS_DISABLED:
      begin
         case (_ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := 0;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := 1;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := 2;
            end;
            C_COLOURS_FROM_TEXTURE:
            begin
               RenderingProcedure := 3;
            end;
         end;
      end;
      C_NORMALS_PER_VERTEX:
      begin
         case (_ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := 4;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := 5;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := 6;
            end;
            C_COLOURS_FROM_TEXTURE:
            begin
               RenderingProcedure := 7;
            end;
         end;
      end;
      C_NORMALS_PER_FACE:
      begin
         case (_ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := 8;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := 9;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := 10;
            end;
            C_COLOURS_FROM_TEXTURE:
            begin
               RenderingProcedure := 11;
            end;
         end;
      end;
   end;
   ForceRefresh;
end;

procedure TRenderingMachine.DoRender(const _Vertices, _Normals: TAVector3f; const _Colours: TAVector4f; const _TexCoords: TAVector2f; const _Faces: auint32; const _Materials : TAMeshMaterial; const _FaceType: GLInt; const _VerticesPerFace: byte; const _BumpPlugin: PMeshPluginBase; const _ShaderBank: PShaderBank; const _NumFaces,_CurrentPass: integer);
begin
   case (RenderingProcedure) of
      0:
      begin
         RenderWithoutNormalsAndColours(_Vertices,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      1:
      begin
         RenderWithoutNormalsAndWithColoursPerVertex(_Vertices,_Colours,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      2:
      begin
         RenderWithoutNormalsAndWithFaceColours(_Vertices,_Colours,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      3:
      begin
         RenderWithoutNormalsAndWithTexture(_Vertices,_TexCoords,_Faces,_Materials,_FaceType,_VerticesPerFace,_NumFaces,_CurrentPass);
      end;
      4:
      begin
         RenderWithVertexNormalsAndNoColours(_Vertices,_Normals,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      5:
      begin
         RenderWithVertexNormalsAndColours(_Vertices,_Normals,_Colours,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      6:
      begin
         RenderWithVertexNormalsAndFaceColours(_Vertices,_Normals,_Colours,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      7:
      begin
         RenderWithVertexNormalsAndWithTexture(_Vertices,_Normals,_TexCoords,_Faces,_Materials,_FaceType,_VerticesPerFace,_BumpPlugin,_ShaderBank,_NumFaces,_CurrentPass);
      end;
      8:
      begin
         RenderWithFaceNormalsAndNoColours(_Vertices,_Normals,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      9:
      begin
         RenderWithFaceNormalsAndVertexColours(_Vertices,_Normals,_Colours,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      10:
      begin
         RenderWithFaceNormalsAndColours(_Vertices,_Normals,_Colours,_Faces,_FaceType,_VerticesPerFace,_NumFaces);
      end;
      11:
      begin
         RenderWithFaceNormalsAndWithTexture(_Vertices,_Normals,_TexCoords,_Faces,_Materials,_FaceType,_VerticesPerFace,_NumFaces,_CurrentPass);
      end
      else
      begin
         // does not render.
      end;
   end;
end;

// Copy
// Important: You'll need to set the shader manually and the GL list is not copied.
procedure TRenderingMachine.Assign(const _Source: TRenderingMachine);
begin
   IsGeneratingList := false;
   List := C_LIST_NONE;
   SetDiffuseMappingShader;
   RenderingProcedure := _Source.RenderingProcedure;
end;

end.
