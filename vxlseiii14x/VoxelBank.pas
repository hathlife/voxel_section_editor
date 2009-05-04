unit VoxelBank;

interface

uses Voxel, VoxelBankItem, SysUtils;

type
   TVoxelBank = class
      private
         Items : array of TVoxelBankItem;
         // Constructors and Destructors
         procedure Clear;
         // Adds
         function Search(const _Filename: string): integer; overload;
         function Search(const _Voxel: PVoxel): integer; overload;
         function SearchReadOnly(const _Filename: string): integer; overload;
         function SearchReadOnly(const _Voxel: PVoxel): integer; overload;
         function SearchEditable(const _Voxel: PVoxel): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         function Load(var _Voxel: PVoxel; const _Filename: string): PVoxel;
         function LoadNew: PVoxel;
         function Save(var _Voxel: PVoxel; const _Filename: string): boolean;
         // Adds
         function Add(const _filename: string): PVoxel; overload;
         function Add(const _Voxel: PVoxel): PVoxel; overload;
         function AddReadOnly(const _filename: string): PVoxel; overload;
         function AddReadOnly(const _Voxel: PVoxel): PVoxel; overload;
         function Clone(const _filename: string): PVoxel; overload;
         function Clone(const _Voxel: PVoxel): PVoxel; overload;
         function CloneEditable(const _Voxel: PVoxel): PVoxel; overload;
         // Deletes
         procedure Delete(const _Voxel : PVoxel);
   end;


implementation

// Constructors and Destructors
constructor TVoxelBank.Create;
begin
   SetLength(Items,0);
end;

destructor TVoxelBank.Destroy;
begin
   Clear;
   inherited Destroy;
end;

// Only activated when the program is over.
procedure TVoxelBank.Clear;
var
   i : integer;
begin
   for i := Low(Items) to High(Items) do
   begin
      Items[i].Free;
   end;
end;

// I/O
function TVoxelBank.Load(var _Voxel: PVoxel; const _Filename: string): PVoxel;
var
   i : integer;
   Voxel : PVoxel;
begin
   i := SearchEditable(_Voxel);
   if i <> -1 then
   begin
      Items[i].DecCounter;
      if Items[i].GetCount = 0 then
      begin
         try
            Items[i].Free;
            Items[i] := TVoxelBankItem.Create(_Filename);
            Result := Items[i].GetVoxel;
         except
            Result := nil;
            exit;
         end;
         Items[i].SetEditable(true);
      end
      else
      begin
         SetLength(Items,High(Items)+2);
         try
            Items[High(Items)] := TVoxelBankItem.Create(_Filename);
         except
            Items[High(Items)].Free;
            SetLength(Items,High(Items));
            Result := nil;
            exit;
         end;
         Items[High(Items)].SetEditable(true);
         Result := Items[High(Items)].GetVoxel;
      end;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         Items[High(Items)] := TVoxelBankItem.Create(_Filename);
      except
         Items[High(Items)].Free;
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Items[High(Items)].SetEditable(true);
      Result := Items[High(Items)].GetVoxel;
   end;
end;

function TVoxelBank.LoadNew: PVoxel;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := TVoxelBankItem.Create;
   Items[High(Items)].SetEditable(true);
   Result := Items[High(Items)].GetVoxel;
end;


function TVoxelBank.Save(var _Voxel: PVoxel; const _Filename: string): boolean;
var
   i : integer;
   Voxel : PVoxel;
begin
   i := Search(_Voxel);
   if i <> -1 then
   begin
      Voxel := Items[i].GetVoxel;
      Voxel^.SaveToFile(_Filename);
      Items[i].SetFilename(_Filename);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;


// Adds
function TVoxelBank.Search(const _filename: string): integer;
var
   i : integer;
begin
   Result := -1;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if CompareStr(_Filename,Items[i].GetFilename) = 0 then
      begin
         Result := i;
         exit;
      end;
   end;
end;

function TVoxelBank.Search(const _Voxel: PVoxel): integer;
var
   i : integer;
begin
   Result := -1;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if _Voxel = Items[i].GetVoxel then
      begin
         Result := i;
         exit;
      end;
   end;
end;

function TVoxelBank.SearchReadOnly(const _filename: string): integer;
var
   i : integer;
begin
   Result := -1;
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
   end;
end;

function TVoxelBank.SearchReadOnly(const _Voxel: PVoxel): integer;
var
   i : integer;
begin
   Result := -1;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         if _Voxel = Items[i].GetVoxel then
         begin
            Result := i;
            exit;
         end;
      end;
   end;
end;

function TVoxelBank.SearchEditable(const _Voxel: PVoxel): integer;
var
   i : integer;
begin
   Result := -1;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i].GetEditable then
      begin
         if _Voxel = Items[i].GetVoxel then
         begin
            Result := i;
            exit;
         end;
      end;
   end;
end;



function TVoxelBank.Add(const _filename: string): PVoxel;
var
   i : integer;
begin
   i := Search(_Filename);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetVoxel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         Items[High(Items)] := TVoxelBankItem.Create(_Filename);
      except
         Items[High(Items)].Free;
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)].GetVoxel;
   end;
end;

function TVoxelBank.Add(const _Voxel: PVoxel): PVoxel;
var
   i : integer;
begin
   i := Search(_Voxel);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetVoxel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         Items[High(Items)] := TVoxelBankItem.Create(_Voxel);
      except
         Items[High(Items)].Free;
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)].GetVoxel;
   end;
end;

function TVoxelBank.AddReadOnly(const _filename: string): PVoxel;
var
   i : integer;
begin
   i := SearchReadOnly(_Filename);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetVoxel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         Items[High(Items)] := TVoxelBankItem.Create(_Filename);
      except
         Items[High(Items)].Free;
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)].GetVoxel;
   end;
end;

function TVoxelBank.AddReadOnly(const _Voxel: PVoxel): PVoxel;
var
   i : integer;
begin
   i := SearchReadOnly(_Voxel);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetVoxel;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         Items[High(Items)] := TVoxelBankItem.Create(_Voxel);
      except
         Items[High(Items)].Free;
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)].GetVoxel;
   end;
end;

function TVoxelBank.Clone(const _filename: string): PVoxel;
begin
   SetLength(Items,High(Items)+2);
   try
      Items[High(Items)] := TVoxelBankItem.Create(_Filename);
   except
      Items[High(Items)].Free;
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Items[High(Items)].GetVoxel;
end;

function TVoxelBank.Clone(const _Voxel: PVoxel): PVoxel;
begin
   SetLength(Items,High(Items)+2);
   try
      Items[High(Items)] := TVoxelBankItem.Create(_Voxel);
   except
      Items[High(Items)].Free;
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Items[High(Items)].GetVoxel;
end;

function TVoxelBank.CloneEditable(const _Voxel: PVoxel): PVoxel;
begin
   SetLength(Items,High(Items)+2);
   try
      Items[High(Items)] := TVoxelBankItem.Create(_Voxel);
   except
      Items[High(Items)].Free;
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Items[High(Items)].SetEditable(true);
   Result := Items[High(Items)].GetVoxel;
end;


// Deletes
procedure TVoxelBank.Delete(const _Voxel : PVoxel);
var
   i : integer;
begin
   i := Search(_Voxel);
   if i <> -1 then
   begin
      Items[i].DecCounter;
      if Items[i].GetCount = 0 then
      begin
         Items[i].Free;
         while i < High(Items) do
            Items[i] := Items[i+1];
         SetLength(Items,High(Items));
      end;
   end;
end;


end.
