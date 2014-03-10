unit BasicRenderingTypes;

interface

type
   PVertexItem = ^TVertexItem;
   TVertexItem = record
      ID: integer;
      x,y,z: single;
      Next: PVertexItem;
   end;

   PTriangleItem = ^TTriangleItem;
   TTriangleItem = record
      v1, v2, v3: integer;
      Color: cardinal;
      Next: PTriangleItem;
   end;

   PQuadItem = ^TQuadItem;
   TQuadItem = record
      v1, v2, v3, v4: integer;
      Color: cardinal;
      Next: PQuadItem;
   end;

   TTriangleNeighbourItem = record
      ID: integer;
      V1,V2: integer;
   end;
   PTriangleNeighbourItem = ^TTriangleNeighbourItem;

   TSurfaceDescriptiorItem = record
      Triangles: array [0..5] of PTriangleItem;
      Quads: array [0..5] of PQuadItem;
   end;

   TDescriptor = record
      Start,Size: integer;
   end;
   TADescriptor = array of TDescriptor;
   TNeighborDetectorSaveData = record
      cID, nID : integer;
   end;

   TScreenshotType = (stNone,stBmp,stTga,stJpg,stGif,stPng,stDDS,stPS,stPDF,stEPS,stSVG);
   TRenderProc = procedure of object;

implementation

end.
