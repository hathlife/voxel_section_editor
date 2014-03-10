unit TextureAtlasExtractorCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor, GLConstants;

{$INCLUDE source/Global_Conditionals.inc}

type
   TTextureAtlasExtractorCommand = class (TActorActionCommandBase)
      const
         C_DEFAULT_ANGLE = C_TEX_MIN_ANGLE;
         C_DEFAULT_SIZE = 1024;
      protected
         FAngle: single;
         FSize: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, TextureAtlasExtractorBase, TextureAtlasExtractor, GlobalVars,
   SysUtils;

constructor TTextureAtlasExtractorCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Texture Atlas Extraction SBGames 2010';
   ReadAttributes1Int1Single(_Params, FSize, FAngle, C_DEFAULT_SIZE, C_DEFAULT_ANGLE);
   inherited Create(_Actor,_Params);
end;

procedure TTextureAtlasExtractorCommand.Execute;
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
   TexExtractor := CTextureAtlasExtractor.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD],FAngle);
   TexExtractor.ExecuteWithDiffuseTexture(FSize);
   TexExtractor.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Texture atlas and diffuse texture extraction for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.
