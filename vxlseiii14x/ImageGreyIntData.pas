unit ImageGreyIntData;

interface

uses Windows, Graphics, Abstract2DImageData, IntDataSet, dglOpenGL;

type
   T2DImageGreyIntData = class (TAbstract2DImageData)
      private
         // Gets
         function GetData(_x, _y: integer):longword;
         // Sets
         procedure SetData(_x, _y: integer; _value: longword);
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
         property Data[_x,_y:integer]:longword read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageGreyIntData.Initialize;
begin
   FData := TIntDataSet.Create;
end;

// Gets
function T2DImageGreyIntData.GetData(_x, _y: integer):longword;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      Result := (FData as TIntDataSet).Data[(_y * FXSize) + _x];
   end
   else
   begin
      Result := 0;
   end;
end;

function T2DImageGreyIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TIntDataSet).Data[_Position],(FData as TIntDataSet).Data[_Position],(FData as TIntDataSet).Data[_Position]);
end;

function T2DImageGreyIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TIntDataSet).Data[_Position] and $FF;
end;

function T2DImageGreyIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TIntDataSet).Data[_Position] and $FF;
end;

function T2DImageGreyIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TIntDataSet).Data[_Position] and $FF;
end;

function T2DImageGreyIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T2DImageGreyIntData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TIntDataSet).Data[(_y * FXSize) + _x];
end;

function T2DImageGreyIntData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyIntData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyIntData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyIntData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T2DImageGreyIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TIntDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T2DImageGreyIntData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TIntDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
end;

procedure T2DImageGreyIntData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TIntDataSet).Data[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageGreyIntData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyIntData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyIntData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;


procedure T2DImageGreyIntData.SetData(_x, _y: integer; _value: longword);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      (FData as TIntDataSet).Data[(_y * FXSize) + _x] := _value;
   end;
end;

// Misc
procedure T2DImageGreyIntData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TIntDataSet).Data[x] := Round((FData as TIntDataSet).Data[x] * _Value);
   end;
end;

procedure T2DImageGreyIntData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TIntDataSet).Data[x] := 255 - (FData as TIntDataSet).Data[x];
   end;
end;

end.

