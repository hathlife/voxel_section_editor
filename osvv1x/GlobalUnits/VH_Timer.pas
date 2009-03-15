unit VH_Timer;

//Note: this is just the Q3MapView Timer but renamed.

interface

uses windows;

type THiResTimer = class(TObject)
   private
      FFrequency : int64;
      FoldTime : int64;    // last system time
   public
      TotalTime  : double; // time since app started
      FrameTime : double; // time elapsed since last frame
      Frames    : cardinal; // total number of frames
      constructor Create;
      function Refresh : cardinal;
      function GetFPS : integer;
      function GetAverageFPS : integer;
      function GetTime : int64;
      function DiffTime(start_time, end_time : int64) : double;
end;


//VH Edit
//var gTimer : THiResTimer;

implementation

constructor THiResTimer.Create;
begin
   frames := 0;
   QueryPerformanceFrequency(FFrequency); // get high-resolution Frequency
   QueryPerformanceCounter(FoldTime);
end;

function THiResTimer.Refresh : cardinal;
var
   tmp : int64;
   t2 : double;
begin
   QueryPerformanceCounter(tmp);
   t2 := tmp-FoldTime;
   frameTime := t2/FFrequency;
   TotalTime := TotalTime + frameTime;
   FoldTime := tmp;
   inc(Frames);
   result := Frames;
end;

function THiResTimer.GetFPS : integer;
begin
   result := Round(1 / frameTime);
end;

function THiResTimer.GetAverageFPS : integer;
begin
   result := 0;
   if TotalTime > 0 then
   begin
      try
         result := Round(Frames / TotalTime);
      except
      end;
   end;
end;

function THiResTimer.GetTime : int64;
var
   tmp : int64;
begin
   QueryPerformanceCounter(tmp);
   result := tmp;
end;

function THiResTimer.DiffTime(start_time, end_time : int64) : double;
begin
   result := (end_time - start_time) / FFrequency;
end;
end.
