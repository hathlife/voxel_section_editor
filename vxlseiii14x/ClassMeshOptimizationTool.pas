unit ClassMeshOptimizationTool;

interface

uses Geometry, BasicDataTypes, ClassNeighborDetector, ClassStopWatch, ClassIntegerList,
GLConstants, Dialogs, SysUtils, BasicFunctions, ClassVertexTransformationUtils,
ClassIntegerSet;

{$INCLUDE Global_Conditionals.inc}

type
   TMeshOptimizationTool = class
      private
         VertexNeighbors,FaceNeighbors: TNeighborDetector;
         BorderVertexes: abool;
         FIgnoreColours: boolean;
         FAngle : single;
         FAngleBorder : single;
         // Removable Vertexes Detection
         procedure DetectUselessVertexes(var _Vertices, _Normals, _FaceNormals : TAVector3f; var _Colours : TAVector4f; var _VertexTransformation: aint32);
         procedure DetectUselessVertexesIgnoringColours(var _Vertices, _Normals, _FaceNormals : TAVector3f; const _Textures: TAVector2f; var _VertexTransformation: aint32);
         // Merge Vertexes
         procedure MergeVertexes(var _Vertices, _Normals: TAVector3f; var _VertexTransformation: aint32);
         procedure MergeVertexesWithTextures(var _Vertices, _Normals: TAVector3f; var _TexCoords : TAVector2f; var _VertexTransformation: aint32);
         // Merge Vertex Utils
         function areBorderVertexesHiddenByTriangle(var _Vertices: TAVector3f; _V1,_V2,_Normal: TVector3f; var _NeighbourList,_BorderList: CIntegerSet): boolean; overload;
         function areBorderVertexesHiddenByTriangle(var _Vertices: TAVector3f; _V1,_V2,_V3,_Normal: TVector3f; var _BorderList: CIntegerSet): boolean; overload;
         function IsPointInsideTriangle(const _V1,_V2,_V3,_P : TVector2f): boolean;
         function Dot2D(const _V1,_V2: TVector2f): single;
         // Miscellaneous
         function GetBorderVertexList(const _Vertices: TAVector3f; const _Faces : auint32; _VerticesPerFace : integer): abool;
      public
         // Constructors and Destructors
         constructor Create(_IgnoreColors: boolean; _Angle: single);
         destructor Destroy; override;
         // Executes
         procedure Execute(var _Vertices, _Normals, _FaceNormals : TAVector3f; var _Colours : TAVector4f; var _TexCoords : TAVector2f; var _Faces : auint32; _VerticesPerFace,_ColoursType,_NormalsType : integer; var _NumFaces: longword);
   end;

implementation

constructor TMeshOptimizationTool.Create(_IgnoreColors: boolean; _Angle: single);
begin
   VertexNeighbors := TNeighborDetector.Create;
   FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
   SetLength(BorderVertexes,0);
   FIgnoreColours := _IgnoreColors;
   FAngle := _Angle;
   FAngleBorder := _Angle;
end;

destructor TMeshOptimizationTool.Destroy;
begin
   SetLength(BorderVertexes,0);
   // Clean up memory
   VertexNeighbors.Free;
   FaceNeighbors.Free;
end;

procedure TMeshOptimizationTool.Execute(var _Vertices, _Normals, _FaceNormals : TAVector3f; var _Colours : TAVector4f; var _TexCoords : TAVector2f; var _Faces : auint32; _VerticesPerFace,_ColoursType,_NormalsType : integer; var _NumFaces: longword);
var
   VertexTransformation : aint32;
   v, Value,HitCounter : integer;
   VertexBackup,NormalsBackup: TAVector3f;
   ColoursBackup: TAVector4f;
   TextureBackup: TAVector2f;
   FacesBackup: aint32;
   {$ifdef OPTIMIZATION_INFO}
   OriginalVertexCount,RemovableVertexCount, BorderVertexCount, BorderRemovable: integer;
   {$endif}
begin
   VertexNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);
   FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);
   if (High(_TexCoords) > 0) then
   begin
      BorderVertexes := GetBorderVertexList(_Vertices,_Faces,_VerticesPerFace);
   end
   else
   begin
      SetLength(BorderVertexes,High(_Vertices)+1);
      for v := Low(BorderVertexes) to High(BorderVertexes) do
      begin
         BorderVertexes[v] := false;
      end;
  end;

   SetLength(VertexTransformation,High(_Vertices)+1);
   // Step 1: check vertexes that can be removed.
   if FIgnoreColours then
   begin
      DetectUselessVertexesIgnoringColours(_Vertices,_Normals,_FaceNormals,_TexCoords,VertexTransformation);
   end
   else
   begin
      DetectUselessVertexes(_Vertices,_Normals,_FaceNormals,_Colours,VertexTransformation);
   end;
   {$ifdef OPTIMIZATION_INFO}
   RemovableVertexCount := 0;
   BorderVertexCount := 0;
   BorderRemovable := 0;
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      if BorderVertexes[v] then
      begin
         inc(BorderVertexCount);
      end;
      if VertexTransformation[v] = -1 then
      begin
         inc(RemovableVertexCount);
         if BorderVertexes[v] then
         begin
            inc(BorderRemovable);
         end;
      end;
   end;
   OriginalVertexCount := High(_Vertices)+1;
   ShowMessage('This mesh originally has ' + IntToStr(OriginalVertexCount) + ' vertexes and ' + IntToStr(High(_FaceNormals)+1) + ' faces. From the vertexes, ' + IntToStr(BorderVertexCount) + ' of them are at the border of partitions and ' + IntToStr(High(_Vertices)+1-BorderVertexCount) + ' are not. We have found ' + IntToStr(RemovableVertexCount) + ' that could be potentially eliminated. From them, ' + IntToStr(BorderRemovable) + ' are border vertexes while ' + IntToStr(RemovableVertexCount - BorderRemovable) + ' are not.');
   {$endif}
   // Step 2: Find edges from potentialy removed vertexes.
   if High(_TexCoords) < 0 then
   begin
      MergeVertexes(_Vertices,_Normals,VertexTransformation);
   end
   else
   begin
      MergeVertexesWithTextures(_Vertices,_Normals,_TexCoords,VertexTransformation);
   end;
   // Step 3: Convert the vertexes from the faces to the new values.
   for v := Low(_Faces) to High(_Faces) do
   begin
      _Faces[v] := VertexTransformation[_Faces[v]];
   end;
   // Step 4: Get the positions of the vertexes in the new vertex list.
   HitCounter := 0;
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      if VertexTransformation[v] <> v then
      begin
         VertexTransformation[v] := -1;    // eliminated
      end
      else
      begin
         VertexTransformation[v] := HitCounter;
         inc(HitCounter);
      end;
   end;
   // Step 5: Backup vertexes.
   SetLength(VertexBackup,High(_Vertices)+1);
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      VertexBackup[v].X := _Vertices[v].X;
      VertexBackup[v].Y := _Vertices[v].Y;
      VertexBackup[v].Z := _Vertices[v].Z;
   end;
   if (_NormalsType = C_NORMALS_PER_VERTEX) then
   begin
      SetLength(NormalsBackup,High(_Vertices)+1);
      for v := Low(_Vertices) to High(_Vertices) do
      begin
         NormalsBackup[v].X := _Normals[v].X;
         NormalsBackup[v].Y := _Normals[v].Y;
         NormalsBackup[v].Z := _Normals[v].Z;
      end;
   end;
   if (_ColoursType >= C_COLOURS_PER_VERTEX) then
   begin
      SetLength(ColoursBackup,High(_Vertices)+1);
      for v := Low(_Vertices) to High(_Vertices) do
      begin
         ColoursBackup[v].X := _Colours[v].X;
         ColoursBackup[v].Y := _Colours[v].Y;
         ColoursBackup[v].Z := _Colours[v].Z;
         ColoursBackup[v].W := _Colours[v].W;
      end;
   end;
   if (_ColoursType = C_COLOURS_FROM_TEXTURE) then
   begin
      SetLength(TextureBackup,High(_Vertices)+1);
      for v := Low(_Vertices) to High(_Vertices) do
      begin
         TextureBackup[v].U := _TexCoords[v].U;
         TextureBackup[v].V := _TexCoords[v].V;
      end;
   end;
   // Step 6: Now we rewrite the vertex list.
   SetLength(_Vertices,HitCounter);
   for v := Low(VertexTransformation) to High(VertexTransformation) do
   begin
      if VertexTransformation[v] <> -1 then
      begin
         _Vertices[VertexTransformation[v]].X := VertexBackup[v].X;
         _Vertices[VertexTransformation[v]].Y := VertexBackup[v].Y;
         _Vertices[VertexTransformation[v]].Z := VertexBackup[v].Z;
      end;
   end;
   SetLength(VertexBackup,0);
   if (_NormalsType = C_NORMALS_PER_VERTEX) then
   begin
      SetLength(_Normals,HitCounter);
      for v := Low(VertexTransformation) to High(VertexTransformation) do
      begin
         if VertexTransformation[v] <> -1 then
         begin
            _Normals[VertexTransformation[v]].X := NormalsBackup[v].X;
            _Normals[VertexTransformation[v]].Y := NormalsBackup[v].Y;
            _Normals[VertexTransformation[v]].Z := NormalsBackup[v].Z;
         end;
      end;
      SetLength(NormalsBackup,0);
   end;
   if (_ColoursType >= C_COLOURS_PER_VERTEX) then
   begin
      SetLength(_Colours,HitCounter);
      for v := Low(VertexTransformation) to High(VertexTransformation) do
      begin
         if VertexTransformation[v] <> -1 then
         begin
            _Colours[VertexTransformation[v]].X := ColoursBackup[v].X;
            _Colours[VertexTransformation[v]].Y := ColoursBackup[v].Y;
            _Colours[VertexTransformation[v]].Z := ColoursBackup[v].Z;
            _Colours[VertexTransformation[v]].W := ColoursBackup[v].W;
         end;
      end;
      SetLength(ColoursBackup,0);
   end;
   if (_ColoursType = C_COLOURS_FROM_TEXTURE) then
   begin
      SetLength(_TexCoords,HitCounter);
      for v := Low(VertexTransformation) to High(VertexTransformation) do
      begin
         if VertexTransformation[v] <> -1 then
         begin
            _TexCoords[VertexTransformation[v]].U := TextureBackup[v].U;
            _TexCoords[VertexTransformation[v]].V := TextureBackup[v].V;
         end;
      end;
      SetLength(TextureBackup,0);
   end;
   // Step 7: Reconvert the vertexes from the faces to the new values.
   for v := Low(_Faces) to High(_Faces) do
   begin
      _Faces[v] := VertexTransformation[_Faces[v]];
   end;
   // Step 8: Backup faces.
   SetLength(FacesBackup,High(_Faces)+1);
   for v := Low(_Faces) to High(_Faces) do
   begin
      FacesBackup[v] := _Faces[v];
   end;
   if (_NormalsType = C_NORMALS_PER_FACE) then
   begin
      SetLength(NormalsBackup,High(_Normals)+1);
      for v := Low(_Normals) to High(_Normals) do
      begin
         NormalsBackup[v].X := _Normals[v].X;
         NormalsBackup[v].Y := _Normals[v].Y;
         NormalsBackup[v].Z := _Normals[v].Z;
      end;
   end;
   if (_ColoursType = C_COLOURS_PER_FACE) then
   begin
      SetLength(ColoursBackup,High(_Colours)+1);
      for v := Low(_Colours) to High(_Colours) do
      begin
         ColoursBackup[v].X := _Colours[v].X;
         ColoursBackup[v].Y := _Colours[v].Y;
         ColoursBackup[v].Z := _Colours[v].Z;
         ColoursBackup[v].W := _Colours[v].W;
      end;
   end;
   // Step 9: Check for faces with two or more equal vertexes and mark
   // them for elimination.
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      VertexTransformation[v] := 0; // we'll use this vector to detect repetition.
   end;
   v := 0;
   while v <= High(_Faces) do
   begin
      // Check for repetition
      Value := v;
      while Value < (v + _VerticesPerFace) do
      begin
         if VertexTransformation[_Faces[Value]] = 0 then
         begin
            VertexTransformation[_Faces[Value]] := 1;
            inc(Value);
         end
         else // We have a repetition and we'll wipe this face.
         begin
            Value := v + _VerticesPerFace + 1;
         end;
      end;
      if Value < (v + _VerticesPerFace + 1) then
      begin
         // Quickly clean up VertexTransformation
         Value := v;
         while Value < (v + _VerticesPerFace) do
         begin
            VertexTransformation[_Faces[Value]] := 0;
            inc(Value);
         end;
      end
      else
      begin
         // Face elimination happens here.
         Value := v;
         while Value < (v + _VerticesPerFace) do
         begin
            VertexTransformation[_Faces[Value]] := 0;
            FacesBackup[Value] := -1;
            inc(Value);
         end;
      end;
      // Let's move on.
      inc(v,_VerticesPerFace);
   end;
   SetLength(VertexTransformation,0);
   // Step 10: Rewrite the faces.
   HitCounter := 0;
   v := 0;
   while v <= High(_Faces) do
   begin
      if FacesBackup[v] <> -1 then
      begin
         Value := 0;
         while Value < _VerticesPerFace do
         begin
            _Faces[HitCounter+Value] := FacesBackup[v+Value];
            inc(Value);
         end;
         if (_NormalsType = C_NORMALS_PER_FACE) then
         begin
            _Normals[HitCounter div _VerticesPerFace].X := NormalsBackup[v div _VerticesPerFace].X;
            _Normals[HitCounter div _VerticesPerFace].Y := NormalsBackup[v div _VerticesPerFace].Y;
            _Normals[HitCounter div _VerticesPerFace].Z := NormalsBackup[v div _VerticesPerFace].Z;
         end;
         if (_ColoursType = C_COLOURS_PER_FACE) then
         begin
            _Colours[HitCounter div _VerticesPerFace].X := ColoursBackup[v div _VerticesPerFace].X;
            _Colours[HitCounter div _VerticesPerFace].Y := ColoursBackup[v div _VerticesPerFace].Y;
            _Colours[HitCounter div _VerticesPerFace].Z := ColoursBackup[v div _VerticesPerFace].Z;
            _Colours[HitCounter div _VerticesPerFace].W := ColoursBackup[v div _VerticesPerFace].W;
         end;
         inc(HitCounter,_VerticesPerFace);
      end;
      inc(v,_VerticesPerFace);
   end;
   {$ifdef OPTIMIZATION_INFO}
   ShowMessage('Efficience Analysis: Faces: ' + IntToStr(HitCounter div _VerticesPerFace) + '/' + IntToStr(_NumFaces) + ' (' + FloatToStr(((HitCounter div _VerticesPerFace) * 100) / _NumFaces) + '%) and Vertexes: ' + IntToStr(High(_Vertices)+1) + '/' + IntToStr(OriginalVertexCount-RemovableVertexCount) +  ' (' + FloatToStr(((High(_Vertices)+1)*100) / (OriginalVertexCount - RemovableVertexCount)) + '%)');
   {$endif}
   _NumFaces := HitCounter div _VerticesPerFace;
   SetLength(_Faces,HitCounter);
   SetLength(FacesBackup,0);
   SetLength(NormalsBackup,0);
   SetLength(ColoursBackup,0);
end;

procedure TMeshOptimizationTool.DetectUselessVertexes(var _Vertices, _Normals, _FaceNormals : TAVector3f; var _Colours : TAVector4f; var _VertexTransformation: aint32);
var
   v, Value : integer;
   SkipNeighbourCheck : boolean;
   Angle,MaxAngle : single;
begin
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      _VertexTransformation[v] := v;
      // Here we check if every neighbor has the same colour and normal is
      // close to the vertex (v) being evaluated.
      Value := VertexNeighbors.GetNeighborFromID(v);
      SkipNeighbourCheck := false;
      while Value <> -1 do
      begin
         if BorderVertexes[v] = BorderVertexes[Value] then
         begin
            // if colour is different, then the vertex stays.
            if (_Colours[v].X <> _Colours[Value].X) or (_Colours[v].Y <> _Colours[Value].Y) or (_Colours[v].Z <> _Colours[Value].Z) or (_Colours[v].W <> _Colours[Value].W)  then
            begin
               _VertexTransformation[v] := v;
               Value := -1;
               SkipNeighbourCheck := true;
            end
            else
               Value := VertexNeighbors.GetNextNeighbor;
         end
         else
            Value := VertexNeighbors.GetNextNeighbor;
      end;
      if not SkipNeighbourCheck then
      begin
         if BorderVertexes[v] then
            MaxAngle := FAngleBorder
         else
            MaxAngle := FAngle;
         Value := FaceNeighbors.GetNeighborFromID(v);
         while Value <> -1 do
         begin
            Angle := (_Normals[v].X * _FaceNormals[Value].X) + (_Normals[v].Y * _FaceNormals[Value].Y) + (_Normals[v].Z * _FaceNormals[Value].Z);
            if Angle >= MaxAngle then
            begin
               _VertexTransformation[v] := -1; // Mark for removal. Note that it can be canceled if the colour is different.
               Value := FaceNeighbors.GetNextNeighbor;
            end
            else
            begin
               _VertexTransformation[v] := v; // It won't be removed.
               Value := -1;
            end;
         end;
      end;
   end;
end;

procedure TMeshOptimizationTool.DetectUselessVertexesIgnoringColours(var _Vertices, _Normals, _FaceNormals : TAVector3f; const _Textures: TAVector2f; var _VertexTransformation: aint32);
var
   v, Value,BorderNeighborCount : integer;
   Angle,MaxAngle,Size,x,y,z : single;
   Direction: TVector2f;
   Baricentre : TVector3f;
begin
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      _VertexTransformation[v] := v;
      // Here we check if every neighbor has the same colour and normal is
      // close to the vertex (v) being evaluated.
{
      if BorderVertexes[v] then
         MaxAngle := FAngleBorder
      else
         MaxAngle := FAngle;
}
      if BorderVertexes[v] then
      begin
         BorderNeighborCount := 0;
         Direction.U := 0;
         Direction.V := 0;
         Value := VertexNeighbors.GetNeighborFromID(v);
         while Value <> -1 do
         begin
            if BorderVertexes[Value] then
            begin
               Size := sqrt(((_Textures[v].U - _Textures[Value].U) * (_Textures[v].U - _Textures[Value].U)) + ((_Textures[v].V - _Textures[Value].V) * (_Textures[v].V - _Textures[Value].V)));
               Direction.U := Direction.U + ((_Textures[v].U - _Textures[Value].U) / Size);
               Direction.V := Direction.V + ((_Textures[v].V - _Textures[Value].V) / Size);
               inc(BorderNeighborCount);
            end;
            Value := VertexNeighbors.GetNextNeighbor;
         end;
         //if (BorderNeighborCount = 2) and (Direction.U = 0) and (Direction.V = 0) then
         //begin
         //   _VertexTransformation[v] := -1; // Mark for removal.
         //end
         //else
         //begin
            _VertexTransformation[v] := v; // It won't be removed.
         //end;
      end
      else
      begin
         Value := FaceNeighbors.GetNeighborFromID(v);
         while Value <> -1 do
         begin
            Angle := (_Normals[v].X * _FaceNormals[Value].X) + (_Normals[v].Y * _FaceNormals[Value].Y) + (_Normals[v].Z * _FaceNormals[Value].Z);
            if Angle >= FAngle then
            begin
               _VertexTransformation[v] := -1; // Mark for removal.
               Value := FaceNeighbors.GetNextNeighbor;
            end
            else
            begin
               _VertexTransformation[v] := v; // It won't be removed.
               Value := -1;
            end;
         end;
         // Let's check if the exclusion of this vertex expands or contracts the mesh.
{
         if _VertexTransformation[v] = -1 then
         begin
            Baricentre := SetVector(0,0,0);
            Value := VertexNeighbors.GetNeighborFromID(v);
            // Get the baricentre.
            while Value <> -1 do
            begin
               x := (_Vertices[Value].X - _Vertices[v].X);
               y := (_Vertices[Value].Y - _Vertices[v].Y);
               z := (_Vertices[Value].Z - _Vertices[v].Z);
               Baricentre.X := Baricentre.X + x;
               Baricentre.Y := Baricentre.Y + y;
               Baricentre.Z := Baricentre.Z + z;
               Value := VertexNeighbors.GetNextNeighbor;
            end;
            // Get the direction (normal) of the baricentre.
            Size := Sqrt((Baricentre.X * Baricentre.X) + (Baricentre.Y * Baricentre.Y) + (Baricentre.Z * Baricentre.Z));
            if Size > 0 then
            begin
               Baricentre.X := Baricentre.X / Size;
               Baricentre.Y := Baricentre.Y / Size;
               Baricentre.Z := Baricentre.Z / Size;

               // If the direction of the baricentre and normal of the vertex
               // are less than 90', then it will expand the mesh and we'll have
               // to cancel the elimination of this vertex.
               Angle := (_Normals[v].X * Baricentre.X) + (_Normals[v].Y * Baricentre.Y) + (_Normals[v].Z * Baricentre.Z);
               if Angle > 0 then
               begin
                  _VertexTransformation[v] := v; // It won't be removed.
               end;
            end;
         end;
         }
      end;
   end;
end;

procedure TMeshOptimizationTool.MergeVertexes(var _Vertices, _Normals: TAVector3f; var _VertexTransformation: aint32);
var
   List : CIntegerList;
   v, Value,HitCounter : integer;
   Angle, MaxAngle : single;
   Position : TVector3f;
begin
   List := CIntegerList.Create;
   List.UseSmartMemoryManagement(true);
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      if _VertexTransformation[v] = -1 then
      begin
         // Here we look out for all neighbors that are also in -1 and merge
         // them into one vertex.
         Position.X := _Vertices[v].X;
         Position.Y := _Vertices[v].Y;
         Position.Z := _Vertices[v].Z;
         HitCounter := 1;
         List.Add(v);
         _VertexTransformation[v] := v;
         if BorderVertexes[v] then
         begin
            MaxAngle := FAngleBorder;
         end
         else
            MaxAngle := FAngle;
         while List.GetValue(Value) do
         begin
            Value := VertexNeighbors.GetNeighborFromID(Value);
            while Value <> -1 do
            begin
               if (_VertexTransformation[Value] = -1) and (BorderVertexes[v] = BorderVertexes[Value]) then
               begin
                  Angle := (_Normals[v].X * _Normals[Value].X) + (_Normals[v].Y * _Normals[Value].Y) + (_Normals[v].Z * _Normals[Value].Z);
                  if Angle >= MaxAngle then
                  begin
                     Position.X := Position.X + _Vertices[Value].X;
                     Position.Y := Position.Y + _Vertices[Value].Y;
                     Position.Z := Position.Z + _Vertices[Value].Z;
                     inc(HitCounter);
                     _VertexTransformation[Value] := v;
                     List.Add(Value);
                  end;
               end;
               Value := VertexNeighbors.GetNextNeighbor;
            end;
         end;
         // Now we effectively find the vertex's new position.
         _Vertices[v].X := Position.X / HitCounter;
         _Vertices[v].Y := Position.Y / HitCounter;
         _Vertices[v].Z := Position.Z / HitCounter;
      end;
   end;
   List.Free;
end;
{
procedure TMeshOptimizationTool.MergeVertexesWithTextures(var _Vertices, _Normals: TAVector3f; var _TexCoords : TAVector2f; var _VertexTransformation: aint32);
var
   List : CIntegerList;
   v, Value,HitCounter,Vertex : integer;
   Angle, MaxAngle, Size : single;
   Position,Normal,EstimatedPosition,EstimatedNormal: TVector3f;
   TexCoordinate: TVector2f;
   VerticesBackup,NormalsBackup: TAVector3f;
   TexturesBackup: TAVector2f;
   BorderList,NeighbourList,AddedNeighbours: CIntegerSet;
begin
   List := CIntegerList.Create;
   List.UseSmartMemoryManagement(true);
   SetLength(VerticesBackup,High(_Vertices)+1);
   SetLength(NormalsBackup,High(_Vertices)+1);
   SetLength(TexturesBackup,High(_Vertices)+1);
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      VerticesBackup[v].X := _Vertices[v].X;
      VerticesBackup[v].Y := _Vertices[v].Y;
      VerticesBackup[v].Z := _Vertices[v].Z;
      NormalsBackup[v].X := _Normals[v].X;
      NormalsBackup[v].Y := _Normals[v].Y;
      NormalsBackup[v].Z := _Normals[v].Z;
      TexturesBackup[v].U := _TexCoords[v].U;
      TexturesBackup[v].V := _TexCoords[v].V;
   end;
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      if _VertexTransformation[v] = -1 then
      begin
         // Here we look out for all neighbors that are also in -1 and merge
         // them into one vertex.
         Position.X := VerticesBackup[v].X;
         Position.Y := VerticesBackup[v].Y;
         Position.Z := VerticesBackup[v].Z;
         Normal.X := NormalsBackup[v].X;
         Normal.Y := NormalsBackup[v].Y;
         Normal.Z := NormalsBackup[v].Z;
         TexCoordinate.U := TexturesBackup[v].U;
         TexCoordinate.V := TexturesBackup[v].V;
         HitCounter := 1;
         List.Add(v);
         _VertexTransformation[v] := v;
         if BorderVertexes[v] then
         begin
            MaxAngle := FAngleBorder;
            while List.GetValue(Value) do
            begin
               Value := VertexNeighbors.GetNeighborFromID(Value);
               while Value <> -1 do
               begin
                  if (_VertexTransformation[Value] = -1) and (BorderVertexes[v] = BorderVertexes[Value]) then
                  begin
                     Angle := (NormalsBackup[v].X * NormalsBackup[Value].X) + (NormalsBackup[v].Y * NormalsBackup[Value].Y) + (NormalsBackup[v].Z * NormalsBackup[Value].Z);
                     if Angle >= MaxAngle then
                     begin
                        Position.X := Position.X + VerticesBackup[Value].X;
                        Position.Y := Position.Y + VerticesBackup[Value].Y;
                        Position.Z := Position.Z + VerticesBackup[Value].Z;
                        Normal.X := Normal.X + NormalsBackup[Value].X;
                        Normal.Y := Normal.Y + NormalsBackup[Value].Y;
                        Normal.Z := Normal.Z + NormalsBackup[Value].Z;
                        TexCoordinate.U := TexCoordinate.U + TexturesBackup[Value].U;
                        TexCoordinate.V := TexCoordinate.V + TexturesBackup[Value].V;
                        inc(HitCounter);
                        _VertexTransformation[Value] := v;
                        List.Add(Value);
                     end;
                  end;
                  Value := VertexNeighbors.GetNextNeighbor;
               end;
            end;
         end
         else
         begin
            MaxAngle := FAngle;
            BorderList.Clear;
            NeighbourList.Clear;
            AddedNeighbours.Clear;
            while List.GetValue(Value) do
            begin
               // First we update the list of border vertexes.
               Value := VertexNeighbors.GetNeighborFromID(Value);
               while Value <> -1 do
               begin
                  if BorderVertexes[Value] then
                  begin
                     BorderList.Add(Value);
                  end
                  else
                  begin
                     if AddedNeighbours.Add(Value) then
                     begin
                        NeighbourList.Add(Value);
                     end;
                  end;
                  Value := VertexNeighbors.GetNextNeighbor;
               end;
               // Now we process the non-border vertexes only.
               Value := VertexNeighbors.GetNeighborFromID(Value);
               while Value <> -1 do
               begin
                  if (_VertexTransformation[Value] = -1) and (not BorderVertexes[Value]) then
                  begin
                     Angle := (NormalsBackup[v].X * NormalsBackup[Value].X) + (NormalsBackup[v].Y * NormalsBackup[Value].Y) + (NormalsBackup[v].Z * NormalsBackup[Value].Z);
                     if Angle >= MaxAngle then
                     begin
                        EstimatedPosition.X := (Position.X + VerticesBackup[Value].X) / HitCounter;
                        EstimatedPosition.Y := (Position.Y + VerticesBackup[Value].Y) / HitCounter;
                        EstimatedPosition.Z := (Position.Z + VerticesBackup[Value].Z) / HitCounter;
                        EstimatedNormal.X := (Normal.X + NormalsBackup[Value].X) / HitCounter;
                        EstimatedNormal.Y := (Normal.Y + NormalsBackup[Value].Y) / HitCounter;
                        EstimatedNormal.Z := (Normal.Z + NormalsBackup[Value].Z) / HitCounter;




                        Position.X := Position.X + VerticesBackup[Value].X;
                        Position.Y := Position.Y + VerticesBackup[Value].Y;
                        Position.Z := Position.Z + VerticesBackup[Value].Z;
                        Normal.X := Normal.X + NormalsBackup[Value].X;
                        Normal.Y := Normal.Y + NormalsBackup[Value].Y;
                        Normal.Z := Normal.Z + NormalsBackup[Value].Z;
                        TexCoordinate.U := TexCoordinate.U + TexturesBackup[Value].U;
                        TexCoordinate.V := TexCoordinate.V + TexturesBackup[Value].V;
                        inc(HitCounter);
                        _VertexTransformation[Value] := v;
                        List.Add(Value);
                     end;
                  end;
                  Value := VertexNeighbors.GetNextNeighbor;
               end;



            end;
         end;
         // Now we effectively find the vertex's new position.
         _Vertices[v].X := Position.X / HitCounter;
         _Vertices[v].Y := Position.Y / HitCounter;
         _Vertices[v].Z := Position.Z / HitCounter;
         _Normals[v].X := Normal.X / HitCounter;
         _Normals[v].Y := Normal.Y / HitCounter;
         _Normals[v].Z := Normal.Z / HitCounter;
         _TexCoords[v].U := TexCoordinate.U / HitCounter;
         _TexCoords[v].V := TexCoordinate.V / HitCounter;
      end;
   end;
   SetLength(VerticesBackup,0);
   SetLength(NormalsBackup,0);
   SetLength(TexturesBackup,0);
   List.Free;
end;
}

procedure TMeshOptimizationTool.MergeVertexesWithTextures(var _Vertices, _Normals: TAVector3f; var _TexCoords : TAVector2f; var _VertexTransformation: aint32);
var
   List : CIntegerList;
   v, Value,HitCounter,Vertex : integer;
   Angle, MaxAngle, Size : single;
   Position,Normal,EstimatedPosition,EstimatedNormal: TVector3f;
   TexCoordinate: TVector2f;
   VerticesBackup,NormalsBackup: TAVector3f;
   TexturesBackup: TAVector2f;
   BorderList,NeighbourList,AddedNeighbours: CIntegerSet;
begin
   List := CIntegerList.Create;
   List.UseSmartMemoryManagement(true);
   SetLength(VerticesBackup,High(_Vertices)+1);
   SetLength(NormalsBackup,High(_Vertices)+1);
   SetLength(TexturesBackup,High(_Vertices)+1);
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      VerticesBackup[v].X := _Vertices[v].X;
      VerticesBackup[v].Y := _Vertices[v].Y;
      VerticesBackup[v].Z := _Vertices[v].Z;
      NormalsBackup[v].X := _Normals[v].X;
      NormalsBackup[v].Y := _Normals[v].Y;
      NormalsBackup[v].Z := _Normals[v].Z;
      TexturesBackup[v].U := _TexCoords[v].U;
      TexturesBackup[v].V := _TexCoords[v].V;
   end;
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      if _VertexTransformation[v] = -1 then
      begin
         // Here we look out for all neighbors that are also in -1 and merge
         // them into one vertex.
         Position.X := VerticesBackup[v].X;
         Position.Y := VerticesBackup[v].Y;
         Position.Z := VerticesBackup[v].Z;
         Normal.X := NormalsBackup[v].X;
         Normal.Y := NormalsBackup[v].Y;
         Normal.Z := NormalsBackup[v].Z;
         TexCoordinate.U := TexturesBackup[v].U;
         TexCoordinate.V := TexturesBackup[v].V;
         HitCounter := 1;
         List.Add(v);
         _VertexTransformation[v] := v;
         if BorderVertexes[v] then
         begin
            MaxAngle := FAngleBorder;
         end
         else
         begin
            MaxAngle := FAngle;
            while List.GetValue(Value) do
            begin
               Value := VertexNeighbors.GetNeighborFromID(Value);
               while Value <> -1 do
               begin
                  if (_VertexTransformation[Value] = -1) and (BorderVertexes[v] = BorderVertexes[Value]) then
                  begin
                     Angle := (NormalsBackup[v].X * NormalsBackup[Value].X) + (NormalsBackup[v].Y * NormalsBackup[Value].Y) + (NormalsBackup[v].Z * NormalsBackup[Value].Z);
                     if Angle >= MaxAngle then
                     begin
                        Position.X := Position.X + VerticesBackup[Value].X;
                        Position.Y := Position.Y + VerticesBackup[Value].Y;
                        Position.Z := Position.Z + VerticesBackup[Value].Z;
                        Normal.X := Normal.X + NormalsBackup[Value].X;
                        Normal.Y := Normal.Y + NormalsBackup[Value].Y;
                        Normal.Z := Normal.Z + NormalsBackup[Value].Z;
                        TexCoordinate.U := TexCoordinate.U + TexturesBackup[Value].U;
                        TexCoordinate.V := TexCoordinate.V + TexturesBackup[Value].V;
                        inc(HitCounter);
                        _VertexTransformation[Value] := v;
                        List.Add(Value);
                     end;
                  end;
                  Value := VertexNeighbors.GetNextNeighbor;
               end;
            end;
         end;
         // Now we effectively find the vertex's new position.
         _Vertices[v].X := Position.X / HitCounter;
         _Vertices[v].Y := Position.Y / HitCounter;
         _Vertices[v].Z := Position.Z / HitCounter;
         _Normals[v].X := Normal.X / HitCounter;
         _Normals[v].Y := Normal.Y / HitCounter;
         _Normals[v].Z := Normal.Z / HitCounter;
         _TexCoords[v].U := TexCoordinate.U / HitCounter;
         _TexCoords[v].V := TexCoordinate.V / HitCounter;
      end;
   end;
   SetLength(VerticesBackup,0);
   SetLength(NormalsBackup,0);
   SetLength(TexturesBackup,0);
   List.Free;
end;

// Merge Vertex Utils
function TMeshOptimizationTool.areBorderVertexesHiddenByTriangle(var _Vertices: TAVector3f; _V1,_V2,_Normal: TVector3f; var _NeighbourList,_BorderList: CIntegerSet): boolean;
var
   Matrix: TMatrix;
   VertexUtils : TVertexTransformationUtils;
   V1,V2,V3,P: TVector2f;
   BorderVert,NeighbourVert: integer;
begin
   // Initialize basic stuff.
   Result := false;
   VertexUtils := TVertexTransformationUtils.Create;
   // Here we grab the matrix from the normal vector of the triangle.
   Matrix := VertexUtils.GetTransformMatrixFromVector(_Normal);
   // Now, we get the 2D positions of all vertexes.
   V1 := VertexUtils.GetUVCoordinates(_V1,Matrix);
   V2 := VertexUtils.GetUVCoordinates(_V2,Matrix);
   _BorderList.GoToFirstElement;
   while _BorderList.GetValue(BorderVert) do
   begin
      _NeighbourList.GoToFirstElement;
      while _NeighbourList.GetValue(NeighbourVert) do
      begin
         V3 := VertexUtils.GetUVCoordinates(_Vertices[NeighbourVert],Matrix);
         P := VertexUtils.GetUVCoordinates(_Vertices[BorderVert],Matrix);
         // The border vertex will be hidden by the triangle if P is inside the
         // triangle generated by V1, V2 and V3.
         Result := IsPointInsideTriangle(V1,V2,V3,P);
         if Result then
            exit;
      end;
   end;

   // Free memory
   VertexUtils.Free;
end;

function TMeshOptimizationTool.areBorderVertexesHiddenByTriangle(var _Vertices: TAVector3f; _V1,_V2,_V3,_Normal: TVector3f; var _BorderList: CIntegerSet): boolean;
var
   Matrix: TMatrix;
   VertexUtils : TVertexTransformationUtils;
   V1,V2,V3,P: TVector2f;
   BorderVert,NeighbourVert: integer;
begin
   // Initialize basic stuff.
   Result := false;
   VertexUtils := TVertexTransformationUtils.Create;
   // Here we grab the matrix from the normal vector of the triangle.
   Matrix := VertexUtils.GetTransformMatrixFromVector(_Normal);
   // Now, we get the 2D positions of all vertexes.
   V1 := VertexUtils.GetUVCoordinates(_V1,Matrix);
   V2 := VertexUtils.GetUVCoordinates(_V2,Matrix);
   _BorderList.GoToFirstElement;
   while _BorderList.GetValue(BorderVert) do
   begin
      V3 := VertexUtils.GetUVCoordinates(_V3,Matrix);
      P := VertexUtils.GetUVCoordinates(_Vertices[BorderVert],Matrix);
      // The border vertex will be hidden by the triangle if P is inside the
      // triangle generated by V1, V2 and V3.
      Result := IsPointInsideTriangle(V1,V2,V3,P);
      if Result then
         exit;
   end;

   // Free memory
   VertexUtils.Free;
end;

function TMeshOptimizationTool.Dot2D(const _V1,_V2: TVector2f): single;
begin
   Result := (_V1.U * _V2.U) + (_V1.V * _V2.V);
end;

function TMeshOptimizationTool.IsPointInsideTriangle(const _V1,_V2,_V3,_P : TVector2f): boolean;
var
   V0,V1,V2: TVector2f;
   dot00,dot01,dot02,dot11,dot12,invDenom,u,v: single;
begin
   // Compute vectors
   v0.U := _V3.U - _V1.U;
   v0.V := _V3.V - _V1.V;
   v1.U := _V2.U - _V1.U;
   v1.V := _V2.V - _V1.V;
   v2.U := _P.U - _V1.U;
   v2.V := _P.V - _V1.V;

   // Compute dot products
   dot00 := dot2D(v0, v0);
   dot01 := dot2D(v0, v1);
   dot02 := dot2D(v0, v2);
   dot11 := dot2D(v1, v1);
   dot12 := dot2D(v1, v2);

   // Compute barycentric coordinates
   invDenom := 1 / (dot00 * dot11 - dot01 * dot01);
   u := (dot11 * dot02 - dot01 * dot12) * invDenom;
   v := (dot00 * dot12 - dot01 * dot02) * invDenom;

   // Check if point is in triangle
   Result := ((u > 0) and (v > 0) and (u + v < 1));
end;


// Miscellaneous
function TMeshOptimizationTool.GetBorderVertexList(const _Vertices: TAVector3f; const _Faces : auint32; _VerticesPerFace : integer): abool;
var
   NeighborCount,EdgeCount: auint32;
   Vert,Face,Value,Increment: integer;
begin
   SetLength(NeighborCount,High(_Vertices)+1);
   SetLength(EdgeCount,High(_Vertices)+1);
   SetLength(Result,High(_Vertices)+1);
   // Get the number of neighboors for each vertex.
   for Vert := Low(_Vertices) to High(_Vertices) do
   begin
      NeighborCount[Vert] := 0;
      Value := VertexNeighbors.GetNeighborFromID(Vert);
      while Value <> -1 do
      begin
         inc(NeighborCount[Vert]);
         Value := VertexNeighbors.GetNextNeighbor;
      end;
      EdgeCount[Vert] := 0; // Initialize EdgeCount array.
   end;
   // Scan each face and count the edges of each vertex
   Increment := _VerticesPerFace-1;
   for Face := Low(_Faces) to High(_Faces) do
   begin
      inc(EdgeCount[_Faces[Face]],Increment);
   end;
   // for each vertex, if number of edges <> than 2 * neighbors, then it is border
   for Vert := Low(_Vertices) to High(_Vertices) do
   begin
      Result[Vert] := EdgeCount[Vert] <> (2 * NeighborCount[Vert]);
   end;
   // free memory
   SetLength(NeighborCount,0);
   SetLength(EdgeCount,0);
end;

end.
