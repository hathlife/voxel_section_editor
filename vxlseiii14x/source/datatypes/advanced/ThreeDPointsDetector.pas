// Class 3D Points Detector for Voxel Section Editor III
// Made by Banshee at 01/09/2009
unit ThreeDPointsDetector;

// This class was created to detect repetitive 3D vertices. Use GetIDFromPosition.
// If the Id is the same that you provided, the vertex that you are checking is
// legitimate. Otherwise, it is repetitive with a previous ID that you provided.

interface

uses BasicMathsTypes;

type
   P3DPositionDet = ^T3DPositionDet;
   T3DPositionDet = record
      x, y, z: real;
      id: integer;
      Next: P3DPositionDet;
   end;

   C3DPointsDetector = class
      private
         F3DMap : array of array of array of P3DPositionDet;
      public
         // Constructors and Destructors
         constructor Create(_Size: TVector3i);
         destructor Destroy; override;
         procedure Initialize;
         procedure Clear;
         procedure Reset;
         // Gets
         function GetIDFromPosition(_x, _y, _z: real; _id : integer): integer;
         // Adds
         function AddPosition(_x, _y, _z: real; _id: integer):P3DPositionDet;
         // Deletes
         procedure DeleteGroup(var _Element: P3DPositionDet);
   end;

implementation

// Constructors and Destructors
constructor C3DPointsDetector.Create(_Size: TVector3i);
begin
   SetLength(F3DMap,_Size.X,_Size.Y,_Size.Z);
   Initialize;
end;

destructor C3DPointsDetector.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure C3DPointsDetector.Initialize;
var
   x,y,z: integer;
begin
   for x := Low(F3DMap) to High(F3DMap) do
      for y := Low(F3DMap[x]) to High(F3DMap[x]) do
         for z := Low(F3DMap[x,y]) to High(F3DMap[x,y]) do
         begin
            F3DMap[x,y,z] := nil;
         end;
end;

procedure C3DPointsDetector.Clear;
var
   x,y,z: integer;
begin
   for x := Low(F3DMap) to High(F3DMap) do
      for y := Low(F3DMap[x]) to High(F3DMap[x]) do
         for z := Low(F3DMap[x,y]) to High(F3DMap[x,y]) do
         begin
            DeleteGroup(F3DMap[x,y,z]);
         end;
end;

procedure C3DPointsDetector.Reset;
begin
   Clear;
   Initialize;
end;

// Gets
function C3DPointsDetector.GetIDFromPosition(_x, _y, _z: real; _id : integer): integer;
var
   ix,iy,iz: integer;
   Previous,Element : P3DPositionDet;
begin
   ix := Trunc(_x);
   iy := Trunc(_y);
   iz := Trunc(_z);
   if F3DMap[ix,iy,iz] <> nil then
   begin
      Element := F3DMap[ix,iy,iz];
      Previous := nil;
      while Element <> nil do
      begin
         if (Element^.x = _x) and (Element^.y = _y) and (Element^.z = _z) then
         begin
            Result := Element^.id;
            exit;
         end;
         Previous := Element;
         Element := Element^.Next;
      end;
      Element := AddPosition(_x, _y, _z, _id);
      Previous^.Next := Element;
      Result := _id;
   end
   else
   begin
      F3DMap[ix,iy,iz] := AddPosition(_x, _y, _z, _id);
      Result := _id;
   end;
end;

// Adds
function C3DPointsDetector.AddPosition( _x, _y, _z: real; _id: integer): P3DPositionDet;
begin
   new(Result);
   Result^.Next := nil;
   Result^.id := _id;
   Result^.x := _x;
   Result^.y := _y;
   Result^.z := _z;
end;

// Deletes
procedure C3DPointsDetector.DeleteGroup(var _Element: P3DPositionDet);
begin
   if _Element <> nil then
   begin
      DeleteGroup(_Element^.Next);
      Dispose(_Element);
   end;
end;

end.
