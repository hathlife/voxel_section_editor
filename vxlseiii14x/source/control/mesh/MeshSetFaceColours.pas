unit MeshSetFaceColours;

interface

uses LOD, BasicMathsTypes;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSetFaceColours = class
      protected
         FLOD: TLOD;
      public
         DistanceFunction: TDistanceFunc;

         constructor Create(var _LOD: TLOD); virtual;
         procedure Execute;
   end;

implementation

uses MeshColourCalculator, GLConstants, DistanceFormulas;

constructor TMeshSetFaceColours.Create(var _LOD: TLOD);
begin
   FLOD := _LOD;
   DistanceFunction := GetLinearDistance;
end;

procedure TMeshSetFaceColours.Execute;
var
   i: integer;
   Calculator: TMeshColourCalculator;
begin
   Calculator := TMeshColourCalculator.Create;
   Calculator.DistanceFunction := DistanceFunction;
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      // Calculate Vertex Normals
      Calculator.FindMeshFaceColours(FLOD.Mesh[i]);
      FLOD.Mesh[i].SetColoursType(C_COLOURS_PER_FACE);
      FLOD.Mesh[i].SetColourGenStructure(C_COLOURS_PER_FACE);
      FLOD.Mesh[i].ForceRefresh;
   end;
   Calculator.Free;
end;

end.
