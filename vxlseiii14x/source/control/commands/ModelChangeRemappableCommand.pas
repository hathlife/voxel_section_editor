unit ModelChangeRemappableCommand;

interface

{$INCLUDE source/Global_Conditionals.inc}
{$ifdef VOXEL_SUPPORT}

uses ControllerDataTypes, ActorActionCommandBase, Actor, Graphics;

type
   TModelChangeRemappableCommand = class (TActorActionCommandBase)
      protected
         FQuality: longint;
         FColour: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;
{$endif}

implementation

{$ifdef VOXEL_SUPPORT}

uses StopWatch, GlobalVars, SysUtils, GLConstants, LODPostProcessing, ModelVxt;

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
   if FActor.Models[0].ModelType = C_MT_VOXEL then
   begin
      FActor.Models[0]^.ChangeRemappable(FColour);
      (FActor.Models[0]^ as TModelVxt).Quality := FQuality;
      (FActor.Models[0]^ as TModelVxt).RebuildModel;
      LODProcessor := TLODPostProcessing.Create(FQuality);
      for i := Low(FActor.Models[0]^.LOD) to High(FActor.Models[0]^.LOD) do
      begin
         LODProcessor.Execute(FActor.Models[0]^.LOD[i]);
      end;
      LODProcessor.Free;
   end;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Model rebuilt in: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

{$endif}
end.
