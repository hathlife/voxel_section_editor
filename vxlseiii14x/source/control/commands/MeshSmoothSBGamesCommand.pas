unit MeshSmoothSBGamesCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothSBGamesCommand = class (TActorActionCommandBase)
      protected
         FDistanceFormula: integer;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSmoothSBGAMES, DistanceFormulas, GlobalVars, SysUtils;

constructor TMeshSmoothSBGamesCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Mesh Smooth of the SBGames 2010 Method';
   ReadAttributes1Int(_Params, FDistanceFormula, CDF_LINEAR);
   inherited Create(_Actor,_Params);
end;

procedure TMeshSmoothSBGamesCommand.Execute;
var
   MeshSmooth : TMeshSmoothSBGAMES2010;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   MeshSmooth := TMeshSmoothSBGAMES2010.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   MeshSmooth.DistanceFunction := GetDistanceFormula(FDistanceFormula);
   MeshSmooth.Execute;
   MeshSmooth.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh smooth (SBGames 2010) for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
