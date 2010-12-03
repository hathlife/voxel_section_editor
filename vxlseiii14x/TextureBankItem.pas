unit TextureBankItem;

interface

uses dglOpenGL, BasicDataTypes, BasicFunctions, Windows, Graphics, JPEG,
   PNGImage, DDS, SysUtils;

type
   TTextureBankItem = class
      private
         Counter: longword;
         Editable : boolean;
         ID : GLInt;
         Filename: string;
         MipmapCount : integer;
         // Gets
         function GetMipmapCount: integer;
         // Sets
         procedure SetNumMipmaps(_Value: integer);
         // I/O
         procedure LoadBmpTexture(const _Filename : string);
         procedure LoadJPEGTexture(const _Filename : string);
         procedure LoadPNGTexture(const _Filename : string);
         procedure LoadTGATexture(const _Filename : string);
         procedure LoadDDSTexture(const _Filename : string);
         procedure SaveBmpTexture(const _Filename : string);
         procedure SaveJPEGTexture(const _Filename : string);
         procedure SavePNGTexture(const _Filename : string);
         procedure SaveTGATexture(const _Filename : string);
         procedure SaveDDSTexture(const _Filename : string);
         procedure UploadTexture(_Data : Pointer; _Format: GLInt; _Height,_Width,_Level: integer);
      public
         TextureType : integer;
         // Constructor and Destructor
         constructor Create; overload;
         constructor Create(const _Filename: string); overload;
         constructor Create(const _Texture: GLInt); overload;
         constructor Create(const _Bitmap : TBitmap); overload;
         constructor Create(const _Bitmaps : TABitmap); overload;
         constructor Create(const _Bitmap : TBitmap; const _AlphaMap: TByteMap); overload;
         constructor Create(const _Bitmaps : TABitmap; const _AlphaMaps: TAByteMap); overload;
         destructor Destroy; override;
         // I/O
         procedure LoadTexture(const _Filename : string); overload;
         procedure LoadTexture(const _Bitmaps : TABitmap); overload;
         procedure LoadTexture(const _Bitmap : TBitmap; _Level: integer); overload;
         procedure LoadTexture(const _Bitmaps : TABitmap; const _AlphaMaps: TAByteMap); overload;
         procedure LoadTexture(const _Bitmap : TBitmap; const _AlphaMap: TByteMap; _Level: integer); overload;
         procedure SaveTexture(const _Filename: string);
         function DownloadTexture(_Level : integer): TBitmap; overload;
         function DownloadTexture(var _AlphaMap: TByteMap; _Level : integer): TBitmap; overload;
         // Sets
         procedure SetEditable(_value: boolean);
         procedure SetFilename(_value: string);
         // Gets
         function GetEditable: boolean;
         function GetFilename: string;
         function GetID : GLInt;
         // Copies
         procedure Clone(_Texture: GLInt);
         // Counter
         function GetCount : integer;
         procedure IncCounter;
         procedure DecCounter;
         // Properties
         property NumMipmaps: integer read GetMipmapCount write SetNumMipmaps;

   end;
   PTextureBankItem = ^TTextureBankItem;

implementation

// Constructors and Destructors
// This one starts a blank texture.
constructor TTextureBankItem.Create;
begin
   glGenTextures(1, @ID);
   Counter := 1;
   Filename := '';
end;

constructor TTextureBankItem.Create(const _Filename: string);
begin
   glGenTextures(1, @ID);
   glEnable(GL_TEXTURE_2D);
   LoadTexture(_Filename);
   Counter := 1;
   glDisable(GL_TEXTURE_2D);
end;

constructor TTextureBankItem.Create(const _Texture: GLInt);
var
   Pixels : PByte;
   x,xSize,ySize,BaseLevel,MaxLevel : integer;
   tempi : PGLInt;
begin
   glEnable(GL_TEXTURE_2D);
   glGenTextures(1, @ID);
   Clone(_Texture);
   Counter := 1;
   Filename := '';
   glDisable(GL_TEXTURE_2D);
end;

constructor TTextureBankItem.Create(const _Bitmap : TBitmap);
begin
   glEnable(GL_TEXTURE_2D);
   glGenTextures(1, @ID);
   LoadTexture(_Bitmap,0);
   Counter := 1;
   SetNumMipmaps(1);
   glDisable(GL_TEXTURE_2D);
end;

constructor TTextureBankItem.Create(const _Bitmaps : TABitmap);
begin
   glGenTextures(1, @ID);
   glEnable(GL_TEXTURE_2D);
   LoadTexture(_Bitmaps);
   Counter := 1;
   glDisable(GL_TEXTURE_2D);
end;

constructor TTextureBankItem.Create(const _Bitmap : TBitmap; const _AlphaMap: TByteMap);
begin
   glEnable(GL_TEXTURE_2D);
   glGenTextures(1, @ID);
   LoadTexture(_Bitmap,_AlphaMap,0);
   Counter := 1;
   SetNumMipmaps(1);
   glDisable(GL_TEXTURE_2D);
end;

constructor TTextureBankItem.Create(const _Bitmaps : TABitmap; const _AlphaMaps: TAByteMap);
begin
   glGenTextures(1, @ID);
   glEnable(GL_TEXTURE_2D);
   LoadTexture(_Bitmaps,_AlphaMaps);
   Counter := 1;
   glDisable(GL_TEXTURE_2D);
end;

destructor TTextureBankItem.Destroy;
begin
   if (ID <> 0) and (ID <> -1) then
      glDeleteTextures(1,@ID);
   Filename := '';
   inherited Destroy;
end;

// I/O
procedure TTextureBankItem.LoadTexture(const _Filename : string);
var
   Ext : string;
begin
   if FileExists(_Filename) then
   begin
      Filename := CopyString(_Filename);

      Ext := copy(Uppercase(filename), length(filename)-3, 4);
      if ext = '.JPG' then
         LoadJPEGTexture(Filename)
      else if ext = '.BMP' then
         LoadBMPTexture(Filename)
      else if ext = '.PNG' then
         LoadPNGTexture(Filename)
      else if ext = '.TGA' then
         LoadTGATexture(Filename)
      else if ext = '.DDS' then
         LoadDDSTexture(Filename);
   end;
end;

// Code adapted from Jan Horn's Texture.pas from http://www.sulaco.co.za
procedure TTextureBankItem.LoadTexture(const _Bitmap : TBitmap; _Level: integer);
var
   Data : Array of LongWord;
   W, H : Integer;
   Line : ^LongWord;
begin
   SetLength(Data, _Bitmap.Width * _Bitmap.Height);

   For H:= 0 to _Bitmap.Height-1 do
   begin
      Line := _Bitmap.ScanLine[_Bitmap.Height-H-1];   // flip bitmap
      For W:= 0 to _Bitmap.Width-1 do
      begin
         // Switch ABGR to ARGB
         Data[W+(H*_Bitmap.Width)] :=((Line^ and $FF) shl 16) + ((Line^ and $FF0000) shr 16) + (Line^ and $FF00FF00);
         inc(Line);
      end;
   end;
   UploadTexture(Addr(Data[0]),GL_RGBA,_Bitmap.Height,_Bitmap.Width,_Level);
   SetLength(Data,0);
end;

procedure TTextureBankItem.LoadTexture(const _Bitmaps: TABitmap);
var
   i : integer;
begin
   SetNumMipmaps(High(_Bitmaps)+1);
   for i := Low(_Bitmaps) to High(_Bitmaps) do
   begin
      LoadTexture(_Bitmaps[i],i);
   end;
end;

// Code adapted from Jan Horn's Texture.pas from http://www.sulaco.co.za
procedure TTextureBankItem.LoadTexture(const _Bitmap : TBitmap; const _AlphaMap : TByteMap; _Level: integer);
var
   Data : Array of LongWord;
   W, H : Integer;
   Line : ^LongWord;
begin
   SetLength(Data, _Bitmap.Width * _Bitmap.Height);

   For H:= 0 to _Bitmap.Height-1 do
   begin
      Line := _Bitmap.ScanLine[_Bitmap.Height-H-1];   // flip bitmap
      For W:= 0 to _Bitmap.Width-1 do
      begin
         // Switch ABGR to ARGB
         Data[W+(H*_Bitmap.Width)] :=((Line^ and $FF) shl 16) + ((Line^ and $FF0000) shr 16) + (Line^ and $00FF00) + (_AlphaMap[W,_Bitmap.Height-H-1] shl 24);
         inc(Line);
      end;
   end;
   UploadTexture(Addr(Data[0]),GL_RGBA,_Bitmap.Height,_Bitmap.Width,_Level);
   SetLength(Data,0);
end;

procedure TTextureBankItem.LoadTexture(const _Bitmaps: TABitmap; const _AlphaMaps: TAByteMap);
var
   i : integer;
begin
   SetNumMipmaps(High(_Bitmaps)+1);
   for i := Low(_Bitmaps) to High(_Bitmaps) do
   begin
      LoadTexture(_Bitmaps[i],_AlphaMaps[i],i);
   end;
end;

procedure TTextureBankItem.SaveTexture(const _Filename: string);
var
   Ext : string;
begin
   if Length(_Filename) > 0 then
      Filename := CopyString(_Filename);

   Ext := copy(Uppercase(Filename), length(Filename)-3, 4);
   if ext = '.JPG' then
      SaveJPEGTexture(Filename)
   else if ext = '.BMP' then
      SaveBMPTexture(Filename)
   else if ext = '.PNG' then
      SavePNGTexture(Filename)
   else if ext = '.TGA' then
      SaveTGATexture(Filename)
   else if ext = '.DDS' then
      SaveDDSTexture(Filename);
end;


procedure TTextureBankItem.LoadBmpTexture(const _Filename : string);
var
   Bitmap : TBitmap;
begin
   Bitmap := TBitmap.Create;
   Bitmap.LoadFromFile(_Filename);
   SetNumMipmaps(1);
   LoadTexture(Bitmap,0);
   Bitmap.Free;
end;

procedure TTextureBankItem.LoadJPEGTexture(const _Filename : string);
var
   JPG : TJPEGImage;
   Bitmap : TBitmap;
begin
   Bitmap := TBitmap.Create;
   JPG := TJPEGImage.Create;
   JPG.LoadFromFile(_Filename);
   Bitmap.PixelFormat := pf32bit;
   Bitmap.Width := JPG.Width;
   Bitmap.Height := JPG.Height;
   Bitmap.Canvas.Draw(0,0,JPG);
   SetNumMipmaps(1);
   LoadTexture(Bitmap ,0);
   Bitmap.Free;
   JPG.Free;
end;

procedure TTextureBankItem.LoadPNGTexture(const _Filename : string);
var
   PNG : TPNGObject;
   Bitmap : TBitmap;
begin
   Bitmap := TBitmap.Create;
   PNG := TPNGObject.Create;
   PNG.LoadFromFile(_Filename);
   Bitmap.PixelFormat := pf32bit;
   Bitmap.Width := PNG.Width;
   Bitmap.Height := PNG.Height;
   Bitmap.Canvas.Draw(0,0,PNG);
   SetNumMipmaps(1);
   LoadTexture(Bitmap ,0);
   Bitmap.Free;
   PNG.Free;
end;

// code adapted from Jan Horn's Texture.pas from http://www.sulaco.co.za
procedure TTextureBankItem.LoadTGATexture(const _Filename : string);
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
   BytesRead : Integer;
   Image     : Pointer;    {or PRGBTRIPLE}
   CompImage : Pointer;
   Width, Height : Integer;
   ColorDepth    : Integer;
   ImageSize     : Integer;
   BufferIndex : Integer;
   CurrentByte : Integer;
   CurrentPixel : Integer;
   I : Integer;
   Front: ^Byte;
   Back: ^Byte;
   Temp: Byte;
begin
   SetNumMipmaps(1);
   AssignFile(TGAFile, Filename);
   Reset(TGAFile, 1);

   // Read in the bitmap file header
   BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));

    // Only support 24, 32 bit images
   if (TGAHeader.ImageType <> 2) AND    { TGA_RGB }
       (TGAHeader.ImageType <> 10) then  { Compressed RGB }
   begin
      CloseFile(tgaFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32bit TGA supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
   end;

   // Don't support colormapped files
   if TGAHeader.ColorMapType <> 0 then
   begin
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
      CloseFile(TGAFile);
      MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 and 32 bit TGA files supported.'), PChar('TGA File Error'), MB_OK);
      Exit;
   end;

   GetMem(Image, ImageSize);

   if TGAHeader.ImageType = 2 then   // Standard 24, 32 bit TGA file
   begin
      BlockRead(TGAFile, Image^, ImageSize, bytesRead);
      if bytesRead <> ImageSize then
      begin
         CloseFile(TGAFile);
         MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
         Exit;
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
         UploadTexture(Image, GL_RGB, Height, Width, 0);
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
         UploadTexture(Image, GL_RGBA, Height, Width, 0);
      end;
   end;

   // Compressed 24, 32 bit TGA files
   if TGAHeader.ImageType = 10 then
   begin
      ColorDepth := ColorDepth DIV 8;
      CurrentByte := 0;
      CurrentPixel := 0;
      BufferIndex := 0;

      GetMem(CompImage, FileSize(TGAFile)-sizeOf(TGAHeader));
      BlockRead(TGAFile, CompImage^, FileSize(TGAFile)-sizeOf(TGAHeader), BytesRead);   // load compressed data into memory
      if bytesRead <> FileSize(TGAFile)-sizeOf(TGAHeader) then
      begin
         CloseFile(TGAFile);
         MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
         Exit;
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
      FreeMem(CompImage);

      if ColorDepth = 3 then
         UploadTexture(Image,GL_RGB,Height,Width,0)
      else
         UploadTexture(Image,GL_RGBA,Height,Width,0);
   end;
   CloseFile(TGAFile);
   FreeMem(Image);
end;

procedure TTextureBankItem.LoadDDSTexture(const _Filename : string);
var
   DDS : TDDSImage;
   Width, Height: integer;
begin
   DDS := TDDSImage.Create;
   // The DDS Load procedure creates a new texture, so we'll have to eliminate
   // the current one.
   glEnable(GL_TEXTURE_2D);
   if (ID <> 0) and (ID <> -1) then
      glDeleteTextures(1,@ID);
   DDS.LoadFromFile(_Filename,Cardinal(ID),false,Width,Height);
   DDS.Free;
end;

procedure TTextureBankItem.SaveBmpTexture(const _Filename : string);
var
   Bitmap : TBitmap;
begin
  Bitmap := DownloadTexture(0);
  Bitmap.SaveToFile(Filename);
  Bitmap.Free;
end;

procedure TTextureBankItem.SaveJPEGTexture(const _Filename : string);
var
   JPEGImage: TJPEGImage;
   Bitmap : TBitmap;
begin
   Bitmap := DownloadTexture(0);
   JPEGImage := TJPEGImage.Create;
   JPEGImage.Assign(Bitmap);
   JPEGImage.SaveToFile(_Filename);
   Bitmap.Free;
   JPEGImage.Free;
end;

procedure TTextureBankItem.SavePNGTexture(const _Filename : string);
var
   PNGImage: TPNGObject;
   Bitmap : TBitmap;
begin
   Bitmap := DownloadTexture(0);
   PNGImage := TPNGObject.Create;
   PNGImage.Assign(Bitmap);
   PNGImage.SaveToFile(_Filename);
   Bitmap.Free;
   PNGImage.Free;
end;

procedure TTextureBankItem.SaveTGATexture(const _Filename : string);
var
   buffer: array of byte;
   Width, Height, i, c, temp: integer;
   f: file;
   Tempi : PGLInt;
begin
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,ID);
   GetMem(Tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_WIDTH,tempi);
   Width := tempi^;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_HEIGHT,tempi);
   Height := tempi^;
   FreeMem(tempi);

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
         buffer[16] := 32; //pixel size
         buffer[17] := 8;

         glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE,Pointer(Cardinal(buffer) + 18));

         AssignFile(f, _Filename);
         Rewrite(f, 1);

         for i := 0 to 17 do
            BlockWrite(f, buffer[i], sizeof(byte) , temp);

         c := 18;
         for i := 0 to (Width * Height)-1 do
         begin
//            buffer[c+3] := 255 - buffer[c+3]; // invert alpha. 
            BlockWrite(f, buffer[c+2], sizeof(byte) , temp);
            BlockWrite(f, buffer[c+1], sizeof(byte) , temp);
            BlockWrite(f, buffer[c], sizeof(byte) , temp);
            BlockWrite(f, buffer[c+3], sizeof(byte) , temp);
            inc(c,4);
         end;
         closefile(f);
      end;
   finally
      finalize(buffer);
   end;
end;

procedure TTextureBankItem.SaveDDSTexture(const _Filename : string);
var
   DDSImage : TDDSImage;
begin
   DDSImage := TDDSImage.Create;
   DDSImage.SaveToFile(_Filename,ID);
   DDSImage.Free;
end;

procedure TTextureBankItem.UploadTexture(_Data : Pointer; _Format: GLInt; _Height,_Width,_Level: integer);
begin
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, ID);
   glTexImage2D(GL_TEXTURE_2D, _Level, GL_RGBA, _Width, _Height, 0, _Format, GL_UNSIGNED_BYTE, _Data);
   glDisable(GL_TEXTURE_2D);
end;

// Borrowed and adapted from Stucuk's code from OS: Voxel Viewer 1.80+ without AllWhite.
function TTextureBankItem.DownloadTexture(_Level : integer) : TBitmap;
var
   RGBBits : PRGBQuad;
   Pixel : PRGBQuad;
   x,y : Integer;
   Width, Height, maxx, maxy : cardinal;
   Tempi : PGLInt;
begin
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,ID);

   GetMem(Tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,_Level,GL_TEXTURE_WIDTH,tempi);
   Width := tempi^;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,_Level,GL_TEXTURE_HEIGHT,tempi);
   Height := tempi^;
   FreeMem(tempi);

   GetMem(RGBBits, Width * Height * 4);
   glGetTexImage(GL_TEXTURE_2D,_Level,GL_RGBA,GL_UNSIGNED_BYTE, RGBBits);

   glDisable(GL_TEXTURE_2D);

   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width       := Width;
   Result.Height      := Height;

   Pixel := RGBBits;
   maxy := Height-1;
   maxx := Width-1;

   for y := 0 to maxy do
      for x := 0 to maxx do
      begin
         Result.Canvas.Pixels[x,maxy-y] := RGB(Pixel.rgbBlue,Pixel.rgbGreen,Pixel.rgbRed);
         inc(Pixel);
      end;

   FreeMem(RGBBits);
end;

function TTextureBankItem.DownloadTexture(var _AlphaMap: TByteMap; _Level : integer) : TBitmap;
var
   RGBBits : PRGBQuad;
   Pixel : PRGBQuad;
   x,y : Integer;
   Width, Height, maxx, maxy : cardinal;
   Tempi : PGLInt;
begin
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,ID);

   GetMem(Tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,_Level,GL_TEXTURE_WIDTH,tempi);
   Width := tempi^;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,_Level,GL_TEXTURE_HEIGHT,tempi);
   Height := tempi^;
   FreeMem(tempi);

   GetMem(RGBBits, Width * Height * 4);
   glGetTexImage(GL_TEXTURE_2D,_Level,GL_RGBA,GL_UNSIGNED_BYTE, RGBBits);

   glDisable(GL_TEXTURE_2D);

   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width       := Width;
   Result.Height      := Height;
   SetLength(_AlphaMap,Width,Height);

   Pixel := RGBBits;
   maxy := Height-1;
   maxx := Width-1;

   for y := 0 to maxy do
      for x := 0 to maxx do
      begin
         Result.Canvas.Pixels[x,maxy-y] := RGB(Pixel.rgbBlue,Pixel.rgbGreen,Pixel.rgbRed);
         _AlphaMap[x,maxy-y] := Pixel.rgbReserved;
         inc(Pixel);
      end;

   FreeMem(RGBBits);
end;



// Sets
procedure TTextureBankItem.SetEditable(_value: boolean);
begin
   Editable := _value;
end;

procedure TTextureBankItem.SetFilename(_value: string);
begin
   Filename := CopyString(_Value);
end;

procedure TTextureBankItem.SetNumMipmaps(_Value: integer);
var
   BaseLevel,MaxLevel: TGLInt;
   BorderColor: TVector4f;
begin
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, ID);
   MipmapCount := _Value;
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   if MipMapCount < 1 then
      MipMapCount := 1;
   if MipmapCount > 1 then
   begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
   end
   else
   begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   end;
   BaseLevel := 0;
   glTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,@BaseLevel);
   MaxLevel := MipMapCount - 1;
   glTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,@MaxLevel);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
   BorderColor.X := 0;
   BorderColor.Y := 0;
   BorderColor.Z := 0;
   BorderColor.W := 1;
   glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, @BorderColor);
   glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
   glDisable(GL_TEXTURE_2D);
end;


// Gets
function TTextureBankItem.GetEditable: boolean;
begin
   Result := Editable;
end;

function TTextureBankItem.GetFilename: string;
begin
   Result := Filename;
end;

function TTextureBankItem.GetID : GLInt;
begin
   Result := ID;
end;

function TTextureBankItem.GetMipmapCount: integer;
begin
   Result := MipMapCount;
end;


// Copies
procedure TTextureBankItem.Clone(_Texture: Integer);
var
   Pixels : PByte;
   x,xSize,ySize,BaseLevel,MaxLevel : integer;
   tempi : PGLInt;
begin
   glEnable(GL_TEXTURE_2D);
   // Let's clone the texture here.
   glBindTexture(GL_TEXTURE_2D,_Texture);
   // How many mipmaps does it have?
   GetMem(tempi,4);
   glGetTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,tempi);
   MaxLevel := tempi^;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,tempi);
   BaseLevel := tempi^;
   FreeMem(tempi);
   if (MaxLevel = 1000) then
      MaxLevel := BaseLevel;
   // Now we setup the mipmap levels at the new texture.
   glBindTexture(GL_TEXTURE_2D,ID);
   glTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,@BaseLevel);
   glTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,@MaxLevel);
   for x := BaseLevel to MaxLevel do
   begin
      // Get the dimensions of the mipmap
      glBindTexture(GL_TEXTURE_2D,_Texture);
      GetMem(tempi,4);
      glGetTexLevelParameteriv(GL_TEXTURE_2D,x,GL_TEXTURE_WIDTH,tempi);
      xSize := tempi^;
      FreeMem(tempi);
      GetMem(tempi,4);
      glGetTexLevelParameteriv(GL_TEXTURE_2D,x,GL_TEXTURE_HEIGHT,tempi);
      ySize := tempi^;
      FreeMem(tempi);
      // Get data from mipmap.
      GetMem(Pixels, xSize*ySize*4);
      glGetTexImage(GL_TEXTURE_2D,x,GL_RGBA,GL_UNSIGNED_BYTE,Pixels);
      // Copy data to the new texture's respective mipmap.
      glBindTexture(GL_TEXTURE_2D,ID);
      glTexImage2D(GL_TEXTURE_2D,x,GL_RGBA,xSize,ySize,0,GL_RGBA,GL_UNSIGNED_BYTE,Pixels);
      FreeMem(Pixels);
   end;
   glDisable(GL_TEXTURE_2D);
end;


// Counter
function TTextureBankItem.GetCount : integer;
begin
   Result := Counter;
end;

procedure TTextureBankItem.IncCounter;
begin
   inc(Counter);
end;

procedure TTextureBankItem.DecCounter;
begin
   Dec(Counter);
end;

end.
