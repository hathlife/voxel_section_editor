unit VolumeRGBIntData;

interface

uses Windows, Graphics, BasicDataTypes, Abstract3DVolumeData, RGBIntDataSet,
   AbstractDataSet, dglOpenGL, Math;

type
   T3DVolumeRGBIntData = class (TAbstract3DVolumeData)
      private
         FDefaultColor: TPixelRGBIntData;
         // Gets
         function GetData(_x, _y, _z, _c: integer):integer;
         function GetDataUnsafe(_x, _y, _z, _c: integer):integer;
         function GetDefaultColor:TPixelRGBIntData;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: integer);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: integer);
         procedure SetDefaultColor(_value: TPixelRGBIntData);
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
         // Gets
         function GetOpenGLFormat:TGLInt; override;
         // copies
         procedure Assign(const _Source: TAbstract3DVolumeData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         procedure Fill(_Value: integer);
         // properties
         property Data[_x,_y,_z,_c:integer]:integer read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:integer read GetDataUnsafe write SetDataUnsafe;
         property DefaultColor:TPixelRGBIntData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBIntData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FData := TRGBIntDataSet.Create;
end;

// Gets
function T3DVolumeRGBIntData.GetData(_x, _y, _z, _c: integer):integer;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
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

function T3DVolumeRGBIntData.GetDataUnsafe(_x, _y, _z, _c: integer):integer;
begin
   case (_c) of
      0: Result := (FData as TRGBIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBIntData.GetDefaultColor:TPixelRGBIntData;
begin
   Result := FDefaultColor;
end;

function T3DVolumeRGBIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBIntDataSet).Blue[_Position],(FData as TRGBIntDataSet).Green[_Position],(FData as TRGBIntDataSet).Red[_Position]);
end;

function T3DVolumeRGBIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBIntDataSet).Red[_Position] and $FF;
end;

function T3DVolumeRGBIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBIntDataSet).Green[_Position] and $FF;
end;

function T3DVolumeRGBIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBIntDataSet).Blue[_Position] and $FF;
end;

function T3DVolumeRGBIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeRGBIntData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBIntData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBIntData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBIntData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeRGBIntData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T3DVolumeRGBIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBIntDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBIntDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBIntDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBIntData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBIntDataSet).Red[_Position] := _r;
   (FData as TRGBIntDataSet).Green[_Position] := _g;
   (FData as TRGBIntDataSet).Blue[_Position] := _b;
end;

procedure T3DVolumeRGBIntData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBIntData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBIntData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBIntData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // do nothing
end;

procedure T3DVolumeRGBIntData.SetData(_x, _y, _z, _c: integer; _value: integer);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBIntData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: integer);
begin
   case (_c) of
      0: (FData as TRGBIntDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBIntDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBIntDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeRGBIntData.SetDefaultColor(_value: TPixelRGBIntData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
end;

// Copies
procedure T3DVolumeRGBIntData.Assign(const _Source: TAbstract3DVolumeData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T3DVolumeRGBIntData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T3DVolumeRGBIntData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T3DVolumeRGBIntData).FDefaultColor.b;
end;

procedure T3DVolumeRGBIntData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TRGBIntDataSet).Data[x] := (_Data as TRGBIntDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBIntData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBIntDataSet).Red[x] := Round((FData as TRGBIntDataSet).Red[x] * _Value);
      (FData as TRGBIntDataSet).Green[x] := Round((FData as TRGBIntDataSet).Green[x] * _Value);
      (FData as TRGBIntDataSet).Blue[x] := Round((FData as TRGBIntDataSet).Blue[x] * _Value);
   end;
end;

procedure T3DVolumeRGBIntData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBIntDataSet).Red[x] := 255 - (FData as TRGBIntDataSet).Red[x];
      (FData as TRGBIntDataSet).Green[x] := 255 - (FData as TRGBIntDataSet).Green[x];
      (FData as TRGBIntDataSet).Blue[x] := 255 - (FData as TRGBIntDataSet).Blue[x];
   end;
end;

procedure T3DVolumeRGBIntData.Fill(_value: integer);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBIntDataSet).Red[x] := _value;
      (FData as TRGBIntDataSet).Green[x] := _value;
      (FData as TRGBIntDataSet).Blue[x] := _value;
   end;
end;

end.
