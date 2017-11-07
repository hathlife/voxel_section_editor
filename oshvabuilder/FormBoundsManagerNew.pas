unit FormBoundsManagerNew;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, Buttons, ExtCtrls;

type
   TFrmBoundsManager_New = class(TForm)
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
      Label7: TLabel;
      Label8: TLabel;
      Label9: TLabel;
      Label10: TLabel;
      Label11: TLabel;
      SpeedButton1: TSpeedButton;
      SpeedButton2: TSpeedButton;
      SpeedButton3: TSpeedButton;
      XOffset: TEdit;
      YOffset: TEdit;
      ZOffset: TEdit;
      SizeX: TEdit;
      SizeY: TEdit;
      SizeZ: TEdit;
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
   FrmBoundsManager_New: TFrmBoundsManager_New;

implementation

{$R *.dfm}

procedure TFrmBoundsManager_New.Button4Click(Sender: TObject);
begin
   O := True;
   Close;
end;

procedure TFrmBoundsManager_New.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmBoundsManager_New.FormCreate(Sender: TObject);
begin
   O := false;
   Panel1.DoubleBuffered := true;
end;

end.
