unit RenderEnvironment;

interface

uses Windows, dglOpenGL, Voxel_Engine, Camera, SysUtils;

type
   PRenderEnvironment = ^TRenderEnvironment;
   TRenderEnvironment = class
      private
         // Constructors and destructors.
         procedure CleanUpCameras;
      public
         Next : PRenderEnvironment;
//         Models: PModel;
         CameraList : PCamera;
         CurrentCamera : PCamera;
         Handle : THandle;
         DC : HDC;
         RC: HGLRC;
         // Font related
         FontListBase : GLuint;
         // Common Multipliers
         Size : single;
         Width : longword;
         Height: longword;
         // Time
         StartTime, ElapsedTime, LastTime : DWord;
         FFrequency : int64;
         FoldTime : int64;
         // Colours
         BackgroundColour,FontColour : TVector3f;
         // Counters
         PolyCount: longword;
         FPS : single;
         // Debug related.
         ShowDepth, ShowSpeed, ShowPolyCount, ShowRotations : boolean;
         IsEnabled : boolean;
         
         // Constructors;
         constructor Create(_Handle : THandle; _width, _height : longword);
         destructor Destroy; override;
         // Renders and Related
         procedure Render;
         procedure Resize(_width, _height: longword);
         // Adds
         function AddCamera: PCamera;
         procedure RemoveCamera(var _Camera : PCamera);

         // Miscelaneuos Text Related
         procedure BuildFont;
         procedure KillFont;
         procedure glPrint(_text : pchar);
   end;

implementation

// Constructors;
constructor TRenderEnvironment.Create(_Handle: Cardinal;  _width, _height : longword);
begin
   // The basics, to avoid memory issues.
   Next := nil;
   IsEnabled := false;
   // Environment colours.
   BackGroundColour   := SetVector(0.549,0.666,0.921); // RGB(140,170,235)
   FontColour := SetVector(1,1,1);
   Size      := 0.1;
   // Setup rendering context.
   Handle := _Handle;
   DC := GetDC(Handle);
   RC := CreateRenderingContext(DC,[opDoubleBuffered],32,24,0,0,0,0);
   ActivateRenderingContext(DC, RC);
   // Setup GL settings
   glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping
   glClearColor(BackGroundColour.X, BackGroundColour.Y, BackGroundColour.Z, 1.0);
   glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
   glClearDepth(1.0);                       // Depth Buffer Setup
   glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
   glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations
   // Build font
   BuildFont;
   // enable cull face
   glEnable(GL_CULL_FACE);
   glCullFace(GL_BACK);
   // Setup camera.
   CameraList := nil;
   AddCamera;
   // Setup time.
   StartTime :=GetTickCount();
   QueryPerformanceFrequency(FFrequency); // get high-resolution Frequency
   QueryPerformanceCounter(FoldTime);
   // Setup perspective and text settings.
   Resize(_width,_height);
   PolyCount := 0;
   ShowDepth := true;
   ShowSpeed := true;
   ShowPolyCount := true;
   ShowRotations := false;
   // The render is ready to work.
   IsEnabled := true;
end;

destructor TRenderEnvironment.Destroy;
begin
   IsEnabled := false;
   KillFont;
   CleanUpCameras;
   DeactivateRenderingContext;
   wglDeleteContext(rc);
   ReleaseDC(Handle, DC);
   inherited Destroy;
end;

procedure TRenderEnvironment.CleanUpCameras;
var
   MyCamera,NextCamera : PCamera;
begin
   MyCamera := CameraList;
   while MyCamera <> nil do
   begin
      NextCamera := MyCamera^.Next;
      RemoveCamera(MyCamera);
      MyCamera := NextCamera;
   end;
end;

// Renders
procedure TRenderEnvironment.Render;
var
   temp : int64;
   t2 : double;
begin
   // Here's the don't waste time checkup.
   if not IsEnabled then exit;   
   if CurrentCamera = nil then exit;
   // if ModelList = nil then exit;

   // Calculate time and FPS
   LastTime :=ElapsedTime;
   ElapsedTime := GetTickCount() - StartTime;     // Calculate Elapsed Time
   ElapsedTime :=(LastTime + ElapsedTime) DIV 2; // Average it out for smoother movement

   QueryPerformanceCounter(temp);
   t2 := temp - FoldTime;
   FoldTime := temp;
   FPS := FFrequency/t2;
   wglMakeCurrent(dc,rc);        // Make the DC the rendering Context

   // Rendering starts here
   // -------------------------------------------------------
   // Clear The Screen And The Depth Buffer
   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
   glClearColor(BackGroundColour.X, BackGroundColour.Y, BackGroundColour.Z, 1.0);

   // Process Camera
   CurrentCamera^.ProcessNextFrame;

   // Enable Lighting.
   glEnable(GL_LIGHT0);
   glEnable(GL_LIGHTING);
   glEnable(GL_COLOR_MATERIAL);

   glPushMatrix;
      CurrentCamera^.RotateCamera;

   glPopMatrix;
   CurrentCamera^.MoveCamera;

   // Final rendering part.
   glDisable(GL_TEXTURE_2D);

   glLoadIdentity;
   glDisable(GL_DEPTH_TEST);
   glMatrixMode(GL_PROJECTION);
   glPushMatrix;
   glLoadIdentity;
   glOrtho(0, Width, 0, Height, -1, 1);
   glMatrixMode(GL_MODELVIEW);
   glPushMatrix;
   glLoadIdentity;

   glDisable(GL_LIGHT0);
   glDisable(GL_LIGHTING);
   glDisable(GL_COLOR_MATERIAL);

   glColor3f(FontColour.X, FontColour.Y, FontColour.Z);

   glRasterPos2i(1, 2);
   glPrint(PChar('Voxels Used: ' + IntToStr(PolyCount)));

   if (ShowDepth) then
   begin
      glRasterPos2i(1, 13);
      glPrint(PChar('Depth: ' + IntToStr(trunc(CurrentCamera^.Position.Z))));
   end;

   if (ShowSpeed) then
   begin
      glRasterPos2i(1, Height - 9);
      glPrint(PChar('FPS: ' + IntToStr(trunc(FPS))));
   end;

   if ShowRotations then
   begin
      // Note: The Y from the program is still Z from the render.
      glRasterPos2i(1, Height - 19);
      glPrint(PChar('DEBUG -  XRot:' + floattostr(CurrentCamera^.Rotation.X) + ' YRot:' + floattostr(CurrentCamera^.Rotation.Z)));
   end;

   glMatrixMode(GL_PROJECTION);
   glPopMatrix;
   glMatrixMode(GL_MODELVIEW);
   glPopMatrix;
   glEnable(GL_DEPTH_TEST);
   // Rendering starts here
   // -------------------------------------------------------
   SwapBuffers(DC);                  // Display the scene
end;

procedure TRenderEnvironment.Resize(_width, _height: longword);
begin
   Width := _Width;
   Height := _Height;
   if Height = 0 then                // prevent divide by zero exception
      Height := 1;
   glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
   glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
   glLoadIdentity();                   // Reset View
   gluPerspective(45.0, Width/Height, 1.0, 500.0);  // Do the perspective calculations. Last value = max clipping depth
   glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
end;


// Adds
function TRenderEnvironment.AddCamera: PCamera;
var
   NewCamera,PreviousCamera : PCamera;
begin
   new(NewCamera);
   NewCamera^ := TCamera.Create;
   if CameraList = nil then
   begin
      CameraList := NewCamera;
   end
   else
   begin
      PreviousCamera := CameraList;
      while PreviousCamera^.Next <> nil do
         PreviousCamera := PreviousCamera^.Next;
      PreviousCamera^.Next := NewCamera;
   end;
   CurrentCamera := NewCamera;
end;


// Removes
procedure TRenderEnvironment.RemoveCamera(var _Camera : PCamera);
var
   PreviousCamera : PCamera;
begin
   if CameraList = nil then exit; // Can't delete from an empty list.
   if _Camera <> nil then
   begin
      // Check if it is the first camera.
      if _Camera = CameraList then
      begin
         CameraList := _Camera^.Next;
      end
      else // It could be inside the list, but it's not the first.
      begin
         PreviousCamera := CameraList;
         while (PreviousCamera^.Next <> nil) and (PreviousCamera^.Next <> _Camera) do
         begin
            PreviousCamera := PreviousCamera^.Next;
         end;
         if PreviousCamera^.Next = _Camera then
         begin
            PreviousCamera^.Next := _Camera^.Next;
         end
         else // nil -- not from this list.
            exit;
      end;
      // If it has past this stage, the camera is valid and was part of the list.
      // Now let's unlink other variables.
      if CurrentCamera = _Camera then
         CurrentCamera := CameraList;
      // Now we dispose the camera.
      _Camera^.Free;
      _Camera := nil;
   end;
end;


// Miscelaneous Text Related
procedure TRenderEnvironment.BuildFont;			                // Build Our Bitmap Font
var
   font: HFONT;                	                // Windows Font ID
begin
   FontListBase := glGenLists(256);       	                // Storage For 96 Characters
   font := CreateFont(9, 0,0,0, FW_NORMAL, 0, 0, 0, OEM_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY	, FF_DONTCARE + DEFAULT_PITCH, 'Terminal');
   SelectObject(DC, font);
   wglUseFontBitmaps(DC, 0, 127, FontListBase);
end;

procedure TRenderEnvironment.KillFont;     		                // Delete The Font
begin
  glDeleteLists(FontListBase, 256); 		                // Delete All 96 Characters
end;

procedure TRenderEnvironment.glPrint(_text : pchar);	                // Custom GL "Print" Routine
begin
  if (_Text = '') then   			        // If There's No Text
          Exit;					        // Do Nothing

  glPushAttrib(GL_LIST_BIT);				// Pushes The Display List Bits
  glListBase(FontListBase);					// Sets The Base Character
  glCallLists(length(_Text), GL_UNSIGNED_BYTE, _Text);	// Draws The Display List Text
  glPopAttrib();								// Pops The Display List Bits
end;



end.
