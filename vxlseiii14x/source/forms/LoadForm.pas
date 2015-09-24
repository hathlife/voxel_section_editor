unit LoadForm;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   ExtCtrls, StdCtrls, Buttons, GIFImage, jpeg;

{$INCLUDE source/Global_Conditionals.inc}

type
   TLoadFrm = class(TForm)
      Image1: TImage;
      Label4: TLabel;
      lblWill: TLabel;
      loading: TLabel;
      butOK: TSpeedButton;
      Bevel1: TBevel;
      Image2: TImage;
      procedure OKClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

implementation

{$R *.DFM}

procedure TLoadFrm.OKClick(Sender: TObject);
begin
   Close;
end;

end.
