unit HVA;

// HVA Unit By Stucuk
// Written using the tibsun-hva.doc by The Profound Eol
{$INCLUDE Global_Conditionals.inc}

interface

uses dialogs,sysutils,Voxel_Engine,math3d;

type
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

Procedure LoadHVA(Filename : string);

Function ApplyMatrix(V : TVector3f) : TVector3f;
Procedure FloodMatrix;

implementation

uses FormMain;

Procedure LoadHVA(Filename : string);
var
   f : file;
   x,y : integer;
begin
   {$ifdef DEBUG_FILE}
   FrmMain.DebugFile.Add('HVA: LoadHVA');
   {$endif}
   try
      AssignFile(F,Filename);  // Open file
      FileMode := fmOpenRead; // we only load HVA file [VK]
      Reset(F,1); // Goto first byte?

      BlockRead(F,HVAFile.Header,Sizeof(THVA_Main_Header)); // Read Header

      HVAFile.Data_no := HVAFile.Header.N_Sections;
      SetLength(HVAFile.Data,HVAFile.Data_no);

      For x := 0 to HVAFile.Header.N_Sections-1 do
         BlockRead(F,HVAFile.Data[x].SectionName,Sizeof(TSectionName));

      For x := 0 to HVAFile.Header.N_Sections-1 do
      begin
         SetLength(HVAFile.Data[x].TransformMatrixs,HVAFile.Header.N_Frames);
         For y := 0 to HVAFile.Header.N_Frames-1 do
            BlockRead(F,HVAFile.Data[x].TransformMatrixs[y],Sizeof(TTransformMatrix));
      end;

      CloseFile(f);
   except on E : EInOutError do // VK 1.36 U
      MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
   end;
end;

Function GetTMValue(Row,Col : integer) : single;
begin
   Result := HVAFile.Data[HVASection].TransformMatrixs[HVAFrame][Row][Col];
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
            tmp[i][j] := {GetTMValue(i,j) +} Transform[i][j];
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
  Result.X := ( T.x * TempT[1][1] + T.y * TempT[1][2] + T.z * TempT[1][3] + (TT.X {TempT[1][4]}{*Transform[1,4]}));
  Result.Y := ( T.x * TempT[2][1] + T.y * TempT[2][2] + T.z * TempT[2][3] + (TT.Y {TempT[2][4]}{*Transform[2,4]}));
  Result.Z := ( T.x * TempT[3][1] + T.y * TempT[3][2] + T.z * TempT[3][3] + (TT.Z {TempT[3][4]}{*Transform[3,4]}));

{t.x := GetTMValue(1,4);
t.y := GetTMValue(2,4);
t.z := GetTMValue(3,4);  }
//Normalize(T);
//Result := AddVector(Result,T);
{Result.X := Result.X / TempT[1][1];
Result.Y := Result.Y / TempT[2][2];
Result.Z := Result.Z / TempT[3][3];   }
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


end.
