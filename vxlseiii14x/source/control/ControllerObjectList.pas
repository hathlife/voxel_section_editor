unit ControllerObjectList;

interface

uses ControllerObjectItem, ControllerDataTypes;

type
   TControllerObjectList = class
      protected
         FObjects: array of TControllerObjectItem;

         // Gets
         function GetItem(_ObjectID: TObjectID): TControllerObjectItem;
         function GetObject(_ID: integer): TControllerObjectItem;
         function GetNumItems: integer;

         // Adds
         procedure AddItem(_ObjectID: TObjectID);
      public
         // Constructors and destructors
         constructor Create;
         destructor Destroy; override;
         procedure Clear;

         // Adds and Remove
         procedure RemoveItem(var _Item: TControllerObjectItem);

         // Properties
         property NumItems: integer read GetNumItems;
         property Objects[_ID: integer]: TControllerObjectItem read GetObject;
         property Item[_ObjectID: TObjectID]: TControllerObjectItem read GetItem;
   end;

implementation

// Constructor and Destructors
constructor TControllerObjectList.Create;
begin
   SetLength(FObjects, 0);
end;

destructor TControllerObjectList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TControllerObjectList.Clear;
var
   i: integer;
begin
   for i := Low(FObjects) to High(FObjects) do
   begin
      FObjects[i].Free;
   end;
   SetLength(FObjects, 0);
end;

// Gets
function TControllerObjectList.GetItem(_ObjectID: TObjectID): TControllerObjectItem;
var
   i: integer;
begin
   for i := Low(FObjects) to High(FObjects) do
   begin
      if FObjects[i].ObjectID = _ObjectID then
      begin
         Result := FObjects[i];
         exit;
      end;
   end;
   AddItem(_ObjectID);
   Result := FObjects[High(FObjects)];
end;

function TControllerObjectList.GetNumItems: integer;
begin
   Result := High(FObjects) + 1;
end;

function TControllerObjectList.GetObject(_ID: integer): TControllerObjectItem;
begin
   if (_ID >= 0) and (_ID <= High(FObjects)) then
   begin
      Result := FObjects[_ID];
   end
   else
   begin
      Result := nil;
   end;
end;

// Adds & Remove
procedure TControllerObjectList.AddItem(_ObjectID: TObjectID);
begin
   SetLength(FObjects, High(FObjects) + 2);
   FObjects[High(FObjects)] := TControllerObjectItem.Create(_ObjectID);
end;

procedure TControllerObjectList.RemoveItem(var _Item: TControllerObjectItem);
var
   i: integer;
   found: boolean;
begin
   i := High(FObjects);
   found := false;
   while (not found) and (i >= 0) do
   begin
      if FObjects[i].ObjectID = _Item.ObjectID then
      begin
         found := true;
      end
      else
      begin
         dec(i);
      end;
   end;
   while i < High(FObjects) do
   begin
      FObjects[i] := FObjects[i+1];
      inc(i);
   end;
   _Item.Free;
   SetLength(FObjects, High(FObjects));
end;

end.
