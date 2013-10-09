unit VolumeFaceVerifier;

// This class stores all faces (triangles or quads that a mesh extraction
// algorithm is building at each region. It's conceived to avoid quads or
// triangles being constructed at the same face. Check VoxelMeshGenerator.pas
// for its usage.

interface

uses BasicDataTypes, BasicConstants;

{$INCLUDE source/Global_Conditionals.inc}

type
   CVolumeFaceVerifier = class
      private
         function isPixelValid(_x, _y, _z: integer):boolean;
      public
         Items: array of array of array of TSurfaceDescriptiorItem;
         // Constructors and Destructors
         constructor Create(_xSize, _ySize, _zSize: integer);
         destructor Destroy; override;
         // Add
         procedure AddTriangle(const _Triangle: PTriangleItem; _x,_y,_z,_face: integer);
         procedure AddTriangleUnsafe(const _Triangle: PTriangleItem; _x,_y,_z,_face: integer);
         procedure AddQuad(const _Quad: PQuadItem; _x,_y,_z,_face: integer);
         procedure AddQuadUnsafe(const _Quad: PQuadItem; _x,_y,_z,_face: integer);
         // Delete
         procedure Clear;
   end;

implementation

{$ifdef MESH_TEST}
   uses GlobalVars, SysUtils;
{$endif}


constructor CVolumeFaceVerifier.Create(_xSize, _ySize, _zSize: integer);
var
   x,y,z: integer;
begin
   SetLength(Items,_xSize,_ySize,_zSize);
   for x := 0 to High(Items) do
      for y := 0 to High(Items[x]) do
         for z := 0 to High(Items[x,y]) do
         begin
            Items[x,y,z].Triangles[0] := nil;
            Items[x,y,z].Triangles[1] := nil;
            Items[x,y,z].Triangles[2] := nil;
            Items[x,y,z].Triangles[3] := nil;
            Items[x,y,z].Triangles[4] := nil;
            Items[x,y,z].Triangles[5] := nil;
            Items[x,y,z].Quads[0] := nil;
            Items[x,y,z].Quads[1] := nil;
            Items[x,y,z].Quads[2] := nil;
            Items[x,y,z].Quads[3] := nil;
            Items[x,y,z].Quads[4] := nil;
            Items[x,y,z].Quads[5] := nil;
         end;
end;

destructor CVolumeFaceVerifier.Destroy;
begin
   Clear;
   inherited Destroy;
end;

function CVolumeFaceVerifier.isPixelValid(_x, _y, _z: integer):boolean;
begin
   Result := (_x >= 0) and (_y >= 0) and (_z >= 0) and (_x <= High(Items)) and (_y <= High(Items[0])) and (_z <= High(Items[0,0]));
end;

// Add
procedure CVolumeFaceVerifier.AddTriangle(const _Triangle: PTriangleItem; _x,_y,_z,_face: integer);
begin
   if _Triangle <> nil then
   begin
      if (_Face >= 0) and (_Face < 6) then
      begin
         if isPixelValid(_x,_y,_z) then
         begin
            AddTriangleUnsafe(_Triangle,_x,_y,_z,_face);
         end;
      end;
   end;
end;

// Here we check if the cell (_x,_y,_z) has a triangle or a quad at the _face or
// if the neighbour cell has a triangle or quad at the opposite face. If that
// happens, we'll invalidate the new triangle and the existing triangle/quad.
// If that doesn't happen, we'll add the triangle at the cell and the opposite
// triangle at the neighbour.
procedure CVolumeFaceVerifier.AddTriangleUnsafe(const _Triangle: PTriangleItem; _x,_y,_z,_face: integer);
const
   SymmetricFaces: array [0..5] of byte = (1,0,3,2,5,4);
   SymmetricFaceLocation: array [0..5,0..2] of integer = ((-1,0,0),(1,0,0),(0,-1,0),(0,1,0),(0,0,-1),(0,0,1));
var
   xSF,ySF,zSF: integer;
begin
   xSF := _x + SymmetricFaceLocation[_face,0];
   ySF := _y + SymmetricFaceLocation[_face,1];
   zSF := _z + SymmetricFaceLocation[_face,2];
   if (Items[_x,_y,_z].Triangles[_face] <> nil) then
   begin
      // delete triangle.
      _Triangle^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Triangles[_face]^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Triangles[_face] := nil;
      {$ifdef MESH_TEST}
 	      GlobalVars.MeshFile.Add('Triangle construction has been aborted due to a triangle.');
      {$endif}
      if isPixelValid(xSF,ySF,zSF) then
      begin
         Items[xSF,ySF,zSF].Triangles[SymmetricFaces[_face]]^.v1 := C_VMG_NO_VERTEX;
         Items[xSF,ySF,zSF].Triangles[SymmetricFaces[_face]] := nil;
      end;
   end
   else if (Items[_x,_y,_z].Quads[_face] <> nil) then
   begin
      // delete quad
      _Triangle^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Quads[_face]^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Quads[_face] := nil;
      {$ifdef MESH_TEST}
 	      GlobalVars.MeshFile.Add('Triangle construction has been aborted due to a quad.');
      {$endif}
      if isPixelValid(xSF,ySF,zSF) then
      begin
         Items[xSF,ySF,zSF].Quads[SymmetricFaces[_face]]^.v1 := C_VMG_NO_VERTEX;
         Items[xSF,ySF,zSF].Quads[SymmetricFaces[_face]] := nil;
      end;
   end
   else // then we should add it.
   begin
      Items[_x,_y,_z].Triangles[_face] := _Triangle;
      if isPixelValid(xSF,ySF,zSF) then
      begin
         Items[xSF,ySF,zSF].Triangles[SymmetricFaces[_face]] := _Triangle;
      end;
   end;
end;

procedure CVolumeFaceVerifier.AddQuad(const _Quad: PQuadItem; _x,_y,_z,_face: integer);
begin
   if _Quad <> nil then
   begin
      if (_Face >= 0) and (_Face < 6) then
      begin
         if isPixelValid(_x,_y,_z) then
         begin
            AddQuadUnsafe(_Quad,_x,_y,_z,_face);
         end;
      end;
   end;
end;

// Here we check if the cell (_x,_y,_z) has a triangle or a quad at the _face or
// if the neighbour cell has a triangle or quad at the opposite face. If that
// happens, we'll invalidate the new triangle and the existing triangle/quad.
// If that doesn't happen, we'll add the quad at the cell and the opposite quad
// at the neighbour.
procedure CVolumeFaceVerifier.AddQuadUnsafe(const _Quad: PQuadItem; _x,_y,_z,_face: integer);
const
   SymmetricFaces: array [0..5] of byte = (1,0,3,2,5,4);
   SymmetricFaceLocation: array [0..5,0..2] of integer = ((-1,0,0),(1,0,0),(0,-1,0),(0,1,0),(0,0,-1),(0,0,1));
var
   xSF,ySF,zSF: integer;
begin
   xSF := _x + SymmetricFaceLocation[_face,0];
   ySF := _y + SymmetricFaceLocation[_face,1];
   zSF := _z + SymmetricFaceLocation[_face,2];
   if (Items[_x,_y,_z].Triangles[_face] <> nil) then
   begin
      _Quad^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Triangles[_face]^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Triangles[_face] := nil;
      {$ifdef MESH_TEST}
 	      GlobalVars.MeshFile.Add('Quad construction has been aborted due to a triangle.');
      {$endif}
      if isPixelValid(xSF,ySF,zSF) then
      begin
         Items[xSF, ySF, zSF].Triangles[SymmetricFaces[_face]]^.v1 := C_VMG_NO_VERTEX;
         Items[xSF, ySF, zSF].Triangles[SymmetricFaces[_face]] := nil;
      end;
   end
   else if (Items[_x,_y,_z].Quads[_face] <> nil) then
   begin
      _Quad^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Quads[_face]^.v1 := C_VMG_NO_VERTEX;
      Items[_x,_y,_z].Quads[_face] := nil;
      {$ifdef MESH_TEST}
 	      GlobalVars.MeshFile.Add('Quad construction has been aborted due to a quad.');
      {$endif}
      if isPixelValid(xSF,ySF,zSF) then
      begin
         Items[xSF, ySF, zSF].Quads[SymmetricFaces[_face]]^.v1 := C_VMG_NO_VERTEX;
         Items[xSF, ySF, zSF].Quads[SymmetricFaces[_face]] := nil;
      end;
   end
   else
   begin
      Items[_x,_y,_z].Quads[_face] := _Quad;
      if isPixelValid(xSF,ySF,zSF) then
      begin
         Items[xSF, ySF, zSF].Quads[SymmetricFaces[_face]] := _Quad;
      end;
   end;
end;

// Delete
procedure CVolumeFaceVerifier.Clear;
var
   x,y: integer;
begin
   for x := 0 to High(Items) do
   begin
      for y := 0 to High(Items[x]) do
      begin
         SetLength(Items[x,y],0);
      end;
      SetLength(Items[x],0);
   end;
   SetLength(Items,0);
end;

end.
