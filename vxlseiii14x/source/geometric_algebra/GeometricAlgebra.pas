unit GeometricAlgebra;

interface

uses MultiVector, Metric, Math, BasicDataTypes, GADataTypes, GAConstants;

type
   TGeometricAlgebra = class
   private
      FMetric: TMetric;
      FBitCountTable: auint32;
      FDimension: Cardinal;
      FAuxDimension: Cardinal;
      FSystemDimension: Cardinal;
   protected
      // Gets
      function GetDimension: Cardinal;
      function GetAuxDimension: Cardinal;
      function GetSystemDimension: Cardinal;
      // Sets
      procedure SetDimension(_Dimension: cardinal);
      procedure QuickSetDimension(_Dimension: cardinal);
      // Base Operations
      function OuterProduct(_Base1, _Base2: TBaseElement):TBaseElement; overload;
      function RegressiveProduct(_Base1, _Base2: TBaseElement):TBaseElement; overload;
      function OrthogonalGeometricProduct(_Base1, _Base2: TBaseElement):TBaseElement; overload;
      function OrthogonalScalarProduct(_Base1, _Base2: TBaseElement):Single; overload;
      function OrthogonalXContractionProduct(_Base1, _Base2: TBaseElement; _MaxGrade: cardinal):TBaseElement;
      // Misc
      function canonical_reordering(_bitmap1, _bitmap2: cardinal): integer;
      function bit_count(_bitmap: cardinal): word;
      function GetMetricMultiplier(_bitmap1, _bitmap2: cardinal): single;
   public
      // Constructor
      constructor Create;
      destructor Destroy; override;
      // Gets
      function GetMaxGrade(_Vec: TMultiVector):cardinal;
      function GetNorm(_Vec: TMultiVector):single;
      function GetSquaredNorm(_Vec: TMultiVector):single;
      function GetI:TMultiVector;
      function GetIInverse:TMultiVector;
      // Sets
      procedure SetEuclideanMetric;
      procedure SetHomogeneousMetric;
      procedure SetConformalMetric;
      procedure SetMinkowskiConformalMetric;
      // Operations
      function OuterProduct(_Vec1,_Vec2: TMultiVector):TMultiVector; overload;
      function RegressiveProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function OrthogonalGeometricProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function OrthogonalScalarProduct(const _Vec1, _Vec2: TMultiVector):single; overload;
      function OrthogonalLeftContractionProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function OrthogonalRightContractionProduct(const _Vec1, _Vec2: TMultiVector):TMultiVector; overload;
      function Reverse(_Vec: TMultiVector):TMultiVector;
      function GradeInvolution(_Vec: TMultiVector):TMultiVector;
      function CliffordConjugation(_Vec: TMultiVector):TMultiVector;
      function Dual(_Vec:TMultiVector):TMultiVector;
      function Undual(_Vec:TMultiVector):TMultiVector;
      function Normalize(_Vec:TMultiVector):TMultiVector;
      // Properties
      property SystemDimension: cardinal read GetSystemDimension;
      property AuxDimension: cardinal read GetAuxDimension;
      property Dimension:cardinal read GetDimension write SetDimension;
   end;

implementation

// Constructor
constructor TGeometricAlgebra.Create;
begin
   FDimension := 3;
   FMetric := TMetric.Create();
   SetEuclideanMetric;
end;

destructor TGeometricAlgebra.Destroy;
begin
   SetLength(FBitCountTable,0);
   FMetric.Free;
   inherited Destroy;
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

function TGeometricAlgebra.GetMaxGrade(_Vec: TMultiVector):cardinal;
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

function TGeometricAlgebra.GetNorm(_Vec: TMultiVector): single;
var
   Norm: single;
begin
   Norm := GetSquaredNorm(_Vec);
   Result := sqrt(abs(Norm)) * math.Sign(Norm);
end;

function TGeometricAlgebra.GetSquaredNorm(_Vec: TMultiVector): single;
var
   Rev: TMultiVector;
begin
   Rev := Reverse(_Vec);
   Result := OrthogonalScalarProduct(_Vec,Rev);
end;

function TGeometricAlgebra.GetI:TMultiVector;
begin
   Result := TMultiVector.Create(FDimension);
   Result.UnsafeData[Result.MaxElement] := 1;
end;

function TGeometricAlgebra.GetIInverse:TMultiVector;
const
   // nobody will use R21 or higher :P
   ReverseTable: array[0..19] of boolean = (false, false, true, true, false, false, true, true, false, false, true, true, false, false, true, true, false, false, true, true);
begin
   Result := TMultiVector.Create(FDimension);
   if ReverseTable[FBitCountTable[Result.MaxElement]] then
   begin
      Result.UnsafeData[Result.MaxElement] := -1;
   end
   else
   begin
      Result.UnsafeData[Result.MaxElement] := 1;
   end;
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

procedure TGeometricAlgebra.SetEuclideanMetric;
var
   i,j: cardinal;
begin
   FAuxDimension := 0;
   QuickSetDimension(FDimension);
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
   FMetric.Orthogonal := true;
end;

procedure TGeometricAlgebra.SetHomogeneousMetric;
var
   i,j: cardinal;
begin
   FAuxDimension := 1;
   QuickSetDimension(FDimension);
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
   FMetric.Orthogonal := true;
end;

procedure TGeometricAlgebra.SetConformalMetric;
var
   i,j: cardinal;
begin
   FAuxDimension := 2;
   QuickSetDimension(FDimension);
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
   FMetric.Orthogonal := false;
end;

procedure TGeometricAlgebra.SetMinkowskiConformalMetric;
var
   i,j: cardinal;
begin
   FAuxDimension := 2;
   QuickSetDimension(FDimension);
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
   FMetric.Orthogonal := true;
end;

// Operations
function TGeometricAlgebra.OuterProduct(_Vec1,_Vec2: TMultiVector):TMultiVector;
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

function TGeometricAlgebra.OuterProduct(_Base1, _Base2: TBaseElement):TBaseElement;
begin
   if (_Base1.Bitmap and _Base2.Bitmap) = 0 then
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

function TGeometricAlgebra.RegressiveProduct(_Base1, _Base2: TBaseElement):TBaseElement;
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

function TGeometricAlgebra.OrthogonalGeometricProduct(_Base1, _Base2: TBaseElement):TBaseElement;
begin
   Result.Bitmap := _Base1.Bitmap xor _Base2.Bitmap;
   Result.Coeficient := canonical_reordering(_Base1.Bitmap,_Base2.Bitmap) * _Base1.Coeficient * _Base2.Coeficient * GetMetricMultiplier(_Base1.Bitmap,_Base2.Bitmap);
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

function TGeometricAlgebra.OrthogonalScalarProduct(_Base1, _Base2: TBaseElement):Single;
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

function TGeometricAlgebra.OrthogonalLeftContractionProduct(const _Vec1,_Vec2: TMultiVector):TMultiVector;
var
   i,j: cardinal;
   Grade : integer;
   ElemRes,Elem1,Elem2: TBaseElement;
begin
   Grade := GetMaxGrade(_Vec1) - GetMaxGrade(_Vec2);
   if Grade < 0 then
      Grade := 0;
   Result := TMultiVector.Create(Grade);
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

function TGeometricAlgebra.OrthogonalXContractionProduct(_Base1, _Base2: TBaseElement; _MaxGrade: cardinal):TBaseElement;
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


function TGeometricAlgebra.Reverse(_Vec: TMultiVector):TMultiVector;
const
   // nobody will use R21 or higher :P
   ReverseTable: array[0..19] of boolean = (false, false, true, true, false, false, true, true, false, false, true, true, false, false, true, true, false, false, true, true);
var
   i : cardinal;
begin
   Result := TMultiVector.Create(_Vec);
   for i := 3 to Result.MaxElement do
   begin
      if ReverseTable[FBitCountTable[i]] then
      begin
         Result.UnsafeData[i] := -1 * Result.UnsafeData[i];
      end;
   end;
end;

function TGeometricAlgebra.GradeInvolution(_Vec: TMultiVector):TMultiVector;
var
   i : cardinal;
begin
   Result := TMultiVector.Create(_Vec);
   for i := 3 to Result.MaxElement do
   begin
      if (FBitCountTable[i] and 1) > 0 then
      begin
         Result.UnsafeData[i] := -1 * Result.UnsafeData[i];
      end;
   end;
end;

function TGeometricAlgebra.CliffordConjugation(_Vec: TMultiVector):TMultiVector;
const
   // nobody will use R21 or higher :P
   CliffordTable: array[0..19] of boolean = (false, true, true, false, false, true, true, false, false, true, true, false, false, true, true, false, false, true, true, false);
var
   i : cardinal;
begin
   Result := TMultiVector.Create(_Vec);
   for i := 3 to Result.MaxElement do
   begin
      if CliffordTable[FBitCountTable[i]] then
      begin
         Result.UnsafeData[i] := -1 * Result.UnsafeData[i];
      end;
   end;
end;

function TGeometricAlgebra.Dual(_Vec:TMultiVector):TMultiVector;
begin
   Result := OrthogonalGeometricProduct(_Vec,GetIInverse());
end;

function TGeometricAlgebra.Undual(_Vec:TMultiVector):TMultiVector;
begin
   Result := OrthogonalGeometricProduct(_Vec,GetI());
end;

function TGeometricAlgebra.Normalize(_Vec: TMultiVector):TMultiVector;
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

// Misc
function TGeometricAlgebra.canonical_reordering(_bitmap1, _bitmap2: Cardinal): integer;
begin
   Result := 0;
   _bitmap1 := _bitmap1 shr 1;
   While (_bitmap1 <> 0) do
   begin
      Result := Result + Integer(FBitCountTable[_bitmap1 and _bitmap2]);
      _bitmap1 := _bitmap1 shr 1;
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
   i,j,bitmap: cardinal;
begin
   bitmap := _bitmap1 and _bitmap2;
   Result := 1;
   i := 1;
   j := 0;
   while j < FMetric.MaxX do
   begin
      if (Bitmap and i) <> 0 then
      begin
         Result := Result * FMetric.Data[j,j];
      end;
      i := i * 2;
      inc(j);
   end;
end;

end.
