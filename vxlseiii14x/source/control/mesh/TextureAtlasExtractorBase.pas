unit TextureAtlasExtractorBase;

interface

uses BasicDataTypes, Geometry, NeighborhoodDataPlugin, MeshPluginBase, Math,
      NeighborDetector, IntegerList;

{$INCLUDE source/Global_Conditionals.inc}

type
   TTextureSeed = record
      MinBounds, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
      MeshID : integer;
   end;

   TSeedSet = array of TTextureSeed;
   TTexCompareFunction = function (const _Seed1, _Seed2 : TTextureSeed): real of object;

   CTextureAtlasExtractorBase = class
      protected
         // Get Mesh Seeds related functions.
         procedure SetupMeshSeeds(var _Vertices : TAVector3f; var _FaceNormals : TAVector3f; var _Faces : auint32;_VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _FaceNeighbors: TNeighborDetector; var _TexCoords: TAVector2f; var _MaxVerts: integer; var _FaceSeed : aint32; var _FacePriority: AFloat; var _FaceOrder : auint32; var _CheckFace: abool);
         procedure ReAlignSeedsToCenter(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _FaceNeighbors: TNeighborDetector; var _TexCoords: TAVector2f; var _FacePriority: AFloat; var _FaceOrder : auint32; var _CheckFace: abool; var _NeighborhoodPlugin: PMeshPluginBase);
         // Sort related functions
         function isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
         function CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
         function CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
         procedure QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
         procedure QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
         function SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Executes
         // Texture atlas buildup: step by step.
         function GetMeshSeeds(_MeshID: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _NeighborhoodPlugin: PMeshPluginBase): TAVector2f; virtual; abstract;
         procedure MergeSeeds(var _Seeds: TSeedSet); virtual;
         procedure GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
   end;

implementation

constructor CTextureAtlasExtractorBase.Create;
begin
   Initialize;
end;

destructor CTextureAtlasExtractorBase.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTextureAtlasExtractorBase.Initialize;
begin
   // do nothing
end;

procedure CTextureAtlasExtractorBase.Clear;
begin
   // do nothing
end;

procedure CTextureAtlasExtractorBase.Reset;
begin
   Clear;
   Initialize;
end;

procedure CTextureAtlasExtractorBase.SetupMeshSeeds(var _Vertices : TAVector3f; var _FaceNormals : TAVector3f; var _Faces : auint32;_VerticesPerFace: integer; var _Seeds: TSeedSet; var _VertsSeed : aint32; var _FaceNeighbors: TNeighborDetector; var _TexCoords: TAVector2f; var _MaxVerts: integer; var _FaceSeed : aint32; var _FacePriority: AFloat; var _FaceOrder : auint32; var _CheckFace: abool);
var
   i: integer;
begin
   // Get the neighbours of each face.
   _FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
   _FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);

   // Setup FaceSeed, FaceOrder and FacePriority.
   SetLength(_FaceSeed,High(_FaceNormals)+1);
   SetLength(_FaceOrder,High(_FaceSeed)+1);
   SetLength(_FacePriority,High(_FaceSeed)+1);
   SetLength(_CheckFace,High(_FaceNormals)+1);
   for i := Low(_FaceSeed) to High(_FaceSeed) do
   begin
      _FaceSeed[i] := -1;
      _FaceOrder[i] := i;
      _FacePriority[i] := Max(Max(abs(_FaceNormals[i].X),abs(_FaceNormals[i].Y)),abs(_FaceNormals[i].Z));
   end;
   QuickSortPriority(Low(_FaceOrder),High(_FaceOrder),_FaceOrder,_FacePriority);

   // Setup VertsSeed.
   _MaxVerts := High(_Vertices)+1;
   SetLength(_VertsSeed,_MaxVerts);
   for i := Low(_VertsSeed) to High(_VertsSeed) do
   begin
      _VertsSeed[i] := -1;
   end;
   // Setup Texture Coordinates (Result)
   SetLength(_TexCoords,_MaxVerts);
end;

procedure CTextureAtlasExtractorBase.ReAlignSeedsToCenter(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _FaceNeighbors: TNeighborDetector; var _TexCoords: TAVector2f; var _FacePriority: AFloat; var _FaceOrder : auint32; var _CheckFace: abool; var _NeighborhoodPlugin: PMeshPluginBase);
var
   i: integer;
begin
   // Re-align vertexes and seed bounds to start at (0,0)
   for i := Low(_VertsSeed) to High(_VertsSeed) do
   begin
      _TexCoords[i].U := _TexCoords[i].U - _Seeds[_VertsSeed[i]].MinBounds.U;
      _TexCoords[i].V := _TexCoords[i].V - _Seeds[_VertsSeed[i]].MinBounds.V;
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
      _FaceNeighbors.Free;
   end;
   SetLength(_FacePriority,0);
   SetLength(_FaceOrder,0);
   SetLength(_CheckFace,0);
end;

procedure CTextureAtlasExtractorBase.MergeSeeds(var _Seeds: TSeedSet);
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

procedure CTextureAtlasExtractorBase.GetFinalTextureCoordinates(var _Seeds: TSeedSet; var _VertsSeed : aint32; var _TexCoords: TAVector2f);
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
function CTextureAtlasExtractorBase.isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
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

// Sort
function CTextureAtlasExtractorBase.CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed1.MaxBounds.U - _Seed1.MinBounds.U) - (_Seed2.MaxBounds.U - _Seed2.MinBounds.U);
end;

function CTextureAtlasExtractorBase.CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed1.MaxBounds.V - _Seed1.MinBounds.V) - (_Seed2.MaxBounds.V - _Seed2.MinBounds.V);
end;

// Adapted from OMC Manager
procedure CTextureAtlasExtractorBase.QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
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

procedure CTextureAtlasExtractorBase.QuickSortPriority(_min, _max : integer; var _FaceOrder: auint32; const _FacePriority : afloat);
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
function CTextureAtlasExtractorBase.SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
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
