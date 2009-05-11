unit GLConstants;

interface

uses BasicDataTypes;

const
   // For Mesh.NormalsType
   C_NORMALS_DISABLED = 0;
   C_NORMALS_PER_VERTEX = 1;
   C_NORMALS_PER_FACE = 2;
   // For Mesh.ColoursType
   C_COLOURS_DISABLED = 0;
   C_COLOURS_PER_VERTEX = 1;
   C_COLOURS_PER_FACE = 2;

   // For Voxel Faces
   C_VOXEL_FACE_SIDE = 0;
   C_VOXEL_FACE_DEPTH = 1;
   C_VOXEL_FACE_HEIGHT = 2;

   // Lists
   C_LIST_NONE = 0;

   RemapColourMap : array [0..8] of TVector3b =
   (
      ( //DarkRed
         R : 255;
         G : 3;
         B : 3;
      ),
      ( //DarkBlue
         R : 9;
         G : 53;
         B : 255;
      ),
      ( //DarkGreen
         R : 13;
         G : 255;
         B : 16;
      ),
      ( //White
         R : 255;
         G : 255;
         B : 255;
      ),
      ( //Orange
         R : 255;
         G : 160;
         B : 3;
      ),
      ( //Magenta
         R : 255;
         G : 105;
         B : 178;
      ),
      ( //Purple
         R : 255;
         G : 12;
         B : 252;
      ),
      ( //Gold
         R : 255;
         G : 203;
         B : 0;
      ),
      ( //DarkSky
         R : 24;
         G : 191;
         B : 255;
      )
  );


implementation

end.
