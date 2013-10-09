unit BaseSet;

interface

uses BasicDataTypes;

type
   TGetValueFunction = function (var _Value : integer): boolean of object;
   PPointerItem = ^TPointerItem;
   TPointerItem = record
      Data: pointer;
      Next: PPointerItem;
   end;
   CBaseSet = class
      private
         Start,Last,Active : PPointerItem;
         // Constructors and Destructors
         procedure Initialize;
         // Add
         procedure AddBlindly(_Data : pointer);
      protected
         // Sets
         function SetData(const _Data: Pointer):Pointer; virtual;
         // Misc
         function CompareData(const _Data1,_Data2: Pointer):boolean; virtual;
         procedure DisposeData(var _Data:Pointer); virtual;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Reset;
         // Add
         function Add (_Data : pointer): boolean;
         // Delete
         procedure Delete;
         function Remove(_Data: Pointer): Boolean;
         procedure Clear;
         // Gets
         function GetData (var _Data : pointer): boolean;
         function IsDataInList (_Data : pointer): boolean;
         function isEmpty: boolean;
         // Copies
         procedure Assign(const _List: CBaseSet); virtual;
         // Misc
         procedure GoToNextElement;
         procedure GoToFirstElement;
   end;

implementation

constructor CBaseSet.Create;
begin
   Initialize;
end;

destructor CBaseSet.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CBaseSet.Initialize;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

procedure CBaseSet.Reset;
begin
   Clear;
   Initialize;
end;

// Add
procedure CBaseSet.AddBlindly (_Data : pointer);
var
   NewPosition,Position : PPointerItem;
   Found : boolean;
begin
   // Now, we add the value.
   New(NewPosition);
   NewPosition^.Data := SetData(_Data);
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

function CBaseSet.Add (_Data : pointer): boolean;
var
   NewPosition,Position : PPointerItem;
   Found : boolean;
begin
   // First, we check it if we should add this value or not.
   if not IsDataInList(_Data) then
   begin
      // Now, we add the value.
      AddBlindly(_Data);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

// Delete
procedure CBaseSet.Delete;
var
   Previous : PPointerItem;
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

function CBaseSet.Remove(_Data: Pointer): Boolean;
var
   Garbage,NextActive : PPointerItem;
   Found: boolean;
begin
   Garbage := Start;
   Found := false;
   Result := false;
   while not Found do
   begin
      if Garbage <> nil then
      begin
         if CompareData(Garbage^.Data,_Data) then
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

procedure CBaseSet.Clear;
var
   Garbage : PPointerItem;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      DisposeData(Pointer(Garbage));
   end;
   Start := nil;
   Last := nil;
end;

procedure CBaseSet.DisposeData(var _Data:Pointer);
begin
   // Do nothing
end;


// Sets
function CBaseSet.SetData(const _Data: Pointer):Pointer;
begin
   Result := _Data;
end;


// Gets
function CBaseSet.GetData (var _Data : pointer): boolean;
begin
   if Active <> nil then
   begin
      _Data := SetData(Active^.Data);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function CBaseSet.isEmpty: boolean;
begin
   Result := Start = nil;
end;


function CBaseSet.IsDataInList (_Data : pointer): boolean;
var
   Position : PPointerItem;
begin
   // First, we check it if we should add this value or not.
   Position := Start;
   Result := false;
   while (Position <> nil) and (not Result) do
   begin
      if not CompareData(Position^.Data,_Data) then
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
procedure CBaseSet.Assign(const _List: CBaseSet);
var
   Position : PPointerItem;
begin
   Reset;
   Position := _List.Start;
   while Position <> nil do
   begin
      AddBlindly(Position^.Data);
      if _List.Active = Position then
      begin
         Active := Last;
      end;
      Position := Position^.Next;
   end;
end;

// Misc
procedure CBaseSet.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CBaseSet.GoToFirstElement;
begin
   Active := Start;
end;

function CBaseSet.CompareData(const _Data1,_Data2: Pointer):boolean;
begin
   Result := _Data1 = _Data2;
end;



end.
