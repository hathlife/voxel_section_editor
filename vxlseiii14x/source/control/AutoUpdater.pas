unit AutoUpdater;

interface

uses Windows, Internet, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, StdCtrls, Dialogs,
   SysUtils, ActiveX, ExtCtrls, Forms;

type
   TAutoUpdater = class(TThread)
      private
         FMmReport: TMemo;
         FLbFilename: TLabel;
         FForceRepair: Boolean;
         procedure DoMemoRefresh;
         procedure DoLabelRefresh;
      protected
         procedure Execute(); override;
      public
         Finished: boolean;
         RepairDone: boolean;
         constructor Create(const _MMReport: TMemo; const _LbFilename: TLabel; _ForceRepair: boolean);
   end;

implementation

constructor TAutoUpdater.Create(const _MMReport: TMemo; const _LbFilename: TLabel; _ForceRepair: boolean);
begin
   inherited Create(true);
   Finished := false;
   Priority := TpHighest;
   FMmReport := _MMReport;
   FLbFilename := _LbFilename;
   FForceRepair := _ForceRepair;
   RepairDone := false;
   Resume;
end;

procedure TAutoUpdater.DoMemoRefresh;
begin
   Application.ProcessMessages;
   FMMReport.Refresh;
   FMMReport.Repaint;
end;

procedure TAutoUpdater.DoLabelRefresh;
begin
   Application.ProcessMessages;
   FLbFileName.Refresh;
   FLbFileName.Repaint;
end;

procedure TAutoUpdater.Execute;
var
   FileStructureString : string;
   StructureFile: System.Text;
   StructureFilename,BaseDir,Filename: string;
   Node: IXMLNode;
   XMLDocument: IXMLDocument;
   Web : TWebFileDownloader;
begin
   // Ok, first let's get the file structure document.
   FMMReport.Lines.Clear;
   FLbFilename.Caption := 'Loading File Structure';
   try
      FileStructureString := GetWebContent('http://vxlse.ppmsite.com/structure.xml');
   except
      ShowMessage('Warning: Internet Connection Failed. Try again later.');
      ReturnValue := 0;
      Finished := true;
      exit;
   end;
   if Length(FileStructureString) = 0 then
   begin
      ReturnValue := 0;
      Finished := true;
      exit;
   end;
   FLbFilename.Caption := 'File Structure Downloaded';
   BaseDir := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
   StructureFilename := BaseDir + 'structure.xml';
   AssignFile(StructureFile,StructureFilename);
   Rewrite(StructureFile);
   Write(StructureFile,FileStructureString);
   CloseFile(StructureFile);
   FMMReport.Lines.Add('File structure data acquired. Starting procedure to repair the program.');
   FMMReport.Refresh;
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
      FLbFilename.Caption := Filename;
      Synchronize(DoLabelRefresh);
      if not FileExists(Filename) or FForceRepair then
      begin
         Web := TWebFileDownloader.Create(Node.Attributes['out'],Filename);
         Sleep(20);
         if Web.WaitFor > 0 then
         begin
            FMMReport.Lines.Add(Filename + ' downloaded.');
            Synchronize(DoMemoRefresh);
         end
         else
         begin
            FMMReport.Lines.Add(Filename + ' failed.');
            Synchronize(DoMemoRefresh);
         end;
         Web.Free;
      end
      else
      begin
         FMMReport.Lines.Add(Filename + ' skipped.');
         Synchronize(DoMemoRefresh);
      end;
      Node := Node.NextSibling;
   until Node = nil;
   XMLDocument.Active := false;
   DeleteFile(StructureFilename);
   FMMReport.Lines.Add('Repairing procedure has been finished.');
   Synchronize(DoMemoRefresh);
   ReturnValue := 1;
   RepairDone := true;
   Finished := true;
end;


end.
