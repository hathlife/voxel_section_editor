unit ClassTriangleList;

interface

uses BasicDataTypes;

type
   CTriangleList = class
      private
         Start,Last,Active : PTriangleItem;
         FCount: integer;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PTriangleItem);
         function SaveState:PTriangleItem;
         // Add
         procedure Add (_v1,_v2,_v3: integer);
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

constructor CTriangleList.Create;
begin
   Reset;
end;

destructor CTriangleList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTriangleList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
   FCount := 0;
end;

// I/O
procedure CTriangleList.LoadState(_State: PTriangleItem);
begin
   Active := _State;
end;

function CTriangleList.SaveState:PTriangleItem;
begin
   Result := Active;
end;


// Add
procedure CTriangleList.Add (_v1,_v2,_v3: integer);
var
   NewPosition : PTriangleItem;
begin
   New(NewPosition);
   NewPosition^.v1 := _v1;
   NewPosition^.v2 := _v2;
   NewPosition^.v3 := _v3;
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
procedure CTriangleList.Delete;
var
   Previous : PTriangleItem;
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

procedure CTriangleList.Clear;
var
   Garbage : PTriangleItem;
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
procedure CTriangleList.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CTriangleList.GoToFirstElement;
begin
   Active := Start;
end;

end.
