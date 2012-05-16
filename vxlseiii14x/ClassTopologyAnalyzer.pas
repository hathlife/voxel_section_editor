unit ClassTopologyAnalyzer;

interface

uses Voxel, VoxelMap;

type
   CTopologyAnalyzer = class
      private
         FMap: TVoxelMap;
         // I/O
         procedure LoadVoxel(const _Voxel:TVoxelSection);
      public
         NumVoxels,NumCorrect,Num1Face,Num2Faces,Num3Faces,NumLoneVoxels : longword;
         // Constructors and Destructors.
         constructor Create(const _Map: TVoxelMap); overload;
         constructor Create(const _Voxel: TVoxelSection); overload;
         destructor Destroy; override;
         procedure Clear;
         procedure ResetCounters;
         // I/O
         procedure Load(const _Voxel:TVoxelSection);
         procedure LoadFullVoxel(const _Voxel: TVoxel);
         // Execute.
         procedure Execute();
         // Gets (GUI)
         function GetCorrectVoxelsText: string;
         function GetNum1FaceText: string;
         function GetNum2FacesText: string;
         function GetNum3FacesText: string;
         function GetLoneVoxelsText: string;
         function GetTotalVoxelsText: string;
         function GetTopologyScoreText: string;
         function GetClassificationText: string;
   end;

implementation

uses SysUtils, Normals, BasicDataTypes, BasicConstants, GLConstants;

// Constructors and Destructors.
constructor CTopologyAnalyzer.Create(const _Map: TVoxelMap);
begin
   FMap.Assign(_Map);
   ResetCounters;
   Execute;
end;

constructor CTopologyAnalyzer.Create(const _Voxel: TVoxelSection);
begin
   LoadVoxel(_Voxel);
end;

destructor CTopologyAnalyzer.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CTopologyAnalyzer.Clear;
begin
   FMap.Free;
end;

procedure CTopologyAnalyzer.ResetCounters;
begin
   NumVoxels := 0;
   NumCorrect := 0;
   Num1Face := 0;
   Num2Faces := 0;
   Num3Faces := 0;
   NumLoneVoxels := 0;
end;

// I/O
procedure CTopologyAnalyzer.Load(const _Voxel:TVoxelSection);
begin
   Clear;
   LoadVoxel(_Voxel);
end;

procedure CTopologyAnalyzer.LoadVoxel(const _Voxel:TVoxelSection);
begin
   FMap := TVoxelMap.Create(_Voxel,1);
   FMap.GenerateSurfaceMap;
   ResetCounters;
   Execute;
end;

procedure CTopologyAnalyzer.LoadFullVoxel(const _Voxel:TVoxel);
var
   i : integer;
begin
   ResetCounters;
   for i := 0 to (_Voxel.Header.NumSections-1) do
   begin
      Clear;
      FMap := TVoxelMap.Create(_Voxel.Section[i],1);
      FMap.GenerateSurfaceMap;
      Execute;
   end;
end;

// Execute.
procedure CTopologyAnalyzer.Execute();
var
   Cube : TNormals;
   Direction : TVector3f;
   x, y, z, i: longword;
   AxisFaces,maxi: byte;
begin
   for x := 0 to FMap.GetMaxX do
      for y := 0 to FMap.GetMaxY do
         for z := 0 to FMap.GetMaxZ do
         begin
            if FMap.Map[x,y,z] = C_SURFACE then
            begin
               AxisFaces := 0;
               if (FMap.Map[x-1,y,z] >= C_SURFACE) or (FMap.Map[x+1,y,z] >= C_SURFACE) then
               begin
                  inc(AxisFaces);
               end;
               if (FMap.Map[x,y-1,z] >= C_SURFACE) or (FMap.Map[x,y+1,z] >= C_SURFACE) then
               begin
                  inc(AxisFaces);
               end;
               if (FMap.Map[x,y,z-1] >= C_SURFACE) or (FMap.Map[x,y,z+1] >= C_SURFACE) then
               begin
                  inc(AxisFaces);
               end;
               case AxisFaces of
                  0:
                  begin
                     Cube := TNormals.Create(6);
                     maxi := Cube.GetLastID;
                     i := 0;
                     while i <= maxi do
                     begin
                        Direction := Cube[i];
                        if (FMap.Map[x + Round(Direction.X),y + Round(Direction.Y),z + Round(Direction.Z)] >= C_SURFACE) then
                        begin
                           inc(Num3Faces);
                           i := maxi * 2;
                        end
                        else
                        begin
                           inc(i);
                        end;
                     end;
                     if i < (maxi * 2) then
                     begin
                        inc(NumLoneVoxels);
                     end;
                  end;
                  1:
                  begin
                     inc(Num2Faces);
                  end;
                  2:
                  begin
                     inc(Num1Face);
                  end;
                  3:
                  begin
                     inc(NumCorrect);
                  end;
               end;
               inc(NumVoxels);
            end;
         end;
end;

// Gets
function CTopologyAnalyzer.GetCorrectVoxelsText: string;
begin
   Result := IntToStr(NumCorrect) + ' (' + FloatToStrF((100 * NumCorrect) / NumVoxels,ffFixed,12,2) + '%)';
end;

function CTopologyAnalyzer.GetNum1FaceText: string;
begin
   Result := IntToStr(Num1Face) + ' (' + FloatToStrF((100 * Num1Face) / NumVoxels,ffFixed,12,2) + '%)';
end;

function CTopologyAnalyzer.GetNum2FacesText: string;
begin
   Result := IntToStr(Num2Faces) + ' (' + FloatToStrF((100 * Num2Faces) / NumVoxels,ffFixed,12,2) + '%)';
end;

function CTopologyAnalyzer.GetNum3FacesText: string;
begin
   Result := IntToStr(Num3Faces) + ' (' + FloatToStrF((100 * Num3Faces) / NumVoxels,ffFixed,12,2) + '%)';
end;

function CTopologyAnalyzer.GetLoneVoxelsText: string;
begin
   Result := IntToStr(NumLoneVoxels) + ' (' + FloatToStrF((100 * NumLoneVoxels) / NumVoxels,ffFixed,12,2) + '%)';
end;

function CTopologyAnalyzer.GetTotalVoxelsText: string;
begin
   Result := IntToStr(NumVoxels);
end;

function CTopologyAnalyzer.GetTopologyScoreText: string;
var
   Score : single;
begin
   if NumLoneVoxels = 0 then
   begin
      Score := (100 * (NumCorrect - Num2Faces - (2*Num3Faces))) / NumVoxels;
      if Score > 0 then
      begin
         Result := FloatToStrF(Score,ffFixed,12,2) + ' points (out of 100)';
      end
      else
      begin
         Result := FloatToStrF(0,ffFixed,12,2) + ' points (out of 100)';
      end;
   end
   else
   begin
      Result := FloatToStrF(0,ffFixed,12,2) + ' points (out of 100)';
   end;
end;

function CTopologyAnalyzer.GetClassificationText: string;
begin
   if NumLoneVoxels > 0 then
   begin
      Result := 'Non-Manifold with Lone Voxels';
   end
   else if NumCorrect = NumVoxels then
   begin
      Result := 'Manifold Volume and Data Set, Unique Normals';
   end
   else if Num3Faces > 0 then
   begin
      Result := 'Non-Manifold Volume, Ambiguous Normals';
   end
   else if Num2Faces > 0 then
   begin
      Result := 'Manifold Volume, Ambiguous Normals';
   end
   else
   begin
      Result := 'Manifold Volume, Few Ambiguous Normals';
   end;
end;


end.
