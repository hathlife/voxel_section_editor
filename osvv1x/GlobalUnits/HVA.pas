unit HVA;

// HVA Unit By Stucuk
// Written using the tibsun-hva.doc by The Profound Eol And DMV

interface

uses OpenGl15,geometry,dialogs,sysutils,math3d, voxel, math,VH_Types;

// Enable it for HVA debug purposes only.
//{$define DEBUG_HVA_FILE}

Procedure LoadHVA(Filename : string);
Procedure LoadHVA2(var HVAFile : THVA; var HVAOpen : Boolean; const Filename,Ext : string);

Procedure SaveHVA(Filename : string);
Procedure SaveHVA2(var HVAFile : THVA; const Filename,Ext : string);

procedure ClearHVA(var _HVA : THVA);

Function ApplyMatrix2(HVAFile : THVA; VoxelFile : TVoxel; V : TVector3f; Section,Frames : Integer) : TVector3f;
Function ApplyMatrix3(HVAFile : THVA; VoxelFile : TVoxel; V : TVector3f; Section, Frames : Integer) : TVector3f;

Procedure CreateHVA(const Vxl : TVoxel; var HVA : THVA);
Procedure SetHVAPos(Var HVA : THVA; Const Section : Integer; X,Y,Z : single);
Procedure SetHVAPos2(Var HVA : THVA; Const Voxel : TVoxel; Section : Integer; Position : TVector3f);
Function GetHVAPos(HVA : THVA; Voxel : TVoxel; Section : Integer) : TVector3f;

Function SETHVAAngle(var HVAFile : THVA; const Section,Frames : Integer; x,y,z : single) : TVector3f;
Function SETHVAAngle2(var HVAFile : THVA; const Section,Frames : Integer; x,y,z : single) : TVector3f;
Function GETHVAAngle_DEG(HVAFile : THVA; Section,Frames : Integer) : TVector3f;

Procedure AddHVAFrame(Var HVAFile : THVA);
Procedure InsertHVAFrame(Var HVAFile : THVA);
Procedure DeleteHVAFrame(Var HVAFile : THVA);
Procedure CopyHVAFrame(Var HVAFile : THVA);

Procedure SetCharArray(Name : String; Var CharArr : Array of Char);

Function GetCurrentFrame : Integer;
Function GetCurrentFrame2(_Type : Integer) : Integer;
Procedure SetCurrentFrame(Value : Integer);
Function GetCurrentHVA : PHVA;
Function GetCurrentHVAB : Boolean;

Function GetTMValue2(HVAFile : THVA; Row,Col,Section,Frames : integer) : single;

implementation

Uses VH_Global;

Procedure LoadHVA(Filename : string);
begin
   LoadHVA2(HVAFile,HVAOpen,Filename,'.hva');
   If not HVAOpen then
      CreateHVA(VoxelFile,HVAFile);

   CurrentHVA := @HVAFile;

   If VoxelOpenT then
   begin
      LoadHVA2(HVATurret,HVAOpenT,Filename,'tur.hva');
      If not HVAOpenT then
         CreateHVA(VoxelTurret,HVATurret);
   end
   else
   begin
      if HVAOpenT then
         ClearHVA(HVATurret);
      HVAOpenT := false;
   end;

   If VoxelOpenB then
   begin
      LoadHVA2(HVABarrel,HVAOpenB,Filename,'barl.hva');
      If not HVAOpenB then
         CreateHVA(VoxelBarrel,HVABarrel);
   end
   else
   begin
      if HVAOpenB then
         ClearHVA(HVABarrel);
      HVAOpenB := false;
   end;
end;

Procedure LoadHVA2(var HVAFile : THVA; var HVAOpen : Boolean; const Filename,Ext : string);
var
   f : file;
   x : integer;
   TFilename : string;
begin
   if HVAOpen then
      ClearHVA(HVAFile);
   TFilename := extractfiledir(Filename) + '\' + copy(Extractfilename(Filename),1,Length(Extractfilename(Filename))-Length('.hva')) + Ext;
   HVAOpen := false;
   if not FileExists(TFilename) then
      exit;

   AssignFile(F,TFilename);  // Open file
   Reset(F,1); // Goto first byte?

   BlockRead(F,HVAFile.Header,Sizeof(THVA_Main_Header)); // Read Header

   HVAFile.Data_no := HVAFile.Header.N_Sections;
   SetLength(HVAFile.Data,HVAFile.Data_no);

   For x := 0 to HVAFile.Header.N_Sections-1 do
      BlockRead(F,HVAFile.Data[x].SectionName,Sizeof(TSectionName));

   SetLength(HVAFile.TransformMatrixs,HVAFile.Header.N_Frames*HVAFile.Header.N_Sections);

   For x := 0 to HVAFile.Header.N_Sections * HVAFile.Header.N_Frames-1 do
      BlockRead(F,HVAFile.TransformMatrixs[x],Sizeof(TTransformMatrix));

   CloseFile(f);
   HVAOpen := True;
   If HVAFile.Header.N_Frames < 1 then
      HVAOpen := False;
   // Clear memory
   TFilename := '';
end;

Procedure SaveHVA(Filename : string);
begin
   SaveHVA2(HVAFile,Filename,'.hva');

   // Save Turret And Barrel
   if VoxelOpenT then
      SaveHVA2(HVATurret,Filename,'tur.hva');

   if VoxelOpenB then
      SaveHVA2(HVABarrel,Filename,'barl.hva');
end;

procedure ClearHVA(var _HVA : THVA);
begin
   SetLength(_HVA.Data, 0);
   SetLength(_HVA.TransformMatrixs, 0);
   _HVA.Data_no := 0;
   _HVA.HigherLevel := nil;
   _HVA.Header.N_Frames := 0;
   _HVA.Header.N_Sections := 0;
end;

Procedure SaveHVA2(var HVAFile : THVA; const Filename,Ext : string);
var
   f : file;
   wrote,x : integer;
   TFilename : string;
begin
   TFilename := extractfiledir(Filename) + '\' + copy(Extractfilename(Filename),1,Length(Extractfilename(Filename))-Length('.hva')) + Ext;

   //SetCharArray('',HVAFile.Header.FilePath);
   for x := 1 to 16 do
      HVAFile.Header.FilePath[x] := #0;

   AssignFile(F,TFilename);  // Open file
   Rewrite(F,1); // Goto first byte?

   BlockWrite(F,HVAFile.Header,Sizeof(THVA_Main_Header),wrote); // Write Header

   {$ifdef DEBUG_HVA_FILE}
   Showmessage(TFilename);
   showmessage(inttostr(HVAFile.Header.N_Sections));
   showmessage(inttostr(HVAFile.Header.N_Frames));
   showmessage(inttostr(wrote));
   {$endif}

   For x := 0 to HVAFile.Header.N_Sections-1 do
      BlockWrite(F,HVAFile.Data[x].SectionName,Sizeof(TSectionName),wrote);

  {$ifdef DEBUG_HVA_FILE}
  showmessage(inttostr(wrote));
  {$endif}

   For x := 0 to HVAFile.Header.N_Sections * HVAFile.Header.N_Frames-1 do
      BlockWrite(F,HVAFile.TransformMatrixs[x],Sizeof(TTransformMatrix),wrote);

   {$ifdef DEBUG_HVA_FILE}
   showmessage(inttostr(wrote));
   {$endif}

   // Clear memory
   CloseFile(f);
   TFilename := '';
end;

Function GetTMValue2(HVAFile : THVA; Row,Col,Section,Frames : integer) : single;
begin
   Result := HVAFile.TransformMatrixs[Frames*HVAFile.Header.N_Sections+Section][Row][Col];
end;

Function ApplyMatrix3(HVAFile : THVA; VoxelFile : TVoxel; V : TVector3f; Section, Frames : Integer) : TVector3f;
var
   Matrix : TGLMatrixf4;
begin
   if Section = -1 then
   begin
      Exit;
   end;

   HVAScale := VoxelFile.Section[Section].Tailer.Det;
//   if HVAScale = 0 then HVAScale := 1;

   Matrix[0,0] := GetTMValue2(HVAFile,1,1,Section,Frames);
   Matrix[0,1] := GetTMValue2(HVAFile,2,1,Section,Frames);
   Matrix[0,2] := GetTMValue2(HVAFile,3,1,Section,Frames);
   Matrix[0,3] := 0;

   Matrix[1,0] := GetTMValue2(HVAFile,1,2,Section,Frames);
   Matrix[1,1] := GetTMValue2(HVAFile,2,2,Section,Frames);
   Matrix[1,2] := GetTMValue2(HVAFile,3,2,Section,Frames);
   Matrix[1,3] := 0;

   Matrix[2,0] := GetTMValue2(HVAFile,1,3,Section,Frames);
   Matrix[2,1] := GetTMValue2(HVAFile,2,3,Section,Frames);
   Matrix[2,2] := GetTMValue2(HVAFile,3,3,Section,Frames);
   Matrix[2,3] := 0;

   Matrix[3,0] := (GetTMValue2(HVAFile,1,4,Section,Frames)* HVAScale) * V.X * 2;
   Matrix[3,1] := (GetTMValue2(HVAFile,2,4,Section,Frames)* HVAScale) * V.Y * 2;
   Matrix[3,2] := (GetTMValue2(HVAFile,3,4,Section,Frames)* HVAScale) * V.Z * 2;
   Matrix[3,3] := 1;

   glMultMatrixf(@Matrix[0,0]);
end;

Function ApplyMatrix2(HVAFile : THVA; VoxelFile : TVoxel; V : TVector3f; Section, Frames : Integer) : TVector3f;
begin
   if Section = -1 then
   begin
      Result := V;
      Exit;
   end;

   HVAScale := VoxelFile.Section[Section].Tailer.Det;
   if HVAScale = 0 then HVAScale := 1;

   Result.X := ( V.x * GetTMValue2(HVAFile,1,1,Section,Frames) + V.y * GetTMValue2(HVAFile,1,2,Section,Frames) + V.z * GetTMValue2(HVAFile,1,3,Section,Frames) + GetTMValue2(HVAFile,1,4,Section,Frames) * HVAScale);
   Result.Y := ( V.x * GetTMValue2(HVAFile,2,1,Section,Frames) + V.y * GetTMValue2(HVAFile,2,2,Section,Frames) + V.z * GetTMValue2(HVAFile,2,3,Section,Frames) + GetTMValue2(HVAFile,2,4,Section,Frames) * HVAScale);
   Result.Z := ( V.x * GetTMValue2(HVAFile,3,1,Section,Frames) + V.y * GetTMValue2(HVAFile,3,2,Section,Frames) + V.z * GetTMValue2(HVAFile,3,3,Section,Frames) + GetTMValue2(HVAFile,3,4,Section,Frames) * HVAScale);
end;

Procedure ClearMatrix(Var TM : TTransformMatrix);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         TM[x][y] := 0;

   TM[1][1] := 1;
   TM[2][2] := 1;
   TM[3][3] := 1;
end;

Function CreateTM : TTransformMatrix;
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         Result[x][y] := 0;

   Result[1][1] := 1;
   Result[2][2] := 1;
   Result[3][3] := 1;
end;

Procedure SetCharArray(Name : String; Var CharArr : Array of Char);
const
   MAX_LEN = 16;
var
   i: integer;
begin
   for i:=1 to 16 do
      CharArr[i]:=' ';
   for i := 1 to Length(Name) do
   begin
      if i > MAX_LEN then
         break;
      CharArr[i] := Name[i];
   end;
end;

Procedure CreateHVA(const Vxl : TVoxel; var HVA : THVA);
var
   i,x : integer;
   //S : string;
begin
   if (Vxl = nil) or (not Vxl.Loaded) then
      exit;

   HVA.Header.N_Frames := 1;
   HVA.Header.N_Sections := Vxl.Header.NumSections;

   {S := 'OS_HVA_BUILDER  ';

   for i := 1 to length(S) do
      HVA.Header.FilePath[i] := s[i];                    }

   //SetCharArray('OS_HVA_BUILDER',HVA.Header.FilePath);
   for x := 1 to 16 do
      HVAFile.Header.FilePath[x] := #0;

   HVA.Data_no := HVA.Header.N_Sections;
   Setlength(HVA.Data,HVA.Data_no);

   for i := 0 to Vxl.Header.NumSections-1 do
      for x := 1 to 16 do
         HVA.Data[i].SectionName[x] := vxl.section[i].Header.Name[x];

   Setlength(HVA.TransformMatrixs,HVA.Data_no);

   for i := 0 to Vxl.Header.NumSections-1 do
      HVA.TransformMatrixs[i] := CreateTM;
end;

Procedure SetHVAPos(Var HVA : THVA; Const Section : Integer; X,Y,Z : single);
var
   HVAD : integer;
begin
   HVAD := HVAFrame*HVA.Header.N_Sections+Section;

   HVA.TransformMatrixs[HVAD][1][4] := HVA.TransformMatrixs[HVAD][1][4] + (X);
   HVA.TransformMatrixs[HVAD][2][4] := HVA.TransformMatrixs[HVAD][2][4] + (Y);
   HVA.TransformMatrixs[HVAD][3][4] := HVA.TransformMatrixs[HVAD][3][4] + (Z);
end;

Procedure SetHVAPos2(Var HVA : THVA; Const Voxel : TVoxel; Section : Integer; Position : TVector3f);
var
   HVAD : integer;
   Det : single;
begin
   HVAD := HVAFrame*HVA.Header.N_Sections+Section;
   Det := Voxel.Section[Section].Tailer.Det;

   HVA.TransformMatrixs[HVAD][1][4] := Position.X / Det;
   HVA.TransformMatrixs[HVAD][2][4] := Position.Y / Det;
   HVA.TransformMatrixs[HVAD][3][4] := Position.Z / Det;
end;

Function GetHVAPos(HVA : THVA; Voxel : TVoxel; Section : Integer) : TVector3f;
var
   HVAD : integer;
   Det : single;
begin
   HVAD := HVAFrame*HVA.Header.N_Sections+Section;
   Det := Voxel.Section[Section].Tailer.Det;

   Result := SetVector(0,0,0);

   if HVA.TransformMatrixs[HVAD][1][4] > 0 then
      Result.X := HVA.TransformMatrixs[HVAD][1][4] * Det;
   if HVA.TransformMatrixs[HVAD][2][4] > 0 then
      Result.Y := HVA.TransformMatrixs[HVAD][2][4] * Det;
   if HVA.TransformMatrixs[HVAD][3][4] > 0 then
      Result.Z := HVA.TransformMatrixs[HVAD][3][4] * Det;
end;

Procedure AddHVAFrame(Var HVAFile : THVA);
var
   x : integer;
begin
   HVAFile.Header.N_Frames := HVAFile.Header.N_Frames + 1;

   SetLength(HVAFile.TransformMatrixs,HVAFile.Header.N_Frames*HVAFile.Header.N_Sections);

   for x := 0 to HVAFile.Header.N_Sections-1 do
      HVAFile.TransformMatrixs[(HVAFile.Header.N_Frames-1)*HVAFile.Header.N_Sections+x] := CreateTM;
end;

Function HVAToMatrix(HVAFile : THVA; Section,Frames : Integer) : TMatrix;
var
   x,y : integer;
begin
   Result := IdentityMatrix;

   for x := 1 to 3 do
      for y := 1 to 4 do
         Result[x-1][y-1] := GetTMValue2(HVAFile,x,y,Section,Frames);
end;

Procedure MatrixToHVA(var HVAFile : THVA; const M : TMatrix; Section : Integer);
var
   x,y : integer;
begin
   for x := 1 to 3 do
      for y := 1 to 4 do
         HVAFile.TransformMatrixs[HVAFrame*HVAFile.Header.N_Sections+Section][x][y] := m[x-1][y-1];
end;

Function GETHVAAngle_RAD(HVAFile : THVA; Section,Frames : Integer) : TVector3f;
var
   M : TMatrix;
   T : TTransformations;
begin
   M := HVAToMatrix(HVAFile,Section,Frames);

   MatrixDecompose(M,T);

   Result.X := T[ttRotateX];
   Result.Y := T[ttRotateY];
   Result.Z := T[ttRotateZ];
         {
   for x := 0 to 2 do
      M[3][x] := 0;

   M[3][3] := 1; }
                                           {
   SETHVATM(HVAFile,Section,1,1,CosAngles.Y*CosAngles.Z);
   SETHVATM(HVAFile,Section,1,2,-(CosAngles.Y*SinAngles.Z));
   SETHVATM(HVAFile,Section,1,3,-(SinAngles.Y));

   SETHVATM(HVAFile,Section,2,1,(CosAngles.X*SinAngles.Z)-(SinAngles.X*SinAngles.Y*CosAngles.Z));
   SETHVATM(HVAFile,Section,2,2,(SinAngles.X*SinAngles.Y*SinAngles.Z)+(CosAngles.X*CosAngles.Z));
   SETHVATM(HVAFile,Section,2,3,-(SinAngles.X*CosAngles.Y));

   SETHVATM(HVAFile,Section,3,1,(CosAngles.X*SinAngles.Y*CosAngles.Z)+(SinAngles.X*SinAngles.Z));
   SETHVATM(HVAFile,Section,3,2,(SinAngles.X*CosAngles.Z)-(CosAngles.X*SinAngles.Y*SinAngles.Z));
   SETHVATM(HVAFile,Section,3,3,(CosAngles.X*CosAngles.Y));}
              {
   Y := ArcSin(-GetTMValue2(HVAFile,1,3,Section));
   cy := Cos(Y);
   Z := ArcSin((-GetTMValue2(HVAFile,1,2,Section))/cy);
   X := ArcSin((-GetTMValue2(HVAFile,2,3,Section))/cy);

   Result.X := X;
   Result.Y := Y;
   Result.Z := Z;  }
end;

Function GETHVAAngle_DEG(HVAFile : THVA; Section,Frames : Integer) : TVector3f;
var
   Angles : TVector3f;
begin
   Angles := GETHVAAngle_RAD(HVAFile,Section,Frames);

   Result.X := RadToDeg(Angles.X);
   Result.Y := RadToDeg(Angles.Y);
   Result.Z := RadToDeg(Angles.Z);
end;

Function CorrectAngle(Angle : Single) : Single;
begin
   Angle := RadToDeg(Angle);

   If Angle < -90 then
      Angle := 180 + Angle;

   If Angle > 90 then
      Angle := 90 - Angle;

   Result := DegToRad(Angle);
end;

Function CorrectAngles(Angle : TVector3f) : TVector3f;
var
   Angles : TVector3f;
begin
   Angles.X := CorrectAngle(Angle.X);
   Angles.Y := CorrectAngle(Angle.Y);
   Angles.Z := CorrectAngle(Angle.Z);

   Result := Angles;
end;

Procedure SETHVATM(var HVAFile : THVA; const Section,Row,Col : Integer; Value : single);
begin
   HVAFile.TransformMatrixs[HVAFrame*HVAFile.Header.N_Sections+Section][Row][Col] := Value;
end;

Function SETHVAAngle(var HVAFile : THVA; const Section,Frames : Integer; x,y,z : single) : TVector3f;
var
   M : TMatrix;
begin
   M := HVAToMatrix(HVAFile,Section,Frames);

   M := Pitch(M,DegtoRad(X));
   M := Turn(M,DegtoRad(Y));
   M := Roll(M,DegtoRad(Z));

   MatrixToHVA(HVAFile,M,Section);
end;

Function SETHVAAngle2(var HVAFile : THVA; const Section,Frames : Integer; x,y,z : single) : TVector3f;
var
   Angles,NewAngles,N : TVector3f;
   M : TMatrix;
begin
   M := HVAToMatrix(HVAFile,Section,Frames);

   Angles := GETHVAAngle_DEG(HVAFile,Section,Frames);
   NewAngles.X := X;
   NewAngles.Y := Y;
   NewAngles.Z := Z;

   N := SubtractVector(NewAngles,Angles);

   M := Pitch(M,DegtoRad(N.X));
   M := Turn(M,DegtoRad(N.Y));
   M := Roll(M,DegtoRad(N.Z));

   MatrixToHVA(HVAFile,M,Section);
             {
   Angles.X := DegToRad(X);
   Angles.Y := DegToRad(Y);
   Angles.Z := DegToRad(Z);

   CosAngles.X := Cos(Angles.X);
   CosAngles.Y := Cos(Angles.Y);
   CosAngles.Z := Cos(Angles.Z);

   SinAngles.X := Sin(Angles.X);
   SinAngles.Y := Sin(Angles.Y);
   SinAngles.Z := Sin(Angles.Z);

   SETHVATM(HVAFile,Section,1,1,CosAngles.Y*CosAngles.Z);
   SETHVATM(HVAFile,Section,1,2,-(CosAngles.Y*SinAngles.Z));
   SETHVATM(HVAFile,Section,1,3,-(SinAngles.Y));

   SETHVATM(HVAFile,Section,2,1,(CosAngles.X*SinAngles.Z)-(SinAngles.X*SinAngles.Y*CosAngles.Z));
   SETHVATM(HVAFile,Section,2,2,(SinAngles.X*SinAngles.Y*SinAngles.Z)+(CosAngles.X*CosAngles.Z));
   SETHVATM(HVAFile,Section,2,3,-(SinAngles.X*CosAngles.Y));

   SETHVATM(HVAFile,Section,3,1,(CosAngles.X*SinAngles.Y*CosAngles.Z)+(SinAngles.X*SinAngles.Z));
   SETHVATM(HVAFile,Section,3,2,(SinAngles.X*CosAngles.Z)-(CosAngles.X*SinAngles.Y*SinAngles.Z));
   SETHVATM(HVAFile,Section,3,3,(CosAngles.X*CosAngles.Y));
                               }
end;

Procedure InsertHVAFrame(Var HVAFile : THVA);
var
   x,y,z,i,Frames : integer;
   TransformMatrixs : array of TTransformMatrix;
begin
   If @HVAFile = @HVABarrel then
      Frames := HVAFrameB
   else If @HVAFile = @HVATurret then
      Frames := HVAFrameT
   else
      Frames := HVAFrame;

   SetLength(TransformMatrixs,HVAFile.Header.N_Frames*HVAFile.Header.N_Sections);

   for x := 0 to HVAFile.Header.N_Frames-1 do
      for i := 0 to HVAFile.Header.N_Sections-1 do
         for y := 1 to 3 do
            for z := 1 to 4 do
               TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z] := HVAFile.TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z];

   Inc(HVAFile.Header.N_Frames);

   SetLength(HVAFile.TransformMatrixs,HVAFile.Header.N_Frames*HVAFile.Header.N_Sections);

   if Frames > 0 then
      for x := 0 to Frames do
         for i := 0 to HVAFile.Header.N_Sections-1 do
            for y := 1 to 3 do
               for z := 1 to 4 do
                  HVAFile.TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z] := TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z];

   for i := 0 to HVAFile.Header.N_Sections-1 do
      HVAFile.TransformMatrixs[(Frames+1)*HVAFile.Header.N_Sections+i] := CreateTM;

   if Frames+1 < HVAFile.Header.N_Frames-1 then
      for x := Frames+2 to HVAFile.Header.N_Frames-1 do
         for i := 0 to HVAFile.Header.N_Sections-1 do
            for y := 1 to 3 do
               for z := 1 to 4 do
                  HVAFile.TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z] := TransformMatrixs[(x-1)*HVAFile.Header.N_Sections+i][y][z];
   // Clear memory
   SetLength(TransformMatrixs,0);
end;

Procedure CopyHVAFrame(Var HVAFile : THVA);
var
   y,z,i,Frames : integer;
begin
   If @HVAFile = @HVABarrel then
      Frames := HVAFrameB
   else If @HVAFile = @HVATurret then
      Frames := HVAFrameT
   else
      Frames := HVAFrame;

   InsertHVAFrame(HVAFile);

   for i := 0 to HVAFile.Header.N_Sections-1 do
      for y := 1 to 3 do
         for z := 1 to 4 do
            HVAFile.TransformMatrixs[(Frames+1)*HVAFile.Header.N_Sections+i][y][z] := HVAFile.TransformMatrixs[(Frames)*HVAFile.Header.N_Sections+i][y][z];
end;

Procedure DeleteHVAFrame(Var HVAFile : THVA);
var
   x,y,z,i,Frames : integer;
   TransformMatrixs : array of TTransformMatrix;
begin
   If @HVAFile = @HVABarrel then
      Frames := HVAFrameB
   else If @HVAFile = @HVATurret then
      Frames := HVAFrameT
   else
      Frames := HVAFrame;

   SetLength(TransformMatrixs,HVAFile.Header.N_Frames*HVAFile.Header.N_Sections);

   for x := 0 to HVAFile.Header.N_Frames-1 do
      for i := 0 to HVAFile.Header.N_Sections-1 do
         for y := 1 to 3 do
            for z := 1 to 4 do
               TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z] := HVAFile.TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z];

   if Frames > 0 then
      for x := 0 to Frames do
         for i := 0 to HVAFile.Header.N_Sections-1 do
            for y := 1 to 3 do
               for z := 1 to 4 do
                  HVAFile.TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z] := TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z];

   Dec(HVAFile.Header.N_Frames);

   SetLength(HVAFile.TransformMatrixs,HVAFile.Header.N_Frames*HVAFile.Header.N_Sections);

   for x := Frames+1 to HVAFile.Header.N_Frames-1 do
      for i := 0 to HVAFile.Header.N_Sections-1 do
         for y := 1 to 3 do
            for z := 1 to 4 do
               HVAFile.TransformMatrixs[(x-1)*HVAFile.Header.N_Sections+i][y][z] := TransformMatrixs[x*HVAFile.Header.N_Sections+i][y][z];
end;

Function GetCurrentFrame : Integer;
begin
   if HVACurrentFrame = 1 then
      Result := HVAFrameT
   else if HVACurrentFrame = 2 then
      Result := HVAFrameB
   else
      Result := HVAFrame;
end;

Function GetCurrentFrame2(_Type : Integer) : Integer;
begin
   Result := 0;

   if HVACurrentFrame <> _Type then exit;

   if HVACurrentFrame = 1 then
      Result := HVAFrameT
   else if HVACurrentFrame = 2 then
      Result := HVAFrameB
   else
      Result := HVAFrame;
end;

procedure SetCurrentFrame(Value : Integer);
begin
   if HVACurrentFrame = 1 then
      HVAFrameT := Value
   else if HVACurrentFrame = 2 then
      HVAFrameB := Value
   else
      HVAFrame := Value;
end;

Function GetCurrentHVA : PHVA;
begin
   if HVACurrentFrame = 1 then
      Result := @HVATurret
   else if HVACurrentFrame = 2 then
      Result := @HVABarrel
   else
      Result := @HVAFile;
end;

Function GetCurrentHVAB : Boolean;
begin
   if HVACurrentFrame = 1 then
      Result := HVAOpenT
   else if HVACurrentFrame = 2 then
      Result := HVAOpenB
   else
      Result := HVAOpen;
end;

end.
