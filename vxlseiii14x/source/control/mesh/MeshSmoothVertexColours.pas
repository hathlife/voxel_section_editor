unit MeshSmoothVertexColours;

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector,
   MeshColourCalculator, LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothVertexColours = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothOperation(var _Colours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _NumFaces,_VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; var _Calculator: TMeshColourCalculator);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
      public
         DistanceFunction: TDistanceFunc;

         constructor Create(var _LOD: TLOD);
   end;

implementation

uses MeshPluginBase, GLConstants, NeighborhoodDataPlugin, MeshBRepGeometry,
   DistanceFormulas;

constructor TMeshSmoothVertexColours.Create(var _LOD: TLOD);
begin
   inherited Create(_LOD);
   DistanceFunction := GetLinearDistance;
end;

procedure TMeshSmoothVertexColours.DoMeshProcessing(var _Mesh: TMesh);
var
   Calculator : TMeshColourCalculator;
   NeighborhoodPlugin: PMeshPluginBase;
   NeighborDetector: TNeighborDetector;
   VertexEquivalences: auint32;
   NumVertices,MyNumFaces: integer;
   MyFaces: auint32;
   MyFaceColours: TAVector4f;
begin
   Calculator := TMeshColourCalculator.Create;
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   _Mesh.Geometry.GoToFirstElement;
   if NeighborhoodPlugin <> nil then
   begin
      if TNeighborhoodDataPlugin(NeighborhoodPlugin^).UseQuadFaces then
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceNeighbors;
         MyFaces := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaces;
         MyNumFaces := (High(MyFaces)+1) div (_Mesh.Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
         MyFaceColours := TNeighborhoodDataPlugin(NeighborhoodPlugin^).QuadFaceColours;
      end
      else
      begin
         NeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
         _Mesh.Geometry.GoToFirstElement;
         MyFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces;
         MyNumFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).NumFaces;
         MyFaceColours := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Colours;
      end;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
   end
   else
   begin
      NeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      NeighborDetector.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      VertexEquivalences := nil;
      NumVertices := High(_Mesh.Vertices)+1;
      MyFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces;
      MyNumFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).NumFaces;
      MyFaceColours := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Colours;
   end;
   MeshSmoothOperation(_Mesh.Colours,_Mesh.Vertices,NumVertices,MyFaces,MyNumFaces,(_Mesh.Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace,NeighborDetector,VertexEquivalences,Calculator);
   if NeighborhoodPlugin = nil then
   begin
      NeighborDetector.Free;
   end;
   Calculator.Free;
   _Mesh.ForceRefresh;
end;

procedure TMeshSmoothVertexColours.MeshSmoothOperation(var _Colours: TAVector4f; const _Vertices: TAVector3f; _NumVertices: integer; const _Faces: auint32; _NumFaces,_VerticesPerFace: integer; const _NeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32; var _Calculator: TMeshColourCalculator);
var
   OriginalColours,FaceColours : TAVector4f;
begin
   SetLength(OriginalColours,High(_Colours)+1);
   SetLength(FaceColours,_NumFaces);
  // Reset values.
   BackupVector4f(_Colours,OriginalColours);
   _Calculator.GetFaceColoursFromVertexes(OriginalColours,FaceColours,_Faces,_VerticesPerFace);
   _Calculator.GetVertexColoursFromFaces(_Colours,FaceColours,_Vertices,_NumVertices,_Faces,_VerticesPerFace,_NeighborDetector,_VertexEquivalences,DistanceFunction);
   FilterAndFixColours(_Colours);
   // Free memory
   SetLength(FaceColours,0);
   SetLength(OriginalColours,0);
end;


end.
