unit NeighborhoodDataPlugin;

interface

uses BasicDataTypes, MeshPluginBase, ClassNeighborDetector, Math3d, GLConstants;

type
   TNeighborhoodDataPlugin = class (TMeshPluginBase)
      public
         VertexNeighbors: TNeighborDetector;
         FaceNeighbors: TNeighborDetector;
         FaceFaceNeighbors: TNeighborDetector;
         UseQuadFaces: boolean;
         QuadFaces: auint32;
         QuadFaceNormals: TAVector3f;
         QuadFaceNeighbors: TNeighborDetector;
         VertexEquivalences: auint32;
         EquivalenceFaceNeighbors: TNeighborDetector;
         EquivalenceFaceFromVertexNeighbors: TNeighborDetector;
         UseEquivalenceFaces: boolean;
         InitialVertexCount: integer;
         // Constructors and Destructors
         constructor Create(const _Faces: auint32;_VerticesPerFace,_NumVertices: integer);
         destructor Destroy; override;
         // Updates
         procedure UpdateQuadsToTriangles(const _Faces: auint32; const _Vertices: TAVector3f; _NumVertices,_VerticesPerFace: integer);
         procedure DeactivateQuadFaces;
         procedure UpdateEquivalences(const _VertsLocation: aint32);
         procedure ActivateEquivalenceFaces(const _Faces: auint32; _NumVertices,_VerticesPerFace: integer);
         // Gets
         function GetEquivalentVertex(_VertexID: integer): integer;
   end;


implementation

   // Constructors and Destructors
   constructor TNeighborhoodDataPlugin.Create(const _Faces: AUInt32; _VerticesPerFace: Integer; _NumVertices: Integer);
   var
      i : integer;
   begin
      FPluginType := C_MPL_NEIGHBOOR;
      AllowRender := false;
      AllowUpdate := false;
      VertexNeighbors := TNeighborDetector.Create;
      VertexNeighbors.BuildUpData(_Faces,_VerticesPerFace,_NumVertices);
      FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      FaceNeighbors.VertexVertexNeighbors := PNeighborDetector(Addr(VertexNeighbors));
      FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,_NumVertices);
      FaceFaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
      FaceFaceNeighbors.VertexVertexNeighbors := PNeighborDetector(Addr(VertexNeighbors));
      FaceFaceNeighbors.VertexFaceNeighbors := PNeighborDetector(Addr(FaceNeighbors));
      FaceFaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,_NumVertices);
      QuadFaceNeighbors := TNeighborDetector.Create;
      UseQuadFaces := false;
      SetLength(QuadFaces,0);
      SetLength(QuadFaceNormals,0);
      SetLength(VertexEquivalences,_NumVertices);
      UseEquivalenceFaces := false;
      EquivalenceFaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_EDGE);
      EquivalenceFaceFromVertexNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_FACE_FACE_FROM_VERTEX);
      InitialVertexCount := _NumVertices;
      for i := Low(VertexEquivalences) to High(VertexEquivalences) do
      begin
         VertexEquivalences[i] := i;
      end;
   end;

   destructor TNeighborhoodDataPlugin.Destroy;
   begin
      VertexNeighbors.Free;
      FaceNeighbors.Free;
      FaceFaceNeighbors.Free;
//      QuadFaceNeighbors.Free;
      EquivalenceFaceNeighbors.Free;
      SetLength(QuadFaces,0);
      SetLength(QuadFaceNormals,0);
      SetLength(VertexEquivalences,0);
      inherited Destroy;
   end;

   // Updates
   procedure TNeighborhoodDataPlugin.UpdateQuadsToTriangles(const _Faces: auint32; const _Vertices: TAVector3f; _NumVertices,_VerticesPerFace: integer);
   var
      vf,vq,fq,incf,incq: integer;
      V1,V2: TVector3f;
   begin
      // Build QuadFaces from _Faces.
      SetLength(QuadFaces,2*(High(_Faces)+1));
      vf := 0;
      vq := 0;
      incf := 2 * _VerticesPerFace;
      incq := 2 * incf;
      while vf < High(_Faces) do
      begin
         // 0 -> 1 -> 2
         QuadFaces[vq] := _Faces[vf];
         QuadFaces[vq+1] := _Faces[vf+1];
         QuadFaces[vq+2] := _Faces[vf+2];
         // 2 -> 3 -> 0
         QuadFaces[vq+3] := _Faces[vf+3];
         QuadFaces[vq+4] := _Faces[vf+4];
         QuadFaces[vq+5] := _Faces[vf+5];
         // 1 -> 2 -> 3
         QuadFaces[vq+6] := _Faces[vf+1];
         QuadFaces[vq+7] := _Faces[vf+2];
         QuadFaces[vq+8] := _Faces[vf+3];
         // 1 -> 3 -> 0
         QuadFaces[vq+9] := _Faces[vf+1];
         QuadFaces[vq+10] := _Faces[vf+3];
         QuadFaces[vq+11] := _Faces[vf];

         inc(vf,incf);
         inc(vq,incq);
      end;
      // Now we detect the normal vectors from all these faces.
      SetLength(QuadFaceNormals,(High(QuadFaces)+1) div _VerticesPerFace);
      vq := 0;
      fq := 0;
      while vq < High(QuadFaces) do
      begin
         V1.X := _Vertices[QuadFaces[vq+2]].X - _Vertices[QuadFaces[vq+1]].X;
         V1.Y := _Vertices[QuadFaces[vq+2]].Y - _Vertices[QuadFaces[vq+1]].Y;
         V1.Z := _Vertices[QuadFaces[vq+2]].Z - _Vertices[QuadFaces[vq+1]].Z;

         V2.X := _Vertices[QuadFaces[vq]].X - _Vertices[QuadFaces[vq+1]].X;
         V2.Y := _Vertices[QuadFaces[vq]].Y - _Vertices[QuadFaces[vq+1]].Y;
         V2.Z := _Vertices[QuadFaces[vq]].Z - _Vertices[QuadFaces[vq+1]].Z;

         QuadFaceNormals[fq] := CrossProduct(V1,V2);

         inc(vq,_VerticesPerFace);
         inc(fq);
      end;

      // Now we setup QuadFaceNeighbors
      QuadFaceNeighbors.SetType(C_NEIGHBTYPE_VERTEX_FACE);
      QuadFaceNeighbors.VertexVertexNeighbors := FaceNeighbors.VertexVertexNeighbors;
      QuadFaceNeighbors.BuildUpData(QuadFaces,_VerticesPerFace,_NumVertices);

      UseQuadFaces := true;
   end;

   procedure TNeighborhoodDataPlugin.DeactivateQuadFaces;
   begin
//      UseQuadFaces := false;
//      QuadFaceNeighbors.Free;
//      QuadFaceNeighbors := TNeighborDetector.Create;
//      SetLength(QuadFaces,0);
//      SetLength(QuadFaceNormals,0);
   end;

   procedure TNeighborhoodDataPlugin.UpdateEquivalences(const _VertsLocation: aint32);
   var
      v : integer;
   begin
      SetLength(VertexEquivalences,High(_VertsLocation)+1);
      for v  := Low(_VertsLocation) to High(_VertsLocation) do
      begin
         if _VertsLocation[v] > v then
         begin
            VertexEquivalences[_VertsLocation[v]] := VertexEquivalences[v];
            VertexEquivalences[v] := _VertsLocation[v];
         end;
      end;
   end;

   procedure TNeighborhoodDataPlugin.ActivateEquivalenceFaces(const _Faces: auint32; _NumVertices,_VerticesPerFace: integer);
   var
      EFaces : auint32;
      i : integer;
   begin
      SetLength(EFaces,High(_Faces)+1);
      for i := Low(EFaces) to High(EFaces) do
      begin
         if i < VertexEquivalences[i] then
         begin
            EFaces[i] := _Faces[VertexEquivalences[i]];
         end
         else
         begin
            EFaces[i] := _Faces[i];
         end;
      end;
      EquivalenceFaceNeighbors.VertexVertexNeighbors := FaceNeighbors.VertexVertexNeighbors;
      EquivalenceFaceNeighbors.BuildUpData(EFaces,_VerticesPerFace,_NumVertices);
      EquivalenceFaceFromVertexNeighbors.VertexVertexNeighbors := FaceNeighbors.VertexVertexNeighbors;
      EquivalenceFaceFromVertexNeighbors.BuildUpData(EFaces,_VerticesPerFace,_NumVertices);
      UseEquivalenceFaces := true;
   end;

   // Gets
   function TNeighborhoodDataPlugin.GetEquivalentVertex(_VertexID: integer): integer;
   begin
      Result := _VertexID;
      while Result > InitialVertexCount do
      begin
         Result := VertexEquivalences[Result];
      end;
   end;

end.
