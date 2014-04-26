unit TextureAtlasExtractorOrigamiParametricDCCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TTextureAtlasExtractorOrigamiParametricDCCommand = class (TActorActionCommandBase)
      const
         C_DEFAULT_SIZE = 1024;
      protected
         FSize: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, TextureAtlasExtractorBase, TextureAtlasExtractorOrigamiParametricDC,
   TextureAtlasExtractorOrigamiGPU, GlobalVars, SysUtils;

constructor TTextureAtlasExtractorOrigamiParametricDCCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Texture Atlas Extraction Origami Parametric DC';
   ReadAttributes1Int(_Params, FSize, C_DEFAULT_SIZE);
   inherited Create(_Actor,_Params);
end;

procedure TTextureAtlasExtractorOrigamiParametricDCCommand.Execute;
var
   TexExtractor : CTextureAtlasExtractorBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   TexExtractor := CTextureAtlasExtractorOrigamiParametricDC.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
   TexExtractor.ExecuteWithDiffuseTexture(FSize);
   TexExtractor.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Texture atlas and diffuse texture extraction (origami parametric distortion control) for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
