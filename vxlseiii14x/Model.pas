unit Model;

interface

uses Palette, HVA, Voxel, Mesh, BasicFunctions, BasicDataTypes, dglOpenGL, LOD,
   SysUtils, Graphics, GlConstants;

type
   PModel = ^TModel;
   TModel = class
   private
      Opened : boolean;
      // I/O
      procedure OpenVoxel;
      procedure OpenVoxelSection(const _VoxelSection: PVoxelSection);
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
      Quality: integer;
      // GUI
      IsSelected : boolean;
      // constructors and destructors
      constructor Create(const _Filename: string); overload;
      constructor Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _Quality : integer); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; const _HVA: PHVA; _Quality : integer); overload;
      constructor Create(const _Model: TModel); overload;
      destructor Destroy; override;
      procedure CommonCreationProcedures;
      procedure Initialize(_HighQuality: boolean = false);
      procedure ClearLODs;
      procedure Clear;
      procedure Reset;
      // I/O
      procedure RebuildModel;
      procedure RebuildLOD(i: integer);
      procedure RebuildCurrentLOD;
      procedure SaveLODToFile(const _Filename: string);
      // Gets
      function GetNumLODs: longword;
      function IsOpened : boolean;
      // Sets
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      procedure SetQuality(_value: integer);
      // Rendering methods
      procedure Render(var _PolyCount,_VoxelCount: longword; _Frame: integer);
      // Refresh OpenGL List
      procedure RefreshModel;
      procedure RefreshMesh(_MeshID: integer);
      // Model Effects
      procedure SmoothModel;
      procedure CubicSmoothModel;
      procedure LanczosSmoothModel;
      procedure UnsharpModel;
      procedure InflateModel;
      procedure DeflateModel;
      procedure ReNormalizeModel;
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
      // Palette Related
      procedure ChangeRemappable (_Colour : TColor);
      procedure ChangePalette(const _Filename: string);
      // GUI
      procedure SetSelection(_value: boolean);
      // Copies
      procedure Assign(const _Model: TModel);
      // Mesh Optimization
      procedure RemoveInvisibleFaces;
      // Misc
      procedure MakeVoxelHVAIndependent;
   end;

implementation

uses GlobalVars;

constructor TModel.Create(const _Filename: string);
begin
   Filename := CopyString(_Filename);
   Voxel := nil;
   VoxelSection := nil;
   Quality := C_QUALITY_MAX;
   // Create a new 32 bits palette.
   New(Palette);
   Palette^ := TPalette.Create;
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Voxel: PVoxel; const _Palette: PPalette; const _HVA: PHVA; _Quality : integer);
begin
   Filename := '';
   Voxel := VoxelBank.Add(_Voxel);
   HVA := HVABank.Add(_HVA);
   VoxelSection := nil;
   Quality := _Quality;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModel.Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _Quality : integer);
begin
   Filename := '';
   Voxel := nil;
   VoxelSection := _VoxelSection;
   Quality := _Quality;
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
            OpenVoxel;
         end;
      end
      else
      begin
         OpenVoxelSection(VoxelSection);
      end;
   end
   else  // we open the current voxel
   begin
      OpenVoxel;
   end;
   IsVisible := true;
end;

// I/O
procedure TModel.OpenVoxel;
var
   i : integer;
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,Voxel^.Header.NumSections);
   for i := 0 to (Voxel^.Header.NumSections-1) do
   begin
      LOD[0].Mesh[i] := TMesh.CreateFromVoxel(i,Voxel^.Section[i],Palette^,Quality);
      LOD[0].Mesh[i].Next := i+1;
   end;
   LOD[0].Mesh[High(LOD[0].Mesh)].Next := -1;
   CurrentLOD := 0;
   Opened := true;
end;

procedure TModel.OpenVoxelSection(const _VoxelSection : PVoxelSection);
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,1);
   LOD[0].Mesh[0] := TMesh.CreateFromVoxel(0,_VoxelSection^,Palette^,Quality);
   CurrentLOD := 0;
   HVA := HVABank.LoadNew(nil);
   Opened := true;
end;

procedure TModel.SaveLODToFile(const _Filename: string);
begin
   LOD[CurrentLOD].SaveToFile(_Filename);
end;

procedure TModel.RebuildModel;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      RebuildLOD(i);
   end;
end;

procedure TModel.RebuildLOD(i: integer);
var
   j,start : integer;
begin
   if Voxel <> nil then
   begin
      if Voxel^.Header.NumSections > LOD[i].GetNumMeshes then
      begin
         start := LOD[i].GetNumMeshes;
         SetLength(LOD[i].Mesh,Voxel^.Header.NumSections);
         for j := start to Voxel^.Header.NumSections - 1 do
         begin
            LOD[i].Mesh[j] := TMesh.CreateFromVoxel(j,Voxel^.Section[j],Palette^,Quality);
            LOD[i].Mesh[j].Next := j+1;
         end;
      end;
      for j := Low(LOD[i].Mesh) to High(LOD[i].Mesh) do
      begin
         LOD[i].Mesh[j].RebuildVoxel(Voxel^.Section[j],Palette^,Quality);
      end;
   end
   else if VoxelSection <> nil then
   begin
      LOD[i].Mesh[0].RebuildVoxel(VoxelSection^,Palette^,Quality);
   end
   else
   begin
      // At the moment, we won't do anything.
   end;
end;

procedure TModel.RebuildCurrentLOD;
begin
   RebuildLOD(CurrentLOD);
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

// Sets
procedure TModel.SetQuality(_value: integer);
begin
   Quality := _value;
   RebuildModel;
end;

procedure TModel.SetNormalsModeRendering;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i].SetNormalsModeRendering;
   end;
end;

procedure TModel.SetColourModeRendering;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i].SetColourModeRendering;
   end;
end;

// Rendering methods
procedure TModel.Render(var _Polycount,_VoxelCount: longword; _Frame: integer);
begin
   if IsVisible and Opened and (HVA <> nil) then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         LOD[CurrentLOD].Render(_PolyCount,_VoxelCount,HVA,_Frame);
      end;
   end;
end;

// Refresh OpenGL List
procedure TModel.RefreshModel;
begin
   LOD[CurrentLOD].RefreshLOD;
end;

procedure TModel.RefreshMesh(_MeshID: integer);
begin
   LOD[CurrentLOD].RefreshMesh(_MeshID);
end;

// Model Effects
procedure TModel.SmoothModel;
begin
   LOD[CurrentLOD].SmoothLOD;
end;

procedure TModel.CubicSmoothModel;
begin
   LOD[CurrentLOD].CubicSmoothLOD;
end;

procedure TModel.LanczosSmoothModel;
begin
   LOD[CurrentLOD].LanczosSmoothLOD;
end;

procedure TModel.UnsharpModel;
begin
   LOD[CurrentLOD].UnsharpLOD;
end;

procedure TModel.InflateModel;
begin
   LOD[CurrentLOD].InflateLOD;
end;

procedure TModel.DeflateModel;
begin
   LOD[CurrentLOD].DeflateLOD;
end;

procedure TModel.ReNormalizeModel;
begin
   LOD[CurrentLOD].RenormalizeLOD;
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

// Palette Related
procedure TModel.ChangeRemappable(_Colour: TColor);
begin
   if Palette <> nil then
   begin
      Palette^.ChangeRemappable(_Colour);
      RebuildModel;
   end;
end;

procedure TModel.ChangePalette(const _Filename: string);
begin
   if Palette <> nil then
   begin
      Palette^.LoadPalette(_Filename);
      RebuildModel;
   end;
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
   Quality := _Model.Quality;
end;

// Mesh Optimizations
procedure TModel.RemoveInvisibleFaces;
begin
   LOD[CurrentLOD].RemoveInvisibleFaces;
end;


// Misc
procedure TModel.MakeVoxelHVAIndependent;
var
   HVATemp: PHVA;
   VoxelTemp: PVoxel;
begin
   if (HVA <> nil) then
   begin
      HVATemp := HVABank.Clone(HVA);
      HVABank.Delete(HVA);
      HVA := HVATemp;
   end;
   if (Voxel <> nil) then
   begin
      VoxelTemp := VoxelBank.Clone(Voxel);
      VoxelBank.Delete(Voxel);
      Voxel := VoxelTemp;
      HVA^.p_Voxel := Voxel;
   end;
end;



end.
