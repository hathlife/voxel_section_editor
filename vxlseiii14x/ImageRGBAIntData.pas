unit ImageRGBAIntData;

interface

uses Windows, Graphics, Abstract2DImageData, RGBAIntDataSet;

type
   TImagePixelRGBAIntData = record
      r,g,b,a: longword;
   end;

   T2DImageRGBAIntData = class (TAbstract2DImageData)
      private
         FDefaultColor: TImagePixelRGBAIntData;
         // Gets
         function GetData(_x, _y, _c: integer):longword;
         function GetDefaultColor:TImagePixelRGBAIntData;
         // Sets
         procedure SetData(_x, _y, _c: integer; _value: longword);
         procedure SetDefaultColor(_value: TImagePixelRGBAIntData);
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
         // copies
         procedure Assign(const _Source: TAbstract2DImageData); override;
         // properties
         property Data[_x,_y,_c:integer]:longword read GetData write SetData; default;
         property DefaultColor:TImagePixelRGBAIntData read GetDefaultColor write SetDefaultColor;
   end;

implementation

// Constructors and Destructors
procedure T2DImageRGBAIntData.Initialize;
begin
   FDefaultColor.r := 0;
   FDefaultColor.g := 0;
   FDefaultColor.b := 0;
   FDefaultColor.a := 0;
   FData := TRGBAIntDataSet.Create;
end;

// Gets
function T2DImageRGBAIntData.GetData(_x, _y, _c: integer):longword;
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: Result := (FData as TRGBAIntDataSet).Red[(_y * FXSize) + _x];
         1: Result := (FData as TRGBAIntDataSet).Green[(_y * FXSize) + _x];
         2: Result := (FData as TRGBAIntDataSet).Blue[(_y * FXSize) + _x];
         else
         begin
            Result := (FData as TRGBAIntDataSet).Alpha[(_y * FXSize) + _x];
         end;
      end;
   end
   else
   begin
      case (_c) of
         0: Result := FDefaultColor.r;
         1: Result := FDefaultColor.g;
         2: Result := FDefaultColor.b;
         else
         begin
            Result := FDefaultColor.a;
         end;
      end;
   end;
end;

function T2DImageRGBAIntData.GetDefaultColor:TImagePixelRGBAIntData;
begin
   Result := FDefaultColor;
end;

function T2DImageRGBAIntData.GetBitmapPixelColor(_Position: longword):longword;
begin
   Result := RGB((FData as TRGBAIntDataSet).Red[_Position],(FData as TRGBAIntDataSet).Green[_Position],(FData as TRGBAIntDataSet).Blue[_Position]);
end;

function T2DImageRGBAIntData.GetRPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Red[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetGPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Green[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetBPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Blue[_Position] and $FF;
end;

function T2DImageRGBAIntData.GetAPixelColor(_Position: longword):byte;
begin
   Result := (FData as TRGBAIntDataSet).Alpha[_Position] and $FF;
end;


// Sets
procedure T2DImageRGBAIntData.SetBitmapPixelColor(_Position, _Color: longword);
begin
   (FData as TRGBAIntDataSet).Red[_Position] := GetRValue(_Color);
   (FData as TRGBAIntDataSet).Green[_Position] := GetGValue(_Color);
   (FData as TRGBAIntDataSet).Blue[_Position] := GetBValue(_Color);
end;

procedure T2DImageRGBAIntData.SetRGBAPixelColor(_Position, _r, _g, _b, _a: byte);
begin
   (FData as TRGBAIntDataSet).Red[_Position] := _r;
   (FData as TRGBAIntDataSet).Green[_Position] := _g;
   (FData as TRGBAIntDataSet).Blue[_Position] := _b;
   (FData as TRGBAIntDataSet).Alpha[_Position] := _a;
end;


procedure T2DImageRGBAIntData.SetData(_x, _y, _c: integer; _value: longword);
begin
   if (_x >= 0) and (_x < FXSize) and (_y >= 0) and (_y < FYSize) and (_c >= 0) and (_c <= 2) then
   begin
      case (_c) of
         0: (FData as TRGBAIntDataSet).Red[(_y * FXSize) + _x] := _value;
         1: (FData as TRGBAIntDataSet).Green[(_y * FXSize) + _x] := _value;
         2: (FData as TRGBAIntDataSet).Blue[(_y * FXSize) + _x] := _value;
         3: (FData as TRGBAIntDataSet).Alpha[(_y * FXSize) + _x] := _value;
      end;
   end;
end;

procedure T2DImageRGBAIntData.SetDefaultColor(_value: TImagePixelRGBAIntData);
begin
   FDefaultColor.r := _value.r;
   FDefaultColor.g := _value.g;
   FDefaultColor.b := _value.b;
   FDefaultColor.a := _value.a;
end;

// Copies
procedure T2DImageRGBAIntData.Assign(const _Source: TAbstract2DImageData);
begin
   inherited Assign(_Source);
   FDefaultColor.r := (_Source as T2DImageRGBAIntData).FDefaultColor.r;
   FDefaultColor.g := (_Source as T2DImageRGBAIntData).FDefaultColor.g;
   FDefaultColor.b := (_Source as T2DImageRGBAIntData).FDefaultColor.b;
   FDefaultColor.a := (_Source as T2DImageRGBAIntData).FDefaultColor.a;
end;

end.
