unit ImageRGBData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBSingleDataSet;

type
   T2DImageRGBData = class (TAbstract2DImageData)
      private
         // Gets
         function GetData(_x, _y, _c: integer):single;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: single);
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
         property Data[_x,_y,_c:integer]:single read GetData write SetData; default;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBData.Initialize;
begin
   FData := TRGBSingleDataSet.Create;
end;

// Gets
function T2DImageRGBData.GetData(_x, _y, _c: integer):single;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBSingleDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBSingleDataSet).Green[(_y * FXSize) + _x];
         else
         begin
             Result := (FData as TRGBSingleDataSet).Blue[(_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      Result := -99999;
   end;
end;

function T2DImageRGBData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB(Round((FData as TRGBSingleDataSet).Red[_Position]) and $FF,Round((FData as TRGBSingleDataSet).Green[_Position]) and $FF,Round((FData as TRGBSingleDataSet).Blue[_Position]) and $FF);
end;

function T2DImageRGBData.GetRPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBSingleDataSet).Red[_Position]) and $FF;
end;

function T2DImageRGBData.GetGPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBSingleDataSet).Green[_Position]) and $FF;
end;

function T2DImageRGBData.GetBPixelColor(_Position: longword):byte;
begin
   Result := Round((FData as TRGBSingleDataSet).Blue[_Position]) and $FF;
end;

function T2DImageRGBData.GetAPixelColor(_Position: longword):byte;
begin
   Result := 0;
end;


// Sets
procedure T2DImageRGBData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBSingleDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBSingleDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBSingleDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TRGBSingleDataSet).Red[_Position] := _r;
   (FData as TRGBSingleDataSet).Green[_Position] := _g;
   (FData as TRGBSingleDataSet).Blue[_Position] := _b;
end;

procedure T2DImageRGBData.SetData(_x, _y, _c: integer; _value: single);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBSingleDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBSingleDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBSingleDataSet).Blue[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

end.
