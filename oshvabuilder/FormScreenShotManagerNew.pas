unit FormScreenShotManagerNew;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, ComCtrls, StdCtrls, Spin, Buttons, ExtCtrls;

type
   TFrmScreenShotManager_New = class(TForm)
      Panel1: TPanel;
      Image1: TImage;
      Label1: TLabel;
      Label2: TLabel;
      Bevel1: TBevel;
      Panel2: TPanel;
      Button4: TButton;
      Button2: TButton;
      Bevel2: TBevel;
      Label5: TLabel;
      Label6: TLabel;
      lblC100: TLabel;
      lblC1: TLabel;
      Label4: TLabel;
      Label7: TLabel;
      Label8: TLabel;
      SpeedButton1: TSpeedButton;
      SpeedButton2: TSpeedButton;
      MainViewWidth: TSpinEdit;
      MainViewHeight: TSpinEdit;
      RadioButton1: TRadioButton;
      RadioButton2: TRadioButton;
      Compression: TTrackBar;
      procedure Button4Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure RadioButton1Click(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      O : Boolean;
   end;

var
   FrmScreenShotManager_New: TFrmScreenShotManager_New;

implementation

{$R *.dfm}

procedure TFrmScreenShotManager_New.Button4Click(Sender: TObject);
begin
   O := true;
   Close;
end;

procedure TFrmScreenShotManager_New.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmScreenShotManager_New.FormCreate(Sender: TObject);
begin
   O := False;
   Panel1.DoubleBuffered := true;
end;

procedure TFrmScreenShotManager_New.RadioButton1Click(Sender: TObject);
var
   Value : boolean;
begin
   Value := not RadioButton1.Checked;
   Compression.Enabled := Value;
   lblC1.Enabled := Value;
   lblC100.Enabled := Value;
end;

end.
