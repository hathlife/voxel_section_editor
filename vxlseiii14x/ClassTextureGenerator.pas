unit ClassTextureGenerator;

interface

uses GLConstants, Geometry, BasicDataTypes, Voxel_Engine, ClassNeighborDetector,
   ClassIntegerList, Math, Windows, Graphics, BasicFunctions, SysUtils, Dialogs;

const
   C_SEED_SEPARATOR_SPACE = 0;

type
   TTextureSeed = record
      MinBounds, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
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
         // Seeds
         function MakeNewSeed(_ID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace,_MaxVerts: integer): TTextureSeed;
         // Transform Matrix Operations
         function GetSeedTransformMatrix(_Normal: TVector3f): TMatrix;
         function GetTransformMatrix(_AngX, _AngY, _AngZ: single): TMatrix;
         function GetUVCoordinates(const _Position: TVector3f; _TransformMatrix: TMatrix): TVector2f;
         // Angle Detector
         function GetRotationX(const _Vector: TVector3f): single;
         function GetRotationY(const _Vector: TVector3f): single;
         function GetRotationZ(const _Vector: TVector3f): single;
         // Angle Operators
         function SubtractAngles(_Ang1, _Ang2: single): single;
         function CleanAngle(Angle: single): single;
         function CleanAngleRadians(Angle: single): single;
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
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer);
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer);
         function GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
         function GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Executes
         function GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer): TAVector2f;
         // Generate Textures
         function GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
         function GenerateNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
         function GenerateNormalWithHeightMapTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
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
   C_ANG_Y = 0;
   C_ANG_Z = C_ANGLE_NONE;
var
   AngX,AngY,AngZ : single;
begin
   // Get the angles from the normal vector.
   AngX := GetRotationX(_Normal);
   AngY := GetRotationY(_Normal);
   AngZ := GetRotationZ(_Normal);
   // Get the angles of the plane aiming at the user minus normal vector
//   AngX := SubtractAngles(AngX,C_ANG_X);
//   AngY := SubtractAngles(AngY,C_ANG_Y);
//   AngZ := SubtractAngles(AngZ,C_ANG_Z);
   AngX := CleanAngleRadians(-AngX);
   AngY := CleanAngleRadians(-AngY);
   AngZ := CleanAngleRadians(-AngZ);
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

function CTextureGenerator.GetUVCoordinates(const _Position: TVector3f; _TransformMatrix: TMatrix): TVector2f;
var
   TempVector: TVector3f;
begin
   TempVector := VectorTransform(_Position,_TransformMatrix);
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
      Result := CleanAngleRadians(arccos(_Vector.Y / Distance));
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
      Result := CleanAngleRadians(arccos(_Vector.X / Distance));
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
      Result := CleanAngleRadians(_Ang2 - _Ang1);
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
   Result := sqrt((_Vec1.X * _Vec2.X) + (_Vec1.Y * _Vec2.Y) + (_Vec1.Z * _Vec2.Z));
end;

// Executes
function CTextureGenerator.GetTextureCoordinates(var _Vertices : TAVector3f; var _FaceNormals,_VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; _VerticesPerFace: integer): TAVector2f;
   function isVLower(_UMerge, _VMerge, _UMax, _VMax: single): boolean;
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
var
   i, x, MaxVerts, Current, Previous: integer;
   FaceSeed,VertsSeed : aint32;
   FacePriority: AFloat;
   FaceOrder,UOrder,VOrder : auint32;
   FaceNeighbors: TNeighborDetector;
   UMerge,VMerge,UMax,VMax,PushValue: real;
   Seeds: TSeedSet;
   SeedTree : TSeedTree;
   List : CIntegerList;
begin
   // Get the neighbours of each face.
   FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE);
   FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,High(_Vertices)+1);
   // Setup FaceSeed, FaceOrder and FacePriority.
   SetLength(FaceSeed,(High(_Faces)+1) div _VerticesPerFace);
   SetLength(FaceOrder,High(FaceSeed)+1);
   SetLength(FacePriority,High(FaceSeed)+1);
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
         Seeds[High(Seeds)] := MakeNewSeed(High(Seeds),FaceOrder[i],_Vertices,_FaceNormals,_VertsNormals,_VertsColours,_Faces,Result,FaceSeed,VertsSeed,FaceNeighbors,_VerticesPerFace,MaxVerts);
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
      SeedTree[i].Left := -1;
      SeedTree[i].Right := -1;
   end;

   // Setup seed tree detection list
   List := CIntegerList.Create;
   List.UseSmartMemoryManagement(true);

   // We'll now start the main loop. We merge the smaller seeds into bigger seeds until we only have on seed left.
   while High(VOrder) > 0 do
   begin
      // Select the last two seeds from UOrder and VOrder and check which merge
      // uses less space.
      UMerge := ( (Seeds[UOrder[High(UOrder)]].MaxBounds.U - Seeds[UOrder[High(UOrder)]].MinBounds.U) + C_SEED_SEPARATOR_SPACE + (Seeds[UOrder[High(UOrder)-1]].MaxBounds.U - Seeds[UOrder[High(UOrder)-1]].MinBounds.U) ) * max((Seeds[UOrder[High(UOrder)]].MaxBounds.V - Seeds[UOrder[High(UOrder)]].MinBounds.V),(Seeds[UOrder[High(UOrder)-1]].MaxBounds.V - Seeds[UOrder[High(UOrder)-1]].MinBounds.V));
      VMerge := ( (Seeds[VOrder[High(VOrder)]].MaxBounds.V - Seeds[VOrder[High(VOrder)]].MinBounds.V) + C_SEED_SEPARATOR_SPACE + (Seeds[VOrder[High(VOrder)-1]].MaxBounds.V - Seeds[VOrder[High(VOrder)-1]].MinBounds.V) ) * max((Seeds[VOrder[High(VOrder)]].MaxBounds.U - Seeds[VOrder[High(VOrder)]].MinBounds.U),(Seeds[VOrder[High(VOrder)-1]].MaxBounds.U - Seeds[VOrder[High(VOrder)-1]].MinBounds.U));
      UMax := max(( (Seeds[UOrder[High(UOrder)]].MaxBounds.U - Seeds[UOrder[High(UOrder)]].MinBounds.U) + C_SEED_SEPARATOR_SPACE + (Seeds[UOrder[High(UOrder)-1]].MaxBounds.U - Seeds[UOrder[High(UOrder)-1]].MinBounds.U) ),max((Seeds[UOrder[High(UOrder)]].MaxBounds.V - Seeds[UOrder[High(UOrder)]].MinBounds.V),(Seeds[UOrder[High(UOrder)-1]].MaxBounds.V - Seeds[UOrder[High(UOrder)-1]].MinBounds.V)));
      VMax := max(( (Seeds[VOrder[High(VOrder)]].MaxBounds.V - Seeds[VOrder[High(VOrder)]].MinBounds.V) + C_SEED_SEPARATOR_SPACE + (Seeds[VOrder[High(VOrder)-1]].MaxBounds.V - Seeds[VOrder[High(VOrder)-1]].MinBounds.V) ),max((Seeds[VOrder[High(VOrder)]].MaxBounds.U - Seeds[VOrder[High(VOrder)]].MinBounds.U),(Seeds[VOrder[High(VOrder)-1]].MaxBounds.U - Seeds[VOrder[High(VOrder)-1]].MinBounds.U)));
      SetLength(Seeds,High(Seeds)+2);
      Seeds[High(Seeds)].MinBounds.U := 0;
      Seeds[High(Seeds)].MinBounds.V := 0;
      SetLength(SeedTree,High(Seeds)+1);
      if IsVLower(UMerge,VMerge,UMax,VMax) then
      begin
         // So, we'll merge the last two elements of VOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         Seeds[High(Seeds)].MaxBounds.U := max((Seeds[VOrder[High(VOrder)]].MaxBounds.U - Seeds[VOrder[High(VOrder)]].MinBounds.U),(Seeds[VOrder[High(VOrder)-1]].MaxBounds.U - Seeds[VOrder[High(VOrder)-1]].MinBounds.U));
         Seeds[High(Seeds)].MaxBounds.V := (Seeds[VOrder[High(VOrder)]].MaxBounds.V - Seeds[VOrder[High(VOrder)]].MinBounds.V) + C_SEED_SEPARATOR_SPACE + (Seeds[VOrder[High(VOrder)-1]].MaxBounds.V - Seeds[VOrder[High(VOrder)-1]].MinBounds.V);
         // Insert the last two elements from VOrder at the new seed tree element.
         SeedTree[High(SeedTree)].Left := VOrder[High(VOrder)-1];
         SeedTree[High(SeedTree)].Right := VOrder[High(VOrder)];
         // Now we translate the bounds of the element in the 'right' down, where it
         // belongs, and do it recursively.
         PushValue := (Seeds[VOrder[High(VOrder)-1]].MaxBounds.V - Seeds[VOrder[High(VOrder)-1]].MinBounds.V) + C_SEED_SEPARATOR_SPACE;
         List.Add(SeedTree[High(SeedTree)].Right);
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

         while i <= High(UOrder) do
         begin
            if (UOrder[i] = VOrder[High(VOrder)]) or (UOrder[i] = VOrder[High(VOrder)-1]) then
               inc(x)
            else
               UOrder[i - x] := UOrder[i];
            inc(i);
         end;
         SetLength(UOrder,High(UOrder));
         Current := High(UOrder) div 2;
         SeedBinarySearch(High(SeedTree),0,High(UOrder)-1,UOrder,Seeds,CompareU,Current,Previous);
         i := High(UOrder);
         while i > (Previous+1) do
         begin
            UOrder[i] := UOrder[i-1];
            dec(i);
         end;
         UOrder[Previous+1] := High(SeedTree);

         // Now we remove the last two elements from VOrder and add the new seed.
         SetLength(VOrder,High(VOrder));
         Current := High(VOrder) div 2;
         SeedBinarySearch(High(SeedTree),0,High(VOrder)-1,VOrder,Seeds,CompareV,Current,Previous);
         i := High(VOrder);
         while i > (Previous+1) do
         begin
            VOrder[i] := VOrder[i-1];
            dec(i);
         end;
         VOrder[Previous+1] := High(SeedTree);

      end
      else  // UMerge <= VMerge
      begin
         // So, we'll merge the last two elements of UOrder into a new sector.
        // -----------------------
         // Finish the creation of the new seed.
         Seeds[High(Seeds)].MaxBounds.U := (Seeds[UOrder[High(UOrder)]].MaxBounds.U - Seeds[UOrder[High(UOrder)]].MinBounds.U) + C_SEED_SEPARATOR_SPACE + (Seeds[UOrder[High(UOrder)-1]].MaxBounds.U - Seeds[UOrder[High(UOrder)-1]].MinBounds.U);
         Seeds[High(Seeds)].MaxBounds.V := max((Seeds[UOrder[High(UOrder)]].MaxBounds.V - Seeds[UOrder[High(UOrder)]].MinBounds.V),(Seeds[UOrder[High(UOrder)-1]].MaxBounds.V - Seeds[UOrder[High(UOrder)-1]].MinBounds.V));
         // Insert the last two elements from UOrder at the new seed tree element.
         SeedTree[High(SeedTree)].Left := UOrder[High(UOrder)-1];
         SeedTree[High(SeedTree)].Right := UOrder[High(UOrder)];
         // Now we translate the bounds of the element in the 'right' to the right,
         // where it belongs, and do it recursively.
         PushValue := (Seeds[UOrder[High(UOrder)-1]].MaxBounds.U - Seeds[UOrder[High(UOrder)-1]].MinBounds.U) + C_SEED_SEPARATOR_SPACE;
         List.Add(SeedTree[High(SeedTree)].Right);
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
         while i <= High(VOrder) do
         begin
            if (VOrder[i] = UOrder[High(UOrder)]) or (VOrder[i] = UOrder[High(UOrder)-1]) then
               inc(x)
            else
               VOrder[i - x] := VOrder[i];
            inc(i);
         end;
         SetLength(VOrder,High(VOrder));
         Current := High(VOrder) div 2;
         SeedBinarySearch(High(SeedTree),0,High(VOrder)-1,VOrder,Seeds,CompareV,Current,Previous);
         i := High(VOrder);
         while i > (Previous+1) do
         begin
            VOrder[i] := VOrder[i-1];
            dec(i);
         end;
         VOrder[Previous+1] := High(SeedTree);

         // Now we remove the last two elements from UOrder and add the new seed.
         SetLength(UOrder,High(UOrder));
         Current := High(UOrder) div 2;
         SeedBinarySearch(High(SeedTree),0,High(UOrder)-1,UOrder,Seeds,CompareU,Current,Previous);
         i := High(UOrder);
         while i > (Previous+1) do
         begin
            UOrder[i] := UOrder[i-1];
            dec(i);
         end;
         UOrder[Previous+1] := High(SeedTree);
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
   List.Free;
   FaceNeighbors.Free;
end;

function CTextureGenerator.MakeNewSeed(_ID,_StartingFace: integer; var _Vertices : TAVector3f; var _FaceNormals, _VertsNormals : TAVector3f; var _VertsColours : TAVector4f; var _Faces : auint32; var _TextCoords: TAVector2f; var _FaceSeeds,_VertsSeed: aint32; const _FaceNeighbors: TNeighborDetector; _VerticesPerFace,_MaxVerts: integer): TTextureSeed;
const
   C_MIN_ANGLE = 0.707; // approximately cos 45'
var
   v,f,Value,vertex : integer;
   List : CIntegerList;
   VertsLocation : aint32;
   CheckFace : abool;
   Angle: single;
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
   // Avoid unlimmited loop
   SetLength(CheckFace,High(_Faces)+1);
   for f := Low(CheckFace) to High(CheckFace) do
      CheckFace[f] := false;

   // Add starting face
   List.Add(_StartingFace);
   CheckFace[_StartingFace] := true;
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
         vertex := _Faces[(Value * _VerticesPerFace)+v];
         if _VertsSeed[vertex] <> -1 then
         begin
            if VertsLocation[vertex] = -1 then
            begin
               // this vertex was used by a previous seed, therefore, we'll clone it
               SetLength(_Vertices,High(_Vertices)+2);
               SetLength(_VertsSeed,High(_Vertices)+1);
               _VertsSeed[High(_VertsSeed)] := _ID;
               VertsLocation[vertex] := High(_Vertices);
               _Faces[(Value * _VerticesPerFace)+v] := VertsLocation[vertex];
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
               _Faces[(Value * _VerticesPerFace)+v] := VertsLocation[vertex];
            end;
         end
         else
         begin
            // This seed is the first seed to use this vertex.
            _VertsSeed[vertex] := _ID;
            VertsLocation[vertex] := vertex;
            // Get temporary texture coordinates.
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
         if (_FaceSeeds[f] = -1) and (not CheckFace[f]) then
         begin
            // check if angle is 45'
            Angle := GetVectorAngle(_FaceNormals[_StartingFace],_FaceNormals[f]);
            if Angle >= C_MIN_ANGLE then
            begin
               List.Add(f);
            end
            else
            begin
//               ShowMessage('Starting Face: (' + FloatToStr(_FaceNormals[_StartingFace].X) + ', ' + FloatToStr(_FaceNormals[_StartingFace].Y) + ', ' + FloatToStr(_FaceNormals[_StartingFace].Z) + ') and Current Face is (' + FloatToStr(_FaceNormals[f].X) + ', ' + FloatToStr(_FaceNormals[f].Y) + ', ' + FloatToStr(_FaceNormals[f].Z) + ') and the angle is ' + FloatToStr(Angle));
            end;
         end;
         CheckFace[f] := true;
         f := _FaceNeighbors.GetNextNeighbor;
      end;
   end;
   List.Free;
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
begin
   Size := High(_Buffer)+1;
   PosX := Trunc(_Point.U);
   PosY := Trunc(_Point.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, ((PosX+1)-_Point.U) * ((PosY+1)-_Point.V));
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, (_Point.U - PosX) * ((PosY+1)-_Point.V));
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, ((PosX+1)-_Point.U) * (_Point.V - PosY));
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, (_Point.U - PosX) * (_Point.V - PosY));
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
begin
   Size := High(_Buffer)+1;
   PosX := Trunc(_Point.U);
   PosY := Trunc(_Point.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, ((PosX+1)-_Point.U) * ((PosY+1)-_Point.V));
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, (_Point.U - PosX) * ((PosY+1)-_Point.V));
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, ((PosX+1)-_Point.U) * (_Point.V - PosY));
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, (_Point.U - PosX) * (_Point.V - PosY));
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
   dx1, dx2, dx3, dr, dr1, dr2, dr3, dg, dg1, dg2, dg3, db, db1, db2, db3, da, da1, da2, da3 : real;
   SP, EP, PP : TVector2f;
   SC, EC, PC : TVector4f;
begin
   if (_P2.V - _P1.V > 0) then
   begin
		dx1 := (_P2.U - _P1.U) / (_P2.V - _P1.V);
		dr1 := (_C2.X - _C1.X) / (_P2.V - _P1.V);
		dg1 := (_C2.Y - _C1.Y) / (_P2.V - _P1.V);
		db1 := (_C2.Z - _C1.Z) / (_P2.V - _P1.V);
		da1 := (_C2.W - _C1.W) / (_P2.V - _P1.V);
	end
   else
   begin
		dx1 := (_P2.U - _P1.U);
      dr1 := (_C2.X - _C1.X);
      dg1 := (_C2.Y - _C1.Y);
      db1 := (_C2.Z - _C1.Z);
      da1 := (_C2.W - _C1.W);
   end;

	if (_P3.V - _P1.V > 0) then
   begin
		dx2 := (_P3.U - _P1.U) / (_P3.V - _P1.V);
		dr2 := (_C3.X - _C1.X) / (_P3.V - _P1.V);
		dg2 := (_C3.Y - _C1.Y) / (_P3.V - _P1.V);
		db2 := (_C3.Z - _C1.Z) / (_P3.V - _P1.V);
		da2 := (_C3.W - _C1.W) / (_P3.V - _P1.V);
	end
   else
   begin
		dx2 := (_P3.U - _P1.U);
      dr2 := (_C3.X - _C1.X);
      dg2 := (_C3.Y - _C1.Y);
      db2 := (_C3.Z - _C1.Z);
      da2 := (_C3.W - _C1.W);
   end;

	if (_P3.V - _P2.V > 0) then
   begin
		dx3 :=(_P3.U - _P2.U) / (_P3.V - _P2.V);
		dr3 :=(_C3.X - _C2.X) / (_P3.V - _P2.V);
		dg3 :=(_C3.Y - _C2.Y) / (_P3.V - _P2.V);
		db3 :=(_C3.Z - _C2.Z) / (_P3.V - _P2.V);
		da3 :=(_C3.W - _C2.W) / (_P3.V - _P2.V);
	end
   else
   begin
		dx3 := (_P3.U - _P2.U);
      dr3 := (_C3.X - _C2.X);
      dg3 := (_C3.Y - _C2.Y);
      db3 := (_C3.Z - _C2.Z);
      da3 := (_C3.W - _C2.W);
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
				da := (EC.W - SC.W) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
            da := 0;
         end;
         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + db;
				PC.Z := PC.Z + dg;
				PC.W := PC.W + da;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + db2;
         SC.Z := SC.Z + dg2;
         SC.W := SC.W + da2;
         EP.U := EP.U + dx1;
         EC.X := EC.X + dr1;
         EC.Y := EC.Y + db1;
         EC.Z := EC.Z + dg1;
         EC.W := EC.W + da1;
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
				da := (EC.W - SC.W) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
            da := 0;
         end;
         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + db;
				PC.Z := PC.Z + dg;
				PC.W := PC.W + da;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + db2;
         SC.Z := SC.Z + dg2;
         SC.W := SC.W + da2;
         EP.U := EP.U + dx3;
         EC.X := EC.X + dr3;
         EC.Y := EC.Y + db3;
         EC.Z := EC.Z + dg3;
         EC.W := EC.W + da3;
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
				da := (EC.W - SC.W) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
            da := 0;
         end;

         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + db;
				PC.Z := PC.Z + dg;
				PC.W := PC.W + da;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx1;
         SC.X := SC.X + dr1;
         SC.Y := SC.Y + db1;
         SC.Z := SC.Z + dg1;
         SC.W := SC.W + da1;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + db2;
         EC.Z := EC.Z + dg2;
         EC.W := EC.W + da2;
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
				da := (EC.W - SC.W) / (EP.U - SP.U);
			end
         else
         begin
				dr := 0;
            dg := 0;
            db := 0;
            da := 0;
         end;

         AssignPointColour(PP,PC,SP,SC);
			while (PP.U < EP.U) do
         begin
				PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
				PC.X := PC.X + dr;
				PC.Y := PC.Y + db;
				PC.Z := PC.Z + dg;
				PC.W := PC.W + da;
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx3;
         SC.X := SC.X + dr3;
         SC.Y := SC.Y + db3;
         SC.Z := SC.Z + dg3;
         SC.W := SC.W + da3;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + db2;
         EC.Z := EC.Z + dg2;
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
		dx1 := 0;
      dr1 := 0;
      dg1 := 0;
      db1 := 0;
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
		dx2 := 0;
      dr2 := 0;
      dg2 := 0;
      db2 := 0;
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
		dx3 := 0;
      dr3 := 0;
      dg3 := 0;
      db3 := 0;
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
				PC.Y := PC.Y + db; 
				PC.Z := PC.Z + dg; 
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + db2;
         SC.Z := SC.Z + dg2;
         EP.U := EP.U + dx1;
         EC.X := EC.X + dr1;
         EC.Y := EC.Y + db1;
         EC.Z := EC.Z + dg1;
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
				PC.Y := PC.Y + db; 
				PC.Z := PC.Z + dg; 
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx2;
         SC.X := SC.X + dr2;
         SC.Y := SC.Y + db2;
         SC.Z := SC.Z + dg2;
         EP.U := EP.U + dx3;
         EC.X := EC.X + dr3;
         EC.Y := EC.Y + db3;
         EC.Z := EC.Z + dg3;
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
				PC.Y := PC.Y + db; 
				PC.Z := PC.Z + dg; 
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx1;
         SC.X := SC.X + dr1;
         SC.Y := SC.Y + db1;
         SC.Z := SC.Z + dg1;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + db2;
         EC.Z := EC.Z + dg2;
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
				PC.Y := PC.Y + db; 
				PC.Z := PC.Z + dg; 
            PP.U := PP.U + 1;
			end;
         SP.U := SP.U + dx3;
         SC.X := SC.X + dr3;
         SC.Y := SC.Y + db3;
         SC.Z := SC.Z + dg3;
         EP.U := EP.U + dx2;
         EC.X := EC.X + dr2;
         EC.Y := EC.Y + db2;
         EC.Z := EC.Z + dg2;
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

procedure CTextureGenerator.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer);
var
   x,y : integer;
begin
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      SetLength(_Buffer[x],0);
      SetLength(_WeightBuffer[x],0);
   end;
   SetLength(_Buffer,0);
   SetLength(_WeightBuffer,0);
end;

function CTextureGenerator.GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
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
            Result.Canvas.Pixels[x,Result.Height - y] := RGBA(Round((_Buffer[x,y].X / _WeightBuffer[x,y]) * 255),Round((_Buffer[x,y].Y / _WeightBuffer[x,y]) * 255),Round((_Buffer[x,y].Z / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].W / _WeightBuffer[x,y]) * 255));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
      end;
   end;
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
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
            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + (_Buffer[x,y].X / _WeightBuffer[x,y])) * 127.5),Round((1 + (_Buffer[x,y].Y / _WeightBuffer[x,y])) * 127.5),Round((1 + (_Buffer[x,y].Z / _WeightBuffer[x,y])) * 127.5));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
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

function CTextureGenerator.GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
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
   Result := GetColouredBitmapFromFrameBuffer(Buffer,WeightBuffer);
   Result.SaveToFile('test.bmp');
   DisposeFrameBuffer(Buffer,WeightBuffer,Size);
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
   DisposeFrameBuffer(Buffer,WeightBuffer,Size);
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
   DisposeFrameBuffer(Buffer,WeightBuffer,Size);
end;


end.
