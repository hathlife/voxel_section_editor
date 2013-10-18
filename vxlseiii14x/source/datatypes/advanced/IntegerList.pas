unit IntegerList;

interface

uses BasicDataTypes;

type
   TGetValueFunction = function (var _Value : integer): boolean of object;
   TAddValueMethod = procedure (_Value: integer) of object;
   TDeleteValueMethod = procedure of object;
   CIntegerList = class
      private
         Start,Last,Active : PIntegerItem;
         FullList: aint32;
         StartPos,LastPos: integer;
         procedure Reset;
      public
         GetValue: TGetValueFunction;
         Add: TAddValueMethod;
         Delete: TDeleteValueMethod;
         GoToFirstElement: TDeleteValueMethod;
         GoToNextElement: TDeleteValueMethod;
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PIntegerItem);
         procedure LoadStateFixedRAM(_State: integer);
         function SaveState:PIntegerItem;
         function SaveStateFixedRAM:integer;
         // Add
         procedure AddTraditional (_Value : integer);
         procedure AddWithFixedRAM (_Value : integer);
         procedure DeleteTraditional;
         procedure DeleteFixedRAM;
         // Delete
         procedure Clear;
         procedure ClearFixedRAM;
         // Sets
         procedure UseSmartMemoryManagement(_Value: boolean);
         procedure UseFixedRAM(_Value: integer);
         // Gets
         function GetValueTraditional (var _Value : integer): boolean;
         function GetValueWithDeletion (var _Value : integer): boolean;
         function GetValueWithFixedRAM (var _Value : integer): boolean;
         // Misc
         procedure GoToFirstElementTraditional;
         procedure GoToFirstElementFixedRAM;
         procedure GoToNextElementTraditional;
         procedure GoToNextElementFixedRAM;
   end;

implementation

constructor CIntegerList.Create;
begin
   Reset;
   UseSmartMemoryManagement(false);
end;

destructor CIntegerList.Destroy;
begin
   Clear;
   ClearFixedRAM;
   inherited Destroy;
end;

procedure CIntegerList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

// I/O
procedure CIntegerList.LoadState(_State: PIntegerItem);
begin
   Active := _State;
end;

procedure CIntegerList.LoadStateFixedRAM(_State: integer);
begin
   StartPos := _State;
end;

function CIntegerList.SaveState:PIntegerItem;
begin
   Result := Active;
end;

function CIntegerList.SaveStateFixedRAM:integer;
begin
   Result := StartPos;
end;


// Add
procedure CIntegerList.AddTraditional (_Value : integer);
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

procedure CIntegerList.AddWithFixedRAM (_Value : integer);
begin
   if LastPos <= High(FullList) then
   begin
      FullList[LastPos] := _Value;
   end;
   inc(LastPos);
end;

// Delete
procedure CIntegerList.DeleteTraditional;
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

procedure CIntegerList.DeleteFixedRAM;
begin
   // do nothing.
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
   Reset;
end;

procedure CIntegerList.ClearFixedRAM;
begin
   SetLength(FullList,0);
   StartPos := 0;
   LastPos := 0;
end;

// Sets
procedure CIntegerList.UseSmartMemoryManagement(_value: boolean);
begin
   ClearFixedRAM;
   if _Value then
      GetValue := GetValueWithDeletion
   else
      GetValue := GetValueTraditional;
   Add := AddTraditional;
   Delete := DeleteTraditional;
   GoToFirstElement := GoToFirstElementTraditional;
   GoToNextElement := GoToNextElementTraditional;
end;

procedure CIntegerList.UseFixedRAM(_Value: integer);
begin
   if (_Value > 0) then
   begin
      Clear;
      SetLength(FullList,_Value);
      GetValue := GetValueWithFixedRAM;
      Add := AddWithFixedRAM;
      Delete := DeleteFixedRAM;
      GoToFirstElement := GoToFirstElementFixedRAM;
      GoToNextElement := GoToNextElementFixedRAM;
      StartPos := 0;
      LastPos := 0;
   end;
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

function CIntegerList.GetValueWithFixedRAM (var _Value : integer): boolean;
begin
   if (StartPos < LastPos) and (StartPos <= High(FullList)) then
   begin
      _Value := FullList[StartPos];
      inc(StartPos);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

// Misc
procedure CIntegerList.GoToNextElementTraditional;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CIntegerList.GoToNextElementFixedRAM;
begin
   inc(StartPos);
end;

procedure CIntegerList.GoToFirstElementTraditional;
begin
   Active := Start;
end;

procedure CIntegerList.GoToFirstElementFixedRAM;
begin
   StartPos := 0;
end;

end.
