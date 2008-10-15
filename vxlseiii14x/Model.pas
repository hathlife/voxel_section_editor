unit Model;

interface

uses Palette, HVA, Mesh;

type
   PModel = ^TModel;
   TModel = class
   public
      Next : PModel;
      Palette : PPalette;
      // Skeleton:
      HVA : PHVA;
      Mesh : array of TMesh;
   end;

implementation

end.
