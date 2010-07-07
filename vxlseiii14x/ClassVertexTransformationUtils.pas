unit ClassVertexTransformationUtils;

// This class is a split from ClassTextureGenerator and it should be used to
// project a plane out of a vector and find the position of another vector in
// this plane. Boring maths stuff.


interface

uses Geometry, BasicDataTypes, GLConstants;

type
   TVertexTransformationUtils = class
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Transform Matrix Operations
         function GetTransformMatrixFromVector(_Vector: TVector3f): TMatrix;
         function GetTransformMatrixFromAngles(_AngX, _AngY: single): TMatrix;
         function GetUVCoordinates(const _Position: TVector3f; _TransformMatrix: TMatrix): TVector2f;
         // Angle Detector
         function GetRotationX(const _Vector: TVector3f): single;
         function GetRotationY(const _Vector: TVector3f): single;
         // Angle Operators
         function CleanAngle(Angle: single): single;
         function CleanAngleRadians(Angle: single): single;
         function CleanAngle90Radians(Angle: single): single;
   end;

implementation

constructor TVertexTransformationUtils.Create;
begin
   Initialize;
end;

destructor TVertexTransformationUtils.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TVertexTransformationUtils.Initialize;
begin
   // do nothing
end;

procedure TVertexTransformationUtils.Clear;
begin
   // do nothing
end;

procedure TVertexTransformationUtils.Reset;
begin
   Clear;
   Initialize;
end;

// Transform Matrix Operations
function TVertexTransformationUtils.GetTransformMatrixFromVector(_Vector: TVector3f): TMatrix;
const
   C_ANG_X = 0;
   C_ANG_Y = 0;
var
   AngX,AngY : single;
begin
   // Get the angles from the normal vector.
   AngX := GetRotationX(_Vector);
   AngY := GetRotationY(_Vector);
   // Now we get the transform matrix
   Result := GetTransformMatrixFromAngles(AngX,AngY);
end;

function TVertexTransformationUtils.GetTransformMatrixFromAngles(_AngX, _AngY: single): TMatrix;
begin
   Result := IdentityMatrix;
   if _AngY <> C_ANGLE_NONE then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixY(sin(_AngY),cos(_AngY)));
   end;
   if _AngX <> C_ANGLE_NONE then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixX(sin(_AngX),cos(_AngX)));
   end;
end;

function TVertexTransformationUtils.GetUVCoordinates(const _Position: TVector3f; _TransformMatrix: TMatrix): TVector2f;
var
   TempVector: TVector3f;
begin
   TempVector := VectorTransform(_Position,_TransformMatrix);
   Result.U := TempVector.X;
   Result.V := TempVector.Y;
end;

// Angle Detector
function TVertexTransformationUtils.GetRotationX(const _Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.Y * _Vector.Y) + (_Vector.Z * _Vector.Z));
   if Distance > 0 then
   begin
      if (_Vector.Y <> 0) then
      begin
         Result := CleanAngle90Radians(((-1 * _Vector.Y) / (Abs(_Vector.Y))) *  arccos(abs(_Vector.Z) / Distance));
      end
      else
      begin
         Result := C_ANGLE_NONE;//CleanAngle90Radians(-1 * arccos(abs(_Vector.Z) / Distance));
      end;
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

function TVertexTransformationUtils.GetRotationY(const _Vector: TVector3f): single;
var
   Distance: single;
begin
   Distance := sqrt((_Vector.X * _Vector.X) + (_Vector.Z * _Vector.Z));
   if Distance > 0 then
   begin
      if (_Vector.X <> 0) then
      begin
         Result := CleanAngleRadians(((-1 * _Vector.X) / (Abs(_Vector.X))) * arccos(_Vector.Z / Distance));
      end
      else
      begin
         Result := CleanAngleRadians(-1 * arccos(_Vector.Z / Distance));
      end;
   end
   else
   begin
      Result := C_ANGLE_NONE;
   end;
end;

// Angle Operators

function TVertexTransformationUtils.CleanAngle(Angle: single): single;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + 360;
   if Result > 360 then
      Result := Result - 360;
end;

function TVertexTransformationUtils.CleanAngleRadians(Angle: single): single;
const
   C_2PI = 2 * Pi;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + Pi;
   if Result > C_2Pi then
      Result := Result - C_2Pi;
end;

function TVertexTransformationUtils.CleanAngle90Radians(Angle: single): single;
const
   C_2PI = 2 * Pi;
   C_PIDiv2 = Pi / 2;
   C_3PIDiv2 = 1.5 * Pi;
begin
   Result := Angle;
   // Ensure that it is between 0 and 2Pi.
   if Result < 0 then
      Result := Result + Pi;
   if Result > C_2Pi then
      Result := Result - C_2Pi;
   // Now we ensure that it will be either between 3Pi/2 and Pi/2.
   if (Result > C_PIDiv2) and (Result <= Pi) then
      Result := Pi - Result
   else if (Result > Pi) and (Result < C_3PIDiv2) then
      Result := C_2Pi - (Result - Pi);
end;

end.
