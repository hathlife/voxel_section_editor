unit MeshSetVertexNormals;

interface

uses LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSetVertexNormals = class
      protected
         FLOD: TLOD;
      public
         constructor Create(var _LOD: TLOD); virtual;
         procedure Execute;
   end;

implementation

uses MeshNormalVectorCalculator, GLConstants;

constructor TMeshSetVertexNormals.Create(var _LOD: TLOD);
begin
   FLOD := _LOD;
end;

procedure TMeshSetVertexNormals.Execute;
var
   i: integer;
   Calculator: TMeshNormalVectorCalculator;
begin
   Calculator := TMeshNormalVectorCalculator.Create;
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      // Calculate Vertex Normals
      Calculator.FindMeshVertexNormals(FLOD.Mesh[i]);
      FLOD.Mesh[i].SetNormalsType(C_NORMALS_PER_VERTEX);
      FLOD.Mesh[i].ForceRefresh;
   end;
   Calculator.Free;
end;


end.
