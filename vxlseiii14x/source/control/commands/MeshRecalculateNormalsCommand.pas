unit MeshRecalculateNormalsCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshRecalculateNormalsCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshRecalculateNormals, GlobalVars, SysUtils;

constructor TMeshRecalculateNormalsCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Recalculate normal vectors';
   inherited Create(_Actor,_Params);
end;

procedure TMeshRecalculateNormalsCommand.Execute;
var
   Operation : TMeshRecalculateNormals;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshRecalculateNormals.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Recalculation from all normal vectors from the LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
