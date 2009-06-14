unit Class2DPointOrderList;

interface

uses Class2DPointQueue;

type
   P2DPointOrderItem = ^C2DPointOrderItem;
   C2DPointOrderItem = record
      Value: integer;
      Edges: C2DPointQueue;
      Next: P2DPointOrderItem;
   end;

   C2DPointOrderList = class
      private
         Start,Active : P2DPointOrderItem;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure Add (Value,x,y : integer);
         procedure Delete;
         // Delete
         procedure Clear;
         // Gets
         function GetPosition (var x,y : integer): boolean;
         function GetX: integer;
         function GetY: integer;
         function IsEmpty: boolean;
         // Misc
         procedure GoToNextElement;
         procedure GoToFirstElement;
   end;

implementation

constructor C2DPointOrderList.Create;
begin
   Reset;
end;

destructor C2DPointOrderList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure C2DPointOrderList.Reset;
begin
   Start := nil;
   Active := nil;
end;

// Add
procedure C2DPointOrderList.Add (Value,x,y : integer);
var
   PreviousPosition,CurrentPosition: P2DPointOrderItem;
   NewPosition : P2DPointOrderItem;
   LeaveLoop: boolean;
begin
   LeaveLoop := false;
   CurrentPosition := Start;
   PreviousPosition := nil;
   while (CurrentPosition <> nil) and (not LeaveLoop) do
   begin
      if Value < CurrentPosition^.Value then
      begin
         LeaveLoop := true;
      end
      else if Value = CurrentPosition^.Value then
      begin
         CurrentPosition^.Edges.Add(x,y);
         exit;
      end
      else
      begin
         PreviousPosition := CurrentPosition;
         CurrentPosition := CurrentPosition^.Next;
      end;
   end;
   New(NewPosition);
   NewPosition^.Edges := C2DPointQueue.Create;
   NewPosition^.Edges.Add(x,y);
   NewPosition^.Value := Value;
   if Start <> nil then
   begin
      if PreviousPosition <> nil then
      begin
         NewPosition^.Next := PreviousPosition^.Next;
         PreviousPosition^.Next := NewPosition;
      end
      else
      begin
         NewPosition^.Next := Start;
         Start := NewPosition;
         Active := Start;
      end;
   end
   else
   begin
      Start := NewPosition;
      NewPosition^.Next := nil;
      Active := Start;
   end;
end;

// Delete
procedure C2DPointOrderList.Delete;
var
   Previous : P2DPointOrderItem;
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
      end;
      Active^.Edges.Free;
      Dispose(Active);
   end;
end;

procedure C2DPointOrderList.Clear;
var
   Garbage : P2DPointOrderItem;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      Garbage^.Edges.Free;
      dispose(Garbage);
   end;
end;

// Gets
function C2DPointOrderList.GetPosition (var x,y : integer): boolean;
begin
   if Active <> nil then
   begin
      Active^.Edges.GetPosition(x,y);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function C2DPointOrderList.GetX: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.Edges.GetX;
   end;
end;

function C2DPointOrderList.GetY: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.Edges.GetY;
   end;
end;

function C2DPointOrderList.IsEmpty: boolean;
begin
   Result := (Start = nil);
end;

// Misc
procedure C2DPointOrderList.GoToNextElement;
begin
   if Active <> nil then
   begin
      if Active^.Edges.IsEndOfQueue then
      begin
         Active := Active^.Next;
      end
      else
      begin
         Active^.Edges.GoToNextElement;
      end;
   end
end;

procedure C2DPointOrderList.GoToFirstElement;
begin
   Active := Start;
   while Active <> nil do
   begin
      Active^.Edges.GoToFirstElement;
      Active := Active^.Next;
   end;
   Active := Start;
end;

end.
