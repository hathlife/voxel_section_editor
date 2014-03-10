unit BumpMapTextureGeneratorCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor, GLConstants;

{$INCLUDE source/Global_Conditionals.inc}

type
   TBumpMapTextureGeneratorCommand = class (TActorActionCommandBase)
      const
         C_DEFAULT_SIZE = 1024;
         C_DEFAULT_MATERIAL = 0;
         C_DEFAULT_TEXTURE = 0;
         C_DEFAULT_SCALE = C_BUMP_DEFAULTSCALE;
      protected
         FSize: longint;
         FMaterialID: longint;
         FTextureID: longint;
         FScale: single;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, TextureGeneratorBase, BumpMapTextureGenerator, GlobalVars,
   SysUtils;

constructor TBumpMapTextureGeneratorCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Bump Map Texture Generation';
   ReadAttributes3Int1Single(_Params,FSize,FMaterialID,FTextureID,FScale,C_DEFAULT_SIZE,C_DEFAULT_MATERIAL,C_DEFAULT_TEXTURE,C_DEFAULT_SCALE);
   inherited Create(_Actor,_Params);
end;

procedure TBumpMapTextureGeneratorCommand.Execute;
var
   TexGenerator : CTextureGeneratorBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   TexGenerator := CBumpMapTextureGenerator.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD],FSize,FMaterialID,FTextureID,FScale);
   TexGenerator.Execute();
   TexGenerator.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Bump map texture generation for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.

