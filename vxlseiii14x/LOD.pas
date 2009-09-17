unit LOD;

// Level of Detail v1.0

// It should feature the meshes from a model. And a model will have several LODs

interface

uses Mesh, HVA, BasicDataTypes, BasicFunctions, dglOpenGL, GlConstants, ObjFile,
   SysUtils;

type
   TLOD = class
   private
      // I/O
      procedure SaveToOBJFile(const _Filename: string);
      // Rendering Methods
      procedure RenderMesh(_i :integer; var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
   public
      InitialMesh : integer;
      Name : string;
      Mesh : array of TMesh;
      // Constructors and Destructors
      constructor Create; overload;
      constructor Create(const _LOD: TLOD); overload;
      destructor Destroy; override;
      procedure Clear;
      // I/O
      procedure SaveToFile(const _Filename: string);
      // Gets
      function GetNumMeshes: longword;
      // Rendering Methods
      procedure Render(var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      // Refresh OpenGL List
      procedure RefreshLOD;
      procedure RefreshMesh(_MeshID: integer);
      // LOD Effects
      procedure SmoothLOD;
      procedure CubicSmoothLOD;
      procedure LanczosSmoothLOD;
      procedure UnsharpLOD;
      procedure InflateLOD;
      procedure DeflateLOD;
      // Colour Effects
      procedure ColourSmoothLOD;
      procedure ColourCubicSmoothLOD;
      // Normals
      procedure RenormalizeLOD;
      procedure ConvertFaceToVertexNormals;
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
      // GUI
      procedure SetSelection(_value: boolean);
      // Copies
      procedure Assign(const _LOD: TLOD);
      // Mesh Optimizations
      procedure RemoveInvisibleFaces;
      procedure ConvertQuadsToTris;
   end;

implementation

// Constructors and Destructors
constructor TLOD.Create;
begin
   Name := 'Standard Level Of Detail';
   SetLength(Mesh,0);
   InitialMesh := 0;
end;

constructor TLOD.Create(const _LOD: TLOD);
begin
   Assign(_LOD);
end;

destructor TLOD.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TLOD.Clear;
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
end;

// I/O
procedure TLOD.SaveToFile(const _Filename: string);
var
   ext : string;
begin
   ext := Lowercase(ExtractFileExt(_Filename));
   if CompareStr(ext,'.obj') = 0 then
   begin
      SaveToOBJFile(_Filename);
   end;
end;

procedure TLOD.SaveToOBJFile(const _Filename: string);
var
   Obj : TObjFile;
   i : integer;
begin
   Obj := TObjFile.Create;
   for i := Low(Mesh) to High(Mesh) do
   begin
      Obj.AddMesh(Addr(Mesh[i]));
   end;
   Obj.SaveToFile(_Filename);
   Obj.Free;
end;

// Gets
function TLOD.GetNumMeshes: longword;
begin
   Result := High(Mesh)+1;
end;

// Rendering Methods
procedure TLOD.Render(var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
begin
   RenderMesh(InitialMesh,_PolyCount,_VoxelCount,_HVA, _Frame);
end;

procedure TLOD.RenderMesh(_i :integer; var _PolyCount,_VoxelCount: longword; const _HVA: PHVA; _Frame: integer);
begin
   if _i <> -1 then
   begin
      glPushMatrix();
         _HVA^.ApplyMatrix(Mesh[_i].Scale,_i,_Frame);
         RenderMesh(Mesh[_i].Son,_PolyCount,_VoxelCount,_HVA, _Frame);
         Mesh[_i].Render(_PolyCount,_VoxelCount);
      glPopMatrix();
      RenderMesh(Mesh[_i].Next,_PolyCount,_VoxelCount,_HVA, _Frame);
   end;
end;

procedure TLOD.SetNormalsModeRendering;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].SetColoursType(C_COLOURS_DISABLED);
   end;
end;

procedure TLOD.SetColourModeRendering;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceColoursRendering;
   end;
end;



// Refresh OpenGL List
procedure TLOD.RefreshLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceRefresh;
   end;
end;

procedure TLOD.RefreshMesh(_MeshID: integer);
begin
   if _MeshID <= High(Mesh) then
      Mesh[_MeshID].ForceRefresh;
end;

// LOD Effects
procedure TLOD.SmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshSmooth;
   end;
end;

procedure TLOD.CubicSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshCubicSmooth;
   end;
end;

procedure TLOD.LanczosSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshLanczosSmooth;
   end;
end;

procedure TLOD.UnsharpLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshUnsharpMasking;
   end;
end;

procedure TLOD.InflateLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshInflate;
   end;
end;

procedure TLOD.DeflateLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].MeshDeflate;
   end;
end;

// Colour Effects
procedure TLOD.ColourSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ColourSmooth;
   end;
end;

procedure TLOD.ColourCubicSmoothLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ColourCubicSmooth;
   end;
end;

// Normals
procedure TLOD.ReNormalizeLOD;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ReNormalizeMesh;
   end;
end;

procedure TLOD.ConvertFaceToVertexNormals;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertFaceToVertexNormals;
   end;
end;


// Transparency methods
procedure TLOD.ForceTransparency(_level: single);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ForceTransparencyLevel(_Level);
   end;
end;

procedure TLOD.ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
begin
   if _MeshID <= High(Mesh) then
      Mesh[_MeshID].ForceTransparencyLevel(_Level);
end;

procedure TLOD.ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
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

// GUI
procedure TLOD.SetSelection(_value: boolean);
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].IsSelected := _value;
   end;
end;

// Copies
procedure TLOD.Assign(const _LOD: TLOD);
var
   i : integer;
begin
   Name := CopyString(_LOD.Name);
   SetLength(Mesh,_LOD.GetNumMeshes);
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i] := TMesh.Create(_LOD.Mesh[i]);
   end;
end;

// Mesh Optimizations
procedure TLOD.RemoveInvisibleFaces;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].RemoveInvisibleFaces;
   end;
end;

procedure TLOD.ConvertQuadsToTris;
var
   i : integer;
begin
   for i := Low(Mesh) to High(Mesh) do
   begin
      Mesh[i].ConvertQuadsToTris;
   end;
end;


end.
