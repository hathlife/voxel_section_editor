unit VolumeRGBAIntData;

interface

uses Windows, Graphics, Abstract3DVolumeData, AbstractDataSet, RGBAIntDataSet,
   Math;

type
   TImagePixelRGBAIntData = record
      r,g,b,a: longword;
   end;

   T3DVolumeRGBAIntData = class (TAbstract3DVolumeData)
      private
         FDefaultColor: TImagePixelRGBAIntData;
         // Gets
         function GetData(_x, _y, _z, _c: integer):integer;
         function GetDataUnsafe(_x, _y, _z, _c: integer):integer;
         function GetDefaultColor:TImagePixelRGBAIntData;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: integer);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: integer);
         procedure SetDefaultColor(_value: TImagePixelRGBAIntData);
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
         procedure Fill(_Value: integer);
         // properties
         property Data[_x,_y,_z,_c:integer]:integer read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:integer read GetDataUnsafe write SetDataUnsafe;
         property DefaultColor:TImagePixelRGBAIntData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBAIntData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBAIntDataSet.Create;
end;

// Gets
function T3DVolumeRGBAIntData.GetData(_x, _y, _z, _c: integer):integer;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBAIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBAIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         2: Result := (FData as TRGBAIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBAIntDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
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

function T3DVolumeRGBAIntData.GetDataUnsafe(_x, _y, _z, _c: integer):integer;
begin
   case (_c) of
      0: Result := (FData as TRGBAIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBAIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      2: Result := (FData as TRGBAIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBAIntDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBAIntData.GetDefaultColor:TImagePixelRGBAIntData;
begin
   Result := FDefaultColor;
end;

function T3DVolumeRGBAIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBAIntDataSet).Blue[_Position],(FData as TRGBAIntDataSet).Green[_Position],(FData as TRGBAIntDataSet).Red[_Position]);
end;

function T3DVolumeRGBAIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Red[_Position] and $FF;
end;

function T3DVolumeRGBAIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Green[_Position] and $FF;
end;

function T3DVolumeRGBAIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Blue[_Position] and $FF;
end;

function T3DVolumeRGBAIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Alpha[_Position] and $FF;
end;

function T3DVolumeRGBAIntData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAIntData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAIntData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBAIntData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBAIntDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x];
end;


// Sets
procedure T3DVolumeRGBAIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBAIntDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBAIntDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBAIntDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBAIntData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBAIntDataSet).Red[_Position] := _r;
   (FData as TRGBAIntDataSet).Green[_Position] := _g;
   (FData as TRGBAIntDataSet).Blue[_Position] := _b;
   (FData as TRGBAIntDataSet).Alpha[_Position] := _a;
end;

procedure T3DVolumeRGBAIntData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBAIntData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBAIntData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBAIntData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBAIntDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBAIntData.SetData(_x, _y, _z, _c: integer; _value: integer);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBAIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBAIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBAIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         3: (FData as TRGBAIntDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBAIntData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: integer);
begin
   case (_c) of
      0: (FData as TRGBAIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBAIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBAIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      3: (FData as TRGBAIntDataSet).Alpha[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeRGBAIntData.SetDefaultColor(_value: TImagePixelRGBAIntData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T3DVolumeRGBAIntData.Assign(const _Source: TAbstract3DVolumeData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T3DVolumeRGBAIntData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T3DVolumeRGBAIntData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T3DVolumeRGBAIntData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T3DVolumeRGBAIntData).FDefaultColor.a;
end;

procedure T3DVolumeRGBAIntData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TRGBAIntDataSet).Data[x] := (_Data as TRGBAIntDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBAIntData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAIntDataSet).Red[x] := Round((FData as TRGBAIntDataSet).Red[x] * _Value);
      (FData as TRGBAIntDataSet).Green[x] := Round((FData as TRGBAIntDataSet).Green[x] * _Value);
      (FData as TRGBAIntDataSet).Blue[x] := Round((FData as TRGBAIntDataSet).Blue[x] * _Value);
      (FData as TRGBAIntDataSet).Alpha[x] := Round((FData as TRGBAIntDataSet).Alpha[x] * _Value);
   end;
end;

procedure T3DVolumeRGBAIntData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAIntDataSet).Red[x] := 255 - (FData as TRGBAIntDataSet).Red[x];
      (FData as TRGBAIntDataSet).Green[x] := 255 - (FData as TRGBAIntDataSet).Green[x];
      (FData as TRGBAIntDataSet).Blue[x] := 255 - (FData as TRGBAIntDataSet).Blue[x];
      (FData as TRGBAIntDataSet).Alpha[x] := 255 - (FData as TRGBAIntDataSet).Alpha[x];
   end;
end;

procedure T3DVolumeRGBAIntData.Fill(_value: integer);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBAIntDataSet).Red[x] := _value;
      (FData as TRGBAIntDataSet).Green[x] := _value;
      (FData as TRGBAIntDataSet).Blue[x] := _value;
      (FData as TRGBAIntDataSet).Alpha[x] := _value;
   end;
end;

end.
