unit VVS;

{
Voxel Viewer Scene Format
Version:  1.0
Coded By: Stucuk
Coded On: 17/05/04
}

interface

Uses VH_Types;

Const
   VVSF_Ver = 1.0; // Only change if header changed or new arrays are added.

Procedure SaveVVS(Filename : string);
Procedure LoadVVS(Filename : string);

implementation

uses Windows,VH_Global,VH_Display;

Var
   VVSFile : TVVSFile;

Procedure AddToDataS(Id : Integer; Value : Single);
begin
   inc(VVSFile.Header.DataS_No);
   SetLength(VVSFile.DataS,VVSFile.Header.DataS_No);

   VVSFile.DataS[VVSFile.Header.DataS_No-1].ID := ID;
   VVSFile.DataS[VVSFile.Header.DataS_No-1].Value := Value;
end;

Procedure AddToDataB(Id : Integer; Value : Boolean);
begin
   inc(VVSFile.Header.DataB_No);
   SetLength(VVSFile.DataB,VVSFile.Header.DataB_No);

   VVSFile.DataB[VVSFile.Header.DataB_No-1].ID := ID;
   VVSFile.DataB[VVSFile.Header.DataB_No-1].Value := Value;
end;

Procedure BuildVVSFile;
begin
   VVSFile.Header.DataB_No := 0;
   VVSFile.Header.DataS_No := 0;
   VVSFile.Header.Game := VoxelFile.Section[0].Tailer.Unknown;

   VVSFile.Header.GroundName := GroundTex_Textures[GroundTex.ID].Name;
   VVSFile.Header.SkyName := SkyTexList[SkyTex].Texture_Name;
   VVSFile.Version := VVSF_Ver;
   SetLength(VVSFile.DataS,0);
   SetLength(VVSFile.DataB,0);

   AddToDataS(Ord(DSRotX),XRot);
   AddToDataS(Ord(DSRotY),YRot);
   AddToDataS(Ord(DSDepth),Depth);
   AddToDataS(Ord(DSXShift),TexShiftX);
   AddToDataS(Ord(DSYShift),TexShiftY);
   AddToDataS(Ord(DSGroundSize),GSize);
   AddToDataS(Ord(DSGroundHeight),GroundHeightOffset);
   AddToDataS(Ord(DSSkyXPos),SkyPos.X);
   AddToDataS(Ord(DSSkyYPos),SkyPos.Y);
   AddToDataS(Ord(DSSkyZPos),SkyPos.Z);
   AddToDataS(Ord(DSSkyWidth),SkySize.X);
   AddToDataS(Ord(DSSkyHeight),SkySize.Y);
   AddToDataS(Ord(DSSkyLength),SkySize.Z);
   AddToDataS(Ord(DSFOV),FOV);
   AddToDataS(Ord(DSDistance),DEPTH_OF_VIEW);
   AddToDataS(Ord(DSUnitRot),UnitRot);
   AddToDataS(Ord(DSDiffuseX),LightDif.X);
   AddToDataS(Ord(DSDiffuseY),LightDif.Y);
   AddToDataS(Ord(DSDiffuseZ),LightDif.Z);
   AddToDataS(Ord(DSAmbientX),LightAmb.X);
   AddToDataS(Ord(DSAmbientY),LightAmb.Y);
   AddToDataS(Ord(DSAmbientZ),LightAmb.Z);
   AddToDataS(Ord(DSAmbientZ),LightAmb.Z);
   AddToDataS(Ord(DSTurretRotationX),VXLTurretRotation.X);
   AddToDataS(Ord(DSBackgroundColR),BGColor.X);
   AddToDataS(Ord(DSBackgroundColG),BGColor.Y);
   AddToDataS(Ord(DSBackgroundColB),BGColor.Z);
   AddToDataS(Ord(DSUnitCount),UnitCount);
   AddToDataS(Ord(DSUnitSpace),UnitSpace);

   AddToDataB(Ord(DBDrawBarrel),DrawBarrel);
   AddToDataB(Ord(DBDrawTurret),DrawTurret);
   AddToDataB(Ord(DBShowDebug),DebugMode);
   AddToDataB(Ord(DBShowVoxelCount),ShowVoxelCount);
   AddToDataB(Ord(DBDrawGround),Ground_Tex_Draw);
   AddToDataB(Ord(DBTileGround),TileGround);
   AddToDataB(Ord(DBDrawSky),DrawSky);
   AddToDataB(Ord(DBCullFace),CullFace);
   AddToDataB(Ord(DBLightGround),LightGround);
end;

Procedure GetFromDataS(const Id : Integer; var Value : single);
var
   x : integer;
begin
   for x := 0 to VVSFile.Header.DataS_No-1 do
      if VVSFile.DataS[x].ID = ID then
      begin
         Value := VVSFile.DataS[x].Value;
         Exit;
      end;
end;

Procedure GetFromDataB(const Id : Integer; var Value : Boolean);
var
   x : integer;
begin
   for x := 0 to VVSFile.Header.DataB_No-1 do
      if VVSFile.DataB[x].ID = ID then
      begin
         Value := VVSFile.DataB[x].Value;
         Exit;
      end;
end;

Procedure FindGround(Const Texture : string; var GroundTex : TGTI);
var
   X : integer;
begin
   for x := 0 to GroundTex_No-1 do
      if GroundTex_Textures[x].Name = Texture then
      begin
         GroundTex.Tex := GroundTex_Textures[x].Tex;
         GroundTex.ID := x;
         exit;
      end;
end;


Procedure FindSky(Const Texture : string);
var
   X : integer;
begin
   for x := 0 to SkyTexList_No-1 do
      if SkyTexList[x].Texture_Name = Texture then
      begin
         SkyTex := x;
         BuildSkyBox;
         exit;
      end;
end;

Procedure SetVVSFile;
begin
   //if VoxelFile.Section[0].Tailer.Unknown = VVSFile.Header.Game then

   FindGround(VVSFile.Header.GroundName,GroundTex);
   FindSky(VVSFile.Header.SkyName);

   GetFromDataS(Ord(DSRotX),XRot);
   GetFromDataS(Ord(DSRotY),YRot);
   GetFromDataS(Ord(DSDepth),Depth);
   GetFromDataS(Ord(DSXShift),TexShiftX);
   GetFromDataS(Ord(DSYShift),TexShiftY);
   GetFromDataS(Ord(DSGroundSize),GSize);
   GetFromDataS(Ord(DSGroundHeight),GroundHeightOffset);
   GetFromDataS(Ord(DSSkyXPos),SkyPos.X);
   GetFromDataS(Ord(DSSkyYPos),SkyPos.Y);
   GetFromDataS(Ord(DSSkyZPos),SkyPos.Z);
   GetFromDataS(Ord(DSSkyWidth),SkySize.X);
   GetFromDataS(Ord(DSSkyHeight),SkySize.Y);
   GetFromDataS(Ord(DSSkyLength),SkySize.Z);
   GetFromDataS(Ord(DSFOV),FOV);
   GetFromDataS(Ord(DSDistance),DEPTH_OF_VIEW);
   GetFromDataS(Ord(DSUnitRot),UnitRot);
   GetFromDataS(Ord(DSDiffuseX),LightDif.X);
   GetFromDataS(Ord(DSDiffuseY),LightDif.Y);
   GetFromDataS(Ord(DSDiffuseZ),LightDif.Z);
   GetFromDataS(Ord(DSAmbientX),LightAmb.X);
   GetFromDataS(Ord(DSAmbientY),LightAmb.Y);
   GetFromDataS(Ord(DSAmbientZ),LightAmb.Z);
   GetFromDataS(Ord(DSTurretRotationX),VXLTurretRotation.X);
   GetFromDataS(Ord(DSBackgroundColR),BGColor.X);
   GetFromDataS(Ord(DSBackgroundColG),BGColor.Y);
   GetFromDataS(Ord(DSBackgroundColB),BGColor.Z);
   GetFromDataS(Ord(DSUnitCount),UnitCount);
   GetFromDataS(Ord(DSUnitSpace),UnitSpace);

   GetFromDataB(Ord(DBDrawBarrel),DrawBarrel);
   GetFromDataB(Ord(DBDrawTurret),DrawTurret);
   GetFromDataB(Ord(DBShowDebug),DebugMode);
   GetFromDataB(Ord(DBShowVoxelCount),ShowVoxelCount);
   GetFromDataB(Ord(DBDrawGround),Ground_Tex_Draw);
   GetFromDataB(Ord(DBTileGround),TileGround);
   GetFromDataB(Ord(DBDrawSky),DrawSky);
   GetFromDataB(Ord(DBCullFace),CullFace);
   GetFromDataB(Ord(DBLightGround),LightGround);
end;

Procedure SaveVVS(Filename : string);
var
   f : file;
   Written{,Writtent},x : integer;
begin
   //Writtent := 0;
   BuildVVSFile; // Collect the data

   AssignFile(F,Filename);  // Open file
   Rewrite(F,1); // Goto first byte?

   BlockWrite(F,VVSFile.Version,Sizeof(Single),Written); // Write Version
   BlockWrite(F,VVSFile.Header,Sizeof(TVVH),Written); // Write Header

   for x := 0 to VVSFile.Header.DataS_No-1 do
      BlockWrite(F,VVSFile.DataS[x],Sizeof(TVVD),Written); // Write DataS

   for x := 0 to VVSFile.Header.DataB_No-1 do
      BlockWrite(F,VVSFile.DataB[x],Sizeof(TVVDB),Written); // Write DataB

   CloseFile(F); // Close File
end;

Procedure LoadVVS(Filename : string);
var
   f : file;
   read,x : integer;
begin
   AssignFile(F,Filename);  // Open file
   Reset(F,1); // Goto first byte?

   BlockRead(F,VVSFile.Version,Sizeof(Single),read); // Read Header

   if VVSFile.Version <> VVSF_Ver then
   begin
      CloseFile(F);
      MessageBox(0,'Error: Wrong Version','Voxel Viewer Scene Error',0);
      Exit;
   end;

   BlockRead(F,VVSFile.Header,Sizeof(TVVH),read); // Read Header
   Setlength(VVSFile.DataS,VVSFile.Header.DataS_No);
   For x := 0 to VVSFile.Header.DataS_No-1 do
      BlockRead(F,VVSFile.DataS[x],Sizeof(TVVD),read); // Read DataS

   Setlength(VVSFile.DataB,VVSFile.Header.DataB_No);
   For x := 0 to VVSFile.Header.DataB_No-1 do
      BlockRead(F,VVSFile.DataB[x],Sizeof(TVVDB),read); // Read DataB

   CloseFile(F);

   SetVVSFile;
end;

end.
