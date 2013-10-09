unit ImageGreyData;

interface
uses Windows, Graphics, Abstract2DImageData, SingleDataSet, dglOpenGL;

type
   T2DImageGreyData = class (TAbstract2DImageData)
      private
         // Gets
         function GetData(_x, _y: integer):single;
         // Sets
         procedure SetData(_x, _y: integer; _value: single);
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
         property Data[_x,_y:integer]:single read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageGreyData.Initialize;
begin
   FData := TSingleDataSet.Create;
end;

// Gets
function T2DImageGreyData.GetData(_x, _y: integer):single;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      Result := (FData as TSingleDataSet).Data[(_y * FXSize) + _x];
   end
   else
   begin
      Result := -99999;
   end;
end;

function T2DImageGreyData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TSingleDataSet).Data[_Position]) and $FF,Round((FData as TSingleDataSet).Data[_Position]) and $FF,Round((FData as TSingleDataSet).Data[_Position]) and $FF);
end;

function T2DImageGreyData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T2DImageGreyData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T2DImageGreyData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T2DImageGreyData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;

function T2DImageGreyData.GetRedPixelColor(_x,_y: integer):single;
begin
   Result := (FData as TSingleDataSet).Data[(_y * FXSize) + _x];
end;

function T2DImageGreyData.GetGreenPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyData.GetBluePixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyData.GetAlphaPixelColor(_x,_y: integer):single;
begin
   Result := 0;
end;

function T2DImageGreyData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGB;
end;


// Sets
procedure T2DImageGreyData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TSingleDataSet).Data[_Position] := (0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color));
end;

procedure T2DImageGreyData.SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte);
begin
   (FData as TSingleDataSet).Data[_Position] := (0.299 * _r) + (0.587 * _g) + (0.114 * _b);
end;

procedure T2DImageGreyData.SetRedPixelColor(_x,_y: integer; _value:single);
begin
   (FData as TSingleDataSet).Data[(_y * FXSize) + _x] := _value;
end;

procedure T2DImageGreyData.SetGreenPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyData.SetBluePixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyData.SetAlphaPixelColor(_x,_y: integer; _value:single);
begin
   // Do nothing
end;

procedure T2DImageGreyData.SetData(_x, _y: integer; _value: single);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      (FData as TSingleDataSet).Data[(_y * FXSize) + _x] := _value;
   end;
end;

// Misc
procedure T2DImageGreyData.ScaleBy(_Value: single);
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TSingleDataSet).Data[x] := (FData as TSingleDataSet).Data[x] * _Value;
   end;
end;

procedure T2DImageGreyData.Invert;
var
   x,maxx: integer;
begin
   maxx := (FXSize * FYSize) - 1;
   for x := 0 to maxx do
   begin
      (FData as TSingleDataSet).Data[x] := 1 - (FData as TSingleDataSet).Data[x];
   end;
end;


end.
