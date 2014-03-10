unit FormVoxelTexture;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,voxel, ExtDlgs,math, ComCtrls, BasicDataTypes,
  Voxel_Engine, Palette, VoxelUndoEngine;

type
  TFrmVoxelTexture = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    BtGetVoxelTexture: TButton;
    BtApplyTexture: TButton;
    BtLoadTexture: TButton;
    BtSaveTexture: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    BtSavePalette: TButton;
    Image2: TImage;
    CbPaintRemaining: TCheckBox;
    Bevel2: TBevel;
    Panel2: TPanel;
    Image3: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Bevel3: TBevel;
    Panel3: TPanel;
    BtOK: TButton;
    BtCancel: TButton;
    ProgressBar: TProgressBar;
    LbCurrentOperation: TLabel;
    procedure BtGetVoxelTextureClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtLoadTextureClick(Sender: TObject);
    procedure BtSaveTextureClick(Sender: TObject);
    procedure BtSavePaletteClick(Sender: TObject);
    procedure BtApplyTextureClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  FrmVoxelTexture: TFrmVoxelTexture;

implementation

uses FormMain, GlobalVars, BasicVXLSETypes;

{$R *.dfm}

procedure TFrmVoxelTexture.BtGetVoxelTextureClick(Sender: TObject);
var
   x,y,z,zmax,xmax,ymax,lastheight : integer;
   v : tvoxelunpacked;
begin
   xmax := FrmMain.Document.ActiveSection^.Tailer.XSize-1;
   ymax := FrmMain.Document.ActiveSection^.Tailer.YSize-1;
   zmax := FrmMain.Document.ActiveSection^.Tailer.ZSize-1;

   Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);
   Image1.Picture.Bitmap.Width := 0;
   Image1.Picture.Bitmap.Height := 0;

   Image1.Picture.Bitmap.Width := FrmMain.Document.ActiveSection^.Tailer.XSize;
   Image1.Picture.Bitmap.Height := FrmMain.Document.ActiveSection^.Tailer.YSize;

   // Take back texture.
   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      begin
         z := 0;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(v.colour);
               Image1.Picture.Bitmap.Canvas.Pixels[x,y] := Image1.Picture.Bitmap.Canvas.Brush.Color;
            end;
            z := z + 1;
         until (z > zmax) or (v.Used = true);
      end;

   Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);

   lastheight := Image1.Picture.Bitmap.Height+1;
   Image1.Picture.Bitmap.Height := lastheight + FrmMain.Document.ActiveSection^.Tailer.YSize;

   // Take front texture
   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      begin
         z := zmax;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(v.colour);
               Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+y] := Image1.Picture.Bitmap.Canvas.Brush.Color;
            end;
            z := z - 1;
         until (z < 0) or (v.Used = true);
      end;

   Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);

   lastheight := Image1.Picture.Bitmap.Height+1;
   Image1.Picture.Bitmap.Height := lastheight + FrmMain.Document.ActiveSection^.Tailer.ZSize;

   // Take bottom texture.
   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         y := 0;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(v.colour);
               Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+z] := Image1.Picture.Bitmap.Canvas.Brush.Color;
            end;
            y := y + 1;
         until (y > ymax) or (v.Used = true);
      end;

   Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);

   lastheight := Image1.Picture.Bitmap.Height+1;
   Image1.Picture.Bitmap.Height := lastheight + FrmMain.Document.ActiveSection^.Tailer.ZSize;

   // Take top texture.
   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         y := ymax;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(v.colour);
               Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+z] := Image1.Picture.Bitmap.Canvas.Brush.Color;
            end;
            y := y - 1;
         until (y < 0) or (v.Used = true);
      end;

   Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);

   lastheight := Image1.Picture.Bitmap.Height+1;
   Image1.Picture.Bitmap.Height := lastheight + FrmMain.Document.ActiveSection^.Tailer.ZSize;

   // Take left side texture.
   for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         x := 0;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(v.colour);
               Image1.Picture.Bitmap.Canvas.Pixels[y,lastheight+z] := Image1.Picture.Bitmap.Canvas.Brush.Color;
            end;
            x := x + 1;
         until (x > xmax) or (v.Used = true);
      end;

   Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);

   lastheight := Image1.Picture.Bitmap.Height+1;
   Image1.Picture.Bitmap.Height := lastheight + FrmMain.Document.ActiveSection^.Tailer.ZSize;

   // Take right side texture.
   for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         x := xmax;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               Image1.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(v.colour);
               Image1.Picture.Bitmap.Canvas.Pixels[y,lastheight+z] := Image1.Picture.Bitmap.Canvas.Brush.Color;
            end;
            x := x - 1;
         until (x < 0) or (v.Used = true);
      end;
   Image1.refresh;
end;

procedure TFrmVoxelTexture.FormShow(Sender: TObject);
begin
   Image1.Picture.Bitmap.FreeImage;
   BtGetVoxelTextureClick(sender);
end;

procedure TFrmVoxelTexture.BtLoadTextureClick(Sender: TObject);
begin
   if OpenPictureDialog1.Execute then
   begin
      if FileExists(OpenPictureDialog1.FileName) then
         Image1.Picture.LoadFromFile(OpenPictureDialog1.filename);
   end;
end;

procedure TFrmVoxelTexture.BtSaveTextureClick(Sender: TObject);
begin
   if SavePictureDialog1.Execute then
      image1.Picture.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TFrmVoxelTexture.BtSavePaletteClick(Sender: TObject);
var
   x,y,c,cmax,size : integer;
begin
   if SavePictureDialog1.Execute then
   begin
      if SpectrumMode = ModeColours then
         cmax := 256
      else
         cmax := ActiveNormalsCount;
      size := 5;
      Image2.Picture.Bitmap.width := 0;
      Image2.Picture.Bitmap.height := 0;
      Image2.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(-1);
      Image2.Picture.Bitmap.width := 8*size;
      Image2.Picture.Bitmap.height := 32*size;
      c := 0;
      for x := 0 to 7 do
         for y := 0 to 31 do
         begin
            if c < cmax then
            begin
               Image2.Picture.Bitmap.Canvas.Brush.Color := GetVXLPaletteColor(c);
               Image2.Picture.Bitmap.Canvas.FillRect(rect(x*size,y*size,x*size+size,y*size+size));
            end;
            c := c +1;
         end;

      Image2.Picture.SaveToFile(SavePictureDialog1.FileName);
   end;
end;

procedure TFrmVoxelTexture.BtApplyTextureClick(Sender: TObject);
var
   x,y,z,zmax,xmax,ymax,lastheight,col,pp : integer;
   v : tvoxelunpacked;
begin
   // This is one of the worst documented functions ever, if not the worst
   // in the history of this program.
   // Apparently, this is what texturizes the voxel.

   //zmax := ActiveSection.Tailer.ZSize-1;
   ProgressBar.Visible := true;

   if CbPaintRemaining.Checked then
   begin
      LbCurrentOperation.Visible := true;
      LbCurrentOperation.Caption := 'Applying Texture To Bottom And Top Sides';
      LbCurrentOperation.Refresh;
      lastheight := 2*(FrmMain.Document.ActiveSection^.Tailer.YSize+1);

      ProgressBar.Position := 0;
      ProgressBar.Max := FrmMain.Document.ActiveSection^.Tailer.XSize *2;

      for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      begin
         ProgressBar.Position := x;
         for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
            for y := 0 to ((FrmMain.Document.ActiveSection^.Tailer.YSize-1) div 2) do
            begin
               FrmMain.Document.ActiveSection^.GetVoxel(x,((FrmMain.Document.ActiveSection^.Tailer.YSize-1) div 2)-y,z,v);
               if v.Used then
               begin
                  col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+z]);
                  if col <> GetVXLPaletteColor(-1) then
                     if SpectrumMode = ModeColours then
                        v.Colour := col
                     else
                        v.Normal := col;
                  FrmMain.Document.ActiveSection^.SetVoxel(x,((FrmMain.Document.ActiveSection^.Tailer.YSize-1) div 2)-y,z,v);
               end;
            end;
      end;

      lastheight := lastheight + FrmMain.Document.ActiveSection^.Tailer.YSize+1;

      for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      begin
         ProgressBar.Position := FrmMain.Document.ActiveSection^.Tailer.XSize+x;
         for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
            for y := 0 to ((FrmMain.Document.ActiveSection^.Tailer.YSize-1) div 2) do
            begin
               FrmMain.Document.ActiveSection^.GetVoxel(x,((FrmMain.Document.ActiveSection^.Tailer.YSize-1) div 2)+y,z,v);
               if v.Used then
               begin
                  col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+z]);
                  if col <> GetVXLPaletteColor(-1) then
                     if SpectrumMode = ModeColours then
                        v.Colour := col
                     else
                        v.Normal := col;
                  FrmMain.Document.ActiveSection^.SetVoxel(x,((FrmMain.Document.ActiveSection^.Tailer.YSize-1) div 2)+y,z,v);
               end;
            end;
      end;
   end;

   xmax := FrmMain.Document.ActiveSection^.Tailer.XSize-1;
   ymax := FrmMain.Document.ActiveSection^.Tailer.YSize-1;
   zmax := FrmMain.Document.ActiveSection^.Tailer.ZSize-1;
   ProgressBar.Max := (xmax*4)+ (ymax*2);

   pp := ProgressBar.Position;
   LbCurrentOperation.Caption := 'Applying Texture To Back And Front Sides';
   LbCurrentOperation.Refresh;

   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      begin
         z := 0;
         ProgressBar.Position := x + pp;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[x,y]);
               if col <> GetVXLPaletteColor(-1) then
                  if SpectrumMode = ModeColours then
                     v.Colour := col
                  else
                     v.Normal := col;

               FrmMain.Document.ActiveSection^.SetVoxel(x,y,z,v);
            end;
            z := z + 1;
         until (z > zmax) or (v.Used = true);
      end;

   lastheight := FrmMain.Document.ActiveSection^.Tailer.YSize+1;
   pp := ProgressBar.Position;

   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      begin
         z := zmax;
         ProgressBar.Position := x + pp;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+y]);
               if col <> GetVXLPaletteColor(-1) then
                  if SpectrumMode = ModeColours then
                     v.Colour := col
                  else
                     v.Normal := col;
               FrmMain.Document.ActiveSection^.SetVoxel(x,y,z,v);
            end;
            z := z - 1;
         until (z < 0) or (v.Used = true);
      end;

   LbCurrentOperation.Caption := 'Applying Texture To Bottom And Top Sides';
   LbCurrentOperation.Refresh;

   // Here we start at the 3rd part of the whole picture.
   lastheight := lastheight +FrmMain.Document.ActiveSection^.Tailer.YSize+1;

   pp := ProgressBar.Position;
   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         y := 0;
         ProgressBar.Position := x +pp;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+z]);
               if col <> GetVXLPaletteColor(-1) then
                  if SpectrumMode = ModeColours then
                     v.Colour := col
                  else
                     v.Normal := col;
               FrmMain.Document.ActiveSection^.SetVoxel(x,y,z,v);
            end;
            y := y + 1;
         until (y > ymax) or (v.Used = true);
      end;

   lastheight := lastheight +FrmMain.Document.ActiveSection^.Tailer.ZSize+1;
   pp := ProgressBar.Position;

   // Take top texture.
   for x := 0 to FrmMain.Document.ActiveSection^.Tailer.XSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         y := ymax;
         ProgressBar.Position := x + pp;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[x,lastheight+z]);
               if col <> GetVXLPaletteColor(-1) then
                  if SpectrumMode = ModeColours then
                     v.Colour := col
                  else
                     v.Normal := col;
               FrmMain.Document.ActiveSection^.SetVoxel(x,y,z,v);
            end;
            y := y - 1;
         until (y < 0) or (v.Used = true);
      end;

   lastheight := lastheight +FrmMain.Document.ActiveSection^.Tailer.ZSize+1;
   pp := ProgressBar.Position;

   LbCurrentOperation.Caption := 'Applying Texture To Left And Right Sides';
   LbCurrentOperation.Refresh;

   for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         x := 0;
         ProgressBar.Position := y + pp;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[y,lastheight+z]);
               if col <> GetVXLPaletteColor(-1) then
                  if SpectrumMode = ModeColours then
                     v.Colour := col
                  else
                     v.Normal := col;
               FrmMain.Document.ActiveSection^.SetVoxel(x,y,z,v);
            end;
            x := x + 1;
         until (x > xmax) or (v.Used = true);
      end;

   lastheight := lastheight +FrmMain.Document.ActiveSection^.Tailer.ZSize+1;
   pp := ProgressBar.Position;

   for y := 0 to FrmMain.Document.ActiveSection^.Tailer.YSize-1 do
      for z := 0 to FrmMain.Document.ActiveSection^.Tailer.ZSize-1 do
      begin
         x := xmax;
         ProgressBar.Position := y + pp;
         repeat
            FrmMain.Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               col := FrmMain.Document.Palette^.GetColourFromPalette(Image1.Picture.Bitmap.Canvas.Pixels[y,lastheight+z]);
               if col <> GetVXLPaletteColor(-1) then
                  if SpectrumMode = ModeColours then
                     v.Colour := col
                  else
                     v.Normal := col;

               FrmMain.Document.ActiveSection^.SetVoxel(x,y,z,v);
            end;
            x := x - 1;
         until (x < 0) or (v.Used = true);
      end;

   ProgressBar.Visible := false;
   LbCurrentOperation.Visible := false;

   FrmMain.RefreshAll;
end;

procedure TFrmVoxelTexture.BtOKClick(Sender: TObject);
begin
   CreateVXLRestorePoint(FrmMain.Document.ActiveSection^,Undo);
   BtApplyTextureClick(sender);
   FrmMain.UpdateUndo_RedoState;
   //FrmMain.RefreshAll;
   VXLChanged := true;
   Close;
end;

procedure TFrmVoxelTexture.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmVoxelTexture.FormCreate(Sender: TObject);
begin
   Panel2.DoubleBuffered := true;
end;

end.
