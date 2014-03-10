unit MeshSmoothGaussianCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothGaussianCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSmoothGaussian, GlobalVars, SysUtils;

constructor TMeshSmoothGaussianCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Mesh Smooth Gaussian Method';
   inherited Create(_Actor,_Params);
end;

procedure TMeshSmoothGaussianCommand.Execute;
var
   MeshSmooth : TMeshSmoothGaussian;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   MeshSmooth := TMeshSmoothGaussian.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   MeshSmooth.Execute;
   MeshSmooth.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh smooth Gaussian for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
