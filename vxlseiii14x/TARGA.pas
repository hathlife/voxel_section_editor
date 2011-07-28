// Targa unit developed by Davie Reed, davie@smatters.com

unit Targa;

interface

uses
   Windows, Classes, Graphics;

{
{ Setup the following variable before calling LoadFromFileX
{
{ Global_KeepTrueFormat:Word
{ 0 = Use the files native bits per pixel for the TBitMap
{ 1 = Force TBitMap of 256 colors and use gray it file was 24bit
{ 2 = Force TBitMap to 24bit
{
{ SAVETOFILEX(parm1,parm2,parm3);
{    Parm1=Filename
{    Parm2=TBitMap to save
{    Parm3=Type of TGA file to create
{           1 = Save as 256 Color file
{           2 = Save as 16M file
}

procedure SaveToFileX(FileName: string; const BitMap: TBitMap; MyPcxType: byte);
procedure LoadFromFileX(FileName: string; const BitMap: TBitMap);

type
   TTarga = class(TGraphic)
   end;

implementation

type
   TGAHeader = packed record
      IdentSize: byte;
      ColorMapType: byte;
      ImageType: byte;
      ColorMapStart: word;
      ColorMapLength: word;
      ColorMapBits: byte;
      XStart: word;
      YStart: word;
      Width:  word;
      Height: word;
      Bits:   byte;
      Descriptor: byte;
   end;

type
   TypeRegVer    = set of (Non_Registered, Registered, OEM, PRO, SYSOP);
   DataLineArray = array[0..65535] of byte;
   DataWordArray = array[0..65535] of smallint;

   FakePalette = packed record
      LPal:  TLogPalette;
      Dummy: array[1..255] of TPaletteEntry;
   end;

   TypeEgaPalette = array[0..16] of byte;
   TypePalette    = array[0..255, 1..3] of byte;

const
   Global_HiColor = 3;
   Global_KeepTrueFormat: word = 2;

var
   PictureFile: file;
   PaletteVGA:  TypePalette;
   SysPal:      FakePalette;
   TempArrayD:  ^DataLineArray;
   TempArrayD2: ^DataLineArray;
   TempArrayDBIg: ^DataLineArray;

   ErrorString: ShortString;
   Width:      word;
   Height:     word;
   BitsPerPixel: smallint;
   Compressed: boolean;
   TGAHead:    TGAHeader;
   MyKeepTrueFormat: boolean;
   MyKeepTrueBits: word;
   FileOk:     boolean;




const
   Const4096 = 8 * 1024;

var
   Index1:    word = 0;
   Index2:    word = 0;
   IndexData: array[0..Const4096 - 1] of byte;

procedure FileGetMore;
var
   NumRead: integer;
begin
   FillChar(IndexData, Const4096, 0);
   BlockRead(PictureFile, IndexData, Const4096, NumRead);
   Index1 := Const4096;
   Index2 := 0;
end;

procedure FastGetBytes(var Ptr1; NumBytes: word);
var
   X: integer;
begin
{
{ If we have enough the block it!
{ Otherwise do one at a time!
}
   if Index1 < NumBytes then
   begin
      if Index1 = 0 then
      begin
         FileGetMore;
      end;
      for X := 0 to NumBytes - 1 do
      begin
         DataLineArray(Ptr1)[X] := IndexData[Index2];
         Inc(Index2);
         Dec(Index1);
         if Index1 = 0 then
            FileGetMore;
      end;
   end
   else
   begin
   {
   { Block it fast!
   }
      Move(IndexData[Index2], DataLineArray(Ptr1)[0], NumBytes);
      Index2 := Index2 + Numbytes;
      Index1 := Index1 - NumBytes;
   end;
end;

function FastGetByte: byte;
begin
   if Index1 = 0 then
   begin
      FileGetMore;
   end;
   FastGetByte := IndexData[Index2];
   Inc(Index2);
   Dec(Index1);
end;

function FastGetWord: word;
begin
   FastGetWord := word(FastGetByte) + word(FastGetByte) * 256;
end;

procedure FileIoReset;
begin
   Index1 := 0;
   Index2 := 0;
end;

procedure OpenFile(var FileName: string; var FileOk: boolean);
var
   Io: integer;
   OldFileMode: word;
begin
   FileIoReset;
   // Io:=IoResult;
   OldFileMode := FileMode;
   FileMode    := 0;
   AssignFile(PictureFile, FileName);
   ReSet(PictureFile, 1);
   Io := IoResult;
   if Io <> 0 then
   begin
      FileOk := False;
   end;
   FileMode := OldFileMode;
end;

procedure FillerUp(var TempArrayD; Size: word; B1: byte);
begin
   FillChar(TempArrayD, Size, B1);
end;

procedure ConvertXBitsToYBits(var Input, Output: DataLineArray; Xbits, Ybits, Width: word);
var
   X, Z: word;
   B1:   byte;
begin
{
{ Generic converter to a single data line :)
{ Can go only from smaller bits to larger bits, otherwise you need to
{     dither down!
{ PaletteVGA MUST be setup already!
}
   case Xbits of
      1:
      begin
         case Ybits of
            4:
            begin
              {
              { From 1 bit to 4 bit, hmmmmm EZ :)
              }
               for X := 0 to Width - 1 do
               begin
                  B1 := (Input[X shr 3] shr (7 - (X mod 8))) and 1;
                  OutPut[X shr 1] := OutPut[X shr 1] or (B1 shl ((1 - (X mod 2)) * 4));
               end;
            end;
            8:
            begin
              {
              { From 1 bit to 8 bit, hmmmmm EZ :)
              }
               for X := 0 to Width - 1 do
               begin
                  B1 := (Input[X shr 3] shr (7 - (X mod 8))) and 1;
                  OutPut[X] := B1;
               end;
            end;
            24:
            begin
              {
              { From 1 bit to 8 bit, hmmmmm EZ :)
              }
               Z := 0;
               for X := 0 to Width - 1 do
               begin
                  B1 := ((Input[X shr 3] shr (7 - (X mod 8))) and 1) * 255;
                  OutPut[Z + 0] := B1;
                  OutPut[Z + 1] := B1;
                  OutPut[Z + 2] := B1;
                  Z  := Z + 3;
               end;
            end;
         end;
      end;
      4:
      begin
         case Ybits of
            4:
            begin
               Move(Input[0], Output[0], Width);
            end;
            8:
            begin
              {
              { Go from 4 bits to 8 bit :)
              }
               for X := 0 to Width - 1 do
               begin
                  B1 := (Input[X shr 1] shr ((1 - (X mod 2)) * 4)) and $0F;
                  OutPut[X] := B1;
               end;
            end;
            24:
            begin
              {
              { Go from 4 bits to 24 bit :)
              }
               Z := 0;
               for X := 0 to Width - 1 do
               begin
                  B1 := (Input[X shr 1] shr ((1 - (X mod 2)) * 4)) and $0F;
                  OutPut[Z + 0] := (PaletteVGA[B1, 3] * 255) div 63;
                  OutPut[Z + 1] := (PaletteVGA[B1, 2] * 255) div 63;
                  OutPut[Z + 2] := (PaletteVGA[B1, 1] * 255) div 63;
                  Z  := Z + 3;
               end;
            end;
         end;
      end;
      8:
      begin
         case Ybits of
            1:
            begin
               for X := 0 to Width - 1 do
                  OutPut[X shr 3] := 0;
               for X := 0 to Width - 1 do
               begin
                  B1 := InPut[X];
                  OutPut[X shr 3] := OutPut[X shr 3] or (B1 shl (7 - (X mod 8)));
               end;
            end;
            8:
            begin
               Move(Input[0], Output[0], Width);
            end;
            24:
            begin
              {
              { From 8 bit to 24 bit, hmmmmm 2EZ :)
              }
               Z := 0;
               for X := 0 to Width - 1 do
               begin
                  B1 := Input[X];
                  OutPut[Z + 0] := (PaletteVGA[B1, 3] * 255) div 63;
                  OutPut[Z + 1] := (PaletteVGA[B1, 2] * 255) div 63;
                  OutPut[Z + 2] := (PaletteVGA[B1, 1] * 255) div 63;
                  Z  := Z + 3;
               end;
            end;
         end;
      end;
      24:
      begin
         case Ybits of
            24:
            begin
               Move(Input[0], Output[0], Width * 3);
            end;
         end;
      end;
   end;
end;




procedure SetUpMaskGrayPalette;
var
   I, J: word;
begin
   for J := 0 to 255 do
   begin
      for I := 1 to 3 do
      begin
         PaletteVga[J, I] := J * 63 div 255;
      end;
   end;
end;

function PCXGrayValue(R, G, B: word): word;
begin
   PCXGrayValue := ((R shl 5) + (G shl 6) + (B * 12)) div 108;
end;

procedure MakePalBW(const BitMap: TBitMap);
begin
   SysPal.LPal.palVersion := $300;
   SysPal.LPal.palNumEntries := 2;
   Syspal.LPal.PalPalEntry[0].peRed := 0;
   Syspal.LPal.PalPalEntry[0].peGreen := 0;
   Syspal.LPal.PalPalEntry[0].peBlue := 0;
   Syspal.LPal.PalPalEntry[0].peFlags := 0;
   Syspal.Dummy[1].peRed := 255;
   Syspal.Dummy[1].peGreen := 255;
   Syspal.Dummy[1].peBlue := 255;
   Syspal.Dummy[1].peFlags := 0;
   Bitmap.Palette := CreatePalette(Syspal.LPal);
end;

procedure MakePalPalette(const BitMap: TBitMap);
var
   I: word;
begin
   SysPal.LPal.palVersion    := $300;
   SysPal.LPal.palNumEntries := 256;
   for I := 0 to 255 do
   begin
      Syspal.LPal.PalPalEntry[I].peRed   := (PaletteVga[I, 1]) * 4;
      Syspal.LPal.PalPalEntry[I].peGreen := (PaletteVga[I, 2]) * 4;
      Syspal.LPal.PalPalEntry[I].peBlue  := (PaletteVga[I, 3]) * 4;
      Syspal.LPal.PalPalEntry[I].peFlags := 0;
   end;
   Bitmap.Palette := CreatePalette(Syspal.LPal);
end;

procedure MakePalPaletteX(const BitMap: TBitMap; HowMany: word);
var
   I: word;
begin
   SysPal.LPal.palVersion    := $300;
   SysPal.LPal.palNumEntries := HowMany;
   for I := 0 to HowMany - 1 do
   begin
      Syspal.LPal.PalPalEntry[I].peRed   := (PaletteVga[I, 1]) * 4;
      Syspal.LPal.PalPalEntry[I].peGreen := (PaletteVga[I, 2]) * 4;
      Syspal.LPal.PalPalEntry[I].peBlue  := (PaletteVga[I, 3]) * 4;
      Syspal.LPal.PalPalEntry[I].peFlags := 0;
   end;
   Bitmap.Palette := CreatePalette(Syspal.LPal);
end;

procedure SaveThePalette(const HPal: HPalette; var SavePal: TypePalette);
var
   I: word;
begin
   for I := 0 to 255 do
   begin
      Syspal.LPal.PalPalEntry[I].peRed   := 0;
      Syspal.LPal.PalPalEntry[I].peGreen := 0;
      Syspal.LPal.PalPalEntry[I].peBlue  := 0;
   end;
   GetPaletteEntries(HPal, 0, 256, SysPal.LPal.PalPalEntry[0]);
   for I := 0 to 255 do
   begin
      SavePal[I, 1] := (((Syspal.LPal.PalPalEntry[I].peRed)) div 4);
      SavePal[I, 2] := (((Syspal.LPal.PalPalEntry[I].peGreen)) div 4);
      SavePal[I, 3] := (((Syspal.LPal.PalPalEntry[I].peBlue)) div 4);
   end;
end;

procedure MakeGenPalette;
var
   X: word;
   R, G, B: word;
begin
   X := 0;
   for R := 0 to 7 do
   begin
      for G := 0 to 7 do
      begin
         for B := 0 to 3 do
         begin
            PaletteVga[X, 1] := (R + 1) * 8 - 1;
            PaletteVga[X, 2] := (G + 1) * 8 - 1;
            PaletteVga[X, 3] := (B + 1) * 16 - 1;
            Inc(X);
         end;
      end;
   end;
end;

function ShouldIKeepTrueFormat(var BPP: word): boolean;
begin
{
{ Choices
{    Use File Colors
{    Force 256 Colors
{    Force 16M Colors
}
   if Global_KeepTrueFormat = 0 then
      ShouldIKeepTrueFormat := True
   else
      ShouldIKeepTrueFormat := False;
   if Global_KeepTrueFormat = 1 then
      BPP := 8;
   if Global_KeepTrueFormat = 2 then
      BPP := 24;
end;




procedure ReadTGAFileHeader(var FileOk: boolean;
   var ErrorString: ShortString; var Width: word;
   var Height: word; var BitsPerPixel: smallint;
   var Compressed: boolean);
label
   ExitNow;
var
   I, W1:      word;
   DummyArray: array[1..4048] of char;
begin
{
{ Read Targa Header
}
   FastGetBytes(TGAHead, SizeOf(TGAHeader));
   if not (TGAHead.ImageType in [1, 2, 4, 9, 10, 11]) then
   begin
      ErrorString := 'Invalid TGA file!';
      FileOk      := False;
      goto ExitNow;
   end;
   if not (TGAHead.Bits in [1, 4, 8, 16, 24, 32]) then
   begin
      ErrorString := 'Invalid TGA file!';
      FileOk      := False;
      goto ExitNow;
   end;
   Width  := TGAHead.Width;
   Height := TGAHead.Height;
   BitsPerPixel := TGAHead.Bits;
   FastGetBytes(DummyArray, TGAHead.IdentSize);
{
{ Read in colormap
}
   for I := 0 to 255 do
   begin
      PaletteVGA[I, 1] := 0;
      PaletteVGA[I, 2] := 0;
      PaletteVGA[I, 3] := 0;
   end;
   if TGAHead.ColorMapType <> 0 then
   begin
      case TGAHead.ColorMapBits of
         24:
         begin
            for I := TGAHead.ColorMapStart to TGAHead.ColorMapStart +
               TGAHead.ColorMapLength - 1 do
            begin
               PaletteVGA[I, 3] := FastGetByte div 4;
               PaletteVGA[I, 2] := FastGetByte div 4;
               PaletteVGA[I, 1] := FastGetByte div 4;
            end;
         end;
         16:
         begin
            for I := TGAHead.ColorMapStart to TGAHead.ColorMapStart +
               TGAHead.ColorMapLength - 1 do
            begin
               W1 := FastGetWord;
               PaletteVGA[I, 3] := ((W1 shr 10) and $1F) shl 1;
               PaletteVGA[I, 2] := ((W1 shr 5) and $1F) shl 1;
               PaletteVGA[I, 1] := ((W1 shr 0) and $1F) shl 1;
            end;
         end;
      end;

   end;
   if ((BitsPerPixel = 8) and (TGAHead.ColorMapType = 0)) then
      SetUpMaskGrayPalette
   else
   begin
      if BitsPerPixel = 1 then
      begin
         PaletteVGA[0, 1] := 0;
         PaletteVGA[0, 2] := 0;
         PaletteVGA[0, 3] := 0;
         PaletteVGA[1, 1] := 63;
         PaletteVGA[1, 2] := 63;
         PaletteVGA[1, 3] := 63;
      end;
   end;
   Compressed := False;
   if TGAHead.ImageType in [9, 10, 11] then
      Compressed := True;
   ExitNow: ;
end;


procedure LoadFromFileX(FileName: string; const BitMap: TBitMap);
const
   MaskTable: array[0..7] of byte = (128, 64, 32, 16, 8, 4, 2, 1);
var
   II, NewWidth: word;
   TrueLineBytes, LineBytes: word;
   StartLine, IncLine, I: smallint;
   Ptr1: Pointer;

   procedure PixelSwapArray(var TempArrayD; Wide: word);
   var
      W, X, Y, Z: word;
      Byte1, Byte2, Byte3: byte;
   begin
{
{ Should I do 1 byte pixel or 3 byte pixels
}
      case BitMap.PixelFormat of
         pf8Bit:
         begin
            Y := Wide div 2;
            Z := Wide - 1;
            for X := 0 to Y - 1 do
            begin
               Byte1 := DataLineArray(TempArrayD)[X];
               DataLineArray(TempArrayD)[X] := DataLineArray(TempArrayD)[Z];
               DataLineArray(TempArrayD)[Z] := Byte1;
               Dec(Z);
            end;
         end;
         pf24Bit:
         begin
            Y := (Wide div 3) div 2;
            Z := Wide - 3;
            W := 0;
            for X := 0 to Y - 1 do
            begin
               Byte1 := DataLineArray(TempArrayD)[W + 0];
               Byte2 := DataLineArray(TempArrayD)[W + 1];
               Byte3 := DataLineArray(TempArrayD)[W + 2];
               DataLineArray(TempArrayD)[W + 0] := DataLineArray(TempArrayD)[Z + 0];
               DataLineArray(TempArrayD)[W + 1] := DataLineArray(TempArrayD)[Z + 1];
               DataLineArray(TempArrayD)[W + 2] := DataLineArray(TempArrayD)[Z + 2];
               DataLineArray(TempArrayD)[Z + 0] := Byte1;
               DataLineArray(TempArrayD)[Z + 1] := Byte2;
               DataLineArray(TempArrayD)[Z + 2] := Byte3;
               Z     := Z - 3;
               W     := W + 3;
            end;
         end;
      end;
   end;

   procedure TGAReverse(var TempArrayD: DataLineArray);
   begin
      if TGAHead.Descriptor and $10 <> 0 then
         PixelSwapArray(TempArrayD, TrueLineBytes);
   end;

   procedure TGAMono2Vga;
   var
      I: smallint;
   begin
      for I := 0 to Width - 1 do
      begin
         if (TempArrayD^[I] shr 3) and MaskTable[I and 7] <> 0 then
            TempArrayD2^[I] := 1
         else
            TempArrayD2^[I] := 0;
      end;
      Move(TempArrayD2^[0], TempArrayD^[0], Width);
   end;

   function Pixels2Bytes(Width: word): word;
   begin
      Pixels2Bytes := (Width + 7) div 8;
   end;

   procedure TGA16_ANY_U(var Z: word; var TempArrayD; Width: word);

      procedure Do24;
      var
         W1, I:   word;
         R, G, B: byte;
      begin
         for I := 0 to Width - 1 do
         begin
            W1 := FastGetWord;
            R  := ((W1 shr 10) and $1F) shl 3;
            G  := ((W1 shr 5) and $1F) shl 3;
            B  := ((W1 shr 0) and $1F) shl 3;
            DataLineArray(TempArrayD)[Z + 0] := B;
            DataLineArray(TempArrayD)[Z + 1] := G;
            DataLineArray(TempArrayD)[Z + 2] := R;
            Z  := Z + Global_HiColor;
         end;
      end;

      procedure Do8;
      var
         W1, I:   word;
         R, G, B: byte;
      begin
         for I := 0 to Width - 1 do
         begin
            W1 := FastGetWord;
            R  := ((W1 shr 10) and $1F) shl 3;
            G  := ((W1 shr 5) and $1F) shl 3;
            B  := ((W1 shr 0) and $1F) shl 3;
            DataLineArray(TempArrayD)[Z] := PcxGrayValue(R, G, B);
            Inc(Z);
         end;
      end;

   begin
      if MyKeepTrueFormat then
         Do24
      else
      begin
         case MyKeepTrueBits of
            8: Do8;
            24: Do24;
         end;
      end;
   end;

   procedure TGA24_ANY_U(var Z: word; Flag: byte; var TempArrayD; Width: word);
   type
      TypeRGB = packed record
         B, G, R: byte;
      end;
   var
      RGB: TypeRGB;

      procedure Do8;
      var
         I: word;
      begin
         for I := 0 to Width - 1 do
         begin
            FastGetBytes(RGB, 3);
            DataLineArray(TempArrayD)[Z] := PcxGrayValue(RGB.R, RGB.G, RGB.B);
            Inc(Z);
            if Flag = 1 then
               FastGetByte;
         end;
      end;

      procedure Do24;
      var
         I: word;
      begin
         for I := 0 to Width - 1 do
         begin
            DataLineArray(TempArrayD)[Z + 0] := FastGetByte;
            DataLineArray(TempArrayD)[Z + 1] := FastGetByte;
            DataLineArray(TempArrayD)[Z + 2] := FastGetByte;
            Z := Z + Global_HiColor;
            if Flag = 1 then
               FastGetByte;
         end;
      end;

   begin
      if (Z = 1) or (MyKeepTrueFormat = False) then
      begin
         if MyKeepTrueFormat then
            Do24
         else
         begin
            case MyKeepTrueBits of
               8: Do8;
               24: Do24;
            end;
         end;
      end
      else
      begin
   {
   { Z=0 AND keep=true
   }
         FastGetBytes(DataLineArray(TempArrayD)[Z], Width * Global_HiColor);
         Z := Z + Global_HiColor * Width;
      end;
   end;


   procedure ReadTGALine;
   var
      N, Size, LineSize: smallint;
      W1, Z: word;
      R, G, B, B1: byte;

      procedure Do8;
      var
         I: word;
      begin
         for I := 0 to Size - 1 do
         begin
            TempArrayD^[Z] := PcxGrayValue(R, G, B);
            Inc(Z);
         end;
      end;

      procedure Do8Raw;
      begin
         FastGetBytes(TempArrayD^[0], Width);
      end;

      procedure Do8RawPart;
      begin
         FastGetBytes(TempArrayD^[Z], Size);
         Z := Z + Size;
      end;

      procedure Do8Fill(B1: byte);
      begin
         FillerUp(TempArrayD^[Z], Size, B1);
         Z := Z + Size;
      end;

      procedure Do24Raw;
      var
         I, Z: word;
      begin
         Z := 0;
         for I := 0 to Width - 1 do
         begin
            B1 := FastGetByte;
            TempArrayD^[Z + 0] := PaletteVGA[B1, 3] * 4 + 3;
            TempArrayD^[Z + 1] := PaletteVGA[B1, 2] * 4 + 3;
            TempArrayD^[Z + 2] := PaletteVGA[B1, 1] * 4 + 3;
            Z  := Z + Global_HiColor;
         end;
      end;

      procedure Do24RawPart;
      var
         I: word;
      begin
         for I := 0 to Size - 1 do
         begin
            B1 := FastGetByte;
            TempArrayD^[Z + 0] := PaletteVGA[B1, 3] * 4 + 3;
            TempArrayD^[Z + 1] := PaletteVGA[B1, 2] * 4 + 3;
            TempArrayD^[Z + 2] := PaletteVGA[B1, 1] * 4 + 3;
            Z  := Z + Global_HiColor;
         end;
      end;

      procedure Do24Fill(B1: byte);
      var
         I: word;
         R, G, B: byte;
      begin
         R := PaletteVGA[B1, 1] * 4 + 3;
         G := PaletteVGA[B1, 2] * 4 + 3;
         B := PaletteVGA[B1, 3] * 4 + 3;
         for I := 0 to Size - 1 do
         begin
            TempArrayD^[Z + 0] := B;
            TempArrayD^[Z + 1] := G;
            TempArrayD^[Z + 2] := R;
            Z := Z + Global_HiColor;
         end;
      end;

      procedure Do24;
      var
         I: word;
      begin
         for I := 0 to Size - 1 do
         begin
            TempArrayD^[Z + 0] := B;
            TempArrayD^[Z + 1] := G;
            TempArrayD^[Z + 2] := R;
            Z := Z + Global_HiColor;
         end;
      end;

   begin
      N := 0;
      if BitsPerPixel = 1 then
         LineSize := Pixels2Bytes(Width)
      else
         LineSize := Width;
{
{ Uncompressed Lines
}
      if TGAHead.ImageType in [1, 2, 3] then
      begin
         case BitsPerPixel of
            1: FastGetBytes(TempArrayD^[0], LineBytes);
            8:
            begin
               if MyKeepTrueFormat then
                  Do8Raw
               else
               begin
                  case MyKeepTrueBits of
                     8: Do8Raw;
                     24: Do24Raw;
                  end;
               end;
            end;
            16:
            begin
               Z := 0;
               TGA16_ANY_U(Z, TempArrayD^[0], Width);
            end;
            24:
            begin
               Z := 0;
               TGA24_ANY_U(Z, 0, TempArrayD^[0], Width);
            end;
            32:
            begin
               Z := 0;
               TGA24_ANY_U(Z, 1, TempArrayD^[0], Width);
            end;
         end;
      end
      else
{
{ Compressed Lines
}
      begin
         Z := 0;
         repeat
            B1   := FastGetByte;
            Size := (B1 and $7F) + 1;
            N    := N + Size;
            if (B1 and $80) <> 0 then
            begin
               case BitsPerPixel of
                  1,
                  8:
                  begin
                     B1 := FastGetByte;
                     if MyKeepTrueFormat then
                        Do8Fill(B1)
                     else
                     begin
                        case MyKeepTrueBits of
                           8: Do8Fill(B1);
                           24: Do24Fill(B1);
                        end;
                     end;
                  end;
                  16:
                  begin
                     W1 := FastGetWord;
                     R  := ((W1 shr 10) and $1F) shl 3;
                     G  := ((W1 shr 5) and $1F) shl 3;
                     B  := ((W1 shr 0) and $1F) shl 3;
                     if MyKeepTrueFormat then
                        Do24
                     else
                     begin
                        case MyKeepTrueBits of
                           8: Do8;
                           24: Do24;
                        end;
                     end;
                  end;
                  24, 32:
                  begin
                     B := FastGetByte;
                     G := FastGetByte;
                     R := FastGetByte;
                     if BitsPerPixel = 32 then
                        B1 := FastGetByte;
                     if MyKeepTrueFormat then
                        Do24
                     else
                     begin
                        case MyKeepTrueBits of
                           8: Do8;
                           24: Do24;
                        end;
                     end;
                  end;
               end;
            end
            else
{
{ Single bytes
}
            begin
               case BitsPerPixel of
                  1,
                  8:
                  begin
                     if MyKeepTrueFormat then
                        Do8RawPart
                     else
                     begin
                        case MyKeepTrueBits of
                           8: Do8RawPart;
                           24: Do24RawPart;
                        end;
                     end;
                  end;
                  16:
                  begin
                     TGA16_ANY_U(Z, TempArrayD^[0], Size);
                  end;
                  24:
                  begin
                     TGA24_ANY_U(Z, 0, TempArrayD^[0], Size);
                  end;
                  32:
                  begin
                     TGA24_ANY_U(Z, 1, TempArrayD^[0], Size);
                  end;
               end;
            end;
         until N >= LineSize;
      end;
   end;

begin
{
{ Read Targa File
}
   MyKeepTrueFormat := ShouldIKeepTrueFormat(MyKeepTrueBits);
   ErrorString := '';
   FileOk := True;
   OpenFile(FileName, FileOk);
   ReadTgaFileHeader(FileOK, ErrorString, Width, Height, BitsPerPixel, Compressed);
   if FileOk then
   begin
      BitMap.Height := Height;
      BitMap.Width  := Width;
      case BitsPerPixel of
         1:
         begin
            BitMap.PixelFormat := pf1bit;
            MakePalBW(BitMap);
         end;
         8:
         begin
            BitMap.PixelFormat := pf8bit;
            MakePalPalette(BitMap);
         end;
         16:
         begin
            BitMap.PixelFormat := pf24bit;
         end;
         24:
         begin
            BitMap.PixelFormat := pf24bit;
         end;
         32:
         begin
            BitMap.PixelFormat := pf24bit;
         end;
      end;
      case BitsPerPixel of
         1, 8:
         begin
            if MyKeepTrueFormat then
            begin
            end
            else
            begin
               case MyKeepTrueBits of
                  8:
                  begin
                     BitMap.PixelFormat := pf8bit;
                  end;
                  24:
                  begin
                     BitMap.PixelFormat := pf24bit;
                     if BitsPerPixel <> 8 then
                        MakeGenPalette;
                  end;
               end;
               MakePalPalette(BitMap);
            end;
         end;
         16, 24, 32:
         begin
            if MyKeepTrueFormat then
               MakeGenPalette
            else
            begin
               case MyKeepTrueBits of
                  8:
                  begin
                     BitMap.PixelFormat := pf8bit;
                     SetUpMaskGrayPalette;
                  end;
                  24: MakeGenPalette;
               end;
            end;
            MakePalPalette(BitMap);
         end;
      end;

      NewWidth := Width * Global_HiColor;
      GetMem(TempArrayD, NewWidth);
      GetMem(TempArrayD2, NewWidth);
      if BitsPerPixel = 1 then
         LineBytes := Pixels2Bytes(Width)
      else
      begin
         if BitsPerPixel = 8 then
            LineBytes := Width
         else
            LineBytes := Width * 3;
      end;
      if MyKeepTrueFormat = True then
         TrueLineBytes := LineBytes
      else
      begin
         case MyKeepTrueBits of
            8: TrueLineBytes  := Width;
            24: TrueLineBytes := Width * Global_HiColor;
         end;
      end;
      if TGAHead.Descriptor and $20 = 0 then
      begin
         StartLine := Height - 1;
         IncLine   := -1;
      end
      else
      begin
         StartLine := 0;
         IncLine   := 1;
      end;
      I  := StartLine;
      II := 0;

      if TGAHead.ImageType in [1, 2, 3, 9, 10, 11] then
      begin
         repeat
            begin
               ReadTGALine;
               case BitsPerPixel of
                  1: TGAMono2Vga;
               end;
               TGAReverse(TempArrayD^);
               Ptr1 := BitMap.ScanLine[I];
    {
    { Copy the data
    }
               Move(TempArrayD^, Ptr1^, TrueLineBytes);
            end;
            Inc(II);
            I := I + IncLine;
         until II >= Height;
      end;
      FreeMem(TempArrayD, NewWidth);
      FreeMem(TempArrayD2, NewWidth);
   end
   else
   begin
      BitMap.Width  := 1;
      BitMap.Height := 1;
      BitsPerPixel  := 8;
   end;
   if IoResult <> 0 then
   ;
   Close(PictureFile);
   if IoResult <> 0 then
   ;
end;

procedure SaveToFileX(FileName: string; const BitMap: TBitMap; MyPcxType: byte);
label
   ErrExitClose;
var
   ResultStatus: boolean;
   File1:    file;
   TGAHead:  TGAHeader;
   MyWidth:  word;
   MyHeight: word;
   CurrBitsPerPixel: word;
   NewLine:  ^DataLineArray;

   procedure TGAWrite256Palette;
   var
      X, Y: word;
      B1:   byte;
   begin
      for X := 0 to 255 do
      begin
         for Y := 3 downto 1 do
         begin
            B1 := (PaletteVga[X, Y] * 255) div 63;
            BlockWrite(File1, B1, 1);
         end;
      end;
   end;

const
   TGADescriptor: string[60] = 'TurboView(GIF-REED) produced this TARGA file!' + Chr($1A);

   procedure TGAWriteHeader;
   begin
      TGAHead.IdentSize := Length(TGADescriptor);
      if MyPcxType = 1 then
      begin
         TGAHead.ColorMapType   := 1;
         TGAHead.ImageType      := 1;
         TGAHead.ColorMapStart  := 0;
         TGAHead.ColorMapLength := 256;
         TGAHead.ColorMapBits   := 24;
      end
      else
      begin
         TGAHead.ColorMapType   := 0;
         TGAHead.ImageType      := 2;
         TGAHead.ColorMapStart  := 0;
         TGAHead.ColorMapLength := 0;
         TGAHead.ColorMapBits   := 24;
      end;
      TGAHead.XStart := 0;
      TGAHead.YStart := 0;
      TGAHead.Width  := MyWidth;
      TGAHead.Height := MyHeight;
      case MyPcxType of
         1: TGAHead.Bits := 8;
         2: TGAHead.Bits := 24;
      end;
      TGAHead.Descriptor := $20;
      BlockWrite(File1, TGAHead, SizeOf(TGAHead));
      BlockWrite(File1, TGADescriptor[1], Length(TGADescriptor));
      if TGAHead.ColorMapType = 1 then
         TGAWrite256Palette;
   end;

   procedure TGAWriteBody(var ResultStatus: boolean);
   var
      Width_24: word;
      I: word;
   begin
      Width_24 := MyWidth * 3;
      I := 0;
      ResultStatus := True;
      repeat
         begin
            TempArrayD := BitMap.ScanLine[I];
            case MyPcxType of
               1:
               begin
                  case CurrBitsPerPixel of
                     1: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 1, 8, MyWidth);
                     4: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 4, 8, MyWidth);
                     8: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 8, 8, MyWidth);
                  end;
                  BlockWrite(File1, TempArrayDBIG^[0], MyWidth);
               end;
               2:
               begin
                  case CurrBitsPerPixel of
                     1: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 1, 24, MyWidth);
                     4: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 4, 24, MyWidth);
                     8: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 8, 24, MyWidth);
                     24: ConvertXBitsToYBits(TempArrayD^, TempArrayDBIG^, 24, 24, MyWidth);
                  end;
                  BlockWrite(File1, TempArrayDBIG^[0], Width_24);
               end;
            end;
            Inc(I);
         end;
      until (I >= MyHeight) or (ResultStatus = False);
   end;

begin
{
{ Write TARGA files.
}
   SaveThePalette(BitMap.Palette, PaletteVGA);
   MyWidth  := BitMap.Width;
   MyHeight := BitMap.Height;
   case BitMap.PixelFormat of
      pf1bit: CurrBitsPerPixel  := 1;
      pf4bit: CurrBitsPerPixel  := 4;
      pf8bit: CurrBitsPerPixel  := 8;
      pf24bit: CurrBitsPerPixel := 24;
   end;
   GetMem(NewLine, MyWidth * 4);
   GetMem(TempArrayDBig, MyWidth * 4);
   Assign(File1, FileName);
   ReWrite(File1, 1);
   TGAWriteHeader;
   TGAWriteBody(ResultStatus);
   if ResultStatus = False then
   begin
      goto ErrExitClose;
   end;
   ErrExitClose: ;
   Close(File1);
   FreeMem(TempArrayDBig, MyWidth * 4);
   FreeMem(NewLine, MyWidth * 4);
end;

end.
