unit ShaderBank;

interface

uses BasicDataTypes, dglOpengl, ShaderBankItem, SysUtils, Dialogs, GLConstants;

type
   TShaderBank = class
      private
         Items : array of TShaderBankItem;
         ShaderDirectory : string;
         // Constructors and Destructors
         procedure Clear;
         // I/O
         procedure Load(const _ProgramName: string); overload;
         // Adds
         function Search(const _Shader: PShaderBankItem): integer; overload;
      public
         // Constructors and Destructors
         constructor Create(const _ShaderDirectory: string);
         destructor Destroy; override;
         // I/O
         function Load(const _VertexFilename, _FragmentFilename: string): PShaderBankItem; overload;
         // Gets
         function Get(_Type: integer): PShaderBankItem;
         // Deletes
         procedure Delete(const _Shader : PShaderBankItem);
   end;
   PShaderBank = ^TShaderBank;


implementation

uses FormMain;

// Constructors and Destructors
constructor TShaderBank.Create(const _ShaderDirectory: string);
begin
   SetLength(Items,0);
   ShaderDirectory := IncludeTrailingPathDelimiter(_ShaderDirectory);
   // Check if GLSL is supported by the hardware (requires OpenGL 2.0)
{
   if (gl_ARB_vertex_shader) and ((gl_ARB_fragment_shader) or (GL_ATI_fragment_shader)) then
   begin
      // Add Phong Shaders.
      Load('phong');
      Load('phong_1tex');
   end;
}
end;

destructor TShaderBank.Destroy;
begin
   Clear;
   inherited Destroy;
end;

// Only activated when the program is over.
procedure TShaderBank.Clear;
var
   i : integer;
begin
   for i := Low(Items) to High(Items) do
   begin
      Items[i].Free;
   end;
end;

// I/O
procedure TShaderBank.Load(const _ProgramName: string);
var
   VertexFilename,FragmentFilename: string;
begin
   VertexFilename := ShaderDirectory + _ProgramName + '_vertexshader.txt';
   if not FileExists(VertexFilename) then
      FrmMain.AutoRepair(VertexFilename);
   FragmentFilename := ShaderDirectory + _ProgramName + '_fragmentshader.txt';
   if not FileExists(FragmentFilename) then
      FrmMain.AutoRepair(FragmentFilename);
   Load(VertexFilename,FragmentFilename);
end;

function TShaderBank.Load(const _VertexFilename,_FragmentFilename: string): PShaderBankItem;
begin
   SetLength(Items,High(Items)+2);
   try
      Items[High(Items)] := TShaderBankItem.Create(_VertexFilename,_FragmentFilename);
   except
      Items[High(Items)].Free;
      SetLength(Items,High(Items));
      Result := nil;
      exit;
   end;
   Result := Addr(Items[High(Items)]);
end;

// Gets
function TShaderBank.Get(_Type: integer): PShaderBankItem;
begin
   Result := nil;
   if _Type <= High(Items) then
   begin
      Result := @Items[_Type];
   end;
end;

// Adds
function TShaderBank.Search(const _Shader: PShaderBankItem): integer;
var
   i : integer;
begin
   Result := -1;
   if _Shader = nil then
      exit;
   i := Low(Items);
   while i <= High(Items) do
   begin
      if _Shader^.GetID = Items[i].GetID then
      begin
         Result := i;
         exit;
      end;
      inc(i);
   end;
end;

// Deletes
procedure TShaderBank.Delete(const _Shader : PShaderBankItem);
var
   i : integer;
begin
   i := Search(_Shader);
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

