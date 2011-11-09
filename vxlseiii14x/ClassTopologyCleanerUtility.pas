unit ClassTopologyCleanerUtility;

interface

uses GLConstants, BasicDataTypes;

type
   TTopologyCleanerUtility = class
      private
         EdgeNeighbors: aint32;
         FaceData: aint32;
      public
         constructor Create(_NumVertices: integer);

   end;

implementation

constructor TTopologyCleanerUtility.Create(_NumVertices: integer);
var
   x : integer;
begin
   SetLength(EdgeNeighbors,_NumVertices*6);
   SetLength(FaceData,_NumVertices*6);
   for x := 0 to High(FaceData) do
   begin
      EdgeNeighbors[x] := C_TOPO_DOESNT_EXIST;
      FaceData[x] := C_TOPO_DOESNT_EXIST;
   end;
end;

end.
