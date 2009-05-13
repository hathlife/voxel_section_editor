// PALETTE.PAS 2.0
// By Banshee
// Built from Stucuk's PALETTE.PAS.

unit Palette;

interface

uses Graphics, Windows, SysUtils, math, BasicDataTypes;

const
	TRANSPARENT = 0;
   C_MAX_BITS = 32; // works for both 24 and 32 bits.
type
   TRGB = record
      r,g,b,a : byte;
   end;

   TPalette = class
   private
      NumBits : byte;
      FPalette : array of TColor;
      function ReadColour(_id : longword): TColor;
      procedure SetColour(_id : longword; _colour : TColor);
      function ReadRGB(_id : longword): TRGB;
      procedure SetRGB(_id : longword; _colour : TRGB);
      function ReadGL(_id : longword): TVector3f;
      procedure SetGL(_id: longword; _colour: TVector3f);
      function ReadGL4(_id : longword): TVector4f;
      procedure SetGL4(_id: longword; _colour: TVector4f);
   public
      // Constructors
      constructor Create; overload;
      procedure Initialize;
      constructor Create(const _Filename : string); overload;
      constructor Create(const _Palette : TPalette); overload;
      destructor Destroy; override;

      // Input and Output
      function LoadPalette(_Filename : string): boolean;
      procedure NewPalette(_NumBits : longword);

      // Gets
      function GetColourFromPalette(_colour : TColor): longword;

      // Copies
      procedure Assign(const _Palette : TPalette);

      // Misc
      procedure PaletteGradient(_StartNum,_EndNum :longword; _StartColour,_EndColour : TColor);
      procedure ChangeRemappable (_Colour : TColor);

      // Properties
      property Colour[_id : longword] : TColor read ReadColour write SetColour; default;
      property ColourRGB[_id: longword] : TRGB read ReadRGB write SetRGB;
      property ColourGL[_id: longword] : TVector3f read ReadGL write SetGL;
      property ColourGL4[_id: longword] : TVector4f read ReadGL4 write SetGL4;
   end;
   PPalette = ^TPalette;

implementation

uses Dialogs;

// Constructors
constructor TPalette.Create;
begin
   Initialize;
end;

constructor TPalette.Create(const _Filename: string);
begin
   if not LoadPalette(_Filename) then
   begin
      Initialize;
   end;
end;

constructor TPalette.Create(const _Palette : TPalette);
begin
   Assign(_Palette);
end;

procedure TPalette.Initialize;
begin
   NumBits := C_MAX_BITS;
   SetLength(FPalette,0);
end;

destructor TPalette.Destroy;
begin
   SetLength(FPalette,0);
   inherited Destroy;
end;

// Input and Output
function TPalette.LoadPalette(_Filename: string): boolean;
var
   Palette_f : array [0..255] of record
      red,green,blue:byte;
   end;
   x: Integer;
   F : file;
   JASCFile : System.Text;
   signature,binaryvalue:string[10];
   colours : Integer;
   R,G,B : byte;
begin
   Result := false;
   if FileExists(_Filename) then
   begin
      try
         // open palette file
         AssignFile(F,_Filename);
         // VK set good file mode for file
         // This allow to run program from write-protected media
         FileMode := fmOpenRead;
         Reset(F,1); // file of byte

         if FileSize(F) = 768 then
         begin
            BlockRead(F,Palette_f,sizeof(Palette_f));
            CloseFile(F);

            NumBits := 8;
            SetLength(FPalette,256);
            for x := 0 to 255 do
               FPalette[x] := RGB(Palette_f[x].red*4,Palette_f[x].green*4,Palette_f[x].blue*4);
            Result := true;
         end
         else // Try JASC
         begin
            CloseFile(F);
            AssignFile(JASCFile,_Filename);
            FileMode := fmOpenRead;
            Reset(JASCFile); // file of byte
            {Jasc format validation}
            readln(JASCFile,signature); {JASC-PAL}
            readln(JASCFile,binaryvalue); {0100}
            readln(JASCFile,colours); {256 (number of colours)}

            if (signature <> 'JASC-PAL') then
               MessageBox(0,'Error: JASC Signature Incorrect','Load Palette Error',0)
            else if ((binaryvalue <> '0100') or (colours <> 256)) then
               MessageBox(0,'Error: Palette Must Be 8Bit(256 Colours)','Load Palette Error',0)
            else
            Begin
               {Now, convert colour per colour}
               SetLength(FPalette, 256);
               NumBits := 8;
               for x:=0 to 255 do
               begin
                  {read source info}
                  readln(JASCFile,R,G,B);

                  {Note: No colour conversion needed since JASC-PAL colours are the same as VXLPalette ones}
                  Palette_f[x].red := r;
                  Palette_f[x].green := g;
                  Palette_f[x].blue := b;

                  FPalette[x] := RGB(Palette_f[x].red,Palette_f[x].green,Palette_f[x].blue);
               end;
               Result := true;
            end;
            CloseFile(JASCFile);
         end;
      except on E : EInOutError do
         MessageDlg('Error: ' + E.Message + Char($0A) + _Filename, mtError, [mbOK], 0);
      end;
   end;
end;

procedure TPalette.NewPalette(_NumBits : longword);
var
   x : longword;
   Size : single;
   Interval : real;
begin
   // First, we unload the existing palette.
   SetLength(FPalette,0);
   NumBits := _NumBits;
   if _NumBits = 8 then
   begin
      SetLength(FPalette,256);
      for x := 0 to 255 do
         FPalette[x] := RGB(255-x,255-x,255-x);
   end
   else if _NumBits <> C_MAX_BITS then
   begin
      Size := Power(2,_NumBits);
      SetLength(FPalette,Round(Size));
      Interval := 16777215 / Size;
      for x := Low(FPalette) to High(FPalette) do
      begin
         FPalette[x] := Round(x * Interval) and $00FFFFFF;
      end;
   end;
end;


// Gets
function TPalette.ReadColour(_id: Cardinal): TColor;
begin
   if NumBits = C_MAX_BITS then
   begin
      Result := _id;
   end
   else if NumBits = 8 then
   begin
      if (_id < 256) then
         Result := FPalette[_id]
      else
         Result := FPalette[0];
   end
   else
      Result := _id;
end;

function TPalette.ReadRGB(_id : longword): TRGB;
begin
   if NumBits = C_MAX_BITS then
   begin
      Result.r := Byte(_id);
      Result.g := Byte(_id shr 8);
      Result.b := Byte(_id shr 16);
      Result.a := Byte(_id shr 24);
   end
   else if NumBits = 8 then
   begin
      if (_id < 256) then
      begin
         Result.r := Byte(FPalette[_id]);
         Result.g := Byte(FPalette[_id] shr 8);
         Result.b := Byte(FPalette[_id] shr 16);
         Result.a := Byte(FPalette[_id] shr 24);
      end
      else
      begin
         Result.r := Byte(FPalette[0]);
         Result.g := Byte(FPalette[0] shr 8);
         Result.b := Byte(FPalette[0] shr 16);
         Result.a := Byte(FPalette[0] shr 24);
      end;
   end
   else
   begin
      Result.r := Byte(_id);
      Result.g := Byte(_id shr 8);
      Result.b := Byte(_id shr 16);
      Result.a := Byte(_id shr 24);
   end;
end;

function TPalette.ReadGL(_id : longword): TVector3f;
begin
   if NumBits = C_MAX_BITS then
   begin
      Result.X := Byte(_id and $FF) / 255;
      Result.Y := Byte((_id shr 8) and $FF) / 255;
      Result.Z := Byte((_id shr 16) and $FF) / 255;
   end
   else if NumBits = 8 then
   begin
      if (_id < 256) then
      begin
         Result.X := Byte(FPalette[_id] and $FF) / 255;
         Result.Y := Byte((FPalette[_id] shr 8) and $FF) / 255;
         Result.Z := Byte((FPalette[_id] shr 16) and $FF) / 255;
      end
      else
      begin
         Result.X := Byte(FPalette[0] and $FF) / 255;
         Result.Y := Byte((FPalette[0] shr 8) and $FF) / 255;
         Result.Z := Byte((FPalette[0] shr 16) and $FF) / 255;
      end;
   end
   else
   begin
      Result.X := Byte(_id and $FF) / 255;
      Result.Y := Byte((_id shr 8) and $FF) / 255;
      Result.Z := Byte((_id shr 16) and $FF) / 255;
   end;
end;

function TPalette.ReadGL4(_id : longword): TVector4f;
begin
   if NumBits = C_MAX_BITS then
   begin
      Result.X := Byte(_id and $FF) / 255;
      Result.Y := Byte((_id shr 8) and $FF) / 255;
      Result.Z := Byte((_id shr 16) and $FF) / 255;
      Result.W := Byte(_id shr 24) / 255;
   end
   else if NumBits = 8 then
   begin
      if (_id < 256) then
      begin
         Result.X := Byte(FPalette[_id] and $FF) / 255;
         Result.Y := Byte((FPalette[_id] shr 8) and $FF) / 255;
         Result.Z := Byte((FPalette[_id] shr 16) and $FF) / 255;
         Result.W := Byte(FPalette[_id] shr 24) / 255;
      end
      else
      begin
         Result.X := Byte(FPalette[0] and $FF) / 255;
         Result.Y := Byte((FPalette[0] shr 8) and $FF) / 255;
         Result.Z := Byte((FPalette[0] shr 16) and $FF) / 255;
         Result.W := Byte(FPalette[0] shr 24) / 255;
      end;
   end
   else
   begin
      Result.X := Byte(_id and $FF) / 255;
      Result.Y := Byte((_id shr 8) and $FF) / 255;
      Result.Z := Byte((_id shr 16) and $FF) / 255;
      Result.W := Byte(_id shr 24) / 255;
   end;
end;


function TPalette.GetColourFromPalette(_colour : TColor): longword;
var
   colour : integer;
   r,g,b,rx,gx,bx : byte; // (r,g,b) of the original colour and (rx,gx,bx) current
   diff,min_diff : real; // Current difference and Minimum difference
   x : longword;
   // The colour structure related ones.
   rs,gs,bs,rxs,bxs,gxs : real;
   diffs,min_diffs : real;
   top : byte;
begin
   if High(FPalette) >= 0 then
   begin
      // Get the original colours.
      r := GetRValue(_Colour);
      g := GetGValue(_Colour);
      b := GetBValue(_Colour);

      // Reset min_diff and colour
      min_diff := 9999999;
      min_diffs := 999999;
      colour := 0;

      // Prepare the colour structure part.
      top := max(r,max(g,b));
      if top <> 0 then
      begin
         rs := r / top;
         gs := g / top;
         bs := b / top;
      end
      else
      begin
         rs := 1;
         gs := 1;
         bs := 1;
      end;


      for x := Low(FPalette) to High(FPalette) do
      begin
         rx := GetRValue(FPalette[x]);
         gx := GetGValue(FPalette[x]);
         bx := GetBValue(FPalette[x]);

         if (r = rx) and (g = gx) and (b = bx) then
         begin
            Result := x;
            exit;
         end;

         diff := sqrt(((r - rx) * (r - rx)) + ((g - gx) * (g - gx)) + ((b - bx) * (b - bx)));
         if diff < min_diff then
         begin
            colour := x;
            min_diff := diff;
            // Setup colour structure comparison.
            top := max(rx,max(gx,bx));
            if top <> 0 then
            begin
               rxs := rx / top;
               gxs := gx / top;
               bxs := bx / top;
            end
            else
            begin
               rxs := 1;
               gxs := 1;
               bxs := 1;
            end;
            min_diffs := sqrt(((rs - rxs) * (rs - rxs)) + ((gs - gxs) * (gs - gxs)) + ((bs - bxs) * (bs - bxs)));
         end
         else if diff = min_diff then
         begin
            // Now, here comes the challenge, based on Structuralis algorithm
            // from OS SHP Builder
            top := max(rx,max(gx,bx));
            if top <> 0 then
            begin
               rxs := rx / top;
               gxs := gx / top;
               bxs := bx / top;
            end
            else
            begin
               rxs := 1;
               gxs := 1;
               bxs := 1;
            end;
            diffs := sqrt(((rs - rxs) * (rs - rxs)) + ((gs - gxs) * (gs - gxs)) + ((bs - bxs) * (bs - bxs)));
            if diffs < min_diffs then
            begin
               min_diffs := diffs;
               colour := x;
            end;
         end;
      end;
      Result := colour;
   end
   else
   begin
      Result := _colour;
   end
end;


// Sets
procedure TPalette.SetColour(_id: longword; _colour: TColor);
begin
   if NumBits <> C_MAX_BITS then
   begin
      if (_id <= High(FPalette)) then
      begin
         FPalette[_id] := _colour;
      end;
   end;
end;

procedure TPalette.SetRGB(_id: longword; _colour: TRGB);
begin
   if NumBits <> C_MAX_BITS then
   begin
      if (_id <= High(FPalette)) then
      begin
         FPalette[_id] := (_colour.r or (_colour.g shl 8) or (_colour.b shl 16) or (_colour.a shl 24));
      end;
   end;
end;

procedure TPalette.SetGL(_id: longword; _colour: TVector3f);
begin
   if NumBits <> C_MAX_BITS then
   begin
      if (_id <= High(FPalette)) then
      begin
         FPalette[_id] := (Round(_colour.X * 255) or (Round(_colour.Y * 255) shl 8) or (Round(_colour.Z * 255) shl 16));
      end;
   end;
end;

procedure TPalette.SetGL4(_id: longword; _colour: TVector4f);
begin
   if NumBits <> C_MAX_BITS then
   begin
      if (_id <= High(FPalette)) then
      begin
         FPalette[_id] := (Round(_colour.X * 255) or (Round(_colour.Y * 255) shl 8) or (Round(_colour.Z * 255) shl 16) or (Round(_colour.W * 255) shl 24));
      end;
   end;
end;


// Copies
procedure TPalette.Assign(const _Palette: TPalette);
var
   i : longword;
begin
   NumBits := _Palette.NumBits;
   if High(_Palette.FPalette) > 0 then
   begin
      SetLength(FPalette,High(_Palette.FPalette)+1);
      for i := Low(FPalette) to High(FPalette) do
      begin
         FPalette[i] := _Palette.FPalette[i];
      end;
   end
   else
      SetLength(FPalette,0);
end;

// Misc
procedure TPalette.PaletteGradient(_StartNum,_EndNum :longword; _StartColour,_EndColour : TColor);
var
   X,Distance : integer;
   Temp : longword;
   StepR,StepG,StepB : Real;
   R,G,B : integer;
   Rx,Gx,Bx : real;
begin
   // Let's catch the errors.

   // 24bits has no palette.
   if NumBits <> 8 then
      exit;

   // For optimization purposes, we make sure _EndNum is the highest value.
   if _StartNum > _EndNum then
   begin
      Temp := _StartNum;
      _StartNum := _EndNum;
      _EndNum := Temp;
   end;

   // Catch if it is at the palette's scope.
   if (_EndNum > High(FPalette)) then
      exit;

   Distance := _EndNum - _StartNum;
   if Distance = 0 then // Catch the Divison By 0's
   begin
      MessageBox(0,'Error: PaletteGradient Needs Start Num And '+#13+#13+'End Num To Be Different Numbers','PaletteGradient Input Error',0);
      Exit;
   end;

   // Now, we start the procedure.
   StepR := (GetRValue(_EndColour) - GetRValue(_StartColour)) / Distance;
   StepG := (GetGValue(_EndColour) - GetGValue(_StartColour)) / Distance;
   StepB := (GetBValue(_EndColour) - GetBValue(_StartColour)) / Distance;

   R := GetRValue(_StartColour);
   G := GetGValue(_StartColour);
   B := GetBValue(_StartColour);
   Rx := R;
   Bx := B;
   Gx := G;

   for x := _StartNum to _EndNum do
   begin
      if Round(Rx + StepR) < 0 then
         R := 0
      else
      begin
         R := Round(Rx + StepR);
         Rx := Rx + StepR;
      end;

      if Round(Gx + StepG) < 0 then
         G := 0
      else
      begin
         G := Round(Gx + StepG);
         Gx := Gx + StepG;
      end;

      if Round(Bx + StepB) < 0 then
         B := 0
      else
      begin
         B := Round(Bx + StepB);
         Bx := Bx + StepB;
      end;

      if R > 255 then
         R := 255;

      if G > 255 then
         G := 255;

      if B > 255 then
         B := 255;

      FPalette[x] := RGB(R,G,B);
   end;
end;

// Importing and adapting change remappable from OS SHP Builder.
procedure TPalette.ChangeRemappable (_Colour : TColor);
const
   RedMultiples : array[16..31] of byte = ($FC, $EC, $DC, $D0, $C0, $B0, $A4, $94, $84, $78, $68, $58, $4C, $3C, $2C, $20);
var
   rmult,gmult,bmult: single;
   x : byte;
begin
   if NumBits <> 8 then
      exit;
   rmult := GetRValue(_Colour) / 255;
   gmult := GetGValue(_Colour) / 255;
   bmult := GetBValue(_Colour) / 255;
   // Generate Remmapable colours
   for x := 16 to 31 do
   begin
      FPalette[x]:= RGB(Round(rmult * RedMultiples[x]),Round(gmult * RedMultiples[x]),Round(bmult * RedMultiples[x]));
   end;
end;

end.

