unit VolumeGreyIntData;

interface

uses Windows, Graphics, Abstract3DVolumeData, AbstractDataSet, IntDataSet,
   dglOpenGL, Math;

type
   T3DVolumeGreyIntData = class (TAbstract3DVolumeData)
      private
         // Gets
         function GetData(_x, _y, _z: integer):longword;
         function GetDataUnsafe(_x, _y, _z: integer):longword;
         // Sets
         procedure SetData(_x, _y, _z: integer; _value: longword);
         procedure SetDataUnsafe(_x, _y, _z: integer; _value: longword);
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
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         procedure Fill(_value: longword);
         // properties
         property Data[_x,_y,_z:integer]:longword read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z:integer]:longword read GetDataUnsafe write SetDataUnsafe;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeGreyIntData.Initialize;
begin
   FData := TIntDataSet.Create;
end;

// Gets
function T3DVolumeGreyIntData.GetData(_x, _y,_z: integer):longword;
begin
   if IsPixelValid(_x,_y,_z) then
   begin
      Result := (FData as TIntDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
   end
   else
   begin
      Result := 0;
   end;
end;

function T3DVolumeGreyIntData.GetDataUnsafe(_x, _y,_z: integer):longword;
begin
   // Use with care, otherwise you'll get an access violation
   Result := (FData as TIntDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeGreyIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TIntDataSet).Data[_Position],(FData as TIntDataSet).Data[_Position],(FData as TIntDataSet).Data[_Position]);
end;

function T3DVolumeGreyIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TIntDataSet).Data[_Position] and $FF;
end;

function T3DVolumeGreyIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TIntDataSet).Data[_Position] and $FF;
end;

function T3DVolumeGreyIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TIntDataSet).Data[_Position] and $FF;
end;

function T3DVolumeGreyIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeGreyIntData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TIntDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeGreyIntData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyIntData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyIntData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyIntData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T3DVolumeGreyIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TIntDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T3DVolumeGreyIntData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TIntDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
end;

procedure T3DVolumeGreyIntData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TIntDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T3DVolumeGreyIntData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyIntData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyIntData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;


procedure T3DVolumeGreyIntData.SetData(_x, _y, _z: integer; _value: longword);
begin
   if IsPixelValid(_x,_y,_z) then
   begin
      (FData as TIntDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeGreyIntData.SetDataUnsafe(_x, _y, _z: integer; _value: longword);
begin
  (FData as TIntDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

// Copies
procedure T3DVolumeGreyIntData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: longword);
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
            (FData as TIntDataSet).Data[x] := (_Data as TIntDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeGreyIntData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TIntDataSet).Data[x] := Round((FData as TIntDataSet).Data[x] * _Value);
   end;
end;

procedure T3DVolumeGreyIntData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TIntDataSet).Data[x] := 255 - (FData as TIntDataSet).Data[x];
   end;
end;

procedure T3DVolumeGreyIntData.Fill(_value: longword);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TIntDataSet).Data[x] := _value;
   end;
end;

end.
