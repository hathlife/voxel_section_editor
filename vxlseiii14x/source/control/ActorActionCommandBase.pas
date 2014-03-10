unit ActorActionCommandBase;

interface

uses ControllerDataTypes, CommandBase, Actor, Classes;

type
   TActorActionCommandBase = class (TCommandBase)
      protected
         FActor: TActor;     // do not free it in the destroy!
         FCommandName: string;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); virtual;
   end;

implementation

uses GlobalVars;

constructor TActorActionCommandBase.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FActor := _Actor;
   GlobalVars.ModelUndoEngine.Add(FActor.Models[0]^,FCommandName);
end;



end.

