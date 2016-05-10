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

Function CreateRestorePoint(const _TempView : TTempView; var _Undo_Redo : TUndo_Redo): Boolean;
Procedure UndoRestorePoint(var _URUndo,_URRedo : TUndo_Redo);
Procedure RedoRestorePoint(var _URUndo,_URRedo : TUndo_Redo);
Function IsUndoRedoUsed(const _Undo_Redo : TUndo_Redo) : boolean;
Procedure ResetUndoRedo;
Procedure ResetUndo(var _Undo : TUndo_Redo);

// Bad but only way to do some restore points(i.e flips, nudges, mirroring)
Procedure CreateVXLRestorePoint(const _Vxl : TVoxelSection; var _Undo_Redo : TUndo_Redo);

Procedure SaveVXLRestorePoint(const _Vxl : TVoxelSection; var _Undo_Redo : TUndo_Redo);
Procedure LoadVXLRestorePoint(var _Vxl : TVoxelSection; var _Undo_Redo : TUndo_Redo);

Procedure GoneOverReset(Var _Undo_Redo : TUndo_Redo);
procedure FreeUndoRedo(Var _Undo_Redo : TUndo_Redo);

implementation

uses FormMain;

Function CreateRestorePoint(const _TempView : TTempView; var _Undo_Redo : TUndo_Redo): Boolean;
var
   i,no : integer;
   v : TVoxelUnpacked;
begin
   Result := false;
   if _TempView.Data_no < 1 then
      exit;

   if _Undo_Redo.Data_no > Min_Undos + 5 then
      GoneOverReset(_Undo_Redo);

   ResetUndo(Redo);

   inc(_Undo_Redo.Data_no);
   SetLength(_Undo_Redo.Data,_Undo_Redo.Data_no);

   _Undo_Redo.Data[_Undo_Redo.Data_no-1].XSize := FrmMain.Document.ActiveSection^.Tailer.XSize;
   _Undo_Redo.Data[_Undo_Redo.Data_no-1].YSize := FrmMain.Document.ActiveSection^.Tailer.YSize;
   _Undo_Redo.Data[_Undo_Redo.Data_no-1].ZSize := FrmMain.Document.ActiveSection^.Tailer.ZSize;
   _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no := 0;
   SetLength(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data,_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no);

   for i := 1 to _TempView.Data_no do
   begin
      if _TempView.Data[i].VU then
      begin
         inc(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no);
         no := _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no - 1;

         SetLength(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data, no + 1);
         with _TempView do
            FrmMain.Document.ActiveSection^.GetVoxel(Data[i].VC.X,Data[i].VC.Y,Data[i].VC.Z,v);

         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Colour := V.Colour;
         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Flags := V.Flags;
         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Normal := V.Normal;
         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Used := V.Used;

         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].Pos.X := _TempView.Data[i].VC.X;
         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].Pos.Y := _TempView.Data[i].VC.Y;
         _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].Pos.Z := _TempView.Data[i].VC.Z;
      end;
   end;
   FrmMain.SetVoxelChanged(true);
   Result := true;
end;

Procedure UndoRestorePoint(var _URUndo,_URRedo : TUndo_Redo);
begin
   SaveVXLRestorePoint(FrmMain.Document.ActiveSection^, _URRedo);
   LoadVXLRestorePoint(FrmMain.Document.ActiveSection^, _URUndo);
end;

Procedure RedoRestorePoint(var _URUndo,_URRedo : TUndo_Redo);
begin
   SaveVXLRestorePoint(FrmMain.Document.ActiveSection^, _URUndo);
   LoadVXLRestorePoint(FrmMain.Document.ActiveSection^, _URRedo);
end;

Function IsUndoRedoUsed(const _Undo_Redo : TUndo_Redo) : boolean;
begin
   if _Undo_Redo.Data_no > 0 then
      Result := true
   else
      Result := false;
end;

Procedure ResetUndoRedo;
begin
   ResetUndo(Undo);
   ResetUndo(Redo);
end;

Procedure ResetUndo(var _Undo : TUndo_Redo);
var
   x : integer;
begin
   for x := Low(_Undo.Data) to High(_Undo.Data) do
   begin
      SetLength(_Undo.Data[x].Data,0);
      _Undo.Data[x].Data_no := 0;
   end;
   _Undo.Data_no := 0;
   SetLength(_Undo.Data,_Undo.Data_no);
end;

Procedure CreateVXLRestorePoint(const _Vxl : TVoxelSection; var _Undo_Redo : TUndo_Redo);
begin
   ResetUndo(Redo);
   SaveVXLRestorePoint(_Vxl, _Undo_Redo);
end;

Procedure SaveVXLRestorePoint(const _Vxl : TVoxelSection; var _Undo_Redo : TUndo_Redo);
var
   x,y,z,no : integer;
   v : TVoxelUnpacked;
begin
   if _Undo_Redo.Data_no > Min_Undos + 5 then
      GoneOverReset(_Undo_Redo);

   inc(_Undo_Redo.Data_no);
   SetLength(_Undo_Redo.Data,_Undo_Redo.Data_no);

   _Undo_Redo.Data[_Undo_Redo.Data_no-1].XSize := _VXL.Tailer.XSize;
   _Undo_Redo.Data[_Undo_Redo.Data_no-1].YSize := _VXL.Tailer.YSize;
   _Undo_Redo.Data[_Undo_Redo.Data_no-1].ZSize := _VXL.Tailer.ZSize;
   _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no := 0;
   SetLength(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data, 0);

   for x := 0 to _VXL.Tailer.XSize-1 do
      for y := 0 to _VXL.Tailer.YSize-1 do
         for z := 0 to _VXL.Tailer.ZSize-1 do
         begin
            inc(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no);
            no := _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no - 1;

            SetLength(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data, no + 1);
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);

            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Colour := V.Colour;
            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Flags := V.Flags;
            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Normal := V.Normal;
            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].V.Used := V.Used;

            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].Pos.X := x;
            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].Pos.Y := y;
            _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[no].Pos.Z := z;
         end;
   FrmMain.SetVoxelChanged(true);
end;

Procedure LoadVXLRestorePoint(var _Vxl : TVoxelSection; var _Undo_Redo : TUndo_Redo);
var
   i : integer;
   v : TVoxelUnpacked;
begin
   if (FrmMain.Document.ActiveSection^.Tailer.XSize <> _Undo_Redo.Data[_Undo_Redo.Data_no-1].XSize) or (FrmMain.Document.ActiveSection^.Tailer.YSize <> _Undo_Redo.Data[_Undo_Redo.Data_no-1].YSize) or (FrmMain.Document.ActiveSection^.Tailer.ZSize <> _Undo_Redo.Data[_Undo_Redo.Data_no-1].ZSize) then
   begin
      FrmMain.Document.ActiveSection^.Resize(_Undo_Redo.Data[_Undo_Redo.Data_no-1].XSize, _Undo_Redo.Data[_Undo_Redo.Data_no-1].YSize, _Undo_Redo.Data[_Undo_Redo.Data_no-1].ZSize);
   end;

   for i := 0 to _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data_no-1 do
   begin
      v.Colour := _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].V.Colour;
      v.Flags := _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].V.Flags;
      v.Normal := _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].V.Normal;
      v.Used := _Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].V.Used;

      FrmMain.Document.ActiveSection^.SetVoxel(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].Pos.X,_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].Pos.Y,_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data[i].Pos.Z, v);
   end;

   SetLength(_Undo_Redo.Data[_Undo_Redo.Data_no-1].Data, 0);
   dec(_Undo_Redo.Data_no);
   SetLength(_Undo_Redo.Data,_Undo_Redo.Data_no);
   FrmMain.SetVoxelChanged(true);
end;

Procedure Copy_UndoRedo(Const _Source : TUndo_Redo; Var _Dest  : TUndo_Redo);
var
   I,J : integer;
begin
   _Dest.Data_no := _Source.Data_no;
   SetLength(_Dest.Data,_Dest.Data_no);
   for i := 0 to _Source.Data_no-1 do
   begin
      _Dest.Data[i].XSize := _Source.Data[i].XSize;
      _Dest.Data[i].YSize := _Source.Data[i].YSize;
      _Dest.Data[i].ZSize := _Source.Data[i].ZSize;
      _Dest.Data[i].Data_no := _Source.Data[i].Data_no;
      SetLength(_Dest.Data[i].Data,_Dest.Data[i].Data_no);
      For j := 0 to _Source.Data[i].Data_no-1 do
      begin
         _Dest.Data[i].Data[j].Pos.X := _Source.Data[i].Data[j].Pos.X;
         _Dest.Data[i].Data[j].Pos.Y := _Source.Data[i].Data[j].Pos.Y;
         _Dest.Data[i].Data[j].Pos.Z := _Source.Data[i].Data[j].Pos.Z;

         _Dest.Data[i].Data[j].V.Colour := _Source.Data[i].Data[j].V.Colour;
         _Dest.Data[i].Data[j].V.Normal := _Source.Data[i].Data[j].V.Normal;
         _Dest.Data[i].Data[j].V.Flags := _Source.Data[i].Data[j].V.Flags;
         _Dest.Data[i].Data[j].V.Used := _Source.Data[i].Data[j].V.Used;
      end;
   end;
end;


Procedure Copy_UndoRedo2(Const _Source : TUndo_Redo; Var _Dest  : TUndo_Redo);
var
   I,J : integer;
begin
   _Dest.Data_no := _Source.Data_no-5;
   SetLength(_Dest.Data,_Dest.Data_no);
   for i := 5 to _Source.Data_no-1 do
   begin
      _Dest.Data[i-5].XSize := _Source.Data[i].XSize;
      _Dest.Data[i-5].YSize := _Source.Data[i].YSize;
      _Dest.Data[i-5].ZSize := _Source.Data[i].ZSize;
      _Dest.Data[i-5].Data_no := _Source.Data[i].Data_no;
      SetLength(_Dest.Data[i-5].Data,_Dest.Data[i-5].Data_no);
      For j := 0 to _Source.Data[i].Data_no-1 do
      begin
         _Dest.Data[i-5].Data[j].Pos.X := _Source.Data[i].Data[j].Pos.X;
         _Dest.Data[i-5].Data[j].Pos.Y := _Source.Data[i].Data[j].Pos.Y;
         _Dest.Data[i-5].Data[j].Pos.Z := _Source.Data[i].Data[j].Pos.Z;

         _Dest.Data[i-5].Data[j].V.Colour := _Source.Data[i].Data[j].V.Colour;
         _Dest.Data[i-5].Data[j].V.Normal := _Source.Data[i].Data[j].V.Normal;
         _Dest.Data[i-5].Data[j].V.Flags := _Source.Data[i].Data[j].V.Flags;
         _Dest.Data[i-5].Data[j].V.Used := _Source.Data[i].Data[j].V.Used;
      end;
   end;
end;

// Should reduce the undo by 5 making it have Min_Undos
Procedure GoneOverReset(Var _Undo_Redo : TUndo_Redo);
Var
   UndoT : TUndo_Redo;
begin
   Copy_UndoRedo(_Undo_Redo,UndoT);
   ResetUndoRedo;
   Copy_UndoRedo2(UndoT,_Undo_Redo);
   FreeUndoRedo(UndoT);
end;

procedure FreeUndoRedo(Var _Undo_Redo : TUndo_Redo);
var
   i: integer;
begin
   i := Low(_Undo_Redo.Data);
   while i <= High(_Undo_Redo.Data) do
   begin
      SetLength(_Undo_Redo.Data[i].Data, 0);
      inc(i);
   end;
   SetLength(_Undo_Redo.Data, 0);
end;

begin
   ResetUndoRedo;
end.
