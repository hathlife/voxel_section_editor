unit MeshSmoothVertexNormalsCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothVertexNormalsCommand = class (TActorActionCommandBase)
      protected
         FDistanceFormula: integer;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSmoothVertexNormals, GlobalVars, SysUtils, DistanceFormulas;

constructor TMeshSmoothVertexNormalsCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Mesh Smooth Vertex Normals Method';
   ReadAttributes1Int(_Params, FDistanceFormula, CDF_LINEAR);
   inherited Create(_Actor,_Params);
end;

procedure TMeshSmoothVertexNormalsCommand.Execute;
var
   Operation : TMeshSmoothVertexNormals;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshSmoothVertexNormals.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.DistanceFunction := GetDistanceFormula(FDistanceFormula);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh vertex normals smooth for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
