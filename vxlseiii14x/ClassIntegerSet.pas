unit ClassIntegerSet;

interface

uses BasicDataTypes;

type
   TGetValueFunction = function (var _Value : integer): boolean of object;
   CIntegerSet = class
      private
         Start,Last,Active : PIntegerItem;
         procedure Reset;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         function Add (_Value : integer): boolean;
         procedure Delete;
         // Delete
         procedure Clear;
         // Sets
         // Gets
         function GetValue (var _Value : integer): boolean;
         function IsValueInList (_Value : integer): boolean;
         // Misc
         procedure GoToNextElement;
         procedure GoToFirstElement;
   end;

implementation

constructor CIntegerSet.Create;
begin
   Reset;
end;

destructor CIntegerSet.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CIntegerSet.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

// Add
function CIntegerSet.Add (_Value : integer): boolean;
var
   NewPosition,Position : PIntegerItem;
   Found : boolean;
begin
   // First, we check it if we should add this value or not.
   if not IsValueInList(_Value) then
   begin
      // Now, we add the value.
      New(NewPosition);
      NewPosition^.Value := _Value;
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
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

// Delete
procedure CIntegerSet.Delete;
var
   Previous : PIntegerItem;
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

procedure CIntegerSet.Clear;
var
   Garbage : PIntegerItem;
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


// Gets
function CIntegerSet.GetValue (var _Value : integer): boolean;
begin
   if Active <> nil then
   begin
      _Value := Active^.Value;
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function CIntegerSet.IsValueInList (_Value : integer): boolean;
var
   Position : PIntegerItem;
begin
   // First, we check it if we should add this value or not.
   Position := Start;
   Result := false;
   while (Position <> nil) and (not Result) do
   begin
      if Position^.Value <> _Value then
      begin
         Position := Position^.Next;
      end
      else
      begin
         Result := true;
      end;
   end;
end;

// Misc
procedure CIntegerSet.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CIntegerSet.GoToFirstElement;
begin
   Active := Start;
end;


end.
