unit TextureAtlasExtractorOrigami;

interface

uses BasicDataTypes, TextureAtlasExtractorBase, MeshPluginBase, NeighborDetector,
   Math, IntegerList, VertexTransformationUtils, Math3d, NeighborhoodDataPlugin,
   SysUtils;

{$INCLUDE source/Global_Conditionals.inc}
   
type
   CTextureAtlasExtractorOrigami = class (CTextureAtlasExtractorBase)
      private
         // Main functions
         function MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
      protected
         // Aux functions
         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
         function Get2DOuterProduct(const _Source,_V1, _V2: TVector2f): single;
         function Get90RotDirectionFromVector(const _V1,_V2: TVector2f): TVector2f;
         function Get90RotDirectionFromDirection(const _Direction: TVector2f): TVector2f;
         function GetTriangleCenterPosition(const _V0,_V1,_V2: TVector3f): TVector3f;
         function GetVertexLocationID(const _VertsLocation : aint32; _ID: integer): integer;
         procedure ObtainCommonEdgeFromFaces(var _Faces: auint32; const _VertsLocation : aint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2,_inFaceCurrVertPosition: integer);
      public
         function GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f; override;
   end;


implementation

uses GlobalVars;

function CTextureAtlasExtractorOrigami.GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
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
         _Seeds[NumSeeds] := MakeNewSeed(NumSeeds,_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,CheckFace);
         inc(NumSeeds);
      end;
   end;
   SetLength(_Seeds,NumSeeds);

   // Re-align vertexes and seed bounds to start at (0,0)
   ReAlignSeedsToCenter(_Seeds,_VertsSeed,FaceNeighbors,Result,FacePriority,FaceOrder,CheckFace,_NeighborhoodPlugin);
end;

function CTextureAtlasExtractorOrigami.MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
var
   v,f,Value,vertex,FaceIndex,PreviousFace : integer;
   CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1: integer;
   FaceList,PreviousFaceList : CIntegerList;
   Angle: single;
   Position,TriangleCenter: TVector3f;
   VertexUtil : TVertexTransformationUtils;
   VertsLocation : aint32;
   CandidateUVPosition: TVector2f;
   AddedFace: abool;
   FaceBackup: auint32;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   VertexUtil := TVertexTransformationUtils.Create;
   SetLength(FaceBackup,_VerticesPerFace);
   // Setup neighbor detection list
   FaceList := CIntegerList.Create;
   FaceList.UseFixedRAM(High(_CheckFace)+1);
   PreviousFaceList := CIntegerList.Create;
   PreviousFaceList.UseFixedRAM(High(_CheckFace)+1);
   // Setup VertsLocation
   SetLength(VertsLocation,High(_Vertices)+1);
   for v := Low(VertsLocation) to High(VertsLocation) do
   begin
      VertsLocation[v] := -1;
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
   Result.TransformMatrix := VertexUtil.GetTransformMatrixFromVector(_FaceNormals[_StartingFace]);
   Result.MinBounds.U := 999999;
   Result.MaxBounds.U := -999999;
   Result.MinBounds.V := 999999;
   Result.MaxBounds.V := -999999;
   Result.MeshID := _MeshID;
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Add('Transform Matrix is described below: ');
   for v := 0 to 3 do
   begin
      Temp := '|';
      for f := 0 to 3 do
      begin
         Temp := Temp + FloatToStr(Result.TransformMatrix[v,f]) + ' ';
      end;
      Temp := Temp + '|';
      GlobalVars.OrigamiFile.Add(Temp);
   end;
   {$endif}

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
         SetLength(VertsLocation,High(_Vertices)+1);
         VertsLocation[High(_Vertices)] := vertex;  // _VertsLocation works slightly different here than in the non-origami version.
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
         _TextCoords[High(_Vertices)] := VertexUtil.GetUVCoordinates(Position,Result.TransformMatrix);
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
         VertsLocation[vertex] := vertex;
         // Get temporary texture coordinates.
         _TextCoords[vertex] := VertexUtil.GetUVCoordinates(Position,Result.TransformMatrix);
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
      ObtainCommonEdgeFromFaces(_Faces,VertsLocation,_VerticesPerFace,Value,PreviousFace,CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1,v);
      {$ifdef ORIGAMI_TEST}
      GlobalVars.OrigamiFile.Add('Current Vertex = ' + IntToStr(CurrentVertex) + '; Previous Vertex = ' + IntToStr(PreviousVertex) + '; Share Edge = [' + IntToStr(SharedEdge0) + ', ' + IntToStr(SharedEdge1) + ']');
      {$endif}
      // Find coordinates and check if we won't hit another face.
      if IsValidUVPoint(_Vertices,_Faces,_TextCoords,CurrentVertex,SharedEdge0,SharedEdge1,PreviousVertex,_CheckFace,CandidateUVPosition,Value,PreviousFace,_VerticesPerFace) then
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
            if VertsLocation[CurrentVertex] <> -1 then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Vertex ' + IntToStr(CurrentVertex) + ' is being cloned as ' + IntToStr(High(_Vertices)+1));
               {$endif}

               // Clone vertex
               SetLength(_Vertices,High(_Vertices)+2);
               SetLength(_VertsSeed,High(_Vertices)+1);
               _VertsSeed[High(_VertsSeed)] := _ID;
               SetLength(VertsLocation,High(_Vertices)+1);
               VertsLocation[High(_Vertices)] := CurrentVertex;
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
               VertsLocation[CurrentVertex] := CurrentVertex;
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
            SetLength(VertsLocation,High(_Vertices)+1);
            VertsLocation[High(_Vertices)] := CurrentVertex;
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
      TNeighborhoodDataPlugin(_NeighborhoodPlugin^).UpdateEquivalencesOrigami(VertsLocation);
   end;
   SetLength(VertsLocation,0);
   SetLength(AddedFace,0);
   FaceList.Free;
   PreviousFaceList.Free;
   VertexUtil.Free;
end;

function CTextureAtlasExtractorOrigami.IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   EdgeSizeInMesh,EdgeSizeInUV,Scale,SinProjectionSizeInMesh,SinProjectionSizeInUV,ProjectionSizeInMesh,ProjectionSizeInUV: single;
   EdgeDirectionInUV,PositionOfTargetAtEdgeInUV,SinDirectionInUV: TVector2f;
   EdgeDirectionInMesh,PositionOfTargetAtEdgeInMesh: TVector3f;
   SourceSide: single;
   i,v: integer;
   VertexUtil : TVertexTransformationUtils;
begin
   VertexUtil := TVertexTransformationUtils.Create;
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
      Result := true;
      // the change in the _AddedFace temporary optimization for the upcoming loop.
      _CheckFace[_PreviousFace] := false;
      v := 0;
      for i := Low(_CheckFace) to High(_CheckFace) do
      begin
         // If the face was projected in the UV domain.
         if _CheckFace[i] then
         begin
            {$ifdef ORIGAMI_TEST}
            //GlobalVars.OrigamiFile.Add('Face ' + IntToStr(i) + ' has vertexes (' + FloatToStr(_TexCoords[_Faces[v]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v]].V) + '), (' + FloatToStr(_TexCoords[_Faces[v+1]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v+1]].V)  + '), (' + FloatToStr(_TexCoords[_Faces[v+2]].U) + ', ' + FloatToStr(_TexCoords[_Faces[v+2]].V) + ').');
            {$endif}
            // Check if the candidate position is inside this triangle.
            // If it is inside the triangle, then point is not validated. Exit.
            if VertexUtil.IsPointInsideTriangle(_TexCoords[_Faces[v]],_TexCoords[_Faces[v+1]],_TexCoords[_Faces[v+2]],_UVPosition) then
            begin
               {$ifdef ORIGAMI_TEST}
               GlobalVars.OrigamiFile.Add('Vertex textured coordinate (' + FloatToStr(_UVPosition.U) + ', ' + FloatToStr(_UVPosition.V) + ') conflicts with face ' + IntToStr(i) + '.');
               {$endif}
               Result := false;
               _CheckFace[_PreviousFace] := true;
               VertexUtil.Free;
               exit;
            end;
         end;
         inc(v,_VerticesPerFace);
      end;
      _CheckFace[_PreviousFace] := true;
   end;
   VertexUtil.Free;
end;

// Determinant from a matrix where first line is _Source, second is _V1 and 3rd is _V2.
function CTextureAtlasExtractorOrigami.Get2DOuterProduct(const _Source,_V1, _V2: TVector2f): single;
begin
   Result := (_Source.U * _V1.V) + (_Source.V * _V2.U) + (_V1.U * _V2.V) - (_Source.U * _V2.V) - (_Source.V * _V1.U) - (_V1.V * _V2.U);
end;

function CTextureAtlasExtractorOrigami.Get90RotDirectionFromVector(const _V1,_V2: TVector2f): TVector2f;
begin
   Result.U := _V1.V - _V2.V;
   Result.V := _V2.U - _V1.U;
   Normalize(Result);
end;

function CTextureAtlasExtractorOrigami.Get90RotDirectionFromDirection(const _Direction: TVector2f): TVector2f;
begin
   Result.U := -1 * _Direction.V;
   Result.V := _Direction.U;
   Normalize(Result);
end;

function CTextureAtlasExtractorOrigami.GetTriangleCenterPosition(const _V0,_V1,_V2: TVector3f): TVector3f;
var
   MaxWeight: single;
   Weight: array[0..2] of single;
   Distance: array[0..2] of single;
begin
   Distance[0] := VectorDistance(_V1,_V2);
   Distance[1] := VectorDistance(_V0,_V2);
   Distance[2] := VectorDistance(_V0,_V1);
   Weight[0] := (Distance[1] + Distance[2]);
   Weight[1] := (Distance[0] + Distance[2]);
   Weight[2] := (Distance[0] + Distance[1]);
   MaxWeight := Weight[0] + Weight[1] + Weight[2];
   Weight[0] := Weight[0] / MaxWeight;
   Weight[1] := Weight[1] / MaxWeight;
   Weight[2] := Weight[2] / MaxWeight;
   Result.X := (_V0.X * Weight[0]) + (_V1.X * Weight[1]) + (_V2.X * Weight[2]);
   Result.Y := (_V0.Y * Weight[0]) + (_V1.Y * Weight[1]) + (_V2.Y * Weight[2]);
   Result.Z := (_V0.Z * Weight[0]) + (_V1.Z * Weight[1]) + (_V2.Z * Weight[2]);
end;

function CTextureAtlasExtractorOrigami.GetVertexLocationID(const _VertsLocation : aint32; _ID: integer): integer;
begin
   if _VertsLocation[_ID] = -1 then
   begin
      Result := _ID;
   end
   else
   begin
      Result := _VertsLocation[_ID];
   end;
end;

// That's the time of the day that we miss a half edge structure (even if a
// fragmented memory makes Delphi go wild)
procedure CTextureAtlasExtractorOrigami.ObtainCommonEdgeFromFaces(var _Faces: auint32; const _VertsLocation : aint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2,_inFaceCurrVertPosition: integer);
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
   for i := Low(_VertsLocation) to High(_VertsLocation) do
   begin
      Temp := Temp + IntToStr(_VertsLocation[i]) + ' ';
   end;
   Temp := Temp + ']';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}

   // Real code starts here.
   // Find a vertex that is in both faces and call it _CommonVertex1
   i := 0;
   Found := false;
   while (i < _VerticesPerFace) and (not Found) do
   begin
      j := 0;
      while (j < _VerticesPerFace) and (not Found) do
      begin
         if GetVertexLocationID(_VertsLocation,_Faces[mincface+i]) = GetVertexLocationID(_VertsLocation,_Faces[minpface+j]) then
         begin
            _CommonVertex1 := _Faces[minpface+j];
            _Faces[mincface+i] := _CommonVertex1; // ensure synchornization
            Found := true;
         end
         else
         begin
            inc(j);
         end;
      end;
      if not Found then
      begin
         inc(i);
      end;
   end;
   // Try the next element
   if GetVertexLocationID(_VertsLocation,_Faces[mincface + ((i + 1) mod _VerticesPerFace)]) = GetVertexLocationID(_VertsLocation,_Faces[minpface + ((j + _VerticesPerFace - 1) mod _VerticesPerFace)]) then
   begin
      _CommonVertex2 := _Faces[minpface + ((j + _VerticesPerFace - 1) mod _VerticesPerFace)];
      _Faces[mincface + ((i + 1) mod _VerticesPerFace)] := _CommonVertex2; // ensure synchronization
      _inFaceCurrVertPosition := (i + _VerticesPerFace - 1) mod _VerticesPerFace;
      _CurrentVertex := _Faces[mincface + _inFaceCurrVertPosition];
      _PreviousVertex := _Faces[minpface + ((j + 1) mod _VerticesPerFace)];
   end
   else // Then, it is the previous element.
   begin
      // PS: I'm not sure if _CommonVertex2 may have orientation problems here. To do: Check it out later.
      _CommonVertex2 := _Faces[minpface + ((j + 1) mod _VerticesPerFace)];
      _Faces[mincface + ((i + _VerticesPerFace - 1) mod _VerticesPerFace)] := _CommonVertex2;
      _inFaceCurrVertPosition := (i + 1) mod _VerticesPerFace;
      _CurrentVertex := _Faces[mincface + _inFaceCurrVertPosition];
      _PreviousVertex := _Faces[minpface + ((j + _VerticesPerFace - 1) mod _VerticesPerFace)];
   end;
end;

end.
