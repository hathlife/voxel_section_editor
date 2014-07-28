unit BasicVXLSETypes;

interface

uses Graphics, ExtCtrls, StdCtrls, Menus, BasicMathsTypes;

type
   PPaintBox = ^TPaintBox;
   PLabel = ^TLabel;
   PMenuItem = ^TMenuItem;

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

   TSitesList = array of packed record
      SiteName : string;
      SiteUrl : string;
   end;


implementation

end.
