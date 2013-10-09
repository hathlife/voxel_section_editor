unit VolumeRGBData;

interface

uses Windows, Graphics, Abstract3DVolumeData, RGBSingleDataSet, AbstractDataSet,
   dglOpenGL, Math;

type
   T3DVolumeRGBData = class (TAbstract3DVolumeData)
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
         // Gets
         function GetOpenGLFormat:TGLInt; override;
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
procedure T3DVolumeRGBData.Initialize;
begin
   FData := TRGBSingleDataSet.Create;
end;

// Gets
function T3DVolumeRGBData.GetData(_x, _y, _z, _c: integer):single;
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBSingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
         1: Result := (FData as TRGBSingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
         else
         begin
             Result := (FData as TRGBSingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      Result := -99999;
   end;
end;

function T3DVolumeRGBData.GetDataUnsafe(_x, _y, _z, _c: integer):single;
begin
   case (_c) of
      0: Result := (FData as TRGBSingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
      1: Result := (FData as TRGBSingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
      else
      begin
          Result := (FData as TRGBSingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
      end;
   end;
end;

function T3DVolumeRGBData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TRGBSingleDataSet).Blue[_Position]) and $FF,Round((FData as TRGBSingleDataSet).Green[_Position]) and $FF,Round((FData as TRGBSingleDataSet).Red[_Position]) and $FF);
end;

function T3DVolumeRGBData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBSingleDataSet).Red[_Position]) and $FF;
end;

function T3DVolumeRGBData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBSingleDataSet).Green[_Position]) and $FF;
end;

function T3DVolumeRGBData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBSingleDataSet).Blue[_Position]) and $FF;
end;

function T3DVolumeRGBData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeRGBData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBSingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBSingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TRGBSingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeRGBData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeRGBData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T3DVolumeRGBData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBSingleDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBSingleDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBSingleDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T3DVolumeRGBData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TRGBSingleDataSet).Red[_Position] := _r;
   (FData as TRGBSingleDataSet).Green[_Position] := _g;
   (FData as TRGBSingleDataSet).Blue[_Position] := _b;
end;

procedure T3DVolumeRGBData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBSingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBSingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TRGBSingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeRGBData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // do nothing
end;

procedure T3DVolumeRGBData.SetData(_x, _y, _z, _c: integer; _value: single);
begin
   if IsPixelValid(_x,_y,_z) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBSingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         1: (FData as TRGBSingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
         2: (FData as TRGBSingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T3DVolumeRGBData.SetDataUnsafe(_x, _y, _z, _c: integer; _value: single);
begin
   case (_c) of
      0: (FData as TRGBSingleDataSet).Red[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      1: (FData as TRGBSingleDataSet).Green[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
      2: (FData as TRGBSingleDataSet).Blue[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

// Copies
procedure T3DVolumeRGBData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TRGBSingleDataSet).Data[x] := (_Data as TRGBSingleDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeRGBData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBSingleDataSet).Red[x] := Round((FData as TRGBSingleDataSet).Red[x] * _Value);
      (FData as TRGBSingleDataSet).Green[x] := Round((FData as TRGBSingleDataSet).Green[x] * _Value);
      (FData as TRGBSingleDataSet).Blue[x] := Round((FData as TRGBSingleDataSet).Blue[x] * _Value);
   end;
end;

procedure T3DVolumeRGBData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBSingleDataSet).Red[x] := 1 - (FData as TRGBSingleDataSet).Red[x];
      (FData as TRGBSingleDataSet).Green[x] := 1 - (FData as TRGBSingleDataSet).Green[x];
      (FData as TRGBSingleDataSet).Blue[x] := 1 - (FData as TRGBSingleDataSet).Blue[x];
   end;
end;

procedure T3DVolumeRGBData.Fill(_value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TRGBSingleDataSet).Red[x] := _value;
      (FData as TRGBSingleDataSet).Green[x] := _value;
      (FData as TRGBSingleDataSet).Blue[x] := _value;
   end;
end;

end.
