unit Abstract2DImageData;

interface

uses Windows, Graphics, BasicFunctions, BasicDataTypes, AbstractDataSet, dglOpenGL;

type
   TAbstract2DImageData = class
      protected
         FData: TAbstractDataSet;
         FXSize, FYSize: integer;
         FName: string;
         // Constructors and Destructors
         procedure Initialize; virtual;
         // I/O
         procedure LoadBitmap(const _Bitmap:TBitmap);
         // Gets
         function GetXSize: integer;
         function GetYSize: integer;
         function GetMaxX: integer;
         function GetMaxY: integer;
         function GetBitmapPixelColor(_Position: longword):longword; virtual; abstract;
         function GetRPixelColor(_Position: longword):byte; virtual; abstract;
         function GetGPixelColor(_Position: longword):byte; virtual; abstract;
         function GetBPixelColor(_Position: longword):byte; virtual; abstract;
         function GetAPixelColor(_Position: longword):byte; virtual; abstract;
         function GetRedPixelColor(_x,_y: integer):single; virtual; abstract;
         function GetGreenPixelColor(_x,_y: integer):single; virtual; abstract;
         function GetBluePixelColor(_x,_y: integer):single; virtual; abstract;
         function GetAlphaPixelColor(_x,_y: integer):single; virtual; abstract;
         function GetName: String;
         // Sets
         procedure SetDataLength(_Size: longword); virtual;
         procedure SetBitmapPixelColor(_Position, _Color: longword); virtual; abstract;
         procedure SetRGBAPixelColor(_Position: integer; _r, _g, _b, _a: byte); virtual; abstract;
         procedure SetRedPixelColor(_x,_y: integer; _value:single); virtual; abstract;
         procedure SetGreenPixelColor(_x,_y: integer; _value:single); virtual; abstract;
         procedure SetBluePixelColor(_x,_y: integer; _value:single); virtual; abstract;
         procedure SetAlphaPixelColor(_x,_y: integer; _value:single); virtual; abstract;
         procedure SetName(const _Name:String);
      public
         // constructors and destructors
         constructor Create(_XSize, _YSize: integer); overload;
         constructor CreateFromBitmap(const _Bitmap:TBitmap);
         constructor Create(const _Source: TAbstract2DImageData); overload;
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
         function isPixelValid(_x, _y: integer):boolean;
         function GetOpenGLFormat:TGLInt; virtual;
         // Copies
         procedure Assign(const _Source: TAbstract2DImageData); virtual;
         // Misc
         procedure ScaleBy(_Value: single); virtual; abstract;
         procedure Invert; virtual; abstract;
         // properties
         property XSize:integer read GetXSize;
         property YSize:integer read GetYSize;
         property MaxX:integer read GetMaxX;
         property MaxY:integer read GetMaxY;
         property Name:String read GetName write SetName;
         property Red[_x,_y: integer]:single read GetRedPixelColor write SetRedPixelColor;
         property Green[_x,_y: integer]:single read GetGreenPixelColor write SetGreenPixelColor;
         property Blue[_x,_y: integer]:single read GetBluePixelColor write SetBluePixelColor;
         property Alpha[_x,_y: integer]:single read GetAlphaPixelColor write SetAlphaPixelColor;
   end;

implementation

constructor TAbstract2DImageData.Create(_XSize: Integer; _YSize: Integer);
begin
   Initialize;
   FXSize := _XSize;
   FYSize := _YSize;
   SetDataLength(FXSize*FYSize);
end;

constructor TAbstract2DImageData.CreateFromBitmap(const _Bitmap: TBitmap);
begin
   Initialize;
   LoadBitmap(_Bitmap);
end;

constructor TAbstract2DImageData.Create(const _Source: TAbstract2DImageData);
begin
   Initialize;
   Assign(_Source);
end;

constructor TAbstract2DImageData.CreateFromRGBA(const _Data:Pointer; _Width, _Height: integer);
begin
   Initialize;
   LoadRGBA(_Data,_Width,_Height);
end;

constructor TAbstract2DImageData.CreateFromGL_RGBA(const _Data:Pointer; _Width, _Height: integer);
begin
   Initialize;
   LoadGL_RGBA(_Data,_Width,_Height);
end;


destructor TAbstract2DImageData.Destroy;
begin
   FData.Free;
   inherited Destroy;
end;

procedure TAbstract2DImageData.Clear;
begin
   SetDataLength(0);
   FXSize := 0;
   FYSize := 0;
end;

procedure TAbstract2DImageData.Initialize;
begin
   FData := TAbstractDataSet.Create;
end;

// I/O
procedure TAbstract2DImageData.LoadFromBitmap(const _Bitmap:TBitmap);
begin
   Clear;
   LoadBitmap(_Bitmap);
end;

procedure TAbstract2DImageData.LoadBitmap(const _Bitmap:TBitmap);
var
   x, y: integer;
   Value,Position: Longword;
   Line: Pointer;
begin
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
end;

procedure TAbstract2DImageData.LoadRGBA(const _Data:Pointer; _Width, _Height: integer);
var
   x, DataLength, Position: integer;
   Data,GData,BData,AData: PByte;
begin
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
end;

// Same as the previous function, except that it swaps Y.
procedure TAbstract2DImageData.LoadGL_RGBA(const _Data:Pointer; _Width, _Height: integer);
var
   x, y, Position: integer;
   Data,GData,BData,AData: PByte;
begin
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
end;

function TAbstract2DImageData.SaveToBitmap:TBitmap;
var
   x, y: integer;
   Position: Longword;
   Line: ^Longword;
begin
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
end;

function TAbstract2DImageData.SaveToRGBA:AUInt32;
var
   DataLength, x : Integer;
begin
   DataLength := FXSize*FYSize;
   SetLength(Result,DataLength);
   for x := 0 to High(Result) do
   begin
      Result[x] := GetRPixelColor(x) + (GetGPixelColor(x) shl 8) + (GetBPixelColor(x) shl 16) + (GetAPixelColor(x) shl 24);
   end;
end;

function TAbstract2DImageData.SaveToGL_RGBA:AUInt32;
var
   DataLength, x,y,yRes, PositionImg,PositionRes : Integer;
begin
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
end;

// Gets
function TAbstract2DImageData.GetXSize: integer;
begin
   Result := FXSize;
end;

function TAbstract2DImageData.GetYSize: integer;
begin
   Result := FYSize;
end;

function TAbstract2DImageData.GetMaxX: integer;
begin
   Result := FXSize - 1;
end;

function TAbstract2DImageData.GetMaxY: integer;
begin
   Result := FYSize - 1;
end;

function TAbstract2DImageData.GetName: String;
begin
   Result := FName;
end;

function TAbstract2DImageData.GetOpenGLFormat:TGLInt;
begin
   Result := GL_RGBA;
end;


function TAbstract2DImageData.isPixelValid(_x, _y: integer):boolean;
begin
   if (_x >= 0) and (_y >= 0) and (_x < FXSize) and (_y < FYSize) then
   begin
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;

// Sets
procedure TAbstract2DImageData.SetName(const _Name:String);
begin
   FName := CopyString(_Name);
end;

procedure TAbstract2DImageData.SetDataLength(_Size: Cardinal);
begin
   FData.Length := _Size;
end;

// Copies
procedure TAbstract2DImageData.Assign(const _Source: TAbstract2DImageData);
begin
   Clear;
   FXSize := _Source.GetXSize;
   FYSize := _Source.GetYSize;
   FName := CopyString(_Source.FName);
   FData.Assign(_Source.FData);
end;


end.
