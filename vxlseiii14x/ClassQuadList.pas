unit ClassQuadList;

interface

uses BasicDataTypes;

type
   CQuadList = class
      private
         Start,Last,Active : PQuadItem;
         FCount: integer;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PQuadItem);
         function SaveState:PQuadItem;
         // Add
         procedure Add (_v1,_v2,_v3,_v4: integer);
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

constructor CQuadList.Create;
begin
   Reset;
end;

destructor CQuadList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CQuadList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
   FCount := 0;
end;

// I/O
procedure CQuadList.LoadState(_State: PQuadItem);
begin
   Active := _State;
end;

function CQuadList.SaveState:PQuadItem;
begin
   Result := Active;
end;


// Add
procedure CQuadList.Add (_v1,_v2,_v3,_v4: integer);
var
   NewPosition : PQuadItem;
begin
   New(NewPosition);
   NewPosition^.v1 := _v1;
   NewPosition^.v2 := _v2;
   NewPosition^.v3 := _v3;
   NewPosition^.v4 := _v4;
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
procedure CQuadList.Delete;
var
   Previous : PQuadItem;
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

procedure CQuadList.Clear;
var
   Garbage : PQuadItem;
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
procedure CQuadList.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CQuadList.GoToFirstElement;
begin
   Active := Start;
end;

end.
