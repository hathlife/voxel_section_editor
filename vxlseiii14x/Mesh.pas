unit Mesh;

interface

uses math3d, voxel_engine, dglOpenGL, GLConstants, Graphics, Voxel, Normals,
      BasicDataTypes, BasicFunctions, Palette, VoxelMap, Dialogs, SysUtils,
      VoxelModelizer, BasicConstants, Math, ClassNeighborDetector,
      ClassIntegerList, ClassStopWatch, ShaderBank, ShaderBankItem, TextureBank,
      TextureBankItem, ClassTextureGenerator, ClassIntegerSet,
      ClassMeshOptimizationTool, Material, VoxelMeshGenerator, ClassVector3fSet,
      MeshPluginBase, NormalsMeshPlugin, NeighborhoodDataPlugin, BumpMapDataPlugin,
      ClassMeshNormalsTool, ClassMeshColoursTool, ClassMeshProcessingTool,
      ClassTextureAtlasExtractor, Abstract2DImageData, ImageRGBAByteData,
      ClassMeshGeometryList, MeshBRepGeometry, MeshGeometryBase;

{$INCLUDE Global_Conditionals.inc}
type
   TMesh = class
      private
         ColoursType : byte;
         ColourGenStructure : byte;
         TransparencyLevel : single;
         Opened : boolean;
         // For multi-texture rendering purposes
//         CurrentPass : integer;
         // SetShaderAttributes procedure for rendering bump maps
//         SetShaderAttributes : TSetShaderAttributesFunc;
//         SetShaderUniform : TSetShaderUniformFunc;
         // I/O
         procedure LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
         // Sets
         // Mesh
         procedure MeshSmoothOperation(_DistanceFunction : TDistanceFunc);
         procedure LimitedMeshSmoothOperation(_DistanceFunction : TDistanceFunc);
         // Normals
         procedure RebuildFaceNormals;
         procedure SmoothNormalsOperation(_DistanceFunction: TDistanceFunc);
         // Colours
         procedure ApplyColourSmooth(_DistanceFunction : TDistanceFunc);
         procedure ConvertFaceToVertexColours(_DistanceFunction : TDistanceFunc); overload;
         // Distance Functions
         function GetIgnoredDistance(_Distance : single): single;
         function GetLinearDistance(_Distance : single): single;
         function GetLinear1DDistance(_Distance : single): single;
         function GetCubicDistance(_Distance : single): single;
         function GetCubic1DDistance(_Distance : single): single;
         function GetQuadric1DDistance(_Distance : single): single;
         function GetLanczosDistance(_Distance : single): single;
         function GetLanczos1DA1Distance(_Distance : single): single;
         function GetLanczos1DA3Distance(_Distance : single): single;
         function GetLanczos1DACDistance(_Distance : single): single;
         function GetSinc1DDistance(_Distance : single): single;
         function GetEuler1DDistance(_Distance : single): single;
         function GetEulerSquared1DDistance(_Distance : single): single;
         function GetSincInfinite1DDistance(_Distance : single): single;
         // Materials
         procedure AddMaterial;
         procedure DeleteMaterial(_ID: integer);
         procedure ClearMaterials;
         // Misc
         procedure OverrideTransparency;
      public
         // These are the formal atributes
         Name : string;
         ID : longword;
         Next : integer;
         Son : integer; // not implemented yet.
         // Graphical atributes goes here
//         FaceType : GLINT; // GL_QUADS for quads, and GL_TRIANGLES for triangles
//         VerticesPerFace : byte; // for optimization purposes only.
         NormalsType : byte;
         NumFaces : longword;
         NumVoxels : longword; // for statistic purposes.
         Vertices : TAVector3f;
         Normals : TAVector3f;
         Colours : TAVector4f;
//         Faces : auint32;
         TexCoords : TAVector2f;
         Geometry: CMeshGeometryList;
//         FaceNormals : TAVector3f;
         Materials : TAMeshMaterial;
         // Graphical and colision

         BoundingBox : TRectangle3f;
         Scale : TVector3f;
         IsColisionEnabled : boolean;
         IsVisible : boolean;
         // Rendering optimization
         RenderingProcedure : TRenderProc;
//         List : Integer;
         // Connect to the correct shader bank
         ShaderBank : PShaderBank;
         // GUI
         IsSelected : boolean;
         // Additional Features
         Plugins: PAMeshPluginBase;
         // Constructors And Destructors
         constructor Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte; _ShaderBank : PShaderBank); overload;
         constructor Create(const _Mesh : TMesh); overload;
         constructor CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED);
         destructor Destroy; override;
         procedure Clear;
         // I/O
         procedure RebuildVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
         // Sets
         procedure SetColoursType(_ColoursType: integer);
         procedure SetNormalsType(_NormalsType: integer);
         procedure SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
         procedure ForceColoursRendering;
         // Gets
         function IsOpened: boolean;

         // Mesh Effects
         procedure MeshSmooth;
         procedure MeshQuadricSmooth;
         procedure MeshCubicSmooth;
         procedure MeshLanczosSmooth;
         procedure MeshSincSmooth;
         procedure MeshEulerSmooth;
         procedure MeshEulerSquaredSmooth;
         procedure MeshSincInfiniteSmooth;
         procedure MeshGaussianSmooth;
         procedure MeshUnsharpMasking;
         procedure MeshInflate;
         procedure MeshDeflate;

         // Colour Effects
         procedure ColourSmooth;
         procedure ColourCubicSmooth;
         procedure ColourLanczosSmooth;
         procedure ColourUnsharpMasking;
         procedure ConvertVertexToFaceColours;
         procedure ConvertFaceToVertexColours; overload;
         procedure ConvertFaceToVertexColoursLinear;
         procedure ConvertFaceToVertexColoursCubic;
         procedure ConvertFaceToVertexColoursLanczos;

         // Normals related
         procedure ReNormalizeMesh;
         function GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
         procedure ConvertFaceToVertexNormals;
         procedure TransformFaceToVertexNormals;
         procedure NormalSmooth;
         procedure NormalLinearSmooth;
         procedure NormalCubicSmooth;
         procedure NormalLanczosSmooth;

         // Texture related.
         procedure GenerateDiffuseTexture;
         procedure GetMeshSeeds(_MeshID: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexExtractor: CTextureAtlasExtractor);
         procedure GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexExtractor: CTextureAtlasExtractor);
         procedure PaintMeshDiffuseTexture(var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData; var _TexGenerator: CTextureGenerator);
         procedure PaintMeshNormalMapTexture(var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData; var _TexGenerator: CTextureGenerator);
         procedure PaintMeshBumpMapTexture(var _Buffer: TAbstract2DImageData; var _TexGenerator: CTextureGenerator);
         procedure AddTextureToMesh(_MaterialID, _TextureType, _ShaderID: integer; _Texture:PTextureBankItem);
         procedure ExportTextures(const _BaseDir, _Ext : string; var _UsedTextures : CIntegerSet; _previewTextures: boolean);
         procedure SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);

         // Rendering methods
         procedure Render(var _Polycount, _VoxelCount: longword);
         procedure RenderVectorial;
         procedure ForceRefresh;

         // Copies
         procedure Assign(const _Mesh : TMesh);

         // Texture related
         function CollectColours(var _ColourMap: auint32): TAVector4f;

         // Model optimization
         procedure RemoveInvisibleFaces;
         procedure OptimizeMeshLossLess;
         procedure OptimizeMeshLossLessIgnoreColours;
         procedure MeshOptimization(_IgnoreColours: boolean; _Angle : single);
         procedure MeshOptimizationIgnoreColours(_Angle : single);
         procedure ConvertQuadsToTris;

         // Materials
         function GetLastTextureID(_MaterialID: integer): integer;
         function GetNextTextureID(_MaterialID: integer): integer;
         function GetTextureSize(_MaterialID,_TextureID: integer): integer;

         // Plugins
         procedure AddNormalsPlugin;
         procedure AddNeighborhoodPlugin;
         procedure AddBumpMapDataPlugin;
         procedure RemovePlugin(_PluginType: integer);
         procedure ClearPlugins;
         function IsPluginEnabled(_PluginType: integer): boolean;
         function GetPlugin(_PluginType: integer): PMeshPluginBase;

         // Miscelaneous
         procedure ForceTransparencyLevel(_TransparencyLevel : single);
   end;
   PMesh = ^TMesh;

implementation

uses GlobalVars;

constructor TMesh.Create(_ID,_NumVertices,_NumFaces : longword; _BoundingBox : TRectangle3f; _VerticesPerFace, _ColoursType, _NormalsType : byte; _ShaderBank : PShaderBank);
begin
   // Set basic variables:
   ShaderBank := _ShaderBank;
   ID := _ID;
//   VerticesPerFace := _VerticesPerFace;
   NumFaces := _NumFaces;
   NumVoxels := 0;
   SetColoursAndNormalsType(_ColoursType,_NormalsType);
   ColourGenStructure := _ColoursType;
   Geometry := CMeshGeometryList.Create();
   Geometry.Add;
   //Geometry.Current^ := TMeshBRepGeometry.Create(_NumFaces,_VerticesPerFace,_ColoursType,_NormalsType);
   // Let's set the array sizes.
   SetLength(Vertices,_NumVertices);
   SetLength(TexCoords,_NumVertices);
   SetLength(Normals,_NumVertices);
   SetLength(Colours,_NumVertices);
   // The rest
   BoundingBox.Min.X := _BoundingBox.Min.X;
   BoundingBox.Min.Y := _BoundingBox.Min.Y;
   BoundingBox.Min.Z := _BoundingBox.Min.Z;
   BoundingBox.Max.X := _BoundingBox.Max.X;
   BoundingBox.Max.Y := _BoundingBox.Max.Y;
   BoundingBox.Max.Z := _BoundingBox.Max.Z;
   Scale := SetVector(1,1,1);
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
   TransparencyLevel := C_TRP_OPAQUE;
   Opened := false;
   IsSelected := false;
   AddMaterial;
   Next := -1;
   Son := -1;
   SetLength(Plugins,0);
end;

constructor TMesh.Create(const _Mesh : TMesh);
begin
   Assign(_Mesh);
end;

constructor TMesh.CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _ShaderBank: PShaderBank; _Quality: integer = C_QUALITY_CUBED);
var
   c : integer;
begin
   ShaderBank := _ShaderBank;
   Geometry := CMeshGeometryList.Create;
   Clear;
   ColoursType := C_COLOURS_PER_FACE;
   ColourGenStructure := C_COLOURS_PER_FACE;
   ID := _ID;
   TransparencyLevel := C_TRP_OPAQUE;
   NumVoxels := 0;
   c := 1;
   while (c <= 16) and (_Voxel.Header.Name[c] <> #0) do
   begin
      Name := Name + _Voxel.Header.Name[c];
      inc(c);
   end;
   case _Quality of
      C_QUALITY_CUBED:
      begin
         LoadFromVoxel(_Voxel,_Palette);
      end;
      C_QUALITY_VISIBLE_CUBED:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
      end;
      C_QUALITY_VISIBLE_TRIS:
      begin
         LoadTrisFromVisibleVoxels(_Voxel,_Palette);
      end;
      C_QUALITY_VISIBLE_MANIFOLD:
      begin
         LoadManifoldsFromVisibleVoxels(_Voxel,_Palette);
      end;
      C_QUALITY_LANCZOS_QUADS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
         MeshLanczosSmooth;
      end;
      C_QUALITY_2LANCZOS_4TRIS:
      begin
         LoadTrisFromVisibleVoxels(_Voxel,_Palette);
         MeshLanczosSmooth;
         MeshLanczosSmooth;
         ConvertFaceToVertexNormals;
         ConvertFaceToVertexColours;
         ColourLanczosSmooth;
         ColourLanczosSmooth;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
         MeshLanczosSmooth;
         ConvertQuadsToTris;
         RebuildFaceNormals;
         ConvertFaceToVertexNormals;
         ConvertFaceToVertexColours;
      end;
      C_QUALITY_HIGH:
      begin
         ModelizeFromVoxel(_Voxel,_Palette);
      end;
   end;
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
   IsSelected := false;
   Next := -1;
   Son := -1;
end;

destructor TMesh.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TMesh.Clear;
begin
   Opened := false;
   ForceRefresh;
   SetLength(Vertices,0);
   SetLength(Colours,0);
   SetLength(Normals,0);
   SetLength(TexCoords,0);
   Geometry.Clear;
   ClearMaterials;
   ClearPlugins;
end;

// I/O;
procedure TMesh.RebuildVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
var
   HasNormalsMeshPlugin: boolean;
begin
   HasNormalsMeshPlugin := IsPluginEnabled(C_MPL_NORMALS);
   Clear;
   ColourGenStructure := C_COLOURS_PER_FACE;
   if ColoursType <> C_COLOURS_PER_FACE then
   begin
      SetColoursType(C_COLOURS_PER_FACE);
   end;
   case _Quality of
      C_QUALITY_CUBED:
      begin
         LoadFromVoxel(_Voxel,_Palette);
      end;
      C_QUALITY_VISIBLE_CUBED:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
      end;
      C_QUALITY_VISIBLE_TRIS:
      begin
         LoadTrisFromVisibleVoxels(_Voxel,_Palette);
      end;
      C_QUALITY_VISIBLE_MANIFOLD:
      begin
         LoadManifoldsFromVisibleVoxels(_Voxel,_Palette);
      end;
      C_QUALITY_LANCZOS_QUADS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
         MeshLanczosSmooth;
      end;
      C_QUALITY_2LANCZOS_4TRIS:
      begin
         LoadTrisFromVisibleVoxels(_Voxel,_Palette);
         MeshLanczosSmooth;
         MeshLanczosSmooth;
         ConvertFaceToVertexNormals;
         ConvertFaceToVertexColours;
         ColourLanczosSmooth;
         ColourLanczosSmooth;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
         MeshLanczosSmooth;
         ConvertQuadsToTris;
         RebuildFaceNormals;
         ConvertFaceToVertexNormals;
         ConvertFaceToVertexColours;
      end;
      C_QUALITY_HIGH:
      begin
         ModelizeFromVoxel(_Voxel,_Palette);
      end;
   end;
   if HasNormalsMeshPlugin then
   begin
      AddNormalsPlugin;
   end;
   OverrideTransparency;
end;


procedure TMesh.LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   MeshGen: TVoxelMeshGenerator;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetNormalsType(C_NORMALS_PER_FACE);
   Geometry.Add(C_GEO_BREP4);

//   Geometry.Current^ := TMeshBRepGeometry.Create(0,4,ColoursType,NormalsType);
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadFromVoxels(_Voxel,_Palette,Vertices,TexCoords,Geometry,NumVoxels);
   NumFaces := Geometry.Current^.NumFaces;
   MeshGen.Free;

   CommonVoxelLoadingActions(_Voxel);
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('LoadFromVoxels for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   MeshGen: TVoxelMeshGenerator;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetNormalsType(C_NORMALS_PER_FACE);
   Geometry.Add(C_GEO_BREP4);

   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadFromVisibleVoxels(_Voxel,_Palette,Vertices,TexCoords,Geometry,NumVoxels);
   NumFaces := Geometry.Current^.NumFaces;
   MeshGen.Free;

   AddNeighborhoodPlugin;
   CommonVoxelLoadingActions(_Voxel);
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('LoadFromVisibleVoxels for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   MeshGen: TVoxelMeshGenerator;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetNormalsType(C_NORMALS_PER_FACE);
   Geometry.Add(C_GEO_BREP4);

   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadManifoldsFromVisibleVoxels(_Voxel,_Palette,Vertices,Geometry,TexCoords,NumVoxels);
   NumFaces := Geometry.Current^.NumFaces;
   MeshGen.Free;

   CommonVoxelLoadingActions(_Voxel);
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('LoadManifoldsFromVisibleVoxels for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   MeshGen: TVoxelMeshGenerator;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetNormalsType(C_NORMALS_PER_FACE);
   Geometry.Add(C_GEO_BREP3);

   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadTrianglesFromVisibleVoxels(_Voxel,_Palette,Vertices,TexCoords,Geometry,NumVoxels);
   NumFaces := Geometry.Current^.NumFaces;
   MeshGen.Free;

   CommonVoxelLoadingActions(_Voxel);
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('LoadTrisFromVisibleVoxels for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   VoxelMap,ColourMap : TVoxelMap;
   SemiSurfacesMap : T3DIntGrid;
   VoxelModelizer : TVoxelModelizer;
   x, y : integer;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   ColoursType := C_COLOURS_PER_FACE;
   NormalsType := C_NORMALS_PER_FACE;
   Geometry.Add(C_GEO_BREP3);
   SetLength(TexCoords,0);
   SetLength(Normals,0);
   // Voxel classification stage
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;
   VoxelMap.MapSemiSurfaces(SemiSurfacesMap);
   // Colour mapping stage
   ColourMap := TVoxelMap.Create(_Voxel,1,C_MODE_COLOUR,C_OUTSIDE_VOLUME);
   // Mesh generation process
   VoxelModelizer := TVoxelModelizer.Create(VoxelMap,SemiSurfacesMap,Vertices,(Geometry.Current^ as TMeshBRepGeometry).Faces,(Geometry.Current^ as TMeshBRepGeometry).Normals,Colours,_Palette,ColourMap);
   NumFaces := (High((Geometry.Current^ as TMeshBRepGeometry).Faces)+1) div (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
   // Do the rest.
   CommonVoxelLoadingActions(_Voxel);
   // Clear memory
   VoxelModelizer.Free;
   VoxelMap.Free;
   ColourMap.Free;
   for x := High(SemiSurfacesMap) downto Low(SemiSurfacesMap) do
   begin
      for y := High(SemiSurfacesMap[x]) downto Low(SemiSurfacesMap[x]) do
      begin
         SetLength(SemiSurfacesMap[x,y],0);
      end;
      SetLength(SemiSurfacesMap[x],0);
   end;
   SetLength(SemiSurfacesMap,0);
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Modelize From Voxel for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
begin
   // The rest
   SetLength(Normals,0);
   SetLength(Colours,0);
   SetLength(TexCoords,0);
   BoundingBox.Min.X := _Voxel.Tailer.MinBounds[1];
   BoundingBox.Min.Y := _Voxel.Tailer.MinBounds[2];
   BoundingBox.Min.Z := _Voxel.Tailer.MinBounds[3];
   BoundingBox.Max.X := _Voxel.Tailer.MaxBounds[1];
   BoundingBox.Max.Y := _Voxel.Tailer.MaxBounds[2];
   BoundingBox.Max.Z := _Voxel.Tailer.MaxBounds[3];
   AddMaterial;
   Scale.X := (BoundingBox.Max.X - BoundingBox.Min.X) / _Voxel.Tailer.XSize;
   Scale.Y := (BoundingBox.Max.Y - BoundingBox.Min.Y) / _Voxel.Tailer.YSize;
   Scale.Z := (BoundingBox.Max.Z - BoundingBox.Min.Z) / _Voxel.Tailer.ZSize;
   Opened := true;
end;

// Mesh Effects.
procedure TMesh.MeshQuadricSmooth;
begin
   LimitedMeshSmoothOperation(GetQuadric1DDistance);
end;

procedure TMesh.MeshCubicSmooth;
begin
   MeshSmoothOperation(GetCubic1DDistance);
end;

procedure TMesh.MeshLanczosSmooth;
begin
   LimitedMeshSmoothOperation(GetLanczos1DACDistance);
end;

procedure TMesh.MeshSincSmooth;
begin
   MeshSmoothOperation(GetSinc1DDistance);
end;

procedure TMesh.MeshEulerSmooth;
begin
   MeshSmoothOperation(GetEuler1DDistance);
end;

procedure TMesh.MeshEulerSquaredSmooth;
begin
   MeshSmoothOperation(GetEulerSquared1DDistance);
end;

procedure TMesh.MeshSincInfiniteSmooth;
begin
   MeshSmoothOperation(GetSincInfinite1DDistance);
end;

procedure TMesh.MeshSmooth;
var
   Tool : TMeshProcessingTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin: PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      NumVertices := High(Vertices)+1;
      VertexEquivalences := nil;
   end;
   Tool := TMeshProcessingTool.Create;
   Tool.MeshSmooth(Vertices,NumVertices,NeighborDetector,VertexEquivalences);
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   ForceRefresh;
   Tool.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Smooth for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshSmoothOperation(_DistanceFunction : TDistanceFunc);
var
   Tool : TMeshProcessingTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      NumVertices := High(Vertices)+1;
      VertexEquivalences := nil;
   end;
   Tool := TMeshProcessingTool.Create;
   Tool.MeshSmoothOperation(Vertices,NumVertices,NeighborDetector,VertexEquivalences,_DistanceFunction);
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   ForceRefresh;
   Tool.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Smooth Operation for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.LimitedMeshSmoothOperation(_DistanceFunction : TDistanceFunc);
var
   Tool: TMeshProcessingTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      NumVertices := High(Vertices)+1;
      VertexEquivalences := nil;
   end;
   Tool := TMeshProcessingTool.Create;
   Tool.LimitedMeshSmoothOperation(Vertices,NumVertices,NeighborDetector,VertexEquivalences,_DistanceFunction);
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   Tool.Free;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Smooth Operation for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshGaussianSmooth;
var
   Tool: TMeshProcessingTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      NumVertices := High(Vertices)+1;
      VertexEquivalences := nil;
   end;
   Tool := TMeshProcessingTool.Create;
   Tool.MeshGaussianSmooth(Vertices,NumVertices,NeighborDetector,VertexEquivalences);
   ForceRefresh;
   // Free memory
   Tool.Free;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Gaussian Smooth for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshUnsharpMasking;
var
   Tool: TMeshProcessingTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      NumVertices := High(Vertices)+1;
      VertexEquivalences := nil;
   end;
   Tool := TMeshProcessingTool.Create;
   Tool.MeshUnsharpMasking(Vertices,NumVertices,NeighborDetector,VertexEquivalences);
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   Tool.Free;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Unsharp Masking for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshDeflate;
var
   Tool : TMeshProcessingTool;
begin
   Tool := TMeshProcessingTool.Create;
   Tool.MeshDeflate(Vertices);
   Tool.Free;
   ForceRefresh;
end;

procedure TMesh.MeshInflate;
var
   Tool : TMeshProcessingTool;
begin
   Tool := TMeshProcessingTool.Create;
   Tool.MeshInflate(Vertices);
   Tool.Free;
   ForceRefresh;
end;

// Colour Effects.
procedure TMesh.ColourSmooth;
begin
   ApplyColourSmooth(GetLinearDistance);
end;

procedure TMesh.ColourCubicSmooth;
begin
   ApplyColourSmooth(GetCubicDistance);
end;

procedure TMesh.ColourLanczosSmooth;
begin
   ApplyColourSmooth(GetLanczosDistance);
end;

procedure TMesh.ConvertFaceToVertexColours;
begin
   ConvertFaceToVertexColours(GetIgnoredDistance);
end;

procedure TMesh.ConvertFaceToVertexColoursLinear;
begin
   ConvertFaceToVertexColours(GetLinearDistance);
end;

procedure TMesh.ConvertFaceToVertexColoursCubic;
begin
   ConvertFaceToVertexColours(GetCubicDistance);
end;

procedure TMesh.ConvertFaceToVertexColoursLanczos;
begin
   ConvertFaceToVertexColours(GetLanczosDistance);
end;

procedure TMesh.ApplyColourSmooth(_DistanceFunction : TDistanceFunc);
var
   Tool : TMeshColoursTool;
   NeighborhoodPlugin: PMeshPluginBase;
   NeighborDetector: TNeighborDetector;
   VertexEquivalences: auint32;
   NumVertices,MyNumFaces: integer;
   MyFaces: auint32;
   MyFaceColours: TAVector4f;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Tool := TMeshColoursTool.Create;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   Geometry.GoToFirstElement;
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
         MyFaces := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaces;
         MyNumFaces := (High(MyFaces)+1) div (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
         MyFaceColours := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceColours;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
         Geometry.GoToFirstElement;
         MyFaces := (Geometry.Current^ as TMeshBRepGeometry).Faces;
         MyNumFaces := (Geometry.Current^ as TMeshBRepGeometry).NumFaces;
         MyFaceColours := (Geometry.Current^ as TMeshBRepGeometry).Colours;
      end;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      VertexEquivalences := nil;
      NumVertices := High(Vertices)+1;
      MyFaces := (Geometry.Current^ as TMeshBRepGeometry).Faces;
      MyNumFaces := (Geometry.Current^ as TMeshBRepGeometry).NumFaces;
      MyFaceColours := (Geometry.Current^ as TMeshBRepGeometry).Colours;
   end;
   if (ColoursType = C_COLOURS_PER_FACE) then
   begin
      Tool.ApplyFaceColourSmooth(Colours,MyFaceColours,Vertices,NumVertices,MyFaces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,NeighborDetector,VertexEquivalences,_DistanceFunction);
   end
   else if (ColoursType = C_COLOURS_PER_VERTEX) then
   begin
      Tool.ApplyVertexColourSmooth(Colours,Vertices,NumVertices,MyFaces,MyNumFaces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,NeighborDetector,VertexEquivalences,_DistanceFunction);
   end;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   Tool.Free;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Apply Colour Smooth for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ConvertFaceToVertexColours(_DistanceFunction : TDistanceFunc);
var
   Tool : TMeshColoursTool;
   OriginalColours : TAVector4f;
   NeighborhoodPlugin: PMeshPluginBase;
   NeighborDetector: TNeighborDetector;
   VertexEquivalences: auint32;
   NumVertices: integer;
   MyFaces: auint32;
   MyFaceColours: TAVector4f;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (ColoursType = C_COLOURS_PER_FACE) then
   begin
{
      NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin <> nil then
      begin
         if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
         begin
            NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
            MyFaces := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaces;
            MyFaceColours := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceColours;
         end
         else
         begin
            NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
            Geometry.GoToFirstElement;
            MyFaces := (Geometry.Current^ as TMeshBRepGeometry).Faces;
            MyFaceColours := (Geometry.Current^ as TMeshBRepGeometry).Colours;
         end;
         VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
         NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      end
      else
      begin
         NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
         Geometry.GoToFirstElement;
         NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
         VertexEquivalences := nil;
         NumVertices := High(Vertices)+1;
         MyFaces := (Geometry.Current^ as TMeshBRepGeometry).Faces;
         MyFaceColours := (Geometry.Current^ as TMeshBRepGeometry).Colours;
      end;
      Geometry.GoToFirstElement;
      SetLength(OriginalColours,High(MyFaceColours)+1);
      Tool := TMeshColoursTool.Create;
      Tool.BackupColourVector(MyFaceColours,OriginalColours);
      SetLength(Colours,High(Vertices)+1);
      Tool.TransformFaceToVertexColours(Colours,OriginalColours,Vertices,NumVertices,MyFaces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,NeighborDetector,VertexEquivalences,_DistanceFunction);
      SetLength(OriginalColours,0);
      ColourGenStructure := C_COLOURS_PER_VERTEX;
      SetColoursType(C_COLOURS_PER_VERTEX);
      ForceRefresh;
      Tool.Free;
      if NeighborhoodPlugin = nil then
      begin
         NeighborDetector.Free;
      end;
      }
      NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin <> nil then
      begin
         VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
         NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      end
      else
      begin
         VertexEquivalences := nil;
         NumVertices := High(Vertices)+1;
      end;
      Tool := TMeshColoursTool.Create;
      SetLength(Colours,High(Vertices)+1);
      Tool.TransformFaceToVertexColours(Colours,Geometry,Vertices,NumVertices,VertexEquivalences,_DistanceFunction);
      ColourGenStructure := C_COLOURS_PER_VERTEX;
      SetColoursType(C_COLOURS_PER_VERTEX);
      ForceRefresh;
      Tool.Free;
   end;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Convert Face To Vertex Colours for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ConvertVertexToFaceColours;
var
   CurrentGeometry: PMeshGeometryBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (ColoursType = C_COLOURS_PER_VERTEX) then
   begin
      Geometry.GoToFirstElement;
      CurrentGeometry := Geometry.Current;
      while CurrentGeometry <> nil do
      begin
         (CurrentGeometry^ as TMeshBRepGeometry).ConvertVertexToFaceColours(Colours);
         Geometry.GoToNextElement;
         CurrentGeometry := Geometry.Current;
      end;
      ColourGenStructure := C_COLOURS_PER_FACE;
      ColoursType := C_COLOURS_PER_FACE;
//      SetColoursType(C_COLOURS_PER_FACE);
//      ForceRefresh;
   end;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Convert Vertex To Face Colours for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ColourUnsharpMasking;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
   MyFaces: Auint32;
begin
   Geometry.GoToFirstElement;
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   SetLength(VertsHit,High(Vertices)+1,High(Vertices)+1);
   // Reset values.
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      OriginalVertexes[i].X := Vertices[i].X;
      OriginalVertexes[i].Y := Vertices[i].Y;
      OriginalVertexes[i].Z := Vertices[i].Z;
      Vertices[i].X := 0;
      Vertices[i].Y := 0;
      Vertices[i].Z := 0;
      for j := Low(HitCounter) to High(HitCounter) do
      begin
         VertsHit[i,j] := false;
      end;
      VertsHit[i,i] := true;
   end;
   MaxVerticePerFace := (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace - 1;
   MyFaces := (Geometry.Current^ as TMeshBRepGeometry).Faces;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace) + v;
         i := (v + (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace - 1) mod (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[MyFaces[v1],MyFaces[v2]] then
            begin
               Vertices[MyFaces[v1]].X := Vertices[MyFaces[v1]].X + OriginalVertexes[MyFaces[v2]].X;
               Vertices[MyFaces[v1]].Y := Vertices[MyFaces[v1]].Y + OriginalVertexes[MyFaces[v2]].Y;
               Vertices[MyFaces[v1]].Z := Vertices[MyFaces[v1]].Z + OriginalVertexes[MyFaces[v2]].Z;
               inc(HitCounter[MyFaces[v1]]);
               VertsHit[MyFaces[v1],MyFaces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod (Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
            inc(j);
         end;
      end;
   end;
   // Finally, we do the unsharp masking effect here.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HItCounter[v] > 0 then
      begin
         Vertices[v].X := (2 * OriginalVertexes[v].X) - (Vertices[v].X / HitCounter[v]);
         Vertices[v].Y := (2 * OriginalVertexes[v].Y) - (Vertices[v].Y / HitCounter[v]);
         Vertices[v].Z := (2 * OriginalVertexes[v].Z) - (Vertices[v].Z / HitCounter[v]);
      end
      else
      begin
         Vertices[v].X := OriginalVertexes[v].X;
         Vertices[v].Y := OriginalVertexes[v].Y;
         Vertices[v].Z := OriginalVertexes[v].Z;
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   for i := Low(Vertices) to High(Vertices) do
   begin
      SetLength(VertsHit[i],0);
   end;
   SetLength(VertsHit,0);
   ForceRefresh;
end;

// Normals Effects
procedure TMesh.NormalSmooth;
begin
   SmoothNormalsOperation(GetIgnoredDistance);
end;

procedure TMesh.NormalLinearSmooth;
begin
   SmoothNormalsOperation(GetLinearDistance);
end;

procedure TMesh.NormalCubicSmooth;
begin
   SmoothNormalsOperation(GetCubic1DDistance);
end;

procedure TMesh.NormalLanczosSmooth;
begin
   SmoothNormalsOperation(GetLanczosDistance);
end;

procedure TMesh.ReNormalizeMesh;
var
   Tool: TMeshNormalsTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin: PMeshPluginBase;
   VertexEquivalences: auint32;
   MyNormals: TAVector3f;
   NumVertices: integer;
   {$ifdef SPEED_TEST}
   StopWatch: TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Tool := TMeshNormalsTool.Create;
   Geometry.GoToFirstElement;
   Tool.RebuildFaceNormals((Geometry.Current^ as TMeshBRepGeometry).Normals,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,Vertices,(Geometry.Current^ as TMeshBRepGeometry).Faces);
   // If it uses vertex normals, it will normalize vertexes.
   if (NormalsType and C_NORMALS_PER_VERTEX) <> 0 then
   begin
      NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin <> nil then
      begin
         if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
         begin
            NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
            MyNormals := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNormals;
         end
         else
         begin
            NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
            MyNormals := (Geometry.Current^ as TMeshBRepGeometry).Normals;
         end;
         VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
         NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      end
      else
      begin
         NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
         Geometry.GoToFirstElement;
         NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
         MyNormals := (Geometry.Current^ as TMeshBRepGeometry).Normals;
         VertexEquivalences := nil;
         NumVertices := High(Vertices)+1;
      end;
      Tool.TransformFaceToVertexNormals(Normals,MyNormals,Vertices,NumVertices,NeighborDetector,VertexEquivalences);
      // Free Memory
      if NeighborhoodPlugin = nil then
      begin
         NeighborDetector.Free;
      end;
   end;
   ForceRefresh;
   // Free memory
   Tool.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('ReNormalize Quads for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.RebuildFaceNormals;
var
   CurrentGeometry: PMeshGeometryBase;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).RebuildNormals(Addr(Self));
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.TransformFaceToVertexNormals;
var
   Tool : TMeshNormalsTool;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   MyNormals : TAVector3f;
   VertexEquivalences : auint32;
   NumVertices: integer;
begin
   Tool := TMeshNormalsTool.Create;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   Geometry.GoToFirstElement;
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
         MyNormals := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNormals;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
         MyNormals := (Geometry.Current^ as TMeshBRepGeometry).Normals;
      end;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(Geometry,High(Vertices)+1);
      MyNormals := (Geometry.Current^ as TMeshBRepGeometry).Normals;
      VertexEquivalences := nil;
      NumVertices := High(Vertices)+1;
   end;
   SetLength(Normals,High(Vertices)+1);
   Tool.TransformFaceToVertexNormals(Normals,MyNormals,Vertices,NumVertices,NeighborDetector,VertexEquivalences);
   // Free memory
   Tool.Free;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
end;

procedure TMesh.ConvertFaceToVertexNormals;
   {$ifdef SPEED_TEST}
var
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (NormalsType and C_NORMALS_PER_VERTEX) = 0 then
   begin
      NormalsType := C_NORMALS_PER_VERTEX;
      SetLength(Normals,High(Vertices)+1);
      TransformFaceToVertexNormals;
      SetNormalsType(C_NORMALS_PER_VERTEX);
   end;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Face To Vertex Normals Conversion for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

function TMesh.GetNormalsValue(const _V1,_V2,_V3: TVector3f): TVector3f;
begin
   Result.X := (((_V3.Y - _V2.Y) * (_V1.Z - _V2.Z)) - ((_V1.Y - _V2.Y) * (_V3.Z - _V2.Z)));
   Result.Y := (((_V3.Z - _V2.Z) * (_V1.X - _V2.X)) - ((_V1.Z - _V2.Z) * (_V3.X - _V2.X)));
   Result.Z := (((_V3.X - _V2.X) * (_V1.Y - _V2.Y)) - ((_V1.X - _V2.X) * (_V3.Y - _V2.Y)));
   Normalize(Result);
end;

procedure TMesh.SmoothNormalsOperation(_DistanceFunction: TDistanceFunc);
var
   Neighbors : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   Tool : TMeshNormalsTool;
   NumVertices : integer;
   VertexEquivalences: auint32;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Tool := TMeshNormalsTool.Create;
   // Setup Neighbors.
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   Geometry.GoToFirstElement;
   if (NormalsType and C_NORMALS_PER_FACE) = 0 then
   begin
      if NeighborhoodPlugin <> nil then
      begin
         Neighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
         NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
         if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseEquivalenceFaces then
         begin
            VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
         end
         else
         begin
            VertexEquivalences := nil;
         end;
      end
      else
      begin
         Neighbors := TNeighborDetector.Create;
         Neighbors.BuildUpData((Geometry.Current^ as TMeshBRepGeometry).Faces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,High(Vertices)+1);
         Geometry.GoToFirstElement;
         NumVertices := High(Vertices)+1;
         VertexEquivalences := nil;
      end;
      Tool.SmoothVertexNormalsOperation(Normals,Vertices,NumVertices,Neighbors,VertexEquivalences,_DistanceFunction);
   end
   else
   begin
      if NeighborhoodPlugin <> nil then
      begin
         Neighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
      end
      else
      begin
         Neighbors := TNeighborDetector.Create;
         Neighbors.NeighborType := C_NEIGHBTYPE_FACE_FACE_FROM_EDGE;
         Neighbors.BuildUpData(Geometry,High(Vertices)+1);
      end;
      Tool.SmoothFaceNormalsOperation((Geometry.Current^ as TMeshBRepGeometry).Normals,Vertices,Neighbors,_DistanceFunction);
   end;

   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      Neighbors.Free;
   end;
   Tool.Free;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Smooth Normals Operation for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

// Texture related.
// -- DEPRECATED (still works, but avoid using it). Check LOD.pas instead.
procedure TMesh.GenerateDiffuseTexture;
var
   AtlasExtractor: CTextureAtlasExtractor;
   TexGenerator: CTextureGenerator;
   Bitmap : TBitmap;
   AlphaMap : TByteMap;
   NeighborhoodPlugin: PMeshPluginBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   RebuildFaceNormals;
   AtlasExtractor := CTextureAtlasExtractor.Create;
   TexGenerator := CTextureGenerator.Create;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   Geometry.GoToFirstElement;
   TexCoords := AtlasExtractor.GetTextureCoordinates(Vertices,(Geometry.Current^ as TMeshBRepGeometry).Normals,Normals,Colours,(Geometry.Current^ as TMeshBRepGeometry).Faces,NeighborhoodPlugin,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace);
   if NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(NeighborhoodPlugin^).DeactivateQuadFaces;
   end;
   ClearMaterials;
   AddMaterial;
   SetLength(Materials[0].Texture,1);
   glActiveTexture(GL_TEXTURE0);
   Bitmap := TexGenerator.GenerateDiffuseTexture((Geometry.Current^ as TMeshBRepGeometry).Faces,Colours,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,1024,AlphaMap);
   Materials[0].Texture[0] := GlobalVars.TextureBank.Add(Bitmap,AlphaMap);
   Materials[0].Texture[0]^.TextureType := C_TTP_DIFFUSE;
   SetLength(AlphaMap,0,0);
   Bitmap.Free;
   if ShaderBank <> nil then
      Materials[0].Shader := ShaderBank^.Get(C_SHD_PHONG_1TEX)
   else
      Materials[0].Shader := nil;
   SetColoursType(C_COLOURS_FROM_TEXTURE);
   AtlasExtractor.Free;
   TexGenerator.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Texture atlas extraction for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

// This function gets a temporary set of coordinates that might become real texture coordinates later on.
procedure TMesh.GetMeshSeeds(_MeshID: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexExtractor: CTextureAtlasExtractor);
var
   NeighborhoodPlugin: PMeshPluginBase;
begin
   //RebuildFaceNormals;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   Geometry.GoToFirstElement;
   TexCoords := _TexExtractor.GetMeshSeeds(_MeshID,Vertices,(Geometry.Current^ as TMeshBRepGeometry).Normals,Normals,Colours,(Geometry.Current^ as TMeshBRepGeometry).Faces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_Seeds,_VertsSeed,NeighborhoodPlugin);
   if NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(NeighborhoodPlugin^).DeactivateQuadFaces;
   end;
end;

// This one really acquires the final texture coordinates values.
procedure TMesh.GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexExtractor: CTextureAtlasExtractor);
begin
   _TexExtractor.GetFinalTextureCoordinates(_Seeds,_VertsSeed,TexCoords);
end;

procedure TMesh.PaintMeshDiffuseTexture(var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData; var _TexGenerator: CTextureGenerator);
begin
   Geometry.GoToFirstElement;
   _TexGenerator.PaintMeshDiffuseTexture((Geometry.Current^ as TMeshBRepGeometry).Faces,Colours,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_Buffer,_WeightBuffer);
end;

procedure TMesh.PaintMeshNormalMapTexture(var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData; var _TexGenerator: CTextureGenerator);
begin
   Geometry.GoToFirstElement;
   _TexGenerator.PaintMeshNormalMapTexture((Geometry.Current^ as TMeshBRepGeometry).Faces,Normals,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_Buffer,_WeightBuffer);
   while Geometry.Current <> nil do
   begin
      (Geometry.Current^ as TMeshBRepGeometry).SetNormalMappingShader;
      Geometry.GoToNextElement;
   end;
end;

procedure TMesh.PaintMeshBumpMapTexture(var _Buffer: TAbstract2DImageData; var _TexGenerator: CTextureGenerator);
var
   DiffuseMap: TAbstract2DImageData;
begin
   DiffuseMap := T2DImageRGBAByteData.Create(0,0);
   Geometry.GoToFirstElement;
   Materials[0].GetTextureData(C_TTP_DIFFUSE,DiffuseMap);
   _TexGenerator.PaintMeshBumpMapTexture((Geometry.Current^ as TMeshBRepGeometry).Faces,Normals,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,_Buffer,DiffuseMap);
   DiffuseMap.Free;
   AddBumpMapDataPlugin;
   while Geometry.Current <> nil do
   begin
      (Geometry.Current^ as TMeshBRepGeometry).SetBumpMappingShader;
      Geometry.GoToNextElement;
   end;
end;

procedure TMesh.AddTextureToMesh(_MaterialID, _TextureType, _ShaderID: integer; _Texture:PTextureBankItem);
begin
   while High(Materials) < _MaterialID do
   begin
      AddMaterial;
   end;
   Materials[_MaterialID].AddTexture(_TextureType,_Texture);
   if ShaderBank <> nil then
      Materials[_MaterialID].Shader := ShaderBank^.Get(_ShaderID)
   else
      Materials[_MaterialID].Shader := nil;
   if _TextureType = C_TTP_DOT3BUMP then
   begin
      AddBumpMapDataPlugin;
      Geometry.GoToFirstElement;
      while Geometry.Current <> nil do
      begin
         (Geometry.Current^ as TMeshBRepGeometry).SetBumpMappingShader;
         Geometry.GoToNextElement;
      end;
   end;
   SetColoursType(C_COLOURS_FROM_TEXTURE);
end;

// Sets
procedure TMesh.SetColoursType(_ColoursType: integer);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   ColoursType := _ColoursType and 3;
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      CurrentGeometry^.SetColoursType(ColoursType);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.ForceColoursRendering;
begin
   SetColoursType(ColourGenStructure);
end;

procedure TMesh.SetNormalsType(_NormalsType: integer);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   NormalsType := _NormalsType and 3;
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      CurrentGeometry^.SetNormalsType(NormalsType);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   ColoursType := _ColoursType and 3;
   NormalsType := _NormalsType and 3;
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      CurrentGeometry^.SetColoursAndNormalsType(ColoursType,NormalsType);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

// Gets
function TMesh.IsOpened: boolean;
begin
   Result := Opened;
end;


// Rendering methods.
procedure TMesh.Render(var _PolyCount,_VoxelCount: longword);
var
   i : integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   if IsVisible and Opened then
   begin
      inc(_PolyCount,NumFaces);
      inc(_VoxelCount,NumVoxels);

      Geometry.GoToFirstElement;
      CurrentGeometry := Geometry.Current;
      while CurrentGeometry <> nil do
      begin
         CurrentGeometry^.PreRender(Addr(self));
         Geometry.GoToNextElement;
         CurrentGeometry := Geometry.Current;
      end;
      // Move accordingly to the bounding box position.
      glTranslatef(BoundingBox.Min.X, BoundingBox.Min.Y, BoundingBox.Min.Z);
      Geometry.GoToFirstElement;
      CurrentGeometry := Geometry.Current;
      while CurrentGeometry <> nil do
      begin
         CurrentGeometry^.Render;
         Geometry.GoToNextElement;
         CurrentGeometry := Geometry.Current;
      end;
      for i := Low(Plugins) to High(Plugins) do
      begin
         if Plugins[i] <> nil then
         begin
            Plugins[i]^.Render;
         end;
      end;
   end;
end;

procedure TMesh.RenderVectorial();
var
   i : integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   if IsVisible and Opened then
   begin
      // Move accordingly to the bounding box position.
      glTranslatef(BoundingBox.Min.X, BoundingBox.Min.Y, BoundingBox.Min.Z);
      Geometry.GoToFirstElement;
      CurrentGeometry := Geometry.Current;
      while CurrentGeometry <> nil do
      begin
         CurrentGeometry^.RenderVectorial(Addr(self));
         Geometry.GoToNextElement;
         CurrentGeometry := Geometry.Current;
      end;
      for i := Low(Plugins) to High(Plugins) do
      begin
         if Plugins[i] <> nil then
         begin
            Plugins[i]^.Render;
         end;
      end;
   end;
end;

// Basically clears the OpenGL List, so the RenderingProcedure may run next time it renders the mesh.
procedure TMesh.ForceRefresh;
var
   i : integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      CurrentGeometry^.ForceRefresh;
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
   for i := Low(Plugins) to High(Plugins) do
   begin
      if Plugins[i] <> nil then
      begin
         Plugins[i]^.Update(Addr(self));
      end;
   end;
end;

// Copies
procedure TMesh.Assign(const _Mesh : TMesh);
var
   i : integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   ShaderBank := _Mesh.ShaderBank;
   NormalsType := _Mesh.NormalsType;
   ColoursType := _Mesh.ColoursType;
   TransparencyLevel := _Mesh.TransparencyLevel;
   Opened := _Mesh.Opened;
   Name := CopyString(_Mesh.Name);
   ID := _Mesh.ID;
   Son := _Mesh.Son;
   Scale.X := _Mesh.Scale.X;
   Scale.Y := _Mesh.Scale.Y;
   Scale.Z := _Mesh.Scale.Z;
   IsColisionEnabled := _Mesh.IsColisionEnabled;
   IsVisible := _Mesh.IsVisible;
   IsSelected := _Mesh.IsSelected;
   BoundingBox.Min.X := _Mesh.BoundingBox.Min.X;
   BoundingBox.Min.Y := _Mesh.BoundingBox.Min.Y;
   BoundingBox.Min.Z := _Mesh.BoundingBox.Min.Z;
   BoundingBox.Max.X := _Mesh.BoundingBox.Max.X;
   BoundingBox.Max.Y := _Mesh.BoundingBox.Max.Y;
   BoundingBox.Max.Z := _Mesh.BoundingBox.Max.Z;
   SetLength(Vertices,High(_Mesh.Vertices) + 1);
   for i := Low(Vertices) to High(Vertices) do
   begin
      Vertices[i].X := _Mesh.Vertices[i].X;
      Vertices[i].Y := _Mesh.Vertices[i].Y;
      Vertices[i].Z := _Mesh.Vertices[i].Z;
   end;
   SetLength(Normals,High(_Mesh.Normals)+1);
   for i := Low(Normals) to High(Normals) do
   begin
      Normals[i].X := _Mesh.Normals[i].X;
      Normals[i].Y := _Mesh.Normals[i].Y;
      Normals[i].Z := _Mesh.Normals[i].Z;
   end;
   SetLength(Colours,High(_Mesh.Colours)+1);
   for i := Low(Colours) to High(Colours) do
   begin
      Colours[i].X := _Mesh.Colours[i].X;
      Colours[i].Y := _Mesh.Colours[i].Y;
      Colours[i].Z := _Mesh.Colours[i].Z;
      Colours[i].W := _Mesh.Colours[i].W;
   end;
   SetLength(TexCoords,High(_Mesh.TexCoords)+1);
   for i := Low(TexCoords) to High(TexCoords) do
   begin
      TexCoords[i].U := _Mesh.TexCoords[i].U;
      TexCoords[i].V := _Mesh.TexCoords[i].V;
   end;
   SetLength(Materials,High(Materials)+1);
   for i := Low(Materials) to High(Materials) do
   begin
      Materials[i].Assign(Materials[i]);
   end;
   _Mesh.Geometry.GoToFirstElement;
   CurrentGeometry := _Mesh.Geometry.Current;
   Geometry := CMeshGeometryList.Create();
   while CurrentGeometry <> nil do
   begin
      Geometry.Add(C_GEO_BREP);
      Geometry.Current^.Assign(CurrentGeometry^);

      _Mesh.Geometry.GoToNextElement;
      CurrentGeometry := _Mesh.Geometry.Current;
   end;

   Next := _Mesh.Next;
end;

// Texture related
function TMesh.CollectColours(var _ColourMap: auint32): TAVector4f;
var
   i,f: integer;
   found : boolean;
begin
   SetLength(Result,0);
   SetLength(_ColourMap,High(Colours)+1);
   for f := Low(Colours) to High(Colours) do
   begin
      i := Low(Result);
      found := false;
      while (i < High(Result)) and (not found) do
      begin
         if (Colours[f].X = Result[i].X) and (Colours[f].Y = Result[i].Y) and (Colours[f].Z = Result[i].Z) and (Colours[f].W = Result[i].W) then
         begin
            found := true;
            _ColourMap[f] := i;
         end
         else
            inc(i);
      end;
      if not found then
      begin
         SetLength(Result,High(Result)+2);
         Result[High(Result)].X := Colours[f].X;
         Result[High(Result)].Y := Colours[f].Y;
         Result[High(Result)].Z := Colours[f].Z;
         Result[High(Result)].W := Colours[f].W;
         _ColourMap[f] := High(Result);
      end;
   end;
end;

// Materials
procedure TMesh.AddMaterial;
begin
   SetLength(Materials,High(Materials)+2);
   Materials[High(Materials)] := TMeshMaterial.Create(ShaderBank);
end;

procedure TMesh.DeleteMaterial(_ID: integer);
var
   i: integer;
begin
   i := _ID;
   while i < High(Materials) do
   begin
      Materials[i].Assign(Materials[i+1]);
      inc(i);
   end;
   Materials[High(Materials)].Free;
   SetLength(Materials,High(Materials));
end;

procedure TMesh.ClearMaterials;
var
   i: integer;
begin
   for i := Low(Materials) to High(Materials) do
   begin
      Materials[i].Free;
   end;
   SetLength(Materials,0);
end;

function TMesh.GetLastTextureID(_MaterialID: integer): integer;
begin
   if (_MaterialID >= 0) and (_MaterialID <= High(Materials)) then
   begin
      Result := Materials[_MaterialID].GetLastTextureID;
   end
   else
   begin
      Result := -1;
   end;
end;

function TMesh.GetNextTextureID(_MaterialID: integer): integer;
begin
   if (_MaterialID >= 0) and (_MaterialID <= High(Materials)) then
   begin
      Result := Materials[_MaterialID].GetNextTextureID;
   end
   else
   begin
      Result := 0;
   end;
end;

function TMesh.GetTextureSize(_MaterialID,_TextureID: integer): integer;
begin
   if (_MaterialID >= 0) and (_MaterialID <= High(Materials)) then
   begin
      Result := Materials[_MaterialID].GetTextureSize(_TextureID);
   end
   else
   begin
      Result := 0;
   end;
end;

procedure TMesh.ExportTextures(const _BaseDir, _Ext : string; var _UsedTextures : CIntegerSet; _previewTextures: boolean);
var
   mat: integer;
begin
   for mat := Low(Materials) to High(Materials) do
   begin
      Materials[mat].ExportTextures(_BaseDir,Name + '_' + IntToStr(ID) + '_' + IntToStr(mat),_Ext,_UsedTextures,_previewTextures);
   end;
end;

procedure TMesh.SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
var
   mat : integer;
begin
   for mat := Low(Materials) to High(Materials) do
   begin
      Materials[mat].SetTextureNumMipmaps(_NumMipMaps,_TextureType);
   end;
end;


// Plugins
procedure TMesh.AddNormalsPlugin;
var
   NewPlugin : PMeshPluginBase;
begin
   new(NewPlugin);
   NewPlugin^ := TNormalsMeshPlugin.Create();
   SetLength(Plugins,High(Plugins)+2);
   Plugins[High(Plugins)] := NewPlugin;
   ForceRefresh;
end;

procedure TMesh.AddNeighborhoodPlugin;
var
   NewPlugin : PMeshPluginBase;
begin
   new(NewPlugin);
   Geometry.GoToFirstElement;
   NewPlugin^ := TNeighborhoodDataPlugin.Create(Geometry,High(Vertices)+1);
   SetLength(Plugins,High(Plugins)+2);
   Plugins[High(Plugins)] := NewPlugin;
   ForceRefresh;
end;

procedure TMesh.AddBumpMapDataPlugin;
var
   NewPlugin : PMeshPluginBase;
begin
   new(NewPlugin);
   Geometry.GoToFirstElement;
   NewPlugin^ := TBumpMapDataPlugin.Create(Vertices,Normals,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).Faces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace);
   SetLength(Plugins,High(Plugins)+2);
   Plugins[High(Plugins)] := NewPlugin;
   ForceRefresh;
end;


procedure TMesh.RemovePlugin(_PluginType: integer);
var
   i : integer;
begin
   i := Low(Plugins);
   while i <= High(Plugins) do
   begin
      if Plugins[i] <> nil then
      begin
         if Plugins[i]^.PluginType = _PluginType then
         begin
            Plugins[i]^.Free;
            while i < High(Plugins) do
            begin
               Plugins[i] := Plugins[i+1];
               inc(i);
            end;
         end;
      end;
      inc(i);
   end;
   SetLength(Plugins,High(Plugins));
   ForceRefresh;
end;

procedure TMesh.ClearPlugins;
var
   i : integer;
begin
   for i := Low(Plugins) to High(Plugins) do
   begin
      if Plugins[i] <> nil then
      begin
         Plugins[i]^.Free;
      end;
   end;
   SetLength(Plugins,0);
end;

function TMesh.IsPluginEnabled(_PluginType: integer): boolean;
var
   i : integer;
begin
   Result := false;
   i := Low(Plugins);
   while i <= High(Plugins) do
   begin
      if Plugins[i] <> nil then
      begin
         if Plugins[i]^.PluginType = _PluginType then
         begin
            Result := true;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function TMesh.GetPlugin(_PluginType: integer): PMeshPluginBase;
var
   i : integer;
begin
   i := Low(Plugins);
   while i <= High(Plugins) do
   begin
      if Plugins[i] <> nil then
      begin
         if Plugins[i]^.PluginType = _PluginType then
         begin
            Result := Plugins[i];
            exit;
         end;
      end;
      inc(i);
   end;
   Result := nil;
end;


// Miscelaneous
procedure TMesh.OverrideTransparency;
var
   c : integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   for c := Low(Colours) to High(Colours) do
   begin
      Colours[c].W := TransparencyLevel;
   end;
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).OverrideTransparency(TransparencyLevel);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.ForceTransparencyLevel(_TransparencyLevel : single);
begin
   TransparencyLevel := _TransparencyLevel;
   OverrideTransparency;
   ForceRefresh;
end;

procedure TMesh.RemoveInvisibleFaces;
var
   CurrentGeometry: PMeshGeometryBase;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).RemoveInvisibleFaces(Addr(Self));
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.ConvertQuadsToTris;
var
   CurrentGeometry: PMeshGeometryBase;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).ConvertQuadsToTris(Addr(Self));
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.MeshOptimization(_IgnoreColours: boolean; _Angle : single);
var
   OptimizationTool: TMeshOptimizationTool;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (NormalsType = C_NORMALS_PER_FACE) then
   begin
      ConvertFaceToVertexNormals;
   end;
   RebuildFaceNormals;
   // Check ClassMeshOptimizationTool.pas. Note: _Angle is actually the value of the cosine
   Geometry.GoToFirstElement;
   OptimizationTool := TMeshOptimizationTool.Create(_IgnoreColours,_Angle);
   if ColoursType >= C_COLOURS_PER_VERTEX then
   begin
      OptimizationTool.Execute(Vertices,Normals,(Geometry.Current^ as TMeshBRepGeometry).Normals,Colours,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).Faces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,ColoursType,NormalsType,NumFaces);
   end
   else
   begin
      OptimizationTool.Execute(Vertices,Normals,(Geometry.Current^ as TMeshBRepGeometry).Normals,(Geometry.Current^ as TMeshBRepGeometry).Colours,TexCoords,(Geometry.Current^ as TMeshBRepGeometry).Faces,(Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,ColoursType,NormalsType,NumFaces);
   end;
   (Geometry.Current^ as TMeshBRepGeometry).UpdateNumFaces;
   OptimizationTool.Free;

   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   if not _IgnoreColours then
   begin
      GlobalVars.SpeedFile.Add('Mesh Optimization for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   end
   else
   begin
      GlobalVars.SpeedFile.Add('Mesh Optimization without colour restriction for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   end;
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshOptimizationIgnoreColours(_Angle : single);
begin
   MeshOptimization(true,_Angle);
end;

procedure TMesh.OptimizeMeshLossLess;
begin
   MeshOptimization(false,1);
end;

procedure TMesh.OptimizeMeshLossLessIgnoreColours;
begin
   MeshOptimizationIgnoreColours(1);
end;

// Distance Formulas
function TMesh.GetIgnoredDistance(_Distance : single): single;
begin
   Result := 1;
end;

function TMesh.GetLinearDistance(_Distance : single): single;
begin
   Result := 1 / (abs(_Distance) + 1);
end;

function TMesh.GetCubicDistance(_Distance : single): single;
begin
   Result := 1 / (1 + Power(_Distance,3));
end;

function TMesh.GetQuadric1DDistance(_Distance : single): single;
const
   FREQ_NORMALIZER = 4/3;
begin
   Result := Power(FREQ_NORMALIZER * _Distance,2);
   if _Distance < 0 then
      Result := Result * -1;
end;

function TMesh.GetLinear1DDistance(_Distance : single): single;
begin
   Result := _Distance;
end;

function TMesh.GetCubic1DDistance(_Distance : single): single;
const
   FREQ_NORMALIZER = 1.5;
begin
   Result := Power(FREQ_NORMALIZER * _Distance,3);
end;

function TMesh.GetLanczosDistance(_Distance : single): single;
const
   PIDIV3 = Pi / 3;
begin
   Result := ((3 * sin(Pi * _Distance) * sin(PIDIV3 * _Distance)) / Power(Pi * _Distance,2));
   if _Distance < 0 then
      Result := Result * -1;
end;

function TMesh.GetLanczos1DA1Distance(_Distance : single): single;
begin
   Result := 0;
   if _Distance <> 0 then
      Result := 1 - (Power(sin(Pi * _Distance),2) / Power(Pi * _Distance,2));
   if _Distance < 0 then
      Result := Result * -1;
end;

function TMesh.GetLanczos1DA3Distance(_Distance : single): single;
const
   PIDIV3 = Pi / 3;
begin
   Result := 0;
   if _Distance <> 0 then
     Result := 1 - ((3 * sin(Pi * _Distance) * sin(PIDIV3 * _Distance)) / Power(Pi * _Distance,2));
   if _Distance < 0 then
     Result := Result * -1;
end;

function TMesh.GetLanczos1DACDistance(_Distance : single): single;
const
   CONST_A = 3;//15;
   NORMALIZER = 2 * Pi;
   PIDIVA = Pi / CONST_A;
var
   Distance: single;
begin
   Result := 0;
   Distance := _Distance * C_FREQ_NORMALIZER;
   if _Distance <> 0 then
//     Result := NORMALIZER * (1 - ((CONST_A * sin(Distance) * sin(Distance / CONST_A)) / Power(Distance,2)));
     Result := (1 - ((CONST_A * sin(Pi * Distance) * sin(PIDIVA * Distance)) / Power(Pi * Distance,2)));
   if _Distance < 0 then
     Result := Result * -1;
end;

function TMesh.GetSinc1DDistance(_Distance : single): single;
const
   NORMALIZER = 2 * Pi; //6.307993515;
var
   Distance: single;
begin
   Result := 0;
   Distance := _Distance * C_FREQ_NORMALIZER;
   if _Distance <> 0 then
      Result := NORMALIZER * (1 - (sin(Distance) / Distance));
   if _Distance < 0 then
      Result := Result * -1;
end;

function TMesh.GetEuler1DDistance(_Distance : single): single;
var
   i,c : integer;
   Distance : single;
begin
   i := 2;
   Result := 1;
   c := 0;
   Distance := abs(_Distance);
   while c <= 30 do
   begin
      Result := Result * cos(Distance / i);
      i := i * 2;
      inc(c);
   end;
   if _Distance < 0 then
      Result := -Result;
end;

function TMesh.GetEulerSquared1DDistance(_Distance : single): single;
var
   i,c : integer;
begin
   i := 2;
   Result := 1;
   c := 0;
   while c <= 30 do
   begin
      Result := Result * cos(_Distance / i);
      i := i * 2;
      inc(c);
   end;
   Result := Result * Result;
   if _Distance < 0 then
      Result := -Result;
end;

function TMesh.GetSincInfinite1DDistance(_Distance : single): single;
var
   i,c : integer;
   Distance2: single;
begin
   c := 0;
   i := 1;
   Distance2 := _Distance * _Distance;
   Result := 1;
   while c <= 100 do
   begin
      Result := Result * (1 - (Distance2 / (i * i)));
      inc(c);
      inc(i);
   end;
   Result := 1 - Result;
   if _Distance < 0 then
      Result := -Result;
end;


end.
