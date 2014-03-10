unit CommandBase;

interface

uses ControllerDataTypes, Classes;

type
   TCommandBase = class
      protected
         procedure ReadAttributes1Int(var _Params: TCommandParams; var _IntAttrib1: integer; _IntDefault1: integer);
         procedure ReadAttributes2Int(var _Params: TCommandParams; var _IntAttrib1, _IntAttrib2: integer; _IntDefault1, _IntDefault2: integer);
         procedure ReadAttributes3Int(var _Params: TCommandParams; var _IntAttrib1, _IntAttrib2, _IntAttrib3: integer; _IntDefault1, _IntDefault2, _IntDefault3: integer);
         procedure ReadAttributes1Int1Single(var _Params: TCommandParams; var _IntAttrib1: integer; var _SingleAttrib1: single; _IntDefault1: integer; _SingleDefault1: single);
         procedure ReadAttributes3Int1Single(var _Params: TCommandParams; var _IntAttrib1, _IntAttrib2, _IntAttrib3: integer; var _SingleAttrib1: single; _IntDefault1, _IntDefault2, _IntDefault3: integer; _SingleDefault1: single);
         procedure ReadAttributes1Bool1Single(var _Params: TCommandParams; var _BoolAttrib1: boolean; var _SingleAttrib1: single; _BoolDefault1: boolean; _SingleDefault1: single);
      public
         procedure Execute; virtual; abstract;
   end;

implementation

procedure TCommandBase.ReadAttributes1Int(var _Params: TCommandParams; var _IntAttrib1: integer; _IntDefault1: integer);
begin
   if _Params <> nil then
   begin
      if _Params.Size = (sizeof(longint)) then
      begin
         _Params.Seek(0,soFromBeginning);
         _Params.Read(_IntAttrib1,sizeof(longint));
      end
      else  // use defaults
      begin
         _IntAttrib1 := _IntDefault1;
      end;
   end
   else
   begin
      _IntAttrib1 := _IntDefault1;
   end;
end;

procedure TCommandBase.ReadAttributes2Int(var _Params: TCommandParams; var _IntAttrib1, _IntAttrib2: integer; _IntDefault1, _IntDefault2: integer);
begin
   if _Params <> nil then
   begin
      if _Params.Size = (2 * sizeof(longint)) then
      begin
         _Params.Seek(0,soFromBeginning);
         _Params.Read(_IntAttrib1,sizeof(longint));
         _Params.Read(_IntAttrib2,sizeof(longint));
      end
      else  // use defaults
      begin
         _IntAttrib1 := _IntDefault1;
         _IntAttrib2 := _IntDefault2;
      end;
   end
   else
   begin
      _IntAttrib1 := _IntDefault1;
      _IntAttrib2 := _IntDefault2;
   end;
end;

procedure TCommandBase.ReadAttributes3Int(var _Params: TCommandParams; var _IntAttrib1, _IntAttrib2, _IntAttrib3: integer; _IntDefault1, _IntDefault2, _IntDefault3: integer);
begin
   if _Params <> nil then
   begin
      if _Params.Size = (3 * sizeof(longint)) then
      begin
         _Params.Seek(0,soFromBeginning);
         _Params.Read(_IntAttrib1,sizeof(longint));
         _Params.Read(_IntAttrib2,sizeof(longint));
         _Params.Read(_IntAttrib3,sizeof(longint));
      end
      else  // use defaults
      begin
         _IntAttrib1 := _IntDefault1;
         _IntAttrib2 := _IntDefault2;
         _IntAttrib3 := _IntDefault3;
      end;
   end
   else
   begin
      _IntAttrib1 := _IntDefault1;
      _IntAttrib2 := _IntDefault2;
      _IntAttrib3 := _IntDefault3;
   end;
end;

procedure TCommandBase.ReadAttributes1Int1Single(var _Params: TCommandParams; var _IntAttrib1: integer; var _SingleAttrib1: single; _IntDefault1: integer; _SingleDefault1: single);
begin
   if _Params <> nil then
   begin
      if _Params.Size = (sizeof(longint) + sizeof(single)) then
      begin
         _Params.Seek(0,soFromBeginning);
         _Params.Read(_IntAttrib1,sizeof(longint));
         _Params.Read(_SingleAttrib1,sizeof(single));
      end
      else  // use defaults
      begin
         _IntAttrib1 := _IntDefault1;
         _SingleAttrib1 := _SingleDefault1;
      end;
   end
   else
   begin
      _IntAttrib1 := _IntDefault1;
      _SingleAttrib1 := _SingleDefault1;
   end;
end;

procedure TCommandBase.ReadAttributes3Int1Single(var _Params: TCommandParams; var _IntAttrib1, _IntAttrib2, _IntAttrib3: integer; var _SingleAttrib1: single; _IntDefault1, _IntDefault2, _IntDefault3: integer; _SingleDefault1: single);
begin
   if _Params <> nil then
   begin
      if _Params.Size = ((3 * sizeof(longint)) + sizeof(single)) then
      begin
         _Params.Seek(0,soFromBeginning);
         _Params.Read(_IntAttrib1,sizeof(longint));
         _Params.Read(_IntAttrib2,sizeof(longint));
         _Params.Read(_IntAttrib3,sizeof(longint));
         _Params.Read(_SingleAttrib1,sizeof(single));
      end
      else  // use defaults
      begin
         _IntAttrib1 := _IntDefault1;
         _IntAttrib2 := _IntDefault2;
         _IntAttrib3 := _IntDefault3;
         _SingleAttrib1 := _SingleDefault1;
      end;
   end
   else
   begin
      _IntAttrib1 := _IntDefault1;
      _IntAttrib2 := _IntDefault2;
      _IntAttrib3 := _IntDefault3;
      _SingleAttrib1 := _SingleDefault1;
   end;
end;

procedure TCommandBase.ReadAttributes1Bool1Single(var _Params: TCommandParams; var _BoolAttrib1: boolean; var _SingleAttrib1: single; _BoolDefault1: boolean; _SingleDefault1: single);
begin
   if _Params <> nil then
   begin
      if _Params.Size = (sizeof(longint) + sizeof(single)) then
      begin
         _Params.Seek(0,soFromBeginning);
         _Params.Read(_BoolAttrib1,sizeof(boolean));
         _Params.Read(_SingleAttrib1,sizeof(single));
      end
      else  // use defaults
      begin
         _BoolAttrib1 := _BoolDefault1;
         _SingleAttrib1 := _SingleDefault1;
      end;
   end
   else
   begin
      _BoolAttrib1 := _BoolDefault1;
      _SingleAttrib1 := _SingleDefault1;
   end;
end;

end.
