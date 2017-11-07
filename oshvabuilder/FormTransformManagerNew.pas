unit FormTransformManagerNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls;

type
  TFrmTransformManager_New = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    Panel2: TPanel;
    Button4: TButton;
    Button2: TButton;
    Label13: TLabel;
    grdTrans: TStringGrid;
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
  FrmTransformManager_New: TFrmTransformManager_New;

implementation

{$R *.dfm}

procedure TFrmTransformManager_New.Button4Click(Sender: TObject);
begin
O := True;
Close;
end;

procedure TFrmTransformManager_New.Button2Click(Sender: TObject);
begin
Close;
end;

procedure TFrmTransformManager_New.FormCreate(Sender: TObject);
begin
O := False;
Panel1.DoubleBuffered := true;
end;

end.
