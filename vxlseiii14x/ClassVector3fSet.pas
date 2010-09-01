unit ClassVector3fSet;
interface

uses BasicDataTypes, ClassBaseSet;

type
   CVector3fSet = class (CBaseSet)
      protected
         // Sets
         function SetData(const _Data: Pointer):Pointer; override;
         // Misc
         function CompareData(const _Data1,_Data2: Pointer):boolean; override;
         procedure DisposeData(var _Data:Pointer); override;
   end;

implementation

function CVector3fSet.SetData(const _Data: Pointer): Pointer;
begin
   Result := new(PVector3f);
   (PVector3f(Result))^.X := (PVector3f(_Data))^.X;
   (PVector3f(Result))^.Y := (PVector3f(_Data))^.Y;
   (PVector3f(Result))^.Z := (PVector3f(_Data))^.Z;
end;

function CVector3fSet.CompareData(const _Data1,_Data2: Pointer):boolean;
begin
   Result := ((PVector3f(_Data1)^.X) = (PVector3f(_Data2)^.X)) and ((PVector3f(_Data1)^.Y) = (PVector3f(_Data2)^.Y)) and ((PVector3f(_Data1)^.Z) = (PVector3f(_Data2)^.Z));
end;

procedure CVector3fSet.DisposeData(var _Data:Pointer);
begin
   Dispose(PVector3f(_Data));
end;

end.
