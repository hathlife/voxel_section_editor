unit Model;

interface

uses Palette, HierarchyAnimation, Mesh, BasicFunctions, BasicDataTypes, dglOpenGL, LOD,
   SysUtils, Graphics, GlConstants, ShaderBank, Histogram;

{$INCLUDE source/Global_Conditionals.inc}
   
type
   PModel = ^TModel;
   TModel = class
   protected
      FOpened : boolean;
      FType: integer;
      FRequestUpdateWorld: boolean;
      // Gets
      function GetRequestUpdateWorld: boolean;
   public
      ID: integer;
      Palette : PPalette;
      IsVisible : boolean;
      // Skeleton:
      HA : PHierarchyAnimation;
      LOD : array of TLOD;
      CurrentLOD : integer;
      // Source
      Filename : string;
      // GUI
      IsSelected : boolean;
      // Others
      ShaderBank : PShaderBank;
      // constructors and destructors
      constructor Create(const _Filename: string; _ShaderBank : PShaderBank); overload; virtual;
      constructor Create(const _Model: TModel); overload; virtual;
      destructor Destroy; override;
      procedure CommonCreationProcedures;
      procedure Initialize(); virtual;
      procedure ClearLODs;
      procedure Clear; virtual;
      procedure Reset;
      // I/O
      procedure SaveLODToFile(const _Filename, _TexExt: string);
      // Gets
      function GetNumLODs: longword;
      function IsOpened : boolean;
      function GetVertexCount: longword;
      function GetPolyCount: longword;
      function GetVoxelCount: longword; virtual;
      // Sets
      procedure SetNormalsModeRendering;
      procedure SetColourModeRendering;
      procedure SetQuality(_value: integer); virtual;
      // Rendering methods
      procedure Render;
      procedure RenderVectorial;
      procedure ProcessNextFrame;
      // Refresh OpenGL List
      procedure RefreshModel;
      procedure RefreshMesh(_MeshID: integer);
      // Textures
      procedure ExportTextures(const _BaseDir, _Ext: string; _previewTextures: boolean);
      procedure ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
      procedure SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
      // Transparency methods
      procedure ForceTransparency(_level: single);
      procedure ForceTransparencyOnMesh(_Level: single; _MeshID: integer);
      procedure ForceTransparencyExceptOnAMesh(_Level: single; _MeshID: integer);
      // Palette Related
      procedure ChangeRemappable (_Colour : TColor); virtual;
      procedure ChangePalette(const _Filename: string); virtual;
      // GUI
      procedure SetSelection(_value: boolean);
      // Copies
      procedure Assign(const _Model: TModel); virtual;
      // Mesh Optimization
      procedure RemoveInvisibleFaces;
      // Quality Assurance
      function GetAspectRatioHistogram(): THistogram;
      function GetSkewnessHistogram(): THistogram;
      function GetSmoothnessHistogram(): THistogram;
      procedure FillAspectRatioHistogram(var _Histogram: THistogram);
      procedure FillSkewnessHistogram(var _Histogram: THistogram);
      procedure FillSmoothnessHistogram(var _Histogram: THistogram);
      // Mesh Plugins
      procedure AddNormalsPlugin;
      procedure RemoveNormalsPlugin;

      property ModelType: integer read FType;
      property RequestUpdateWorld: boolean read GetRequestUpdateWorld write FRequestUpdateWorld;
   end;

implementation

uses GlobalVars, GenericThread;

constructor TModel.Create(const _Filename: string; _ShaderBank : PShaderBank);
begin
   Filename := CopyString(_Filename);
   ShaderBank := _ShaderBank;
   // Create a new 32 bits palette.
   New(Palette);
   Palette^ := TPalette.Create;
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
   FOpened := false;
   HA := nil;
   ID := GlobalVars.ModelBank.NextID;
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
   Palette^.Free;
   if HA <> nil then
   begin
      HA^.Free;
   end;
   HA := nil;
end;

procedure TModel.Initialize();
begin
   FType := C_MT_STANDARD;
   if HA = nil then
   begin
      new(HA);
      if CurrentLOD <= High(LOD) then
      begin
         if High(LOD[CurrentLOD].Mesh) >= 0 then
         begin
            HA^ := THierarchyAnimation.Create(High(LOD[CurrentLOD].Mesh)+1, 1);
         end
         else
         begin
            HA^ := THierarchyAnimation.Create(1, 1);
         end;
      end
      else
      begin
         HA^ := THierarchyAnimation.Create(1, 1);
      end;
   end;
   IsVisible := true;
end;

// I/O
procedure TModel.SaveLODToFile(const _Filename, _TexExt: string);
begin
   LOD[CurrentLOD].SaveToFile(_Filename,_TexExt);
end;

// Gets
function TModel.GetNumLODs: longword;
begin
   Result := High(LOD) + 1;
end;

function TModel.IsOpened : boolean;
begin
   Result := FOpened;
end;

function TModel.GetVertexCount: longword;
var
   i: integer;
begin
   Result := 0;
   for i := Low(LOD[CurrentLOD].Mesh) to High(LOD[CurrentLOD].Mesh) do
   begin
      if LOD[CurrentLOD].Mesh[i].Opened and LOD[CurrentLOD].Mesh[i].IsVisible then
      begin
         inc(Result, LOD[CurrentLOD].Mesh[i].GetNumVertices);
      end;
   end;
end;

function TModel.GetPolyCount: longword;
var
   i: integer;
begin
   Result := 0;
   for i := Low(LOD[CurrentLOD].Mesh) to High(LOD[CurrentLOD].Mesh) do
   begin
      if LOD[CurrentLOD].Mesh[i].Opened and LOD[CurrentLOD].Mesh[i].IsVisible then
      begin
         inc(Result, LOD[CurrentLOD].Mesh[i].NumFaces);
      end;
   end;
end;

function TModel.GetVoxelCount: longword;
begin
   Result := 0;
end;

function TModel.GetRequestUpdateWorld: boolean;
begin
   Result := FRequestUpdateWorld;
   FRequestUpdateWorld := false;
end;

// Sets
procedure TModel.SetQuality(_value: integer);
begin
   // do nothing.
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
procedure TModel.Render;
begin
   if IsVisible and FOpened then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         if HA^.DetectTransformationAnimationFrame then
         begin
            FRequestUpdateWorld := true;
         end;
         LOD[CurrentLOD].Render(HA);
      end;
   end;
end;

// No render to texture, nor display lists.
procedure TModel.RenderVectorial;
begin
   if IsVisible and FOpened then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         if HA^.DetectTransformationAnimationFrame then
         begin
            FRequestUpdateWorld := true;
         end;
         LOD[CurrentLOD].RenderVectorial(HA);
      end;
   end;
end;

procedure TModel.ProcessNextFrame;
begin
   if IsVisible and FOpened then
   begin
      if CurrentLOD <= High(LOD) then
      begin
         if HA^.DetectTransformationAnimationFrame then
         begin
            FRequestUpdateWorld := true;
         end;
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

// Textures
procedure TModel.ExportTextures(const _BaseDir, _Ext: string; _previewTextures: boolean);
begin
   LOD[CurrentLOD].ExportTextures(_BaseDir,_Ext,_previewTextures);
end;

procedure TModel.ExportHeightMap(const _BaseDir, _Ext : string; _previewTextures: boolean);
begin
   LOD[CurrentLOD].ExportHeightMap(_BaseDir,_Ext,_previewTextures);
end;

procedure TModel.SetTextureNumMipMaps(_NumMipMaps, _TextureType: integer);
begin
   LOD[CurrentLOD].SetTextureNumMipMaps(_NumMipMaps,_TextureType);
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
   end;
end;

procedure TModel.ChangePalette(const _Filename: string);
begin
   if Palette <> nil then
   begin
      Palette^.LoadPalette(_Filename);
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
   ShaderBank := _Model.ShaderBank;
   Palette^ := TPalette.Create(_Model.Palette^);
   IsVisible := _Model.IsVisible;
   SetLength(LOD,_Model.GetNumLODs);
   for i := Low(LOD) to High(LOD) do
   begin
      LOD[i] := TLOD.Create(_Model.LOD[i]);
   end;
   CurrentLOD := _Model.CurrentLOD;
   Filename := CopyString(_Model.Filename);
   IsSelected := _Model.IsSelected;
end;

// Mesh Optimizations
procedure TModel.RemoveInvisibleFaces;
begin
   LOD[CurrentLOD].RemoveInvisibleFaces;
end;

// Quality Assurance
function TModel.GetAspectRatioHistogram(): THistogram;
begin
   Result := LOD[CurrentLOD].GetAspectRatioHistogram;
end;

function TModel.GetSkewnessHistogram(): THistogram;
begin
   Result := LOD[CurrentLOD].GetSkewnessHistogram;
end;

function TModel.GetSmoothnessHistogram(): THistogram;
begin
   Result := LOD[CurrentLOD].GetSmoothnessHistogram;
end;

procedure TModel.FillAspectRatioHistogram(var _Histogram: THistogram);
begin
   LOD[CurrentLOD].FillAspectRatioHistogram(_Histogram);
end;

procedure TModel.FillSkewnessHistogram(var _Histogram: THistogram);
begin
   LOD[CurrentLOD].FillSkewnessHistogram(_Histogram);
end;

procedure TModel.FillSmoothnessHistogram(var _Histogram: THistogram);
begin
   LOD[CurrentLOD].FillSmoothnessHistogram(_Histogram);
end;

// Mesh Plugins
procedure TModel.AddNormalsPlugin;
begin
   LOD[CurrentLOD].AddNormalsPlugin;
end;

procedure TModel.RemoveNormalsPlugin;
begin
   LOD[CurrentLOD].RemoveNormalsPlugin;
end;

end.
