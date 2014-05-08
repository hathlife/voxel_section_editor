unit FormTopologyAnalysis;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, TopologyAnalyzer, Voxel;

type
   TFrmTopologyAnalysis = class(TForm)
      Bevel4: TBevel;
      BtOK: TButton;
    GbCollectedData: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LbLoneVoxels: TLabel;
    Lb3Faces: TLabel;
    Lb2Faces: TLabel;
    Lb1Face: TLabel;
    LbCorrectVoxels: TLabel;
    GbAnalysis: TGroupBox;
    Label7: TLabel;
    LbTopologyScore: TLabel;
    LbClassification: TLabel;
    Label8: TLabel;
    Label6: TLabel;
    Bevel2: TBevel;
    LbTotalVoxels: TLabel;
    GbExplanation: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    GroupBox1: TGroupBox;
    RbWholeModel: TRadioButton;
    RbJustSection: TRadioButton;
    CbSections: TComboBox;
    Label12: TLabel;
    procedure CbSectionsChange(Sender: TObject);
    procedure RbJustSectionClick(Sender: TObject);
    procedure RbWholeModelClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
   private
      procedure ShowResults;
   public
      TopologyAnalyzer: CTopologyAnalyzer;
      // Constructors and Destructors.
      constructor Create(const _Voxel: TVoxelSection; Sender: TComponent); reintroduce; overload;
      destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses FormMain;

// Constructors and Destructors.
procedure TFrmTopologyAnalysis.CbSectionsChange(Sender: TObject);
begin
   if RbJustSection.Checked then
   begin
      TopologyAnalyzer.Load(FrmMain.Document.ActiveVoxel^.Section[CbSections.ItemIndex]);
      ShowResults();
   end;
end;

constructor TFrmTopologyAnalysis.Create(const _Voxel: TVoxelSection; Sender: TComponent);
var
   i : integer;
begin
   TopologyAnalyzer := CTopologyAnalyzer.Create(_Voxel);
   inherited Create(Sender);
   for i := 0 to (FrmMain.Document.ActiveVoxel^.Header.NumSections-1) do
   begin
      CbSections.Items.Add(FrmMain.Document.ActiveVoxel^.Section[i].Name);
   end;
   CbSections.ItemIndex := _Voxel.Header.Number;
end;

destructor TFrmTopologyAnalysis.Destroy;
begin
   TopologyAnalyzer.Free;
   inherited Destroy;
end;

procedure TFrmTopologyAnalysis.FormCreate(Sender: TObject);
begin
   // ???
end;

procedure TFrmTopologyAnalysis.FormShow(Sender: TObject);
begin
   ShowResults();
end;

procedure TFrmTopologyAnalysis.ShowResults();
begin
   LbCorrectVoxels.Caption := TopologyAnalyzer.GetCorrectVoxelsText();
   Lb1Face.Caption := TopologyAnalyzer.GetNum1FaceText();
   Lb2Faces.Caption := TopologyAnalyzer.GetNum2FacesText();
   Lb3Faces.Caption := TopologyAnalyzer.GetNum3FacesText();
   LbLoneVoxels.Caption := TopologyAnalyzer.GetLoneVoxelsText();
   LbTotalVoxels.Caption := TopologyAnalyzer.GetTotalVoxelsText();
   LbTopologyScore.Caption := TopologyAnalyzer.GetTopologyScoreText();
   LbClassification.Caption := TopologyAnalyzer.GetClassificationText();
end;

procedure TFrmTopologyAnalysis.RbJustSectionClick(Sender: TObject);
begin
   RbWholeModel.Checked := false;
   RbJustSection.Checked := true;
   TopologyAnalyzer.Load(FrmMain.Document.ActiveVoxel^.Section[CbSections.ItemIndex]);
   ShowResults();
end;

procedure TFrmTopologyAnalysis.RbWholeModelClick(Sender: TObject);
begin
   RbWholeModel.Checked := true;
   RbJustSection.Checked := false;
   TopologyAnalyzer.LoadFullVoxel(FrmMain.Document.ActiveVoxel^);
   ShowResults();
end;

procedure TFrmTopologyAnalysis.BtOKClick(Sender: TObject);
begin
   Close;
end;

end.
