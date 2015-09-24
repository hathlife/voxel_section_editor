unit FormImportSection;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmImportSection = class(TForm)
    Label1: TLabel;
    ComboBox1: TComboBox;
    BtOK: TButton;
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmImportSection: TFrmImportSection;

implementation

{$R *.dfm}

procedure TFrmImportSection.BtOKClick(Sender: TObject);
begin
   BtOK.Enabled := false;
   close;
end;

end.
