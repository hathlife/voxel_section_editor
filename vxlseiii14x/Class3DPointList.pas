unit Class3DPointList;

interface

type
   P3DPosition = ^T3DPosition;
   T3DPosition = record
      x,y,z : integer;
      Next : P3DPosition;
   end;

   TGetPositionFunction = function (var x,y,z : integer): boolean of object;
   C3DPointList = class
      private
         Start,Last,Active : P3DPosition;
         procedure Reset;
      public
         GetPosition: TGetPositionFunction;
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure Add (x,y,z : integer);
         procedure Delete;
         // Delete
         procedure Clear;
         // Sets
         procedure UseSmartMemoryManagement(_value: boolean);
         // Gets
         function GetPositionTraditional (var x,y,z : integer): boolean;
         function GetPositionWithDeletion (var x,y,z : integer): boolean;
         function GetX: integer;
         function GetY: integer;
         function GetZ: integer;
         // Misc
         procedure GoToNextElement;
   end;

implementation

constructor C3DPointList.Create;
begin
   GetPosition := GetPositionTraditional;
   Reset;
end;

destructor C3DPointList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure C3DPointList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

// Add
procedure C3DPointList.Add (x,y,z : integer);
var
   NewPosition : P3DPosition;
begin
   New(NewPosition);
   NewPosition^.x := x;
   NewPosition^.y := y;
   NewPosition^.z := z;
   NewPosition^.Next := nil;
   if Start <> nil then
   begin
      Last^.Next := NewPosition;
   end
   else
   begin
      Start := NewPosition;
      Active := Start;
   end;
   Last := NewPosition;
end;

// Delete
procedure C3DPointList.Delete;
var
   Previous : P3DPosition;
begin
   if Active <> nil then
   begin
      Previous := Start;
      if Active = Start then
      begin
         Start := Start^.Next;
      end
      else
      begin
         while Previous^.Next <> Active do
         begin
            Previous := Previous^.Next;
         end;
         Previous^.Next := Active^.Next;
         if Active = Last then
         begin
            Last := Previous;
         end;
      end;
      Dispose(Active);
   end;
end;

procedure C3DPointList.Clear;
var
   Garbage : P3DPosition;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      dispose(Garbage);
   end;
end;

// Sets
procedure C3DPointList.UseSmartMemoryManagement(_value: boolean);
begin
   if _Value then
      GetPosition := GetPositionWithDeletion
   else
      GetPosition := GetPositionTraditional;
end;


// Gets
function C3DPointList.GetPositionTraditional (var x,y,z : integer): boolean;
begin
   if Active <> nil then
   begin
      x := Active^.x;
      y := Active^.y;
      z := Active^.z;
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function C3DPointList.GetPositionWithDeletion (var x,y,z : integer): boolean;
begin
   if Start <> nil then
   begin
      x := Start^.x;
      y := Start^.y;
      z := Start^.z;
      Active := Start;
      Start := Start^.Next;
      Dispose(Active);
      Active := Start;
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function C3DPointList.GetX: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.x;
   end;
end;

function C3DPointList.GetY: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.y;
   end;
end;

function C3DPointList.GetZ: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.z;
   end;
end;

// Misc
procedure C3DPointList.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

end.
