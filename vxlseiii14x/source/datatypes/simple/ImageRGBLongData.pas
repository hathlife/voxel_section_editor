unit ImageRGBLongData;

interface

uses Windows, Graphics, BasicDataTypes, Abstract2DImageData, RGBLongDataSet, dglOpenGL;

type
   T2DImageRGBLongData = class (TAbstract2DImageData)
      private
         FDefaultColor: TPixelRGBLongData;
         // Gets
         function GetData(_x, _y, _c: integer):longword;
         function GetDefaultColor:TPixelRGBLongData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: longword);
         procedure SetDefaultColor(_value: TPixelRGBLongData);
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
         property Data[_x,_y,_c:integer]:longword read GetData write SetData; default;
         property DefaultColor:TPixelRGBLongData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBLongData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FData := TRGBLongDataSet.Create;
end;

// Gets
function T2DImageRGBLongData.GetData(_x, _y, _c: integer):longword;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBLongDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBLongDataSet).Green[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBLongDataSet).Blue[(_y * FXSize) + _x];
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

function T2DImageRGBLongData.GetDefaultColor:TPixelRGBLongData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBLongData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBLongDataSet).Blue[_Position],(FData as TRGBLongDataSet).Green[_Position],(FData as TRGBLongDataSet).Red[_Position]);
end;

function T2DImageRGBLongData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBLongDataSet).Red[_Position] and $FF;
end;

function T2DImageRGBLongData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBLongDataSet).Green[_Position] and $FF;
end;

function T2DImageRGBLongData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBLongDataSet).Blue[_Position] and $FF;
end;

function T2DImageRGBLongData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T2DImageRGBLongData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBLongDataSet).Red[(_y * FXSize) + _x];
end;

function T2DImageRGBLongData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBLongDataSet).Green[(_y * FXSize) + _x];
end;

function T2DImageRGBLongData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBLongDataSet).Blue[(_y * FXSize) + _x];
end;

function T2DImageRGBLongData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageRGBLongData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T2DImageRGBLongData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBLongDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBLongDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBLongDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBLongData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBLongDataSet).Red[_Position] := _r;
   (FData as TRGBLongDataSet).Green[_Position] := _g;
   (FData as TRGBLongDataSet).Blue[_Position] := _b;
end;

procedure T2DImageRGBLongData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBLongDataSet).Red[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBLongData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBLongDataSet).Green[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBLongData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBLongDataSet).Blue[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBLongData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // do nothing
end;

procedure T2DImageRGBLongData.SetData(_x, _y, _c: integer; _value: longword);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBLongDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBLongDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBLongDataSet).Blue[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBLongData.SetDefaultColor(_value: TPixelRGBLongData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
end;

// Copies
procedure T2DImageRGBLongData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBLongData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBLongData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBLongData).FDefaultColor.b;
end;

// Misc
procedure T2DImageRGBLongData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBLongDataSet).Red[x] := Round((FData as TRGBLongDataSet).Red[x] * _Value);
      (FData as TRGBLongDataSet).Green[x] := Round((FData as TRGBLongDataSet).Green[x] * _Value);
      (FData as TRGBLongDataSet).Blue[x] := Round((FData as TRGBLongDataSet).Blue[x] * _Value);
   end;
end;

procedure T2DImageRGBLongData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBLongDataSet).Red[x] := 255 - (FData as TRGBLongDataSet).Red[x];
      (FData as TRGBLongDataSet).Green[x] := 255 - (FData as TRGBLongDataSet).Green[x];
      (FData as TRGBLongDataSet).Blue[x] := 255 - (FData as TRGBLongDataSet).Blue[x];
   end;
end;

end.
