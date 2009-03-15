unit VH_Types;

interface

Uses Math3d,Voxel;

type

   TVoxelBox = record
      Color,Normal,Section : integer;
      Position,MinBounds,MinBounds2 : TVector3f;
      Faces : array [1..6] of Boolean;
   end;

   TVoxelBoxSection = Record
      Boxs    : array of TVoxelBox;
      List,
      NumBoxs : Integer;
   end;

   TVoxelBoxs = Record
      Sections  : array of TVoxelBoxSection;
      NumSections : Integer;
   end;

   TGT = record
      Tex : Cardinal;
      Name : string;
      Tile : boolean;
   end;

   TGTI = record
      Tex,ID : cardinal;
   end;

   TSKYTex = record
      Loaded : Boolean;
      Textures : array [0..5] of Cardinal;
      Texture_Name : String;
      Filename : array [0..5] of String;
   end;

// Currently 5 sections. Between each section is a break. If depth => 0 then it isn't used.
   TVH_Views = record
      Name : String;
      XRot, YRot, Depth : Single;
      Section : Integer;
      NotUnitRot : Boolean;
   end;

   TScreenShot = record
      Take,TakeAnimation,CaptureAnimation,
      Take360DAnimation : Boolean;
      _Type,            //0 = BMP, 1 = JPG
      Width,Height,
      CompressionRate,
      Frames,FrameCount : Integer;
      FrameAdder,OldYRot : Single;
   end;

Type
   TVVH = record
      Game : byte; //(2 TS, 4 RA2)
      GroundName,SkyName : string[50];
      DataS_No : integer;
      DataB_No : integer;
   end;

   TVVD = record
      ID: word;
      Value : single;
   end;

   TVVDB = record
      ID: word;
      Value : Boolean;
   end;

   TVVSFile = record
      Version : single;
      Header : TVVH;
      DataS : array of TVVD;
      DataB : array of TVVDB;
   end;

   DSIDs = (DSRotX,DSRotY,DSDepth,DSXShift,DSYShift,DSGroundSize,DSGroundHeight,DSSkyXPos,DSSkyYPos,DSSkyZPos,DSSkyWidth,DSSkyHeight,DSSkyLength,DSFOV,DSDistance,DSUnitRot,DSDiffuseX,DSDiffuseY,DSDiffuseZ,DSAmbientX,DSAmbientY,DSAmbientZ,DSTurretRotationX,DSBackgroundColR,DSBackgroundColG,DSBackgroundColB,DSUnitCount,DSUnitSpace);
   DBIDs = (DBDrawGround,DBTileGround,DBDrawTurret,DBDrawBarrel,DBShowDebug,DBShowVoxelCount,DBDrawSky,DBCullFace,DBLightGround);

   TControlType = (CTview,CToffset,CThvaposition,CThvarotation);

   THVA_Main_Header = record
      FilePath: array[1..16] of Char;  (* ASCIIZ string                      *)
      N_Frames,                        (* Number of animation frames         *)
      N_Sections : Longword;           (* Number of voxel sections described *)
   end;

   TSectionName = array[1..16] of Char; (* ASCIIZ string - name of section *)
   TTransformMatrix = array[1..3,1..4] of Single;

   THVAData = record
      SectionName : TSectionName;
   end;

   PHVA = ^THVA;
   THVA = Record
      Header : THVA_Main_Header;
      Data : array of THVAData;
      TransformMatrixs : array of TTransformMatrix;
      Data_no : integer;
      HigherLevel : PHVA; // Added by Banshee, for hierarchy purposes.
   end;

   THVAVOXEL = (HVhva,HVvoxel);

   TUndo_Redo_Data = record
      _Type : THVAVOXEL;
      Voxel : PVoxel;
      HVA : PHVA;
      Offset : TVector3f;
      Size : TVector3f;
      TransformMatrix : TTransformMatrix;
      Frame,Section : Integer;
   end;

   TUndo_Redo = Record
      Data : Array Of TUndo_Redo_Data;
      Data_No : Integer;
   end;

implementation

end.
