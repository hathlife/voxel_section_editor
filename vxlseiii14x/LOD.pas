unit LOD;

// Level of Detail v1.0

// It should feature the meshes from a model. And a model will have several LODs

interface

uses Mesh, HVA, BasicDataTypes, BasicFunctions, dglOpenGL, GlConstants, ObjFile,
   SysUtils, ClassTextureGenerator, Windows, Graphics, TextureBankItem,
   ClassIntegerSet, ClassStopWatch;

{$INCLUDE Global_Conditionals.inc}
   
type
   TLOD = class
   private
      // I/O
      procedure SaveToOBJFile(const _Filename,_TexExt: string);
      // Rendering Methods
      procedure RenderMesh(_i :integer; var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
   public
      InitialMesh : integer;
      Name : string;
      Mesh : array of TMesh;
      // Constructors and Destructors
      constructor Create; overload;
      constructor Create(const _LOD: TLOD); overload;
      destructor Destroy; override;
      procedure Clear;
      // I/O
      procedure SaveToFile(const _Filename,_TexExt: string);
      // Gets
      function GetNumMeshes: longword;
      // Rendering Methods
      procedure Render(var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      // Refresh OpenGL List
      procedure RefreshLOD;
      procedure RefreshMesh(_MeshID: integer);
      // LOD Effects
      procedure SmoothLOD;
      procedure QuadricSmoothLOD;
      procedure CubicSmoothLOD;
      procedure LanczosSmoothLOD;
      procedure SincSmoothLOD;
      procedure EulerSmoothLOD;
      procedure EulerSquaredSmoothLOD;
      procedure SincInfiniteSmoothLOD;
      procedure GaussianSmoothLOD;
      procedure UnsharpLOD;
      procedure InflateLOD;
      procedure DeflateLOD;
      // Colour Effects
      procedure ColourSmoothLOD;
      procedure ColourCubicSmoothLOD;
      procedure ColourLanczosSmoothLOD;
      procedure ConvertVertexToFaceColours;
      procedure ConvertFaceToVertexColours;
      procedure ConvertFaceToVertexColoursLinear;
      procedure ConvertFaceToVertexColoursCubic;
      procedure ConvertFaceToVertexColoursLanczos;
      // Normals
      procedure RenormalizeLOD;
      procedure ConvertFaceToVertexNormals;
      procedure NormalSmoothLOD;
      procedure NormalLinearSmoothLOD;
      procedure NormalCubicSmoothLOD;
      procedure NormalLanczosSmoothLOD;
      // Textures
      procedure ExtractTextureAtlas; overload;
      procedure ExtractTextureAtlas(_Angle: single); overload;
      procedure GenerateDiffuseTexture(_Size, _MaterialID, _TextureID: integer);
      procedure ExportTextures(const _BaseDir, _Ext : string);
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
      // GUI
      procedure SetSelection(_value: boolean);
      // Copies
      procedure Assign(const _LOD: TLOD);
      // Mesh Optimizations
      procedure RemoveInvisibleFaces;
      procedure OptimizeMeshMaxQuality;
      procedure OptimizeMeshMaxQualityIgnoreColours;
      procedure OptimizeMesh(_QualityLoss: single; _IgnoreColours: boolean);
      procedure ConvertQuadsToTris;

      // Mesh Plugins
      procedure AddNormalsPlugin;
      procedure RemoveNormalsPlugin;
   end;

implementation

uses GlobalVars;

// Constructors and Destructors
constructor TLOD.Create;
begin
   Name := 'Standard Level Of Detail';
   SetLength(Mesh,0);
   InitialMesh := 0;
end;

constructor TLOD.Create(const _LOD: TLOD);
begin
   Assign(_LOD);
end;

destructor TLOD.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TLOD.Clear;
var
   i : integer;
begin
   i := High(Mesh);
   while i >= 0 do
   begin
      Mesh[i].Free;
      dec(i);
   end;
   SetLength(Mesh,0);
end;

// I/O
procedure TLOD.SaveToFile(const _Filename,_TexExt: string);
var
   ext : string;
begin
   ext := Lowercase(ExtractFileExt(_Filename));
   if CompareStr(ext,'.obj') = 0 then
   begin
      SaveToOBJFile(_Filename,_TexExt);
   end;
end;

procedure TLOD.SaveToOBJFile(const _Filename, _TexExt: string);
var
   Obj : TObjFile;
   i : integer;
begin
   Obj := TObjFile.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Obj.AddMesh(Addr(Mesh[i]));
   end;
   Obj.SaveToFile(_Filename,_TexExt);
   Obj.Free;
end;

// Gets
function TLOD.GetNumMeshes: longword;
begin
   Result := High(Mesh)+1;
end;

// Rendering Methods
procedure TLOD.Render(var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
begin
   RenderMesh(InitialMesh,_PolyCount,_VoxelCount,_HVA, _Frame);
end;

procedure TLOD.RenderMesh(_i :integer; var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
begin
   if _i <> -1 then
   begin
      glPushMatrix();
         _HVA^.ApplyMatrix(Mesh[_i].Scale,_i,_Frame);
         RenderMesh(Mesh[_i].Son,_PolyCount,_VoxelCount,_HVA, _Frame);
         Mesh[_i].Render(_PolyCount,_VoxelCount);
      glPopMatrix();
      RenderMesh(Mesh[_i].Next,_PolyCount,_VoxelCount,_HVA, _Frame);
   end;
end;

procedure TLOD.SetNormalsModeRendering;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].SetColoursType(C_COLOURS_DISABLED);
   end;
end;

procedure TLOD.SetColourModeRendering;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceColoursRendering;
   end;
end;



// Refresh OpenGL List
procedure TLOD.RefreshLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceRefresh;
   end;
end;

procedure TLOD.RefreshMesh(_MeshID: integer);
begin
   if _MeshID <= High(Mesh) then
      Mesh[_MeshID].ForceRefresh;
end;

// LOD Effects
procedure TLOD.SmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSmooth;
   end;
end;

procedure TLOD.QuadricSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshQuadricSmooth;
   end;
end;

procedure TLOD.CubicSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshCubicSmooth;
   end;
end;

procedure TLOD.LanczosSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshLanczosSmooth;
   end;
end;

procedure TLOD.SincSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSincSmooth;
   end;
end;

procedure TLOD.EulerSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshEulerSmooth;
   end;
end;

procedure TLOD.EulerSquaredSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshEulerSquaredSmooth;
   end;
end;

procedure TLOD.SincInfiniteSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSincInfiniteSmooth;
   end;
end;

procedure TLOD.GaussianSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshGaussianSmooth;
   end;
end;

procedure TLOD.UnsharpLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshUnsharpMasking;
   end;
end;

procedure TLOD.InflateLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshInflate;
   end;
end;

procedure TLOD.DeflateLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshDeflate;
   end;
end;

// Colour Effects
procedure TLOD.ColourSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ColourSmooth;
   end;
end;

procedure TLOD.ColourCubicSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ColourCubicSmooth;
   end;
end;

procedure TLOD.ColourLanczosSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ColourLanczosSmooth;
   end;
end;

procedure TLOD.ConvertVertexToFaceColours;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertVertexToFaceColours;
   end;
end;

procedure TLOD.ConvertFaceToVertexColours;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertFaceToVertexColours;
   end;
end;

procedure TLOD.ConvertFaceToVertexColoursLinear;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertFaceToVertexColoursLinear;
   end;
end;

procedure TLOD.ConvertFaceToVertexColoursCubic;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertFaceToVertexColoursCubic;
   end;
end;

procedure TLOD.ConvertFaceToVertexColoursLanczos;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertFaceToVertexColoursLanczos;
   end;
end;


// Normals
procedure TLOD.ReNormalizeLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ReNormalizeMesh;
   end;
end;

procedure TLOD.ConvertFaceToVertexNormals;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertFaceToVertexNormals;
   end;
end;

procedure TLOD.NormalSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].NormalSmooth;
   end;
end;

procedure TLOD.NormalLinearSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].NormalLinearSmooth;
   end;
end;

procedure TLOD.NormalCubicSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].NormalCubicSmooth;
   end;
end;

procedure TLOD.NormalLanczosSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].NormalLanczosSmooth;
   end;
end;

// Textures
procedure TLOD.ExtractTextureAtlas;
begin
   ExtractTextureAtlas(C_TEX_MIN_ANGLE);
end;

procedure TLOD.ExtractTextureAtlas(_Angle: single);
var
   i : integer;
   Seeds: TSeedSet;
   VertsSeed : TInt32Map;
   TexGenerator: CTextureGenerator;
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Bitmap : TBitmap;
   AlphaMap : TByteMap;
   DiffuseTexture : PTextureBankItem;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
// Here's the old code
{
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].GenerateDiffuseTexture;
   end;
}
// Now, the new code.
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   // First, we'll build the texture atlas.
   SetLength(VertsSeed,High(Mesh)+1);
   SetLength(Seeds,0);
   TexGenerator := CTextureGenerator.Create(_Angle);
   for i := Low(Mesh) to High(Mesh) do
   begin
      SetLength(VertsSeed[i],0);
      Mesh[i].GetMeshSeeds(i,Seeds,VertsSeed[i],TexGenerator);
   end;
   TexGenerator.MergeSeeds(Seeds);
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].GetFinalTextureCoordinates(Seeds,VertsSeed[i],TexGenerator);
   end;
   // Now we build the diffuse texture.
   GenerateDiffuseTexture(1024,0,0);
   // Free memory.
   for i := Low(Mesh) to High(Mesh) do
   begin
      SetLength(VertsSeed[i],0);
   end;
   SetLength(VertsSeed,0);
   TexGenerator.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Texture atlas and diffuse texture extraction for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TLOD.GenerateDiffuseTexture(_Size, _MaterialID, _TextureID: integer);
var
   i : integer;
   TexGenerator: CTextureGenerator;
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Bitmap : TBitmap;
   AlphaMap : TByteMap;
   DiffuseTexture : PTextureBankItem;
begin
   TexGenerator.SetupFrameBuffer(Buffer,WeightBuffer,_Size);
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].PaintMeshDiffuseTexture(Buffer,WeightBuffer,TexGenerator);
   end;
   Bitmap := TexGenerator.GetColouredBitmapFromFrameBuffer(Buffer,WeightBuffer,AlphaMap);
   TexGenerator.DisposeFrameBuffer(Buffer,WeightBuffer);
   // Now we generate a texture that will be used by all meshes.
   glActiveTextureARB(GL_TEXTURE0_ARB + _TextureID);
   DiffuseTexture := GlobalVars.TextureBank.Add(Bitmap,AlphaMap);
   // Now we add this diffuse texture to all meshes.
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].AddTextureToMesh(_MaterialID,C_TTP_DIFFUSE,C_SHD_PHONG_1TEX,DiffuseTexture);
   end;
   // Free memory.
   GlobalVars.TextureBank.Delete(DiffuseTexture^.GetID);
   for i := Low(AlphaMap) to High(AlphaMap) do
   begin
      SetLength(AlphaMap[i],0);
   end;
   SetLength(AlphaMap,0);
   Bitmap.Free;
end;

procedure TLOD.ExportTextures(const _BaseDir, _Ext : string);
var
   i : integer;
   UsedTextures : CIntegerSet;
begin
   UsedTextures := CIntegerSet.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ExportTextures(_BaseDir,_Ext,UsedTextures);
   end;
   UsedTextures.Free;
end;

// Transparency methods
procedure TLOD.ForceTransparency(_level: single);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceTransparencyLevel(_Level);
   end;
end;

procedure TLOD.ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
begin
   if _MeshID <= High(Mesh) then
      Mesh[_MeshID].ForceTransparencyLevel(_Level);
end;

procedure TLOD.ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      if i <> _MeshID then
         Mesh[i].ForceTransparencyLevel(_Level)
      else
         Mesh[i].ForceTransparencyLevel(C_TRP_OPAQUE);
   end;
end;

// GUI
procedure TLOD.SetSelection(_value: boolean);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].IsSelected := _value;
   end;
end;

// Copies
procedure TLOD.Assign(const _LOD: TLOD);
var
   i : integer;
begin
   Name := CopyString(_LOD.Name);
   SetLength(Mesh,_LOD.GetNumMeshes);
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i] := TMesh.Create(_LOD.Mesh[i]);
   end;
end;

// Mesh Optimizations
procedure TLOD.RemoveInvisibleFaces;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].RemoveInvisibleFaces;
   end;
end;

procedure TLOD.OptimizeMeshMaxQuality;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].OptimizeMeshLossLess;
   end;
end;

procedure TLOD.OptimizeMeshMaxQualityIgnoreColours;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].OptimizeMeshLossLessIgnoreColours;
   end;
end;

procedure TLOD.OptimizeMesh(_QualityLoss: single; _IgnoreColours: boolean);
var
   i : integer;
begin
   if _IgnoreColours then
   begin
      for i := Low(Mesh) to High(Mesh) do
      begin
         Mesh[i].MeshOptimizationIgnoreColours(_QualityLoss);
      end;
   end
   else
   begin
      for i := Low(Mesh) to High(Mesh) do
      begin
         Mesh[i].MeshOptimization(false,_QualityLoss);
      end;
   end;
end;


procedure TLOD.ConvertQuadsToTris;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertQuadsToTris;
   end;
end;

// Mesh Plugins
procedure TLOD.AddNormalsPlugin;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].AddNormalsPlugin;
   end;
end;

procedure TLOD.RemoveNormalsPlugin;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].RemoveNormalsPlugin;
   end;
end;


end.
