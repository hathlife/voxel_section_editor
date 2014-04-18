unit DifferentMeshFaceTypePlugin;

interface

uses MeshPluginBase, BasicMathsTypes, BasicDataTypes, GlConstants, BasicConstants,
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
         // Copy
         procedure Assign(const _Source: TMeshPluginBase); override;
   end;



implementation

uses Mesh, Math3d;

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

// Copy
procedure TDifferentMeshFaceTypePlugin.Assign(const _Source: TMeshPluginBase);
var
   i: integer;
begin
   if _Source.PluginType = FPluginType then
   begin
      MeshNormalsType := (_Source as TDifferentMeshFaceTypePlugin).MeshNormalsType;
      VerticesPerFace := (_Source as TDifferentMeshFaceTypePlugin).VerticesPerFace;
      FaceType := (_Source as TDifferentMeshFaceTypePlugin).FaceType;
      NumNormals := (_Source as TDifferentMeshFaceTypePlugin).NumNormals;
      SetLength(Faces, High((_Source as TDifferentMeshFaceTypePlugin).Faces) + 1);
      for i := Low(Faces) to High(Faces) do
      begin
         Faces[i] := (_Source as TDifferentMeshFaceTypePlugin).Faces[i];
      end;
      SetLength(Colours, High((_Source as TDifferentMeshFaceTypePlugin).Colours) + 1);
      for i := Low(Colours) to High(Colours) do
      begin
         Colours[i].X := (_Source as TDifferentMeshFaceTypePlugin).Colours[i].X;
         Colours[i].Y := (_Source as TDifferentMeshFaceTypePlugin).Colours[i].Y;
         Colours[i].Z := (_Source as TDifferentMeshFaceTypePlugin).Colours[i].Z;
         Colours[i].W := (_Source as TDifferentMeshFaceTypePlugin).Colours[i].W;
      end;
   end;
   inherited Assign(_Source);
end;


end.
