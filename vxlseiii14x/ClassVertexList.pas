unit ClassVertexList;

interface

uses BasicDataTypes;

type
   CVertexList = class
      private
         Start,Last,Active : PVertexItem;
         FCount: integer;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PVertexItem);
         function SaveState:PVertexItem;
         // Add
         procedure Add (_ID : integer; _x,_y,_z: single);
         procedure Delete;
         // Delete
         procedure Clear;
         // Misc
         procedure GoToFirstElement;
         procedure GoToNextElement;
         // Properties
         property Count: integer read FCount;
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
procedure CVertexList.Add (_ID : integer; _x,_y,_z: single);
var
   NewPosition : PVertexItem;
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
