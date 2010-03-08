unit FormRepairAssistant;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, xmldom, XMLIntf, msxmldom,
  XMLDoc;

type
   TFrmRepairAssistant = class(TForm)
      MmReport: TMemo;
      Label1: TLabel;
      LbFilename: TLabel;
      IdHTTP: TIdHTTP;
      IdAntiFreeze1: TIdAntiFreeze;
      XMLDocument: TXMLDocument;
      procedure FormCreate(Sender: TObject);
      procedure Execute;
   private
      function RequestAuthorization(const _Filename: string): boolean;
      { Private declarations }
   public
      { Public declarations }
      RepairDone: boolean;
   end;

implementation

{$R *.dfm}

procedure TFrmRepairAssistant.FormCreate(Sender: TObject);
begin
   RepairDone := false;
end;

procedure TFrmRepairAssistant.Execute;
var
   FileStructureString : string;
   StructureFile,CurrentFile: System.Text;
   StructureFilename,BaseDir,Filename: string;
   FileContents : TStream;
   Node: IXMLNode;
begin
   // Ok, first let's get the file structure document.
   FileStructureString := IdHTTP.Get('http://vxlse.ppmsite.com/structure.xml');
   if Length(FileStructureString) = 0 then
   begin
      Close;
   end;
   BaseDir := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
   StructureFilename := BaseDir + 'structure.xml';
   AssignFile(StructureFile,StructureFilename);
   Rewrite(StructureFile);
   Write(StructureFile,FileStructureString);
   CloseFile(StructureFile);
   // Now, let's read it.
   XMLDocument.LoadFromFile(StructureFilename);
   XMLDocument.Active := true;
   // check each item
   Node := XMLDocument.DocumentElement.ChildNodes.First.ChildNodes.FindNode('file') ;
   repeat
      Filename := BaseDir + Node.Attributes['in'];
      LbFilename.Caption := Filename;
      if not FileExists(Filename) then
      begin
         FileContents := TFileStream.Create(Filename,fmCreate);
         while FileContents.Size = 0 do
         begin
            IdHTTP.Get(Node.Attributes['out'],FileContents);
         end;
         FileContents.Free;
      end;
   until Node = nil;
   DeleteFile(StructureFilename);
   RepairDone := true;
   Close;
end;

function TFrmRepairAssistant.RequestAuthorization(const _Filename: string): boolean;
begin
   Result := false;
   if MessageDlg('Voxel Section Editor III Repair Assistant' +#13#13+
        'The program requires the following file to run:' + #13+#13 +
        _Filename + #13+#13 + ' This file was not found by the program.' +#13+
        'The Voxel Section Editor III Repair Assistant is able to retrive this ' + #13 +
        'and required other files from the internet automatically. In order to run it, click OK. ' + #13 +
        'If you refuse to run it, click Cancel.',
        mtWarning,mbOKCancel,0) = mrCancel then
                        Application.Terminate;
   Result := true;
end;

end.
