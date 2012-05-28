unit MeshGeometryBase;

interface

uses BasicDataTypes, ShaderBank;

type
   PMeshGeometryBase = ^TMeshGeometryBase;
   TMeshGeometryBase = class
      protected
         FNumFaces: longword;
         // Gets
         function GetNumFaces: longword;
         // Sets
         procedure SetNumFaces(_Value: longword); virtual;
      public
         Next: PMeshGeometryBase;
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Initialize; virtual;
         procedure Clear; virtual;
         procedure Reset; virtual;
         // Renders
         procedure Render; virtual;
         procedure PreRender(_Mesh : Pointer); virtual;
         procedure RenderVectorial(_Mesh : Pointer); virtual;
         procedure ForceRefresh; virtual;
         // Sets
         procedure SetColoursType(_ColoursType: integer); virtual;
         procedure SetNormalsType(_NormalsType: integer); virtual;
         procedure SetColoursAndNormalsType(_ColoursType, _NormalsType: integer); virtual;
         procedure ForceColoursRendering; virtual;
         // Materials
         procedure AddMaterial(const _ShaderBank: PShaderBank); virtual;
         procedure DeleteMaterial(_ID: integer); virtual;
         procedure ClearMaterials; virtual;
         function GetLastTextureID(_MaterialID: integer): integer; virtual;
         function GetNextTextureID(_MaterialID: integer): integer; virtual;
         function GetTextureSize(_MaterialID,_TextureID: integer): integer; virtual;
         // Copies
         procedure Assign(const _Geometry : TMeshGeometryBase); virtual;
         // Properties
         property NumFaces:longword read GetNumFaces write SetNumFaces;
   end;

implementation

// Constructors and Destructors
constructor TMeshGeometryBase.Create;
begin
   Next := nil;
   Initialize;
end;

destructor TMeshGeometryBase.Destroy;
begin
   Clear;
   Next := nil;
   inherited Destroy;
end;

procedure TMeshGeometryBase.Initialize;
begin
   FNumFaces := 0;
end;

procedure TMeshGeometryBase.Clear;
begin
   SetNumFaces(0);
end;

procedure TMeshGeometryBase.Reset;
begin
   Clear;
   Initialize;
end;

// Renders
procedure TMeshGeometryBase.Render;
begin
   // do nothing.
end;

procedure TMeshGeometryBase.PreRender(_Mesh : Pointer);
begin
   // do nothing.
end;

procedure TMeshGeometryBase.RenderVectorial(_Mesh : Pointer);
begin
   // do nothing.
end;

procedure TMeshGeometryBase.ForceRefresh;
begin
   // do nothing.
end;

// Gets
function TMeshGeometryBase.GetNumFaces: longword;
begin
   Result := FNumFaces;
end;

// Sets
procedure TMeshGeometryBase.SetNumFaces(_Value: longword);
begin
   FNumFaces := _Value;
end;

procedure TMeshGeometryBase.SetColoursType(_ColoursType: integer);
begin
   // do nothing
end;

procedure TMeshGeometryBase.SetNormalsType(_NormalsType: integer);
begin
  // do nothing
end;

procedure TMeshGeometryBase.SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
begin
   // do nothing.
end;

procedure TMeshGeometryBase.ForceColoursRendering;
begin
   // do nothing.
end;

// Materials
procedure TMeshGeometryBase.AddMaterial(const _ShaderBank: PShaderBank);
begin
   // do nothing.
end;

procedure TMeshGeometryBase.DeleteMaterial(_ID: integer);
begin
   // do nothing.
end;

procedure TMeshGeometryBase.ClearMaterials;
begin
   // do nothing.
end;

function TMeshGeometryBase.GetLastTextureID(_MaterialID: integer): integer;
begin
   Result := 0;
end;

function TMeshGeometryBase.GetNextTextureID(_MaterialID: integer): integer;
begin
   Result := 0;
end;

function TMeshGeometryBase.GetTextureSize(_MaterialID,_TextureID: integer): integer;
begin
   Result := 0;
end;


// Copies
procedure TMeshGeometryBase.Assign(const _Geometry : TMeshGeometryBase);
begin
   FNumFaces := _Geometry.NumFaces;
end;


end.
