unit VolumeRGBByteData;

interface

uses Windows, Graphics, BasicDataTypes, Abstract3DVolumeData, RGBByteDataSet,
   AbstractDataSet, dglOpenGL, Math;

type
   T3DVolumeRGBByteData = class (TAbstract3DVolumeData)
      private
         FDefaultColor: TPixelRGBByteData;
         // Gets
         function GetData(_x, _y, _z, _c: integer):byte;
         function GetDataUnsafe(_x, _y, _z, _c: integer):byte;
         function GetDefaultColor:TPixelRGBByteData;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: byte);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: byte);
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
         procedure CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: longword); override;
      public
         // Gets
         function GetOpenGLFormat:TGLInt; override;
         // copies
         procedure Assign(const _Source: TAbstract3DVolumeData); override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         procedure Fill(_Value: byte);
         // properties
         property Data[_x,_y,_z,_c:integer]:byte read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:byte read GetDataUnsafe write SetDataUnsafe;
         property DefaultColor:TPixelRGBByteData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBByteData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FData := TRGBByteDataSet.Create;
end;

// Gets
function T3DVolumeRGBByteData.GetData(_x, _y, _z, _c: integer):byte;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
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

function T3DVolumeRGBByteData.GetDataUnsafe(_x, _y, _z, _c: integer):byte;
begin
   case (_c) of
      0: Result := (FData as TRGBByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBByteData.GetDefaultColor:TPixelRGBByteData;
begin
   Result := FDefaultColor;
end;

function T3DVolumeRGBByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBByteDataSet).Blue[_Position],(FData as TRGBByteDataSet).Green[_Position],(FData as TRGBByteDataSet).Red[_Position]);
end;

function T3DVolumeRGBByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBByteDataSet).Red[_Position];
end;

function T3DVolumeRGBByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBByteDataSet).Green[_Position];
end;

function T3DVolumeRGBByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBByteDataSet).Blue[_Position];
end;

function T3DVolumeRGBByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeRGBByteData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBByteData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBByteData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBByteData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeRGBByteData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;



// Sets
procedure T3DVolumeRGBByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBByteDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBByteDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBByteDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBByteData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBByteDataSet).Red[_Position] := _r;
   (FData as TRGBByteDataSet).Green[_Position] := _g;
   (FData as TRGBByteDataSet).Blue[_Position] := _b;
end;

procedure T3DVolumeRGBByteData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBByteData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBByteData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeRGBByteData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // do nothing
end;

procedure T3DVolumeRGBByteData.SetData(_x, _y, _z, _c: integer; _value: byte);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBByteData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: byte);
begin
   case (_c) of
      0: (FData as TRGBByteDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBByteDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBByteDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeRGBByteData.SetDefaultColor(_value: TPixelRGBByteData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
end;

// Copies
procedure T3DVolumeRGBByteData.Assign(const _Source: TAbstract3DVolumeData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T3DVolumeRGBByteData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T3DVolumeRGBByteData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T3DVolumeRGBByteData).FDefaultColor.b;
end;

procedure T3DVolumeRGBByteData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: longword);
var
   x,y,z,ZPos,ZDataPos,Pos,maxPos,DataPos,maxX, maxY, maxZ: longword;
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
            (FData as TRGBByteDataSet).Data[x] := (_Data as TRGBByteDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBByteData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBByteDataSet).Red[x] := Round((FData as TRGBByteDataSet).Red[x] * _Value);
      (FData as TRGBByteDataSet).Green[x] := Round((FData as TRGBByteDataSet).Green[x] * _Value);
      (FData as TRGBByteDataSet).Blue[x] := Round((FData as TRGBByteDataSet).Blue[x] * _Value);
   end;
end;

procedure T3DVolumeRGBByteData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBByteDataSet).Red[x] := 255 - (FData as TRGBByteDataSet).Red[x];
      (FData as TRGBByteDataSet).Green[x] := 255 - (FData as TRGBByteDataSet).Green[x];
      (FData as TRGBByteDataSet).Blue[x] := 255 - (FData as TRGBByteDataSet).Blue[x];
   end;
end;

procedure T3DVolumeRGBByteData.Fill(_value: byte);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBByteDataSet).Red[x] := _value;
      (FData as TRGBByteDataSet).Green[x] := _value;
      (FData as TRGBByteDataSet).Blue[x] := _value;
   end;
end;

end.
