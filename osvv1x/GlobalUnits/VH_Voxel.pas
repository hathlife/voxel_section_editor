unit VH_Voxel;

interface

Uses OpenGl15,SysUtils,Voxel,VH_Global,VH_Types,Math3d,HVA,palette,Windows;

procedure UpdateVoxelList;
procedure UpdateVoxelList2(const Vxl : TVoxel; Var VoxelBoxes : TVoxelBoxs; Var VoxelBox_No : Integer; Const HVAOpen : Boolean; HVA : THVA; Frames : Integer);
Procedure GETMinMaxBounds(Const Vxl : TVoxel; i : Integer; Var MB,MB2 : TVector3f);
Procedure GetOffsetAndSize(Const Vxl : TVoxel; i : Integer; Var Size,Offset : TVector3f);
Function GetVXLColorWithSelection(Vxl : TVoxel; Color,Normal,Section : integer) : TVector3f;

Procedure LoadVoxel(Filename : String);

Procedure SetSpectrum(Colours : Boolean);

Procedure ChangeOffset(Vxl : TVoxel; Section : integer; X,Y,Z : single);
procedure ChangeRemappable (var Palette:TPalette; Colour : TVector3f);

implementation

function checkface(Vxl : TVoxelSection; x,y,z : integer) : boolean;
var
   v: TVoxelUnpacked;
begin
   Result := true;

   if (X < 0) or (X > Vxl.Tailer.XSize-1) then
      Exit;

   if (Y < 0) or (Y > Vxl.Tailer.YSize-1) then
      Exit;

   if (Z < 0) or (Z > Vxl.Tailer.ZSize-1) then
      Exit;

   Vxl.GetVoxel(x,y,z,v);

   if v.Used then
      Result := false;
end;

procedure UpdateVoxelList;
begin
   VoxelBox_No := 0;
   VoxelBoxes.NumSections := 0;
   SetLength(VoxelBoxes.Sections,VoxelBoxes.NumSections);

   VoxelBox_NoT := 0;
   VoxelBoxesT.NumSections := 0;
   SetLength(VoxelBoxesT.Sections,VoxelBoxesT.NumSections);

   VoxelBox_NoB := 0;
   VoxelBoxesB.NumSections := 0;
   SetLength(VoxelBoxesB.Sections,VoxelBoxesB.NumSections);

   LowestZ := 1000;

   If VoxelOpen then
      UpdateVoxelList2(VoxelFile,VoxelBoxes,VoxelBox_No,HVAOpen,HVAFile,HVAFrame);

   If VoxelOpenT then
      UpdateVoxelList2(VoxelTurret,VoxelBoxesT,VoxelBox_NoT,HVAOpenT,HVATurret,HVAFrameT);

   If VoxelOpenB then
      UpdateVoxelList2(VoxelBarrel,VoxelBoxesB,VoxelBox_NoB,HVAOpenB,HVABarrel,HVAFrameB);
end;

procedure UpdateVoxelList2(const Vxl : TVoxel; Var VoxelBoxes : TVoxelBoxs; Var VoxelBox_No : Integer; Const HVAOpen : Boolean; HVA : THVA; Frames : Integer);
var
   x,y,z,i: Byte;
   v: TVoxelUnpacked;
   num : integer;
   CD : TVector3f;
begin
   VoxelBox_No := 0;
   if VoxelBoxes.NumSections > 0 then
      for x := 0 to VoxelBoxes.NumSections-1 do
         If VoxelBoxes.Sections[x].List > 0 then
            glDeleteLists(VoxelBoxes.Sections[x].List, 1);

   VoxelBoxes.NumSections := VXL.Header.NumSections;
   SetLength(VoxelBoxes.Sections,0);
   SetLength(VoxelBoxes.Sections,VXL.Header.NumSections);

   for i := 0 to VXL.Header.NumSections-1 do
   begin
      VoxelBoxes.Sections[i].NumBoxs := 0;
      num:=0;
      SetLength(VoxelBoxes.Sections[i].Boxs,VoxelBoxes.Sections[i].NumBoxs);
      for z:=0 to (Vxl.Section[i].Tailer.zSize-1) do
      begin
         for y:=0 to (Vxl.Section[i].Tailer.YSize-1) do
         begin
            for x:=0 to (Vxl.Section[i].Tailer.xSize-1) do
            begin
               Vxl.Section[i].GetVoxel(x,y,z,v);
               if v.Used=true then
               begin
                  inc(VoxelBox_No);
                  inc(VoxelBoxes.Sections[i].NumBoxs);
                  SetLength(VoxelBoxes.Sections[i].Boxs,VoxelBoxes.Sections[i].NumBoxs);
                  VoxelBoxes.Sections[i].Boxs[num].Section := i;
                  VoxelBoxes.Sections[i].Boxs[num].MinBounds.x := (Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1])/Vxl.Section[i].Tailer.xSize;
                  VoxelBoxes.Sections[i].Boxs[num].MinBounds.y := (Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2])/Vxl.Section[i].Tailer.ySize;
                  VoxelBoxes.Sections[i].Boxs[num].MinBounds.z := (Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3])/Vxl.Section[i].Tailer.zSize;

                  CD.x := Vxl.Section[i].Tailer.MaxBounds[1] + (-(Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1])/2);
                  CD.y := Vxl.Section[i].Tailer.MaxBounds[2] + (-(Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2])/2);
                  CD.z := Vxl.Section[i].Tailer.MaxBounds[3] + (-(Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3])/2);

                  VoxelBoxes.Sections[i].Boxs[num].MinBounds2.x := CD.x + (-(Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1])/2);
                  VoxelBoxes.Sections[i].Boxs[num].MinBounds2.y := CD.y + (-(Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2])/2);
                  VoxelBoxes.Sections[i].Boxs[num].MinBounds2.z := CD.z + (-(Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3])/2);

                  if HVAOpen then
                  begin
                     VoxelBoxes.Sections[i].Boxs[num].Faces[1] := True;
                     VoxelBoxes.Sections[i].Boxs[num].Faces[2] := True;
                     VoxelBoxes.Sections[i].Boxs[num].Faces[3] := True;
                     VoxelBoxes.Sections[i].Boxs[num].Faces[4] := True;
                     VoxelBoxes.Sections[i].Boxs[num].Faces[5] := True;
                     VoxelBoxes.Sections[i].Boxs[num].Faces[6] := True;

                     VoxelBoxes.Sections[i].Boxs[num].Position.X := {Vxl.Section[i].Tailer.Transform[1][4]+}X;//X {* Vxl.Section[i].Tailer.MinBounds[1]}-((Vxl.Section[i].Tailer.xSize-1) / 2){+ 80* Vxl.Section[i].Tailer.Det};
                     VoxelBoxes.Sections[i].Boxs[num].Position.Y := {Vxl.Section[i].Tailer.Transform[2][4]+}Y;//Y {* Vxl.Section[i].Tailer.MinBounds[2]}-((Vxl.Section[i].Tailer.ySize-1) / 2){+ 80* Vxl.Section[i].Tailer.Det};
                     VoxelBoxes.Sections[i].Boxs[num].Position.Z := {Vxl.Section[i].Tailer.Transform[3][4]+}Z;//Z {* Vxl.Section[i].Tailer.MinBounds[3]} {- ((Vxl.Section[i].Tailer.zSize-1) / 2) + 80* Vxl.Section[i].Tailer.Det};
{
                     if ApplyMatrix2(HVA,Vxl,AddVector(ScaleVector3f(VoxelBoxes.Sections[i].Boxs[num].Position,VoxelBoxes.Sections[i].Boxs[num].MinBounds),VoxelBoxes.Sections[i].Boxs[num].MinBounds2),i,Frames).Z < LowestZ then
                        LowestZ := ApplyMatrix2(HVA,Vxl,AddVector(ScaleVector3f(VoxelBoxes.Sections[i].Boxs[num].Position,VoxelBoxes.Sections[i].Boxs[num].MinBounds),VoxelBoxes.Sections[i].Boxs[num].MinBounds2),i,Frames).Z;
}
                  end
                  else
                  begin
                     VoxelBoxes.Sections[i].Boxs[num].Faces[1] := CheckFace(Vxl.Section[i],x,y+1,z);
                     VoxelBoxes.Sections[i].Boxs[num].Faces[2] := CheckFace(Vxl.Section[i],x,y-1,z);
                     VoxelBoxes.Sections[i].Boxs[num].Faces[3] := CheckFace(Vxl.Section[i],x,y,z+1);
                     VoxelBoxes.Sections[i].Boxs[num].Faces[4] := CheckFace(Vxl.Section[i],x,y,z-1);
                     VoxelBoxes.Sections[i].Boxs[num].Faces[5] := CheckFace(Vxl.Section[i],x-1,y,z);
                     VoxelBoxes.Sections[i].Boxs[num].Faces[6] := CheckFace(Vxl.Section[i],x+1,y,z);
                     VoxelBoxes.Sections[i].Boxs[num].Position.X := Vxl.Section[i].Tailer.Transform[1][4]+X;// - ((Vxl.Section[i].Tailer.xSize-1) / 2);
                     VoxelBoxes.Sections[i].Boxs[num].Position.Y := Vxl.Section[i].Tailer.Transform[2][4]+Y;// - ((Vxl.Section[i].Tailer.ySize-1) / 2);
                     VoxelBoxes.Sections[i].Boxs[num].Position.Z := {HighestZ+}Vxl.Section[i].Tailer.Transform[3][4]+Z;// - ((Vxl.Section[i].Tailer.zSize-1) / 2);
{
                     if AddVector(ScaleVector3f(VoxelBoxes.Sections[i].Boxs[num].Position,VoxelBoxes.Sections[i].Boxs[num].MinBounds),VoxelBoxes.Sections[i].Boxs[num].MinBounds2).Z < LowestZ then
                        LowestZ := AddVector(ScaleVector3f(VoxelBoxes.Sections[i].Boxs[num].Position,VoxelBoxes.Sections[i].Boxs[num].MinBounds),VoxelBoxes.Sections[i].Boxs[num].MinBounds2).Z;
}
                  end;

                  VoxelBoxes.Sections[i].Boxs[num].Color := v.Colour;
                  VoxelBoxes.Sections[i].Boxs[num].Normal := v.Normal;

                  Inc(num);
               end;
            end;
         end;
      end;
   end;
end;

Procedure GETMinMaxBounds(Const Vxl : TVoxel; i : Integer; Var MB,MB2 : TVector3f);
begin
   // As far as I could understand, this is the scale.
   MB.x := (Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1])/Vxl.Section[i].Tailer.xSize;
   MB.y := (Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2])/Vxl.Section[i].Tailer.ySize;
   MB.z := (Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3])/Vxl.Section[i].Tailer.zSize;
   // That's the offset.
   MB2.x := Vxl.Section[i].Tailer.MinBounds[1]; //Vxl.Section[i].Tailer.MaxBounds[1] - ((Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1]));
   MB2.y := Vxl.Section[i].Tailer.MinBounds[2]; //Vxl.Section[i].Tailer.MaxBounds[2] - ((Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2]));
   MB2.z := Vxl.Section[i].Tailer.MinBounds[3]; //Vxl.Section[i].Tailer.MaxBounds[3] - ((Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3]));
end;

Procedure GetOffsetAndSize(Const Vxl : TVoxel; i : Integer; Var Size,Offset : TVector3f);
begin
   Size.x := (Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1])/Vxl.Section[i].Tailer.xSize;
   Size.y := (Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2])/Vxl.Section[i].Tailer.ySize;
   Size.z := (Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3])/Vxl.Section[i].Tailer.zSize;

   Offset.x := Vxl.Section[i].Tailer.MaxBounds[1] + (-(Vxl.Section[i].Tailer.MaxBounds[1]-Vxl.Section[i].Tailer.MinBounds[1])/2);
   Offset.y := Vxl.Section[i].Tailer.MaxBounds[2] + (-(Vxl.Section[i].Tailer.MaxBounds[2]-Vxl.Section[i].Tailer.MinBounds[2])/2);
   Offset.z := Vxl.Section[i].Tailer.MaxBounds[3] + (-(Vxl.Section[i].Tailer.MaxBounds[3]-Vxl.Section[i].Tailer.MinBounds[3])/2);

   ScaleVector3f(Offset,Size);
end;

Function CleanV3fCol(Color : TVector3f) : TVector3f;
Var
   T : TVector3f;
begin
   T.X := Color.X;
   T.Y := Color.Y;
   T.Z := Color.Z;

   If T.X > 255 then
      T.X := 255;

   If T.X < 0 then
      T.X := 0;

   If T.Y > 255 then
      T.Y := 255;

   If T.Y < 0 then
      T.Y := 0;

   If T.Z > 255 then
      T.Z := 255;

   If T.Z < 0 then
      T.Z := 0;

   T.X := T.X / 255;
   T.Y := T.Y / 255;
   T.Z := T.Z / 255;

   Result := T;
end;

// Importing and adapting change remappable from OS SHP Builder.
procedure ChangeRemappable (var Palette:TPalette; Colour : TVector3f);
var
   base,x,rsub,gsub,bsub:byte;
   rmult,gmult,bmult: single;
begin
   base := 64;
   rmult := (Colour.X * 255) / 128;
   gmult := (Colour.Y * 255) / 128;
   bmult := (Colour.Z * 255) / 128;
   // Generate Remmapable colours
   if rmult <> 0 then
     rsub := 1
   else
     rsub := 0;
   if gmult <> 0 then
     gsub := 1
   else
     gsub := 0;
   if bmult <> 0 then
     bsub := 1
   else
     bsub := 0;

   for x := 16 to 31 do
   begin
      Palette[x]:= RGB(Round(((base*2)*rmult)-rsub),Round(((base*2)*gmult)-gsub),Round(((base*2)*bmult)-bsub));
      if (((x+1) div 3) <> 0) then
         base := base - 4
      else
         base := base - 3;
   end;
end;

function GetCorrectColour(Color : integer) : TVector3f;
begin
   result := TColorToTVector3f(VXLPalette[Color]);
end;

Function GetVXLColor(Color,Normal : integer) : TVector3f;
begin
   if SpectrumMode = ModeColours then
      Result := GetCorrectColour(color)
   else
      Result := CleanV3fCol(SetVector(127,127,127));
end;

Function GetVXLColorWithSelection(Vxl : TVoxel; Color,Normal,Section : integer) : TVector3f;
begin
   Result := GetVXLColor(Color,Normal);

   if (Vxl = CurrentVoxel^) and (Section = CurrentVoxelSection) and (Highlight) then
   begin
      Result.X := (Result.X *255) + 70;
      Result := CleanV3fCol(Result);
   end;
end;

Procedure LoadVoxel2(Filename,Ext : String; Var Voxel : TVoxel; Var VoxelOpen : Boolean);
Var
   FName : String;
begin
   FName := ExtractFileDir(Filename) + '\' + copy(ExtractFilename(Filename),1,Length(ExtractFilename(Filename))-Length('.vxl')) + Ext;

   If Not FileExists(FName) then exit;

   Try
      Voxel.Free;
      Voxel := TVoxel.Create;
      Voxel.LoadFromFile(FName);
      VoxelOpen := True;
   Except
   End;
end;

Procedure LoadVoxel(Filename : String);
begin
   VoxelOpen := False;
   VoxelOpenT := False;
   VoxelOpenB := False;

   HVAOpen := False;
   HVAOpenT := False;
   HVAOpenB := False;

   VXLChanged := False;

   HVAFrame := 0;
   HVAFrameT := 0;
   HVAFrameB := 0;

   CurrentVoxelSection := 0;

   LoadVoxel2(Filename,'.vxl',VoxelFile,VoxelOpen);
   LoadVoxel2(Filename,'tur.vxl',VoxelTurret,VoxelOpenT);
   LoadVoxel2(Filename,'barl.vxl',VoxelBarrel,VoxelOpenB);

   If VoxelOpen then
   begin
      VXLFilename := Copy(ExtractFilename(Filename),1,Length(ExtractFilename(Filename))-Length(ExtractFileExt(Filename)));
      CurrentVoxel := @VoxelFile;
      CurrentSectionVoxel := @VoxelFile;
   end
   else
   begin
      VXLFilename := '';
      CurrentVoxel := nil;
      CurrentSectionVoxel := nil;
   end;

   LoadHVA(Filename);

   UpdateVoxelList;
end;

Procedure SetSpectrum(Colours : Boolean);
begin
   If Colours then
      SpectrumMode := ModeColours
   else
      SpectrumMode := ModeNormals;
end;

Procedure ChangeOffset(Vxl : TVoxel; Section : integer; X,Y,Z : single);
var
   CD : TVector3f;
begin
   CD.x := CurrentVoxel^.Section[Section].Tailer.MaxBounds[1] + (-(CurrentVoxel^.Section[Section].Tailer.MaxBounds[1]-CurrentVoxel^.Section[Section].Tailer.MinBounds[1])/2);
   CD.y := CurrentVoxel^.Section[Section].Tailer.MaxBounds[2] + (-(CurrentVoxel^.Section[Section].Tailer.MaxBounds[2]-CurrentVoxel^.Section[Section].Tailer.MinBounds[2])/2);
   CD.z := CurrentVoxel^.Section[Section].Tailer.MaxBounds[3] + (-(CurrentVoxel^.Section[Section].Tailer.MaxBounds[3]-CurrentVoxel^.Section[Section].Tailer.MinBounds[3])/2);

   Vxl.Section[Section].Tailer.MinBounds[1] := Vxl.Section[Section].Tailer.MinBounds[1] + X;
   Vxl.Section[Section].Tailer.MinBounds[2] := Vxl.Section[Section].Tailer.MinBounds[2] + Y;
   Vxl.Section[Section].Tailer.MinBounds[3] := Vxl.Section[Section].Tailer.MinBounds[3] + Z;

   Vxl.Section[Section].Tailer.MaxBounds[1] := Vxl.Section[Section].Tailer.MaxBounds[1] + X;
   Vxl.Section[Section].Tailer.MaxBounds[2] := Vxl.Section[Section].Tailer.MaxBounds[2] + Y;
   Vxl.Section[Section].Tailer.MaxBounds[3] := Vxl.Section[Section].Tailer.MaxBounds[3] + Z;
end;

begin
   VoxelBox_No := 0;
   VoxelBoxes.NumSections := 0;
   SetLength(VoxelBoxes.Sections,VoxelBox_No);

   VoxelBox_NoT := 0;
   VoxelBoxesT.NumSections := 0;
   SetLength(VoxelBoxesB.Sections,VoxelBox_NoT);

   VoxelBox_NoB := 0;
   VoxelBoxesB.NumSections := 0;
   SetLength(VoxelBoxesB.Sections,VoxelBox_NoB);
end.
