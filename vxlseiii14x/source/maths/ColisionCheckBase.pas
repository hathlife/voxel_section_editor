unit ColisionCheckBase;

interface

{$INCLUDE source/Global_Conditionals.inc}

type
   CColisionCheckBase = class
      protected
         function Epsilon(_value: single):single;
   end;

implementation

function CColisionCheckBase.Epsilon(_value: single):single;
begin
   Result := _Value;
   if abs(_Value) < 0.000001 then
      Result := 0;
end;


end.
