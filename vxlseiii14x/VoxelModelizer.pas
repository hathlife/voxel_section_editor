unit VoxelModelizer;

interface

uses VoxelMap, BasicDataTypes, VoxelModelizerItem, BasicConstants, ThreeDMap,
   Palette;

type
   TVoxelModelizer = class
      private
         FMap : T3DIntGrid;
         FItems : array of TVoxelModelizerItem;
         PVoxelMap : PVoxelMap;
         PSemiSurfacesMap : P3DIntGrid;
         FNumVertexes : integer;
         FVertexMap: T3DIntGrid;
         function GetNormals(_V1,_V2,_V3: TVector3f): TVector3f;
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32; var _Normals: TAVector3f; var _Colours: TAVector4f; const _Palette: TPalette; const _ColourMap: TVoxelMap);
         destructor Destroy; override;
         // Misc
         procedure GenerateItemsMap;
         procedure ResetVertexMap;
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid; var _Vertexes: TAVector3f; var _Faces: auint32; var _Normals: TAVector3f; var _Colours: TAVector4f; const _Palette: TPalette; const _ColourMap: TVoxelMap);
var
   x, y, z, i, f, v, pos, NumFaces: integer;
   EdgeMap: T3DMap;
   ModelMap: T3DMap;
   Vertexes: TAVector3i;
   Normal : TVector3f;
begin
   // Prepare basic variables.
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
   // Find out the regions where we will have meshes.
   GenerateItemsMap;
   // Prepare other map types.
   EdgeMap := T3DMap.Create(((High(FMap) + 1)*C_VP_HIGH)+1,((High(FMap[0]) + 1)*C_VP_HIGH)+1,((High(FMap[0,0]) + 1)*C_VP_HIGH)+1);
   SetLength(FVertexMap,EdgeMap.GetMaxX + 1,EdgeMap.GetMaxY + 1,EdgeMap.GetMaxZ + 1);
   for x := Low(FVertexMap) to High(FVertexMap) do
      for y := Low(FVertexMap[x]) to High(FVertexMap[x]) do
         for z := Low(FVertexMap[x,y]) to High(FVertexMap[x,y]) do
            FVertexMap[x,y,z] := -1;
   ModelMap := T3DMap.Create(EdgeMap.GetMaxX + 1,EdgeMap.GetMaxY + 1,EdgeMap.GetMaxZ + 1);
   // Write faces and vertexes for each item of the map.
   for x := Low(FMap) to High(FMap) do
      for y := Low(FMap[x]) to High(FMap[x]) do
         for z := Low(FMap[x,y]) to High(FMap[x,y]) do
         begin
            if FMap[x,y,z] <> -1 then
            begin
               FItems[FMap[x,y,z]] := TVoxelModelizerItem.Create(PVoxelMap^,PSemiSurfacesMap^,FVertexMap,EdgeMap,x,y,z,FNumVertexes,_Palette,_ColourMap);
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
   for i := Low(FItems) to High(FItems) do
   begin
      f := 0;
      while f < High(FItems[i].Faces) do
      begin
         ModelMap.PaintFace(Vertexes[FItems[i].Faces[f]],Vertexes[FItems[i].Faces[f+1]],Vertexes[FItems[i].Faces[f+2]],1);
         inc(f,3);
      end;
   end;
   // Classify the voxels from the 3D Map as in, out or surface.
   ModelMap.GenerateSelfSurfaceMap;
   // Check every face to ensure that it is in the surface. Cut the ones inside
   // the volume.
   NumFaces := 0;
   for i := Low(FItems) to High(FItems) do
   begin
      v := 0;
      f := 0;
      while f <= High(FItems[i].FaceLocation) do
      begin
//         if ModelMap.IsFaceValid(Vertexes[FItems[i].Faces[v]],Vertexes[FItems[i].Faces[v+1]],Vertexes[FItems[i].Faces[v+2]],C_INSIDE_VOLUME) then
//         begin
            FItems[i].FaceLocation[f] := NumFaces*3;
            inc(NumFaces);
//         end;
         inc(f);
         inc(v,3);
      end;
   end;
   // Generate the final faces array.
   SetLength(_Faces,NumFaces*3);
   SetLength(_Colours,NumFaces);
   SetLength(_Normals,NumFaces);
   for i := Low(FItems) to High(FItems) do
   begin
      v := 0;
      f := 0;
      while f <= High(FItems[i].FaceLocation) do
      begin
         if FItems[i].FaceLocation[f] > -1 then
         begin
            pos := FItems[i].FaceLocation[f] div 3;
            // Calculate the normals from each face.
            Normal := GetNormals(_Vertexes[FItems[i].Faces[v]],_Vertexes[FItems[i].Faces[v+1]],_Vertexes[FItems[i].Faces[v+2]]);
            // Use 'raycasting' procedure to ensure that the vertexes are ordered correctly (anti-clockwise)
            if not ModelMap.IsFaceNormalsCorrect(Vertexes[FItems[i].Faces[v]],Vertexes[FItems[i].Faces[v+1]],Vertexes[FItems[I].Faces[v+2]],Normal) then
            begin
               Normal.X := Normal.X * (-1);
               Normal.Y := Normal.Y * (-1);
               Normal.Z := Normal.Z * (-1);
               _Faces[FItems[i].FaceLocation[f]] := FItems[i].Faces[v+2];
               _Faces[FItems[i].FaceLocation[f]+1] := FItems[i].Faces[v+1];
               _Faces[FItems[i].FaceLocation[f]+2] := FItems[i].Faces[v];
            end
            else
            begin
               _Faces[FItems[i].FaceLocation[f]] := FItems[i].Faces[v];
               _Faces[FItems[i].FaceLocation[f]+1] := FItems[i].Faces[v+1];
               _Faces[FItems[i].FaceLocation[f]+2] := FItems[i].Faces[v+2];
            end;
            // Set normals value
            _Normals[pos].X := Normal.X;
            _Normals[pos].Y := Normal.Y;
            _Normals[pos].Z := Normal.Z;
            // Set a colour for each face.
            _Colours[pos].X := FItems[i].Colour.X;
            _Colours[pos].Y := FItems[i].Colour.Y;
            _Colours[pos].Z := FItems[i].Colour.Z;
            _Colours[pos].W := FItems[i].Colour.W;
         end;
         inc(f);
         inc(v,3);
      end;
   end;

   // Free memory
   ModelMap.Free;
   EdgeMap.Free;
   SetLength(Vertexes,0);
end;

destructor TVoxelModelizer.Destroy;
var
   x,y : integer;
begin
   for x := Low(FItems) to High(FItems) do
   begin
      FItems[x].Free;
   end;
   SetLength(FItems,0);
   x := High(FMap);
   while x >= 0 do
   begin
      y := High(FMap[x]);
      while y >= 0 do
      begin
         SetLength(FMap[x,y],0);
         dec(y);
      end;
      SetLength(FMap[x],0);
      dec(x);
   end;
   SetLength(FMap,0);
   x := High(FVertexMap);
   while x >= 0 do
   begin
      y := High(FVertexMap[x]);
      while y >= 0 do
      begin
         SetLength(FVertexMap[x,y],0);
         dec(y);
      end;
      SetLength(FVertexMap[x],0);
      dec(x);
   end;
   SetLength(FVertexMap,0);
   inherited Destroy;
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

function TVoxelModelizer.GetNormals(_V1,_V2,_V3: TVector3f): TVector3f;
begin
   Result.X := ((_V3.Y - _V2.Y) * (_V1.Z - _V2.Z)) - ((_V1.Y - _V2.Y) * (_V3.Z - _V2.Z));
   Result.Y := ((_V3.Z - _V2.Z) * (_V1.X - _V2.X)) - ((_V1.Z - _V2.Z) * (_V3.X - _V2.X));
   Result.Z := ((_V3.X - _V2.X) * (_V1.Y - _V2.Y)) - ((_V1.X - _V2.X) * (_V3.Y - _V2.Y));
end;

end.
