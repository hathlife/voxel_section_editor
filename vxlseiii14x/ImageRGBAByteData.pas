unit ImageRGBAByteData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBAByteDataSet;

type
   TImagePixelRGBAByteData = record
      r,g,b,a: byte;
   end;

   T2DImageRGBAByteData = class (TAbstract2DImageData)
      private
         FDefaultColor: TImagePixelRGBAByteData;
         // Gets
         function GetData(_x, _y, _c: integer):byte;
         function GetDefaultColor:TImagePixelRGBAByteData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: byte);
         procedure SetDefaultColor(_value: TImagePixelRGBAByteData);
      protected
         // Constructors and Destructors
         procedure Initialize; override;
         // Gets
         function GetBitmapPixelColor(_Position: longword):longword; override;
         function GetRPixelColor(_Position: longword):byte; override;
         function GetGPixelColor(_Position: longword):byte; override;
         function GetBPixelColor(_Position: longword):byte; override;
         function GetAPixelColor(_Position: longword):byte; override;
         // Sets
         procedure SetBitmapPixelColor(_Position, _Color: longword); override;
         procedure SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte); override;
      public
         // copies
         procedure Assign(const _Source: TAbstract2DImageData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         // properties
         property Data[_x,_y,_c:integer]:byte read GetData write SetData; default;
         property DefaultColor:TImagePixelRGBAByteData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBAByteData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBAByteDataSet.Create;
end;

// Gets
function T2DImageRGBAByteData.GetData(_x, _y, _c: integer):byte;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBAByteDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBAByteDataSet).Green[(_y * FXSize) + _x];
         2: Result := (FData as TRGBAByteDataSet).Blue[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBAByteDataSet).Alpha[(_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      case (_c) of
         0: Result := FDefaultColor.r;
         1: Result := FDefaultColor.g;
         2: Result := FDefaultColor.b;
         else
         begin
            Result := FDefaultColor.a;
         end;
      end;
   end;
end;

function T2DImageRGBAByteData.GetDefaultColor:TImagePixelRGBAByteData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBAByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBAByteDataSet).Red[_Position],(FData as TRGBAByteDataSet).Green[_Position],(FData as TRGBAByteDataSet).Blue[_Position]);
end;

function T2DImageRGBAByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Red[_Position];
end;

function T2DImageRGBAByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Green[_Position];
end;

function T2DImageRGBAByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Blue[_Position];
end;

function T2DImageRGBAByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Alpha[_Position];
end;



// Sets
procedure T2DImageRGBAByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBAByteDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBAByteDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBAByteDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBAByteData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TRGBAByteDataSet).Red[_Position] := _r;
   (FData as TRGBAByteDataSet).Green[_Position] := _g;
   (FData as TRGBAByteDataSet).Blue[_Position] := _b;
   (FData as TRGBAByteDataSet).Alpha[_Position] := _a;
end;

procedure T2DImageRGBAByteData.SetData(_x, _y, _c: integer; _value: byte);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBAByteDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBAByteDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBAByteDataSet).Blue[(_y * FXSize) + _x] := _value;
         3: (FData as TRGBAByteDataSet).Alpha[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBAByteData.SetDefaultColor(_value: TImagePixelRGBAByteData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T2DImageRGBAByteData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBAByteData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBAByteData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBAByteData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T2DImageRGBAByteData).FDefaultColor.a;
end;

// Misc
procedure T2DImageRGBAByteData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAByteDataSet).Red[x] := Round((FData as TRGBAByteDataSet).Red[x] * _Value);
      (FData as TRGBAByteDataSet).Green[x] := Round((FData as TRGBAByteDataSet).Green[x] * _Value);
      (FData as TRGBAByteDataSet).Blue[x] := Round((FData as TRGBAByteDataSet).Blue[x] * _Value);
      (FData as TRGBAByteDataSet).Alpha[x] := Round((FData as TRGBAByteDataSet).Alpha[x] * _Value);
   end;
end;

procedure T2DImageRGBAByteData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAByteDataSet).Red[x] := 255 - (FData as TRGBAByteDataSet).Red[x];
      (FData as TRGBAByteDataSet).Green[x] := 255 - (FData as TRGBAByteDataSet).Green[x];
      (FData as TRGBAByteDataSet).Blue[x] := 255 - (FData as TRGBAByteDataSet).Blue[x];
      (FData as TRGBAByteDataSet).Alpha[x] := 255 - (FData as TRGBAByteDataSet).Alpha[x];
   end;
end;

end.
