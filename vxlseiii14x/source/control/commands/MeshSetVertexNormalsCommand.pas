unit MeshSetVertexNormalsCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSetVertexNormalsCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSetVertexNormals, GlobalVars, SysUtils;

constructor TMeshSetVertexNormalsCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Activate Vertex Normals';
   inherited Create(_Actor,_Params);
end;

procedure TMeshSetVertexNormalsCommand.Execute;
var
   Operation : TMeshSetVertexNormals;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshSetVertexNormals.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Activating vertex normals in the LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
