unit TriangleFiller;

interface

uses BasicMathsTypes, BasicDataTypes, Vector3fSet, BasicFunctions, math3D, Windows, Graphics,
   Abstract2DImageData;

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
         procedure GetRGBFactorsFromPixel(const _r, _g, _b: real; var _i, _rX, _gX, _bX: real);
         function GetColourSimilarityFactor(_r1, _g1, _b1, _r2, _g2, _b2: real; var _cos: real): real;
         function AreColoursSimilar(_r1, _g1, _b1, _r2, _g2, _b2: real): real;

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
         procedure PaintHorizontalLineNCM(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f); overload;
         procedure PaintHorizontalLineNCM(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector4f); overload;
         procedure PaintBumpHorizontalLine(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _X1, _X2, _Y : single; _Size: integer); overload;
         procedure PaintBumpHorizontalLine(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X1, _X2, _Y : single; _Size: integer); overload;
         // Triangle Utils
         procedure GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector3f; var _dx, _dr, _dg, _db: single); overload;
         procedure GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector4f; var _dx, _dr, _dg, _db, _da: single); overload;
         procedure GetGradient(const _P2, _P1: TVector2f; var _dx: single); overload;
         procedure GetGradientNCM(const _P2, _P1: TVector2f; const _C2, _C1: TVector4f; var _dy, _dx, _dr, _dg, _db, _da: single; var _iStart, _iEnd: real); overload;
         procedure PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real); overload;
         procedure PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real); overload;
         procedure PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real); overload;
         procedure PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real); overload;
         procedure PaintTrianglePiece(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _S, _E: TVector2f; const _FinalPos: TVector2f; const _dxs, _dxe: single; _Size: integer); overload;
         procedure PaintTrianglePiece(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; var _S, _E: TVector2f; const _FinalPos: TVector2f; const _dxs, _dxe: single; _Size: integer); overload;
         procedure PaintTrianglePieceNCM(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dys, _dye, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae,_iStart1, _iEnd1,_iStart2,_iEnd2: real); overload;
         procedure PaintTrianglePieceNCM(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dys, _dye, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae,_iStart1, _iEnd1,_iStart2,_iEnd2: real); overload;
         procedure PaintTrianglePieceBorder(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real); overload;
         procedure PaintTrianglePieceBorder(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real); overload;
         // Paint triangle
         procedure PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f); overload;
         procedure PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f); overload;
         procedure PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintNCMTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintNCMTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintBumpMapTriangle(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintBumpMapTriangle(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintGouraudTriangleBorder(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintGouraudTriangleBorder(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
      public
         // For bump mapping only
         procedure PaintBumpValueAtFrameBuffer(var _Bitmap: TBitmap; const _HeightMap: TByteMap; _X, _Y : single; _Size: integer); overload;
         procedure PaintBumpValueAtFrameBuffer(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X, _Y : single; _Size: integer); overload;
         // Painting procedures
         procedure PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f); overload;
         procedure PaintTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _N1, _N2, _N3: TVector3f); overload;
         procedure PaintTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintTriangleNCM(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintTriangleNCM(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f); overload;
         procedure PaintFlatTriangleFromHeightMap(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintFlatTriangleFromHeightMap(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintDebugTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f); overload;
         procedure PaintDebugTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f); overload;
   end;

implementation

uses Math, SysUtils;

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

procedure CTriangleFiller.GetRGBFactorsFromPixel(const _r, _g, _b: real; var _i, _rX, _gX, _bX: real);
var
   temp: real;
begin
   _i := Max(_r, Max(_g, _b));
   // Get the chrome.
   if _r + _g + _b > 0 then
   begin
      temp := sqrt((_r * _r) + (_g * _g) + (_b * _b));
      _rX := _r / temp;
      _gX := _g / temp;
      _bX := _b / temp;
   end
   else
   begin
      _rX := sqrt(3)/3;
      _gX := _rX;
      _bX := _rX;
   end;
end;

function CTriangleFiller.GetColourSimilarityFactor(_r1, _g1, _b1, _r2, _g2, _b2: real; var _cos: real): real;
var
   dot: real;
begin
   // Get the inner product between the two normalized colours and calculate score.
   _cos := (_r1 * _r2) + (_g1 * _g2) + (_b1 * _b2);
   if _cos >= 1 then
   begin
      Result := 0;
   end
   else
   begin
      Result := sqrt(1 - (_cos * _cos)); // Result is the sin: sin = sqrt(1 - cos²) in the 1st quadrant
   end;
end;

function CTriangleFiller.AreColoursSimilar(_r1, _g1, _b1, _r2, _g2, _b2: real): real;
const
   C_EPSILON = 6/255;
var
   i1, r1, g1, b1, i2, r2, g2, b2, cos, sin: real;
begin
   GetRGBFactorsFromPixel(_r1, _g1, _b1, i1, r1, g1, b1);
   GetRGBFactorsFromPixel(_r2, _g2, _b2, i2, r2, g2, b2);
   sin := GetColourSimilarityFactor(r1, g1, b1, r2, g2, b2, cos);
   //if ((i1 * sin) <= C_EPSILON) and ((i2 * sin) <= C_EPSILON) then
   if (sin <= (sqrt(12)/(255 * i1 * i1))) and  (sin <= (sqrt(12)/(255 * i2 * i2))) then   
      Result := cos
   else
      Result := 0;
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
   _Buffer.Red[X,Y] := (1 + Normal.X) * 127.5;
   _Buffer.Green[X,Y] := (1 + Normal.Y) * 127.5;
   _Buffer.Blue[X,Y] := (1 + Normal.Z) * 127.5;
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
   dx, dr, dg, db : real;
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
   if (x2 - x1) > 1 then
   begin
      dx := (x2 - x1) / trunc(x2 - x1);
 	   dr := (C2.X - C1.X) / trunc(x2 - x1);
      dg := (C2.Y - C1.Y) / trunc(x2 - x1);
      db := (C2.Z - C1.Z) / trunc(x2 - x1);
      PC := SetVector(C1);
   end
   else
   begin
      dx := (x2 - x1);
      PC := GetAverageColour(_C1,_C2);
   end;


   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U < x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
var
   dx, dr, dg, db, da : real;
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
   if (x2 - x1) > 1 then
   begin
      PC := SetVector(C1);
      dx := (x2 - x1) / trunc(x2 - x1);
    	dr := (C2.X - C1.X) / trunc(x2 - x1);
      dg := (C2.Y - C1.Y) / trunc(x2 - x1);
      db := (C2.Z - C1.Z) / trunc(x2 - x1);
      da := (C2.W - C1.W) / trunc(x2 - x1);
   end
   else
   begin
      dx := (x2 - x1);
      PC := GetAverageColour(_C1,_C2);
   end;


   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U < x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PC.W := PC.W + da;
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector3f);
var
   dx, dr, dg, db : real;
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
   if (x2 - x1) > 1 then
   begin
      dx := (x2 - x1) / trunc(x2 - x1);
    	dr := (C2.X - C1.X) / trunc(x2 - x1);
      dg := (C2.Y - C1.Y) / trunc(x2 - x1);
      db := (C2.Z - C1.Z) / trunc(x2 - x1);
      PC := SetVector(C1);
   end
   else
   begin
      dx := (x2 - x1);
      PC := GetAverageColour(_C1,_C2);
   end;


   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U < x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintGouraudHorizontalLine(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
var
   dx, dr, dg, db, da : real;
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
   if (x2 - x1) > 1 then
   begin
      dx := (x2 - x1) / trunc(x2 - x1);
    	dr := (C2.X - C1.X) / trunc(x2 - x1);
      dg := (C2.Y - C1.Y) / trunc(x2 - x1);
      db := (C2.Z - C1.Z) / trunc(x2 - x1);
      da := (C2.W - C1.W) / trunc(x2 - x1);
      PC := SetVector(C1);
   end
   else
   begin
      dx := (x2 - x1);
      PC := GetAverageColour(_C1,_C2);
   end;


   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U < x2 do
   begin
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PC.X := PC.X + dr;
      PC.Y := PC.Y + dg;
      PC.Z := PC.Z + db;
      PC.W := PC.W + da;
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintHorizontalLineNCM(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
const
   C_EPSILON = 0.000001;
var
   dx, dr, dg, db, da : real;
   x2, x1 : single;
   C1, C2, PC, PN : TVector4f;
   PP : TVector2f;
   iStart, iEnd, iSize, iStep, iCurrent, iPrevious, iNext: real;
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

   iStart := x1 + (((1 - AreColoursSimilar(C1.X, C1.Y, C1.Z, C2.X, C2.Y, C2.Z)) / 2) * (x2 - x1));
   iEnd := x2 - (iStart - x1);
   iSize := iEnd - iStart;

   // get the gradients for each colour channel
   if (x2 - x1) > 1 then
   begin
      dx := (x2 - x1) / trunc(x2 - x1);
      if iSize > C_EPSILON then
      begin
         dr := (C2.X - C1.X) / iSize;
         dg := (C2.Y - C1.Y) / iSize;
         db := (C2.Z - C1.Z) / iSize;
         da := (C2.W - C1.W) / iSize;
      end
      else
      begin
         if iSize < C_EPSILON then
            iSize := C_EPSILON;
         dr := (C2.X - C1.X);
         dg := (C2.Y - C1.Y);
         db := (C2.Z - C1.Z);
         da := (C2.W - C1.W);
      end;
      PC := SetVector(C1);
   end
   else
   begin
      dx := (x2 - x1);
      PC := GetAverageColour(_C1,_C2);
   end;

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   iCurrent := 0;
   PN := SetVector(PC);
   while PP.U < x2 do
   begin
      if (PP.U - iStart + dx) > 0 then
      begin
         if iCurrent < iSize then
         begin
            iStep := (PP.U - iStart + dx) - iCurrent;
            if iStart > PP.U then
            begin
               iPrevious := iStart - PP.U;
            end
            else
            begin
               iPrevious := 0;
            end;
            if ((iStep + iCurrent) > iSize) then
            begin
               if iSize > C_EPSILON then
               begin
                  iStep := iSize - iCurrent;
                  iNext := (PP.U + dx) - iEnd;
               end
               else
               begin
                  iStep := 0;
                  iNext := dx;
               end;
            end
            else
            begin
               iNext := 0;
            end;
            if iStep > 0 then
            begin
               PC := SetVector(PN);
               PN.X := PN.X + (iStep * dr);
               PN.Y := PN.Y + (iStep * dg);
               PN.Z := PN.Z + (iStep * db);
               PN.W := PN.W + (iStep * da);
               PC.X := ((PC.X * iPrevious) + (PC.X * iStep) + ((PN.X - PC.X) * iStep * 0.5) + (PN.X * iNext)) / dx;
               PC.Y := ((PC.Y * iPrevious) + (PC.Y * iStep) + ((PN.Y - PC.Y) * iStep * 0.5) + (PN.Y * iNext)) / dx;
               PC.Z := ((PC.Z * iPrevious) + (PC.Z * iStep) + ((PN.Z - PC.Z) * iStep * 0.5) + (PN.Z * iNext)) / dx;
               PC.W := ((PC.W * iPrevious) + (PC.W * iStep) + ((PN.W - PC.W) * iStep * 0.5) + (PN.W * iNext)) / dx;
            end
            else
            begin
               PC.X := PN.X + dr;
               PC.Y := PN.Y + dg;
               PC.Z := PN.Z + db;
               PC.W := PN.W + da;
               PN.X := PN.X + dr;
               PN.Y := PN.Y + dg;
               PN.Z := PN.Z + db;
               PN.W := PN.W + da;
               iStep := 1;
            end;
            iCurrent := iCurrent + iStep;
         end;
      end;
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintHorizontalLineNCM(var _Buffer, _WeightBuffer: TAbstract2DImageData; _X1, _X2, _Y : single; _C1, _C2: TVector4f);
const
   C_EPSILON = 0.000001;
var
   dx, dr, dg, db, da : real;
   x2, x1 : single;
   C1, C2, PC, PN : TVector4f;
   PP : TVector2f;
   iStart, iEnd, iSize, iStep, iCurrent, iPrevious, iNext: real;
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

   iStart := x1 + (((1 - AreColoursSimilar(C1.X, C1.Y, C1.Z, C2.X, C2.Y, C2.Z)) / 2) * (x2 - x1));
   iEnd := x2 - (iStart - x1);
   iSize := iEnd - iStart;

   // get the gradients for each colour channel
   if (x2 - x1) > 1 then
   begin
      dx := (x2 - x1) / trunc(x2 - x1);
      if iSize > C_EPSILON then
      begin
         dr := (C2.X - C1.X) / iSize;
         dg := (C2.Y - C1.Y) / iSize;
         db := (C2.Z - C1.Z) / iSize;
         da := (C2.W - C1.W) / iSize;
      end
      else
      begin
         if iSize < C_EPSILON then
            iSize := C_EPSILON;
         dr := (C2.X - C1.X);
         dg := (C2.Y - C1.Y);
         db := (C2.Z - C1.Z);
         da := (C2.W - C1.W);
      end;
      PC := SetVector(C1);
   end
   else
   begin
      dx := (x2 - x1);
      PC := GetAverageColour(_C1,_C2);
   end;

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   PN := SetVector(PC);
   iCurrent := 0;
   while PP.U < x2 do
   begin
      if (PP.U - iStart + dx) > 0 then
      begin
         if iCurrent < iSize then
         begin
            iStep := (PP.U - iStart + dx) - iCurrent;
            if iStart > PP.U then
            begin
               iPrevious := iStart - PP.U;
            end
            else
            begin
               iPrevious := 0;
            end;
            if ((iStep + iCurrent) > iSize) then
            begin
               if iSize > C_EPSILON then
               begin
                  iStep := iSize - iCurrent;
                  iNext := (PP.U + dx) - iEnd;
               end
               else
               begin
                  iStep := 0;
                  iNext := dx;
               end;
            end
            else
            begin
               iNext := 0;
            end;
            if iStep > 0 then
            begin
               PC := SetVector(PN);
               PN.X := PN.X + (iStep * dr);
               PN.Y := PN.Y + (iStep * dg);
               PN.Z := PN.Z + (iStep * db);
               PN.W := PN.W + (iStep * da);
               PC.X := ((PC.X * iPrevious) + (PC.X * iStep) + ((PN.X - PC.X) * iStep * 0.5) + (PN.X * iNext)) / dx;
               PC.Y := ((PC.Y * iPrevious) + (PC.Y * iStep) + ((PN.Y - PC.Y) * iStep * 0.5) + (PN.Y * iNext)) / dx;
               PC.Z := ((PC.Z * iPrevious) + (PC.Z * iStep) + ((PN.Z - PC.Z) * iStep * 0.5) + (PN.Z * iNext)) / dx;
               PC.W := ((PC.W * iPrevious) + (PC.W * iStep) + ((PN.W - PC.W) * iStep * 0.5) + (PN.W * iNext)) / dx;
            end
            else
            begin
               PC.X := PN.X + dr;
               PC.Y := PN.Y + dg;
               PC.Z := PN.Z + db;
               PC.W := PN.W + da;
               PN.X := PN.X + dr;
               PN.Y := PN.Y + dg;
               PN.Z := PN.Z + db;
               PN.W := PN.W + da;
               iStep := 1;
            end;
            iCurrent := iCurrent + iStep;
         end;
      end;
      PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PP, PC);
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintBumpHorizontalLine(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _X1, _X2, _Y : single; _Size: integer);
var
   x2, x1 : single;
   PP : TVector2f;
   dx: real;
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

   if (x2 - x1) > 1 then
      dx := (x2 - x1) / trunc(x2 - x1)
   else
      dx := (x2 - x1);

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U < x2 do
   begin
      PaintBumpValueAtFrameBuffer(_Buffer, _HeightMap, PP.U, PP.V,_Size);
      PP.U := PP.U + dx;
   end;
end;

procedure CTriangleFiller.PaintBumpHorizontalLine(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _X1, _X2, _Y : single; _Size: integer);
var
   x2, x1 : single;
   PP : TVector2f;
   dx: real;
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

   if (x2 - x1) > 1 then
      dx := (x2 - x1) / trunc(x2 - x1)
   else
      dx := (x2 - x1);

   //  Now, let's start the painting procedure:
   PP := SetVector(x1,_Y);
   while PP.U < x2 do
   begin
      PaintBumpValueAtFrameBuffer(_Buffer, _HeightMap, PP.U, PP.V,_Size);
      PP.U := PP.U + dx;
   end;
end;


// Triangle Utils
procedure CTriangleFiller.GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector3f; var _dx, _dr, _dg, _db: single);
var
   VSize: real;
begin
   VSize := trunc(abs(_P2.V - _P1.V));
   if VSize > 1 then
   begin
      _dx := (_P2.U - _P1.U) / VSize;
	   _dr := (_C2.X - _C1.X) / VSize;
	   _dg := (_C2.Y - _C1.Y) / VSize;
	   _db := (_C2.Z - _C1.Z) / VSize;
   end
   else
   begin
      _dx := (_P2.U - _P1.U);
	   _dr := (_C2.X - _C1.X);
	   _dg := (_C2.Y - _C1.Y);
	   _db := (_C2.Z - _C1.Z);
   end;
end;

procedure CTriangleFiller.GetGradient(const _P2, _P1: TVector2f; const _C2, _C1: TVector4f; var _dx, _dr, _dg, _db, _da: single);
var
   VSize: real;
begin
   VSize := trunc(abs(_P2.V - _P1.V));
   if VSize > 1 then
   begin
      _dx := (_P2.U - _P1.U) / VSize;
   	_dr := (_C2.X - _C1.X) / VSize;
	   _dg := (_C2.Y - _C1.Y) / VSize;
   	_db := (_C2.Z - _C1.Z) / VSize;
	   _da := (_C2.W - _C1.W) / VSize;
   end
   else
   begin
      _dx := (_P2.U - _P1.U);
   	_dr := (_C2.X - _C1.X);
	   _dg := (_C2.Y - _C1.Y);
   	_db := (_C2.Z - _C1.Z);
	   _da := (_C2.W - _C1.W);
   end;
end;

procedure CTriangleFiller.GetGradientNCM(const _P2, _P1: TVector2f; const _C2, _C1: TVector4f; var _dy, _dx, _dr, _dg, _db, _da: single; var _iStart, _iEnd: real);
const
   C_EPSILON = 0.000001;
var
   iStart, iEnd, iSize: real;
begin
   _iStart := _P1.V + (((1 - AreColoursSimilar(_C1.X, _C1.Y, _C1.Z, _C2.X, _C2.Y, _C2.Z)) / 2) * (_P2.V - _P1.V));
   _iEnd := _P2.V - (_iStart - _P1.V);
   iSize := _iEnd - _iStart;

   if abs(_P2.V - _P1.V) > 1 then
   begin
      _dy := (_P2.V - _P1.V) / trunc(abs(_P2.V - _P1.V));
      _dx := (_P2.U - _P1.U) / abs(_P2.V - _P1.V);
   end
   else
   begin
      _dy := (_P2.V - _P1.V);
      _dx := (_P2.U - _P1.U);
   end;
   if iSize > C_EPSILON then
   begin
      _dr := (_C2.X - _C1.X) / iSize;
	   _dg := (_C2.Y - _C1.Y) / iSize;
	   _db := (_C2.Z - _C1.Z) / iSize;
	   _da := (_C2.W - _C1.W) / iSize;
   end
   else
   begin
      _dr := (_C2.X - _C1.X);
	   _dg := (_C2.Y - _C1.Y);
	   _db := (_C2.Z - _C1.Z);
	   _da := (_C2.W - _C1.W);
   end;
end;

procedure CTriangleFiller.GetGradient(const _P2, _P1: TVector2f; var _dx: single);
begin
   _dx := trunc(abs(_P2.V - _P1.V));
   if _dx > 1 then
   begin
      _dx := (_P2.U - _P1.U) / trunc(abs(_P2.V - _P1.V));
   end
   else
   begin
      _dx := (_P2.U - _P1.U);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real);
var
   dy: real;
begin
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      dy := (_FinalPos.V - _SP.V) / trunc(_FinalPos.V - _SP.V);
      while (_SP.V < _FinalPos.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + dy);
         _EP := SetVector(_EP.U + _dxe, _EP.V + dy);
         _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs);
         _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2));
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real);
var
   dy: real;
begin
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      dy := (_FinalPos.V - _SP.V) / trunc(_FinalPos.V - _SP.V);
      while (_SP.V < _FinalPos.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + dy);
         _EP := SetVector(_EP.U + _dxe, _EP.V + dy);
         _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs, _SC.W + _das);
         _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe, _EC.W + _dae);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector3f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe: real);
var
   dy: real;
begin
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      dy := (_FinalPos.V - _SP.V) / trunc(_FinalPos.V - _SP.V);
      while (_SP.V < _FinalPos.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + dy);
         _EP := SetVector(_EP.U + _dxe, _EP.V + dy);
         _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs);
         _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2));
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real);
var
   dy: real;
begin
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      dy := (_FinalPos.V - _SP.V) / trunc(_FinalPos.V - _SP.V);
      while (_SP.V < _FinalPos.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + dy);
         _EP := SetVector(_EP.U + _dxe, _EP.V + dy);
         _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs, _SC.W + _das);
         _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe, _EC.W + _dae);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePieceNCM(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dys, _dye, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae, _iStart1, _iEnd1,_iStart2,_iEnd2: real);
const
   C_EPSILON = 0.000001;
var
   iSize1, iSize2, iCurrent1, iCurrent2, iStep1, iStep2, iPrevious1, iPrevious2, iNext1, iNext2: real;
   SN, EN: TVector4f;
begin
   iSize1 := _iEnd1 - _iStart1;
   iSize2 := _iEnd2 - _iStart2;
   if iSize1 < C_EPSILON then
      iSize1 := C_EPSILON;
   if iSize2 < C_EPSILON then
      iSize2 := C_EPSILON;
   iCurrent1 := 0;
   iCurrent2 := 0;
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      SN := SetVector(_SC);
      EN := SetVector(_EC);
      while (_SP.V < _FinalPos.V) do
      begin
         if (_SP.V  - _iStart1 + _dys) > 0 then
         begin
            if iCurrent1 < iSize1 then
            begin
               iStep1 := (_SP.V - _iStart1 + _dys) - iCurrent1;
               if _iStart1 > _SP.V then
               begin
                  iPrevious1 := _iStart1 - _SP.V;
               end
               else
               begin
                  iPrevious1 := 0;
               end;
               if ((iStep1 + iCurrent1) > iSize1) then
               begin
                  if iSize1 > C_EPSILON then
                  begin
                     iStep1 := iSize1 - iCurrent1;
                     iNext1 := (_SP.V + _dys) - _iEnd1;
                  end
                  else
                  begin
                     iStep1 := 0;
                     iNext1 := _dys;
                  end;
               end
               else
               begin
                  iNext1 := 0;
               end;
               if iStep1 > 0 then
               begin
                  _SC := SetVector(SN);
                  SN := SetVector(SN.X + (iStep1 * _drs), SN.Y + (iStep1 * _dgs), SN.Z + (iStep1 * _dbs), SN.W + (iStep1 * _das));
                  _SC := SetVector(((_SC.X * iPrevious1) + (_SC.X * iStep1) + ((SN.X - _SC.X) * iStep1 * 0.5) + (SN.X * iNext1)) / _dys, ((_SC.Y * iPrevious1) + (_SC.Y * iStep1) + ((SN.Y - _SC.Y) * iStep1 * 0.5) + (SN.Y * iNext1)) / _dys, ((_SC.Z * iPrevious1) + (_SC.Z * iStep1) + ((SN.Z - _SC.Z) * iStep1 * 0.5) + (SN.Z * iNext1)) / _dys, ((_SC.W * iPrevious1) + (_SC.W * iStep1) + ((SN.W - _SC.W) * iStep1 * 0.5) + (SN.W * iNext1)) / _dys);
               end
               else
               begin
                  _SC := SetVector(SN.X + _drs, SN.Y + _dgs, SN.Z + _dbs, SN.W + _das);
                  SN := SetVector(SN.X + _drs, SN.Y + _dgs, SN.Z + _dbs, SN.W + _das);
               end;
               iCurrent1 := iCurrent1 + iStep1;
            end;
         end;
         if (_EP.V  - _iStart2 + _dye) > 0 then
         begin
            if iCurrent2 < iSize2 then
            begin
               iStep2 := (_EP.V - _iStart2 + _dye) - iCurrent2;
               if _iStart2 > _EP.V then
               begin
                  iPrevious2 := _iStart2 - _EP.V;
               end
               else
               begin
                  iPrevious2 := 0;
               end;
               if ((iStep2 + iCurrent2) > iSize2) then
               begin
                  if iSize2 > C_EPSILON then
                  begin
                     iStep2 := iSize2 - iCurrent2;
                     iNext2 := (_EP.V + _dye) - _iEnd2;
                  end
                  else
                  begin
                     iStep2 := 0;
                     iNext2 := _dye;
                  end;
               end
               else
               begin
                  iNext2 := 0;
               end;
               if iStep2 > 0 then
               begin
                  _EC := SetVector(EN);
                  EN := SetVector(EN.X + (iStep2 * _dre), EN.Y + (iStep2 * _dge), EN.Z + (iStep2 * _dbe), EN.W + (iStep2 * _dae));
                  _EC := SetVector(((_EC.X * iPrevious2) + (_EC.X * iStep2) + ((EN.X - _EC.X) * iStep2 * 0.5) + (EN.X * iNext2)) / _dye, ((_EC.Y * iPrevious2) + (_EC.Y * iStep2) + ((EN.Y - _EC.Y) * iStep2 * 0.5) + (EN.Y * iNext2)) / _dye, ((_EC.Z * iPrevious2) + (_EC.Z * iStep2) + ((EN.Z - _EC.Z) * iStep2 * 0.5) + (EN.Z * iNext2)) / _dye, ((_EC.W * iPrevious2) + (_EC.W * iStep2) + ((EN.W - _EC.W) * iStep2 * 0.5) + (EN.W * iNext2)) / _dye);
               end
               else
               begin
                  _EC := SetVector(EN.X + _dre, EN.Y + _dge, EN.Z + _dbe, EN.W + _dae);
                  EN := SetVector(EN.X + _dre, EN.Y + _dge, EN.Z + _dbe, EN.W + _dae);
               end;
               iCurrent2 := iCurrent2 + iStep2;
            end;
         end;
         PaintHorizontalLineNCM(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + _dys);
         _EP := SetVector(_EP.U + _dxe, _EP.V + _dye);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      PaintHorizontalLineNCM(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePieceNCM(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dys, _dye, _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae,_iStart1, _iEnd1,_iStart2,_iEnd2: real);
const
   C_EPSILON = 0.000001;
var
   iSize1, iSize2, iCurrent1, iCurrent2, iStep1, iStep2, iPrevious1, iPrevious2, iNext1, iNext2: real;
   SN, EN: TVector4f;
begin
   iSize1 := _iEnd1 - _iStart1;
   iSize2 := _iEnd2 - _iStart2;
   if iSize1 < 0.00001 then
      iSize1 := 0.00001;
   if iSize2 < 0.00001 then
      iSize2 := 0.00001;
   iCurrent1 := 0;
   iCurrent2 := 0;
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      SN := SetVector(_SC);
      EN := SetVector(_EC);
      while (_SP.V < _FinalPos.V) do
      begin
         if (_SP.V  - _iStart1 + _dys) > 0 then
         begin
            if iCurrent1 < iSize1 then
            begin
               iStep1 := (_SP.V - _iStart1 + _dys) - iCurrent1;
               if _iStart1 > _SP.V then
               begin
                  iPrevious1 := _iStart1 - _SP.V;
               end
               else
               begin
                  iPrevious1 := 0;
               end;
               if ((iStep1 + iCurrent1) > iSize1) then
               begin
                  if iSize1 > C_EPSILON then
                  begin
                     iStep1 := iSize1 - iCurrent1;
                     iNext1 := (_SP.V + _dys) - _iEnd1;
                  end
                  else
                  begin
                     iStep1 := 0;
                     iNext1 := _dys;
                  end;
               end
               else
               begin
                  iNext1 := 0;
               end;
               if iStep1 > 0 then
               begin
                  _SC := SetVector(SN);
                  SN := SetVector(SN.X + (iStep1 * _drs), SN.Y + (iStep1 * _dgs), SN.Z + (iStep1 * _dbs), SN.W + (iStep1 * _das));
                  _SC := SetVector(((_SC.X * iPrevious1) + (_SC.X * iStep1) + ((SN.X - _SC.X) * iStep1 * 0.5) + (SN.X * iNext1)) / _dys, ((_SC.Y * iPrevious1) + (_SC.Y * iStep1) + ((SN.Y - _SC.Y) * iStep1 * 0.5) + (SN.Y * iNext1)) / _dys, ((_SC.Z * iPrevious1) + (_SC.Z * iStep1) + ((SN.Z - _SC.Z) * iStep1 * 0.5) + (SN.Z * iNext1)) / _dys, ((_SC.W * iPrevious1) + (_SC.W * iStep1) + ((SN.W - _SC.W) * iStep1 * 0.5) + (SN.W * iNext1)) / _dys);
               end
               else
               begin
                  _SC := SetVector(SN.X + _drs, SN.Y + _dgs, SN.Z + _dbs, SN.W + _das);
                  SN := SetVector(SN.X + _drs, SN.Y + _dgs, SN.Z + _dbs, SN.W + _das);
               end;
               iCurrent1 := iCurrent1 + iStep1;
            end;
         end;
         if (_EP.V  - _iStart2 + _dye) > 0 then
         begin
            if iCurrent2 < iSize2 then
            begin
               iStep2 := (_EP.V - _iStart2 + _dye) - iCurrent2;
               if _iStart2 > _EP.V then
               begin
                  iPrevious2 := _iStart2 - _EP.V;
               end
               else
               begin
                  iPrevious2 := 0;
               end;
               if ((iStep2 + iCurrent2) > iSize2) then
               begin
                  if iSize2 > C_EPSILON then
                  begin
                     iStep2 := iSize2 - iCurrent2;
                     iNext2 := (_EP.V + _dye) - _iEnd2;
                  end
                  else
                  begin
                     iStep2 := 0;
                     iNext2 := _dye;
                  end;
               end
               else
               begin
                  iNext2 := 0;
               end;
               if iStep2 > 0 then
               begin
                  _EC := SetVector(EN);
                  EN := SetVector(EN.X + (iStep2 * _dre), EN.Y + (iStep2 * _dge), EN.Z + (iStep2 * _dbe), EN.W + (iStep2 * _dae));
                  _EC := SetVector(((_EC.X * iPrevious2) + (_EC.X * iStep2) + ((EN.X - _EC.X) * iStep2 * 0.5) + (EN.X * iNext2)) / _dye, ((_EC.Y * iPrevious2) + (_EC.Y * iStep2) + ((EN.Y - _EC.Y) * iStep2 * 0.5) + (EN.Y * iNext2)) / _dye, ((_EC.Z * iPrevious2) + (_EC.Z * iStep2) + ((EN.Z - _EC.Z) * iStep2 * 0.5) + (EN.Z * iNext2)) / _dye, ((_EC.W * iPrevious2) + (_EC.W * iStep2) + ((EN.W - _EC.W) * iStep2 * 0.5) + (EN.W * iNext2)) / _dye);
               end
               else
               begin
                  _EC := SetVector(EN.X + _dre, EN.Y + _dge, EN.Z + _dbe, EN.W + _dae);
                  EN := SetVector(EN.X + _dre, EN.Y + _dge, EN.Z + _dbe, EN.W + _dae);
               end;
               iCurrent2 := iCurrent2 + iStep2;
            end;
         end;
         PaintHorizontalLineNCM(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + _dys);
         _EP := SetVector(_EP.U + _dxe, _EP.V + _dye);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      PaintHorizontalLineNCM(_Buffer,_WeightBuffer,_SP.U,_EP.U,_SP.V,_SC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; var _S, _E: TVector2f; const _FinalPos: TVector2f; const _dxs, _dxe: single; _Size: integer);
var
   dy: real;
begin
   if (_FinalPos.V - _S.V) > 1 then
   begin
      dy := (_FinalPos.V - _S.V) / trunc(_FinalPos.V - _S.V);
      while _S.V < _FinalPos.V do
      begin
	      PaintBumpHorizontalLine(_Buffer, _HeightMap,_S.U,_E.U,_S.V,_Size);
         _S := SetVector(_S.U + _dxs, _S.V + dy);
         _E := SetVector(_E.U + _dxe, _E.V + dy);
      end;
   end
   else
   begin
      PaintBumpHorizontalLine(_Buffer, _HeightMap,_S.U,_E.U,_S.V,_Size);
      _E := SetVector(_E.U + _dxe, _E.V + (_FinalPos.V - _S.V));
      _S := SetVector(_S.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePiece(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; var _S, _E: TVector2f; const _FinalPos: TVector2f; const _dxs, _dxe: single; _Size: integer);
var
   dy: real;
begin
   if (_FinalPos.V - _S.V) > 1 then
   begin
      dy := (_FinalPos.V - _S.V) / trunc(_FinalPos.V - _S.V);
      while _S.V < _FinalPos.V do
      begin
	      PaintBumpHorizontalLine(_Buffer, _HeightMap,_S.U,_E.U,_S.V,_Size);
         _S := SetVector(_S.U + _dxs, _S.V + dy);
         _E := SetVector(_E.U + _dxe, _E.V + dy);
      end;
   end
   else
   begin
      PaintBumpHorizontalLine(_Buffer, _HeightMap,_S.U,_E.U,_S.V,_Size);
      _E := SetVector(_E.U + _dxe, _E.V + (_FinalPos.V - _S.V));
      _S := SetVector(_S.U + _dxs, _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePieceBorder(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real);
var
   dy: real;
begin
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      dy := (_FinalPos.V - _SP.V) / trunc(_FinalPos.V - _SP.V);
      while (_SP.V < _FinalPos.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_SP.U + _dxs,_SP.V,_SC,_SC);
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_EP.U,_EP.U + _dxe,_EP.V,_EC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + dy);
         _EP := SetVector(_EP.U + _dxe, _EP.V + dy);
         _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs, _SC.W + _das);
         _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe, _EC.W + _dae);
   	end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_SP.U + _dxs,_SP.V,_SC,_SC);
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_EP.U,_EP.U + _dxe,_EP.V,_EC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _SP.V + _FinalPos.V);
   end;
end;

procedure CTriangleFiller.PaintTrianglePieceBorder(var _Buffer, _WeightBuffer: TAbstract2DImageData; var _SP, _EP: TVector2f; var _SC, _EC: TVector4f; const _FinalPos: TVector2f; const _dxs, _dxe, _drs, _dre, _dgs, _dge, _dbs, _dbe, _das, _dae: real);
var
   dy: real;
begin
   if (_FinalPos.V - _SP.V) > 1 then
   begin
      dy := (_FinalPos.V - _SP.V) / trunc(_FinalPos.V - _SP.V);
      while (_SP.V < _FinalPos.V) do
      begin
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_SP.U + _dxs,_SP.V,_SC,_SC);
         PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_EP.U,_EP.U + _dxe,_EP.V,_EC,_EC);
         _SP := SetVector(_SP.U + _dxs, _SP.V + dy);
         _EP := SetVector(_EP.U + _dxe, _EP.V + dy);
         _SC := SetVector(_SC.X + _drs, _SC.Y + _dgs, _SC.Z + _dbs, _SC.W + _das);
         _EC := SetVector(_EC.X + _dre, _EC.Y + _dge, _EC.Z + _dbe, _EC.W + _dae);
	   end;
   end
   else
   begin
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_SP.U,_SP.U + _dxs,_SP.V,_SC,_SC);
      PaintGouraudHorizontalLine(_Buffer,_WeightBuffer,_EP.U,_EP.U + _dxe,_EP.V,_EC,_EC);
      _SC := SetVector(_SC.X + (_drs / 2), _SC.Y + (_dgs / 2), _SC.Z + (_dbs / 2), _SC.W + (_das / 2));
      _EC := SetVector(_EC.X + (_dre / 2), _EC.Y + (_dge / 2), _EC.Z + (_dbe / 2), _EC.W + (_dae / 2));
      _EP := SetVector(_EP.U + _dxe, _EP.V + (_FinalPos.V - _SP.V));
      _SP := SetVector(_SP.U + _dxs, _SP.V + _FinalPos.V);
   end;
end;


procedure CTriangleFiller.PaintGouraudTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f);
var
   dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3 : single;
   SP, EP : TVector2f;
   SC, EC : TVector3f;
begin
   GetGradient(_P2,_P1,_C2,_C1,dx1,dr1,dg1,db1);
   GetGradient(_P3,_P1,_C3,_C1,dx2,dr2,dg2,db2);
   GetGradient(_P3,_P2,_C3,_C2,dx3,dr3,dg3,db3);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2);
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
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2);
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
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2);
	end;
end;

procedure CTriangleFiller.PaintGouraudTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector3f);
var
   dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3 : single;
   SP, EP : TVector2f;
   SC, EC : TVector3f;
begin
   GetGradient(_P2,_P1,_C2,_C1,dx1,dr1,dg1,db1);
   GetGradient(_P3,_P1,_C3,_C1,dx2,dr2,dg2,db2);
   GetGradient(_P3,_P2,_C3,_C2,dx3,dr3,dg3,db3);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePiece(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2);
	end;
end;

procedure CTriangleFiller.PaintNCMTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   dy1, dy2, dy3, dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3, da1, da2, da3 : single;
   SP, EP : TVector2f;
   SC, EC : TVector4f;
   iStart1, iEnd1, iStart2, iEnd2: real;
begin
   GetGradient(_P2,_P1,dx1);
   GetGradient(_P3,_P1,dx2);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      GetGradientNCM(_P2,_P1,_C2,_C1,dy1,dx1,dr1,dg1,db1,da1,iStart1,iEnd1);
      GetGradientNCM(_P3,_P1,_C3,_C1,dy2,dx2,dr2,dg2,db2,da2,iStart2,iEnd2);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dy2,dy1,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1,iStart1,iEnd1,iStart2,iEnd2);

      AssignPointColour(EP,EC,_P2,_C2);
      GetGradientNCM(_P3,_P2,_C3,_C2,dy3,dx3,dr3,dg3,db3,da3,iStart1,iEnd1);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dy2,dy3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3,iStart1,iEnd1,iStart2,iEnd2);
	end
   else
   begin
      GetGradientNCM(_P2,_P1,_C2,_C1,dy1,dx1,dr1,dg1,db1,da1,iStart1,iEnd1);
      GetGradientNCM(_P3,_P1,_C3,_C1,dy2,dx2,dr2,dg2,db2,da2,iStart2,iEnd2);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dy1,dy2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2,iStart1,iEnd1,iStart2,iEnd2);

      AssignPointColour(SP,SC,_P2,_C2);
      GetGradientNCM(_P3,_P2,_C3,_C2,dy3,dx3,dr3,dg3,db3,da3,iStart1,iEnd1);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dy3,dy2,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2,iStart1,iEnd1,iStart2,iEnd2);
	end;
end;

procedure CTriangleFiller.PaintNCMTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   dy1, dy2, dy3, dx1, dx2, dx3, dr1, dr2, dr3, dg1, dg2, dg3, db1, db2, db3, da1, da2, da3 : single;
   SP, EP : TVector2f;
   SC, EC : TVector4f;
   iStart1, iEnd1, iStart2, iEnd2: real;
begin
   GetGradient(_P2,_P1,dx1);
   GetGradient(_P3,_P1,dx2);

   AssignPointColour(SP,SC,_P1,_C1);
   AssignPointColour(EP,EC,_P1,_C1);
	if (dx1 > dx2) then
   begin
      GetGradientNCM(_P2,_P1,_C2,_C1,dy1,dx1,dr1,dg1,db1,da1,iStart1,iEnd1);
      GetGradientNCM(_P3,_P1,_C3,_C1,dy2,dx2,dr2,dg2,db2,da2,iStart2,iEnd2);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dy2,dy1,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1,iStart1,iEnd1,iStart2,iEnd2);

      AssignPointColour(EP,EC,_P2,_C2);
      GetGradientNCM(_P3,_P2,_C3,_C2,dy3,dx3,dr3,dg3,db3,da3,iStart2,iEnd2);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dy2,dy3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3,iStart1,iEnd1,iStart2,iEnd2);
	end
   else
   begin
      GetGradientNCM(_P2,_P1,_C2,_C1,dy1,dx1,dr1,dg1,db1,da1,iStart1,iEnd1);
      GetGradientNCM(_P3,_P1,_C3,_C1,dy2,dx2,dr2,dg2,db2,da2,iStart2,iEnd2);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dy1,dy2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2,iStart1,iEnd1,iStart2,iEnd2);

      AssignPointColour(SP,SC,_P2,_C2);
      GetGradientNCM(_P3,_P2,_C3,_C2,dy3,dx3,dr3,dg3,db3,da3,iStart1,iEnd1);
      PaintTrianglePieceNCM(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dy3,dy2,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2,iStart1,iEnd1,iStart2,iEnd2);
	end;
end;

procedure CTriangleFiller.PaintBumpMapTriangle(var _Buffer: T2DFrameBuffer; const _HeightMap: TByteMap; _P1, _P2, _P3 : TVector2f);
var
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
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2,dx2,dx1,Size);
      E := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3,dx2,dx3,Size);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2,dx1,dx2,Size);
      S := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3,dx3,dx2,Size);
	end;
end;

procedure CTriangleFiller.PaintBumpMapTriangle(var _Buffer: TAbstract2DImageData; const _HeightMap: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f);
var
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
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2,dx2,dx1,Size);
      E := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3,dx2,dx3,Size);
	end
   else
   begin
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P2,dx1,dx2,Size);
      S := SetVector(_P2);
      PaintTrianglePiece(_Buffer,_HeightMap,S,E,_P3,dx3,dx2,Size);
	end;
end;

procedure CTriangleFiller.PaintGouraudTriangleBorder(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
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
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3);
	end
   else
   begin
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2);
	end;
end;

procedure CTriangleFiller.PaintGouraudTriangleBorder(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
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
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx2,dx1,dr2,dr1,dg2,dg1,db2,db1,da2,da1);

      AssignPointColour(EP,EC,_P2,_C2);
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx2,dx3,dr2,dr3,dg2,dg3,db2,db3,da2,da3);
	end
   else
   begin
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P2,dx1,dx2,dr1,dr2,dg1,dg2,db1,db2,da1,da2);

      AssignPointColour(SP,SC,_P2,_C2);
      PaintTrianglePieceBorder(_Buffer,_WeightBuffer,SP,EP,SC,EC,_P3,dx3,dx2,dr3,dr2,dg3,dg2,db3,db2,da3,da2);
	end;
end;




// Public methods starts here.

procedure CTriangleFiller.PaintTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   P1, P2, P3 : TVector2f;
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

procedure CTriangleFiller.PaintTriangleNCM(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   P1, P2, P3 : TVector2f;
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
         PaintNCMTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_C3,_C2,_C1);
      end
      else
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P2 < P3 < P1
            PaintNCMTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_C2,_C3,_C1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintNCMTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_C2,_C1,_C3);
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
            PaintNCMTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_C3,_C1,_C2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintNCMTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_C1,_C3,_C2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintNCMTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_C1,_C2,_C3);
      end;
   end;
end;

procedure CTriangleFiller.PaintTriangleNCM(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f; _C1, _C2, _C3: TVector4f);
var
   P1, P2, P3 : TVector2f;
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
         PaintNCMTriangle(_Buffer,_WeightBuffer,P3,P2,P1,_C3,_C2,_C1);
      end
      else
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P2 < P3 < P1
            PaintNCMTriangle(_Buffer,_WeightBuffer,P2,P3,P1,_C2,_C3,_C1);
         end
         else
         begin
            // P2 < P1 < P3
            PaintNCMTriangle(_Buffer,_WeightBuffer,P2,P1,P3,_C2,_C1,_C3);
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
            PaintNCMTriangle(_Buffer,_WeightBuffer,P3,P1,P2,_C3,_C1,_C2);
         end
         else
         begin
            // P1 < P3 < P2
            PaintNCMTriangle(_Buffer,_WeightBuffer,P1,P3,P2,_C1,_C3,_C2);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintNCMTriangle(_Buffer,_WeightBuffer,P1,P2,P3,_C1,_C2,_C3);
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

procedure CTriangleFiller.PaintDebugTriangle(var _Buffer: T2DFrameBuffer; var _WeightBuffer: TWeightBuffer; _P1, _P2, _P3 : TVector2f);
var
   P1, P2, P3, PC : TVector2f;
   CX : TVector4f;
   Size : integer;
   Perimeterx2, D12, D23, D31 : single;
begin
   Size := High(_Buffer[0])+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);

   // We'll do things in a different way here.
   // 1) paint center of triangle:

   // Detect Central position.
   D12 := VectorDistance(P1, P2);
   D23 := VectorDistance(P2, P3);
   D31 := VectorDistance(P3, P1);
   Perimeterx2 := (D12 + D23 + D31) * 2;
   PC.U := (P1.U * ((D12 + D31) / Perimeterx2)) + (P2.U * ((D12 + D23) / Perimeterx2)) + (P3.U * ((D23 + D31) / Perimeterx2));
   PC.V := (P1.V * ((D12 + D31) / Perimeterx2)) + (P2.V * ((D12 + D23) / Perimeterx2)) + (P3.V * ((D23 + D31) / Perimeterx2));
   // Set Center colour, should be a green.
   CX.X := 0;
   CX.Y := 1;
   CX.Z := 0;
   CX.W := 0;
   // Paint it.
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PC, CX);

   // 2) paint the edges.
   // Set edge colour, should be a blue.
   CX.X := 0;
   CX.Y := 0;
   CX.Z := 1;
   CX.W := 0;

   if IsP1HigherThanP2(P1,P2) then
   begin
      if IsP1HigherThanP2(P2,P3) then
      begin
         // P3 < P2 < P1
         PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P3,P2,P1,CX,CX,CX);
      end
      else
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P2 < P3 < P1
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P2,P3,P1,CX,CX,CX);
         end
         else
         begin
            // P2 < P1 < P3
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P2,P1,P3,CX,CX,CX);
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
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P3,P1,P2,CX,CX,CX);
         end
         else
         begin
            // P1 < P3 < P2
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P1,P3,P2,CX,CX,CX);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P1,P2,P3,CX,CX,CX);
      end;
   end;

   // 3) Paint vertexes.
   // Set vertex colour, should be red.
   CX.X := 1;
   CX.Y := 0;
   CX.Z := 0;
   CX.W := 0;

   // Paint it.
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, P1, CX);
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, P2, CX);
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, P3, CX);
end;

procedure CTriangleFiller.PaintDebugTriangle(var _Buffer, _WeightBuffer: TAbstract2DImageData; _P1, _P2, _P3 : TVector2f);
var
   P1, P2, P3, P12, P23, P31, PC : TVector2f;
   CX : TVector4f;
   Size : integer;
   Perimeter, D12, D23, D31 : single;
begin
   Size := _Buffer.MaxX+1;
   P1 := ScaleVector(_P1,Size);
   P2 := ScaleVector(_P2,Size);
   P3 := ScaleVector(_P3,Size);

   // We'll do things in a different way here.
   // 1) paint center of triangle:

   // Detect Central position.
   D12 := VectorDistance(P1, P2);
   D23 := VectorDistance(P2, P3);
   D31 := VectorDistance(P3, P1);
   P12.U := (P1.U + P2.U) / 2;
   P12.V := (P1.V + P2.V) / 2;
   P23.U := (P2.U + P3.U) / 2;
   P23.V := (P2.V + P3.V) / 2;
   P31.U := (P3.U + P1.U) / 2;
   P31.V := (P3.V + P1.V) / 2;
   Perimeter := (D12 + D23 + D31);
   PC.U := (P23.U * (D23 / Perimeter)) + (P31.U * (D31 / Perimeter)) + (P12.U * (D12 / Perimeter));
   PC.V := (P23.V * (D23 / Perimeter)) + (P31.V * (D31 / Perimeter)) + (P12.V * (D12 / Perimeter));
   // Set Center colour, should be a green.
   CX.X := 0;
   CX.Y := 1;
   CX.Z := 0;
   CX.W := 1;
   // Paint it.
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, PC, CX);

   // 2) paint the edges.
   // Set edge colour, should be a blue.
   CX.X := 0;
   CX.Y := 0;
   CX.Z := 1;
   CX.W := 1;
   if IsP1HigherThanP2(P1,P2) then
   begin
      if IsP1HigherThanP2(P2,P3) then
      begin
         // P3 < P2 < P1
         PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P3,P2,P1,CX,CX,CX);
      end
      else
      begin
         if IsP1HigherThanP2(P1,P3) then
         begin
            // P2 < P3 < P1
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P2,P3,P1,CX,CX,CX);
         end
         else
         begin
            // P2 < P1 < P3
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P2,P1,P3,CX,CX,CX);
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
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P3,P1,P2,CX,CX,CX);
         end
         else
         begin
            // P1 < P3 < P2
            PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P1,P3,P2,CX,CX,CX);
         end;
      end
      else
      begin
         // P1 < P2 < P3
         PaintGouraudTriangleBorder(_Buffer,_WeightBuffer,P1,P2,P3,CX,CX,CX);
      end;
   end;

   // 3) Paint vertexes.
   // Set vertex colour, should be white.
   CX.X := 1;
   CX.Y := 1;
   CX.Z := 0;
   CX.W := 1;

   // Paint it.
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, P1, CX);
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, P2, CX);
   PaintPixelAtFrameBuffer(_Buffer, _WeightBuffer, P3, CX);
end;

end.
