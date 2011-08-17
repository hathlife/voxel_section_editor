unit ImageGreyByteData;

interface
uses Windows, Graphics, Abstract2DImageData, ByteDataSet;

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
         // Sets
         procedure SetBitmapPixelColor(_Position, _Color: longword); override;
         procedure SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte); override;
      public
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


// Sets
procedure T2DImageGreyByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T2DImageGreyByteData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
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

