unit RenderEnvironment;

interface

uses Windows, Graphics, dglOpenGL, Voxel_Engine, BasicDataTypes, Camera, SysUtils,
   Model, Actor, BasicFunctions, JPEG, PNGImage, GIFImage, FTGifAnimate;

type
   PRenderEnvironment = ^TRenderEnvironment;
   TRenderEnvironment = class
      private
         // Rendering
         FUpdateWorld : boolean;
         // Constructors and destructors.
         procedure CleanUpCameras;
         procedure CleanUpActors;
         // Screenshot
         procedure MakeMeAScreenshotName(var Filename: string; Ext : string);
         procedure ScreenshotJPG(const _Filename: string; _Compression: integer);
         procedure ScreenShotPNG(const _Filename : string; _Compression: integer);
         procedure ScreenShotTGA(const _Filename : string);
         procedure ScreenShotBMP(const _Filename : string);
         procedure ScreenShotGIF(_GIFImage : TGIFImage; const _Filename : string);
      public
         Next : PRenderEnvironment;
         ActorList: PActor;
         CameraList : PCamera;
         CurrentActor : PActor;
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
         // Screenshot & Animation related.
         ScreenTexture : cardinal;
         ScreenType : TScreenshotType;
         ScreenshotCompression: integer;
         ScreenFilename: string;
         AnimFrameCounter: integer;
         AnimFrameMax : integer;
         AnimFrameTime: integer; // in centiseconds.
         NonScreenCamera : PCamera;
         // Ambient Lighting
         LightAmb : TVector4f;
         LightDif: TVector4f;
         // Constructors;
         constructor Create(_Handle : THandle; _width, _height : longword);
         destructor Destroy; override;

         // Renders and Related
         procedure Render;
         procedure DrawCacheTexture(Texture : Cardinal; X,Y : Single; Width,Height,AWidth,AHeight : Cardinal; XOff : Cardinal = 0; YOff : Cardinal = 0; XOffWidth : Cardinal = Cardinal(-1); YOffHeight : Cardinal = Cardinal(-1));
         procedure Resize(_width, _height: longword);
         procedure RenderNormals;
         procedure RenderColours;
         procedure ForceRefresh;

         // Adds
         function AddCamera: PCamera;
         function AddActor: PActor;
         procedure RemoveCamera(var _Camera : PCamera);
         procedure RemoveActor(var _Actor : PActor);

         // Miscelaneuos Text Related
         procedure BuildFont;
         procedure KillFont;
         procedure glPrint(_text : pchar);

         // Screenshot related
         function GetScreenShot : TBitmap;
         procedure TakeScreenshot(const _Filename: string; _type: TScreenshotType; _Compression: integer = 0);
         procedure TakeAnimation(const _Filename: string; _NumFrames, _FrameDelay: integer; _type: TScreenshotType);
         procedure Take360Animation(const _Filename: string; _NumFrames, _FrameDelay: integer; _type: TScreenshotType);
         procedure StartAnimation;
         procedure AddFrame;
         procedure FinishAnimation;
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
   // Enable lighting
   glEnable(GL_LIGHT0);
   glEnable(GL_LIGHTING);
   glEnable(GL_COLOR_MATERIAL);
   // Setup camera.
   CameraList := nil;
   AddCamera;
   // Start without models
   ActorList := nil;
   // Setup time.
   StartTime := GetTickCount();
   QueryPerformanceFrequency(FFrequency); // get high-resolution Frequency
   QueryPerformanceCounter(FoldTime);
   // Lighting settings
   LightAmb := SetVector4f(134/255, 134/255, 134/255, 1.0);
   LightDif := SetVector4f(172/255, 172/255, 172/255, 1.0);
   wglSwapIntervalEXT(0);
   // Prepare screenshot variables.
   ScreenTexture := 0;
   AnimFrameCounter := 0;
   AnimFrameMax := 0;
   AnimFrameTime := 3; //about 30fps.
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
   CleanUpActors;
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
   FUpdateWorld := true;
end;

procedure TRenderEnvironment.CleanUpActors;
var
   MyActor,NextActor : PActor;
begin
   MyActor := ActorList;
   while MyActor <> nil do
   begin
      NextActor := MyActor^.Next;
      RemoveActor(MyActor);
      MyActor := NextActor;
   end;
   FUpdateWorld := true;
end;

// Renders
procedure TRenderEnvironment.Render;
var
   temp : int64;
   t2 : double;
   Actor : PActor;
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
   FUpdateWorld := FUpdateWorld or CurrentCamera^.GetRequestUpdateWorld;
   // Process Actors
   Actor := ActorList;
   while Actor <> nil do
   begin
      Actor^.ProcessNextFrame;
      FUpdateWorld := FUpdateWorld or Actor^.GetRequestUpdateWorld;
      Actor := Actor^.Next;
   end;

   // Enable Lighting.
   glEnable(GL_LIGHT0);
   glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmb);
   glLightfv(GL_LIGHT0, GL_DIFFUSE, @LightDif);
   glEnable(GL_LIGHTING);
   glEnable(GL_COLOR_MATERIAL);

   if FUpdateWorld then
   begin
      FUpdateWorld := false;
      CurrentCamera^.MoveCamera;
      CurrentCamera^.RotateCamera;

      // Render all models.
      PolyCount := 0;
      Actor := ActorList;
      while Actor <> nil do
      begin
         Actor^.Render(Polycount);
         Actor := Actor^.Next;
      end;

      glColor3f(1,1,1);
      glNormal3f(0,0,0);
      // Here we cache the existing scene in a texture.
      glEnable(GL_TEXTURE_2D);
      if ScreenTexture <> 0 then
         glDeleteTextures(1,@ScreenTexture);
      glGenTextures(1, @ScreenTexture);
      glBindTexture(GL_TEXTURE_2D, ScreenTexture);
      glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, GetPow2Size(Width),GetPow2Size(Height), 0);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
      glDisable(GL_TEXTURE_2D);
      // End of texture caching.
   end;
   glLoadIdentity;
   // Final rendering part.
   glDisable(GL_LIGHT0);
   glDisable(GL_LIGHTING);
   glDisable(GL_COLOR_MATERIAL);
   glDisable(GL_DEPTH_TEST);
   glMatrixMode(GL_PROJECTION);
   glPushMatrix;
      glLoadIdentity;
      glOrtho(0, Width, 0, Height, -1, 1);
      glMatrixMode(GL_MODELVIEW);
      glPushMatrix;
         glLoadIdentity;
         // Draw texture caching.
         glEnable(GL_TEXTURE_2D);
         glColor3f(1,1,1);
         DrawCacheTexture(ScreenTexture,0,0,Width,Height,GetPow2Size(Width),GetPow2Size(Height));
         glDisable(GL_TEXTURE_2D);
         // End of draw texture caching.
         // Are we screenshoting?
         if AnimFrameMax = 0 then
         begin
            glColor3f(FontColour.X, FontColour.Y, FontColour.Z);
            // No, we are not screenshoting, so show normal stats.
            glRasterPos2i(1, 2);
            glPrint(PChar('Polygons Used: ' + IntToStr(PolyCount)));

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
               glPrint(PChar('DEBUG -  XRot:' + floattostr(CurrentCamera^.Rotation.X) + ' YRot:' + floattostr(CurrentCamera^.Rotation.Y) + ' ZRot:' + floattostr(CurrentCamera^.Rotation.Z)));
            end;
         end
         else // We are screenshoting!
         begin
            // Let's check if the animation is over or not.
            inc(AnimFrameCounter);
            if AnimFrameCounter < AnimFrameMax then
            begin
               // We are still animating. Simply add the frame.
               AddFrame;
            end
            else
            begin
               // Animation is over. Let's conclude the movie.
               FinishAnimation;

               // Reset animation variables.
               AnimFrameCounter := 0;
               AnimFrameMax := 0;
            end;
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

// Borrowed from OS: Voxel Viewer 1.80+, coded by Stucuk.
procedure TRenderEnvironment.DrawCacheTexture(Texture : Cardinal; X,Y : Single; Width,Height,AWidth,AHeight : Cardinal; XOff : Cardinal = 0; YOff : Cardinal = 0; XOffWidth : Cardinal = Cardinal(-1); YOffHeight : Cardinal = Cardinal(-1));
var
   TexCoordX,
   TexCoordY,
   TexCoordOffX,
   TexCoordOffY : Single;
begin
   if XOffWidth = Cardinal(-1) then
      XOffWidth    := Width;
   if YOffHeight = Cardinal(-1) then
      YOffHeight   := Height;
   TexCoordX    := XOffWidth/AWidth;
   TexCoordY    := YOffHeight/AHeight;
   TexCoordOffX := XOff/AWidth;
   TexCoordOffY := YOff/AHeight;
   glBindTexture(GL_TEXTURE_2D, Texture);
   glBegin(GL_QUADS);
      //1
      glTexCoord2f(TexCoordOffX, TexCoordOffY);
      glVertex2f(X, Y);
      //2
      glTexCoord2f(TexCoordOffX+TexCoordX, TexCoordOffY);
      glVertex2f(X+Width, Y);
      //3
      glTexCoord2f(TexCoordOffX+TexCoordX, TexCoordOffY+TexCoordY);
      glVertex2f(X+Width, Y+Height);
      //4
      glTexCoord2f(TexCoordOffX, TexCoordOffY+TexCoordY);
      glVertex2f(X, Y+Height);
   glEnd;
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
   gluPerspective(45.0, Width/Height, 1.0, 4000.0);  // Do the perspective calculations. Last value = max clipping depth
   glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
   FUpdateWorld := true;
end;

procedure TRenderEnvironment.RenderNormals;
var
   Actor : PActor;
begin
   Actor := ActorList;
   while Actor <> nil do
   begin
      Actor^.SetNormalsModeRendering;
      Actor := Actor^.Next;
   end;
   FUpdateWorld := true;
end;

procedure TRenderEnvironment.RenderColours;
var
   Actor : PActor;
begin
   Actor := ActorList;
   while Actor <> nil do
   begin
      Actor^.SetColourModeRendering;
      Actor := Actor^.Next;
   end;
   FUpdateWorld := true;
end;

procedure TRenderEnvironment.ForceRefresh;
begin
   FUpdateWorld := true;
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
   Result := NewCamera;
   FUpdateWorld := true;
end;

function TRenderEnvironment.AddActor: PActor;
var
   NewActor,PreviousActor : PActor;
begin
   new(NewActor);
   NewActor^ := TActor.Create;
   if ActorList = nil then
   begin
      ActorList := NewActor;
   end
   else
   begin
      PreviousActor := ActorList;
      while PreviousActor^.Next <> nil do
         PreviousActor := PreviousActor^.Next;
      PreviousActor^.Next := NewActor;
   end;
   CurrentActor := NewActor;
   Result := NewActor;
   FUpdateWorld := true;
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
      FUpdateWorld := true;
   end;
end;

procedure TRenderEnvironment.RemoveActor(var _Actor : PActor);
var
   PreviousActor : PActor;
begin
   if ActorList = nil then exit; // Can't delete from an empty list.
   if _Actor <> nil then
   begin
      // Check if it is the first actor.
      if _Actor = ActorList then
      begin
         ActorList := _Actor^.Next;
      end
      else // It could be inside the list, but it's not the first.
      begin
         PreviousActor := ActorList;
         while (PreviousActor^.Next <> nil) and (PreviousActor^.Next <> _Actor) do
         begin
            PreviousActor := PreviousActor^.Next;
         end;
         if PreviousActor^.Next = _Actor then
         begin
            PreviousActor^.Next := _Actor^.Next;
         end
         else // nil -- not from this list.
            exit;
      end;
      // If it has past this stage, the camera is valid and was part of the list.
      // Now we dispose the actor.
      _Actor^.Free;
      _Actor := nil;
      FUpdateWorld := true;
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

// Screenshot related
procedure TRenderEnvironment.MakeMeAScreenshotName(var Filename: string; Ext : string);
var
   i: integer;
   t, FN, FN2 : string;
   SSDir : string;
begin
   // create the screenshots directory if it doesn't exist
   SSDir := extractfiledir(Paramstr(0))+'\ScreenShots\';
   FN2 := extractfilename(Filename);
   FN2 := copy(FN2,1,length(FN2)-length(Extractfileext(FN2)));

 // sys_mkdir
   {$I-}
   CreateDir(SSDir);
//  MkDir(SSDir);
   {$I+}
   FN := SSDir+FN2;

   for i := 0 to 999 do
   begin
      t := inttostr(i);
      if length(t) < 3 then
         t := '00'+t
      else if length(t) < 2 then
         t := '0'+t;
      if not fileexists(FN+'_'+t+Ext) then
      begin
         Filename := FN+'_'+t+Ext;
         break;
      end;
   end;
end;

// Borrowed and adapted from Stucuk's code from OS: Voxel Viewer 1.80+ without AllWhite.
function TRenderEnvironment.GetScreenShot : TBitmap;
var
   RGBBits  : PRGBQuad;
   Pixel    : PRGBQuad;
   BMP     : TBitmap;
   x,y      : Integer;
   Pow2Width, Pow2Height, maxx, maxy : cardinal;
begin
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,ScreenTexture);
   Pow2Width := GetPow2Size(Width);
   Pow2Height:= GetPow2Size(Height);

   GetMem(RGBBits, Pow2Width * Pow2Height * 4);
   glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE, RGBBits);

   glDisable(GL_TEXTURE_2D);

   BMP := TBitmap.Create;
   BMP.PixelFormat := pf32Bit;
   BMP.Width       := Pow2Width;
   BMP.Height      := Pow2Height;

   Pixel := RGBBits;
   maxy := Pow2Height-1;
   maxx := Pow2Width-1;

   for y := 0 to maxy do
      for x := 0 to maxx do
      begin
         Bmp.Canvas.Pixels[x,maxy-y] := RGB(Pixel.rgbBlue,Pixel.rgbGreen,Pixel.rgbRed);
         inc(Pixel);
      end;

   FreeMem(RGBBits);

   Result := TBitmap.Create;
   Result.Width := Width;
   Result.Height := Height;

   Result.Canvas.Draw(0,-(Pow2Height-Height),BMP);
   BMP.Free;
end;

procedure TRenderEnvironment.ScreenShotJPG(const _Filename : string; _Compression : integer);
var
   Filename : string;
   JPEGImage: TJPEGImage;
   Bitmap : TBitmap;
begin
   // Get filename.
   Filename := CopyString(_Filename);
   MakeMeAScreenshotName(Filename,'.jpg');

   if Filename = '' then
      exit;

   Bitmap := GetScreenShot;
   JPEGImage := TJPEGImage.Create;
   JPEGImage.Assign(Bitmap);
   JPEGImage.CompressionQuality := _Compression;
   JPEGImage.SaveToFile(Filename);
   Bitmap.Free;
   JPEGImage.Free;
end;

procedure TRenderEnvironment.ScreenShotPNG(const _Filename : string; _Compression: integer);
var
  Filename : string;
  PNGImage: TPNGObject;
  Bitmap : TBitmap;
begin
   // Get filename.
   Filename := CopyString(_Filename);
   MakeMeAScreenshotName(Filename,'.png');

   if Filename = '' then
      exit;

  Bitmap := GetScreenShot;
  PNGImage := TPNGObject.Create;
  PNGImage.Assign(Bitmap);
  PNGImage.CompressionLevel := _Compression;
  PNGImage.SaveToFile(Filename);
  Bitmap.Free;
  PNGImage.Free;
end;

procedure TRenderEnvironment.ScreenShotTGA(const _Filename : string);
var
   Filename : string;
   buffer: array of byte;
   i, c, temp: integer;
   f: file;
begin
   // Get filename.
   Filename := CopyString(_Filename);
   MakeMeAScreenshotName(Filename,'.tga');

   if Filename = '' then
      exit;

   try
      SetLength(buffer, (Width * Height * 4) + 18);
      begin
         for i := 0 to 17 do
            buffer[i] := 0;
         buffer[2] := 2; //uncompressed type
         buffer[12] := Width and $ff;
         buffer[13] := Width shr 8;
         buffer[14] := Height and $ff;
         buffer[15] := Height shr 8;
         buffer[16] := 24; //pixel size

         glReadPixels(0, 0, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, Pointer(Cardinal(buffer) + 18));

         AssignFile(f, Filename);
         Rewrite(f, 1);

         for i := 0 to 17 do
            BlockWrite(f, buffer[i], sizeof(byte) , temp);

         c := 18;
         for i := 0 to (Width * Height)-1 do
         begin
            BlockWrite(f, buffer[c+2], sizeof(byte) , temp);
            BlockWrite(f, buffer[c+1], sizeof(byte) , temp);
            BlockWrite(f, buffer[c], sizeof(byte) , temp);
            inc(c,4);
         end;
         closefile(f);
      end;
   finally
      finalize(buffer);
   end;
end;

procedure TRenderEnvironment.ScreenShotBMP(const _Filename : string);
var
   Filename : string;
   Bitmap : TBitmap;
begin
   // Get filename.
   Filename := CopyString(_Filename);
   MakeMeAScreenshotName(Filename,'.bmp');

   if Filename = '' then
      exit;

  Bitmap := GetScreenShot;
  Bitmap.SaveToFile(Filename);
  Bitmap.Free;
end;

procedure TRenderEnvironment.ScreenShotGIF(_GIFImage : TGIFImage; const _Filename : string);
var
   Filename : string;
begin
   // Get filename.
   Filename := CopyString(_Filename);
   MakeMeAScreenshotName(Filename,'.gif');

   if Filename = '' then
      exit;

   _GIFImage.SaveToFile(Filename);
   _GIFImage.Free;
end;

procedure TRenderEnvironment.TakeScreenshot(const _Filename: string; _type: TScreenshotType; _Compression: integer = 0);
begin
   ScreenFilename:= CopyString(_Filename);
   ScreenshotCompression := 100-_Compression;
   AnimFrameMax := 1;
   AnimFrameTime := 10;
   NonScreenCamera := CurrentCamera;
   StartAnimation;
end;

procedure TRenderEnvironment.TakeAnimation(const _Filename: string; _NumFrames, _FrameDelay: integer; _type: TScreenshotType);
begin
   ScreenFilename:= CopyString(_Filename);
   AnimFrameMax := _NumFrames;
   AnimFrameTime := _FrameDelay;
   NonScreenCamera := CurrentCamera;
   StartAnimation;
end;

procedure TRenderEnvironment.Take360Animation(const _Filename: string; _NumFrames, _FrameDelay: integer; _type: TScreenshotType);
begin
   ScreenFilename:= CopyString(_Filename);
   AnimFrameMax := _NumFrames;
   AnimFrameTime := _FrameDelay;
   NonScreenCamera := CurrentCamera;
   CurrentCamera := AddCamera;
   CurrentCamera^.SetPosition(NonScreenCamera^.Position);
   CurrentCamera^.SetPositionSpeed(0,0,0);
   CurrentCamera^.SetPositionAcceleration(0,0,0);
   CurrentCamera^.SetRotation(NonScreenCamera^.Rotation);
   CurrentCamera^.SetRotationSpeed((_NumFrames / 360.0),0,0);
   CurrentCamera^.SetRotationAcceleration(0,0,0);
   StartAnimation;
end;

procedure TRenderEnvironment.StartAnimation;
begin
   AnimFrameCounter := 0;
   if ScreenType = stGif then
   begin
      GifAnimateBegin;
   end;
end;

procedure TRenderEnvironment.AddFrame;
begin
   case ScreenType of
      stBmp:
      begin
         ScreenShotBMP(ScreenFilename);
      end;
      stTga:
      begin
         ScreenShotTGA(ScreenFilename);
      end;
      stJpg:
      begin
         ScreenShotJPG(ScreenFilename,ScreenshotCompression);
      end;
      stGif:
      begin
         GifAnimateAddImage(GetScreenShot, False, AnimFrameTime);
      end;
      stPng:
      begin
         ScreenShotPNG(ScreenFilename,ScreenshotCompression);
      end;
   end;
end;

procedure TRenderEnvironment.FinishAnimation;
begin
   case ScreenType of
      stBmp:
      begin
         ScreenShotBMP(ScreenFilename);
      end;
      stTga:
      begin
         ScreenShotTGA(ScreenFilename);
      end;
      stJpg:
      begin
         ScreenShotJPG(ScreenFilename,ScreenshotCompression);
      end;
      stGif:
      begin
         ScreenShotGIF(GifAnimateEndGif, ScreenFilename);
      end;
      stPng:
      begin
         ScreenShotPNG(ScreenFilename,ScreenshotCompression);
      end;
   end;
   AnimFrameMax := 0;
   ScreenType := stNone;
   if CurrentCamera <> NonScreenCamera then
   begin
      RemoveCamera(CurrentCamera);
      CurrentCamera := NonScreenCamera;
   end;
end;




end.
