unit TriangleNeighbourSet;

interface

uses BasicDataTypes, BaseSet;

type
   CTriangleNeighbourSet = class (CBaseSet)
      protected
         // Sets
         function SetData(const _Data: Pointer):Pointer; override;
         // Misc
         function CompareData(const _Data1,_Data2: Pointer):boolean; override;
         procedure DisposeData(var _Data:Pointer); override;
   end;

implementation

function CTriangleNeighbourSet.SetData(const _Data: Pointer): Pointer;
begin
   Result := new(PTriangleNeighbourItem);
   (PTriangleNeighbourItem(Result))^.ID := (PTriangleNeighbourItem(_Data))^.ID;
   (PTriangleNeighbourItem(Result))^.V1 := (PTriangleNeighbourItem(_Data))^.V1;
   (PTriangleNeighbourItem(Result))^.V2 := (PTriangleNeighbourItem(_Data))^.V2;
end;

function CTriangleNeighbourSet.CompareData(const _Data1,_Data2: Pointer):boolean;
begin
   Result := (PTriangleNeighbourItem(_Data1)^.ID) = (PTriangleNeighbourItem(_Data2)^.ID);
end;

procedure CTriangleNeighbourSet.DisposeData(var _Data:Pointer);
begin
   Dispose(PTriangleNeighbourItem(_Data));
end;


end.
