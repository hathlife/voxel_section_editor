unit TextureAtlasExtractorOrigamiGPU;

interface

uses BasicMathsTypes, BasicDataTypes, TextureAtlasExtractorOrigami, MeshPluginBase, NeighborDetector,
   Math, IntegerList, VertexTransformationUtils, Math3d, NeighborhoodDataPlugin,
   SysUtils, Mesh, TextureAtlasExtractorBase, OpenCLLauncher;

{$INCLUDE source/Global_Conditionals.inc}

type
   CTextureAtlasExtractorOrigamiGPU = class (CTextureAtlasExtractorOrigami)
      protected
         OCL : TOpenClLauncher;
         // Aux functions
         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; override;
         function IsValidUVTriangle(const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; override;
      public
         procedure Initialize; override;
         // Executes
         procedure Execute(); override;
         procedure ExecuteWithDiffuseTexture(_Size: integer); override;
   end;


implementation

uses GlobalVars, TextureGeneratorBase, DiffuseTextureGenerator, MeshBRepGeometry,
   GLConstants, ColisionCheck, BasicFunctions;

procedure CTextureAtlasExtractorOrigamiGPU.Initialize();
begin
   OCL := TOpenCLLauncher.Create();
end;

procedure CTextureAtlasExtractorOrigamiGPU.Execute();
var
   i : integer;
   Seeds: TSeedSet;
   VertsSeed : TInt32Map;
   NeighborhoodPlugin: PMeshPluginBase;
   ProgramNames: AString;
begin
   // First, we'll build the texture atlas.
   SetLength(VertsSeed,High(FLOD.Mesh)+1);
   SetLength(Seeds,0);
   ProgramNames[0] := 'are2DTrianglesColidingEdges';
   ProgramNames[1] := 'are2DTrianglesOverlapping';
   OCL.LoadProgram(ExtractFilePath(ParamStr(0)) + 'opencl/origami.cl', ProgramNames);
   ProgramNames[0] := '';
   ProgramNames[1] := '';
   SetLength(ProgramNames, 0);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      SetLength(VertsSeed[i],0);
      NeighborhoodPlugin := FLOD.Mesh[i].GetPlugin(C_MPL_NEIGHBOOR);
      FLOD.Mesh[i].Geometry.GoToFirstElement;
      FLOD.Mesh[i].TexCoords := GetMeshSeeds(i,FLOD.Mesh[i].Vertices,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Normals,FLOD.Mesh[i].Normals,FLOD.Mesh[i].Colours,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Faces,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,Seeds,VertsSeed[i],NeighborhoodPlugin);
      if NeighborhoodPlugin <> nil then
      begin
         TNeighborhoodDataPlugin(NeighborhoodPlugin^).DeactivateQuadFaces;
      end;
   end;
   MergeSeeds(Seeds);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      GetFinalTextureCoordinates(Seeds,VertsSeed[i],FLOD.Mesh[i].TexCoords);
   end;
   // Free memory.
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      SetLength(VertsSeed[i],0);
   end;
   OCL.Free;
   SetLength(VertsSeed,0);
end;

procedure CTextureAtlasExtractorOrigamiGPU.ExecuteWithDiffuseTexture(_Size: integer);
var
   i : integer;
   Seeds: TSeedSet;
   VertsSeed : TInt32Map;
   TexGenerator: CTextureGeneratorBase;
   NeighborhoodPlugin: PMeshPluginBase;
   ProgramNames: AString;
begin
   // First, we'll build the texture atlas.
   SetLength(VertsSeed,High(FLOD.Mesh)+1);
   SetLength(Seeds,0);
   SetLength(ProgramNames, 2);
   ProgramNames[0] := 'are2DTrianglesColidingEdges';
   ProgramNames[1] := 'are2DTrianglesOverlapping';
   OCL.LoadProgram(ExtractFilePath(ParamStr(0)) + 'opencl/origami.cl', ProgramNames);
   ProgramNames[0] := '';
   ProgramNames[1] := '';
   SetLength(ProgramNames, 0);
   TexGenerator := CDiffuseTextureGenerator.Create(FLOD,_Size,0,0);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      SetLength(VertsSeed[i],0);
      NeighborhoodPlugin := FLOD.Mesh[i].GetPlugin(C_MPL_NEIGHBOOR);
      FLOD.Mesh[i].Geometry.GoToFirstElement;
      FLOD.Mesh[i].TexCoords := GetMeshSeeds(i,FLOD.Mesh[i].Vertices,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Normals,FLOD.Mesh[i].Normals,FLOD.Mesh[i].Colours,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Faces,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,Seeds,VertsSeed[i],NeighborhoodPlugin);
      if NeighborhoodPlugin <> nil then
      begin
         TNeighborhoodDataPlugin(NeighborhoodPlugin^).DeactivateQuadFaces;
      end;
   end;
   MergeSeeds(Seeds);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      GetFinalTextureCoordinates(Seeds,VertsSeed[i],FLOD.Mesh[i].TexCoords);
   end;
   // Now we build the diffuse texture.
   TexGenerator.Execute();
   // Free memory.
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      SetLength(VertsSeed[i],0);
   end;
   SetLength(VertsSeed,0);
   OCL.Free;
   TexGenerator.Free;
end;

function CTextureAtlasExtractorOrigamiGPU.IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   EdgeSizeInMesh,EdgeSizeInUV,Scale,SinProjectionSizeInMesh,SinProjectionSizeInUV,ProjectionSizeInMesh,ProjectionSizeInUV: single;
   EdgeDirectionInUV,PositionOfTargetAtEdgeInUV,SinDirectionInUV: TVector2f;
   EdgeDirectionInMesh,PositionOfTargetAtEdgeInMesh: TVector3f;
   SourceSide: single;
   InputData: apointer;
   InputSize, InputUnitSize: auint32;
   OutputSource: aint32;
   GlobalWorkSize: auint32;
   EdgeIDs: aint32;
   TriangleData: afloat;
   Output: integer;
begin
   Result := false;
   // Get edge size in mesh
   EdgeSizeInMesh := VectorDistance(_Vertices[_Edge0],_Vertices[_Edge1]);
   if EdgeSizeInMesh > 0 then
   begin
      // Get the direction of the edge (Edge0 to Edge1) in Mesh and UV space
      EdgeDirectionInMesh := SubtractVector(_Vertices[_Edge1],_Vertices[_Edge0]);
      EdgeDirectionInUV := SubtractVector(_TexCoords[_Edge1],_TexCoords[_Edge0]);
      // Get edge size in UV space.
      EdgeSizeInUV := Sqrt((EdgeDirectionInUV.U * EdgeDirectionInUV.U) + (EdgeDirectionInUV.V * EdgeDirectionInUV.V));
      // Directions must be normalized.
      Normalize(EdgeDirectionInMesh);
      Normalize(EdgeDirectionInUV);
      Scale := EdgeSizeInUV / EdgeSizeInMesh;
      // Get the size of projection of (Vertex - Edge0) at the Edge, in mesh
      ProjectionSizeInMesh := DotProduct(SubtractVector(_Vertices[_Target],_Vertices[_Edge0]),EdgeDirectionInMesh);
      // Obtain the position of this projection at the edge, in mesh
      PositionOfTargetatEdgeInMesh := AddVector(_Vertices[_Edge0],ScaleVector(EdgeDirectionInMesh,ProjectionSizeInMesh));
      // Now we can use the position obtained previously to find out the
      // distance between that and the _Target in mesh.
      SinProjectionSizeInMesh := VectorDistance(_Vertices[_Target],PositionOfTargetatEdgeInMesh);
      // Rotate the edge in 90' in UV space.
      SinDirectionInUV := Get90RotDirectionFromDirection(EdgeDirectionInUV);
      // We need to make sure that _Target and _OriginVert are at opposite sides
      // the universe, if it is divided by the Edge0 to Edge1.
      SourceSide := Get2DOuterProduct(_TexCoords[_OriginVert],_TexCoords[_Edge0],_TexCoords[_Edge1]);
      if SourceSide > 0 then
      begin
         SinDirectionInUV := ScaleVector(SinDirectionInUV,-1);
      end;
      // Now we use the same logic applied in mesh to find out the final position
      // in UV space
      ProjectionSizeInUV := ProjectionSizeInMesh * Scale;
      PositionOfTargetatEdgeInUV := AddVector(_TexCoords[_Edge0],ScaleVector(EdgeDirectionInUV,ProjectionSizeInUV));
      SinProjectionSizeInUV := SinProjectionSizeInMesh * Scale;
      // Write the UV Position
      _UVPosition := AddVector(PositionOfTargetatEdgeInUV,ScaleVector(SinDirectionInUV,SinProjectionSizeInUV));


      // Let's check if this UV Position will hit another UV project face.
      SetLength(TriangleData, 2);
      TriangleData[0] := _UVPosition.U;
      TriangleData[1] := _UVPosition.V;
      SetLength(EdgeIDs, 2);
      EdgeIDs[0] := _Edge0;
      EdgeIDs[1] := _Edge1;
      Output := 0;
      SetLength(InputData,6);
      InputData[0] := Addr(TriangleData[0]);
      InputData[1] := Addr(EdgeIDs[0]);
      InputData[2] := Addr(_CheckFace[0]);
      InputData[3] := Addr(_TexCoords[0]);
      InputData[4] := Addr(_Faces[0]);
      InputData[5] := Addr(Output);
      SetLength(InputSize,6);
      InputSize[0] := 2;
      InputSize[1] := 2;
      InputSize[2] := High(_CheckFace) + 1;
      InputSize[3] := 2 * (High(_TexCoords) + 1);
      InputSize[4] := High(_Faces) + 1;
      InputSize[5] := 1;
      SetLength(InputUnitSize,6);
      InputUnitSize[0] := sizeof(single);
      InputUnitSize[1] := sizeof(integer);
      InputUnitSize[2] := sizeof(boolean);
      InputUnitSize[3] := sizeof(single);
      InputUnitSize[4] := sizeof(integer);
      InputUnitSize[5] := sizeof(integer);
      SetLength(OutputSource,1);
      OutputSource[0] := 5;
      SetLength(GlobalWorkSize,1);
      GlobalWorkSize[0] := High(_CheckFace) + 1;
      OCL.RunKernel(InputData,InputSize,InputUnitSize,OutputSource,1,GlobalWorkSize,nil);
      if output = 1 then
      begin
         Result := false;
      end
      else
      begin
         Result := true;
      end;
      SetLength(TriangleData, 0);
      SetLength(EdgeIDs, 0);
      SetLength(InputData, 0);
      SetLength(InputSize, 0);
      SetLength(InputUnitSize, 0);
      SetLength(OutputSource, 0);
      SetLength(GlobalWorkSize, 0);
   end;
end;

function CTextureAtlasExtractorOrigamiGPU.IsValidUVTriangle(const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
const
   C_MIN_ANGLE = pi / 6;
   C_HALF_MIN_ANGLE = C_MIN_ANGLE / 2;
var
   InputData: apointer;
   InputSize, InputUnitSize: auint32;
   OutputSource: aint32;
   GlobalWorkSize: auint32;
   EdgeIDs: aint32;
   TriangleData: afloat;
   Output: integer;
   DirTE0,DirE1T,DirE0E1: TVector2f;
   Ang0,Ang1,AngTarget: single;
begin
   // Do we have a valid triangle?
   DirTE0 := SubtractVector(_TexCoords[_Edge0], _TexCoords[_Target]);
   if Epsilon(Normalize(DirTE0)) = 0 then
   begin
      Result := false;
      exit;
   end;
   DirE1T := SubtractVector(_TexCoords[_Target], _TexCoords[_Edge1]);
   if Epsilon(Normalize(DirE1T)) = 0 then
   begin
      Result := false;
      exit;
   end;

   // Is the orientation correct?
   if Epsilon(Get2DOuterProduct(_TexCoords[_Target],_TexCoords[_Edge0],_TexCoords[_Edge1])) > 0 then
   begin
      Result := false;
      exit;
   end;

   DirE0E1 := SubtractVector(_TexCoords[_Edge1], _TexCoords[_Edge0]);
   Normalize(DirE0E1);
   // Are angles acceptable?
   Ang0 := ArcCos(-1 * DotProduct(DirTE0, DirE0E1));
   Ang1 := ArcCos(-1 * DotProduct(DirE0E1, DirE1T));
   AngTarget := ArcCos(-1 * DotProduct(DirE1T, DirTE0));
   if Epsilon(abs(DotProduct(DirTE0,DirE1T)) - 1) = 0 then
   begin
      Result := false;
      exit;
   end;

   // Are all angles above threshold?
   if Ang0 < C_MIN_ANGLE then
   begin
      Result := false;
      exit;
   end;
   if Ang1 < C_MIN_ANGLE then
   begin
      Result := false;
      exit;
   end;
   if AngTarget < C_MIN_ANGLE then
   begin
      Result := false;
      exit;
   end;

   // Let's check if this UV Position will hit another UV project face.
   SetLength(TriangleData, 2);
   TriangleData[0] := _TexCoords[_Target].U;
   TriangleData[1] := _TexCoords[_Target].V;
   SetLength(EdgeIDs, 2);
   EdgeIDs[0] := _Edge0;
   EdgeIDs[1] := _Edge1;
   Output := 0;
   SetLength(InputData,6);
   InputData[0] := Addr(TriangleData[0]);
   InputData[1] := Addr(EdgeIDs[0]);
   InputData[2] := Addr(_CheckFace[0]);
   InputData[3] := Addr(_TexCoords[0]);
   InputData[4] := Addr(_Faces[0]);
   InputData[5] := Addr(Output);
   SetLength(InputSize,6);
   InputSize[0] := 2;
   InputSize[1] := 2;
   InputSize[2] := High(_CheckFace) + 1;
   InputSize[3] := 2 * (High(_TexCoords) + 1);
   InputSize[4] := High(_Faces) + 1;
   InputSize[5] := 1;
   SetLength(InputUnitSize,6);
   InputUnitSize[0] := sizeof(single);
   InputUnitSize[1] := sizeof(integer);
   InputUnitSize[2] := sizeof(boolean);
   InputUnitSize[3] := sizeof(single);
   InputUnitSize[4] := sizeof(integer);
   InputUnitSize[5] := sizeof(integer);
   SetLength(OutputSource,1);
   OutputSource[0] := 5;
   SetLength(GlobalWorkSize,1);
   GlobalWorkSize[0] := High(_CheckFace) + 1;
   OCL.CurrentKernel := 1;
   OCL.RunKernel(InputData,InputSize,InputUnitSize,OutputSource,1,GlobalWorkSize,nil);
   if output = 1 then
   begin
      Result := false;
   end
   else
   begin
      Result := true;
   end;
   OCL.CurrentKernel := 0;
   SetLength(TriangleData, 0);
   SetLength(EdgeIDs, 0);
   SetLength(InputData, 0);
   SetLength(InputSize, 0);
   SetLength(InputUnitSize, 0);
   SetLength(OutputSource, 0);
   SetLength(GlobalWorkSize, 0);
end;

end.
