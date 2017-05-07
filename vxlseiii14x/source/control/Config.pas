unit Config;

// TConfiguration class
// ====================
//
// Created by Koen van de Sande
//
// Revision 1.0 (11-06-2001)
//
// New class for Voxel editor: This class keeps track of the used file list
// adding a file is easy: just call AddFileToHistory(FileName), and retrieving
// them can be done through the GetHistory() function.
// They are saved upon Destruction of this class (call Free when closing
// application)

interface

uses Registry, SysUtils, Windows, Constants;

type
   TConfiguration = class(TObject)
      public
         Icon: Integer;
         Assoc,Palette: Boolean;
         TS,RA2,Location3ds2vxl,INILocation3ds2vxl : string;
         FPSCap : longword;
         OpenCL, ResetNormalValue: boolean;
         ANType: integer;
         ANSmoothMyNormals, ANInfluenceMap, ANNewPixels, ANStretch: boolean;
         ANNormalizationRange, ANSmoothLevel, ANContrastLevel: single;
         Canvas2DBackgroundColor, Canvas3DBackgroundColor: longword;
         MaintainDimensionsRM: boolean;
         constructor Create();
         destructor Destroy(); override;
         procedure AddFileToHistory(FileName: String);
         function GetHistory(Index: Integer): String;
         procedure SaveSettings;
      private
         History: Array[0..HistoryDepth] of String;
   end;

implementation

{ TConfiguration }

procedure TConfiguration.AddFileToHistory(FileName: String);
var
   i,j: Integer;
begin
   //Add a file to the history list :)
   for i:=HistoryDepth downto 1 do
   begin
      History[i]:=History[i-1];
   end;
   History[0]:=FileName;

   //now check for doubles!
   for i:=1 to HistoryDepth-1 do
   begin
      if CompareText(FileName,History[i])=0 then
      begin  //the same!!!
         for j:=i to HistoryDepth - 1 do
         begin
            History[j]:=History[j+1];
         end;
         History[HistoryDepth]:='';
      end;
   end;
end;

constructor TConfiguration.Create;
var
  Reg: TRegistry;
  i: Integer;
  RegOpen : boolean;
begin
   Reg:=TRegistry.Create;
   try
      //Retrieve history information
      Reg.RootKey := HKEY_CURRENT_USER;
      RegOpen := Reg.OpenKey(RegPath,true);

      if RegOpen then
      begin
         for i:=0 to HistoryDepth - 1 do
         begin
            if Reg.ValueExists('History'+IntToStr(i)) then
               History[i] := Reg.ReadString('History'+IntToStr(i))
            else
               History[i] := '';
         end;
         if Reg.ValueExists('Icon') then
            Icon:=Reg.ReadInteger('Icon')
         else
            Icon:=0;

         if Reg.ValueExists('Assoc') then
            Assoc:=Reg.ReadBool('Assoc')
         else
            Assoc:=False;

         if Reg.ValueExists('Palette') then
            Palette:=Reg.ReadBool('Palette')
         else
            Palette:=False;

         if Reg.ValueExists('TS') then
            TS:=Reg.ReadString('TS')
         else
            TS:='TS';

         if Reg.ValueExists('RA2') then
            RA2:=Reg.ReadString('RA2')
         else
            RA2:='RA2';

         if Reg.ValueExists('FPSCap') then
            FPSCap := Reg.ReadInteger('FPSCap')
         else
            FPSCap := 70;

         if Reg.ValueExists('OpenCL') then
            OpenCL := Reg.ReadBool('OpenCL')
         else
            OpenCL := true;

         if Reg.ValueExists('3ds2vxlLocation') then
            Location3ds2vxl := Reg.ReadString('3ds2vxlLocation')
         else
            Location3ds2vxl := '';

         if Reg.ValueExists('3ds2vxlINILocation') then
            INILocation3ds2vxl := Reg.ReadString('3ds2vxlINILocation')
         else
            INILocation3ds2vxl := '';

         if Reg.ValueExists('ANType') then
            ANType := Reg.ReadInteger('ANType')
         else
            ANType := 0;

         if Reg.ValueExists('ANSmoothMyNormals') then
            ANSmoothMyNormals := Reg.ReadBool('ANSmoothMyNormals')
         else
            ANSmoothMyNormals := false;

         if Reg.ValueExists('ANInfluenceMap') then
            ANInfluenceMap := Reg.ReadBool('ANInfluenceMap')
         else
            ANInfluenceMap := true;

         if Reg.ValueExists('ANNewPixels') then
            ANNewPixels := Reg.ReadBool('ANNewPixels')
         else
            ANNewPixels := false;

         if Reg.ValueExists('ANStretch') then
            ANStretch := Reg.ReadBool('ANStretch')
         else
            ANStretch := true;

         if Reg.ValueExists('ANNormalizationRange') then
            ANNormalizationRange := Reg.ReadFloat('ANNormalizationRange')
         else
            ANNormalizationRange := 1.7;

         if Reg.ValueExists('ANSmoothLevel') then
            ANSmoothLevel := Reg.ReadFloat('ANSmoothLevel')
         else
            ANSmoothLevel := 1;

         if Reg.ValueExists('ANContrastLevel') then
            ANContrastLevel := Reg.ReadFloat('ANContrastLevel')
         else
            ANContrastLevel := 1;

         if Reg.ValueExists('2DBackgroundColor') then
            Canvas2DBackgroundColor := Reg.ReadInteger('2DBackgroundColor')
         else
            Canvas2DBackgroundColor := 15444620; // RGB(140, 170, 235)

         if Reg.ValueExists('3DBackgroundColor') then
            Canvas3DBackgroundColor := Reg.ReadInteger('3DBackgroundColor')
         else
            Canvas3DBackgroundColor := 15444620;
         if Reg.ValueExists('MaintainDimensionsRM') then
            MaintainDimensionsRM := Reg.ReadBool('MaintainDimensionsRM')
         else
            MaintainDimensionsRM := false;
         if Reg.ValueExists('ResetNormalValue') then
            ResetNormalValue := Reg.ReadBool('ResetNormalValue')
         else
            ResetNormalValue := false;
      end
      else
      begin
         for i:=0 to HistoryDepth - 1 do
         begin
            History[i] := '';
         end;
         Icon:=0;
         Assoc:=False;
         Palette:=False;
         TS:='TS';
         RA2:='RA2';
         FPSCap := 70;
         OpenCL := true;
         ANType := 0;
         ANSmoothMyNormals := false;
         ANInfluenceMap := true;
         ANNewPixels := false;
         ANStretch := true;
         ANNormalizationRange := 1.7;
         ANSmoothLevel := 1;
         ANContrastLevel := 1;
         Canvas2DBackgroundColor := 15444620; // RGB(140, 170, 235)
         Canvas3DBackgroundColor := 15444620;
         MaintainDimensionsRM := false;
         ResetNormalValue := false;
      end;

   finally
      Reg.CloseKey;
      Reg.Free;
   end;
end;

destructor TConfiguration.Destroy;
begin
   inherited;
   SaveSettings;
end;

function TConfiguration.GetHistory(Index: Integer): String;
begin
   GetHistory:='';
   if (Index>=0) and (Index<HistoryDepth) then
      GetHistory:=History[Index];
end;

procedure TConfiguration.SaveSettings;
var
   Reg: TRegistry;
   i: Integer;
begin
   //Retrieve history information
   Reg:=TRegistry.Create;
   Reg.RootKey := HKEY_CURRENT_USER;
   Reg.OpenKey(RegPath,true);

   for i:=0 to HistoryDepth - 1 do
   begin
      Reg.WriteString('History'+IntToStr(i),History[i]);
   end;
   Reg.WriteInteger('Icon',Icon);
   Reg.WriteBool('Assoc',Assoc);
   Reg.WriteBool('Palette',Palette);
   Reg.WriteString('TS',TS);
   Reg.WriteString('RA2',RA2);
   Reg.WriteInteger('FPSCap',FPSCap);
   Reg.WriteString('3ds2vxlLocation',Location3ds2vxl);
   Reg.WriteString('3ds2vxlINILocation',INILocation3ds2vxl);
   Reg.WriteBool('OpenCL',OpenCL);
   Reg.WriteInteger('ANType', ANType);
   Reg.WriteBool('ANSmoothMyNormals', ANSmoothMyNormals);
   Reg.WriteBool('ANInfluenceMap', ANInfluenceMap);
   Reg.WriteBool('ANNewPixels', ANNewPixels);
   Reg.WriteBool('ANStretch', ANStretch);
   Reg.WriteFloat('ANNormalizationRange', ANNormalizationRange);
   Reg.WriteFloat('ANSmoothLevel', ANSmoothLevel);
   Reg.WriteFloat('ANContrastLevel', ANContrastLevel);
   Reg.WriteInteger('2DBackgroundColor',Canvas2DBackgroundColor);
   Reg.WriteInteger('3DBackgroundColor',Canvas3DBackgroundColor);
   Reg.WriteBool('MaintainDimensionsRM', MaintainDimensionsRM);
   Reg.WriteBool('ResetNormalValue',ResetNormalValue);
   Reg.CloseKey;
   Reg.Free;
end;

end.
