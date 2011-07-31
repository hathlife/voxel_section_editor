unit math3d;

interface

uses BasicDataTypes;

const
  M_PI = 3.1415926535897932384626433832795;		// matches value in gcc v2 math.h
  M_TWO_PI = 6.283185307179586476925286766559;
  M_180_PI = 57.295779513082320876798154814105;
  M_PI_180 = 0.017453292519943295769236907684886;


function VectorDistance(const v1, v2 : TVector3f) : Single;
function DEG2RAD(a : single) : single;
function RAD2DEG(a : single) : single;
function Normalize(var v : TVector2f) : single; overload;
function Normalize(var v : TVector3f) : single; overload;
function Normalize(var v : TVector4f) : single; overload;
function ScaleVector(v : TVector2f; s : single) : TVector2f; overload;
function ScaleVector(v : TVector3f; s : single) : TVector3f; overload;
function ScaleVector(v : TVector4f; s : single) : TVector4f; overload;
function ScaleVector2f(v,s : TVector2f) : TVector2f;
function ScaleVector3f(v,s : TVector3f) : TVector3f;
function ScaleVector4f(v,s : TVector4f) : TVector4f;
function AddVector(v1, v2 : TVector2f) : TVector2f; overload;
function AddVector(v1, v2 : TVector3f) : TVector3f; overload;
function AddVector(v1, v2 : TVector4f) : TVector4f; overload;
function SubtractVector(v1, v2 : TVector2f) : TVector2f; overload;
function SubtractVector(v1, v2 : TVector3f) : TVector3f; overload;
function SubtractVector(v1, v2 : TVector4f) : TVector4f; overload;
function DotProduct(v1, v2 : TVector2f) : single; overload;
function DotProduct(v1, v2 : TVector3f) : single; overload;
function DotProduct(v1, v2 : TVector4f) : single; overload;
function InvertVector(v : TVector2f) : TVector2f; overload;
function InvertVector(v : TVector3f) : TVector3f; overload;
function InvertVector(v : TVector4f) : TVector4f; overload;
function planeDistance(point, PlaneNormal : TVector3f; PlaneDistance : single) : single;
function SetVector(const v: TVector2f) : TVector2f; overload;
function SetVector(const v: TVector3f) : TVector3f; overload;
function SetVector(const v: TVector4f) : TVector4f; overload;
function SetVector(u, v : single) : TVector2f; overload;
function SetVector(x, y, z : single) : TVector3f; overload;
function SetVector(x, y, z, w : single) : TVector4f; overload;
function CrossProduct(const V1, V2: TVector3f): TVector3f;
function ClassifyPoint(point, PlaneNormal : TVector3f; PlaneDistance : single) : single; overload;
function ClassifyPoint(PlaneNormal : TVector3f; PlaneDistance : single) : single; overload;
function ClassifyPoint(Point, PointOnPlane, PlaneNormal : TVector3f) : single; overload;
function CleanAngle(Angle: single): single;

implementation

function VectorDistance(const v1, v2 : TVector3f) : Single; register;
// EAX contains address of v1
// EDX contains highest of v2
// Result  is passed on the stack
asm
      FLD  DWORD PTR [EAX]
      FSUB DWORD PTR [EDX]
      FMUL ST, ST
      FLD  DWORD PTR [EAX+4]
      FSUB DWORD PTR [EDX+4]
      FMUL ST, ST
      FADD
      FLD  DWORD PTR [EAX+8]
      FSUB DWORD PTR [EDX+8]
      FMUL ST, ST
      FADD
      FSQRT
end;

function SetVector(const v : TVector2f) : TVector2f;
begin
  result.u := v.u;
  result.v := v.v;
end;


function SetVector(const v : TVector3f) : TVector3f;
begin
  result.x := v.x;
  result.y := v.y;
  result.z := v.z;
end;

function SetVector(const v : TVector4f) : TVector4f;
begin
  result.x := v.x;
  result.y := v.y;
  result.z := v.z;
  result.w := v.w;
end;

function SetVector(u, v : single) : TVector2f;
begin
  result.u := u;
  result.v := v;
end;

function SetVector(x, y, z : single) : TVector3f;
begin
  result.x := x;
  result.y := y;
  result.z := z;
end;

function SetVector(x, y, z, w : single) : TVector4f;
begin
  result.x := x;
  result.y := y;
  result.z := z;
  result.w := w;
end;

function DEG2RAD(a : single) : single;
begin
  result :=  a*M_PI_180;
end;

function RAD2DEG(a : single) : single;
begin
  result := a*M_180_PI;
end;

function Normalize(var v : TVector2f) : single;
var l : single;
begin
   l := sqrt(v.u*v.u+v.v*v.v);

   if (l > 0) then
   begin
      v.u := v.u/l;
      v.v := v.v/l;
   end;
   result := l;
end;

function Normalize(var v : TVector3f) : single;
var l : single;
begin
   l := sqrt(v.x*v.x+v.y*v.y+v.z*v.z);

   if (l > 0) then
   begin
      v.x := v.x/l;
      v.y := v.y/l;
      v.z := v.Z/l;
   end;
   result := l;
end;

function Normalize(var v : TVector4f) : single;
var l : single;
begin
   l := sqrt(v.x*v.x+v.y*v.y+v.z*v.z+v.w*v.w);

   if (l > 0) then
   begin
      v.x := v.x/l;
      v.y := v.y/l;
      v.z := v.z/l;
      v.w := v.w/l;
   end;
   result := l;
end;

function ScaleVector(v : TVector2f; s : single) : TVector2f;
begin
   Result.u := v.u * s;
   Result.v := v.v * s;
end;

function ScaleVector(v : TVector3f; s : single) : TVector3f;
begin
   Result.x := v.x * s;
   Result.y := v.y * s;
   Result.z := v.z * s;
end;

function ScaleVector(v : TVector4f; s : single) : TVector4f;
begin
   Result.x := v.x * s;
   Result.y := v.y * s;
   Result.z := v.z * s;
   Result.w := v.w * s;
end;

function ScaleVector2f(v,s : TVector2f) : TVector2f;
begin
   Result.u := v.u * s.u;
   Result.v := v.v * s.v;
end;

function ScaleVector3f(v,s : TVector3f) : TVector3f;
begin
   Result.x := v.x * s.x;
   Result.y := v.y * s.y;
   Result.z := v.z * s.z;
end;

function ScaleVector4f(v,s : TVector4f) : TVector4f;
begin
   Result.x := v.x * s.x;
   Result.y := v.y * s.y;
   Result.z := v.z * s.z;
   Result.w := v.w * s.w;
end;

function AddVector(v1, v2 : TVector2f) : TVector2f;
begin
   Result.u := v1.u + v2.u;
   Result.v := v1.v + v2.v;
end;

function AddVector(v1, v2 : TVector3f) : TVector3f;
begin
   Result.x := v1.x + v2.x;
   Result.y := v1.y + v2.y;
   Result.z := v1.z + v2.z;
end;

function AddVector(v1, v2 : TVector4f) : TVector4f;
begin
   Result.x := v1.x + v2.x;
   Result.y := v1.y + v2.y;
   Result.z := v1.z + v2.z;
   Result.w := v1.w + v2.w;
end;

function SubtractVector(v1, v2 : TVector2f) : TVector2f;
begin
   Result.u := v1.u - v2.u;
   Result.v := v1.v - v2.v;
end;

function SubtractVector(v1, v2 : TVector3f) : TVector3f;
begin
   Result.x := v1.x - v2.x;
   Result.y := v1.y - v2.y;
   Result.z := v1.z - v2.z;
end;

function SubtractVector(v1, v2 : TVector4f) : TVector4f;
begin
   Result.x := v1.x - v2.x;
   Result.y := v1.y - v2.y;
   Result.z := v1.z - v2.z;
   Result.w := v1.w - v2.w;
end;

function DotProduct(v1, v2 : TVector2f) : single;
begin
   Result := v1.U*v2.U + v1.V*v2.V
end;

function DotProduct(v1, v2 : TVector3f) : single;
begin
   Result := v1.X*v2.X + v1.y*v2.y + v1.z*v2.z;
end;

function DotProduct(v1, v2 : TVector4f) : single;
begin
   Result := v1.X*v2.X + v1.y*v2.y + v1.z*v2.z + v1.w*v2.w;
end;

function InvertVector(v : TVector2f) : TVector2f;
begin
   Result.u := -v.u;
   Result.v := -v.v;
end;

function InvertVector(v : TVector3f) : TVector3f;
begin
   Result.x := -v.x;
   Result.y := -v.y;
   Result.z := -v.z;
end;

function InvertVector(v : TVector4f) : TVector4f;
begin
   Result.x := -v.x;
   Result.y := -v.y;
   Result.z := -v.z;
   Result.w := -v.w;
end;

function CrossProduct(const V1, V2: TVector3f): TVector3f;
begin
   Result.X:=V1.Y * V2.z - V1.z * V2.y;
   Result.Y:=V1.z * V2.x - V1.x * V2.z;
   Result.Z:=V1.x * V2.y - V1.y * V2.x;
end;

function planeDistance(point, PlaneNormal : TVector3f; PlaneDistance : single) : single;
begin
  result := (planeNormal.x * point.x +
	     planeNormal.y * point.y +
	     planeNormal.z * point.z) - PlaneDistance;
end;

// point = test point
// p0 = point on plane = VectorScale(Plane.Normal, -Plane.d)
// pN = plane normal
function ClassifyPoint(point, PlaneNormal : TVector3f; PlaneDistance : single) : single;
var pointOnPlane, tempVect, dir : TVector3f;
    d : single;
begin
 pointOnPlane := ScaleVector(PlaneNormal, -PlaneDistance);
 TempVect.x := pointOnPlane.x - point.x;
 TempVect.y := pointOnPlane.y - point.y;
 TempVect.z := pointOnPlane.z - point.z;
 dir := TempVect;
 d := DotProduct(dir, PlaneNormal);
 if (d < -0.001) then
   result := 1
 else if (d > 0.001) then
   result := -1
 else
   result := 0;
end;

function ClassifyPoint(PlaneNormal : TVector3f; PlaneDistance : single) : single;
var pointOnPlane, tempVect, dir, point : TVector3f;
    d : single;
begin
 point := SetVector(0,0,0);
 pointOnPlane := ScaleVector(PlaneNormal, -PlaneDistance);
 TempVect.x := pointOnPlane.x - point.x;
 TempVect.y := pointOnPlane.y - point.y;
 TempVect.z := pointOnPlane.z - point.z;
 dir := TempVect;
 d := DotProduct(dir, PlaneNormal);
 if (d < -0.001) then
   result := 1
 else if (d > 0.001) then
   result := -1
 else
   result := 0;
end;

function ClassifyPoint(Point, PointOnPlane, PlaneNormal : TVector3f) : single; overload;
var tempVect, dir : TVector3f;
    d : single;
begin
 TempVect.x := pointOnPlane.x - point.x;
 TempVect.y := pointOnPlane.y - point.y;
 TempVect.z := pointOnPlane.z - point.z;
 dir := TempVect;
 d := DotProduct(dir, PlaneNormal);
 if (d < -0.001) then
   result := 1
 else if (d > 0.001) then
   result := -1
 else
   result := 0;
end;

function CleanAngle(Angle: single): single;
begin
   Result := (360 + Angle);
   if Result > 360 then
      Result := Result - 360;
end;


end.
