unit ImageRGBAData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBASingleDataSet;

type
   T2DImageRGBAData = class (TAbstract2DImageData)
      private
         // Gets
         function GetData(_x, _y, _c: integer):single;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: single);
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
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         // properties
         property Data[_x,_y,_c:integer]:single read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBAData.Initialize;
begin
   FData := TRGBASingleDataSet.Create;
end;

// Gets
function T2DImageRGBAData.GetData(_x, _y, _c: integer):single;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBASingleDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBASingleDataSet).Green[(_y * FXSize) + _x];
         2: Result := (FData as TRGBASingleDataSet).Blue[(_y * FXSize) + _x];
         else
         begin
             Result := (FData as TRGBASingleDataSet).Alpha[(_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      Result := -99999;
   end;
end;

function T2DImageRGBAData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TRGBASingleDataSet).Red[_Position]) and $FF,Round((FData as TRGBASingleDataSet).Green[_Position]) and $FF,Round((FData as TRGBASingleDataSet).Blue[_Position]) and $FF);
end;

function T2DImageRGBAData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Red[_Position]) and $FF;
end;

function T2DImageRGBAData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Green[_Position]) and $FF;
end;

function T2DImageRGBAData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Blue[_Position]) and $FF;
end;

function T2DImageRGBAData.GetAPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Alpha[_Position]) and $FF;
end;

function T2DImageRGBAData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Red[(_y * FXSize) + _x];
end;

function T2DImageRGBAData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Green[(_y * FXSize) + _x];
end;

function T2DImageRGBAData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Blue[(_y * FXSize) + _x];
end;

function T2DImageRGBAData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Alpha[(_y * FXSize) + _x];
end;


// Sets
procedure T2DImageRGBAData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBASingleDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBASingleDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBASingleDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBAData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TRGBASingleDataSet).Red[_Position] := _r;
   (FData as TRGBASingleDataSet).Green[_Position] := _g;
   (FData as TRGBASingleDataSet).Blue[_Position] := _b;
   (FData as TRGBASingleDataSet).Alpha[_Position] := _a;
end;

procedure T2DImageRGBAData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Red[(_y * FXSize) + _x] := _value;
end;

procedure T2DImageRGBAData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Green[(_y * FXSize) + _x] := _value;
end;

procedure T2DImageRGBAData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Blue[(_y * FXSize) + _x] := _value;
end;

procedure T2DImageRGBAData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Alpha[(_y * FXSize) + _x] := _value;
end;

procedure T2DImageRGBAData.SetData(_x, _y, _c: integer; _value: single);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBASingleDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBASingleDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBASingleDataSet).Blue[(_y * FXSize) + _x] := _value;
         3: (FData as TRGBASingleDataSet).Alpha[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

// Misc
procedure T2DImageRGBAData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBASingleDataSet).Red[x] := (FData as TRGBASingleDataSet).Red[x] * _Value;
      (FData as TRGBASingleDataSet).Green[x] := (FData as TRGBASingleDataSet).Green[x] * _Value;
      (FData as TRGBASingleDataSet).Blue[x] := (FData as TRGBASingleDataSet).Blue[x] * _Value;
      (FData as TRGBASingleDataSet).Alpha[x] := (FData as TRGBASingleDataSet).Alpha[x] * _Value;
   end;
end;

procedure T2DImageRGBAData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBASingleDataSet).Red[x] := 1 - (FData as TRGBASingleDataSet).Red[x];
      (FData as TRGBASingleDataSet).Green[x] := 1 - (FData as TRGBASingleDataSet).Green[x];
      (FData as TRGBASingleDataSet).Blue[x] := 1 - (FData as TRGBASingleDataSet).Blue[x];
      (FData as TRGBASingleDataSet).Alpha[x] := 1 - (FData as TRGBASingleDataSet).Alpha[x];
   end;
end;

end.
