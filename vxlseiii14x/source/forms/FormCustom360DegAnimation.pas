unit FormCustom360DegAnimation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFrmCustom360DegAnimation = class(TForm)
    LbNumFrames: TLabel;
    EdNumFrames: TEdit;
    Bevel1: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    LbFrameDelay: TLabel;
    EdFrameDelay: TEdit;
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OK: boolean;
    NumFrames: longword;
    FrameDelay: longword;
  end;

implementation

{$R *.dfm}

procedure TFrmCustom360DegAnimation.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmCustom360DegAnimation.BtOKClick(Sender: TObject);
begin
   NumFrames := StrToIntDef(EdNumFrames.Text, 0);
   if NumFrames > 0 then
   begin
      FrameDelay := StrToIntDef(EdFrameDelay.Text, 0);
      if FrameDelay > 0 then
      begin
         OK := true;
         close;
      end
      else
      begin
         ShowMessage('Warning: Insert a valid time in millisseconds of frame delay for an animation. It must be a positive non-zero value.');
      end;
   end
   else
   begin
      ShowMessage('Warning: Insert a valid amount of frames for an animation. It must be a positive non-zero value.');
   end;
end;

procedure TFrmCustom360DegAnimation.FormCreate(Sender: TObject);
begin
   OK := false;
end;

end.
