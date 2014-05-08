unit BaseController;

interface

uses ControllerDataTypes, CommandBase, ControllerObjectList, ControllerObjectItem;

type
   TBaseController = class
      protected
         procedure SendCommandNoParams(_CommandType: integer; _ObjectID: TObjectID);
         procedure SendCommand1Int(_CommandType: integer; _ObjectID: TObjectID; _Integer1: integer);
         procedure SendCommand2Int(_CommandType: integer; _ObjectID: TObjectID; _Integer1, _Integer2: integer);
         procedure SendCommand3Int(_CommandType: integer; _ObjectID: TObjectID; _Integer1, _Integer2, _Integer3: integer);
         procedure SendCommand1Int1Single(_CommandType: integer; _ObjectID: TObjectID; _Integer1: integer; _Single1: single);
         procedure SendCommand3Int1Single(_CommandType: integer; _ObjectID: TObjectID; _Integer1, _Integer2, _Integer3: integer; _Single1: single);
         procedure SendCommand1Bool1Single(_CommandType: integer; _ObjectID: TObjectID; _Boolean1: boolean; _Single1: single);

         // The Send Command declaration.
         procedure SendCommand(_CommandType: integer; _ObjectID: TObjectID; _Parameters: TCommandParams); virtual;

         // Process and execute commands.
         procedure ProcessCommands(_Item: TControllerObjectItem);
         procedure ProcessAllCommands;
         procedure ExecuteCommand(_CommandType: integer; _ObjectID: TObjectID; _Parameters: TCommandParams); virtual; abstract;

         // Others
         procedure TerminateObject(_Item: TControllerObjectItem); overload; virtual;
      public
         Objects: TControllerObjectList;

         // Constructors and Destructors
         constructor Create; virtual;
         destructor Destroy; override;

         // Object related procedures
         procedure TerminateObject(_ObjectID: TObjectID); overload;
   end;

implementation

uses Classes, ControllerObjectCommandItem;

constructor TBaseController.Create;
begin
   Objects := TControllerObjectList.Create;
end;

destructor TBaseController.Destroy;
begin
   Objects.Free;
   inherited Destroy;
end;

procedure TBaseController.SendCommandNoParams(_CommandType: integer; _ObjectID: TObjectID);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   SendCommand(_CommandType, _ObjectID, Params^);
end;

procedure TBaseController.SendCommand1Int(_CommandType: integer; _ObjectID: TObjectID; _Integer1: integer);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   Params^.Write(_Integer1, sizeof(longint));
   SendCommand(_CommandType, _ObjectID, Params^);
end;

procedure TBaseController.SendCommand2Int(_CommandType: integer; _ObjectID: TObjectID; _Integer1, _Integer2: integer);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   Params^.Write(_Integer1, sizeof(longint));
   Params^.Write(_Integer2, sizeof(longint));
   SendCommand(_CommandType, _ObjectID, Params^);
end;

procedure TBaseController.SendCommand3Int(_CommandType: integer; _ObjectID: TObjectID; _Integer1, _Integer2, _Integer3: integer);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   Params^.Write(_Integer1, sizeof(longint));
   Params^.Write(_Integer2, sizeof(longint));
   Params^.Write(_Integer3, sizeof(longint));
   SendCommand(_CommandType, _ObjectID, Params^);
end;

procedure TBaseController.SendCommand1Int1Single(_CommandType: integer; _ObjectID: TObjectID; _Integer1: integer; _Single1: single);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   Params^.Write(_Integer1, sizeof(longint));
   Params^.Write(_Single1, sizeof(single));
   SendCommand(_CommandType, _ObjectID, Params^);
end;

procedure TBaseController.SendCommand3Int1Single(_CommandType: integer; _ObjectID: TObjectID; _Integer1, _Integer2, _Integer3: integer; _Single1: single);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   Params^.Write(_Integer1, sizeof(longint));
   Params^.Write(_Integer2, sizeof(longint));
   Params^.Write(_Integer3, sizeof(longint));
   Params^.Write(_Single1, sizeof(single));
   SendCommand(_CommandType, _ObjectID, Params^);
   // Note: do not free memory of Params until I figure out how it will be stored.
end;

procedure TBaseController.SendCommand1Bool1Single(_CommandType: integer; _ObjectID: TObjectID; _Boolean1: boolean; _Single1: single);
var
   Params: PCommandParams;
begin
   new(Params);
   Params^ := TMemoryStream.Create;
   Params^.Seek(0, soFromBeginning);
   Params^.Write(_Boolean1, sizeof(boolean));
   Params^.Write(_Single1, sizeof(single));
   SendCommand(_CommandType, _ObjectID, Params^);
end;

procedure TBaseController.SendCommand(_CommandType: integer; _ObjectID: TObjectID; _Parameters: TCommandParams);
var
   Item: TControllerObjectItem;
begin
   // Let's find the object first.
   Item := Objects.Item[_ObjectID];

   // Now we add the command to the list.
   Item.CommandList.Add(_CommandType, _Parameters);

   // Here we will have a condition to figure out if this is an online resource
   // or if it is working offline. It will only process commands for the offline
   // case
   ProcessCommands(Item);
end;

procedure TBaseController.ProcessCommands(_Item: TControllerObjectItem);
var
   CurrentCommand: TControllerObjectCommandItem;
begin
   while _Item.CommandList.HasCommandsToBeExecuted do
   begin
      CurrentCommand := _Item.CommandList.GetCurrentCommand;
      ExecuteCommand(CurrentCommand.Command, _Item.ObjectID, CurrentCommand.Params);
   end;
end;

procedure TBaseController.ProcessAllCommands;
var
   i, maxi: integer;
begin
   maxi := Objects.NumItems - 1;
   for i := 0 to maxi do
   begin
      ProcessCommands(Objects.Objects[i]);
   end;
end;

procedure TBaseController.TerminateObject(_ObjectID: TObjectID);
var
   Item: TControllerObjectItem;
begin
   Item := Objects.Item[_ObjectID];

   TerminateObject(Item);
end;

procedure TBaseController.TerminateObject(_Item: TControllerObjectItem);
begin
   Objects.RemoveItem(_Item);
end;

end.
