unit BasicConstants;

interface

const
   // Voxel Section Editor Basic constants (originally at Voxel_Engine.pas)
   DefaultZoom = 7;
   VIEWBGCOLOR = -1;

   VXLTool_Brush = 0;
   VXLTool_Line = 1;
   VXLTool_Erase = 2;
   VXLTool_FloodFill = 3;
   VXLTool_Dropper = 4;
   VXLTool_Rectangle = 5;
   VXLTool_FilledRectangle = 6;
   VXLTool_Darken = 7;
   VXLTool_Lighten = 8;
   VXLTool_SmoothNormal = 9;
   VXLTool_FloodFillErase = 10;
   VXLTool_Measure = 11;
   ViewName: array[0..5] of string = (
      ' Right',
      ' Left',
      ' Top',
      ' Bottom',
      ' Back',
      ' Front');

   // From Voxel.pas
   VTRANSPARENT = 256;
   MAXNORM_TIBERIAN_SUN = 36;
   MAXNORM_RED_ALERT2 = 244;

   // Voxel Map Fill Mode
   C_MODE_NONE = 0;
   C_MODE_ALL = 1;
   C_MODE_USED = 2;
   C_MODE_COLOUR = 3;
   C_MODE_NORMAL = 4;

   // Pixel position in the volume.
   C_OUTSIDE_VOLUME = 0;
   C_ONE_AXIS_INFLUENCE = 1;
   C_TWO_AXIS_INFLUENCE = 2;
   C_THREE_AXIS_INFLUENCE = 3;
   C_SEMI_SURFACE = 3;
   C_SURFACE = 4;
   C_INSIDE_VOLUME = 5;

   // Semi-surfaces configuration
   C_SF_BOTTOM_FRONT_LEFT_POINT = 1;
   C_SF_BOTTOM_FRONT_RIGHT_POINT = 2;
   C_SF_BOTTOM_BACK_LEFT_POINT = 4;
   C_SF_BOTTOM_BACK_RIGHT_POINT = 8;
   C_SF_TOP_FRONT_LEFT_POINT = $10;
   C_SF_TOP_FRONT_RIGHT_POINT = $20;
   C_SF_TOP_BACK_LEFT_POINT = $40;
   C_SF_TOP_BACK_RIGHT_POINT = $80;
   C_SF_BOTTOM_FRONT_LINE = $103;
   C_SF_BOTTOM_BACK_LINE = $20C;
   C_SF_BOTTOM_LEFT_LINE = $405;
   C_SF_BOTTOM_RIGHT_LINE = $80A;
   C_SF_TOP_FRONT_LINE = $1030;
   C_SF_TOP_BACK_LINE = $20C0;
   C_SF_TOP_LEFT_LINE = $4050;
   C_SF_TOP_RIGHT_LINE = $80A0;
   C_SF_LEFT_FRONT_LINE = $10011;
   C_SF_LEFT_BACK_LINE = $20044;
   C_SF_RIGHT_FRONT_LINE = $40022;
   C_SF_RIGHT_BACK_LINE = $80088;

   // From VoxelMeshGenerator
   C_VMG_NO_VERTEX = -1;//2147483647;

   // From MeshGeometryList
   C_GEO_BREP = 1;
   C_GEO_BREP3 = 2;
   C_GEO_BREP4 = 3;

   //------------------------------------------------------------------
   // From VoxelModelizerItem.pas
   //------------------------------------------------------------------

   // Vertices
   C_VERT_TOP_LEFT_BACK = 0;
   C_VERT_TOP_RIGHT_BACK = 1;
   C_VERT_TOP_LEFT_FRONT = 2;
   C_VERT_TOP_RIGHT_FRONT = 3;
   C_VERT_BOTTOM_LEFT_BACK = 4;
   C_VERT_BOTTOM_RIGHT_BACK = 5;
   C_VERT_BOTTOM_LEFT_FRONT = 6;
   C_VERT_BOTTOM_RIGHT_FRONT = 7;
   // Edges
   C_EDGE_TOP_LEFT = 0;
   C_EDGE_TOP_RIGHT = 1;
   C_EDGE_TOP_BACK = 2;
   C_EDGE_TOP_FRONT = 3;
   C_EDGE_BOTTOM_LEFT = 4;
   C_EDGE_BOTTOM_RIGHT = 5;
   C_EDGE_BOTTOM_BACK = 6;
   C_EDGE_BOTTOM_FRONT = 7;
   C_EDGE_FRONT_LEFT = 8;
   C_EDGE_FRONT_RIGHT = 9;
   C_EDGE_BACK_LEFT = 10;
   C_EDGE_BACK_RIGHT = 11;
   // Faces
   C_FACE_LEFT = 0;
   C_FACE_RIGHT = 1;
   C_FACE_BACK = 2;
   C_FACE_FRONT = 3;
   C_FACE_BOTTOM = 4;
   C_FACE_TOP = 5;

   // Face Settings
   C_FACE_SET_VERT = 0;
   C_FACE_SET_EDGE = 1;
   C_FACE_SET_FACE = 2;

   // Vertex Positions
   C_VP_HIGH = 8;
   C_VP_MID = C_VP_HIGH div 2;            // 4

   VertexRequirements: array[0..7] of integer = (C_SF_TOP_BACK_LEFT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT);

   VertexCheck: array[0..55] of byte = (0, 1, 4, 8, 9, 10, 11, 17, 18, 21, 25, 9, 10,
   11, 0, 1, 3, 6, 13, 12, 11, 17, 18, 20, 23, 13, 12, 11, 0, 2, 4, 7, 9, 16, 15,
   17, 19, 21, 24, 9, 16, 15, 0, 2, 3, 5, 13, 14, 15, 17, 19, 20, 22, 13, 14, 15);

   SSVertexesCheck: array[0..55] of byte = (C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_LEFT_POINT,
   C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
   C_SF_TOP_FRONT_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_RIGHT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_BOTTOM_BACK_RIGHT_POINT,
   C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
   C_SF_BOTTOM_FRONT_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
   C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_FRONT_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_TOP_BACK_RIGHT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT,
   C_SF_TOP_BACK_LEFT_POINT, C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_FRONT_LEFT_POINT,
   C_SF_TOP_FRONT_LEFT_POINT, C_SF_BOTTOM_BACK_LEFT_POINT, C_SF_TOP_BACK_LEFT_POINT,
   C_SF_BOTTOM_BACK_RIGHT_POINT, C_SF_TOP_BACK_RIGHT_POINT, C_SF_TOP_FRONT_RIGHT_POINT);

   EdgeRequirements: array[0..11] of integer = (C_SF_TOP_LEFT_LINE, C_SF_TOP_RIGHT_LINE,
   C_SF_TOP_BACK_LINE, C_SF_TOP_FRONT_LINE, C_SF_BOTTOM_LEFT_LINE, C_SF_BOTTOM_RIGHT_LINE,
   C_SF_BOTTOM_BACK_LINE, C_SF_BOTTOM_FRONT_LINE, C_SF_LEFT_FRONT_LINE, C_SF_RIGHT_FRONT_LINE,
   C_SF_LEFT_BACK_LINE, C_SF_RIGHT_BACK_LINE);

   EdgeCheck: array[0..35] of byte = (0, 1, 11, 17, 18, 11, 9, 10, 11, 13, 12, 11,
   0, 2, 15, 17, 19, 15, 9, 16, 15, 13, 14, 15, 0, 3, 13, 17, 20, 13, 0, 4, 9, 17,
   21, 9);

   SSEdgesCheck: array[0..35] of integer = (C_SF_TOP_RIGHT_LINE, C_SF_BOTTOM_RIGHT_LINE,
   C_SF_BOTTOM_LEFT_LINE, C_SF_TOP_LEFT_LINE, C_SF_BOTTOM_LEFT_LINE,
   C_SF_BOTTOM_RIGHT_LINE, C_SF_TOP_FRONT_LINE, C_SF_BOTTOM_FRONT_LINE,
   C_SF_BOTTOM_BACK_LINE, C_SF_TOP_BACK_LINE, C_SF_BOTTOM_BACK_LINE,
   C_SF_BOTTOM_FRONT_LINE, C_SF_BOTTOM_RIGHT_LINE, C_SF_TOP_RIGHT_LINE,
   C_SF_TOP_LEFT_LINE, C_SF_BOTTOM_LEFT_LINE, C_SF_TOP_LEFT_LINE,
   C_SF_TOP_RIGHT_LINE, C_SF_BOTTOM_FRONT_LINE, C_SF_TOP_FRONT_LINE,
   C_SF_TOP_BACK_LINE, C_SF_BOTTOM_BACK_LINE, C_SF_TOP_BACK_LINE,
   C_SF_TOP_FRONT_LINE, C_SF_RIGHT_FRONT_LINE, C_SF_RIGHT_BACK_LINE,
   C_SF_LEFT_BACK_LINE, C_SF_LEFT_FRONT_LINE, C_SF_LEFT_BACK_LINE,
   C_SF_RIGHT_BACK_LINE, C_SF_RIGHT_BACK_LINE, C_SF_RIGHT_FRONT_LINE,
   C_SF_LEFT_FRONT_LINE, C_SF_LEFT_BACK_LINE, C_SF_LEFT_FRONT_LINE,
   C_SF_RIGHT_FRONT_LINE);

   FaceCheck: array[0..5] of byte = (0, 17, 9, 13, 15, 11);

   VertexPoints: array[0..19,0..2] of byte = ((0,0,C_VP_HIGH),(C_VP_HIGH,0,C_VP_HIGH),
   (0,C_VP_HIGH,C_VP_HIGH), (C_VP_HIGH,C_VP_HIGH,C_VP_HIGH), (0,0,0), (C_VP_HIGH,0,0),
   (0,C_VP_HIGH,0), (C_VP_HIGH,C_VP_HIGH,0), (0,C_VP_MID,C_VP_HIGH),
   (C_VP_HIGH,C_VP_MID,C_VP_HIGH), (C_VP_MID,0,C_VP_HIGH), (C_VP_MID,C_VP_HIGH,C_VP_HIGH),
   (0,C_VP_MID,0), (C_VP_HIGH,C_VP_MID,0), (C_VP_MID,0,0), (C_VP_MID,C_VP_HIGH,0),
   (0,C_VP_HIGH,C_VP_MID), (C_VP_HIGH,C_VP_HIGH,C_VP_MID), (0,0,C_VP_MID), (C_VP_HIGH,0,C_VP_MID));

   VertexNeighbors: array [0..23] of byte = (8,10,18,10,19,9,8,11,16,9,11,17,12,
   18,14,14,13,19,16,15,12,15,17,13);

   VertexNeighborEdges: array [0..23] of byte = (0,2,10,2,11,1,0,3,8,1,3,9,4,
   10,6,6,5,11,8,7,4,7,9,5);

   EdgeVertexesList: array [0..71] of byte = (0,2,10,18,11,16,3,1,10,19,11,17,0,1,
   8,18,9,19,2,3,8,16,17,9,4,6,18,14,16,15,5,7,14,19,17,15,4,5,18,12,19,13,6,7,16,
   12,17,13,2,6,8,11,15,12,3,7,11,9,13,15,0,4,8,10,12,14,1,5,10,9,14,13);

   FaceVertexesList: array [0..47] of byte = (0,2,4,6,14,10,11,15,1,5,7,3,10,14,
   11,15,0,1,4,5,8,9,12,13,2,3,6,7,8,9,12,13,4,5,6,7,16,17,18,19,0,1,2,3,16,17,
   18,19);

   EdgeVertexes: array[0..23] of byte = (0,2,1,3,0,1,2,3,4,6,5,7,4,5,6,7,2,6,3,
   7,0,4,1,5);

{
   ForbiddenEdgesPerEdges: array[0..143,0..1] of byte = ((0,11),(0,3),(0,9),(2,10),
   (2,1),(2,9),(0,16),(0,6),(0,12),(2,18),(2,4),(2,12),(1,11),(1,2),(1,8),(3,10),
   (3,0),(3,8),(1,17),(1,7),(1,13),(3,19),(3,5),(3,13),(0,11),(0,3),(0,9),(1,8),
   (1,2),(1,11),(0,19),(0,5),(0,14),(1,18),(1,4),(1,14),(2,9),(2,1),(2,10),(3,10),
   (3,0),(3,8),(2,17),(2,7),(2,15),(3,16),(3,6),(3,15),(4,16),(4,2),(4,8),(6,18),
   (6,0),(6,8),(4,15),(4,7),(4,13),(6,14),(6,5),(6,13),(5,17),(5,3),(5,9),(7,19),
   (7,1),(7,9),(5,15),(5,6),(5,12),(7,14),(7,4),(7,12),(4,19),(4,1),(4,10),(5,18),
   (5,0),(5,10),(4,13),(4,7),(4,15),(5,12),(5,6),(5,15),(6,17),(6,3),(6,11),(7,16),
   (7,2),(7,11),(6,13),(6,5),(6,14),(7,12),(7,4),(7,14),(2,12),(2,4),(2,18),(6,8),
   (6,0),(6,18),(2,17),(2,7),(2,15),(6,11),(6,3),(6,17),(3,13),(3,5),(3,19),(7,9),
   (7,1),(7,19),(3,15),(3,6),(3,16),(7,11),(7,2),(7,16),(0,12),(0,6),(0,16),(4,8),
   (4,2),(4,16),(0,14),(0,5),(0,19),(4,10),(4,1),(4,19),(1,13),(1,7),(1,17),(5,9),
   (5,3),(5,17),(1,14),(1,4),(1,18),(5,10),(5,0),(5,18));
}

   ForbiddenEdgesPerEdges: array[0..59,0..1] of byte = ((0,11),(0,16),(2,10),(2,18),
   (0,2),(1,11),(1,14),(3,10),(3,19),(1,3),(0,19),(0,9),(1,8),(1,18),(0,1),(2,9),
   (3,8),(2,17),(3,16),(2,3),(4,16),(6,18),(4,15),(6,14),(4,6),(5,17),(7,19),(5,15),
   (7,14),(5,7),(4,19),(5,18),(4,13),(5,12),(4,5),(6,17),(7,16),(6,13),(7,12),(6,7),
   (2,12),(6,8),(2,15),(6,11),(2,6),(3,13),(7,9),(3,15),(7,11),(3,7),(0,12),(4,8),
   (0,14),(4,10),(0,4),(1,13),(5,9),(1,14),(5,10),(1,5));


   ForbiddenEdgesPerFace: array[0..95,0..1] of byte = ((0,16),(0,6),(0,12),(8,16),
   (8,6),(8,12),(8,4),(8,18),(2,12),(2,4),(2,18),(16,12),(16,4),(16,18),(6,18),
   (12,18),(1,17),(1,7),(1,13),(9,17),(9,7),(9,13),(9,5),(9,19),(3,13),(3,5),(3,19),
   (17,13),(17,5),(17,19),(7,19),(13,19),(0,19),(0,5),(0,14),(10,19),(10,5),(10,14),
   (10,4),(10,18),(1,14),(1,4),(1,18),(19,14),(19,4),(19,18),(5,18),(14,18),(2,17),
   (2,7),(2,15),(11,17),(11,7),(11,15),(11,6),(11,16),(3,15),(3,6),(3,16),(17,15),
   (17,6),(17,16),(7,16),(15,16),(4,13),(4,7),(4,15),(14,13),(14,7),(14,15),(14,6),
   (14,12),(5,15),(5,6),(5,12),(13,15),(13,6),(13,12),(7,12),(15,12),(0,9),(0,3),
   (0,11),(10,9),(10,3),(10,11),(10,2),(10,8),(1,11),(1,2),(1,8),(9,11),(9,2),(9,8),
   (3,8),(11,8));

   ForbiddenFaces: array[0..11,0..2] of byte = ((0,8,2),(0,18,4),(4,12,6),(2,16,6),
   (2,11,3),(3,17,7),(6,15,7),(3,9,1),(1,19,5),(7,13,5),(0,10,1),(4,14,5));

   ForbiddenFacesPerFaces: array[0..317,0..2] of byte = ((0,8,18),(0,2,18),(0,16,18),
   (0,6,18),(0,12,18),(0,4,18),(0,4,12),(0,4,6),(0,4,16),(0,4,2),(0,4,8),(0,12,6),
   (0,12,16),(0,2,12),(0,8,12),(0,6,16),(0,6,2),(0,6,8),(0,16,2),(0,8,16),(18,4,12),
   (18,4,6),(18,4,16),(18,4,2),(18,4,8),(18,12,6),(18,12,16),(18,12,2),(18,12,8),
   (18,6,16),(18,6,2),(18,6,8),(18,16,2),(18,16,8),(18,2,8),(4,12,16),(4,12,2),
   (4,12,8),(4,6,16),(4,6,2),(4,6,8),(4,16,2),(4,16,8),(4,2,8),(12,6,16),(12,6,2),
   (12,6,8),(12,16,2),(12,16,8),(12,2,8),(6,16,8),(6,2,8),(16,2,8),(3,9,17),(3,1,17),
   (3,19,17),(3,5,17),(3,13,17),(3,7,17),(3,7,13),(3,7,5),(3,7,19),(3,7,1),(3,7,9),
   (3,13,5),(3,13,19),(3,1,13),(3,9,13),(3,5,19),(3,5,1),(3,5,9),(3,19,1),(3,9,19),
   (17,7,13),(17,7,5),(17,7,19),(17,7,1),(17,7,9),(17,13,5),(17,13,19),(17,13,1),
   (17,13,9),(17,5,19),(17,5,1),(17,5,9),(17,19,1),(17,19,9),(17,1,9),(7,13,19),
   (7,13,1),(7,13,9),(7,5,19),(7,5,1),(7,5,9),(7,19,1),(7,19,9),(7,1,9),(13,5,19),
   (13,5,1),(13,5,9),(13,19,1),(13,19,9),(13,1,9),(5,19,9),(5,1,9),(19,1,9),(1,10,19),
   (1,0,19),(1,18,19),(1,4,19),(1,14,19),(1,5,19),(1,5,14),(1,5,4),(1,5,18),(1,5,0),
   (1,5,10),(1,14,4),(1,14,18),(1,0,14),(1,10,14),(1,4,18),(1,4,0),(1,4,10),(1,18,0),
   (1,10,18),(19,5,14),(19,5,4),(19,5,18),(19,5,0),(19,5,10),(19,14,4),(19,14,18),
   (19,14,0),(19,14,10),(19,4,18),(19,4,0),(19,4,10),(19,18,0),(19,18,10),(19,0,10),
   (5,14,18),(5,14,0),(5,14,10),(5,4,18),(5,4,0),(5,4,10),(5,18,0),(5,18,10),(5,0,10),
   (14,4,18),(14,4,0),(14,4,10),(14,18,0),(14,18,10),(14,0,10),(4,18,10),(4,0,10),
   (18,0,10),(3,11,17),(3,2,17),(3,16,17),(3,6,17),(3,15,17),(3,7,17),(3,7,15),
   (3,7,6),(3,7,16),(3,7,2),(3,7,11),(3,15,6),(3,15,16),(3,2,15),(3,11,15),(3,6,16),
   (3,6,2),(3,6,11),(3,16,2),(3,11,16),(17,7,12),(17,7,6),(17,7,16),(17,7,2),
   (17,7,11),(17,15,6),(17,15,16),(17,15,2),(17,15,11),(17,6,16),(17,6,2),(17,6,11),
   (17,16,2),(17,16,11),(17,2,11),(7,15,16),(7,15,2),(7,15,11),(7,6,16),(7,6,2),
   (7,6,11),(7,16,2),(7,16,11),(7,2,11),(15,6,16),(15,6,2),(15,6,11),(15,16,2),
   (15,16,11),(15,2,11),(6,16,11),(6,2,11),(16,2,11),(5,14,13),(5,4,13),(5,12,13),
   (5,6,13),(5,15,13),(5,7,13),(5,7,15),(5,7,6),(5,7,12),(5,7,4),(5,7,14),(5,15,6),
   (5,15,12),(5,4,15),(5,14,15),(5,6,12),(5,6,4),(5,6,14),(5,12,4),(5,14,12),
   (13,7,15),(13,7,6),(13,7,12),(13,7,4),(13,7,14),(13,15,6),(13,15,12),(13,15,4),
   (13,15,14),(13,6,12),(13,6,4),(13,6,14),(13,12,4),(13,12,14),(13,4,14),(7,15,12),
   (7,15,4),(7,15,14),(7,6,12),(7,6,4),(7,6,14),(7,12,4),(7,12,14),(7,4,14),
   (15,6,12),(15,6,4),(15,6,14),(15,12,4),(15,12,14),(15,4,14),(6,12,14),(6,4,14),
   (12,4,14),(1,10,9),(1,0,9),(1,8,9),(1,2,9),(1,11,9),(1,3,9),(1,3,11),(1,3,2),
   (1,3,8),(1,3,0),(1,3,10),(1,11,2),(1,11,8),(1,0,11),(1,10,11),(1,2,8),(1,2,0),
   (1,2,10),(1,8,0),(1,10,8),(9,3,11),(9,3,2),(9,3,8),(9,3,0),(9,3,10),(9,11,2),
   (9,11,8),(9,11,0),(9,11,10),(9,2,8),(9,2,0),(9,2,10),(9,8,0),(9,8,10),(9,0,10),
   (3,11,8),(3,11,0),(3,11,10),(3,2,8),(3,2,0),(3,2,10),(3,8,0),(3,8,10),(3,0,10),
   (11,2,8),(11,2,0),(11,2,10),(11,8,0),(11,8,10),(11,0,10),(2,8,10),(2,0,10),
   (8,0,10));

implementation

end.
