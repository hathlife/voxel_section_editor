unit Mesh;

interface

uses dglOpenGL, GLConstants, Graphics, Voxel, Normals, BasicMathsTypes, BasicDataTypes,
      BasicRenderingTypes, Palette, Dialogs, SysUtils, IntegerList, StopWatch,
      ShaderBank, ShaderBankItem, TextureBank, TextureBankItem, IntegerSet,
      Material, Vector3fSet, MeshPluginBase, MeshGeometryList, MeshGeometryBase,
      Histogram, Debug;

{$INCLUDE source/Global_Conditionals.inc}
type
   TGetCardinalAttr = function: cardinal of object;
   TMesh = class
      private
         ColourGenStructure : byte;
         TransparencyLevel : single;
         Opened : boolean;
         NumVertices: cardinal;
         LastVertex: cardinal;
         // I/O
         procedure LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
         // Gets
         function GetNumVerticesCompressed: cardinal;
         function GetNumVerticesUnCompressed: cardinal;
         function GetLastVertexCompressed: cardinal;
         function GetLastVertexUnCompressed: cardinal;
         // Sets
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
         ColoursType : byte;
         NormalsType : byte;
         NumFaces : longword;
         NumVoxels : longword; // for statistic purposes.
         Vertices : TAVector3f;
         Normals : TAVector3f;
         Colours : TAVector4f;
//         Faces : auint32;
         TexCoords : TAVector2f;
         Geometry: CMeshGeometryList;
         GetNumVertices: TGetCardinalAttr;
         GetLastVertex: TGetCardinalAttr;
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
         procedure SetColourGenStructure(_ColoursType: integer);
         procedure SetNormalsType(_NormalsType: integer);
         procedure SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
         procedure ForceColoursRendering;
         // Gets
         function IsOpened: boolean;

         // Texture related.
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

         // Materials
         function GetLastTextureID(_MaterialID: integer): integer;
         function GetNextTextureID(_MaterialID: integer): integer;
         function GetTextureSize(_MaterialID,_TextureID: integer): integer;

         // Quality Assurance
         procedure FillAspectRatioHistogram(var _Histogram: THistogram);
         procedure FillSkewnessHistogram(var _Histogram: THistogram);
         procedure FillSmoothnessHistogram(var _Histogram: THistogram);

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

         // Uncompres to let it add vertices faster. Compress (default) to make it more compact.
         procedure UncompressMesh;
         procedure CompressMesh;
         procedure AddVertices(_NumVertices: cardinal);

         // Debug
         procedure Debug(const _Debug:TDebugFile);
         procedure DebugVertexPositions(const _Debug:TDebugFile);
         procedure DebugVertexNormals(const _Debug:TDebugFile);
         procedure DebugVertexColours(const _Debug:TDebugFile);
         procedure DebugVertexTexCoordss(const _Debug:TDebugFile);
   end;
   PMesh = ^TMesh;

implementation

uses GlobalVars, VoxelMeshGenerator, NormalsMeshPlugin, NeighborhoodDataPlugin,
      MeshBRepGeometry, BumpMapDataPlugin, BasicConstants, BasicFunctions, NeighborDetector;

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
   GetNumVertices := GetNumVerticesCompressed;
   GetLastVertex := GetLastVertexCompressed;
end;

constructor TMesh.Create(const _Mesh : TMesh);
begin
   Assign(_Mesh);
   GetNumVertices := GetNumVerticesCompressed;
   GetLastVertex := GetLastVertexCompressed;
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
//         MeshLanczosSmooth;
      end;
      C_QUALITY_2LANCZOS_4TRIS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
//         MeshLanczosSmooth;
//         RebuildFaceNormals;
//         SetVertexNormals;
//         ConvertFaceToVertexColours;
//         ConvertQuadsTo48Tris;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
//         MeshLanczosSmooth;
//         ConvertQuadsToTris;
//         RebuildFaceNormals;
//         SetVertexNormals;
//         ConvertFaceToVertexColours;
      end;
      C_QUALITY_SMOOTH_MANIFOLD:
      begin
         LoadManifoldsFromVisibleVoxels(_Voxel,_Palette);
//         SetVertexNormals;
//         ConvertFaceToVertexColours;
      end;
   end;
   IsColisionEnabled := false; // Temporarily, until colision is implemented.
   IsVisible := true;
   IsSelected := false;
   Next := -1;
   Son := -1;
   GetNumVertices := GetNumVerticesCompressed;
   GetLastVertex := GetLastVertexCompressed;
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
//         MeshLanczosSmooth;
      end;
      C_QUALITY_2LANCZOS_4TRIS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
//         MeshLanczosSmooth;
//         RebuildFaceNormals;
//         SetVertexNormals;
//         ConvertFaceToVertexColours;
//         ConvertQuadsTo48Tris;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         LoadFromVisibleVoxels(_Voxel,_Palette);
//         MeshLanczosSmooth;
//         ConvertQuadsToTris;
//         RebuildFaceNormals;
//         SetVertexNormals;
//         ConvertFaceToVertexColours;
      end;
      C_QUALITY_SMOOTH_MANIFOLD:
      begin
         LoadManifoldsFromVisibleVoxels(_Voxel,_Palette);
//         SetVertexNormals;
//         ConvertFaceToVertexColours;
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

// Texture related.
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

procedure TMesh.SetColourGenStructure(_ColoursType: integer);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   ColourGenStructure := _ColoursType and 3;
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      CurrentGeometry^.SetColourGenStructure(ColoursType);
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

// Quality Assurance
procedure TMesh.FillAspectRatioHistogram(var _Histogram: THistogram);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).FillAspectRatioHistogram(_Histogram,Vertices);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.FillSkewnessHistogram(var _Histogram: THistogram);
var
   CurrentGeometry: PMeshGeometryBase;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).FillSkewnessHistogram(_Histogram,Vertices);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.FillSmoothnessHistogram(var _Histogram: THistogram);
var
   CurrentGeometry: PMeshGeometryBase;
   NeighborhoodPlugin: PMeshPluginBase;
   FaceNeighbors: TNeighborDetector;
begin
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   NeighborhoodPlugin := GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      FaceNeighbors := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceFaceNeighbors;
   end
   else
   begin
      FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
      FaceNeighbors.BuildUpData((CurrentGeometry^ as TMeshBRepGeometry).Faces,(CurrentGeometry^ as TMeshBRepGeometry).VerticesPerFace,High(Vertices)+1);
   end;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).FillSmoothnessHistogram(_Histogram,Vertices,FaceNeighbors);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
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

// Mesh compression and uncompression
function TMesh.GetNumVerticesCompressed: cardinal;
begin
   Result := High(Vertices) + 1;
end;

function TMesh.GetNumVerticesUnCompressed: cardinal;
begin
   Result := NumVertices;
end;

function TMesh.GetLastVertexCompressed: cardinal;
begin
   Result := High(Vertices);
end;

function TMesh.GetLastVertexUnCompressed: cardinal;
begin
   Result := LastVertex;
end;

procedure TMesh.UncompressMesh;
begin
   NumVertices := High(Vertices)+1;
   LastVertex := High(Vertices);
   GetNumVertices := GetNumVerticesUncompressed;
   GetLastVertex := GetLastVertexUncompressed;
end;

procedure TMesh.CompressMesh;
begin
   if High(TexCoords) = High(Vertices) then
      SetLength(TexCoords, NumVertices);
   if High(Normals) = High(Vertices) then
      SetLength(Normals, NumVertices);
   if High(Colours) = High(Vertices) then
      SetLength(Colours, NumVertices);
   SetLength(Vertices, NumVertices);
   GetNumVertices := GetNumVerticesCompressed;
   GetLastVertex := GetLastVertexCompressed;
end;

procedure TMesh.AddVertices(_NumVertices: Cardinal);
var
   NewSize: cardinal;
begin
   NumVertices := NumVertices + _NumVertices;
   LastVertex := NumVertices - 1;
   if NumVertices >= High(Vertices) then
   begin
      NewSize := NumVertices * 2;
      if High(TexCoords) = High(Vertices) then
         SetLength(TexCoords, NewSize);
      if High(Normals) = High(Vertices) then
         SetLength(Normals, NewSize);
      if High(Colours) = High(Vertices) then
         SetLength(Colours, NewSize);
      SetLength(Vertices, NewSize);
   end;
end;

// Debug
procedure TMesh.Debug(const _Debug:TDebugFile);
var
   i: integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   _Debug.Add('Mesh ' + Name + ' with ID ' + IntToStr(ID) + ' Starts Here:' + #13#10);
   if High(Vertices) > 0 then
   begin
      _Debug.Add(IntToStr(High(Vertices)+1) + ' vertices:' + #13#10);
      for i := Low(Vertices) to High(Vertices) do
      begin
         _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(Vertices[i].X) + ' ' + FloatToStr(Vertices[i].Y) + ' ' + FloatToStr(Vertices[i].Z) + ']');
      end;
      if (High(Normals) > 0) then
      begin
         _Debug.Add(#13#10 + 'Vertex normals:' + #13#10);
         for i := Low(Normals) to High(Normals) do
         begin
            _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(Normals[i].X) + ' ' + FloatToStr(Normals[i].Y) + ' ' + FloatToStr(Normals[i].Z) + ']');
         end;
      end;
      if (High(Colours) > 0) then
      begin
         _Debug.Add(#13#10 + 'Vertex colours:' + #13#10);
         for i := Low(Colours) to High(Colours) do
         begin
            _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(Colours[i].X) + ' ' + FloatToStr(Colours[i].Y) + ' ' + FloatToStr(Colours[i].Z) + ' ' + FloatToStr(Colours[i].W) + ']');
         end;
      end;
      if (High(TexCoords) > 0) then
      begin
         _Debug.Add(#13#10 + 'Texture coordinates:' + #13#10);
         for i := Low(TexCoords) to High(TexCoords) do
         begin
            _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(TexCoords[i].U) + ' ' + FloatToStr(TexCoords[i].V) + ']');
         end;
      end;
   end;
   Geometry.GoToFirstElement;
   CurrentGeometry := Geometry.Current;
   while CurrentGeometry <> nil do
   begin
      (CurrentGeometry^ as TMeshBRepGeometry).Debug(_Debug);
      Geometry.GoToNextElement;
      CurrentGeometry := Geometry.Current;
   end;
end;

procedure TMesh.DebugVertexPositions(const _Debug:TDebugFile);
var
   i: integer;
begin
   if High(Vertices) > 0 then
   begin
      _Debug.Add('Mesh ' + Name + ' with ID ' + IntToStr(ID) + ' has the following ' + IntToStr(High(Vertices)+1) + ' vertices:' + #13#10);
      for i := Low(Vertices) to High(Vertices) do
      begin
         _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(Vertices[i].X) + ' ' + FloatToStr(Vertices[i].Y) + ' ' + FloatToStr(Vertices[i].Z) + ']');
      end;
   end;
end;

procedure TMesh.DebugVertexNormals(const _Debug:TDebugFile);
var
   i: integer;
begin
   if High(Normals) > 0 then
   begin
      _Debug.Add('Mesh ' + Name + ' with ID ' + IntToStr(ID) + ' has the following ' + IntToStr(High(Vertices)+1) + ' normals:' + #13#10);
      for i := Low(Normals) to High(Normals) do
      begin
         _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(Normals[i].X) + ' ' + FloatToStr(Normals[i].Y) + ' ' + FloatToStr(Normals[i].Z) + ']');
      end;
   end;
end;

procedure TMesh.DebugVertexColours(const _Debug:TDebugFile);
var
   i: integer;
begin
   if High(Colours) > 0 then
   begin
      _Debug.Add('Mesh ' + Name + ' with ID ' + IntToStr(ID) + ' has the following ' + IntToStr(High(Vertices)+1) + ' colours:' + #13#10);
      for i := Low(Colours) to High(Colours) do
      begin
         _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(Colours[i].X) + ' ' + FloatToStr(Colours[i].Y) + ' ' + FloatToStr(Colours[i].Z) + ' ' + FloatToStr(Colours[i].W) + ']');
      end;
   end;
end;

procedure TMesh.DebugVertexTexCoordss(const _Debug:TDebugFile);
var
   i: integer;
begin
   if High(TexCoords) > 0 then
   begin
      _Debug.Add('Mesh ' + Name + ' with ID ' + IntToStr(ID) + ' has the following ' + IntToStr(High(Vertices)+1) + ' texture coordinates:' + #13#10);
      for i := Low(TexCoords) to High(TexCoords) do
      begin
         _Debug.Add(IntToStr(i) + ' = [' + FloatToStr(TexCoords[i].U) + ' ' + FloatToStr(TexCoords[i].V) + ']');
      end;
   end;
end;


end.
