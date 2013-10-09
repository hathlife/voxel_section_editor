unit Model;

interface

uses Palette, HVA, Voxel, Mesh, BasicFunctions, BasicDataTypes, dglOpenGL, LOD,
   SysUtils, Graphics, GlConstants, ShaderBank, Histogram;

type
   TVoxelCreationStruct = record
      Mesh: PMesh;
      i : integer;
      Section : TVoxelSection;
      Palette: TPalette;
      ShaderBank: PShaderBank;
      Quality: integer;
   end;
   PVoxelCreationStruct = ^TVoxelCreationStruct;


   PModel = ^TModel;
   TModel = class
   private
      Opened : boolean;
      // I/O
      procedure OpenVoxel;
      procedure OpenVoxelSection(const _VoxelSection: PVoxelSection);
   public
      Palette : PPalette;
      IsVisible : boolean;
      // Skeleton:
      HVA : PHVA;
      LOD : array of TLOD;
      CurrentLOD : integer;
      // Source
      Filename : string;
      Voxel : PVoxel;
      VoxelSection : PVoxelSection;
      Quality: integer;
      // GUI
      IsSelected : boolean;
      // Others
      ShaderBank : PShaderBank;
      // constructors and destructors
      constructor Create(const _Filename: string; _ShaderBank : PShaderBank); overload;
      constructor Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _ShaderBank : PShaderBank; _Quality : integer); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; const _HVA: PHVA; _ShaderBank : PShaderBank; _Quality : integer); overload;
      constructor Create(const _Model: TModel); overload;
      destructor Destroy; override;
      procedure CommonCreationProcedures;
      procedure Initialize(_HighQuality: boolean = false);
      procedure ClearLODs;
      procedure Clear;
      procedure Reset;
      // I/O
      procedure RebuildModel;
      procedure RebuildLOD(i: integer);
      procedure RebuildCurrentLOD;
      procedure SaveLODToFile(const _Filename, _TexExt: string);
      // Gets
      function GetNumLODs: longword;
      function IsOpened : boolean;
      // Sets
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      procedure SetQuality(_value: integer);
      // Rendering methods
      procedure Render(var _PolyCount,_VoxelCount: longword; _Frame: integer);
      procedure RenderVectorial(_Frame: integer);
      // Refresh OpenGL List
      procedure RefreshModel;
      procedure RefreshMesh(_MeshID: integer);
      // Model Effects
      procedure SmoothModel;
      procedure QuadricSmoothModel;
      procedure CubicSmoothModel;
      procedure LanczosSmoothModel;
      procedure SincSmoothModel;
      procedure EulerSmoothModel;
      procedure EulerSquaredSmoothModel;
      procedure SincInfiniteSmoothModel;
      procedure SmoothModel2;
      procedure QuadricSmoothModel2;
      procedure CubicSmoothModel2;
      procedure LanczosSmoothModel2;
      procedure SincSmoothModel2;
      procedure EulerSmoothModel2;
      procedure EulerSquaredSmoothModel2;
      procedure SincInfiniteSmoothModel2;
      procedure GaussianSmoothModel;
      procedure UnsharpModel;
      procedure InflateModel;
      procedure DeflateModel;
      // Colour Effects
      procedure ColourSmoothModel;
      procedure ColourCubicSmoothModel;
      procedure ColourLanczosSmoothModel;
      procedure ConvertVertexToFaceColours;
      procedure ConvertFaceToVertexColours;
      procedure ConvertFaceToVertexColoursLinear;
      procedure ConvertFaceToVertexColoursCubic;
      procedure ConvertFaceToVertexColoursLanczos;
      // Normals
      procedure ReNormalizeModel;
      procedure ConvertFaceToVertexNormals;
      procedure NormalSmoothModel;
      procedure NormalLinearSmoothModel;
      procedure NormalCubicSmoothModel;
      procedure NormalLanczosSmoothModel;
      // Textures
      procedure ExtractTextureAtlas; overload;
      procedure ExtractTextureAtlas(_Angle: single; _Size: integer); overload;
      procedure ExtractTextureAtlasOrigami; overload;
      procedure ExtractTextureAtlasOrigami(_Size: integer); overload;
      procedure ExtractTextureAtlasOrigamiGA; overload;
      procedure ExtractTextureAtlasOrigamiGA(_Size: integer); overload;
      procedure ExportTextures(const _BaseDir, _Ext: string; _previewTextures: boolean);
      procedure ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
      procedure GenerateNormalMapTexture;
      procedure GenerateBumpMapTexture; overload;
      procedure GenerateBumpMapTexture(_Scale: single); overload;
      procedure SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
      // Palette Related
      procedure ChangeRemappable (_Colour : TColor);
      procedure ChangePalette(const _Filename: string);
      // GUI
      procedure SetSelection(_value: boolean);
      // Copies
      procedure Assign(const _Model: TModel);
      // Mesh Optimization
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
      // Misc
      procedure MakeVoxelHVAIndependent;
   end;

implementation

uses GlobalVars, GenericThread;

constructor TModel.Create(const _Filename: string; _ShaderBank : PShaderBank);
begin
   Filename := CopyString(_Filename);
   ShaderBank := _ShaderBank;
   Voxel := nil;
   VoxelSection := nil;
   Quality := C_QUALITY_MAX;
   // Create a new 32 bits palette.
   New(Palette);
   Palette^ := TPalette.Create;
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Voxel: PVoxel; const _Palette: PPalette; const _HVA: PHVA; _ShaderBank : PShaderBank; _Quality : integer);
begin
   Filename := '';
   ShaderBank := _ShaderBank;
   Voxel := VoxelBank.Add(_Voxel);
   HVA := HVABank.Add(_HVA);
   VoxelSection := nil;
   Quality := _Quality;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModel.Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _ShaderBank : PShaderBank; _Quality : integer);
begin
   Filename := '';
   ShaderBank := _ShaderBank;
   Voxel := nil;
   VoxelSection := _VoxelSection;
   Quality := _Quality;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Model: TModel);
begin
   Assign(_Model);
end;

destructor TModel.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TModel.CommonCreationProcedures;
begin
   CurrentLOD := 0;
   Opened := false;
   Reset;
end;

procedure TModel.Reset;
begin
   ClearLODs;
   Initialize;
end;

procedure TModel.ClearLODs;
var
   i : integer;
begin
   i := High(LOD);
   while i >= 0 do
   begin
      LOD[i].Free;
      dec(i);
   end;
   SetLength(LOD,0);
end;

procedure TModel.Clear;
begin
   ClearLODs;
   VoxelBank.Delete(Voxel);    // even if it is nil, no problem.
   HVABank.Delete(HVA);
   Palette^.Free;
end;

procedure TModel.Initialize(_HighQuality: boolean = false);
var
   ext : string;
   HVAFilename : string;
begin
   // Check if we have a random file or a voxel.
   if Voxel = nil then
   begin
      if VoxelSection = nil then
      begin
         // We have a file to open.
         ext := ExtractFileExt(Filename);
         if (CompareStr(ext,'.vxl') = 0) then
         begin
            Voxel := VoxelBank.Add(Filename);
            HVAFilename := copy(Filename,1,Length(Filename)-3);
            HVAFilename := HVAFilename + 'hva';
            HVA := HVABank.Add(HVAFilename,Voxel);
            OpenVoxel;
         end;
      end
      else
      begin
         OpenVoxelSection(VoxelSection);
      end;
   end
   else  // we open the current voxel
   begin
      OpenVoxel;
   end;
   IsVisible := true;
end;

// I/O
function ThreadCreateFromVoxel(const _args: pointer): integer;
var
   Data: TVoxelCreationStruct;
begin
   if _args <> nil then
   begin
      Data := PVoxelCreationStruct(_args)^;
      (Data.Mesh)^ := TMesh.CreateFromVoxel(Data.i,Data.Section,Data.Palette,Data.ShaderBank,Data.Quality);
      (Data.Mesh)^.Next := Data.i+1;
   end;
end;


procedure TModel.OpenVoxel;
   function CreatePackageForThreadCall(const _Mesh: PMesh; _i : integer; const _Section: TVoxelSection; const _Palette: TPalette; _ShaderBank: PShaderBank; _Quality: integer): TVoxelCreationStruct;
   begin
      Result.Mesh := _Mesh;
      Result.i := _i;
      Result.Section := _Section;
      Result.Palette := _Palette;
      Result.ShaderBank := _ShaderBank;
      Result.Quality := _Quality;
   end;

   procedure LoadSections;
   var
      i : integer;
      Packages: array of TVoxelCreationStruct;
      Threads: array of TGenericThread;
      MyFunction : TGenericFunction;
   begin
      SetLength(Threads,Voxel^.Header.NumSections);
      SetLength(Packages,Voxel^.Header.NumSections);
      MyFunction := ThreadCreateFromVoxel;
      for i := 0 to (Voxel^.Header.NumSections-1) do
      begin
         Packages[i] := CreatePackageForThreadCall(Addr(LOD[0].Mesh[i]),i,Voxel^.Section[i],Palette^,ShaderBank,Quality);
         Threads[i] := TGenericThread.Create(MyFunction,Addr(Packages[i]));
      end;
      for i := 0 to (Voxel^.Header.NumSections-1) do
      begin
         Threads[i].WaitFor;
         Threads[i].Free;
      end;
      SetLength(Threads,0);
      SetLength(Packages,0);
   end;
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,Voxel^.Header.NumSections);
   LoadSections;
   LOD[0].Mesh[High(LOD[0].Mesh)].Next := -1;
   CurrentLOD := 0;
   Opened := true;
end;

procedure TModel.OpenVoxelSection(const _VoxelSection : PVoxelSection);
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,1);
   LOD[0].Mesh[0] := TMesh.CreateFromVoxel(0,_VoxelSection^,Palette^,ShaderBank,Quality);
   CurrentLOD := 0;
   HVA := HVABank.LoadNew(nil);
   Opened := true;
end;

procedure TModel.SaveLODToFile(const _Filename, _TexExt: string);
begin
   LOD[CurrentLOD].SaveToFile(_Filename,_TexExt);
end;

procedure TModel.RebuildModel;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      RebuildLOD(i);
   end;
end;

procedure TModel.RebuildLOD(i: integer);
var
   j,start : integer;
begin
   if Voxel <> nil then
   begin
      if Voxel^.Header.NumSections > LOD[i].GetNumMeshes then
      begin
         start := LOD[i].GetNumMeshes;
         SetLength(LOD[i].Mesh,Voxel^.Header.NumSections);
         for j := start to Voxel^.Header.NumSections - 1 do
         begin
            LOD[i].Mesh[j] := TMesh.CreateFromVoxel(j,Voxel^.Section[j],Palette^,ShaderBank,Quality);
            LOD[i].Mesh[j].Next := j+1;
         end;
      end;
      for j := Low(LOD[i].Mesh) to High(LOD[i].Mesh) do
      begin
         LOD[i].Mesh[j].RebuildVoxel(Voxel^.Section[j],Palette^,Quality);
      end;
   end
   else if VoxelSection <> nil then
   begin
      LOD[i].Mesh[0].RebuildVoxel(VoxelSection^,Palette^,Quality);
   end
   else
   begin
      // At the moment, we won't do anything.
   end;
end;

procedure TModel.RebuildCurrentLOD;
begin
   RebuildLOD(CurrentLOD);
end;

// Gets
function TModel.GetNumLODs: longword;
begin
   Result := High(LOD) + 1;
end;

function TModel.IsOpened : boolean;
begin
   Result := Opened;
end;

// Sets
procedure TModel.SetQuality(_value: integer);
begin
   Quality := _value;
   RebuildModel;
end;

procedure TModel.SetNormalsModeRendering;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i].SetNormalsModeRendering;
   end;
end;

procedure TModel.SetColourModeRendering;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i].SetColourModeRendering;
   end;
end;

// Rendering methods
procedure TModel.Render(var _Polycount,_VoxelCount: longword; _Frame: integer);
begin
   if IsVisible and Opened and (HVA <> nil) then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         LOD[CurrentLOD].Render(_PolyCount,_VoxelCount,HVA,_Frame);
      end;
   end;
end;

// No render to texture, nor display lists.
procedure TModel.RenderVectorial(_Frame: integer);
begin
   if IsVisible and Opened and (HVA <> nil) then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         LOD[CurrentLOD].RenderVectorial(HVA,_Frame);
      end;
   end;
end;

// Refresh OpenGL List
procedure TModel.RefreshModel;
begin
   LOD[CurrentLOD].RefreshLOD;
end;

procedure TModel.RefreshMesh(_MeshID: integer);
begin
   LOD[CurrentLOD].RefreshMesh(_MeshID);
end;

// Model Effects
procedure TModel.SmoothModel;
begin
   LOD[CurrentLOD].SmoothLOD;
end;

procedure TModel.QuadricSmoothModel;
begin
   LOD[CurrentLOD].QuadricSmoothLOD;
end;

procedure TModel.CubicSmoothModel;
begin
   LOD[CurrentLOD].CubicSmoothLOD;
end;

procedure TModel.LanczosSmoothModel;
begin
   LOD[CurrentLOD].LanczosSmoothLOD;
end;

procedure TModel.SincSmoothModel;
begin
   LOD[CurrentLOD].SincSmoothLOD;
end;

procedure TModel.EulerSmoothModel;
begin
   LOD[CurrentLOD].EulerSmoothLOD;
end;

procedure TModel.EulerSquaredSmoothModel;
begin
   LOD[CurrentLOD].EulerSquaredSmoothLOD;
end;

procedure TModel.SincInfiniteSmoothModel;
begin
   LOD[CurrentLOD].SincInfiniteSmoothLOD;
end;

procedure TModel.SmoothModel2;
begin
   LOD[CurrentLOD].SmoothLOD2;
end;

procedure TModel.QuadricSmoothModel2;
begin
   LOD[CurrentLOD].QuadricSmoothLOD2;
end;

procedure TModel.CubicSmoothModel2;
begin
   LOD[CurrentLOD].CubicSmoothLOD2;
end;

procedure TModel.LanczosSmoothModel2;
begin
   LOD[CurrentLOD].LanczosSmoothLOD2;
end;

procedure TModel.SincSmoothModel2;
begin
   LOD[CurrentLOD].SincSmoothLOD2;
end;

procedure TModel.EulerSmoothModel2;
begin
   LOD[CurrentLOD].EulerSmoothLOD2;
end;

procedure TModel.EulerSquaredSmoothModel2;
begin
   LOD[CurrentLOD].EulerSquaredSmoothLOD2;
end;

procedure TModel.SincInfiniteSmoothModel2;
begin
   LOD[CurrentLOD].SincInfiniteSmoothLOD2;
end;

procedure TModel.GaussianSmoothModel;
begin
   LOD[CurrentLOD].GaussianSmoothLOD;
end;

procedure TModel.UnsharpModel;
begin
   LOD[CurrentLOD].UnsharpLOD;
end;

procedure TModel.InflateModel;
begin
   LOD[CurrentLOD].InflateLOD;
end;

procedure TModel.DeflateModel;
begin
   LOD[CurrentLOD].DeflateLOD;
end;

// Colour Effects
procedure TModel.ColourSmoothModel;
begin
   LOD[CurrentLOD].ColourSmoothLOD;
end;

procedure TModel.ColourCubicSmoothModel;
begin
   LOD[CurrentLOD].ColourCubicSmoothLOD;
end;

procedure TModel.ColourLanczosSmoothModel;
begin
   LOD[CurrentLOD].ColourLanczosSmoothLOD;
end;

procedure TModel.ConvertVertexToFaceColours;
begin
   LOD[CurrentLOD].ConvertVertexToFaceColours;
end;

procedure TModel.ConvertFaceToVertexColours;
begin
   LOD[CurrentLOD].ConvertFaceToVertexColours;
end;

procedure TModel.ConvertFaceToVertexColoursLinear;
begin
   LOD[CurrentLOD].ConvertFaceToVertexColoursLinear;
end;

procedure TModel.ConvertFaceToVertexColoursCubic;
begin
   LOD[CurrentLOD].ConvertFaceToVertexColoursCubic;
end;

procedure TModel.ConvertFaceToVertexColoursLanczos;
begin
   LOD[CurrentLOD].ConvertFaceToVertexColoursLanczos;
end;

// Normals
procedure TModel.ReNormalizeModel;
begin
   LOD[CurrentLOD].RenormalizeLOD;
end;

procedure TModel.ConvertFaceToVertexNormals;
begin
   LOD[CurrentLOD].ConvertFaceToVertexNormals;
end;

procedure TModel.NormalSmoothModel;
begin
   LOD[CurrentLOD].NormalSmoothLOD;
end;

procedure TModel.NormalLinearSmoothModel;
begin
   LOD[CurrentLOD].NormalLinearSmoothLOD;
end;

procedure TModel.NormalCubicSmoothModel;
begin
   LOD[CurrentLOD].NormalCubicSmoothLOD;
end;

procedure TModel.NormalLanczosSmoothModel;
begin
   LOD[CurrentLOD].NormalLanczosSmoothLOD;
end;

// Textures
procedure TModel.ExtractTextureAtlas;
begin
   LOD[CurrentLOD].ExtractTextureAtlas;
end;

procedure TModel.ExtractTextureAtlas(_Angle: single; _Size : integer);
begin
   LOD[CurrentLOD].ExtractTextureAtlas(_Angle,_Size);
end;

procedure TModel.ExtractTextureAtlasOrigami;
begin
   LOD[CurrentLOD].ExtractTextureAtlasOrigami;
end;

procedure TModel.ExtractTextureAtlasOrigami(_Size : integer);
begin
   LOD[CurrentLOD].ExtractTextureAtlasOrigami(_Size);
end;

procedure TModel.ExtractTextureAtlasOrigamiGA;
begin
   LOD[CurrentLOD].ExtractTextureAtlasOrigamiGA;
end;

procedure TModel.ExtractTextureAtlasOrigamiGA(_Size : integer);
begin
   LOD[CurrentLOD].ExtractTextureAtlasOrigamiGA(_Size);
end;

procedure TModel.ExportTextures(const _BaseDir, _Ext: string; _previewTextures: boolean);
begin
   LOD[CurrentLOD].ExportTextures(_BaseDir,_Ext,_previewTextures);
end;

procedure TModel.ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
begin
   LOD[CurrentLOD].ExportHeightMap(_BaseDir,_Ext,_previewTextures);
end;

procedure TModel.GenerateNormalMapTexture;
begin
   LOD[CurrentLOD].GenerateNormalMapTexture;
end;

procedure TModel.GenerateBumpMapTexture;
begin
   LOD[CurrentLOD].GenerateBumpMapTexture;
end;

procedure TModel.GenerateBumpMapTexture(_Scale: single);
begin
   LOD[CurrentLOD].GenerateBumpMapTexture(_Scale);
end;

procedure TModel.SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
begin
   LOD[CurrentLOD].SetTextureNumMipMaps(_NumMipMaps,_TextureType);
end;


// Transparency methods
procedure TModel.ForceTransparency(_level: single);
begin
   LOD[CurrentLOD].ForceTransparency(_Level);
end;

procedure TModel.ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
begin
   LOD[CurrentLOD].ForceTransparencyOnMesh(_Level,_MeshID);
end;

procedure TModel.ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
begin
   LOD[CurrentLOD].ForceTransparencyExceptOnAMesh(_Level,_MeshID);
end;

// Palette Related
procedure TModel.ChangeRemappable(_Colour: TColor);
begin
   if Palette <> nil then
   begin
      Palette^.ChangeRemappable(_Colour);
      RebuildModel;
   end;
end;

procedure TModel.ChangePalette(const _Filename: string);
begin
   if Palette <> nil then
   begin
      Palette^.LoadPalette(_Filename);
      RebuildModel;
   end;
end;

// GUI
procedure TModel.SetSelection(_value: boolean);
var
   i : integer;
begin
   IsSelected := _value;
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i].SetSelection(_value);
   end;
end;

// Copies
procedure TModel.Assign(const _Model: TModel);
var
   i : integer;
begin
   New(Palette);
   ShaderBank := _Model.ShaderBank;
   Palette^ := TPalette.Create(_Model.Palette^);
   IsVisible := _Model.IsVisible;
   HVA := _Model.HVA;
   SetLength(LOD,_Model.GetNumLODs);
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i] := TLOD.Create(_Model.LOD[i]);
   end;
   CurrentLOD := _Model.CurrentLOD;
   Filename := CopyString(_Model.Filename);
   Voxel := _Model.Voxel;
   IsSelected := _Model.IsSelected;
   Quality := _Model.Quality;
end;

// Mesh Optimizations
procedure TModel.RemoveInvisibleFaces;
begin
   LOD[CurrentLOD].RemoveInvisibleFaces;
end;

procedure TModel.OptimizeMeshMaxQuality;
begin
   LOD[CurrentLOD].OptimizeMeshMaxQuality;
end;

procedure TModel.OptimizeMeshMaxQualityIgnoreColours;
begin
   LOD[CurrentLOD].OptimizeMeshMaxQualityIgnoreColours;
end;

procedure TModel.OptimizeMesh(_QualityLoss: single; _IgnoreColours: boolean);
begin
   LOD[CurrentLOD].OptimizeMesh(_QualityLoss,_IgnoreColours);
end;

procedure TModel.ConvertQuadsToTris;
begin
   LOD[CurrentLOD].ConvertQuadsToTris;
end;

procedure TModel.ConvertQuadsTo48Tris;
begin
   LOD[CurrentLOD].ConvertQuadsTo48Tris;
end;

// Quality Assurance
function TModel.GetAspectRatioHistogram(): THistogram;
begin
   Result := LOD[CurrentLOD].GetAspectRatioHistogram;
end;

function TModel.GetSkewnessHistogram(): THistogram;
begin
   Result := LOD[CurrentLOD].GetSkewnessHistogram;
end;

function TModel.GetSmoothnessHistogram(): THistogram;
begin
   Result := LOD[CurrentLOD].GetSmoothnessHistogram;
end;

procedure TModel.FillAspectRatioHistogram(var _Histogram: THistogram);
begin
   LOD[CurrentLOD].FillAspectRatioHistogram(_Histogram);
end;

procedure TModel.FillSkewnessHistogram(var _Histogram: THistogram);
begin
   LOD[CurrentLOD].FillSkewnessHistogram(_Histogram);
end;

procedure TModel.FillSmoothnessHistogram(var _Histogram: THistogram);
begin
   LOD[CurrentLOD].FillSmoothnessHistogram(_Histogram);
end;

// Mesh Plugins
procedure TModel.AddNormalsPlugin;
begin
   LOD[CurrentLOD].AddNormalsPlugin;
end;

procedure TModel.RemoveNormalsPlugin;
begin
   LOD[CurrentLOD].RemoveNormalsPlugin;
end;


// Misc
procedure TModel.MakeVoxelHVAIndependent;
var
   HVATemp: PHVA;
   VoxelTemp: PVoxel;
begin
   if (HVA <> nil) then
   begin
      HVATemp := HVABank.Clone(HVA);
      HVABank.Delete(HVA);
      HVA := HVATemp;
   end;
   if (Voxel <> nil) then
   begin
      VoxelTemp := VoxelBank.Clone(Voxel);
      VoxelBank.Delete(Voxel);
      Voxel := VoxelTemp;
      HVA^.p_Voxel := Voxel;
   end;
end;



end.
