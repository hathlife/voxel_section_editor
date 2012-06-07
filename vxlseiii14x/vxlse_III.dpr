program vxlse_III;

{$SetPEFlags $0020}
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
  VoxelDocumentBank in 'VoxelDocumentBank.pas',
  VoxelModelizer in 'VoxelModelizer.pas',
  VoxelModelizerItem in 'VoxelModelizerItem.pas',
  Class2DPointQueue in 'Class2DPointQueue.pas',
  BasicConstants in 'BasicConstants.pas',
  ThreeDMap in 'ThreeDMap.pas',
  ClassFaceQueue in 'ClassFaceQueue.pas',
  ClassVertexQueue in 'ClassVertexQueue.pas',
  Class2DPointOrderList in 'Class2DPointOrderList.pas',
  Class3DPointsDetector in 'Class3DPointsDetector.pas',
  ThreeDSFile in 'ThreeDSFile.pas',
  OBJFile in 'OBJFile.pas',
  Form3dModelizer in 'Form3dModelizer.pas' {Frm3DModelizer},
  ClassNeighborDetector in 'ClassNeighborDetector.pas',
  ClassIntegerList in 'ClassIntegerList.pas',
  ClassTextureGenerator in 'ClassTextureGenerator.pas',
  FormOptimizeMesh in 'FormOptimizeMesh.pas' {FrmOptimizeMesh},
  ClassStopWatch in 'ClassStopWatch.pas',
  CustomScheme in 'CustomScheme.pas',
  DDS in 'DDS.pas',
  TextureBank in 'TextureBank.pas',
  TextureBankItem in 'TextureBankItem.pas',
  ShaderBank in 'ShaderBank.pas',
  ShaderBankItem in 'ShaderBankItem.pas',
  FormRepairAssistant in 'FormRepairAssistant.pas' {FrmRepairAssistant},
  ClassIntegerSet in 'ClassIntegerSet.pas',
  ColladaFile in 'ColladaFile.pas',
  ClassMeshOptimizationTool in 'ClassMeshOptimizationTool.pas',
  Material in 'Material.pas',
  ClassVoxelView in 'ClassVoxelView.pas',
  UI2DEditView in 'UI2DEditView.pas',
  ClassVertexTransformationUtils in 'ClassVertexTransformationUtils.pas',
  ClassBaseSet in 'ClassBaseSet.pas',
  ClassTriangleNeighbourSet in 'ClassTriangleNeighbourSet.pas',
  FormGenerateDiffuseTexture in 'FormGenerateDiffuseTexture.pas' {FrmGenerateDiffuseTexture},
  VoxelMeshGenerator in 'VoxelMeshGenerator.pas',
  ClassVector3fSet in 'ClassVector3fSet.pas',
  MeshPluginBase in 'MeshPluginBase.pas',
  NormalsMeshPlugin in 'NormalsMeshPlugin.pas',
  RenderingMachine in 'RenderingMachine.pas',
  NeighborhoodDataPlugin in 'NeighborhoodDataPlugin.pas',
  BumpMapDataPlugin in 'BumpMapDataPlugin.pas',
  ClassMeshNormalsTool in 'ClassMeshNormalsTool.pas',
  ClassMeshColoursTool in 'ClassMeshColoursTool.pas',
  ClassMeshProcessingTool in 'ClassMeshProcessingTool.pas',
  FormHeightmap in 'FormHeightmap.pas' {FrmHeightMap},
  ImageIOUtils in 'ImageIOUtils.pas',
  PCXCtrl in 'PCXCtrl.pas',
  TARGA in 'TARGA.pas',
  ClassTriangleFiller in 'ClassTriangleFiller.pas',
  Internet in 'Internet.pas',
  AutoUpdater in 'AutoUpdater.pas',
  ClassTextureAtlasExtractor in 'ClassTextureAtlasExtractor.pas',
  AbstractDataSet in 'AbstractDataSet.pas',
  Abstract2DImageData in 'Abstract2DImageData.pas',
  ByteDataSet in 'ByteDataSet.pas',
  IntDataSet in 'IntDataSet.pas',
  ImageGreyByteData in 'ImageGreyByteData.pas',
  ImageGreyData in 'ImageGreyData.pas',
  ImageRGBData in 'ImageRGBData.pas',
  ImageRGBIntData in 'ImageRGBIntData.pas',
  SingleDataSet in 'SingleDataSet.pas',
  RGBIntDataSet in 'RGBIntDataSet.pas',
  RGBSingleDataSet in 'RGBSingleDataSet.pas',
  RGBAIntDataSet in 'RGBAIntDataSet.pas',
  ImageRGBAIntData in 'ImageRGBAIntData.pas',
  RGBAByteDataSet in 'RGBAByteDataSet.pas',
  RGBByteDataSet in 'RGBByteDataSet.pas',
  ImageRGBAByteData in 'ImageRGBAByteData.pas',
  ImageRGBByteData in 'ImageRGBByteData.pas',
  RGBASingleDataSet in 'RGBASingleDataSet.pas',
  ImageRGBAData in 'ImageRGBAData.pas',
  FormBumpMapping in 'FormBumpMapping.pas' {FrmBumpMapping},
  ClassTopologyCleanerUtility in 'ClassTopologyCleanerUtility.pas',
  BooleanDataSet in 'BooleanDataSet.pas',
  Abstract3DVolumeData in 'Abstract3DVolumeData.pas',
  VolumeGreyByteData in 'VolumeGreyByteData.pas',
  VolumeGreyData in 'VolumeGreyData.pas',
  VolumeRGBAByteData in 'VolumeRGBAByteData.pas',
  VolumeRGBAData in 'VolumeRGBAData.pas',
  VolumeRGBAIntData in 'VolumeRGBAIntData.pas',
  VolumeRGBByteData in 'VolumeRGBByteData.pas',
  VolumeRGBData in 'VolumeRGBData.pas',
  VolumeRGBIntData in 'VolumeRGBIntData.pas',
  ImageGreyIntData in 'ImageGreyIntData.pas',
  VolumeGreyIntData in 'VolumeGreyIntData.pas',
  LongDataSet in 'LongDataSet.pas',
  RGBALongDataSet in 'RGBALongDataSet.pas',
  RGBLongDataSet in 'RGBLongDataSet.pas',
  ImageGreyLongData in 'ImageGreyLongData.pas',
  ImageRGBALongData in 'ImageRGBALongData.pas',
  ImageRGBLongData in 'ImageRGBLongData.pas',
  VolumeGreyLongData in 'VolumeGreyLongData.pas',
  VolumeRGBALongData in 'VolumeRGBALongData.pas',
  VolumeRGBLongData in 'VolumeRGBLongData.pas',
  DifferentMeshFaceTypePlugin in 'DifferentMeshFaceTypePlugin.pas',
  ClassVertexList in 'ClassVertexList.pas',
  ClassTriangleList in 'ClassTriangleList.pas',
  ClassQuadList in 'ClassQuadList.pas',
  MeshGeometryBase in 'MeshGeometryBase.pas',
  MeshBRepGeometry in 'MeshBRepGeometry.pas',
  ClassMeshGeometryList in 'ClassMeshGeometryList.pas',
  ClassRefinementTrianglesSupporter in 'ClassRefinementTrianglesSupporter.pas',
  ClassVolumeFaceVerifier in 'ClassVolumeFaceVerifier.pas',
  ClassTopologyAnalyzer in 'ClassTopologyAnalyzer.pas',
  FormTopologyAnalysis in 'FormTopologyAnalysis.pas' {FrmTopologyAnalysis},
  ClassIsoSurfaceFile in 'ClassIsoSurfaceFile.pas',
  ClassPLYFile in 'ClassPLYFile.pas',
  ClassTopologyFixer in 'ClassTopologyFixer.pas',
  ClassFillUselessGapsTool in 'ClassFillUselessGapsTool.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Voxel Section Editor III';
  //  Application.CreateForm(TFrmTimeMain, FrmTimeMain);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
