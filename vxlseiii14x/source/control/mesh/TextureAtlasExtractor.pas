unit TextureAtlasExtractor;

interface

uses GLConstants, BasicDataTypes, Geometry, NeighborDetector,
   IntegerList, Math, VertexTransformationUtils, NeighborhoodDataPlugin,
   MeshPluginBase, SysUtils, GeometricAlgebra, Multivector, TextureAtlasExtractorBase;

{$INCLUDE source/Global_Conditionals.inc}

// This is the Texture Atlas Extraction Method published in SBGames 2010.
type
   CTextureAtlasExtractor = class(CTextureAtlasExtractorBase)
      private
         FTextureAngle: single;
         // Seeds
         function MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
         // Angle stuff
         function GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
      public
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(_TextureAngle: single); overload;
         // Executes
         function GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace: integer): TAVector2f;
         // Texture atlas buildup: step by step.
         function GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
   end;

implementation

uses Math3d, GlobalVars;

constructor CTextureAtlasExtractor.Create;
begin
   FTextureAngle := C_TEX_MIN_ANGLE;
   Initialize;
end;

constructor CTextureAtlasExtractor.Create(_TextureAngle : single);
begin
   FTextureAngle := _TextureAngle;
   Initialize;
end;

// Angle operations
function CTextureAtlasExtractor.GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
begin
   Result := (_Vec1.X * _Vec2.X) + (_Vec1.Y * _Vec2.Y) + (_Vec1.Z * _Vec2.Z);
end;

// Executes
function CTextureAtlasExtractor.GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
var
   i, MaxVerts,NumSeeds: integer;
   VertsLocation,FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
begin
   SetLength(VertsLocation,High(_Vertices)+1);
   SetupMeshSeeds(_Vertices,_FaceNormals,_Faces,_VerticesPerFace,_Seeds,_VertsSeed,FaceNeighbors,Result,MaxVerts,FaceSeed,FacePriority,FaceOrder,CheckFace);

   // Let's build the seeds.
   NumSeeds := High(_Seeds)+1;
   SetLength(_Seeds,NumSeeds + High(FaceSeed)+1);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      if FaceSeed[FaceOrder[i]] = -1 then
      begin
         // Make new seed.
         _Seeds[NumSeeds] := MakeNewSeed(NumSeeds,_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,VertsLocation,CheckFace);
         inc(NumSeeds);
      end;
   end;
   SetLength(_Seeds,NumSeeds);

   // Re-align vertexes and seed bounds to start at (0,0)
   ReAlignSeedsToCenter(_Seeds,_VertsSeed,FaceNeighbors,Result,FacePriority,FaceOrder,CheckFace,_NeighborhoodPlugin);
   SetLength(VertsLocation,0);
end;

function CTextureAtlasExtractor.MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
const
   C_MIN_ANGLE = 0.001; // approximately cos 90'
var
   v,f,Value,vertex,FaceIndex : integer;
   List : CIntegerList;
   Angle: single;
   VertexUtil : TVertexTransformationUtils;
begin
   VertexUtil := TVertexTransformationUtils.Create;
   // Setup neighbor detection list
   List := CIntegerList.Create;
   List.UseFixedRAM((High(_CheckFace) + 1));
   // Setup VertsLocation
   for v := Low(_VertsLocation) to High(_VertsLocation) do
   begin
      _VertsLocation[v] := -1;
   end;
   // Avoid unlimmited loop
   for f := Low(_CheckFace) to High(_CheckFace) do
      _CheckFace[f] := false;

   // Add starting face
   List.Add(_StartingFace);
   _CheckFace[_StartingFace] := true;
   Result.TransformMatrix := VertexUtil.GetTransformMatrixFromVector(_FaceNormals[_StartingFace]);
   Result.MinBounds.U := 999999;
   Result.MaxBounds.U := -999999;
   Result.MinBounds.V := 999999;
   Result.MaxBounds.V := -999999;
   Result.MeshID := _MeshID;

   // Neighbour Face Scanning starts here.
   while List.GetValue(Value) do
   begin
      // Add face here
      // Add the face and its vertexes
      _FaceSeeds[Value] := _ID;
      FaceIndex := Value * _VerticesPerFace;
      for v := 0 to _VerticesPerFace - 1 do
      begin
         vertex := _Faces[FaceIndex+v];
         if _VertsSeed[vertex] <> -1 then
         begin
            if _VertsLocation[vertex] = -1 then
            begin
               // this vertex was used by a previous seed, therefore, we'll clone it
               SetLength(_Vertices,High(_Vertices)+2);
               SetLength(_VertsSeed,High(_Vertices)+1);
               _VertsSeed[High(_VertsSeed)] := _ID;
               _VertsLocation[vertex] := High(_Vertices);
               _Faces[FaceIndex+v] := _VertsLocation[vertex];
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
               _TextCoords[High(_Vertices)] := VertexUtil.GetUVCoordinates(_Vertices[vertex],Result.TransformMatrix);
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
               // This vertex is already used by this seed.
               _Faces[FaceIndex+v] := _VertsLocation[vertex];
            end;
         end
         else
         begin
            // This seed is the first seed to use this vertex.
            _VertsSeed[vertex] := _ID;
            _VertsLocation[vertex] := vertex;
            // Get temporary texture coordinates.
            _TextCoords[vertex] := VertexUtil.GetUVCoordinates(_Vertices[vertex],Result.TransformMatrix);
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


      // Check if other neighbors are elegible for this partition/seed.
      f := _FaceNeighbors.GetNeighborFromID(Value);
      while f <> -1 do
      begin
         // do some verification here
         if not _CheckFace[f] then
         begin
            if (_FaceSeeds[f] = -1) then
            begin
               // check if angle (which actually receives a cosine) is less than FTextureAngle
               Angle := GetVectorAngle(_FaceNormals[_StartingFace],_FaceNormals[f]);
               if Angle >= FTextureAngle then
               begin
                  List.Add(f);
//             end
//             else
//             begin
//                ShowMessage('Starting Face: (' + FloatToStr(_FaceNormals[_StartingFace].X) + ', ' + FloatToStr(_FaceNormals[_StartingFace].Y) + ', ' + FloatToStr(_FaceNormals[_StartingFace].Z) + ') and Current Face is (' + FloatToStr(_FaceNormals[f].X) + ', ' + FloatToStr(_FaceNormals[f].Y) + ', ' + FloatToStr(_FaceNormals[f].Z) + ') and the angle is ' + FloatToStr(Angle));
               end;
            end;
            _CheckFace[f] := true;
         end;
         f := _FaceNeighbors.GetNextNeighbor;
      end;
   end;

   if _NeighborhoodPlugin <> nil then
   begin
      TNeighborhoodDataPlugin(_NeighborhoodPlugin^).UpdateEquivalences(_VertsLocation);
   end;
   List.Free;
   VertexUtil.Free;
end;

// Deprecated...
function CTextureAtlasExtractor.GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace: integer): TAVector2f;
var
   i, x, MaxVerts, Current, Previous: integer;
   VertsLocation,FaceSeed,VertsSeed : aint32;
   FacePriority: AFloat;
   FaceOrder,UOrder,VOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
   UMerge,VMerge,UMax,VMax,PushValue: real;
   HiO,HiS: integer;
   Seeds: TSeedSet;
   SeedTree : TSeedTree;
   List : CIntegerList;
   SeedSeparatorSpace: single;
begin
   // Get the neighbours of each face.
   if _NeighborhoodPlugin <> nil then
   begin
      FaceNeighbors := TNeighborhoodDataPlugin(_NeighborhoodPlugin^).FaceFaceNeighbors;
   end
   else
   begin
      FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
      FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);
   end;
   // Setup FaceSeed, FaceOrder and FacePriority.
   SetLength(FaceSeed,High(_FaceNormals)+1);
   SetLength(FaceOrder,High(FaceSeed)+1);
   SetLength(FacePriority,High(FaceSeed)+1);
   SetLength(VertsLocation,High(_Vertices)+1);
   SetLength(CheckFace,High(_FaceNormals)+1);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      FaceSeed[i] := -1;
      FaceOrder[i] := i;
      FacePriority[i] := Max(Max(abs(_FaceNormals[i].X),abs(_FaceNormals[i].Y)),abs(_FaceNormals[i].Z));
   end;
   QuickSortPriority(Low(FaceOrder),High(FaceOrder),FaceOrder,FacePriority);

   // Setup VertsSeed.
   MaxVerts := High(_Vertices)+1;
   SetLength(VertsSeed,MaxVerts);
   for i := Low(VertsSeed) to High(VertsSeed) do
   begin
      VertsSeed[i] := -1;
   end;
   // Setup Seeds.
   SetLength(Seeds,0);
   // Setup Texture Coordinates (Result)
   SetLength(Result,MaxVerts);

   // Let's build the seeds.
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      if FaceSeed[FaceOrder[i]] = -1 then
      begin
         // Make new seed.
         SetLength(Seeds,High(Seeds)+2);
         Seeds[High(Seeds)] := MakeNewSeed(High(Seeds),0,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,VertsLocation,CheckFace);
      end;
   end;

   // Re-align vertexes and seed bounds to start at (0,0)
   for i := Low(VertsSeed) to High(VertsSeed) do
   begin
      Result[i].U := Result[i].U - Seeds[VertsSeed[i]].MinBounds.U;
      Result[i].V := Result[i].V - Seeds[VertsSeed[i]].MinBounds.V;
   end;

   for i := Low(Seeds) to High(Seeds) do
   begin
      Seeds[i].MaxBounds.U := Seeds[i].MaxBounds.U - Seeds[i].MinBounds.U;
      Seeds[i].MinBounds.U := 0;
      Seeds[i].MaxBounds.V := Seeds[i].MaxBounds.V - Seeds[i].MinBounds.V;
      Seeds[i].MinBounds.V := 0;
   end;

   // Now, we need to setup two lists: one ordered by u and another ordered by v.
   HiO := High(Seeds);      // That's the index for the last useful element of the U and V order buffers
   SetLength(UOrder,HiO+1);
   SetLength(VOrder,HiO+1);
   for i := Low(UOrder) to High(UOrder) do
   begin
      UOrder[i] := i;
      VOrder[i] := i;
   end;
   QuickSortSeeds(Low(UOrder),HiO,UOrder,Seeds,CompareU);
   QuickSortSeeds(Low(VOrder),HiO,VOrder,Seeds,CompareV);
   HiS := HiO;   // That's the index for the last useful seed and seed tree item.
   SetLength(Seeds,(2*HiS)+1);

   // Let's calculate the required space to separate one seed from others.
   // Get the smallest dimension of the smallest partitions.
   SeedSeparatorSpace := 0.03 * max(Seeds[VOrder[Low(VOrder)]].MaxBounds.V - Seeds[VOrder[Low(VOrder)]].MinBounds.V,Seeds[UOrder[Low(UOrder)]].MaxBounds.U - Seeds[UOrder[Low(UOrder)]].MinBounds.U);

   // Then, we start a SeedTree, which we'll use to ajust the bounds from seeds
   // inside bigger seeds.
   SetLength(SeedTree,High(Seeds)+1);
   for i := Low(SeedTree) to High(SeedTree) do
   begin
      SeedTree[i].Left := -1;
      SeedTree[i].Right := -1;
   end;

   // Setup seed tree detection list
   List := CIntegerList.Create;
   List.UseSmartMemoryManagement(true);

   // We'll now start the main loop. We merge the smaller seeds into bigger seeds until we only have on seed left.
   while HiO > 0 do
   begin
      // Select the last two seeds from UOrder and VOrder and check which merge
      // uses less space.
      UMerge := ( (Seeds[UOrder[HiO]].MaxBounds.U - Seeds[UOrder[HiO]].MinBounds.U) + SeedSeparatorSpace + (Seeds[UOrder[HiO-1]].MaxBounds.U - Seeds[UOrder[HiO-1]].MinBounds.U) ) * max((Seeds[UOrder[HiO]].MaxBounds.V - Seeds[UOrder[HiO]].MinBounds.V),(Seeds[UOrder[HiO-1]].MaxBounds.V - Seeds[UOrder[HiO-1]].MinBounds.V));
      VMerge := ( (Seeds[VOrder[HiO]].MaxBounds.V - Seeds[VOrder[HiO]].MinBounds.V) + SeedSeparatorSpace + (Seeds[VOrder[HiO-1]].MaxBounds.V - Seeds[VOrder[HiO-1]].MinBounds.V) ) * max((Seeds[VOrder[HiO]].MaxBounds.U - Seeds[VOrder[HiO]].MinBounds.U),(Seeds[VOrder[HiO-1]].MaxBounds.U - Seeds[VOrder[HiO-1]].MinBounds.U));
      UMax := max(( (Seeds[UOrder[HiO]].MaxBounds.U - Seeds[UOrder[HiO]].MinBounds.U) + SeedSeparatorSpace + (Seeds[UOrder[HiO-1]].MaxBounds.U - Seeds[UOrder[HiO-1]].MinBounds.U) ),max((Seeds[UOrder[HiO]].MaxBounds.V - Seeds[UOrder[HiO]].MinBounds.V),(Seeds[UOrder[HiO-1]].MaxBounds.V - Seeds[UOrder[HiO-1]].MinBounds.V)));
      VMax := max(( (Seeds[VOrder[HiO]].MaxBounds.V - Seeds[VOrder[HiO]].MinBounds.V) + SeedSeparatorSpace + (Seeds[VOrder[HiO-1]].MaxBounds.V - Seeds[VOrder[HiO-1]].MinBounds.V) ),max((Seeds[VOrder[HiO]].MaxBounds.U - Seeds[VOrder[HiO]].MinBounds.U),(Seeds[VOrder[HiO-1]].MaxBounds.U - Seeds[VOrder[HiO-1]].MinBounds.U)));
      inc(HiS);
      Seeds[HiS].MinBounds.U := 0;
      Seeds[HiS].MinBounds.V := 0;
      if IsVLower(UMerge,VMerge,UMax,VMax) then
      begin
         // So, we'll merge the last two elements of VOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         Seeds[HiS].MaxBounds.U := max((Seeds[VOrder[HiO]].MaxBounds.U - Seeds[VOrder[HiO]].MinBounds.U),(Seeds[VOrder[HiO-1]].MaxBounds.U - Seeds[VOrder[HiO-1]].MinBounds.U));
         Seeds[HiS].MaxBounds.V := (Seeds[VOrder[HiO]].MaxBounds.V - Seeds[VOrder[HiO]].MinBounds.V) + SeedSeparatorSpace + (Seeds[VOrder[HiO-1]].MaxBounds.V - Seeds[VOrder[HiO-1]].MinBounds.V);
         // Insert the last two elements from VOrder at the new seed tree element.
         SeedTree[HiS].Left := VOrder[HiO-1];
         SeedTree[HiS].Right := VOrder[HiO];
         // Now we translate the bounds of the element in the 'right' down, where it
         // belongs, and do it recursively.
         PushValue := (Seeds[VOrder[HiO-1]].MaxBounds.V - Seeds[VOrder[HiO-1]].MinBounds.V) + SeedSeparatorSpace;
         List.Add(SeedTree[HiS].Right);
         while List.GetValue(i) do
         begin
            Seeds[i].MinBounds.V := Seeds[i].MinBounds.V + PushValue;
            Seeds[i].MaxBounds.V := Seeds[i].MaxBounds.V + PushValue;
            if SeedTree[i].Left <> -1 then
               List.Add(SeedTree[i].Left);
            if SeedTree[i].Right <> -1 then
               List.Add(SeedTree[i].Right);
         end;
         // Remove the last two elements of VOrder from UOrder and add the new seed.
         i := 0;
         x := 0;

         while i <= HiO do
         begin
            if (UOrder[i] = VOrder[HiO]) or (UOrder[i] = VOrder[HiO-1]) then
               inc(x)
            else
               UOrder[i - x] := UOrder[i];
            inc(i);
         end;
         dec(HiO);
         Current := HiO div 2;
         SeedBinarySearch(HiS,0,HiO-1,UOrder,Seeds,CompareU,Current,Previous);
         i := HiO;
         while i > (Previous+1) do
         begin
            UOrder[i] := UOrder[i-1];
            dec(i);
         end;
         UOrder[Previous+1] := HiS;

         // Now we remove the last two elements from VOrder and add the new seed.
         Current := HiO div 2;
         SeedBinarySearch(HiS,0,HiO-1,VOrder,Seeds,CompareV,Current,Previous);
         i := HiO;
         while i > (Previous+1) do
         begin
            VOrder[i] := VOrder[i-1];
            dec(i);
         end;
         VOrder[Previous+1] := HiS;

      end
      else  // UMerge <= VMerge
      begin
         // So, we'll merge the last two elements of UOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         Seeds[HiS].MaxBounds.U := (Seeds[UOrder[HiO]].MaxBounds.U - Seeds[UOrder[HiO]].MinBounds.U) + SeedSeparatorSpace + (Seeds[UOrder[HiO-1]].MaxBounds.U - Seeds[UOrder[HiO-1]].MinBounds.U);
         Seeds[HiS].MaxBounds.V := max((Seeds[UOrder[HiO]].MaxBounds.V - Seeds[UOrder[HiO]].MinBounds.V),(Seeds[UOrder[HiO-1]].MaxBounds.V - Seeds[UOrder[HiO-1]].MinBounds.V));
         // Insert the last two elements from UOrder at the new seed tree element.
         SeedTree[HiS].Left := UOrder[HiO-1];
         SeedTree[HiS].Right := UOrder[HiO];
         // Now we translate the bounds of the element in the 'right' to the right,
         // where it belongs, and do it recursively.
         PushValue := (Seeds[UOrder[HiO-1]].MaxBounds.U - Seeds[UOrder[HiO-1]].MinBounds.U) + SeedSeparatorSpace;
         List.Add(SeedTree[HiS].Right);
         while List.GetValue(i) do
         begin
            Seeds[i].MinBounds.U := Seeds[i].MinBounds.U + PushValue;
            Seeds[i].MaxBounds.U := Seeds[i].MaxBounds.U + PushValue;
            if SeedTree[i].Left <> -1 then
               List.Add(SeedTree[i].Left);
            if SeedTree[i].Right <> -1 then
               List.Add(SeedTree[i].Right);
         end;

         // Remove the last two elements of UOrder from VOrder and add the new seed.
         i := 0;
         x := 0;
         while i <= HiO do
         begin
            if (VOrder[i] = UOrder[HiO]) or (VOrder[i] = UOrder[HiO-1]) then
               inc(x)
            else
               VOrder[i - x] := VOrder[i];
            inc(i);
         end;
         dec(HiO);
         Current := HiO div 2;
         SeedBinarySearch(HiS,0,HiO-1,VOrder,Seeds,CompareV,Current,Previous);
         i := HiO;
         while i > (Previous+1) do
         begin
            VOrder[i] := VOrder[i-1];
            dec(i);
         end;
         VOrder[Previous+1] := HiS;

         // Now we remove the last two elements from UOrder and add the new seed.
         Current := HiO div 2;
         SeedBinarySearch(HiS,0,HiO-1,UOrder,Seeds,CompareU,Current,Previous);
         i := HiO;
         while i > (Previous+1) do
         begin
            UOrder[i] := UOrder[i-1];
            dec(i);
         end;
         UOrder[Previous+1] := HiS;
      end;
   end;

   // The texture must be a square, so we'll centralize the smallest dimension.
   if (Seeds[High(Seeds)].MaxBounds.U > Seeds[High(Seeds)].MaxBounds.V) then
   begin
      PushValue := (Seeds[High(Seeds)].MaxBounds.U - Seeds[High(Seeds)].MaxBounds.V) / 2;
      for i := Low(Seeds) to (High(Seeds)-1) do
      begin
         Seeds[i].MinBounds.V := Seeds[i].MinBounds.V + PushValue;
         Seeds[i].MaxBounds.V := Seeds[i].MaxBounds.V + PushValue;
      end;
      Seeds[High(Seeds)].MaxBounds.V := Seeds[High(Seeds)].MaxBounds.U;
   end
   else if (Seeds[High(Seeds)].MaxBounds.U < Seeds[High(Seeds)].MaxBounds.V) then
   begin
      PushValue := (Seeds[High(Seeds)].MaxBounds.V - Seeds[High(Seeds)].MaxBounds.U) / 2;
      for i := Low(Seeds) to (High(Seeds)-1) do
      begin
         Seeds[i].MinBounds.U := Seeds[i].MinBounds.U + PushValue;
         Seeds[i].MaxBounds.U := Seeds[i].MaxBounds.U + PushValue;
      end;
      Seeds[High(Seeds)].MaxBounds.U := Seeds[High(Seeds)].MaxBounds.V;
   end;
   // Let's get the final texture coordinates for each vertex now.
   for i := Low(Result) to High(Result) do
   begin
      Result[i].U := (Seeds[VertsSeed[i]].MinBounds.U + Result[i].U) / Seeds[High(Seeds)].MaxBounds.U;
      Result[i].V := (Seeds[VertsSeed[i]].MinBounds.V + Result[i].V) / Seeds[High(Seeds)].MaxBounds.V;
   end;

   // Clean up memory.
   SetLength(SeedTree,0);
   SetLength(Seeds,0);
   SetLength(FaceSeed,0);
   SetLength(VertsSeed,0);
   SetLength(UOrder,0);
   SetLength(VOrder,0);
   SetLength(FacePriority,0);
   SetLength(FaceOrder,0);
   SetLength(CheckFace,0);
   SetLength(VertsLocation,0);
   List.Free;
   if _NeighborhoodPlugin = nil then
      FaceNeighbors.Free;
end;

end.
