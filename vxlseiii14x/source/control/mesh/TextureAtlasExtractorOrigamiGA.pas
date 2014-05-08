unit TextureAtlasExtractorOrigamiGA;

interface

uses BasicMathsTypes, BasicDataTypes, TextureAtlasExtractorBase, TextureAtlasExtractorOrigami,
   NeighborDetector, MeshPluginBase, Math, SysUtils, GeometricAlgebra, Multivector,
   IntegerList, math3d, NeighborhoodDataPlugin, ColisionCheckGA;

{$INCLUDE source/Global_Conditionals.inc}

type
   CTextureAtlasExtractorOrigamiGA = class (CTextureAtlasExtractorOrigami)
      private
         // Main functions
         function MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
      protected
         function GetVersorForTriangleProjectionGA(var _GA: TGeometricAlgebra; const _Normal: TVector3f): TMultiVector;
         function GetVertexPositionOnTriangleProjectionGA(var _GA: TGeometricAlgebra; const _V1: TVector3f; const _Versor,_Inverse: TMultiVector): TVector2f;
         function IsValidUVPointGA(var _PGA,_EGA: TGeometricAlgebra; const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _FaceNormal: TVector3f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
      public
         function GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f; override;
   end;

implementation

uses GlobalVars;

// Geometric Algebra edition.
function CTextureAtlasExtractorOrigamiGA.GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
var
   i, MaxVerts, NumSeeds: integer;
   FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   SetupMeshSeeds(_Vertices,_FaceNormals,_Faces,_VerticesPerFace,_Seeds,_VertsSeed,FaceNeighbors,Result,MaxVerts,FaceSeed,FacePriority,FaceOrder,CheckFace);

   // Let's build the seeds.
   NumSeeds := High(_Seeds) + 1;
   SetLength(_Seeds,NumSeeds + High(FaceSeed)+1);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      if FaceSeed[FaceOrder[i]] = -1 then
      begin
         // Make new seed.
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Seed = ' + IntToStr(NumSeeds) + ' and i = ' + IntToStr(i));
         {$endif}
         _Seeds[NumSeeds] := MakeNewSeed(NumSeeds,_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,CheckFace);
         inc(NumSeeds);
      end;
   end;
   SetLength(_Seeds,NumSeeds);

   // Re-align vertexes and seed bounds to start at (0,0)
   ReAlignSeedsToCenter(_Seeds,_VertsSeed,FaceNeighbors,Result,FacePriority,FaceOrder,CheckFace,_NeighborhoodPlugin);
end;

function CTextureAtlasExtractorOrigamiGA.GetVersorForTriangleProjectionGA(var _GA: TGeometricAlgebra; const _Normal: TVector3f): TMultiVector;
var
   Triangle,Screen,FullRotation: TMultiVector;
begin
   // Get rotation from _Normal to (0,0,1).
   Triangle := _GA.NewEuclideanBiVector(_Normal);
   Screen := _GA.NewEuclideanBiVector(SetVector(0,0,1));
   FullRotation := _GA.GetGeometricProduct(Triangle,Screen);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_ROTATION_TEST}
   GlobalVars.OrigamiFile.Add('Normal: (' + FloatToStr(_Normal.X) + ', ' + FloatToStr(_Normal.Y) + ', ' + FloatToStr(_Normal.Z) + ').');
   Triangle.Debug(GlobalVars.OrigamiFile,'Triangle (Normal)');
   Screen.Debug(GlobalVars.OrigamiFile,'Screen (0,0,1)');
   FullRotation.Debug(GlobalVars.OrigamiFile,'Full Rotation');
   {$endif}
   {$endif}

   // Obtain the versor that will be used to do this projection.
   Result := _GA.Euclidean3DLogarithm(FullRotation);

   // Free Memory
   FullRotation.Free;
   Triangle.Free;
   Screen.Free;
end;

function CTextureAtlasExtractorOrigamiGA.GetVertexPositionOnTriangleProjectionGA(var _GA: TGeometricAlgebra; const _V1: TVector3f; const _Versor,_Inverse: TMultiVector): TVector2f;
var
   Vector,Position: TMultiVector;
begin
   Vector := _GA.NewEuclideanVector(_V1);
   Position := _GA.GetAppliedRotor(Vector,_Versor,_Inverse);
   Result.U := Position.UnsafeData[1];
   Result.V := Position.UnsafeData[2];
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_ROTATION_TEST}
   Position.Debug(GlobalVars.OrigamiFile,'Triangle Positions');
   {$endif}
   {$endif}

   Position.Free;
   Vector.Free;
end;

function CTextureAtlasExtractorOrigamiGA.IsValidUVPointGA(var _PGA,_EGA: TGeometricAlgebra; const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _FaceNormal: TVector3f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   EdgeSizeInMesh,EdgeSizeInUV,Scale: single;
   i,v: integer;
   PEdge0,PEdge1,PTarget,PEdge0UV,PEdge1UV,PCenterTriangle,PCenterSegment,PCenterSegmentUV,PTemp,V0,V1,V2: TMultiVector; // Points
   LSEdge,LSEdgeUV,LSEdge0,LSEdge1,LSEdge2: TMultiVector; // Line segments.
   DirEdge,DirEdgeUV: TMultiVector; // Directions.
   PlaneRotation,SegmentRotation: TMultiVector; // Versors
   ColisionCheck : CColisionCheckGA;
begin
   Result := false;
   ColisionCheck := CColisionCheckGA.Create(_PGA);
   // Get constants that will be required in our computation.

   // Bring our points to Geometric Algebra.
   PEdge0 := _PGA.NewHomogeneousFlat(_Vertices[_Edge0]);
   PEdge1 := _PGA.NewHomogeneousFlat(_Vertices[_Edge1]);
   PTarget := _PGA.NewHomogeneousFlat(_Vertices[_Target]);
   PCenterTriangle := _PGA.NewHomogeneousFlat(GetTriangleCenterPosition(_Vertices[_Edge0],_Vertices[_Edge1],_Vertices[_Target]));
   PEdge0UV := _PGA.NewHomogeneousFlat(_TexCoords[_Edge0]);
   PEdge1UV := _PGA.NewHomogeneousFlat(_TexCoords[_Edge1]);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget');
   PCenterTriangle.Debug(GlobalVars.OrigamiFile,'PCenterTriangle');
   PEdge0UV.Debug(GlobalVars.OrigamiFile,'PEdge0UV');
   PEdge1UV.Debug(GlobalVars.OrigamiFile,'PEdge1UV');
   {$endif}
   {$endif}

   // Do translation to get center in (0,0,0).
   _PGA.HomogeneousOppositeTranslation(PEdge0,PCenterTriangle);
   _PGA.HomogeneousOppositeTranslation(PEdge1,PCenterTriangle);
   _PGA.HomogeneousOppositeTranslation(PTarget,PCenterTriangle);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0 moved to the center of the triangle');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1 moved to the center of the triangle');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget moved to the center of the triangle');
   {$endif}
   {$endif}

   // Get line segments.
   LSEdge := _PGA.GetOuterProduct(PEdge0,PEdge1);
   LSEdgeUV := _PGA.GetOuterProduct(PEdge0UV,PEdge1UV);
   // Get Directions.
   DirEdge := _PGA.GetFlatDirection(LSEdge);
   DirEdgeUV := _PGA.GetFlatDirection(LSEdgeUV);

   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   LSEdge.Debug(GlobalVars.OrigamiFile,'LSEdge');
   LSEdgeUV.Debug(GlobalVars.OrigamiFile,'LSEdgeUV');
   DirEdge.Debug(GlobalVars.OrigamiFile,'DirEdge');
   DirEdgeUV.Debug(GlobalVars.OrigamiFile,'DirEdgeUV');
   {$endif}
   {$endif}

   // Let's do the scale first.
   EdgeSizeInMesh := _PGA.GetLength(DirEdge);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   GlobalVars.OrigamiFile.Add('Norm of DirEdge is ' + FloatToStr(EdgeSizeInMesh) + '.');
   {$endif}
   {$endif}
   if EdgeSizeInMesh = 0 then
   begin
      PEdge0.Free;
      PEdge1.Free;
      PTarget.Free;
      PEdge0UV.Free;
      PEdge1UV.Free;
      LSEdge.Free;
      LSEdgeUV.Free;
      DirEdge.Free;
      DirEdgeUV.Free;
      PCenterTriangle.Free;
      ColisionCheck.Free;
      exit;
   end;
   EdgeSizeInUV := _PGA.GetLength(DirEdgeUV);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   GlobalVars.OrigamiFile.Add('Norm of DirEdgeUV is ' + FloatToStr(EdgeSizeInUV) + '.');
   {$endif}
   {$endif}

   Scale := EdgeSizeInUV / EdgeSizeInMesh;
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   GlobalVars.OrigamiFile.Add('Scale is ' + FloatToStr(Scale) + '.');
   {$endif}
   {$endif}
   _PGA.ScaleEuclideanDataFromVector(PEdge0,Scale);
   _PGA.ScaleEuclideanDataFromVector(PEdge1,Scale);
   _PGA.ScaleEuclideanDataFromVector(PTarget,Scale);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0 after scale');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1 after scale');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget after scale');
   {$endif}
   {$endif}

   // Project the triangle (Edge0,Edge1,Target) at the UV plane.
   PlaneRotation := GetVersorForTriangleProjectionGA(_EGA,_FaceNormal);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PlaneRotation.Debug(GlobalVars.OrigamiFile,'PlaneRotation');
   {$endif}
   {$endif}

   // This part is not very practical, but it should avoid problems.
   PTemp := TMultiVector.Create(PEdge0);
   _PGA.ApplyRotor(PEdge0,PTemp,PlaneRotation);
   _PGA.BladeOfGradeFromVector(PEdge0,1);
   PTemp.Assign(PEdge1);
   _PGA.ApplyRotor(PEdge1,PTemp,PlaneRotation);
   _PGA.BladeOfGradeFromVector(PEdge1,1);
   PTemp.Assign(PTarget);
   _PGA.ApplyRotor(PTarget,PTemp,PlaneRotation);
   _PGA.BladeOfGradeFromVector(PTarget,1);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0 after plane projection');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1 after plane projection');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget after plane projection');
   {$endif}
   {$endif}

   // Let's center our triangle at the center of the Edge0-Edge1 line segment.
   PCenterSegment := _PGA.NewEuclideanVector(SetVector((PEdge0.UnsafeData[1] + PEdge1.UnsafeData[1])*0.5,(PEdge0.UnsafeData[2] + PEdge1.UnsafeData[2])*0.5));
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PCenterSegment.Debug(GlobalVars.OrigamiFile,'PCenterSegment');
   {$endif}
   {$endif}
   // Do translation to get center in (0,0,0).
   _PGA.HomogeneousOppositeTranslation(PEdge0,PCenterSegment);
   _PGA.HomogeneousOppositeTranslation(PEdge1,PCenterSegment);
   _PGA.HomogeneousOppositeTranslation(PTarget,PCenterSegment);

   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0 moved to the center of the segment');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1 moved to the center of the segment');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget moved to the center of the segment');
   {$endif}
   {$endif}

   // Let's center our UV triangle at the center of the Edge0UV-Edge1UV line segment.
   PCenterSegmentUV := _PGA.NewEuclideanVector(SetVector((PEdge0UV.UnsafeData[1] + PEdge1UV.UnsafeData[1])*0.5,(PEdge0UV.UnsafeData[2] + PEdge1UV.UnsafeData[2])*0.5));
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PCenterSegmentUV.Debug(GlobalVars.OrigamiFile,'PCenterSegmentUV');
   {$endif}
   {$endif}
   // Do translation to get center in (0,0,0).
   _PGA.HomogeneousOppositeTranslation(PEdge0UV,PCenterSegmentUV);
   _PGA.HomogeneousOppositeTranslation(PEdge1UV,PCenterSegmentUV);

   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0UV.Debug(GlobalVars.OrigamiFile,'PEdge0UV moved to the center of the UV segment');
   PEdge1UV.Debug(GlobalVars.OrigamiFile,'PEdge1UV moved to the center of the UV segment');
   {$endif}
   {$endif}

   // Now we have to recalculate the line segments and directions.
   // Get line segments.
   _PGA.OuterProduct(LSEdge,PEdge0,PEdge1);
   _PGA.OuterProduct(LSEdgeUV,PEdge0UV,PEdge1UV);
   // Get Directions.
   _PGA.FlatDirection(DirEdge,LSEdge);
   _PGA.FlatDirection(DirEdgeUV,LSEdgeUV);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   LSEdge.Debug(GlobalVars.OrigamiFile,'LSEdge');
   LSEdgeUV.Debug(GlobalVars.OrigamiFile,'LSEdgeUV');
   DirEdge.Debug(GlobalVars.OrigamiFile,'DirEdge');
   DirEdgeUV.Debug(GlobalVars.OrigamiFile,'DirEdgeUV');
   {$endif}
   {$endif}

   // Let's rotate our vectors.
   _PGA.GeometricProduct(PTemp,DirEdge,DirEdgeUV);

   // Rotate the triangle (Edge0,Edge1,Target) at the UV plane.
   SegmentRotation := _PGA.Euclidean3DLogarithm(PTemp);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   SegmentRotation.Debug(GlobalVars.OrigamiFile,'SegmentRotation');
   {$endif}
   {$endif}
   // This part is not very practical, but it should avoid problems.
   PTemp.Assign(PEdge0);
   _PGA.ApplyRotor(PEdge0,PTemp,SegmentRotation);
   _PGA.BladeOfGradeFromVector(PEdge0,1);
   PTemp.Assign(PEdge1);
   _PGA.ApplyRotor(PEdge1,PTemp,SegmentRotation);
   _PGA.BladeOfGradeFromVector(PEdge1,1);
   PTemp.Assign(PTarget);
   _PGA.ApplyRotor(PTarget,PTemp,SegmentRotation);
   _PGA.BladeOfGradeFromVector(PTarget,1);

   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0 after rotation at the center of the segment');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1 after rotation at the center of the segment');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget after rotation at the center of the segment');
   {$endif}
   {$endif}

   // Translate PCenterSegmentUV units.
   _PGA.HomogeneousTranslation(PEdge0,PCenterSegmentUV);
   _PGA.HomogeneousTranslation(PEdge1,PCenterSegmentUV);
   _PGA.HomogeneousTranslation(PTarget,PCenterSegmentUV);

   {$ifdef ORIGAMI_TEST}
   PEdge0.Debug(GlobalVars.OrigamiFile,'PEdge0 at its final position');
   PEdge1.Debug(GlobalVars.OrigamiFile,'PEdge1 at its final position');
   PTarget.Debug(GlobalVars.OrigamiFile,'PTarget at its final position');
   {$endif}

   // Now we have the UV position (at PTarget)
   // Let's clear up some RAM before we continue.
   PTemp.Free;
   PEdge0UV.Free;
   PEdge1UV.Free;
   PCenterTriangle.Free;
   PCenterSegment.Free;
   PCenterSegmentUV.Free;
   LSEdge.Free;
   LSEdgeUV.Free;
   DirEdge.Free;
   DirEdgeUV.Free;
   PlaneRotation.Free;
   SegmentRotation.Free;

   // Get the line segments for colision detection.
   LSEdge0 := _PGA.GetOuterProduct(PEdge0,PEdge1);
   LSEdge1 := _PGA.GetOuterProduct(PEdge1,PTarget);
   LSEdge2 := _PGA.GetOuterProduct(PTarget,PEdge0);

   // Write UV coordinates.
   _UVPosition.U := PTarget.UnsafeData[1];
   _UVPosition.V := PTarget.UnsafeData[2];

   // Free more memory.
   PEdge0.Free;
   PEdge1.Free;
   PTarget.Free;

   // Let's check if this UV Position will hit another UV project face.
   Result := true;
   // the change in the _AddedFace temporary optimization for the upcoming loop.
   _CheckFace[_PreviousFace] := false;
   v := 0;
   V0 := TMultiVector.Create(_PGA.SystemDimension);
   V1 := TMultiVector.Create(_PGA.SystemDimension);
   V2 := TMultiVector.Create(_PGA.SystemDimension);
   for i := Low(_CheckFace) to High(_CheckFace) do
   begin
      // If the face was projected in the UV domain.
      if _CheckFace[i] then
      begin
         {$ifdef ORIGAMI_TEST}
         {$ifdef ORIGAMI_COLISION_TEST}
         GlobalVars.OrigamiFile.Add('Face ' + IntToStr(i) + ' has vertexes (' + FloatToStr(_TexCoords[_Faces[v]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v]].V) + '), (' + FloatToStr(_TexCoords[_Faces[v+1]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v+1]].V)  + '), (' + FloatToStr(_TexCoords[_Faces[v+2]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v+2]].V) + ').');
         {$endif}
         {$endif}
         // Check if the candidate position is inside this triangle.
         // If it is inside the triangle, then point is not validated. Exit.
         _PGA.SetHomogeneousFlat(V0,_TexCoords[_Faces[v]]);
         _PGA.SetHomogeneousFlat(V1,_TexCoords[_Faces[v+1]]);
         _PGA.SetHomogeneousFlat(V2,_TexCoords[_Faces[v+2]]);
         if ColisionCheck.Are2DTrianglesColiding(_PGA,LSEdge0,LSEdge1,LSEdge2,V0,V1,V2) then
         begin
            {$ifdef ORIGAMI_TEST}
            GlobalVars.OrigamiFile.Add('Vertex textured coordinate (' + FloatToStr(_UVPosition.U) + ', ' + FloatToStr(_UVPosition.V) + ') conflicts with face ' + IntToStr(i) + '.');
            {$endif}
            Result := false;
            _CheckFace[_PreviousFace] := true;
            // Free RAM.
            LSEdge2.Free;
            LSEdge1.Free;
            LSEdge0.Free;
            V2.Free;
            V1.Free;
            V0.Free;
            ColisionCheck.Free;
            exit;
         end;
      end;
      inc(v,_VerticesPerFace);
   end;
   _CheckFace[_PreviousFace] := true;

   // Free RAM.
   V2.Free;
   V1.Free;
   V0.Free;
   LSEdge2.Free;
   LSEdge1.Free;
   LSEdge0.Free;
   ColisionCheck.Free;
end;


function CTextureAtlasExtractorOrigamiGA.MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
var
   v,f,Value,vertex,FaceIndex,PreviousFace : integer;
   CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1: integer;
   FaceList,PreviousFaceList : CIntegerList;
   Angle: single;
   Position,TriangleCenter: TVector3f;
   CandidateUVPosition: TVector2f;
   AddedFace: abool;
   TriangleTransform,TriangleTransformInv: TMultiVector;
   EuclideanGA,ProjectiveGA: TGeometricAlgebra;
   FaceBackup: auint32;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   EuclideanGA := TGeometricAlgebra.Create(3);
   ProjectiveGA := TGeometricAlgebra.CreateHomogeneous(3);
   SetLength(FaceBackup,_VerticesPerFace);

   // Setup neighbor detection list
   FaceList := CIntegerList.Create;
   FaceList.UseFixedRAM(High(_CheckFace)+1);
   PreviousFaceList := CIntegerList.Create;
   PreviousFaceList.UseFixedRAM(High(_CheckFace)+1);
   // Setup VertsLocation
   SetLength(FVertsLocation,High(_Vertices)+1);
   for v := Low(FVertsLocation) to High(FVertsLocation) do
   begin
      FVertsLocation[v] := -1;
   end;
   // Avoid unlimmited loop
   SetLength(AddedFace,High(_CheckFace)+1);
   for f := Low(_CheckFace) to High(_CheckFace) do
   begin
      AddedFace[f] := false;
      _CheckFace[f] := false;
   end;

   // Add starting face
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Starting Face of the seed is ' + IntToStr(_StartingFace));
   {$endif}
   _FaceSeeds[_StartingFace] := _ID;
   _CheckFace[_StartingFace] := true;
   AddedFace[_StartingFace] := true;
   TriangleTransform := GetVersorForTriangleProjectionGA(EuclideanGA,_FaceNormals[_StartingFace]);
   TriangleTransformInv := EuclideanGA.GetInverse(TriangleTransform);
   {$ifdef ORIGAMI_TEST}
   TriangleTransform.Debug(GlobalVars.OrigamiFile,'TriangleTransform');
   TriangleTransformInv.Debug(GlobalVars.OrigamiFile,'TriangleTransformInv');
   {$endif}
//   Result.TransformMatrix := VertexUtil.GetTransformMatrixFromVector(_FaceNormals[_StartingFace]);
   Result.MinBounds.U := 999999;
   Result.MaxBounds.U := -999999;
   Result.MinBounds.V := 999999;
   Result.MaxBounds.V := -999999;
   Result.MeshID := _MeshID;

   // The first triangle is dealt in a different way.
   // We'll project it in the plane XY and the first vertex is on (0,0,0).
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Starting Face is ' + IntToStr(_StartingFace) + ' and it is being added now');
   {$endif}
   FaceIndex := _StartingFace * _VerticesPerFace;
   TriangleCenter := GetTriangleCenterPosition(_Vertices[_Faces[FaceIndex]],_Vertices[_Faces[FaceIndex+1]],_Vertices[_Faces[FaceIndex+2]]);
   for v := 0 to _VerticesPerFace - 1 do
   begin
      vertex := _Faces[FaceIndex+v];
      Position := SubtractVector(_Vertices[vertex],TriangleCenter);
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(Position.X) + ' ' + FloatToStr(Position.Y) + ' ' + FloatToStr(Position.Z) + ']');
      {$endif}
      if _VertsSeed[vertex] <> -1 then
      begin
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_StartingFace) + ' is used and it is being cloned as ' + IntToStr(High(_Vertices)+2));
         {$endif}
         // this vertex was used by a previous seed, therefore, we'll clone it
         SetLength(_Vertices,High(_Vertices)+2);
         SetLength(_VertsSeed,High(_Vertices)+1);
         _VertsSeed[High(_VertsSeed)] := _ID;
         SetLength(FVertsLocation,High(_Vertices)+1);
         FVertsLocation[High(_Vertices)] := vertex;  // _VertsLocation works slightly different here than in the non-origami version.
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+v) + ' has been changed to ' + IntToStr(High(_Vertices)));
         {$endif}
         _Faces[FaceIndex+v] := High(_Vertices);
         _Vertices[High(_Vertices)].X := _Vertices[vertex].X;
         _Vertices[High(_Vertices)].Y := _Vertices[vertex].Y;
         _Vertices[High(_Vertices)].Z := _Vertices[vertex].Z;
         SetLength(_VertsNormals,High(_Vertices)+1);
         _VertsNormals[High(_Vertices)].X := _VertsNormals[vertex].X;
         _VertsNormals[High(_Vertices)].Y := _VertsNormals[vertex].Y;
         _VertsNormals[High(_Vertices)].Z := _VertsNormals[vertex].Z;
         SetLength(_VertsColours,High(_Vertices)+1);
         _VertsColours[High(_Vertices)].X := _VertsColours[vertex].X;
         _VertsColours[High(_Vertices)].Y := _VertsColours[vertex].Y;
         _VertsColours[High(_Vertices)].Z := _VertsColours[vertex].Z;
         _VertsColours[High(_Vertices)].W := _VertsColours[vertex].W;
         // Get temporarily texture coordinates.
         SetLength(_TextCoords,High(_Vertices)+1);
//         _TextCoords[High(_Vertices)] := VertexUtil.GetUVCoordinates(Position,Result.TransformMatrix);
         _TextCoords[High(_Vertices)] := GetVertexPositionOnTriangleProjectionGA(EuclideanGA,Position,TriangleTransform,TriangleTransformInv);
         // Now update the bounds of the seed.
         if _TextCoords[High(_Vertices)].U < Result.MinBounds.U then
            Result.MinBounds.U := _TextCoords[High(_Vertices)].U;
         if _TextCoords[High(_Vertices)].U > Result.MaxBounds.U then
            Result.MaxBounds.U := _TextCoords[High(_Vertices)].U;
         if _TextCoords[High(_Vertices)].V < Result.MinBounds.V then
            Result.MinBounds.V := _TextCoords[High(_Vertices)].V;
         if _TextCoords[High(_Vertices)].V > Result.MaxBounds.V then
            Result.MaxBounds.V := _TextCoords[High(_Vertices)].V;
      end
      else
      begin
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(vertex) + ' is new.');
         {$endif}
         // This seed is the first seed to use this vertex.
         _VertsSeed[vertex] := _ID;
         FVertsLocation[vertex] := vertex;
         // Get temporary texture coordinates.
//         _TextCoords[vertex] := VertexUtil.GetUVCoordinates(Position,Result.TransformMatrix);
         _TextCoords[vertex] := GetVertexPositionOnTriangleProjectionGA(EuclideanGA,Position,TriangleTransform,TriangleTransformInv);
         // Now update the bounds of the seed.
         if _TextCoords[vertex].U < Result.MinBounds.U then
            Result.MinBounds.U := _TextCoords[vertex].U;
         if _TextCoords[vertex].U > Result.MaxBounds.U then
            Result.MaxBounds.U := _TextCoords[vertex].U;
         if _TextCoords[vertex].V < Result.MinBounds.V then
            Result.MinBounds.V := _TextCoords[vertex].V;
         if _TextCoords[vertex].V > Result.MaxBounds.V then
            Result.MaxBounds.V := _TextCoords[vertex].V;
      end;
   end;

   // Add neighbour faces to the list.
   f := _FaceNeighbors.GetNeighborFromID(_StartingFace);
   while f <> -1 do
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(_StartingFace));
      {$endif}
      // do some verification here
      if not AddedFace[f] then
      begin
         if (_FaceSeeds[f] = -1) then
         begin
            PreviousFaceList.Add(_StartingFace);
            FaceList.Add(f);
            {$ifdef ORIGAMI_TEST}
            GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
            {$endif}
         end;
         AddedFace[f] := true;
      end;
      f := _FaceNeighbors.GetNextNeighbor;
   end;


   // Neighbour Face Scanning starts here.
   // Wel'll check face by face and add the vertexes that were not added
   while FaceList.GetValue(Value) do
   begin
      PreviousFaceList.GetValue(PreviousFace);
      // Backup current face just in case the face gets rejected
      FaceIndex := Value * _VerticesPerFace;
      v := 0;
      while v < _VerticesPerFace do
      begin
         FaceBackup[v] := _Faces[FaceIndex + v];
         inc(v);
      end;

      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Veryfing Face ' + IntToStr(Value) + ' that was added by previous face ' + IntToStr(PreviousFace));
      {$endif}
      // The first idea is to get the vertex that wasn't added yet.
      ObtainCommonEdgeFromFaces(_Faces,_VerticesPerFace,Value,PreviousFace,CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1,v);
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Current Vertex = ' + IntToStr(CurrentVertex) + '; Previous Vertex = ' + IntToStr(PreviousVertex) + '; Share Edge = [' + IntToStr(SharedEdge0) + ', ' + IntToStr(SharedEdge1) + ']');
      {$endif}
      // Find coordinates and check if we won't hit another face.
      if IsValidUVPointGA(ProjectiveGA,EuclideanGA,_Vertices,_Faces,_TextCoords,_FaceNormals[Value],CurrentVertex,SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,CandidateUVPosition,Value,PreviousFace,_VerticesPerFace) then
      begin
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated.');
         {$endif}
         // Add the face and its vertexes
         _CheckFace[Value] := true;
         _FaceSeeds[Value] := _ID;
         // If the vertex wasn't used yet
         if _VertsSeed[CurrentVertex] = -1 then
         begin
            // This seed is the first seed to use this vertex.

            // Does this vertex has coordinates already?
            if FVertsLocation[CurrentVertex] <> -1 then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being cloned as ' + IntToStr(High(_Vertices)+1));
               {$endif}

               // Clone vertex
               SetLength(_Vertices,High(_Vertices)+2);
               SetLength(_VertsSeed,High(_Vertices)+1);
               _VertsSeed[High(_VertsSeed)] := _ID;
               SetLength(FVertsLocation,High(_Vertices)+1);
               FVertsLocation[High(_Vertices)] := CurrentVertex;
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+v) + ' has been changed from ' + IntToStr(CurrentVertex) + ' to ' + IntToStr(High(_Vertices)));
               {$endif}
               _Faces[FaceIndex+v] := High(_Vertices);
               _Vertices[High(_Vertices)].X := _Vertices[CurrentVertex].X;
               _Vertices[High(_Vertices)].Y := _Vertices[CurrentVertex].Y;
               _Vertices[High(_Vertices)].Z := _Vertices[CurrentVertex].Z;
               SetLength(_VertsNormals,High(_Vertices)+1);
               _VertsNormals[High(_Vertices)].X := _VertsNormals[CurrentVertex].X;
               _VertsNormals[High(_Vertices)].Y := _VertsNormals[CurrentVertex].Y;
               _VertsNormals[High(_Vertices)].Z := _VertsNormals[CurrentVertex].Z;
               SetLength(_VertsColours,High(_Vertices)+1);
               _VertsColours[High(_Vertices)].X := _VertsColours[CurrentVertex].X;
               _VertsColours[High(_Vertices)].Y := _VertsColours[CurrentVertex].Y;
               _VertsColours[High(_Vertices)].Z := _VertsColours[CurrentVertex].Z;
               _VertsColours[High(_Vertices)].W := _VertsColours[CurrentVertex].W;
               // Get temporary texture coordinates.
               SetLength(_TextCoords,High(_Vertices)+1);
               _TextCoords[High(_Vertices)].U := CandidateUVPosition.U;
               _TextCoords[High(_Vertices)].V := CandidateUVPosition.V;
               // Now update the bounds of the seed.
               if _TextCoords[High(_Vertices)].U < Result.MinBounds.U then
                  Result.MinBounds.U := _TextCoords[High(_Vertices)].U;
               if _TextCoords[High(_Vertices)].U > Result.MaxBounds.U then
                  Result.MaxBounds.U := _TextCoords[High(_Vertices)].U;
               if _TextCoords[High(_Vertices)].V < Result.MinBounds.V then
                  Result.MinBounds.V := _TextCoords[High(_Vertices)].V;
               if _TextCoords[High(_Vertices)].V > Result.MaxBounds.V then
                  Result.MaxBounds.V := _TextCoords[High(_Vertices)].V;
            end
            else
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being used.');
               {$endif}
               // Write the vertex coordinates.
               _VertsSeed[CurrentVertex] := _ID;
               FVertsLocation[CurrentVertex] := CurrentVertex;
               // Get temporary texture coordinates.
               _TextCoords[CurrentVertex].U := CandidateUVPosition.U;
               _TextCoords[CurrentVertex].V := CandidateUVPosition.V;
               // Now update the bounds of the seed.
               if _TextCoords[CurrentVertex].U < Result.MinBounds.U then
                  Result.MinBounds.U := _TextCoords[CurrentVertex].U;
               if _TextCoords[CurrentVertex].U > Result.MaxBounds.U then
                  Result.MaxBounds.U := _TextCoords[CurrentVertex].U;
               if _TextCoords[CurrentVertex].V < Result.MinBounds.V then
                  Result.MinBounds.V := _TextCoords[CurrentVertex].V;
               if _TextCoords[CurrentVertex].V > Result.MaxBounds.V then
                  Result.MaxBounds.V := _TextCoords[CurrentVertex].V;
            end;
         end
         else // if the vertex has been added previously.
         begin
            {$ifdef ORIGAMI_TEST}
            GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being cloned as ' + IntToStr(High(_Vertices)+1) + ' due to another seed.');
            {$endif}
            // Clone the vertex.
            SetLength(_Vertices,High(_Vertices)+2);
            SetLength(_VertsSeed,High(_Vertices)+1);
            _VertsSeed[High(_VertsSeed)] := _ID;
            SetLength(FVertsLocation,High(_Vertices)+1);
            FVertsLocation[High(_Vertices)] := CurrentVertex;
            {$ifdef ORIGAMI_TEST}
            GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+v) + ' has been changed from ' + IntToStr(CurrentVertex) + ' to ' + IntToStr(High(_Vertices)));
            {$endif}
            _Faces[FaceIndex+v] := High(_Vertices);
            _Vertices[High(_Vertices)].X := _Vertices[CurrentVertex].X;
            _Vertices[High(_Vertices)].Y := _Vertices[CurrentVertex].Y;
            _Vertices[High(_Vertices)].Z := _Vertices[CurrentVertex].Z;
            SetLength(_VertsNormals,High(_Vertices)+1);
            _VertsNormals[High(_Vertices)].X := _VertsNormals[CurrentVertex].X;
            _VertsNormals[High(_Vertices)].Y := _VertsNormals[CurrentVertex].Y;
            _VertsNormals[High(_Vertices)].Z := _VertsNormals[CurrentVertex].Z;
            SetLength(_VertsColours,High(_Vertices)+1);
            _VertsColours[High(_Vertices)].X := _VertsColours[CurrentVertex].X;
            _VertsColours[High(_Vertices)].Y := _VertsColours[CurrentVertex].Y;
            _VertsColours[High(_Vertices)].Z := _VertsColours[CurrentVertex].Z;
            _VertsColours[High(_Vertices)].W := _VertsColours[CurrentVertex].W;
            // Get temporary texture coordinates.
            SetLength(_TextCoords,High(_Vertices)+1);
            _TextCoords[High(_Vertices)].U := CandidateUVPosition.U;
            _TextCoords[High(_Vertices)].V := CandidateUVPosition.V;
            // Now update the bounds of the seed.
            if _TextCoords[High(_Vertices)].U < Result.MinBounds.U then
               Result.MinBounds.U := _TextCoords[High(_Vertices)].U;
            if _TextCoords[High(_Vertices)].U > Result.MaxBounds.U then
               Result.MaxBounds.U := _TextCoords[High(_Vertices)].U;
            if _TextCoords[High(_Vertices)].V < Result.MinBounds.V then
               Result.MinBounds.V := _TextCoords[High(_Vertices)].V;
            if _TextCoords[High(_Vertices)].V > Result.MaxBounds.V then
               Result.MaxBounds.V := _TextCoords[High(_Vertices)].V;
         end;


         // Check if other neighbors are elegible for this partition/seed.
         f := _FaceNeighbors.GetNeighborFromID(Value);
         while f <> -1 do
         begin
            {$ifdef ORIGAMI_TEST}
            GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(Value));
            {$endif}
            // do some verification here
            if not AddedFace[f] then
            begin
               if (_FaceSeeds[f] = -1) then
               begin
                  PreviousFaceList.Add(Value);
                  FaceList.Add(f);
                  {$ifdef ORIGAMI_TEST}
                  GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
                  {$endif}
               end;
               AddedFace[f] := true;
            end;
            f := _FaceNeighbors.GetNextNeighbor;
         end;
      end
      else // Face has been rejected.
      begin
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been rejected.');
         {$endif}
         // Restore current face due to rejection
         v := 0;
         while v < _VerticesPerFace do
         begin
            _Faces[FaceIndex + v] := FaceBackup[v];
            inc(v);
         end;
      end;
   end;

   if _NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(_NeighborhoodPlugin^).UpdateEquivalencesOrigami(FVertsLocation);
   end;
   SetLength(FVertsLocation,0);
   SetLength(AddedFace,0);
   SetLength(FaceBackup,0);
   TriangleTransform.Free;
   TriangleTransformInv.Free;
   FaceList.Free;
   PreviousFaceList.Free;
   EuclideanGA.Free;
   ProjectiveGA.Free;
end;

end.
