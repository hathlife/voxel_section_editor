unit ColladaFile;

interface

uses BasicDataTypes, XMLIntf, msxmldom, XMLDoc, Mesh, SysUtils, Camera, IntegerSet;

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
         // I/O
         procedure SaveColladaNode(var _XML: IXMLDocument; const _Filename: string);
         procedure SaveAssetNode(var _ParentNode: IXMLNode);
         procedure SaveCameraNode(var _ParentNode: IXMLNode);
         procedure SaveLightNode(var _ParentNode: IXMLNode);
         procedure SaveImagesNode(var _ParentNode: IXMLNode; const _BaseName: string);
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

uses FormMain;

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
   SaveColladaNode(XMLDocument,_Filename);

   // Now, we save it to the file we want.
   // Clear memory
   XMLDocument.Active := false;
end;

procedure TColladaFile.SaveColladaNode(var _XML: IXMLDocument; const _Filename: string);
var
   Node: IXMLNode;
   BaseName : string;
begin
   BaseName := copy(_Filename,1,Length(_Filename) - 8);

   Node := _XML.AddChild('COLLADA');
   Node.SetAttributeNS('xmlns','','http://www.collada.org/2005/11/COLLADASchema');
   Node.SetAttributeNS('version','','1.4.1');
   // Create asset node
   SaveAssetNode(Node);
   // Create library_cameras node
   //SaveCameraNode(Node);
   // Create library_lights node
   //SaveLightNode(Node);
   // Create library_images node
   // Create library_materials node
   // Create library_effects node
   // Create library_geometries node
   // Create library_visual_scenes node
   // Create scene node
end;

procedure TColladaFile.SaveAssetNode(var _ParentNode: IXMLNode);
var
   AssetNode,Node,ChildNode: IXMLNode;
   CurrentTime: TDateTime;
   Temp : string;
begin
   CurrentTime := Now;
   AssetNode := _ParentNode.AddChild('asset');
   Node := AssetNode.AddChild('contributor');
   ChildNode := Node.AddChild('author');
   ChildNode.Text := 'Author';
   ChildNode := Node.AddChild('authoring_tool');
   ChildNode.Text := 'Voxel Section Editor III v.' + APPLICATION_VER;
   ChildNode := Node.AddChild('comments');
   ChildNode.Text := 'Created with Voxel Section Editor III Modelizer Tool.';
   ChildNode := Node.AddChild('copyright');
   DateTimeToString(Temp,'yyyy',CurrentTime);
   ChildNode.Text := 'Copyright ' + Temp + ' to Author. If you want to use this asset in your project, modify it or redistribute it, please, get in contact with Author first.' ;
   Node := AssetNode.AddChild('created');
   DateTimeToString(Temp,'yyyy-mm-ddThh:nn:ssZ',CurrentTime);
   Node.Text := Temp;
   Node := AssetNode.AddChild('modified');
   Node.Text := Temp;
   Node := AssetNode.AddChild('unit');
   Node.SetAttributeNS('meter','','0.01');
   Node.SetAttributeNS('name','','centimeter');
   Node := AssetNode.AddChild('up_axis');
   Node.Text := 'Y_UP';
end;

procedure TColladaFile.SaveCameraNode(var _ParentNode: IXMLNode);
var
   CameraNode,Node,ChildNode: IXMLNode;
begin
   CameraNode := _ParentNode.AddChild('library_cameras');
   Node := CameraNode.AddChild('camera');
   Node.SetAttributeNS('id','','Camera');
   Node.SetAttributeNS('name','','Camera');
   Node := Node.AddChild('optics');
   Node := Node.AddChild('technique_common');
   Node := Node.AddChild('perspective');
   ChildNode := Node.AddChild('yfov');
   ChildNode.Text := '45';
   ChildNode := Node.AddChild('aspect_ratio');
   ChildNode.Text := '1';
   ChildNode := Node.AddChild('znear');
   ChildNode.Text := '1';
   ChildNode := Node.AddChild('zfar');
   ChildNode.Text := '4000';
end;

procedure TColladaFile.SaveLightNode(var _ParentNode: IXMLNode);
var
   CameraNode,Node,ChildNode: IXMLNode;
begin
   CameraNode := _ParentNode.AddChild('library_lights');
   Node := CameraNode.AddChild('light');
   Node.SetAttributeNS('id','','Light');
   Node.SetAttributeNS('name','','Light');
   Node := Node.AddChild('technique_common');
   Node := Node.AddChild('point');
   ChildNode := Node.AddChild('color');
   ChildNode.Text := '1 1 1';
   ChildNode := Node.AddChild('constant_attenuation');
   ChildNode.Text := '1';
   ChildNode := Node.AddChild('linear_attenuation');
   ChildNode.Text := '0';
   ChildNode := Node.AddChild('quadratic_attenuation');
   ChildNode.Text := '0';
end;

procedure TColladaFile.SaveImagesNode(var _ParentNode: IXMLNode; const _BaseName: string);
var
   ImageNode,Node,ChildNode: IXMLNode;
   Mesh : PColladaMeshUnit;
   UsedTextures: CIntegerSet;
   mat,tex : integer;
begin
   Mesh := Meshes;
   if Mesh <> nil then
   begin
      UsedTextures := CIntegerSet.Create;
      ImageNode := _ParentNode.AddChild('library_images');
      while Mesh <> nil do
      begin
         for mat := Low(Mesh^.Mesh.Materials) to High(Mesh^.Mesh.Materials) do
         begin
            if High(Mesh^.Mesh.Materials[mat].Texture) >= 0 then
            begin
               for tex := Low(Mesh^.Mesh.Materials[mat].Texture) to High(Mesh^.Mesh.Materials[mat].Texture) do
               begin
                  if Mesh^.Mesh.Materials[mat].Texture[tex] <> nil then
                  begin
                     if UsedTextures.Add(Mesh^.Mesh.Materials[mat].Texture[tex]^.GetID) then
                     begin
                        Node := ImageNode.AddChild('image');
                     end;
                  end;
               end;
            end;
         end;
         Mesh := Mesh^.Next;
      end;
      UsedTextures.Free;
   end;
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
