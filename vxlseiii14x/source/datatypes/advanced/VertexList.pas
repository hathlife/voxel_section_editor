unit VertexList;

interface

uses BasicDataTypes;

type
   CVertexList = class
      private
         Start,Last,Active : PVertexItem;
         FCount: integer;
         procedure Reset;
         function GetX: single;
         function GetY: single;
         function GetZ: single;
         function GetID: integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PVertexItem);
         function SaveState:PVertexItem;
         // Add
         function Add (_ID : integer; _x,_y,_z: single): integer;
         procedure Delete;
         // Delete
         procedure Clear;
         // Misc
         procedure GoToFirstElement;
         procedure GoToNextElement;
         // Properties
         property Count: integer read FCount;
         property X: single read GetX;
         property Y: single read GetY;
         property Z: single read GetZ;
         property ID: integer read GetID;
   end;

implementation

constructor CVertexList.Create;
begin
   Reset;
end;

destructor CVertexList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CVertexList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
   FCount := 0;
end;

// I/O
procedure CVertexList.LoadState(_State: PVertexItem);
begin
   Active := _State;
end;

function CVertexList.SaveState:PVertexItem;
begin
   Result := Active;
end;


// Add
function CVertexList.Add (_ID : integer; _x,_y,_z: single):integer;
var
   Position,NewPosition : PVertexItem;
   Found: boolean;
begin
   // Ensure that no vertex will repeat.
   Position := Start;
   Found := false;
   while (Position <> nil) and (not Found) do
   begin
      if Position^.x <> _x then
      begin
         Position := Position^.Next;
      end
      else if Position^.y <> _y then
      begin
         Position := Position^.Next;
      end
      else if Position^.z <> _z then
      begin
         Position := Position^.Next;
      end
      else
      begin
         Found := true;
         Result := Position^.ID;
      end;
   end;
   // Add vertex if it is not in the list.
   if not Found then
   begin
      New(NewPosition);
      NewPosition^.ID := _ID;
      NewPosition^.x := _x;
      NewPosition^.y := _y;
      NewPosition^.z := _z;
      NewPosition^.Next := nil;
      inc(FCount);
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
      Result := _ID;
   end;
end;

// Delete
procedure CVertexList.Delete;
var
   Previous : PVertexItem;
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
      dec(FCount);
   end;
end;

procedure CVertexList.Clear;
var
   Garbage : PVertexItem;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      dispose(Garbage);
   end;
   Reset;
end;

// Gets
function CVertexList.GetX: single;
begin
   if Active <> nil then
   begin
      Result := Active^.x;
   end
   else
   begin
      Result := 0;
   end;
end;

function CVertexList.GetY: single;
begin
   if Active <> nil then
   begin
      Result := Active^.y;
   end
   else
   begin
      Result := 0;
   end;
end;

function CVertexList.GetZ: single;
begin
   if Active <> nil then
   begin
      Result := Active^.z;
   end
   else
   begin
      Result := 0;
   end;
end;

function CVertexList.GetID: integer;
begin
   if Active <> nil then
   begin
      Result := Active^.id;
   end
   else
   begin
      Result := -1;
   end;
end;


// Misc
procedure CVertexList.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CVertexList.GoToFirstElement;
begin
   Active := Start;
end;

end.
