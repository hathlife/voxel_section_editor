unit VolumeRGBAByteData;

interface

uses Windows, Graphics, BasicDataTypes, AbstractDataSet, Abstract3DVolumeData,
   RGBAByteDataSet, Math;

type
   T3DVolumeRGBAByteData = class (TAbstract3DVolumeData)
      private
         FDefaultColor: TPixelRGBAByteData;
         // Gets
         function GetData(_x, _y, _z, _c: integer):byte;
         function GetDataUnsafe(_x, _y, _z, _c: integer):byte;
         function GetDefaultColor:TPixelRGBAByteData;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: byte);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: byte);
         procedure SetDefaultColor(_value: TPixelRGBAByteData);
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
         // copies
         procedure Assign(const _Source: TAbstract3DVolumeData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         procedure Fill(_Value: byte);
         // properties
         property Data[_x,_y,_z,_c:integer]:byte read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:byte read GetDataUnsafe write SetDataUnsafe;
         property DefaultColor:TPixelRGBAByteData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBAByteData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBAByteDataSet.Create;
end;

// Gets
function T3DVolumeRGBAByteData.GetData(_x, _y, _z, _c: integer):byte;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBAByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBAByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         2: Result := (FData as TRGBAByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBAByteDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
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

function T3DVolumeRGBAByteData.GetDataUnsafe(_x, _y, _z, _c: integer):byte;
begin
   case (_c) of
      0: Result := (FData as TRGBAByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBAByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      2: Result := (FData as TRGBAByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBAByteDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBAByteData.GetDefaultColor:TPixelRGBAByteData;
begin
   Result := FDefaultColor;
end;

function T3DVolumeRGBAByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBAByteDataSet).Blue[_Position],(FData as TRGBAByteDataSet).Green[_Position],(FData as TRGBAByteDataSet).Red[_Position]);
end;

function T3DVolumeRGBAByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Red[_Position];
end;

function T3DVolumeRGBAByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Green[_Position];
end;

function T3DVolumeRGBAByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Blue[_Position];
end;

function T3DVolumeRGBAByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAByteDataSet).Alpha[_Position];
end;

function T3DVolumeRGBAByteData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAByteData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAByteData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAByteData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAByteDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
end;



// Sets
procedure T3DVolumeRGBAByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBAByteDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBAByteDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBAByteDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBAByteData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBAByteDataSet).Red[_Position] := _r;
   (FData as TRGBAByteDataSet).Green[_Position] := _g;
   (FData as TRGBAByteDataSet).Blue[_Position] := _b;
   (FData as TRGBAByteDataSet).Alpha[_Position] := _a;
end;

procedure T3DVolumeRGBAByteData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBAByteData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBAByteData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBAByteData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAByteDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBAByteData.SetData(_x, _y, _z, _c: integer; _value: byte);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBAByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBAByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBAByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         3: (FData as TRGBAByteDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBAByteData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: byte);
begin
   case (_c) of
      0: (FData as TRGBAByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBAByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBAByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      3: (FData as TRGBAByteDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeRGBAByteData.SetDefaultColor(_value: TPixelRGBAByteData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T3DVolumeRGBAByteData.Assign(const _Source: TAbstract3DVolumeData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T3DVolumeRGBAByteData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T3DVolumeRGBAByteData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T3DVolumeRGBAByteData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T3DVolumeRGBAByteData).FDefaultColor.a;
end;

// Copies
procedure T3DVolumeRGBAByteData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TRGBAByteDataSet).Data[x] := (_Data as TRGBAByteDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBAByteData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAByteDataSet).Red[x] := Round((FData as TRGBAByteDataSet).Red[x] * _Value);
      (FData as TRGBAByteDataSet).Green[x] := Round((FData as TRGBAByteDataSet).Green[x] * _Value);
      (FData as TRGBAByteDataSet).Blue[x] := Round((FData as TRGBAByteDataSet).Blue[x] * _Value);
      (FData as TRGBAByteDataSet).Alpha[x] := Round((FData as TRGBAByteDataSet).Alpha[x] * _Value);
   end;
end;

procedure T3DVolumeRGBAByteData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAByteDataSet).Red[x] := 255 - (FData as TRGBAByteDataSet).Red[x];
      (FData as TRGBAByteDataSet).Green[x] := 255 - (FData as TRGBAByteDataSet).Green[x];
      (FData as TRGBAByteDataSet).Blue[x] := 255 - (FData as TRGBAByteDataSet).Blue[x];
      (FData as TRGBAByteDataSet).Alpha[x] := 255 - (FData as TRGBAByteDataSet).Alpha[x];
   end;
end;

procedure T3DVolumeRGBAByteData.Fill(_value: byte);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAByteDataSet).Red[x] := _value;
      (FData as TRGBAByteDataSet).Green[x] := _value;
      (FData as TRGBAByteDataSet).Blue[x] := _value;
      (FData as TRGBAByteDataSet).Alpha[x] := _value;
   end;
end;

end.
