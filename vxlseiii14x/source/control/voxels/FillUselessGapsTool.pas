unit FillUselessGapsTool;

interface

uses BasicDataTypes, Voxel, VoxelMap;

type
   TFillUselessGapsTool = class
      private
         FRayMap: TVoxelMap;
      public
         // Constructors and Destructors
         constructor Create(var _Voxel: TVoxelSection); overload;
         destructor Destroy; override;
         // Execute
         procedure FillCaves(var _Voxel: TVoxelSection; _min, _max, _Colour: integer); overload;
         procedure FillCaves(var _Voxel: TVoxelSection); overload;
   end;

implementation

uses BasicConstants;

// Constructors and Destructors
constructor TFillUselessGapsTool.Create(var _Voxel: TVoxelSection);
begin
   FRayMap := TVoxelMap.CreateQuick(_Voxel,1);
   FRayMap.GenerateRayCastingMap();
end;

destructor TFillUselessGapsTool.Destroy;
begin
   FRayMap.Free;
   inherited Destroy;
end;

// Execute
procedure TFillUselessGapsTool.FillCaves(var _Voxel: TVoxelSection; _min, _max, _Colour: integer);
var
   x, y, z : integer;
   V : TVoxelUnpacked;
begin
   for x := Low(_Voxel.Data) to High(_Voxel.Data) do
      for y := Low(_Voxel.Data[0]) to High(_Voxel.Data[0]) do
         for z := Low(_Voxel.Data[0,0]) to High(_Voxel.Data[0,0]) do
         begin
            if (FRayMap.Map[x + 1, y + 1, z + 1] >= _Min) and (FRayMap.Map[x + 1, y + 1, z + 1] <= _Max) then
            begin
               _Voxel.GetVoxel(x,y,z,v);
               if not v.Used then
               begin
                  v.Used := true;
                  v.Colour := _Colour;   // Default: 63, Black
                  _Voxel.SetVoxel(x,y,z,v);
               end;
            end;
         end;

end;

procedure TFillUselessGapsTool.FillCaves(var _Voxel: TVoxelSection);
begin
   FillCaves(_Voxel,0,3,63);
end;


end.
