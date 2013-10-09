 {Delphi 16/256-Color PCX Reader Support objects}
 {copyright 1998, MDRUtils(tm) Mark D. Rafn}

 // **************************************************************************
 // NOTE: Range Checking is turned off due to Borland zero length array types
 // procedures needing this directive are labeled if you want to isolate
 // **************************************************************************

{$R-}
unit Pcxctrl;

interface

uses
   SysUtils, Windows, Messages, Classes, Graphics, Controls,
   Forms, Dialogs;

type

   {use this structure instead of TRGBTriple.}
   {TRGBTriple is reversed, confusing with read results}
   TPCXTriple = record
      r, g, b: byte;
   end;

   TPCXColors256 = array[0..255] of TPCXTriple;
   TPcxColors16  = array[0..15] of TPCXTriple;

   TPCXHeader = record
      Maker:    byte;
      Version:  byte;
      Encoding: byte;
      Bpp:      byte;
      Xmn, Ymn: smallint;
      Xmx, Ymx: smallint;
      HRes, VRes: smallint;
      CMap:     TPcxColors16;
      Reserved: byte;
      NPlanes:  byte;
      NBpl:     smallint;
      PalType:  smallint;
   end;

type

   TPCXColorModel = (Color16, Color256);

   TPCXBitmap = class(TBitmap)
   private
      FHeader:     TPCXHeader;
      FColorModel: TPCXColorModel;
      function ConvertStream(Stream: TStream): TMemoryStream;
   public
      constructor Create; override;
      destructor Destroy; override;
      procedure LoadFromStream(Stream: TStream); override;
   end;

   TDecoder = class
      ImageHeight, ImageWidth: longint;
      ImageBytesPerLine: longint;
      Buffer:      array[0..1023] of byte;
      BufferIndex: integer;
      bmiSize:     word;
      ImageOffset: integer;
   protected
      procedure Decode_Row(Stream: TStream; RL: integer; ScanLine: TMemoryStream);
      function MakeBMIInfo(Stream: TStream): PBitmapInfo; virtual;
      function MakeBMInfoHeader: TBitMapInfoHeader; virtual; abstract;
      procedure MakeBMIColors(Stream: TStream; BitmapInfo: PBitmapInfo);
         virtual; abstract;
      function GetPaletteSize: integer; virtual; abstract;
      function MakeBMFileHeader(Bmi: PBitmapInfo): TBitmapFileHeader;
      function GetImageSize: longint;
   public
      constructor Create;
      destructor Destroy; override;
      function DecodeStream(AStream: TStream; AHeader: TPCXHeader;
         AImage: TMemoryStream): integer; virtual; abstract;
   end;

   TDecoder256 = class(TDecoder)
   protected
      function MakeBMInfoHeader: TBitMapInfoHeader; override;
      procedure MakeBMIColors(Stream: TStream; BitmapInfo: PBitmapInfo); override;
      function GetPaletteSize: integer; override;
   public
      function DecodeStream(AStream: TStream; PCXHeader: TPCXHeader;
         AImage: TMemoryStream): integer; override;
   end;

   TDecoder16 = class(TDecoder)
   protected
      function MakeBMInfoHeader: TBitMapInfoHeader; override;
      procedure MakeBMIColors(Stream: TStream; BitmapInfo: PBitmapInfo); override;
      function GetPaletteSize: integer; override;
   public
      function DecodeStream(AStream: TStream; PCXHeader: TPCXHeader;
         AImage: TMemoryStream): integer; override;
   end;

   EPCXPropertyError = class(Exception);

implementation

function AlignDouble(Size: longint): longint;
begin
   AlignDouble := (Size + 3) div 4 * 4;
end;

procedure InvalidGraphic(Str: string); near;
begin
   raise EInvalidGraphic.Create(Str);
end;

{ TPCXBitmap }
constructor TPCXBitmap.Create;
begin
   inherited Create;
end;

destructor TPCXBitmap.Destroy;
begin
   inherited Destroy;
end;

function TPCXBitmap.ConvertStream(Stream: TStream): TMemoryStream;
var
   Image:   TMemoryStream;
   Decoder: TDecoder;
   ImageHeight, ImageWidth: integer;
   Size:    longint;
   BMI:     TBitmapInfo;
   Bmf:     TBitmapFileHeader;
begin
   Result := nil;
   Stream.Position := 0;
   Stream.Read(FHeader, Sizeof(FHeader));
   with FHeader do
   begin
      if Maker <> $0A then
         Exit;
      if (Bpp = 8) and (NPlanes = 1) then
         FColorModel := Color256
      else if (Bpp = 1) and (NPlanes = 4) then
         FColorModel := Color16
      else
         Exit;
      ImageHeight := longint(Ymx) - longint(Ymn) + 1;
      ImageWidth  := longint(Xmx) - longint(Xmn) + 1;
   end;
   Image := TMemoryStream.Create;
   if FColorModel = Color16 then
      Decoder := TDecoder16.Create
   else
      Decoder := TDecoder256.Create;
   try
      if Decoder.DecodeStream(Stream, FHeader, Image) = 1 then
      begin
         Image.Position := 0;
         Result := Image;
      end
      else
         Image.Free;
   finally
      Decoder.Free;
   end;
end;

procedure TPCXBitmap.LoadFromStream(Stream: TStream);
var
   Image: TMemoryStream;
begin
   Image := ConvertStream(Stream);
   if Image = nil then
      inherited LoadFromStream(Stream)
   else
      inherited LoadFromStream(Image);
end;

{ TDecoder }
constructor TDecoder.Create;
begin
   inherited Create;
   BufferIndex := 0;
   FillChar(Buffer, SizeOf(Buffer), 0);
   ImageBytesPerLine := -1;
end;

destructor TDecoder.Destroy;
begin
   inherited Destroy;
end;

{ Decode an entire scanline into S regardless of image type }
procedure TDecoder.Decode_Row(Stream: TStream; RL: integer; ScanLine: TMemoryStream);
var
   i, ByteCount, Repeats, RunLength: integer;
   b: byte;
   NumRead: integer;
   ReadCount, Count: longint;
begin
   ByteCount := 0;
   RunLength := RL;

   ReadCount := SizeOf(Buffer);
   Count     := Stream.Size - Stream.Position;
   if BufferIndex = 0 then
      if Count > ReadCount then
         Stream.ReadBuffer(Buffer, ReadCount)
      else
         Stream.ReadBuffer(Buffer, Count);
   while (ByteCount < RunLength) do
   begin
      if BufferIndex = 1024 then
      begin
         if Count > ReadCount then
            Stream.ReadBuffer(Buffer, ReadCount)
         else
            Stream.ReadBuffer(Buffer, Count);
         BufferIndex := 0;
      end;
      b := Buffer[BufferIndex];
      BufferIndex := BufferIndex + 1;
      if (b >= 192) then
      begin
         Repeats := b - 192;
         if BufferIndex = 1024 then
         begin
            if Count > ReadCount then
               Stream.ReadBuffer(Buffer, ReadCount)
            else
               Stream.ReadBuffer(Buffer, Count);
            BufferIndex := 0;
         end;
         b := Buffer[BufferIndex];
         BufferIndex := BufferIndex + 1;
         for i := 1 to Repeats do
         begin
            ScanLine.Write(b, 1);
            ByteCount := ByteCount + 1;
         end;
      end
      else
      begin
         ScanLine.Write(b, 1);
         ByteCount := ByteCount + 1;
      end;
   end;
end;

function TDecoder.MakeBMFileHeader(Bmi: PBitmapInfo): TBitmapFileHeader;
var
   Bmf: TBitmapFileHeader;
   ImageSize: longint;
begin
   with Bmf do
   begin
      bfType      := $4D42;
      bfSize      := SizeOf(Bmf) + BmiSize + GetImageSize;
      bfReserved1 := 0;
      bfReserved2 := 0;
      bfOffBits   := SizeOf(Bmf) + BmiSize;
   end;
   Result := Bmf;
end;

function TDecoder.MakeBMIInfo(Stream: TStream): PBitmapInfo;
var
   Bmi: PBitmapInfo;
begin
   Bmi     := nil;
   bmiSize := SizeOf(TBitmapInfoHeader) + GetPaletteSize;
   try
      GetMem(Bmi, bmiSize);
      Bmi^.bmiHeader := MakeBMInfoHeader;
      MakeBMIColors(Stream, Bmi);
   except
      raise;
   end;
   Result := Bmi;
end;

function TDecoder.GetImageSize: longint;
begin
   Result := ImageBytesPerLine * ImageHeight;
end;

{ TDecoder256 }
function TDecoder256.DecodeStream(AStream: TStream; PCXHeader: TPCXHeader;
   AImage: TMemoryStream): integer;
var
   Bmi:      PBitMapInfo;
   Bmf:      TBitmapFileHeader;
   Image:    TMemoryStream;
   Scanline: TMemoryStream;
   LineCount: integer;
   Size:     longint;
begin
   Result := 0;
   Image  := AImage;
   with PCXHeader do
   begin
      ImageHeight := longint(Ymx) - longint(Ymn) + 1;
      ImageWidth  := longint(Xmx) - longint(Xmn) + 1;
      ImageBytesPerLine := AlignDouble(longint(NBpl));
   end;
   Bmi  := MakeBMIInfo(AStream);
   Bmf  := MakeBMFileHeader(Bmi);
   Size := SizeOf(Bmf) + BmiSize + GetImageSize;
   ImageOffset := Bmf.bfOffBits;
   try
      Image.SetSize(Size);
   except
      raise;
      Exit;
   end;
   try
      Image.Write(Bmf, SizeOf(Bmf));
      Image.Write(Bmi^, BmiSize);
   except
      raise;
      Exit;
   end;
   ScanLine := TMemoryStream.Create;
   try
      ScanLine.SetSize(ImageBytesPerLine);
   except
      raise;
      Exit;
   end;
   AStream.Seek(128, 0);
   for LineCount := (ImageHeight - 1) downto 0 do
   begin
      ScanLine.Position := 0;
      //Decode_Row(AStream, ImageBytesPerLine, ScanLine); this was wrong 12.20.97
      Decode_Row(AStream, pcxheader.nbpl, ScanLine);
      try
         Image.Position := longint(ImageOffset) + (longint(LineCount) *
            longint(ImageBytesPerLine));
         Image.Write(Scanline.Memory^, ImageBytesPerLine);
      except
         raise;
         Exit;
      end;
   end;
   ScanLine.Free;
   Result := 1;
end;

function TDecoder256.MakeBMInfoHeader: TBitMapInfoHeader;
var
   BitMapInfoHeader: TBitMapInfoHeader;
begin
   with BitmapInfoHeader do
   begin
      biSize      := Sizeof(TBitmapInfoHeader);
      biWidth     := ImageWidth;
      biHeight    := ImageHeight;
      biPlanes    := 1;
      biBitCount  := 8;
      biCompression := 0;
      biSizeImage := GetImageSize;
      biXPelsperMeter := 0;
      biYPelsperMeter := 0;
      biClrUsed   := 256;
      biClrImportant := 0;
   end;
   Result := BitmapInfoHeader;
end;

{R-}
procedure TDecoder256.MakeBMIColors(Stream: TStream; BitmapInfo: PBitmapInfo);
var
   b: byte;
   i: integer;
   PCXColors: TPCXColors256;
begin
   Stream.Position := Stream.Size - 769;
   Stream.Read(b, 1);
   if b = $0C then
   begin
      Stream.Read(PCXColors, SizeOf(PCXColors));
      for i := 0 to 255 do
         with BitMapInfo^.bmiColors[i], PCXColors[i] do
         begin
            rgbRed      := r;
            rgbGreen    := g;
            rgbBlue     := b;
            rgbReserved := 0;
         end;
   end;
end;

{R+}

function TDecoder256.GetPaletteSize: integer;
begin
   Result := Sizeof(TRGBQuad) * 256;
end;

{ TDecoder16 }
function TDecoder16.MakeBMInfoHeader: TBitMapInfoHeader;
var
   BitMapInfoHeader: TBitMapInfoHeader;
begin
   with BitmapInfoHeader do
   begin
      biSize      := Sizeof(TBitmapInfoHeader);
      biWidth     := ImageWidth;
      biHeight    := ImageHeight;
      biPlanes    := 1;
      biBitCount  := 4;
      biCompression := 0;
      biSizeImage := GetImagesize;
      biXPelsperMeter := 0;
      biYPelsperMeter := 0;
      biClrUsed   := 0;
      biClrImportant := 0;
   end;
   Result := BitmapInfoHeader;
end;

{R-}
procedure TDecoder16.MakeBMIColors(Stream: TStream; BitmapInfo: PBitmapInfo);
var
   b:      byte;
   i:      integer;
   Header: TPCXHeader;
begin
   Stream.Position := 0;
   Stream.Read(Header, Sizeof(Header));
   for i := 0 to 15 do
      with BitMapInfo^.bmiColors[i], Header.CMap[i] do
      begin
         rgbRed      := r;
         rgbGreen    := g;
         rgbBlue     := b;
         rgbReserved := 0;
      end;
end;

{R+}

function TDecoder16.GetPaletteSize: integer;
begin
   Result := Sizeof(TRGBQuad) * 16;
end;

function TDecoder16.DecodeStream(AStream: TStream; PCXHeader: TPCXHeader;
   AImage: TMemoryStream): integer;
var
   Bmi:      PBitMapInfo;
   Bmf:      TBitmapFileHeader;
   Image:    TMemoryStream;
   Scanline: TMemoryStream;
   ConvertedLine: TMemoryStream;
   LineCount: integer;
   Size:     longint;

   {not real elegant, but it works for now...}
   procedure ConvertLine;
   var
      b1, b2, b3, b4, NewByte: byte;
      i, j:      integer;
      aNewBytes: array[0..3] of byte;
   begin
      ConvertedLine.Seek(0, 0);
      for i := 0 to (PCXHeader.Nbpl - 1) do
      begin
         ScanLine.Seek(i, 0);
         Scanline.Read(b1, 1);
         ScanLine.Seek(i + PCXHeader.Nbpl, 0);
         Scanline.Read(b2, 1);
         ScanLine.Seek(i + (PCXHeader.Nbpl * 2), 0);
         Scanline.Read(b3, 1);
         ScanLine.Seek(i + (PCXHeader.Nbpl * 3), 0);
         Scanline.Read(b4, 1);
         for j := 0 to 3 do
         begin
            NewByte := 0;
            NewByte :=
               ((b1 and $80) shr 3) or ((b2 and $80) shr 2) or
               ((b3 and $80) shr 1) or (b4 and $80) or
               ((b1 and $40) shr 6) or ((b2 and $40) shr 5) or
               ((b3 and $40) shr 4) or ((b4 and $40) shr 3);
            b1      := b1 shl 2;
            b2      := b2 shl 2;
            b3      := b3 shl 2;
            b4      := b4 shl 2;
            aNewBytes[j] := NewByte;
         end;
         ConvertedLine.Write(aNewBytes, 4);
      end;
   end;

begin
   Result := 0;
   Image  := AImage;
   with PCXHeader do
   begin
      ImageHeight := longint(Ymx) - longint(Ymn) + 1;
      ImageWidth  := longint(Xmx) - longint(Xmn) + 1;
      ImageBytesPerLine := AlignDouble(NBpl * NPlanes);
   end;
   Bmi  := MakeBMIInfo(AStream);
   Bmf  := MakeBMFileHeader(Bmi);
   Size := SizeOf(Bmf) + BmiSize + (ImageBytesPerLine * ImageHeight);
   ImageOffset := Bmf.bfOffBits;
   try
      Image.SetSize(Size);
   except
      raise;
      Exit;
   end;
   try
      Image.Write(Bmf, SizeOf(Bmf));
      Image.Write(Bmi^, BmiSize);
   except
      raise;
      Exit;
   end;
   ScanLine      := TMemoryStream.Create;
   ConvertedLine := TMemoryStream.Create;
   try
      ScanLine.SetSize(ImageBytesPerLine);
      ConvertedLine.SetSize(ImageBytesPerLine);
   except
      raise;
      Exit;
   end;
   AStream.Seek(128, 0);
   for LineCount := (ImageHeight - 1) downto 0 do
   begin
      ScanLine.Position := 0;
      // originally changed the next line to read the same as the 256 decoder
      // but a problem reported by a user showed the orginal code was correct
      // so I changed it back.  The following line is original code and displays
      // correctly.  02.10.98
      Decode_Row(AStream, ImageBytesPerLine, ScanLine);
      ConvertLine;
      try
         Image.Position := longint(ImageOffset) + (longint(LineCount) *
            longint(ImageBytesPerLine));
         Image.Write(ConvertedLine.Memory^, ImageBytesPerLine);
      except
         raise;
         ScanLine.Free;
         ConvertedLine.Free;
         Exit;
      end;
   end;
   ScanLine.Free;
   ConvertedLine.Free;
   Result := 1;
end;

{$R+}
end.
