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
   C_COLOURS_FROM_TEXTURE = 3;

   // For Voxel Faces
   C_VOXEL_FACE_SIDE = 0;
   C_VOXEL_FACE_DEPTH = 1;
   C_VOXEL_FACE_HEIGHT = 2;

   // Lists
   C_LIST_NONE = 0;

   // Mesh Quality
   C_QUALITY_CUBED = 0;
   C_QUALITY_VISIBLE_CUBED = 1;
   C_QUALITY_VISIBLE_TRIS = 2;
   C_QUALITY_LANCZOS_QUADS = 3;
   C_QUALITY_2LANCZOS_4TRIS = 4;
   C_QUALITY_LANCZOS_TRIS = 5;
   C_QUALITY_VISIBLE_MANIFOLD = 6;
   C_QUALITY_SMOOTH_MANIFOLD = 7;
   C_QUALITY_HIGH = 8;
   C_QUALITY_MAX = C_QUALITY_HIGH;

   // Frequency normalization
   C_FREQ_NORMALIZER = 4/3;

   // Texture Type
   C_TTP_DIFFUSE = 0;
   C_TTP_NORMAL = 1;
   C_TTP_HEIGHT = 2;
   C_TTP_SPECULAR = 3;
   C_TTP_ALPHA = 4;
   C_TTP_AMBIENT = 5;
   C_TTP_ENVIRONMENT = 6;
   C_TTP_DECAL = 7;
   C_TTP_DISPLACEMENT = 8;
   C_TTP_DOT3BUMP = 9;

   // Angle Detection
   C_ANGLE_NONE = -99999;

   // Shader Types
   C_SHD_PHONG = 0;
   C_SHD_PHONG_1TEX = 1;
   C_SHD_PHONG_2TEX = 2;
   C_SHD_PHONG_DOT3TEX = 3;

   // Transparency
   C_TRP_OPAQUE = 1;
   C_TRP_GHOST = 0.05;
   C_TRP_INVISIBLE = 0;
   C_TRP_RGB_OPAQUE = 255;
   C_TRP_RGB_GHOST = 2;
   C_TRP_RGB_INVISIBLE = 0;

   // Texture minimum angle
   C_TEX_MIN_ANGLE = 0.7; // approximately cos 45'

   // Mesh Plugins
   C_MPL_BASE = 0;
   C_MPL_NORMALS = 1;
   C_MPL_NEIGHBOOR = 2;
   C_MPL_BUMPMAPDATA = 3;
   C_MPL_MESH = 4;

   // Distance Functions
   C_DSF_IGNORE = 0;
   C_DSF_LINEAR = 1;
   C_DSF_CUBIC = 2;
   C_DSF_QUADRIC1D = 3;
   C_DSF_LINEAR1D = 4;
   C_DSF_CUBIC1D = 5;
   C_DSF_LANCZOS = 6;
   C_DSF_LANCZOS1DA1 = 7;
   C_DSF_LANCZOS1DA3 = 8;
   C_DSF_LANCZOS1DAC = 9;
   C_DSF_SINC1D = 10;
   C_DSF_EULER1D = 11;
   C_DSF_EULERSQUARED1D = 12;
   C_DSF_SINCINFINITE1D = 13;

   // To clean topological problems
   C_TOPO_DOESNT_EXIST = -2;
   C_TOPO_MAKRED_TO_DIE = -1;
   C_TOPO_X_POS = 0;
   C_TOPO_X_NEG = 1;
   C_TOPO_Y_POS = 2;
   C_TOPO_Y_NEG = 3;
   C_TOPO_Z_POS = 4;
   C_TOPO_Z_NEG = 5;
   C_ORI_XNEG_YNEG = 0;
   C_ORI_XPOS_YNEG = 1;
   C_ORI_XNEG_YPOS = 2;
   C_ORI_XPOS_YPOS = 3;
   C_ORI_XNEG_ZNEG = $10;
   C_ORI_XPOS_ZNEG = $11;
   C_ORI_XNEG_ZPOS = $14;
   C_ORI_XPOS_ZPOS = $15;
   C_ORI_YNEG_ZNEG = $20;
   C_ORI_YPOS_ZNEG = $22;
   C_ORI_YNEG_ZPOS = $24;
   C_ORI_YPOS_ZPOS = $26;

   // For bump mapping texture generation
   C_BUMP_DEFAULTSCALE = 2.2;

   // Remappables
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
