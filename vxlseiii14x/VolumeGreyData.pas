unit VolumeGreyData;

interface
uses Windows, Graphics, Abstract3DVolumeData, AbstractDataSet, SingleDataSet,
   dglOpenGL, Math;

type
   T3DVolumeGreyData = class (TAbstract3DVolumeData)
      private
         // Gets
         function GetData(_x, _y, _z: integer):single;
         function GetDataUnsafe(_x, _y, _z: integer):single;
         // Sets
         procedure SetData(_x, _y, _z: integer; _value: single);
         procedure SetDataUnsafe(_x, _y, _z: integer; _value: single);
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
         procedure Fill(_value: single);
         // properties
         property Data[_x,_y,_z:integer]:single read GetData write SetData; default;
         property DataUnsafe[_x,_y,_z:integer]:single read GetDataUnsafe write SetDataUnsafe;
   end;

implementation

// Constructors and Destructors
procedure T3DVolumeGreyData.Initialize;
begin
   FData := TSingleDataSet.Create;
end;

// Gets
function T3DVolumeGreyData.GetData(_x, _y, _z: integer):single;
begin
   if IsPixelValid(_x,_y,_z) then
   begin
      Result := (FData as TSingleDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
   end
   else
   begin
      Result := -99999;
   end;
end;

function T3DVolumeGreyData.GetDataUnsafe(_x, _y, _z: integer):single;
begin
   Result := (FData as TSingleDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeGreyData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TSingleDataSet).Data[_Position]) and $FF,Round((FData as TSingleDataSet).Data[_Position]) and $FF,Round((FData as TSingleDataSet).Data[_Position]) and $FF);
end;

function T3DVolumeGreyData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T3DVolumeGreyData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T3DVolumeGreyData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T3DVolumeGreyData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T3DVolumeGreyData.GetRedPixelColor(_x,_y,_z: integer):single;
begin
   Result := (FData as TSingleDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x];
end;

function T3DVolumeGreyData.GetGreenPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyData.GetBluePixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyData.GetAlphaPixelColor(_x,_y,_z: integer):single;
begin
   Result := 0;
end;

function T3DVolumeGreyData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T3DVolumeGreyData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TSingleDataSet).Data[_Position] := (0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color));
end;

procedure T3DVolumeGreyData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TSingleDataSet).Data[_Position] := (0.299 * _r) + (0.587 * _g) + (0.114 * _b);
end;

procedure T3DVolumeGreyData.SetRedPixelColor(_x,_y,_z: integer; _value:single);
begin
   (FData as TSingleDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

procedure T3DVolumeGreyData.SetGreenPixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyData.SetBluePixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyData.SetAlphaPixelColor(_x,_y,_z: integer; _value:single);
begin
   // Do nothing
end;

procedure T3DVolumeGreyData.SetData(_x, _y, _z: integer; _value: single);
begin
   if IsPixelValid(_x,_y,_z) then
   begin
      (FData as TSingleDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
   end;
end;

procedure T3DVolumeGreyData.SetDataUnsafe(_x, _y, _z: integer; _value: single);
begin
  (FData as TSingleDataSet).Data[(_z * FYxXSize) + (_y * FXSize) + _x] := _value;
end;

// Copies
procedure T3DVolumeGreyData.CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: integer);
var
   x,y,z,ZPos,ZDataPos,Pos,maxPos,DataPos,maxX, maxY, maxZ: integer;
begin
   if (_DataXSize = 0) or (_DataYSize = 0) or (_DataZSize = 0) then
      exit;

   maxX := min(FXSize,_DataXSize)-1;
   maxY := min(FYSize,_DataYSize)-1;
   maxZ := min(FZSize,_DataZSize)-1;
   for z := 0 to maxZ do
   begin
      ZPos := z * FYSize * FXSize;
      ZDataPos := z * _DataYSize * _DataXSize;
      for y := 0 to maxY do
      begin
         Pos := ZPos + (y * FXSize);
         DataPos := ZDataPos + (y * _DataXSize);
         maxPos := Pos + maxX;
         for x := Pos to maxPos do
         begin
            (FData as TSingleDataSet).Data[x] := (_Data as TSingleDataSet).Data[DataPos];
            inc(DataPos);
         end;
      end;
   end;
end;

// Misc
procedure T3DVolumeGreyData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TSingleDataSet).Data[x] := (FData as TSingleDataSet).Data[x] * _Value;
   end;
end;

procedure T3DVolumeGreyData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TSingleDataSet).Data[x] := 1 - (FData as TSingleDataSet).Data[x];
   end;
end;

procedure T3DVolumeGreyData.Fill(_value: single);
var
   x,maxx: integer;
begin
   maxx := (FYxXSize * FZSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TSingleDataSet).Data[x] := _value;
   end;
end;

end.
