unit ClassTriangleFiller;

interface

uses BasicDataTypes, ClassVector3fSet, math3D, Windows, Graphics, Abstract2DImageData;

type
   CTriangleFiller = class
      private
         // Pixel Utils
         function IsP1HigherThanP2(_P1, _P2 : TVector2f): boolean;
         procedure AssignPointColour(var _DestPoint: TVector2f; var _DestColour: TVector4f; const _SourcePoint: TVector2f; const _SourceColour: TVector4f); overload;
         procedure AssignPointColour(var _DestPoint: TVector2f; var _DestColour: TVector3f; const _SourcePoint: TVector2f; const _SourceColour: TVector3f); overload;
         function GetAverageColour(const _C1, _C2: TVector3f):TVector3f; overload;
         function GetAverageColour(const _C1, _C2: TVector4f):TVector4f; overload;
         function GetAverageColour(const _C1, _C2,_C3: TVector3f):TVector3f; overload;
         function GetAverageColour(const _C1, _C2,_C3: TVector4f):TVector4f; overload;
         // Paint single pixel
         procedure PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size, _PosX, _PosY : integer; _Colour: TVector4f; _Weight : single); overload;
         procedure PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size, _PosX, _PosY : integer; _Colour: TVector3f; _Weight : single); overload;
         procedure PaintPixel(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Size, _PosX, _PosY : integer; _Colour: TVector3f; _Weight : single); overload;
         procedure PaintPixel(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Size, _PosX, _PosY : integer; _Colour: TVector4f; _Weight : single); overload;
         // Paint bicubic pixel
         procedure PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector4f); overload;
         procedure PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector3f); overload;
         procedure PaintPixelAtFrameBuffer(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Point: TVector2f; _Colour: TVector3f); overload;
         procedure PaintPixelAtFrameBuffer(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Point: TVector2f; _Colour: TVector4f); overload;
         procedure PaintBumpValueAtFrameBuffer(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _X, _Y : single; _Size: integer); overload;
         // Paint line
         procedure PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector3f); overload;
         procedure PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f); overload;
         procedure PaintGouraudHorizontalLine(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector3f); overload;
         procedure PaintGouraudHorizontalLine(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector4f); overload;
         procedure PaintBumpHorizontalLine(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _X1, _X2, _Y : single; _Size: integer); overload;
         procedure PaintBumpHorizontalLine(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X1, _X2, _Y : single; _Size: integer); overload;
         // Triangle Utils
         procedure GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector3f; var _dx, _dr, _dg, _db: single); overload;
         procedure GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector4f; var _dx, _dr, _dg, _db, _da: single); overload;
         procedure GetGradient(const _P2, _P1: TVector2f; var dx: single); overload;
         procedure PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real); overload;
         procedure PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real); overload;
         procedure PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real); overload;
         procedure PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real); overload;
         procedure PaintTrianglePiece(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _S, _E: TVector2f; const _FinalPos, _dxs, _dxe: single; _Size: integer); overload;
         procedure PaintTrianglePiece(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; var _S, _E: TVector2f; const _FinalPos, _dxs, _dxe: single; _Size: integer); overload;
         // Paint triangle
         procedure PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f); overload;
         procedure PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f); overload;
         procedure PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintBumpMapTriangle(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintBumpMapTriangle(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f); overload;
      public
         // For bump mapping only
         procedure PaintBumpValueAtFrameBuffer(var _Bitmap: TBitmap; const _HeightMap: TByteMap; _X, _Y : single; _Size: integer); overload;
         procedure PaintBumpValueAtFrameBuffer(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X, _Y : single; _Size: integer); overload;
         // Painting procedures
         procedure PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f); overload;
         procedure PaintTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f); overload;
         procedure PaintTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintFlatTriangleFromHeightMap(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintFlatTriangleFromHeightMap(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f); overload;
   end;

implementation

// Pixel Utils
function CTriangleFiller.IsP1HigherThanP2(_P1, _P2 : TVector2f): boolean;
begin
   if _P1.V > _P2.V then
   begin
      Result := true;
   end
   else if _P1.V = _P2.V then
   begin
      if _P1.U > _P2.U then
      begin
         Result := true;
      end
      else
      begin
         Result := false;
      end;
   end
   else
   begin
      Result := false;
   end;
end;

procedure CTriangleFiller.AssignPointColour(var _DestPoint: TVector2f; var _DestColour: TVector4f; const _SourcePoint: TVector2f; const _SourceColour: TVector4f);
begin
   _DestPoint := SetVector(_SourcePoint);
   _DestColour := SetVector(_SourceColour);
end;

procedure CTriangleFiller.AssignPointColour(var _DestPoint: TVector2f; var _DestColour: TVector3f; const _SourcePoint: TVector2f; const _SourceColour: TVector3f);
begin
   _DestPoint := SetVector(_SourcePoint);
   _DestColour := SetVector(_SourceColour);
end;

function CTriangleFiller.GetAverageColour(const _C1, _C2: TVector3f):TVector3f;
begin
   Result.X := (_C1.X + _C2.X) / 2;
   Result.Y := (_C1.Y + _C2.Y) / 2;
   Result.Z := (_C1.Z + _C2.Z) / 2;
end;

function CTriangleFiller.GetAverageColour(const _C1, _C2: TVector4f):TVector4f;
begin
   Result.X := (_C1.X + _C2.X) / 2;
   Result.Y := (_C1.Y + _C2.Y) / 2;
   Result.Z := (_C1.Z + _C2.Z) / 2;
   Result.W := (_C1.W + _C2.W) / 2;
end;

function CTriangleFiller.GetAverageColour(const _C1, _C2,_C3: TVector3f):TVector3f;
begin
   Result.X := (_C1.X + _C2.X + _C3.X) / 3;
   Result.Y := (_C1.Y + _C2.Y + _C3.Y) / 3;
   Result.Z := (_C1.Z + _C2.Z + _C3.Z) / 3;
end;

function CTriangleFiller.GetAverageColour(const _C1, _C2,_C3: TVector4f):TVector4f;
begin
   Result.X := (_C1.X + _C2.X + _C3.X) / 3;
   Result.Y := (_C1.Y + _C2.Y + _C3.Y) / 3;
   Result.Z := (_C1.Z + _C2.Z + _C3.Z) / 3;
   Result.W := (_C1.W + _C2.W + _C3.W) / 3;
end;


// Paint Pixel
procedure CTriangleFiller.PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size, _PosX, _PosY : integer; _Colour: TVector3f; _Weight : single);
begin
   if (_PosY < _Size) and (_PosX < _Size) and (_PosX >= 0) and (_PosY >= 0) then
   begin
      _Buffer[_PosX,_PosY].X := _Buffer[_PosX,_PosY].X + (_Colour.X * _Weight);
      _Buffer[_PosX,_PosY].Y := _Buffer[_PosX,_PosY].Y + (_Colour.Y * _Weight);
      _Buffer[_PosX,_PosY].Z := _Buffer[_PosX,_PosY].Z + (_Colour.Z * _Weight);
      _WeightBuffer[_PosX,_PosY] := _WeightBuffer[_PosX,_PosY] + _Weight;
   end;
end;

procedure CTriangleFiller.PaintPixel(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Size, _PosX, _PosY : integer; _Colour: TVector4f; _Weight : single);
begin
   if (_PosY < _Size) and (_PosX < _Size) and (_PosX >= 0) and (_PosY >= 0) then
   begin
      _Buffer[_PosX,_PosY].X := _Buffer[_PosX,_PosY].X + (_Colour.X * _Weight);
      _Buffer[_PosX,_PosY].Y := _Buffer[_PosX,_PosY].Y + (_Colour.Y * _Weight);
      _Buffer[_PosX,_PosY].Z := _Buffer[_PosX,_PosY].Z + (_Colour.Z * _Weight);
      _Buffer[_PosX,_PosY].W := _Buffer[_PosX,_PosY].W + (_Colour.W * _Weight);
      _WeightBuffer[_PosX,_PosY] := _WeightBuffer[_PosX,_PosY] + _Weight;
   end;
end;

procedure CTriangleFiller.PaintPixel(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Size, _PosX, _PosY : integer; _Colour: TVector3f; _Weight : single);
begin
   if (_PosY < _Size) and (_PosX < _Size) and (_PosX >= 0) and (_PosY >= 0) then
   begin
      _Buffer.Red[_PosX,_PosY] := _Buffer.Red[_PosX,_PosY] + (_Colour.X * _Weight);
      _Buffer.Green[_PosX,_PosY] := _Buffer.Green[_PosX,_PosY] + (_Colour.Y * _Weight);
      _Buffer.Blue[_PosX,_PosY] := _Buffer.Blue[_PosX,_PosY] + (_Colour.Z * _Weight);
      _WeightBuffer.Red[_PosX,_PosY] := _WeightBuffer.Red[_PosX,_PosY] + _Weight;
   end;
end;

procedure CTriangleFiller.PaintPixel(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Size, _PosX, _PosY : integer; _Colour: TVector4f; _Weight : single);
begin
   if (_PosY < _Size) and (_PosX < _Size) and (_PosX >= 0) and (_PosY >= 0) then
   begin
      _Buffer.Red[_PosX,_PosY] := _Buffer.Red[_PosX,_PosY] + (_Colour.X * _Weight);
      _Buffer.Green[_PosX,_PosY] := _Buffer.Green[_PosX,_PosY] + (_Colour.Y * _Weight);
      _Buffer.Blue[_PosX,_PosY] := _Buffer.Blue[_PosX,_PosY] + (_Colour.Z * _Weight);
      _Buffer.Alpha[_PosX,_PosY] := _Buffer.Alpha[_PosX,_PosY] + (_Colour.W * _Weight);
      _WeightBuffer.Red[_PosX,_PosY] := _WeightBuffer.Red[_PosX,_PosY] + _Weight;
   end;
end;

// Painting procedures
procedure CTriangleFiller.PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector4f);
var
   Size : integer;
   PosX, PosY : integer;
   Point,FractionLow,FractionHigh : TVector2f;
begin
   Size := High(_Buffer)+1;
   Point := SetVector(_Point);
   PosX := Trunc(Point.U);
   PosY := Trunc(Point.V);
   FractionHigh := SetVector(Point.U - PosX, Point.V - PosY);
   FractionLow := SetVector(1 - FractionHigh.U,1 - FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, FractionLow.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, FractionHigh.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, FractionLow.U * FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, FractionHigh.U * FractionHigh.V);
end;

procedure CTriangleFiller.PaintPixelAtFrameBuffer(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _Point: TVector2f; _Colour: TVector3f);
var
   Size : integer;
   PosX, PosY : integer;
   Point,FractionLow,FractionHigh : TVector2f;
begin
   Size := High(_Buffer)+1;
   Point := SetVector(_Point);
   PosX := Trunc(Point.U);
   PosY := Trunc(Point.V);
   FractionHigh := SetVector(Point.U - PosX, Point.V - PosY);
   FractionLow := SetVector(1 - FractionHigh.U,1 - FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, FractionLow.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, FractionHigh.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, FractionLow.U * FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, FractionHigh.U * FractionHigh.V);
end;

procedure CTriangleFiller.PaintPixelAtFrameBuffer(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Point: TVector2f; _Colour: TVector3f);
var
   Size : integer;
   PosX, PosY : integer;
   Point,FractionLow,FractionHigh : TVector2f;
begin
   Size := _Buffer.MaxX + 1;
   Point := SetVector(_Point);
   PosX := Trunc(Point.U);
   PosY := Trunc(Point.V);
   FractionHigh := SetVector(Point.U - PosX, Point.V - PosY);
   FractionLow := SetVector(1 - FractionHigh.U,1 - FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, FractionLow.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, FractionHigh.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, FractionLow.U * FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, FractionHigh.U * FractionHigh.V);
end;

procedure CTriangleFiller.PaintPixelAtFrameBuffer(var _Buffer,_WeightBuffer: TAbstract2DImageData; _Point: TVector2f; _Colour: TVector4f);
var
   Size : integer;
   PosX, PosY : integer;
   Point,FractionLow,FractionHigh : TVector2f;
begin
   Size := _Buffer.MaxX + 1;
   Point := SetVector(_Point);
   PosX := Trunc(Point.U);
   PosY := Trunc(Point.V);
   FractionHigh := SetVector(Point.U - PosX, Point.V - PosY);
   FractionLow := SetVector(1 - FractionHigh.U,1 - FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY, _Colour, FractionLow.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY, _Colour, FractionHigh.U * FractionLow.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX, PosY+1, _Colour, FractionLow.U * FractionHigh.V);
   PaintPixel(_Buffer, _WeightBuffer, Size, PosX+1, PosY+1, _Colour, FractionHigh.U * FractionHigh.V);
end;


procedure CTriangleFiller.PaintBumpValueAtFrameBuffer(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _X, _Y : single; _Size: integer);
const
   FaceSequence : array [0..7,0..3] of integer = ((-1,-1,0,-1),(0,-1,1,-1),(1,-1,1,0),(1,0,1,1),(1,1,0,1),(0,1,-1,1),(-1,1,-1,0),(-1,0,-1,-1));
var
   DifferentNormalsList: CVector3fSet;
   i,x,y,P1x,P1y,P2x,P2y : integer;
   CurrentNormal : PVector3f;
   V1, V2, Normal: TVector3f;
begin
   x := Round(_X);
   y := Round(_Y);
   if (X < 0) or (Y < 0) or (X >= _Size) or (Y >= _Size) then exit;

   DifferentNormalsList := CVector3fSet.Create;
   Normal := SetVector(0,0,0);
   for i := 0 to 7 do
   begin
      P1x := X + FaceSequence[i,0];
      P1y := Y + FaceSequence[i,1];
      P2x := X + FaceSequence[i,2];
      P2y := Y + FaceSequence[i,3];

      if (P1x >= 0) and (P1y >= 0) and (P1x < _Size) and (P1y < _Size) and (P2x >= 0) and (P2y >= 0) and (P2x < _Size) and (P2y < _Size) then
      begin
         CurrentNormal := new(PVector3f);
         V1 := SetVector(FaceSequence[i,0], FaceSequence[i,1], _HeightMap[X,Y] - _HeightMap[P1x,P1y]);
         V2 := SetVector(FaceSequence[i,2], FaceSequence[i,3], _HeightMap[X,Y] - _HeightMap[P2x,P2y]);
         Normalize(V1);
         Normalize(V2);
         CurrentNormal^ := CrossProduct(V1,V2);
         Normalize(CurrentNormal^);
         if DifferentNormalsList.Add(CurrentNormal) then
         begin
            Normal := AddVector(Normal,CurrentNormal^);
         end;
      end;
   end;
   if not DifferentNormalsList.isEmpty then
   begin
      Normalize(Normal);
   end;
   _Buffer[X,Y].X := Normal.X;
   _Buffer[X,Y].Y := Normal.Y;
   _Buffer[X,Y].Z := Normal.Z;
   DifferentNormalsList.Free;
end;

procedure CTriangleFiller.PaintBumpValueAtFrameBuffer(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X, _Y : single; _Size: integer);
const
   FaceSequence : array [0..7,0..3] of integer = ((-1,-1,0,-1),(0,-1,1,-1),(1,-1,1,0),(1,0,1,1),(1,1,0,1),(0,1,-1,1),(-1,1,-1,0),(-1,0,-1,-1));
var
   DifferentNormalsList: CVector3fSet;
   i,x,y,P1x,P1y,P2x,P2y : integer;
   CurrentNormal : PVector3f;
   V1, V2, Normal: TVector3f;
begin
   x := Round(_X);
   y := Round(_Y);
   if (X < 0) or (Y < 0) or (X >= _Size) or (Y >= _Size) then exit;

   DifferentNormalsList := CVector3fSet.Create;
   Normal := SetVector(0,0,0);
   for i := 0 to 7 do
   begin
      P1x := X + FaceSequence[i,0];
      P1y := Y + FaceSequence[i,1];
      P2x := X + FaceSequence[i,2];
      P2y := Y + FaceSequence[i,3];

      if (P1x >= 0) and (P1y >= 0) and (P1x < _Size) and (P1y < _Size) and (P2x >= 0) and (P2y >= 0) and (P2x < _Size) and (P2y < _Size) then
      begin
         CurrentNormal := new(PVector3f);
         V1 := SetVector(FaceSequence[i,0], FaceSequence[i,1], _HeightMap.Red[X,Y] - _HeightMap.Red[P1x,P1y]);
         V2 := SetVector(FaceSequence[i,2], FaceSequence[i,3], _HeightMap.Red[X,Y] - _HeightMap.Red[P2x,P2y]);
         Normalize(V1);
         Normalize(V2);
         CurrentNormal^ := CrossProduct(V1,V2);
         Normalize(CurrentNormal^);
         if DifferentNormalsList.Add(CurrentNormal) then
         begin
            Normal := AddVector(Normal,CurrentNormal^);
         end;
      end;
   end;
   if not DifferentNormalsList.isEmpty then
   begin
      Normalize(Normal);
   end;
   _Buffer.Red[X,Y] := Normal.X;
   _Buffer.Green[X,Y] := Normal.Y;
   _Buffer.Blue[X,Y] := Normal.Z;
   DifferentNormalsList.Free;
end;


procedure CTriangleFiller.PaintBumpValueAtFrameBuffer(var _Bitmap: TBitmap; const _HeightMap: TByteMap; _X, _Y : single; _Size: integer);
const
   FaceSequence : array [0..7,0..3] of integer = ((-1,-1,0,-1),(0,-1,1,-1),(1,-1,1,0),(1,0,1,1),(1,1,0,1),(0,1,-1,1),(-1,1,-1,0),(-1,0,-1,-1));
var
   DifferentNormalsList: CVector3fSet;
   i,x,y,P1x,P1y,P2x,P2y : integer;
   CurrentNormal : PVector3f;
   V1, V2, Normal: TVector3f;
begin
   x := Round(_X);
   y := Round(_Y);
   if (X < 0) or (Y < 0) or (X >= _Size) or (Y >= _Size) then exit;

   DifferentNormalsList := CVector3fSet.Create;
   Normal := SetVector(0,0,0);
   for i := 0 to 7 do
   begin
      P1x := X + FaceSequence[i,0];
      P1y := Y + FaceSequence[i,1];
      P2x := X + FaceSequence[i,2];
      P2y := Y + FaceSequence[i,3];

      if (P1x >= 0) and (P1y >= 0) and (P1x < _Size) and (P1y < _Size) and (P2x >= 0) and (P2y >= 0) and (P2x < _Size) and (P2y < _Size) then
      begin
         CurrentNormal := new(PVector3f);
         V1 := SetVector(FaceSequence[i,0], FaceSequence[i,1], _HeightMap[X,Y] - _HeightMap[P1x,P1y]);
         V2 := SetVector(FaceSequence[i,2], FaceSequence[i,3], _HeightMap[X,Y] - _HeightMap[P2x,P2y]);
         Normalize(V1);
         Normalize(V2);
         CurrentNormal^ := CrossProduct(V1,V2);
         Normalize(CurrentNormal^);
         if DifferentNormalsList.Add(CurrentNormal) then
         begin
            Normal := AddVector(Normal,CurrentNormal^);
         end;
      end;
   end;
   if not DifferentNormalsList.isEmpty then
   begin
      Normalize(Normal);
   end;
   if (abs(Normal.X) + abs(Normal.Y) + abs(Normal.Z)) = 0 then
      Normal.Z := 1;
   _Bitmap.Canvas.Pixels[X,Y] := RGB(Round((1 + Normal.X) * 127.5), Round((1 + Normal.Y) * 127.5), Round((1 + Normal.Z) * 127.5));
   DifferentNormalsList.Free;
end;



// Paint line
procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector3f);
var
   dr, dg, db : real;
   x2, x1 : single;
   C1, C2, PC : TVector3f;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
      C1 := SetVector(_C2);
      C2 := SetVector(_C1);
   end
   else if _X1 = _X2 then
   begin
      PP := SetVector(_x1,_Y);
      PC := GetAverageColour(_C1,_C2);
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
      C1 := SetVector(_C1);
      C2 := SetVector(_C2);
   end;

   // get the gradients for each colour channel
 	dr := (C2.X - C1.X) / (x2 - x1);
   dg := (C2.Y - C1.Y) / (x2 - x1);
   db := (C2.Z - C1.Z) / (x2 - x1);

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   PC := SetVector(C1);
   while PP.U <= x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PP.U := PP.U + 1;
   end;
end;

procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
var
   dr, dg, db, da : real;
   x2, x1 : single;
   C1, C2, PC : TVector4f;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
      C1 := SetVector(_C2);
      C2 := SetVector(_C1);
   end
   else if _X1 = _X2 then
   begin
      PP := SetVector(_x1,_Y);
      PC := GetAverageColour(_C1,_C2);
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
      C1 := SetVector(_C1);
      C2 := SetVector(_C2);
   end;

   // get the gradients for each colour channel
 	dr := (C2.X - C1.X) / (x2 - x1);
   dg := (C2.Y - C1.Y) / (x2 - x1);
   db := (C2.Z - C1.Z) / (x2 - x1);
   da := (C2.W - C1.W) / (x2 - x1);

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   PC := SetVector(C1);
   while PP.U <= x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PC.W := PC.W + da;
      PP.U := PP.U + 1;
   end;
end;

procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector3f);
var
   dr, dg, db : real;
   x2, x1 : single;
   C1, C2, PC : TVector3f;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
      C1 := SetVector(_C2);
      C2 := SetVector(_C1);
   end
   else if _X1 = _X2 then
   begin
      PP := SetVector(_x1,_Y);
      PC := GetAverageColour(_C1,_C2);
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
      C1 := SetVector(_C1);
      C2 := SetVector(_C2);
   end;

   // get the gradients for each colour channel
 	dr := (C2.X - C1.X) / (x2 - x1);
   dg := (C2.Y - C1.Y) / (x2 - x1);
   db := (C2.Z - C1.Z) / (x2 - x1);

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   PC := SetVector(C1);
   while PP.U <= x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PP.U := PP.U + 1;
   end;
end;

procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
var
   dr, dg, db, da : real;
   x2, x1 : single;
   C1, C2, PC : TVector4f;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
      C1 := SetVector(_C2);
      C2 := SetVector(_C1);
   end
   else if _X1 = _X2 then
   begin
      PP := SetVector(_x1,_Y);
      PC := GetAverageColour(_C1,_C2);
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
      C1 := SetVector(_C1);
      C2 := SetVector(_C2);
   end;

   // get the gradients for each colour channel
 	dr := (C2.X - C1.X) / (x2 - x1);
   dg := (C2.Y - C1.Y) / (x2 - x1);
   db := (C2.Z - C1.Z) / (x2 - x1);
   da := (C2.W - C1.W) / (x2 - x1);

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   PC := SetVector(C1);
   while PP.U <= x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PC.W := PC.W + da;
      PP.U := PP.U + 1;
   end;
end;


procedure CTriangleFiller.PaintBumpHorizontalLine(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _X1, _X2, _Y : single; _Size: integer);
var
   x2, x1 : single;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
   end
   else if _X1 = _X2 then
   begin
      PaintBumpValueAtFrameBuffer(_Buffer, _HeightMap, _x1, _Y,_Size);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
   end;

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U <= x2 do
   begin
      PaintBumpValueAtFrameBuffer(_Buffer, _HeightMap, PP.U, PP.V,_Size);
      PP.U := PP.U + 1;
   end;
end;

procedure CTriangleFiller.PaintBumpHorizontalLine(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X1, _X2, _Y : single; _Size: integer);
var
   x2, x1 : single;
   PP : TVector2f;
begin
   // First we make sure x1 will be smaller than x2.
   if (_X1 > _X2) then
   begin
      x1 := _X2;
      x2 := _X1;
   end
   else if _X1 = _X2 then
   begin
      PaintBumpValueAtFrameBuffer(_Buffer, _HeightMap, _x1, _Y,_Size);
      exit;
   end
   else
   begin
      x1 := _X1;
      x2 := _X2;
   end;

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U <= x2 do
   begin
      PaintBumpValueAtFrameBuffer(_Buffer, _HeightMap, PP.U, PP.V,_Size);
      PP.U := PP.U + 1;
   end;
end;


// Triangle Utils
procedure CTriangleFiller.GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector3f; var _dx, _dr, _dg, _db: single);
var
   VSize: single;
begin
   VSize := _P2.V - _P1.V;
   if (VSize <> 0) then
   begin
		_dx := (_P2.U - _P1.U) / VSize;
		_dr := (_C2.X - _C1.X) / VSize;
		_dg := (_C2.Y - _C1.Y) / VSize;
		_db := (_C2.Z - _C1.Z) / VSize;
	end
   else
   begin
		_dx := 0;//(_P2.U - _P1.U);
      _dr := 0;//(_C2.X - _C1.X);
      _dg := 0;//(_C2.Y - _C1.Y);
      _db := 0;//(_C2.Z - _C1.Z);
   end;
end;

procedure CTriangleFiller.GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector4f; var _dx, _dr, _dg, _db, _da: single);
var
   VSize: single;
begin
   VSize := _P2.V - _P1.V;
   if (VSize <> 0) then
   begin
		_dx := (_P2.U - _P1.U) / VSize;
		_dr := (_C2.X - _C1.X) / VSize;
		_dg := (_C2.Y - _C1.Y) / VSize;
		_db := (_C2.Z - _C1.Z) / VSize;
		_da := (_C2.W - _C1.W) / VSize;
	end
   else
   begin
		_dx := 0;//(_P2.U - _P1.U);
      _dr := 0;//(_C2.X - _C1.X);
      _dg := 0;//(_C2.Y - _C1.Y);
      _db := 0;//(_C2.Z - _C1.Z);
      _da := 0;//(_C2.W - _C1.W);
   end;
end;

procedure CTriangleFiller.GetGradient(const _P2, _P1: TVector2f; var dx: single);
var
   VSize: single;
begin
   VSize := _P2.V - _P1.V;
   if (VSize <> 0) then
      dx := ((_P2.U - _P1.U) / VSize)
   else
      dx := 0;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real);
begin
   while (_SP.V <= _FinalPos) do
   begin
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SP := SetVector(_SP.U + _dxs, _SP.V + 1);
      _EP := SetVector(_EP.U + _dxe, _EP.V + 1);
      _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs);
      _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe);
	end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real);
begin
   while (_SP.V <= _FinalPos) do
   begin
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SP := SetVector(_SP.U + _dxs, _SP.V + 1);
      _EP := SetVector(_EP.U + _dxe, _EP.V + 1);
      _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs, _SC.W + _das);
      _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe, _EC.W + _dae);
	end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real);
begin
   while (_SP.V <= _FinalPos) do
   begin
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SP := SetVector(_SP.U + _dxs, _SP.V + 1);
      _EP := SetVector(_EP.U + _dxe, _EP.V + 1);
      _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs);
      _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe);
	end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real);
begin
   while (_SP.V <= _FinalPos) do
   begin
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SP := SetVector(_SP.U + _dxs, _SP.V + 1);
      _EP := SetVector(_EP.U + _dxe, _EP.V + 1);
      _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs, _SC.W + _das);
      _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe, _EC.W + _dae);
	end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _S, _E: TVector2f; const _FinalPos, _dxs, _dxe: single; _Size: integer);
begin
   while _S.V <= _FinalPos do
   begin
	   PaintBumpHorizontalLine(_Buffer, _HeightMap,_S.U,_E.U,_S.V,_Size);
      _S := SetVector(_S.U + _dxs, _S.V + 1);
      _E := SetVector(_E.U + _dxe, _E.V + 1);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; var _S, _E: TVector2f; const _FinalPos, _dxs, _dxe: single; _Size: integer);
begin
   while _S.V <= _FinalPos do
   begin
	   PaintBumpHorizontalLine(_Buffer, _HeightMap,_S.U,_E.U,_S.V,_Size);
      _S := SetVector(_S.U + _dxs, _S.V + 1);
      _E := SetVector(_E.U + _dxe, _E.V + 1);
   end;
end;

procedure CTriangleFiller.PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f);
var
   dx1, dx2, dx3, dr, dr1, dr2, dr3, dg, dg1, dg2, dg3, db, db1, db2, db3 : single;
   SP, EP, PP : TVector2f;
   SC, EC, PC : TVector3f;
begin
   GetGradient(_P2,_P1,_C2,_C1,dx1,dr1,dg1,db1);
   GetGradient(_P3,_P1,_C3,_C1,dx2,dr2,dg2,db2);
   GetGradient(_P3,_P2,_C3,_C2,dx3,dr3,dg3,db3);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2);
	end;
end;

procedure CTriangleFiller.PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3, da1, da2, da3 : single;
   SP, EP : TVector2f;
   SC, EC : TVector4f;
begin
   GetGradient(_P2,_P1,_C2,_C1,dx1,dr1,dg1,db1,da1);
   GetGradient(_P3,_P1,_C3,_C1,dx2,dr2,dg2,db2,da2);
   GetGradient(_P3,_P2,_C3,_C2,dx3,dr3,dg3,db3,da3);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2);
	end;
end;


// Code adapted from http://www-users.mat.uni.torun.pl/~wrona/3d_tutor/tri_fillers.html
procedure CTriangleFiller.PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3, da1, da2, da3 : single;
   SP, EP : TVector2f;
   SC, EC : TVector4f;
begin
   GetGradient(_P2,_P1,_C2,_C1,dx1,dr1,dg1,db1,da1);
   GetGradient(_P3,_P1,_C3,_C1,dx2,dr2,dg2,db2,da2);
   GetGradient(_P3,_P2,_C3,_C2,dx3,dr3,dg3,db3,da3);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2);
	end;
end;

procedure CTriangleFiller.PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f);
var
   dx1, dx2, dx3, dr, dr1, dr2, dr3, dg, dg1, dg2, dg3, db, db1, db2, db3 : single;
   SP, EP, PP : TVector2f;
   SC, EC, PC : TVector3f;
begin
   GetGradient(_P2,_P1,_C2,_C1,dx1,dr1,dg1,db1);
   GetGradient(_P3,_P1,_C3,_C1,dx2,dr2,dg2,db2);
   GetGradient(_P3,_P2,_C3,_C2,dx3,dr3,dg3,db3);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2.V,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3.V,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2);
	end;
end;

procedure CTriangleFiller.PaintBumpMapTriangle(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f);
var
   P1, P2, P3 : TVector2f;
   dx1, dx2, dx3 : single;
   Size : integer;
   S, E : TVector2f;
begin
   Size := High(_Buffer[0])+1;
   GetGradient(_P2,_P1,dx1);
   GetGradient(_P3,_P1,dx2);
   GetGradient(_P3,_P2,dx3);

   E := SetVector(_P1);
   S := SetVector(_P1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2.V,dx2,dx1,Size);
      E := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3.V,dx2,dx3,Size);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2.V,dx1,dx2,Size);
      S := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3.V,dx3,dx2,Size);
	end;
end;

procedure CTriangleFiller.PaintBumpMapTriangle(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f);
var
   P1, P2, P3 : TVector2f;
   dx1, dx2, dx3 : single;
   Size : integer;
   S, E : TVector2f;
begin
   Size := _Buffer.MaxX +1;
   GetGradient(_P2,_P1,dx1);
   GetGradient(_P3,_P1,dx2);
   GetGradient(_P3,_P2,dx3);

   E := SetVector(_P1);
   S := SetVector(_P1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2.V,dx2,dx1,Size);
      E := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3.V,dx2,dx3,Size);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2.V,dx1,dx2,Size);
      S := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3.V,dx3,dx2,Size);
	end;
end;


// Public methods starts here.

procedure CTriangleFiller.PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   P1, P2, P3 : TVector2f;
   CX : TVector4f;
   Size : integer;
begin
   Size := High(_Buffer[0])+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);
   if IsP1HigherThanP2(P1,P2) then
   begin
      if IsP1HigherThanP2(P2,P3) then
      begin
         // P3 < P2 < P1
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_C3,_C2,_C1);
      end
      else
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P2 < P3 < P1
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_C2,_C3,_C1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_C2,_C1,_C3);
         end;
      end;
   end
   else
   begin
      if IsP1HigherThanP2(P2,P3) then
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P3 < P1 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_C3,_C1,_C2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_C1,_C3,_C2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_C1,_C2,_C3);
      end;
   end;
end;

procedure CTriangleFiller.PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f);
var
   P1, P2, P3 : TVector2f;
   Size : integer;
begin
   Size := High(_Buffer[0])+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);
   if P1.V > P2.V then
   begin
      if P2.V > P3.V then
      begin
         // P3 < P2 < P1
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_N3,_N2,_N1);
      end
      else
      begin
         if P1.V > P3.V then
         begin
            // P2 < P3 < P1
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_N2,_N3,_N1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_N2,_N1,_N3);
         end;
      end;
   end
   else
   begin
      if P2.V > P3.V then
      begin
         if P1.V > P3.V then
         begin
            // P3 < P1 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_N3,_N1,_N2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_N1,_N3,_N2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_N1,_N2,_N3);
      end;
   end;
end;

procedure CTriangleFiller.PaintTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f);
var
   P1, P2, P3 : TVector2f;
   Size : integer;
begin
   Size := _Buffer.MaxX+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);
   if P1.V > P2.V then
   begin
      if P2.V > P3.V then
      begin
         // P3 < P2 < P1
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_N3,_N2,_N1);
      end
      else
      begin
         if P1.V > P3.V then
         begin
            // P2 < P3 < P1
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_N2,_N3,_N1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_N2,_N1,_N3);
         end;
      end;
   end
   else
   begin
      if P2.V > P3.V then
      begin
         if P1.V > P3.V then
         begin
            // P3 < P1 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_N3,_N1,_N2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_N1,_N3,_N2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_N1,_N2,_N3);
      end;
   end;
end;

procedure CTriangleFiller.PaintTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   P1, P2, P3 : TVector2f;
   CX : TVector4f;
   Size : integer;
begin
   Size := _Buffer.MaxX +1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);
   if IsP1HigherThanP2(P1,P2) then
   begin
      if IsP1HigherThanP2(P2,P3) then
      begin
         // P3 < P2 < P1
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_C3,_C2,_C1);
      end
      else
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P2 < P3 < P1
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_C2,_C3,_C1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_C2,_C1,_C3);
         end;
      end;
   end
   else
   begin
      if IsP1HigherThanP2(P2,P3) then
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P3 < P1 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_C3,_C1,_C2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_C1,_C3,_C2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintGouraudTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_C1,_C2,_C3);
      end;
   end;
end;


procedure CTriangleFiller.PaintFlatTriangleFromHeightMap(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f);
var
   P1, P2, P3 : TVector2f;
   Size : integer;
begin
   Size := High(_Buffer[0])+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);
   if P1.V > P2.V then
   begin
      if P2.V > P3.V then
      begin
         // P3 < P2 < P1
         PaintBumpMapTriangle(_Buffer,_HeightMap,P3,P2,P1);
      end
      else
      begin
         if P1.V > P3.V then
         begin
            // P2 < P3 < P1
            PaintBumpMapTriangle(_Buffer,_HeightMap,P2,P3,P1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintBumpMapTriangle(_Buffer,_HeightMap,P2,P1,P3);
         end;
      end;
   end
   else
   begin
      if P2.V > P3.V then
      begin
         if P1.V > P3.V then
         begin
            // P3 < P1 < P2
            PaintBumpMapTriangle(_Buffer,_HeightMap,P3,P1,P2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintBumpMapTriangle(_Buffer,_HeightMap,P1,P3,P2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintBumpMapTriangle(_Buffer,_HeightMap,P1,P2,P3);
      end;
   end;
end;

procedure CTriangleFiller.PaintFlatTriangleFromHeightMap(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f);
var
   P1, P2, P3 : TVector2f;
   Size : integer;
begin
   Size := _Buffer.MaxX+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);
   if P1.V > P2.V then
   begin
      if P2.V > P3.V then
      begin
         // P3 < P2 < P1
         PaintBumpMapTriangle(_Buffer,_HeightMap,P3,P2,P1);
      end
      else
      begin
         if P1.V > P3.V then
         begin
            // P2 < P3 < P1
            PaintBumpMapTriangle(_Buffer,_HeightMap,P2,P3,P1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintBumpMapTriangle(_Buffer,_HeightMap,P2,P1,P3);
         end;
      end;
   end
   else
   begin
      if P2.V > P3.V then
      begin
         if P1.V > P3.V then
         begin
            // P3 < P1 < P2
            PaintBumpMapTriangle(_Buffer,_HeightMap,P3,P1,P2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintBumpMapTriangle(_Buffer,_HeightMap,P1,P3,P2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintBumpMapTriangle(_Buffer,_HeightMap,P1,P2,P3);
      end;
   end;
end;

end.
