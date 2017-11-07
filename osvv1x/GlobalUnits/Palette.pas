// PALETTE.PAS
// By Banshee & Stucuk
// Modifyed for VXLSE III

unit Palette;

interface

uses
  Windows, Variants, Graphics,SysUtils, math;

const
   TRANSPARENT = 0;

type
   TPalette = array[0..255] of TColor;

procedure LoadPaletteFromFile(Filename : string);
procedure LoadPaletteFromFile2(Filename : string; var Palette : TPalette);
procedure SavePaletteToFile(Filename : string);
procedure GetPaletteFromFile(var Palette:TPalette; Filename : string);
Procedure CreateBlankPalette; // does a gradient effect
Procedure CreateBlankPalette_True; // Makes all 0
procedure LoadJASCPaletteFromFile(Filename : string);
procedure LoadJASCPaletteFromFile2(Filename : string; var Palette:TPalette);
procedure SavePaletteToJASCFile(Filename : string);
procedure PaletteGradient(StartNum,EndNum :byte; StartColour,EndColour : TColor);
Function LoadAPaletteFromFile(Filename:String) : integer;
Function LoadAPaletteFromFile2(Filename:String; var Palette:TPalette) : integer;
function getpalettecolour(Palette: TPalette; Colour : Tcolor) : integer;
function getsquarecolour(x,y : integer; image : tbitmap) : integer;

implementation

Uses VH_Global;

// These functions are not inline, which prevents compiling problems with the
// latest Delphi versions (2006, 2007?)
function RGB(r,g,b : integer): TColor;
begin
   Result := (r or (g shl 8) or (b shl 16));
end;

function GetRValue(rgb: TColor): Byte;
begin
   Result := Byte(rgb);
end;

function GetGValue(rgb: TColor): Byte;
begin
   Result := Byte(rgb shr 8);
end;

function GetBValue(rgb: TColor): Byte;
begin
   Result := Byte(rgb shr 16);
end;

// Loads TS/RA2 Palette into the VXLPalette
procedure LoadPaletteFromFile(Filename : string);
begin
   LoadPaletteFromFile2(filename,VXLPalette);
end;

procedure LoadPaletteFromFile2(Filename : string; var Palette : TPalette);
var
   Palette_f : array [0..255] of record
   red,green,blue:byte;
end;
   x: Integer;
   F : file;
begin
   // open palette file
   AssignFile(F,Filename);
   Reset(F,1); // file of byte

   BlockRead(F,Palette_f,sizeof(Palette_f));
   CloseFile(F);

   for x := 0 to 255 do
      Palette[x] := RGB(Palette_f[x].red*4,Palette_f[x].green*4,Palette_f[x].blue*4);
end;

// Saves TS/RA2 Palette from the VXLPalette
procedure SavePaletteToFile(Filename : string);
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
   x: Integer;
   F : file;
begin
   for x := 0 to 255 do
   begin
      Palette_f[x].red := GetRValue(VXLPalette[x]) div 4;
      Palette_f[x].green := GetGValue(VXLPalette[x]) div 4;
      Palette_f[x].blue := GetBValue(VXLPalette[x]) div 4;
   end;

   AssignFile(F,Filename);
   Rewrite(F,1);

   BlockWrite(F,Palette_f,sizeof(Palette_f));
   CloseFile(F);
end;

procedure GetPaletteFromFile(var Palette:TPalette; Filename : string);
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
   x: Integer;
   Colour : string;
   F : file;
begin
   // open palette file
   AssignFile(F,Filename);
   Reset(F,1); // file of byte

   BlockRead(F,Palette_f,sizeof(Palette_f));
   CloseFile(F);

   for x := 0 to 255 do
   begin
      Colour := '$00' + IntToHex(Palette_f[x].blue * 4,2) + IntToHex(Palette_f[x].green * 4,2) + IntToHex(Palette_f[x].red * 4,2);
      Palette[x] := StringToColor(Colour);
   end;
end;

Procedure CreateBlankPalette;
var
   x : integer;
begin
   for x := 0 to 255 do
      VXLPalette[x] := RGB(255-x,255-x,255-x);
end;

Procedure CreateBlankPalette_True;
var
   x : integer;
begin
   for x := 0 to 255 do
      VXLPalette[x] := 0;
end;

// Loads JASC 8Bit Palette into the VXLPalette
procedure LoadJASCPaletteFromFile(Filename : string);
begin
   LoadJASCPaletteFromFile2(Filename,VXLPalette);
end;

procedure LoadJASCPaletteFromFile2(Filename : string; var Palette:TPalette);
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
   signature,binaryvalue:string[10];
   x,colours : Integer;
   F : text;
   R,G,B : byte;
begin
   // open palette file
   AssignFile(F,Filename);
   Reset(F);

   {Jasc format validation}
   readln(F,signature); {JASC-PAL}
   readln(F,binaryvalue); {0100}
   readln(F,colours); {256 (number of colours)}

   if (signature <> 'JASC-PAL') then
      MessageBox(0,'Error: JASC Signature Incorrect','Load Palette Error',0)
   else if ((binaryvalue <> '0100') or (colours <> 256)) then
      MessageBox(0,'Error: Palette Must Be 8Bit(256 Colours)','Load Palette Error',0)
   else
   begin
      {Now, convert colour per colour}
      for x:=0 to 255 do
      begin
         {read source info}
         readln(F,R,G,B);

         {Note: No colour conversion needed since JASC-PAL colours are the same as VXLPalette ones}
         Palette_f[x].red := r;
         Palette_f[x].green := g;
         Palette_f[x].blue := b;

         Palette[x] := RGB(Palette_f[x].red,Palette_f[x].green,Palette_f[x].blue);
      end;
   end;
   CloseFile(F);
end;

// Saves the VXLPalette As JASC-PAL
procedure SavePaletteToJASCFile(Filename : string);
var
   signature,binaryvalue:string[10];
   x,colours : Integer;
   F : text;
begin
   AssignFile(F,Filename);
   Rewrite(F);

   signature := 'JASC-PAL';
   binaryvalue := '0100';
   colours := 256;
   writeln(F,signature); {JASC-PAL}
   writeln(F,binaryvalue); {0100}
   writeln(F,colours); {256 (number of colours)}

   for x := 0 to 255 do
      writeln(F,inttostr(GetRValue(VXLPalette[x]))+' ',inttostr(GetGValue(VXLPalette[x]))+' ',GetBValue(VXLPalette[x]));

   CloseFile(F);
end;

procedure PaletteGradient(StartNum,EndNum :byte; StartColour,EndColour : TColor);
var
   X,Distance : integer;
   StepR,StepG,StepB : Real;
   R,G,B : integer;
begin
   Distance := EndNum-StartNum;

   if Distance = 0 then // Catch the Divison By 0's
   begin
      MessageBox(0,'Error: PaletteGradient Needs Start Num And '+#13+#13+'End Num To Be Different Numbers','PaletteGradient Input Error',0);
      Exit;
   end;

   StepR := (Max(GetRValue(EndColour),GetRValue(StartColour)) - Min(GetRValue(EndColour),GetRValue(StartColour))) / Distance;
   StepG := (Max(GetGValue(EndColour),GetGValue(StartColour)) - Min(GetGValue(EndColour),GetGValue(StartColour))) / Distance;
   StepB := (Max(GetBValue(EndColour),GetBValue(StartColour)) - Min(GetBValue(EndColour),GetBValue(StartColour))) / Distance;

   if GetRValue(EndColour) < GetRValue(StartColour) then
      StepR := -StepR;

   if GetGValue(EndColour) < GetGValue(StartColour) then
      StepG := -StepG;

   if GetBValue(EndColour) < GetBValue(StartColour) then
      StepB := -StepB;

   R := GetRValue(StartColour);
   G := GetGValue(StartColour);
   B := GetBValue(StartColour);

   for x := StartNum to EndNum do
   begin
      if Round(R + StepR) < 0 then
         R := 0
      else
         R := Round(R + StepR);

      if Round(G + StepG) < 0 then
         G := 0
      else
         G := Round(G + StepG);

      if Round(B + StepB) < 0 then
         B := 0
      else
         B := Round(B + StepB);

      if R > 255 then
         R := 255;

      if G > 255 then
         G := 255;

      if B > 255 then
         B := 255;

      VXLPalette[x] := RGB(R,G,B);
   end;

end;


Function LoadAPaletteFromFile(Filename:String) : integer; // Works out which filetype it is
begin
   Result := LoadAPaletteFromFile2(Filename,VXLPalette);
end;

Function LoadAPaletteFromFile2(Filename:String; var Palette:TPalette) : integer; // Works out which filetype it is
var
   signature:string[10];
   F : text;
begin
   Result := 1; // Assume TS/RA2

   // open palette file
   AssignFile(F,Filename);
   Reset(F);

   {Jasc format validation}
   readln(F,signature); {JASC-PAL}
   CloseFile(F);

   if (signature <> 'JASC-PAL') then // If Signature is not JASC-PAL Assume its a TS/RA2 Palette
      LoadPaletteFromFile2(Filename,Palette)
   else
   begin
      Result := 2;
      LoadJASCPaletteFromFile2(Filename,Palette);
   end;
end;

function getpalettecolour(Palette: TPalette; Colour : Tcolor) : integer;
var
   p,col : integer;
   r,g,b : byte;
   value,t : single;
begin
   col := -1;

   for p := 0 to 255 do
      if Colour = Palette[p] then
         col := p;

   if col = -1 then
   begin
      t := 10000;
      col := -1;
      for p := 0 to 255 do
      begin
         r := GetRValue(ColortoRGB(Colour)) - GetRValue(ColortoRGB(Palette[p])) ;
         g := GetGValue(ColortoRGB(Colour)) - GetGValue(ColortoRGB(Palette[p])) ;
         b := GetBValue(ColortoRGB(Colour)) - GetBValue(ColortoRGB(Palette[p])) ;

         value := Sqrt(r*r + g*g + b*b);
         if value < t then
         begin
            t := value;
            col := p;
         end;
      end;

      if (col = -1) or (t = 10000) then
         col := 0;
   end;

   result := col;
end;

function getsquarecolour(x,y : integer; image : tbitmap) : integer;
begin
   Result := getpalettecolour(VXLPalette,Image.Canvas.Pixels[x,y]);
end;

end.

