unit Undo_Engine;

interface

uses HVA,math3d,Voxel,VH_Global,VH_Types;

var
Undo,Redo : TUndo_Redo;

Procedure ResetUndoRedo;
Procedure ResetUndo;
Procedure ResetRedo;

Procedure AddHVAToUndo(HVA : PHVA; Frame,Section : Integer);
Procedure AddVOXELToUndo(Voxel : PVoxel; Frame,Section : Integer);

Procedure DoUndo;
Procedure DoRedo;

Function IsUndo : Boolean;
Function IsRedo : Boolean;

implementation

Procedure ResetUndo;
begin
   Undo.Data_No := 0;
   SetLength(Undo.Data,0);
end;

Procedure ResetRedo;
begin
   Redo.Data_No := 0;
   SetLength(Redo.Data,0);
end;

Procedure ResetUndoRedo;
begin
   Redo.Data_No := 0;
   SetLength(Redo.Data,0);
end;

Procedure AddHVAToUndo(HVA : PHVA; Frame,Section : Integer);
begin
   Inc(Undo.Data_No);
   SetLength(Undo.Data,Undo.Data_No);

   Undo.Data[Undo.Data_No-1]._Type := HVhva;
   Undo.Data[Undo.Data_No-1].HVA := HVA;
   Undo.Data[Undo.Data_No-1].Frame := Frame;
   Undo.Data[Undo.Data_No-1].Section := Section;
   Undo.Data[Undo.Data_No-1].TransformMatrix := HVA.TransformMatrixs[Frame*HVA.Header.N_Sections+Section];
   Undo.Data[Undo.Data_No-1].Voxel := nil;
   Undo.Data[Undo.Data_No-1].Offset := SetVector(0,0,0);
   Undo.Data[Undo.Data_No-1].Size := SetVector(0,0,0);
end;

Procedure AddVOXELToUndo(Voxel : PVoxel; Frame,Section : Integer);
begin
   Inc(Undo.Data_No);
   SetLength(Undo.Data,Undo.Data_No);

   Undo.Data[Undo.Data_No-1]._Type := HVvoxel;
   Undo.Data[Undo.Data_No-1].HVA := nil;
   Undo.Data[Undo.Data_No-1].Frame := Frame;
   Undo.Data[Undo.Data_No-1].Section := Section;
   Undo.Data[Undo.Data_No-1].Voxel := Voxel;

   Undo.Data[Undo.Data_No-1].Offset.x := Voxel.Section[Section].Tailer.MaxBounds[1] + (-(Voxel.Section[Section].Tailer.MaxBounds[1]-Voxel.Section[Section].Tailer.MinBounds[1])/2);
   Undo.Data[Undo.Data_No-1].Offset.y := Voxel.Section[Section].Tailer.MaxBounds[2] + (-(Voxel.Section[Section].Tailer.MaxBounds[2]-Voxel.Section[Section].Tailer.MinBounds[2])/2);
   Undo.Data[Undo.Data_No-1].Offset.z := Voxel.Section[Section].Tailer.MaxBounds[3] + (-(Voxel.Section[Section].Tailer.MaxBounds[3]-Voxel.Section[Section].Tailer.MinBounds[3])/2);

   Undo.Data[Undo.Data_No-1].Size.x := Voxel^.Section[Section].Tailer.MaxBounds[1]-Voxel^.Section[Section].Tailer.MinBounds[1];
   Undo.Data[Undo.Data_No-1].Size.y := Voxel^.Section[Section].Tailer.MaxBounds[2]-Voxel^.Section[Section].Tailer.MinBounds[2];
   Undo.Data[Undo.Data_No-1].Size.z := Voxel^.Section[Section].Tailer.MaxBounds[3]-Voxel^.Section[Section].Tailer.MinBounds[3];
end;

Procedure DoUndo_Redo(var Undo,Redo : TUndo_Redo);
var
   HVA : PHVA;
   Voxel : PVoxel;
   NB,NB2 : TVector3f;
begin
   inc(Redo.Data_No);
   SetLength(Redo.Data,Redo.Data_No);

   Redo.Data[Redo.Data_No-1]._Type :=           Undo.Data[Undo.Data_No-1]._Type;
   Redo.Data[Redo.Data_No-1].HVA :=             CurrentHVA;//Undo.Data[Undo.Data_No-1].HVA;
   Redo.Data[Redo.Data_No-1].Frame :=           Undo.Data[Undo.Data_No-1].Frame;
   Redo.Data[Redo.Data_No-1].Section :=         Undo.Data[Undo.Data_No-1].Section;
   Redo.Data[Redo.Data_No-1].Voxel :=           CurrentVoxel;//  Undo.Data[Undo.Data_No-1].Voxel;

   Redo.Data[Redo.Data_No-1].Offset.x := CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[1] + (-(CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[1]-CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[1])/2);
   Redo.Data[Redo.Data_No-1].Offset.y := CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[2] + (-(CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[2]-CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[2])/2);
   Redo.Data[Redo.Data_No-1].Offset.z := CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[3] + (-(CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[3]-CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[3])/2);

   Redo.Data[Redo.Data_No-1].Size.x := CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[1]-CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[1];
   Redo.Data[Redo.Data_No-1].Size.y := CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[2]-CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[2];
   Redo.Data[Redo.Data_No-1].Size.z := CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[3]-CurrentVoxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[3];

{
   Redo.Data[Redo.Data_No-1].Offset :=          Undo.Data[Undo.Data_No-1].Offset;
   Redo.Data[Redo.Data_No-1].Size :=            Undo.Data[Undo.Data_No-1].Size;
}
   Redo.Data[Redo.Data_No-1].TransformMatrix := CurrentHVA.TransformMatrixs[Undo.Data[Undo.Data_No-1].Frame*CurrentHVA.Header.N_Sections+Undo.Data[Undo.Data_No-1].Section];
   //Redo.Data[Redo.Data_No-1].TransformMatrix := Undo.Data[Undo.Data_No-1].TransformMatrix;

   if Undo.Data[Undo.Data_No-1]._Type = HVhva then
   begin
      HVA := Undo.Data[Undo.Data_No-1].HVA;
      HVA.TransformMatrixs[Undo.Data[Undo.Data_No-1].Frame*HVA.Header.N_Sections+Undo.Data[Undo.Data_No-1].Section] := Undo.Data[Undo.Data_No-1].TransformMatrix;
   end
   else
   begin
      Voxel := Undo.Data[Undo.Data_No-1].Voxel;

      NB.x := 0-(Undo.Data[Undo.Data_No-1].Size.x/2);
      NB.y := 0-(Undo.Data[Undo.Data_No-1].Size.y/2);
      NB.z := 0-(Undo.Data[Undo.Data_No-1].Size.z/2);

      NB2.x := (Undo.Data[Undo.Data_No-1].Size.x/2);
      NB2.y := (Undo.Data[Undo.Data_No-1].Size.y/2);
      NB2.z := (Undo.Data[Undo.Data_No-1].Size.z/2);

      NB.X := NB.X + Undo.Data[Undo.Data_No-1].Offset.x;
      NB.Y := NB.Y + Undo.Data[Undo.Data_No-1].Offset.y;
      NB.Z := NB.Z + Undo.Data[Undo.Data_No-1].Offset.z;

      NB2.X := NB2.X + Undo.Data[Undo.Data_No-1].Offset.x;
      NB2.Y := NB2.Y + Undo.Data[Undo.Data_No-1].Offset.y;
      NB2.Z := NB2.Z + Undo.Data[Undo.Data_No-1].Offset.z;

      Voxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[1] := NB.X;
      Voxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[2] := NB.Y;
      Voxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MinBounds[3] := NB.Z;

      Voxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[1] := NB2.X;
      Voxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[2] := NB2.Y;
      Voxel.Section[Undo.Data[Undo.Data_No-1].Section].Tailer.MaxBounds[3] := NB2.Z;
   end;
   Dec(Undo.Data_No);
   SetLength(Undo.Data,Undo.Data_No);
end;

Procedure DoUndo;
begin
   DoUnDo_ReDo(Undo,Redo);
end;

Procedure DoRedo;
begin
   DoUnDo_ReDo(Redo,Undo);
end;

Function IsUndo : Boolean;
begin
   Result := false;
   if Undo.Data_No > 0 then
      Result := true;
end;

Function IsRedo : Boolean;
begin
   Result := false;
   if Redo.Data_No > 0 then
      Result := true;
end;

begin
   ResetUndoRedo;
end.
