//----------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://www.sulaco.co.za
//               http://home.global.co.za/~jhorn
// Version     : 1.03
// Date        : 1 May 2001
// Changes     : 28 July   2001 - Faster BGR to RGB swapping routine
//               2 October 2001 - Added support for 24, 32bit TGA files
//               28 April  2002 - Added support for compressed TGA files
//
// Description : A unit that used with OpenGL projects to load BMP, JPG and TGA
//               files from the disk or a resource file.
// Usage       : LoadTexture(Filename, TextureName, LoadFromResource);
//
//               eg : LoadTexture('logo.jpg', LogoTex, TRUE);
//                    will load a JPG texture from the resource included
//                    with the EXE. File has to be loaded into the Resource
//                    using this format  "logo JPEG logo.jpg"
//
//----------------------------------------------------------------------------
unit Textures;

interface

uses
  Windows, OpenGL15, Graphics, Classes, JPEG, SysUtils, PNGImage;

type
   TTexInfo = record
      ID : cardinal;
      Width,Height : integer;
   end;

var
   TexInfo : array of TTexInfo;
   TexInfo_No : integer = 0;

Function GetTexInfoNo(Texture : cardinal) : integer;

function initLocking : boolean;
function LoadTexture(Filename: String; var Texture : GLuint; LoadFromRes, NoPicMip, NoMipMap : Boolean) : Boolean;
function LoadQuakeTexture(path, name : string; var Texture : GLUINT; NoPicMip, NoMipMap : boolean) : boolean;
function LoadTGATexture(Filename: String; var Texture: GLuint; LoadFromResource, NoPicMip, NoMipMap : Boolean): Boolean;

implementation

uses Dialogs;

Function GetTexInfoNo(Texture : cardinal) : integer;
var
   X : integer;
begin
   if TexInfo_No > 0 then
      for x := 0 to TexInfo_No-1 do
         if TexInfo[x].ID = Texture then
         begin
            Result := x;
            Exit;
         end;

   Result := 1;
end;

// Swap bitmap format from BGR to RGB
procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;


// Create the Texture                                              }
function CreateTexture(Width, Height, Format : Word; pData : Pointer; NoPicMip, NoMipMap : boolean) : Integer;
var
   Texture : GLuint;
begin
   glGenTextures(1, @Texture);
   glBindTexture(GL_TEXTURE_2D, Texture);

   glEnable(GL_TEXTURE_2D);

//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}

   if NoPicMip then
   begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   end
   else
   begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   end;
   if NoMipMap then
   begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, 4, Width, Height, 0, Format, GL_UNSIGNED_BYTE, pData)
   end
   else
   begin
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
      gluBuild2DMipmaps(GL_TEXTURE_2D, 4, Width, Height, Format, GL_UNSIGNED_BYTE, pData);
   end;
   inc(TexInfo_No);
   SetLength(TexInfo,TexInfo_No);
   TexInfo[TexInfo_No-1].ID := Texture;
   TexInfo[TexInfo_No-1].Width := Width;
   TexInfo[TexInfo_No-1].Height := Height;

   result := Texture;
end;


{------------------------------------------------------------------}
{  Load BMP textures                                               }
{------------------------------------------------------------------}
function LoadBMPTexture(Filename: String; var Texture : GLuint; LoadFromResource, NoPicMip, NoMipMap : Boolean) : Boolean;
var
   FileHeader: BITMAPFILEHEADER;
   InfoHeader: BITMAPINFOHEADER;
   Palette: array of RGBQUAD;
   BitmapFile: THandle;
   BitmapLength: LongWord;
   PaletteLength: LongWord;
   ReadBytes: LongWord;
   Width, Height : Integer;
   pData : Pointer;

   // used for loading from resource
   ResStream : TResourceStream;
begin
   result :=FALSE;

   if LoadFromResource then // Load from resource
   begin
      try
         ResStream := TResourceStream.Create(hInstance, PChar(copy(Filename, 1, Pos('.', Filename)-1)), 'BMP');
         ResStream.ReadBuffer(FileHeader, SizeOf(FileHeader));  // FileHeader
         ResStream.ReadBuffer(InfoHeader, SizeOf(InfoHeader));  // InfoHeader
         PaletteLength := InfoHeader.biClrUsed;
         SetLength(Palette, PaletteLength);
         ResStream.ReadBuffer(Palette, PaletteLength);          // Palette

         Width := InfoHeader.biWidth;
         Height := InfoHeader.biHeight;

         BitmapLength := InfoHeader.biSizeImage;
         if BitmapLength = 0 then
            BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

         GetMem(pData, BitmapLength);
         ResStream.ReadBuffer(pData^, BitmapLength);            // Bitmap Data
         ResStream.Free;
      except
         on EResNotFound do
         begin
            MessageBox(0, PChar('File not found in resource - ' + Filename), PChar('BMP Texture'), MB_OK);
            Exit;
         end
         else
         begin
            MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
            Exit;
         end;
      end;
   end
   else
   begin   // Load image from file
      BitmapFile := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
      if (BitmapFile = INVALID_HANDLE_VALUE) then
      begin
         MessageBox(0, PChar('Error opening ' + Filename), PChar('BMP Unit'), MB_OK);
         Exit;
      end;

      // Get header information
      ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
      ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);

      // Get palette
      PaletteLength := InfoHeader.biClrUsed;
      SetLength(Palette, PaletteLength);
      ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
      if (ReadBytes <> PaletteLength) then
      begin
         MessageBox(0, PChar('Error reading palette'), PChar('BMP Unit'), MB_OK);
         Exit;
      end;

      Width  := InfoHeader.biWidth;
      Height := InfoHeader.biHeight;
      BitmapLength := InfoHeader.biSizeImage;
      if BitmapLength = 0 then
         BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

      // Get the actual pixel data
      GetMem(pData, BitmapLength);
      ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
      if (ReadBytes <> BitmapLength) then
      begin
         MessageBox(0, PChar('Error reading bitmap data'), PChar('BMP Unit'), MB_OK);
         Exit;
      end;
      CloseHandle(BitmapFile);
   end;

   // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
   SwapRGB(pData, Width*Height);

   Texture :=CreateTexture(Width, Height, GL_RGB, pData, NoPicMip, NoMipMap);
   FreeMem(pData);
   result :=TRUE;
end;

{------------------------------------------------------------------}
{  Load JPEG textures                                              }
{------------------------------------------------------------------}
function LoadJPGTexture(Filename: String; var Texture: GLuint; LoadFromResource, NoPicMip, NoMipMap : Boolean): Boolean;
var
   Data : Array of LongWord;
   W, Width : Integer;
   H, Height : Integer;
   BMP : TBitmap;
   JPG : TJPEGImage;
   C : LongWord;
   Line : ^LongWord;
   ResStream : TResourceStream;      // used for loading from resource
begin
   result :=FALSE;
   JPG:=TJPEGImage.Create;

   if LoadFromResource then // Load from resource
   begin
      try
         ResStream := TResourceStream.Create(hInstance, PChar(copy(Filename, 1, Pos('.', Filename)-1)), 'JPEG');
         JPG.LoadFromStream(ResStream);
         ResStream.Free;
      except on
         EResNotFound do
         begin
            MessageBox(0, PChar('File not found in resource - ' + Filename), PChar('JPG Texture'), MB_OK);
            Exit;
         end
         else
         begin
            MessageBox(0, PChar('Couldn''t load JPG Resource - "'+ Filename +'"'), PChar('BMP Unit'), MB_OK);
            Exit;
         end;
      end;
   end
   else
   begin
      try
         JPG.LoadFromFile(Filename);
      except
         MessageBox(0, PChar('Couldn''t load JPG - "'+ Filename +'"'), PChar('BMP Unit'), MB_OK);
         Exit;
      end;
   end;

   // Create Bitmap
   BMP:=TBitmap.Create;
   BMP.pixelformat:=pf32bit;
   BMP.width:=JPG.width;
   BMP.height:=JPG.height;
   BMP.canvas.draw(0,0,JPG);        // Copy the JPEG onto the Bitmap

   Width :=BMP.Width;
   Height :=BMP.Height;
   SetLength(Data, Width*Height);

   For H:=0 to Height-1 do
   begin
      Line :=BMP.scanline[Height-H-1];   // flip JPEG
      For W:=0 to Width-1 do
      begin
         c:=Line^ and $FFFFFF; // Need to do a color swap
         Data[W+(H*Width)] :=(((c and $FF) shl 16)+(c shr 16)+(c and $FF00)) or $FF000000;  // 4 channel.
         inc(Line);
      end;
   end;

   BMP.free;
   JPG.free;

   Texture :=CreateTexture(Width, Height, GL_RGBA, addr(Data[0]), NoPicMip, NoMipMap);
   result :=TRUE;
end;

function LoadPNGTexture(const _Filename: String; var Texture: GLuint; LoadFromResource, NoPicMip, NoMipMap : Boolean): Boolean;
var
   PNG : TPNGObject;
   Bitmap : TBitmap;
   W, Width, H, Height: integer;
   Data : Array of LongWord;
   C : LongWord;
   Line : ^LongWord;
begin
   Bitmap := TBitmap.Create;
   PNG := TPNGObject.Create;
   PNG.LoadFromFile(_Filename);
   Bitmap.PixelFormat := pf32bit;
   Bitmap.Width := PNG.Width;
   Bitmap.Height := PNG.Height;
   Bitmap.Canvas.Draw(0,0,PNG);

   Width := Bitmap.Width;
   Height :=Bitmap.Height;
   SetLength(Data, Width*Height);

   For H:=0 to Height-1 do
   begin
      Line :=Bitmap.scanline[Height-H-1];   // flip PNG
      For W:=0 to Width-1 do
      begin
         c:=Line^ and $FFFFFF; // Need to do a color swap
         Data[W+(H*Width)] :=(((c and $FF) shl 16)+(c shr 16)+(c and $FF00)) or $FF000000;  // 4 channel.
         inc(Line);
      end;
   end;
   Bitmap.Free;
   PNG.Free;

   Texture :=CreateTexture(Width, Height, GL_RGBA, addr(Data[0]), NoPicMip, NoMipMap);
   result := TRUE;
end;

{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String; var Texture: GLuint; LoadFromResource, NoPicMip, NoMipMap : Boolean): Boolean;
var
   TGAHeader : packed record   // Header type for TGA images
      FileType     : Byte;
      ColorMapType : Byte;
      ImageType    : Byte;
      ColorMapSpec : Array[0..4] of Byte;
      OrigX  : Array [0..1] of Byte;
      OrigY  : Array [0..1] of Byte;
      Width  : Array [0..1] of Byte;
      Height : Array [0..1] of Byte;
      BPP    : Byte;
      ImageInfo : Byte;
   end;
   TGAFile   : File;
   bytesRead : Integer;
   image     : Pointer;    {or PRGBTRIPLE}
   CompImage : Pointer;
   Width, Height : Integer;
   ColorDepth    : Integer;
   ImageSize     : Integer;
   BufferIndex : Integer;
   currentByte : Integer;
   CurrentPixel : Integer;
   I : Integer;
   Front: ^Byte;
   Back: ^Byte;
   Temp: Byte;

   ResStream : TResourceStream;      // used for loading from resource

   // Copy a pixel from source to dest and Swap the RGB color values
   procedure CopySwapPixel(const Source, Destination : Pointer);
   asm
      push ebx
      mov bl,[eax+0]
      mov bh,[eax+1]
      mov [edx+2],bl
      mov [edx+1],bh
      mov bl,[eax+2]
      mov bh,[eax+3]
      mov [edx+0],bl
      mov [edx+3],bh
      pop ebx
   end;

begin
   result :=FALSE;
   GetMem(Image, 0);
   if LoadFromResource then // Load from resource
   begin
      try
         ResStream := TResourceStream.Create(hInstance, PChar(copy(Filename, 1, Pos('.', Filename)-1)), 'TGA');
         ResStream.ReadBuffer(TGAHeader, SizeOf(TGAHeader));  // FileHeader
         result :=TRUE;
      except on
         EResNotFound do
         begin
            MessageBox(0, PChar('File not found in resource - ' + Filename), PChar('TGA Texture'), MB_OK);
            Exit;
         end
         else
         begin
            MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
            Exit;
         end;
      end;
   end
   else
   begin
      if FileExists(Filename) then
      begin
         AssignFile(TGAFile, Filename);
         Reset(TGAFile, 1);

         // Read in the bitmap file header
         BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));
         result :=TRUE;
      end
      else
      begin
         MessageBox(0, PChar('File not found  - ' + Filename), PChar('TGA Texture'), MB_OK);
         Exit;
      end;
   end;

   if Result = TRUE then
   begin
      Result :=FALSE;

      // Only support 24, 32 bit images
      if (TGAHeader.ImageType <> 2) AND    { TGA_RGB }
         (TGAHeader.ImageType <> 10) then  { Compressed RGB }
      begin
         Result := False;
         CloseFile(tgaFile);
         MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32bit TGA supported.'), PChar('TGA File Error'), MB_OK);
         Exit;
      end;

      // Don't support colormapped files
      if TGAHeader.ColorMapType <> 0 then
      begin
         Result := False;
         CloseFile(TGAFile);
         MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.'), PChar('TGA File Error'), MB_OK);
         Exit;
      end;

      // Get the width, height, and color depth
      Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
      Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
      ColorDepth := TGAHeader.BPP;
      ImageSize  := Width*Height*(ColorDepth div 8);

      if ColorDepth < 24 then
      begin
         Result := False;
         CloseFile(TGAFile);
         MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32 bit TGA files supported.'), PChar('TGA File Error'), MB_OK);
         Exit;
      end;

      GetMem(Image, ImageSize);

      if TGAHeader.ImageType = 2 then   // Standard 24, 32 bit TGA file
      begin
         if LoadFromResource then // Load from resource
         begin
            try
               ResStream.ReadBuffer(Image^, ImageSize);
               ResStream.Free;
            except
               MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
               Exit;
            end;
         end
         else         // Read in the image from file
         begin
            BlockRead(TGAFile, image^, ImageSize, bytesRead);
            if bytesRead <> ImageSize then
            begin
               Result := False;
               CloseFile(TGAFile);
               MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
               Exit;
            end
         end;

         // TGAs are stored BGR and not RGB, so swap the R and B bytes.
         // 32 bit TGA files have alpha channel and gets loaded differently
         if TGAHeader.BPP = 24 then
         begin
            for I :=0 to Width * Height - 1 do
            begin
               Front := Pointer(Integer(Image) + I*3);
               Back := Pointer(Integer(Image) + I*3 + 2);
               Temp := Front^;
               Front^ := Back^;
               Back^ := Temp;
            end;
            Texture :=CreateTexture(Width, Height, GL_RGB, Image, NoPicMip, NoMipMap);
         end
         else
         begin
            for I :=0 to Width * Height - 1 do
            begin
               Front := Pointer(Integer(Image) + I*4);
               Back := Pointer(Integer(Image) + I*4 + 2);
               Temp := Front^;
               Front^ := Back^;
               Back^ := Temp;
            end;
            Texture :=CreateTexture(Width, Height, GL_RGBA, Image, NoPicMip, NoMipMap);
         end;
      end;

      // Compressed 24, 32 bit TGA files
      if TGAHeader.ImageType = 10 then
      begin
         ColorDepth :=ColorDepth DIV 8;
         CurrentByte :=0;
         CurrentPixel :=0;
         BufferIndex :=0;

         if LoadFromResource then // Load from resource
         begin
            try
               GetMem(CompImage, ResStream.Size-sizeOf(TGAHeader));
               ResStream.ReadBuffer(CompImage^, ResStream.Size-sizeOf(TGAHeader));   // load compressed date into memory
               ResStream.Free;
            except
               MessageBox(0, PChar('Unable to read from resource - ' + Filename), PChar('BMP Unit'), MB_OK);
               Exit;
            end;
         end
         else
         begin
            GetMem(CompImage, FileSize(TGAFile)-sizeOf(TGAHeader));
            BlockRead(TGAFile, CompImage^, FileSize(TGAFile)-sizeOf(TGAHeader), BytesRead);   // load compressed data into memory
            if bytesRead <> FileSize(TGAFile)-sizeOf(TGAHeader) then
            begin
               Result := False;
               CloseFile(TGAFile);
               MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
               Exit;
            end
         end;

         // Extract pixel information from compressed data
         repeat
            Front := Pointer(Integer(CompImage) + BufferIndex);
            Inc(BufferIndex);
            if Front^ < 128 then
            begin
               For I := 0 to Front^ do
               begin
                  CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex+I*ColorDepth), Pointer(Integer(image)+CurrentByte));
                  CurrentByte := CurrentByte + ColorDepth;
                  inc(CurrentPixel);
               end;
               BufferIndex :=BufferIndex + (Front^+1)*ColorDepth
            end
            else
            begin
               For I := 0 to Front^ -128 do
               begin
                  CopySwapPixel(Pointer(Integer(CompImage)+BufferIndex), Pointer(Integer(image)+CurrentByte));
                  CurrentByte := CurrentByte + ColorDepth;
                  inc(CurrentPixel);
               end;
               BufferIndex :=BufferIndex + ColorDepth
            end;
         until CurrentPixel >= Width*Height;

         try
            if ColorDepth = 3 then
               Texture :=CreateTexture(Width, Height, GL_RGB, Image, NoPicMip, NoMipMap)
            else
               Texture :=CreateTexture(Width, Height, GL_RGBA, Image, NoPicMip, NoMipMap);
         except
            Texture := 0;
         end;
      end;

      Result := TRUE;
      CloseFile(TGAFile);
      try
         //FreeMem(Image); // Causes access violation!
      except
         ;
      end;
   end;
end;


{------------------------------------------------------------------}
{  Determines file type and sends to correct function              }
{------------------------------------------------------------------}
function LoadTexture(Filename: String; var Texture : GLuint; LoadFromRes, NoPicMip, NoMipMap : Boolean) : Boolean;
var
   ext : string;
begin
   result := false;
//  ShowMessage(FileName);
   ext := copy(Uppercase(filename), length(filename)-3, 4);
   if ext = '.JPG' then
      result := LoadJPGTexture(Filename, Texture, LoadFromRes, NoPicMip, NoMipMap)
   else if ext = '.BMP' then
      result := LoadBMPTexture(Filename, Texture, LoadFromRes, NoPicMip, NoMipMap)
   else if ext = '.TGA' then
      result := LoadTGATexture(Filename, Texture, LoadFromRes, NoPicMip, NoMipMap)
   else if ext = '.PNG' then
      result := LoadPNGTexture(Filename, Texture, LoadFromRes, NoPicMip, NoMipMap);

   if result = false then
      ShowMessage(filename);
end;


function initLocking : boolean;
var
   extensionStr : string;
begin
   if Pos('GL_EXT_compiled_vertex_array', extensionStr) = 0 then
   begin
//    glLockArraysEXT	:= wglGetProcAddress('glLockArraysEXT');
//    glUnLockArraysEXT	:= wglGetProcAddress('glUnLockArraysEXT');
      result := true;
   end
   else
      result := false;
end;

function LoadQuakeTexture(path, name : string; var Texture : GLUINT;  NoPicMip, NoMipMap : boolean) : boolean;
var
   ext, fullname : string;
begin
   try
      result := false;
      ext := ExtractFileExt(name);
      if (ext <> '.tga') and (ext <> '.jpg') then
         ext := '';

      if Length(ext) > 0 then
         name := Copy(name, 1, Length(name)-4); // remove ext
      fullname := path + name + '.tga';
      if FileExists(fullname) then
         result := LoadTexture(fullname, Texture, false,  NoPicMip, NoMipMap)
      else
      begin
         fullname := path + name + '.jpg';
         if FileExists(fullname) then
            result := LoadTexture(fullname, Texture, false, NoPicMip, NoMipMap)
         else
            Texture := 0;
      end;
   except
      ext := ext;
   end;
end;

end.