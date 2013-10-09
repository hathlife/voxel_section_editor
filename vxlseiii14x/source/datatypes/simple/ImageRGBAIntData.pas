unit ImageRGBAIntData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBAIntDataSet, BasicDataTypes;

type
   T2DImageRGBAIntData = class (TAbstract2DImageData)
      private
         FDefaultColor: TPixelRGBAIntData;
         // Gets
         function GetData(_x, _y, _c: integer):integer;
         function GetDefaultColor:TPixelRGBAIntData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: integer);
         procedure SetDefaultColor(_value: TPixelRGBAIntData);
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
         // copies
         procedure Assign(const _Source: TAbstract2DImageData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         // properties
         property Data[_x,_y,_c:integer]:integer read GetData write SetData; default;
         property DefaultColor:TPixelRGBAIntData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBAIntData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBAIntDataSet.Create;
end;

// Gets
function T2DImageRGBAIntData.GetData(_x, _y, _c: integer):integer;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBAIntDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBAIntDataSet).Green[(_y * FXSize) + _x];
         2: Result := (FData as TRGBAIntDataSet).Blue[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBAIntDataSet).Alpha[(_y * FXSize) + _x];
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

function T2DImageRGBAIntData.GetDefaultColor:TPixelRGBAIntData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBAIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBAIntDataSet).Blue[_Position],(FData as TRGBAIntDataSet).Green[_Position],(FData as TRGBAIntDataSet).Red[_Position]);
end;

function T2DImageRGBAIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Red[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Green[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Blue[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Alpha[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Red[(_y * FXSize) + _x];
end;

function T2DImageRGBAIntData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Green[(_y * FXSize) + _x];
end;

function T2DImageRGBAIntData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Blue[(_y * FXSize) + _x];
end;

function T2DImageRGBAIntData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Alpha[(_y * FXSize) + _x];
end;


// Sets
procedure T2DImageRGBAIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBAIntDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBAIntDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBAIntDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBAIntData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBAIntDataSet).Red[_Position] := _r;
   (FData as TRGBAIntDataSet).Green[_Position] := _g;
   (FData as TRGBAIntDataSet).Blue[_Position] := _b;
   (FData as TRGBAIntDataSet).Alpha[_Position] := _a;
end;

procedure T2DImageRGBAIntData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Red[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBAIntData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Green[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBAIntData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Blue[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBAIntData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Alpha[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBAIntData.SetData(_x, _y, _c: integer; _value: integer);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBAIntDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBAIntDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBAIntDataSet).Blue[(_y * FXSize) + _x] := _value;
         3: (FData as TRGBAIntDataSet).Alpha[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBAIntData.SetDefaultColor(_value: TPixelRGBAIntData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T2DImageRGBAIntData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBAIntData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBAIntData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBAIntData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T2DImageRGBAIntData).FDefaultColor.a;
end;

// Misc
procedure T2DImageRGBAIntData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAIntDataSet).Red[x] := Round((FData as TRGBAIntDataSet).Red[x] * _Value);
      (FData as TRGBAIntDataSet).Green[x] := Round((FData as TRGBAIntDataSet).Green[x] * _Value);
      (FData as TRGBAIntDataSet).Blue[x] := Round((FData as TRGBAIntDataSet).Blue[x] * _Value);
      (FData as TRGBAIntDataSet).Alpha[x] := Round((FData as TRGBAIntDataSet).Alpha[x] * _Value);
   end;
end;

procedure T2DImageRGBAIntData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAIntDataSet).Red[x] := 255 - (FData as TRGBAIntDataSet).Red[x];
      (FData as TRGBAIntDataSet).Green[x] := 255 - (FData as TRGBAIntDataSet).Green[x];
      (FData as TRGBAIntDataSet).Blue[x] := 255 - (FData as TRGBAIntDataSet).Blue[x];
      (FData as TRGBAIntDataSet).Alpha[x] := 255 - (FData as TRGBAIntDataSet).Alpha[x];
   end;
end;

end.
