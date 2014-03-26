unit ModelBank;

interface

{$INCLUDE source/Global_Conditionals.inc}

uses Model, ModelBankItem, SysUtils, {$IFDEF VOXEL_SUPPORT}Voxel, HVA,{$ENDIF} Palette,
   GlConstants, ShaderBank;

type
   TModelBank = class
      private
         FNextID: integer;
         Items : array of TModelBankItem;
         // Constructors and Destructors
         procedure Clear;
         // Adds
         function Search(const _Filename: string): integer; overload;
         function Search(const _Model: PModel): integer; overload;
{$IFDEF VOXEL_SUPPORT}
         function Search(const _Voxel: PVoxel): integer; overload;
{$ENDIF}
         function SearchReadOnly(const _Filename: string): integer; overload;
         function SearchReadOnly(const _Model: PModel): integer; overload;
{$IFDEF VOXEL_SUPPORT}
         function SearchReadOnly(const _Voxel: PVoxel): integer; overload;
{$ENDIF}
         function SearchEditable(const _Model: PModel): integer; overload;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         function Load(var _Model: PModel; const _Filename: string; _ShaderBank : PShaderBank): PModel;
         function Save(var _Model: PModel; const _Filename,_TexExt: string): boolean;
         // Adds
         function Add(const _filename: string; _ShaderBank : PShaderBank): PModel; overload;
         function Add(const _Model: PModel): PModel; overload;
{$IFDEF VOXEL_SUPPORT}
         function Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel; overload;
         function Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel; overload;
{$ENDIF}
         function AddReadOnly(const _filename: string; _ShaderBank : PShaderBank): PModel; overload;
         function AddReadOnly(const _Model: PModel): PModel; overload;
{$IFDEF VOXEL_SUPPORT}
         function AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel; overload;
         function AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel; overload;
{$ENDIF}
         function Clone(const _filename: string; _ShaderBank : PShaderBank): PModel; overload;
         function Clone(const _Model: PModel): PModel; overload;
{$IFDEF VOXEL_SUPPORT}
         function Clone(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel; overload;
{$ENDIF}
         // Deletes
         procedure Delete(const _Model : PModel);
         // Search
         function Search(const _ID: integer): TModel; overload;
         function SearchReadOnly(const _ID: integer): TModel; overload;
         function SearchEditable(const _ID: integer): TModel; overload;

         // Properties
         property NextID: integer read FNextID;
   end;


implementation

uses GlobalVars {$ifdef VOXEL_SUPPORT}, ModelVxt{$endif};

// Constructors and Destructors
constructor TModelBank.Create;
begin
   SetLength(Items,0);
   FNextID := 0;
end;

destructor TModelBank.Destroy;
begin
   Clear;
   inherited Destroy;
end;

// Only activated when the program is over.
procedure TModelBank.Clear;
var
   i : integer;
begin
   for i := Low(Items) to High(Items) do
   begin
      Items[i].Free;
   end;
end;

// I/O
function TModelBank.Load(var _Model: PModel; const _Filename: string; _ShaderBank : PShaderBank): PModel;
var
   i : integer;
begin
   i := SearchEditable(_Model);
   if i <> -1 then
   begin
      Items[i].DecCounter;
      if Items[i].GetCount = 0 then
      begin
         Items[i].Free;
         Items[i] := TModelBankItem.Create(_Filename,_ShaderBank);
         Items[i].SetEditable(true);
         inc(FNextID);
         Result := Items[i].GetModel;
      end
      else
      begin
         SetLength(Items,High(Items)+2);
         Items[High(Items)] := TModelBankItem.Create(_Filename,_ShaderBank);
         Items[High(Items)].SetEditable(true);
         inc(FNextID);
         Result := Items[High(Items)].GetModel;
      end;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Filename,_ShaderBank);
      Items[High(Items)].SetEditable(true);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.Save(var _Model: PModel; const _Filename, _TexExt: string): boolean;
var
   i : integer;
   Model : PModel;
begin
   i := Search(_Model);
   if i <> -1 then
   begin
      Model := Items[i].GetModel;
      Model^.SaveLODToFile(_Filename, _TexExt);
      Items[i].SetFilename(_Filename);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;


// Adds
function TModelBank.Search(const _filename: string): integer;
var
   i : integer;
begin
   Result := -1;
   if Length(_Filename) = 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if CompareStr(_Filename,Items[i].GetFilename) = 0 then
      begin
         Result := i;
         exit;
      end;
      inc(i);
   end;
end;

function TModelBank.Search(const _Model: PModel): integer;
var
   i : integer;
begin
   Result := -1;
   if _Model = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if _Model = Items[i].GetModel then
      begin
         Result := i;
         exit;
      end;
      inc(i);
   end;
end;

{$IFDEF VOXEL_SUPPORT}
function TModelBank.Search(const _Voxel: PVoxel): integer;
var
   i : integer;
   Model: PModel;
begin
   Result := -1;
   if _Voxel = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      Model := Items[i].GetModel;
      if Model <> nil then
      begin
         if Model^.ModelType = C_MT_VOXEL then
         begin
            if _Voxel = (Model^ as TModelVxt).Voxel then
            begin
               Result := i;
               exit;
            end;
         end;
      end;
      inc(i);
   end;
end;
{$ENDIF}

function TModelBank.Search(const _ID: integer): TModel;
var
   i : integer;
begin
   Result := nil;
   if (_ID < 0) then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i].GetModel <> nil then
      begin
         if _ID = Items[i].GetModel^.ID then
         begin
            Result := Items[i].GetModel^;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function TModelBank.SearchReadOnly(const _filename: string): integer;
var
   i : integer;
begin
   Result := -1;
   if Length(_Filename) = 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         if CompareStr(_Filename,Items[i].GetFilename) = 0 then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function TModelBank.SearchReadOnly(const _Model: PModel): integer;
var
   i : integer;
begin
   Result := -1;
   if _Model = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         if _Model = Items[i].GetModel then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;

{$IFDEF VOXEL_SUPPORT}
function TModelBank.SearchReadOnly(const _Voxel: PVoxel): integer;
var
   i : integer;
   Model: PModel;
begin
   Result := -1;
   if _Voxel = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         Model := Items[i].GetModel;
         if Model <> nil then
         begin
            if Model^.ModelType = C_MT_VOXEL then
            begin
               if _Voxel = (Model^ as TModelVxt).Voxel then
               begin
                  Result := i;
                  exit;
               end;
            end;
         end;
      end;
      inc(i);
   end;
end;
{$ENDIF}

function TModelBank.SearchReadOnly(const _ID: integer): TModel;
var
   i : integer;
begin
   Result := nil;
   if _ID < 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         if Items[i].GetModel <> nil then
         begin
            if _ID = Items[i].GetModel^.ID then
            begin
               Result := Items[i].GetModel^;
               exit;
            end;
         end;
      end;
      inc(i);
   end;
end;

function TModelBank.SearchEditable(const _Model: PModel): integer;
var
   i : integer;
begin
   Result := -1;
   if _Model = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i].GetEditable then
      begin
         if _Model = Items[i].GetModel then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function TModelBank.SearchEditable(const _ID: integer): TModel;
var
   i : integer;
begin
   Result := nil;
   if _ID < 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i].GetEditable then
      begin
         if _ID = Items[i].GetModel^.ID then
         begin
            Result := Items[i].GetModel^;
            exit;
         end;
      end;
      inc(i);
   end;
end;




function TModelBank.Add(const _filename: string; _ShaderBank : PShaderBank): PModel;
var
   i : integer;
begin
   i := Search(_Filename);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetModel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Filename,_ShaderBank);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.Add(const _Model: PModel): PModel;
var
   i : integer;
begin
   i := Search(_Model);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetModel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Model);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

{$IFDEF VOXEL_SUPPORT}
function TModelBank.Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel;
var
   i : integer;
begin
   i := Search(_Voxel);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetModel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Voxel,_HVA,_Palette,_ShaderBank,_Quality);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_VoxelSection,_Palette,_ShaderBank,_Quality);
   inc(FNextID);
   Result := Items[High(Items)].GetModel;
end;
{$ENDIF}

function TModelBank.AddReadOnly(const _filename: string; _ShaderBank : PShaderBank): PModel;
var
   i : integer;
begin
   i := SearchReadOnly(_Filename);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetModel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Filename,_ShaderBank);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.AddReadOnly(const _Model: PModel): PModel;
var
   i : integer;
begin
   i := SearchReadOnly(_Model);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetModel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Model);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

{$IFDEF VOXEL_SUPPORT}
function TModelBank.AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel;
var
   i : integer;
begin
   i := SearchReadOnly(_Voxel);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetModel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Voxel,_HVA,_Palette,_ShaderBank,_Quality);
      inc(FNextID);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_VoxelSection,_Palette,_ShaderBank,_Quality);
   inc(FNextID);
   Result := Items[High(Items)].GetModel;
end;
{$ENDIF}

function TModelBank.Clone(const _filename: string; _ShaderBank : PShaderBank): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_Filename,_ShaderBank);
   inc(FNextID);
   Result := Items[High(Items)].GetModel;
end;

function TModelBank.Clone(const _Model: PModel): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_Model);
   inc(FNextID);
   Result := Items[High(Items)].GetModel;
end;

{$IFDEF VOXEL_SUPPORT}
function TModelBank.Clone(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_Voxel,_HVA,_Palette,_ShaderBank,_Quality);
   inc(FNextID);
   Result := Items[High(Items)].GetModel;
end;
{$ENDIF}

// Deletes
procedure TModelBank.Delete(const _Model : PModel);
var
   i : integer;
begin
   i := Search(_Model);
   if i <> -1 then
   begin
      Items[i].DecCounter;
      if Items[i].GetCount = 0 then
      begin
         Items[i].Free;
         while i < High(Items) do
         begin
            Items[i] := Items[i+1];
            inc(i);
         end;
         SetLength(Items,High(Items));
      end;
   end;
end;


end.

