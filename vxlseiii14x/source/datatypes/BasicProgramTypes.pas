unit BasicProgramTypes;

interface

uses ExtCtrls, StdCtrls, Menus;

type
   PPaintBox = ^TPaintBox;
   PLabel = ^TLabel;
   PMenuItem = ^TMenuItem;

   TSitesList = array of packed record
      SiteName : string;
      SiteUrl : string;
   end;

   TColourSchemesInfo = array of packed record
        Name,Filename,By,Website : string;
   end;
   
implementation

end.
