unit VolumeRGBLongData;

interface

uses Windows, Graphics, BasicDataTypes, Abstract3DVolumeData, RGBLongDataSet,
   AbstractDataSet, dglOpenGL, Math;

type
   T3DVolumeRGBLongData = class (TAbstract3DVolumeData)
      private
         FDefaultColor: TPixelRGBLongData;
         // Gets
         function GetData(_x, _y, _z, _c: integer):longword;
         function GetDataUnsafe(_x, _y, _z, _c: integer):longword;
         function GetDefaultColor:TPixelRGBLongData;
         // Sets
         procedure SetData(_x, _y, _z, _c: integer; _value: longword);
         procedure SetDataUnsafe(_x, _y, _z, _c: integer; _value: longword);
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
         procedure Fill(_Value: longword);
         // properties
         property Data[_x,_y,_z,_c:integer]:longword read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z,_c:integer]:longword read GetDataUnsafe write SetDataUnsafe;
         property DefaultColor:TPixelRGBLongData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeRGBLongData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FData := TRGBLongDataSet.Create;
end;

// Gets
function T3DVolumeRGBLongData.GetData(_x, _y, _z, _c: integer):longword;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBLongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBLongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBLongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
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

function T3DVolumeRGBLongData.GetDataUnsafe(_x, _y, _z, _c: integer):longword;
begin
   case (_c) of
      0: Result := (FData as TRGBLongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBLongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
         Result := (FData as TRGBLongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBLongData.GetDefaultColor:TPixelRGBLongData;
begin
   Result := FDefaultColor;
end;

function T3DVolumeRGBLongData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBLongDataSet).Blue[_Position],(FData as TRGBLongDataSet).Green[_Position],(FData as TRGBLongDataSet).Red[_Position]);
end;

function T3DVolumeRGBLongData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBLongDataSet).Red[_Position] and $FF;
end;

function T3DVolumeRGBLongData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBLongDataSet).Green[_Position] and $FF;
end;

function T3DVolumeRGBLongData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBLongDataSet).Blue[_Position] and $FF;
end;

function T3DVolumeRGBLongData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeRGBLongData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBLongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBLongData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBLongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBLongData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBLongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBLongData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeRGBLongData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T3DVolumeRGBLongData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBLongDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBLongDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBLongDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBLongData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBLongDataSet).Red[_Position] := _r;
   (FData as TRGBLongDataSet).Green[_Position] := _g;
   (FData as TRGBLongDataSet).Blue[_Position] := _b;
end;

procedure T3DVolumeRGBLongData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBLongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBLongData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBLongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBLongData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBLongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value);
end;

procedure T3DVolumeRGBLongData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // do nothing
end;

procedure T3DVolumeRGBLongData.SetData(_x, _y, _z, _c: integer; _value: longword);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBLongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBLongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBLongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBLongData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: longword);
begin
   case (_c) of
      0: (FData as TRGBLongDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBLongDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBLongDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeRGBLongData.SetDefaultColor(_value: TPixelRGBLongData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
end;

// Copies
procedure T3DVolumeRGBLongData.Assign(const _Source: TAbstract3DVolumeData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T3DVolumeRGBLongData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T3DVolumeRGBLongData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T3DVolumeRGBLongData).FDefaultColor.b;
end;

procedure T3DVolumeRGBLongData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TRGBLongDataSet).Data[x] := (_Data as TRGBLongDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBLongData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBLongDataSet).Red[x] := Round((FData as TRGBLongDataSet).Red[x] * _Value);
      (FData as TRGBLongDataSet).Green[x] := Round((FData as TRGBLongDataSet).Green[x] * _Value);
      (FData as TRGBLongDataSet).Blue[x] := Round((FData as TRGBLongDataSet).Blue[x] * _Value);
   end;
end;

procedure T3DVolumeRGBLongData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBLongDataSet).Red[x] := 255 - (FData as TRGBLongDataSet).Red[x];
      (FData as TRGBLongDataSet).Green[x] := 255 - (FData as TRGBLongDataSet).Green[x];
      (FData as TRGBLongDataSet).Blue[x] := 255 - (FData as TRGBLongDataSet).Blue[x];
   end;
end;

procedure T3DVolumeRGBLongData.Fill(_value: longword);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBLongDataSet).Red[x] := _value;
      (FData as TRGBLongDataSet).Green[x] := _value;
      (FData as TRGBLongDataSet).Blue[x] := _value;
   end;
end;

end.
