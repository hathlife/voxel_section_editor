unit MeshConvertQuadsTo48TrisCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshConvertQuadsTo48TrisCommand = class (TActorActionCommandBase)
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, MeshConvertQuadsTo48Tris, GlobalVars, SysUtils;

constructor TMeshConvertQuadsTo48TrisCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Convert Quads to Triangles';
   inherited Create(_Actor,_Params);
end;

procedure TMeshConvertQuadsTo48TrisCommand.Execute;
var
   Operation : TMeshConvertQuadsTo48Tris;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   Operation := TMeshConvertQuadsTo48Tris.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   Operation.Execute;
   Operation.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Conversion of quads to triangles (4-8 style) in the LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
