unit OBJFile;

interface

uses BasicDataTypes, BasicFunctions, SysUtils;

type
   TObjFile = class
      private
         procedure WriteVertexes(var _File: System.Text; const _Vertexes: TAVector3f);
      public
   end;

implementation

// I/O
procedure TObjFile.WriteVertexes(var _File: System.Text; const _Vertexes: TAVector3f);
var
   v : integer;
begin
   Writeln(_File,'// ' + IntToStr(High(_Vertexes)+1) + ' vertexes.');
   DecimalSeparator := '.';
   for v := Low(_Vertexes) to High(_Vertexes) do
   begin
      Writeln(_File,'v ' + FloatToStr(_Vertexes[v].X) + ' ' + FloatToStr(_Vertexes[v].Y) + ' ' + FloatToStr(_Vertexes[v].Z));
   end;
   Writeln(_File);
end;

end.
