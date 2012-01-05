unit DifferentMeshFaceTypePlugin;

interface

uses MeshPluginBase, BasicDataTypes, GlConstants, BasicConstants, BasicFunctions,
   dglOpenGL, RenderingMachine, Material, MeshBRepGeometry;

type
   TDifferentMeshFaceTypePlugin = class (TMeshPluginBase)
      private
         MeshNormalsType: byte;
         VerticesPerFace: byte;
         MeshVertices: PAVector3f;
         MeshNormals: PAVector3f;
         FaceType : GLINT;
         NumNormals: integer;
         Faces: auint32;
         Colours: TAVector4f;
         Render: TRenderingMachine;
         Material: TMeshMaterial;
         MyMesh: Pointer;
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

constructor TDifferentMeshFaceTypePlugin.Create;
begin
   FPluginType := C_MPL_MESH;
   FaceType := GL_TRIANGLES;
   VerticesPerFace := 3;
   Initialize;
end;

procedure TDifferentMeshFaceTypePlugin.Initialize;
begin
   inherited Initialize;
   Material := TMeshMaterial.Create(nil);
   Render := TRenderingMachine.Create;
end;

procedure TDifferentMeshFaceTypePlugin.Clear;
begin
   Render.Free;
   SetLength(Colours,0);
   SetLength(Faces,0);
   Material.Free;
end;

procedure TDifferentMeshFaceTypePlugin.DoUpdate(_MeshAddress: Pointer);
begin
   MyMesh := _MeshAddress;
   MeshNormalsType := (PMesh(MyMesh))^.NormalsType;
   MeshVertices := PAVector3f(Addr((PMesh(MyMesh))^.Vertices));
   if MeshNormalsType = C_NORMALS_PER_VERTEX then
   begin
      MeshNormals := PAVector3f(Addr((PMesh(MyMesh))^.Normals));
   end
   else
   begin
      (PMesh(MyMesh))^.Geometry.GoToFirstElement;
      MeshNormals := PAVector3f(Addr(((PMesh(MyMesh))^.Geometry.Current^ as TMeshBRepGeometry).Normals));
   end;
   NumNormals := High(MeshNormals^)+1;
   Render.ForceRefresh;
end;

// Rendering related.
procedure TDifferentMeshFaceTypePlugin.DoRender;
begin
   // do nothing
   Render.StartRender;
   Material.Enable;
   Render.RenderWithFaceNormalsAndColours(MeshVertices^,MeshNormals^,Colours,Faces,FaceType,VerticesPerFace,NumNormals);
   Material.Disable;
   Render.FinishRender(SetVector(0,0,0));
end;

end.
