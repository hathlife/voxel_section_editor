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
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32; var _Normals: TAVector3f; var _Colours: TAVector4f);
         // Misc
         procedure GenerateItemsMap;
         procedure ResetVertexMap;
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32; var _Normals: TAVector3f; var _Colours: TAVector4f);
var
   x, y, z, f, v, NumFaces: integer;
   EdgeMap: T3DMap;
   ModelMap: T3DMap;
   Vertexes: TAVector3i;
begin
   // Prepare basic variables.
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
   EdgeMap := T3DMap.Create((High(FMap) + 1)*C_VP_HIGH,(High(FMap[0]) + 1)*C_VP_HIGH,(High(FMap[0,0]) + 1)*C_VP_HIGH);
   SetLength(FVertexMap,EdgeMap.GetMaxX + 1,EdgeMap.GetMaxY + 1,EdgeMap.GetMaxZ + 1);
   ModelMap := T3DMap.Create(EdgeMap.GetMaxX + 1,EdgeMap.GetMaxY + 1,EdgeMap.GetMaxZ + 1);
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
            end;
         end;
   // Confirm the vertex list.
   SetLength(_Vertexes,FNumVertexes);
   SetLength(Vertexes,FNumVertexes); // internal vertex list for future operations
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
         begin
            if FVertexMap[x,y,z] <> -1 then
            begin
               _Vertexes[FVertexMap[x,y,z]].X := x / C_VP_HIGH;
               _Vertexes[FVertexMap[x,y,z]].Y := y / C_VP_HIGH;
               _Vertexes[FVertexMap[x,y,z]].Z := z / C_VP_HIGH;
               Vertexes[FVertexMap[x,y,z]].X := x;
               Vertexes[FVertexMap[x,y,z]].Y := y;
               Vertexes[FVertexMap[x,y,z]].Z := z;
            end;
         end;
   // Paint the faces in the 3D Map.
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               f := 0;
               while f <= High(FItems[FMap[x,y,z]].Faces) do
               begin
                  ModelMap.PaintFace(Vertexes[FItems[FMap[x,y,z]].Faces[f]],Vertexes[FItems[FMap[x,y,z]].Faces[f+1]],Vertexes[FItems[FMap[x,y,z]].Faces[f+2]],1);
                  inc(f,3);
               end;
            end;
         end;
   // Classify the voxels from the 3D Map as in, out or surface.
   ModelMap.GenerateSelfSurfaceMap;
   // Check every face to ensure that it is in the surface. Cut the ones inside
   // the volume.
   NumFaces := 0;
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               v := 0;
               f := 0;
               while f <= High(FItems[FMap[x,y,z]].FaceLocation) do
               begin
                  if ModelMap.IsFaceValid(Vertexes[FItems[FMap[x,y,z]].Faces[v]],Vertexes[FItems[FMap[x,y,z]].Faces[v+1]],Vertexes[FItems[FMap[x,y,z]].Faces[v+2]],C_INSIDE_VOLUME) then
                  begin
                     FItems[FMap[x,y,z]].FaceLocation[f] := NumFaces*3;
                     inc(NumFaces);
                  end;
                  inc(f);
                  inc(v,3);
               end;
            end;
         end;
   // Generate the final faces array.
   SetLength(_Faces,NumFaces*3);
   SetLength(_Colours,NumFaces);
   SetLength(_Normals,NumFaces);
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               v := 0;
               f := 0;
               while f <= High(FItems[FMap[x,y,z]].FaceLocation) do
               begin
                  if FItems[FMap[x,y,z]].FaceLocation[f] > -1 then
                  begin
                     _Faces[FItems[FMap[x,y,z]].FaceLocation[f]] := FItems[FMap[x,y,z]].Faces[v];
                     _Faces[FItems[FMap[x,y,z]].FaceLocation[f]+1] := FItems[FMap[x,y,z]].Faces[v+1];
                     _Faces[FItems[FMap[x,y,z]].FaceLocation[f]+2] := FItems[FMap[x,y,z]].Faces[v+2];
                     // Set a colour for each face.
                     // Calculate the normals from each face.
                     // Use raycasting procedure to ensure that the vertexes are ordered correctly (anti-clockwise)
                  end;
                  inc(f);
                  inc(v,3);
               end;
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
   FNumVertexes := 0;
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
         begin
            FVertexMap[x,y,z] := -1;
         end;
end;


end.
