unit NormalsMeshPlugin;

interface

uses MeshPluginBase, BasicDataTypes, GlConstants, BasicConstants, BasicFunctions,
   dglOpenGL, RenderingMachine;

type
   TNormalsMeshPlugin = class (TMeshPluginBase)
      private
         MeshNormalsType: pbyte;
         MeshVerticesPerFace: pbyte;
         MeshVertices: PAVector3f;
         MeshFaces: PAUInt32;
         MeshNormals: PAVector3f;
         FaceType : GLINT;
         NumNormals: integer;
         Vertices: TAVector3f;
         Faces: auint32;
         Colours: TAVector4f;
         Render: TRenderingMachine;
         // Mesh related
         procedure BuildMesh();
         procedure BuildNormalsLine(_ID: integer);
         procedure BuildNormalsLineFromVector(_ID: integer; const _BasePosition: TVector3f);
      protected
         procedure DoRender(); override;
         procedure DoUpdate(); override;
      public
         constructor Create(_NormalsType,_VerticesPerFace: pbyte; const _Vertices, _Normals: TAVector3f; const _Faces: AUint32);
         procedure Initialize; override;
         procedure Clear; override;
   end;



implementation

constructor TNormalsMeshPlugin.Create(_NormalsType,_VerticesPerFace: pbyte; const _Vertices, _Normals: TAVector3f; const _Faces: AUint32);
begin
   FPluginType := C_MPL_NORMALS;
   MeshNormalsType := _NormalsType;
   MeshVerticesPerFace := _VerticesPerFace;
   MeshVertices := PAVector3f(Addr(_Vertices));
   MeshNormals := PAVector3f(Addr(_Normals));
   NumNormals := High(_Normals)+1;
   MeshFaces := PAUInt32(Addr(_Faces));
   FaceType := GL_LINE;
   Initialize;
end;

procedure TNormalsMeshPlugin.Initialize;
begin
   inherited Initialize;
   Render := TRenderingMachine.Create;
   DoUpdate;
end;

procedure TNormalsMeshPlugin.Clear;
begin
   Render.Free;
   SetLength(Colours,0);
   SetLength(Vertices,0);
   SetLength(Faces,0);
end;

procedure TNormalsMeshPlugin.DoUpdate;
begin
   BuildMesh;
   Render.ForceRefresh;
end;

// Rendering related.
procedure TNormalsMeshPlugin.BuildMesh();
var
   Normalsx2: integer;
   n,v : integer;
begin
   Normalsx2 := NumNormals * 2;
   SetLength(Vertices,Normalsx2);
   SetLength(Colours,Normalsx2);
   SetLength(Faces,Normalsx2);
   n := 0;
   v := 0;
   while n < NumNormals do
   begin
      BuildNormalsLine(n);
      Colours[v] := SetVector4f(0.25,0,0,0);
      Faces[v] := v;
      inc(v);
      Colours[v] := SetVector4f(1,0,0,0);
      Faces[v] := v;
      inc(v);
      inc(n);
   end;
end;

procedure TNormalsMeshPlugin.BuildNormalsLine(_ID: integer);
var
   BasePosition: TVector3f;
   i,maxi : integer;
begin
   if MeshNormalsType^ = C_NORMALS_PER_VERTEX then
   begin
      BasePosition.X := (MeshVertices^)[_ID].X + (MeshNormals^)[_ID].X;
      BasePosition.Y := (MeshVertices^)[_ID].Y + (MeshNormals^)[_ID].Y;
      BasePosition.Z := (MeshVertices^)[_ID].Z + (MeshNormals^)[_ID].Z;
   end
   else if MeshNormalsType^ = C_NORMALS_PER_FACE then
   begin
      BasePosition := SetVector(0,0,0);
      i := _ID * MeshVerticesPerFace^;
      maxi := i + MeshVerticesPerFace^ - 1;
      while i <= maxi do
      begin
         BasePosition.X := BasePosition.X + (MeshVertices^)[i].X;
         BasePosition.Y := BasePosition.Y + (MeshVertices^)[i].Y;
         BasePosition.Z := BasePosition.Z + (MeshVertices^)[i].Z;
         inc(i);
      end;
      BasePosition.X := BasePosition.X + (MeshNormals^)[_ID].X;
      BasePosition.Y := BasePosition.Y + (MeshNormals^)[_ID].Y;
      BasePosition.Z := BasePosition.Z + (MeshNormals^)[_ID].Z;
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
begin
   // do nothing
   Render.StartRender;
   Render.RenderWithoutNormalsAndWithColoursPerVertex(Vertices,Colours,Faces,FaceType,2,NumNormals);
   Render.FinishRender(SetVector(0,0,0));
end;

end.
