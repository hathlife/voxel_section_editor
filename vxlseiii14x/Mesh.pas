unit Mesh;

interface

uses math3d, voxel_engine, dglOpenGL, GLConstants, Graphics, Voxel, Normals,
      BasicDataTypes, BasicFunctions, Palette, VoxelMap, Dialogs, SysUtils,
      VoxelModelizer, BasicConstants, Math, ClassNeighborDetector,
      ClassIntegerList, ClassStopWatch, ShaderBank, ShaderBankItem, TextureBank,
      TextureBankItem, ClassTextureGenerator, ClassIntegerSet,
      ClassMeshOptimizationTool, Material, VoxelMeshGenerator, ClassVector3fSet,
      MeshPluginBase, NormalsMeshPlugin, NeighborhoodDataPlugin, BumpMapDataPlugin;

{$INCLUDE Global_Conditionals.inc}
type
   TRenderProc = procedure of object;
   TDistanceFunc = function (_Distance: single): single of object;
   TMesh = class
      private
         ColoursType : byte;
         ColourGenStructure : byte;
         TransparencyLevel : single;
         Opened : boolean;
         // For multi-texture rendering purposes
         CurrentPass : integer;
         // Connect to the correct shader bank
         ShaderBank : PShaderBank;
         // I/O
         procedure LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure ModelizeFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
         // Sets
         procedure SetRenderingProcedure;
         // Mesh
         procedure MeshSmoothOperation(_DistanceFunction : TDistanceFunc);
         procedure LimitedMeshSmoothOperation(_DistanceFunction : TDistanceFunc);
         // Normals
         procedure ReNormalizeQuads;
         procedure ReNormalizeTriangles;
         procedure ReNormalizePerVertex;
         procedure ReNormalizeFaces;
         procedure RebuildFaceNormals;
         procedure TransformFaceToVertexNormals;
         procedure SmoothNormalsOperation(_DistanceFunction: TDistanceFunc);
         // Colours
         procedure ApplyColourSmooth(_DistanceFunction : TDistanceFunc);
         procedure FilterAndFixColours;
         procedure TransformFaceToVertexColours(var _VertColours: TAVector4f; const _FaceColours: TAVector4f; _DistanceFunction : TDistanceFunc);
         procedure TransformVertexToFaceColours(const _VertColours: TAVector4f; var _FaceColours: TAVector4f);
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
         function FindMeshCenter: TVector3f;
      public
         // These are the formal atributes
         Name : string;
         ID : longword;
         Next : integer;
         Son : integer; // not implemented yet.
         // Graphical atributes goes here
         FaceType : GLINT; // GL_QUADS for volumes, and GL_TRIANGLES for geometry
         VerticesPerFace : byte; // for optimization purposes only.
         NormalsType : byte;
         NumFaces : longword;
         NumVoxels : longword; // for statistic purposes.
         Vertices : TAVector3f;
         Normals : TAVector3f;
         Colours : TAVector4f;
         Faces : auint32;
         TexCoords : TAVector2f;
         FaceNormals : TAVector3f;
         Materials : TAMeshMaterial;
         // Graphical and colision
         BoundingBox : TRectangle3f;
         Scale : TVector3f;
         IsColisionEnabled : boolean;
         IsVisible : boolean;
         // Rendering optimization
         RenderingProcedure : TRenderProc;
         List : Integer;
         // GUI
         IsSelected : boolean;
         // Additional Features
         Plugins: PMeshPluginBase;
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
         procedure NormalSmooth;
         procedure NormalLinearSmooth;
         procedure NormalCubicSmooth;
         procedure NormalLanczosSmooth;

         // Texture related.
         procedure GenerateDiffuseTexture;
         procedure GetMeshSeeds(_MeshID: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexGenerator: CTextureGenerator);
         procedure GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexGenerator: CTextureGenerator);
         procedure PaintMeshDiffuseTexture(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _TexGenerator: CTextureGenerator);
         procedure PaintMeshNormalMapTexture(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _TexGenerator: CTextureGenerator);
         procedure PaintMeshBumpMapTexture(var _Buffer: T2DFrameBuffer; var _TexGenerator: CTextureGenerator);
         procedure AddTextureToMesh(_MaterialID, _TextureType, _ShaderID: integer; _Texture:PTextureBankItem);
         procedure ExportTextures(const _BaseDir, _Ext : string; var _UsedTextures : CIntegerSet);

         // Rendering methods
         procedure Render(var _Polycount, _VoxelCount: longword);
         procedure RenderWithoutNormalsAndColours;
         procedure RenderWithVertexNormalsAndNoColours;
         procedure RenderWithFaceNormalsAndNoColours;
         procedure RenderWithoutNormalsAndWithColoursPerVertex;
         procedure RenderWithVertexNormalsAndColours;
         procedure RenderWithFaceNormalsAndVertexColours;
         procedure RenderWithoutNormalsAndWithFaceColours;
         procedure RenderWithVertexNormalsAndFaceColours;
         procedure RenderWithFaceNormalsAndColours;
         procedure RenderWithoutNormalsAndWithTexture;
         procedure RenderWithVertexNormalsAndWithTexture;
         procedure RenderWithFaceNormalsAndWithTexture;
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
   List := C_LIST_NONE;
   ID := _ID;
   VerticesPerFace := _VerticesPerFace;
   NumFaces := _NumFaces;
   NumVoxels := 0;
   SetColoursAndNormalsType(_ColoursType,_NormalsType);
   ColourGenStructure := _ColoursType;
   // Let's set the face type:
   if VerticesPerFace = 4 then
      FaceType := GL_QUADS
   else
      FaceType := GL_TRIANGLES;
   // Let's set the array sizes.
   SetLength(Vertices,_NumVertices);
   SetLength(Faces,_NumFaces);
   SetLength(TexCoords,_NumVertices);
   if (NormalsType and C_NORMALS_PER_VERTEX) <> 0 then
      SetLength(Normals,_NumVertices)
   else
      SetLength(Normals,0);
   if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      SetLength(FaceNormals,NumFaces)
   else
      SetLength(FaceNormals,0);
   if (ColoursType = C_COLOURS_PER_VERTEX) then
      SetLength(Colours,_NumVertices)
   else if (ColoursType = C_COLOURS_PER_FACE) then
      SetLength(Colours,NumFaces)
   else
      SetLength(Colours,0);
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
   AddMaterial;
   Opened := false;
   IsSelected := false;
   Next := -1;
   Son := -1;
   Plugins := nil;
end;

constructor TMesh.Create(const _Mesh : TMesh);
begin
   List := C_LIST_NONE;
   Assign(_Mesh);
end;

constructor TMesh.CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _ShaderBank: PShaderBank; _Quality: integer = C_QUALITY_CUBED);
var
   c : integer;
begin
   ShaderBank := _ShaderBank;
   List := C_LIST_NONE;
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
   SetLength(Faces,0);
   SetLength(Colours,0);
   SetLength(Normals,0);
   SetLength(FaceNormals,0);
   SetLength(TexCoords,0);
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
   VerticesPerFace := 4;
   FaceType := GL_QUADS;
   SetNormalsType(C_NORMALS_PER_FACE);
   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadFromVoxels(_Voxel,_Palette,Vertices,Faces,Colours,Normals,FaceNormals,TexCoords,NumVoxels,NumFaces,VerticesPerFace);
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
   NumVertices,HitCounter : longword;
   VoxelMap: TVoxelMap;
   VertexMap : array of array of array of integer;
   FaceMap : array of array of array of array of integer;
   VertexTransformation: aint32;
   x, y, z, i : longword;
   V : TVoxelUnpacked;
   v1, v2 : boolean;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   VerticesPerFace := 4;
   FaceType := GL_QUADS;
   SetNormalsType(C_NORMALS_PER_FACE);

   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadFromVisibleVoxels(_Voxel,_Palette,Vertices,Faces,Colours,Normals,FaceNormals,TexCoords,NumVoxels,NumFaces,VerticesPerFace);
   MeshGen.Free;

   AddNeighborhoodPlugin;
   CommonVoxelLoadingActions(_Voxel);
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('LoadFromVisibleVoxels for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
var
   MeshGen: TVoxelMeshGenerator;
   NumVertices,HitCounter : longword;
   VoxelMap: TVoxelMap;
   VertexMap : array of array of array of integer;
   FaceMap : array of array of array of array of integer;
   VertexTransformation: aint32;
   x, y, z, i : longword;
   V : TVoxelUnpacked;
   v1, v2 : boolean;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   VerticesPerFace := 3;
   FaceType := GL_TRIANGLES;
   SetNormalsType(C_NORMALS_PER_FACE);

   // This is the complex part of the thing. We'll map all vertices and faces
   // and make a model out of it.
   MeshGen := TVoxelMeshGenerator.Create;
   MeshGen.LoadTrianglesFromVisibleVoxels(_Voxel,_Palette,Vertices,Faces,Colours,Normals,FaceNormals,TexCoords,NumVoxels,NumFaces,VerticesPerFace);
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
   VerticesPerFace := 3;
   FaceType := GL_TRIANGLES;
   ColoursType := C_COLOURS_PER_FACE;
   NormalsType := C_NORMALS_PER_FACE;
   SetLength(TexCoords,0);
   SetLength(Normals,0);
   // Voxel classification stage
   VoxelMap := TVoxelMap.Create(_Voxel,1);
   VoxelMap.GenerateSurfaceMap;
   VoxelMap.MapSemiSurfaces(SemiSurfacesMap);
   // Colour mapping stage
   ColourMap := TVoxelMap.Create(_Voxel,1,C_MODE_COLOUR,C_OUTSIDE_VOLUME);
   // Mesh generation process
   VoxelModelizer := TVoxelModelizer.Create(VoxelMap,SemiSurfacesMap,Vertices,Faces,FaceNormals,Colours,_Palette,ColourMap);
   NumFaces := (High(Faces)+1) div VerticesPerFace;
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
   BoundingBox.Min.X := _Voxel.Tailer.MinBounds[1];
   BoundingBox.Min.Y := _Voxel.Tailer.MinBounds[2];
   BoundingBox.Min.Z := _Voxel.Tailer.MinBounds[3];
   BoundingBox.Max.X := _Voxel.Tailer.MaxBounds[1];
   BoundingBox.Max.Y := _Voxel.Tailer.MaxBounds[2];
   BoundingBox.Max.Z := _Voxel.Tailer.MaxBounds[3];
   Scale.X := (BoundingBox.Max.X - BoundingBox.Min.X) / _Voxel.Tailer.XSize;
   Scale.Y := (BoundingBox.Max.Y - BoundingBox.Min.Y) / _Voxel.Tailer.YSize;
   Scale.Z := (BoundingBox.Max.Z - BoundingBox.Min.Z) / _Voxel.Tailer.ZSize;
   AddMaterial;
   Opened := true;
//   Plugins := nil;
end;

// Mesh Effects.
procedure TMesh.MeshSmooth;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   i,v,v1 : integer;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin: PMeshPluginBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
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
   end;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
   end;
   // Now, let's check each face.
   for v := Low(Vertices) to High(Vertices) do
   begin
      v1 := NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         // add it to the sum.
         Vertices[v].X := Vertices[v].X + OriginalVertexes[v1].X;
         Vertices[v].Y := Vertices[v].Y + OriginalVertexes[v1].Y;
         Vertices[v].Z := Vertices[v].Z + OriginalVertexes[v1].Z;
         inc(HitCounter[v]);

         v1 := NeighborDetector.GetNextNeighbor;
      end;
   end;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HitCounter[v] > 0 then
      begin
         Vertices[v].X := Vertices[v].X / HitCounter[v];
         Vertices[v].Y := Vertices[v].Y / HitCounter[v];
         Vertices[v].Z := Vertices[v].Z / HitCounter[v];
      end;
   end;
   // Free memory
   SetLength(HitCounter,0);
   SetLength(OriginalVertexes,0);
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Smooth for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

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


procedure TMesh.MeshSmoothOperation(_DistanceFunction : TDistanceFunc);
var
   HitCounter: array of single;
   OriginalVertexes : array of TVector3f;
   v,v1 : integer;
   Distance: single;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   // Reset values.
   for v := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[v] := 0;
      OriginalVertexes[v].X := Vertices[v].X;
      OriginalVertexes[v].Y := Vertices[v].Y;
      OriginalVertexes[v].Z := Vertices[v].Z;
      Vertices[v].X := 0;
      Vertices[v].Y := 0;
      Vertices[v].Z := 0;
   end;
   // Sum up vertices with its neighbours, using the desired distance formula.
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
   end;
   for v := Low(Vertices) to High(Vertices) do
   begin
      v1 := NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         Vertices[v].X := Vertices[v].X + (OriginalVertexes[v1].X - OriginalVertexes[v].X);
         Vertices[v].Y := Vertices[v].Y + (OriginalVertexes[v1].Y - OriginalVertexes[v].Y);
         Vertices[v].Z := Vertices[v].Z + (OriginalVertexes[v1].Z - OriginalVertexes[v].Z);

         HitCounter[v] := HitCounter[v] + 1;

         v1 := NeighborDetector.GetNextNeighbor;
      end;
   end;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;

   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Mesh Value (' + FloatToStr(Vertices[v].X) + ', ' + FloatToStr(Vertices[v].Y) + ', ' +FloatToStr(Vertices[v].Z) + ') with ' + FloatToStr(HitCounter[v]) + ' neighbours. Expected frequencies: (' + FloatToStr(Vertices[v].X / HitCounter[v]) + ', ' + FloatToStr(Vertices[v].Y / HitCounter[v]) + ', ' + FloatToStr(Vertices[v].Z / HitCounter[v]) + ')');
      {$endif}
      if HitCounter[v] > 0 then
      begin
         Vertices[v].X := OriginalVertexes[v].X + _DistanceFunction((Vertices[v].X) / HitCounter[v]);
         Vertices[v].Y := OriginalVertexes[v].Y + _DistanceFunction((Vertices[v].Y) / HitCounter[v]);
         Vertices[v].Z := OriginalVertexes[v].Z + _DistanceFunction((Vertices[v].Z) / HitCounter[v]);
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
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Smooth Operation for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.LimitedMeshSmoothOperation(_DistanceFunction : TDistanceFunc);
var
   HitCounter: array of single;
   OriginalVertexes : array of TVector3f;
   v,v1 : integer;
   x,y,z : single;
   Distance: single;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   // Reset values.
   for v := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[v] := 0;
      OriginalVertexes[v].X := Vertices[v].X;
      OriginalVertexes[v].Y := Vertices[v].Y;
      OriginalVertexes[v].Z := Vertices[v].Z;
      Vertices[v].X := 0;
      Vertices[v].Y := 0;
      Vertices[v].Z := 0;
   end;
   // Sum up vertices with its neighbours, using the desired distance formula.
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
   end;
   for v := Low(Vertices) to High(Vertices) do
   begin
      v1 := NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         x := (OriginalVertexes[v1].X - OriginalVertexes[v].X);
         y := (OriginalVertexes[v1].Y - OriginalVertexes[v].Y);
         z := (OriginalVertexes[v1].Z - OriginalVertexes[v].Z);
         Distance := Sqrt((x * x) + (y * y) + (z * z));
         if Distance > 0 then
         begin
            Vertices[v].X := Vertices[v].X + (x/distance);
            Vertices[v].Y := Vertices[v].Y + (y/distance);
            Vertices[v].Z := Vertices[v].Z + (z/distance);

            HitCounter[v] := HitCounter[v] + 1;
         end;
         v1 := NeighborDetector.GetNextNeighbor;
      end;
   end;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;

   // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      {$ifdef MESH_TEST}
      GlobalVars.MeshFile.Add('Mesh Value (' + FloatToStr(Vertices[v].X) + ', ' + FloatToStr(Vertices[v].Y) + ', ' +FloatToStr(Vertices[v].Z) + ') with ' + FloatToStr(HitCounter[v]) + ' neighbours. Expected frequencies: (' + FloatToStr(Vertices[v].X / HitCounter[v]) + ', ' + FloatToStr(Vertices[v].Y / HitCounter[v]) + ', ' + FloatToStr(Vertices[v].Z / HitCounter[v]) + ')');
      {$endif}
      if HitCounter[v] > 0 then
      begin
         Vertices[v].X := OriginalVertexes[v].X + _DistanceFunction((Vertices[v].X / HitCounter[v]));
         Vertices[v].Y := OriginalVertexes[v].Y + _DistanceFunction((Vertices[v].Y / HitCounter[v]));
         Vertices[v].Z := OriginalVertexes[v].Z + _DistanceFunction((Vertices[v].Z / HitCounter[v]));
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
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Smooth Operation for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshGaussianSmooth;
const
   C_2PI = 2 * Pi;
   C_E = 2.718281828;
var
   HitCounter: single;
   OriginalVertexes : array of TVector3f;
   VertexWeight : TVector3f;
   v,v1 : integer;
   Distance: single;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   Deviation: single;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetLength(OriginalVertexes,High(Vertices)+1);
   // Reset values.
   for v := Low(Vertices) to High(Vertices) do
   begin
      OriginalVertexes[v].X := Vertices[v].X;
      OriginalVertexes[v].Y := Vertices[v].Y;
      OriginalVertexes[v].Z := Vertices[v].Z;
   end;
   // Sum up vertices with its neighbours, using the desired distance formula.
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
      end;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
   end;

   // Do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      // get the standard deviation.
      Deviation := 0;
      v1 := NeighborDetector.GetNeighborFromID(v);
      HitCounter := 0;
      VertexWeight.X := 0;
      VertexWeight.Y := 0;
      VertexWeight.Z := 0;
      while v1 <> -1 do
      begin
         Deviation := Deviation + Power(OriginalVertexes[v1].X - OriginalVertexes[v].X,2) + Power(OriginalVertexes[v1].Y - OriginalVertexes[v].Y,2) + Power(OriginalVertexes[v1].Z - OriginalVertexes[v].Z,2);
         HitCounter := HitCounter + 1;

         VertexWeight.X := VertexWeight.X + (OriginalVertexes[v1].X - OriginalVertexes[v].X);
         VertexWeight.Y := VertexWeight.Y + (OriginalVertexes[v1].Y - OriginalVertexes[v].Y);
         VertexWeight.Z := VertexWeight.Z + (OriginalVertexes[v1].Z - OriginalVertexes[v].Z);

         v1 := NeighborDetector.GetNextNeighbor;
      end;
      if HitCounter > 0 then
         Deviation := Sqrt(Deviation / HitCounter);
      // calculate the vertex position.
      if (HitCounter > 0) and (Deviation <> 0) then
      begin
         Distance := ((C_FREQ_NORMALIZER * VertexWeight.X) / HitCounter);
         if Distance > 0 then
            Vertices[v].X := OriginalVertexes[v].X + (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation))
         else if Distance < 0 then
            Vertices[v].X := OriginalVertexes[v].X - (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation));
         Distance := ((C_FREQ_NORMALIZER * VertexWeight.Y) / HitCounter);
         if Distance > 0 then
            Vertices[v].Y := OriginalVertexes[v].Y + (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation))
         else if Distance < 0 then
            Vertices[v].Y := OriginalVertexes[v].Y - (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation));
         Distance := ((C_FREQ_NORMALIZER * VertexWeight.Z) / HitCounter);
         if Distance > 0 then
            Vertices[v].Z := OriginalVertexes[v].Z + (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation))
         else if Distance < 0 then
            Vertices[v].Z := OriginalVertexes[v].Z - (1 / (sqrt(C_2PI) * Deviation)) * Power(C_E,(Distance * Distance) / (-2 * Deviation * Deviation));
      end;
   end;
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Gaussian Smooth for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshUnsharpMasking;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   SetLength(HitCounter,High(Vertices)+1);
   SetLength(OriginalVertexes,High(Vertices)+1);
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
      end;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create;
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
   end;
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
   end;
   // sum all values from neighbors
   for v := Low(Vertices) to High(Vertices) do
   begin
      v1 := NeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         Vertices[v].X := Vertices[v].X + OriginalVertexes[v1].X;
         Vertices[v].Y := Vertices[v].Y + OriginalVertexes[v1].Y;
         Vertices[v].Z := Vertices[v].Z + OriginalVertexes[v1].Z;
         inc(HitCounter[v]);
         v1 := NeighborDetector.GetNextNeighbor;
      end;
   end;
   // Finally, we do the unsharp masking effect here.
   for v := Low(Vertices) to High(Vertices) do
   begin
      if HitCounter[v] > 0 then
      begin
//         Vertices[v].X := (2 * OriginalVertexes[v].X) - (Vertices[v].X / HitCounter[v]);
//         Vertices[v].Y := (2 * OriginalVertexes[v].Y) - (Vertices[v].Y / HitCounter[v]);
//         Vertices[v].Z := (2 * OriginalVertexes[v].Z) - (Vertices[v].Z / HitCounter[v]);
         Vertices[v].X := ((HitCounter[v] + 1) * OriginalVertexes[v].X) - Vertices[v].X;
         Vertices[v].Y := ((HitCounter[v] + 1) * OriginalVertexes[v].Y) - Vertices[v].Y;
         Vertices[v].Z := ((HitCounter[v] + 1) * OriginalVertexes[v].Z) - Vertices[v].Z;
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
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Unsharp Masking for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.MeshDeflate;
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter;

    // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      Temp := (CenterPoint.X - Vertices[v].X) * 0.1;
      if Temp > 0 then
         Vertices[v].X := Vertices[v].X  + Power(Temp,2)
      else
         Vertices[v].X := Vertices[v].X - Power(Temp,2);
      Temp := (CenterPoint.Y - Vertices[v].Y) * 0.1;
      if Temp > 0 then
         Vertices[v].Y := Vertices[v].Y + Power(Temp,2)
      else
         Vertices[v].Y := Vertices[v].Y - Power(Temp,2);
      Temp := (CenterPoint.Z - Vertices[v].Z) * 0.1;
      if Temp > 0 then
         Vertices[v].Z := Vertices[v].Z + Power(Temp,2)
      else
         Vertices[v].Z := Vertices[v].Z - Power(Temp,2);
   end;
   ForceRefresh;
end;

procedure TMesh.MeshInflate;
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter;

    // Finally, we do an average for all vertices.
   for v := Low(Vertices) to High(Vertices) do
   begin
      Temp := (CenterPoint.X - Vertices[v].X) * 0.1;
      if Temp > 0 then
         Vertices[v].X := Vertices[v].X - Power(Temp,2)
      else
         Vertices[v].X := Vertices[v].X + Power(Temp,2);
      Temp := (CenterPoint.Y - Vertices[v].Y) * 0.1;
      if Temp > 0 then
         Vertices[v].Y := Vertices[v].Y - Power(Temp,2)
      else
         Vertices[v].Y := Vertices[v].Y + Power(Temp,2);
      Temp := (CenterPoint.Z - Vertices[v].Z) * 0.1;
      if Temp > 0 then
         Vertices[v].Z := Vertices[v].Z - Power(Temp,2)
      else
         Vertices[v].Z := Vertices[v].Z + Power(Temp,2);
   end;
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
   OriginalColours,VertColours,FaceColours : TAVector4f;
   i : integer;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (ColoursType = C_COLOURS_PER_FACE) then
   begin
      SetLength(OriginalColours,High(Colours)+1);
      SetLength(VertColours,High(Vertices)+1);
      // Reset values.
      for i := Low(Colours) to High(Colours) do
      begin
         OriginalColours[i].X := Colours[i].X;
         OriginalColours[i].Y := Colours[i].Y;
         OriginalColours[i].Z := Colours[i].Z;
         OriginalColours[i].W := Colours[i].W;
         Colours[i].X := 0;
         Colours[i].Y := 0;
         Colours[i].Z := 0;
         Colours[i].W := 0;
      end;
      TransformFaceToVertexColours(VertColours,OriginalColours,_DistanceFunction);
      TransformVertexToFaceColours(VertColours,Colours);
      // Free memory
      SetLength(VertColours,0);
   end
   else if (ColoursType = C_COLOURS_PER_VERTEX) then
   begin
      SetLength(OriginalColours,High(Colours)+1);
      SetLength(FaceColours,NumFaces);
     // Reset values.
      for i := Low(Colours) to High(Colours) do
      begin
         OriginalColours[i].X := Colours[i].X;
         OriginalColours[i].Y := Colours[i].Y;
         OriginalColours[i].Z := Colours[i].Z;
         OriginalColours[i].W := Colours[i].W;
         Colours[i].X := 0;
         Colours[i].Y := 0;
         Colours[i].Z := 0;
         Colours[i].W := 0;
      end;
      TransformVertexToFaceColours(OriginalColours,FaceColours);
      TransformFaceToVertexColours(Colours,FaceColours,_DistanceFunction);
      // Free memory
      SetLength(FaceColours,0);
   end;
   FilterAndFixColours;
   SetLength(OriginalColours,0);
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Apply Colour Smooth for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ConvertFaceToVertexColours(_DistanceFunction : TDistanceFunc);
var
   OriginalColours : TAVector4f;
   i : integer;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (ColoursType = C_COLOURS_PER_FACE) then
   begin
      SetLength(OriginalColours,High(Colours)+1);
      // Reset values.
      for i := Low(Colours) to High(Colours) do
      begin
         OriginalColours[i].X := Colours[i].X;
         OriginalColours[i].Y := Colours[i].Y;
         OriginalColours[i].Z := Colours[i].Z;
         OriginalColours[i].W := Colours[i].W;
      end;
      SetLength(Colours,High(Vertices)+1);
      for i := Low(Colours) to High(Colours) do
      begin
         Colours[i].X := 0;
         Colours[i].Y := 0;
         Colours[i].Z := 0;
         Colours[i].W := 0;
      end;
      TransformFaceToVertexColours(Colours,OriginalColours,_DistanceFunction);
   end;
   FilterAndFixColours;
   SetLength(OriginalColours,0);
   ColourGenStructure := C_COLOURS_PER_VERTEX;
   SetColoursType(C_COLOURS_PER_VERTEX);
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Convert Face To Vertex Colours for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ConvertVertexToFaceColours;
var
   OriginalColours : TAVector4f;
   i : integer;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (ColoursType = C_COLOURS_PER_VERTEX) then
   begin
      SetLength(OriginalColours,High(Colours)+1);
     // Reset values.
      for i := Low(Colours) to High(Colours) do
      begin
         OriginalColours[i].X := Colours[i].X;
         OriginalColours[i].Y := Colours[i].Y;
         OriginalColours[i].Z := Colours[i].Z;
         OriginalColours[i].W := Colours[i].W;
      end;
      SetLength(Colours,NumFaces);
      for i := Low(Colours) to High(Colours) do
      begin
         Colours[i].X := 0;
         Colours[i].Y := 0;
         Colours[i].Z := 0;
         Colours[i].W := 0;
      end;
      TransformVertexToFaceColours(OriginalColours,Colours);
   end;
   FilterAndFixColours;
   SetLength(OriginalColours,0);
   ColourGenStructure := C_COLOURS_PER_FACE;
   SetColoursType(C_COLOURS_PER_FACE);
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Convert Vertex To Face Colours for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.TransformFaceToVertexColours(var _VertColours: TAVector4f; const _FaceColours: TAVector4f; _DistanceFunction : TDistanceFunc);
var
   HitCounter: array of single;
   i,f,v,v1 : integer;
   MaxVerticePerFace: integer;
   MidPoint : TVector3f;
   Distance: single;
begin
   SetLength(HitCounter,High(Vertices)+1);
   for i := Low(HitCounter) to High(HitCounter) do
   begin
      HitCounter[i] := 0;
      _VertColours[i].X := 0;
      _VertColours[i].Y := 0;
      _VertColours[i].Z := 0;
      _VertColours[i].W := 0;
   end;

   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // find central position of the face.
      MidPoint.X := 0;
      MidPoint.Y := 0;
      MidPoint.Z := 0;
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         MidPoint.X := MidPoint.X + Vertices[Faces[v1]].X;
         MidPoint.Y := MidPoint.Y + Vertices[Faces[v1]].Y;
         MidPoint.Z := MidPoint.Z + Vertices[Faces[v1]].Z;
      end;
      MidPoint.X := MidPoint.X / VerticesPerFace;
      MidPoint.Y := MidPoint.Y / VerticesPerFace;
      MidPoint.Z := MidPoint.Z / VerticesPerFace;

      // check all colours from all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         Distance := sqrt(Power(MidPoint.X - Vertices[Faces[v1]].X,2) + Power(MidPoint.Y - Vertices[Faces[v1]].Y,2) + Power(MidPoint.Z - Vertices[Faces[v1]].Z,2));
         Distance := _DistanceFunction(Distance);
         _VertColours[Faces[v1]].X := _VertColours[Faces[v1]].X + (_FaceColours[f].X * Distance);
         _VertColours[Faces[v1]].Y := _VertColours[Faces[v1]].Y + (_FaceColours[f].Y * Distance);
         _VertColours[Faces[v1]].Z := _VertColours[Faces[v1]].Z + (_FaceColours[f].Z * Distance);
         _VertColours[Faces[v1]].W := _VertColours[Faces[v1]].W + (_FaceColours[f].W * Distance);
         HitCounter[Faces[v1]] := HitCounter[Faces[v1]] + Distance;
      end;
   end;
   // Then, we do an average for each vertice.
   for v := Low(_VertColours) to High(_VertColours) do
   begin
      if HitCounter[v] > 0 then
      begin
         _VertColours[v].X := (_VertColours[v].X / HitCounter[v]);
         _VertColours[v].Y := (_VertColours[v].Y / HitCounter[v]);
         _VertColours[v].Z := (_VertColours[v].Z / HitCounter[v]);
         _VertColours[v].W := (_VertColours[v].W / HitCounter[v]);
      end;
   end;
   SetLength(HitCounter,0);
end;

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


procedure TMesh.TransformVertexToFaceColours(const _VertColours: TAVector4f; var _FaceColours: TAVector4f);
var
   f,v,v1,MaxVerticePerFace : integer;
begin
   // Define face colours.
   MaxVerticePerFace := VerticesPerFace - 1;
   for f := 0 to NumFaces-1 do
   begin
      // average all colours from all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         _FaceColours[f].X := _FaceColours[f].X + _VertColours[Faces[v1]].X;
         _FaceColours[f].Y := _FaceColours[f].Y + _VertColours[Faces[v1]].Y;
         _FaceColours[f].Z := _FaceColours[f].Z + _VertColours[Faces[v1]].Z;
         _FaceColours[f].W := _FaceColours[f].W + _VertColours[Faces[v1]].W;
      end;
      // Get result
      _FaceColours[f].X := (_FaceColours[f].X / VerticesPerFace);
      _FaceColours[f].Y := (_FaceColours[f].Y / VerticesPerFace);
      _FaceColours[f].Z := (_FaceColours[f].Z / VerticesPerFace);
      _FaceColours[f].W := (_FaceColours[f].W / VerticesPerFace);
   end;
end;

procedure TMesh.FilterAndFixColours;
var
   i : integer;
begin
   for i := Low(Colours) to High(Colours) do
   begin
      // Avoid problematic colours:
      if Colours[i].X < 0 then
         Colours[i].X := 0
      else if Colours[i].X > 1 then
         Colours[i].X := 1;
      if Colours[i].Y < 0 then
         Colours[i].Y := 0
      else if Colours[i].Y > 1 then
         Colours[i].Y := 1;
      if Colours[i].Z < 0 then
         Colours[i].Z := 0
      else if Colours[i].Z > 1 then
         Colours[i].Z := 1;
      if Colours[i].W < 0 then
         Colours[i].W := 0
      else if Colours[i].W > 1 then
         Colours[i].W := 1;
   end;
end;

procedure TMesh.ColourUnsharpMasking;
var
   HitCounter: array of integer;
   OriginalVertexes : array of TVector3f;
   VertsHit: array of array of boolean;
   i,j,f,v,v1,v2 : integer;
   MaxVerticePerFace: integer;
begin
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
   MaxVerticePerFace := VerticesPerFace - 1;
   // Now, let's check each face.
   for f := 0 to NumFaces-1 do
   begin
      // check all vertexes from the face.
      for v := 0 to MaxVerticePerFace do
      begin
         v1 := (f * VerticesPerFace) + v;
         i := (v + VerticesPerFace - 1) mod VerticesPerFace;
         j := 0;
         // for each vertex, get the previous, the current and the next.
         while j < 3 do
         begin
            v2 := v1 - v + i;
            // if this connection wasn't summed, add it to the sum.
            if not VertsHit[Faces[v1],Faces[v2]] then
            begin
               Vertices[Faces[v1]].X := Vertices[Faces[v1]].X + OriginalVertexes[Faces[v2]].X;
               Vertices[Faces[v1]].Y := Vertices[Faces[v1]].Y + OriginalVertexes[Faces[v2]].Y;
               Vertices[Faces[v1]].Z := Vertices[Faces[v1]].Z + OriginalVertexes[Faces[v2]].Z;
               inc(HitCounter[Faces[v1]]);
               VertsHit[Faces[v1],Faces[v2]] := true;
            end;
            // increment vertex.
            i := (i + 1) mod VerticesPerFace;
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
begin
   if FaceType = GL_QUADS then
      ReNormalizeQuads
   else
      ReNormalizeTriangles;
end;

procedure TMesh.ReNormalizeQuads;
var
   f : integer;
   temp : TVector3f;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if High(FaceNormals) >= 0 then
   begin
      for f := Low(FaceNormals) to High(faceNormals) do
      begin
         FaceNormals[f] := GetNormalsValue(Vertices[Faces[f*4]],Vertices[Faces[(f*4)+1]],Vertices[Faces[(f*4)+2]]);
         Temp := GetNormalsValue(Vertices[Faces[(f*4)+2]],Vertices[Faces[(f*4)+3]],Vertices[Faces[f*4]]);
         FaceNormals[f].X := FaceNormals[f].X + Temp.X;
         FaceNormals[f].Y := FaceNormals[f].Y + Temp.Y;
         FaceNormals[f].Z := FaceNormals[f].Z + Temp.Z;
         Normalize(FaceNormals[f]);
      end;
   end
   else if High(Normals) >= 0 then
   begin
      ReNormalizePerVertex;
   end;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('ReNormalize Quads for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ReNormalizeTriangles;
var
   f : integer;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if High(FaceNormals) >= 0 then
   begin
      for f := Low(FaceNormals) to High(FaceNormals) do
      begin
         FaceNormals[f] := GetNormalsValue(Vertices[Faces[f*3]],Vertices[Faces[(f*3)+1]],Vertices[Faces[(f*3)+2]]);
      end;
   end
   else if High(Normals) >= 0 then
   begin
      ReNormalizePerVertex;
   end;
   ForceRefresh;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('ReNormalize Triangles for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

procedure TMesh.ReNormalizePerVertex;
var
   DifferentNormalsList: array of CVector3fSet;
   i,f,v,Vertex,v1,Value : integer;
   MaxVerticePerFace: integer;
   Normals1,Normals2 : TVector3f;
   Normal : PVector3f;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin: PMeshPluginBase;
   MyFaces: auint32;
   MaxNeighbors: integer;
begin
   SetLength(DifferentNormalsList,High(Vertices)+1);
   SetLength(Normals,High(Vertices)+1);
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
         MyFaces := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaces;
         MaxNeighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount - 1;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
         MyFaces := Faces;
         MaxNeighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount - 1;
      end;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
      MyFaces := Faces;
      MaxNeighbors := High(Vertices);
   end;

   // Reset values.
   for i := Low(DifferentNormalsList) to High(DifferentNormalsList) do
   begin
      DifferentNormalsList[i] := CVector3fSet.Create;
      Normals[i].X := 0;
      Normals[i].Y := 0;
      Normals[i].Z := 0;
   end;
   MaxVerticePerFace := VerticesPerFace - 1;
   v1 := 0;
   // Now, let's check each vertex and calculate the normals with the neighborhood.
   if MaxVerticePerFace = 2 then
   begin
      for v := Low(Vertices) to MaxNeighbors do
      begin
         Value := NeighborDetector.GetNeighborFromID(v);
         while Value <> -1 do
         begin
            v1 := Value * 3;
            Normal := new (PVector3f);
            Normal^ := GetNormalsValue(Vertices[MyFaces[v1]],Vertices[MyFaces[v1+1]],Vertices[MyFaces[v1+2]]);
            if DifferentNormalsList[v].Add(Normal) then
            begin
               Normals[v].X := Normals[v].X + Normal^.X;
               Normals[v].Y := Normals[v].Y + Normal^.Y;
               Normals[v].Z := Normals[v].Z + Normal^.Z;
            end;
            Value := NeighborDetector.GetNextNeighbor;
         end;
         if not DifferentNormalsList[v].isEmpty then
         begin
            Normalize(Normals[v]);
         end;
         DifferentNormalsList[v].Free;
      end;
      for v := MaxNeighbors + 1 to High(Vertices) do
      begin
         Vertex := TNeighborhoodDataPlugin(NeighborhoodPlugin^).GetEquivalentVertex(v);
         Normals[v].X := Normals[Vertex].X;
         Normals[v].Y := Normals[Vertex].Y;
         Normals[v].Z := Normals[Vertex].Z;
      end;
   end
   else
   begin
      for v := Low(Vertices) to High(Vertices) do
      begin
         if v  > MaxNeighbors then
         begin
            Vertex := TNeighborhoodDataPlugin(NeighborhoodPlugin^).GetEquivalentVertex(v);
         end
         else
         begin
            Vertex := v;
         end;
         Value := NeighborDetector.GetNeighborFromID(Vertex);
         while Value <> -1 do
         begin
            v1 := Value * 4;
            Normals1 := GetNormalsValue(Vertices[MyFaces[v1]],Vertices[MyFaces[v1+1]],Vertices[MyFaces[v1+2]]);
            Normals2 := GetNormalsValue(Vertices[MyFaces[v1+2]],Vertices[MyFaces[v1+3]],Vertices[MyFaces[v1]]);
            Normal := new (PVector3f);
            Normal^.X := ((Normals1.X + Normals2.X) / 2);
            Normal^.Y := ((Normals1.Y + Normals2.Y) / 2);
            Normal^.Z := ((Normals1.Z + Normals2.Z) / 2);
            if DifferentNormalsList[v].Add(Normal) then
            begin
               Normals[v].X := Normals[v].X + Normal^.X;
               Normals[v].Y := Normals[v].Y + Normal^.Y;
               Normals[v].Z := Normals[v].Z + Normal^.Z;
            end;
            Value := NeighborDetector.GetNextNeighbor;
         end;
         if not DifferentNormalsList[v].isEmpty then
         begin
            Normalize(Normals[v]);
         end;
         DifferentNormalsList[v].Free;
      end;
   end;
   // Free memory
   SetLength(DifferentNormalsList,0);
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
end;

procedure TMesh.ReNormalizeFaces;
var
   f,face : integer;
   temp : TVector3f;
begin
   if High(FaceNormals) >= 0 then
   begin
      if VerticesPerFace = 3 then
      begin
         for f := Low(FaceNormals) to High(FaceNormals) do
         begin
            face := f * 3;
            FaceNormals[f] := GetNormalsValue(Vertices[Faces[face]],Vertices[Faces[face+1]],Vertices[Faces[face+2]]);
         end;
      end
      else if VerticesPerFace = 4 then
      begin
         for f := Low(FaceNormals) to High(faceNormals) do
         begin
            face := f * 4;
            FaceNormals[f] := GetNormalsValue(Vertices[Faces[face]],Vertices[Faces[face+1]],Vertices[Faces[face+2]]);
            Temp := GetNormalsValue(Vertices[Faces[face+2]],Vertices[Faces[face+3]],Vertices[Faces[face]]);
            FaceNormals[f].X := FaceNormals[f].X + Temp.X;
            FaceNormals[f].Y := FaceNormals[f].Y + Temp.Y;
            FaceNormals[f].Z := FaceNormals[f].Z + Temp.Z;
            Normalize(FaceNormals[f]);
         end;
      end;
   end;
end;

procedure TMesh.RebuildFaceNormals;
begin
   SetLength(FaceNormals,NumFaces);
   ReNormalizeFaces;
end;


procedure TMesh.TransformFaceToVertexNormals;
var
   DifferentNormalsList: array of CVector3fSet;
   i,v,Value : integer;
   Normal : PVector3f;
   NeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   MyNormals : TAVector3f;
begin
   SetLength(DifferentNormalsList,High(Vertices)+1);
   SetLength(Normals,High(Vertices)+1);
   // Reset values.
   for i := Low(DifferentNormalsList) to High(DifferentNormalsList) do
   begin
      DifferentNormalsList[i] := CVector3fSet.Create;
      Normals[i].X := 0;
      Normals[i].Y := 0;
      Normals[i].Z := 0;
   end;
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
         MyNormals := FaceNormals;
      end;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
      MyNormals := FaceNormals;
   end;
   // Now, let's check each vertex.
   for v := Low(Vertices) to High(Vertices) do
   begin
      Value := NeighborDetector.GetNeighborFromID(v);
      while Value <> -1 do
      begin
         Normal := new(PVector3f);
         Normal^.X := MyNormals[Value].X;
         Normal^.Y := MyNormals[Value].Y;
         Normal^.Z := MyNormals[Value].Z;
         if DifferentNormalsList[v].Add(Normal) then
         begin
            Normals[v].X := Normals[v].X + Normal^.X;
            Normals[v].Y := Normals[v].Y + Normal^.Y;
            Normals[v].Z := Normals[v].Z + Normal^.Z;
         end;
         Value := NeighborDetector.GetNextNeighbor;
      end;
      if not DifferentNormalsList[v].isEmpty then
      begin
         Normalize(Normals[v]);
      end;
      DifferentNormalsList[v].Free;
   end;
   // Free memory
   SetLength(DifferentNormalsList,0);
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
      if High(FaceNormals) >= 0 then
      begin
         TransformFaceToVertexNormals;
         SetLength(FaceNormals,0);
      end
      else
      begin
         ReNormalizePerVertex;
      end;
      SetRenderingProcedure;
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
   i,Value : integer;
   NormalsHandicap : TAVector3f;
   HitCounter : array of single;
   Distance: single;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   // Setup Neighbors.
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if (NormalsType and C_NORMALS_PER_FACE) = 0 then
   begin
      if NeighborhoodPlugin <> nil then
      begin
         Neighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      end
      else
      begin
         Neighbors := TNeighborDetector.Create;
         Neighbors.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
      end;
      // Setup Normals Handicap and Hit Counter.
      SetLength(NormalsHandicap,High(Normals)+1);
      SetLength(HitCounter,High(Normals)+1);
      for i := Low(NormalsHandicap) to High(NormalsHandicap) do
      begin
         NormalsHandicap[i].X := 0;
         NormalsHandicap[i].Y := 0;
         NormalsHandicap[i].Z := 0;
         HitCounter[i] := 0;
      end;
      // Main loop goes here.
      for i := Low(Vertices) to High(Vertices) do
      begin
         Value := Neighbors.GetNeighborFromID(i);
         while Value <> -1 do
         begin
            Distance := Vertices[Value].X - Vertices[i].X;
            if Distance <> 0 then
               NormalsHandicap[i].X := NormalsHandicap[i].X + (Normals[Value].X * _DistanceFunction(Distance));
            Distance := Vertices[Value].Y - Vertices[i].Y;
            if Distance <> 0 then
               NormalsHandicap[i].Y := NormalsHandicap[i].Y + (Normals[Value].Y * _DistanceFunction(Distance));
            Distance := Vertices[Value].Z - Vertices[i].Z;
            if Distance <> 0 then
               NormalsHandicap[i].Z := NormalsHandicap[i].Z + (Normals[Value].Z * _DistanceFunction(Distance));
            HitCounter[i] := HitCounter[i] + 1;
            Value := Neighbors.GetNextNeighbor;
         end;
      end;
      // Finally, we do an average for all vertices.
      for i := Low(Vertices) to High(Vertices) do
      begin
         if HitCounter[i] > 0 then
         begin
            Normals[i].X := Normals[i].X + (NormalsHandicap[i].X / HitCounter[i]);
            Normals[i].Y := Normals[i].Y + (NormalsHandicap[i].Y / HitCounter[i]);
            Normals[i].Z := Normals[i].Z + (NormalsHandicap[i].Z / HitCounter[i]);
            Normalize(Normals[i]);
         end;
      end;
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
         Neighbors.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
      end;
      // Get neighbor faces from faces.
      Neighbors.NeighborType := C_NEIGHBTYPE_FACE_FACE_FROM_EDGE;
      Neighbors.BuildUpData(Faces,VerticesPerFace,High(Vertices)+1);
      // Setup Normals Handicap.
      SetLength(NormalsHandicap,High(FaceNormals)+1);
      SetLength(HitCounter,High(FaceNormals)+1);
      for i := Low(NormalsHandicap) to High(NormalsHandicap) do
      begin
         NormalsHandicap[i].X := 0;
         NormalsHandicap[i].Y := 0;
         NormalsHandicap[i].Z := 0;
         HitCounter[i] := 0;
      end;
      // Main loop goes here.
      for i := Low(NormalsHandicap) to High(NormalsHandicap) do
      begin
         Value := Neighbors.GetNeighborFromID(i);
         while Value <> -1 do
         begin
            Distance := Vertices[Value].X - Vertices[i].X;
            if Distance <> 0 then
               NormalsHandicap[i].X := NormalsHandicap[i].X + (FaceNormals[Value].X * _DistanceFunction(Distance));
            Distance := Vertices[Value].Y - Vertices[i].Y;
            if Distance <> 0 then
               NormalsHandicap[i].Y := NormalsHandicap[i].Y + (FaceNormals[Value].Y * _DistanceFunction(Distance));
            Distance := Vertices[Value].Z - Vertices[i].Z;
            if Distance <> 0 then
               NormalsHandicap[i].Z := NormalsHandicap[i].Z + (FaceNormals[Value].Z * _DistanceFunction(Distance));
            Distance := sqrt(Power(Vertices[Value].X - Vertices[i].X,2) + Power(Vertices[Value].Y - Vertices[i].Y,2) + Power(Vertices[Value].Z - Vertices[i].Z,2));
            HitCounter[i] := HitCounter[i] + Distance;
            Value := Neighbors.GetNextNeighbor;
         end;
      end;
      // Finally, we do an average for all vertices.
      for i := Low(FaceNormals) to High(FaceNormals) do
      begin
         if HitCounter[i] > 0 then
         begin
            FaceNormals[i].X := FaceNormals[i].X + (NormalsHandicap[i].X / HitCounter[i]);
            FaceNormals[i].Y := FaceNormals[i].Y + (NormalsHandicap[i].Y / HitCounter[i]);
            FaceNormals[i].Z := FaceNormals[i].Z + (NormalsHandicap[i].Z / HitCounter[i]);
            Normalize(FaceNormals[i]);
         end;
      end;
   end;

   // Free memory
   SetLength(NormalsHandicap,0);
   SetLength(HitCounter,0);
   Neighbors.Free;
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
   TexGenerator := CTextureGenerator.Create;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   TexCoords := TexGenerator.GetTextureCoordinates(Vertices,FaceNormals,Normals,Colours,Faces,NeighborhoodPlugin,VerticesPerFace);
   if NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(NeighborhoodPlugin^).DeactivateQuadFaces;
   end;
   ClearMaterials;
   AddMaterial;
   SetLength(Materials[0].Texture,1);
   glActiveTextureARB(GL_TEXTURE0_ARB);
   Bitmap := TexGenerator.GenerateDiffuseTexture(Faces,Colours,TexCoords,VerticesPerFace,1024,AlphaMap);
   Materials[0].Texture[0] := GlobalVars.TextureBank.Add(Bitmap,AlphaMap);
   Materials[0].Texture[0]^.TextureType := C_TTP_DIFFUSE;
   SetLength(AlphaMap,0,0);
   Bitmap.Free;
   if ShaderBank <> nil then
      Materials[0].Shader := ShaderBank^.Get(C_SHD_PHONG_1TEX)
   else
      Materials[0].Shader := nil;
   SetColoursType(C_COLOURS_FROM_TEXTURE);
   SetLength(FaceNormals,0);
   TexGenerator.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Texture atlas extraction for ' + Name + ' takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

// This function gets a temporary set of coordinates that might become real texture coordinates later on.
procedure TMesh.GetMeshSeeds(_MeshID: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexGenerator: CTextureGenerator);
var
   NeighborhoodPlugin: PMeshPluginBase;
begin
   RebuildFaceNormals;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   TexCoords := _TexGenerator.GetMeshSeeds(_MeshID,Vertices,FaceNormals,Normals,Colours,Faces,VerticesPerFace,_Seeds,_VertsSeed,NeighborhoodPlugin);
   if NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(NeighborhoodPlugin^).DeactivateQuadFaces;
   end;
   SetLength(FaceNormals,0);
end;

// This one really acquires the final texture coordinates values.
procedure TMesh.GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexGenerator: CTextureGenerator);
begin
   _TexGenerator.GetFinalTextureCoordinates(_Seeds,_VertsSeed,TexCoords);
end;

procedure TMesh.PaintMeshDiffuseTexture(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _TexGenerator: CTextureGenerator);
begin
   _TexGenerator.PaintMeshDiffuseTexture(Faces,Colours,TexCoords,VerticesPerFace,_Buffer,_WeightBuffer);
end;

procedure TMesh.PaintMeshNormalMapTexture(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _TexGenerator: CTextureGenerator);
begin
   _TexGenerator.PaintMeshNormalMapTexture(Faces,Normals,TexCoords,VerticesPerFace,_Buffer,_WeightBuffer);
end;

procedure TMesh.PaintMeshBumpMapTexture(var _Buffer: T2DFrameBuffer; var _TexGenerator: CTextureGenerator);
var
   DiffuseBitmap: TBitmap;
   Mat: integer;
begin
   DiffuseBitmap := Materials[0].GetTexture(C_TTP_DIFFUSE);
   _TexGenerator.PaintMeshBumpMapTexture(Faces,Normals,TexCoords,VerticesPerFace,_Buffer,DiffuseBitmap);
   DiffuseBitmap.Free;
   AddBumpMapDataPlugin;
end;

procedure TMesh.AddTextureToMesh(_MaterialID, _TextureType, _ShaderID: integer; _Texture:PTextureBankItem);
var
   i : integer;
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
   SetColoursType(C_COLOURS_FROM_TEXTURE);
end;

procedure TMesh.ExportTextures(const _BaseDir, _Ext : string; var _UsedTextures : CIntegerSet);
var
   mat, tex: integer;
begin
   for mat := Low(Materials) to High(Materials) do
   begin
      Materials[mat].ExportTextures(_BaseDir,Name + '_' + IntToStr(ID) + '_' + IntToStr(mat),_Ext,_UsedTextures);
   end;
end;

// Sets
procedure TMesh.SetRenderingProcedure;
begin
   case (NormalsType) of
      C_NORMALS_DISABLED:
      begin
         case (ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := RenderWithoutNormalsAndColours;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := RenderWithoutNormalsAndWithColoursPerVertex;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := RenderWithoutNormalsAndWithFaceColours;
            end;
            C_COLOURS_FROM_TEXTURE:
            begin
               RenderingProcedure := RenderWithoutNormalsAndWithTexture;
            end;
         end;
      end;
      C_NORMALS_PER_VERTEX:
      begin
         case (ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndNoColours;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndColours;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndFaceColours;
            end;
            C_COLOURS_FROM_TEXTURE:
            begin
               RenderingProcedure := RenderWithVertexNormalsAndWithTexture;
            end;
         end;
      end;
      C_NORMALS_PER_FACE:
      begin
         case (ColoursType) of
            C_COLOURS_DISABLED:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndNoColours;
            end;
            C_COLOURS_PER_VERTEX:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndVertexColours;
            end;
            C_COLOURS_PER_FACE:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndColours;
            end;
            C_COLOURS_FROM_TEXTURE:
            begin
               RenderingProcedure := RenderWithFaceNormalsAndWithTexture;
            end;
         end;
      end;
   end;
   ForceRefresh;
end;

procedure TMesh.SetColoursType(_ColoursType: integer);
begin
   ColoursType := _ColoursType and 3;
   SetRenderingProcedure;
end;

procedure TMesh.ForceColoursRendering;
begin
   ColoursType := ColourGenStructure;
   SetRenderingProcedure;
end;

procedure TMesh.SetNormalsType(_NormalsType: integer);
begin
   NormalsType := _NormalsType and 3;
   SetRenderingProcedure;
end;

procedure TMesh.SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
begin
   ColoursType := _ColoursType and 3;
   NormalsType := _NormalsType and 3;
   SetRenderingProcedure;
end;

// Gets
function TMesh.IsOpened: boolean;
begin
   Result := Opened;
end;


// Rendering methods.
procedure TMesh.Render(var _PolyCount,_VoxelCount: longword);
var
   Plugin: PMeshPluginBase;
begin
   if IsVisible and Opened then
   begin
      inc(_PolyCount,NumFaces);
      inc(_VoxelCount,NumVoxels);
      if List = C_LIST_NONE then
      begin
         List := glGenLists(1);
         glNewList(List, GL_COMPILE);
         CurrentPass := Low(Materials);
         while CurrentPass <= High(Materials) do
         begin
            Materials[CurrentPass].Enable;
            RenderingProcedure();
            Materials[CurrentPass].Disable;
            inc(CurrentPass);
         end;
         glEndList;
      end;
      // Move accordingly to the bounding box position.
      glTranslatef(BoundingBox.Min.X, BoundingBox.Min.Y, BoundingBox.Min.Z);
      glCallList(List);
      Plugin := Plugins;
      while Plugin <> nil do
      begin
         Plugin^.Render;
         Plugin := Plugin^.Next;
      end;
   end;
end;

procedure TMesh.RenderWithoutNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor4f(0.5,0.5,0.5,C_TRP_OPAQUE);
   glNormal3f(0,0,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithVertexNormalsAndNoColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor4f(0.5,0.5,0.5,C_TRP_OPAQUE);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithFaceNormalsAndNoColours;
var
   i,f,v : longword;
begin
   f := 0;
   glColor4f(0.5,0.5,0.5,C_TRP_OPAQUE);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithoutNormalsAndWithColoursPerVertex;
var
   i,f,v : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glColor4f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z,Colours[Faces[f]].W);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithVertexNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glActiveTextureARB(GL_TEXTURE0_ARB);
   glDisable(GL_TEXTURE_2D);
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            glColor4f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z,Colours[Faces[f]].W);
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithFaceNormalsAndVertexColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glColor4f(Colours[Faces[f]].X,Colours[Faces[f]].Y,Colours[Faces[f]].Z,Colours[Faces[f]].W);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithoutNormalsAndWithTexture;
var
   i,f,v,tex : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   glColor4f(1,1,1,1);
   i := 0;
   for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
   begin
      if Materials[CurrentPass].Texture[tex] <> nil then
      begin
         glActiveTextureARB(GL_TEXTURE0_ARB + tex);
         glBindTexture(GL_TEXTURE_2D,Materials[CurrentPass].Texture[tex]^.GetID);
         glEnable(GL_TEXTURE_2D);
      end;
   end;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
            begin
               glMultiTexCoord2fARB(GL_TEXTURE0_ARB + tex,TexCoords[Faces[f]].U,TexCoords[Faces[f]].V);
            end;
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
   for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
   begin
      if Materials[CurrentPass].Texture[tex] <> nil then
      begin
         glActiveTextureARB(GL_TEXTURE0_ARB + tex);
         glBindTexture(GL_TEXTURE_2D,Materials[CurrentPass].Texture[tex]^.GetID);
         glDisable(GL_TEXTURE_2D);
      end;
   end;
end;

procedure TMesh.RenderWithVertexNormalsAndWithTexture;
var
   i,f,v,tex : longword;
begin
   f := 0;
   i := 0;
   glColor4f(1,1,1,1);
   for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
   begin
      if Materials[CurrentPass].Texture[tex] <> nil then
      begin
         glActiveTextureARB(GL_TEXTURE0_ARB + tex);
         glBindTexture(GL_TEXTURE_2D,Materials[CurrentPass].Texture[tex]^.GetID);
         glEnable(GL_TEXTURE_2D);
      end;
   end;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         while (v < VerticesPerFace) do
         begin
            for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
            begin
               glMultiTexCoord2fARB(GL_TEXTURE0_ARB + tex,TexCoords[Faces[f]].U,TexCoords[Faces[f]].V);
            end;
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
   for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
   begin
      if Materials[CurrentPass].Texture[tex] <> nil then
      begin
         glActiveTextureARB(GL_TEXTURE0_ARB + tex);
         glBindTexture(GL_TEXTURE_2D,Materials[CurrentPass].Texture[tex]^.GetID);
         glDisable(GL_TEXTURE_2D);
      end;
   end;
end;

procedure TMesh.RenderWithFaceNormalsAndWithTexture;
var
   i,f,v,tex : longword;
begin
   f := 0;
   i := 0;
   glColor4f(1,1,1,1);
   for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
   begin
      if Materials[CurrentPass].Texture[tex] <> nil then
      begin
         glActiveTextureARB(GL_TEXTURE0_ARB + tex);
         glBindTexture(GL_TEXTURE_2D,Materials[CurrentPass].Texture[tex]^.GetID);
         glEnable(GL_TEXTURE_2D);
      end;
   end;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
            begin
               glMultiTexCoord2fARB(GL_TEXTURE0_ARB + tex,TexCoords[Faces[f]].U,TexCoords[Faces[f]].V);
            end;
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
   for tex := Low(Materials[CurrentPass].Texture) to High(Materials[CurrentPass].Texture) do
   begin
      if Materials[CurrentPass].Texture[tex] <> nil then
      begin
         glActiveTextureARB(GL_TEXTURE0_ARB + tex);
         glBindTexture(GL_TEXTURE_2D,Materials[CurrentPass].Texture[tex]^.GetID);
         glDisable(GL_TEXTURE_2D);
      end;
   end;
end;

procedure TMesh.RenderWithoutNormalsAndWithFaceColours;
var
   i,f,v : longword;
begin
   f := 0;
   glNormal3f(0,0,0);
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glColor4f(Colours[i].X,Colours[i].Y,Colours[i].Z,Colours[i].W);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithVertexNormalsAndFaceColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glColor4f(Colours[i].X,Colours[i].Y,Colours[i].Z,Colours[i].W);
         while (v < VerticesPerFace) do
         begin
            glNormal3f(Normals[Faces[f]].X,Normals[Faces[f]].Y,Normals[Faces[f]].Z);
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

procedure TMesh.RenderWithFaceNormalsAndColours;
var
   i,f,v : longword;
begin
   f := 0;
   i := 0;
   glBegin(FaceType);
      while i < NumFaces do
      begin
         v := 0;
         glColor4f(Colours[i].X,Colours[i].Y,Colours[i].Z,Colours[i].W);
         glNormal3f(FaceNormals[i].X,FaceNormals[i].Y,FaceNormals[i].Z);
         while (v < VerticesPerFace) do
         begin
            glVertex3f(Vertices[Faces[f]].X,Vertices[Faces[f]].Y,Vertices[Faces[f]].Z);
            inc(v);
            inc(f);
         end;
         inc(i);
      end;
   glEnd();
end;

// Basically clears the OpenGL List, so the RenderingProcedure may run next time it renders the mesh.
procedure TMesh.ForceRefresh;
var
   Plugin: PMeshPluginBase;
begin
   if List > C_LIST_NONE then
   begin
      glDeleteLists(List,1);
   end;
   List := C_LIST_NONE;
   Plugin := Plugins;
   while Plugin <> nil do
   begin
      Plugin^.Update(Addr(self));
      Plugin := Plugin^.Next;
   end;
end;

// Copies
procedure TMesh.Assign(const _Mesh : TMesh);
var
   i : integer;
begin
   ShaderBank := _Mesh.ShaderBank;
   NormalsType := _Mesh.NormalsType;
   ColoursType := _Mesh.ColoursType;
   TransparencyLevel := _Mesh.TransparencyLevel;
   Opened := _Mesh.Opened;
   Name := CopyString(_Mesh.Name);
   ID := _Mesh.ID;
   Son := _Mesh.Son;
   FaceType := _Mesh.FaceType;
   VerticesPerFace := _Mesh.VerticesPerFace;
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
   SetLength(Faces,High(_Mesh.Faces)+1);
   for i := Low(Faces) to High(Faces) do
   begin
      Faces[i] := _Mesh.Faces[i];
   end;
   SetLength(Normals,High(_Mesh.Normals)+1);
   for i := Low(Normals) to High(Normals) do
   begin
      Normals[i].X := _Mesh.Normals[i].X;
      Normals[i].Y := _Mesh.Normals[i].Y;
      Normals[i].Z := _Mesh.Normals[i].Z;
   end;
   SetLength(FaceNormals,High(_Mesh.FaceNormals)+1);
   for i := Low(FaceNormals) to High(FaceNormals) do
   begin
      FaceNormals[i].X := _Mesh.FaceNormals[i].X;
      FaceNormals[i].Y := _Mesh.FaceNormals[i].Y;
      FaceNormals[i].Z := _Mesh.FaceNormals[i].Z;
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
   i,j : integer;
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
   i, j: integer;
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


// Plugins
procedure TMesh.AddNormalsPlugin;
var
   NewPlugin,Plugin : PMeshPluginBase;
begin
   new(NewPlugin);
   NewPlugin^ := TNormalsMeshPlugin.Create();
   Plugin := Plugins;
   if Plugin <> nil then
   begin
      while Plugin^.Next <> nil do
      begin
         Plugin := Plugin^.Next;
      end;
      Plugin^.Next := NewPlugin;
   end
   else
   begin
      Plugins := NewPlugin;
   end;
   ForceRefresh;
end;

procedure TMesh.AddNeighborhoodPlugin;
var
   NewPlugin,Plugin : PMeshPluginBase;
begin
   new(NewPlugin);
   NewPlugin^ := TNeighborhoodDataPlugin.Create(Faces,VerticesPerFace,High(Vertices)+1);
   Plugin := Plugins;
   if Plugin <> nil then
   begin
      while Plugin^.Next <> nil do
      begin
         Plugin := Plugin^.Next;
      end;
      Plugin^.Next := NewPlugin;
   end
   else
   begin
      Plugins := NewPlugin;
   end;
   ForceRefresh;
end;

procedure TMesh.AddBumpMapDataPlugin;
var
   NewPlugin,Plugin : PMeshPluginBase;
begin
   new(NewPlugin);
   NewPlugin^ := TBumpMapDataPlugin.Create(Vertices,Normals,TexCoords,Faces,VerticesPerFace);
   Plugin := Plugins;
   if Plugin <> nil then
   begin
      while Plugin^.Next <> nil do
      begin
         Plugin := Plugin^.Next;
      end;
      Plugin^.Next := NewPlugin;
   end
   else
   begin
      Plugins := NewPlugin;
   end;
   ForceRefresh;
end;


procedure TMesh.RemovePlugin(_PluginType: integer);
var
   Plugin,DisposedPlugin : PMeshPluginBase;
begin
   Plugin := Plugins;
   while Plugin <> nil do
   begin
      DisposedPlugin := Plugin;
      Plugin := Plugin^.Next;
      if DisposedPlugin^.PluginType = _PluginType then
      begin
         if DisposedPlugin = Plugins then
            Plugins := Plugin;
         DisposedPlugin^.Free;
         DisposedPlugin := nil;
      end;
   end;
   ForceRefresh;
end;

procedure TMesh.ClearPlugins;
var
   Plugin,DisposedPlugin : PMeshPluginBase;
begin
   Plugin := Plugins;
   while Plugin <> nil do
   begin
      DisposedPlugin := Plugin;
      Plugin := Plugin^.Next;
      DisposedPlugin^.Free;
      DisposedPlugin := nil;
   end;
   Plugins := nil;
end;

function TMesh.IsPluginEnabled(_PluginType: integer): boolean;
var
   Plugin : PMeshPluginBase;
begin
   Result := false;
   Plugin := Plugins;
   while Plugin <> nil do
   begin
      if Plugin^.PluginType = _PluginType then
      begin
         Result := true;
         exit;
      end;
      Plugin := Plugin^.Next;
   end;
end;

function TMesh.GetPlugin(_PluginType: integer): PMeshPluginBase;
var
   Plugin : PMeshPluginBase;
begin
   Plugin := Plugins;
   while Plugin <> nil do
   begin
      if Plugin^.PluginType = _PluginType then
      begin
         Result := Plugin;
         exit;
      end;
      Plugin := Plugin^.Next;
   end;
   Result := nil;
end;


// Miscelaneous
procedure TMesh.OverrideTransparency;
var
   c : integer;
begin
   for c := Low(Colours) to High(Colours) do
   begin
      Colours[c].W := TransparencyLevel;
   end;
end;

procedure TMesh.ForceTransparencyLevel(_TransparencyLevel : single);
begin
   TransparencyLevel := _TransparencyLevel;
   OverrideTransparency;
   ForceRefresh;
end;

function TMesh.FindMeshCenter: TVector3f;
var
   v : integer;
   MaxPoint,MinPoint: TVector3f;
begin
   if High(Vertices) >= 0 then
   begin
      MinPoint.X := Vertices[0].X;
      MinPoint.Y := Vertices[0].Y;
      MinPoint.Z := Vertices[0].Z;
      MaxPoint.X := Vertices[0].X;
      MaxPoint.Y := Vertices[0].Y;
      MaxPoint.Z := Vertices[0].Z;
      // Find mesh scope.
      for v := Low(Vertices) to High(Vertices) do
      begin
         if (Vertices[v].X < MinPoint.X) and (Vertices[v].X <> -NAN) then
         begin
            MinPoint.X := Vertices[v].X;
         end;
         if Vertices[v].X > MaxPoint.X then
         begin
            MaxPoint.X := Vertices[v].X;
         end;
         if (Vertices[v].Y < MinPoint.Y) and (Vertices[v].Y <> -NAN) then
         begin
            MinPoint.Y := Vertices[v].Y;
         end;
         if Vertices[v].Y > MaxPoint.Y then
         begin
            MaxPoint.Y := Vertices[v].Y;
         end;
         if (Vertices[v].Z < MinPoint.Z) and (Vertices[v].Z <> -NAN) then
         begin
            MinPoint.Z := Vertices[v].Z;
         end;
         if Vertices[v].Z > MaxPoint.Z then
         begin
            MaxPoint.Z := Vertices[v].Z;
         end;
      end;
      Result.X := (MinPoint.X + MaxPoint.X) / 2;
      Result.Y := (MinPoint.Y + MaxPoint.Y) / 2;
      Result.Z := (MinPoint.Z + MaxPoint.Z) / 2;
   end
   else
   begin
      Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
   end;
end;

procedure TMesh.RemoveInvisibleFaces;
var
   iRead,iWrite,v: integer;
   MarkForRemoval: boolean;
   Normal : TVector3f;
begin
   iRead := 0;
   iWrite := 0;
   while iRead <= High(Faces) do
   begin
      MarkForRemoval := false;
      // check if vertexes are NaN.
      v := 0;
      while v < VerticesPerFace do
      begin
         if IsNaN(Vertices[Faces[iRead+v]].X) or IsNaN(Vertices[Faces[iRead+v]].Y) or IsNaN(Vertices[Faces[iRead+v]].Z) or IsInfinite(Vertices[Faces[iRead+v]].X) or IsInfinite(Vertices[Faces[iRead+v]].Y) or IsInfinite(Vertices[Faces[iRead+v]].Z) then
         begin
            MarkForRemoval := true;
         end;
         inc(v);
      end;
      if not MarkForRemoval then
      begin
         // check if normal is 0,0,0.
         Normal := GetNormalsValue(Vertices[Faces[iRead]],Vertices[Faces[iRead+1]],Vertices[Faces[iRead+2]]);
         if (Normal.X = 0) and (Normal.Y = 0) and (Normal.Z = 0) then
            MarkForRemoval := true;
         if VerticesPerFace = 4 then
         begin
            Normal := GetNormalsValue(Vertices[Faces[iRead+2]],Vertices[Faces[iRead+3]],Vertices[Faces[iRead]]);
            if (Normal.X = 0) and (Normal.Y = 0) and (Normal.Z = 0) then
               MarkForRemoval := true;
          end;
      end;

      // Finally, we remove it.
      if not MarkForRemoval then
      begin
         v := 0;
         while v < VerticesPerFace do
         begin
            Faces[iWrite+v] := Faces[iRead+v];
            inc(v);
         end;
         if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
         begin
            FaceNormals[iWrite div VerticesPerFace].X := FaceNormals[iRead div VerticesPerFace].X;
            FaceNormals[iWrite div VerticesPerFace].Y := FaceNormals[iRead div VerticesPerFace].Y;
            FaceNormals[iWrite div VerticesPerFace].Z := FaceNormals[iRead div VerticesPerFace].Z;
         end;
         if (ColoursType = C_COLOURS_PER_FACE) then
         begin
            Colours[iWrite div VerticesPerFace].X := Colours[iRead div VerticesPerFace].X;
            Colours[iWrite div VerticesPerFace].Y := Colours[iRead div VerticesPerFace].Y;
            Colours[iWrite div VerticesPerFace].Z := Colours[iRead div VerticesPerFace].Z;
            Colours[iWrite div VerticesPerFace].W := Colours[iRead div VerticesPerFace].W;
         end;
         iWrite := iWrite + VerticesPerFace;
      end;
      iRead := iRead + VerticesPerFace;
   end;
   NumFaces := iWrite div VerticesPerFace;
   SetLength(Faces,iWrite);
   if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
   begin
      SetLength(FaceNormals,NumFaces);
   end;
   if (ColoursType = C_COLOURS_PER_FACE) then
   begin
      SetLength(Colours,NumFaces);
   end;
   ForceRefresh;
end;

procedure TMesh.ConvertQuadsToTris;
var
   OldFaces: auint32;
   OldFaceNormals: TAVector3f;
   OldColours: TAVector4f;
   OldNumFaces : integer;
   i,j,k : integer;
   NeighborhoodPlugin: PMeshPluginBase;
begin
   if VerticesPerFace <> 3 then
   begin
      // Start with face conversion.
      VerticesPerFace := 3;
      FaceType := GL_TRIANGLES;
      OldNumFaces := NumFaces;
      NumFaces := NumFaces * 2;
      // Make a backup of the faces first.
      SetLength(OldFaces,High(Faces)+1);
      for i := Low(Faces) to High(Faces) do
         OldFaces[i] := Faces[i];
      // Now we transform each quad in two tris.
      SetLength(Faces,Round((High(Faces)+1)*1.5));
      i := 0;
      j := 0;
      while i <= High(Faces) do
      begin
         Faces[i] := OldFaces[j];
         inc(i);
         Faces[i] := OldFaces[j+1];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+3];
         inc(i);
         Faces[i] := OldFaces[j];
         inc(i);
         inc(j,4);
      end;
      SetLength(OldFaces,0);
      NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin <> nil then
      begin
         TNeighborhoodDataPlugin(NeighborhoodPlugin^).UpdateQuadsToTriangles(Faces,Vertices,High(Vertices)+1,VerticesPerFace);
      end;

      // Go with Colour conversion.
      if (ColoursType = C_COLOURS_PER_FACE) then
      begin
         // Make a backup of the colours first.
         SetLength(OldColours,High(Colours)+1);
         for i := Low(Colours) to High(Colours) do
         begin
            OldColours[i].X := Colours[i].X;
            OldColours[i].Y := Colours[i].Y;
            OldColours[i].Z := Colours[i].Z;
            OldColours[i].W := Colours[i].W;
         end;
         // Duplicate the colours.
         SetLength(Colours,NumFaces);
         i := 0;
         j := 0;
         while j < OldNumFaces do
         begin
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            inc(j);
         end;
         SetLength(OldColours,0);
      end;
      // Go with Normals conversion.
      if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      begin
         // Make a backup of the normals first.
         SetLength(OldFaceNormals,High(FaceNormals)+1);
         for i := Low(FaceNormals) to High(FaceNormals) do
         begin
            OldFaceNormals[i].X := FaceNormals[i].X;
            OldFaceNormals[i].Y := FaceNormals[i].Y;
            OldFaceNormals[i].Z := FaceNormals[i].Z;
         end;
         // Duplicate the face normals.
         SetLength(FaceNormals,NumFaces);
         for i := 0 to OldNumFaces - 1 do
         begin
            FaceNormals[i*2].X := OldFaceNormals[i].X;
            FaceNormals[i*2].Y := OldFaceNormals[i].Y;
            FaceNormals[i*2].Z := OldFaceNormals[i].Z;
            FaceNormals[(i*2)+1].X := OldFaceNormals[i].X;
            FaceNormals[(i*2)+1].Y := OldFaceNormals[i].Y;
            FaceNormals[(i*2)+1].Z := OldFaceNormals[i].Z;
         end;
         SetLength(OldFaceNormals,0);
      end;
      ForceRefresh;
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
   OptimizationTool := TMeshOptimizationTool.Create(_IgnoreColours,_Angle);
   OptimizationTool.Execute(Vertices,Normals,FaceNormals,Colours,TexCoords,Faces,VerticesPerFace,ColoursType,NormalsType,NumFaces);
   OptimizationTool.Free;

   SetLength(FaceNormals,0);
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

end.
