unit FormGenerateDiffuseTexture;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin;

type
  TFrmGenerateDiffuseTexture = class(TForm)
    LbThreshold: TLabel;
    BvlBottomLine: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    Label1: TLabel;
    EdThreshold: TEdit;
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Apply : boolean;
    Threshold : real;
  end;

implementation

{$R *.dfm}

procedure TFrmGenerateDiffuseTexture.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmGenerateDiffuseTexture.BtOKClick(Sender: TObject);
begin
   Threshold := StrToFloatDef(EdThreshold.Text,-1);
   if (Threshold > 0) and (Threshold < 180) then
   begin
      Threshold := cos((Threshold * Pi) / 180);
      BtOK.Enabled := false;
      Apply := true;
      Close;
   end
   else
   begin
      ShowMessage('Please, insert an angle between 0 and 180 (not included).');
   end;
end;

procedure TFrmGenerateDiffuseTexture.FormCreate(Sender: TObject);
begin
   Apply := false;
end;

end.
