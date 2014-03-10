unit TextureGeneratorBase;

interface

uses GLConstants, BasicMathsTypes, BasicDataTypes, Windows, Graphics, BasicFunctions, SysUtils,
   Math3d, TriangleFiller, ImageRGBAByteData, ImageGreyByteData,
   ImageRGBByteData, Abstract2DImageData, LOD;

type
   CTextureGeneratorBase = class
      protected
         FLOD: TLOD;
         FSize: integer;
         FMaterialID: integer;
         FTextureID: integer;
         // Painting procedures
         function GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
         procedure FixBilinearBorders(var _Bitmap: TBitmap; var _AlphaMap: TByteMap); overload;
         procedure FixBilinearBorders(var _ImageData: TAbstract2DImageData); overload;
         function GenerateHeightMapBuffer(const _DiffuseMap: TAbstract2DImageData): T2DImageGreyByteData;
      public
         // Constructors and Destructors
         constructor Create(var _LOD: TLOD); overload; virtual;
         constructor Create(var _LOD: TLOD; _Size, _MaterialID, _TextureID: integer); overload; virtual;
         destructor Destroy; override;
         procedure Initialize;
         procedure Reset;
         procedure Clear;
         // Execute
         procedure Execute; virtual; abstract;
         // Generate Textures step by step
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer); overload;
         procedure SetupFrameBuffer(var _Buffer: T2DFrameBuffer; _Size: integer); overload;
         procedure PaintMeshDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData);
         procedure PaintMeshNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData);
         procedure PaintMeshBumpMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; const _DiffuseMap: TAbstract2DImageData);
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer); overload;
         procedure DisposeFrameBuffer(var _Buffer: T2DFrameBuffer); overload;
         function GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
         function GetColouredImageDataFromBuffer(var _Buffer, _WeightBuffer: TAbstract2DImageData): TAbstract2DImageData;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _AlphaMap: TByteMap): TBitmap; overload;
         function GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer): TBitmap; overload;
         function GetPositionedImageDataFromBuffer(const _Buffer, _WeightBuffer: TAbstract2DImageData): TAbstract2DImageData;
         function GetBumpMapTexture(const _DiffuseMap: TAbstract2DImageData; _Scale: single = C_BUMP_DEFAULTSCALE): TAbstract2DImageData;
   end;


implementation

uses Math;

constructor CTextureGeneratorBase.Create(var _LOD: TLOD; _Size, _MaterialID, _TextureID: integer);
begin
   FLOD := _LOD;
   FSize := _Size;
   FMaterialID := _MaterialID;
   FTextureID := _TextureID;
   Initialize;
end;

constructor CTextureGeneratorBase.Create(var _LOD: TLOD);
begin
   FLOD := _LOD;
   FSize := 1024;
   FTextureID := 0;
   if FLOD <> nil then
   begin
      if High(FLOD.Mesh) >= 0 then
      begin
         FSize := FLOD.Mesh[0].GetTextureSize(0,FLOD.Mesh[0].Materials[0].GetTextureID(C_TTP_DIFFUSE));
         FTextureID := FLOD.Mesh[0].GetNextTextureID(0);
      end;
   end;
   FMaterialID := 0;
   Initialize;
end;

destructor CTextureGeneratorBase.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTextureGeneratorBase.Initialize;
begin
   // do nothing
end;

procedure CTextureGeneratorBase.Clear;
begin
   // do nothing
end;

procedure CTextureGeneratorBase.Reset;
begin
   Clear;
   Initialize;
end;

// Painting procedures
procedure CTextureGeneratorBase.SetupFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size: integer);
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

procedure CTextureGeneratorBase.SetupFrameBuffer(var _Buffer: T2DFrameBuffer; _Size: integer);
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

procedure CTextureGeneratorBase.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer);
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

procedure CTextureGeneratorBase.DisposeFrameBuffer(var _Buffer: T2DFrameBuffer);
var
   x : integer;
begin
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      SetLength(_Buffer[x],0);
   end;
   SetLength(_Buffer,0);
end;

function CTextureGeneratorBase.GetColouredBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
var
   x,y,i,j,counter : integer;
begin
   Result := TBitmap.Create;
   Result.PixelFormat := pf32Bit;
   Result.Transparent := false;
   Result.Width := High(_Buffer)+1;
   Result.Height := High(_Buffer)+1;
   SetLength(_AlphaMap,Result.Width,Result.Width);
   // First pass
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

            _Buffer[x,y].X := _Buffer[x,y].X / _WeightBuffer[x,y];
            _Buffer[x,y].Y := _Buffer[x,y].Y / _WeightBuffer[x,y];
            _Buffer[x,y].Z := _Buffer[x,y].Z / _WeightBuffer[x,y];
            //Result.Canvas.Pixels[x,Result.Height - y] := RGB(Trunc((_Buffer[x,y].X / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].Y / _WeightBuffer[x,y]) * 255),Trunc((_Buffer[x,y].Z / _WeightBuffer[x,y]) * 255));
            _AlphaMap[x,Result.Height - y] := Trunc(((_Buffer[x,y].W / _WeightBuffer[x,y])) * 255);
            _WeightBuffer[x,y] := 1;
         end
         else
         begin
            //Result.Canvas.Pixels[x,Result.Height - y] := 0;//$888888;
            _Buffer[x,y].X := 0;
            _Buffer[x,y].Y := 0;
            _Buffer[x,y].Z := 0;
            _AlphaMap[x,Result.Height - y] := C_TRP_INVISIBLE;
         end;
      end;
   end;
   // Second pass
   for x := Low(_Buffer) to High(_Buffer) do
   begin
      for y := Low(_Buffer[x]) to High(_Buffer[x]) do
      begin
         if _WeightBuffer[x,y] > 0 then
         begin
            Result.Canvas.Pixels[x,Result.Height - y] := RGB(Trunc(_Buffer[x,y].X * 255),Trunc(_Buffer[x,y].Y * 255),Trunc(_Buffer[x,y].Z * 255));
         end
         else
         begin
            counter := 0;
            for i := max(0, x - 1) to min(High(_Buffer), x + 1) do
               for j := max(0, y - 1) to min(High(_Buffer[x]), y + 1) do
               begin
                  if _WeightBuffer[i, j] = 1 then
                  begin
                     _Buffer[x,y].X := _Buffer[x,y].X + _Buffer[i,j].X;
                     _Buffer[x,y].Y := _Buffer[x,y].Y + _Buffer[i,j].Y;
                     _Buffer[x,y].Z := _Buffer[x,y].Z + _Buffer[i,j].Z;
                     inc(counter);
                  end;
               end;
            if counter > 0 then
            begin
               _Buffer[x,y].X := _Buffer[x,y].X / counter;
               _Buffer[x,y].Y := _Buffer[x,y].Y / counter;
               _Buffer[x,y].Z := _Buffer[x,y].Z / counter;
               _AlphaMap[x,Result.Height - y] := C_TRP_RGB_OPAQUE;
               Result.Canvas.Pixels[x,Result.Height - y] := RGB(Trunc(_Buffer[x,y].X * 255),Trunc(_Buffer[x,y].Y * 255),Trunc(_Buffer[x,y].Z * 255));
            end;
         end;
      end;
   end;
//   FixBilinearBorders(Result,_AlphaMap);
end;

function CTextureGeneratorBase.GetColouredImageDataFromBuffer(var _Buffer, _WeightBuffer: TAbstract2DImageData): TAbstract2DImageData;
var
   x, y, i, j, counter : integer;
begin
   Result := T2DImageRGBAByteData.Create(_Buffer.XSize,_Buffer.YSize);
   // First pass
   for x := 0 to _Buffer.MaxX do
   begin
      for y := 0 to _Buffer.MaxY do
      begin
         if _WeightBuffer.Red[x,y] > 0 then
         begin
            if ((_Buffer.Red[x,y]  / _WeightBuffer.Red[x,y]) < 0) then
               _Buffer.Red[x,y] := 0;
            if (abs(_Buffer.Red[x,y]  / _WeightBuffer.Red[x,y]) > 1) then
               _Buffer.Red[x,y] := _WeightBuffer.Red[x,y];
            if ((_Buffer.Green[x,y]  / _WeightBuffer.Red[x,y]) < 0) then
               _Buffer.Green[x,y] := 0;
            if (abs(_Buffer.Green[x,y]  / _WeightBuffer.Red[x,y]) > 1) then
               _Buffer.Green[x,y] := _WeightBuffer.Red[x,y];
            if ((_Buffer.Blue[x,y]  / _WeightBuffer.Red[x,y]) < 0) then
               _Buffer.Blue[x,y] := 0;
            if (abs(_Buffer.Blue[x,y]  / _WeightBuffer.Red[x,y]) > 1) then
               _Buffer.Blue[x,y] := _WeightBuffer.Red[x,y];
            if ((_Buffer.Alpha[x,y]  / _WeightBuffer.Red[x,y]) < 0) then
               _Buffer.Alpha[x,y] := 0;
            if (abs(_Buffer.Alpha[x,y]  / _WeightBuffer.Red[x,y]) > 1) then
               _Buffer.Alpha[x,y] := _WeightBuffer.Red[x,y];

            _Buffer.Red[x, y] := (_Buffer.Red[x,y] / _WeightBuffer.Red[x,y]);
            _Buffer.Green[x, y] := (_Buffer.Green[x,y] / _WeightBuffer.Red[x,y]);
            _Buffer.Blue[x, y] := (_Buffer.Blue[x,y] / _WeightBuffer.Red[x,y]);
            Result.Alpha[x,Result.YSize - y] := (_Buffer.Alpha[x,y] / _WeightBuffer.Red[x,y]) * 255;
            _WeightBuffer.Red[x,y] := 1;
         end
         else
         begin
            Result.Red[x,Result.YSize - y] := 0;//$888888;
            Result.Green[x,Result.YSize - y] := 0;//$888888;
            Result.Blue[x,Result.YSize - y] := 0;//$888888;
            Result.Alpha[x,Result.YSize - y] := C_TRP_INVISIBLE;
         end;
      end;
   end;
   // Second pass
   for x := 0 to _Buffer.MaxX do
   begin
      for y := 0 to _Buffer.MaxY do
      begin
         if _WeightBuffer.Red[x,y] > 0 then
         begin
            Result.Red[x,Result.YSize - y] := _Buffer.Red[x,y] * 255;
            Result.Green[x,Result.YSize - y] := _Buffer.Green[x,y] * 255;
            Result.Blue[x,Result.YSize - y] := _Buffer.Blue[x,y] * 255;
         end
         else
         begin
            counter := 0;
            for i := max(0, x - 1) to min(_Buffer.MaxX, x + 1) do
               for j := max(0, y - 1) to min(_Buffer.MaxY, y + 1) do
               begin
                  if _WeightBuffer.Red[i, j] = 1 then
                  begin
                     _Buffer.Red[x,y] := _Buffer.Red[x,y] + _Buffer.Red[i,j];
                     _Buffer.Green[x,y] := _Buffer.Green[x,y] + _Buffer.Green[i,j];
                     _Buffer.Blue[x,y] := _Buffer.Blue[x,y] + _Buffer.Blue[i,j];
                     inc(counter);
                  end;
               end;
            if counter > 0 then
            begin
               _Buffer.Red[x,y] := _Buffer.Red[x,y] / counter;
               _Buffer.Green[x,y] := _Buffer.Green[x,y] / counter;
               _Buffer.Blue[x,y] := _Buffer.Blue[x,y] / counter;
               Result.Red[x,Result.YSize - y] := _Buffer.Red[x,y] * 255;
               Result.Green[x,Result.YSize - y] := _Buffer.Green[x,y] * 255;
               Result.Blue[x,Result.YSize - y] := _Buffer.Blue[x,y] * 255;
               Result.Alpha[x,Result.YSize - y] := C_TRP_RGB_OPAQUE;
            end;
         end;
      end;
   end;

//   FixBilinearBorders(Result);
end;

function CTextureGeneratorBase.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
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

function CTextureGeneratorBase.GetPositionedImageDataFromBuffer(const _Buffer, _WeightBuffer: TAbstract2DImageData): TAbstract2DImageData;
var
   x,y : integer;
   Normal: TVector3f;
begin
   Result := T2DImageRGBByteData.Create(_Buffer.XSize,_Buffer.YSize);
   for x := 0 to _Buffer.MaxX do
   begin
      for y := 0 to _Buffer.MaxY do
      begin
         if _WeightBuffer.Red[x,y] > 0 then
         begin
            Normal.X := _Buffer.Red[x,y] / _WeightBuffer.Red[x,y];
            Normal.Y := _Buffer.Green[x,y] / _WeightBuffer.Red[x,y];
            Normal.Z := _Buffer.Blue[x,y] / _WeightBuffer.Red[x,y];
            if abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z) = 0 then
               Normal.Z := 1;
            Normalize(Normal);
            Result.Red[x,Result.YSize - y] := Round((1 + Normal.X) * 127.5);
            Result.Green[x,Result.YSize - y] := Round((1 + Normal.Y) * 127.5);
            Result.Blue[x,Result.YSize - y] := Round((1 + Normal.Z) * 127.5);
         end
         else
         begin
            Result.Red[x,Result.YSize - y] := 0;
            Result.Green[x,Result.YSize - y] := 0;
            Result.Blue[x,Result.YSize - y] := 0;
         end;
      end;
   end;
end;

function CTextureGeneratorBase.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _AlphaMap: TByteMap): TBitmap;
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

function CTextureGeneratorBase.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _AlphaMap: TByteMap): TBitmap;
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

function CTextureGeneratorBase.GetPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer): TBitmap;
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

function CTextureGeneratorBase.GetHeightPositionedBitmapFromFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer): TBitmap;
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

function CTextureGeneratorBase.GenerateHeightMapBuffer(const _DiffuseMap: TAbstract2DImageData): T2DImageGreyByteData;
var
   x,y,Size : integer;
   r,g,b: real;
begin
   // Build height map and visited map
   Size := _DiffuseMap.XSize;
   Result := T2DImageGreyByteData.Create(Size,Size);
   for x := 0 to Result.MaxX do
   begin
      for y := 0 to Result.MaxY do
      begin
         r := _DiffuseMap.Red[x,y] / 255;
         g := _DiffuseMap.Green[x,y] / 255;
         b := _DiffuseMap.Blue[x,y] / 255;
         // Convert to YIQ
         Result.Red[x,y] := Round((1 - (0.299 * r) + (0.587 * g) + (0.114 * b)) * 255) and $FF;
      end;
   end;
end;


procedure CTextureGeneratorBase.PaintMeshDiffuseTexture(const _Faces: auint32; const _VertsColours: TAVector4f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData);
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

procedure CTextureGeneratorBase.PaintMeshNormalMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; var _WeightBuffer: TAbstract2DImageData);
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
procedure CTextureGeneratorBase.PaintMeshBumpMapTexture(const _Faces: auint32; const _VertsNormals: TAVector3f; const _TexCoords: TAVector2f; _VerticesPerFace: integer; var _Buffer: TAbstract2DImageData; const _DiffuseMap: TAbstract2DImageData);
var
   HeightMap : TAbstract2DImageData;
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
   HeightMap.Free;
   Filler.Free;
end;

// This is the latest attempt as a simple image processsing operation.
function CTextureGeneratorBase.GetBumpMapTexture(const _DiffuseMap: TAbstract2DImageData; _Scale: single): TAbstract2DImageData;
var
   HeightMap : TAbstract2DImageData;
   x,y,Size : integer;
   Filler: CTriangleFiller;
begin
   // Build height map and visited map
   Filler := CTriangleFiller.Create;
   HeightMap := GenerateHeightMapBuffer(_DiffuseMap);
   HeightMap.ScaleBy(_Scale / 255);
   Size := HeightMap.XSize;
   Result := T2DImageRGBByteData.Create(Size,Size);
   // Now, we'll check each face.
   for x := 0 to HeightMap.MaxX do
      for y := 0 to HeightMap.MaxY do
      begin
         Filler.PaintBumpValueAtFrameBuffer(Result,HeightMap,X,Y,Size);
      end;
   HeightMap.Free;
   Filler.Free;
end;


// This procedure fixes white/black borders in the edge of each partition.
procedure CTextureGeneratorBase.FixBilinearBorders(var _Bitmap: TBitmap; var _AlphaMap: TByteMap);
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

procedure CTextureGeneratorBase.FixBilinearBorders(var _ImageData: TAbstract2DImageData);
var
   x,y,i,k,mini,maxi,mink,maxk,r,g,b,ri,gi,bi,sum : integer;
   AlphaMapBackup: TByteMap;
begin
   SetLength(AlphaMapBackup,_ImageData.XSize,_ImageData.YSize);
   for x := 0 to _ImageData.MaxX do
   begin
      for y := 0 to _ImageData.MaxY do
      begin
         AlphaMapBackup[x,y] := Trunc(_ImageData.Alpha[x,y]);
      end;
   end;
   for x := 0 to _ImageData.MaxX do
   begin
      for y := 0 to _ImageData.MaxY do
      begin
         if AlphaMapBackup[x,y] = C_TRP_RGB_INVISIBLE then
         begin
            mini := x - 1;
            if mini < 0 then
               mini := 0;
            maxi := x + 1;
            if maxi > _ImageData.MaxX then
               maxi := _ImageData.MaxX;
            mink := y - 1;
            if mink < 0 then
               mink := 0;
            maxk := y + 1;
            if maxk > _ImageData.MaxY then
               maxk := _ImageData.MaxY;

            r := 0;
            g := 0;
            b := 0;
            sum := 0;
            for i := mini to maxi do
               for k := mink to maxk do
               begin
                  if AlphaMapBackup[i,k] <> C_TRP_RGB_INVISIBLE then
                  begin
                     ri := Trunc(_ImageData.Red[i,k]);
                     gi := Trunc(_ImageData.Green[i,k]);
                     bi := Trunc(_ImageData.Blue[i,k]);
                     r := r + ri;
                     g := g + gi;
                     b := b + bi;
                     inc(sum);
                  end;
               end;
            if (r + g + b) > 0 then
               _ImageData.Alpha[x,y] := C_TRP_RGB_OPAQUE;
            if sum > 0 then
            begin
               _ImageData.Red[x,y] := r div sum;
               _ImageData.Green[x,y] :=  g div sum;
               _ImageData.Blue[x,y] :=  b div sum;
            end;
         end;
      end;
   end;
   // Free memory
   for i := Low(AlphaMapBackup) to High(AlphaMapBackup) do
   begin
      SetLength(AlphaMapBackup[i],0);
   end;
   SetLength(AlphaMapBackup,0);
end;

end.
