unit TextureAtlasExtractorOrigamiParametricCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TTextureAtlasExtractorOrigamiParametricCommand = class (TActorActionCommandBase)
      const
         C_DEFAULT_SIZE = 1024;
      protected
         FSize: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, TextureAtlasExtractorBase, TextureAtlasExtractorOrigamiParametric,
   TextureAtlasExtractorOrigamiGPU, GlobalVars, SysUtils;

constructor TTextureAtlasExtractorOrigamiParametricCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Texture Atlas Extraction Origami Parametric';
   ReadAttributes1Int(_Params, FSize, C_DEFAULT_SIZE);
   inherited Create(_Actor,_Params);
end;

procedure TTextureAtlasExtractorOrigamiParametricCommand.Execute;
var
   TexExtractor : CTextureAtlasExtractorBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   // First, we'll build the texture atlas.
//   if GlobalVars.Render.EnableOpenCL then
//   begin
//      TexExtractor := CTextureAtlasExtractorOrigamiGPU.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
//   end
//   else
//   begin
      TexExtractor := CTextureAtlasExtractorOrigamiParametric.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD]);
//   end;
   TexExtractor.ExecuteWithDiffuseTexture(FSize);
   TexExtractor.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Texture atlas and diffuse texture extraction (origami parametric) for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
