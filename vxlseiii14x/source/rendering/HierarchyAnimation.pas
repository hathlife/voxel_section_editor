unit HierarchyAnimation;

interface

uses BasicMathsTypes, TransformAnimation;

{$INCLUDE source/Global_Conditionals.inc}

type
   THierarchyAnimation = class
      private
         FDesiredTimeRate: int64;
         FTransformFramesPerSecond: single;
         FTransformLastChange: int64;
      public
         // Euclidean transformations
         CurrentTransformationFrame: integer;
         ExecuteTransformAnimation: boolean;
         ExecuteTransformAnimationLoop: boolean;
         CurrentTransformAnimation: integer;
         NumTransformationFrames: integer;
         NumSectors: integer;
         TransformAnimations: array of TTransformAnimation;

         // constructors and destructors
         constructor Create(_NumSectors, _NumFrames: integer); overload;
         constructor Create(_NumSectors: integer); overload;
         constructor Create(const _Source: THierarchyAnimation); overload;
         destructor Destroy; override;
         procedure Initialize;
         procedure Clear;
         procedure Reset(_NumSectors, _NumFrames: integer);

         // Executes
         procedure ExecuteAnimation(_NumSection: integer);
         function DetectTransformationAnimationFrame: boolean;
         procedure ApplyPivot(_Pivot: TVector3f);
         procedure PlayTransformAnim;
         procedure PauseTransformAnim;
         procedure StopTransformAnim;

         // Sets
         procedure SetTransformFPS(_FPS: single);

         // Copy
         procedure Assign(const _Source: THierarchyAnimation);
   end;
   PHierarchyAnimation = ^THierarchyAnimation;

implementation

uses Math3D, dglOpenGL, Windows;

constructor THierarchyAnimation.Create(_NumSectors: integer);
begin
   NumSectors := _NumSectors;
   NumTransformationFrames := 1;
   Initialize;
end;

constructor THierarchyAnimation.Create(_NumSectors, _NumFrames: integer);
begin
   NumSectors := _NumSectors;
   NumTransformationFrames := _NumFrames;
   Initialize;
end;

constructor THierarchyAnimation.Create(const _Source: THierarchyAnimation);
begin
   Assign(_Source);
end;

destructor THierarchyAnimation.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure THierarchyAnimation.Initialize;
var
   i: integer;
begin
   QueryPerformanceCounter(FTransformLastChange);
   CurrentTransformationFrame := 0;
   CurrentTransformAnimation := 0;
   ExecuteTransformAnimation := false;
   ExecuteTransformAnimationLoop := false;
   FTransformFramesPerSecond := 0;
   SetLength(TransformAnimations, 1);
   TransformAnimations[0] := TTransformAnimation.Create(NumSectors, NumTransformationFrames);
end;

procedure THierarchyAnimation.Clear;
var
   i: integer;
begin
   for i := Low(TransformAnimations) to High(TransformAnimations) do
   begin
      TransformAnimations[i].Free;
   end;
end;

procedure THierarchyAnimation.Reset(_NumSectors, _NumFrames: integer);
begin
   Clear;
   NumSectors := _NumSectors;
   NumTransformationFrames := _NumFrames;
   Initialize;
end;

// Executes
procedure THierarchyAnimation.ExecuteAnimation(_NumSection: integer);
begin
   TransformAnimations[CurrentTransformAnimation].ApplyMatrix(_NumSection, CurrentTransformationFrame);
end;

function THierarchyAnimation.DetectTransformationAnimationFrame: boolean;
var
   temp : int64;
   t2: int64;
begin
   Result := false;
   if ExecuteTransformAnimation then
   begin
      // determine the current frame here
      if FTransformFramesPerSecond > 0 then
      begin
         QueryPerformanceCounter(temp);
         t2 := temp - FTransformLastChange;
         if t2 >= FDesiredTimeRate then
         begin
            CurrentTransformationFrame := (CurrentTransformationFrame + 1) mod NumTransformationFrames;
            Result := true;
            if (not (ExecuteTransformAnimationLoop)) and (CurrentTransformationFrame = 0) then
            begin
               ExecuteTransformAnimation := false;
            end;
            QueryPerformanceCounter(FTransformLastChange);
         end;
      end
      else
      begin
         CurrentTransformationFrame := (CurrentTransformationFrame + 1) mod NumTransformationFrames;
         Result := true;
         if (not (ExecuteTransformAnimationLoop)) and (CurrentTransformationFrame = 0) then
         begin
            ExecuteTransformAnimation := false;
         end;
      end;
   end;
end;

procedure THierarchyAnimation.ApplyPivot(_Pivot: TVector3f);
begin
   glTranslatef(_Pivot.X, _Pivot.Y, _Pivot.Z);
end;

procedure THierarchyAnimation.PlayTransformAnim;
begin
   CurrentTransformationFrame := 0;
   ExecuteTransformAnimation := true;
end;

procedure THierarchyAnimation.PauseTransformAnim;
begin
   ExecuteTransformAnimation := false;
end;

procedure THierarchyAnimation.StopTransformAnim;
begin
   CurrentTransformationFrame := 0;
   ExecuteTransformAnimation := false;
end;

// Sets
procedure THierarchyAnimation.SetTransformFPS(_FPS: single);
var
   Frequency: int64;
begin
   FTransformFramesPerSecond := _FPS;
   if FTransformFramesPerSecond > 0 then
   begin
      QueryPerformanceFrequency(Frequency); // get high-resolution Frequency
      FDesiredTimeRate := Round(Frequency / FTransformFramesPerSecond);
   end;
end;

// Copy
procedure THierarchyAnimation.Assign(const _Source: THierarchyAnimation);
var
   i: integer;
begin
   FDesiredTimeRate := _Source.FDesiredTimeRate;
   FTransformFramesPerSecond := _Source.FTransformFramesPerSecond;
   FTransformLastChange := _Source.FTransformLastChange;
   CurrentTransformationFrame := _Source.CurrentTransformationFrame;
   ExecuteTransformAnimation := _Source.ExecuteTransformAnimation;
   ExecuteTransformAnimationLoop := _Source.ExecuteTransformAnimationLoop;
   CurrentTransformAnimation := _Source.CurrentTransformAnimation;
   NumTransformationFrames := _Source.NumTransformationFrames;
   NumSectors := _Source.NumSectors;
   SetLength(TransformAnimations, High(_Source.TransformAnimations) + 1);
   for i := Low(TransformAnimations) to High(TransformAnimations) do
   begin
      TransformAnimations[i] := TTransformAnimation.Create(_Source.TransformAnimations[i]);
   end;
end;

end.
