unit MeshOptimization2009Command;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshOptmization2009Command = class (TActorActionCommandBase)
      protected
         FIgnoreColours: boolean;
         FAngle: single;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshOptimization2009, GlobalVars, SysUtils;

constructor TMeshOptmization2009Command.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Mesh Optimization 2009 Method';
   ReadAttributes1Bool1Single(_Params, FIgnoreColours, FAngle, false, 1);
   inherited Create(_Actor,_Params);
end;

procedure TMeshOptmization2009Command.Execute;
var
   MeshOptimization : TMeshOptimization2009;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   MeshOptimization := TMeshOptimization2009.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   MeshOptimization.IgnoreColors := FIgnoreColours;
   MeshOptimization.Angle := FAngle;
   MeshOptimization.Execute;
   MeshOptimization.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh optimization (2009) for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
