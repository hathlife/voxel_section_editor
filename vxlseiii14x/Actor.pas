unit Actor;

interface

uses Voxel_engine, BasicDataTypes, math3d, math, dglOpenGL, Model;

type
   PActor = ^TActor;
   TActor = class
   public
      // List
      Next : PActor;
      // Atributes
      Models : PModel;
      // physics cinematics.
      PositionAcceleration : TVector3f;
      RotationAcceleration : TVector3f;
      PositionSpeed : TVector3f;   // Move for the next frame.
      RotationSpeed : TVector3f;
      Position : TVector3f;
      Rotation : TVector3f;
      // User interface
      IsSelected : boolean;
      // Constructors
      constructor Create;
      procedure Reset;

      // Execution
      procedure Render(var _PolyCount: longword);
      procedure RotateActor;
      procedure MoveActor;
      procedure ProcessNextFrame;

      // Removes
      procedure RemoveModel(var _Model : PModel);
   end;

implementation

constructor TActor.Create;
begin
   Next := nil;
   IsSelected := false;
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

procedure TActor.Render(var _PolyCount: longword);
var
   MyModel : PModel;
begin
   ProcessNextFrame;
   glPushMatrix;
      MoveActor;
      RotateActor;
      MyModel := Models;
      while MyModel <> nil do
      begin
         MyModel^.Render(_PolyCount);
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

// Removes
procedure TActor.RemoveModel(var _Model : PModel);
var
   PreviousModel : PModel;
begin
   if Models = nil then exit; // Can't delete from an empty list.
   if _Model <> nil then
   begin
      // Check if it is the first camera.
      if _Model = Models then
      begin
         Models := _Model^.Next;
      end
      else // It could be inside the list, but it's not the first.
      begin
         PreviousModel := Models;
         while (PreviousModel^.Next <> nil) and (PreviousModel^.Next <> _Model) do
         begin
            PreviousModel := PreviousModel^.Next;
         end;
         if PreviousModel^.Next = _Model then
         begin
            PreviousModel^.Next := _Model^.Next;
         end
         else // nil -- not from this list.
            exit;
      end;
      // If it has past this stage, the camera is valid and was part of the list.
      // Now we dispose the camera.
      _Model^.Free;
      _Model := nil;
   end;
end;


end.
