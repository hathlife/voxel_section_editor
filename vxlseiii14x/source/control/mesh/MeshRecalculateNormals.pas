unit MeshRecalculateNormals;

interface

uses LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshRecalculateNormals = class
      protected
         FLOD: TLOD;
      public
         constructor Create(var _LOD: TLOD); virtual;
         procedure Execute;
   end;

implementation

uses MeshNormalVectorCalculator;

constructor TMeshRecalculateNormals.Create(var _LOD: TLOD);
begin
   FLOD := _LOD;
end;

procedure TMeshRecalculateNormals.Execute;
var
   i: integer;
   Calculator: TMeshNormalVectorCalculator;
begin
   Calculator := TMeshNormalVectorCalculator.Create;
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      // Recalculate Face Normals
      Calculator.FindMeshFaceNormals(FLOD.Mesh[i]);
      // Recalculate Vertex Normals
      Calculator.FindMeshVertexNormals(FLOD.Mesh[i]);
   end;
   Calculator.Free;
end;

end.
