unit FormVxlError;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Voxel_Engine;

type
  TFrmVxlError = class(TForm)
    Bevel3: TBevel;
    Panel3: TPanel;
    Image1: TImage;
    Label5: TLabel;
    Label6: TLabel;
    Bevel4: TBevel;
    Panel4: TPanel;
    BtClose: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    InfoBox1: TRichEdit;
    BtFixErrorHeader: TButton;
    TabSheet2: TTabSheet;
    Label2: TLabel;
    RichEdit1: TRichEdit;
    BtFixErrorNormals: TButton;
    procedure BtFixErrorHeaderClick(Sender: TObject);
    procedure BtCloseClick(Sender: TObject);
    procedure BtFixErrorNormalsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmVxlError: TFrmVxlError;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmVxlError.BtFixErrorHeaderClick(Sender: TObject);
begin
   SetVoxelFileDefaults;
   VXLChanged := true;
   BtFixErrorHeader.Enabled := False;
end;

procedure TFrmVxlError.BtCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmVxlError.BtFixErrorNormalsClick(Sender: TObject);
var
   N : integer;
begin
   N := FrmMain.Document.ActiveVoxel^.Section[0].Tailer.NormalsType;
   SetNormals(N);

   MessageBox(0,Pchar('Normals Set To: ' + inttostr(N)),'Information',0);

   VXLChanged := true;
   BtFixErrorNormals.Enabled := False;
end;

procedure TFrmVxlError.FormCreate(Sender: TObject);
begin
   TabSheet1.TabVisible := false;
   TabSheet2.TabVisible := false;
   Panel3.DoubleBuffered := true;
end;

end.
