unit ClassTextureGenerator;

interface

uses GLConstants, Geometry, BasicDataTypes, Voxel_Engine, ClassNeighborDetector,
   ClassIntegerList, Math, Windows, Graphics, BasicFunctions, SysUtils, Dialogs,
   ClassVertexTransformationUtils, Math3d, NeighborhoodDataPlugin, MeshPluginBase,
   ClassVector3fSet;

type
   TTextureSeed = record
      MinBounds, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
      MeshID : integer;
   end;
   TSeedTreeItem = record
      Left, Right: integer;
   end;
   TSeedTree = array of TSeedTreeItem;
   TSeedSet = array of TTextureSeed;
   TTexCompareFunction = function (const _Seed1, _Seed2 : TTextureSeed): real of object;
   T2DFrameBuffer = array of array of TVector4f;
   TWeightBuffer = array of array of real;

   CTextureGenerator = class
      private
         FTextureAngle: single;
         // Seeds
         function MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
         function isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
         // Angle stuff
         function GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
         // Sort related functions
         function CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
         function CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
         procedure QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
         procedure QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
         function SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
         // Painting procedures
         procedure PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector4f); overload;
         procedure PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector3f); overload;
         procedure PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f); overload;
         procedure PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f); overload;
         procedure PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
         procedure PaintFlatTriangleFromHeightMap(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _VisitedMap: T2DBooleanMap; _P1, _P2, _P3 : TVector2f);
         function GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
         procedure FixBilinearBorders(var _Bitmap: TBitmap; var _AlphaMap: TByteMap);
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
         // Generate Textures
         function GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer; var _AlphaMap: TByteMap): TBitmap;
         function GenerateNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
         function GenerateNormalWithHeightMapTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
         // Generate Textures step by step
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer); overload;
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; _Size: integer); overload;
         procedure PaintMeshDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
         procedure PaintMeshNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
         procedure PaintMeshBumpMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; const _DiffuseMap: TBitmap);
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer); overload;
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer); overload;
         function GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _AlphaMap: TByteMap): TBitmap; overload;
   end;


implementation

constructor CTextureGenerator.Create;
begin
   FTextureAngle := C_TEX_MIN_ANGLE;
   Initialize;
end;

constructor CTextureGenerator.Create(_TextureAngle : single);
begin
   FTextureAngle := _TextureAngle;
   Initialize;
end;

destructor CTextureGenerator.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTextureGenerator.Initialize;
begin
   // do nothing
end;

procedure CTextureGenerator.Clear;
begin
   // do nothing
end;

procedure CTextureGenerator.Reset;
begin
   Clear;
   Initialize;
end;

// Angle operations
function CTextureGenerator.GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
begin
   Result := (_Vec1.X * _Vec2.X) + (_Vec1.Y * _Vec2.Y) + (_Vec1.Z * _Vec2.Z);
end;

// Executes
function CTextureGenerator.GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace: integer): TAVector2f;
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

function CTextureGenerator.GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f;
var
   i, MaxVerts: integer;
   VertsLocation,FaceSeed : aint32;
   FacePriority: AFloat;
   FaceOrder : auint32;
   CheckFace: abool;
   FaceNeighbors: TNeighborDetector;
begin
   // Get the neighbours of each face.
//   if _NeighborhoodPlugin <> nil then
//   begin
//      FaceNeighbors := TNeighborhoodDataPlugin(_NeighborhoodPlugin^).FaceFaceNeighbors;
//   end
//   else
//   begin
      FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
      FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);
//   end;
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

procedure CTextureGenerator.MergeSeeds(var _Seeds: TSeedSet);
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

procedure CTextureGenerator.GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
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
function CTextureGenerator.isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
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

function CTextureGenerator.MakeNewSeed(_ID,_MeshID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; var _NeighborhoodPlugin: PMeshPluginBase; _VerticesPerFace,_MaxVerts: integer; var _VertsLocation : aint32; var _CheckFace: abool): TTextureSeed;
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
               // check if angle is less than 90'
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

// Sort
function CTextureGenerator.CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed1.MaxBounds.U - _Seed1.MinBounds.U) - (_Seed2.MaxBounds.U - _Seed2.MinBounds.U);
end;

function CTextureGenerator.CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed1.MaxBounds.V - _Seed1.MinBounds.V) - (_Seed2.MaxBounds.V - _Seed2.MinBounds.V);
end;

// Adapted from OMC Manager
procedure CTextureGenerator.QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
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

procedure CTextureGenerator.QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
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
function CTextureGenerator.SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
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


// Painting procedures
procedure CTextureGenerator.PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector4f);
   procedure PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size, _PosX, _PosY : integer; _Colour: TVector4f; _Weight : single);
   begin
      if (_PosY < _Size) and (_PosX < _Size) and (_PosX >= 0) and (_PosY >= 0) then
      begin
         _Buffer[_PosX,_PosY].X := _Buffer[_PosX,_PosY].X + (_Colour.X * _Weight);
         _Buffer[_PosX,_PosY].Y := _Buffer[_PosX,_PosY].Y + (_Colour.Y * _Weight);
         _Buffer[_PosX,_PosY].Z := _Buffer[_PosX,_PosY].Z + (_Colour.Z * _Weight);
         _Buffer[_PosX,_PosY].W := _Buffer[_PosX,_PosY].W + (_Colour.W * _Weight);
         _WeightBuffer[_PosX,_PosY] := _WeightBuffer[_PosX,_PosY] + _Weight;
      end;
   end;
var
   Size : integer;
   PosX, PosY : integer;
   Point,FractionLow,FractionHigh : TVector2f;
begin
   Size := High(_Buffer)+1;
   Point.U := _Point.U;// - 0.5;
   Point.V := _Point.V;// - 0.5;
   PosX := Trunc(Point.U);
   PosY := Trunc(Point.V);
   FractionHigh.U := Point.U - PosX;
   FractionHigh.V := Point.V - PosY;
   FractionLow.U := 1 - FractionHigh.U;
   FractionLow.V := 1 - FractionHigh.V;
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, FractionLow.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, FractionHigh.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, FractionLow.U * FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, FractionHigh.U * FractionHigh.V);
end;

procedure CTextureGenerator.PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector3f);
   procedure PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size, _PosX, _PosY : integer; _Colour: TVector3f; _Weight : single);
   begin
      if (_PosY < _Size) and (_PosX < _Size) and (_PosX >= 0) and (_PosY >= 0) then
      begin
         _Buffer[_PosX,_PosY].X := _Buffer[_PosX,_PosY].X + (_Colour.X * _Weight);
         _Buffer[_PosX,_PosY].Y := _Buffer[_PosX,_PosY].Y + (_Colour.Y * _Weight);
         _Buffer[_PosX,_PosY].Z := _Buffer[_PosX,_PosY].Z + (_Colour.Z * _Weight);
         _WeightBuffer[_PosX,_PosY] := _WeightBuffer[_PosX,_PosY] + _Weight;
      end;
   end;
var
   Size : integer;
   PosX, PosY : integer;
   Point,FractionLow,FractionHigh : TVector2f;
begin
   Size := High(_Buffer)+1;
   Point.U := _Point.U;// - 0.5;
   Point.V := _Point.V;// - 0.5;
   PosX := Trunc(Point.U);
   PosY := Trunc(Point.V);
   FractionHigh.U := Point.U - PosX;
   FractionHigh.V := Point.V - PosY;
   FractionLow.U := 1 - FractionHigh.U;
   FractionLow.V := 1 - FractionHigh.V;
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, FractionLow.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, FractionHigh.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, FractionLow.U * FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, FractionHigh.U * FractionHigh.V);
end;


// Code adapted from http://www-users.mat.uni.torun.pl/~wrona/3d_tutor/tri_fillers.html
procedure CTextureGenerator.PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
   procedure AssignPointColour(var _DestPoint: TVector2f; var _DestColour: TVector4f; const _SourcePoint: TVector2f; const _SourceColour: TVector4f);
   begin
      _DestPoint.U := _SourcePoint.U;
      _DestPoint.V := _SourcePoint.V;
      _DestColour.X := _SourceColour.X;
      _DestColour.Y := _SourceColour.Y;
      _DestColour.Z := _SourceColour.Z;
      _DestColour.W := _SourceColour.W;
   end;
var
   dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3, da1, da2, da3 : real;
   SP, EP : TVector2f;
   SC, EC : TVector4f;
begin
   if (_P2.V - _P1.V <> 0) then
   begin
		dx1 := (_P2.U - _P1.U) / (_P2.V - _P1.V);
		dr1 := (_C2.X - _C1.X) / (_P2.V - _P1.V);
		dg1 := (_C2.Y - _C1.Y) / (_P2.V - _P1.V);
		db1 := (_C2.Z - _C1.Z) / (_P2.V - _P1.V);
		da1 := (_C2.W - _C1.W) / (_P2.V - _P1.V);
	end
   else
   begin
		dx1 := 0;//(_P2.U - _P1.U);
      dr1 := 0;//(_C2.X - _C1.X);
      dg1 := 0;//(_C2.Y - _C1.Y);
      db1 := 0;//(_C2.Z - _C1.Z);
      da1 := 0;//(_C2.W - _C1.W);
   end;

	if (_P3.V - _P1.V <> 0) then
   begin
		dx2 := (_P3.U - _P1.U) / (_P3.V - _P1.V);
		dr2 := (_C3.X - _C1.X) / (_P3.V - _P1.V);
		dg2 := (_C3.Y - _C1.Y) / (_P3.V - _P1.V);
		db2 := (_C3.Z - _C1.Z) / (_P3.V - _P1.V);
		da2 := (_C3.W - _C1.W) / (_P3.V - _P1.V);
	end
   else
   begin
		dx2 := 0;//(_P3.U - _P1.U);
      dr2 := 0;//(_C3.X - _C1.X);
      dg2 := 0;//(_C3.Y - _C1.Y);
      db2 := 0;//(_C3.Z - _C1.Z);
      da2 := 0;//(_C3.W - _C1.W);
   end;

	if (_P3.V - _P2.V <> 0) then
   begin
		dx3 :=(_P3.U - _P2.U) / (_P3.V - _P2.V);
		dr3 :=(_C3.X - _C2.X) / (_P3.V - _P2.V);
		dg3 :=(_C3.Y - _C2.Y) / (_P3.V - _P2.V);
		db3 :=(_C3.Z - _C2.Z) / (_P3.V - _P2.V);
		da3 :=(_C3.W - _C2.W) / (_P3.V - _P2.V);
	end
   else
   begin
		dx3 := 0;//(_P3.U - _P2.U);
      dr3 := 0;//(_C3.X - _C2.X);
      dg3 := 0;//(_C3.Y - _C2.Y);
      db3 := 0;//(_C3.Z - _C2.Z);
      da3 := 0;//(_C3.W - _C2.W);
   end;

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
		while (SP.V < _P2.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,SP.U,EP.U,SP.V,SC,EC);
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + dg2;
         SC.Z := SC.Z + db2;
         SC.W := SC.W + da2;
         EP.U := EP.U + dx1;
         EC.X := EC.X + dr1;
         EC.Y := EC.Y + dg1;
         EC.Z := EC.Z + db1;
         EC.W := EC.W + da1;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;

      AssignPointColour(EP,EC,_P2,_C2);
		while (SP.V <= _P3.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,SP.U,EP.U,SP.V,SC,EC);
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + dg2;
         SC.Z := SC.Z + db2;
         SC.W := SC.W + da2;
         EP.U := EP.U + dx3;
         EC.X := EC.X + dr3;
         EC.Y := EC.Y + dg3;
         EC.Z := EC.Z + db3;
         EC.W := EC.W + da3;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;
	end
   else
   begin
		while (SP.V < _P2.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,SP.U,EP.U,SP.V,SC,EC);
         SP.U := SP.U + dx1;
         SC.X := SC.X + dr1;
         SC.Y := SC.Y + dg1;
         SC.Z := SC.Z + db1;
         SC.W := SC.W + da1;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + dg2;
         EC.Z := EC.Z + db2;
         EC.W := EC.W + da2;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;

      AssignPointColour(SP,SC,_P2,_C2);
		while (SP.V <= _P3.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,SP.U,EP.U,SP.V,SC,EC);
         SP.U := SP.U + dx3;
         SC.X := SC.X + dr3;
         SC.Y := SC.Y + dg3;
         SC.Z := SC.Z + db3;
         SC.W := SC.W + da3;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + dg2;
         EC.Z := EC.Z + db2;
         EC.W := EC.W + da2;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;
	end;

end;

procedure CTextureGenerator.PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f);
   procedure AssignPointColour(var _DestPoint: TVector2f; var _DestColour: TVector3f; const _SourcePoint: TVector2f; const _SourceColour: TVector3f);
   begin
      _DestPoint.U := _SourcePoint.U;
      _DestPoint.V := _SourcePoint.V;
      _DestColour.X := _SourceColour.X;
      _DestColour.Y := _SourceColour.Y;
      _DestColour.Z := _SourceColour.Z;
   end;
var
   dx1, dx2, dx3, dr, dr1, dr2, dr3, dg, dg1, dg2, dg3, db, db1, db2, db3 : single;
   SP, EP, PP : TVector2f;
   SC, EC, PC : TVector3f;
begin
   if (_P2.V - _P1.V > 0) then
   begin
		dx1 := (_P2.U - _P1.U) / (_P2.V - _P1.V);
		dr1 := (_C2.X - _C1.X) / (_P2.V - _P1.V);
		dg1 := (_C2.Y - _C1.Y) / (_P2.V - _P1.V);
		db1 := (_C2.Z - _C1.Z) / (_P2.V - _P1.V);
	end
   else
   begin 
		dx1 := (_P2.U - _P1.U);
		dr1 := (_C2.X - _C1.X);
		dg1 := (_C2.Y - _C1.Y);
		db1 := (_C2.Z - _C1.Z);
   end;

	if (_P3.V - _P1.V > 0) then
   begin
		dx2 := (_P3.U - _P1.U) / (_P3.V - _P1.V);
		dr2 := (_C3.X - _C1.X) / (_P3.V - _P1.V);
		dg2 := (_C3.Y - _C1.Y) / (_P3.V - _P1.V);
		db2 := (_C3.Z - _C1.Z) / (_P3.V - _P1.V);
	end
   else
   begin
		dx2 := (_P3.U - _P1.U);
		dr2 := (_C3.X - _C1.X);
		dg2 := (_C3.Y - _C1.Y);
		db2 := (_C3.Z - _C1.Z);
   end;

	if (_P3.V - _P2.V > 0) then
   begin
		dx3 :=(_P3.U - _P2.U) / (_P3.V - _P2.V);
		dr3 :=(_C3.X - _C2.X) / (_P3.V - _P2.V);
		dg3 :=(_C3.Y - _C2.Y) / (_P3.V - _P2.V);
		db3 :=(_C3.Z - _C2.Z) / (_P3.V - _P2.V);
	end
   else
   begin
		dx3 :=(_P3.U - _P2.U);
		dr3 :=(_C3.X - _C2.X);
		dg3 :=(_C3.Y - _C2.Y);
		db3 :=(_C3.Z - _C2.Z);
   end;

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
		while (SP.V <= _P2.V) do
      begin
			if(EP.U - SP.U > 0) then
         begin
				dr := (EC.X - SC.X) / (EP.U - SP.U);
				dg := (EC.Y - SC.Y) / (EP.U - SP.U);
				db := (EC.Z - SC.Z) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
         end;
         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + dg;
				PC.Z := PC.Z + db;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + dg2;
         SC.Z := SC.Z + db2;
         EP.U := EP.U + dx1;
         EC.X := EC.X + dr1;
         EC.Y := EC.Y + dg1;
         EC.Z := EC.Z + db1;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;

      AssignPointColour(EP,EC,_P2,_C2);
		while (SP.V <= _P3.V) do
      begin
			if (EP.U - SP.U > 0) then
         begin
				dr := (EC.X - SC.X) / (EP.U - SP.U);
				dg := (EC.Y - SC.Y) / (EP.U - SP.U);
				db := (EC.Z - SC.Z) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
         end;
         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + dg;
				PC.Z := PC.Z + db;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + dg2;
         SC.Z := SC.Z + db2;
         EP.U := EP.U + dx3;
         EC.X := EC.X + dr3;
         EC.Y := EC.Y + dg3;
         EC.Z := EC.Z + db3;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;
	end
   else
   begin
		while (SP.V <= _P2.V) do
      begin
			if (EP.U - SP.U > 0) then
         begin
				dr := (EC.X - SC.X) / (EP.U - SP.U);
				dg := (EC.Y - SC.Y) / (EP.U - SP.U);
				db := (EC.Z - SC.Z) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
         end;

         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + dg;
				PC.Z := PC.Z + db;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx1;
         SC.X := SC.X + dr1;
         SC.Y := SC.Y + dg1;
         SC.Z := SC.Z + db1;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + dg2;
         EC.Z := EC.Z + db2;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;

      AssignPointColour(SP,SC,_P2,_C2);
		while (SP.V <= _P3.V) do
      begin
			if (EP.U - SP.U > 0) then
         begin
				dr := (EC.X - SC.X) / (EP.U - SP.U);
				dg := (EC.Y - SC.Y) / (EP.U - SP.U);
				db := (EC.Z - SC.Z) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
         end;

         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + dg;
				PC.Z := PC.Z + db;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx3;
         SC.X := SC.X + dr3;
         SC.Y := SC.Y + dg3;
         SC.Z := SC.Z + db3;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + dg2;
         EC.Z := EC.Z + db2;
         SP.V := SP.V + 1;
         EP.V := EP.V + 1;
		end;
	end;

end;

procedure CTextureGenerator.PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
   function IsP1HigherThanP2(_P1, _P2 : TVector2f): boolean;
   begin
      if _P1.V > _P2.V then
      begin
         Result := true;
      end
      else if _P1.V = _P2.V then
      begin
         if _P1.U > _P2.U then
         begin
            Result := true;
         end
         else
         begin
            Result := false;
         end;
      end
      else
      begin
         Result := false;
      end;
   end;

   procedure PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P : TVector2f; _C1, _C2, _C3: TVector4f);
   var
      CX : TVector4f;
   begin
      // Paint a single pixel.
      CX.X := (_C1.X + _C2.X + _C3.X) / 3;
      CX.Y := (_C1.Y + _C2.Y + _C3.Y) / 3;
      CX.Z := (_C1.Z + _C2.Z + _C3.Z) / 3;
      CX.W := (_C1.W + _C2.W + _C3.W) / 3;
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, _P, CX);
   end;

var
   P1, P2, P3 : TVector2f;
   CX : TVector4f;
   Size : integer;
begin
   Size := High(_Buffer[0])+1;
   P1.U := _P1.U * Size;
   P1.V := _P1.V * Size;
   P2.U := _P2.U * Size;
   P2.V := _P2.V * Size;
   P3.U := _P3.U * Size;
   P3.V := _P3.V * Size;
   // check if the triangle is just a line or pixel.
   if (P1.V = P2.V) and (P1.V = P3.V) then
   begin
      if (P1.U = P2.U) then
      begin
         if (P1.U = P3.U) then
         begin
            PaintPixel(_Buffer,_WeightBuffer,P1,_C1,_C2,_C3);
         end
         else
         begin
            CX.X := (_C1.X + _C2.X) / 2;
            CX.Y := (_C1.Y + _C2.Y) / 2;
            CX.Z := (_C1.Z + _C2.Z) / 2;
            CX.W := (_C1.W + _C2.W) / 2;
            PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P1.U,P3.U,P1.V,CX,_C3);
         end;
      end
      else
      begin
         if (P1.U = P3.U) then
         begin
            CX.X := (_C1.X + _C3.X) / 2;
            CX.Y := (_C1.Y + _C3.Y) / 2;
            CX.Z := (_C1.Z + _C3.Z) / 2;
            CX.W := (_C1.W + _C3.W) / 2;
            PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P1.U,P2.U,P1.V,CX,_C2);
         end
         else  // paint two lines linking P1, P2 and P3.
         begin
            if P1.U > P2.U then
            begin
               if P2.U > P3.U then
               begin
                  PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P3.U,P2.U,P1.V,_C3,_C2);
                  PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P2.U,P1.U,P1.V,_C2,_C1);
               end
               else
               begin
                  if P1.U > P3.U then
                  begin
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P2.U,P3.U,P1.V,_C2,_C3);
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P3.U,P1.U,P1.V,_C3,_C1);
                  end
                  else
                  begin
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P2.U,P1.U,P1.V,_C2,_C1);
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P1.U,P3.U,P1.V,_C1,_C3);
                  end;
               end;
            end
            else
            begin
               if P2.U > P3.U then
               begin
                  if P1.U > P3.U then
                  begin
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P3.U,P1.U,P1.V,_C3,_C1);
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P1.U,P2.U,P1.V,_C1,_C2);
                  end
                  else
                  begin
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P1.U,P3.U,P1.V,_C1,_C3);
                     PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P3.U,P2.U,P1.V,_C3,_C2);
                  end;
               end
               else
               begin
                  PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P1.U,P2.U,P1.V,_C1,_C2);
                  PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,P2.U,P3.U,P1.V,_C2,_C3);
               end;
            end;
         end;
      end;
   end
   else // it is really a triangle.
   begin
      if IsP1HigherThanP2(P1,P2) then
      begin
         if IsP1HigherThanP2(P2,P3) then
         begin
            // P1, P2, P3
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_C3,_C2,_C1);
         end
         else
         begin
            if IsP1HigherThanP2(P1,P3) then
            begin
               // P1, P3, P2
               PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_C2,_C3,_C1);
            end
            else
            begin
               // P3, P1, P2
               PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_C2,_C1,_C3);
            end;
         end;
      end
      else
      begin
         if IsP1HigherThanP2(P2,P3) then
         begin
            if IsP1HigherThanP2(P1,P3) then
            begin
               // P2, P1, P3
               PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_C3,_C1,_C2);
            end
            else
            begin
               // P2, P3, P1
               PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_C1,_C3,_C2);
            end;
         end
         else
         begin
            // P3, P2, P1
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_C1,_C2,_C3);
         end;
      end;
   end;
end;

procedure CTextureGenerator.PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f);
var
   P1, P2, P3 : TVector2f;
   Size : integer;
begin
   Size := High(_Buffer[0])+1;
   P1.U := _P1.U * Size;
   P1.V := _P1.V * Size;
   P2.U := _P2.U * Size;
   P2.V := _P2.V * Size;
   P3.U := _P3.U * Size;
   P3.V := _P3.V * Size;
   if P1.V > P2.V then
   begin
      if P2.V > P3.V then
      begin
         // P1, P2, P3
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_N3,_N2,_N1);
      end
      else
      begin
         if P1.V > P3.V then
         begin
            // P1, P3, P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_N2,_N3,_N1);
         end
         else
         begin
            // P3, P1, P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_N2,_N1,_N3);
         end;
      end;
   end
   else
   begin
      if P2.V > P3.V then
      begin
         if P1.V > P3.V then
         begin
            // P2, P1, P3
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_N3,_N1,_N2);
         end
         else
         begin
            // P2, P3, P1
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_N1,_N3,_N2);
         end;
      end
      else
      begin
         // P3, P2, P1
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_N1,_N2,_N3);
      end;
   end;
end;

procedure CTextureGenerator.PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
   procedure AssignColour(var _DestColour: TVector4f; const _SourceColour: TVector4f);
   begin
      _DestColour.X := _SourceColour.X;
      _DestColour.Y := _SourceColour.Y;
      _DestColour.Z := _SourceColour.Z;
      _DestColour.W := _SourceColour.W;
   end;
var
   dr, dg, db, da : real;
   x2, x1 : single;
   C1, C2, PC : TVector4f;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
      AssignColour(C1,_C2);
      AssignColour(C2,_C1);
   end
   else if _X1 = _X2 then
   begin
      PP.U := _X1;
      PP.V := _Y;
      PC.X := (_C1.X + _C2.X) /2;
      PC.Y := (_C1.Y + _C2.Y) /2;
      PC.Z := (_C1.Z + _C2.Z) /2;
      PC.W := (_C1.W + _C2.W) /2;
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
      AssignColour(C1,_C1);
      AssignColour(C2,_C2);
   end;

   // get the gradients for each colour channel
 	dr := (C2.X - C1.X) / (x2 - x1);
   dg := (C2.Y - C1.Y) / (x2 - x1);
   db := (C2.Z - C1.Z) / (x2 - x1);
   da := (C2.W - C1.W) / (x2 - x1);

   //  Now, let's start the painting procedure:
   PP.U := x1;
   PP.V := _Y;
   AssignColour(PC,C1);
   while PP.U <= x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PC.W := PC.W + da;
      PP.U := PP.U + 1;
   end;
end;

procedure CTextureGenerator.PaintFlatTriangleFromHeightMap(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _VisitedMap: T2DBooleanMap; _P1, _P2, _P3 : TVector2f);
   procedure AssignPoint(var _DestPoint: TVector2f; const _SourcePoint: TVector2f);
   begin
      _DestPoint.U := _SourcePoint.U;
      _DestPoint.V := _SourcePoint.V;
   end;

   procedure SetBumpValue(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _VisitedMap: T2DBooleanMap; _X, _Y : single; _Size: integer);
   const
      FaceSequence : array [0..7,0..3] of integer = ((-1,-1,0,-1),(0,-1,1,-1),(1,-1,1,0),(1,0,1,1),(1,1,0,1),(0,1,-1,1),(-1,1,-1,0),(-1,0,-1,-1));
   var
      DifferentNormalsList: CVector3fSet;
      i,x,y : integer;
      CurrentNormal : PVector3f;
      V1, V2, Normal: TVector3f;
   begin
      x := Round(_X);
      y := Round(_Y);
      if (X < 0) or (Y < 0) or (X >= _Size) or (Y >= _Size) then exit;

      if not _VisitedMap[X,Y] then
      begin
         _VisitedMap[X,Y] := true;
         DifferentNormalsList := CVector3fSet.Create;
         Normal.X := 0;
         Normal.Y := 0;
         Normal.Z := 0;
         for i := 0 to 7 do
         begin
            CurrentNormal := new(PVector3f);

            V1.X := FaceSequence[i,2];
            V1.Y := FaceSequence[i,3];
            V1.Z := _HeightMap[Round(_X) + FaceSequence[i,2], Round(_X) + FaceSequence[i,3]];

            V2.X := FaceSequence[i,0];
            V2.Y := FaceSequence[i,1];
            V2.Z := _HeightMap[Round(_X) + FaceSequence[i,0], Round(_X) + FaceSequence[i,1]];

            CurrentNormal^ := CrossProduct(V1,V2);
            if DifferentNormalsList.Add(CurrentNormal) then
            begin
               Normal.X := Normal.X + CurrentNormal^.X;
               Normal.Y := Normal.Y + CurrentNormal^.Y;
               Normal.Z := Normal.Z + CurrentNormal^.Z;
            end;
         end;
         if not DifferentNormalsList.isEmpty then
         begin
            Normalize(Normal);
         end;
         _Buffer[X,Y].X := Normal.X;
         _Buffer[X,Y].Y := Normal.Y;
         _Buffer[X,Y].Z := Normal.Z;
         DifferentNormalsList.Free;
      end;
   end;

   procedure HorizontalLine(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _VisitedMap: T2DBooleanMap; _X1, _X2, _Y : single; _Size: integer);
   var
      x2, x1 : single;
      PP : TVector2f;
   begin
      // First we make sure x1 will be smaller than x2.
      if (_X1 > _X2) then
      begin
         x1 := _X2;
         x2 := _X1;
      end
      else if _X1 = _X2 then
      begin
         PP.U := _X1;
         PP.V := _Y;
         SetBumpValue(_Buffer, _HeightMap, _VisitedMap, PP.U, PP.V,_Size);
         exit;
      end
      else
      begin
         x1 := _X1;
         x2 := _X2;
      end;

      //  Now, let's start the painting procedure:
      PP.U := x1;
      PP.V := _Y;
      while PP.U <= x2 do
      begin
         SetBumpValue(_Buffer, _HeightMap, _VisitedMap, PP.U, PP.V,_Size);
         PP.U := PP.U + 1;
      end;
   end;

var
   P1, P2, P3 : TVector2f;
   dx1, dx2, dx3 : single;
   Size : integer;
   S, E : TVector2f;
begin
   Size := High(_Buffer[0])+1;
   P1.U := _P1.U * Size;
   P1.V := _P1.V * Size;
   P2.U := _P2.U * Size;
   P2.V := _P2.V * Size;
   P3.U := _P3.U * Size;
   P3.V := _P3.V * Size;

	if (P2.V - P1.V > 0) then
      dx1 := (_P2.U - _P1.U) / (_P2.V - _P1.V)
   else
      dx1 := 0;

	if (P3.V - P1.V > 0) then
      dx2 := (_P3.U - _P1.U) / (_P2.V - _P1.V)
   else
      dx2 := 0;

	if (P3.V - P2.V > 0) then
      dx3 := (_P3.U - _P2.U) / (_P3.V - _P2.V)
   else
      dx3 := 0;

   AssignPoint(E,P1);
   AssignPoint(S,P1);

	if (dx1 > dx2) then
   begin
      while S.V <= P2.V do
      begin
   	   HorizontalLine(_Buffer, _HeightMap, _VisitedMap,S.U,E.U,S.V,Size);
         S.U := S.U + dx2;
         S.V := S.V + 1;
         E.U := E.U + dx1;
         E.V := E.V + 1;
      end;
		AssignPoint(E,P2);
      while S.V <= P3.V do
      begin
   	   HorizontalLine(_Buffer, _HeightMap, _VisitedMap,S.U,E.U,S.V,Size);
         S.U := S.U + dx2;
         S.V := S.V + 1;
         E.U := E.U + dx3;
         E.V := E.V + 1;
      end;
	end
   else
   begin
      while S.V <= P2.V do
      begin
   	   HorizontalLine(_Buffer,_HeightMap, _VisitedMap,S.U,E.U,S.V,Size);
         S.U := S.U + dx1;
         S.V := S.V + 1;
         E.U := E.U + dx2;
         E.V := E.V + 1;
      end;
		AssignPoint(S,P2);
      while S.V <= P3.V do
      begin
   	   HorizontalLine(_Buffer,_HeightMap, _VisitedMap,S.U,E.U,S.V,Size);
         S.U := S.U + dx3;
         S.V := S.V + 1;
         E.U := E.U + dx2;
         E.V := E.V + 1;
      end;
	end;
end;



procedure CTextureGenerator.SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer);
var
   x,y : integer;
begin
   SetLength(_Buffer,_Size,_Size);
   SetLength(_WeightBuffer,_Size,_Size);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer) to High(_Buffer) do
      begin
         _Buffer[x,y].X := 0;
         _Buffer[x,y].Y := 0;
         _Buffer[x,y].Z := 0;
         _Buffer[x,y].W := 0;
         _WeightBuffer[x,y] := 0;
      end;
   end;
end;

procedure CTextureGenerator.SetupFrameBuffer(var _Buffer: T2DFrameBuffer; _Size: integer);
var
   x,y : integer;
begin
   SetLength(_Buffer,_Size,_Size);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer) to High(_Buffer) do
      begin
         _Buffer[x,y].X := 0;
         _Buffer[x,y].Y := 0;
         _Buffer[x,y].Z := 0;
         _Buffer[x,y].W := 0;
      end;
   end;
end;

procedure CTextureGenerator.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
var
   x : integer;
begin
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      SetLength(_Buffer[x],0);
      SetLength(_WeightBuffer[x],0);
   end;
   SetLength(_Buffer,0);
   SetLength(_WeightBuffer,0);
end;

procedure CTextureGenerator.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer);
var
   x : integer;
begin
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      SetLength(_Buffer[x],0);
   end;
   SetLength(_Buffer,0);
end;

function CTextureGenerator.GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y : integer;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Transparent := false;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   SetLength(_AlphaMap,Result.Width,Result.Width);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            if ((_Buffer[x,y].X  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].X := 0; //_Buffer[x,y].X * -1;
            if (abs(_Buffer[x,y].X  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].X := _WeightBuffer[x,y];
            if ((_Buffer[x,y].Y  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].Y := 0; //_Buffer[x,y].Y * -1;
            if (abs(_Buffer[x,y].Y  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].Y := _WeightBuffer[x,y];
            if ((_Buffer[x,y].Z  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].Z := 0; //_Buffer[x,y].Z * -1;
            if (abs(_Buffer[x,y].Z  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].Z := _WeightBuffer[x,y];
            if ((_Buffer[x,y].W  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].W := 0; //_Buffer[x,y].W * -1;
            if (abs(_Buffer[x,y].W  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].W := _WeightBuffer[x,y];

            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Trunc((_Buffer[x,y].X / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].Y / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].Z / _WeightBuffer[x,y]) * 255));
            _AlphaMap[x,Result.Height - y] := Trunc(((_Buffer[x,y].W / _WeightBuffer[x,y])) * 255);
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;//$888888;
            _AlphaMap[x,Result.Height - y] := C_TRP_INVISIBLE;
         end;
      end;
   end;
   FixBilinearBorders(Result,_AlphaMap);
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Normal.X := _Buffer[x,y].X / _WeightBuffer[x,y];
            Normal.Y := _Buffer[x,y].Y / _WeightBuffer[x,y];
            Normal.Z := _Buffer[x,y].Z / _WeightBuffer[x,y];
            if abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0 then
               Normal.Z := 1;
            Normalize(Normal);
            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
      end;
   end;
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   SetLength(_AlphaMap,Result.Width,Result.Width);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Normal.X := _Buffer[x,y].X / _WeightBuffer[x,y];
            Normal.Y := _Buffer[x,y].Y / _WeightBuffer[x,y];
            Normal.Z := _Buffer[x,y].Z / _WeightBuffer[x,y];
            if abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0 then
               Normal.Z := 1;
            Normalize(Normal);
            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
            _AlphaMap[x,Result.Height - y] := C_TRP_OPAQUE;
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
            _AlphaMap[x,Result.Height - y] := C_TRP_INVISIBLE;
         end;
      end;
   end;
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   SetLength(_AlphaMap,Result.Width,Result.Width);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         Normal.X := _Buffer[x,y].X;
         Normal.Y := _Buffer[x,y].Y;
         Normal.Z := _Buffer[x,y].Z;
         if abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0 then
            Normal.Z := 1;
         Normalize(Normal);
         Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
         _AlphaMap[x,Result.Height - y] := C_TRP_OPAQUE;
      end;
   end;
end;

function CTextureGenerator.GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
var
   x,y : integer;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := RGBA(Round((1 + (_Buffer[x,y].X / _WeightBuffer[x,y])) * 127.5),Round((1 + (_Buffer[x,y].Y / _WeightBuffer[x,y])) * 127.5),Round((1 + (_Buffer[x,y].Z / _WeightBuffer[x,y])) * 127.5),Round((_Buffer[x,y].W / _WeightBuffer[x,y]) * 255));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
      end;
   end;
end;

function CTextureGenerator.GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer; var _AlphaMap: TByteMap): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
begin
   Size := GetPow2Size(_Size);
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      PaintTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsColours[_Faces[(i * _VerticesPerFace)]],_VertsColours[_Faces[(i * _VerticesPerFace)+1]],_VertsColours[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Result := GetColouredBitmapFromFrameBuffer(Buffer,WeightBuffer,_AlphaMap);
//   Result.SaveToFile('test.bmp');
   DisposeFrameBuffer(Buffer,WeightBuffer);
end;

function CTextureGenerator.GenerateNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
begin
   Size := GetPow2Size(_Size);
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      PaintTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsNormals[_Faces[(i * _VerticesPerFace)]],_VertsNormals[_Faces[(i * _VerticesPerFace)+1]],_VertsNormals[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Result := GetPositionedBitmapFromFrameBuffer(Buffer,WeightBuffer);
   DisposeFrameBuffer(Buffer,WeightBuffer);
end;

function CTextureGenerator.GenerateNormalWithHeightMapTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
   D1, D2, D3 : TVector4f;
begin
   Size := GetPow2Size(_Size);
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      D1.X := _VertsNormals[_Faces[(i * _VerticesPerFace)]].X;
      D1.Y := _VertsNormals[_Faces[(i * _VerticesPerFace)]].Y;
      D1.Z := _VertsNormals[_Faces[(i * _VerticesPerFace)]].Z;
      D1.W := (_VertsColours[_Faces[(i * _VerticesPerFace)]].X * _VertsColours[_Faces[(i * _VerticesPerFace)]].Y * _VertsColours[_Faces[(i * _VerticesPerFace)]].Z);
      D2.X := _VertsNormals[_Faces[(i * _VerticesPerFace)+1]].X;
      D2.Y := _VertsNormals[_Faces[(i * _VerticesPerFace)+1]].Y;
      D2.Z := _VertsNormals[_Faces[(i * _VerticesPerFace)+1]].Z;
      D2.W := (_VertsColours[_Faces[(i * _VerticesPerFace)+1]].X * _VertsColours[_Faces[(i * _VerticesPerFace)+1]].Y * _VertsColours[_Faces[(i * _VerticesPerFace)+1]].Z);
      D3.X := _VertsNormals[_Faces[(i * _VerticesPerFace)+2]].X;
      D3.Y := _VertsNormals[_Faces[(i * _VerticesPerFace)+2]].Y;
      D3.Z := _VertsNormals[_Faces[(i * _VerticesPerFace)+2]].Z;
      D3.W := (_VertsColours[_Faces[(i * _VerticesPerFace)+2]].X * _VertsColours[_Faces[(i * _VerticesPerFace)+2]].Y * _VertsColours[_Faces[(i * _VerticesPerFace)+2]].Z);

      PaintTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]],D1,D2,D3);
   end;
   Result := GetHeightPositionedBitmapFromFrameBuffer(Buffer,WeightBuffer);
   DisposeFrameBuffer(Buffer,WeightBuffer);
end;

procedure CTextureGenerator.PaintMeshDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
var
   i,LastFace : cardinal;
begin
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      PaintTriangle(_Buffer,_WeightBuffer,_TexCoords[_Faces[(i * _VerticesPerFace)]],_TexCoords[_Faces[(i * _VerticesPerFace)+1]],_TexCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsColours[_Faces[(i * _VerticesPerFace)]],_VertsColours[_Faces[(i * _VerticesPerFace)+1]],_VertsColours[_Faces[(i * _VerticesPerFace)+2]]);
   end;
end;

procedure CTextureGenerator.PaintMeshNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
var
   i,LastFace : cardinal;
begin
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      PaintTriangle(_Buffer,_WeightBuffer,_TexCoords[_Faces[(i * _VerticesPerFace)]],_TexCoords[_Faces[(i * _VerticesPerFace)+1]],_TexCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsNormals[_Faces[(i * _VerticesPerFace)]],_VertsNormals[_Faces[(i * _VerticesPerFace)+1]],_VertsNormals[_Faces[(i * _VerticesPerFace)+2]]);
   end;
end;

procedure CTextureGenerator.PaintMeshBumpMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; const _DiffuseMap: TBitmap);
var
   HeightMap,PixelMap : TByteMap;
   x,y,Size,Face : integer;
   r,g,b: real;
   VisitedMap : T2DBooleanMap;
begin
   // Build height map and visited map
   Size := High(_Buffer)+1;
   SetLength(HeightMap,Size,Size);
   SetLength(VisitedMap,Size,Size);
   for x := Low(HeightMap) to High(HeightMap) do
   begin
      for y := Low(HeightMap[x]) to High(HeightMap[x]) do
      begin
         r := GetRValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         g := GetGValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         b := GetBValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         // Convert to YIQ
         HeightMap[x,y] := Round(((0.299 * r) + (0.587 * g) + (0.114 * b)) * 255) and $FF;
         VisitedMap[x,y] := false;
      end;
   end;
   // Now, we'll check each face.
   Face := 0;
   while Face < High(_Faces) do
   begin
      // Paint the face here.
      PaintFlatTriangleFromHeightMap(_Buffer,HeightMap,VisitedMap,_TexCoords[_Faces[Face]],_TexCoords[_Faces[Face+1]],_TexCoords[_Faces[Face+2]]);

      // Go to next face.
      inc(Face,_VerticesPerFace);
   end;
end;


// This procedure fixes white/black borders in the edge of each partition.
procedure CTextureGenerator.FixBilinearBorders(var _Bitmap: TBitmap; var _AlphaMap: TByteMap);
var
   x,y,i,k,mini,maxi,mink,maxk,r,g,b,ri,gi,bi,sum : integer;
   AlphaMapBackup: TByteMap;
begin
   SetLength(AlphaMapBackup,High(_AlphaMap)+1,High(_AlphaMap)+1);
   for x := Low(_AlphaMap) to High(_AlphaMap) do
   begin
      for y := Low(_AlphaMap[x]) to High(_AlphaMap[x]) do
      begin
         AlphaMapBackup[x,y] := _AlphaMap[x,y];
      end;
   end;
   for x := Low(_AlphaMap) to High(_AlphaMap) do
   begin
      for y := Low(_AlphaMap[x]) to High(_AlphaMap[x]) do
      begin
         if AlphaMapBackup[x,y] = C_TRP_RGB_INVISIBLE then
         begin
            mini := x - 1;
            if mini < 0 then
               mini := 0;
            maxi := x + 1;
            if maxi > High(_AlphaMap) then
               maxi := High(_AlphaMap);
            mink := y - 1;
            if mink < 0 then
               mink := 0;
            maxk := y + 1;
            if maxk > High(_AlphaMap) then
               maxk := High(_AlphaMap);

            r := 0;
            g := 0;
            b := 0;
            sum := 0;
            for i := mini to maxi do
               for k := mink to maxk do
               begin
                  if AlphaMapBackup[i,k] <> C_TRP_RGB_INVISIBLE then
                  begin
                     ri := GetRValue(_Bitmap.Canvas.Pixels[i,k]);
                     gi := GetGValue(_Bitmap.Canvas.Pixels[i,k]);
                     bi := GetBValue(_Bitmap.Canvas.Pixels[i,k]);
                     r := r + ri;
                     g := g + gi;
                     b := b + bi;
                     inc(sum);
                  end;
               end;
            if (r + g + b) > 0 then
               _AlphaMap[x,y] := C_TRP_RGB_OPAQUE;
            if sum > 0 then
               _Bitmap.Canvas.Pixels[x,y] := RGB(r div sum, g div sum, b div sum);
         end;
      end;
   end;
   // Free memory
   for i := Low(_AlphaMap) to High(_AlphaMap) do
   begin
      SetLength(AlphaMapBackup[i],0);
   end;
   SetLength(AlphaMapBackup,0);
end;


end.
