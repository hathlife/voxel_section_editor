unit ClassTextureGenerator;

interface

uses GLConstants, BasicDataTypes, Windows, Graphics, BasicFunctions, SysUtils,
   Math3d, ClassTriangleFiller;

type
   CTextureGenerator = class
      private
         // Painting procedures
         function GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
         procedure FixBilinearBorders(var _Bitmap: TBitmap; var _AlphaMap: TByteMap);
         function GenerateHeightMapBuffer(const _DiffuseMap: TBitmap): TByteMap;
      public
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(_TextureAngle: single); overload;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Generate Textures
         function GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer; var _AlphaMap: TByteMap): TBitmap;
         function GenerateNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
         function GenerateNormalWithHeightMapTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
         function GenerateHeightMap(const _DiffuseMap: TBitmap): TBitmap;
         // Generate Textures step by step
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer); overload;
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; _Size: integer); overload;
         procedure PaintMeshDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
         procedure PaintMeshNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
         procedure PaintMeshBumpMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; const _DiffuseMap: TBitmap);
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer); overload;
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer); overload;
         function GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _AlphaMap: TByteMap): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer): TBitmap; overload;
         function GetBumpMapTexture(const _DiffuseMap: TBitmap): TBitmap;
   end;


implementation

constructor CTextureGenerator.Create;
begin
   Initialize;
end;

constructor CTextureGenerator.Create(_TextureAngle : single);
begin
   Initialize;
end;

destructor CTextureGenerator.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTextureGenerator.Initialize;
begin
   // do nothing
end;

procedure CTextureGenerator.Clear;
begin
   // do nothing
end;

procedure CTextureGenerator.Reset;
begin
   Clear;
   Initialize;
end;

// Painting procedures
procedure CTextureGenerator.SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer);
var
   x,y : integer;
begin
   SetLength(_Buffer,_Size,_Size);
   SetLength(_WeightBuffer,_Size,_Size);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer) to High(_Buffer) do
      begin
         _Buffer[x,y].X := 0;
         _Buffer[x,y].Y := 0;
         _Buffer[x,y].Z := 0;
         _Buffer[x,y].W := 0;
         _WeightBuffer[x,y] := 0;
      end;
   end;
end;

procedure CTextureGenerator.SetupFrameBuffer(var _Buffer: T2DFrameBuffer; _Size: integer);
var
   x,y : integer;
begin
   SetLength(_Buffer,_Size,_Size);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer) to High(_Buffer) do
      begin
         _Buffer[x,y].X := 0;
         _Buffer[x,y].Y := 0;
         _Buffer[x,y].Z := 0;
         _Buffer[x,y].W := 0;
      end;
   end;
end;

procedure CTextureGenerator.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
var
   x : integer;
begin
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      SetLength(_Buffer[x],0);
      SetLength(_WeightBuffer[x],0);
   end;
   SetLength(_Buffer,0);
   SetLength(_WeightBuffer,0);
end;

procedure CTextureGenerator.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer);
var
   x : integer;
begin
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      SetLength(_Buffer[x],0);
   end;
   SetLength(_Buffer,0);
end;

function CTextureGenerator.GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y : integer;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Transparent := false;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   SetLength(_AlphaMap,Result.Width,Result.Width);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            if ((_Buffer[x,y].X  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].X := 0; //_Buffer[x,y].X * -1;
            if (abs(_Buffer[x,y].X  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].X := _WeightBuffer[x,y];
            if ((_Buffer[x,y].Y  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].Y := 0; //_Buffer[x,y].Y * -1;
            if (abs(_Buffer[x,y].Y  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].Y := _WeightBuffer[x,y];
            if ((_Buffer[x,y].Z  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].Z := 0; //_Buffer[x,y].Z * -1;
            if (abs(_Buffer[x,y].Z  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].Z := _WeightBuffer[x,y];
            if ((_Buffer[x,y].W  / _WeightBuffer[x,y]) < 0) then
               _Buffer[x,y].W := 0; //_Buffer[x,y].W * -1;
            if (abs(_Buffer[x,y].W  / _WeightBuffer[x,y]) > 1) then
               _Buffer[x,y].W := _WeightBuffer[x,y];

            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Trunc((_Buffer[x,y].X / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].Y / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].Z / _WeightBuffer[x,y]) * 255));
            _AlphaMap[x,Result.Height - y] := Trunc(((_Buffer[x,y].W / _WeightBuffer[x,y])) * 255);
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;//$888888;
            _AlphaMap[x,Result.Height - y] := C_TRP_INVISIBLE;
         end;
      end;
   end;
   FixBilinearBorders(Result,_AlphaMap);
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Normal.X := _Buffer[x,y].X / _WeightBuffer[x,y];
            Normal.Y := _Buffer[x,y].Y / _WeightBuffer[x,y];
            Normal.Z := _Buffer[x,y].Z / _WeightBuffer[x,y];
            if abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0 then
               Normal.Z := 1;
            Normalize(Normal);
            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
      end;
   end;
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Normal.X := _Buffer[x,y].X / _WeightBuffer[x,y];
            Normal.Y := _Buffer[x,y].Y / _WeightBuffer[x,y];
            Normal.Z := _Buffer[x,y].Z / _WeightBuffer[x,y];
            if abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0 then
               Normal.Z := 1;
            Normalize(Normal);
            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
      end;
   end;
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   SetLength(_AlphaMap,Result.Width,Result.Width);
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         Normal.X := _Buffer[x,y].X;
         Normal.Y := _Buffer[x,y].Y;
         Normal.Z := _Buffer[x,y].Z;
         if (abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0) then
            Normal.Z := 1;
         Normalize(Normal);
         Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
         _AlphaMap[x,Result.Height - y] := C_TRP_OPAQUE;
      end;
   end;
end;

function CTextureGenerator.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer): TBitmap;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         Normal.X := _Buffer[x,y].X;
         Normal.Y := _Buffer[x,y].Y;
         Normal.Z := _Buffer[x,y].Z;
         if (abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0) then
            Normal.Z := 1;
         Normalize(Normal);
         Result.Canvas.Pixels[x,Result.Height - y] := RGB(Round((1 + Normal.X) * 127.5),Round((1 + Normal.Y) * 127.5),Round((1 + Normal.Z) * 127.5));
      end;
   end;
end;

function CTextureGenerator.GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
var
   x,y : integer;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := RGBA(Round((1 + (_Buffer[x,y].X / _WeightBuffer[x,y])) * 127.5),Round((1 + (_Buffer[x,y].Y / _WeightBuffer[x,y])) * 127.5),Round((1 + (_Buffer[x,y].Z / _WeightBuffer[x,y])) * 127.5),Round((_Buffer[x,y].W / _WeightBuffer[x,y]) * 255));
         end
         else
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := 0;
         end;
      end;
   end;
end;

function CTextureGenerator.GenerateDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer; var _AlphaMap: TByteMap): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
   Filler: CTriangleFiller;
begin
   Size := GetPow2Size(_Size);
   Filler := CTriangleFiller.Create;
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      Filler.PaintTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsColours[_Faces[(i * _VerticesPerFace)]],_VertsColours[_Faces[(i * _VerticesPerFace)+1]],_VertsColours[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Result := GetColouredBitmapFromFrameBuffer(Buffer,WeightBuffer,_AlphaMap);
//   Result.SaveToFile('test.bmp');
   DisposeFrameBuffer(Buffer,WeightBuffer);
   Filler.Free;
end;

function CTextureGenerator.GenerateNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
   Filler: CTriangleFiller;
begin
   Size := GetPow2Size(_Size);
   Filler := CTriangleFiller.Create;
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      Filler.PaintTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsNormals[_Faces[(i * _VerticesPerFace)]],_VertsNormals[_Faces[(i * _VerticesPerFace)+1]],_VertsNormals[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Result := GetPositionedBitmapFromFrameBuffer(Buffer,WeightBuffer);
   DisposeFrameBuffer(Buffer,WeightBuffer);
   Filler.Free;
end;

function CTextureGenerator.GenerateNormalWithHeightMapTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _VertsNormals: TAVector3f; const _TextCoords: TAVector2f; _VerticesPerFace, _Size: integer): TBitmap;
var
   Buffer: T2DFrameBuffer;
   WeightBuffer: TWeightBuffer;
   Size,i,LastFace : cardinal;
   D1, D2, D3 : TVector4f;
   Filler: CTriangleFiller;
begin
   Size := GetPow2Size(_Size);
   Filler := CTriangleFiller.Create;
   SetupFrameBuffer(Buffer,WeightBuffer,Size);
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   for i := 0 to LastFace do
   begin
      D1.X := _VertsNormals[_Faces[(i * _VerticesPerFace)]].X;
      D1.Y := _VertsNormals[_Faces[(i * _VerticesPerFace)]].Y;
      D1.Z := _VertsNormals[_Faces[(i * _VerticesPerFace)]].Z;
      D1.W := (_VertsColours[_Faces[(i * _VerticesPerFace)]].X * _VertsColours[_Faces[(i * _VerticesPerFace)]].Y * _VertsColours[_Faces[(i * _VerticesPerFace)]].Z);
      D2.X := _VertsNormals[_Faces[(i * _VerticesPerFace)+1]].X;
      D2.Y := _VertsNormals[_Faces[(i * _VerticesPerFace)+1]].Y;
      D2.Z := _VertsNormals[_Faces[(i * _VerticesPerFace)+1]].Z;
      D2.W := (_VertsColours[_Faces[(i * _VerticesPerFace)+1]].X * _VertsColours[_Faces[(i * _VerticesPerFace)+1]].Y * _VertsColours[_Faces[(i * _VerticesPerFace)+1]].Z);
      D3.X := _VertsNormals[_Faces[(i * _VerticesPerFace)+2]].X;
      D3.Y := _VertsNormals[_Faces[(i * _VerticesPerFace)+2]].Y;
      D3.Z := _VertsNormals[_Faces[(i * _VerticesPerFace)+2]].Z;
      D3.W := (_VertsColours[_Faces[(i * _VerticesPerFace)+2]].X * _VertsColours[_Faces[(i * _VerticesPerFace)+2]].Y * _VertsColours[_Faces[(i * _VerticesPerFace)+2]].Z);

      Filler.PaintTriangle(Buffer,WeightBuffer,_TextCoords[_Faces[(i * _VerticesPerFace)]],_TextCoords[_Faces[(i * _VerticesPerFace)+1]],_TextCoords[_Faces[(i * _VerticesPerFace)+2]],D1,D2,D3);
   end;
   Result := GetHeightPositionedBitmapFromFrameBuffer(Buffer,WeightBuffer);
   DisposeFrameBuffer(Buffer,WeightBuffer);
   Filler.Free;
end;

function CTextureGenerator.GenerateHeightMap(const _DiffuseMap: TBitmap): TBitmap;
var
   x,y: integer;
   r,g,b: single;
   h : byte;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Transparent := false;
   Result.Width := _DiffuseMap.Width;
   Result.Height := _DiffuseMap.Height;
   for x := 0 to (Result.Width - 1) do
   begin
      for y := 0 to (Result.Height - 1) do
      begin
         r := GetRValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         g := GetGValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         b := GetBValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         // Convert to YIQ
         h := Round((1 - (0.299 * r) + (0.587 * g) + (0.114 * b)) * 255) and $FF;
         Result.Canvas.Pixels[x,y] := RGB(h,h,h);
      end;
   end;
end;

function CTextureGenerator.GenerateHeightMapBuffer(const _DiffuseMap: TBitmap): TByteMap;
var
   x,y,Size : integer;
   r,g,b: real;
begin
   // Build height map and visited map
   Size := _DiffuseMap.Width;
   SetLength(Result,Size,Size);
   for x := Low(Result) to High(Result) do
   begin
      for y := Low(Result[x]) to High(Result[x]) do
      begin
         r := GetRValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         g := GetGValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         b := GetBValue(_DiffuseMap.Canvas.Pixels[x,y]) / 255;
         // Convert to YIQ
         Result[x,y] := Round((1 - (0.299 * r) + (0.587 * g) + (0.114 * b)) * 255) and $FF;
      end;
   end;
end;


procedure CTextureGenerator.PaintMeshDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
var
   i,LastFace : cardinal;
   Filler: CTriangleFiller;
begin
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   Filler := CTriangleFiller.Create;
   for i := 0 to LastFace do
   begin
      Filler.PaintTriangle(_Buffer,_WeightBuffer,_TexCoords[_Faces[(i * _VerticesPerFace)]],_TexCoords[_Faces[(i * _VerticesPerFace)+1]],_TexCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsColours[_Faces[(i * _VerticesPerFace)]],_VertsColours[_Faces[(i * _VerticesPerFace)+1]],_VertsColours[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Filler.Free;
end;

procedure CTextureGenerator.PaintMeshNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
var
   i,LastFace : cardinal;
   Filler: CTriangleFiller;
begin
   LastFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   Filler := CTriangleFiller.Create;
   for i := 0 to LastFace do
   begin
      Filler.PaintTriangle(_Buffer,_WeightBuffer,_TexCoords[_Faces[(i * _VerticesPerFace)]],_TexCoords[_Faces[(i * _VerticesPerFace)+1]],_TexCoords[_Faces[(i * _VerticesPerFace)+2]],_VertsNormals[_Faces[(i * _VerticesPerFace)]],_VertsNormals[_Faces[(i * _VerticesPerFace)+1]],_VertsNormals[_Faces[(i * _VerticesPerFace)+2]]);
   end;
   Filler.Free;
end;

// This is the original attempt painting faces.
procedure CTextureGenerator.PaintMeshBumpMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: T2DFrameBuffer; const _DiffuseMap: TBitmap);
var
   HeightMap : TByteMap;
   Face : integer;
   Filler: CTriangleFiller;
begin
   // Build height map and visited map
   Filler := CTriangleFiller.Create;
   HeightMap := GenerateHeightMapBuffer(_DiffuseMap);
   // Now, we'll check each face.
   Face := 0;
   while Face < High(_Faces) do
   begin
      // Paint the face here.
      Filler.PaintFlatTriangleFromHeightMap(_Buffer,HeightMap,_TexCoords[_Faces[Face]],_TexCoords[_Faces[Face+1]],_TexCoords[_Faces[Face+2]]);

      // Go to next face.
      inc(Face,_VerticesPerFace);
   end;
   Filler.Free;
end;

// This is the latest attempt as a simple image processsing operation.
function CTextureGenerator.GetBumpMapTexture(const _DiffuseMap: TBitmap): TBitmap;
var
   HeightMap : TByteMap;
   x,y,Size : integer;
   Filler: CTriangleFiller;
begin
   // Build height map and visited map
   Filler := CTriangleFiller.Create;
   HeightMap := GenerateHeightMapBuffer(_DiffuseMap);
   Size := High(HeightMap)+1;
   Result := TBitmap.Create;
   Result.PixelFormat := pf32bit;
   Result.Transparent := false;
   Result.Width := Size;
   Result.Height := Size;
   // Now, we'll check each face.
   for x := Low(HeightMap) to High(HeightMap) do
      for y := Low(HeightMap[x]) to High(HeightMap[x]) do
      begin
         Filler.PaintBumpValueAtFrameBuffer(Result,HeightMap,X,Y,Size);
      end;
   Filler.Free;
end;


// This procedure fixes white/black borders in the edge of each partition.
procedure CTextureGenerator.FixBilinearBorders(var _Bitmap: TBitmap; var _AlphaMap: TByteMap);
var
   x,y,i,k,mini,maxi,mink,maxk,r,g,b,ri,gi,bi,sum : integer;
   AlphaMapBackup: TByteMap;
begin
   SetLength(AlphaMapBackup,High(_AlphaMap)+1,High(_AlphaMap)+1);
   for x := Low(_AlphaMap) to High(_AlphaMap) do
   begin
      for y := Low(_AlphaMap[x]) to High(_AlphaMap[x]) do
      begin
         AlphaMapBackup[x,y] := _AlphaMap[x,y];
      end;
   end;
   for x := Low(_AlphaMap) to High(_AlphaMap) do
   begin
      for y := Low(_AlphaMap[x]) to High(_AlphaMap[x]) do
      begin
         if AlphaMapBackup[x,y] = C_TRP_RGB_INVISIBLE then
         begin
            mini := x - 1;
            if mini < 0 then
               mini := 0;
            maxi := x + 1;
            if maxi > High(_AlphaMap) then
               maxi := High(_AlphaMap);
            mink := y - 1;
            if mink < 0 then
               mink := 0;
            maxk := y + 1;
            if maxk > High(_AlphaMap) then
               maxk := High(_AlphaMap);

            r := 0;
            g := 0;
            b := 0;
            sum := 0;
            for i := mini to maxi do
               for k := mink to maxk do
               begin
                  if AlphaMapBackup[i,k] <> C_TRP_RGB_INVISIBLE then
                  begin
                     ri := GetRValue(_Bitmap.Canvas.Pixels[i,k]);
                     gi := GetGValue(_Bitmap.Canvas.Pixels[i,k]);
                     bi := GetBValue(_Bitmap.Canvas.Pixels[i,k]);
                     r := r + ri;
                     g := g + gi;
                     b := b + bi;
                     inc(sum);
                  end;
               end;
            if (r + g + b) > 0 then
               _AlphaMap[x,y] := C_TRP_RGB_OPAQUE;
            if sum > 0 then
               _Bitmap.Canvas.Pixels[x,y] := RGB(r div sum, g div sum, b div sum);
         end;
      end;
   end;
   // Free memory
   for i := Low(_AlphaMap) to High(_AlphaMap) do
   begin
      SetLength(AlphaMapBackup[i],0);
   end;
   SetLength(AlphaMapBackup,0);
end;


end.
