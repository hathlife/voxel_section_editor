unit Render;

interface

uses Windows, dglOpenGL, RenderEnvironment;

type
   TRender = class
      public
         Environment: PRenderEnvironment;

         // Constructors;
         constructor Create;
         destructor Destroy; override;
         procedure ClearAllEnvironments;
         // Render
         procedure Render;
         // Adds and Removes.
         function AddEnvironment(_Handle : THandle; _width, _height : longword): PRenderEnvironment;
   end;

implementation


constructor TRender.Create;
begin
   InitOpenGL;
   Environment := nil;
end;

destructor TRender.Destroy;
begin
   ClearAllEnvironments;
   inherited Destroy;
end;

// Adds
function TRender.AddEnvironment(_Handle : THandle; _width, _height : longword): PRenderEnvironment;
var
   NewEnvironment,CurrentEnvironment : PRenderEnvironment;
begin
   new(NewEnvironment);
   NewEnvironment^ := TRenderEnvironment.Create(_Handle,_width,_height);
   if Environment = nil then
   begin
      Environment := NewEnvironment;
   end
   else
   begin
      CurrentEnvironment := Environment;
      while CurrentEnvironment^.Next <> nil do
         CurrentEnvironment := CurrentEnvironment^.Next;
      CurrentEnvironment^.Next := NewEnvironment;
   end;
end;


procedure TRender.ClearAllEnvironments;
begin
   // Bla bla bla
end;

procedure TRender.Render;
 var
    CurrentEnv : PRenderEnvironment;
begin
   CurrentEnv := Environment;
   while CurrentEnv <> nil do
   begin
      CurrentEnv^.Next;
      CurrentEnv := CurrentEnv^.Next;
   end;
end;

end.
