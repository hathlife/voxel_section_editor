unit FormRotationManagerNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmRotationManager_New = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    Panel2: TPanel;
    Button4: TButton;
    Button2: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    RotationX: TEdit;
    RotationY: TEdit;
    RotationZ: TEdit;
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
  FrmRotationManager_New: TFrmRotationManager_New;

implementation

{$R *.dfm}

procedure TFrmRotationManager_New.Button4Click(Sender: TObject);
begin
O := True;
Close;
end;

procedure TFrmRotationManager_New.FormCreate(Sender: TObject);
begin
O := False;
Panel1.DoubleBuffered := true;
end;

procedure TFrmRotationManager_New.Button2Click(Sender: TObject);
begin
Close;
end;

end.
