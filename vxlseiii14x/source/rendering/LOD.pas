unit LOD;

// Level of Detail v1.0

// It should feature the meshes from a model. And a model will have several LODs

interface

uses Mesh, BasicDataTypes, dglOpenGL, SysUtils, Windows, Graphics, Histogram,
   HierarchyAnimation;

{$INCLUDE source/Global_Conditionals.inc}

type
   TLOD = class
   private
      // I/O
      procedure SaveToOBJFile(const _Filename,_TexExt: string);
      procedure SaveToPLYFile(const _Filename: string);
      // Rendering Methods
      procedure RenderMesh(_i :integer; const _HA: PHierarchyAnimation);
      procedure RenderMeshVectorial(_i :integer; const _HA: PHierarchyAnimation);
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
      procedure Render(const _HA: PHierarchyAnimation);
      procedure RenderVectorial(const _HA: PHierarchyAnimation);
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      // Refresh OpenGL List
      procedure RefreshLOD;
      procedure RefreshMesh(_MeshID: integer);
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
   StopWatch, ImageIOUtils, ImageRGBAByteData, ImageRGBAData, ImageRGBByteData,
   ImageGreyData, Abstract2DImageData, ImageRGBData, BasicFunctions, TextureBankItem,
   TextureGeneratorBase;

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
   Ply.SaveToFile(_Filename,Mesh[0].Vertices,Mesh[0].Normals,(Mesh[0].Geometry.Current^ as TMeshBRepGeometry).Faces,(Mesh[0].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace);
   Ply.Free;
end;

// Gets
function TLOD.GetNumMeshes: longword;
begin
   Result := High(Mesh)+1;
end;

// Rendering Methods
procedure TLOD.Render(const _HA: PHierarchyAnimation);
begin
   RenderMesh(InitialMesh, _HA);
end;

procedure TLOD.RenderVectorial(const _HA: PHierarchyAnimation);
begin
   RenderMeshVectorial(InitialMesh, _HA);
end;

procedure TLOD.RenderMesh(_i :integer; const _HA: PHierarchyAnimation);
begin
   if _i <> -1 then
   begin
      glPushMatrix();
         //_HVA^.ApplyMatrix(Mesh[_i].Scale,_i,_Frame);
         _HA^.ExecuteAnimation(_i);
         RenderMesh(Mesh[_i].Son, _HA);
         Mesh[_i].Render();
      glPopMatrix();
      RenderMesh(Mesh[_i].Next, _HA);
   end;
end;

procedure TLOD.RenderMeshVectorial(_i :integer; const _HA: PHierarchyAnimation);
begin
   if _i <> -1 then
   begin
      glPushMatrix();
         //_HVA^.ApplyMatrix(Mesh[_i].Scale,_i,_Frame);
         _HA^.ExecuteAnimation(_i);
         RenderMeshVectorial(Mesh[_i].Son, _HA);
         Mesh[_i].RenderVectorial();
      glPopMatrix();
      RenderMeshVectorial(Mesh[_i].Next, _HA);
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

// Normals

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
//var
//   DiffuseBitmap,HeightmapBitmap: TBitmap;
//   TexGenerator: CTextureGeneratorBase;
begin
//   DiffuseBitmap := Mesh[0].Materials[0].GetTexture(C_TTP_DIFFUSE);
//   HeightmapBitmap := TexGenerator.GenerateHeightMap(DiffuseBitmap);
//   SaveImage(_BaseDir + Mesh[0].Name + '_heightmap.' + _Ext,HeightMapBitmap);
//   if (_previewTextures) then
//   begin
//      RunAProgram(_BaseDir + Mesh[0].Name + '_heightmap.' + _Ext,'','');
//   end;
//   DiffuseBitmap.Free;
//   HeightmapBitmap.Free;
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
