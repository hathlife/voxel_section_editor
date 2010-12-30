unit Material;

interface

uses dglOpenGL, BasicDataTypes, TextureBank, TextureBankItem, ShaderBank, ShaderBankItem,
   BasicFunctions, GlConstants, ClassIntegerSet, SysUtils, Windows, Graphics,
   Dialogs;

type
   TMeshMaterial = class
      private
         procedure ClearTextures;
      public
         Ambient: TVector4f;
         Diffuse: TVector4f;
         Specular: TVector4f;
         Shininess: Single;
         Emission: TVector4f;
         Shader: PShaderBankItem;
         SrcAlphaBlend, DstAlphaBlend: GLINT;
         Texture: array of PTextureBankItem;
         // Constructors & Destructors
         constructor Create(_ShaderBank: PShaderBank);
         destructor Destroy; override;
         // Gets
         function GetTexture(_Type: integer):TBitmap;
         function GetTextureID(_Type: integer):integer;
         function GetLastTextureID: integer;
         function GetNextTextureID: integer;
         function GetTextureSize(_TextureID: integer): integer;
         // Sets
         // Render
         procedure Enable;
         procedure Disable;
         // Adds
         procedure AddTexture(_TextureType: integer; const _Texture:PTextureBankItem);
         // Copies
         procedure Assign(const _MeshMaterial: TMeshMaterial);
         // Misc
         procedure ExportTextures(const _BaseDir, _Name, _Ext : string; var _UsedTextures : CIntegerSet);
   end;
   PMeshMaterial = ^TMeshMaterial;
   TAMeshMaterial = array of TMeshMaterial;

implementation

uses GlobalVars;

// Constructors & Destructors
constructor TMeshMaterial.Create(_ShaderBank: PShaderBank);
begin
   SetLength(Texture,0);
   Ambient := SetVector4f(0.2,0.2,0.2,0.0);
   Diffuse := SetVector4f(0.8,0.8,0.8,1.0);
   Shininess := 0;
   Specular := SetVector4f(0,0,0,1);
   Emission := SetVector4f(0,0,0,1);
   SrcAlphaBlend := GL_SRC_ALPHA;
   DstAlphaBlend := GL_ONE_MINUS_SRC_ALPHA;
   if _ShaderBank <> nil then
      Shader := _ShaderBank^.Get(C_SHD_PHONG)
   else
      Shader := nil;
end;

destructor TMeshMaterial.Destroy;
begin
   ClearTextures;
   Shader := nil;
   inherited Destroy;
end;

// Gets
function TMeshMaterial.GetTexture(_Type: integer):TBitmap;
var
   tex: integer;
begin
   for tex := Low(Texture) to High(Texture) do
   begin
      if Texture[tex] <> nil then
      begin
         if Texture[tex].TextureType = _Type then
         begin
            glActiveTextureARB(GL_TEXTURE0_ARB + tex);
            Result := Texture[tex]^.DownloadTexture(0);
         end;
      end;
   end;
end;

function TMeshMaterial.GetTextureID(_Type: integer):integer;
var
   tex: integer;
begin
   Result := -1;
   for tex := Low(Texture) to High(Texture) do
   begin
      if Texture[tex] <> nil then
      begin
         if Texture[tex].TextureType = _Type then
         begin
            Result := tex;
            exit;
         end;
      end;
   end;
end;

function TMeshMaterial.GetLastTextureID: integer;
begin
   Result := High(Texture);
end;

function TMeshMaterial.GetNextTextureID: integer;
begin
   Result := High(Texture)+1;
end;

function TMeshMaterial.GetTextureSize(_TextureID: integer): integer;
begin
   if (_TextureID >= 0) and (_TextureID <= High(Texture)) then
   begin
      Result := Texture[_TextureID]^.Size;
   end
   else
   begin
      Result := 0;
   end;

end;

procedure TMeshMaterial.ClearTextures;
var
   i: integer;
begin
   for i := Low(Texture) to High(Texture) do
   begin
      if Texture[i] <> nil then
      begin
         GlobalVars.TextureBank.Delete(Texture[i]^.GetID);
         Texture[i] := nil;
      end;
   end;
   SetLength(Texture,0);
end;

// Sets

// Render
procedure TMeshMaterial.Enable;
begin
   glEnable(GL_BLEND);
   glBlendFunc(SrcAlphaBlend, DstAlphaBlend);
   glEnable(GL_COLOR_MATERIAL);
   glEnable(GL_LIGHTING);
   glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
   glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,PGLFloat(@(Ambient)));
   glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,PGLFloat(@(Diffuse)));
   glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,PGLFloat(@(Specular)));
   glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION,PGLFloat(@(Emission)));
   glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,Shininess);
   if Shader <> nil then
   begin
      Shader^.UseProgram;
   end;
end;

procedure TMeshMaterial.Disable;
begin
   if Shader <> nil then
   begin
      Shader^.DeactivateProgram;
   end;
   glDisable(GL_LIGHTING);
   glDisable(GL_COLOR_MATERIAL);
   glDisable(GL_BLEND);
end;

// Adds
procedure TMeshMaterial.AddTexture(_TextureType: integer; const _Texture:PTextureBankItem);
begin
   SetLength(Texture,High(Texture)+2);
   Texture[High(Texture)] := GlobalVars.TextureBank.Add(_Texture^.GetID);
   Texture[High(Texture)]^.TextureType := _TextureType;
end;

// Copies
procedure TMeshMaterial.Assign(const _MeshMaterial: TMeshMaterial);
var
   i : integer;
begin
   ClearTextures;
   SetLength(Texture,High(_MeshMaterial.Texture)+1);
   for i := Low(Texture) to High(Texture) do
   begin
      if _MeshMaterial.Texture[i] <> nil then
      begin
         Texture[i] := GlobalVars.TextureBank.Clone(_MeshMaterial.Texture[i]^.GetID);
      end
      else
      begin
         Texture[i] := nil;
      end;
   end;
   Ambient := SetVector4f(_MeshMaterial.Ambient.X,_MeshMaterial.Ambient.Y,_MeshMaterial.Ambient.Z,_MeshMaterial.Ambient.W);
   Diffuse := SetVector4f(_MeshMaterial.Diffuse.X,_MeshMaterial.Diffuse.Y,_MeshMaterial.Diffuse.Z,_MeshMaterial.Diffuse.W);
   Shininess := _MeshMaterial.Shininess;
   Specular := SetVector4f(_MeshMaterial.Specular.X,_MeshMaterial.Specular.Y,_MeshMaterial.Specular.Z,_MeshMaterial.Specular.W);
   Emission := SetVector4f(_MeshMaterial.Emission.X,_MeshMaterial.Emission.Y,_MeshMaterial.Emission.Z,_MeshMaterial.Emission.W);
   Shader := _MeshMaterial.Shader;
end;

// Misc
procedure TMeshMaterial.ExportTextures(const _BaseDir, _Name, _Ext : string; var _UsedTextures : CIntegerSet);
var
   tex: integer;
begin
   for tex := Low(Texture) to High(Texture) do
   begin
      if Texture[tex] <> nil then
      begin
         if _UsedTextures.Add(Texture[tex]^.GetID) then
         begin
            glActiveTextureARB(GL_TEXTURE0_ARB + tex);
//            Texture[tex]^.SaveTexture(_BaseDir + Name + '_' + IntToStr(ID) + '_' + IntToStr(mat) + '_' +  IntToStr(tex) + '.' + _Ext);
            Texture[tex]^.SaveTexture(_BaseDir + _Name + '_' + IntToStr(tex) + '.' + _Ext);
         end;
      end;
   end;
end;


end.
