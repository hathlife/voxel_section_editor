unit LOD;

// Level of Detail v1.0

// It should feature the meshes from a model. And a model will have several LODs

interface

uses Mesh, HVA, BasicDataTypes, dglOpenGL, SysUtils, Windows, Graphics, Histogram;

{$INCLUDE source/Global_Conditionals.inc}

type
   TLOD = class
   private
      // I/O
      procedure SaveToOBJFile(const _Filename,_TexExt: string);
      procedure SaveToPLYFile(const _Filename: string);
      // Rendering Methods
      procedure RenderMesh(_i :integer; var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
      procedure RenderMeshVectorial(_i :integer; const _HVA: PHVA; _Frame: integer);
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
      procedure RenderVectorial(const _HVA: PHVA; _Frame: integer);
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
      procedure SmoothLOD2;
      procedure QuadricSmoothLOD2;
      procedure CubicSmoothLOD2;
      procedure LanczosSmoothLOD2;
      procedure SincSmoothLOD2;
      procedure EulerSmoothLOD2;
      procedure EulerSquaredSmoothLOD2;
      procedure SincInfiniteSmoothLOD2;
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
      procedure ExportTextures(const _BaseDir, _Ext : string; _previewTextures: boolean);
      procedure ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
      procedure SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
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
      procedure ConvertQuadsTo48Tris;
      // Quality Assurance
      function GetAspectRatioHistogram(): THistogram;
      function GetSkewnessHistogram(): THistogram;
      function GetSmoothnessHistogram(): THistogram;
      procedure FillAspectRatioHistogram(var _Histogram: THistogram);
      procedure FillSkewnessHistogram(var _Histogram: THistogram);
      procedure FillSmoothnessHistogram(var _Histogram: THistogram);
      // Mesh Plugins
      procedure AddNormalsPlugin;
      procedure RemoveNormalsPlugin;
   end;

implementation

uses GlobalVars, PLYFile, MeshBRepGeometry, GlConstants, ObjFile, IntegerSet,
   StopWatch, ImageIOUtils, ImageRGBAByteData, ImageRGBAData, ImageRGBByteData, ImageGreyData, Abstract2DImageData,
   ImageRGBData, BasicFunctions, TextureBankItem;

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
   end
   else if CompareStr(ext,'.ply') = 0 then
   begin
      SaveToPLYFile(_Filename);
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

procedure TLOD.SaveToPLYFile(const _Filename: string);
var
   Ply : CPLYFile;
begin
   Ply := CPLYFile.Create;
   Mesh[0].Geometry.GoToFirstElement;
   if High(Mesh[0].Normals) < 0 then
   begin
      Mesh[0].TransformFaceToVertexNormals;
   end;
   Ply.SaveToFile(_Filename,Mesh[0].Vertices,Mesh[0].Normals,(Mesh[0].Geometry.Current^ as TMeshBRepGeometry).Faces,(Mesh[0].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace);
   Ply.Free;
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

procedure TLOD.RenderVectorial(const _HVA: PHVA; _Frame: integer);
begin
   RenderMeshVectorial(InitialMesh,_HVA, _Frame);
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

procedure TLOD.RenderMeshVectorial(_i :integer; const _HVA: PHVA; _Frame: integer);
begin
   if _i <> -1 then
   begin
      glPushMatrix();
         _HVA^.ApplyMatrix(Mesh[_i].Scale,_i,_Frame);
         RenderMeshVectorial(Mesh[_i].Son,_HVA, _Frame);
         Mesh[_i].RenderVectorial();
      glPopMatrix();
      RenderMeshVectorial(Mesh[_i].Next,_HVA, _Frame);
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

procedure TLOD.SmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSmooth2;
   end;
end;

procedure TLOD.QuadricSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshQuadricSmooth2;
   end;
end;

procedure TLOD.CubicSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshCubicSmooth2;
   end;
end;

procedure TLOD.LanczosSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshLanczosSmooth2;
   end;
end;

procedure TLOD.SincSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSincSmooth2;
   end;
end;

procedure TLOD.EulerSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshEulerSmooth2;
   end;
end;

procedure TLOD.EulerSquaredSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshEulerSquaredSmooth2;
   end;
end;

procedure TLOD.SincInfiniteSmoothLOD2;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSincInfiniteSmooth2;
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
      Mesh[i].SetVertexNormals;
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
procedure TLOD.ExportTextures(const _BaseDir, _Ext : string; _previewTextures: boolean);
var
   i : integer;
   UsedTextures : CIntegerSet;
begin
   UsedTextures := CIntegerSet.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ExportTextures(_BaseDir,_Ext,UsedTextures,_previewTextures);
   end;
   UsedTextures.Free;
end;

procedure TLOD.ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
var
   DiffuseBitmap,HeightmapBitmap: TBitmap;
//   TexGenerator: CTextureGenerator;
begin
   DiffuseBitmap := Mesh[0].Materials[0].GetTexture(C_TTP_DIFFUSE);
//   TexGenerator := CTextureGenerator.Create;
//   HeightmapBitmap := TexGenerator.GenerateHeightMap(DiffuseBitmap);
   SaveImage(_BaseDir + Mesh[0].Name + '_heightmap.' + _Ext,HeightMapBitmap);
   if (_previewTextures) then
   begin
      RunAProgram(_BaseDir + Mesh[0].Name + '_heightmap.' + _Ext,'','');
   end;
//   TexGenerator.Free;
   DiffuseBitmap.Free;
   HeightmapBitmap.Free;
end;


procedure TLOD.SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].SetTextureNumMipMaps(_NumMipMaps,_TextureType);
   end;
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

procedure TLOD.ConvertQuadsTo48Tris;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertQuadsTo48Tris;
   end;
end;

// Quality Assurance
function TLOD.GetAspectRatioHistogram(): THistogram;
var
   i : integer;
begin
   Result := THistogram.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].FillAspectRatioHistogram(Result);
   end;
end;

function TLOD.GetSkewnessHistogram(): THistogram;
var
   i : integer;
begin
   Result := THistogram.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].FillSkewnessHistogram(Result);
   end;
end;

function TLOD.GetSmoothnessHistogram(): THistogram;
var
   i : integer;
begin
   Result := THistogram.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].FillSmoothnessHistogram(Result);
   end;
end;

procedure TLOD.FillAspectRatioHistogram(var _Histogram: THistogram);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].FillAspectRatioHistogram(_Histogram);
   end;
end;

procedure TLOD.FillSkewnessHistogram(var _Histogram: THistogram);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].FillSkewnessHistogram(_Histogram);
   end;
end;

procedure TLOD.FillSmoothnessHistogram(var _Histogram: THistogram);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].FillSmoothnessHistogram(_Histogram);
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
      Mesh[i].RemovePlugin(C_MPL_NORMALS);
   end;
end;


end.
