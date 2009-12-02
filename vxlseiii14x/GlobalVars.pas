unit GlobalVars;

interface

uses Palette, HVA, VoxelBank, HVABank, ModelBank, VoxelDocumentBank, Render, Debug,
   SysUtils;

{$INCLUDE Global_Conditionals.inc}

var
   VoxelBank : TVoxelBank;
   HVABank : THVABank;
   ModelBank : TModelBank;
   Documents : TVoxelDocumentBank;
   Render : TRender;
   {$ifdef SPEED_TEST}
   SpeedFile: TDebugFile;
   {$endif}

implementation

begin
   {$ifdef SPEED_TEST}
   SpeedFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'speedtest.txt');
   {$endif}
end.
