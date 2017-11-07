unit FormHVAPositionManagerNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmHVAPositionManager_New = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    Panel2: TPanel;
    Button4: TButton;
    Button2: TButton;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label4: TLabel;
    PositionX: TEdit;
    PositionY: TEdit;
    PositionZ: TEdit;
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    O : boolean;
  end;

var
  FrmHVAPositionManager_New: TFrmHVAPositionManager_New;

implementation

{$R *.dfm}

procedure TFrmHVAPositionManager_New.Button4Click(Sender: TObject);
begin
O := true;
close;
end;

procedure TFrmHVAPositionManager_New.Button2Click(Sender: TObject);
begin
close;
end;

procedure TFrmHVAPositionManager_New.FormCreate(Sender: TObject);
begin
Panel1.DoubleBuffered := true;
O := false;
end;

end.
