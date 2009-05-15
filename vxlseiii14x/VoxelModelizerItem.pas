unit VoxelModelizerItem;

interface

uses BasicFunctions, BasicDataTypes;

type
   TVoxelModelizerItem = class
      private
      public
         // Region as a cube
         FilledVerts : array[0..7] of boolean;
         FilledEdges: array[0..11] of boolean;
         FilledFaces: array[0..5] of boolean;
         // Situation per face and its edges.
         CubeSettings: array[0..5,0..4] of byte;
   end;

implementation

end.
