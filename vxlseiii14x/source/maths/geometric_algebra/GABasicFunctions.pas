unit GABasicFunctions;

interface

function PowerBase2(_exponent: integer): integer;

implementation

function PowerBase2(_exponent: integer): integer;
var
   i : integer;
begin
   Result := 1;
   if _exponent > 0 then
   begin
      for i := 1 to _exponent do
      begin
         Result := Result * 2;
      end;
   end;
end;

end.
