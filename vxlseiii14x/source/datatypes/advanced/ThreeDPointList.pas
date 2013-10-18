unit ThreeDPointList;

interface

uses BasicDataTypes;

type
   P3DPosition = ^T3DPosition;
   T3DPosition = record
      x,y,z : integer;
      Next : P3DPosition;
   end;

   TGetPositionFunction = function (var _x,_y,_z : integer): boolean of object;
   TAddPositionMethod = procedure (_x,_y,_z: integer) of object;
   TDeletePositionMethod = procedure of object;
   TGetUniquePositionMethod = function: integer of object;

   C3DPointList = class
      private
         Start,Last,Active : P3DPosition;
         FullList: aint32;
         StartPos,LastPos: integer;
         procedure Reset;
      public
         GetPosition: TGetPositionFunction;
         Add: TAddPositionMethod;
         Delete: TDeletePositionMethod;
         GoToFirstElement: TDeletePositionMethod;
         GoToNextElement: TDeletePositionMethod;
         GetX, GetY, GetZ: TGetUniquePositionMethod;
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // Add
         procedure AddTraditional (_x,_y,_z : integer);
         procedure AddWithFixedRAM (_x,_y,_z : integer);
         procedure DeleteTraditional;
         procedure DeleteFixedRAM;
         // Delete
         procedure Clear;
         procedure ClearFixedRAM;
         // Sets
         procedure UseSmartMemoryManagement(_value: boolean);
         procedure UseFixedRAM(_Value: integer);
         // Gets
         function GetPositionTraditional (var _x,_y,_z : integer): boolean;
         function GetPositionWithDeletion (var _x,_y,_z : integer): boolean;
         function GetPositionWithFixedRAM (var _x,_y,_z : integer): boolean;
         function GetXTraditional: integer;
         function GetXWithFixedRAM: integer;
         function GetYTraditional: integer;
         function GetYWithFixedRAM: integer;
         function GetZTraditional: integer;
         function GetZWithFixedRAM: integer;
         // Misc
         procedure GoToFirstElementTraditional;
         procedure GoToFirstElementFixedRAM;
         procedure GoToNextElementTraditional;
         procedure GoToNextElementFixedRAM;
   end;

implementation

constructor C3DPointList.Create;
begin
   Reset;
   UseSmartMemoryManagement(false);
end;

destructor C3DPointList.Destroy;
begin
   Clear;
   ClearFixedRAM;
   inherited Destroy;
end;

procedure C3DPointList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
end;

// Add
procedure C3DPointList.AddTraditional (_x,_y,_z : integer);
var
   NewPosition : P3DPosition;
begin
   New(NewPosition);
   NewPosition^.x := _x;
   NewPosition^.y := _y;
   NewPosition^.z := _z;
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

procedure C3DPointList.AddWithFixedRAM (_x,_y,_z : integer);
begin
   if (LastPos+2) < High(FullList) then
   begin
      FullList[LastPos] := _x;
      FullList[LastPos+1] := _y;
      FullList[LastPos+2] := _z;
   end;
   inc(LastPos,3);
end;

// Delete
procedure C3DPointList.DeleteTraditional;
var
   Previous : P3DPosition;
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

procedure C3DPointList.DeleteFixedRAM;
begin
   // do nothing.
end;

procedure C3DPointList.Clear;
var
   Garbage : P3DPosition;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      dispose(Garbage);
   end;
end;

procedure C3DPointList.ClearFixedRAM;
begin
   SetLength(FullList,0);
   StartPos := 0;
   LastPos := 0;
end;

// Sets
procedure C3DPointList.UseSmartMemoryManagement(_value: boolean);
begin
   ClearFixedRAM;
   if _Value then
      GetPosition := GetPositionWithDeletion
   else
      GetPosition := GetPositionTraditional;
   Add := AddTraditional;
   Delete := DeleteTraditional;
   GoToFirstElement := GoToFirstElementTraditional;
   GoToNextElement := GoToNextElementTraditional;
   GetX := GetXTraditional;
   GetY := GetYTraditional;
   GetZ := GetZTraditional;
end;

procedure C3DPointList.UseFixedRAM(_Value: integer);
begin
   if (_Value > 0) then
   begin
      Clear;
      SetLength(FullList,_Value*3);
      GetPosition := GetPositionWithFixedRAM;
      Add := AddWithFixedRAM;
      Delete := DeleteFixedRAM;
      GoToFirstElement := GoToFirstElementFixedRAM;
      GoToNextElement := GoToNextElementFixedRAM;
      GetX := GetXWithFixedRAM;
      GetY := GetYWithFixedRAM;
      GetZ := GetZWithFixedRAM;
      StartPos := 0;
      LastPos := 0;
   end;
end;


// Gets
function C3DPointList.GetPositionTraditional (var _x,_y,_z : integer): boolean;
begin
   if Active <> nil then
   begin
      _x := Active^.x;
      _y := Active^.y;
      _z := Active^.z;
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function C3DPointList.GetPositionWithDeletion (var _x,_y,_z : integer): boolean;
begin
   if Start <> nil then
   begin
      _x := Start^.x;
      _y := Start^.y;
      _z := Start^.z;
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

function C3DPointList.GetPositionWithFixedRAM (var _x,_y,_z : integer): boolean;
begin
   if (StartPos < LastPos) and (StartPos < High(FullList)) then
   begin
      _x := FullList[StartPos];
      _y := FullList[StartPos+1];
      _z := FullList[StartPos+2];
      inc(StartPos,3);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

function C3DPointList.GetXTraditional: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.x;
   end;
end;

function C3DPointList.GetXWithFixedRAM: integer;
begin
   if StartPos < LastPos then
   begin
      Result := FullList[StartPos];
   end
   else
   begin
      Result := 0;
   end;
end;

function C3DPointList.GetYTraditional: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.y;
   end;
end;

function C3DPointList.GetYWithFixedRAM: integer;
begin
   if StartPos < LastPos then
   begin
      Result := FullList[StartPos+1];
   end
   else
   begin
      Result := 0;
   end;
end;

function C3DPointList.GetZTraditional: integer;
begin
   Result := 0;
   if Active <> nil then
   begin
      Result := Active^.z;
   end;
end;

function C3DPointList.GetZWithFixedRAM: integer;
begin
   if StartPos < LastPos then
   begin
      Result := FullList[StartPos+2];
   end
   else
   begin
      Result := 0;
   end;
end;

// Misc
procedure C3DPointList.GoToNextElementTraditional;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure C3DPointList.GoToNextElementFixedRAM;
begin
   inc(StartPos,3);
end;

procedure C3DPointList.GoToFirstElementTraditional;
begin
   Active := Start;
end;

procedure C3DPointList.GoToFirstElementFixedRAM;
begin
   StartPos := 0;
end;

end.
