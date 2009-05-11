program vxlse_III;

{%File 'Global_Conditionals.inc'}

uses
  Forms,
  Voxel_Engine in 'Voxel_Engine.pas',
  normals in 'normals.pas',
  FormHeaderUnit in 'FormHeaderUnit.pas' {FrmHeader},
  undo_engine in 'undo_engine.pas',
  HVA in 'HVA.pas',
  FormReplaceColour in 'FormReplaceColour.pas' {FrmReplaceColour},
  FormVoxelTexture in 'FormVoxelTexture.pas' {FrmVoxelTexture},
  FormImportSection in 'FormImportSection.pas' {FrmImportSection},
  FormFullResize in 'FormFullResize.pas' {FrmFullResize},
  FormPreferences in 'FormPreferences.pas' {FrmPreferences},
  FormVxlError in 'FormVxlError.pas' {FrmVxlError},
  Voxel_Tools in 'Voxel_Tools.pas',
  Voxel in 'Voxel.pas',
  math3d in 'math3d.pas',
  cls_Config in 'cls_Config.pas',
  LoadForm in 'LoadForm.pas' {LoadFrm},
  FormBoundsMAnager in 'FormBoundsMAnager.pas' {FrmBoundsManager},
  FormNewSectionSizeUnit in 'FormNewSectionSizeUnit.pas' {FrmNewSectionSize},
  FormNewVxlUnit in 'FormNewVxlUnit.pas' {FrmNew},
  Mouse in 'Mouse.pas',
  Geometry in 'Geometry.pas',
  Constants in 'Constants.pas',
  Form3dPreview in 'Form3dPreview.pas' {Frm3DPReview},
  Palette in 'Palette.pas',
  Debug in 'Debug.pas',
  FormAutoNormals in 'FormAutoNormals.pas' {FrmAutoNormals},
  BZK2_Sector in 'BZK2_Sector.pas',
  BZK2_Actor in 'BZK2_Actor.pas',
  BZK2_Camera in 'BZK2_Camera.pas',
  BZK2_File in 'BZK2_File.pas',
  FormPalettePackAbout in 'FormPalettePackAbout.pas' {FrmPalettePackAbout},
  Voxel_AutoNormals in 'Voxel_AutoNormals.pas',
  Spin in 'Spin.pas',
  FormMain in 'FormMain.pas' {FrmMain},
  Class3DPointList in 'Class3DPointList.pas',
  GlobalVars in 'GlobalVars.pas',
  dglOpenGL in 'dglOpenGL.pas',
  Render in 'Render.pas',
  RenderEnvironment in 'RenderEnvironment.pas',
  Camera in 'Camera.pas',
  Actor in 'Actor.pas',
  Mesh in 'Mesh.pas',
  GLConstants in 'GLConstants.pas',
  BmpToDIB in 'BmpToDIB.pas',
  NormalsConstants in 'NormalsConstants.pas',
  BasicDataTypes in 'BasicDataTypes.pas',
  Model in 'Model.pas',
  VoxelMap in 'VoxelMap.pas',
  BasicFunctions in 'BasicFunctions.pas',
  VoxelBank in 'VoxelBank.pas',
  VoxelBankItem in 'VoxelBankItem.pas',
  LOD in 'LOD.pas',
  ModelBankItem in 'ModelBankItem.pas',
  ModelBank in 'ModelBank.pas',
  HVABankItem in 'HVABankItem.pas',
  HVABank in 'HVABank.pas',
  VoxelDocument in 'VoxelDocument.pas',
  VoxelDocumentBank in 'VoxelDocumentBank.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Voxel Section Editor III';
  //  Application.CreateForm(TFrmTimeMain, FrmTimeMain);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
