unit Class2DPointQueue;

interface

type
   P2DPosition = ^T2DPosition;
   T2DPosition = record
      x,y : integer;
      Next : P2DPosition;
   end;

   C2DPointQueue = class
      private
         Start,Last,Active : P2DPosition;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure Add (x,y : integer);
         procedure Delete;
         // Delete
         procedure Clear;
         // Gets
         function GetPosition (var x,y : integer): boolean;
         function GetX: integer;
         function GetY: integer;
         function IsEmpty: boolean;
         function IsEndOfQueue: boolean;
         // Misc
         procedure GoToNextElement;
         procedure GoToFirstElement;
         procedure GoToLastElement;
   end;

implementation

constructor C2DPointQueue.Create;
begin
   Reset;
end;

destructor C2DPointQueue.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure C2DPointQueue.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

// Add
procedure C2DPointQueue.Add (x,y : integer);
var
   NewPosition : P2DPosition;
begin
   New(NewPosition);
   NewPosition^.x := x;
   NewPosition^.y := y;
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
procedure C2DPointQueue.Delete;
var
   Previous : P2DPosition;
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

procedure C2DPointQueue.Clear;
var
   Garbage : P2DPosition;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      dispose(Garbage);
   end;
end;

// Gets
function C2DPointQueue.GetPosition (var x,y : integer): boolean;
begin
   if Active <> nil then
   begin
      x := Active^.x;
      y := Active^.y;
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function C2DPointQueue.GetX: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.x;
   end;
end;

function C2DPointQueue.GetY: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.y;
   end;
end;

function C2DPointQueue.IsEmpty: boolean;
begin
   Result := (Start = nil);
end;

// Misc
procedure C2DPointQueue.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure C2DPointQueue.GoToFirstElement;
begin
   Active := Start;
end;

procedure C2DPointQueue.GoToLastElement;
begin
   Active := Last;
end;

function C2DPointQueue.IsEndOfQueue: boolean;
begin
   Result := Active = Last;
end;


end.
