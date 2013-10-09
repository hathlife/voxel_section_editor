unit FaceQueue;

interface

type
   PFaceData = ^TFaceData;
   TFaceData = record
      v1,v2,v3 : integer;
      location: integer;
      Next : PFaceData;
   end;

   CFaceQueue = class
      private
         Start,Last : PFaceData;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure Add (_v1,_v2,_v3 : integer);
         procedure Delete(var _item: PFaceData);
         // Delete
         procedure Clear;
         // Gets
         function IsEmpty: boolean;
         // Misc
         function GetFirstElement: PFaceData;
         function GetLastElement: PFaceData;
   end;

implementation

constructor CFaceQueue.Create;
begin
   Reset;
end;

destructor CFaceQueue.Destroy;
begin
   Clear;
   Reset;
   inherited Destroy;
end;

procedure CFaceQueue.Reset;
begin
   Start := nil;
   Last := nil;
end;

// Add
procedure CFaceQueue.Add (_v1,_v2,_v3 : integer);
var
   NewPosition : PFaceData;
begin
   New(NewPosition);
   NewPosition^.V1 := _v1;
   NewPosition^.V2 := _v2;
   NewPosition^.V3 := _v3;
   NewPosition^.location := -1;
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
end;

// Delete
procedure CFaceQueue.Delete(var _item: PFaceData);
var
   Previous : PFaceData;
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
   end;
end;

procedure CFaceQueue.Clear;
var
   Item,Garbage : PFaceData;
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
function CFaceQueue.IsEmpty: boolean;
begin
   Result := (Start = nil);
end;

// Misc
function CFaceQueue.GetFirstElement: PFaceData;
begin
   Result := Start;
end;

function CFaceQueue.GetLastElement: PFaceData;
begin
   Result := Last;
end;


end.
