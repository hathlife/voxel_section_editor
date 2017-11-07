unit FormAnimationManagerNew;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Spin, Buttons, ExtCtrls;

type
   TFrmAnimationManager_New = class(TForm)
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
      Label4: TLabel;
      Label7: TLabel;
      Label8: TLabel;
      Label9: TLabel;
      SpeedButton1: TSpeedButton;
      SpeedButton2: TSpeedButton;
      MainViewWidth: TSpinEdit;
      MainViewHeight: TSpinEdit;
      Frames: TSpinEdit;
      AnimateCheckBox: TCheckBox;
      procedure Button4Click(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      O : Boolean;
   end;

var
   FrmAnimationManager_New: TFrmAnimationManager_New;

implementation

{$R *.dfm}

procedure TFrmAnimationManager_New.Button4Click(Sender: TObject);
begin
   O := True;
   Close;
end;

procedure TFrmAnimationManager_New.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmAnimationManager_New.FormCreate(Sender: TObject);
begin
   O := False;
   Panel1.DoubleBuffered := true;
end;

end.
