unit MeshProcessingBase;

interface

uses BasicMathsTypes, BasicDataTypes, LOD, Mesh;

type
   TMeshProcessingBase = class
      protected
         FLOD: TLOD;
         procedure DoMeshProcessing(var _Mesh: TMesh); virtual; abstract;
         procedure BackupVector2f(const _Source: TAVector2f; var _Destination: TAVector2f);
         procedure BackupVector3f(const _Source: TAVector3f; var _Destination: TAVector3f);
         procedure BackupVector4f(const _Source: TAVector4f; var _Destination: TAVector4f);
         function GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
         function FindMeshCenter(var _Vertices: TAVector3f): TVector3f;
         procedure FilterAndFixColours(var _Colours: TAVector4f);
      public
         constructor Create(var _LOD: TLOD); virtual;
         procedure Execute;
   end;


implementation

uses Math;

constructor TMeshProcessingBase.Create(var _LOD: TLOD);
begin
   FLOD := _LOD;
end;

procedure TMeshProcessingBase.Execute;
var
   i: integer;
begin
   for i := Low(FLOD.Mesh) to High(FLOD.Mesh) do
   begin
      DoMeshProcessing(FLOD.Mesh[i]);
   end;
end;

function TMeshProcessingBase.GetEquivalentVertex(_VertexID,_MaxVertexID: integer; const _VertexEquivalences: auint32): integer;
begin
   Result := _VertexID;
   while Result > _MaxVertexID do
   begin
      Result := _VertexEquivalences[Result];
   end;
end;

procedure TMeshProcessingBase.BackupVector2f(const _Source: TAVector2f; var _Destination: TAVector2f);
var
   i : integer;
begin
   for i := Low(_Source) to High(_Source) do
   begin
      _Destination[i].U := _Source[i].U;
      _Destination[i].V := _Source[i].V;
   end;
end;

procedure TMeshProcessingBase.BackupVector3f(const _Source: TAVector3f; var _Destination: TAVector3f);
var
   i : integer;
begin
   for i := Low(_Source) to High(_Source) do
   begin
      _Destination[i].X := _Source[i].X;
      _Destination[i].Y := _Source[i].Y;
      _Destination[i].Z := _Source[i].Z;
   end;
end;

function TMeshProcessingBase.FindMeshCenter(var _Vertices: TAVector3f): TVector3f;
var
   v : integer;
   MaxPoint,MinPoint: TVector3f;
begin
   if High(_Vertices) >= 0 then
   begin
      MinPoint.X := _Vertices[0].X;
      MinPoint.Y := _Vertices[0].Y;
      MinPoint.Z := _Vertices[0].Z;
      MaxPoint.X := _Vertices[0].X;
      MaxPoint.Y := _Vertices[0].Y;
      MaxPoint.Z := _Vertices[0].Z;
      // Find mesh scope.
      for v := 1 to High(_Vertices) do
      begin
         if (_Vertices[v].X < MinPoint.X) and (_Vertices[v].X <> -NAN) then
         begin
            MinPoint.X := _Vertices[v].X;
         end;
         if _Vertices[v].X > MaxPoint.X then
         begin
            MaxPoint.X := _Vertices[v].X;
         end;
         if (_Vertices[v].Y < MinPoint.Y) and (_Vertices[v].Y <> -NAN) then
         begin
            MinPoint.Y := _Vertices[v].Y;
         end;
         if _Vertices[v].Y > MaxPoint.Y then
         begin
            MaxPoint.Y := _Vertices[v].Y;
         end;
         if (_Vertices[v].Z < MinPoint.Z) and (_Vertices[v].Z <> -NAN) then
         begin
            MinPoint.Z := _Vertices[v].Z;
         end;
         if _Vertices[v].Z > MaxPoint.Z then
         begin
            MaxPoint.Z := _Vertices[v].Z;
         end;
      end;
      Result.X := (MinPoint.X + MaxPoint.X) / 2;
      Result.Y := (MinPoint.Y + MaxPoint.Y) / 2;
      Result.Z := (MinPoint.Z + MaxPoint.Z) / 2;
   end
   else
   begin
      Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
   end;
end;

procedure TMeshProcessingBase.FilterAndFixColours(var _Colours: TAVector4f);
var
   i : integer;
begin
   for i := Low(_Colours) to High(_Colours) do
   begin
      // Avoid problematic colours:
      if _Colours[i].X < 0 then
         _Colours[i].X := 0
      else if _Colours[i].X > 1 then
         _Colours[i].X := 1;
      if _Colours[i].Y < 0 then
         _Colours[i].Y := 0
      else if _Colours[i].Y > 1 then
         _Colours[i].Y := 1;
      if _Colours[i].Z < 0 then
         _Colours[i].Z := 0
      else if _Colours[i].Z > 1 then
         _Colours[i].Z := 1;
      if _Colours[i].W < 0 then
         _Colours[i].W := 0
      else if _Colours[i].W > 1 then
         _Colours[i].W := 1;
   end;
end;

procedure TMeshProcessingBase.BackupVector4f(const _Source: TAVector4f; var _Destination: TAVector4f);
var
   i : integer;
begin
   for i := Low(_Source) to High(_Source) do
   begin
      _Destination[i].X := _Source[i].X;
      _Destination[i].Y := _Source[i].Y;
      _Destination[i].Z := _Source[i].Z;
      _Destination[i].W := _Source[i].W;
   end;
end;

end.
