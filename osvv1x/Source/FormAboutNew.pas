unit FormAboutNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ShellAPI;

type
  TFrmAbout_New = class(TForm)
    Panel2: TPanel;
    Button2: TButton;
    Bevel2: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAbout_New: TFrmAbout_New;

implementation

{$R *.dfm}

procedure TFrmAbout_New.FormCreate(Sender: TObject);
begin
   Panel1.DoubleBuffered := true;
end;

procedure TFrmAbout_New.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmAbout_New.Label8Click(Sender: TObject);
begin
   ShellExecute(Application.Handle,nil,PChar(TLabel(Sender).Caption),'','',SW_SHOWNORMAL);
end;

end.
