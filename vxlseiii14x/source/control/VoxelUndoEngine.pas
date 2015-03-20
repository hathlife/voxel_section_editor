unit VoxelUndoEngine;

interface

uses BasicMathsTypes, BasicDataTypes, BasicVXLSETypes, Voxel, Voxel_Engine;

Type
   TUndo_Redo_Voxel_Data = record
      Pos : TVector3i;
      V : TVoxelUnpacked;
   end;

   TUndo_Redo_Section_Data = record
      XSize, YSize, ZSize: integer;
      Data : array of TUndo_Redo_Voxel_Data;
      Data_no : integer;
   end;

   TUndo_Redo = record
      Data : array of TUndo_Redo_Section_Data;
      Data_no : integer;
   end;

Var
   Undo,Redo : TUndo_Redo;
Const
   Min_Undos = 10;

Function CreateRestorePoint(TempView : TTempView; var Undo_Redo : TUndo_Redo): Boolean;
Procedure UndoRestorePoint(var URUndo,URRedo : TUndo_Redo);
Procedure RedoRestorePoint(var URUndo,URRedo : TUndo_Redo);
Function IsUndoRedoUsed(Undo_Redo : TUndo_Redo) : boolean;
Procedure ResetUndoRedo;

// Bad but only way to do some restore points(i.e flips, nudges, mirroring)
Procedure CreateVXLRestorePoint(Vxl : TVoxelSection; var Undo_Redo : TUndo_Redo);

Procedure PushVXLRestorePoint(Vxl : TVoxelSection; var Undo_Redo : TUndo_Redo);
Procedure PopVXLRestorePoint(Vxl : TVoxelSection; var Undo_Redo : TUndo_Redo);

Procedure GoneOverReset(Var Undo_Redo : TUndo_Redo);

implementation

uses FormMain;

Function CreateRestorePoint(TempView : TTempView; var Undo_Redo : TUndo_Redo): Boolean;
var
   i,no : integer;
   v : TVoxelUnpacked;
begin
   Result := false;
   if TempView.Data_no < 1 then
      exit;

   if Undo_Redo.Data_no > Min_Undos + 5 then
      GoneOverReset(Undo_Redo);

   Redo.Data_no := 0;
   SetLength(Redo.Data,Redo.Data_no);

   inc(Undo_Redo.Data_no);
   SetLength(Undo_Redo.Data,Undo_Redo.Data_no);

   Undo_Redo.Data[Undo_Redo.Data_no-1].XSize := FrmMain.Document.ActiveSection^.Tailer.XSize;
   Undo_Redo.Data[Undo_Redo.Data_no-1].YSize := FrmMain.Document.ActiveSection^.Tailer.YSize;
   Undo_Redo.Data[Undo_Redo.Data_no-1].ZSize := FrmMain.Document.ActiveSection^.Tailer.ZSize;
   Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no := 0;
   SetLength(Undo_Redo.Data[Undo_Redo.Data_no-1].Data,Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no);

   for i := 1 to TempView.Data_no do
   begin
      if TempView.Data[i].VU then
      begin
         inc(Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no);
         no := Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no - 1;

         SetLength(Undo_Redo.Data[Undo_Redo.Data_no-1].Data, no + 1);
         with TempView do
            FrmMain.Document.ActiveSection^.GetVoxel(Data[i].VC.X,Data[i].VC.Y,Data[i].VC.Z,v);

         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Colour := V.Colour;
         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Flags := V.Flags;
         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Normal := V.Normal;
         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Used := V.Used;

         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].Pos.X := TempView.Data[i].VC.X;
         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].Pos.Y := TempView.Data[i].VC.Y;
         Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].Pos.Z := TempView.Data[i].VC.Z;
      end;
   end;
   VXLChanged := true;
   Result := true;
end;

Procedure UndoRestorePoint(var URUndo,URRedo : TUndo_Redo);
begin
   PushVXLRestorePoint(FrmMain.Document.ActiveSection^, URRedo);
   PopVXLRestorePoint(FrmMain.Document.ActiveSection^, URUndo);
end;

Procedure RedoRestorePoint(var URUndo,URRedo : TUndo_Redo);
begin
   PushVXLRestorePoint(FrmMain.Document.ActiveSection^, URUndo);
   PopVXLRestorePoint(FrmMain.Document.ActiveSection^, URRedo);
end;

Function IsUndoRedoUsed(Undo_Redo : TUndo_Redo) : boolean;
begin
   if Undo_Redo.Data_no > 0 then
      Result := true
   else
      Result := false;
end;

Procedure ResetUndoRedo;
var
   x : integer;
begin
   for x := Low(Undo.Data) to High(Undo.Data) do
   begin
      SetLength(Undo.Data[x].Data,0);
      Undo.Data[x].Data_no := 0;
   end;
   Undo.Data_no := 0;
   SetLength(Undo.Data,Undo.Data_no);

   for x := Low(Redo.Data) to High(Redo.Data) do
   begin
      SetLength(Redo.Data[x].Data,0);
      Redo.Data[x].Data_no := 0;
   end;
   Redo.Data_no := 0;
   SetLength(Redo.Data,Redo.Data_no);
end;

Procedure CreateVXLRestorePoint(Vxl : TVoxelSection; var Undo_Redo : TUndo_Redo);
begin
   Redo.Data_no := 0;
   SetLength(Redo.Data,Redo.Data_no);

   PushVXLRestorePoint(Vxl, Undo_Redo);
end;

Procedure PushVXLRestorePoint(Vxl : TVoxelSection; var Undo_Redo : TUndo_Redo);
var
   x,y,z,no : integer;
   v : TVoxelUnpacked;
begin
   if Undo_Redo.Data_no > Min_Undos + 5 then
      GoneOverReset(Undo_Redo);

   inc(Undo_Redo.Data_no);
   SetLength(Undo_Redo.Data,Undo_Redo.Data_no);

   Undo_Redo.Data[Undo_Redo.Data_no-1].XSize := VXL.Tailer.XSize;
   Undo_Redo.Data[Undo_Redo.Data_no-1].YSize := VXL.Tailer.YSize;
   Undo_Redo.Data[Undo_Redo.Data_no-1].ZSize := VXL.Tailer.ZSize;
   Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no := 0;
   SetLength(Undo_Redo.Data[Undo_Redo.Data_no-1].Data, 0);

   for x := 0 to VXL.Tailer.XSize-1 do
      for y := 0 to VXL.Tailer.YSize-1 do
         for z := 0 to VXL.Tailer.ZSize-1 do
         begin
            inc(Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no);
            no := Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no - 1;

            SetLength(Undo_Redo.Data[Undo_Redo.Data_no-1].Data, no + 1);
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);

            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Colour := V.Colour;
            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Flags := V.Flags;
            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Normal := V.Normal;
            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].V.Used := V.Used;

            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].Pos.X := x;
            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].Pos.Y := y;
            Undo_Redo.Data[Undo_Redo.Data_no-1].Data[no].Pos.Z := z;
         end;
   VXLChanged := true;
end;

Procedure PopVXLRestorePoint(Vxl : TVoxelSection; var Undo_Redo : TUndo_Redo);
var
   i : integer;
   v : TVoxelUnpacked;
begin
   if (FrmMain.Document.ActiveSection^.Tailer.XSize <> Undo_Redo.Data[Undo_Redo.Data_no-1].XSize) or (FrmMain.Document.ActiveSection^.Tailer.YSize <> Undo_Redo.Data[Undo_Redo.Data_no-1].YSize) or (FrmMain.Document.ActiveSection^.Tailer.ZSize <> Undo_Redo.Data[Undo_Redo.Data_no-1].ZSize) then
   begin
      FrmMain.Document.ActiveSection^.Resize(Undo_Redo.Data[Undo_Redo.Data_no-1].XSize, Undo_Redo.Data[Undo_Redo.Data_no-1].YSize, Undo_Redo.Data[Undo_Redo.Data_no-1].ZSize);
   end;

   for i := 0 to Undo_Redo.Data[Undo_Redo.Data_no-1].Data_no-1 do
   begin
      v.Colour := Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].V.Colour;
      v.Flags := Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].V.Flags;
      v.Normal := Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].V.Normal;
      v.Used := Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].V.Used;

      FrmMain.Document.ActiveSection^.SetVoxel(Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].Pos.X,Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].Pos.Y,Undo_Redo.Data[Undo_Redo.Data_no-1].Data[i].Pos.Z, v);
   end;

   SetLength(Undo_Redo.Data[Undo_Redo.Data_no-1].Data, 0);
   dec(Undo_Redo.Data_no);
   SetLength(Undo_Redo.Data,Undo_Redo.Data_no);
   VXLChanged := true;
end;

Procedure Copy_UndoRedo(Const Source : TUndo_Redo; Var Dest  : TUndo_Redo);
var
   I,J : integer;
begin
   Dest.Data_no := Source.Data_no;
   SetLength(Dest.Data,Dest.Data_no);
   for i := 0 to Source.Data_no-1 do
   begin
      Dest.Data[i].XSize := Source.Data[i].XSize;
      Dest.Data[i].YSize := Source.Data[i].YSize;
      Dest.Data[i].ZSize := Source.Data[i].ZSize;
      Dest.Data[i].Data_no := Source.Data[i].Data_no;
      SetLength(Dest.Data[i].Data,Dest.Data[i].Data_no);
      For j := 0 to Source.Data[i].Data_no-1 do
      begin
         Dest.Data[i].Data[j].Pos.X := Source.Data[i].Data[j].Pos.X;
         Dest.Data[i].Data[j].Pos.Y := Source.Data[i].Data[j].Pos.Y;
         Dest.Data[i].Data[j].Pos.Z := Source.Data[i].Data[j].Pos.Z;

         Dest.Data[i].Data[j].V.Colour := Source.Data[i].Data[j].V.Colour;
         Dest.Data[i].Data[j].V.Normal := Source.Data[i].Data[j].V.Normal;
         Dest.Data[i].Data[j].V.Flags := Source.Data[i].Data[j].V.Flags;
         Dest.Data[i].Data[j].V.Used := Source.Data[i].Data[j].V.Used;
      end;
   end;
end;


Procedure Copy_UndoRedo2(Const Source : TUndo_Redo; Var Dest  : TUndo_Redo);
var
   I,J : integer;
begin
   Dest.Data_no := Source.Data_no-5;
   SetLength(Dest.Data,Dest.Data_no);
   for i := 5 to Source.Data_no-1 do
   begin
      Dest.Data[i-5].XSize := Source.Data[i].XSize;
      Dest.Data[i-5].YSize := Source.Data[i].YSize;
      Dest.Data[i-5].ZSize := Source.Data[i].ZSize;
      Dest.Data[i-5].Data_no := Source.Data[i].Data_no;
      SetLength(Dest.Data[i-5].Data,Dest.Data[i-5].Data_no);
      For j := 0 to Source.Data[i].Data_no-1 do
      begin
         Dest.Data[i-5].Data[j].Pos.X := Source.Data[i].Data[j].Pos.X;
         Dest.Data[i-5].Data[j].Pos.Y := Source.Data[i].Data[j].Pos.Y;
         Dest.Data[i-5].Data[j].Pos.Z := Source.Data[i].Data[j].Pos.Z;

         Dest.Data[i-5].Data[j].V.Colour := Source.Data[i].Data[j].V.Colour;
         Dest.Data[i-5].Data[j].V.Normal := Source.Data[i].Data[j].V.Normal;
         Dest.Data[i-5].Data[j].V.Flags := Source.Data[i].Data[j].V.Flags;
         Dest.Data[i-5].Data[j].V.Used := Source.Data[i].Data[j].V.Used;
      end;
   end;
end;

// Should reduce the undo by 5 making it have Min_Undos
Procedure GoneOverReset(Var Undo_Redo : TUndo_Redo);
Var
   UndoT : TUndo_Redo;
begin
   Copy_UndoRedo(Undo_Redo,UndoT);
   ResetUndoRedo;
   Copy_UndoRedo2(UndoT,Undo_Redo);
end;

begin
   ResetUndoRedo;
end.
