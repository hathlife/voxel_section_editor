unit ImageRGBALongData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBALongDataSet, BasicDataTypes;

type
   T2DImageRGBALongData = class (TAbstract2DImageData)
      private
         FDefaultColor: TPixelRGBALongData;
         // Gets
         function GetData(_x, _y, _c: integer):longword;
         function GetDefaultColor:TPixelRGBALongData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: longword);
         procedure SetDefaultColor(_value: TPixelRGBALongData);
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
         property Data[_x,_y,_c:integer]:longword read GetData write SetData; default;
         property DefaultColor:TPixelRGBALongData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBALongData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBALongDataSet.Create;
end;

// Gets
function T2DImageRGBALongData.GetData(_x, _y, _c: integer):longword;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBALongDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBALongDataSet).Green[(_y * FXSize) + _x];
         2: Result := (FData as TRGBALongDataSet).Blue[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBALongDataSet).Alpha[(_y * FXSize) + _x];
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

function T2DImageRGBALongData.GetDefaultColor:TPixelRGBALongData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBALongData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBALongDataSet).Blue[_Position],(FData as TRGBALongDataSet).Green[_Position],(FData as TRGBALongDataSet).Red[_Position]);
end;

function T2DImageRGBALongData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Red[_Position] and $FF;
end;

function T2DImageRGBALongData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Green[_Position] and $FF;
end;

function T2DImageRGBALongData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Blue[_Position] and $FF;
end;

function T2DImageRGBALongData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Alpha[_Position] and $FF;
end;

function T2DImageRGBALongData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Red[(_y * FXSize) + _x];
end;

function T2DImageRGBALongData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Green[(_y * FXSize) + _x];
end;

function T2DImageRGBALongData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Blue[(_y * FXSize) + _x];
end;

function T2DImageRGBALongData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Alpha[(_y * FXSize) + _x];
end;


// Sets
procedure T2DImageRGBALongData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBALongDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBALongDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBALongDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBALongData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBALongDataSet).Red[_Position] := _r;
   (FData as TRGBALongDataSet).Green[_Position] := _g;
   (FData as TRGBALongDataSet).Blue[_Position] := _b;
   (FData as TRGBALongDataSet).Alpha[_Position] := _a;
end;

procedure T2DImageRGBALongData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Red[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBALongData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Green[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBALongData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Blue[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBALongData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Alpha[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageRGBALongData.SetData(_x, _y, _c: integer; _value: longword);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBALongDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBALongDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBALongDataSet).Blue[(_y * FXSize) + _x] := _value;
         3: (FData as TRGBALongDataSet).Alpha[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBALongData.SetDefaultColor(_value: TPixelRGBALongData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T2DImageRGBALongData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBALongData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBALongData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBALongData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T2DImageRGBALongData).FDefaultColor.a;
end;

// Misc
procedure T2DImageRGBALongData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBALongDataSet).Red[x] := Round((FData as TRGBALongDataSet).Red[x] * _Value);
      (FData as TRGBALongDataSet).Green[x] := Round((FData as TRGBALongDataSet).Green[x] * _Value);
      (FData as TRGBALongDataSet).Blue[x] := Round((FData as TRGBALongDataSet).Blue[x] * _Value);
      (FData as TRGBALongDataSet).Alpha[x] := Round((FData as TRGBALongDataSet).Alpha[x] * _Value);
   end;
end;

procedure T2DImageRGBALongData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBALongDataSet).Red[x] := 255 - (FData as TRGBALongDataSet).Red[x];
      (FData as TRGBALongDataSet).Green[x] := 255 - (FData as TRGBALongDataSet).Green[x];
      (FData as TRGBALongDataSet).Blue[x] := 255 - (FData as TRGBALongDataSet).Blue[x];
      (FData as TRGBALongDataSet).Alpha[x] := 255 - (FData as TRGBALongDataSet).Alpha[x];
   end;
end;

end.
