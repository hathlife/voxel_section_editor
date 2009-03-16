unit FormCameraManagerNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmCameraManager_New = class(TForm)
    Panel2: TPanel;
    Bevel2: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Label3: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Button4: TButton;
    Button2: TButton;
    XRot: TEdit;
    YRot: TEdit;
    Depth: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    TargetX: TEdit;
    TargetY: TEdit;
    Label6: TLabel;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    O : boolean;
  end;

var
  FrmCameraManager_New: TFrmCameraManager_New;

implementation

{$R *.dfm}

procedure TFrmCameraManager_New.Button4Click(Sender: TObject);
begin
O := True;
Close;
end;

procedure TFrmCameraManager_New.FormCreate(Sender: TObject);
begin
O := False;
Panel1.DoubleBuffered := true;
end;

procedure TFrmCameraManager_New.Button2Click(Sender: TObject);
begin
Close;
end;

end.
