unit FormTopologyAnalysis;

interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   Dialogs, StdCtrls, ExtCtrls, ClassTopologyAnalyzer, Voxel;

type
   TFrmTopologyAnalysis = class(TForm)
      Label1: TLabel;
      Label2: TLabel;
      Label3: TLabel;
      Label4: TLabel;
      Label5: TLabel;
      Bevel1: TBevel;
      Label6: TLabel;
      Bevel2: TBevel;
      Label7: TLabel;
      Label8: TLabel;
      Bevel3: TBevel;
      Label9: TLabel;
      Label10: TLabel;
      Label11: TLabel;
      Bevel4: TBevel;
      BtOK: TButton;
      LbCorrectVoxels: TLabel;
      Lb1Face: TLabel;
      Lb2Faces: TLabel;
      Lb3Faces: TLabel;
      LbLoneVoxels: TLabel;
      LbTotalVoxels: TLabel;
      LbTopologyScore: TLabel;
      LbClassification: TLabel;
      procedure FormShow(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure BtOKClick(Sender: TObject);
   private
      { Private declarations }
   public
      TopologyAnalyzer: CTopologyAnalyzer;
      // Constructors and Destructors.
      constructor Create(const _Voxel: TVoxelSection; Sender: TComponent); overload;
      destructor Destroy; override;
  end;

implementation

{$R *.dfm}

// Constructors and Destructors.
constructor TFrmTopologyAnalysis.Create(const _Voxel: TVoxelSection; Sender: TComponent);
begin
   TopologyAnalyzer := CTopologyAnalyzer.Create(_Voxel);
   inherited Create(Sender);
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
   LbCorrectVoxels.Caption := TopologyAnalyzer.GetCorrectVoxelsText();
   Lb1Face.Caption := TopologyAnalyzer.GetNum1FaceText();
   Lb2Faces.Caption := TopologyAnalyzer.GetNum2FacesText();
   Lb3Faces.Caption := TopologyAnalyzer.GetNum3FacesText();
   LbLoneVoxels.Caption := TopologyAnalyzer.GetLoneVoxelsText();
   LbTotalVoxels.Caption := TopologyAnalyzer.GetTotalVoxelsText();
   LbTopologyScore.Caption := TopologyAnalyzer.GetTopologyScoreText();
   LbClassification.Caption := TopologyAnalyzer.GetClassificationText();
end;

procedure TFrmTopologyAnalysis.BtOKClick(Sender: TObject);
begin
   Close;
end;

end.
