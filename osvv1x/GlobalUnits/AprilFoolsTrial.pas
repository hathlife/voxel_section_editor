unit AprilFoolsTrial;

interface

var
CurrentDay,
CurrentMonth,
CurrentYear : Integer;
IsError,
IsEndOfTrial : Boolean;

Procedure InitTrial;

implementation

uses SysUtils;

Procedure InitTrial;
begin

CurrentDay  := StrToInt(FormatDateTime('d', Date));
CurrentMonth := StrToInt(FormatDateTime('m', Date));
CurrentYear := StrToInt(FormatDateTime('yyyy', Date));

IsError := True;
IsEndOfTrial := False;

if (CurrentYear < 2006) then exit;

if (CurrentYear >= 2006) then
begin
IsError := False;
if (CurrentYear > 2006) then
begin
IsEndOfTrial := True;
exit;
end;
end;

if (CurrentMonth < 4) then exit;

if (CurrentMonth >= 4) then
begin
IsError := False;
if (CurrentMonth > 4) then
begin
IsEndOfTrial := True;
exit;
end;
end;

if CurrentDay >= 3 then
IsEndOfTrial := True;

end;

begin
InitTrial;
end.
