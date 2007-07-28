unit FormReplaceColour;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Voxel_Engine, palette, voxel, mouse, undo_engine;

Type
TRepalceColourData = record
   Col1 : byte;
   Col2 : byte;
end;

type
  TFrmReplaceColour = class(TForm)
    Bevel3: TBevel;
    Panel3: TPanel;
    Image1: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Bevel4: TBevel;
    Panel4: TPanel;
    Button6: TButton;
    Button7: TButton;
    Panel5: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    ListBox1: TListBox;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Bevel1: TBevel;
    cnvPalette: TPaintBox;
    pnlPalette: TPanel;
    lblActiveColour: TLabel;
    pnlActiveColour: TPanel;
    procedure FormDestroy(Sender: TObject);
    procedure cnvPalettePaint(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure cnvPaletteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmReplaceColour: TFrmReplaceColour;
  RepalceColourData,TempColourData : array of TRepalceColourData;
  Data_no : integer;
  Replace : integer = -1;
  ReplaceW : integer = -1;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmReplaceColour.cnvPalettePaint(Sender: TObject);
begin
PaintPalette(cnvPalette, false);
end;

procedure TFrmReplaceColour.Panel1Click(Sender: TObject);
begin
Panel1.BevelOuter := bvRaised;
Panel2.BevelOuter := bvLowered;
end;

procedure TFrmReplaceColour.Panel2Click(Sender: TObject);
begin
Panel2.BevelOuter := bvRaised;
Panel1.BevelOuter := bvLowered;
end;

procedure TFrmReplaceColour.cnvPaletteMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var colwidth, rowheight: Real;
    i, j, idx: Integer;
begin
If not isEditable then exit;
     colwidth := cnvPalette.Width / 8;
     rowheight := cnvPalette.Height / 32;
     i := Trunc(X / colwidth);
     j := Trunc(Y / rowheight);
     idx := (i * 32) + j;


     if SpectrumMode = ModeColours then
      if Panel1.BevelOuter = bvRaised then
        begin
        Replace := idx;
        Panel1.Color := VXLPalette[idx];
        Label3.Caption := inttostr(idx);
        Panel2.BevelOuter := bvRaised;
        Panel1.BevelOuter := bvLowered;
        end
        else
        begin
        ReplaceW := idx;
        Panel2.Color := VXLPalette[idx];
        Label4.Caption := inttostr(idx);
        Panel1.BevelOuter := bvRaised;
        Panel2.BevelOuter := bvLowered;
        end
     else
     if not (idx > ActiveNormalsCount-1) then
     if Panel1.BevelOuter = bvRaised then
        begin
        Replace := idx;
        Panel1.Color := GetVXLPaletteColor(idx);
        Label3.Caption := inttostr(idx);
        Panel2.BevelOuter := bvRaised;
        Panel1.BevelOuter := bvLowered;
        end
        else
        begin
        ReplaceW := idx;
        Panel2.Color := GetVXLPaletteColor(idx);
        Label4.Caption := inttostr(idx);
        Panel1.BevelOuter := bvRaised;
        Panel2.BevelOuter := bvLowered;
        end;
end;

procedure TFrmReplaceColour.FormCreate(Sender: TObject);
begin
cnvPalette.Cursor := MouseBrush;
Panel3.DoubleBuffered := true;
end;

procedure TFrmReplaceColour.Button3Click(Sender: TObject);
var
x : integer;
B : Boolean;
begin
if (Replace = -1) or (ReplaceW = -1) then
begin
Messagebox(0,'Please Select 2 Colours','Colour Error',0);
exit;
end;

B := false;

if Replace = ReplaceW then exit; // U can't replace a colour with its self... pointless

if Data_no > 0 then
for x := 0 to Data_no-1 do
if b = false then
if RepalceColourData[x].Col1 = Replace then
B := true;

if B = true then exit; // Stops pointless additions

inc(Data_no);
SetLength(RepalceColourData,Data_no);
RepalceColourData[Data_no-1].Col1 := Replace;
RepalceColourData[Data_no-1].Col2 := ReplaceW;
ListBox1.Items.Add(Inttostr(Replace) + ' -> ' + Inttostr(ReplaceW));

end;

procedure TFrmReplaceColour.ListBox1Click(Sender: TObject);
begin

if Data_no > 0 then
begin

Replace := RepalceColourData[ListBox1.ItemIndex].Col1;
ReplaceW := RepalceColourData[ListBox1.ItemIndex].Col2;

Panel1.Color := GetVXLPaletteColor(Replace);
Panel2.Color := GetVXLPaletteColor(ReplaceW);

Label3.Caption := inttostr(Replace);
Label4.Caption := inttostr(ReplaceW);
end;

end;

procedure TFrmReplaceColour.Button4Click(Sender: TObject);
begin
if Data_no > 0 then
begin

RepalceColourData[ListBox1.ItemIndex].Col1 := Replace;
RepalceColourData[ListBox1.ItemIndex].Col2 := ReplaceW;
ListBox1.Items.Strings[ListBox1.ItemIndex] := Inttostr(Replace) + ' -> ' + Inttostr(ReplaceW);
end;

end;

procedure TFrmReplaceColour.Button5Click(Sender: TObject);
var
x,c,ItemIndex : integer;
begin
if data_no < 1 then exit;

ItemIndex := ListBox1.ItemIndex;

Setlength(TempColourData,data_no);

for x := 0 to data_no-1 do
begin
TempColourData[x].Col1 := RepalceColourData[x].Col1;
TempColourData[x].Col2 := RepalceColourData[x].Col2;
end;

Dec(data_no);

Setlength(RepalceColourData,data_no);
ListBox1.Items.Clear;

if data_no < 1 then
begin
Setlength(TempColourData,0);
exit;
end;

C := 0;
X := 0;
Repeat


if x <> ItemIndex then
begin
RepalceColourData[c].Col1 := TempColourData[x].Col1;
RepalceColourData[c].Col2 := TempColourData[x].Col2;
ListBox1.Items.Add(Inttostr(TempColourData[x].Col1) + ' -> ' + Inttostr(TempColourData[x].Col2));
inc(c);
end;

inc(x);
until c = data_no;

Setlength(TempColourData,0);
end;

procedure TFrmReplaceColour.cnvPaletteMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var colwidth, rowheight: Real;
    i, j, idx: Integer;
begin
If not isEditable then exit;
     colwidth := cnvPalette.Width / 8;
     rowheight := cnvPalette.Height / 32;
     i := Trunc(X / colwidth);
     j := Trunc(Y / rowheight);
     idx := (i * 32) + j;

     if (SpectrumMode = ModeNormals) and (idx > ActiveNormalsCount-1) then exit;

     lblActiveColour.Caption := inttostr(idx);
     pnlActiveColour.Color := GetVXLPaletteColor(idx);
end;

procedure TFrmReplaceColour.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
data_no := 0;
Setlength(RepalceColourData,0);
end;

procedure TFrmReplaceColour.Button6Click(Sender: TObject);
var
ColourArray : array [0..255] of Byte;
x,y,z : integer;
v : TVoxelUnPacked;
begin

if data_no < 1 then Close; // nothing to do, so close.

CreateVXLRestorePoint(ActiveSection,Undo); // Save Undo

For x := 0 to 255 do
ColourArray[x] := x;

For x := 0 to data_no-1 do
ColourArray[RepalceColourData[x].Col1] := RepalceColourData[x].Col2;

For x := 0 to ActiveSection.Tailer.XSize -1 do
For y := 0 to ActiveSection.Tailer.YSize -1 do
For z := 0 to ActiveSection.Tailer.ZSize -1 do
begin
ActiveSection.GetVoxel(x,y,z,v);

if SpectrumMode = ModeColours then
V.Colour := ColourArray[V.Colour]
else
V.Normal := ColourArray[V.Normal];

ActiveSection.SetVoxel(x,y,z,v);
end;

FrmMain.RefreshAll;
FrmMain.UpdateUndo_RedoState;
VXLChanged := true;

Close;

end;

procedure TFrmReplaceColour.Button7Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmReplaceColour.FormDestroy(Sender: TObject);
begin
   SetLength(RepalceColourData,0);
   SetLength(TempColourData,0);
end;

end.
