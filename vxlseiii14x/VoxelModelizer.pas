unit VoxelModelizer;

interface

uses VoxelMap, BasicDataTypes, VoxelModelizerItem;

type
   TVoxelModelizer = class
      private
         FMap : T3DIntGrid;
         FItems : TVoxelModelizerItem;
         PVoxelMap : PVoxelMap;
         PSemiSurfacesMap : P3DIntGrid;
      public
         // Constructors and Destructors
         constructor Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid);
   end;

implementation

constructor TVoxelModelizer.Create(const _VoxelMap : TVoxelMap; const _SemiSurfaces: T3DIntGrid);
begin
   PVoxelMap := @_VoxelMap;
   PSemiSurfacesMap := @_SemiSurfaces;
end;


end.
