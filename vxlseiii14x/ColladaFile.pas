unit ColladaFile;

interface

uses BasicDataTypes, XMLIntf, msxmldom, XMLDoc, Mesh;

type
   PColladaMeshUnit = ^TColladaMeshUnit;
   TColladaMeshUnit = record
      Mesh : PMesh;
      Next : PColladaMeshUnit;
   end;

   TColladaFile = class
      private
         Meshes : PColladaMeshUnit;
         // Constructor
         procedure Initialize;
         procedure Clear;
         procedure ClearMesh(var _Mesh: PColladaMeshUnit);
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure SaveToFile(const _Filename: string);
         // Adds
         procedure AddMesh(const _Mesh: PMesh);
   end;

implementation

// Constructors and Destructors
constructor TColladaFile.Create;
begin
   Initialize;
end;

destructor TColladaFile.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TColladaFile.Initialize;
begin
   Meshes := nil;
end;

procedure TColladaFile.Clear;
begin
   ClearMesh(Meshes);
end;

procedure TColladaFile.ClearMesh(var _Mesh: PColladaMeshUnit);
begin
   if _Mesh <> nil then
   begin
      ClearMesh(_Mesh^.Next);
      Dispose(_Mesh);
      _Mesh := nil;
   end;
end;

// I/O
procedure TColladaFile.SaveToFile(const _Filename: string);
var
   XMLDocument: IXMLDocument;
begin
   XMLDocument := TXMLDocument.Create(nil);
   XMLDocument.Active := true;
   // Basic XML settings.
   XMLDocument.Encoding := 'utf8';
   XMLDocument.Version := '1.0';
   // Now we create the COLLADA Node

   // Now, we save it to the file we want.
   // Clear memory
   XMLDocument.Active := false;
end;

// Adds
procedure TColladaFile.AddMesh(const _Mesh: PMesh);
var
   Previous,Element: PColladaMeshUnit;
begin
   new(Element);
   Element^.Mesh := _Mesh;
   Element^.Next := nil;
   if Meshes = nil then
   begin
      Meshes := Element;
   end
   else
   begin
      Previous := Meshes;
      while Previous^.Next <> nil do
      begin
         Previous := Previous^.Next;
      end;
      Previous^.Next := Element;
   end;
end;

end.
