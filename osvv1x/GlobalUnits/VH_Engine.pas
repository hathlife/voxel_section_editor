unit VH_Engine;
{

Title: Voxel HVA Engine
By: Stucuk

Note: This engine uses parts of OS HVA Builder and OS Voxel Viewer.

19 Oct 2005 - Revision by Stucuk

Improved rendering speed. VoxelBoxes revamped to do it by section.
Each section has its own OGL list so its only 'rendered' to the list once
and then called each time (so its faster). Also we now use the multimatrix
command so we don't need to apply the matrix each time to each box.

}

interface

Uses Windows,SysUtils,Controls,Classes,Graphics,JPEG,Palette,VH_Global,VH_GL,OpenGL15,VH_Voxel,
     VH_Display,TimerUnit,FormProgress,Textures,Menus,Math3d,GifImage,VVS,Voxel,Undo_Engine,VH_Types,
     HVA;

Function InitalizeVHE(Location,Palette : String; SCREEN_WIDTH,SCREEN_HEIGHT : Integer; Handle : HWND; Depth : single) : Boolean;
Procedure VH_Draw;
Procedure VH_MouseDown(Button: TMouseButton; X, Y: Integer);
Procedure VH_MouseUp;
Procedure VH_MouseMove(X,Y: Integer);
Procedure VH_LoadGroundTextures(frm: TFrmProgress);
Procedure VH_LoadSkyTextures(frm: TFrmProgress);
Procedure VH_BuildSkyBox;
Procedure VH_SetSpectrum(Colours : Boolean);
Procedure VH_BuildViewMenu(Var View : TMenuItem; Proc : TNotifyEvent);
Procedure VH_ChangeView(x : integer);
Procedure VH_SetBGColour(BGColour : TVector3f);

procedure VH_ScreenShot(Filename : string);
procedure VH_ScreenShotJPG(Filename : string; Compression : integer);
procedure VH_ScreenShotGIF(GIFIMAGE : TGIFImage; Filename : string);
function  VH_ScreenShot_BitmapResult : TBitmap;
procedure VH_ScreenShotToSHPBuilder;

Procedure VH_LoadVVS(Filename : String);
Procedure VH_SaveVVS(Filename : String);

Procedure VH_SaveVoxel(Filename : String);
Procedure VH_LoadVoxel(Filename : String);
Procedure VH_SaveHVA(Filename : String);

Procedure VH_ResetUndoRedo;
Procedure VH_AddHVAToUndo(HVA : PHVA; Frame,Section : Integer);
Procedure VH_ResetRedo;
Function VH_ISUndo : Boolean;
Function VH_ISRedo : Boolean;
Procedure VH_DoUndo;
Procedure VH_DoRedo;
Procedure VH_AddVOXELToUndo(Voxel : PVoxel; Frame,Section : Integer);

implementation

uses registry,clipbrd;

Function InitalizeVHE(Location,Palette : String; SCREEN_WIDTH,SCREEN_HEIGHT : Integer; Handle : HWND; Depth : single) : Boolean;
begin
   Result := False;

   VHLocation := Location;
   DefaultDepth := Depth;

   If not Fileexists(Location + '\' + Palette) then
   begin
      Messagebox(0,pchar('File Not Found: ' +#13+ Location + '\' + Palette),'File Missng',0);
      exit;
   end;

   Try
      LoadAPaletteFromFile(Location + '\' + Palette);
      InitGL(Handle);
      gTimer := TTimerSystem.Create;
      gTimer.Refresh;
   Except
      Exit;
   End;

   Result := True;
end;

Procedure VH_Draw;
begin
   If (not DrawVHWorld) or (not VoxelOpen) then Exit;

   gTimer.Refresh;
   glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);    // Clear The Screen And The Depth Buffer

   if XRotB then
      XRot := XRot + (XRot2 * 30) * gTimer.FrameTime;

   if YRotB then
      YRot := YRot + (YRot2 * 30) * gTimer.FrameTime;

   XRot := CleanAngle(XRot);
   YRot := CleanAngle(YRot);

   DrawWorld;

   SwapBuffers(H_DC);
end;

Procedure VH_MouseDown(Button: TMouseButton; X, Y: Integer);
begin
   if (not VoxelOpen) {or (not MVEnabled)} then exit;

   if Button = mbLeft  then
   begin
      MouseButton :=1;
      Xcoord := X;
      Ycoord := Y;
   end;
   if Button = mbRight then
   begin
      MouseButton :=2;
      Zcoord := Y;
      Xcoord2 := X;
      Ycoord2 := Y;
   end;
end;

Procedure VH_MouseUp;
begin
   if not VoxelOpen then exit;

   MouseButton :=0;
end;

Procedure VH_MouseMove(X,Y: Integer);
begin
   If MouseButton = 1 then
   begin
    FUpdateWorld := True;

      if Axis = 2 then
      begin
         if VHControlType = CToffset then
         begin
            ChangeOffset(CurrentVoxel^,CurrentVoxelSection,(Y - Ycoord)/2,0,0);
            Ycoord := Y;
            VXLChanged := True;
         end
         else if VHControlType = CThvaposition then
         begin
            SetHVAPos(CurrentHVA^,CurrentVoxelSection,(Y - Ycoord)/2,0,0);
            Ycoord := Y;
            VXLChanged := True;
         end
         else if VHControlType = CThvarotation then
         begin
            SETHVAAngle(CurrentHVA^,CurrentVoxelSection,GetCurrentFrame,(Y - Ycoord)/2,0,0);
            Ycoord := Y;
            VXLChanged := True;
         end;
      end;

      if Axis = 0 then
      begin
         if VHControlType = CToffset then
         begin
            ChangeOffset(CurrentVoxel^,CurrentVoxelSection,0,(Y - Ycoord)/2,0);
            Ycoord := Y;
            VXLChanged := True;
         end
         else if VHControlType = CThvaposition then
         begin
            SetHVAPos(CurrentHVA^,CurrentVoxelSection,0,(Y - Ycoord)/2,0);
            Ycoord := Y;
            VXLChanged := True;
         end
         else if VHControlType = CThvarotation then
         begin
            SETHVAAngle(CurrentHVA^,CurrentVoxelSection,GetCurrentFrame,0,(Y - Ycoord)/2,0);
            Ycoord := Y;
            VXLChanged := True;
         end;
      end;

      if Axis = 1 then
      begin
         if VHControlType = CToffset then
         begin
            ChangeOffset(CurrentVoxel^,CurrentVoxelSection,0,0,-(Y - Ycoord)/2);
            Ycoord := Y;
            VXLChanged := True;
         end
         else if VHControlType = CThvaposition then
         begin
            SetHVAPos(CurrentHVA^,CurrentVoxelSection,0,0,-(Y - Ycoord)/2);
            Ycoord := Y;
            VXLChanged := True;
         end
         else if VHControlType = CThvarotation then
         begin
            SETHVAAngle(CurrentHVA^,CurrentVoxelSection,GetCurrentFrame,0,0,-(Y - Ycoord)/2);
            Ycoord := Y;
            VXLChanged := True;
         end;
      end;

      if VHControlType = CTview then
      begin
         xRot := xRot + (Y - Ycoord)/2;  // moving up and down = rot around X-axis
         yRot := yRot + (X - Xcoord)/2;
         Xcoord := X;
         Ycoord := Y;
      end;
   end;

   If MouseButton = 2 then
   begin
    FUpdateWorld := True;

      if VHControlType = CTview then
      begin
         Depth :=Depth - (Y-ZCoord)/3;
         Zcoord := Y;
      end
      else
      begin
         xRot := xRot + (Y - Ycoord2)/2;  // moving up and down = rot around X-axis
         yRot := yRot + (X - Xcoord2)/2;
         Xcoord2 := X;
         Ycoord2 := Y;
      end;
   end;
end;

Procedure LoadGroundTexture(Dir,Ext : string; frm: TFrmProgress);
var
   f: TSearchRec;
   path: String;
begin
   path := Concat(Dir,'*'+Ext);
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      frm.UpdateAction('Ground: ' + f.Name);
      frm.Refresh;

      inc(GroundTex_No);
      SetLength(GroundTex_Textures,GroundTex_No);
      LoadTexture(Concat(Dir,f.Name),GroundTex_Textures[GroundTex_No-1].Tex,False,False,False);
      GroundTex_Textures[GroundTex_No-1].Name := Copy(f.Name,1,length(f.Name)-length(Ext));
      //showmessage('|' + ansilowercase(copy(GroundTex_Textures[GroundTex_No-1].Name,length(GroundTex_Textures[GroundTex_No-1].Name)-length('tile')+1,length(GroundTex_Textures[GroundTex_No-1].Name)))+'|');
      if ansilowercase(copy(GroundTex_Textures[GroundTex_No-1].Name,length(GroundTex_Textures[GroundTex_No-1].Name)-length('tile')+1,length(GroundTex_Textures[GroundTex_No-1].Name))) = 'tile' then
         GroundTex_Textures[GroundTex_No-1].Tile := true
      else
         GroundTex_Textures[GroundTex_No-1].Tile := false;
   until FindNext(f) <> 0;
   FindClose(f);
end;

Procedure VH_LoadGroundTextures(frm: TFrmProgress);
begin
   GroundTex_No := 0;
   LoadGroundTexture(ExtractFileDir(ParamStr(0)) + '\Textures\Ground\','.jpg',frm);
end;

Procedure LoadSkyTexture2(Ext, Fname, _type : string; id : integer);
var
   Filename : string;
begin
   Filename := copy(FName,1,length(Fname)-length(Ext)) + _type + copy(ext,length(ext)-length('_bk'),length(ext));

//SkyTexList[SkyTexList_No-1].Loaded := false;
//SkyTexList[SkyTexList_No-1].Filename[id] := Filename;
   LoadTexture(Filename,SkyTexList[SkyTexList_No-1].Textures[id],False,False,False);
   SkyTexList[SkyTexList_No-1].Texture_Name := extractfilename(Copy(Filename,1,length(Filename)-length(Ext)));
end;

Procedure LoadSkyTexture(Dir,Ext : string; frm: TFrmProgress);
var
   f: TSearchRec;
   path: String;
begin
   path := Concat(Dir,'*'+Ext);

   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      inc(SkyTexList_No);
      SetLength(SkyTexList,SkyTexList_No);

      frm.UpdateAction('Sky: ' + f.Name);
      frm.Refresh;

      LoadSkyTexture2(Ext,Concat(Dir,f.Name),'_rt',0);
      LoadSkyTexture2(Ext,Concat(Dir,f.Name),'_lf',1);
      LoadSkyTexture2(Ext,Concat(Dir,f.Name),'_ft',2);
      LoadSkyTexture2(Ext,Concat(Dir,f.Name),'_bk',3);
      LoadSkyTexture2(Ext,Concat(Dir,f.Name),'_up',4);
      LoadSkyTexture2(Ext,Concat(Dir,f.Name),'_dn',5);
   until FindNext(f) <> 0;
   FindClose(f);
end;

Procedure VH_LoadSkyTextures(frm: TFrmProgress);
begin
   SkyTexList_No := 0;
   LoadSkyTexture(ExtractFileDir(ParamStr(0)) + '\Textures\Sky\','_bk.jpg',frm);
end;

Procedure VH_BuildSkyBox;
begin
   BuildSkyBox;
end;

Procedure VH_SetSpectrum(Colours : Boolean);
begin
   SetSpectrum(Colours);
end;

Procedure VH_ChangeView(x : integer);
begin
   If (x > -1) and (x < VH_Views_No) then
   begin
      xRot := VH_Views[x].XRot;

      If not VH_Views[x].NotUnitRot then
         yRot := VH_Views[x].YRot-UnitRot
      else
         yRot := VH_Views[x].YRot;

      If VH_Views[x].Depth < 0 then
         Depth := VH_Views[x].Depth;
   end;
end;

Procedure VH_BuildViewMenu(Var View : TMenuItem; Proc : TNotifyEvent);
var
   Section,X : integer;
   Item : TMenuItem;
begin
   Section := 0;
   For x := 0 to VH_Views_No-1 do
   begin
      if VH_Views[x].Section <> Section then
      begin
         item := TMenuItem.Create(View);
         item.Caption := '-';
         View.Add(item);
         Section := VH_Views[x].Section;
      end;

      item := TMenuItem.Create(View);
      item.Caption := VH_Views[x].Name;
      item.Tag := x; // so we know which it is
      item.OnClick := Proc;
      View.Add(item);
   end; // Loop End
end; // Procedure End

Procedure VH_SetBGColour(BGColour : TVector3f);
begin
   BGColor := BGColour;
   glClearColor(BGColor.X, BGColor.Y, BGColor.Z, 1.0);
end;

procedure VH_ScreenShot(Filename : string);
var
   i: integer;
   t, FN, FN2, FN3 : string;
   SSDir : string;
   BMP : TBitmap;
begin
   // create the scrnshots directory if it doesn't exist
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
      if not fileexists(FN+'_'+t+'.bmp') then
      begin
         FN3 := FN+'_'+t+'.bmp';
         break;
      end;
   end;

   if FN3 = '' then
   begin
      exit;
   end;

   BMP := VH_ScreenShot_BitmapResult;
   BMP.SaveToFile(FN3);
   BMP.Free;
end;

procedure VH_ScreenShotToSHPBuilder;
var
   Reg : TRegistry;
   Path : String;
   Version : String;
   P : PChar;
   BMP : TBitmap;
begin
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   if not Reg.OpenKey('\SOFTWARE\CnC Tools\OS SHP Builder\',false) then
   begin
      MessageBox(0,'Incorrect SHP Builder Version','Error',0);
      exit;
   end;
   Version := Reg.ReadString('Version');
   if Version < '3.36' then
   begin
      MessageBox(0,'Incorrect SHP Builder Version','Error',0);
      exit;
   end;
   Path := Reg.ReadString('Path');
   Reg.CloseKey;
   Reg.Free;


   BMP := VH_ScreenShot_BitmapResult;
   Clipboard.Assign(BMP);
   BMP.Free;

   Path := Path + ' -Clipboard ' + inttostr(Screenshot.Width) + ' ' + inttostr(Screenshot.Height);

   p:=PChar(Path);
   WinExec(p,sw_ShowNormal);
end;

procedure VH_ScreenShotJPG(Filename : string; Compression : integer);
var
   i : integer;
   t, FN, FN2, FN3 : string;
   SSDir : string;
   JPEGImage: TJPEGImage;
   Bitmap : TBitmap;
begin
   // create the scrnshots directory if it doesn't exist
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
      if not fileexists(FN+'_'+t+'.jpg') then
      begin
         FN3 := FN+'_'+t+'.jpg';
         break;
      end;
   end;

   if FN3 = '' then
   begin
      exit;
   end;
   Bitmap := VH_ScreenShot_BitmapResult;
   JPEGImage := TJPEGImage.Create;
   JPEGImage.Assign(Bitmap);
   JPEGImage.CompressionQuality := 100-Compression;
   JPEGImage.SaveToFile(FN3);
   Bitmap.Free;
   JPEGImage.Free;
end;

procedure VH_ScreenShotGIF(GIFIMAGE : TGIFImage; Filename : string);
var
   i : integer;
   t, FN, FN2, FN3 : string;
   SSDir : string;
begin
   // create the scrnshots directory if it doesn't exist
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
      if not fileexists(FN+'_'+t+'.gif') then
      begin
         FN3 := FN+'_'+t+'.gif';
         break;
      end;
   end;

   if FN3 = '' then
   begin
      exit;
   end;
   GIFImage.SaveToFile(FN3);
   GIFImage.Free;
end;

function VH_ScreenShot_BitmapResult : TBitmap;
var
   RGBBits  : PRGBQuad;
   Pixel    : PRGBQuad;
   BMP,
   BMP2     : TBitmap;
   x,y      : Integer;
   Temp     : Byte;
   AllWhite : Boolean;
begin
   AllWhite := True;
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,FTexture);

   GetMem(RGBBits, GetPow2Size(SCREEN_WIDTH)*GetPow2Size(SCREEN_HEIGHT)*4);
   glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE, RGBBits);

   glDisable(GL_TEXTURE_2D);

   BMP := TBitmap.Create;
   BMP.PixelFormat := pf32Bit;
   BMP.Width       := GetPow2Size(SCREEN_WIDTH);
   BMP.Height      := GetPow2Size(SCREEN_HEIGHT);

   Pixel := RGBBits;
   for y := 0 to GetPow2Size(SCREEN_HEIGHT)-1 do
   for x := 0 to GetPow2Size(SCREEN_WIDTH)-1 do
      begin
         Temp              := Pixel.rgbRed;
         Pixel.rgbRed      := Pixel.rgbBlue;
         Pixel.rgbBlue     := Temp;

         Bmp.Canvas.Pixels[x,GetPow2Size(SCREEN_HEIGHT)-y-1] := RGB(Pixel.rgbRed,Pixel.rgbGreen,Pixel.rgbBlue);

         if (Pixel.rgbRed <> 255) or (Pixel.rgbGreen <> 255) or (Pixel.rgbBlue <> 255) then
         AllWhite := False;
//         Pixel.rgbReserved := 0;
         inc(Pixel);
      end;

   FreeMem(RGBBits);

   BMP2 := TBitmap.Create;
   BMP2.Width := SCREEN_WIDTH;
   BMP2.Height := SCREEN_HEIGHT;

   BMP2.Canvas.Draw(0,-(GetPow2Size(SCREEN_HEIGHT)-SCREEN_HEIGHT),BMP);
   BMP.Free;

   if AllWhite then
   begin
    BMP2.Free;
    Result := VH_ScreenShot_BitmapResult;
   end
   else
   Result := BMP2;
end;

Procedure VH_LoadVVS(Filename : String);
begin
   LoadVVS(Filename);
   FUpdateWorld := True;
end;

Procedure VH_SaveVVS(Filename : String);
begin
   SaveVVS(Filename);
end;

Procedure VH_LoadVoxel(Filename : String);
begin
   LoadVoxel(Filename);
   FUpdateWorld := True;
end;

Procedure SaveVoxel(Vxl : TVoxel; Filename,Ext : String);
var
   TFilename : string;
begin
   TFilename := extractfiledir(Filename) + '\' + copy(Extractfilename(Filename),1,Length(Extractfilename(Filename))-Length('.vxl')) + Ext;

   Vxl.SaveToFile(TFilename);
end;

Procedure VH_SaveVoxel(Filename : String);
begin
   VXLChanged := False;
   SaveVoxel(VoxelFile,Filename,'.vxl');

   if VoxelOpenT then
      SaveVoxel(VoxelTurret,Filename,'tur.vxl');
   if VoxelOpenB then
      SaveVoxel(VoxelBarrel,Filename,'barl.vxl');
end;

Procedure VH_SaveHVA(Filename : String);
begin
   SaveHVA(Filename);
end;

Procedure VH_ResetUndoRedo;
begin
   ResetUndoRedo;
end;

Procedure VH_AddHVAToUndo(HVA : PHVA; Frame,Section : Integer);
begin
   AddHVAToUndo(HVA,Frame,Section);
end;

Procedure VH_ResetRedo;
begin
   ResetRedo;
end;

Function VH_ISUndo : Boolean;
begin
   Result := ISUndo;
end;

Function VH_ISRedo : Boolean;
begin
   Result := ISRedo;
end;

Procedure VH_DoUndo;
begin
   DoUndo;
end;

Procedure VH_DoRedo;
begin
   DoRedo;
end;

Procedure VH_AddVOXELToUndo(Voxel : PVoxel; Frame,Section : Integer);
begin
   AddVOXELToUndo(Voxel,Frame,Section);
end;

end.
