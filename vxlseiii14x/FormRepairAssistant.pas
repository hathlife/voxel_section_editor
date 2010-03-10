unit FormRepairAssistant;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, xmldom, XMLIntf, msxmldom,
  XMLDoc, ActiveX, ExtCtrls;

type
   TFrmRepairAssistant = class(TForm)
      MmReport: TMemo;
      Label1: TLabel;
      LbFilename: TLabel;
      IdHTTP: TIdHTTP;
      IdAntiFreeze1: TIdAntiFreeze;
      Timer: TTimer;
    procedure FormShow(Sender: TObject);
      procedure TimerTimer(Sender: TObject);
      procedure MmReportChange(Sender: TObject);
      function RequestAuthorization(const _Filename: string): boolean;
      procedure FormCreate(Sender: TObject);
      procedure Execute;
   private
      { Private declarations }
   public
      { Public declarations }
      RepairDone, ForceRepair: boolean;
   end;

implementation

{$R *.dfm}

procedure TFrmRepairAssistant.FormCreate(Sender: TObject);
begin
   RepairDone := false;
   ForceRepair := false;
end;

procedure TFrmRepairAssistant.FormShow(Sender: TObject);
begin
   Timer.Enabled := true;
end;

procedure TFrmRepairAssistant.MmReportChange(Sender: TObject);
begin
   MmReport.Perform(EM_LineScroll, 0, MmReport.Lines.Count);
   LbFilename.Refresh;
end;

procedure TFrmRepairAssistant.Execute;
const
   MAX_TRIES = 5;
var
   FileStructureString : string;
   StructureFile,CurrentFile: System.Text;
   StructureFilename,BaseDir,Filename: string;
   FileContents : TStream;
   Node: IXMLNode;
   XMLDocument: IXMLDocument;
   DLAttempt: integer;
begin
   // Ok, first let's get the file structure document.
   MMReport.Lines.Clear;
   LbFilename.Caption := 'Loading File Structure';
   try
      FileStructureString := IdHTTP.Get('http://vxlse.ppmsite.com/structure.xml');
   except
      ShowMessage('Warning: Internet Connection Failed. Try again later.');
      close;
      exit;
   end;
   if Length(FileStructureString) = 0 then
   begin
      Close;
      exit;
   end;
   LbFilename.Caption := 'File Structure Downloaded';
   BaseDir := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
   StructureFilename := BaseDir + 'structure.xml';
   AssignFile(StructureFile,StructureFilename);
   Rewrite(StructureFile);
   Write(StructureFile,FileStructureString);
   CloseFile(StructureFile);
   MMReport.Lines.Add('File structure data acquired. Starting procedure to repair the program.');
   // Now, let's read it.
   CoInitialize(nil);
   XMLDocument := TXMLDocument.Create(nil);
   XMLDocument.Active := true;
   XMLDocument.LoadFromFile(StructureFilename);
   // Make sure that we create the directories that the program will use.
   ForceDirectories(BaseDir + 'palettes\');
   ForceDirectories(BaseDir + 'palettes\TS\');
   ForceDirectories(BaseDir + 'palettes\RA2\');
   ForceDirectories(BaseDir + 'Cursors\');
   ForceDirectories(BaseDir + 'images\');
   ForceDirectories(BaseDir + 'shaders\');
   ForceDirectories(BaseDir + 'cschemes\');
   ForceDirectories(BaseDir + 'cschemes\PalPack1\');
   ForceDirectories(BaseDir + 'cschemes\PalPack2\');
   ForceDirectories(BaseDir + 'cschemes\USER\');
   // check each item
   Node := XMLDocument.DocumentElement.ChildNodes.FindNode('file');
   repeat
      Filename := BaseDir + Node.Attributes['in'];
      LbFilename.Caption := Filename;
      if not FileExists(Filename) or ForceRepair then
      begin
         FileContents := TFileStream.Create(Filename,fmCreate);
         DLAttempt := 0;
         while (FileContents.Size = 0) and (DLAttempt < MAX_TRIES) do
         begin
            IdHTTP.Get(Node.Attributes['out'],FileContents);
            inc(DLAttempt);
         end;
         if FileContents.Size > 0 then
         begin
            MMReport.Lines.Add(Filename + ' downloaded.');
         end
         else
         begin
            MMReport.Lines.Add(Filename + ' failed.');
         end;
         FileContents.Free;
      end
      else
      begin
         MMReport.Lines.Add(Filename + ' skipped.');
      end;
      Node := Node.NextSibling;
   until Node = nil;
   XMLDocument.Active := false;
   DeleteFile(StructureFilename);
   MMReport.Lines.Add('Repairing procedure has been finished.');
   RepairDone := true;
   Close;
end;

function TFrmRepairAssistant.RequestAuthorization(const _Filename: string): boolean;
begin
   Result := false;
   if MessageDlg('Voxel Section Editor III Repair Assistant' +#13#13+
        'The program has detected that the required file below is missing:' + #13+#13 +
        _Filename + #13+#13 +
        'The Voxel Section Editor III Repair Assistant is able to retrieve this ' + #13 +
        'and required other files from the internet automatically. In order to run it, ' + #13 +
        'make sure you are online and click OK. If you refuse to run it, click Cancel.',
        mtWarning,mbOKCancel,0) = mrCancel then
                        Application.Terminate;
   Result := true;
end;

procedure TFrmRepairAssistant.TimerTimer(Sender: TObject);
begin
   Sleep(200);
   Execute;
   Timer.Enabled := false;
end;

end.
