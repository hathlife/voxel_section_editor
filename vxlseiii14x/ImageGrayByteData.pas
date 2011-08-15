unit ImageGrayByteData;

interface
uses Windows, Graphics, Abstract2DImageData, ByteDataSet;

type
   T2DImageGrayByteData = class (TAbstract2DImageData)
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
         // properties
         property Data[_x,_y:integer]:byte read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageGrayByteData.Initialize;
begin
   FData := TByteDataSet.Create;
end;

// Gets
function T2DImageGrayByteData.GetData(_x, _y: integer):byte;
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

function T2DImageGrayByteData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TByteDataSet).Data[_Position],(FData as TByteDataSet).Data[_Position],(FData as TByteDataSet).Data[_Position]);
end;

function T2DImageGrayByteData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T2DImageGrayByteData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T2DImageGrayByteData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TByteDataSet).Data[_Position];
end;

function T2DImageGrayByteData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;


// Sets
procedure T2DImageGrayByteData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color))) * 255);
end;

procedure T2DImageGrayByteData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TByteDataSet).Data[_Position] := Round(((0.299 * _r) + (0.587 * _g) + (0.114 * _b)) * 255);
end;


procedure T2DImageGrayByteData.SetData(_x, _y: integer; _value: byte);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      (FData as TByteDataSet).Data[(_y * FXSize) + _x] := _value;
   end;
end;

end.

