unit MeshVxt;

// Mesh with Westwood Voxel Support (for Voxel Section Editor III)

interface

{$INCLUDE source/Global_Conditionals.inc}

{$ifdef VOXEL_SUPPORT}

uses dglOpenGL, GLConstants, Voxel, Normals, BasicMathsTypes, BasicDataTypes,
      BasicRenderingTypes, Palette, SysUtils, ShaderBank, MeshGeometryList,
      MeshGeometryBase, Mesh;

type
   TGetCardinalAttr = function: cardinal of object;
   TMeshVxt = class (TMesh)
      protected
         // I/O
         procedure LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
         procedure CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
      public
         NumVoxels : longword; // for statistic purposes.
         // Constructors And Destructors
         constructor Create(const _Mesh : TMeshVxt); overload;
         constructor CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED);
         destructor Destroy; override;
         procedure Clear;
         // I/O
         procedure RebuildVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);

         // Copies
         procedure Assign(const _Mesh : TMesh); override;
   end;
   PMeshVxt = ^TMeshVxt;

{$endif}

implementation

{$ifdef VOXEL_SUPPORT}

uses GlobalVars, VoxelMeshGenerator, NormalsMeshPlugin, NeighborhoodDataPlugin,
      MeshBRepGeometry, BumpMapDataPlugin, BasicConstants, BasicFunctions, NeighborDetector,
      StopWatch;


constructor TMeshVxt.Create(const _Mesh : TMeshVxt);
begin
   Assign(_Mesh);
   GetNumVertices := GetNumVerticesCompressed;
   GetLastVertex := GetLastVertexCompressed;
end;

constructor TMeshVxt.CreateFromVoxel(_ID : longword; const _Voxel : TVoxelSection; const _Palette : TPalette; _ShaderBank: PShaderBank; _Quality: integer = C_QUALITY_CUBED);
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

destructor TMeshVxt.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TMeshVxt.Clear;
begin
   FOpened := false;
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
procedure TMeshVxt.RebuildVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette; _Quality: integer = C_QUALITY_CUBED);
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


procedure TMeshVxt.LoadFromVoxel(const _Voxel : TVoxelSection; const _Palette : TPalette);
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

procedure TMeshVxt.LoadFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
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

procedure TMeshVxt.LoadManifoldsFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
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

procedure TMeshVxt.LoadTrisFromVisibleVoxels(const _Voxel : TVoxelSection; const _Palette : TPalette);
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

procedure TMeshVxt.CommonVoxelLoadingActions(const _Voxel : TVoxelSection);
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
   Scale.X := _Voxel.Tailer.Det * ((BoundingBox.Max.X - BoundingBox.Min.X) / _Voxel.Tailer.XSize);
   Scale.Y := _Voxel.Tailer.Det * ((BoundingBox.Max.Y - BoundingBox.Min.Y) / _Voxel.Tailer.YSize);
   Scale.Z := _Voxel.Tailer.Det * ((BoundingBox.Max.Z - BoundingBox.Min.Z) / _Voxel.Tailer.ZSize);
   FOpened := true;
end;

// Copies
procedure TMeshVxt.Assign(const _Mesh : TMesh);
begin
   NumVoxels := (_Mesh as TMeshVxt).NumVoxels;
   inherited Assign(_Mesh);
end;

{$endif}

end.
