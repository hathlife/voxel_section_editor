unit CholeskySolver;

interface

uses BasicDataTypes;

type
   TCholeskySolver = class
   public
      Answer: AFloat;

      constructor Create(var _A: AFloat; _b: AFloat);
      destructor Destroy; override;
      procedure Execute;
   private
      m: integer;
      A, y, b: AFloat;
      // Cholesky internal procedures
      procedure DecomposeL;
      procedure SolveLyb;
      procedure SolveLxy;

      // Matrix operations
      function BuildTranspose(const _mat: AFloat): AFloat;
      function MultMatrix(const _mat1, _mat2: AFloat): AFloat;
      function MultMatrixVec(const _mat, _vec: AFloat): AFloat;

      // Basic Matrix Get & Set
      function GetMatrixElem(const _Matrix: AFloat; i, j: integer): real;
      procedure SetMatrixElem(const _Matrix: AFloat; i, j: integer; _Value: real);
   end;

implementation

uses Math;

constructor TCholeskySolver.Create(var _A: AFloat; _b: AFloat);
var
   Transpose: AFloat;
begin
   m := High(_b) + 1;
   SetLength(Answer, m);
   SetLength(y, m);
   Transpose := buildTranspose(_A);
   A := multMatrix(Transpose,_A);
   b := multMatrixVec(Transpose,_b);

   // Free Memory
   SetLength(Transpose, 0);
end;

destructor TCholeskySolver.Destroy;
begin
   SetLength(Answer, 0);
   SetLength(A, 0);
   SetLength(b, 0);
   SetLength(y, 0);
   inherited Destroy;
end;

procedure TCholeskySolver.Execute;
begin
   // Decompose L
   decomposeL();
   // Solve L
   solveLyb(); // Ly = b
   solveLxy(); // L*x = y
end;

// "Transforms" A into L, a lower triangular matrix.
procedure TCholeskySolver.DecomposeL;
var
   i, j, k: integer;
   ajj: real;
begin
   j := 0;
   while j < m do
   begin
      k := 0;
      while k < j do
      begin
         i := j;
         while i < m do
         begin
            SetMatrixElem(A,j,i,GetMatrixElem(A,j,i) - (GetMatrixElem(A,k,i) * GetMatrixElem(A,k,j)));
            inc(i);
         end;
         inc(k);
      end;
      ajj := sqrt(GetMatrixElem(A,j,j));
      SetMatrixElem(A,j,j,ajj);
      k := j + 1;
      while k < m do
      begin
         SetMatrixElem(A,j,k,GetMatrixElem(A,j,k) / ajj);
         inc(k);
      end;
      inc(j);
   end;
end;

// Ly = b; where L is A, y is y and b is the answer. (forward substitution)
procedure TCholeskySolver.solveLyb;
var
   i, j: integer;
   value: real;
begin
   i := 0;
   while i < m do
   begin
      value := b[i];
      j := 0;
      while j < i do
      begin
         value := value - (y[j] * GetMatrixElem(A,i,j));
         inc(j);
      end;
      y[i] := value / GetMatrixElem(A,i,i);
      inc(i);
   end;
end;

// L*x = y; where L* is A* (transposed A), x is answer and y is y. (back substitution)
procedure TCholeskySolver.solveLxy;
var
   i, j: integer;
   value: real;
begin
   i := m - 1;
   while i >= 0 do
   begin
      value := y[i];
      j := m - 1;
      while j > i do
      begin
         value := value - (answer[j] * GetMatrixElem(A,j,i)); // (i and j are inverted, since A is transposed)
         dec(j);
      end;
      answer[i] := value / GetMatrixElem(A,i,i);
      dec(i);
   end;
end;

function TCholeskySolver.BuildTranspose(const _mat: AFloat): AFloat;
var
   i, j: integer;
begin
   SetLength(Result, High(_mat)+1);
   i := 0;
   while i < m do
   begin
      j := 0;
      while j < m do
      begin
         SetMatrixElem(Result,i,j,GetMatrixElem(_mat,j,i));
         inc(j);
      end;
      inc(i);
   end;
end;

function TCholeskySolver.MultMatrix(const _mat1, _mat2: AFloat): AFloat;
var
   i, j, k: integer;
   value: real;
begin
   SetLength(Result, High(_mat1) + 1);
   i := 0;
   while i < m do
   begin
      j := 0;
      while j < m do
      begin
         value := 0;
         k := 0;
         while k < m do
         begin
            value := value + (GetMatrixElem(_mat1, i, k) * GetMatrixElem(_mat2, k, j));
            inc(k);
         end;
         SetMatrixElem(Result,i,j,value);
         inc(j);
      end;
      inc(i);
   end;
end;

function TCholeskySolver.MultMatrixVec(const _mat, _vec: AFloat): AFloat;
var
   j, k: integer;
   value: real;
begin
   SetLength(Result, m);
   j := 0;
   while j < m do
   begin
      value := 0;
      k := 0;
      while k < m do
      begin
         value := value + (GetMatrixElem(_mat, j, k) * _vec[k]);
         inc(k);
      end;
      Result[j] := value;
      inc(j);
   end;
end;

function TCholeskySolver.GetMatrixElem(const _Matrix: AFloat; i, j: integer): real;
begin
   Result := _Matrix[(i * m) + j];
end;

procedure TCholeskySolver.SetMatrixElem(const _Matrix: AFloat; i, j: integer; _Value: real);
begin
   _Matrix[(i * m) + j] := _Value;
end;

end.
