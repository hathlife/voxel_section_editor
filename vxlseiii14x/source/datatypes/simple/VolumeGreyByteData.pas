unit VolumeGreyByteData;

interface

uses Windows, Graphics, Abstract3DVolumeData, AbstractDataSet, ByteDataSet,
   dglOpenGL, Math;

type
   T3DVolumeGreyByteData = class (TAbstract3DVolumeData)
      private
         // Gets
         function GetData(_x, _y, _z: integer):byte;
         function GetDataUnsafe(_x, _y, _z: integer):byte;
         // Sets
         procedure SetData(_x, _y, _z: integer; _value: byte);
         procedure SetDataUnsafe(_x, _y, _z: integer; _value: byte);
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
         procedure Fill(_value: byte);
         // properties
         property Data[_x,_y,_z:integer]:byte read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z:integer]:byte read GetDataUnsafe write SetDataUnsafe;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeGreyByteData.Initialize;
begin
   FData := TByteDataSet.Create;
end;

// Gets
function T3DVolumeGreyByteData.GetData(_x, _y,_z: integer):byte;
begin
   if IsPixelValid(_x,_y,_z) then
   begin
      Result := (FData as TByteDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
   end
   else
   begin
      Result := 0;
   end;
end;

// Use with care, otherwise you'll get an access violation.
function T3DVolumeGreyByteData.GetDataUnsafe(_x, _y,_z: integer):byte;
begin
   Result := (FData as TByteDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeGreyByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TByteDataSet).Data[_Position],(FData as TByteDataSet).Data[_Position],(FData as TByteDataSet).Data[_Position]);
end;

function T3DVolumeGreyByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T3DVolumeGreyByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T3DVolumeGreyByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T3DVolumeGreyByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeGreyByteData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TByteDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeGreyByteData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyByteData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyByteData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyByteData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T3DVolumeGreyByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T3DVolumeGreyByteData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
end;

procedure T3DVolumeGreyByteData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TByteDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeGreyByteData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyByteData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyByteData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;


procedure T3DVolumeGreyByteData.SetData(_x, _y, _z: integer; _value: byte);
begin
   if IsPixelValid(_x,_y,_z) then
   begin
      (FData as TByteDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeGreyByteData.SetDataUnsafe(_x, _y, _z: integer; _value: byte);
begin
  (FData as TByteDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

// Copies
procedure T3DVolumeGreyByteData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
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
            (FData as TByteDataSet).Data[x] := (_Data as TByteDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeGreyByteData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TByteDataSet).Data[x] := Round((FData as TByteDataSet).Data[x] * _Value);
   end;
end;

procedure T3DVolumeGreyByteData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TByteDataSet).Data[x] := 255 - (FData as TByteDataSet).Data[x];
   end;
end;

procedure T3DVolumeGreyByteData.Fill(_value: byte);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TByteDataSet).Data[x] := _value;
   end;
end;

end.

