unit TimerUnit;

{
 TimerUnit
 Started: Unknown (Added to DNW on 30 Jan 2009)
 By: Stuart "Stucuk" Carey

 If you make changes to this unit please list them below including your name.
 I.E 17 Dec 2008 (Stucuk):  Started Application

 --Changes--
}

interface

Const IntervalVal = 10;
      FrameSliceN = 3*IntervalVal-1;

type TTimerSystem = class(TObject)
  private
    FFrequency : int64;
    FoldTime   : int64;    // last system time
  public
    TotalTime  : double; // time since app started
    FrameTime  : double; // time elapsed since last frame
    Frames     : Cardinal;
    FrameSlices: Array [0..FrameSliceN] of Cardinal;
    FramesSec  : double;
    constructor Create;
    Procedure Refresh;
    function GetFPS : integer;
    procedure ClearAverages;
    function GetAverageFPS : integer;
  end;

var
   TimerSystem : TTimerSystem;

implementation

uses windows;

constructor TTimerSystem.Create;
begin
   FramesSec := 0;
   Frames    := 0;
   QueryPerformanceFrequency(FFrequency); // get high-resolution Frequency
   QueryPerformanceCounter(FoldTime);
   ClearAverages;
end;

Procedure TTimerSystem.Refresh;
var
   tmp : int64;
   t2  : double;
   x   : Byte;
begin
   QueryPerformanceCounter(tmp);
   t2        := tmp-FoldTime;
   frameTime := t2/FFrequency;
   TotalTime := TotalTime + frameTime;
   FoldTime  := tmp;

   inc(Frames);

   FramesSec := FramesSec + frameTime;
   if FramesSec >= 1/IntervalVal then
   begin
      FramesSec  := FramesSec - (1/IntervalVal);
      for x := FrameSliceN downto 1 do
         FrameSlices[x] := FrameSlices[x-1];
      FrameSlices[0] := Frames;
      Frames         := 0;
   end;
end;

function TTimerSystem.GetFPS : integer;
begin
   if FrameTime = 0 then
      result := 0
   else
      result := Round(1 / frameTime);
end;

procedure TTimerSystem.ClearAverages;
var
   X : Byte;
begin
   Frames     := 0;
   FramesSec  := 0;
   for x := 0 to FrameSliceN do
      FrameSlices[x] := 0;
end;

// Get AverageFPS for last 3 seconds or less if not enough data!
function TTimerSystem.GetAverageFPS : integer;
var
   X,
   FT  : Byte;
   FV  : Cardinal;
begin
   FT := 1;
   FV := 0;
   for x := 1 to FrameSliceN do
   begin
      if FrameSlices[x] > 0 then
         inc(FT);
      inc(FV,FrameSlices[x]);
   end;
   result := Round((FrameSlices[0] + FV) / (FT/IntervalVal));
end;

begin
   TimerSystem := TTimerSystem.Create;
end.
