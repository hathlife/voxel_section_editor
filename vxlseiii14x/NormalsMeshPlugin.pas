unit NormalsMeshPlugin;

interface

uses MeshPluginBase, BasicDataTypes, GlConstants, BasicConstants, BasicFunctions,
   dglOpenGL, RenderingMachine, Material;

type
   TNormalsMeshPlugin = class (TMeshPluginBase)
      private
         MeshNormalsType: byte;
         MeshVerticesPerFace: byte;
         MeshVertices: PAVector3f;
         MeshFaces: PAUInt32;
         MeshNormals: PAVector3f;
         FaceType : GLINT;
         NumNormals: integer;
         Vertices: TAVector3f;
         Faces: auint32;
         Colours: TAVector4f;
         Render: TRenderingMachine;
         Material: TMeshMaterial;
         MyMesh: Pointer;
         // Mesh related
         procedure BuildMesh();
         procedure BuildNormalsLine(_ID: integer);
         procedure BuildNormalsLineFromVector(_ID: integer; const _BasePosition: TVector3f);
      protected
         procedure DoRender(); override;
         procedure DoUpdate(_MeshAddress: Pointer); override;
      public
         constructor Create;
         procedure Initialize; override;
         procedure Clear; override;
   end;



implementation

uses Mesh;

constructor TNormalsMeshPlugin.Create;
begin
   FPluginType := C_MPL_NORMALS;
   FaceType := GL_TRIANGLES;
   Initialize;
end;

procedure TNormalsMeshPlugin.Initialize;
begin
   inherited Initialize;
   Material := TMeshMaterial.Create(nil);
   Render := TRenderingMachine.Create;
end;

procedure TNormalsMeshPlugin.Clear;
begin
   Render.Free;
   SetLength(Colours,0);
   SetLength(Vertices,0);
   SetLength(Faces,0);
   Material.Free;
end;

procedure TNormalsMeshPlugin.DoUpdate(_MeshAddress: Pointer);
begin
   MyMesh := _MeshAddress;
   MeshNormalsType := (PMesh(MyMesh))^.NormalsType;
   MeshVerticesPerFace := (PMesh(MyMesh))^.VerticesPerFace;
   MeshVertices := PAVector3f(Addr((PMesh(MyMesh))^.Vertices));
   if MeshNormalsType = C_NORMALS_PER_VERTEX then
   begin
      MeshNormals := PAVector3f(Addr((PMesh(MyMesh))^.Normals));
   end
   else
   begin
      MeshNormals := PAVector3f(Addr((PMesh(MyMesh))^.FaceNormals));
   end;
   NumNormals := High(MeshNormals^)+1;
   MeshFaces := PAUInt32(Addr((PMesh(MyMesh))^.Faces));
   BuildMesh;
   Render.ForceRefresh;
end;

// Rendering related.
procedure TNormalsMeshPlugin.BuildMesh();
var
   Normalsx2,Normalsx3: integer;
   n,v,f : integer;
begin
   Normalsx2 := NumNormals * 2;
   Normalsx3 := NumNormals * 3;
   SetLength(Vertices,Normalsx2);
   SetLength(Colours,Normalsx2);
   SetLength(Faces,Normalsx3);
   n := 0;
   v := 0;
   f := 0;
   while n < NumNormals do
   begin
      BuildNormalsLine(n);
      Colours[v] := SetVector4f(0.25,0,0,C_TRP_OPAQUE);
      Faces[f] := v;
      inc(v);
      inc(f);
      Colours[v] := SetVector4f(1,0,0,C_TRP_OPAQUE);
      Faces[f] := v;
      inc(f);
      Faces[f] := v-1;
      inc(f);
      inc(v);
      inc(n);
   end;
end;

procedure TNormalsMeshPlugin.BuildNormalsLine(_ID: integer);
var
   BasePosition: TVector3f;
   i,maxi : integer;
begin
   if MeshNormalsType = C_NORMALS_PER_VERTEX then
   begin
      BasePosition.X := (MeshVertices^)[_ID].X;
      BasePosition.Y := (MeshVertices^)[_ID].Y;
      BasePosition.Z := (MeshVertices^)[_ID].Z;
   end
   else if MeshNormalsType = C_NORMALS_PER_FACE then
   begin
      BasePosition := SetVector(0,0,0);
      i := _ID * MeshVerticesPerFace;
      maxi := i + MeshVerticesPerFace;
      while i < maxi do
      begin
         BasePosition.X := BasePosition.X + (MeshVertices^)[i].X;
         BasePosition.Y := BasePosition.Y + (MeshVertices^)[i].Y;
         BasePosition.Z := BasePosition.Z + (MeshVertices^)[i].Z;
         inc(i);
      end;
      BasePosition.X := (BasePosition.X / MeshVerticesPerFace);
      BasePosition.Y := (BasePosition.Y / MeshVerticesPerFace);
      BasePosition.Z := (BasePosition.Z / MeshVerticesPerFace);
   end;
   BuildNormalsLineFromVector(_ID,BasePosition);
end;

procedure TNormalsMeshPlugin.BuildNormalsLineFromVector(_ID: integer; const _BasePosition: TVector3f);
var
   IDx2 : integer;
begin
   IDx2 := _ID * 2;
   Vertices[IDx2].X := _BasePosition.X;
   Vertices[IDx2].Y := _BasePosition.Y;
   Vertices[IDx2].Z := _BasePosition.Z;
   inc(IDx2);
   Vertices[IDx2].X := _BasePosition.X + (MeshNormals^)[_ID].X;
   Vertices[IDx2].Y := _BasePosition.Y + (MeshNormals^)[_ID].Y;
   Vertices[IDx2].Z := _BasePosition.Z + (MeshNormals^)[_ID].Z;
end;

procedure TNormalsMeshPlugin.DoRender;
var
   PolygonMode: PGLInt;
begin
   // do nothing
   Render.StartRender;
   GetMem(PolygonMode,4);
   glDisable(GL_LIGHTING);
   glGetIntegerv(GL_POLYGON_MODE,PolygonMode);
   glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
   Material.Enable;
   Render.RenderWithoutNormalsAndWithColoursPerVertex(Vertices,Colours,Faces,FaceType,2,NumNormals);
   Material.Disable;
   Render.FinishRender(SetVector(0,0,0));
   glPolygonMode(GL_FRONT_AND_BACK,PolygonMode^);
   FreeMem(PolygonMode);
   glEnable(GL_LIGHTING);
end;

end.
