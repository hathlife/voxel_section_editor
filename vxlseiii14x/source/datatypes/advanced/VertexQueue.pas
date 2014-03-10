unit VertexQueue;

interface

uses BasicMathsTypes;

type
   PVertexData = ^TVertexData;
   TVertexData = record
      X,Y,Z : integer;
      Position: integer;
      Next : PVertexData;
   end;

   CVertexQueue = class
      private
         Start,Last : PVertexData;
         NumItems: integer;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure Add (_x,_y,_z,_Position : integer);
         procedure Delete(var _item: PVertexData);
         // Delete
         procedure Clear;
         // Gets
         function IsEmpty: boolean;
         function GetNumItems: integer;
         function GetVector3i(const _item: PVertexData): TVector3i;
         // Misc
         function GetFirstElement: PVertexData;
         function GetLastElement: PVertexData;
   end;

implementation

constructor CVertexQueue.Create;
begin
   Reset;
end;

destructor CVertexQueue.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CVertexQueue.Reset;
begin
   Start := nil;
   Last := nil;
   NumItems := 0;
end;

// Add
procedure CVertexQueue.Add (_x,_y,_z,_Position : integer);
var
   NewPosition : PVertexData;
begin
   New(NewPosition);
   NewPosition^.x := _x;
   NewPosition^.y := _y;
   NewPosition^.z := _z;
   NewPosition^.Position := _Position;
   NewPosition^.Next := nil;
   if Start <> nil then
   begin
      Last^.Next := NewPosition;
   end
   else
   begin
      Start := NewPosition;
   end;
   Last := NewPosition;
   inc(NumItems);
end;

// Delete
procedure CVertexQueue.Delete(var _item: PVertexData);
var
   Previous : PVertexData;
begin
   if _Item <> nil then
   begin
      Previous := Start;
      if _Item = Start then
      begin
         Start := Start^.Next;
      end
      else
      begin
         while Previous^.Next <> _Item do
         begin
            Previous := Previous^.Next;
         end;
         Previous^.Next := _Item^.Next;
         if _Item = Last then
         begin
            Last := Previous;
         end;
      end;
      Dispose(_Item);
      dec(NumItems);
   end;
end;

procedure CVertexQueue.Clear;
var
   Item,Garbage : PVertexData;
begin
   Item := Start;
   while Item <> nil do
   begin
      Garbage := Item;
      Item := Item^.Next;
      dispose(Garbage);
   end;
end;

// Gets
function CVertexQueue.IsEmpty: boolean;
begin
   Result := (Start = nil);
end;

function CVertexQueue.GetNumItems: integer;
begin
   Result := NumItems;
end;

function CVertexQueue.GetVector3i(const _item: PVertexData): TVector3i;
begin
   if _Item <> nil then
   begin
      Result.X := _Item^.X;
      Result.Y := _Item^.Y;
      Result.Z := _Item^.Z;
   end
   else
   begin
      Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
   end;
end;

// Misc
function CVertexQueue.GetFirstElement: PVertexData;
begin
   Result := Start;
end;

function CVertexQueue.GetLastElement: PVertexData;
begin
   Result := Last;
end;


end.
