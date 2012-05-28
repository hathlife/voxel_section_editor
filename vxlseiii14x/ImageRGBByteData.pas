unit ImageRGBByteData;

interface

uses Windows, Graphics, BasicDataTypes, Abstract2DImageData, RGBByteDataSet, dglOpenGL;

type
   T2DImageRGBByteData = class (TAbstract2DImageData)
      private
         FDefaultColor: TPixelRGBByteData;
         // Gets
         function GetData(_x, _y, _c: integer):byte;
         function GetDefaultColor:TPixelRGBByteData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: byte);
         procedure SetDefaultColor(_value: TPixelRGBByteData);
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
         procedure SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte); override;
         procedure SetRedPixelColor(_x,_y: integer; _value:single); override;
         procedure SetGreenPixelColor(_x,_y: integer; _value:single); override;
         procedure SetBluePixelColor(_x,_y: integer; _value:single); override;
         procedure SetAlphaPixelColor(_x,_y: integer; _value:single); override;
      public
         // Gets
         function GetOpenGLFormat:TGLInt; override;
         // copies
         procedure Assign(const _Source: TAbstract2DImageData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         // properties
         property Data[_x,_y,_c:integer]:byte read GetData write SetData; default;
         property DefaultColor:TPixelRGBByteData read GetDefaultColor write SetDefaultColor;
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

function T2DImageRGBByteData.GetDefaultColor:TPixelRGBByteData;
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

function T2DImageRGBByteData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBByteDataSet).Red[(_y * FXSize) + _x];
end;

function T2DImageRGBByteData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBByteDataSet).Green[(_y * FXSize) + _x];
end;

function T2DImageRGBByteData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBByteDataSet).Blue[(_y * FXSize) + _x];
end;

function T2DImageRGBByteData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageRGBByteData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;



// Sets
procedure T2DImageRGBByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBByteDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBByteDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBByteDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBByteData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBByteDataSet).Red[_Position] := _r;
   (FData as TRGBByteDataSet).Green[_Position] := _g;
   (FData as TRGBByteDataSet).Blue[_Position] := _b;
end;

procedure T2DImageRGBByteData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBByteDataSet).Red[(_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T2DImageRGBByteData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBByteDataSet).Green[(_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T2DImageRGBByteData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBByteDataSet).Blue[(_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T2DImageRGBByteData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // do nothing
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

procedure T2DImageRGBByteData.SetDefaultColor(_value: TPixelRGBByteData);
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

// Misc
procedure T2DImageRGBByteData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBByteDataSet).Red[x] := Round((FData as TRGBByteDataSet).Red[x] * _Value);
      (FData as TRGBByteDataSet).Green[x] := Round((FData as TRGBByteDataSet).Green[x] * _Value);
      (FData as TRGBByteDataSet).Blue[x] := Round((FData as TRGBByteDataSet).Blue[x] * _Value);
   end;
end;

procedure T2DImageRGBByteData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBByteDataSet).Red[x] := 255 - (FData as TRGBByteDataSet).Red[x];
      (FData as TRGBByteDataSet).Green[x] := 255 - (FData as TRGBByteDataSet).Green[x];
      (FData as TRGBByteDataSet).Blue[x] := 255 - (FData as TRGBByteDataSet).Blue[x];
   end;
end;

end.
