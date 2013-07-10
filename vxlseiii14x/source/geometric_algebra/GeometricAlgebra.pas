unit GeometricAlgebra;

interface

uses MultiVector, Metric, Math, BasicDataTypes, GADataTypes, GAConstants, SysUtils;

{$INCLUDE Global_Conditionals.inc}

type
   TVecOperationMethod = function (const _Vec1, _Vec2 : TMultiVector): TMultiVector of object;
   TSingleOperationMethod = function (const _Vec1, _Vec2 : TMultiVector): single of object;

   TGeometricAlgebra = class
   private
      FMetric: TMetric;
      FBitCountTable: auint32;
      FCannonicalOrderTable: aint32;
      FDimension: Cardinal;
      FAuxDimension: Cardinal;
      FSystemDimension: Cardinal;
   protected
      // Gets
      function GetDimension: Cardinal;
      function GetAuxDimension: Cardinal;
      function GetSystemDimension: Cardinal;
      function GetCannonicalOrderTable(_X,_Y: cardinal): integer;

      // Sets
      procedure SetDimension(_Dimension: cardinal);
      procedure QuickSetDimension(_Dimension: cardinal);
      procedure SetOrthogonalMetric;
      procedure SetNonOrthogonalMetric;
      procedure SetCannonicalOrderTable(_X,_Y: cardinal; _Value: integer);

      // MultiVector Operations
      function OrthogonalGeometricProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function OrthogonalScalarProduct(const _Vec1, _Vec2: TMultiVector):single; overload;
      function OrthogonalLeftContractionProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function OrthogonalRightContractionProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function OrthogonalGeometricDivision(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function NonOrthogonalGeometricProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function NonOrthogonalScalarProduct(const _Vec1, _Vec2: TMultiVector):single; overload;
      function NonOrthogonalLeftContractionProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function NonOrthogonalRightContractionProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function NonOrthogonalGeometricDivision(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;

      // Base Operations
      function OuterProduct(const _Base1, _Base2: TBaseElement):TBaseElement; overload;
      function RegressiveProduct(const _Base1, _Base2: TBaseElement):TBaseElement; overload;
      function OrthogonalGeometricProduct(const _Base1, _Base2: TBaseElement):TBaseElement; overload;
      function OrthogonalScalarProduct(const _Base1, _Base2: TBaseElement):Single; overload;
      function OrthogonalXContractionProduct(const _Base1, _Base2: TBaseElement; _MaxGrade: cardinal):TBaseElement;

      // Misc
      function canonical_reordering(_bitmap1, _bitmap2: cardinal): integer;
      function canonical_reordering_euclidean(_bitmap1, _bitmap2: Cardinal): integer;
      function canonical_reordering_homogeneous(_bitmap1, _bitmap2: Cardinal): integer;
      function canonical_reordering_conformal(_bitmap1, _bitmap2: Cardinal): integer;
      function bit_count(_bitmap: cardinal): word;
      function GetMetricMultiplier(_bitmap1, _bitmap2: cardinal): single;
   public
      // The following operations are dependent on metrics
      GeometricProduct: TVecOperationMethod;
      ScalarProduct: TSingleOperationMethod;
      LeftContraction: TVecOperationMethod;
      RightContraction: TVecOperationMethod;
      GeometricDivision: TVecOperationMethod;

      // Constructor
      constructor Create; overload;
      constructor Create(_Dimension: cardinal); overload;
      constructor CreateHomogeneous; overload;
      constructor CreateHomogeneous(_Dimension: cardinal); overload;
      constructor CreateConformal; overload;
      constructor CreateConformal(_Dimension: cardinal); overload;
      destructor Destroy; override;
      // Objects
      function NewEuclideanVector(const _Vector:TVector2f): TMultiVector; overload;
      function NewEuclideanVector(const _Vector:TVector3f): TMultiVector; overload;
      function NewEuclideanBiVector(const _Vector:TVector2f): TMultiVector; overload;
      function NewEuclideanBiVector(const _Vector:TVector3f): TMultiVector; overload;
      function NewHomogeneousFlat(const _Vector:TVector2f): TMultiVector; overload;
      function NewHomogeneousFlat(const _Vector:TVector3f): TMultiVector; overload;
      function NewEuclideanRotationVersor(const _Vector: TMultiVector; _angle: single): TMultiVector; overload;
      procedure BladeOfGradeFromVector(var _Vec:TMultiVector; _Grade: cardinal); overload;
      function GetBladeOfGradeFromVector(const _Vec:TMultiVector; _Grade: cardinal): TMultiVector; overload;
      procedure MultiplesGradeFromVector(var _Vec:TMultiVector; _GradesIDBitmap: cardinal);
      function GetMultiplesGradeFromVector(const _Vec:TMultiVector; _GradesIDBitmap: cardinal): TMultiVector;
      function GetEuclideanPartFromVector(const _Vec:TMultiVector): TMultiVector; overload;
      // Gets
      function GetMaxGrade(const _Vec: TMultiVector):cardinal;
      function GetNorm(const _Vec: TMultiVector):single;
      function GetSquaredNorm(const _Vec: TMultiVector):single; overload;
      function GetSquaredNorm(const _Vec,_Reverse: TMultiVector):single; overload;
      function GetSquaredNormOfGrade(const _Vec: TMultiVector; _Grade: cardinal): single;
      function GetLength(const _Vec: TMultiVector): single;
      function GetFlatDirection(const _Vec: TMultiVector): TMultiVector; overload;
      function GetFlatDirection(const _Vec,_e0: TMultiVector): TMultiVector; overload;
      function GetFlatMoment(const _Vec: TMultiVector): TMultiVector; overload;
      function GetFlatMoment(const _Vec,_e0: TMultiVector): TMultiVector; overload;
      function GetFlatSupportVector(const _Vec: TMultiVector): TMultiVector; overload;
      function GetFlatSupportVector(const _Vec,_e0: TMultiVector): TMultiVector; overload;
      function GetFlatUnitSupportPoint(const _Vec: TMultiVector): TMultiVector; overload;
      function GetFlatUnitSupportPoint(const _Vec,_e0: TMultiVector): TMultiVector; overload;

      function GetI:TMultiVector;
      function GetIInverse:TMultiVector;
      function GetHomogeneousE0: TMultiVector;
      // Sets
      procedure SetEuclideanMetric;
      procedure SetHomogeneousMetric;
      procedure SetConformalMetric;
      procedure SetMinkowskiConformalMetric;
      // Operations
      function OuterProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector; overload;
      function RegressiveProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      procedure Sum(var _Vec1: TMultiVector; const _Vec2: TMultiVector); overload;
      function GetSum(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      procedure Subtraction(var _Vec1:TMultiVector; const _Vec2: TMultiVector); overload;
      function GetSubtraction(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function ApplyRotor(const _Blade, _Rotor: TMultiVector):TMultiVector; overload;
      function ApplyRotor(const _Blade, _Rotor,_InverseRotor: TMultiVector):TMultiVector; overload;
      procedure HomogeneousTranslation(var _Vec: TMultiVector; const _Offset: TMultiVector);
      function GetHomogeneousTranslation(const _Vec,_Offset: TMultiVector): TMultiVector;
      procedure HomogeneousOppositeTranslation(var _Vec: TMultiVector; const _Offset: TMultiVector);
      function GetHomogeneousOppositeTranslation(const _Vec,_Offset: TMultiVector): TMultiVector;

      // Individual operations.
      function GetReverse(const _Vec: TMultiVector):TMultiVector; overload;
      procedure Reverse(var _Vec: TMultiVector); overload;
      function GetGradeInvolution(const _Vec: TMultiVector):TMultiVector; overload;
      procedure GradeInvolution(var _Vec: TMultiVector); overload;
      function GetCliffordConjugation(const _Vec: TMultiVector):TMultiVector;
      procedure CliffordConjugation(var _Vec: TMultiVector);
      function GetInverse(const _Vec:TMultiVector): TMultiVector; overload;
      function GetInverse(const _Vec,_Reverse:TMultiVector): TMultiVector; overload;
      function GetInverse(const _Vec,_Reverse:TMultiVector; _Norm: single): TMultiVector; overload;
      procedure Inverse(var _Vec:TMultiVector); overload;
      procedure Inverse(var _Vec: TMultiVector; const _Reverse:TMultiVector); overload;
      procedure Inverse(var _Vec: TMultiVector; const _Reverse:TMultiVector; _Norm: single); overload;
      function GetDual(const _Vec:TMultiVector):TMultiVector;
      procedure Dual(var _Vec:TMultiVector);
      function GetUndual(const _Vec:TMultiVector):TMultiVector;
      procedure Undual(var _Vec:TMultiVector);
      function Normalize(const _Vec:TMultiVector):TMultiVector;
      procedure ScaleVector(var _Vec: TMultiVector; _Scale: single);
      procedure ScaleEuclideanDataFromVector(var _Vec: TMultiVector; _Scale: single);
      procedure ScaleHomogeneousDataFromVector(var _Vec: TMultiVector; _Scale: single);
      function Euclidean3DLogarithm(const _Vec: TMultiVector): TMultiVector;

      // Properties
      property SystemDimension: cardinal read GetSystemDimension;
      property AuxDimension: cardinal read GetAuxDimension;
      property Dimension:cardinal read GetDimension write SetDimension;
   end;

implementation

uses GlobalVars;

// Constructor
constructor TGeometricAlgebra.Create;
begin
   FSystemDimension := 0;
   FDimension := 3;
   FMetric := TMetric.Create();
   SetEuclideanMetric;
end;

constructor TGeometricAlgebra.Create(_Dimension: cardinal);
begin
   FSystemDimension := 0;
   FDimension := _Dimension;
   FMetric := TMetric.Create();
   SetEuclideanMetric;
end;

constructor TGeometricAlgebra.CreateHomogeneous;
begin
   FSystemDimension := 0;
   FDimension := 3;
   FMetric := TMetric.Create();
   SetHomogeneousMetric;
end;

constructor TGeometricAlgebra.CreateHomogeneous(_Dimension: cardinal);
begin
   FSystemDimension := 0;
   FDimension := _Dimension;
   FMetric := TMetric.Create();
   SetHomogeneousMetric;
end;

constructor TGeometricAlgebra.CreateConformal;
begin
   FSystemDimension := 0;
   FDimension := 3;
   FMetric := TMetric.Create();
   SetConformalMetric;
end;

constructor TGeometricAlgebra.CreateConformal(_Dimension: cardinal);
begin
   FSystemDimension := 0;
   FDimension := _Dimension;
   FMetric := TMetric.Create();
   SetConformalMetric;
end;

destructor TGeometricAlgebra.Destroy;
begin
   SetLength(FBitCountTable,0);
   FMetric.Free;
   inherited Destroy;
end;

// Objects
// Euclidean direction.
function TGeometricAlgebra.NewEuclideanVector(const _Vector:TVector2f): TMultiVector;
begin
   Result := TMultiVector.Create(FSystemDimension);
   Result.UnsafeData[1] := _Vector.U;
   Result.UnsafeData[2] := _Vector.V;
end;

function TGeometricAlgebra.NewEuclideanVector(const _Vector:TVector3f): TMultiVector;
begin
   Result := TMultiVector.Create(FSystemDimension);
   Result.UnsafeData[1] := _Vector.X;
   Result.UnsafeData[2] := _Vector.Y;
   Result.UnsafeData[4] := _Vector.Z;
end;

// Euclidean rotation direction.
function TGeometricAlgebra.NewEuclideanBiVector(const _Vector:TVector2f): TMultiVector;
begin
   Result := NewEuclideanVector(_Vector);
   Undual(Result);
end;

function TGeometricAlgebra.NewEuclideanBiVector(const _Vector:TVector3f): TMultiVector;
begin
   Result := NewEuclideanVector(_Vector);
   Undual(Result);
end;

// Homogeneous Flat
function TGeometricAlgebra.NewHomogeneousFlat(const _Vector:TVector2f): TMultiVector;
var
   AuxBit: cardinal;
begin
   AuxBit := 1 shl FDimension;

   Result := TMultiVector.Create(FSystemDimension);
   Result.UnsafeData[1] := _Vector.U;
   Result.UnsafeData[2] := _Vector.V;
   Result.UnsafeData[AuxBit] := 1;
end;

function TGeometricAlgebra.NewHomogeneousFlat(const _Vector:TVector3f): TMultiVector;
var
   AuxBit: cardinal;
begin
   AuxBit := 1 shl FDimension;

   Result := TMultiVector.Create(FSystemDimension);
   Result.UnsafeData[1] := _Vector.X;
   Result.UnsafeData[2] := _Vector.Y;
   Result.UnsafeData[4] := _Vector.Z;
   Result.UnsafeData[AuxBit] := 1;
end;

// Rotation Versor in euclidean space from a Blade<2>.
// Angle is in radians.
function TGeometricAlgebra.NewEuclideanRotationVersor(const _Vector: TMultiVector; _angle: single): TMultiVector;
var
   sinAngle: single;
   i: cardinal;
begin
   Result := TMultiVector.Create(FSystemDimension);
   Result.UnsafeData[0] := cos(_Angle);
   sinAngle := (-1) * sin(_Angle);
   for i := 3 to Result.GetMaxElementForGrade(FDimension) do
   begin
      if FBitCountTable[i] = 2 then
      begin
         Result.UnsafeData[i] := _Vector.UnsafeData[i] * sinAngle;
      end;
   end;
end;

procedure TGeometricAlgebra.BladeOfGradeFromVector(var _Vec:TMultiVector; _Grade: cardinal);
var
   i : cardinal;
begin
   for i := 0 to _Vec.MaxElement do
   begin
      if FBitCountTable[i] = _Grade then
      begin
         _Vec.UnsafeData[i] := _Vec.UnsafeData[i];
      end
      else
      begin
         _Vec.UnsafeData[i] := 0;
      end;
   end;
end;

function TGeometricAlgebra.GetBladeOfGradeFromVector(const _Vec:TMultiVector; _Grade: cardinal): TMultiVector;
var
   i : cardinal;
begin
   Result := TMultiVector.Create(_Vec.Dimension);
   for i := 0 to Result.MaxElement do
   begin
      if FBitCountTable[i] = _Grade then
      begin
         Result.UnsafeData[i] := _Vec.UnsafeData[i];
      end
      else
      begin
         Result.UnsafeData[i] := 0;
      end;
   end;
end;

// Does the same thing as BladeOfGradeFromVector, but it allows you to extract
// multiples grades. I.e.: to extract grades 0 and 2, _GradesIDBitmap = 5
// (in binary: 101)
procedure TGeometricAlgebra.MultiplesGradeFromVector(var _Vec:TMultiVector; _GradesIDBitmap: cardinal);
var
   i : cardinal;
begin
   for i := 0 to _Vec.MaxElement do
   begin
      if FBitCountTable[i] and _GradesIDBitmap <> 0 then
      begin
         _Vec.UnsafeData[i] := _Vec.UnsafeData[i];
      end
      else
      begin
         _Vec.UnsafeData[i] := 0;
      end;
   end;
end;

// Does the same thing as GetBladeOfGradeFromVector, but it allows you to extract
// multiples grades. I.e.: to extract grades 0 and 2, _GradesIDBitmap = 5
// (in binary: 101)
function TGeometricAlgebra.GetMultiplesGradeFromVector(const _Vec:TMultiVector; _GradesIDBitmap: cardinal): TMultiVector;
var
   i : cardinal;
begin
   Result := TMultiVector.Create(_Vec.Dimension);
   for i := 0 to Result.MaxElement do
   begin
      if FBitCountTable[i] and _GradesIDBitmap <> 0 then
      begin
         Result.UnsafeData[i] := _Vec.UnsafeData[i];
      end
      else
      begin
         Result.UnsafeData[i] := 0;
      end;
   end;
end;

function TGeometricAlgebra.GetEuclideanPartFromVector(const _Vec:TMultiVector): TMultiVector;
var
   i,maxi : cardinal;
begin
   Result := TMultiVector.Create(_Vec.Dimension);
   i := 0;
   maxi := Result.GetMaxElementForGrade(FDimension);
   while i < maxi do
   begin
      Result.UnsafeData[i] := _Vec.UnsafeData[i];
      inc(i);
   end;
   maxi := _Vec.MaxElement;
   while i < maxi do
   begin
      Result.UnsafeData[i] := 0;
      inc(i);
   end;

end;

// Gets
function TGeometricAlgebra.GetDimension: Cardinal;
begin
   Result := FDimension;
end;

function TGeometricAlgebra.GetAuxDimension: Cardinal;
begin
   Result := FAuxDimension;
end;

function TGeometricAlgebra.GetSystemDimension: Cardinal;
begin
   Result := FSystemDimension;
end;

function TGeometricAlgebra.GetMaxGrade(const _Vec: TMultiVector):cardinal;
var
   i : cardinal;
begin
   Result := 0;
   i := _Vec.GetTheFirstNonZeroBitmap;
   while i <> C_INFINITY do
   begin
      if FBitCountTable[i] > Result then
         Result := FBitCountTable[i];
      i := _Vec.GetTheNextNonZeroBitmap(i);
   end;
end;

function TGeometricAlgebra.GetNorm(const _Vec: TMultiVector): single;
var
   Norm: single;
begin
   Norm := GetSquaredNorm(_Vec);
   Result := sqrt(abs(Norm)) * math.Sign(Norm);
end;

function TGeometricAlgebra.GetSquaredNormOfGrade(const _Vec: TMultiVector; _Grade: cardinal): single;
var
   Vec,Rev: TMultiVector;
begin
   Vec := GetBladeOfGradeFromVector(_Vec,_Grade);
   Rev := GetReverse(Vec);
   Result := OrthogonalScalarProduct(Rev,Vec);
   Vec.Free;
   Rev.Free;
end;

function TGeometricAlgebra.GetSquaredNorm(const _Vec: TMultiVector): single;
var
   Rev: TMultiVector;
begin
   Rev := GetReverse(_Vec);
   Result := OrthogonalScalarProduct(Rev,_Vec);
   Rev.Free;
end;

function TGeometricAlgebra.GetSquaredNorm(const _Vec,_Reverse: TMultiVector): single;
begin
   Result := OrthogonalScalarProduct(_Reverse,_Vec);
end;

// The good old Norm2 from linear algebra at Geometric Algebra, for positive norms.
function TGeometricAlgebra.GetLength(const _Vec: TMultiVector): single;
begin
   Result := sqrt(OrthogonalScalarProduct(_Vec,_Vec));
end;

function TGeometricAlgebra.GetI:TMultiVector;
begin
   Result := TMultiVector.Create(FSystemDimension);
   Result.UnsafeData[Result.MaxElement] := 1;
end;

function TGeometricAlgebra.GetIInverse:TMultiVector;
begin
   Result := TMultiVector.Create(FSystemDimension);
   if (FSystemDimension mod 4) > 1 then
   begin
      Result.UnsafeData[Result.MaxElement] := -1;
   end
   else
   begin
      Result.UnsafeData[Result.MaxElement] := 1;
   end;
end;

//e0, which is eFDimension in our case.
function TGeometricAlgebra.GetHomogeneousE0: TMultiVector;
var
   AuxBit: cardinal;
begin
   AuxBit := 1 shl FDimension;

   Result := TMultiVector.Create(FSystemDimension);
   Result.Data[AuxBit] := 1;
end;

function TGeometricAlgebra.GetCannonicalOrderTable(_X,_Y: cardinal): integer;
begin
   Result := FCannonicalOrderTable[_X+((1 shl FSystemDimension) * _Y)];
end;

// A<t - 1>
function TGeometricAlgebra.GetFlatDirection(const _Vec: TMultiVector): TMultiVector;
var
   e0: TMultiVector;
begin
   e0 := GetHomogeneousE0();

   Result := LeftContraction(e0,_Vec);
   e0.Free;
end;

function TGeometricAlgebra.GetFlatDirection(const _Vec,_e0: TMultiVector): TMultiVector;
begin
   Result := LeftContraction(_e0,_Vec);
end;

// M<t>
function TGeometricAlgebra.GetFlatMoment(const _Vec: TMultiVector): TMultiVector;
var
   e0: TMultiVector;
begin
   e0 := GetHomogeneousE0();

   Result := LeftContraction(e0,OuterProduct(e0,_Vec));
   e0.Free;
end;

function TGeometricAlgebra.GetFlatMoment(const _Vec,_e0: TMultiVector): TMultiVector;
begin
   Result := LeftContraction(_e0,OuterProduct(_e0,_Vec));
end;

// s
function TGeometricAlgebra.GetFlatSupportVector(const _Vec: TMultiVector): TMultiVector;
var
   e0: TMultiVector;
begin
   e0 := GetHomogeneousE0();

   Result := GeometricDivision(GetFlatMoment(_Vec,e0),GetFlatDirection(_Vec,e0));
   e0.Free;
end;

function TGeometricAlgebra.GetFlatSupportVector(const _Vec,_e0: TMultiVector): TMultiVector;
begin
   Result := GeometricDivision(GetFlatMoment(_Vec,_e0),GetFlatDirection(_Vec,_e0));
end;

// e0 + s
function TGeometricAlgebra.GetFlatUnitSupportPoint(const _Vec: TMultiVector): TMultiVector;
var
   e0: TMultiVector;
begin
   e0 := GetHomogeneousE0();

   Result := GeometricDivision(_Vec,GetFlatDirection(_Vec,e0));
   e0.Free;
end;

function TGeometricAlgebra.GetFlatUnitSupportPoint(const _Vec,_e0: TMultiVector): TMultiVector;
begin
   Result := GeometricDivision(_Vec,GetFlatDirection(_Vec,_e0));
end;

// Sets
procedure TGeometricAlgebra.SetDimension(_Dimension: Cardinal);
var
   i,j,k : integer;
   SystemDimension: cardinal;
begin
   SystemDimension := _Dimension + FAuxDimension;
   SetLength(FBitCountTable,SystemDimension * SystemDimension);
   if SystemDimension > FSystemDimension then
   begin
      i := FSystemDimension * FSystemDimension;
      while i <= High(FBitCountTable) do
      begin
         FBitCountTable[i] := bit_Count(i);
         inc(i);
      end;
      FMetric.Dimension := SystemDimension;
      // Adapt metric for the new dimension.
      if FAuxDimension > 0 then
      begin
         i := FDimension;
         k := _Dimension;
         while (i < FSystemDimension) do
         begin
            j := 0;
            while (j < FDimension) do
            begin
               FMetric.Data[j,k] := FMetric.Data[j,i];
               FMetric.Data[k,j] := FMetric.Data[i,j];
               inc(j);
            end;
            while j < k do
            begin
               FMetric.Data[j,k] := 0;
               FMetric.Data[k,j] := 0;
               inc(j);
            end;
            FMetric.Data[k,k] := FMetric.Data[i,i];
            j := 0;
            while (j < _Dimension) do
            begin
               FMetric.Data[j,i] := 0;
               FMetric.Data[i,j] := 0;
               inc(j);
            end;
            FMetric.Data[i,i] := 1;
            inc(i);
            inc(k);
         end;
      end;
   end
   else if SystemDimension < FSystemDimension then
   begin
      // Adapt metric for the new dimension.
      if FAuxDimension > 0 then
      begin
         i := _Dimension;
         k := FDimension;
         while (i < SystemDimension) do
         begin
            j := 0;
            while (j < _Dimension) do
            begin
               FMetric.Data[j,k] := FMetric.Data[j,i];
               FMetric.Data[k,j] := FMetric.Data[i,j];
               inc(j);
            end;
            FMetric.Data[i,i] := FMetric.Data[k,k];
            inc(i);
            inc(k);
         end;
      end;
      FMetric.Dimension := SystemDimension;
   end;
   FDimension := _Dimension;
   FSystemDimension := SystemDimension;
end;

procedure TGeometricAlgebra.QuickSetDimension(_Dimension: Cardinal);
var
   i : integer;
   SystemDimension: cardinal;
begin
   SystemDimension := _Dimension + FAuxDimension;
   SetLength(FBitCountTable,SystemDimension * SystemDimension);
   if SystemDimension > FSystemDimension then
   begin
      i := FSystemDimension * FSystemDimension;
      while i <= High(FBitCountTable) do
      begin
         FBitCountTable[i] := bit_Count(i);
         inc(i);
      end;
   end;
   FDimension := _Dimension;
   FSystemDimension := SystemDimension;
   FMetric.Dimension := FSystemDimension;
end;

procedure TGeometricAlgebra.SetOrthogonalMetric;
begin
   FMetric.Orthogonal := true;
   GeometricProduct := OrthogonalGeometricProduct;
   ScalarProduct := OrthogonalScalarProduct;
   LeftContraction := OrthogonalLeftContractionProduct;
   RightContraction := OrthogonalRightContractionProduct;
   GeometricDivision := OrthogonalGeometricDivision;
end;

procedure TGeometricAlgebra.SetNonOrthogonalMetric;
begin
   FMetric.Orthogonal := false;
   GeometricProduct := NonOrthogonalGeometricProduct;
   ScalarProduct := NonOrthogonalScalarProduct;
   LeftContraction := NonOrthogonalLeftContractionProduct;
   RightContraction := NonOrthogonalRightContractionProduct;
   GeometricDivision := NonOrthogonalGeometricDivision;
end;

procedure TGeometricAlgebra.SetEuclideanMetric;
var
   i,j,maxElem: cardinal;
begin
   // Set dimension
   FAuxDimension := 0;
   QuickSetDimension(FDimension);
   // Build metric.
   i := 0;
   while i < FDimension do
   begin
      j := 0;
      while j < FDimension do
      begin
         FMetric.UnsafeData[i,j] := 0;
         inc(j);
      end;
      FMetric.UnsafeData[i,i] := 1;
      inc(i);
   end;
   // Build cannonical ordering cache.
   SetLength(FCannonicalOrderTable,1 shl (2 * FSystemDimension));
   maxElem := (1 shl FSystemDimension) - 1;
   for i := 0 to maxElem do
   begin
      for j := 0 to maxElem do
      begin
         SetCannonicalOrderTable(i,j,canonical_reordering_euclidean(i,j));
      end;
   end;
   // Ensure that metric is orthogonal
   SetOrthogonalMetric;
end;

procedure TGeometricAlgebra.SetHomogeneousMetric;
var
   i,j,maxElem: cardinal;
begin
   // Set dimension
   FAuxDimension := 1;
   QuickSetDimension(FDimension);
   // Build metric
   // e0 should be eDim to make things simpler.
   i := 0;
   while i < FDimension do
   begin
      j := 0;
      while j < FDimension do
      begin
         FMetric.UnsafeData[i,j] := 0;
         inc(j);
      end;
      FMetric.UnsafeData[i,i] := 1;
      FMetric.UnsafeData[FDimension,i] := 0;
      FMetric.UnsafeData[i,FDimension] := 0;
      inc(i);
   end;
   FMetric.UnsafeData[FDimension,FDimension] := 1;
   // Build cannonical ordering cache.
   SetLength(FCannonicalOrderTable,1 shl (2 * FSystemDimension));
   maxElem := (1 shl FSystemDimension) - 1;
   for i := 0 to maxElem do
   begin
      for j := 0 to maxElem do
      begin
         SetCannonicalOrderTable(i,j,canonical_reordering_homogeneous(i,j));
      end;
   end;
   // Ensure that metric is orthogonal
   SetOrthogonalMetric;
end;

procedure TGeometricAlgebra.SetConformalMetric;
var
   i,j,maxElem: cardinal;
begin
   // Set dimension
   FAuxDimension := 2;
   QuickSetDimension(FDimension);
   // Build metric
   // origin should be eDim and infinity should be eDim+1 to make things simpler.
   i := 0;
   while i < FDimension do
   begin
      j := 0;
      while j < FDimension do
      begin
         FMetric.UnsafeData[i,j] := 0;
         inc(j);
      end;
      FMetric.UnsafeData[i,i] := 1;
      FMetric.UnsafeData[FDimension,i] := 0;
      FMetric.UnsafeData[i,FDimension] := 0;
      FMetric.UnsafeData[FDimension+1,i] := 0;
      FMetric.UnsafeData[i,FDimension+1] := 0;
      inc(i);
   end;
   FMetric.UnsafeData[FDimension,FDimension+1] := -1;
   FMetric.UnsafeData[FDimension+1,FDimension] := -1;
   FMetric.UnsafeData[FDimension,FDimension] := 0;
   FMetric.UnsafeData[FDimension+1,FDimension+1] := 0;
   // Build cannonical ordering cache.
   SetLength(FCannonicalOrderTable,1 shl (2 * FSystemDimension));
   maxElem := (1 shl FSystemDimension) - 1;
   for i := 0 to maxElem do
   begin
      for j := 0 to maxElem do
      begin
         SetCannonicalOrderTable(i,j,canonical_reordering_conformal(i,j));
      end;
   end;
   // Ensure that metric is NOT orthogonal
   SetNonOrthogonalMetric;
end;

procedure TGeometricAlgebra.SetMinkowskiConformalMetric;
var
   i,j,maxElem: cardinal;
begin
   // Set dimension
   FAuxDimension := 2;
   QuickSetDimension(FDimension);
   // Build metric
   // e+ should be eDim and e- should be eDim+1 to make things simpler.
   i := 0;
   while i < FDimension do
   begin
      j := 0;
      while j < FDimension do
      begin
         FMetric.UnsafeData[i,j] := 0;
         inc(j);
      end;
      FMetric.UnsafeData[i,i] := 1;
      FMetric.UnsafeData[FDimension,i] := 0;
      FMetric.UnsafeData[i,FDimension] := 0;
      FMetric.UnsafeData[FDimension+1,i] := 0;
      FMetric.UnsafeData[i,FDimension+1] := 0;
      inc(i);
   end;
   FMetric.UnsafeData[FDimension,FDimension] := 1;
   FMetric.UnsafeData[FDimension+1,FDimension+1] := -1;
   // Build cannonical ordering cache.
   SetLength(FCannonicalOrderTable,1 shl (2 * FSystemDimension));
   maxElem := (1 shl FSystemDimension) - 1;
   for i := 0 to maxElem do
   begin
      for j := 0 to maxElem do
      begin
         SetCannonicalOrderTable(i,j,canonical_reordering_conformal(i,j));
      end;
   end;
   // Ensure that metric is orthogonal
   SetOrthogonalMetric;
end;

procedure TGeometricAlgebra.SetCannonicalOrderTable(_X,_Y: cardinal; _Value: integer);
begin
   FCannonicalOrderTable[_X+((1 shl FSystemDimension) * _Y)] := _Value;
end;

// Operations
function TGeometricAlgebra.OuterProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
   ElemRes,Elem1,Elem2: TBaseElement;
begin
   Result := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := _Vec1.GetTheFirstNonZeroBitmap;
   while i <> C_INFINITY do
   begin
      Elem1.Coeficient := _Vec1.UnsafeData[i];
      Elem1.Bitmap := i;
      j := _Vec2.GetTheFirstNonZeroBitmap;
      while j <> C_INFINITY do
      begin
         Elem2.Coeficient := _Vec2.UnsafeData[j];
         Elem2.Bitmap := j;
         ElemRes := OuterProduct(Elem1,Elem2);
         Result.UnsafeData[ElemRes.Bitmap] := Result.UnsafeData[ElemRes.Bitmap] + ElemRes.Coeficient;
         j := _Vec2.GetTheNextNonZeroBitmap(j);
      end;
      i := _Vec1.GetTheNextNonZeroBitmap(i);
   end;
end;

function TGeometricAlgebra.OuterProduct(const _Base1, _Base2: TBaseElement):TBaseElement;
begin
   if (_Base1.Bitmap and _Base2.Bitmap) <> 0 then
   begin
      Result.Coeficient := 0;
      Result.Bitmap := 0;
   end
   else
   begin
      Result.Bitmap := _Base1.Bitmap or _Base2.Bitmap;
      Result.Coeficient := canonical_reordering(_Base1.Bitmap,_Base2.Bitmap) * _Base1.Coeficient * _Base2.Coeficient;
   end;
end;

function TGeometricAlgebra.RegressiveProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
   ElemRes,Elem1,Elem2: TBaseElement;
begin
   Result := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := _Vec1.GetTheFirstNonZeroBitmap;
   while i <> C_INFINITY do
   begin
      Elem1.Coeficient := _Vec1.UnsafeData[i];
      Elem1.Bitmap := i;
      j := _Vec2.GetTheFirstNonZeroBitmap;
      while j <> C_INFINITY do
      begin
         Elem2.Coeficient := _Vec2.UnsafeData[j];
         Elem2.Bitmap := j;
         ElemRes := RegressiveProduct(Elem1,Elem2);
         Result.UnsafeData[ElemRes.Bitmap] := Result.UnsafeData[ElemRes.Bitmap] + ElemRes.Coeficient;
         j := _Vec2.GetTheNextNonZeroBitmap(j);
      end;
      i := _Vec1.GetTheNextNonZeroBitmap(i);
   end;
end;

function TGeometricAlgebra.RegressiveProduct(const _Base1, _Base2: TBaseElement):TBaseElement;
begin
   Result.Bitmap := _Base1.Bitmap and _Base2.Bitmap;
   if ((FBitCountTable[_Base1.Bitmap] + FBitCountTable[_Base2.Bitmap] - FBitCountTable[Result.Bitmap]) <> FMetric.Dimension) then
   begin
      Result.Bitmap := 0;
      Result.Coeficient := 0;
   end
   else
   begin
      Result.Coeficient := canonical_reordering(_Base1.Bitmap xor Result.Bitmap,_Base2.Bitmap xor Result.Bitmap) * _Base1.Coeficient * _Base2.Coeficient;
   end;
end;

procedure TGeometricAlgebra.Sum(var _Vec1: TMultiVector; const _Vec2: TMultiVector);
var
   i,j: cardinal;
   Sum: TMultiVector;
begin
   Sum := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := 0;
   while i <= Min(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Sum.UnsafeData[i] := _Vec1.UnsafeData[i] + _Vec2.UnsafeData[i];
      inc(i);
   end;
   while i <= Max(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Sum.UnsafeData[i] := _Vec1.Data[i] + _Vec2.Data[i];
      inc(i);
   end;
   _Vec1.Free;
   _Vec1 := TMultiVector.Create(Sum);
end;

function TGeometricAlgebra.GetSum(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
begin
   Result := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := 0;
   while i <= Min(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Result.UnsafeData[i] := _Vec1.UnsafeData[i] + _Vec2.UnsafeData[i];
      inc(i);
   end;
   while i <= Max(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Result.UnsafeData[i] := _Vec1.Data[i] + _Vec2.Data[i];
      inc(i);
   end;
end;

procedure TGeometricAlgebra.Subtraction(var _Vec1: TMultiVector; const _Vec2: TMultiVector);
var
   i,j: cardinal;
   Subtraction: TMultiVector;
begin
   Subtraction := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := 0;
   while i <= Min(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Subtraction.UnsafeData[i] := _Vec1.UnsafeData[i] - _Vec2.UnsafeData[i];
      inc(i);
   end;
   while i <= Max(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Subtraction.UnsafeData[i] := _Vec1.Data[i] - _Vec2.Data[i];
      inc(i);
   end;
   _Vec1.Free;
   _Vec1 := TMultiVector.Create(Subtraction);
end;

function TGeometricAlgebra.GetSubtraction(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
begin
   Result := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := 0;
   while i <= Min(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Result.UnsafeData[i] := _Vec1.UnsafeData[i] - _Vec2.UnsafeData[i];
      inc(i);
   end;
   while i <= Max(_Vec1.MaxElement,_Vec2.MaxElement) do
   begin
      Result.UnsafeData[i] := _Vec1.Data[i] - _Vec2.Data[i];
      inc(i);
   end;
end;

function TGeometricAlgebra.OrthogonalGeometricProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
   ElemRes,Elem1,Elem2: TBaseElement;
begin
   Result := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := _Vec1.GetTheFirstNonZeroBitmap;
   while i <> C_INFINITY do
   begin
      Elem1.Coeficient := _Vec1.UnsafeData[i];
      Elem1.Bitmap := i;
      j := _Vec2.GetTheFirstNonZeroBitmap;
      while j <> C_INFINITY do
      begin
         Elem2.Coeficient := _Vec2.UnsafeData[j];
         Elem2.Bitmap := j;
         ElemRes := OrthogonalGeometricProduct(Elem1,Elem2);
         Result.UnsafeData[ElemRes.Bitmap] := Result.UnsafeData[ElemRes.Bitmap] + ElemRes.Coeficient;
         j := _Vec2.GetTheNextNonZeroBitmap(j);
      end;
      i := _Vec1.GetTheNextNonZeroBitmap(i);
   end;
end;

function TGeometricAlgebra.OrthogonalGeometricProduct(const _Base1, _Base2: TBaseElement):TBaseElement;
begin
   Result.Bitmap := _Base1.Bitmap xor _Base2.Bitmap;
   Result.Coeficient := canonical_reordering(_Base1.Bitmap,_Base2.Bitmap) * _Base1.Coeficient * _Base2.Coeficient * GetMetricMultiplier(_Base1.Bitmap,_Base2.Bitmap);
end;

function TGeometricAlgebra.OrthogonalGeometricDivision(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   Inverse: TMultiVector;
begin
   Inverse := GetInverse(_Vec2);
   Result := GeometricProduct(_Vec1,Inverse);
   Inverse.Free;
end;

function TGeometricAlgebra.OrthogonalScalarProduct(const _Vec1,_Vec2: TMultiVector):single;
var
   i,j: cardinal;
   Elem1,Elem2: TBaseElement;
   Res: single;
begin
   Result := 0;
   i := _Vec1.GetTheFirstNonZeroBitmap;
   while i <> C_INFINITY do
   begin
      Elem1.Coeficient := _Vec1.UnsafeData[i];
      Elem1.Bitmap := i;
      j := _Vec2.GetTheFirstNonZeroBitmap;
      while j <> C_INFINITY do
      begin
         Elem2.Coeficient := _Vec2.UnsafeData[j];
         Elem2.Bitmap := j;
         Res := OrthogonalScalarProduct(Elem1,Elem2);
         Result := Result + Res;
         j := _Vec2.GetTheNextNonZeroBitmap(j);
      end;
      i := _Vec1.GetTheNextNonZeroBitmap(i);
   end;
end;

function TGeometricAlgebra.OrthogonalScalarProduct(const _Base1, _Base2: TBaseElement):Single;
begin
   if (_Base1.Bitmap xor _Base2.Bitmap) = 0 then
   begin
      Result := canonical_reordering(_Base1.Bitmap,_Base2.Bitmap) * _Base1.Coeficient * _Base2.Coeficient * GetMetricMultiplier(_Base1.Bitmap,_Base2.Bitmap);
   end
   else
   begin
      Result := 0;
   end;
end;

// Right (_Vec2) is bigger than Left (_Vec1).
function TGeometricAlgebra.OrthogonalLeftContractionProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
   Grade : integer;
   ElemRes,Elem1,Elem2: TBaseElement;
begin
   Grade := GetMaxGrade(_Vec2) - GetMaxGrade(_Vec1);
   if Grade < 0 then
      Grade := 0;
   Result := TMultiVector.Create(Max(_Vec1.Dimension,_Vec2.Dimension));
   i := _Vec1.GetTheFirstNonZeroBitmap;
   while i <> C_INFINITY do
   begin
      Elem1.Coeficient := _Vec1.UnsafeData[i];
      Elem1.Bitmap := i;
      j := _Vec2.GetTheFirstNonZeroBitmap;
      while j <> C_INFINITY do
      begin
         Elem2.Coeficient := _Vec2.UnsafeData[j];
         Elem2.Bitmap := j;
         ElemRes := OrthogonalXContractionProduct(Elem1,Elem2,Grade);
         Result.UnsafeData[ElemRes.Bitmap] := Result.UnsafeData[ElemRes.Bitmap] + ElemRes.Coeficient;
         j := _Vec2.GetTheNextNonZeroBitmap(j);
      end;
      i := _Vec1.GetTheNextNonZeroBitmap(i);
   end;
end;

function TGeometricAlgebra.OrthogonalRightContractionProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
begin
   OrthogonalLeftContractionProduct(_Vec2,_Vec1);
end;

function TGeometricAlgebra.OrthogonalXContractionProduct(const _Base1, _Base2: TBaseElement; _MaxGrade: cardinal):TBaseElement;
var
   bitmap : cardinal;
begin
   bitmap := _Base1.Bitmap xor _Base2.Bitmap;
   if FBitCountTable[bitmap] <= _MaxGrade then
   begin
      Result.Bitmap := bitmap;
      Result.Coeficient := canonical_reordering(_Base1.Bitmap,_Base2.Bitmap) * _Base1.Coeficient * _Base2.Coeficient * GetMetricMultiplier(_Base1.Bitmap,_Base2.Bitmap);
   end
   else
   begin
      Result.Bitmap := 0;
      Result.Coeficient := 0;
   end;
end;

function TGeometricAlgebra.NonOrthogonalGeometricProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
begin
   // Do some pre-processing here.
   // Convert data to an orthogonal metric. Needs eigenvalues, eigenvectors and stuff.
   Result := OrthogonalGeometricProduct(_Vec1, _Vec2);
   // Do some post-processing here.
   // Convert it back to non-ortoghonal
end;

function TGeometricAlgebra.NonOrthogonalGeometricDivision(const _Vec1,_Vec2: TMultiVector):TMultiVector;
begin
   // Do some pre-processing here.
   // Convert data to an orthogonal metric. Needs eigenvalues, eigenvectors and stuff.
   Result := OrthogonalGeometricDivision(_Vec1, _Vec2);
   // Do some post-processing here.
   // Convert it back to non-ortoghonal
end;

function TGeometricAlgebra.NonOrthogonalScalarProduct(const _Vec1,_Vec2: TMultiVector):Single;
begin
   // Do some pre-processing here.
   // Convert data to an orthogonal metric. Needs eigenvalues, eigenvectors and stuff.
   Result := OrthogonalScalarProduct(_Vec1, _Vec2);
   // Do some post-processing here.
   // Convert it back to non-ortoghonal
end;

function TGeometricAlgebra.NonOrthogonalLeftContractionProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
begin
   // Do some pre-processing here.
   // Convert data to an orthogonal metric. Needs eigenvalues, eigenvectors and stuff.
   Result := OrthogonalLeftContractionProduct(_Vec1, _Vec2);
   // Do some post-processing here.
   // Convert it back to non-ortoghonal
end;

function TGeometricAlgebra.NonOrthogonalRightContractionProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
begin
   // Do some pre-processing here.
   // Convert data to an orthogonal metric. Needs eigenvalues, eigenvectors and stuff.
   Result := OrthogonalRightContractionProduct(_Vec1, _Vec2);
   // Do some post-processing here.
   // Convert it back to non-ortoghonal
end;

function TGeometricAlgebra.ApplyRotor(const _Blade, _Rotor: TMultiVector):TMultiVector;
var
   Inverse: TMultiVector;
begin
   Inverse := GetInverse(_Rotor);
   Result := ApplyRotor(_Blade,_Rotor,Inverse);
   Inverse.Free;
end;

function TGeometricAlgebra.ApplyRotor(const _Blade, _Rotor,_InverseRotor: TMultiVector):TMultiVector;
var
   GpRotBlade : TMultiVector;
begin
   GpRotBlade := GeometricProduct(_Rotor,_Blade);
   Result := GeometricProduct(GpRotBlade,_InverseRotor);
   GpRotBlade.Free;
end;

// _Vec := _Vec + (_Offset ^ (e0 l _Vec))    ... where l is left contraction.
procedure TGeometricAlgebra.HomogeneousTranslation(var _Vec: TMultiVector; const _Offset: TMultiVector);
var
   Offset,EuclideanOffset,Direction: TMultiVector;
begin
   Direction := GetFlatDirection(_Vec);
   EuclideanOffset := GetEuclideanPartFromVector(_Offset);
   Offset := OuterProduct(EuclideanOffset,Direction);
   Sum(_Vec,Offset);

   // Free memory.
   EuclideanOffset.Free;
   Offset.Free;
   Direction.Free;
end;

// Result := _Vec + (_Offset ^ (e0 l _Vec))    ... where l is left contraction.
function TGeometricAlgebra.GetHomogeneousTranslation(const _Vec,_Offset: TMultiVector): TMultiVector;
var
   Offset,EuclideanOffset,Direction: TMultiVector;
begin
   Direction := GetFlatDirection(_Vec);
   EuclideanOffset := GetEuclideanPartFromVector(_Offset);
   Offset := OuterProduct(EuclideanOffset,Direction);
   Result := GetSum(_Vec,Offset);

   // Free memory.
   EuclideanOffset.Free;
   Offset.Free;
   Direction.Free;
end;

// _Vec := _Vec - (_Offset ^ (e0 l _Vec))    ... where l is left contraction. Warning: _Offset must be euclidean
procedure TGeometricAlgebra.HomogeneousOppositeTranslation(var _Vec: TMultiVector; const _Offset: TMultiVector);
var
   Offset,EuclideanOffset,Direction: TMultiVector;
begin
   Direction := GetFlatDirection(_Vec);
   EuclideanOffset := GetEuclideanPartFromVector(_Offset);
   Offset := OuterProduct(EuclideanOffset,Direction);
   Subtraction(_Vec,Offset);

   // Free memory.
   EuclideanOffset.Free;
   Offset.Free;
   Direction.Free;
end;

// Result := _Vec - (_Offset ^ (e0 l _Vec))    ... where l is left contraction.
function TGeometricAlgebra.GetHomogeneousOppositeTranslation(const _Vec,_Offset: TMultiVector): TMultiVector;
var
   Offset,EuclideanOffset,Direction: TMultiVector;
begin
   Direction := GetFlatDirection(_Vec);
   EuclideanOffset := GetEuclideanPartFromVector(_Offset);
   Offset := OuterProduct(EuclideanOffset,Direction);
   Result := GetSubtraction(_Vec,Offset);

   // Free memory.
   EuclideanOffset.Free;
   Offset.Free;
   Direction.Free;
end;

// Ã
function TGeometricAlgebra.GetReverse(const _Vec: TMultiVector):TMultiVector;
begin
   Result := TMultiVector.Create(_Vec);
   Reverse(Result);
end;

procedure TGeometricAlgebra.Reverse(var _Vec: TMultiVector);
var
   i,Grade: cardinal;
begin
   for i := 0 to _Vec.MaxElement do
   begin
      if (FBitCountTable[i] mod 4) > 1 then
      begin
         _Vec.UnsafeData[i] := -1 * _Vec.UnsafeData[i];
      end;
   end;
end;

// Â
function TGeometricAlgebra.GetGradeInvolution(const _Vec: TMultiVector):TMultiVector;
begin
   Result := TMultiVector.Create(_Vec);
   GradeInvolution(Result);
end;

procedure TGeometricAlgebra.GradeInvolution(var _Vec: TMultiVector);
var
   i,Grade : cardinal;
begin
   Grade := GetMaxGrade(_Vec);
   if (Grade mod 2) > 0 then
   begin
      for i := 0 to _Vec.MaxElement do
      begin
         _Vec.UnsafeData[i] := -1 * _Vec.UnsafeData[i];
      end;
   end;
end;

function TGeometricAlgebra.GetCliffordConjugation(const _Vec: TMultiVector):TMultiVector;
begin
   Result := TMultiVector.Create(_Vec);
   CliffordConjugation(Result);
end;

procedure TGeometricAlgebra.CliffordConjugation(var _Vec: TMultiVector);
var
   i,Grade : cardinal;
begin
   Grade := GetMaxGrade(_Vec);
   if ((Grade mod 4) mod 3) = 0 then
   begin
      for i := 0 to _Vec.MaxElement do
      begin
         _Vec.UnsafeData[i] := -1 * _Vec.UnsafeData[i];
      end;
   end;
end;

// V^(-1)
function TGeometricAlgebra.GetInverse(const _Vec:TMultiVector): TMultiVector;
begin
   Result := TMultiVector.Create(_Vec);
   Inverse(Result);
end;

function TGeometricAlgebra.GetInverse(const _Vec,_Reverse:TMultiVector): TMultiVector;
begin
   Result := TMultiVector.Create(_Vec);
   Inverse(Result,_Reverse);
end;

function TGeometricAlgebra.GetInverse(const _Vec,_Reverse:TMultiVector; _Norm: single): TMultiVector;
begin
   Result := TMultiVector.Create(_Vec);
   Inverse(Result,_Reverse,_Norm);
end;

procedure TGeometricAlgebra.Inverse(var _Vec:TMultiVector);
var
   Reverse: TMultiVector;
   Norm: single;
   i: cardinal;
begin
   Reverse := GetReverse(_Vec);
   Norm := GetSquaredNorm(_Vec,Reverse);
   if Norm <> 0 then
   begin
      for i := 0 to _Vec.MaxElement do
      begin
         _Vec.UnsafeData[i] := Reverse.UnsafeData[i] / Norm;
      end;
   end;
   Reverse.Free;
end;

procedure TGeometricAlgebra.Inverse(var _Vec: TMultiVector; const _Reverse:TMultiVector);
var
   Norm: single;
   i: cardinal;
begin
   Norm := GetSquaredNorm(_Vec,_Reverse);
   if Norm <> 0 then
   begin
      for i := 0 to _Vec.MaxElement do
      begin
         _Vec.UnsafeData[i] := _Reverse.UnsafeData[i] / Norm;
      end;
   end;
end;

procedure TGeometricAlgebra.Inverse(var _Vec: TMultiVector; const _Reverse:TMultiVector; _Norm: single);
var
   i: cardinal;
begin
   if _Norm <> 0 then
   begin
      for i := 0 to _Vec.MaxElement do
      begin
         _Vec.UnsafeData[i] := _Reverse.UnsafeData[i] / _Norm;
      end;
   end;
end;

procedure TGeometricAlgebra.Dual(var _Vec:TMultiVector);
var
   IInverse: TMultiVector;
begin
   IInverse := GetIInverse();
   _Vec := OrthogonalLeftContractionProduct(_Vec,IInverse);
   IInverse.Free;
end;

function TGeometricAlgebra.GetDual(const _Vec:TMultiVector):TMultiVector;
var
   IInverse: TMultiVector;
begin
   IInverse := GetIInverse();
   Result := OrthogonalLeftContractionProduct(_Vec,IInverse);
   IInverse.Free;
end;

procedure TGeometricAlgebra.Undual(var _Vec:TMultiVector);
var
   I,Answer : TMultiVector;
begin
   I := GetI();
   Answer := OrthogonalLeftContractionProduct(_Vec,I);
   _Vec.Free;
   _Vec := TMultiVector.Create(Answer);
   Answer.Free;
   I.Free;
end;

function TGeometricAlgebra.GetUndual(const _Vec:TMultiVector):TMultiVector;
var
   I : TMultiVector;
begin
   I := GetI();
   Result := OrthogonalLeftContractionProduct(_Vec,I);
   I.Free;
end;

function TGeometricAlgebra.Normalize(const _Vec: TMultiVector):TMultiVector;
var
   Norm_r: single;
   i : cardinal;
begin
   Result := TMultiVector.Create(_Vec);
   Norm_r := Abs(GetSquaredNorm(_Vec));
   if Norm_r <> 0 then
   begin
      i := _Vec.GetTheFirstNonZeroBitmap;
      while i <> C_INFINITY do
      begin
         Result.UnsafeData[i] := Result.UnsafeData[i] / Norm_r;
         i := _Vec.GetTheNextNonZeroBitmap(i);
      end;
   end;
end;

procedure TGeometricAlgebra.ScaleVector(var _Vec: TMultiVector; _Scale: single);
var
   i: integer;
begin
   for i := 0 to _Vec.MaxElement do
   begin
      _Vec.UnsafeData[i] := _Vec.UnsafeData[i] * _Scale;
   end;
end;

procedure TGeometricAlgebra.ScaleEuclideanDataFromVector(var _Vec: TMultiVector; _Scale: single);
var
   first,last,i: integer;
begin
   first := 0;
   last := (1 shl FDimension) - 1;
   for i := first to last do
   begin
      _Vec.UnsafeData[i] := _Vec.UnsafeData[i] * _Scale;
   end;
end;

procedure TGeometricAlgebra.ScaleHomogeneousDataFromVector(var _Vec: TMultiVector; _Scale: single);
var
   first,last,i: integer;
begin
   first := 1 shl FDimension;
   last := (first shl 1) - 1;
   for i := first to last do
   begin
      _Vec.UnsafeData[i] := _Vec.UnsafeData[i] * _Scale;
   end;
end;

function TGeometricAlgebra.Euclidean3DLogarithm(const _Vec: TMultiVector): TMultiVector;
var
   Grade2SqrtNorm: single;
   HalfAngle: single;
   RotBase: TMultiVector;
begin
   // Get rotation base.
   RotBase := GetBladeOfGradeFromVector(_Vec,2);
   Grade2SqrtNorm := sqrt(GetSquaredNorm(RotBase));
   ScaleVector(RotBase,1/Grade2SqrtNorm);

   // Get rotation angle.
   HalfAngle := arctan2(Grade2SqrtNorm,_Vec.UnsafeData[0])*0.5;
   // Get the versor required to do the transformation.
   Result := NewEuclideanRotationVersor(RotBase,HalfAngle);

   // Free memory
   RotBase.Free;
end;

// Misc
function TGeometricAlgebra.canonical_reordering(_bitmap1, _bitmap2: Cardinal): integer;
begin
   Result := GetCannonicalOrderTable(_bitmap1,_bitmap2);
end;

function TGeometricAlgebra.canonical_reordering_euclidean(_bitmap1, _bitmap2: Cardinal): integer;
var
   bitmap: cardinal;
begin
   Result := 0;
   bitmap := _bitmap1 shr 1;
   While (bitmap <> 0) do
   begin
      Result := Result + Integer(FBitCountTable[bitmap and _bitmap2]);
      bitmap := bitmap shr 1;
   end;

   // + for even number of swaps or - for odd number of swaps
   if (Result and 1) = 0 then
   begin
      Result := 1;
   end
   else
   begin
      Result := -1;
   end;
end;

// Our base eFDimension is the e0 from this model. It should actually go
// before e1, e2, e3, etc...
function TGeometricAlgebra.canonical_reordering_homogeneous(_bitmap1, _bitmap2: Cardinal): integer;
var
   bitmap1,bitmap2: cardinal;
begin
   bitmap1 := ((_bitmap1 and ((1 shl FDimension) - 1)) shl 1) + (_bitmap1 shr FDimension);
   bitmap2 := ((_bitmap2 and ((1 shl FDimension) - 1)) shl 1) + (_bitmap2 shr FDimension);
   Result := canonical_reordering_euclidean(bitmap1,bitmap2);
end;

// Our base eFDimension is the e0 from this model. It should actually go
// before e1, e2, e3, etc...

// Our base eFDimension+1 is the infinity from this model. It should actually
// go after e1, e2, e3, etc...
function TGeometricAlgebra.canonical_reordering_conformal(_bitmap1, _bitmap2: Cardinal): integer;
var
   bitmap1,bitmap2: cardinal;
begin
   bitmap1 := ((_bitmap1 and ((1 shl FDimension) - 1)) shl 1) + ((_bitmap1 shr FDimension) and 1) + (_bitmap1 and (1 shl (FDimension + 1)));
   bitmap2 := ((_bitmap2 and ((1 shl FDimension) - 1)) shl 1) + ((_bitmap2 shr FDimension) and 1) + (_bitmap2 and (1 shl (FDimension + 1)));
   Result := canonical_reordering_euclidean(bitmap1,bitmap2);
end;

function TGeometricAlgebra.bit_count(_bitmap: Cardinal): word;
begin
   Result := 0;
   while _bitmap <> 0 do
   begin
      inc(Result);
      _bitmap := _bitmap and (_bitmap - 1);
   end;
end;

function TGeometricAlgebra.GetMetricMultiplier(_bitmap1, _bitmap2: cardinal): single;
var
   i,j,Bitmap: cardinal;
begin
   Bitmap := _bitmap1 and _bitmap2;
   Result := 1;
   i := 1;
   j := 0;
   while j < FMetric.MaxX do
   begin
      if (Bitmap and i) <> 0 then
      begin
         Result := Result * FMetric.Data[j,j];
      end;
      i := i shl 1;
      inc(j);
   end;
end;

end.
