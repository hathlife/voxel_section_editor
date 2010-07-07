unit ClassVoxelView;

interface

uses BasicDataTypes, BasicFunctions, Voxel, BasicConstants;

type
   T2DVoxelView = class
   private
      Orient: EVoxelViewOrient;
      Dir: EVoxelViewDir;
      swapX, swapY, swapZ: boolean; // are these inversed for viewing?
      // Constructors and Destructors
      procedure CreateCanvas;
      procedure Clear;
      procedure CalcSwapXYZ;
   public
      Foreground, // the Depth in Canvas[] that is the active slice
      Width, Height: Integer;
      Canvas: {packed} array of {packed} array of TVoxelViewCell;
      Voxel: TVoxelSection; // owner
      // Constructors and Destructors
      constructor Create(Owner: TVoxelSection; o: EVoxelViewOrient; d: EVoxelViewDir);
      destructor Destroy; override;
      procedure Reset;
      // Gets
      function getViewNameIdx: Integer;
      function getDir: EVoxelViewDir;
      function getOrient: EVoxelViewOrient;
      procedure TranslateClick(i, j: Integer; var X, Y, Z: Integer);
      procedure getPhysicalCursorCoords(var X, Y: integer);
      // Sets
      procedure setDir(newdir: EVoxelViewDir);
      procedure setVoxelSection(const _Section: TVoxelSection);
      // Render
      procedure Refresh; // like a paint on the canvas
      // Copies
      procedure Assign(const _VoxelView : T2DVoxelView);
   end;


implementation

// Constructors and Destructors
constructor T2DVoxelView.Create(Owner: TVoxelSection; o: EVoxelViewOrient; d: EVoxelViewDir);
begin
   Voxel := Owner;
   Orient := o;
   Dir := d;
   Reset;
end;

destructor T2DVoxelView.Destroy;
var
   x : integer;
begin
   for x := Low(Canvas) to high(Canvas) do
   begin
      SetLength(Canvas[x],0);
   end;
   SetLength(Canvas,0);
   finalize(Canvas);
   inherited Destroy;
end;

procedure T2DVoxelView.Reset;
begin
   Clear;
   CreateCanvas;
   CalcSwapXYZ;
   Refresh;
end;

procedure T2DVoxelView.CreateCanvas;
var
   x: Integer;
begin
   with Voxel.Tailer do
   begin
      case Orient of
         oriX:
         begin
            Width := ZSize;
            Height := YSize;
         end;
         oriY:
         begin
            Width := ZSize;
            Height := XSize;
         end;
         oriZ:
         begin
            Width := XSize;
            Height := YSize;
         end;
      end;
   end;
   SetLength(Canvas,Width);
   for x := 0 to (Width - 1) do
      SetLength(Canvas[x],Height);
   //CalcIncs;
end;

procedure T2DVoxelView.Clear;
var
   x, y: Integer;
begin
   for x := Low(Canvas) to High(Canvas) do
      for y := Low(Canvas[x]) to High(Canvas[x]) do
         with Canvas[x,y] do
         begin
            Colour := VTRANSPARENT;
            Depth := 0; // far away
         end;
end;

procedure T2DVoxelView.CalcSwapXYZ;
var idx: integer;
begin
   idx := getViewNameIdx;
   case idx of
      0:
      begin // Right to Left
         SwapX := False;
         SwapY := True;
         SwapZ := False;
      end;
      1:
      begin // Left to Right
         SwapX := False;
         SwapY := True;
         SwapZ := True;
      end;
      2:
      begin // Top to Bottom
         SwapX := True;
         SwapY := True;
         SwapZ := False;
      end;
      3:
      begin // Bottom to Top
         SwapX := True;
         SwapY := True;
         SwapZ := True;
      end;
      4:
      begin // Back to Front
         SwapX := True;
         SwapY := True;
         SwapZ := False;
      end;
      5:
      begin // Front to Back
         SwapX := False;
         SwapY := True;
         SwapZ := False;
      end;
   end;
end;

// Gets
function T2DVoxelView.getViewNameIdx: Integer;
begin
   Result := 0;
   case Orient of
      oriX: Result := 0;
      oriY: Result := 2;
      oriZ: Result := 4;
   end;
   if Dir = dirAway then
      Inc(Result);
end;

procedure T2DVoxelView.TranslateClick(i, j: Integer; var X, Y, Z: Integer);

   procedure TranslateX;
   begin
      X := Foreground;
      if SwapZ then
         Z := Width - 1 - i
      else
         Z := i;
      if SwapY then
         Y := Height - 1 - j
      else
         Y := j;
   end;
   procedure TranslateY;
   begin
      if SwapZ then
         Z := Width - 1 - i
      else
         Z := i;
      Y := Foreground;
      if SwapX then
         X := Height - 1 - j
      else
         X := j;
   end;

   procedure TranslateZ;
   begin
      if SwapX then
         X := Width - 1 - i
      else
         X := i;
      if SwapY then
         Y := Height - 1 - j
      else
         Y := j;
      Z := Foreground;
  end;

begin
   case Orient of
      oriX: TranslateX;
      oriY: TranslateY;
      oriZ: TranslateZ;
   end;
end;

procedure T2DVoxelView.getPhysicalCursorCoords(var X, Y: integer);
   procedure TranslateX;
   begin
      if SwapZ then
         X := Width - 1 - Voxel.Z
      else
         X := Voxel.Z;
      if SwapY then
         Y := Height - 1 - Voxel.Y
      else
         Y := Voxel.Y;
   end;
   procedure TranslateY;
   begin
      if SwapZ then
         X := Width - 1 - Voxel.Z
      else
         X := Voxel.Z;
      if SwapX then
         Y := Height - 1 - Voxel.X
      else
         Y := Voxel.X;
   end;
   procedure TranslateZ;
   begin
      if SwapX then
         X := Width - 1 - Voxel.X
      else
         X := Voxel.X;
      if SwapY then
         Y := Height - 1 - Voxel.Y
      else
         Y := Voxel.Y;
   end;
begin
   case Orient of
      oriX: TranslateX;
      oriY: TranslateY;
      oriZ: TranslateZ;
   end;
end;

function T2DVoxelView.getDir: EVoxelViewDir;
begin
   Result := Dir;
end;

function T2DVoxelView.getOrient: EVoxelViewOrient;
begin
   Result := Orient;
end;

// Sets
procedure T2DVoxelView.setDir(newdir: EVoxelViewDir);
begin
   Dir := newdir;
   CalcSwapXYZ;
   Refresh;
end;

procedure T2DVoxelView.setVoxelSection(const _Section: TVoxelSection);
begin
   Voxel := _Section;
   Reset;
end;

// Render
procedure T2DVoxelView.Refresh;
   procedure DrawX;
   var
      x, y, z, // coords in model
      i, j: Integer; // screen coords
      v: TVoxelUnpacked;
      iFactor, iOp, jFactor, jOp: integer;
   begin
      Foreground := Voxel.X;
      if SwapZ then
      begin
         iFactor := Width - 1;
         iOp := -1;
      end
      else
      begin
         iFactor := 0;
         iOp := 1;
      end;
      if SwapY then
      begin
         jFactor := Height - 1;
         jOp := -1;
      end
      else
      begin
         jFactor := 0;
         jOp := 1;
      end;
      // increment on the x axis
      if Dir = dirTowards then
      begin
         for z := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               x := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Inc(x);
                  if x >= Voxel.Tailer.XSize then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := x;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end
      else
      begin // Dir = dirAway
         for z := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               x := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Dec(x);
                  if x < 0 then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := x;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end;
   end;
   procedure DrawY;
   var
      x, y, z, // coords in model
      i, j: Integer; // screen coords
      v: TVoxelUnpacked;
      iFactor, iOp, jFactor, jOp: integer;
   begin
      Foreground := Voxel.Y;
      if SwapZ then
      begin
         iFactor := Width - 1;
         iOp := -1;
      end
      else
      begin
         iFactor := 0;
         iOp := 1;
      end;
      if SwapX then
      begin
         jFactor := Height - 1;
         jOp := -1;
      end
      else
      begin
         jFactor := 0;
         jOp := 1;
      end;
      if Dir = dirTowards then
      begin
         for z := 0 to (Width - 1) do
            for x := 0 to (Height - 1) do
            begin
               y := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Inc(y);
                  if y >= Voxel.Tailer.YSize then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * x);
               with Canvas[i,j] do
               begin
                  Depth := y;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end
      else
      begin // Dir = dirAway
         for z := 0 to (Width - 1) do
            for x := 0 to (Height - 1) do
            begin
               y := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Dec(y);
                  if y < 0 then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * z);
               j := jFactor + (jOp * x);
               with Canvas[i,j] do
               begin
                  Depth := y;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end;
   end;
   procedure DrawZ;
   var
      x, y, z, // coords in model
      i, j: Integer; // screen coords
      v: TVoxelUnpacked;
      iFactor, iOp, jFactor, jOp: integer;
   begin
      Foreground := Voxel.Z;
      if SwapX then
      begin
         iFactor := Width -1;
         iOp := -1;
      end
      else
      begin
         iFactor := 0;
         iOp := 1;
      end;
      if SwapY then
      begin
         jFactor := Height - 1;
         jOp := -1;
      end
      else
      begin
         jFactor := 0;
         jOp := 1;
      end;

      if Dir = dirTowards then
      begin
         for x := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               z := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Inc(z);
                  if z >= Voxel.Tailer.ZSize then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * x);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := z;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
      end
      else
      begin // Dir = dirAway
         for x := 0 to (Width - 1) do
            for y := 0 to (Height - 1) do
            begin
               z := Foreground;
               Voxel.GetVoxel(x,y,z,v);
               // find voxel on the x axis
               while not v.Used do
               begin
                  Dec(z);
                  if z < 0 then // range check
                     Break; // Ok, no voxels ever to show
                  // get next
                  Voxel.GetVoxel(x,y,z,v);
               end;
               // and set the voxel appropriately
               i := iFactor + (iOp * x);
               j := jFactor + (jOp * y);
               with Canvas[i,j] do
               begin
                  Depth := z;
                  if v.Used then
                  begin
                     if voxel.spectrum = ModeNormals then
                        Colour := v.Normal
                     else
                        Colour := v.Colour;
                  end
                  else
                     Colour := VTRANSPARENT; // 256
               end;
            end;
         end;
   end;
begin
   case Orient of
      oriX: DrawX;
      oriY: DrawY;
      oriZ: DrawZ;
   end;
end;

// Copies
procedure T2DVoxelView.Assign(const _VoxelView : T2DVoxelView);
var
   i,j : integer;
begin
   Orient := _VoxelView.Orient;
   Dir := _VoxelView.Dir;
   swapX := _VoxelView.swapX;
   swapY := _VoxelView.swapY;
   swapZ := _VoxelView.swapZ;
   Foreground := _VoxelView.Foreground;
   Width := _VoxelView.Width;
   Height := _VoxelView.Height;
   Voxel := _VoxelView.Voxel;
   SetLength(Canvas,Width);
   for i := Low(Canvas) to High(Canvas) do
   begin
      SetLength(Canvas[i],Height);
      for j := Low(Canvas[i]) to High(Canvas[i]) do
      begin
         Canvas[i,j].Colour := _VoxelView.Canvas[i,j].Colour;
         Canvas[i,j].Depth := _VoxelView.Canvas[i,j].Depth;
      end;
   end;
end;

end.
