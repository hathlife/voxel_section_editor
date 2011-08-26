unit ImageGreyByteData;

interface
uses Windows, Graphics, Abstract2DImageData, ByteDataSet, dglOpenGL;

type
   T2DImageGreyByteData = class (TAbstract2DImageData)
      private
         // Gets
         function GetData(_x, _y: integer):byte;
         // Sets
         procedure SetData(_x, _y: integer; _value: byte);
      protected
         // Constructors and Destructors
         procedure Initialize; override;
         // Gets
         function GetBitmapPixelColor(_Position: longword):longword; override;
         function GetRPixelColor(_Position: longword):byte; override;
         function GetGPixelColor(_Position: longword):byte; override;
         function GetBPixelColor(_Position: longword):byte; override;
         function GetAPixelColor(_Position: longword):byte; override;
         function GetRedPixelColor(_x,_y: integer):single; override;
         function GetGreenPixelColor(_x,_y: integer):single; override;
         function GetBluePixelColor(_x,_y: integer):single; override;
         function GetAlphaPixelColor(_x,_y: integer):single; override;
         // Sets
         procedure SetBitmapPixelColor(_Position, _Color: longword); override;
         procedure SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte); override;
         procedure SetRedPixelColor(_x,_y: integer; _value:single); override;
         procedure SetGreenPixelColor(_x,_y: integer; _value:single); override;
         procedure SetBluePixelColor(_x,_y: integer; _value:single); override;
         procedure SetAlphaPixelColor(_x,_y: integer; _value:single); override;
      public
         // Gets
         function GetOpenGLFormat:TGLInt; override;
         // Misc
         procedure ScaleBy(_Value: single); override;
         procedure Invert; override;
         // properties
         property Data[_x,_y:integer]:byte read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageGreyByteData.Initialize;
begin
   FData := TByteDataSet.Create;
end;

// Gets
function T2DImageGreyByteData.GetData(_x, _y: integer):byte;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      Result := (FData as TByteDataSet).Data[(_y * FXSize) + _x];
   end
   else
   begin
      Result := 0;
   end;
end;

function T2DImageGreyByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TByteDataSet).Data[_Position],(FData as TByteDataSet).Data[_Position],(FData as TByteDataSet).Data[_Position]);
end;

function T2DImageGreyByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T2DImageGreyByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T2DImageGreyByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T2DImageGreyByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T2DImageGreyByteData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TByteDataSet).Data[(_y * FXSize) + _x];
end;

function T2DImageGreyByteData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyByteData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyByteData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyByteData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T2DImageGreyByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T2DImageGreyByteData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
end;

procedure T2DImageGreyByteData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TByteDataSet).Data[(_y * FXSize) + _x] := Round(_value) and $FF;
end;

procedure T2DImageGreyByteData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyByteData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyByteData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;


procedure T2DImageGreyByteData.SetData(_x, _y: integer; _value: byte);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      (FData as TByteDataSet).Data[(_y * FXSize) + _x] := _value;
   end;
end;

// Misc
procedure T2DImageGreyByteData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TByteDataSet).Data[x] := Round((FData as TByteDataSet).Data[x] * _Value);
   end;
end;

procedure T2DImageGreyByteData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TByteDataSet).Data[x] := 255 - (FData as TByteDataSet).Data[x];
   end;
end;


end.

