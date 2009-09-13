unit ModelBank;

interface

uses Model, ModelBankItem, SysUtils, Voxel, HVA, Palette;

type
   TModelBank = class
      private
         Items : array of TModelBankItem;
         // Constructors and Destructors
         procedure Clear;
         // Adds
         function Search(const _Filename: string): integer; overload;
         function Search(const _Model: PModel): integer; overload;
         function Search(const _Voxel: PVoxel): integer; overload;
         function SearchReadOnly(const _Filename: string): integer; overload;
         function SearchReadOnly(const _Model: PModel): integer; overload;
         function SearchReadOnly(const _Voxel: PVoxel): integer; overload;
         function SearchEditable(const _Model: PModel): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         function Load(var _Model: PModel; const _Filename: string): PModel;
         function Save(var _Model: PModel; const _Filename: string): boolean;
         // Adds
         function Add(const _filename: string): PModel; overload;
         function Add(const _Model: PModel): PModel; overload;
         function Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: boolean = false): PModel; overload;
         function Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: boolean = false): PModel; overload;
         function AddReadOnly(const _filename: string): PModel; overload;
         function AddReadOnly(const _Model: PModel): PModel; overload;
         function AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: boolean = false): PModel; overload;
         function AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _HighQuality: boolean = false): PModel; overload;
         function Clone(const _filename: string): PModel; overload;
         function Clone(const _Model: PModel): PModel; overload;
         function Clone(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _HighQuality: boolean = false): PModel; overload;
         // Deletes
         procedure Delete(const _Model : PModel);
   end;


implementation

// Constructors and Destructors
constructor TModelBank.Create;
begin
   SetLength(Items,0);
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
function TModelBank.Load(var _Model: PModel; const _Filename: string): PModel;
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
         Items[i] := TModelBankItem.Create(_Filename);
         Items[i].SetEditable(true);
         Result := Items[i].GetModel;
      end
      else
      begin
         SetLength(Items,High(Items)+2);
         Items[High(Items)] := TModelBankItem.Create(_Filename);
         Items[High(Items)].SetEditable(true);
         Result := Items[High(Items)].GetModel;
      end;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := TModelBankItem.Create(_Filename);
      Items[High(Items)].SetEditable(true);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.Save(var _Model: PModel; const _Filename: string): boolean;
var
   i : integer;
   Model : PModel;
begin
   i := Search(_Model);
   if i <> -1 then
   begin
      Model := Items[i].GetModel;
      Model^.SaveLODToFile(_Filename);
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

function TModelBank.Search(const _Voxel: PVoxel): integer;
var
   i : integer;
begin
   Result := -1;
   if _Voxel = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i].GetModel <> nil then
      begin
         if _Voxel = Items[i].GetModel^.Voxel then
         begin
            Result := i;
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

function TModelBank.SearchReadOnly(const _Voxel: PVoxel): integer;
var
   i : integer;
begin
   Result := -1;
   if _Voxel = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         if Items[i].GetModel <> nil then
         begin
            if _Voxel = Items[i].GetModel^.Voxel then
            begin
               Result := i;
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



function TModelBank.Add(const _filename: string): PModel;
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
      Items[High(Items)] := TModelBankItem.Create(_Filename);
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
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.Add(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette;  _HighQuality: boolean = false): PModel;
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
      Items[High(Items)] := TModelBankItem.Create(_Voxel,_HVA,_Palette,_HighQuality);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.Add(const _VoxelSection: PVoxelSection; const _Palette: PPalette;  _HighQuality: boolean = false): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_VoxelSection,_Palette,_HighQuality);
   Result := Items[High(Items)].GetModel;
end;

function TModelBank.AddReadOnly(const _filename: string): PModel;
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
      Items[High(Items)] := TModelBankItem.Create(_Filename);
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
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.AddReadOnly(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette;  _HighQuality: boolean = false): PModel;
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
      Items[High(Items)] := TModelBankItem.Create(_Voxel,_HVA,_Palette,_HighQuality);
      Result := Items[High(Items)].GetModel;
   end;
end;

function TModelBank.AddReadOnly(const _VoxelSection: PVoxelSection; const _Palette: PPalette;  _HighQuality: boolean = false): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_VoxelSection,_Palette,_HighQuality);
   Result := Items[High(Items)].GetModel;
end;


function TModelBank.Clone(const _filename: string): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_Filename);
   Result := Items[High(Items)].GetModel;
end;

function TModelBank.Clone(const _Model: PModel): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_Model);
   Result := Items[High(Items)].GetModel;
end;

function TModelBank.Clone(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette;  _HighQuality: boolean = false): PModel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TModelBankItem.Create(_Voxel,_HVA,_Palette,_HighQuality);
   Result := Items[High(Items)].GetModel;
end;



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

