unit ClassTopologyAnalyzer;

interface

uses Voxel, VoxelMap;

type
   CTopologyAnalyzer = class
      private
         FMap: TVoxelMap;
      public
         NumVoxels,NumCorrect,Num1Face,Num2Faces,Num3Faces,NumLoneVoxels : longword;
         // Constructors and Destructors.
         constructor Create(const _Map: TVoxelMap); overload;
         constructor Create(const _Voxel: TVoxelSection); overload;
         destructor Destroy; override;
         procedure ResetCounters;
         // Execute.
         procedure Execute();
   end;

implementation

uses Normals, BasicDataTypes, BasicConstants, GLConstants;

// Constructors and Destructors.
constructor CTopologyAnalyzer.Create(const _Map: TVoxelMap);
begin
   FMap.Assign(_Map);
   Execute;
end;

constructor CTopologyAnalyzer.Create(const _Voxel: TVoxelSection);
begin
   FMap := TVoxelMap.Create(_Voxel,1);
   FMap.GenerateSurfaceMap;
   Execute;
end;

destructor CTopologyAnalyzer.Destroy;
begin
   FMap.Free;
   inherited Destroy;
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

// Execute.
procedure CTopologyAnalyzer.Execute();
var
   Cube : TNormals;
   Direction : TVector3f;
   x, y, z, i: longword;
   AxisFaces,maxi: byte;
begin
   ResetCounters;
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


end.
