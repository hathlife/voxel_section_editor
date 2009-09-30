unit ClassIntegerList;

interface

uses BasicDataTypes;

type
   TGetValueFunction = function (var _Value : integer): boolean of object;
   CIntegerList = class
      private
         Start,Last,Active : PIntegerItem;
         procedure Reset;
      public
         GetValue: TGetValueFunction;
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure Add (_Value : integer);
         procedure Delete;
         // Delete
         procedure Clear;
         // Sets
         procedure UseSmartMemoryManagement(_Value: boolean);
         // Gets
         function GetValueTraditional (var _Value : integer): boolean;
         function GetValueWithDeletion (var _Value : integer): boolean;
         // Misc
         procedure GoToNextElement;
   end;

implementation

constructor CIntegerList.Create;
begin
   GetValue := GetValueTraditional;
   Reset;
end;

destructor CIntegerList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CIntegerList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

// Add
procedure CIntegerList.Add (_Value : integer);
var
   NewPosition : PIntegerItem;
begin
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

// Delete
procedure CIntegerList.Delete;
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

procedure CIntegerList.Clear;
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
procedure CIntegerList.UseSmartMemoryManagement(_value: boolean);
begin
   if _Value then
      GetValue := GetValueWithDeletion
   else
      GetValue := GetValueTraditional;
end;


// Gets
function CIntegerList.GetValueTraditional (var _Value : integer): boolean;
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

function CIntegerList.GetValueWithDeletion (var _Value : integer): boolean;
begin
   if Start <> nil then
   begin
      _Value := Start^.Value;
      Active := Start;
      Start := Start^.Next;
      Dispose(Active);
      Active := Start;
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

// Misc
procedure CIntegerList.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

end.
