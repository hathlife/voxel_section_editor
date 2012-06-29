unit ClassTextureAtlasExtractor;

interface

uses GLConstants, BasicDataTypes, Geometry, ClassNeighborDetector,
   ClassIntegerList, Math, ClassVertexTransformationUtils, NeighborhoodDataPlugin,
   MeshPluginBase;

type
   TTextureSeed = record
      MinBounds, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
      MeshID : integer;
   end;

   TSeedSet = array of TTextureSeed;
   TTexCompareFunction = function (const _Seed1, _Seed2 : TTextureSeed): real of object;

   CTextureAtlasExtractor = class
      private
         FTextureAngle: single;
         // Seeds
         function MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
         function MakeNewSeedOrigami(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
         function isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
         // Angle stuff
         function GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
         // Sort related functions
         function CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
         function CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
         procedure QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
         procedure QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
         function SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
         procedure ObtainCommonEdgeFromFaces(const _Faces: auint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2: integer);
      public
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(_TextureAngle: single); overload;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Executes
         function GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace: integer): TAVector2f;
         // Texture atlas buildup: step by step.
         function GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
         procedure MergeSeeds(var _Seeds: TSeedSet);
         procedure GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
   end;

implementation

uses Math3d;

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

destructor CTextureAtlasExtractor.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTextureAtlasExtractor.Initialize;
begin
   // do nothing
end;

procedure CTextureAtlasExtractor.Clear;
begin
   // do nothing
end;

procedure CTextureAtlasExtractor.Reset;
begin
   Clear;
   Initialize;
end;

// Angle operations
function CTextureAtlasExtractor.GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
begin
   Result := (_Vec1.X * _Vec2.X) + (_Vec1.Y * _Vec2.Y) + (_Vec1.Z * _Vec2.Z);
end;

// Executes
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

function CTextureAtlasExtractor.GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
var
   i, MaxVerts: integer;
   VertsLocation,FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
begin
   // Get the neighbours of each face.
   FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
   FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);

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
   SetLength(_VertsSeed,MaxVerts);
   for i := Low(_VertsSeed) to High(_VertsSeed) do
   begin
      _VertsSeed[i] := -1;
   end;
   // Setup Texture Coordinates (Result)
   SetLength(Result,MaxVerts);

   // Let's build the seeds.
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      if FaceSeed[FaceOrder[i]] = -1 then
      begin
         // Make new seed.
         SetLength(_Seeds,High(_Seeds)+2);
         _Seeds[High(_Seeds)] := MakeNewSeed(High(_Seeds),_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,VertsLocation,CheckFace);
      end;
   end;

   // Re-align vertexes and seed bounds to start at (0,0)
   for i := Low(_VertsSeed) to High(_VertsSeed) do
   begin
      Result[i].U := Result[i].U - _Seeds[_VertsSeed[i]].MinBounds.U;
      Result[i].V := Result[i].V - _Seeds[_VertsSeed[i]].MinBounds.V;
   end;

   for i := Low(_Seeds) to High(_Seeds) do
   begin
      _Seeds[i].MaxBounds.U := _Seeds[i].MaxBounds.U - _Seeds[i].MinBounds.U;
      _Seeds[i].MinBounds.U := 0;
      _Seeds[i].MaxBounds.V := _Seeds[i].MaxBounds.V - _Seeds[i].MinBounds.V;
      _Seeds[i].MinBounds.V := 0;
   end;

   if _NeighborhoodPlugin = nil then
   begin
      FaceNeighbors.Free;
   end;
   SetLength(FacePriority,0);
   SetLength(FaceOrder,0);
   SetLength(CheckFace,0);
   SetLength(VertsLocation,0);
end;

procedure CTextureAtlasExtractor.MergeSeeds(var _Seeds: TSeedSet);
var
   i, x, Current, Previous: integer;
   UOrder,VOrder : auint32;
   UMerge,VMerge,UMax,VMax,PushValue: real;
   HiO,HiS: integer;
   SeedTree : TSeedTree;
   List : CIntegerList;
   SeedSeparatorSpace: single;
begin
   // Now, we need to setup two lists: one ordered by u and another ordered by v.
   HiO := High(_Seeds);      // That's the index for the last useful element of the U and V order buffers
   SetLength(UOrder,HiO+1);
   SetLength(VOrder,HiO+1);
   for i := Low(UOrder) to High(UOrder) do
   begin
      UOrder[i] := i;
      VOrder[i] := i;
   end;
   QuickSortSeeds(Low(UOrder),HiO,UOrder,_Seeds,CompareU);
   QuickSortSeeds(Low(VOrder),HiO,VOrder,_Seeds,CompareV);
   HiS := HiO;   // That's the index for the last useful seed and seed tree item.
   SetLength(_Seeds,(2*HiS)+1);

   // Let's calculate the required space to separate one seed from others.
   // Get the smallest dimension of the smallest partitions.
   SeedSeparatorSpace := 0.03 * max(_Seeds[VOrder[Low(VOrder)]].MaxBounds.V - _Seeds[VOrder[Low(VOrder)]].MinBounds.V,_Seeds[UOrder[Low(UOrder)]].MaxBounds.U - _Seeds[UOrder[Low(UOrder)]].MinBounds.U);

   // Then, we start a SeedTree, which we'll use to ajust the bounds from seeds
   // inside bigger seeds.
   SetLength(SeedTree,High(_Seeds)+1);
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
      UMerge := ( (_Seeds[UOrder[HiO]].MaxBounds.U - _Seeds[UOrder[HiO]].MinBounds.U) + SeedSeparatorSpace + (_Seeds[UOrder[HiO-1]].MaxBounds.U - _Seeds[UOrder[HiO-1]].MinBounds.U) ) * max((_Seeds[UOrder[HiO]].MaxBounds.V - _Seeds[UOrder[HiO]].MinBounds.V),(_Seeds[UOrder[HiO-1]].MaxBounds.V - _Seeds[UOrder[HiO-1]].MinBounds.V));
      VMerge := ( (_Seeds[VOrder[HiO]].MaxBounds.V - _Seeds[VOrder[HiO]].MinBounds.V) + SeedSeparatorSpace + (_Seeds[VOrder[HiO-1]].MaxBounds.V - _Seeds[VOrder[HiO-1]].MinBounds.V) ) * max((_Seeds[VOrder[HiO]].MaxBounds.U - _Seeds[VOrder[HiO]].MinBounds.U),(_Seeds[VOrder[HiO-1]].MaxBounds.U - _Seeds[VOrder[HiO-1]].MinBounds.U));
      UMax := max(( (_Seeds[UOrder[HiO]].MaxBounds.U - _Seeds[UOrder[HiO]].MinBounds.U) + SeedSeparatorSpace + (_Seeds[UOrder[HiO-1]].MaxBounds.U - _Seeds[UOrder[HiO-1]].MinBounds.U) ),max((_Seeds[UOrder[HiO]].MaxBounds.V - _Seeds[UOrder[HiO]].MinBounds.V),(_Seeds[UOrder[HiO-1]].MaxBounds.V - _Seeds[UOrder[HiO-1]].MinBounds.V)));
      VMax := max(( (_Seeds[VOrder[HiO]].MaxBounds.V - _Seeds[VOrder[HiO]].MinBounds.V) + SeedSeparatorSpace + (_Seeds[VOrder[HiO-1]].MaxBounds.V - _Seeds[VOrder[HiO-1]].MinBounds.V) ),max((_Seeds[VOrder[HiO]].MaxBounds.U - _Seeds[VOrder[HiO]].MinBounds.U),(_Seeds[VOrder[HiO-1]].MaxBounds.U - _Seeds[VOrder[HiO-1]].MinBounds.U)));
      inc(HiS);
      _Seeds[HiS].MinBounds.U := 0;
      _Seeds[HiS].MinBounds.V := 0;
      if IsVLower(UMerge,VMerge,UMax,VMax) then
      begin
         // So, we'll merge the last two elements of VOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         _Seeds[HiS].MaxBounds.U := max((_Seeds[VOrder[HiO]].MaxBounds.U - _Seeds[VOrder[HiO]].MinBounds.U),(_Seeds[VOrder[HiO-1]].MaxBounds.U - _Seeds[VOrder[HiO-1]].MinBounds.U));
         _Seeds[HiS].MaxBounds.V := (_Seeds[VOrder[HiO]].MaxBounds.V - _Seeds[VOrder[HiO]].MinBounds.V) + SeedSeparatorSpace + (_Seeds[VOrder[HiO-1]].MaxBounds.V - _Seeds[VOrder[HiO-1]].MinBounds.V);
         // Insert the last two elements from VOrder at the new seed tree element.
         SeedTree[HiS].Left := VOrder[HiO-1];
         SeedTree[HiS].Right := VOrder[HiO];
         // Now we translate the bounds of the element in the 'right' down, where it
         // belongs, and do it recursively.
         PushValue := (_Seeds[VOrder[HiO-1]].MaxBounds.V - _Seeds[VOrder[HiO-1]].MinBounds.V) + SeedSeparatorSpace;
         List.Add(SeedTree[HiS].Right);
         while List.GetValue(i) do
         begin
            _Seeds[i].MinBounds.V := _Seeds[i].MinBounds.V + PushValue;
            _Seeds[i].MaxBounds.V := _Seeds[i].MaxBounds.V + PushValue;
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
         SeedBinarySearch(HiS,0,HiO-1,UOrder,_Seeds,CompareU,Current,Previous);
         i := HiO;
         while i > (Previous+1) do
         begin
            UOrder[i] := UOrder[i-1];
            dec(i);
         end;
         UOrder[Previous+1] := HiS;

         // Now we remove the last two elements from VOrder and add the new seed.
         Current := HiO div 2;
         SeedBinarySearch(HiS,0,HiO-1,VOrder,_Seeds,CompareV,Current,Previous);
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
         _Seeds[HiS].MaxBounds.U := (_Seeds[UOrder[HiO]].MaxBounds.U - _Seeds[UOrder[HiO]].MinBounds.U) + SeedSeparatorSpace + (_Seeds[UOrder[HiO-1]].MaxBounds.U - _Seeds[UOrder[HiO-1]].MinBounds.U);
         _Seeds[HiS].MaxBounds.V := max((_Seeds[UOrder[HiO]].MaxBounds.V - _Seeds[UOrder[HiO]].MinBounds.V),(_Seeds[UOrder[HiO-1]].MaxBounds.V - _Seeds[UOrder[HiO-1]].MinBounds.V));
         // Insert the last two elements from UOrder at the new seed tree element.
         SeedTree[HiS].Left := UOrder[HiO-1];
         SeedTree[HiS].Right := UOrder[HiO];
         // Now we translate the bounds of the element in the 'right' to the right,
         // where it belongs, and do it recursively.
         PushValue := (_Seeds[UOrder[HiO-1]].MaxBounds.U - _Seeds[UOrder[HiO-1]].MinBounds.U) + SeedSeparatorSpace;
         List.Add(SeedTree[HiS].Right);
         while List.GetValue(i) do
         begin
            _Seeds[i].MinBounds.U := _Seeds[i].MinBounds.U + PushValue;
            _Seeds[i].MaxBounds.U := _Seeds[i].MaxBounds.U + PushValue;
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
         SeedBinarySearch(HiS,0,HiO-1,VOrder,_Seeds,CompareV,Current,Previous);
         i := HiO;
         while i > (Previous+1) do
         begin
            VOrder[i] := VOrder[i-1];
            dec(i);
         end;
         VOrder[Previous+1] := HiS;

         // Now we remove the last two elements from UOrder and add the new seed.
         Current := HiO div 2;
         SeedBinarySearch(HiS,0,HiO-1,UOrder,_Seeds,CompareU,Current,Previous);
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
   if (_Seeds[High(_Seeds)].MaxBounds.U > _Seeds[High(_Seeds)].MaxBounds.V) then
   begin
      PushValue := (_Seeds[High(_Seeds)].MaxBounds.U - _Seeds[High(_Seeds)].MaxBounds.V) / 2;
      for i := Low(_Seeds) to (High(_Seeds)-1) do
      begin
         _Seeds[i].MinBounds.V := _Seeds[i].MinBounds.V + PushValue;
         _Seeds[i].MaxBounds.V := _Seeds[i].MaxBounds.V + PushValue;
      end;
      _Seeds[High(_Seeds)].MaxBounds.V := _Seeds[High(_Seeds)].MaxBounds.U;
   end
   else if (_Seeds[High(_Seeds)].MaxBounds.U < _Seeds[High(_Seeds)].MaxBounds.V) then
   begin
      PushValue := (_Seeds[High(_Seeds)].MaxBounds.V - _Seeds[High(_Seeds)].MaxBounds.U) / 2;
      for i := Low(_Seeds) to (High(_Seeds)-1) do
      begin
         _Seeds[i].MinBounds.U := _Seeds[i].MinBounds.U + PushValue;
         _Seeds[i].MaxBounds.U := _Seeds[i].MaxBounds.U + PushValue;
      end;
      _Seeds[High(_Seeds)].MaxBounds.U := _Seeds[High(_Seeds)].MaxBounds.V;
   end;

   // Clean up memory.
   SetLength(SeedTree,0);
   SetLength(UOrder,0);
   SetLength(VOrder,0);
   List.Free;
end;

procedure CTextureAtlasExtractor.GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
var
   i : integer;
begin
   // Let's get the final texture coordinates for each vertex now.
   for i := Low(_TexCoords) to High(_TexCoords) do
   begin
      _TexCoords[i].U := (_Seeds[_VertsSeed[i]].MinBounds.U + _TexCoords[i].U) / _Seeds[High(_Seeds)].MaxBounds.U;
      _TexCoords[i].V := (_Seeds[_VertsSeed[i]].MinBounds.V + _TexCoords[i].V) / _Seeds[High(_Seeds)].MaxBounds.V;
   end;
end;

// Seed related
function CTextureAtlasExtractor.isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
begin
   if _VMax < _UMax then
   begin
      Result := true;
   end
   else if _VMax > _UMax then
   begin
      Result := false;
   end
   else if _VMerge < _UMerge then
   begin
      Result := true;
   end
   else
   begin
      Result := false;
   end;
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
   List.UseSmartMemoryManagement(true);
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

function CTextureAtlasExtractor.MakeNewSeedOrigami(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
const
   C_MIN_ANGLE = 0.001; // approximately cos 90'
var
   v,f,Value,vertex,FaceIndex,PreviousFace : integer;
   CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1: integer;
   FaceList,PreviousFaceList : CIntegerList;
   Angle: single;
   Position: TVector3f;
   VertexUtil : TVertexTransformationUtils;
begin
   VertexUtil := TVertexTransformationUtils.Create;
   // Setup neighbor detection list
   FaceList := CIntegerList.Create;
   FaceList.UseSmartMemoryManagement(true);
   PreviousFaceList := CIntegerList.Create;
   PreviousFaceList.UseSmartMemoryManagement(true);
   // Setup VertsLocation
   for v := Low(_VertsLocation) to High(_VertsLocation) do
   begin
      _VertsLocation[v] := -1;
   end;
   // Avoid unlimmited loop
   for f := Low(_CheckFace) to High(_CheckFace) do
      _CheckFace[f] := false;

   // Add starting face
   _FaceSeeds[Value] := _ID;
   _CheckFace[_StartingFace] := true;
   Result.TransformMatrix := VertexUtil.GetTransformMatrixFromVector(_FaceNormals[_StartingFace]);
   Result.MinBounds.U := 999999;
   Result.MaxBounds.U := -999999;
   Result.MinBounds.V := 999999;
   Result.MaxBounds.V := -999999;
   Result.MeshID := _MeshID;

   // The first triangle is dealt in a different way.
   // We'll project it in the plane XY and the first vertex is on (0,0,0).
   FaceIndex := _StartingFace * _VerticesPerFace;
   for v := 0 to _VerticesPerFace - 1 do
   begin
      vertex := _Faces[FaceIndex+v];
      Position := SubtractVector(_Vertices[vertex],_Vertices[_Faces[FaceIndex]]);
      if _VertsSeed[vertex] <> -1 then
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
         // This seed is the first seed to use this vertex.
         _VertsSeed[vertex] := _ID;
         _VertsLocation[vertex] := vertex;
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
      // do some verification here
      if not _CheckFace[f] then
      begin
         if (_FaceSeeds[f] = -1) then
         begin
            PreviousFaceList.Add(_StartingFace);
            FaceList.Add(f);
            _CheckFace[f] := true;
         end;
      end;
      f := _FaceNeighbors.GetNextNeighbor;
   end;


   // Neighbour Face Scanning starts here.
   // Wel'll check face by face and add the vertexes that were not added
   while FaceList.GetValue(Value) do
   begin
      PreviousFaceList.GetValue(PreviousFace);
      // Add the face and its vertexes
      _FaceSeeds[Value] := _ID;
      FaceIndex := Value * _VerticesPerFace;
      // The first idea is to get the vertex that wasn't added yet.
      ObtainCommonEdgeFromFaces(_Faces,_VerticesPerFace,Value,PreviousFace,CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1);
      // If we find the vertex...
      if _VertsSeed[CurrentVertex] = -1 then
      begin
         // This seed is the first seed to use this vertex.
         _VertsSeed[vertex] := _ID;
         _VertsLocation[vertex] := vertex;
         // Get temporary texture coordinates. -----Change the next line-----
         //_TextCoords[vertex] := VertexUtil.GetUVCoordinates(_Vertices[vertex],Result.TransformMatrix);
         // Now update the bounds of the seed.
         if _TextCoords[vertex].U < Result.MinBounds.U then
            Result.MinBounds.U := _TextCoords[vertex].U;
         if _TextCoords[vertex].U > Result.MaxBounds.U then
            Result.MaxBounds.U := _TextCoords[vertex].U;
         if _TextCoords[vertex].V < Result.MinBounds.V then
            Result.MinBounds.V := _TextCoords[vertex].V;
         if _TextCoords[vertex].V > Result.MaxBounds.V then
            Result.MaxBounds.V := _TextCoords[vertex].V;
      end
      else // sometimes we may not find the vertex, because all of them might
      // have been added previously.
      begin


      end;
      // This part is old code and it will be eventually removed.
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
               //_TextCoords[High(_Vertices)] := VertexUtil.GetUVCoordinates(_Vertices[vertex],Result.TransformMatrix);
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
               PreviousFaceList.Add(Value);
               FaceList.Add(f);
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
   FaceList.Free;
   PreviousFaceList.Free;
   VertexUtil.Free;
end;

// That's the time of the day that we miss a half edge structure (even if a
// fragmented memory makes Delphi go wild)
procedure CTextureAtlasExtractor.ObtainCommonEdgeFromFaces(const _Faces: auint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2: integer);
var
   i,j,mincface,minpface : integer;
   Found: boolean;
begin
   mincface := _CurrentFace * _VerticesPerFace;
   minpface := _PreviousFace * _VerticesPerFace;

   // Real code starts here.
   i := 0;
   Found := false;
   while (i < _VerticesPerFace) and (not Found) do
   begin
      j := 0;
      while (j < _VerticesPerFace) and (not Found) do
      begin
         if _Faces[mincface+i] = _Faces[minpface+j] then
         begin
            _CommonVertex1 := _Faces[mincface+i];
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
   if _Faces[mincface + ((i + 1) mod _VerticesPerFace)] = _Faces[minpface + ((j + _VerticesPerFace - 1) mod _VerticesPerFace)] then
   begin
      _CommonVertex2 := _Faces[mincface + ((i + 1) mod _VerticesPerFace)];
      _CurrentVertex := _Faces[mincface + ((i + _VerticesPerFace - 1) mod _VerticesPerFace)];
      _PreviousVertex := _Faces[minpface + ((j + 1) mod _VerticesPerFace)];
   end
   else // Then, it is the previous element.
   begin
      _CommonVertex2 := _Faces[mincface + ((i + _VerticesPerFace - 1) mod _VerticesPerFace)];
      _CurrentVertex := _Faces[mincface + ((i + 1) mod _VerticesPerFace)];
      _PreviousVertex := _Faces[minpface + ((j + _VerticesPerFace - 1) mod _VerticesPerFace)];
   end;
end;

// Sort
function CTextureAtlasExtractor.CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed1.MaxBounds.U - _Seed1.MinBounds.U) - (_Seed2.MaxBounds.U - _Seed2.MinBounds.U);
end;

function CTextureAtlasExtractor.CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed1.MaxBounds.V - _Seed1.MinBounds.V) - (_Seed2.MaxBounds.V - _Seed2.MinBounds.V);
end;

// Adapted from OMC Manager
procedure CTextureAtlasExtractor.QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
var
   Lo, Hi, Mid, T: Integer;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while _CompareFunction(_Seeds[_OrderedList[Lo]],_Seeds[_OrderedList[Mid]]) > 0 do Inc(Lo);
      while _CompareFunction(_Seeds[_OrderedList[Hi]],_Seeds[_OrderedList[Mid]]) < 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         T := _OrderedList[Lo];
         _OrderedList[Lo] := _OrderedList[Hi];
         _OrderedList[Hi] := T;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortSeeds(_min, Hi, _OrderedList, _Seeds, _CompareFunction);
   if Lo < _max then
      QuickSortSeeds(Lo, _max, _OrderedList, _Seeds, _CompareFunction);
end;

procedure CTextureAtlasExtractor.QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
var
   Lo, Hi, Mid, T: Integer;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while (_FacePriority[_FaceOrder[Lo]] - _FacePriority[_FaceOrder[Mid]]) > 0 do Inc(Lo);
      while (_FacePriority[_FaceOrder[Hi]] - _FacePriority[_FaceOrder[Mid]]) < 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         T := _FaceOrder[Lo];
         _FaceOrder[Lo] := _FaceOrder[Hi];
         _FaceOrder[Hi] := T;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortPriority(_min, Hi, _FaceOrder, _FacePriority);
   if Lo < _max then
      QuickSortPriority(Lo, _max, _FaceOrder, _FacePriority);
end;

// binary search with decrescent order (borrowed from OS BIG Editor)
function CTextureAtlasExtractor.SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
var
   Comparison : real;
   Current : integer;
begin
   Comparison := _CompareFunction(_Seeds[_Value],_Seeds[_OrderedList[_current]]);
   if Comparison = 0 then
   begin
      _previous := _current - 1;
      Result := _current;
   end
   else if Comparison < 0 then
   begin
      if _min < _max then
      begin
         Current := _current;
         _current := (_current + _max) div 2;
         Result := SeedBinarySearch(_Value,Current+1,_max,_OrderedList,_Seeds,_CompareFunction,_current,_previous);
      end
      else
      begin
         _previous := _current;
         Result := -1;
      end;
   end
   else // > 0
   begin
      if _min < _max then
      begin
         Current := _current;
         _current := (_current + _min) div 2;
         Result := SeedBinarySearch(_Value,_min,Current-1,_OrderedList,_Seeds,_CompareFunction,_current,_previous);
      end
      else
      begin
         _previous := _current - 1;
         Result := -1;
      end;
   end;
end;


end.
