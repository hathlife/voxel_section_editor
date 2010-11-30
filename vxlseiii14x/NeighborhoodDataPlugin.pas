unit NeighborhoodDataPlugin;

interface

uses BasicDataTypes, MeshPluginBase, ClassNeighborDetector;

type
   TNeighborhoodDataPlugin = class (TMeshPluginBase)
      public
         VertexNeighbors: TNeighborDetector;
         FaceNeighbors: TNeighborDetector;
         QuadFaces: auint32;
         QuadFaceNormals: TAVector3f;
         QuadFaceNeighbors: TNeighborDetector;
         VertexEquivalences: auint32;
         constructor Create(const _Faces: auint32;_VerticesPerFace,_NumVertices: integer);
         destructor Destroy; override;
   end;


implementation

   constructor TNeighborhoodDataPlugin.Create(const _Faces: AUInt32; _VerticesPerFace: Integer; _NumVertices: Integer);
   var
      i : integer;
   begin
      VertexNeighbors := TNeighborDetector.Create;
      VertexNeighbors.BuildUpData(_Faces,_VerticesPerFace,_NumVertices);
      FaceNeighbors := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      FaceNeighbors.VertexVertexNeighbors := PNeighborDetector(Addr(VertexNeighbors));
      FaceNeighbors.BuildUpData(_Faces,_VerticesPerFace,_NumVertices);
      QuadFaceNeighbors := TNeighborDetector.Create;
      SetLength(QuadFaces,0);
      SetLength(QuadFaceNormals,0);
      SetLength(VertexEquivalences,_NumVertices);
      for i := Low(VertexEquivalences) to High(VertexEquivalences) do
      begin
         VertexEquivalences[i] := i;
      end;
   end;

   destructor TNeighborhoodDataPlugin.Destroy;
   begin
      VertexNeighbors.Free;
      FaceNeighbors.Free;
      inherited Destroy;
   end;

end.
