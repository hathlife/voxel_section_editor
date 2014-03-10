unit ModelLoadCommand;

interface

// This command must be executed AFTER the model has been loaded.
// It should post-process the model to achieve the desired quality.

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TModelLoadCommand = class (TActorActionCommandBase)
      protected
         FQuality: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, GlobalVars, SysUtils, GLConstants, LODPostProcessing;

constructor TModelLoadCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Original Model Data';
   ReadAttributes1Int(_Params, FQuality, C_QUALITY_CUBED);
   // Warning: There is no undo here, so no inherited Create.
   FActor := _Actor;
end;

procedure TModelLoadCommand.Execute;
var
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
   LODProcessor: TLODPostProcessing;
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   FActor.Models[0]^.MakeVoxelHVAIndependent;
   LODProcessor := TLODPostProcessing.Create(FQuality);
   LODProcessor.Execute(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   LODProcessor.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Model loading time is: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;


end.
