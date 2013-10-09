unit BasicDataTypes;

interface

uses Graphics,StdCtrls,ExtCtrls,Menus;

type
   PPaintBox = ^TPaintBox;
   PLabel = ^TLabel;
   PMenuItem = ^TMenuItem;

   TVector4f = record
      X, Y, Z, W : single;
   end;
   PVector4f = ^TVector4f;

   TAVector4f = array of TVector4f;
   PAVector4f = ^TAVector4f;

   TVector3f = record
      X, Y, Z : single;
   end;
   PVector3f = ^TVector3f;

   TAVector3f = array of TVector3f;
   PAVector3f = ^TAVector3f;

   TVector2f = record
      U, V : single;
   end;
   TAVector2f = array of TVector2f;
   PAVector2f = ^TAVector2f;

   TVector3i = record
      X, Y, Z : integer;
   end;
   TAVector3i = array of TVector3i;
   PAVector3i = ^TAVector3i;

   TVector3b = record
      R,G,B : Byte;
   end;
   
   TRectangle3f = record
      Min, Max : TVector3f;
   end;

   TVoxelUnpacked = record
      Colour,
      Normal,
      Flags: Byte;
      Used: Boolean;
   end;

   TTempViewData = record
      V : TVoxelUnpacked;
      VC : TVector3i; // Cordinates of V
      VU : Boolean; // Is V Used, if so we can do this to the VXL file when needed
      X,Y : Integer;
   end;

   TTempView = record
      Data : Array of TTempViewData;
      Data_no : integer;
   end;

   TTempLine = record
      x1 : integer;
      y1 : integer;
      x2 : integer;
      y2 : integer;
      colour : TColor;
      width : integer;
   end;

   TTempLines = record
      Data : Array of TTempLine;
      Data_no : integer;
   end;

   TPaletteList = record
      Data : array of String;
      Data_no : integer;
   end;

   TColourSchemesInfo = array of packed record
        Name,Filename,By,Website : string;
   end;

   TVoxelPacked = LongInt;

   TThumbnail = record
      Width, Height: Integer;
   end;

   TViewport = record
      Left, Top, Zoom: Integer;
      hasBeenUsed: Boolean; // this flag lets the ui know if this
                   // view has been used already (so zoom is a user setting)
   end;

   EError = (OK, ReadFailed, WriteFailed, InvalidSpanDataSizeCalced, InvalidSpan,
     BadSpan_SecondVoxelCount, Unhandled_Exception);

   EDrawMode = (ModeDraw, ModeFloodFill, ModeRectFill, ModeMagnify, ModeLine, ModeColSelect, ModeBrush,  ModeRect, ModeSelect, ModePippet,
     ModeErase, ModeBumpColour, ModeBumpDownColour,ModeFloodFillErase);
   EClickMode = (ModeSingleClick, ModeDoubleClick);
   ESpectrumMode = (ModeColours, ModeNormals);
   EViewMode = (ModeFull, ModeEmphasiseDepth, ModeCrossSection);

   EVoxelViewOrient = (oriX, oriY, oriZ);
   EVoxelViewDir = (dirTowards, dirAway);
   TVoxelType = (vtLand, vtAir);

   PIntegerItem = ^TIntegerItem;
   TIntegerItem = record
      Value : integer;
      Next : PIntegerItem;
   end;

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

   TGLMatrixf4 = array[0..3, 0..3] of Single;

   T3DIntGrid = array of array of array of integer;
   P3DIntGrid = ^T3DIntGrid;
   T3DSingleGrid = array of array of array of single;
   P3DSingleGrid = ^T3DSingleGrid;
   T4DIntGrid = array of array of array of array of integer;
   P4DIntGrid = ^T4DIntGrid;

   PByte = ^Byte;
   PInteger = ^Integer;
   AInt32 = array of integer;
   AUInt32 = array of longword;
   AString = array of string;
   PAUint32 = ^AUInt32;
   ABool = array of boolean;
   AByte = array of byte;
   AFloat = array of single;
   TByteMap = array of array of byte;
   T2DBooleanMap = array of array of Boolean;
   TInt32Map = array of AInt32;
   TAByteMap = array of TByteMap;
   TABitmap = array of TBitmap;

   TDistanceUnit = record
      x,
      y,
      z,
      Distance : single;
   end;

   TDescriptor = record
      Start,Size: integer;
   end;
   TADescriptor = array of TDescriptor;
   TNeighborDetectorSaveData = record
      cID, nID : integer;
   end;


   TScreenshotType = (stNone,stBmp,stTga,stJpg,stGif,stPng,stDDS,stPS,stPDF,stEPS,stSVG);
   TBinaryMap = array of array of array of single; //byte;
   T3DBooleanMap = array of array of array of boolean;
   TVector3fMap = array of array of array of TVector3f;
   TDistanceArray = array of array of array of TDistanceUnit; //single;

   TDistanceFunc = function (_Distance: single): single of object;
   T2DFrameBuffer = array of array of TVector4f;
   TWeightBuffer = array of array of real;

   TSeedTreeItem = record
      Left, Right: integer;
   end;
   TSeedTree = array of TSeedTreeItem;
   TPixelRGBAByteData = record
      r,g,b,a: byte;
   end;
   TPixelRGBByteData = record
      r,g,b: byte;
   end;
   TPixelRGBLongData = record
      r,g,b: longword;
   end;
   TPixelRGBIntData = record
      r,g,b: integer;
   end;
   TPixelRGBALongData = record
      r,g,b,a: longword;
   end;
   TPixelRGBAIntData = record
      r,g,b,a: integer;
   end;

   TRenderProc = procedure of object;

implementation

end.
