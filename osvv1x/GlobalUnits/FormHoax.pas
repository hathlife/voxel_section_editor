unit FormHoax;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type
  TFrmHoax = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    Panel2: TPanel;
    RichEdit1: TRichEdit;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    Button2: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmHoax: TFrmHoax;

implementation

uses AprilFoolsTrial;

{$R *.dfm}

procedure TFrmHoax.Timer1Timer(Sender: TObject);
begin
if ProgressBar1.Position = 100 then
begin
Timer1.Enabled  := False;
if not IsError then
Button2.Visible := True
else
Close;
exit;
end;
ProgressBar1.Position := ProgressBar1.Position + 5;
end;

procedure TFrmHoax.Button2Click(Sender: TObject);
begin
Close;
end;

end.
