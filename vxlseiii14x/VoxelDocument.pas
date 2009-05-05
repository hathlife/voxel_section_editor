unit VoxelDocument;

interface

uses Voxel, HVA, Palette, BasicDataTypes, BasicFunctions, SysUtils;

const
   C_VXLTP_BODY = 0;
   C_VXLTP_TURRET = 1;
   C_VXLTP_BARREL = 2;

type
   TVoxelDocument = class
   private
      // Misc
      function GetHVAName(var _VoxelName: string): string;
      function GetTurretName(var _VoxelName: string): string;
      function GetBarrelName(var _VoxelName: string): string;
   public
      Voxels : array of PVoxel;
      HVAs : array of PHVA;
      VoxelType : array of byte;
      Palette : PPalette;
      // Constructors and Destructors
      constructor Create; overload;
      constructor Create(const _Filename: string); overload;
      constructor Create(const _VoxelDocument: TVoxelDocument); overload;
      constructor CreateFullUnit(const _Filename: string);
      destructor Destroy; override;
      procedure Clear;
      procedure ClearVoxel;
      // I/O
      procedure LoadNew;
      function Load(const _Filename: string): boolean;
      function LoadFullUnit(const _Filename: string): boolean;
      procedure SaveDocument(const _Filename: string);
      // Gets
      function GetNumVoxels: integer;
      function GetBodyVoxel: PVoxel;
      function GetTurretVoxel: PVoxel;
      function GetBarrelVoxel: PVoxel;
      function GetBodyHVA: PHVA;
      function GetTurretHVA: PHVA;
      function GetBarrelHVA: PHVA;
      // Adds
      function AddVoxel(const _Filename: string): boolean;
      // Copies
      procedure Assign(const _VoxelDocument: TVoxelDocument);
      // Swicthes
      function SwitchTurret(const _Filename: string): boolean;
   end;
   PVoxelDocument = ^TVoxelDocument;

implementation

uses GlobalVars;

constructor TVoxelDocument.Create;
begin
   // Create new document.
   New(Palette);
   Palette^ := TPalette.Create(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
   LoadNew;
end;

constructor TVoxelDocument.Create(const _Filename: string);
begin
   // Load a single voxel.
   New(Palette);
   Palette^ := TPalette.Create(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
   Load(_Filename);
end;

constructor TVoxelDocument.Create(const _VoxelDocument: TVoxelDocument);
begin
   Assign(_VoxelDocument);
end;

constructor TVoxelDocument.CreateFullUnit(const _Filename: string);
begin
   // Load a single voxel.
   New(Palette);
   Palette^ := TPalette.Create(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
   LoadFullUnit(_Filename);
end;

destructor TVoxelDocument.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TVoxelDocument.Clear;
begin
   ClearVoxel;
   Palette^.Free;
end;

procedure TVoxelDocument.ClearVoxel;
var
   i : integer;
begin
   for i := Low(Voxels) to High(Voxels) do
   begin
      HVABank.Delete(HVAs[i]);
      VoxelBank.Delete(Voxels[i]);
   end;
   SetLength(Voxels,0);
   SetLength(HVAs,0);
   SetLength(VoxelType,0);
end;

// I/O
procedure TVoxelDocument.LoadNew;
begin
   ClearVoxel;
   SetLength(Voxels,1);
   SetLength(HVAs,1);
   SetLength(VoxelType,1);
   Voxels[0] := VoxelBank.LoadNew;
   HVAs[0] := HVABank.LoadNew(Voxels[0]);
   VoxelType[0] := C_VXLTP_BODY;
end;

function TVoxelDocument.Load(const _Filename: string): boolean;
begin
   ClearVoxel;
   Result := AddVoxel(_Filename);
end;

function TVoxelDocument.LoadFullUnit(const _Filename: string): boolean;
var
   Filename : string;
begin
   ClearVoxel;
   // Add Body.
   Result := AddVoxel(_Filename);
   if Result then
   begin
      // Turret.
      Filename := CopyString(_Filename);
      if AddVoxel(GetTurretName(Filename)) then
         VoxelType[High(VoxelType)] := C_VXLTP_TURRET;
      // Barrel.
      Filename := CopyString(_Filename);
      if AddVoxel(GetBarrelName(Filename)) then
         VoxelType[High(VoxelType)] := C_VXLTP_BARREL;
   end;
end;


procedure TVoxelDocument.SaveDocument(const _Filename: string);
var
   OriginalFilename,Filename : string;
   i : integer;
begin
   // If there are no voxels, there is nothing to save.
   if High(Voxels) < 0 then
      exit;
   // Check if it saves all voxels in a different place.
   if Length(_Filename) = 0 then
   begin
      OriginalFilename := CopyString(Voxels[0]^.Filename);
   end
   else
   begin
      OriginalFilename := CopyString(_Filename);
   end;
   // Save all voxels and HVAs
   for i := Low(Voxels) to High(Voxels) do
   begin
      Filename := CopyString(OriginalFilename);
      case (VoxelType[i]) of
         C_VXLTP_BODY:
         begin
            VoxelBank.Save(Voxels[0],Filename);
            HVABank.Save(HVAs[0],GetHVAName(Filename));
         end;
         C_VXLTP_TURRET:
         begin
            VoxelBank.Save(Voxels[0],GetTurretName(Filename));
            HVABank.Save(HVAs[0],GetHVAName(Filename));
         end;
         C_VXLTP_BARREL:
         begin
            VoxelBank.Save(Voxels[0],GetBarrelName(Filename));
            HVABank.Save(HVAs[0],GetHVAName(Filename));
         end;
      end;
   end;
end;

// Gets
function TVoxelDocument.GetNumVoxels: integer;
begin
   Result := High(Voxels)+1;
end;

function TVoxelDocument.GetBodyVoxel: PVoxel;
var
   i : integer;
begin
   Result := nil;
   for i := Low(VoxelType) to High(VoxelType) do
   begin
      if (VoxelType[i] = C_VXLTP_BODY) then
      begin
         Result := Voxels[i];
         exit;
      end;
   end;
end;

function TVoxelDocument.GetTurretVoxel: PVoxel;
var
   i : integer;
begin
   Result := nil;
   for i := Low(VoxelType) to High(VoxelType) do
   begin
      if (VoxelType[i] = C_VXLTP_TURRET) then
      begin
         Result := Voxels[i];
         exit;
      end;
   end;
end;

function TVoxelDocument.GetBarrelVoxel: PVoxel;
var
   i : integer;
begin
   Result := nil;
   for i := Low(VoxelType) to High(VoxelType) do
   begin
      if (VoxelType[i] = C_VXLTP_BARREL) then
      begin
         Result := Voxels[i];
         exit;
      end;
   end;
end;

function TVoxelDocument.GetBodyHVA: PHVA;
var
   i : integer;
begin
   Result := nil;
   for i := Low(VoxelType) to High(VoxelType) do
   begin
      if (VoxelType[i] = C_VXLTP_BODY) then
      begin
         Result := HVAs[i];
         exit;
      end;
   end;
end;

function TVoxelDocument.GetTurretHVA: PHVA;
var
   i : integer;
begin
   Result := nil;
   for i := Low(VoxelType) to High(VoxelType) do
   begin
      if (VoxelType[i] = C_VXLTP_TURRET) then
      begin
         Result := HVAs[i];
         exit;
      end;
   end;
end;

function TVoxelDocument.GetBarrelHVA: PHVA;
var
   i : integer;
begin
   Result := nil;
   for i := Low(VoxelType) to High(VoxelType) do
   begin
      if (VoxelType[i] = C_VXLTP_BARREL) then
      begin
         Result := HVAs[i];
         exit;
      end;
   end;
end;

// Adds
function TVoxelDocument.AddVoxel(const _Filename: string): boolean;
var
   i: integer;
   Filename: string;
begin
   Result := false;
   Filename := CopyString(_Filename);
   if FileExists(Filename) then
   begin
      SetLength(Voxels,High(Voxels)+2);
      SetLength(HVAs,High(HVAs)+2);
      SetLength(VoxelType,High(VoxelType)+2);
      i := High(Voxels);
      Voxels[i] := VoxelBank.Load(Voxels[i],Filename);
      // Did it open the voxel?
      if Voxels[i] <> nil then
      begin
         HVAs[i] := HVABank.Load(HVAs[i],GetHVAName(Filename),Voxels[i]);
         VoxelType[i] := C_VXLTP_BODY; // Default value.
         Result := true;
      end
      else // if Voxel couldn't be opened, abort operation
      begin
         SetLength(Voxels,High(Voxels));
         SetLength(HVAs,High(HVAs));
         SetLength(VoxelType,High(VoxelType));
      end;
   end;
end;

// Copies
procedure TVoxelDocument.Assign(const _VoxelDocument: TVoxelDocument);
var
   NumItems, i: integer;
begin
   NumItems := _VoxelDocument.GetNumVoxels;
   SetLength(Voxels,NumItems);
   SetLength(HVAs,NumItems);
   SetLength(VoxelType,NumItems);
   for i := Low(Voxels) to High(Voxels) do
   begin
      Voxels[i] := VoxelBank.CloneEditable(_VoxelDocument.Voxels[i]);
      HVAs[i] := HVABank.CloneEditable(_VoxelDocument.HVAs[i]);
      VoxelType[i] := _VoxelDocument.VoxelType[i];
   end;
   New(Palette);
   Palette^ := TPalette.Create(_VoxelDocument.Palette^);
end;

// Misc
function TVoxelDocument.GetHVAName(var _VoxelName: string): string;
begin
   if Length(_VoxelName) > 4 then
   begin
      _VoxelName[Length(_VoxelName) - 2] := 'h';
      _VoxelName[Length(_VoxelName) - 1] := 'v';
      _VoxelName[Length(_VoxelName)] := 'a';
   end;
end;

function TVoxelDocument.GetTurretName(var _VoxelName: string): string;
begin
   if Length(_VoxelName) > 4 then
   begin
      _VoxelName := copy(_VoxelName,1,Length(_VoxelName)-4);
      _VoxelName := _VoxelName + 'tur.vxl';
   end;
end;

function TVoxelDocument.GetBarrelName(var _VoxelName: string): string;
begin
   if Length(_VoxelName) > 4 then
   begin
      _VoxelName := copy(_VoxelName,1,Length(_VoxelName)-4);
      _VoxelName := _VoxelName + 'bar.vxl';
   end;
end;

// Swicthes
function TVoxelDocument.SwitchTurret(const _Filename: string): boolean;
var
   i : integer;
   Filename: string;
begin
   Result := false;
   if FileExists(_Filename) then
   begin
      i := 0;
      while i <= High(Voxels) do
      begin
         if VoxelType[i] = C_VXLTP_TURRET then
         begin
            Voxels[i] := VoxelBank.Load(Voxels[i],_Filename);
            Filename := CopyString(_Filename);
            HVAs[i] := HVABank.Load(HVAs[i],GetHVAName(Filename),Voxels[i]);
            Result := true;
            exit;
         end;
         inc(i);
      end;
   end;
end;


end.
