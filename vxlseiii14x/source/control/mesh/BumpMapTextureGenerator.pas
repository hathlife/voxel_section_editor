unit BumpMapTextureGenerator;

interface

uses TextureGeneratorBase, dglOpenGL, BasicDataTypes, Windows, Graphics, LOD;

type
   CBumpMapTextureGenerator = class (CTextureGeneratorBase)
      protected
         FScale: single;
      public
         constructor Create(var _LOD: TLOD); overload; override;
         constructor Create(var _LOD: TLOD; _Size, _MaterialID, _TextureID: integer); overload; override;
         constructor Create(var _LOD: TLOD; _Size, _MaterialID, _TextureID: integer; _Scale: single); overload;
         procedure Execute(); override;
   end;

implementation

uses GlobalVars, TriangleFiller, BasicFunctions, Abstract2DImageData, TextureBankItem,
   ImageRGBAByteData, ImageGreyData, MeshBRepGeometry, GLConstants;

constructor CBumpMapTextureGenerator.Create(var _LOD: TLOD; _Size, _MaterialID, _TextureID: integer; _Scale: single);
begin
   FScale := _Scale;
   FLOD := _LOD;
   FSize := _Size;
   FMaterialID := _MaterialID;
   FTextureID := _TextureID;
   Initialize;
end;

constructor CBumpMapTextureGenerator.Create(var _LOD: TLOD; _Size, _MaterialID, _TextureID: integer);
begin
   FScale := C_BUMP_DEFAULTSCALE;
   inherited Create(_LOD, _Size, _MaterialID, _TextureID);
end;

constructor CBumpMapTextureGenerator.Create(var _LOD: TLOD);
begin
   FScale := C_BUMP_DEFAULTSCALE;
   inherited Create(_LOD);
end;

procedure CBumpMapTextureGenerator.Execute();
var
   i : integer;
   DiffuseMap: TAbstract2DImageData;
   BumpMap : TAbstract2DImageData;
   NormalTexture : PTextureBankItem;
begin
   DiffuseMap := T2DImageRGBAByteData.Create(0,0);
   FLOD.Mesh[0].Materials[0].GetTextureData(C_TTP_DIFFUSE,DiffuseMap);
   BumpMap := GetBumpMapTexture(DiffuseMap,FScale);
   // Now we generate a texture that will be used by all meshes.
   glActiveTexture(GL_TEXTURE0 + FTextureID);
   NormalTexture := GlobalVars.TextureBank.Add(BumpMap);
   // Now we add this diffuse texture to all meshes.
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      FLOD.Mesh[i].AddTextureToMesh(FMaterialID,C_TTP_DOT3BUMP,C_SHD_PHONG_DOT3TEX,NormalTexture);
   end;
   // Free memory.
   GlobalVars.TextureBank.Delete(NormalTexture^.GetID);
   DiffuseMap.Free;
   BumpMap.Free;
end;

end.
