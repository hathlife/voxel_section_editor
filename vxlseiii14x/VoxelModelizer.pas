unit VoxelModelizer;

interface

uses VoxelMap, BasicDataTypes, VoxelModelizerItem;

type
   TVoxelModelizer = class
      private
         FMap : T3DIntGrid;
         FItems : array of TVoxelModelizerItem;
         PVoxelMap : PVoxelMap;
         PSemiSurfacesMap : P3DIntGrid;
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid);
         // Misc
         procedure GenerateItemsMap;
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid);
begin
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
   GenerateItemsMap;
end;

procedure TVoxelModelizer.GenerateItemsMap;
var
   x, y, z: integer;
   NumItems : integer;
begin
   PVoxelMap^.Bias := 0;
   NumItems := 0;
   SetLength(FMap,PVoxelMap^.GetMaxX+1,PVoxelMap^.GetMaxY+1,PVoxelMap^.GetMaxZ+1);
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if PVoxelMap^.Map[x,y,z] <> C_OUTSIDE_VOLUME then
            begin
               FMap[x,y,z] := NumItems;
               inc(NumItems);
            end
            else
            begin
               FMap[x,y,z] := -1;
            end;
         end;
   SetLength(FItems,NumItems);
end;


end.
