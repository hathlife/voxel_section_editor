unit VH_GL;

interface

Uses Windows,OpenGL15,VH_Global,VH_Display;//,OpenGLWrapper;

Procedure InitGL(Handle : HWND);
procedure glResizeWnd(Width, Height : Integer);

implementation

Procedure InitGL(Handle : HWND);
var
   pfd : TPIXELFORMATDESCRIPTOR;
   pf  : Integer;
begin
   InitOpenGL; // Don't forget, or first gl-Call will result in an access violation! exit;

   // OpenGL initialisieren
   h_DC:=GetDC(Handle);

   // PixelFormat
   pfd.nSize:=sizeof(pfd);
   pfd.nVersion:=1;
   pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
   pfd.iPixelType:=PFD_TYPE_RGBA;      // PFD_TYPE_RGBA or PFD_TYPEINDEX
   pfd.cColorBits:=32;
   pfd.cStencilBits := 8;

   pf :=ChoosePixelFormat(h_DC, @pfd);   // Returns format that most closely matches above pixel format
   SetPixelFormat(h_DC, pf, @pfd);

   h_rc :=wglCreateContext(h_DC);    // Rendering Context = window-glCreateContext
   wglMakeCurrent(h_DC,h_rc);        // Make the DC (Form1) the rendering Context

   ActivateRenderingContext(h_DC, h_RC);


   glEnable(GL_TEXTURE_2D);                     // Enable Texture Mapping
   glClearColor(BGColor.X, BGColor.Y, BGColor.Z, 1.0);
   glShadeModel(GL_SMOOTH);                 // Enables Smooth Color Shading
   glClearDepth(1.0);                       // Depth Buffer Setup
   glEnable(GL_DEPTH_TEST);                 // Enable Depth Buffer
   glDepthFunc(GL_LESS);		           // The Type Of Depth Test To Do

   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   //Realy Nice perspective calculations

   BuildFont;

   glEnable(GL_CULL_FACE);
   glCullFace(GL_BACK);

   glEnable(GL_LIGHT0);
   glEnable(GL_LIGHTING);
   glEnable(GL_COLOR_MATERIAL);

   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

   xRot  := 0;
   yRot  := 0;
   Depth := DefaultDepth;

   oglloaded := true;

   wglSwapIntervalEXT(0);

   glResizeWnd(SCREEN_WIDTH,SCREEN_HEIGHT);

   SwapBuffers(H_DC);

   Randomize;
end;

procedure glResizeWnd(Width, Height : Integer);
begin
   SCREEN_WIDTH := Width;
   SCREEN_HEIGHT := Height;

   if (Height = 0) then                // prevent divide by zero exception
      Height := 1;
   glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
   glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
   glLoadIdentity();                   // Reset View
   gluPerspective(FOV, Width/Height, 4.0, DEPTH_OF_VIEW);  // Do the perspective calculations. Last value = max clipping depth
   glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
   glLoadIdentity();                   // Reset View

   FUpdateWorld := True;
end;

end.
