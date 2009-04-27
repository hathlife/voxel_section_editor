unit Model;

interface

uses Palette, HVA, Voxel, Mesh, BasicFunctions, BasicDataTypes, dglOpenGL;

type
   PModel = ^TModel;
   TModel = class
   private
      Opened : boolean;
   public
      Next : PModel;
      Palette : PPalette;
      IsVisible : boolean;
      // Skeleton:
      HVA : PHVA;
      Mesh : array of TMesh;
      // Source
      Filename : string;
      Voxel : PVoxel;
      // constructors and destructors
      constructor Create(const _Filename: string); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; _HighQuality : boolean); overload;
      destructor Destroy; override;
      procedure CommonCreationProcedures;
      procedure Initialize(_HighQuality: boolean = false);
      procedure Clear;
      procedure Reset;
      // Gets
      function GetNumMeshes: longword;
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
   end;

implementation

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

destructor TModel.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TModel.CommonCreationProcedures;
begin
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
   i := High(Mesh);
   while i >= 0 do
   begin
      Mesh[i].Free;
      dec(i);
   end;
   SetLength(Mesh,0);
   HVA := nil;
   Palette := nil;
end;

procedure TModel.Initialize(_HighQuality: boolean = false);
var
   i : integer;
begin
   // Check if we have a random file or a voxel.
   if Voxel = nil then
   begin
      // We have a file to open.


   end
   else
   begin
      // We may use an existing voxel.
      SetLength(Mesh,Voxel^.Header.NumSections);
      for i := 0 to (Voxel^.Header.NumSections-1) do
      begin
         Mesh[i] := TMesh.CreateFromVoxel(i,Voxel^.Section[i],Palette^,_HighQuality);
      end;
      Opened := true;
   end;
end;

// Gets
function TModel.GetNumMeshes: longword;
begin
   Result := High(Mesh) + 1;
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
      for i := Low(Mesh) to High(Mesh) do
      begin
         glPushMatrix();
            HVA^.ApplyMatrix(Mesh[i].Scale,i);
            Mesh[i].Render(_PolyCount);
         glPopMatrix();
      end;
   end;
end;

// Refresh OpenGL List
procedure TModel.RefreshModel;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceRefresh;
   end;
end;

procedure TModel.RefreshMesh(_MeshID: integer);
begin
   Mesh[_MeshID].ForceRefresh;
end;

// Transparency methods
procedure TModel.ForceTransparency(_level: single);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceTransparencyLevel(_Level);
   end;
end;

procedure TModel.ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
begin
   Mesh[_MeshID].ForceTransparencyLevel(_Level);
end;

procedure TModel.ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      if i <> _MeshID then
         Mesh[i].ForceTransparencyLevel(_Level)
      else
         Mesh[i].ForceTransparencyLevel(0);
   end;
end;


end.
