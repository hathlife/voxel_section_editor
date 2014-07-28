unit CommunityLinks;

interface

procedure LoadCommunityLinks;

implementation

uses FormMain, SysUtils, Dialogs, Menus;

 // *****************************************************
 // ********* Community Menu Loading Procedures *********
 // *****************************************************

procedure LoadCommunityLinks;
var
   CatCounter, Counter, position: word; // String element and its char position
   line, pos: word; // File line and position
   token: char;     // current char
   F:    Text;      // file
   OnText, OnUrl, OnName, OnCategory: boolean;
   CatName: string;
   Item: TMenuItem;
begin
   // Check for file
   if not fileexists(extractfiledir(ParamStr(0)) + '/commlist.ini') then
   begin
      ShowMessage('Error! Commlist.ini doesn''t exist. Initialization aborted!');
      FrmMain.Close;
      Exit;
   end;

   // Open File
   AssignFile(F, extractfiledir(ParamStr(0)) + '/commlist.ini');
   Reset(F);

   // Reset engine
   CatCounter := 1;
   counter := 0;
   position := 0;
   line   := 1;
   pos    := 1;
   OnText := False;
   OnUrl  := False;
   OnName := False;
   OnCategory := False;

   // Start reading
   while not EOF(F) do
   begin
      // Read next char
      Read(F, token);

      // If it's receiving text, then...
      if OnText then
      begin
         case (token) of
            ']':
            begin
               Inc(pos);
               Inc(line);
               OnCategory := False;
               OnText   := False;
               Item     := TMenuItem.Create(FrmMain);
               Item.Caption := CatName;
               Item.Tag := CatCounter;
               Item.Visible := True;
               FrmMain.Sites1.Add(Item);
               Inc(CatCounter);
               ReadLn(F);
            end;
            '$':
            begin
               Inc(pos);
               Inc(line);
               OnUrl  := False;
               OnText := False;
               Readln(F);
            end;
            '>':
            begin
               Inc(pos);
               Inc(line);
               OnName   := False;
               OnText   := False;
               Item     := TMenuItem.Create(FrmMain);
               Item.Caption := FrmMain.SiteList[counter].SiteName;
               Item.Tag := Counter;
               Item.OnClick := FrmMain.LoadSite;
               Item.Visible := True;
               FrmMain.Sites1.Items[CatCounter].Add(Item);
               Inc(counter);
               Readln(F);
            end;
            else
            begin
               if OnCategory then
               begin
                  SetLength(CatName, position);
                  CatName[position] := token;
               end
               else if OnUrl then
               begin
                  SetLength(FrmMain.SiteList[counter].SiteUrl, position);
                  FrmMain.SiteList[counter].SiteUrl[position] := token;
               end
               else if OnName then
               begin
                  SetLength(FrmMain.SiteList[counter].SiteName, position);
                  FrmMain.SiteList[counter].SiteName[position] := token;
               end;
               Inc(position);
            end;
         end;
      end
      else // searching instructions
      begin
         case (token) of
            ' ':
            begin
               Inc(pos);
            end;
            '[':
            begin
               Inc(pos);
               position   := 1;
               OnCategory := True;
               OnText     := True;
               CatName    := '';
            end;
            '$':
            begin
               Inc(pos);
               position := 1;
               OnUrl    := True;
               OnText   := True;
               SetLength(FrmMain.SiteList, Counter + 1);
            end;
            '<':
            begin
               Inc(pos);
               position := 1;
               OnName   := True;
               OnText   := True;
            end;
            '#':
            begin
               Readln(F);
               Inc(line);
               pos := 1;
            end;
            else
               ShowMessage('Community Links Error: Parse error at Line ' +
                  IntToStr(line) + ', Position ' + IntToStr(pos));
         end;
      end;
   end;
   CloseFile(F);
end;



end.
