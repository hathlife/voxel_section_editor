unit FormAnimationManagerNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Buttons, ExtCtrls;

type
  TFrmAniamtionManager_New = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Panel2: TPanel;
    Button4: TButton;
    Button2: TButton;
    Bevel2: TBevel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SpeedButton1: TSpeedButton;
    MainViewWidth: TSpinEdit;
    Frames: TSpinEdit;
    AnimateCheckBox: TCheckBox;
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    O : Boolean;
  end;

var
  FrmAniamtionManager_New: TFrmAniamtionManager_New;

implementation

{$R *.dfm}

uses Math, FormMain;

procedure TFrmAniamtionManager_New.Button4Click(Sender: TObject);
begin
O := True;
Close;
end;

procedure TFrmAniamtionManager_New.Button2Click(Sender: TObject);
begin
Close;
end;

procedure TFrmAniamtionManager_New.FormCreate(Sender: TObject);
begin
O := False;
Panel1.DoubleBuffered := true;
end;

procedure TFrmAniamtionManager_New.SpeedButton1Click(Sender: TObject);
begin
 MainViewWidth.Value := Min(VVFrmMain.MainView.Width,300);
end;

end.
