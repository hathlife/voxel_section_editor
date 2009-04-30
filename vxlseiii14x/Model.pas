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
   public
      Next : PModel;
      Palette : PPalette;
      IsVisible : boolean;
      // Skeleton:
      HVA : PHVA;
      LOD : array of TLOD;
      CurrentLOD : integer;
      // Source
      Filename : string;
      Voxel : PVoxel;
      // GUI
      IsSelected : boolean;
      // constructors and destructors
      constructor Create(const _Filename: string); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; _HighQuality : boolean); overload;
      constructor Create(const _Model: TModel); overload;
      destructor Destroy; override;
      procedure CommonCreationProcedures;
      procedure Initialize(_HighQuality: boolean = false);
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
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Voxel: PVoxel; const _Palette: PPalette; _HighQuality : boolean);
begin
   Filename := '';
   Voxel := _Voxel;
   Palette := _Palette;
   CommonCreationProcedures;
end;

constructor TModel.Create(const _Model: TModel);
begin
   Next := nil;
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
   Next := nil;
   Opened := false;
   Reset;
end;

procedure TModel.Reset;
begin
   Clear;
   Initialize;
end;

procedure TModel.Clear;
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
   HVA := nil;
   Palette := nil;
end;

procedure TModel.Initialize(_HighQuality: boolean = false);
var
   ext : string;
begin
   // Check if we have a random file or a voxel.
   if Voxel = nil then
   begin
      // We have a file to open.
      ext := ExtractFileExt(Filename);
      if (CompareStr(ext,'.vxl') = 0) then
      begin
         Voxel := VoxelBank.Add(Filename);
         OpenVoxel(_HighQuality);
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
   end;
   CurrentLOD := 0;
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
   Palette := _Model.Palette;
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
