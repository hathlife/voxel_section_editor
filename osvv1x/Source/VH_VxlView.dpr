program VH_VxlView;

uses
  Forms,
  Windows,
  Messages,
  FormMain in 'FormMain.pas' {VVFrmMain},
  VH_Engine in '..\GlobalUnits\VH_Engine.pas',
  math3d in '..\GlobalUnits\math3d.pas',
  normals in '..\GlobalUnits\normals.pas',
  Palette in '..\GlobalUnits\Palette.pas',
  VH_Global in '..\GlobalUnits\VH_Global.pas',
  VH_Display in '..\GlobalUnits\VH_Display.pas',
  VH_Types in '..\GlobalUnits\VH_Types.pas',
  OpenGL15 in '..\GlobalUnits\OpenGL15.pas',
  VH_GL in '..\GlobalUnits\VH_GL.pas',
  Voxel in '..\GlobalUnits\Voxel.pas',
  VH_Voxel in '..\GlobalUnits\VH_Voxel.pas',
  HVA in '..\GlobalUnits\HVA.pas',
  Geometry in '..\GlobalUnits\Geometry.pas',
  FormAboutNew in 'FormAboutNew.pas' {FrmAbout_New},
  Textures in '..\GlobalUnits\Textures.pas',
  FormProgress in '..\GlobalUnits\FormProgress.pas' {FrmProgress},
  FormCameraManagerNew in 'FormCameraManagerNew.pas' {FrmCameraManager_New},
  FormScreenShotManagerNew in 'FormScreenShotManagerNew.pas' {FrmScreenShotManager_New},
  FTGifAnimate in '..\GlobalUnits\FTGifAnimate.pas',
  GIFImage in '..\GlobalUnits\gifimage.pas',
  FormAnimationManagerNew in 'FormAnimationManagerNew.pas' {FrmAniamtionManager_New},
  VVS in '..\GlobalUnits\VVS.pas',
  Undo_Engine in '..\GlobalUnits\Undo_Engine.pas',
  OSVVCommEngine in 'OSVVCommEngine.pas',
  FormSurface in 'FormSurface.pas' {FrmSurfaces},
  VH_SurfaceGen in 'VH_SurfaceGen.pas',
  //OpenGLWrapper in '..\GlobalUnits\OpenGLWrapper.pas',
  TimerUnit in '..\GlobalUnits\TimerUnit.pas';

{$R *.res}

type
   PHWND = ^HWND;

// This function checks if the window choosen by EnumWindows
// is another SHP Builder opened.

// Code copied and adapted from the book:

// Mastering Delphi 3 for Windows 95/NT

// from Cantú, Marco.
// Published by Makron Books and purchased by me (Banshee). R$105,00 (very expensive, but worth :P)
function EnumWndProc (Hwnd : THandle; FoundWnd : PHWND):Bool ; stdcall
var
   ClassName, ModuleName, WinModuleName : string;
   WinInstance : THandle;
begin
   Result := true;
   SetLength(ClassName,100);
   GetClassName(Hwnd,PChar(ClassName),Length(ClassName));
   ClassName := PChar(ClassName);
   if ClassName = 'TVVFrmMain' then
   begin
      SetLength(ModuleName,200);
      SetLength(WinModuleName,200);
      GetModuleFilename(HInstance,PChar(ModuleName),Length(ModuleName));
      ModuleName := PChar(ModuleName);
      WinInstance := GetWindowLong(hwnd,gwl_hInstance);
      GetModuleFilename(WinInstance,PChar(WinModuleName),Length(WinModuleName));
      WinModuleName := PChar(WinModuleName);
      If ModuleName = WinModuleName then
      begin
         FoundWnd^ := Hwnd;
         Result := false;
      end;
   end;
end;

var
   Hwnd : THandle;
   x : word;
   parameter_string : pchar;
   cd: TCOPYDATASTRUCT;
begin

  // Reset Handler
  Hwnd := 0;
  // Check if there is another VV opened
  EnumWindows(@EnumWndProc,Longint(@Hwnd));
  // It's the first VV window
  if Hwnd = 0 then
  begin
  Application.Initialize;
  Application.Title := 'OS: Voxel Viewer';
  Application.CreateForm(TVVFrmMain, VVFrmMain);
  Application.Run;
  end
  else // there is another VV opened
  begin
  parameter_string := '';
     // extract current parameters
     if ParamCount > 0 then
        for x := 1 to ParamCount do
        begin
           if parameter_string = '' then
              parameter_string := pchar(ParamStr(x))
           else
              parameter_string := pchar(parameter_string + ' ' + ParamStr(x));
        end;

  cd.dwData:= 43254321;
  cd.cbData:= length(parameter_string)+1;
  cd.lpData:= parameter_string;

  SendMessage(Hwnd,wm_copydata,3,integer(@cd));

     SetForegroundWindow(Hwnd);
  end;
end.
