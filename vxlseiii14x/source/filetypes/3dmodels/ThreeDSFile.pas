unit ThreeDSFile;

interface

uses BasicDataTypes, BasicFunctions;

const
   C_MAIN_CHUNK = $4D4D;
   C_3DEDITOR_CHUNK = $3D3D;
   C_OBJECT_BLOCK = $4000;
   C_TRIANGULAR_MESH = $4100;
   C_VERTICES_LIST = $4110;
   C_FACES_DESCRIPTION = $4120;
   C_FACES_MATERIAL = $4130;
   C_MAPPING_COORDINATES_LIST = $4140;
   C_SMOOTHING_GROUP_LIST = $4150;
   C_LOCAL_COORDINATES_SYSTEM = $4160;
   C_LIGHT = $4600;
   C_SPOTLIGHT = $4610;
   C_CAMERA = $4700;
   C_MATERIAL_BLOCK = $AFFF;
   C_MATERIAL_NAME = $A000;
   C_AMBIENT_COLOR = $A010;
   C_DIFFUSE_COLOR = $A020;
   C_SPECULAR_COLOR = $A030;
   C_TEXTURE_MAP = $A200;
   C_BUMP_MAP = $A230;
   C_REFLECTION_MAP = $A220;
   C_MAPPING_FILENAME = $A300;
   C_MAPPING_PARAMETERS = $A351;
   C_KEYFRAMER_CHUNK = $B000;
   C_MESH_INFORMATION_BLOCK = $B002;
   C_SPOT_LIGHT_INFORMATION_BLOCK = $B007;
   C_FRAMES = $B008;
   C_OBJECT_NAME = $B010;
   C_OBJECT_PIVOT_POINT = $B013;
   C_POSITION_TRACK = $B020;
   C_ROTATION_TRACK = $B021;
   C_SCALE_TRACK = $B022;
   C_HIERARCHY_POSITION = $B030;

type
   T3DSFile = class
      private
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
   end;

implementation

constructor T3DSFile.Create;
begin
   // Do nothing
end;

destructor T3DSFile.Destroy;
begin
   inherited Destroy;
end;



end.
