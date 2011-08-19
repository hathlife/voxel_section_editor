unit ImageRGBIntData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBIntDataSet;

type
   TImagePixelRGBIntData = record
      r,g,b: longword;
   end;

   T2DImageRGBIntData = class (TAbstract2DImageData)
      private
         FDefaultColor: TImagePixelRGBIntData;
         // Gets
         function GetData(_x, _y, _c: integer):longword;
         function GetDefaultColor:TImagePixelRGBIntData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: longword);
         procedure SetDefaultColor(_value: TImagePixelRGBIntData);
      protected
         // Constructors and Destructors
         procedure Initialize; override;
         // Gets
         function GetBitmapPixelColor(_Position: longword):longword; override;
         function GetRPixelColor(_Position: longword):byte; override;
         function GetGPixelColor(_Position: longword):byte; override;
         function GetBPixelColor(_Position: longword):byte; override;
         function GetAPixelColor(_Position: longword):byte; override;
         function GetRedPixelColor(_x,_y: integer):single; override;
         function GetGreenPixelColor(_x,_y: integer):single; override;
         function GetBluePixelColor(_x,_y: integer):single; override;
         function GetAlphaPixelColor(_x,_y: integer):single; override;
         // Sets
         procedure SetBitmapPixelColor(_Position, _Color: longword); override;
         procedure SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte); override;
         procedure SetRedPixelColor(_x,_y: integer; _value:single); override;
         procedure SetGreenPixelColor(_x,_y: integer; _value:single); override;
         procedure SetBluePixelColor(_x,_y: integer; _value:single); override;
         procedure SetAlphaPixelColor(_x,_y: integer; _value:single); override;
      public
         // copies
         procedure Assign(const _Source: TAbstract2DImageData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         // properties
         property Data[_x,_y,_c:integer]:longword read GetData write SetData; default;
         property DefaultColor:TImagePixelRGBIntData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBIntData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FData := TRGBIntDataSet.Create;
end;

// Gets
function T2DImageRGBIntData.GetData(_x, _y, _c: integer):longword;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBIntDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBIntDataSet).Green[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBIntDataSet).Blue[(_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      case (_c) of
         0: Result := FDefaultColor.r;
         1: Result := FDefaultColor.g;
         else
         begin
            Result := FDefaultColor.b;
         end;
      end;
   end;
end;

function T2DImageRGBIntData.GetDefaultColor:TImagePixelRGBIntData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBIntDataSet).Red[_Position],(FData as TRGBIntDataSet).Green[_Position],(FData as TRGBIntDataSet).Blue[_Position]);
end;

function T2DImageRGBIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBIntDataSet).Red[_Position] and $FF;
end;

function T2DImageRGBIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBIntDataSet).Green[_Position] and $FF;
end;

function T2DImageRGBIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBIntDataSet).Blue[_Position] and $FF;
end;

function T2DImageRGBIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T2DImageRGBIntData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBIntDataSet).Red[(_y * FXSize) + _x];
end;

function T2DImageRGBIntData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBIntDataSet).Green[(_y * FXSize) + _x];
end;

function T2DImageRGBIntData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBIntDataSet).Blue[(_y * FXSize) + _x];
end;

function T2DImageRGBIntData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;


// Sets
procedure T2DImageRGBIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBIntDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBIntDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBIntDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBIntData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TRGBIntDataSet).Red[_Position] := _r;
   (FData as TRGBIntDataSet).Green[_Position] := _g;
   (FData as TRGBIntDataSet).Blue[_Position] := _b;
end;

procedure T2DImageRGBIntData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBIntDataSet).Red[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBIntData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBIntDataSet).Green[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBIntData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBIntDataSet).Blue[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBIntData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // do nothing
end;

procedure T2DImageRGBIntData.SetData(_x, _y, _c: integer; _value: longword);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBIntDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBIntDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBIntDataSet).Blue[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBIntData.SetDefaultColor(_value: TImagePixelRGBIntData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
end;

// Copies
procedure T2DImageRGBIntData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBIntData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBIntData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBIntData).FDefaultColor.b;
end;

// Misc
procedure T2DImageRGBIntData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBIntDataSet).Red[x] := Round((FData as TRGBIntDataSet).Red[x] * _Value);
      (FData as TRGBIntDataSet).Green[x] := Round((FData as TRGBIntDataSet).Green[x] * _Value);
      (FData as TRGBIntDataSet).Blue[x] := Round((FData as TRGBIntDataSet).Blue[x] * _Value);
   end;
end;

procedure T2DImageRGBIntData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBIntDataSet).Red[x] := 255 - (FData as TRGBIntDataSet).Red[x];
      (FData as TRGBIntDataSet).Green[x] := 255 - (FData as TRGBIntDataSet).Green[x];
      (FData as TRGBIntDataSet).Blue[x] := 255 - (FData as TRGBIntDataSet).Blue[x];
   end;
end;

end.
