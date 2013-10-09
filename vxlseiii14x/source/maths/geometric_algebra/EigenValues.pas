unit EigenValues;

interface

uses math;

{
Copyright © 1999 CERN - European Organization for Nuclear Research.
Permission to use, copy, modify, distribute and sell this software and its documentation for any purpose
is hereby granted without fee, provided that the above copyright notice appear in all copies and
that both that copyright notice and this permission notice appear in supporting documentation.
CERN makes no representations about the suitability of this software for any purpose.
It is provided "as is" without expressed or implied warranty.
}

// This file is derived from cern.colt.matrix.linalg;
// It translates java codes from CERN, but I've reduced it for symmetric matrixes
// only.

type
   TEigenValueDecomposition = class
      private
         FDimension: cardinal;
         FSize: cardinal;
         FEigenValues: PSingle;
         FImagEigenValues: PSingle;
         FEigenVectors: PSingle;

         // Misc
         function hypot(_a, _b: single): single;
         procedure tred2();
         procedure tql2();
      public
         // Constructors and Destructors
         constructor Create(var _Matrix: PSingle; _Dimension: integer);
         destructor Destroy; override;

         // Gets
         function GetEigenvalues(_i: integer): single;
         function GetImagEigenvalues(_i: integer): single;
         function GetEigenVectors(_i, _j: integer): single;

         // Sets
         procedure SetEigenvalues(_i: integer; _value: single);
         procedure SetImagEigenvalues(_i: integer; _value: single);
         procedure SetEigenVectors(_i,_j: integer; _value: single);
   end;

implementation

// Warning: here we are taking into account that our _Matrix is symmetric.
// If your matrix is not symmetric, it will fail hard!
constructor TEigenValueDecomposition.Create(var _Matrix: PSingle; _Dimension: integer);
var
   i : integer;
begin
   // Get Dimension
   FDimension := _Dimension;
   // Copy Matrix
   FSize := FDimension * FDimension;
   GetMem(FEigenVectors,FSize);
   for i := 0 to FSize - 1 do
   begin
      PSingle(Cardinal(FEigenVectors)+i)^ := PSingle(Cardinal(_Matrix)+i)^;
   end;
   // Set Eigenvalues vectors.
   GetMem(FEigenValues,FDimension);
   GetMem(FImagEigenValues,FDimension);
   for i := 0 to FDimension - 1 do
   begin
      PSingle(Cardinal(FEigenValues)+i)^ := 0;
      PSingle(Cardinal(FEigenValues)+i)^ := 0;
   end;

   // Tridiagonalize.
	tred2();

	// Diagonalize.
	tql2();
end;

// Say bye bye!
destructor TEigenValueDecomposition.Destroy;
begin
   FreeMem(FEigenVectors);
   FreeMem(FEigenValues);
   FreeMem(FImagEigenValues);
   inherited Destroy;
end;


// Gets
// These functions are relying too much at the programmer. They may have access
// violation if misused.
function TEigenValueDecomposition.GetEigenvalues(_i: integer): single;
begin
   Result := PSingle(Cardinal(FEigenvalues)+_i)^
end;

function TEigenValueDecomposition.GetImagEigenvalues(_i: integer): single;
begin
   Result := PSingle(Cardinal(FImagEigenvalues)+_i)^
end;

function TEigenValueDecomposition.GetEigenVectors(_i, _j: integer): single;
begin
   Result := PSingle(Cardinal(FEigenVectors)+_i+(FDimension * _j))^;
end;

// Sets
// These functions are relying too much at the programmer. They may have access
// violation if misused.
procedure TEigenValueDecomposition.SetEigenvalues(_i: integer; _value: single);
begin
   PSingle(Cardinal(FEigenvalues)+_i)^ := _value;
end;

procedure TEigenValueDecomposition.SetImagEigenvalues(_i: integer; _value: single);
begin
   PSingle(Cardinal(FImagEigenvalues)+_i)^ := _value;
end;

procedure TEigenValueDecomposition.SetEigenVectors(_i,_j: integer; _value: single);
begin
   PSingle(Cardinal(FEigenVectors)+_i+(FDimension * _j))^ := _value;
end;

// Misc
function TEigenValueDecomposition.hypot(_a, _b: single): single;
begin
	if (abs(_a) > abs(_b)) then
   begin
		Result := _b/_a;
		Result := abs(_a) * sqrt(1+Result*Result);
	end
   else if (_b <> 0) then
   begin
		Result := _a/_b;
		Result := abs(_b) * sqrt(1+Result*Result);
	end
   else
   begin
		Result := 0;
	end;
end;

// Symmetric tridiagonal QL algorithm.
procedure TEigenValueDecomposition.tql2 ();
var
   i,l,m,iter,j,k : cardinal;
   f,tst1,eps,g,p,r,dl1,h,c,c2,c3,el1,s,s2: single;
begin
	//  This is derived from the Algol procedures tql2, by
	//  Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
	//  Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
	//  Fortran subroutine in EISPACK.

	i := 1;
   while i < FDimension do
   begin
	   SetImagEigenvalues(i-1,GetImagEigenvalues(i));
      inc(i);
	end;
	SetImagEigenvalues(FDimension-1,0);

	f := 0;
	tst1 := 0.0;
	eps := math.Power(2,-52.0);
	l := 0;
   while l < FDimension do
   begin
      // Find small subdiagonal element
      tst1 := Math.max(tst1,abs(GetEigenvalues(l)) + abs(GetImagEigenvalues(l)));
	   m := l;
	   while (m < FDimension) do
      begin
			if (abs(GetImagEigenvalues(m)) <= (eps*tst1)) then
			   break;
		end;
	   inc(m);
      inc(l);
   end;

   // If m == l, d[l] is an eigenvalue,
	// otherwise, iterate.
   if (m > l) then
   begin
		iter := 0;
		repeat
			iter := iter + 1;  // (Could check iteration count here.)

			// Compute implicit shift
         g := GetEigenvalues(l);
			p := (GetEigenvalues(l+1) - g) / (2.0 * GetImagEigenvalues(l));
			r := hypot(p,1);
			if (p < 0) then
         begin
				r := -r;
			end;
			SetEigenvalues(l,GetImagEigenvalues(l) / (p + r));
			SetEigenvalues(l+1,GetImagEigenvalues(l) * (p + r));
			dl1 := GetEigenvalues(l+1);
			h := g - GetEigenvalues(l);
         i := l+2;
			while i < FDimension do
         begin
				SetEigenvalues(i,GetEigenvalues(i) - h);
            inc(i);
         end;
 	      f := f + h;

			// Implicit QL transformation.
         p := GetEigenvalues(m);
			c := 1;
			c2 := c;
			c3 := c;
			el1 := GetImagEigenvalues(l+1);
			s := 0;
			s2 := 0;
         i := m-1;
			while i >= l do
         begin
				c3 := c2;
				c2 := c;
				s2 := s;
				g := c * GetImagEigenvalues(i);
				h := c * p;
				r := hypot(p,GetImagEigenvalues(i));
				SetImagEigenvalues(i+1, s * r);
				s := GetImagEigenvalues(i) / r;
				c := p / r;
				p := c * GetEigenvalues(i) - s * g;
				SetEigenvalues(i+1, h + s * (c * g + s * GetEigenvalues(i)));

				// Accumulate transformation.
            k := 0;
            while (k < FDimension) do
            begin
					h := GetEigenVectors(k,i+1);
					SetEigenVectors(k, i+1, s * GetEigenVectors(k,i) + c * h);
					SetEigenVectors(k, i, c * GetEigenVectors(k,i) - s * h);
               inc(k);
				end;
            inc(i);
         end;
			p := -s * s2 * c3 * el1 * GetImagEigenvalues(l) / dl1;
			SetImagEigenvalues(l, s * p);
			SetEigenvalues(l, c * p);

		// Check for convergence.
      until (abs(GetImagEigenvalues(l)) <= (eps*tst1));

		SetEigenvalues(l, GetEigenvalues(l) + f);
		SetImagEigenvalues(l, 0);
	end;

   // Sort eigenvalues and corresponding vectors.
   i := 0;
   while i < (FDimension-1) do
   begin
		k := i;
		p := GetEigenvalues(i);
      j := i+1;
      while j < FDimension do
      begin
			if (GetEigenvalues(j) < p) then
         begin
			   k := j;
			   p := GetEigenvalues(j);
         end;
         inc(j);
      end;
		inc(i);
	   if (k <> i) then
      begin
			SetEigenvalues(k, GetEigenvalues(i));
			SetEigenvalues(i, p);
         j := 0;
			while j < FDimension do
         begin
			   p := GetEigenVectors(j,i);
			   SetEigenVectors(j, i, GetEigenVectors(j,k));
			   SetEigenVectors(j, k, p);
            inc(j);
			end;
      end;
	end;
end;

//Symmetric Householder reduction to tridiagonal form.
procedure TEigenValueDecomposition.tred2 ();
var
   i,j,k: cardinal;
   scale,f,g,h,hh: single;
begin
   //  This is derived from the Algol procedures tred2 by
   //  Bowdler, Martin, Reinsch, and Wilkinson, Handbook for
   //  Auto. Comp., Vol.ii-Linear Algebra, and the corresponding
   //  Fortran subroutine in EISPACK.
   j := 0;
   while j < FDimension do
   begin
		 SetEigenValues(j, GetEigenVectors(FDimension-1, j));
       inc(j);
   end;

   // Householder reduction to tridiagonal form.
   i := FDimension-1;
	while i > 0 do
   begin
	   // Scale to avoid under/overflow.
      scale := 0;
		h := 0;
      k := 0;
		while k < i do
      begin
			scale := scale + abs(GetEigenValues(k));
         inc(k);
		end;
		if (scale = 0) then
      begin
			SetImagEigenvalues(i, GetEigenValues(i-1));
         j := 0;
			while j < i do
         begin
			   SetEigenvalues(j, GetEigenVectors(i-1,j));
			   SetEigenVectors(i, j, 0);
			   SetEigenVectors(j, i, 0);
            inc(j);
			end;
		end
      else
      begin
         // Generate Householder vector.
         k := 0;
			while k < i do
         begin
			   SetEigenValues(k, GetEigenValues(k) / scale);
			   h := h + (GetEigenValues(k) * GetEigenValues(k));
            inc(k);
			end;
			f := GetEigenValues(i-1);
			g := sqrt(h);
			if (f > 0) then
         begin
			   g := -g;
			end;
			SetImagEigenvalues(i, scale * g);
			h := h - f * g;
			SetEigenValues(i-1, f - g);
         j := 0;
			while j < i do
         begin
			   SetImagEigenValues(j, 0);
            inc(j);
         end;

			// Apply similarity transformation to remaining columns.
         j := 0;
			while j < i do
         begin
			   f := GetEigenValues(j);
			   SetEigenVectors(j, i, f);
			   g := GetImagEigenValues(j) + GetEigenVectors(j,j) * f;
            k := j+1;
			   while k <= (i-1) do
            begin
				   g := g + GetEigenVectors(k,j) * GetEigenValues(k);
				   SetImagEigenvalues(k, GetImagEigenvalues(k) + GetEigenVectors(k,j) * f);
               inc(k);
            end;
			   SetImagEigenvalues(j, g);
            inc(j);
         end;

			f := 0;
         j := 0;
			while j < i do
         begin
			   SetImagEigenvalues(j, GetImagEigenvalues(j) / h);
			   f := f + (GetImagEigenvalues(j) * GetEigenvalues(j));
            inc(j);
			end;
			hh := f / (h + h);
         j := 0;
			while j < i do
         begin
			   SetImagEigenvalues(j, GetImagEigenvalues(j) - hh * GetEigenvalues(j));
            inc(j);
         end;
         j := 0;
			while j < i do
         begin
			   f := GetEigenvalues(j);
			   g := GetImagEigenvalues(j);
            k := j;
			   while k <= (i-1) do
            begin
				   SetEigenVectors(k, j, GetEigenVectors(k,j) - (f * GetImagEigenValues(k) + g * GetEigenvalues(k)));
               inc(k);
            end;
			   SetEigenvalues(j, GetEigenVectors(i-1,j));
			   SetEigenVectors(i, j, 0);
            inc(j);
         end;
      end;
   	SetEigenvalues(i, h);
      dec(j);
   end;

	// Accumulate transformations.
   i := 0;
	while i < (FDimension-1) do
   begin
		SetEigenVectors(FDimension-1, i, GetEigenVectors(i,i));
		SetEigenVectors(i, i, 1);
		h := GetEigenvalues(i+1);
		if (h <> 0) then
      begin
         k := 0;
		   while k <= i do
         begin
			   SetEigenvalues(k, GetEigenVectors(k,i+1) / h);
            inc(k);
         end;
         j := 0;
			while j <= i do
         begin
			   g := 0;
            k := 0;
			   while k <= i do
            begin
				   g := g + (GetEigenVectors(k,i+1) * GetEigenVectors(k,j));
               inc(k);
			   end;
            k := 0;
			   while k <= i do
            begin
				   SetEigenVectors(k, j, GetEigenVectors(k,j) - (g * GetEigenvalues(k)));
               inc(k);
			   end;
            inc(j);
			end;
		end;
      k := 0;
		while k <= i do
      begin
			SetEigenVectors(k, i+1, 0);
         inc(k);
		end;
      inc(i);
	end;
   j := 0;
	while j < FDimension do
   begin
	   SetEigenvalues(j,GetEigenVectors(FDimension-1,j));
		SetEigenVectors(FDimension-1, j, 0);
      inc(j);
   end;
	SetEigenVectors(FDimension-1, FDimension-1, 1);
	SetImagEigenvalues(0, 0);
end;

end.
