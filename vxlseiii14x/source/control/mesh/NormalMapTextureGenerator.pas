unit NormalMapTextureGenerator;

interface

uses TextureGeneratorBase, BasicDataTypes, Windows, Graphics;

type
   CNormalMapTextureGenerator = class (CTextureGeneratorBase)
      public
         procedure Execute(); override;
   end;

implementation

uses GlobalVars, TriangleFiller, BasicFunctions, Abstract2DImageData, TextureBankItem,
   ImageRGBData, ImageGreyData, MeshBRepGeometry, dglOpenGL, GLConstants;

procedure CNormalMapTextureGenerator.Execute();
var
   i : integer;
   Buffer: TAbstract2DImageData;
   WeightBuffer: TAbstract2DImageData;
   TextureImage : TAbstract2DImageData;
   NormalTexture : PTextureBankItem;
begin
   Buffer := T2DImageRGBData.Create(FSize,FSize);
   WeightBuffer := T2DImageGreyData.Create(FSize,FSize);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      FLOD.Mesh[i].Geometry.GoToFirstElement;
      PaintMeshNormalMapTexture((FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Faces,FLOD.Mesh[i].Normals,FLOD.Mesh[i].TexCoords,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,Buffer,WeightBuffer);
      while FLOD.Mesh[i].Geometry.Current <> nil do
      begin
         (FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).SetNormalMappingShader;
         FLOD.Mesh[i].Geometry.GoToNextElement;
      end;
   end;
   TextureImage := GetPositionedImageDataFromBuffer(Buffer,WeightBuffer);
   Buffer.Free;
   WeightBuffer.Free;
   // Now we generate a texture that will be used by all meshes.
   glActiveTexture(GL_TEXTURE0 + FTextureID);
   NormalTexture := GlobalVars.TextureBank.Add(TextureImage);
   // Now we add this diffuse texture to all meshes.
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      FLOD.Mesh[i].AddTextureToMesh(FMaterialID,C_TTP_NORMAL,C_SHD_PHONG_2TEX,NormalTexture);
   end;
   // Free memory.
   GlobalVars.TextureBank.Delete(NormalTexture^.GetID);
   TextureImage.Free;
end;

end.
