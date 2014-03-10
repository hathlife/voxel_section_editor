unit NormalMapTextureGeneratorCommand;

interface

uses ControllerDataTypes, ActorActionCommandBase, Actor;

{$INCLUDE source/Global_Conditionals.inc}

type
   TNormalMapTextureGeneratorCommand = class (TActorActionCommandBase)
      const
         C_DEFAULT_SIZE = 1024;
         C_DEFAULT_MATERIAL = 0;
         C_DEFAULT_TEXTURE = 0;
      protected
         FSize: longint;
         FMaterialID: longint;
         FTextureID: longint;
      public
         constructor Create(var _Actor: TActor; var _Params: TCommandParams); override;
         procedure Execute; override;
   end;

implementation

uses StopWatch, TextureGeneratorBase, NormalMapTextureGenerator, GlobalVars,
   SysUtils;

constructor TNormalMapTextureGeneratorCommand.Create(var _Actor: TActor; var _Params: TCommandParams);
begin
   FCommandName := 'Normal Map Texture Generation';
   ReadAttributes3Int(_Params, FSize, FMaterialID, FTextureID, C_DEFAULT_SIZE, C_DEFAULT_MATERIAL, C_DEFAULT_TEXTURE);
   inherited Create(_Actor,_Params);
end;

procedure TNormalMapTextureGeneratorCommand.Execute;
var
   TexGenerator : CTextureGeneratorBase;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   TexGenerator := CNormalMapTextureGenerator.Create(FActor.Models[0]^.LOD[FActor.Models[0]^.CurrentLOD],FSize,FMaterialID,FTextureID);
   TexGenerator.Execute();
   TexGenerator.Free;
   {$ifdef SPEED_TEST}
   StopWatch.Stop;
   GlobalVars.SpeedFile.Add('Normal map texture generation for LOD takes: ' + FloatToStr(StopWatch.ElapsedNanoseconds) + ' nanoseconds.');
   StopWatch.Free;
   {$endif}
end;

end.

