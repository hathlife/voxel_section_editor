unit GlobalVars;

interface

uses Palette, HVA, VoxelBank, HVABank, ModelBank, VoxelDocumentBank, Render, Debug,
   SysUtils, TextureBank, ShaderBank, SysInfo, ModelUndoEngine, ActorActionController;

{$INCLUDE source/Global_Conditionals.inc}

var
   VoxelBank : TVoxelBank;
   HVABank : THVABank;
   ModelBank : TModelBank;
   Documents : TVoxelDocumentBank;
   TextureBank : TTextureBank;
   Render : TRender;
   SysInfo: TSysInfo;
   ModelUndoEngine: TModelUndoRedo;
   ModelRedoEngine: TModelUndoRedo;
   ActorController: TActorActionController;
   {$ifdef SPEED_TEST}
   SpeedFile: TDebugFile;
   {$endif}
   {$ifdef MESH_TEST}
   MeshFile: TDebugFile;
   {$endif}
   {$ifdef SMOOTH_TEST}
   SmoothFile: TDebugFile;
   {$endif}
   {$ifdef ORIGAMI_TEST}
   OrigamiFile: TDebugFile;
   {$endif}

implementation

begin
   {$ifdef SPEED_TEST}
   SpeedFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'speedtest.txt');
   {$endif}
   {$ifdef MESH_TEST}
   MeshFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'meshtest.txt');
   {$endif}
   {$ifdef SMOOTH_TEST}
   SmoothFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'smoothtest.txt');
   {$endif}
   {$ifdef ORIGAMI_TEST}
   OrigamiFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'origamitest.txt');
   {$endif}
   SysInfo := TSysInfo.Create;
end.
