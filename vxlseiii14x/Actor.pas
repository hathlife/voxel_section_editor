unit Actor;

interface

uses Voxel_engine, math3d, math, dglOpenGL, Model;

type
   PActor = ^TActor;
   TActor = class
   public
      // List
      Next : PActor;
      // Atributes
      Model : PModel;
      // physics cinematics.
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
      procedure Render;
      procedure RotateActor;
      procedure MoveActor;
      procedure ProcessNextFrame;
   end;

implementation

constructor TActor.Create;
begin
   Next := nil;
   Reset;
end;

procedure TActor.Reset;
begin
   Rotation.X := -90;
   Rotation.Y := 0;
   Rotation.Z := -85;
   Position.X := 0;
   Position.Y := 0;
   Position.Z := -30;
   PositionSpeed := SetVector(0,0,0);
   RotationSpeed := SetVector(0,0,0);
   PositionAcceleration := SetVector(0,0,0);
   RotationAcceleration := SetVector(0,0,0);
end;

procedure TActor.Render;
var
   MyModel : PModel;
begin
   ProcessNextFrame;
   glPushMatrix;
      MoveActor;
      RotateActor;
      MyModel := Model;
      while MyModel <> nil do
      begin
         // MyModel^.Render;
         MyModel := MyModel^.Next;
      end;
   glPopMatrix;

end;

procedure TActor.RotateActor;
begin
   glRotatef(Rotation.X, 1, 0, 0);
   glRotatef(Rotation.Y, 0, 1, 0);
   glRotatef(Rotation.Z, 0, 0, 1);
end;

procedure TActor.MoveActor;
begin
   glTranslatef(Position.X, Position.Y, Position.Z);
end;

procedure TActor.ProcessNextFrame;
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
end;

end.
