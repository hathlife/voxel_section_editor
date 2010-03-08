unit BasicFunctions;

interface

uses BasicDataTypes,SysUtils, Classes, Math, Windows, Graphics, ShellAPI;

// String related
function WriteStringToStream(const _String: string; var _Stream : TStream): boolean;
function ReadStringFromStream(var _Stream: TStream): string;
function CopyString(const _String : string): string;

function GetBool(_Value : integer): boolean; overload;
function GetBool(_Value : string): boolean; overload;
function GetStringID(_ID : integer): string;

// Graphics related (OpenGL engine)
function GetPow2Size(Size : Cardinal) : Cardinal;
function SetVector4f(x, y, z, w : single) : TVector4f;
Function TVector3fToTColor(Vector3f : TVector3f) : TColor;
Function TColorToTVector3f(Color : TColor) : TVector3f;
function Subtract3i(_V1,_V2: TVector3i): TVector3i;
function RGBA(r, g, b, a: Byte): COLORREF;
function CopyVector4f(_V: TVector4f): TVector4f;

// Program related
function RunAProgram (const theProgram, itsParameters, defaultDirectory : string): integer;
function RunProgram (const theProgram, itsParameters, defaultDirectory : string): TShellExecuteInfo;
function GetParamStr: String;


implementation

// String related
function WriteStringToStream(const _String: string; var _Stream : TStream): boolean;
var
   MyChar : integer;
   Zero : char;
begin
   Result := false;
   Zero := #0;
   try
      for MyChar := 1 to Length(_String) do
      begin
        _Stream.WriteBuffer(_String[MyChar],sizeof(char));
      end;
      _Stream.WriteBuffer(Zero,sizeof(Char));
   except
      exit;
   end;
   Result := true;
end;

function ReadStringFromStream(var _Stream: TStream): string;
var
   MyChar : char;
begin
   Result := '';
   try
      _Stream.ReadBuffer(MyChar,sizeof(Char));
      while MyChar <> #0 do
      begin
         Result := Result + MyChar;
         _Stream.ReadBuffer(MyChar,sizeof(Char));
      end;
   except
      exit;
   end;
end;

function CopyString(const _String: string): string;
begin
   Result := copy(_String,1,Length(_String));
end;

function GetBool(_Value : integer): boolean;
begin
   if _Value <> 0 then
      Result := true
   else
      Result := false;
end;

function GetBool(_Value : string): boolean;
begin
   if CompareText(_Value,'true') = 0 then
      Result := true
   else
      Result := false;
end;


function GetStringID(_ID : integer): string;
begin
   if _ID < 10000 then
   begin
      if (_ID > 999) then
         Result := IntToStr(_ID)
      else if (_ID > 99) then
         Result := '0' + IntToStr(_ID)
      else if (_ID > 9) then
         Result := '00' + IntToStr(_ID)
      else
         Result := '000' + IntToStr(_ID);
   end;
end;

// Graphics related (OpenGL engine)
function GetPow2Size(Size : Cardinal) : Cardinal;
begin
   Result := 1;
   while (Result < Size) and (Result < 4096) do
      Result := Result shl 1;
   if Result > 4096 then
      Result := 4096;
end;

function SetVector4f(x, y, z, w : single) : TVector4f;
begin
   result.x := x;
   result.y := y;
   result.z := z;
   result.W := w;
end;

Function TVector3fToTColor(Vector3f : TVector3f) : TColor;
begin
   Result := RGB(trunc(Vector3f.X*255),trunc(Vector3f.Y*255),trunc(Vector3f.Z*255));
end;

Function TColorToTVector3f(Color : TColor) : TVector3f;
begin
   Result.X := GetRValue(Color) / 255;
   Result.Y := GetGValue(Color) / 255;
   Result.Z := GetBValue(Color) / 255;
end;

function Subtract3i(_V1,_V2: TVector3i): TVector3i;
begin
   Result.X := _V1.X - _V2.X;
   Result.Y := _V1.Y - _V2.Y;
   Result.Z := _V1.Z - _V2.Z;
end;

function CopyVector4f(_V: TVector4f): TVector4f;
begin
   Result.X := _V.X;
   Result.Y := _V.Y;
   Result.Z := _V.Z;
   Result.W := _V.W;
end;

function RGBA(r, g, b, a: Byte): COLORREF;
begin
  Result := (r or (g shl 8) or (b shl 16) or (a shl 24));
end;

// Program related.
function RunAProgram (const theProgram, itsParameters, defaultDirectory : string): integer;
var
   msg : string;
begin
   Result := ShellExecute(0, 'open', pChar(theProgram), pChar(itsParameters), pChar(defaultDirectory), sw_ShowNormal);
   if Result <= 32 then
   begin
      case Result of
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
      raise Exception.Create ('ShellExecute error #' + IntToStr(Result) + ': ' + msg);
   end;
end;

function RunProgram (const theProgram, itsParameters, defaultDirectory : string): TShellExecuteInfo;
var
   msg : string;
begin
   Result.cbSize := sizeof(TShellExecuteInfo);
   Result.lpFile := pChar(theProgram);
   Result.lpParameters := pChar(itsParameters);
   Result.lpDirectory := pChar(defaultDirectory);
   Result.nShow := sw_ShowNormal;
   Result.fMask := SEE_MASK_NOCLOSEPROCESS;
   Result.Wnd := 0;
   Result.lpVerb := 'open';
   if not ShellExecuteEx(@Result) then
   begin
      if Result.hInstApp <= 32 then
      begin
         case Result.hInstApp of
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
         raise Exception.Create ('ShellExecute error #' + IntToStr(Result.hInstApp) + ': ' + msg);
      end;
   end;
end;


function GetParamStr: String;
var
x : integer;
begin
   Result := '';
   for x := 1 to ParamCount do
      if Result <> '' then
         Result := Result + ' ' +ParamStr(x)
      else
         Result := ParamStr(x);
end;


end.
