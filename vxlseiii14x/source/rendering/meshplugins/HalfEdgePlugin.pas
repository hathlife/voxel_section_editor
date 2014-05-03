unit HalfEdgePlugin;

interface

// This plugin provides basic topological information for meshes, completing our
// half edge information with the Opposites array, since the rest is described
// implicity in the Faces array.

uses BasicMathsTypes, BasicDataTypes, MeshPluginBase, Math3d, GlConstants,
   NeighborDetector;

type
   THalfEdgePlugin = class (TMeshPluginBase)
      public
         Opposites : aint32;
         ID: integer;
         // Constructors and destructors
         constructor Create(_ID: integer; const _Vertices: TAVector3f; const _Faces: auint32; _VerticesPerFace: integer); overload;
         constructor Create(const _Source: THalfEdgePlugin); overload;
         destructor Destroy; override;
         // Copy
         procedure Assign(const _Source: TMeshPluginBase); override;
   end;

implementation

// Constructors and destructors

// Automatic Tangent Vector generation, adapted from http://www.terathon.com/code/tangent.html
constructor THalfEdgePlugin.Create(_ID: integer; const _Vertices: TAVector3f; const _Faces: auint32; _VerticesPerFace: integer);
var
   n,nBase,v,i,iNext,vNext: integer;
   Neighbors, NeighborEdge: aint32;
   NumVertices: integer;
begin
   // Basic Plugin Setup
   FPluginType := C_MPL_HALFEDGE;
   AllowRender := false;
   AllowUpdate := false;
   ID := _ID;

   // Reset Opposites.
   SetLength(Opposites, High(_Faces) + 1);
   for i := Low(Opposites) to High(Opposites) do
   begin
      Opposites[i] := -1;
   end;

   // Let's build the neighborhood data for this.
   NumVertices := High(_Vertices) + 1;
   SetLength(Neighbors, NumVertices * 15);
   SetLength(NeighborEdge, High(Neighbors)+1);
   for i := Low(Neighbors) to High(Neighbors) do
   begin
      Neighbors[i] := -1;
      NeighborEdge[i] := -1;
   end;

   // Populate the Neighbors and Edges.
   v := Low(_Faces);
   while v <= High(_Faces) do
   begin
      i := 0;
      while i < _VerticesPerFace do
      begin
         iNext := (i + 1) mod _VerticesPerFace;
         n := 0;
         nBase := _Faces[v + i] * 15;
         while Neighbors[nBase + n] <> -1 do
         begin
            inc(n);
         end;
         Neighbors[nBase + n] := _Faces[v + iNext];
         NeighborEdge[nBase + n] := v + i;
         inc(i);
      end;
      inc(v, _VerticesPerFace);
   end;

   // Now we'll use this data to populate Opposites.
   for v := Low(_Vertices) to High(_Vertices) do
   begin
      nBase := v * 15;
      n := 0;
      while Neighbors[nBase + n] <> -1 do
      begin
         if Opposites[NeighborEdge[nBase + n]] = -1 then
         begin
            i := Neighbors[nBase + n] * 15;
            while Neighbors[i] <> v do
            begin
               inc(i);
            end;
            Opposites[NeighborEdge[nBase + n]] := NeighborEdge[i];
            Opposites[NeighborEdge[i]] := NeighborEdge[nBase + n];
         end;
         inc(n);
      end;
   end;

   // Free Memory
   SetLength(Neighbors, 0);
   SetLength(NeighborEdge, 0);
end;

constructor THalfEdgePlugin.Create(const _Source: THalfEdgePlugin);
begin
   FPluginType := C_MPL_HALFEDGE;
   Assign(_Source);
end;


destructor THalfEdgePlugin.Destroy;
begin
   SetLength(Opposites,0);
   inherited Destroy;
end;

// Copy
procedure THalfEdgePlugin.Assign(const _Source: TMeshPluginBase);
var
   i: integer;
begin
   if _Source.PluginType = FPluginType then
   begin
      SetLength(Opposites, High((_Source as THalfEdgePlugin).Opposites)+1);
      for i := Low(Opposites) to High(Opposites) do
      begin
         Opposites[i] := (_Source as THalfEdgePlugin).Opposites[i];
      end;
      ID := (_Source as THalfEdgePlugin).ID;
   end;
   inherited Assign(_Source);
end;

end.
