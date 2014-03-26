unit TransformAnimation;

interface

uses BasicMathsTypes, Geometry;

{$INCLUDE source/Global_Conditionals.inc}

type
   TTransformAnimation = class
      public
         Name: string;
         TransformMatrices: array of TGLMatrixf4;

         // Constructors and Destructors
         constructor Create(const _Name: string; _NumSectors: integer); overload;
         constructor Create(_NumSectors: integer); overload;
         constructor Create(const _Name: string; _NumSectors, _NumFrames: integer); overload;
         constructor Create(_NumSectors, _NumFrames: integer); overload;
         destructor Destroy;
         procedure InitializeTransforms(_NumSectors, _NumFrames: integer);

         // Execute
         procedure ApplyMatrix(_Section : Integer; _Frame: integer); overload;
         procedure ApplyMatrix(_Scale : TVector3f; _Section : Integer; _Frame: integer); overload;

         // Sets
         procedure SetScale(_Scale : TVector3f; _Section : Integer; _Frame: integer);
         procedure SetMatrix(const _M : TMatrix; _Frame,_Section : Integer);

         // Copy
         procedure Assign(const _Source: TTransformAnimation);
   end;

implementation

uses BasicFunctions, dglOpenGL;

// Constructors and Destructors
constructor TTransformAnimation.Create(const _Name: string; _NumSectors: integer);
begin
   Name := copyString(_Name);
   InitializeTransforms(_NumSectors, 1);
end;

constructor TTransformAnimation.Create(_NumSectors: integer);
begin
   Name := 'Movement';
   InitializeTransforms(_NumSectors, 1);
end;

constructor TTransformAnimation.Create(const _Name: string; _NumSectors, _NumFrames: integer);
begin
   Name := copyString(_Name);
   InitializeTransforms(_NumSectors, _NumFrames);
end;

constructor TTransformAnimation.Create(_NumSectors, _NumFrames: integer);
begin
   Name := 'Movement';
   InitializeTransforms(_NumSectors, _NumFrames);
end;

destructor TTransformAnimation.Destroy;
begin
   Name := '';
   SetLength(TransformMatrices, 0);
   inherited Destroy;
end;

procedure TTransformAnimation.InitializeTransforms(_NumSectors, _NumFrames: Integer);
var
   i: integer;
begin
   SetLength(TransformMatrices, _NumSectors * _NumFrames);
   for i := Low(TransformMatrices) to High(TransformMatrices) do
   begin
      TransformMatrices[i][0,0] := 1;
      TransformMatrices[i][0,1] := 0;
      TransformMatrices[i][0,2] := 0;
      TransformMatrices[i][0,3] := 0;
      TransformMatrices[i][1,0] := 0;
      TransformMatrices[i][1,1] := 1;
      TransformMatrices[i][1,2] := 0;
      TransformMatrices[i][1,3] := 0;
      TransformMatrices[i][2,0] := 0;
      TransformMatrices[i][2,1] := 0;
      TransformMatrices[i][2,2] := 1;
      TransformMatrices[i][2,3] := 0;
      TransformMatrices[i][3,0] := 0;
      TransformMatrices[i][3,1] := 0;
      TransformMatrices[i][3,2] := 0;
      TransformMatrices[i][3,3] := 1;
   end;
end;

// Execute
procedure TTransformAnimation.ApplyMatrix(_Scale : TVector3f; _Section : Integer; _Frame: integer);
var
   Matrix : TGLMatrixf4;
   index: integer;
begin
   index := (_Frame * _Section) + _Section;
   if Index > High(TransformMatrices) then
      exit;

   Matrix[0,0] := TransformMatrices[index][0,0];
   Matrix[0,1] := TransformMatrices[index][0,1];
   Matrix[0,2] := TransformMatrices[index][0,2];
   Matrix[0,3] := TransformMatrices[index][0,3];

   Matrix[1,0] := TransformMatrices[index][1,0];
   Matrix[1,1] := TransformMatrices[index][1,1];
   Matrix[1,2] := TransformMatrices[index][1,2];
   Matrix[1,3] := TransformMatrices[index][1,3];

   Matrix[2,0] := TransformMatrices[index][2,0];
   Matrix[2,1] := TransformMatrices[index][2,1];
   Matrix[2,2] := TransformMatrices[index][2,2];
   Matrix[2,3] := TransformMatrices[index][2,3];

   Matrix[3,0] := TransformMatrices[index][3,0] * _Scale.X;
   Matrix[3,1] := TransformMatrices[index][3,1] * _Scale.Y;
   Matrix[3,2] := TransformMatrices[index][3,2] * _Scale.Z;
   Matrix[3,3] := TransformMatrices[index][3,3];

   glMultMatrixf(@Matrix[0,0]);
end;

procedure TTransformAnimation.ApplyMatrix(_Section : Integer; _Frame: integer);
var
   Matrix : TGLMatrixf4;
   index: integer;
begin
   index := (_Frame * _Section) + _Section;
   if Index > High(TransformMatrices) then
      exit;

   Matrix[0,0] := TransformMatrices[index][0,0];
   Matrix[0,1] := TransformMatrices[index][0,1];
   Matrix[0,2] := TransformMatrices[index][0,2];
   Matrix[0,3] := TransformMatrices[index][0,3];

   Matrix[1,0] := TransformMatrices[index][1,0];
   Matrix[1,1] := TransformMatrices[index][1,1];
   Matrix[1,2] := TransformMatrices[index][1,2];
   Matrix[1,3] := TransformMatrices[index][1,3];

   Matrix[2,0] := TransformMatrices[index][2,0];
   Matrix[2,1] := TransformMatrices[index][2,1];
   Matrix[2,2] := TransformMatrices[index][2,2];
   Matrix[2,3] := TransformMatrices[index][2,3];

   Matrix[3,0] := TransformMatrices[index][3,0];
   Matrix[3,1] := TransformMatrices[index][3,1];
   Matrix[3,2] := TransformMatrices[index][3,2];
   Matrix[3,3] := TransformMatrices[index][3,3];

   glMultMatrixf(@Matrix[0,0]);
end;

// Sets
procedure TTransformAnimation.SetScale(_Scale : TVector3f; _Section : Integer; _Frame: integer);
var
   index: integer;
begin
   index := (_Frame * _Section) + _Section;
   if Index > High(TransformMatrices) then
      exit;

   TransformMatrices[index][3,0] := TransformMatrices[index][3,0] * _Scale.X;
   TransformMatrices[index][3,1] := TransformMatrices[index][3,1] * _Scale.Y;
   TransformMatrices[index][3,2] := TransformMatrices[index][3,2] * _Scale.Z;
   TransformMatrices[index][3,3] := TransformMatrices[index][3,3];
end;

procedure TTransformAnimation.SetMatrix(const _M : TMatrix; _Frame,_Section : Integer);
var
   x,y : integer;
   index: integer;
begin
   index := (_Frame * _Section) + _Section;
   for x := 0 to 3 do
      for y := 0 to 3 do
         TransformMatrices[index][x][y] := _m[x][y];
end;

procedure TTransformAnimation.Assign(const _Source: TTransformAnimation);
var
   i,x,y: integer;
begin
   Name := CopyString(_Source.Name);
   SetLength(TransformMatrices, High(_Source.TransformMatrices) + 1);
   for i := Low(TransformMatrices) to High(TransformMatrices) do
   begin
      for x := 0 to 3 do
         for y := 0 to 3 do
         begin
            TransformMatrices[i][x,y] := _Source.TransformMatrices[i][x,y];
         end;
   end;
end;

end.
