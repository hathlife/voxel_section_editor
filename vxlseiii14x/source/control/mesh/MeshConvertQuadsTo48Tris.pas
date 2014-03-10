unit MeshConvertQuadsTo48Tris;

interface

uses LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshConvertQuadsTo48Tris = class
      protected
         FLOD: TLOD;
      public
         constructor Create(var _LOD: TLOD); virtual;
         procedure Execute;
   end;

implementation

uses MeshGeometryBase, MeshBRepGeometry;

constructor TMeshConvertQuadsTo48Tris.Create(var _LOD: TLOD);
begin
   FLOD := _LOD;
end;

procedure TMeshConvertQuadsTo48Tris.Execute;
var
   i: integer;
   CurrentGeometry: PMeshGeometryBase;
begin
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      FLOD.Mesh[i].Geometry.GoToFirstElement;
      CurrentGeometry := FLOD.Mesh[i].Geometry.Current;
      while CurrentGeometry <> nil do
      begin
         (CurrentGeometry^ as TMeshBRepGeometry).ConvertQuadsTo48Tris(Addr(FLOD.Mesh[i]));
         FLOD.Mesh[i].Geometry.GoToNextElement;
         CurrentGeometry := FLOD.Mesh[i].Geometry.Current;
      end;
   end;
end;

end.
