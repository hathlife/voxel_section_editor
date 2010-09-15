unit MeshPluginBase;

interface

type
   TMeshPluginBase = class
      protected
         procedure DoRender(); virtual;
         procedure DoUpdate(); virtual;
      public
         AllowUpdate: boolean;
         AllowRender: boolean;
         // Constructors and destructors
         destructor Destroy; override;
         procedure Initialize(); virtual;
         procedure Clear(); virtual;
         procedure Reset();
         // Rendering functions
         procedure Render();
         procedure Update();
   end;

implementation

// Constructors and destructors
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

end.
