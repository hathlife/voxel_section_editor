unit Abstract3DVolumeData;

interface

uses Windows, Graphics, BasicFunctions, BasicDataTypes, AbstractDataSet, dglOpenGL;

type
   TAbstract3DVolumeData = class
      protected
         FData: TAbstractDataSet;
         FXSize, FYSize, FZSize: integer;
         FName: string;
         // Variables for performance optimization
         FYxXSize: longword;
         FMaxX, FMaxY, FMaxZ: longword;
         // Constructors and Destructors
         procedure Initialize; virtual;
         // I/O
         procedure LoadBitmap(const _Bitmap:TBitmap);
         // Gets
         function GetXSize: integer;
         function GetYSize: integer;
         function GetZSize: integer;
         function GetMaxX: integer;
         function GetMaxY: integer;
         function GetMaxZ: integer;
         function GetBitmapPixelColor(_Position: longword):longword; virtual; abstract;
         function GetRPixelColor(_Position: longword):byte; virtual; abstract;
         function GetGPixelColor(_Position: longword):byte; virtual; abstract;
         function GetBPixelColor(_Position: longword):byte; virtual; abstract;
         function GetAPixelColor(_Position: longword):byte; virtual; abstract;
         function GetRedPixelColor(_x,_y,_z: integer):single; virtual; abstract;
         function GetGreenPixelColor(_x,_y,_z: integer):single; virtual; abstract;
         function GetBluePixelColor(_x,_y,_z: integer):single; virtual; abstract;
         function GetAlphaPixelColor(_x,_y,_z: integer):single; virtual; abstract;
         function GetName: String;
         // Sets
         procedure SetDataLength(_Size: longword); virtual;
         procedure SetBitmapPixelColor(_Position, _Color: longword); virtual; abstract;
         procedure SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte); virtual; abstract;
         procedure SetRedPixelColor(_x,_y,_z: integer; _value:single); virtual; abstract;
         procedure SetGreenPixelColor(_x,_y,_z: integer; _value:single); virtual; abstract;
         procedure SetBluePixelColor(_x,_y,_z: integer; _value:single); virtual; abstract;
         procedure SetAlphaPixelColor(_x,_y,_z: integer; _value:single); virtual; abstract;
         procedure SetName(const _Name:String);
         procedure UpdateSizeDataCaching;
         // Copies
         procedure CopyData(const _Data: TAbstractDataSet; _DataXSize, _DataYSize, _DataZSize: longword); virtual; abstract;
      public
         // constructors and destructors
         constructor Create(_XSize, _YSize, _ZSize: integer); overload;
         constructor CreateFromBitmap(const _Bitmap:TBitmap);
         constructor Create(const _Source: TAbstract3DVolumeData); overload;
         constructor CreateFromRGBA(const _Data:Pointer; _Width, _Height: integer);
         constructor CreateFromGL_RGBA(const _Data:Pointer; _Width, _Height: integer);
         destructor Destroy; override;
         procedure Clear;
         // I/O
         procedure LoadFromBitmap(const _Bitmap:TBitmap);
         procedure LoadRGBA(const _Data:Pointer; _Width, _Height: integer);
         procedure LoadGL_RGBA(const _Data:Pointer; _Width, _Height: integer);
         function SaveToBitmap:TBitmap;
         function SaveToRGBA:AUInt32;
         function SaveToGL_RGBA:AUInt32;
         // Gets
         function isPixelValid(_x, _y, _z: integer):boolean;
         function GetOpenGLFormat:TGLInt; virtual;
         // Sets
         procedure Resize(_XSize,_YSize,_ZSize: longword);
         procedure SetSize(_XSize,_YSize,_ZSize: longword);
         // Copies
         procedure Assign(const _Source: TAbstract3DVolumeData); virtual;
         // Misc
         procedure ScaleBy(_Value: single); virtual; abstract;
         procedure Invert; virtual; abstract;
         // properties
         property XSize:integer read GetXSize;
         property YSize:integer read GetYSize;
         property ZSize:integer read GetZSize;
         property MaxX:integer read GetMaxX;
         property MaxY:integer read GetMaxY;
         property MaxZ:integer read GetMaxZ;
         property Name:String read GetName write SetName;
         property Red[_x,_y,_z: integer]:single read GetRedPixelColor write SetRedPixelColor;
         property Green[_x,_y,_z: integer]:single read GetGreenPixelColor write SetGreenPixelColor;
         property Blue[_x,_y,_z: integer]:single read GetBluePixelColor write SetBluePixelColor;
         property Alpha[_x,_y,_z: integer]:single read GetAlphaPixelColor write SetAlphaPixelColor;
   end;

implementation

constructor TAbstract3DVolumeData.Create(_XSize, _YSize, _ZSize: integer);
begin
   Initialize;
   FXSize := _XSize;
   FYSize := _YSize;
   FZSize := _ZSize;
   UpdateSizeDataCaching;
   SetDataLength(FYxXSize*FZSize);
end;

constructor TAbstract3DVolumeData.CreateFromBitmap(const _Bitmap: TBitmap);
begin
   Initialize;
   LoadBitmap(_Bitmap);
end;

constructor TAbstract3DVolumeData.Create(const _Source: TAbstract3DVolumeData);
begin
   Initialize;
   Assign(_Source);
end;

constructor TAbstract3DVolumeData.CreateFromRGBA(const _Data:Pointer; _Width, _Height: integer);
begin
   Initialize;
   LoadRGBA(_Data,_Width,_Height);
end;

constructor TAbstract3DVolumeData.CreateFromGL_RGBA(const _Data:Pointer; _Width, _Height: integer);
begin
   Initialize;
   LoadGL_RGBA(_Data,_Width,_Height);
end;


destructor TAbstract3DVolumeData.Destroy;
begin
   FData.Free;
   inherited Destroy;
end;

procedure TAbstract3DVolumeData.Clear;
begin
   SetDataLength(0);
   FXSize := 0;
   FYSize := 0;
   FZSize := 0;
   FYxXSize := 0;
end;

procedure TAbstract3DVolumeData.Initialize;
begin
   FData := TAbstractDataSet.Create;
end;

// I/O
procedure TAbstract3DVolumeData.LoadFromBitmap(const _Bitmap:TBitmap);
begin
   Clear;
   LoadBitmap(_Bitmap);
end;

// To be done
procedure TAbstract3DVolumeData.LoadBitmap(const _Bitmap:TBitmap);
{
var
   x, y: integer;
   Value,Position: Longword;
   Line: Pointer;
}
begin
{
   if (_Bitmap <> nil) then
   begin
      FXSize := _Bitmap.Width;
      FYSize := _Bitmap.Height;
      SetDataLength(FXSize*FYSize);
      _Bitmap.PixelFormat := pf32bit;
      for y := 0 to FYSize - 1 do
      begin
         Line := _Bitmap.ScanLine[y];
         Position := (y * FXSize);
         for x := 0 to FXSize - 1 do
         begin
            Value := Longword(Line^);
            SetBitmapPixelColor(Position,Value);
            Line := Pointer(longword(Line) + 4);
            inc(Position);
         end;
      end;
   end
   else
   begin
      FXSize := 0;
      FYSize := 0;
      SetDataLength(0);
   end;
}
end;

// To be done.
procedure TAbstract3DVolumeData.LoadRGBA(const _Data:Pointer; _Width, _Height: integer);
{
var
   x, DataLength, Position: integer;
   Data,GData,BData,AData: PByte;
}
begin
{
   if Assigned(_Data) then
   begin
      FXSize := _Width;
      FYSize := _Height;
      DataLength := FXSize*FYSize;
      SetDataLength(DataLength);
      Position := 0;
      Data := _Data;
      for x := 1 to DataLength do
      begin
         GData := PByte(Cardinal(Data) + 1);
         BData := PByte(Cardinal(Data) + 2);
         AData := PByte(Cardinal(Data) + 3);
         SetRGBAPixelColor(Position,Data^,GData^,BData^,AData^);
         inc(Position);
         Data := PByte(Cardinal(Data) + 4);
      end;
   end
   else
   begin
      FXSize := 0;
      FYSize := 0;
      SetDataLength(0);
   end;
}
end;

// Same as the previous function, except that it swaps Y.
// To be done.
procedure TAbstract3DVolumeData.LoadGL_RGBA(const _Data:Pointer; _Width, _Height: integer);
{
var
   x, y, Position,DataPosition: integer;
   Data,GData,BData,AData: PByte;
}
begin
{
   if Assigned(_Data) then
   begin
      FXSize := _Width;
      FYSize := _Height;
      SetDataLength(FXSize*FYSize);
      Data := _Data;
      for y := FYSize - 1 downto 0 do
      begin
         Position := (y * FXSize);
         for x := 0 to FXSize - 1 do
         begin
            GData := PByte(Cardinal(Data) + 1);
            BData := PByte(Cardinal(Data) + 2);
            AData := PByte(Cardinal(Data) + 3);
            SetRGBAPixelColor(Position,Data^,GData^,BData^,AData^);
            inc(Position);
            Data := PByte(Cardinal(Data) + 4);
         end;
      end;
   end
   else
   begin
      FXSize := 0;
      FYSize := 0;
      SetDataLength(0);
   end;
}
end;

// To be done...
function TAbstract3DVolumeData.SaveToBitmap:TBitmap;
{
var
   x, y: integer;
   Position: Longword;
   Line: ^Longword;
}
begin
{
   Result := TBitmap.Create;
   Result.Width := FXSize;
   Result.Height := FYSize;
   Result.PixelFormat := pf32bit;
   for y := 0 to FYSize - 1 do
   begin
      Line := Result.ScanLine[y];
      Position := (y * FXSize);
      for x := 0 to FXSize - 1 do
      begin
         Line^ := GetBitmapPixelColor(Position);
         inc(Line);
         inc(Position);
      end;
   end;
}
   Result := nil;
end;

// To be done...
function TAbstract3DVolumeData.SaveToRGBA:AUInt32;
{
var
   DataLength, x : Integer;
}
begin
{
   DataLength := FXSize*FYSize;
   SetLength(Result,DataLength);
   for x := 0 to High(Result) do
   begin
      Result[x] := GetRPixelColor(x) + (GetGPixelColor(x) shl 8) + (GetBPixelColor(x) shl 16) + (GetAPixelColor(x) shl 24);
   end;
}
end;

// To be done...
function TAbstract3DVolumeData.SaveToGL_RGBA:AUInt32;
{
var
   DataLength, x,y,yRes, PositionImg,PositionRes : Integer;
}
begin
{
   DataLength := FXSize*FYSize;
   SetLength(Result,DataLength);
   yRes := 0;
   for y := (FYSize - 1) downto 0 do
   begin
      PositionImg := y * FXSize;
      PositionRes := yRes * FXSize;
      for x := 0 to FXSize - 1 do
      begin
         Result[PositionRes] := GetRPixelColor(PositionImg) + (GetGPixelColor(PositionImg) shl 8) + (GetBPixelColor(PositionImg) shl 16) + (GetAPixelColor(PositionImg) shl 24);
         inc(PositionImg);
         inc(PositionRes);
      end;
      inc(yRes);
   end;
}
end;

// Gets
function TAbstract3DVolumeData.GetXSize: integer;
begin
   Result := FXSize;
end;

function TAbstract3DVolumeData.GetYSize: integer;
begin
   Result := FYSize;
end;

function TAbstract3DVolumeData.GetZSize: integer;
begin
   Result := FZSize;
end;

function TAbstract3DVolumeData.GetMaxX: integer;
begin
   Result := FMaxX;
end;

function TAbstract3DVolumeData.GetMaxY: integer;
begin
   Result := FMaxY;
end;

function TAbstract3DVolumeData.GetMaxZ: integer;
begin
   Result := FMaxZ;
end;

function TAbstract3DVolumeData.GetName: String;
begin
   Result := FName;
end;

function TAbstract3DVolumeData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGBA;
end;


function TAbstract3DVolumeData.isPixelValid(_x, _y, _z: integer):boolean;
begin
   Result := (_x >= 0) and (_y >= 0) and (_z >= 0) and (_x < FXSize) and (_y < FYSize) and (_z < FZSize);
end;

// Sets
procedure TAbstract3DVolumeData.SetName(const _Name:String);
begin
   FName := CopyString(_Name);
end;

procedure TAbstract3DVolumeData.SetDataLength(_Size: Cardinal);
begin
   FData.Length := _Size;
end;

procedure TAbstract3DVolumeData.Resize(_XSize,_YSize,_ZSize: longword);
var
   OldData: TAbstractDataSet;
   OldXSize,OldYSize,OldZSize: longword;
begin
   OldData := FData;
   Initialize;
   SetDataLength(_XSize * _YSize * _ZSize);
   OldXSize := FXSize;
   OldYSize := FYSize;
   OldZSize := FZSize;
   FXSize := _XSize;
   FYSize := _YSize;
   FZSize := _ZSize;
   UpdateSizeDataCaching;
   // Now we copy the data from OldData to the new FData.
   CopyData(OldData,OldXSize,OldYSize,OldZSize);
   OldData.Free;
end;

procedure TAbstract3DVolumeData.UpdateSizeDataCaching;
begin
   FYxXSize := FYSize * FXSize;
   FMaxX := FXSize - 1;
   FMaxY := FYSize - 1;
   FMaxZ := FZSize - 1;
end;

procedure TAbstract3DVolumeData.SetSize(_XSize,_YSize,_ZSize: longword);
begin
   FData.Free;
   Initialize;
   SetDataLength(_XSize * _YSize * _ZSize);
   FXSize := _XSize;
   FYSize := _YSize;
   FZSize := _ZSize;
   UpdateSizeDataCaching;
end;

// Copies
procedure TAbstract3DVolumeData.Assign(const _Source: TAbstract3DVolumeData);
begin
   Clear;
   FXSize := _Source.GetXSize;
   FYSize := _Source.GetYSize;
   FZSize := _Source.GetZSize;
   UpdateSizeDataCaching;
   FName := CopyString(_Source.FName);
   FData.Assign(_Source.FData);
end;

end.
