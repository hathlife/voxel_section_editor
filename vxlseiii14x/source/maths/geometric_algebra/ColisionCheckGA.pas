unit ColisionCheckGA;

interface

uses GeometricAlgebra, Multivector, ColisionCheckBase;

{$INCLUDE source/Global_Conditionals.inc}

type
   CColisionCheckGA = class (CColisionCheckBase)
      private
         Temp: TMultiVector;
         function IsVertexInsideOrOutside2DEdge(var _PGA: TGeometricAlgebra; const _LS, _V: TMultiVector): byte;
      public
         constructor Create(var _PGA: TGeometricAlgebra);
         destructor Destroy; override;
         function Are2DTrianglesColiding(var _PGA: TGeometricAlgebra; const _TLS1, _TLS2, _TLS3, _TV1, _TV2, _TV3: TMultiVector): boolean;
   end;

implementation

uses GlobalVars;

constructor CColisionCheckGA.Create(var _PGA: TGeometricAlgebra);
begin
   Temp := TMultiVector.Create(_PGA.Dimension);
end;

destructor CColisionCheckGA.Destroy;
begin
   Temp.Free;
   inherited Destroy;
end;

function CColisionCheckGA.IsVertexInsideOrOutside2DEdge(var _PGA: TGeometricAlgebra; const _LS, _V: TMultiVector): byte;
begin
   _PGA.OuterProduct(Temp,_LS,_V);
   if Epsilon(Temp.UnsafeData[11]) <= 0 then
   begin
      Result := 1;
   end
   else
   begin
      Result := 0;
   end;
end;

// _TLS1,2,3 are line segments of one of the triangles. _TV1,2,3 are the vertexes (flats) from the other triangle.
// It requires homogeneous/projective model from the geometric algebra.
function CColisionCheckGA.Are2DTrianglesColiding(var _PGA: TGeometricAlgebra; const _TLS1, _TLS2, _TLS3, _TV1, _TV2, _TV3: TMultiVector): boolean;
var
   VertexConfig1,VertexConfig2,VertexConfig3: byte;
   SegConfig1,SegConfig2,SegConfig3: byte;
begin
   Result := true; // assume true for optimization
   {$ifdef ORIGAMI_TEST}
   {$ifdef ORIGAMI_COLISION_TEST}
   GlobalVars.OrigamiFile.Add('Colision detection starts here.');
   _TLS1.Debug(GlobalVars.OrigamiFile,'Triangle A Line Segment 1');
   _TLS2.Debug(GlobalVars.OrigamiFile,'Triangle A Line Segment 2');
   _TLS3.Debug(GlobalVars.OrigamiFile,'Triangle A Line Segment 3');
   _TV1.Debug(GlobalVars.OrigamiFile,'Triangle B Vertex 1');
   _TV2.Debug(GlobalVars.OrigamiFile,'Triangle B Vertex 2');
   _TV3.Debug(GlobalVars.OrigamiFile,'Triangle B Vertex 3');
   {$endif}
   {$endif}

   // Collect vertex configurations. 1 is outside and 0 is inside.
   // Vertex 1
   VertexConfig1 := IsVertexInsideOrOutside2DEdge(_PGA,_TLS1, _TV1) or (2 * IsVertexInsideOrOutside2DEdge(_PGA,_TLS2, _TV1)) or (4 * IsVertexInsideOrOutside2DEdge(_PGA,_TLS3, _TV1));
   if VertexConfig1 = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Vertex 1 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the vertex is inside the triangle.
   end;
   // Vertex 2
   VertexConfig2 := IsVertexInsideOrOutside2DEdge(_PGA,_TLS1, _TV2) or (2 * IsVertexInsideOrOutside2DEdge(_PGA,_TLS2, _TV2)) or (4 * IsVertexInsideOrOutside2DEdge(_PGA,_TLS3, _TV2));
   if VertexConfig2 = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Vertex 2 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the vertex is inside the triangle.
   end;
   // Vertex 3
   VertexConfig3 := IsVertexInsideOrOutside2DEdge(_PGA,_TLS1, _TV3) or (2 * IsVertexInsideOrOutside2DEdge(_PGA,_TLS2, _TV3)) or (4 * IsVertexInsideOrOutside2DEdge(_PGA,_TLS3, _TV3));
   if VertexConfig3 = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Vertex 3 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the vertex is inside the triangle.
   end;
   // Now let's check the line segments
   SegConfig1 := VertexConfig1 xor (VertexConfig2 and VertexConfig1);
   if SegConfig1 = VertexConfig1 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Segment 12 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the line segment crosses the triangle.
   end;
   SegConfig2 := VertexConfig2 xor (VertexConfig3 and VertexConfig2);
   if SegConfig2 = VertexConfig2 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Segment 23 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the line segment crosses the triangle.
   end;
   SegConfig3 := VertexConfig3 xor (VertexConfig1 and VertexConfig3);
   if SegConfig3 = VertexConfig3 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Segment 31 is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the line segment crosses the triangle.
   end;
   // Now let's check the triangle, if it contains the other or not.
   if (VertexConfig1 and VertexConfig2 and VertexConfig3) = 0 then
   begin
      {$ifdef ORIGAMI_TEST}
      {$ifdef ORIGAMI_COLISION_TEST}
      GlobalVars.OrigamiFile.Add('Triangle is inside the Triangle');
      {$endif}
      {$endif}
      exit; // return true, the triangle contains the other triangle.
   end;
   Result := false; // return false. There is no colision between the two triangles.
end;

end.
