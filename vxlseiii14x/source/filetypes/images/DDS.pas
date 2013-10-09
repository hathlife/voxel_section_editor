//10 02 2004//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DDS import routines for Delphi
//  written by Martin Waldegger
//  based on MyDDS by Jon Watte
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  This code is distributed in the hope that it will be useful but
//  WITHOUT ANY WARRANTY. ALL WARRANTIES, EXPRESS OR IMPLIED ARE HEREBY
//  DISCLAMED. This includes but is not limited to warranties of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// The DDS Image class was written by Banshee for Voxel Section Editor III, to
// cover its needs of loading saving textures with mipmaps. It uses the loading
// code from Martin Waldegger, who adapted Jon Watte's code to load DDS files.
// All functions, constants declarations and types used by LoadDDS function were
// written by them, except the TDDSImage class. You can use it on your own
// project as long as you credit all authors mentioned above somewhere or simply
// keeping this copyright intact. Do the changes that you feel necessary to fit
// your project.

unit DDS;

interface

uses Classes, dglOpenGL, Windows, Graphics, SysUtils;

const
//  little-endian, of course
   DDS_MAGIC                   = $20534444;

//  DDS_header.dwFlags
   DDSD_CAPS                   = $00000001;
   DDSD_HEIGHT                 = $00000002;
   DDSD_WIDTH                  = $00000004;
   DDSD_PITCH                  = $00000008;
   DDSD_PIXELFORMAT            = $00001000;
   DDSD_MIPMAPCOUNT            = $00020000;
   DDSD_LINEARSIZE             = $00080000;
   DDSD_DEPTH                  = $00800000;

//  DDS_header.sPixelFormat.dwFlags
   DDPF_ALPHAPIXELS            = $00000001;
   DDPF_FOURCC                 = $00000004;
   DDPF_INDEXED                = $00000020;
   DDPF_RGB                    = $00000040;

//  DDS_header.sCaps.dwCaps1
   DDSCAPS_COMPLEX             = $00000008;
   DDSCAPS_TEXTURE             = $00001000;
   DDSCAPS_MIPMAP              = $00400000;

//  DDS_header.sCaps.dwCaps2
   DDSCAPS2_CUBEMAP            = $00000200;
   DDSCAPS2_CUBEMAP_POSITIVEX  = $00000400;
   DDSCAPS2_CUBEMAP_NEGATIVEX  = $00000800;
   DDSCAPS2_CUBEMAP_POSITIVEY  = $00001000;
   DDSCAPS2_CUBEMAP_NEGATIVEY  = $00002000;
   DDSCAPS2_CUBEMAP_POSITIVEZ  = $00004000;
   DDSCAPS2_CUBEMAP_NEGATIVEZ  = $00008000;
   DDSCAPS2_VOLUME             = $00200000;

   D3DFMT_DXT1                 = $31545844;    //  DXT1 compression texture format
   D3DFMT_DXT2                 = $32545844;    //  DXT2 compression texture format
   D3DFMT_DXT3                 = $33545844;    //  DXT3 compression texture format
   D3DFMT_DXT4                 = $34545844;    //  DXT4 compression texture format
   D3DFMT_DXT5                 = $35545844;    //  DXT5 compression texture format


type
   TDDSPixelFormat = record
      dwSize: Cardinal;
      dwFlags: Cardinal;
      dwFourCC: Cardinal;
      dwRGBBitCount: Cardinal;
      dwRBitMask: Cardinal;
      dwGBitMask: Cardinal;
      dwBBitMask: Cardinal;
      dwAlphaBitMask: Cardinal;
   end;

   TDDSCaps = record
      dwCaps1: Cardinal;
      dwCaps2: Cardinal;
      dwDDSX: Cardinal;
      dwReserved: Cardinal;
   end;

   PDDSHeader = ^TDDSHeader;
   TDDSHeader = record
      case boolean of
      TRUE:
      (
         dwMagic: Cardinal;
         dwSize: Cardinal;
         dwFlags: Cardinal;
         dwHeight: Cardinal;
         dwWidth: Cardinal;
         dwPitchOrLinearSize: Cardinal;
         dwDepth: Cardinal;
         dwMipMapCount: Cardinal;
         dwReserved: array[0..10] of Cardinal;
         PixelFormat: TDDSPixelFormat;
         Caps: TDDSCaps;
         dwReserved2: Cardinal;
      );
      FALSE:
      (
         Data: array[0..127] of byte;
      );
   end;

   TDDSLoadInfo = record
      compressed: boolean;
      swap: boolean;
      palette: boolean;
      divSize: Cardinal;
      blockBytes: Cardinal;
      internalFormat: GLenum;
      externalFormat: GLenum;
      typ: GLenum;
   end;

   TBytes = array[0..9999] of Byte;
   PBytes = ^TBytes;
   TGLuints = array[0..9999] of Cardinal;
   PGLuints = ^TGLuints;

   TDDSImage = class
      private
         function PF_IS_DXT1(var pf: TDDSPixelFormat): boolean;
         function PF_IS_DXT3(var pf: TDDSPixelFormat): boolean;
         function PF_IS_DXT5(var pf: TDDSPixelFormat): boolean;
         function PF_IS_BGRA8(var pf: TDDSPixelFormat): boolean;
         function PF_IS_BGR8(var pf: TDDSPixelFormat): boolean;
         function PF_IS_BGR5A1(var pf: TDDSPixelFormat): boolean;
         function PF_IS_BGR565(var pf: TDDSPixelFormat): boolean;
         function PF_IS_INDEX8(const pf: TDDSPixelFormat): boolean;
         function max(v1,v2: Cardinal): Cardinal;
         Procedure SwapY(_Pixels: pBytes; _xSize, _ySize,_PixelSize: Integer);
      public
         destructor Destroy; override;
         // I/O
         function LoadFromFile(const _Filename: string; var _Texture: Cardinal; _NoPicMip : Boolean; Var _Width,_Height : Integer): boolean;
         function LoadDDS(var _Stream: TStream; Var _Texture : Cardinal; _NoPicMip : Boolean; Var _Width,_Height : Integer): boolean;
         function SaveDDS(var _Stream: TStream; Var _Texture : Cardinal; _Compression : GLINT = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT): boolean;
         function SaveToFile(const _Filename: string; _Texture: Cardinal): boolean; overload;
         function SaveToFile(const _Filename: string; _Texture, _Compression: Cardinal): boolean; overload;
   end;

var
   loadInfoDXT1 : TDDSLoadInfo = (compressed: true; swap: false; palette: false; divsize: 4; blockBytes: 8; internalFormat: GL_COMPRESSED_RGBA_S3TC_DXT1_EXT);
   loadInfoDXT3 : TDDSLoadInfo = (compressed: true; swap: false; palette: false; divsize: 4; blockBytes: 16; internalFormat: GL_COMPRESSED_RGBA_S3TC_DXT3_EXT);
   loadInfoDXT5 : TDDSLoadInfo = (compressed: true; swap: false; palette: false; divsize: 4; blockBytes: 16; internalFormat: GL_COMPRESSED_RGBA_S3TC_DXT5_EXT);
   loadInfoBGRA8 : TDDSLoadInfo = (compressed: false; swap: false; palette: false; divsize: 1; blockBytes: 4; internalFormat: GL_RGBA8; externalFormat: GL_BGRA; typ: GL_UNSIGNED_BYTE);
   loadInfoBGR8 : TDDSLoadInfo = (compressed: false; swap: false; palette: false; divsize: 1; blockBytes: 3; internalFormat: GL_RGB8; externalFormat: GL_BGR; typ: GL_UNSIGNED_BYTE);
   loadInfoBGR5A1 : TDDSLoadInfo = (compressed: false; swap: true; palette: false; divsize: 1; blockBytes: 2; internalFormat: GL_RGB5_A1; externalFormat: GL_BGRA; typ: GL_UNSIGNED_SHORT_1_5_5_5_REV);
   loadInfoBGR565 : TDDSLoadInfo = (compressed: false; swap: true; palette: false; divsize: 1; blockBytes: 2; internalFormat: GL_RGB5; externalFormat: GL_BGR; typ: GL_UNSIGNED_SHORT_5_6_5);
   loadInfoIndex8 : TDDSLoadInfo = (compressed: false; swap: false; palette: true; divsize: 1; blockBytes: 1; internalFormat: GL_RGB8; externalFormat: GL_BGRA; typ: GL_UNSIGNED_BYTE);


implementation

uses TextureBankItem;

destructor TDDSImage.Destroy;
begin
   inherited Destroy;
end;

function TDDSImage.PF_IS_DXT1(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_FOURCC)<>0) and
             (pf.dwFourCC = D3DFMT_DXT1));
end;

function TDDSImage.PF_IS_DXT3(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_FOURCC)<>0) and
             (pf.dwFourCC = D3DFMT_DXT3));
end;

function TDDSImage.PF_IS_DXT5(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_FOURCC)<>0) and
             (pf.dwFourCC = D3DFMT_DXT5));
end;

function TDDSImage.PF_IS_BGRA8(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_RGB)<>0) and
             ((pf.dwFlags and DDPF_ALPHAPIXELS)<>0) and
             (pf.dwRGBBitCount = 32) and
             (pf.dwRBitMask = $ff0000) and
             (pf.dwGBitMask = $ff00) and
             (pf.dwBBitMask = $ff) and
             (pf.dwAlphaBitMask = $ff000000));
end;

function TDDSImage.PF_IS_BGR8(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_RGB)<>0) and
             ((pf.dwFlags and DDPF_ALPHAPIXELS)=0) and
             (pf.dwRGBBitCount = 24) and
             (pf.dwRBitMask = $ff0000) and
             (pf.dwGBitMask = $ff00) and
             (pf.dwBBitMask = $ff));
end;

function TDDSImage.PF_IS_BGR5A1(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_RGB)<>0) and
             ((pf.dwFlags and DDPF_ALPHAPIXELS)<>0) and
             (pf.dwRGBBitCount = 16) and
             (pf.dwRBitMask = $00007c00) and
             (pf.dwGBitMask = $000003e0) and
             (pf.dwBBitMask = $0000001f) and
             (pf.dwAlphaBitMask = $00008000));
end;

function TDDSImage.PF_IS_BGR565(var pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_RGB)<>0) and
             ((pf.dwFlags and DDPF_ALPHAPIXELS)=0) and
             (pf.dwRGBBitCount = 16) and
             (pf.dwRBitMask = $0000f800) and
             (pf.dwGBitMask = $000007e0) and
             (pf.dwBBitMask = $0000001f));
end;

function TDDSImage.PF_IS_INDEX8(const pf: TDDSPixelFormat): boolean;
begin
   result := (((pf.dwFlags and DDPF_INDEXED)<>0) and (pf.dwRGBBitCount = 8));
end;

function TDDSImage.max(v1,v2: Cardinal): Cardinal;
begin
   if v2>v1 then
      result:=v2
   else
      result:=v1;
end;

Procedure TDDSImage.SwapY(_Pixels: pBytes; _xSize, _ySize,_PixelSize: Integer);
var
   x, y: integer;
   P1, P2: ^Byte;
   Temp,i: Byte;
begin
   for y:=0 to Pred(_ySize shr 1) do
      for x:=0 to Pred(_xSize) do
      begin
         P1 := Addr(_Pixels^[(y*_xSize + x)*_PixelSize]);
         P2 := Addr(_Pixels^[((_ySize-y-1)*_xSize + x)*_PixelSize]);
         for i := 1 to _PixelSize do
         begin
            Temp := P1^;
            P1^ := P2^;
            P2^ := Temp;
            inc(P1);
            inc(P2);
         end;
      end;
end;

function TDDSImage.LoadDDS(var _Stream: TStream; Var _Texture : Cardinal; _NoPicMip : Boolean; Var _Width,_Height : Integer): boolean;
var
   hdr: TDDSHeader;
   mipMapCount, x, y, xSize, ySize: Cardinal;
   li: ^TDDSLoadInfo;
   data,pixels: PBytes;
   unpacked: PGLuints;
   size, ix, zz: Cardinal;
   palette: array[0..255] of Cardinal;
begin
   result := false;
   //  DDS is so simple to read, too
   _Stream.Read(hdr, sizeof(hdr));
   if (hdr.dwMagic<>DDS_MAGIC) or (hdr.dwSize<>124) or ((hdr.dwFlags and DDSD_PIXELFORMAT)=0) or ((hdr.dwFlags and DDSD_CAPS)=0) then
      exit;

   if (addr(glTexParameteri)=NIL) or (addr(glCompressedTexImage2D)=NIL) or (addr(glPixelStorei)=NIL) then
      exit;

   xSize := hdr.dwWidth;
   ySize := hdr.dwHeight;

   if (PF_IS_DXT1(hdr.PixelFormat)) then li := @loadInfoDXT1 else
   if (PF_IS_DXT3(hdr.PixelFormat)) then li := @loadInfoDXT3 else
   if (PF_IS_DXT5(hdr.PixelFormat)) then li := @loadInfoDXT5 else
   if (PF_IS_BGRA8(hdr.PixelFormat)) then li := @loadInfoBGRA8 else
   if (PF_IS_BGR8(hdr.PixelFormat)) then li := @loadInfoBGR8 else
   if (PF_IS_BGR5A1(hdr.PixelFormat)) then li := @loadInfoBGR5A1 else
   if (PF_IS_BGR565(hdr.PixelFormat)) then li := @loadInfoBGR565 else
   if (PF_IS_INDEX8(hdr.PixelFormat)) then li := @loadInfoIndex8 else
      exit;

   x := xSize;
   y := ySize;
   _Width := x;
   _Height := y;
   GetMem(pixels, xSize*ySize*4);

   glGenTextures(1, @_Texture);
   glBindTexture(GL_TEXTURE_2D, _Texture);
   glEnable(GL_TEXTURE_2D);
   if _NoPicMip then
   begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   end
   else
   begin
      if Assigned(glTexParameteri) then
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   end;

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);

   if hdr.dwFlags and DDSD_MIPMAPCOUNT<>0 then
      mipMapCount := hdr.dwMipMapCount else mipMapCount := 1;

   if li.compressed then
   begin
      size := max(li.divSize, x ) div li.divSize * max(li.divSize, y) div li.divSize * li.blockBytes;
      GetMem(data, size);
      for ix:=0 to mipMapCount-1 do
      begin
         _Stream.Read(data^, size);
         glCompressedTexImage2D(GL_TEXTURE_2D, ix, li.internalFormat, x, y, 0, size, data);
         glGetTexImage(GL_TEXTURE_2D, ix, GL_RGBA, GL_BYTE, pixels);
         SwapY(pixels,xSize,ySize,4);
         glTexImage2D(GL_TEXTURE_2D, ix, GL_RGBA, xsize, ysize, 0, GL_RGBA, GL_BYTE, pixels);
         x := (x+1) shr 1;
         y := (y+1) shr 1;
         size := max(li.divSize, x ) div li.divSize * max(li.divSize, y ) div li.divSize * li.blockBytes;
      end;
      FreeMem(data);
   end
   else if li.palette then
   begin
      size := hdr.dwPitchOrLinearSize * ySize;
      GetMem(data, size);
      GetMem(unpacked, size * sizeof(cardinal));
      _Stream.Read(palette, 1024);
      for ix:=0 to mipMapCount-1 do
      begin
         _Stream.Read(data^, size);
         for zz:=0 to size-1 do
            unpacked[zz] := palette[data[zz]];
         glPixelStorei(GL_UNPACK_ROW_LENGTH, y);
         glTexImage2D(GL_TEXTURE_2D, ix, li.internalFormat, x, y, 0, li.externalFormat, li.typ, unpacked);
         glGetTexImage(GL_TEXTURE_2D, ix, GL_RGBA, GL_BYTE, pixels);
         SwapY(pixels,xSize,ySize,4);
         glTexImage2D(GL_TEXTURE_2D, ix, GL_RGBA, xsize, ysize, 0, GL_RGBA, GL_BYTE, pixels);
         x := (x+1) shr 1;
         y := (y+1) shr 1;
         size := x * y * li.blockBytes;
      end;
      FreeMem(data);
      FreeMem(unpacked);
      glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
   end
   else
   begin
      if li.swap then
         glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_TRUE);
      size := x * y * li.blockBytes;
      GetMem(data, size);
      for ix:=0 to mipMapCount-1 do
      begin
         _Stream.Read(data^, size);
         glPixelStorei(GL_UNPACK_ROW_LENGTH, y);
         glTexImage2D(GL_TEXTURE_2D, ix, li.internalFormat, x, y, 0, li.externalFormat, li.typ, data);
         glGetTexImage(GL_TEXTURE_2D, ix, GL_RGBA, GL_BYTE, pixels);
         SwapY(pixels,xSize,ySize,4);
         glTexImage2D(GL_TEXTURE_2D, ix, GL_RGBA, xsize, ysize, 0, GL_RGBA, GL_BYTE, pixels);
         x := (x+1) shr 1;
         y := (y+1) shr 1;
         size := x * y * li.blockBytes;
      end;
      FreeMem(data);
      glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_FALSE);
      glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
   end;
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, mipMapCount-1);
   FreeMem(pixels);

   GetMem(data, _Width*_Height*4);
   glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
   gluBuild2DMipmaps(GL_TEXTURE_2D, 4, _Width,_Height, GL_RGBA, GL_UNSIGNED_BYTE, Data);
   FreeMem(data);

   result := true;
end;

function TDDSImage.LoadFromFile(const _Filename: string; var _Texture: Cardinal; _NoPicMip : Boolean; Var _Width,_Height : Integer): boolean;
var
   MyFile: TStream;
begin
   Result := false;
   if FileExists(_Filename) then
   begin
      MyFile := TFileStream.Create(_Filename,fmOpenRead);
      Result := LoadDDS(MyFile,_Texture,_NoPicMip,_Width,_Height);
      MyFile.Free;
   end;
end;


// This is written by Banshee and it ignores volumes, cube maps and any non-RGBA or RGB texture.
function TDDSImage.SaveDDS(var _Stream: TStream; Var _Texture : Cardinal; _Compression : GLINT = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT): boolean;
var
   hdr: TDDSHeader;
   Border,x, y, xSize, ySize, i, Size: Cardinal;
   data,pixels: PBytes;
   tempi : PGLInt;
   IsRGBA, IsCompressed: boolean;
begin
   result := false;
   //  DDS is so simple to write, too
   hdr.dwMagic := DDS_MAGIC;
   hdr.dwSize := 124;
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D,_Texture);
   glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
   GetMem(tempi,4);
   glGetTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_MAX_LEVEL,tempi);
   x := tempi^;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexParameteriv(GL_TEXTURE_2D,GL_TEXTURE_BASE_LEVEL,tempi);
   x := x - tempi^;
   FreeMem(tempi);
   // Note, we'll only save compressed textures.
   if (x > 0) and (x <> 1000) then
   begin
      hdr.dwMipMapCount := x+1;
      hdr.dwFlags := $A1007;
      hdr.Caps.dwCaps1 := $401008;
   end
   else
   begin
      hdr.dwMipMapCount := 1;
      hdr.dwFlags := $81007;
      hdr.Caps.dwCaps1 := $1000;
   end;
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_BORDER,tempi);
   Border := tempi^;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_HEIGHT,tempi);
   hdr.dwHeight := tempi^ - Border;
   FreeMem(tempi);
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_WIDTH,tempi);
   hdr.dwWidth := tempi^ - Border;
   FreeMem(tempi);
   hdr.dwDepth := 0;    // volume maps are ignored.
   hdr.Caps.dwCaps2 := 0; // volume and cube maps are ignored.
   hdr.Caps.dwDDSX := 0;
   hdr.Caps.dwReserved := 0;
   hdr.PixelFormat.dwSize := 24;
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_INTERNAL_FORMAT,tempi);
   hdr.PixelFormat.dwFlags := DDPF_RGB or DDPF_FOURCC;
   hdr.PixelFormat.dwRBitMask := $ff0000;
   hdr.PixelFormat.dwGBitMask := $ff00;
   hdr.PixelFormat.dwBBitMask := $ff;
   hdr.PixelFormat.dwRGBBitCount := 24;
   IsRGBA := false;
   if tempi^ = GL_ALPHA then
   begin
      hdr.PixelFormat.dwFlags := hdr.PixelFormat.dwFlags or DDPF_ALPHAPIXELS;
      hdr.PixelFormat.dwAlphaBitMask := $ff000000;
      hdr.PixelFormat.dwRGBBitCount := 32;
      hdr.PixelFormat.dwSize := 32;
      IsRGBA := true;
   end;
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_ALPHA_SIZE,tempi);
   if tempi^ > 0 then
   begin
      hdr.PixelFormat.dwFlags := hdr.PixelFormat.dwFlags or DDPF_ALPHAPIXELS;
      hdr.PixelFormat.dwAlphaBitMask := $ff000000;
      hdr.PixelFormat.dwRGBBitCount := 32;
      IsRGBA := true;
   end;
   FreeMem(tempi);
   // Force compression of level 0 texture for linear size.
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_COMPRESSED,tempi);
   IsCompressed := tempi^ > 0;
   FreeMem(tempi);
   if not IsCompressed then
   begin
      // Compress the texture. Note that we need to flip the texture in the y axis.
      if IsRGBA then
      begin
         GetMem(pixels, hdr.dwWidth*hdr.dwHeight*4);
         glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
         SwapY(pixels,hdr.dwWidth,hdr.dwHeight,4);
         glTexImage2D(GL_TEXTURE_2D,0,_Compression,hdr.dwWidth,hdr.dwHeight,0,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
      end
      else
      begin
         GetMem(pixels, hdr.dwWidth*hdr.dwHeight*3);
         glGetTexImage(GL_TEXTURE_2D,0,GL_RGB,GL_UNSIGNED_BYTE,pixels);
         SwapY(pixels,hdr.dwWidth,hdr.dwHeight,3);
         glTexImage2D(GL_TEXTURE_2D,0,GL_COMPRESSED_RGB_S3TC_DXT1_EXT,hdr.dwWidth,hdr.dwHeight,0,GL_RGB,GL_UNSIGNED_BYTE,pixels);
      end;
   end;
   if isRGBA then
   begin
      hdr.PixelFormat.dwFourCC := D3DFMT_DXT5;
   end
   else
   begin
      hdr.PixelFormat.dwFourCC := D3DFMT_DXT1;
   end;
   GetMem(tempi,4);
   glGetTexLevelParameteriv(GL_TEXTURE_2D,0,GL_TEXTURE_COMPRESSED_IMAGE_SIZE,tempi);
   hdr.dwPitchOrLinearSize := tempi^;
   FreeMem(tempi);

   // Write reserved.
   for i := 0 to 10 do
      hdr.dwReserved[i] := 0;

   // Write header.
   _Stream.Write(hdr, sizeof(hdr));
   // Write first texture.
   GetMem(data, hdr.dwPitchOrLinearSize);
   glGetCompressedTexImage(GL_TEXTURE_2D,0,data);
   _Stream.Write(data^,hdr.dwPitchOrLinearSize);
   FreeMem(data);

   // Here we unflip the texture in the Y axis.
   if not IsCompressed then
   begin
      if IsRGBA then
      begin
         SwapY(pixels,hdr.dwWidth,hdr.dwHeight,4);
         glTexImage2D(GL_TEXTURE_2D,0,_Compression,hdr.dwWidth,hdr.dwHeight,0,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
      end
      else
      begin
         SwapY(pixels,hdr.dwWidth,hdr.dwHeight,3);
         glTexImage2D(GL_TEXTURE_2D,0,GL_COMPRESSED_RGB_S3TC_DXT1_EXT,hdr.dwWidth,hdr.dwHeight,0,GL_RGB,GL_UNSIGNED_BYTE,pixels);
      end;
      FreeMem(pixels);
   end;

   // Does it have mipmaps? Write them as well.
   i := 1;
   while i < hdr.dwMipMapCount do
   begin
      // Get the dimensions of the mipmap
      GetMem(tempi,4);
      glGetTexLevelParameteriv(GL_TEXTURE_2D,i,GL_TEXTURE_WIDTH,tempi);
      xSize := tempi^;
      FreeMem(tempi);
      GetMem(tempi,4);
      glGetTexLevelParameteriv(GL_TEXTURE_2D,i,GL_TEXTURE_HEIGHT,tempi);
      ySize := tempi^;
      FreeMem(tempi);
      // Is the current mipmap compressed?
      GetMem(tempi,4);
      glGetTexLevelParameteriv(GL_TEXTURE_2D,i,GL_TEXTURE_COMPRESSED,tempi);
      IsCompressed := tempi^ > 0;
      FreeMem(tempi);
      if not IsCompressed then
      begin
         // It is not, then compress the texture first.
         if IsRGBA then
         begin
            GetMem(pixels, xSize*ySize*4);
            glGetTexImage(GL_TEXTURE_2D,i,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
            SwapY(pixels,xSize,ySize,4);
            glTexImage2D(GL_TEXTURE_2D,i,_Compression,xSize,ySize,0,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
         end
         else
         begin
            GetMem(pixels, xSize*ySize*3);
            glGetTexImage(GL_TEXTURE_2D,i,GL_RGB,GL_UNSIGNED_BYTE,pixels);
            SwapY(pixels,xSize,ySize,3);
            glTexImage2D(GL_TEXTURE_2D,i,GL_COMPRESSED_RGB_S3TC_DXT1_EXT,xSize,ySize,0,GL_RGB,GL_UNSIGNED_BYTE,pixels);
         end;
      end;
      // Now we get the compressed size.
      GetMem(tempi,4);
      glGetTexLevelParameteriv(GL_TEXTURE_2D,i,GL_TEXTURE_COMPRESSED_IMAGE_SIZE,tempi);
      Size := tempi^;
      FreeMem(tempi);

      // Write the texture.
      GetMem(data, Size);
      glGetCompressedTexImage(GL_TEXTURE_2D,i,data);
      _Stream.Write(data^,Size);
      FreeMem(data);

      // Here we unflip the texture in the Y axis.
      if not IsCompressed then
      begin
         if IsRGBA then
         begin
            SwapY(pixels,xSize,ySize,4);
            glTexImage2D(GL_TEXTURE_2D,i,_Compression,xSize,ySize,0,GL_RGBA,GL_UNSIGNED_BYTE,pixels);
         end
         else
         begin
            SwapY(pixels,xSize,ySize,3);
            glTexImage2D(GL_TEXTURE_2D,i,GL_COMPRESSED_RGB_S3TC_DXT1_EXT,xSize,ySize,0,GL_RGB,GL_UNSIGNED_BYTE,pixels);
         end;
         FreeMem(pixels);
      end;

      // go to next mipmap level.
      inc(i);
   end;
   glDisable(GL_TEXTURE_2D);
end;

function TDDSImage.SaveToFile(const _Filename: string; _Texture: Cardinal): boolean;
var
   MyFile: TStream;
begin
   Result := false;
   MyFile := TFileStream.Create(_Filename,fmCreate);
   SaveDDS(MyFile,_Texture);
   MyFile.Free;
   Result := true;
end;

function TDDSImage.SaveToFile(const _Filename: string; _Texture, _Compression: Cardinal): boolean;
var
   Compression : TGLInt;
begin
   case _Compression of
      D3DFMT_DXT1:
      begin
         Compression := GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
      end;
      D3DFMT_DXT3:
      begin
         Compression := GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
      end;
      D3DFMT_DXT5:
      begin
         Compression := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
      end
      else
      begin
         Compression := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
      end;
   end;
   SaveToFile(_Filename,_Texture,Compression);
end;


end.
