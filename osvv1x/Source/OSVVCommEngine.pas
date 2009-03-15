unit OSVVCommEngine;

interface

uses Windows,Messages,ShellApi,SysUtils,Palette,Dialogs;

const
// OS Message Types Listing
SHP_ACCESS = 12345234; // Load SHP File on OS SHP Builder
VOXEL_ACCESS = 12345235; // Load Voxel File on VXLSE III, OS: VV, HVA Builder
HVA_ACCESS = 12345236; // Load HVA File on HVA Builder
OS_PALETTE_ACCESS = 12345237; // Load Palette from string here
OS_SCHEME_ACCESS = 12345238; // Load Custom Scheme from string here
PALETTE_ACCESS = 12345239; // Load Palette File here
CSCHEME_ACCESS = 12345240; // Load Custom Scheme File here
MY_HANDLE = 12345250; // Establish Conection: Receiver's Handle

function TextToPalette( const FullText : AnsiString): TPalette;
function PaletteToText( const Palette : TPalette): AnsiString;
function GetPaletteParameters (const Hwnd : THandle) : AnsiString;
function UpdateHwndList(Hwnd : THandle; var WasAdded: boolean): integer; overload;
procedure RunAProgram (const theProgram, itsParameters, defaultDirectory : AnsiString);
function SendExternalMessage(const Hwnd : THandle; const Destination : Cardinal; const ParameterString : string): Boolean;

var
   HwndList : array of THandle;

implementation

uses FormMain;

function TextToPalette( const FullText : AnsiString): TPalette;
var
   colour : byte;
   letter : integer;
   r,g,b : byte;
begin
   letter := 1;
   for colour := 0 to 255 do
   begin
      r := Byte(FullText[letter]);
      inc(letter);
      g := Byte(FullText[letter]);
      inc(letter);
      b := Byte(FullText[letter]);
      inc(letter);
      Result[colour] := RGB(r,g,b);
   end;
end;

function PaletteToText( const Palette : TPalette): AnsiString;
var
   colour : byte;
begin
   Result := '';
   for colour := 0 to 255 do
   begin
      Result := Result + Char(GetRValue(Palette[colour])) + Char(GetGValue(Palette[colour])) + Char(GetBValue(Palette[colour]));
   end;
   Result := Result + #0;
end;

function GetPaletteParameters (const Hwnd : THandle) : AnsiString;
begin
   Result := '-palette ' + IntToStr(Hwnd);
end;

// -------------------------------------------------------------
// The set of function below deals with the handle list.
function UpdateHwndList(Hwnd : THandle; var WasAdded: boolean): integer; overload;
var
   counter: integer;
begin
   WasAdded := false;
   // Is the list empty?
   if High(HwndList) > 0 then
   begin
      // Search handle inside the list
      for counter := Low(HwndList) to High(HwndList) do
      begin
         // If the handle is inside...
         if HwndList[counter] = Hwnd then
         begin
            Result := counter;
            exit;
         end;
      end;
   end;
   // Now, we are sure that Hwnd isn't in the list.
   // Let's add an element to this array.
   SetLength(HwndList,High(HwndList)+1);
   HwndList[High(HwndList)] := Hwnd;
   WasAdded := true;
   Result := High(HwndList);
end;

function UpdateHwndList(Hwnd : String; var WasAdded: boolean): integer; overload;
var
   Value : Integer;
begin
   Value := StrToIntDef(Hwnd,0);
   Result := UpdateHwndList(THandle(Value),WasAdded);
end;

// The two function below were ripped by OS SHP Builder 3.39 beta
// Both were written by Stucuk.

// Interpretates comunications from other OS Tools windows
// Check SHP Builder project source (PostMessage commands)

// CopyData has been modified to return the message to someone
// else interpret
function CopyData(var Msg: TMessage): string;
var
   cd: ^TCOPYDATASTRUCT;
   PointerChar : PChar;
   IsNewHandle : boolean;
   Position : Integer;
begin
   cd:=Pointer(msg.lParam);
   msg.result:=0;
   if cd^.dwData=(VOXEL_ACCESS) then
   begin
      try
         PointerChar := cd^.lpData;
         PointerChar := PChar(copy(PointerChar,2,length(PointerChar)));
         Result := String(PointerChar);
         if Fileexists(Result) then
            VVFrmMain.OpenVoxel(Result);

         { process data }
         msg.result:=-1;
      except
      end;
   end
   else if cd^.dwData=(MY_HANDLE) then
   begin
      try
         PointerChar := cd^.lpData;
         PointerChar := PChar(copy(PointerChar,2,length(PointerChar)));
         Result := String(PointerChar);
         // work out handle in the HwndList.
         Position := UpdateHwndList(Result,IsNewHandle);
         { process data }
         msg.result:=-1;
      except
      end;
   end;
end;

procedure RunAProgram (const theProgram, itsParameters, defaultDirectory : AnsiString);
var rslt     : integer;
    msg      : string;
begin
rslt := ShellExecute (0, 'open',
                        pChar (theProgram),
                        pChar (itsParameters),
                        pChar (defaultDirectory),
                        sw_ShowNormal);
if rslt <= 32
then begin
     case rslt of
          0,
          se_err_OOM :             msg := 'Out of memory/resources';
          error_File_Not_Found :   msg := 'File "' + theProgram + '" not found';
          error_Path_Not_Found :   msg := 'Path not found';
          error_Bad_Format :       msg := 'Damaged or invalid exe';
          se_err_AccessDenied :    msg := 'Access denied';
          se_err_NoAssoc,
          se_err_AssocIncomplete : msg := 'Filename association invalid';
          se_err_DDEBusy,
          se_err_DDEFail,
          se_err_DDETimeOut :      msg := 'DDE error';
         se_err_Share :        msg := 'Sharing violation';
          else                    msg := 'no text';
          end; // of case
     raise Exception.Create ('ShellExecute error #' + IntToStr (rslt) + ': ' + msg);
     end;
end;

function SendExternalMessage(const Hwnd : THandle; const Destination : Cardinal; const ParameterString : string): Boolean;
var
   cd: ^TCOPYDATASTRUCT;
begin
   Result := false;
   if IsWindow(Hwnd) then
   begin
      // Generate data and send
      cd.dwData:= Destination;
      cd.cbData:= length(ParameterString)+1;
      cd.lpData:= PChar(ParameterString);
      SendMessage(Hwnd,wm_copydata,3,integer(@cd));
      Result := true;
   end;
end;

end.
