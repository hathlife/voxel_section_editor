unit DistanceFormulas;

interface

uses BasicMathsTypes;

const
   CDF_IGNORED = 0;
   CDF_LINEAR = 1;
   CDF_LINEAR_INV = 2;
   CDF_QUADRIC = 3;
   CDF_QUADRIC_INV = 4;
   CDF_CUBIC = 5;
   CDF_CUBIC_INV = 6;
   CDF_LANCZOS = 7;
   CDF_LANCZOS_INV_A1 = 8;
   CDF_LANCZOS_INV_A3 = 9;
   CDF_LANCZOS_INV_AC = 10;
   CDF_SINC = 11;
   CDF_SINC_INV = 12;
   CDF_EULER = 13;
   CDF_EULERSQUARED = 14;
   CDF_SINCINFINITE = 15;
   CDF_SINCINFINITE_INV = 16;

function GetDistanceFormula(_ID: integer): TDistanceFunc;

// Distance Functions
function GetIgnoredDistance(_Distance : single): single;
function GetLinearDistance(_Distance : single): single;
function GetLinearInvDistance(_Distance : single): single;
function GetQuadricDistance(_Distance : single): single;
function GetQuadricInvDistance(_Distance : single): single;
function GetCubicDistance(_Distance : single): single;
function GetCubicInvDistance(_Distance : single): single;
function GetLanczosDistance(_Distance : single): single;
function GetLanczosInvA1Distance(_Distance : single): single;
function GetLanczosInvA3Distance(_Distance : single): single;
function GetLanczosInvACDistance(_Distance : single): single;
function GetSincDistance(_Distance : single): single;
function GetSincInvDistance(_Distance : single): single;
function GetEulerDistance(_Distance : single): single;
function GetEulerSquaredDistance(_Distance : single): single;
function GetSincInfiniteDistance(_Distance : single): single;
function GetSincInfiniteInvDistance(_Distance : single): single;


implementation

uses Math, GLConstants;

function GetDistanceFormula(_ID: integer): TDistanceFunc;
begin
   case (_ID) of
      CDF_IGNORED: Result := GetIgnoredDistance;
      CDF_LINEAR: Result := GetLinearDistance;
      CDF_LINEAR_INV: Result := GetLinearInvDistance;
      CDF_QUADRIC: Result := GetQuadricDistance;
      CDF_QUADRIC_INV: Result := GetQuadricInvDistance;
      CDF_CUBIC: Result := GetCubicDistance;
      CDF_CUBIC_INV: Result := GetCubicInvDistance;
      CDF_LANCZOS: Result := GetLanczosDistance;
      CDF_LANCZOS_INV_A1: Result := GetLanczosInvA1Distance;
      CDF_LANCZOS_INV_A3: Result := GetLanczosInvA3Distance;
      CDF_LANCZOS_INV_AC: Result := GetLanczosInvACDistance;
      CDF_SINC: Result := GetSincDistance;
      CDF_SINC_INV: Result := GetSincInvDistance;
      CDF_EULER: Result := GetEulerDistance;
      CDF_EULERSQUARED: Result := GetEulerSquaredDistance;
      CDF_SINCINFINITE: Result := GetSincInfiniteDistance;
      CDF_SINCINFINITE_INV: Result := GetSincInfiniteInvDistance;
      else
         Result := GetIgnoredDistance;
   end;
end;

// Distance Formulas
function GetIgnoredDistance(_Distance : single): single;
begin
   Result := 1;
end;

function GetLinearDistance(_Distance : single): single;
begin
   Result := _Distance;
end;

function GetLinearInvDistance(_Distance : single): single;
begin
   Result := 1 / (abs(_Distance) + 1);
end;

function GetQuadricDistance(_Distance : single): single;
const
   FREQ_NORMALIZER = 4/3;
begin
   Result := Power(FREQ_NORMALIZER * _Distance,2);
   if _Distance < 0 then
      Result := Result * -1;
end;

function GetQuadricInvDistance(_Distance : single): single;
const
   FREQ_NORMALIZER = 4/3;
begin
   Result := 1 / (1 + Power(FREQ_NORMALIZER * _Distance,2));
   if _Distance < 0 then
      Result := Result * -1;
end;

function GetCubicDistance(_Distance : single): single;
const
   FREQ_NORMALIZER = 1.5;
begin
   Result := Power(FREQ_NORMALIZER * _Distance,3);
end;

function GetCubicInvDistance(_Distance : single): single;
begin
   Result := 1 / (1 + Power(_Distance,3));
end;

function GetLanczosDistance(_Distance : single): single;
const
   PIDIV3 = Pi / 3;
begin
   Result := ((3 * sin(Pi * _Distance) * sin(PIDIV3 * _Distance)) / Power(Pi * _Distance,2));
   if _Distance < 0 then
      Result := Result * -1;
end;

function GetLanczosInvA1Distance(_Distance : single): single;
begin
   Result := 0;
   if _Distance <> 0 then
      Result := 1 - (Power(sin(Pi * _Distance),2) / Power(Pi * _Distance,2));
   if _Distance < 0 then
      Result := Result * -1;
end;

function GetLanczosInvA3Distance(_Distance : single): single;
const
   PIDIV3 = Pi / 3;
begin
   Result := 0;
   if _Distance <> 0 then
     Result := 1 - ((3 * sin(Pi * _Distance) * sin(PIDIV3 * _Distance)) / Power(Pi * _Distance,2));
   if _Distance < 0 then
     Result := Result * -1;
end;

function GetLanczosInvACDistance(_Distance : single): single;
const
   CONST_A = 3;//15;
   NORMALIZER = 2 * Pi;
   PIDIVA = Pi / CONST_A;
var
   Distance: single;
begin
   Result := 0;
   Distance := _Distance * C_FREQ_NORMALIZER;
   if _Distance <> 0 then
//     Result := NORMALIZER * (1 - ((CONST_A * sin(Distance) * sin(Distance / CONST_A)) / Power(Distance,2)));
     Result := (1 - ((CONST_A * sin(Pi * Distance) * sin(PIDIVA * Distance)) / Power(Pi * Distance,2)));
   if _Distance < 0 then
     Result := Result * -1;
end;

function GetSincDistance(_Distance : single): single;
const
   NORMALIZER = 2 * Pi; //6.307993515;
var
   Distance: single;
begin
   Result := 0;
//   Distance := _Distance * C_FREQ_NORMALIZER;
   if _Distance <> 0 then
      Result := (sin(Distance) / Distance);
   if _Distance < 0 then
      Result := Result * -1;
end;

function GetSincInvDistance(_Distance : single): single;
const
   NORMALIZER = 2 * Pi; //6.307993515;
var
   Distance: single;
begin
   Result := 0;
   Distance := _Distance * C_FREQ_NORMALIZER;
   if _Distance <> 0 then
      Result := 1 - (NORMALIZER * (sin(Distance) / Distance));
   if _Distance < 0 then
      Result := Result * -1;
end;

function GetEulerDistance(_Distance : single): single;
var
   i,c : integer;
   Distance : single;
begin
   i := 2;
   Result := 1;
   c := 0;
   Distance := abs(_Distance);
   while c <= 30 do
   begin
      Result := Result * cos(Distance / i);
      i := i * 2;
      inc(c);
   end;
   if _Distance < 0 then
      Result := -Result;
end;

function GetEulerSquaredDistance(_Distance : single): single;
var
   i,c : integer;
begin
   i := 2;
   Result := 1;
   c := 0;
   while c <= 30 do
   begin
      Result := Result * cos(_Distance / i);
      i := i * 2;
      inc(c);
   end;
   Result := Result * Result;
   if _Distance < 0 then
      Result := -Result;
end;

function GetSincInfiniteDistance(_Distance : single): single;
var
   i,c : integer;
   Distance2: single;
begin
   c := 0;
   i := 1;
   Distance2 := _Distance * _Distance;
   Result := 1;
   while c <= 100 do
   begin
      Result := Result * (1 - (Distance2 / (i * i)));
      inc(c);
      inc(i);
   end;
   if _Distance < 0 then
      Result := -Result;
end;

function GetSincInfiniteInvDistance(_Distance : single): single;
var
   i,c : integer;
   Distance2: single;
begin
   c := 0;
   i := 1;
   Distance2 := _Distance * _Distance;
   Result := 1;
   while c <= 100 do
   begin
      Result := Result * (1 - (Distance2 / (i * i)));
      inc(c);
      inc(i);
   end;
   Result := 1 - Result;
   if _Distance < 0 then
      Result := -Result;
end;


end.
