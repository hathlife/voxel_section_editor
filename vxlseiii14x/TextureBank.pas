unit TextureBank;

interface

uses BasicDataTypes, dglOpengl, TextureBankItem, SysUtils, Windows, Graphics;

type
   TTextureBank = class
      private
         Items : array of PTextureBankItem;
         // Constructors and Destructors
         procedure Clear;
         // Adds
         function Search(const _Filename: string): integer; overload;
         function Search(const _ID: GLInt): integer; overload;
         function SearchReadOnly(const _Filename: string): integer; overload;
         function SearchReadOnly(const _ID: GLInt): integer; overload;
         function SearchEditable(const _ID: GLInt): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         function Load(var _ID: GLInt; const _Filename: string): PTextureBankItem;
         function LoadNew: PTextureBankItem;
         function Save(var _ID: GLInt; const _Filename: string): boolean;
         // Adds
         function Add(const _filename: string): PTextureBankItem; overload;
         function Add(const _ID: GLInt): PTextureBankItem; overload;
         function Add(const _Bitmap: TBitmap): PTextureBankItem; overload;
         function Add(const _Bitmaps: TABitmap): PTextureBankItem; overload;
         function AddReadOnly(const _filename: string): PTextureBankItem; overload;
         function AddReadOnly(const _ID: GLInt): PTextureBankItem; overload;
         function Clone(const _filename: string): PTextureBankItem; overload;
         function Clone(const _ID: GLInt): PTextureBankItem; overload;
         function Clone(const _Bitmap: TBitmap): PTextureBankItem; overload;
         function Clone(const _Bitmaps: TABitmap): PTextureBankItem; overload;
         function CloneEditable(const _ID: GLInt): PTextureBankItem; overload;
         // Deletes
         procedure Delete(const _ID : GLInt);
   end;


implementation

// Constructors and Destructors
constructor TTextureBank.Create;
begin
   SetLength(Items,0);
end;

destructor TTextureBank.Destroy;
begin
   Clear;
   inherited Destroy;
end;

// Only activated when the program is over.
procedure TTextureBank.Clear;
var
   i : integer;
begin
   for i := Low(Items) to High(Items) do
   begin
      Items[i]^.Free;
   end;
end;

// I/O
function TTextureBank.Load(var _ID: GLInt; const _Filename: string): PTextureBankItem;
var
   i : integer;
begin
   i := SearchEditable(_ID);
   if i <> -1 then
   begin
      Items[i].DecCounter;
      if Items[i].GetCount = 0 then
      begin
         try
            Items[i]^.Free;
            dispose(Items[i]);
            new(Items[i]);
            Items[i]^ := TTextureBankItem.Create(_Filename);
            Result := Items[i];
         except
            Result := nil;
            exit;
         end;
         Items[i]^.SetEditable(true);
      end
      else
      begin
         SetLength(Items,High(Items)+2);
         try
            new(Items[High(Items)]);
            Items[High(Items)]^ := TTextureBankItem.Create(_Filename);
         except
            Items[High(Items)]^.Free;
            SetLength(Items,High(Items));
            Result := nil;
            exit;
         end;
         Items[High(Items)]^.SetEditable(true);
         Result := Items[High(Items)];
      end;
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         new(Items[High(Items)]);
         Items[High(Items)]^ := TTextureBankItem.Create(_Filename);
      except
         Items[High(Items)]^.Free;
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Items[High(Items)]^.SetEditable(true);
      Result := Items[High(Items)];
   end;
end;

function TTextureBank.LoadNew: PTextureBankItem;
begin
   SetLength(Items,High(Items)+2);
   new(Items[High(Items)]);
   Items[High(Items)]^ := TTextureBankItem.Create;
   Items[High(Items)]^.SetEditable(true);
   Result := Items[High(Items)];
end;


function TTextureBank.Save(var _ID: GLInt; const _Filename: string): boolean;
var
   i : integer;
   ID : GLInt;
begin
   i := Search(_ID);
   if i <> -1 then
   begin
      ID := Items[i]^.GetID;
      Items[i]^.SaveTexture(_Filename);
      Result := true;
   end
   else
   begin
      Result := false;
   end;
end;


// Adds
function TTextureBank.Search(const _filename: string): integer;
var
   i : integer;
begin
   Result := -1;
   if Length(_Filename) = 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if CompareStr(_Filename,Items[i]^.GetFilename) = 0 then
      begin
         Result := i;
         exit;
      end;
      inc(i);
   end;
end;

function TTextureBank.Search(const _ID: GLInt): integer;
var
   i : integer;
begin
   Result := -1;
   if _ID <= 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if _ID = Items[i]^.GetID then
      begin
         Result := i;
         exit;
      end;
      inc(i);
   end;
end;

function TTextureBank.SearchReadOnly(const _filename: string): integer;
var
   i : integer;
begin
   Result := -1;
   if Length(_Filename) = 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i]^.GetEditable then
      begin
         if CompareStr(_Filename,Items[i]^.GetFilename) = 0 then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function TTextureBank.SearchReadOnly(const _ID: GLInt): integer;
var
   i : integer;
begin
   Result := -1;
   if _ID <= 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if not Items[i]^.GetEditable then
      begin
         if _ID = Items[i]^.GetID then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;

function TTextureBank.SearchEditable(const _ID: GLInt): integer;
var
   i : integer;
begin
   Result := -1;
   if _ID <= 0 then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if Items[i]^.GetEditable then
      begin
         if _ID = Items[i]^.GetID then
         begin
            Result := i;
            exit;
         end;
      end;
      inc(i);
   end;
end;



function TTextureBank.Add(const _filename: string): PTextureBankItem;
var
   i : integer;
begin
   i := Search(_Filename);
   if i <> -1 then
   begin
      Items[i]^.IncCounter;
      Result := Items[i];
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         new(Items[High(Items)]);
         Items[High(Items)]^ := TTextureBankItem.Create(_Filename);
      except
         Items[High(Items)]^.Free;
         dispose(Items[High(Items)]);
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)];
   end;
end;

function TTextureBank.Add(const _ID: GLInt): PTextureBankItem;
var
   i : integer;
begin
   i := Search(_ID);
   if i <> -1 then
   begin
      Items[i]^.IncCounter;
      Result := Items[i];
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         new(Items[High(Items)]);
         Items[High(Items)]^ := TTextureBankItem.Create(_ID);
      except
         Items[High(Items)]^.Free;
         Dispose(Items[High(Items)]);
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)];
   end;
end;

function TTextureBank.Add(const _Bitmap: TBitmap): PTextureBankItem;
begin
   Result := Clone(_Bitmap);
end;

function TTextureBank.Add(const _Bitmaps: TABitmap): PTextureBankItem;
begin
   Result := Clone(_Bitmaps);
end;

function TTextureBank.AddReadOnly(const _filename: string): PTextureBankItem;
var
   i : integer;
begin
   i := SearchReadOnly(_Filename);
   if i <> -1 then
   begin
      Items[i]^.IncCounter;
      Result := Items[i];
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         new(Items[High(Items)]);
         Items[High(Items)]^ := TTextureBankItem.Create(_Filename);
      except
         Items[High(Items)]^.Free;
         Dispose(Items[High(Items)]);
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)];
   end;
end;

function TTextureBank.AddReadOnly(const _ID: GLInt): PTextureBankItem;
var
   i : integer;
begin
   i := SearchReadOnly(_ID);
   if i <> -1 then
   begin
      Items[i]^.IncCounter;
      Result := Items[i];
   end
   else
   begin
      SetLength(Items,High(Items)+2);
      try
         new(Items[High(Items)]);
         Items[High(Items)]^ := TTextureBankItem.Create(_ID);
      except
         Items[High(Items)]^.Free;
         Dispose(Items[High(Items)]);
         SetLength(Items,High(Items));
         Result := nil;
         exit;
      end;
      Result := Items[High(Items)];
   end;
end;

function TTextureBank.Clone(const _filename: string): PTextureBankItem;
begin
   SetLength(Items,High(Items)+2);
   try
      new(Items[High(Items)]);
      Items[High(Items)]^ := TTextureBankItem.Create(_Filename);
   except
      Items[High(Items)]^.Free;
      Dispose(Items[High(Items)]);
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Items[High(Items)];
end;

function TTextureBank.Clone(const _ID: GLInt): PTextureBankItem;
begin
   SetLength(Items,High(Items)+2);
   try
      new(Items[High(Items)]);
      Items[High(Items)]^ := TTextureBankItem.Create(_ID);
   except
      Items[High(Items)]^.Free;
      Dispose(Items[High(Items)]);
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Items[High(Items)];
end;

function TTextureBank.Clone(const _Bitmap: TBitmap): PTextureBankItem;
begin
   SetLength(Items,High(Items)+2);
   try
      new(Items[High(Items)]);
      Items[High(Items)]^ := TTextureBankItem.Create(_Bitmap);
   except
      Items[High(Items)]^.Free;
      Dispose(Items[High(Items)]);
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Items[High(Items)];
end;

function TTextureBank.Clone(const _Bitmaps: TABitmap): PTextureBankItem;
begin
   SetLength(Items,High(Items)+2);
   try
      new(Items[High(Items)]);
      Items[High(Items)]^ := TTextureBankItem.Create(_Bitmaps);
   except
      Items[High(Items)]^.Free;
      Dispose(Items[High(Items)]);
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Items[High(Items)];
end;

function TTextureBank.CloneEditable(const _ID: GLInt): PTextureBankItem;
begin
   SetLength(Items,High(Items)+2);
   try
      new(Items[High(Items)]);
      Items[High(Items)]^ := TTextureBankItem.Create(_ID);
   except
      Items[High(Items)]^.Free;
      Dispose(Items[High(Items)]);
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Items[High(Items)]^.SetEditable(true);
   Result := Items[High(Items)];
end;


// Deletes
procedure TTextureBank.Delete(const _ID : GLInt);
var
   i : integer;
begin
   i := Search(_ID);
   if i <> -1 then
   begin
      Items[i]^.DecCounter;
      if Items[i]^.GetCount = 0 then
      begin
         Items[i]^.Free;
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
