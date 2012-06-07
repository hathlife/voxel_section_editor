unit ClassFillUselessGapsTool;

interface

uses BasicDataTypes, Voxel, VoxelMap;

type
   TFillUselessGapsTool = class
      private
         FMap,FRayMap: TVoxelMap;
      public
         constructor Create(var _Voxel: TVoxelSection); overload;
         destructor Destroy; override;
   end;

implementation

uses BasicConstants;

constructor TFillUselessGapsTool.Create(var _Voxel: TVoxelSection);
var
   x, y, z : integer;
   V : TVoxelUnpacked;
begin
   FMap := TVoxelMap.CreateQuick(_Voxel,1);
   FMap.GenerateUsedMap(1,0);
   FRayMap := TVoxelMap.CreateQuick(_Voxel,1);
   FRayMap.GenerateRayCastingMap(FMap);
   // Merge Map Data
   for x := Low(_Voxel.Data) to High(_Voxel.Data) do
      for y := Low(_Voxel.Data[0]) to High(_Voxel.Data[0]) do
         for z := Low(_Voxel.Data[0,0]) to High(_Voxel.Data[0,0]) do
         begin
            if (FRayMap.Map[x + 1, y + 1, z + 1] >= 0) and (FRayMap.Map[x + 1, y + 1, z + 1] <= 3) then
            begin
               _Voxel.GetVoxel(x,y,z,v);
               if not v.Used then
               begin
                  v.Used := true;
                  v.Colour := 63;   // Black
                  _Voxel.SetVoxel(x,y,z,v);
               end;
            end;
         end;
end;

destructor TFillUselessGapsTool.Destroy;
begin
   FRayMap.Free;
   FMap.Free;
   inherited Destroy;
end;

end.
