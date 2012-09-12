unit GlobalVars;

interface

uses Palette, HVA, VoxelBank, HVABank, ModelBank, VoxelDocumentBank, Render, Debug,
   SysUtils, TextureBank, ShaderBank, SysInfo;

{$INCLUDE Global_Conditionals.inc}

var
   VoxelBank : TVoxelBank;
   HVABank : THVABank;
   ModelBank : TModelBank;
   Documents : TVoxelDocumentBank;
   TextureBank : TTextureBank;
   Render : TRender;
   SysInfo: TSysInfo;
   {$ifdef SPEED_TEST}
   SpeedFile: TDebugFile;
   {$endif}
   {$ifdef MESH_TEST}
   MeshFile: TDebugFile;
   {$endif}

implementation

begin
   {$ifdef SPEED_TEST}
   SpeedFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'speedtest.txt');
   {$endif}
   {$ifdef MESH_TEST}
   MeshFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'meshtest.txt');
   {$endif}
   SysInfo := TSysInfo.Create;
end.
