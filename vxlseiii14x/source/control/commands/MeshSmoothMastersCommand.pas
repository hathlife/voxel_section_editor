unit MeshSmoothMastersCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothMastersCommand = class (TActorActionCommandBase)
      protected
         FDistanceFormula: integer;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSmoothMasters, DistanceFormulas, GlobalVars, SysUtils;

constructor TMeshSmoothMastersCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Mesh Smooth (Masters) Method';
   ReadAttributes1Int(_Params, FDistanceFormula, CDF_LINEAR);
   inherited Create(_Actor,_Params);
end;

procedure TMeshSmoothMastersCommand.Execute;
var
   MeshSmooth : TMeshSmoothMasters;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   MeshSmooth := TMeshSmoothMasters.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   MeshSmooth.DistanceFunction := GetDistanceFormula(FDistanceFormula);
   MeshSmooth.Execute;
   MeshSmooth.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh smooth (Masters) for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.

