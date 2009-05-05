unit VoxelDocumentBank;

interface

uses VoxelDocument;

type
   TVoxelDocumentBank = class
      private
         Documents : array of PVoxelDocument;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         procedure Clear;
         // Gets
         function GetNumDocuments: integer;
         // Adds
         function AddNew: PVoxelDocument;
         function Add(const _Filename: string): PVoxelDocument; overload;
         function Add(const _VoxelDocument: PVoxelDocument): PVoxelDocument; overload;
         function AddFullUnit(const _Filename: string): PVoxelDocument;
         // Removes
         procedure Remove(var _VoxelDocument: PVoxelDocument);

   end;

implementation

// Constructors and Destructors
constructor TVoxelDocumentBank.Create;
begin
   SetLength(Documents,0);
end;

destructor TVoxelDocumentBank.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TVoxelDocumentBank.Clear;
var
   i : integer;
begin
   for i := Low(Documents) to High(Documents) do
   begin
      if Documents[i] <> nil then
      begin
         Documents[i]^.Free;
      end;
   end;
   SetLength(Documents,0);
end;

// Gets
function TVoxelDocumentBank.GetNumDocuments: integer;
begin
   Result := High(Documents)+1;
end;

// Adds
function TVoxelDocumentBank.AddNew: PVoxelDocument;
begin
   SetLength(Documents,High(Documents)+2);
   New (Documents[High(Documents)]);
   Documents[High(Documents)]^ := TVoxelDocument.Create;
   Result := Documents[High(Documents)];
end;

function TVoxelDocumentBank.Add(const _Filename: string): PVoxelDocument;
begin
   SetLength(Documents,High(Documents)+2);
   New(Documents[High(Documents)]);
   Documents[High(Documents)]^ := TVoxelDocument.Create(_Filename);
   Result := Documents[High(Documents)];
end;

function TVoxelDocumentBank.Add(const _VoxelDocument: PVoxelDocument): PVoxelDocument;
begin
   if _VoxelDocument <> nil then
   begin
      SetLength(Documents,High(Documents)+2);
      New(Documents[High(Documents)]);
      Documents[High(Documents)]^ := TVoxelDocument.Create(_VoxelDocument^);
      Result := Documents[High(Documents)];
   end
   else
      Result := nil;
end;

function TVoxelDocumentBank.AddFullUnit(const _Filename: string): PVoxelDocument;
begin
   SetLength(Documents,High(Documents)+2);
   New(Documents[High(Documents)]);
   Documents[High(Documents)]^ := TVoxelDocument.CreateFullUnit(_Filename);
   Result := Documents[High(Documents)];
end;

// Removes
procedure TVoxelDocumentBank.Remove(var _VoxelDocument: PVoxelDocument);
var
   i : integer;
begin
   if _VoxelDocument = nil then
      exit;
   i := Low(Documents);
   while i <= High(Documents) do
   begin
      if (_VoxelDocument = Documents[i]) then
      begin
         Documents[i]^.Free;
         _VoxelDocument := nil;
         while i < High(Documents) do
         begin
            Documents[i] := Documents[i+1];
            inc(i);
         end;
         SetLength(Documents,High(Documents));
         exit;
      end;
      inc(i);
   end;
end;

end.
