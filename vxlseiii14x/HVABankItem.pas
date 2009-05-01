unit HVABankItem;

interface

uses HVA, Voxel, BasicFunctions, SysUtils;

type
   THVABankItem = class
      private
         Counter: longword;
         Editable : boolean;
         HVA : THVA;
         Filename: string;
         // Gets
         procedure GetFilenameFromHVA;
      public
         // Constructor and Destructor
         constructor Create; overload;
         constructor Create(const _Filename: string; _Voxel : PVoxel); overload;
         constructor Create(const _HVA: PHVA); overload;
         destructor Destroy; override;
         // Sets
         procedure SetEditable(_value: boolean);
         procedure SetFilename(_value: string);
         // Gets
         function GetEditable: boolean;
         function GetFilename: string;
         function GetHVA : PHVA;
         // Counter
         function GetCount : integer;
         procedure IncCounter;
         procedure DecCounter;
   end;
   PHVABankItem = ^THVABankItem;

implementation

// Constructors and Destructors
// This one starts a blank voxel.
constructor THVABankItem.Create;
begin
   HVA := THVA.Create;
   Counter := 1;
   Filename := '';
end;

constructor THVABankItem.Create(const _Filename: string; _Voxel : PVoxel);
begin
   HVA := THVA.Create(_Filename, _Voxel);
   Counter := 1;
   Filename := CopyString(_Filename);
end;

constructor THVABankItem.Create(const _HVA: PHVA);
var
   i : integer;
begin
   HVA := THVA.Create(_HVA^);
   Counter := 1;
   GetFilenameFromHVA;
end;

destructor THVABankItem.Destroy;
begin
   HVA.Free;
   Filename := '';
   inherited Destroy;
end;

// Sets
procedure THVABankItem.SetEditable(_value: boolean);
begin
   Editable := _value;
end;

procedure THVABankItem.SetFilename(_value: string);
begin
   Filename := CopyString(_Value);
end;


// Gets
function THVABankItem.GetEditable: boolean;
begin
   Result := Editable;
end;

function THVABankItem.GetFilename: string;
begin
   Result := Filename;
end;

function THVABankItem.GetHVA: PHVA;
begin
   Result := @HVA;
end;

procedure THVABankItem.GetFilenameFromHVA;
begin
   if HVA.p_Voxel <> nil then
   begin
      Filename := CopyString(HVA.p_Voxel^.Filename);
      Filename[Length(Filename)-2] := 'h';
      Filename[Length(Filename)-1] := 'v';
      Filename[Length(Filename)] := 'a';
      if not FileExists(Filename) then
         Filename := '';
   end
   else
   begin
      Filename := '';
   end;
end;


// Counter
function THVABankItem.GetCount : integer;
begin
   Result := Counter;
end;

procedure THVABankItem.IncCounter;
begin
   inc(Counter);
end;

procedure THVABankItem.DecCounter;
begin
   Dec(Counter);
end;

end.

