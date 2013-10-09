unit HVABank;

interface

uses HVA, Voxel, HVABankItem, SysUtils;

type
   THVABank = class
      private
         Items : array of THVABankItem;
         // Constructors and Destructors
         procedure Clear;
         // Adds
         function Search(const _Filename: string): integer; overload;
         function Search(const _HVA: PHVA): integer; overload;
         function SearchReadOnly(const _Filename: string): integer; overload;
         function SearchReadOnly(const _HVA: PHVA): integer; overload;
         function SearchEditable(const _HVA: PHVA): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         function Load(var _HVA: PHVA; const _Filename: string; const _Voxel: PVoxel): PHVA;
         function LoadNew(const _Voxel: PVoxel): PHVA;
         function Save(var _HVA: PHVA; const _Filename: string): boolean;
         // Adds
         function Add(const _filename: string; _Voxel: PVoxel): PHVA; overload;
         function Add(const _HVA: PHVA): PHVA; overload;
         function AddReadOnly(const _filename: string; _Voxel: PVoxel): PHVA; overload;
         function AddReadOnly(const _HVA: PHVA): PHVA; overload;
         function Clone(const _filename: string; _Voxel: PVoxel): PHVA; overload;
         function Clone(const _HVA: PHVA): PHVA; overload;
         function CloneEditable(const _HVA: PHVA): PHVA; overload;
         // Deletes
         procedure Delete(const _HVA : PHVA);
   end;


implementation

// Constructors and Destructors
constructor THVABank.Create;
begin
   SetLength(Items,0);
end;

destructor THVABank.Destroy;
begin
   Clear;
   inherited Destroy;
end;

// Only activated when the program is over.
procedure THVABank.Clear;
var
   i : integer;
begin
   for i := Low(Items) to High(Items) do
   begin
      Items[i].Free;
   end;
end;

// I/O
function THVABank.Load(var _HVA: PHVA; const _Filename: string; const _Voxel: PVoxel): PHVA;
var
   i : integer;
begin
   i := SearchEditable(_HVA);
   if i <> -1 then
   begin
      Items[i].DecCounter;
      if Items[i].GetCount = 0 then
      begin
         Items[i].Free;
         Items[i] := THVABankItem.Create(_Filename, _Voxel);
         Items[i].SetEditable(true);
         Result := Items[i].GetHVA;
      end
      else
      begin
         SetLength(Items,High(Items)+2);
         Items[High(Items)] := THVABankItem.Create(_Filename, _Voxel);
         Items[High(Items)].SetEditable(true);
         Result := Items[High(Items)].GetHVA;
      end;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := THVABankItem.Create(_Filename, _Voxel);
      Items[High(Items)].SetEditable(true);
      Result := Items[High(Items)].GetHVA;
   end;
end;

function THVABank.LoadNew(const _Voxel : PVoxel): PHVA;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := THVABankItem.Create;
   Items[High(Items)].SetEditable(true);
   Result := Items[High(Items)].GetHVA;
   Result^.p_Voxel := _Voxel;
end;


function THVABank.Save(var _HVA: PHVA; const _Filename: string): boolean;
var
   i : integer;
   HVA : PHVA;
begin
   i := Search(_HVA);
   if i <> -1 then
   begin
      HVA := Items[i].GetHVA;
      HVA^.SaveFile(_Filename);
      Items[i].SetFilename(_Filename);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;


// Adds
function THVABank.Search(const _filename: string): integer;
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

function THVABank.Search(const _HVA: PHVA): integer;
var
   i : integer;
begin
   Result := -1;
   if _HVA = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if _HVA = Items[i].GetHVA then
      begin
         Result := i;
         exit;
      end;
      inc(i);
   end;
end;

function THVABank.SearchReadOnly(const _filename: string): integer;
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

function THVABank.SearchReadOnly(const _HVA: PHVA): integer;
var
   i : integer;
begin
   Result := -1;
   if _HVA = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i].GetEditable then
      begin
         if _HVA = Items[i].GetHVA then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function THVABank.SearchEditable(const _HVA: PHVA): integer;
var
   i : integer;
begin
   Result := -1;
   if _HVA = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i].GetEditable then
      begin
         if _HVA = Items[i].GetHVA then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;



function THVABank.Add(const _filename: string; _Voxel: PVoxel): PHVA;
var
   i : integer;
begin
   i := Search(_Filename);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetHVA;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := THVABankItem.Create(_Filename, _Voxel);
      Result := Items[High(Items)].GetHVA;
   end;
end;

function THVABank.Add(const _HVA: PHVA): PHVA;
var
   i : integer;
begin
   i := Search(_HVA);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetHVA;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := THVABankItem.Create(_HVA);
      Result := Items[High(Items)].GetHVA;
   end;
end;

function THVABank.AddReadOnly(const _filename: string; _Voxel: PVoxel): PHVA;
var
   i : integer;
begin
   i := SearchReadOnly(_Filename);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetHVA;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := THVABankItem.Create(_Filename, _Voxel);
      Result := Items[High(Items)].GetHVA;
   end;
end;

function THVABank.AddReadOnly(const _HVA: PHVA): PHVA;
var
   i : integer;
begin
   i := SearchReadOnly(_HVA);
   if i <> -1 then
   begin
      Items[i].IncCounter;
      Result := Items[i].GetHVA;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      Items[High(Items)] := THVABankItem.Create(_HVA);
      Result := Items[High(Items)].GetHVA;
   end;
end;


function THVABank.Clone(const _filename: string; _Voxel: PVoxel): PHVA;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := THVABankItem.Create(_Filename,_Voxel);
   Result := Items[High(Items)].GetHVA;
end;

function THVABank.Clone(const _HVA: PHVA): PHVA;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := THVABankItem.Create(_HVA);
   Result := Items[High(Items)].GetHVA;
end;

function THVABank.CloneEditable(const _HVA: PHVA): PHVA;
begin
   SetLength(Items,High(Items)+2);
   Items[High(Items)] := THVABankItem.Create(_HVA);
   Items[High(Items)].SetEditable(true);
   Result := Items[High(Items)].GetHVA;
end;

// Deletes
procedure THVABank.Delete(const _HVA : PHVA);
var
   i : integer;
begin
   i := Search(_HVA);
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

