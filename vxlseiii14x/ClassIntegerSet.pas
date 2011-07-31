unit ClassIntegerSet;

interface

uses BasicDataTypes;

type
   TGetValueFunction = function (var _Value : integer): boolean of object;
   CIntegerSet = class
      private
         Start,Last,Active : PIntegerItem;
         // Constructors and Destructors
         procedure Initialize;
         // Add
         procedure AddBlindly(_Value : integer);
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Reset;
         // Add
         function Add (_Value : integer): boolean;
         // Delete
         procedure Delete;
         function Remove(_Value: integer): Boolean;
         procedure Clear;
         // Sets
         // Gets
         function GetValue (var _Value : integer): boolean;
         function IsValueInList (_Value : integer): boolean;
         // Copies
         procedure Assign(const _List: CIntegerSet);
         // Misc
         procedure GoToNextElement;
         procedure GoToFirstElement;
   end;

implementation

constructor CIntegerSet.Create;
begin
   Initialize;
end;

destructor CIntegerSet.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CIntegerSet.Initialize;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

procedure CIntegerSet.Reset;
begin
   Clear;
   Initialize;
end;

// Add
procedure CIntegerSet.AddBlindly (_Value : integer);
var
   NewPosition : PIntegerItem;
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
end;

function CIntegerSet.Add (_Value : integer): boolean;
begin
   // First, we check it if we should add this value or not.
   if not IsValueInList(_Value) then
   begin
      // Now, we add the value.
      AddBlindly(_Value);
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

function CIntegerSet.Remove(_Value: integer): Boolean;
var
   Garbage,NextActive : PIntegerItem;
   Found: boolean;
begin
   Garbage := Start;
   Found := false;
   Result := false;
   while not Found do
   begin
      if Garbage <> nil then
      begin
         if Garbage^.Value = _Value then
         begin
            Found := true;
            if Active <> Garbage then
            begin
               NextActive := Active;
               Active := Garbage;
            end
            else
            begin
               NextActive := Start;
            end;
            Delete;
            Active := NextActive;
            Result := true;
         end
         else
            Garbage := Garbage^.Next;
      end
      else
         exit;
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
   Last := nil;
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

// Copies
procedure CIntegerSet.Assign(const _List: CIntegerSet);
var
   Position : PIntegerItem;
begin
   Reset;
   Position := _List.Start;
   while Position <> nil do
   begin
      AddBlindly(Position^.Value);
      if _List.Active = Position then
      begin
         Active := Last;
      end;
      Position := Position^.Next;
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
