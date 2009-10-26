unit ClassTextureGenerator;

interface

uses BasicDataTypes, GLConstants, Geometry, Voxel_Engine;

type
   TTextureSeed = record
      Position : TVector2f;
      MinBound, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
   end;

   CTextureGenerator = class
      private
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
      public
         constructor Create;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
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
      Result := MatrixMultiply(Result,CreateRotationMatrixX(sin(_AngY),cos(_AngY)));
   end;
   if _AngZ <> C_ANGLE_NONE then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixX(sin(_AngZ),cos(_AngZ)));
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
      Result := CleanAngle(arccos(_Vector.Z / Distance));
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
      Result := CleanAngle(arccos(_Vector.Z / Distance));
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
      Result := CleanAngle(arccos(_Vector.Y / Distance));
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


end.
