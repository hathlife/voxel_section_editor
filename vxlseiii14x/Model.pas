unit Model;

interface

uses Palette, HVA, Voxel, Mesh, BasicFunctions, BasicDataTypes, dglOpenGL, LOD,
   SysUtils;

type
   PModel = ^TModel;
   TModel = class
   private
      Opened : boolean;
      // I/O
      procedure OpenVoxel(_HighQuality: boolean = false);
      procedure OpenVoxelSection(const _VoxelSection: PVoxelSection; _HighQuality: boolean = false);
   public
      Palette : PPalette;
      IsVisible : boolean;
      // Skeleton:
      HVA : PHVA;
      LOD : array of TLOD;
      CurrentLOD : integer;
      // Source
      Filename : string;
      Voxel : PVoxel;
      VoxelSection : PVoxelSection;
      // GUI
      IsSelected : boolean;
      // constructors and destructors
      constructor Create(const _Filename: string); overload;
      constructor Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _HighQuality : boolean); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; const _HVA: PHVA; _HighQuality : boolean); overload;
      constructor Create(const _Model: TModel); overload;
      destructor Destroy; override;
      procedure CommonCreationProcedures;
      procedure Initialize(_HighQuality: boolean = false);
      procedure ClearLODs;
      procedure Clear;
      procedure Reset;
      // Gets
      function GetNumLODs: longword;
      function IsOpened : boolean;
      // Rendering methods
      procedure Render(var _PolyCount: longword);
      // Refresh OpenGL List
      procedure RefreshModel;
      procedure RefreshMesh(_MeshID: integer);
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
      // GUI
      procedure SetSelection(_value: boolean);
      // Copies
      procedure Assign(const _Model: TModel);
   end;

implementation

uses GlobalVars;

constructor TModel.Create(const _Filename: string);
begin
   Filename := CopyString(_Filename);
   Voxel := nil;
   VoxelSection := nil;
   // Create a new 32 bits palette.
   New(Palette);
   Palette^ := TPalette.Create;
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Voxel: PVoxel; const _Palette: PPalette; const _HVA: PHVA; _HighQuality : boolean);
begin
   Filename := '';
   Voxel := VoxelBank.Add(_Voxel);
   HVA := HVABank.Add(_HVA);
   VoxelSection := nil;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModel.Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _HighQuality : boolean);
begin
   Filename := '';
   Voxel := nil;
   VoxelSection := _VoxelSection;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Model: TModel);
begin
   Assign(_Model);
end;

destructor TModel.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TModel.CommonCreationProcedures;
begin
   CurrentLOD := 0;
   Opened := false;
   Reset;
end;

procedure TModel.Reset;
begin
   ClearLODs;
   Initialize;
end;

procedure TModel.ClearLODs;
var
   i : integer;
begin
   i := High(LOD);
   while i >= 0 do
   begin
      LOD[i].Free;
      dec(i);
   end;
   SetLength(LOD,0);
end;

procedure TModel.Clear;
begin
   ClearLODs;
   VoxelBank.Delete(Voxel);    // even if it is nil, no problem.
   HVABank.Delete(HVA);
   Palette^.Free;
end;

procedure TModel.Initialize(_HighQuality: boolean = false);
var
   ext : string;
   HVAFilename : string;
begin
   // Check if we have a random file or a voxel.
   if Voxel = nil then
   begin
      if VoxelSection = nil then
      begin
         // We have a file to open.
         ext := ExtractFileExt(Filename);
         if (CompareStr(ext,'.vxl') = 0) then
         begin
            Voxel := VoxelBank.Add(Filename);
            HVAFilename := copy(Filename,1,Length(Filename)-3);
            HVAFilename := HVAFilename + 'hva';
            HVA := HVABank.Add(HVAFilename,Voxel);
            OpenVoxel(_HighQuality);
         end;
      end
      else
      begin
         OpenVoxelSection(VoxelSection,_HighQuality);
      end;
   end
   else  // we open the current voxel
   begin
      OpenVoxel(_HighQuality);
   end;
end;

// I/O
procedure TModel.OpenVoxel(_HighQuality: boolean = false);
var
   i : integer;
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,Voxel^.Header.NumSections);
   for i := 0 to (Voxel^.Header.NumSections-1) do
   begin
      LOD[0].Mesh[i] := TMesh.CreateFromVoxel(i,Voxel^.Section[i],Palette^,_HighQuality);
      LOD[0].Mesh[i].Next := i+1;
   end;
   LOD[0].Mesh[High(LOD[0].Mesh)].Next := -1;
   CurrentLOD := 0;
   Opened := true;
end;

procedure TModel.OpenVoxelSection(const _VoxelSection : PVoxelSection; _HighQuality: boolean = false);
var
   i : integer;
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,1);
   LOD[0].Mesh[0] := TMesh.CreateFromVoxel(0,_VoxelSection^,Palette^,_HighQuality);
   CurrentLOD := 0;
   HVA := HVABank.LoadNew(nil);
   Opened := true;
end;


// Gets
function TModel.GetNumLODs: longword;
begin
   Result := High(LOD) + 1;
end;

function TModel.IsOpened : boolean;
begin
   Result := Opened;
end;


// Rendering methods
procedure TModel.Render(var _Polycount: longword);
var
   i : integer;
begin
   if IsVisible and Opened and (HVA <> nil) then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         LOD[i].Render(_PolyCount,HVA);
      end;
   end;
end;

// Refresh OpenGL List
procedure TModel.RefreshModel;
var
   i : integer;
begin
   LOD[CurrentLOD].RefreshLOD;
end;

procedure TModel.RefreshMesh(_MeshID: integer);
begin
   LOD[CurrentLOD].RefreshMesh(_MeshID);
end;

// Transparency methods
procedure TModel.ForceTransparency(_level: single);
begin
   LOD[CurrentLOD].ForceTransparency(_Level);
end;

procedure TModel.ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
begin
   LOD[CurrentLOD].ForceTransparencyOnMesh(_Level,_MeshID);
end;

procedure TModel.ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
begin
   LOD[CurrentLOD].ForceTransparencyExceptOnAMesh(_Level,_MeshID);
end;

// GUI
procedure TModel.SetSelection(_value: boolean);
var
   i : integer;
begin
   IsSelected := _value;
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i].SetSelection(_value);
   end;
end;

// Copies
procedure TModel.Assign(const _Model: TModel);
var
   i : integer;
begin
   New(Palette);
   Palette^ := TPalette.Create(_Model.Palette^);
   IsVisible := _Model.IsVisible;
   HVA := _Model.HVA;
   SetLength(LOD,_Model.GetNumLODs);
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i] := TLOD.Create(_Model.LOD[i]);
   end;
   CurrentLOD := _Model.CurrentLOD;
   Filename := CopyString(_Model.Filename);
   Voxel := _Model.Voxel;
   IsSelected := _Model.IsSelected;
end;


end.
