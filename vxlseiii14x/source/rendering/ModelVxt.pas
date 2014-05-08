unit ModelVxt;

// Model: Voxel Extension, for models based from voxed used in Voxel Section Editor III

interface

{$INCLUDE source/Global_Conditionals.inc}

{$ifdef VOXEL_SUPPORT}

uses Palette, HVA, Voxel, Mesh, LOD, SysUtils, Graphics, GlConstants, ShaderBank,
      Model, MeshVxt;

type
   TVoxelCreationStruct = record
      Mesh: PMesh;
      i : integer;
      Section : TVoxelSection;
      Palette: TPalette;
      ShaderBank: PShaderBank;
      Quality: integer;
   end;
   PVoxelCreationStruct = ^TVoxelCreationStruct;


   TModelVxt = class(TModel)
   private
      // I/O
      procedure OpenVoxel;
      procedure OpenVoxelSection(const _VoxelSection: PVoxelSection);
   public
      // Skeleton:
      HVA : PHVA;
      // Source
      Voxel : PVoxel;
      VoxelSection : PVoxelSection;
      Quality: integer;
      // constructors and destructors
      constructor Create(const _Filename: string; _ShaderBank : PShaderBank); overload; override;
      constructor Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _ShaderBank : PShaderBank; _Quality : integer); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; const _HVA: PHVA; _ShaderBank : PShaderBank; _Quality : integer); overload;
      constructor Create(const _Model: TModel); overload; override;
      procedure Initialize(); override;
      procedure Clear; override;
      // I/O
      procedure RebuildModel;
      procedure RebuildLOD(i: integer);
      procedure RebuildCurrentLOD;
      procedure SynchronizeHVA;
      // Gets
      function GetVoxelCount: longword; override;
      // Sets
      procedure SetQuality(_value: integer); override;
      // Palette Related
      procedure ChangeRemappable (_Colour : TColor); override;
      procedure ChangePalette(const _Filename: string); override;
      // Copies
      procedure Assign(const _Model: TModel); override;
      // Misc
      procedure MakeVoxelHVAIndependent;
   end;
   PModelVxt = ^TModelVxt;

{$endif}

implementation

{$ifdef VOXEL_SUPPORT}

uses GlobalVars, GenericThread, HierarchyAnimation, BasicMathsTypes;

constructor TModelVxt.Create(const _Filename: string; _ShaderBank : PShaderBank);
begin
   Voxel := nil;
   VoxelSection := nil;
   Quality := C_QUALITY_MAX;
   inherited Create(_Filename, _ShaderBank);
end;

constructor TModelVxt.Create(const _Voxel: PVoxel; const _Palette: PPalette; const _HVA: PHVA; _ShaderBank : PShaderBank; _Quality : integer);
begin
   Filename := '';
   ShaderBank := _ShaderBank;
   Voxel := VoxelBank.Add(_Voxel);
   HVA := HVABank.Add(_HVA);
   VoxelSection := nil;
   Quality := _Quality;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModelVxt.Create(const _VoxelSection: PVoxelSection; const _Palette : PPalette; _ShaderBank : PShaderBank; _Quality : integer);
begin
   Filename := '';
   ShaderBank := _ShaderBank;
   Voxel := nil;
   VoxelSection := _VoxelSection;
   Quality := _Quality;
   New(Palette);
   Palette^ := TPalette.Create(_Palette^);
   CommonCreationProcedures;
end;

constructor TModelVxt.Create(const _Model: TModel);
begin
   Assign(_Model);
end;

procedure TModelVxt.Clear;
begin
   VoxelBank.Delete(Voxel);    // even if it is nil, no problem.
   HVABank.Delete(HVA);
   inherited Clear;
end;

procedure TModelVxt.Initialize();
var
   ext : string;
   HVAFilename : string;
begin
   FType := C_MT_VOXEL;
   // Check if we have a random file or a voxel.
   if Voxel = nil then
   begin
      if VoxelSection = nil then
      begin
         // We have a file to open.
         ext := ExtractFileExt(Filename);
         if (CompareStr(ext,'.vxl') = 0) then
         begin
            Voxel := VoxelBank.Add(Filename);
            HVAFilename := copy(Filename,1,Length(Filename)-3);
            HVAFilename := HVAFilename + 'hva';
            HVA := HVABank.Add(HVAFilename,Voxel);
            OpenVoxel;
         end;
      end
      else
      begin
         OpenVoxelSection(VoxelSection);
      end;
   end
   else  // we open the current voxel
   begin
      OpenVoxel;
   end;
   SynchronizeHVA;
   IsVisible := true;
end;

// I/O
function ThreadCreateFromVoxel(const _args: pointer): integer;
var
   Data: TVoxelCreationStruct;
begin
   if _args <> nil then
   begin
      Data := PVoxelCreationStruct(_args)^;
      (Data.Mesh)^ := TMeshVxt.CreateFromVoxel(Data.i,Data.Section,Data.Palette,Data.ShaderBank,Data.Quality);
      (Data.Mesh)^.Next := Data.i+1;
   end;
end;


procedure TModelVxt.OpenVoxel;
   function CreatePackageForThreadCall(const _Mesh: PMesh; _i : integer; const _Section: TVoxelSection; const _Palette: TPalette; _ShaderBank: PShaderBank; _Quality: integer): TVoxelCreationStruct;
   begin
      Result.Mesh := _Mesh;
      Result.i := _i;
      Result.Section := _Section;
      Result.Palette := _Palette;
      Result.ShaderBank := _ShaderBank;
      Result.Quality := _Quality;
   end;

   procedure LoadSections;
   var
      i : integer;
      Packages: array of TVoxelCreationStruct;
      Threads: array of TGenericThread;
      MyFunction : TGenericFunction;
   begin
      SetLength(Threads,Voxel^.Header.NumSections);
      SetLength(Packages,Voxel^.Header.NumSections);
      MyFunction := ThreadCreateFromVoxel;
      for i := 0 to (Voxel^.Header.NumSections-1) do
      begin
         Packages[i] := CreatePackageForThreadCall(Addr(LOD[0].Mesh[i]),i,Voxel^.Section[i],Palette^,ShaderBank,Quality);
         Threads[i] := TGenericThread.Create(MyFunction,Addr(Packages[i]));
      end;
      for i := 0 to (Voxel^.Header.NumSections-1) do
      begin
         Threads[i].WaitFor;
         Threads[i].Free;
      end;
      SetLength(Threads,0);
      SetLength(Packages,0);
   end;
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,Voxel^.Header.NumSections);
   LoadSections;
   LOD[0].Mesh[High(LOD[0].Mesh)].Next := -1;
   CurrentLOD := 0;
   FOpened := true;
end;

procedure TModelVxt.OpenVoxelSection(const _VoxelSection : PVoxelSection);
begin
   // We may use an existing voxel.
   SetLength(LOD,1);
   LOD[0] := TLOD.Create;
   SetLength(LOD[0].Mesh,1);
   LOD[0].Mesh[0] := TMeshVxt.CreateFromVoxel(0,_VoxelSection^,Palette^,ShaderBank,Quality);
   CurrentLOD := 0;
   HVA := HVABank.LoadNew(nil);
   FOpened := true;
end;

procedure TModelVxt.RebuildModel;
var
   i : integer;
begin
   for i := Low(LOD) to High(LOD) do
   begin
      RebuildLOD(i);
   end;
   SynchronizeHVA;
end;

procedure TModelVxt.RebuildLOD(i: integer);
var
   j,start : integer;
begin
   if Voxel <> nil then
   begin
      if Voxel^.Header.NumSections > LOD[i].GetNumMeshes then
      begin
         start := LOD[i].GetNumMeshes;
         SetLength(LOD[i].Mesh,Voxel^.Header.NumSections);
         for j := start to Voxel^.Header.NumSections - 1 do
         begin
            LOD[i].Mesh[j] := TMeshVxt.CreateFromVoxel(j,Voxel^.Section[j],Palette^,ShaderBank,Quality);
            LOD[i].Mesh[j].Next := j+1;
         end;
      end;
      for j := Low(LOD[i].Mesh) to High(LOD[i].Mesh) do
      begin
         (LOD[i].Mesh[j] as TMeshVxt).RebuildVoxel(Voxel^.Section[j],Palette^,Quality);
      end;
   end
   else if VoxelSection <> nil then
   begin
      (LOD[i].Mesh[0] as TMeshVxt).RebuildVoxel(VoxelSection^,Palette^,Quality);
   end
   else
   begin
      // At the moment, we won't do anything.
   end;
end;

procedure TModelVxt.RebuildCurrentLOD;
begin
   RebuildLOD(CurrentLOD);
   SynchronizeHVA;
end;

procedure TModelVxt.SynchronizeHVA;
var
   s, f: integer;
   Scale: TVector3f;
begin
   if HVA <> nil then
   begin
      if HA <> nil then
      begin
         HA^.Free;
         HA := nil;
      end;
      new(HA);
      HA^ := THierarchyAnimation.Create(HVA.Header.N_Sections, HVA.Header.N_Frames);
      for f := 0 to HVA.Header.N_Frames - 1 do
      begin
         for s := 0 to HVA.Header.N_Sections - 1 do
         begin
            // Copy transformation matrix values
            HA^.TransformAnimations[0].SetMatrix(HVA.GetMatrix(s, f), f, s);
            // SetScale.
            if Voxel <> nil then
            begin
               Scale.X := LOD[CurrentLOD].Mesh[s].Scale.X;
               Scale.Y := LOD[CurrentLOD].Mesh[s].Scale.Y;
               Scale.Z := LOD[CurrentLOD].Mesh[s].Scale.Z;
            end
            else
            begin
               Scale.X := 1/12;
               Scale.Y := 1/12;
               Scale.Z := 1/12;
            end;
            HA^.TransformAnimations[0].SetScale(Scale, s, f);
         end;
      end;
      HA^.SetTransformFPS(6); // 1 frame each 0.1 seconds.
      HA^.ExecuteTransformAnimationLoop := true;
   end
   else
   begin
      if HA <> nil then
      begin
         HA^.Free;
         HA := nil;
      end;
      new(HA);
      if High(LOD[CurrentLOD].Mesh) >= 0 then
      begin
         HA^ := THierarchyAnimation.Create(High(LOD[CurrentLOD].Mesh) + 1, 1);
      end
      else
      begin
         HA^ := THierarchyAnimation.Create(1, 1);
      end;
   end;
end;

// Gets
function TModelVxt.GetVoxelCount: longword;
var
   i: integer;
begin
   Result := 0;
   for i := Low(LOD[CurrentLOD].Mesh) to High(LOD[CurrentLOD].Mesh) do
   begin
      if LOD[CurrentLOD].Mesh[i].Opened and LOD[CurrentLOD].Mesh[i].IsVisible then
      begin
         inc(Result, (LOD[CurrentLOD].Mesh[i] as TMeshVxT).NumVoxels);
      end;
   end;
end;

// Sets
procedure TModelVxt.SetQuality(_value: integer);
begin
   Quality := _value;
   RebuildModel;
end;

// Palette Related
procedure TModelVxt.ChangeRemappable(_Colour: TColor);
begin
   if Palette <> nil then
   begin
      Palette^.ChangeRemappable(_Colour);
      RebuildModel;
   end;
end;

procedure TModelVxt.ChangePalette(const _Filename: string);
begin
   if Palette <> nil then
   begin
      Palette^.LoadPalette(_Filename);
      RebuildModel;
   end;
end;

// Copies
procedure TModelVxt.Assign(const _Model: TModel);
begin
   HVA := (_Model as TModelVxt).HVA;
   Voxel := (_Model as TModelVxt).Voxel;
   Quality := (_Model as TModelVxt).Quality;
   inherited Assign(_Model);
end;

// Misc
procedure TModelVxt.MakeVoxelHVAIndependent;
var
   HVATemp: PHVA;
   VoxelTemp: PVoxel;
begin
   if (HVA <> nil) then
   begin
      HVATemp := HVABank.Clone(HVA);
      HVABank.Delete(HVA);
      HVA := HVATemp;
   end;
   if (Voxel <> nil) then
   begin
      VoxelTemp := VoxelBank.Clone(Voxel);
      VoxelBank.Delete(Voxel);
      Voxel := VoxelTemp;
      HVA^.p_Voxel := Voxel;
   end;
end;

{$endif}
end.
