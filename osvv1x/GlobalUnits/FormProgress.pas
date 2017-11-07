unit FormProgress;

interface

uses
   Controls, StdCtrls, Classes, ExtCtrls,Forms;

type
   TFrmProgress = class(TForm)
      Panel1: TPanel;
      Label3: TLabel;
      Label1: TLabel;
   public
      Procedure UpdateAction(Action : String);
   end;

var
   FrmProgress: TFrmProgress;

implementation

{$R *.dfm}


Procedure TFrmProgress.UpdateAction(Action : String);
begin
   Label3.Caption := {'Loading ' + }Action;
   Label3.Update;
end;

end.
