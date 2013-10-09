unit VoxelBankItem;

interface

uses Voxel, BasicFunctions;

type
   TVoxelBankItem = class
      private
         Counter: longword;
         Editable : boolean;
         Voxel : TVoxel;
         Filename: string;
      public
         // Constructor and Destructor
         constructor Create; overload;
         constructor Create(const _Filename: string); overload;
         constructor Create(const _Voxel: PVoxel); overload;
         destructor Destroy; override;
         // Sets
         procedure SetEditable(_value: boolean);
         procedure SetFilename(_value: string);
         // Gets
         function GetEditable: boolean;
         function GetFilename: string;
         function GetVoxel : PVoxel;
         // Counter
         function GetCount : integer;
         procedure IncCounter;
         procedure DecCounter;
   end;
   PVoxelBankItem = ^TVoxelBankItem;

implementation

// Constructors and Destructors
// This one starts a blank voxel.
constructor TVoxelBankItem.Create;
begin
   Voxel := TVoxel.Create;
   Counter := 1;
   Filename := '';
end;

constructor TVoxelBankItem.Create(const _Filename: string);
begin
   Voxel := TVoxel.Create;
   Voxel.LoadFromFile(_Filename);
   Counter := 1;
   Filename := CopyString(_Filename);
end;

constructor TVoxelBankItem.Create(const _Voxel: PVoxel);
begin
   Voxel := TVoxel.Create(_Voxel^);
   Counter := 1;
   Filename := CopyString(Voxel.Filename);
end;

destructor TVoxelBankItem.Destroy;
begin
   Voxel.Free;
   Filename := '';
   inherited Destroy;
end;

// Sets
procedure TVoxelBankItem.SetEditable(_value: boolean);
begin
   Editable := _value;
end;

procedure TVoxelBankItem.SetFilename(_value: string);
begin
   Filename := CopyString(_Value);
end;


// Gets
function TVoxelBankItem.GetEditable: boolean;
begin
   Result := Editable;
end;

function TVoxelBankItem.GetFilename: string;
begin
   Result := Filename;
end;

function TVoxelBankItem.GetVoxel : PVoxel;
begin
   Result := @Voxel;
end;

// Counter
function TVoxelBankItem.GetCount : integer;
begin
   Result := Counter;
end;

procedure TVoxelBankItem.IncCounter;
begin
   inc(Counter);
end;

procedure TVoxelBankItem.DecCounter;
begin
   Dec(Counter);
end;

end.
