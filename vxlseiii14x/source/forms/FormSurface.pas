unit FormSurface;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TFrmSurfaces = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    BtOK: TButton;
    BtCancel: TButton;
    SpP1x: TSpinEdit;
    SpP2x: TSpinEdit;
    SpP3x: TSpinEdit;
    SpP4x: TSpinEdit;
    SpP1y: TSpinEdit;
    SpP2y: TSpinEdit;
    SpP3y: TSpinEdit;
    SpP4y: TSpinEdit;
    SpP1z: TSpinEdit;
    SpP2z: TSpinEdit;
    SpP3z: TSpinEdit;
    SpP4z: TSpinEdit;
    SpT1x: TSpinEdit;
    SpT2x: TSpinEdit;
    SpT3x: TSpinEdit;
    SpT4x: TSpinEdit;
    SpT1y: TSpinEdit;
    SpT2y: TSpinEdit;
    SpT3y: TSpinEdit;
    SpT4y: TSpinEdit;
    SpT1z: TSpinEdit;
    SpT2z: TSpinEdit;
    SpT3z: TSpinEdit;
    SpT4z: TSpinEdit;
    LbVoxelSize: TLabel;
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Changed : Boolean;
  end;

implementation

uses FormMain;

{$R *.dfm}

procedure TFrmSurfaces.BtOKClick(Sender: TObject);
begin
   Changed := true;
   Close;
end;

procedure TFrmSurfaces.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmSurfaces.FormCreate(Sender: TObject);
begin
   SpP1x.Value := 0;
   SpP1y.Value := 0;
   SpP1z.Value := 0;
   SpP2x.Value := 0;
   SpP2y.Value := 0;
   SpP2z.Value := 0;
   SpP3x.Value := 0;
   SpP3y.Value := 0;
   SpP3z.Value := 0;
   SpP4x.Value := 0;
   SpP4y.Value := 0;
   SpP4z.Value := 0;
   SpT1x.Value := 0;
   SpT1y.Value := 0;
   SpT1z.Value := 0;
   SpT2x.Value := 0;
   SpT2y.Value := 0;
   SpT2z.Value := 0;
   SpT3x.Value := 0;
   SpT3y.Value := 0;
   SpT3z.Value := 0;
   SpT4x.Value := 0;
   SpT4y.Value := 0;
   SpT4z.Value := 0;
   lbVoxelSize.Caption := 'Voxel Size Is: ' + IntToStr(FrmMain.Document.ActiveSection^.Tailer.XSize) + ', ' + IntToStr(FrmMain.Document.ActiveSection^.Tailer.YSize) + ', ' + IntToStr(FrmMain.Document.ActiveSection^.Tailer.ZSize) + '.';
end;

end.
