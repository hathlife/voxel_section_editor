unit FormBumpMapping;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmBumpMapping = class(TForm)
    LbThreshold: TLabel;
    BvlBottomLine: TBevel;
    Label1: TLabel;
    BtOK: TButton;
    BtCancel: TButton;
    EdBump: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Apply : boolean;
  end;

implementation

{$R *.dfm}

procedure TFrmBumpMapping.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmBumpMapping.BtOKClick(Sender: TObject);
begin
   if StrToFloatDef(EdBump.Text,-1) > 0 then
   begin
      Apply := true;
      Close;
   end
   else
   begin
      ShowMessage('Please, insert a positive value for bump mapping scale.');
   end;
end;

procedure TFrmBumpMapping.FormCreate(Sender: TObject);
begin
   Apply := false;
end;

end.
