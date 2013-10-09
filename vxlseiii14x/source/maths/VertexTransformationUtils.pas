unit VertexTransformationUtils;

// This class is a split from ClassTextureGenerator and it should be used to
// project a plane out of a vector and find the position of another vector in
// this plane. Boring maths stuff.


interface

uses Geometry, BasicDataTypes, GLConstants, Math;

{$INCLUDE source/Global_Conditionals.inc}

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
         function GetRotationXZ(const _Vector: TVector3f): single;
         // Angle Operators
         function CleanAngle(Angle: single): single;
         function CleanAngleRadians(Angle: single): single;
         function CleanAngle90Radians(Angle: single): single;
         // Tangent Plane Detector
         procedure GetTangentPlaneFromNormalAndDirection(var _AxisX,_AxisY: TVector3f; const _Normal,_Direction: TVector3f);
         function ProjectVectorOnTangentPlane(const _Normal,_Vector: TVector3f): TVector3f;
         function GetArcCosineFromTangentPlane(const _Vector, _AxisX, _AxisY: TVector3f): single;
         function GetArcCosineFromAngleOnTangentSpace(_VI,_V1,_V2: TVector3f; _VertexNormal: TVector3f): single;
         // Misc
         function IsPointInsideTriangle(const _V1,_V2,_V3,_P : TVector2f): boolean;
   end;

implementation

uses GlobalVars, SysUtils, Math3d;

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
   AngX := GetRotationY(_Vector);
   AngY := GetRotationXZ(_Vector);
   // Now we get the transform matrix
   Result := GetTransformMatrixFromAngles(CleanAngleRadians(-AngX),CleanAngleRadians(-AngY));
end;

function TVertexTransformationUtils.GetTransformMatrixFromAngles(_AngX, _AngY: single): TMatrix;
const
   ANG90 = Pi * 0.5;
var
   RotMatrix : TMatrix;
begin
   Result := IdentityMatrix;
   // first of all, we align our world with the direction z = 1.
   if _AngX <> 0 then
   begin
      Result := MatrixMultiply(Result,CreateRotationMatrixY(sin(_AngX),cos(_AngX)));
   end;
   // now we vertically rotate our world to y = 0.
   if _AngY <> 0 then
   begin
      RotMatrix := CreateRotationMatrixX(sin(_AngY),cos(_AngY));
      Result := MatrixMultiply(Result,RotMatrix);
   end;

end;

function TVertexTransformationUtils.GetUVCoordinates(const _Position: TVector3f; _TransformMatrix: TMatrix): TVector2f;
begin
   Result.U := (_Position.X * _TransformMatrix[0,0]) + (_Position.Y * _TransformMatrix[0,1]) + (_Position.Z * _TransformMatrix[0,2]);
   Result.V := (_Position.X * _TransformMatrix[1,0]) + (_Position.Y * _TransformMatrix[1,1]) + (_Position.Z * _TransformMatrix[1,2]);
end;

// Angle Detector

// GetRotationX has been deprecated (use XZ instead)
function TVertexTransformationUtils.GetRotationX(const _Vector: TVector3f): single;
begin
   if _Vector.Y <> 0 then
   begin
      Result := CleanAngleRadians((-1 * (_Vector.Y) / (Abs(_Vector.Y))) *  arccos(sqrt((_Vector.X * _Vector.X) + (_Vector.Z * _Vector.Z))));
   end
   else
   begin
      Result := 0;
   end;
end;

// Horizontal rotation. (Rotation is 0 if it points to z = 1)
function TVertexTransformationUtils.GetRotationY(const _Vector: TVector3f): single;
begin
   if (_Vector.X <> 0) then
   begin
      Result := CleanAngleRadians(((_Vector.X) / (Abs(_Vector.X))) * arccos(_Vector.Z / sqrt((_Vector.X * _Vector.X) + (_Vector.Z * _Vector.Z))));
   end
   else if (_Vector.Z >= 0) then
   begin
      Result := 0;
   end
   else
   begin
      Result := Pi;
   end;
end;

// Vertical rotation. (Rotation is 0 if y = 0)
function TVertexTransformationUtils.GetRotationXZ(const _Vector: TVector3f): single;
begin
   if _Vector.Y <> 0 then
   begin
      if _Vector.Y = 1 then
      begin
         Result := Pi * 0.5;
      end
      else if _Vector.Y = -1 then
      begin
         Result := Pi * 1.5;
      end
      else
      begin
         if _Vector.Z = max(abs(_Vector.Z),abs(_Vector.X)) then
         begin
            Result := CleanAngleRadians(((_Vector.Z) / (Abs(_Vector.Z))) *  arcsin(_Vector.Y / sqrt((_Vector.Y * _Vector.Y) + (_Vector.Z * _Vector.Z))));
         end
         else
         begin
            Result := CleanAngleRadians(((_Vector.X) / (Abs(_Vector.X))) *  arcsin(_Vector.Y / sqrt((_Vector.X * _Vector.X) + (_Vector.Y * _Vector.Y))));
         end;
      end;
   end
   else
   begin
      Result := 0;
   end;
end;


// Angle Operators

function TVertexTransformationUtils.CleanAngle(Angle: single): single;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + 360;
   if Result >= 360 then
      Result := Result - 360;
end;

function TVertexTransformationUtils.CleanAngleRadians(Angle: single): single;
const
   C_2PI = 2 * Pi;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + C_2Pi;
   if Result >= C_2Pi then
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
      Result := Result + C_2Pi;
   if Result > C_2Pi then
      Result := Result - C_2Pi;
   // Now we ensure that it will be either between (0, Pi/2) and (3Pi/2 and 2Pi).
   if (Result > C_PIDiv2) and (Result <= Pi) then
      Result := Pi - Result
   else if (Result > Pi) and (Result < C_3PIDiv2) then
      Result := C_2Pi - (Result - Pi);
end;

// Tangent Plane Detector
procedure TVertexTransformationUtils.GetTangentPlaneFromNormalAndDirection(var _AxisX,_AxisY: TVector3f; const _Normal,_Direction: TVector3f);
var
   Direction: TVector3f;
begin
   Direction := SetVector(_Direction);
   Normalize(Direction);
   _AxisY := CrossProduct(_Normal,Direction);
   Normalize(_AxisY);
   _AxisX := CrossProduct(_Normal,_AxisY);
   Normalize(_AxisX);
end;

function TVertexTransformationUtils.ProjectVectorOnTangentPlane(const _Normal,_Vector: TVector3f): TVector3f;
begin
//   Result := _Vector - Dot(_Vector,_Normal)*_Normal;
   Result := SubtractVector(_Vector,ScaleVector(_Normal,DotProduct(_Vector,_Normal)));
end;

function TVertexTransformationUtils.GetArcCosineFromTangentPlane(const _Vector, _AxisX, _AxisY: TVector3f): single;
var
   Signal : single;
begin
   Signal := DotProduct(_Vector,_AxisY);
   if Signal > 0 then
   begin
      Signal := 1;
   end
   else if Signal < 0 then
   begin
      Signal := -1;
   end;
   Result := Signal * ArcCos(DotProduct(_Vector,_AxisX));
end;

function TVertexTransformationUtils.GetArcCosineFromAngleOnTangentSpace(_VI,_V1,_V2: TVector3f; _VertexNormal: TVector3f): single;
var
   Direction1,Direction2: TVector3f;
begin
   // Get the projection of the edges on Tangent Plane
   {$ifdef SMOOTH_TEST}
   //GlobalVars.SmoothFile.Add('VI: (' + FloatToStr(_VI.X) + ', ' + FloatToStr(_VI.Y) + ', ' + FloatToStr(_VI.Z) + '), V1: (' + FloatToStr(_V1.X) + ', ' + FloatToStr(_V1.Y) + ', ' + FloatToStr(_V1.Z) + ') and V2: (' + FloatToStr(_V2.X) + ', ' + FloatToStr(_V2.Y) + ', ' + FloatToStr(_V2.Z) + ').');
   {$endif}
   Direction1 := SubtractVector(_V1,_VI);
   Normalize(Direction1);
   {$ifdef SMOOTH_TEST}
   //GlobalVars.SmoothFile.Add('Direction 1: (' + FloatToStr(Direction1.X) + ', ' + FloatToStr(Direction1.Y) + ', ' + FloatToStr(Direction1.Z) + ')');
   {$endif}
   Direction1 := ProjectVectorOnTangentPlane(_VertexNormal,Direction1);
   Normalize(Direction1);
   Direction2 := SubtractVector(_V2,_VI);
   Normalize(Direction2);
   {$ifdef SMOOTH_TEST}
   //GlobalVars.SmoothFile.Add('Direction 2: (' + FloatToStr(Direction2.X) + ', ' + FloatToStr(Direction2.Y) + ', ' + FloatToStr(Direction2.Z) + ')');
   {$endif}
   Direction2 := ProjectVectorOnTangentPlane(_VertexNormal,Direction2);
   Normalize(Direction2);
   {$ifdef SMOOTH_TEST}
   //GlobalVars.SmoothFile.Add('Projected Direction 1: (' + FloatToStr(Direction1.X) + ', ' + FloatToStr(Direction1.Y) + ', ' + FloatToStr(Direction1.Z) + ') and Projected Direction 2: (' + FloatToStr(Direction2.X) + ', ' + FloatToStr(Direction2.Y) + ', ' + FloatToStr(Direction2.Z) + ') at VertexNormal: (' + FloatToStr(_VertexNormal.X) + ', ' + FloatToStr(_VertexNormal.Y) + ', ' + FloatToStr(_VertexNormal.Z) + ')');
   {$endif}
   // Return dot product.
   Result := CleanAngleRadians(ArcCos(DotProduct(Direction1,Direction2)));
   {$ifdef SMOOTH_TEST}
   //GlobalVars.SmoothFile.Add('Resulting Angle is: ' + FloatToStr(Result) + '.');
   {$endif}
end;

function TVertexTransformationUtils.IsPointInsideTriangle(const _V1,_V2,_V3,_P : TVector2f): boolean;
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
   dot00 := DotProduct(v0, v0);
   dot01 := DotProduct(v0, v1);
   dot02 := DotProduct(v0, v2);
   dot11 := DotProduct(v1, v1);
   dot12 := DotProduct(v1, v2);

   // Compute barycentric coordinates
   invDenom := 1 / ((dot00 * dot11) - (dot01 * dot01));
   u := ((dot11 * dot02) - (dot01 * dot12)) * invDenom;
   v := ((dot00 * dot12) - (dot01 * dot02)) * invDenom;

   // Check if point is in triangle
   Result := ((u > 0) and (v > 0) and ((u + v) < 1));
end;

end.
