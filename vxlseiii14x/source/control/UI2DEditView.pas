unit UI2DEditView;

interface

uses BasicDataTypes, BasicVXLSETypes, BasicFunctions, VoxelView, Windows, Graphics,
   Math, BasicConstants;

type
   TUIEditView = class
      private
      public
         View: T2DVoxelView;
         Viewport: TViewport;
         Canvas: PPaintBox;
         WndIndex: Integer;
         // Constructors and Destructors

         // Sets
//         procedure TranslateClick(sx, sy: Integer; var lx, ly, lz: Integer);
//         procedure TranslateClick2(sx, sy: Integer; var lx, ly, lz: Integer);
         // Render
//         Procedure PaintView(_isMouseLeftDown, _isEditable : boolean; _BGViewColor : TColor; _ViewMode: EViewMode; var _TempLines : TTempLines);
         procedure PaintView2(_isMouseLeftDown, _isEditable : boolean; _BGViewColor : TColor; _ViewMode: EViewMode; var _TempLines : TTempLines);
   end;

implementation

uses Voxel_Engine;

procedure TUIEditView.PaintView2(_isMouseLeftDown, _isEditable : boolean; _BGViewColor : TColor; _ViewMode: EViewMode; var _TempLines : TTempLines);
var
   x,xx, y, txx,tyy: Integer;
   r: TRect;
   PalIdx : integer;
   f : boolean;
   Bitmap : TBitmap;
   lineIndex : integer;
begin
   {$ifdef DEBUG_FILE}
   FrmMain.DebugFile.Add('UI2DEditView: PaintView2');
   {$endif}
   if (not Canvas.Enabled) or (not _IsEditable) then
   begin // draw it empty then
      with Canvas.Canvas do
      begin
         r.Left := 0;
         r.Top := 0;
         r.Right := Canvas.Width;
         r.Bottom := Canvas.Height;
         Brush.Color := clBtnFace;
         FillRect(r);
      end;
      Exit; // don't do anything else then
   end;
   if View = nil then Exit;
   // fill margins around shape
   Bitmap := TBitmap.Create;
   Bitmap.Canvas.Brush.Style := bsSolid;
   Bitmap.Canvas.Brush.Color := _BGViewColor;
   Bitmap.Width := Canvas.Width;
   Bitmap.Height := Canvas.Height;
   // left side?
   if (Viewport.Left > 0) then
   begin
      with r do
      begin // left size
         Left := 0;
         Right := Viewport.Left;
         Top := 0;
         Bottom := Canvas.Height;
      end;
      with Bitmap.Canvas do
         FillRect(r);
   end;
   // right side?
   if (Viewport.Left + (Viewport.Zoom * View.Width)) < Canvas.Width then
   begin
      with r do
      begin // right side
         Left := Viewport.Left + (Viewport.Zoom * View.Width);
         Right := Canvas.Width;
         Top := 0;
         Bottom := Canvas.Height;
      end;
      with Bitmap.Canvas do
         FillRect(r);
   end;
   // top
   if (Viewport.Top > 0) then
   begin
      with r do
      begin // top
         Left := 0;
         Right := Canvas.Width;
         Top := 0;
         Bottom := Viewport.Top;
      end;
      with Bitmap.Canvas do
         FillRect(r);
   end;
   // bottom
   if (Viewport.Top + (Viewport.Zoom * View.Height)) < Canvas.Height then
   begin
      with r do
      begin // bottom
         Top := Viewport.Top + (Viewport.Zoom * View.Height);
         Bottom := Canvas.Height;
         Left := 0;
         Right := Canvas.Width;
      end;
      with Bitmap.Canvas do
         FillRect(r);
   end;
   Bitmap.Canvas.Brush.Style := bsSolid;
   // paint view
   Bitmap.Canvas.Pen.Color := clRed; //VXLPalette[Transparent];
   for x := 0 to (View.Width - 1) do
   begin
      r.Left := (x * Viewport.Zoom) + Viewport.Left;
      r.Right := r.Left + Viewport.Zoom;
      if r.Right < 0 then
         Continue; // not visible checks
      if r.Left > Canvas.Width then
         Continue; // not visible checks
      r.Top := Viewport.Top;
      r.Bottom := r.Top + Viewport.Zoom;
      for y := 0 to (View.Height - 1) do
      begin
         if (r.Bottom >= 0) and (r.Top <= Canvas.Height) then
         begin // not visible checks
            if (_ViewMode = ModeCrossSection) and (wndindex=0) then
            begin
               if View.Canvas[x,y].Depth = View.Foreground then
                  PalIdx := View.Canvas[x,y].Colour
               else
                  PalIdx := VIEWBGCOLOR;
            end
            else if View.Canvas[x,y].Colour = VTRANSPARENT then // ModeFull or ModeEmpDepth
               PalIdx := VIEWBGCOLOR
            else
               PalIdx := View.Canvas[x,y].Colour;

            with Bitmap.Canvas do
            begin
               Brush.Color := GetVXLPaletteColor(PalIdx);
               if ((_ViewMode = ModeEmphasiseDepth) and (wndindex=0) and (View.Canvas[x,y].Depth = View.Foreground)) then
               begin
                  if Viewport.Zoom = 1 then
                     Pixels[r.Left,r.Top] := Pen.Color
                  else
                     Rectangle(r.Left,r.Top,r.Right,r.Bottom)
               end
               else
                  FillRect(r);
{$IFDEF DEBUG_NORMALS}
               if (SpectrumMode = ModeNormals) then
                  if (PalIdx > -1) then
                     if Viewport.Zoom > 10 then
                     begin
                        Font.Color := VXLPalette[PalIdx] shr 2;
                        TextOut(r.Left,r.Top,IntToStr(View.Canvas[x,y].Colour));
                     end;
{$ENDIF}    end;
         end;
         Inc(r.Top,Viewport.Zoom);
         Inc(r.Bottom,Viewport.Zoom);
      end;
   end;

   if WndIndex = 0 then
      if tempview.Data_no > 0 then
      begin
         for xx := 1 to tempview.Data_no do
         begin
            if (View.getViewNameIdx = 1) or(View.getViewNameIdx = 3) or (View.getViewNameIdx = 5) then
               x := View.Width - 1-tempview.data[xx].X
            else
               x := tempview.data[xx].X;
            y :=  View.Height - 1-tempview.data[xx].Y;
            if tempview.data[xx].VU then
            begin
               if SpectrumMode = ModeColours then
                  PalIdx := tempview.data[xx].V.Colour
               else
                  PalIdx := tempview.data[xx].V.Normal;

               r.Left := (x * Viewport.Zoom) + Viewport.Left;
               r.Right := r.Left + Viewport.Zoom;
               r.Top := (y * Viewport.Zoom) + Viewport.Top;
               r.Bottom := r.Top + Viewport.Zoom;
               with Bitmap.Canvas do
               begin
                  Brush.Color := GetVXLPaletteColor(PalIdx);
                  if Viewport.Zoom = 1 then
                     Pixels[r.Left,r.Top] := Pen.Color
                  else
                     Rectangle(r.Left,r.Top,r.Right,r.Bottom);
{$IFDEF DEBUG_NORMALS}
                  if (SpectrumMode = ModeNormals) then
                     if (PalIdx > -1) then
                        if Viewport.Zoom > 10 then
                        begin
                           Font.Color := GetVXLPalette[PalIdx] shr 2;
                           TextOut(r.Left,r.Top,IntToStr(View.Canvas[x,y].Colour));
                        end;
{$ENDIF}       end;
            end;
         end;
      end;

   // draw temporary display lines (eg. measure tool)
   if (_TempLines.Data_no > 0) and (WndIndex = 0) then
      for lineIndex := 0 to _TempLines.Data_no - 1 do
      begin
         Bitmap.Canvas.MoveTo(_TempLines.Data[lineIndex].x1,_TempLines.Data[lineIndex].y1);
         Bitmap.Canvas.Pen.Width := _TempLines.Data[lineIndex].width;
         Bitmap.Canvas.Pen.Color := _TempLines.Data[lineIndex].colour;
         Bitmap.Canvas.LineTo(_TempLines.Data[lineIndex].x2,_TempLines.Data[lineIndex].y2);
      end;

   // draw cursor, but not if drawing!
   if not _isMouseLeftDown then
   begin
      View.getPhysicalCursorCoords(x,y);
      //set brush color, or else it will get the color of the bottom-right voxel
      Bitmap.Canvas.Brush.Color:= _BGViewColor;
      // vert
      r.Top := Max(Viewport.Top,0);
      r.Bottom := Min(Viewport.Top + (View.Height * Viewport.Zoom), Canvas.Height);
      r.Left := (x * Viewport.Zoom) + Viewport.Left + (Viewport.Zoom div 2) - 1;
      r.Right := r.Left + 2;
      Bitmap.Canvas.DrawFocusRect(r);
      // horiz
      r.Left := Max(Viewport.Left,0);
      r.Right := Min(Viewport.Left + (View.Width * Viewport.Zoom), Canvas.Width);
      r.Top := (y * Viewport.Zoom) + Viewport.Top + (Viewport.Zoom div 2) - 1;
      r.Bottom := r.Top + 2;
      Bitmap.Canvas.DrawFocusRect(r);
   end
   else
   begin
      View.getPhysicalCursorCoords(x,y);
      //set brush color, or else it will get the color of the bottom-right voxel
      Bitmap.Canvas.Brush.Color:= clbtnface;
      // vert
      r.Top := Max(Viewport.Top,0)-1;
      r.Bottom := Min(Viewport.Top + (View.Height * Viewport.Zoom), Canvas.Height)+1;
      r.Left := Max(Viewport.Left,0)-1;
      r.Right := Min(Viewport.Left + (View.Width * Viewport.Zoom), Canvas.Width)+1;
      Bitmap.Canvas.DrawFocusRect(r);
   end;

   Canvas.Canvas.Draw(0,0,Bitmap); // Draw to Canvas, should stop flickerings
   //Cnv.Canvas.TextOut(0,0,'hmm');
   Bitmap.Free;
end;

end.
