unit ColisionCheck;

interface

uses ColisionCheckBase, BasicMathsTypes, BasicDataTypes;

{$INCLUDE source/Global_Conditionals.inc}

type
   PColisionCheck = ^CColisionCheck;
   CColisionCheck = class (CColisionCheckBase)
      private
         function IsVertexInsideOrOutside2DEdge(const _VL1, _VL2, _V: TVector2f): byte;
      public
         function Are2DTrianglesColiding(const _VA1, _VA2, _VA3, _VB1, _VB2, _VB3: TVector2f): boolean;
         function Is2DPointInsideTriangle(const _V, _V1, _V2, _V3: TVector2f): boolean;
         function Is2DTriangleColidingWithMesh(const _V1, _V2, _V3: TVector2f; const _Coords: TAVector2f; const _Faces: auint32; const _AllowedFaces: abool): boolean;
         function Is2DTriangleColidingWithMeshMT(const _V1, _V2, _V3: TVector2f; const _Coords: TAVector2f; const _Faces: auint32; const _AllowedFaces: abool): boolean;
   end;

   TTriangleColidingMeshStruct = record
      Tool: PColisionCheck;
      V1, V2, V3: TVector2f;
      Coords: TAVector2f;
      Faces: auint32;
      AllowedFaces: abool;
      StartElem,FinalElem: integer;
      Result: boolean;
   end;
   PTriangleColidingMeshStruct = ^TTriangleColidingMeshStruct;

implementation

uses GlobalVars, GenericThread;

function CColisionCheck.IsVertexInsideOrOutside2DEdge(const _VL1, _VL2, _V: TVector2f): byte;
var
   Value: single;
begin
   // determinant.
   Value := (_V.U * _VL1.V) + (_V.V * _VL2.U) + (_VL1.U * _VL2.V) - (_V.U * _VL2.V) - (_V.V * _VL1.U) - (_VL1.V * _VL2.U);
   if Epsilon(Value) <= 0 then
   begin
      Result := 1;
   end
   else
   begin
      Result := 0;
   end;
end;


function CColisionCheck.Are2DTrianglesColiding(const _VA1, _VA2, _VA3, _VB1, _VB2, _VB3: TVector2f): boolean;
var
   VertexConfig1,VertexConfig2,VertexConfig3: byte;
begin
   Result := true; // assume true for optimization

   // Collect vertex configurations. 1 is outside and 0 is inside.
   // Vertex 1
   VertexConfig1 := IsVertexInsideOrOutside2DEdge(_VA1, _VA2, _VB1) or (2 * IsVertexInsideOrOutside2DEdge(_VA2, _VA3,_VB1)) or (4 * IsVertexInsideOrOutside2DEdge(_VA3, _VA1, _VB1));
   if VertexConfig1 = 0 then
   begin
      exit; // return true, the vertex is inside the triangle.
   end;
   // Vertex 2
   VertexConfig2 := IsVertexInsideOrOutside2DEdge(_VA1, _VA2, _VB2) or (2 * IsVertexInsideOrOutside2DEdge(_VA2, _VA3, _VB2)) or (4 * IsVertexInsideOrOutside2DEdge(_VA3, _VA1, _VB2));
   if VertexConfig2 = 0 then
   begin
      exit; // return true, the vertex is inside the triangle.
   end;
   // Vertex 3
   VertexConfig3 := IsVertexInsideOrOutside2DEdge(_VA1, _VA2, _VB3) or (2 * IsVertexInsideOrOutside2DEdge(_VA2, _VA3, _VB3)) or (4 * IsVertexInsideOrOutside2DEdge(_VA3, _VA1, _VB3));
   if VertexConfig3 = 0 then
   begin
      exit; // return true, the vertex is inside the triangle.
   end;
   // Now let's check the line segments
   if (VertexConfig1 and VertexConfig2) = 0 then
   begin
      exit; // return true, the line segment crosses the triangle.
   end;
   if (VertexConfig2 and VertexConfig3) = 0 then
   begin
      exit; // return true, the line segment crosses the triangle.
   end;
   if (VertexConfig1 and VertexConfig3) = 0 then
   begin
      exit; // return true, the line segment crosses the triangle.
   end;
   // Now let's check the triangle, if it contains the other or not.
   if (VertexConfig1 and VertexConfig2 and VertexConfig3) = 0 then
   begin
      exit; // return true, the triangle contains the other triangle.
   end;
   Result := false; // return false. There is no colision between the two triangles.
end;

function CColisionCheck.Is2DPointInsideTriangle(const _V, _V1, _V2, _V3: TVector2f): boolean;
var
   VertexConfig: byte;
begin
   // Collect vertex configuration. 1 is outside and 0 is inside.
   VertexConfig := IsVertexInsideOrOutside2DEdge(_V1, _V2, _V) or (2 * IsVertexInsideOrOutside2DEdge(_V2, _V3,_V)) or (4 * IsVertexInsideOrOutside2DEdge(_V3, _V1, _V));
   Result := VertexConfig = 0;
end;


function CColisionCheck.Is2DTriangleColidingWithMesh(const _V1, _V2, _V3: TVector2f; const _Coords: TAVector2f; const _Faces: auint32; const _AllowedFaces: abool): boolean;
var
   i, v: integer;
begin
   // Let's check if this UV Position will hit another UV project face.
   Result := true;
   v := 0;
   for i := Low(_AllowedFaces) to High(_AllowedFaces) do
   begin
      // If the face was projected in the UV domain.
      if _AllowedFaces[i] then
      begin
         // Check if the candidate position is inside this triangle.
         // If it is inside the triangle, then point is not validated. Exit.
         if Are2DTrianglesColiding(_V1,_V2,_V3,_Coords[_Faces[v]],_Coords[_Faces[v+1]],_Coords[_Faces[v+2]]) then
         begin
            Result := false;
            exit;
         end;
      end;
      inc(v,3);
   end;
end;

function ThreadIs2DTriangleColidingWithMesh(const _args: pointer): integer;
var
   Data: TTriangleColidingMeshStruct;
   i, v: integer;
begin
   if _args <> nil then
   begin
      Data := PTriangleColidingMeshStruct(_args)^;
      // Let's check if this UV Position will hit another UV project face.
      Data.Result := false;
      v := 0;
      for i := Data.StartElem to Data.FinalElem do
      begin
         // If the face was projected in the UV domain.
         if Data.AllowedFaces[i] = true then
         begin
            // Check if the candidate position is inside this triangle.
            // If it is inside the triangle, then point is not validated. Exit.
            if (Data.Tool)^.Are2DTrianglesColiding(Data.V1,Data.V2,Data.V3,Data.Coords[Data.Faces[v]],Data.Coords[Data.Faces[v+1]],Data.Coords[Data.Faces[v+2]]) then
            begin
               Data.Result := true;
               exit;
            end;
         end;
         inc(v,3);
      end;
   end;
end;

function CColisionCheck.Is2DTriangleColidingWithMeshMT(const _V1, _V2, _V3: TVector2f; const _Coords: TAVector2f; const _Faces: auint32; const _AllowedFaces: abool): boolean;
   function CreatePackageForThreadCall(const _V1, _V2, _V3: TVector2f; const _Coords: TAVector2f; const _Faces: auint32; const _AllowedFaces: abool; _StartElem,_FinalElem: integer): TTriangleColidingMeshStruct;
   begin
      Result.Tool := Addr(self);
      Result.V1 := _V1;
      Result.V2 := _V2;
      Result.V3 := _V3;
      Result.Coords := _Coords;
      Result.Faces := _Faces;
      Result.AllowedFaces := _AllowedFaces;
      Result.StartElem := _StartElem;
      Result.FinalElem := _FinalElem;
   end;

var
   i, e, step, maxThreads: integer;
   Packages: array of TTriangleColidingMeshStruct;
   Threads: array of TGenericThread;
   MyFunction : TGenericFunction;
begin
   maxThreads := GlobalVars.SysInfo.PhysicalCore;
   e := 0;
   step := (High(_AllowedFaces) + 1) div maxThreads;
   SetLength(Threads, maxThreads);
   SetLength(Packages, maxThreads);
   MyFunction := ThreadIs2DTriangleColidingWithMesh;
   for i := 0 to (maxThreads - 2) do
   begin
      Packages[i] := CreatePackageForThreadCall(_V1, _V2, _V3, _Coords, _Faces, _AllowedFaces, e, e + step - 1);
      Threads[i] := TGenericThread.Create(MyFunction,Addr(Packages[i]));
      e := e + step;
   end;
   // Last thread has a special code.
   i := maxThreads - 1;
   Packages[i] := CreatePackageForThreadCall(_V1, _V2, _V3, _Coords, _Faces, _AllowedFaces, e, High(_AllowedFaces));
   Threads[i] := TGenericThread.Create(MyFunction,Addr(Packages[i]));

   for i := 0 to (maxThreads - 1) do
   begin
      Threads[i].WaitFor;
      Threads[i].Free;
   end;
   Result := false;
   for i := 0 to (maxThreads - 1) do
   begin
      Result := Result or Packages[i].Result;
   end;
   SetLength(Threads,0);
   SetLength(Packages,0);
end;

end.
