unit FormMain;

// TODO:
// Consider writing a class that helps to deal with brush-related painting affairs
// - HBD  01/28/2011

interface

uses
  Windows, BasicMathsTypes, BasicDataTypes, Render, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin, ImgList, Spin, Buttons, ShellAPI, Form3dpreview, XPMan, dglOpenGL,
  VoxelDocument, RenderEnvironment, Actor, Camera, BasicFunctions,
  BasicVXLSETypes, Form3dModelizer, BasicProgramTypes, CustomSchemeControl,
  PaletteControl, Debug;

{$INCLUDE source/Global_Conditionals.inc}

Const
   APPLICATION_TITLE = 'Voxel Section Editor III';
   APPLICATION_VER = '1.39.267';
   APPLICATION_BETA = true;

type
  TFrmMain = class(TForm)
    File1: TMenuItem;
    Open1: TMenuItem;
    OpenVXLDialog: TOpenDialog;
    Panel1: TPanel;
    LeftPanel: TPanel;
    RightPanel: TPanel;
    MainPaintPanel: TPanel;
    CnvView2: TPaintBox;
    CnvView1: TPaintBox;
    lblView1: TLabel;
    lblView2: TLabel;
    lblView0: TLabel;
    View1: TMenuItem;
    lblSection: TLabel;
    ViewMode1: TMenuItem;
    Full1: TMenuItem;
    CrossSection1: TMenuItem;
    EmphasiseDepth1: TMenuItem;
    Panel2: TPanel;
    ToolBar1: TToolBar;
    BarOpen: TToolButton;
    BarSaveAs: TToolButton;
    BarReopen: TToolButton;
    ToolButton4: TToolButton;
    mnuBarUndo: TToolButton;
    mnuBarRedo: TToolButton;
    ToolButton10: TToolButton;
    ToolButton7: TToolButton;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    ToolButton13: TToolButton;
    ToolButton11: TToolButton;
    ToolButton1: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ImageList1: TImageList;
    Spectrum1: TMenuItem;
    Colours1: TMenuItem;
    Normals1: TMenuItem;
    Panel3: TPanel;
    SectionCombo: TComboBox;
    lblTools: TLabel;
    PnlTools: TPanel;
    lblpalette: TLabel;
    cnvPalette: TPaintBox;
    pnlPalette: TPanel;
    lblActiveColour: TLabel;
    pnlActiveColour: TPanel;
    ScrollBar2: TScrollBar;
    Panel5: TPanel;
    ScrollBar1: TScrollBar;
    Panel6: TPanel;
    N2: TMenuItem;
    ShowUsedColoursNormals1: TMenuItem;
    lbl3dview: TLabel;
    OGL3DPreview: TPanel;
    Panel7: TPanel;
    SpeedButton2: TSpeedButton;
    btn3DRotateX2: TSpeedButton;
    btn3DRotateY2: TSpeedButton;
    btn3DRotateY: TSpeedButton;
    Bevel1: TBevel;
    SpeedButton1: TSpeedButton;
    btn3DRotateX: TSpeedButton;
    spin3Djmp: TSpinEdit;
    ColorDialog: TColorDialog;
    Popup3d: TPopupMenu;
    Views1: TMenuItem;
    Front1: TMenuItem;
    Back1: TMenuItem;
    MenuItem1: TMenuItem;
    LEft1: TMenuItem;
    Right1: TMenuItem;
    MenuItem2: TMenuItem;
    Bottom1: TMenuItem;
    op1: TMenuItem;
    N3: TMenuItem;
    Cameo1: TMenuItem;
    Cameo21: TMenuItem;
    Cameo31: TMenuItem;
    Cameo41: TMenuItem;
    Options2: TMenuItem;
    DebugMode1: TMenuItem;
    RemapColour1: TMenuItem;
    Gold1: TMenuItem;
    Red1: TMenuItem;
    Orange1: TMenuItem;
    Magenta1: TMenuItem;
    Purple1: TMenuItem;
    Blue1: TMenuItem;
    Green1: TMenuItem;
    DarkSky1: TMenuItem;
    White1: TMenuItem;
    N4: TMenuItem;
    BackgroundColour1: TMenuItem;
    extColour1: TMenuItem;
    N5: TMenuItem;
    lblLayer: TLabel;
    PnlLayer: TPanel;
    XCursorBar: TTrackBar;
    Label2: TLabel;
    Label3: TLabel;
    YCursorBar: TTrackBar;
    Label4: TLabel;
    ZCursorBar: TTrackBar;
    StatusBar1: TStatusBar;
    mnuDirectionPopup: TPopupMenu;
    mnuEdit: TMenuItem;
    mnuDirTowards: TMenuItem;
    mnuDirAway: TMenuItem;
    mnuCancel1: TMenuItem;
    lblBrush: TLabel;
    PnlBrushOptions: TPanel;
    Brush_5: TSpeedButton;
    Brush_4: TSpeedButton;
    Brush_3: TSpeedButton;
    Brush_2: TSpeedButton;
    Brush_1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton9: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    NewProject1: TMenuItem;
    ReOpen1: TMenuItem;
    N1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    Exit1: TMenuItem;
    EmptyVoxel1: TMenuItem;
    EmptyVoxel2: TMenuItem;
    Section1: TMenuItem;
    VoxelHeader1: TMenuItem;
    SaveVXLDialog: TSaveDialog;
    New1: TMenuItem;
    N9: TMenuItem;
    Resize1: TMenuItem;
    FullResize1: TMenuItem;
    Delete1: TMenuItem;
    ClearLayer1: TMenuItem;
    ClearEntireSection1: TMenuItem;
    normalsaphere1: TMenuItem;
    ools2: TMenuItem;
    N10: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    N11: TMenuItem;
    RemoveRedundantVoxels1: TMenuItem;
    CnvView0: TPaintBox;
    Sites1: TMenuItem;
    PPMForUpdates1: TMenuItem;
    N13: TMenuItem;
    Help1: TMenuItem;
    VXLSEHelp1: TMenuItem;
    N14: TMenuItem;
    About1: TMenuItem;
    Options1: TMenuItem;
    Preferences1: TMenuItem;
    Display3dView1: TMenuItem;
    Section2: TMenuItem;
    Copyofthissection1: TMenuItem;
    Importfrommodel1: TMenuItem;
    Flip1: TMenuItem;
    N15: TMenuItem;
    Mirror1: TMenuItem;
    Nudge1: TMenuItem;
    FlipZswitchFrontBack1: TMenuItem;
    FlipXswitchRightLeft1: TMenuItem;
    FlipYswitchTopBottom1: TMenuItem;
    MirrorBottomToTop1: TMenuItem;
    MirrorTopToBottom1: TMenuItem;
    N16: TMenuItem;
    MirrorLeftToRight1: TMenuItem;
    MirrorRightToLeft1: TMenuItem;
    N17: TMenuItem;
    MirrorBackToFront1: TMenuItem;
    Nudge1Left1: TMenuItem;
    Nudge1Right1: TMenuItem;
    Nudge1up1: TMenuItem;
    Nudge1Down1: TMenuItem;
    Palette1: TMenuItem;
    iberianSunPalette1: TMenuItem;
    RedAlert2Palette1: TMenuItem;
    Custom1: TMenuItem;
    N18: TMenuItem;
    blank1: TMenuItem;
    SpeedButton12: TSpeedButton;
    N19: TMenuItem;
    DarkenLightenValue1: TMenuItem;
    N110: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    ClearVoxelColour1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    ClearUndoSystem1: TMenuItem;
    IconList: TImageList;
    PasteFull1: TMenuItem;
    Paste1: TMenuItem;
    ColourScheme1: TMenuItem;
    N22: TMenuItem;
    iberianSun2: TMenuItem;
    RedAlert22: TMenuItem;
    YurisRevenge1: TMenuItem;
    blank2: TMenuItem;
    blank3: TMenuItem;
    blank4: TMenuItem;
    PalPack1: TMenuItem;
    N23: TMenuItem;
    About2: TMenuItem;
    N24: TMenuItem;
    Allied1: TMenuItem;
    Soviet1: TMenuItem;
    Yuri1: TMenuItem;
    Blue2: TMenuItem;
    Brick1: TMenuItem;
    Brown11: TMenuItem;
    Brown21: TMenuItem;
    Grayscale1: TMenuItem;
    Green2: TMenuItem;
    NoUnlit1: TMenuItem;
    Remap1: TMenuItem;
    Red2: TMenuItem;
    Yellow1: TMenuItem;
    blank5: TMenuItem;
    blank6: TMenuItem;
    blank7: TMenuItem;
    blank8: TMenuItem;
    blank9: TMenuItem;
    blank10: TMenuItem;
    blank11: TMenuItem;
    blank12: TMenuItem;
    blank13: TMenuItem;
    blank14: TMenuItem;
    blank15: TMenuItem;
    blank16: TMenuItem;
    blank17: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton14: TToolButton;
    OpenDialog1: TOpenDialog;
    DisableDrawPreview1: TMenuItem;
    SmoothNormals1: TMenuItem;
    Disable3dView1: TMenuItem;
    ReplaceColours1: TMenuItem;
    Normals3: TMenuItem;
    Colours2: TMenuItem;
    VoxelTexture1: TMenuItem;
    N12: TMenuItem;
    test1: TMenuItem;
    Scripts1: TMenuItem;
    SpinButton3: TSpinButton;
    SpinButton1: TSpinButton;
    SpinButton2: TSpinButton;
    TopBarImageHolder: TImage;
    MainViewPopup: TPopupMenu;
    Magnification1: TMenuItem;
    N1x1: TMenuItem;
    N3x1: TMenuItem;
    N5x1: TMenuItem;
    N7x1: TMenuItem;
    N9x1: TMenuItem;
    N10x1: TMenuItem;
    N131: TMenuItem;
    N15x1: TMenuItem;
    N17x1: TMenuItem;
    N19x1: TMenuItem;
    N21x1: TMenuItem;
    N23x1: TMenuItem;
    N25x1: TMenuItem;
    ToolButton5: TToolButton;
    ToolButton12: TToolButton;
    CubedAutoNormals1: TMenuItem;
    SpeedButton13: TSpeedButton;
    Others1: TMenuItem;
    blank18: TMenuItem;
    MirrorFrontToBack2: TMenuItem;
    Display3DWindow1: TMenuItem;
    ProjectSVN1: TMenuItem;
    XPManifest1: TXPManifest;
    Animation1: TMenuItem;
    SpeedButton14: TSpeedButton;
    TSPalettes: TMenuItem;
    RA2Palettes: TMenuItem;
    O3DModelizer1: TMenuItem;
    Import1: TMenuItem;
    N20: TMenuItem;
    using3ds2vxl1: TMenuItem;
    MainMenu1: TMainMenu;
    UpdateSchemes1: TMenuItem;
    OpenDialog3ds2vxl: TOpenDialog;
    Importfromamodelusing3ds2vxl1: TMenuItem;
    CropSection1: TMenuItem;
    AutoUpdate1: TMenuItem;
    RepairProgram1: TMenuItem;
    Display1: TMenuItem;
    FillMode1: TMenuItem;
    DisplayFMSolid: TMenuItem;
    DisplayFMWireframe: TMenuItem;
    DisplayFMPointCloud: TMenuItem;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    RemoveRedundantVoxelsB1: TMenuItem;
    ImagewithHeightmap1: TMenuItem;
    QualityAnalysis1: TMenuItem;
    opologyAnalysis1: TMenuItem;
    Export1: TMenuItem;
    Isosurfacesiso1: TMenuItem;
    SaveDialogExport: TSaveDialog;
    IncreaseResolution1: TMenuItem;
    Shape1: TMenuItem;
    FillUselessInternalGaps1: TMenuItem;
    FillUselessInternalCavesVeryStrict1: TMenuItem;
    N26: TMenuItem;
    Apollo1: TMenuItem;
    N25: TMenuItem;
    UpdatePaletteList1: TMenuItem;
    RotateModel1: TMenuItem;
    Pitch901: TMenuItem;
    Pitch902: TMenuItem;
    Roll901: TMenuItem;
    Roll902: TMenuItem;
    Yaw901: TMenuItem;
    Yaw902: TMenuItem;
    N27: TMenuItem;
    MaintainDimensions1: TMenuItem;
    procedure MaintainDimensions1Click(Sender: TObject);
    procedure UpdatePaletteList1Click(Sender: TObject);
    procedure FillUselessInternalCavesVeryStrict1Click(Sender: TObject);
    procedure FillUselessInternalGaps1Click(Sender: TObject);
    procedure IncreaseResolution1Click(Sender: TObject);
    procedure Isosurfacesiso1Click(Sender: TObject);
    procedure opologyAnalysis1Click(Sender: TObject);
    procedure ImagewithHeightmap1Click(Sender: TObject);
    procedure DisplayFMPointCloudClick(Sender: TObject);
    procedure DisplayFMWireframeClick(Sender: TObject);
    procedure DisplayFMSolidClick(Sender: TObject);
    procedure RepairProgram1Click(Sender: TObject);
    procedure AutoUpdate1Click(Sender: TObject);
    procedure CropSection1Click(Sender: TObject);
    procedure Importfromamodelusing3ds2vxl1Click(Sender: TObject);
    procedure UpdateSchemes1Click(Sender: TObject);
    procedure using3ds2vxl1Click(Sender: TObject);
    procedure O3DModelizer1Click(Sender: TObject);
    procedure ProjectSVN1Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure NewAutoNormals1Click(Sender: TObject);
    procedure Display3DWindow1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Open1Click(Sender: TObject);
    procedure OpenVoxelInterface(const _Filename: string);
    procedure CnvView0Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ChangeCaption(Filename : boolean);
    procedure CnvView1Paint(Sender: TObject);
    procedure CnvView2Paint(Sender: TObject);
    Procedure SetIsEditable(Value : boolean);
    Procedure RefreshAll;
    Procedure SetupSections;
    procedure SectionComboChange(Sender: TObject);
    procedure Full1Click(Sender: TObject);
    procedure CrossSection1Click(Sender: TObject);
    procedure EmphasiseDepth1Click(Sender: TObject);
    Procedure SetViewMode(VM : EViewMode);
    Procedure SetSpectrum(SP : ESpectrumMode);
    procedure Colours1Click(Sender: TObject);
    procedure Normals1Click(Sender: TObject);
    procedure cnvPalettePaint(Sender: TObject);
    procedure SetActiveColor(Value : integer; CN : boolean);
    procedure SetActiveNormal(Value : integer; CN : boolean);
    Procedure SetActiveCN(Value : integer);
    procedure ScrollBar1Change(Sender: TObject);
    procedure setupscrollbars;
    procedure FormShow(Sender: TObject);
    procedure cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShowUsedColoursNormals1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OGL3DPreviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure OGL3DPreviewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OGL3DPreviewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DebugMode1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btn3DRotateXClick(Sender: TObject);
    Procedure SetRotationAdders;
    procedure btn3DRotateX2Click(Sender: TObject);
    procedure btn3DRotateY2Click(Sender: TObject);
    procedure btn3DRotateYClick(Sender: TObject);
    procedure spin3DjmpChange(Sender: TObject);
    procedure BackgroundColour1Click(Sender: TObject);
    procedure extColour1Click(Sender: TObject);
    procedure ClearRemapClicks;
    procedure Gold1Click(Sender: TObject);
    procedure Red1Click(Sender: TObject);
    procedure Orange1Click(Sender: TObject);
    procedure Magenta1Click(Sender: TObject);
    procedure Purple1Click(Sender: TObject);
    procedure Blue1Click(Sender: TObject);
    procedure Green1Click(Sender: TObject);
    procedure DarkSky1Click(Sender: TObject);
    procedure White1Click(Sender: TObject);
    procedure Front1Click(Sender: TObject);
    procedure Back1Click(Sender: TObject);
    procedure LEft1Click(Sender: TObject);
    procedure Right1Click(Sender: TObject);
    procedure Bottom1Click(Sender: TObject);
    procedure op1Click(Sender: TObject);
    procedure Cameo1Click(Sender: TObject);
    procedure Cameo21Click(Sender: TObject);
    procedure Cameo31Click(Sender: TObject);
    procedure Cameo41Click(Sender: TObject);
    procedure CnvView2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CnvView1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CnvView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CnvView1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CnvView2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CnvView2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CnvView0MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure UpdateCursor(P : TVector3i; Repaint : Boolean);
    procedure XCursorBarChange(Sender: TObject);
    Procedure CursorReset;
    Procedure CursorResetNoMAX;
    Procedure SetupStatusBar;
    procedure CnvView0MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lblView1Click(Sender: TObject);
    procedure lblView2Click(Sender: TObject);
    procedure mnuDirectionPopupPopup(Sender: TObject);
    procedure mnuEditClick(Sender: TObject);
    procedure mnuDirTowardsClick(Sender: TObject);
    procedure mnuDirAwayClick(Sender: TObject);
    procedure DoAfterLoadingThings;
    procedure Brush_1Click(Sender: TObject);
    procedure Brush_2Click(Sender: TObject);
    procedure Brush_3Click(Sender: TObject);
    procedure Brush_4Click(Sender: TObject);
    procedure Brush_5Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    Procedure SetVXLTool(VXLTool_ : Integer);
    procedure CnvView0MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure VoxelHeader1Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    Procedure UpdateUndo_RedoState;
    procedure mnuBarUndoClick(Sender: TObject);
    procedure mnuBarRedoClick(Sender: TObject);
    procedure updatenormals1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure normalsaphere1Click(Sender: TObject);
    procedure RemoveRedundantVoxels1Click(Sender: TObject);
    procedure ClearEntireSection1Click(Sender: TObject);
    procedure CnCSource1Click(Sender: TObject);
    procedure PPMForUpdates1Click(Sender: TObject);
    procedure LoadSite(Sender: TObject);
    procedure OpenHyperlink(HyperLink: PChar);
    procedure VXLSEHelp1Click(Sender: TObject);
    procedure Display3dView1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FlipZswitchFrontBack1Click(Sender: TObject);
    procedure FlipXswitchRightLeft1Click(Sender: TObject);
    procedure FlipYswitchTopBottom1Click(Sender: TObject);
    procedure MirrorBottomToTop1Click(Sender: TObject);
    procedure MirrorLeftToRight1Click(Sender: TObject);
    procedure MirrorBackToFront1Click(Sender: TObject);
    procedure MirrorFrontToBack1Click(Sender: TObject);
    procedure Nudge1Left1Click(Sender: TObject);
    procedure RotateYawNegativeClick(Sender: TObject);
    procedure RotateYawPositiveClick(Sender: TObject);
    procedure RotatePitchNegativeClick(Sender: TObject);
    procedure RotatePitchPositiveClick(Sender: TObject);
    procedure RotateRollNegativeClick(Sender: TObject);
    procedure RotateRollPositiveClick(Sender: TObject);
    procedure Section2Click(Sender: TObject);
    procedure Copyofthissection1Click(Sender: TObject);
    procedure BuildReopenMenu;
    procedure mnuHistoryClick(Sender: TObject);
    procedure BarReopenClick(Sender: TObject);
    procedure iberianSunPalette1Click(Sender: TObject);
    procedure RedAlert2Palette1Click(Sender: TObject);
    Procedure LoadPalettes;
    procedure blank1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Function CheckVXLChanged: boolean;
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
    Procedure SetDarkenLighten(Value : integer);
    procedure N110Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N31Click(Sender: TObject);
    procedure N41Click(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ClearLayer1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure ClearUndoSystem1Click(Sender: TObject);
    procedure PasteFull1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    function CreateSplitterMenuItem: TMenuItem;
    function UpdateCScheme : integer;
    function LoadCScheme : integer;
    procedure blank2Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
    procedure EmptyVoxel1Click(Sender: TObject);
    procedure EmptyVoxel2Click(Sender: TObject);
    Procedure NewVFile(Game : integer);
    Procedure SetCursor;
    procedure DisableDrawPreview1Click(Sender: TObject);
    procedure SmoothNormals1Click(Sender: TObject);
    procedure VoxelTexture1Click(Sender: TObject);
    procedure test1Click(Sender: TObject);
    function GetVoxelImportedBy3ds2vxl(var _Destination: string): boolean;
    procedure ImportSectionFromVoxel(const _Filename: string);
    procedure Importfrommodel1Click(Sender: TObject);
    procedure Resize1Click(Sender: TObject);
    procedure SpinButton3UpClick(Sender: TObject);
    procedure SpinButton3DownClick(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure SpinButton2DownClick(Sender: TObject);
    procedure SpinButton2UpClick(Sender: TObject);
    procedure FullResize1Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    Procedure SelectCorrectPalette;
    Procedure SelectCorrectPalette2(Palette : String);
    procedure ToolButton13Click(Sender: TObject);
    Procedure CreateVxlError(v,n : Boolean);
    procedure N1x1Click(Sender: TObject);
    procedure CubedAutoNormals1Click(Sender: TObject);
    procedure SpeedButton13Click(Sender: TObject);
    procedure UpdatePositionStatus(x,y,z : integer);
    procedure AutoRepair(const _Filename: string; _ForceRepair: boolean = false);
    procedure RemoveRedundantVoxelsB1Click(Sender: TObject);
  private
     { Private declarations }
     RemapColour : TVector3f;
     Xcoord, Ycoord, Zcoord : Integer;
     MouseButton : Integer;
     ValidLastClick : boolean;
     procedure Idle(Sender: TObject; var Done: Boolean);
     procedure BuildUsedColoursArray;
     function CharToStr: string;
     procedure ApplyPalette(const _Filename: string);
     procedure UncheckFillMode;
  public
    { Public declarations }
    {IsEditable,}IsVXLLoading : boolean;
     ShiftPressed : boolean;
     AltPressed : boolean;
     p_Frm3DPreview : PFrm3DPReview;
     p_Frm3DModelizer: PFrm3DModelizer;
     Document : TVoxelDocument;
     Env : TRenderEnvironment;
     Actor : PActor;
     Camera : TCamera;
     CustomSchemeControl : TCustomSchemeControl;
     PaletteControl : TPaletteControl;
     SiteList: TSitesList;
     {$ifdef DEBUG_FILE or TEXTURE_DEBUG}
     DebugFile: TDebugFile;
     {$endif}
     SelectedZoomOption: TMenuItem;
     procedure UpdateRenderingCounters;
     procedure SetVoxelChanged(_Value: boolean);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses FormHeaderUnit, LoadForm, FormNewSectionSizeUnit, FormPalettePackAbout, HVA,
   FormReplaceColour, FormVoxelTexture, FormBoundsManager, FormImportSection,
   FormFullResize, FormPreferences, FormVxlError, Config, ActorActionController,
   ModelUndoEngine, ModelVxt, Constants, mouse, Math, FormAutoNormals, pause,
   FormRepairAssistant, GlConstants, FormHeightmap, FormTopologyAnalysis, Voxel,
   IsoSurfaceFile, FillUselessGapsTool, TopologyFixer, FormNewVxlUnit, Registry,
   VoxelUndoEngine, GlobalVars, VoxelDocumentBank, ModelBank, TextureBank, Normals,
   HVABank, VoxelBank, CustomScheme, BasicConstants, ImageIOUtils, INIFiles,
   Voxel_Engine, CommunityLinks;

procedure TFrmMain.FormCreate(Sender: TObject);
var
   i : integer;
begin
   // 1.32: Debug adition
   {$ifdef DEBUG_FILE or TEXTURE_DEBUG}
   DebugFile := TDebugFile.Create(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'debugdev.txt');
   DebugFile.Add('FrmMain: FormCreate');
   {$endif}

   // 1.32: Shortcut aditions
   ShiftPressed := false;
   AltPressed := false;
   ValidLastClick := false;

   CnvView[0] := @CnvView0;
   CnvView[1] := @CnvView1;
   CnvView[2] := @CnvView2;

   lblView[0] := @lblView0;
   lblView[1] := @lblView1;
   lblView[2] := @lblView2;

   mnuReopen := @ReOpen1;
   BuildReopenMenu;
   Height := 768;

   if not FileExists(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'palettes\TS\unittem.pal') then
   begin
      AutoRepair(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'palettes\TS\unittem.pal');
   end;
   if (not FileExists(ExtractFileDir(ParamStr(0)) + '\images\pause.bmp')) then
   begin
      AutoRepair(ExtractFileDir(ParamStr(0)) + '\images\pause.bmp');
   end;
   if (not FileExists(ExtractFileDir(ParamStr(0)) + '\images\play.bmp')) then
   begin
      AutoRepair(ExtractFileDir(ParamStr(0)) + '\images\play.bmp');
   end;
   // ensure that ocl scripts exists
   if (not FileExists(ExtractFileDir(ParamStr(0)) + '\opencl\origami.cl')) then
   begin
      AutoRepair(ExtractFileDir(ParamStr(0)) + '\opencl\origami.cl');
   end;

   GlobalVars.Render := TRender.Create(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'shaders');
   GlobalVars.Documents := TVoxelDocumentBank.Create;
   GlobalVars.VoxelBank := TVoxelBank.Create;
   GlobalVars.HVABank := THVABank.Create;
   GlobalVars.ModelBank := TModelBank.Create;
   GlobalVars.TextureBank := TTextureBank.Create;
   Document := (Documents.AddNew)^;

   for i := 0 to 2 do
   begin
      cnvView[i].ControlStyle := cnvView[i].ControlStyle + [csOpaque];
      lblView[i].ControlStyle := lblView[i].ControlStyle + [csOpaque];
   end;

   // 1.4x New Render starts here.
   GlobalVars.ActorController := TActorActionController.Create;
   GlobalVars.ModelUndoEngine := TModelUndoRedo.Create;
   GlobalVars.ModelRedoEngine := TModelUndoRedo.Create;

   Env := (GlobalVars.Render.AddEnvironment(OGL3DPreview.Handle,OGL3DPreview.Width,OGL3DPreview.Height))^;
   Actor := Env.AddActor;
   Camera := Env.CurrentCamera^;
   GlobalVars.Render.SetFPS(Configuration.FPSCap);
   GlobalVars.Render.EnableOpenCL := Configuration.OpenCL;
   Env.SetBackgroundColour(Configuration.Canvas3DBackgroundColor);
   Env.EnableShaders(false);
   Env.AddRenderingVariable('Voxels','0');
   SetIsEditable(False);
   //FrmMain.DoubleBuffered := true;
   //MainPaintPanel.DoubleBuffered := true;
   LeftPanel.DoubleBuffered := true;
   RightPanel.DoubleBuffered := true;

   SetActiveColor(16,true);
   SetActiveNormal(0,false);

   ChangeCaption(false);

   // Resets the 3 views on the right sidebar if the res is too low for 203 high ones.
   if RightPanel.Height < lblView1.Height+CnvView1.Height+lblView2.Height+CnvView2.Height+lbl3dview.Height+Panel7.Height+OGL3DPreview.Height then
   begin
      i := RightPanel.Height - (lblView1.Height+lblView2.Height+lbl3dview.Height+Panel7.Height);

      i := trunc(i / 3);
      CnvView1.Height := i;
      CnvView2.Height := i;
      OGL3DPreview.Height := i;
   end;

   // 1.2 Enable Idle only on certain situations.
   Application.OnIdle := nil;

   p_Frm3DPreview := nil;
   p_Frm3DModelizer := nil;

   Application.OnDeactivate := FormDeactivate;
   Application.OnActivate := FormActivate;
   Application.OnMinimize := FormDeactivate;
   Application.OnRestore := FormActivate;

   // Setting up nudge shortcuts.
   Nudge1Left1.ShortCut := ShortCut(VK_LEFT,[ssShift,ssCtrl]);
   Nudge1Right1.ShortCut := ShortCut(VK_RIGHT,[ssShift,ssCtrl]);
   Nudge1Up1.ShortCut := ShortCut(VK_UP,[ssShift,ssCtrl]);
   Nudge1Down1.ShortCut := ShortCut(VK_DOWN,[ssShift,ssCtrl]);

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FormCreate Loaded');
   // If you don't have Delphi 2006 or better, disable the line below!
   ReportMemoryLeaksOnShutdown := true;
   {$endif}
end;

procedure TFrmMain.FormShow(Sender: TObject);
var
   frm: TLoadFrm;
   l: Integer;
   Reg: TRegistry;
   LatestVersion: string;
   VoxelName: string;
begin
   frm := TLoadFrm.Create(Self);
   if testbuild then
      frm.Label4.Caption := APPLICATION_VER + ' TB '+testbuildversion
   else
      frm.Label4.Caption := APPLICATION_VER;

   // 1.2:For future compatibility with other OS tools, we are
   // using the registry keys to confirm its existance.
   Reg :=TRegistry.Create;
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   if Reg.OpenKey('Software\CnC Tools\VXLSEIII\',true) then
   begin
      LatestVersion := Reg.ReadString('Version');
      if APPLICATION_VER > LatestVersion then
      begin
         Reg.WriteString('Path',ParamStr(0));
         Reg.WriteString('Version',APPLICATION_VER);
      end;
      Reg.CloseKey;
   end;
   Reg.Free;

   frm.Show;
   l := 0;
   while l < 25 do
   begin
      if l = 0 then begin frm.Loading.Caption := 'Loading: 3rd Party Palettes';frm.Loading.Refresh; LoadPalettes; end;
      if l = 10 then begin frm.Loading.Caption := 'Loading: Colour Schemes'; frm.Loading.Refresh; LoadCScheme; end;
      if l = 23 then begin frm.Loading.Caption := 'Finished Loading'; delay(50); end;
      l := l + 1;
      delay(2);
   end;
   frm.Close;
   frm.Free;
   if (not FileExists(ExtractFileDir(ParamStr(0)) + '\commlist.ini')) then
   begin
      AutoRepair(ExtractFileDir(ParamStr(0)) + '\commlist.ini');
   end;
   LoadCommunityLinks;

   WindowState := wsMaximized;
//  refresh;
   setupscrollbars;
   UpdateUndo_RedoState;
   VXLTool := 4;

   if ParamCount > 0 then
   begin
      VoxelName := GetParamStr;
      If FileExists(VoxelName) then
      Begin
         IsVXLLoading := true;
         Application.OnIdle := nil;
         SetIsEditable(LoadVoxel(Document,VoxelName));
         if IsEditable then
         begin
            if p_Frm3DPreview <> nil then
            begin
               p_Frm3DPreview^.SpFrame.MaxValue := 1;
               p_Frm3DPreview^.SpStopClick(nil);
            end;
            if p_Frm3DModelizer <> nil then
            begin
               p_Frm3DModelizer^.SpFrame.MaxValue := 1;
               p_Frm3DModelizer^.SpStopClick(nil);
            end;
            DoAfterLoadingThings;
         end;
         IsVXLLoading := false;
      End;
   end;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FormShow Loaded');
   {$endif}
end;

procedure TFrmMain.Idle(Sender: TObject; var Done: Boolean);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Idle');
   {$endif}
   if IsEditable then
   begin
      GlobalVars.Render.Render;
   end;
   Done := false;
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FormResize');
   {$endif}
   CentreViews;
   setupscrollbars;
end;

procedure TFrmMain.Open1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Open1Click');
   {$endif}
   if OpenVXLDialog.Execute then
   begin
      OpenVoxelInterface(OpenVXLDialog.FileName);
   end;
end;

procedure TFrmMain.OpenVoxelInterface(const _Filename: string);
begin
   SetIsEditable(false);
   sleep(50);
   application.ProcessMessages;
   IsVXLLoading := true;
   Application.OnIdle := nil;
   CheckVXLChanged;

   if LoadVoxel(Document,_Filename) then
   begin
      if p_Frm3DPreview <> nil then
      begin
         p_Frm3DPreview^.SpFrame.MaxValue := 1;
         p_Frm3DPreview^.SpStopClick(nil);
      end;
      if p_Frm3DModelizer <> nil then
      begin
         p_Frm3DModelizer^.SpFrame.MaxValue := 1;
         p_Frm3DModelizer^.SpStopClick(nil);
      end;
      DoAfterLoadingThings;
      SetIsEditable(true);
      RefreshAll;
   end;
   IsVXLLoading := false;
end;

Procedure TFrmMain.SetIsEditable(Value : boolean);
var
i : integer;
begin
   IsEditable := value;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetIsEditable');
   {$endif}

   // Clear tempview:
   TempView.Data_no := 0;
   Setlength(TempView.Data,0);
   // Invalidate mouse click.
   ValidLastClick := false;

   Env.IsEnabled := IsEditable;

   for i := 0 to 2 do
   begin
      cnvView[i].Enabled := isEditable;
     //lblView[i].Enabled := isEditable;
   end;

   if iseditable then
   begin
      for i := 0 to 2 do
      begin
         lblView[i].Color := clNavy;
         lblView[i].Font.Color := clYellow;
         lblView[i].Refresh;
      end;

      lblSection.Color := clNavy;
      lblSection.Font.Color := clYellow;
      lblTools.Color := clNavy;
      lblTools.Font.Color := clYellow;
      lblPalette.Color := clNavy;
      lblPalette.Font.Color := clYellow;
      lbl3dview.Color := clNavy;
      lbl3dview.Font.Color := clYellow;
      lblLayer.Color := clNavy;
      lblLayer.Font.Color := clYellow;
      lblBrush.Color := clNavy;
      lblBrush.Font.Color := clYellow;

      lblBrush.refresh;
      lblLayer.refresh;
      lbl3dview.refresh;
      lblSection.refresh;
      lblTools.refresh;
      lblPalette.refresh;

      If SpectrumMode = ModeColours then
         SetActiveColor(ActiveColour,true);
      cnvPalette.refresh;

      // 1.32 Aditions:
      cnvView0.OnMouseDown := cnvView0MouseDown;
      cnvView0.OnMouseUp := cnvView0MouseUp;
      cnvView0.OnMouseMove := cnvView0MouseMove;
      cnvView0.OnPaint := cnvView0Paint;
      cnvView1.OnMouseDown := cnvView1MouseDown;
      cnvView1.OnMouseUp := cnvView1MouseUp;
      cnvView1.OnMouseMove := cnvView1MouseMove;
      cnvView1.OnPaint := cnvView1Paint;
      cnvView2.OnMouseDown := cnvView2MouseDown;
      cnvView2.OnMouseUp := cnvView2MouseUp;
      cnvView2.OnMouseMove := cnvView2MouseMove;
      cnvView2.OnPaint := cnvView2Paint;
      oGL3DPreview.OnMouseDown := ogl3DPreviewMouseDown;
      oGL3DPreview.OnMouseUp := ogl3DPreviewMouseUp;
      oGL3DPreview.OnMouseMove := ogl3DPreviewMouseMove;
   end
   else
   begin
      // We'll force a closure of the 3D Preview window.
      if p_Frm3DPreview <> nil then
      begin
         p_Frm3DPreview^.Release;
         p_Frm3DPreview := nil;
      end;
      // We'll force a closure of the 3D MOdelizer window.
      if p_Frm3DModelizer <> nil then
      begin
         p_Frm3DModelizer^.Release;
         p_Frm3DModelizer := nil;
      end;

      // 1.32 Aditions:
      cnvView0.OnMouseDown := nil;
      cnvView0.OnMouseUp := nil;
      cnvView0.OnMouseMove := nil;
      cnvView0.OnPaint := nil;
      cnvView1.OnMouseDown := nil;
      cnvView1.OnMouseUp := nil;
      cnvView1.OnMouseMove := nil;
      cnvView1.OnPaint := nil;
      cnvView2.OnMouseDown := nil;
      cnvView2.OnMouseUp := nil;
      cnvView2.OnMouseMove := nil;
      cnvView2.OnPaint := nil;
      oGL3DPreview.OnMouseDown := nil;
      oGL3DPreview.OnMouseUp := nil;
      oGL3DPreview.OnMouseMove := nil;
   end;

   View1.Visible := IsEditable;
   Section1.Visible := IsEditable;
   ools2.Visible := IsEditable;
   Edit1.Visible := IsEditable;
   Scripts1.Visible := IsEditable;

   Export1.Enabled := IsEditable;

   SectionCombo.Enabled := IsEditable;
   BarSaveAs.Enabled := IsEditable;
   ToolButton5.Enabled := IsEditable;
   ToolButton7.Enabled := IsEditable;
   ToolButton3.Enabled := IsEditable;
   ToolButton13.Enabled := IsEditable;
   ToolButton11.Enabled := IsEditable;
   ToolButton1.Enabled := IsEditable;
   ToolButton2.Enabled := IsEditable;

   btn3DRotateY.Enabled := IsEditable;
   btn3DRotateY2.Enabled := IsEditable;
   btn3DRotateX.Enabled := IsEditable;
   btn3DRotateX2.Enabled := IsEditable;
   spin3Djmp.Enabled := IsEditable;
   SpeedButton1.Enabled := IsEditable;
   SpeedButton2.Enabled := IsEditable;
   SpeedButton3.Enabled := IsEditable;
   SpeedButton4.Enabled := IsEditable;
   SpeedButton5.Enabled := IsEditable;
   SpeedButton6.Enabled := IsEditable;
   SpeedButton7.Enabled := IsEditable;
   SpeedButton8.Enabled := IsEditable;
   SpeedButton9.Enabled := IsEditable;
   SpeedButton10.Enabled := IsEditable;
   SpeedButton11.Enabled := IsEditable;
   SpeedButton12.Enabled := IsEditable;
   SpeedButton13.Enabled := IsEditable;
   SpeedButton14.Enabled := IsEditable;

   Brush_1.Enabled := IsEditable;
   Brush_2.Enabled := IsEditable;
   Brush_3.Enabled := IsEditable;
   Brush_4.Enabled := IsEditable;
   Brush_5.Enabled := IsEditable;

   pnlLayer.Enabled := IsEditable;

   mnuDirectionPopup.AutoPopup := IsEditable;

   Magnification1.Enabled := IsEditable;

   N6.Enabled := IsEditable;
   SaveAs1.Enabled := IsEditable;
   Save1.Enabled := IsEditable;

   // Temporary
   Animation1.Enabled := false;

   if not iseditable then
   begin
      OGL3DPreview.Refresh;
   end;
end;

procedure TFrmMain.DoAfterLoadingThings;
var
   v,n : boolean;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: DoAfterLoadingThings');
   {$endif}
   ChangeCaption(true);

   v := not IsVoxelValid;
   n := HasNormalsBug;

   if v or n then
      CreateVxlError(v,n);

   SetupSections;
   SetViewMode(ModeEmphasiseDepth);
   SetSpectrum(SpectrumMode);
   SetActiveNormal(ActiveNormal,true);
   // 1.2b: Refresh Show Use Colours
   if UsedColoursOption then
      BuildUsedColoursArray;
   // End of 1.2b adition
   setupscrollbars;
   SetupStatusBar;
   CursorReset;
   ResetUndoRedo;
   UpdateUndo_RedoState;
   SelectCorrectPalette;
   PaintPalette(cnvPalette,True);
   if High(Actor^.Models) >= 0 then
   begin
      Actor^.Clear;
      GlobalVars.ActorController.TerminateObject(Actor);
   end;
   Actor^.Add(Document.ActiveSection,Document.Palette,C_QUALITY_CUBED);
   GlobalVars.ActorController.DoLoadModel(Actor, C_QUALITY_CUBED);
   GlobalVars.ActorController.SetBaseObject(Actor);
   UpdateRenderingCounters;
   if p_Frm3DPreview <> nil then
   begin
      if High(p_Frm3DPreview^.Actor^.Models) >= 0 then
      begin
         GlobalVars.ModelUndoEngine.Remove(p_Frm3DPreview^.Actor.Models[0]^.ID);
         p_Frm3DPreview^.Actor^.Clear;
         GlobalVars.ActorController.TerminateObject(p_Frm3DPreview^.Actor);
      end;
      p_Frm3DPreview^.Actor^.Clone(Document.ActiveVoxel,Document.ActiveHVA,Document.Palette,p_Frm3DPreview^.GetQualityModel);
      GlobalVars.ActorController.DoLoadModel(p_Frm3DPreview^.Actor, p_Frm3DPreview^.GetQualityModel);
      GlobalVars.ActorController.SetBaseObject(p_Frm3DPreview^.Actor);
      p_Frm3DPreview^.SetActorModelTransparency;
      p_Frm3DPreview^.UpdateQualityUI;
      p_Frm3DPreview^.UpdateRenderingCounters;

      p_Frm3DPreview^.SpFrame.MaxValue := Document.ActiveHVA^.Header.N_Frames;
      p_Frm3DPreview^.SpFrame.Value := 1;
   end;
   if p_Frm3DModelizer <> nil then
   begin
      if High(p_Frm3DModelizer^.Actor^.Models) >= 0 then
      begin
         GlobalVars.ModelUndoEngine.Remove(p_Frm3DModelizer^.Actor.Models[0]^.ID);
         p_Frm3DModelizer^.Actor^.Clear;
         GlobalVars.ActorController.TerminateObject(p_Frm3DModelizer^.Actor);
      end;
      p_Frm3DModelizer^.Actor^.Clone(Document.ActiveVoxel,Document.ActiveHVA,Document.Palette,p_Frm3DModelizer^.GetQualityModel);
      GlobalVars.ActorController.DoLoadModel(p_Frm3DModelizer^.Actor, p_Frm3DModelizer^.GetQualityModel);
      (p_Frm3DModelizer^.Actor^.Models[0]^ as TModelVxt).MakeVoxelHVAIndependent;
      GlobalVars.ActorController.SetBaseObject(p_Frm3DModelizer^.Actor);
      p_Frm3DModelizer^.SetActorModelTransparency;
      p_Frm3DModelizer^.UpdateQualityUI;
      p_Frm3DModelizer^.UpdateRenderingCounters;

      p_Frm3DModelizer^.SpFrame.MaxValue := Document.ActiveHVA^.Header.N_Frames;
      p_Frm3DModelizer^.SpFrame.Value := 1;
   end;
   if not Display3dView1.Checked then
      if @Application.OnIdle = nil then
         Application.OnIdle := Idle
   else
      Application.OnIdle := nil;

   RefreshAll;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if CheckVXLChanged then
   begin
      if p_Frm3DPreview <> nil then
      begin
         try
            p_Frm3DPreview^.Release;
         except;
         end;
         p_Frm3DPreview := nil;
      end;
      if p_Frm3DModelizer <> nil then
      begin
         try
            p_Frm3DModelizer^.Release;
         except;
         end;
         p_Frm3DModelizer := nil;
      end
   end
   else
   begin
      Action := caNone;
   end;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   VoxelOpen := false;
   if IsEditable then
   begin
      GlobalVars.ModelUndoEngine.Remove(Actor^.Models[0]^.ID);
      GlobalVars.ActorController.TerminateObject(Actor);
   end;
   IsEditable := false;
   GlobalVars.ModelUndoEngine.Free;
   GlobalVars.ModelRedoEngine.Free;
   GlobalVars.ActorController.Free;
   GlobalVars.Render.Free;
   GlobalVars.Documents.Free;
   GlobalVars.VoxelBank.Free;
   GlobalVars.HVABank.Free;
   GlobalVars.ModelBank.Free;
   GlobalVars.TextureBank.Free;
   DeactivateRenderingContext;
   UpdateHistoryMenu;
   Configuration.SaveSettings;
   Configuration.Free;
   RA2Normals.Free;
   TSNormals.Free;
   CubeNormals.Free;
   CustomSchemeControl.Free;
   PaletteControl.Free;
   {$ifdef SPEED_TEST}
   GlobalVars.SpeedFile.Free;
   {$endif}
   {$ifdef MESH_TEST}
   GlobalVars.MeshFile.Free;
   {$endif}
   {$ifdef SMOOTH_TEST}
   GlobalVars.SmoothFile.Free;
   {$endif}
   {$ifdef ORIGAMI_TEST}
   GlobalVars.OrigamiFile.Free;
   {$endif}
   {$ifdef DEBUG_FILE or TEXTURE_DEBUG}
   DebugFile.Free;
   {$endif}
   GlobalVars.SysInfo.Free;

   //SetLength(ColourSchemes,0);
end;

Procedure TFrmMain.RefreshAll;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Refresh All');
   {$endif}
   RefreshViews;
   RepaintViews;
   if (Actor <> nil) and (not Display3dView1.Checked) then
   begin
      Actor^.RebuildActor;
      UpdateRenderingCounters;
   end;
   if p_Frm3DPreview <> nil then
   begin
      GlobalVars.ActorController.DoRebuildModel(p_Frm3DPreview^.Actor, p_Frm3DPreview^.GetQualityModel);
      //p_Frm3DPreview^.Actor^.RebuildActor;
      p_Frm3DPreview^.UpdateRenderingCounters;
   end;
end;

procedure TFrmMain.UpdateRenderingCounters;
begin
   if (Actor <> nil) then
      if High(Actor^.Models) >= 0 then
         if Actor^.Models[0] <> nil then
            if Actor^.Models[0]^.ModelType = C_MT_VOXEL then
            begin
               Env.RenderingVariableValues[0] := IntToStr((Actor^.Models[0]^ as TModelVxt).GetVoxelCount);
            end
            else
            begin
               Env.RenderingVariableValues[0] := IntToStr(Actor^.Models[0]^.GetVoxelCount);
            end;
end;

{------------------------------------------------------------------}
{------------------------------------------------------------------}

procedure TFrmMain.changecaption(Filename : boolean);
begin
   Caption := APPLICATION_TITLE + ' v' + APPLICATION_VER;

   if Filename then
   begin
      if VXLFilename = '' then
      begin
         Caption := Caption + ' [Untitled]';
      end
      else
      begin
         Caption := Caption + ' [' + extractfilename(VXLFilename) + ']';
      end;
      if VXLChanged then
      begin
         Caption := Caption  + '*';
      end;
   end;
end;

procedure TFrmMain.CnvView0Paint(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CnvView0Paint');
   {$endif}
   if Document.ActiveSection <> nil then
      PaintView2(0,true,CnvView[0],Document.ActiveSection^.View[0]);
end;

procedure TFrmMain.CnvView1Paint(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CnvView1Paint');
   {$endif}
   if Document.ActiveSection <> nil then
      PaintView2(1,false,CnvView[1],Document.ActiveSection^.View[1]);
end;

procedure TFrmMain.CnvView2Paint(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CnvView2Paint');
   {$endif}
   if Document.ActiveSection <> nil then
      PaintView2(2,false,CnvView[2],Document.ActiveSection^.View[2]);
end;

Procedure TFrmMain.SetupSections;
var
   i : integer;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Setup Sections');
   {$endif}
   SectionCombo.Clear;

   for i := 0 to (Document.ActiveVoxel^.Header.NumSections - 1) do
      SectionCombo.Items.Add(Document.ActiveVoxel^.Section[i].Name);
   SectionCombo.ItemIndex := CurrentSection;
end;

procedure TFrmMain.SectionComboChange(Sender: TObject);
begin
   if IsVXLLoading then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SectionComboChange');
   {$endif}

   CurrentSection := SectionCombo.ItemIndex;
   ChangeSection;
   CursorReset;
   if High(Actor^.Models) >= 0 then
      Actor^.Clear;
   Actor^.Add(Document.ActiveSection,Document.Palette,C_QUALITY_CUBED);
   UpdateRenderingCounters;
   if p_Frm3DPreview <> nil then
   begin
      p_Frm3DPreview^.SetActorModelTransparency;
      p_Frm3DPreview^.UpdateRenderingCounters;
   end;
   ResetUndoRedo;
   UpdateUndo_RedoState;

   RefreshAll;
end;

procedure TFrmMain.Full1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Full1Click');
   {$endif}
   SetViewMode(ModeFull);
   RepaintViews;
end;


procedure TFrmMain.CrossSection1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CrossSection1Click');
   {$endif}
   SetViewMode(ModeCrossSection);
   RepaintViews;
end;

procedure TFrmMain.EmphasiseDepth1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: EmphasiseDepth1Click');
   {$endif}
   SetViewMode(ModeEmphasiseDepth);
   RepaintViews;
end;

Procedure TFrmMain.SetViewMode(VM : EViewMode);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetViewMode');
   {$endif}

   Full1.checked := false;
   CrossSection1.checked := false;
   EmphasiseDepth1.checked := false;

   if VM = ModeFull then
      Full1.checked := true;

   if VM = ModeCrossSection then
      CrossSection1.checked := true;

   if VM = ModeEmphasiseDepth then
      EmphasiseDepth1.checked := true;

   ViewMode := VM;
end;

Procedure TFrmMain.SetSpectrum(SP : ESpectrumMode);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetSpectrum');
   {$endif}

   Normals1.checked := false;
   Colours1.checked := false;

   if SP = ModeNormals then
   begin
      Normals1.checked := true;
      Env.RenderNormals;
      if p_Frm3DPreview <> nil then
      begin
         p_Frm3DPreview^.Env.RenderNormals;
      end;
   end
   else
   begin
      Colours1.checked := true;
      Env.RenderColours;
      if p_Frm3DPreview <> nil then
      begin
         p_Frm3DPreview^.Env.RenderColours;
      end;
   end;

   SpectrumMode := SP;
   SetSpectrumMode;

   Document.ActiveSection^.View[0].Refresh;
   Document.ActiveSection^.View[1].Refresh;
   Document.ActiveSection^.View[2].Refresh;

   PaintPalette(cnvPalette,True);

   if not IsVXLLoading then
      RepaintViews;
end;

procedure TFrmMain.Colours1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Colours1Click');
   {$endif}
   SetSpectrum(ModeColours);
   SetActiveColor(ActiveColour,true);
end;

procedure TFrmMain.Normals1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Normals1Click');
   {$endif}
   SetSpectrum(ModeNormals);
   SetActiveNormal(ActiveNormal,true);
end;

procedure TFrmMain.cnvPalettePaint(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: cnvPalettePaint');
   {$endif}
   PaintPalette(cnvPalette,true);
end;

procedure TFrmMain.SetActiveColor(Value : integer; CN : boolean);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetActiveColour');
   {$endif}
   ActiveColour := Value;
   if CN then
   if SpectrumMode = ModeColours then
      SetActiveCN(Value);
end;

procedure TFrmMain.SetActiveNormal(Value : integer; CN : boolean);
var
   v : integer;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetActiveNormal');
   {$endif}
   v := Value;

   if ActiveNormalsCount > 0 then
      if v > ActiveNormalsCount-1 then
         v := ActiveNormalsCount-1; // normal too high

   ActiveNormal := v;

   if CN then
      if SpectrumMode = ModeNormals then
         SetActiveCN(V);
end;

Procedure TFrmMain.SetActiveCN(Value : integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetActiveCN');
   {$endif}
   if isEditable then
      pnlActiveColour.Color := GetVXLPaletteColor(Value)
   else
      pnlActiveColour.Color := colourtogray(GetVXLPaletteColor(Value));
   lblActiveColour.Caption := IntToStr(Value) + ' (0x' + IntToHex(Value,3) + ')';
   cnvPalette.Repaint;
end;

procedure TFrmMain.ScrollBar1Change(Sender: TObject);
var
x , y, width, height : integer;
begin
   if not isEditable then Exit;
   if not scrollbar_editable then Exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ScrollBar1Change');
   {$endif}

   Width := cnvView[0].Width;
   Height := cnvView[0].Height;
   with Document.ActiveSection^.Viewport[0] do
   begin
      x := Document.ActiveSection^.View[0].Width * Zoom;
      if ScrollBar1.enabled then
         if x > Width then
            Left := 0 - ((x - Width) div 2) -(ScrollBar1.Position - (ScrollBar1.Max div 2))
         else
            Left := ((Width - x) div 2) -(ScrollBar1.Position - (ScrollBar1.Max div 2));
      y := Document.ActiveSection^.View[0].Height * Zoom;

      if ScrollBar2.enabled then
         if y > Height then
            Top := 0 - ((y - Height) div 2) -(ScrollBar2.Position - (ScrollBar2.Max div 2))
         else
            Top := (Height - y) div 2 -(ScrollBar2.Position - (ScrollBar2.Max div 2));
   end;
   PaintView2(0,true,CnvView[0],Document.ActiveSection^.View[0]);
end;

procedure TFrmMain.SetupScrollBars;
begin
   ScrollBar1.Enabled := false;
   ScrollBar2.Enabled := false;

   if not isEditable then Exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetupScrollBars');
   {$endif}
   If (Document.ActiveSection^.View[0].Width * Document.ActiveSection^.Viewport[0].zoom) > cnvView[0].Width then
   begin
      scrollbar_editable := false;
      // showmessage(inttostr(ActiveSection.View[0].Width * ActiveSection.Viewport[0].zoom - cnvView[0].Width));
      ScrollBar2.Position := 0;
      ScrollBar1.max := Document.ActiveSection^.View[0].Width * Document.ActiveSection^.Viewport[0].zoom - cnvView[0].Width;
      ScrollBar1.Position := ScrollBar1.max div 2;
      ScrollBar1.Enabled := true;
      scrollbar_editable := true;
   end
   else
      ScrollBar1.Enabled := false;

   If (Document.ActiveSection^.View[0].Height * Document.ActiveSection^.Viewport[0].zoom) > cnvView[0].Height then
   begin
      scrollbar_editable := false;
      //showmessage(inttostr(ActiveSection.View[0].Height * ActiveSection.Viewport[0].zoom - cnvView[0].Height));
      ScrollBar2.Position := 0;
      ScrollBar2.max := Document.ActiveSection^.View[0].Height * Document.ActiveSection^.Viewport[0].zoom - cnvView[0].Height;
      ScrollBar2.Position := ScrollBar2.max div 2;
      ScrollBar2.Enabled := true;
      scrollbar_editable := true;
   end
   else
      ScrollBar2.Enabled := false;
end;

procedure TFrmMain.cnvPaletteMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   colwidth, rowheight: Real;
   i, j, idx: Integer;
begin
   If not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: cnvPaletteMouseUp');
   {$endif}
   colwidth := cnvPalette.Width / 8;
   rowheight := cnvPalette.Height / 32;
   i := Trunc(X / colwidth);
   j := Trunc(Y / rowheight);
   idx := (i * 32) + j;
   if SpectrumMode = ModeColours then
      SetActiveColor(idx,true)
   else if not (idx > ActiveNormalsCount-1) then
      SetActiveNormal(idx,true);
end;

// 1.2b: Build the Show Used Colours/Normals array
// Ripped from VXLSE II 2.2 SE OpenGL (never released version)
// Original function apparently made by Stucuk
procedure TFrmMain.BuildUsedColoursArray;
var
   x,y,z : integer;
   v : TVoxelUnpacked;
begin
   // This part is modified by Banshee. It's stupid to see it checking if x < 244 everytime
   for x := 0 to 244 do
   begin
      UsedColours[x] := false;
      UsedNormals[x] := false;
   end;
   for x := 245 to 255 do
      UsedColours[x] := false;


   for x := 0 to Document.ActiveSection^.Tailer.XSize -1 do
   for y := 0 to Document.ActiveSection^.Tailer.YSize -1 do
   for z := 0 to Document.ActiveSection^.Tailer.ZSize -1 do
   begin
      Document.ActiveSection^.GetVoxel(x,y,z,v);
      if v.Used then
      begin
         UsedColours[v.Colour] := true;
         UsedNormals[v.normal] := true;
      end;
   end;
end;

procedure TFrmMain.ShowUsedColoursNormals1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ShowUsedColoursNormals1');
   {$endif}
   ShowUsedColoursNormals1.Checked := not UsedColoursOption;
   UsedColoursOption := ShowUsedColoursNormals1.Checked;
   // 1.2b: Refresh Show Use Colours
   if UsedColoursOption then
      BuildUsedColoursArray;
   PaintPalette(cnvPalette,True);
end;

procedure TFrmMain.OGL3DPreviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   If not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: OGL3DPreviewMouseMove');
   {$endif}
   if MouseButton = 1 then
   begin
      Camera.SetRotation(Camera.Rotation.X + (Y - Ycoord)/2,Camera.Rotation.Y + (X - Xcoord)/2,Camera.Rotation.Z);
      Xcoord := X;
      Ycoord := Y;
   end;
   if MouseButton = 2 then
   begin
      Camera.SetPosition(Camera.Position.X,Camera.Position.Y,Camera.Position.Z - (Y-ZCoord)/3);
      Zcoord := Y;
   end;
end;

procedure TFrmMain.O3DModelizer1Click(Sender: TObject);
begin
   if p_Frm3DModelizer = nil then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: O3DModelizer1Click');
      {$endif}
      Application.OnIdle := nil;
      new(p_Frm3DModelizer);
      p_Frm3DModelizer^ := TFrm3DModelizer.Create(self);
      p_Frm3DModelizer^.Show;
      if @Application.OnIdle = nil then
         Application.OnIdle := Idle;
   end;
end;

procedure TFrmMain.OGL3DPreviewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   If not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: OGL3DPreviewMouseDown');
   {$endif}
   if Button = mbLeft  then
   begin
      MouseButton :=1;
      Xcoord := X;
      Ycoord := Y;
   end;
   if Button = mbRight then
   begin
      MouseButton :=2;
      Zcoord := Y;
   end;
end;

procedure TFrmMain.OGL3DPreviewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: OGL3DPreviewMouseUp');
   {$endif}
   MouseButton :=0;
end;

procedure TFrmMain.SpeedButton1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SpeedButton1MouseUp');
   {$endif}
   Popup3d.Popup(Left+SpeedButton1.Left+ RightPanel.Left +5,Top+ 90+ Panel7.Top + SpeedButton1.Top);
end;

procedure TFrmMain.DebugMode1Click(Sender: TObject);
begin
   DebugMode1.Checked := not DebugMode1.Checked;
   Env.ShowRotations := DebugMode1.Checked;
end;

Procedure TFrmMain.SetRotationAdders;
var
   V : single;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetRotationAdders');
   {$endif}
   try
      V := spin3Djmp.Value / 10;
   except
      exit; // Not a value
   end;

   if btn3DRotateX2.Down then
      Camera.SetRotationSpeed(-V,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z)
   else if btn3DRotateX.Down then
      Camera.SetRotationSpeed(V,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z)
   else
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);

   if btn3DRotateY2.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,-V,Camera.RotationSpeed.Z)
   else if btn3DRotateY.Down then
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,V,Camera.RotationSpeed.Z)
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,0,Camera.RotationSpeed.Z);
end;

procedure TFrmMain.SpeedButton2Click(Sender: TObject);
begin
   Camera.SetPosition(Camera.Position.X,Camera.Position.Y,-150);
end;

procedure TFrmMain.btn3DRotateXClick(Sender: TObject);
begin
   if btn3DRotateX.Down then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: Btn3DRotateXClick');
      {$endif}
      SetRotationAdders;
   end
   else
   begin
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);
   end;
end;

procedure TFrmMain.btn3DRotateX2Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Bnt3DRotateX2Click');
   {$endif}
   if btn3DRotateX2.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(0,Camera.RotationSpeed.Y,Camera.RotationSpeed.Z);
end;

procedure TFrmMain.btn3DRotateY2Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Btn3DRotateY2Click');
   {$endif}
   if btn3DRotateY2.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,0,Camera.RotationSpeed.Z);
end;

procedure TFrmMain.btn3DRotateYClick(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: btn3DRotateYClick');
   {$endif}
   if btn3DRotateY.Down then
   begin
      SetRotationAdders;
   end
   else
      Camera.SetRotationSpeed(Camera.RotationSpeed.X,0,Camera.RotationSpeed.Z);
end;

procedure TFrmMain.spin3DjmpChange(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Spin3DJmpChange');
   {$endif}
   SetRotationAdders;
end;

procedure TFrmMain.BackgroundColour1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector3fToTColor(Env.BackgroundColour);
   if ColorDialog.Execute then
      Env.SetBackgroundColour(TColorToTVector3f(ColorDialog.Color));
end;

procedure TFrmMain.extColour1Click(Sender: TObject);
begin
   ColorDialog.Color := TVector3fToTColor(Env.FontColour);
   if ColorDialog.Execute then
      Env.SetFontColour(TColorToTVector3f(ColorDialog.Color));
end;

procedure TFrmMain.ClearRemapClicks;
begin
   Red1.Checked := false;
   Blue1.Checked := false;
   Green1.Checked := false;
   White1.Checked := false;
   Orange1.Checked := false;
   Magenta1.Checked := false;
   Purple1.Checked := false;
   Gold1.Checked := false;
   DarkSky1.Checked := false;
end;

procedure TFrmMain.Red1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Red1.Checked := true;
   RemapColour.X := RemapColourMap[0].R /255;
   RemapColour.Y := RemapColourMap[0].G /255;
   RemapColour.Z := RemapColourMap[0].B /255;
   Actor^.ChangeRemappable(RemapColourMap[0].R,RemapColourMap[0].G,RemapColourMap[0].B);
end;

procedure TFrmMain.Blue1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Blue1.Checked := true;
   RemapColour.X := RemapColourMap[1].R /255;
   RemapColour.Y := RemapColourMap[1].G /255;
   RemapColour.Z := RemapColourMap[1].B /255;
   Actor^.ChangeRemappable(RemapColourMap[1].R,RemapColourMap[1].G,RemapColourMap[1].B);
end;

procedure TFrmMain.Green1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Green1.Checked := true;
   RemapColour.X := RemapColourMap[2].R /255;
   RemapColour.Y := RemapColourMap[2].G /255;
   RemapColour.Z := RemapColourMap[2].B /255;
   Actor^.ChangeRemappable(RemapColourMap[2].R,RemapColourMap[2].G,RemapColourMap[2].B);
end;

procedure TFrmMain.White1Click(Sender: TObject);
begin
   ClearRemapClicks;
   White1.Checked := true;
   RemapColour.X := RemapColourMap[3].R /255;
   RemapColour.Y := RemapColourMap[3].G /255;
   RemapColour.Z := RemapColourMap[3].B /255;
   Actor^.ChangeRemappable(RemapColourMap[3].R,RemapColourMap[3].G,RemapColourMap[3].B);
end;

procedure TFrmMain.Orange1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Orange1.Checked := true;
   RemapColour.X := RemapColourMap[4].R /255;
   RemapColour.Y := RemapColourMap[4].G /255;
   RemapColour.Z := RemapColourMap[4].B /255;
   Actor^.ChangeRemappable(RemapColourMap[4].R,RemapColourMap[4].G,RemapColourMap[4].B);
end;

procedure TFrmMain.Magenta1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Magenta1.Checked := true;
   RemapColour.X := RemapColourMap[5].R /255;
   RemapColour.Y := RemapColourMap[5].G /255;
   RemapColour.Z := RemapColourMap[5].B /255;
   Actor^.ChangeRemappable(RemapColourMap[5].R,RemapColourMap[5].G,RemapColourMap[5].B);
end;

procedure TFrmMain.MaintainDimensions1Click(Sender: TObject);
begin
   MaintainDimensions1.Checked := not MaintainDimensions1.Checked; 
   Configuration.MaintainDimensionsRM := MaintainDimensions1.Checked;
end;

procedure TFrmMain.Purple1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Purple1.Checked := true;
   RemapColour.X := RemapColourMap[6].R /255;
   RemapColour.Y := RemapColourMap[6].G /255;
   RemapColour.Z := RemapColourMap[6].B /255;
   Actor^.ChangeRemappable(RemapColourMap[6].R,RemapColourMap[6].G,RemapColourMap[6].B);
end;

procedure TFrmMain.Gold1Click(Sender: TObject);
begin
   ClearRemapClicks;
   Gold1.Checked := true;
   RemapColour.X := RemapColourMap[7].R /255;
   RemapColour.Y := RemapColourMap[7].G /255;
   RemapColour.Z := RemapColourMap[7].B /255;
   Actor^.ChangeRemappable(RemapColourMap[7].R,RemapColourMap[7].G,RemapColourMap[7].B);
end;

procedure TFrmMain.DarkSky1Click(Sender: TObject);
begin
   ClearRemapClicks;
   DarkSky1.Checked := true;
   RemapColour.X := RemapColourMap[8].R /255;
   RemapColour.Y := RemapColourMap[8].G /255;
   RemapColour.Z := RemapColourMap[8].B /255;
   Actor^.ChangeRemappable(RemapColourMap[8].R,RemapColourMap[8].G,RemapColourMap[8].B);
end;

procedure TFrmMain.Front1Click(Sender: TObject);
begin
   Camera.SetRotation(0,0,0);
end;

procedure TFrmMain.Back1Click(Sender: TObject);
begin
   Camera.SetRotation(0,180,0);
end;

procedure TFrmMain.LEft1Click(Sender: TObject);
begin
   Camera.SetRotation(0,-90,0);
end;

procedure TFrmMain.Right1Click(Sender: TObject);
begin
   Camera.SetRotation(0,90,0);
end;

procedure TFrmMain.Bottom1Click(Sender: TObject);
begin
   Camera.SetRotation(90,-90,180);
end;

procedure TFrmMain.op1Click(Sender: TObject);
begin
   Camera.SetRotation(-90,90,180);
end;

procedure TFrmMain.Cameo1Click(Sender: TObject);
begin
   Camera.SetRotation(17,315,0);
end;

procedure TFrmMain.Cameo21Click(Sender: TObject);
begin
   Camera.SetRotation(17,45,0);
end;

procedure TFrmMain.Cameo31Click(Sender: TObject);
begin
   Camera.SetRotation(17,345,0);
end;

procedure TFrmMain.Cameo41Click(Sender: TObject);
begin
   Camera.SetRotation(17,15,0);
end;

procedure TFrmMain.CnvView2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CnvView2MouseUp');
   {$endif}
   // isLeftMB := false;
end;

procedure TFrmMain.CnvView1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CnvView1MouseUp');
   {$endif}
   // isLeftMB := false;
end;

procedure TFrmMain.CnvView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   Outside: Boolean;
begin
   if VoxelOpen and IsEditable then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView1MouseDown');
      {$endif}
      // if Button = mbLeft then
         // isLeftMB := true;

      if Button = mbLeft then
      begin
         TranslateClick(1,X,Y,LastClick[1].X,LastClick[1].Y,LastClick[1].Z,Outside);
         if not Outside then
         begin
            MoveCursor(LastClick[1].X,LastClick[1].Y,LastClick[1].Z,true);
            CursorResetNoMAX;
         end;
      end;
   end;
end;

procedure TFrmMain.CnvView1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   Outside: Boolean;
begin
   if VoxelOpen and IsEditable then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView1MouseMove');
      {$endif}
      if ssLeft in Shift then
      begin
         TranslateClick(1,X,Y,LastClick[1].X,LastClick[1].Y,LastClick[1].Z,Outside);
         if Not Outside then
         begin
            MoveCursor(LastClick[1].X,LastClick[1].Y,LastClick[1].Z,true);
            CursorResetNoMAX;
         end;
      end;
   end;
end;

procedure TFrmMain.CnvView2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   Outside: boolean;
begin
   if VoxelOpen and IsEditable then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView2MouseMove');
      {$endif}
      if ssLeft in Shift then
      begin
         TranslateClick(2,X,Y,LastClick[2].X,LastClick[2].Y,LastClick[2].Z,Outside);
         if not Outside then
         begin
            MoveCursor(LastClick[2].X,LastClick[2].Y,LastClick[2].Z,true);
            CursorResetNoMAX;
         end;
      end;
   end;
end;

procedure TFrmMain.CnvView2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   Outside: boolean;
begin
   if VoxelOpen and IsEditable then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView2MouseDown');
      {$endif}
      // if Button = mbLeft then
         // isLeftMB := true;

      if ssLeft in Shift then
      begin
         TranslateClick(2,X,Y,LastClick[2].X,LastClick[2].Y,LastClick[2].Z,Outside);
         if not Outside then
         begin
            MoveCursor(LastClick[2].X,LastClick[2].Y,LastClick[2].Z,true);
            CursorResetNoMAX;
         end;
      end;
   end;
end;

procedure TFrmMain.CnvView0MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   TempI : integer;
   V : TVoxelUnpacked;
   Outside: boolean;
begin
   if VoxelOpen and IsEditable then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView0MouseUp');
      {$endif}

      if ((ssAlt in shift) and (Button = mbLeft)) or ((Button = mbLeft) and (VXLTool = VXLTool_Dropper)) then
      begin
         TempI := GetPaletteColourFromVoxel(X,Y,0);
         if TempI > -1 then
            if SpectrumMode = ModeColours then
               SetActiveColor(TempI,True)
            else
               SetActiveNormal(TempI,True);
      end
      else
      begin
         if (ssCtrl in shift) and (Button = mbLeft) then
         begin
            TranslateClick(0,x,y,LastClick[0].x,LastClick[0].y,LastClick[0].z,Outside);
            if not Outside then
            begin
               MoveCursor(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,false);
            end;
         end;

         if VXLTool = VXLTool_FloodFill then
         begin
            TranslateClick(0,x,y,LastClick[0].x,LastClick[0].y,LastClick[0].z,Outside);
            if not Outside then
            begin
               Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
               if (SpectrumMode = ModeColours) or (v.Used=False) then
                  v.Colour := ActiveColour;
               if (SpectrumMode = ModeNormals) or (v.Used=False) then
                  v.Normal := ActiveNormal;

               v.Used := True;
               VXLFloodFillTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,Document.ActiveSection^.View[0].GetOrient);
            end;
         end;

         if VXLTool = VXLTool_FloodFillErase then
         begin
            TranslateClick(0,x,y,LastClick[0].x,LastClick[0].y,LastClick[0].z,Outside);
            if not Outside then
            begin
               Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
               if (SpectrumMode = ModeColours) or (v.Used=False) then
                  v.Colour := 0;
               if (SpectrumMode = ModeNormals) or (v.Used=False) then
                  v.Normal := 0;

               v.Used := False;
               VXLFloodFillTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,Document.ActiveSection^.View[0].GetOrient);
            end;
         end;

         if VXLTool = VXLTool_Darken then
         begin
            TranslateClick(0,x,y,LastClick[0].x,LastClick[0].y,LastClick[0].z,Outside);
            if not Outside then
            begin
               Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
               if (SpectrumMode = ModeColours) or (v.Used=False) then
                  v.Colour := ActiveColour;
               if (SpectrumMode = ModeNormals) or (v.Used=False) then
                  v.Normal := ActiveNormal;

               v.Used := True;
               VXLBrushToolDarkenLighten(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,VXLBrush,Document.ActiveSection^.View[0].GetOrient,True);
            end;
         end;

         if VXLTool = VXLTool_Lighten then
         begin
            TranslateClick(0,x,y,LastClick[0].x,LastClick[0].y,LastClick[0].z,Outside);
            if not Outside then
            begin
               Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
               if (SpectrumMode = ModeColours) or (v.Used=False) then
                  v.Colour := ActiveColour;
               if (SpectrumMode = ModeNormals) or (v.Used=False) then
                  v.Normal := ActiveNormal;

               v.Used := True;
               VXLBrushToolDarkenLighten(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,VXLBrush,Document.ActiveSection^.View[0].GetOrient,false);
            end;
         end;
      end;

      if ApplyTempView(Document.ActiveSection^) then
         UpdateUndo_RedoState;

      TempLines.Data_no := 0;
      SetLength(TempLines.Data,0);
      ValidLastClick := false;

      if (Button = mbLeft) or (Button = mbRight) then
      begin
         RefreshAll;
      end;
   end;
end;

Procedure TFrmMain.UpdateCursor(P : TVector3i; Repaint : Boolean);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: UpdateCursor');
   {$endif}
   XCursorBar.Position := P.X;
   YCursorBar.Position := P.Y;
   ZCursorBar.Position := P.Z;
   UpdatePositionStatus(P.X,P.Y,P.Z);
   StatusBar1.Refresh;

   MoveCursor(P.X,P.Y,P.Z,Repaint);
end;

procedure TFrmMain.XCursorBarChange(Sender: TObject);
begin
   if IsVXLLoading then exit;
   if isCursorReset then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: XCursorBarChange');
   {$endif}
   UpdateCursor(SetVectorI(XCursorBar.Position,YCursorBar.Position,ZCursorBar.Position),true);
end;

Procedure TFrmMain.CursorReset;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CursorReset');
   {$endif}
   isCursorReset := true;

   XCursorBar.Position := 0;
   YCursorBar.Position := 0;
   ZCursorBar.Position := 0;

   XCursorBar.Max := Document.ActiveSection^.Tailer.XSize-1;
   YCursorBar.Max := Document.ActiveSection^.Tailer.YSize-1;
   ZCursorBar.Max := Document.ActiveSection^.Tailer.ZSize-1;

   XCursorBar.Position := Document.ActiveSection^.X;
   YCursorBar.Position := Document.ActiveSection^.Y;
   ZCursorBar.Position := Document.ActiveSection^.Z;

   UpdatePositionStatus(Document.ActiveSection^.X,Document.ActiveSection^.Y,Document.ActiveSection^.Z);
   StatusBar1.Refresh;

   isCursorReset := false;
end;

Procedure TFrmMain.CursorResetNoMAX;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CursorResetNoMAX');
   {$endif}
   isCursorReset := true;

   XCursorBar.Position := Document.ActiveSection^.X;
   YCursorBar.Position := Document.ActiveSection^.Y;
   ZCursorBar.Position := Document.ActiveSection^.Z;

   UpdatePositionStatus(Document.ActiveSection^.X,Document.ActiveSection^.Y,Document.ActiveSection^.Z);
   StatusBar1.Refresh;

   isCursorReset := false;
end;

Procedure TFrmMain.SetupStatusBar;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetupStatusBar');
   {$endif}
   if Document.ActiveSection^.Tailer.NormalsType = 2 then
      StatusBar1.Panels[0].Text := 'Type: Tiberian Sun'
   else if Document.ActiveSection^.Tailer.NormalsType = 4 then
      StatusBar1.Panels[0].Text := 'Type: RedAlert 2'
   else
      StatusBar1.Panels[0].Text := 'Type: Unknown ' + inttostr(Document.ActiveSection^.Tailer.NormalsType);

   StatusBar1.Panels[1].Text := 'X Size: ' + inttostr(Document.ActiveSection^.Tailer.XSize) + ', Y Size: ' + inttostr(Document.ActiveSection^.Tailer.YSize) + ', Z Size: ' + inttostr(Document.ActiveSection^.Tailer.ZSize);
   StatusBar1.Panels[2].Text := '';
   StatusBar1.Refresh;
end;

procedure TFrmMain.CnvView0MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
label
   PickColor;
var
   V : TVoxelUnpacked;
   TempI : integer;
   Viewport : TViewport;
   SnapPos1 : TPoint;
   SnapPos2 : TPoint;
   GridPos1 : TPoint;
   GridPos2 : TPoint;
   GridOffset : TPoint;
   MeasureAngle : Extended;
   Outside: Boolean;
begin
   // Maybe a switch statement is better because it can be optimized by the compiler - HBD
   // Test whether left(right) mouse button is down with:
   // if ssLeft(ssRight) in Shift then ... - HBD
   if VoxelOpen and isEditable then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView0MouseMove');
      {$endif}
      TranslateClick(0,x,y,LastClick[0].x,LastClick[0].y,LastClick[0].z,Outside);
      StatusBar1.Panels[2].Text := 'X: ' + inttostr(LastClick[0].X) + ', Y: ' + inttostr(LastClick[0].Y) + ', Z: ' + inttostr(LastClick[0].Z);
      StatusBar1.Refresh;

      MousePos.X := X;
      MousePos.Y := Y;

      if TempLines.Data_no > 0 then
      begin
         TempLines.Data_no := 0;
         SetLength(TempLines.Data,0);
      end;

      if not Outside then
      begin
         if ssLeft in Shift then
         begin
            if ssCtrl in shift then
            begin
               MoveCursor(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,true);
               Exit;
            end;

            // alt key dropper
            if ssAlt in Shift then goto PickColor;

            case VxlTool of

               VxlTool_Brush:
               begin
                  if VXLBrush <> 4 then
                  begin
                     Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
                     if (SpectrumMode = ModeColours) or (v.Used=False) then
                        v.Colour := ActiveColour;
                     if (SpectrumMode = ModeNormals) or (v.Used=False) then
                        v.Normal := ActiveNormal;

                     v.Used := True;
                     VXLBrushTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,Document.ActiveSection^.View[0].GetOrient);
                     CnvView[0].Repaint;
                  end;
               end;

               VxlTool_Dropper:
               PickColor:
               begin
                  TempI := GetPaletteColourFromVoxel(X,Y,0);
                  if TempI > -1 then
                     if SpectrumMode = ModeColours then
                        SetActiveColor(TempI,True)
                     else
                        SetActiveNormal(TempI,True);
                  Mouse_Current := MouseDropper;
                  CnvView[0].Cursor := Mouse_Current;
               end;

               VXLTool_SmoothNormal:
               begin
                  Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
                  VXLSmoothBrushTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,Document.ActiveSection^.View[0].GetOrient);
                  RepaintViews;
               end;

               VXLTool_Erase:
               begin
                  v.Used := false;
                  v.Colour := 0;
                  v.Normal := 0;
                  VXLBrushTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,Document.ActiveSection^.View[0].GetOrient);

                  RepaintViews;
               end;

               VxlTool_Line:
               begin
                  if ValidLastClick then
                  begin
                     V.Used := true;
                     V.Colour := ActiveColour;
                     V.Normal := ActiveNormal;
                     drawstraightline(Document.ActiveSection^,TempView,LastClick[0],LastClick[1],V);
                     RepaintViews;
                  end;
               end;

               VXLTool_Rectangle:
               begin
                  if ValidLastClick then
                  begin
                     V.Used := true;
                     V.Colour := ActiveColour;
                     V.Normal := ActiveNormal;
                     VXLRectangle(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,LastClick[1].X,LastClick[1].Y,LastClick[1].Z,false,v);
                     RepaintViews;
                  end;
               end;

               VXLTool_FilledRectangle:
               begin
                  if ValidLastClick then
                  begin
                     V.Used := true;
                     V.Colour := ActiveColour;
                     V.Normal := ActiveNormal;
                     VXLRectangle(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,LastClick[1].X,LastClick[1].Y,LastClick[1].Z,true,v);
                     RepaintViews;
                  end;
               end;

               VXLTool_Measure:
               begin
                  Viewport := Document.ActiveSection^.Viewport[0];

                  GridPos1.X := ((OldMousePos.X-Viewport.Left) div Viewport.Zoom);
                  GridPos1.Y := ((OldMousePos.Y-Viewport.Top) div Viewport.Zoom);
                  GridPos2.X := ((MousePos.X-Viewport.Left) div Viewport.Zoom);
                  GridPos2.Y := ((MousePos.Y-Viewport.Top) div Viewport.Zoom);
                  SnapPos1.X := (GridPos1.X*Viewport.Zoom + Viewport.Zoom div 2)+Viewport.Left;
                  SnapPos1.Y := (GridPos1.Y*Viewport.Zoom + Viewport.Zoom div 2)+Viewport.Top;
                  SnapPos2.X := (GridPos2.X*Viewport.Zoom + Viewport.Zoom div 2)+Viewport.Left;
                  SnapPos2.Y := (GridPos2.Y*Viewport.Zoom + Viewport.Zoom div 2)+Viewport.Top;
                  GridOffset.X := GridPos2.X-GridPos1.X;
                  GridOffset.Y := GridPos2.Y-GridPos1.Y;

                  MeasureAngle := ArcTan2(SnapPos2.Y-SnapPos1.Y,SnapPos2.X-SnapPos1.X);

                  if (GridOffset.X <> 0) or (GridOffset.Y <> 0) then
                  begin
                     AddTempLine(Round(SnapPos1.X+Cos(MeasureAngle)*5.0),Round(SnapPos1.Y+Sin(MeasureAngle)*5.0),Round(SnapPos2.X-Cos(MeasureAngle)*5.0),Round(SnapPos2.Y-Sin(MeasureAngle)*5.0),1,clBlack);
                     AddTempLine(Round(SnapPos1.X+Cos(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos1.Y+Sin(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos1.X-Cos(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos1.Y-Sin(MeasureAngle+Pi*0.5)*10.0),1,clBlack);
                     AddTempLine(Round(SnapPos2.X+Cos(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos2.Y+Sin(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos2.X-Cos(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos2.Y-Sin(MeasureAngle+Pi*0.5)*10.0),1,clBlack);
                     AddTempLine(Round(SnapPos1.X+Cos(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos1.Y+Sin(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos1.X-Cos(MeasureAngle+Pi*0.5)*10.0),Round(SnapPos1.Y-Sin(MeasureAngle+Pi*0.5)*10.0),1,clBlack);
                     AddTempLine(Round(SnapPos1.X+Cos(MeasureAngle)*5.0),Round(SnapPos1.Y+Sin(MeasureAngle)*5.0),Round(SnapPos1.X-Cos(MeasureAngle+Pi*0.8)*15.0),Round(SnapPos1.Y-Sin(MeasureAngle+Pi*0.8)*15.0),1,clBlack);
                     AddTempLine(Round(SnapPos1.X+Cos(MeasureAngle)*5.0),Round(SnapPos1.Y+Sin(MeasureAngle)*5.0),Round(SnapPos1.X-Cos(MeasureAngle-Pi*0.8)*15.0),Round(SnapPos1.Y-Sin(MeasureAngle-Pi*0.8)*15.0),1,clBlack);
                     AddTempLine(Round(SnapPos2.X-Cos(MeasureAngle)*5.0),Round(SnapPos2.Y-Sin(MeasureAngle)*5.0),Round(SnapPos2.X+Cos(MeasureAngle+Pi*0.8)*15.0),Round(SnapPos2.Y+Sin(MeasureAngle+Pi*0.8)*15.0),1,clBlack);
                     AddTempLine(Round(SnapPos2.X-Cos(MeasureAngle)*5.0),Round(SnapPos2.Y-Sin(MeasureAngle)*5.0),Round(SnapPos2.X+Cos(MeasureAngle-Pi*0.8)*15.0),Round(SnapPos2.Y+Sin(MeasureAngle-Pi*0.8)*15.0),1,clBlack);
                  end;

                  StatusBar1.Panels[4].Text := 'Tool: Measure - ('+inttostr(GridPos1.X)+','+inttostr(GridPos1.Y)+') -> ('+inttostr(GridPos2.X)+','+inttostr(GridPos2.Y)+')     Offset - ('+inttostr(GridOffset.X)+','+inttostr(GridOffset.Y)+')     Length - ('+FloatToStrF(Sqrt(GridOffset.X*GridOffset.X+GridOffset.Y*GridOffset.Y),ffFixed,100,3)+')';
                  RepaintViews;
               end;

            end;
         end
         else if ssRight in Shift then
         begin
            case VxlTool of

               VXLTool_Brush:
               begin
                  v.Used := false;
                  v.Colour := 0;
                  v.Normal := 0;
                  VXLBrushTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,Document.ActiveSection^.View[0].GetOrient);
                  RepaintViews;
               end;

               VxlTool_Line:
               begin
                  if ValidLastClick then
                  begin
                     V.Used := False;
                     V.Colour := 0;
                     V.Normal := 0;
                     drawstraightline(Document.ActiveSection^,TempView,LastClick[0],LastClick[1],V);
                     RepaintViews;
                  end;
               end;

               VXLTool_Rectangle:
               begin
                  if ValidLastClick then
                  begin
                     V.Used := False;
                     V.Colour := 0;
                     V.Normal := 0;
                     VXLRectangle(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,LastClick[1].X,LastClick[1].Y,LastClick[1].Z,false,v);
                     RepaintViews;
                  end;
               end;

               VXLTool_FilledRectangle:
               begin
                  if ValidLastClick then
                  begin
                     V.Used := False;
                     V.Colour := 0;
                     V.Normal := 0;
                     VXLRectangle(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,LastClick[1].X,LastClick[1].Y,LastClick[1].Z,true,v);
                     RepaintViews;
                  end;
               end;

            end; // tool switch
         end
         else
         begin
            OldMousePos.X := X;
            OldMousePos.Y := Y;
            //TranslateClick2(0,X,Y,LastClick[0].X,LastClick[0].Y,LastClick[0].Z);
            with Document.ActiveSection^.Tailer do
               if (LastClick[0].X < 0) or (LastClick[0].Y < 0) or (LastClick[0].Z < 0) or (LastClick[0].X >= XSize) or (LastClick[0].Y >= YSize) or (LastClick[0].Z >= ZSize) then
               begin
                  if TempView.Data_no > 0 then
                  begin
                     TempView.Data_no := 0;
                     Setlength(TempView.Data,0);
                     CnvView[0].Repaint;
                  end;
                  Mouse_Current := crDefault;
                  CnvView[0].Cursor := Mouse_Current;
                  Exit;
               end;
            SetCursor;
            if ssAlt in Shift then
            begin
               Mouse_Current := MouseDropper;
               CnvView[0].Repaint;
            end;
            CnvView[0].Cursor := Mouse_Current;

           if TempView.Data_no > 0 then
            begin
               TempView.Data_no := 0;
               Setlength(TempView.Data,0);
               //CnvView[0].Repaint;
            end;

            if (not DisableDrawPreview1.Checked) and (not (ssAlt in Shift)) then
            begin
               case VXLTool of

                  VXLTool_Brush:
                  begin
                     if (VXLBrush <> 4) then
                     begin
                        Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
                        if (SpectrumMode = ModeColours) or (v.Used=False) then
                           v.Colour := ActiveColour;
                        if (SpectrumMode = ModeNormals) or (v.Used=False) then
                           v.Normal := ActiveNormal;

                        v.Used := True;
                        VXLBrushTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,Document.ActiveSection^.View[0].GetOrient);
                        // ActiveSection.BrushTool(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,ActiveSection.View[0].GetOrient);
                        CnvView[0].Repaint;
                     end;
                  end;

                  VXLTool_SmoothNormal:
                  begin
                     if VXLBrush <> 4 then
                     begin
                        Document.ActiveSection^.GetVoxel(LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v);
                        VXLSmoothBrushTool(Document.ActiveSection^,LastClick[0].X,LastClick[0].Y,LastClick[0].Z,v,VXLBrush,Document.ActiveSection^.View[0].GetOrient);
                        CnvView[0].Repaint;
                     end;
                  end;

               end; // tool switch

            end; // draw preview not disabled and alt not used.

         end; // Which button is down

      end // Is click not outside
      else
      begin
         TempView.Data_no := 0;
         Setlength(TempView.Data,0);
         CnvView[0].Repaint;
      end;

   end; // open and editable
end;

procedure TFrmMain.lblView1Click(Sender: TObject);
begin
   if not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: lblView1Click');
   {$endif}
   ActivateView(1);
   setupscrollbars;
end;

procedure TFrmMain.lblView2Click(Sender: TObject);
begin
   if not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: lblView2Click');
   {$endif}
   ActivateView(2);
   setupscrollbars;
end;

procedure TFrmMain.mnuDirectionPopupPopup(Sender: TObject);
var
   comp: TComponent;
   idx: Integer;
   View: TVoxelView;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuDirectionPopupPopup');
   {$endif}
   comp := mnuDirectionPopup.PopupComponent;
   mnuEdit.Visible := (comp <> lblView0); // can't edit as already editing it!
   if comp = lblView0 then
      View := Document.ActiveSection^.View[0]
   else if comp = lblView1 then
      View := Document.ActiveSection^.View[1]
   else
      View := Document.ActiveSection^.View[2];
   idx := (View.getViewNameIdx div 2) * 2;
   with mnuDirTowards do
   begin
      Caption := ViewName[idx];
      Enabled := not (View.getDir = dirTowards);
   end;
   with mnuDirAway do
   begin
      Caption := ViewName[idx+1];
      Enabled := not (View.getDir = dirAway);
   end;
end;

procedure TFrmMain.mnuEditClick(Sender: TObject);
var comp: TComponent;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuEditClick');
   {$endif}
   comp := mnuDirectionPopup.PopupComponent;
   if comp = lblView1 then
      ActivateView(1)
   else
      ActivateView(2);
end;

procedure TFrmMain.mnuDirTowardsClick(Sender: TObject);
   procedure SetDir(WndIndex: Integer);
//   var idx: Integer;
   begin
      with Document.ActiveSection^.View[WndIndex] do
      begin
         setDir(dirTowards);
//         idx := getViewNameIdx;
         //lblView[WndIndex].Caption := ViewName[idx];
         SyncViews;
         Refresh;
         RepaintViews;
         cnvView[WndIndex].Repaint;
      end;
   end;
var
   i: Integer;
   // KnownComponent: Boolean;
   comp: TComponent;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuDirTowardsClick');
   {$endif}
   comp := mnuDirectionPopup.PopupComponent;
   //KnownComponent := False;
   for i := 0 to 2 do
   begin
       if comp.Name = lblView[i].Name then
       begin
          SetDir(i);
          Break;
       end;
   end;
end;

procedure TFrmMain.mnuDirAwayClick(Sender: TObject);
   procedure SetDir(WndIndex: Integer);
   begin
      with Document.ActiveSection^.View[WndIndex] do
      begin
         setDir(dirAway);
         SyncViews;
         Refresh;
         RepaintViews;
         cnvView[WndIndex].Repaint;
      end;
   end;
var
   i: Integer;
   comp: TComponent;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuDirAwayClick');
   {$endif}
   comp := mnuDirectionPopup.PopupComponent;
   //  KnownComponent := False;
   for i := 0 to 2 do
   begin
      if comp.Name = lblView[i].Name then
      begin
         SetDir(i);
         //   KnownComponent := True;
         Break;
      end;
   end;
end;

Procedure TFrmMain.SelectCorrectPalette2(Palette : String);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SelectCorrectPalette2');
   {$endif}
   if Palette = 'TS' then
      iberianSunPalette1Click(nil)
   else if Palette = 'RA2' then
      RedAlert2Palette1Click(nil)
   else if fileexists(ExtractFileDir(ParamStr(0)) + '\palettes\USER\' + Palette) then
   begin
      Document.Palette^.LoadPalette(ExtractFileDir(ParamStr(0)) + '\palettes\USER\' + Palette);
      cnvPalette.Repaint;
   end;
end;

Procedure TFrmMain.SelectCorrectPalette;
begin
   if not Configuration.Palette then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SelectCorrectPalette');
   {$endif}

   if Document.ActiveVoxel^.Section[0].Tailer.NormalsType = 2 then
      SelectCorrectPalette2(Configuration.TS)
   else
   SelectCorrectPalette2(Configuration.RA2);
end;

Procedure TFrmMain.CreateVxlError(v,n : Boolean);
var
   frm : tFrmVxlError;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CreateVxlError');
   {$endif}
   frm:=TFrmVxlError.Create(Self);
   frm.Visible:=False;

   frm.Image1.Picture := TopBarImageHolder.Picture;
   frm.TabSheet1.TabVisible := v;
   frm.TabSheet2.TabVisible := n;

   frm.ShowModal;
   frm.Close;
   frm.Free;
end;

procedure TFrmMain.Brush_1Click(Sender: TObject);
begin
   VXLBrush := 0;
end;

procedure TFrmMain.Brush_2Click(Sender: TObject);
begin
   VXLBrush := 1;
end;

procedure TFrmMain.Brush_3Click(Sender: TObject);
begin
   VXLBrush := 2;
end;

procedure TFrmMain.Brush_4Click(Sender: TObject);
begin
   VXLBrush := 3;
end;

procedure TFrmMain.Brush_5Click(Sender: TObject);
begin
   VXLBrush := 4;
end;

procedure TFrmMain.SpeedButton3Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Brush);
end;

Procedure TFrmMain.SetVXLTool(VXLTool_ : Integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetVXLTool');
   {$endif}
   SpeedButton3.Down := false;
   SpeedButton4.Down := false;
   SpeedButton5.Down := false;
   SpeedButton6.Down := false;
   SpeedButton7.Down := false;
   SpeedButton8.Down := false;
   SpeedButton9.Down := false;
   SpeedButton10.Down := false;
   SpeedButton11.Down := false;
   SpeedButton12.Down := false;
   SpeedButton13.Down := false;
   SpeedButton14.Down := false;

   if VXLTool_ = VXLTool_Brush then
   begin
      VXLToolName := 'Brush';
      SpeedButton3.Down := true;
   end
   else if VXLTool_ = VXLTool_Line then
   begin
      VXLToolName := 'Line';
      SpeedButton4.Down := true;
   end
   else if VXLTool_ = VXLTool_Erase then
   begin
      VXLToolName := 'Erase';
      SpeedButton5.Down := true;
   end
   else if VXLTool_ = VXLTool_FloodFill then
   begin
      VXLToolName := 'Flood Fill';
      SpeedButton10.Down := true;
   end
   else if VXLTool_ = VXLTool_FloodFillErase then
   begin
      VXLToolName := 'Flood Erase';
      SpeedButton13.Down := true;
   end
   else if VXLTool_ = VXLTool_Dropper then
   begin
      VXLToolName := 'Dropper';
      SpeedButton11.Down := true;
   end
   else if VXLTool_ = VXLTool_Rectangle then
   begin
      VXLToolName := 'Rectangle';
      SpeedButton6.Down := true;
   end
   else if VXLTool_ = VXLTool_FilledRectangle then
   begin
      VXLToolName := 'Filled Rectange';
      SpeedButton8.Down := true;
   end
   else if VXLTool_ = VXLTool_Darken then
   begin
      VXLToolName := 'Darken';
      SpeedButton7.Down := true;
   end
   else if VXLTool_ = VXLTool_Lighten then
   begin
      VXLToolName := 'Lighten';
      SpeedButton12.Down := true;
   end
   else if VXLTool_ = VXLTool_SmoothNormal then
   begin
      VXLToolName := 'Smooth Normals';
      SpeedButton9.Down := true;
   end
   else if VXLTool_ = VXLTool_Measure then
   begin
      VXLToolName := 'Measure';
      SpeedButton14.Down := true;
   end;

   StatusBar1.Panels[4].Text := 'Tool: '+VXLToolName;

   VXLTool := VXLTool_;
end;

procedure TFrmMain.CnvView0MouseDown(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
begin
   if VoxelOpen and IsEditable then
   begin
      TranslateClick2(0,X,Y,LastClick[0].X,LastClick[0].Y,LastClick[0].Z);
      if (LastClick[0].X < 0) or (LastClick[0].Y < 0) or (LastClick[0].Z < 0) then Exit;

      with Document.ActiveSection^.Tailer do
         if (LastClick[0].X >= XSize) or (LastClick[0].Y >= YSize) or (LastClick[0].Z >= ZSize) then Exit;

      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CnvView0MouseDown');
      {$endif}

      if (VXLTool = VXLTool_Line) or (VXLTool = VXLTool_FilledRectangle) or (VXLTool = VXLTool_Rectangle) then
      begin
         LastClick[1].X := LastClick[0].X;
         LastClick[1].Y := LastClick[0].Y;
         LastClick[1].Z := LastClick[0].Z;
         ValidLastClick := true;
      end;

      if button = mbleft then
      begin
         if TempView.Data_no > 0 then
         begin
            TempView.Data_no := 0;
            Setlength(TempView.Data,0);
         end;
         // isLeftMouseDown := true;
         CnvView0MouseMove(sender,shift,x,y);
      end;
   end;
end;

procedure TFrmMain.SpeedButton5Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Erase);
end;

procedure TFrmMain.SpeedButton4Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Line);
end;

procedure TFrmMain.SpeedButton10Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_FloodFill);
end;

procedure TFrmMain.SpeedButton11Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Dropper);
end;

procedure TFrmMain.SpeedButton6Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Rectangle);
end;

procedure TFrmMain.SpeedButton8Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_FilledRectangle);
end;

procedure TFrmMain.Save1Click(Sender: TObject);
begin
   if not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Save1Click');
   {$endif}
   if VXLFilename <> '' then
   begin
      if FileExists(VXLFilename) then
      begin
         // ShowBusyMessage('Saving...');
         Document.SaveDocument(VXLFilename);
         SetVoxelChanged(false);
         // HideBusyMessage;
      end
      else
         SaveAs1Click(Sender);
   end
   else
   begin
      SaveAs1Click(Sender);
   end;
end;

procedure TFrmMain.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmMain.SaveAs1Click(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SaveAs1Click');
   {$endif}
   if SaveVXLDialog.Execute then
   begin
      Document.SaveDocument(SaveVXLDialog.FileName);
      VXLFilename := SaveVXLDialog.Filename;

      SetVoxelChanged(false);
      Configuration.AddFileToHistory(VXLFilename);
      UpdateHistoryMenu;
   end;
end;

procedure TFrmMain.VoxelHeader1Click(Sender: TObject);
var
   FrmHeader: TFrmHeader;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: VoxelHeader1Click');
   {$endif}
   FrmHeader:=TFrmHeader.Create(Self);
   with FrmHeader do
   begin
      SetValues(Document.ActiveVoxel,Document.ActiveHVA);
      PageControl1.ActivePage := PageControl1.Pages[1];
      Image2.Picture := TopBarImageHolder.Picture;
      ShowModal;
      RefreshAll;
      Release;
   end;
end;

procedure TFrmMain.N6Click(Sender: TObject);
var
  FrmHeader: TFrmHeader;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: N6Click');
   {$endif}
   FrmHeader:=TFrmHeader.Create(Self);
   with FrmHeader do
   begin
      SetValues(Document.ActiveVoxel,Document.ActiveHVA);
      PageControl1.ActivePage := PageControl1.Pages[0];
      Image2.Picture := TopBarImageHolder.Picture;
      ShowModal;
      Release;
   end;
end;

Procedure TFrmMain.UpdateUndo_RedoState;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: UpdateUndo_RedoState');
   {$endif}
   mnuBarUndo.Enabled := IsUndoRedoUsed(Undo);
   mnuBarRedo.Enabled := IsUndoRedoUsed(Redo);

   Undo1.Enabled := mnuBarUndo.Enabled;
   Redo1.Enabled := mnuBarRedo.Enabled;
end;

function TFrmMain.GetVoxelImportedBy3ds2vxl(var _Destination: string): boolean;
var
   SEInfo : TShellExecuteInfo;
   ExitCode : dword;
   OptionsFile : TINIFile;
begin
   // check if the location from 3ds2vxl exists.
   Result := false;
   while (not FileExists(Configuration.Location3ds2vxl)) or (not FileExists(Configuration.INILocation3ds2vxl)) do
   begin
      ShowMessage('Please inform the location of the 3ds2vxl executable. If you do not have it, download it from http://get3ds2vxl.ppmsite.com.');
      if OpenDialog3ds2vxl.Execute then
      begin
         Configuration.Location3ds2vxl := OpenDialog3ds2vxl.FileName;
         Configuration.INILocation3ds2vxl := IncludeTrailingPathDelimiter(ExtractFileDir(OpenDialog3ds2vxl.FileName)) + '3DS2VXL FE.ini';
      end
      else
      begin
         exit;
      end;
   end;
   SEInfo := RunProgram(Configuration.Location3ds2vxl,'',ExtractFileDir(Configuration.Location3ds2vxl));
   if SEInfo.hInstApp > 32 then
   begin
      repeat
         Sleep(2000);
         Application.ProcessMessages;
         GetExitCodeProcess(SEInfo.hProcess, ExitCode);
      until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
      // Once it's over, let's check the created file.
      OptionsFile := TINIFile.Create(Configuration.INILocation3ds2vxl);
      if (OptionsFile.ReadInteger('main','enable_voxelizer',0) = 1) and (OptionsFile.ReadInteger('main','activate_batch_voxelization',1) = 0) then
      begin
         _Destination := OptionsFile.ReadString('main','destination','');
         if FileExists(_Destination) then
         begin
            Result := true;
         end;
      end;
   end;
end;

procedure TFrmMain.using3ds2vxl1Click(Sender: TObject);
var
   Destination : string;
begin
   if GetVoxelImportedBy3ds2vxl(Destination) then
   begin
      OpenVoxelInterface(Destination);
   end;
end;

procedure TFrmMain.mnuBarUndoClick(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuBarUndoClick');
   {$endif}
   UndoRestorePoint(Undo,Redo);
   UpdateUndo_RedoState;
   UpdateViews;
   SetupStatusBar;
   RefreshAll;
end;

procedure TFrmMain.mnuBarRedoClick(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuBarRedoClick');
   {$endif}
   RedoRestorePoint(Undo,Redo);
   UpdateUndo_RedoState;
   UpdateViews;
   SetupStatusBar;
   RefreshAll;
end;

procedure TFrmMain.updatenormals1Click(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: UpdateNormals1Click');
   {$endif}
   // ask the user to confirm
   if MessageDlg('Autonormals v1.1' +#13#13+
        'This process will modify the voxel''s normals.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then
                        Exit;
   //ResetUndoRedo;
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   if ApplyNormalsToVXL(Document.ActiveSection^) > 0 then
      if MessageDlg('Some were Confused, This may mean there are redundant voxels.'+#13#13+'Run Remove Redundant Voxels?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
         RemoveRedundantVoxels1Click(Sender);

   Refreshall;
   SetVoxelChanged(true);
end;

procedure TFrmMain.CubedAutoNormals1Click(Sender: TObject);
var
   FrmAutoNormals : TFrmAutoNormals;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CubedAutoNormals1Click');
   {$endif}
   // One AutoNormals to rule them all!
   FrmAutoNormals := TFrmAutoNormals.Create(self);
   FrmAutoNormals.MyVoxel := Document.ActiveSection^;
   FrmAutoNormals.ShowModal;
   FrmAutoNormals.Release;
end;

procedure TFrmMain.Delete1Click(Sender: TObject);
var
  SectionIndex,i: Integer;
begin
   if not isEditable then exit;

   if Document.ActiveVoxel^.Header.NumSections<2 then
   begin
      MessageDlg('Warning: We can not delete this section if there is only 1 section!',mtWarning,[mbOK],0);
      Exit;
   end;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Delete1Click');
   {$endif}
   // ask the user to confirm
   if MessageDlg('Delete Section' +#13#13+
        'This process will delete the current section.' +#13+
        'This cannot be undone. If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then
                        Exit;

   //we can't undo these actions!!!
   ResetUndoRedo;
   UpdateUndo_RedoState;
   SetisEditable(False);

   SectionIndex:=Document.ActiveSection^.Header.Number;
   Document.ActiveVoxel^.RemoveSection(SectionIndex);
   Document.ActiveHVA^.DeleteSection(SectionIndex);

   SectionCombo.Items.Clear;
   for i:=0 to Document.ActiveVoxel^.Header.NumSections-1 do
   begin
      SectionCombo.Items.Add(Document.ActiveVoxel^.Section[i].Name);
   end;
   SectionCombo.ItemIndex:=0;
   SectionComboChange(Self);
   SetisEditable(True);
   SetVoxelChanged(true);
   Refreshall;
end;

procedure TFrmMain.normalsaphere1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: NormalSphere1Click');
   {$endif}
   //Update3dViewWithNormals(Document.ActiveSection^);
end;

procedure TFrmMain.RemoveRedundantVoxels1Click(Sender: TObject);
var no{, i}: integer;
   label Done;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: RemoveRedundantVoxels1Click');
   {$endif}
   // ensure the user wants to do this!
   if MessageDlg('Remove Redundant Voxels (8-Neighbors)' +#13#13+
        'This process will remove voxels that are hidden from view.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;
   // stop undo's
//     ResetUndoRedo;
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   // ok, do it
   no := RemoveRedundantVoxelsFromVXL(Document.ActiveSection^);
   if no = 0 then
      ShowMessage('Remove Redundant Voxels (8-Neighbors)' +#13#13+ 'Removed: 0')
   else
   begin
      ShowMessage('Remove Redundant Voxels (8-Neighbors)' +#13#13+ 'Removed: ' + IntToStr(no));
      RefreshAll;
      SetVoxelChanged(true);
   end;
end;

procedure TFrmMain.RemoveRedundantVoxelsB1Click(Sender: TObject);
var
  RemoveCount: Cardinal;
  TimeUsed: Cardinal;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: RemoveRedundantVoxelsB1Click');
   {$endif}
   // ensure the user wants to do this!
   if MessageDlg('Remove Redundant Voxels (4-Neighbors)' +#13#13+
        'This process will remove voxels that are hidden from view.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;
   TimeUsed := GetTickCount;
   RemoveCount := velRemoveRedundantVoxels(Document.ActiveSection^);
   TimeUsed := GetTickCount - TimeUsed;
   ShowMessage('Remove redundant Voxels (4-Neighbors)' +#13#13+ 'Removed: ' + IntToStr(RemoveCount)
      + #13 + 'Time used: ' + IntToStr(TimeUsed) + 'ms');
   if RemoveCount > 0 then
   begin
      RefreshAll;
      SetVoxelChanged(true);
   end;
end;


procedure TFrmMain.ClearEntireSection1Click(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ClearEntireSection1Click');
   {$endif}
   if MessageDlg('Clear Section' +#13#13+
        'This process will remove all voxels from the current section.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;

   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;
   Document.ActiveSection^.Clear;
   SetVoxelChanged(true);
   RefreshAll;
end;

procedure TFrmMain.VXLSEHelp1Click(Sender: TObject);
begin
   if not fileexists(extractfiledir(paramstr(0))+'/help.chm') then
   begin
      messagebox(0,'VXLSE Help' + #13#13 + 'help.chm not found','VXLSE Help',0);
      exit;
   end;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: VXLSEHelp1Click');
   {$endif}
   RunAProgram('help.chm','',extractfiledir(paramstr(0)));
end;

procedure TFrmMain.Display3dView1Click(Sender: TObject);
begin

   Display3dView1.Checked := not Display3dView1.Checked;
   Disable3dView1.Checked := Display3dView1.Checked;
   Env.SetIsEnabled(not Display3dView1.Checked);

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Display3DView1Click');
   {$endif}
   if Display3dView1.Checked then
   begin
      if (p_Frm3DPreview = nil) and (p_Frm3DModelizer = nil) then
      begin
         Application.OnIdle := nil;
      end
      else
      begin
         Application.OnIdle := Idle;
      end;
   end
   else
   begin
      Application.OnIdle := Idle;
   end;
   OGL3DPreview.Refresh;
end;

procedure TFrmMain.About1Click(Sender: TObject);
var
   frm: TLoadFrm;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: About1Click');
   {$endif}
   frm:=TLoadFrm.Create(Self);
   frm.Visible:=False;
   if testbuild then
      frm.Label4.Caption := APPLICATION_VER + ' TB '+testbuildversion
   else
      frm.Label4.Caption := APPLICATION_VER;
   frm.Image2.Visible := false;
   frm.butOK.Visible:=True;
   frm.Loading.Caption:='';
   frm.ShowModal;
   frm.Close;
   frm.Free;
end;

procedure TFrmMain.FlipZswitchFrontBack1Click(Sender: TObject);
begin
   //Create a transformation matrix...
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Document.ActiveSection^.FlipMatrix([1,1,-1],[0,0,1]);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.FillUselessInternalCavesVeryStrict1Click(Sender: TObject);
var
   Tool: TFillUselessGapsTool;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FillUselessInternalGapsVeryStrict1Click');
   {$endif}
   // ensure the user wants to do this!
   if MessageDlg('Fill Useless Internal Caves (Aggressive)' +#13#13+
        'This process will add black voxels at caves that are hidden from view.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Tool := TFillUselessGapsTool.Create(Document.ActiveSection^);
   Tool.FillCaves(Document.ActiveSection^,0,4,63);
   Tool.Free;

   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.FillUselessInternalGaps1Click(Sender: TObject);
var
   Tool: TFillUselessGapsTool;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FillUselessInternalGaps1Click');
   {$endif}
   // ensure the user wants to do this!
   if MessageDlg('Fill Useless Internal Caves (Conservative)' +#13#13+
        'This process will add black voxels at caves that are hidden from view.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Tool := TFillUselessGapsTool.Create(Document.ActiveSection^);
   Tool.FillCaves(Document.ActiveSection^);
   Tool.Free;

   RefreshAll;
   SetVoxelChanged(true);

end;

procedure TFrmMain.FlipXswitchRightLeft1Click(Sender: TObject);
begin
   //Create a transformation matrix...
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Document.ActiveSection^.FlipMatrix([-1,1,1],[1,0,0]);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.FlipYswitchTopBottom1Click(Sender: TObject);
begin
   //Create a transformation matrix...
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Document.ActiveSection^.FlipMatrix([1,-1,1],[0,1,0]);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.MirrorBottomToTop1Click(Sender: TObject);
var
   FlipFirst: Boolean;
begin
   FlipFirst:=False;
   if (Sender.ClassNameIs('TMenuItem')) then
   begin
      if CompareStr((Sender as TMenuItem).Name,'MirrorTopToBottom1')=0 then
      begin
         //flip first!
         FlipFirst:=True;
      end;
  end;

  CreateVXLRestorePoint(Document.ActiveSection^,Undo);
  UpdateUndo_RedoState;

  //Based on the current view...
  case Document.ActiveSection^.View[0].GetViewNameIdx of
    0:
    begin
      if not FlipFirst then Document.ActiveSection^.FlipMatrix([1,1,-1],[0,0,1]);
      Document.ActiveSection^.Mirror(oriZ);
    end;
    1:
    begin
      if not FlipFirst then Document.ActiveSection^.FlipMatrix([1,1,-1],[0,0,1]);
      Document.ActiveSection^.Mirror(oriZ);
    end;
    2:
    begin
      if not FlipFirst then Document.ActiveSection^.FlipMatrix([1,1,-1],[0,0,1]);
      Document.ActiveSection^.Mirror(oriZ);
    end;
    3:
    begin
      if not FlipFirst then Document.ActiveSection^.FlipMatrix([1,1,-1],[0,0,1]);
      Document.ActiveSection^.Mirror(oriZ);
    end;
    4:
    begin
      if not FlipFirst then Document.ActiveSection^.FlipMatrix([1,-1,1],[0,1,0]);
      Document.ActiveSection^.Mirror(oriY);
    end;
    5:
    begin
      if not FlipFirst then Document.ActiveSection^.FlipMatrix([1,-1,1],[0,1,0]);
      Document.ActiveSection^.Mirror(oriY);
    end;
  end;

  RefreshAll;
  SetVoxelChanged(true);
end;

procedure TFrmMain.MirrorLeftToRight1Click(Sender: TObject);
var
   FlipFirst: Boolean;
begin
   FlipFirst:=False;
   if (Sender.ClassNameIs('TMenuItem')) then
   begin
      if CompareStr((Sender as TMenuItem).Name,'MirrorLeftToRight1')=0 then
      begin
         //flip first!
         FlipFirst:=True;
//       ActiveSection.FlipMatrix([1,-1,1],[0,1,0]);
      end;
   end;

   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   //Based on the current view...
   case Document.ActiveSection^.View[0].GetViewNameIdx of
      0:
      begin
         if FlipFirst then
            Document.ActiveSection^.FlipMatrix([1,-1,1],[0,1,0]);
         Document.ActiveSection^.Mirror(oriY);
      end;
      1:
      begin
         //reverse here :) (reversed view, that's why!)
         if not FlipFirst then
            Document.ActiveSection^.FlipMatrix([1,-1,1],[0,1,0]);
         Document.ActiveSection^.Mirror(oriY);
      end;
      2:
      begin
         if FlipFirst then
            Document.ActiveSection^.FlipMatrix([-1,1,1],[1,0,0]);
         Document.ActiveSection^.Mirror(oriX);
      end;
      3:
      begin
         if not FlipFirst then
            Document.ActiveSection^.FlipMatrix([-1,1,1],[1,0,0]);
         Document.ActiveSection^.Mirror(oriX);
      end;
      4:
      begin
         if FlipFirst then
            Document.ActiveSection^.FlipMatrix([-1,1,1],[1,0,0]);
         Document.ActiveSection^.Mirror(oriX);
      end;
      5:
      begin
         if not FlipFirst then
            Document.ActiveSection^.FlipMatrix([-1,1,1],[1,0,0]);
         Document.ActiveSection^.Mirror(oriX);
      end;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.MirrorBackToFront1Click(Sender: TObject);
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   FlipZswitchFrontBack1Click(Sender);
   Document.ActiveSection^.Mirror(oriZ);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.MirrorFrontToBack1Click(Sender: TObject);
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Document.ActiveSection^.Mirror(oriZ);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.Nudge1Left1Click(Sender: TObject);
var
   i: Integer;
   NR: Array[0..2] of Single;
begin
   NR[0]:=0; NR[1]:=0; NR[2]:=0;
   if (Sender.ClassNameIs('TMenuItem')) then
   begin
      if (CompareStr((Sender as TMenuItem).Name,'Nudge1Left1')=0) or (CompareStr((Sender as TMenuItem).Name,'Nudge1Right1')=0) then
      begin
         //left and right
         case Document.ActiveSection^.View[0].GetViewNameIdx of
            0: NR[2]:=1;
            1: NR[2]:=-1;
            2: NR[2]:=-1;
            3: NR[2]:=-1;
            4: NR[0]:=1;
            5: NR[0]:=-1;
         end;
         if CompareStr((Sender as TMenuItem).Name,'Nudge1Right1')=0 then
         begin
            for i:=0 to 2 do
            begin
               NR[i]:=-NR[i];
            end;
         end;
      end
      else
      begin
         //up and down
         case Document.ActiveSection^.View[0].GetViewNameIdx of
            0: NR[1]:=-1;
            1: NR[1]:=-1;
            2: NR[0]:=1;
            3: NR[0]:=-1;
            4: NR[1]:=-1;
            5: NR[1]:=-1;
         end;
         if CompareStr((Sender as TMenuItem).Name,'Nudge1up1')=0 then
         begin
            for i:=0 to 2 do
            begin
               NR[i]:=-NR[i];
            end;
         end;
      end;
   end;

   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Document.ActiveSection^.FlipMatrix([1,1,1],NR,False);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.RotateYawNegativeClick(Sender: TObject);
var
   i: Integer;
   Matrix: BasicMathsTypes.TGLMatrixf4;
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Matrix[0,1] := 1;
   Matrix[1,0] := -1;
   Matrix[2,2] := 1;
   Matrix[3,3] := 1;

   SetIsEditable(false);
   Document.ActiveSection^.ApplyMatrix(Matrix, not MaintainDimensions1.Checked);
   SetIsEditable(true);
   if not MaintainDimensions1.Checked then
   begin
      UpdateViews;
      SetupStatusBar;
      CursorReset;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.RotateYawPositiveClick(Sender: TObject);
var
   i: Integer;
   Matrix: BasicMathsTypes.TGLMatrixf4;
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Matrix[0,1] := -1;
   Matrix[1,0] := 1;
   Matrix[2,2] := 1;
   Matrix[3,3] := 1;

   SetIsEditable(false);
   Document.ActiveSection^.ApplyMatrix(Matrix, not MaintainDimensions1.Checked);
   SetIsEditable(true);
   if not MaintainDimensions1.Checked then
   begin
      UpdateViews;
      SetupStatusBar;
      CursorReset;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.RotatePitchNegativeClick(Sender: TObject);
var
   i: Integer;
   Matrix: BasicMathsTypes.TGLMatrixf4;
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Matrix[0,2] := -1;
   Matrix[2,0] := 1;
   Matrix[1,1] := 1;
   Matrix[3,3] := 1;

   SetIsEditable(false);
   Document.ActiveSection^.ApplyMatrix(Matrix, not MaintainDimensions1.Checked);
   SetIsEditable(true);
   if not MaintainDimensions1.Checked then
   begin
      UpdateViews;
      SetupStatusBar;
      CursorReset;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.RotatePitchPositiveClick(Sender: TObject);
var
   i: Integer;
   Matrix: BasicMathsTypes.TGLMatrixf4;
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Matrix[0,2] := 1;
   Matrix[2,0] := -1;
   Matrix[1,1] := 1;
   Matrix[3,3] := 1;

   SetIsEditable(false);
   Document.ActiveSection^.ApplyMatrix(Matrix, not MaintainDimensions1.Checked);
   SetIsEditable(true);
   if not MaintainDimensions1.Checked then
   begin
      UpdateViews;
      SetupStatusBar;
      CursorReset;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.RotateRollNegativeClick(Sender: TObject);
var
   i: Integer;
   Matrix: BasicMathsTypes.TGLMatrixf4;
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Matrix[1,2] := 1;
   Matrix[2,1] := -1;
   Matrix[0,0] := 1;
   Matrix[3,3] := 1;

   SetIsEditable(false);
   Document.ActiveSection^.ApplyMatrix(Matrix, not MaintainDimensions1.Checked);
   SetIsEditable(true);
   if not MaintainDimensions1.Checked then
   begin
      UpdateViews;
      SetupStatusBar;
      CursorReset;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.RotateRollPositiveClick(Sender: TObject);
var
   i: Integer;
   Matrix: BasicMathsTypes.TGLMatrixf4;
begin
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   Matrix[1,2] := -1;
   Matrix[2,1] := 1;
   Matrix[0,0] := 1;
   Matrix[3,3] := 1;

   SetIsEditable(false);
   Document.ActiveSection^.ApplyMatrix(Matrix, not MaintainDimensions1.Checked);
   SetIsEditable(true);
   if not MaintainDimensions1.Checked then
   begin
      UpdateViews;
      SetupStatusBar;
      CursorReset;
   end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.Section2Click(Sender: TObject);
var
  i, SectionIndex: Integer;
  FrmNewSectionSize: TFrmNewSectionSize;
  OldVoxelType : TVoxelType;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Section2Click');
   {$endif}
   FrmNewSectionSize:=TFrmNewSectionSize.Create(Self);
   with FrmNewSectionSize do
   begin
      ShowModal;
      if aborted then Exit;
      if MessageDlg('Create Section' + #13#13+ 'Are you sure you want to create a section: ' + #13#13 +
             'Name: ' + AsciizToStr(Name,16) + Chr(10) +
             'Size: ' + IntToStr(X) + 'x' + IntToStr(Y) + 'x' + IntToStr(Z),
             mtConfirmation,[mbYes,mbNo],0) = mrNo then
         exit;

      SetisEditable(False);

      SectionIndex:=Document.ActiveSection^.Header.Number;
      if not before then //after
         Inc(SectionIndex);

      OldVoxelType := VoxelType;
      VoxelType := vtAir;
      Document.ActiveVoxel^.InsertSection(SectionIndex,Name,X,Y,Z);

      SectionCombo.Items.Clear;
      for i:=0 to Document.ActiveVoxel^.Header.NumSections-1 do
      begin
         SectionCombo.Items.Add(Document.ActiveVoxel^.Section[i].Name);
      end;

      Document.ActiveVoxel^.Section[SectionIndex].Tailer.NormalsType := Document.ActiveVoxel^.Section[0].Tailer.NormalsType;
      Document.ActiveHVA^.InsertSection(SectionIndex);

      VoxelType := OldVoxelType;
      //MajorRepaint;
      SectionCombo.ItemIndex:=SectionIndex;
      SectionComboChange(Self);

      ResetUndoRedo;
      SetisEditable(True);
      SetVoxelChanged(true);
   end;
   FrmNewSectionSize.Free;
end;

procedure TFrmMain.Copyofthissection1Click(Sender: TObject);
var
   i, SectionIndex,x,y,z : Integer;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CopyOfThisSection1Click');
   {$endif}
   if MessageDlg('Copy Section' + #13#13+ 'Are you sure you want to make a copy of the current section?',
             mtConfirmation,[mbYes,mbNo],0) = mrNo then
      exit;

   SectionIndex:=Document.ActiveSection^.Header.Number;
   Inc(SectionIndex);

   ResetUndoRedo;
   UpdateUndo_RedoState;

   Document.ActiveVoxel^.InsertSection(SectionIndex,'Copy Of '+Document.ActiveVoxel^.Section[SectionIndex-1].Name,Document.ActiveVoxel^.Section[SectionIndex-1].Tailer.XSize,Document.ActiveVoxel^.Section[SectionIndex-1].Tailer.YSize,Document.ActiveVoxel^.Section[SectionIndex-1].Tailer.ZSize);
   Document.ActiveHVA^.InsertSection(SectionIndex);
   Document.ActiveHVA^.CopySection(SectionIndex-1,SectionIndex);

   for x := 0 to (Document.ActiveVoxel^.Section[SectionIndex-1].Tailer.XSize - 1) do
      for y := 0 to (Document.ActiveVoxel^.Section[SectionIndex-1].Tailer.YSize - 1) do
         for z := 0 to (Document.ActiveVoxel^.Section[SectionIndex-1].Tailer.ZSize - 1) do
            Document.ActiveVoxel^.Section[SectionIndex].Data[x,y,z] := Document.ActiveVoxel^.Section[SectionIndex-1].Data[x,y,z];

   with Document.ActiveVoxel^.Section[SectionIndex-1].Tailer do
   begin
      Document.ActiveVoxel^.Section[SectionIndex].Tailer.Det := Det;
      for x := 1 to 3 do
      begin
         Document.ActiveVoxel^.Section[SectionIndex].Tailer.MaxBounds[x] := MaxBounds[x];
         Document.ActiveVoxel^.Section[SectionIndex].Tailer.MinBounds[x] := MinBounds[x];
      end;
      Document.ActiveVoxel^.Section[SectionIndex].Tailer.SpanDataOfs := SpanDataOfs;
      Document.ActiveVoxel^.Section[SectionIndex].Tailer.SpanEndOfs := SpanEndOfs;
      Document.ActiveVoxel^.Section[SectionIndex].Tailer.SpanStartOfs := SpanStartOfs;
      for x := 1 to 3 do
         for y := 1 to 4 do
            Document.ActiveVoxel^.Section[SectionIndex].Tailer.Transform[x,y] := Transform[x,y];

      Document.ActiveVoxel^.Section[SectionIndex].Tailer.NormalsType := NormalsType;
   end;

   SectionCombo.Items.Clear;
   for i:=0 to Document.ActiveVoxel^.Header.NumSections-1 do
   begin
      SectionCombo.Items.Add(Document.ActiveVoxel^.Section[i].Name);
   end;

   //MajorRepaint;
   SectionCombo.ItemIndex:=SectionIndex;
   SectionComboChange(Self);
   SetVoxelChanged(true);
end;

procedure TFrmMain.CropSection1Click(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CropSection1Click');
   {$endif}
   SetisEditable(False);
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   // Here we do the crop
   Document.ActiveSection^.Crop;
   SetisEditable(True);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.mnuHistoryClick(Sender: TObject);
var
   p: ^TMenuItem;
   s,VoxelName : string;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: MenuHistoryClick');
   {$endif}
   if Sender.ClassNameIs('TMenuItem') then
   begin //check to see if it is this class
      //and now do some dirty things with pointers...
      p:=@Sender;
      s := Configuration.GetHistory(p^.Tag);

      if not fileexists(s) then
      begin
         Messagebox(0,'File Doesn''t Exist','Load Voxel',0);
         exit;
      end;

      VoxelName := Configuration.GetHistory(p^.Tag);
      OpenVoxelInterface(VoxelName);
   end;
end;

procedure TFrmMain.BuildReopenMenu;
var
   i : integer;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: BuildReopenMenu');
   {$endif}
   Configuration := TConfiguration.Create;
   for i:=HistoryDepth - 1 downto 0 do
   begin
      mnuHistory[i]:=TMenuItem.Create(Self);
      mnuHistory[i].OnClick:=mnuHistoryClick;
      mnuReOpen.Insert(0,mnuHistory[i]);
   end;
   UpdateHistoryMenu;
end;

procedure TFrmMain.BarReopenClick(Sender: TObject);
begin
   //ReOpen1.Caption := Configuration.GetHistory(0);
end;

procedure TFrmMain.iberianSunPalette1Click(Sender: TObject);
begin
   ApplyPalette(ExtractFileDir(ParamStr(0)) + '\palettes\TS\unittem.pal');
end;

procedure TFrmMain.RedAlert2Palette1Click(Sender: TObject);
begin
   ApplyPalette(ExtractFileDir(ParamStr(0)) + '\palettes\RA2\unittem.pal');
end;

procedure TFrmMain.ApplyPalette(const _Filename: string);
begin
   Document.Palette^.LoadPalette(_Filename);
   if Actor <> nil then
      Actor^.ChangePalette(_Filename);
   if p_Frm3DPreview <> nil then
   begin
      p_Frm3DPreview^.Actor^.ChangePalette(_Filename);
   end;
   cnvPalette.Repaint;
   RefreshAll;
end;


procedure TFrmMain.AutoUpdate1Click(Sender: TObject);
begin
   // We'll test it later.
end;

Procedure TFrmMain.LoadPalettes;
var
   c : integer;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: LoadPalettes');
   {$endif}
   PaletteControl := TPaletteControl.Create(Owner, blank1Click);

   // prepare
   c := 0;

   // Now Load TS Palettes
   PaletteControl.AddPalettesToSubMenu(TSPalettes, ExtractFilePath(ParamStr(0))+'Palettes\TS\', c, 15);
   // Now Load RA2 Palettes
   PaletteControl.AddPalettesToSubMenu(RA2Palettes, ExtractFilePath(ParamStr(0))+'Palettes\RA2\', c, 16);
   // Now Load User's Palettes
   PaletteControl.AddPalettesToSubMenu(Custom1, ExtractFilePath(ParamStr(0))+'Palettes\User\', c, 39);
end;

procedure TFrmMain.UpdatePaletteList1Click(Sender: TObject);
var
   c : integer;
begin
   c := 0;
   PaletteControl.ResetPaletteSchemes;
   PaletteControl.UpdatePalettesAtSubMenu(TSPalettes, ExtractFilePath(ParamStr(0))+'Palettes\TS\', c, 15);
   PaletteControl.UpdatePalettesAtSubMenu(RA2Palettes, ExtractFilePath(ParamStr(0))+'Palettes\RA2\', c, 16);
   PaletteControl.UpdatePalettesAtSubMenu(Custom1, ExtractFilePath(ParamStr(0))+'Palettes\User\', c, 39);
end;

procedure TFrmMain.blank1Click(Sender: TObject);
begin
   ApplyPalette(PaletteControl.PaletteSchemes[TMenuItem(Sender).tag].Filename);
end;

Function TFrmMain.CheckVXLChanged: Boolean;
var
   T : string;
   Answer: integer;
begin
   if VXLChanged then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: CheckVXLChanged');
      {$endif}
      T := ExtractFileName(VXLFilename);
      if t = '' then
         T := 'Do you want to save Untitled'
      else
         T := 'Do you want to save changes in ' + T;
      Answer := MessageDlg('Last changes were not saved. ' + T + '? Answer YES to save and exit, NO to exit without saving and CANCEL to not exit nor save.',mtWarning,[mbYes,mbNo,mbCancel],0);
      if Answer = mrYes then
      begin
         Save1.Click;
      end;
      Result := Answer <> MrCancel;
   end
   else
      Result := true;
end;

procedure TFrmMain.SpeedButton7Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Darken);
end;

procedure TFrmMain.SpeedButton12Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Lighten);
end;

procedure TFrmMain.SpeedButton13Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_FloodFillErase);
end;

procedure TFrmMain.SpeedButton14Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_Measure);
end;

Procedure TFrmMain.SetDarkenLighten(Value : integer);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetDarkenLighten');
   {$endif}
   DarkenLighten := Value;
   N110.Checked := false;
   N21.Checked := false;
   N31.Checked := false;
   N41.Checked := false;
   N51.Checked := false;

   if Value = 1 then
      N110.Checked := true
   else if Value = 2 then
      N21.Checked := true
   else if Value = 3 then
      N31.Checked := true
   else if Value = 4 then
      N41.Checked := true
   else if Value = 5 then
      N51.Checked := true;
end;

procedure TFrmMain.N110Click(Sender: TObject);
begin
   SetDarkenLighten(1);
end;

procedure TFrmMain.N21Click(Sender: TObject);
begin
   SetDarkenLighten(2);
end;

procedure TFrmMain.N31Click(Sender: TObject);
begin
   SetDarkenLighten(3);
end;

procedure TFrmMain.N41Click(Sender: TObject);
begin
   SetDarkenLighten(4);
end;

procedure TFrmMain.N51Click(Sender: TObject);
begin
   SetDarkenLighten(5);
end;

procedure TFrmMain.ToolButton11Click(Sender: TObject);
var
   x,y,z : integer;
   v : tvoxelunpacked;
begin
   if not isEditable then exit;

   if MessageDlg('Clear Voxel Colour' +#13#13+
        'This process will clear the voxels colours/normals with the currently selected colour.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ToolButton1Click');
   {$endif}
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   for x := 0 to Document.ActiveSection^.Tailer.XSize-1 do
      for y := 0 to Document.ActiveSection^.Tailer.YSize-1 do
         for z := 0 to Document.ActiveSection^.Tailer.ZSize-1 do
         begin
            Document.ActiveSection^.GetVoxel(x,y,z,v);
            if SpectrumMode = ModeColours then
               v.Colour := ActiveColour
            else
               v.Normal := ActiveNormal;
            Document.ActiveSection^.SetVoxel(x,y,z,v);
         end;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.ClearLayer1Click(Sender: TObject);
begin
   if not isEditable then exit;

   if MessageDlg('Clear Layer' +#13#13+
        'This process will remove all voxels from the current layer.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ClearLayer1Click');
   {$endif}
   ClearVXLLayer(Document.ActiveSection^);

   UpdateUndo_RedoState;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.Copy1Click(Sender: TObject);
begin
   if not isEditable then exit;

   VXLCopyToClipboard(Document.ActiveSection^);
end;

procedure TFrmMain.Cut1Click(Sender: TObject);
begin
   if not isEditable then exit;

   VXLCutToClipboard(Document.ActiveSection^);
   UpdateUndo_RedoState;
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.ClearUndoSystem1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ClearUndoSystem1Click');
   {$endif}
   ResetUndoRedo;
   UpdateUndo_RedoState;
end;

procedure TFrmMain.PasteFull1Click(Sender: TObject);
begin
   if not isEditable then exit;

   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   PasteFullVXL(Document.ActiveSection^);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.Paste1Click(Sender: TObject);
begin
   if not isEditable then exit;

   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   // --- 1.2: Removed
   // PasteFullVXL(ActiveSection);
   // --- Replaced with
   PasteVXL(Document.ActiveSection^);
   RefreshAll;
   SetVoxelChanged(true);
end;

function TFrmMain.CreateSplitterMenuItem: TMenuItem;
begin
   Result := TMenuItem.Create(Owner);
   Result.Caption := '-';
end;

function TFrmMain.UpdateCScheme : integer;
begin
   CustomSchemeControl.ResetColourSchemes;
   Result := CustomSchemeControl.UpdateCSchemes(PalPack1, ExtractFilePath(ParamStr(0))+'\cschemes\PalPack1\',0, true, true);
   Result := CustomSchemeControl.UpdateCSchemes(PalPack1, ExtractFilePath(ParamStr(0))+'\cschemes\PalPack2\',Result, true, false);
   Result := CustomSchemeControl.UpdateCSchemes(Apollo1, ExtractFilePath(ParamStr(0))+'\cschemes\Apollo\',Result, true, true);
   Result := CustomSchemeControl.UpdateCSchemes(ColourScheme1, ExtractFilePath(ParamStr(0))+'\cschemes\USER\',Result, true, true);
end;

function TFrmMain.LoadCScheme : integer;
begin
   // New Custom Scheme loader goes here.
   CustomSchemeControl := TCustomSchemeControl.Create(Owner, blank2Click);
   Result := CustomSchemeControl.LoadCSchemes(PalPack1, ExtractFilePath(ParamStr(0))+'\cschemes\PalPack1\',0, false);
   Result := CustomSchemeControl.LoadCSchemes(PalPack1, ExtractFilePath(ParamStr(0))+'\cschemes\PalPack2\',Result, false);
   Result := CustomSchemeControl.LoadCSchemes(Apollo1, ExtractFilePath(ParamStr(0))+'\cschemes\Apollo\',Result, false);
   Result := CustomSchemeControl.LoadCSchemes(ColourScheme1, ExtractFilePath(ParamStr(0))+'\cschemes\USER\',Result, false);
end;

procedure TFrmMain.blank2Click(Sender: TObject);
var
   x,y,z : integer;
   V : TVoxelUnpacked;
   Scheme : TCustomScheme;
   Data : TCustomSchemeData;
begin
   Scheme := TCustomScheme.CreateForData(CustomSchemeControl.ColourSchemes[Tmenuitem(Sender).Tag].Filename);
   Data := Scheme.Data;

   tempview.Data_no := tempview.Data_no +0;
   setlength(tempview.Data,tempview.Data_no +0);

   for x := 0 to Document.ActiveSection^.Tailer.XSize-1 do
      for y := 0 to Document.ActiveSection^.Tailer.YSize-1 do
         for z := 0 to Document.ActiveSection^.Tailer.ZSize-1 do
         begin
            Document.ActiveSection^.GetVoxel(x,y,z,v);
            if v.Used then
            begin
               V.Colour := Data[V.Colour];
               tempview.Data_no := tempview.Data_no +1;
               setlength(tempview.Data,tempview.Data_no +1);
               tempview.Data[tempview.Data_no].VC.X := x;
               tempview.Data[tempview.Data_no].VC.Y := y;
               tempview.Data[tempview.Data_no].VC.Z := z;
               tempview.Data[tempview.Data_no].VU := true;
               tempview.Data[tempview.Data_no].V := v;
            end;
         end;

   Scheme.Free;
   ApplyTempView(Document.ActiveSection^);
   UpdateUndo_RedoState;
   RefreshAll;
end;

procedure TFrmMain.About2Click(Sender: TObject);
var
   frm: TFrmPalettePackAbout;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: About2Click');
   {$endif}
   frm:=TFrmPalettePackAbout.Create(Self);
   frm.Visible:=False;
   frm.ShowModal;
   frm.Close;
   frm.Free;
end;

procedure TFrmMain.EmptyVoxel1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: EmptyVoxel1Click');
   {$endif}
   NewVFile(2);
end;

procedure TFrmMain.EmptyVoxel2Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: EmptyVoxel2Click');
   {$endif}
   NewVFile(4);
end;

Procedure TFrmMain.NewVFile(Game : integer);
var
   FrmNew: TFrmNew;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: NewVFile');
   {$endif}
   IsVXLLoading := true;
   Application.OnIdle := nil;
   CheckVXLChanged;

   FrmNew:=TFrmNew.Create(Self);
   with FrmNew do
   begin
      //FrmNew.Caption := ' New Voxel File';
      Label9.Caption := 'New Voxel';
      Label9.Caption := 'Enter the size you want the voxel to be';
      //grpCurrentSize.Left := 400;
      grpCurrentSize.Visible := false;
      //grpNewSize.Width := 201;
      grpNewSize.Left := (FrmNew.Width div 2) - (grpNewSize.Width div 2);
      grpNewSize.Caption := 'Size';
      BtCancel.Visible := false;
      BtOK.Left := BtCancel.Left;
      Image1.Picture := TopBarImageHolder.Picture;
      //grpCurrentSize.Visible := true;
      grpVoxelType.Visible := true;

      x := 10;//ActiveSection.Tailer.XSize;
      y := 10;//ActiveSection.Tailer.YSize;
      z := 10;//ActiveSection.Tailer.ZSize;
      ShowModal;
   end;

   // 1.3: Before creating the new voxel, we add the type support.
   if FrmNew.rbLand.Checked then
      VoxelType := vtLand
   else
      VoxelType := vtAir;

   SetIsEditable(NewVoxel(Document,Game,FrmNew.x,FrmNew.y,FrmNew.z));

   if IsEditable then
      DoAfterLoadingThings;

   IsVXLLoading := false;
end;

Procedure TFrmMain.SetCursor;
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SetCursor');
   {$endif}
   //CnvView[0].Cursor := Mouse_Current;
   if VXLTool = VXLTool_Brush then
      if VXLBrush = 4 then
         Mouse_Current := MouseSpray
      else
         Mouse_Current := MouseDraw
   else if VXLTool = VXLTool_Line then
      Mouse_Current := MouseLine
   else if VXLTool = VXLTool_Erase then
      if VXLBrush = 4 then
         Mouse_Current := MouseSpray
      else
         Mouse_Current := MouseDraw
   else if VXLTool = VXLTool_FloodFill then
      Mouse_Current := MouseFill
   else if VXLTool = VXLTool_FloodFillErase then
      Mouse_Current := MouseFill
   else if VXLTool = VXLTool_Dropper then
      Mouse_Current := MouseDropper
   else if VXLTool = VXLTool_Rectangle then
      Mouse_Current := MouseLine
   else if VXLTool = VXLTool_FilledRectangle then
      Mouse_Current := MouseLine
   else if VXLTool = VXLTool_Darken then
      if VXLBrush = 4 then
         Mouse_Current := MouseSpray
      else
         Mouse_Current := MouseDraw
   else if VXLTool = VXLTool_Lighten then
      if VXLBrush = 4 then
         Mouse_Current := MouseSpray
      else
         Mouse_Current := MouseDraw
   else if VXLTool = VXLTool_SmoothNormal then
      if VXLBrush = 4 then
         Mouse_Current := MouseSpray
      else
         Mouse_Current := MouseSmoothNormal;

   if not iseditable then
      Mouse_Current := crDefault;
end;

procedure TFrmMain.DisableDrawPreview1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: DisableDrawPreview1Click');
   {$endif}
   DisableDrawPreview1.Checked := not DisableDrawPreview1.Checked;
end;

procedure TFrmMain.SmoothNormals1Click(Sender: TObject);
begin
   if not isEditable then exit;

   // ask the user to confirm
   if MessageDlg('Smooth Normals v1.0' +#13#13+
        'This process will modify the voxel''s normals.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then
      Exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: SmoothNormals1Click');
   {$endif}
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;
   SmoothVXLNormals(Document.ActiveSection^);
   RefreshAll;
   SetVoxelChanged(true);
end;

procedure TFrmMain.VoxelTexture1Click(Sender: TObject);
var
   frm: TFrmVoxelTexture;
begin
   if not isEditable then exit;
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: VoxelTexture1Click');
   {$endif}
   frm:=TFrmVoxelTexture.Create(Self);
   frm.Visible:=False;
   frm.Image3.Picture := TopBarImageHolder.Picture;
   frm.ShowModal;
   frm.Close;
   frm.Free;
end;

procedure TFrmMain.opologyAnalysis1Click(Sender: TObject);
var
   Frm : TFrmTopologyAnalysis;
begin
   Frm := TFrmTopologyAnalysis.Create(Document.ActiveSection^,self);
   Frm.ShowModal;
   Frm.Close;
   Frm.Free;
end;

procedure TFrmMain.OpenHyperlink(HyperLink: PChar);
begin
   ShellExecute(Application.Handle,nil,HyperLink,'','',SW_SHOWNORMAL);
end;

procedure TFrmMain.CnCSource1Click(Sender: TObject);
begin
   OpenHyperLink('http://www.cnc-source.com/');
end;

procedure TFrmMain.PPMForUpdates1Click(Sender: TObject);
begin
   OpenHyperLink('http://www.ppmsite.com/index.php?go=vxlseinfo');
end;

procedure TFrmMain.LoadSite(Sender : TObject);
begin
   OpenHyperlink(PChar(FrmMain.SiteList[TMenuItem(Sender).Tag].SiteUrl));
end;

procedure TFrmMain.ProjectSVN1Click(Sender: TObject);
begin
   OpenHyperLink('http://svn.ppmsite.com/');
end;


procedure TFrmMain.test1Click(Sender: TObject);
begin
//   Update3dViewVOXEL(Document.ActiveVoxel^);
end;

procedure TFrmMain.ImportSectionFromVoxel(const _Filename: string);
var
   TempDocument : TVoxelDocument;
   i, SectionIndex,tempsectionindex: Integer;
   frm: Tfrmimportsection;
begin
   TempDocument := TVoxelDocument.Create(_FileName);
   if TempDocument.ActiveVoxel = nil then
   begin
      TempDocument.Free;
      exit;
   end;
   tempsectionindex := 0;
   if TempDocument.ActiveVoxel^.Header.NumSections > 1 then
   begin
      frm:=Tfrmimportsection.Create(Self);
      frm.Visible:=False;

      frm.ComboBox1.Items.Clear;
      for i:=0 to TempDocument.ActiveVoxel^.Header.NumSections-1 do
      begin
         frm.ComboBox1.Items.Add(TempDocument.ActiveVoxel^.Section[i].Name);
      end;
      frm.ComboBox1.ItemIndex:=0;
      frm.ShowModal;
      tempsectionindex := frm.ComboBox1.ItemIndex;
      frm.Free;
   end;
   SetIsEditable(false);
   SectionIndex:=Document.ActiveSection^.Header.Number;
   Inc(SectionIndex);
   Document.ActiveVoxel^.InsertSection(SectionIndex,TempDocument.ActiveVoxel^.Section[tempsectionindex].Name,TempDocument.ActiveVoxel^.Section[tempsectionindex].Tailer.XSize,TempDocument.ActiveVoxel^.Section[tempsectionindex].Tailer.YSize,TempDocument.ActiveVoxel^.Section[tempsectionindex].Tailer.ZSize);
   Document.ActiveVoxel^.Section[SectionIndex].Assign(TempDocument.ActiveVoxel^.Section[tempsectionindex]);
   Document.ActiveVoxel^.Section[SectionIndex].Header.Number := SectionIndex;
   Document.ActiveHVA^.InsertSection(SectionIndex);
   Document.ActiveHVA^.CopySection(tempsectionindex,SectionIndex,TempDocument.ActiveHVA^);
   //MajorRepaint;
   SectionCombo.ItemIndex:=SectionIndex;
   SectionComboChange(Self);

   ResetUndoRedo;
   UpdateUndo_RedoState;
   SetIsEditable(true);

   SetupSections;
   SetVoxelChanged(true);
end;

procedure TFrmMain.ImagewithHeightmap1Click(Sender: TObject);
var
   Frm: TFrmHeightmap;
   Img,Hmap : TBitmap;
   x,y,z,h,curr: integer;
   v : tvoxelunpacked;
begin
   Frm := TFrmHeightmap.Create(self);
   Frm.ShowModal;
   if Frm.OK then
   begin
      if FileExists(Frm.EdImage.Text) and FileExists(Frm.EdHeightmap.Text) then
      begin
         Img := GetBMPFromImageFile(Frm.EdImage.Text);
         Hmap := GetBMPFromImageFile(Frm.EdHeightmap.Text);
         if Assigned(Img) and Assigned(Hmap) then
         begin
            if (Img.Height = Hmap.Height) and (Img.Width = Hmap.Width) then
            begin
               if (Img.Height > 255) or (Img.Width > 255) then
               begin
                  ResizeBitmap(Img,255,255,0);
                  ResizeBitmap(Hmap,255,255,0);
               end;
               // We are creating a new voxel file.
               IsVXLLoading := true;
               Application.OnIdle := nil;
               CheckVXLChanged;
               VoxelType := vtLand;
               z := 0;
               for x := 0 to Img.Width - 1 do
                  for y := 0 to Img.Height - 1 do
                  begin
                     curr := GetBValue(HMap.Canvas.Pixels[x,y]);
                     if curr > z then
                     begin
                        z := curr;
                     end;
                  end;
               if z = 255 then
                  z := 254;
               if (NewVoxel(Document,4,Img.Width,Img.Height,z+1))then
               begin
                  VoxelOpen := false;
                  VXLChanged := false;
                  h := Img.Height - 1;
                  for x := 0 to Img.Width - 1 do
                     for y := 0 to Img.Height - 1 do
                     begin
                        z := GetBValue(HMap.Canvas.Pixels[x,y]);
                        if z = 255 then
                           z := 254;
                        Document.ActiveSection^.GetVoxel(x,h-y,z,v);
                        v.Used := true;
                        v.Colour := Document.Palette^.GetColourFromPalette(Img.Canvas.Pixels[x,y]);
                        v.Normal := 0;
                        Document.ActiveSection^.SetVoxel(x,h-y,z,v);
                     end;
                  SetIsEditable(true);
                  VoxelOpen := true;
                  SetVoxelChanged(true);
                  DoAfterLoadingThings;
               end;
               IsVXLLoading := false;
            end;
         end;
         Img.Free;
         Hmap.Free;
      end;
   end;
   Frm.Release;
end;

procedure TFrmMain.Importfromamodelusing3ds2vxl1Click(Sender: TObject);
var
   Destination : string;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Importfromamodelusing3ds2vxl1Click');
   {$endif}
   if GetVoxelImportedBy3ds2vxl(Destination) then
   begin
      ImportSectionFromVoxel(Destination);
   end;
end;

procedure TFrmMain.Importfrommodel1Click(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: ImportFromModel1Click');
   {$endif}
   if OpenVXLDialog.execute then
   begin
      ImportSectionFromVoxel(OpenVXLDialog.FileName);
   end;
end;

procedure TFrmMain.Isosurfacesiso1Click(Sender: TObject);
var
   IsoFile: CIsosurfaceFile;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Isosurfacesiso1Click');
   {$endif}
   if SaveDialogExport.execute then
   begin
      IsoFile := CIsoSurfaceFile.Create;
      IsoFile.SaveToFile(SaveDialogExport.Filename,Document.ActiveSection^);
      IsoFile.Free;
   end;
end;

procedure TFrmMain.Resize1Click(Sender: TObject);
var
  FrmNew: TFrmNew;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: Resize1Click');
   {$endif}
   FrmNew := TFrmNew.Create(Self);
   with FrmNew do
   begin
      //FrmNew.Caption := ' Resize';
      //grpCurrentSize.Left := 8;
      //grpNewSize.Left := 112;
      //grpNewSize.Width := 97;
      Label9.caption := 'Enter the size you want the canvas to be:';
      Label10.caption := 'Resize Canvas';
      grpCurrentSize.Visible := true;
      Image1.Picture := TopBarImageHolder.Picture;
      grpVoxelType.Visible := false;

      x := Document.ActiveSection^.Tailer.XSize;
      y := Document.ActiveSection^.Tailer.YSize;
      z := Document.ActiveSection^.Tailer.ZSize;
      ShowModal;
      if changed then
      begin
         //Save undo information
         CreateVXLRestorePoint(Document.ActiveSection^,Undo);
         UpdateUndo_RedoState;

         SetIsEditable(false);
         Document.ActiveSection^.Resize(x,y,z);
         SetIsEditable(true);
         UpdateViews;
         SetupStatusBar;
         CursorReset;
         Refreshall;
         SetVoxelChanged(true);
      end;
   end;
   FrmNew.Free;
end;

procedure TFrmMain.SpinButton3UpClick(Sender: TObject);
begin
   YCursorBar.Position := YCursorBar.Position +1;
end;

procedure TFrmMain.SpinButton3DownClick(Sender: TObject);
begin
   YCursorBar.Position := YCursorBar.Position -1;
end;

procedure TFrmMain.SpinButton1DownClick(Sender: TObject);
begin
   ZCursorBar.Position := ZCursorBar.Position -1;
end;

procedure TFrmMain.SpinButton1UpClick(Sender: TObject);
begin
   ZCursorBar.Position := ZCursorBar.Position +1;
end;

procedure TFrmMain.SpinButton2DownClick(Sender: TObject);
begin
   XCursorBar.Position := XCursorBar.Position -1;
end;

procedure TFrmMain.SpinButton2UpClick(Sender: TObject);
begin
   XCursorBar.Position := XCursorBar.Position +1;
end;

procedure TFrmMain.IncreaseResolution1Click(Sender: TObject);
var
   Tool : CTopologyFixer;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: IncreaseResolution1Click');
   {$endif}

   if (Document.ActiveSection^.Tailer.XSize < 127) and (Document.ActiveSection^.Tailer.YSize < 127) and (Document.ActiveSection^.Tailer.ZSize < 127) then
   begin
      CreateVXLRestorePoint(Document.ActiveSection^,Undo);
      UpdateUndo_RedoState;

      SetIsEditable(false);
      Tool := CTopologyFixer.Create(Document.ActiveSection^,Document.Palette^);
      Tool.Free;
      SetIsEditable(true);
      UpdateViews;
      SetupStatusBar;
      CursorReset;
      Refreshall;
      SetVoxelChanged(true);
   end;
end;

procedure TFrmMain.FullResize1Click(Sender: TObject);
var
   frm: TFrmFullResize;
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FullResize1Click');
   {$endif}
   frm:=TFrmFullResize.Create(Self);
   with frm do
   begin
      x := Document.ActiveSection^.Tailer.XSize;
      y := Document.ActiveSection^.Tailer.YSize;
      z := Document.ActiveSection^.Tailer.ZSize;
      Image1.Picture := TopBarImageHolder.Picture;
      ShowModal;
      if Changed then
      begin
         CreateVXLRestorePoint(Document.ActiveSection^,Undo);
         UpdateUndo_RedoState;
         SetIsEditable(false);
         Document.ActiveSection^.ResizeBlowUp(Scale);
         SetIsEditable(true);
         UpdateViews;
         SetupStatusBar;
         CursorReset;
         Refreshall;
         SetVoxelChanged(true);
      end;
   end;
   frm.Free;
end;

procedure TFrmMain.UpdatePositionStatus(x,y,z : integer);
begin
   StatusBar1.Panels[3].Text :=  'Pos: ' + inttostr(X) + ',' + inttostr(Y) + ',' + inttostr(Z);
end;

procedure TFrmMain.UpdateSchemes1Click(Sender: TObject);
begin
   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: UpdateSchemes1Click');
   {$endif}
   UpdateCScheme;
end;

procedure TFrmMain.ToolButton9Click(Sender: TObject);
var
   frm: TFrmPreferences;
begin
   frm:=TFrmPreferences.Create(Self);
   frm.ShowModal;
   frm.Free;
end;

procedure TFrmMain.SpeedButton9Click(Sender: TObject);
begin
   SetVXLTool(VXLTool_SmoothNormal);
   Normals1.Click;
end;

procedure TFrmMain.ToolButton13Click(Sender: TObject);
var
  frm: TFrmReplaceColour;
begin
  frm:=TFrmReplaceColour.Create(Self);
  frm.Visible:=False;
  frm.Image1.Picture := TopBarImageHolder.Picture;

  frm.ShowModal;
  frm.Close;
  frm.Free;
end;

Function TFrmMain.CharToStr : String;
var
   x : integer;
begin
   for x := 1 to 16 do
      Result := Document.ActiveVoxel^.Header.FileType[x];
end;

Function CleanString(S : string) : String;
var
   x : integer;
begin
   Result := '';
   for x := 1 to Length(s) do
      if (S[x] <> '&') and (S[x] <> 'x') then
         Result := Result + S[x];
end;

procedure TFrmMain.N1x1Click(Sender: TObject);
begin
   Document.ActiveSection^.Viewport[0].Zoom := Strtoint(CleanString(TMenuItem(Sender).caption));
   if SelectedZoomOption <> nil then
   begin
      SelectedZoomOption.Checked := false;
   end;
   SelectedZoomOption := TMenuItem(Sender);
   SelectedZoomOption.Checked := true;
   CentreViews;
   setupscrollbars;
   CnvView0.Refresh;
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: FormKeyDown');
   {$endif}
   if (Key = Ord('Z')) or (Key = Ord('z')) then
   begin
      if ssShift in shift then
      begin
         if YCursorBar.Position > 0 then
            YCursorBar.Position := YCursorBar.Position - 1;
      end
      else
      begin
         if YCursorBar.Position < YCursorBar.Max then
            YCursorBar.Position := YCursorBar.Position + 1;
      end;
      XCursorBarChange(nil);
   end
   else if (Key = Ord('X')) or (Key = Ord('x')) then
   begin
      if ssShift in shift then
      begin
         if ZCursorBar.Position > 0 then
            ZCursorBar.Position := ZCursorBar.Position - 1;
      end
      else
      begin
         if ZCursorBar.Position < ZCursorBar.Max then
            ZCursorBar.Position := ZCursorBar.Position + 1;
      end;
      XCursorBarChange(nil);
   end;
   if (Key = Ord('C')) or (Key = Ord('c')) then
   begin
      if ssShift in shift then
      begin
         if XCursorBar.Position > 0 then
            XCursorBar.Position := XCursorBar.Position - 1;
      end
      else
      begin
         if XCursorBar.Position < XCursorBar.Max then
            XCursorBar.Position := XCursorBar.Position + 1;
      end;
      XCursorBarChange(nil);
   end;
end;

procedure TFrmMain.Display3DWindow1Click(Sender: TObject);
begin
   if p_Frm3DPreview = nil then
   begin
      {$ifdef DEBUG_FILE}
      DebugFile.Add('FrmMain: Display3DWindow1Click');
      {$endif}
      Application.OnIdle := nil;
      new(p_Frm3DPreview);
      p_Frm3DPreview^ := TFrm3DPreview.Create(self);
      p_Frm3DPreview^.Show;
      if @Application.OnIdle = nil then
         Application.OnIdle := Idle;
   end;
end;

procedure TFrmMain.DisplayFMPointCloudClick(Sender: TObject);
begin
   UncheckFillMode;
   DisplayFMPointCloud.Checked := true;
   Env.SetPolygonMode(GL_POINT);
end;

procedure TFrmMain.DisplayFMSolidClick(Sender: TObject);
begin
   UncheckFillMode;
   DisplayFMSolid.Checked := true;
   Env.SetPolygonMode(GL_FILL);
end;

procedure TFrmMain.DisplayFMWireframeClick(Sender: TObject);
begin
   UncheckFillMode;
   DisplayFMWireframe.Checked := true;
   Env.SetPolygonMode(GL_LINE);
end;

procedure TFrmMain.UncheckFillMode;
begin
   DisplayFMSolid.Checked := false;
   DisplayFMWireframe.Checked := false;
   DisplayFMPointCloud.Checked := false;
end;

procedure TFrmMain.NewAutoNormals1Click(Sender: TObject);
begin
   if not isEditable then exit;

   {$ifdef DEBUG_FILE}
   DebugFile.Add('FrmMain: CubedAutoNormals1Click');
   {$endif}
   // ask the user to confirm
   if MessageDlg('Autonormals v6.1' +#13#13+
        'This process will modify the voxel''s normals.' +#13+
        'If you choose to do this, you should first save' + #13 +
        'your model under a different name as a backup.',
        mtWarning,mbOKCancel,0) = mrCancel then
                        Exit;
   //ResetUndoRedo;
   CreateVXLRestorePoint(Document.ActiveSection^,Undo);
   UpdateUndo_RedoState;

   ApplyInfluenceNormalsToVXL(Document.ActiveSection^);
   Refreshall;
   SetVoxelChanged(true);
end;

procedure TFrmMain.AutoRepair(const _Filename: string; _ForceRepair: boolean);
var
   Frm : TFrmRepairAssistant;
begin
   Frm := TFrmRepairAssistant.Create(self);
   if Frm.RequestAuthorization(_Filename) then
   begin
      Frm.ForceRepair := _ForceRepair;
      Frm.ShowModal;
      if not Frm.RepairDone then
      begin
         Application.Terminate;
      end;
      Frm.Close;
   end;
   Frm.Release;
end;

procedure TFrmMain.RepairProgram1Click(Sender: TObject);
var
   Frm : TFrmRepairAssistant;
begin
   Frm := TFrmRepairAssistant.Create(self);
   Frm.ForceRepair := true;
   Frm.ShowModal;
   if not Frm.RepairDone then
   begin
      ShowMessage('Warning: Auto Repair could not finish its job.');
   end;
   Frm.Close;
   Frm.Release;
end;


procedure TFrmMain.FormActivate(Sender: TObject);
begin
   // Activate the view.
   if (not Display3dView1.Checked)  then
   begin
      if p_Frm3DPreview <> nil then
      begin
         p_Frm3DPreview^.AnimationTimer.Enabled := p_Frm3DPreview^.AnimationState;
      end;
      if p_Frm3DModelizer <> nil then
      begin
         p_Frm3DModelizer^.AnimationTimer.Enabled := p_Frm3DModelizer^.AnimationState;
      end;
      if @Application.OnIdle = nil then
         Application.OnIdle := Idle;
   end
   else
   begin
      if (p_Frm3DPreview = nil) and (p_Frm3DModelizer = nil) then
      begin
         Application.OnIdle := nil;
      end
      else
      begin
         Application.OnIdle := Idle;
      end;
   end;
end;

procedure TFrmMain.FormDeactivate(Sender: TObject);
begin
   Application.OnIdle := nil;
end;

procedure TFrmMain.SetVoxelChanged(_Value: boolean);
begin
   VXLChanged := _Value;
   ChangeCaption(true);
end;

end.
