unit ControllerDataTypes;

interface

// Note by Banshee:

// The contents of this file are not located at BasicDataTypes, so this code can
// be reused in other programs, together with our Controller system.

uses Classes;

type
   TCommandParams = TStream;
   PCommandParams = ^TStream;
   TObjectID = pointer;

implementation

end.
