unit ModelBankItem;

interface

uses Model, BasicFunctions, Voxel, HVA, Palette, GlConstants, ShaderBank;

type
   TModelBankItem = class
      private
         Counter: longword;
         Editable : boolean;
         Model : TModel;
         Filename: string;
      public
         // Constructor and Destructor
//         constructor Create; overload;
         constructor Create(const _Filename: string; _ShaderBank : PShaderBank); overload;
         constructor Create(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED); overload;
         constructor Create(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED); overload;
         constructor Create(const _Model: PModel); overload;
         destructor Destroy; override;
         // Sets
         procedure SetEditable(_value: boolean);
         procedure SetFilename(_value: string);
         // Gets
         function GetEditable: boolean;
         function GetFilename: string;
         function GetModel : PModel;
         // Counter
         function GetCount : integer;
         procedure IncCounter;
         procedure DecCounter;
   end;
   PModelBankItem = ^TModelBankItem;

implementation

// Constructors and Destructors
// This one starts a blank voxel.
{
constructor TModelBankItem.Create;
begin
   Model := TModel.Create;
   Counter := 1;
   Filename := '';
end;
}
constructor TModelBankItem.Create(const _Filename: string; _ShaderBank : PShaderBank);
begin
   Model := TModel.Create(_Filename, _ShaderBank);
   Counter := 1;
   Filename := CopyString(_Filename);
end;

constructor TModelBankItem.Create(const _Model: PModel);
begin
   Model := TModel.Create(_Model^);
   Counter := 1;
   Filename := CopyString(Model.Filename);
end;

constructor TModelBankItem.Create(const _Voxel: PVoxel; const _HVA: PHVA; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED);
begin
   Model := TModel.Create(_Voxel,_Palette,_HVA,_ShaderBank,_Quality);
   Counter := 1;
   Filename := CopyString(Model.Filename);
end;

constructor TModelBankItem.Create(const _VoxelSection: PVoxelSection; const _Palette: PPalette; _ShaderBank : PShaderBank; _Quality: integer = C_QUALITY_CUBED);
begin
   Model := TModel.Create(_VoxelSection,_Palette,_ShaderBank,_Quality);
   Counter := 1;
   Filename := CopyString(Model.Filename);
end;

destructor TModelBankItem.Destroy;
begin
   Model.Free;
   Filename := '';
   inherited Destroy;
end;

// Sets
procedure TModelBankItem.SetEditable(_value: boolean);
begin
   Editable := _value;
end;

procedure TModelBankItem.SetFilename(_value: string);
begin
   Filename := CopyString(_Value);
end;


// Gets
function TModelBankItem.GetEditable: boolean;
begin
   Result := Editable;
end;

function TModelBankItem.GetFilename: string;
begin
   Result := Filename;
end;

function TModelBankItem.GetModel: PModel;
begin
   Result := @Model;
end;

// Counter
function TModelBankItem.GetCount : integer;
begin
   Result := Counter;
end;

procedure TModelBankItem.IncCounter;
begin
   inc(Counter);
end;

procedure TModelBankItem.DecCounter;
begin
   Dec(Counter);
end;

end.

