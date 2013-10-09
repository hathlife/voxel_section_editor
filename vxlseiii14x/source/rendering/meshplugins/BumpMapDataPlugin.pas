unit BumpMapDataPlugin;

interface

uses BasicDataTypes, MeshPluginBase, Math3d, GlConstants;

type
   TBumpMapDataPlugin = class (TMeshPluginBase)
      public
         Tangents : TAVector3f;
         BiTangents : TAVector3f;
         Handedness : aint32;
         // Constructors and destructors
         constructor Create(const _Vertices: TAVector3f; const _Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; _VerticesPerFace: integer);
         destructor Destroy; override;
   end;

implementation

// Constructors and destructors

// Automatic Tangent Vector generation, adapted from http://www.terathon.com/code/tangent.html
constructor TBumpMapDataPlugin.Create(const _Vertices: TAVector3f; const _Normals: TAVector3f; const _TexCoords: TAVector2f; const _Faces: auint32; _VerticesPerFace: integer);
var
   Tan1,Tan2: TAVector3f;
   i,face,v : integer;
   P1, P2, SDIR, TDIR: TVector3f;
   UV1, UV2: TVector2f;
   r : single;
begin
   // Basic Plugin Setup
   FPluginType := C_MPL_BUMPMAPDATA;
   AllowRender := false;
   AllowUpdate := false;

   // Setup Exclusive Data
   SetLength(Tan1,High(_Vertices)+1);
   SetLength(Tan2,High(_Vertices)+1);
   SetLength(Tangents,High(_Vertices)+1);
   SetLength(BiTangents,High(_Vertices)+1);
   SetLength(Handedness,High(_Vertices)+1);

   for i := Low(Tan1) to High(Tan1) do
   begin
      Tan1[i].X := 0;
      Tan1[i].Y := 0;
      Tan1[i].Z := 0;
      Tan2[i].X := 0;
      Tan2[i].Y := 0;
      Tan2[i].Z := 0;
   end;

   Face := 0;
   while Face < High(_Faces) do
   begin
      P1.X := _Vertices[_Faces[Face+2]].X - _Vertices[_Faces[Face+1]].X;
      P1.Y := _Vertices[_Faces[Face+2]].Y - _Vertices[_Faces[Face+1]].Y;
      P1.Z := _Vertices[_Faces[Face+2]].Z - _Vertices[_Faces[Face+1]].Z;
      P2.X := _Vertices[_Faces[Face]].X - _Vertices[_Faces[Face+1]].X;
      P2.Y := _Vertices[_Faces[Face]].Y - _Vertices[_Faces[Face+1]].Y;
      P2.Z := _Vertices[_Faces[Face]].Z - _Vertices[_Faces[Face+1]].Z;

      UV1.U := _TexCoords[_Faces[Face+2]].U - _TexCoords[_Faces[Face+1]].U;
      UV1.V := _TexCoords[_Faces[Face+2]].V - _TexCoords[_Faces[Face+1]].V;
      UV2.U := _TexCoords[_Faces[Face]].U - _TexCoords[_Faces[Face+1]].U;
      UV2.V := _TexCoords[_Faces[Face]].V - _TexCoords[_Faces[Face+1]].V;

      r := (1 / (UV1.U * UV2.V - UV2.U * UV1.V));
      SDIR.X := ((UV2.V * P1.X) - (UV1.V * P2.X)) * r;
      SDIR.Y := ((UV2.V * P1.Y) - (UV1.V * P2.Y)) * r;
      SDIR.Z := ((UV2.V * P1.Z) - (UV1.V * P2.Z)) * r;
      TDIR.X := (UV1.U * P2.X - UV2.U * P1.X) * r;
      TDIR.Y := (UV1.U * P2.Y - UV2.U * P1.Y) * r;
      TDIR.Z := (UV1.U * P2.Z - UV2.U * P1.Z) * r;

      Tan1[_Faces[Face]] := AddVector(Tan1[_Faces[Face]],sdir);
      Tan1[_Faces[Face+1]] := AddVector(Tan1[_Faces[Face+1]],sdir);
      Tan1[_Faces[Face+2]] := AddVector(Tan1[_Faces[Face+2]],sdir);

      Tan2[_Faces[Face]] := AddVector(Tan2[_Faces[Face]],tdir);
      Tan2[_Faces[Face+1]] := AddVector(Tan2[_Faces[Face+1]],tdir);
      Tan2[_Faces[Face+2]] := AddVector(Tan2[_Faces[Face+2]],tdir);

      inc(Face,_VerticesPerFace);
   end;

    for v := Low(_Vertices) to High(_Vertices) do
    begin
        // Gram-Schmidt orthogonalize
        Tangents[v] := SubtractVector(Tan1[v],ScaleVector(_Normals[v],DotProduct(_Normals[v], Tan1[v])));
        Normalize(Tangents[v]);

        // Calculate handedness
        if (DotProduct(CrossProduct(_Normals[v], Tan1[v]), Tan2[v]) < 0) then
        begin
           Handedness[v] := -1;
        end
        else
        begin
           Handedness[v] := 1;
        end;

        BiTangents[v] := ScaleVector(CrossProduct(_Normals[v],Tangents[v]),Handedness[v]);
        Normalize(BiTangents[v]);
    end;
    // Free memory here.
   SetLength(Tan1,0);
   SetLength(Tan2,0);
end;

destructor TBumpMapDataPlugin.Destroy;
begin
   SetLength(Tangents,0);
   SetLength(BiTangents,0);
   SetLength(Handedness,0);
   inherited Destroy;
end;


end.
