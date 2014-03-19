unit MeshPluginBase;

interface

uses GlConstants, ShaderBank;

type
   PMeshPluginBase = ^TMeshPluginBase;
   TSetShaderAttributesFunc = procedure (const _ShaderBank: PShaderBank; _VertexID: integer; const _PPlugin: PMeshPluginBase) of object;
   TMeshPluginBase = class
      protected
         FPluginType : integer;
         procedure DoRender(); virtual;
         procedure DoUpdate(_MeshAddress: Pointer); virtual;
         function GetPluginType: integer;
      public
         AllowUpdate: boolean;
         AllowRender: boolean;
         // Constructors and destructors
         constructor Create;
         destructor Destroy; override;
         procedure Initialize(); virtual;
         procedure Clear(); virtual;
         procedure Reset();
         // Rendering functions
         procedure Render();
         procedure Update(_MeshAddress: Pointer);
         // Copy
         procedure Assign(const _Source: TMeshPluginBase); virtual;
         // properties
         property PluginType: integer read GetPluginType;
   end;
   TAMeshPluginBase = array of TMeshPluginBase;
   PAMeshPluginBase = array of PMeshPluginBase;

implementation

// Constructors and destructors
constructor TMeshPluginBase.Create;
begin
   FPluginType := C_MPL_BASE;
end;

destructor TMeshPluginBase.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TMeshPluginBase.Initialize;
begin
   AllowUpdate := true;
   AllowRender := true;
end;

procedure TMeshPluginBase.Clear;
begin
   // do nothing
end;

procedure TMeshPluginBase.Reset;
begin
   Clear;
   Initialize;
end;

// Rendering functions
procedure TMeshPluginBase.Render;
begin
   if AllowRender then
   begin
      DoRender;
   end;
end;

procedure TMeshPluginBase.DoRender;
begin
   // do nothing
end;

procedure TMeshPluginBase.Update(_MeshAddress: Pointer);
begin
   if AllowUpdate then
   begin
      DoUpdate(_MeshAddress);
   end;
end;

procedure TMeshPluginBase.DoUpdate(_MeshAddress: Pointer);
begin
   // do nothing
end;


function TMeshPluginBase.GetPluginType: integer;
begin
   Result := FPluginType;
end;

// Copy
procedure TMeshPluginBase.Assign(const _Source: TMeshPluginBase);
begin
   AllowUpdate := _Source.AllowUpdate;
   AllowRender := _Source.AllowRender;
end;


end.
