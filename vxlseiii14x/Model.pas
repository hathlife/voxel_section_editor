unit Model;

interface

uses Palette, HVA, Voxel, Mesh, BasicFunctions, BasicDataTypes, dglOpenGL;

type
   PModel = ^TModel;
   TModel = class
   public
      Next : PModel;
      Palette : PPalette;
      IsVisible : boolean;
      // Skeleton:
      HVA : PHVA;
      Mesh : array of TMesh;
      // Source
      Filename : string;
      Voxel : PVoxel;
      // constructors and destructors
      constructor Create(const _Filename: string); overload;
      constructor Create(const _Voxel: PVoxel; const _Palette : PPalette; _HighQuality : boolean); overload;
      destructor Destroy; override;
      procedure Initialize(_HighQuality: boolean = false);
      procedure Clear;
      procedure Reset;
      // Rendering methods
      procedure Render(var _PolyCount: longword);
   end;

implementation

constructor TModel.Create(const _Filename: string);
begin
   Filename := CopyString(_Filename);
   Voxel := nil;
   Next := nil;
   Reset;
end;

constructor TModel.Create(const _Voxel: PVoxel; const _Palette: PPalette; _HighQuality : boolean);
begin
   Filename := '';
   Voxel := _Voxel;
   Palette := _Palette;
   Next := nil;
   Reset;
end;

destructor TModel.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TModel.Reset;
begin
   Clear;
   Initialize;
end;

procedure TModel.Clear;
var
   i : integer;
begin
   i := High(Mesh);
   while i >= 0 do
   begin
      Mesh[i].Free;
      dec(i);
   end;
   SetLength(Mesh,0);
   HVA := nil;
   Palette := nil;
end;

procedure TModel.Initialize(_HighQuality: boolean = false);
var
   i : integer;
begin
   // Check if we have a random file or a voxel.
   if Voxel = nil then
   begin
      // We have a file to open.


   end
   else
   begin
      // We may use an existing voxel.
      SetLength(Mesh,Voxel^.Header.NumSections);
      for i := 0 to (Voxel^.Header.NumSections-1) do
      begin
         Mesh[i] := TMesh.CreateFromVoxel(i,Voxel^.Section[i],Palette^,_HighQuality);
      end;
   end;
end;

// Rendering methods
procedure TModel.Render(var _Polycount: longword);
var
   i : integer;
begin
   if IsVisible and (HVA <> nil) then
   begin
      for i := Low(Mesh) to High(Mesh) do
      begin
         glPushMatrix();
            HVA^.ApplyMatrix(Mesh[i].Scale,i);
            Mesh[i].Render(_PolyCount);
         glPopMatrix();
      end;
   end;
end;

end.
