unit PaletteControl;

interface

uses Menus, BasicProgramTypes, Classes;

type
   TPaletteControl = class
      private
         Owner: TComponent;

         function IsFileInUse(const _FileName: string): Boolean;
         function FindSubMenuItemFromCaption(var _BaseMenuItem: TMenuItem; const _Caption: string):TMenuItem;
         procedure ClearSubMenu(var _MenuItem: TMenuItem);
      public
         PaletteSchemes : TPaletteSchemes;
         OnClickEvent: TNotifyEvent;

         constructor Create(const _Owner: TComponent; _OnClickEvent: TNotifyEvent);
         destructor Destroy; override;
         procedure ResetPaletteSchemes;
         procedure AddPalettesToSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer); overload;
         procedure AddPalettesToSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer;  _CreateSubMenu: boolean); overload;
         procedure UpdatePalettesAtSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer); overload;
         procedure UpdatePalettesAtSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer;  _UseBaseItem, _ClearBaseItem: boolean); overload;
   end;

implementation

uses BasicFunctions, Windows, SysUtils;

constructor TPaletteControl.Create(const _Owner: TComponent; _OnClickEvent: TNotifyEvent);
begin
   Owner := _Owner;
   OnClickEvent := _OnClickEvent;
end;

destructor TPaletteControl.Destroy;
begin
   ResetPaletteSchemes;
   inherited Destroy;
end;

procedure TPaletteControl.ResetPaletteSchemes;
begin
   SetLength(PaletteSchemes, 0);
end;

procedure TPaletteControl.ClearSubMenu(var _MenuItem: TMenuItem);
var
   i: integer;
   item: TMenuItem;
begin
   if _MenuItem.Count > 0 then
   begin
      i := _MenuItem.Count - 1;
      while i >= 0 do
      begin
         item := _MenuItem.Items[i];
         if Item.Count > 0 then
         begin
            ClearSubMenu(Item);
         end;
         _MenuItem.Delete(i);
         dec(i);
      end;
   end;
end;

function TPaletteControl.FindSubMenuItemFromCaption(var _BaseMenuItem: TMenuItem; const _Caption: string):TMenuItem;
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
   Result.Visible := false;
   _BaseMenuItem.Insert(_BaseMenuItem.Count, Result);
end;

// copied from: http://stackoverflow.com/questions/16287983/why-do-i-get-i-o-error-32-even-though-the-file-isnt-open-in-any-other-program
function TPaletteControl.IsFileInUse(const _FileName: string): Boolean;
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

procedure TPaletteControl.AddPalettesToSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer);
begin
   AddPalettesToSubMenu(_SubMenu, _Dir, _Counter, _ImageIndex, false);
end;

procedure TPaletteControl.AddPalettesToSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer;  _CreateSubMenu: boolean);
var
   f: TSearchRec;
   FileName, DirName, path: String;
   item: TMenuItem;
   CurrentSubMenu: TMenuItem;
begin
   if not DirectoryExists(_Dir) then
      exit;

   if _CreateSubMenu then
   begin
      Item     := TMenuItem.Create(Owner);
      item.Caption := ExtractFileName(ExcludeTrailingPathDelimiter(_Dir));
      //   item.OnClick := FrmMain.blank2Click;
      _SubMenu.Insert(_SubMenu.Count, Item);
      CurrentSubMenu := Item;
   end
   else
   begin
      if _SubMenu = nil then
         exit;
      CurrentSubMenu := _SubMenu;
   end;

   CurrentSubMenu.Visible := false;
   path := Concat(_Dir, '*.pal');
   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      Filename := IncludeTrailingPathDelimiter(_Dir) + f.Name;
      SetLength(PaletteSchemes, High(PaletteSchemes)+2);

      PaletteSchemes[High(PaletteSchemes)].FileName := Filename;
      PaletteSchemes[High(PaletteSchemes)].ImageIndex := _ImageIndex;

      item := TMenuItem.Create(Owner);
      item.AutoHotkeys := maManual;
      item.Caption := extractfilename(PaletteSchemes[High(PaletteSchemes)].FileName);
      item.Tag := High(PaletteSchemes); // so we know which it is
      item.OnClick := OnClickEvent;

      CurrentSubMenu.Insert(CurrentSubMenu.Count, item);
   until FindNext(f) <> 0;
   FindClose(f);

   if (High(PaletteSchemes)+1) > _Counter then
   begin
      CurrentSubMenu.Visible := true;
   end;
   _Counter := High(PaletteSchemes)+1;

   // Find directories.
   Path := IncludeTrailingPathDelimiter(_Dir) + '*';
   if FindFirst(path,faDirectory,f) = 0 then
   begin
      repeat
         if (CompareStr(f.Name,'.') <> 0) and (CompareStr(f.Name, '..') <> 0) then
         begin
            DirName := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(_Dir) + f.Name);
            if DirectoryExists(DirName) then // It sounds unnecessary, but for some reason, it may catch some weird dirs sometimes.
            begin
               AddPalettesToSubMenu(CurrentSubMenu, DirName, _Counter, _ImageIndex, true);
            end;
         end;
      until FindNext(f) <> 0;
   end;
   FindClose(f);
end;

procedure TPaletteControl.UpdatePalettesAtSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer);
begin
   UpdatePalettesAtSubMenu(_SubMenu, _Dir, _Counter, _ImageIndex, true, true);
end;

procedure TPaletteControl.UpdatePalettesAtSubMenu(var _SubMenu: TMenuItem; const _Dir: string; var _Counter: integer; const _ImageIndex: integer;  _UseBaseItem, _ClearBaseItem: boolean);
var
   f: TSearchRec;
   FileName, DirName, path: String;
   item: TMenuItem;
   CurrentSubMenu: TMenuItem;
begin
   if not DirectoryExists(_Dir) then
      exit;

   if not _UseBaseItem then
   begin
      CurrentSubMenu := FindSubMenuItemFromCaption(_SubMenu, ExtractFileName(ExcludeTrailingPathDelimiter(_Dir)));
   end
   else
   begin
      CurrentSubMenu := _SubMenu;
   end;
   if _ClearBaseItem then
   begin
      ClearSubMenu(CurrentSubMenu);
   end;

   path := Concat(_Dir, '*.pal');
   // find files
   if FindFirst(path,faAnyFile,f) = 0 then
   repeat
      FileName := _Dir + f.Name;
      if FileExists(FileName) and (not IsFileInUse(FileName)) then
      begin
         SetLength(PaletteSchemes, High(PaletteSchemes)+2);

         PaletteSchemes[High(PaletteSchemes)].FileName := Filename;
         PaletteSchemes[High(PaletteSchemes)].ImageIndex := _ImageIndex;

         item := TMenuItem.Create(Owner);
         item.AutoHotkeys := maManual;
         item.Caption := extractfilename(PaletteSchemes[High(PaletteSchemes)].FileName);
         item.Tag := High(PaletteSchemes); // so we know which it is
         item.OnClick := OnClickEvent;

         inc(_Counter);
         CurrentSubMenu.Insert(CurrentSubMenu.Count, item);
         inc(_Counter);
      end;
   until FindNext(f) <> 0;
   FindClose(f);

   if (High(PaletteSchemes)+1) > _Counter then
   begin
      CurrentSubMenu.Visible := true;
   end;

   // Find directories.
   Path := IncludeTrailingPathDelimiter(_Dir) + '*';
   if FindFirst(path,faDirectory,f) = 0 then
   begin
      repeat
         if (CompareStr(f.Name,'.') <> 0) and (CompareStr(f.Name, '..') <> 0) then
         begin
            DirName := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(_Dir) + f.Name);
            if DirectoryExists(DirName) then // It sounds unnecessary, but for some reason, it may catch some weird dirs sometimes.
            begin
               UpdatePalettesAtSubMenu(CurrentSubMenu, DirName, _Counter, _ImageIndex, false, true);
            end;
         end;
      until FindNext(f) <> 0;
   end;
   FindClose(f);
end;

end.
