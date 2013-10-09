unit VolumeRGBAData;

interface

uses Windows, Graphics, Abstract3DVolumeData, AbstractDataSet, RGBASingleDataSet,
   Math;

type
   T3DVolumeRGBAData = class (TAbstract3DVolumeData)
      private
         // Gets
         function GetData(_x, _y, _z, _c: integer):single;
         function GetDataUnsafe(_x, _y, _z, _c: integer):single;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: single);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: single);
      protected
         // Constructors and Destructors
         procedure Initialize; override;
         // Gets
         function GetBitmapPixelColor(_Position: longword):longword; override;
         function GetRPixelColor(_Position: longword):byte; override;
         function GetGPixelColor(_Position: longword):byte; override;
         function GetBPixelColor(_Position: longword):byte; override;
         function GetAPixelColor(_Position: longword):byte; override;
         function GetRedPixelColor(_x,_y,_z: integer):single; override;
         function GetGreenPixelColor(_x,_y,_z: integer):single; override;
         function GetBluePixelColor(_x,_y,_z: integer):single; override;
         function GetAlphaPixelColor(_x,_y,_z: integer):single; override;
         // Sets
         procedure SetBitmapPixelColor(_Position, _Color: longword); override;
         procedure SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte); override;
         procedure SetRedPixelColor(_x,_y,_z: integer; _value:single); override;
         procedure SetGreenPixelColor(_x,_y,_z: integer; _value:single); override;
         procedure SetBluePixelColor(_x,_y,_z: integer; _value:single); override;
         procedure SetAlphaPixelColor(_x,_y,_z: integer; _value:single); override;
         // Copies
         procedure CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer); override;
      public
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         procedure Fill(_Value: single);
         // properties
         property Data[_x,_y,_z,_c:integer]:single read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:single read GetDataUnsafe write SetDataUnsafe;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBAData.Initialize;
begin
   FData := TRGBASingleDataSet.Create;
end;

// Gets
function T3DVolumeRGBAData.GetData(_x, _y, _z, _c: integer):single;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBASingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBASingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         2: Result := (FData as TRGBASingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
             Result := (FData as TRGBASingleDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      Result := -99999;
   end;
end;

function T3DVolumeRGBAData.GetDataUnsafe(_x, _y, _z, _c: integer):single;
begin
   case (_c) of
      0: Result := (FData as TRGBASingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBASingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      2: Result := (FData as TRGBASingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBASingleDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBAData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TRGBASingleDataSet).Blue[_Position]) and $FF,Round((FData as TRGBASingleDataSet).Green[_Position]) and $FF,Round((FData as TRGBASingleDataSet).Red[_Position]) and $FF);
end;

function T3DVolumeRGBAData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Red[_Position]) and $FF;
end;

function T3DVolumeRGBAData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Green[_Position]) and $FF;
end;

function T3DVolumeRGBAData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Blue[_Position]) and $FF;
end;

function T3DVolumeRGBAData.GetAPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBASingleDataSet).Alpha[_Position]) and $FF;
end;

function T3DVolumeRGBAData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBASingleDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
end;


// Sets
procedure T3DVolumeRGBAData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBASingleDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBASingleDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBASingleDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBAData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBASingleDataSet).Red[_Position] := _r;
   (FData as TRGBASingleDataSet).Green[_Position] := _g;
   (FData as TRGBASingleDataSet).Blue[_Position] := _b;
   (FData as TRGBASingleDataSet).Alpha[_Position] := _a;
end;

procedure T3DVolumeRGBAData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBAData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBAData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBAData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBASingleDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBAData.SetData(_x, _y, _z, _c: integer; _value: single);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBASingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBASingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBASingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         3: (FData as TRGBASingleDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBAData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: single);
begin
   case (_c) of
      0: (FData as TRGBASingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBASingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBASingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      3: (FData as TRGBASingleDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

// Copies
procedure T3DVolumeRGBAData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
var
   x,y,z,ZPos,ZDataPos,Pos,maxPos,DataPos,maxX, maxY, maxZ: integer;
begin
   maxX := min(FXSize,_DataXSize)-1;
   maxY := min(FYSize,_DataYSize)-1;
   maxZ := min(FZSize,_DataZSize)-1;
   for z := 0 to maxZ do
   begin
      ZPos := z * FYxXSize;
      ZDataPos := z * _DataYSize * _DataXSize;
      for y := 0 to maxY do
      begin
         Pos := ZPos + (y * FXSize);
         DataPos := ZDataPos + (y * _DataXSize);
         maxPos := Pos + maxX;
         for x := Pos to maxPos do
         begin
            (FData as TRGBASingleDataSet).Data[x] := (_Data as TRGBASingleDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBAData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBASingleDataSet).Red[x] := (FData as TRGBASingleDataSet).Red[x] * _Value;
      (FData as TRGBASingleDataSet).Green[x] := (FData as TRGBASingleDataSet).Green[x] * _Value;
      (FData as TRGBASingleDataSet).Blue[x] := (FData as TRGBASingleDataSet).Blue[x] * _Value;
      (FData as TRGBASingleDataSet).Alpha[x] := (FData as TRGBASingleDataSet).Alpha[x] * _Value;
   end;
end;

procedure T3DVolumeRGBAData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBASingleDataSet).Red[x] := 1 - (FData as TRGBASingleDataSet).Red[x];
      (FData as TRGBASingleDataSet).Green[x] := 1 - (FData as TRGBASingleDataSet).Green[x];
      (FData as TRGBASingleDataSet).Blue[x] := 1 - (FData as TRGBASingleDataSet).Blue[x];
      (FData as TRGBASingleDataSet).Alpha[x] := 1 - (FData as TRGBASingleDataSet).Alpha[x];
   end;
end;

procedure T3DVolumeRGBAData.Fill(_value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBASingleDataSet).Red[x] := _value;
      (FData as TRGBASingleDataSet).Green[x] := _value;
      (FData as TRGBASingleDataSet).Blue[x] := _value;
      (FData as TRGBASingleDataSet).Alpha[x] := _value;
   end;
end;

end.
