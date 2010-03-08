unit Render;

interface

uses Windows, dglOpenGL, RenderEnvironment, BasicFunctions;

type
   TRender = class
      private
         FPSCap : longword;
         FirstRC : HGLRC;
         ShaderDirectory: string;
         // Misc
         procedure ForceFPS;
      public
         Environment: PRenderEnvironment;

         // Constructors;
         constructor Create(const _ShaderDirectory: string);
         destructor Destroy; override;
         procedure ClearAllEnvironments;
         // Render
         procedure Render;
         // Sets
         procedure SetFPS(_FPS: longword);
         // Adds and Removes.
         function AddEnvironment(_Handle : THandle; _width, _height : longword): PRenderEnvironment;
         procedure RemoveEnvironment(var _Environment: PRenderEnvironment);
   end;

implementation


constructor TRender.Create(const _ShaderDirectory: string);
begin
   InitOpenGL;
   FirstRC := 0;
   ShaderDirectory := CopyString(_ShaderDirectory);
   Environment := nil;
end;

destructor TRender.Destroy;
begin
   ClearAllEnvironments;
   inherited Destroy;
end;

// Sets
procedure TRender.SetFPS(_FPS: longword);
begin
   FPSCap := _FPS;
   ForceFPS;
end;

// Adds
function TRender.AddEnvironment(_Handle : THandle; _width, _height : longword): PRenderEnvironment;
var
   NewEnvironment,CurrentEnvironment : PRenderEnvironment;
begin
   new(NewEnvironment);
   NewEnvironment^ := TRenderEnvironment.Create(_Handle,FirstRC,_width,_height,ShaderDirectory);
   if Environment = nil then
   begin
      Environment := NewEnvironment;
      FirstRC := NewEnvironment^.RC;
   end
   else
   begin
      CurrentEnvironment := Environment;
      while CurrentEnvironment^.Next <> nil do
         CurrentEnvironment := CurrentEnvironment^.Next;
      CurrentEnvironment^.Next := NewEnvironment;
   end;
   ForceFPS;
   Result := NewEnvironment;
end;

// Removes
procedure TRender.RemoveEnvironment(var _Environment : PRenderEnvironment);
var
   PreviousEnvironment : PRenderEnvironment;
begin
   if Environment = nil then exit; // Can't delete from an empty list.
   if _Environment <> nil then
   begin
      // Check if it is the first element.
      if _Environment = Environment then
      begin
         Environment := _Environment^.Next;
         if Environment <> nil then
         begin
            FirstRC := Environment^.RC;
         end
         else
         begin
            FirstRC := 0;
         end;
      end
      else // It could be inside the list, but it's not the first.
      begin
         PreviousEnvironment := Environment;
         while (PreviousEnvironment^.Next <> nil) and (PreviousEnvironment^.Next <> _Environment) do
         begin
            PreviousEnvironment := PreviousEnvironment^.Next;
         end;
         if PreviousEnvironment^.Next = _Environment then
         begin
            PreviousEnvironment^.Next := _Environment^.Next;
         end
         else // nil -- not from this list.
            exit;
      end;
      // If it has past this stage, the element is valid and was part of the list.
      // Now we dispose the camera.
      _Environment^.Free;
   end;
end;


procedure TRender.ClearAllEnvironments;
var
   MyEnvironment,NextEnvironment : PRenderEnvironment;
begin
   MyEnvironment := Environment;
   while MyEnvironment <> nil do
   begin
      NextEnvironment := MyEnvironment^.Next;
      RemoveEnvironment(MyEnvironment);
      MyEnvironment := NextEnvironment;
   end;
end;

procedure TRender.Render;
 var
   CurrentEnv : PRenderEnvironment;
begin
   CurrentEnv := Environment;
   while CurrentEnv <> nil do
   begin
      CurrentEnv^.Render;
      CurrentEnv := CurrentEnv^.Next;
   end;
end;

// Misc
procedure TRender.ForceFPS;
var
   Frequency: int64;
   DesiredTimeRate : int64;
   CurrentEnv : PRenderEnvironment;
begin
   QueryPerformanceFrequency(Frequency); // get high-resolution Frequency
   DesiredTimeRate := Round(Frequency / FPSCap);
   CurrentEnv := Environment;
   while CurrentEnv <> nil do
   begin
      CurrentEnv^.DesiredTimeRate := DesiredTimeRate;
      CurrentEnv := CurrentEnv^.Next;
   end;
end;

end.
