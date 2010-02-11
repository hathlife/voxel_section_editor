unit ClassTextureGenerator;

interface

uses BasicDataTypes, GLConstants, Geometry, Voxel_Engine, ClassNeighborDetector,
   ClassIntegerList, Math;

const
   C_SEED_SEPARATOR_SPACE = 1;

type
   TTextureSeed = record
      Position : TVector2f;
      MinBounds, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
   end;
   TSeedTreeItem = record
      left,right : integer;
   end;
   TSeedTree = array of TSeedTreeItem;
   TSeedSet = array of TTextureSeed;
   TTexCompareFunction = function (const _Seed1, _Seed2 : TTextureSeed): real of object;

   CTextureGenerator = class
      private
         // Seeds
         function MakeNewSeed(_ID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _FaceColours, _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace,_MaxVerts: integer): TTextureSeed;
         // Transform Matrix Operations
         function GetSeedTransformMatrix(_Normal: TVector3f): TMatrix;
         function GetTransformMatrix(_AngX, _AngY, _AngZ: single): TMatrix;
         function GetUVCoordinates(const _Normal: TVector3f; _TransformMatrix: TMatrix): TVector2f;
         // Angle Detector
         function GetRotationX(const _Vector: TVector3f): single;
         function GetRotationY(const _Vector: TVector3f): single;
         function GetRotationZ(const _Vector: TVector3f): single;
         // Angle Operators
         function SubtractAngles(_Ang1, _Ang2: single): single;
         function CleanAngle(Angle: single): single;
         function CleanAngleRadians(Angle: single): single;
         function GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
         // Sort
         function CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
         function CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
         procedure QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
         function SeedBinarySearch(const _Value, _min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction; var _current,_previous : integer): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Executes
         function GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; _FaceColours, _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer): TAVector2f;
   end;


implementation

constructor CTextureGenerator.Create;
begin
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

// Transform Matrix Operations
function CTextureGenerator.GetSeedTransformMatrix(_Normal: TVector3f): TMatrix;
const
   C_ANG_X = 0;
   C_ANG_Y = 1.5 * pi;
   C_ANG_Z = C_ANGLE_NONE;
var
   AngX,AngY,AngZ : single;
begin
   // Get the angles from the normal vector.
   AngX := GetRotationX(_Normal);
   AngY := GetRotationY(_Normal);
   AngZ := GetRotationZ(_Normal);
   // Get the angles of the plane aiming at the user minus normal vector
   AngX := SubtractAngles(AngX,C_ANG_X);
   AngY := SubtractAngles(AngY,C_ANG_Y);
//   AngZ := SubtractAngles(AngZ,C_ANG_Z);
   // Now we get the transform matrix
   Result := GetTransformMatrix(AngX,AngY,AngZ);
end;

function CTextureGenerator.GetTransformMatrix(_AngX, _AngY, _AngZ: single): TMatrix;
begin
   Result := IdentityMatrix;
   if _AngX <> C_ANGLE_NONE then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixX(sin(_AngX),cos(_AngX)));
   end;
   if _AngY <> C_ANGLE_NONE then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixY(sin(_AngY),cos(_AngY)));
   end;
   if _AngZ <> C_ANGLE_NONE then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixZ(sin(_AngZ),cos(_AngZ)));
   end;
end;

function CTextureGenerator.GetUVCoordinates(const _Normal: TVector3f; _TransformMatrix: TMatrix): TVector2f;
var
   TempVector: TVector3f;
begin
   TempVector := VectorTransform(_Normal,_TransformMatrix);
   Result.U := TempVector.X;
   Result.V := TempVector.Y;
end;


// Angle Detector
function CTextureGenerator.GetRotationX(const _Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.Y * _Vector.Y) + (_Vector.Z * _Vector.Z));
   if Distance > 0 then
   begin
      Result := CleanAngleRadians(arccos(_Vector.Z / Distance));
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

function CTextureGenerator.GetRotationY(const _Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.X * _Vector.X) + (_Vector.Z * _Vector.Z));
   if Distance > 0 then
   begin
      Result := CleanAngleRadians(arccos(_Vector.Z / Distance));
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

function CTextureGenerator.GetRotationZ(const _Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.Y * _Vector.Y) + (_Vector.X * _Vector.X));
   if Distance > 0 then
   begin
      Result := CleanAngleRadians(arccos(_Vector.Y / Distance));
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

// Angle Operators

// _Ang2 - _Ang1
function CTextureGenerator.SubtractAngles(_Ang1, _Ang2: single): single;
begin
   if _Ang1 = C_ANGLE_NONE then
   begin
      Result := _Ang2;
   end
   else if _Ang2 = C_ANGLE_NONE then
   begin
      Result := _Ang1;
   end
   else
   begin
      Result := CleanAngle(_Ang2 - _Ang1);
   end;
end;

function CTextureGenerator.CleanAngle(Angle: single): single;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + 360;
   if Result > 360 then
      Result := Result - 360;
end;

function CTextureGenerator.CleanAngleRadians(Angle: single): single;
const
   C_2PI = 2 * Pi;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + Pi;
   if Result > C_2Pi then
      Result := Result - C_2Pi;
end;

function CTextureGenerator.GetVectorAngle(_Vec1, _Vec2: TVector3f): single;
var
   V1, V2: TAffineVector;
begin
   V1[0] := _Vec1.X;
   V1[1] := _Vec1.Y;
   V1[2] := _Vec1.Z;
   V2[0] := _Vec2.X;
   V2[1] := _Vec2.Y;
   V2[2] := _Vec2.Z;
   Result := VectorAngle(V1,V2); // check Geometry.pas
end;

// Executes
function CTextureGenerator.GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; _FaceColours,_VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer): TAVector2f;
var
   i, MaxVerts: integer;
   FaceSeed,VertsSeed : aint32;
   UOrder,VOrder : auint32;
   FaceNeighbors: TNeighborDetector;
   UMerge,VMerge,PushValue: real;
   Seeds: TSeedSet;
   SeedTree : TSeedTree;
begin
   // Get the neighbours of each face.
   FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE);
   FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);
   // Setup FaceSeed.
   SetLength(FaceSeed,(High(_Faces)+1) div _VerticesPerFace);
   for i := Low(FaceSeed) to High(FaceSeed) do
   begin
      FaceSeed[i] := -1;
   end;
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
      if FaceSeed[i] = -1 then
      begin
         // Make new seed.
         SetLength(Seeds,High(Seeds)+2);
         Seeds[High(Seeds)] := MakeNewSeed(High(Seeds),i,_Vertices,_FaceNormals,_VertsNormals,_FaceColours,_VertsColours,_Faces,Result,FaceSeed,VertsSeed,FaceNeighbors,_VerticesPerFace,MaxVerts);
      end;
   end;

   // Re-align vertexes and seed bounds to (0,0)
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
   SetLength(UOrder,High(Seeds)+1);
   SetLength(VOrder,High(Seeds)+1);
   for i := Low(UOrder) to High(UOrder) do
   begin
      UOrder[i] := i;
      VOrder[i] := i;
   end;
   QuickSortSeeds(Low(UOrder),High(UOrder),UOrder,Seeds,CompareU);
   QuickSortSeeds(Low(VOrder),High(VOrder),VOrder,Seeds,CompareV);

   // Then, we start a SeedTree, which we'll use to ajust the bounds from seeds
   // inside bigger seeds.
   SetLength(SeedTree,High(Seeds)+1);
   for i := Low(SeedTree) to High(SeedTree) do
   begin
      SeedTree[i].left := -1;
      SeedTree[i].right := -1;
   end;

   // We'll now start the main loop. We merge the smaller seeds into bigger seeds until we only have on seed left.
   while High(VOrder) > 0 do
   begin
      // Select the last two seeds from UOrder and VOrder and check which merge
      // uses less space.
      UMerge := ( (Seeds[UOrder[High(UOrder)]].MaxBounds.U - Seeds[UOrder[High(UOrder)]].MinBounds.U) + C_SEED_SEPARATOR_SPACE + (Seeds[UOrder[High(UOrder)-1]].MaxBounds.U - Seeds[UOrder[High(UOrder)-1]].MinBounds.U) ) * max((Seeds[UOrder[High(UOrder)]].MaxBounds.V - Seeds[UOrder[High(UOrder)]].MinBounds.V),(Seeds[UOrder[High(UOrder)-1]].MaxBounds.V - Seeds[UOrder[High(UOrder)-1]].MinBounds.V));
      VMerge := ( (Seeds[VOrder[High(VOrder)]].MaxBounds.V - Seeds[VOrder[High(VOrder)]].MinBounds.V) + C_SEED_SEPARATOR_SPACE + (Seeds[VOrder[High(VOrder)-1]].MaxBounds.V - Seeds[VOrder[High(VOrder)-1]].MinBounds.V) ) * max((Seeds[VOrder[High(VOrder)]].MaxBounds.U - Seeds[VOrder[High(VOrder)]].MinBounds.U),(Seeds[VOrder[High(VOrder)-1]].MaxBounds.U - Seeds[VOrder[High(VOrder)-1]].MinBounds.U));
      SetLength(Seeds,High(Seeds)+2);
      Seeds[High(Seeds)].MinBounds.U := 0;
      Seeds[High(Seeds)].MinBounds.V := 0;
      SetLength(SeedTree,High(Seeds)+1);
      if VMerge < UMerge then
      begin
         // So, we'll merge the last two elements of VOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         Seeds[High(Seeds)].MaxBounds.U := max((Seeds[VOrder[High(VOrder)]].MaxBounds.U - Seeds[VOrder[High(VOrder)]].MinBounds.U),(Seeds[VOrder[High(VOrder)-1]].MaxBounds.U - Seeds[VOrder[High(VOrder)-1]].MinBounds.U));
         Seeds[High(Seeds)].MaxBounds.V := (Seeds[VOrder[High(VOrder)]].MaxBounds.V - Seeds[VOrder[High(VOrder)]].MinBounds.V) + C_SEED_SEPARATOR_SPACE + (Seeds[VOrder[High(VOrder)-1]].MaxBounds.V - Seeds[VOrder[High(VOrder)-1]].MinBounds.V);
         // Insert the last two elements from VOrder at the new seed tree element.
         SeedTree[High(SeedTree)].left := VOrder[High(VOrder)-1];
         SeedTree[High(SeedTree)].right := VOrder[High(VOrder)];
         // Now we translate the bounds of the element in the 'right' down, where it
         // belongs, and do it recursively.
         i := VOrder[High(VOrder)];
         PushValue := (Seeds[VOrder[High(VOrder)]].MaxBounds.V - Seeds[VOrder[High(VOrder)]].MinBounds.V) + C_SEED_SEPARATOR_SPACE;
         while i <> -1 do
         begin
            Seeds[i].MinBounds.V := Seeds[i].MinBounds.V + PushValue;
            Seeds[i].MaxBounds.V := Seeds[i].MaxBounds.V + PushValue;
            i := SeedTree[i].right;
         end;
         // Now we remove the last two elements from VOrder and add the new seed.
         SetLength(VOrder,High(VOrder));


         
      end
      else  // UMerge <= VMerge
      begin
         // So, we'll merge the last two elements of UOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         Seeds[High(Seeds)].MaxBounds.U := (Seeds[UOrder[High(UOrder)]].MaxBounds.U - Seeds[UOrder[High(UOrder)]].MinBounds.U) + C_SEED_SEPARATOR_SPACE + (Seeds[UOrder[High(UOrder)-1]].MaxBounds.U - Seeds[UOrder[High(UOrder)-1]].MinBounds.U);
         Seeds[High(Seeds)].MaxBounds.V := max((Seeds[UOrder[High(UOrder)]].MaxBounds.V - Seeds[UOrder[High(UOrder)]].MinBounds.V),(Seeds[UOrder[High(UOrder)-1]].MaxBounds.V - Seeds[UOrder[High(UOrder)-1]].MinBounds.V));
         // Insert the last two elements from UOrder at the new seed tree element.
         SeedTree[High(SeedTree)].left := VOrder[High(UOrder)-1];
         SeedTree[High(SeedTree)].right := VOrder[High(UOrder)];
         // Now we translate the bounds of the element in the 'right' to the right, 
         // where it belongs, and do it recursively.
         i := VOrder[High(UOrder)];
         PushValue := (Seeds[UOrder[High(UOrder)]].MaxBounds.U - Seeds[UOrder[High(UOrder)]].MinBounds.U) + C_SEED_SEPARATOR_SPACE;
         while i <> -1 do
         begin
            Seeds[i].MinBounds.U := Seeds[i].MinBounds.U + PushValue;
            Seeds[i].MaxBounds.U := Seeds[i].MaxBounds.U + PushValue;
            i := SeedTree[i].right;
         end;


      end;
   end;

   // Clean up memory.
   SetLength(FaceSeed,0);
   SetLength(VertsSeed,0);
   FaceNeighbors.Free;
end;

function CTextureGenerator.MakeNewSeed(_ID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _FaceColours, _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace,_MaxVerts: integer): TTextureSeed;
const
   C_MIN_ANGLE = Pi / 4; // 45'
var
   v,f,Value,vertex : integer;
   List : CIntegerList;
   VertsLocation : aint32;
begin
   // Setup neighbor detection list
   List := CIntegerList.Create;
   List.UseSmartMemoryManagement(true);
   // Setup VertsLocation
   SetLength(VertsLocation,_MaxVerts);
   for v := Low(VertsLocation) to High(VertsLocation) do
   begin
      VertsLocation[v] := -1;
   end;

   // Add starting face
   List.Add(_StartingFace);
   Result.TransformMatrix := GetSeedTransformMatrix(_FaceNormals[_StartingFace]);
   Result.MinBounds.U := 999999;
   Result.MaxBounds.U := -999999;
   Result.MinBounds.V := 999999;
   Result.MaxBounds.V := -999999;

   // Neighbour Face Scanning starts here.
   while List.GetValue(Value) do
   begin
      // Add face here
      // Add the face and its vertexes
      _FaceSeeds[Value] := _ID;
      for v := 0 to _VerticesPerFace - 1 do
      begin
         vertex := _Faces[(f * _VerticesPerFace)+v];
         if _VertsSeed[vertex] <> -1 then
         begin
            if VertsLocation[vertex] = -1 then
            begin
               // this vertex was used by a previous seed, therefore, we'll clone it
               SetLength(_Vertices,High(_Vertices)+2);
               SetLength(_VertsSeed,High(_Vertices)+1);
               _VertsSeed[High(_VertsSeed)] := _ID;
               VertsLocation[vertex] := High(_Vertices);
               _Faces[(f * _VerticesPerFace)+v] := VertsLocation[vertex];
               _Vertices[High(_Vertices)].X := _Vertices[vertex].X;
               _Vertices[High(_Vertices)].Y := _Vertices[vertex].Y;
               _Vertices[High(_Vertices)].Z := _Vertices[vertex].Z;
               _VertsNormals[High(_Vertices)].X := _VertsNormals[vertex].X;
               _VertsNormals[High(_Vertices)].Y := _VertsNormals[vertex].Y;
               _VertsNormals[High(_Vertices)].Z := _VertsNormals[vertex].Z;
               _VertsColours[High(_Vertices)].X := _VertsColours[vertex].X;
               _VertsColours[High(_Vertices)].Y := _VertsColours[vertex].Y;
               _VertsColours[High(_Vertices)].Z := _VertsColours[vertex].Z;
               _VertsColours[High(_Vertices)].W := _VertsColours[vertex].W;
               // Get temporarily texture coordinates.
               _TextCoords[High(_Vertices)] := GetUVCoordinates(_Vertices[vertex],Result.TransformMatrix);
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
               _Faces[(f * _VerticesPerFace)+v] := VertsLocation[vertex];
            end;
         end
         else
         begin
            // This seed is the first seed to use this vertex.
            _VertsSeed[vertex] := _ID;
            VertsLocation[vertex] := vertex;
            // Get temporarily texture coordinates.
            _TextCoords[vertex] := GetUVCoordinates(_Vertices[vertex],Result.TransformMatrix);
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
         if _FaceSeeds[f] = -1 then
         begin
            // check if angle is 45'
            if GetVectorAngle(_FaceNormals[_StartingFace],_FaceNormals[f]) <= C_MIN_ANGLE then
            begin
               List.Add(f);
            end;
         end;
         f := _FaceNeighbors.GetNextNeighbor;
      end;
   end;
   List.Free;
end;

// Sort
function CTextureGenerator.CompareU(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed2.MaxBounds.U - _Seed2.MinBounds.U) - (_Seed1.MaxBounds.U - _Seed1.MinBounds.U);
end;

function CTextureGenerator.CompareV(const _Seed1, _Seed2 : TTextureSeed): real;
begin
   Result := (_Seed2.MaxBounds.V - _Seed2.MinBounds.V) - (_Seed1.MaxBounds.V - _Seed1.MinBounds.V);
end;

procedure CTextureGenerator.QuickSortSeeds(_min, _max : integer; var _OrderedList: auint32; const _Seeds : TSeedSet; _CompareFunction: TTexCompareFunction);
var
   Lo, Hi, Mid, T: Integer;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while _CompareFunction(_Seeds[_OrderedList[Lo]],_Seeds[_OrderedList[Mid]]) < 0 do Inc(Lo);
         while _CompareFunction(_Seeds[_OrderedList[Hi]],_Seeds[_OrderedList[Mid]]) > 0 do Dec(Hi);
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

end.
