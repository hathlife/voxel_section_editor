unit MeshBRepGeometry;

interface

uses BasicDataTypes, MeshGeometryBase, Material, dglOpenGl, GlConstants,
   RenderingMachine, ShaderBank, MeshPluginBase, NeighborhoodDataPlugin, Math,
   ClassMeshNormalsTool, SysUtils, ClassIntegerSet, ClassMeshColoursTool,
   ClassQuadList, ClassTriangleList;

type
   PMeshBRepGeometry = ^TMeshBRepGeometry;
   TMeshBRepGeometry = class (TMeshGeometryBase)
      private
         NormalsType,ColoursType,ColourGenStructure : byte;
         // Constructors and Destructors
         procedure InitializeAsTriangles;
         procedure InitializeAsQuads;
      protected
         // Sets
         procedure SetNumFaces(_Value: longword); override;
      public
         FaceType : GLINT; // GL_QUADS for quads, and GL_TRIANGLES for triangles
         VerticesPerFace : byte;
         Normals : TAVector3f;
         Colours : TAVector4f;
         Faces : auint32;
         IsVisible : boolean;
         // Rendering optimization
         Renderer: TRenderingMachine;

         // Constructors and Destructors.
         constructor Create; overload;
         constructor Create(_VerticesPerFace : byte); overload;
         constructor Create(_NumFaces : longword; _VerticesPerFace : byte); overload;
         constructor Create(_VerticesPerFace, _ColoursType, _NormalsType : byte); overload;
         constructor Create(_NumFaces : longword; _VerticesPerFace, _ColoursType, _NormalsType : byte); overload;
         constructor Create(const _Geometry : TMeshGeometryBase); overload;
         procedure InitializeWithParams(_NumFaces : longword; _VerticesPerFace, _ColoursType, _NormalsType : byte); overload;
         procedure Initialize; override;
         procedure Clear; override;
         procedure Reset; override;

         // Rendering
         procedure Render; override;
         procedure PreRender(_Mesh : Pointer); override;
         procedure RenderVectorial(_Mesh : Pointer); override;
         procedure ForceRefresh; override;

         // Sets
         procedure SetColoursType(_ColoursType: integer); override;
         procedure SetNormalsType(_NormalsType: integer); override;
         procedure SetColoursAndNormalsType(_ColoursType, _NormalsType: integer); override;
         procedure ForceColoursRendering; override;
         procedure SetDiffuseMappingShader;
         procedure SetNormalMappingShader;
         procedure SetBumpMappingShader;

         // Copies
         procedure Assign(const _Geometry : TMeshGeometryBase); override;

         // Adds
         procedure AddTrianglesFromList(var _TriangleList: CTriangleList; const _Vertices: TAVector3f);
         procedure AddQuadsFromList(var _QuadList: CQuadList; const _Vertices: TAVector3f);

         // Colours
         procedure OverrideTransparency(_TransparencyLevel: single);
         procedure ConvertVertexToFaceColours(const _VertexColours: TAVector4f);

         // Miscellaneous
         procedure RebuildNormals(_Mesh : Pointer);
         procedure RemoveInvisibleFaces(_Mesh : Pointer);
         procedure ConvertQuadsToTris(_Mesh : Pointer); overload;
         procedure ConvertQuadsToTris(); overload;
         procedure ConvertQuadsTo48Tris(_Mesh : Pointer); overload;
         procedure UpdateNumFaces;
   end;

implementation

uses Mesh, Windows;

// Constructors and Destructors.
constructor TMeshBRepGeometry.Create;
begin
   Next := nil;
   Renderer := TRenderingMachine.Create;
end;

constructor TMeshBRepGeometry.Create(_VerticesPerFace : byte);
begin
   InitializeWithParams(0, _VerticesPerFace, C_COLOURS_PER_FACE, C_NORMALS_PER_FACE);
end;

constructor TMeshBRepGeometry.Create(_NumFaces : longword; _VerticesPerFace : byte);
begin
   InitializeWithParams(_NumFaces, _VerticesPerFace, C_COLOURS_PER_FACE, C_NORMALS_PER_FACE);
end;

constructor TMeshBRepGeometry.Create(_VerticesPerFace, _ColoursType, _NormalsType : byte);
begin
   InitializeWithParams(0, _VerticesPerFace, _ColoursType, _NormalsType);
end;

constructor TMeshBRepGeometry.Create(_NumFaces : longword; _VerticesPerFace, _ColoursType, _NormalsType : byte);
begin
   InitializeWithParams(_NumFaces, _VerticesPerFace, _ColoursType, _NormalsType);
end;

procedure TMeshBRepGeometry.InitializeWithParams(_NumFaces : longword; _VerticesPerFace, _ColoursType, _NormalsType : byte);
begin
   Next := nil;
   // Set basic variables:
   VerticesPerFace := _VerticesPerFace;
   NumFaces := _NumFaces;
   // Let's set the face type:
   if VerticesPerFace = 4 then
      FaceType := GL_QUADS
   else
      FaceType := GL_TRIANGLES;
   // Let's set the array sizes.
   SetLength(Faces,NumFaces);
   SetLength(Normals,NumFaces);
   SetLength(Colours,NumFaces);
   // The rest
   Renderer := TRenderingMachine.Create;
   SetColoursAndNormalsType(_ColoursType,_NormalsType);
   ColourGenStructure := _ColoursType;
end;

constructor TMeshBRepGeometry.Create(const _Geometry : TMeshGeometryBase);
begin
   Next := nil;
   Renderer := TRenderingMachine.Create;
   Assign(_Geometry);
end;


procedure TMeshBRepGeometry.Initialize;
begin
   Renderer := TRenderingMachine.Create;
   ColoursType := C_COLOURS_PER_FACE;
   ColourGenStructure := C_COLOURS_PER_FACE;
   InitializeAsTriangles;
end;

procedure TMeshBRepGeometry.Clear;
begin
   ForceRefresh;
   inherited Clear;
end;

procedure TMeshBRepGeometry.InitializeAsTriangles;
begin
   VerticesPerFace := 3;
   FaceType := GL_TRIANGLES;
   SetNumFaces(0);
end;

procedure TMeshBRepGeometry.InitializeAsQuads;
begin
   VerticesPerFace := 4;
   FaceType := GL_QUADS;
   SetNumFaces(0);
end;

procedure TMeshBRepGeometry.Reset;
begin
   Clear;
end;

// Sets
procedure TMeshBRepGeometry.SetNumFaces(_Value: longword);
begin
   SetLength(Normals,_Value);
   SetLength(Colours,_Value);
   SetLength(Faces,_Value * VerticesPerFace);
   IsVisible := _Value > 0;
   inherited SetNumFaces(_Value);
end;

// Rendering
procedure TMeshBRepGeometry.Render;
begin
   Renderer.CallList;
end;

procedure TMeshBRepGeometry.PreRender(_Mesh : Pointer);
var
   MyMesh: PMesh;
   CurrentPass: integer;
begin
   MyMesh := PMesh(_Mesh);
   Renderer.StartRender;
   CurrentPass := Low(MyMesh^.Materials);
   while CurrentPass <= High(MyMesh^.Materials) do
   begin
      MyMesh^.Materials[CurrentPass].Enable;
      if NormalsType = C_NORMALS_PER_VERTEX then
      begin
         if ColoursType = C_COLOURS_PER_FACE then
         begin
            Renderer.DoRender(MyMesh^.Vertices, MyMesh^.Normals, Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,nil,MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end
         else
         begin
            Renderer.DoRender(MyMesh^.Vertices, MyMesh^.Normals, MyMesh^.Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,MyMesh^.GetPlugin(C_MPL_BUMPMAPDATA),MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end;
      end
      else
      begin
         if ColoursType = C_COLOURS_PER_FACE then
         begin
            Renderer.DoRender(MyMesh^.Vertices, Normals, Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,nil,MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end
         else
         begin
            Renderer.DoRender(MyMesh^.Vertices, Normals, MyMesh^.Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,nil,MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end;
      end;
      MyMesh^.Materials[CurrentPass].Disable;
      inc(CurrentPass);
   end;
   Renderer.FinishRender;
end;

procedure TMeshBRepGeometry.RenderVectorial(_Mesh : Pointer);
var
   MyMesh: PMesh;
   CurrentPass: integer;
begin
   MyMesh := PMesh(_Mesh);
   Renderer.StartRenderVectorial;
   CurrentPass := Low(MyMesh^.Materials);
   while CurrentPass <= High(MyMesh^.Materials) do
   begin
      MyMesh^.Materials[CurrentPass].Enable;
      if NormalsType = C_NORMALS_PER_VERTEX then
      begin
         if ColoursType = C_COLOURS_PER_FACE then
         begin
            Renderer.DoRender(MyMesh^.Vertices, MyMesh^.Normals, Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,nil,MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end
         else
         begin
            Renderer.DoRender(MyMesh^.Vertices, MyMesh^.Normals, MyMesh^.Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,MyMesh^.GetPlugin(C_MPL_BUMPMAPDATA),MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end;
      end
      else
      begin
         if ColoursType = C_COLOURS_PER_FACE then
         begin
            Renderer.DoRender(MyMesh^.Vertices, Normals, Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,nil,MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end
         else
         begin
            Renderer.DoRender(MyMesh^.Vertices, Normals, MyMesh^.Colours, MyMesh^.TexCoords,Faces,MyMesh^.Materials,FaceType,VerticesPerFace,nil,MyMesh^.ShaderBank,NumFaces,CurrentPass);
         end;
      end;
      MyMesh^.Materials[CurrentPass].Disable;
      inc(CurrentPass);
   end;
   Renderer.FinishRenderVectorial;
end;


procedure TMeshBRepGeometry.ForceRefresh;
begin
   Renderer.ForceRefresh;
end;

// Sets
procedure TMeshBRepGeometry.SetColoursType(_ColoursType: integer);
begin
   ColoursType := _ColoursType and 3;
   Renderer.SetRenderingProcedure(NormalsType, ColoursType);
end;

procedure TMeshBRepGeometry.SetNormalsType(_NormalsType: integer);
begin
   NormalsType := _NormalsType and 3;
   Renderer.SetRenderingProcedure(NormalsType, ColoursType);
end;

procedure TMeshBRepGeometry.SetColoursAndNormalsType(_ColoursType, _NormalsType: integer);
begin
   ColoursType := _ColoursType and 3;
   NormalsType := _NormalsType and 3;
   Renderer.SetRenderingProcedure(NormalsType, ColoursType);
end;

procedure TMeshBRepGeometry.ForceColoursRendering;
begin
   ColoursType := ColourGenStructure;
   Renderer.SetRenderingProcedure(NormalsType, ColoursType);
end;

procedure TMeshBRepGeometry.SetDiffuseMappingShader;
begin
   Renderer.SetDiffuseMappingShader;
end;

procedure TMeshBRepGeometry.SetNormalMappingShader;
begin
   Renderer.SetNormalMappingShader;
end;

procedure TMeshBRepGeometry.SetBumpMappingShader;
begin
   Renderer.SetBumpMappingShader;
end;


// Copies
procedure TMeshBRepGeometry.Assign(const _Geometry : TMeshGeometryBase);
var
   i : integer;
begin
   SetColoursAndNormalsType((_Geometry as TMeshBRepGeometry).ColoursType,(_Geometry as TMeshBRepGeometry).NormalsType);
   FaceType := (_Geometry as TMeshBRepGeometry).FaceType;
   VerticesPerFace := (_Geometry as TMeshBRepGeometry).VerticesPerFace;
   IsVisible := (_Geometry as TMeshBRepGeometry).IsVisible;
   SetLength(Faces,High((_Geometry as TMeshBRepGeometry).Faces)+1);
   for i := Low(Faces) to High(Faces) do
   begin
      Faces[i] := (_Geometry as TMeshBRepGeometry).Faces[i];
   end;
   SetLength(Normals,High((_Geometry as TMeshBRepGeometry).Normals)+1);
   for i := Low(Normals) to High(Normals) do
   begin
      Normals[i].X := (_Geometry as TMeshBRepGeometry).Normals[i].X;
      Normals[i].Y := (_Geometry as TMeshBRepGeometry).Normals[i].Y;
      Normals[i].Z := (_Geometry as TMeshBRepGeometry).Normals[i].Z;
   end;
   SetLength(Colours,High((_Geometry as TMeshBRepGeometry).Colours)+1);
   for i := Low(Colours) to High(Colours) do
   begin
      Colours[i].X := (_Geometry as TMeshBRepGeometry).Colours[i].X;
      Colours[i].Y := (_Geometry as TMeshBRepGeometry).Colours[i].Y;
      Colours[i].Z := (_Geometry as TMeshBRepGeometry).Colours[i].Z;
      Colours[i].W := (_Geometry as TMeshBRepGeometry).Colours[i].W;
   end;
   inherited Assign(_Geometry);
end;

// Colours
procedure TMeshBRepGeometry.OverrideTransparency(_TransparencyLevel : single);
var
   c : integer;
begin
   for c := Low(Colours) to High(Colours) do
   begin
      Colours[c].W := _TransparencyLevel;
   end;
end;

procedure TMeshBRepGeometry.ConvertVertexToFaceColours(const _VertexColours: TAVector4f);
var
   Tool: TMeshColoursTool;
   OriginalColours : TAVector4f;
   {$ifdef SPEED_TEST}
   StopWatch : TStopWatch;
   {$endif}
begin
   {$ifdef SPEED_TEST}
   StopWatch := TStopWatch.Create(true);
   {$endif}
   if (ColoursType = C_COLOURS_PER_VERTEX) then
   begin
      Tool := TMeshColoursTool.Create;
      Tool.TransformVertexToFaceColours(_VertexColours,Colours,Faces,VerticesPerFace);
      ColourGenStructure := C_COLOURS_PER_FACE;
      SetColoursType(C_COLOURS_PER_FACE);
      ForceRefresh;
      Tool.Free;
   end;
end;

// Adds
procedure TMeshBRepGeometry.AddTrianglesFromList(var _TriangleList: CTriangleList; const _Vertices: TAVector3f);
var
   x,y: integer;
   Tool : TMeshNormalsTool;
begin
   // Build new quads (faces, normals, colours).
   if VerticesPerFace = 3 then
   begin
      if _TriangleList.Count > 0 then
      begin
         Tool := TMeshNormalsTool.Create;
         x := NumFaces * 3;
         y := NumFaces;
         NumFaces := NumFaces + _TriangleList.Count;
         _TriangleList.GoToFirstElement;
         while x < High(Faces) do
         begin
            Faces[x] := _TriangleList.V1;
            Faces[x+1] := _TriangleList.V2;
            Faces[x+2] := _TriangleList.V3;
            Colours[y].X := GetRValue(_TriangleList.Colour) / 255;
            Colours[y].Y := GetGValue(_TriangleList.Colour) / 255;
            Colours[y].Z := GetBValue(_TriangleList.Colour) / 255;
            Colours[y].W := 0;
            Normals[y] := Tool.GetNormalsValue(_Vertices[_TriangleList.V1],_Vertices[_TriangleList.V2],_Vertices[_TriangleList.V3]);
            _TriangleList.GoToNextElement;
            inc(y);
            inc(x,3);
         end;
         Tool.Free;
      end;
   end;
end;

procedure TMeshBRepGeometry.AddQuadsFromList(var _QuadList: CQuadList; const _Vertices: TAVector3f);
var
   x,y: integer;
   Tool : TMeshNormalsTool;
begin
   // Build new quads (faces, normals, colours).
   if VerticesPerFace = 4 then
   begin
      if _QuadList.Count > 0 then
      begin
         Tool := TMeshNormalsTool.Create;
         x := NumFaces * 4;
         y := NumFaces;
         NumFaces := NumFaces + _QuadList.Count;
         _QuadList.GoToFirstElement;
         while x < High(Faces) do
         begin
            Faces[x] := _QuadList.V1;
            Faces[x+1] := _QuadList.V2;
            Faces[x+2] := _QuadList.V3;
            Faces[x+3] := _QuadList.V4;
            Colours[y].X := GetRValue(_QuadList.Colour) / 255;
            Colours[y].Y := GetGValue(_QuadList.Colour) / 255;
            Colours[y].Z := GetBValue(_QuadList.Colour) / 255;
            Colours[y].W := 0;
            Normals[y] := Tool.GetQuadNormalValue(_Vertices[_QuadList.V1],_Vertices[_QuadList.V2],_Vertices[_QuadList.V3],_Vertices[_QuadList.V4]);
            _QuadList.GoToNextElement;
            inc(y);
            inc(x,4);
         end;
         Tool.Free;
      end;
   end;
end;

// Miscellaneous
procedure TMeshBRepGeometry.RebuildNormals(_Mesh : Pointer);
var
   Tool : TMeshNormalsTool;
   MyMesh: PMesh;
begin
   MyMesh := PMesh(_Mesh);
   Tool := TMeshNormalsTool.Create;
   Tool.RebuildFaceNormals(Normals,VerticesPerFace,MyMesh^.Vertices,Faces);
   Tool.Free;
end;

procedure TMeshBRepGeometry.RemoveInvisibleFaces(_Mesh : Pointer);
var
   iRead,iWrite,v: integer;
   MarkForRemoval: boolean;
   Normal : TVector3f;
   Tool: TMeshNormalsTool;
   MyMesh: PMesh;
begin
   MyMesh := PMesh(_Mesh);
   iRead := 0;
   iWrite := 0;
   Tool := TMeshNormalsTool.Create;
   while iRead <= High(Faces) do
   begin
      MarkForRemoval := false;
      // check if vertexes are NaN.
      v := 0;
      while v < VerticesPerFace do
      begin
         if IsNaN(MyMesh^.Vertices[Faces[iRead+v]].X) or IsNaN(MyMesh^.Vertices[Faces[iRead+v]].Y) or IsNaN(MyMesh^.Vertices[Faces[iRead+v]].Z) or IsInfinite(MyMesh^.Vertices[Faces[iRead+v]].X) or IsInfinite(MyMesh^.Vertices[Faces[iRead+v]].Y) or IsInfinite(MyMesh^.Vertices[Faces[iRead+v]].Z) then
         begin
            MarkForRemoval := true;
         end;
         inc(v);
      end;
      if not MarkForRemoval then
      begin
         // check if normal is 0,0,0.
         Normal := Tool.GetNormalsValue(MyMesh^.Vertices[Faces[iRead]],MyMesh^.Vertices[Faces[iRead+1]],MyMesh^.Vertices[Faces[iRead+2]]);
         if (Normal.X = 0) and (Normal.Y = 0) and (Normal.Z = 0) then
            MarkForRemoval := true;
         if VerticesPerFace = 4 then
         begin
            Normal := Tool.GetNormalsValue(MyMesh^.Vertices[Faces[iRead+2]],MyMesh^.Vertices[Faces[iRead+3]],MyMesh^.Vertices[Faces[iRead]]);
            if (Normal.X = 0) and (Normal.Y = 0) and (Normal.Z = 0) then
               MarkForRemoval := true;
          end;
      end;

      // Finally, we remove it.
      if not MarkForRemoval then
      begin
         v := 0;
         while v < VerticesPerFace do
         begin
            Faces[iWrite+v] := Faces[iRead+v];
            inc(v);
         end;
         Normals[iWrite div VerticesPerFace].X := Normals[iRead div VerticesPerFace].X;
         Normals[iWrite div VerticesPerFace].Y := Normals[iRead div VerticesPerFace].Y;
         Normals[iWrite div VerticesPerFace].Z := Normals[iRead div VerticesPerFace].Z;
         Colours[iWrite div VerticesPerFace].X := Colours[iRead div VerticesPerFace].X;
         Colours[iWrite div VerticesPerFace].Y := Colours[iRead div VerticesPerFace].Y;
         Colours[iWrite div VerticesPerFace].Z := Colours[iRead div VerticesPerFace].Z;
         Colours[iWrite div VerticesPerFace].W := Colours[iRead div VerticesPerFace].W;
         iWrite := iWrite + VerticesPerFace;
      end;
      iRead := iRead + VerticesPerFace;
   end;
   NumFaces := iWrite div VerticesPerFace;
   SetLength(Faces,iWrite);
   SetLength(Normals,NumFaces);
   SetLength(Colours,NumFaces);
   ForceRefresh;
   Tool.Free;
end;

procedure TMeshBRepGeometry.ConvertQuadsToTris(_Mesh : Pointer);
var
   OldFaces: auint32;
   OldNormals: TAVector3f;
   OldColours: TAVector4f;
   OldNumFaces,OldFaceSize : integer;
   i,j : integer;
   NeighborhoodPlugin: PMeshPluginBase;
   MyMesh: PMesh;
begin
   MyMesh := PMesh(_Mesh);
   if VerticesPerFace <> 3 then
   begin
      // Start with face conversion.
      VerticesPerFace := 3;
      FaceType := GL_TRIANGLES;
      OldNumFaces := NumFaces;
      OldFaceSize := High(Faces)+1;
      // Make a backup of the faces first.
      SetLength(OldFaces,OldFaceSize);
      for i := Low(OldFaces) to High(OldFaces) do
         OldFaces[i] := Faces[i];
      // Now we transform each quad in two tris.
      NumFaces := NumFaces * 2;
      i := 0;
      j := 0;
      while i <= High(Faces) do
      begin
         Faces[i] := OldFaces[j];
         inc(i);
         Faces[i] := OldFaces[j+1];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+3];
         inc(i);
         Faces[i] := OldFaces[j];
         inc(i);
         inc(j,4);
      end;
      SetLength(OldFaces,0);

      // Go with Colour conversion.
      if (ColoursType = C_COLOURS_PER_FACE) then
      begin
         // Make a backup of the colours first.
         SetLength(OldColours,OldNumFaces);
         for i := Low(OldColours) to High(OldColours) do
         begin
            OldColours[i].X := Colours[i].X;
            OldColours[i].Y := Colours[i].Y;
            OldColours[i].Z := Colours[i].Z;
            OldColours[i].W := Colours[i].W;
         end;
         // Duplicate the colours.
         i := 0;
         j := 0;
         while j < OldNumFaces do
         begin
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            inc(j);
         end;
         SetLength(OldColours,0);
      end;
      // Go with Normals conversion.
      if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      begin
         // Make a backup of the normals first.
         SetLength(OldNormals,OldNumFaces);
         for i := Low(OldNormals) to High(OldNormals) do
         begin
            OldNormals[i].X := Normals[i].X;
            OldNormals[i].Y := Normals[i].Y;
            OldNormals[i].Z := Normals[i].Z;
         end;
         // Duplicate the face normals.
         j := 0;
         for i := Low(OldNormals) to High(OldNormals) do
         begin
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
         end;
         SetLength(OldNormals,0);
      end;
      NeighborhoodPlugin := MyMesh^.GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin <> nil then
      begin
         TNeighborhoodDataPlugin(NeighborhoodPlugin^).UpdateQuadsToTriangles(Faces,MyMesh^.Vertices,High(MyMesh^.Vertices)+1,VerticesPerFace);
         if (ColoursType = C_COLOURS_PER_FACE) then
         begin
            TNeighborhoodDataPlugin(NeighborhoodPlugin^).UpdateQuadsToTriangleColours(Colours);
         end;
      end;
      ForceRefresh;
   end;
end;

procedure TMeshBRepGeometry.ConvertQuadsToTris();
var
   OldFaces: auint32;
   OldNormals: TAVector3f;
   OldColours: TAVector4f;
   OldNumFaces,OldFaceSize : integer;
   i,j : integer;
begin
   if VerticesPerFace <> 3 then
   begin
      // Start with face conversion.
      VerticesPerFace := 3;
      FaceType := GL_TRIANGLES;
      OldNumFaces := NumFaces;
      OldFaceSize := High(Faces)+1;
      // Make a backup of the faces first.
      SetLength(OldFaces,OldFaceSize);
      for i := Low(OldFaces) to High(OldFaces) do
         OldFaces[i] := Faces[i];
      // Now we transform each quad in two tris.
      NumFaces := NumFaces * 2;
      i := 0;
      j := 0;
      while i <= High(Faces) do
      begin
         Faces[i] := OldFaces[j];
         inc(i);
         Faces[i] := OldFaces[j+1];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+3];
         inc(i);
         Faces[i] := OldFaces[j];
         inc(i);
         inc(j,4);
      end;
      SetLength(OldFaces,0);

      // Go with Colour conversion.
      if (ColoursType = C_COLOURS_PER_FACE) then
      begin
         // Make a backup of the colours first.
         SetLength(OldColours,OldNumFaces);
         for i := Low(OldColours) to High(OldColours) do
         begin
            OldColours[i].X := Colours[i].X;
            OldColours[i].Y := Colours[i].Y;
            OldColours[i].Z := Colours[i].Z;
            OldColours[i].W := Colours[i].W;
         end;
         // Duplicate the colours.
         i := 0;
         j := 0;
         while j < OldNumFaces do
         begin
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            inc(j);
         end;
         SetLength(OldColours,0);
      end;
      // Go with Normals conversion.
      if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      begin
         // Make a backup of the normals first.
         SetLength(OldNormals,OldNumFaces);
         for i := Low(OldNormals) to High(OldNormals) do
         begin
            OldNormals[i].X := Normals[i].X;
            OldNormals[i].Y := Normals[i].Y;
            OldNormals[i].Z := Normals[i].Z;
         end;
         // Duplicate the face normals.
         j := 0;
         for i := Low(OldNormals) to High(OldNormals) do
         begin
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
         end;
         SetLength(OldNormals,0);
      end;
   end;
end;

procedure TMeshBRepGeometry.ConvertQuadsTo48Tris(_Mesh : Pointer);
var
   OldFaces: auint32;
   OldNormals: TAVector3f;
   OldColours: TAVector4f;
   OldNumFaces,OldFaceSize,OldNumVertices : integer;
   i,j,k : integer;
   NeighborhoodPlugin: PMeshPluginBase;
   MyMesh: PMesh;
begin
   MyMesh := PMesh(_Mesh);
   if VerticesPerFace <> 3 then
   begin
      // Start with face conversion.
      VerticesPerFace := 3;
      FaceType := GL_TRIANGLES;
      OldNumFaces := NumFaces;
      OldFaceSize := High(Faces)+1;
      // Make a backup of the faces first.
      SetLength(OldFaces,OldFaceSize);
      for i := Low(OldFaces) to High(OldFaces) do
         OldFaces[i] := Faces[i];
      // Now we expand the amount of vertexes from the mesh.
      OldNumVertices := High(MyMesh^.Vertices)+1;
      SetLength(MyMesh^.Vertices,OldNumVertices+OldNumFaces);

      // Now we transform each quad in four tris.
      NumFaces := NumFaces * 4;
      i := 0;
      j := 0;
      k := OldNumVertices;
      while i <= High(Faces) do
      begin
         // Calculate the position of the new vertex of this face.
         MyMesh^.Vertices[k].X := (MyMesh^.Vertices[OldFaces[j]].X + MyMesh^.Vertices[OldFaces[j+1]].X + MyMesh^.Vertices[OldFaces[j+2]].X + MyMesh^.Vertices[OldFaces[j+3]].X) / 4;
         MyMesh^.Vertices[k].Y := (MyMesh^.Vertices[OldFaces[j]].Y + MyMesh^.Vertices[OldFaces[j+1]].Y + MyMesh^.Vertices[OldFaces[j+2]].Y + MyMesh^.Vertices[OldFaces[j+3]].Y) / 4;
         MyMesh^.Vertices[k].Z := (MyMesh^.Vertices[OldFaces[j]].Z + MyMesh^.Vertices[OldFaces[j+1]].Z + MyMesh^.Vertices[OldFaces[j+2]].Z + MyMesh^.Vertices[OldFaces[j+3]].Z) / 4;
         // Generate new faces.
         // Face 1 (Left)
         Faces[i] := OldFaces[j];
         inc(i);
         Faces[i] := OldFaces[j+1];
         inc(i);
         Faces[i] := k;
         inc(i);
         // Face 2 (Bottom)
         Faces[i] := OldFaces[j+1];
         inc(i);
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := k;
         inc(i);
         // Face 3 (Right)
         Faces[i] := OldFaces[j+2];
         inc(i);
         Faces[i] := OldFaces[j+3];
         inc(i);
         Faces[i] := k;
         inc(i);
         // Face 4 (Top)
         Faces[i] := OldFaces[j+3];
         inc(i);
         Faces[i] := OldFaces[j];
         inc(i);
         Faces[i] := k;
         inc(i);
         // Move to next old face and the new vertex of the next old face.
         inc(j,4);
         inc(k);
      end;
      SetLength(OldFaces,0);

      // Go with Colour conversion.
      if (ColoursType = C_COLOURS_PER_FACE) then
      begin
         // Make a backup of the colours first.
         SetLength(OldColours,OldNumFaces);
         for i := Low(OldColours) to High(OldColours) do
         begin
            OldColours[i].X := Colours[i].X;
            OldColours[i].Y := Colours[i].Y;
            OldColours[i].Z := Colours[i].Z;
            OldColours[i].W := Colours[i].W;
         end;
         // Quadruplicate the colours.
         i := 0;
         j := 0;
         while j < OldNumFaces do
         begin
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            Colours[i].X := OldColours[j].X;
            Colours[i].Y := OldColours[j].Y;
            Colours[i].Z := OldColours[j].Z;
            Colours[i].W := OldColours[j].W;
            inc(i);
            inc(j);
         end;
         SetLength(OldColours,0);
      end;
      // Go with Normals conversion.
      if (NormalsType and C_NORMALS_PER_FACE) <> 0 then
      begin
         // Make a backup of the normals first.
         SetLength(OldNormals,OldNumFaces);
         for i := Low(OldNormals) to High(OldNormals) do
         begin
            OldNormals[i].X := Normals[i].X;
            OldNormals[i].Y := Normals[i].Y;
            OldNormals[i].Z := Normals[i].Z;
         end;
         // Quadruplicate the face normals.
         j := 0;
         for i := Low(OldNormals) to High(OldNormals) do
         begin
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
            Normals[j].X := OldNormals[i].X;
            Normals[j].Y := OldNormals[i].Y;
            Normals[j].Z := OldNormals[i].Z;
            inc(j);
         end;
         SetLength(OldNormals,0);
      end;
      NeighborhoodPlugin := MyMesh^.GetPlugin(C_MPL_NEIGHBOOR);
      if NeighborhoodPlugin <> nil then
      begin
         TNeighborhoodDataPlugin(NeighborhoodPlugin^).UpdateQuadsTo48Triangles(Faces,MyMesh^.Vertices,High(MyMesh^.Vertices)+1,VerticesPerFace);
      end;
      ForceRefresh;
   end;
end;


// Workaround for Mesh Optimization.
procedure TMeshBRepGeometry.UpdateNumFaces;
begin
   FNumFaces := High(Faces)+1;
end;

end.
