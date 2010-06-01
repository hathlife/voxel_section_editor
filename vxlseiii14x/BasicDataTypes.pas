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

   TAVector4f = array of TVector4f;
   PAVector4f = ^TAVector4f;

   TVector3f = record
      X, Y, Z : single;
   end;

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

   TGLMatrixf4 = array[0..3, 0..3] of Single;

   T3DIntGrid = array of array of array of integer;
   P3DIntGrid = ^T3DIntGrid;
   T3DSingleGrid = array of array of array of single;
   P3DSingleGrid = ^T3DSingleGrid;

   PByte = ^Byte;
   AInt32 = array of integer;
   AUInt32 = array of longword;
   ABool = array of boolean;
   AFloat = array of single;
   TByteMap = array of array of byte;
   TInt32Map = array of AInt32;
   TAByteMap = array of TByteMap;
   TABitmap = array of TBitmap;
   TScreenshotType = (stNone,stBmp,stTga,stJpg,stGif,stPng,stDDS);


implementation

end.
