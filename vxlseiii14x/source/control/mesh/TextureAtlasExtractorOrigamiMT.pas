unit TextureAtlasExtractorOrigamiMT;

// Multi-thread attempt... that failed. It was slower than the original Texture
// Atlas Extractor due to the massive amount of threads created (8 per face).

interface

uses BasicMathsTypes, BasicDataTypes, TextureAtlasExtractorOrigami, MeshPluginBase,
   NeighborDetector, Math, IntegerList, VertexTransformationUtils, Math3d,
   NeighborhoodDataPlugin, SysUtils, Mesh, TextureAtlasExtractorBase;

{$INCLUDE source/Global_Conditionals.inc}

type
   CTextureAtlasExtractorOrigamiMT = class (CTextureAtlasExtractorOrigami)
      protected
         // Aux functions
         function IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean; override;
   end;


implementation

uses GlobalVars, TextureGeneratorBase, DiffuseTextureGenerator, MeshBRepGeometry,
   GLConstants, ColisionCheck;

function CTextureAtlasExtractorOrigamiMT.IsValidUVPoint(const _Vertices: TAVector3f; const _Faces : auint32; var _TexCoords: TAVector2f; _Target,_Edge0,_Edge1,_OriginVert: integer; var _CheckFace: abool; var _UVPosition: TVector2f; _CurrentFace, _PreviousFace, _VerticesPerFace: integer): boolean;
var
   EdgeSizeInMesh,EdgeSizeInUV,Scale,SinProjectionSizeInMesh,SinProjectionSizeInUV,ProjectionSizeInMesh,ProjectionSizeInUV: single;
   EdgeDirectionInUV,PositionOfTargetAtEdgeInUV,SinDirectionInUV: TVector2f;
   EdgeDirectionInMesh,PositionOfTargetAtEdgeInMesh: TVector3f;
   SourceSide: single;
   i,v: integer;
   ColisionUtil : CColisionCheck;
begin
   ColisionUtil := CColisionCheck.Create;
   // Get edge size in mesh
   EdgeSizeInMesh := VectorDistance(_Vertices[_Edge0],_Vertices[_Edge1]);
   if EdgeSizeInMesh > 0 then
   begin
      // Get the direction of the edge (Edge0 to Edge1) in Mesh and UV space
      EdgeDirectionInMesh := SubtractVector(_Vertices[_Edge1],_Vertices[_Edge0]);
      EdgeDirectionInUV := SubtractVector(_TexCoords[_Edge1],_TexCoords[_Edge0]);
      // Get edge size in UV space.
      EdgeSizeInUV := Sqrt((EdgeDirectionInUV.U * EdgeDirectionInUV.U) + (EdgeDirectionInUV.V * EdgeDirectionInUV.V));
      // Directions must be normalized.
      Normalize(EdgeDirectionInMesh);
      Normalize(EdgeDirectionInUV);
      Scale := EdgeSizeInUV / EdgeSizeInMesh;
      // Get the size of projection of (Vertex - Edge0) at the Edge, in mesh
      ProjectionSizeInMesh := DotProduct(SubtractVector(_Vertices[_Target],_Vertices[_Edge0]),EdgeDirectionInMesh);
      // Obtain the position of this projection at the edge, in mesh
      PositionOfTargetatEdgeInMesh := AddVector(_Vertices[_Edge0],ScaleVector(EdgeDirectionInMesh,ProjectionSizeInMesh));
      // Now we can use the position obtained previously to find out the
      // distance between that and the _Target in mesh.
      SinProjectionSizeInMesh := VectorDistance(_Vertices[_Target],PositionOfTargetatEdgeInMesh);
      // Rotate the edge in 90' in UV space.
      SinDirectionInUV := Get90RotDirectionFromDirection(EdgeDirectionInUV);
      // We need to make sure that _Target and _OriginVert are at opposite sides
      // the universe, if it is divided by the Edge0 to Edge1.
      SourceSide := Get2DOuterProduct(_TexCoords[_OriginVert],_TexCoords[_Edge0],_TexCoords[_Edge1]);
      if SourceSide > 0 then
      begin
         SinDirectionInUV := ScaleVector(SinDirectionInUV,-1);
      end;
      // Now we use the same logic applied in mesh to find out the final position
      // in UV space
      ProjectionSizeInUV := ProjectionSizeInMesh * Scale;
      PositionOfTargetatEdgeInUV := AddVector(_TexCoords[_Edge0],ScaleVector(EdgeDirectionInUV,ProjectionSizeInUV));
      SinProjectionSizeInUV := SinProjectionSizeInMesh * Scale;
      // Write the UV Position
      _UVPosition := AddVector(PositionOfTargetatEdgeInUV,ScaleVector(SinDirectionInUV,SinProjectionSizeInUV));

      _CheckFace[_PreviousFace] := false;
      Result := not ColisionUtil.Is2DTriangleColidingWithMeshMT(_UVPosition,_TexCoords[_Edge0],_TexCoords[_Edge1],_TexCoords,_Faces,_CheckFace);
      _CheckFace[_PreviousFace] := true;
   end;
   ColisionUtil.Free;
end;

end.

