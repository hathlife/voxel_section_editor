unit MeshConvertQuadsToTrisCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshConvertQuadsToTrisCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshConvertQuadsToTris, GlobalVars, SysUtils;

constructor TMeshConvertQuadsToTrisCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Convert Quads to Triangles';
   inherited Create(_Actor,_Params);
end;

procedure TMeshConvertQuadsToTrisCommand.Execute;
var
   Operation : TMeshConvertQuadsToTris;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshConvertQuadsToTris.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Conversion of quads to triangles in the LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
