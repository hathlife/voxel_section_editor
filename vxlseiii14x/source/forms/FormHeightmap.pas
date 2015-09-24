unit FormHeightmap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFrmHeightMap = class(TForm)
    EdImage: TEdit;
    BtBrowseImage: TButton;
    BtBrowseHeightmap: TButton;
    EdHeightmap: TEdit;
    Label1: TLabel;
    Panel2: TPanel;
    BtCancel: TButton;
    BtOK: TButton;
    Bevel3: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    OpenDialog: TOpenDialog;
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtBrowseHeightmapClick(Sender: TObject);
    procedure BtBrowseImageClick(Sender: TObject);
  private
    { Private declarations }
  public
    OK: boolean;
    { Public declarations }
  end;


implementation

{$R *.dfm}

procedure TFrmHeightMap.BtBrowseHeightmapClick(Sender: TObject);
begin
   if OpenDialog.Execute then
   begin
      EdHeightmap.Text := OpenDialog.FileName;
      if FileExists(EdImage.Text) and FileExists(EdHeightmap.Text) then
      begin
         BtOK.Enabled := true;
      end
      else
      begin
         BtOK.Enabled := false;
      end;
   end;
end;

procedure TFrmHeightMap.BtBrowseImageClick(Sender: TObject);
begin
   if OpenDialog.Execute then
   begin
      EdImage.Text := OpenDialog.FileName;
      if FileExists(EdImage.Text) and FileExists(EdHeightmap.Text) then
      begin
         BtOK.Enabled := true;
      end
      else
      begin
         BtOK.Enabled := false;
      end;
   end;
end;

procedure TFrmHeightMap.BtCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmHeightMap.BtOKClick(Sender: TObject);
begin
   BtOK.Enabled := false;
   OK := true;
   close;
end;

procedure TFrmHeightMap.FormShow(Sender: TObject);
begin
   OK := false;
end;

end.
