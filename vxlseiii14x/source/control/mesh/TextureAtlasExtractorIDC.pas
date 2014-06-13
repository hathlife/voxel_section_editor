unit TextureAtlasExtractorIDC;

interface

uses TextureAtlasExtractorBase, TextureAtlasExtractorOrigami,
      BasicMathsTypes, BasicDataTypes, NeighborDetector, MeshPluginBase,
      VertexTransformationUtils, NeighborhoodDataPlugin, IntegerList,
      OrderedWeightList;

{$INCLUDE source/Global_Conditionals.inc}

type
   CTextureAtlasExtractorIDC = class (CTextureAtlasExtractorOrigami)
      const
         C_MIN_ANGLE = pi / 6;
         C_HALF_MIN_ANGLE = C_MIN_ANGLE / 2;
         C_MAX_ANGLE = pi - (2 * C_MIN_ANGLE);
         C_IDEAL_ANGLE = pi / 3;
         C_MIN_TO_IDEAL_ANGLE_INTERVAL = C_IDEAL_ANGLE - C_MIN_ANGLE;
         C_IDEAL_TO_MAX_ANGLE_INTERVAL = C_MAX_ANGLE - C_IDEAL_ANGLE;
      protected
         FPriorityList: COrderedWeightList;
         FFaceList, FPreviousFaceList: auint32;
         FBorderEdges, FBorderEdgesMap: aint32;
         FBorderEdgeCounter: integer;

         FMeshAngleCount, FParamAngleCount: afloat;
         FVertNeighborsLeft: auint32;

         FAngleFactor: afloat;
         FMeshAng0, FMeshAng1, FMeshAngTarget, FUVAng0, FUVAng1, FUVAngTarget: single;
         // Execute
         function GetTexCoords(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces: auint32; var _Opposites : aint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
         // Seed creation
         function GetNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _Opposites: aint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed; overload;
         procedure BuildFirstTriangle(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; const _Opposites: aint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; _VerticesPerFace: integer; var _VertexUtil: TVertexTransformationUtils; var _TextureSeed: TTextureSeed; var _FaceEdgeCounter: auint32; const _CheckFace: abool); reintroduce;
         procedure ObtainCommonEdgeFromFaces(var _Faces: auint32; var _Opposites: aint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2,_inFaceCurrVertPosition: integer); reintroduce;
         procedure AddNeighborFaces(_CurrentFace: integer; var _FaceEdgeCounter: auint32; const _Faces: auint32; const _Opposites: aint32;  var _TextCoords: TAVector2f; const _FaceSeeds: aint32; const _CheckFace: abool; _VerticesPerFace: integer);
         procedure AssignVertex(_VertexID, _SeedID: integer; _U, _V: single; var _TextCoords: TAVector2f; var _VertsSeed: aint32; var _TextureSeed: TTextureSeed);
         procedure CloneVertex(_VertexID, _SeedID, _FaceIndex: integer; _U, _V: single; var _TextCoords: TAVector2f; var _VertsSeed: aint32; var _TextureSeed: TTextureSeed; var _Vertices : TAVector3f; var _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32);
         procedure UpdateBorderEdges(_CurrentFace: integer; const _Faces: auint32; const _Opposites: aint32; _VerticesPerFace: integer);
         procedure UpdateAngleCount(_Edge0, _Edge1, _Target: integer);

         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; override;
         function IsValidUVTriangle(const _Faces : auint32; const _Opposites: aint32; var _TexCoords: TAVector2f; const _Vertices: TAVector3f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; reintroduce;

         // Aux functions
         function GetDistortionFactor(_ID:integer; _Angle: single): single;
         procedure GetAnglesFromCoordinates(const _Vertices: TAVector3f; _Edge0, _Edge1, _Target: integer);

      public
         procedure ExecuteWithDiffuseTexture(_Size: integer); override;
   end;

implementation

uses GlobalVars, TextureGeneratorBase, DiffuseTextureGenerator, MeshBRepGeometry,
   GLConstants, ColisionCheck, BasicFunctions, HalfEdgePlugin, math3d, math,
   MeshCurvatureMeasure, SysUtils;

procedure CTextureAtlasExtractorIDC.ExecuteWithDiffuseTexture(_Size: integer);
var
   i : integer;
   Seeds: TSeedSet;
   VertsSeed : TInt32Map;
   TexGenerator: CTextureGeneratorBase;
   NeighborhoodPlugin, HalfEdgePlugin: PMeshPluginBase;
begin
   // First, we'll build the texture atlas.
   SetLength(VertsSeed,High(FLOD.Mesh)+1);
   SetLength(Seeds,0);
   TexGenerator := CDiffuseTextureGenerator.Create(FLOD,_Size,0,0);
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      SetLength(VertsSeed[i],0);
      NeighborhoodPlugin := FLOD.Mesh[i].GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin = nil then
      begin
         FLOD.Mesh[i].AddNeighborhoodPlugin;
         NeighborhoodPlugin := FLOD.Mesh[i].GetPlugin(C_MPL_NEIGHBOOR);
      end;
      HalfEdgePlugin := FLOD.Mesh[i].GetPlugin(C_MPL_HALFEDGE);
      if HalfEdgePlugin = nil then
      begin
         FLOD.Mesh[i].AddHalfEdgePlugin;
         HalfEdgePlugin := FLOD.Mesh[i].GetPlugin(C_MPL_HALFEDGE);
      end;
      FLOD.Mesh[i].Geometry.GoToFirstElement;
      FLOD.Mesh[i].TexCoords := GetTexCoords(i,FLOD.Mesh[i].Vertices,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Normals,FLOD.Mesh[i].Normals,FLOD.Mesh[i].Colours,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).Faces,(HalfEdgePlugin^ as THalfEdgePlugin).Opposites,(FLOD.Mesh[i].Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,Seeds,VertsSeed[i],NeighborhoodPlugin);
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
   TexGenerator.Free;
end;

function CTextureAtlasExtractorIDC.GetTexCoords(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces: auint32; var _Opposites : aint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
const
   C_2PI = 2 * pi;
var
   i, MaxVerts, NumSeeds, ExpectedMaxFaces: integer;
   FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
   Tool: TMeshCurvatureMeasure;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   SetupMeshSeeds(_Vertices,_FaceNormals,_Faces,_VerticesPerFace,_Seeds,_VertsSeed,FaceNeighbors,Result,MaxVerts,FaceSeed,FacePriority,FaceOrder,CheckFace);
   ExpectedMaxFaces := ((High(CheckFace)+1) * 2) + 1;
   SetLength(FFaceList, ExpectedMaxFaces);
   SetLength(FPreviousFaceList, ExpectedMaxFaces);
   FPriorityList := COrderedWeightList.Create;
   FPriorityList.SetRAMSize(ExpectedMaxFaces);

   // Calculate the remaining angle left for each vertex in the mesh and locally.
   Tool := TMeshCurvatureMeasure.Create;
   SetLength(FMeshAngleCount, High(_Vertices)+1);
   SetLength(FParamAngleCount, High(_Vertices)+1);
   SetLength(FVertNeighborsLeft, High(_Vertices)+1);
   SetLength(FAngleFactor, High(_Vertices)+1);
   for i := Low(FMeshAngleCount) to High(FMeshAngleCount) do
   begin
      FParamAngleCount[i] := C_2PI;
      FMeshAngleCount[i] := Tool.GetVertexAngleSum(i, _Vertices, _VertsNormals, (_NeighborhoodPlugin^ as TNeighborhoodDataPlugin).VertexNeighbors);
      FVertNeighborsLeft[i] := (_NeighborhoodPlugin^ as TNeighborhoodDataPlugin).VertexNeighbors.GetNumNeighbors(i);
      FAngleFactor[i] := Tool.GetVertexAngleSumFactor(FMeshAngleCount[i]);
   end;
   Tool.Free;

   // Let's build the seeds.
   NumSeeds := High(_Seeds)+1;
   SetLength(_Seeds,NumSeeds + High(FaceSeed)+1);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      if FaceSeed[FaceOrder[i]] = -1 then
      begin
         // Make new seed.
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Seed = ' + IntToStr(NumSeeds) + ' and i = ' + IntToStr(i));
         {$endif}
         _Seeds[NumSeeds] := GetNewSeed(NumSeeds,_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,_Opposites,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,CheckFace);
         inc(NumSeeds);
      end;
   end;
   SetLength(_Seeds,NumSeeds);

   // Re-align vertexes and seed bounds to start at (0,0)
   ReAlignSeedsToCenter(_Seeds,_VertsSeed,FaceNeighbors,Result,FacePriority,FaceOrder,CheckFace,_NeighborhoodPlugin);

   // Clear memory
   SetLength(FaceSeed, 0);
   SetLength(FacePriority, 0);
   SetLength(FaceOrder, 0);
   SetLength(CheckFace, 0);
   SetLength(FFaceList, 0);
   SetLength(FPreviousFaceList, 0);
   FPriorityList.Free;
   SetLength(FMeshAngleCount, 0);
   SetLength(FParamAngleCount, 0);
   SetLength(FVertNeighborsLeft, 0);
   SetLength(FAngleFactor, 0);
end;

function CTextureAtlasExtractorIDC.GetNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _Opposites: aint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
var
   Index,v,f,i,imax,Value,FaceIndex,PreviousFace : integer;
   CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1: integer;
   found: boolean;
   VertexUtil : TVertexTransformationUtils;
   CandidateUVPosition: TVector2f;
   FaceBackup: auint32;
   FaceEdgeCounter: auint32;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   VertexUtil := TVertexTransformationUtils.Create;
   SetLength(FaceBackup,_VerticesPerFace);
   // Setup VertsLocation
   SetLength(FVertsLocation,High(_Vertices)+1);
   for v := Low(FVertsLocation) to High(FVertsLocation) do
   begin
      FVertsLocation[v] := -1;
   end;
   // Setup neighbor detection list
   // Avoid unlimmited loop
   SetLength(FaceEdgeCounter, High(_CheckFace) + 1);
   for f := Low(_CheckFace) to High(_CheckFace) do
   begin
      _CheckFace[f] := false;
      FFaceList[f] := 0;
      FPreviousFaceList[f] := 0;
      FaceEdgeCounter[f] := 0;
   end;

   // Setup the edge descriptor from the Seed (Chart), for collision detection.
   FBorderEdgeCounter := 0;
   SetLength(FBorderEdges, High(_Faces) + 1);
   SetLength(FBorderEdgesMap, High(_Faces) + 1);
   for f := Low(_Faces) to High(_Faces) do
   begin
      FBorderEdges[f] := -1;
      FBorderEdgesMap[f] := -1;
   end;

   // Add starting face
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Starting Face of the seed is ' + IntToStr(_StartingFace));
   {$endif}
   _FaceSeeds[_StartingFace] := _ID;
   _CheckFace[_StartingFace] := true;
   Result.MinBounds.U := 999999;
   Result.MaxBounds.U := -999999;
   Result.MinBounds.V := 999999;
   Result.MaxBounds.V := -999999;
   Result.MeshID := _MeshID;

   BuildFirstTriangle(_ID, _MeshID, _StartingFace, _Vertices, _FaceNormals, _VertsNormals, _VertsColours, _Faces, _Opposites, _TextCoords, _FaceSeeds, _VertsSeed, _VerticesPerFace, VertexUtil, Result, FaceEdgeCounter, _CheckFace);

   // Neighbour Face Scanning starts here.
   // Wel'll check face by face and add the vertexes that were not added
   Index := FPriorityList.GetFirstElement;
   while Index <> -1 do
   begin
      FPriorityList.Delete(Index);
      Value := FFaceList[Index];
      PreviousFace := FPreviousFaceList[Index];
      if not _CheckFace[Value] then
      begin
         // Backup current face just in case the face gets rejected
         FaceIndex := Value * _VerticesPerFace;
         v := 0;
         while v < _VerticesPerFace do
         begin
            FaceBackup[v] := _Faces[FaceIndex + v];
            inc(v);
         end;

         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Veryfing Face ' + IntToStr(Value) + ' <' + IntToStr(_Faces[FaceIndex]) + ', ' + IntToStr(_Faces[FaceIndex + 1]) + ', ' + IntToStr(_Faces[FaceIndex + 2]) + '> that was added by previous face ' + IntToStr(PreviousFace));
         {$endif}
         // The first idea is to get the vertex that wasn't added yet.
         ObtainCommonEdgeFromFaces(_Faces,_Opposites,_VerticesPerFace,Value,PreviousFace,CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1,v);
         {$ifdef ORIGAMI_TEST}
         Temp := 'VertsSeed = [';
         for i := Low(_VertsSeed) to High(_VertsSeed) do
         begin
            Temp := Temp + IntToStr(_VertsSeed[i]) + ' ';
         end;
         Temp := Temp + ']';
         GlobalVars.OrigamiFile.Add(Temp);
         GlobalVars.OrigamiFile.Add('Current Vertex = ' + IntToStr(CurrentVertex) + '; Previous Vertex = ' + IntToStr(PreviousVertex) + '; Share Edge = [' + IntToStr(SharedEdge0) + ', ' + IntToStr(SharedEdge1) + ']');
         {$endif}
         // If the vertex was added before, let's see if the triangle matches.
         if (_VertsSeed[CurrentVertex] <>  -1) then
         begin
            if (_VertsSeed[CurrentVertex] = _ID) and IsValidUVTriangle(_Faces,_Opposites,_TextCoords,_Vertices,CurrentVertex,SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,Value,PreviousFace,_VerticesPerFace) then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated using its original coordinates: [' +  FloatToStr(_TextCoords[CurrentVertex].U) + ', ' + FloatToStr(_TextCoords[CurrentVertex].V) + '].');
               {$endif}
               // Add the face only
               _CheckFace[Value] := true;
               _FaceSeeds[Value] := _ID;
               UpdateAngleCount(SharedEdge0, SharedEdge1, CurrentVertex); 
               UpdateBorderEdges(Value, _Faces, _Opposites, _VerticesPerFace);

               // Check if other neighbors are elegible for this partition/seed.
               AddNeighborFaces(Value, FaceEdgeCounter, _Faces, _Opposites, _TextCoords, _FaceSeeds, _CheckFace, _VerticesPerFace);
            end
            else
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been rejected using its original coordinates: [' +  FloatToStr(_TextCoords[CurrentVertex].U) + ', ' + FloatToStr(_TextCoords[CurrentVertex].V) + ']. Attempting nearby coordinates...');
               {$endif}
               // sometimes the triangle that may match may have another cloned
               // vertex instead of CurrentVertex.
               f := _FaceNeighbors.GetNeighborFromID(Value);
               while f <> -1 do
               begin
                  if _CheckFace[f] then
                  begin
                     i := f * _VerticesPerFace;
                     imax := i + _VerticesPerFace;
                     Found := false;
                     while (i < imax) and (not found) do
                     begin
                        if GetVertexLocationID(CurrentVertex) = GetVertexLocationID(_Faces[i]) then
                        begin
                           Found := true;
                        end
                        else
                        begin
                           inc(i);
                        end;
                     end;
                     if Found then
                     begin
                        if (_Faces[i] <> CurrentVertex) and (_VertsSeed[_Faces[i]] = _ID) then
                        begin
                           if IsValidUVTriangle(_Faces,_Opposites,_TextCoords,_Vertices,_Faces[i],SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,Value,PreviousFace,_VerticesPerFace) then
                           begin
                              {$ifdef ORIGAMI_TEST}
                              GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated using coordinates from ' + IntToStr(_Faces[i]) + ' instead of ' + IntToStr(CurrentVertex) + '. These coordinates are: [' + FloatToStr(_TextCoords[_Faces[i]].U) + ', ' + FloatToStr(_TextCoords[_Faces[i]].V) + '].');
                              {$endif}
                              // Add the face only
                              _CheckFace[Value] := true;
                              _FaceSeeds[Value] := _ID;
                              UpdateAngleCount(SharedEdge0, SharedEdge1, _Faces[i]);
                              UpdateBorderEdges(Value, _Faces, _Opposites, _VerticesPerFace);
                              {$ifdef ORIGAMI_TEST}
                              GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+v) + ' has been changed from ' + IntToStr(CurrentVertex) + ' to ' + IntToStr(_Faces[i]));
                              {$endif}
                              _Faces[FaceIndex + v] := _Faces[i];
                              f := -1;
                           end
                           else
                           begin
                              {$ifdef ORIGAMI_TEST}
                              GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has not been validated using coordinates from ' + IntToStr(_Faces[i]) + ' instead of ' + IntToStr(CurrentVertex) + '[' + FloatToStr(_TextCoords[_Faces[i]].U) + ', ' + FloatToStr(_TextCoords[_Faces[i]].V) + '].');
                              {$endif}
                           end;
                        end;
                     end;
                  end;
                  if f <> -1 then
                  begin
                     f := _FaceNeighbors.GetNextNeighbor;
                  end;
               end;
               // if the previous operation fails, try to clone it or reject it.
               if not _CheckFace[Value] then
               begin
                  // Find coordinates and check if we won't hit another face.
                  if IsValidUVPoint(_Vertices,_Faces,_TextCoords,CurrentVertex,SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,CandidateUVPosition,Value,PreviousFace,_VerticesPerFace) then
                  begin
                     {$ifdef ORIGAMI_TEST}
                     GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated.');
                     {$endif}
                     // Add the face and its vertexes
                     _CheckFace[Value] := true;
                     _FaceSeeds[Value] := _ID;

                     // Clone the vertex.
                     CloneVertex(CurrentVertex, _ID, FaceIndex+v, CandidateUVPosition.U, CandidateUVPosition.V, _TextCoords, _VertsSeed, Result, _Vertices, _VertsNormals, _VertsColours, _Faces);

                     UpdateAngleCount(SharedEdge0, SharedEdge1, _Faces[FaceIndex+v]);
                     UpdateBorderEdges(Value, _Faces, _Opposites, _VerticesPerFace);

                     // Check if other neighbors are elegible for this partition/seed.
                     AddNeighborFaces(Value, FaceEdgeCounter, _Faces, _Opposites, _TextCoords, _FaceSeeds, _CheckFace, _VerticesPerFace);
                  end
                  else // Face has been rejected.
                  begin
                     {$ifdef ORIGAMI_TEST}
                     GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been rejected when the following coordinates were used: [' + FloatToStr(CandidateUVPosition.U) + ', ' + FloatToStr(CandidateUVPosition.V) + '].');
                     {$endif}
                     // Restore current face due to rejection
                     v := 0;
                     while v < _VerticesPerFace do
                     begin
                        _Faces[FaceIndex + v] := FaceBackup[v];
                        inc(v);
                     end;
                  end;
               end
               else
               begin
                  // Check if other neighbors are elegible for this partition/seed.
                  AddNeighborFaces(Value, FaceEdgeCounter, _Faces, _Opposites, _TextCoords, _FaceSeeds, _CheckFace, _VerticesPerFace);
               end;
            end;
         end
         else
         begin
            // Find coordinates and check if we won't hit another face.
            if IsValidUVPoint(_Vertices,_Faces,_TextCoords,CurrentVertex,SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,CandidateUVPosition,Value,PreviousFace,_VerticesPerFace) then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated.');
               {$endif}
               // Add the face and its vertexes
               _CheckFace[Value] := true;
               _FaceSeeds[Value] := _ID;

               // This seed is the first seed to use this vertex.

               // Does this vertex has coordinates already?
               if (FVertsLocation[CurrentVertex] <> -1) or ((_VertsSeed[CurrentVertex] <> -1) and (_VertsSeed[CurrentVertex] <> _ID)) then
               begin
                  CloneVertex(CurrentVertex, _ID, FaceIndex+v, CandidateUVPosition.U, CandidateUVPosition.V, _TextCoords, _VertsSeed, Result, _Vertices, _VertsNormals, _VertsColours, _Faces);
               end
               else
               begin
                  AssignVertex(CurrentVertex, _ID, CandidateUVPosition.U, CandidateUVPosition.V, _TextCoords, _VertsSeed, Result);
               end;

               UpdateAngleCount(SharedEdge0, SharedEdge1, _Faces[FaceIndex + v]);
               UpdateBorderEdges(Value, _Faces, _Opposites, _VerticesPerFace);
               // Check if other neighbors are elegible for this partition/seed.
               AddNeighborFaces(Value, FaceEdgeCounter, _Faces, _Opposites, _TextCoords, _FaceSeeds, _CheckFace, _VerticesPerFace);
            end
            else // Face has been rejected.
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been rejected when the following coordinates were used: [' + FloatToStr(CandidateUVPosition.U) + ', ' + FloatToStr(CandidateUVPosition.V) + '].');
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
      end;
      Index := FPriorityList.GetFirstElement;
   end;

   if _NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(_NeighborhoodPlugin^).UpdateEquivalencesOrigami(FVertsLocation);
   end;
   SetLength(FVertsLocation,0);
   VertexUtil.Free;
end;

procedure CTextureAtlasExtractorIDC.BuildFirstTriangle(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; const _Opposites: aint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; _VerticesPerFace: integer; var _VertexUtil: TVertexTransformationUtils; var _TextureSeed: TTextureSeed; var _FaceEdgeCounter: auint32; const _CheckFace: abool);
var
   vertex, FaceIndex: integer;
   Target,Edge0,Edge1: integer;
   cosAng0, cosAng1, sinAng0, sinAng1, Edge0Size: single;
   UVPosition: TVector2f;
begin
   // The first triangle is dealt in a different way.
   // We'll project it in the plane XY and the first vertex is on (0,0,0).
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Starting Face is ' + IntToStr(_StartingFace) + ' and it is being added now');
   {$endif}
   FaceIndex := _StartingFace * _VerticesPerFace;
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_Faces[FaceIndex]) + ' position is [' + FloatToStr(_Vertices[_Faces[FaceIndex]].X) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex]].Y) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex]].Z) + '].');
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_Faces[FaceIndex+1]) + ' position is [' + FloatToStr(_Vertices[_Faces[FaceIndex+1]].X) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+1]].Y) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+1]].Z) + '].');
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_Faces[FaceIndex+2]) + ' position is [' + FloatToStr(_Vertices[_Faces[FaceIndex+2]].X) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+2]].Y) + ', ' + FloatToStr(_Vertices[_Faces[FaceIndex+2]].Z) + '].');
   {$endif}
   // First vertex is (1,0).
   vertex := _Faces[FaceIndex];
   if _VertsSeed[vertex] <> -1 then
   begin
      CloneVertex(vertex, _ID, FaceIndex, 1, 0, _TextCoords, _VertsSeed, _TextureSeed, _Vertices, _VertsNormals, _VertsColours, _Faces);
   end
   else
   begin
      AssignVertex(vertex, _ID, 1, 0, _TextCoords, _VertsSeed, _TextureSeed);
   end;

   // Second vertex is (0,0).
   vertex := _Faces[FaceIndex+1];
   if _VertsSeed[vertex] <> -1 then
   begin
      CloneVertex(vertex, _ID, FaceIndex+1, 0, 0, _TextCoords, _VertsSeed, _TextureSeed, _Vertices, _VertsNormals, _VertsColours, _Faces);
   end
   else
   begin
      AssignVertex(vertex, _ID, 0, 0, _TextCoords, _VertsSeed, _TextureSeed);
   end;

   // Now, finally we have to figure out the 3rd vertex. That one depends on the angles.
   Target := _Faces[FaceIndex + 2];
   Edge0 := _Faces[FaceIndex];
   Edge1 := _Faces[FaceIndex + 1];

   GetAnglesFromCoordinates(_Vertices, Edge0, Edge1, Target);

   cosAng0 := cos(FUVAng0);
   cosAng1 := cos(FUVAng1);
   sinAng0 := sin(FUVAng0);
   sinAng1 := sin(FUVAng1);

   Edge0Size := sinAng1 / ((cosAng0 * sinAng1) + (cosAng1 * sinAng0));

   // Write the UV Position
   UVPosition.U := Edge0Size * cosAng0;
   UVPosition.V := Edge0Size * sinAng0;
   vertex := Target;
   if _VertsSeed[vertex] <> -1 then
   begin
      CloneVertex(vertex, _ID, FaceIndex+2, UVPosition.U, UVPosition.V, _TextCoords, _VertsSeed, _TextureSeed, _Vertices, _VertsNormals, _VertsColours, _Faces);
   end
   else
   begin
      AssignVertex(vertex, _ID, UVPosition.U, UVPosition.V, _TextCoords, _VertsSeed, _TextureSeed);
   end;

   UpdateAngleCount(Edge0, Edge1, Target);
   UpdateBorderEdges(_StartingFace, _Faces, _Opposites, _VerticesPerFace);

   // Add neighbour faces to the list.
   AddNeighborFaces(_StartingFace, _FaceEdgeCounter, _Faces, _Opposites, _TextCoords, _FaceSeeds, _CheckFace, _VerticesPerFace);
end;

procedure CTextureAtlasExtractorIDC.AddNeighborFaces(_CurrentFace: integer; var _FaceEdgeCounter: auint32; const _Faces: auint32; const _Opposites: aint32; var _TextCoords: TAVector2f; const _FaceSeeds: aint32; const _CheckFace: abool; _VerticesPerFace: integer);
var
   i,j,jNext,f,fi: integer;
   MidEdgePosition: TVector2f;
begin
   // Add neighbour faces to the list.
   fi := _CurrentFace * _VerticesPerFace;
   j := 0;
   while j < _VerticesPerFace do
   begin
      f := _Opposites[fi + j] div _VerticesPerFace;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(_CurrentFace));
      {$endif}
      inc(_FaceEdgeCounter[f]);
      // do some verification here
      if not _CheckFace[f] then
      begin
         if (_FaceSeeds[f] = -1) then
         begin
            if _FaceEdgeCounter[f] = 3 then
            begin
               i := FPriorityList.Add(0);   // add as first element.
            end
            else
            begin
               jNext := (j + 1) mod _VerticesPerFace;
               MidEdgePosition.U := (_TextCoords[_Faces[fi + j]].U + _TextCoords[_Faces[fi + jNext]].U) / 2;
               MidEdgePosition.V := (_TextCoords[_Faces[fi + j]].V + _TextCoords[_Faces[fi + jNext]].V) / 2;
               i := FPriorityList.Add(GetVectorLength(MidEdgePosition));
            end;
            FPreviousFaceList[i] := _CurrentFace;
            FFaceList[i] := f;
            {$ifdef ORIGAMI_TEST}
            GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
            {$endif}
         end;
      end;
      inc(j);
   end;
end;

procedure CTextureAtlasExtractorIDC.AssignVertex(_VertexID, _SeedID: integer; _U, _V: single; var _TextCoords: TAVector2f; var _VertsSeed: aint32; var _TextureSeed: TTextureSeed);
begin
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_VertexID) + ' is new.');
   {$endif}
   // This seed is the first seed to use this vertex.
   _VertsSeed[_VertexID] := _SeedID;
   FVertsLocation[_VertexID] := _VertexID;
   // Get temporary texture coordinates.
   _TextCoords[_VertexID].U := _U;
   _TextCoords[_VertexID].V := _V;
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(_VertexID) + ' and Position is: [' + FloatToStr(_U) + ' ' + FloatToStr(_V) + ']');
   {$endif}
   // Now update the bounds of the seed.
   if _U < _TextureSeed.MinBounds.U then
      _TextureSeed.MinBounds.U := _U;
   if _U > _TextureSeed.MaxBounds.U then
      _TextureSeed.MaxBounds.U := _U;
   if _V < _TextureSeed.MinBounds.V then
      _TextureSeed.MinBounds.V := _V;
   if _V > _TextureSeed.MaxBounds.V then
      _TextureSeed.MaxBounds.V := _V;
end;

procedure CTextureAtlasExtractorIDC.CloneVertex(_VertexID, _SeedID, _FaceIndex: integer; _U, _V: single; var _TextCoords: TAVector2f; var _VertsSeed: aint32; var _TextureSeed: TTextureSeed; var _Vertices : TAVector3f; var _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32);
begin
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(_VertexID) + ' is used and it is being cloned as ' + IntToStr(High(_Vertices)+1));
   {$endif}
   // this vertex was used by a previous seed, therefore, we'll clone it
   SetLength(_Vertices,High(_Vertices)+2);
   SetLength(_VertsSeed,High(_Vertices)+1);
   _VertsSeed[High(_VertsSeed)] := _SeedID;
   SetLength(FVertsLocation,High(_Vertices)+1);
   FVertsLocation[High(_Vertices)] := _VertexID;  // _VertsLocation works slightly different here than in the non-origami version.
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(_FaceIndex) + ' has been changed to ' + IntToStr(High(_Vertices)));
   {$endif}
   _Faces[_FaceIndex] := High(_Vertices);
   _Vertices[High(_Vertices)].X := _Vertices[_VertexID].X;
   _Vertices[High(_Vertices)].Y := _Vertices[_VertexID].Y;
   _Vertices[High(_Vertices)].Z := _Vertices[_VertexID].Z;
   SetLength(_VertsNormals,High(_Vertices)+1);
   _VertsNormals[High(_Vertices)].X := _VertsNormals[_VertexID].X;
   _VertsNormals[High(_Vertices)].Y := _VertsNormals[_VertexID].Y;
   _VertsNormals[High(_Vertices)].Z := _VertsNormals[_VertexID].Z;
   SetLength(_VertsColours,High(_Vertices)+1);
   _VertsColours[High(_Vertices)].X := _VertsColours[_VertexID].X;
   _VertsColours[High(_Vertices)].Y := _VertsColours[_VertexID].Y;
   _VertsColours[High(_Vertices)].Z := _VertsColours[_VertexID].Z;
   _VertsColours[High(_Vertices)].W := _VertsColours[_VertexID].W;
   // Get temporarily texture coordinates.
   SetLength(_TextCoords,High(_Vertices)+1);
   _TextCoords[High(_Vertices)].U := _U;
   _TextCoords[High(_Vertices)].V := _V;
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(_VertexID) + ' and Position is: [' + FloatToStr(_U) + ' ' + FloatToStr(_V) + ']');
   {$endif}
   // Now update the bounds of the seed.
   if _U < _TextureSeed.MinBounds.U then
      _TextureSeed.MinBounds.U := _U;
   if _U > _TextureSeed.MaxBounds.U then
      _TextureSeed.MaxBounds.U := _U;
   if _V < _TextureSeed.MinBounds.V then
      _TextureSeed.MinBounds.V := _V;
   if _V > _TextureSeed.MaxBounds.V then
      _TextureSeed.MaxBounds.V := _V;

    // Update our angle counter system
    SetLength(FParamAngleCount, High(_Vertices)+1);
    FParamAngleCount[High(_Vertices)] := 2 * pi;
    SetLength(FAngleFactor, High(_Vertices)+1);
    FAngleFactor[High(_Vertices)] := 1;
end;

// Update the FBorderEdges descriptor. The order of the edges doesn't matter at all.
procedure CTextureAtlasExtractorIDC.UpdateBorderEdges(_CurrentFace: integer; const _Faces: auint32; const _Opposites: aint32; _VerticesPerFace: integer);
var
   FaceIndex, i, iNext, oNext: integer;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   FaceIndex := _CurrentFace * _VerticesPerFace;
   i := 0;
   while i < _VerticesPerFace do
   begin
      if FBorderEdgesMap[_Opposites[FaceIndex + i]] <> -1 then
      begin
         // Check if the edge and its twin have the same vertices.
         // If they don't, then we should add this edge instead of removing one.
         oNext := ((_Opposites[FaceIndex + i] + 1) mod _VerticesPerFace) + ((_Opposites[FaceIndex + i] div _VerticesPerFace) * _VerticesPerFace);
         iNext := (i + 1) mod _VerticesPerFace;
         if (_Faces[FaceIndex + i] = _Faces[oNext]) and (_Faces[FaceIndex + iNext] = _Faces[_Opposites[FaceIndex + i]]) then
         begin
            // remove edge.
            dec(FBorderEdgeCounter);
            FBorderEdges[FBorderEdgesMap[_Opposites[FaceIndex + i]]] := FBorderEdges[FBorderEdgeCounter];
            FBorderEdgesMap[FBorderEdges[FBorderEdgeCounter]] := FBorderEdgeCounter;
            FBorderEdges[FBorderEdgeCounter] := -1;
            FBorderEdgesMap[_Opposites[FaceIndex + i]] := -1;
            FBorderEdgesMap[FaceIndex + i] := -1;
         end
         else
         begin
            // add edge
            FBorderEdgesMap[FaceIndex + i] := FBorderEdgeCounter;
            FBorderEdges[FBorderEdgeCounter] := FaceIndex + i;
            inc(FBorderEdgeCounter);
         end;
      end
      else // add edge.
      begin
         FBorderEdgesMap[FaceIndex + i] := FBorderEdgeCounter;
         FBorderEdges[FBorderEdgeCounter] := FaceIndex + i;
         inc(FBorderEdgeCounter);
      end;
      inc(i);
   end;
   {$ifdef ORIGAMI_TEST}
   i := 0;
   Temp := 'Border Edges are: [';
   while i < (FBorderEdgeCounter - 1) do
   begin
      iNext := ((FBorderEdges[i] + 1) mod _VerticesPerFace) + ((FBorderEdges[i] div _VerticesPerFace) * _VerticesPerFace);
      Temp := Temp + '(' + IntToStr(_Faces[FBorderEdges[i]]) + ', ' + IntToStr(_Faces[iNext]) + '), ';
      inc(i);
   end;
   iNext := ((FBorderEdges[i] + 1) mod _VerticesPerFace) + ((FBorderEdges[i] div _VerticesPerFace) * _VerticesPerFace);
   Temp := Temp + '(' + IntToStr(_Faces[FBorderEdges[i]]) + ', ' + IntToStr(_Faces[iNext]) + ')]';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}
end;

procedure CTextureAtlasExtractorIDC.UpdateAngleCount(_Edge0, _Edge1, _Target: integer);
begin
   FMeshAngleCount[GetVertexLocationID(_Edge0)] := FMeshAngleCount[GetVertexLocationID(_Edge0)] - FMeshAng0;
   FMeshAngleCount[GetVertexLocationID(_Edge1)] := FMeshAngleCount[GetVertexLocationID(_Edge1)] - FMeshAng1;
   FMeshAngleCount[GetVertexLocationID(_Target)] := FMeshAngleCount[GetVertexLocationID(_Target)] - FMeshAngTarget;
   FParamAngleCount[_Edge0] := FParamAngleCount[_Edge0] - FUVAng0;
   FParamAngleCount[_Edge1] := FParamAngleCount[_Edge1] - FUVAng1;
   FParamAngleCount[_Target] := FParamAngleCount[_Target] - FUVAngTarget;
   FAngleFactor[_Edge0] := epsilon((FMeshAngleCount[GetVertexLocationID(_Edge0)] / FParamAngleCount[_Edge0]) - 1) + 1;
   FAngleFactor[_Edge1] := epsilon((FMeshAngleCount[GetVertexLocationID(_Edge1)] / FParamAngleCount[_Edge1]) - 1) + 1;
   FAngleFactor[_Target] := epsilon((FMeshAngleCount[GetVertexLocationID(_Target)] / FParamAngleCount[_Target]) - 1) + 1;
   dec(FVertNeighborsLeft[GetVertexLocationID(_Edge0)]);
   dec(FVertNeighborsLeft[GetVertexLocationID(_Edge1)]);
   dec(FVertNeighborsLeft[GetVertexLocationID(_Target)]);
end;

// That's basically an interpolation. I'm still in doubt if it should be linear or not.
// At the moment, it is linear.
function CTextureAtlasExtractorIDC.GetDistortionFactor(_ID:integer; _Angle: single): single;
var
   AvgAngle: single;
   NumNeighborsFactor: integer;
begin
   NumNeighborsFactor := (FVertNeighborsLeft[_ID] -1);
   AvgAngle := (FParamAngleCount[_ID] - _Angle) / NumNeighborsFactor;
   if AvgAngle < C_MIN_ANGLE then
   begin
      Result := 0;
   end
   else if AvgAngle < C_IDEAL_ANGLE  then
   begin
      Result := ((AvgAngle - C_MIN_ANGLE) / (C_MIN_TO_IDEAL_ANGLE_INTERVAL)) * (NumNeighborsFactor * NumNeighborsFactor);
   end
   else if AvgAngle < C_MAX_ANGLE  then
   begin
      Result := (1 - ((AvgAngle - C_IDEAL_ANGLE) / (C_IDEAL_TO_MAX_ANGLE_INTERVAL))) * (NumNeighborsFactor * NumNeighborsFactor);
   end
   else
      Result := 0;
end;

procedure CTextureAtlasExtractorIDC.GetAnglesFromCoordinates(const _Vertices: TAVector3f; _Edge0, _Edge1, _Target: integer);
var
   i: integer;
   DirEdge,DirEdge0,DirEdge1: TVector3f;
   AngSum, DistortionSum: single;
   IdealAngles: afloat;
   DistortionFactor: afloat;
   IDs: auint32;
begin
   // Set memory
   SetLength(IDs, 3);
   SetLength(IdealAngles, 3);
   SetLength(DistortionFactor, 3);
   IDs[0] := _Edge0;
   IDs[1] := _Edge1;
   IDs[2] := _Target;

   // Gather basic data
   DirEdge := SubtractVector(_Vertices[_Edge1],_Vertices[_Edge0]);
   Normalize(DirEdge);
   DirEdge0 := SubtractVector(_Vertices[_Target],_Vertices[_Edge0]);
   Normalize(DirEdge0);
   DirEdge1 := SubtractVector(_Vertices[_Target],_Vertices[_Edge1]);
   Normalize(DirEdge1);
   FMeshAng0 := ArcCos(DotProduct(DirEdge0, DirEdge));
   FMeshAng1 := ArcCos(-1 * DotProduct(DirEdge1, DirEdge));
   FMeshAngTarget := ArcCos(DotProduct(DirEdge0, DirEdge1));
   IdealAngles[0] := FMeshAng0 / FAngleFactor[GetVertexLocationID(IDs[0])];
   IdealAngles[1] := FMeshAng1 / FAngleFactor[GetVertexLocationID(IDs[1])];
   IdealAngles[2] := FMeshAngTarget / FAngleFactor[GetVertexLocationID(IDs[2])];
   AngSum := IdealAngles[0] + IdealAngles[1] + IdealAngles[2];
   // Calculate resulting angles.
   if AngSum < pi then
   begin
      // We'll priorize the highest distortion factor.
      AngSum := pi - AngSum;
      DistortionSum := 0;
      for i := 0 to 2 do
      begin
         if FVertNeighborsLeft[IDs[i]] > 1 then
         begin
            DistortionFactor[i] := GetDistortionFactor(IDs[i], IdealAngles[i]);
         end
         else
         begin
            DistortionFactor[i] := 0;
         end;
         DistortionSum := DistortionSum + DistortionFactor[i];
      end;
      if DistortionSum > 0 then
      begin
         FUVAng0 := IdealAngles[0] + (AngSum * (DistortionFactor[0] / DistortionSum));
         FUVAng1 := IdealAngles[1] + (AngSum * (DistortionFactor[1] / DistortionSum));
      end
      else
      begin
         FUVAng0 := IdealAngles[0] + (AngSum / 3);
         FUVAng1 := IdealAngles[1] + (AngSum / 3);
      end;
      {$ifdef ORIGAMI_TEST}
      AngSum := pi - AngSum;
      {$endif}
   end
   else if AngSum = pi then
   begin
      FUVAng0 := (IdealAngles[0] / AngSum) * pi;
      FUVAng1 := (IdealAngles[1] / AngSum) * pi;
   end
   else
   begin
      // We'll priorize the highest distortion factor.
      AngSum := AngSum - pi;
      DistortionSum := 0;
      for i := 0 to 2 do
      begin
         if FVertNeighborsLeft[IDs[i]] > 1 then
         begin
            DistortionFactor[i] := GetDistortionFactor(IDs[i], IdealAngles[i]);
         end
         else
         begin
            DistortionFactor[i] := 0;
         end;
         DistortionSum := DistortionSum + DistortionFactor[i];
      end;
      if DistortionSum > 0 then
      begin
         FUVAng0 := IdealAngles[0] - (AngSum * (DistortionFactor[0] / DistortionSum));
         FUVAng1 := IdealAngles[1] - (AngSum * (DistortionFactor[1] / DistortionSum));
      end
      else
      begin
         FUVAng0 := IdealAngles[0] - (AngSum / 3);
         FUVAng1 := IdealAngles[1] - (AngSum / 3);
      end;
      {$ifdef ORIGAMI_TEST}
      AngSum := AngSum + pi;
      {$endif}
   end;

   // Self-Defense against absurdly deformed triangles.
   FUVAngTarget := pi - (FUVAng0 + FUVAng1);
   if FUVAng0 < C_MIN_ANGLE then
   begin
      FUVAng0 := C_MIN_ANGLE;
      FUVAng1 := FUVAng1 - C_HALF_MIN_ANGLE;
      FUVAngTarget := FUVAngTarget - C_HALF_MIN_ANGLE;
   end;
   if FUVAng1 < C_MIN_ANGLE then
   begin
      FUVAng0 := FUVAng0 - C_HALF_MIN_ANGLE;
      FUVAng1 := C_MIN_ANGLE;
      FUVAngTarget := FUVAngTarget - C_HALF_MIN_ANGLE;
   end;
   if (FUVAngTarget) < C_MIN_ANGLE then
   begin
      FUVAng0 := FUVAng0 - C_HALF_MIN_ANGLE;
      FUVAng1 := FUVAng1 - C_HALF_MIN_ANGLE;
      FUVAngTarget := C_MIN_ANGLE;
   end;

   // Report result if required.
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Triangle with the angles: (' + FloatToStr(FMeshAng0) + ', ' + FloatToStr(FMeshAng1) + ', ' + FloatToStr(FMeshAngTarget) + ') has been deformed with the angles: (' + FloatToStr(IdealAngles[0]) + ', ' + FloatToStr(IdealAngles[1]) + ', ' + FloatToStr(IdealAngles[2]) + ') and, it generates the following angles: (' + FloatToStr(FUVAng0) + ', ' + FloatToStr(FUVAng1) + ', ' + FloatToStr(FUVAngTarget) + ') where the factors are respectively ( ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Edge0)]) + ', ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Edge1)]) + ', ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Target)]) + ') and AngleSum is ' + FloatToStr(AngSum) + ' .');
   {$endif}
   // Free memory.
   SetLength(IDs, 0);
   SetLength(IdealAngles, 0);
   SetLength(DistortionFactor, 0);
end;

procedure CTextureAtlasExtractorIDC.ObtainCommonEdgeFromFaces(var _Faces: auint32; var _Opposites: aint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2,_inFaceCurrVertPosition: integer);
var
   i,j,mincface,minpface : integer;
   Found: boolean;
   {$ifdef ORIGAMI_TEST}
   Temp: String;
   {$endif}
begin
   mincface := _CurrentFace * _VerticesPerFace;
   minpface := _PreviousFace * _VerticesPerFace;

   {$ifdef ORIGAMI_TEST}
   Temp := 'VertexLocation = [';
   for i := Low(FVertsLocation) to High(FVertsLocation) do
   begin
      Temp := Temp + IntToStr(FVertsLocation[i]) + ' ';
   end;
   Temp := Temp + ']';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}

   j := 0;
   found := false;
   while (j < _VerticesPerFace) and (not found) do
   begin
      if (_Opposites[minpface + j] div _VerticesPerFace) = _CurrentFace then
      begin
         Found := true;
         i := _Opposites[minpface + j] mod _VerticesPerFace;
         _CommonVertex2 := _Faces[minpface + j]; //_Faces[mincface + i];
         _CommonVertex1 := _Faces[minpface + ((j + 1) mod _VerticesPerFace)]; //_Faces[mincface + ((i + 1) mod _VerticesPerFace)];
         _inFaceCurrVertPosition := (i + 2) mod _VerticesPerFace;
         _CurrentVertex := _Faces[mincface + _inFaceCurrVertPosition];
         _PreviousVertex := _Faces[minpface + ((j + 2) mod _VerticesPerFace)];
         _Faces[mincface + ((_inFaceCurrVertPosition + 1) mod _VerticesPerFace)] := _CommonVertex1;
         _Faces[mincface + ((_inFaceCurrVertPosition + 2) mod _VerticesPerFace)] := _CommonVertex2;
      end
      else
         inc(j);
   end;
end;

function CTextureAtlasExtractorIDC.IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   cosAng0,cosAng1,sinAng0,sinAng1,Edge0Size: single;
   EdgeSizeInMesh,EdgeSizeInUV,SinProjectionSizeInUV,ProjectionSizeInUV: single;
   EdgeDirectionInUV,PositionOfTargetAtEdgeInUV,SinDirectionInUV: TVector2f;
   EdgeDirectionInMesh: TVector3f;
   SourceSide: single;
   i,v: integer;
   ColisionUtil : CColisionCheck;//TVertexTransformationUtils;
begin
   Result := false;
   ColisionUtil := CColisionCheck.Create; //TVertexTransformationUtils.Create;
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

      // Find the angles of the vertexes of the main edge in Mesh.
      GetAnglesFromCoordinates(_Vertices, _Edge0, _Edge1, _Target);

      cosAng0 := cos(FUVAng0);
      cosAng1 := cos(FUVAng1);
      sinAng0 := sin(FUVAng0);
      sinAng1 := sin(FUVAng1);

      // We'll now use these angles to find the projection directly in UV.
      Edge0Size := (EdgeSizeInUV * sinAng1) / ((cosAng0 * sinAng1) + (cosAng1 * sinAng0));
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Edge0Size is ' + FloatToStr(Edge0Size) + '.');
      {$endif}
      if (Edge0Size <= 10) and (Edge0Size >= 0.1) then
      begin
         // Get the size of projection of (Vertex - Edge0) at the Edge, in UV already
         ProjectionSizeInUV := Edge0Size * cosAng0;

         // Obtain the position of this projection at the edge, in UV
         PositionOfTargetatEdgeInUV := AddVector(_TexCoords[_Edge0],ScaleVector(EdgeDirectionInUV,ProjectionSizeInUV));

         // Find out the distance between that and the _Target in UV.
         SinProjectionSizeInUV := Edge0Size * sinAng0;
         // Rotate the edgeze in 90' in UV space.
         SinDirectionInUV := Get90RotDirectionFromDirection(EdgeDirectionInUV);
         // We need to make sure that _Target and _OriginVert are at opposite sides
         // the universe, if it is divided by the Edge0 to Edge1.
         SourceSide := Get2DOuterProduct(_TexCoords[_OriginVert],_TexCoords[_Edge0],_TexCoords[_Edge1]);
         if SourceSide > 0 then
         begin
            SinDirectionInUV := ScaleVector(SinDirectionInUV,-1);
         end;
         // Write the UV Position
         _UVPosition := AddVector(PositionOfTargetatEdgeInUV,ScaleVector(SinDirectionInUV,SinProjectionSizeInUV));

         // Let's check if this UV Position will hit another UV project face.
         Result := true;
         // the change in the _AddedFace temporary optimization for the upcoming loop.
         i := 0;
         while i < FBorderEdgeCounter do
         begin
            v := ((FBorderEdges[i] + 1) mod _VerticesPerFace) + ((FBorderEdges[i] div _VerticesPerFace) * _VerticesPerFace);
            // Check if the candidate position is inside this triangle.
            // If it is inside the triangle, then point is not validated. Exit.
            if ColisionUtil.Is2DTriangleColidingEdge(_UVPosition,_TexCoords[_Edge0],_TexCoords[_Edge1],_TexCoords[_Faces[FBorderEdges[i]]],_TexCoords[_Faces[v]]) then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Vertex textured coordinate (' + FloatToStr(_UVPosition.U) + ', ' + FloatToStr(_UVPosition.V) + ') conflicts with edge ' + IntToStr(FBorderEdges[i]) + ' which is the edge [' + IntToStr(_Faces[FBorderEdges[i]]) + ', ' + IntToStr(_Faces[v]) + '].');
               {$endif}
               Result := false;
               ColisionUtil.Free;
               exit;
            end;
            inc(i);
         end;
      end;
   end
   else
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('New triangle causes too much distortion. Edge size is: ' + FloatToStr(Edge0Size) + '.');
      {$endif}
      Result := false;
   end;
   ColisionUtil.Free;
end;

function CTextureAtlasExtractorIDC.IsValidUVTriangle(const _Faces : auint32; const _Opposites: aint32; var _TexCoords: TAVector2f; const _Vertices: TAVector3f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   i,v, FaceIndex,OppFaceIndex: integer;
   ColisionUtil : CColisionCheck;//TVertexTransformationUtils;
   DirMeshTE0,DirMeshE1T,DirMeshE0E1: TVector3f;
   DirUVTE0,DirUVE1T,DirUVE0E1: TVector2f;
begin
   // Do we have a valid triangle?
   DirUVTE0 := SubtractVector(_TexCoords[_Edge0], _TexCoords[_Target]);
   if Epsilon(Normalize(DirUVTE0)) = 0 then
   begin
      Result := false;
      exit;
   end;
   DirUVE1T := SubtractVector(_TexCoords[_Target], _TexCoords[_Edge1]);
   if Epsilon(Normalize(DirUVE1T)) = 0 then
   begin
      Result := false;
      exit;
   end;
   DirUVE0E1 := SubtractVector(_TexCoords[_Edge1], _TexCoords[_Edge0]);
   Normalize(DirUVE0E1);

   // Is the orientation correct?
   if Epsilon(Get2DOuterProduct(_TexCoords[_Target],_TexCoords[_Edge0],_TexCoords[_Edge1])) > 0 then
   begin
      Result := false;
      exit;
   end;

   // Are angles acceptable?
   FUVAng0 := ArcCos(-1 * DotProduct(DirUVTE0, DirUVE0E1));
   FUVAng1 := ArcCos(-1 * DotProduct(DirUVE0E1, DirUVE1T));
   FUVAngTarget := ArcCos(-1 * DotProduct(DirUVE1T, DirUVTE0));
   if Epsilon(abs(DotProduct(DirUVTE0,DirUVE1T)) - 1) = 0 then
   begin
      Result := false;
      exit;
   end;

   // Check if half edges related to the current vertex were already projected
   // and are coherent.
   i := 0;
   v := 0;
   FaceIndex := _CurrentFace * _VerticesPerFace;
   while i < _VerticesPerFace do
   begin
      if _Faces[FaceIndex + i] = _Target then
      begin
         v := i;
         i := _VerticesPerFace;
      end;
      inc(i);
   end;
   // Now we know that _Faces[FaceIndex + v] points to _Target, we need to know
   // if the two twin half edges that points to it are really related to _Target
   OppFaceIndex := (_Opposites[FaceIndex + v] div _VerticesPerFace) * _VerticesPerFace;
   i := OppFaceIndex + ((_Opposites[FaceIndex + v] + 1) mod _VerticesPerFace);
   if _Faces[i] <> _Faces[FaceIndex + v] then
   begin
      Result := false;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('New triangle has an undesirable configuration.');
      {$endif}
      exit;
   end;
   i := OppFaceIndex + ((i + 2) mod _VerticesPerFace);
   if _Faces[i] <> _Faces[FaceIndex + ((v + 1) mod _VerticesPerFace)] then
   begin
      Result := false;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('New triangle has an undesirable configuration.');
      {$endif}
      exit;
   end;



   // Are all angles above threshold?
   if FUVAng0 < C_HALF_MIN_ANGLE then
   begin
      Result := false;
      exit;
   end;
   if FUVAng1 < C_HALF_MIN_ANGLE then
   begin
      Result := false;
      exit;
   end;
   if FUVAngTarget < C_HALF_MIN_ANGLE then
   begin
      Result := false;
      exit;
   end;


   DirMeshE0E1 := SubtractVector(_Vertices[_Edge1],_Vertices[_Edge0]);
   Normalize(DirMeshE0E1);
   DirMeshTE0 := SubtractVector(_Vertices[_Target],_Vertices[_Edge0]);
   Normalize(DirMeshTE0);
   DirMeshE1T := SubtractVector(_Vertices[_Target],_Vertices[_Edge1]);
   Normalize(DirMeshE1T);
   FMeshAng0 := ArcCos(DotProduct(DirMeshTE0, DirMeshE0E1));
   FMeshAng1 := ArcCos(-1 * DotProduct(DirMeshE1T, DirMeshE0E1));
   FMeshAngTarget := ArcCos(DotProduct(DirMeshTE0, DirMeshE1T));


   ColisionUtil := CColisionCheck.Create; //TVertexTransformationUtils.Create;

   // Let's check if this UV Position will hit another UV project face.
   Result := true;
   // the change in the _AddedFace temporary optimization for the upcoming loop.
   i := 0;
   while i < FBorderEdgeCounter do
   begin
      v := ((FBorderEdges[i] + 1) mod _VerticesPerFace) + ((FBorderEdges[i] div _VerticesPerFace) * _VerticesPerFace);
      // Check if the candidate position is inside this triangle.
      // If it is inside the triangle, then point is not validated. Exit.
      if ColisionUtil.Is2DTriangleOverlappingEdge(_TexCoords[_Target],_TexCoords[_Edge0],_TexCoords[_Edge1],_TexCoords[_Faces[FBorderEdges[i]]],_TexCoords[_Faces[v]]) then
      begin
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Vertex textured coordinate (' + FloatToStr(_TexCoords[_Target].U) + ', ' + FloatToStr(_TexCoords[_Target].V) + ') conflicts with edge ' + IntToStr(FBorderEdges[i]) + ' which is the edge [' + IntToStr(_Faces[FBorderEdges[i]]) + ', ' + IntToStr(_Faces[v]) + '].');
         {$endif}
         Result := false;
         ColisionUtil.Free;
         exit;
      end;
      inc(i);
   end;
   ColisionUtil.Free;
end;


end.
