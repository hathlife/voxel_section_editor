unit HVA;

// HVA Unit By Stucuk
// Written using the tibsun-hva.doc by The Profound Eol
{$INCLUDE Global_Conditionals.inc}

interface

uses dialogs,sysutils,OpenGL15, Voxel, Geometry, Voxel_Engine, math3d;

type
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
   THVA = class
         Header : THVA_Main_Header;
         Data : array of THVAData;
         TransformMatrices : array of TTransformMatrix;
         p_Voxel : PVoxel;
      private
         procedure ClearMemory;
         procedure MakeABlankHVA;
         function LoadFromFile(const _Filename : string): boolean;
         procedure ClearFrame(_Number : integer);
         procedure ClearTM(_Number : integer);
         Function CorrectAngle(_Angle : Single) : Single;
         procedure CopyTM(Source, Dest : integer);
      public
         Frame : longword;
         Section : longword;
         // Constructors/Destructors
         Constructor Create(); overload;
         constructor Create(const _Filename : string; _pVoxel : PVoxel); overload;
         Destructor Destroy; override;
         // I/O stuff
         procedure Clear;
         procedure LoadFile(const _Filename : string; _pVoxel : PVoxel);
         Procedure SaveFile(const _Filename : string);
         // Frame Operations
         procedure AddBlankFrame;
         Procedure InsertFrame(FrameNumber : integer);
         Procedure CopyFrame(FrameNumber : integer);
         Procedure DeleteFrame(FrameNumber : Integer);
         // Gets
         Function GetMatrix(_Section,_Frames : Integer) : TMatrix; overload;
         Procedure GetMatrix(var _Res : TTransformMatrix; _Section,_Frames : Integer); overload;
         Function GetTMValue(_Row,_Col,_Section,_Frames : integer) : single;
         Function GetPosition(_Frame,_Section : Integer) : TVector3f;
         Function GetAngle_RAD(_Section,_Frames : Integer) : TVector3f;
         Function GetAngle_DEG(_Section,_Frames : Integer) : TVector3f;
         Function GetAngle_DEG_Correct(_Section,_Frames : Integer) : TVector3f;
         // Sets
         Procedure SetMatrix(const _M : TMatrix; _Frame,_Section : Integer); overload;
         Procedure SetMatrix(const _M : TTransformMatrix; _Frame,_Section : Integer); overload;
         Procedure SetTMValue(_Frame,_Section,_Row,_Col : Integer; _Value : single);
         Procedure SetPosition(_Frame,_Section : Integer; _Position : TVector3f);
         Function SetAngle(_Section,_Frames : Integer; _x,_y,_z : single) : TVector3f;
         // Miscelaneous
         Procedure ApplyMatrix(_VoxelScale : TVector3f; _Section : Integer);
         Procedure MovePosition(_Frame,_Section : Integer; _X,_Y,_Z : single);
   end;

   THVAVOXEL = (HVhva,HVvoxel);

{
THVA_Main_Header = packed record
   FilePath: array[1..16] of Char;  (* ASCIIZ string                      *)
   N_Frames,                        (* Number of animation frames         *)
   N_Sections : Longword;           (* Number of voxel sections described *)
end;

TSectionName = array[1..16] of Char; (* ASCIIZ string - name of section *)
TTransformMatrix = packed array[1..3,1..4] of Single;

THVAData = packed record
   SectionName : TSectionName;
   TransformMatrixs : array of TTransformMatrix;
end;

THVA = Record
   Header : THVA_Main_Header;
   Data : array of THVAData;
   Data_no : integer;
end;

var
   HVAFile : THVA;
   HVASection : integer = 0;
   HVAFrame : integer = 0;
   {Transformations : TTransformations;
   Matrix : TMatrix;
   matrix2: array[0..15] of GLfloat;}

{
function LoadHVA(Filename : string): boolean;

Function ApplyMatrix(V : TVector3f) : TVector3f; overload;
Function ApplyMatrix(VoxelScale : TVector3f; Section, Frames : Integer) : TVector3f; overload;
Procedure FloodMatrix;
Function GetTMValue(Row,Col : integer) : single; overload;
Function GetTMValue(Row,Col,Section : integer) : single; overload;
Procedure ClearHVA;
function GetIdentityTM : TTransformMatrix;
}
implementation

///////////////////////////////////////////////////////////
//////// New HVA Engine Rock And Roll HERE ////////////////
///////////////////////////////////////////////////////////
Constructor THVA.Create();
begin
   p_Voxel := nil;
   MakeABlankHVA;
end;

Constructor THVA.Create (const _Filename : string; _pVoxel : PVoxel);
begin
   LoadFile(_Filename,_pVoxel);
end;

Destructor THVA.Destroy;
begin
   ClearMemory;
   inherited Destroy;
end;

procedure THVA.ClearMemory;
begin
   SetLength(TransformMatrices,0);
end;

procedure THVA.Clear;
begin
   ClearMemory;
   MakeABlankHVA;
end;

// Gives the default settings for invalid HVAs
procedure THVA.MakeABlankHVA;
var
   x,i : byte;
begin
   Header.N_Frames := 0;
   if (p_Voxel <> nil) then
   begin
      Header.N_Sections := p_Voxel^.Header.NumSections
   end
   else
      Header.N_Sections := 0;

   for x := 1 to 16 do
      Header.FilePath[x] := #0;

   Setlength(Data,Header.N_Sections);

   if (p_Voxel <> nil) then
   begin
      for i := 0 to p_Voxel^.Header.NumSections-1 do
         for x := 1 to 16 do
            Data[i].SectionName[x] := p_Voxel^.section[i].Header.Name[x];
   end;
   AddBlankFrame;
   Frame := 0;
   Section := 0;
end;

Procedure THVA.SaveFile(const _Filename : string);
var
   f : file;
   wrote,x : integer;
begin
   //SetCharArray('',HVAFile.Header.FilePath);
   for x := 1 to 16 do
      Header.FilePath[x] := #0;

   AssignFile(F,_Filename);  // Open file
   Rewrite(F,1); // Goto first byte?

   BlockWrite(F,Header,Sizeof(THVA_Main_Header),wrote); // Write Header

   {$ifdef DEBUG_HVA_FILE}
   Showmessage(_Filename);
   showmessage(inttostr(Header.N_Sections));
   showmessage(inttostr(Header.N_Frames));
   showmessage(inttostr(wrote));
   {$endif}

   For x := 0 to High(Data) do
      BlockWrite(F,Data[x].SectionName,Sizeof(TSectionName),wrote);

  {$ifdef DEBUG_HVA_FILE}
  showmessage(inttostr(wrote));
  {$endif}

   For x := 0 to High(TransformMatrices) do
      BlockWrite(F,TransformMatrices[x],Sizeof(TTransformMatrix),wrote);

   {$ifdef DEBUG_HVA_FILE}
   showmessage(inttostr(wrote));
   {$endif}

   CloseFile(f);
end;

procedure THVA.LoadFile(const _Filename : string; _pVoxel : PVoxel);
begin
   p_Voxel := _pVoxel;
   ClearMemory;
   if not LoadFromFile(_Filename) then MakeABlankHVA;
end;

function THVA.LoadFromFile(const _Filename: String): boolean;
var
   f : file;
   read,x,y : integer;
begin
   Result := false;
   if not FileExists(_Filename) then exit;

   AssignFile(F,_Filename);  // Open file
   Reset(F,1); // Goto first byte?

   BlockRead(F,Header,Sizeof(THVA_Main_Header)); // Read Header

   SetLength(Data,Header.N_Sections);

   For x := 0 to High(Data) do
      BlockRead(F,Data[x].SectionName,Sizeof(TSectionName));

   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);

   For x := 0 to High(TransformMatrices) do
      BlockRead(F,TransformMatrices[x],Sizeof(TTransformMatrix));

   CloseFile(f);
   If Header.N_Frames < 1 then
      exit;
   Frame := 0;
   Result := True;
end;

procedure THVA.AddBlankFrame;
var
   x : integer;
begin
   inc(Header.N_Frames);

   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);

   ClearFrame(Header.N_Frames-1);
end;

// The number received here must be the frame as the user see.
// starting from frame #1.
procedure THVA.ClearFrame(_Number : Integer);
var
   x : integer;
begin
   for x := 0 to Header.N_Sections-1 do
      ClearTM(_Number*Header.N_Sections+x);
end;

procedure THVA.ClearTM(_Number : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TransformMatrices[_Number][x][y] := 0;

   TransformMatrices[_Number][1][1] := 1;
   TransformMatrices[_Number][2][2] := 1;
   TransformMatrices[_Number][3][3] := 1;
end;

Function THVA.GetTMValue(_Row,_Col,_Section,_Frames : integer) : single;
begin
   Result := TransformMatrices[_Frames*Header.N_Sections+_Section][_Row][_Col];
end;

Function THVA.GetMatrix(_Section,_Frames : Integer) : TMatrix;
var
   x,y : integer;
begin
   Result := IdentityMatrix;

   for x := 1 to 3 do
      for y := 1 to 4 do
         Result[x-1][y-1] := GetTMValue(x,y,_Section,_Frames);
end;

Procedure THVA.GetMatrix(var _Res : TTransformMatrix; _Section,_Frames : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         _Res[x][y] := GetTMValue(x,y,_Section,_Frames);
end;

Procedure THVA.SetMatrix(const _M : TMatrix; _Frame,_Section : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TransformMatrices[_Frame*Header.N_Sections+_Section][x][y] := _m[x-1][y-1];
end;

Procedure THVA.SetMatrix(const _M : TTransformMatrix; _Frame,_Section : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TransformMatrices[_Frame*Header.N_Sections+_Section][x][y] := _m[x][y];
end;

Procedure THVA.ApplyMatrix(_VoxelScale : TVector3f; _Section : Integer);
var
   Matrix : TGLMatrixf4;
   Scale : single;
begin
   if _Section = -1 then
   begin
      Exit;
   end;

   Scale := p_Voxel^.Section[_Section].Tailer.Det;

   if Header.N_Sections > 0 then
   begin
      Matrix[0,0] := GetTMValue(1,1,_Section,Frame);
      Matrix[0,1] := GetTMValue(2,1,_Section,Frame);
      Matrix[0,2] := GetTMValue(3,1,_Section,Frame);
      Matrix[0,3] := 0;

      Matrix[1,0] := GetTMValue(1,2,_Section,Frame);
      Matrix[1,1] := GetTMValue(2,2,_Section,Frame);
      Matrix[1,2] := GetTMValue(3,2,_Section,Frame);
      Matrix[1,3] := 0;

      Matrix[2,0] := GetTMValue(1,3,_Section,Frame);
      Matrix[2,1] := GetTMValue(2,3,_Section,Frame);
      Matrix[2,2] := GetTMValue(3,3,_Section,Frame);
      Matrix[2,3] := 0;

      Matrix[3,0] := (GetTMValue(1,4,_Section,Frame)* Scale) * _VoxelScale.X;
      Matrix[3,1] := (GetTMValue(2,4,_Section,Frame)* Scale) * _VoxelScale.Y;
      Matrix[3,2] := (GetTMValue(3,4,_Section,Frame)* Scale) * _VoxelScale.Z;
      Matrix[3,3] := 1;
   end
   else
   begin
      Matrix[0,0] := 1;
      Matrix[0,1] := 0;
      Matrix[0,2] := 0;
      Matrix[0,3] := 0;

      Matrix[1,0] := 0;
      Matrix[1,1] := 1;
      Matrix[1,2] := 0;
      Matrix[1,3] := 0;

      Matrix[2,0] := 0;
      Matrix[2,1] := 0;
      Matrix[2,2] := 1;
      Matrix[2,3] := 0;

      Matrix[3,0] := 0;
      Matrix[3,1] := 0;
      Matrix[3,2] := 0;
      Matrix[3,3] := 1;
   end;

   glMultMatrixf(@Matrix[0,0]);
end;

Procedure THVA.MovePosition(_Frame,_Section : Integer; _X,_Y,_Z : single);
var
   HVAD : integer;
begin
   HVAD := _Frame*Header.N_Sections+_Section;

   TransformMatrices[HVAD][1][4] := TransformMatrices[HVAD][1][4] + (_X);
   TransformMatrices[HVAD][2][4] := TransformMatrices[HVAD][2][4] + (_Y);
   TransformMatrices[HVAD][3][4] := TransformMatrices[HVAD][3][4] + (_Z);
end;

Procedure THVA.SetPosition(_Frame,_Section : Integer; _Position : TVector3f);
var
   HVAD : integer;
   Det : single;
begin
   HVAD := _Frame*Header.N_Sections+_Section;
   Det := p_Voxel^.Section[_Section].Tailer.Det;

   TransformMatrices[HVAD][1][4] := _Position.X / Det;
   TransformMatrices[HVAD][2][4] := _Position.Y / Det;
   TransformMatrices[HVAD][3][4] := _Position.Z / Det;
end;

Function THVA.GetPosition(_Frame,_Section : Integer) : TVector3f;
var
   HVAD : integer;
   Det : single;
begin
   HVAD := _Frame*Header.N_Sections+_Section;
   Det := p_Voxel^.Section[_Section].Tailer.Det;

   Result := SetVector(0,0,0);

   if TransformMatrices[HVAD][1][4] > 0 then
      Result.X := TransformMatrices[HVAD][1][4] * Det;
   if TransformMatrices[HVAD][2][4] > 0 then
      Result.Y := TransformMatrices[HVAD][2][4] * Det;
   if TransformMatrices[HVAD][3][4] > 0 then
      Result.Z := TransformMatrices[HVAD][3][4] * Det;
end;

Function THVA.GetAngle_RAD(_Section,_Frames : Integer) : TVector3f;
var
   cy,x,y,z : single;
   M : TMatrix;
   T : TTransformations;
begin
   M := GetMatrix(_Section,_Frames);

   MatrixDecompose(M,T);

   Result.X := T[ttRotateX];
   Result.Y := T[ttRotateY];
   Result.Z := T[ttRotateZ];
end;

Function THVA.GetAngle_DEG(_Section,_Frames : Integer) : TVector3f;
var
   Angles : TVector3f;
begin
   Angles := GetAngle_RAD(_Section,_Frames);

   Result.X := RadToDeg(Angles.X);
   Result.Y := RadToDeg(Angles.Y);
   Result.Z := RadToDeg(Angles.Z);
end;

Function THVA.GetAngle_DEG_Correct(_Section,_Frames : Integer) : TVector3f;
var
   Angles : TVector3f;
begin
   Angles := GetAngle_RAD(_Section,_Frames);

   Result.X := CorrectAngle(RadToDeg(Angles.X));
   Result.Y := CorrectAngle(RadToDeg(Angles.Y));
   Result.Z := CorrectAngle(RadToDeg(Angles.Z));
end;

Function THVA.CorrectAngle(_Angle : Single) : Single;
var
   Ang90 : single;
begin
   Ang90 := Pi/2;
   If _Angle < (-Ang90) then
      _Angle := Pi + _Angle
   else if _Angle > Ang90 then
      _Angle := Ang90 - _Angle;

   Result := _Angle;
end;

Procedure THVA.SetTMValue(_Frame,_Section,_Row,_Col : Integer; _Value : single);
begin
   TransformMatrices[_Frame*Header.N_Sections+_Section][_Row][_Col] := _Value;
end;

Function THVA.SetAngle(_Section,_Frames : Integer; _x,_y,_z : single) : TVector3f;
var
   Angles,CosAngles,SinAngles : TVector3f;
   M : TMatrix;
begin
   M := GetMatrix(_Section,_Frames);

   M := Pitch(M,DegtoRad(_X));
   M := Turn(M,DegtoRad(_Y));
   M := Roll(M,DegtoRad(_Z));

   SetMatrix(M,_Frames,_Section);
end;

Procedure THVA.InsertFrame(FrameNumber : integer);
var
   x,i : integer;
   TransformMatricesTemp : array of TTransformMatrix;
begin
   // Prepare a temporary Transformation Matrix Copy.
   SetLength(TransformMatricesTemp,Header.N_Frames*Header.N_Sections);

   // Copy the transformation matrixes from the HVA to the temp
   for x := 0 to Header.N_Frames-1 do
      for i := 0 to Header.N_Sections-1 do
         GetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],i,x);

   // Increase the ammount of frames from the HVA.
   AddBlankFrame;

   // Copy all info from the frames till the current frame.
   if FrameNumber > 0 then
      for x := 0 to FrameNumber do
         for i := 0 to Header.N_Sections-1 do
            SetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],x,i);

   // Create new frames for the selected frame.
   ClearFrame(FrameNumber);

   // Copy the final part.
   if FrameNumber+1 < Header.N_Frames-1 then
      for x := FrameNumber+2 to Header.N_Frames-1 do
         for i := 0 to Header.N_Sections-1 do
            SetMatrix(TransformMatricesTemp[(x-1)*Header.N_Sections+i],x,i);
end;

procedure THVA.CopyTM(Source, Dest : integer);
var
   y,z,i : integer;
begin
   for i := 0 to Header.N_Sections-1 do
      for y := 1 to 3 do
         for z := 1 to 4 do
            TransformMatrices[(Dest)*Header.N_Sections+i][y][z] := TransformMatrices[(Source)*Header.N_Sections+i][y][z];
end;

Procedure THVA.CopyFrame(FrameNumber : integer);
var
   y,z,i : integer;
begin
   InsertFrame(FrameNumber);

   CopyTM(FrameNumber,FrameNumber+1);
end;

Procedure THVA.DeleteFrame(FrameNumber : Integer);
var
   x,i : integer;
   TransformMatricesTemp : array of TTransformMatrix;
begin
   // Prepare a temporary Transformation Matrix Copy.
   SetLength(TransformMatricesTemp,Header.N_Frames*Header.N_Sections);

   // Copy the transformation matrixes from the HVA to the temp
   for x := 0 to Header.N_Frames-1 do
      for i := 0 to Header.N_Sections-1 do
         GetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],i,x);

   // Copy all info from the frames till the current frame.
   if FrameNumber > 0 then
      for x := 0 to FrameNumber do
         for i := 0 to Header.N_Sections-1 do
            SetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],x,i);

   // Decrease the ammount of frames from the HVA.
   Dec(Header.N_Frames);
   SetLength(TransformMatrices,Header.N_Frames*Header.N_Sections);

   // Copy the final part.
   for x := FrameNumber+1 to Header.N_Frames-1 do
      for i := 0 to Header.N_Sections-1 do
         SetMatrix(TransformMatricesTemp[x*Header.N_Sections+i],x-1,i);
end;

{
procedure ClearHVA;
var
   Section : integer;
begin
   if High(HVAFile.Data) >= 0 then
   begin
      for Section := Low(HVAFile.Data) to High(HVAFile.Data) do
      begin
         SetLength(HVAFile.Data[Section].TransformMatrixs,0);
      end;
   end;
   SetLength(HVAFile.Data,1);
   HVAFrame := 0;
   HVASection := 0;
   HVAFile.Header.N_Frames := 1;
   HVAFile.Header.N_Sections := 1;
   SetLength(HVAFile.Data[0].TransformMatrixs,1);
   HVAFile.Data[0].TransformMatrixs[0] := GetIdentityTM;
   HVAFile.Data_no := 1;
end;

function LoadHVA(Filename : string): boolean;
var
   f : file;
   x,y : integer;
begin
   {$ifdef DEBUG_FILE}
 {
   FrmMain.DebugFile.Add('HVA: LoadHVA');
   {$endif}
{
   Result := false;
   try
      ClearHVA;
      AssignFile(F,Filename);  // Open file
      FileMode := fmOpenRead; // we only load HVA file [VK]
      Reset(F,1); // Goto first byte?

      BlockRead(F,HVAFile.Header,Sizeof(THVA_Main_Header)); // Read Header

      HVAFile.Data_no := HVAFile.Header.N_Sections;
      SetLength(HVAFile.Data,HVAFile.Data_no);

      For x := Low(HVAFile.Data) to High(HVAFile.Data) do
      begin
         BlockRead(F,HVAFile.Data[x].SectionName,Sizeof(TSectionName));
         SetLength(HVAFile.Data[x].TransformMatrixs,HVAFile.Header.N_Frames);
      end;

      For y := 0 to HVAFile.Header.N_Frames-1 do
      begin
         For x := Low(HVAFile.Data) to High(HVAFile.Data) do
         begin
            BlockRead(F,HVAFile.Data[x].TransformMatrixs[y],Sizeof(TTransformMatrix));
         end;
      end;

      if HVAFile.Header.N_Frames = 0 then
      begin
         HVAFile.Header.N_Frames := 1;
         For x := Low(HVAFile.Data) to High(HVAFile.Data) do
         begin
            SetLength(HVAFile.Data[x].TransformMatrixs,1);
            HVAFile.Data[x].TransformMatrixs[0] := GetIdentityTM;
         end;
      end;

      CloseFile(f);
   except on E : EInOutError do // VK 1.36 U
      MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
   end;
   Result := true;
end;

function GetIdentityTM : TTransformMatrix;
begin
   Result[1,1] := 1;
   Result[1,2] := 0;
   Result[1,3] := 0;
   Result[1,4] := 0;
   Result[2,1] := 0;
   Result[2,2] := 1;
   Result[2,3] := 0;
   Result[2,4] := 0;
   Result[3,1] := 0;
   Result[3,2] := 0;
   Result[3,3] := 1;
   Result[3,4] := 0;
end;

Function GetTMValue(Row,Col : integer) : single;
begin
   Result := HVAFile.Data[HVASection].TransformMatrixs[HVAFrame][Row][Col];
end;

Function GetTMValue(Row,Col,Section : integer) : single;
begin
   Result := HVAFile.Data[Section].TransformMatrixs[HVAFrame][Row][Col];
end;

Function ApplyMatrixVXL(V : TVector3f) : TVector3f;
var
   T : TVector3f;
begin
   T := V;
   with ActiveSection.Tailer do
   begin
      Result.X := ( T.x * Transform[1,1] + T.y * Transform[1,2] + T.z * Transform[1,3] + Transform[1,4]);
      Result.Y := ( T.x * Transform[2,1] + T.y * Transform[2,2] + T.z * Transform[2,3] + Transform[2,4]);
      Result.Z := ( T.x * Transform[3,1] + T.y * Transform[3,2] + T.z * Transform[3,3] + Transform[3,4]);
   end;
end;

// Copied from OS: Voxel Viewer.
Function ApplyMatrix(VoxelScale: TVector3f; Section, Frames : Integer) : TVector3f;
var
   Matrix : TGLMatrixf4;
   SectionDet : single;
begin
   if Section = -1 then
   begin
      Exit;
   end;

   SectionDet := VoxelFile.Section[Section].Tailer.Det;
   if HVAFile.Header.N_Sections > 0 then
   begin
      Matrix[0,0] := GetTMValue(1,1,Section);
      Matrix[0,1] := GetTMValue(2,1,Section);
      Matrix[0,2] := GetTMValue(3,1,Section);
      Matrix[0,3] := 0;

      Matrix[1,0] := GetTMValue(1,2,Section);
      Matrix[1,1] := GetTMValue(2,2,Section);
      Matrix[1,2] := GetTMValue(3,2,Section);
      Matrix[1,3] := 0;

      Matrix[2,0] := GetTMValue(1,3,Section);
      Matrix[2,1] := GetTMValue(2,3,Section);
      Matrix[2,2] := GetTMValue(3,3,Section);
      Matrix[2,3] := 0;

      Matrix[3,0] := GetTMValue(1,4,Section) * VoxelScale.X * SectionDet;
      Matrix[3,1] := GetTMValue(2,4,Section) * VoxelScale.Y * SectionDet;
      Matrix[3,2] := GetTMValue(3,4,Section) * VoxelScale.Z * SectionDet;
      Matrix[3,3] := 1;
   end
   else
   begin
      Matrix[0,0] := 1;
      Matrix[0,1] := 0;
      Matrix[0,2] := 0;
      Matrix[0,3] := 0;

      Matrix[1,0] := 0;
      Matrix[1,1] := 1;
      Matrix[1,2] := 0;
      Matrix[1,3] := 0;

      Matrix[2,0] := 0;
      Matrix[2,1] := 0;
      Matrix[2,2] := 1;
      Matrix[2,3] := 0;

      Matrix[3,0] := SectionDet * VoxelScale.X;
      Matrix[3,1] := SectionDet * VoxelScale.Y;
      Matrix[3,2] := SectionDet * VoxelScale.Z;
      Matrix[3,3] := 1;
   end;
   glMultMatrixf(@Matrix[0,0]);
end;

Function Transform : TTransformMatrix;
var
   tmp : TTransformMatrix;
   i,j : integer;
begin
   with ActiveSection.Tailer do
   begin
      for i:=1 to 3 do
      begin
         tmp[i][3] := 0;
         for j:=1 to 4 do
         begin
            tmp[i][j] := GetTMValue(i,1)*Transform[1][j] + GetTMValue(i,2)*Transform[2][j] + GetTMValue(i,3)*Transform[3][j];
         end;
      end;
   end;
   Result := tmp;
end;

Function Transform2 : TTransformMatrix;
var
   tmp : TTransformMatrix;
   i,j : integer;
begin
   with ActiveSection.Tailer do
   begin
      for i:=1 to 3 do
      begin
         tmp[i][3] := 0;
         for j:=1 to 4 do
         begin
            tmp[i][j] := Transform[i][1]*GetTMValue(1,j)+
                         Transform[i][2]*GetTMValue(2,j)+
                         Transform[i][3]*GetTMValue(3,j);
         end;
         tmp[i][3] := tmp[i][3] + Transform[i][3];
      end;
   end;
   Result := tmp;
end;

Function Transform3 : TTransformMatrix;
var
tmp : TTransformMatrix;
i,j : integer;
begin
with ActiveSection.Tailer do
begin
    for i:=1 to 3 do
      begin
        for j:=1 to 4 do
          begin
            tmp[i][j] := Transform[i][j];
          end;
      end;
end;
    Result := tmp;
end;

Function ApplyMatrix(V : TVector3f) : TVector3f;
var
T,TT : TVector3f;
TempT : TTransformMatrix;
begin
TempT := Transform3;
  T := V;//ApplyMatrixVXL(V);
TT.X := TempT[1][4];
TT.Y := TempT[2][4];
TT.Z := TempT[3][4];
//Normalize(TT);
  Result.X := ( T.x * TempT[1][1] + T.y * TempT[1][2] + T.z * TempT[1][3] + (TT.X ));
  Result.Y := ( T.x * TempT[2][1] + T.y * TempT[2][2] + T.z * TempT[2][3] + (TT.Y ));
  Result.Z := ( T.x * TempT[3][1] + T.y * TempT[3][2] + T.z * TempT[3][3] + (TT.Z ));

//Normalize(T);
//Result := AddVector(Result,T);
  //Result := T;//ApplyMatrixVXL(T);
end;

Procedure FloodMatrix;
var
x,y : integer;
begin

for x := 1 to 3 do
for y := 1 to 4 do
HVAFile.Data[HVASection].TransformMatrixs[HVAFrame][x][y] := 0;

HVAFile.Data[HVASection].TransformMatrixs[HVAFrame][1][1] := 1;
HVAFile.Data[HVASection].TransformMatrixs[HVAFrame][2][2] := 1;
HVAFile.Data[HVASection].TransformMatrixs[HVAFrame][3][3] := 1;

end;

}
end.
