unit normals;

// VXLSE III 1.4 :: Normals redesigned to support unlimmited directions.
// Normals class written by Banshee.

interface

uses BasicDataTypes, NormalsConstants;

const
   C_RES_INFINITE = -1;

type
   TNormals = class
      private
         FResolution : integer;
         FPalette : PAVector3f;

         // Constructors
         procedure ResetPalette;
         //Gets
         function ReadNormal(_id : longword): TVector3f;
         // Sets
         procedure SetPalette;
         procedure SetNormal(_id : longword; _normal : TVector3f);
         // Adds
         procedure AddToPalette(_normal: TVector3f);
         // Removes
         procedure RemoveFromPalette(_id : longword);
         // Copies
         procedure CopyNormalsAtPalette(_source, _dest: longword);
      public
         // Constructors
         constructor Create; overload;
         procedure Initialize;
         constructor Create(const _Type : integer); overload;
         constructor Create(const _Normals : TNormals); overload;
         destructor Destroy; override;
         procedure Clear;

         // Gets
         function GetIDFromNormal(const _vector : TVector3f): longword; overload;
         function GetIDFromNormal(_x, _y, _z : single): longword; overload;
         function GetLastID: integer;

         // Copies
         procedure Assign(const _Normals : TNormals);

         // Adds
         function AddNormal(const _Normal : TVector3f): longword;

         // Switch
         procedure SwitchNormalsType(_Type : integer);

         // Properties
         property Normal[_id : longword] : TVector3f read ReadNormal write SetNormal; default;
   end;
   PNormals = ^TNormals;

// Temporary data for compatibility with the old code.
var
   TSNormals : TNormals;
   RA2Normals : TNormals;
   CubeNormals : TNormals;

implementation

uses Voxel_Engine;

// Constructors
constructor TNormals.Create;
begin
   Initialize;
end;

constructor TNormals.Create(const _Type : integer);
begin
   FResolution := _Type;
   SetPalette;
end;

constructor TNormals.Create(const _Normals : TNormals);
begin
   Assign(_Normals);
end;

procedure TNormals.Initialize;
begin
   FResolution := C_RES_INFINITE;
   FPalette := nil;
end;

procedure TNormals.ResetPalette;
begin
   if (FPalette <> nil) and (FResolution = C_RES_INFINITE) then
   begin
      SetLength(FPalette^,0);
   end;
end;

destructor TNormals.Destroy;
begin
   ResetPalette;
   inherited Destroy;
end;

procedure TNormals.Clear;
begin
   ResetPalette;
end;

// Gets
function TNormals.ReadNormal(_id: longword): TVector3f;
begin
   if FResolution = C_RES_INFINITE then
   begin
      if (_id <= High(FPalette^)) then
         Result := CopyVector((FPalette^)[_id])
      else
         Result := SetVector(0,0,0);
   end
   else
   begin
      if (_id <= High(FPalette^)) then
         Result := CopyVector((FPalette^)[_id])
      else
         Result := SetVector(0,0,0);
   end;
end;

function TNormals.GetIDFromNormal(const _vector : TVector3f): longword;
var
   i : longword;
   lowerDiff, Diff : single;
begin
   Result := AddNormal(_vector);
   if Result = $FFFFFFFF then
   begin
      lowerDiff := 99999;
      for i := Low(FPalette^) to High(FPalette^) do
      begin
         Diff := (_vector.X - (FPalette^)[i].X) * (_vector.X - (FPalette^)[i].X) + (_vector.Y - (FPalette^)[i].Y) * (_vector.Y - (FPalette^)[i].Y) + (_vector.Z - (FPalette^)[i].Z) * (_vector.Z - (FPalette^)[i].Z);
         if Diff < lowerDiff then
         begin
            lowerDiff := Diff;
            Result := i;
         end;
      end;
   end;
end;

function TNormals.GetIDFromNormal(_x, _y, _z : single): longword;
begin
   Result := GetIDFromNormal(SetVector(_X,_Y,_Z));
end;

function TNormals.GetLastID: integer;
begin
   if FPalette <> nil then
      Result := High(FPalette^)
   else
      Result := -1;
end;


// Sets
procedure TNormals.SetNormal(_id: longword; _normal: TVector3f);
begin
   if FResolution = C_RES_INFINITE then
   begin
      if (_id <= High(FPalette^)) then
      begin
         (FPalette^)[_id].X := _Normal.X;
         (FPalette^)[_id].Y := _Normal.Y;
         (FPalette^)[_id].Z := _Normal.Z;
      end;
   end;
end;

procedure TNormals.SetPalette;
begin
   if FResolution = 2 then
   begin
      FPalette := Addr(TSNormals_Table);
   end
   else if FResolution = 4 then
   begin
      FPalette := Addr(RA2Normals_Table);
   end
   else if FResolution = 6 then
   begin
      FPalette := Addr(CubeNormals_Table);
   end
   else if FResolution = 7 then
   begin
      FPalette := Addr(FaceNormals_Table);
   end
   else if FResolution = 8 then
   begin
      FPalette := Addr(VertAndEdgeNormals_Table);
   end
   else
      Initialize;
end;

// Copies
procedure TNormals.Assign(const _Normals: TNormals);
var
   i : longword;
begin
   FResolution := _Normals.FResolution;
   if High(_Normals.FPalette^) > 0 then
   begin
      SetLength(FPalette^,High(_Normals.FPalette^)+1);
      for i := Low(FPalette^) to High(FPalette^) do
      begin
         (FPalette^)[i].X := (_Normals.FPalette^)[i].X;
         (FPalette^)[i].Y := (_Normals.FPalette^)[i].Y;
         (FPalette^)[i].Z := (_Normals.FPalette^)[i].Z;
      end;
   end
   else
      FPalette := nil;
end;

procedure TNormals.CopyNormalsAtPalette(_source, _dest: longword);
begin
   (FPalette^)[_dest].X := (FPalette^)[_source].X;
   (FPalette^)[_dest].Y := (FPalette^)[_source].Y;
   (FPalette^)[_dest].Z := (FPalette^)[_source].Z;
end;


// Adds
procedure TNormals.AddToPalette(_normal: TVector3f);
begin
   if FPalette <> nil then
   begin
      SetLength(FPalette^,High(FPalette^)+2);
   end
   else
   begin
      FPalette := new(PAVector3f);
      SetLength(FPalette^,1);
   end;
   (FPalette^)[High(FPalette^)].X := _Normal.X;
   (FPalette^)[High(FPalette^)].Y := _Normal.Y;
   (FPalette^)[High(FPalette^)].Z := _Normal.Z;
end;

function TNormals.AddNormal(const _Normal : TVector3f): longword;
var
   i : integer;
begin
   Result := $FFFFFFFF;
   if FResolution = C_RES_INFINITE then
   begin
      if FPalette <> nil then
      begin
         i := Low(FPalette^);
         while (i <= High(FPalette^)) do
         begin
            if (_Normal.X = (FPalette^)[i].X) and (_Normal.Y = (FPalette^)[i].Y) and (_Normal.Z = (FPalette^)[i].Z) then
            begin
               Result := i;
               exit;
            end;
            inc(i);
         end;
         AddToPalette(_Normal);
         Result := High(FPalette^);
      end
      else
      begin
         AddToPalette(_Normal);
         Result := High(FPalette^);
      end;
   end;
end;

// Removes
procedure TNormals.RemoveFromPalette(_id: Cardinal);
var
   i : integer;
begin
   if FPalette <> nil then
   begin
      if _id < High(FPalette^) then
      begin
         i := _id + 1;
         while i <  High(FPalette^) do
         begin
            CopyNormalsAtPalette(i+1,i);
            inc(i);
         end;
         SetLength(FPalette^,High(FPalette^));
      end
      else
      begin
         if _id = 0 then
         begin
            dispose(FPalette);
            FPalette := nil;
         end
         else
         begin
            SetLength(FPalette^,High(FPalette^));
         end;
      end;
   end;
end;

// Switch
procedure TNormals.SwitchNormalsType(_Type : integer);
begin
   if _Type <> FResolution then
   begin
      ResetPalette;
      FResolution := _Type;
      SetPalette;
   end;
end;


// Temporary data for compatibility with the old code.
begin
   TSNormals := TNormals.Create(2);
   RA2Normals := TNormals.Create(4);
   CubeNormals := TNormals.Create(6);
end.
