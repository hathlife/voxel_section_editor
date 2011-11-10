unit VolumeRGBALongData;

interface

uses Windows, Graphics, Abstract3DVolumeData, AbstractDataSet, RGBALongDataSet,
   Math, BasicDataTypes;

type
   T3DVolumeRGBALongData = class (TAbstract3DVolumeData)
      private
         FDefaultColor: TPixelRGBALongData;
         // Gets
         function GetData(_x, _y, _z, _c: integer):longword;
         function GetDataUnsafe(_x, _y, _z, _c: integer):longword;
         function GetDefaultColor:TPixelRGBALongData;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: longword);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: longword);
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
         procedure Fill(_Value: longword);
         // properties
         property Data[_x,_y,_z,_c:integer]:longword read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:longword read GetDataUnsafe write SetDataUnsafe;
         property DefaultColor:TPixelRGBALongData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBALongData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBALongDataSet.Create;
end;

// Gets
function T3DVolumeRGBALongData.GetData(_x, _y, _z, _c: integer):longword;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBALongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBALongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         2: Result := (FData as TRGBALongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBALongDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
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

function T3DVolumeRGBALongData.GetDataUnsafe(_x, _y, _z, _c: integer):longword;
begin
   case (_c) of
      0: Result := (FData as TRGBALongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBALongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      2: Result := (FData as TRGBALongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBALongDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBALongData.GetDefaultColor:TPixelRGBALongData;
begin
   Result := FDefaultColor;
end;

function T3DVolumeRGBALongData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBALongDataSet).Blue[_Position],(FData as TRGBALongDataSet).Green[_Position],(FData as TRGBALongDataSet).Red[_Position]);
end;

function T3DVolumeRGBALongData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Red[_Position] and $FF;
end;

function T3DVolumeRGBALongData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Green[_Position] and $FF;
end;

function T3DVolumeRGBALongData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Blue[_Position] and $FF;
end;

function T3DVolumeRGBALongData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBALongDataSet).Alpha[_Position] and $FF;
end;

function T3DVolumeRGBALongData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBALongData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBALongData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBALongData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBALongDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
end;


// Sets
procedure T3DVolumeRGBALongData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBALongDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBALongDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBALongDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBALongData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBALongDataSet).Red[_Position] := _r;
   (FData as TRGBALongDataSet).Green[_Position] := _g;
   (FData as TRGBALongDataSet).Blue[_Position] := _b;
   (FData as TRGBALongDataSet).Alpha[_Position] := _a;
end;

procedure T3DVolumeRGBALongData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBALongData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBALongData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBALongData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBALongDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBALongData.SetData(_x, _y, _z, _c: integer; _value: longword);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBALongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBALongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBALongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         3: (FData as TRGBALongDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBALongData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: longword);
begin
   case (_c) of
      0: (FData as TRGBALongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBALongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBALongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      3: (FData as TRGBALongDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeRGBALongData.SetDefaultColor(_value: TPixelRGBALongData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T3DVolumeRGBALongData.Assign(const _Source: TAbstract3DVolumeData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T3DVolumeRGBALongData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T3DVolumeRGBALongData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T3DVolumeRGBALongData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T3DVolumeRGBALongData).FDefaultColor.a;
end;

procedure T3DVolumeRGBALongData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TRGBALongDataSet).Data[x] := (_Data as TRGBALongDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBALongData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBALongDataSet).Red[x] := Round((FData as TRGBALongDataSet).Red[x] * _Value);
      (FData as TRGBALongDataSet).Green[x] := Round((FData as TRGBALongDataSet).Green[x] * _Value);
      (FData as TRGBALongDataSet).Blue[x] := Round((FData as TRGBALongDataSet).Blue[x] * _Value);
      (FData as TRGBALongDataSet).Alpha[x] := Round((FData as TRGBALongDataSet).Alpha[x] * _Value);
   end;
end;

procedure T3DVolumeRGBALongData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBALongDataSet).Red[x] := 255 - (FData as TRGBALongDataSet).Red[x];
      (FData as TRGBALongDataSet).Green[x] := 255 - (FData as TRGBALongDataSet).Green[x];
      (FData as TRGBALongDataSet).Blue[x] := 255 - (FData as TRGBALongDataSet).Blue[x];
      (FData as TRGBALongDataSet).Alpha[x] := 255 - (FData as TRGBALongDataSet).Alpha[x];
   end;
end;

procedure T3DVolumeRGBALongData.Fill(_value: longword);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBALongDataSet).Red[x] := _value;
      (FData as TRGBALongDataSet).Green[x] := _value;
      (FData as TRGBALongDataSet).Blue[x] := _value;
      (FData as TRGBALongDataSet).Alpha[x] := _value;
   end;
end;

end.
