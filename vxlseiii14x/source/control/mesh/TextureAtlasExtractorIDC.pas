unit TextureAtlasExtractorIDC;

interface

uses TextureAtlasExtractorBase, TextureAtlasExtractorOrigami,
      BasicMathsTypes, BasicDataTypes, NeighborDetector, MeshPluginBase,
      VertexTransformationUtils, NeighborhoodDataPlugin, IntegerList;

{$INCLUDE source/Global_Conditionals.inc}

type
   CTextureAtlasExtractorIDC = class (CTextureAtlasExtractorOrigami)
      protected
         FMeshAngleCount, FParamAngleCount: afloat;

         FAngleFactor: afloat;
         FMaxDistortionFactor: single;
         // Execute
         function GetTexCoords(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces: auint32; var _Opposites : aint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
         // Seed creation
         function GetNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _Opposites: aint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed; overload;
         procedure BuildFirstTriangle(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace: integer; var _VertexUtil: TVertexTransformationUtils; var _TextureSeed: TTextureSeed); override;

         // Aux functions
         function CalculateDistortionFactor(_value: single): single;
         procedure GetAnglesFromCoordinates(const _Vertices: TAVector3f; _Edge0, _Edge1, _Target: integer; var _Ang0, _Ang1: single);


//         procedure SetupAngleFactor(var _Vertices : TAVector3f; var _VertexNormals : TAVector3f; var _VertexNeighbors: TNeighborDetector);
//         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; override;
      public
         procedure ExecuteWithDiffuseTexture(_Size: integer); override;
   end;

implementation

uses GlobalVars, TextureGeneratorBase, DiffuseTextureGenerator, MeshBRepGeometry,
   GLConstants, ColisionCheck, BasicFunctions, HalfEdgePlugin, math3d, math,
   MeshCurvatureMeasure;

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
      HalfEdgePlugin := FLOD.Mesh[i].GetPlugin(C_MPL_HALFEDGE);
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
   FFaceList := CIntegerList.Create;
   FFaceList.UseFixedRAM(ExpectedMaxFaces);
   FPreviousFaceList := CIntegerList.Create;
   FPreviousFaceList.UseFixedRAM(ExpectedMaxFaces);

   // Calculate the remaining angle left for each vertex in the mesh and locally.
   Tool := TMeshCurvatureMeasure.Create;
   SetLength(FMeshAngleCount, High(_Vertices)+1);
   SetLength(FParamAngleCount, High(_Vertices)+1);
   for i := Low(FMeshAngleCount) to High(FMeshAngleCount) do
   begin
      FMeshAngleCount[i] := C_2PI;
      FParamAngleCount[i] := Tool.GetVertexAngleSum(i, _Vertices, _VertsNormals, (_NeighborhoodPlugin^ as TNeighborhoodDataPlugin).VertexNeighbors);
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
   FFaceList.Free;
   FPreviousFaceList.Free;
end;

function CTextureAtlasExtractorIDC.GetNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _Opposites: aint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
var
   v,f,i,imax,Value,FaceIndex,PreviousFace : integer;
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
   // Setup neighbor detection list
   FFaceList.RebootList;
   FPreviousFaceList.RebootList;
   // Setup VertsLocation
   SetLength(FVertsLocation,High(_Vertices)+1);
   for v := Low(FVertsLocation) to High(FVertsLocation) do
   begin
      FVertsLocation[v] := -1;
   end;
   // Avoid unlimmited loop
   SetLength(FaceEdgeCounter, High(_CheckFace) + 1);
   for f := Low(_CheckFace) to High(_CheckFace) do
   begin
      _CheckFace[f] := false;
      FaceEdgeCounter[f] := 0;
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

   BuildFirstTriangle(_ID, _MeshID, _StartingFace, _Vertices, _FaceNormals, _VertsNormals, _VertsColours, _Faces, _TextCoords, _FaceSeeds, _VertsSeed, _FaceNeighbors, _VerticesPerFace, VertexUtil, Result);

   // Neighbour Face Scanning starts here.
   // Wel'll check face by face and add the vertexes that were not added
   while FFaceList.GetValue(Value) do
   begin
      FPreviousFaceList.GetValue(PreviousFace);
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
         ObtainCommonEdgeFromFaces(_Faces,_VerticesPerFace,Value,PreviousFace,CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1,v);
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
            if (_VertsSeed[CurrentVertex] = _ID) and IsValidUVTriangle(_Faces,_TextCoords,CurrentVertex,SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,Value,PreviousFace,_VerticesPerFace) then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated using its original coordinates: [' +  FloatToStr(_TextCoords[CurrentVertex].U) + ', ' + FloatToStr(_TextCoords[CurrentVertex].V) + '].');
               {$endif}
               // Add the face only
               _CheckFace[Value] := true;
               _FaceSeeds[Value] := _ID;

               // Check if other neighbors are elegible for this partition/seed.
               f := _FaceNeighbors.GetNeighborFromID(Value);
               while f <> -1 do
               begin
                  {$ifdef ORIGAMI_TEST}
                  GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(Value));
                  {$endif}
                  // do some verification here
                  if not _CheckFace[f] then
                  begin
                     if (_FaceSeeds[f] = -1) then
                     begin
                        FPreviousFaceList.Add(Value);
                        FFaceList.Add(f);
                        {$ifdef ORIGAMI_TEST}
                        GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
                        {$endif}
                     end;
                  end;
                  f := _FaceNeighbors.GetNextNeighbor;
               end;
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
                           if IsValidUVTriangle(_Faces,_TextCoords,_Faces[i],SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,Value,PreviousFace,_VerticesPerFace) then
                           begin
                              {$ifdef ORIGAMI_TEST}
                              GlobalVars.OrigamiFile.Add('Face ' + IntToStr(Value) + ' has been validated using coordinates from ' + IntToStr(_Faces[i]) + ' instead of ' + IntToStr(CurrentVertex) + '. These coordinates are: [' + FloatToStr(_TextCoords[_Faces[i]].U) + ', ' + FloatToStr(_TextCoords[_Faces[i]].V) + '].');
                              {$endif}
                              // Add the face only
                              _CheckFace[Value] := true;
                              _FaceSeeds[Value] := _ID;
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
                     SetLength(_Vertices,High(_Vertices)+2);
                     SetLength(_VertsSeed,High(_Vertices)+1);
                     _VertsSeed[High(_VertsSeed)] := _ID;
                     SetLength(FVertsLocation,High(_Vertices)+1);
                     FVertsLocation[High(_Vertices)] := CurrentVertex;
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
                     {$ifdef ORIGAMI_TEST}
                     GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being cloned as ' + IntToStr(High(_Vertices)) + ' due to another seed using the following coordinates: [' + FloatToStr(CandidateUVPosition.U) + ', ' + FloatToStr(CandidateUVPosition.V) + '].');
                     GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+v) + ' has been changed from ' + IntToStr(CurrentVertex) + ' to ' + IntToStr(High(_Vertices)));
                     {$endif}
                     // Now update the bounds of the seed.
                     if _TextCoords[High(_Vertices)].U < Result.MinBounds.U then
                        Result.MinBounds.U := _TextCoords[High(_Vertices)].U;
                     if _TextCoords[High(_Vertices)].U > Result.MaxBounds.U then
                        Result.MaxBounds.U := _TextCoords[High(_Vertices)].U;
                     if _TextCoords[High(_Vertices)].V < Result.MinBounds.V then
                        Result.MinBounds.V := _TextCoords[High(_Vertices)].V;
                     if _TextCoords[High(_Vertices)].V > Result.MaxBounds.V then
                        Result.MaxBounds.V := _TextCoords[High(_Vertices)].V;

                     // Check if other neighbors are elegible for this partition/seed.
                     f := _FaceNeighbors.GetNeighborFromID(Value);
                     while f <> -1 do
                     begin
                        {$ifdef ORIGAMI_TEST}
                        GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(Value));
                        {$endif}
                        // do some verification here
                        if not _CheckFace[f] then
                        begin
                           if (_FaceSeeds[f] = -1) then
                           begin
                              FPreviousFaceList.Add(Value);
                              FFaceList.Add(f);
                              {$ifdef ORIGAMI_TEST}
                              GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
                              {$endif}
                           end;
                        end;
                        f := _FaceNeighbors.GetNextNeighbor;
                     end;
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
                  f := _FaceNeighbors.GetNeighborFromID(Value);
                  while f <> -1 do
                  begin
                     {$ifdef ORIGAMI_TEST}
                     GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(Value));
                     {$endif}
                     // do some verification here
                     if not _CheckFace[f] then
                     begin
                        if (_FaceSeeds[f] = -1) then
                        begin
                           FPreviousFaceList.Add(Value);
                           FFaceList.Add(f);
                           {$ifdef ORIGAMI_TEST}
                           GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
                           {$endif}
                        end;
                     end;
                     f := _FaceNeighbors.GetNextNeighbor;
                  end;
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
                  {$ifdef ORIGAMI_TEST}
                  GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being cloned as ' + IntToStr(High(_Vertices)+1) + ' using the following coordinates: [' + FloatToStr(CandidateUVPosition.U) + ', ' + FloatToStr(CandidateUVPosition.V) + '].');
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
                  GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being used, with the following coordinates: [' + FloatToStr(CandidateUVPosition.U) + ', ' + FloatToStr(CandidateUVPosition.V) + '].');
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

               // Check if other neighbors are elegible for this partition/seed.
               f := _FaceNeighbors.GetNeighborFromID(Value);
               while f <> -1 do
               begin
                  {$ifdef ORIGAMI_TEST}
                  GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(Value));
                  {$endif}
                  // do some verification here
                  if not _CheckFace[f] then
                  begin
                     if (_FaceSeeds[f] = -1) then
                     begin
                        FPreviousFaceList.Add(Value);
                        FFaceList.Add(f);
                        {$ifdef ORIGAMI_TEST}
                        GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
                        {$endif}
                     end;
                  end;
                  f := _FaceNeighbors.GetNextNeighbor;
               end;
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
   end;

   if _NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(_NeighborhoodPlugin^).UpdateEquivalencesOrigami(FVertsLocation);
   end;
   SetLength(FVertsLocation,0);
   VertexUtil.Free;
end;

procedure CTextureAtlasExtractorIDC.BuildFirstTriangle(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace: integer; var _VertexUtil: TVertexTransformationUtils; var _TextureSeed: TTextureSeed);
var
   vertex, f, FaceIndex: integer;
   Target,Edge0,Edge1: integer;
   Ang0, Ang1, cosAng0, cosAng1, sinAng0, sinAng1, Edge0Size: single;
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
      GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex) + ' has been changed to ' + IntToStr(High(_Vertices)));
      {$endif}
      _Faces[FaceIndex] := High(_Vertices);
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
      _TextCoords[High(_Vertices)].U := 1;
      _TextCoords[High(_Vertices)].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[High(_Vertices)].U) + ' ' + FloatToStr(_TextCoords[High(_Vertices)].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[High(_Vertices)].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[High(_Vertices)].V;
      if _TextCoords[High(_Vertices)].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[High(_Vertices)].V;
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
      _TextCoords[vertex].U := 1;
      _TextCoords[vertex].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[vertex].U) + ' ' + FloatToStr(_TextCoords[vertex].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[vertex].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[vertex].V;
      if _TextCoords[vertex].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[vertex].V;
   end;

   // Second vertex is (0,0).
   vertex := _Faces[FaceIndex+1];
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
      GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+1) + ' has been changed to ' + IntToStr(High(_Vertices)));
      {$endif}
      _Faces[FaceIndex+1] := High(_Vertices);
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
      _TextCoords[High(_Vertices)].U := 0;
      _TextCoords[High(_Vertices)].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[High(_Vertices)].U) + ' ' + FloatToStr(_TextCoords[High(_Vertices)].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[High(_Vertices)].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[High(_Vertices)].V;
      if _TextCoords[High(_Vertices)].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[High(_Vertices)].V;
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
      _TextCoords[vertex].U := 0;
      _TextCoords[vertex].V := 0;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[vertex].U) + ' ' + FloatToStr(_TextCoords[vertex].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[vertex].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[vertex].V;
      if _TextCoords[vertex].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[vertex].V;
   end;

   // Now, finally we have to figure out the 3rd vertex. That one depends on the angles.
   Target := _Faces[FaceIndex + 2];
   Edge0 := _Faces[FaceIndex];
   Edge1 := _Faces[FaceIndex + 1];

   GetAnglesFromCoordinates(_Vertices, Edge0, Edge1, Target, Ang0, Ang1);

   cosAng0 := cos(Ang0);
   cosAng1 := cos(Ang1);
   sinAng0 := sin(Ang0);
   sinAng1 := sin(Ang1);

   Edge0Size := sinAng1 / ((cosAng0 * sinAng1) + (cosAng1 * sinAng0));

   // Write the UV Position
   UVPosition.U := Edge0Size * cosAng0;
   UVPosition.V := Edge0Size * sinAng0;
   vertex := Target;
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
      GlobalVars.OrigamiFile.Add('Face item ' + IntToStr(FaceIndex+2) + ' has been changed to ' + IntToStr(High(_Vertices)));
      {$endif}
      _Faces[FaceIndex+2] := High(_Vertices);
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
      _TextCoords[High(_Vertices)].U := UVPosition.U;
      _TextCoords[High(_Vertices)].V := UVPosition.V;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[High(_Vertices)].U) + ' ' + FloatToStr(_TextCoords[High(_Vertices)].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[High(_Vertices)].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[High(_Vertices)].U;
      if _TextCoords[High(_Vertices)].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[High(_Vertices)].V;
      if _TextCoords[High(_Vertices)].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[High(_Vertices)].V;
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
      _TextCoords[vertex].U := UVPosition.U;
      _TextCoords[vertex].V := UVPosition.V;
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Vertex is ' + IntToStr(vertex) + ' and Position is: [' + FloatToStr(_TextCoords[vertex].U) + ' ' + FloatToStr(_TextCoords[vertex].V) + ']');
      {$endif}
      // Now update the bounds of the seed.
      if _TextCoords[vertex].U < _TextureSeed.MinBounds.U then
         _TextureSeed.MinBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].U > _TextureSeed.MaxBounds.U then
         _TextureSeed.MaxBounds.U := _TextCoords[vertex].U;
      if _TextCoords[vertex].V < _TextureSeed.MinBounds.V then
         _TextureSeed.MinBounds.V := _TextCoords[vertex].V;
      if _TextCoords[vertex].V > _TextureSeed.MaxBounds.V then
         _TextureSeed.MaxBounds.V := _TextCoords[vertex].V;
   end;

   // Add neighbour faces to the list.
   f := _FaceNeighbors.GetNeighborFromID(_StartingFace);
   while f <> -1 do
   begin
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' is neighbour of ' + IntToStr(_StartingFace));
      {$endif}
      // do some verification here
      if (_FaceSeeds[f] = -1) then
      begin
         FPreviousFaceList.Add(_StartingFace);
         FFaceList.Add(f);
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Face ' + IntToStr(f) + ' has been added to the list');
         {$endif}
      end;
      f := _FaceNeighbors.GetNextNeighbor;
   end;
end;

function CTextureAtlasExtractorIDC.CalculateDistortionFactor(_value: single): single;
begin
   if abs(_Value) >= 1 then
   begin
      Result := abs(_value) - 1;
   end
   else
   begin
      Result := 1 - abs(_value);
   end;
end;

procedure CTextureAtlasExtractorIDC.GetAnglesFromCoordinates(const _Vertices: TAVector3f; _Edge0, _Edge1, _Target: integer; var _Ang0, _Ang1: single);
const
   C_MIN_ANGLE = pi / 6;
   C_HALF_MIN_ANGLE = C_MIN_ANGLE / 2;
var
   i: integer;
   DirEdge,DirEdge0,DirEdge1: TVector3f;
   AngSum, DistortionSum: single;
   IdealAngles, OriginalAngles: afloat;
   DistortionFactor: afloat;
   IDs: auint32;
begin
   // Set memory
   SetLength(IDs, 3);
   SetLength(OriginalAngles, 3);
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
   OriginalAngles[0] := ArcCos(DotProduct(DirEdge0, DirEdge));
   OriginalAngles[1] := ArcCos(-1 * DotProduct(DirEdge1, DirEdge));
   OriginalAngles[2] := ArcCos(DotProduct(DirEdge0, DirEdge1));
   IdealAngles[0] := OriginalAngles[0] / FAngleFactor[GetVertexLocationID(IDs[0])];
   IdealAngles[1] := OriginalAngles[1] / FAngleFactor[GetVertexLocationID(IDs[1])];
   IdealAngles[2] := OriginalAngles[2] / FAngleFactor[GetVertexLocationID(IDs[2])];
   AngSum := IdealAngles[0] + IdealAngles[1] + IdealAngles[2];
   // Calculate resulting angles.
   if AngSum < pi then
   begin
      // We'll priorize the highest distortion factor.
      AngSum := pi - AngSum;
      DistortionSum := 0;
      for i := 0 to 2 do
      begin
         DistortionFactor[i] := FMaxDistortionFactor - CalculateDistortionFactor(FAngleFactor[GetVertexLocationID(IDs[i])]);
         DistortionSum := DistortionSum + DistortionFactor[i];
      end;
      if DistortionSum > 0 then
      begin
         _Ang0 := IdealAngles[0] + (AngSum * (DistortionFactor[0] / DistortionSum));
         _Ang1 := IdealAngles[1] + (AngSum * (DistortionFactor[1] / DistortionSum));
      end
      else
      begin
         _Ang0 := IdealAngles[0] + (AngSum / 3);
         _Ang1 := IdealAngles[1] + (AngSum / 3);
      end;
      {$ifdef ORIGAMI_TEST}
      AngSum := pi - AngSum;
      {$endif}
   end
   else if AngSum = pi then
   begin
      _Ang0 := (IdealAngles[0] / AngSum) * pi;
      _Ang1 := (IdealAngles[1] / AngSum) * pi;
   end
   else
   begin
      // We'll priorize the highest distortion factor.
      AngSum := AngSum - pi;
      DistortionSum := 0;
      for i := 0 to 2 do
      begin
         DistortionFactor[i] := FMaxDistortionFactor - CalculateDistortionFactor(FAngleFactor[GetVertexLocationID(IDs[i])]);
         DistortionSum := DistortionSum + DistortionFactor[i];
      end;
      if DistortionSum > 0 then
      begin
         _Ang0 := IdealAngles[0] - (AngSum * (DistortionFactor[0] / DistortionSum));
         _Ang1 := IdealAngles[1] - (AngSum * (DistortionFactor[1] / DistortionSum));
      end
      else
      begin
         _Ang0 := IdealAngles[0] - (AngSum / 3);
         _Ang1 := IdealAngles[1] - (AngSum / 3);
      end;
      {$ifdef ORIGAMI_TEST}
      AngSum := AngSum + pi;
      {$endif}
   end;

   // Self-Defense against absurdly deformed triangles.
   if _Ang0 < C_MIN_ANGLE then
   begin
      _Ang0 := C_MIN_ANGLE;
      _Ang1 := _Ang1 - C_HALF_MIN_ANGLE;
   end;
   if _Ang1 < C_MIN_ANGLE then
   begin
      _Ang0 := _Ang0 - C_HALF_MIN_ANGLE;
      _Ang1 := C_MIN_ANGLE;
   end;
   if (pi - (_Ang0 + _Ang1)) < C_MIN_ANGLE then
   begin
      _Ang0 := _Ang0 - C_HALF_MIN_ANGLE;
      _Ang1 := _Ang1 - C_HALF_MIN_ANGLE;
   end;

   // Report result if required.
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Triangle with the angles: (' + FloatToStr(OriginalAngles[0]) + ', ' + FloatToStr(OriginalAngles[1]) + ', ' + FloatToStr(OriginalAngles[2]) + ') has been deformed with the angles: (' + FloatToStr(IdealAngles[0]) + ', ' + FloatToStr(IdealAngles[1]) + ', ' + FloatToStr(IdealAngles[2]) + ') and, it generates the following angles: (' + FloatToStr(_Ang0) + ', ' + FloatToStr(_Ang1) + ', ' + FloatToStr(pi - (_Ang0 + _Ang1)) + ') where the factors are respectively ( ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Edge0)]) + ', ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Edge1)]) + ', ' + FloatToStr(FAngleFactor[GetVertexLocationID(_Target)]) + ') and AngleSum is ' + FloatToStr(AngSum) + ' .');
   {$endif}
   // Free memory.
   SetLength(IDs, 0);
   SetLength(IdealAngles, 0);
   SetLength(DistortionFactor, 0);
end;


end.
