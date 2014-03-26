unit LODPostProcessing;

interface

{$INCLUDE source/Global_Conditionals.inc}

uses LOD;

type
   TLODPostProcessing = class
      private
         FQuality: integer;
      public
         constructor Create(_Quality: integer);
         procedure Execute(var _LOD: TLOD);
   end;

implementation

uses GLConstants, MeshSmoothSBGames, DistanceFormulas, MeshConvertQuadsToTris,
   MeshConvertQuadsTo48Tris, MeshRecalculateNormals, MeshSetVertexNormals,
   MeshSetVertexColours;

constructor TLODPostProcessing.Create(_Quality: Integer);
begin
   FQuality := _Quality;
end;

procedure TLODPostProcessing.Execute(var _LOD: TLOD);
var
   MeshSmooth: TMeshSmoothSBGAMES2010;
   MeshConvertQuadsToTris: TMeshConvertQuadsToTris;
   MeshConvertQuadsTo48Tris: TMeshConvertQuadsTo48Tris;
   MeshRecalculateNormals: TMeshRecalculateNormals;
   MeshSetVertexNormals : TMeshSetVertexNormals;
   MeshSetVertexColours : TMeshSetVertexColours;
begin
   case (FQuality) of
      C_QUALITY_LANCZOS_QUADS:
      begin
         MeshSmooth := TMeshSmoothSBGAMES2010.Create(_LOD);
         MeshSmooth.DistanceFunction := GetLanczosInvACDistance;
         MeshSmooth.Execute;
         MeshSmooth.Free;
      end;
      C_QUALITY_2LANCZOS_4TRIS:
      begin
         MeshSmooth := TMeshSmoothSBGAMES2010.Create(_LOD);
         MeshSmooth.DistanceFunction := GetLanczosInvACDistance;
         MeshSmooth.Execute;
         MeshSmooth.Free;
         MeshRecalculateNormals := TMeshRecalculateNormals.Create(_LOD);
         MeshRecalculateNormals.Execute;
         MeshRecalculateNormals.Free;
         MeshSetVertexNormals := TMeshSetVertexNormals.Create(_LOD);
         MeshSetVertexNormals.Execute;
         MeshSetVertexNormals.Free;
         MeshSetVertexColours := TMeshSetVertexColours.Create(_LOD);
         MeshSetVertexColours.Execute;
         MeshSetVertexColours.Free;
         MeshConvertQuadsTo48Tris := TMeshConvertQuadsTo48Tris.Create(_LOD);
         MeshConvertQuadsTo48Tris.Execute;
         MeshConvertQuadsTo48Tris.Free;
      end;
      C_QUALITY_LANCZOS_TRIS:
      begin
         MeshSmooth := TMeshSmoothSBGAMES2010.Create(_LOD);
         MeshSmooth.DistanceFunction := GetLanczosInvACDistance;
         MeshSmooth.Execute;
         MeshSmooth.Free;
         MeshConvertQuadsToTris := TMeshConvertQuadsToTris.Create(_LOD);
         MeshConvertQuadsToTris.Execute;
         MeshConvertQuadsToTris.Free;
         MeshRecalculateNormals := TMeshRecalculateNormals.Create(_LOD);
         MeshRecalculateNormals.Execute;
         MeshRecalculateNormals.Free;
         MeshSetVertexNormals := TMeshSetVertexNormals.Create(_LOD);
         MeshSetVertexNormals.Execute;
         MeshSetVertexNormals.Free;
         MeshSetVertexColours := TMeshSetVertexColours.Create(_LOD);
         MeshSetVertexColours.Execute;
         MeshSetVertexColours.Free;
      end;
      C_QUALITY_SMOOTH_MANIFOLD:
      begin
         MeshSetVertexNormals := TMeshSetVertexNormals.Create(_LOD);
         MeshSetVertexNormals.Execute;
         MeshSetVertexNormals.Free;
         MeshSetVertexColours := TMeshSetVertexColours.Create(_LOD);
         MeshSetVertexColours.Execute;
         MeshSetVertexColours.Free;
      end;
   end;
end;

end.
