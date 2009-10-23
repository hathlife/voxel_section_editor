unit ClassTextureGenerator;

interface

uses BasicDataTypes, GLConstants, Geometry;

type
   TTextureSeed = record
      Position : TVector2f;
      MinBound, MaxBounds: TVector2f;
      TransformMatrix : TMatrix;
   end;

   CTextureGenerator = class
      private
         // Transform Matrix Operations
         function GetTransformMatrix(_AngX, _AngY, _AngZ: single): TMatrix;
         // Angle Detector
         function GetRotationX(_Vector: TVector3f): single;
         function GetRotationY(_Vector: TVector3f): single;
         function GetRotationZ(_Vector: TVector3f): single;
         // Angle Operators
         function SubtractAngles(_Ang1, _Ang2: single): single;
      public
         constructor Create;
   end;


implementation

constructor CTextureGenerator.Create;
begin
   // do nothing?
end;

// Transform Matrix Operations
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


// Angle Detector
function CTextureGenerator.GetRotationX(_Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.Y * _Vector.Y) + (_Vector.Z * _Vector.Z));
   if Distance > 0 then
   begin
      Result := arccos(_Vector.Z / Distance);
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

function CTextureGenerator.GetRotationY(_Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.X * _Vector.X) + (_Vector.Z * _Vector.Z));
   if Distance > 0 then
   begin
      Result := arccos(_Vector.Z / Distance);
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

function CTextureGenerator.GetRotationZ(_Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.Y * _Vector.Y) + (_Vector.X * _Vector.X));
   if Distance > 0 then
   begin
      Result := arccos(_Vector.Y / Distance);
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
      Result := _Ang2 - _Ang1;
   end;
end;


end.
