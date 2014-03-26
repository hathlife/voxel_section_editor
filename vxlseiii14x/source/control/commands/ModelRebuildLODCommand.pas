unit ModelRebuildLODCommand;

interface

{$INCLUDE source/Global_Conditionals.inc}
{$ifdef VOXEL_SUPPORT}
uses ControllerDataTypes, ActorActionCommandBase, Actor;

type
   TModelRebuildLODCommand = class (TActorActionCommandBase)
      protected
         FQuality: longint;
         FLODID: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;
{$endif}

implementation

{$ifdef VOXEL_SUPPORT}
uses StopWatch, GlobalVars, SysUtils, GLConstants, LODPostProcessing, ModelVxt;

constructor TModelRebuildLODCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Rebuild Model LOD Data';
   ReadAttributes2Int(_Params, FQuality, FLODID, C_QUALITY_CUBED, _Actor.Models[0]^.CurrentLOD);
   inherited Create(_Actor,_Params);
end;

procedure TModelRebuildLODCommand.Execute;
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
   if (FActor.Models[0]^.ModelType = C_MT_VOXEL) then
   begin
      (FActor.Models[0]^ as TModelVxT).Quality := FQuality;
      (FActor.Models[0]^ as TModelVxt).RebuildLOD(FLODID);
      LODProcessor := TLODPostProcessing.Create(FQuality);
      LODProcessor.Execute(FActor.Models[0]^.LOD[FLODID]);
      LODProcessor.Free;
   end;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Model LOD rebuilt in: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;
{$endif}

end.
