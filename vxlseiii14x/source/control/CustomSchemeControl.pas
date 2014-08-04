unit CustomSchemeControl;

interface

uses Menus, BasicProgramTypes, CustomScheme, Classes;

type
   TCustomSchemeControl = class
      private
         MenuItems: array [1..19] of TMenuItem;

         BaseMn, CurrentSubMenu: TMenuItem;
         Owner: TComponent;

         function IsFileInUse(const _FileName: string): Boolean;
         function FindSubMenuItemFromCaption(var _BaseMenuItem: TMenuItem; const _Caption: string):TMenuItem;
         function CreateSplitterMenuItem: TMenuItem;
         procedure InsertItemAtMenu(var _item,_menu: TMenuItem; _GameType: integer; Split: boolean);
         procedure AddScheme(const _Filename: string);
         procedure SetupSubMenu;
      public
         LatestScheme : integer;
         ColourSchemes : TColourSchemesInfo;
         OnClickEvent: TNotifyEvent;

         constructor Create(var _BaseMenu: TMenuItem; const _Owner: TComponent; _OnClickEvent: TNotifyEvent);
         function UpdateCSchemes(var _BaseItem: TMenuItem; _Latest: integer; _Dir : string; _c : integer) : Integer; overload;
         function UpdateCSchemes(var _BaseItem: TMenuItem; _Latest: integer; _Dir : string; _c : integer; _UseBaseItem: boolean) : Integer; overload;
         function LoadCSchemes(var _BaseItem: TMenuItem; _Dir: string; _c: integer): integer; overload;
         function LoadCSchemes(var _BaseItem: TMenuItem; _Dir: string; _c: integer; _CreateSubMenu: boolean): integer; overload;
         function UpdateCScheme : integer;
         function LoadCScheme : integer;
   end;

implementation

uses BasicFunctions, Windows, SysUtils;

constructor TCustomSchemeControl.Create(var _BaseMenu: TMenuItem; const _Owner: TComponent; _OnClickEvent: TNotifyEvent);
begin
   BaseMn := _BaseMenu;
   Owner := _Owner;
   OnClickEvent := _OnClickEvent;
end;

function TCustomSchemeControl.FindSubMenuItemFromCaption(var _BaseMenuItem: TMenuItem; const _Caption: string):TMenuItem;
var
   i: integer;
begin
   i := 0;
   while i < _BaseMenuItem.Count do
   begin
      if CompareText(_BaseMenuItem.Items[i].Caption, _Caption) = 0 then
      begin
         Result := _BaseMenuItem.Items[i];
         exit;
      end;
      inc(i);
   end;
   Result := TMenuItem.Create(Owner);
   Result.Caption := CopyString(_Caption);
   _BaseMenuItem.Insert(_BaseMenuItem.Count, Result);
end;

function TCustomSchemeControl.CreateSplitterMenuItem: TMenuItem;
begin
   Result := TMenuItem.Create(Owner);
   Result.Caption := '-';
end;

procedure TCustomSchemeControl.InsertItemAtMenu(var _item,_menu: TMenuItem; _GameType: integer; Split: boolean);
var
   i, pos: integer;
begin
   if _Menu = nil then
   begin
      _Menu := TMenuItem.Create(Owner);
      case (_GameType) of
         1: _Menu.Caption := 'Tiberian Sun';
         2: _Menu.Caption := 'Red Alert 2';
         3: _Menu.Caption := 'Yuri''s Revenge';
         4: _Menu.Caption := 'Allied';
         5: _Menu.Caption := 'Soviet';
         6: _Menu.Caption := 'Yuri';
         7: _Menu.Caption := 'Brick';
         8: _Menu.Caption := 'Grayscale';
         9: _Menu.Caption := 'Remap';
         10: _Menu.Caption := 'Brown 1';
         11: _Menu.Caption := 'Brown 2';
         12: _Menu.Caption := 'Blue';
         13: _Menu.Caption := 'Green';
         14: _Menu.Caption := 'No Unlit';
         15: _Menu.Caption := 'Red';
         16: _Menu.Caption := 'Yellow';
         17: _Menu.Caption := 'Others';
         18: _Menu.Caption := 'Tiberian Dawn';
         19: _Menu.Caption := 'Red Alert 1';
      end;
      case (_GameType) of
         18: _Menu.Tag := 0;
         19: _Menu.Tag := 1;
         else _Menu.Tag := _GameType + 1;
      end;
      pos := 0;
      if CurrentSubMenu.Count > 0 then
      begin
         i := 1;
         if _Menu.Tag > CurrentSubMenu.Items[0].Tag then
         begin
            while (i < CurrentSubMenu.Count) and (pos = 0) do
            begin
               if _Menu.Tag < CurrentSubMenu.Items[i].Tag then
               begin
                  pos := i;
               end
               else
                  inc(i);
            end;
            if i = CurrentSubMenu.Count then
               pos := i;
         end;
      end;
      CurrentSubMenu.Insert(pos, _Menu);
      MenuItems[_GameType] := _Menu;
   end;
   if Split then
      _Menu.Insert(_Menu.Count, CreateSplitterMenuItem());
   _Menu.Insert(_Menu.Count, _Item);
   _Menu.Visible := True;
end;

procedure TCustomSchemeControl.AddScheme(const _Filename: string);
var
   item: TMenuItem;
   Scheme : TCustomScheme;
   c : integer;
begin
   c := High(ColourSchemes)+2;
   SetLength(ColourSchemes, c + 1);

   Scheme := TCustomScheme.CreateForVXLSE(_Filename);
   ColourSchemes[c].FileName := CopyString(_Filename);

   item     := TMenuItem.Create(Owner);
   item.Caption := Scheme.Name;
   item.Tag := c; // so we know which it is
   item.OnClick := OnClickEvent;
   item.ImageIndex := Scheme.ImageIndex;
   if Scheme.GameType = 0 then
      Scheme.GameType := 17;
   InsertItemAtMenu(item,MenuItems[Scheme.GameType],Scheme.GameType,Scheme.Split); // TS

   Scheme.Free;
end;

// copied from: http://stackoverflow.com/questions/16287983/why-do-i-get-i-o-error-32-even-though-the-file-isnt-open-in-any-other-program
function TCustomSchemeControl.IsFileInUse(const _FileName: string): Boolean;
var
   HFileRes: HFILE;
begin
   Result := False;
   if not FileExists(_FileName) then Exit;
   HFileRes := CreateFile(PChar(_FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
   Result := (HFileRes = INVALID_HANDLE_VALUE);
   if not Result then
      CloseHandle(HFileRes);
end;

function TCustomSchemeControl.UpdateCSchemes(var _BaseItem: TMenuItem; _Latest: integer; _Dir : string; _c : integer) : Integer;
begin
   Result := UpdateCSchemes(_BaseItem, _Latest, _Dir, _c, true);
end;

function TCustomSchemeControl.UpdateCSchemes(var _BaseItem: TMenuItem; _Latest: integer; _Dir : string; _c : integer; _UseBaseItem: boolean) : Integer;
var
   f:     TSearchRec;
   Name, path:  string;
   i : integer;
begin
   if not DirectoryExists(IncludeTrailingPathDelimiter(_Dir)) then
      exit;

   if not _UseBaseItem then
   begin
      CurrentSubMenu := FindSubMenuItemFromCaption(_BaseItem, ExtractFileName(ExcludeTrailingPathDelimiter(_Dir)));
   end
   else
   begin
      CurrentSubMenu := _BaseItem;
   end;
   // Reset submenus.
   for i := 1 to 19 do
   begin
      MenuItems[i] := nil;
   end;
   // Find submenu subitems
   SetupSubMenu;

   // prepare
   path := Concat(_Dir, '*.cscheme');
   // find files
   if FindFirst(path, faAnyFile, f) = 0 then
      repeat
         Name := IncludeTrailingPathDelimiter(_Dir) + f.Name;
         if FileExists(Name) and (not IsFileInUse(Name)) then
         begin
            if f.Time > _Latest then
            begin
               AddScheme(Concat(_Dir, f.Name));
               if f.Time > LatestScheme then
               begin
                  LatestScheme := f.Time;
               end;
               inc(_c);
            end;
         end;
      until FindNext(f) <> 0;
   FindClose(f);

   // Check all subdirectories.
   Path := IncludeTrailingPathDelimiter(_Dir) + '*';
   if FindFirst(path,faDirectory,f) = 0 then
   begin
      repeat
         if (CompareStr(f.Name,'.') <> 0) and (CompareStr(f.Name, '..') <> 0) then
         begin
            Name := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(_Dir) + f.Name);
            if DirectoryExists(Name) then // It sounds unnecessary, but for some reason, it may catch some weird dirs sometimes.
            begin
               UpdateCSchemes(CurrentSubMenu, _Latest, Name, _c, false);
            end;
         end;
      until FindNext(f) <> 0;
   end;
   FindClose(f);
   Result := _c;
end;

procedure TCustomSchemeControl.SetupSubMenu;
var
   i : integer;
begin
   // Reset submenus.
   for i := 1 to 19 do
   begin
      MenuItems[i] := nil;
   end;
   // Find submenu subitems
   if CurrentSubMenu.Count > 0 then
   begin
      i := 0;
      while i < CurrentSubMenu.Count do
      begin
         if CompareText(CurrentSubMenu.Items[i].Caption, 'Tiberian Sun') = 0 then
         begin
            MenuItems[1] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 2;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Red Alert 2') = 0 then
         begin
            MenuItems[2] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 3;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Yuri''s Revenge') = 0 then
         begin
            MenuItems[3] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 4;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Allied') = 0 then
         begin
            MenuItems[4] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 5;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Soviet') = 0 then
         begin
            MenuItems[5] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 6;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Yuri') = 0 then
         begin
            MenuItems[6] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 7;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Brick') = 0 then
         begin
            MenuItems[7] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 8;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Grayscale') = 0 then
         begin
            MenuItems[8] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 9;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Remap') = 0 then
         begin
            MenuItems[9] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 10;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Brown 1') = 0 then
         begin
            MenuItems[10] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 11;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Brown 2') = 0 then
         begin
            MenuItems[11] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 12;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Blue') = 0 then
         begin
            MenuItems[12] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 13;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Green') = 0 then
         begin
            MenuItems[13] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 14;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'No Unlit') = 0 then
         begin
            MenuItems[14] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 15;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Red') = 0 then
         begin
            MenuItems[15] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 16;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Yellow') = 0 then
         begin
            MenuItems[16] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 17;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Others') = 0 then
         begin
            MenuItems[17] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 18;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Tiberian Dawn') = 0 then
         begin
            MenuItems[18] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 0;
         end
         else if CompareText(CurrentSubMenu.Items[i].Caption, 'Red Alert 1') = 0 then
         begin
            MenuItems[19] := CurrentSubMenu.Items[i];
            CurrentSubMenu.Items[i].Tag := 1;
         end;
         inc(i);
      end;
   end;
end;

function TCustomSchemeControl.LoadCSchemes(var _BaseItem: TMenuItem; _Dir: string; _c: integer): integer;
begin
   Result := LoadCSchemes(_BaseItem, _Dir, _c, false);
end;

function TCustomSchemeControl.LoadCSchemes(var _BaseItem: TMenuItem; _Dir: string; _c: integer; _CreateSubMenu: boolean): integer;
var
   f:     TSearchRec;
   Name, path:  string;
   Item: TMenuItem;
begin
   if not DirectoryExists(IncludeTrailingPathDelimiter(_Dir)) then
      exit;

   if _CreateSubMenu then
   begin
      Item     := TMenuItem.Create(Owner);
      item.Caption := ExtractFileName(ExcludeTrailingPathDelimiter(_Dir));
      //   item.OnClick := FrmMain.blank2Click;
      _BaseItem.Insert(_BaseItem.Count, Item);
      CurrentSubMenu := Item;
   end
   else
   begin
      if _BaseItem = nil then
         exit;
      CurrentSubMenu := _BaseItem;
   end;
   // Find submenu subitems
   SetupSubMenu;

   // prepare
   path := Concat(_Dir, '*.cscheme');

   // find files
   if FindFirst(path, faAnyFile, f) = 0 then
      repeat
         Name := IncludeTrailingPathDelimiter(_Dir) + f.Name;
         if FileExists(Name) and (not IsFileInUse(Name)) then
         begin
            AddScheme(Concat(_Dir, f.Name));
            if f.Time > LatestScheme then
            begin
               LatestScheme := f.Time;
            end;
         end;
      until FindNext(f) <> 0;
   FindClose(f);

   Path := IncludeTrailingPathDelimiter(_Dir) + '*';
   if FindFirst(path,faDirectory,f) = 0 then
   begin
      repeat
         if (CompareStr(f.Name,'.') <> 0) and (CompareStr(f.Name, '..') <> 0) then
         begin
            Name := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(_Dir) + f.Name);
            if DirectoryExists(Name) then // It sounds unnecessary, but for some reason, it may catch some weird dirs sometimes.
            begin
               LoadCSchemes(CurrentSubMenu, Name, _c, true);
            end;
         end;
      until FindNext(f) <> 0;
   end;
   FindClose(f);
   Result := High(ColourSchemes)+1;
   if Result > _c then
   begin
      CurrentSubMenu.Visible := true;
   end;
end;

function TCustomSchemeControl.UpdateCScheme : integer;
var
   User,c,LastScheme : integer;
begin
   LastScheme := LatestScheme;
   User := UpdateCSchemes(BaseMn, LastScheme,ExtractFilePath(ParamStr(0))+'\cscheme\USER\',0);
   c := UpdateCSchemes(BaseMn, LastScheme,ExtractFilePath(ParamStr(0))+'\cscheme\PalPack1\',User);
   Result := UpdateCSchemes(BaseMn, LastScheme,ExtractFilePath(ParamStr(0))+'\cscheme\PalPack2\',c);
end;

function TCustomSchemeControl.LoadCScheme : integer;
var
   User,c : integer;
begin
   SetLength(ColourSchemes,0);
   User := LoadCSchemes(BaseMn, ExtractFilePath(ParamStr(0))+'\cscheme\USER\',0);
   c := LoadCSchemes(BaseMn, ExtractFilePath(ParamStr(0))+'\cscheme\PalPack1\',User);
   Result := LoadCSchemes(BaseMn, ExtractFilePath(ParamStr(0))+'\cscheme\PalPack2\',c);
end;


end.
