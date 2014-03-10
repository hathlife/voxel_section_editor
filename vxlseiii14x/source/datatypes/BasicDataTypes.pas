unit BasicDataTypes;

interface

uses Graphics, BasicMathsTypes;

type
   PIntegerItem = ^TIntegerItem;
   TIntegerItem = record
      Value : integer;
      Next : PIntegerItem;
   end;

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
   APointer = array of Pointer;

   TDistanceUnit = record
      x,
      y,
      z,
      Distance : single;
   end;

   TBinaryMap = array of array of array of single; //byte;
   T3DBooleanMap = array of array of array of boolean;
   TDistanceArray = array of array of array of TDistanceUnit; //single;
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

implementation

end.
