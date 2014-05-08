unit MeshSmoothMasters;

// This is the third type of mesh smooth made for this program made for my Master
// Dissertation. It works with manifold meshes where all vertexes must be real
// vertexes (and not part of edges or faces). If these conditions are met, the
// results are interesting using a single interaction, regardless of how irregular
// is the mesh. However, the execution time is slower than other methods.

interface

uses MeshProcessingBase, Mesh, BasicMathsTypes, BasicDataTypes, NeighborDetector,
      LOD;

{$INCLUDE source/Global_Conditionals.inc}

type
   TMeshSmoothMasters = class (TMeshProcessingBase)
      protected
         procedure MeshSmoothOperation(var _Vertices,_VertexNormals,_FaceNormals: TAVector3f; const _Faces:auint32; _NumVertices,_VerticesPerFace: integer; const _VertexNeighborDetector,_FaceNeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32);
         procedure DoMeshProcessing(var _Mesh: TMesh); override;
      public
         DistanceFunction: TDistanceFunc;

         constructor Create(var _LOD: TLOD); override;
   end;

implementation

uses MeshPluginBase, MeshBRepGeometry, NeighborhoodDataPlugin, GLConstants, Math,
   VertexTransformationUtils, math3d, SysUtils, GlobalVars, DistanceFormulas,
   MeshNormalVectorCalculator;

constructor TMeshSmoothMasters.Create(var _LOD: TLOD);
begin
   inherited Create(_LOD);
   DistanceFunction := GetLinearDistance;
end;

procedure TMeshSmoothMasters.DoMeshProcessing(var _Mesh: TMesh);
var
   VertexNeighborDetector,FaceNeighborDetector : TNeighborDetector;
   NeighborhoodPlugin : PMeshPluginBase;
   NumVertices: integer;
   VertexEquivalences: auint32;
   MyFaces: auint32;
   MyFaceNormals: TAVector3f;
   MyVerticesPerFace: integer;
   Calculator: TMeshNormalVectorCalculator;
begin
   _Mesh.Geometry.GoToFirstElement;
   NeighborhoodPlugin := _Mesh.GetPlugin(C_MPL_NEIGHBOOR);
   if NeighborhoodPlugin <> nil then
   begin
      VertexNeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexNeighbors;
      FaceNeighborDetector := TNeighborhoodDataPlugin(NeighborhoodPlugin^).FaceNeighbors;
      NumVertices := TNeighborhoodDataPlugin(NeighborhoodPlugin^).InitialVertexCount;
      VertexEquivalences := TNeighborhoodDataPlugin(NeighborhoodPlugin^).VertexEquivalences;
   end
   else
   begin
      VertexNeighborDetector := TNeighborDetector.Create;
      VertexNeighborDetector.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      _Mesh.Geometry.GoToFirstElement;
      FaceNeighborDetector := TNeighborDetector.Create(C_NEIGHBTYPE_VERTEX_FACE);
      FaceNeighborDetector.BuildUpData(_Mesh.Geometry,High(_Mesh.Vertices)+1);
      NumVertices := High(_Mesh.Vertices)+1;
      VertexEquivalences := nil;
   end;
   MyFaces := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Faces;
   MyFaceNormals := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).Normals;
   MyVerticesPerFace := (_Mesh.Geometry.Current^ as TMeshBRepGeometry).VerticesPerFace;
   if High(_Mesh.Normals) <= 0 then
   begin
      Calculator := TMeshNormalVectorCalculator.Create;
      Calculator.FindMeshVertexNormals(_Mesh);
      Calculator.Free;
   end;
   MeshSmoothOperation(_Mesh.Vertices,_Mesh.Normals,MyFaceNormals,MyFaces,NumVertices,MyVerticesPerFace,VertexNeighborDetector,FaceNeighborDetector,VertexEquivalences);
   // Free memory
   if NeighborhoodPlugin = nil then
   begin
      VertexNeighborDetector.Free;
      FaceNeighborDetector.Free;
   end;
   _Mesh.ForceRefresh;
end;

procedure TMeshSmoothMasters.MeshSmoothOperation(var _Vertices,_VertexNormals,_FaceNormals: TAVector3f; const _Faces:auint32; _NumVertices,_VerticesPerFace: integer; const _VertexNeighborDetector,_FaceNeighborDetector: TNeighborDetector; const _VertexEquivalences: auint32);
const
   C_2Pi = Pi * 2;
var
   HitCounter,Weight: single;
   OriginalVertexes : TAVector3f;
   v,v1,i,mini,maxi : integer;
   nv : array[0..1] of integer;
   IsConcave,Found: boolean;
   CossineAngle: single;
   Direction,LaplacianDirection: TVector3f;
   CurrentScale,MaxScale,Frequency: single;
   Util : TVertexTransformationUtils;
begin
   Util := TVertexTransformationUtils.Create;
   SetLength(OriginalVertexes,High(_Vertices)+1);
   BackupVector3f(_Vertices,OriginalVertexes);
   // Sum up vertices with its neighbours, using the desired distance formula.
   for v := Low(_Vertices) to (_NumVertices-1) do
   begin
      HitCounter := 0;
      MaxScale := 999999;
      IsConcave := false;
      v1 := _VertexNeighborDetector.GetNeighborFromID(v);
      while v1 <> -1 do
      begin
         // Check if the vertex is concave or conves to determine the direction
         // of the final vertex translation.
         Direction := SubtractVector(OriginalVertexes[v1],OriginalVertexes[v]);
         Normalize(Direction);
         CossineAngle := DotProduct(_VertexNormals[v],Direction);
         IsConcave := IsConcave or (CossineAngle < 0);
         // Check the maximum possible scale of the final vertex translation
         Direction := SubtractVector(OriginalVertexes[v],OriginalVertexes[v1]);
         Normalize(Direction);
         CurrentScale := Abs(DotProduct(Direction,_VertexNormals[v]));
//         if (CurrentScale <> 0) and (CurrentScale < MaxScale) then
         if (CurrentScale < MaxScale) then
         begin
            MaxScale := CurrentScale;
         end;
         {$ifdef SMOOTH_TEST}
         {
         if CurrentScale = 0 then
         begin
            GlobalVars.SmoothFile.Add('v1 = ' + IntToStr(v1) +  ' = (' + FloatToStr(OriginalVertexes[v1].X) + ', ' + FloatToStr(OriginalVertexes[v1].Y) + ', ' + FloatToStr(OriginalVertexes[v1].Z) + ') forces MaxScale 0 with v = ' + IntToStr(v));
         end;
         }
         {$endif}
         v1 := _VertexNeighborDetector.GetNextNeighbor;
      end;
      if MaxScale = 999999 then
         MaxScale := 0;
      if IsConcave then
      begin
         LaplacianDirection := ScaleVector(_VertexNormals[v],-1);
         {$ifdef SMOOTH_TEST}
         GlobalVars.SmoothFile.Add('vertex ' + IntToStr(v) +  ' is concave.');
         {$endif}
      end
      else
      begin
         LaplacianDirection := SetVector(_VertexNormals[v]);
         {$ifdef SMOOTH_TEST}
         GlobalVars.SmoothFile.Add('vertex ' + IntToStr(v) +  ' is convex.');
         {$endif}
      end;
      {$ifdef SMOOTH_TEST}
      GlobalVars.SmoothFile.Add('v = ' + IntToStr(v) +  ' = (' + FloatToStr(OriginalVertexes[v].X) + ', ' + FloatToStr(OriginalVertexes[v].Y) + ', ' + FloatToStr(OriginalVertexes[v].Z) + ') , MaxScale: ' + FloatToStr(MaxScale));
      {$endif}

      // Finally, we do an average for all vertices.
      Frequency := 0;
      v1 := _FaceNeighborDetector.GetNeighborFromID(v); // face neighbour of the vertex v
      if MaxScale > 0 then
      begin
         while v1 <> -1 do
         begin
            // Obtain both edges of the face that has v
            mini := v1 * _VerticesPerFace;
            maxi := mini + _VerticesPerFace - 1;
            Found := false;
            // Find v in the face.
            i := 0;
            while (i < _VerticesPerFace) and (not Found) do
            begin
               if _Faces[mini + i] = v then
               begin
                  Found := true;
               end
               else
               begin
                  inc(i);
               end;
            end;
            // Now we obtain both edges (actually vertexes that have edges with v)
            if i = 0 then
            begin
               nv[0] := _Faces[maxi];
               nv[1] := _Faces[mini + 1];
            end
            else if i = (_VerticesPerFace-1) then
            begin
               nv[0] := _Faces[maxi - 1];
               nv[1] := _Faces[mini];
            end
            else
            begin
               nv[0] := _Faces[mini + i - 1];
               nv[1] := _Faces[mini + i + 1];
            end;
            // Obtain the percentage of angle from the triangle at tangent space level
            Weight := Util.GetArcCosineFromAngleOnTangentSpace(OriginalVertexes[v],OriginalVertexes[nv[0]],OriginalVertexes[nv[1]],_VertexNormals[v]) / C_2Pi;
            HitCounter := HitCounter + Weight;
            // Obtain dot product of face normal and vertex normal
            Frequency := Frequency + ((1 - abs(DotProduct(_VertexNormals[v],_FaceNormals[v1]))) * Weight);

            v1 := _FaceNeighborDetector.GetNextNeighbor;
         end;
         {$ifdef SMOOTH_TEST}
         GlobalVars.SmoothFile.Add('v = ' + IntToStr(v) +  ', Weight Value: ' + FloatToStr(Weight) + ', MaxScale: ' + FloatToStr(MaxScale) + ', Frequency: ' +FloatToStr(Frequency) + ') with ' + FloatToStr(HitCounter*100) + ' % of the neighbourhood. Expected frequency: (' + FloatToStr(Frequency / HitCounter) + ')');
         {$endif}
      end;
      if HitCounter > 0 then
      begin
         CurrentScale := MaxScale * DistanceFunction(Frequency / HitCounter);
         _Vertices[v].X := OriginalVertexes[v].X + CurrentScale * LaplacianDirection.X;
         _Vertices[v].Y := OriginalVertexes[v].Y + CurrentScale * LaplacianDirection.Y;
         _Vertices[v].Z := OriginalVertexes[v].Z + CurrentScale * LaplacianDirection.Z;
         {$ifdef SMOOTH_TEST}
         GlobalVars.SmoothFile.Add('New position for vertex ' + IntToStr(v) +  ' = (' + FloatToStr(_Vertices[v].X) + ', ' + FloatToStr(_Vertices[v].Y) + ', ' + FloatToStr(_Vertices[v].Z) + ') , Intensity: ' + FloatToStr(CurrentScale));
         {$endif}
      end
      else
      begin
         _Vertices[v].X := OriginalVertexes[v].X;
         _Vertices[v].Y := OriginalVertexes[v].Y;
         _Vertices[v].Z := OriginalVertexes[v].Z;
         {$ifdef SMOOTH_TEST}
         GlobalVars.SmoothFile.Add('Vertex ' + IntToStr(v) +  ' = (' + FloatToStr(_Vertices[v].X) + ', ' + FloatToStr(_Vertices[v].Y) + ', ' + FloatToStr(_Vertices[v].Z) + ') was not moved.');
         {$endif}
      end;
   end;
   v := _NumVertices;
   while v <= High(_Vertices) do
   begin
      v1 := GetEquivalentVertex(v,_NumVertices,_VertexEquivalences);
      _Vertices[v].X := _Vertices[v1].X;
      _Vertices[v].Y := _Vertices[v1].Y;
      _Vertices[v].Z := _Vertices[v1].Z;
      inc(v);
   end;
   // Free memory
   SetLength(OriginalVertexes,0);
   Util.Free;
end;

end.
