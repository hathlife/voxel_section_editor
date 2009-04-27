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

   TVector3i = record
      X, Y, Z : integer;
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

   TColourSchemes = array of packed record
        Name,Filename,By,Website : string;
        Data : array [0..255] of byte;
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
   TGLMatrixf4 = array[0..3, 0..3] of Single;

   T3DIntGrid = array of array of array of integer;

implementation

end.
