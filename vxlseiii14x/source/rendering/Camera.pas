unit Camera;

interface

uses BasicMathsTypes, math3d, math, dglOpenGL;

type
   PCamera = ^TCamera;
   TCamera = class
   private
      // For the renderer
      RequestUpdateWorld: boolean;
      // Misc
      function CleanAngle(Angle: single): single;
   public
      // List
      Next : PCamera;
      // Atributes
      PositionAcceleration : TVector3f;
      RotationAcceleration : TVector3f;
      PositionSpeed : TVector3f;   // Move for the next frame.
      RotationSpeed : TVector3f;
      Position : TVector3f;
      Rotation : TVector3f;
      // Constructors
      constructor Create;
      procedure Reset;

      // Execution
      procedure RotateCamera;
      procedure MoveCamera;
      procedure ProcessNextFrame;

      // Gets
      function GetRequestUpdateWorld: boolean;

      // Sets
      procedure SetPosition(_x, _y, _z: single); overload;
      procedure SetPosition(_Vector: TVector3f); overload;
      procedure SetRotation(_x, _y, _z: single); overload;
      procedure SetRotation(_Vector: TVector3f); overload;
      procedure SetPositionSpeed(_x, _y, _z: single); overload;
      procedure SetPositionSpeed(_Vector: TVector3f); overload;
      procedure SetRotationSpeed(_x, _y, _z: single); overload;
      procedure SetRotationSpeed(_Vector: TVector3f); overload;
      procedure SetPositionAcceleration(_x, _y, _z: single); overload;
      procedure SetPositionAcceleration(_Vector: TVector3f); overload;
      procedure SetRotationAcceleration(_x, _y, _z: single); overload;
      procedure SetRotationAcceleration(_Vector: TVector3f); overload;
   end;

implementation

constructor TCamera.Create;
begin
   Next := nil;
   Reset;
end;

procedure TCamera.Reset;
begin
   Rotation.X := 0;
   Rotation.Y := -5;
   Rotation.Z := 0;
   Position.X := 0;
   Position.Y := 0;
   Position.Z := -150;
   PositionSpeed := SetVector(0,0,0);
   RotationSpeed := SetVector(0,0,0);
   PositionAcceleration := SetVector(0,0,0);
   RotationAcceleration := SetVector(0,0,0);
   RequestUpdateWorld := true;
end;

procedure TCamera.RotateCamera;
begin
   glRotatef(Rotation.X, 1, 0, 0);
   glRotatef(Rotation.Y, 0, 1, 0);
   glRotatef(Rotation.Z, 0, 0, 1);
end;

procedure TCamera.MoveCamera;
begin
   glTranslatef(Position.X, Position.Y, Position.Z);
end;

procedure TCamera.ProcessNextFrame;
var
   Signal : integer;
begin
   // Process acceleration.
   Signal := Sign(PositionSpeed.X);
   PositionSpeed.X := PositionSpeed.X + PositionAcceleration.X;
   if Signal <> Sign(PositionSpeed.X) then
      PositionSpeed.X := 0;
   Signal := Sign(PositionSpeed.Y);
   PositionSpeed.Y := PositionSpeed.Y + PositionAcceleration.Y;
   if Signal <> Sign(PositionSpeed.Y) then
      PositionSpeed.Y := 0;
   Signal := Sign(PositionSpeed.Z);
   PositionSpeed.Z := PositionSpeed.Z + PositionAcceleration.Z;
   if Signal <> Sign(PositionSpeed.Z) then
      PositionSpeed.Z := 0;
   Signal := Sign(RotationSpeed.X);
   RotationSpeed.X := RotationSpeed.X + RotationAcceleration.X;
   if Signal <> Sign(RotationSpeed.X) then
      RotationSpeed.X := 0;
   Signal := Sign(RotationSpeed.Y);
   RotationSpeed.Y := RotationSpeed.Y + RotationAcceleration.Y;
   if Signal <> Sign(RotationSpeed.Y) then
      RotationSpeed.Y := 0;
   Signal := Sign(RotationSpeed.Z);
   RotationSpeed.Z := RotationSpeed.Z + RotationAcceleration.Z;
   if Signal <> Sign(RotationSpeed.Z) then
      RotationSpeed.Z := 0;

   // Process position and angle
   Position.X := Position.X + PositionSpeed.X;
   Position.Y := Position.Y + PositionSpeed.Y;
   Position.Z := Position.Z + PositionSpeed.Z;
   Rotation.X := CleanAngle(Rotation.X + RotationSpeed.X);
   Rotation.Y := CleanAngle(Rotation.Y + RotationSpeed.Y);
   Rotation.Z := CleanAngle(Rotation.Z + RotationSpeed.Z);

   // update request world update.
   RequestUpdateWorld := RequestUpdateWorld or (PositionSpeed.X <> 0) or (PositionSpeed.Y <> 0) or (PositionSpeed.Z <> 0) or (RotationSpeed.X <> 0) or (RotationSpeed.Y <> 0) or (RotationSpeed.Z <> 0);
end;

function TCamera.GetRequestUpdateWorld: boolean;
begin
   Result := RequestUpdateWorld;
   RequestUpdateWorld := false;
end;

// Sets
procedure TCamera.SetPosition(_x, _y, _z: single);
begin
   Position.X := _x;
   Position.Y := _y;
   Position.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetPosition(_Vector: TVector3f);
begin
   Position.X := _Vector.X;
   Position.Y := _Vector.Y;
   Position.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetRotation(_x, _y, _z: single);
begin
   Rotation.X := CleanAngle(_x);
   Rotation.Y := CleanAngle(_y);
   Rotation.Z := CleanAngle(_z);
   RequestUpdateWorld := true;
end;

procedure TCamera.SetRotation(_Vector: TVector3f);
begin
   Rotation.X := CleanAngle(_Vector.X);
   Rotation.Y := CleanAngle(_Vector.Y);
   Rotation.Z := CleanAngle(_Vector.Z);
   RequestUpdateWorld := true;
end;

procedure TCamera.SetPositionSpeed(_x, _y, _z: single);
begin
   PositionSpeed.X := _x;
   PositionSpeed.Y := _y;
   PositionSpeed.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetPositionSpeed(_Vector: TVector3f);
begin
   PositionSpeed.X := _Vector.X;
   PositionSpeed.Y := _Vector.Y;
   PositionSpeed.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetRotationSpeed(_x, _y, _z: single);
begin
   RotationSpeed.X := _x;
   RotationSpeed.Y := _y;
   RotationSpeed.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetRotationSpeed(_Vector: TVector3f);
begin
   RotationSpeed.X := _Vector.X;
   RotationSpeed.Y := _Vector.Y;
   RotationSpeed.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetPositionAcceleration(_x, _y, _z: single);
begin
   PositionAcceleration.X := _x;
   PositionAcceleration.Y := _y;
   PositionAcceleration.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetPositionAcceleration(_Vector: TVector3f);
begin
   PositionAcceleration.X := _Vector.X;
   PositionAcceleration.Y := _Vector.Y;
   PositionAcceleration.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetRotationAcceleration(_x, _y, _z: single);
begin
   RotationAcceleration.X := _x;
   RotationAcceleration.Y := _y;
   RotationAcceleration.Z := _z;
   RequestUpdateWorld := true;
end;

procedure TCamera.SetRotationAcceleration(_Vector: TVector3f);
begin
   RotationAcceleration.X := _Vector.X;
   RotationAcceleration.Y := _Vector.Y;
   RotationAcceleration.Z := _Vector.Z;
   RequestUpdateWorld := true;
end;

// Misc
function TCamera.CleanAngle(Angle: single): single;
begin
   Result := Angle;
   if Result < 0 then
      Result := Result + 360;
   if Result > 360 then
      Result := Result - 360;
end;



end.
