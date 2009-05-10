unit BasicFunctions;

interface

uses BasicDataTypes,SysUtils, Classes, Math;

function WriteStringToStream(const _String: string; var _Stream : TStream): boolean;
function ReadStringFromStream(var _Stream: TStream): string;
function CopyString(const _String : string): string;

function GetBool(_Value : integer): boolean;
function GetStringID(_ID : integer): string;

function GetPow2Size(Size : Cardinal) : Cardinal;

function SetVector4f(x, y, z, w : single) : TVector4f;

implementation


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

function GetStringID(_ID : integer): string;
begin
   if _ID < 9999 then
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

function GetPow2Size(Size : Cardinal) : Cardinal;
var
   Step : Byte;
begin
   Step   := 0;
   Repeat
      Result := Trunc(Power(2,Step));
      inc(Step);
   Until (Result >= Size) or (Result >= 4096);
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


end.
