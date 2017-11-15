program VH_HVABuilder;

uses
  Forms,
  FormMain in 'FormMain.pas' {FrmMain},
  VH_Engine in '..\osvv1x\GlobalUnits\VH_Engine.pas',
  math3d in '..\osvv1x\GlobalUnits\math3d.pas',
  normals in '..\osvv1x\GlobalUnits\normals.pas',
  Palette in '..\osvv1x\GlobalUnits\Palette.pas',
  VH_Global in '..\osvv1x\GlobalUnits\VH_Global.pas',
  VH_Display in '..\osvv1x\GlobalUnits\VH_Display.pas',
  VH_Types in '..\osvv1x\GlobalUnits\VH_Types.pas',
  OpenGL15 in '..\osvv1x\GlobalUnits\OpenGL15.pas',
  VH_GL in '..\osvv1x\GlobalUnits\VH_GL.pas',
  Voxel in '..\osvv1x\GlobalUnits\Voxel.pas',
  VH_Voxel in '..\osvv1x\GlobalUnits\VH_Voxel.pas',
  VH_Timer in '..\osvv1x\GlobalUnits\VH_Timer.pas',
  HVA in '..\osvv1x\GlobalUnits\HVA.pas',
  Geometry in '..\osvv1x\GlobalUnits\Geometry.pas',
  FormAboutNew in 'FormAboutNew.pas' {FrmAbout_New},
  Textures in '..\osvv1x\GlobalUnits\Textures.pas',
  FormCameraManagerNew in 'FormCameraManagerNew.pas' {FrmCameraManager_New},
  FormScreenShotManagerNew in 'FormScreenShotManagerNew.pas' {FrmScreenShotManager_New},
  FTGifAnimate in '..\osvv1x\GlobalUnits\FTGifAnimate.pas',
  gifimage in '..\osvv1x\GlobalUnits\gifimage.pas',
  FormAnimationManagerNew in 'FormAnimationManagerNew.pas' {FrmAnimationManager_New},
  VVS in '..\osvv1x\GlobalUnits\VVS.pas',
  FormTransformManagerNew in 'FormTransformManagerNew.pas' {FrmTransformManager_New},
  FormProgress in '..\osvv1x\GlobalUnits\FormProgress.pas' {FrmProgress},
  FormBoundsManagerNew in 'FormBoundsManagerNew.pas' {FrmBoundsManager_New},
  FormRotationManagerNew in 'FormRotationManagerNew.pas' {FrmRotationManager_New},
  FormHVAPositionManagerNew in 'FormHVAPositionManagerNew.pas' {FrmHVAPositionManager_New},
  Undo_Engine in '..\osvv1x\GlobalUnits\Undo_Engine.pas',
  FormPreferences in 'FormPreferences.pas' {FrmPreferences},
  TimerUnit in '..\osvv1x\GlobalUnits\TimerUnit.pas',
  pngimage in '..\osvv1x\GlobalUnits\pngimage.pas',
  pngzlib in '..\osvv1x\GlobalUnits\pngzlib.pas',
  pnglang in '..\osvv1x\GlobalUnits\pnglang.pas',
  FormTurretOffsetManagerNew in 'FormTurretOffsetManagerNew.pas' {FrmTurretOffsetManager_New};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'OS HVA Builder';
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmPreferences, FrmPreferences);
  Application.CreateForm(TFrmTurretOffsetManager_New, FrmTurretOffsetManager_New);
  Application.Run;
end.
