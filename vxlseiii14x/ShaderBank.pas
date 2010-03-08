unit ShaderBank;

interface

uses BasicDataTypes, dglOpengl, ShaderBankItem, SysUtils, Dialogs;

const
   C_SHD_PHONG = 0;

type
   TShaderBank = class
      private
         Items : array of TShaderBankItem;
         // Constructors and Destructors
         procedure Clear;
         // Adds
         function Search(const _Shader: PShaderBankItem): integer; overload;
      public
         // Constructors and Destructors
         constructor Create(const _ShaderDirectory: string);
         destructor Destroy; override;
         // I/O
         function Load(const _VertexFilename, _FragmentFilename: string): PShaderBankItem;
         // Gets
         function Get(_Type: integer): PShaderBankItem;
         // Deletes
         procedure Delete(const _Shader : PShaderBankItem);
   end;
   PShaderBank = ^TShaderBank;


implementation

// Constructors and Destructors
constructor TShaderBank.Create(const _ShaderDirectory: string);
var
   VertexFilename,FragmentFilename: string;
begin
   SetLength(Items,0);
   // Check if GLSL is supported by the hardware (requires OpenGL 2.0)
   if (gl_ARB_vertex_shader) and (gl_ARB_fragment_shader) then
   begin
      // Add Phong Shader.
      VertexFilename := IncludeTrailingPathDelimiter(_ShaderDirectory) + 'phong_vertexshader.txt';
      FragmentFilename := IncludeTrailingPathDelimiter(_ShaderDirectory) + 'phong_fragmentshader.txt';
      Load(VertexFilename,FragmentFilename);
   end
   else
   begin
      ShowMessage('Warning: Your hardware does not support GLSL. Models that uses shader effects will not be previewed correctly with this program.');
   end;
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
function TShaderBank.Load(const _VertexFilename,_FragmentFilename: string): PShaderBankItem;
var
   i : integer;
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

