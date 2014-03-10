unit MeshSetFaceNormalsCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSetFaceNormalsCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshSetFaceNormals, GlobalVars, SysUtils;

constructor TMeshSetFaceNormalsCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Activate Face Normals';
   inherited Create(_Actor,_Params);
end;

procedure TMeshSetFaceNormalsCommand.Execute;
var
   Operation : TMeshSetFaceNormals;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshSetFaceNormals.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Activating face normals in the LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
