unit MeshInflate;

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, NeighborDetector;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshInflate = class (TMeshProcessingBase)
      protected
         procedure MeshInflateOperation(var _Vertices: TAVector3f);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
   end;

implementation

uses Math;

procedure TMeshInflate.DoMeshProcessing(var _Mesh: TMesh);
begin
   MeshInflateOperation(_Mesh.Vertices);
   _Mesh.ForceRefresh;
end;

procedure TMeshInflate.MeshInflateOperation(var _Vertices: TAVector3f);
var
   v : integer;
   CenterPoint: TVector3f;
   Temp: single;
begin
   CenterPoint := FindMeshCenter(_Vertices);

    // Finally, we do an average for all vertices.
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      Temp := (CenterPoint.X - _Vertices[v].X) * 0.1;
      if Temp > 0 then
         _Vertices[v].X := _Vertices[v].X - Power(Temp,2)
      else
         _Vertices[v].X := _Vertices[v].X + Power(Temp,2);
      Temp := (CenterPoint.Y - _Vertices[v].Y) * 0.1;
      if Temp > 0 then
         _Vertices[v].Y := _Vertices[v].Y - Power(Temp,2)
      else
         _Vertices[v].Y := _Vertices[v].Y + Power(Temp,2);
      Temp := (CenterPoint.Z - _Vertices[v].Z) * 0.1;
      if Temp > 0 then
         _Vertices[v].Z := _Vertices[v].Z - Power(Temp,2)
      else
         _Vertices[v].Z := _Vertices[v].Z + Power(Temp,2);
   end;
end;


end.
