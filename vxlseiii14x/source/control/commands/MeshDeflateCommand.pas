unit MeshDeflateCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshDeflateCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshDeflate, GlobalVars, SysUtils;

constructor TMeshDeflateCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Mesh Deflate Method';
   inherited Create(_Actor,_Params);
end;

procedure TMeshDeflateCommand.Execute;
var
   Operation : TMeshDeflate;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshDeflate.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Mesh Deflate for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
