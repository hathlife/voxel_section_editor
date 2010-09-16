unit MeshPluginBase;

interface

uses GlConstants;

type
   TMeshPluginBase = class
      protected
         FPluginType : integer;
         procedure DoRender(); virtual;
         procedure DoUpdate(); virtual;
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
         procedure Update();
         // properties
         property PluginType: integer read GetPluginType;
   end;
   PMeshPluginBase = ^TMeshPluginBase;
   TAMeshPluginBase = array of TMeshPluginBase;
   PAMeshPluginBase = ^TAMeshPluginBase;

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

procedure TMeshPluginBase.Update;
begin
   if AllowUpdate then
   begin
      DoUpdate;
   end;
end;

procedure TMeshPluginBase.DoUpdate;
begin
   // do nothing
end;


function TMeshPluginBase.GetPluginType: integer;
begin
   Result := FPluginType;
end;

end.
