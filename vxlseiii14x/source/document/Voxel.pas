unit Voxel;

interface

uses
   Classes, dglOpenGL, Normals, BasicMathsTypes, BasicDataTypes, BasicVXLSETypes,
   BasicFunctions, BasicConstants;

{$INCLUDE source/Global_Conditionals.inc}

type
   TVoxelHeader = packed record
      FileType: packed array[1..16] of Char; // always "Voxel Animation"
      NumPalettes, // always 1
      NumSections,
      NumSections2,
      BodySize: LongInt; // as above
      StartPaletteRemap,
      EndPaletteRemap: Byte; // colour indexes
      PaletteData: packed array[1..256*3] of Byte; // never used
   end;

   TVoxelSectionHeader = packed record
      Name: array[1..16] of Char; // ASCIIZ
      Number, // ordinal
      Unknown1, // always 1
      Unknown2: LongInt; // always 2
   end;

   TVoxelSectionTailer = packed record
      SpanStartOfs,
      SpanEndOfs,
      SpanDataOfs: LongInt;
      Det: Single;
      Transform: packed array[1..3,1..4] of Single;
      MinBounds, MaxBounds: packed array[1..3] of Single;
      XSize,
      YSize,
      ZSize,
      NormalsType: Byte; // always 2 (or 4?); possibly normals-encoding scheme selection
   end;

   TVoxelView = class; // forward dec

   TVoxelSection = class
   private
      // for storing / accessing the stored data
      procedure InitViews;
      procedure SetDataSize(_XSize, _YSize, _ZSize: Integer);
      procedure DefaultTransforms;
      function PackVoxel(const _Unpacked: TVoxelUnpacked): TVoxelPacked;
      procedure UnpackVoxel(const _PackedVoxel: TVoxelPacked; var _Dest: TVoxelUnpacked);
   public
      spectrum: ESpectrumMode;
      Data: array of array of array of TVoxelPacked; // as is 32-bit type, should be packed anyway
      Normals : TNormals; // Normals palette.
      MaxNormal, // the highest normal value
      X, Y, Z: Integer; // cursor location
      // other
      Header: TVoxelSectionHeader;
      Tailer: TVoxelSectionTailer;
      View: array[0..2] of TVoxelView;
      Viewport: array[0..2] of TViewport; // so that each window can have a unique zoom etc
      Thumb: array[0..2] of TThumbnail;
      ThumbVisible: array[0..2] of Boolean; // does not rotate with viewport changes
      constructor Create(); overload;
      constructor Create(const _Name: string; _Number, _XSize,_YSize,_ZSize: Integer); overload;
      constructor Create(const _VoxelSection : TVoxelSection); overload;
      destructor Destroy; override;
      procedure Resize(_XSize,_YSize,_ZSize: Integer);
      function ResizeUpdateBounds(var _MinPosition, _MaxPosition: TVector3f): boolean;
      procedure Crop;
      procedure ReCreate(const _Name: string; _Number, _XSize,_YSize,_ZSize: Integer);
	//Plasmadroid v1.4+ drawing tools
      //View-fix, combined with RectangleFill (for shorter code, less bugs :)
      procedure Rectangle(_Xpos,_Ypos,_Zpos,_Xpos2,_Ypos2,_Zpos2:Integer; _v: TVoxelUnpacked; _Fill: Boolean);
      //Replaced: it now uses the Rectangle code
//        procedure RectangleFill(Xpos,Ypos,Zpos,Xpos2,Ypos2,Zpos2:Integer; v: TVoxelUnpacked);
      //Fixed BrushTool
      procedure BrushTool(_Xc,_Yc,_Zc: Integer; _V: TVoxelUnpacked; _BrushMode: Integer; _BrushView: EVoxelViewOrient);
      //TODO: FIX
      procedure FloodFillTool(_Xpos,_Ypos,_Zpos: Integer; _v: TVoxelUnpacked; _EditView: EVoxelViewOrient);
      //blow-up tool for content resizing
      procedure ResizeBlowUp(_Scale: Integer);
      procedure setSpectrum(_newspectrum: ESpectrumMode);
      // viewport cursor
      procedure SetX(_newX: Integer);
      procedure SetY(_newY: Integer);
      procedure SetZ(_newZ: Integer);
      procedure Clear; // blanks the entire voxel model
      procedure SetVoxel(_x,_y,_z: Integer; const _src: TVoxelUnpacked);
      procedure GetVoxel(_x,_y,_z: Integer; var _dest: TVoxelUnpacked);
      function GetVoxelSafe(_x,_y,_z: Integer; var _dest: TVoxelUnpacked): Boolean;
      // loading and saving
      function LoadFromFile(var _F: File; _HeadOfs, _BodyOfs, _TailOfs : Integer): EError;
//    function SaveToFileHeader(var F: File): EError;
      function SaveToFileBody(var _F: File): EError;
 //   function SaveToFileTailer(var F: File): EError;
      procedure OpenGLToWestwoodCoordinates;
      procedure WestwoodToOpenGLCoordinates;

      // utility methods
      function Name: string;
      // new by Koen
      procedure SetHeaderName(const _Name: String);

      //New undo system by Koen - SaveUndoDump - saves data to an undo stream
      procedure SaveUndoDump(var _fs: TStream);
      //loads data of this voxel section from a stream
      procedure LoadUndoDump(var _fs: TStream);

      //a directional and a positional vector (x,y,z)=PosVector+t*DirectionVector
      procedure FlipMatrix(const _VectorDir, _VectorPos: Array of Single; _Multiply: Boolean=True);
      procedure Mirror(_MirrorView: EVoxelViewOrient);
      procedure ApplyMatrix(const _Matrix: TGLMatrixf4; _ResizeModel: Boolean = false);  overload;
      procedure ApplyMatrix(const _Matrix: TGLMatrixf4; _Pivot: TVector3f; _ResizeModel: Boolean = false);  overload;

      procedure Assign(const _VoxelSection : TVoxelSection);
      function GetTransformAsOpenGLMatrix : TGlmatrixf4;
   end;
   PVoxelSection = ^TVoxelSection;

   TVoxel = class
   public
      Loaded: Boolean;
      ErrorCode: EError; // if an error, says what it is
      ErrorMsg, // if an error, says what it is
      Filename: string;
      Header: TVoxelHeader;
      Section: array of TVoxelSection;
      constructor Create; overload;
      constructor Create(const _Voxel: TVoxel); overload;
      destructor Destroy; override;
      procedure LoadFromFile(const _Fname: string); // examine ErrorCode for success
      procedure SaveToFile(const _Fname: string); // examine ErrorCode for success
      function isOpen: Boolean;
      procedure setSpectrum(_newspectrum: ESpectrumMode);
      procedure InsertSection(_SectionIndex: Integer; const _Name: String; _XSize,_YSize,_ZSize: Integer);
      procedure RemoveSection(_SectionIndex: Integer);
      procedure Assign(const _Voxel: TVoxel);
   end;
   PVoxel = ^TVoxel;

   TVoxelViewCell = packed record
      Colour: Word; // 16-bits; 256 is transparent
      Depth: Byte; // a z-buffer
   end;

   TVoxelView = class
   private
      Orient: EVoxelViewOrient;
      Dir: EVoxelViewDir;
      swapX, swapY, swapZ: boolean; // are these inversed for viewing?
      procedure CreateCanvas;
      procedure Clear;
      procedure CalcSwapXYZ;
   public
      Foreground, // the Depth in Canvas[] that is the active slice
      Width, Height: Integer;
      Canvas: {packed} array of {packed} array of TVoxelViewCell;
      Voxel: TVoxelSection; // owner
      constructor Create(const _Owner: TVoxelSection; _o: EVoxelViewOrient; _d: EVoxelViewDir);
      destructor Destroy; override;
      function getViewNameIdx: Integer;
      function getDir: EVoxelViewDir;
      function getOrient: EVoxelViewOrient;
      procedure TranslateClick(_i, _j: Integer; var _X, _Y, _Z: Integer);
      procedure getPhysicalCursorCoords(var _X, _Y: integer);
      procedure setDir(_newdir: EVoxelViewDir);
      procedure Refresh; // like a paint on the canvas
      procedure Assign(const _VoxelView : TVoxelView);
   end;

   var
      VoxelType: TVoxelType;


   function AsciizToStr(var _src: array of Char; _maxlen: Byte): string;

implementation

uses
   SysUtils, Math, Dialogs, CholeskySolver;

function AsciizToStr(var _src: array of Char; _maxlen: Byte): string;
var
   ch: Char;
   i: Integer;
begin
   SetLength(Result,_maxlen);
   for i := 1 to _maxlen do
   begin
      ch := _src[i-1];
      if Ord(ch) = 0 then
      begin
         SetLength(Result,i-1);
         Break;
      end;
      Result[i] := ch;
   end;
end;

procedure DebugMsg(const _Msg: string; _Typ: TMsgDlgType);
begin
   // in this version, just show a messsage box for the user
   if (MessageDlg('Debug:' + Chr(10) + _Msg,_Typ,[mbOK,mbCancel],0) > 0) then
      Halt;
end;

(*** TVoxelSection members *********************************************)

// Min/MaxBounds Fixed! - Stucuk
procedure TVoxelSection.DefaultTransforms;
const
   C_WWDET = 1/12;
var
   i, j: integer;
begin
   Tailer.Det := C_WWDET;

   for i := 1 to 3 do
      for j := 1 to 3 do // from memory, don't think this transform is ever used.
         if i = j then
            Tailer.Transform[i,j] := 1
         else
            Tailer.Transform[i,j] := 0;

   Tailer.MaxBounds[1] := (Tailer.XSize / 2);
   Tailer.MaxBounds[3] := (Tailer.ZSize / 2);
   Tailer.MinBounds[1] := 0 - (Tailer.XSize / 2);
   Tailer.MinBounds[3] := 0 - (Tailer.ZSize / 2);

   if VoxelType = vtAir then
   begin
      Tailer.MaxBounds[2] := (Tailer.YSize / 2);
      Tailer.MinBounds[2] := 0 - (Tailer.YSize / 2);
   end
   else
   begin
      Tailer.MaxBounds[2] := Tailer.YSize;
      Tailer.MinBounds[2] := 0;
   end;
end;

procedure TVoxelSection.Resize(_XSize,_YSize,_ZSize: Integer);
begin
   // memory alloc
   SetDataSize(_XSize, _YSize, _ZSize); // will preserve contents where possible I believe
   // set tailer
   Tailer.XSize := _XSize;
   Tailer.YSize := _YSize;
   Tailer.ZSize := _ZSize;
   DefaultTransforms;
   // and (re)create views
   InitViews;
end;

procedure TVoxelSection.InitViews;
var
   i: integer;
begin
   // deallocate memory for old views
   for i := 0 to 2 do
      //Viewport[i].Free;
      View[i].Free;
   // cursor is by default in the middle of the voxel
   X := (Tailer.XSize div 2);
   Y := (Tailer.YSize div 2);
   Z := (Tailer.ZSize div 2);
   // set views
   View[0] := TVoxelView.Create(Self,oriZ,dirTowards);
   View[1] := TVoxelView.Create(Self,oriX,dirAway);
   View[2] := TVoxelView.Create(Self,oriY,dirAway);
   for i := 0 to 2 do
   begin
      with ViewPort[i] do
      begin
         Top := 0;
         Left := 0;
         Zoom := 15;
         hasBeenUsed := False; // so will zoom-to-fit first use
      end;
      with Thumb[i] do
      begin
         Width := Min(Max(View[i].Width,50),150);
         Height := Min(Max(View[i].Height,50),150);
         if Width > Height then // aspect ratio
            Height := Ceil(Width * (View[i].Height / View[i].Width))
         else
            Width := Ceil(Height * (View[i].Width / View[i].Height));
         ThumbVisible[i] := False;
      end;
   end;
end;

function TVoxelSection.GetTransformAsOpenGLMatrix : TGlmatrixf4;
begin
   Result[0,0] := Tailer.Transform[1,1];
   Result[0,1] := Tailer.Transform[2,1];
   Result[0,2] := Tailer.Transform[3,1];
   Result[0,3] := 0;

   Result[1,0] := Tailer.Transform[1,2];
   Result[1,1] := Tailer.Transform[2,2];
   Result[1,2] := Tailer.Transform[3,2];
   Result[1,3] := 0;

   Result[2,0] := Tailer.Transform[1,3];
   Result[2,1] := Tailer.Transform[2,3];
   Result[2,2] := Tailer.Transform[3,3];
   Result[2,3] := 0;

   Result[3,0] := Tailer.Transform[1,4];
   Result[3,1] := Tailer.Transform[2,4];
   Result[3,2] := Tailer.Transform[3,4];
   Result[3,3] := 1;
end;

procedure TVoxelSection.SetHeaderName(const _Name: String);
const
   MAX_LEN = 15;
var
   i: integer;
begin
   for i:=1 to 16 do
      Header.Name[i] := #0;
   for i := 1 to Length(_Name) do
   begin
      if i > MAX_LEN then
         break;
      Header.Name[i] := _Name[i];
   end;
end;

constructor TVoxelSection.Create(const _Name: string; _Number, _XSize,_YSize,_ZSize: Integer);
begin
   // create header
   SetHeaderName(_Name);
   Header.Number := _Number;
   Header.Unknown1 := 1; // TODO: review if this is correct in all cases etc
   Header.Unknown2 := 2; // TODO: review if this is correct in all cases etc
   Tailer.NormalsType := 2; // or 4 in RA2?  TODO: review if this is correct in all cases etc
   Normals := TNormals.Create(2);

   Tailer.Det:=1/12; //oops, forgot to set Det part correctly

   // allocate the memory
   Resize(_XSize,_YSize,_ZSize);
   // clear it
   Clear;
end;

procedure TVoxelSection.Assign(const _VoxelSection : TVoxelSection);
var
   i,x,y,z : integer;
begin
   // Copy Header.
   for i := Low(Header.Name) to High(Header.Name) do
      Header.Name[i] := _VoxelSection.Header.Name[i];
   Header.Number := _VoxelSection.Header.Number;
   Header.Unknown1 := _VoxelSection.Header.Unknown1;
   Header.Unknown2 := _VoxelSection.Header.Unknown2;
   // Copy Tailer.
   Tailer.SpanStartOfs := _VoxelSection.Tailer.SpanStartOfs;
   Tailer.SpanEndOfs := _VoxelSection.Tailer.SpanEndOfs;
   Tailer.SpanDataOfs := _VoxelSection.Tailer.SpanDataOfs;
   Tailer.Det := _VoxelSection.Tailer.Det;
   for i := 1 to 3 do
   begin
      Tailer.Transform[i,1] := _VoxelSection.Tailer.Transform[i,1];
      Tailer.Transform[i,2] := _VoxelSection.Tailer.Transform[i,2];
      Tailer.Transform[i,3] := _VoxelSection.Tailer.Transform[i,3];
      Tailer.Transform[i,4] := _VoxelSection.Tailer.Transform[i,4];
   end;
   for i := 1 to 3 do
   begin
      Tailer.MinBounds[i] := _VoxelSection.Tailer.MinBounds[i];
      Tailer.MaxBounds[i] := _VoxelSection.Tailer.MaxBounds[i];
   end;
   Tailer.XSize := _VoxelSection.Tailer.XSize;
   Tailer.YSize := _VoxelSection.Tailer.YSize;
   Tailer.ZSize := _VoxelSection.Tailer.ZSize;
   Tailer.NormalsType := _VoxelSection.Tailer.NormalsType;
   Normals.SwitchNormalsType(Tailer.NormalsType);
   SetDataSize(Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   // Copy Data
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
         begin
            Data[x,y,z] := _VoxelSection.Data[x,y,z];
         end;
   // Copy anything else.
   spectrum := _VoxelSection.spectrum;
   MaxNormal := _VoxelSection.MaxNormal;
   Self.X := _VoxelSection.X;
   Self.Y := _VoxelSection.Y;
   Self.Z := _VoxelSection.Z;
   for i := 0 to 2 do
   begin
      View[i].Free;
      View[i] := TVoxelView.Create(self,_VoxelSection.View[i].Orient, _VoxelSection.View[i].getDir);
      View[i].Assign(_VoxelSection.View[i]);
      View[i].Voxel := self;
      Viewport[i].Left := _VoxelSection.Viewport[i].Left;
      Viewport[i].Top := _VoxelSection.Viewport[i].Top;
      Viewport[i].Zoom := _VoxelSection.Viewport[i].Zoom;
      Viewport[i].hasBeenUsed := _VoxelSection.Viewport[i].hasBeenUsed;
      Thumb[i].Width := _VoxelSection.Thumb[i].Width;
      Thumb[i].Height := _VoxelSection.Thumb[i].Height;
      ThumbVisible[i] := _VoxelSection.ThumbVisible[i];
   end;
end;

constructor TVoxelSection.Create;
begin
   Normals := TNormals.Create(2);
end;

constructor TVoxelSection.Create(const _VoxelSection : TVoxelSection);
begin
   Normals := TNormals.Create(2);
   Assign(_VoxelSection);
end;

procedure TVoxelSection.ReCreate(const _Name: string; _Number, _XSize,_YSize,_ZSize: Integer);
begin
   // create header
   SetHeaderName(_Name);
   Header.Number := _Number;
   Header.Unknown1 := 1; // TODO: review if this is correct in all cases etc
   Header.Unknown2 := 2; // TODO: review if this is correct in all cases etc
   Tailer.NormalsType := 2; // or 4 in RA2?  TODO: review if this is correct in all cases etc
   Normals := TNormals.Create(2);

   Tailer.Det:=1/12; //oops, forgot to set Det part correctly

   // allocate the memory
   Resize(_XSize, _YSize, _ZSize);
   // clear it
   Clear;
end;


destructor TVoxelSection.Destroy;
var
   i: integer;
begin
   Normals.Free;
   SetDataSize(0,0,0);
   for i := 0 to 2 do
      View[i].Free;
   inherited Destroy;
end;


function TVoxelSection.Name: string;
begin
   Result := AsciizToStr(Header.Name,16);
end;

procedure TVoxelSection.SetX(_newX: Integer);
begin
   X := Max(Min(_newX,Tailer.XSize-1),0);
end;

procedure TVoxelSection.SetY(_newY: Integer);
begin
   Y := Max(Min(_newY,Tailer.YSize-1),0);
end;

procedure TVoxelSection.SetZ(_newZ: Integer);
begin
   Z := Max(Min(_newZ,Tailer.ZSize-1),0);
end;

function TVoxelSection.PackVoxel(const _Unpacked: TVoxelUnpacked): TVoxelPacked;
begin
   Result := _Unpacked.Flags shl 16;
   if _Unpacked.Used then
      Result := Result or $100 or _Unpacked.Colour
   else
      Result := Result or _Unpacked.Colour;
   Result := Result shl 8;
   Result := Result or _Unpacked.Normal;
end;

procedure TVoxelSection.UnpackVoxel(const _PackedVoxel: TVoxelPacked; var _Dest: TVoxelUnpacked);
begin
   _Dest.Normal := (_PackedVoxel and $000000FF);
   _Dest.Colour := (_PackedVoxel and $0000FF00) shr 8;
   _Dest.Used :=   (_PackedVoxel and $00010000) > 0;
   _Dest.Flags :=  (_PackedVoxel and $FF000000) shr 24;
end;

procedure TVoxelSection.Clear; // blanks the entire voxel model
var
   x, y, z: Integer;
   Empty: TVoxelUnpacked;
   PackedVoxel: TVoxelPacked;
begin
// prepare empty voxel
   with Empty do
   begin
      Colour := 0;
      Normal := 0;
      Used := False;
   end;
   PackedVoxel := PackVoxel(Empty);
   Normals.Clear;
// and set each and every voxel
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            Data[x,y,z] := PackedVoxel;
end;

procedure TVoxelSection.SetDataSize(_XSize, _YSize, _ZSize: Integer);
var
   x, y: Integer;
begin
   // 1.71: Let's clear the memory from the stuff after XSize.
   if (High(Data) >= _XSize) then
   begin
      for x := _XSize to High(Data) do
      begin
         for y := 0 to High(Data[x]) do
         begin
            SetLength(Data[x,y],0);
         end;
         SetLength(Data[x],0);
      end;
   end;
   // Old code continues here.
   SetLength(Data,_XSize);
   for x := 0 to (_XSize - 1) do
   begin
      // 1.71: Let's clear the memory stuff after YSize
      if (High(Data[x]) >= _YSize) then
      begin
         for y := _YSize to High(Data[x]) do
         begin
            SetLength(Data[x,y],0);
         end;
      end;
      // Old code continues here.
      SetLength(Data[x],_YSize);
      for y := 0 to (_YSize - 1) do
         SetLength(Data[x,y],_ZSize);
   end;
end;

//This catches the crashes!
{$RANGECHECKS ON}
procedure TVoxelSection.SetVoxel(_x,_y,_z: Integer; const _Src: TVoxelUnpacked);
begin
   Data[_x,_y,_z] := PackVoxel(_Src);
end;

procedure TVoxelSection.GetVoxel(_x,_y,_z: Integer; var _Dest: TVoxelUnpacked);
begin
   UnpackVoxel(Data[_x,_y,_z],_Dest);
end;

function TVoxelSection.GetVoxelSafe(_x,_y,_z: Integer; var _Dest: TVoxelUnpacked): Boolean;
begin
   Result := False;
   if (_x >= 0) and (_x < Tailer.XSize) and (_y >= 0) and (_y < Tailer.YSize) and (_z >= 0) and (_z < Tailer.ZSize) then
   begin
      UnpackVoxel(Data[_x,_y,_z],_Dest);
      Result := true;
   end;
end;

{$OPTIMIZATION OFF}
{$RANGECHECKS ON}

function TVoxelSection.LoadFromFile(var _F: File; _HeadOfs, _BodyOfs, _TailOfs : Integer): EError;
var
   BytesToRead,
   BytesRead,
   i, SpanCount, Ofs,
   x, y, z,
   voxel_num, num_voxels,
   SpanDataLen: Integer;
   UnpackedVoxel: TVoxelUnpacked;
   SpanStart, SpanEnd: packed array of LongInt;
   SpanData: packed array of Byte; // the raw data

   procedure CleanUp(_Err: Boolean);
   begin
      SetLength(SpanData,0);
      SetLength(SpanEnd,0);
      SetLength(SpanStart,0);
      if _Err then
         SetDataSize(0,0,0);
   end;

begin
   MaxNormal := 0;
   try
      Result := OK; // assume ok
// read in tailer first
      Seek(_F,_TailOfs); // move to tail offset
      BytesToRead := SizeOf(TVoxelSectionTailer);
      BlockRead(_F,Tailer,BytesToRead,BytesRead);
      if (BytesToRead <> BytesRead) then
      begin
         Result := ReadFailed;
         CleanUp(true);
         Exit;
      end;
      {with Tailer do
          DebugMsg('Size = [' + IntToStr(XSize) + ',' + IntToStr(YSize) + ',' + IntToStr(ZSize) + ']',mtInformation);}
// read in head next
      Seek(_F,_HeadOfs);
      BytesToRead := SizeOf(TVoxelSectionHeader);
      BlockRead(_F,Header,BytesToRead,BytesRead);
      if (BytesToRead <> BytesRead) then
      begin
         Result := ReadFailed;
         CleanUp(True);
         Exit;
      end;
{$IFDEF DEBUG_NORMALS}
      DebugMsg('Header.Section name is : ' + Chr(10) + '[' + AsciizToStr(Header.Name,16) + ']' + Chr(10) +
        'Header.Number is : ' + IntToStr(Header.Number) + Chr(10) +
        'Header.Unknown1 is : ' + IntToStr(Header.Unknown1) + Chr(10) +
        'Header.Unknown2 is : ' + IntToStr(Header.Unknown2) + Chr(10) +
        'Tailer.NormalsType is : ' + IntToStr(Tailer.NormalsType)
        ,mtInformation);
{$ENDIF}
// create memory for storing the actual voxels; note the creation order
      with Tailer do
      begin
         SetDataSize(XSize,YSize,ZSize);
         Clear; // empty data
         SpanCount := XSize * YSize;
      end;
      SetLength(SpanStart,SpanCount);
      SetLength(SpanEnd,SpanCount);
      // read in the span start offsets
      Seek(_F,_BodyOfs + Tailer.SpanStartOfs);
      BytesToRead := SpanCount * SizeOf(LongInt);
      BlockRead(_F,SpanStart[0],BytesToRead,BytesRead);
      if (BytesToRead <> BytesRead) then
      begin
         Result := ReadFailed;
         CleanUp(True);
         Exit;
      end;
      Seek(_F,_BodyOfs + Tailer.SpanEndOfs);
      BlockRead(_F,SpanEnd[0],BytesToRead,BytesRead);
      if (BytesToRead <> BytesRead) then
      begin
         Result := ReadFailed;
         CleanUp(True);
         Exit;
      end;
      // and load the spans data into a buffer to be parsed
      // find last span end
      i := SpanCount - 1;
      while (SpanEnd[i] = -1) and (i > 0) do
         Dec(i);
      SpanDataLen := SpanEnd[i];
      // find first span end
      i := 0;
      while (SpanStart[i] = -1) and ((i+1) < SpanCount) do
         Inc(i);
      Dec(SpanDataLen,SpanStart[i]);
      Inc(SpanDataLen); // safety
      if SpanDataLen < 1 then
      begin
         Result := InvalidSpanDataSizeCalced;
         CleanUp(True);
         Exit;
      end;
      SetLength(SpanData,SpanDataLen);
      BlockRead(_F,SpanData[0],SpanDataLen,BytesRead);
      if (SpanDataLen <> BytesRead) then
      begin
         Result := ReadFailed;
         CleanUp(True);
         Exit;
      end;
      // Banshee's adition here:
      // -- Speed up operations and avoid future mistakes.
      if Tailer.NormalsType = 2 then
      begin
         Normals.SwitchNormalsType(2);
         MaxNormal := 35
      end
      else if Tailer.NormalsType = 4 then
      begin
         Normals.SwitchNormalsType(4);
         MaxNormal := 243;
      end;
      if Tailer.Det = 0 then
         Tailer.Det := 1;
      // -- End of Banshee's speed up operation.
      // and parse the spans
      i := -1; // will be inc'ed before anything else
      UnpackedVoxel.Used := True;
      for y := 0 to (Tailer.YSize - 1) do
      begin
         for x := 0 to (Tailer.XSize - 1) do
         begin
            Inc(i);
            if (SpanStart[i] = -1) or (SpanEnd[i] = -1) then // skip empty span?
               Continue;
            z := 0;
            Ofs := SpanStart[i];
            while (z < Tailer.ZSize) and (z < SpanEnd[i]) do
            begin
               // this is one z - span
               Inc(z,SpanData[Ofs]); Inc(Ofs); // skip count
               num_voxels := SpanData[Ofs]; Inc(Ofs);
               if (z >= Tailer.ZSize) then
                  Break;
               if (z + num_voxels > Tailer.ZSize) then
                  DebugMsg('Err',mtError);
               for voxel_num := 1 to num_voxels do
               begin
                  with UnpackedVoxel do
                  begin
                     Colour := SpanData[Ofs]; Inc(Ofs);
                     Normal := SpanData[Ofs]; Inc(Ofs);
                     // Banshee: I've changed this, so it avoids
                     // invalid normal values to be placed when
                     // the file loads
                     if (Normal > MaxNormal) then
                        Normal := MaxNormal;
                  end;
                  SetVoxel(x,y,z,UnpackedVoxel);
                  Inc(z);
               end;
               // check second span number
               voxel_num := SpanData[Ofs]; Inc(Ofs);
               if voxel_num <> num_voxels then
               begin
                  Result := BadSpan_SecondVoxelCount;
                  CleanUp(True);
                  Exit;
               end;
            end;
         end;
      end;
{$IFDEF DEBUG_NORMALS}
      DebugMsg('Max normals = ' + IntToStr(MaxNormal),mtInformation);
{$ENDIF}
      WestwoodToOpenGLCoordinates;
    // done
   except
      Result := Unhandled_Exception;
      CleanUp(True);
   end;
   InitViews;
   // done
   CleanUp(False);
end;

function TVoxelSection.SaveToFileBody(var _F: File): EError;
const
   MaskUsed: TVoxelPacked = $00010000;

   function SpanUsed(_x, _y: integer): boolean;
   var
      z: integer;
   begin
      Result := True; // assume it is
      for z := 0 to (Tailer.ZSize - 1) do
         if (Data[_x,_y,z] and MaskUsed) > 0 then // used flag set?
            Exit;
      Result := False; // if here, span wasn't used after all
   end;

   function SpanLength(_x,_y,_z: integer): integer;
   var
      v: TVoxelPacked;
   begin
      Result := 0;
      while _z < Tailer.ZSize do
      begin
         v := Data[_x,_y,_z];
         if (v and MaskUsed) > 0 then
            Inc(Result)
         else
            Exit;
         Inc(_z);
      end;
   end;
var
   FSpanStart, FSpanEnd, FBody,
   SpanStart, SpanEnd: LongInt;
   x, y, z, SpanSize, s: integer;
   v: TVoxelPacked;
   skip, spanlen, colour, normal: byte;
begin
   // work out offsets
   FBody := FilePos(_F);
   SpanSize := Tailer.XSize * Tailer.YSize * SizeOf(LongInt);
   FSpanEnd := FBody - SpanSize;
   FSpanStart := FSpanEnd - SpanSize;
   // and save some info now to the tailer
   Tailer.SpanStartOfs := FSpanStart;
   Tailer.SpanEndOfs := FSpanEnd;
   Tailer.SpanDataOfs := FBody;
   for y := 0 to (Tailer.YSize - 1) do
      for x := 0 to (Tailer.XSize - 1) do
      begin
         if not SpanUsed(x,y) then
         begin
            SpanStart := -1;
            SpanEnd := -1;
         end
         else
         begin
            SpanStart := FilePos(_F) - Tailer.SpanDataOfs;
            skip := 0;
            z := 0;
            while z < (Tailer.ZSize) do
            begin
               spanlen := SpanLength(x,y,z);
               if (spanlen > 0) then
               begin
                  BlockWrite(_F,skip,1); // write skip
                  BlockWrite(_F,spanlen,1); // write span length again
                  for s := 1 to spanlen do
                  begin
                     v := Data[x,y,z + s - 1]; // get voxel
                     colour := (v and $0000FF00) shr 8;
                     normal := (v and $000000FF);
                     BlockWrite(_F,colour,1);
                     BlockWrite(_F,normal,1);
                  end;
                  BlockWrite(_F,spanlen,1); // write span length again
                  Inc(z,spanlen);
                  skip := 0;
               end
               else
               begin
                  Inc(skip);
                  Inc(z);
               end;
            end;
            if skip > 0 then
            begin // write a dummy?
               BlockWrite(_F,skip,1);
               spanlen := 0;
               BlockWrite(_F,spanlen,1);
               BlockWrite(_F,spanlen,1);
            end;
            SpanEnd := FilePos(_F) - Tailer.SpanDataOfs - 1;
         end;
         // write span data
         FBody := FilePos(_F);
         Seek(_F,FSpanStart);
         BlockWrite(_F,SpanStart,SizeOf(SpanStart));
         Inc(FSpanStart,SizeOf(SpanStart));
         Seek(_F,FSpanEnd);
         BlockWrite(_F,SpanEnd,SizeOf(SpanEnd));
         Inc(FSpanEnd,SizeOf(SpanEnd));
         Seek(_F,FBody); //return to span data
      end;
   Result := OK;
end;

// Westwood's coordinate system is different than OpenGL's.
// So, we'll turn (x,y,z) into (y,z,x)
procedure TVoxelSection.OpenGLToWestwoodCoordinates;
var
   x,y,z : integer;
   temp : byte;
   TempBound : single;
   TempInt : integer;
   TempData : array of array of array of TVoxelPacked;
begin
   // backup data.
   SetLength(TempData,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            TempData[x,y,z] := Data[x,y,z];
   // switch Tailer.Sizes
   temp := Tailer.XSize;
   Tailer.XSize := Tailer.ZSize;
   Tailer.ZSize := Tailer.YSize;
   Tailer.YSize := temp;
   // switch data.
   SetDataSize(Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            Data[x,y,z] := TempData[y,z,x];
   // Switch Bounds;
   TempBound := Tailer.MinBounds[1];
   Tailer.MinBounds[1] := Tailer.MinBounds[3];
   Tailer.MinBounds[3] := Tailer.MinBounds[2];
   Tailer.MinBounds[2] := TempBound;
   TempBound := Tailer.MaxBounds[1];
   Tailer.MaxBounds[1] := Tailer.MaxBounds[3];
   Tailer.MaxBounds[3] := Tailer.MaxBounds[2];
   Tailer.MaxBounds[2] := TempBound;
   // Switch X, Y, Z
   TempInt := Self.X;
   Self.X := Self.Z;
   Self.Z := Self.Y;
   Self.Y := TempInt;
   // Cleanup TempData
   for x := Low(TempData) to High(TempData) do
   begin
      for y := Low(TempData[x]) to High(TempData[x]) do
      begin
         SetLength(TempData[x,y],0);
      end;
      SetLength(TempData[x],0);
   end;
   SetLength(TempData,0);
end;

// Do exactly the opposite of PrepareToSave()
procedure TVoxelSection.WestwoodToOpenGLCoordinates;
var
   x,y,z : integer;
   temp : byte;
   TempInt : integer;
   TempBound : single;
   TempData : array of array of array of TVoxelPacked;
begin
   // backup data.
   SetLength(TempData,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            TempData[x,y,z] := Data[x,y,z];
   // switch Tailer.Sizes
   temp := Tailer.XSize;
   Tailer.XSize := Tailer.YSize;
   Tailer.YSize := Tailer.ZSize;
   Tailer.ZSize := temp;
   // switch data.
   SetDataSize(Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            Data[x,y,z] := TempData[z,x,y];
   // Switch Bounds;
   TempBound := Tailer.MinBounds[1];
   Tailer.MinBounds[1] := Tailer.MinBounds[2];
   Tailer.MinBounds[2] := Tailer.MinBounds[3];
   Tailer.MinBounds[3] := TempBound;
   TempBound := Tailer.MaxBounds[1];
   Tailer.MaxBounds[1] := Tailer.MaxBounds[2];
   Tailer.MaxBounds[2] := Tailer.MaxBounds[3];
   Tailer.MaxBounds[3] := TempBound;
   // Switch X, Y, Z
   TempInt := Self.X;
   Self.X := Self.Y;
   Self.Y := Self.Z;
   Self.Z := TempInt;
   // Cleanup TempData
   for x := Low(TempData) to High(TempData) do
   begin
      for y := Low(TempData[x]) to High(TempData[x]) do
      begin
         SetLength(TempData[x,y],0);
      end;
      SetLength(TempData[x],0);
   end;
   SetLength(TempData,0);
end;


{$OPTIMIZATION ON}
{$RANGECHECKS OFF}

constructor TVoxel.Create;
begin
   ErrorCode := OK;
   Filename := '';
   Loaded := False;
end;

constructor TVoxel.Create(const _Voxel: TVoxel);
begin
   Assign(_Voxel);
end;

destructor TVoxel.Destroy;
var
   x : integer;
begin
   for x := High(Section) downto Low(Section) do
   begin
      RemoveSection(x);
   end;
   SetLength(Section,0);
   inherited Destroy;
end;

procedure TVoxel.LoadFromFile(const _FName: string);
var
   F: File;
   BytesToRead,
   BytesRead,
   i,
   HeadOfs, TailOfs, BodyOfs: Integer;
begin
     {DebugMsg(      'SizeOf(Header) = ' + IntToStr(SizeOf(Header)) + Chr(10) +
        'SizeOf(TVoxelSectionHeader) = ' + IntToStr(SizeOf(TVoxelSectionHeader)) + Chr(10) +
        'SizeOf(TVoxelSectionTailer) = ' + IntToStr(SizeOf(TVoxelSectionTailer)),mtInformation);}
   ErrorCode := OK;
   Loaded := False;
   try  // if file doesn't exist...
      Filename := _FName;
      // open voxel file to read
      AssignFile(F,Filename);
      FileMode := fmOpenRead; // read only
      Reset(F,1); // file of byte
      // read in main header
      BytesToRead := SizeOf(Header);
      BlockRead(F,Header,BytesToRead,BytesRead);
      if (BytesRead <> BytesToRead) then
      begin
         ErrorCode := ReadFailed;
         Showmessage('Error: Could not read Voxel Header');
         CloseFile(F);
         Exit;
      end;
      //DebugMsg('there are ' + IntToStr(Header.NumSections) + ' sections',mtInformation);
      // read in sections
      // prepare section objects
      SetLength(Section,Header.NumSections);
      for i := 1 to Header.NumSections do
         Section[i-1] := TVoxelSection.Create;
      HeadOfs := SizeOf(Header); // starts immediately after header
      BodyOfs := HeadOfs + (Header.NumSections * SizeOf(TVoxelSectionHeader)); // after all section headers
      TailOfs := BodyOfs + Header.BodySize; // last part of file
      // and load them
      for i := 1 to Header.NumSections do
      begin
         ErrorCode := Section[i-1].LoadFromFile(F,HeadOfs,BodyOfs,TailOfs);
         if (ErrorCode <> OK) then
         begin
            ErrorMsg := 'Could not read Voxel Section Tailer[' + IntToStr(i) + ']';
            DebugMsg(ErrorMsg,mtError);
            Exit;
         end;
         Inc(HeadOfs,SizeOf(TVoxelSectionHeader)); // next header
         // BodyOfs doesn't change, as relative offset is in tailer
         Inc(TailOfs,SizeOf(TVoxelSectionTailer)); // next tailer
      end;
      Loaded := True;
      CloseFile(F);
   except on E : EInOutError do // VK 1.36 U
      MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
   end;
end;

procedure TVoxel.SaveToFile(const _Fname: string);
{ First, we create the file.  We write blanks to represent the
  header. We then write the section headers.  We then encode the
  section bodies.  We then return to the section headers and
  write them, then the section tailers.  We then write the voxel
  header.
}
var
   F: File;
   BytesToWrite,
   BytesWritten: integer;

   function WriteBlank(_count: integer): EError;
   var
      i: integer;
      ch: byte;
   begin
      ch := 0;
      BytesToWrite := 1;
      for i := 1 to _count do
      begin
         BlockWrite(F,ch,BytesToWrite,BytesWritten);
         if (BytesWritten <> BytesToWrite) then
         begin
            Result := WriteFailed;
            Exit;
         end;
      end;
      Result := OK;
   end;
var
   i, BodyStart, BodyEnd: Integer;
begin
   if not Loaded then Exit; // cannot save an empty voxel?
   //-- when we save an empty voxel - this voxel will be unsupported - we must change this [Kamil ^aka Plasmadroid]
   ErrorCode := OK;
   try
      Filename := copy(_FName, 1, Length(_FName));
      // create voxel file to write
      AssignFile(F,Filename);
      FileMode := fmOpenWrite; // we save file, so write mode [VK]
      Rewrite(F,1); // file of byte
      // Prepare sections for save with Westwood's coordinate system
      for i := Low(Section) to High(Section) do
      begin
         Section[i].OpenGLToWestwoodCoordinates;
      end;
      // write main header (overwritten later)
      ErrorCode := WriteBlank(SizeOf(TVoxelHeader));
      if (ErrorCode <> OK) then
      begin
         ErrorMsg := 'Could not write Voxel Header (pass 2)';
         DebugMsg(ErrorMsg,mtError);
         Exit;
      end;
      // write section heads (real data)
      BytesToWrite := SizeOf(TVoxelSectionHeader);
      for i := 1 to Header.NumSections do
      begin
         BlockWrite(F,Section[Pred(i)].Header,BytesToWrite,BytesWritten);
         if (BytesWritten <> BytesToWrite) then
         begin
            ErrorCode := WriteFailed;
            ErrorMsg := 'Could not write Voxel Section Header #' + IntToStr(i) + '(pass 2)';
            DebugMsg(ErrorMsg,mtError);
            Exit;
         end;
      end;
      // write section bodies (real data)
      BodyStart := FilePos(F); // for later; could have calc'ed it instead
      for i := 0 to (Header.NumSections - 1) do
      begin
         with Section[i] do
         begin
            // first, write blank data where the span starts / ends will be
            ErrorCode := WriteBlank(Tailer.XSize*Tailer.YSize*4*2);
            if (ErrorCode <> OK) then
            begin
               ErrorMsg := 'Could not write Voxel Section Body #' + IntToStr(Succ(i)) + ' (pass 1)';
               DebugMsg(ErrorMsg,mtError);
               Exit;
            end;
            // now write the actual data
            ErrorCode := SaveToFileBody(F);
            if (ErrorCode <> OK) then
            begin
               ErrorMsg := 'Could not write Voxel Section Body #' + IntToStr(Succ(i)) + ' (pass 2)';
               DebugMsg(ErrorMsg,mtError);
               Exit;
            end;
         end;
      end;
      BodyEnd := FilePos(F); // for later; could have calc'ed it instead
      // write section tailers (real data)
      BytesToWrite := SizeOf(TVoxelSectionTailer);
      for i := 0 to (Header.NumSections - 1) do
      begin
         with Section[i].Tailer do
         begin
            Dec(SpanStartOfs,BodyStart);
            Dec(SpanEndOfs,BodyStart);
            Dec(SpanDataOfs,BodyStart);
         end;

         BlockWrite(F,Section[i].Tailer,BytesToWrite,BytesWritten);
         if (BytesWritten <> BytesToWrite) then
         begin
            ErrorCode := WriteFailed;
            ErrorMsg := 'Could not write Voxel Section Tailer #' + IntToStr(i) + '(pass 2)';
            DebugMsg(ErrorMsg,mtError);
            Exit;
         end;
      end;
      // write main header (real data)
      Seek(F,0); // go to start of file again
      Header.BodySize := BodyEnd - BodyStart;
      BytesToWrite := SizeOf(TVoxelHeader);
      BlockWrite(F,Header,BytesToWrite,BytesWritten);
      if (BytesWritten <> BytesToWrite) then
      begin
         ErrorMsg := 'Could not write Voxel Header (pass 2)';
         DebugMsg(ErrorMsg,mtError);
         Exit;
      end;
      CloseFile(F);
      // Fix coordinates system from the voxel for editing purposes
      for i := Low(Section) to High(Section) do
      begin
         Section[i].WestwoodToOpenGLCoordinates;
      end;
   except on E : EInOutError do // VK 1.36 U
		MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
   end;
end;

function TVoxel.isOpen: Boolean;
begin
  Result := Loaded;
end;

procedure TVoxel.Assign(const _Voxel: TVoxel);
var
   i : integer;
begin
   Loaded := _Voxel.Loaded;
   ErrorCode := _Voxel.ErrorCode;
   ErrorMsg := CopyString(_Voxel.ErrorMsg);
   Filename := _Voxel.Filename;
   for i := 1 to 16 do
      Header.FileType[i] := _Voxel.Header.FileType[i];
   Header.NumPalettes := _Voxel.Header.NumPalettes;
   Header.NumSections := _Voxel.Header.NumSections;
   Header.NumSections2 := _Voxel.Header.NumSections2;
   Header.BodySize := _Voxel.Header.BodySize;
   Header.StartPaletteRemap := _Voxel.Header.StartPaletteRemap;
   Header.EndPaletteRemap := _Voxel.Header.EndPaletteRemap;
   for i := 1 to 768 do
      Header.PaletteData[i] := _Voxel.Header.PaletteData[i];
   SetLength(Section,Header.NumSections);
   for i := Low(Section) to High(Section) do
   begin
      Section[i] := TVoxelSection.Create(_Voxel.Section[i]);
   end;
end;

(*** TVoxelView members *********************************************)

procedure TVoxelView.CreateCanvas;
var
   x: Integer;
begin
   with Voxel.Tailer do
   begin
      case Orient of
         oriX:
         begin
            Width := ZSize;
            Height := YSize;
         end;
         oriY:
         begin
            Width := ZSize;
            Height := XSize;
         end;
         oriZ:
         begin
            Width := XSize;
            Height := YSize;
         end;
      end;
   end;
   SetLength(Canvas,Width);
   for x := 0 to (Width - 1) do
      SetLength(Canvas[x],Height);
   //CalcIncs;
end;

procedure TVoxelView.Clear;
var
   x, y: Integer;
begin
   for x := 0 to (Width - 1) do
      for y := 0 to (Height - 1) do
         with Canvas[x,y] do
         begin
            Colour := VTRANSPARENT;
            Depth := 0; // far away
         end;
end;

constructor TVoxelView.Create(const _Owner: TVoxelSection; _o: EVoxelViewOrient; _d: EVoxelViewDir);
begin
   Voxel := _Owner;
   Orient := _o;
   Dir := _d;
   CreateCanvas;
   CalcSwapXYZ;
   Refresh;
end;

destructor TVoxelView.Destroy;
var
   x : integer;
begin
   for x := Low(Canvas) to high(Canvas) do
   begin
      SetLength(Canvas[x],0);
   end;
   SetLength(Canvas,0);
   finalize(Canvas);
   inherited Destroy;
end;

procedure TVoxelView.Assign(const _VoxelView : TVoxelView);
var
   i,j : integer;
begin
   Orient := _VoxelView.Orient;
   Dir := _VoxelView.Dir;
   swapX := _VoxelView.swapX;
   swapY := _VoxelView.swapY;
   swapZ := _VoxelView.swapZ;
   Foreground := _VoxelView.Foreground;
   Width := _VoxelView.Width;
   Height := _VoxelView.Height;
   Voxel := _VoxelView.Voxel;
   SetLength(Canvas,Width);
   for i := Low(Canvas) to High(Canvas) do
   begin
      SetLength(Canvas[i],Height);
      for j := Low(Canvas[i]) to High(Canvas[i]) do
      begin
         Canvas[i,j].Colour := _VoxelView.Canvas[i,j].Colour;
         Canvas[i,j].Depth := _VoxelView.Canvas[i,j].Depth;
      end;
   end;
end;


function TVoxelView.getViewNameIdx: Integer;
begin
   Result := 0;
   case Orient of
      oriX: Result := 0;
      oriY: Result := 2;
      oriZ: Result := 4;
   end;
   if Dir = dirAway then
      Inc(Result);
end;

procedure TVoxelView.Refresh;
   procedure DrawX;
   var
      x, y, z, // coords in model
      i, j: Integer; // screen coords
      v: TVoxelUnpacked;
      iFactor, iOp, jFactor, jOp: integer;
   begin
      Foreground := Voxel.X;
      if SwapZ then
      begin
         iFactor := Width - 1;
         iOp := -1;
      end
      else
      begin
         iFactor := 0;
         iOp := 1;
      end;
      if SwapY then
      begin
         jFactor := Height - 1;
         jOp := -1;
      end
      else
      begin
         jFactor := 0;
         jOp := 1;
      end;
      // increment on the x axis
      if Dir = dirTowards then
      begin
         for z := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               x := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Inc(x);
                  if x >= Voxel.Tailer.XSize then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := x;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end
      else
      begin // Dir = dirAway
         for z := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               x := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Dec(x);
                  if x < 0 then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := x;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end;
   end;
   procedure DrawY;
   var
      x, y, z, // coords in model
      i, j: Integer; // screen coords
      v: TVoxelUnpacked;
      iFactor, iOp, jFactor, jOp: integer;
   begin
      Foreground := Voxel.Y;
      if SwapZ then
      begin
         iFactor := Width - 1;
         iOp := -1;
      end
      else
      begin
         iFactor := 0;
         iOp := 1;
      end;
      if SwapX then
      begin
         jFactor := Height - 1;
         jOp := -1;
      end
      else
      begin
         jFactor := 0;
         jOp := 1;
      end;
      if Dir = dirTowards then
      begin
         for z := 0 to (Width - 1) do
            for x := 0 to (Height - 1) do
            begin
               y := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the y axis
               while not v.Used do
               begin
                  Inc(y);
                  if y >= Voxel.Tailer.YSize then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * x);
               with Canvas[i,j] do
               begin
                  Depth := y;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end
      else
      begin // Dir = dirAway
         for z := 0 to (Width - 1) do
            for x := 0 to (Height - 1) do
            begin
               y := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the y axis
               while not v.Used do
               begin
                  Dec(y);
                  if y < 0 then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * x);
               with Canvas[i,j] do
               begin
                  Depth := y;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end;
   end;
   procedure DrawZ;
   var
      x, y, z, // coords in model
      i, j: Integer; // screen coords
      v: TVoxelUnpacked;
      iFactor, iOp, jFactor, jOp: integer;
   begin
      Foreground := Voxel.Z;
      if SwapX then
      begin
         iFactor := Width - 1;
         iOp := -1;
      end
      else
      begin
         iFactor := 0;
         iOp := 1;
      end;
      if SwapY then
      begin
         jFactor := Height - 1;
         jOp := -1;
      end
      else
      begin
         jFactor := 0;
         jOp := 1;
      end;

      if Dir = dirTowards then
      begin
         for x := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               z := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the z axis
               while not v.Used do
               begin
                  Inc(z);
                  if z >= Voxel.Tailer.ZSize then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * x);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := z;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end
      else
      begin // Dir = dirAway
         for x := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               z := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the z axis
               while not v.Used do
               begin
                  Dec(z);
                  if z < 0 then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * x);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := z;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
         end;
   end;
begin
   case Orient of
      oriX: DrawX;
      oriY: DrawY;
      oriZ: DrawZ;
   end;
end;

procedure TVoxelView.TranslateClick(_i, _j: Integer; var _X, _Y, _Z: Integer);

   procedure TranslateX;
   begin
      _X := Foreground;
      if SwapZ then
         _Z := Width - 1 - _i
      else
         _Z := _i;
      if SwapY then
         _Y := Height - 1 - _j
      else
         _Y := _j;
   end;
   procedure TranslateY;
   begin
      if SwapZ then
         _Z := Width - 1 - _i
      else
         _Z := _i;
      _Y := Foreground;
      if SwapX then
         _X := Height - 1 - _j
      else
         _X := _j;
   end;

   procedure TranslateZ;
   begin
      if SwapX then
         _X := Width - 1 - _i
      else
         _X := _i;
      if SwapY then
         _Y := Height - 1 - _j
      else
         _Y := _j;
      _Z := Foreground;
  end;

begin
   case Orient of
      oriX: TranslateX;
      oriY: TranslateY;
      oriZ: TranslateZ;
   end;
end;

procedure TVoxelView.getPhysicalCursorCoords(var _X, _Y: integer);
   procedure TranslateX;
   begin
      if SwapZ then
         _X := Width - 1 - Voxel.Z
      else
         _X := Voxel.Z;
      if SwapY then
         _Y := Height - 1 - Voxel.Y
      else
         _Y := Voxel.Y;
   end;
   procedure TranslateY;
   begin
      if SwapZ then
         _X := Width - 1 - Voxel.Z
      else
         _X := Voxel.Z;
      if SwapX then
         _Y := Height - 1 - Voxel.X
      else
         _Y := Voxel.X;
   end;
   procedure TranslateZ;
   begin
      if SwapX then
         _X := Width - 1 - Voxel.X
      else
         _X := Voxel.X;
      if SwapY then
         _Y := Height - 1 - Voxel.Y
      else
         _Y := Voxel.Y;
   end;
begin
   case Orient of
      oriX: TranslateX;
      oriY: TranslateY;
      oriZ: TranslateZ;
   end;
end;

procedure TVoxelView.setDir(_newdir: EVoxelViewDir);
begin
   Dir := _newdir;
   CalcSwapXYZ;
   Refresh;
end;

function TVoxelView.getDir: EVoxelViewDir;
begin
   Result := Dir;
end;

function TVoxelView.getOrient: EVoxelViewOrient;
begin
   Result := Orient;
end;

procedure TVoxelSection.setSpectrum(_newspectrum: ESpectrumMode);
begin
   spectrum := _newspectrum;
end;

procedure TVoxelView.CalcSwapXYZ;
var idx: integer;
begin
   idx := getViewNameIdx;
   case idx of
      0:
      begin // Left to Right
         SwapX := False;
         SwapY := True;
         SwapZ := True;
      end;
      1:
      begin // Right to Left
         SwapX := False;
         SwapY := True;
         SwapZ := False;
      end;
      2:
      begin // Bottom to Top
         SwapX := False;
         SwapY := False;
         SwapZ := False;
      end;
      3:
      begin // Top to Bottom
         SwapX := True;
         SwapY := False;
         SwapZ := False;
      end;
      4:
      begin // Back to Front
         SwapX := True;
         SwapY := True;
         SwapZ := False;
      end;
      5:
      begin // Front to Back
         SwapX := False;
         SwapY := True;
         SwapZ := False;
      end;
   end;
end;

procedure TVoxelSection.Rectangle(_Xpos,_Ypos,_Zpos,_Xpos2,_Ypos2,_Zpos2:Integer; _v: TVoxelUnpacked; _Fill: Boolean);
type
   EOrientRect = (oriUnDef, oriX, oriY, oriZ);
var
   i,j,k: Integer;
   O: EOrientRect;
   Inside,Exact: Integer;
begin
   O:=oriUnDef; //the view direction isn't defined yet
   if (_Xpos=_Xpos2) then O:=oriX;
   if (_Ypos=_Ypos2) then O:=oriY;
   if (_Zpos=_Zpos2) then O:=oriZ;
   if (O=oriUnDef) then MessageDlg('Impossible to draw 3D rectangles!!!',mtError,[mbOK],0);
{  //this isn't efficient...
  for i:=0 to Tailer.XSize do begin
    for j:=0 to Tailer.YSize do begin
      for k:=0 to Tailer.ZSize do begin}
  //this is better
   for i:=Min(_Xpos,_Xpos2) to Max(_Xpos,_Xpos2) do
   begin
      for j:=Min(_Ypos,_Ypos2) to Max(_Ypos,_Ypos2) do
      begin
         for k:=Min(_Zpos,_Zpos2) to Max(_Zpos,_Zpos2) do
         begin
            Inside:=0; Exact:=0;
            case O of
               oriX:
               begin
                  if (i=_Xpos) then
                  begin //we're in the right slice
                     if (j>Min(_Ypos,_Ypos2)) and (j<Max(_Ypos,_Ypos2)) then Inc(Inside);
                     if (k>Min(_Zpos,_Zpos2)) and (k<Max(_Zpos,_Zpos2)) then Inc(Inside);
                     if (j=Min(_Ypos,_Ypos2)) or (j=Max(_Ypos,_Ypos2)) then Inc(Exact);
                     if (k=Min(_Zpos,_Zpos2)) or (k=Max(_Zpos,_Zpos2)) then Inc(Exact);
                  end;
               end;
               oriY:
               begin
                  if (j=_Ypos) then
                  begin //we're in the right slice
                     if (i>Min(_Xpos,_Xpos2)) and (i<Max(_Xpos,_Xpos2)) then Inc(Inside);
                     if (k>Min(_Zpos,_Zpos2)) and (k<Max(_Zpos,_Zpos2)) then Inc(Inside);
                     if (i=Min(_Xpos,_Xpos2)) or (i=Max(_Xpos,_Xpos2)) then Inc(Exact);
                     if (k=Min(_Zpos,_Zpos2)) or (k=Max(_Zpos,_Zpos2)) then Inc(Exact);
                  end;
               end;
               oriZ:
               begin
                  if (k=_Zpos) then
                  begin //we're in the right slice
                     if (i>Min(_Xpos,_Xpos2)) and (i<Max(_Xpos,_Xpos2)) then Inc(Inside);
                     if (j>Min(_Ypos,_Ypos2)) and (j<Max(_Ypos,_Ypos2)) then Inc(Inside);
                     if (i=Min(_Xpos,_Xpos2)) or (i=Max(_Xpos,_Xpos2)) then Inc(Exact);
                     if (j=Min(_Ypos,_Ypos2)) or (j=Max(_Ypos,_Ypos2)) then Inc(Exact);
                  end;
               end;
            end;
            if _Fill then
            begin
               if Inside+Exact=2 then
               begin
                  SetVoxel(i,j,k,_v);
               end;
            end
            else
            begin
               if (Exact>=1) and (Inside+Exact=2) then
               begin
                  SetVoxel(i,j,k,_v);
               end;
            end;
         end;
      end;
   end;
end;

procedure TVoxelSection.SaveUndoDump(var _fs: TStream);
var
   x,y,z: Integer;
begin
   _fs.Write(Header,SizeOf(Header));
   _fs.Write(Tailer,SizeOf(Tailer));
   for x := 0 to (Tailer.XSize - 1) do
      for y := 0 to (Tailer.YSize - 1) do
         for z := 0 to (Tailer.ZSize - 1) do
            _fs.Write(Data[x,y,z],SizeOf(TVoxelPacked));
end;

procedure TVoxelSection.LoadUndoDump(var _fs: TStream);
var
   x,y,z: Integer;
begin
   _fs.Read(Header,SizeOf(Header));
   _fs.Read(Tailer,SizeOf(Tailer));
   for x := 0 to (Tailer.XSize - 1) do
      for y := 0 to (Tailer.YSize - 1) do
         for z := 0 to (Tailer.ZSize - 1) do
            _fs.Read(Data[x,y,z],SizeOf(TVoxelPacked));
end;

// Insert a new section with SectionIndex :)
procedure TVoxel.InsertSection(_SectionIndex: Integer; const _Name: String; _XSize, _YSize, _ZSize: Integer);
var
   i: Integer;
begin
   //SectionIndex contains the index of the *new* section to create...
   SetLength(Section,Header.NumSections+1);
   Section[High(Section)] := TVoxelSection.Create;
   for i:=Header.NumSections-1 downto _SectionIndex do
   begin
      Section[i+1].Assign(Section[i]);
      Section[i+1].Header.Number:=i+1;
   end;
   Section[_SectionIndex].Clear;
   Section[_SectionIndex].ReCreate(_Name,_SectionIndex,_XSize,_YSize,_ZSize);
   Inc(Header.NumSections);
   Inc(Header.NumSections2);
end;

procedure TVoxel.RemoveSection(_SectionIndex: Integer);
var
   i: Integer;
begin
   for i:= _SectionIndex to Header.NumSections - 2 do
   begin
      Section[i].Assign(Section[i+1]);
      Section[i].Header.Number:=i;
   end;
   Section[High(Section)].Free;
   Dec(Header.NumSections);
   Dec(Header.NumSections2);
   SetLength(Section,Header.NumSections);
end;

//this function uses basic matrix/vector operations (nice hybrid Koen) to
//allow flipping and nudging.
procedure TVoxelSection.FlipMatrix(const _VectorDir, _VectorPos: array of Single; _Multiply: Boolean=True);
var
   NewData: array of array of array of TVoxelPacked; // as is 32-bit type, should be packed anyway
   i,j,k,a,b,c: Integer;
   Empty: TVoxelUnpacked;
   PackedVoxel: TVoxelPacked;
   VectorPos: array [0..2] of Single;
begin
   // prepare empty voxel
   with Empty do
   begin
      Colour := 0;
      Normal := 0;
      Used := False;
   end;
   PackedVoxel := PackVoxel(Empty);

   //create new data matrix
   SetLength(NewData,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   //fill it with empty voxels
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            NewData[i,j,k]:=PackedVoxel;
         end;
      end;
   end;
   if _Multiply then
   begin
      VectorPos[0]:=Max(_VectorPos[0]*Tailer.XSize-1,0);
      VectorPos[1]:=Max(_VectorPos[1]*Tailer.YSize-1,0);
      VectorPos[2]:=Max(_VectorPos[2]*Tailer.ZSize-1,0);
   end;
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            a:=Round(i*_VectorDir[0]+VectorPos[0]);
            b:=Round(j*_VectorDir[1]+VectorPos[1]);
            c:=Round(k*_VectorDir[2]+VectorPos[2]);
            //perform range checking
            if (a >=0 ) and (b >= 0) and (c >= 0) then
            begin
               if (a < Tailer.XSize) and (b < Tailer.YSize) and (c < Tailer.ZSize) then
                  NewData[a,b,c]:=Data[i,j,k];
            end;
         end;
      end;
   end;
   //That wasn't so hard...
   //now copy it back
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            Data[i,j,k] := NewData[i,j,k];
         end;
      end;
   end;
   // 1.3: Now, let's clear the memory
   for i := Low(NewData) to High(NewData) do
   begin
      for j := Low(NewData[i]) to High(NewData[i]) do
      begin
         SetLength(NewData[i,j],0);
      end;
      SetLength(NewData[i],0);
   end;
   SetLength(NewData,0);
end;

procedure TVoxelSection.ApplyMatrix(const _Matrix: TGLMatrixf4; _ResizeModel: Boolean = false);
var
   Pivot: TVector3f;
begin
   Pivot.X := (Tailer.XSize) / 2;
   Pivot.Y := (Tailer.YSize) / 2;
   Pivot.Z := (Tailer.ZSize) / 2;
   ApplyMatrix(_Matrix, Pivot, _ResizeModel);
end;

procedure TVoxelSection.ApplyMatrix(const _Matrix: TGLMatrixf4; _Pivot: TVector3f; _ResizeModel: Boolean = false);
var
   OldData: array of array of array of TVoxelPacked; // as is 32-bit type, should be packed anyway
   i,j,k,a,b,c: Integer;
   Empty: TVoxelUnpacked;
   PackedVoxel: TVoxelPacked;
   MatLinearSystem, ConstLinearSystem: AFloat;
   Solver: TCholeskySolver;
   Borders: AFloat;
   BorderNewPosition: TVector3f;
   MinPosition, MaxPosition, SystemPivot: TVector3f;

begin
   if _Matrix[3,3] = 0 then
      exit; // bad parameter - division by 0.

   // Prepare Linear System
   SetLength(MatLinearSystem, 9);
   SetLength(ConstLinearSystem, 3);

   // prepare empty voxel
   with Empty do
   begin
      Colour := 0;
      Normal := 0;
      Used := False;
   end;
   PackedVoxel := PackVoxel(Empty);

   // Backup data
   SetLength(OldData,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            OldData[i,j,k] := Data[i,j,k];
         end;
      end;
   end;

   //fill it with empty voxels
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            Data[i,j,k]:=PackedVoxel;
         end;
      end;
   end;

   MatLinearSystem[0] := _Matrix[0,0];
   MatLinearSystem[1] := _Matrix[0,1];
   MatLinearSystem[2] := _Matrix[0,2];
   MatLinearSystem[3] := _Matrix[1,0];
   MatLinearSystem[4] := _Matrix[1,1];
   MatLinearSystem[5] := _Matrix[1,2];
   MatLinearSystem[6] := _Matrix[2,0];
   MatLinearSystem[7] := _Matrix[2,1];
   MatLinearSystem[8] := _Matrix[2,2];

   if _ResizeModel then
   begin
      SetLength(Borders, 24);
      Borders[0] := 0; Borders[1] := 0; Borders[2] := 0;
      Borders[3] := 0; Borders[4] := 0; Borders[5] := Tailer.ZSize;
      Borders[6] := 0; Borders[7] := Tailer.YSize; Borders[8] := 0;
      Borders[9] := 0; Borders[10] := Tailer.YSize; Borders[11] := Tailer.ZSize;
      Borders[12] := Tailer.XSize; Borders[13] := 0; Borders[14] := 0;
      Borders[15] := Tailer.XSize; Borders[16] := 0; Borders[17] := Tailer.ZSize;
      Borders[18] := Tailer.XSize; Borders[19] := Tailer.YSize; Borders[20] := 0;
      Borders[21] := Tailer.XSize; Borders[22] := Tailer.YSize; Borders[23] := Tailer.ZSize;
      MinPosition.X := 999999;
      MinPosition.Y := 999999;
      MinPosition.Z := 999999;
      MaxPosition.X := -999999;
      MaxPosition.Y := -999999;
      MaxPosition.Z := -999999;


      i := 0;
      while i < 23 do
      begin
         ConstLinearSystem[0] := ((Borders[i] - _Pivot.X) * _Matrix[3,3]) - _Matrix[0,3];
         ConstLinearSystem[1] := ((Borders[i+1] - _Pivot.Y) * _Matrix[3,3]) - _Matrix[1,3];
         ConstLinearSystem[2] := ((Borders[i+2] - _Pivot.Z) * _Matrix[3,3]) - _Matrix[2,3];
         Solver := TCholeskySolver.Create(MatLinearSystem, ConstLinearSystem);
         Solver.Execute;
         BorderNewPosition.X := _Pivot.X + Solver.Answer[0];
         BorderNewPosition.Y := _Pivot.Y + Solver.Answer[1];
         BorderNewPosition.Z := _Pivot.Z + Solver.Answer[2];
         if BorderNewPosition.X < MinPosition.X then
            MinPosition.X := BorderNewPosition.X;
         if BorderNewPosition.Y < MinPosition.Y then
            MinPosition.Y := BorderNewPosition.Y;
         if BorderNewPosition.Z < MinPosition.Z then
            MinPosition.Z := BorderNewPosition.Z;
         if BorderNewPosition.X > MaxPosition.X then
            MaxPosition.X := BorderNewPosition.X;
         if BorderNewPosition.Y > MaxPosition.Y then
            MaxPosition.Y := BorderNewPosition.Y;
         if BorderNewPosition.Z > MaxPosition.Z then
            MaxPosition.Z := BorderNewPosition.Z;
         Solver.Free;
         inc(i, 3);
      end;
      SetLength(Borders, 0);

      if not ResizeUpdateBounds(MinPosition, MaxPosition) then
      begin
         exit;
      end;
      SystemPivot.X := (MaxPosition.X - MinPosition.X) / 2;
      SystemPivot.Y := (MaxPosition.Y - MinPosition.Y) / 2;
      SystemPivot.Z := (MaxPosition.Z - MinPosition.Z) / 2;
   end
   else
   begin
      SystemPivot.X := _Pivot.X;
      SystemPivot.Y := _Pivot.Y;
      SystemPivot.Z := _Pivot.Z;
   end;



   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            ConstLinearSystem[0] := ((i - SystemPivot.X) * _Matrix[3,3]) - _Matrix[0,3];
            ConstLinearSystem[1] := ((j - SystemPivot.Y) * _Matrix[3,3]) - _Matrix[1,3];
            ConstLinearSystem[2] := ((k - SystemPivot.Z) * _Matrix[3,3]) - _Matrix[2,3];
            Solver := TCholeskySolver.Create(MatLinearSystem, ConstLinearSystem);
            Solver.Execute;
            a := Trunc(_Pivot.X + Solver.Answer[0]);
            b := Trunc(_Pivot.Y + Solver.Answer[1]);
            c := Trunc(_Pivot.Z + Solver.Answer[2]);
            Solver.Free;

            //perform range checking
            if (a >=0 ) and (b >= 0) and (c >= 0) then
            begin
               if (a <= High(OldData)) and (b <= High(OldData[0])) and (c <= High(OldData[0,0])) then
               begin
                  Data[i,j,k] := OldData[a,b,c];
               end;
            end;
         end;
      end;
   end;

   if _ResizeModel then
   begin
      _Pivot.X := _Pivot.X + MinPosition.X;
      _Pivot.Y := _Pivot.Y + MinPosition.Y;
      _Pivot.Z := _Pivot.Z + MinPosition.Z;
   end;

   // 1.3: Now, let's clear the memory
   for i := Low(OldData) to High(OldData) do
   begin
      for j := Low(OldData[i]) to High(OldData[i]) do
      begin
         SetLength(OldData[i,j],0);
      end;
      SetLength(OldData[i],0);
   end;
   SetLength(OldData,0);
   SetLength(MatLinearSystem, 0);
   SetLength(ConstLinearSystem, 0);
end;

procedure TVoxelSection.Mirror(_MirrorView: EVoxelViewOrient);
var
   NewData: array of array of array of TVoxelPacked; // as is 32-bit type, should be packed anyway
   i,j,k: Integer;
   Xm,Ym,Zm: Integer;
   OddMod: Integer;
begin
   OddMod:=0;
   SetLength(NewData,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   //First, copy the entire voxel into the new data array
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            NewData[i,j,k]:=Data[i,j,k];
         end;
      end;
   end;
   Xm:=Tailer.XSize div 2-1;
   Ym:=Tailer.YSize div 2-1;
   Zm:=Tailer.ZSize div 2-1;
   case _MirrorView of
      oriX:
      begin
         if (Tailer.XSize mod 2)=1 then OddMod:=1;
         for i:=0 to Xm do
         begin
            for j:=0 to Tailer.YSize-1 do
            begin
               for k:=0 to Tailer.ZSize-1 do
               begin
                  NewData[-i+Xm,j,k]:=Data[i+Xm+1+OddMod,j,k];
               end;
            end;
         end;
      end;
      oriY:
      begin
         if (Tailer.YSize mod 2)=1 then OddMod:=1;
         for i:=0 to Tailer.XSize-1 do
         begin
            for j:=0 to Ym do
            begin
               for k:=0 to Tailer.ZSize-1 do
               begin
                  NewData[i,-j+Ym,k]:=Data[i,j+Ym+1+OddMod,k];
               end;
            end;
         end;
      end;
      oriZ:
      begin
         if (Tailer.ZSize mod 2)=1 then OddMod:=1;
         for i:=0 to Tailer.XSize-1 do
         begin
            for j:=0 to Tailer.YSize-1 do
            begin
               for k:=0 to Zm do
               begin
                  NewData[i,j,-k+Zm]:=Data[i,j,k+Zm+1+OddMod];
               end;
            end;
         end;
      end;
   end;
   //That wasn't so hard...
   //now copy it back
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            Data[i,j,k]:=NewData[i,j,k];
         end;
      end;
   end;
   // 1.3: Now, let's clear the memory
   for i := Low(NewData) to High(NewData) do
   begin
      for j := Low(NewData[i]) to High(NewData[i]) do
      begin
         SetLength(NewData[i,j],0);
      end;
      SetLength(NewData[i],0);
   end;
   SetLength(NewData,0);
   finalize(NewData);
end;

procedure TVoxelSection.ResizeBlowUp(_Scale: Integer);
var
   NewData: array of array of array of TVoxelPacked; // as is 32-bit type, should be packed anyway
   i,j,k: Integer;
   Empty: TVoxelUnpacked;
   PackedVoxel: TVoxelPacked;
begin
// prepare empty voxel
   with Empty do
   begin
      Colour := 0;
      Normal := 0;
      Used := False;
   end;
   PackedVoxel := PackVoxel(Empty);

   //create new data matrix
   SetLength(NewData,Tailer.XSize*_Scale,Tailer.YSize*_Scale,Tailer.ZSize*_Scale);
   //fill it with empty voxels
   for i:=0 to Tailer.XSize * _Scale - 1 do
   begin
      for j:=0 to Tailer.YSize * _Scale - 1 do
      begin
         for k:=0 to Tailer.ZSize * _Scale - 1 do
         begin
            NewData[i,j,k]:=PackedVoxel;
         end;
      end;
   end;
   for i:=0 to Tailer.XSize * _Scale - 1 do
   begin
      for j:=0 to Tailer.YSize * _Scale - 1 do
      begin
         for k:=0 to Tailer.ZSize * _Scale - 1 do
         begin
            NewData[i,j,k]:=Data[i div _Scale,j div _Scale,k div _Scale];
         end;
      end;
   end;
   Resize(Tailer.XSize*_Scale,Tailer.YSize*_Scale,Tailer.ZSize*_Scale);
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            Data[i,j,k]:=NewData[i,j,k];
         end;
      end;
   end;
   // 1.3: Now, let's clear the memory
   for i := Low(NewData) to High(NewData) do
   begin
      for j := Low(NewData[i]) to High(NewData[i]) do
      begin
         SetLength(NewData[i,j],0);
      end;
      SetLength(NewData[i],0);
   end;
   SetLength(NewData,0);
end;

// This procedure will wipe all the pixel data from the section. Make sure you have a backup.
function TVoxelSection.ResizeUpdateBounds(var _MinPosition, _MaxPosition: TVector3f): boolean;
var
   i,j,k: Integer;
   Empty: TVoxelUnpacked;
   PackedVoxel: TVoxelPacked;
   OldMinBounds: TVector3f;
   OldMaxBounds: TVector3f;
   BoundScale: TVector3f;
   OldSize, NewSize: TVector3i;
begin
// prepare empty voxel
   with Empty do
   begin
      Colour := 0;
      Normal := 0;
      Used := False;
   end;
   PackedVoxel := PackVoxel(Empty);

   // Backup bounds, since Resize will mess them up.
   OldMinBounds.X := Tailer.MinBounds[1];
   OldMinBounds.Y := Tailer.MinBounds[2];
   OldMinBounds.Z := Tailer.MinBounds[3];
   OldMaxBounds.X := Tailer.MaxBounds[1];
   OldMaxBounds.Y := Tailer.MaxBounds[2];
   OldMaxBounds.Z := Tailer.MaxBounds[3];

   _MinPosition.X := Floor(_MinPosition.X);
   _MinPosition.Y := Floor(_MinPosition.Y);
   _MinPosition.Z := Floor(_MinPosition.Z);
   _MaxPosition.X := Ceil(_MaxPosition.X);
   _MaxPosition.Y := Ceil(_MaxPosition.Y);
   _MaxPosition.Z := Ceil(_MaxPosition.Z);

   NewSize.X := Round(_MaxPosition.X - _MinPosition.X);
   NewSize.Y := Round(_MaxPosition.Y - _MinPosition.Y);
   NewSize.Z := Round(_MaxPosition.Z - _MinPosition.Z);

   if (NewSize.X <= 0) or (NewSize.X > 255) or (NewSize.Y <= 0) or (NewSize.Y > 255) or (NewSize.Z <= 0) or (NewSize.Z > 255) then
   begin
      Result := false;
      exit;
   end;
   Result := true;

   OldSize.X := Tailer.XSize;
   OldSize.Y := Tailer.YSize;
   OldSize.Z := Tailer.ZSize;

   BoundScale.X := (OldMaxBounds.X - OldMinBounds.X) / Tailer.XSize;
   BoundScale.Y := (OldMaxBounds.Y - OldMinBounds.Y) / Tailer.YSize;
   BoundScale.Z := (OldMaxBounds.Z - OldMinBounds.Z) / Tailer.ZSize;

   Resize(NewSize.X, NewSize.Y, NewSize.Z);
   for i:=0 to Tailer.XSize - 1 do
   begin
      for j:=0 to Tailer.YSize - 1 do
      begin
         for k:=0 to Tailer.ZSize - 1 do
         begin
            Data[i,j,k]:=PackedVoxel;
         end;
      end;
   end;

   Tailer.MinBounds[1] := OldMinBounds.X + (_MinPosition.X * BoundScale.X);
   Tailer.MinBounds[2] := OldMinBounds.Y + (_MinPosition.Y * BoundScale.Y);
   Tailer.MinBounds[3] := OldMinBounds.Z + (_MinPosition.Z * BoundScale.Z);
   Tailer.MaxBounds[1] := OldMaxBounds.X + ((_MaxPosition.X - OldSize.X) * BoundScale.X);
   Tailer.MaxBounds[2] := OldMaxBounds.Y + ((_MaxPosition.Y - OldSize.Y) * BoundScale.Y);
   Tailer.MaxBounds[3] := OldMaxBounds.Z + ((_MaxPosition.Z - OldSize.Z) * BoundScale.Z);
end;

//brushview contains the view of the current editing Window.
procedure TVoxelSection.BrushTool(_Xc,_Yc,_Zc: Integer; _V: TVoxelUnpacked; _BrushMode: Integer; _BrushView: EVoxelViewOrient);
var
   Shape: Array[-5..5,-5..5] of 0..1;
   i,j,r1,r2: Integer;
begin
   randomize;
   for i:=-5 to 5 do
      for j:=-5 to 5 do
         Shape[i,j]:=0;
   Shape[0,0]:=1;
   if _BrushMode>=1 then
   begin
      Shape[0,1]:=1; Shape[0,-1]:=1; Shape[1,0]:=1; Shape[-1,0]:=1;
   end;
   if _BrushMode>=2 then
   begin
      Shape[1,1]:=1; Shape[1,-1]:=1; Shape[-1,-1]:=1; Shape[-1,1]:=1;
   end;
   if _BrushMode>=3 then
   begin
      Shape[0,2]:=1; Shape[0,-2]:=1; Shape[2,0]:=1; Shape[-2,0]:=1;
   end;
   if _BrushMode =4 then
   begin
      for i:=-5 to 5 do
         for j:=-5 to 5 do
            Shape[i,j]:=0;

      for i:=1 to 3 do
      begin
         r1 := random(7)-3; r2 := random(7)-3;
         Shape[r1,r2]:=1;
      end;
   end;
   //Brush completed, now actually use it!
   //for every pixel of the brush, check if we need to draw it (Shape),
   //if so, use the correct view to set the voxel (with range checking!)
   for i:=-5 to 5 do
   begin
      for j:=-5 to 5 do
      begin
         if Shape[i,j]=1 then
         begin
            case _BrushView of
               oriX: SetVoxel(_Xc,Max(Min(_Yc+i,Tailer.YSize-1),0),Max(Min(_Zc+j,Tailer.ZSize-1),0),_v);
               oriY: SetVoxel(Max(Min(_Xc+i,Tailer.XSize-1),0),_Yc,Max(Min(_Zc+j,Tailer.ZSize-1),0),_v);
               oriZ: SetVoxel(Max(Min(_Xc+i,Tailer.XSize-1),0),Max(Min(_Yc+j,Tailer.YSize-1),0),_Zc,_v);
            end;
         end;
      end;
   end;
   //all old Brush code was deleted, because this one doesn't have problems with
   //multiple views.
end;

procedure TVoxelSection.FloodFillTool(_Xpos,_Ypos,_Zpos: Integer; _v: TVoxelUnpacked; _EditView: EVoxelViewOrient);
type
   FloodSet = (Left,Right,Up,Down);
   Flood3DPoint = record
      X,Y,Z: Integer;
   end;
   StackType = record
      Dir: set of FloodSet;
      p: Flood3DPoint;
   end;

   function PointOK(_l: Flood3DPoint): Boolean;
   begin
      PointOK:=False;
      if (_l.X<0) or (_l.Y<0) or (_l.Z<0) then Exit;
      if (_l.X>=Tailer.XSize) or (_l.Y>=Tailer.YSize) or (_l.Z>=Tailer.ZSize) then Exit;
      PointOK:=True;
   end;

var
   z1,z2: TVoxelUnpacked;
   i,j,k: Integer;         //this isn't 100% FloodFill, but function is very handy for user;
   Stack: Array of StackType; //this is the floodfill stack for my code
   SC,Sp: Integer; //stack counter and stack pointer
   po: Flood3DPoint;
   Full: set of FloodSet;
   Done: Array of Array of Array of Boolean;
begin
   SetLength(Done,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   SetLength(Stack,Tailer.XSize*Tailer.YSize*Tailer.ZSize);
   //this array avoids creation of extra stack objects when it isn't needed.
   for i:=0 to Tailer.XSize - 1 do
      for j:=0 to Tailer.YSize - 1 do
         for k:=0 to Tailer.ZSize - 1 do
            Done[i,j,k]:=False;

   GetVoxel(_Xpos,_Ypos,_Zpos,z1);
   SetVoxel(_Xpos,_Ypos,_Zpos,_v);

   Full:=[Left,Right,Up,Down];
   Sp:=0;
   Stack[Sp].Dir:=Full;
   Stack[Sp].p.X:= _Xpos;
   Stack[Sp].p.Y:= _Ypos;
   Stack[Sp].p.Z:= _Zpos;
   SC:=1;
   while (SC>0) do
   begin
      if Left in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Left];
         po:=Stack[Sp].p;
         case _EditView of
            oriX: Dec(po.Y);
            oriY: Dec(po.X);
            oriZ: Dec(po.X);
         end;
         //now check this point - only if it's within range, check it.
         if PointOK(po) then
         begin
            GetVoxel(po.X,po.Y,po.Z,z2);
            if z2.Colour=z1.Colour then
            begin
               SetVoxel(po.X,po.Y,po.Z,_v);
               if not Done[po.X,po.Y,po.Z] then
               begin
                  Stack[SC].Dir:=Full-[Right]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y,po.Z]:=True;
            end;
         end;
      end;
      if Right in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Right];
         po:=Stack[Sp].p;
         case _EditView of
            oriX: Inc(po.Y);
            oriY: Inc(po.X);
            oriZ: Inc(po.X);
         end;
         //now check this point - only if it's within range, check it.
         if PointOK(po) then
         begin
            GetVoxel(po.X,po.Y,po.Z,z2);
            if z2.Colour=z1.Colour then
            begin
               SetVoxel(po.X,po.Y,po.Z,_v);
               if not Done[po.X,po.Y,po.Z] then
               begin
                  Stack[SC].Dir:=Full-[Left]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y,po.Z]:=True;
            end;
         end;
      end;
      if Up in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Up];
         po:=Stack[Sp].p;
         case _EditView of
            oriX: Dec(po.Z);
            oriY: Dec(po.Z);
            oriZ: Dec(po.Y);
         end;
         //now check this point - only if it's within range, check it.
         if PointOK(po) then
         begin
            GetVoxel(po.X,po.Y,po.Z,z2);
            if z2.Colour=z1.Colour then
            begin
               SetVoxel(po.X,po.Y,po.Z,_v);
               if not Done[po.X,po.Y,po.Z] then
               begin
                  Stack[SC].Dir:=Full-[Down]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y,po.Z]:=True;
            end;
         end;
      end;
      if Down in Stack[Sp].Dir then
      begin //it's in there - check left
         //not in there anymore! we're going to do that one now.
         Stack[Sp].Dir:=Stack[Sp].Dir - [Down];
         po:=Stack[Sp].p;
         case _EditView of
            oriX: Inc(po.Z);
            oriY: Inc(po.Z);
            oriZ: Inc(po.Y);
         end;
         //now check this point - only if it's within range, check it.
         if PointOK(po) then
         begin
            GetVoxel(po.X,po.Y,po.Z,z2);
            if z2.Colour=z1.Colour then
            begin
               SetVoxel(po.X,po.Y,po.Z,_v);
               if not Done[po.X,po.Y,po.Z] then
               begin
                  Stack[SC].Dir:=Full-[Up]; //Don't go back
                  Stack[SC].p:=po;
                  Inc(SC);
                  Inc(Sp); //increase stack pointer
               end;
               Done[po.X,po.Y,po.Z]:=True;
            end;
         end;
      end;
      if (Stack[Sp].Dir = []) then
      begin
         Dec(Sp);
         Dec(SC);
         //decrease stack pointer and stack count
      end;
   end;
   SetLength(Stack,0); // Free Up Memory
   // 1.3: Now, let's clear the memory
   for i := Low(Done) to High(Done) do
   begin
      for j := Low(Done[i]) to High(Done[i]) do
      begin
         SetLength(Done[i,j],0);
      end;
      SetLength(Done[i],0);
   end;
   SetLength(Done,0);
end;

procedure TVoxelSection.Crop;
var
   x,y,z,x_min, y_min, z_min, x_max, y_max, z_max: integer;
   found: boolean;
   v : TVoxelUnpacked;
   Scale : TVector3f;
   TempData : array of array of array of TVoxelPacked;
begin
   // Detect scale
   Scale.X := (Tailer.MaxBounds[1] - Tailer.MinBounds[1]) / Tailer.XSize;
   Scale.Y := (Tailer.MaxBounds[2] - Tailer.MinBounds[2]) / Tailer.YSize;
   Scale.Z := (Tailer.MaxBounds[3] - Tailer.MinBounds[3]) / Tailer.ZSize;
   // Detect minimums
   // x_min
   x_min := 0;
   found := false;
   while (not found) and (x_min < Tailer.XSize) do
   begin
      y := 0;
      while (not found) and (y < Tailer.YSize) do
      begin
         z := 0;
         while (not found) and (z < Tailer.ZSize) do
         begin
            GetVoxel(x_min,y,z,v);
            if v.Used then
            begin
               found := true;
            end;
            inc(z);
         end;
         inc(y);
      end;
      if not found then
         inc(x_min);
   end;
   // y_min
   y_min := 0;
   found := false;
   while (not found) and (y_min < Tailer.YSize) do
   begin
      x := 0;
      while (not found) and (x < Tailer.XSize) do
      begin
         z := 0;
         while (not found) and (z < Tailer.ZSize) do
         begin
            GetVoxel(x,y_min,z,v);
            if v.Used then
            begin
               found := true;
            end;
            inc(z);
         end;
         inc(x);
      end;
      if not found then
         inc(y_min);
   end;
   // z_min
   z_min := 0;
   found := false;
   while (not found) and (z_min < Tailer.ZSize) do
   begin
      y := 0;
      while (not found) and (y < Tailer.YSize) do
      begin
         x := 0;
         while (not found) and (x < Tailer.XSize) do
         begin
            GetVoxel(x,y,z_min,v);
            if v.Used then
            begin
               found := true;
            end;
            inc(x);
         end;
         inc(y);
      end;
      if not found then
         inc(z_min);
   end;
   // Detect maximums
   // x_max
   x_max := Tailer.XSize-1;
   found := false;
   while (not found) and (x_min >= 0) do
   begin
      y := 0;
      while (not found) and (y < Tailer.YSize) do
      begin
         z := 0;
         while (not found) and (z < Tailer.ZSize) do
         begin
            GetVoxel(x_max,y,z,v);
            if v.Used then
            begin
               found := true;
            end;
            inc(z);
         end;
         inc(y);
      end;
      if not found then
         dec(x_max);
   end;
   // y_max
   y_max := Tailer.YSize-1;
   found := false;
   while (not found) and (y_max >= 0) do
   begin
      x := 0;
      while (not found) and (x < Tailer.XSize) do
      begin
         z := 0;
         while (not found) and (z < Tailer.ZSize) do
         begin
            GetVoxel(x,y_max,z,v);
            if v.Used then
            begin
               found := true;
            end;
            inc(z);
         end;
         inc(x);
      end;
      if not found then
         dec(y_max);
   end;
   // z_max
   z_max := Tailer.ZSize-1;
   found := false;
   while (not found) and (z_max >= 0) do
   begin
      y := 0;
      while (not found) and (y < Tailer.YSize) do
      begin
         x := 0;
         while (not found) and (x < Tailer.XSize) do
         begin
            GetVoxel(x,y,z_max,v);
            if v.Used then
            begin
               found := true;
            end;
            inc(x);
         end;
         inc(y);
      end;
      if not found then
         dec(z_max);
   end;
   // Fix bounds
   Tailer.MinBounds[1] := Tailer.MinBounds[1] + (x_min * Scale.X);
   Tailer.MinBounds[2] := Tailer.MinBounds[2] + (y_min * Scale.Y);
   Tailer.MinBounds[3] := Tailer.MinBounds[3] + (z_min * Scale.Z);
   Tailer.MaxBounds[1] := Tailer.MaxBounds[1] - ((Tailer.XSize - x_max) * Scale.X);
   Tailer.MaxBounds[2] := Tailer.MaxBounds[2] - ((Tailer.YSize - y_max) * Scale.Y);
   Tailer.MaxBounds[3] := Tailer.MaxBounds[3] - ((Tailer.ZSize - z_max) * Scale.Z);
   // Backup Data.
   SetLength(TempData,Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            TempData[x,y,z] := Data[x,y,z];
   // Fix sizes
   Tailer.XSize := x_max - x_min + 1;
   Tailer.YSize := y_max - y_min + 1;
   Tailer.ZSize := z_max - z_min + 1;
   // Compress data
   SetDataSize(Tailer.XSize,Tailer.YSize,Tailer.ZSize);
   for x := Low(Data) to High(Data) do
      for y := Low(Data[x]) to High(Data[x]) do
         for z := Low(Data[x,y]) to High(Data[x,y]) do
            Data[x,y,z] := TempData[x+x_min,y+y_min,z+z_min];
   // Fix X, Y and Z
   if Self.X >= Tailer.XSize then
      Self.X := Tailer.XSize - 1;
   if Self.Y >= Tailer.YSize then
      Self.Y := Tailer.YSize - 1;
   if Self.Z >= Tailer.ZSize then
      Self.Z := Tailer.ZSize - 1;
   // Refresh views
   for x := 0 to 2 do
   begin
      View[x].Clear;
      View[x].CreateCanvas;
   end;
   // Cleanup TempData
   for x := Low(TempData) to High(TempData) do
   begin
      for y := Low(TempData[x]) to High(TempData[x]) do
      begin
         SetLength(TempData[x,y],0);
      end;
      SetLength(TempData[x],0);
   end;
   SetLength(TempData,0);
end;

procedure TVoxel.setSpectrum(_newspectrum: ESpectrumMode);
var i: integer;
begin
   for i := Low(Section) to High(Section) do
      Section[i].setSpectrum(_newspectrum);
end;

end.
