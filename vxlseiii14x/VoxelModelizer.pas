unit VoxelModelizer;

interface

uses VoxelMap, BasicDataTypes, VoxelModelizerItem, BasicConstants, ThreeDMap;

type
   TVoxelModelizer = class
      private
         FMap : T3DIntGrid;
         FItems : array of TVoxelModelizerItem;
         PVoxelMap : PVoxelMap;
         PSemiSurfacesMap : P3DIntGrid;
         FNumVertexes : integer;
         FVertexMap: T3DIntGrid;
         FVertexes: TAVector3i;
         EdgeMap: T3DMap;
         F3DMap: T3DMap;
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32);
         // Misc
         procedure GenerateItemsMap;
         procedure ResetVertexMap;
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32);
var
   x, y, z: integer;
begin
   // Prepare basic variables.
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
   EdgeMap := T3DMap.Create((High(FMap) + 1)*C_VP_HIGH,(High(FMap[0]) + 1)*C_VP_HIGH,(High(FMap[0,0]) + 1)*C_VP_HIGH);
   SetLength(FVertexMap,EdgeMap.GetMaxX + 1,EdgeMap.GetMaxY + 1,EdgeMap.GetMaxZ + 1);
   F3DMap := T3DMap.Create(EdgeMap.GetMaxX + 1,EdgeMap.GetMaxY + 1,EdgeMap.GetMaxZ + 1);
   // Find out the regions where we will have meshes.
   GenerateItemsMap;
   // Write faces and vertexes for each item of the map.
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               FItems[FMap[x,y,z]] := TVoxelModelizerItem.Create(PVoxelMap^,PSemiSurfacesMap^,FVertexMap,EdgeMap,x,y,z,FNumVertexes);
               // Paint the faces in the 3D Map.
            end;
         end;
   // Confirm the vertex list.
   SetLength(_Vertexes,FNumVertexes);
   SetLength(FVertexes,FNumVertexes); // internal vertex list for future operations
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
         begin
            if FVertexMap[x,y,z] <> -1 then
            begin
               _Vertexes[FVertexMap[x,y,z]].X := x / C_VP_HIGH;
               _Vertexes[FVertexMap[x,y,z]].Y := y / C_VP_HIGH;
               _Vertexes[FVertexMap[x,y,z]].Z := z / C_VP_HIGH;
               FVertexes[FVertexMap[x,y,z]].X := x;
               FVertexes[FVertexMap[x,y,z]].Y := y;
               FVertexes[FVertexMap[x,y,z]].Z := z;
            end;
         end;
   // Classify the voxels from the 3D Map as in, out or surface.
   // Check every face to ensure that it is in the surface. Cut the ones inside.
   // Calculate the normals from each face.
   // Use raycasting procedure to ensure that the vertexes are ordered correctly (anti-clockwise)
   // Set a colour for each face.

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
   FNumVertexes := 0;
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
         begin
            FVertexMap[x,y,z] := -1;
         end;
end;


end.
