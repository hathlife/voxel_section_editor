unit ControllerObjectCommandList;

interface

uses ControllerObjectCommandItem, ControllerDataTypes;

type
   TControllerObjectCommandList = class
      protected
         FCurrentCommand, FMaxCommand: integer;
         FCommands: array of TControllerObjectCommandItem;
      public
         // Constructors and Destructors.
         constructor Create;
         destructor Destroy; override;
         procedure Clear;

         // Adds & Removes
         procedure Add(_Command: longint; var _Params: TCommandParams);

         // Gets
         function GetCommand(_ID: integer): TControllerObjectCommandItem;
         function GetCurrentCommand: TControllerObjectCommandItem;
         function HasCommandsToBeExecuted: boolean;

         // Properties
         property CurrentCommandID: integer read FCurrentCommand;
         property CurrentCommand: TControllerObjectCommandItem read GetCurrentCommand;
         property Command[_ID: integer]: TControllerObjectCommandItem read GetCommand;
   end;

implementation

uses Math;

constructor TControllerObjectCommandList.Create;
begin
   FCurrentCommand := 0;
   FMaxCommand := -1;
   SetLength(FCommands, 0);
end;

destructor TControllerObjectCommandList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TControllerObjectCommandList.Clear;
var
   i: integer;
begin
   for i := Low(FCommands) to min(FMaxCommand, High(FCommands)) do
   begin
      FCommands[i].Free;
   end;
   SetLength(FCommands, 0);
   FMaxCommand := -1;
   FCurrentCommand := 0;
end;

procedure TControllerObjectCommandList.Add(_Command: longint; var _Params: TCommandParams);
begin
   inc(FMaxCommand);
   if FMaxCommand > High(FCommands) then
   begin
      SetLength(FCommands, High(FCommands) + 50);
   end;
   FCommands[FMaxCommand] := TControllerObjectCommandItem.Create(_Command, _Params);
end;

function TControllerObjectCommandList.GetCommand(_ID: integer): TControllerObjectCommandItem;
begin
   if (_ID >= 0) and (_ID <= FMaxCommand) then
   begin
      Result := FCommands[_ID];
   end
   else
   begin
      Result := nil;
   end;
end;

function TControllerObjectCommandList.GetCurrentCommand: TControllerObjectCommandItem;
begin
   if FMaxCommand >= 0 then
   begin
      Result := FCommands[FCurrentCommand];
      inc(FCurrentCommand);
   end;
end;

function TControllerObjectCommandList.HasCommandsToBeExecuted: boolean;
begin
   Result := FCurrentCommand <= FMaxCommand;
end;

end.
