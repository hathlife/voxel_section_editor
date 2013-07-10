unit ClassTextureAtlasExtractor;

interface

uses GLConstants, BasicDataTypes, Geometry, ClassNeighborDetector,
   ClassIntegerList, Math, ClassVertexTransformationUtils, NeighborhoodDataPlugin,
   MeshPluginBase, SysUtils, GeometricAlgebra, Multivector;

{$INCLUDE Global_Conditionals.inc}

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
         function MakeNewSeedOrigami(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
         function MakeNewSeedOrigamiGA(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
         function isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
         // Angle stuff
         function GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
         // Sort related functions
         function CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
         function CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
         procedure QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
         procedure QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
         function SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
         procedure ObtainCommonEdgeFromFaces(var _Faces: auint32; const _VertsLocation : aint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2,_inFaceCurrVertPosition: integer);
         // Oriogami helper functions
         procedure WriteUVCoordinatesOrigami(const _Vertices: TAVector3f; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer);
         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
         function Get90RotDirectionFromVector(const _V1,_V2: TVector2f): TVector2f;
         function Get90RotDirectionFromDirection(const _Direction: TVector2f): TVector2f;
         function GetVertexLocationID(const _VertsLocation : aint32; _ID: integer): integer;
         function GetTriangleCenterPosition(const _V0,_V1,_V2: TVector3f): TVector3f;
         // Origami geometric algebra helper functions
         function GetVersorForTriangleProjectionGA(var _GA: TGeometricAlgebra; const _Normal: TVector3f): TMultiVector;
         function GetVertexPositionOnTriangleProjectionGA(var _GA: TGeometricAlgebra; const _V1: TVector3f; const _Versor,_Inverse: TMultiVector): TVector2f;
         function AreTrianglesColiding(var _PGA: TGeometricAlgebra; const _TLS1, _TLS2, _TLS3, _TV1, _TV2, _TV3: TMultiVector): boolean;
         function IsValidUVPointGA(var _PGA,_EGA: TGeometricAlgebra; const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _FaceNormal: TVector3f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
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
         function GetMeshSeedsOrigami(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
         function GetMeshSeedsOrigamiGA(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
         procedure MergeSeeds(var _Seeds: TSeedSet);
         procedure GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
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

function CTextureAtlasExtractor.GetMeshSeedsOrigami(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
var
   i, MaxVerts: integer;
   FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   // Get the neighbours of each face.
   FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
   FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);

   // Setup FaceSeed, FaceOrder and FacePriority.
   SetLength(FaceSeed,High(_FaceNormals)+1);
   SetLength(FaceOrder,High(FaceSeed)+1);
   SetLength(FacePriority,High(FaceSeed)+1);
   SetLength(CheckFace,High(_FaceNormals)+1);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      FaceSeed[i] := -1;
      FaceOrder[i] := i;
      FacePriority[i] := Max(Max(abs(_FaceNormals[i].X),abs(_FaceNormals[i].Y)),abs(_FaceNormals[i].Z));
   end;
   {$ifdef ORIGAMI_TEST}
   Temp := 'FaceOrder before sort = [';
   for i := Low(FaceOrder) to High(FaceOrder) do
   begin
      Temp := Temp + IntToStr(FaceOrder[i]) + ' ';
   end;
   Temp := Temp + ']';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}
   QuickSortPriority(Low(FaceOrder),High(FaceOrder),FaceOrder,FacePriority);
   {$ifdef ORIGAMI_TEST}
   Temp := 'FaceOrder after sort = [';
   for i := Low(FaceOrder) to High(FaceOrder) do
   begin
      Temp := Temp + IntToStr(FaceOrder[i]) + ' ';
   end;
   Temp := Temp + ']';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}

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
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Seed = ' + IntToStr(High(_Seeds)) + ' and i = ' + IntToStr(i));
         {$endif}
         _Seeds[High(_Seeds)] := MakeNewSeedOrigami(High(_Seeds),_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,CheckFace);
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
end;

// Geometric Algebra edition.
function CTextureAtlasExtractor.GetMeshSeedsOrigamiGA(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
var
   i, MaxVerts: integer;
   FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
   {$ifdef ORIGAMI_TEST}
   Temp: string;
   {$endif}
begin
   // Get the neighbours of each face.
   FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
   FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);

   // Setup FaceSeed, FaceOrder and FacePriority.
   SetLength(FaceSeed,High(_FaceNormals)+1);
   SetLength(FaceOrder,High(FaceSeed)+1);
   SetLength(FacePriority,High(FaceSeed)+1);
   SetLength(CheckFace,High(_FaceNormals)+1);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      FaceSeed[i] := -1;
      FaceOrder[i] := i;
      FacePriority[i] := Max(Max(abs(_FaceNormals[i].X),abs(_FaceNormals[i].Y)),abs(_FaceNormals[i].Z));
   end;
   {$ifdef ORIGAMI_TEST}
   Temp := 'FaceOrder before sort = [';
   for i := Low(FaceOrder) to High(FaceOrder) do
   begin
      Temp := Temp + IntToStr(FaceOrder[i]) + ' ';
   end;
   Temp := Temp + ']';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}
   QuickSortPriority(Low(FaceOrder),High(FaceOrder),FaceOrder,FacePriority);
   {$ifdef ORIGAMI_TEST}
   Temp := 'FaceOrder after sort = [';
   for i := Low(FaceOrder) to High(FaceOrder) do
   begin
      Temp := Temp + IntToStr(FaceOrder[i]) + ' ';
   end;
   Temp := Temp + ']';
   GlobalVars.OrigamiFile.Add(Temp);
   {$endif}

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
         {$ifdef ORIGAMI_TEST}
         GlobalVars.OrigamiFile.Add('Seed = ' + IntToStr(High(_Seeds)) + ' and i = ' + IntToStr(i));
         {$endif}
         _Seeds[High(_Seeds)] := MakeNewSeedOrigamiGA(High(_Seeds),_MeshID,FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,_VertsSeed,FaceNeighbors,_NeighborhoodPlugin,_VerticesPerFace,MaxVerts,CheckFace);
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

   // Force a seed separator space at the left of the seeds.
   for i := Low(_Seeds) to High(_Seeds) do
   begin
      _Seeds[i].MinBounds.U := _Seeds[i].MinBounds.U + SeedSeparatorSpace;
      _Seeds[i].MinBounds.V := _Seeds[i].MinBounds.V + SeedSeparatorSpace;
      _Seeds[i].MaxBounds.U := _Seeds[i].MaxBounds.U + SeedSeparatorSpace;
      _Seeds[i].MaxBounds.V := _Seeds[i].MaxBounds.V + SeedSeparatorSpace;
   end;

   // Force seeds separator space at the end of the main seed.
   _Seeds[High(_Seeds)].MaxBounds.U := _Seeds[High(_Seeds)].MaxBounds.U + SeedSeparatorSpace;
   _Seeds[High(_Seeds)].MaxBounds.V := _Seeds[High(_Seeds)].MaxBounds.V + SeedSeparatorSpace;

   // The texture must be a square, so we'll centralize the smallest dimension.
{
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
}

   // Clean up memory.
   SetLength(SeedTree,0);
   SetLength(UOrder,0);
   SetLength(VOrder,0);
   List.Free;
end;

procedure CTextureAtlasExtractor.GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
var
   i : integer;
   ScaleU, ScaleV: real;
begin
   // We'll ensure that our main seed spreads from (0,0) to (1,1) for both axis.
   ScaleU := (max(_Seeds[High(_Seeds)].MaxBounds.U,_Seeds[High(_Seeds)].MaxBounds.V)) / _Seeds[High(_Seeds)].MaxBounds.U;
   ScaleV := (max(_Seeds[High(_Seeds)].MaxBounds.U,_Seeds[High(_Seeds)].MaxBounds.V)) / _Seeds[High(_Seeds)].MaxBounds.V;
   for i := Low(_Seeds) to High(_Seeds) do
   begin
      _Seeds[i].MinBounds.U := _Seeds[i].MinBounds.U * ScaleU;
      _Seeds[i].MaxBounds.U := _Seeds[i].MaxBounds.U * ScaleU;
      _Seeds[i].MinBounds.V := _Seeds[i].MinBounds.V * ScaleV;
      _Seeds[i].MaxBounds.V := _Seeds[i].MaxBounds.V * ScaleV;
   end;

   // Let's get the final texture coordinates for each vertex now.
   for i := Low(_TexCoords) to High(_TexCoords) do
   begin
      _TexCoords[i].U := (_Seeds[_VertsSeed[i]].MinBounds.U + (_TexCoords[i].U * ScaleU)) / _Seeds[High(_Seeds)].MaxBounds.U;
      _TexCoords[i].V := (_Seeds[_VertsSeed[i]].MinBounds.V + (_TexCoords[i].V * ScaleV)) / _Seeds[High(_Seeds)].MaxBounds.V;
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

// Determinant from a matrix where first line is _Source, second is _V1 and 3rd is _V2.
function Get2DOuterProduct(const _Source,_V1, _V2: TVector2f): single;
begin
   Result := (_Source.U * _V1.V) + (_Source.V * _V2.U) + (_V1.U * _V2.V) - (_Source.U * _V2.V) - (_Source.V * _V1.U) - (_V1.V * _V2.U);
end;

function CTextureAtlasExtractor.Get90RotDirectionFromVector(const _V1,_V2: TVector2f): TVector2f;
begin
   Result.U := _V1.V - _V2.V;
   Result.V := _V2.U - _V1.U;
   Normalize(Result);
end;

function CTextureAtlasExtractor.Get90RotDirectionFromDirection(const _Direction: TVector2f): TVector2f;
begin
   Result.U := -1 * _Direction.V;
   Result.V := _Direction.U;
   Normalize(Result);
end;

function CTextureAtlasExtractor.GetTriangleCenterPosition(const _V0,_V1,_V2: TVector3f): TVector3f;
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


// The objective is to write the UV coordinates from _Target.
procedure CTextureAtlasExtractor.WriteUVCoordinatesOrigami(const _Vertices: TAVector3f; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer);
var
   EdgeSizeInMesh,EdgeSizeInUV,Scale,SinProjectionSizeInMesh,SinProjectionSizeInUV,ProjectionSizeInMesh,ProjectionSizeInUV: single;
   EdgeDirectionInUV,PositionOfTargetAtEdgeInUV,SinDirectionInUV: TVector2f;
   EdgeDirectionInMesh,PositionOfTargetAtEdgeInMesh: TVector3f;
   SourceSide: single;
begin
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
      _TexCoords[_Target] := AddVector(PositionOfTargetatEdgeInUV,ScaleVector(SinDirectionInUV,SinProjectionSizeInUV));
   end;
end;

function CTextureAtlasExtractor.IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
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

function CTextureAtlasExtractor.MakeNewSeedOrigami(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
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
   FaceList.UseSmartMemoryManagement(true);
   PreviousFaceList := CIntegerList.Create;
   PreviousFaceList.UseSmartMemoryManagement(true);
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

function CTextureAtlasExtractor.GetVersorForTriangleProjectionGA(var _GA: TGeometricAlgebra; const _Normal: TVector3f): TMultiVector;
var
   Triangle,Screen,FullRotation: TMultiVector;
begin
   // Get rotation from _Normal to (0,0,1).
   Triangle := _GA.NewEuclideanBiVector(_Normal);
   Screen := _GA.NewEuclideanBiVector(SetVector(0,0,1));
   FullRotation := _GA.GeometricProduct(Triangle,Screen);
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

function CTextureAtlasExtractor.GetVertexPositionOnTriangleProjectionGA(var _GA: TGeometricAlgebra; const _V1: TVector3f; const _Versor,_Inverse: TMultiVector): TVector2f;
var
   Vector,Position: TMultiVector;
begin
   Vector := _GA.NewEuclideanVector(_V1);
   Position := _GA.ApplyRotor(Vector,_Versor,_Inverse);
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

// _TLS1,2,3 are line segments of one of the triangles. _TV1,2,3 are the vertexes (flats) from the other triangle.
// It requires homogeneous/projective model from the geometric algebra.
function CTextureAtlasExtractor.AreTrianglesColiding(var _PGA: TGeometricAlgebra; const _TLS1, _TLS2, _TLS3, _TV1, _TV2, _TV3: TMultiVector): boolean;
   function Epsilon(_value: single):single;
   begin
      Result := _Value;
      if abs(_Value) < 0.000001 then
         Result := 0;
   end;
var
   VertexConfig1,VertexConfig2,VertexConfig3: byte;
   SegConfig1,SegConfig2,SegConfig3: byte;
   Temp: TMultiVector;
begin
   Result := true; // assume true for optimization
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   GlobalVars.OrigamiFile.Add('Colision detection starts here.');
   _TLS1.Debug(GlobalVars.OrigamiFile,'Triangle A Line Segment 1');
   _TLS2.Debug(GlobalVars.OrigamiFile,'Triangle A Line Segment 2');
   _TLS3.Debug(GlobalVars.OrigamiFile,'Triangle A Line Segment 3');
   _TV1.Debug(GlobalVars.OrigamiFile,'Triangle B Vertex 1');
   _TV2.Debug(GlobalVars.OrigamiFile,'Triangle B Vertex 2');
   _TV3.Debug(GlobalVars.OrigamiFile,'Triangle B Vertex 3');
   {$endif}
   {$endif}

   // Collect vertex configurations. 1 is outside and 0 is inside.
   // Vertex 1
   VertexConfig1 := 0;
   Temp := _PGA.OuterProduct(_TLS1,_TV1);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL1 ^ _TV1');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig1 := VertexConfig1 or 1;
   end;
   Temp.Free;
   Temp := _PGA.OuterProduct(_TLS2,_TV1);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL2 ^ _TV1');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig1 := VertexConfig1 or 2;
   end;
   Temp.Free;
   Temp := _PGA.OuterProduct(_TLS3,_TV1);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL3 ^ _TV1');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig1 := VertexConfig1 or 4;
   end;
   Temp.Free;
   if VertexConfig1 = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Vertex 1 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the vertex is inside the triangle.
   end;
   // Vertex 2
   VertexConfig2 := 0;
   Temp := _PGA.OuterProduct(_TLS1,_TV2);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL1 ^ _TV2');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig2 := VertexConfig2 or 1;
   end;
   Temp.Free;
   Temp := _PGA.OuterProduct(_TLS2,_TV2);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL2 ^ _TV2');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig2 := VertexConfig2 or 2;
   end;
   Temp.Free;
   Temp := _PGA.OuterProduct(_TLS3,_TV2);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL3 ^ _TV2');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig2 := VertexConfig2 or 4;
   end;
   Temp.Free;
   if VertexConfig2 = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Vertex 2 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the vertex is inside the triangle.
   end;
   // Vertex 3
   VertexConfig3 := 0;
   Temp := _PGA.OuterProduct(_TLS1,_TV3);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL1 ^ _TV3');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig3 := VertexConfig3 or 1;
   end;
   Temp.Free;
   Temp := _PGA.OuterProduct(_TLS2,_TV3);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL2 ^ _TV3');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig3 := VertexConfig3 or 2;
   end;
   Temp.Free;
   Temp := _PGA.OuterProduct(_TLS3,_TV3);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   Temp.Debug(GlobalVars.OrigamiFile,'_TSL3 ^ _TV3');
   {$endif}
   {$endif}
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      VertexConfig3 := VertexConfig3 or 4;
   end;
   Temp.Free;
   if VertexConfig3 = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Vertex 3 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the vertex is inside the triangle.
   end;
   // Now let's check the line segments
   SegConfig1 := VertexConfig1 xor (VertexConfig2 and VertexConfig1);
   if SegConfig1 = VertexConfig1 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Segment 12 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the line segment crosses the triangle.
   end;
   SegConfig2 := VertexConfig2 xor (VertexConfig3 and VertexConfig2);
   if SegConfig2 = VertexConfig2 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Segment 23 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the line segment crosses the triangle.
   end;
   SegConfig3 := VertexConfig3 xor (VertexConfig1 and VertexConfig3);
   if SegConfig3 = VertexConfig3 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Segment 31 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the line segment crosses the triangle.
   end;
   // Now let's check the triangle, if it contains the other or not.
   if (VertexConfig1 and VertexConfig2 and VertexConfig3) = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Triangle is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the triangle contains the other triangle.
   end;
   Result := false; // return false. There is no colision between the two triangles.
end;

function CTextureAtlasExtractor.IsValidUVPointGA(var _PGA,_EGA: TGeometricAlgebra; const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _FaceNormal: TVector3f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   EdgeSizeInMesh,EdgeSizeInUV,Scale: single;
   i,v: integer;
   PEdge0,PEdge1,PTarget,PEdge0UV,PEdge1UV,PCenterTriangle,PCenterSegment,PCenterSegmentUV,PTemp,V0,V1,V2: TMultiVector; // Points
   LSEdge,LSEdgeUV,LSEdge0,LSEdge1,LSEdge2: TMultiVector; // Line segments.
   DirEdge,DirEdgeUV: TMultiVector; // Directions.
   PlaneRotation,SegmentRotation: TMultiVector; // Versors
   e0: TMultiVector; // constants.
begin
   // Get constants that will be required in our computation.
   e0 := _PGA.GetHomogeneousE0();

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
   LSEdge := _PGA.OuterProduct(PEdge0,PEdge1);
   LSEdgeUV := _PGA.OuterProduct(PEdge0UV,PEdge1UV);
   // Get Directions.
   DirEdge := _PGA.GetFlatDirection(LSEdge,e0);
   DirEdgeUV := _PGA.GetFlatDirection(LSEdgeUV,e0);

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
      e0.Free;
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
   PEdge0.Free;
   PEdge0 := _PGA.ApplyRotor(PTemp,PlaneRotation);
   _PGA.BladeOfGradeFromVector(PEdge0,1);
   PTemp.Free;
   PTemp := TMultiVector.Create(PEdge1);
   PEdge1.Free;
   PEdge1 := _PGA.ApplyRotor(PTemp,PlaneRotation);
   _PGA.BladeOfGradeFromVector(PEdge1,1);
   PTemp.Free;
   PTemp := TMultiVector.Create(PTarget);
   PTarget.Free;
   PTarget := _PGA.ApplyRotor(PTemp,PlaneRotation);
   _PGA.BladeOfGradeFromVector(PTarget,1);
   PTemp.Free;
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
   LSEdge.Free;
   LSEdge := _PGA.OuterProduct(PEdge0,PEdge1);
   LSEdgeUV.Free;
   LSEdgeUV := _PGA.OuterProduct(PEdge0UV,PEdge1UV);
   // Get Directions.
   DirEdge.Free;
   DirEdge := _PGA.GetFlatDirection(LSEdge,e0);
   DirEdgeUV.Free;
   DirEdgeUV := _PGA.GetFlatDirection(LSEdgeUV,e0);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   LSEdge.Debug(GlobalVars.OrigamiFile,'LSEdge');
   LSEdgeUV.Debug(GlobalVars.OrigamiFile,'LSEdgeUV');
   DirEdge.Debug(GlobalVars.OrigamiFile,'DirEdge');
   DirEdgeUV.Debug(GlobalVars.OrigamiFile,'DirEdgeUV');
   {$endif}
   {$endif}

   // Let's rotate our vectors.
   PTemp := _PGA.GeometricProduct(DirEdge,DirEdgeUV);

   // Rotate the triangle (Edge0,Edge1,Target) at the UV plane.
   SegmentRotation := _PGA.Euclidean3DLogarithm(PTemp);
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_PROJECTION_TEST}
   SegmentRotation.Debug(GlobalVars.OrigamiFile,'SegmentRotation');
   {$endif}
   {$endif}
   // This part is not very practical, but it should avoid problems.
   PTemp.Free;
   PTemp := TMultiVector.Create(PEdge0);
   PEdge0.Free;
   PEdge0 := _PGA.ApplyRotor(PTemp,SegmentRotation);
   _PGA.BladeOfGradeFromVector(PEdge0,1);
   PTemp.Free;
   PTemp := TMultiVector.Create(PEdge1);
   PEdge1.Free;
   PEdge1 := _PGA.ApplyRotor(PTemp,SegmentRotation);
   _PGA.BladeOfGradeFromVector(PEdge1,1);
   PTemp.Free;
   PTemp := TMultiVector.Create(PTarget);
   PTarget.Free;
   PTarget := _PGA.ApplyRotor(PTemp,SegmentRotation);
   _PGA.BladeOfGradeFromVector(PTarget,1);
   PTemp.Free;

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
   PEdge0UV.Free;
   PEdge1UV.Free;
   PCenterTriangle.Free;
   PCenterSegment.Free;
   PCenterSegmentUV.Free;
   DirEdge.Free;
   DirEdgeUV.Free;
   PlaneRotation.Free;
   SegmentRotation.Free;
   e0.Free;

   // Get the line segments for colision detection.
   LSEdge0 := _PGA.OuterProduct(PEdge0,PEdge1);
   LSEdge1 := _PGA.OuterProduct(PEdge1,PTarget);
   LSEdge2 := _PGA.OuterProduct(PTarget,PEdge0);

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
         V0 := _PGA.NewHomogeneousFlat(_TexCoords[_Faces[v]]);
         V1 := _PGA.NewHomogeneousFlat(_TexCoords[_Faces[v+1]]);
         V2 := _PGA.NewHomogeneousFlat(_TexCoords[_Faces[v+2]]);
         if AreTrianglesColiding(_PGA,LSEdge0,LSEdge1,LSEdge2,V0,V1,V2) then
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

            exit;
         end;
         V2.Free;
         V1.Free;
         V0.Free;
      end;
      inc(v,_VerticesPerFace);
   end;
   _CheckFace[_PreviousFace] := true;

   // Free RAM.
   LSEdge2.Free;
   LSEdge1.Free;
   LSEdge0.Free;
end;


function CTextureAtlasExtractor.MakeNewSeedOrigamiGA(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _CheckFace: abool): TTextureSeed;
var
   v,f,Value,vertex,FaceIndex,PreviousFace : integer;
   CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1: integer;
   FaceList,PreviousFaceList : CIntegerList;
   Angle: single;
   Position,TriangleCenter: TVector3f;
   VertsLocation : aint32;
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
   FaceList.UseSmartMemoryManagement(true);
   PreviousFaceList := CIntegerList.Create;
   PreviousFaceList.UseSmartMemoryManagement(true);
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
         VertsLocation[vertex] := vertex;
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
      ObtainCommonEdgeFromFaces(_Faces,VertsLocation,_VerticesPerFace,Value,PreviousFace,CurrentVertex,PreviousVertex,SharedEdge0,SharedEdge1,v);
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
   SetLength(FaceBackup,0);
   TriangleTransform.Free;
   TriangleTransformInv.Free;
   FaceList.Free;
   PreviousFaceList.Free;
   EuclideanGA.Free;
   ProjectiveGA.Free;
end;

function CTextureAtlasExtractor.GetVertexLocationID(const _VertsLocation : aint32; _ID: integer): integer;
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
procedure CTextureAtlasExtractor.ObtainCommonEdgeFromFaces(var _Faces: auint32; const _VertsLocation : aint32; const _VerticesPerFace,_CurrentFace,_PreviousFace: integer; var _CurrentVertex,_PreviousVertex,_CommonVertex1,_CommonVertex2,_inFaceCurrVertPosition: integer);
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
