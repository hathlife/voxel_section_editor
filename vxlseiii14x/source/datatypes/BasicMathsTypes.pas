unit BasicMathsTypes;

interface

type
   TVector4f = record
      X, Y, Z, W : single;
   end;
   PVector4f = ^TVector4f;

   TAVector4f = array of TVector4f;
   PAVector4f = ^TAVector4f;

   TVector3f = record
      X, Y, Z : single;
   end;
   PVector3f = ^TVector3f;

   TAVector3f = array of TVector3f;
   PAVector3f = ^TAVector3f;

   TVector2f = record
      U, V : single;
   end;
   TAVector2f = array of TVector2f;
   PAVector2f = ^TAVector2f;

   TVector3i = record
      X, Y, Z : integer;
   end;
   TAVector3i = array of TVector3i;
   PAVector3i = ^TAVector3i;

   TVector3b = record
      R,G,B : Byte;
   end;
   
   TRectangle3f = record
      Min, Max : TVector3f;
   end;

   TGLMatrixf4 = array[0..3, 0..3] of Single;
   TVector3fMap = array of array of array of TVector3f;
   TDistanceFunc = function (_Distance: single): single;


implementation

end.
