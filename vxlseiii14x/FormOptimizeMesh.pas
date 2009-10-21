unit FormOptimizeMesh;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin;

type
  TFrmOptimizeMesh = class(TForm)
    LbThreshold: TLabel;
    BvlBottomLine: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    cbIgnoreColours: TCheckBox;
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

procedure TFrmOptimizeMesh.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmOptimizeMesh.BtOKClick(Sender: TObject);
begin
   Threshold := StrToFloatDef(EdThreshold.Text,-1);
   if Threshold >= 0 then
   begin
      Apply := true;
      Close;
   end
   else
   begin
      ShowMessage('Please, insert a threshold between 0 and 1.4.');
   end;
end;

procedure TFrmOptimizeMesh.FormCreate(Sender: TObject);
begin
   Apply := false;
end;

end.
