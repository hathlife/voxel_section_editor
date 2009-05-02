unit VoxelDocumentItem;

interface

uses Voxel, HVA, Palette, BasicDataTypes, BasicFunctions, SysUtils;

type
   TVoxelDocumentItem = class
   private
      // Misc
      function GetHVAName(var _VoxelName: string): string;
      function GetTurretName(var _VoxelName: string): string;
      function GetBarrelName(var _VoxelName: string): string;
   public
      Voxels : array of PVoxel;
      HVAs : array of PHVA;
      Palette : PPalette;
      // Constructors and Destructors
      constructor Create; overload;
      constructor Create(const _Filename: string); overload;
      constructor Create(const _VoxelDocumentItem: TVoxelDocumentItem); overload;
      constructor CreateFullUnit(const _Filename: string);
      destructor Destroy; override;
      procedure Clear;
      // Gets
      function GetNumVoxels: integer;
      // Adds
      procedure AddVoxel(const _Filename: string);
      // Copies
      procedure Assign(const _VoxelDocumentItem: TVoxelDocumentItem);
   end;

implementation

uses GlobalVars;

constructor TVoxelDocumentItem.Create;
begin
   // Create new document.
   New(Palette);
   Palette^ := TPalette.Create(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
   SetLength(Voxels,1);
   New(Voxels[0]);
   Voxels[0] := VoxelBank.LoadNew;
   SetLength(HVAs,1);
   New(HVAs[0]);
   HVAs[0] := HVABank.LoadNew(Voxels[0]);
end;

constructor TVoxelDocumentItem.Create(const _Filename: string);
begin
   // Load a single voxel.
   New(Palette);
   Palette^ := TPalette.Create(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
   AddVoxel(_Filename);
end;

constructor TVoxelDocumentItem.Create(const _VoxelDocumentItem: TVoxelDocumentItem);
begin
   Assign(_VoxelDocumentItem);
end;

constructor TVoxelDocumentItem.CreateFullUnit(const _Filename: string);
var
   Filename : string;
begin
   // Load a single voxel.
   New(Palette);
   Palette^ := TPalette.Create(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
   SetLength(Voxels,0);
   SetLength(HVAs,0);
   // Add Body.
   AddVoxel(_Filename);
   // Turret.
   Filename := CopyString(_Filename);
   AddVoxel(GetTurretName(Filename));
   // Barrel.
   Filename := CopyString(_Filename);
   AddVoxel(GetBarrelName(Filename));
end;

destructor TVoxelDocumentItem.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TVoxelDocumentItem.Clear;
var
   i : integer;
begin
   for i := Low(Voxels) to High(Voxels) do
   begin
      HVABank.Delete(HVAs[i]);
      VoxelBank.Delete(Voxels[i]);
   end;
   Palette^.Free;
end;

// Gets
function TVoxelDocumentItem.GetNumVoxels: integer;
begin
   Result := High(Voxels)+1;
end;

// Adds
procedure TVoxelDocumentItem.AddVoxel(const _Filename: string);
var
   i: integer;
   Filename: string;
begin
   Filename := CopyString(_Filename);
   if FileExists(Filename) then
   begin
      SetLength(Voxels,High(Voxels)+2);
      SetLength(HVAs,High(HVAs)+2);
      i := High(Voxels);
      New(Voxels[i]);
      Voxels[i] := VoxelBank.Load(Voxels[i],Filename);
      New(HVAs[i]);
      HVAs[i] := HVABank.Load(HVAs[i],GetHVAName(Filename),Voxels[i]);
   end;
end;

// Copies
procedure TVoxelDocumentItem.Assign(const _VoxelDocumentItem: TVoxelDocumentItem);
var
   NumItems, i: integer;
begin
   NumItems := _VoxelDocumentItem.GetNumVoxels;
   SetLength(Voxels,NumItems);
   SetLength(HVAs,NumItems);
   for i := Low(Voxels) to High(Voxels) do
   begin
      Voxels[i] := VoxelBank.CloneEditable(_VoxelDocumentItem.Voxels[i]);
      HVAs[i] := HVABank.CloneEditable(_VoxelDocumentItem.HVAs[i]);
   end;
   New(Palette);
   Palette^ := TPalette.Create(_VoxelDocumentItem.Palette^);
end;

// Misc
function TVoxelDocumentItem.GetHVAName(var _VoxelName: string): string;
begin
   if Length(_VoxelName) > 4 then
   begin
      _VoxelName[Length(_VoxelName) - 2] := 'h';
      _VoxelName[Length(_VoxelName) - 1] := 'v';
      _VoxelName[Length(_VoxelName)] := 'a';
   end;
end;

function TVoxelDocumentItem.GetTurretName(var _VoxelName: string): string;
begin
   if Length(_VoxelName) > 4 then
   begin
      _VoxelName := copy(_VoxelName,1,Length(_VoxelName)-4);
      _VoxelName := _VoxelName + 'tur.vxl';
   end;
end;

function TVoxelDocumentItem.GetBarrelName(var _VoxelName: string): string;
begin
   if Length(_VoxelName) > 4 then
   begin
      _VoxelName := copy(_VoxelName,1,Length(_VoxelName)-4);
      _VoxelName := _VoxelName + 'bar.vxl';
   end;
end;

end.
