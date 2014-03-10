unit PLYFile;

interface

uses BasicMathsTypes, BasicDataTypes;

type
   CPLYFile = class
      public
         procedure SaveToFile(const _Filename: string; const _Vertices: TAVector3f; const _Normals: TAVector3f; const _Faces: auint32; _VerticesPerFace: byte);
   end;

implementation

uses SysUtils;

procedure CPLYFile.SaveToFile(const _Filename: string; const _Vertices: TAVector3f; const _Normals: TAVector3f; const _Faces: auint32; _VerticesPerFace: byte);
var
   PLYFile: System.Text;
   i,j,f : integer;
   MaxFace,MaxVerticePerFace : longword;
   MinX,MinY,MinZ,MaxX,MaxY,MaxZ,SizeX,SizeY,SizeZ: single;
begin
   DecimalSeparator := '.';
   AssignFile(PLYFIle,_Filename);
   Rewrite(PLYFile);
   Writeln(PLYFile,'ply');
   Writeln(PLYFile,'format ascii 1.0');
   Writeln(PLYFile,'element vertex ' + IntToStr(High(_Vertices)+1));
   Writeln(PLYFile,'property float32 x');
   Writeln(PLYFile,'property float32 y');
   Writeln(PLYFile,'property float32 z');
   Writeln(PLYFile,'property float32 nx');
   Writeln(PLYFile,'property float32 ny');
   Writeln(PLYFile,'property float32 nz');
   MaxFace := ((High(_Faces)+1) div _VerticesPerFace) - 1;
   Writeln(PLYFile,'element face ' + IntToStr(MaxFace + 1));
   Writeln(PLYFile,'property list uint8 int32 vertex_indices');
   Writeln(PLYFile,'end_header');
   MinX := 99999;
   MinY := 99999;
   MinZ := 99999;
   MaxX := -99999;
   MaxY := -99999;
   MaxZ := -99999;
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      if _Vertices[i].X < MinX then
      begin
         MinX := _Vertices[i].X;
      end;
      if _Vertices[i].X > MaxX then
      begin
         MaxX := _Vertices[i].X;
      end;
      if _Vertices[i].Y < MinY then
      begin
         MinY := _Vertices[i].Y;
      end;
      if _Vertices[i].Y > MaxY then
      begin
         MaxY := _Vertices[i].Y;
      end;
      if _Vertices[i].Z < MinZ then
      begin
         MinZ := _Vertices[i].Z;
      end;
      if _Vertices[i].Z > MaxZ then
      begin
         MaxZ := _Vertices[i].Z;
      end;
   end;
   SizeX := (MaxX - MinX) / 2;
   SizeY := (MaxY - MinY) / 2;
   SizeZ := (MaxZ - MinZ) / 2;
   for i := Low(_Vertices) to High(_Vertices) do
   begin
      WriteLn(PLYFile,'    ' + FloatToStr((((_Vertices[i].X - MinX) / SizeX) - 1) * 0.9) + '    ' + FloatToStr((((_Vertices[i].Z - MinZ) / SizeZ) - 1) * 0.9) + '    ' + FloatToStr((((_Vertices[i].Y - MinY) / SizeY) - 1) * 0.9) + '    ' + FloatToStr(_Normals[i].X) + '    ' + FloatToStr(_Normals[i].Z) + '    ' + FloatToStr(_Normals[i].Y));
//      WriteLn(PLYFile,'    ' + FloatToStr(_Vertices[i].X) + '    ' + FloatToStr(_Vertices[i].Y) + '    ' + FloatToStr(_Vertices[i].Z) + '    ' + FloatToStr(_Normals[i].X) + '    ' + FloatToStr(_Normals[i].Y) + '    ' + FloatToStr(_Normals[i].Z));
   end;
   MaxVerticePerFace :=  _VerticesPerface - 1;
   f := 0;
   for i := 0 to MaxFace do
   begin
      Write(PLYFile,IntToStr(_VerticesPerFace));
      for j := 0 to MaxVerticePerFace do
      begin
         Write(PLYFile,' ' + IntToStr(_Faces[f]));
         inc(f);
      end;
      WriteLn(PLYFile);
   end;
   CloseFile(PLYFIle);
end;

end.
