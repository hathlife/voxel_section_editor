unit MeshSetVertexColoursCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSetVertexColoursCommand = class (TActorActionCommandBase)
      protected
         FDistanceFormula: integer;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSetVertexColours, GlobalVars, SysUtils,
   DistanceFormulas;

constructor TMeshSetVertexColoursCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Activate Vertex Colors';
   ReadAttributes1Int(_Params, FDistanceFormula, CDF_LINEAR);
   inherited Create(_Actor,_Params);
end;

procedure TMeshSetVertexColoursCommand.Execute;
var
   Operation : TMeshSetVertexColours;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshSetVertexColours.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.DistanceFunction := GetDistanceFormula(FDistanceFormula);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Activating vertex colors in the LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
