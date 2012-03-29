unit ClassQuadList;

interface

uses BasicDataTypes, BasicConstants;

type
   CQuadList = class
      private
         Start,Last,Active : PQuadItem;
         FCount: integer;
         procedure Reset;
         function GetV1: integer;
         function GetV2: integer;
         function GetV3: integer;
         function GetV4: integer;
         function GetColour: cardinal;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PQuadItem);
         function SaveState:PQuadItem;
         // Add
         procedure Add (_v1,_v2,_v3,_v4: integer; _Color: Cardinal);
         procedure Delete;
         // Delete
         procedure Clear;
         procedure CleanUpBadQuads;
         // Misc
         procedure GoToFirstElement;
         procedure GoToNextElement;
         procedure GoToLastElement;
         // Properties
         property Count: integer read FCount;
         property V1: integer read GetV1;
         property V2: integer read GetV2;
         property V3: integer read GetV3;
         property V4: integer read GetV4;
         property Colour: cardinal read GetColour;
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
procedure CQuadList.Add (_v1,_v2,_v3,_v4: integer; _Color: Cardinal);
var
   NewPosition : PQuadItem;
begin
   New(NewPosition);
   NewPosition^.v1 := _v1;
   NewPosition^.v2 := _v2;
   NewPosition^.v3 := _v3;
   NewPosition^.v4 := _v4;
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

procedure CQuadList.CleanUpBadQuads;
var
   Previous,Next : PQuadItem;
begin
   Active := Start;
   Previous := nil;
   while Active <> nil do
   begin
      // if vertex 1 is invalid, delete quad.
      if Active^.v1 = C_VMG_NO_VERTEX then
      begin
         Next := Active^.Next;
         if Previous <> nil then
         begin
            Previous^.Next := Next;
         end
         else
         begin
            Start := Next;
         end;
         if Last = Active then
         begin
            Last := Previous;
         end;
         Dispose(Active);
         dec(FCount);
         Active := Next;
      end
      else
      begin
         Previous := Active;
         Active := Active^.Next;
      end;
   end;
   Active := Start;
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

// Gets
function CQuadList.GetV1: integer;
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

function CQuadList.GetV2: integer;
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

function CQuadList.GetV3: integer;
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

function CQuadList.GetV4: integer;
begin
   if Active <> nil then
   begin
      Result := Active^.v4;
   end
   else
   begin
      Result := -1;
   end;
end;

function CQuadList.GetColour: cardinal;
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

procedure CQuadList.GoToLastElement;
begin
   Active := Last;
end;

end.
