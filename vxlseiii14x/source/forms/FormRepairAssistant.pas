unit FormRepairAssistant;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, ExtCtrls,
  Internet, AutoUpdater;

type
   TFrmRepairAssistant = class(TForm)
      MmReport: TMemo;
      Label1: TLabel;
      LbFilename: TLabel;
      Timer: TTimer;
      procedure FormShow(Sender: TObject);
      procedure TimerTimer(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure MmReportChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      RepairDone, ForceRepair: boolean;
      function RequestAuthorization(const _Filename: string): boolean;
      procedure Execute;
   end;

implementation

{$R *.dfm}

procedure TFrmRepairAssistant.FormCreate(Sender: TObject);
begin
   RepairDone := false;
   ForceRepair := false;
end;

procedure TFrmRepairAssistant.FormDestroy(Sender: TObject);
begin
   MMReport.Lines.Clear;
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
var
   Updater: TAutoUpdater;
begin
   isMultiThread := true;
   Sleep(200);
   Updater := TAutoUpdater.Create(MMReport,LbFilename,ForceRepair);
   if Updater.WaitFor > 0 then
   begin
      RepairDone := Updater.RepairDone;
   end;
   Updater.Free;
   isMultiThread := false;
   Close;
end;

function TFrmRepairAssistant.RequestAuthorization(const _Filename: string): boolean;
begin
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
   Timer.Enabled := false;
   Execute;
end;

end.
