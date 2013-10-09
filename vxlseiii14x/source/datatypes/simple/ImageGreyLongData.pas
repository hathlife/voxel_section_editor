unit ImageGreyLongData;

interface

uses Windows, Graphics, Abstract2DImageData, LongDataSet, dglOpenGL;

type
   T2DImageGreyLongData = class (TAbstract2DImageData)
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
procedure T2DImageGreyLongData.Initialize;
begin
   FData := TLongDataSet.Create;
end;

// Gets
function T2DImageGreyLongData.GetData(_x, _y: integer):longword;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      Result := (FData as TLongDataSet).Data[(_y * FXSize) + _x];
   end
   else
   begin
      Result := 0;
   end;
end;

function T2DImageGreyLongData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TLongDataSet).Data[_Position],(FData as TLongDataSet).Data[_Position],(FData as TLongDataSet).Data[_Position]);
end;

function T2DImageGreyLongData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TLongDataSet).Data[_Position] and $FF;
end;

function T2DImageGreyLongData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TLongDataSet).Data[_Position] and $FF;
end;

function T2DImageGreyLongData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TLongDataSet).Data[_Position] and $FF;
end;

function T2DImageGreyLongData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T2DImageGreyLongData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TLongDataSet).Data[(_y * FXSize) + _x];
end;

function T2DImageGreyLongData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyLongData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyLongData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyLongData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T2DImageGreyLongData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TLongDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T2DImageGreyLongData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TLongDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
end;

procedure T2DImageGreyLongData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TLongDataSet).Data[(_y * FXSize) + _x] := Round(_value);
end;

procedure T2DImageGreyLongData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyLongData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyLongData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;


procedure T2DImageGreyLongData.SetData(_x, _y: integer; _value: longword);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      (FData as TLongDataSet).Data[(_y * FXSize) + _x] := _value;
   end;
end;

// Misc
procedure T2DImageGreyLongData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TLongDataSet).Data[x] := Round((FData as TLongDataSet).Data[x] * _Value);
   end;
end;

procedure T2DImageGreyLongData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TLongDataSet).Data[x] := 255 - (FData as TLongDataSet).Data[x];
   end;
end;

end.

