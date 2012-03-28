unit ClassTriangleList;

interface

uses BasicDataTypes, BasicConstants;

type
   CTriangleList = class
      private
         Start,Last,Active : PTriangleItem;
         FCount: integer;
         procedure Reset;
         function GetV1: integer;
         function GetV2: integer;
         function GetV3: integer;
         function GetColour: cardinal;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PTriangleItem);
         function SaveState:PTriangleItem;
         // Add
         procedure Add (_v1,_v2,_v3: integer; _Color: Cardinal);
         // Delete
         procedure Delete;
         procedure CleanUpBadTriangles;
         procedure Clear;
         // Misc
         procedure GoToFirstElement;
         procedure GoToLastElement;
         procedure GoToNextElement;
         // Properties
         property Count: integer read FCount;
         property V1: integer read GetV1;
         property V2: integer read GetV2;
         property V3: integer read GetV3;
         property Colour: cardinal read GetColour;
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

// Gets
function CTriangleList.GetV1: integer;
begin
   if Active <> nil then
   begin
      Result := Active^.v1;
   end
   else
   begin
      Result := -1;
   end;
end;

function CTriangleList.GetV2: integer;
begin
   if Active <> nil then
   begin
      Result := Active^.v2;
   end
   else
   begin
      Result := -1;
   end;
end;

function CTriangleList.GetV3: integer;
begin
   if Active <> nil then
   begin
      Result := Active^.v3;
   end
   else
   begin
      Result := -1;
   end;
end;

function CTriangleList.GetColour: cardinal;
begin
   if Active <> nil then
   begin
      Result := Active^.color;
   end
   else
   begin
      Result := 0;
   end;
end;

// Add
procedure CTriangleList.Add (_v1,_v2,_v3: integer; _Color: Cardinal);
var
   NewPosition : PTriangleItem;
begin
   New(NewPosition);
   NewPosition^.v1 := _v1;
   NewPosition^.v2 := _v2;
   NewPosition^.v3 := _v3;
   NewPosition^.Color := _Color;
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

procedure CTriangleList.CleanUpBadTriangles;
var
   Previous : PTriangleItem;
begin
   Active := Start;
   Previous := nil;
   while Active <> nil do
   begin
      // if vertex 1 is invalid, delete quad.
      if Active^.v1 = C_VMG_NO_VERTEX then
      begin
         if Previous <> nil then
         begin
            Previous^.Next := Active^.Next;
         end
         else
         begin
            Start := Active^.Next;
         end;
         if Last = Active then
         begin
            Last := Previous;
         end;
         Dispose(Active);
         dec(FCount);
         Active := Previous^.Next;
      end
      else
      begin
         Previous := Active;
         Active := Active^.Next;
      end;
   end;
   Active := Start;
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

procedure CTriangleList.GoToLastElement;
begin
   Active := Last;
end;

end.
