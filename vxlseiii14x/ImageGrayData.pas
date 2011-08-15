unit ImageGrayData;

interface
uses Windows, Graphics, Abstract2DImageData, SingleDataSet;

type
   T2DImageGrayData = class (TAbstract2DImageData)
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
         // Sets
         procedure SetBitmapPixelColor(_Position, _Color: longword); override;
         procedure SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte); override;
      public
         // properties
         property Data[_x,_y:integer]:single read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageGrayData.Initialize;
begin
   FData := TSingleDataSet.Create;
end;

// Gets
function T2DImageGrayData.GetData(_x, _y: integer):single;
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

function T2DImageGrayData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TSingleDataSet).Data[_Position]) and $FF,Round((FData as TSingleDataSet).Data[_Position]) and $FF,Round((FData as TSingleDataSet).Data[_Position]) and $FF);
end;

function T2DImageGrayData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T2DImageGrayData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T2DImageGrayData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TSingleDataSet).Data[_Position]) and $FF;
end;

function T2DImageGrayData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;



// Sets
procedure T2DImageGrayData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TSingleDataSet).Data[_Position] := (0.299 * GetRValue(_Color)) + (0.587 * GetGValue(_Color)) + (0.114 * GetBValue(_Color));
end;

procedure T2DImageGrayData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TSingleDataSet).Data[_Position] := (0.299 * _r) + (0.587 * _g) + (0.114 * _b);
end;

procedure T2DImageGrayData.SetData(_x, _y: integer; _value: single);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) then
   begin
      (FData as TSingleDataSet).Data[(_y * FXSize) + _x] := _value;
   end;
end;

end.
