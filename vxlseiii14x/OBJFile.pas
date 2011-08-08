unit OBJFile;

interface

uses BasicDataTypes, BasicFunctions, SysUtils, Mesh, GlConstants, TextureBankItem,
ClassIntegerSet, Material;

type
   PObjMeshUnit = ^TObjMeshUnit;
   TObjMeshUnit = record
      Mesh : PMesh;
      VertexStart, NormalStart, TextureStart: longword;
      Next : PObjMeshUnit;
   end;

   TObjFile = class
      private
         Meshes : PObjMeshUnit;
         VertexCount,TextureCount,NormalsCount: longword;
         UseTexture: boolean;
         BaseName,ObjectName,TexExtension : string;
         // Constructor
         procedure Initialize;
         procedure Clear;
         procedure ClearMesh(var _Mesh: PObjMeshUnit);
         // I/O
         procedure WriteGroup(var _File: System.Text; const _GroupName: string; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
         procedure WriteGroupName(var _File: System.Text; const _GroupName: string);
         procedure WriteGroupFaces(var _File: System.Text; _VertexStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
         procedure WriteGroupFacesTexture(var _File: System.Text; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
         procedure WriteGroupVN(var _File: System.Text; const _GroupName: string; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
         procedure WriteGroupFacesVN(var _File: System.Text; _VertexStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
         procedure WriteGroupFacesTextureVN(var _File: System.Text; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
         procedure WriteVertexes(var _File: System.Text);
         procedure WriteNormals(var _File: System.Text);
         procedure WriteTextures(var _File: System.Text);
         procedure WriteMeshVertexes(var _File: System.Text; const _Vertexes: TAVector3f);
         procedure WriteMaterial(var _File: System.Text; const _Material: TMeshMaterial; const _GroupName: string);
         procedure WriteMeshNormals(var _File: System.Text; const _Normals: TAVector3f);
         procedure WriteMeshTexture(var _File: System.Text; const _Texture: TAVector2f);
         // Gets
         function CheckTexture: boolean;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure SaveToFile(const _Filename,_TexExt: string);
         // Adds
         procedure AddMesh(const _Mesh: PMesh);
   end;

implementation

// Constructors and Destructors
constructor TObjFile.Create;
begin
   Initialize;
end;

destructor TObjFile.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TObjFile.Initialize;
begin
   Meshes := nil;
   VertexCount := 0;
   TextureCount := 0;
   NormalsCount := 0;
   UseTexture := false;
end;

procedure TObjFile.Clear;
begin
   ClearMesh(Meshes);
end;

procedure TObjFile.ClearMesh(var _Mesh: PObjMeshUnit);
begin
   if _Mesh <> nil then
   begin
      ClearMesh(_Mesh^.Next);
      Dispose(_Mesh);
      _Mesh := nil;
   end;
end;

// I/O
procedure TObjFile.SaveToFile(const _Filename, _TexExt: string);
var
   OBJFIle,MTLFile: System.Text;
   MyMesh : PObjMeshUnit;
   MTLFilename: string;
   Material : integer;
begin
   AssignFile(OBJFIle,_Filename);
   BaseName := copy(_Filename,1,Length(_Filename)-4);
   ObjectName := ExtractFilename(BaseName);
   MTLFilename := BaseName+'.mtl';
   TexExtension := CopyString(_TexExt);
   AssignFile(MTLFile,MTLFilename);
   Rewrite(OBJFIle);
   Writeln(OBJFIle,'# OBJ Wavefront exported with Voxel Section Editor III.');
   Writeln(OBJFIle);
   Writeln(OBJFIle,'mtllib ' + ObjectName + '.mtl');
   Writeln(OBJFIle);
   Rewrite(MTLFIle);
   Writeln(MTLFIle,'# OBJ Wavefront Material exported with Voxel Section Editor III.');
   Writeln(MTLFIle);
   WriteVertexes(OBJFIle);
   UseTexture := CheckTexture;
   if UseTexture then
   begin
      WriteTextures(OBJFIle);
   end;
   WriteNormals(OBJFIle);
   MyMesh := Meshes;
   while MyMesh <> nil do
   begin
      for Material := Low(MyMesh^.Mesh^.Materials) to High(MyMesh^.Mesh^.Materials) do
      begin
         WriteMaterial(MTLFile,MyMesh^.Mesh^.Materials[Material],MyMesh^.Mesh^.Name);
         if MyMesh^.Mesh^.NormalsType = C_NORMALS_PER_VERTEX then
         begin
            WriteGroupVN(OBJFIle,MyMesh^.Mesh^.Name,MyMesh^.VertexStart,MyMesh^.TextureStart,MyMesh^.NormalStart,MyMesh^.Mesh^.VerticesPerFace,MyMesh^.Mesh^.Faces);
         end
         else
         begin
            WriteGroup(OBJFIle,MyMesh^.Mesh^.Name,MyMesh^.VertexStart,MyMesh^.TextureStart,MyMesh^.NormalStart,MyMesh^.Mesh^.VerticesPerFace,MyMesh^.Mesh^.Faces);
         end;
      end;
      MyMesh := MyMesh^.Next;
   end;
   CloseFile(OBJFIle);
   CloseFile(MTLFIle);
end;


procedure TObjFile.WriteGroup(var _File: System.Text; const _GroupName: string; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
begin
   WriteGroupName(_File,_GroupName);
   // usemtl stuff goes here.
   if UseTexture then
   begin
      WriteGroupFacesTexture(_File,_VertexStart,_TextureStart,_NormalsStart,_VertsPerFace,_Faces);
   end
   else
   begin
      WriteGroupFaces(_File,_VertexStart,_NormalsStart,_VertsPerFace,_Faces);
   end;
   if _VertsPerFace = 3 then
   begin
      Writeln(_File,'# ' + IntToStr((High(_Faces)+1) div 3) + ' triangles in group.');
   end
   else if _VertsPerFace = 4 then
   begin
      Writeln(_File,'# ' + IntToStr((High(_Faces)+1) div 4) + ' quads in group.');
   end;
   Writeln(_File);
end;

procedure TObjFile.WriteGroupVN(var _File: System.Text; const _GroupName: string; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
begin
   WriteGroupName(_File,_GroupName);
   Writeln(_File,'usemtl ' + _GroupName + '_mat');
   // usemtl stuff goes here.
   if UseTexture then
   begin
      WriteGroupFacesTextureVN(_File,_VertexStart,_TextureStart,_NormalsStart,_VertsPerFace,_Faces);
   end
   else
   begin
      WriteGroupFacesVN(_File,_VertexStart,_NormalsStart,_VertsPerFace,_Faces);
   end;
   if _VertsPerFace = 3 then
   begin
      Writeln(_File,'# ' + IntToStr((High(_Faces)+1) div 3) + ' triangles in group.');
   end
   else if _VertsPerFace = 4 then
   begin
      Writeln(_File,'# ' + IntToStr((High(_Faces)+1) div 4) + ' quads in group.');
   end;
   Writeln(_File);
end;

procedure TObjFile.WriteGroupName(var _File: System.Text; const _GroupName: string);
begin
   if Length(_GroupName) = 0 then
   begin // create a random name.
      Writeln(_File,'g mesh_' + IntToStr(Random(9999)));
   end
   else
   begin
      Writeln(_File,'g ' + _GroupName);
   end;
end;

procedure TObjFile.WriteGroupFaces(var _File: System.Text; _VertexStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
var
   maxf,f,v : integer;
begin
   maxf := ((High(_Faces)+1)div _VertsPerFace) -1;
   for f := Low(_Faces) to maxf do
   begin
      Write(_File,'f ');
      for v := 0 to (_VertsPerFace-1) do
      begin
         Write(_File,IntToStr(_Faces[(f*_VertsPerFace) + v] + _VertexStart) + '//' + IntToStr(f + _NormalsStart) + ' ');
      end;
      Writeln(_File);
   end;
end;

procedure TObjFile.WriteGroupFacesTexture(var _File: System.Text; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
var
   maxf,f,v : integer;
begin
   maxf := ((High(_Faces)+1)div _VertsPerFace) -1;
   for f := Low(_Faces) to maxf do
   begin
      Write(_File,'f ');
      for v := 0 to (_VertsPerFace-1) do
      begin
         Write(_File,IntToStr(_Faces[(f*_VertsPerFace) + v] + _VertexStart) + '/' + IntToStr(_Faces[(f*_VertsPerFace) + v] + _TextureStart) + '/' + IntToStr(f + _NormalsStart) + ' ');
      end;
      Writeln(_File);
   end;
end;

// Vertex Normals version.
procedure TObjFile.WriteGroupFacesVN(var _File: System.Text; _VertexStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
var
   maxf,f,v : integer;
begin
   maxf := ((High(_Faces)+1)div _VertsPerFace) -1;
   for f := Low(_Faces) to maxf do
   begin
      Write(_File,'f ');
      for v := 0 to (_VertsPerFace-1) do
      begin
         Write(_File,IntToStr(_Faces[(f*_VertsPerFace) + v] + _VertexStart) + '//' + IntToStr(_Faces[(f*_VertsPerFace) + v] + _NormalsStart) + ' ');
      end;
      Writeln(_File);
   end;
end;

procedure TObjFile.WriteGroupFacesTextureVN(var _File: System.Text; _VertexStart, _TextureStart, _NormalsStart,_VertsPerFace: longword; const _Faces: auint32);
var
   maxf,f,v : integer;
begin
   maxf := ((High(_Faces)+1)div _VertsPerFace) -1;
   for f := Low(_Faces) to maxf do
   begin
      Write(_File,'f ');
      for v := 0 to (_VertsPerFace-1) do
      begin
         Write(_File,IntToStr(_Faces[(f*_VertsPerFace) + v] + _VertexStart) + '/' + IntToStr(_Faces[(f*_VertsPerFace) + v] + _TextureStart) + '/' + IntToStr(_Faces[(f*_VertsPerFace) + v] + _NormalsStart) + ' ');
      end;
      Writeln(_File);
   end;
end;

procedure TObjFile.WriteVertexes(var _File: System.Text);
var
   MyMesh : PObjMeshUnit;
begin
   MyMesh := Meshes;
   while MyMesh <> nil do
   begin
      MyMesh^.VertexStart := VertexCount + 1;
      WriteMeshVertexes(_File,MyMesh^.Mesh^.Vertices);
      MyMesh := MyMesh^.Next;
   end;
   Writeln(_File,'# ' + IntToStr(VertexCount) + ' vertexes.');
   Writeln(_File);
end;

procedure TObjFile.WriteMeshVertexes(var _File: System.Text; const _Vertexes: TAVector3f);
var
   v : integer;
begin
   DecimalSeparator := '.';
   for v := Low(_Vertexes) to High(_Vertexes) do
   begin
      Writeln(_File,'v ' + FloatToStr(_Vertexes[v].X) + ' ' + FloatToStr(_Vertexes[v].Y) + ' ' + FloatToStr(_Vertexes[v].Z));
   end;
   inc(VertexCount,High(_Vertexes)+1);
end;

procedure TObjFile.WriteNormals(var _File: System.Text);
var
   MyMesh : PObjMeshUnit;
begin
   MyMesh := Meshes;
   while MyMesh <> nil do
   begin
      MyMesh^.NormalStart := NormalsCount + 1;
      if MyMesh^.Mesh^.NormalsType = C_NORMALS_PER_VERTEX then
      begin
         WriteMeshNormals(_File,MyMesh^.Mesh^.Normals);
      end
      else
      begin
         WriteMeshNormals(_File,MyMesh^.Mesh^.FaceNormals);
      end;
      MyMesh := MyMesh^.Next;
   end;
   Writeln(_File,'# ' + IntToStr(NormalsCount) + ' normals.');
   Writeln(_File);
end;

procedure TObjFile.WriteMeshNormals(var _File: System.Text; const _Normals: TAVector3f);
var
   n : integer;
begin
   DecimalSeparator := '.';
   for n := Low(_Normals) to High(_Normals) do
   begin
      Writeln(_File,'vn ' + FloatToStr(_Normals[n].X) + ' ' + FloatToStr(_Normals[n].Y) + ' ' + FloatToStr(_Normals[n].Z));
   end;
   inc(NormalsCount,High(_Normals)+1);
end;

procedure TObjFile.WriteTextures(var _File: System.Text);
var
   MyMesh : PObjMeshUnit;
begin
   MyMesh := Meshes;
   while MyMesh <> nil do
   begin
      MyMesh^.TextureStart := TextureCount + 1;
      WriteMeshTexture(_File,MyMesh^.Mesh^.TexCoords);
      MyMesh := MyMesh^.Next;
   end;
   Writeln(_File,'# ' + IntToStr(TextureCount) + ' texture coordinates.');
   Writeln(_File);
end;

procedure TObjFile.WriteMeshTexture(var _File: System.Text; const _Texture: TAVector2f);
var
   t : integer;
begin
   DecimalSeparator := '.';
   for t := Low(_Texture) to High(_Texture) do
   begin
      Writeln(_File,'vt ' + FloatToStr(_Texture[t].U) + ' ' + FloatToStr(_Texture[t].V));
   end;
   inc(TextureCount,High(_Texture)+1);
end;

procedure TObjFile.WriteMaterial(var _File: System.Text; const _Material: TMeshMaterial; const _GroupName: string);
var
   tex: integer;//PTextureBankItem;
   UsedTextures: CIntegerSet;
begin
   UsedTextures := CIntegerSet.Create;
   Writeln(_File);
   Writeln(_File,'newmtl ' + _GroupName + '_mat');
   Writeln(_File,'Ka ' + FloatToStr(_Material.Ambient.X) + ' ' + FloatToStr(_Material.Ambient.Y) + ' ' + FloatToStr(_Material.Ambient.Z));
   Writeln(_File,'Kd ' + FloatToStr(_Material.Diffuse.X) + ' ' + FloatToStr(_Material.Diffuse.Y) + ' ' + FloatToStr(_Material.Diffuse.Z));
   Writeln(_File,'Ks ' + FloatToStr(_Material.Specular.X) + ' ' + FloatToStr(_Material.Specular.Y) + ' ' + FloatToStr(_Material.Specular.Z));
   Writeln(_File,'Ke 0.0 0.0 0.0');
   Writeln(_File,'Ns ' + FloatToStr(_Material.Shininess));
   Writeln(_File,'Ni 1.5');
   Writeln(_File,'d 1.0');
   Writeln(_File,'Tr 0.0');
   Writeln(_File,'Tf 1.0 1.0 1.0');
   Writeln(_File,'illum 2');
   if High(_Material.Texture) >= 0 then
   begin
      for tex := Low(_Material.Texture) to High(_Material.Texture) do
      begin
         if _Material.Texture[tex] <> nil then
         begin
            if UsedTextures.Add(_Material.Texture[tex]^.GetID) then
            begin
               case _Material.Texture[tex]^.TextureType of
                  C_TTP_DIFFUSE:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '.' + TexExtension);
                     Writeln(_File,'map_Ka ' + ObjectName + '.' + TexExtension);
                     Writeln(_File,'map_Kd ' + ObjectName + '.' + TexExtension);
                  end;
                  C_TTP_NORMAL:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '_normal.' + TexExtension);
                     Writeln(_File,'bump ' + ObjectName + '_normal.' + TexExtension);
                  end;
                  C_TTP_DOT3BUMP:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '_bump.' + TexExtension);
                     Writeln(_File,'bump ' + ObjectName + '_bump.' + TexExtension);
                  end;
                  C_TTP_SPECULAR:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '_spec.' + TexExtension);
                     Writeln(_File,'map_Ks ' + ObjectName + '_spec.' + TexExtension);
                  end;
                  C_TTP_ALPHA:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '_alpha.' + TexExtension);
                     Writeln(_File,'map_d ' + ObjectName + '_alpha.' + TexExtension);
                  end;
                  C_TTP_AMBIENT:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '.' + TexExtension);
                     Writeln(_File,'map_Ka ' + ObjectName + '.' + TexExtension);
                     Writeln(_File,'map_Kd ' + ObjectName + '.' + TexExtension);
                  end;
                  C_TTP_DECAL:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '_decal.' + TexExtension);
                     Writeln(_File,'decal ' + ObjectName + '_decal.' + TexExtension);
                  end;
                  C_TTP_DISPLACEMENT:
                  begin
                     _Material.Texture[tex]^.SaveTexture(BaseName + '_disp.' + TexExtension);
                     Writeln(_File,'disp ' + ObjectName + '_disp.' + TexExtension);
                  end;
               end;
            end;
         end;
      end;
   end;
   UsedTextures.Free;
end;

// Adds
procedure TObjFile.AddMesh(const _Mesh: PMesh);
var
   Previous,Element: PObjMeshUnit;
begin
   new(Element);
   Element^.Mesh := _Mesh;
   Element^.VertexStart := 1;
   Element^.NormalStart := 1;
   Element^.TextureStart := 1;
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

// Gets
function TObjFile.CheckTexture: boolean;
var
   MyMesh: PObjMeshUnit;
begin
   Result := true;
   MyMesh := Meshes;
   while MyMesh <> nil do
   begin
      if High(MyMesh^.Mesh^.TexCoords) < 0 then
      begin
         Result := false;
         exit;
      end;
      MyMesh := MyMesh^.Next;
   end;
end;

end.
