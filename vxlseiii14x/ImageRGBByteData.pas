unit ImageRGBByteData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBByteDataSet;

type
   TImagePixelRGBByteData = record
      r,g,b: byte;
   end;

   T2DImageRGBByteData = class (TAbstract2DImageData)
      private
         FDefaultColor: TImagePixelRGBByteData;
         // Gets
         function GetData(_x, _y, _c: integer):byte;
         function GetDefaultColor:TImagePixelRGBByteData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: byte);
         procedure SetDefaultColor(_value: TImagePixelRGBByteData);
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
         // properties
         property Data[_x,_y,_c:integer]:byte read GetData write SetData; default;
         property DefaultColor:TImagePixelRGBByteData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBByteData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FData := TRGBByteDataSet.Create;
end;

// Gets
function T2DImageRGBByteData.GetData(_x, _y, _c: integer):byte;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBByteDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBByteDataSet).Green[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBByteDataSet).Blue[(_y * FXSize) + _x];
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

function T2DImageRGBByteData.GetDefaultColor:TImagePixelRGBByteData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBByteDataSet).Red[_Position],(FData as TRGBByteDataSet).Green[_Position],(FData as TRGBByteDataSet).Blue[_Position]);
end;

function T2DImageRGBByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBByteDataSet).Red[_Position];
end;

function T2DImageRGBByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBByteDataSet).Green[_Position];
end;

function T2DImageRGBByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBByteDataSet).Blue[_Position];
end;

function T2DImageRGBByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;



// Sets
procedure T2DImageRGBByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBByteDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBByteDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBByteDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBByteData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TRGBByteDataSet).Red[_Position] := _r;
   (FData as TRGBByteDataSet).Green[_Position] := _g;
   (FData as TRGBByteDataSet).Blue[_Position] := _b;
end;

procedure T2DImageRGBByteData.SetData(_x, _y, _c: integer; _value: byte);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBByteDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBByteDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBByteDataSet).Blue[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBByteData.SetDefaultColor(_value: TImagePixelRGBByteData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
end;

// Copies
procedure T2DImageRGBByteData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBByteData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBByteData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBByteData).FDefaultColor.b;
end;

end.
