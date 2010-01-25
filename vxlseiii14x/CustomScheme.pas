unit CustomScheme;

interface

uses BasicFunctions, SysUtils, Classes;

type
   TCustomSchemeData = array[0..255] of integer;
   TCustomScheme = class
      private
         fName : string;
         fAuthor : string;
         fGameType : integer;
         fSplit : boolean;
         fWebsite : string;
         fImageIndex : integer;
         fSchemeType : integer;
         fData : TCustomSchemeData;
         // Gets
         function getName: string;
         function getAuthor: string;
         function getGameType: integer;
         function getSplit: boolean;
         function getWebsite: string;
         function getImageIndex: integer;
         function getSchemeType: integer;
         function getData: TCustomSchemeData;
         // Sets
         procedure setName(_Value: string);
         procedure setAuthor(_Value: string);
         procedure setGameType(_Value: integer);
         procedure setSplit(_Value: boolean);
         procedure setWebsite(_Value: string);
         procedure setImageIndex(_Value: integer);
         procedure setSchemeType(_Value: integer);
         procedure setData(_Value: TCustomSchemeData);
         // Text related operations
         function isLineTagEqual(const _Tag,_Line: string) : boolean;
         function getLineValue(const _Line : string): string;
         function getTagValue(const _StringList: TStringList; const _Tag: string): string;
      public
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(const _Filename: string); overload;
         constructor CreateForVXLSE(const _Filename: string);
         constructor CreateForData(const _Filename: string);
         destructor Destroy; override;
         // I/O
         procedure Load(const _Filename: string);
         procedure GatherInfoForVXLSE(const _Filename : string);
         procedure GatherData(const _Filename: string);
         procedure Save(const _Filename: string);
         // Properties
         property Name: string read getName write setName;
         property Author: string read getAuthor write setAuthor;
         property GameType: integer read getGameType write setGameType;
         property Split: boolean read getSplit write setSplit;
         property Website: string read getWebsite write setWebsite;
         property ImageIndex: integer read getImageIndex write setImageIndex;
         property SchemeType: integer read getSchemeType write setSchemeType;
         property Data: TCustomSchemeData read getData write setData;
   end;

implementation

// Constructors and Destructors
constructor TCustomScheme.Create;
begin
   fName := '';
   fAuthor := '';
   fWebsite := '';
   fGameType := 0;
   fImageIndex := -1;
   fSchemeType := 1;
   Split := false;
end;

constructor TCustomScheme.Create(const _Filename: string);
begin
   Load(_Filename);
end;

constructor TCustomScheme.CreateForVXLSE(const _Filename: string);
begin
   GatherInfoForVXLSE(_Filename);
   fAuthor := '';
   fWebsite := '';
   fSchemeType := 1;
end;

constructor TCustomScheme.CreateForData(const _Filename: string);
begin
   GatherData(_Filename);
end;

destructor TCustomScheme.Destroy;
begin
   fName := '';
   fAuthor := '';
   fWebsite := '';
   inherited Destroy;
end;

// I/O
procedure TCustomScheme.Load(const _Filename : string);
var
   s: TStringList;
   i : integer;
begin
   s := TStringList.Create;
   s.LoadFromFile(_Filename);
   fName := getTagValue(s,'name');
   fAuthor := getTagValue(s,'by');
   fWebsite := getTagValue(s,'website');
   fImageIndex := StrToIntDef(getTagValue(s,'imageindex'),-1);
   fSplit := GetBool(getTagValue(s,'split'));
   fGameType := StrToIntDef(getTagValue(s,'gametype'),0);
   fSchemeType := StrToIntDef(getTagValue(s,'schemetype'),1);
   for i := 0 to 255 do
   begin
      fData[i] := StrToIntDef(getTagValue(s,IntToStr(i)),0);
   end;
   s.Free;
end;

procedure TCustomScheme.GatherInfoForVXLSE(const _Filename : string);
var
   s: TStringList;
begin
   s := TStringList.Create;
   s.LoadFromFile(_Filename);
   fName := getTagValue(s,'name');
   fImageIndex := StrToIntDef(getTagValue(s,'imageindex'),-1);
   fSplit := GetBool(getTagValue(s,'split'));
   fGameType := StrToIntDef(getTagValue(s,'gametype'),0);
   s.Free;
end;

procedure TCustomScheme.GatherData(const _Filename : string);
var
   s: TStringList;
   i : integer;
begin
   s := TStringList.Create;
   s.LoadFromFile(_Filename);
   for i := 0 to 255 do
   begin
      fData[i] := StrToIntDef(getTagValue(s,IntToStr(i)),0);
   end;
   s.Free;
end;

procedure TCustomScheme.Save(const _Filename : string);
var
   F:     system.Text;
   i:     integer;
begin
   AssignFile(F,_Filename);
   Rewrite(F);
   Writeln(F,'[Info]');
   if Length(fName) > 0 then
      Writeln(F,'Name=' + fName)
   else
      Writeln(F,'Name=Unnamed Custom Scheme');
   if Length(fAuthor) > 0 then
      Writeln(F,'By=' + fAuthor)
   else
      Writeln(F,'By=Anonymous');
   if Length(fWebsite) > 0 then
      Writeln(F,'Website=' + fWebsite)
   else
      Writeln(F,'Website=None');
   Writeln(F,'ImageIndex=' + IntToStr(fImageIndex));
   if Split then
      Writeln(F,'Split=true')
   else
      Writeln(F,'Split=false');
   Writeln(F,'GameType=' + IntToStr(fGameType));
   Writeln(F,'SchemeType=' + IntToStr(fSchemeType));
   Writeln(F);
   Writeln(F,'[Data]');
   for i := 0 to 255 do
   begin
      WriteLn(F,IntToStr(i) + '=' + IntToStr(fData[i]));
   end;
   Writeln(F);
   CloseFile(F);
end;


// Gets
function TCustomScheme.getName: string;
begin
   Result := fName;
end;

function TCustomScheme.getAuthor: string;
begin
   Result := fAuthor;
end;

function TCustomScheme.getGameType: integer;
begin
   Result := fGameType;
end;

function TCustomScheme.getSplit: boolean;
begin
   Result := fSplit;
end;

function TCustomScheme.getWebsite: string;
begin
   Result := fWebsite;
end;

function TCustomScheme.getImageIndex: integer;
begin
   Result := fImageIndex;
end;

function TCustomScheme.getSchemeType: integer;
begin
   Result := fSchemeType;
end;

function TCustomScheme.getData: TCustomSchemeData;
begin
   Result := fData;
end;

// Sets
procedure TCustomScheme.setName(_Value: string);
begin
   fName := CopyString(_Value);
end;

procedure TCustomScheme.setAuthor(_Value: string);
begin
   fAuthor := CopyString(_Value);
end;

procedure TCustomScheme.setGameType(_Value: integer);
begin
   fGameType := _Value;
end;

procedure TCustomScheme.setSplit(_Value: boolean);
begin
   fSplit := _Value;
end;

procedure TCustomScheme.setWebsite(_Value: string);
begin
   fWebsite := CopyString(_Value);
end;

procedure TCustomScheme.setImageIndex(_Value: integer);
begin
   fImageIndex := _Value;
end;

procedure TCustomScheme.setSchemeType(_Value: integer);
begin
   fSchemeType := _Value;
end;

procedure TCustomScheme.setData(_Value: TCustomSchemeData);
begin
   fData := _Value;
end;

// Text related operations

// Check if a line (name=blahblah) has a value of a tag (i.e.: name, author, website)
function TCustomScheme.isLineTagEqual(const _Tag,_Line: string) : boolean;
var
   i: integer;
   Tag, Line: string;
begin
   Result := false;
   if (Length(_Tag) > 0) and (Length(_Line) > 0) and (Length(_Tag) < Length(_Line)) then
   begin
      Tag := Lowercase(_Tag);
      Line := Lowercase(_Line);
      Result := true;
      i := 1;
      while Result and (i <= Length(Tag)) do
      begin
         if Tag[i] <> Line[i] then
            Result := false;
         inc(i);
      end;
   end;
end;

function TCustomScheme.getLineValue(const _Line : string): string;
var
   i: integer;
   Found : boolean;
begin
   Result := '';
   i := 1;
   Found := false;
   while (i <= Length(_Line)) and (not Found) do
   begin
      if _Line[i] = '=' then
         Found := true;
      inc(i);
   end;
   if Found then
      Result := Copy(_Line,i,Length(_Line)-i+1);
end;

function TCustomScheme.getTagValue(const _StringList: TStringList; const _Tag: string): string;
var
   i: integer;
   Found : boolean;
begin
   Result := '!ERROR!';
   i := 0;
   Found := false;
   while (i < _StringList.Count) and (not Found) do
   begin
      if isLineTagEqual(_Tag,_StringList.Strings[i]) then
      begin
         Found := true;
         Result := getLineValue(_StringList.Strings[i]);
      end;
      inc(i);
   end;
end;

end.
