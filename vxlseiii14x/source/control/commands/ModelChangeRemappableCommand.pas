unit ModelChangeRemappableCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor, Graphics;

{$INCLUDE source/Global_Conditionals.inc}

type
   TModelChangeRemappableCommand = class (TActorActionCommandBase)
      protected
         FQuality: longint;
         FColour: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, GlobalVars, SysUtils, GLConstants, LODPostProcessing;

constructor TModelChangeRemappableCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Rebuild Model Data';
   ReadAttributes2Int(_Params, FQuality, FColour, C_QUALITY_CUBED, $FF);
   inherited Create(_Actor,_Params);
end;

procedure TModelChangeRemappableCommand.Execute;
var
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
   LODProcessor: TLODPostProcessing;
   i: integer;
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   FActor.Models[0]^.ChangeRemappable(FColour);
   FActor.Models[0]^.Quality := FQuality;
   FActor.Models[0]^.RebuildModel;
   LODProcessor := TLODPostProcessing.Create(FQuality);
   for i := Low(FActor.Models[0]^.LOD) to High(FActor.Models[0]^.LOD) do
   begin
      LODProcessor.Execute(FActor.Models[0]^.LOD[i]);
   end;
   LODProcessor.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Model rebuilt in: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
