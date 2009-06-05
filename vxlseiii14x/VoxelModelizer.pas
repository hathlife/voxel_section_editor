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
         FNumVertices : integer;
         FVertexMap: T3DIntGrid;
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid);
         // Misc
         procedure GenerateItemsMap;
         procedure ResetVertexMap;
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid);
var
   x, y, z: integer;
begin
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
   SetLength(FVertexMap,(High(FMap) + 1)*C_VP_HIGH,(High(FMap[0]) + 1)*C_VP_HIGH,(High(FMap[0,0]) + 1)*C_VP_HIGH);
   GenerateItemsMap;
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               FItems[FMap[x,y,z]] := TVoxelModelizerItem.Create(PVoxelMap^,PSemiSurfacesMap^,FVertexMap,x,y,z,FNumVertices);
            end;
         end;
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
            if (PVoxelMap^.Map[x,y,z] > C_OUTSIDE_VOLUME) and (PVoxelMap^.Map[x,y,z] < C_INSIDE_VOLUME) then
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

procedure TVoxelModelizer.ResetVertexMap;
var
   x, y, z: integer;
begin
   FNumVertices := 0;
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
         begin
            FVertexMap[x,y,z] := -1;
         end;
end;


end.
