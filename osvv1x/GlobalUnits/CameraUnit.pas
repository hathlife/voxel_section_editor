unit CameraUnit;

interface

uses Maths3D;

type
TCamera = Class(TObject)
public
  X_Angle,
  Y_Angle       : Single;
  Position      : TVec3;
  moveForward,
  moveBackward,
  moveLeft,
  moveRight,
  moveUp,
  moveDown      : Boolean;
  velocity      : TVec3;
  acceleration,
  friction,
  fov,
  max_speed,
  move_mouse_x,
  move_mouse_y  : Single;
  FWaitTime : Single;
 constructor Create;
 Procedure ApplyCamera;
 function Update(speed : single; IgnoreMouse : Boolean) : boolean;
 property WaitTime : Single read FWaitTime write FWaitTime;
end;

var
Camera : TCamera;

implementation

uses OpenGL15, Math;

constructor TCamera.Create;
begin
 acceleration := 2000;
 friction     := 1000*1.5;
 max_speed    := 200*2;
 fov          := 90;
 Position     := SetVector(0,0,0);
end;

Procedure TCamera.ApplyCamera;
begin
 glRotatef(X_Angle, 1, 0, 0); // pitch
 glRotatef(Y_Angle, 0, 1, 0);  // roll

 glTranslatef(-Position[0],-Position[1],-Position[2]);
end;

function TCamera.Update(speed : single; IgnoreMouse : Boolean) : boolean;
var dir, versor, desp, temp : TVec3;
    rad_yaw, vel, ivel : single;
label MouseAction;
begin
 if FWaitTime > 0 then
 begin
  FWaitTime := FWaitTime - Speed;
  exit;
 end;
  dir    := SetVector(0,0,0);
  versor := SetVector( 0,0,0);

  if (X_Angle < -90.0) or (X_Angle > 90.0) then
  begin
  moveForward := false;
  moveBackward := false;
  moveLeft := false;
  moveRight := false;

  velocity[0] := 0;
  velocity[2] := 0;
  end;

  if (moveForward)  then versor[2] := versor[2]-1.0;
  if (moveBackward) then versor[2] := versor[2]+1.0;
  if (moveUp)       then versor[1] := versor[1]+1.0;
  if (moveDown)     then versor[1] := versor[1]-1.0;
  if (moveLeft)     then versor[0] := versor[0]-1.0;
  if (moveRight)    then versor[0] := versor[0]+1.0;

  rad_yaw := DEG2RAD(Y_Angle);
  // strafe
  if (versor[0] <> 0) then begin
    dir[0] := dir[0] +  versor[0]*Cos(rad_yaw);
    dir[2] := dir[2] +  versor[0]*Sin(rad_yaw);
  end;

  // move

  if ((X_Angle < -88.0) or (X_Angle > 88.0)) then
  else
  if (versor[2] <> 0) then begin
    dir[0] := dir[0] -  versor[2]*Sin(rad_yaw);
    dir[2] := dir[2] +  versor[2]*Cos(rad_yaw);
  end;

  IF X_Angle > 90 then
  X_Angle := 90
  else
  IF X_Angle < -90 then
  X_Angle := -90;

  if X_angle = 90 then
  rad_yaw := DEG2RAD(-x_angle)
  else
  if X_angle = -90 then
  rad_yaw := DEG2RAD(-x_angle)
  else
  rad_yaw := DEG2RAD(x_angle);

  // move
  if (versor[1] <> 0) then begin
    dir[1] := dir[1] -  versor[1]*Tan(rad_yaw);
  end;

  rad_yaw := DEG2RAD(y_angle);

  if (Normalize(versor) > 0) then begin
    velocity[0] := velocity[0] + dir[0]*speed*acceleration;
    velocity[1] := velocity[1] + dir[1]*speed*acceleration;
    velocity[2] := velocity[2] + dir[2]*speed*acceleration;
  end;

  // Speed
  temp := velocity;
  vel := Normalize(temp);

  velocity[0] := velocity[0] - temp[0]*speed*friction;
  velocity[1] := velocity[1] - temp[1]*speed*friction;
  velocity[2] := velocity[2] - temp[2]*speed*friction;

  if (((temp[0] > 0) and (velocity[0] < 0)) or ((temp[0] < 0) and (velocity[0] > 0))) then
    velocity[0] := 0;
  if (((temp[1] > 0) and (velocity[1] < 0)) or ((temp[1] < 0) and (velocity[1] > 0))) then
    velocity[1] := 0;
  if (((temp[2] > 0) and (velocity[2] < 0)) or ((temp[2] < 0) and (velocity[2] > 0))) then
    velocity[2] := 0;

  if (vel > max_speed) then begin
    ivel := 1/vel*max_speed;
    velocity := MultiplyVector(velocity, ivel);
  end;

  // Position
  desp := MultiplyVector(velocity, speed);

  Position := AddVector(desp, Position);

MouseAction:
  // Rotation
  If Not IgnoreMouse then
  begin

  if (move_mouse_x <> 0) then begin
    y_angle := y_angle + move_mouse_x*fov/M_TWO_PI;		// the rotation is proportionnal to camera fov
  end;
  if (move_mouse_y <> 0) then begin
    x_angle := x_angle + move_mouse_y*fov/M_TWO_PI;
  end;

  end;

  // dont go out of bounds
  if (x_angle < -90.0) then
    x_angle := -90.0
  else if (x_angle > 90.0) then
    x_angle := 90.0;

  move_mouse_x := 0;
  move_mouse_y := 0;
  moveForward := false;
  moveBackward := false;
  moveLeft := false;
  moveRight := false;
  moveUp := false;
  moveDown := false;
end;

begin
 Camera := TCamera.Create;
end.
