unit StopWatch;

interface

// Adapted from
// http://delphi.about.com/od/windowsshellapi/a/delphi-high-performance-timer-tstopwatch.htm

uses Windows, SysUtils, DateUtils;

type
   TStopWatch = class
      private
         fFrequency : TLargeInteger;
         fIsRunning: boolean;
         fIsHighResolution: boolean;
         fStartCount, fStopCount : TLargeInteger;
         procedure SetTickStamp(var lInt : TLargeInteger) ;
         function GetElapsedTicks: TLargeInteger;
         function GetElapsedMiliseconds: TLargeInteger;
         function GetElapsedNanoseconds: Extended;
         function GetElapsed: string;
      public
         constructor Create(const startOnCreate : boolean = false) ;
         procedure Start;
         procedure Stop;
         property IsHighResolution : boolean read fIsHighResolution;
         property ElapsedTicks : TLargeInteger read GetElapsedTicks;
         property ElapsedMiliseconds : TLargeInteger read GetElapsedMiliseconds;
         property ElapsedNanoseconds : Extended read GetElapsedNanoseconds;
         property Elapsed : string read GetElapsed;
         property IsRunning : boolean read fIsRunning;
   end;

implementation

constructor TStopWatch.Create(const startOnCreate : boolean = false);
begin
   inherited Create;

   fIsRunning := false;

   fIsHighResolution := QueryPerformanceFrequency(fFrequency);
   if not fIsHighResolution then
      fFrequency := MSecsPerSec;

   if startOnCreate then
      Start;
end;

function TStopWatch.GetElapsedTicks: TLargeInteger;
begin
   result := fStopCount - fStartCount;
end;

procedure TStopWatch.SetTickStamp(var lInt : TLargeInteger);
begin
   if fIsHighResolution then
      QueryPerformanceCounter(lInt)
   else
      lInt := MilliSecondOf(Now) ;
end;

function TStopWatch.GetElapsed: string;
var
   dt : TDateTime;
begin
   dt := ElapsedMiliseconds / MSecsPerSec / SecsPerDay;
   result := Format('%d days, %s', [Trunc(dt), FormatDateTime('hh:nn:ss.z', Frac(dt))]) ;
end;

function TStopWatch.GetElapsedMiliseconds: TLargeInteger;
begin
   result := (MSecsPerSec * (fStopCount - fStartCount)) div fFrequency;
end;

function TStopWatch.GetElapsedNanoseconds: Extended;
begin
   result := (1000000000 * (fStopCount - fStartCount)) / fFrequency;
end;

procedure TStopWatch.Start;
begin
   SetTickStamp(fStartCount) ;
   fIsRunning := true;
end;

procedure TStopWatch.Stop;
begin
   SetTickStamp(fStopCount) ;
   fIsRunning := false;
end;

end.

