unit MeshCurvatureMeasure;

interface

uses BasicMathsTypes, NeighborDetector;

const
   CMCM_CONVEX = 0;
   CMCM_CONCAVE = 1;
   CMCM_SADDLE = 2;
   CMCM_PART_OF_EDGE = 3;
   CMCM_PART_OF_FACE = 4;

type
   TMeshCurvatureMeasure = class
      public
         // Get a curvature measure.
         function GetVertexCurvatureAngle(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
         function GetVertexCurvatureLength(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
         function GetVertexAngleSum(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
         function GetVertexAngleSumFactor(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;

         // Just check if it is convex, concave or something else.
         function GetVertexClassification(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): integer;
         function IsVertexConvex(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): boolean;
         function IsVertexConcave(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): boolean;
         function IsVertexUseful(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): boolean;
   end;

implementation

uses Math3d, Math, BasicFunctions;

function TMeshCurvatureMeasure.GetVertexCurvatureAngle(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
const
   C_DEFAULT = 999999;
var
   v : integer;
   Direction: TVector3f;
   DotResult: single;
begin
   Result := C_DEFAULT;
   v := _NeighborDetector.GetNeighborFromID(_ID);
   while v <> -1 do
   begin
      Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
      Normalize(Direction);
      DotResult := DotProduct(_VertexNormals[_ID],Direction);
      if DotResult <> 0 then
      begin
         if Abs(DotResult) < Result then
         begin
            if (Result <> C_DEFAULT) and ((Result * DotResult) > 0) then
            begin
               Result := DotResult;
            end
            else if (Result <> C_DEFAULT) then
            begin
               Result := 0;
               exit;
            end
            else
            begin
               Result := DotResult;
            end;
         end;
      end
      else if DotResult = 0 then
      begin
         Result := 0;
         exit;
      end;
      v := _NeighborDetector.GetNextNeighbor;
   end;
   if Result = C_DEFAULT then
      Result := 0;
end;

function TMeshCurvatureMeasure.GetVertexCurvatureLength(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
const
   C_DEFAULT = 999999;
var
   v : integer;
   Direction: TVector3f;
   DotResult,PreviousDotResult,Length: single;
begin
   PreviousDotResult := C_DEFAULT;
   Result := C_DEFAULT;
   v := _NeighborDetector.GetNeighborFromID(_ID);
   while v <> -1 do
   begin
      Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
      Length := GetVectorLength(Direction);
      Normalize(Direction);
      DotResult := DotProduct(_VertexNormals[_ID],Direction);
      if DotResult <> 0 then
      begin
         Length := Length * DotResult;
         if Abs(Length) < Abs(Result) then
         begin
            if (PreviousDotResult <> C_DEFAULT) and ((PreviousDotResult * DotResult) > 0) then
            begin
               PreviousDotResult := DotResult;
               Result := Length;
            end
            else if (PreviousDotResult <> C_DEFAULT) then
            begin
               Result := 0;
               exit;
            end
            else
            begin
               PreviousDotResult := DotResult;
               Result := Length;
            end;
         end;
      end
      else if DotResult = 0 then
      begin
         Result := 0;
         exit;
      end;
      v := _NeighborDetector.GetNextNeighbor;
   end;
   if Result = C_DEFAULT then
      Result := 0;
end;

// Requires star ordered C_NEIGHBTYPE_VERTEX_VERTEX _NeighborDetector.
function TMeshCurvatureMeasure.GetVertexAngleSum(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
const
   C_DEFAULT = 999999;
var
   v,vNext,firstV : integer;
   Direction,DirectionNext: TVector3f;
   DotResult: single;
begin
   Result := 0;
   v := _NeighborDetector.GetNeighborFromID(_ID);
   if v <> -1 then
   begin
      vNext := _NeighborDetector.GetNextNeighbor;
      firstV := v;
      while vNext <> -1 do
      begin
         Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
         Normalize(Direction);
         DirectionNext := SubtractVector(_Vertices[vNext],_Vertices[_ID]);
         Normalize(DirectionNext);
         DotResult := DotProduct(Direction,DirectionNext);
         Result := Result + arccos(DotResult);
         v := vNext;
         vNext := _NeighborDetector.GetNextNeighbor;
      end;
      if v <> firstV then
      begin
         Direction := SubtractVector(_Vertices[firstV],_Vertices[_ID]);
         Normalize(Direction);
         DotResult := DotProduct(Direction,DirectionNext);
         Result := Result + arccos(DotResult);
      end;
   end;
end;

function TMeshCurvatureMeasure.GetVertexAngleSumFactor(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): single;
const
   C_2PI = 2 * pi;
begin
   Result := epsilon((GetVertexAngleSum(_ID, _Vertices, _VertexNormals, _NeighborDetector) / C_2PI) - 1) + 1;
end;


function TMeshCurvatureMeasure.GetVertexClassification(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): integer;
var
   v,zeroCounter : integer;
   Direction: TVector3f;
   DotResult: single;
begin
   Result := -1;
   zeroCounter := 0;
   v := _NeighborDetector.GetNeighborFromID(_ID);
   while v <> -1 do
   begin
      Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
      Normalize(Direction);
      DotResult := DotProduct(_VertexNormals[_ID],Direction);
      if DotResult > 0 then
      begin
         if Result = -1 then
         begin
            Result := CMCM_CONCAVE; // Pretend that it is concave.
         end
         else if Result = CMCM_CONVEX then
         begin
            Result := CMCM_SADDLE; // Pretend that it is a saddle point.
         end;
      end
      else if DotResult = 0 then
      begin
         if zeroCounter > 1 then
         begin
            Result := CMCM_PART_OF_FACE;
            exit;
         end
         else
         begin
            Result := CMCM_PART_OF_EDGE; // Pretend that it is part of an edge.
            inc(zeroCounter);
         end;
      end
      else
      begin
         if Result = -1 then
         begin
            Result := CMCM_CONVEX; // Pretend that it is convex.
         end
         else if Result = CMCM_CONCAVE then
         begin
            Result := CMCM_SADDLE; // Pretend that it is a saddle point.
         end;
      end;
      v := _NeighborDetector.GetNextNeighbor;
   end;
end;

// New Discrete 'Laplacian' Operator (not really laplacian)
function TMeshCurvatureMeasure.IsVertexConvex(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): boolean;
var
   v : integer;
   Direction: TVector3f;
   DotResult: single;
begin
   v := _NeighborDetector.GetNeighborFromID(_ID);
   while v <> -1 do
   begin
      Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
      Normalize(Direction);
      DotResult := DotProduct(_VertexNormals[_ID],Direction);
      if DotResult <= 0 then
      begin
         Result := false; // it is concave.
         exit;
      end;
      v := _NeighborDetector.GetNextNeighbor;
   end;
   Result := true; // if all angles are smaller than 90', it's convex.
end;

function TMeshCurvatureMeasure.IsVertexConcave(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): boolean;
var
   v : integer;
   Direction: TVector3f;
   DotResult: single;
begin
   v := _NeighborDetector.GetNeighborFromID(_ID);
   while v <> -1 do
   begin
      Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
      Normalize(Direction);
      DotResult := DotProduct(_VertexNormals[_ID],Direction);
      if DotResult >= 0 then
      begin
         Result := false; // it is convex.
         exit;
      end;
      v := _NeighborDetector.GetNextNeighbor;
   end;
   Result := true; // if all angles are higher than 90', it's concave.
end;

function TMeshCurvatureMeasure.IsVertexUseful(_ID: integer; const _Vertices, _VertexNormals: TAVector3f; const _NeighborDetector : TNeighborDetector): boolean;
var
   v : integer;
   Direction: TVector3f;
   DotResult: single;
begin
   v := _NeighborDetector.GetNeighborFromID(_ID);
   while v <> -1 do
   begin
      Direction := SubtractVector(_Vertices[v],_Vertices[_ID]);
      Normalize(Direction);
      DotResult := DotProduct(_VertexNormals[_ID],Direction);
      if DotResult = 0 then
      begin
         Result := false; // it is either part of an edge or face. Not useful.
         exit;
      end;
      v := _NeighborDetector.GetNextNeighbor;
   end;
   Result := true;
end;

end.
